#!/usr/bin/env python3
"""Преобразует PCAPNG pktmon в стабильный CSV/таймлайн для сравнения MIC-185."""

from __future__ import annotations

import argparse
import csv
import ipaddress
import struct
from datetime import datetime, timezone
from pathlib import Path


TCP_FLAGS = (
    (0x100, "NS"),
    (0x080, "CWR"),
    (0x040, "ECE"),
    (0x020, "URG"),
    (0x010, "ACK"),
    (0x008, "PSH"),
    (0x004, "RST"),
    (0x002, "SYN"),
    (0x001, "FIN"),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--ip", required=True)
    parser.add_argument("--port", required=True, type=int)
    parser.add_argument("--csv", required=True, type=Path)
    parser.add_argument("--timeline", required=True, type=Path)
    return parser.parse_args()


def padded(length: int) -> int:
    return (length + 3) & ~3


def parse_options(data: bytes, endian: str) -> dict[int, list[bytes]]:
    result: dict[int, list[bytes]] = {}
    offset = 0
    while offset + 4 <= len(data):
        code, length = struct.unpack_from(endian + "HH", data, offset)
        offset += 4
        if code == 0:
            break
        value = data[offset : offset + length]
        result.setdefault(code, []).append(value)
        offset += padded(length)
    return result


def parse_packet(frame: bytes, device_ip: bytes, port: int) -> dict[str, object] | None:
    if len(frame) < 14:
        return None
    offset = 14
    ether_type = struct.unpack_from("!H", frame, 12)[0]
    while ether_type in (0x8100, 0x88A8) and len(frame) >= offset + 4:
        ether_type = struct.unpack_from("!H", frame, offset + 2)[0]
        offset += 4
    if ether_type != 0x0800 or len(frame) < offset + 20:
        return None

    version_ihl = frame[offset]
    if version_ihl >> 4 != 4:
        return None
    ihl = (version_ihl & 0x0F) * 4
    if ihl < 20 or len(frame) < offset + ihl:
        return None
    ip_total = struct.unpack_from("!H", frame, offset + 2)[0]
    protocol = frame[offset + 9]
    src_ip = frame[offset + 12 : offset + 16]
    dst_ip = frame[offset + 16 : offset + 20]
    if protocol != 6 or (src_ip != device_ip and dst_ip != device_ip):
        return None

    tcp_offset = offset + ihl
    if len(frame) < tcp_offset + 20:
        return None
    src_port, dst_port, seq, ack = struct.unpack_from("!HHII", frame, tcp_offset)
    if src_port != port and dst_port != port:
        return None
    data_offset = (frame[tcp_offset + 12] >> 4) * 4
    if data_offset < 20:
        return None
    flags_word = ((frame[tcp_offset + 12] & 1) << 8) | frame[tcp_offset + 13]
    ip_payload_end = min(len(frame), offset + ip_total)
    payload_start = tcp_offset + data_offset
    payload = frame[payload_start:ip_payload_end] if payload_start <= ip_payload_end else b""
    direction = "DEV->PC" if src_ip == device_ip else "PC->DEV"

    return {
        "direction": direction,
        "src_ip": str(ipaddress.ip_address(src_ip)),
        "src_port": src_port,
        "dst_ip": str(ipaddress.ip_address(dst_ip)),
        "dst_port": dst_port,
        "seq": seq,
        "ack": ack,
        "flags": "|".join(name for mask, name in TCP_FLAGS if flags_word & mask) or "-",
        "ip_len": ip_total,
        "tcp_payload_len": len(payload),
        "payload_hex": payload.hex(" ").upper(),
    }


def iter_packets(path: Path):
    data = path.read_bytes()
    offset = 0
    endian = "<"
    interfaces: list[dict[str, object]] = []
    section = 0
    while offset + 12 <= len(data):
        raw_type = data[offset : offset + 4]
        if raw_type == b"\x0A\x0D\x0D\x0A":
            if offset + 16 > len(data):
                break
            magic = data[offset + 8 : offset + 12]
            if magic == b"\x4D\x3C\x2B\x1A":
                endian = "<"
            elif magic == b"\x1A\x2B\x3C\x4D":
                endian = ">"
            else:
                raise ValueError("Неизвестный byte-order magic PCAPNG")
            block_type, block_len = struct.unpack_from(endian + "II", data, offset)
            interfaces = []
            section += 1
        else:
            block_type, block_len = struct.unpack_from(endian + "II", data, offset)
        if block_len < 12 or offset + block_len > len(data):
            raise ValueError(f"Повреждённый блок PCAPNG по смещению {offset}")
        body = data[offset + 8 : offset + block_len - 4]

        if block_type == 1 and len(body) >= 8:
            link_type = struct.unpack_from(endian + "H", body, 0)[0]
            options = parse_options(body[8:], endian)
            ts_resolution = 1_000_000
            if 9 in options and options[9] and options[9][0]:
                value = options[9][0][0]
                ts_resolution = (2 ** (value & 0x7F)) if value & 0x80 else (10 ** value)
            ts_offset = 0
            if 14 in options and options[14] and len(options[14][0]) >= 8:
                ts_offset = struct.unpack_from(endian + "q", options[14][0], 0)[0]
            interfaces.append(
                {"link_type": link_type, "ts_resolution": ts_resolution, "ts_offset": ts_offset}
            )
        elif block_type == 6 and len(body) >= 20:
            interface_id, ts_hi, ts_lo, cap_len, original_len = struct.unpack_from(
                endian + "IIIII", body, 0
            )
            packet = body[20 : 20 + cap_len]
            if interface_id < len(interfaces):
                interface = interfaces[interface_id]
                timestamp = ((ts_hi << 32) | ts_lo) / int(interface["ts_resolution"])
                timestamp += int(interface["ts_offset"])
                yield section, interface_id, timestamp, original_len, packet
        offset += block_len


def main() -> int:
    args = parse_args()
    device_ip = ipaddress.ip_address(args.ip)
    if device_ip.version != 4:
        raise SystemExit("Поддерживается только IPv4")
    device_bytes = device_ip.packed

    rows: list[dict[str, object]] = []
    first_timestamp: float | None = None
    for section, interface_id, timestamp, wire_len, frame in iter_packets(args.input):
        packet = parse_packet(frame, device_bytes, args.port)
        if packet is None:
            continue
        if first_timestamp is None:
            first_timestamp = timestamp
        packet.update(
            {
                "index": len(rows) + 1,
                "time_iso": datetime.fromtimestamp(timestamp, timezone.utc).astimezone().isoformat(
                    timespec="microseconds"
                ),
                "relative_ms": round((timestamp - first_timestamp) * 1000.0, 3),
                "delta_ms": round((timestamp - rows[-1]["_timestamp"]) * 1000.0, 3)
                if rows
                else 0.0,
                "wire_len": wire_len,
                "captured_len": len(frame),
                "section": section,
                "interface_id": interface_id,
                "_timestamp": timestamp,
            }
        )
        rows.append(packet)

    fields = [
        "index",
        "time_iso",
        "relative_ms",
        "delta_ms",
        "direction",
        "src_ip",
        "src_port",
        "dst_ip",
        "dst_port",
        "wire_len",
        "captured_len",
        "ip_len",
        "seq",
        "ack",
        "flags",
        "tcp_payload_len",
        "payload_hex",
        "section",
        "interface_id",
    ]
    args.csv.parent.mkdir(parents=True, exist_ok=True)
    with args.csv.open("w", newline="", encoding="utf-8-sig") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)

    with args.timeline.open("w", encoding="utf-8") as stream:
        stream.write(f"# MIC-185 {args.ip}:{args.port}; packets={len(rows)}\n")
        stream.write("# idx  relative    delta direction flags      seq        ack        payload wire\n")
        for row in rows:
            stream.write(
                f"{row['index']:6d} {row['relative_ms']:10.3f} "
                f"{row['delta_ms']:8.3f} {row['direction']:7s} "
                f"{row['flags']:<10s} {row['seq']:10d} {row['ack']:10d} "
                f"{row['tcp_payload_len']:7d} {row['wire_len']:5d}\n"
            )

    print(f"PACKETS={len(rows)}")
    print(f"CSV={args.csv}")
    print(f"TIMELINE={args.timeline}")
    return 0 if rows else 2


if __name__ == "__main__":
    raise SystemExit(main())
