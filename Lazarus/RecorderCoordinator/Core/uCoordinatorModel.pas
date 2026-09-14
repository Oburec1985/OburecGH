unit uCoordinatorModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DateUtils, SyncObjs, fpjson, jsonparser,
  uSharedFileLogger, uCoordinatorHostStore;

type
  TCoordinatorHost = class
  public
    InstanceId: string;
    Address: string;
    HostName: string;
    MacAddress: string;
    ExecutablePath: string;
    OperatingSystem: string;
    MeraFilesPath: string;
    State: string;
    CurrentRecordingId: string;
    CurrentMeasurementPath: string;
    LastSeenUtc: TDateTime;
    LastHttpSeenUtc: TDateTime;
    Managed: Boolean;
    PcReachable: Boolean;
    PcReachabilityKnown: Boolean;
    PcConnectionState: string;
    LastPingUtc: TDateTime;
    AgentReachable: Boolean;
    AgentReachabilityKnown: Boolean;
    AgentConnectionState: string;
    LastAgentSeenUtc: TDateTime;
    function ToJson: TJSONObject;
  end;

  TCoordinatorEvent = class
  public
    EventId: string;
    CorrelationId: string;
    StartedUtc: TDateTime;
    FinishedUtc: TDateTime;
    WindowEndsUtc: TDateTime;
    Recordings: TStringList;
    CompletedRecordings: TStringList;
    constructor Create;
    destructor Destroy; override;
    function ToJson: TJSONObject;
  end;

  TCoordinatorCommand = class
  public
    CommandId: string;
    InstanceId: string;
    CommandName: string;
    CorrelationId: string;
    ExecuteAtUtc: string;
    PayloadJson: string;
    State: string;
    ResultCode: string;
    ResultText: string;
    function ToJson: TJSONObject;
  end;

  TCoordinatorRecordingLifecycle = record
    MessageType: string;
    EventId: string;
    CorrelationId: string;
    RecordingId: string;
    InstanceId: string;
    HostName: string;
    DisplayName: string;
    ProjectName: string;
    State: string;
    LocalPath: string;
    EntryFile: string;
    StartedUtc: TDateTime;
    FinishedUtc: TDateTime;
  end;

  TCoordinatorRecordingLifecycleHandler = function(
    const AInfo: TCoordinatorRecordingLifecycle): string of object;

  TCoordinatorModel = class
  private
    fLock: TCriticalSection;
    fHosts: TFPList;
    fEvents: TFPList;
    fCommands: TFPList;
    fDiagnostics: TStringList;
    fHostStore: TCoordinatorHostStore;
    fIgnoredHosts: TFPList;
    fIgnoredHostsFileName: string;
    procedure AddDiagnosticLocked(const AText: string);
    function FindHost(const AInstanceId: string): TCoordinatorHost;
    function FindHostByAddress(const AAddress: string): TCoordinatorHost;
    function FindHostByMac(const AMacAddress: string): TCoordinatorHost;
    procedure MergeHost(AHost, AAlias: TCoordinatorHost);
    function MergeNamedIdentityAlias(AHost: TCoordinatorHost): TCoordinatorHost;
    function MergeHostAliases(AHost: TCoordinatorHost;
      const AAddress, AMacAddress: string): Boolean;
    function FindOpenEvent(const AStartedUtc: TDateTime): TCoordinatorEvent;
    function FindEventByRecording(
      const ARecordingId: string): TCoordinatorEvent;
    function FindCommand(const ACommandId: string): TCoordinatorCommand;
    function HasActiveStartCommand(const AInstanceId: string): Boolean;
    function EnqueuePeerRecordingStarts(const AInitiatorId: string): Integer;
    function NewId: string;
    procedure LoadStoredHosts;
    procedure LoadIgnoredHostsLocked;
    procedure MergeStoredIdentityAliases;
    procedure SaveHostsLocked;
    procedure SaveIgnoredHostsLocked;
    function IsHostIgnored(const AInstanceId, AAddress,
      AMacAddress: string): Boolean;
  public
    EventWindowSec: Integer;
    CreateRecordingEvents: Boolean;
    StartAllOnAnyRecording: Boolean;
    OnRecordingLifecycle: TCoordinatorRecordingLifecycleHandler;
    constructor Create;
    destructor Destroy; override;
    procedure EnableHostPersistence(const AFileName: string = '');
    function RegisterHello(AData: TJSONObject): TJSONObject;
    function RegisterDiscovery(AData: TJSONObject): TJSONObject;
    function ApplyHeartbeat(AData: TJSONObject): TJSONObject;
    function AddRecordingEvent(AData: TJSONObject): TJSONObject;
    function EnqueueCommand(AData: TJSONObject): TJSONObject;
    function NextCommand(const AInstanceId: string): TJSONObject;
    function CompleteCommand(AData: TJSONObject): TJSONObject;
    function CurrentRecording(const AInstanceId: string): TJSONObject;
    function HostsJson: TJSONArray;
    function HostByIdJson(const AInstanceId: string): TJSONObject;
    function HostByAddressJson(const AAddress: string): TJSONObject;
    function SetHostDisplayName(const AInstanceId,
      ADisplayName: string): Boolean;
    function SetHostAddress(const AInstanceId, AAddress: string): Boolean;
    function IgnoreHost(const AInstanceId: string): Boolean;
    procedure ClearHostMeraFilesPaths;
    function HostProbeTargets: TJSONArray;
    procedure MarkPcReachabilityChecking(const AAddress: string);
    procedure ApplyPcReachability(const AAddress: string;
      AReachable: Boolean; ACheckedUtc: TDateTime);
    function ApplyAgentStatus(const AAddress: string;
      AStatus: TJSONObject): TJSONObject;
    procedure MarkAgentReachabilityChecking(const AAddress: string);
    procedure ApplyAgentReachability(const AAddress: string;
      AReachable: Boolean; ACheckedUtc: TDateTime);
    procedure ApplyAgentUnavailable(const AAddress: string;
      ACheckedUtc: TDateTime);
    function EventsJson: TJSONArray;
    function StatusJson: TJSONObject;
    procedure DrainDiagnostics(ATarget: TStrings);
  end;

function JsonDateTime(const AValue: TDateTime): string;
function ParseJsonDateTime(const AValue: string; const ADefault: TDateTime): TDateTime;

implementation

uses IniFiles;

function IsUuidLike(const AValue: string): Boolean; forward;
function IsUsableHostAddress(const AValue: string): Boolean; forward;
function NormalizedAddress(const AValue: string): string; forward;
function NormalizedMacAddress(const AValue: string): string; forward;

function JsonDateTime(const AValue: TDateTime): string;
begin
  Result := FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss"."zzz', AValue) + 'Z';
end;

function ParseJsonDateTime(const AValue: string; const ADefault: TDateTime): TDateTime;
var
  lValue: string;
begin
  Result := ADefault;
  lValue := StringReplace(AValue, 'T', ' ', []);
  lValue := StringReplace(lValue, 'Z', '', []);
  if lValue = '' then Exit;
  TryISO8601ToDate(AValue, Result, True);
end;

function JsonString(AData: TJSONObject; const AName, ADefault: string): string;
var
  lItem, lPayload: TJSONData;
begin
  lItem := AData.Find(AName);
  if lItem = nil then
  begin
    lPayload := AData.Find('payload');
    if lPayload is TJSONObject then
      lItem := TJSONObject(lPayload).Find(AName);
  end;
  if (lItem = nil) or (lItem.JSONType in [jtObject, jtArray]) then
    Result := ADefault
  else
    Result := lItem.AsString;
end;

function JsonBoolean(AData: TJSONObject; const AName: string;
  ADefault: Boolean): Boolean;
var
  lItem: TJSONData;
begin
  lItem := AData.Find(AName);
  if lItem = nil then
    Exit(ADefault);
  Result := lItem.AsBoolean;
end;

function NormalizeCorrelationId(const AValue: string): string;
begin
  Result := Trim(AValue);
  if (Length(Result) = 38) and (Result[1] = '{') and
    (Result[Length(Result)] = '}') then
    Result := Copy(Result, 2, 36);
  { The SQL contract stores UUID-compatible correlation ids in varchar(36).
    Never pass an oversized external value to Firebird. }
  if Length(Result) > 36 then Result := '';
end;

function JsonPayloadObject(AData: TJSONObject; const AName: string): TJSONObject;
var
  lPayload, lItem: TJSONData;
begin
  Result := nil;
  lPayload := AData.Find('payload');
  if not (lPayload is TJSONObject) then Exit;
  lItem := TJSONObject(lPayload).Find(AName);
  if lItem is TJSONObject then Result := TJSONObject(lItem);
end;

function TCoordinatorHost.ToJson: TJSONObject;
const
  CHostOfflineAfterSec = 10;
var
  lLegacyReachable: Boolean;
  lRecorderReachable: Boolean;
  lEffectiveState: string;
begin
  lRecorderReachable := (LastHttpSeenUtc <> 0) and
    (SecondsBetween(Now, LastHttpSeenUtc) <= CHostOfflineAfterSec);
  lLegacyReachable := (LastSeenUtc <> 0) and
    (SecondsBetween(Now, LastSeenUtc) <= CHostOfflineAfterSec);
  if not lLegacyReachable then
    lEffectiveState := 'offline'
  else
    lEffectiveState := State;
  Result := TJSONObject.Create;
  Result.Add('instance_id', InstanceId);
  Result.Add('address', Address);
  Result.Add('host_name', HostName);
  Result.Add('mac_address', MacAddress);
  Result.Add('executable_path', ExecutablePath);
  Result.Add('os', OperatingSystem);
  Result.Add('mera_files_path', MeraFilesPath);
  Result.Add('state', lEffectiveState);
  Result.Add('recorder_state', State);
  Result.Add('recorder_reachable', lRecorderReachable);
  Result.Add('agent_reachable', AgentReachable);
  Result.Add('agent_reachability_known', AgentReachabilityKnown);
  if AgentConnectionState = '' then
    Result.Add('agent_connection_state', 'unknown')
  else
    Result.Add('agent_connection_state', AgentConnectionState);
  if LastAgentSeenUtc <> 0 then
    Result.Add('last_agent_seen_utc', JsonDateTime(LastAgentSeenUtc))
  else
    Result.Add('last_agent_seen_utc', '');
  Result.Add('pc_reachable', PcReachable);
  Result.Add('pc_reachability_known', PcReachabilityKnown);
  if PcConnectionState = '' then
    Result.Add('pc_connection_state', 'unknown')
  else
    Result.Add('pc_connection_state', PcConnectionState);
  if LastPingUtc <> 0 then
    Result.Add('last_ping_utc', JsonDateTime(LastPingUtc))
  else
    Result.Add('last_ping_utc', '');
  Result.Add('runtime_state', State);
  Result.Add('last_seen_utc', JsonDateTime(LastSeenUtc));
  Result.Add('current_recording_id', CurrentRecordingId);
  Result.Add('measurement_path', CurrentMeasurementPath);
  Result.Add('managed', Managed);
end;

constructor TCoordinatorEvent.Create;
begin
  inherited Create;
  Recordings := TStringList.Create;
  CompletedRecordings := TStringList.Create;
end;

destructor TCoordinatorEvent.Destroy;
begin
  CompletedRecordings.Free;
  Recordings.Free;
  inherited Destroy;
end;

function TCoordinatorEvent.ToJson: TJSONObject;
var
  lItems: TJSONArray;
  lIndex: Integer;
begin
  Result := TJSONObject.Create;
  Result.Add('event_id', EventId);
  Result.Add('correlation_id', CorrelationId);
  Result.Add('started_utc', JsonDateTime(StartedUtc));
  if FinishedUtc <> 0 then
    Result.Add('finished_utc', JsonDateTime(FinishedUtc))
  else
    Result.Add('finished_utc', '');
  Result.Add('window_ends_utc', JsonDateTime(WindowEndsUtc));
  lItems := TJSONArray.Create;
  for lIndex := 0 to Recordings.Count - 1 do lItems.Add(Recordings[lIndex]);
  Result.Add('recording_ids', lItems);
  lItems := TJSONArray.Create;
  for lIndex := 0 to CompletedRecordings.Count - 1 do
    lItems.Add(CompletedRecordings[lIndex]);
  Result.Add('completed_recording_ids', lItems);
  if (Recordings.Count > 0) and
    (CompletedRecordings.Count >= Recordings.Count) then
    Result.Add('state', 'completed')
  else
    Result.Add('state', 'active');
end;

function TCoordinatorCommand.ToJson: TJSONObject;
var
  lPayload: TJSONData;
begin
  Result := TJSONObject.Create;
  Result.Add('command_id', CommandId);
  Result.Add('instance_id', InstanceId);
  Result.Add('command', CommandName);
  Result.Add('command_type', CommandName);
  Result.Add('correlation_id', CorrelationId);
  Result.Add('execute_at_utc', ExecuteAtUtc);
  try
    lPayload := GetJSON(PayloadJson);
  except
    lPayload := TJSONObject.Create;
  end;
  Result.Add('payload', lPayload);
  Result.Add('state', State);
  Result.Add('result_code', ResultCode);
  Result.Add('result_text', ResultText);
end;

constructor TCoordinatorModel.Create;
begin
  inherited Create;
  fLock := TCriticalSection.Create;
  fHosts := TFPList.Create;
  fEvents := TFPList.Create;
  fCommands := TFPList.Create;
  fDiagnostics := TStringList.Create;
  fIgnoredHosts := TFPList.Create;
  EventWindowSec := 30;
  CreateRecordingEvents := True;
  StartAllOnAnyRecording := False;
end;

destructor TCoordinatorModel.Destroy;
var
  lIndex: Integer;
begin
  for lIndex := 0 to fHosts.Count - 1 do TObject(fHosts[lIndex]).Free;
  for lIndex := 0 to fEvents.Count - 1 do TObject(fEvents[lIndex]).Free;
  for lIndex := 0 to fCommands.Count - 1 do TObject(fCommands[lIndex]).Free;
  for lIndex := 0 to fIgnoredHosts.Count - 1 do
    TObject(fIgnoredHosts[lIndex]).Free;
  fCommands.Free;
  fIgnoredHosts.Free;
  fHostStore.Free;
  fDiagnostics.Free;
  fEvents.Free;
  fHosts.Free;
  fLock.Free;
  inherited Destroy;
end;

procedure TCoordinatorModel.LoadStoredHosts;
var
  lHost: TCoordinatorHost;
  lHosts: TCoordinatorStoredHosts;
  lAddress: string;
  lIndex: Integer;
begin
  lHosts := nil;
  try
    lHosts := fHostStore.Load;
    for lIndex := 0 to High(lHosts) do
    begin
      if Trim(lHosts[lIndex].InstanceId) = '' then Continue;
      lHost := FindHost(lHosts[lIndex].InstanceId);
      lAddress := Trim(lHosts[lIndex].Address);
      if not IsUsableHostAddress(lAddress) then lAddress := '';
      if (lAddress = '') and
        IsUsableHostAddress(lHosts[lIndex].InstanceId) then
        lAddress := Trim(lHosts[lIndex].InstanceId);
      if IsHostIgnored(lHosts[lIndex].InstanceId, lAddress,
        lHosts[lIndex].MacAddress) then
        Continue;
      if lHost = nil then lHost := FindHostByAddress(lAddress);
      if lHost = nil then lHost := FindHostByMac(lHosts[lIndex].MacAddress);
      if lHost = nil then
      begin
        lHost := TCoordinatorHost.Create;
        lHost.InstanceId := lHosts[lIndex].InstanceId;
        fHosts.Add(lHost);
      end;
      { A stored row with a separate address contains the Recorder identity.
        An address-only row is only a manually configured alias. }
      if IsUsableHostAddress(lHosts[lIndex].Address) then
        lHost.InstanceId := lHosts[lIndex].InstanceId;
      if (lHost.Address = '') and (lAddress <> '') then
        lHost.Address := lAddress;
      if (lHost.HostName = '') and (Trim(lHosts[lIndex].HostName) <> '') then
        lHost.HostName := lHosts[lIndex].HostName;
      if (lHost.MacAddress = '') and (Trim(lHosts[lIndex].MacAddress) <> '') then
        lHost.MacAddress := lHosts[lIndex].MacAddress;
      if (lHost.ExecutablePath = '') and
        (Trim(lHosts[lIndex].ExecutablePath) <> '') then
        lHost.ExecutablePath := lHosts[lIndex].ExecutablePath;
      if (lHost.OperatingSystem = '') and
        (Trim(lHosts[lIndex].OperatingSystem) <> '') then
        lHost.OperatingSystem := lHosts[lIndex].OperatingSystem;
      if (lHost.MeraFilesPath = '') and
        (Trim(lHosts[lIndex].MeraFilesPath) <> '') then
        lHost.MeraFilesPath := lHosts[lIndex].MeraFilesPath;
      if (lHost.State = '') and (Trim(lHosts[lIndex].RecorderState) <> '') then
        lHost.State := lHosts[lIndex].RecorderState;
      lHost.Managed := lHost.Managed or lHosts[lIndex].Managed;
      MergeHostAliases(lHost, lAddress, lHosts[lIndex].MacAddress);
    end;
    MergeStoredIdentityAliases;
  except
    on E: Exception do
      AddDiagnosticLocked('Host registry load failed: ' + E.Message);
  end;
end;

procedure TCoordinatorModel.MergeStoredIdentityAliases;
var
  lAddressHost, lIdentityHost: TCoordinatorHost;
  lLeft, lRight: Integer;
begin
  for lLeft := fHosts.Count - 1 downto 0 do
    for lRight := lLeft - 1 downto 0 do
    begin
      lIdentityHost := TCoordinatorHost(fHosts[lLeft]);
      lAddressHost := TCoordinatorHost(fHosts[lRight]);
      if (Trim(lIdentityHost.HostName) = '') or
        (not SameText(lIdentityHost.HostName, lAddressHost.HostName)) then
        Continue;
      if IsUuidLike(lAddressHost.InstanceId) and
        IsUsableHostAddress(lIdentityHost.Address) then
      begin
        lIdentityHost := lAddressHost;
        lAddressHost := TCoordinatorHost(fHosts[lLeft]);
      end
      else if not (IsUuidLike(lIdentityHost.InstanceId) and
        IsUsableHostAddress(lAddressHost.Address)) then
        Continue;
      { A persisted UUID row and one address row with the same explicit host
        name are complementary identities of one PC.  UUID stays canonical. }
      MergeHost(lIdentityHost, lAddressHost);
      Break;
    end;
end;

procedure TCoordinatorModel.EnableHostPersistence(const AFileName: string);
var
  lFileName: string;
begin
  lFileName := Trim(AFileName);
  if lFileName = '' then lFileName := DefaultCoordinatorHostStoreFile;
  fLock.Acquire;
  try
    FreeAndNil(fHostStore);
    fHostStore := TCoordinatorHostStore.Create(lFileName);
    fIgnoredHostsFileName := IncludeTrailingPathDelimiter(
      ExtractFileDir(lFileName)) + 'ignored-hosts.ini';
    LoadIgnoredHostsLocked;
    LoadStoredHosts;
    SaveHostsLocked;
  finally
    fLock.Release;
  end;
end;

procedure TCoordinatorModel.LoadIgnoredHostsLocked;
var
  lHost: TCoordinatorHost;
  lCount, lIndex: Integer;
  lIni: TIniFile;
  lSection: string;
begin
  for lIndex := 0 to fIgnoredHosts.Count - 1 do
    TObject(fIgnoredHosts[lIndex]).Free;
  fIgnoredHosts.Clear;
  if not FileExists(fIgnoredHostsFileName) then Exit;
  lIni := TIniFile.Create(fIgnoredHostsFileName);
  try
    lCount := lIni.ReadInteger('ignored_hosts', 'count', 0);
    for lIndex := 0 to lCount - 1 do
    begin
      lSection := 'ignored_host.' + IntToStr(lIndex);
      lHost := TCoordinatorHost.Create;
      lHost.InstanceId := lIni.ReadString(lSection, 'id', '');
      lHost.Address := lIni.ReadString(lSection, 'address', '');
      lHost.HostName := lIni.ReadString(lSection, 'name', '');
      lHost.MacAddress := lIni.ReadString(lSection, 'mac', '');
      if (Trim(lHost.InstanceId) = '') and (Trim(lHost.Address) = '') and
        (Trim(lHost.MacAddress) = '') then
        lHost.Free
      else
        fIgnoredHosts.Add(lHost);
    end;
  finally
    lIni.Free;
  end;
end;

procedure TCoordinatorModel.SaveIgnoredHostsLocked;
var
  lHost: TCoordinatorHost;
  lIndex: Integer;
  lIni: TIniFile;
  lSection: string;
begin
  if fIgnoredHostsFileName = '' then Exit;
  ForceDirectories(ExtractFileDir(fIgnoredHostsFileName));
  lIni := TIniFile.Create(fIgnoredHostsFileName);
  try
    lIni.EraseSection('ignored_hosts');
    lIni.WriteInteger('ignored_hosts', 'count', fIgnoredHosts.Count);
    for lIndex := 0 to fIgnoredHosts.Count - 1 do
    begin
      lHost := TCoordinatorHost(fIgnoredHosts[lIndex]);
      lSection := 'ignored_host.' + IntToStr(lIndex);
      lIni.EraseSection(lSection);
      lIni.WriteString(lSection, 'id', lHost.InstanceId);
      lIni.WriteString(lSection, 'address', lHost.Address);
      lIni.WriteString(lSection, 'name', lHost.HostName);
      lIni.WriteString(lSection, 'mac', lHost.MacAddress);
    end;
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
end;

function TCoordinatorModel.IsHostIgnored(const AInstanceId, AAddress,
  AMacAddress: string): Boolean;
var
  lHost: TCoordinatorHost;
  lIndex: Integer;
begin
  Result := False;
  for lIndex := 0 to fIgnoredHosts.Count - 1 do
  begin
    lHost := TCoordinatorHost(fIgnoredHosts[lIndex]);
    if ((Trim(AInstanceId) <> '') and
        SameText(Trim(lHost.InstanceId), Trim(AInstanceId))) or
       ((Trim(AAddress) <> '') and
        SameText(NormalizedAddress(lHost.Address),
          NormalizedAddress(AAddress))) or
       ((NormalizedMacAddress(AMacAddress) <> '') and
        (NormalizedMacAddress(lHost.MacAddress) =
          NormalizedMacAddress(AMacAddress))) then
      Exit(True);
  end;
end;

procedure TCoordinatorModel.SaveHostsLocked;
var
  lHost: TCoordinatorHost;
  lHosts: TCoordinatorStoredHosts;
  lIndex: Integer;
begin
  if fHostStore = nil then Exit;
  lHosts := nil;
  SetLength(lHosts, fHosts.Count);
  for lIndex := 0 to fHosts.Count - 1 do
  begin
    lHost := TCoordinatorHost(fHosts[lIndex]);
    lHosts[lIndex].InstanceId := lHost.InstanceId;
    lHosts[lIndex].Address := lHost.Address;
    lHosts[lIndex].HostName := lHost.HostName;
    lHosts[lIndex].MacAddress := lHost.MacAddress;
    lHosts[lIndex].ExecutablePath := lHost.ExecutablePath;
    lHosts[lIndex].OperatingSystem := lHost.OperatingSystem;
    lHosts[lIndex].MeraFilesPath := lHost.MeraFilesPath;
    lHosts[lIndex].RecorderState := lHost.State;
    lHosts[lIndex].Managed := lHost.Managed;
  end;
  try
    fHostStore.Save(lHosts);
  except
    on E: Exception do
      AddDiagnosticLocked('Host registry save failed: ' + E.Message);
  end;
end;

procedure TCoordinatorModel.AddDiagnosticLocked(const AText: string);
begin
  fDiagnostics.Add(AText);
  SharedLogger.Info('Coordinator diagnostic ' + AText);
end;

procedure TCoordinatorModel.DrainDiagnostics(ATarget: TStrings);
begin
  if ATarget = nil then Exit;
  fLock.Acquire;
  try
    ATarget.AddStrings(fDiagnostics);
    fDiagnostics.Clear;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.NewId: string;
var
  lId: TGuid;
begin
  CreateGUID(lId);
  Result := GUIDToString(lId);
  Result := StringReplace(Result, '{', '', []);
  Result := StringReplace(Result, '}', '', []);
end;

function TCoordinatorModel.FindHost(const AInstanceId: string): TCoordinatorHost;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to fHosts.Count - 1 do
    if SameText(TCoordinatorHost(fHosts[lIndex]).InstanceId, AInstanceId) then
      Exit(TCoordinatorHost(fHosts[lIndex]));
end;

function NormalizedAddress(const AValue: string): string;
var
  lComputerName: string;
begin
  Result := LowerCase(Trim(AValue));
  if (Length(Result) > 2) and (Result[1] = '[') and
    (Result[Length(Result)] = ']') then
    Result := Copy(Result, 2, Length(Result) - 2);
  if Pos('::ffff:', Result) = 1 then
    Delete(Result, 1, Length('::ffff:'));
  lComputerName := LowerCase(Trim(GetEnvironmentVariable('COMPUTERNAME')));
  if (Result = '127.0.0.1') or (Result = '::1') or
    (Result = 'localhost') or ((lComputerName <> '') and
    SameText(Result, lComputerName)) then
    Result := '<local>';
end;

function IsUuidLike(const AValue: string): Boolean;
var
  lChar: Char;
  lIndex: Integer;
  lValue: string;
begin
  lValue := Trim(AValue);
  if (Length(lValue) = 38) and (lValue[1] = '{') and
    (lValue[38] = '}') then
    lValue := Copy(lValue, 2, 36);
  Result := Length(lValue) = 36;
  if not Result then Exit;
  for lIndex := 1 to Length(lValue) do
  begin
    lChar := lValue[lIndex];
    if lIndex in [9, 14, 19, 24] then
    begin
      if lChar <> '-' then Exit(False);
    end
    else if not (lChar in ['0'..'9', 'a'..'f', 'A'..'F']) then
      Exit(False);
  end;
end;

function IsUsableHostAddress(const AValue: string): Boolean;
var
  lValue: string;
begin
  lValue := Trim(AValue);
  Result := (lValue <> '') and (not IsUuidLike(lValue)) and
    (Pos(' ', lValue) = 0) and (Pos('/', lValue) = 0) and
    (Pos('\\', lValue) = 0);
end;

function NormalizedMacAddress(const AValue: string): string;
begin
  Result := LowerCase(Trim(AValue));
  Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  Result := StringReplace(Result, ':', '', [rfReplaceAll]);
  Result := StringReplace(Result, '.', '', [rfReplaceAll]);
end;

function StableHostId(const AInstanceId, AAddress, AMacAddress: string): string;
begin
  Result := Trim(AInstanceId);
  if Result <> '' then Exit;
  if NormalizedMacAddress(AMacAddress) <> '' then
    Exit('mac-' + NormalizedMacAddress(AMacAddress));
  Result := LowerCase(Trim(AAddress));
end;

function IncomingIdentityIsPreferred(const ACurrentId,
  AIncomingId: string): Boolean;
begin
  Result := IsUuidLike(AIncomingId) or not IsUuidLike(ACurrentId);
end;

function IsHexMac(const AValue: string): Boolean;
var
  lChar: Char;
begin
  Result := Length(AValue) = 12;
  if not Result then Exit;
  for lChar in AValue do
    if not (lChar in ['0'..'9', 'a'..'f']) then Exit(False);
end;

function CanonicalMacAddress(const AValue: string): string;
var
  lIndex: Integer;
  lMac: string;
begin
  Result := '';
  lMac := NormalizedMacAddress(AValue);
  if not IsHexMac(lMac) then Exit;
  for lIndex := 0 to 5 do
  begin
    if Result <> '' then Result := Result + ':';
    Result := Result + UpperCase(Copy(lMac, lIndex * 2 + 1, 2));
  end;
end;

function JsonMacAddress(AData: TJSONObject): string;
var
  lCandidate, lValues: string;
  lIndex: Integer;
  lItems: TStringList;
begin
  Result := CanonicalMacAddress(JsonString(AData, 'mac_address',
    JsonString(AData, 'mac', '')));
  if Result <> '' then Exit;
  lValues := JsonString(AData, 'mac_addresses', '');
  lValues := StringReplace(lValues, #13, ' ', [rfReplaceAll]);
  lValues := StringReplace(lValues, #10, ' ', [rfReplaceAll]);
  lValues := StringReplace(lValues, ',', ' ', [rfReplaceAll]);
  lValues := StringReplace(lValues, ';', ' ', [rfReplaceAll]);
  lItems := TStringList.Create;
  try
    lItems.Delimiter := ' ';
    lItems.StrictDelimiter := False;
    lItems.DelimitedText := lValues;
    for lIndex := 0 to lItems.Count - 1 do
    begin
      lCandidate := CanonicalMacAddress(lItems[lIndex]);
      if lCandidate <> '' then Exit(lCandidate);
    end;
  finally
    lItems.Free;
  end;
end;

function TCoordinatorModel.FindHostByAddress(
  const AAddress: string): TCoordinatorHost;
var
  lHost: TCoordinatorHost;
  lIndex: Integer;
begin
  Result := nil;
  if not IsUsableHostAddress(AAddress) then Exit;
  for lIndex := 0 to fHosts.Count - 1 do
  begin
    lHost := TCoordinatorHost(fHosts[lIndex]);
    if (IsUsableHostAddress(lHost.Address) and
        (NormalizedAddress(lHost.Address) = NormalizedAddress(AAddress))) or
      (IsUsableHostAddress(lHost.InstanceId) and
       (NormalizedAddress(lHost.InstanceId) = NormalizedAddress(AAddress))) then
      Exit(lHost);
  end;
end;

function TCoordinatorModel.FindHostByMac(
  const AMacAddress: string): TCoordinatorHost;
var
  lIndex: Integer;
  lMacAddress: string;
begin
  Result := nil;
  lMacAddress := NormalizedMacAddress(AMacAddress);
  if lMacAddress = '' then Exit;
  for lIndex := 0 to fHosts.Count - 1 do
    if NormalizedMacAddress(TCoordinatorHost(fHosts[lIndex]).MacAddress) =
      lMacAddress then
      Exit(TCoordinatorHost(fHosts[lIndex]));
end;

procedure TCoordinatorModel.MergeHost(AHost, AAlias: TCoordinatorHost);
var
  lIndex: Integer;
  lOldId: string;
begin
  if (AHost = nil) or (AAlias = nil) or (AHost = AAlias) then Exit;
  lOldId := AAlias.InstanceId;
  if AAlias.LastHttpSeenUtc > AHost.LastHttpSeenUtc then
  begin
    AHost.Address := AAlias.Address;
    AHost.State := AAlias.State;
    AHost.LastHttpSeenUtc := AAlias.LastHttpSeenUtc;
  end
  else if AHost.Address = '' then
    AHost.Address := AAlias.Address;
  if AAlias.LastSeenUtc > AHost.LastSeenUtc then
    AHost.LastSeenUtc := AAlias.LastSeenUtc;
  if AHost.HostName = '' then AHost.HostName := AAlias.HostName;
  if AHost.MacAddress = '' then AHost.MacAddress := AAlias.MacAddress;
  if AHost.ExecutablePath = '' then
    AHost.ExecutablePath := AAlias.ExecutablePath;
  if AHost.OperatingSystem = '' then
    AHost.OperatingSystem := AAlias.OperatingSystem;
  if AHost.MeraFilesPath = '' then
    AHost.MeraFilesPath := AAlias.MeraFilesPath;
  if AHost.CurrentRecordingId = '' then
    AHost.CurrentRecordingId := AAlias.CurrentRecordingId;
  if AHost.CurrentMeasurementPath = '' then
    AHost.CurrentMeasurementPath := AAlias.CurrentMeasurementPath;
  AHost.Managed := AHost.Managed or AAlias.Managed;
  if AAlias.PcReachabilityKnown and
    ((not AHost.PcReachabilityKnown) or (AAlias.LastPingUtc > AHost.LastPingUtc)) then
  begin
    AHost.PcReachable := AAlias.PcReachable;
    AHost.PcReachabilityKnown := True;
    AHost.PcConnectionState := AAlias.PcConnectionState;
    AHost.LastPingUtc := AAlias.LastPingUtc;
  end;
  if (AHost.PcConnectionState = '') and
    (AAlias.PcConnectionState <> '') then
    AHost.PcConnectionState := AAlias.PcConnectionState;
  if AAlias.AgentReachabilityKnown and
    ((not AHost.AgentReachabilityKnown) or
     (AAlias.LastAgentSeenUtc > AHost.LastAgentSeenUtc)) then
  begin
    AHost.AgentReachable := AAlias.AgentReachable;
    AHost.AgentReachabilityKnown := True;
    AHost.AgentConnectionState := AAlias.AgentConnectionState;
    AHost.LastAgentSeenUtc := AAlias.LastAgentSeenUtc;
  end;
  if (AHost.AgentConnectionState = '') and
    (AAlias.AgentConnectionState <> '') then
    AHost.AgentConnectionState := AAlias.AgentConnectionState;
  for lIndex := 0 to fCommands.Count - 1 do
    if SameText(TCoordinatorCommand(fCommands[lIndex]).InstanceId, lOldId) then
      TCoordinatorCommand(fCommands[lIndex]).InstanceId := AHost.InstanceId;
  fHosts.Remove(AAlias);
  AAlias.Free;
end;

function TCoordinatorModel.MergeNamedIdentityAlias(
  AHost: TCoordinatorHost): TCoordinatorHost;
var
  lAlias, lIdentityHost: TCoordinatorHost;
  lIndex: Integer;
begin
  Result := AHost;
  if (AHost = nil) or (Trim(AHost.HostName) = '') then Exit;
  for lIndex := fHosts.Count - 1 downto 0 do
  begin
    lAlias := TCoordinatorHost(fHosts[lIndex]);
    if (lAlias = AHost) or (Trim(lAlias.HostName) = '') or
      (not SameText(lAlias.HostName, AHost.HostName)) then
      Continue;
    lIdentityHost := nil;
    if IsUuidLike(AHost.InstanceId) and
      (not IsUsableHostAddress(AHost.Address)) and
      IsUsableHostAddress(lAlias.Address) then
      lIdentityHost := AHost
    else if IsUuidLike(lAlias.InstanceId) and
      (not IsUsableHostAddress(lAlias.Address)) and
      IsUsableHostAddress(AHost.Address) then
      lIdentityHost := lAlias;
    if lIdentityHost = nil then Continue;
    if lIdentityHost = AHost then
      MergeHost(AHost, lAlias)
    else
    begin
      MergeHost(lIdentityHost, AHost);
      Result := lIdentityHost;
    end;
    Exit;
  end;
end;

function TCoordinatorModel.MergeHostAliases(AHost: TCoordinatorHost;
  const AAddress, AMacAddress: string): Boolean;
var
  lAlias: TCoordinatorHost;
  lIndex: Integer;
begin
  Result := False;
  if AHost = nil then Exit;
  for lIndex := fHosts.Count - 1 downto 0 do
  begin
    lAlias := TCoordinatorHost(fHosts[lIndex]);
    if lAlias = AHost then Continue;
    if (IsUsableHostAddress(AAddress) and
        ((IsUsableHostAddress(lAlias.Address) and
          (NormalizedAddress(lAlias.Address) = NormalizedAddress(AAddress))) or
         (IsUsableHostAddress(lAlias.InstanceId) and
          (NormalizedAddress(lAlias.InstanceId) =
           NormalizedAddress(AAddress))))) or
       ((NormalizedMacAddress(AMacAddress) <> '') and
        (NormalizedMacAddress(lAlias.MacAddress) =
         NormalizedMacAddress(AMacAddress))) then
    begin
      MergeHost(AHost, lAlias);
      Result := True;
    end;
  end;
end;

function TCoordinatorModel.FindOpenEvent(const AStartedUtc: TDateTime): TCoordinatorEvent;
var
  lIndex: Integer;
  lEvent: TCoordinatorEvent;
begin
  Result := nil;
  for lIndex := fEvents.Count - 1 downto 0 do
  begin
    lEvent := TCoordinatorEvent(fEvents[lIndex]);
    if (AStartedUtc >= lEvent.StartedUtc) and
      (AStartedUtc < lEvent.WindowEndsUtc) then
      Exit(lEvent);
  end;
end;

function TCoordinatorModel.FindEventByRecording(
  const ARecordingId: string): TCoordinatorEvent;
var
  lIndex: Integer;
begin
  Result := nil;
  if ARecordingId = '' then Exit;
  for lIndex := fEvents.Count - 1 downto 0 do
    if TCoordinatorEvent(fEvents[lIndex]).Recordings.IndexOf(
      ARecordingId) >= 0 then
      Exit(TCoordinatorEvent(fEvents[lIndex]));
end;

function TCoordinatorModel.FindCommand(const ACommandId: string): TCoordinatorCommand;
var
  lIndex: Integer;
begin
  Result := nil;
  for lIndex := 0 to fCommands.Count - 1 do
    if SameText(TCoordinatorCommand(fCommands[lIndex]).CommandId, ACommandId) then
      Exit(TCoordinatorCommand(fCommands[lIndex]));
end;

function TCoordinatorModel.HasActiveStartCommand(
  const AInstanceId: string): Boolean;
var
  lIndex: Integer;
  lCommand: TCoordinatorCommand;
begin
  Result := False;
  for lIndex := 0 to fCommands.Count - 1 do
  begin
    lCommand := TCoordinatorCommand(fCommands[lIndex]);
    if SameText(lCommand.InstanceId, AInstanceId) and
      SameText(lCommand.CommandName, 'recording.start') and
      ((lCommand.State = 'pending') or (lCommand.State = 'accepted')) then
      Exit(True);
  end;
end;

function TCoordinatorModel.EnqueuePeerRecordingStarts(
  const AInitiatorId: string): Integer;
var
  lIndex, lQueuedCount: Integer;
  lCorrelation: string;
  lHost: TCoordinatorHost;
  lCommand: TCoordinatorCommand;
begin
  lCorrelation := NewId;
  lQueuedCount := 0;
  for lIndex := 0 to fHosts.Count - 1 do
  begin
    lHost := TCoordinatorHost(fHosts[lIndex]);
    if (not lHost.Managed) or (lHost.LastSeenUtc = 0) or
      (SecondsBetween(Now, lHost.LastSeenUtc) > 10) or
      SameText(lHost.InstanceId, AInitiatorId) or
      SameText(lHost.State, 'recording') or
      HasActiveStartCommand(lHost.InstanceId) then
      Continue;
    lCommand := TCoordinatorCommand.Create;
    lCommand.CommandId := NewId;
    lCommand.InstanceId := lHost.InstanceId;
    lCommand.CommandName := 'recording.start';
    lCommand.CorrelationId := lCorrelation;
    lCommand.State := 'pending';
    fCommands.Add(lCommand);
    Inc(lQueuedCount);
  end;
  SharedLogger.Info(Format(
    'Auto-start peers initiator=%s correlation=%s queued=%d',
    [AInitiatorId, lCorrelation, lQueuedCount]));
  Result := lQueuedCount;
end;

function TCoordinatorModel.RegisterHello(AData: TJSONObject): TJSONObject;
var
  lHost, lAlias, lMacAlias: TCoordinatorHost;
  lAddress, lId, lMacAddress: string;
  lIndex: Integer;
  lHasRemoteAddress: Boolean;
  lPersistNeeded: Boolean;
begin
  lAddress := JsonString(AData, 'remote_address', '');
  lHasRemoteAddress := IsUsableHostAddress(lAddress);
  if not IsUsableHostAddress(lAddress) then lAddress := '';
  if (lAddress = '') and
    IsUsableHostAddress(JsonString(AData, 'instance_id', '')) then
    lAddress := JsonString(AData, 'instance_id', '');
  lMacAddress := JsonMacAddress(AData);
  lId := StableHostId(JsonString(AData, 'instance_id', ''), lAddress,
    lMacAddress);
  fLock.Acquire;
  try
    if IsHostIgnored(lId, lAddress, lMacAddress) then
    begin
      Result := TJSONObject.Create;
      Result.Add('result_code', 'ignored');
      Exit;
    end;
    lPersistNeeded := False;
    lHost := FindHost(lId);
    lAlias := FindHostByAddress(lAddress);
    lMacAlias := FindHostByMac(lMacAddress);
    if (lAlias = nil) then lAlias := lMacAlias;
    if (lHost = nil) and (lAlias <> nil) then
    begin
      lHost := lAlias;
      if IncomingIdentityIsPreferred(lHost.InstanceId, lId) then
      begin
        for lIndex := 0 to fCommands.Count - 1 do
          if SameText(TCoordinatorCommand(fCommands[lIndex]).InstanceId,
            lHost.InstanceId) then
            TCoordinatorCommand(fCommands[lIndex]).InstanceId := lId;
        lHost.InstanceId := lId;
      end;
      lPersistNeeded := True;
    end
    else if (lHost <> nil) and (lAlias <> lHost) then
    begin
      MergeHost(lHost, lAlias);
      lPersistNeeded := True;
    end;
    if lHost <> nil then
      lPersistNeeded := MergeHostAliases(lHost, lAddress, lMacAddress) or
        lPersistNeeded;
    if lHost = nil then
    begin
      lHost := TCoordinatorHost.Create;
      lHost.InstanceId := lId;
      lHost.State := 'ready';
      lHost.Address := lAddress;
      fHosts.Add(lHost);
      lPersistNeeded := True;
    end;
    if (lAddress <> '') and (not SameText(lHost.Address, lAddress)) then
    begin
      lHost.Address := lAddress;
      lPersistNeeded := True;
    end;
    if (lMacAddress <> '') and
      (NormalizedMacAddress(lHost.MacAddress) <>
       NormalizedMacAddress(lMacAddress)) then
    begin
      lHost.MacAddress := lMacAddress;
      lPersistNeeded := True;
    end;
    lId := JsonString(AData, 'executable_path', lHost.ExecutablePath);
    if lHost.ExecutablePath <> lId then lPersistNeeded := True;
    lHost.ExecutablePath := lId;
    lId := JsonString(AData, 'os', lHost.OperatingSystem);
    if lHost.OperatingSystem <> lId then lPersistNeeded := True;
    lHost.OperatingSystem := lId;
    { RegisterHello is called only for the Recorder HTTP hello/heartbeat
      endpoints. Reaching either endpoint proves that this instance supports
      the coordinator command contract. UDP discovery uses RegisterDiscovery
      and must not make an unverified announcement manageable. }
    if not lHost.Managed then lPersistNeeded := True;
    lHost.Managed := True;
    lId := JsonString(AData, 'host_name',
      JsonString(AData, 'display_name', lHost.HostName));
    { A manually assigned name is a user label.  Automatic inventory only
      fills it when no label is known; it must not silently replace it. }
    if (lHost.HostName = '') and (lId <> '') then
    begin
      lHost.HostName := lId;
      lPersistNeeded := True;
    end;
    lAlias := lHost;
    lHost := MergeNamedIdentityAlias(lHost);
    if lHost <> lAlias then lPersistNeeded := True;
    lHost.State := JsonString(AData, 'state', lHost.State);
    if lHasRemoteAddress then
    begin
      lHost.LastSeenUtc := Now;
      lHost.LastHttpSeenUtc := lHost.LastSeenUtc;
    end;
    if lPersistNeeded then SaveHostsLocked;
    Result := lHost.ToJson;
    Result.Add('result_code', 'noError');
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.RegisterDiscovery(AData: TJSONObject): TJSONObject;
const
  CHttpStatePrioritySec = 10;
var
  lHost, lAlias, lMacAlias: TCoordinatorHost;
  lAddress, lId, lMacAddress: string;
  lIndex: Integer;
  lPersistNeeded: Boolean;
begin
  lAddress := JsonString(AData, 'remote_address', '');
  if not IsUsableHostAddress(lAddress) then lAddress := '';
  lMacAddress := JsonMacAddress(AData);
  lId := StableHostId(JsonString(AData, 'instance_id', ''), lAddress,
    lMacAddress);
  fLock.Acquire;
  try
    if IsHostIgnored(lId, lAddress, lMacAddress) then
    begin
      Result := TJSONObject.Create;
      Result.Add('result_code', 'ignored');
      Exit;
    end;
    lPersistNeeded := False;
    lHost := FindHost(lId);
    lAlias := FindHostByAddress(lAddress);
    lMacAlias := FindHostByMac(lMacAddress);
    if lAlias = nil then lAlias := lMacAlias;
    if (lHost = nil) and (lAlias <> nil) then
    begin
      lHost := lAlias;
      if IncomingIdentityIsPreferred(lHost.InstanceId, lId) then
      begin
        for lIndex := 0 to fCommands.Count - 1 do
          if SameText(TCoordinatorCommand(fCommands[lIndex]).InstanceId,
            lHost.InstanceId) then
            TCoordinatorCommand(fCommands[lIndex]).InstanceId := lId;
        lHost.InstanceId := lId;
      end;
      lPersistNeeded := True;
    end
    else if (lHost <> nil) and (lAlias <> nil) and (lAlias <> lHost) then
    begin
      MergeHost(lHost, lAlias);
      lPersistNeeded := True;
    end;
    if lHost <> nil then
      lPersistNeeded := MergeHostAliases(lHost, lAddress, lMacAddress) or
        lPersistNeeded;
    if lHost = nil then
    begin
      lHost := TCoordinatorHost.Create;
      lHost.InstanceId := lId;
      lHost.State := 'discovered';
      fHosts.Add(lHost);
      lPersistNeeded := True;
    end;
    if lHost.HostName = '' then
    begin
      lHost.HostName := JsonString(AData, 'host_name',
        JsonString(AData, 'display_name', ''));
      lPersistNeeded := lHost.HostName <> '';
    end;
    lAlias := lHost;
    lHost := MergeNamedIdentityAlias(lHost);
    if lHost <> lAlias then lPersistNeeded := True;
    if (lMacAddress <> '') and
      (NormalizedMacAddress(lHost.MacAddress) <>
       NormalizedMacAddress(lMacAddress)) then
    begin
      lHost.MacAddress := lMacAddress;
      lPersistNeeded := True;
    end;
    { UDP only proves that the process announces itself. A recent HTTP hello or
      heartbeat is authoritative for both endpoint identity and runtime state. }
    if (lHost.LastHttpSeenUtc = 0) or
      (SecondsBetween(Now, lHost.LastHttpSeenUtc) > CHttpStatePrioritySec) then
    begin
      if (lAddress <> '') and (not SameText(lHost.Address, lAddress)) then
      begin
        lHost.Address := lAddress;
        lPersistNeeded := True;
      end;
      lHost.State := 'discovered';
    end;
    lHost.LastSeenUtc := Now;
    if lPersistNeeded then SaveHostsLocked;
    Result := lHost.ToJson;
    Result.Add('result_code', 'noError');
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.ApplyHeartbeat(AData: TJSONObject): TJSONObject;
var
  lHost: TCoordinatorHost;
  lState, lRecording: TJSONObject;
  lPreviousState, lCurrentState, lMeasurementPath: string;
  lQueuedCount: Integer;
begin
  Result := RegisterHello(AData);
  fLock.Acquire;
  try
    lHost := FindHost(JsonString(AData, 'instance_id', ''));
    if lHost <> nil then
    begin
      lPreviousState := lHost.State;
      lState := JsonPayloadObject(AData, 'state');
      if lState <> nil then
        lHost.State := JsonString(lState, 'state', lHost.State);
      lCurrentState := lHost.State;
      lRecording := JsonPayloadObject(AData, 'recording');
      if lRecording <> nil then
      begin
        lHost.CurrentRecordingId := JsonString(lRecording, 'recording_id', lHost.CurrentRecordingId);
        lMeasurementPath := JsonString(lRecording, 'local_path',
          JsonString(lRecording, 'measurement_path', ''));
        if Trim(lMeasurementPath) <> '' then
          lHost.CurrentMeasurementPath := lMeasurementPath;
      end
      else
      begin
        lHost.CurrentRecordingId := JsonString(AData, 'recording_id', lHost.CurrentRecordingId);
        lMeasurementPath := JsonString(AData, 'measurement_path', '');
        if Trim(lMeasurementPath) <> '' then
          lHost.CurrentMeasurementPath := lMeasurementPath;
      end;
      if not SameText(lPreviousState, lCurrentState) then
      begin
        AddDiagnosticLocked(Format('Heartbeat %s: %s -> %s; managed=%s',
          [lHost.InstanceId, lPreviousState, lCurrentState,
           BoolToStr(lHost.Managed, True)]));
        if SameText(lCurrentState, 'recording') then
        begin
          lQueuedCount := 0;
          if StartAllOnAnyRecording and lHost.Managed then
            lQueuedCount := EnqueuePeerRecordingStarts(lHost.InstanceId);
          AddDiagnosticLocked(Format(
            'Автостарт: enabled=%s; initiator=%s; managed=%s; queued=%d',
            [BoolToStr(StartAllOnAnyRecording, True), lHost.InstanceId,
             BoolToStr(lHost.Managed, True), lQueuedCount]));
        end;
      end;
      Result.Free;
      Result := lHost.ToJson;
      Result.Add('result_code', 'noError');
    end;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.AddRecordingEvent(AData: TJSONObject): TJSONObject;
const
  CClockSkewWarningSec = 5 * 60;
var
  lEvent: TCoordinatorEvent;
  lHost: TCoordinatorHost;
  lInfo: TCoordinatorRecordingLifecycle;
  lPersistenceError: string;
  lStarted: TDateTime;
  lReceivedUtc: TDateTime;
  lSentAtUtc: TDateTime;
  lClockOffsetSec: Double;
  lClientFinishedText, lClientStartedText, lCorrelation, lMessageType, lRecordingId,
    lSentAtText: string;
  lClientFinishedValid, lClientTimeValid, lClockFallback, lNewEvent, lNotifyLifecycle,
    lSentAtValid: Boolean;
begin
  lInfo := Default(TCoordinatorRecordingLifecycle);
  lCorrelation := NormalizeCorrelationId(
    JsonString(AData, 'correlation_id', ''));
  lRecordingId := JsonString(AData, 'recording_id', '');
  lMessageType := JsonString(AData, 'message_type', 'recording.started');
  lReceivedUtc := LocalTimeToUniversal(Now);
  lSentAtText := JsonString(AData, 'sent_at_utc', '');
  lSentAtValid := (Trim(lSentAtText) <> '') and
    TryISO8601ToDate(lSentAtText, lSentAtUtc, True);
  if lSentAtValid then
    lClockOffsetSec := (lReceivedUtc - lSentAtUtc) * SecsPerDay
  else
    lClockOffsetSec := 0;
  lClientStartedText := JsonString(AData, 'started_utc', '');
  lClientTimeValid := (Trim(lClientStartedText) <> '') and
    TryISO8601ToDate(lClientStartedText, lStarted, True);
  if not lClientTimeValid then lStarted := lReceivedUtc;
  lClockFallback := SameText(lMessageType, 'recording.started') and
    (not lClientTimeValid);
  if lClientTimeValid and lSentAtValid then
    lStarted := lStarted + lClockOffsetSec / SecsPerDay
  else if lClockFallback then
    lStarted := lReceivedUtc;
  lNewEvent := False;
  lNotifyLifecycle := False;
  fLock.Acquire;
  try
    AddDiagnosticLocked(Format(
      'Получено %s: recorder=%s; recording=%s; CreateRecordingEvents=%s',
      [lMessageType, JsonString(AData, 'instance_id', ''), lRecordingId,
       BoolToStr(CreateRecordingEvents, True)]));
    if SameText(lMessageType, 'recording.started') and
      (lClockFallback or (not lSentAtValid) or
       (Abs(lClockOffsetSec) > CClockSkewWarningSec)) then
      AddDiagnosticLocked(Format(
        'Clock sync: client_start=%s; sent=%s; receive=%s; offset_sec=%.0f; corrected=%s; fallback=%s',
        [lClientStartedText, lSentAtText, JsonDateTime(lReceivedUtc),
         lClockOffsetSec, BoolToStr(lClientTimeValid and lSentAtValid, True),
         BoolToStr(lClockFallback, True)]));
    if not CreateRecordingEvents then
    begin
      Result := TJSONObject.Create;
      Result.Add('result_code', 'noError');
      Result.Add('event_created', False);
      Exit;
    end;

    if not SameText(lMessageType, 'recording.started') and
      not SameText(lMessageType, 'recording.completed') then
    begin
      Result := TJSONObject.Create;
      Result.Add('result_code', 'noError');
      Result.Add('event_created', False);
      Exit;
    end;

    if SameText(lMessageType, 'recording.completed') then
      lEvent := FindEventByRecording(lRecordingId)
    else
      lEvent := FindOpenEvent(lStarted);
    if SameText(lMessageType, 'recording.completed') and (lEvent = nil) then
    begin
      { Completion must never be attached by a time-window guess. RecordingId
        is the stable lifecycle identity of one RecorderLnx package. }
      Result := TJSONObject.Create;
      Result.Add('result_code', 'noError');
      Result.Add('event_created', False);
      Result.Add('event_matched', False);
      SharedLogger.Warning(Format(
        'Grouping completion unmatched recording=%s correlation=%s',
        [lRecordingId, lCorrelation]));
      Exit;
    end;
    if SameText(lMessageType, 'recording.completed') and
      ((lRecordingId = '') or
       (lEvent.Recordings.IndexOf(lRecordingId) < 0)) then
    begin
      Result := TJSONObject.Create;
      Result.Add('result_code', 'noError');
      Result.Add('event_created', False);
      Result.Add('event_matched', False);
      SharedLogger.Warning(Format(
        'Grouping completion rejected recording=%s event=%s correlation=%s',
        [lRecordingId, lEvent.EventId, lEvent.CorrelationId]));
      Exit;
    end;

    if lEvent = nil then
    begin
      lEvent := TCoordinatorEvent.Create;
      lEvent.EventId := NewId;
      if lCorrelation = '' then lCorrelation := NewId;
      lEvent.CorrelationId := lCorrelation;
      lEvent.StartedUtc := lStarted;
      if EventWindowSec < 1 then
        lEvent.WindowEndsUtc := IncSecond(lStarted, 1)
      else
        lEvent.WindowEndsUtc := IncSecond(lStarted, EventWindowSec);
      fEvents.Add(lEvent);
      lNewEvent := True;
      SharedLogger.Info(Format(
        'Grouping started event=%s correlation=%s recording=%s',
        [lEvent.EventId, lEvent.CorrelationId, lRecordingId]));
    end;
    if (lRecordingId <> '') and (lEvent.Recordings.IndexOf(lRecordingId) < 0) then
      lEvent.Recordings.Add(lRecordingId);
    if SameText(lMessageType, 'recording.completed') then
    begin
      if (lRecordingId <> '') and
        (lEvent.CompletedRecordings.IndexOf(lRecordingId) < 0) then
        lEvent.CompletedRecordings.Add(lRecordingId);
      lClientFinishedText := JsonString(AData, 'finished_utc', '');
      lClientFinishedValid := (Trim(lClientFinishedText) <> '') and
        TryISO8601ToDate(lClientFinishedText, lEvent.FinishedUtc, True);
      if not lClientFinishedValid then
        lEvent.FinishedUtc := lReceivedUtc;
      if lClientFinishedValid and lSentAtValid then
        lEvent.FinishedUtc := lEvent.FinishedUtc + lClockOffsetSec / SecsPerDay;
      lStarted := lEvent.StartedUtc;
      SharedLogger.Info(Format(
        'Grouping completed event=%s correlation=%s recording=%s completed=%d total=%d',
        [lEvent.EventId, lEvent.CorrelationId, lRecordingId,
         lEvent.CompletedRecordings.Count, lEvent.Recordings.Count]));
    end;
    lHost := FindHost(JsonString(AData, 'instance_id', ''));
    lInfo.MessageType := lMessageType;
    lInfo.EventId := lEvent.EventId;
    lInfo.CorrelationId := lEvent.CorrelationId;
    lInfo.RecordingId := lRecordingId;
    lInfo.InstanceId := JsonString(AData, 'instance_id', '');
    if lHost <> nil then lInfo.HostName := lHost.HostName;
    lInfo.DisplayName := JsonString(AData, 'display_name', 'Запись RecorderLnx');
    lInfo.ProjectName := JsonString(AData, 'project_name', '');
    if SameText(lMessageType, 'recording.completed') then
      lInfo.State := 'complete'
    else
      lInfo.State := 'building';
    lInfo.LocalPath := JsonString(AData, 'local_path', '');
    lInfo.EntryFile := JsonString(AData, 'entry_file', '');
    lInfo.StartedUtc := lStarted;
    if SameText(lMessageType, 'recording.completed') then
      lInfo.FinishedUtc := lEvent.FinishedUtc
    else
      lInfo.FinishedUtc := 0;
    Result := lEvent.ToJson;
    Result.Add('result_code', 'noError');
    Result.Add('event_created', lNewEvent);
    Result.Add('event_matched', True);
    lNotifyLifecycle := True;
  finally
    fLock.Release;
  end;
  if lNotifyLifecycle and Assigned(OnRecordingLifecycle) then
  begin
    lPersistenceError := OnRecordingLifecycle(lInfo);
    if lPersistenceError <> '' then
      Result.Add('persistence_error', lPersistenceError);
  end;
end;

function TCoordinatorModel.EnqueueCommand(AData: TJSONObject): TJSONObject;
var
  lCommand: TCoordinatorCommand;
  lTarget, lCorrelation: string;
  lPayload: TJSONData;
  lPayloadJson: string;
  lIndex, lCount: Integer;
begin
  fLock.Acquire;
  try
    lTarget := JsonString(AData, 'instance_id', '');
    lCorrelation := NormalizeCorrelationId(
      JsonString(AData, 'correlation_id', ''));
    if lCorrelation = '' then lCorrelation := NewId;
    lPayload := AData.Find('payload');
    if lPayload <> nil then
      lPayloadJson := lPayload.AsJSON
    else
      lPayloadJson := '{}';
    if lTarget = '*' then
    begin
      lCount := 0;
      for lIndex := 0 to fHosts.Count - 1 do
      begin
        lCommand := TCoordinatorCommand.Create;
        lCommand.CommandId := NewId;
        lCommand.InstanceId := TCoordinatorHost(fHosts[lIndex]).InstanceId;
        lCommand.CommandName := JsonString(AData, 'command', 'status');
        lCommand.CorrelationId := lCorrelation;
        lCommand.ExecuteAtUtc := JsonString(AData, 'execute_at_utc', '');
        lCommand.PayloadJson := lPayloadJson;
        lCommand.State := 'pending';
        fCommands.Add(lCommand);
        Inc(lCount);
      end;
      Result := TJSONObject.Create;
      Result.Add('result_code', 'noError');
      Result.Add('correlation_id', lCorrelation);
      Result.Add('queued_count', lCount);
      Exit;
    end;
    lCommand := TCoordinatorCommand.Create;
    lCommand.CommandId := JsonString(AData, 'command_id', NewId);
    lCommand.InstanceId := lTarget;
    lCommand.CommandName := JsonString(AData, 'command', 'status');
    lCommand.CorrelationId := lCorrelation;
    lCommand.ExecuteAtUtc := JsonString(AData, 'execute_at_utc', '');
    lCommand.PayloadJson := lPayloadJson;
    lCommand.State := 'pending';
    fCommands.Add(lCommand);
    Result := lCommand.ToJson;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.NextCommand(const AInstanceId: string): TJSONObject;
var
  lIndex: Integer;
  lCommand: TCoordinatorCommand;
begin
  fLock.Acquire;
  try
    Result := TJSONObject.Create;
    for lIndex := 0 to fCommands.Count - 1 do
    begin
      lCommand := TCoordinatorCommand(fCommands[lIndex]);
      if (lCommand.State = 'pending') and SameText(lCommand.InstanceId, AInstanceId) then
      begin
        lCommand.State := 'accepted';
        Result.Free;
        Exit(lCommand.ToJson);
      end;
    end;
    Result.Add('result_code', 'noCommand');
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.CompleteCommand(AData: TJSONObject): TJSONObject;
var
  lCommand: TCoordinatorCommand;
  lHost: TCoordinatorHost;
  lCommandResult: TJSONObject;
  lMeraFilesPath: string;
begin
  fLock.Acquire;
  try
    lCommand := FindCommand(JsonString(AData, 'command_id', ''));
    Result := TJSONObject.Create;
    if lCommand = nil then
      Result.Add('result_code', 'notFound')
    else
    begin
      lCommand.State := JsonString(AData, 'state', 'completed');
      lCommand.ResultCode := JsonString(AData, 'result_code',
        JsonString(AData, 'code', 'noError'));
      lCommand.ResultText := JsonString(AData, 'result_text',
        JsonString(AData, 'text', ''));
      if SameText(lCommand.CommandName, 'config.get') and
        SameText(lCommand.ResultCode, 'noError') then
      begin
        lCommandResult := JsonPayloadObject(AData, 'result');
        if lCommandResult <> nil then
        begin
          lMeraFilesPath := Trim(JsonString(lCommandResult,
            'mera_files_path', ''));
          lHost := FindHost(lCommand.InstanceId);
          if (lHost <> nil) and (lMeraFilesPath <> '') and
            (lHost.MeraFilesPath <> lMeraFilesPath) then
          begin
            lHost.MeraFilesPath := lMeraFilesPath;
            SaveHostsLocked;
          end;
        end;
      end;
      Result.Free;
      Result := lCommand.ToJson;
    end;
  finally
    fLock.Release;
  end;
end;

procedure TCoordinatorModel.ClearHostMeraFilesPaths;
var
  lIndex: Integer;
begin
  fLock.Acquire;
  try
    for lIndex := 0 to fHosts.Count - 1 do
      TCoordinatorHost(fHosts[lIndex]).MeraFilesPath := '';
    SaveHostsLocked;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.CurrentRecording(const AInstanceId: string): TJSONObject;
var
  lHost: TCoordinatorHost;
begin
  fLock.Acquire;
  try
    Result := TJSONObject.Create;
    lHost := FindHost(AInstanceId);
    if lHost = nil then Result.Add('result_code', 'notFound') else
    begin
      Result.Add('result_code', 'noError');
      Result.Add('instance_id', lHost.InstanceId);
      Result.Add('recording_id', lHost.CurrentRecordingId);
      Result.Add('measurement_path', lHost.CurrentMeasurementPath);
      Result.Add('available', lHost.CurrentMeasurementPath <> '');
    end;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.HostsJson: TJSONArray;
var lIndex: Integer;
begin
  fLock.Acquire;
  try
    Result := TJSONArray.Create;
    for lIndex := 0 to fHosts.Count - 1 do Result.Add(TCoordinatorHost(fHosts[lIndex]).ToJson);
  finally fLock.Release; end;
end;

function TCoordinatorModel.HostByIdJson(
  const AInstanceId: string): TJSONObject;
var
  lHost: TCoordinatorHost;
begin
  fLock.Acquire;
  try
    lHost := FindHost(AInstanceId);
    if lHost <> nil then
      Result := lHost.ToJson
    else
    begin
      Result := TJSONObject.Create;
      Result.Add('result_code', 'notFound');
    end;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.HostByAddressJson(
  const AAddress: string): TJSONObject;
var
  lHost: TCoordinatorHost;
begin
  fLock.Acquire;
  try
    lHost := FindHostByAddress(AAddress);
    if lHost <> nil then
      Result := lHost.ToJson
    else
    begin
      Result := TJSONObject.Create;
      Result.Add('result_code', 'notFound');
    end;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.SetHostDisplayName(const AInstanceId,
  ADisplayName: string): Boolean;
var
  lHost: TCoordinatorHost;
begin
  fLock.Acquire;
  try
    lHost := FindHost(AInstanceId);
    Result := lHost <> nil;
    if not Result then Exit;
    lHost.HostName := Trim(ADisplayName);
    SaveHostsLocked;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.SetHostAddress(const AInstanceId,
  AAddress: string): Boolean;
var
  lAlias, lHost: TCoordinatorHost;
  lAddress: string;
begin
  lAddress := Trim(AAddress);
  Result := IsUsableHostAddress(lAddress);
  if not Result then Exit;
  fLock.Acquire;
  try
    lHost := FindHost(AInstanceId);
    Result := lHost <> nil;
    if not Result then Exit;
    lAlias := FindHostByAddress(lAddress);
    if (lAlias <> nil) and (lAlias <> lHost) then
      MergeHost(lHost, lAlias);
    lHost.Address := lAddress;
    SaveHostsLocked;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.IgnoreHost(const AInstanceId: string): Boolean;
var
  lCommand: TCoordinatorCommand;
  lHost, lIgnoredHost: TCoordinatorHost;
  lIndex: Integer;
begin
  fLock.Acquire;
  try
    lHost := FindHost(AInstanceId);
    Result := lHost <> nil;
    if not Result then Exit;
    lIgnoredHost := TCoordinatorHost.Create;
    lIgnoredHost.InstanceId := lHost.InstanceId;
    lIgnoredHost.Address := lHost.Address;
    lIgnoredHost.HostName := lHost.HostName;
    lIgnoredHost.MacAddress := lHost.MacAddress;
    fIgnoredHosts.Add(lIgnoredHost);
    for lIndex := fCommands.Count - 1 downto 0 do
    begin
      lCommand := TCoordinatorCommand(fCommands[lIndex]);
      if SameText(lCommand.InstanceId, lHost.InstanceId) then
      begin
        fCommands.Delete(lIndex);
        lCommand.Free;
      end;
    end;
    fHosts.Remove(lHost);
    lHost.Free;
    SaveIgnoredHostsLocked;
    SaveHostsLocked;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.HostProbeTargets: TJSONArray;
var
  lAddress: string;
  lIndex: Integer;
  lKnownAddresses: TStringList;
  lTarget: TJSONObject;
begin
  Result := TJSONArray.Create;
  lKnownAddresses := TStringList.Create;
  try
    lKnownAddresses.CaseSensitive := False;
    lKnownAddresses.Sorted := True;
    lKnownAddresses.Duplicates := dupIgnore;
    fLock.Acquire;
    try
      for lIndex := 0 to fHosts.Count - 1 do
      begin
        lAddress := Trim(TCoordinatorHost(fHosts[lIndex]).Address);
        if (lAddress = '') or (lKnownAddresses.IndexOf(lAddress) >= 0) then
          Continue;
        { A configured UUID is an identity, not a DNS name or IP target. }
        if (Length(lAddress) = 36) and (lAddress[9] = '-') and
          (lAddress[14] = '-') and (lAddress[19] = '-') and
          (lAddress[24] = '-') then Continue;
        lKnownAddresses.Add(lAddress);
        lTarget := TJSONObject.Create;
        lTarget.Add('address', lAddress);
        Result.Add(lTarget);
      end;
    finally
      fLock.Release;
    end;
  finally
    lKnownAddresses.Free;
  end;
end;

procedure TCoordinatorModel.MarkPcReachabilityChecking(
  const AAddress: string);
var
  lHost: TCoordinatorHost;
begin
  fLock.Acquire;
  try
    lHost := FindHostByAddress(AAddress);
    if lHost <> nil then
      lHost.PcConnectionState := 'checking';
  finally
    fLock.Release;
  end;
end;

procedure TCoordinatorModel.ApplyPcReachability(const AAddress: string;
  AReachable: Boolean; ACheckedUtc: TDateTime);
var
  lHost: TCoordinatorHost;
begin
  fLock.Acquire;
  try
    lHost := FindHostByAddress(AAddress);
    if lHost = nil then Exit;
    lHost.PcReachable := AReachable;
    lHost.PcReachabilityKnown := True;
    if AReachable then
      lHost.PcConnectionState := 'reachable'
    else
      lHost.PcConnectionState := 'unreachable';
    lHost.LastPingUtc := ACheckedUtc;
  finally
    fLock.Release;
  end;
end;

function TCoordinatorModel.ApplyAgentStatus(const AAddress: string;
  AStatus: TJSONObject): TJSONObject;
var
  lHost, lAlias: TCoordinatorHost;
  lId, lMacAddress: string;
  lIndex: Integer;
  lPersistNeeded: Boolean;
begin
  lMacAddress := JsonMacAddress(AStatus);
  lId := StableHostId(JsonString(AStatus, 'instance_id', ''), AAddress,
    lMacAddress);
  fLock.Acquire;
  try
    if IsHostIgnored(lId, AAddress, lMacAddress) then
    begin
      Result := TJSONObject.Create;
      Result.Add('result_code', 'ignored');
      Exit;
    end;
    lPersistNeeded := False;
    lHost := FindHost(lId);
    lAlias := FindHostByAddress(AAddress);
    if lAlias = nil then lAlias := FindHostByMac(lMacAddress);
    if (lHost = nil) and (lAlias <> nil) then
    begin
      lHost := lAlias;
      for lIndex := 0 to fCommands.Count - 1 do
        if SameText(TCoordinatorCommand(fCommands[lIndex]).InstanceId,
          lHost.InstanceId) then
          TCoordinatorCommand(fCommands[lIndex]).InstanceId := lId;
      lHost.InstanceId := lId;
      lPersistNeeded := True;
    end;
    if lHost <> nil then
      lPersistNeeded := MergeHostAliases(lHost, AAddress, lMacAddress) or
        lPersistNeeded;
    if lHost = nil then
    begin
      lHost := TCoordinatorHost.Create;
      lHost.InstanceId := lId;
      lHost.Address := AAddress;
      lHost.State := 'unknown';
      fHosts.Add(lHost);
      lPersistNeeded := True;
    end;
    if (Trim(AAddress) <> '') and
      (not SameText(lHost.Address, Trim(AAddress))) then
    begin
      lHost.Address := Trim(AAddress);
      lPersistNeeded := True;
    end;
    if (lMacAddress <> '') and
      (NormalizedMacAddress(lHost.MacAddress) <>
       NormalizedMacAddress(lMacAddress)) then
    begin
      lHost.MacAddress := lMacAddress;
      lPersistNeeded := True;
    end;
    lId := JsonString(AStatus, 'host_name', lHost.HostName);
    if (lHost.HostName = '') and (lId <> '') then
    begin
      lHost.HostName := lId;
      lPersistNeeded := True;
    end;
    lHost.AgentReachable := JsonBoolean(AStatus, 'reachable', True);
    lHost.AgentReachabilityKnown := True;
    if lHost.AgentReachable then
      lHost.AgentConnectionState := 'reachable'
    else
      lHost.AgentConnectionState := 'unreachable';
    if lHost.AgentReachable then lHost.LastAgentSeenUtc := Now;
    if lPersistNeeded then SaveHostsLocked;
    Result := lHost.ToJson;
    Result.Add('result_code', 'noError');
  finally
    fLock.Release;
  end;
end;

procedure TCoordinatorModel.MarkAgentReachabilityChecking(
  const AAddress: string);
var
  lHost: TCoordinatorHost;
begin
  fLock.Acquire;
  try
    lHost := FindHostByAddress(AAddress);
    if lHost <> nil then
      lHost.AgentConnectionState := 'checking';
  finally
    fLock.Release;
  end;
end;

procedure TCoordinatorModel.ApplyAgentReachability(const AAddress: string;
  AReachable: Boolean; ACheckedUtc: TDateTime);
var
  lHost: TCoordinatorHost;
begin
  fLock.Acquire;
  try
    lHost := FindHostByAddress(AAddress);
    if lHost = nil then Exit;
    lHost.AgentReachable := AReachable;
    lHost.AgentReachabilityKnown := True;
    if AReachable then
      lHost.AgentConnectionState := 'reachable'
    else
      lHost.AgentConnectionState := 'unreachable';
    lHost.LastAgentSeenUtc := ACheckedUtc;
  finally
    fLock.Release;
  end;
end;

procedure TCoordinatorModel.ApplyAgentUnavailable(const AAddress: string;
  ACheckedUtc: TDateTime);
begin
  ApplyAgentReachability(AAddress, False, ACheckedUtc);
end;

function TCoordinatorModel.EventsJson: TJSONArray;
var lIndex: Integer;
begin
  fLock.Acquire;
  try
    Result := TJSONArray.Create;
    for lIndex := 0 to fEvents.Count - 1 do Result.Add(TCoordinatorEvent(fEvents[lIndex]).ToJson);
  finally fLock.Release; end;
end;

function TCoordinatorModel.StatusJson: TJSONObject;
begin
  fLock.Acquire;
  try
    Result := TJSONObject.Create;
    Result.Add('service', 'RecorderCoordinator');
    Result.Add('api_version', 1);
    Result.Add('state', 'ready');
    Result.Add('hosts', fHosts.Count);
    Result.Add('events', fEvents.Count);
  finally fLock.Release; end;
end;

end.
