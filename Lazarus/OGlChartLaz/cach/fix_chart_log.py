import os

CHART_PATH = r"c:\Oburec\OburecGH\Lazarus\SharedUtils\components\chart_lzr\uoglchart.pas"

with open(CHART_PATH, 'rb') as f:
    raw_c = f.read()
content_c = raw_c.decode('cp1251')
content_c_lf = content_c.replace('\r\n', '\n').replace('\r', '\n')

impl_start_chart_target = """implementation

uses Windows;

{ TOglChart }"""

impl_start_chart_replacement = """implementation

uses Windows;

procedure LogToFile(const AMsg: string);
var
  F: TextFile;
  lLogPath: string;
begin
  lLogPath := ExtractFilePath(ParamStr(0)) + 'chart_events.log';
  AssignFile(F, lLogPath);
  try
    if FileExists(lLogPath) then
      Append(F)
    else
      Rewrite(F);
    WriteLn(F, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ': ' + AMsg);
  finally
    CloseFile(F);
  end;
end;

{ TOglChart }"""

if impl_start_chart_target in content_c_lf:
    content_c_lf = content_c_lf.replace(impl_start_chart_target, impl_start_chart_replacement)
    print("Successfully added LogToFile to uoglchart.pas.")
else:
    print("Error: impl_start_chart_target not found!")

with open(CHART_PATH, 'wb') as f:
    f.write(content_c_lf.replace('\n', '\r\n').encode('cp1251'))
