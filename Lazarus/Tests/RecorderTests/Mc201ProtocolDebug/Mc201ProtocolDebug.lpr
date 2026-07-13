program Mc201ProtocolDebug;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Interfaces, Forms, SysUtils, uMc201ProtocolDebugRunner, uMc032DebugForm;

function HasCliSwitch: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), '--cli') or SameText(ParamStr(I), '--help') or
      SameText(ParamStr(I), '-h') then
      Exit(True);
end;

begin
  if HasCliSwitch then
    Halt(RunMc201ProtocolDebug(ParamStr(0)))
  else
  begin
    RequireDerivedFormResource := False;
    Application.Scaled := True;
    Application.Initialize;
    Application.CreateForm(TMc032DebugForm, Mc032DebugForm);
    Application.Run;
  end;
end.
