#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Verify .pas files after bulk edits: Russian comments/strings not corrupted.

Exit 0 = OK, 1 = issues found, 2 = usage error.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import count_corruption, has_cyrillic, read_pas


def scan_file(path: Path) -> list[str]:
    issues: list[str] = []
    try:
        text = read_pas(path)
    except OSError as exc:
        return [f"{path}: read error: {exc}"]

    if not has_cyrillic(text) and "???" not in text and "\ufffd" not in text:
        return []

    for label, count in count_corruption(text).items():
        issues.append(f"{path}: {label} x{count}")

    if "{$codepage cp1251}" in text[:500] and has_cyrillic(text):
        sample = text[:2000]
        if any(ord(c) > 127 for c in sample):
            issues.append(
                f"{path}: " + "{$codepage cp1251}" + " but file contains non-ASCII — "
                "likely UTF-8/cp1251 mismatch (see Docs/source-encoding.md)"
            )

    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description="Check .pas for encoding corruption")
    parser.add_argument(
        "paths",
        nargs="+",
        help=".pas files or directories to scan recursively",
    )
    args = parser.parse_args()

    files: list[Path] = []
    for raw in args.paths:
        p = Path(raw)
        if p.is_dir():
            files.extend(sorted(p.rglob("*.pas")))
        elif p.is_file():
            files.append(p)
        else:
            print(f"skip (not found): {p}", file=sys.stderr)

    if not files:
        print("No .pas files to scan", file=sys.stderr)
        return 2

    all_issues: list[str] = []
    for fp in files:
        all_issues.extend(scan_file(fp))

    if all_issues:
        print("ENCODING ISSUES:")
        for item in all_issues:
            print(f"  {item}")
        print(f"\nTotal: {len(all_issues)} issue(s) in {len(files)} file(s)")
        print("Fix with scripts from Scripts/encoding-safe/ (see README.md)")
        return 1

    print(f"OK: {len(files)} file(s), no encoding corruption markers")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
