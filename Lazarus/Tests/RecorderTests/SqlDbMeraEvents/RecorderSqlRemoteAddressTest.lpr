program RecorderSqlRemoteAddressTest;

{$mode objfpc}{$H+}

uses Classes, SysUtils, uRecorderSqlDbTypes, uRecorderNetworkBinding;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

var
  lConfig, lCopy: TRecorderSqlDbConfig;
  lRejected: Boolean;
  lAddresses: TStringList;
  lFile: string;
begin
  lConfig := TRecorderSqlDbConfig.Create;
  lCopy := TRecorderSqlDbConfig.Create;
  try
    lConfig.Backend := rsbFirebird;
    lConfig.RootDirectory := '/mnt/sda1/base';
    lConfig.LocalDatabase := '/mnt/sda1/base/firebird/recorderlnx.fdb';
    lConfig.UserName := CRecorderFirebirdDefaultUserName;
    lConfig.StoredPassword := CRecorderFirebirdDefaultPassword;
    lConfig.TlsRequired := True;
    lConfig.Enabled := False;
    lConfig.ApplyRemoteServerAddress(' 192.0.2.92 ', 3051,
      '/remote/server/data/recorderlnx.fdb');
    Check(lConfig.Host = '192.0.2.92', 'host not applied');
    Check(lConfig.Port = 3051, 'port not applied');
    Check(lConfig.RootDirectory = '/mnt/sda1/base', 'local root replaced');
    Check(lConfig.LocalDatabase = '/mnt/sda1/base/firebird/recorderlnx.fdb',
      'local database replaced');
    Check(lConfig.Database = '/remote/server/data/recorderlnx.fdb',
      'remote server database not selected');
    Check(lConfig.UserName = CRecorderFirebirdDefaultUserName, 'user changed');
    Check(lConfig.Password = CRecorderFirebirdDefaultPassword, 'password changed');
    Check(lConfig.TlsRequired and not lConfig.Enabled, 'other settings changed');
    lCopy.Assign(lConfig);
    Check(lCopy.Database = lConfig.Database, 'configuration copy lost database');
    lRejected := False;
    try lConfig.ApplyRemoteServerAddress('other-host', 65536);
    except on E: ERecorderSqlDbError do lRejected := True; end;
    Check(lRejected, 'invalid port accepted');
    Check((lConfig.Host = '192.0.2.92') and (lConfig.Port = 3051),
      'invalid port partially changed endpoint');
    lRejected := False;
    try lConfig.ApplyRemoteServerAddress(' ', 3050);
    except on E: ERecorderSqlDbError do lRejected := True; end;
    Check(lRejected, 'empty host accepted');
    Check((lConfig.Host = '192.0.2.92') and (lConfig.Port = 3051),
      'invalid host partially changed endpoint');
    lRejected := False;
    try lConfig.ApplyRemoteServerAddress('192.0.2.93', 3050);
    except on E: ERecorderSqlDbError do lRejected := True; end;
    Check(lRejected, 'unknown server reused another server database');
    Check(lConfig.Host = '192.0.2.92', 'unknown server partially changed endpoint');
    lConfig.Host := '192.0.2.93';
    Check(lConfig.Database = '', 'another server path shown for unknown host');
    lConfig.Host := '';
    Check(lConfig.Database = lConfig.LocalDatabase, 'empty host lost local database');
    lConfig.Host := '127.0.0.1';
    Check(lConfig.Database = lConfig.LocalDatabase, 'loopback lost local database');
    lAddresses := TStringList.Create;
    try
      RecorderEnumerateLocalIPv4(lAddresses);
      if lAddresses.Count > 1 then
      begin
        lConfig.Host := RecorderNetworkAddressFromDisplay(lAddresses[1]);
        Check(lConfig.IsLocalFileDatabase, 'own IP was treated as remote');
        Check(lConfig.Database = lConfig.LocalDatabase, 'own IP lost local database');
        lConfig.ApplyRemoteServerAddress(lConfig.Host, 3050, '/must/not/replace/local.fdb');
        Check(lConfig.LocalDatabase = '/mnt/sda1/base/firebird/recorderlnx.fdb',
          'server payload replaced local database through own IP');
      end;
    finally
      lAddresses.Free;
    end;
    lConfig.Host := '192.0.2.92';
    Check(lConfig.Database = '/remote/server/data/recorderlnx.fdb',
      'known remote path was lost after local switching');
    if (ParamCount > 0) and (Copy(ParamStr(1), 1, 5) = '/cfg:') then
    begin
      lFile := GetTempDir(False) + 'recorder-address-project-' +
        IntToHex(GetTickCount64, 16) + '.ini';
      try
        lConfig.SaveToFile(lFile);
        lCopy.LoadFromFile(lFile);
        Check(lCopy.LocalDatabase = lConfig.LocalDatabase,
          'save/reload lost local database');
        Check(lCopy.RemoteDatabase = lConfig.RemoteDatabase,
          'save/reload lost remote database');
        Check(lCopy.RemoteDatabaseHost = lConfig.RemoteDatabaseHost,
          'save/reload lost remote host association');
        lCopy.Host := '';
        Check(lCopy.Database = lConfig.LocalDatabase,
          'save/reload lost local selection');
      finally
        DeleteFile(lFile);
      end;
    end;
    WriteLn('RESULT RecorderSqlRemoteAddressTest passed');
  finally
    lCopy.Free;
    lConfig.Free;
  end;
end.
