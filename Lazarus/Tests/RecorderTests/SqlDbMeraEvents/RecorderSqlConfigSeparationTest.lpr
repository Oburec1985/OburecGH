program RecorderSqlConfigSeparationTest;

{$mode objfpc}{$H+}

uses Classes, SysUtils, IniFiles, uRecorderMeraPaths, uRecorderSqlDbTypes;

procedure Check(AValue: Boolean; const AText: string);
begin
  if not AValue then raise Exception.Create(AText);
end;

var
  lApp, lProject: string;
  lIni: TIniFile;
  lConfig, lReload: TRecorderSqlDbConfig;
  lRejected: Boolean;
begin
  if (ParamCount <> 1) or (Copy(ParamStr(1), 1, 5) <> '/cfg:') then
    raise Exception.Create('Pass /cfg: with an isolated temporary app.ini');
  lApp := RecorderAppConfigFileName;
  Check(not FileExists(lApp), 'app fixture must not exist');
  lProject := IncludeTrailingPathDelimiter(ExtractFileDir(lApp)) + 'project-sql.ini';
  Check(not FileExists(lProject), 'project fixture must not exist');
  Check(ForceDirectories(ExtractFileDir(lApp)), 'cannot create fixture directory');
  lIni := TIniFile.Create(lApp);
  try
    lIni.WriteString('SQLdbConnection', 'Host', '192.0.2.9');
    lIni.WriteString('SQLdbConnection', 'Database', '/old/effective.fdb');
    lIni.WriteString('SQLdbConnection', 'LocalDatabase', '/local/test.fdb');
    lIni.WriteString('SQLdbConnection', 'RemoteDatabase', '/remote/test.fdb');
    lIni.WriteString('SQLdbConnection', 'RemoteDatabaseHost', '192.0.2.9');
    lIni.UpdateFile;
  finally lIni.Free; end;
  lIni := TIniFile.Create(lProject);
  try
    lIni.WriteString('SQLdb', 'Host', '192.0.2.88');
    lIni.WriteString('SQLdb', 'Database', '/old/project.fdb');
    lIni.WriteString('SQLdb', 'ControlTag', 'TestEnable');
    lIni.UpdateFile;
  finally lIni.Free; end;
  lConfig := TRecorderSqlDbConfig.Create;
  lReload := TRecorderSqlDbConfig.Create;
  try
    lConfig.LoadFromFile(lProject);
    Check(lConfig.Host = '192.0.2.9', 'application host must override legacy project host');
    Check(lConfig.Database = '/remote/test.fdb', 'remote path precedence');
    Check(lConfig.LocalDatabase = '/local/test.fdb', 'local path precedence');
    Check(lConfig.ControlTagName = 'TestEnable', 'project setting lost');
    lConfig.SaveToFile(lProject);
    lIni := TIniFile.Create(lApp);
    try
      Check(not lIni.ValueExists('SQLdbConnection', 'Database'), 'duplicate database alias');
      Check(not lIni.SectionExists('SQLdb'), 'project settings leaked into app file');
      Check(lIni.ReadString('SQLdbConnection', 'RemoteDatabase', '') = '/remote/test.fdb',
        'remote database was not saved');
    finally lIni.Free; end;
    lIni := TIniFile.Create(lProject);
    try
      Check(not lIni.ValueExists('SQLdb', 'Host'), 'legacy project host not migrated');
      Check(not lIni.ValueExists('SQLdb', 'Database'), 'legacy project database not migrated');
      Check(lIni.ReadString('SQLdb', 'ControlTag', '') = 'TestEnable', 'project tag lost');
    finally lIni.Free; end;
    lReload.LoadFromFile(lProject);
    Check((lReload.Host = lConfig.Host) and (lReload.Database = lConfig.Database) and
      (lReload.LocalDatabase = lConfig.LocalDatabase), 'round trip changed connection');
    lReload.SaveToFile(lProject);
    lConfig.LoadFromFile(lProject);
    Check((lConfig.LocalDatabase = '/local/test.fdb') and
      (lConfig.Database = '/remote/test.fdb') and (lConfig.Host = '192.0.2.9'),
      'repeated migration overwrote canonical values');
    lRejected := False;
    try lConfig.SaveToFile(lApp);
    except on E: ERecorderSqlDbError do lRejected := True; end;
    Check(lRejected, 'saving project into application config was allowed');
    lIni := TIniFile.Create(lApp);
    try Check(not lIni.SectionExists('SQLdb'), 'rejected save changed app config');
    finally lIni.Free; end;
    { A project from an older installation can provide the connection when
      the application has none. Saving migrates it without losing settings. }
    lIni := TIniFile.Create(lApp);
    try lIni.EraseSection('SQLdbConnection'); lIni.UpdateFile;
    finally lIni.Free; end;
    lIni := TIniFile.Create(lProject);
    try
      lIni.WriteString('SQLdb', 'Host', '192.0.2.88');
      lIni.WriteString('SQLdb', 'Database', '/old/project.fdb');
      lIni.UpdateFile;
    finally lIni.Free; end;
    lReload.LoadFromFile(lProject);
    Check((lReload.Host = '192.0.2.88') and
      (lReload.Database = '/old/project.fdb'), 'legacy-only project not loaded');
    lReload.SaveToFile(lProject);
    lConfig.LoadFromFile(lProject);
    Check((lConfig.Host = '192.0.2.88') and
      (lConfig.Database = '/old/project.fdb'), 'legacy-only migration lost connection');
    lIni := TIniFile.Create(lProject);
    try
      Check(not lIni.ValueExists('SQLdb', 'Host'), 'migrated legacy host remains in project');
      Check(not lIni.ValueExists('SQLdb', 'Database'), 'migrated legacy database remains in project');
    finally lIni.Free; end;
    { Older global files stored only the effective Database value. }
    lIni := TIniFile.Create(lApp);
    try
      lIni.EraseSection('SQLdbConnection');
      lIni.WriteString('SQLdbConnection', 'Host', '192.0.2.77');
      lIni.WriteString('SQLdbConnection', 'Database', '/legacy/app.fdb');
      lIni.UpdateFile;
    finally lIni.Free; end;
    lConfig.LoadFromFile(lProject);
    Check((lConfig.Host = '192.0.2.77') and
      (lConfig.Database = '/legacy/app.fdb'), 'legacy global Database not loaded');
    lConfig.SaveToFile(lProject);
    lReload.LoadFromFile(lProject);
    Check(lReload.Database = '/legacy/app.fdb', 'legacy global Database lost on migration');
    { Non-Firebird legacy credentials must not be silently discarded. }
    lIni := TIniFile.Create(lApp);
    try
      lIni.WriteString('SQLdbConnection', 'Backend', 'postgresql');
      lIni.UpdateFile;
    finally lIni.Free; end;
    lIni := TIniFile.Create(lProject);
    try
      lIni.WriteString('SQLdb', 'UserName', 'test-user');
      lIni.WriteString('SQLdb', 'PasswordEnvironment', 'TEST_DATABASE_PASSWORD');
      lIni.WriteString('SQLdb', 'Password', 'fixture-only');
      lIni.UpdateFile;
    finally lIni.Free; end;
    lConfig.LoadFromFile(lProject);
    Check((lConfig.Backend = rsbPostgreSQL) and (lConfig.UserName = 'test-user') and
      (lConfig.StoredPassword = 'fixture-only'), 'legacy PostgreSQL credentials not loaded');
    lConfig.SaveToFile(lProject);
    lReload.LoadFromFile(lProject);
    Check((lReload.UserName = 'test-user') and (lReload.StoredPassword = 'fixture-only') and
      (lReload.PasswordEnvironment = 'TEST_DATABASE_PASSWORD'), 'PostgreSQL credentials lost');
    WriteLn('RESULT RecorderSqlConfigSeparationTest passed');
  finally
    lReload.Free;
    lConfig.Free;
  end;
end.
