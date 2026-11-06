unit uRecorderHostAgentServer;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, Sockets, fphttpserver, httpdefs, fpjson,
  uRecorderHostAgentConfig;

type
  THostAgentServer = class(TFPHTTPServer)
  private
    fConfig: TRecorderHostAgentConfig;
    procedure HandleHttpRequest(Sender: TObject; var ARequest: TFPHTTPConnectionRequest;
      var AResponse: TFPHTTPConnectionResponse);
    procedure Reply(var AResponse: TFPHTTPConnectionResponse; AJson: TJSONData;
      ACode: Integer = 200);
    function Authorized(ARequest: TFPHTTPConnectionRequest): Boolean;
  public
    constructor Create(AConfig: TRecorderHostAgentConfig);
    function TryStart(out AError: string): Boolean;
  end;

implementation

uses uRecorderHostAgentActions, uRecorderHostAgentBackup, jsonparser;

constructor THostAgentServer.Create(AConfig: TRecorderHostAgentConfig);
begin
  inherited Create(nil);
  fConfig := AConfig;
  Threaded := True;
  AcceptIdleTimeout := 100;
  Address := fConfig.ListenAddress;
  Port := fConfig.Port;
  OnRequest := @HandleHttpRequest;
end;

function THostAgentServer.TryStart(out AError: string): Boolean;
var
  lSocket: TSocket;
  lAddress: TInetSockAddr;
  {$ifdef unix}
  lReuseAddress: LongInt;
  {$endif}
begin
  Result := False;
  AError := '';
  lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if lSocket = TSocket(-1) then
  begin
    AError := 'cannot create TCP socket';
    Exit;
  end;
  try
    {$ifdef unix}
    { TFPHTTPServer enables SO_REUSEADDR. Match it here so a previous
      connection in TIME_WAIT does not prevent a legitimate restart. }
    lReuseAddress := 1;
    if fpSetSockOpt(lSocket, SOL_SOCKET, SO_REUSEADDR, @lReuseAddress,
      SizeOf(lReuseAddress)) <> 0 then
    begin
      AError := 'cannot configure TCP socket address reuse';
      Exit;
    end;
    {$endif}
    FillChar(lAddress, SizeOf(lAddress), 0);
    lAddress.sin_family := AF_INET;
    lAddress.sin_port := htons(fConfig.Port);
    if (fConfig.ListenAddress = '') or (fConfig.ListenAddress = '0.0.0.0') then
      lAddress.sin_addr.s_addr := 0
    else
      lAddress.sin_addr := StrToNetAddr(fConfig.ListenAddress);
    if fpBind(lSocket, @lAddress, SizeOf(lAddress)) <> 0 then
    begin
      AError := Format('TCP endpoint %s:%d is already in use',
        [fConfig.ListenAddress, fConfig.Port]);
      Exit;
    end;
  finally
    CloseSocket(lSocket);
  end;

  try
    Active := True;
    Result := True;
  except
    on E: Exception do
      AError := E.Message;
  end;
end;

function THostAgentServer.Authorized(ARequest: TFPHTTPConnectionRequest): Boolean;
begin
  Result := (fConfig.ApiToken = '') or
    (ARequest.CustomHeaders.Values['Authorization'] = 'Bearer ' + fConfig.ApiToken);
end;

procedure THostAgentServer.Reply(var AResponse: TFPHTTPConnectionResponse;
  AJson: TJSONData; ACode: Integer);
begin
  try
    AResponse.Code := ACode;
    AResponse.ContentType := 'application/json; charset=utf-8';
    AResponse.Content := AJson.AsJSON;
  finally
    AJson.Free;
  end;
end;

procedure THostAgentServer.HandleHttpRequest(Sender: TObject;
  var ARequest: TFPHTTPConnectionRequest;
  var AResponse: TFPHTTPConnectionResponse);
var
  lResult: TJSONObject;
  lMessage: string;
  lOk: Boolean;
  lCode: Integer;
  lData: TJSONData;
  lObj: TJSONObject;
  lSnapshotId, lRelativePath, lProjectName: string;
begin
  if not Authorized(ARequest) then
  begin
    lResult := TJSONObject.Create;
    lResult.Add('result_code', 'accessDenied');
    Reply(AResponse, lResult, 403);
    Exit;
  end;

  if (ARequest.Method = 'GET') and (ARequest.URI = '/api/v1/status') then
  begin
    Reply(AResponse, HostAgentStatusJson(fConfig));
  end
  else if (ARequest.Method = 'POST') and
    (ARequest.URI = '/api/v1/recorder/start') then
  begin
    lOk := HostAgentLaunchRecorder(fConfig, lMessage);
    lResult := TJSONObject.Create;
    if lOk then
    begin
      lResult.Add('result_code', 'noError');
      lCode := 200;
    end
    else
    begin
      lResult.Add('result_code', 'notReady');
      lCode := 409;
    end;

    lResult.Add('message', lMessage);
    Reply(AResponse, lResult, lCode);
  end
  else if (ARequest.Method = 'POST') and
    ((ARequest.URI = '/api/v1/backup/prepare') or (ARequest.URI = '/api/v1/backup/cleanup') or (ARequest.URI = '/api/v1/backup/verify')) then
  begin
    lData:=nil; lResult:=TJSONObject.Create;
    try
      try
        lData:=GetJSON(ARequest.Content);
        if not (lData is TJSONObject) then raise Exception.Create('Expected JSON object');
        lObj:=TJSONObject(lData);
        if ARequest.URI='/api/v1/backup/prepare' then
        begin
          if (lObj.Get('layout','') <> CHostBackupLayout) or
            not lObj.Get('configurations',False) or lObj.Get('program',False) or
            lObj.Get('plugins',False) then
            raise Exception.Create('Backup requires an updated panel and settings-only layout');
          lOk:=HostAgentPrepareBackup(fConfig,lObj.Get('calibrations',False),
            lSnapshotId,lRelativePath,lProjectName,lMessage);
        end
        else if ARequest.URI='/api/v1/backup/verify' then
          lOk:=HostAgentVerifyBackup(fConfig,lObj.Get('snapshot_id',''),lMessage)
        else lOk:=HostAgentCleanupBackup(fConfig,lObj.Get('snapshot_id',''),lMessage);
      except on E:Exception do begin lOk:=False; lMessage:=E.Message; end; end;
      if lOk then begin
        lResult.Add('result_code','noError'); lCode:=200;
        if ARequest.URI='/api/v1/backup/prepare' then begin
          lResult.Add('snapshot_id',lSnapshotId); lResult.Add('relative_path',lRelativePath);
          lResult.Add('layout', CHostBackupLayout); lResult.Add('project_name', lProjectName);
        end;
      end else begin lResult.Add('result_code','notReady'); lCode:=409; end;
      lResult.Add('message',lMessage);
      Reply(AResponse,lResult,lCode); lResult:=nil;
    finally lData.Free; lResult.Free; end;
  end
  else if (ARequest.Method = 'POST') and
    (ARequest.URI = '/api/v1/system/shutdown') then
  begin
    lOk := HostAgentShutdown(fConfig, lMessage);
    lResult := TJSONObject.Create;
    if lOk then
    begin
      lResult.Add('result_code', 'noError');
      lCode := 202;
    end
    else
    begin
      lResult.Add('result_code', 'accessDenied');
      lCode := 403;
    end;

    lResult.Add('message', lMessage);
    Reply(AResponse, lResult, lCode);
  end
  else
  begin
    lResult := TJSONObject.Create;
    lResult.Add('result_code', 'notFound');
    Reply(AResponse, lResult, 404);
  end;
end;

end.
