# -*- coding: utf-8 -*-
from __future__ import annotations

import re
from pathlib import Path


def fix_cp1251_mojibake(text: str, rounds: int = 2) -> str:
    for _ in range(rounds):
        try:
            candidate = text.encode('cp1251').decode('utf-8')
        except UnicodeError:
            break
        if candidate == text:
            break
        text = candidate
    return text


def fix_string_literals(text: str) -> str:
    string_re = re.compile(r"'((?:''|[^'])*)'")

    def repl(match: re.Match[str]) -> str:
        raw = match.group(1).replace("''", "'")
        if 'Р' not in raw:
            return match.group(0)
        try:
            fixed = raw.encode('cp1251').decode('utf-8')
        except UnicodeError:
            return match.group(0)
        if any(marker in fixed for marker in ('РЎ', 'Рџ', 'Рњ', 'пїЅ')):
            return match.group(0)
        return "'" + fixed.replace("'", "''") + "'"

    return string_re.sub(repl, text)


def write_utf8_crlf(path: Path, text: str) -> None:
    path.write_bytes(text.replace('\n', '\r\n').encode('utf-8'))


def fix_file(path: Path, whole_file: bool = False) -> None:
    text = path.read_text(encoding='utf-8')
    if whole_file:
        text = fix_cp1251_mojibake(text)
    else:
        text = fix_string_literals(text)
    write_utf8_crlf(path, text)
    print('fixed', path.name)


if __name__ == '__main__':
    chart = Path(__file__).resolve().parents[2] / 'SharedUtils' / 'components' / 'chart_lzr'
    ui = Path(__file__).resolve().parents[1] / 'UI'
    fix_file(chart / 'uOglChartColors.pas', whole_file=False)
    fix_file(ui / 'uTagSettingsDialog.pas', whole_file=False)
    # header comment block in TagSettingsDialog
    path = ui / 'uTagSettingsDialog.pas'
    text = path.read_text(encoding='utf-8')
    header_old_start = text.find('{\n  ')
    if header_old_start >= 0 and 'uTagSettingsDialog' in text[header_old_start:header_old_start + 200]:
        header_end = text.find('}\n\n{$mode', header_old_start)
        if header_end > header_old_start:
            header = text[header_old_start:header_end + 1]
            fixed_header = fix_cp1251_mojibake(header)
            text = text[:header_old_start] + fixed_header + text[header_end + 1:]
            write_utf8_crlf(path, text)
            print('fixed header', path.name)
