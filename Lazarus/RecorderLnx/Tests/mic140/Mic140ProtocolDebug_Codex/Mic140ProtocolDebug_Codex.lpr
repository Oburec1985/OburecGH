program Mic140ProtocolDebug_Codex;

{$mode objfpc}{$H+}
{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}
  {$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}
  {$ENDIF}
  Interfaces, Forms, uRecorderAcquisitionTypes, uRecorderDeviceInterfaces,
  uMic140DebugForm, uRecorderDeviceManager, uMic140Device, uMic140Registration {Mic140DebugForm};

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMic140DebugForm, Mic140DebugForm);
  Application.Run;
end.
