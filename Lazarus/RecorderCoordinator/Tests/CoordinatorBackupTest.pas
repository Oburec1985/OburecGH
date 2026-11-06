program CoordinatorBackupTest;
{$mode objfpc}{$H+}
{$codepage UTF8}
uses Classes, SysUtils, IniFiles, uCoordinatorBackup
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

procedure Check(AValue: Boolean; const AMessage: string);
begin if not AValue then raise Exception.Create(AMessage); end;

procedure WriteText(const AFileName, AText: string);
var lFile: TStringList;
begin
  lFile := TStringList.Create;
  try lFile.Text := AText; lFile.LineBreak := #10; lFile.SaveToFile(AFileName); finally lFile.Free; end;
end;

function FindSnapshot(const AParent: string): string;
var lSearch: TSearchRec;
begin
  Result := '';
  if FindFirst(AParent + '/*', faDirectory, lSearch) <> 0 then Exit;
  try
    repeat
      if (lSearch.Name <> '.') and (lSearch.Name <> '..') and
        ((lSearch.Attr and faDirectory) <> 0) then
        Exit(AParent + '/' + lSearch.Name);
    until FindNext(lSearch) <> 0;
  finally SysUtils.FindClose(lSearch); end;
end;

{$IFDEF BACKUP_TEST_HOOKS}
var TestStoragePath, TestMarkerPath: string; RetryCount: Integer;
procedure RetryWithoutWait;
begin Inc(RetryCount); end;
procedure RepairExportOnRetry;
begin
  Inc(RetryCount);
  WriteText(TestMarkerPath, '0123456789abcdef0123456789abcdef');
end;
procedure ChangeStorageDuringCopy;
begin WriteText(TestStoragePath, '[Storage]' + #10 + 'MeraFilesPath=/changed'); end;
{$ENDIF}

var
  lRoot, lConfig, lProjects, lProgram, lDest, lReport, lSnapshot: string;
  lHost: TBackupHost;
  lIni: TIniFile;
begin
  if ParamCount <> 1 then raise Exception.Create('Pass a new isolated test directory');
  lRoot := IncludeTrailingPathDelimiter(ExpandFileName(ParamStr(1)));
  if DirectoryExists(lRoot) then raise Exception.Create('Test directory already exists');
  Check(ForceDirectories(lRoot), 'test root');
  lConfig := lRoot + 'machine'; lProjects := lRoot + 'projects';
  lProgram := lRoot + 'program'; lDest := lRoot + 'destination';
  Check(ForceDirectories(lConfig + '/config') and ForceDirectories(lProjects + '/001') and
    ForceDirectories(lRoot + 'calibr') and ForceDirectories(lRoot + 'sdb') and
    ForceDirectories(lProgram + '/plugins') and ForceDirectories(lDest), 'fixture directories');
  lIni := TIniFile.Create(lConfig + '/app.ini');
  try lIni.WriteString('Application', 'DefaultProjectConfigDir', '/remote/config/001');
    lIni.UpdateFile; finally lIni.Free; end;
  lIni := TIniFile.Create(lConfig + '/backup-export-info.ini');
  try
    lIni.WriteString('BackupExport', 'State', 'ready');
    lIni.WriteString('BackupExport', 'ProjectsGeneration', '0123456789abcdef0123456789abcdef');
    lIni.WriteString('BackupExport', 'CalibrGeneration', '0123456789abcdef0123456789abcdef');
    lIni.WriteString('BackupExport', 'SdbGeneration', '0123456789abcdef0123456789abcdef');
    lIni.WriteString('BackupExport', 'ProjectsRoot', '/remote/config');
    lIni.WriteString('BackupExport', 'RuntimeMeraRoot', '/remote/mera');
    lIni.WriteString('BackupExport', 'CalibrRoot', '/remote/mera/Calibr');
    lIni.WriteString('BackupExport', 'SdbRoot', '/remote/mera/SDB');
    lIni.WriteString('BackupExport', 'ProgramRoot', '/opt/mera/RecorderLnx');
    lIni.UpdateFile;
  finally lIni.Free; end;
  lIni := TIniFile.Create(lConfig + '/storage.ini');
  try lIni.WriteString('Storage', 'MeraFilesPath', '/remote/mera');
    lIni.UpdateFile; finally lIni.Free; end;
  WriteText(lProjects + '/.recorder-backup-export-0123456789abcdef0123456789abcdef', '0123456789abcdef0123456789abcdef');
  WriteText(lRoot + 'calibr/.recorder-backup-export-0123456789abcdef0123456789abcdef', '0123456789abcdef0123456789abcdef');
  WriteText(lRoot + 'sdb/.recorder-backup-export-0123456789abcdef0123456789abcdef', '0123456789abcdef0123456789abcdef');
  WriteText(lProjects + '/001/config.json', '{"tags":[]}');
  WriteText(lProjects + '/001/gui.ini', '[gui]');
  WriteText(lProjects + '/001/.hidden', 'hidden config');
  WriteText(lProjects + '/LogLinux.log', 'must not copy');
  WriteText(lProjects + '/app.ini.before-backup', 'must not copy');
  WriteText(lRoot + 'calibr/channel.cal', 'calibration');
  WriteText(lProgram + '/RecorderLnx.paths.ini', '[Paths]');
  WriteText(lProgram + '/RecorderLnx', 'program');
  WriteText(lProgram + '/plugins/sample.so', 'plugin');
  lHost.DisplayName := 'KIP-1'; lHost.ConfigRoot := lConfig;
  lHost.ConfigRootRemote := '/remote/machine'; lHost.ProgramRoot := lProgram;
  SetLength(lHost.ConfigRoots, 4);
  lHost.ConfigRoots[0].SourcePath := lConfig + '/config';
  lHost.ConfigRoots[0].DestinationName := 'app-config';
  lHost.ConfigRoots[1].SourcePath := lProjects;
  lHost.ConfigRoots[1].DestinationName := 'projects';
  lHost.ConfigRoots[2].SourcePath := lRoot + 'calibr';
  lHost.ConfigRoots[2].DestinationName := 'Calibr';
  lHost.ConfigRoots[3].SourcePath := lRoot + 'sdb';
  lHost.ConfigRoots[3].DestinationName := 'SDB';
  Check(BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), lReport);
  lSnapshot := FindSnapshot(lDest + '/KIP-1');
  Check(lSnapshot <> '', 'snapshot folder');
  Check(FileExists(lSnapshot + '/configurations/projects/001/.hidden'), 'hidden file');
  Check(not FileExists(lSnapshot + '/configurations/projects/.recorder-backup-export-0123456789abcdef0123456789abcdef'), 'export marker excluded');
  Check(FileExists(lSnapshot + '/configurations/app.ini'), 'active app.ini');
  Check(not DirectoryExists(lSnapshot + '/program'), 'program not copied');
  Check(not DirectoryExists(lSnapshot + '/configurations/SDB'), 'SDB not copied');
  Check(not DirectoryExists(lSnapshot + '/configurations/Calibr'), 'GX not selected');
  Check(not FileExists(lSnapshot + '/configurations/storage.ini'), 'storage.ini not copied');
  Check(not FileExists(lSnapshot + '/configurations/projects/LogLinux.log'), 'outer logs not copied');
  Check(not FileExists(lSnapshot + '/configurations/projects/app.ini.before-backup'), 'outer backup app.ini not copied');
  Check(not FileExists(lSnapshot + '/.backup-incomplete'), 'completion marker');
  lHost.DisplayName := 'KIP-1-with-calibration';
  Check(BackupRecorderHost(lDest, lHost, [boConfigurations,boCalibrations], lReport), lReport);
  Check(FileExists(FindSnapshot(lDest + '/KIP-1-with-calibration') +
    '/configurations/Calibr/channel.cal'), 'GX included when selected');
  Check(FileExists(lSnapshot + '/configurations/app.ini'), 'original backup preserved');
  Check(not BackupRecorderHost(lDest, lHost, [boConfigurations,boProgram], lReport), 'program option rejected');
  lHost.DisplayName := '../bad';
  Check(not BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), 'path traversal');
  {$IFDEF BACKUP_TEST_HOOKS}
  lHost.DisplayName := 'changed-during-copy';
  TestStoragePath := lConfig + '/storage.ini';
  BackupTestBeforeFinalCheck := @ChangeStorageDuringCopy;
  Check(not BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), 'change during copy rejected');
  BackupTestBeforeFinalCheck := nil;
  lSnapshot := FindSnapshot(lDest + '/changed-during-copy');
  Check(FileExists(lSnapshot + '/.backup-incomplete'), 'changed copy remains incomplete');
  lIni := TIniFile.Create(TestStoragePath);
  try lIni.WriteString('Storage', 'MeraFilesPath', '/remote/mera'); lIni.UpdateFile; finally lIni.Free; end;
  {$ENDIF}
  lHost.DisplayName := 'stale-marker';
  {$IFDEF BACKUP_TEST_HOOKS}
  RetryCount := 0; BackupTestBeforeExportRetry := @RetryWithoutWait;
  {$ENDIF}
  WriteText(lRoot + 'calibr/.recorder-backup-export-0123456789abcdef0123456789abcdef', 'stale');
  Check(not BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), 'stale marker rejected');
  Check(not DirectoryExists(lDest + '/stale-marker'), 'stale export preflight');
  {$IFDEF BACKUP_TEST_HOOKS}
  Check(RetryCount = 1, 'exactly one stale export retry');
  TestMarkerPath := lRoot + 'calibr/.recorder-backup-export-0123456789abcdef0123456789abcdef';
  RetryCount := 0; BackupTestBeforeExportRetry := @RepairExportOnRetry;
  lHost.DisplayName := 'retry-success';
  Check(BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), 'repaired export retry succeeds: ' + lReport);
  Check(RetryCount = 1, 'one retry before success');
  Check(DeleteFile(TestMarkerPath), 'remove marker');
  RetryCount := 0;
  lHost.DisplayName := 'retry-missing-marker';
  Check(BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), 'missing marker retry succeeds: ' + lReport);
  Check(RetryCount = 1, 'missing marker retried once');
  BackupTestBeforeExportRetry := nil;
  {$ENDIF}
  WriteText(lRoot + 'calibr/.recorder-backup-export-0123456789abcdef0123456789abcdef', '0123456789abcdef0123456789abcdef');
  lHost.DisplayName := 'old-metadata';
  lIni := TIniFile.Create(lConfig + '/backup-export-info.ini');
  try lIni.DeleteKey('BackupExport', 'State'); lIni.UpdateFile; finally lIni.Free; end;
  Check(not BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), 'old metadata rejected');
  lIni := TIniFile.Create(lConfig + '/backup-export-info.ini');
  try lIni.WriteString('BackupExport', 'State', 'ready'); lIni.UpdateFile; finally lIni.Free; end;
  lHost.DisplayName := 'missing';
  lIni := TIniFile.Create(lConfig + '/backup-export-info.ini');
  try lIni.WriteString('BackupExport', 'ProjectsRoot', '/different');
    lIni.UpdateFile; finally lIni.Free; end;
  Check(not BackupRecorderHost(lDest, lHost, [boConfigurations], lReport), 'missing active project');
  Check(not DirectoryExists(lDest + '/missing'), 'preflight creates nothing on failure');
  lHost.DisplayName := 'nested';
  Check(not BackupRecorderHost(lProgram, lHost, [boProgram], lReport), 'destination in source');
  {$IFDEF UNIX}
  Check(fpSymlink(PChar('/etc/passwd'), PChar(lProgram + '/plugins/link')) = 0, 'create symlink');
  lHost.DisplayName := 'symlink';
  Check(not BackupRecorderHost(lDest, lHost, [boPlugins], lReport), 'symlink must fail');
  lSnapshot := FindSnapshot(lDest + '/symlink');
  Check(FileExists(lSnapshot + '/.backup-incomplete'), 'failed copy marked incomplete');
  {$ENDIF}
  WriteLn('OK: coordinator backup');
end.
