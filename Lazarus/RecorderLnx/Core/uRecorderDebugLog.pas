unit uRecorderDebugLog;

{$mode objfpc}{$H+}

interface

procedure RecorderDebugLog(const AMessage: string);
procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);

implementation

uses
  SysUtils, uSharedFileLogger, uRecorderMeraPaths;

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
  lLogFile := RecorderServiceFileName('LogWindows.log');
  {$ELSE}
  lLogFile := RecorderServiceFileName('LogLinux.log');
  {$ENDIF}

  if FileExists(lLogFile) then
    DeleteFile(lLogFile);

  SharedLogger.Configure(lLogFile);
  SharedLogger.Info('RecorderLnx log initialized: ' + lLogFile);

end.
