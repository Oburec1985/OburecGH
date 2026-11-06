unit uRecorderCoordinatorClient;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, SyncObjs, uRecorderCoordinatorProtocol,
  uRecorderLanDiscovery, uRecorderCoordinatorOwnership;

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
    UseComputerName: Boolean;
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
    OwnershipGeneration: QWord;
  end;

  TRecorderCoordinatorEvent = class
  public
    EventType: string;
    CorrelationId: string;
    PayloadJson: string;
    CoordinatorId: string;
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
    fOwnership: TRecorderCoordinatorOwnership;
    fCommandOrigins: TStringList;
    fRecordingOrigins: TStringList;
    procedure ClearPendingCommands;
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
    procedure GetWorkstationName(out AName: string; out AUseComputerName: Boolean);
    procedure SetWorkstationName(const AName: string; AUseComputerName: Boolean);
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
    procedure ProcessControlRequests;
    procedure ReleaseOwnership;
    function OwnershipJson: string;
    function ServerReachable(const AExpectedCoordinatorId: string = ''): Boolean;
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

function RecorderComputerName: string;

implementation

uses
  IniFiles, fphttpclient, fpjson, jsonparser, opensslsockets, URIParser,
  ssockets, uRecorderNetworkBinding, uSharedFileLogger
  {$ifdef unix}, BaseUnix{$endif};

function RecorderComputerName: string;
{$ifdef unix}
var
  lInfo: utsname;
{$endif}
begin
  {$ifdef unix}
  if fpUname(lInfo) = 0 then
    Exit(StrPas(@lInfo.nodename[0]));
  {$endif}
  Result := GetEnvironmentVariable('COMPUTERNAME');
  if Result = '' then Result := GetEnvironmentVariable('HOSTNAME');
end;

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

function RecorderHostInfoJson: string;
var
  lMacAddresses: TStringList;
  lHostName, lPlatform: string;
begin
  lHostName := RecorderComputerName;
{$ifdef windows}
  lPlatform := 'windows';
{$else}
  lPlatform := 'linux';
{$endif}
  lMacAddresses := TStringList.Create;
  try
    RecorderEnumerateLocalMacAddresses(lMacAddresses);
    Result := Format('"host_name":%s,"mac_addresses":%s,' +
      '"executable_path":%s,"os":%s',
      [JsonQuote(lHostName), JsonQuote(lMacAddresses.CommaText),
       JsonQuote(ExpandFileName(ParamStr(0))), JsonQuote(lPlatform)]);
  finally
    lMacAddresses.Free;
  end;
end;

constructor TRecorderCoordinatorClientConfig.Create;
begin
  inherited Create;
  Enabled := True;
  BaseUrl := '';
  InstanceId := RecorderCoordinatorNewId;
  DisplayName := RecorderComputerName;
  UseComputerName := True;
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
    { An endpoint is a runtime lease, never a workstation preference. }
    BaseUrl := '';
    InstanceId := lIni.ReadString('Coordinator', 'InstanceId', InstanceId);
    if Trim(InstanceId) = '' then InstanceId := RecorderCoordinatorNewId;
    if lIni.ReadString('Coordinator', 'InstanceId', '') <> InstanceId then
      lIni.WriteString('Coordinator', 'InstanceId', InstanceId);
    lIni.DeleteKey('Coordinator', 'BaseUrl');
    DisplayName := lIni.ReadString('Coordinator', 'DisplayName', DisplayName);
    UseComputerName := lIni.ReadBool('Coordinator', 'UseComputerName', True);
    if UseComputerName then DisplayName := RecorderComputerName;
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
    lIni.DeleteKey('Coordinator', 'BaseUrl');
    lIni.WriteString('Coordinator', 'InstanceId', InstanceId);
    lIni.WriteString('Coordinator', 'DisplayName', DisplayName);
    lIni.WriteBool('Coordinator', 'UseComputerName', UseComputerName);
    lIni.WriteString('Coordinator', 'AuthToken', AuthToken);
    lIni.WriteInteger('Coordinator', 'HeartbeatMs', HeartbeatMs);
    lIni.WriteInteger('Coordinator', 'RequestTimeoutMs', RequestTimeoutMs);
    lIni.WriteBool('Coordinator', 'AllowRemoteControl', AllowRemoteControl);
    lIni.WriteBool('Coordinator', 'AllowRemoteConfig', AllowRemoteConfig);
  finally
    lIni.Free;
  end;
end;

procedure TRecorderCoordinatorClient.GetWorkstationName(out AName: string;
  out AUseComputerName: Boolean);
begin
  fSnapshotLock.Acquire;
  try
    AName := fConfig.DisplayName;
    AUseComputerName := fConfig.UseComputerName;
  finally
    fSnapshotLock.Release;
  end;
  if AUseComputerName then AName := RecorderComputerName;
end;

procedure TRecorderCoordinatorClient.SetWorkstationName(const AName: string;
  AUseComputerName: Boolean);
var
  lName: string;
  lIni: TIniFile;
begin
  if AUseComputerName then lName := RecorderComputerName
  else lName := Trim(AName);
  if (lName = '') or (Length(lName) > 255) or
    (Pos(#0, lName) > 0) or (Pos(#10, lName) > 0) or (Pos(#13, lName) > 0) then
    raise Exception.Create('Invalid workstation name');
  lIni := TIniFile.Create(fConfig.FileName);
  try
    lIni.CacheUpdates := True;
    lIni.WriteString('Coordinator', 'DisplayName', lName);
    lIni.WriteBool('Coordinator', 'UseComputerName', AUseComputerName);
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
  fSnapshotLock.Acquire;
  try
    fConfig.DisplayName := lName;
    fConfig.UseComputerName := AUseComputerName;
  finally
    fSnapshotLock.Release;
  end;
  if fDiscovery <> nil then fDiscovery.SetDisplayName(lName);
end;

constructor TRecorderCoordinatorClient.Create(
  AConfig: TRecorderCoordinatorClientConfig);
var
  lMacAddresses, lLocalAddresses: TStringList;
  I: Integer;
  lAddress: string;
begin
  inherited Create;
  fConfig := AConfig;
  fOwnership := TRecorderCoordinatorOwnership.Create;
  fCommandOrigins := TStringList.Create;
  fRecordingOrigins := TStringList.Create;
  fSnapshotLock := TCriticalSection.Create;
  fCommands := TThreadList.Create;
  fResults := TThreadList.Create;
  fEvents := TThreadList.Create;
  if (fConfig <> nil) and (fConfig.FileName <> '') then
    fOutboxFileName := ChangeFileExt(fConfig.FileName, '.events.json');
  LoadEventOutbox;
  fStateJson := '{}';
  fRecordingJson := '{}';
  fState := rccsDisabled;
  if fConfig <> nil then
  begin
    lMacAddresses := TStringList.Create;
    lLocalAddresses := TStringList.Create;
    try
      RecorderEnumerateLocalMacAddresses(lMacAddresses);
      RecorderEnumerateLocalIPv4(lLocalAddresses);
      for I := lLocalAddresses.Count - 1 downto 0 do
      begin
        lAddress := RecorderNetworkAddressFromDisplay(lLocalAddresses[I]);
        if (lAddress = '') or (Pos('127.', lAddress) = 1) or
          (Pos('169.254.', lAddress) = 1) then
          lLocalAddresses.Delete(I)
        else
          lLocalAddresses[I] := lAddress;
      end;
      fDiscovery := TRecorderLanDiscovery.Create(rdrRecorder,
        fConfig.InstanceId, fConfig.DisplayName, 0,
        lMacAddresses.CommaText, lLocalAddresses.CommaText);
      fDiscovery.SetControlToken(fConfig.AuthToken);
    finally
      lMacAddresses.Free;
      lLocalAddresses.Free;
    end;
  end;
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
          if TJSONObject(lItem).Get('internal_kind', '') = 'recording_origin' then
          begin
            fRecordingOrigins.Add(TJSONObject(lItem).Get('correlation_id', '') +
              '=' + TJSONObject(lItem).Get('coordinator_id', ''));
            Continue;
          end;
          lEvent := TRecorderCoordinatorEvent.Create;
          lEvent.EventType := TJSONObject(lItem).Get('event_type', '');
          lEvent.CorrelationId := TJSONObject(lItem).Get('correlation_id', '');
          lEvent.PayloadJson := TJSONObject(lItem).Get('payload_json', '{}');
          lEvent.CoordinatorId := TJSONObject(lItem).Get('coordinator_id', '');
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
    fSnapshotLock.Acquire;
    try
      for I := 0 to fRecordingOrigins.Count - 1 do
      begin
        lItem := TJSONObject.Create;
        lItem.Add('internal_kind', 'recording_origin');
        lItem.Add('correlation_id', fRecordingOrigins.Names[I]);
        lItem.Add('coordinator_id', fRecordingOrigins.ValueFromIndex[I]);
        lArray.Add(lItem);
      end;
    finally
      fSnapshotLock.Release;
    end;
    for I := 0 to AList.Count - 1 do
    begin
      lEvent := TRecorderCoordinatorEvent(AList[I]);
      lItem := TJSONObject.Create;
      lItem.Add('event_type', lEvent.EventType);
      lItem.Add('correlation_id', lEvent.CorrelationId);
      lItem.Add('payload_json', lEvent.PayloadJson);
      lItem.Add('coordinator_id', lEvent.CoordinatorId);
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

procedure TRecorderCoordinatorClient.ClearPendingCommands;
var
  lList: TList;
begin
  lList := fCommands.LockList;
  try
    while lList.Count > 0 do
    begin
      TObject(lList[0]).Free;
      lList.Delete(0);
    end;
  finally
    fCommands.UnlockList;
  end;
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
  fOwnership.Free;
  fCommandOrigins.Free;
  fRecordingOrigins.Free;
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
  fSnapshotLock.Acquire;
  try
    if (ACorrelationId <> '') and
      (fRecordingOrigins.IndexOfName(ACorrelationId) >= 0) then
      lEvent.CoordinatorId := fRecordingOrigins.Values[ACorrelationId]
    else if (ACorrelationId <> '') and
      (fCommandOrigins.IndexOfName(ACorrelationId) >= 0) then
      lEvent.CoordinatorId := fCommandOrigins.Values[ACorrelationId]
    else lEvent.CoordinatorId := fOwnership.CoordinatorId;
    { A recording outlives its start command and may span a takeover. Pin its
      origin independently of the bounded command history, including restart. }
    if (AEventType = 'recording.started') and (ACorrelationId <> '') then
    begin
      fRecordingOrigins.Clear;
      fRecordingOrigins.Add(ACorrelationId + '=' + lEvent.CoordinatorId);
    end
    else if (AEventType = 'recording.completed') and
      (fRecordingOrigins.IndexOfName(ACorrelationId) >= 0) then
      fRecordingOrigins.Delete(fRecordingOrigins.IndexOfName(ACorrelationId));
  finally
    fSnapshotLock.Release;
  end;
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
  fSnapshotLock.Acquire;
  try
    fOwnership.Clear;
    fConfig.BaseUrl := '';
  finally
    fSnapshotLock.Release;
  end;
  ClearPendingCommands;
  if fDiscovery <> nil then fDiscovery.SetControlOwner('', '');
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
    while lList.Count > 0 do
    begin
      Result := TRecorderCoordinatorCommand(lList[0]);
      lList.Delete(0);
      fSnapshotLock.Acquire;
      try
        if (fOwnership.CoordinatorId <> '') and
          (Result.OwnershipGeneration = fOwnership.Generation) then Exit;
      finally
        fSnapshotLock.Release;
      end;
      FreeAndNil(Result);
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
  lResult.OwnershipGeneration := ACommand.OwnershipGeneration;
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

function TRecorderCoordinatorClientThread.ServerReachable(
  const AExpectedCoordinatorId: string): Boolean;
var
  lBuffer: array[0..4095] of Byte;
  lError: string;
  lRead: LongInt;
  lRequest: RawByteString;
  lResponse: RawByteString;
  lStatusEnd, lStatusSpace: SizeInt;
  lStatusLine: RawByteString;
  lPort: Word;
  lStream: TSocketStream;
  lUri: TURI;
  lJson: TJSONData;
  lBodyStart: SizeInt;
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
      'Host: ' + lUri.Host + ':' + IntToStr(lPort) + #13#10;
    if fOwner.fConfig.AuthToken <> '' then
      lRequest := lRequest + 'Authorization: Bearer ' + fOwner.fConfig.AuthToken + #13#10;
    lRequest := lRequest + 'Connection: close'#13#10#13#10;
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
      if Result and (AExpectedCoordinatorId <> '') then
      begin
        lBodyStart := Pos(#13#10#13#10, lResponse);
        if lBodyStart = 0 then
          raise Exception.Create('Coordinator identity response is missing');
        lJson := GetJSON(Copy(lResponse, lBodyStart + 4, MaxInt));
        try
          Result := (lJson is TJSONObject) and
            (TJSONObject(lJson).Get('coordinator_instance_id', '') = AExpectedCoordinatorId);
          if not Result then lError := 'Coordinator identity does not match claim';
        finally
          lJson.Free;
        end;
      end;
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
  end;
end;

procedure TRecorderCoordinatorClientThread.ReleaseOwnership;
begin
  fOwner.fSnapshotLock.Acquire;
  try
    fOwner.fOwnership.Clear;
    fOwner.fConfig.BaseUrl := '';
  finally
    fOwner.fSnapshotLock.Release;
  end;
  fOwner.ClearPendingCommands;
  fOwner.fDiscovery.SetControlOwner('', '');
  fOwner.fState := rccsConnecting;
  fSentSnapshotGeneration := 0;
  fLastHeartbeat := 0;
end;

procedure TRecorderCoordinatorClientThread.ProcessControlRequests;
var
  lRequest: TRecorderCoordinatorControlRequest;
  lOldUrl: string;
  lOldGeneration: QWord;
  lAllowed: Boolean;
  lList: TList;
  lIndex: Integer;
begin
  while fOwner.fDiscovery.TakeControlRequest(lRequest) do
  begin
    if lRequest.Release then
    begin
      if (fOwner.fOwnership.CoordinatorId = lRequest.CoordinatorId) and
        (fOwner.fOwnership.ClaimId = lRequest.ClaimId) then
        ReleaseOwnership;
      Continue;
    end;
    fOwner.fSnapshotLock.Acquire;
    try
      lAllowed := fOwner.fOwnership.CanClaim(lRequest.CoordinatorId,
        lRequest.ClaimId, lRequest.Force);
      lOldUrl := fOwner.fConfig.BaseUrl;
      lOldGeneration := fOwner.fOwnership.Generation;
    finally
      fOwner.fSnapshotLock.Release;
    end;
    if not lAllowed then
    begin
      fOwner.fDiscovery.RequestSearch;
      Continue;
    end;
    { Validate the requested peer before abandoning the current owner. UDP
      announces alone never transfer a Recorder or execute a command. }
    fOwner.fConfig.BaseUrl := lRequest.CoordinatorUrl;
    if not ServerReachable(lRequest.CoordinatorId) then
    begin
      fOwner.fConfig.BaseUrl := lOldUrl;
      Continue;
    end;
    fOwner.fSnapshotLock.Acquire;
    try
      fOwner.fOwnership.Accept(lRequest.CoordinatorId, lRequest.ClaimId,
        lRequest.CoordinatorUrl, GetTickCount64);
      for lIndex := 0 to fOwner.fRecordingOrigins.Count - 1 do
        if fOwner.fRecordingOrigins.ValueFromIndex[lIndex] = '' then
          fOwner.fRecordingOrigins.ValueFromIndex[lIndex] := lRequest.CoordinatorId;
    finally
      fOwner.fSnapshotLock.Release;
    end;
    if lOldGeneration <> fOwner.fOwnership.Generation then
      fOwner.ClearPendingCommands;
    { Events created while autonomous have no former controller. Bind them
      once; previously addressed durable events stay with their origin. }
    lList := fOwner.fEvents.LockList;
    try
      for lIndex := 0 to lList.Count - 1 do
        if TRecorderCoordinatorEvent(lList[lIndex]).CoordinatorId = '' then
          TRecorderCoordinatorEvent(lList[lIndex]).CoordinatorId := lRequest.CoordinatorId;
      try
        fOwner.SaveEventOutboxLocked(lList);
      except
        on E: Exception do SharedLogger.Error('Coordinator event owner outbox: ' + E.Message);
      end;
    finally
      fOwner.fEvents.UnlockList;
    end;
    fOwner.fDiscovery.SetControlOwner(lRequest.CoordinatorId, lRequest.ClaimId);
    fOwner.fLastError := '';
    fOwner.fState := rccsConnecting;
    fSentSnapshotGeneration := 0;
    fLastHeartbeat := 0;
    SharedLogger.Info('Coordinator control claimed by ' + lRequest.CoordinatorId);
  end;
end;

function TRecorderCoordinatorClientThread.OwnershipJson: string;
begin
  Result := '"coordinator_instance_id":' + JsonQuote(fOwner.fOwnership.CoordinatorId) +
    ',"coordinator_claim_id":' + JsonQuote(fOwner.fOwnership.ClaimId);
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
    begin
      fOwner.fOwnership.LastSuccess := GetTickCount64;
      fOwner.fLastError := ''
    end
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
      begin
        fOwner.fOwnership.LastSuccess := GetTickCount64;
        fOwner.fLastError := ''
      end
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
  lPayload, lResponse, lName: string;
  lUseComputerName: Boolean;
begin
  fOwner.GetWorkstationName(lName, lUseComputerName);
  lPayload := Format('{"display_name":%s,"protocol_version":%d,%s,%s}',
    [JsonQuote(lName),
     CRecorderCoordinatorProtocolVersion, RecorderHostInfoJson, OwnershipJson]);
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
      fOwner.fRecordingJson + ',' + RecorderHostInfoJson + ',' + OwnershipJson + '}';
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
    if lResult.OwnershipGeneration <> fOwner.fOwnership.Generation then
    begin
      lResult.Free;
      Continue;
    end;
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
  lIndex: Integer;
begin
  lEvent := nil;
  lList := fOwner.fEvents.LockList;
  try
    for lIndex := 0 to lList.Count - 1 do
      if TRecorderCoordinatorEvent(lList[lIndex]).CoordinatorId =
        fOwner.fOwnership.CoordinatorId then
      begin
        lEvent := TRecorderCoordinatorEvent(lList[lIndex]);
        Break;
      end;
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
      lIndex := lList.IndexOf(lEvent);
      if lIndex >= 0 then
      begin
        SharedLogger.Info(Format(
          'Coordinator lifecycle delivered type=%s correlation=%s',
          [lEvent.EventType, lEvent.CorrelationId]));
        lList.Delete(lIndex);
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
      if not (lJson is TJSONObject) then Exit;
      if TJSONObject(lJson).Get('coordinator_claim_id', '') <>
        fOwner.fOwnership.ClaimId then Exit;
      lCommand := TRecorderCoordinatorCommand.FromJson(lJson);
      if (lCommand <> nil) and (lCommand.CommandId <> '') then
      begin
        lCommand.OwnershipGeneration := fOwner.fOwnership.Generation;
        if lCommand.CorrelationId <> '' then
        begin
          fOwner.fSnapshotLock.Acquire;
          try
            fOwner.fCommandOrigins.Values[lCommand.CorrelationId] :=
              fOwner.fOwnership.CoordinatorId;
            if fOwner.fCommandOrigins.Count > 512 then
              fOwner.fCommandOrigins.Delete(0);
          finally
            fOwner.fSnapshotLock.Release;
          end;
        end;
        fOwner.fCommands.Add(lCommand)
      end
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
    fWakeEvent.ResetEvent;
    ProcessControlRequests;
    if (fOwner.fOwnership.CoordinatorId <> '') and
      (GetTickCount64 - fOwner.fOwnership.LastSuccess >= CRecorderCoordinatorLeaseMs) then
      ReleaseOwnership;
    if fOwner.fOwnership.CoordinatorId = '' then
    begin
      fOwner.fLastError := '';
      fWakeEvent.WaitFor(250);
      Continue;
    end;
    fOwner.fLastError := '';
    if fOwner.fState <> rccsOnline then SendHello;
    if fOwner.fLastError = '' then
    begin
      fOwner.fState := rccsOnline;
      if SnapshotChanged or (fLastHeartbeat = 0) or
        (GetTickCount64 - fLastHeartbeat >= QWord(fOwner.fConfig.HeartbeatMs)) then
        SendHeartbeat;
      if fOwner.fLastError = '' then SendResults;
      if fOwner.fLastError = '' then SendEvents;
      if fOwner.fLastError = '' then PollCommand;
    end;
    if fOwner.fLastError <> '' then fOwner.fState := rccsBackoff;
    { The bounded pause also services newly queued ownership requests while
      the old coordinator is unavailable. No automatic discovery takeover. }
    fWakeEvent.WaitFor(250);
  end;
end;

end.
