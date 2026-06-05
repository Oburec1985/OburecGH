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
  { Hot-path diagnostics are disabled by default: file append per data block
    makes the process working set grow during long preview runs. }
end;

procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
begin
  uSharedFileLogger.RegisterThreadName(AThreadID, AName);
end;

initialization
  SharedLogger.Enabled := False;
  if FileExists(CRecorderLogFile) then
    DeleteFile(CRecorderLogFile);
  SharedLogger.Configure(CRecorderLogFile);

end.
