program RecorderSqlDbPathTest;

{$mode objfpc}{$H+}

uses SysUtils, uRecorderSqlDbTypes;

var
  lConfig: TRecorderSqlDbConfig;
begin
  lConfig := TRecorderSqlDbConfig.Create;
  try
    lConfig.Backend := rsbFirebird;
    lConfig.Host := '';
    lConfig.RootDirectory := '/home/example/selected';
    lConfig.Database := 'recorderlnx.fdb';
    {$ifdef unix}
    if lConfig.DatabaseFileName <> '/home/example/selected/recorderlnx.fdb' then
      raise Exception.Create('The selected home directory was not preserved');
    lConfig.Database := '/mnt/sda1/base/recorderlnx.fdb';
    if lConfig.DatabaseFileName <> '/mnt/sda1/base/recorderlnx.fdb' then
      raise Exception.Create('The absolute database path was not preserved');
    {$endif}
    WriteLn('OK: SQL database path');
  finally
    lConfig.Free;
  end;
end.
