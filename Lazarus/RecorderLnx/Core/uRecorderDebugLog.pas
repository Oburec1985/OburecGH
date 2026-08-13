unit uRecorderDebugLog;

{$mode objfpc}{$H+}

interface

procedure RecorderDebugLog(const AMessage: string);
procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
procedure SetDeviceLogEnabled(AEnabled: Boolean);
function DeviceLogEnabled: Boolean;

implementation

uses
  SysUtils, uSharedFileLogger, uRecorderMeraPaths;

var
  gDeviceLogEnabled: Boolean = True;

procedure RecorderDebugLog(const AMessage: string);
begin
  SharedLogger.Debug(AMessage);
end;

procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
begin
  uSharedFileLogger.RegisterThreadName(AThreadID, AName);
end;

procedure SetDeviceLogEnabled(AEnabled: Boolean);
begin
  gDeviceLogEnabled := AEnabled;
end;

function DeviceLogEnabled: Boolean;
begin
  Result := gDeviceLogEnabled;
end;

var
  lLogFile: string;
  lPreviousLog: string;

initialization
  SharedLogger.Enabled := True;
  {$IFDEF MSWINDOWS}
  lLogFile := RecorderServiceFileName('LogWindows.log');
  {$ELSE}
  lLogFile := RecorderServiceFileName('LogLinux.log');
  {$ENDIF}

  lPreviousLog := ChangeFileExt(lLogFile, '.previous.log');
  if FileExists(lPreviousLog) then
    DeleteFile(lPreviousLog);
  if FileExists(lLogFile) then
    RenameFile(lLogFile, lPreviousLog);

  SharedLogger.Configure(lLogFile);
  SharedLogger.Info('RecorderLnx log initialized: ' + lLogFile);

end.
