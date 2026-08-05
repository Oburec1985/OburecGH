# -*- coding: utf-8 -*-
import io

file_path = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uOglChartChart.pas"

# Read the file in CP1251
with io.open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Locate procedure cChart.AlignPagesAuto(AAspect: Double);
target = "procedure cChart.AlignPagesAuto(AAspect: Double);\nvar\n  lPages: TList;\n  lIndex: Integer;\n  lPageIndex: Integer;\n  lPage: cBasePage;\n  lCols: Integer;\n  lRows: Integer;\n  lRow: Integer;\n  lCol: Integer;\n  lCellHeight: Double;\n  lAreaWidth: Double;\n  lAreaHeight: Double;\n  lLeft: Double;\n  lTop: Double;\n  lRowStart: Integer;\n  lRowCount: Integer;\n  lRowCellWidth: Double;\nbegin"

# Normalize line endings
content_normalized = content.replace('\r\n', '\n')
target_normalized = target.replace('\r\n', '\n')

replacement_normalized = """procedure cChart.AlignPagesAuto(AAspect: Double);
var
  lPages: TList;
  lIndex: Integer;
  lPageIndex: Integer;
  lPage: cBasePage;
  lCols: Integer;
  lRows: Integer;
  lRow: Integer;
  lCol: Integer;
  lCellHeight: Double;
  lAreaWidth: Double;
  lAreaHeight: Double;
  lLeft: Double;
  lTop: Double;
  lRowStart: Integer;
  lRowCount: Integer;
  lRowCellWidth: Double;
begin
  LogToFile('=== AlignPagesAuto: AAspect=' + FloatToStr(AAspect) + ' ===');"""

# Also we need to import LogToFile if not present, but wait, uOglChartChart.pas might not have LogToFile defined!
# Let's check if LogToFile is defined in uOglChartChart.pas or we can write a local one, or use a general log.
# Wait! Let's check if LogToFile is already defined in uOglChartChart.pas.
# We can search for LogToFile in uOglChartChart.pas.
