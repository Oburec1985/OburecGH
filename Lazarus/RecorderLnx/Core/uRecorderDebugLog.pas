unit uRecorderDebugLog;

{$mode objfpc}{$H+}

interface

procedure RecorderDebugLog(const AMessage: string);
procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);

implementation

uses
  SysUtils, uSharedFileLogger;

procedure RecorderDebugLog(const AMessage: string);
begin
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