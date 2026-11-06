program SqlDbPathDialogProbe;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}cthreads, cwstring,{$ENDIF}
  Interfaces, Forms, SysUtils, IniFiles, uRecorderMeraPaths,
  uRecorderSqlDbSettingsDialog, uRecorderSqlDbTypes;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

var
  lDialog: TRecorderSqlDbSettingsDialog;
  lIni: TIniFile;
  lAppFile, lProjectFile, lOwnIp: string;
begin
  Application.Initialize;
  Check((ParamCount > 0) and (Copy(ParamStr(1), 1, 5) = '/cfg:'),
    'isolated /cfg: fixture is required');
  lAppFile := RecorderAppConfigFileName;
  if (ParamCount >= 3) and (ParamStr(2) = '--readonly') then
  begin
    lDialog := TRecorderSqlDbSettingsDialog.Create(nil);
    try
      lDialog.LoadConfig(ParamStr(3), nil);
      WriteLn('HOST=', lDialog.edHost.Text);
      WriteLn('DATABASE=', lDialog.edDatabase.Text);
      WriteLn('LOCAL=', BoolToStr(lDialog.edRoot.Visible, True));
      if ParamCount >= 4 then
        Check(lDialog.edRoot.Visible = (ParamStr(4) = 'local'), 'unexpected dialog path mode');
      if ParamCount >= 5 then
        Check(lDialog.edDatabase.Text = ParamStr(5), 'unexpected displayed database path');
      WriteLn('RESULT SqlDbPathDialogProbe readonly passed');
    finally
      lDialog.Free;
    end;
    Halt(0);
  end;
  ForceDirectories(ExtractFileDir(lAppFile));
  lProjectFile := ExtractFilePath(lAppFile) + 'project-sql.ini';
  lIni := TIniFile.Create(lAppFile);
  try
    lIni.WriteString('SQLdbConnection', 'Backend', 'firebird');
    lIni.WriteString('SQLdbConnection', 'RootDirectory', '/mnt/sda1/base');
    lIni.WriteString('SQLdbConnection', 'LocalDatabase', '/mnt/sda1/base/firebird/local.fdb');
    lIni.WriteString('SQLdbConnection', 'RemoteDatabase', '/srv/database/server.fdb');
    lIni.WriteString('SQLdbConnection', 'RemoteDatabaseHost', '192.0.2.92');
    lIni.WriteString('SQLdbConnection', 'Database', '/srv/database/server.fdb');
    lIni.WriteString('SQLdbConnection', 'Host', '192.0.2.92');
  finally
    lIni.Free;
  end;
  lDialog := TRecorderSqlDbSettingsDialog.Create(nil);
  try
    lDialog.LoadConfig(lProjectFile, nil);
    lDialog.Show;
    Application.ProcessMessages;
    Check(lDialog.edDatabase.Text = '/srv/database/server.fdb', 'remote path not shown');
    Check(not lDialog.edRoot.Visible, 'remote root browse should be hidden');
    lDialog.edHost.Text := '';
    Check(lDialog.edDatabase.Text = '/mnt/sda1/base/firebird/local.fdb', 'blank host not local');
    Check(lDialog.edRoot.Visible and lDialog.btnBrowse.Visible, 'local root browse unavailable');
    lDialog.edDatabase.Text := '/mnt/sda1/base/firebird/local-edited.fdb';
    lOwnIp := GetEnvironmentVariable('SQL_DIALOG_LOCAL_IP');
    Check(lOwnIp <> '', 'SQL_DIALOG_LOCAL_IP is required');
    lDialog.edHost.Text := lOwnIp;
    Check(RecorderSqlDbHostIsLocal(lOwnIp), 'own IP not recognized');
    Check(lDialog.edDatabase.Text = '/mnt/sda1/base/firebird/local-edited.fdb', 'own IP lost local draft');
    Check(lDialog.edRoot.Visible, 'own IP treated as remote in UI');
    lDialog.edHost.Text := '192.0.2.93';
    Check(lDialog.edDatabase.Text = '', 'unknown server invented a database path');
    lDialog.edHost.Text := '192.0.2.92';
    Check(lDialog.edDatabase.Text = '/srv/database/server.fdb', 'known server lost remote draft');
    lDialog.edHost.Text := lOwnIp;
    lDialog.btnOkClick(nil);
    lDialog.LoadConfig(lProjectFile, nil);
    Check(lDialog.edDatabase.Text = '/mnt/sda1/base/firebird/local-edited.fdb', 'local save/reload lost path');
    lDialog.edHost.Text := '192.0.2.92';
    Check(lDialog.edDatabase.Text = '/srv/database/server.fdb', 'save/reload lost remote server path');
    WriteLn('RESULT SqlDbPathDialogProbe passed');
  finally
    lDialog.Free;
  end;
end.
