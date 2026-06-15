program RecorderLnx;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, Forms, uMainForm, uComponentSettingsDialog,
  uRecorderTrendSettingsDialog, uRecorderTrendView,
  uRecorderCalibrationAddDialog, uRecorderCalibrationListDialog,
  uRecorderCalibrationPropertiesDialog, uRecorderMic140SettingsDialog,
  uRecorderSpectrumSettingsDialog, uRecorderSpectrumView,
  uRecorderVisualControl, uRecorderDeviceInterfaces, uRecorderMebiusTcpProtocol,
  uRecorderMic140DataSource, uRecorderSpectrumRuntime, uSharedFileLogger;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
