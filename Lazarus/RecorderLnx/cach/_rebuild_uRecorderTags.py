#!/usr/bin/env python3
"""Rebuild uRecorderTags.pas from UTF-8 backup + keep newer code additions."""
from __future__ import annotations

from pathlib import Path

CORE = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx\Core/uRecorderTags.pas")
BACKUP = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx\cach/uRecorderTags_utf8.pas")
CURRENT = CORE


def nl(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def to_crlf(text: str) -> bytes:
    return nl(text).replace("\n", "\r\n").encode("utf-8")


def extract_block(text: str, start_marker: str, end_marker: str) -> str:
    start = text.index(start_marker)
    end = text.index(end_marker, start)
    return text[start:end]


def main() -> None:
    base = nl(BACKUP.read_text(encoding="utf-8"))
    cur = nl(CURRENT.read_text(encoding="utf-8"))

    share_decl = extract_block(
        cur,
        "function RecorderTagsShareSourceId(ARegistry: TRecorderTagRegistry;",
        "implementation",
    ).rstrip()
    share_impl = extract_block(
        cur,
        "function RecorderTagsShareSourceId(ARegistry: TRecorderTagRegistry;\n  const ATagNames: array of string): Boolean;",
        "{ TRecorderSignalBuffer }",
    ).rstrip()
    rename_impl = extract_block(
        cur,
        "function TRecorderTagRegistry.RenameTag(ATag: TRecorderTag; const ANewName: string): Boolean;",
        "function TRecorderTagRegistry.FindCalibrationByName(const AName: string): TRecorderCalibration;",
    ).rstrip()

    text = base.replace(
        "  uRecorderCoreServices;",
        "  uRecorderCoreServices, uRecorderSpectrumEngine, uRecorderFrequencyBands;",
        1,
    )
    text = text.replace(
        "    fCalibrations: TRecorderCalibrationList;\n    function GetActiveSourceCount: Integer;",
        "    fCalibrations: TRecorderCalibrationList;\n"
        "    fSpectrumConfigs: TRecorderSpectrumConfigTree;\n"
        "    fFrequencyBands: TRecorderFrequencyBandList;\n"
        "    function GetActiveSourceCount: Integer;",
        1,
    )
    text = text.replace(
        "    function FindByName(const AName: string): TRecorderTag;\n"
        "    function FindCalibrationByName(const AName: string): TRecorderCalibration;",
        "    function FindByName(const AName: string): TRecorderTag;\n"
        "    function RenameTag(ATag: TRecorderTag; const ANewName: string): Boolean;\n"
        "    function FindCalibrationByName(const AName: string): TRecorderCalibration;",
        1,
    )
    text = text.replace(
        "    property Calibrations: TRecorderCalibrationList read fCalibrations;\n"
        "    property Tags[AIndex: Integer]: TRecorderTag read GetTag;",
        "    property Calibrations: TRecorderCalibrationList read fCalibrations;\n"
        "    property SpectrumConfigs: TRecorderSpectrumConfigTree read fSpectrumConfigs;\n"
        "    property FrequencyBands: TRecorderFrequencyBandList read fFrequencyBands;\n"
        "    property Tags[AIndex: Integer]: TRecorderTag read GetTag;",
        1,
    )
    text = text.replace(
        "function RecorderTagEstimatePortionLengthIsAuto(AValue: Integer;\n"
        "  APollFrequencyHz: Double; ADataUpdateMs: Cardinal): Boolean;\n\nimplementation",
        "function RecorderTagEstimatePortionLengthIsAuto(AValue: Integer;\n"
        "  APollFrequencyHz: Double; ADataUpdateMs: Cardinal): Boolean;\n\n"
        + share_decl
        + "\n\nimplementation",
        1,
    )
    text = text.replace(
        "  fCalibrations := TRecorderCalibrationList.Create;\nend;",
        "  fCalibrations := TRecorderCalibrationList.Create;\n"
        "  fSpectrumConfigs := TRecorderSpectrumConfigTree.Create;\n"
        "  fFrequencyBands := TRecorderFrequencyBandList.Create;\nend;",
        1,
    )
    text = text.replace(
        "  Clear;\n  fCalibrations.Free;\n  fActiveSourceIds.Free;",
        "  Clear;\n  fFrequencyBands.Free;\n  fSpectrumConfigs.Free;\n  fCalibrations.Free;\n  fActiveSourceIds.Free;",
        1,
    )
    text = text.replace(
        "end;\n\n\nfunction TRecorderTagRegistry.FindCalibrationByName(const AName: string): TRecorderCalibration;",
        "end;\n\n\n" + rename_impl + "\n\n\nfunction TRecorderTagRegistry.FindCalibrationByName(const AName: string): TRecorderCalibration;",
        1,
    )
    text = text.replace(
        "end;\n\n{ TRecorderSignalBuffer }",
        "end;\n\n" + share_impl + "\n\n{ TRecorderSignalBuffer }",
        1,
    )

    if "{$codepage UTF8}" not in text:
        text = text.replace("{$mode objfpc}{$H+}", "{$mode objfpc}{$H+}\n{$codepage UTF8}", 1)

    bad = text.count("пїЅ") + text.count("\ufffd")
    if bad:
        raise SystemExit(f"rebuild failed, bad chars={bad}")

    CORE.write_bytes(to_crlf(text))
    cyr = sum(1 for c in text if "\u0400" <= c <= "\u04FF")
    print(f"OK rebuilt uRecorderTags.pas cyrillic={cyr}")


if __name__ == "__main__":
    main()
