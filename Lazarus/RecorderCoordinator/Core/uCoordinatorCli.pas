unit uCoordinatorCli;

{$mode objfpc}{$H+}

interface

function RunCoordinatorCli: Integer;

implementation

uses
  Classes, SysUtils, fphttpclient, fpjson, jsonparser, HTTPDefs,
  uCoordinatorModel, uCoordinatorConfig, uCoordinatorHttpServer,
  uCoordinatorSqlEventStore
  {$IFDEF WINDOWS}, Windows{$ENDIF};

procedure CliWriteLine(const AValue: UTF8String; AError: Boolean = False);
{$IFDEF WINDOWS}
var
  lHandle: THandle;
  lHandleKind, lWritten, lConsoleMode: DWORD;
  lBytes: UTF8String;
  lWide: UnicodeString;
begin
  if AError then lHandleKind := DWORD(STD_ERROR_HANDLE)
  else lHandleKind := DWORD(STD_OUTPUT_HANDLE);
  lHandle := GetStdHandle(lHandleKind);
  if (lHandle = 0) or (lHandle = INVALID_HANDLE_VALUE) then
  begin
    AttachConsole(ATTACH_PARENT_PROCESS);
    lHandle := GetStdHandle(lHandleKind);
    if (lHandle = 0) or (lHandle = INVALID_HANDLE_VALUE) then Exit;
  end;
  lBytes := AValue + LineEnding;
  if GetConsoleMode(lHandle, lConsoleMode) then
  begin
    lWide := UTF8Decode(lBytes);
    WriteConsoleW(lHandle, PWideChar(lWide), Length(lWide), lWritten, nil);
  end
  else
    WriteFile(lHandle, lBytes[1], Length(lBytes), lWritten, nil);
{$ELSE}
begin
  if AError then WriteLn(StdErr, AValue)
  else WriteLn(AValue);
{$ENDIF}
end;

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
  CliWriteLine('RecorderCoordinator');
  CliWriteLine('  --serve [--listen=0.0.0.0] [--port=8765]');
  CliWriteLine('  --cli --status [--url=http://127.0.0.1:8765]');
  CliWriteLine('  --cli --list-hosts [--url=http://127.0.0.1:8765]');
  CliWriteLine('  --cli --command=start|stop --host=<instance-id> [--url=...]');
  CliWriteLine('  --cli --command=workstation.name.get --host=<IPv4> [--url=...]');
  CliWriteLine('  --cli --command=workstation.name.set --host=<IPv4> --workstation-name=<name> [--url=...]');
  CliWriteLine('  --cli --command=workstation.name.set --host=<IPv4> --use-computer-name [--url=...]');
end;

function HttpGet(const AUrl: string; ATimeoutMs: Integer = 0): string;
var lClient: TFPHTTPClient;
begin
  lClient := TFPHTTPClient.Create(nil);
  try
    if ATimeoutMs > 0 then
    begin
      lClient.ConnectTimeout := ATimeoutMs;
      lClient.IOTimeout := ATimeoutMs;
    end;
    lClient.AddHeader('Accept', 'application/json');
    Result := lClient.Get(AUrl);
  finally lClient.Free; end;
end;

function HttpPost(const AUrl, ABody: string; ATimeoutMs: Integer = 0): string;
var
  lClient: TFPHTTPClient;
  lInput: TStringStream;
begin
  lClient := TFPHTTPClient.Create(nil);
  lInput := TStringStream.Create(ABody);
  try
    if ATimeoutMs > 0 then
    begin
      lClient.ConnectTimeout := ATimeoutMs;
      lClient.IOTimeout := ATimeoutMs;
    end;
    lClient.AddHeader('Content-Type', 'application/json');
    lClient.RequestBody := lInput;
    Result := lClient.Post(AUrl);
    lClient.RequestBody := nil;
  finally
    lInput.Free;
    lClient.Free;
  end;
end;

function ParseCommandResponse(const AResponse: string): TJSONObject;
var
  lData: TJSONData;
begin
  lData := GetJSON(AResponse);
  if not (lData is TJSONObject) then
  begin
    lData.Free;
    raise Exception.Create('Invalid command response');
  end;
  Result := TJSONObject(lData);
end;

function RunWorkstationNameCommand(const ABaseUrl, ACommand, AHost: string): Integer;
const
  CRequestTimeoutMs = 3000;
  CCommandWaitMs = 20000;
var
  lRequest, lPayload, lResponse: TJSONObject;
  lName, lCommandId, lState, lStatusUrl: string;
  lUseComputerName: Boolean;
  lDeadline: QWord;
begin
  lName := Trim(ParamValue('--workstation-name', ''));
  lUseComputerName := HasParam('--use-computer-name');
  if (ACommand = 'workstation.name.set') and
     ((lName <> '') = lUseComputerName) then
  begin
    PrintUsage;
    Exit(2);
  end;

  lRequest := TJSONObject.Create;
  try
    lRequest.Add('address', AHost);
    lRequest.Add('command', ACommand);
    if ACommand = 'workstation.name.set' then
    begin
      lPayload := TJSONObject.Create;
      lRequest.Add('payload', lPayload);
      lPayload.Add('name', lName);
      lPayload.Add('use_computer_name', lUseComputerName);
    end;
    lResponse := ParseCommandResponse(HttpPost(ABaseUrl + '/api/v1/commands',
      lRequest.AsJSON, CRequestTimeoutMs));
    try
      lCommandId := lResponse.Get('command_id', '');
      if lCommandId = '' then
        raise Exception.Create('Command rejected: ' + lResponse.AsJSON);
    finally
      lResponse.Free;
    end;
  finally
    lRequest.Free;
  end;

  lStatusUrl := ABaseUrl + '/api/v1/commands/status?command_id=' +
    HTTPEncode(lCommandId);
  lDeadline := GetTickCount64 + CCommandWaitMs;
  repeat
    lResponse := ParseCommandResponse(HttpGet(lStatusUrl, CRequestTimeoutMs));
    try
      lState := lResponse.Get('state', '');
      if (lState <> 'pending') and (lState <> 'accepted') then
      begin
        if (lState = 'completed') and
           (lResponse.Get('result_code', '') = 'noError') then
        begin
          CliWriteLine(lResponse.AsJSON);
          Exit(0);
        end;
        CliWriteLine(lResponse.AsJSON, True);
        Exit(1);
      end;
    finally
      lResponse.Free;
    end;
    Sleep(250);
  until GetTickCount64 >= lDeadline;
  CliWriteLine('Timed out waiting for command ' + lCommandId, True);
  Result := 1;
end;

function RunServer: Integer;
var
  lModel: TCoordinatorModel;
  lConfig: TCoordinatorConfig;
  lServer: TCoordinatorHttpServer;
  lEventStore: TCoordinatorSqlEventStore;
begin
  Result := 1;
  lModel := TCoordinatorModel.Create;
  lConfig := TCoordinatorConfig.Create(ChangeFileExt(ParamStr(0), '.ini'));
  lServer := nil;
  lEventStore := nil;
  try
    lConfig.Load;
    lServer := TCoordinatorHttpServer.Create(lModel, lConfig.HostAgentPort,
      lConfig.HostAgentToken);
    lEventStore := TCoordinatorSqlEventStore.Create(lConfig.SqlDbConfigFile);
    lModel.OnRecordingLifecycle := @lEventStore.HandleLifecycle;
    lModel.EventWindowSec := lConfig.EventWindowSec;
    lModel.CreateRecordingEvents := lConfig.CreateRecordingEvents;
    lModel.StartAllOnAnyRecording := lConfig.StartAllOnAnyRecording;
    lConfig.ListenAddress := ParamValue('--listen', lConfig.ListenAddress);
    lConfig.Port := StrToIntDef(ParamValue('--port', IntToStr(lConfig.Port)), lConfig.Port);
    lServer.Start(lConfig.ListenAddress, lConfig.Port);
    CliWriteLine('RecorderCoordinator listening on ' + lConfig.ListenAddress +
      ':' + IntToStr(lConfig.Port));
    CliWriteLine('Press Ctrl+C to stop.');
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
  if (lCommand = 'workstation.name.get') or
     (lCommand = 'workstation.name.set') then
    Exit(RunWorkstationNameCommand(ABaseUrl, lCommand, lHost));
  lJson := TJSONObject.Create;
  try
    lJson.Add('instance_id', lHost);
    lJson.Add('command', lCommand);
    lBody := lJson.AsJSON;
  finally
    lJson.Free;
  end;
  CliWriteLine(HttpPost(ABaseUrl + '/api/v1/commands', lBody));
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
      CliWriteLine(HttpGet(lBaseUrl + '/api/v1/status'))
    else if HasParam('--list-hosts') then
      CliWriteLine(HttpGet(lBaseUrl + '/api/v1/hosts'))
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
      CliWriteLine('ERROR: ' + E.Message, True);
      Result := 1;
    end;
  end;
end;

end.
