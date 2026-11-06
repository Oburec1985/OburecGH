program CoordinatorFirebirdHostPersistenceTest;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, IniFiles, uCoordinatorConfig;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

function FixtureDirectory: string;
var
  lIndex: Integer;
  lConfigArgument: string;
begin
  Result := '';
  lConfigArgument := '';
  for lIndex := 1 to ParamCount do
  begin
    if Copy(ParamStr(lIndex), 1, 10) = '--fixture=' then
      Result := ExpandFileName(Copy(ParamStr(lIndex), 11, MaxInt));
    if Copy(ParamStr(lIndex), 1, 5) = '/cfg:' then
      lConfigArgument := ExpandFileName(Copy(ParamStr(lIndex), 6, MaxInt));
  end;
  Check(Result <> '', 'Pass --fixture=<temporary directory>');
  Result := IncludeTrailingPathDelimiter(Result);
  Check(SameFileName(lConfigArgument, Result + 'app.ini'),
    'The test requires /cfg:<fixture>/app.ini to isolate shared paths');
end;

procedure WriteFixture(const ADirectory, APanelFile: string);
var
  lIni: TIniFile;
begin
  ForceDirectories(ADirectory + 'mera');
  lIni := TIniFile.Create(ADirectory + 'app.ini');
  try
    lIni.WriteString('Paths', 'MeraFiles', ADirectory + 'mera');
    lIni.WriteString('SQLdbConnection', 'Host', '192.168.9.66');
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
  lIni := TIniFile.Create(APanelFile);
  try
    lIni.WriteString('events', 'sql_db_config', ADirectory + 'app.ini');
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
end;

procedure CheckPersistence(const APanelFile: string);
var
  lConfig: TCoordinatorConfig;
  lIni: TIniFile;
begin
  lConfig := TCoordinatorConfig.Create(APanelFile);
  try
    lConfig.Load;
    Check(lConfig.FirebirdHost = '',
      'Legacy panel without a selection must allow the SQL configuration fallback');
    lConfig.FirebirdHost := '192.168.9.92';
    lConfig.Save;
  finally
    lConfig.Free;
  end;

  lConfig := TCoordinatorConfig.Create(APanelFile);
  try
    lConfig.Load;
    Check(lConfig.FirebirdHost = '192.168.9.92',
      'The selected Firebird host was lost across panel restart');
    lConfig.EventWindowSec := 45;
    lConfig.Save;
  finally
    lConfig.Free;
  end;

  lIni := TIniFile.Create(APanelFile);
  try
    Check(lIni.ReadString('events', 'firebird_host', '') = '192.168.9.92',
      'Saving unrelated settings overwrote the selected Firebird host');
  finally
    lIni.Free;
  end;

  lConfig := TCoordinatorConfig.Create(APanelFile);
  try
    lConfig.Load;
    Check(lConfig.FirebirdHost = '192.168.9.92',
      'A later restart reverted to the old SQL default');
  finally
    lConfig.Free;
  end;
end;

var
  lDirectory, lPanelFile: string;
begin
  lDirectory := FixtureDirectory;
  lPanelFile := lDirectory + 'panel.ini';
  WriteFixture(lDirectory, lPanelFile);
  CheckPersistence(lPanelFile);
  WriteLn('RESULT CoordinatorFirebirdHostPersistenceTest passed');
end.
