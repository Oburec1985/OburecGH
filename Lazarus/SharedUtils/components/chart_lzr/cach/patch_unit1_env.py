# -*- coding: utf-8 -*-
import os

file_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

if not os.path.exists(file_path):
    print("Error: unit1.pas not found")
    exit(1)

with open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

# Let's clean up both the old select_axis parameter code and replace it with environment variable check
target = """  // Programmatic selection check for testing
  if (ParamCount > 0) and (ParamStr(1) = 'select_axis') then
  begin
    OglChart1.SelectedObject := lAxisPerf1D;
  end;"""

replacement = """  // Programmatic selection check for testing
  if GetEnvironmentVariable('CHART_TEST_SELECT_AXIS') = '1' then
  begin
    OglChart1.SelectedObject := lAxisPerf1D;
  end;"""

if target in content:
    content = content.replace(target, replacement)
    with open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
        f.write(content)
    print("Successfully patched unit1.pas to use environment variable!")
else:
    # Check if target is already patched or if we need to search for original target
    print("Target string not found in unit1.pas. It might already be patched or have different format.")
