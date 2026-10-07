unit uRecorder3dInteractionTrace;

{$mode objfpc}{$H+}

{ Recorder-specific opt-in bridge for detailed interaction events emitted by
  the reusable 3D widget. The view calls this API; the unit owns the lazy
  rotating logger from first use until process finalization. }

interface

procedure Recorder3dInteractionTrace(const AMessage: string);
function Recorder3dInteractionTraceEnabled: Boolean;
function Recorder3dInteractionTraceFileName: string;

implementation

uses
  SysUtils, IniFiles, uSharedFileLogger, uRecorderMeraPaths;

var
  gConfigured: Boolean = False;
  gEnabled: Boolean = False;
  gLogger: TSharedFileLogger = nil;
  gFileName: string = '';

procedure Configure;
forward;

procedure EnsureConfigured;
begin
  if not gConfigured then
    Configure;
end;

procedure Recorder3dInteractionTrace(const AMessage: string);
begin
  EnsureConfigured;
  if gEnabled and (gLogger <> nil) then
    gLogger.Debug('[3D] ' + AMessage);
end;

function Recorder3dInteractionTraceEnabled: Boolean;
begin
  EnsureConfigured;
  Result := gEnabled;
end;

function Recorder3dInteractionTraceFileName: string;
begin
  EnsureConfigured;
  Result := gFileName;
end;

function ReadEnabled(const AFileName: string): Boolean;
var
  Ini: TIniFile;
begin
  Result := False;
  if not FileExists(AFileName) then
    Exit;
  Ini := TIniFile.Create(AFileName);
  try
    Result := Ini.ReadBool('Diagnostics', 'Debug3dInteraction', False);
  finally
    Ini.Free;
  end;
end;

procedure Configure;
var
  ConfigFile, ServiceConfigFile: string;
begin
  ConfigFile := RecorderAppConfigFileName;
  ServiceConfigFile := RecorderServiceFileName('app.ini');
  gEnabled := ReadEnabled(ConfigFile);
  if (not gEnabled) and (not SameFileName(ConfigFile,ServiceConfigFile)) then
    gEnabled := ReadEnabled(ServiceConfigFile);
  gConfigured := True;
  if not gEnabled then
    Exit;
  gFileName := RecorderServiceFileName('Recorder3dInteraction.log');
  gLogger := TSharedFileLogger.Create(gFileName, 5 * 1024 * 1024, 3);
  gLogger.Info(Format('3D interaction trace enabled config="%s" executable="%s"',
    [ConfigFile, ParamStr(0)]));
end;

finalization
  gLogger.Free;

end.
