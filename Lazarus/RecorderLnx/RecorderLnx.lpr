program RecorderLnx;

{$mode objfpc}{$H+}
{$IFDEF MSWINDOWS}
{$R Device/MCbus/resources/mcbus.rc}
{$ENDIF}

uses
  {$IFDEF UNIX}
  cthreads, BaseUnix,
  {$ENDIF}
  SysUtils, Classes, Interfaces, Forms, uMainForm, uRecorderNetworkBinding,
  uComponentSettingsDialog,
  uRecorderVirtualTagDialog,
  uRecorderButtonSettingsDialog,
  uRecorderTrendSettingsDialog, uRecorderTrendView,
  uRecorderSqlTrendModel, uRecorderSqlTrendView,
  uRecorderSqlTrendSettingsDialog,
  uRecorderCalibrationAddDialog, uRecorderCalibrationListDialog,
  uRecorderCalibrationPropertiesDialog, uRecorderStrainCalibration,
  uRecorderStrainCalibrationDialog, uRecorderMic140SettingsDialog,
  uRecorderSpectrumSettingsDialog, uRecorderSpectrumView,
  uRecorderVisualControl, uRecorderDeviceInterfaces, uMic185Constants,
  uMic185DebugLog, uMic185Device, uMic185MebiusTcpProtocol, uMic185MebiusTypes,
  uRecorderMic185DataSource, uRecorderMic185Runtime,
  uRecorderMic185AdditionalDialog, uRecorderMic185ChannelDialog,
  uRecorderMic185SettingsDialog,
  uRecorderMic140DataSource, uRecorderSpectrumRuntime, uSharedFileLogger,
  uRecorderMeraPaths, uOglChartLog,
  uMc201ProtocolTypes, uMc201FirmwareResources, uMc201LegacyMdpClient,
  uMc032Device, uRecorderMcbusDevice;

function HasSwitch(const AName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), AName) then Exit(True);
end;

function SwitchValue(const AName, ADefault: string): string;
var
  I: Integer;
  lPrefix: string;
begin
  Result := ADefault;
  lPrefix := AName + '=';
  for I := 1 to ParamCount do
    if SameText(Copy(ParamStr(I), 1, Length(lPrefix)), lPrefix) then
      Exit(Copy(ParamStr(I), Length(lPrefix) + 1, MaxInt));
end;

procedure RunHardwareSearchTest;
var
  lFound: TStringList;
  lReport: TStringList;
  lReportFile: string;
  lNetworkLogFile: string;
  lBind: string;
  lHint: string;
  lKind: string;
  lSerial: string;
  lTimeout: Cardinal;
  I: Integer;
begin
  lBind := SwitchValue('--bind', '');
  lHint := SwitchValue('--hint', '');
  lTimeout := StrToIntDef(SwitchValue('--timeout-ms', '5200'), 5200);
  lReportFile := ExtractFilePath(ParamStr(0)) +
    'hardware-search-main-summary.log';
  lNetworkLogFile := ExtractFilePath(ParamStr(0)) +
    'hardware-search-main-net.log';
  RecorderSetNetworkDebugLogFile(lNetworkLogFile);
  SetRecorderNetworkBindAddress(lBind);
  RecorderClearDiscoveryHints;
  RecorderAddDiscoveryHintIPv4(lHint);
  lFound := TStringList.Create;
  lReport := TStringList.Create;
  try
    lReport.Add(Format('hardware-search-test exe="%s" bind="%s" effective="%s" hint="%s" timeout=%d',
      [ParamStr(0), lBind, RecorderNetworkBindAddress, lHint, lTimeout]));
    RecorderDiscoverMeraBroadcast(lFound, lTimeout);
    if (lFound.Count = 0) and RecorderProbeMeraLegacyHost(lHint, lKind,
      lSerial, 600) then
      lFound.Add(lHint + '=' + lKind + '|' + lSerial);
    lReport.Add(Format('found=%d', [lFound.Count]));
    for I := 0 to lFound.Count - 1 do
      lReport.Add(lFound[I]);
    lReport.SaveToFile(lReportFile);
  finally
    lReport.Free;
    lFound.Free;
  end;
end;

begin
  if HasSwitch('--hardware-search-test') then
  begin
    RunHardwareSearchTest;
    Halt(0);
  end;

  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  if HasSwitch('--hardware-search-test-after-init') then
  begin
    RunHardwareSearchTest;
    Halt(0);
  end;
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
