#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fix mojibake + double spacing (batch chart/math units). UTF-8 safe."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import (
    collapse_double_spacing,
    count_corruption,
    fix_cp1251_mojibake,
    read_pas,
    write_utf8_crlf,
)


def fix_file(path: Path, rounds: int = 3) -> None:
    text = fix_cp1251_mojibake(read_pas(path), rounds=rounds)
    text = collapse_double_spacing(text)
    write_utf8_crlf(path, text)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")
    parser.add_argument("--rounds", type=int, default=3)
    args = parser.parse_args()

    exit_code = 0
    for raw in args.files:
        path = Path(raw)
        fix_file(path, rounds=args.rounds)
        bad = count_corruption(read_pas(path))
        print(f"{path.name}: {bad or 'OK'}")
        if bad:
            exit_code = 1
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
