unit uRecorderDebugLog;

{$mode objfpc}{$H+}

interface

const
  { Временно: в LogWindows.log только диагностика legacy scan stream MIC-140.
    Вернуть False для полного лога приложения. }
  CMic140StreamLogOnly = True;

function Mic140StreamLogAllowed(const AMessage: string): Boolean;
procedure RecorderDebugLog(const AMessage: string);
procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);

implementation

uses
  SysUtils, uSharedFileLogger;

function Mic140StreamLogAllowed(const AMessage: string): Boolean;
begin
  if (Pos('thermocouple curve ready', AMessage) > 0) or
     (Pos('hardware calibr serial', AMessage) > 0) or
     (Pos('Ethernet protocol detected', AMessage) > 0) or
     (Pos('status=0 connecting', AMessage) > 0) or
     (Pos('status=1 connected', AMessage) > 0) or
     (Pos('status=2 programmed', AMessage) > 0) or
     (Pos('CJC active', AMessage) > 0) or
     (Pos('CJC T', AMessage) > 0) or
     (Pos('orphan StopScan', AMessage) > 0) or
     (Pos('loaded hardware calibration', AMessage) > 0) or
     (Pos('loaded TIn hardware calibration', AMessage) > 0) or
     (Pos('Tick took', AMessage) > 0) then
    Exit(False);

  if (Pos('MIC-140', AMessage) > 0) or
     (Pos('Legacy ', AMessage) > 0) or
     (Pos('stride misalignment', AMessage) > 0) or
     (Pos('raw ring', AMessage) > 0) or
     (Pos('BIOS header', AMessage) > 0) then
    Exit(True);

  Result := False;
end;

procedure RecorderDebugLog(const AMessage: string);
begin
  if CMic140StreamLogOnly and not Mic140StreamLogAllowed(AMessage) then
    Exit;
  SharedLogger.Debug(AMessage);
end;

procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
begin
  uSharedFileLogger.RegisterThreadName(AThreadID, AName);
end;

var
  lLogFile: string;

initialization
  SharedLogger.Enabled := True;
  {$IFDEF MSWINDOWS}
  lLogFile := ExtractFilePath(ParamStr(0)) + 'LogWindows.log';
  if DirectoryExists(ExtractFilePath(ParamStr(0)) + '..\..') then
    lLogFile := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\..\LogWindows.log');
  {$ELSE}
  if DirectoryExists('/mnt/win_share/OburecGH/Lazarus/RecorderLnx') then
    lLogFile := '/mnt/win_share/OburecGH/Lazarus/RecorderLnx/LogLinux.log'
  else
    lLogFile := ExtractFilePath(ParamStr(0)) + 'LogLinux.log';
  {$ENDIF}

  if FileExists(lLogFile) then
    DeleteFile(lLogFile);

  SharedLogger.Configure(lLogFile);

end.
