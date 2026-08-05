#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Remove double blank lines in .pas (UTF-8 safe). Does not change string content."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import collapse_double_spacing, read_pas, write_utf8_crlf


def main() -> int:
    parser = argparse.ArgumentParser(description="Collapse double spacing in .pas files")
    parser.add_argument("files", nargs="+", help=".pas files to fix")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    for raw in args.files:
        path = Path(raw)
        before = read_pas(path)
        after = collapse_double_spacing(before)
        if before == after:
            print(f"{path.name}: unchanged")
            continue
        print(f"{path.name}: {len(before.splitlines())} -> {len(after.splitlines())} lines")
        if not args.dry_run:
            write_utf8_crlf(path, after)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
