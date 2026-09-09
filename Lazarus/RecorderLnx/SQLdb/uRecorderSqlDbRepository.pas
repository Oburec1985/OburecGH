unit uRecorderSqlDbRepository;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, StrUtils, Math, DB, SQLDB,
  uRecorderSqlDbTypes;

type
  TRecorderSqlDbRepository = class
  private
    fConfig: TRecorderSqlDbConfig;
    fConnection: TSQLConnection;
    fTransaction: TSQLTransaction;
    fDatabaseEnsured: Boolean;
    function CreateConnection: TSQLConnection;
    function TableExists(const AName: string): Boolean;
    function IndexExists(const AName: string): Boolean;
    function ColumnExists(const ATableName, AColumnName: string): Boolean;
    procedure CreateTableIfMissing(const AName, ASql: string);
    procedure CreateIndexIfMissing(const AName, ASql: string);
    procedure AddColumnIfMissing(const ATableName, AColumnName,
      ASql: string);
    procedure Exec(const ASql: string);
    function ScalarInt(const ASql: string): Int64;
    function FindId(const ASql, AParamName, AParamValue: string): string;
    procedure MigrateSchema(AVersion: Integer);
    procedure Commit;
    procedure CommitAndRestart;
  public
    constructor Create(AConfig: TRecorderSqlDbConfig);
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure EnsureDatabase;
    procedure Flush;
    function SchemaVersion: Integer;
    function HealthCheck: Boolean;
    function EnsureObject(const AName, AObjectType, ASerialNumber: string): string;
    procedure SetObjectProperty(const AObjectId, AName, AValueType,
      AValueText: string);
    function EnsureSignal(const AObjectId, AName, AValueType, AUnit,
      ARecorderTag: string; const ARecorderSourceId: string = '';
      const ARecorderAddress: string = ''): string;
    function RenameSignalByRecorderAddress(const AObjectId,
      ARecorderSourceId, ARecorderAddress, ANewName, AUnit: string): Boolean;
    function BeginRegistration(const AObjectId, ATestId, AReason: string;
      AStartedUtc: Double): string;
    procedure FinishRegistration(const ARegistrationId, AStatus: string;
      AFinishedUtc: Double);
    procedure InsertSignalValue(const ARegistrationId, ASignalId: string;
      ATimestampUtc, AValue: Double; AQuality: Integer; ASequenceNo: Int64);
    procedure InsertEvent(const ARegistrationId, AObjectId, ASignalId: string;
      ATimestampUtc: Double; const AEventType, ASeverity, AText: string;
      AValue: Double; const APayloadJson: string);
    procedure InsertDataFile(const AId, AStorageKey, ADataType, AFormat: string;
      ASize: Int64; const AChecksum, AState, ARegistrationId, ASignalId,
      AEventId: string; AAnchorUtc, AFromUtc, AToUtc: Double);
    function UpsertRecorderInstance(const AInstanceKey, AHostName,
      ADisplayName, APlatform: string; ALastSeenAtUtc: Double): string;
    procedure SetSystemSetting(const AKey, AValue, AValueType,
      AUpdatedByInstanceId: string; AUpdatedAtUtc: Double);
    function GetSystemSetting(const AKey: string; out AValue,
      AValueType: string): Boolean;
    function BeginMeraRecording(const ARecording: TRecorderSqlDbMeraRecording): string;
    procedure CompleteMeraRecording(const ARecordingId, AState,
      AEntryFileId, AErrorText: string; AFinishedAtUtc: Double);
    procedure UpsertMeraFile(const AFile: TRecorderSqlDbMeraFile);
    procedure UpsertDataFileLocation(const ALocation: TRecorderSqlDbFileLocation);
    procedure ListMeraRecordings(AFromUtc, AToUtc: Double;
      out AItems: TRecorderSqlDbMeraRecordings);
    function GetCurrentMeraRecording(const ARecorderInstanceId: string;
      out AItem: TRecorderSqlDbMeraRecording): Boolean;
    procedure ListMeraFiles(const ARecordingId: string;
      out AItems: TRecorderSqlDbMeraFiles);
    procedure ListDataFileLocations(const AFileId: string;
      out AItems: TRecorderSqlDbFileLocations);
    procedure ListMeraRecordingEvents(AFromUtc, AToUtc: Double;
      out AItems: TRecorderSqlDbMeraEvents);
    function GetMeraEventSnapshot(const AEventId: string;
      out AEventUtc, AFirstStartedUtc, ALastFinishedUtc: Double;
      out ARecordingCount: Integer): Boolean;
    function UpdateMeraEvent(const AEventId, ADisplayName,
      ADescription: string): Boolean;
    function UpdateDataFileLocationPath(const AEventId, ALocationId,
      APathKey: string): Boolean;
    function DeleteMeraEvent(const AEventId: string): Boolean; overload;
    function DeleteMeraEvent(const AEventId: string; out ADeletedPackages,
      ADeletedFiles: Integer): Boolean; overload;
    procedure ListMeraPackages(const AEventId: string;
      out AItems: TRecorderSqlDbMeraPackages);
    procedure ListAttachments(AFromUtc, AToUtc: Double; AItems: TList);
    procedure ListSignalNames(AItems: TStrings);
    procedure ListSignalInfos(out AItems: TRecorderSqlDbSignalInfos;
      AWithPointCounts: Boolean);
    function DatabaseAttachmentName(out AName: string): Boolean;
    procedure DeleteSignalsByName(ANames: TStrings; out ASignalCount,
      AValueCount: Int64);
    procedure DeleteSignalValuesInterval(ASignalNames: TStrings; AFromUtc,
      AToUtc: Double; out AValueCount: Int64);
    function GetTrendTimeRange(out AFromUtc, AToUtc: Double;
      out APointCount: Int64): Boolean;
    procedure ReadTrendPoints(ASignalNames: TStrings; AFromUtc, AToUtc: Double;
      AMaxPointsPerSignal: Integer; out APoints: TRecorderSqlTrendPoints;
      AExcludeFrom: Boolean = False);
    function CountRows(const ATableName: string): Int64;
    property Connection: TSQLConnection read fConnection;
  end;

implementation

uses
  SQLite3Conn, IBConnection, PQConnection;

const
  CSchemaTables: array[0..17] of string = (
    'schema_info', 'objects', 'property_definitions', 'object_property_values',
    'signals', 'signal_bindings', 'tests', 'registrations',
    'recording_policies', 'signal_values', 'events', 'data_files',
    'data_file_links', 'recorder_instances', 'system_settings',
    'mera_recordings', 'mera_recording_files', 'data_file_locations');

function FirebirdOpenError(const AConfig: TRecorderSqlDbConfig;
  const AMessage: string): ERecorderSqlDbError;
var
  lMessage: string;
begin
  lMessage := LowerCase(AMessage);
  if (Pos('fbclient', lMessage) > 0) or
     (Pos('libgds', lMessage) > 0) or
     (Pos('client library', lMessage) > 0) or
     (Pos('client libraries', lMessage) > 0) then
    Result := ERecorderSqlDbError.Create(
      'Не найдена клиентская библиотека Firebird. Сервер Firebird на этом ПК ' +
      'не требуется, но для доступа к удалённой БД нужно установить пакет ' +
      'libfbclient2 (Linux) или fbclient.dll той же разрядности (Windows). ' +
      'Исходная ошибка: ' + AMessage)
  else
    Result := ERecorderSqlDbError.CreateFmt(
      'Не удалось открыть Firebird %s:%d, БД %s. %s',
      [AConfig.Host, AConfig.Port, AConfig.DatabaseFileName, AMessage]);
end;

constructor TRecorderSqlDbRepository.Create(AConfig: TRecorderSqlDbConfig);
begin
  inherited Create;
  if AConfig = nil then
    raise ERecorderSqlDbError.Create('SQLdb config is nil');
  fConfig := TRecorderSqlDbConfig.Create;
  fConfig.Assign(AConfig);
end;

destructor TRecorderSqlDbRepository.Destroy;
begin
  Close;
  fConfig.Free;
  inherited Destroy;
end;

function TRecorderSqlDbRepository.CreateConnection: TSQLConnection;
var
  lHost: string;
begin
  case fConfig.Backend of
    rsbSQLite:
      begin
        Result := TSQLite3Connection.Create(nil);
        Result.DatabaseName := fConfig.DatabaseFileName;
      end;
    rsbFirebird:
      begin
        Result := TIBConnection.Create(nil);
        lHost := Trim(fConfig.Host);
        if lHost = '' then
          lHost := '127.0.0.1';
        Result.HostName := lHost;
        if fConfig.Port <> 0 then
          TIBConnection(Result).Port := fConfig.Port;
        Result.DatabaseName := fConfig.DatabaseFileName;
        Result.UserName := fConfig.UserName;
        Result.Password := fConfig.Password;
        TIBConnection(Result).CharSet := 'UTF8';
      end;
    rsbPostgreSQL:
      begin
        Result := TPQConnection.Create(nil);
        Result.HostName := fConfig.Host;
        Result.DatabaseName := fConfig.Database;
        Result.UserName := fConfig.UserName;
        Result.Password := fConfig.Password;
        if fConfig.Port <> 0 then
          Result.Params.Values['port'] := IntToStr(fConfig.Port);
      end;
  else
    raise ERecorderSqlDbError.Create('Unsupported SQLdb backend');
  end;
end;

procedure TRecorderSqlDbRepository.Open;
var
  lDir: string;
  lIb: TIBConnection;
begin
  if fConnection <> nil then Exit;
  fConfig.RequireValid;
  if fConfig.Backend = rsbSQLite then
  begin
    lDir := ExtractFileDir(fConfig.DatabaseFileName);
    if not ForceDirectories(lDir) then
      raise ERecorderSqlDbError.CreateFmt('Cannot create SQLdb directory: %s', [lDir]);
  end;
  fConnection := CreateConnection;
  fTransaction := TSQLTransaction.Create(nil);
  fConnection.Transaction := fTransaction;
  try
    if (fConfig.Backend = rsbFirebird) and fConfig.IsLocalFileDatabase and
       (not FileExists(fConfig.DatabaseFileName)) then
    begin
      lDir := ExtractFileDir(fConfig.DatabaseFileName);
      if not ForceDirectories(lDir) then
        raise ERecorderSqlDbError.CreateFmt('Cannot create Firebird directory: %s', [lDir]);
      lIb := TIBConnection(fConnection);
      lIb.CreateDB;
    end
    else
      fConnection.Open;
    if not fTransaction.Active then fTransaction.StartTransaction;
  except
    on E: Exception do
    begin
      Close;
      if fConfig.Backend = rsbFirebird then
        raise FirebirdOpenError(fConfig, E.Message);
      raise;
    end;
  end;
end;

procedure TRecorderSqlDbRepository.Close;
begin
  fDatabaseEnsured := False;
  if fTransaction <> nil then
  begin
    if fTransaction.Active then
      try fTransaction.Commit except fTransaction.Rollback; end;
  end;
  FreeAndNil(fTransaction);
  if fConnection <> nil then
  begin
    if fConnection.Connected then fConnection.Close;
    FreeAndNil(fConnection);
  end;
end;

procedure TRecorderSqlDbRepository.ListSignalNames(AItems: TStrings);
var
  lQuery: TSQLQuery;
begin
  if AItems = nil then Exit;
  AItems.Clear;
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'select distinct name from signals order by name';
    lQuery.Open;
    while not lQuery.EOF do
    begin
      AItems.Add(lQuery.Fields[0].AsString);
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.ListSignalInfos(
  out AItems: TRecorderSqlDbSignalInfos; AWithPointCounts: Boolean);
var
  lQuery: TSQLQuery;
  lIndex: Integer;
begin
  SetLength(AItems, 0);
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    if AWithPointCounts then
      lQuery.SQL.Text :=
        'select s.name, s.unit_name, s.recorder_source_id, ' +
        's.recorder_address, count(v.id) ' +
        'from signals s left join signal_values v on v.signal_id=s.id ' +
        'group by s.name, s.unit_name, s.recorder_source_id, ' +
        's.recorder_address order by s.name'
    else
      lQuery.SQL.Text :=
        'select s.name, s.unit_name, s.recorder_source_id, ' +
        's.recorder_address, cast(0 as bigint) from signals s order by s.name';
    lQuery.Open;
    while not lQuery.EOF do
    begin
      lIndex := Length(AItems);
      SetLength(AItems, lIndex + 1);
      AItems[lIndex].Name := lQuery.Fields[0].AsString;
      AItems[lIndex].UnitName := lQuery.Fields[1].AsString;
      AItems[lIndex].RecorderSourceId := lQuery.Fields[2].AsString;
      AItems[lIndex].RecorderAddress := lQuery.Fields[3].AsString;
      AItems[lIndex].PointCount := lQuery.Fields[4].AsLargeInt;
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.DatabaseAttachmentName(out AName: string): Boolean;
var
  lQuery: TSQLQuery;
begin
  AName := '';
  Result := False;
  EnsureDatabase;
  if fConfig.Backend <> rsbFirebird then
  begin
    AName := fConfig.DatabaseFileName;
    Exit(AName <> '');
  end;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select mon$attachment_name from mon$attachments ' +
      'where mon$attachment_id=current_connection';
    lQuery.Open;
    if not lQuery.EOF then
      AName := Trim(lQuery.Fields[0].AsString);
    Result := AName <> '';
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.DeleteSignalsByName(ANames: TStrings;
  out ASignalCount, AValueCount: Int64);
var
  I: Integer;
  lQuery: TSQLQuery;
  lName: string;
begin
  ASignalCount := 0;
  AValueCount := 0;
  if (ANames = nil) or (ANames.Count = 0) then Exit;
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    for I := 0 to ANames.Count - 1 do
    begin
      lName := Trim(ANames[I]);
      if lName = '' then Continue;
      lQuery.Close;
      lQuery.SQL.Text :=
        'select count(*) from signal_values v join signals s on s.id=v.signal_id ' +
        'where s.name=:name';
      lQuery.Params.ParamByName('name').AsString := lName;
      lQuery.Open;
      Inc(AValueCount, lQuery.Fields[0].AsLargeInt);
      lQuery.Close;
      lQuery.SQL.Text :=
        'delete from signal_values where signal_id in ' +
        '(select id from signals where name=:name)';
      lQuery.Params.ParamByName('name').AsString := lName;
      lQuery.ExecSQL;
      lQuery.SQL.Text :=
        'delete from signal_bindings where signal_id in ' +
        '(select id from signals where name=:name)';
      lQuery.Params.ParamByName('name').AsString := lName;
      lQuery.ExecSQL;
      lQuery.SQL.Text := 'delete from signals where name=:name';
      lQuery.Params.ParamByName('name').AsString := lName;
      lQuery.ExecSQL;
      Inc(ASignalCount);
    end;
    Commit;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.DeleteSignalValuesInterval(
  ASignalNames: TStrings; AFromUtc, AToUtc: Double; out AValueCount: Int64);
var
  I: Integer;
  lQuery: TSQLQuery;
  lName: string;
begin
  AValueCount := 0;
  if (ASignalNames = nil) or (ASignalNames.Count = 0) or
    (AToUtc <= AFromUtc) then Exit;
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    for I := 0 to ASignalNames.Count - 1 do
    begin
      lName := Trim(ASignalNames[I]);
      if lName = '' then Continue;
      lQuery.Close;
      lQuery.SQL.Text :=
        'select count(*) from signal_values v join signals s on s.id=v.signal_id ' +
        'where s.name=:name and v.timestamp_utc>=:time_from ' +
        'and v.timestamp_utc<=:time_to';
      lQuery.Params.ParamByName('name').AsString := lName;
      lQuery.Params.ParamByName('time_from').AsFloat := AFromUtc;
      lQuery.Params.ParamByName('time_to').AsFloat := AToUtc;
      lQuery.Open;
      Inc(AValueCount, lQuery.Fields[0].AsLargeInt);
      lQuery.Close;
      lQuery.SQL.Text :=
        'delete from signal_values where signal_id in ' +
        '(select id from signals where name=:name) ' +
        'and timestamp_utc>=:time_from and timestamp_utc<=:time_to';
      lQuery.Params.ParamByName('name').AsString := lName;
      lQuery.Params.ParamByName('time_from').AsFloat := AFromUtc;
      lQuery.Params.ParamByName('time_to').AsFloat := AToUtc;
      lQuery.ExecSQL;
    end;
    Commit;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.GetTrendTimeRange(out AFromUtc,
  AToUtc: Double; out APointCount: Int64): Boolean;
var
  lQuery: TSQLQuery;
begin
  AFromUtc := 0;
  AToUtc := 0;
  APointCount := 0;
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select count(*), min(timestamp_utc), max(timestamp_utc) '+
      'from signal_values';
    lQuery.Open;
    APointCount := lQuery.Fields[0].AsLargeInt;
    Result := (APointCount > 0) and (not lQuery.Fields[1].IsNull) and
      (not lQuery.Fields[2].IsNull);
    if Result then
    begin
      AFromUtc := lQuery.Fields[1].AsFloat;
      AToUtc := lQuery.Fields[2].AsFloat;
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.ReadTrendPoints(ASignalNames: TStrings;
  AFromUtc, AToUtc: Double; AMaxPointsPerSignal: Integer;
  out APoints: TRecorderSqlTrendPoints; AExcludeFrom: Boolean);
var
  I, J, lBucket, lLastBucket, lSignalCount, lOutputStart: Integer;
  lQuery: TSQLQuery;
  lName: string;
  lPoint, lFirstPoint, lLastPoint: TRecorderSqlTrendPoint;
  lSignalPoints: TRecorderSqlTrendPoints;
  lHasFirst: Boolean;
begin
  SetLength(APoints, 0);
  if (ASignalNames = nil) or (ASignalNames.Count = 0) or
    (AToUtc <= AFromUtc) then Exit;
  if AMaxPointsPerSignal < 32 then AMaxPointsPerSignal := 32;
  EnsureDatabase;
  { A long-lived SQL Trend repository must begin each read with a fresh
    transaction snapshot, otherwise Firebird can keep showing the rows that
    were visible during the first live request. }
  CommitAndRestart;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select v.id, s.name, v.timestamp_utc, v.measured_value '+
      'from signal_values v join signals s on s.id=v.signal_id '+
      'where s.name=:signal_name and v.timestamp_utc' +
      IfThen(AExcludeFrom, '>', '>=') + ':time_from '+
      'and v.timestamp_utc<=:time_to order by v.timestamp_utc';
    SetLength(lSignalPoints, AMaxPointsPerSignal);
    for I := 0 to ASignalNames.Count - 1 do
    begin
      lName := ASignalNames[I];
      lQuery.Close;
      lQuery.ParamByName('signal_name').AsString := lName;
      lQuery.ParamByName('time_from').AsFloat := AFromUtc;
      lQuery.ParamByName('time_to').AsFloat := AToUtc;
      lQuery.Open;
      lSignalCount := 0;
      lLastBucket := -1;
      lHasFirst := False;
      while not lQuery.EOF do
      begin
        lPoint.RowId := lQuery.Fields[0].AsString;
        lPoint.SignalName := lQuery.Fields[1].AsString;
        lPoint.TimestampUtc := lQuery.Fields[2].AsFloat;
        lPoint.Value := lQuery.Fields[3].AsFloat;
        if not lHasFirst then
        begin
          lFirstPoint := lPoint;
          lLastPoint := lPoint;
          lHasFirst := True;
        end
        else
        begin
          lLastPoint := lPoint;
          lBucket := EnsureRange(Floor((lPoint.TimestampUtc - AFromUtc) /
            (AToUtc - AFromUtc) * (AMaxPointsPerSignal - 2)), 0,
            AMaxPointsPerSignal - 3);
          if (lBucket <> lLastBucket) and
            (lSignalCount < AMaxPointsPerSignal - 2) then
          begin
            lSignalPoints[1 + lSignalCount] := lPoint;
            Inc(lSignalCount);
            lLastBucket := lBucket;
          end;
        end;
        lQuery.Next;
      end;
      if not lHasFirst then Continue;
      lSignalPoints[0] := lFirstPoint;
      Inc(lSignalCount);
      if lLastPoint.TimestampUtc <>
        lSignalPoints[lSignalCount - 1].TimestampUtc then
      begin
        lSignalPoints[lSignalCount] := lLastPoint;
        Inc(lSignalCount);
      end;
      lOutputStart := Length(APoints);
      SetLength(APoints, lOutputStart + lSignalCount);
      for J := 0 to lSignalCount - 1 do
        APoints[lOutputStart + J] := lSignalPoints[J];
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.Commit;
begin
  if fTransaction.Active then fTransaction.CommitRetaining;
end;

procedure TRecorderSqlDbRepository.CommitAndRestart;
begin
  if fTransaction.Active then
    fTransaction.Commit;
  fTransaction.StartTransaction;
end;

procedure TRecorderSqlDbRepository.Flush;
begin
  Commit;
end;

procedure TRecorderSqlDbRepository.Exec(const ASql: string);
begin
  fConnection.ExecuteDirect(ASql);
end;

function TRecorderSqlDbRepository.TableExists(const AName: string): Boolean;
var
  lNames: TStringList;
  I: Integer;
begin
  Result := False;
  lNames := TStringList.Create;
  try
    fConnection.GetTableNames(lNames, False);
    for I := 0 to lNames.Count - 1 do
      if SameText(lNames[I], AName) then Exit(True);
  finally
    lNames.Free;
  end;
end;

function TRecorderSqlDbRepository.IndexExists(const AName: string): Boolean;
var
  lQuery: TSQLQuery;
  lSql: string;
begin
  Result := False;
  if Trim(AName) = '' then Exit;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    case fConfig.Backend of
      rsbFirebird:
        lSql :=
          'select 1 from rdb$indices where upper(trim(rdb$index_name))=:name';
      rsbSQLite:
        lSql :=
          'select 1 from sqlite_master where type=''index'' and upper(name)=:name';
      rsbPostgreSQL:
        lSql :=
          'select 1 from pg_indexes where upper(indexname)=:name';
    else
      Exit;
    end;
    lQuery.SQL.Text := lSql;
    lQuery.Params.ParamByName('name').AsString := UpperCase(AName);
    lQuery.Open;
    Result := not lQuery.EOF;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.ColumnExists(const ATableName,
  AColumnName: string): Boolean;
var
  lNames: TStringList;
  I: Integer;
begin
  Result := False;
  lNames := TStringList.Create;
  try
    fConnection.GetFieldNames(ATableName, lNames);
    for I := 0 to lNames.Count - 1 do
      if SameText(lNames[I], AColumnName) then Exit(True);
  finally
    lNames.Free;
  end;
end;

procedure TRecorderSqlDbRepository.CreateTableIfMissing(const AName, ASql: string);
begin
  if not TableExists(AName) then Exec(ASql);
end;

procedure TRecorderSqlDbRepository.CreateIndexIfMissing(const AName, ASql: string);
begin
  if not IndexExists(AName) then Exec(ASql);
end;

procedure TRecorderSqlDbRepository.AddColumnIfMissing(const ATableName,
  AColumnName, ASql: string);
begin
  if not ColumnExists(ATableName, AColumnName) then Exec(ASql);
end;

procedure TRecorderSqlDbRepository.MigrateSchema(AVersion: Integer);
var
  lQuery: TSQLQuery;
begin
  if AVersion < 2 then
  begin
    AddColumnIfMissing('signals', 'recorder_source_id',
      'alter table signals add recorder_source_id varchar(255)');
    AddColumnIfMissing('signals', 'recorder_address',
      'alter table signals add recorder_address varchar(255)');
    CommitAndRestart;
    lQuery := TSQLQuery.Create(nil);
    try
      lQuery.DataBase := fConnection;
      lQuery.Transaction := fTransaction;
      lQuery.SQL.Text := 'insert into schema_info(version, applied_at, description) ' +
        'values(:version,:applied_at,:description)';
      lQuery.Params.ParamByName('version').AsInteger := 2;
      lQuery.Params.ParamByName('applied_at').AsFloat := Now;
      lQuery.Params.ParamByName('description').AsString :=
        'RecorderLnx SQLdb channel recorder address columns';
      lQuery.ExecSQL;
    finally
      lQuery.Free;
    end;
  end;
  if AVersion < 3 then
  begin
    CreateIndexIfMissing('idx_signals_name',
      'create index idx_signals_name on signals(name)');
    CreateIndexIfMissing('idx_signal_values_signal',
      'create index idx_signal_values_signal on signal_values(signal_id)');
    CreateIndexIfMissing('idx_signal_values_signal_time',
      'create index idx_signal_values_signal_time on signal_values(signal_id,timestamp_utc)');
    CommitAndRestart;
    lQuery := TSQLQuery.Create(nil);
    try
      lQuery.DataBase := fConnection;
      lQuery.Transaction := fTransaction;
      lQuery.SQL.Text := 'insert into schema_info(version, applied_at, description) ' +
        'values(:version,:applied_at,:description)';
      lQuery.Params.ParamByName('version').AsInteger := 3;
      lQuery.Params.ParamByName('applied_at').AsFloat := Now;
      lQuery.Params.ParamByName('description').AsString :=
        'RecorderLnx SQLdb maintenance indexes';
      lQuery.ExecSQL;
    finally
      lQuery.Free;
    end;
  end;
  if AVersion < 4 then
  begin
    CreateIndexIfMissing('idx_events_type_time',
      'create index idx_events_type_time on events(event_type,timestamp_utc)');
    CreateIndexIfMissing('idx_data_file_links_anchor',
      'create index idx_data_file_links_anchor on data_file_links(anchor_time_utc)');
    CreateIndexIfMissing('idx_mera_recordings_time',
      'create index idx_mera_recordings_time on mera_recordings(started_at_utc,finished_at_utc,state)');
    CreateIndexIfMissing('idx_data_file_locations_state',
      'create index idx_data_file_locations_state on data_file_locations(file_id,state)');
    CommitAndRestart;
    lQuery := TSQLQuery.Create(nil);
    try
      lQuery.DataBase := fConnection;
      lQuery.Transaction := fTransaction;
      lQuery.SQL.Text := 'insert into schema_info(version, applied_at, description) ' +
        'values(:version,:applied_at,:description)';
      lQuery.Params.ParamByName('version').AsInteger := 4;
      lQuery.Params.ParamByName('applied_at').AsFloat := Now;
      lQuery.Params.ParamByName('description').AsString :=
        'RecorderLnx MERA recording events and file locations';
      lQuery.ExecSQL;
    finally
      lQuery.Free;
    end;
  end;
  if AVersion < 5 then
  begin
    AddColumnIfMissing('events', 'display_name',
      'alter table events add display_name varchar(255)');
    AddColumnIfMissing('events', 'description',
      'alter table events add description varchar(2048)');
    { Firebird publishes ALTER TABLE metadata only after the DDL transaction
      is committed.  The backfill query below must be prepared in a fresh
      transaction, otherwise it fails with -206 Column unknown DISPLAY_NAME. }
    CommitAndRestart;
    lQuery := TSQLQuery.Create(nil);
    try
      lQuery.DataBase := fConnection;
      lQuery.Transaction := fTransaction;
      lQuery.SQL.Text :=
        'update events set display_name=coalesce((select max(r.display_name) ' +
        'from mera_recordings r where r.event_id=events.id),event_text,''''),' +
        'description=coalesce(event_text,'''') where event_type=''mera.recording''';
      lQuery.ExecSQL;
      lQuery.SQL.Text := 'insert into schema_info(version, applied_at, description) ' +
        'values(:version,:applied_at,:description)';
      lQuery.Params.ParamByName('version').AsInteger := 5;
      lQuery.Params.ParamByName('applied_at').AsFloat := Now;
      lQuery.Params.ParamByName('description').AsString :=
        'Editable MERA event display name and description';
      lQuery.ExecSQL;
      CommitAndRestart;
    finally
      lQuery.Free;
    end;
  end;
end;

procedure TRecorderSqlDbRepository.EnsureDatabase;
var
  lQuery: TSQLQuery;
  lVersion: Integer;
begin
  if fDatabaseEnsured and (fConnection <> nil) and fConnection.Connected then
    Exit;
  Open;
  CreateTableIfMissing('schema_info',
    'create table schema_info (version integer not null, applied_at double precision not null, description varchar(255))');
  CreateTableIfMissing('objects',
    'create table objects (id varchar(36) primary key, parent_id varchar(36), name varchar(255) not null, object_type varchar(100), serial_number varchar(100), created_at double precision not null, updated_at double precision not null)');
  CreateTableIfMissing('property_definitions',
    'create table property_definitions (id varchar(36) primary key, name varchar(255) not null unique, value_type varchar(40) not null, unit_name varchar(64), constraints_json varchar(8191))');
  CreateTableIfMissing('object_property_values',
    'create table object_property_values (id varchar(36) primary key, object_id varchar(36) not null, property_id varchar(36) not null, value_text varchar(8191), valid_from double precision, valid_to double precision)');
  CreateTableIfMissing('signals',
    'create table signals (id varchar(36) primary key, object_id varchar(36) not null, parent_id varchar(36), name varchar(255) not null, value_type varchar(40) not null, unit_name varchar(64), enabled smallint not null, recorder_source_id varchar(255), recorder_address varchar(255))');
  CreateTableIfMissing('signal_bindings',
    'create table signal_bindings (id varchar(36) primary key, signal_id varchar(36) not null, recorder_tag varchar(255), source_kind varchar(40), transform_json varchar(8191))');
  CreateTableIfMissing('tests',
    'create table tests (id varchar(36) primary key, object_id varchar(36) not null, name varchar(255), started_at double precision, finished_at double precision, metadata_json varchar(8191))');
  CreateTableIfMissing('registrations',
    'create table registrations (id varchar(36) primary key, object_id varchar(36) not null, test_id varchar(36), started_at double precision not null, finished_at double precision, status varchar(32) not null, reason varchar(255))');
  CreateTableIfMissing('recording_policies',
    'create table recording_policies (id varchar(36) primary key, object_id varchar(36), signal_id varchar(36), mode_name varchar(40), period_ms integer, aggregation varchar(40), condition_json varchar(8191))');
  CreateTableIfMissing('signal_values',
    'create table signal_values (id varchar(36) primary key, registration_id varchar(36) not null, signal_id varchar(36) not null, timestamp_utc double precision not null, measured_value double precision, quality integer not null, sequence_no bigint not null)');
  CreateTableIfMissing('events',
    'create table events (id varchar(36) primary key, registration_id varchar(36), object_id varchar(36), signal_id varchar(36), timestamp_utc double precision not null, event_type varchar(80) not null, severity varchar(32), measured_value double precision, event_text varchar(2048), payload_json varchar(8191), display_name varchar(255), description varchar(2048))');
  CreateTableIfMissing('data_files',
    'create table data_files (id varchar(36) primary key, storage_key varchar(500) not null unique, data_type varchar(80), data_format varchar(80), file_size bigint not null, checksum varchar(128), file_state varchar(32) not null, created_at double precision not null)');
  CreateTableIfMissing('data_file_links',
    'create table data_file_links (id varchar(36) primary key, file_id varchar(36) not null, registration_id varchar(36), signal_id varchar(36), event_id varchar(36), anchor_time_utc double precision, time_from_utc double precision, time_to_utc double precision)');
  CreateTableIfMissing('recorder_instances',
    'create table recorder_instances (id varchar(36) primary key, instance_key varchar(100) not null unique, host_name varchar(255), display_name varchar(255), platform varchar(80), last_seen_at_utc double precision not null)');
  CreateTableIfMissing('system_settings',
    'create table system_settings (setting_key varchar(255) primary key, value_text varchar(8191), value_type varchar(40) not null, updated_at_utc double precision not null, updated_by_instance_id varchar(36))');
  CreateTableIfMissing('mera_recordings',
    'create table mera_recordings (id varchar(36) primary key, event_id varchar(36) not null, recorder_instance_id varchar(36) not null, registration_id varchar(36), correlation_id varchar(36), display_name varchar(255), started_at_utc double precision not null, finished_at_utc double precision, state varchar(32) not null, entry_file_id varchar(36), project_name varchar(255), error_text varchar(2048))');
  CreateTableIfMissing('mera_recording_files',
    'create table mera_recording_files (recording_id varchar(36) not null, file_id varchar(36) not null, file_role varchar(40) not null, relative_name varchar(500) not null, ordinal integer not null, primary key(recording_id,file_id))');
  CreateTableIfMissing('data_file_locations',
    'create table data_file_locations (id varchar(36) primary key, file_id varchar(36) not null, recorder_instance_id varchar(36), location_kind varchar(40) not null, path_key varchar(1024) not null, state varchar(32) not null, created_at_utc double precision not null, verified_at_utc double precision, error_text varchar(2048))');
  CreateIndexIfMissing('idx_signals_name',
    'create index idx_signals_name on signals(name)');
  CreateIndexIfMissing('idx_signal_values_signal',
    'create index idx_signal_values_signal on signal_values(signal_id)');
  CreateIndexIfMissing('idx_signal_values_signal_time',
    'create index idx_signal_values_signal_time on signal_values(signal_id,timestamp_utc)');
  CreateIndexIfMissing('idx_events_type_time',
    'create index idx_events_type_time on events(event_type,timestamp_utc)');
  CreateIndexIfMissing('idx_data_file_links_anchor',
    'create index idx_data_file_links_anchor on data_file_links(anchor_time_utc)');
  CreateIndexIfMissing('idx_mera_recordings_time',
    'create index idx_mera_recordings_time on mera_recordings(started_at_utc,finished_at_utc,state)');
  CreateIndexIfMissing('idx_data_file_locations_state',
    'create index idx_data_file_locations_state on data_file_locations(file_id,state)');
  { Firebird publishes newly created metadata at a transaction boundary.
    Preparing a query for SCHEMA_INFO in the DDL transaction can otherwise
    fail with SQL error -204 / table unknown on a newly created database. }
  CommitAndRestart;
  if ScalarInt('select count(*) from schema_info') = 0 then
  begin
    lQuery := TSQLQuery.Create(nil);
    try
      lQuery.DataBase := fConnection;
      lQuery.Transaction := fTransaction;
      lQuery.SQL.Text := 'insert into schema_info(version, applied_at, description) ' +
        'values(:version,:applied_at,:description)';
      lQuery.Params.ParamByName('version').AsInteger := CRecorderSqlDbSchemaVersion;
      lQuery.Params.ParamByName('applied_at').AsFloat := Now;
      lQuery.Params.ParamByName('description').AsString :=
        'initial RecorderLnx SQLdb schema';
      lQuery.ExecSQL;
    finally
      lQuery.Free;
    end;
  end;
  lVersion := SchemaVersion;
  if lVersion > CRecorderSqlDbSchemaVersion then
    raise ERecorderSqlDbError.CreateFmt('Database schema %d is newer than supported %d',
      [lVersion, CRecorderSqlDbSchemaVersion]);
  { The version row alone is not a structural guarantee.  A legacy database
    can have an empty/restored schema_info or a partially completed DDL
    migration.  Repair the columns idempotently before any v5 query. }
  AddColumnIfMissing('events', 'display_name',
    'alter table events add display_name varchar(255)');
  AddColumnIfMissing('events', 'description',
    'alter table events add description varchar(2048)');
  CommitAndRestart;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'update events set display_name=coalesce(display_name,(select ' +
      'max(r.display_name) from mera_recordings r where r.event_id=events.id),' +
      'event_text,''''),description=coalesce(description,event_text,'''') ' +
      'where event_type=''mera.recording'' and ' +
      '(display_name is null or description is null)';
    lQuery.ExecSQL;
    CommitAndRestart;
  finally
    lQuery.Free;
  end;
  MigrateSchema(lVersion);
  Commit;
  fDatabaseEnsured := True;
end;

function TRecorderSqlDbRepository.ScalarInt(const ASql: string): Int64;
var
  lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := ASql;
    lQuery.Open;
    Result := lQuery.Fields[0].AsLargeInt;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.SchemaVersion: Integer;
begin
  if not TableExists('schema_info') then Exit(0);
  Result := ScalarInt('select max(version) from schema_info');
end;

function TRecorderSqlDbRepository.HealthCheck: Boolean;
begin
  try
    EnsureDatabase;
    Result := ScalarInt('select 1 from schema_info') = 1;
  except
    Result := False;
  end;
end;

function TRecorderSqlDbRepository.FindId(const ASql, AParamName,
  AParamValue: string): string;
var
  lQuery: TSQLQuery;
begin
  Result := '';
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := ASql;
    lQuery.Params.ParamByName(AParamName).AsString := AParamValue;
    lQuery.Open;
    if not lQuery.EOF then Result := lQuery.Fields[0].AsString;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.EnsureObject(const AName, AObjectType,
  ASerialNumber: string): string;
var
  lQuery: TSQLQuery;
begin
  Result := FindId('select id from objects where name=:name', 'name', AName);
  if Result <> '' then Exit;
  Result := RecorderSqlDbNewId;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'insert into objects(id,name,object_type,serial_number,created_at,updated_at) values(:id,:name,:type,:sn,:created,:updated)';
    lQuery.Params.ParamByName('id').AsString := Result;
    lQuery.Params.ParamByName('name').AsString := AName;
    lQuery.Params.ParamByName('type').AsString := AObjectType;
    lQuery.Params.ParamByName('sn').AsString := ASerialNumber;
    lQuery.Params.ParamByName('created').AsFloat := Now;
    lQuery.Params.ParamByName('updated').AsFloat := Now;
    lQuery.ExecSQL; Commit;
  finally lQuery.Free; end;
end;

procedure TRecorderSqlDbRepository.SetObjectProperty(const AObjectId, AName,
  AValueType, AValueText: string);
var
  lDefId, lId: string;
  lQuery: TSQLQuery;
begin
  lDefId := FindId('select id from property_definitions where name=:name', 'name', AName);
  if lDefId = '' then
  begin
    lDefId := RecorderSqlDbNewId;
    lQuery := TSQLQuery.Create(nil);
    try
      lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
      lQuery.SQL.Text := 'insert into property_definitions(id,name,value_type) values(:id,:name,:type)';
      lQuery.Params.ParamByName('id').AsString := lDefId;
      lQuery.Params.ParamByName('name').AsString := AName;
      lQuery.Params.ParamByName('type').AsString := AValueType;
      lQuery.ExecSQL;
    finally lQuery.Free; end;
  end;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'select id from object_property_values where object_id=:object_id and property_id=:property_id and valid_to is null';
    lQuery.Params.ParamByName('object_id').AsString := AObjectId;
    lQuery.Params.ParamByName('property_id').AsString := lDefId;
    lQuery.Open;
    if not lQuery.EOF then lId := lQuery.Fields[0].AsString else lId := '';
    lQuery.Close;
    if lId = '' then
    begin
      lId := RecorderSqlDbNewId;
      lQuery.SQL.Text := 'insert into object_property_values(id,object_id,property_id,value_text,valid_from) values(:id,:object_id,:property_id,:value_text,:valid_from)';
      lQuery.Params.ParamByName('id').AsString := lId;
      lQuery.Params.ParamByName('object_id').AsString := AObjectId;
      lQuery.Params.ParamByName('property_id').AsString := lDefId;
      lQuery.Params.ParamByName('value_text').AsString := AValueText;
      lQuery.Params.ParamByName('valid_from').AsFloat := Now;
    end
    else
    begin
      lQuery.SQL.Text := 'update object_property_values set value_text=:value_text where id=:id';
      lQuery.Params.ParamByName('value_text').AsString := AValueText;
      lQuery.Params.ParamByName('id').AsString := lId;
    end;
    lQuery.ExecSQL; Commit;
  finally lQuery.Free; end;
end;

function TRecorderSqlDbRepository.EnsureSignal(const AObjectId, AName,
  AValueType, AUnit, ARecorderTag: string; const ARecorderSourceId: string;
  const ARecorderAddress: string): string;
var
  lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    if Trim(ARecorderAddress) <> '' then
    begin
      lQuery.SQL.Text :=
        'select id from signals where object_id=:object_id ' +
        'and recorder_source_id=:recorder_source_id ' +
        'and recorder_address=:recorder_address';
      lQuery.Params.ParamByName('object_id').AsString := AObjectId;
      lQuery.Params.ParamByName('recorder_source_id').AsString :=
        ARecorderSourceId;
      lQuery.Params.ParamByName('recorder_address').AsString :=
        ARecorderAddress;
      lQuery.Open;
      if not lQuery.EOF then
      begin
        Result := lQuery.Fields[0].AsString;
        lQuery.Close;
        lQuery.SQL.Text :=
          'update signals set name=:name,value_type=:value_type,' +
          'unit_name=:unit_name where id=:id';
        lQuery.Params.ParamByName('name').AsString := AName;
        lQuery.Params.ParamByName('value_type').AsString := AValueType;
        lQuery.Params.ParamByName('unit_name').AsString := AUnit;
        lQuery.Params.ParamByName('id').AsString := Result;
        lQuery.ExecSQL;
        lQuery.SQL.Text :=
          'update signal_bindings set recorder_tag=:tag where signal_id=:signal_id';
        lQuery.Params.ParamByName('tag').AsString := ARecorderTag;
        lQuery.Params.ParamByName('signal_id').AsString := Result;
        lQuery.ExecSQL;
        Commit;
        Exit;
      end;
      lQuery.Close;
    end;
    lQuery.SQL.Text := 'select id from signals where object_id=:object_id and name=:name';
    lQuery.Params.ParamByName('object_id').AsString := AObjectId;
    lQuery.Params.ParamByName('name').AsString := AName;
    lQuery.Open;
    if not lQuery.EOF then
    begin
      Result := lQuery.Fields[0].AsString;
      lQuery.Close;
      lQuery.SQL.Text :=
        'update signals set value_type=:value_type,unit_name=:unit_name,' +
        'recorder_source_id=:recorder_source_id,' +
        'recorder_address=:recorder_address where id=:id';
      lQuery.Params.ParamByName('value_type').AsString := AValueType;
      lQuery.Params.ParamByName('unit_name').AsString := AUnit;
      lQuery.Params.ParamByName('recorder_source_id').AsString :=
        ARecorderSourceId;
      lQuery.Params.ParamByName('recorder_address').AsString :=
        ARecorderAddress;
      lQuery.Params.ParamByName('id').AsString := Result;
      lQuery.ExecSQL;
      lQuery.SQL.Text :=
        'update signal_bindings set recorder_tag=:tag where signal_id=:signal_id';
      lQuery.Params.ParamByName('tag').AsString := ARecorderTag;
      lQuery.Params.ParamByName('signal_id').AsString := Result;
      lQuery.ExecSQL;
      Commit;
      Exit;
    end;
    lQuery.Close;
    Result := RecorderSqlDbNewId;
    lQuery.SQL.Text := 'insert into signals(id,object_id,name,value_type,unit_name,enabled,recorder_source_id,recorder_address) values(:id,:object_id,:name,:value_type,:unit_name,1,:recorder_source_id,:recorder_address)';
    lQuery.Params.ParamByName('id').AsString := Result;
    lQuery.Params.ParamByName('object_id').AsString := AObjectId;
    lQuery.Params.ParamByName('name').AsString := AName;
    lQuery.Params.ParamByName('value_type').AsString := AValueType;
    lQuery.Params.ParamByName('unit_name').AsString := AUnit;
    lQuery.Params.ParamByName('recorder_source_id').AsString :=
      ARecorderSourceId;
    lQuery.Params.ParamByName('recorder_address').AsString :=
      ARecorderAddress;
    lQuery.ExecSQL;
    lQuery.SQL.Text := 'insert into signal_bindings(id,signal_id,recorder_tag,source_kind) values(:id,:signal_id,:tag,''recorder-tag'')';
    lQuery.Params.ParamByName('id').AsString := RecorderSqlDbNewId;
    lQuery.Params.ParamByName('signal_id').AsString := Result;
    lQuery.Params.ParamByName('tag').AsString := ARecorderTag;
    lQuery.ExecSQL; Commit;
  finally lQuery.Free; end;
end;

function TRecorderSqlDbRepository.RenameSignalByRecorderAddress(
  const AObjectId, ARecorderSourceId, ARecorderAddress, ANewName,
  AUnit: string): Boolean;
var
  lQuery: TSQLQuery;
  lSignalId: string;
begin
  Result := False;
  if (Trim(AObjectId) = '') or (Trim(ARecorderAddress) = '') or
    (Trim(ANewName) = '') then Exit;
  lSignalId := '';
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select id from signals where object_id=:object_id ' +
      'and recorder_source_id=:recorder_source_id ' +
      'and recorder_address=:recorder_address';
    lQuery.Params.ParamByName('object_id').AsString := AObjectId;
    lQuery.Params.ParamByName('recorder_source_id').AsString :=
      ARecorderSourceId;
    lQuery.Params.ParamByName('recorder_address').AsString := ARecorderAddress;
    lQuery.Open;
    if not lQuery.EOF then
      lSignalId := lQuery.Fields[0].AsString;
    lQuery.Close;
    if lSignalId = '' then
    begin
      lQuery.SQL.Text :=
        'select id from signals where object_id=:object_id and name=:name';
      lQuery.Params.ParamByName('object_id').AsString := AObjectId;
      lQuery.Params.ParamByName('name').AsString := ANewName;
      lQuery.Open;
      if not lQuery.EOF then
        lSignalId := lQuery.Fields[0].AsString;
      lQuery.Close;
    end;
    if lSignalId = '' then Exit;
    lQuery.SQL.Text :=
      'update signals set name=:name,unit_name=:unit_name,' +
      'recorder_source_id=:recorder_source_id,' +
      'recorder_address=:recorder_address where id=:id';
    lQuery.Params.ParamByName('name').AsString := ANewName;
    lQuery.Params.ParamByName('unit_name').AsString := AUnit;
    lQuery.Params.ParamByName('recorder_source_id').AsString :=
      ARecorderSourceId;
    lQuery.Params.ParamByName('recorder_address').AsString := ARecorderAddress;
    lQuery.Params.ParamByName('id').AsString := lSignalId;
    lQuery.ExecSQL;
    lQuery.SQL.Text :=
      'update signal_bindings set recorder_tag=:tag where signal_id=:signal_id';
    lQuery.Params.ParamByName('tag').AsString := ANewName;
    lQuery.Params.ParamByName('signal_id').AsString := lSignalId;
    lQuery.ExecSQL;
    Commit;
    Result := True;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.BeginRegistration(const AObjectId, ATestId,
  AReason: string; AStartedUtc: Double): string;
var lQuery: TSQLQuery;
begin
  Result := RecorderSqlDbNewId;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'insert into registrations(id,object_id,test_id,started_at,status,reason) values(:id,:object_id,:test_id,:started_at,''open'',:reason)';
    lQuery.Params.ParamByName('id').AsString := Result;
    lQuery.Params.ParamByName('object_id').AsString := AObjectId;
    if ATestId = '' then lQuery.Params.ParamByName('test_id').Clear else lQuery.Params.ParamByName('test_id').AsString := ATestId;
    lQuery.Params.ParamByName('started_at').AsFloat := AStartedUtc;
    lQuery.Params.ParamByName('reason').AsString := AReason;
    lQuery.ExecSQL; Commit;
  finally lQuery.Free; end;
end;

procedure TRecorderSqlDbRepository.FinishRegistration(const ARegistrationId,
  AStatus: string; AFinishedUtc: Double);
var lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'update registrations set finished_at=:finished_at,status=:status where id=:id';
    lQuery.Params.ParamByName('finished_at').AsFloat := AFinishedUtc;
    lQuery.Params.ParamByName('status').AsString := AStatus;
    lQuery.Params.ParamByName('id').AsString := ARegistrationId;
    lQuery.ExecSQL; Commit;
  finally lQuery.Free; end;
end;

procedure TRecorderSqlDbRepository.InsertSignalValue(const ARegistrationId,
  ASignalId: string; ATimestampUtc, AValue: Double; AQuality: Integer;
  ASequenceNo: Int64);
var lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'insert into signal_values(id,registration_id,signal_id,timestamp_utc,measured_value,quality,sequence_no) values(:id,:registration_id,:signal_id,:timestamp_utc,:measured_value,:quality,:sequence_no)';
    lQuery.Params.ParamByName('id').AsString := RecorderSqlDbNewId;
    lQuery.Params.ParamByName('registration_id').AsString := ARegistrationId;
    lQuery.Params.ParamByName('signal_id').AsString := ASignalId;
    lQuery.Params.ParamByName('timestamp_utc').AsFloat := ATimestampUtc;
    lQuery.Params.ParamByName('measured_value').AsFloat := AValue;
    lQuery.Params.ParamByName('quality').AsInteger := AQuality;
    lQuery.Params.ParamByName('sequence_no').AsLargeInt := ASequenceNo;
    lQuery.ExecSQL; Commit;
  finally lQuery.Free; end;
end;

procedure TRecorderSqlDbRepository.InsertEvent(const ARegistrationId,
  AObjectId, ASignalId: string; ATimestampUtc: Double; const AEventType,
  ASeverity, AText: string; AValue: Double; const APayloadJson: string);
var lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'insert into events(id,registration_id,object_id,signal_id,timestamp_utc,event_type,severity,measured_value,event_text,payload_json) values(:id,:registration_id,:object_id,:signal_id,:timestamp_utc,:event_type,:severity,:measured_value,:event_text,:payload_json)';
    lQuery.Params.ParamByName('id').AsString := RecorderSqlDbNewId;
    if ARegistrationId = '' then lQuery.Params.ParamByName('registration_id').Clear else lQuery.Params.ParamByName('registration_id').AsString := ARegistrationId;
    if AObjectId = '' then lQuery.Params.ParamByName('object_id').Clear else lQuery.Params.ParamByName('object_id').AsString := AObjectId;
    if ASignalId = '' then lQuery.Params.ParamByName('signal_id').Clear else lQuery.Params.ParamByName('signal_id').AsString := ASignalId;
    lQuery.Params.ParamByName('timestamp_utc').AsFloat := ATimestampUtc;
    lQuery.Params.ParamByName('event_type').AsString := AEventType;
    lQuery.Params.ParamByName('severity').AsString := ASeverity;
    lQuery.Params.ParamByName('measured_value').AsFloat := AValue;
    lQuery.Params.ParamByName('event_text').AsString := AText;
    lQuery.Params.ParamByName('payload_json').AsString := APayloadJson;
    lQuery.ExecSQL; Commit;
  finally lQuery.Free; end;
end;

procedure TRecorderSqlDbRepository.InsertDataFile(const AId, AStorageKey,
  ADataType, AFormat: string; ASize: Int64; const AChecksum, AState,
  ARegistrationId, ASignalId, AEventId: string; AAnchorUtc, AFromUtc,
  AToUtc: Double);
var lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'insert into data_files(id,storage_key,data_type,data_format,file_size,checksum,file_state,created_at) values(:id,:storage_key,:data_type,:data_format,:file_size,:checksum,:file_state,:created_at)';
    lQuery.Params.ParamByName('id').AsString := AId;
    lQuery.Params.ParamByName('storage_key').AsString := AStorageKey;
    lQuery.Params.ParamByName('data_type').AsString := ADataType;
    lQuery.Params.ParamByName('data_format').AsString := AFormat;
    lQuery.Params.ParamByName('file_size').AsLargeInt := ASize;
    lQuery.Params.ParamByName('checksum').AsString := AChecksum;
    lQuery.Params.ParamByName('file_state').AsString := AState;
    lQuery.Params.ParamByName('created_at').AsFloat := Now;
    lQuery.ExecSQL;
    lQuery.SQL.Text := 'insert into data_file_links(id,file_id,registration_id,signal_id,event_id,anchor_time_utc,time_from_utc,time_to_utc) values(:id,:file_id,:registration_id,:signal_id,:event_id,:anchor_time_utc,:time_from_utc,:time_to_utc)';
    lQuery.Params.ParamByName('id').AsString := RecorderSqlDbNewId;
    lQuery.Params.ParamByName('file_id').AsString := AId;
    if ARegistrationId = '' then lQuery.Params.ParamByName('registration_id').Clear else lQuery.Params.ParamByName('registration_id').AsString := ARegistrationId;
    if ASignalId = '' then lQuery.Params.ParamByName('signal_id').Clear else lQuery.Params.ParamByName('signal_id').AsString := ASignalId;
    if AEventId = '' then lQuery.Params.ParamByName('event_id').Clear else lQuery.Params.ParamByName('event_id').AsString := AEventId;
    lQuery.Params.ParamByName('anchor_time_utc').AsFloat := AAnchorUtc;
    lQuery.Params.ParamByName('time_from_utc').AsFloat := AFromUtc;
    lQuery.Params.ParamByName('time_to_utc').AsFloat := AToUtc;
    lQuery.ExecSQL; Commit;
  finally lQuery.Free; end;
end;

function TRecorderSqlDbRepository.UpsertRecorderInstance(const AInstanceKey,
  AHostName, ADisplayName, APlatform: string; ALastSeenAtUtc: Double): string;
var
  lQuery: TSQLQuery;
begin
  EnsureDatabase;
  Result := FindId('select id from recorder_instances where instance_key=:key',
    'key', AInstanceKey);
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    if Result = '' then
    begin
      Result := RecorderSqlDbNewId;
      lQuery.SQL.Text :=
        'insert into recorder_instances(id,instance_key,host_name,display_name,' +
        'platform,last_seen_at_utc) values(:id,:key,:host,:display,:platform,:seen)';
      lQuery.ParamByName('id').AsString := Result;
      lQuery.ParamByName('key').AsString := AInstanceKey;
    end
    else
    begin
      lQuery.SQL.Text :=
        'update recorder_instances set host_name=:host,display_name=:display,' +
        'platform=:platform,last_seen_at_utc=:seen where id=:id';
      lQuery.ParamByName('id').AsString := Result;
    end;
    lQuery.ParamByName('host').AsString := AHostName;
    lQuery.ParamByName('display').AsString := ADisplayName;
    lQuery.ParamByName('platform').AsString := APlatform;
    lQuery.ParamByName('seen').AsFloat := ALastSeenAtUtc;
    lQuery.ExecSQL;
    Commit;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.SetSystemSetting(const AKey, AValue,
  AValueType, AUpdatedByInstanceId: string; AUpdatedAtUtc: Double);
var
  lExists: Boolean;
  lQuery: TSQLQuery;
begin
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'select setting_key from system_settings where setting_key=:key';
    lQuery.ParamByName('key').AsString := AKey;
    lQuery.Open;
    lExists := not lQuery.EOF;
    lQuery.Close;
    if not lExists then
      lQuery.SQL.Text :=
        'insert into system_settings(setting_key,value_text,value_type,' +
        'updated_at_utc,updated_by_instance_id) values(:key,:value,:type,:updated,:instance)'
    else
      lQuery.SQL.Text :=
        'update system_settings set value_text=:value,value_type=:type,' +
        'updated_at_utc=:updated,updated_by_instance_id=:instance where setting_key=:key';
    lQuery.ParamByName('key').AsString := AKey;
    lQuery.ParamByName('value').AsString := AValue;
    lQuery.ParamByName('type').AsString := AValueType;
    lQuery.ParamByName('updated').AsFloat := AUpdatedAtUtc;
    if AUpdatedByInstanceId = '' then
      lQuery.ParamByName('instance').Clear
    else
      lQuery.ParamByName('instance').AsString := AUpdatedByInstanceId;
    lQuery.ExecSQL;
    Commit;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.GetSystemSetting(const AKey: string;
  out AValue, AValueType: string): Boolean;
var
  lQuery: TSQLQuery;
begin
  AValue := '';
  AValueType := '';
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select value_text,value_type from system_settings where setting_key=:key';
    lQuery.ParamByName('key').AsString := AKey;
    lQuery.Open;
    Result := not lQuery.EOF;
    if Result then
    begin
      AValue := lQuery.Fields[0].AsString;
      AValueType := lQuery.Fields[1].AsString;
    end;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.BeginMeraRecording(
  const ARecording: TRecorderSqlDbMeraRecording): string;
var
  lExists: Boolean;
  lEventId: string;
  lQuery: TSQLQuery;
begin
  EnsureDatabase;
  Result := ARecording.Id;
  if Result = '' then Result := RecorderSqlDbNewId;
  lEventId := ARecording.EventId;
  if lEventId = '' then lEventId := RecorderSqlDbNewId;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'select id from events where id=:id';
    lQuery.ParamByName('id').AsString := lEventId;
    lQuery.Open;
    lExists := not lQuery.EOF;
    lQuery.Close;
    if not lExists then
    begin
      lQuery.SQL.Text :=
        'insert into events(id,registration_id,timestamp_utc,event_type,severity,' +
        'payload_json,display_name,description) values(:id,:registration,:time,' +
        '''mera.recording'',''info'',:payload,:display,:description)';
      lQuery.ParamByName('id').AsString := lEventId;
      if ARecording.RegistrationId = '' then lQuery.ParamByName('registration').Clear
      else lQuery.ParamByName('registration').AsString := ARecording.RegistrationId;
      lQuery.ParamByName('time').AsFloat := ARecording.StartedAtUtc;
      lQuery.ParamByName('payload').AsString := '{}';
      lQuery.ParamByName('display').AsString := ARecording.DisplayName;
      lQuery.ParamByName('description').AsString := '';
      lQuery.ExecSQL;
    end;

    lQuery.SQL.Text := 'select id from mera_recordings where id=:id';
    lQuery.ParamByName('id').AsString := Result;
    lQuery.Open;
    lExists := not lQuery.EOF;
    lQuery.Close;
    if not lExists then
      lQuery.SQL.Text :=
        'insert into mera_recordings(id,event_id,recorder_instance_id,' +
        'registration_id,correlation_id,display_name,started_at_utc,state,' +
        'project_name,error_text) values(:id,:event,:instance,:registration,' +
        ':correlation,:display,:started,:state,:project,:error)'
    else
      lQuery.SQL.Text :=
        'update mera_recordings set event_id=:event,recorder_instance_id=:instance,' +
        'registration_id=:registration,correlation_id=:correlation,' +
        'display_name=:display,started_at_utc=:started,state=:state,' +
        'project_name=:project,error_text=:error where id=:id';
    lQuery.ParamByName('id').AsString := Result;
    lQuery.ParamByName('event').AsString := lEventId;
    lQuery.ParamByName('instance').AsString := ARecording.RecorderInstanceId;
    if ARecording.RegistrationId = '' then lQuery.ParamByName('registration').Clear
    else lQuery.ParamByName('registration').AsString := ARecording.RegistrationId;
    if ARecording.CorrelationId = '' then lQuery.ParamByName('correlation').Clear
    else lQuery.ParamByName('correlation').AsString := ARecording.CorrelationId;
    lQuery.ParamByName('display').AsString := ARecording.DisplayName;
    lQuery.ParamByName('started').AsFloat := ARecording.StartedAtUtc;
    lQuery.ParamByName('state').AsString := ARecording.State;
    lQuery.ParamByName('project').AsString := ARecording.ProjectName;
    lQuery.ParamByName('error').AsString := ARecording.ErrorText;
    lQuery.ExecSQL;
    Commit;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.CompleteMeraRecording(const ARecordingId,
  AState, AEntryFileId, AErrorText: string; AFinishedAtUtc: Double);
var
  lQuery: TSQLQuery;
begin
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'update mera_recordings set finished_at_utc=:finished,state=:state,' +
      'entry_file_id=:entry,error_text=:error where id=:id';
    lQuery.ParamByName('finished').AsFloat := AFinishedAtUtc;
    lQuery.ParamByName('state').AsString := AState;
    if AEntryFileId = '' then lQuery.ParamByName('entry').Clear
    else lQuery.ParamByName('entry').AsString := AEntryFileId;
    lQuery.ParamByName('error').AsString := AErrorText;
    lQuery.ParamByName('id').AsString := ARecordingId;
    lQuery.ExecSQL;
    Commit;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.UpsertMeraFile(
  const AFile: TRecorderSqlDbMeraFile);
var
  lExists: Boolean;
  lQuery: TSQLQuery;
begin
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'select id from data_files where id=:id';
    lQuery.ParamByName('id').AsString := AFile.FileId;
    lQuery.Open;
    lExists := not lQuery.EOF;
    lQuery.Close;
    if not lExists then
      lQuery.SQL.Text :=
        'insert into data_files(id,storage_key,data_type,data_format,file_size,' +
        'checksum,file_state,created_at) values(:id,:key,''mera'',:format,' +
        ':size,:checksum,:state,:created)'
    else
      lQuery.SQL.Text :=
        'update data_files set storage_key=:key,data_format=:format,file_size=:size,' +
        'checksum=:checksum,file_state=:state where id=:id';
    lQuery.ParamByName('id').AsString := AFile.FileId;
    lQuery.ParamByName('key').AsString := AFile.StorageKey;
    lQuery.ParamByName('format').AsString := AFile.DataFormat;
    lQuery.ParamByName('size').AsLargeInt := AFile.Size;
    lQuery.ParamByName('checksum').AsString := AFile.Checksum;
    lQuery.ParamByName('state').AsString := AFile.State;
    if lQuery.Params.FindParam('created') <> nil then
      lQuery.ParamByName('created').AsFloat := Now;
    lQuery.ExecSQL;

    lQuery.SQL.Text :=
      'select file_id from mera_recording_files where recording_id=:recording ' +
      'and relative_name=:name';
    lQuery.ParamByName('recording').AsString := AFile.RecordingId;
    lQuery.ParamByName('name').AsString := AFile.RelativeName;
    lQuery.Open;
    lExists := not lQuery.EOF;
    lQuery.Close;
    if not lExists then
      lQuery.SQL.Text :=
        'insert into mera_recording_files(recording_id,file_id,file_role,' +
        'relative_name,ordinal) values(:recording,:file,:role,:name,:ordinal)'
    else
      lQuery.SQL.Text :=
        'update mera_recording_files set file_id=:file,file_role=:role,' +
        'ordinal=:ordinal where recording_id=:recording and relative_name=:name';
    lQuery.ParamByName('recording').AsString := AFile.RecordingId;
    lQuery.ParamByName('file').AsString := AFile.FileId;
    lQuery.ParamByName('role').AsString := AFile.FileRole;
    lQuery.ParamByName('name').AsString := AFile.RelativeName;
    lQuery.ParamByName('ordinal').AsInteger := AFile.Ordinal;
    lQuery.ExecSQL;
    Commit;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.UpsertDataFileLocation(
  const ALocation: TRecorderSqlDbFileLocation);
var
  lId: string;
  lQuery: TSQLQuery;
begin
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select id from data_file_locations where file_id=:file and ' +
      'location_kind=:kind and ((recorder_instance_id=:instance) or ' +
      '(recorder_instance_id is null and :instance is null))';
    lQuery.ParamByName('file').AsString := ALocation.FileId;
    lQuery.ParamByName('kind').AsString := ALocation.LocationKind;
    if ALocation.RecorderInstanceId = '' then lQuery.ParamByName('instance').Clear
    else lQuery.ParamByName('instance').AsString := ALocation.RecorderInstanceId;
    lQuery.Open;
    if lQuery.EOF then lId := '' else lId := lQuery.Fields[0].AsString;
    lQuery.Close;
    if lId = '' then
    begin
      lId := ALocation.Id;
      if lId = '' then lId := RecorderSqlDbNewId;
      lQuery.SQL.Text :=
        'insert into data_file_locations(id,file_id,recorder_instance_id,' +
        'location_kind,path_key,state,created_at_utc,verified_at_utc,error_text) ' +
        'values(:id,:file,:instance,:kind,:path,:state,:created,:verified,:error)';
    end
    else
      lQuery.SQL.Text :=
        'update data_file_locations set path_key=:path,state=:state,' +
        'verified_at_utc=:verified,error_text=:error where id=:id';
    lQuery.ParamByName('id').AsString := lId;
    if lQuery.Params.FindParam('file') <> nil then
      lQuery.ParamByName('file').AsString := ALocation.FileId;
    if lQuery.Params.FindParam('instance') <> nil then
      if ALocation.RecorderInstanceId = '' then lQuery.ParamByName('instance').Clear
      else lQuery.ParamByName('instance').AsString := ALocation.RecorderInstanceId;
    if lQuery.Params.FindParam('kind') <> nil then
      lQuery.ParamByName('kind').AsString := ALocation.LocationKind;
    lQuery.ParamByName('path').AsString := ALocation.PathKey;
    lQuery.ParamByName('state').AsString := ALocation.State;
    if lQuery.Params.FindParam('created') <> nil then
      lQuery.ParamByName('created').AsFloat := ALocation.CreatedAtUtc;
    if ALocation.VerifiedAtUtc = 0 then lQuery.ParamByName('verified').Clear
    else lQuery.ParamByName('verified').AsFloat := ALocation.VerifiedAtUtc;
    lQuery.ParamByName('error').AsString := ALocation.ErrorText;
    lQuery.ExecSQL;
    Commit;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.ListMeraRecordings(AFromUtc,
  AToUtc: Double; out AItems: TRecorderSqlDbMeraRecordings);
var
  I: Integer;
  lQuery: TSQLQuery;
begin
  SetLength(AItems, 0);
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select id,event_id,recorder_instance_id,registration_id,correlation_id,' +
      'display_name,started_at_utc,finished_at_utc,state,entry_file_id,' +
      'project_name,error_text from mera_recordings where started_at_utc<=:to ' +
      'and (finished_at_utc is null or finished_at_utc>=:from) order by started_at_utc';
    lQuery.ParamByName('from').AsFloat := AFromUtc;
    lQuery.ParamByName('to').AsFloat := AToUtc;
    lQuery.Open;
    while not lQuery.EOF do
    begin
      I := Length(AItems);
      SetLength(AItems, I + 1);
      AItems[I].Id := lQuery.Fields[0].AsString;
      AItems[I].EventId := lQuery.Fields[1].AsString;
      AItems[I].RecorderInstanceId := lQuery.Fields[2].AsString;
      AItems[I].RegistrationId := lQuery.Fields[3].AsString;
      AItems[I].CorrelationId := lQuery.Fields[4].AsString;
      AItems[I].DisplayName := lQuery.Fields[5].AsString;
      AItems[I].StartedAtUtc := lQuery.Fields[6].AsFloat;
      if not lQuery.Fields[7].IsNull then
        AItems[I].FinishedAtUtc := lQuery.Fields[7].AsFloat;
      AItems[I].State := lQuery.Fields[8].AsString;
      AItems[I].EntryFileId := lQuery.Fields[9].AsString;
      AItems[I].ProjectName := lQuery.Fields[10].AsString;
      AItems[I].ErrorText := lQuery.Fields[11].AsString;
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.GetCurrentMeraRecording(
  const ARecorderInstanceId: string;
  out AItem: TRecorderSqlDbMeraRecording): Boolean;
var
  lQuery: TSQLQuery;
begin
  FillChar(AItem, SizeOf(AItem), 0);
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select id,event_id,recorder_instance_id,registration_id,correlation_id,' +
      'display_name,started_at_utc,finished_at_utc,state,entry_file_id,' +
      'project_name,error_text from mera_recordings where recorder_instance_id=:id ' +
      'order by started_at_utc desc';
    lQuery.ParamByName('id').AsString := ARecorderInstanceId;
    lQuery.Open;
    Result := not lQuery.EOF;
    if not Result then Exit;
    AItem.Id := lQuery.Fields[0].AsString;
    AItem.EventId := lQuery.Fields[1].AsString;
    AItem.RecorderInstanceId := lQuery.Fields[2].AsString;
    AItem.RegistrationId := lQuery.Fields[3].AsString;
    AItem.CorrelationId := lQuery.Fields[4].AsString;
    AItem.DisplayName := lQuery.Fields[5].AsString;
    AItem.StartedAtUtc := lQuery.Fields[6].AsFloat;
    if not lQuery.Fields[7].IsNull then
      AItem.FinishedAtUtc := lQuery.Fields[7].AsFloat;
    AItem.State := lQuery.Fields[8].AsString;
    AItem.EntryFileId := lQuery.Fields[9].AsString;
    AItem.ProjectName := lQuery.Fields[10].AsString;
    AItem.ErrorText := lQuery.Fields[11].AsString;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.ListMeraFiles(const ARecordingId: string;
  out AItems: TRecorderSqlDbMeraFiles);
var
  I: Integer;
  lQuery: TSQLQuery;
begin
  SetLength(AItems, 0);
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select f.id,m.recording_id,m.file_role,m.relative_name,m.ordinal,' +
      'f.storage_key,f.data_format,f.file_size,f.checksum,f.file_state ' +
      'from mera_recording_files m join data_files f on f.id=m.file_id ' +
      'where m.recording_id=:id order by m.ordinal,m.relative_name';
    lQuery.ParamByName('id').AsString := ARecordingId;
    lQuery.Open;
    while not lQuery.EOF do
    begin
      I := Length(AItems);
      SetLength(AItems, I + 1);
      AItems[I].FileId := lQuery.Fields[0].AsString;
      AItems[I].RecordingId := lQuery.Fields[1].AsString;
      AItems[I].FileRole := lQuery.Fields[2].AsString;
      AItems[I].RelativeName := lQuery.Fields[3].AsString;
      AItems[I].Ordinal := lQuery.Fields[4].AsInteger;
      AItems[I].StorageKey := lQuery.Fields[5].AsString;
      AItems[I].DataFormat := lQuery.Fields[6].AsString;
      AItems[I].Size := lQuery.Fields[7].AsLargeInt;
      AItems[I].Checksum := lQuery.Fields[8].AsString;
      AItems[I].State := lQuery.Fields[9].AsString;
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.ListDataFileLocations(const AFileId: string;
  out AItems: TRecorderSqlDbFileLocations);
var
  I: Integer;
  lQuery: TSQLQuery;
begin
  SetLength(AItems, 0);
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select id,file_id,recorder_instance_id,location_kind,path_key,state,' +
      'created_at_utc,verified_at_utc,error_text from data_file_locations ' +
      'where file_id=:id order by location_kind,created_at_utc';
    lQuery.ParamByName('id').AsString := AFileId;
    lQuery.Open;
    while not lQuery.EOF do
    begin
      I := Length(AItems);
      SetLength(AItems, I + 1);
      AItems[I].Id := lQuery.Fields[0].AsString;
      AItems[I].FileId := lQuery.Fields[1].AsString;
      AItems[I].RecorderInstanceId := lQuery.Fields[2].AsString;
      AItems[I].LocationKind := lQuery.Fields[3].AsString;
      AItems[I].PathKey := lQuery.Fields[4].AsString;
      AItems[I].State := lQuery.Fields[5].AsString;
      AItems[I].CreatedAtUtc := lQuery.Fields[6].AsFloat;
      if not lQuery.Fields[7].IsNull then
        AItems[I].VerifiedAtUtc := lQuery.Fields[7].AsFloat;
      AItems[I].ErrorText := lQuery.Fields[8].AsString;
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.ListMeraRecordingEvents(AFromUtc,
  AToUtc: Double; out AItems: TRecorderSqlDbMeraEvents);
var
  I: Integer;
  lQuery: TSQLQuery;
begin
  SetLength(AItems, 0);
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select e.id,max(r.correlation_id),e.display_name,e.description,' +
      'e.timestamp_utc,max(r.finished_at_utc),max(r.state),' +
      'count(distinct r.id),cast(coalesce(sum(f.file_size),0) as bigint) ' +
      'from events e join mera_recordings r on r.event_id=e.id ' +
      'left join mera_recording_files m ' +
      'on m.recording_id=r.id left join data_files f on f.id=m.file_id ' +
      'where r.started_at_utc<=:to and (r.finished_at_utc is null or ' +
      'r.finished_at_utc>=:from) group by e.id,e.display_name,e.description,' +
      'e.timestamp_utc order by e.timestamp_utc';
    lQuery.ParamByName('from').AsFloat := AFromUtc;
    lQuery.ParamByName('to').AsFloat := AToUtc;
    lQuery.Open;
    while not lQuery.EOF do
    begin
      I := Length(AItems);
      SetLength(AItems, I + 1);
      AItems[I].EventId := lQuery.Fields[0].AsString;
      AItems[I].CorrelationId := lQuery.Fields[1].AsString;
      AItems[I].DisplayName := lQuery.Fields[2].AsString;
      AItems[I].Description := lQuery.Fields[3].AsString;
      AItems[I].StartedAtUtc := lQuery.Fields[4].AsFloat;
      if not lQuery.Fields[5].IsNull then
        AItems[I].FinishedAtUtc := lQuery.Fields[5].AsFloat;
      AItems[I].State := lQuery.Fields[6].AsString;
      AItems[I].PackageCount := lQuery.Fields[7].AsInteger;
      AItems[I].TotalSize := lQuery.Fields[8].AsLargeInt;
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.GetMeraEventSnapshot(const AEventId: string;
  out AEventUtc, AFirstStartedUtc, ALastFinishedUtc: Double;
  out ARecordingCount: Integer): Boolean;
var
  lQuery: TSQLQuery;
begin
  Result := False;
  AEventUtc := 0;
  AFirstStartedUtc := 0;
  ALastFinishedUtc := 0;
  ARecordingCount := 0;
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select e.timestamp_utc,min(r.started_at_utc),max(r.finished_at_utc),' +
      'count(r.id) from events e ' +
      'left join mera_recordings r on r.event_id=e.id ' +
      'where e.id=:id group by e.id,e.timestamp_utc';
    lQuery.ParamByName('id').AsString := AEventId;
    lQuery.Open;
    Result := not lQuery.EOF;
    if Result then
    begin
      AEventUtc := lQuery.Fields[0].AsFloat;
      if not lQuery.Fields[1].IsNull then
        AFirstStartedUtc := lQuery.Fields[1].AsFloat;
      if not lQuery.Fields[2].IsNull then
        ALastFinishedUtc := lQuery.Fields[2].AsFloat;
      ARecordingCount := lQuery.Fields[3].AsInteger;
    end;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.UpdateMeraEvent(const AEventId,
  ADisplayName, ADescription: string): Boolean;
var
  lQuery: TSQLQuery;
begin
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'update events set display_name=:display,description=:description ' +
      'where id=:id and event_type=''mera.recording''';
    lQuery.ParamByName('display').AsString := ADisplayName;
    lQuery.ParamByName('description').AsString := ADescription;
    lQuery.ParamByName('id').AsString := AEventId;
    lQuery.ExecSQL;
    Result := lQuery.RowsAffected > 0;
    Commit;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.UpdateDataFileLocationPath(const AEventId,
  ALocationId, APathKey: string): Boolean;
var
  lQuery: TSQLQuery;
begin
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'update data_file_locations set path_key=:path where id=:location ' +
      'and exists(select 1 from mera_recording_files m ' +
      'join mera_recordings r on r.id=m.recording_id ' +
      'where m.file_id=data_file_locations.file_id and r.event_id=:event)';
    lQuery.ParamByName('path').AsString := APathKey;
    lQuery.ParamByName('location').AsString := ALocationId;
    lQuery.ParamByName('event').AsString := AEventId;
    lQuery.ExecSQL;
    Result := lQuery.RowsAffected > 0;
    Commit;
  finally
    lQuery.Free;
  end;
end;

function TRecorderSqlDbRepository.DeleteMeraEvent(
  const AEventId: string): Boolean;
var
  lDeletedFiles, lDeletedPackages: Integer;
begin
  Result := DeleteMeraEvent(AEventId, lDeletedPackages, lDeletedFiles);
end;

function TRecorderSqlDbRepository.DeleteMeraEvent(const AEventId: string;
  out ADeletedPackages, ADeletedFiles: Integer): Boolean;
var
  lQuery: TSQLQuery;
begin
  ADeletedPackages := 0;
  ADeletedFiles := 0;
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    try
      lQuery.SQL.Text :=
        'select count(*) from mera_recordings where event_id=:event';
      lQuery.ParamByName('event').AsString := AEventId;
      lQuery.Open;
      ADeletedPackages := lQuery.Fields[0].AsInteger;
      lQuery.Close;
      lQuery.SQL.Text :=
        'select count(distinct m.file_id) from mera_recording_files m ' +
        'join mera_recordings r on r.id=m.recording_id ' +
        'where r.event_id=:event and not exists ' +
        '(select 1 from mera_recording_files m2 join mera_recordings r2 ' +
        'on r2.id=m2.recording_id where m2.file_id=m.file_id ' +
        'and r2.event_id<>:event) and not exists ' +
        '(select 1 from data_file_links l where l.file_id=m.file_id and ' +
        '(l.event_id is null or l.event_id<>:event))';
      lQuery.ParamByName('event').AsString := AEventId;
      lQuery.Open;
      ADeletedFiles := lQuery.Fields[0].AsInteger;
      lQuery.Close;
      lQuery.SQL.Text :=
        'delete from data_file_locations where file_id in ' +
        '(select m.file_id from mera_recording_files m join mera_recordings r ' +
        'on r.id=m.recording_id where r.event_id=:event) and not exists ' +
        '(select 1 from mera_recording_files m2 join mera_recordings r2 ' +
        'on r2.id=m2.recording_id where m2.file_id=data_file_locations.file_id ' +
        'and r2.event_id<>:event) and not exists ' +
        '(select 1 from data_file_links l where ' +
        'l.file_id=data_file_locations.file_id and ' +
        '(l.event_id is null or l.event_id<>:event))';
      lQuery.ParamByName('event').AsString := AEventId;
      lQuery.ExecSQL;
      lQuery.SQL.Text := 'delete from data_file_links where event_id=:event';
      lQuery.ParamByName('event').AsString := AEventId;
      lQuery.ExecSQL;
      lQuery.SQL.Text :=
        'delete from data_files where id in (select m.file_id from ' +
        'mera_recording_files m join mera_recordings r on r.id=m.recording_id ' +
        'where r.event_id=:event) and not exists ' +
        '(select 1 from mera_recording_files m2 join mera_recordings r2 ' +
        'on r2.id=m2.recording_id where m2.file_id=data_files.id ' +
        'and r2.event_id<>:event) and not exists ' +
        '(select 1 from data_file_links l where l.file_id=data_files.id)';
      lQuery.ParamByName('event').AsString := AEventId;
      lQuery.ExecSQL;
      lQuery.SQL.Text := 'delete from mera_recording_files where recording_id ' +
        'in (select id from mera_recordings where event_id=:event)';
      lQuery.ParamByName('event').AsString := AEventId;
      lQuery.ExecSQL;
      lQuery.SQL.Text := 'delete from mera_recordings where event_id=:event';
      lQuery.ParamByName('event').AsString := AEventId;
      lQuery.ExecSQL;
      lQuery.SQL.Text :=
        'delete from events where id=:event and event_type=''mera.recording''';
      lQuery.ParamByName('event').AsString := AEventId;
      lQuery.ExecSQL;
      Result := lQuery.RowsAffected > 0;
      Commit;
    except
      if fTransaction.Active then fTransaction.RollbackRetaining;
      raise;
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.ListMeraPackages(const AEventId: string;
  out AItems: TRecorderSqlDbMeraPackages);
var
  I: Integer;
  lQuery: TSQLQuery;
begin
  SetLength(AItems, 0);
  EnsureDatabase;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select r.id,r.event_id,r.recorder_instance_id,r.registration_id,' +
      'r.correlation_id,r.display_name,r.started_at_utc,r.finished_at_utc,' +
      'r.state,r.entry_file_id,r.project_name,r.error_text,i.instance_key,' +
      'i.host_name,count(m.file_id),' +
      'cast(coalesce(sum(f.file_size),0) as bigint) ' +
      'from mera_recordings r join recorder_instances i ' +
      'on i.id=r.recorder_instance_id left join mera_recording_files m ' +
      'on m.recording_id=r.id left join data_files f on f.id=m.file_id ' +
      'where r.event_id=:event group by r.id,r.event_id,r.recorder_instance_id,' +
      'r.registration_id,r.correlation_id,r.display_name,r.started_at_utc,' +
      'r.finished_at_utc,r.state,r.entry_file_id,r.project_name,r.error_text,' +
      'i.instance_key,i.host_name order by r.started_at_utc';
    lQuery.ParamByName('event').AsString := AEventId;
    lQuery.Open;
    while not lQuery.EOF do
    begin
      I := Length(AItems);
      SetLength(AItems, I + 1);
      AItems[I].Recording.Id := lQuery.Fields[0].AsString;
      AItems[I].Recording.EventId := lQuery.Fields[1].AsString;
      AItems[I].Recording.RecorderInstanceId := lQuery.Fields[2].AsString;
      AItems[I].Recording.RegistrationId := lQuery.Fields[3].AsString;
      AItems[I].Recording.CorrelationId := lQuery.Fields[4].AsString;
      AItems[I].Recording.DisplayName := lQuery.Fields[5].AsString;
      AItems[I].Recording.StartedAtUtc := lQuery.Fields[6].AsFloat;
      if not lQuery.Fields[7].IsNull then
        AItems[I].Recording.FinishedAtUtc := lQuery.Fields[7].AsFloat;
      AItems[I].Recording.State := lQuery.Fields[8].AsString;
      AItems[I].Recording.EntryFileId := lQuery.Fields[9].AsString;
      AItems[I].Recording.ProjectName := lQuery.Fields[10].AsString;
      AItems[I].Recording.ErrorText := lQuery.Fields[11].AsString;
      AItems[I].InstanceKey := lQuery.Fields[12].AsString;
      AItems[I].HostName := lQuery.Fields[13].AsString;
      AItems[I].FileCount := lQuery.Fields[14].AsInteger;
      AItems[I].TotalSize := lQuery.Fields[15].AsLargeInt;
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderSqlDbRepository.ListAttachments(AFromUtc, AToUtc: Double;
  AItems: TList);
var lQuery: TSQLQuery; lItem: TRecorderSqlDbAttachment;
begin
  if AItems = nil then Exit;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'select f.id,f.storage_key,f.data_type,f.data_format,f.file_size,f.checksum,l.anchor_time_utc,l.time_from_utc,l.time_to_utc from data_files f join data_file_links l on l.file_id=f.id where f.file_state=''ready'' and ((l.anchor_time_utc between :from_utc and :to_utc) or (l.time_from_utc <= :to_utc and l.time_to_utc >= :from_utc)) order by l.anchor_time_utc';
    lQuery.Params.ParamByName('from_utc').AsFloat := AFromUtc;
    lQuery.Params.ParamByName('to_utc').AsFloat := AToUtc;
    lQuery.Open;
    while not lQuery.EOF do
    begin
      lItem := TRecorderSqlDbAttachment.Create;
      lItem.Id := lQuery.Fields[0].AsString;
      lItem.StorageKey := lQuery.Fields[1].AsString;
      lItem.DataType := lQuery.Fields[2].AsString;
      lItem.DataFormat := lQuery.Fields[3].AsString;
      lItem.Size := lQuery.Fields[4].AsLargeInt;
      lItem.Checksum := lQuery.Fields[5].AsString;
      lItem.AnchorTimeUtc := lQuery.Fields[6].AsFloat;
      lItem.TimeFromUtc := lQuery.Fields[7].AsFloat;
      lItem.TimeToUtc := lQuery.Fields[8].AsFloat;
      AItems.Add(lItem);
      lQuery.Next;
    end;
  finally lQuery.Free; end;
end;

function TRecorderSqlDbRepository.CountRows(const ATableName: string): Int64;
var I: Integer; lValid: Boolean;
begin
  lValid := False;
  for I := Low(CSchemaTables) to High(CSchemaTables) do
    if SameText(CSchemaTables[I], ATableName) then begin lValid := True; Break; end;
  if not lValid then raise ERecorderSqlDbError.Create('Unknown SQLdb table: ' + ATableName);
  Result := ScalarInt('select count(*) from ' + ATableName);
end;

end.
