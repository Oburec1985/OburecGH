program CoordinatorConfigPathTest;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, IniFiles, uCoordinatorConfig;

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
    '/var/opt/mera/RecorderLnx/config/projects/default/sql-db.ini');
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

var
  lDirectory: string;
begin
  lDirectory := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'recorder-coordinator-config-path-' + IntToStr(GetProcessID);
  ForceDirectories(lDirectory);
  CheckLegacyRepair(lDirectory);
  CheckUnixAbsolutePath;
  WriteLn('RESULT CoordinatorConfigPathTest passed');
end.
