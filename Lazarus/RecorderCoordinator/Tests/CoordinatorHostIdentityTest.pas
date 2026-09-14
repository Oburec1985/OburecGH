program CoordinatorHostIdentityTest;

{$mode objfpc}{$H+}

uses
  SysUtils, fpjson, uCoordinatorModel, uCoordinatorHostStore;

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
procedure RegisterLive(AModel: TCoordinatorModel); forward;

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

procedure CheckRecorderHostInfo;
var
  lData, lPayload, lResult: TJSONObject;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', 'host-info-recorder');
      lPayload := TJSONObject.Create;
      lPayload.Add('host_name', 'Recorder host');
      lPayload.Add('mac_addresses', '00:11:22:33:44:55,66:77:88:99:AA:BB');
      lPayload.Add('executable_path', '/opt/recorderlnx/RecorderLnx');
      lPayload.Add('os', 'linux');
      lData.Add('payload', lPayload);
      lResult := lModel.RegisterHello(lData);
      try
        Check(lResult.Get('mac_address', '') = '00:11:22:33:44:55',
          'first valid Recorder MAC was not accepted');
        Check(lResult.Get('executable_path', '') =
          '/opt/recorderlnx/RecorderLnx', 'Recorder executable path missing');
        Check(lResult.Get('os', '') = 'linux', 'Recorder OS missing');
      finally
        lResult.Free;
      end;
    finally
      lData.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckLocalManualAndAutomaticDetailsMerge(const ALocalAlias: string);
var
  lData, lPayload, lResult: TJSONObject;
  lHosts: TJSONData;
  lHost: TJSONObject;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', ALocalAlias);
      lData.Add('host_name', 'Manual local name');
      lData.Add('state', 'configured');
      lData.Add('managed', True);
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', CRecorderId);
      lData.Add('remote_address', '127.0.0.1');
      lData.Add('host_name', 'Automatic computer name');
      lData.Add('state', 'preview');
      lPayload := TJSONObject.Create;
      lPayload.Add('mac_addresses', '00:11:22:33:44:55');
      lPayload.Add('executable_path', 'C:\Program Files\Mera\RecorderLnx.exe');
      lPayload.Add('os', 'windows');
      lData.Add('payload', lPayload);
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lHosts := lModel.HostsJson;
    try
      Check(lHosts.Count = 1,
        'manual and automatic local hosts were not merged for ' + ALocalAlias);
      lHost := TJSONObject(TJSONArray(lHosts).Items[0]);
      Check(lHost.Get('instance_id', '') = CRecorderId,
        'automatic UUID was not adopted for ' + ALocalAlias);
      Check(lHost.Get('address', '') = '127.0.0.1',
        'automatic address was not added for ' + ALocalAlias);
      Check(lHost.Get('host_name', '') = 'Manual local name',
        'manual display name was not retained for ' + ALocalAlias);
      Check(lHost.Get('mac_address', '') = '00:11:22:33:44:55',
        'automatic MAC was not added for ' + ALocalAlias);
      Check(lHost.Get('executable_path', '') =
        'C:\Program Files\Mera\RecorderLnx.exe',
        'automatic executable path was not added for ' + ALocalAlias);
      Check(lHost.Get('os', '') = 'windows',
        'automatic operating system was not added for ' + ALocalAlias);
      Check(lHost.Get('recorder_state', '') = 'preview',
        'automatic runtime state was not applied for ' + ALocalAlias);
    finally
      lHosts.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckDifferentRemoteHostsStaySeparate;
var
  lData, lResult: TJSONObject;
  lHosts: TJSONData;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', '192.168.9.150');
      lData.Add('host_name', 'Same visible name');
      lData.Add('remote_address', '192.168.9.150');
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', 'remote-recorder-uuid');
      lData.Add('host_name', 'Same visible name');
      lData.Add('remote_address', '192.168.9.151');
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lHosts := lModel.HostsJson;
    try
      Check(lHosts.Count = 2,
        'different remote addresses were incorrectly merged');
    finally
      lHosts.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckDifferentLoopbackAddressStaysNew;
var
  lHost: TJSONObject;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    RegisterConfigured(lModel, '127.0.0.1');
    lHost := lModel.HostByAddressJson('127.0.0.2');
    try
      Check(lHost.Get('result_code', '') = 'notFound',
        '127.0.0.2 must remain a new editor address');
    finally
      lHost.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckIpv4MappedLocalAddressMerges;
var
  lData, lResult: TJSONObject;
  lHosts: TJSONData;
  lHost: TJSONObject;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    RegisterConfigured(lModel, '127.0.0.1');
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', CRecorderId);
      lData.Add('remote_address', '::ffff:127.0.0.1');
      lData.Add('state', 'ready');
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lHosts := lModel.HostsJson;
    try
      Check(lHosts.Count = 1,
        'IPv4-mapped local address created a duplicate host');
      lHost := TJSONObject(TJSONArray(lHosts).Items[0]);
      Check(lHost.Get('instance_id', '') = CRecorderId,
        'UUID was not adopted from IPv4-mapped local hello');
    finally
      lHosts.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckAddressAndMacAliasChainMerges;
const
  CAddress = '192.168.9.160';
  COldAddress = '192.168.9.161';
  CMac = '10:20:30:40:50:60';
var
  lData, lResult: TJSONObject;
  lHosts: TJSONData;
  lHost: TJSONObject;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', 'manual-address-alias');
      lData.Add('remote_address', CAddress);
      lData.Add('host_name', 'Manual control-room name');
      lData.Add('executable_path', '/manual/recorder/path');
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', 'old-mac-alias');
      lData.Add('remote_address', COldAddress);
      lData.Add('mac_address', CMac);
      lData.Add('os', 'linux');
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', CRecorderId);
      lData.Add('remote_address', CAddress);
      lData.Add('mac_address', CMac);
      lData.Add('state', 'preview');
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lHosts := lModel.HostsJson;
    try
      Check(lHosts.Count = 1,
        'address and MAC aliases were not collapsed into one host');
      lHost := TJSONObject(TJSONArray(lHosts).Items[0]);
      Check(lHost.Get('instance_id', '') = CRecorderId,
        'stable UUID was not adopted after alias-chain merge');
      Check(lHost.Get('host_name', '') = 'Manual control-room name',
        'address-alias name was lost during alias-chain merge');
      Check(lHost.Get('executable_path', '') = '/manual/recorder/path',
        'address-alias executable path was lost during alias-chain merge');
      Check(lHost.Get('mac_address', '') = CMac,
        'MAC alias value was lost during alias-chain merge');
      Check(lHost.Get('os', '') = 'linux',
        'MAC-alias operating system was lost during alias-chain merge');
      Check(lHost.Get('recorder_state', '') = 'preview',
        'latest runtime state was not retained after alias-chain merge');
    finally
      lHosts.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckPersistedRemoteAddressAliasMerges;
const
  CAddress = '192.168.9.66';
  CMac = '10:20:30:40:50:66';
var
  lData, lResult: TJSONObject;
  lHosts: TJSONData;
  lHost: TJSONObject;
  lModel: TCoordinatorModel;
  lStoredHosts: TCoordinatorStoredHosts;
  lStore: TCoordinatorHostStore;
  lStoreFile: string;
begin
  lStoreFile := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'coordinator-remote-host-alias-test.ini';
  DeleteFile(lStoreFile);
  SetLength(lStoredHosts, 1);
  lStoredHosts[0].InstanceId := CAddress;
  { Simulates an older persisted row whose address field became stale while
    its address-only manual identity stayed valid. }
  lStoredHosts[0].Address := '192.168.9.166';
  lStoredHosts[0].HostName := 'kip3 manual';
  lStoredHosts[0].ExecutablePath := '/manual/recorder';
  lStore := TCoordinatorHostStore.Create(lStoreFile);
  try
    lStore.Save(lStoredHosts);
  finally
    lStore.Free;
  end;

  lModel := TCoordinatorModel.Create;
  try
    lModel.EnableHostPersistence(lStoreFile);
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', CRecorderId);
      lData.Add('remote_address', CAddress);
      lData.Add('host_name', 'kip3');
      lData.Add('mac_address', CMac);
      lData.Add('os', 'linux');
      lData.Add('state', 'ready');
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lHosts := lModel.HostsJson;
    try
      Check(lHosts.Count = 1,
        'persisted remote address alias created a duplicate');
      lHost := TJSONObject(TJSONArray(lHosts).Items[0]);
      Check(lHost.Get('instance_id', '') = CRecorderId,
        'remote Recorder UUID was not adopted');
      Check(lHost.Get('address', '') = CAddress,
        'current remote address was not retained');
      Check(lHost.Get('host_name', '') = 'kip3 manual',
        'manual remote host name was not retained');
      Check(lHost.Get('mac_address', '') = CMac,
        'remote MAC did not complement the manual row');
      Check(lHost.Get('executable_path', '') = '/manual/recorder',
        'manual executable path was lost');
      Check(lHost.Get('os', '') = 'linux',
        'remote OS did not complement the manual row');
    finally
      lHosts.Free;
    end;
  finally
    lModel.Free;
    DeleteFile(lStoreFile);
  end;
end;

procedure CheckEditedUuidAddressSurvivesRestart;
const
  CAddress = '192.168.9.86';
var
  lData, lHost, lResult: TJSONObject;
  lHosts: TJSONData;
  lModel: TCoordinatorModel;
  lStoreFile: string;
begin
  lStoreFile := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'coordinator-edited-uuid-address-restart-test.ini';
  DeleteFile(lStoreFile);
  lModel := TCoordinatorModel.Create;
  try
    lModel.EnableHostPersistence(lStoreFile);
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', CRecorderId);
      lData.Add('host_name', 'kip4');
      lData.Add('state', 'discovered');
      lResult := lModel.RegisterHello(lData);
      try
        Check(lResult.Get('address', '') = '',
          'Recorder UUID must not be copied into network address');
      finally
        lResult.Free;
      end;
    finally
      lData.Free;
    end;
    Check(lModel.SetHostAddress(CRecorderId, CAddress),
      'manual address was not applied to UUID host');
  finally
    lModel.Free;
  end;

  lModel := TCoordinatorModel.Create;
  try
    lModel.EnableHostPersistence(lStoreFile);
    { Startup also reloads the legacy configured-address list.  It must not
      replace the stable Recorder UUID with the address identity. }
    RegisterConfigured(lModel, CAddress);
    lHosts := lModel.HostsJson;
    try
      Check(lHosts.Count = 1, 'configured address duplicated UUID after restart');
      lHost := TJSONObject(TJSONArray(lHosts).Items[0]);
      Check(lHost.Get('instance_id', '') = CRecorderId,
        'configured address replaced stable UUID after restart');
      Check(lHost.Get('address', '') = CAddress,
        'edited network address was lost after restart');
      Check(lHost.Get('host_name', '') = 'kip4',
        'manual host name was lost after restart');
    finally
      lHosts.Free;
    end;
  finally
    lModel.Free;
    DeleteFile(lStoreFile);
  end;
end;

procedure CheckLateNamedAddressAliasMerges;
const
  CAddress = '192.168.9.85';
var
  lData, lHost, lResult: TJSONObject;
  lHosts: TJSONData;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', CRecorderId);
      lData.Add('remote_address', CRecorderId);
      lData.Add('host_name', 'kip4');
      lData.Add('state', 'discovered');
      lResult := lModel.RegisterDiscovery(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', CAddress);
      lData.Add('remote_address', CAddress);
      lData.Add('host_name', 'kip4');
      lData.Add('state', 'configured');
      lResult := lModel.RegisterHello(lData);
      lResult.Free;
    finally
      lData.Free;
    end;

    lHosts := lModel.HostsJson;
    try
      Check(lHosts.Count = 1,
        'late kip4 address row did not remove the UUID-only duplicate');
      lHost := TJSONObject(TJSONArray(lHosts).Items[0]);
      Check(lHost.Get('instance_id', '') = CRecorderId,
        'kip4 UUID identity was not retained');
      Check(lHost.Get('address', '') = CAddress,
        'kip4 valid address was not retained');
      Check(lHost.Get('host_name', '') = 'kip4',
        'kip4 host name was not retained');
    finally
      lHosts.Free;
    end;
  finally
    lModel.Free;
  end;
end;

procedure CheckPcConnectionStates;
var
  lHost: TJSONObject;
  lModel: TCoordinatorModel;
begin
  lModel := TCoordinatorModel.Create;
  try
    RegisterLive(lModel);
    lHost := lModel.HostByAddressJson('127.0.0.1');
    try
      Check(lHost.Get('pc_connection_state', '') = 'unknown',
        'new host connection state must be unknown');
    finally
      lHost.Free;
    end;

    lModel.MarkPcReachabilityChecking('127.0.0.1');
    lHost := lModel.HostByAddressJson('127.0.0.1');
    try
      Check(lHost.Get('pc_connection_state', '') = 'checking',
        'host connection state did not change to checking');
    finally
      lHost.Free;
    end;

    lModel.ApplyPcReachability('127.0.0.1', True, Now);
    lHost := lModel.HostByAddressJson('127.0.0.1');
    try
      Check(lHost.Get('pc_connection_state', '') = 'reachable',
        'successful ping did not set reachable state');
    finally
      lHost.Free;
    end;

    lModel.MarkPcReachabilityChecking('127.0.0.1');
    lModel.ApplyPcReachability('127.0.0.1', False, Now);
    lHost := lModel.HostByAddressJson('127.0.0.1');
    try
      Check(lHost.Get('pc_connection_state', '') = 'unreachable',
        'failed ping did not set unreachable state');
    finally
      lHost.Free;
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

procedure CheckStoppedHeartbeatPreservesMeasurementPath;
const
  CMeasurementPath = '/home/user/Mera Files/usml/0018/';
var
  lData, lPayload, lRecording, lResult, lState: TJSONObject;
  lModel: TCoordinatorModel;

  procedure ApplyHeartbeat(const AState, APath: string);
  begin
    lData := TJSONObject.Create;
    try
      lData.Add('instance_id', CRecorderId);
      lData.Add('remote_address', '192.168.9.85');
      lPayload := TJSONObject.Create;
      lState := TJSONObject.Create;
      lState.Add('state', AState);
      lPayload.Add('state', lState);
      lRecording := TJSONObject.Create;
      lRecording.Add('local_path', APath);
      lPayload.Add('recording', lRecording);
      lData.Add('payload', lPayload);
      lResult := lModel.ApplyHeartbeat(lData);
      lResult.Free;
    finally
      lData.Free;
    end;
  end;

begin
  lModel := TCoordinatorModel.Create;
  try
    ApplyHeartbeat('recording', CMeasurementPath);
    ApplyHeartbeat('stopped', '');
    lResult := lModel.HostByIdJson(CRecorderId);
    try
      Check(lResult.Get('measurement_path', '') = CMeasurementPath,
        'stopped heartbeat erased the last measurement path');
    finally
      lResult.Free;
    end;
  finally
    lModel.Free;
  end;
end;

begin
  CheckDiscoveryRequiresHttpForManagement;
  CheckRecorderHostInfo;
  CheckLocalManualAndAutomaticDetailsMerge('127.0.0.1');
  CheckLocalManualAndAutomaticDetailsMerge('localhost');
  CheckIpv4MappedLocalAddressMerges;
  CheckAddressAndMacAliasChainMerges;
  CheckPersistedRemoteAddressAliasMerges;
  CheckEditedUuidAddressSurvivesRestart;
  CheckLateNamedAddressAliasMerges;
  CheckPcConnectionStates;
  CheckDifferentRemoteHostsStaySeparate;
  CheckDifferentLoopbackAddressStaysNew;
  CheckAlias('127.0.0.1');
  CheckAlias('localhost');
  CheckAlias(GetEnvironmentVariable('COMPUTERNAME'));
  CheckWildcardConfigPayload;
  CheckStoppedHeartbeatPreservesMeasurementPath;
  WriteLn('OK: configured local aliases merge into RecorderLnx UUID');
end.
