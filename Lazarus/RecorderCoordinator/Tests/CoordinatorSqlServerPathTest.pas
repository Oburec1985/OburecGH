program CoordinatorSqlServerPathTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses Classes, SysUtils, fpjson, uCoordinatorModel;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

procedure Heartbeat(AModel: TCoordinatorModel; const AId, AAddress, APath: string);
var
  lInput, lPayload, lState, lResult: TJSONObject;
begin
  lInput := TJSONObject.Create;
  try
    lInput.Add('instance_id', AId);
    lInput.Add('remote_address', AAddress);
    lPayload := TJSONObject.Create;
    lState := TJSONObject.Create;
    lState.Add('state', 'stopped');
    lState.Add('sql_local_database', APath);
    lPayload.Add('state', lState);
    lInput.Add('payload', lPayload);
    lResult := AModel.ApplyHeartbeat(lInput);
    lResult.Free;
  finally
    lInput.Free;
  end;
end;

function Queue(AModel: TCoordinatorModel; const AServer: string): TJSONObject;
var
  lInput, lPayload: TJSONObject;
begin
  lInput := TJSONObject.Create;
  try
    lInput.Add('instance_id', 'client');
    lInput.Add('command', 'config.sql_database.set');
    lPayload := TJSONObject.Create;
    lPayload.Add('host', AServer);
    lPayload.Add('port', 3050);
    lPayload.Add('server_database', '/wrong/panel/database.fdb');
    lPayload.Add('database', '/legacy/panel/database.fdb');
    lInput.Add('payload', lPayload);
    Result := AModel.EnqueueCommand(lInput);
  finally
    lInput.Free;
  end;
end;

const
  CServer = '192.0.2.92';
  CServerDatabase = '/srv/server-storage/local-recorder.fdb';
var
  lModel: TCoordinatorModel;
  lResult, lPayload, lAck, lAckResult, lDiscovery: TJSONObject;
  lStore: string;
begin
  lStore := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-server-path-' + IntToHex(GetTickCount64, 16) + '.ini';
  try
    lModel := TCoordinatorModel.Create;
    try
      lModel.EnableHostPersistence(lStore, True);
      Heartbeat(lModel, 'server', CServer, CServerDatabase);
      Heartbeat(lModel, 'client', '192.0.2.200', '/client/local.fdb');
      lDiscovery := TJSONObject.Create;
      try
        lDiscovery.Add('instance_id', 'server');
        lDiscovery.Add('address', CServer);
        lDiscovery.Add('sql_local_database', '/wrong/udp/database.fdb');
        lResult := lModel.RegisterDiscovery(lDiscovery);
        lResult.Free;
      finally lDiscovery.Free; end;
      lResult := lModel.HostByIdJson('server');
      try Check(lResult.Get('sql_local_database', '') = CServerDatabase,
        'server local metadata not exposed');
      finally lResult.Free; end;
      lResult := Queue(lModel, '192.0.2.99');
      try
        lPayload := TJSONObject(lResult.Find('payload'));
        Check(lPayload.Find('server_database') = nil,
          'unknown server accepted the panel supplied path');
        Check(lPayload.Find('database') = nil,
          'legacy panel database path was transmitted');
      finally lResult.Free; end;
      lResult := Queue(lModel, CServer);
      try
        lPayload := TJSONObject(lResult.Find('payload'));
        Check(lPayload.Get('server_database', '') = CServerDatabase,
          'target server metadata did not replace panel path');
        Check(lPayload.Get('host', '') = CServer, 'server host changed');
        Check(lPayload.Get('port', 0) = 3050, 'server port changed');
      finally lResult.Free; end;
    finally lModel.Free; end;
    lModel := TCoordinatorModel.Create;
    try
      lModel.EnableHostPersistence(lStore, True);
      lResult := lModel.NextCommand('client');
      try
        Check(TJSONObject(lResult.Find('payload')).Find('server_database') = nil,
          'unknown server gained a path after restart');
        lAck := TJSONObject.Create;
        try
          lAck.Add('command_id', lResult.Get('command_id', ''));
          lAck.Add('result_code', 'noError');
          lAckResult := lModel.CompleteCommand(lAck);
          lAckResult.Free;
        finally lAck.Free; end;
      finally lResult.Free; end;
      lResult := lModel.NextCommand('client');
      try Check(TJSONObject(lResult.Find('payload')).Get('server_database', '') =
        CServerDatabase, 'trusted path was lost during restart/retry');
      finally lResult.Free; end;
    finally lModel.Free; end;
    with TStringList.Create do
    try
      LoadFromFile(lStore + '.sql-queue.json');
      Check(Pos(CServerDatabase, Text) > 0, 'trusted path was not persisted');
      Check(Pos('/wrong/panel/database.fdb', Text) = 0, 'panel path persisted');
    finally Free; end;
    WriteLn('OK: SQL server path comes from matching Recorder metadata');
  finally
    DeleteFile(lStore);
    DeleteFile(lStore + '.sql-queue.json');
    DeleteFile(lStore + '.sql-queue.json.tmp');
  end;
end.
