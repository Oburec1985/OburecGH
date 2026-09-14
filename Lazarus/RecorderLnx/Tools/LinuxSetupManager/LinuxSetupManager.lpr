program LinuxSetupManager;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, uLinuxSetupManagerMain;

begin
  RequireDerivedFormResource := False;
  Application.Initialize;
  Application.CreateForm(TLinuxSetupManagerForm, LinuxSetupManagerForm);
  Application.Run;
end.
