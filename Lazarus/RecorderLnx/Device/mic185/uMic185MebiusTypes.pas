unit uMic185MebiusTypes;

{
  Mebius MIC185V2 device settings blob (ProgramDeviceBin).
  Layout matches CMIC185V2_BASESETTINGS (MSVC pack 8).
}

{$mode objfpc}{$H+}
{$codepage UTF8}
{$PACKRECORDS 8}

interface

uses
  SysUtils,
  uMic185MebiusTcpProtocol, uMic185Constants;

type
  { MSVC #pragma pack(8): после bool — 3 байта pad; после Word BlockSize — 2 байта pad. }
  TMic185BaseChanSettings = record
    FrequencyHz: Single;
    Connected: Boolean;
    _PadAfterConnected: array[0..2] of Byte;
    BlockSize: Word;
    _PadBeforeMeasRange: Word;
    MeasRangeIndex: LongWord;
    SoftBalance: LongInt;
    CommutIndex: LongWord;
    ShuntOn: LongWord;
    EvalType: LongWord;
    TensoSensitivity: Double;
    Resistance: Double;
    SensorScheme: LongWord;
  end;

  { Температурный канал LM74 в ProgramDeviceBin. }
  TMic185TempChanSettings = record
    FrequencyHz: Single;
    Connected: Boolean;
    _PadAfterConnected: array[0..2] of Byte;
  end;

  { Редактируемые настройки одного измерительного канала до упаковки в
    бинарный пакет MIC185V2. }
  TMic185ChannelProgramSettings = record
    FrequencyHz: Double;
    Connected: Boolean;
    BlockSize: Word;
    MeasRangeIndex: LongWord;
    SoftBalance: LongInt;
    SoftBalanceFine: Double;
    CommutIndex: LongWord;
    ShuntOn: LongWord;
    EvalType: LongWord;
    TensoSensitivity: Double;
    Resistance: Double;
    SensorScheme: LongWord;
    PowerMaCode: LongWord;
  end;

  TMic185ChannelProgramSettingsArray =
    array[0..CMic185ChannelCountMax - 1] of TMic185ChannelProgramSettings;

  { Выбор компенсационного входа для каждой четверти прибора по 16 каналов. }
  TMic185GroupAdditionArray =
    array[0..CMic185ModuleCount - 1] of LongWord;

  { Editable module-wide settings stored by original MIC185V2 driver.
    AveragePointCount is the binary exponent: 7 means 2^7 = 128 ADC samples. }
  TMic185ModuleProgramSettings = record
    GroundCommutationUs: LongWord;
    ChannelCommutationUs: LongWord;
    BalancePortionLength: LongWord;
    HardBalance: LongWord;
    AveragePointCount: Word;
    MaxFreqMode: LongWord;
    CalibrShuntIndex: LongWord;
    DetermineBreak: Boolean;
    HardwareBalanceOn: Boolean;
  end;

  { Полный пакет настроек CMIC185V2_BASESETTINGS для PROGRAMM_DEVICE_BIN. }
  TMic185BaseSettings = record
    Channels: array[0..CMic185SettingsChannelSlots - 1] of TMic185BaseChanSettings;
    TempChannels: array[0..CMic185TempChannelCount - 1] of TMic185TempChanSettings;
    SerialNumber: LongWord;
    GroundEnabled: Boolean;
    _PadAfterGround: array[0..2] of Byte;
    GroundCommutationUs: LongWord;
    ChannelCommutationUs: LongWord;
    BalancePortionLength: LongWord;
    HardBalance: LongWord;
    AveragePointCount: Word;
    _PadAfterAverage: Word;
    PowerMaCode: LongWord;
    Reserved: LongWord;
    MaxFreqMode: LongWord;
    CalibrShuntIndex: LongWord;
    GroupAddition: array[0..CMic185ModuleCount - 1] of LongWord;
    DetermineBreak: Boolean;
    HardwareBalanceOn: Boolean;
    TemperatureCompensation: Boolean;
    _PadBeforeSoftVersion: Byte;
    SoftVersion: LongWord;
  end;

  { Ответ команды GetSoftVersion: серийный номер, версия ПО и метрология. }
  TMic185HardDeviceInfo = packed record
    SerialNumber: LongWord;
    SoftVersion: LongWord;
    HardVersion: LongWord;
    Revision: LongWord;
    IniDateTimeLow: LongWord;
    IniDateTimeHigh: LongWord;
    Metrolog: array[0..31] of AnsiChar;
    MetroDateTimeLow: LongWord;
    MetroDateTimeHigh: LongWord;
  end;

{ Формирует session_id так же, как Mebius-клиент: привязка к серийному номеру
  плюс случайная/временная младшая часть. }
function Mic185GenerateSessionId(ASerialNumber: LongWord): LongWord;
{ Заполняет настройки одного измерительного канала безопасными значениями
  original Recorder: диапазон 5 мВ, вход, тензометр 2 мВ/В, 200 Ом. }
procedure Mic185DefaultChannelProgramSettings(AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings);
{ Заполняет массив из 64 измерительных каналов одинаковыми настройками. }
procedure Mic185DefaultChannelProgramSettingsArray(AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettingsArray);
{ Настройка по умолчанию для термокомпенсации: первый компенсационный вход
  назначен первой группе из 16 каналов, остальные группы отключены. }
procedure Mic185DefaultGroupAdditionSettings(
  out ASettings: TMic185GroupAdditionArray);
{ Fills module-wide settings with MIC185V2_DEFAULT values from original Recorder. }
procedure Mic185DefaultModuleProgramSettings(
  out ASettings: TMic185ModuleProgramSettings);
{ Converts protocol exponent to the UI point count. }
function Mic185AverageExponentToPointCount(AExponent: Word): LongWord;
{ Converts UI point count to the protocol exponent. }
function Mic185AveragePointCountToExponent(APointCount: LongWord): Word;
{ Calculates the same max channel rate as CMIC185V2Base::CalcMaxRate. }
function Mic185CalcMaxFrequencyHz(
  const ASettings: TMic185ModuleProgramSettings): Double;
{ Original MIC185V2 time offset for an active channel inside its 16-channel
  group. AOrderInGroup is the zero-based order among connected channels. }
function Mic185ChannelStartOffsetSec(
  const ASettings: TMic185ModuleProgramSettings;
  AOrderInGroup: Integer): Double;
{ Совместимый wrapper для старого пути программирования без индивидуальных
  настроек каналов. }
function Mic185BuildSettings(AMeasFrequencyHz, ATempFrequencyHz: Double;
  AUtsEnabled: Boolean; ADeviceSerial, ASoftVersion: LongWord): TRecorderByteArray;
{ Формирует бинарный буфер ProgramDeviceBin: каналы, температуры, питание,
  компенсационные входы и флаг TKC. }
function Mic185BuildSettingsEx(AMeasFrequencyHz, ATempFrequencyHz: Double; AUtsEnabled: Boolean; ADeviceSerial, ASoftVersion: LongWord;
         const AChannelSettings: TMic185ChannelProgramSettingsArray;
         const AGroupAddition: TMic185GroupAdditionArray;
         ATemperatureCompensation: Boolean;
         const AModuleSettings: TMic185ModuleProgramSettings;
         APowerMaCode: LongWord = CMic185DefaultPowerMaCode): TRecorderByteArray;
{ Перевод тока питания датчика из мА в код DAC MIC185V2. }
function Mic185PowerMaToCode(APowerMa: Double): LongWord;
{ Обратный перевод кода DAC в мА для расчетов диапазонов и Ом. }
function Mic185PowerCodeToMa(APowerMaCode: LongWord): Double;
{ Форматирует версию прошивки из DWORD в привычный текст x.y.z.w. }
function Mic185FormatSoftVersion(AVersion: LongWord): string;

implementation

function Mic185GenerateSessionId(ASerialNumber: LongWord): LongWord;
begin
  Result := (ASerialNumber and $FF) shl 24;
  { Точный формат CMIC185V2::GenerateSessionId: серийный номер,
    случайные средние 12 бит и младшие 12 бит системного времени. }
  Result := Result or ((LongWord(Random($1000)) shl 12) and $00FFF000);
  Result := Result or (LongWord(GetTickCount64) and $00000FFF);
end;

procedure Mic185DefaultChannelProgramSettings(AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings);
begin
  FillChar(ASettings, SizeOf(ASettings), 0);
  ASettings.FrequencyHz := AFrequencyHz;
  ASettings.Connected := True;
  ASettings.BlockSize := 1;
  ASettings.MeasRangeIndex := CMic185Range5mV;
  ASettings.SoftBalance := 0;
  ASettings.CommutIndex := CMic185CommutInput;
  ASettings.ShuntOn := 0;
  ASettings.EvalType := 0;
  ASettings.TensoSensitivity := 2;
  ASettings.Resistance := 200;
  ASettings.SensorScheme := CMic185SensorSchemeTenzo;
  ASettings.PowerMaCode := CMic185DefaultPowerMaCode;
end;

procedure Mic185DefaultChannelProgramSettingsArray(AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettingsArray);
var
  I: Integer;
begin
  for I := 0 to High(ASettings) do
    Mic185DefaultChannelProgramSettings(AFrequencyHz, ASettings[I]);
end;

procedure Mic185DefaultGroupAdditionSettings(
  out ASettings: TMic185GroupAdditionArray);
var
  I: Integer;
begin
  for I := 0 to High(ASettings) do
    ASettings[I] := CMic185ModAddOff;
  ASettings[0] := CMic185ModAdd1;
end;

procedure Mic185DefaultModuleProgramSettings(
  out ASettings: TMic185ModuleProgramSettings);
begin
  FillChar(ASettings, SizeOf(ASettings), 0);
  ASettings.GroundCommutationUs := CMic185DefaultGndCommutUs;
  ASettings.ChannelCommutationUs := CMic185DefaultChnCommutUs;
  ASettings.BalancePortionLength := CMic185DefaultBlnPortionLength;
  ASettings.HardBalance := CMic185DefaultHardBalance;
  ASettings.AveragePointCount := CMic185DefaultAveragePointCount;
  ASettings.MaxFreqMode := 0;
  ASettings.CalibrShuntIndex := CMic185DefaultCalibrShuntIndex;
  ASettings.DetermineBreak := False;
  ASettings.HardwareBalanceOn := False;
end;

function Mic185AverageExponentToPointCount(AExponent: Word): LongWord;
begin
  if AExponent >= 31 then
    Exit(1 shl 30);
  Result := LongWord(1) shl AExponent;
end;

function Mic185AveragePointCountToExponent(APointCount: LongWord): Word;
begin
  Result := 0;
  if APointCount = 0 then
    Exit;
  while (APointCount > 1) and (Result < 30) do
  begin
    APointCount := APointCount shr 1;
    Inc(Result);
  end;
end;

function Mic185CalcMaxFrequencyHz(
  const ASettings: TMic185ModuleProgramSettings): Double;
const
  CMic185NiosIrqDelayUs = 10.0;
var
  lChannelTimeUs: Double;
  lGroupCount: Double;
begin
  if ASettings.MaxFreqMode <> 0 then
    lGroupCount := 1.0
  else
    lGroupCount := CMic185ChannelsPerModule;
  lChannelTimeUs := ASettings.GroundCommutationUs + CMic185NiosIrqDelayUs +
    ASettings.ChannelCommutationUs + CMic185NiosIrqDelayUs + 5.0 +
    2.0 * Mic185AverageExponentToPointCount(ASettings.AveragePointCount);
  if (lChannelTimeUs <= 0) or (lGroupCount <= 0) then
    Exit(0);
  Result := (1000000.0 / (lChannelTimeUs * lGroupCount)) * 0.90;
end;

function Mic185ChannelStartOffsetSec(
  const ASettings: TMic185ModuleProgramSettings;
  AOrderInGroup: Integer): Double;
var
  lAveragePoints: LongWord;
  lSampleTimeUs: Double;
begin
  if AOrderInGroup < 0 then
    Exit(0);
  lAveragePoints := Mic185AverageExponentToPointCount(
    ASettings.AveragePointCount);
  lSampleTimeUs := ASettings.GroundCommutationUs + CMic185NiosIrqDelayUs +
    ASettings.ChannelCommutationUs + CMic185NiosIrqDelayUs +
    2.0 * lAveragePoints + CMic185SpiTempDelayUs;
  Result := (lSampleTimeUs * AOrderInGroup - lAveragePoints -
    CMic185DriverStartOffsetUs) / 1000000.0;
end;

function Mic185BuildSettingsEx(AMeasFrequencyHz, ATempFrequencyHz: Double;
  AUtsEnabled: Boolean; ADeviceSerial, ASoftVersion: LongWord;
  const AChannelSettings: TMic185ChannelProgramSettingsArray;
  const AGroupAddition: TMic185GroupAdditionArray;
  ATemperatureCompensation: Boolean;
  const AModuleSettings: TMic185ModuleProgramSettings;
  APowerMaCode: LongWord): TRecorderByteArray;
var
  I: Integer;
  lSettings: TMic185BaseSettings;
  lChannel: TMic185ChannelProgramSettings;
begin
  FillChar(lSettings, SizeOf(lSettings), 0);

  for I := 0 to CMic185ChannelCountMax - 1 do
  begin
    lChannel := AChannelSettings[I];
    if lChannel.FrequencyHz <= 0 then
      lChannel.FrequencyHz := AMeasFrequencyHz;
    if lChannel.BlockSize = 0 then
      lChannel.BlockSize := 1;
    lSettings.Channels[I].FrequencyHz := lChannel.FrequencyHz;
    lSettings.Channels[I].Connected := lChannel.Connected;
    lSettings.Channels[I].BlockSize := lChannel.BlockSize;
    lSettings.Channels[I].MeasRangeIndex := lChannel.MeasRangeIndex;
    lSettings.Channels[I].SoftBalance := lChannel.SoftBalance;
    lSettings.Channels[I].CommutIndex := lChannel.CommutIndex;
    lSettings.Channels[I].ShuntOn := lChannel.ShuntOn;
    lSettings.Channels[I].EvalType := lChannel.EvalType;
    lSettings.Channels[I].TensoSensitivity := lChannel.TensoSensitivity;
    lSettings.Channels[I].Resistance := lChannel.Resistance;
    // схема подключения
    lSettings.Channels[I].SensorScheme := lChannel.SensorScheme;
  end;

  for I := CMic185ChannelCountMax to High(lSettings.Channels) do
    FillChar(lSettings.Channels[I], SizeOf(lSettings.Channels[I]), 0);

  for I := 0 to High(lSettings.TempChannels) do
  begin
    lSettings.TempChannels[I].FrequencyHz := ATempFrequencyHz;
    lSettings.TempChannels[I].Connected := True;
  end;

  lSettings.SerialNumber := ADeviceSerial;
  lSettings.GroundEnabled := True;
  lSettings.GroundCommutationUs := AModuleSettings.GroundCommutationUs;
  lSettings.ChannelCommutationUs := AModuleSettings.ChannelCommutationUs;
  lSettings.BalancePortionLength := AModuleSettings.BalancePortionLength;
  lSettings.HardBalance := AModuleSettings.HardBalance;
  lSettings.AveragePointCount := AModuleSettings.AveragePointCount;
  if APowerMaCode = 0 then
    lSettings.PowerMaCode := CMic185DefaultPowerMaCode
  else
    lSettings.PowerMaCode := APowerMaCode;
  lSettings.Reserved := 0;
  lSettings.MaxFreqMode := AModuleSettings.MaxFreqMode;
  lSettings.CalibrShuntIndex := AModuleSettings.CalibrShuntIndex;
  for I := 0 to High(lSettings.GroupAddition) do
    if AGroupAddition[I] <= CMic185ModAddOff then
      lSettings.GroupAddition[I] := AGroupAddition[I]
    else
      lSettings.GroupAddition[I] := CMic185ModAddOff;
  lSettings.DetermineBreak := AModuleSettings.DetermineBreak;
  lSettings.HardwareBalanceOn := AModuleSettings.HardwareBalanceOn;
  lSettings.TemperatureCompensation := ATemperatureCompensation;
  lSettings.SoftVersion := ASoftVersion;

  if not AUtsEnabled then
    ; // UTS flag is passed separately via SET_CONTROLLER_PARAMS

  SetLength(Result, SizeOf(lSettings));
  Move(lSettings, Result[0], SizeOf(lSettings));
end;

function Mic185PowerMaToCode(APowerMa: Double): LongWord;
begin
  if (APowerMa < -12.5) or (APowerMa > 12.5) then
    Exit(CMic185DefaultPowerMaCode);
  Result := Round((200.0 * (APowerMa / 1000.0) + 2.5) * 16384.0 / 5.0);
end;

function Mic185PowerCodeToMa(APowerMaCode: LongWord): Double;
begin
  if APowerMaCode > 16384 then
    Exit(0);
  Result := ((((APowerMaCode * 5.0) / 16384.0) - 2.5) / 200.0) * 1000.0;
end;

function Mic185BuildSettings(AMeasFrequencyHz, ATempFrequencyHz: Double;
  AUtsEnabled: Boolean; ADeviceSerial, ASoftVersion: LongWord): TRecorderByteArray;
var
  lChannelSettings: TMic185ChannelProgramSettingsArray;
  lGroupAddition: TMic185GroupAdditionArray;
  lModuleSettings: TMic185ModuleProgramSettings;
begin
  Mic185DefaultChannelProgramSettingsArray(AMeasFrequencyHz, lChannelSettings);
  Mic185DefaultGroupAdditionSettings(lGroupAddition);
  Mic185DefaultModuleProgramSettings(lModuleSettings);
  Result := Mic185BuildSettingsEx(AMeasFrequencyHz, ATempFrequencyHz, AUtsEnabled,
    ADeviceSerial, ASoftVersion, lChannelSettings, lGroupAddition, True,
    lModuleSettings);
end;

function Mic185FormatSoftVersion(AVersion: LongWord): string;
var
  lOmap, lNios, lFpga: Integer;
begin
  lOmap := (AVersion shr 20) and $FF;
  lNios := (AVersion shr 10) and $3F;
  lFpga := AVersion and $3F;
  Result := Format('%d.%d.%d', [lOmap, lNios, lFpga]);
end;

end.
