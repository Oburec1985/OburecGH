#!/usr/bin/env python3
"""Compare two MIC-185 captures and decode Mebius/IOCTL lifecycle."""

from __future__ import annotations

import argparse
import csv
import hashlib
import statistics
import struct
from collections import Counter
from pathlib import Path

SIGS = {0xA0A0CAFE, 0xA0A0CAFF}
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


def args_parse() -> argparse.Namespace:
    p = argparse.ArgumentParser()
    p.add_argument("--reference", required=True, type=Path)
    p.add_argument("--actual", required=True, type=Path)
    p.add_argument("--out", required=True, type=Path)
    return p.parse_args()


def load(path: Path) -> list[dict[str, str]]:
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def raw(row: dict[str, str]) -> bytes:
    return bytes.fromhex(row["payload_hex"]) if row["payload_hex"] else b""


def decode(row: dict[str, str]) -> tuple[str, str]:
    data = raw(row)
    if not data:
        flags = row.get("flags", "")
        if "SYN" in flags:
            return "connect", ""
        if "FIN" in flags or "RST" in flags:
            return "disconnect", ""
        return "tcp_control", ""
    if len(data) < 20:
        return "fragment", ""
    signature, _size, _to, sender, _crc = struct.unpack_from("<IIIII", data)
    if signature not in SIGS:
        return "continuation", ""
    if sender == DATA_TASK:
        return "measurement_data", ""
    if len(data) >= 28 and struct.unpack_from("<H", data, 20)[0] == 0xF10C:
        code = struct.unpack_from("<I", data, 24)[0]
        name = IOCTLS.get(code, f"ioctl_{code:08X}")
        stage = {
            "start": "start", "stop": "stop",
            "program_device_bin": "init_config", "program": "init_config",
            "set_session": "init_config", "query_session": "service",
            "call_command": "service",
        }.get(name, "service")
        return stage, name
    return "mebius_packet", ""


def commands(rows: list[dict[str, str]]) -> list[tuple[dict[str, str], str]]:
    result = []
    for row in rows:
        stage, name = decode(row)
        if row["direction"] == "PC->DEV" and name:
            result.append((row, name))
    return result


def data_rows(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    return [row for row in rows if decode(row)[0] == "measurement_data"]


def median_period(rows: list[dict[str, str]]) -> float:
    times = [float(row["relative_ms"]) for row in rows]
    delta = [times[i] - times[i - 1] for i in range(1, len(times))]
    return statistics.median(delta) if delta else 0.0


def digest(row: dict[str, str]) -> str:
    return hashlib.sha256(raw(row)).hexdigest()[:16]


def add_commands(lines: list[str], title: str, rows: list[dict[str, str]]) -> None:
    lines.extend([f"### {title}", "", "| # | ms | command | bytes | SHA-256 |", "| ---: | ---: | --- | ---: | --- |"])
    for index, (row, name) in enumerate(commands(rows), 1):
        lines.append(f"| {index} | {float(row['relative_ms']):.3f} | {name} | {row['tcp_payload_len']} | `{digest(row)}` |")
    lines.append("")


def main() -> int:
    args = args_parse()
    ref, act = load(args.reference), load(args.actual)
    ref_cmd, act_cmd = commands(ref), commands(act)
    ref_data, act_data = data_rows(ref), data_rows(act)
    prefix = 0
    for (left, _), (right, _) in zip(ref_cmd, act_cmd):
        if raw(left) != raw(right):
            break
        prefix += 1
    ref_stage = Counter(decode(row)[0] for row in ref)
    act_stage = Counter(decode(row)[0] for row in act)
    stages = sorted(set(ref_stage) | set(act_stage))
    lines = [
        "# MIC-185 traffic comparison", "", f"- Reference: `{args.reference.name}`",
        f"- Actual: `{args.actual.name}`", "", "## Summary", "",
        "| Metric | Reference | Actual |", "| --- | ---: | ---: |",
        f"| TCP packets | {len(ref)} | {len(act)} |",
        f"| PC->DEV IOCTL commands | {len(ref_cmd)} | {len(act_cmd)} |",
        f"| Measurement packets | {len(ref_data)} | {len(act_data)} |",
        f"| Median data interval, ms | {median_period(ref_data):.3f} | {median_period(act_data):.3f} |",
        f"| Identical outgoing prefix | {prefix} | {prefix} |", "",
        "## Lifecycle stages", "", "| Stage | Reference | Actual |", "| --- | ---: | ---: |",
    ]
    lines.extend(f"| {stage} | {ref_stage[stage]} | {act_stage[stage]} |" for stage in stages)
    lines.append("")
    add_commands(lines, "Original/reference", ref)
    add_commands(lines, "RecorderLnx/actual", act)
    if prefix < min(len(ref_cmd), len(act_cmd)):
        left, lname = ref_cmd[prefix]
        right, rname = act_cmd[prefix]
        lines.extend(["## First outgoing difference", "", f"- Command: {prefix + 1}",
                      f"- Reference: `{lname}`, {left['tcp_payload_len']} bytes, `{digest(left)}`",
                      f"- Actual: `{rname}`, {right['tcp_payload_len']} bytes, `{digest(right)}`", ""])
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(lines), encoding="utf-8")
    print(f"REPORT={args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
