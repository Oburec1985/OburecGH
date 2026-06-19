# -*- coding: utf-8 -*-
"""Fix CP1251 mojibake in uTagSettingsDialog UI string literals."""
from __future__ import annotations

import re
from pathlib import Path

path = Path(__file__).resolve().parents[1] / 'UI' / 'uTagSettingsDialog.pas'
text = path.read_text(encoding='utf-8')

string_re = re.compile(r"'((?:''|[^'])*)'")


def try_fix_mojibake(value: str) -> str:
    if 'Р' not in value:
        return value
    try:
        candidate = value.encode('cp1251').decode('utf-8')
    except UnicodeError:
        return value
    if candidate == value:
        return value
    # Accept fix when mojibake markers disappear and Cyrillic remains.
    if any(marker in candidate for marker in ('РЎ', 'Рџ', 'Рњ', 'пїЅ')):
        return value
    if sum(1 for ch in candidate if '\u0400' <= ch <= '\u04FF') == 0:
        return value
    return candidate


def fix_line(line: str) -> str:
    def repl(match: re.Match[str]) -> str:
        raw = match.group(1).replace("''", "'")
        fixed = try_fix_mojibake(raw)
        escaped = fixed.replace("'", "''")
        return f"'{escaped}'"

    return string_re.sub(repl, line)


lines = [fix_line(line) for line in text.splitlines()]
path.write_bytes('\n'.join(lines).replace('\n', '\r\n').encode('utf-8'))

fixed_count = sum(
    1 for old, new in zip(text.splitlines(), lines, strict=False)
    if old != new
)
print(f'fixed lines: {fixed_count}')
print('written', path)
