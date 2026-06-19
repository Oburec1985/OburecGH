# -*- coding: utf-8 -*-
"""Safe read/write helpers for Lazarus .pas files with Russian text (UTF-8, CRLF, no BOM)."""
from __future__ import annotations

from pathlib import Path

# Mojibake / corruption markers checked after edits (see verify_russian_comments.py).
MOJIBAKE_MARKERS = (
    "РЎ", "Рџ", "Рњ", "Рќ", "Р°", "Р±", "РІ", "пїЅ", "\ufffd",
)
QUESTION_RUN_RE = r"\?{3,}"


def normalize_newlines(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def read_pas(path: Path) -> str:
    """Read .pas as UTF-8; fall back to CP1251 only for legacy blobs."""
    raw = path.read_bytes()
    for enc in ("utf-8", "cp1251"):
        try:
            return normalize_newlines(raw.decode(enc))
        except UnicodeDecodeError:
            continue
    return normalize_newlines(raw.decode("latin-1"))


def write_utf8_crlf(path: Path, text: str) -> None:
    """Write UTF-8 + CRLF, no BOM. Only approved writer for .pas with Cyrillic."""
    path.write_bytes(normalize_newlines(text).replace("\n", "\r\n").encode("utf-8"))


def fix_cp1251_mojibake(text: str, rounds: int = 3) -> str:
    """Undo UTF-8-read-as-CP1251 mojibake (РќР°… -> Настройка)."""
    for _ in range(rounds):
        try:
            candidate = text.encode("cp1251").decode("utf-8")
        except UnicodeError:
            break
        if candidate == text:
            break
        text = candidate
    return text


def collapse_double_spacing(text: str) -> str:
    """Remove 'every line followed by blank line' pattern; keep at most one blank line."""
    lines = [line.rstrip() for line in text.split("\n")]
    non_empty = sum(1 for line in lines if line.strip())
    followed = sum(
        1
        for i in range(len(lines) - 1)
        if lines[i].strip() and not lines[i + 1].strip()
    )
    if non_empty and followed / non_empty > 0.7:
        cleaned: list[str] = []
        i = 0
        while i < len(lines):
            line = lines[i]
            cleaned.append(line)
            if line.strip() and i + 1 < len(lines) and not lines[i + 1].strip():
                i += 2
                continue
            i += 1
        lines = cleaned

    final: list[str] = []
    prev_empty = False
    for line in lines:
        if not line.strip():
            if not prev_empty:
                final.append("")
            prev_empty = True
        else:
            final.append(line)
            prev_empty = False
    return "\n".join(final)


def has_cyrillic(text: str) -> bool:
    return any("\u0400" <= ch <= "\u04FF" for ch in text)


def count_corruption(text: str) -> dict[str, int]:
    import re

    counts: dict[str, int] = {"???": text.count("???")}
    counts["U+FFFD"] = text.count("\ufffd")
    counts["0x98"] = text.count("\x98")
    for m in MOJIBAKE_MARKERS:
        if m in text:
            counts[f"mojibake:{m}"] = text.count(m)
    counts["question_runs"] = len(re.findall(QUESTION_RUN_RE, text))
    return {k: v for k, v in counts.items() if v > 0}
