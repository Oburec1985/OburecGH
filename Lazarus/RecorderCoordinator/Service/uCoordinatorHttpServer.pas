unit uCoordinatorHttpServer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs, Sockets, fphttpserver, httpdefs, fpjson, jsonparser,
  uCoordinatorModel, uCoordinatorHostMonitor, uSharedFileLogger,
  uRecorderLanDiscovery;

type
  TCoordinatorPendingClaim = class
  public
    Address, InstanceId, ClaimId: string;
    Force: Boolean;
    Attempts: Integer;
    NextAttempt: QWord;
  end;

  TCoordinatorFpHttpServer = class(TFPHTTPServer)
  public
    procedure SetListenAddress(const AValue: string);
  end;

  TCoordinatorListenerThread = class(TThread)
  private
    fServer: TCoordinatorFpHttpServer;
    fErrorLock: TCriticalSection;
    fLastError: string;
    procedure SetLastError(const AValue: string);
  protected
    procedure Execute; override;
  public
    constructor Create(AServer: TCoordinatorFpHttpServer);
    destructor Destroy; override;
    function LastError: string;
  end;

  TCoordinatorHttpServer = class
  private
    fServer: TCoordinatorFpHttpServer;
    fThread: TCoordinatorListenerThread;
    fModel: TCoordinatorModel;
    fDiscovery: TRecorderLanDiscovery;
    fHostMonitor: TCoordinatorHostMonitor;
    fLastError: string;
    fControlId, fControlToken: string;
    fPendingClaims: TFPList;
    procedure DiscoveryOwnerFound(const AInstanceId, AOwnerId,
      AClaimId: string);
    procedure ReleaseFinishedThread;
    function PortAvailable(APort: Word): Boolean;
    procedure DiscoveryRecorderFound(const AInstanceId, ADisplayName,
      AAddress, ABaseUrl, AMacAddresses: string);
    procedure HandleRequest(Sender: TObject;
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
    function ReadBody(ARequest: TFPHTTPConnectionRequest): TJSONObject;
    procedure SendJson(var AResponse: TFPHTTPConnectionResponse;
      AData: TJSONData; AStatusCode: Integer = 200);
  public
    constructor Create(AModel: TCoordinatorModel; AAgentPort: Word = 8766;
      const AAgentToken: string = '');
    destructor Destroy; override;
    procedure Start(const AAddress: string; APort: Word);
    procedure Stop;
    procedure SearchRecorders;
    procedure ConfigureControl(const AInstanceId, AToken: string);
    function ClaimRecorder(const AAddress, AInstanceId: string;
      AForce: Boolean): string;
    procedure ReleaseRecorder(const AAddress, AInstanceId, AClaimId: string);
    procedure RetryControlRequests;
    property ControlId: string read fControlId;
    function Active: Boolean;
    function Stopping: Boolean;
    function LastError: string;
  end;

implementation

uses uRecorderNetworkBinding;

constructor TCoordinatorListenerThread.Create(AServer: TCoordinatorFpHttpServer);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fServer := AServer;
  fErrorLock := TCriticalSection.Create;
end;

destructor TCoordinatorListenerThread.Destroy;
begin
  fErrorLock.Free;
  inherited Destroy;
end;

procedure TCoordinatorListenerThread.SetLastError(const AValue: string);
begin
  fErrorLock.Acquire;
  try
    fLastError := AValue;
  finally
    fErrorLock.Release;
  end;
end;

procedure TCoordinatorListenerThread.Execute;
begin
  RegisterThreadName(GetThreadID, 'CoordinatorHttpListener');
  SetLastError('');
  SharedLogger.Info('HTTP listener starting');
  try
    if not Terminated then
      fServer.Active := True;
  except
    on E: Exception do
    begin
      SetLastError(E.Message);
      SharedLogger.Error('HTTP listener error class=' + E.ClassName +
        ' message=' + E.Message);
    end;
  end;
  SharedLogger.Info('HTTP listener stopped');
end;

function TCoordinatorListenerThread.LastError: string;
begin
  fErrorLock.Acquire;
  try
    Result := fLastError;
  finally
    fErrorLock.Release;
  end;
end;

procedure TCoordinatorFpHttpServer.SetListenAddress(const AValue: string);
begin
  Address := AValue;
end;

constructor TCoordinatorHttpServer.Create(AModel: TCoordinatorModel;
  AAgentPort: Word; const AAgentToken: string);
var
  lId: TGUID;
begin
  inherited Create;
  CreateGUID(lId);
  fControlId := GUIDToString(lId);
  fPendingClaims := TFPList.Create;
  fModel := AModel;
  fModel.ControlId := fControlId;
  fModel.EnableHostPersistence;
  fServer := TCoordinatorFpHttpServer.Create(nil);
  fServer.Threaded := True;
  { A nonzero timeout keeps accept in a bounded select loop. StopAccepting
    changes FAccepting; no OnAcceptIdle callback or synthetic connection is
    needed to make the loop observe that state. }
  fServer.AcceptIdleTimeout := 50;
  fServer.OnRequest := @HandleRequest;
  fHostMonitor := TCoordinatorHostMonitor.Create(fModel, AAgentPort, AAgentToken);
  fHostMonitor.Start;
end;

procedure TCoordinatorHttpServer.ConfigureControl(const AInstanceId,
  AToken: string);
begin
  if fDiscovery <> nil then
    raise Exception.Create('Control identity cannot change while running');
  if Trim(AInstanceId) <> '' then fControlId := AInstanceId;
  fModel.ControlId := fControlId;
  fControlToken := AToken;
end;

procedure TCoordinatorHttpServer.DiscoveryOwnerFound(const AInstanceId,
  AOwnerId, AClaimId: string);
begin
  fModel.ApplyControlOwner(AInstanceId, AOwnerId, AClaimId);
end;

function TCoordinatorHttpServer.ClaimRecorder(const AAddress,
  AInstanceId: string; AForce: Boolean): string;
var
  lClaim: TCoordinatorPendingClaim;
  lId: TGUID;
  lIndex: Integer;
begin
  Result := '';
  if (fDiscovery = nil) or (Trim(AAddress) = '') then Exit;
  for lIndex := fPendingClaims.Count - 1 downto 0 do
    if SameText(TCoordinatorPendingClaim(fPendingClaims[lIndex]).Address,
      AAddress) then
    begin
      TObject(fPendingClaims[lIndex]).Free;
      fPendingClaims.Delete(lIndex);
    end;
  lClaim := TCoordinatorPendingClaim.Create;
  lClaim.Address := AAddress;
  lClaim.InstanceId := AInstanceId;
  lClaim.Force := AForce;
  CreateGUID(lId);
  lClaim.ClaimId := GUIDToString(lId);
  Result := lClaim.ClaimId;
  fPendingClaims.Add(lClaim);
  fDiscovery.RequestSearch;
  RetryControlRequests;
end;

procedure TCoordinatorHttpServer.ReleaseRecorder(const AAddress,
  AInstanceId, AClaimId: string);
var
  lIndex: Integer;
begin
  for lIndex := fPendingClaims.Count - 1 downto 0 do
    if SameText(TCoordinatorPendingClaim(fPendingClaims[lIndex]).Address,
      AAddress) then
    begin
      TObject(fPendingClaims[lIndex]).Free;
      fPendingClaims.Delete(lIndex);
    end;
  if fDiscovery <> nil then
    fDiscovery.RequestRelease(AAddress, AInstanceId, AClaimId);
end;

procedure TCoordinatorHttpServer.RetryControlRequests;
var
  lIndex: Integer;
  lClaim: TCoordinatorPendingClaim;
  lHost: TJSONObject;
begin
  if fDiscovery = nil then Exit;
  for lIndex := fPendingClaims.Count - 1 downto 0 do
  begin
    lClaim := TCoordinatorPendingClaim(fPendingClaims[lIndex]);
    lHost := fModel.HostByAddressJson(lClaim.Address);
    try
      if (lHost.Get('control_owner', '') = fControlId) and
         (lHost.Get('control_claim', '') = lClaim.ClaimId) and
         lHost.Get('recorder_reachable', False) then
      begin
        lClaim.Free;
        fPendingClaims.Delete(lIndex);
        Continue;
      end;
      if lClaim.NextAttempt > GetTickCount64 then Continue;
      if lClaim.Attempts >= 6 then
      begin
        SharedLogger.Error('Recorder claim timed out: ' + lClaim.Address);
        lClaim.Free;
        fPendingClaims.Delete(lIndex);
        Continue;
      end;
      if lHost.Get('instance_id', '') <> '' then
        lClaim.InstanceId := lHost.Get('instance_id', '');
      fDiscovery.RequestClaim(lClaim.Address, lClaim.InstanceId,
        lClaim.ClaimId, lClaim.Force and (lClaim.Attempts = 0));
      Inc(lClaim.Attempts);
      lClaim.NextAttempt := GetTickCount64 + 2000;
    finally
      lHost.Free;
    end;
  end;
end;

procedure TCoordinatorHttpServer.DiscoveryRecorderFound(const AInstanceId,
  ADisplayName, AAddress, ABaseUrl, AMacAddresses: string);
var
  lHost, lResult: TJSONObject;
begin
  { Runs in the UDP worker. TCoordinatorModel serializes host mutations. }
  lHost := TJSONObject.Create;
  try
    lHost.Add('instance_id', AInstanceId);
    lHost.Add('host_name', ADisplayName);
    lHost.Add('workstation_name', ADisplayName);
    lHost.Add('remote_address', AAddress);
    lHost.Add('mac_addresses', AMacAddresses);
    lHost.Add('state', 'discovered');
    lResult := fModel.RegisterDiscovery(lHost);
    lResult.Free;
  finally
    lHost.Free;
  end;
end;

function TCoordinatorHttpServer.PortAvailable(APort: Word): Boolean;
var
  lSocket: LongInt;
  lAddress: TInetSockAddr;
begin
  Result := False;
  lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if lSocket < 0 then Exit;
  try
    FillChar(lAddress, SizeOf(lAddress), 0);
    lAddress.sin_family := AF_INET;
    lAddress.sin_port := htons(APort);
    lAddress.sin_addr.s_addr := 0;
    Result := fpBind(lSocket, @lAddress, SizeOf(lAddress)) = 0;
  finally
    CloseSocket(lSocket);
  end;
end;

destructor TCoordinatorHttpServer.Destroy;
var
  lIndex: Integer;
begin
  FreeAndNil(fDiscovery);
  Stop;
  fHostMonitor.Terminate;
  { Execute sets Finished after observing Terminated. The current OS ping is
    bounded to one second, so destruction cannot wait on an unbounded probe. }
  while not fHostMonitor.Finished do Sleep(1);
  FreeAndNil(fHostMonitor);
  { Object destruction is the ownership barrier: the server cannot be freed
    while Execute still uses it. AcceptIdleTimeout bounds the time until the
    accept loop observes StopAccepting's state. }
  while (fThread <> nil) and not fThread.Finished do
    Sleep(1);
  ReleaseFinishedThread;
  fServer.Free;
  for lIndex := 0 to fPendingClaims.Count - 1 do
    TObject(fPendingClaims[lIndex]).Free;
  fPendingClaims.Free;
  inherited Destroy;
end;

procedure TCoordinatorHttpServer.ReleaseFinishedThread;
begin
  if (fThread <> nil) and fThread.Finished then
    FreeAndNil(fThread);
end;

procedure TCoordinatorHttpServer.Start(const AAddress: string; APort: Word);
var
  lLocalAddresses: TStringList;
  I: Integer;
  lAddress: string;
begin
  SharedLogger.Info(Format('HTTP start requested address=%s port=%d',
    [AAddress, APort]));
  ReleaseFinishedThread;
  if fThread <> nil then
  begin
    fLastError := 'HTTP service is still stopping';
    Exit;
  end;
  fLastError := '';
  if not PortAvailable(APort) then
  begin
    fLastError := Format('TCP port %d is already in use', [APort]);
    SharedLogger.Error('HTTP start rejected: ' + fLastError);
    Exit;
  end;
  fServer.SetListenAddress(AAddress);
  fServer.Port := APort;
  fThread := TCoordinatorListenerThread.Create(fServer);
  fThread.Start;
  lLocalAddresses := TStringList.Create;
  try
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
    fDiscovery := TRecorderLanDiscovery.Create(rdrCoordinator, fControlId,
      'Recorder Coordinator', APort, '', lLocalAddresses.CommaText);
  finally
    lLocalAddresses.Free;
  end;
  fDiscovery.SetControlToken(fControlToken);
  fDiscovery.OnFound := @DiscoveryRecorderFound;
  fDiscovery.OnOwnerFound := @DiscoveryOwnerFound;
  fDiscovery.Start;
end;

procedure TCoordinatorHttpServer.Stop;
begin
  FreeAndNil(fDiscovery);
  ReleaseFinishedThread;
  if fThread = nil then Exit;
  SharedLogger.Info('HTTP stop requested');
  fThread.Terminate;
  if fServer.Active then
    fServer.Active := False;
end;

procedure TCoordinatorHttpServer.SearchRecorders;
begin
  if fDiscovery <> nil then
    fDiscovery.RequestSearch;
end;

function TCoordinatorHttpServer.Active: Boolean;
begin
  ReleaseFinishedThread;
  Result := (fThread <> nil) and not fThread.Terminated;
end;

function TCoordinatorHttpServer.Stopping: Boolean;
begin
  ReleaseFinishedThread;
  Result := (fThread <> nil) and fThread.Terminated;
end;

function TCoordinatorHttpServer.LastError: string;
begin
  ReleaseFinishedThread;
  Result := fLastError;
  if (Result = '') and (fThread <> nil) then
    Result := fThread.LastError;
end;

function TCoordinatorHttpServer.ReadBody(ARequest: TFPHTTPConnectionRequest): TJSONObject;
var
  lData: TJSONData;
begin
  Result := nil;
  if Trim(ARequest.Content) = '' then Exit(TJSONObject.Create);
  lData := GetJSON(ARequest.Content);
  if lData.JSONType <> jtObject then
  begin
    lData.Free;
    raise EJSONParser.Create('JSON object expected');
  end;
  Result := TJSONObject(lData);
end;

procedure TCoordinatorHttpServer.SendJson(var AResponse: TFPHTTPConnectionResponse;
  AData: TJSONData; AStatusCode: Integer);
begin
  try
    AResponse.Code := AStatusCode;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.Content := AData.AsJSON;
  finally
    AData.Free;
  end;
end;

procedure TCoordinatorHttpServer.HandleRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);
var
  lBody, lError, lEventResult: TJSONObject;
  lPath, lInstanceId: string;
begin
  lBody := nil;
  lPath := ARequest.URI;
  SharedLogger.Info(Format('HTTP receive method=%s path=%s remote=%s',
    [ARequest.Method, lPath, ARequest.RemoteAddress]));
  try
    if (ARequest.Method = 'GET') and (lPath = '/api/v1/status') then
    begin
      lBody := fModel.StatusJson;
      lBody.Add('coordinator_instance_id', fControlId);
      SendJson(AResponse, lBody);
      lBody := nil;
    end
    else if (ARequest.Method = 'GET') and (lPath = '/api/v1/hosts') then
      SendJson(AResponse, fModel.HostsJson)
    else if (ARequest.Method = 'GET') and (lPath = '/api/v1/events') then
      SendJson(AResponse, fModel.EventsJson)
    else if (ARequest.Method = 'POST') and (lPath = '/api/v1/clients/hello') then
    begin
      lBody := ReadBody(ARequest);
      if lBody.Find('remote_address') = nil then
        lBody.Add('remote_address', ARequest.RemoteAddress);
      SendJson(AResponse, fModel.RegisterHello(lBody));
    end
    else if (ARequest.Method = 'POST') and (lPath = '/api/v1/clients/heartbeat') then
    begin
      lBody := ReadBody(ARequest);
      if lBody.Find('remote_address') = nil then
        lBody.Add('remote_address', ARequest.RemoteAddress);
      SendJson(AResponse, fModel.ApplyHeartbeat(lBody));
    end
    else if (ARequest.Method = 'POST') and (lPath = '/api/v1/events') then
    begin
      lBody := ReadBody(ARequest);
      lEventResult := fModel.AddRecordingEvent(lBody);
      if lEventResult.Find('persistence_error') <> nil then
        SendJson(AResponse, lEventResult, 503)
      else
        SendJson(AResponse, lEventResult);
    end
    else if (ARequest.Method = 'POST') and (lPath = '/api/v1/commands') then
    begin
      lBody := ReadBody(ARequest);
      SendJson(AResponse, fModel.EnqueueCommand(lBody), 201);
    end
    else if (ARequest.Method = 'GET') and
      ((lPath = '/api/v1/commands/status') or
       (Pos('/api/v1/commands/status?', lPath) = 1)) then
      SendJson(AResponse, fModel.WorkstationCommandStatus(
        ARequest.QueryFields.Values['command_id']))
    else if (ARequest.Method = 'GET') and (Pos('/api/v1/commands/next', lPath) = 1) then
    begin
      lInstanceId := ARequest.QueryFields.Values['instance_id'];
      SendJson(AResponse, fModel.NextCommand(lInstanceId));
    end
    else if (ARequest.Method = 'POST') and (lPath = '/api/v1/commands/result') then
    begin
      lBody := ReadBody(ARequest);
      SendJson(AResponse, fModel.CompleteCommand(lBody));
    end
    else if (ARequest.Method = 'GET') and (Pos('/api/v1/recordings/current', lPath) = 1) then
    begin
      lInstanceId := ARequest.QueryFields.Values['instance_id'];
      SendJson(AResponse, fModel.CurrentRecording(lInstanceId));
    end
    else
    begin
      lError := TJSONObject.Create;
      lError.Add('result_code', 'notFound');
      SendJson(AResponse, lError, 404);
    end;
  except
    on E: Exception do
    begin
      SharedLogger.Error(Format(
        'HTTP request error method=%s path=%s class=%s message=%s',
        [ARequest.Method, lPath, E.ClassName, E.Message]));
      lError := TJSONObject.Create;
      lError.Add('result_code', 'invalidRequest');
      lError.Add('message', E.Message);
      SendJson(AResponse, lError, 400);
    end;
  end;
  SharedLogger.Info(Format('HTTP result method=%s path=%s status=%d',
    [ARequest.Method, lPath, AResponse.Code]));
  lBody.Free;
end;

end.
