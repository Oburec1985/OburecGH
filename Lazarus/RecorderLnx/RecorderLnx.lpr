program RecorderLnx;

{$mode objfpc}{$H+}
{$IFDEF MSWINDOWS}
{$R Device/MCbus/resources/mcbus.rc}
{$ENDIF}

uses
  {$IFDEF UNIX}
  cthreads, BaseUnix,
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
  uRecorderMic140DataSource, uRecorderSpectrumRuntime, uSharedFileLogger,
  uRecorderMeraPaths, uOglChartLog,
  uMc201ProtocolTypes, uMc201FirmwareResources, uMc201LegacyMdpClient,
  uMc032Device, uRecorderMcbusDevice;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  {$IFDEF UNIX}
  { LCL и подключенный отладчик могут настроить обработчики сигналов во время
    Application.Initialize. Поэтому политику TCP задаём после Initialize, но
    до CreateForm, где начинаются проверки сетевых устройств. Закрытый peer
    должен дать драйверу EPIPE, а не External exception code 13. }
  fpSignal(SIGPIPE, SignalHandler(SIG_IGN));
  {$ENDIF}
  ChartLogSetFileName(RecorderServiceFileName('oglchart_debug.log'));
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
