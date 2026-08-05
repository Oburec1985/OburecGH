#!/usr/bin/env python3
"""Convert uRecorderOscillogramSettingsDialog.pas to UTF-8 + {$codepage UTF8}.

Problem: file saved as UTF-8 but marked cp1251 with CP1251ToUTF8() wrappers
shows mojibake in LCL (UTF-8 bytes interpreted as CP1251, then double-converted).

See Docs/source-encoding.md, marker RLNX_SOURCE_ENCODING_2026_06.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "UI" / "uRecorderOscillogramSettingsDialog.pas"

ENCODING_NOTE = """
  Кодировка (2026-06):
    Файл в UTF-8, {$codepage UTF8}. Строки для LCL — обычные string-литералы.
    См. Docs/source-encoding.md.
"""


def unwrap_cp1251_to_utf8(text: str) -> str:
    pattern = re.compile(
        r"CP1251ToUTF8\(\s*'((?:[^']|'')*)'\s*\)",
        re.DOTALL,
    )
    prev = None
    while prev != text:
        prev = text
        text = pattern.sub(r"'\1'", text)
    return text


def main() -> None:
    raw = TARGET.read_text(encoding="utf-8")
    if "???" in raw:
        raise SystemExit(f"Refusing: {TARGET} contains ??? — restore from git first")

    out = raw.replace("{$codepage cp1251}", "{$codepage UTF8}")
    out = out.replace("  LConvEncoding,\n", "")
    out = unwrap_cp1251_to_utf8(out)

    if "CP1251ToUTF8" in out:
        raise SystemExit("Some CP1251ToUTF8() calls remain — check regex")

    if "Кодировка (2026-06):" not in out:
        out = out.replace(
            "  Supports one primary tag plus additional synchronized lines from the same device.\n}",
            "  Supports one primary tag plus additional synchronized lines from the same device."
            + ENCODING_NOTE
            + "}",
        )

    TARGET.write_bytes(out.replace("\n", "\r\n").encode("utf-8"))
    print(f"OK: {TARGET} -> UTF-8, CRLF, no BOM")


if __name__ == "__main__":
    main()
