# -*- coding: utf-8 -*-
import io

file_path = "uOglChartRenderer.pas"

with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

content = content.replace("\r\n", "\n").replace("\r", "\n")

# 1. Cast Children[J] to cBaseTrend in FindSelectedTrend
target_trend = """      for J := 0 to lAxis.ChildCount - 1 do
        if lAxis.Children[J] is cBaseTrend then
        begin
          if lAxis.Children[J].Visible then
            Exit(cBaseTrend(lAxis.Children[J]));
        end;"""

replacement_trend = """      for J := 0 to lAxis.ChildCount - 1 do
        if lAxis.Children[J] is cBaseTrend then
        begin
          if cBaseTrend(lAxis.Children[J]).Visible then
            Exit(cBaseTrend(lAxis.Children[J]));
        end;"""

if target_trend in content:
    content = content.replace(target_trend, replacement_trend)
    print("Trend cast fixed.")
else:
    print("Error: target_trend not found")

# 2. Use Round in DrawCursorLabel assignments
target_rect = """    lRect.Left := AXPixel - lTextWidth / 2 - 6;
    lRect.Right := AXPixel + lTextWidth / 2 + 6;
    lRect.Top := AYPixel - lTextHeight / 2 - 4;
    lRect.Bottom := AYPixel + lTextHeight / 2 + 4;"""

replacement_rect = """    lRect.Left := Round(AXPixel - lTextWidth / 2 - 6);
    lRect.Right := Round(AXPixel + lTextWidth / 2 + 6);
    lRect.Top := Round(AYPixel - lTextHeight / 2 - 4);
    lRect.Bottom := Round(AYPixel + lTextHeight / 2 + 4);"""

if target_rect in content:
    content = content.replace(target_rect, replacement_rect)
    print("Label rect round fixed.")
else:
    print("Error: target_rect not found")

content = content.replace("\n", "\r\n")

with io.open(file_path, "w", encoding="cp1251", newline="") as f:
    f.write(content)

print("Done.")
