#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Convert module: {$codepage cp1251} + CP1251ToUTF8(...) -> {$codepage UTF8} literals."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import read_pas, write_utf8_crlf

WRAP_RE = re.compile(r"CP1251ToUTF8\(\s*'((?:[^']|'')*)'\s*\)", re.DOTALL)


def unwrap(text: str) -> str:
    prev = None
    while prev != text:
        prev = text
        text = WRAP_RE.sub(r"'\1'", text)
    return text


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help=".pas module to convert")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    path = Path(args.file)
    text = read_pas(path)

    if "???" in text:
        print(f"Refusing: {path} contains ??? — restore from git first", file=sys.stderr)
        return 1

    out = text.replace("{$codepage cp1251}", "{$codepage UTF8}")
    out = out.replace("  LConvEncoding,\n", "")
    out = out.replace(", LConvEncoding", "")
    out = unwrap(out)

    if "CP1251ToUTF8" in out:
        print("Warning: some CP1251ToUTF8() remain", file=sys.stderr)
        return 1

    if args.dry_run:
        print(f"{path.name}: would convert ({len(text)} -> {len(out)} chars)")
        return 0

    write_utf8_crlf(path, out)
    print(f"OK: {path} -> UTF-8, CRLF, " + "{$codepage UTF8}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
