#!/usr/bin/env python3
"""Reorganize MIC140v2: utils subfolder, full split from legacy."""
from pathlib import Path
import shutil
import re

ROOT = Path(r'D:\works\OburecGH\Lazarus\RecorderLnx')
DEV = ROOT / 'Device'
V2 = DEV / 'MIC140v2'
UTILS = V2 / 'utils'
MIC = DEV / 'MIC140'

UTILS_FILES = [
    'uRecorderMic140v2Consts.pas',
    'uRecorderMic140v2Timing.pas',
    'uRecorderMic140v2ChanDesc.pas',
    'uRecorderMic140v2Diag.pas',
    'uRecorderMic140v2Helper.pas',
    'uRecorderMic140v2Types.pas',
]

RENAME_MAP = {
    'unit uRecorderMic140WireTypes;': 'unit uRecorderMic140v2WireTypes;',
    'uRecorderMic140WireTypes': 'uRecorderMic140v2WireTypes',
    'unit uRecorderMic140DeviceFactory;': 'unit uRecorderMic140v2Factory;',
    'uRecorderMic140DeviceFactory': 'uRecorderMic140v2Factory',
    'unit uRecorderMic140RawRing;': 'unit uRecorderMic140v2RawRing;',
    'uRecorderMic140RawRing': 'uRecorderMic140v2RawRing',
    'TMic140RawBlockRing': 'TMic140v2RawRing',
    'CMic140RawRingDefaultSlotCount': 'CMic140v2RawRingSlots',
}


def xform(text: str) -> str:
    for a, b in RENAME_MAP.items():
        text = text.replace(a, b)
    return text


def main():
    UTILS.mkdir(parents=True, exist_ok=True)

    wire_src = DEV / 'uRecorderMic140WireTypes.pas'
    wire_dst = UTILS / 'uRecorderMic140v2WireTypes.pas'
    if wire_src.exists():
        t = xform(wire_src.read_text(encoding='utf-8'))
        t = t.replace(
            'Общие wire-типы MIC-140 (кадр скана, прошивка, TIn).\n  Контракт IMic140Device; v1 legacy и v2 используют один layout.',
            'Wire-типы MIC-140 v2 (кадр скана, прошивка, TIn).',
        )
        wire_dst.write_text(t, encoding='utf-8')
        wire_src.unlink()
        print('wire -> utils')

    for name in UTILS_FILES:
        src = V2 / name
        if src.exists():
            shutil.move(str(src), str(UTILS / name))
            print('utils/', name)

    ring_src = MIC / 'uRecorderMic140RawRing.pas'
    ring_dst = V2 / 'uRecorderMic140v2RawRing.pas'
    if ring_src.exists():
        t = xform(ring_src.read_text(encoding='utf-8'))
        t = t.replace('uRecorderMic140StreamTypes', 'uRecorderMic140v2WireTypes')
        ring_dst.write_text(t, encoding='utf-8')
        ring_src.unlink()
        print('raw ring -> v2')

    fac_src = DEV / 'uRecorderMic140DeviceFactory.pas'
    fac_dst = V2 / 'uRecorderMic140v2Factory.pas'
    if fac_src.exists():
        t = xform(fac_src.read_text(encoding='utf-8'))
        t = t.replace(
            'Фабрика драйвера MIC-140. Смена v1 ↔ v2 — одна строка в CreateMic140Device.',
            'Фабрика MIC-140 v2 (единственная рабочая ветка опроса).',
        )
        fac_dst.write_text(t, encoding='utf-8')
        fac_src.unlink()
        print('factory -> v2')

    backup = V2 / 'backup'
    if backup.is_dir():
        shutil.rmtree(backup)
        print('removed backup')

    pas_files = list(ROOT.rglob('*.pas')) + list(ROOT.rglob('*.lpi')) + list(ROOT.rglob('*.lps'))
    for p in pas_files:
        if 'lib' in p.parts or 'cach' in p.parts:
            continue
        text = p.read_text(encoding='utf-8')
        new = xform(text)
        if new != text:
            p.write_text(new, encoding='utf-8')
            print('updated', p.relative_to(ROOT))

    lpi = ROOT / 'RecorderLnx.lpi'
    t = lpi.read_text(encoding='utf-8')
    t = t.replace(
        'Device/MIC140v2/uRecorderMic140v2Types.pas',
        'Device/MIC140v2/utils/uRecorderMic140v2Types.pas',
    )
    for name in UTILS_FILES:
        t = t.replace(f'Device/MIC140v2/{name}', f'Device/MIC140v2/utils/{name}')
    t = t.replace(
        '<Filename Value="Device/uRecorderMic140WireTypes.pas"/>',
        '<Filename Value="Device/MIC140v2/utils/uRecorderMic140v2WireTypes.pas"/>',
    )
    t = t.replace(
        '<Filename Value="Device/MIC140/uRecorderMic140RawRing.pas"/>',
        '<Filename Value="Device/MIC140v2/uRecorderMic140v2RawRing.pas"/>',
    )
    t = t.replace(
        '<Filename Value="Device/uRecorderMic140DeviceFactory.pas"/>',
        '<Filename Value="Device/MIC140v2/uRecorderMic140v2Factory.pas"/>',
    )
    t = t.replace(
        'Device/MIC140;Device/MIC140/UI;Device/MIC140v2;',
        'Device/MIC140;Device/MIC140/UI;Device/MIC140v2;Device/MIC140v2/utils;',
    )
    lpi.write_text(t, encoding='utf-8')
    print('lpi ok')


if __name__ == '__main__':
    main()
