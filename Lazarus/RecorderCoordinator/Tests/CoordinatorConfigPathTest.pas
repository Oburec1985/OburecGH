program CoordinatorConfigPathTest;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, IniFiles, uCoordinatorConfig, uRecorderMeraPaths,
  uRecorderSqlDbTypes;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure Touch(const AFileName: string);
var
  lStream: TFileStream;
begin
  lStream := TFileStream.Create(AFileName, fmCreate);
  lStream.Free;
end;

procedure WriteCoordinatorConfig(const AFileName, ASqlConfig: string);
var
  lIni: TIniFile;
begin
  lIni := TIniFile.Create(AFileName);
  try
    lIni.WriteString('events', 'sql_db_config', ASqlConfig);
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
end;

procedure CheckLegacyRepair(const ADirectory: string);
var
  lConfig: TCoordinatorConfig;
  lIni: TIniFile;
  lCoordinatorFile, lSqlFile, lSaved: string;
begin
  lCoordinatorFile := IncludeTrailingPathDelimiter(ADirectory) + 'coordinator.ini';
  lSqlFile := IncludeTrailingPathDelimiter(ADirectory) + 'sql-db.ini';
  Touch(lSqlFile);
  WriteCoordinatorConfig(lCoordinatorFile,
    '/opt/mera/RecorderCoordinator/opt/mera/RecorderCoordinator' +
    '/var/opt/mera/RecorderLnx/config/projects/default/sql-db.ini' +
    '/codex-missing-fixture');
  lConfig := TCoordinatorConfig.Create(lCoordinatorFile);
  try
    lConfig.Load;
    Check(SameFileName(lConfig.SqlDbConfigFile, lSqlFile),
      'existing adjacent SQL config was not selected');
  finally
    lConfig.Free;
  end;
  lIni := TIniFile.Create(lCoordinatorFile);
  try
    lSaved := lIni.ReadString('events', 'sql_db_config', '');
  finally
    lIni.Free;
  end;
  Check(SameFileName(lSaved, lSqlFile),
    'repaired SQL config path was not persisted');
end;

procedure CheckUnixAbsolutePath;
const
  EXPECTED = '/srv/recorder/config/sql-db.ini';
begin
  Check(IsAbsoluteConfigPath(EXPECTED),
    'Unix absolute path was treated as relative');
  Check(not IsAbsoluteConfigPath('config/sql-db.ini'),
    'relative path was treated as absolute');
end;

procedure CheckAppConfigIsNotProjectConfig(const ADirectory: string);
var
  lAppFile, lProjectDir, lProjectSql, lCoordinatorFile: string;
  lIni: TIniFile;
  lConfig: TCoordinatorConfig;
begin
  lAppFile := IncludeTrailingPathDelimiter(ADirectory) + 'app.ini';
  lProjectDir := IncludeTrailingPathDelimiter(ADirectory) + 'my-project';
  ForceDirectories(lProjectDir);
  lProjectSql := IncludeTrailingPathDelimiter(lProjectDir) + 'sql-db.ini';
  Touch(lProjectSql);
  lIni := TIniFile.Create(lAppFile);
  try
    lIni.WriteString('SQLdbConnection', 'Host', '192.0.2.42');
    lIni.WriteString('Application', 'DefaultProjectConfigDir', 'my-project');
  finally
    lIni.Free;
  end;
  lCoordinatorFile := IncludeTrailingPathDelimiter(ADirectory) + 'panel.ini';
  WriteCoordinatorConfig(lCoordinatorFile, lAppFile);
  lConfig := TCoordinatorConfig.Create(lCoordinatorFile);
  try
    lConfig.Load;
    Check(SameFileName(lConfig.SqlDbConfigFile, lProjectSql),
      'app.ini was incorrectly used as project SQL settings');
    lConfig.Save;
  finally
    lConfig.Free;
  end;
  lIni := TIniFile.Create(lCoordinatorFile);
  try
    Check(SameFileName(lIni.ReadString('events', 'sql_db_config', ''),
      lAppFile), 'panel copied and froze the selected project path');
  finally
    lIni.Free;
  end;
  lIni := TIniFile.Create(lAppFile);
  try
    Check(lIni.ReadString('SQLdbConnection', 'Host', '') = '192.0.2.42',
      'global connection was modified');
    Check(not lIni.SectionExists('SQLdb'), 'project section leaked into app.ini');
  finally
    lIni.Free;
  end;
  lIni := TIniFile.Create(lAppFile);
  try
    lIni.WriteString('Application', 'DefaultProjectConfigDir', 'another-project');
  finally
    lIni.Free;
  end;
  lConfig := TCoordinatorConfig.Create(lCoordinatorFile);
  try
    lConfig.Load;
    Check(SameFileName(lConfig.SqlDbConfigFile,
      IncludeTrailingPathDelimiter(ADirectory) + 'another-project' +
      DirectorySeparator + 'sql-db.ini'),
      'panel did not follow the new default project');
  finally
    lConfig.Free;
  end;
end;

procedure CheckSharedInstalledPaths(const ADirectory: string);
var
  lCoordinatorDir, lRecorderDir, lMeraRoot, lFile, lAppFile, lProjectFile,
    lLegacySql, lExpectedSql, lExplicitSql: string;
  lIni: TIniFile;
  lConfig: TCoordinatorConfig;
  lSql: TRecorderSqlDbConfig;
begin
  if GetEnvironmentVariable('MERA_FILES') <> '' then Exit;
  lCoordinatorDir := IncludeTrailingPathDelimiter(ADirectory) + 'RecorderCoordinator';
  lRecorderDir := IncludeTrailingPathDelimiter(ADirectory) + 'RecorderLnx';
  lMeraRoot := IncludeTrailingPathDelimiter(ADirectory) + 'shared-mera';
  ForceDirectories(lCoordinatorDir);
  ForceDirectories(lRecorderDir);
  ForceDirectories(lMeraRoot);
  lIni := TIniFile.Create(IncludeTrailingPathDelimiter(lRecorderDir) +
    'RecorderLnx.paths.ini');
  try
    lIni.WriteString('Paths', 'MeraFiles', '..' + DirectorySeparator +
      'shared-mera');
  finally
    lIni.Free;
  end;
  lFile := IncludeTrailingPathDelimiter(lCoordinatorDir) + 'RecorderCoordinator.ini';
  lConfig := TCoordinatorConfig.Create(lFile);
  try
    lAppFile := IncludeTrailingPathDelimiter(lMeraRoot) + 'RecorderLnx' +
      DirectorySeparator + 'app.ini';
    Check(SameFileName(RecorderAppConfigFileName, lAppFile),
      'panel did not use RecorderLnx shared app.ini');
    ForceDirectories(ExtractFileDir(lAppFile));
    lIni := TIniFile.Create(lAppFile);
    try
      lIni.WriteString('SQLdbConnection', 'Host', '192.0.2.92');
      lIni.WriteString('Application', 'DefaultProjectConfigDir', 'active-project');
    finally
      lIni.Free;
    end;
    lProjectFile := IncludeTrailingPathDelimiter(ADirectory) + 'sql-db.ini';
    lSql := TRecorderSqlDbConfig.Create;
    try
      lSql.LoadFromFile(lProjectFile);
      Check(lSql.Host = '192.0.2.92', 'panel used incorrect SQL host');
    finally
      lSql.Free;
    end;
    lLegacySql := IncludeTrailingPathDelimiter(RecorderDefaultProjectConfigDir) +
      'sql-db.ini';
    ForceDirectories(ExtractFileDir(lLegacySql));
    Touch(lLegacySql);
    lExpectedSql := ExtractFileDir(lAppFile) + DirectorySeparator +
      'active-project' + DirectorySeparator + 'sql-db.ini';
    WriteCoordinatorConfig(lFile, lLegacySql);
    lConfig.Load;
    Check(SameFileName(lConfig.SqlDbConfigFile, lExpectedSql),
      'automatic legacy default did not follow the active project');
    lConfig.Save;
    lIni := TIniFile.Create(lFile);
    try
      Check(SameFileName(lIni.ReadString('events', 'sql_db_config', ''), lAppFile),
        'legacy default was not converted to an app pointer');
    finally
      lIni.Free;
    end;
    lExplicitSql := IncludeTrailingPathDelimiter(ADirectory) + 'explicit' +
      DirectorySeparator + 'sql-db.ini';
    ForceDirectories(ExtractFileDir(lExplicitSql));
    Touch(lExplicitSql);
    WriteCoordinatorConfig(lFile, lExplicitSql);
    lConfig.Load;
    Check(SameFileName(lConfig.SqlDbConfigFile, lExplicitSql),
      'explicit project SQL path was unexpectedly changed');
  finally
    lConfig.Free;
  end;
end;

procedure CheckMissingProjectDoesNotWriteToApp(const ADirectory: string);
var
  lRoot, lApp, lPanel, lExpected: string;
  lIni: TIniFile;
  lConfig: TCoordinatorConfig;
begin
  lRoot := IncludeTrailingPathDelimiter(ADirectory) + 'missing-project-case';
  ForceDirectories(lRoot);
  lApp := IncludeTrailingPathDelimiter(lRoot) + 'app.ini';
  lPanel := IncludeTrailingPathDelimiter(lRoot) + 'panel.ini';
  lExpected := IncludeTrailingPathDelimiter(lRoot) + 'missing' +
    DirectorySeparator + 'sql-db.ini';
  lIni := TIniFile.Create(lApp);
  try
    lIni.WriteString('Application', 'DefaultProjectConfigDir', 'missing');
  finally
    lIni.Free;
  end;
  WriteCoordinatorConfig(lPanel, lApp);
  lConfig := TCoordinatorConfig.Create(lPanel);
  try
    lConfig.Load;
    Check(SameFileName(lConfig.SqlDbConfigFile, lExpected),
      'missing project fell back to app.ini or another project');
  finally
    lConfig.Free;
  end;
end;

var
  lDirectory: string;
begin
  lDirectory := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-coordinator-config-path-' + IntToStr(GetProcessID);
  ForceDirectories(lDirectory);
  CheckSharedInstalledPaths(lDirectory);
  CheckLegacyRepair(lDirectory);
  CheckUnixAbsolutePath;
  CheckAppConfigIsNotProjectConfig(lDirectory);
  CheckMissingProjectDoesNotWriteToApp(lDirectory);
  WriteLn('RESULT CoordinatorConfigPathTest passed');
end.
