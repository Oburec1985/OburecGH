program NetworkPathResolveProbe;
{$mode objfpc}{$H+}
uses SysUtils, uRecorderNetworkPathResolver;
begin
  if ParamCount <> 1 then Halt(2);
  WriteLn(ResolveRecorderNetworkPath(ParamStr(1)));
end.
