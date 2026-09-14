#!/usr/bin/env python3
"""Place RecorderHostAgent beside the matching RecorderLnx build."""

import argparse
import shutil
from pathlib import Path


def copy_checked(source: Path, target: Path, signature: bytes) -> None:
    if not source.is_file():
        raise SystemExit(f"Host agent build is missing: {source}")
    if not source.read_bytes()[: len(signature)] == signature:
        raise SystemExit(f"Unexpected executable format: {source}")
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
    print(f"RecorderHostAgent synchronized: {source} -> {target}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--platform", choices=("win64", "linux", "all"), default="all")
    args = parser.parse_args()

    agent_root = Path(__file__).resolve().parents[1]
    lazarus_root = agent_root.parent
    recorder_root = lazarus_root / "RecorderLnx"

    if args.platform in ("win64", "all"):
        copy_checked(
            agent_root / "lib" / "x86_64-win64" / "RecorderHostAgent.exe",
            recorder_root / "lib" / "x86_64-win64" / "RecorderHostAgent.exe",
            b"MZ",
        )
    if args.platform in ("linux", "all"):
        copy_checked(
            agent_root / "lib" / "x86_64-linux" / "RecorderHostAgent",
            recorder_root / "lib" / "x86_64-linux" / "RecorderHostAgent",
            b"\x7fELF",
        )


if __name__ == "__main__":
    main()
