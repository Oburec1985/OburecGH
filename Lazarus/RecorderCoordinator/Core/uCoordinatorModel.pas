unit uCoordinatorModel;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DateUtils, SyncObjs, fpjson, jsonparser,
  uSharedFileLogger;

type
  TCoordinatorHost = class
  public
    InstanceId: string;
    Address: string;
    HostName: string;
    State: string;
    CurrentRecordingId: string;
    CurrentMeasurementPath: string;
    LastSeenUtc: TDateTime;
    LastHttpSeenUtc: TDateTime;
    Managed: Boolean;
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
    procedure AddDiagnosticLocked(const AText: string);
    function FindHost(const AInstanceId: string): TCoordinatorHost;
    function FindHostByAddress(const AAddress: string): TCoordinatorHost;
    procedure MergeHost(AHost, AAlias: TCoordinatorHost);
    function FindOpenEvent(const AStartedUtc: TDateTime): TCoordinatorEvent;
    function FindEventByRecording(
      const ARecordingId: string): TCoordinatorEvent;
    function FindCommand(const ACommandId: string): TCoordinatorCommand;
    function HasActiveStartCommand(const AInstanceId: string): Boolean;
    function EnqueuePeerRecordingStarts(const AInitiatorId: string): Integer;
    function NewId: string;
  public
    EventWindowSec: Integer;
    CreateRecordingEvents: Boolean;
    StartAllOnAnyRecording: Boolean;
    OnRecordingLifecycle: TCoordinatorRecordingLifecycleHandler;
    constructor Create;
    destructor Destroy; override;
    function RegisterHello(AData: TJSONObject): TJSONObject;
    function RegisterDiscovery(AData: TJSONObject): TJSONObject;
    function ApplyHeartbeat(AData: TJSONObject): TJSONObject;
    function AddRecordingEvent(AData: TJSONObject): TJSONObject;
    function EnqueueCommand(AData: TJSONObject): TJSONObject;
    function NextCommand(const AInstanceId: string): TJSONObject;
    function CompleteCommand(AData: TJSONObject): TJSONObject;
    function CurrentRecording(const AInstanceId: string): TJSONObject;
    function HostsJson: TJSONArray;
    function EventsJson: TJSONArray;
    function StatusJson: TJSONObject;
    procedure DrainDiagnostics(ATarget: TStrings);
  end;

function JsonDateTime(const AValue: TDateTime): string;
function ParseJsonDateTime(const AValue: string; const ADefault: TDateTime): TDateTime;

implementation

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
  lEffectiveState: string;
begin
  if (LastSeenUtc = 0) or (SecondsBetween(Now, LastSeenUtc) > CHostOfflineAfterSec) then
    lEffectiveState := 'offline'
  else
    lEffectiveState := State;
  Result := TJSONObject.Create;
  Result.Add('instance_id', InstanceId);
  Result.Add('address', Address);
  Result.Add('host_name', HostName);
  Result.Add('state', lEffectiveState);
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
  fCommands.Free;
  fDiagnostics.Free;
  fEvents.Free;
  fHosts.Free;
  fLock.Free;
  inherited Destroy;
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
  lComputerName := LowerCase(Trim(GetEnvironmentVariable('COMPUTERNAME')));
  if (Result = '127.0.0.1') or (Result = '::1') or
    (Result = 'localhost') or ((lComputerName <> '') and
    SameText(Result, lComputerName)) then
    Result := '<local>';
end;

function TCoordinatorModel.FindHostByAddress(
  const AAddress: string): TCoordinatorHost;
var
  lCandidate: string;
  lIndex: Integer;
begin
  Result := nil;
  if Trim(AAddress) = '' then Exit;
  for lIndex := 0 to fHosts.Count - 1 do
  begin
    lCandidate := TCoordinatorHost(fHosts[lIndex]).Address;
    if lCandidate = '' then
      lCandidate := TCoordinatorHost(fHosts[lIndex]).InstanceId;
    if NormalizedAddress(lCandidate) = NormalizedAddress(AAddress) then
      Exit(TCoordinatorHost(fHosts[lIndex]));
  end;
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
  if AHost.CurrentRecordingId = '' then
    AHost.CurrentRecordingId := AAlias.CurrentRecordingId;
  if AHost.CurrentMeasurementPath = '' then
    AHost.CurrentMeasurementPath := AAlias.CurrentMeasurementPath;
  AHost.Managed := AHost.Managed or AAlias.Managed;
  for lIndex := 0 to fCommands.Count - 1 do
    if SameText(TCoordinatorCommand(fCommands[lIndex]).InstanceId, lOldId) then
      TCoordinatorCommand(fCommands[lIndex]).InstanceId := AHost.InstanceId;
  fHosts.Remove(AAlias);
  AAlias.Free;
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
  lHost, lAlias: TCoordinatorHost;
  lAddress, lId: string;
  lIndex: Integer;
begin
  lId := JsonString(AData, 'instance_id', '');
  lAddress := JsonString(AData, 'remote_address', '');
  fLock.Acquire;
  try
    lHost := FindHost(lId);
    lAlias := FindHostByAddress(lAddress);
    if (lHost = nil) and (lAlias <> nil) then
    begin
      lHost := lAlias;
      for lIndex := 0 to fCommands.Count - 1 do
        if SameText(TCoordinatorCommand(fCommands[lIndex]).InstanceId,
          lHost.InstanceId) then
          TCoordinatorCommand(fCommands[lIndex]).InstanceId := lId;
      lHost.InstanceId := lId;
    end
    else if (lHost <> nil) and (lAlias <> lHost) then
      MergeHost(lHost, lAlias);
    if lHost = nil then
    begin
      lHost := TCoordinatorHost.Create;
      lHost.InstanceId := lId;
      lHost.State := 'ready';
      if lAddress = '' then lHost.Address := lId;
      fHosts.Add(lHost);
    end;
    if lAddress <> '' then lHost.Address := lAddress;
    { RegisterHello is called only for the Recorder HTTP hello/heartbeat
      endpoints. Reaching either endpoint proves that this instance supports
      the coordinator command contract. UDP discovery uses RegisterDiscovery
      and must not make an unverified announcement manageable. }
    lHost.Managed := True;
    lHost.HostName := JsonString(AData, 'host_name',
      JsonString(AData, 'display_name', lHost.HostName));
    lHost.State := JsonString(AData, 'state', lHost.State);
    if lAddress <> '' then
    begin
      lHost.LastSeenUtc := Now;
      lHost.LastHttpSeenUtc := lHost.LastSeenUtc;
    end;
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
  lHost, lAlias: TCoordinatorHost;
  lAddress, lId: string;
begin
  lId := JsonString(AData, 'instance_id', '');
  lAddress := JsonString(AData, 'remote_address', '');
  fLock.Acquire;
  try
    lHost := FindHost(lId);
    lAlias := FindHostByAddress(lAddress);
    if (lHost = nil) and (lAlias <> nil) then
      lHost := lAlias
    else if (lHost <> nil) and (lAlias <> nil) and (lAlias <> lHost) then
      MergeHost(lHost, lAlias);
    if lHost = nil then
    begin
      lHost := TCoordinatorHost.Create;
      lHost.InstanceId := lId;
      lHost.State := 'discovered';
      fHosts.Add(lHost);
    end;
    if lHost.HostName = '' then
      lHost.HostName := JsonString(AData, 'host_name',
        JsonString(AData, 'display_name', ''));
    { UDP only proves that the process announces itself. A recent HTTP hello or
      heartbeat is authoritative for both endpoint identity and runtime state. }
    if (lHost.LastHttpSeenUtc = 0) or
      (SecondsBetween(Now, lHost.LastHttpSeenUtc) > CHttpStatePrioritySec) then
    begin
      if lAddress <> '' then lHost.Address := lAddress;
      lHost.State := 'discovered';
    end;
    lHost.LastSeenUtc := Now;
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
  lPreviousState, lCurrentState: string;
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
        lHost.CurrentMeasurementPath := JsonString(lRecording, 'local_path',
          JsonString(lRecording, 'measurement_path', lHost.CurrentMeasurementPath));
      end
      else
      begin
        lHost.CurrentRecordingId := JsonString(AData, 'recording_id', lHost.CurrentRecordingId);
        lHost.CurrentMeasurementPath := JsonString(AData, 'measurement_path', lHost.CurrentMeasurementPath);
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
      Result.Free;
      Result := lCommand.ToJson;
    end;
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
