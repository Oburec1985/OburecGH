# -*- coding: utf-8 -*-
"""Fix mojibake comments and double spacing in chart/math units."""
from __future__ import annotations

from pathlib import Path


def read_text(path: Path) -> str:
    return path.read_bytes().decode('utf-8', errors='replace').replace('\r\n', '\n').replace('\r', '\n')


def write_utf8_crlf(path: Path, text: str) -> None:
    path.write_bytes(text.replace('\n', '\r\n').encode('utf-8'))


def fix_cp1251_mojibake(text: str, rounds: int = 3) -> str:
    for _ in range(rounds):
        try:
            candidate = text.encode('cp1251').decode('utf-8')
        except UnicodeError:
            break
        if candidate == text:
            break
        text = candidate
    return text


def collapse_double_spacing(text: str) -> str:
    lines = [line.rstrip() for line in text.split('\n')]
    non_empty = sum(1 for line in lines if line.strip())
    followed = sum(
        1 for i in range(len(lines) - 1)
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
                final.append('')
            prev_empty = True
        else:
            final.append(line)
            prev_empty = False
    return '\n'.join(final)


CURSOR_HEADER = '''{
  Модуль uOglChartCursor
  Описание: Класс интерактивного курсора-визира для измерения текущих значений трендов.
}'''


def fix_cursor(path: Path) -> None:
    text = fix_cp1251_mojibake(read_text(path), rounds=3)
    lines = text.split('\n')
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == '{' and i + 1 < len(lines) and 'uOglChartCursor' in lines[i + 1]:
            out.append(CURSOR_HEADER)
            i += 1
            while i < len(lines) and lines[i].strip() != '}':
                i += 1
            if i < len(lines):
                i += 1
            continue
        if line.strip() == '}' and out and out[-1].strip() == '}':
            i += 1
            continue
        out.append(line)
        i += 1
    text = '\n'.join(out)
    text = collapse_double_spacing(text)
    write_utf8_crlf(path, text)


def fix_panzoom(path: Path) -> None:
    text = fix_cp1251_mojibake(read_text(path), rounds=2)
    text = collapse_double_spacing(text)
    write_utf8_crlf(path, text)


def fix_complex(path: Path) -> None:
    text = fix_cp1251_mojibake(read_text(path), rounds=2)
    text = text.replace('пїЅС… обозначают', 'Их обозначают')
    text = text.replace('С… обозначают', 'Их обозначают')
    if '{$codepage UTF8}' not in text[:400]:
        text = text.replace('{$mode delphi}\n\n', '{$mode delphi}\n{$codepage UTF8}\n\n', 1)
    text = collapse_double_spacing(text)
    write_utf8_crlf(path, text)


def fix_hardware_math(path: Path) -> None:
    text = fix_cp1251_mojibake(read_text(path), rounds=2)
    text = collapse_double_spacing(text)
    write_utf8_crlf(path, text)


def main() -> None:
    chart = Path(__file__).resolve().parents[1]
    math = chart.parents[1] / 'math'
    jobs = [
        ('uOglChartCursor.pas', chart, fix_cursor),
        ('uOglChartPanZoomListener.pas', chart, fix_panzoom),
        ('complex.pas', math, fix_complex),
        ('uHardwareMath.pas', math, fix_hardware_math),
    ]
    for name, root, fn in jobs:
        path = root / name
        fn(path)
        text = read_text(path)
        bad = any(x in text for x in ('Рњ', 'РЎ', 'пїЅ', '\ufffd'))
        print(f'{name}: lines={len(text.splitlines())}, bad={bad}')


if __name__ == '__main__':
    main()
