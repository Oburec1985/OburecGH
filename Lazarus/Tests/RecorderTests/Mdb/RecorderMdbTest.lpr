program RecorderMdbTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, DateUtils, SQLDB, sqlite3dyn, uRecorderSqlDbTypes,
  uRecorderSqlDbRuntime, uRecorderSqlDbManager, uRecorderMdbTypes,
  uRecorderMdbRepository;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create('CHECK FAILED: ' + AMessage);
end;

procedure Run;
var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderMdbRepository;
  lRuntime: TRecorderSqlDbRuntime;
  lSqlManager: TRecorderSqlDbManager;
  lQuery: TSQLQuery;
  lObjects: TMdbObjectInfos;
  lTests: TMdbTestInfos;
  lMeasurements: TMdbMeasurementInfos;
  lObjectId, lOtherObjectId, lTestId, lRegistrationId, lSignalId: string;
  lDatabaseFile, lConfigDir, lConfigFile, lDefaultObjectId: string;
  lRejected, lManualFound: Boolean;
  I: Integer;
begin
  lDatabaseFile := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorderlnx-mdb-test-' + IntToStr(GetProcessID) + '.sqlite3';
  if FileExists(lDatabaseFile) then DeleteFile(lDatabaseFile);
  lConfig := TRecorderSqlDbConfig.Create;
  try
    lConfig.ResetDefaults;
    lConfig.Backend := rsbSQLite;
    lConfig.Database := lDatabaseFile;
    lConfig.RootDirectory := ExtractFileDir(lDatabaseFile);
    lConfig.Enabled := True;
    lRepository := TRecorderMdbRepository.Create(lConfig);
    try
      lRepository.Open;
      Check(lRepository.Store.SchemaVersion = CRecorderSqlDbSchemaVersion,
        'schema version');
      lObjectId := lRepository.CreateObject('Изделие 01', 'Редуктор', 'SN-01');
      lOtherObjectId := lRepository.CreateObject('Изделие 02', 'Редуктор', 'SN-02');
      lTestId := lRepository.CreateTest(lObjectId, 'Ресурсное испытание',
        '{"mode":"resource"}', LocalTimeToUniversal(Now));
      Check(lRepository.ContextExists(lObjectId, lTestId), 'valid context');
      Check(not lRepository.ContextExists(lOtherObjectId, lTestId),
        'test cannot belong to another object');
      lRejected := False;
      try
        lRepository.Store.BeginRegistration(lOtherObjectId, lTestId,
          'invalid-context', LocalTimeToUniversal(Now));
      except
        on E: ERecorderSqlDbError do lRejected := True;
      end;
      Check(lRejected, 'invalid context rejected');
      lRegistrationId := lRepository.Store.BeginRegistration(lObjectId,
        lTestId, 'manual', LocalTimeToUniversal(Now));
      lSignalId := lRepository.Store.EnsureSignal(lObjectId, 'Torque',
        'double', 'N.m', 'Torque');
      lRepository.Store.InsertSignalValue(lRegistrationId, lSignalId,
        LocalTimeToUniversal(Now), 12.5, 0, 1);
      lRepository.Store.InsertEvent(lRegistrationId, lObjectId, lSignalId,
        LocalTimeToUniversal(Now), 'test.marker', 'info', 'marker', 12.5, '{}');
      lRepository.Store.InsertDataFile(RecorderSqlDbNewId, 'data/test.mera',
        'mera', 'mera', 10, 'checksum', 'ready', lRegistrationId, '', '',
        LocalTimeToUniversal(Now), LocalTimeToUniversal(Now),
        LocalTimeToUniversal(Now));
      lRepository.Store.FinishRegistration(lRegistrationId, 'closed',
        LocalTimeToUniversal(Now));
    finally
      lRepository.Free;
    end;

    { Regression: after an Mdb registration a legacy start with an empty
      context must switch the writer back to its configured default object. }
    lConfig.ObjectName := 'Default recorder object';
    lConfig.ObjectType := 'Recorder';
    lConfig.SerialNumber := 'DEFAULT-01';
    lRuntime := TRecorderSqlDbRuntime.Create(lConfig);
    try
      lRuntime.Start;
      Sleep(100);
      lRuntime.BeginRegistration(lObjectId, lTestId, 'runtime-mdb',
        LocalTimeToUniversal(Now));
      Check(lRuntime.SubmitValue('RuntimeValue', LocalTimeToUniversal(Now),
        1.0), 'runtime Mdb value queued');
      lRuntime.EndRegistration(LocalTimeToUniversal(Now));
      lRuntime.BeginRegistration('runtime-default', LocalTimeToUniversal(Now));
      Check(lRuntime.SubmitValue('RuntimeValue', LocalTimeToUniversal(Now),
        2.0), 'runtime default value queued');
      lRuntime.EndRegistration(LocalTimeToUniversal(Now));
      lRuntime.Stop;
      Check(lRuntime.LastError = '', 'runtime writer error: ' +
        lRuntime.LastError);
    finally
      lRuntime.Free;
    end;

    lRepository := TRecorderMdbRepository.Create(lConfig);
    try
      lRepository.ListObjects(lObjects);
      Check(Length(lObjects) = 3, 'objects survive reopen');
      lRepository.ListTests(lObjectId, lTests);
      Check((Length(lTests) = 1) and (lTests[0].Id = lTestId),
        'test survives reopen');
      lRepository.ListMeasurements(lObjectId, lTestId, lMeasurements);
      Check(Length(lMeasurements) = 2, 'measurements query by context, got ' +
        IntToStr(Length(lMeasurements)));
      lManualFound := False;
      for I := 0 to High(lMeasurements) do
        if lMeasurements[I].RegistrationId = lRegistrationId then
        begin
          lManualFound := True;
          Check(lMeasurements[I].ValueCount = 1, 'linked signal value');
          Check(lMeasurements[I].EventCount = 1, 'linked event');
          Check(lMeasurements[I].FileCount = 1, 'linked data file');
          Check(lMeasurements[I].Status = 'closed', 'measurement closed');
        end;
      Check(lManualFound, 'stable registration id');
      lQuery := TSQLQuery.Create(nil);
      try
        lQuery.DataBase := lRepository.Store.Connection;
        lQuery.Transaction := TSQLTransaction(
          lRepository.Store.Connection.Transaction);
        lQuery.SQL.Text := 'select id from objects where name=:name';
        lQuery.ParamByName('name').AsString := lConfig.ObjectName;
        lQuery.Open;
        Check(not lQuery.EOF, 'default runtime object exists');
        lDefaultObjectId := lQuery.Fields[0].AsString;
        lQuery.Close;
        lQuery.SQL.Text := 'select object_id,test_id from registrations ' +
          'where reason=:reason';
        lQuery.ParamByName('reason').AsString := 'runtime-default';
        lQuery.Open;
        Check(not lQuery.EOF, 'default registration exists');
        Check(lQuery.Fields[0].AsString = lDefaultObjectId,
          'legacy start returns to default object');
        Check(lQuery.Fields[1].AsString = '',
          'legacy start has no stale test context');
      finally
        lQuery.Free;
      end;
    finally
      lRepository.Free;
    end;

    { PersistMeasurementContext must restore both runtime and config fields
      when the configuration cannot be written. }
    lConfigDir := IncludeTrailingPathDelimiter(GetTempDir(False)) +
      'recorderlnx-mdb-config-' + IntToStr(GetProcessID);
    ForceDirectories(lConfigDir);
    lConfigFile := IncludeTrailingPathDelimiter(lConfigDir) + 'app.ini';
    lConfig.Enabled := False;
    lConfig.MdbObjectId := '';
    lConfig.MdbTestId := '';
    lConfig.SaveToFile(lConfigFile);
    lSqlManager := TRecorderSqlDbManager.Create(nil, nil);
    try
      lSqlManager.Configure(lConfigFile);
      DeleteFile(lConfigFile);
      CreateDir(lConfigFile);
      lRejected := False;
      try
        lSqlManager.PersistMeasurementContext(lObjectId, lTestId);
      except
        on E: Exception do lRejected := True;
      end;
      Check(lRejected, 'configuration write failure reported');
      Check((lSqlManager.MeasurementObjectId = '') and
        (lSqlManager.MeasurementTestId = ''), 'runtime context rolled back');
      Check((lSqlManager.Config.MdbObjectId = '') and
        (lSqlManager.Config.MdbTestId = ''), 'config context rolled back');
    finally
      lSqlManager.Free;
      RemoveDir(lConfigFile);
      RemoveDir(lConfigDir);
    end;
  finally
    lConfig.Free;
    if FileExists(lDatabaseFile) then DeleteFile(lDatabaseFile);
  end;
end;

begin
  try
    {$ifdef windows}
    SQLiteDefaultLibrary := 'winsqlite3.dll';
    {$endif}
    Run;
    WriteLn('RecorderMdbTest: OK');
  except
    on E: Exception do
    begin
      WriteLn(StdErr, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
