program Mic140ProtocolDebugCli;

{
  Упрощённая консольная обёртка над uMic140AutoRunner.

  Использование:
    Mic140ProtocolDebugCli.exe [--auto [N]] [--fifo-stride 48|51] ...
    Mic140ProtocolDebugCli.exe --proxy [listenPort] [deviceHost] [devicePort]
    Mic140ProtocolDebugCli.exe [секунды]  — только длительность, конфиг по умолчанию
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
