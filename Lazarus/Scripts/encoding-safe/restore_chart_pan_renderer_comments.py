#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Restore uOglChartPanZoomListener + uOglChartRenderer comments from git 88ba4f91.

Re-applies functional patches (MarkAxisUserZoomY, ApplyActiveHitNumericValue).
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]  # Lazarus/
CHART = ROOT / "SharedUtils/components/chart_lzr"
REPO = Path(r"D:\works\OburecGH")
GOOD_REF = "88ba4f91"

sys.path.insert(0, str(Path(__file__).resolve().parent / "lib"))
from pas_io import fix_cp1251_mojibake, write_utf8_crlf

APPLY_ACTIVE_HIT = """procedure ApplyActiveHitNumericValue(const AHit: TChartTextHit; AValue: Double);
begin
  case AHit.Kind of
    celAxisMin:
      ChartAxisApplyUserValue(AHit.Axis, True, AValue);
    celAxisMax:
      ChartAxisApplyUserValue(AHit.Axis, False, AValue);
    celXMin:
      if Assigned(AHit.Axis) then
        AHit.Axis.XMinValue := AValue
      else if Assigned(AHit.Page) then
      begin
        ChartPageApplyUserXValue(AHit.Page, True, AValue);
        AHit.Page.ZoomedX := True;
      end;
    celXMax:
      if Assigned(AHit.Axis) then
        AHit.Axis.XMaxValue := AValue
      else if Assigned(AHit.Page) then
      begin
        ChartPageApplyUserXValue(AHit.Page, False, AValue);
        AHit.Page.ZoomedX := True;
      end;
  end;
end;

"""

MARK_AXIS_USER_ZOOM_Y = """procedure MarkAxisUserZoomY(AAxis: TChartAxis);
begin
  if Assigned(AAxis) then
    AAxis.HasPresetRange := True;
end;

"""

APPLY_PRESET_ZOOM_Y_AXIS = """procedure ApplyPresetZoomY(AAxis: TChartAxis);
begin
  if not Assigned(AAxis) then
    Exit;
  if AAxis.PresetMaxValue > AAxis.PresetMinValue then
  begin
    AAxis.MinValue := AAxis.PresetMinValue;
    AAxis.MaxValue := AAxis.PresetMaxValue;
  end;
  AAxis.HasPresetRange := False;
end;

"""

OLD_COMMIT_BLOCK = re.compile(
    r"  if TryStrToFloatUniversal\(fEditText, lValue\) then\s*"
    r"begin\s*"
    r"if fActiveHit\.Kind = celAxisMin then.*?end;\s*\n\s*end;\s*\n",
    re.DOTALL,
)

NEW_COMMIT_BLOCK = (
    "  if TryStrToFloatUniversal(fEditText, lValue) then\n"
    "    ApplyActiveHitNumericValue(fActiveHit, lValue);\n\n"
    "end;\n\n"
)


def load_git_pas(git_path: str) -> str:
    raw = subprocess.check_output(
        ["git", "-C", str(REPO), "show", f"{GOOD_REF}:{git_path}"],
    )
    return raw.decode("utf-8").replace("\r\n", "\n").replace("\r", "\n")


def patch_panzoom(text: str) -> str:
    text = fix_cp1251_mojibake(text, rounds=3)

    if "procedure MarkAxisUserZoomY" not in text:
        text = text.replace(
            "procedure ApplyPresetZoomY(AAxis: TChartAxis);",
            MARK_AXIS_USER_ZOOM_Y + APPLY_PRESET_ZOOM_Y_AXIS,
            1,
        )
    else:
        text = re.sub(
            r"procedure ApplyPresetZoomY\(AAxis: TChartAxis\);\s*begin.*?AAxis\.HasPresetRange := False;\s*end;\s*\n",
            APPLY_PRESET_ZOOM_Y_AXIS,
            text,
            count=1,
            flags=re.DOTALL,
        )

    replacements = [
        (
            "lAxis.MaxValue := lAxis.MaxValue + dValY;\n          end;",
            "lAxis.MaxValue := lAxis.MaxValue + dValY;\n            MarkAxisUserZoomY(lAxis);\n          end;",
        ),
        (
            "                  lAxis.MaxValue := NewYMax;\n                end;",
            "                  lAxis.MaxValue := NewYMax;\n                  MarkAxisUserZoomY(lAxis);\n                end;",
        ),
        (
            "            lAxis.MaxValue := lMouseValY + (lAxis.MaxValue - lMouseValY) * lZoomFactor;\n          end;",
            "            lAxis.MaxValue := lMouseValY + (lAxis.MaxValue - lMouseValY) * lZoomFactor;\n            MarkAxisUserZoomY(lAxis);\n          end;",
        ),
    ]
    for old, new in replacements:
        if new.split("\n")[1].strip() not in text:
            text = text.replace(old, new, 1)

    return text


def patch_renderer(text: str) -> str:
    if "procedure ApplyActiveHitNumericValue" not in text:
        text = text.replace(
            "function TOpenGLChartRenderer.KeyDown(AKey: Word): Boolean;",
            APPLY_ACTIVE_HIT + "function TOpenGLChartRenderer.KeyDown(AKey: Word): Boolean;",
            1,
        )

    text = OLD_COMMIT_BLOCK.sub(NEW_COMMIT_BLOCK, text)
    return text


def main() -> int:
    jobs = [
        (
            "Lazarus/SharedUtils/components/chart_lzr/uOglChartPanZoomListener.pas",
            CHART / "uOglChartPanZoomListener.pas",
            patch_panzoom,
        ),
        (
            "Lazarus/SharedUtils/components/chart_lzr/uOglChartRenderer.pas",
            CHART / "uOglChartRenderer.pas",
            patch_renderer,
        ),
    ]
    for git_path, out_path, patch_fn in jobs:
        text = load_git_pas(git_path)
        text = patch_fn(text)
        write_utf8_crlf(out_path, text)
        cyr = sum(1 for c in text if "\u0400" <= c <= "\u04ff")
        bad98 = text.count("\x98")
        print(f"OK {out_path.name}: lines={len(text.splitlines())}, cyrillic={cyr}, 0x98={bad98}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
