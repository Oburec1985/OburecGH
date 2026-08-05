#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fix CP1251 mojibake (РќР°СЃ… -> Настройка) in UTF-8 .pas files."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import count_corruption, fix_cp1251_mojibake, read_pas, write_utf8_crlf


def main() -> int:
    parser = argparse.ArgumentParser(description="Fix UTF-8/cp1251 mojibake in .pas")
    parser.add_argument("files", nargs="+")
    parser.add_argument("--rounds", type=int, default=3)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    exit_code = 0
    for raw in args.files:
        path = Path(raw)
        before = read_pas(path)
        after = fix_cp1251_mojibake(before, rounds=args.rounds)
        bad_before = count_corruption(before)
        bad_after = count_corruption(after)
        print(f"{path.name}: before={bad_before or '{}'} after={bad_after or '{}'}")
        if before != after and not args.dry_run:
            write_utf8_crlf(path, after)
        if bad_after:
            exit_code = 1
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
