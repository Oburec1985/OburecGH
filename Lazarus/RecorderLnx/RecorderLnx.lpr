program RecorderLnx;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, Forms, uMainForm, uComponentSettingsDialog,
  uRecorderTrendSettingsDialog, uRecorderTrendView, uSharedFileLogger;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
