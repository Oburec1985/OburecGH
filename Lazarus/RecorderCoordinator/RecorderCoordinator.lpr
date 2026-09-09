program RecorderCoordinator;

{$mode objfpc}{$H+}
{$IFDEF MSWINDOWS}
{$R resources/app/rcpanel_app.rc}
{$ENDIF}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces, Forms, SysUtils,
  uCoordinatorCli, uCoordinatorMainForm, uSharedFileLogger;

function WantsCommandLine: Boolean;
var
  lIndex: Integer;
  lValue: string;
begin
  Result := False;
  for lIndex := 1 to ParamCount do
  begin
    lValue := ParamStr(lIndex);
    if SameText(lValue, '--cli') or SameText(lValue, '--serve') or
       SameText(lValue, '--status') or SameText(lValue, '--list-hosts') or
       (Pos('--command=', lValue) = 1) then
      Exit(True);
  end;
end;

begin
  SharedLogger.Configure(ChangeFileExt(ParamStr(0), '.log'));
  SharedLogger.Info('Coordinator process started');
  if WantsCommandLine then
    Halt(RunCoordinatorCli);

  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TCoordinatorMainForm, CoordinatorMainForm);
  CoordinatorMainForm.Show;
  Application.Run;
  SharedLogger.Info('Coordinator process stopped');
end.
