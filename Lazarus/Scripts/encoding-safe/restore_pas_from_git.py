#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Restore .pas from git blob (CP1251) and save as UTF-8 with {$codepage UTF8}."""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import normalize_newlines, write_utf8_crlf

DEFAULT_REPO = Path(r"D:\works\OburecGH")


def load_git_pas(repo: Path, git_path: str, ref: str = "origin/master") -> str:
    raw = subprocess.check_output(
        ["git", "-C", str(repo), "show", f"{ref}:{git_path}"],
    )
    text = normalize_newlines(raw.decode("cp1251"))
    return text.replace("{$codepage cp1251}", "{$codepage UTF8}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Restore .pas comments from git CP1251 blob -> UTF-8 file",
    )
    parser.add_argument("git_path", help="path inside repo, e.g. Lazarus/RecorderLnx/UI/uMainForm.pas")
    parser.add_argument(
        "-o", "--output",
        help="output .pas path (default: repo/Lazarus/... from git_path)",
    )
    parser.add_argument("--repo", type=Path, default=DEFAULT_REPO)
    parser.add_argument("--ref", default="origin/master")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    out_path = Path(args.output) if args.output else args.repo / args.git_path
    text = load_git_pas(args.repo, args.git_path, ref=args.ref)

    if "???" in text:
        print(f"Warning: git blob still has ??? — pick another ref", file=sys.stderr)

    if args.dry_run:
        print(f"Would write {out_path} ({len(text.splitlines())} lines)")
        return 0

    write_utf8_crlf(out_path, text)
    print(f"OK: {out_path} from {args.ref}:{args.git_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
