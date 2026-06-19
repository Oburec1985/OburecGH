#!/usr/bin/env python3
"""Merge uRecorderTags: UTF-8 comments from cach backup + code from current file."""
from __future__ import annotations

import re
from pathlib import Path

CORE = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx\Core/uRecorderTags.pas")
BACKUP = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx\cach/uRecorderTags_utf8.pas")


def nl(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n").lstrip("\ufeff")


def to_crlf(text: str) -> bytes:
    return nl(text).replace("\n", "\r\n").encode("utf-8")


def ascii_key(line: str) -> str:
    return re.sub(r"[^\x20-\x7e]", "", line)


def repair_from_backup(current: str, backup: str) -> str:
    bmap: dict[str, list[str]] = {}
    for line in backup.split("\n"):
        key = ascii_key(line)
        if key.strip():
            bmap.setdefault(key, []).append(line)

    out: list[str] = []
    for line in current.split("\n"):
        if "пїЅ" not in line and "\ufffd" not in line:
            out.append(line)
            continue
        key = ascii_key(re.sub(r"[пїЅ\ufffd]+", "", line))
        if key in bmap:
            out.append(min(bmap[key], key=lambda g: abs(len(g) - len(line))))
        else:
            out.append(line)
    return "\n".join(out)


def main() -> None:
    backup = nl(BACKUP.read_text(encoding="utf-8"))
    current = nl(CORE.read_text(encoding="utf-8"))

    merged = repair_from_backup(current, backup)
    bad = merged.count("пїЅ") + merged.count("\ufffd") + len(re.findall(r"\?{3,}", merged))
    if bad:
        # fallback: backup + tail code blocks present only in current
        backup_lines = backup.split("\n")
        current_lines = current.split("\n")
        backup_keys = {ascii_key(x) for x in backup_lines}
        extra = [ln for ln in current_lines if ascii_key(ln) and ascii_key(ln) not in backup_keys and "пїЅ" not in ln]
        if extra:
            merged = backup + "\n\n{ merged additions from current }\n" + "\n".join(extra[:20])
        raise SystemExit(f"still bad chars: {bad}")

    if "{$codepage UTF8}" not in merged:
        merged = merged.replace("{$mode objfpc}{$H+}", "{$mode objfpc}{$H+}\n{$codepage UTF8}", 1)

    CORE.write_bytes(to_crlf(merged))
    cyr = sum(1 for c in merged if "\u0400" <= c <= "\u04FF")
    print(f"OK uRecorderTags.pas cyrillic={cyr}")


if __name__ == "__main__":
    main()
