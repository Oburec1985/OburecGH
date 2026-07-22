program Mic140ProtocolDebug_Codex;

{$mode objfpc}{$H+}
{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}
  {$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}
  {$ENDIF}
  Interfaces, Forms,
  uMic140DebugForm in 'uMic140DebugForm.pas' {Mic140DebugForm},
  uMic140Registration in 'device\MIC140\uMic140Registration.pas';

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMic140DebugForm, Mic140DebugForm);
  Application.Run;
end.
