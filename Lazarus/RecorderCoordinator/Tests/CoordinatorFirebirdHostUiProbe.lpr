program CoordinatorFirebirdHostUiProbe;

{$mode objfpc}{$H+}{$codepage UTF8}

uses
  cthreads, Interfaces, Forms, Classes, SysUtils, IniFiles,
  uCoordinatorMainForm;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure PrepareFixture;
var
  lDirectory, lAppFile, lProjectFile: string;
  lIni: TIniFile;
begin
  lDirectory := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0)));
  lAppFile := lDirectory + 'app.ini';
  lProjectFile := lDirectory + 'project/sql-db.ini';
  Check((ParamCount = 1) and
    SameText(ParamStr(1), '/cfg:' + lAppFile),
    'Run with /cfg:<probe directory>/app.ini inside an isolated network namespace');
  ForceDirectories(ExtractFileDir(lProjectFile));
  lIni := TIniFile.Create(lAppFile);
  try
    lIni.WriteString('Paths', 'MeraFiles', lDirectory + 'mera');
    lIni.WriteString('Application', 'DefaultProjectConfigDir',
      ExtractFileDir(lProjectFile));
    lIni.WriteString('SQLdbConnection', 'Host', '192.168.9.66');
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
  lIni := TIniFile.Create(lProjectFile);
  try
    lIni.WriteBool('SQLdb', 'Enabled', False);
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
  DeleteFile(ChangeFileExt(ParamStr(0), '.ini'));
  lIni := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    lIni.WriteString('service', 'listen', '127.0.0.1');
    lIni.WriteInteger('service', 'port', 18967);
    lIni.WriteBool('events', 'create_recording_events', False);
    lIni.WriteString('events', 'sql_db_config', lProjectFile);
    lIni.WriteInteger('hosts', 'count', 0);
    lIni.WriteInteger('storages', 'count', 0);
    lIni.UpdateFile;
  finally
    lIni.Free;
  end;
end;

function OpenPanel: TCoordinatorMainForm;
begin
  Result := TCoordinatorMainForm.Create(nil);
  Result.timerRefresh.Enabled := False;
  Result.Show;
  Application.ProcessMessages;
end;

var
  lForm: TCoordinatorMainForm;
begin
  PrepareFixture;
  RequireDerivedFormResource := True;
  Application.Initialize;

  lForm := OpenPanel;
  try
    Check(lForm.edtDatabaseHost.Text = '192.168.9.66',
      'A legacy panel did not read the Firebird host from the SQL configuration');
    lForm.edtDatabaseHost.Text := '192.168.9.92';
    lForm.btnSetDatabaseForAllClick(nil);
  finally
    lForm.Free;
  end;

  lForm := OpenPanel;
  try
    Check(lForm.edtDatabaseHost.Text = '192.168.9.92',
      'The Firebird host field reverted after closing and reopening the panel');
    lForm.btnSaveClick(nil);
  finally
    lForm.Free;
  end;

  lForm := OpenPanel;
  try
    Check(lForm.edtDatabaseHost.Text = '192.168.9.92',
      'Saving unrelated settings lost the selected Firebird host');
  finally
    lForm.Free;
  end;
  WriteLn('RESULT CoordinatorFirebirdHostUiProbe passed');
end.
