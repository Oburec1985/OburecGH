program Mc201ProtocolDebug;

{$mode objfpc}{$H+}
{$codepage UTF8}

{$IFDEF MSWINDOWS}
{$R resources/mc201_protocol_debug.rc}
{$ENDIF}

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

function HasSwitch(const AName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), AName) then
      Exit(True);
end;

begin
  if HasCliSwitch then
    Halt(RunMc201ProtocolDebug(ParamStr(0)))
  else if HasSwitch('--gui-connect-on-create-test') then
  begin
    { Регрессионный режим: создать GUI-форму и выполнить тот же connect,
      что у кнопки, но выйти без входа в цикл сообщений. }
    RequireDerivedFormResource := False;
    Application.Scaled := True;
    Application.Initialize;
    Application.ShowMainForm := False;
    Mc032EnableConnectOnCreateTest;
    Application.CreateForm(TMc032DebugForm, Mc032DebugForm);
    if Mc032ConnectOnCreateTestPassed then
    begin
      WriteLn('RESULT Mc201GuiConnectOnCreate passed: ' +
        Mc032ConnectOnCreateTestMessage);
      Halt(0);
    end
    else
    begin
      WriteLn('RESULT Mc201GuiConnectOnCreate failed: ' +
        Mc032ConnectOnCreateTestMessage);
      Halt(5);
    end;
  end
  else
  begin
    RequireDerivedFormResource := False;
    Application.Scaled := True;
    Application.Initialize;
    Application.CreateForm(TMc032DebugForm, Mc032DebugForm);
    Application.Run;
  end;
end.
