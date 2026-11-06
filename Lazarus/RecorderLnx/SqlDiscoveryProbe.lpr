program SqlDiscoveryProbe;
{$mode objfpc}{$H+}
{$codepage UTF8}
uses Interfaces, Forms, Controls, SysUtils, uRecorderSqlDbTypes, uRecorderSqlDbSettingsDialog;
var D: TRecorderSqlDbSettingsDialog;
begin
  Application.Initialize;
  D := TRecorderSqlDbSettingsDialog.Create(nil);
  try
    D.LoadConfig('/tmp/recorder-sql-discovery-probe.ini', nil);
    D.cbBackend.ItemIndex := Ord(rsbFirebird);
    D.edHost.Text := '192.168.9.92';
    D.edDatabase.Text := '';
    D.btnOkClick(nil);
    WriteLn('path=', D.edDatabase.Text);
    WriteLn('result=', D.ModalResult);
    if (D.edDatabase.Text <> '/mnt/sda1/base/firebird/recorderlnx.fdb') or
       (D.ModalResult <> mrOk) then Halt(1);
  finally D.Free; end;
end.
