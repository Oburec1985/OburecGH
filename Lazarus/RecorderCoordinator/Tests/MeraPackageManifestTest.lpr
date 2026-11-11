program MeraPackageManifestTest;

{$mode objfpc}{$H+}

uses
  {$ifdef unix}cthreads,{$endif}
  Classes, SysUtils, DateUtils, fpjson, SQLite3Dyn,
  uRecorderMeraPackageManifest, uCoordinatorModel, uCoordinatorSqlEventStore,
  uRecorderSqlDbTypes, uRecorderSqlDbRepository, uRecorderMeraPaths;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

type
  TStoreHarness = class
  public
    Store: TCoordinatorSqlEventStore;
    function Persist(const AInfo: TCoordinatorRecordingLifecycle): string;
  end;

function TStoreHarness.Persist(const AInfo: TCoordinatorRecordingLifecycle): string;
begin
  Result := Store.HandleLifecycle(AInfo);
end;

procedure WriteFixture(const APath: string; ASize: Integer);
var
  S: TFileStream;
  B: array[0..63] of Byte;
begin
  ForceDirectories(ExtractFileDir(APath));
  FillChar(B, SizeOf(B), 42);
  S := TFileStream.Create(APath, fmCreate);
  try
    S.WriteBuffer(B, ASize);
  finally
    S.Free;
  end;
end;

function Send(AModel: TCoordinatorModel; const ARecording, AType,
  AStarted: string; AManifest: TJSONData): string;
var
  D, P, Reply: TJSONObject;
begin
  D := TJSONObject.Create;
  try
    D.Add('message_type', AType);
    D.Add('instance_id', 'manifest-fixture');
    D.Add('correlation_id', ARecording);
    D.Add('sent_at_utc', AStarted);
    P := TJSONObject.Create;
    P.Add('recording_id', ARecording);
    P.Add('started_utc', AStarted);
    P.Add('finished_utc', AStarted);
    P.Add('entry_file', 'smb://fixture-host/Measure/pack/0001.mera');
    P.Add('local_path', '/this-is-not-a-coordinator-local-path');
    P.Add('display_name', ARecording);
    if AManifest <> nil then P.Add('package_manifest', AManifest.Clone);
    D.Add('payload', P);
    Reply := AModel.AddRecordingEvent(D);
    try
      Check(Reply.Get('result_code', '') = 'noError', AType + ' rejected');
      Check(Reply.Get('persistence_error', '') = '',
        'Persistence failed: ' + Reply.Get('persistence_error', ''));
      Result := Reply.Get('event_id', '');
      Check(Result <> '', 'Missing event id');
    finally
      Reply.Free;
    end;
  finally
    D.Free;
  end;
end;

procedure Run;
var
  App, RequestedApp, Root, ConfigPath, DbPath, PackageDir, Entry,
    EventId, Started, SourceFilesBefore: string;
  Config, Reloaded: TRecorderSqlDbConfig;
  Repository: TRecorderSqlDbRepository;
  Model: TCoordinatorModel;
  Harness: TStoreHarness;
  Manifest, Invalid, Bad, Hello, Reply: TJSONObject;
  Packages: TRecorderSqlDbMeraPackages;
  Files, FirstFiles: TRecorderSqlDbMeraFiles;
  Events: TRecorderSqlDbMeraEvents;
  EventIds: TStringList;
  Counts: TRecorderSqlDbEventFileCounts;
  Parsed: TRecorderMeraPackageManifest;
  I: Integer;
begin
  Check((ParamCount = 1) and (Pos('/cfg:', LowerCase(ParamStr(1))) = 1),
    'Explicit isolated /cfg:<TEMP>/MeraManifestApp-*/app.ini is mandatory');
  App := ExpandFileName(RecorderAppConfigFileName);
  RequestedApp := ExpandFileName(Copy(ParamStr(1), 6, MaxInt));
  Root := ExcludeTrailingPathDelimiter(ExtractFileDir(App));
  Check(App = RequestedApp, 'Actual/cfg did not honor the exact requested app.ini');
  Check(Pos(IncludeTrailingPathDelimiter(ExpandFileName(GetTempDir(False))),
    IncludeTrailingPathDelimiter(Root)) = 1, 'Fixture must belong to TEMP');
  Check(Pos('MeraManifestApp-', ExtractFileName(Root)) = 1,
    'Fixture must use a unique owned MeraManifestApp-* folder');
  Check(SameText(ExtractFileName(App), 'app.ini') and not FileExists(App),
    'Fixture application INI must be a new app.ini');
  ForceDirectories(Root);
  {$ifdef unix}
  InitializeSQLite('libsqlite3.so.0');
  {$else}
  InitializeSQLite(IncludeTrailingPathDelimiter(GetEnvironmentVariable('WINDIR')) +
    'System32\winsqlite3.dll');
  {$endif}
  ConfigPath := IncludeTrailingPathDelimiter(Root) + 'manifest-sql.ini';
  DbPath := IncludeTrailingPathDelimiter(Root) + 'manifest.sqlite3';
  PackageDir := IncludeTrailingPathDelimiter(Root) + 'pack';
  Entry := IncludeTrailingPathDelimiter(PackageDir) + '0001.mera';
  WriteFixture(Entry, 11);
  WriteFixture(IncludeTrailingPathDelimiter(PackageDir) + 'channel.dat', 17);
  WriteFixture(IncludeTrailingPathDelimiter(PackageDir) + 'channel.x', 7);
  WriteFixture(IncludeTrailingPathDelimiter(PackageDir) + 'empty.dat', 0);
  WriteFixture(IncludeTrailingPathDelimiter(PackageDir) + 'nested/a b%.dat', 5);
  Manifest := RecorderBuildMeraManifest(PackageDir, Entry);
  Invalid := nil;
  Bad := nil;
  EventIds := TStringList.Create;
  Config := TRecorderSqlDbConfig.Create;
  Reloaded := TRecorderSqlDbConfig.Create;
  Repository := nil;
  Harness := TStoreHarness.Create;
  Model := TCoordinatorModel.Create;
  try
    Parsed := RecorderReadMeraManifest(Manifest);
    Check(Parsed.Complete and (Length(Parsed.Files) = 5), 'Source full manifest failed');
    SourceFilesBefore := Manifest.AsJSON;
    Invalid := TJSONObject(Manifest.Clone);
    TJSONObject(TJSONArray(Invalid.Find('files'))[1]).Strings['relative_name'] := '../escape.dat';
    Check(not RecorderReadMeraManifest(Invalid).Complete, 'Traversal manifest accepted');
    Bad := TJSONObject(Manifest.Clone);
    TJSONObject(TJSONArray(Bad.Find('files'))[1]).Strings['relative_name'] := '0001.mera';
    Check(not RecorderReadMeraManifest(Bad).Complete, 'Duplicate manifest filename accepted');
    FreeAndNil(Bad);
    Bad := TJSONObject.Create;
    Bad.Add('complete', 'not-a-boolean');
    Check(not RecorderReadMeraManifest(Bad).Complete, 'Malformed manifest type accepted');
    FreeAndNil(Bad);
    Config.Enabled := True;
    Config.Backend := rsbSQLite;
    Config.RootDirectory := Root;
    Config.Database := DbPath;
    Check(Config.DatabaseFileName = DbPath, 'Fixture database escaped its TEMP root');
    Config.SaveToFile(ConfigPath);
    Reloaded.LoadFromFile(ConfigPath);
    Check((Reloaded.Backend = rsbSQLite) and (Reloaded.DatabaseFileName = DbPath),
      'Saved SQL config did not preserve the exact isolated database');
    Harness.Store := TCoordinatorSqlEventStore.Create(ConfigPath);
    Check(Harness.Store.DatabaseDisplay = DbPath,
      'Coordinator would open a different database; refusing any write');
    Repository := TRecorderSqlDbRepository.Create(Reloaded);
    Repository.Open;
    Check(Repository.Connection.DatabaseName = DbPath, 'Actual DB attachment is not the fixture');
    Repository.EnsureDatabase;
    Repository.Flush;
    Model.CreateRecordingEvents := True;
    Model.OnRecordingLifecycle := @Harness.Persist;
    Hello := TJSONObject.Create;
    try
      Hello.Add('instance_id', 'manifest-fixture');
      Hello.Add('host_name', 'fixture-host');
      Reply := Model.RegisterHello(Hello);
      Reply.Free;
    finally
      Hello.Free;
    end;
    Started := DateToISO8601(LocalTimeToUniversal(Now), True);
    EventId := Send(Model, 'manifest-recording', 'recording.started', Started, nil);
    Repository.ListMeraPackages(EventId, Packages);
    Check((Length(Packages) = 1) and (Packages[0].FileCount = -1) and
      (Packages[0].TotalSize = -1), 'Building package claims a known total');
    Repository.Flush;
    Check(Send(Model, 'manifest-recording', 'recording.completed', Started, Manifest) = EventId,
      'Completion changed the event identity');
    Repository.ListMeraPackages(EventId, Packages);
    Check((Length(Packages) = 1) and (Packages[0].FileCount = 5) and
      (Packages[0].TotalSize = 40), 'Completed package count/size excludes payload files');
    Repository.ListMeraFiles('manifest-recording', FirstFiles);
    Check(Length(FirstFiles) = 5, 'Manifest children were not persisted');
    Repository.Flush;
    Check(Send(Model, 'manifest-recording', 'recording.completed', Started, Manifest) = EventId,
      'Retry changed the event identity');
    Repository.ListMeraFiles('manifest-recording', Files);
    Check(Length(Files) = 5, 'Retry duplicated manifest files');
    for I := 0 to High(Files) do
      Check((Files[I].FileId = FirstFiles[I].FileId) and
        (Files[I].Size = FirstFiles[I].Size), 'Retry changed stable file identity or size');
    Repository.ListTimelineEvents(LocalTimeToUniversal(Now) - 1,
      LocalTimeToUniversal(Now) + 1, True, False, False, Events);
    Check((Length(Events) = 1) and (Events[0].TotalSize = 40) and
      (Events[0].MeraFileCount = 1), 'Timeline must aggregate all bytes but open only the entry descriptor');
    Repository.Flush;
    Started := DateToISO8601(LocalTimeToUniversal(Now) + 1, True);
    EventId := Send(Model, 'legacy-recording', 'recording.started', Started, nil);
    Send(Model, 'legacy-recording', 'recording.completed', Started, nil);
    Repository.ListMeraPackages(EventId, Packages);
    Check((Length(Packages) = 1) and (Packages[0].FileCount = -1) and
      (Packages[0].TotalSize = -1), 'Legacy descriptor size masquerades as package total');
    Repository.ListMeraFiles('legacy-recording', Files);
    Check((Length(Files) = 1) and (Files[0].FileRole = 'entry-mera'),
      'Legacy entry descriptor must remain available for opening');
    EventIds.Add(EventId);
    Repository.ListRecordingMeraFileCounts(EventIds, Counts);
    Check((Length(Counts) = 1) and (Counts[0].FileCount = 1),
      'Legacy known entry count must not become unknown package count');
    Repository.Flush;
    Started := DateToISO8601(LocalTimeToUniversal(Now) + 2, True);
    EventId := Send(Model, 'invalid-recording', 'recording.started', Started, nil);
    Send(Model, 'invalid-recording', 'recording.completed', Started, Invalid);
    Repository.ListMeraPackages(EventId, Packages);
    Check((Length(Packages) = 1) and (Packages[0].FileCount = -1) and
      (Packages[0].TotalSize = -1), 'Malformed manifest did not retain an unknown descriptor');
    Repository.Flush;
    { Simulate an older client row only inside this strictly isolated TEMP DB.
      Release the independent reader before the fixture performs this write. }
    FreeAndNil(Harness.Store);
    Repository.Connection.ExecuteDirect('update data_files set file_size=0 where id=''legacy-recording''');
    Repository.Flush;
    EventId := EventIds[0];
    Repository.ListMeraPackages(EventId, Packages);
    Check((Length(Packages) = 1) and (Packages[0].FileCount = -1) and
      (Packages[0].TotalSize = -1), 'Historical zero entry must project unknown, not an empty package');
    Repository.ListRecordingMeraFileCounts(EventIds, Counts);
    Check((Length(Counts) = 1) and (Counts[0].FileCount = 1),
      'Historical zero size must not hide a known entry descriptor');
    FreeAndNil(Manifest);
    Manifest := RecorderBuildMeraManifest(PackageDir, Entry);
    Check(Manifest.AsJSON = SourceFilesBefore, 'Persistence changed source package files');
  finally
    Model.OnRecordingLifecycle := nil;
    Model.Free;
    Harness.Store.Free;
    Harness.Free;
    Repository.Free;
    Reloaded.Free;
    Config.Free;
    Invalid.Free;
    Bad.Free;
    EventIds.Free;
    Manifest.Free;
  end;
end;

begin
  try
    Run;
    WriteLn('RESULT MeraPackageManifestTest passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT MeraPackageManifestTest failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
