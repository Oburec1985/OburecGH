program LinuxSetupManager;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, uLinuxSetupManagerMain, uLinuxSetupManagerEmbedded;

begin
  if (ParamCount > 0) and (ParamStr(1) = '--internal') then
    Halt(RunEmbedded(2));
  RequireDerivedFormResource := False;
  Application.Initialize;
  Application.CreateForm(TLinuxSetupManagerForm, LinuxSetupManagerForm);
  Application.Run;
end.
