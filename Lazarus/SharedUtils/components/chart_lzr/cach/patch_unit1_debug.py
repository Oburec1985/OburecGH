# -*- coding: utf-8 -*-
import os

file_path = r"c:\Oburec\OburecGH\Lazarus\OGlChartLaz\Test_component\unit1.pas"

if not os.path.exists(file_path):
    print("Error: unit1.pas not found")
    exit(1)

with open(file_path, "r", encoding="cp1251") as f:
    content = f.read()

target = """  // Programmatic selection check for testing
  if GetEnvironmentVariable('CHART_TEST_SELECT_AXIS') = '1' then
  begin
    OglChart1.SelectedObject := lAxisPerf1D;
  end;"""

replacement = """  // Programmatic selection check for testing
  begin
    var lLogVal: string;
    var lLogFile: TextFile;
    lLogVal := GetEnvironmentVariable('CHART_TEST_SELECT_AXIS');
    AssignFile(lLogFile, ExtractFilePath(ParamStr(0)) + 'init_trace.log');
    Append(lLogFile);
    WriteLn(lLogFile, 'FormCreate: CHART_TEST_SELECT_AXIS = \"' + lLogVal + '\"');
    CloseFile(lLogFile);
    if lLogVal = '1' then
    begin
      OglChart1.SelectedObject := lAxisPerf1D;
    end;
  end;"""

if target in content:
    content = content.replace(target, replacement)
    with open(file_path, "w", encoding="cp1251", newline="\r\n") as f:
        f.write(content)
    print("Successfully added debug logging to unit1.pas!")
else:
    print("Target string not found in unit1.pas.")
