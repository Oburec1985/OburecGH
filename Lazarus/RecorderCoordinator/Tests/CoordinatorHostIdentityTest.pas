program CoordinatorHostIdentityTest;

{$mode objfpc}{$H+}

uses
  SysUtils, fpjson, uCoordinatorModel;

const
  CRecorderId = '83e7e8d1-64d0-486b-a512-12ab34cd56ef';

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure RegisterConfigured(AModel: TCoordinatorModel; const AAlias: string);
var
  lData, lResult: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('instance_id', AAlias);
    lData.Add('host_name', 'Configured local Recorder');
    lData.Add('state', 'configured');
    lData.Add('managed', True);
    lResult := AModel.RegisterHello(lData);
    lResult.Free;
  finally
    lData.Free;
  end;
end;

procedure RegisterPeer(AModel: TCoordinatorModel);
var
  lData, lResult: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('instance_id', 'peer-recorder');
    lData.Add('host_name', 'Peer Recorder');
    lData.Add('remote_address', '192.168.9.150');
    lData.Add('state', 'stopped');
    lResult := AModel.RegisterHello(lData);
    lResult.Free;
  finally
    lData.Free;
  end;
end;

procedure ApplyRuntimeState(AModel: TCoordinatorModel; const AState: string); forward;

procedure CheckDiscoveryRequiresHttpForManagement;
var
  lData, lResult: TJSONObject;
  lHosts: TJSONData;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', CRecorderId);
      lData.Add('remote_address', '192.168.9.149');
      lResult := lModel.RegisterDiscovery(lData);
      try
        Check(not lResult.Get('managed', True),
          'UDP discovery must not make a host manageable');
      finally
        lResult.Free;
      end;
    finally
      lData.Free;
    end;

    ApplyRuntimeState(lModel, 'stopped');
    lHosts := lModel.HostsJson;
    try
      Check(TJSONObject(TJSONArray(lHosts).Items[0]).Get('managed', False),
        'successful HTTP heartbeat must make Recorder manageable');
    finally
      lHosts.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure RegisterLive(AModel: TCoordinatorModel);
var
  lData, lResult: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('instance_id', CRecorderId);
    lData.Add('display_name', 'RecorderLnx');
    lData.Add('remote_address', '127.0.0.1');
    lData.Add('state', 'ready');
    lResult := AModel.RegisterHello(lData);
    lResult.Free;
  finally
    lData.Free;
  end;
end;

procedure ApplyRuntimeState(AModel: TCoordinatorModel; const AState: string);
var
  lData, lPayload, lResult, lState: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('instance_id', CRecorderId);
    lData.Add('remote_address', '127.0.0.1');
    lPayload := TJSONObject.Create;
    lState := TJSONObject.Create;
    lState.Add('state', AState);
    lPayload.Add('state', lState);
    { The state edge is authoritative. The recording lifecycle message and its
      recording_id may arrive after this heartbeat. }
    lData.Add('payload', lPayload);
    lResult := AModel.ApplyHeartbeat(lData);
    try
      Check(lResult.Get('state', '') = AState,
        'heartbeat state was not applied: ' + AState);
    finally
      lResult.Free;
    end;
  finally
    lData.Free;
  end;
end;

procedure ApplyDiscovery(AModel: TCoordinatorModel; const AAddress: string);
var
  lData, lResult: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('instance_id', CRecorderId);
    lData.Add('display_name', 'RecorderLnx discovery');
    lData.Add('remote_address', AAddress);
    lData.Add('state', 'discovered');
    lResult := AModel.RegisterDiscovery(lData);
    lResult.Free;
  finally
    lData.Free;
  end;
end;

procedure CheckAlias(const AAlias: string);
var
  lCommand, lHosts, lNext: TJSONData;
  lData: TJSONObject;
  lModel: TCoordinatorModel;
begin
  if Trim(AAlias) = '' then Exit;
  lModel := TCoordinatorModel.Create;
  try
    RegisterConfigured(lModel, AAlias);
    lHosts := lModel.HostsJson;
    try
      Check(lHosts.Count = 1, 'configured host missing');
      Check(TJSONObject(TJSONArray(lHosts).Items[0]).Get('state', '') = 'offline',
        'configured host without heartbeat must be offline');
    finally
      lHosts.Free;
    end;

    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', AAlias);
      lData.Add('command', 'status');
      lCommand := lModel.EnqueueCommand(lData);
      lCommand.Free;
    finally
      lData.Free;
    end;

    RegisterLive(lModel);
    RegisterLive(lModel);
    RegisterPeer(lModel);
    ApplyRuntimeState(lModel, 'stopped');
    ApplyDiscovery(lModel, '192.168.9.149');
    lModel.StartAllOnAnyRecording := True;
    ApplyRuntimeState(lModel, 'preview');
    ApplyRuntimeState(lModel, 'recording');
    ApplyDiscovery(lModel, '192.168.9.149');
    lHosts := lModel.HostsJson;
    try
      Check(lHosts.Count = 2, 'live hello created a duplicate for ' + AAlias);
      lData := TJSONObject(TJSONArray(lHosts).Items[0]);
      Check(lData.Get('instance_id', '') = CRecorderId,
        'stable UUID was not adopted for ' + AAlias);
      Check(lData.Get('address', '') = '127.0.0.1',
        'recent HTTP address was overwritten by discovery for ' + AAlias);
      Check(lData.Get('state', '') = 'recording',
        'latest heartbeat state must survive discovery');
    finally
      lHosts.Free;
    end;

    lNext := lModel.NextCommand('peer-recorder');
    try
      Check(TJSONObject(lNext).Get('command', '') = 'recording.start',
        'recording transition did not enqueue peer start');
    finally
      lNext.Free;
    end;

    lNext := lModel.NextCommand(CRecorderId);
    try
      Check(TJSONObject(lNext).Get('result_code', '') <> 'noCommand',
        'pending command did not follow merged identity');
    finally
      lNext.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckWildcardConfigPayload;
var
  lCommand, lData, lHost, lPayload, lResult: TJSONObject;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    lHost := TJSONObject.Create;
    try
      lHost.Add('instance_id', 'payload-recorder');
      lHost.Add('remote_address', '192.168.9.151');
      lHost.Add('managed', True);
      lResult := lModel.RegisterHello(lHost);
      lResult.Free;
    finally
      lHost.Free;
    end;

    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', '*');
      lData.Add('command', 'config.sql_database.set');
      lPayload := TJSONObject.Create;
      lPayload.Add('host', '192.168.9.10');
      lPayload.Add('port', 3050);
      lData.Add('payload', lPayload);
      lResult := lModel.EnqueueCommand(lData);
      try
        Check(lResult.Get('queued_count', 0) = 1,
          'wildcard config command was not queued');
      finally
        lResult.Free;
      end;
    finally
      lData.Free;
    end;

    lCommand := lModel.NextCommand('payload-recorder');
    try
      Check(lCommand.Get('command', '') = 'config.sql_database.set',
        'wildcard config command type changed in queue');
      lPayload := TJSONObject(lCommand.Find('payload'));
      Check(lPayload <> nil, 'wildcard config payload was lost');
      Check(lPayload.Get('host', '') = '192.168.9.10',
        'wildcard config host changed in queue');
      Check(lPayload.Get('port', 0) = 3050,
        'wildcard config port changed in queue');
    finally
      lCommand.Free;
    end;
  finally
    lModel.Free;
  end;
end;

begin
  CheckDiscoveryRequiresHttpForManagement;
  CheckAlias('127.0.0.1');
  CheckAlias('localhost');
  CheckAlias(GetEnvironmentVariable('COMPUTERNAME'));
  CheckWildcardConfigPayload;
  WriteLn('OK: configured local aliases merge into RecorderLnx UUID');
end.
