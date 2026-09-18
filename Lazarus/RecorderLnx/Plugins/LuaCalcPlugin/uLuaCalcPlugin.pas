unit uLuaCalcPlugin;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, IniFiles, uRecorderPluginApi, uLuaCalcEngine;

type
  TLuaCalcPlugin = class
  private
    fHost: TRecorderPluginHostApi;
    fScripts: TList;
    fDirectory: string;
    fProjectDirectory: string;
    procedure UpdateDirectory;
    procedure LogError(const AMessage: string);
    procedure ReloadScripts;
    procedure RunScripts;
  public
    constructor Create;
    destructor Destroy; override;
    function Initialize(AHostApi: PRecorderPluginHostApi): Boolean;
    function Notify(AEvent: LongInt): Boolean;
    procedure Close;
  end;

implementation

type
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

function WriteValue(AContext: Pointer; const AName: UTF8String;
  AValue, ATime: Double; AStatus: LongInt): Boolean; cdecl;
var
  lHost: ^TRecorderPluginHostApi;
begin
  lHost := @TLuaCalcPlugin(AContext).fHost;
  Result := Assigned(lHost^.PublishTagValue) and
    lHost^.PublishTagValue(lHost^.HostContext, PAnsiChar(AName), AValue);
end;

constructor TLuaCalcPlugin.Create;
begin
  inherited Create;
  fScripts := TList.Create;
end;

destructor TLuaCalcPlugin.Destroy;
begin
  Close;
  fScripts.Free;
  inherited Destroy;
end;

function TLuaCalcPlugin.Initialize(AHostApi: PRecorderPluginHostApi): Boolean;
begin
  Result := (AHostApi <> nil) and
    (AHostApi^.Size >= SizeOf(TRecorderPluginHostApi));
  if not Result then Exit;
  fHost := AHostApi^;
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
  for I := 0 to fScripts.Count - 1 do
    TLoadedScript(fScripts[I]).Free;
  fScripts.Clear;
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
  UpdateDirectory;
  if (fDirectory = '') or not DirectoryExists(fDirectory) then Exit;
  lCallbacks := Default(TLuaCalcCallbacks);
  lCallbacks.Context := Self;
  lCallbacks.OnGetValue := @ReadValue;
  lCallbacks.OnSetValue := @WriteValue;
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
