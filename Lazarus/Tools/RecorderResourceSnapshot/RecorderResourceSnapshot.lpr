program RecorderResourceSnapshot;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces, Forms, SysUtils, uMainForm, uResourceSnapshot;

function ParameterValue(const AName: string): string;
var
  lIndex: Integer;
  lPrefix: string;
begin
  Result := '';
  lPrefix := '--' + AName + '=';
  for lIndex := 1 to ParamCount do
    if Pos(lPrefix, ParamStr(lIndex)) = 1 then
      Exit(Copy(ParamStr(lIndex), Length(lPrefix) + 1, MaxInt));
end;

procedure RunCommandLineSnapshot;
var
  lPid: QWord;
  lLogFile, lText: string;
begin
  if not TryStrToQWord(ParameterValue('pid'), lPid) then
    raise Exception.Create('Для CLI укажите --pid=<номер>.');
  lLogFile := ParameterValue('log');
  if lLogFile = '' then
    lLogFile := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
      'RecorderResourceSnapshots.log';
  lText := TResourceSnapshotService.Capture(lPid);
  TResourceSnapshotService.AppendToLog(lLogFile, lText);
end;

begin
  if ParameterValue('pid') <> '' then
  begin
    try
      RunCommandLineSnapshot;
      Halt(0);
    except
      on E: Exception do
      begin
        TResourceSnapshotService.AppendToLog(ParameterValue('log'),
          'ERROR ' + E.ClassName + ': ' + E.Message);
        Halt(2);
      end;
    end;
  end;
  RequireDerivedFormResource := False;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
