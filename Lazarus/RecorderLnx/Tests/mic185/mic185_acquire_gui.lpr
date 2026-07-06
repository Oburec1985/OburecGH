program mic185_acquire_gui;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  SysUtils, Interfaces, Forms,
  uMic185DebugForm in 'uMic185DebugForm.pas' {Mic185DebugForm},
  uMic185Registration in 'device\MIC185\uMic185Registration.pas';

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.Title := 'MIC183/185 Protocol Debug';
  Application.CreateForm(TMic185DebugForm, Mic185DebugForm);
  Application.Run;
end.
