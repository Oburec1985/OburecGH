# -*- coding: utf-8 -*-
import os

file_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

if not os.path.exists(file_path):
    print("Error: unit1.pas not found")
    exit(1)

with open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

target = """  btnRefreshTree.Visible := True;
  BuildChartTree;

  // Запускаем перерисовку графика
  OglChart1.Redraw;
end;"""

replacement = """  btnRefreshTree.Visible := True;
  BuildChartTree;

  // Programmatic selection check for testing
  if GetEnvironmentVariable('CHART_TEST_SELECT_AXIS') = '1' then
  begin
    OglChart1.SelectedObject := lAxisPerf1D;
  end;

  // Запускаем перерисовку графика
  OglChart1.Redraw;
end;"""

if target in content:
    content = content.replace(target, replacement)
    with open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
        f.write(content)
    print("Successfully patched unit1.pas!")
else:
    print("Target string not found in unit1.pas.")
