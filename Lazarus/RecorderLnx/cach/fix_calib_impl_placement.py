# -*- coding: utf-8 -*-
"""Move method bodies out of interface sections (calibrate WIP fix)."""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, r"D:\works\OburecGH\Lazarus\Scripts\encoding-safe")
from lib.pas_io import read_pas, write_utf8_crlf  # noqa: E402

ROOT = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx")


def fix_dialog() -> None:
    p = ROOT / "Device/MCbus/UI/uRecorderMc201SlotSettingsDialog.pas"
    t = read_pas(p)
    start = t.find("procedure TRecorderMc201SlotSettingsDialog.CalibrateClick")
    end = t.find("function ShowRecorderMc201SlotSettingsDialog", start)
    if start < 0 or end < 0:
        raise SystemExit(f"dialog markers not found: {start=} {end=}")
    # Already in implementation?
    impl = t.find("\nimplementation\n")
    if impl > 0 and start > impl:
        print("dialog: CalibrateClick already in implementation")
        return
    body = t[start:end].rstrip() + "\n\n"
    t2 = t[:start] + t[end:]
    idx = t2.find("{$R *.lfm}")
    if idx < 0:
        raise SystemExit("{$R *.lfm} missing")
    nl = t2.find("\n", idx) + 1
    while nl < len(t2) and t2[nl] == "\n":
        nl += 1
    t2 = t2[:nl] + body + t2[nl:]
    write_utf8_crlf(p, t2)
    print(f"dialog: moved CalibrateClick ({len(body)} chars)")


def fix_device() -> None:
    p = ROOT / "Device/MCbus/uRecorderMcbusDevice.pas"
    t = read_pas(p)
    start = t.find("function TRecorderMcbusDevice.CalibrateScaleByBalanceDacShift")
    if start < 0:
        raise SystemExit("device: CalibrateScale body not found")
    impl = t.find("\nimplementation\n")
    if impl > 0 and start > impl:
        print("device: CalibrateScale already in implementation")
        return
    end = t.find("function CreateRecorderMcbusDevice: IRecorderDevice;", start)
    if end < 0:
        raise SystemExit("device: end marker not found")
    body = t[start:end].rstrip() + "\n\n"
    t2 = t[:start] + t[end:]
    # Insert after BalanceTrace
    marker = "procedure BalanceTrace(const AText: string);"
    pos = t2.find(marker)
    if pos < 0:
        raise SystemExit("BalanceTrace not found")
    end_proc = t2.find("\nend;\n", pos)
    if end_proc < 0:
        raise SystemExit("BalanceTrace end not found")
    insert_at = end_proc + len("\nend;\n")
    t2 = t2[:insert_at] + "\n" + body + t2[insert_at:]
    write_utf8_crlf(p, t2)
    print(f"device: moved CalibrateScale ({len(body)} chars)")


if __name__ == "__main__":
    fix_dialog()
    fix_device()
