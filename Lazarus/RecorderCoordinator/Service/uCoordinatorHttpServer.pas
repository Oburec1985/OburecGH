unit uCoordinatorHttpServer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs, Sockets, fphttpserver, httpdefs, fpjson, jsonparser,
  uCoordinatorModel, uSharedFileLogger, uRecorderLanDiscovery;

type
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
    fLastError: string;
    procedure ReleaseFinishedThread;
    function PortAvailable(APort: Word): Boolean;
    procedure DiscoveryRecorderFound(const AInstanceId, ADisplayName,
      AAddress, ABaseUrl: string);
    procedure HandleRequest(Sender: TObject;
      var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
    function ReadBody(ARequest: TFPHTTPConnectionRequest): TJSONObject;
    procedure SendJson(var AResponse: TFPHTTPConnectionResponse;
      AData: TJSONData; AStatusCode: Integer = 200);
  public
    constructor Create(AModel: TCoordinatorModel);
    destructor Destroy; override;
    procedure Start(const AAddress: string; APort: Word);
    procedure Stop;
    function Active: Boolean;
    function Stopping: Boolean;
    function LastError: string;
  end;

implementation

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

constructor TCoordinatorHttpServer.Create(AModel: TCoordinatorModel);
begin
  inherited Create;
  fModel := AModel;
  fServer := TCoordinatorFpHttpServer.Create(nil);
  fServer.Threaded := True;
  { A nonzero timeout keeps accept in a bounded select loop. StopAccepting
    changes FAccepting; no OnAcceptIdle callback or synthetic connection is
    needed to make the loop observe that state. }
  fServer.AcceptIdleTimeout := 50;
  fServer.OnRequest := @HandleRequest;
end;

procedure TCoordinatorHttpServer.DiscoveryRecorderFound(const AInstanceId,
  ADisplayName, AAddress, ABaseUrl: string);
var
  lHost, lResult: TJSONObject;
begin
  { Runs in the UDP worker. TCoordinatorModel serializes host mutations. }
  lHost := TJSONObject.Create;
  try
    lHost.Add('instance_id', AInstanceId);
    lHost.Add('host_name', ADisplayName);
    lHost.Add('remote_address', AAddress);
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
begin
  FreeAndNil(fDiscovery);
  Stop;
  { Object destruction is the ownership barrier: the server cannot be freed
    while Execute still uses it. AcceptIdleTimeout bounds the time until the
    accept loop observes StopAccepting's state. }
  while (fThread <> nil) and not fThread.Finished do
    Sleep(1);
  ReleaseFinishedThread;
  fServer.Free;
  inherited Destroy;
end;

procedure TCoordinatorHttpServer.ReleaseFinishedThread;
begin
  if (fThread <> nil) and fThread.Finished then
    FreeAndNil(fThread);
end;

procedure TCoordinatorHttpServer.Start(const AAddress: string; APort: Word);
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
  fDiscovery := TRecorderLanDiscovery.Create(rdrCoordinator, 'coordinator',
    'Recorder Coordinator', APort);
  fDiscovery.OnFound := @DiscoveryRecorderFound;
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
      SendJson(AResponse, fModel.StatusJson)
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
