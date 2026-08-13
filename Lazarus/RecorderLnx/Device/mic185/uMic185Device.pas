unit uMic185Device;

{
  Драйвер MIC183/185 для автономного стенда.
  В Recorder прибор отображается как «MIC183/185»; в Mebius — medaq_mic185v2.
  Каналы: 64 тензо + 5 температурных + 1 СЕВ (UTS).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Variants,
  uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uMic185MebiusTcpProtocol, uMic185MebiusTypes, uMic185Constants;

type
  TRecorderMic185Device = class(TRecorderDevice)
  private
    fClient: TRecorderMebiusTcpClient;
    fDeviceSerial: LongWord;
    fSoftVersion: LongWord;
    fSampleIndex: Int64;
    fSessionId: LongWord;
    fMeasChannelCount: Integer;
    fTempChannelCount: Integer;
    fUtsEnabled: Boolean;
    fMeasFrequencyHz: Double;
    fTempFrequencyHz: Double;
    fChannelProgramSettings: TMic185ChannelProgramSettingsArray;
    fHasChannelProgramSettings: Boolean;
    fGroupAddition: TMic185GroupAdditionArray;
    fModuleProgramSettings: TMic185ModuleProgramSettings;
    fTemperatureCompensation: Boolean;
    fPowerMaCode: LongWord;
    fRecorderDeviceIndex: Integer;
    fLastTempValues: array of Double;
    fLastUtsValue: Double;
    fLastUtsDeviceTimeSec: Double;
    fUtsGeneration: QWord;
    fHasLastTemp: Boolean;
    fHasLastUts: Boolean;
    { Читает серийный номер и версию прошивки короткой Mebius-командой. }
    function TryQueryDeviceInfo(out AErrorText: string): Boolean;
    { Возвращает количество каналов, видимых RecorderLnx: AIn + TIn + UTS. }
    function TotalLogicalChannelCount: Integer;
    { Формирует короткое имя и адрес канала: 185-{3-1}. }
    function BuildLogicalChannelName(AIndex: Integer): string;
    { Адрес канала сейчас совпадает с именем, чтобы теги однозначно связывались
      с аппаратным слотом. }
    function BuildLogicalChannelAddress(AIndex: Integer): string;
    { Единица по умолчанию для канала устройства до пользовательского выбора. }
    function BuildLogicalChannelUnit(AIndex: Integer): string;
    { Частота канала для создания тегов и буферов RecorderLnx. }
    function BuildLogicalChannelFrequency(AIndex: Integer): Double;
  protected
    { Обновляет общие параметры TRecorderDevice после чтения конфигурации. }
    procedure ReadDeviceParameters; override;
  public
    constructor Create(const ADeviceId, AName: string); override;
    destructor Destroy; override;
    { Возвращает логические каналы прибора для дерева оборудования. }
    function GetChannels: TRecorderDeviceChannelArray; override;
    { Читает свойства прибора через общий интерфейс RecorderLnx. }
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant; override;
    { Меняет свойства прибора, которые задаются из источника данных/диалога. }
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer = -1): Boolean; override;
    { Открывает только транспортную TCP-сессию. }
    function TryConnect(out AErrorText: string): Boolean;
    procedure Connect; override;
    function TryInitializeSession(out AErrorText: string): Boolean;
    { Закрывает TCP-клиент и снимает runtime-занятость endpoint. }
    procedure Disconnect; override;
    { Отправляет ProgramDeviceBin, session_id и команду PROGRAM. }
    function TryProgramDevice(out AErrorText: string): Boolean;
    procedure ProgramDevice; override;
    { Принимает настройки каналов от RecorderLnx без изменения базового
      интерфейса TRecorderDevice. }
    procedure ApplyChannelProgramSettings(
      const ASettings: TMic185ChannelProgramSettingsArray;
      const AGroupAddition: TMic185GroupAdditionArray;
      ATemperatureCompensation: Boolean;
      const AModuleSettings: TMic185ModuleProgramSettings);
    { Seeds identity loaded from project/broadcast cache. A failed refresh must
      not erase the last confirmed serial shown by the hardware tree. }
    procedure ApplyKnownIdentity(ASerialNumber, ASoftVersion: LongWord);
    { Запускает измерительную задачу MIC185V2. }
    procedure Start; override;
    function TryStart(out AErrorText: string): Boolean;
    { Останавливает измерительную задачу MIC185V2. }
    procedure Stop; override;
    { Читает очередной блок измерений и перекладывает его в acquisition block. }
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderAcquisitionBlock): Boolean; override;
    property SoftVersion: LongWord read fSoftVersion;
    property DeviceSerial: LongWord read fDeviceSerial;
    property MeasChannelCount: Integer read fMeasChannelCount;
    property TempChannelCount: Integer read fTempChannelCount;
    property UtsEnabled: Boolean read fUtsEnabled;
    property RecorderDeviceIndex: Integer read fRecorderDeviceIndex
      write fRecorderDeviceIndex;
    { Последнее кэшированное значение температурного канала. }
    function LastTempValue(AIndex: Integer): Double;
    { Последнее кэшированное значение UTS/SEV. }
    function LastUts: Double;
    function LastUtsDeviceTimeSec: Double;
    function UtsGeneration: QWord;
    { Признак, что хотя бы один температурный пакет уже получен. }
    function HasTempData: Boolean;
    { Признак, что UTS/SEV пакет уже получен. }
    function HasUtsData: Boolean;
    { Продлевает активную Mebius-сессию без ожидания служебного ответа. }
    { Быстрая проверка TCP/Mebius связи без запуска измерений. }
    function TestLink(out AErrorText: string): Boolean; override;
    { Диагностическое чтение нескольких сырых Mebius-пакетов. }
    function SniffPackets(APacketCount: Integer; ATimeoutMs: Cardinal): Integer;
    { Счетчик принятых DATA_TRANSMIT пакетов для диагностики. }
    function RxDataPacketCount: Int64;
    function RxByteCount: Int64;
    function RxPacketCount: Int64;
    function RxSyncDropCount: Int64;
    function RxCompactCount: Int64;
    function RxMaxBuffered: Integer;
    function RxBufferedByteCount: Integer;
    function ConnectionLost: Boolean;
    function LastReadError: string;
  end;

{ Фабрика для регистрации MIC183/185 в общем менеджере устройств. }
function CreateRecorderMic185Device: IRecorderDevice;

implementation

uses
  uRecorderMic185Runtime;

const
  CMic185ConnectAttempts = 1;
  { Недоступность прибора должна определяться быстро. Повтор той же команды
    после явного IoControl timeout только задерживает сброс. }
  CMic185ConnectTimeoutMs = 2000;
  CMic185IdentityTimeoutMs = 2000;
  { A successful TCP handshake is earlier than the Mebius transport-ready
    event used by the original driver's WaitConnecting().  Give the device
    service time to attach the new settings client before the first
    IoControl.  This delay is local to each device, so devices still prepare
    in parallel. }
  { Оригинальный CTCPLink ждёт одну секунду после Connect перед первой
    командой программирования. }
  CMic185TransportReadyDelayMs = 1000;

constructor TRecorderMic185Device.Create(const ADeviceId, AName: string);
begin
  inherited Create(ADeviceId, AName);
  fPort := 4000;
  fMeasChannelCount := CMic185ChannelCountMax;
  fTempChannelCount := CMic185TempChannelCount;
  fUtsEnabled := True;
  fChannelCount := CMic185TotalLogicalChannelCount;
  fMeasFrequencyHz := CMic185DefaultMeasFrequencyHz;
  fTempFrequencyHz := CMic185DefaultTempFrequencyHz;
  fPollFrequencyHz := fMeasFrequencyHz;
  fUpdateTimeMs := 100;
  fRecorderDeviceIndex := 3;
  Mic185DefaultChannelProgramSettingsArray(fMeasFrequencyHz, fChannelProgramSettings);
  Mic185DefaultGroupAdditionSettings(fGroupAddition);
  Mic185DefaultModuleProgramSettings(fModuleProgramSettings);
  fTemperatureCompensation := True;
  fPowerMaCode := CMic185DefaultPowerMaCode;
  fHasChannelProgramSettings := False;
end;

destructor TRecorderMic185Device.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

function TRecorderMic185Device.TotalLogicalChannelCount: Integer;
begin
  Result := fMeasChannelCount + fTempChannelCount;
  if fUtsEnabled then
    Inc(Result, CMic185UtsChannelCount);
end;

function TRecorderMic185Device.BuildLogicalChannelName(AIndex: Integer): string;
begin
  if AIndex < fMeasChannelCount then
    Result := Format('185-{%d-%d}', [fRecorderDeviceIndex, AIndex + 1])
  else if AIndex < fMeasChannelCount + fTempChannelCount then
    Result := Format('185-{%d-t%d}', [fRecorderDeviceIndex,
      AIndex - fMeasChannelCount + 1])
  else
    Result := Format('185-{%d-uts}', [fRecorderDeviceIndex]);
end;

function TRecorderMic185Device.BuildLogicalChannelAddress(AIndex: Integer): string;
begin
  if AIndex < fMeasChannelCount then
    Result := Format('%d-%d', [fRecorderDeviceIndex, AIndex + 1])
  else if AIndex < fMeasChannelCount + fTempChannelCount then
    Result := Format('%d-t%d', [fRecorderDeviceIndex,
      AIndex - fMeasChannelCount + 1])
  else
    Result := Format('%d-uts', [fRecorderDeviceIndex]);
end;

function TRecorderMic185Device.BuildLogicalChannelUnit(AIndex: Integer): string;
begin
  if AIndex < fMeasChannelCount then
    Result := 'mV'
  else if AIndex < fMeasChannelCount + fTempChannelCount then
    Result := 'C'
  else
    Result := 's';
end;

function TRecorderMic185Device.BuildLogicalChannelFrequency(AIndex: Integer): Double;
begin
  if AIndex < fMeasChannelCount then
    Result := fMeasFrequencyHz
  else
    Result := fTempFrequencyHz;
end;

procedure TRecorderMic185Device.ReadDeviceParameters;
begin
  inherited ReadDeviceParameters;
  fChannelCount := TotalLogicalChannelCount;
end;

function TRecorderMic185Device.GetChannels: TRecorderDeviceChannelArray;
var
  I: Integer;
begin
  SetLength(Result, TotalLogicalChannelCount);
  for I := 0 to TotalLogicalChannelCount - 1 do
  begin
    Result[I].Name := BuildLogicalChannelName(I);
    Result[I].Address := BuildLogicalChannelAddress(I);
    Result[I].UnitName := BuildLogicalChannelUnit(I);
    Result[I].ModuleType := fName;
    Result[I].PollFrequencyHz := BuildLogicalChannelFrequency(I);
    Result[I].Enabled := True;
  end;
end;

function TRecorderMic185Device.GetDeviceProperty(
  AProperty: TRecorderDeviceProperty; AIndex: Integer): Variant;
begin
  case AProperty of
    rdpDeviceSerial: Result := fDeviceSerial;
    rdpChannelCount: Result := TotalLogicalChannelCount;
    rdpPollFrequencyHz: Result := fMeasFrequencyHz;
  else
    Result := inherited GetDeviceProperty(AProperty, AIndex);
  end;
end;

function TRecorderMic185Device.TrySetDeviceProperty(
  AProperty: TRecorderDeviceProperty; const AValue: Variant;
  AIndex: Integer): Boolean;
begin
  Result := True;
  case AProperty of
    rdpPollFrequencyHz:
      begin
        fMeasFrequencyHz := Double(AValue);
        fPollFrequencyHz := fMeasFrequencyHz;
        if not fHasChannelProgramSettings then
          Mic185DefaultChannelProgramSettingsArray(fMeasFrequencyHz,
            fChannelProgramSettings);
      end;
    rdpChannelCount:
      begin
        { Ожидаемая конфигурация Recorder: 64 + 5 + 1. }
        if Integer(AValue) <> CMic185TotalLogicalChannelCount then
          Exit(False);
        fMeasChannelCount := CMic185ChannelCountMax;
        fTempChannelCount := CMic185TempChannelCount;
        fUtsEnabled := True;
        fChannelCount := TotalLogicalChannelCount;
      end;
  else
    Result := inherited TrySetDeviceProperty(AProperty, AValue, AIndex);
  end;
end;

function TRecorderMic185Device.TryQueryDeviceInfo(
  out AErrorText: string): Boolean;
var
  lOut: TRecorderByteArray;
  lInfo: TMic185HardDeviceInfo;
  lError: string;
  lSavedTimeoutMs: Cardinal;
begin
  Result := False;
  AErrorText := '';
  if fClient = nil then
  begin
    AErrorText := 'MIC183/185 TCP session is not connected';
    Exit;
  end;
  lSavedTimeoutMs := fClient.TimeoutMs;
  try
    if fClient.TimeoutMs < CMic185IdentityTimeoutMs then
      fClient.TimeoutMs := CMic185IdentityTimeoutMs;
    if fClient.TryCallCommand(CMic185IoCtlCmdGetSoftVersion, nil,
      CMic185HardDeviceInfoSize, lOut, lError) and
      (Length(lOut) >= CMic185HardDeviceInfoSize) then
    begin
      Move(lOut[0], lInfo, SizeOf(lInfo));
      fDeviceSerial := lInfo.SerialNumber;
      fSoftVersion := lInfo.SoftVersion;
      RecorderMic185RuntimeUpdateInfo(fHost, Word(fPort), fDeviceSerial,
        fSoftVersion);
      Result := True;
      Exit;
    end;
    if Trim(lError) <> '' then
      AErrorText := lError
    else
      AErrorText := 'MIC183/185 returned incomplete device information';
  finally
    fClient.TimeoutMs := lSavedTimeoutMs;
  end;
end;

procedure TRecorderMic185Device.ApplyKnownIdentity(ASerialNumber,
  ASoftVersion: LongWord);
begin
  if ASerialNumber <> 0 then
    fDeviceSerial := ASerialNumber;
  if ASoftVersion <> 0 then
    fSoftVersion := ASoftVersion;
  if (fDeviceSerial <> 0) or (fSoftVersion <> 0) then
    RecorderMic185RuntimeUpdateInfo(fHost, Word(fPort), fDeviceSerial,
      fSoftVersion);
end;

function TRecorderMic185Device.TryConnect(out AErrorText: string): Boolean;
var
  lAttempt: Integer;
begin
  Result := False;
  AErrorText := '';
  if fState <> rdsDisconnected then
    Exit(True);
  if Trim(fHost) = '' then
  begin
    AErrorText := 'MIC183/185 host is not set';
    Exit;
  end;

  for lAttempt := 1 to CMic185ConnectAttempts do
  begin
    FreeAndNil(fClient);
    fClient := TRecorderMebiusTcpClient.Create(fHost, Word(fPort), CMic185ConnectTimeoutMs);
    if fClient.TryConnect(AErrorText) then
    begin
      fState := rdsConnected;
      Exit(True);
    end;
    FreeAndNil(fClient);
  end;
end;

function TRecorderMic185Device.TryInitializeSession(
  out AErrorText: string): Boolean;
begin
  Result := False;
  AErrorText := '';
  if fState = rdsDisconnected then
  begin
    AErrorText := 'MIC183/185 session is not connected';
    Exit(False);
  end;

  RecorderMic185RuntimeLog(Format(
    'Initialize transport-ready wait %s:%d delay=%dms',
    [fHost, fPort, CMic185TransportReadyDelayMs]));
  Sleep(CMic185TransportReadyDelayMs);
  if not TryQueryDeviceInfo(AErrorText) then
  begin
    { TCP мог открыться поверх ещё не освобождённой или полуразорванной
      сессии прибора. Один раз полностью пересоздаём транспорт. }
    Disconnect;
    Sleep(CMic185TransportReadyDelayMs);
    if not TryConnect(AErrorText) then
      Exit;
    Sleep(CMic185TransportReadyDelayMs);
    if not TryQueryDeviceInfo(AErrorText) then
      Exit;
  end;
  RecorderMic185RuntimeAttach(fHost, Word(fPort), fDeviceSerial,
    fSoftVersion, False);
  Result := True;
end;

procedure TRecorderMic185Device.Connect;
var
  lErrorText: string;
begin
  if not TryConnect(lErrorText) then
    raise ERecorderDeviceError.CreateFmt('MIC183/185 connect failed: %s',
      [lErrorText]);
end;

procedure TRecorderMic185Device.Disconnect;
begin
  { При аварийном reset сразу освобождаем транспорт. Штатный Stop вызывается
    отдельной стадией жизненного цикла. }
  FreeAndNil(fClient);
  RecorderMic185RuntimeDetach(fHost, Word(fPort));
  fState := rdsDisconnected;
end;

procedure TRecorderMic185Device.ApplyChannelProgramSettings(
  const ASettings: TMic185ChannelProgramSettingsArray;
  const AGroupAddition: TMic185GroupAdditionArray;
  ATemperatureCompensation: Boolean;
  const AModuleSettings: TMic185ModuleProgramSettings);
begin
  fChannelProgramSettings := ASettings;
  fGroupAddition := AGroupAddition;
  fModuleProgramSettings := AModuleSettings;
  fTemperatureCompensation := ATemperatureCompensation;
  if ASettings[0].PowerMaCode <> 0 then
    fPowerMaCode := ASettings[0].PowerMaCode;
  fHasChannelProgramSettings := True;
end;

function TRecorderMic185Device.TryProgramDevice(
  out AErrorText: string): Boolean;
var
  lCommandIn: TRecorderByteArray;
  lCommandOut: TRecorderByteArray;
  lErrorMessage: string;
  lSettings: TRecorderByteArray;
  lStatusFlags: LongWord;
begin
  Result := False;
  AErrorText := '';
  if (fState = rdsDisconnected) or (fClient = nil) then
  begin
    AErrorText := 'MIC183/185 session is not connected';
    Exit;
  end;

  lStatusFlags := 0;
  if fUtsEnabled then
    lStatusFlags := lStatusFlags or CMic185TaskSevEnFlag;
  SetLength(lCommandIn, SizeOf(lStatusFlags));
  Move(lStatusFlags, lCommandIn[0], SizeOf(lStatusFlags));
  if not fClient.TryCallCommand(CMic185IoCtlCmdSetControllerParams, lCommandIn,
    0, lCommandOut, lErrorMessage) then
  begin
    AErrorText := 'SetControllerParams: ' + lErrorMessage;
    Exit;
  end;

  if not fHasChannelProgramSettings then
    Mic185DefaultChannelProgramSettingsArray(fMeasFrequencyHz,
      fChannelProgramSettings);
  lSettings := Mic185BuildSettingsEx(fMeasFrequencyHz, fTempFrequencyHz,
    fUtsEnabled, fDeviceSerial, fSoftVersion, fChannelProgramSettings,
    fGroupAddition, fTemperatureCompensation, fModuleProgramSettings,
    fPowerMaCode);
  if not fClient.TryProgramDeviceBin(lSettings, lErrorMessage) then
  begin
    AErrorText := 'ProgramDeviceBin: ' + lErrorMessage;
    Exit;
  end;

  fSessionId := Mic185GenerateSessionId(fDeviceSerial);
  RecorderMic185RuntimeLog(Format('MIC-185 session id %s:%d = %.8x',
    [fHost, fPort, fSessionId]));
  if not fClient.TrySetSessionId(fSessionId, lErrorMessage) then
  begin
    AErrorText := 'SetSessionId: ' + lErrorMessage;
    Exit;
  end;

  if not fClient.TryProgramMeasurement(lErrorMessage) then
  begin
    AErrorText := 'ProgramMeasurement: ' + lErrorMessage;
    Exit;
  end;

  fState := rdsProgrammed;
  Result := True;
end;

procedure TRecorderMic185Device.ProgramDevice;
var
  lErrorText: string;
begin
  if fState = rdsDisconnected then
    Connect;
  if not TryProgramDevice(lErrorText) then
    raise ERecorderDeviceError.CreateFmt('MIC183/185 programming failed: %s',
      [lErrorText]);
end;

procedure TRecorderMic185Device.Start;
var
  lErrorMessage: string;
begin
  if not TryStart(lErrorMessage) then
    raise ERecorderDeviceError.CreateFmt('StartMeasurement: %s', [lErrorMessage]);
end;

function TRecorderMic185Device.TryStart(out AErrorText: string): Boolean;
begin
  Result := False;
  AErrorText := '';
  if fState = rdsDisconnected then
    if not TryConnect(AErrorText) then
      Exit;
  if fState = rdsConnected then
    if not TryProgramDevice(AErrorText) then
      Exit;
  if (fState <> rdsProgrammed) or (fClient = nil) then
  begin
    AErrorText := 'MIC183/185 is not programmed';
    Exit;
  end;

  if not fClient.TryStartMeasurement(AErrorText) then
    Exit;
  fSampleIndex := 0;
  fState := rdsStarted;
  RecorderMic185RuntimeSetAcquiring(fHost, Word(fPort), True);
  Result := True;
end;

procedure TRecorderMic185Device.Stop;
var
  lErrorMessage: string;
begin
  if (fClient <> nil) and (fState = rdsStarted) then
    fClient.TryStopMeasurement(lErrorMessage);
  if fState = rdsStarted then
  begin
    fState := rdsProgrammed;
    RecorderMic185RuntimeSetAcquiring(fHost, Word(fPort), False);
  end;
end;

function TRecorderMic185Device.LastTempValue(AIndex: Integer): Double;
begin
  if (AIndex >= 0) and (AIndex < Length(fLastTempValues)) then
    Result := fLastTempValues[AIndex]
  else
    Result := 0;
end;

function TRecorderMic185Device.LastUts: Double;
begin
  Result := fLastUtsValue;
end;

function TRecorderMic185Device.LastUtsDeviceTimeSec: Double;
begin
  Result := fLastUtsDeviceTimeSec;
end;

function TRecorderMic185Device.UtsGeneration: QWord;
begin
  Result := fUtsGeneration;
end;

function TRecorderMic185Device.HasTempData: Boolean;
begin
  Result := fHasLastTemp;
end;

function TRecorderMic185Device.HasUtsData: Boolean;
begin
  Result := fHasLastUts;
end;

function TRecorderMic185Device.SniffPackets(APacketCount: Integer;
  ATimeoutMs: Cardinal): Integer;
begin
  Result := 0;
  if fClient <> nil then
    Result := fClient.SniffPackets(APacketCount, ATimeoutMs);
end;

function TRecorderMic185Device.RxDataPacketCount: Int64;
begin
  Result := 0;
  if fClient <> nil then
    Result := fClient.RxDataPacketCount;
end;

function TRecorderMic185Device.RxByteCount: Int64;
begin
  if fClient <> nil then Result := fClient.RxByteCount else Result := 0;
end;

function TRecorderMic185Device.RxPacketCount: Int64;
begin
  if fClient <> nil then Result := fClient.RxPacketCount else Result := 0;
end;

function TRecorderMic185Device.RxSyncDropCount: Int64;
begin
  if fClient <> nil then Result := fClient.RxSyncDropCount else Result := 0;
end;

function TRecorderMic185Device.RxCompactCount: Int64;
begin
  if fClient <> nil then Result := fClient.RxCompactCount else Result := 0;
end;

function TRecorderMic185Device.RxMaxBuffered: Integer;
begin
  if fClient <> nil then Result := fClient.RxMaxBuffered else Result := 0;
end;

function TRecorderMic185Device.RxBufferedByteCount: Integer;
begin
  if fClient <> nil then Result := fClient.RxBufferedByteCount else Result := 0;
end;

function TRecorderMic185Device.ConnectionLost: Boolean;
begin
  Result := (fClient <> nil) and fClient.ConnectionLost;
end;

function TRecorderMic185Device.LastReadError: string;
begin
  Result := '';
  if fClient <> nil then
    Result := fClient.LastReadError;
end;

function TRecorderMic185Device.TestLink(out AErrorText: string): Boolean;
begin
  AErrorText := '';
  if (fState = rdsDisconnected) or (fClient = nil) then
  begin
    AErrorText := 'MIC183/185 is not connected';
    Exit(False);
  end;
  if fState = rdsStarted then
  begin
    if fDeviceSerial <> 0 then
      Exit(True);
    AErrorText := 'MIC183/185 serial number is unavailable while acquiring';
    Exit(False);
  end;
  { A connected socket alone is not a successful TEST. Every non-running
    TestLink reads the current identity and refreshes SN/version. }
  Result := TryQueryDeviceInfo(AErrorText);
end;

function TRecorderMic185Device.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderAcquisitionBlock): Boolean;
var
  I, J: Integer;
  lRaw: TRecorderMebiusFloatBlock;
  lTemp: TRecorderSingleArray;
  lHasTemp, lHasUts: Boolean;
  lUtsDeviceTime, lUts: Double;
begin
  // очистка блока. Нужна ли? Может делать это при старте измерений разово?
  ClearRecorderAcquisitionBlock(ABlock);
  Result := False;
  if (fState <> rdsStarted) or (fClient = nil) then
    Exit;

  fClient.TimeoutMs := ATimeoutMs;
  if not fClient.ReadMeasDataBlock(fMeasChannelCount, lRaw, lTemp, lHasTemp,
    lUtsDeviceTime, lUts, lHasUts) then
    Exit;

  if lHasTemp then
  begin
    SetLength(fLastTempValues, Length(lTemp));
    for I := 0 to High(lTemp) do
      fLastTempValues[I] := lTemp[I];
    fHasLastTemp := True;
  end;
  if lHasUts then
  begin
    fLastUtsDeviceTimeSec := lUtsDeviceTime;
    fLastUtsValue := lUts;
    fHasLastUts := True;
    Inc(fUtsGeneration);
  end;

  ABlock.ChannelCount := lRaw.ChannelCount;
  ABlock.SampleCount := lRaw.SampleCount;
  ABlock.SampleRateHz := fMeasFrequencyHz;
  ABlock.FirstTimeSec := fSampleIndex / fMeasFrequencyHz;
  SetLength(ABlock.Values, ABlock.ChannelCount);
  for I := 0 to ABlock.ChannelCount - 1 do
  begin
    SetLength(ABlock.Values[I], ABlock.SampleCount);
    for J := 0 to ABlock.SampleCount - 1 do
      ABlock.Values[I][J] := lRaw.Values[I][J];
  end;
  Inc(fSampleIndex, ABlock.SampleCount);
  Result := True;
end;

function CreateRecorderMic185Device: IRecorderDevice;
begin
  Result := TRecorderMic185Device.Create('MIC183/185', 'MIC183/185');
end;

end.
