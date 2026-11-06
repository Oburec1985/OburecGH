program RecorderNetworkConfigTest;

{$mode objfpc}{$H+}

uses SysUtils, IniFiles, uRecorderMeraPaths, uRecorderNetworkBinding;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

const
  CLegacy = '192.0.2.123';
var
  lFile: string;
  lIni: TIniFile;
begin
  lFile := RecorderAppConfigFileName;
  Check(Pos('recorder-network-config-fixture', LowerCase(lFile)) > 0,
    'test requires an isolated /cfg: fixture');
  Check(not FileExists(lFile), 'fixture must start absent');
  RecorderLoadNetworkBindAddress(CLegacy, True);
  Check(not FileExists(lFile), 'reading legacy must not write app.ini');
  Check(RecorderNetworkConfiguredBindAddress = CLegacy,
    'configured value lost while interface is unavailable');
  Check(RecorderNetworkBindAddress = '', 'unavailable interface must use OS routing');
  Check(RecorderMigrateLegacyNetworkBindAddress(CLegacy), 'migration missing');
  Check(RecorderNetworkHasPersistedBindAddress, 'migration was not persisted');
  RecorderLoadNetworkBindAddress('198.51.100.24', True);
  Check(RecorderNetworkConfiguredBindAddress = CLegacy,
    'another project overrode local preference');
  Check(not RecorderMigrateLegacyNetworkBindAddress('198.51.100.24'),
    'existing preference must not be overwritten');
  RecorderSaveNetworkBindAddress;
  lIni := TIniFile.Create(lFile);
  try
    Check(lIni.ReadString('Network', 'BindAddress', '') = CLegacy,
      'saving lost unavailable address');
    lIni.WriteString('Network', 'BindAddress', '');
  finally lIni.Free; end;
  RecorderLoadNetworkBindAddress(CLegacy, True);
  Check(RecorderNetworkConfiguredBindAddress = '',
    'explicit automatic selection must win over project legacy');
  WriteLn('OK: network config migration and application precedence');
end.
