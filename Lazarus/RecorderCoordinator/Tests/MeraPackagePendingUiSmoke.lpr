program MeraPackagePendingUiSmoke;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$ifdef unix}cthreads,{$endif}
  Interfaces, Forms, Classes, SysUtils, SQLite3Dyn,
  uRecorderSqlDbTypes, uRecorderSqlDbRepository, uRecorderMeraEventDialog,
  uRecorderMeraPaths;

procedure Check(ACondition: Boolean; const AText: string);
begin
  if not ACondition then raise Exception.Create(AText);
end;

procedure WaitForPackage(ADialog: TRecorderMeraEventDialog);
var
  lDeadline: QWord;
begin
  lDeadline := GetTickCount64 + 10000;
  repeat
    Application.ProcessMessages;
    if ADialog.grdPackages.Cells[1, 1] = '0001' then Exit;
    Sleep(5);
  until GetTickCount64 >= lDeadline;
  raise Exception.Create('Package did not load: ' + ADialog.lblStatus.Caption);
end;

procedure RunSmoke;
var
  lRoot, lConfigPath, lEntry, lInstance, lActualApp, lRequestedApp,
    lTempPrefix, lAppDirectory, lCopyEntry: string;
  lGuid: TGuid;
  lConfig: TRecorderSqlDbConfig;
  lRepository: TRecorderSqlDbRepository;
  lRecording: TRecorderSqlDbMeraRecording;
  lFile: TRecorderSqlDbMeraFile;
  lLocation: TRecorderSqlDbFileLocation;
  lEvent: TRecorderSqlDbMeraEvent;
  lDialog: TRecorderMeraEventDialog;
  lHandle: THandle;
  lLocations: TRecorderSqlDbFileLocations;
begin
  Check((ParamCount = 1) and (Pos('/cfg:', LowerCase(ParamStr(1))) = 1),
    'The database fixture requires an explicit isolated /cfg:<directory>/app.ini');
  lActualApp := ExpandFileName(RecorderAppConfigFileName);
  lRequestedApp := ExpandFileName(Copy(ParamStr(1), 6, MaxInt));
  lTempPrefix := IncludeTrailingPathDelimiter(ExpandFileName(GetTempDir(False)));
  lAppDirectory := ExcludeTrailingPathDelimiter(ExtractFileDir(lActualApp));
  Check(lActualApp = lRequestedApp, 'Application INI did not honor the exact fixture path');
  Check((CompareText(Copy(lAppDirectory, 1, Length(lTempPrefix)), lTempPrefix) = 0)
    and (Pos('MeraPendingApp-', ExtractFileName(lAppDirectory)) = 1),
    'Application INI must be in a unique owned MeraPendingApp-* temporary directory');
  Check(not FileExists(lActualApp), 'The fixture application INI must be new');
  Check(SameText(ExtractFileName(lActualApp), 'app.ini'),
    '/cfg must name the isolated app.ini file, not its directory');
  {$ifdef unix}
  InitializeSQLite('libsqlite3.so.0');
  {$else}
  if FileExists(GetEnvironmentVariable('SystemRoot') + '\System32\winsqlite3.dll') then
    InitializeSQLite(GetEnvironmentVariable('SystemRoot') + '\System32\winsqlite3.dll')
  else
    InitializeSQLite(IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'sqlite3.dll');
  {$endif}
  RequireDerivedFormResource := True;
  Application.Initialize;
  CreateGUID(lGuid);
  lRoot := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'MeraPending-' + GUIDToString(lGuid);
  ForceDirectories(lRoot);
  lEntry := IncludeTrailingPathDelimiter(lRoot) + '0001.mera';
  lCopyEntry := IncludeTrailingPathDelimiter(lRoot) + 'manual-copy.mera';
  lConfigPath := IncludeTrailingPathDelimiter(lRoot) + 'sql-db.ini';
  lConfig := TRecorderSqlDbConfig.Create;
  lRepository := nil;
  lDialog := nil;
  try
    lConfig.Enabled := True;
    lConfig.Backend := rsbSQLite;
    lConfig.RootDirectory := lRoot;
    lConfig.Database := IncludeTrailingPathDelimiter(lRoot) + 'pending.sqlite3';
    lConfig.SaveToFile(lConfigPath);
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    lRepository.EnsureDatabase;
    lInstance := lRepository.UpsertRecorderInstance('pending-test',
      'test-host', 'test-host', 'test', Now);
    lRecording := Default(TRecorderSqlDbMeraRecording);
    lRecording.Id := 'pending-recording';
    lRecording.EventId := 'pending-event';
    lRecording.RecorderInstanceId := lInstance;
    lRecording.DisplayName := '0001';
    lRecording.StartedAtUtc := Now;
    lRecording.State := 'building';
    lRepository.BeginMeraRecording(lRecording);
    lFile := Default(TRecorderSqlDbMeraFile);
    lFile.FileId := lRecording.Id;
    lFile.RecordingId := lRecording.Id;
    lFile.FileRole := 'entry-mera';
    lFile.RelativeName := '0001.mera';
    lFile.StorageKey := 'recorder://pending-test/0001';
    lFile.State := 'building';
    lRepository.UpsertMeraFile(lFile);
    lLocation := Default(TRecorderSqlDbFileLocation);
    lLocation.FileId := lFile.FileId;
    lLocation.RecorderInstanceId := lInstance;
    lLocation.LocationKind := 'source-local';
    lLocation.PathKey := lEntry;
    lLocation.State := 'building';
    lLocation.CreatedAtUtc := Now;
    lRepository.UpsertDataFileLocation(lLocation);
    FreeAndNil(lRepository);
    lEvent := Default(TRecorderSqlDbMeraEvent);
    lEvent.EventId := lRecording.EventId;
    lEvent.StartedAtUtc := Now;
    lEvent.DisplayName := 'Pending fixture';
    lDialog := TRecorderMeraEventDialog.CreateDialog(nil, lConfigPath, lEvent);
    lDialog.Show;
    WaitForPackage(lDialog);
    WriteLn('CHECK pending package loaded'); Flush(Output);
    Check(lDialog.grdPackages.Cells[1, 1] = '0001',
      'Pending package did not load: ' + lDialog.lblStatus.Caption);
    Check(lDialog.grdPackages.Cells[6, 1] = lEntry,
      'Pending source path was omitted before completion');
    Check(Pos('Записывается: 1', lDialog.lblStatus.Caption) > 0,
      'Pending package was not identified as recording');
    Check(Pos('не найден', lDialog.lblStatus.Caption) = 0,
      'A legitimate active package was labeled as a missing recording');
    lDialog.grdPackages.Row := 1;
    lDialog.grdPackagesDblClick(nil);
    Check(Pos('ещё выполняется', lDialog.lblStatus.Caption) > 0,
      'Opening a pending package did not wait for completion');
    FreeAndNil(lDialog);
    WriteLn('CHECK pending dialog closed'); Flush(Output);
    lHandle := FileCreate(lEntry); Check(lHandle <> feInvalidHandle, 'Cannot create test source file');
    FileClose(lHandle);
    lHandle := FileCreate(lCopyEntry); Check(lHandle <> feInvalidHandle, 'Cannot create test local copy');
    FileClose(lHandle);
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    lFile.State := 'ready';
    lRepository.UpsertMeraFile(lFile);
    lLocation.State := 'ready';
    lRepository.UpsertDataFileLocation(lLocation);
    lRepository.CompleteMeraRecording(lRecording.Id, 'ready-local', lFile.FileId, '', Now);
    FreeAndNil(lRepository);
    lDialog := TRecorderMeraEventDialog.CreateDialog(nil, lConfigPath, lEvent);
    lDialog.Show;
    WaitForPackage(lDialog);
    WriteLn('CHECK completed package loaded'); Flush(Output);
    Check(Pos('не найден', lDialog.lblStatus.Caption) > 0,
      'An existing local file incorrectly overrode the remote source owner');
    lDialog.grdPackages.Cells[6, 1] := lCopyEntry;
    lDialog.btnSaveClick(nil);
    WriteLn('CHECK manual path saved'); Flush(Output);
    Check(Pos('сохранены', lDialog.lblStatus.Caption) > 0, 'Manual copy path was not saved');
    FreeAndNil(lDialog);
    lRepository := TRecorderSqlDbRepository.Create(lConfig);
    lRepository.ListDataFileLocations(lFile.FileId, lLocations);
    Check((Length(lLocations) = 1) and
      (lLocations[0].LocationKind = 'operator-selected'), 'Manual path intent was not persisted');
    { A delayed source completion must not replace the explicitly chosen copy. }
    lRepository.UpsertDataFileLocation(lLocation);
    FreeAndNil(lRepository);
    lDialog := TRecorderMeraEventDialog.CreateDialog(nil, lConfigPath, lEvent);
    lDialog.Show;
    WaitForPackage(lDialog);
    WriteLn('CHECK manual copy reopened'); Flush(Output);
    Check(lDialog.grdPackages.Cells[6, 1] = lCopyEntry,
      'Reopening selected the source retry instead of the operator copy');
    Check(Pos('не найден', lDialog.lblStatus.Caption) = 0,
      'A valid explicitly selected local copy became unavailable after reopen');
    WriteLn('RESULT MeraPackagePendingUiSmoke passed');
  finally
    lDialog.Free;
    lRepository.Free;
    lConfig.Free;
    DeleteFile(lConfigPath);
    DeleteFile(lEntry); DeleteFile(lCopyEntry);
    DeleteFile(lActualApp);
    RemoveDir(lAppDirectory);
    DeleteFile(IncludeTrailingPathDelimiter(lRoot) + 'pending.sqlite3');
    RemoveDir(lRoot);
  end;
end;

begin
  try
    RunSmoke;
  except
    on E: Exception do
    begin
      WriteLn('RESULT MeraPackagePendingUiSmoke failed: ', E.Message);
      DumpExceptionBackTrace(Output);
      Halt(1);
    end;
  end;
end.
