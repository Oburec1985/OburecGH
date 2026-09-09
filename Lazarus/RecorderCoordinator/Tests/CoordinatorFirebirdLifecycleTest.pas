program CoordinatorFirebirdLifecycleTest;

{$mode objfpc}{$H+}

uses
  SysUtils, DateUtils, Math, SQLDB, fpjson, uCoordinatorModel, uCoordinatorSqlEventStore,
  uRecorderSqlDbTypes, uRecorderSqlDbRepository;

const
  CInstance = 'codex-firebird-recorder-a';
  CCorrelation = 'codex-firebird-correlation-a';
  CRecording = 'codex-firebird-recording-a';

type
  TStoreHarness = class
  private
    fStore: TCoordinatorSqlEventStore;
  public
    constructor Create(const AConfig: string);
    destructor Destroy; override;
    function Store(const AInfo: TCoordinatorRecordingLifecycle): string;
  end;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

constructor TStoreHarness.Create(const AConfig: string);
begin
  inherited Create;
  fStore := TCoordinatorSqlEventStore.Create(AConfig);
end;

destructor TStoreHarness.Destroy;
begin
  fStore.Free;
  inherited Destroy;
end;

function TStoreHarness.Store(
  const AInfo: TCoordinatorRecordingLifecycle): string;
begin
  Result := fStore.HandleLifecycle(AInfo);
end;

function SendLifecycle(AModel: TCoordinatorModel; const AType: string): string;
var
  D, P, R: TJSONObject;
begin
  D := TJSONObject.Create;
  try
    D.Add('message_type', AType);
    D.Add('instance_id', CInstance);
    D.Add('correlation_id', CCorrelation);
    P := TJSONObject.Create;
    P.Add('recording_id', CRecording);
    P.Add('local_path', 'C:\Mera Files\codex-firebird');
    P.Add('entry_file', 'C:\Mera Files\codex-firebird\record.mera');
    P.Add('started_utc', '2026-09-09T10:00:00.000Z');
    P.Add('finished_utc', '2026-09-09T10:00:05.000Z');
    P.Add('display_name', 'Codex Firebird lifecycle');
    P.Add('project_name', 'firebird-regression');
    D.Add('payload', P);
    R := AModel.AddRecordingEvent(D);
    try
      Check(R.Get('result_code', '') = 'noError', AType + ' rejected');
      Check(R.Get('persistence_error', '') = '',
        AType + ' persistence: ' + R.Get('persistence_error', ''));
      Result := R.Get('event_id', '');
      Check(Result <> '', AType + ' returned no event id');
    finally
      R.Free;
    end;
  finally
    D.Free;
  end;
end;

procedure RegisterHost(AModel: TCoordinatorModel);
var
  D, R: TJSONObject;
begin
  D := TJSONObject.Create;
  try
    D.Add('instance_id', CInstance);
    D.Add('host_name', 'Codex Firebird host');
    D.Add('remote_address', '127.0.0.1');
    R := AModel.RegisterHello(D);
    R.Free;
  finally
    D.Free;
  end;
end;

procedure CleanupTestData(const AConfigFile: string);
var
  Cfg: TRecorderSqlDbConfig;
  Repo: TRecorderSqlDbRepository;
begin
  Cfg := TRecorderSqlDbConfig.Create;
  try
    Cfg.LoadFromFile(AConfigFile);
    Repo := TRecorderSqlDbRepository.Create(Cfg);
    try
      Repo.EnsureDatabase;
      Repo.Connection.ExecuteDirect(
        'delete from data_file_locations where file_id=''' + CRecording + '''');
      Repo.Connection.ExecuteDirect(
        'delete from mera_recording_files where recording_id=''' + CRecording + '''');
      Repo.Connection.ExecuteDirect(
        'delete from data_files where id=''' + CRecording + '''');
      Repo.Connection.ExecuteDirect(
        'delete from mera_recordings where id=''' + CRecording + '''');
      Repo.Connection.ExecuteDirect(
        'delete from recorder_instances where instance_key=''' + CInstance + '''');
      Repo.Connection.ExecuteDirect(
        'delete from events where display_name=''Codex Firebird lifecycle'' ' +
        'or event_text=''Codex Firebird lifecycle''');
      Repo.Flush;
    finally
      Repo.Free;
    end;
  finally
    Cfg.Free;
  end;
end;

var
  Config: TRecorderSqlDbConfig;
  Event1, Event2: string;
  Harness: TStoreHarness;
  Model: TCoordinatorModel;
  Packages: TRecorderSqlDbMeraPackages;
  Events: TRecorderSqlDbMeraEvents;
  AttachmentName: string;
  Query: TSQLQuery;
  Repository: TRecorderSqlDbRepository;
  SnapshotCount: Integer;
  SnapshotUtc, SnapshotStartedUtc, SnapshotFinishedUtc: Double;
begin
  Check(ParamCount = 1, 'Usage: CoordinatorFirebirdLifecycleTest <sql-db.ini>');
  CleanupTestData(ParamStr(1));
  Harness := TStoreHarness.Create(ParamStr(1));
  Model := TCoordinatorModel.Create;
  try
    Model.CreateRecordingEvents := True;
    Model.OnRecordingLifecycle := @Harness.Store;
    RegisterHost(Model);
    Event1 := SendLifecycle(Model, 'recording.started');
    Event2 := SendLifecycle(Model, 'recording.started');
    Check(Event2 = Event1, 'duplicate started changed event id');
    Event2 := SendLifecycle(Model, 'recording.completed');
    Check(Event2 = Event1, 'completed changed event id');
    Event2 := SendLifecycle(Model, 'recording.completed');
    Check(Event2 = Event1, 'duplicate completed changed event id');

    Config := TRecorderSqlDbConfig.Create;
    try
      Config.LoadFromFile(ParamStr(1));
      Repository := TRecorderSqlDbRepository.Create(Config);
      try
        Check(Repository.GetMeraEventSnapshot(Event1, SnapshotUtc,
          SnapshotStartedUtc, SnapshotFinishedUtc, SnapshotCount),
          'fresh repository cannot read persisted event');
        Check(SnapshotCount = 1,
          'fresh repository returned unexpected recording count');
        Check(Repository.DatabaseAttachmentName(AttachmentName),
          'cannot identify database attachment');
        Repository.ListMeraRecordingEvents(
          Min(SnapshotStartedUtc, SnapshotFinishedUtc) - 1.0 / SecsPerDay,
          Max(SnapshotStartedUtc, SnapshotFinishedUtc) + 1.0 / SecsPerDay,
          Events);
        Check(Length(Events) = 1,
          'event is not visible through production interval query');
        Check(Events[0].EventId = Event1,
          'production interval query returned another event');
        Repository.ListMeraRecordingEvents(
          Max(SnapshotStartedUtc, SnapshotFinishedUtc) + 2.0 / SecsPerDay,
          Max(SnapshotStartedUtc, SnapshotFinishedUtc) + 60.0 / SecsPerDay,
          Events);
        Check(Length(Events) = 0,
          'event leaked outside its recording time interval');
        Repository.ListMeraPackages(Event1, Packages);
        Check(Length(Packages) = 1, 'expected exactly one idempotent package');
        Check(Packages[0].Recording.Id = CRecording, 'recording id mismatch');
        Check(Packages[0].Recording.State = 'ready-local', 'recording not final');
        Check(Packages[0].FileCount = 1, 'entry file was duplicated');
        Query := TSQLQuery.Create(nil);
        try
          Query.DataBase := Repository.Connection;
          Query.Transaction := Repository.Connection.Transaction;
          Query.SQL.Text := 'select count(*) from events where display_name=:text';
          Query.ParamByName('text').AsString := 'Codex Firebird lifecycle';
          Query.Open;
          Check(Query.Fields[0].AsLargeInt = 1,
            'existing recording id left duplicate/orphan SQL events: ' +
            Query.Fields[0].AsString);
        finally
          Query.Free;
        end;
      finally
        Repository.Free;
      end;
    finally
      Config.Free;
    end;
    Writeln('RESULT Coordinator Firebird lifecycle passed event=', Event1,
      ' attachment=', AttachmentName);
  finally
    Model.OnRecordingLifecycle := nil;
    Model.Free;
    Harness.Free;
    CleanupTestData(ParamStr(1));
  end;
end.
