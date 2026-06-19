#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fix mojibake inside Pascal string literals ('РќР°…' -> 'На…'). UTF-8 safe."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import fix_cp1251_mojibake, read_pas, write_utf8_crlf

STRING_RE = re.compile(r"'((?:''|[^'])*)'")


def try_fix_literal(value: str) -> str:
    if "Р" not in value and "пї" not in value:
        return value
    fixed = fix_cp1251_mojibake(value, rounds=3)
    if any(m in fixed for m in ("РЎ", "Рџ", "Рњ", "пїЅ")):
        return value
    if sum(1 for ch in fixed if "\u0400" <= ch <= "\u04FF") == 0:
        return value
    return fixed


def fix_line(line: str) -> str:
    def repl(match: re.Match[str]) -> str:
        raw = match.group(1).replace("''", "'")
        fixed = try_fix_literal(raw)
        return "'" + fixed.replace("'", "''") + "'"

    return STRING_RE.sub(repl, line)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    for raw in args.files:
        path = Path(raw)
        lines = read_pas(path).split("\n")
        out = [fix_line(line) for line in lines]
        text = "\n".join(out)
        if args.dry_run:
            print(f"{path.name}: dry-run")
        else:
            write_utf8_crlf(path, text)
            print(f"{path.name}: written")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
