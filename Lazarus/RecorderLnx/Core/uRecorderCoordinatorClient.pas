unit uRecorderCoordinatorClient;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, SyncObjs, uRecorderCoordinatorProtocol,
  uRecorderLanDiscovery;

type
  TRecorderCoordinatorClientState = (rccsDisabled, rccsConnecting,
    rccsOnline, rccsBackoff, rccsStopping);

  TRecorderCoordinatorClientConfig = class
  public
    FileName: string;
    Enabled: Boolean;
    BaseUrl: string;
    InstanceId: string;
    DisplayName: string;
    AuthToken: string;
    HeartbeatMs: Integer;
    RequestTimeoutMs: Integer;
    AllowRemoteControl: Boolean;
    AllowRemoteConfig: Boolean;
    constructor Create;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
  end;

  TRecorderCoordinatorResult = class
  public
    CommandId: string;
    CorrelationId: string;
    Code: TRecorderCoordinatorResultCode;
    Text: string;
    PayloadJson: string;
  end;

  TRecorderCoordinatorEvent = class
  public
    EventType: string;
    CorrelationId: string;
    PayloadJson: string;
  end;

  TRecorderCoordinatorClientThread = class;

  TRecorderCoordinatorClient = class
  private
    fConfig: TRecorderCoordinatorClientConfig;
    fCommands: TThreadList;
    fResults: TThreadList;
    fEvents: TThreadList;
    fSnapshotLock: TCriticalSection;
    fStateJson: string;
    fRecordingJson: string;
    fSnapshotGeneration: QWord;
    fThread: TRecorderCoordinatorClientThread;
    fState: TRecorderCoordinatorClientState;
    fLastError: string;
    fOutboxFileName: string;
    fDiscovery: TRecorderLanDiscovery;
    procedure LoadEventOutbox;
    procedure SaveEventOutboxLocked(AList: TList);
    function TakeResult: TRecorderCoordinatorResult;
    function GetAllowRemoteControl: Boolean;
    function GetAllowRemoteConfig: Boolean;
  public
    constructor Create(AConfig: TRecorderCoordinatorClientConfig);
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    procedure UpdateSnapshot(const AStateJson, ARecordingJson: string);
    function PopCommand: TRecorderCoordinatorCommand;
    procedure CompleteCommand(ACommand: TRecorderCoordinatorCommand;
      ACode: TRecorderCoordinatorResultCode; const AText,
      APayloadJson: string);
    procedure PublishEvent(const AEventType, ACorrelationId,
      APayloadJson: string);
    property State: TRecorderCoordinatorClientState read fState;
    property LastError: string read fLastError;
    property AllowRemoteControl: Boolean read GetAllowRemoteControl;
    property AllowRemoteConfig: Boolean read GetAllowRemoteConfig;
  end;

  TRecorderCoordinatorClientThread = class(TThread)
  private
    fOwner: TRecorderCoordinatorClient;
    fWakeEvent: TEvent;
    fLastHeartbeat: QWord;
    fSentSnapshotGeneration: QWord;
    fBackoffMs: Integer;
    function ServerReachable: Boolean;
    function PostJson(const APath, AJson: string; out AResponse: string): Boolean;
    function HttpGetJson(const APath: string; out AResponse: string): Boolean;
    function SnapshotChanged: Boolean;
    procedure SendHello;
    procedure SendHeartbeat;
    procedure SendResults;
    procedure SendEvents;
    procedure PollCommand;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderCoordinatorClient);
    destructor Destroy; override;
    procedure Wake;
  end;

implementation

uses
  IniFiles, fphttpclient, fpjson, jsonparser, opensslsockets, URIParser,
  ssockets, uRecorderNetworkBinding, uSharedFileLogger;

function JsonQuote(const AValue: string): string;
var
  lValue: TJSONString;
begin
  lValue := TJSONString.Create(AValue);
  try
    Result := lValue.AsJSON;
  finally
    lValue.Free;
  end;
end;

constructor TRecorderCoordinatorClientConfig.Create;
begin
  inherited Create;
  Enabled := True;
  BaseUrl := 'http://127.0.0.1:8765';
  InstanceId := RecorderCoordinatorNewId;
  DisplayName := GetEnvironmentVariable('COMPUTERNAME');
  if DisplayName = '' then DisplayName := GetEnvironmentVariable('HOSTNAME');
  HeartbeatMs := 3000;
  RequestTimeoutMs := 5000;
  AllowRemoteControl := True;
  AllowRemoteConfig := False;
end;

procedure TRecorderCoordinatorClientConfig.LoadFromFile(const AFileName: string);
var
  lIni: TIniFile;
begin
  FileName := ExpandFileName(AFileName);
  if not FileExists(AFileName) then
  begin
    SaveToFile(AFileName);
    Exit;
  end;
  lIni := TIniFile.Create(AFileName);
  try
    Enabled := lIni.ReadBool('Coordinator', 'Enabled', Enabled);
    BaseUrl := lIni.ReadString('Coordinator', 'BaseUrl', BaseUrl);
    InstanceId := lIni.ReadString('Coordinator', 'InstanceId', InstanceId);
    DisplayName := lIni.ReadString('Coordinator', 'DisplayName', DisplayName);
    AuthToken := lIni.ReadString('Coordinator', 'AuthToken', '');
    HeartbeatMs := lIni.ReadInteger('Coordinator', 'HeartbeatMs', HeartbeatMs);
    RequestTimeoutMs := lIni.ReadInteger('Coordinator', 'RequestTimeoutMs', RequestTimeoutMs);
    AllowRemoteControl := lIni.ReadBool('Coordinator', 'AllowRemoteControl', True);
    AllowRemoteConfig := lIni.ReadBool('Coordinator', 'AllowRemoteConfig', False);
  finally
    lIni.Free;
  end;
end;

procedure TRecorderCoordinatorClientConfig.SaveToFile(const AFileName: string);
var
  lIni: TIniFile;
begin
  FileName := ExpandFileName(AFileName);
  ForceDirectories(ExtractFileDir(AFileName));
  lIni := TIniFile.Create(AFileName);
  try
    lIni.WriteBool('Coordinator', 'Enabled', Enabled);
    lIni.WriteString('Coordinator', 'BaseUrl', BaseUrl);
    lIni.WriteString('Coordinator', 'InstanceId', InstanceId);
    lIni.WriteString('Coordinator', 'DisplayName', DisplayName);
    lIni.WriteString('Coordinator', 'AuthToken', AuthToken);
    lIni.WriteInteger('Coordinator', 'HeartbeatMs', HeartbeatMs);
    lIni.WriteInteger('Coordinator', 'RequestTimeoutMs', RequestTimeoutMs);
    lIni.WriteBool('Coordinator', 'AllowRemoteControl', AllowRemoteControl);
    lIni.WriteBool('Coordinator', 'AllowRemoteConfig', AllowRemoteConfig);
  finally
    lIni.Free;
  end;
end;

constructor TRecorderCoordinatorClient.Create(
  AConfig: TRecorderCoordinatorClientConfig);
begin
  inherited Create;
  fConfig := AConfig;
  fCommands := TThreadList.Create;
  fResults := TThreadList.Create;
  fEvents := TThreadList.Create;
  if (fConfig <> nil) and (fConfig.FileName <> '') then
    fOutboxFileName := ChangeFileExt(fConfig.FileName, '.events.json');
  LoadEventOutbox;
  fSnapshotLock := TCriticalSection.Create;
  fStateJson := '{}';
  fRecordingJson := '{}';
  fState := rccsDisabled;
  if fConfig <> nil then
    fDiscovery := TRecorderLanDiscovery.Create(rdrRecorder,
      fConfig.InstanceId, fConfig.DisplayName, 0);
end;

procedure TRecorderCoordinatorClient.LoadEventOutbox;
var
  lData, lItem: TJSONData;
  lEvent: TRecorderCoordinatorEvent;
  lFileName, lText: string;
  lList: TList;
  lStream: TStringList;
  I: Integer;
begin
  if fOutboxFileName = '' then Exit;
  lFileName := fOutboxFileName;
  if not FileExists(lFileName) then
  begin
    if FileExists(lFileName + '.bak') then lFileName := lFileName + '.bak'
    else if FileExists(lFileName + '.tmp') then lFileName := lFileName + '.tmp'
    else Exit;
  end;
  lStream := TStringList.Create;
  try
    lStream.LoadFromFile(lFileName);
    lText := lStream.Text;
  finally
    lStream.Free;
  end;
  try
    lData := GetJSON(lText);
    try
      if not (lData is TJSONArray) then Exit;
      lList := fEvents.LockList;
      try
        for I := 0 to TJSONArray(lData).Count - 1 do
        begin
          lItem := TJSONArray(lData).Items[I];
          if not (lItem is TJSONObject) then Continue;
          lEvent := TRecorderCoordinatorEvent.Create;
          lEvent.EventType := TJSONObject(lItem).Get('event_type', '');
          lEvent.CorrelationId := TJSONObject(lItem).Get('correlation_id', '');
          lEvent.PayloadJson := TJSONObject(lItem).Get('payload_json', '{}');
          if lEvent.EventType <> '' then lList.Add(lEvent) else lEvent.Free;
        end;
      finally
        fEvents.UnlockList;
      end;
    finally
      lData.Free;
    end;
  except
    on E: Exception do fLastError := 'Coordinator event outbox: ' + E.Message;
  end;
end;

procedure TRecorderCoordinatorClient.SaveEventOutboxLocked(AList: TList);
var
  lArray: TJSONArray;
  lEvent: TRecorderCoordinatorEvent;
  lItem: TJSONObject;
  lStream: TStringStream;
  lBackup, lTemp: string;
  I: Integer;
begin
  if fOutboxFileName = '' then Exit;
  lTemp := fOutboxFileName + '.tmp';
  lBackup := fOutboxFileName + '.bak';
  lArray := TJSONArray.Create;
  try
    for I := 0 to AList.Count - 1 do
    begin
      lEvent := TRecorderCoordinatorEvent(AList[I]);
      lItem := TJSONObject.Create;
      lItem.Add('event_type', lEvent.EventType);
      lItem.Add('correlation_id', lEvent.CorrelationId);
      lItem.Add('payload_json', lEvent.PayloadJson);
      lArray.Add(lItem);
    end;
    lStream := TStringStream.Create(lArray.AsJSON);
    try
      lStream.SaveToFile(lTemp);
    finally
      lStream.Free;
    end;
    if FileExists(lBackup) then DeleteFile(lBackup);
    if FileExists(fOutboxFileName) and
      (not RenameFile(fOutboxFileName, lBackup)) then
      raise Exception.Create('cannot rotate ' + fOutboxFileName);
    if not RenameFile(lTemp, fOutboxFileName) then
    begin
      if FileExists(lBackup) then RenameFile(lBackup, fOutboxFileName);
      raise Exception.Create('cannot replace ' + fOutboxFileName);
    end;
    if FileExists(lBackup) then DeleteFile(lBackup);
  finally
    lArray.Free;
  end;
end;

function TRecorderCoordinatorClient.GetAllowRemoteControl: Boolean;
begin
  Result := (fConfig <> nil) and fConfig.AllowRemoteControl;
end;

function TRecorderCoordinatorClient.GetAllowRemoteConfig: Boolean;
begin
  Result := (fConfig <> nil) and fConfig.AllowRemoteConfig;
end;

destructor TRecorderCoordinatorClient.Destroy;
var
  lList: TList;
begin
  Stop;
  FreeAndNil(fDiscovery);
  lList := fCommands.LockList;
  try while lList.Count > 0 do begin TObject(lList[0]).Free; lList.Delete(0); end;
  finally fCommands.UnlockList; end;
  lList := fResults.LockList;
  try while lList.Count > 0 do begin TObject(lList[0]).Free; lList.Delete(0); end;
  finally fResults.UnlockList; end;
  lList := fEvents.LockList;
  try while lList.Count > 0 do begin TObject(lList[0]).Free; lList.Delete(0); end;
  finally fEvents.UnlockList; end;
  fSnapshotLock.Free;
  fResults.Free;
  fEvents.Free;
  fCommands.Free;
  fConfig.Free;
  inherited Destroy;
end;

procedure TRecorderCoordinatorClient.PublishEvent(const AEventType,
  ACorrelationId, APayloadJson: string);
var
  lEvent: TRecorderCoordinatorEvent;
  lList: TList;
begin
  lEvent := TRecorderCoordinatorEvent.Create;
  lEvent.EventType := AEventType;
  lEvent.CorrelationId := ACorrelationId;
  lEvent.PayloadJson := APayloadJson;
  lList := fEvents.LockList;
  try
    lList.Add(lEvent);
    SharedLogger.Info(Format(
      'Coordinator lifecycle queued type=%s correlation=%s pending=%d',
      [AEventType, ACorrelationId, lList.Count]));
    try
      SaveEventOutboxLocked(lList);
    except
      on E: Exception do fLastError := 'Coordinator event outbox: ' + E.Message;
    end;
  finally
    fEvents.UnlockList;
  end;
  if fThread <> nil then fThread.Wake;
end;

procedure TRecorderCoordinatorClient.Start;
begin
  if (fThread <> nil) or (not fConfig.Enabled) then Exit;
  if fDiscovery <> nil then fDiscovery.Start;
  fThread := TRecorderCoordinatorClientThread.Create(Self);
  fThread.Start;
end;

procedure TRecorderCoordinatorClient.Stop;
begin
  if fDiscovery <> nil then fDiscovery.Stop;
  if fThread = nil then Exit;
  fState := rccsStopping;
  fThread.Terminate;
  { Wake sets fWakeEvent below: it releases either the 250 ms runtime pause or
    the reconnect backoff so Execute can observe Terminated and finish. }
  fThread.Wake;
  fThread.WaitFor;
  FreeAndNil(fThread);
  fState := rccsDisabled;
end;

procedure TRecorderCoordinatorClient.UpdateSnapshot(const AStateJson,
  ARecordingJson: string);
var
  lChanged: Boolean;
begin
  lChanged := False;
  fSnapshotLock.Acquire;
  try
    if (fStateJson <> AStateJson) or
      (fRecordingJson <> ARecordingJson) then
    begin
      fStateJson := AStateJson;
      fRecordingJson := ARecordingJson;
      Inc(fSnapshotGeneration);
      lChanged := True;
    end;
  finally
    fSnapshotLock.Release;
  end;
  if lChanged and (fThread <> nil) then
    fThread.Wake;
end;

function TRecorderCoordinatorClient.PopCommand: TRecorderCoordinatorCommand;
var
  lList: TList;
begin
  Result := nil;
  lList := fCommands.LockList;
  try
    if lList.Count > 0 then
    begin
      Result := TRecorderCoordinatorCommand(lList[0]);
      lList.Delete(0);
    end;
  finally
    fCommands.UnlockList;
  end;
end;

procedure TRecorderCoordinatorClient.CompleteCommand(
  ACommand: TRecorderCoordinatorCommand; ACode: TRecorderCoordinatorResultCode;
  const AText, APayloadJson: string);
var
  lResult: TRecorderCoordinatorResult;
begin
  if ACommand = nil then Exit;
  lResult := TRecorderCoordinatorResult.Create;
  lResult.CommandId := ACommand.CommandId;
  lResult.CorrelationId := ACommand.CorrelationId;
  lResult.Code := ACode;
  lResult.Text := AText;
  lResult.PayloadJson := APayloadJson;
  fResults.Add(lResult);
  ACommand.Free;
  if fThread <> nil then fThread.Wake;
end;

function TRecorderCoordinatorClient.TakeResult: TRecorderCoordinatorResult;
var
  lList: TList;
begin
  Result := nil;
  lList := fResults.LockList;
  try
    if lList.Count > 0 then
    begin
      Result := TRecorderCoordinatorResult(lList[0]);
      lList.Delete(0);
    end;
  finally
    fResults.UnlockList;
  end;
end;

constructor TRecorderCoordinatorClientThread.Create(
  AOwner: TRecorderCoordinatorClient);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fWakeEvent := TEvent.Create(nil, True, False, '');
  fBackoffMs := 500;
end;

destructor TRecorderCoordinatorClientThread.Destroy;
begin
  fWakeEvent.Free;
  inherited Destroy;
end;

procedure TRecorderCoordinatorClientThread.Wake;
begin
  fWakeEvent.SetEvent;
end;

function TRecorderCoordinatorClientThread.SnapshotChanged: Boolean;
begin
  fOwner.fSnapshotLock.Acquire;
  try
    Result := fSentSnapshotGeneration <> fOwner.fSnapshotGeneration;
  finally
    fOwner.fSnapshotLock.Release;
  end;
end;

function TRecorderCoordinatorClientThread.ServerReachable: Boolean;
var
  lBuffer: array[0..4095] of Byte;
  lError: string;
  lRead: LongInt;
  lRequest: RawByteString;
  lResponse: RawByteString;
  lStatusEnd, lStatusSpace: SizeInt;
  lStatusLine: RawByteString;
  lPort: Word;
  lDiscoveredUrl: string;
  lStream: TSocketStream;
  lUri: TURI;
begin
  Result := False;
  lStream := nil;
  lUri := ParseURI(fOwner.fConfig.BaseUrl);
  if lUri.Host = '' then
  begin
    fOwner.fLastError := 'Invalid coordinator URL: ' +
      fOwner.fConfig.BaseUrl;
    Exit;
  end;
  lPort := lUri.Port;
  if lPort = 0 then
    if SameText(lUri.Protocol, 'https') then
      lPort := 443
    else
      lPort := 80;
  { A refused/offline endpoint is normal while Recorder runs autonomously.
    Probe it through the non-raising socket API before fphttpclient: otherwise
    Lazarus debugger stops on the internally handled ESocketError. A connected
    HTTP socket must receive a complete request before it is closed; otherwise
    Coordinator reports a missing REQUEST_METHOD. }
  Result := RecorderOpenBoundTcpStream(lUri.Host, lPort,
    fOwner.fConfig.RequestTimeoutMs, lStream, lError, False, nil);
  if Result then
  begin
    lRequest := 'GET /api/v1/status HTTP/1.1'#13#10 +
      'Host: ' + lUri.Host + ':' + IntToStr(lPort) + #13#10 +
      'Connection: close'#13#10#13#10;
    try
      lStream.WriteBuffer(lRequest[1], Length(lRequest));
      lResponse := '';
      repeat
        lRead := lStream.Read(lBuffer, SizeOf(lBuffer));
        if lRead > 0 then
        begin
          if Length(lResponse) + lRead > 1024 * 1024 then
            raise Exception.Create('Coordinator preflight response is too large');
          SetLength(lResponse, Length(lResponse) + lRead);
          Move(lBuffer[0], lResponse[Length(lResponse) - lRead + 1], lRead);
        end;
      until lRead <= 0;
      lStatusEnd := Pos(#13#10, lResponse);
      if lStatusEnd = 0 then
        raise Exception.Create('Coordinator returned an invalid HTTP response');
      lStatusLine := Copy(lResponse, 1, lStatusEnd - 1);
      lStatusSpace := Pos(' ', lStatusLine);
      Result := (Pos('HTTP/', lStatusLine) = 1) and
        (lStatusSpace > 0) and (Length(lStatusLine) > lStatusSpace) and
        (lStatusLine[lStatusSpace + 1] = '2');
      if not Result then
        lError := 'Coordinator preflight failed: ' + string(lStatusLine);
    except
      on E: Exception do
      begin
        Result := False;
        lError := E.Message;
      end;
    end;
  end;
  lStream.Free;
  if not Result then
  begin
    fOwner.fLastError := lError;
    { Do not replace a healthy explicit endpoint. Discovery is consumed only
      after the configured endpoint has actually failed its HTTP preflight. }
    if (fOwner.fDiscovery <> nil) and
       fOwner.fDiscovery.TakeCoordinatorUrl(lDiscoveredUrl) and
       (lDiscoveredUrl <> fOwner.fConfig.BaseUrl) then
    begin
      fOwner.fConfig.BaseUrl := lDiscoveredUrl;
      fOwner.fLastError := '';
      SharedLogger.Info('Coordinator endpoint selected by discovery: ' +
        lDiscoveredUrl);
      Result := ServerReachable;
    end;
  end;
end;

function TRecorderCoordinatorClientThread.PostJson(const APath, AJson: string;
  out AResponse: string): Boolean;
var
  lClient: TFPHTTPClient;
  lBody, lResponse: TStringStream;
begin
  Result := False;
  AResponse := '';
  if not ServerReachable then
    Exit;
  lClient := TFPHTTPClient.Create(nil);
  lBody := TStringStream.Create(AJson);
  lResponse := TStringStream.Create('');
  try
    lClient.ConnectTimeout := fOwner.fConfig.RequestTimeoutMs;
    lClient.IOTimeout := fOwner.fConfig.RequestTimeoutMs;
    lClient.AddHeader('Content-Type', 'application/json');
    if fOwner.fConfig.AuthToken <> '' then
      lClient.AddHeader('Authorization', 'Bearer ' + fOwner.fConfig.AuthToken);
    lClient.RequestBody := lBody;
    lClient.Post(fOwner.fConfig.BaseUrl + APath, lResponse);
    AResponse := lResponse.DataString;
    Result := lClient.ResponseStatusCode div 100 = 2;
    if Result then
      fOwner.fLastError := ''
    else
      fOwner.fLastError := Format('Coordinator HTTP %d: %s',
        [lClient.ResponseStatusCode, Trim(AResponse)]);
  except
    on E: Exception do fOwner.fLastError := E.Message;
  end;
  lResponse.Free;
  lBody.Free;
  lClient.Free;
end;

function TRecorderCoordinatorClientThread.HttpGetJson(const APath: string;
  out AResponse: string): Boolean;
var
  lClient: TFPHTTPClient;
begin
  Result := False;
  AResponse := '';
  if not ServerReachable then
    Exit;
  lClient := TFPHTTPClient.Create(nil);
  try
    lClient.ConnectTimeout := fOwner.fConfig.RequestTimeoutMs;
    lClient.IOTimeout := fOwner.fConfig.RequestTimeoutMs;
    if fOwner.fConfig.AuthToken <> '' then
      lClient.AddHeader('Authorization', 'Bearer ' + fOwner.fConfig.AuthToken);
    try
      AResponse := lClient.Get(fOwner.fConfig.BaseUrl + APath);
      Result := lClient.ResponseStatusCode div 100 = 2;
      if Result then
        fOwner.fLastError := ''
      else
        fOwner.fLastError := Format('Coordinator HTTP %d: %s',
          [lClient.ResponseStatusCode, Trim(AResponse)]);
    except
      on E: Exception do fOwner.fLastError := E.Message;
    end;
  finally
    lClient.Free;
  end;
end;

procedure TRecorderCoordinatorClientThread.SendHello;
var
  lPayload, lResponse: string;
begin
  lPayload := Format('{"display_name":%s,"protocol_version":%d}',
    [JsonQuote(fOwner.fConfig.DisplayName),
     CRecorderCoordinatorProtocolVersion]);
  PostJson('/api/v1/clients/hello', RecorderCoordinatorEnvelope('client.hello',
    RecorderCoordinatorNewId, fOwner.fConfig.InstanceId, '', '', lPayload),
    lResponse);
end;

procedure TRecorderCoordinatorClientThread.SendHeartbeat;
var
  lPayload, lResponse: string;
  lSnapshotGeneration: QWord;
begin
  fOwner.fSnapshotLock.Acquire;
  try
    lPayload := '{"state":' + fOwner.fStateJson + ',"recording":' +
      fOwner.fRecordingJson + '}';
    lSnapshotGeneration := fOwner.fSnapshotGeneration;
  finally
    fOwner.fSnapshotLock.Release;
  end;
  if PostJson('/api/v1/clients/heartbeat',
    RecorderCoordinatorEnvelope('client.heartbeat', RecorderCoordinatorNewId,
      fOwner.fConfig.InstanceId, '', '', lPayload), lResponse) then
  begin
    fSentSnapshotGeneration := lSnapshotGeneration;
    fLastHeartbeat := GetTickCount64;
  end;
end;

procedure TRecorderCoordinatorClientThread.SendResults;
var
  lResult: TRecorderCoordinatorResult;
  lPayload, lResponse: string;
  lRequeued: Boolean;
begin
  repeat
    lResult := fOwner.TakeResult;
    if lResult = nil then Exit;
    lRequeued := False;
    try
      lPayload := Format('{"command_id":%s,"code":%s,"text":%s,"result":%s}',
        [JsonQuote(lResult.CommandId),
         JsonQuote(RecorderCoordinatorResultCodeName(lResult.Code)),
         JsonQuote(lResult.Text), lResult.PayloadJson]);
      if not PostJson('/api/v1/commands/result',
        RecorderCoordinatorEnvelope('command.result', RecorderCoordinatorNewId,
          fOwner.fConfig.InstanceId, lResult.CorrelationId, lResult.CommandId,
          lPayload), lResponse) then
      begin
        fOwner.fResults.Add(lResult);
        lRequeued := True;
        Exit;
      end;
    finally
      if not lRequeued then lResult.Free;
    end;
  until Terminated;
end;

procedure TRecorderCoordinatorClientThread.SendEvents;
var
  lList: TList;
  lEvent: TRecorderCoordinatorEvent;
  lResponse: string;
begin
  lEvent := nil;
  lList := fOwner.fEvents.LockList;
  try
    if lList.Count > 0 then
      lEvent := TRecorderCoordinatorEvent(lList[0]);
  finally
    fOwner.fEvents.UnlockList;
  end;
  if lEvent = nil then Exit;
  if PostJson('/api/v1/events', RecorderCoordinatorEnvelope(lEvent.EventType,
    RecorderCoordinatorNewId, fOwner.fConfig.InstanceId, lEvent.CorrelationId,
    '', lEvent.PayloadJson), lResponse) then
  begin
    lList := fOwner.fEvents.LockList;
    try
      if (lList.Count > 0) and (TObject(lList[0]) = lEvent) then
      begin
        SharedLogger.Info(Format(
          'Coordinator lifecycle delivered type=%s correlation=%s',
          [lEvent.EventType, lEvent.CorrelationId]));
        lList.Delete(0);
        lEvent.Free;
      end;
      try
        fOwner.SaveEventOutboxLocked(lList);
      except
        on E: Exception do
          fOwner.fLastError := 'Coordinator event outbox: ' + E.Message;
      end;
    finally
      fOwner.fEvents.UnlockList;
    end;
  end
  else
    { The event remains first both in memory and in the durable outbox. This
      preserves lifecycle order and permits retry after process restart. };
end;

procedure TRecorderCoordinatorClientThread.PollCommand;
var
  lResponse: string;
  lJson: TJSONData;
  lCommand: TRecorderCoordinatorCommand;
begin
  if not HttpGetJson('/api/v1/commands/next?instance_id=' +
    EncodeURLElement(fOwner.fConfig.InstanceId), lResponse) then Exit;
  if Trim(lResponse) = '' then Exit;
  try
    lJson := GetJSON(lResponse);
    try
      lCommand := TRecorderCoordinatorCommand.FromJson(lJson);
      if (lCommand <> nil) and (lCommand.CommandId <> '') then
        fOwner.fCommands.Add(lCommand)
      else
        lCommand.Free;
    finally
      lJson.Free;
    end;
  except
    on E: Exception do fOwner.fLastError := 'Invalid coordinator command: ' + E.Message;
  end;
end;

procedure TRecorderCoordinatorClientThread.Execute;
begin
  fOwner.fState := rccsConnecting;
  while not Terminated do
  begin
    SendHello;
    if fOwner.fLastError = '' then
    begin
      fOwner.fState := rccsOnline;
      fBackoffMs := 500;
      while not Terminated and (fOwner.fState = rccsOnline) do
      begin
        { Reset before inspecting pending work. A concurrent SetEvent after
          this point remains signaled and prevents the pause below. }
        fWakeEvent.ResetEvent;
        if SnapshotChanged or
          (fLastHeartbeat = 0) or
          (GetTickCount64 - fLastHeartbeat >= QWord(fOwner.fConfig.HeartbeatMs)) then
          SendHeartbeat;
        SendResults;
        SendEvents;
        PollCommand;
        if fOwner.fLastError <> '' then Break;
        { Released by TRecorderCoordinatorClientThread.Wake from Stop or when
          a command/event is queued; timeout schedules the next poll. }
        fWakeEvent.WaitFor(250);
      end;
    end;
    if Terminated then Break;
    fOwner.fState := rccsBackoff;
    { Released by TRecorderCoordinatorClientThread.Wake from Stop or queued
      work; timeout schedules the next reconnect attempt. }
    fWakeEvent.WaitFor(fBackoffMs);
    fWakeEvent.ResetEvent;
    if fBackoffMs < 15000 then fBackoffMs := fBackoffMs * 2;
    fOwner.fLastError := '';
    fOwner.fState := rccsConnecting;
  end;
end;

end.
