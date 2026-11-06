program NetworkPathHostIsolationTest;
{$mode objfpc}{$H+}
uses SysUtils, uRecorderNetworkPathResolver;
const MissingUri = 'smb://nonexistent-recorder/USML/0001/0001.mera';
begin
  if ResolveRecorderNetworkPath(MissingUri) <> MissingUri then
    raise Exception.Create('An unresolved SMB URI must retain its host and share');
  WriteLn('Network path host isolation OK');
end.
