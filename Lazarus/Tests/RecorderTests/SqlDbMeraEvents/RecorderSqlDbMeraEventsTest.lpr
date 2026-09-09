program RecorderSqlDbMeraEventsTest;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, SQLDB, uRecorderSqlDbTypes, uRecorderSqlDbRepository;

procedure Require(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure TestV3Migration(const ARoot: string);
var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
begin
  lConfig := TRecorderSqlDbConfig.Create;
  try
    lConfig.Backend := rsbSQLite;
    lConfig.Enabled := True;
    lConfig.RootDirectory := ARoot;
    lConfig.Database := 'migration.sqlite3';
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    try
      lRepository.Open;
      lRepository.Connection.ExecuteDirect(
        'create table schema_info (version integer not null, ' +
        'applied_at double precision not null, description varchar(255))');
      lRepository.Connection.ExecuteDirect(
        'insert into schema_info(version,applied_at,description) ' +
        'values(3,46000,''test v3'')');
      lRepository.Flush;
      lRepository.EnsureDatabase;
      Require(lRepository.SchemaVersion = 5, 'v3 database was not migrated');
      Require(lRepository.CountRows('recorder_instances') = 0,
        'migrated recorder_instances is not empty');
    finally
      lRepository.Free;
    end;
  finally
    lConfig.Free;
  end;
end;

procedure TestConfiguredFirebird(const AConfigFile: string);
var
  lConfig: TRecorderSqlDbConfig;
  lEvents: TRecorderSqlDbMeraEvents;
  lPackages: TRecorderSqlDbMeraPackages;
  lRepository: TRecorderSqlDbRepository;
begin
  lConfig := TRecorderSqlDbConfig.Create;
  try
    lConfig.LoadFromFile(AConfigFile);
    Require(lConfig.Backend = rsbFirebird,
      'configured integration database is not Firebird');
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    try
      lRepository.EnsureDatabase;
      Require(lRepository.SchemaVersion = CRecorderSqlDbSchemaVersion,
        'Firebird schema migration did not reach current version');
      Writeln('CHECK Firebird ListMeraRecordingEvents');
      lRepository.ListMeraRecordingEvents(0, Now + 1, lEvents);
      Writeln('OK ListMeraRecordingEvents rows=', Length(lEvents));
      if Length(lEvents) > 0 then
      begin
        Writeln('CHECK Firebird ListMeraPackages event=', lEvents[0].EventId);
        lRepository.ListMeraPackages(lEvents[0].EventId, lPackages);
        Writeln('OK ListMeraPackages rows=', Length(lPackages));
      end;
      Writeln('RESULT SQLdb Firebird schema v5 migration passed');
    finally
      lRepository.Free;
    end;
  finally
    lConfig.Free;
  end;
end;

var
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
  lInstanceId, lRecordingId, lValue, lValueType: string;
  lRecording, lCurrent: TRecorderSqlDbMeraRecording;
  lFile: TRecorderSqlDbMeraFile;
  lLocation: TRecorderSqlDbFileLocation;
  lEvents: TRecorderSqlDbMeraEvents;
  lPackages: TRecorderSqlDbMeraPackages;
  lFiles: TRecorderSqlDbMeraFiles;
  lLocations: TRecorderSqlDbFileLocations;
  lRoot: string;
begin
  if (ParamCount = 2) and SameText(ParamStr(1), '--firebird-config') then
  begin
    TestConfiguredFirebird(ParamStr(2));
    Exit;
  end;
  lRoot := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorderlnx-sql-v5-' + FormatDateTime('yyyymmddhhnnsszzz', Now);
  TestV3Migration(lRoot);
  lConfig := TRecorderSqlDbConfig.Create;
  try
    lConfig.Backend := rsbSQLite;
    lConfig.Enabled := True;
    lConfig.RootDirectory := lRoot;
    lConfig.Database := 'events.sqlite3';
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    try
      lRepository.EnsureDatabase;
      Require(lRepository.SchemaVersion = 5, 'schema version is not 5');

      lInstanceId := lRepository.UpsertRecorderInstance('test-instance',
        'host-a', 'Recorder A', 'windows', 46000.25);
      Require(lInstanceId <> '', 'instance was not created');
      Require(lRepository.UpsertRecorderInstance('test-instance', 'host-b',
        'Recorder A', 'linux', 46000.5) = lInstanceId,
        'instance upsert created duplicate');

      lRepository.SetSystemSetting('archive.mera.root', '/srv/mera', 'path',
        lInstanceId, 46000.5);
      Require(lRepository.GetSystemSetting('archive.mera.root', lValue,
        lValueType), 'setting was not found');
      Require((lValue = '/srv/mera') and (lValueType = 'path'),
        'setting value mismatch');

      FillChar(lRecording, SizeOf(lRecording), 0);
      lRecording.Id := '10000000-0000-0000-0000-000000000001';
      lRecording.EventId := '20000000-0000-0000-0000-000000000001';
      lRecording.RecorderInstanceId := lInstanceId;
      lRecording.CorrelationId := '30000000-0000-0000-0000-000000000001';
      lRecording.DisplayName := 'Test measurement';
      lRecording.StartedAtUtc := 46000.25;
      lRecording.State := 'recording';
      lRecording.ProjectName := 'test-project';
      lRecordingId := lRepository.BeginMeraRecording(lRecording);
      Require(lRecordingId = lRecording.Id, 'recording id mismatch');
      Require(lRepository.BeginMeraRecording(lRecording) = lRecordingId,
        'recording begin is not idempotent');

      FillChar(lFile, SizeOf(lFile), 0);
      lFile.FileId := '40000000-0000-0000-0000-000000000001';
      lFile.RecordingId := lRecordingId;
      lFile.FileRole := 'entry-mera';
      lFile.RelativeName := 'frame.mera';
      lFile.StorageKey := 'recorder://test-instance/frame.mera';
      lFile.DataFormat := 'mera';
      lFile.Size := 1234;
      lFile.Checksum := 'abc';
      lFile.State := 'ready';
      lRepository.UpsertMeraFile(lFile);
      lRepository.UpsertMeraFile(lFile);

      FillChar(lLocation, SizeOf(lLocation), 0);
      lLocation.FileId := lFile.FileId;
      lLocation.RecorderInstanceId := lInstanceId;
      lLocation.LocationKind := 'source';
      lLocation.PathKey := 'C:\measurements\frame.mera';
      lLocation.State := 'ready';
      lLocation.CreatedAtUtc := 46000.25;
      lRepository.UpsertDataFileLocation(lLocation);
      lRepository.UpsertDataFileLocation(lLocation);
      Require(lRepository.CountRows('data_file_locations') = 1,
        'location upsert created duplicate');
      lRepository.ListDataFileLocations(lFile.FileId, lLocations);
      Require((Length(lLocations) = 1) and
        (lLocations[0].PathKey = lLocation.PathKey),
        'file location query mismatch');
      Require((lRepository.CountRows('events') = 1) and
        (lRepository.CountRows('mera_recordings') = 1),
        'recording upsert created duplicate');

      lRepository.CompleteMeraRecording(lRecordingId, 'ready-local',
        lFile.FileId, '', 46000.5);
      Require(lRepository.GetCurrentMeraRecording(lInstanceId, lCurrent),
        'current recording was not found');
      Require((lCurrent.Id = lRecordingId) and
        (Abs(lCurrent.StartedAtUtc - 46000.25) < 1E-9),
        'Double UTC was not preserved');
      lRepository.ListMeraFiles(lRecordingId, lFiles);
      Require(Length(lFiles) = 1, 'file upsert created duplicate');
      lRepository.ListMeraRecordingEvents(46000, 46001, lEvents);
      Require((Length(lEvents) = 1) and (lEvents[0].TotalSize = 1234),
        'event query mismatch');
      Require((lEvents[0].DisplayName = 'Test measurement') and
        (lEvents[0].Description = ''), 'new event details mismatch');
      Require(lRepository.UpdateMeraEvent(lRecording.EventId, 'Shown event',
        'Editable description'), 'event details were not updated');
      lRepository.ListMeraRecordingEvents(46000, 46001, lEvents);
      Require((Length(lEvents) = 1) and
        (lEvents[0].DisplayName = 'Shown event') and
        (lEvents[0].Description = 'Editable description'),
        'updated event details were not read from events');
      Require(not lRepository.UpdateDataFileLocationPath(
        '20000000-0000-0000-0000-000000000099', lLocations[0].Id,
        'D:\wrong\frame.mera'), 'foreign event changed a location path');
      Require(lRepository.UpdateDataFileLocationPath(lRecording.EventId,
        lLocations[0].Id, 'D:\corrected\frame.mera'),
        'owned location path was not updated');
      lRepository.ListDataFileLocations(lFile.FileId, lLocations);
      Require((Length(lLocations) = 1) and
        (lLocations[0].PathKey = 'D:\corrected\frame.mera'),
        'corrected location path mismatch');
      lRepository.ListMeraPackages(lRecording.EventId, lPackages);
      Require((Length(lPackages) = 1) and (lPackages[0].FileCount = 1),
        'package query mismatch');
      Require(lRepository.DeleteMeraEvent(lRecording.EventId),
        'MERA event was not deleted');
      Require((lRepository.CountRows('events') = 0) and
        (lRepository.CountRows('mera_recordings') = 0) and
        (lRepository.CountRows('mera_recording_files') = 0) and
        (lRepository.CountRows('data_file_locations') = 0) and
        (lRepository.CountRows('data_files') = 0),
        'MERA event metadata was not completely deleted');
      Require(not lRepository.DeleteMeraEvent(lRecording.EventId),
        'repeated event delete reported success');
      Writeln('RESULT SQLdb MERA schema v5 test passed');
    finally
      lRepository.Free;
    end;
  finally
    lConfig.Free;
  end;
end.
