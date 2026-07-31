unit uRecorderSqlDbRepository;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, DB, SQLDB,
  uRecorderSqlDbTypes;

type
  TRecorderSqlDbRepository = class
  private
    fConfig: TRecorderSqlDbConfig;
    fConnection: TSQLConnection;
    fTransaction: TSQLTransaction;
    function CreateConnection: TSQLConnection;
    function TableExists(const AName: string): Boolean;
    procedure CreateTableIfMissing(const AName, ASql: string);
    procedure Exec(const ASql: string);
    function ScalarInt(const ASql: string): Int64;
    function FindId(const ASql, AParamName, AParamValue: string): string;
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
      ARecorderTag: string): string;
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
    procedure ListAttachments(AFromUtc, AToUtc: Double; AItems: TList);
    procedure ListSignalNames(AItems: TStrings);
    function GetTrendTimeRange(out AFromUtc, AToUtc: Double;
      out APointCount: Int64): Boolean;
    procedure ReadTrendPoints(ASignalNames: TStrings; AFromUtc, AToUtc: Double;
      AMaxPointsPerSignal: Integer; out APoints: TRecorderSqlTrendPoints);
    function CountRows(const ATableName: string): Int64;
    property Connection: TSQLConnection read fConnection;
  end;

implementation

uses
  SQLite3Conn, IBConnection, PQConnection;

const
  CSchemaTables: array[0..12] of string = (
    'schema_info', 'objects', 'property_definitions', 'object_property_values',
    'signals', 'signal_bindings', 'tests', 'registrations',
    'recording_policies', 'signal_values', 'events', 'data_files',
    'data_file_links');

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
        if (lHost <> '') and (fConfig.Port <> 0) then
          lHost := lHost + '/' + IntToStr(fConfig.Port);
        Result.HostName := lHost;
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
    Close;
    raise;
  end;
end;

procedure TRecorderSqlDbRepository.Close;
begin
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
  Open;
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

function TRecorderSqlDbRepository.GetTrendTimeRange(out AFromUtc,
  AToUtc: Double; out APointCount: Int64): Boolean;
var
  lQuery: TSQLQuery;
begin
  AFromUtc := 0;
  AToUtc := 0;
  APointCount := 0;
  Open;
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
  out APoints: TRecorderSqlTrendPoints);
var
  I, lCount, lStep, lSourceIndex: Integer;
  lQuery: TSQLQuery;
  lName: string;
begin
  SetLength(APoints, 0);
  if (ASignalNames = nil) or (ASignalNames.Count = 0) or
    (AToUtc <= AFromUtc) then Exit;
  if AMaxPointsPerSignal < 32 then AMaxPointsPerSignal := 32;
  Open;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection;
    lQuery.Transaction := fTransaction;
    lQuery.SQL.Text :=
      'select s.name, v.timestamp_utc, v.measured_value '+
      'from signal_values v join signals s on s.id=v.signal_id '+
      'where s.name=:signal_name and v.timestamp_utc>=:time_from '+
      'and v.timestamp_utc<=:time_to order by v.timestamp_utc';
    for I := 0 to ASignalNames.Count - 1 do
    begin
      lName := ASignalNames[I];
      lQuery.Close;
      lQuery.ParamByName('signal_name').AsString := lName;
      lQuery.ParamByName('time_from').AsFloat := AFromUtc;
      lQuery.ParamByName('time_to').AsFloat := AToUtc;
      lQuery.Open;
      lCount := 0;
      while not lQuery.EOF do begin Inc(lCount); lQuery.Next; end;
      lStep := 1;
      if lCount > AMaxPointsPerSignal then
        lStep := (lCount + AMaxPointsPerSignal - 1) div AMaxPointsPerSignal;
      lQuery.First;
      lSourceIndex := 0;
      while not lQuery.EOF do
      begin
        if (lSourceIndex mod lStep = 0) or (lSourceIndex = lCount - 1) then
        begin
          SetLength(APoints, Length(APoints) + 1);
          APoints[High(APoints)].SignalName := lQuery.Fields[0].AsString;
          APoints[High(APoints)].TimestampUtc := lQuery.Fields[1].AsFloat;
          APoints[High(APoints)].Value := lQuery.Fields[2].AsFloat;
        end;
        Inc(lSourceIndex);
        lQuery.Next;
      end;
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

procedure TRecorderSqlDbRepository.CreateTableIfMissing(const AName, ASql: string);
begin
  if not TableExists(AName) then Exec(ASql);
end;

procedure TRecorderSqlDbRepository.EnsureDatabase;
var
  lQuery: TSQLQuery;
begin
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
    'create table signals (id varchar(36) primary key, object_id varchar(36) not null, parent_id varchar(36), name varchar(255) not null, value_type varchar(40) not null, unit_name varchar(64), enabled smallint not null)');
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
    'create table events (id varchar(36) primary key, registration_id varchar(36), object_id varchar(36), signal_id varchar(36), timestamp_utc double precision not null, event_type varchar(80) not null, severity varchar(32), measured_value double precision, event_text varchar(2048), payload_json varchar(8191))');
  CreateTableIfMissing('data_files',
    'create table data_files (id varchar(36) primary key, storage_key varchar(500) not null unique, data_type varchar(80), data_format varchar(80), file_size bigint not null, checksum varchar(128), file_state varchar(32) not null, created_at double precision not null)');
  CreateTableIfMissing('data_file_links',
    'create table data_file_links (id varchar(36) primary key, file_id varchar(36) not null, registration_id varchar(36), signal_id varchar(36), event_id varchar(36), anchor_time_utc double precision, time_from_utc double precision, time_to_utc double precision)');
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
  if SchemaVersion > CRecorderSqlDbSchemaVersion then
    raise ERecorderSqlDbError.CreateFmt('Database schema %d is newer than supported %d',
      [SchemaVersion, CRecorderSqlDbSchemaVersion]);
  Commit;
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
    Open;
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
  AValueType, AUnit, ARecorderTag: string): string;
var
  lQuery: TSQLQuery;
begin
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fConnection; lQuery.Transaction := fTransaction;
    lQuery.SQL.Text := 'select id from signals where object_id=:object_id and name=:name';
    lQuery.Params.ParamByName('object_id').AsString := AObjectId;
    lQuery.Params.ParamByName('name').AsString := AName;
    lQuery.Open;
    if not lQuery.EOF then Exit(lQuery.Fields[0].AsString);
    lQuery.Close;
    Result := RecorderSqlDbNewId;
    lQuery.SQL.Text := 'insert into signals(id,object_id,name,value_type,unit_name,enabled) values(:id,:object_id,:name,:value_type,:unit_name,1)';
    lQuery.Params.ParamByName('id').AsString := Result;
    lQuery.Params.ParamByName('object_id').AsString := AObjectId;
    lQuery.Params.ParamByName('name').AsString := AName;
    lQuery.Params.ParamByName('value_type').AsString := AValueType;
    lQuery.Params.ParamByName('unit_name').AsString := AUnit;
    lQuery.ExecSQL;
    lQuery.SQL.Text := 'insert into signal_bindings(id,signal_id,recorder_tag,source_kind) values(:id,:signal_id,:tag,''recorder-tag'')';
    lQuery.Params.ParamByName('id').AsString := RecorderSqlDbNewId;
    lQuery.Params.ParamByName('signal_id').AsString := Result;
    lQuery.Params.ParamByName('tag').AsString := ARecorderTag;
    lQuery.ExecSQL; Commit;
  finally lQuery.Free; end;
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
