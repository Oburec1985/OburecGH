program CoordinatorSqlQueueTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Exercises pending SQL endpoint delivery, restart recovery and ordered retry. }

uses Classes, SysUtils, fpjson, uCoordinatorModel;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

function QueueChange(AModel: TCoordinatorModel; const AHost: string): string;
var
  lData, lPayload, lResult: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('instance_id', 'test-recorder');
    lData.Add('command', 'config.sql_database.set');
    lPayload := TJSONObject.Create;
    lPayload.Add('host', AHost);
    lPayload.Add('port', 3050);
    lPayload.Add('password', 'secret-marker-not-for-storage');
    lData.Add('payload', lPayload);
    lResult := AModel.EnqueueCommand(lData);
    try Result := lResult.Get('command_id', ''); finally lResult.Free; end;
  finally
    lData.Free;
  end;
end;

procedure Complete(AModel: TCoordinatorModel; const ACommandId: string);
var
  lData, lResult: TJSONObject;
begin
  lData := TJSONObject.Create;
  try
    lData.Add('command_id', ACommandId);
    lData.Add('result_code', 'noError');
    lResult := AModel.CompleteCommand(lData);
    lResult.Free;
  finally
    lData.Free;
  end;
end;

procedure CheckStopSupersedesStart;
var
  lModel: TCoordinatorModel;
  lData, lResult: TJSONObject;
  lIndex: Integer;
  lFile: string;
begin
  lModel := TCoordinatorModel.Create;
  lFile := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-stop-test-' + IntToHex(GetTickCount64, 16) + '.ini';
  try
    lModel.EnableHostPersistence(lFile, True);
    for lIndex := 0 to 3 do
    begin
      lData := TJSONObject.Create;
      try
        lData.Add('instance_id', 'test-recorder');
        case lIndex of
          0: lData.Add('command', 'recording.start');
          1: lData.Add('command', 'recording.start_at');
          2: lData.Add('command', 'recording.preview');
        else
          lData.Add('command', 'recording.stop');
        end;
        lResult := lModel.EnqueueCommand(lData);
        lResult.Free;
      finally
        lData.Free;
      end;
    end;
    lResult := lModel.NextCommand('test-recorder');
    try Check(lResult.Get('command', '') = 'recording.stop', 'stop priority');
    finally lResult.Free; end;
    lResult := lModel.NextCommand('test-recorder');
    try Check(lResult.Get('result_code', '') = 'noCommand', 'stale start after stop');
    finally lResult.Free; end;
  finally
    lModel.Free;
    DeleteFile(lFile);
    DeleteFile(lFile + '.sql-queue.json');
  end;
end;

procedure CheckExperimentalQueueDisabled;
var
  lModel: TCoordinatorModel;
  lData, lResult: TJSONObject;
  lFile: string;
  lText: TStringList;
begin
  lFile := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-disabled-test-' + IntToHex(GetTickCount64, 16) + '.ini';
  lText := TStringList.Create;
  lModel := TCoordinatorModel.Create;
  try
    lText.Text := 'untouched';
    lText.SaveToFile(lFile + '.sql-queue.json');
    lModel.EnableHostPersistence(lFile);
    QueueChange(lModel, '192.168.9.66');
    lResult := lModel.NextCommand('test-recorder');
    try Check(lResult.Get('command', '') = 'config.sql_database.set',
      'normal in-memory delivery changed');
    finally lResult.Free; end;
    lResult := lModel.NextCommand('test-recorder');
    try Check(lResult.Get('result_code', '') = 'noCommand',
      'disabled queue unexpectedly retried');
    finally lResult.Free; end;
    lText.LoadFromFile(lFile + '.sql-queue.json');
    Check(Trim(lText.Text) = 'untouched', 'disabled queue was modified');
  finally
    lModel.Free;
    lText.Free;
    DeleteFile(lFile);
    DeleteFile(lFile + '.sql-queue.json');
  end;
end;

procedure CheckLegacyQueuedPathIgnored;
var
  lModel: TCoordinatorModel;
  lCommand: TJSONObject;
  lText: TStringList;
  lStore: string;
begin
  lStore := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-legacy-path-' + IntToHex(GetTickCount64, 16) + '.ini';
  lText := TStringList.Create;
  lModel := TCoordinatorModel.Create;
  try
    lText.Text := '[{"command_id":"legacy-path","instance_id":"test-recorder",' +
      '"host":"192.168.9.92","port":3050,"database":"/wrong/panel/path.fdb"}]';
    lText.SaveToFile(lStore + '.sql-queue.json');
    lModel.EnableHostPersistence(lStore, True);
    lCommand := lModel.NextCommand('test-recorder');
    try
      Check(lCommand.Get('command_id', '') = 'legacy-path', 'legacy command lost');
      Check(TJSONObject(lCommand.Find('payload')).Find('database') = nil,
        'legacy queued database path was transmitted');
    finally
      lCommand.Free;
    end;
  finally
    lModel.Free;
    lText.Free;
    DeleteFile(lStore);
    DeleteFile(lStore + '.sql-queue.json');
  end;
end;

var
  lModel: TCoordinatorModel;
  lCommand, lData, lResult: TJSONObject;
  lText: TStringList;
  lStore, lFirst, lSecond: string;
begin
  CheckLegacyQueuedPathIgnored;
  CheckExperimentalQueueDisabled;
  CheckStopSupersedesStart;
  lStore := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-sql-queue-' + IntToHex(GetTickCount64, 16) + '.ini';
  try
    lModel := TCoordinatorModel.Create;
    try
      lModel.EnableHostPersistence(lStore, True);
      lFirst := QueueChange(lModel, '192.168.9.66');
      lSecond := QueueChange(lModel, '192.168.9.92');
      lText := TStringList.Create;
      try
        lText.LoadFromFile(lStore + '.sql-queue.json');
        Check(Pos('secret-marker-not-for-storage', lText.Text) = 0,
          'queue must never persist the password');
        Check(Pos('"database"', lText.Text) = 0,
          'address-only queue must not persist a database path');
      finally
        lText.Free;
      end;
      lCommand := lModel.NextCommand('test-recorder');
      try Check(lCommand.Get('command_id', '') = lFirst, 'first revision');
      finally lCommand.Free; end;
      lData := TJSONObject.Create;
      try
        lData.Add('command_id', lFirst);
        lData.Add('result_code', 'notReady');
        lResult := lModel.CompleteCommand(lData);
        try Check(lResult.Get('state', '') = 'accepted',
          'notReady must remain queued for retry');
        finally lResult.Free; end;
      finally
        lData.Free;
      end;
      lData := TJSONObject.Create;
      try
        lData.Add('instance_id', 'test-recorder');
        lData.Add('command', 'recording.start');
        lResult := lModel.EnqueueCommand(lData);
        lResult.Free;
      finally
        lData.Free;
      end;
      lData := TJSONObject.Create;
      try
        lData.Add('instance_id', 'test-recorder');
        lData.Add('command', 'recording.stop');
        lResult := lModel.EnqueueCommand(lData);
        lResult.Free;
      finally
        lData.Free;
      end;
      lCommand := lModel.NextCommand('test-recorder');
      try Check(lCommand.Get('command', '') = 'recording.stop',
        'pending SQL must not block stop');
      finally lCommand.Free; end;
      lCommand := lModel.NextCommand('test-recorder');
      try Check(lCommand.Get('result_code', '') = 'noCommand',
        'later revision overtook accepted command');
      finally lCommand.Free; end;
    finally
      lModel.Free;
    end;
    lModel := TCoordinatorModel.Create;
    try
      lModel.EnableHostPersistence(lStore, True);
      lCommand := lModel.NextCommand('test-recorder');
      try
        Check(lCommand.Get('command_id', '') = lFirst, 'restart did not retry');
        Check(TJSONObject(lCommand.Find('payload')).Get('host', '') = '192.168.9.66',
          'host changed during recovery');
        Check(TJSONObject(lCommand.Find('payload')).Find('password') = nil,
          'recovered payload should not contain credentials');
        Check(TJSONObject(lCommand.Find('payload')).Find('database') = nil,
          'recovered payload should not contain a database path');
      finally
        lCommand.Free;
      end;
      Sleep(10100);
      lData := TJSONObject.Create;
      try
        lData.Add('instance_id', 'test-recorder');
        lData.Add('command', 'recording.stop');
        lResult := lModel.EnqueueCommand(lData);
        lResult.Free;
      finally
        lData.Free;
      end;
      lCommand := lModel.NextCommand('test-recorder');
      try Check(lCommand.Get('command', '') = 'recording.stop',
        'SQL retry must not take priority over stop');
      finally lCommand.Free; end;
      lCommand := lModel.NextCommand('test-recorder');
      try Check(lCommand.Get('command_id', '') = lFirst, 'lost ACK was not retried');
      finally lCommand.Free; end;
      Complete(lModel, lFirst);
      lCommand := lModel.NextCommand('test-recorder');
      try Check(lCommand.Get('command_id', '') = lSecond, 'second revision lost');
      finally lCommand.Free; end;
      Complete(lModel, lSecond);
    finally
      lModel.Free;
    end;
    lModel := TCoordinatorModel.Create;
    try
      lModel.EnableHostPersistence(lStore, True);
      lCommand := lModel.NextCommand('test-recorder');
      try Check(lCommand.Get('result_code', '') = 'noCommand',
        'completed commands returned after restart');
      finally lCommand.Free; end;
    finally
      lModel.Free;
    end;
    WriteLn('OK: durable SQL command delivery');
  finally
    DeleteFile(lStore);
    DeleteFile(lStore + '.sql-queue.json');
    DeleteFile(lStore + '.sql-queue.json.tmp');
  end;
end.
