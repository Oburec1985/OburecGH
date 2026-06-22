#!/usr/bin/env python3
"""Fix UTF-8 mojibake in uRecorderOscillogramSettingsDialog.pas (and similar modules).

Проверено 2026-06. Симптом: в {$codepage UTF8} файле литералы вида
'РќР°СЃС‚СЂРѕР№РєР°' вместо 'Настройка'. См. Docs/source-encoding.md.
"""
from __future__ import annotations

import re
from pathlib import Path

TARGET = Path(__file__).resolve().parents[1] / "UI" / "uRecorderOscillogramSettingsDialog.pas"

GOOD_HEADER = """  Supports one primary tag plus additional synchronized lines from the same device.
  Кодировка (2026-06):
    Файл в UTF-8, {$codepage UTF8}. Строки для LCL — обычные string-литералы.
    См. Docs/source-encoding.md.
"""


def fix_mojibake(text: str) -> str:
    return text.encode("cp1251").decode("utf-8")


def main() -> None:
    raw = TARGET.read_text(encoding="utf-8")
    if "???" in raw:
        raise SystemExit("Refusing: contains ???")

    # Header block
    raw = re.sub(
        r"  Supports one primary tag plus additional synchronized lines from the same device\.\n"
        r"  Р.*?См\. Docs/source-encoding\.md\.\n",
        GOOD_HEADER,
        raw,
        flags=re.DOTALL,
    )

    def repl(m: re.Match[str]) -> str:
        inner = m.group(1).replace("''", "\x00").replace("\x00", "''")
        if "Р" not in inner:
            return m.group(0)
        try:
            fixed = fix_mojibake(inner.replace("''", "'"))
        except UnicodeError:
            return m.group(0)
        if fixed == inner.replace("''", "'"):
            return m.group(0)
        return "'" + fixed.replace("'", "''") + "'"

    out = re.sub(r"'((?:[^']|'')*)'", repl, raw)

    TARGET.write_bytes(out.replace("\n", "\r\n").encode("utf-8"))
    print("OK:", TARGET)


if __name__ == "__main__":
    main()
