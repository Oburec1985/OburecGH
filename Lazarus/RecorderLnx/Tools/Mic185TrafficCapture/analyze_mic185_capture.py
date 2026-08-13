#!/usr/bin/env python3
"""Reassemble TCP and decode MIC-185 Mebius lifecycle without manual marks."""

from __future__ import annotations

import argparse
import csv
import hashlib
import struct
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path

SIGS = {0xA0A0CAFE, 0xA0A0CAFF}
MEAS_TASK = 0x0C904000
DATA_TASK = 0x0CA04000
IOCTLS = {
    0x00010000: "null",
    0x00010004: "query_session",
    0x00010024: "set_session",
    0x00010028: "program_device_bin",
    0x0001002C: "start",
    0x00010030: "stop",
    0x00010034: "call_command",
    0x00010040: "program",
}


@dataclass
class Chunk:
    seq: int
    time_ms: float
    data: bytes


def args_parse() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--packets", required=True, type=Path)
    p.add_argument("--events", required=True, type=Path)
    p.add_argument("--report", required=True, type=Path)
    return p.parse_args()


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def conn_key(row: dict[str, str]) -> tuple[str, int, str, int]:
    if row["direction"] == "PC->DEV":
        return row["src_ip"], int(row["src_port"]), row["dst_ip"], int(row["dst_port"])
    return row["dst_ip"], int(row["dst_port"]), row["src_ip"], int(row["src_port"])


def payload(row: dict[str, str]) -> bytes:
    return bytes.fromhex(row["payload_hex"]) if row["payload_hex"] else b""


def join_chunks(chunks: list[Chunk]) -> tuple[bytes, list[tuple[int, float]], int, int]:
    if not chunks:
        return b"", [], 0, 0
    chunks.sort(key=lambda item: (item.seq, item.time_ms))
    out = bytearray()
    marks: list[tuple[int, float]] = []
    expected = chunks[0].seq
    retransmits = gaps = 0
    for chunk in chunks:
        data = chunk.data
        if chunk.seq < expected:
            overlap = expected - chunk.seq
            if overlap >= len(data):
                retransmits += 1
                continue
            retransmits += 1
            data = data[overlap:]
        elif chunk.seq > expected:
            gaps += 1
            # A gap makes the previous tail unusable for framing. Insert a marker
            # that cannot be mistaken for a Mebius signature and continue scanning.
            out.extend(b"\x00" * min(chunk.seq - expected, 20))
        marks.append((len(out), chunk.time_ms))
        out.extend(data)
        expected = chunk.seq + len(chunk.data)
    return bytes(out), marks, retransmits, gaps


def time_at(marks: list[tuple[int, float]], offset: int) -> float:
    value = 0.0
    for mark_offset, mark_time in marks:
        if mark_offset > offset:
            break
        value = mark_time
    return value


def packet_size(data: bytes, offset: int) -> int:
    if offset + 20 > len(data):
        return 0
    size = struct.unpack_from("<I", data, offset + 4)[0]
    if 20 <= size <= 4 * 1024 * 1024:
        return size
    legacy = size & 0xFFFF
    return legacy if 20 <= legacy <= 4 * 1024 * 1024 else -1


def classify(direction: str, packet: bytes) -> tuple[str, str, str]:
    _sig, _size, id_to, id_from, _crc = struct.unpack_from("<IIIII", packet)
    body = packet[20:]
    if id_from == DATA_TASK:
        dev_id = struct.unpack_from("<I", body)[0] if len(body) >= 4 else -1
        kind = {0: "uts_data", 1: "measurement_data", 2: "temperature_data"}.get(dev_id, "device_data")
        return kind, "", f"dev_id={dev_id}"
    if len(body) >= 8 and struct.unpack_from("<H", body)[0] == 0xF10C:
        code = struct.unpack_from("<I", body, 4)[0]
        name = IOCTLS.get(code, f"ioctl_{code:08X}")
        event = {
            "set_session": "init",
            "program_device_bin": "configure",
            "program": "configure_apply",
            "start": "start",
            "stop": "stop",
            "query_session": "alive_request",
            "call_command": "service",
        }.get(name, "service")
        if direction == "DEV->PC" and event == "alive_request":
            event = "alive_response"
        elif direction == "DEV->PC":
            event += "_reply"
        return event, name, f"to={id_to:08X};from={id_from:08X}"
    return "mebius_service", "", f"to={id_to:08X};from={id_from:08X}"


def scan_stream(connection: int, direction: str, data: bytes,
                marks: list[tuple[int, float]]) -> tuple[list[dict[str, object]], int, int]:
    events: list[dict[str, object]] = []
    offset = skipped = incomplete = 0
    while offset + 4 <= len(data):
        signature = struct.unpack_from("<I", data, offset)[0]
        if signature not in SIGS:
            offset += 1
            skipped += 1
            continue
        size = packet_size(data, offset)
        if size < 0:
            offset += 1
            skipped += 1
            continue
        if size == 0 or offset + size > len(data):
            incomplete += 1
            break
        packet = data[offset:offset + size]
        event, ioctl, detail = classify(direction, packet)
        _sig, _size, id_to, id_from, _crc = struct.unpack_from("<IIIII", packet)
        events.append({
            "connection": connection,
            "relative_ms": round(time_at(marks, offset), 3),
            "direction": direction,
            "event": event,
            "ioctl": ioctl,
            "packet_size": size,
            "id_to": f"{id_to:08X}",
            "id_from": f"{id_from:08X}",
            "sha256": hashlib.sha256(packet).hexdigest()[:16],
            "detail": detail,
        })
        offset += size
    return events, skipped, incomplete


def tcp_keepalives(rows: list[dict[str, str]],
                   key_index: dict[tuple[str, int, str, int], int]) -> list[dict[str, object]]:
    """Find TCP probes by the standard SND.NXT-1 sequence-number pattern."""
    next_seq: dict[tuple[tuple[str, int, str, int], str], int] = {}
    events: list[dict[str, object]] = []
    for row in rows:
        key = conn_key(row)
        direction = row["direction"]
        state_key = key, direction
        seq = int(row["seq"])
        data_len = int(row["tcp_payload_len"])
        flags = row.get("flags", "")
        expected = next_seq.get(state_key)
        if (expected is not None and data_len == 0 and flags == "ACK"
                and seq == expected - 1):
            events.append({
                "connection": key_index[key],
                "relative_ms": float(row["relative_ms"]),
                "direction": direction,
                "event": "tcp_keepalive_probe",
                "ioctl": "",
                "packet_size": 0,
                "id_to": "",
                "id_from": "",
                "sha256": "",
                "detail": "TCP probe: seq=SND.NXT-1",
            })
        consumed = data_len + int("SYN" in flags) + int("FIN" in flags)
        if consumed:
            next_seq[state_key] = max(expected or 0, seq + consumed)
    return events


def main() -> int:
    args = args_parse()
    rows = read_rows(args.packets)
    grouped: dict[tuple[str, int, str, int], dict[str, list[Chunk]]] = defaultdict(lambda: defaultdict(list))
    first_time: dict[tuple[str, int, str, int], float] = {}
    tcp_events: list[dict[str, object]] = []
    for row in rows:
        key = conn_key(row)
        first_time.setdefault(key, float(row["relative_ms"]))
        flags = row.get("flags", "")
        if "SYN" in flags and row["direction"] == "PC->DEV":
            tcp_events.append({"key": key, "time": float(row["relative_ms"]), "event": "connect"})
        if "FIN" in flags or "RST" in flags:
            tcp_events.append({"key": key, "time": float(row["relative_ms"]), "event": "disconnect"})
        data = payload(row)
        if data:
            grouped[key][row["direction"]].append(Chunk(int(row["seq"]), float(row["relative_ms"]), data))

    keys = sorted(set(grouped) | set(first_time), key=lambda key: first_time.get(key, 0.0))
    key_index = {key: index + 1 for index, key in enumerate(keys)}
    events: list[dict[str, object]] = []
    stats: list[tuple[int, str, int, int, int, int]] = []
    for item in tcp_events:
        events.append({"connection": key_index[item["key"]], "relative_ms": item["time"],
                       "direction": "TCP", "event": item["event"], "ioctl": "",
                       "packet_size": 0, "id_to": "", "id_from": "", "sha256": "", "detail": ""})
    events.extend(tcp_keepalives(rows, key_index))
    for key in keys:
        for direction in ("PC->DEV", "DEV->PC"):
            stream, marks, retransmits, gaps = join_chunks(grouped[key][direction])
            decoded, skipped, incomplete = scan_stream(key_index[key], direction, stream, marks)
            events.extend(decoded)
            stats.append((key_index[key], direction, len(stream), retransmits, gaps, skipped + incomplete))
    events.sort(key=lambda event: (float(event["relative_ms"]), int(event["connection"])))

    # Infer reset/reconnect: a new initialized connection after a prior disconnect.
    disconnected = False
    for event in events:
        if event["event"] == "disconnect":
            disconnected = True
        elif disconnected and event["event"] == "init" and event["direction"] == "PC->DEV":
            event["event"] = "reset_reconnect_init"
            disconnected = False

    fields = ["connection", "relative_ms", "direction", "event", "ioctl", "packet_size",
              "id_to", "id_from", "sha256", "detail"]
    args.events.parent.mkdir(parents=True, exist_ok=True)
    with args.events.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(events)

    counts = Counter(str(event["event"]) for event in events)
    app_alive = counts["alive_request"] + counts["alive_response"]
    tcp_alive = counts["tcp_keepalive_probe"]
    lines = ["# MIC-185 automatically decoded lifecycle", "", f"- Source: `{args.packets.name}`",
             f"- TCP connections: {len(keys)}", f"- Decoded events: {len(events)}", "",
             "## Alive / keep-alive", "",
             f"- Mebius `query_session`: {app_alive} events "
             f"({counts['alive_request']} requests, {counts['alive_response']} responses).",
             f"- TCP keep-alive probes: {tcp_alive}.",
             "- TCP probes are recognized only by `SEQ = SND.NXT - 1`; ordinary ACK packets are not counted.",
             "- An empty section is normal when traffic is continuous or the capture is shorter than the alive timeout.", "",
             "## Lifecycle counts", "", "| Event | Count |", "| --- | ---: |"]
    lines.extend(f"| {name} | {count} |" for name, count in sorted(counts.items()))
    lines.extend(["", "## TCP reassembly", "", "| Connection | Direction | Bytes | Retransmits | Gaps | Unframed/incomplete |",
                  "| ---: | --- | ---: | ---: | ---: | ---: |"])
    lines.extend(f"| {conn} | {direction} | {size} | {retry} | {gaps} | {bad} |"
                 for conn, direction, size, retry, gaps, bad in stats)
    lines.extend(["", "## Ordered lifecycle", "", "| ms | Conn | Direction | Event | IOCTL | Bytes |",
                  "| ---: | ---: | --- | --- | --- | ---: |"])
    for event in events:
        if event["event"] not in {"measurement_data", "temperature_data", "uts_data"}:
            lines.append(f"| {float(event['relative_ms']):.3f} | {event['connection']} | {event['direction']} | "
                         f"{event['event']} | {event['ioctl']} | {event['packet_size']} |")
    args.report.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"EVENTS={args.events}")
    print(f"REPORT={args.report}")
    print(f"CONNECTIONS={len(keys)}")
    print(f"DECODED={len(events)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
