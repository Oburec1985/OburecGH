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
  uRecorderVisualControl, uRecorderDeviceInterfaces, uMic185Constants,
  uMic185DebugLog, uMic185Device, uMic185MebiusTcpProtocol, uMic185MebiusTypes,
  uRecorderMic185DataSource, uRecorderMic185Runtime,
  uRecorderMic185AdditionalDialog, uRecorderMic185ChannelDialog,
  uRecorderMic185SettingsDialog, uRecorderMebiusTcpProtocol,
  uRecorderMic140DataSource, uRecorderSpectrumRuntime, uSharedFileLogger;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
