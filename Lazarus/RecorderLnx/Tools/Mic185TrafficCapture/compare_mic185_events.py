#!/usr/bin/env python3
"""Compare automatically decoded MIC-185 lifecycle event files."""

import argparse
import csv
from collections import Counter
from pathlib import Path


def load(path: Path):
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--reference", required=True, type=Path)
    p.add_argument("--actual", required=True, type=Path)
    p.add_argument("--out", required=True, type=Path)
    args = p.parse_args()
    ref, act = load(args.reference), load(args.actual)
    ref_cmd = [r for r in ref if r["direction"] == "PC->DEV" and r["ioctl"]]
    act_cmd = [r for r in act if r["direction"] == "PC->DEV" and r["ioctl"]]
    prefix = 0
    for left, right in zip(ref_cmd, act_cmd):
        if (left["ioctl"], left["packet_size"], left["sha256"]) != (right["ioctl"], right["packet_size"], right["sha256"]):
            break
        prefix += 1
    ref_count, act_count = Counter(r["event"] for r in ref), Counter(r["event"] for r in act)
    stages = sorted(set(ref_count) | set(act_count))
    lines = ["# MIC-185 decoded lifecycle comparison", "", f"- Reference: `{args.reference.name}`",
             f"- Actual: `{args.actual.name}`", "", "## Summary", "",
             "| Metric | Reference | Actual |", "| --- | ---: | ---: |",
             f"| Events | {len(ref)} | {len(act)} |", f"| Outgoing commands | {len(ref_cmd)} | {len(act_cmd)} |",
             f"| Identical command prefix | {prefix} | {prefix} |", "", "## Stages", "",
             "| Event | Reference | Actual |", "| --- | ---: | ---: |"]
    lines.extend(f"| {stage} | {ref_count[stage]} | {act_count[stage]} |" for stage in stages)
    lines.extend(["", "## Outgoing command order", "", "| # | Reference | Actual |", "| ---: | --- | --- |"])
    for index in range(max(len(ref_cmd), len(act_cmd))):
        left = ref_cmd[index] if index < len(ref_cmd) else None
        right = act_cmd[index] if index < len(act_cmd) else None
        ltext = f"{left['ioctl']} / {left['packet_size']} / {left['sha256']}" if left else "-"
        rtext = f"{right['ioctl']} / {right['packet_size']} / {right['sha256']}" if right else "-"
        lines.append(f"| {index + 1} | `{ltext}` | `{rtext}` |")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"REPORT={args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
