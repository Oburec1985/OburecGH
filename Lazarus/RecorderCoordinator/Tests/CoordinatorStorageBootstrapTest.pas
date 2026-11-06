program CoordinatorStorageBootstrapTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, Classes, IniFiles, uCoordinatorConfig, uRecorderMeraPaths,
  uRecorderSqlDbTypes;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

var
  lRoot, lPanelDir, lRecorderDir, lBootstrap, lRuntime, lService, lApp,
    lStorage, lDefaultSql, lExpectedSql, lPanelIni: string;
  lIni: TIniFile;
  lConfig: TCoordinatorConfig;
  lMissing, lInvalid, lLegacy, lRejected: Boolean;
begin
  if GetEnvironmentVariable('MERA_FILES') <> '' then
    raise Exception.Create('Run with MERA_FILES unset');
  lMissing := (ParamCount > 0) and (ParamStr(1) = '--missing');
  lInvalid := (ParamCount > 0) and (ParamStr(1) = '--invalid');
  lLegacy := (ParamCount > 0) and (ParamStr(1) = '--legacy');
  lRoot := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'coordinator-storage-bootstrap-' + IntToStr(GetProcessID);
  lPanelDir := lRoot + DirectorySeparator + 'RecorderCoordinator';
  lRecorderDir := lRoot + DirectorySeparator + 'RecorderLnx';
  lBootstrap := lRoot + DirectorySeparator + 'bootstrap';
  lRuntime := lRoot + DirectorySeparator + 'runtime';
  lService := lBootstrap + DirectorySeparator + 'RecorderLnx';
  lApp := lService + DirectorySeparator + 'app.ini';
  lStorage := lService + DirectorySeparator + 'storage.ini';
  lPanelIni := lPanelDir + DirectorySeparator + 'RecorderCoordinator.ini';
  lDefaultSql := lService + DirectorySeparator + 'config' + DirectorySeparator +
    'projects' + DirectorySeparator + 'default' + DirectorySeparator + 'sql-db.ini';
  lExpectedSql := lService + DirectorySeparator + 'active' + DirectorySeparator + 'sql-db.ini';
  ForceDirectories(lPanelDir);
  ForceDirectories(lRecorderDir);
  ForceDirectories(lRuntime);
  ForceDirectories(lService);
  lIni := TIniFile.Create(lRecorderDir + DirectorySeparator + 'RecorderLnx.paths.ini');
  try lIni.WriteString('Paths', 'MeraFiles', lBootstrap); finally lIni.Free; end;
  lIni := TIniFile.Create(lApp);
  try
    lIni.WriteString('Application', 'DefaultProjectConfigDir', 'active');
    lIni.WriteString('SQLdbConnection', 'Host', '192.0.2.92');
  finally lIni.Free; end;
  if not (lMissing or lLegacy) then
  begin
    lIni := TIniFile.Create(lStorage);
    try
      if lInvalid then lIni.WriteString('Storage', 'Other', 'value')
      else lIni.WriteString('Storage', 'MeraFilesPath', lRuntime);
    finally lIni.Free; end;
  end;
  if lLegacy then
  begin
    ForceDirectories(lService + DirectorySeparator + 'active');
    lIni := TIniFile.Create(lService + DirectorySeparator + 'active' +
      DirectorySeparator + 'default.run-control.ini');
    try lIni.WriteString('Mera', 'FilesPath', lRuntime); finally lIni.Free; end;
    lIni := TIniFile.Create(lService + DirectorySeparator + 'active' +
      DirectorySeparator + 'run-control.ini');
    try lIni.WriteString('Mera', 'FilesPath', lBootstrap); finally lIni.Free; end;
  end;
  lIni := TIniFile.Create(lPanelIni);
  try lIni.WriteString('events', 'sql_db_config', lDefaultSql); finally lIni.Free; end;
  if lInvalid then
  begin
    lRejected := False;
    try
      lConfig := TCoordinatorConfig.Create(lPanelIni);
      lConfig.Free;
    except
      on E: Exception do
        lRejected := Pos('incomplete', E.Message) > 0;
    end;
    Check(lRejected, 'invalid storage was silently ignored');
    WriteLn('RESULT CoordinatorStorageBootstrapTest invalid passed');
    Halt(0);
  end;
  lConfig := TCoordinatorConfig.Create(lPanelIni);
  try
    Check(SameFileName(RecorderAppConfigFileName, lApp),
      'app.ini moved away from bootstrap root');
    if lMissing then
    begin
      Check(not FileExists(lStorage), 'panel created machine storage');
      Check(SameFileName(RecorderMeraFilesPath, lBootstrap), 'bootstrap changed without storage');
    end
    else
    begin
      if lLegacy then Check(not FileExists(lStorage), 'legacy read created machine storage');
      Check(SameFileName(RecorderMeraFilesPath, lRuntime), 'runtime root not applied');
      Check(SameFileName(RecorderSqlDbDefaultRootDirectory,
        lRuntime + DirectorySeparator + 'SQLdb'), 'SQL default ignores runtime root');
    end;
    lConfig.Load;
    Check(SameFileName(lConfig.SqlDbConfigFile, lExpectedSql),
      'bootstrap default did not migrate to selected project');
  finally lConfig.Free; end;
  WriteLn('RESULT CoordinatorStorageBootstrapTest passed');
end.
