unit uRecorderMdbRepository;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, SQLDB, uRecorderSqlDbTypes, uRecorderSqlDbRepository,
  uRecorderMdbTypes;

type
  { Domain repository for products, tests and their measurements.  It reuses
    the application's single SQLdb connection/schema instead of creating a
    second database with competing identities. }
  TRecorderMdbRepository = class
  private
    fStore: TRecorderSqlDbRepository;
    function Transaction: TSQLTransaction;
  public
    constructor Create(AConfig: TRecorderSqlDbConfig);
    destructor Destroy; override;
    procedure Open;
    function CreateObject(const AName, AObjectType,
      ASerialNumber: string): string;
    procedure UpdateObject(const AId, AName, AObjectType,
      ASerialNumber: string);
    procedure ListObjects(out AItems: TMdbObjectInfos);
    function CreateTest(const AObjectId, AName, AMetadataJson: string;
      AStartedAtUtc: Double): string;
    procedure FinishTest(const ATestId: string; AFinishedAtUtc: Double);
    procedure ListTests(const AObjectId: string; out AItems: TMdbTestInfos);
    function ContextExists(const AObjectId, ATestId: string): Boolean;
    procedure ListMeasurements(const AObjectId, ATestId: string;
      out AItems: TMdbMeasurementInfos);
    property Store: TRecorderSqlDbRepository read fStore;
  end;

implementation

uses
  DB;

function TRecorderMdbRepository.Transaction: TSQLTransaction;
begin
  Result := TSQLTransaction(fStore.Connection.Transaction);
end;

constructor TRecorderMdbRepository.Create(AConfig: TRecorderSqlDbConfig);
begin
  inherited Create;
  fStore := TRecorderSqlDbRepository.Create(AConfig);
end;

destructor TRecorderMdbRepository.Destroy;
begin
  fStore.Free;
  inherited Destroy;
end;

procedure TRecorderMdbRepository.Open;
begin
  fStore.EnsureDatabase;
end;

function TRecorderMdbRepository.CreateObject(const AName, AObjectType,
  ASerialNumber: string): string;
var
  lQuery: TSQLQuery;
begin
  if Trim(AName) = '' then
    raise EMdbError.Create('Object name is empty');
  Open;
  Result := RecorderSqlDbNewId;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fStore.Connection;
    lQuery.Transaction := Transaction;
    lQuery.SQL.Text := 'insert into objects(id,name,object_type,serial_number,' +
      'created_at,updated_at) values(:id,:name,:type,:serial,:created,:updated)';
    lQuery.ParamByName('id').AsString := Result;
    lQuery.ParamByName('name').AsString := Trim(AName);
    lQuery.ParamByName('type').AsString := Trim(AObjectType);
    lQuery.ParamByName('serial').AsString := Trim(ASerialNumber);
    lQuery.ParamByName('created').AsFloat := Now;
    lQuery.ParamByName('updated').AsFloat := Now;
    lQuery.ExecSQL;
    fStore.Flush;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderMdbRepository.UpdateObject(const AId, AName, AObjectType,
  ASerialNumber: string);
var
  lQuery: TSQLQuery;
begin
  if (Trim(AId) = '') or (Trim(AName) = '') then
    raise EMdbError.Create('Object id or name is empty');
  Open;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fStore.Connection;
    lQuery.Transaction := Transaction;
    lQuery.SQL.Text := 'update objects set name=:name,object_type=:type,' +
      'serial_number=:serial,updated_at=:updated where id=:id';
    lQuery.ParamByName('id').AsString := AId;
    lQuery.ParamByName('name').AsString := Trim(AName);
    lQuery.ParamByName('type').AsString := Trim(AObjectType);
    lQuery.ParamByName('serial').AsString := Trim(ASerialNumber);
    lQuery.ParamByName('updated').AsFloat := Now;
    lQuery.ExecSQL;
    if lQuery.RowsAffected <> 1 then
      raise EMdbError.CreateFmt('Object not found: %s', [AId]);
    fStore.Flush;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderMdbRepository.ListObjects(out AItems: TMdbObjectInfos);
var
  lQuery: TSQLQuery;
  I: Integer;
begin
  SetLength(AItems, 0);
  Open;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fStore.Connection;
    lQuery.Transaction := Transaction;
    lQuery.SQL.Text := 'select id,name,object_type,serial_number from objects ' +
      'order by name,serial_number,id';
    lQuery.Open;
    I := 0;
    while not lQuery.EOF do
    begin
      SetLength(AItems, I + 1);
      AItems[I].Id := lQuery.Fields[0].AsString;
      AItems[I].Name := lQuery.Fields[1].AsString;
      AItems[I].ObjectType := lQuery.Fields[2].AsString;
      AItems[I].SerialNumber := lQuery.Fields[3].AsString;
      Inc(I);
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

function TRecorderMdbRepository.CreateTest(const AObjectId, AName,
  AMetadataJson: string; AStartedAtUtc: Double): string;
var
  lQuery: TSQLQuery;
begin
  if (Trim(AObjectId) = '') or (Trim(AName) = '') then
    raise EMdbError.Create('Test object id or name is empty');
  Open;
  Result := RecorderSqlDbNewId;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fStore.Connection;
    lQuery.Transaction := Transaction;
    lQuery.SQL.Text := 'insert into tests(id,object_id,name,started_at,' +
      'metadata_json) select :id,:object,:name,:started,:metadata from objects ' +
      'where id=:object';
    lQuery.ParamByName('id').AsString := Result;
    lQuery.ParamByName('object').AsString := AObjectId;
    lQuery.ParamByName('name').AsString := Trim(AName);
    lQuery.ParamByName('started').AsFloat := AStartedAtUtc;
    lQuery.ParamByName('metadata').AsString := AMetadataJson;
    lQuery.ExecSQL;
    if lQuery.RowsAffected <> 1 then
      raise EMdbError.CreateFmt('Test object not found: %s', [AObjectId]);
    fStore.Flush;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderMdbRepository.FinishTest(const ATestId: string;
  AFinishedAtUtc: Double);
var
  lQuery: TSQLQuery;
begin
  Open;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fStore.Connection;
    lQuery.Transaction := Transaction;
    lQuery.SQL.Text := 'update tests set finished_at=:finished where id=:id';
    lQuery.ParamByName('id').AsString := ATestId;
    lQuery.ParamByName('finished').AsFloat := AFinishedAtUtc;
    lQuery.ExecSQL;
    if lQuery.RowsAffected <> 1 then
      raise EMdbError.CreateFmt('Test not found: %s', [ATestId]);
    fStore.Flush;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderMdbRepository.ListTests(const AObjectId: string;
  out AItems: TMdbTestInfos);
var
  lQuery: TSQLQuery;
  I: Integer;
begin
  SetLength(AItems, 0);
  Open;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fStore.Connection;
    lQuery.Transaction := Transaction;
    lQuery.SQL.Text := 'select id,object_id,name,started_at,finished_at,' +
      'metadata_json from tests where object_id=:object order by started_at desc,id';
    lQuery.ParamByName('object').AsString := AObjectId;
    lQuery.Open;
    I := 0;
    while not lQuery.EOF do
    begin
      SetLength(AItems, I + 1);
      AItems[I].Id := lQuery.Fields[0].AsString;
      AItems[I].ObjectId := lQuery.Fields[1].AsString;
      AItems[I].Name := lQuery.Fields[2].AsString;
      AItems[I].StartedAtUtc := lQuery.Fields[3].AsFloat;
      if not lQuery.Fields[4].IsNull then
        AItems[I].FinishedAtUtc := lQuery.Fields[4].AsFloat;
      AItems[I].MetadataJson := lQuery.Fields[5].AsString;
      Inc(I);
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

function TRecorderMdbRepository.ContextExists(const AObjectId,
  ATestId: string): Boolean;
var
  lQuery: TSQLQuery;
begin
  Result := False;
  Open;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fStore.Connection;
    lQuery.Transaction := Transaction;
    lQuery.SQL.Text := 'select id from tests where id=:test and object_id=:object';
    lQuery.ParamByName('test').AsString := ATestId;
    lQuery.ParamByName('object').AsString := AObjectId;
    lQuery.Open;
    Result := not lQuery.EOF;
  finally
    lQuery.Free;
  end;
end;

procedure TRecorderMdbRepository.ListMeasurements(const AObjectId,
  ATestId: string; out AItems: TMdbMeasurementInfos);
var
  lQuery: TSQLQuery;
  I: Integer;
begin
  SetLength(AItems, 0);
  Open;
  lQuery := TSQLQuery.Create(nil);
  try
    lQuery.DataBase := fStore.Connection;
    lQuery.Transaction := Transaction;
    lQuery.SQL.Text :=
      'select r.id,r.object_id,r.test_id,r.started_at,r.finished_at,r.status,' +
      'r.reason,(select count(*) from signal_values v where v.registration_id=r.id),' +
      '(select count(*) from events e where e.registration_id=r.id),' +
      '(select count(*) from data_file_links f where f.registration_id=r.id) ' +
      'from registrations r where r.object_id=:object and r.test_id=:test ' +
      'order by r.started_at,r.id';
    lQuery.ParamByName('object').AsString := AObjectId;
    lQuery.ParamByName('test').AsString := ATestId;
    lQuery.Open;
    I := 0;
    while not lQuery.EOF do
    begin
      SetLength(AItems, I + 1);
      AItems[I].RegistrationId := lQuery.Fields[0].AsString;
      AItems[I].ObjectId := lQuery.Fields[1].AsString;
      AItems[I].TestId := lQuery.Fields[2].AsString;
      AItems[I].StartedAtUtc := lQuery.Fields[3].AsFloat;
      if not lQuery.Fields[4].IsNull then
        AItems[I].FinishedAtUtc := lQuery.Fields[4].AsFloat;
      AItems[I].Status := lQuery.Fields[5].AsString;
      AItems[I].Reason := lQuery.Fields[6].AsString;
      AItems[I].ValueCount := lQuery.Fields[7].AsLargeInt;
      AItems[I].EventCount := lQuery.Fields[8].AsLargeInt;
      AItems[I].FileCount := lQuery.Fields[9].AsLargeInt;
      Inc(I);
      lQuery.Next;
    end;
  finally
    lQuery.Free;
  end;
end;

end.
