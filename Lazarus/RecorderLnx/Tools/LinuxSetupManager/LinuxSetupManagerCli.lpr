program LinuxSetupManagerCli;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  uLinuxSetupManagerCli, uLinuxSetupManagerEmbedded;

begin
  SetMultiByteConversionCodePage(CP_UTF8);
  SetTextCodePage(Input, CP_UTF8);
  SetTextCodePage(Output, CP_UTF8);
  SetTextCodePage(StdErr, CP_UTF8);
  if (ParamCount > 0) and (ParamStr(1) = '--internal') then
    Halt(RunEmbedded(2));
  Halt(RunLinuxSetupCli);
end.
