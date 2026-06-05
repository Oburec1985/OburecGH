unit uRecorderDebugLog;

{$mode objfpc}{$H+}

interface

procedure RecorderDebugLog(const AMessage: string);
procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);

implementation

uses
  SysUtils, uSharedFileLogger;

const
  CRecorderLogFile = 'C:\Oburec\OburecGH\Lazarus\RecorderLnx\RecorderLnx.log';

procedure RecorderDebugLog(const AMessage: string);
begin
  SharedLogger.Debug(AMessage);
end;

procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
begin
  uSharedFileLogger.RegisterThreadName(AThreadID, AName);
end;

initialization
  if FileExists(CRecorderLogFile) then
    DeleteFile(CRecorderLogFile);
  SharedLogger.Configure(CRecorderLogFile);

end.
