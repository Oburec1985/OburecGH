program CoordinatorOwnershipIntegrationTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Run only in an isolated network namespace. This test starts the production
  UDP discovery transport and two real HTTP coordinators; no device is opened. }

uses
  {$IFDEF UNIX}cthreads, cwstring,{$ENDIF}
  Classes, SysUtils, IniFiles, Sockets, fpjson, uRecorderLanDiscovery,
  uRecorderCoordinatorClient, uRecorderCoordinatorProtocol,
  uRecorderCoordinatorOwnership, uCoordinatorModel, uCoordinatorHttpServer;

const
  CPortA = 19765;
  CPortB = 19766;
  CPanelA = 'ownership-integration-panel-a';
  CPanelB = 'ownership-integration-panel-b';

var
  gModelA, gModelB: TCoordinatorModel;
  gServerA, gServerB: TCoordinatorHttpServer;
  gClient: TRecorderCoordinatorClient;
  gInstanceId: string;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure Tick;
begin
  CheckSynchronize(1);
  Sleep(10);
end;

procedure Pause(AMilliseconds: QWord);
var
  lStarted: QWord;
begin
  lStarted := GetTickCount64;
  repeat Tick until GetTickCount64 - lStarted >= AMilliseconds;
end;

function Owner(AModel: TCoordinatorModel): string;
var
  lHost: TJSONObject;
begin
  lHost := AModel.HostByIdJson(gInstanceId);
  try
    Result := lHost.Get('control_owner', '');
  finally
    lHost.Free;
  end;
end;

function CommandField(AModel: TCoordinatorModel; const AName: string): string;
var
  lHosts: TJSONArray;
  lIndex: Integer;
begin
  Result := '';
  lHosts := AModel.HostsJson;
  try
    for lIndex := 0 to lHosts.Count - 1 do
      if TJSONObject(lHosts[lIndex]).Get('instance_id', '') = gInstanceId then
        Exit(TJSONObject(lHosts[lIndex]).Get(AName, ''));
  finally
    lHosts.Free;
  end;
end;

procedure WaitOwner(AServer: TCoordinatorHttpServer; AModel: TCoordinatorModel;
  const AOwner: string; ATimeout: QWord = 7000);
var
  lStarted: QWord;
begin
  lStarted := GetTickCount64;
  repeat
    AServer.RetryControlRequests;
    if (Owner(AModel) = AOwner) and (gClient.State = rccsOnline) then Exit;
    Tick;
  until GetTickCount64 - lStarted >= ATimeout;
  raise Exception.Create('Owner did not become ' + AOwner + ': ' + gClient.LastError);
end;

procedure Enqueue(AModel: TCoordinatorModel; const AId: string);
var
  lBody, lReply: TJSONObject;
begin
  lBody := TJSONObject.Create;
  try
    lBody.Add('instance_id', gInstanceId);
    lBody.Add('command_id', AId);
    lBody.Add('command', 'status');
    lReply := AModel.EnqueueCommand(lBody);
    lReply.Free;
  finally
    lBody.Free;
  end;
end;

procedure ReplayOldForcedClaim(const AClaimId: string);
var
  lSocket: LongInt;
  lAddress: TInetSockAddr;
  lJson: TJSONObject;
  lText: RawByteString;
begin
  lJson := TJSONObject.Create;
  try
    lJson.Add('magic', 'RecorderLnxDiscovery');
    lJson.Add('version', 1);
    lJson.Add('kind', 'coordinator.claim');
    lJson.Add('instance_id', CPanelB);
    lJson.Add('target_instance_id', gInstanceId);
    lJson.Add('claim_id', AClaimId);
    lJson.Add('http_port', CPortB);
    lJson.Add('force', True);
    lText := UTF8Encode(lJson.AsJSON);
    lSocket := fpSocket(AF_INET, SOCK_DGRAM, 0);
    Check(lSocket >= 0, 'Replay socket failed');
    try
      FillChar(lAddress, SizeOf(lAddress), 0);
      lAddress.sin_family := AF_INET;
      lAddress.sin_port := htons(CRecorderDiscoveryClientPort);
      lAddress.sin_addr := StrToNetAddr('127.0.0.1');
      Check(fpSendTo(lSocket, @lText[1], Length(lText), 0, @lAddress,
        SizeOf(lAddress)) = Length(lText), 'Replay packet was not sent');
    finally
      CloseSocket(lSocket);
    end;
  finally
    lJson.Free;
  end;
end;

function WaitCommand(const AId: string): TRecorderCoordinatorCommand;
var
  lStarted: QWord;
begin
  lStarted := GetTickCount64;
  repeat
    Result := gClient.PopCommand;
    if Result <> nil then
    begin
      Check(Result.CommandId = AId, 'Unexpected or stale command: ' + Result.CommandId);
      Exit;
    end;
    Tick;
  until GetTickCount64 - lStarted >= 5000;
  raise Exception.Create('Command was not delivered: ' + AId);
end;

procedure RunScenario(const AConfigFile: string);
var
  lConfig, lReload: TRecorderCoordinatorClientConfig;
  lIni: TIniFile;
  lClaimA, lClaimB: string;
  lCommand, lOldCommand: TRecorderCoordinatorCommand;
  lStarted: QWord;
begin
  lIni := TIniFile.Create(AConfigFile);
  try
    lIni.WriteString('Coordinator', 'BaseUrl', 'http://127.0.0.1:' + IntToStr(CPortA));
  finally
    lIni.Free;
  end;
  lConfig := TRecorderCoordinatorClientConfig.Create;
  lConfig.LoadFromFile(AConfigFile);
  Check(lConfig.BaseUrl = '', 'Legacy BaseUrl must be ignored');
  gInstanceId := lConfig.InstanceId;
  Check(gInstanceId <> '', 'Instance identity missing');
  lReload := TRecorderCoordinatorClientConfig.Create;
  try
    lReload.LoadFromFile(AConfigFile);
    Check(lReload.InstanceId = gInstanceId, 'Generated identity was not persisted');
  finally
    lReload.Free;
  end;
  lConfig.HeartbeatMs := 250;
  lConfig.RequestTimeoutMs := 500;
  gClient := TRecorderCoordinatorClient.Create(lConfig);
  gClient.UpdateSnapshot('{"name":"stopped"}', '{}');
  gClient.Start;
  Pause(1000);
  Check((Owner(gModelA) = '') and (Owner(gModelB) = ''),
    'Discovery or old configuration captured an autonomous Recorder');
  WriteLn('PASS legacy endpoint ignored and InstanceId persisted');

  lClaimA := gServerA.ClaimRecorder('127.0.0.1', gInstanceId, False);
  Check(lClaimA <> '', 'Panel A claim was not queued');
  WaitOwner(gServerA, gModelA, CPanelA);
  Enqueue(gModelA, 'from-a');
  lOldCommand := WaitCommand('from-a');
  Enqueue(gModelA, 'queued-from-a');
  lStarted := GetTickCount64;
  while (CommandField(gModelA, 'last_command_state') <> 'accepted') and
    (GetTickCount64 - lStarted < 5000) do Tick;
  Check(CommandField(gModelA, 'last_command_state') = 'accepted',
    'Old command did not enter the Recorder queue');
  WriteLn('PASS claim A and actual command delivery');

  gServerB.ClaimRecorder('127.0.0.1', gInstanceId, False);
  lStarted := GetTickCount64;
  repeat
    gServerB.RetryControlRequests;
    Tick;
  until GetTickCount64 - lStarted >= 1000;
  Check(Owner(gModelA) = CPanelA, 'Non-forced B claim displaced A');
  Check(Owner(gModelB) <> CPanelB, 'Busy Recorder registered with B');
  WriteLn('PASS busy owner cannot be displaced implicitly');

  lClaimB := gServerB.ClaimRecorder('127.0.0.1', gInstanceId, True);
  WaitOwner(gServerB, gModelB, CPanelB);
  lCommand := gClient.PopCommand;
  Check(lCommand = nil, 'Queued old command survived ownership transfer');
  gClient.CompleteCommand(lOldCommand, rcrcNoError, 'old generation', '{}');
  Pause(500);
  Check(CommandField(gModelA, 'last_command_state') <> 'completed',
    'Old generation result unexpectedly completed in former session');
  Check(CommandField(gModelB, 'last_command') = '',
    'Old owner command/result leaked to new owner');
  Enqueue(gModelB, 'from-b');
  lCommand := WaitCommand('from-b');
  gClient.CompleteCommand(lCommand, rcrcNoError, 'new generation', '{}');
  lStarted := GetTickCount64;
  while (CommandField(gModelB, 'last_command_state') <> 'completed') and
    (GetTickCount64 - lStarted < 5000) do Tick;
  Check(CommandField(gModelB, 'last_command_state') = 'completed',
    'New owner did not receive actual command completion');
  WriteLn('PASS explicit takeover B and generation fence');

  gServerB.ReleaseRecorder('127.0.0.1', gInstanceId, lClaimB);
  lStarted := GetTickCount64;
  while (gClient.State <> rccsConnecting) and
    (GetTickCount64 - lStarted < 5000) do Tick;
  Check(gClient.State = rccsConnecting, 'Release did not restore autonomous state');
  gServerA.ClaimRecorder('127.0.0.1', gInstanceId, False);
  WaitOwner(gServerA, gModelA, CPanelA);
  ReplayOldForcedClaim(lClaimB);
  Pause(500);
  Enqueue(gModelA, 'after-replayed-retired-claim');
  lCommand := WaitCommand('after-replayed-retired-claim');
  gClient.CompleteCommand(lCommand, rcrcNoError, 'retired claim rejected', '{}');
  WriteLn('PASS release and non-forced acquisition by another panel');
  WriteLn('PASS replayed retired forced claim does not recapture Recorder');

  gServerA.Stop;
  Pause(CRecorderCoordinatorLeaseMs + 1500);
  Check(gClient.State = rccsConnecting, 'Offline owner lease did not expire');
  gServerB.ClaimRecorder('127.0.0.1', gInstanceId, False);
  WaitOwner(gServerB, gModelB, CPanelB);
  WriteLn('PASS owner disappearance, lease expiry and non-forced reacquisition');
end;

var
  lConfigFile: string;
begin
  if (ParamCount <> 1) or (ParamStr(1) <> '--isolated-network') then
    raise Exception.Create('Run with --isolated-network in a dedicated network namespace');
  lConfigFile := ChangeFileExt(ParamStr(0), '.client-test.ini');
  if FileExists(lConfigFile) then DeleteFile(lConfigFile);
  { Both models are fixtures. Never load inventory left by an earlier run. }
  DeleteFile(ChangeFileExt(ParamStr(0), '.ini'));
  gModelA := TCoordinatorModel.Create;
  gModelB := TCoordinatorModel.Create;
  gServerA := TCoordinatorHttpServer.Create(gModelA);
  gServerB := TCoordinatorHttpServer.Create(gModelB);
  try
    gServerA.ConfigureControl(CPanelA, '');
    gServerB.ConfigureControl(CPanelB, '');
    gServerA.Start('127.0.0.1', CPortA);
    gServerB.Start('127.0.0.1', CPortB);
    Pause(500);
    Check(gServerA.Active and gServerB.Active, 'HTTP services not active');
    RunScenario(lConfigFile);
    WriteLn('RESULT CoordinatorOwnershipIntegrationTest passed');
  finally
    gClient.Free;
    gServerB.Free;
    gServerA.Free;
    gModelB.Free;
    gModelA.Free;
    DeleteFile(lConfigFile);
    DeleteFile(ChangeFileExt(lConfigFile, '.events.json'));
    DeleteFile(ChangeFileExt(ParamStr(0), '.ini'));
  end;
end.
