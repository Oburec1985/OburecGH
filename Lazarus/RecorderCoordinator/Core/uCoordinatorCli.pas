unit uCoordinatorCli;

{$mode objfpc}{$H+}

interface

function RunCoordinatorCli: Integer;

implementation

uses
  Classes, SysUtils, fphttpclient, fpjson, jsonparser,
  uCoordinatorModel, uCoordinatorConfig, uCoordinatorHttpServer,
  uCoordinatorSqlEventStore;

function ParamValue(const AName, ADefault: string): string;
var
  lIndex: Integer;
  lPrefix: string;
begin
  Result := ADefault;
  lPrefix := AName + '=';
  for lIndex := 1 to ParamCount do
    if Pos(lPrefix, ParamStr(lIndex)) = 1 then
      Exit(Copy(ParamStr(lIndex), Length(lPrefix) + 1, MaxInt));
end;

function HasParam(const AName: string): Boolean;
var lIndex: Integer;
begin
  Result := False;
  for lIndex := 1 to ParamCount do
    if SameText(ParamStr(lIndex), AName) then Exit(True);
end;

procedure PrintUsage;
begin
  WriteLn('RecorderCoordinator');
  WriteLn('  --serve [--listen=0.0.0.0] [--port=8765]');
  WriteLn('  --cli --status [--url=http://127.0.0.1:8765]');
  WriteLn('  --cli --list-hosts [--url=http://127.0.0.1:8765]');
  WriteLn('  --cli --command=start|stop --host=<instance-id> [--url=...]');
end;

function HttpGet(const AUrl: string): string;
var lClient: TFPHTTPClient;
begin
  lClient := TFPHTTPClient.Create(nil);
  try
    lClient.AddHeader('Accept', 'application/json');
    Result := lClient.Get(AUrl);
  finally lClient.Free; end;
end;

function HttpPost(const AUrl, ABody: string): string;
var
  lClient: TFPHTTPClient;
  lInput: TStringStream;
begin
  lClient := TFPHTTPClient.Create(nil);
  lInput := TStringStream.Create(ABody);
  try
    lClient.AddHeader('Content-Type', 'application/json');
    lClient.RequestBody := lInput;
    Result := lClient.Post(AUrl);
    lClient.RequestBody := nil;
  finally
    lInput.Free;
    lClient.Free;
  end;
end;

function RunServer: Integer;
var
  lModel: TCoordinatorModel;
  lConfig: TCoordinatorConfig;
  lServer: TCoordinatorHttpServer;
  lEventStore: TCoordinatorSqlEventStore;
  lHost, lResult: TJSONObject;
  lIndex: Integer;
begin
  Result := 1;
  lModel := TCoordinatorModel.Create;
  lConfig := TCoordinatorConfig.Create(ChangeFileExt(ParamStr(0), '.ini'));
  lServer := TCoordinatorHttpServer.Create(lModel);
  lEventStore := nil;
  try
    lConfig.Load;
    lEventStore := TCoordinatorSqlEventStore.Create(lConfig.SqlDbConfigFile);
    lModel.OnRecordingLifecycle := @lEventStore.HandleLifecycle;
    lModel.EventWindowSec := lConfig.EventWindowSec;
    lModel.CreateRecordingEvents := lConfig.CreateRecordingEvents;
    lModel.StartAllOnAnyRecording := lConfig.StartAllOnAnyRecording;
    for lIndex := 0 to lConfig.HostCount - 1 do
    begin
      lHost := TJSONObject.Create;
      try
        lHost.Add('instance_id', lConfig.HostId(lIndex));
        lHost.Add('managed', True);
        lHost.Add('host_name', lConfig.HostName(lIndex));
        lHost.Add('state', 'configured');
        lResult := lModel.RegisterHello(lHost);
        lResult.Free;
      finally
        lHost.Free;
      end;
    end;
    lConfig.ListenAddress := ParamValue('--listen', lConfig.ListenAddress);
    lConfig.Port := StrToIntDef(ParamValue('--port', IntToStr(lConfig.Port)), lConfig.Port);
    lServer.Start(lConfig.ListenAddress, lConfig.Port);
    WriteLn('RecorderCoordinator listening on ', lConfig.ListenAddress, ':', lConfig.Port);
    WriteLn('Press Ctrl+C to stop.');
    while True do
    begin
      CheckSynchronize(50);
      Sleep(50);
    end;
  finally
    lServer.Free;
    lModel.OnRecordingLifecycle := nil;
    lEventStore.Free;
    lConfig.Free;
    lModel.Free;
  end;
end;

function RunRemoteCommand(const ABaseUrl: string): Integer;
var
  lCommand, lHost, lBody: string;
  lJson: TJSONObject;
begin
  lCommand := ParamValue('--command', '');
  lHost := ParamValue('--host', '');
  if (lCommand = '') or (lHost = '') then
  begin
    PrintUsage;
    Exit(2);
  end;
  lJson := TJSONObject.Create;
  try
    lJson.Add('instance_id', lHost);
    lJson.Add('command', lCommand);
    lBody := lJson.AsJSON;
  finally
    lJson.Free;
  end;
  WriteLn(HttpPost(ABaseUrl + '/api/v1/commands', lBody));
  Result := 0;
end;

function RunCoordinatorCli: Integer;
var
  lBaseUrl: string;
begin
  try
    if HasParam('--serve') then Exit(RunServer);
    lBaseUrl := ParamValue('--url', 'http://127.0.0.1:8765');
    if HasParam('--status') then
      WriteLn(HttpGet(lBaseUrl + '/api/v1/status'))
    else if HasParam('--list-hosts') then
      WriteLn(HttpGet(lBaseUrl + '/api/v1/hosts'))
    else if ParamValue('--command', '') <> '' then
      Exit(RunRemoteCommand(lBaseUrl))
    else
    begin
      PrintUsage;
      Exit(2);
    end;
    Result := 0;
  except
    on E: Exception do
    begin
      WriteLn(StdErr, 'ERROR: ', E.Message);
      Result := 1;
    end;
  end;
end;

end.
