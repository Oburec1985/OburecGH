unit uRecorderDebugLog;

{$mode objfpc}{$H+}

interface

procedure RecorderDebugLog(const AMessage: string);
procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
procedure SetDeviceLogEnabled(AEnabled: Boolean);
function DeviceLogEnabled: Boolean;
function RecorderDebugLogFileName: string;

implementation

uses
  SysUtils, uSharedFileLogger, uRecorderMeraPaths;

var
  gDeviceLogEnabled: Boolean = True;
  gLogFile: string = '';

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

function RecorderDebugLogFileName: string;
begin
  Result := gLogFile;
end;

var
  lPreviousLog: string;

initialization
  SharedLogger.Enabled := True;
  {$IFDEF MSWINDOWS}
  gLogFile := RecorderServiceFileName('LogWindows.log');
  {$ELSE}
  gLogFile := RecorderServiceFileName('LogLinux.log');
  {$ENDIF}

  lPreviousLog := ChangeFileExt(gLogFile, '.previous.log');
  if FileExists(lPreviousLog) then
    DeleteFile(lPreviousLog);
  if FileExists(gLogFile) then
    RenameFile(gLogFile, lPreviousLog);

  SharedLogger.Configure(gLogFile);
  SharedLogger.Info('RecorderLnx log initialized: ' + gLogFile);

end.
