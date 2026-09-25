unit uLuaCalcPlugin;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, SyncObjs, IniFiles, uRecorderPluginApi,
  uLuaCalcEngine;

type
  TLuaCalcPlugin = class
  private
    fHost: TRecorderPluginHostApi;
    fScripts: TList;
    fDirectory: string;
    fProjectDirectory: string;
    fDelayedWorkers: TList;
    fDelayedWorkersLock: TCriticalSection;
    fClosing: Boolean;
    procedure UpdateDirectory;
    procedure LogError(const AMessage: string);
    procedure ReloadScripts;
    procedure RunScripts;
    procedure ReapDelayedWorkers;
    procedure StopDelayedWorkers;
    function ScheduleTagValue(const AName: UTF8String; AValue,
      ADelaySeconds: Double): Boolean;
    function PublishDelayedValue(const AName: UTF8String;
      AValue: Double): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Initialize(AHostApi: PRecorderPluginHostApi): Boolean;
    function Notify(AEvent: LongInt): Boolean;
    procedure Close;
  end;

implementation

type
  TDelayedTagValueWorker = class(TThread)
  private
    fOwner: TLuaCalcPlugin;
    fWakeEvent: TEvent;
    fName: UTF8String;
    fValue: Double;
    fDelayMilliseconds: Cardinal;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TLuaCalcPlugin; const AName: UTF8String;
      AValue: Double; ADelayMilliseconds: Cardinal);
    destructor Destroy; override;
    procedure Stop;
  end;

  TLoadedScript = class
    Name: string;
    Engine: TLuaCalcEngine;
    Active: Boolean;
    destructor Destroy; override;
  end;

destructor TLoadedScript.Destroy;
begin
  Engine.Free;
  inherited Destroy;
end;

constructor TDelayedTagValueWorker.Create(AOwner: TLuaCalcPlugin;
  const AName: UTF8String; AValue: Double; ADelayMilliseconds: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fName := AName;
  fValue := AValue;
  fDelayMilliseconds := ADelayMilliseconds;
  fWakeEvent := TEvent.Create(nil, True, False, '');
end;

destructor TDelayedTagValueWorker.Destroy;
begin
  fWakeEvent.Free;
  inherited Destroy;
end;

procedure TDelayedTagValueWorker.Execute;
begin
  if (fWakeEvent.WaitFor(fDelayMilliseconds) = wrTimeout) and
    not Terminated then
    fOwner.PublishDelayedValue(fName, fValue);
end;

procedure TDelayedTagValueWorker.Stop;
begin
  Terminate;
  fWakeEvent.SetEvent;
end;

function ReadValue(AContext: Pointer; const AName: UTF8String;
  out AValue: Double): Boolean; cdecl;
var
  lHost: ^TRecorderPluginHostApi;
  lTime: Double;
begin
  lHost := @TLuaCalcPlugin(AContext).fHost;
  Result := Assigned(lHost^.ReadTagValue) and
    lHost^.ReadTagValue(lHost^.HostContext, PAnsiChar(AName), lTime, AValue);
end;

function ReadSample(AContext: Pointer; const AName: UTF8String;
  out AValue, ATime: Double): Boolean; cdecl;
var
  lHost: ^TRecorderPluginHostApi;
begin
  lHost := @TLuaCalcPlugin(AContext).fHost;
  Result := Assigned(lHost^.ReadTagValue) and
    lHost^.ReadTagValue(lHost^.HostContext, PAnsiChar(AName), ATime, AValue);
end;

function TagExists(AContext: Pointer; const AName: UTF8String): Boolean; cdecl;
var
  lHost: ^TRecorderPluginHostApi;
begin
  lHost := @TLuaCalcPlugin(AContext).fHost;
  Result := Assigned(lHost^.TagExists) and
    lHost^.TagExists(lHost^.HostContext, PAnsiChar(AName));
end;

function ReadAlarmLevel(AContext: Pointer; const AName: UTF8String;
  out ALevel: LongInt): Boolean; cdecl;
var
  lHost: ^TRecorderPluginHostApi;
begin
  lHost := @TLuaCalcPlugin(AContext).fHost;
  Result := Assigned(lHost^.GetTagAlarmLevel) and
    lHost^.GetTagAlarmLevel(lHost^.HostContext, PAnsiChar(AName), ALevel);
end;

function SetpointKind(const AKind: UTF8String; out AValue: LongInt): Boolean;
begin
  Result := True;
  if SameText(string(AKind), 'highAlarm') then AValue := 0
  else if SameText(string(AKind), 'highWarning') then AValue := 1
  else if SameText(string(AKind), 'lowWarning') then AValue := 2
  else if SameText(string(AKind), 'lowAlarm') then AValue := 3
  else Result := False;
end;

function ReadSetpoint(AContext: Pointer; const AName, AKind: UTF8String;
  out AThreshold: Double; out AEnabled: Boolean): Boolean; cdecl;
var
  lHost: ^TRecorderPluginHostApi;
  lKind: LongInt;
  lEnabled: LongBool;
begin
  lHost := @TLuaCalcPlugin(AContext).fHost;
  lEnabled := False;
  Result := SetpointKind(AKind, lKind) and Assigned(lHost^.GetTagSetpoint) and
    lHost^.GetTagSetpoint(lHost^.HostContext, PAnsiChar(AName), lKind,
      AThreshold, lEnabled);
  AEnabled := lEnabled;
end;

function WriteSetpoint(AContext: Pointer; const AName, AKind: UTF8String;
  AThreshold: Double; AEnabled: Boolean): Boolean; cdecl;
var
  lHost: ^TRecorderPluginHostApi;
  lKind: LongInt;
begin
  lHost := @TLuaCalcPlugin(AContext).fHost;
  Result := SetpointKind(AKind, lKind) and Assigned(lHost^.SetTagSetpoint) and
    lHost^.SetTagSetpoint(lHost^.HostContext, PAnsiChar(AName), lKind,
      AThreshold, AEnabled);
end;

function RecorderTime(AContext: Pointer): Double; cdecl;
var
  lHost: ^TRecorderPluginHostApi;
begin
  Result := 0;
  lHost := @TLuaCalcPlugin(AContext).fHost;
  if Assigned(lHost^.GetRecorderTime) then
    lHost^.GetRecorderTime(lHost^.HostContext, Result);
end;

function WriteValue(AContext: Pointer; const AName: UTF8String;
  AValue, ATime: Double; AStatus: LongInt): Boolean; cdecl;
var
  lHost: ^TRecorderPluginHostApi;
begin
  lHost := @TLuaCalcPlugin(AContext).fHost;
  Result := Assigned(lHost^.PublishTagValue) and
    lHost^.PublishTagValue(lHost^.HostContext, PAnsiChar(AName), AValue);
end;

function WriteDelayedValue(AContext: Pointer; const AName: UTF8String;
  AValue, ADelaySeconds: Double): Boolean; cdecl;
begin
  Result := TLuaCalcPlugin(AContext).ScheduleTagValue(AName, AValue,
    ADelaySeconds);
end;

constructor TLuaCalcPlugin.Create;
begin
  inherited Create;
  fScripts := TList.Create;
  fDelayedWorkers := TList.Create;
  fDelayedWorkersLock := TCriticalSection.Create;
end;

destructor TLuaCalcPlugin.Destroy;
begin
  Close;
  fDelayedWorkersLock.Free;
  fDelayedWorkers.Free;
  fScripts.Free;
  inherited Destroy;
end;

function TLuaCalcPlugin.Initialize(AHostApi: PRecorderPluginHostApi): Boolean;
var
  lRequiredSize, lCopySize: SizeUInt;
begin
  Result := AHostApi <> nil;
  if not Result then Exit;
  lRequiredSize := PtrUInt(@AHostApi^.LogMessage) - PtrUInt(AHostApi) +
    SizeOf(AHostApi^.LogMessage);
  Result := AHostApi^.Size >= lRequiredSize;
  if not Result then Exit;
  FillChar(fHost, SizeOf(fHost), 0);
  lCopySize := AHostApi^.Size;
  if lCopySize > SizeOf(fHost) then lCopySize := SizeOf(fHost);
  Move(AHostApi^, fHost, lCopySize);
  fClosing := False;
  UpdateDirectory;
  ReloadScripts;
end;

procedure TLuaCalcPlugin.UpdateDirectory;
var
  lSize: LongInt;
  lBuffer: AnsiString;
begin
  fDirectory := '';
  fProjectDirectory := '';
  if Assigned(fHost.GetProjectDirectory) then
  begin
    lSize := fHost.GetProjectDirectory(fHost.HostContext, nil, 0);
    if lSize > 0 then
    begin
      SetLength(lBuffer, lSize);
      fHost.GetProjectDirectory(fHost.HostContext, PAnsiChar(lBuffer), lSize);
      fProjectDirectory := StrPas(PAnsiChar(lBuffer));
      fDirectory := IncludeTrailingPathDelimiter(fProjectDirectory) + 'LuaCalc';
    end;
  end;
end;

procedure LogValue(AContext: Pointer; const AMessage: UTF8String); cdecl;
var
  lHost: ^TRecorderPluginHostApi;
begin
  lHost := @TLuaCalcPlugin(AContext).fHost;
  if Assigned(lHost^.LogMessage) then
    lHost^.LogMessage(lHost^.HostContext, PAnsiChar(AMessage));
end;

procedure TLuaCalcPlugin.Close;
var
  I: Integer;
begin
  StopDelayedWorkers;
  for I := 0 to fScripts.Count - 1 do
    TLoadedScript(fScripts[I]).Free;
  fScripts.Clear;
end;

procedure TLuaCalcPlugin.ReapDelayedWorkers;
var
  I: Integer;
  lWorker: TDelayedTagValueWorker;
begin
  fDelayedWorkersLock.Acquire;
  try
    for I := fDelayedWorkers.Count - 1 downto 0 do
    begin
      lWorker := TDelayedTagValueWorker(fDelayedWorkers[I]);
      if not lWorker.Finished then Continue;
      fDelayedWorkers.Delete(I);
      lWorker.WaitFor;
      lWorker.Free;
    end;
  finally
    fDelayedWorkersLock.Release;
  end;
end;

procedure TLuaCalcPlugin.StopDelayedWorkers;
var
  I: Integer;
  lWorkers: array of TDelayedTagValueWorker;
begin
  fDelayedWorkersLock.Acquire;
  try
    fClosing := True;
    SetLength(lWorkers, fDelayedWorkers.Count);
    for I := 0 to fDelayedWorkers.Count - 1 do
    begin
      lWorkers[I] := TDelayedTagValueWorker(fDelayedWorkers[I]);
      lWorkers[I].Stop;
    end;
    fDelayedWorkers.Clear;
  finally
    fDelayedWorkersLock.Release;
  end;
  for I := 0 to High(lWorkers) do
  begin
    lWorkers[I].WaitFor;
    lWorkers[I].Free;
  end;
end;

function TLuaCalcPlugin.ScheduleTagValue(const AName: UTF8String; AValue,
  ADelaySeconds: Double): Boolean;
var
  lDelayMilliseconds: Cardinal;
  lWorker: TDelayedTagValueWorker;
begin
  Result := (AName <> '') and not IsNan(ADelaySeconds) and
    not IsInfinite(ADelaySeconds) and (ADelaySeconds >= 0) and
    (ADelaySeconds <= High(Cardinal) / 1000.0);
  if not Result then Exit;
  ReapDelayedWorkers;
  lDelayMilliseconds := Round(ADelaySeconds * 1000.0);
  lWorker := TDelayedTagValueWorker.Create(Self, AName, AValue,
    lDelayMilliseconds);
  fDelayedWorkersLock.Acquire;
  try
    if fClosing then
    begin
      lWorker.Free;
      Exit(False);
    end;
    fDelayedWorkers.Add(lWorker);
    lWorker.Start;
  finally
    fDelayedWorkersLock.Release;
  end;
  Result := True;
end;

function TLuaCalcPlugin.PublishDelayedValue(const AName: UTF8String;
  AValue: Double): Boolean;
begin
  fDelayedWorkersLock.Acquire;
  try
    Result := not fClosing and Assigned(fHost.PublishTagValue);
    if Result then
      Result := fHost.PublishTagValue(fHost.HostContext, PAnsiChar(AName),
        AValue);
  finally
    fDelayedWorkersLock.Release;
  end;
end;

procedure TLuaCalcPlugin.LogError(const AMessage: string);
var
  lLog: TextFile;
begin
  if fDirectory = '' then Exit;
  try
    ForceDirectories(fDirectory);
    AssignFile(lLog, IncludeTrailingPathDelimiter(fDirectory) + 'errors.log');
    if FileExists(IncludeTrailingPathDelimiter(fDirectory) + 'errors.log') then
      Append(lLog)
    else
      Rewrite(lLog);
    try
      WriteLn(lLog, FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), ' ', AMessage);
    finally
      CloseFile(lLog);
    end;
  except
    // The calculation must not interrupt Recorder if diagnostics are read-only.
  end;
end;

procedure TLuaCalcPlugin.ReloadScripts;
var
  lSearch: TSearchRec;
  lScript: TLoadedScript;
  lLines: TStringList;
  lCallbacks: TLuaCalcCallbacks;
  lConfig: TIniFile;
  lConfigName, lName: string;
  I, lCount: Integer;

  procedure LoadScript(const AName: string);
  begin
    if (AName = '') or (ExtractFileName(AName) <> AName) or
      not FileExists(IncludeTrailingPathDelimiter(fDirectory) + AName) then Exit;
    lScript := TLoadedScript.Create;
    lLines := TStringList.Create;
    try
      lScript.Name := AName;
      lScript.Engine := TLuaCalcEngine.Create;
      lScript.Engine.SetCallbacks(lCallbacks);
      lLines.LoadFromFile(IncludeTrailingPathDelimiter(fDirectory) + AName);
      if lScript.Engine.Execute(UTF8String(lLines.Text)) then
      begin
        lScript.Active := True;
        fScripts.Add(lScript);
        lScript := nil;
      end;
      if lScript <> nil then
        LogError(AName + ': ' + lScript.Engine.LastError);
    finally
      lLines.Free;
      lScript.Free;
    end;
  end;
begin
  Close;
  fClosing := False;
  UpdateDirectory;
  if (fDirectory = '') or not DirectoryExists(fDirectory) then Exit;
  lCallbacks := Default(TLuaCalcCallbacks);
  lCallbacks.Context := Self;
  lCallbacks.OnGetValue := @ReadValue;
  lCallbacks.OnGetSample := @ReadSample;
  lCallbacks.OnSetValue := @WriteValue;
  lCallbacks.OnSetDelayedValue := @WriteDelayedValue;
  lCallbacks.OnGetTime := @RecorderTime;
  lCallbacks.OnTagExists := @TagExists;
  lCallbacks.OnGetAlarmLevel := @ReadAlarmLevel;
  lCallbacks.OnGetSetpoint := @ReadSetpoint;
  lCallbacks.OnSetSetpoint := @WriteSetpoint;
  lCallbacks.OnLogMessage := @LogValue;
  lConfigName := IncludeTrailingPathDelimiter(fProjectDirectory) + 'LuaCalc.ini';
  if FileExists(lConfigName) then
  begin
    lConfig := TIniFile.Create(lConfigName);
    try
      if lConfig.ValueExists('LuaCalc', 'ScriptCount') then
      begin
        lCount := lConfig.ReadInteger('LuaCalc', 'ScriptCount', 0);
        for I := 0 to lCount - 1 do
        begin
          lName := lConfig.ReadString('LuaCalc', 'Script' + IntToStr(I), '');
          LoadScript(lName);
        end;
        Exit;
      end;
    finally
      lConfig.Free;
    end;
  end;
  if FindFirst(IncludeTrailingPathDelimiter(fDirectory) + '*.lua',
    faAnyFile, lSearch) <> 0 then Exit;
  try
    repeat
      if (lSearch.Attr and faDirectory) <> 0 then Continue;
      LoadScript(lSearch.Name);
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
end;

procedure TLuaCalcPlugin.RunScripts;
var
  I: Integer;
begin
  for I := 0 to fScripts.Count - 1 do
    if TLoadedScript(fScripts[I]).Active and
      not TLoadedScript(fScripts[I]).Engine.RunMain then
    begin
      TLoadedScript(fScripts[I]).Active := False;
      LogError(TLoadedScript(fScripts[I]).Name + ': ' +
        TLoadedScript(fScripts[I]).Engine.LastError);
    end;
end;

function TLuaCalcPlugin.Notify(AEvent: LongInt): Boolean;
begin
  case AEvent of
    PN_RCLOADCONFIG: ReloadScripts;
    PN_UPDATEDATA: RunScripts;
  end;
  Result := True;
end;

end.
