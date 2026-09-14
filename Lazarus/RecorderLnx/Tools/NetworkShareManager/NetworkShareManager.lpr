program NetworkShareManager;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, uNetworkShareManagerMain;

begin
  RequireDerivedFormResource := False;
  Application.Initialize;
  Application.CreateForm(TNetworkShareManagerForm, NetworkShareManagerForm);
  Application.Run;
end.
