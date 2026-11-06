unit uRecorderDebugLog;

{$mode objfpc}{$H+}

interface

procedure RecorderDebugLog(const AMessage: string);
procedure RecorderInfoLog(const AMessage: string);
procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
procedure SetDeviceLogEnabled(AEnabled: Boolean);
function DeviceLogEnabled: Boolean;
function RecorderDebugLogFileName: string;

implementation

uses
  SysUtils, IniFiles, uSharedFileLogger, uRecorderMeraPaths;

var
  gDeviceLogEnabled: Boolean = True;
  gDeviceLogSettingsLoaded: Boolean = False;
  gLogFile: string = '';

procedure RecorderDebugLog(const AMessage: string);
begin
  SharedLogger.Debug(AMessage);
end;

procedure RecorderInfoLog(const AMessage: string);
begin
  SharedLogger.Info(AMessage);
end;

procedure RegisterThreadName(AThreadID: TThreadID; const AName: string);
begin
  uSharedFileLogger.RegisterThreadName(AThreadID, AName);
end;

procedure LoadDeviceLogSettings;
var
  lIni: TIniFile;
begin
  if gDeviceLogSettingsLoaded then Exit;
  lIni := TIniFile.Create(RecorderAppConfigFileName);
  try
    gDeviceLogEnabled := lIni.ReadBool('Diagnostics', 'DeviceLogEnabled', True);
    gDeviceLogSettingsLoaded := True;
  finally
    lIni.Free;
  end;
end;

procedure SetDeviceLogEnabled(AEnabled: Boolean);
var
  lIni: TIniFile;
begin
  LoadDeviceLogSettings;
  if AEnabled = gDeviceLogEnabled then Exit;
  if not ForceDirectories(RecorderAppConfigDir) then
    raise Exception.Create('Cannot create application configuration directory');
  lIni := TIniFile.Create(RecorderAppConfigFileName);
  try
    lIni.WriteBool('Diagnostics', 'DeviceLogEnabled', AEnabled);
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
  gDeviceLogEnabled := AEnabled;
end;

function DeviceLogEnabled: Boolean;
begin
  LoadDeviceLogSettings;
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
