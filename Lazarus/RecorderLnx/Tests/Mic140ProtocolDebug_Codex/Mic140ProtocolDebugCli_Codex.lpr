program Mic140ProtocolDebugCli_Codex;

{
  Headless MIC-140 acceptance runner for the Codex debug folder.

  It intentionally reuses the proven Mic140ProtocolDebug stand units, but builds
  the executable and reads Data\mic140_adc_reference.txt from this folder.
}

{$mode objfpc}{$H+}

uses
  SysUtils, Interfaces,
  uMic140AutoRunner;

begin
  if Mic140TryRunMdpProxyFromCommandLine then
    Exit;
  if (ParamCount >= 1) and (Copy(ParamStr(1), 1, 2) = '--') then
    ExitCode := Mic140RunAutoTestFromCommandLine
  else if ParamCount >= 1 then
    ExitCode := Mic140RunAutoTest(StrToIntDef(ParamStr(1), 3))
  else
    ExitCode := Mic140RunAutoTest(3);
end.

