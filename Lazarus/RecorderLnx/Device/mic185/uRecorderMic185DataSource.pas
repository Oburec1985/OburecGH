unit uRecorderMic185DataSource;

{
  MIC183/185 data source for RecorderLnx.

  The protocol/device units in this folder are copies of the standalone
  Tests/mic185 implementation. This adapter binds them to RecorderLnx tags and
  data-source lifecycle.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, fpjson,
  uRecorderDataSources, uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uRecorderTags, uRecorderConfiguredDataSources,
  uMic185Device, uMic185Constants, uMic185MebiusTypes;

const
  { Endpoint стендового MIC-185 по умолчанию. }
  MIC185DefaultHost = '192.168.9.142';
  MIC185DefaultPort = 4000;
  MIC185DefaultPollFrequencyHz = CMic185DefaultMeasFrequencyHz;

{ Формирует SourceId RecorderLnx для MIC-185 endpoint. }
function RecorderMic185SourceId(const AHost: string; APort: Word): string;
{ Разбирает SourceId вида "MIC-185: host:port". }
function TryParseRecorderMic185SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
function RecorderIsHardwareMic185TagSource(const ASourceId: string): Boolean;
{ Читает серийный номер/версию прибора через безопасный probe. }
function RecorderMic185ReadDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AErrorText: string; ATimeoutMs: Cardinal = 700): Boolean;
{ Проверяет, что endpoint отвечает на идентификационный запрос. }
function RecorderMic185IsEndpointLive(const AHost: string; APort: Word): Boolean;
{ Проверяет live-device кэш активного источника. }
function RecorderMic185IsLiveDeviceConnected(const AHost: string; APort: Word): Boolean;
{ Проверяет живость источника по SourceId. }
function RecorderMic185IsSourceLinkOk(const ASourceId: string): Boolean;
{ Быстрая TCP/Mebius проба для дерева оборудования. }
function RecorderMic185TcpProbe(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
function RecorderMic185CleanupEndpoint(const AHost: string; APort: Word;
  out AErrorText: string; ATimeoutMs: Cardinal = 1500): Boolean;
{ Текст режима канала по умолчанию для хранения в старых проектах. }
function RecorderMic185DefaultChannelModeText(AFrequencyHz: Double): string;
function RecorderMic185NormalizeFrequency(AFrequencyHz: Double): Double;
procedure RecorderMic185ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double);
{ Сериализует настройки канала MIC-185 в компактную строку. }
function RecorderMic185FormatChannelMode(
  const ASettings: TMic185ChannelProgramSettings): string;
{ Десериализует строку режима канала с fallback на defaults. }
procedure RecorderMic185ReadChannelMode(const AMode: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings);
{ Получает аппаратные настройки канала из конфигурации источника. }
function RecorderMic185GetSourceChannelMode(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings): Boolean;
{ Сохраняет аппаратные настройки канала в конфигурации источника. }
procedure RecorderMic185SetSourceChannelMode(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  const ASettings: TMic185ChannelProgramSettings);
{ Возвращает физическую единицу канала из конфигурации источника. }
function RecorderMic185GetSourceChannelUnitName(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string): string;
{ Сохраняет физическую единицу канала в конфигурации источника. }
procedure RecorderMic185SetSourceChannelUnitName(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  const AUnitName: string);
{ Возвращает код тока питания датчика из конфигурации источника. }
function RecorderMic185GetSourcePowerMaCode(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): LongWord;
{ Сохраняет код тока питания датчика в конфигурации источника. }
procedure RecorderMic185SetSourcePowerMaCode(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double; APowerMaCode: LongWord);
{ Возвращает модульные настройки MIC-185 из конфигурации источника. }
procedure RecorderMic185GetSourceModuleSettings(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; out ASettings: TMic185ModuleProgramSettings);
{ Сохраняет модульные настройки MIC-185 в конфигурации источника. }
procedure RecorderMic185SetSourceModuleSettings(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double;
  const ASettings: TMic185ModuleProgramSettings);
{ Возвращает флаг аппаратной термокомпенсации из конфигурации источника. }
function RecorderMic185GetSourceTemperatureCompensation(
  ARegistry: TRecorderTagRegistry; const ASourceId: string): Boolean;
{ Сохраняет флаг термокомпенсации, не меняя назначение входов дополнений. }
procedure RecorderMic185SetSourceTemperatureCompensation(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  APollFrequencyHz: Double; ATemperatureCompensation: Boolean);
{ Программирует уже настроенный MIC-185 source без открытия общего диалога. }
function RecorderMic185ProgramConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; out AErrorText: string;
  const ATraceId: string = ''): Boolean;
function RecorderMic185ZeroBalanceChannels(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; const AChannelIndices: array of Integer;
  AMessages: TStrings): Boolean;
{ Текст номинального входного диапазона для UI. }
function RecorderMic185RangeText(ARangeIndex: LongWord): string;
{ Единица по умолчанию для выбранного диапазона. }
function RecorderMic185RangeUnitText(ARangeIndex: LongWord): string;
{ Верхняя граница номинального диапазона в мВ. }
function RecorderMic185RangeMax(ARangeIndex: LongWord): Double;
{ Преобразования балансировки MIC-185: в пакете прибора баланс хранится
  кодами, а в UI original Recorder программная балансировка задается
  физическим значением канала. }
function RecorderMic185SoftBalanceCodeToMv(ASoftBalance: LongInt;
  ARangeIndex: LongWord): Double;
function RecorderMic185SoftBalanceMvToCode(ASoftBalanceMv: Double;
  ARangeIndex: LongWord): LongInt;
function RecorderMic185HardBalanceCodeToMv(AHardBalance: LongWord): Double;
function RecorderMic185HardBalanceMvToCode(AHardBalanceMv: Double): LongWord;
{ Верхняя граница диапазона в выбранной пользователем единице. }
function RecorderMic185EffectiveRangeMax(
  const ASettings: TMic185ChannelProgramSettings; const AUnitName: string): Double;
function RecorderMic185EffectiveRangeMaxForTag(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const ASettings: TMic185ChannelProgramSettings;
  const AUnitName: string): Double;
{ Текст фактического диапазона для диалога канала. }
function RecorderMic185EffectiveRangeText(
  const ASettings: TMic185ChannelProgramSettings; const AUnitName: string): string;
function RecorderMic185EffectiveRangeTextForTag(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const ASettings: TMic185ChannelProgramSettings;
  const AUnitName: string): string;
{ Текст сводной линейной ГХ для текущего отображения тега. Сохраненная
  аппаратная ГХ остается исходной; здесь пересчитываются только K/B для UI. }
function RecorderMic185EffectiveTransformText(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const ASettings: TMic185ChannelProgramSettings;
  const AUnitName: string): string;
{ Пересчитывает измеренное MIC-185 значение в выбранную единицу тега. Основной
  поток MIC-185 отдаёт Single уже в мВ; аппаратная ГХ, если включена, уточняет
  это входное значение. }
function RecorderMic185ConvertValue(AValueMv: Double;
  const ASettings: TMic185ChannelProgramSettings; const AUnitName: string;
  AHardwareCalibration: TRecorderCalibration = nil;
  AEffectivePowerMa: Double = 0.0): Double;
{ Пересчитывает уже выраженное в мВ служебное значение в единицу канала,
  учитывая индивидуальную калибровку тока питания. }
function RecorderMic185ConvertUnitValueForTag(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; AValueMv: Double;
  const ASettings: TMic185ChannelProgramSettings;
  const AUnitName: string): Double;
{ Текст коммутации канала для таблицы настройки. }
function RecorderMic185CommutationText(ACommutIndex: LongWord): string;
{ Текст схемы включения датчика для таблицы настройки. }
function RecorderMic185SensorSchemeText(ASensorScheme: LongWord): string;
{ Возвращает индекс измерительного канала из адресов 155-3,
  185-{155-3} и старых MIC183_185-{3-3}. }
function RecorderMic185ChannelAddressToIndex(const AAddress: string): Integer;
function RecorderMic185MeasurementAddressText(ADeviceIndex,
  AChannelNumber: Integer): string;
function RecorderMic185TemperatureAddressText(ADeviceIndex,
  ATemperatureIndex: Integer): string;
function RecorderMic185UtsAddressText(ADeviceIndex: Integer): string;
{ Сравнивает разные допустимые записи одного канала MIC-185, например
  155-3, 185-{155-3} и старую MIC183_185-{3-3}. Источник данных должен
  сравниваться вызывающим кодом отдельно. }
function RecorderMic185SameChannelAddress(const ALeft, ARight: string): Boolean;
function RecorderMic185SourceDeviceIndex(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Integer;
{ Создает или возвращает конфигурацию источника MIC-185. }
function RecorderMic185EnsureConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double): TRecorderConfiguredDataSource;
procedure RecorderMic185SetKnownIdentity(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; ASerialNumber, ASoftVersion: LongWord);
function RecorderMic185GetKnownIdentity(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; out ASerialNumber, ASoftVersion: LongWord): Boolean;
{ Сохраняет MIC-185 секции dataSources[].mic185 в проект. }
procedure SaveMic185DataSourceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
{ Загружает MIC-185 секции dataSources[].mic185 из проекта. }
procedure LoadMic185DataSourceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
{ Берет идентификацию из активного live-device или runtime кэша. }
function RecorderMic185TryGetLiveDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AAcquiring: Boolean): Boolean;
{ Возвращает активный MIC-185 device, если endpoint уже принадлежит runtime. }
function RecorderMic185FindLiveDevice(const AHost: string; APort: Word): TRecorderMic185Device;
{ Регистрирует активный MIC-185 device для UI/probe без второго TCP-клиента. }
procedure RecorderMic185RegisterLiveDevice(AOwner: TObject; const AHost: string;
  APort: Word; ADevice: IRecorderDevice);
{ Снимает регистрацию live-device владельца. }
procedure RecorderMic185UnregisterLiveDevice(AOwner: TObject);
{ Пишет строку в MIC-185 runtime/debug log. }
procedure RecorderMic185Log(const AMessage: string);
function RecorderMic185NewLifecycleTraceId(const AOperation: string): string;
procedure RecorderMic185LifecycleLog(const ATraceId, ASourceId, APhase,
  AState, ADetails: string; AElapsedMs: QWord = 0);

type
  TRecorderMic185RuntimeUnit = (mruMillivolts, mruOhm, mruStrain);
  TRecorderCalibrationArray = array of TRecorderCalibration;

  TRecorderMic185ValueTransform = record
    IsLinear: Boolean;
    K: Double;
    B: Double;
    Settings: TMic185ChannelProgramSettings;
    UnitMode: TRecorderMic185RuntimeUnit;
    HardwareCalibration: TRecorderCalibration;
    ChannelCalibrations: TRecorderCalibrationArray;
    PowerMa: Double;
  end;

  TRecorderMic185DataSource = class(TRecorderDataSourceBase,
    IRecorderZeroBalanceSupport, IRecorderZeroBalanceTraceSupport)
  private
    fChannelTagNames: TStringList;
    fChannelTags: array of TRecorderTag;
    fValueTransforms: array of TRecorderMic185ValueTransform;
    fTempTags: array of TRecorderTag;
    fTimes: TRecorderDoubleArray;
    fUtsTag: TRecorderTag;
    fValues: TRecorderDoubleArray;
    fDevice: IRecorderDevice;
    fHost: string;
    fHardwarePrepared: Boolean;
    fHardwarePrepareAttempted: Boolean;
    fPort: Word;
    fPollFrequencyHz: Double;
    fDiagTick: QWord;
    fDiagBlocks: QWord;
    fLastRxPackets: QWord;
    fLastRxBlocks: QWord;
    fLastRxTick: QWord;
    fLastBlockTick: QWord;
    fRxWarning: Boolean;
    fLastPublishedUtsGeneration: QWord;
    fUtsPublishLogCount: Integer;
    fRuntimeChannelSettings: TMic185ChannelProgramSettingsArray;
    fSelectedNames: TStringList;
    fZeroBalanceTrace: TRecorderZeroBalanceTraceEvent;
    function ChannelSelected(const AChannel: TRecorderDeviceChannel): Boolean;
    function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    procedure ApplyChannelProgramSettings;
    procedure CacheRuntimeChannels;
    procedure ConfigureDevice;
    procedure PublishMeasurementBlock(const ABlock: TRecorderAcquisitionBlock);
    procedure PublishAuxChannels(ATimeSec: Double);
    procedure TraceZeroBalance(const AText: string);
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
    procedure PrepareHardware; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
      ASelectedNames: TStrings = nil);
    destructor Destroy; override;
    procedure RequestStop; override;
    procedure Start; override;
    procedure Stop; override;
    function ZeroBalanceTags(AOwner: TComponent; ATags: TList;
      AMessages: TStrings): Boolean;
    procedure SetZeroBalanceTrace(AHandler: TRecorderZeroBalanceTraceEvent);
  end;

implementation

uses
  Math, StrUtils, Variants,
  jsonparser, uMic185MebiusTcpProtocol, uRecorderMic185Runtime,
  uRecorderHardwareLiveDevices, uRecorderMic140Utils, uRecorderMic185Calibration,
  uRecorderProjectFiles, uRecorderHardwareTree, uRecorderNetworkBinding,
  uRecorderDebugLog, uRecorderDeviceConfigSignature, uRecorderFrequencyGrids;

const
  CMic185SourcePrefix = 'MIC-185: ';
  CMic185ModuleName = 'MIC183/185';
  CMic185ChannelModePrefix = 'mic185:';
  { Fallback scale when no real hardware characteristic is loaded:
    32768 ADC codes correspond to 100% of the selected nominal input range. }
  CMic185NominalAdcFullScale = 32768.0;
  CMic185ParallelStartSlotMs = 150;
  CMic185PrepareCommandSlots = 2;
  CMic185ZeroBalanceFineDiscardBlocks = 1;
  CMic185ZeroBalanceFineBlocks = 4;
  CMic185ZeroBalanceFineReadTimeoutMs = 700;
  CMic185ZeroBalanceFineSettleMs = 150;
  CMic185ZeroBalanceFineTotalWaitMs = 2200;
  CMic185ZeroBalanceFinePollMs = 50;
  CMic185Frequencies: array[0..4] of Double =
    (1.0, 10.0, 25.0, 50.0, 100.0);

var
  gMic185PrepareLock: TRTLCriticalSection;
  gMic185PrepareCommandActive: Integer = 0;

function Mic185RuntimeUnitFromName(const AUnitName: string;
  ARangeIndex: LongWord): TRecorderMic185RuntimeUnit; forward;
procedure Mic185ApplyUnitLine(var AK, AB: Double;
  const ASettings: TMic185ChannelProgramSettings;
  AUnitMode: TRecorderMic185RuntimeUnit; APowerMa: Double); forward;

procedure Mic185EnterPrepareCommandSlot(const ATraceId, ASourceId: string);
var
  lStartedAt: QWord;
  lLoggedWait: Boolean;
begin
  lStartedAt := GetTickCount64;
  lLoggedWait := False;
  while True do
  begin
    EnterCriticalSection(gMic185PrepareLock);
    try
      if gMic185PrepareCommandActive < CMic185PrepareCommandSlots then
      begin
        Inc(gMic185PrepareCommandActive);
        RecorderMic185LifecycleLog(ATraceId, ASourceId, 'prepare-command-slot',
          'OK', Format('active=%d limit=%d',
            [gMic185PrepareCommandActive, CMic185PrepareCommandSlots]),
          GetTickCount64 - lStartedAt);
        Exit;
      end;
    finally
      LeaveCriticalSection(gMic185PrepareLock);
    end;

    if not lLoggedWait then
    begin
      RecorderMic185LifecycleLog(ATraceId, ASourceId, 'prepare-command-slot',
        'BEGIN', Format('limit=%d', [CMic185PrepareCommandSlots]));
      lLoggedWait := True;
    end;
    Sleep(50);
  end;
end;

procedure Mic185LeavePrepareCommandSlot;
begin
  EnterCriticalSection(gMic185PrepareLock);
  try
    if gMic185PrepareCommandActive > 0 then
      Dec(gMic185PrepareCommandActive);
  finally
    LeaveCriticalSection(gMic185PrepareLock);
  end;
end;

function Mic185EndpointStartDelayMs(const AHost: string): Cardinal;
var
  lLastDot: Integer;
  lOctet: Integer;
begin
  Result := 0;
  lLastDot := RPos('.', Trim(AHost));
  if (lLastDot > 0) and TryStrToInt(Copy(Trim(AHost), lLastDot + 1,
    MaxInt), lOctet) then
    Result := Cardinal((lOctet mod 10) * CMic185ParallelStartSlotMs);
end;

function Mic185CanonicalAddress(const AAddress: string): string;
var
  lStart: Integer;
  lDash: Integer;
  lDeviceIndex: Integer;
  lChannelNumber: Integer;
  lTail: string;
begin
  Result := Trim(AAddress);
  if Pos('MIC183_185-', UpperCase(Result)) = 1 then
    Result := Copy(Result, Length('MIC183_185-') + 1, MaxInt)
  else if Pos('185-', UpperCase(Result)) = 1 then
    Result := Copy(Result, Length('185-') + 1, MaxInt);
  lStart := Pos('{', Result);
  if lStart > 0 then
    Delete(Result, lStart, 1);
  if (Result <> '') and (Result[Length(Result)] = '}') then
    Delete(Result, Length(Result), 1);
  lDash := Pos('-', Result);
  if lDash <= 0 then
    Exit;
  lTail := Copy(Result, lDash + 1, MaxInt);
  if (lTail = '') or (Pos('t', LowerCase(lTail)) > 0) or
    SameText(lTail, 'uts') then
    Exit;
  if TryStrToInt(Copy(Result, 1, lDash - 1), lDeviceIndex) and
    TryStrToInt(lTail, lChannelNumber) then
    Result := RecorderMic185MeasurementAddressText(lDeviceIndex,
      lChannelNumber);
end;

function RecorderMic185MeasurementAddressText(ADeviceIndex,
  AChannelNumber: Integer): string;
begin
  Result := Format('%d-%2.2d', [ADeviceIndex, AChannelNumber]);
end;

function RecorderMic185TemperatureAddressText(ADeviceIndex,
  ATemperatureIndex: Integer): string;
begin
  Result := Format('%d-t%d', [ADeviceIndex, ATemperatureIndex]);
end;

function RecorderMic185UtsAddressText(ADeviceIndex: Integer): string;
begin
  Result := Format('%d-uts', [ADeviceIndex]);
end;

function SameMic185Address(const ALeft, ARight: string): Boolean;
begin
  Result := SameText(Mic185CanonicalAddress(ALeft),
    Mic185CanonicalAddress(ARight));
  if not Result then
    Result := SameText(Copy(Mic185CanonicalAddress(ALeft),
      Pos('-', Mic185CanonicalAddress(ALeft)) + 1, MaxInt),
      Copy(Mic185CanonicalAddress(ARight),
      Pos('-', Mic185CanonicalAddress(ARight)) + 1, MaxInt));
end;

function RecorderMic185SourceDeviceIndex(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): Integer;
var
  lHost: string;
  lPort: Word;
  lPos: Integer;
begin
  Result := 3;
  if not TryParseRecorderMic185SourceId(
    RecorderNormalizeTagSourceId(ASourceId), lHost, lPort) then
    Exit;
  lPos := RPos('.', lHost);
  if (lPos > 0) and TryStrToInt(Copy(lHost, lPos + 1, MaxInt), Result) and
    (Result >= 0) and (Result <= 255) then
    Exit;
  Result := 3;
end;

function RecorderIsHardwareMic185TagSource(const ASourceId: string): Boolean;
begin
  Result := Pos(CMic185SourcePrefix,
    RecorderNormalizeTagSourceId(ASourceId)) = 1;
end;

function RecorderMic185HardwareLinkProbe(const ASourceId: string): Boolean;
begin
  Result := RecorderMic185IsSourceLinkOk(ASourceId);
end;

function Mic185FloatToText(AValue: Double): string;
begin
  Result := StringReplace(FormatFloat('0.######', AValue), ',', '.', []);
end;

function Mic185TextToFloatDef(const AText: string; ADefault: Double): Double;
var
  lText: string;
begin
  lText := Trim(AText);
  if TryStrToFloat(lText, Result) then
    Exit;
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator, []);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator, []);
  if not TryStrToFloat(lText, Result) then
    Result := ADefault;
end;

function Mic185TextToIntDef(const AText: string; ADefault: Integer): Integer;
begin
  if not TryStrToInt(Trim(AText), Result) then
    Result := ADefault;
end;

function RecorderMic185FormatChannelMode(
  const ASettings: TMic185ChannelProgramSettings): string;
begin
  Result := Format(
    '%srange=%d;commut=%d;scheme=%d;soft=%d;softFine=%s;shunt=%d;eval=%d;sens=%s;res=%s;block=%d;power=%d',
    [CMic185ChannelModePrefix, ASettings.MeasRangeIndex, ASettings.CommutIndex,
     ASettings.SensorScheme, ASettings.SoftBalance,
     Mic185FloatToText(ASettings.SoftBalanceFine), ASettings.ShuntOn,
     ASettings.EvalType, Mic185FloatToText(ASettings.TensoSensitivity),
     Mic185FloatToText(ASettings.Resistance), ASettings.BlockSize,
     ASettings.PowerMaCode]);
end;

function RecorderMic185DefaultChannelModeText(AFrequencyHz: Double): string;
var
  lSettings: TMic185ChannelProgramSettings;
begin
  Mic185DefaultChannelProgramSettings(AFrequencyHz, lSettings);
  Result := RecorderMic185FormatChannelMode(lSettings);
end;

function RecorderMic185NormalizeFrequency(AFrequencyHz: Double): Double;
var
  I: Integer;
  lBestDelta: Double;
  lDelta: Double;
begin
  Result := CMic185Frequencies[0];
  lBestDelta := Abs(AFrequencyHz - Result);
  for I := 1 to High(CMic185Frequencies) do
  begin
    lDelta := Abs(AFrequencyHz - CMic185Frequencies[I]);
    if lDelta < lBestDelta then
    begin
      Result := CMic185Frequencies[I];
      lBestDelta := lDelta;
    end;
  end;
end;

procedure RecorderMic185ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double);
var
  I: Integer;
  lCapacity: Integer;
  lFrequencyHz: Double;
  lOldFrequencyHz: Double;
  lSettings: TMic185ChannelProgramSettings;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or (Trim(ASourceId) = '') then
    Exit;

  lSourceId := RecorderNormalizeTagSourceId(ASourceId);
  lFrequencyHz := RecorderMic185NormalizeFrequency(AFrequencyHz);
  lCapacity := Ceil(Max(4096, lFrequencyHz * 4));
  RecorderConfiguredDataSourcesEnsure(ARegistry, lSourceId,
    CMic185ModuleName, lFrequencyHz);

  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if (not SameText(RecorderNormalizeTagSourceId(lTag.SourceId),
      lSourceId)) or (RecorderMic185ChannelAddressToIndex(lTag.Address) <= 0)
      then
      Continue;

    lOldFrequencyHz := lTag.PollFrequencyHz;
    if lOldFrequencyHz <= 0 then
      lOldFrequencyHz := lFrequencyHz;
    RecorderMic185GetSourceChannelMode(ARegistry, lSourceId, lTag.Address,
      lOldFrequencyHz, lSettings);
    lSettings.FrequencyHz := lFrequencyHz;
    lTag.PollFrequencyHz := lFrequencyHz;
    lTag.EnsureBufferCapacity(lCapacity);
    RecorderMic185SetSourceChannelMode(ARegistry, lSourceId, lTag.Address,
      lFrequencyHz, lSettings);
  end;
end;

function Mic185ModeValue(const AMode, AKey: string; const ADefault: string): string;
var
  I, lPos: Integer;
  lItems: TStringList;
  lName: string;
begin
  Result := ADefault;
  lItems := TStringList.Create;
  try
    lItems.Delimiter := ';';
    lItems.StrictDelimiter := True;
    lItems.DelimitedText := AMode;
    for I := 0 to lItems.Count - 1 do
    begin
      lPos := Pos('=', lItems[I]);
      if lPos <= 0 then
        Continue;
      lName := Trim(Copy(lItems[I], 1, lPos - 1));
      if SameText(lName, AKey) then
      begin
        Result := Trim(Copy(lItems[I], lPos + 1, MaxInt));
        Exit;
      end;
    end;
  finally
    lItems.Free;
  end;
end;

procedure RecorderMic185ReadChannelMode(const AMode: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings);
var
  lMode: string;
begin
  Mic185DefaultChannelProgramSettings(AFrequencyHz, ASettings);
  lMode := Trim(AMode);
  if SameText(Copy(lMode, 1, Length(CMic185ChannelModePrefix)),
    CMic185ChannelModePrefix) then
  begin
    Delete(lMode, 1, Length(CMic185ChannelModePrefix));
    ASettings.MeasRangeIndex :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'range',
      IntToStr(CMic185Range5mV)), CMic185Range5mV));
    ASettings.CommutIndex :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'commut',
      IntToStr(CMic185CommutInput)), CMic185CommutInput));
    ASettings.SensorScheme :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'scheme',
      IntToStr(CMic185SensorSchemeTenzo)), CMic185SensorSchemeTenzo));
    ASettings.SoftBalance :=
      Mic185TextToIntDef(Mic185ModeValue(lMode, 'soft', '0'), 0);
    ASettings.SoftBalanceFine :=
      Mic185TextToFloatDef(Mic185ModeValue(lMode, 'softFine', '0'), 0);
    ASettings.ShuntOn :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'shunt', '0'), 0));
    ASettings.EvalType :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'eval', '0'), 0));
    ASettings.TensoSensitivity :=
      Mic185TextToFloatDef(Mic185ModeValue(lMode, 'sens', '2'), 2);
    ASettings.Resistance :=
      Mic185TextToFloatDef(Mic185ModeValue(lMode, 'res', '200'), 200);
    ASettings.BlockSize :=
      Word(Mic185TextToIntDef(Mic185ModeValue(lMode, 'block', '1'), 1));
    ASettings.PowerMaCode :=
      LongWord(Mic185TextToIntDef(Mic185ModeValue(lMode, 'power',
      IntToStr(CMic185DefaultPowerMaCode)), CMic185DefaultPowerMaCode));
    if ASettings.BlockSize = 0 then
      ASettings.BlockSize := 1;
    Exit;
  end;

  if lMode <> '' then
  begin
    if (Pos('49', lMode) > 0) or (Pos('39', lMode) > 0) then
      ASettings.CommutIndex := CMic185CommutCalibr
    else if Pos('Зем', lMode) > 0 then
      ASettings.CommutIndex := CMic185CommutGround
    else
      ASettings.CommutIndex := CMic185CommutInput;
  end;
end;

function Mic185SourceConfigObject(AEntry: TRecorderConfiguredDataSource;
  ACreate: Boolean): TJSONObject;
var
  lData: TJSONData;
begin
  Result := nil;
  if AEntry = nil then
    Exit;
  if Trim(AEntry.SpecificConfigText) = '' then
  begin
    if ACreate then
      Result := TJSONObject.Create;
    Exit;
  end;
  try
    lData := GetJSON(AEntry.SpecificConfigText);
  except
    lData := nil;
  end;
  if lData is TJSONObject then
    Result := TJSONObject(lData)
  else
  begin
    lData.Free;
    if ACreate then
      Result := TJSONObject.Create;
  end;
end;

procedure Mic185StoreSourceConfigObject(AEntry: TRecorderConfiguredDataSource;
  AConfig: TJSONObject);
begin
  if (AEntry = nil) or (AConfig = nil) then
    Exit;
  AEntry.SpecificConfigText := AConfig.AsJSON;
end;

function Mic185ConfigChannels(AConfig: TJSONObject;
  ACreate: Boolean): TJSONArray;
var
  lData: TJSONData;
begin
  Result := nil;
  if AConfig = nil then
    Exit;
  lData := AConfig.Find('channels');
  if lData is TJSONArray then
    Exit(TJSONArray(lData));
  if not ACreate then
    Exit;
  Result := TJSONArray.Create;
  AConfig.Add('channels', Result);
end;

function RecorderMic185GetSourceChannelMode(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettings): Boolean;
var
  I: Integer;
  lChannels: TJSONArray;
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
  lItem: TJSONObject;
  lMode: string;
begin
  Result := False;
  Mic185DefaultChannelProgramSettings(AFrequencyHz, ASettings);
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  lConfig := Mic185SourceConfigObject(lEntry, False);
  try
    lChannels := Mic185ConfigChannels(lConfig, False);
    if lChannels = nil then
      Exit;
    for I := 0 to lChannels.Count - 1 do
    begin
      if not (lChannels.Items[I] is TJSONObject) then
        Continue;
      lItem := TJSONObject(lChannels.Items[I]);
      if not SameMic185Address(lItem.Get('address', ''), AAddress) then
        Continue;
      lMode := lItem.Get('sourceValueMode', '');
      RecorderMic185ReadChannelMode(lMode, AFrequencyHz, ASettings);
      Result := Trim(lMode) <> '';
      Exit;
    end;
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185SetSourceChannelMode(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  const ASettings: TMic185ChannelProgramSettings);
var
  I: Integer;
  lIndex: Integer;
  lChannels: TJSONArray;
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
  lItem: TJSONObject;
begin
  lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId,
    CMic185ModuleName, AFrequencyHz);
  lConfig := Mic185SourceConfigObject(lEntry, True);
  try
    lChannels := Mic185ConfigChannels(lConfig, True);
    lItem := nil;
    for I := 0 to lChannels.Count - 1 do
      if (lChannels.Items[I] is TJSONObject) and
        SameMic185Address(TJSONObject(lChannels.Items[I]).Get('address', ''),
          AAddress) then
      begin
        lItem := TJSONObject(lChannels.Items[I]);
        Break;
      end;
    if lItem = nil then
    begin
      lItem := TJSONObject.Create;
      lChannels.Add(lItem);
      lItem.Add('address', AAddress);
    end;
    lIndex := lItem.IndexOfName('sourceValueMode');
    if lIndex >= 0 then
      lItem.Delete(lIndex);
    lIndex := lItem.IndexOfName('pollFrequencyHz');
    if lIndex >= 0 then
      lItem.Delete(lIndex);
    lItem.Add('sourceValueMode', RecorderMic185FormatChannelMode(ASettings));
    lItem.Add('pollFrequencyHz', AFrequencyHz);
    Mic185StoreSourceConfigObject(lEntry, lConfig);
  finally
    lConfig.Free;
  end;
end;

function RecorderMic185GetSourceChannelUnitName(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string): string;
var
  I: Integer;
  lChannels: TJSONArray;
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
  lItem: TJSONObject;
begin
  Result := '';
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  lConfig := Mic185SourceConfigObject(lEntry, False);
  try
    lChannels := Mic185ConfigChannels(lConfig, False);
    if lChannels = nil then
      Exit;
    for I := 0 to lChannels.Count - 1 do
    begin
      if not (lChannels.Items[I] is TJSONObject) then
        Continue;
      lItem := TJSONObject(lChannels.Items[I]);
      if SameMic185Address(lItem.Get('address', ''), AAddress) then
        Exit(Trim(lItem.Get('unitName', '')));
    end;
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185SetSourceChannelUnitName(ARegistry: TRecorderTagRegistry;
  const ASourceId, AAddress: string; AFrequencyHz: Double;
  const AUnitName: string);
var
  I: Integer;
  lChannels: TJSONArray;
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
  lIndex: Integer;
  lItem: TJSONObject;
  lUnitName: string;
begin
  lUnitName := Trim(AUnitName);
  if (ARegistry = nil) or (lUnitName = '') or SameText(lUnitName, 'код') or
    SameText(lUnitName, 'code') then
    Exit;
  lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId,
    CMic185ModuleName, AFrequencyHz);
  lConfig := Mic185SourceConfigObject(lEntry, True);
  try
    lChannels := Mic185ConfigChannels(lConfig, True);
    lItem := nil;
    for I := 0 to lChannels.Count - 1 do
      if (lChannels.Items[I] is TJSONObject) and
        SameMic185Address(TJSONObject(lChannels.Items[I]).Get('address', ''),
          AAddress) then
      begin
        lItem := TJSONObject(lChannels.Items[I]);
        Break;
      end;
    if lItem = nil then
    begin
      lItem := TJSONObject.Create;
      lChannels.Add(lItem);
      lItem.Add('address', AAddress);
    end;
    lIndex := lItem.IndexOfName('unitName');
    if lIndex >= 0 then
      lItem.Delete(lIndex);
    lItem.Add('unitName', lUnitName);
    Mic185StoreSourceConfigObject(lEntry, lConfig);
  finally
    lConfig.Free;
  end;
end;

function RecorderMic185GetSourcePowerMaCode(ARegistry: TRecorderTagRegistry;
  const ASourceId: string): LongWord;
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
begin
  Result := CMic185DefaultPowerMaCode;
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  lConfig := Mic185SourceConfigObject(lEntry, False);
  try
    if lConfig <> nil then
      Result := LongWord(lConfig.Get('powerMaCode',
        Integer(CMic185DefaultPowerMaCode)));
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185SetSourcePowerMaCode(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double; APowerMaCode: LongWord);
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
  lIndex: Integer;
begin
  lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId,
    CMic185ModuleName, APollFrequencyHz);
  lConfig := Mic185SourceConfigObject(lEntry, True);
  try
    lIndex := lConfig.IndexOfName('powerMaCode');
    if lIndex >= 0 then
      lConfig.Delete(lIndex);
    if APowerMaCode = 0 then
      APowerMaCode := CMic185DefaultPowerMaCode;
    lConfig.Add('powerMaCode', Integer(APowerMaCode));
    Mic185StoreSourceConfigObject(lEntry, lConfig);
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185GetSourceModuleSettings(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; out ASettings: TMic185ModuleProgramSettings);
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
begin
  Mic185DefaultModuleProgramSettings(ASettings);
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  lConfig := Mic185SourceConfigObject(lEntry, False);
  try
    if lConfig = nil then
      Exit;
    ASettings.GroundCommutationUs := LongWord(lConfig.Get(
      'groundCommutationUs', Integer(ASettings.GroundCommutationUs)));
    ASettings.ChannelCommutationUs := LongWord(lConfig.Get(
      'channelCommutationUs', Integer(ASettings.ChannelCommutationUs)));
    ASettings.BalancePortionLength := LongWord(lConfig.Get(
      'balancePortionLength', Integer(ASettings.BalancePortionLength)));
    ASettings.HardBalance := LongWord(lConfig.Get('hardBalance',
      Integer(ASettings.HardBalance)));
    ASettings.AveragePointCount := Word(lConfig.Get('averagePointCount',
      Integer(ASettings.AveragePointCount)));
    ASettings.MaxFreqMode := LongWord(lConfig.Get('maxFreqMode',
      Integer(ASettings.MaxFreqMode)));
    ASettings.CalibrShuntIndex := LongWord(lConfig.Get('calibrShuntIndex',
      Integer(ASettings.CalibrShuntIndex)));
    ASettings.DetermineBreak := lConfig.Get('determineBreak',
      ASettings.DetermineBreak);
    ASettings.HardwareBalanceOn := lConfig.Get('hardwareBalanceOn',
      ASettings.HardwareBalanceOn);
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185StoreSourceModuleSettings(AConfig: TJSONObject;
  const ASettings: TMic185ModuleProgramSettings);
var
  lIndex: Integer;

  procedure ReplaceInteger(const AName: string; AValue: LongInt);
  begin
    lIndex := AConfig.IndexOfName(AName);
    if lIndex >= 0 then
      AConfig.Delete(lIndex);
    AConfig.Add(AName, AValue);
  end;

  procedure ReplaceBoolean(const AName: string; AValue: Boolean);
  begin
    lIndex := AConfig.IndexOfName(AName);
    if lIndex >= 0 then
      AConfig.Delete(lIndex);
    AConfig.Add(AName, AValue);
  end;

begin
  if AConfig = nil then
    Exit;
  ReplaceInteger('groundCommutationUs', Integer(ASettings.GroundCommutationUs));
  ReplaceInteger('channelCommutationUs', Integer(ASettings.ChannelCommutationUs));
  ReplaceInteger('balancePortionLength', Integer(ASettings.BalancePortionLength));
  ReplaceInteger('hardBalance', Integer(ASettings.HardBalance));
  ReplaceInteger('averagePointCount', Integer(ASettings.AveragePointCount));
  ReplaceInteger('maxFreqMode', Integer(ASettings.MaxFreqMode));
  ReplaceInteger('calibrShuntIndex', Integer(ASettings.CalibrShuntIndex));
  ReplaceBoolean('determineBreak', ASettings.DetermineBreak);
  ReplaceBoolean('hardwareBalanceOn', ASettings.HardwareBalanceOn);
end;

procedure RecorderMic185SetSourceModuleSettings(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double;
  const ASettings: TMic185ModuleProgramSettings);
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
begin
  lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId,
    CMic185ModuleName, APollFrequencyHz);
  lConfig := Mic185SourceConfigObject(lEntry, True);
  try
    RecorderMic185StoreSourceModuleSettings(lConfig, ASettings);
    Mic185StoreSourceConfigObject(lEntry, lConfig);
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185GetSourceGroupAddition(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; out AGroupAddition: TMic185GroupAdditionArray);
var
  I: Integer;
  lConfig: TJSONObject;
  lData: TJSONData;
  lEntry: TRecorderConfiguredDataSource;
  lValue: Integer;
begin
  Mic185DefaultGroupAdditionSettings(AGroupAddition);
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  lConfig := Mic185SourceConfigObject(lEntry, False);
  try
    if lConfig = nil then
      Exit;
    lData := lConfig.Find('groupAddition');
    if not (lData is TJSONArray) then
      Exit;
    for I := 0 to Min(High(AGroupAddition), TJSONArray(lData).Count - 1) do
    begin
      lValue := TJSONArray(lData).Items[I].AsInteger;
      if (lValue >= Integer(CMic185ModAdd1)) and
        (lValue <= Integer(CMic185ModAddOff)) then
        AGroupAddition[I] := LongWord(lValue);
    end;
  finally
    lConfig.Free;
  end;
end;

function RecorderMic185GetSourceTemperatureCompensation(
  ARegistry: TRecorderTagRegistry; const ASourceId: string): Boolean;
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
begin
  Result := True;
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  lConfig := Mic185SourceConfigObject(lEntry, False);
  try
    if lConfig <> nil then
      Result := lConfig.Get('temperatureCompensation', True);
  finally
    lConfig.Free;
  end;
end;

procedure RecorderMic185StoreSourceCompensation(AConfig: TJSONObject;
  const AGroupAddition: TMic185GroupAdditionArray;
  ATemperatureCompensation: Boolean);
var
  I: Integer;
  lArray: TJSONArray;
  lIndex: Integer;
begin
  if AConfig = nil then
    Exit;
  lIndex := AConfig.IndexOfName('temperatureCompensation');
  if lIndex >= 0 then
    AConfig.Delete(lIndex);
  lIndex := AConfig.IndexOfName('groupAddition');
  if lIndex >= 0 then
    AConfig.Delete(lIndex);
  AConfig.Add('temperatureCompensation', ATemperatureCompensation);
  lArray := TJSONArray.Create;
  AConfig.Add('groupAddition', lArray);
  for I := 0 to High(AGroupAddition) do
    lArray.Add(Integer(AGroupAddition[I]));
end;

procedure RecorderMic185SetSourceTemperatureCompensation(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  APollFrequencyHz: Double; ATemperatureCompensation: Boolean);
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
  lGroupAddition: TMic185GroupAdditionArray;
begin
  RecorderMic185GetSourceGroupAddition(ARegistry, ASourceId, lGroupAddition);
  lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId,
    CMic185ModuleName, APollFrequencyHz);
  lConfig := Mic185SourceConfigObject(lEntry, True);
  try
    RecorderMic185StoreSourceCompensation(lConfig, lGroupAddition,
      ATemperatureCompensation);
    Mic185StoreSourceConfigObject(lEntry, lConfig);
  finally
    lConfig.Free;
  end;
end;

function RecorderMic185FormatGroupAddition(
  const AGroupAddition: TMic185GroupAdditionArray): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(AGroupAddition) do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + IntToStr(AGroupAddition[I]);
  end;
  Result := '[' + Result + ']';
end;

procedure RecorderMic185BuildSourceProgramSettings(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double;
  out ASettings: TMic185ChannelProgramSettingsArray);
var
  I: Integer;
  lAddress: string;
  lDeviceIndex: Integer;
  lPowerMaCode: LongWord;
begin
  Mic185DefaultChannelProgramSettingsArray(AFrequencyHz, ASettings);
  lPowerMaCode := RecorderMic185GetSourcePowerMaCode(ARegistry, ASourceId);
  lDeviceIndex := RecorderMic185SourceDeviceIndex(ARegistry, ASourceId);
  for I := 0 to CMic185ChannelCountMax - 1 do
  begin
    lAddress := RecorderMic185MeasurementAddressText(lDeviceIndex, I + 1);
    RecorderMic185GetSourceChannelMode(ARegistry, ASourceId, lAddress,
      AFrequencyHz, ASettings[I]);
    if ASettings[I].FrequencyHz <= 0 then
      ASettings[I].FrequencyHz := AFrequencyHz;
    ASettings[I].Connected := True;
    ASettings[I].PowerMaCode := lPowerMaCode;
  end;
end;

function RecorderMic185ProgramConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; out AErrorText: string;
  const ATraceId: string): Boolean;
var
  I: Integer;
  lDevice: IRecorderDevice;
  lGroupAddition: TMic185GroupAdditionArray;
  lHost: string;
  lNative: TRecorderMic185Device;
  lLiveNative: TRecorderMic185Device;
  lModuleSettings: TMic185ModuleProgramSettings;
  lKnownSerial, lKnownVersion: LongWord;
  lInitializeOk: Boolean;
  lPollHz: Double;
  lPort: Word;
  lSettings: TMic185ChannelProgramSettingsArray;
  lSummary: string;
  lTemperatureCompensation: Boolean;
  lTraceId: string;
  lStageStartedAt: QWord;
begin
  Result := False;
  AErrorText := '';
  if not TryParseRecorderMic185SourceId(ASourceId, lHost, lPort) then
  begin
    AErrorText := 'Invalid MIC183/185 source id';
    Exit;
  end;
  lTraceId := Trim(ATraceId);
  if lTraceId = '' then
    lTraceId := RecorderMic185NewLifecycleTraceId('configure');
  RecorderMic185LifecycleLog(lTraceId, ASourceId, 'operation', 'BEGIN',
    Format('endpoint=%s:%d bind=%s', [lHost, lPort,
      RecorderNetworkBindAddress]));
  lPollHz := MIC185DefaultPollFrequencyHz;
  if RecorderConfiguredDataSourcesFind(ARegistry, ASourceId) <> nil then
    if RecorderConfiguredDataSourcesFind(ARegistry, ASourceId).DefaultPollFrequencyHz > 0 then
      lPollHz := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId).DefaultPollFrequencyHz;

  RecorderMic185BuildSourceProgramSettings(ARegistry, ASourceId, lPollHz,
    lSettings);
  RecorderMic185GetSourceGroupAddition(ARegistry, ASourceId, lGroupAddition);
  RecorderMic185GetSourceModuleSettings(ARegistry, ASourceId, lModuleSettings);
  lTemperatureCompensation :=
    RecorderMic185GetSourceTemperatureCompensation(ARegistry, ASourceId);
  lSummary := Format('channels=%d first(range=%d commut=%d block=%d) '
    + 'last(range=%d commut=%d block=%d)',
    [Length(lSettings), lSettings[0].MeasRangeIndex,
     lSettings[0].CommutIndex, lSettings[0].BlockSize,
     lSettings[High(lSettings)].MeasRangeIndex,
     lSettings[High(lSettings)].CommutIndex,
     lSettings[High(lSettings)].BlockSize]);
  RecorderMic185Log(Format(
    'ProgramConfiguredSource %s power=%d tkc=%s avg=%d/%d max=%.3fHz groupAddition=%s: %s',
    [ASourceId, lSettings[0].PowerMaCode,
     BoolToStr(lTemperatureCompensation, True),
     lModuleSettings.AveragePointCount,
     Mic185AverageExponentToPointCount(lModuleSettings.AveragePointCount),
     Mic185CalcMaxFrequencyHz(lModuleSettings),
     RecorderMic185FormatGroupAddition(lGroupAddition), lSummary]));

  { The running data source owns the only TCP session for this endpoint.
    Explicit hardware settings Apply/OK must still program the device, so use
    the already opened live device instead of opening a second TCP client. }
  lLiveNative := RecorderMic185FindLiveDevice(lHost, lPort);
  if lLiveNative <> nil then
  begin
    lLiveNative.ApplyChannelProgramSettings(lSettings, lGroupAddition,
      lTemperatureCompensation, lModuleSettings);
    try
      if lLiveNative.State = rdsStarted then
        lLiveNative.Stop;
      lStageStartedAt := GetTickCount64;
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'configure-live',
        'BEGIN', '');
      if not lLiveNative.TryProgramDevice(AErrorText) then
      begin
        RecorderMic185LifecycleLog(lTraceId, ASourceId, 'configure-live',
          'FAIL', AErrorText, GetTickCount64 - lStageStartedAt);
        AErrorText := 'MIC183/185 live programming failed: ' + AErrorText;
        RecorderMic185Log(Format('ProgramConfiguredSource failed live %s: %s',
          [ASourceId, AErrorText]));
        Exit;
      end;
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'configure-live', 'OK',
        '', GetTickCount64 - lStageStartedAt);
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'operation', 'OK',
        'live device programmed');
      RecorderMarkSourceProgrammingApplied(ARegistry, ASourceId);
      Exit(True);
    except
      on E: Exception do
      begin
        AErrorText := E.Message;
        RecorderMic185LifecycleLog(lTraceId, ASourceId, 'configure-live',
          'EXCEPTION', E.ClassName + ': ' + E.Message);
        RecorderMic185Log(Format('ProgramConfiguredSource failed live %s: %s',
          [ASourceId, AErrorText]));
        Exit;
      end;
    end;
  end;

  lDevice := CreateRecorderMic185Device;
  try
    lDevice.TrySetDeviceProperty(rdpHost, lHost);
    lDevice.TrySetDeviceProperty(rdpPort, Integer(lPort));
    lDevice.TrySetDeviceProperty(rdpPollFrequencyHz, lPollHz);
    if not (lDevice.GetNativeObject is TRecorderMic185Device) then
    begin
      AErrorText := 'MIC183/185 device object is not available';
      Exit;
    end;
    lNative := TRecorderMic185Device(lDevice.GetNativeObject);
    if RecorderMic185GetKnownIdentity(ARegistry, ASourceId, lKnownSerial,
      lKnownVersion) then
      lNative.ApplyKnownIdentity(lKnownSerial, lKnownVersion);
    lNative.ApplyChannelProgramSettings(lSettings, lGroupAddition,
      lTemperatureCompensation, lModuleSettings);
    try
      lStageStartedAt := GetTickCount64;
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'connect', 'BEGIN', '');
      if not lNative.TryConnect(AErrorText) then
      begin
        RecorderMic185LifecycleLog(lTraceId, ASourceId, 'connect', 'FAIL',
          AErrorText, GetTickCount64 - lStageStartedAt);
        AErrorText := 'MIC183/185 connect failed: ' + AErrorText;
        RecorderMic185Log(Format('ProgramConfiguredSource failed %s: %s',
          [ASourceId, AErrorText]));
        Exit;
      end;
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'connect', 'OK', '',
        GetTickCount64 - lStageStartedAt);
      lStageStartedAt := GetTickCount64;
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'initialize', 'BEGIN',
        'GetSoftVersion/read SN');
      lInitializeOk := lNative.TryInitializeSession(AErrorText);
      if not lInitializeOk then
      begin
        RecorderMic185LifecycleLog(lTraceId, ASourceId, 'initialize', 'FAIL',
          AErrorText, GetTickCount64 - lStageStartedAt);
        AErrorText := 'MIC183/185 initialization failed: ' + AErrorText;
        RecorderMic185Log(Format('ProgramConfi  guredSource failed %s: %s',
          [ASourceId, AErrorText]));
        Exit;
      end;
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'initialize', 'OK',
        Format('sn=%d version=%s', [lNative.DeviceSerial,
          Mic185FormatSoftVersion(lNative.SoftVersion)]),
        GetTickCount64 - lStageStartedAt);
      RecorderMic185SetKnownIdentity(ARegistry, ASourceId,
        lNative.DeviceSerial, lNative.SoftVersion);
      lStageStartedAt := GetTickCount64;
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'configure', 'BEGIN', '');
      if not lNative.TryProgramDevice(AErrorText) then
      begin
        RecorderMic185LifecycleLog(lTraceId, ASourceId, 'configure', 'FAIL',
          AErrorText, GetTickCount64 - lStageStartedAt);
        AErrorText := 'MIC183/185 programming failed: ' + AErrorText;
        RecorderMic185Log(Format('ProgramConfiguredSource failed %s: %s',
          [ASourceId, AErrorText]));
        Exit;
      end;
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'configure', 'OK', '',
        GetTickCount64 - lStageStartedAt);
      Result := True;
      RecorderMarkSourceProgrammingApplied(ARegistry, ASourceId);
      RecorderMic185LifecycleLog(lTraceId, ASourceId, 'operation', 'OK', '');
    except
      on E: Exception do
      begin
        AErrorText := E.Message;
        RecorderMic185Log(Format('ProgramConfiguredSource failed %s: %s',
          [ASourceId, AErrorText]));
      end;
    end;
  finally
    lStageStartedAt := GetTickCount64;
    RecorderMic185LifecycleLog(lTraceId, ASourceId, 'disconnect', 'BEGIN', '');
    try
      lDevice.Disconnect;
    except
    end;
    RecorderMic185LifecycleLog(lTraceId, ASourceId, 'disconnect', 'OK', '',
      GetTickCount64 - lStageStartedAt);
  end;
end;

function RecorderMic185ZeroBalanceChannels(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; const AChannelIndices: array of Integer;
  AMessages: TStrings): Boolean;
var
  lBalances: TRecorderDeviceActionValues;
  lDevice: IRecorderDevice;
  lError: string;
  lGroupAddition: TMic185GroupAdditionArray;
  lHost: string;
  lLiveNative: TRecorderMic185Device;
  lNative: TRecorderMic185Device;
  lModuleSettings: TMic185ModuleProgramSettings;
  lPollHz: Double;
  lPort: Word;
  lSettings: TMic185ChannelProgramSettingsArray;
  lTemperatureCompensation: Boolean;
  lWasStarted: Boolean;

  procedure ClearSelectedSoftBalance;
  var
    lCh: Integer;
    lIndex: Integer;
  begin
    for lIndex := 0 to High(AChannelIndices) do
    begin
      lCh := AChannelIndices[lIndex];
      if (lCh >= 0) and (lCh <= High(lSettings)) then
      begin
        lSettings[lCh].SoftBalance := 0;
        lSettings[lCh].SoftBalanceFine := 0.0;
      end;
    end;
    RecorderMic185Log(Format('ZeroBalance %s clean setup: cleared %d old soft balances',
      [ASourceId, Length(AChannelIndices)]));
  end;

  procedure StoreReturnedSoftBalance;
  var
    lCh: Integer;
    lIndex: Integer;
  begin
    for lIndex := 0 to High(AChannelIndices) do
    begin
      if lIndex > High(lBalances) then
        Break;
      lCh := AChannelIndices[lIndex];
      if (lCh < 0) or (lCh > High(lSettings)) then
        Continue;
      lSettings[lCh].SoftBalance := Round(lBalances[lIndex]);
      lSettings[lCh].SoftBalanceFine := 0.0;
      RecorderMic185SetSourceChannelMode(ARegistry, ASourceId,
        RecorderMic185MeasurementAddressText(
        RecorderMic185SourceDeviceIndex(ARegistry, ASourceId), lCh + 1),
        lPollHz, lSettings[lCh]);
      RecorderMic185Log(Format(
        'ZeroBalance %s ch%d returned soft=%d code, ui=%.6g mV',
        [ASourceId, lCh + 1, Round(lBalances[lIndex]),
        RecorderMic185SoftBalanceCodeToMv(Round(lBalances[lIndex]),
        lSettings[lCh].MeasRangeIndex)]));
    end;
  end;

  procedure StoreFineSoftBalance(ACh: Integer; AFineCode: Double);
  begin
    if (ACh < 0) or (ACh > High(lSettings)) then
      Exit;
    lSettings[ACh].SoftBalanceFine := AFineCode;
    RecorderMic185SetSourceChannelMode(ARegistry, ASourceId,
      RecorderMic185MeasurementAddressText(
      RecorderMic185SourceDeviceIndex(ARegistry, ASourceId), ACh + 1),
      lPollHz, lSettings[ACh]);
    RecorderMic185Log(Format(
      'ZeroBalance %s ch%d fine residual=%.6g code, ui=%.6g mV',
      [ASourceId, ACh + 1, AFineCode,
      RecorderMic185SoftBalanceCodeToMv(Round(AFineCode),
      lSettings[ACh].MeasRangeIndex)]));
  end;

  function MeasureFineSoftBalance(ADevice: TRecorderMic185Device;
    out AErrorText: string): Boolean;
  var
    I, J, K: Integer;
    lBlock: TRecorderAcquisitionBlock;
    lCh: Integer;
    lCounts: array of Integer;
    lDiscarded: Integer;
    lEndAt: QWord;
    lReadCount: Integer;
    lSampleTotal: Integer;
    lSums: array of Double;
    lTries: Integer;
  begin
    Result := False;
    AErrorText := '';
    SetLength(lSums, Length(AChannelIndices));
    SetLength(lCounts, Length(AChannelIndices));
    if not ADevice.TryStart(AErrorText) then
      Exit;
    try
      Sleep(CMic185ZeroBalanceFineSettleMs);
      lDiscarded := 0;
      lReadCount := 0;
      lTries := 0;
      lEndAt := GetTickCount64 + CMic185ZeroBalanceFineTotalWaitMs;
      while (lReadCount < CMic185ZeroBalanceFineBlocks) and
        (GetTickCount64 < lEndAt) do
      begin
        Inc(lTries);
        if not ADevice.ReadBlock(CMic185ZeroBalanceFineReadTimeoutMs, lBlock) then
        begin
          Sleep(CMic185ZeroBalanceFinePollMs);
          Continue;
        end;
        if lBlock.SampleCount <= 0 then
        begin
          Sleep(CMic185ZeroBalanceFinePollMs);
          Continue;
        end;
        if lDiscarded < CMic185ZeroBalanceFineDiscardBlocks then
        begin
          Inc(lDiscarded);
          Continue;
        end;
        Inc(lReadCount);
        for I := 0 to High(AChannelIndices) do
        begin
          lCh := AChannelIndices[I];
          if (lCh < 0) or (lCh >= lBlock.ChannelCount) then
            Continue;
          for J := 0 to lBlock.SampleCount - 1 do
          begin
            lSums[I] := lSums[I] + lBlock.Values[lCh][J];
            Inc(lCounts[I]);
          end;
        end;
      end;
    finally
      ADevice.Stop;
    end;

    lSampleTotal := 0;
    for K := 0 to High(AChannelIndices) do
      if lCounts[K] > 0 then
      begin
        Inc(lSampleTotal, lCounts[K]);
        StoreFineSoftBalance(AChannelIndices[K], lSums[K] / lCounts[K]);
        Result := True;
      end;
    if Result then
      RecorderMic185Log(Format(
        'ZeroBalance %s fine residual measured blocks=%d discarded=%d samples=%d tries=%d',
        [ASourceId, lReadCount, lDiscarded, lSampleTotal, lTries]));
    if not Result then
      AErrorText := Format(
        'MIC183/185 fine zero-balance read did not return samples (tries=%d)',
        [lTries]);
  end;
begin
  Result := False;
  if not TryParseRecorderMic185SourceId(ASourceId, lHost, lPort) then
  begin
    if AMessages <> nil then
      AMessages.Add('Invalid MIC183/185 source id: ' + ASourceId);
    Exit;
  end;
  lPollHz := MIC185DefaultPollFrequencyHz;
  if RecorderConfiguredDataSourcesFind(ARegistry, ASourceId) <> nil then
    if RecorderConfiguredDataSourcesFind(ARegistry, ASourceId).DefaultPollFrequencyHz > 0 then
      lPollHz := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId).DefaultPollFrequencyHz;
  RecorderMic185BuildSourceProgramSettings(ARegistry, ASourceId, lPollHz,
    lSettings);
  RecorderMic185GetSourceGroupAddition(ARegistry, ASourceId, lGroupAddition);
  RecorderMic185GetSourceModuleSettings(ARegistry, ASourceId, lModuleSettings);
  lTemperatureCompensation :=
    RecorderMic185GetSourceTemperatureCompensation(ARegistry, ASourceId);
  ClearSelectedSoftBalance;

  lLiveNative := RecorderMic185FindLiveDevice(lHost, lPort);
  if lLiveNative <> nil then
  begin
    lLiveNative.ApplyChannelProgramSettings(lSettings, lGroupAddition,
      lTemperatureCompensation, lModuleSettings);
    lWasStarted := lLiveNative.State = rdsStarted;
    try
      if lWasStarted then
        lLiveNative.Stop;
      if not lLiveNative.TryProgramDevice(lError) then
      begin
        if AMessages <> nil then
          AMessages.Add('MIC183/185 clean zero-balance setup failed: ' + lError);
        Exit;
      end;
      if not lLiveNative.TryZeroBalanceChannels(AChannelIndices, lBalances,
        lError) then
      begin
        if AMessages <> nil then
          AMessages.Add(lError);
        Exit;
      end;
      StoreReturnedSoftBalance;
      lLiveNative.ApplyChannelProgramSettings(lSettings, lGroupAddition,
        lTemperatureCompensation, lModuleSettings);
      if not lLiveNative.TryProgramDevice(lError) then
      begin
        Result := False;
        if AMessages <> nil then
          AMessages.Add('MIC183/185 zero-balance apply failed: ' + lError);
        Exit;
      end;
      RecorderMic185Log(Format(
        'ZeroBalance %s applied returned soft balances to device',
        [ASourceId]));
      if not MeasureFineSoftBalance(lLiveNative, lError) then
        RecorderMic185Log(Format('ZeroBalance %s fine residual skipped: %s',
          [ASourceId, lError]));
      RecorderMarkSourceProgrammingApplied(ARegistry, ASourceId);
      Result := True;
    finally
      if lWasStarted then
        if not lLiveNative.TryStart(lError) then
        begin
          Result := False;
          if AMessages <> nil then
            AMessages.Add('MIC183/185 restart after zero-balance failed: ' + lError);
        end;
    end;
    if AMessages <> nil then
      if Result then
        AMessages.Add(Format('MIC183/185 balance OK: %d channel(s)',
          [Length(AChannelIndices)]));
    Exit;
  end;

  lDevice := CreateRecorderMic185Device;
  try
    lDevice.TrySetDeviceProperty(rdpHost, lHost);
    lDevice.TrySetDeviceProperty(rdpPort, Integer(lPort));
    lDevice.TrySetDeviceProperty(rdpPollFrequencyHz, lPollHz);
    if not (lDevice.GetNativeObject is TRecorderMic185Device) then
      Exit;
    lNative := TRecorderMic185Device(lDevice.GetNativeObject);
    lNative.ApplyChannelProgramSettings(lSettings, lGroupAddition,
      lTemperatureCompensation, lModuleSettings);
    if (not lNative.TryConnect(lError)) or
      (not lNative.TryInitializeSession(lError)) or
      (not lNative.TryProgramDevice(lError)) or
      (not lNative.TryZeroBalanceChannels(AChannelIndices, lBalances, lError)) then
    begin
      if AMessages <> nil then
        AMessages.Add(lError);
      Exit;
    end;
    StoreReturnedSoftBalance;
    lNative.ApplyChannelProgramSettings(lSettings, lGroupAddition,
      lTemperatureCompensation, lModuleSettings);
    if not lNative.TryProgramDevice(lError) then
    begin
      if AMessages <> nil then
        AMessages.Add('MIC183/185 zero-balance apply failed: ' + lError);
      Exit;
    end;
    RecorderMic185Log(Format(
      'ZeroBalance %s applied returned soft balances to device',
      [ASourceId]));
    if not MeasureFineSoftBalance(lNative, lError) then
      RecorderMic185Log(Format('ZeroBalance %s fine residual skipped: %s',
        [ASourceId, lError]));
    if AMessages <> nil then
      AMessages.Add(Format('MIC183/185 balance OK: %d channel(s)',
        [Length(AChannelIndices)]));
    Result := True;
  finally
    if lDevice <> nil then
      lDevice.Disconnect;
  end;
end;

function RecorderMic185RangeText(ARangeIndex: LongWord): string;
begin
  case ARangeIndex of
    CMic185Range500mV: Result := '±500.000';
    CMic185Range50mV: Result := '±50.000';
    CMic185Range05mV: Result := '±0.500';
  else
    Result := '±5.000';
  end;
end;

function RecorderMic185RangeUnitText(ARangeIndex: LongWord): string;
begin
  if ARangeIndex = CMic185Range05mV then
    Result := 'мВ(тензо)'
  else
    Result := 'мВ';
end;

function RecorderMic185RangeMax(ARangeIndex: LongWord): Double;
begin
  case ARangeIndex of
    CMic185Range500mV: Result := 500;
    CMic185Range50mV: Result := 50;
    CMic185Range05mV: Result := 0.5;
  else
    Result := 5;
  end;
end;

function RecorderMic185SoftBalanceCodeToMv(ASoftBalance: LongInt;
  ARangeIndex: LongWord): Double;
begin
  Result := ASoftBalance * RecorderMic185RangeMax(ARangeIndex) /
    CMic185NominalAdcFullScale;
end;

function RecorderMic185SoftBalanceMvToCode(ASoftBalanceMv: Double;
  ARangeIndex: LongWord): LongInt;
var
  lCode: Int64;
begin
  lCode := Round(ASoftBalanceMv * CMic185NominalAdcFullScale /
    Max(RecorderMic185RangeMax(ARangeIndex), 1E-9));
  if lCode < -CMic185SoftBalanceMaxCode then
    lCode := -CMic185SoftBalanceMaxCode
  else if lCode > CMic185SoftBalanceMaxCode then
    lCode := CMic185SoftBalanceMaxCode;
  Result := LongInt(lCode);
end;

function RecorderMic185HardBalanceCodeToMv(AHardBalance: LongWord): Double;
begin
  Result := (CMic185DefaultHardBalance - Int64(AHardBalance)) *
    CMic185HardBalanceRangeMv / CMic185DefaultHardBalance;
end;

function RecorderMic185HardBalanceMvToCode(AHardBalanceMv: Double): LongWord;
var
  lCode: Int64;
begin
  lCode := Round(CMic185DefaultHardBalance -
    AHardBalanceMv * CMic185DefaultHardBalance / CMic185HardBalanceRangeMv);
  if lCode < 0 then
    lCode := 0
  else if lCode > CMic185HardBalanceDacMax then
    lCode := CMic185HardBalanceDacMax;
  Result := LongWord(lCode);
end;

function Mic185EffectivePowerMa(
  const ASettings: TMic185ChannelProgramSettings): Double;
begin
  Result := Abs(Mic185PowerCodeToMa(ASettings.PowerMaCode));
  if SameValue(Result, 0.0, 1E-9) then
    Result := 1.0;
end;

function Mic185NormalizeUnitName(const AUnitName: string;
  ARangeIndex: LongWord): string;
begin
  Result := Trim(AUnitName);
  if Result = '' then
    Result := RecorderMic185RangeUnitText(ARangeIndex);
end;

function Mic185SensorSchemeCoeff(ASensorScheme: LongWord): Double;
begin
  case ASensorScheme of
    CMic185SensorSchemeHalf: Result := 2.0;
    CMic185SensorSchemeBridge: Result := 1.0;
  else
    Result := 4.0;
  end;
end;

function Mic185CodeToNominalMv(AValueCode: Double;
  const ASettings: TMic185ChannelProgramSettings): Double;
begin
  Result := AValueCode * RecorderMic185RangeMax(ASettings.MeasRangeIndex) /
    CMic185NominalAdcFullScale;
end;

function Mic185EffectiveRangeMaxWithPower(
  const ASettings: TMic185ChannelProgramSettings; const AUnitName: string;
  APowerMa: Double): Double;
var
  lExcitationMv: Double;
  lRangeMv: Double;
  lSensitivity: Double;
  lUnit: string;
begin
  lRangeMv := RecorderMic185RangeMax(ASettings.MeasRangeIndex);
  lUnit := Mic185NormalizeUnitName(AUnitName, ASettings.MeasRangeIndex);
  if SameText(lUnit, 'код') or SameText(lUnit, 'code') then
    Exit(CMic185NominalAdcFullScale);
  if SameText(lUnit, 'Ом') then
    Exit(lRangeMv / Max(Abs(APowerMa), 1E-9));

  if SameText(lUnit, 'мкм/м') then
  begin
    lExcitationMv := Max(Abs(APowerMa), 1E-9) *
      Max(Abs(ASettings.Resistance), 1E-9);
    lSensitivity := Max(Abs(ASettings.TensoSensitivity), 1E-9);
    Exit((lRangeMv / lExcitationMv) *
      (Mic185SensorSchemeCoeff(ASettings.SensorScheme) / lSensitivity) * 1000000.0);
  end;

  Result := lRangeMv;
end;

function RecorderMic185EffectiveRangeMax(
  const ASettings: TMic185ChannelProgramSettings; const AUnitName: string): Double;
begin
  Result := Mic185EffectiveRangeMaxWithPower(ASettings, AUnitName,
    Mic185EffectivePowerMa(ASettings));
end;

function RecorderMic185EffectiveRangeMaxForTag(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const ASettings: TMic185ChannelProgramSettings;
  const AUnitName: string): Double;
var
  lPowerMa: Double;
begin
  lPowerMa := RecorderMic185ApplyCurrentCalibration(ARegistry, ATag,
    Mic185EffectivePowerMa(ASettings));
  Result := Mic185EffectiveRangeMaxWithPower(ASettings, AUnitName, lPowerMa);
end;

function RecorderMic185EffectiveRangeText(
  const ASettings: TMic185ChannelProgramSettings; const AUnitName: string): string;
begin
  Result := '±' + FormatFloat('0.000', RecorderMic185EffectiveRangeMax(
    ASettings, AUnitName));
end;

function RecorderMic185EffectiveRangeTextForTag(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const ASettings: TMic185ChannelProgramSettings;
  const AUnitName: string): string;
begin
  Result := '±' + FormatFloat('0.000',
    RecorderMic185EffectiveRangeMaxForTag(ARegistry, ATag, ASettings,
    AUnitName));
end;

function RecorderMic185EffectiveTransformText(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const ASettings: TMic185ChannelProgramSettings;
  const AUnitName: string): string;
var
  lCalibration: TRecorderCalibration;
  lHardwareB: Double;
  lHardwareK: Double;
  lLineB: Double;
  lLineK: Double;
  lPowerMa: Double;
begin
  lLineK := 1.0;
  lLineB := 0.0;
  lCalibration := nil;
  if (ARegistry <> nil) and (ATag <> nil) and
    (Trim(ATag.HardwareCalibrationName) <> '') then
    lCalibration := ARegistry.FindCalibrationByName(
      ATag.HardwareCalibrationName);
  if (lCalibration <> nil) and
    RecorderMic185TryExtractHardwareKx(lCalibration, lHardwareK,
    lHardwareB) then
  begin
    lLineK := lHardwareK;
    lLineB := -lHardwareK * lHardwareB;
  end;

  lPowerMa := RecorderMic185ApplyCurrentCalibration(ARegistry, ATag,
    Mic185EffectivePowerMa(ASettings));
  Mic185ApplyUnitLine(lLineK, lLineB, ASettings,
    Mic185RuntimeUnitFromName(AUnitName, ASettings.MeasRangeIndex), lPowerMa);
  Result := RecorderMic185FormatHardwareKx(lLineK, lLineB);
end;

function RecorderMic185ConvertValue(AValueMv: Double;
  const ASettings: TMic185ChannelProgramSettings; const AUnitName: string;
  AHardwareCalibration: TRecorderCalibration; AEffectivePowerMa: Double): Double;
var
  lExcitationMv: Double;
  lMv: Double;
  lPowerMa: Double;
  lSensitivity: Double;
  lUnit: string;
begin
  if AHardwareCalibration <> nil then
    lMv := AHardwareCalibration.Transform(AValueMv)
  else
    lMv := AValueMv;
  lUnit := Mic185NormalizeUnitName(AUnitName, ASettings.MeasRangeIndex);
  lPowerMa := AEffectivePowerMa;
  if SameValue(lPowerMa, 0.0, 1E-9) then
    lPowerMa := Mic185EffectivePowerMa(ASettings);
  if SameText(lUnit, 'Ом') then
    Exit(lMv / lPowerMa);

  if SameText(lUnit, 'мкм/м') then
  begin
    lExcitationMv := lPowerMa *
      Max(Abs(ASettings.Resistance), 1E-9);
    lSensitivity := Max(Abs(ASettings.TensoSensitivity), 1E-9);
    Exit((lMv / lExcitationMv) *
      (Mic185SensorSchemeCoeff(ASettings.SensorScheme) / lSensitivity) * 1000000.0);
  end;

  Result := lMv;
end;

function RecorderMic185ConvertUnitValueForTag(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; AValueMv: Double;
  const ASettings: TMic185ChannelProgramSettings;
  const AUnitName: string): Double;
var
  lPowerMa: Double;
begin
  lPowerMa := RecorderMic185ApplyCurrentCalibration(ARegistry, ATag,
    Mic185EffectivePowerMa(ASettings));
  Result := RecorderMic185ConvertValue(AValueMv, ASettings, AUnitName, nil,
    lPowerMa);
end;

function Mic185RuntimeUnitFromName(const AUnitName: string;
  ARangeIndex: LongWord): TRecorderMic185RuntimeUnit;
var
  lUnit: string;
begin
  lUnit := Mic185NormalizeUnitName(AUnitName, ARangeIndex);
  if SameText(lUnit, 'Ом') then
    Result := mruOhm
  else if SameText(lUnit, 'мкм/м') then
    Result := mruStrain
  else
    Result := mruMillivolts;
end;

function Mic185TryGetCalibrationLine(ACalibration: TRecorderCalibration;
  out AK, AB: Double): Boolean;
var
  I: Integer;
  lFirst: TRecorderCalibrationPoint;
  lPoint: TRecorderCalibrationPoint;
  lSecond: TRecorderCalibrationPoint;
begin
  AK := 1.0;
  AB := 0.0;
  Result := False;
  if ACalibration = nil then
    Exit(True);

  case ACalibration.Kind of
    rckScale:
      begin
        AK := ACalibration.Scale;
        Exit(True);
      end;
    rckStrain:
      begin
        if not SameValue(ACalibration.K2, 0.0, 1E-12) then
          Exit;
        AK := ACalibration.K1;
        AB := ACalibration.Offset;
        Exit(True);
      end;
    rckPiecewiseLinear:
      begin
        if ACalibration.PointCount = 0 then
          Exit(True);
        lFirst := ACalibration.PointAt(0);
        if lFirst = nil then
          Exit;
        if ACalibration.PointCount = 1 then
        begin
          AK := 0.0;
          AB := lFirst.Y;
          Exit(True);
        end;

        lSecond := nil;
        for I := 1 to ACalibration.PointCount - 1 do
        begin
          lPoint := ACalibration.PointAt(I);
          if (lPoint <> nil) and
            (not SameValue(lPoint.X, lFirst.X, 1E-12)) then
          begin
            lSecond := lPoint;
            Break;
          end;
        end;
        if lSecond = nil then
          Exit;

        AK := (lSecond.Y - lFirst.Y) / (lSecond.X - lFirst.X);
        AB := lFirst.Y - AK * lFirst.X;
        for I := 0 to ACalibration.PointCount - 1 do
        begin
          lPoint := ACalibration.PointAt(I);
          if lPoint = nil then
            Exit;
          if not SameValue(lPoint.Y, AK * lPoint.X + AB, 1E-7) then
            Exit;
        end;
        Exit(True);
      end;
  end;
end;

procedure Mic185ComposeLine(var AK, AB: Double; AStepK, AStepB: Double);
begin
  AB := AStepK * AB + AStepB;
  AK := AStepK * AK;
end;

procedure Mic185ApplyUnitLine(var AK, AB: Double;
  const ASettings: TMic185ChannelProgramSettings;
  AUnitMode: TRecorderMic185RuntimeUnit; APowerMa: Double);
var
  lCoeff: Double;
  lExcitationMv: Double;
  lPowerMa: Double;
  lSensitivity: Double;
begin
  lPowerMa := APowerMa;
  if SameValue(lPowerMa, 0.0, 1E-9) then
    lPowerMa := Mic185EffectivePowerMa(ASettings);
  case AUnitMode of
    mruOhm:
      begin
        AK := AK / lPowerMa;
        AB := AB / lPowerMa;
      end;
    mruStrain:
      begin
        lExcitationMv := lPowerMa * Max(Abs(ASettings.Resistance), 1E-9);
        lSensitivity := Max(Abs(ASettings.TensoSensitivity), 1E-9);
        lCoeff := (Mic185SensorSchemeCoeff(ASettings.SensorScheme) /
          lSensitivity) * 1000000.0 / lExcitationMv;
        AK := AK * lCoeff;
        AB := AB * lCoeff;
      end;
  end;
end;

function Mic185ApplyUnitValue(AValueMv: Double;
  const ASettings: TMic185ChannelProgramSettings;
  AUnitMode: TRecorderMic185RuntimeUnit; APowerMa: Double): Double;
var
  lExcitationMv: Double;
  lPowerMa: Double;
  lSensitivity: Double;
begin
  lPowerMa := APowerMa;
  if SameValue(lPowerMa, 0.0, 1E-9) then
    lPowerMa := Mic185EffectivePowerMa(ASettings);
  case AUnitMode of
    mruOhm:
      Result := AValueMv / lPowerMa;
    mruStrain:
      begin
        lExcitationMv := lPowerMa * Max(Abs(ASettings.Resistance), 1E-9);
        lSensitivity := Max(Abs(ASettings.TensoSensitivity), 1E-9);
        Result := (AValueMv / lExcitationMv) *
          (Mic185SensorSchemeCoeff(ASettings.SensorScheme) / lSensitivity) *
          1000000.0;
      end;
  else
    Result := AValueMv;
  end;
end;

function Mic185BuildValueTransform(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const ASettings: TMic185ChannelProgramSettings;
  AHardwareCalibration: TRecorderCalibration): TRecorderMic185ValueTransform;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lStepB: Double;
  lStepK: Double;
begin
  Result.IsLinear := True;
  Result.K := 1.0;
  Result.B := 0.0;
  Result.Settings := ASettings;
  Result.UnitMode := Mic185RuntimeUnitFromName(ATag.UnitName,
    ASettings.MeasRangeIndex);
  Result.HardwareCalibration := AHardwareCalibration;
  SetLength(Result.ChannelCalibrations, 0);
  if not ATag.HardwareCalibrationEnabled then
  begin
    Result.HardwareCalibration := nil;
    Exit;
  end;
  Result.PowerMa := Mic185EffectivePowerMa(ASettings);
  Result.PowerMa := RecorderMic185ApplyCurrentCalibration(ARegistry, ATag,
    Result.PowerMa);

  if AHardwareCalibration <> nil then
  begin
    if Mic185TryGetCalibrationLine(AHardwareCalibration, Result.K, Result.B) then
      Result.HardwareCalibration := nil
    else
      Result.IsLinear := False;
  end;

  if Result.IsLinear then
  begin
    Result.B := Result.B - Result.K * ASettings.SoftBalanceFine;
    Mic185ApplyUnitLine(Result.K, Result.B, ASettings, Result.UnitMode,
      Result.PowerMa);
  end;

  if (ARegistry = nil) or (ATag = nil) or (not ATag.ChannelCalibrationEnabled) or
    (ATag.CalibrationNames = nil) then
    Exit;

  for I := 0 to ATag.CalibrationNames.Count - 1 do
  begin
    lCalibration := ARegistry.FindCalibrationByName(ATag.CalibrationNames[I]);
    if lCalibration = nil then
      Continue;
    SetLength(Result.ChannelCalibrations, Length(Result.ChannelCalibrations) + 1);
    Result.ChannelCalibrations[High(Result.ChannelCalibrations)] := lCalibration;
    if Result.IsLinear then
    begin
      if Mic185TryGetCalibrationLine(lCalibration, lStepK, lStepB) then
        Mic185ComposeLine(Result.K, Result.B, lStepK, lStepB)
      else
        Result.IsLinear := False;
    end;
  end;
end;

function Mic185ApplyValueTransform(AValueCode: Double;
  const ATransform: TRecorderMic185ValueTransform): Double;
var
  I: Integer;
begin
  if ATransform.IsLinear then
    Exit(ATransform.K * AValueCode + ATransform.B);

  AValueCode := AValueCode - ATransform.Settings.SoftBalanceFine;
  if ATransform.HardwareCalibration <> nil then
    Result := ATransform.HardwareCalibration.Transform(AValueCode)
  else
    Result := AValueCode;
  Result := Mic185ApplyUnitValue(Result, ATransform.Settings,
    ATransform.UnitMode, ATransform.PowerMa);
  for I := 0 to High(ATransform.ChannelCalibrations) do
    if ATransform.ChannelCalibrations[I] <> nil then
      Result := ATransform.ChannelCalibrations[I].Transform(Result);
end;

function RecorderMic185CommutationText(ACommutIndex: LongWord): string;
begin
  case ACommutIndex of
    CMic185CommutGround: Result := 'Земля';
    CMic185CommutCalibr: Result := '49 мВ';
  else
    Result := 'Вход';
  end;
end;

function RecorderMic185SensorSchemeText(ASensorScheme: LongWord): string;
begin
  case ASensorScheme of
    CMic185SensorSchemeHalf: Result := 'Полумост';
    CMic185SensorSchemeBridge: Result := 'Мост';
  else
    Result := 'Тензометр';
  end;
end;

function RecorderMic185ChannelAddressToIndex(const AAddress: string): Integer;
var
  lStartPos: Integer;
  lText: string;
begin
  Result := -1;
  lText := Mic185CanonicalAddress(AAddress);
  lStartPos := RPos('-', lText);
  if lStartPos <= 0 then
    Exit;
  lText := Copy(lText, lStartPos + 1, MaxInt);
  if (Pos('t', LowerCase(lText)) > 0) or SameText(lText, 'uts') then
    Exit;
  if not TryStrToInt(lText, Result) then
    Exit(-1);
  Dec(Result);
  if (Result < 0) or (Result >= CMic185ChannelCountMax) then
    Result := -1;
end;

function RecorderMic185EnsureConfiguredSource(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; APollFrequencyHz: Double): TRecorderConfiguredDataSource;
begin
  Result := RecorderConfiguredDataSourcesEnsure(ARegistry, ASourceId, CMic185ModuleName,
    APollFrequencyHz);
end;

function Mic185JsonArray(AOwner: TJSONObject; const AName: string): TJSONArray;
var
  lData: TJSONData;
begin
  Result := nil;
  if AOwner = nil then
    Exit;
  lData := AOwner.Find(AName);
  if lData is TJSONArray then
    Exit(TJSONArray(lData));
  Result := TJSONArray.Create;
  AOwner.Add(AName, Result);
end;

function Mic185FindOrCreateDataSourceJson(AJson: TJSONObject;
  const ASourceId: string): TJSONObject;
var
  I: Integer;
  lArray: TJSONArray;
begin
  Result := nil;
  lArray := Mic185JsonArray(AJson, 'dataSources');
  if lArray = nil then
    Exit;
  for I := 0 to lArray.Count - 1 do
    if (lArray.Items[I] is TJSONObject) and
      SameText(TJSONObject(lArray.Items[I]).Get('sourceId', ''), ASourceId) then
      Exit(TJSONObject(lArray.Items[I]));

  Result := TJSONObject.Create;
  lArray.Add(Result);
  Result.Add('sourceId', ASourceId);
  Result.Add('moduleType', CMic185ModuleName);
  Result.Add('defaultPollFrequencyHz', MIC185DefaultPollFrequencyHz);
end;

function Mic185FindOrCreateObject(AOwner: TJSONObject;
  const AName: string): TJSONObject;
var
  lData: TJSONData;
begin
  Result := nil;
  if AOwner = nil then
    Exit;
  lData := AOwner.Find(AName);
  if lData is TJSONObject then
  begin
    Result := TJSONObject(lData);
    Result.Clear;
    Exit;
  end;
  Result := TJSONObject.Create;
  AOwner.Add(AName, Result);
end;

procedure SaveMic185DataSourceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  J: Integer;
  lChannels: TJSONArray;
  lEntry: TRecorderConfiguredDataSource;
  lGroupAddition: TMic185GroupAdditionArray;
  lHost: string;
  lItem: TJSONObject;
  lKnownSerial: LongWord;
  lKnownVersion: LongWord;
  lLink: TJSONObject;
  lLinks: TJSONArray;
  lMic185: TJSONObject;
  lModuleSettings: TMic185ModuleProgramSettings;
  lPollHz: Double;
  lPort: Word;
  lSourceId: string;
  lSources: TStringList;
  lSettings: TMic185ChannelProgramSettingsArray;
  lTag: TRecorderTag;
  lTemperatureCompensation: Boolean;
  lUnitName: string;
begin
  if (AJson = nil) or (ARegistry = nil) then
    Exit;
  lSources := TStringList.Create;
  try
    lSources.CaseSensitive := False;
    lSources.Sorted := False;
    if RecorderConfiguredDataSourceList(ARegistry) <> nil then
      for I := 0 to RecorderConfiguredDataSourceList(ARegistry).Count - 1 do
      begin
        lEntry := TRecorderConfiguredDataSource(
          RecorderConfiguredDataSourceList(ARegistry)[I]);
        lSourceId := RecorderNormalizeTagSourceId(lEntry.SourceId);
        if not TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
          Continue;
        if lSources.IndexOf(lSourceId) < 0 then
          lSources.Add(lSourceId);
      end;
    for I := 0 to ARegistry.TagCount - 1 do
    begin
      lTag := ARegistry.Tags[I];
      lSourceId := RecorderNormalizeTagSourceId(lTag.SourceId);
      if not TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
        Continue;
      if lSources.IndexOf(lSourceId) < 0 then
        lSources.Add(lSourceId);
    end;

    for I := 0 to lSources.Count - 1 do
    begin
      lSourceId := lSources[I];
      if not TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
        Continue;
      lPollHz := MIC185DefaultPollFrequencyHz;
      for J := 0 to ARegistry.TagCount - 1 do
      begin
        lTag := ARegistry.Tags[J];
        if SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lSourceId) and
          (lTag.PollFrequencyHz > 0) then
        begin
          lPollHz := lTag.PollFrequencyHz;
          Break;
        end;
      end;
      RecorderMic185EnsureConfiguredSource(ARegistry, lSourceId, lPollHz);
      lItem := Mic185FindOrCreateDataSourceJson(AJson, lSourceId);
      if lItem = nil then
        Continue;
      lMic185 := Mic185FindOrCreateObject(lItem, 'mic185');
      lMic185.Add('host', lHost);
      lMic185.Add('port', Integer(lPort));
      lMic185.Add('defaultPollFrequencyHz', lPollHz);
      lMic185.Add('powerMaCode', Integer(RecorderMic185GetSourcePowerMaCode(
        ARegistry, lSourceId)));
      if RecorderMic185GetKnownIdentity(ARegistry, lSourceId, lKnownSerial,
        lKnownVersion) then
      begin
        if lKnownSerial <> 0 then
          lMic185.Add('serialNumber', Integer(lKnownSerial));
        if lKnownVersion <> 0 then
          lMic185.Add('softVersion', Integer(lKnownVersion));
      end;
      RecorderMic185GetSourceGroupAddition(ARegistry, lSourceId, lGroupAddition);
      RecorderMic185GetSourceModuleSettings(ARegistry, lSourceId, lModuleSettings);
      lTemperatureCompensation :=
        RecorderMic185GetSourceTemperatureCompensation(ARegistry, lSourceId);
      RecorderMic185StoreSourceModuleSettings(lMic185, lModuleSettings);
      RecorderMic185StoreSourceCompensation(lMic185, lGroupAddition,
        lTemperatureCompensation);
      lLinks := TJSONArray.Create;
      lMic185.Add('tagLinks', lLinks);
      for J := 0 to ARegistry.TagCount - 1 do
      begin
        lTag := ARegistry.Tags[J];
        if not SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lSourceId) then
          Continue;
        lLink := TJSONObject.Create;
        lLinks.Add(lLink);
        lLink.Add('tagId', lTag.Id);
        lLink.Add('tagName', lTag.Name);
        lLink.Add('address', Mic185CanonicalAddress(lTag.Address));
        lLink.Add('pollFrequencyHz', lTag.PollFrequencyHz);
        lLink.Add('hardwareCalibrationEnabled',
          lTag.HardwareCalibrationEnabled);
        lLink.Add('hardwareCalibrationName', lTag.HardwareCalibrationName);
      end;

      RecorderMic185BuildSourceProgramSettings(ARegistry, lSourceId, lPollHz,
        lSettings);
      lChannels := TJSONArray.Create;
      lMic185.Add('channels', lChannels);
      for J := 0 to High(lSettings) do
      begin
        lLink := TJSONObject.Create;
        lChannels.Add(lLink);
        lLink.Add('address', RecorderMic185MeasurementAddressText(
          RecorderMic185SourceDeviceIndex(ARegistry, lSourceId), J + 1));
        lLink.Add('sourceValueMode',
          RecorderMic185FormatChannelMode(lSettings[J]));
        lLink.Add('pollFrequencyHz', lPollHz);
        lUnitName := RecorderMic185GetSourceChannelUnitName(ARegistry,
          lSourceId, lLink.Get('address', ''));
        if lUnitName <> '' then
          lLink.Add('unitName', lUnitName);
      end;
    end;
  finally
    lSources.Free;
  end;
end;

procedure LoadMic185DataSourceConfigs(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  J: Integer;
  K: Integer;
  lArray: TJSONArray;
  lAddress: string;
  lCapacity: Integer;
  lConfig: TJSONObject;
  lCreated: Boolean;
  lData: TJSONData;
  lEntry: TRecorderConfiguredDataSource;
  lExistingConfig: TJSONObject;
  lGroupAddition: TMic185GroupAdditionArray;
  lHost: string;
  lItem: TJSONObject;
  lKnownSerial: LongWord;
  lKnownVersion: LongWord;
  lLink: TJSONObject;
  lLinks: TJSONArray;
  lMic185: TJSONObject;
  lMode: string;
  lModuleSettings: TMic185ModuleProgramSettings;
  lOriginalAddress: string;
  lPollHz: Double;
  lPort: Word;
  lSettings: TMic185ChannelProgramSettings;
  lSourceId: string;
  lTag: TRecorderTag;
  lTagName: string;
  lTemperatureCompensation: Boolean;
begin
  if (AJson = nil) or (ARegistry = nil) then
    Exit;
  lData := AJson.Find('dataSources');
  if not (lData is TJSONArray) then
    Exit;
  lArray := TJSONArray(lData);
  for I := 0 to lArray.Count - 1 do
  begin
    if not (lArray.Items[I] is TJSONObject) then
      Continue;
    lItem := TJSONObject(lArray.Items[I]);
    lSourceId := RecorderNormalizeTagSourceId(lItem.Get('sourceId', ''));
    if not TryParseRecorderMic185SourceId(lSourceId, lHost, lPort) then
      Continue;
    lPollHz := lItem.Get('defaultPollFrequencyHz', MIC185DefaultPollFrequencyHz);
    lEntry := RecorderMic185EnsureConfiguredSource(ARegistry, lSourceId, lPollHz);
    lKnownSerial := 0;
    lKnownVersion := 0;
    lExistingConfig := Mic185SourceConfigObject(lEntry, False);
    try
      if lExistingConfig <> nil then
      begin
        lKnownSerial := LongWord(lExistingConfig.Get('serialNumber', 0));
        lKnownVersion := LongWord(lExistingConfig.Get('softVersion', 0));
      end;
    finally
      lExistingConfig.Free;
    end;
    lData := lItem.Find('mic185');
    if not (lData is TJSONObject) then
      Continue;
    lMic185 := TJSONObject(lData);
    lConfig := TJSONObject.Create;
    lData := lMic185.Find('channels');
    if lData is TJSONArray then
    begin
      lConfig.Add('channels', lData.Clone);
    end;
    lConfig.Add('powerMaCode', lMic185.Get('powerMaCode',
      Integer(CMic185DefaultPowerMaCode)));
    lKnownSerial := LongWord(lMic185.Get('serialNumber',
      Integer(lKnownSerial)));
    lKnownVersion := LongWord(lMic185.Get('softVersion',
      Integer(lKnownVersion)));
    if lKnownSerial <> 0 then
      lConfig.Add('serialNumber', Integer(lKnownSerial));
    if lKnownVersion <> 0 then
      lConfig.Add('softVersion', Integer(lKnownVersion));
    Mic185DefaultModuleProgramSettings(lModuleSettings);
    lModuleSettings.GroundCommutationUs := LongWord(lMic185.Get(
      'groundCommutationUs', Integer(lModuleSettings.GroundCommutationUs)));
    lModuleSettings.ChannelCommutationUs := LongWord(lMic185.Get(
      'channelCommutationUs', Integer(lModuleSettings.ChannelCommutationUs)));
    lModuleSettings.BalancePortionLength := LongWord(lMic185.Get(
      'balancePortionLength', Integer(lModuleSettings.BalancePortionLength)));
    lModuleSettings.HardBalance := LongWord(lMic185.Get('hardBalance',
      Integer(lModuleSettings.HardBalance)));
    lModuleSettings.AveragePointCount := Word(lMic185.Get('averagePointCount',
      Integer(lModuleSettings.AveragePointCount)));
    lModuleSettings.MaxFreqMode := LongWord(lMic185.Get('maxFreqMode',
      Integer(lModuleSettings.MaxFreqMode)));
    lModuleSettings.CalibrShuntIndex := LongWord(lMic185.Get('calibrShuntIndex',
      Integer(lModuleSettings.CalibrShuntIndex)));
    lModuleSettings.DetermineBreak := lMic185.Get('determineBreak',
      lModuleSettings.DetermineBreak);
    lModuleSettings.HardwareBalanceOn := lMic185.Get('hardwareBalanceOn',
      lModuleSettings.HardwareBalanceOn);
    RecorderMic185StoreSourceModuleSettings(lConfig, lModuleSettings);
    if lMic185.Find('temperatureCompensation') <> nil then
      lTemperatureCompensation := lMic185.Get('temperatureCompensation', True)
    else
      lTemperatureCompensation := True;
    Mic185DefaultGroupAdditionSettings(lGroupAddition);
    lData := lMic185.Find('groupAddition');
    if lData is TJSONArray then
      for J := 0 to Min(High(lGroupAddition), TJSONArray(lData).Count - 1) do
        if (TJSONArray(lData).Items[J].AsInteger >= Integer(CMic185ModAdd1)) and
          (TJSONArray(lData).Items[J].AsInteger <= Integer(CMic185ModAddOff)) then
          lGroupAddition[J] := LongWord(TJSONArray(lData).Items[J].AsInteger);
    RecorderMic185StoreSourceCompensation(lConfig, lGroupAddition,
      lTemperatureCompensation);
    Mic185StoreSourceConfigObject(lEntry, lConfig);
    lConfig.Free;
    lData := lMic185.Find('tagLinks');
    if not (lData is TJSONArray) then
      Continue;
    lLinks := TJSONArray(lData);
    for J := 0 to lLinks.Count - 1 do
    begin
      if not (lLinks.Items[J] is TJSONObject) then
        Continue;
      lLink := TJSONObject(lLinks.Items[J]);
      lOriginalAddress := lLink.Get('address', '');
      lAddress := Mic185CanonicalAddress(lOriginalAddress);
      if Pos('-', lAddress) > 0 then
        lAddress := IntToStr(RecorderMic185SourceDeviceIndex(ARegistry,
          lSourceId)) + Copy(lAddress, Pos('-', lAddress), MaxInt);
      if lAddress = '' then
        Continue;
      if not SameText(Trim(lOriginalAddress), lAddress) then
        RecorderMic185Log(Format(
          'Load config normalized tag link address source="%s": "%s" -> "%s"',
          [lSourceId, lOriginalAddress, lAddress]));
      lTagName := Trim(lLink.Get('tagName', lAddress));
      if lTagName = '' then
        lTagName := lAddress;
      lTag := nil;
      for K := 0 to ARegistry.TagCount - 1 do
        if SameText(ARegistry.Tags[K].SourceId, lSourceId) and
          SameText(ARegistry.Tags[K].Address, lAddress) then
        begin
          lTag := ARegistry.Tags[K];
          Break;
        end;
      if lTag = nil then
        lTag := ARegistry.FindByName(lTagName);
      lCreated := lTag = nil;
      if lTag = nil then
      begin
        lCapacity := Ceil(Max(4096, lPollHz * 4));
        lTag := ARegistry.CreateTag(lTagName, lCapacity);
      end;
      lTag.SourceId := lSourceId;
      lTag.Address := lAddress;
      lTag.ModuleType := CMic185ModuleName;
      lTag.PollFrequencyHz := lLink.Get('pollFrequencyHz', lPollHz);
      lTag.HardwareCalibrationEnabled := lLink.Get(
        'hardwareCalibrationEnabled', lTag.HardwareCalibrationEnabled);
      lTag.HardwareCalibrationName := lLink.Get('hardwareCalibrationName',
        lTag.HardwareCalibrationName);
      lMode := lLink.Get('sourceValueMode', '');
      if Trim(lMode) = '' then
        lMode := lTag.SourceValueMode;
      if (Trim(lMode) <> '') and
        (not RecorderMic185GetSourceChannelMode(ARegistry, lSourceId, lAddress,
          lTag.PollFrequencyHz, lSettings)) then
      begin
        RecorderMic185ReadChannelMode(lMode, lTag.PollFrequencyHz, lSettings);
        RecorderMic185SetSourceChannelMode(ARegistry, lSourceId, lAddress,
          lTag.PollFrequencyHz, lSettings);
      end;
      lTag.SourceValueMode := '';
      if lCreated then
      begin
        lTag.AutoRange := False;
        lTag.AutoUnit := False;
      end;
      if lCreated or (Trim(lTag.Description) = '') then
        lTag.Description := Format('%s channel %s', [CMic185ModuleName, lAddress]);
      if RecorderMic185ChannelAddressToIndex(lAddress) >= 0 then
      begin
        RecorderMic185GetSourceChannelMode(ARegistry, lSourceId, lAddress,
          lTag.PollFrequencyHz, lSettings);
        RecorderMic185LoadHardwareCalibrationForTag(ARegistry, lTag,
          lTag.HardwareCalibrationEnabled);
        if lTag.HardwareCalibrationEnabled then
        begin
          lMode := RecorderMic185GetSourceChannelUnitName(ARegistry,
            lSourceId, lAddress);
          if lMode <> '' then
            lTag.UnitName := lMode
          else if Trim(lTag.UnitName) = '' then
            lTag.UnitName := RecorderMic185RangeUnitText(
              lSettings.MeasRangeIndex);
        end
        else
          lTag.UnitName := 'код';
        lTag.RangeMax := RecorderMic185EffectiveRangeMaxForTag(ARegistry,
          lTag, lSettings, lTag.UnitName);
        lTag.RangeMin := -lTag.RangeMax;
      end
      else if Pos('-t', LowerCase(lAddress)) > 0 then
      begin
        lTag.UnitName := '°C';
        lTag.RangeMin := CMic185TempMinRangeC;
        lTag.RangeMax := CMic185TempMaxRangeC;
      end
      else
      begin
        lTag.UnitName := 's';
        lTag.RangeMin := 0;
        lTag.RangeMax := 0;
      end;
      lTag.EnsureBufferCapacity(Ceil(Max(4096, lTag.PollFrequencyHz * 4)));
    end;
  end;
end;

function RecorderMic185FindLiveDevice(const AHost: string; APort: Word): TRecorderMic185Device;
var
  lDevice: IRecorderDevice;
begin
  Result := nil;
  lDevice := RecorderHardwareFindLiveDevice(RecorderMic185SourceId(AHost, APort));
  if (lDevice <> nil) and (lDevice.GetNativeObject is TRecorderMic185Device) then
    Result := TRecorderMic185Device(lDevice.GetNativeObject);
end;

procedure RecorderMic185RegisterLiveDevice(AOwner: TObject; const AHost: string;
  APort: Word; ADevice: IRecorderDevice);
begin
  if (AOwner = nil) or (ADevice = nil) then
    Exit;
  RecorderHardwareRegisterLiveDevice(AOwner, RecorderMic185SourceId(AHost, APort),
    ADevice);
end;

procedure RecorderMic185UnregisterLiveDevice(AOwner: TObject);
begin
  RecorderHardwareUnregisterLiveDevice(AOwner);
end;

function RecorderMic185IsLiveDeviceConnected(const AHost: string; APort: Word): Boolean;
begin
  Result := RecorderHardwareIsSourceLinkOk(RecorderMic185SourceId(AHost, APort));
end;

function RecorderMic185TcpProbe(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
begin
  if RecorderMic185RuntimeIsBusy(AHost, APort) then
    Exit(True);
  Result := RecorderMic140TcpProbe(AHost, APort, ATimeoutMs);
end;

function RecorderMic185CleanupEndpoint(const AHost: string; APort: Word;
  out AErrorText: string; ATimeoutMs: Cardinal): Boolean;
var
  lClient: TRecorderMebiusTcpClient;
  lError: string;
begin
  Result := False;
  AErrorText := '';
  if Trim(AHost) = '' then
  begin
    AErrorText := 'MIC183/185 host is not set';
    Exit;
  end;
  if RecorderMic185RuntimeIsBusy(AHost, APort) then
  begin
    AErrorText := 'MIC183/185 endpoint is busy by active RecorderLnx session';
    Exit;
  end;

  lClient := TRecorderMebiusTcpClient.Create(AHost, APort, ATimeoutMs);
  try
    if not lClient.TryConnect(lError) then
    begin
      AErrorText := lError;
      Exit;
    end;
    if not lClient.TryCleanupMeasurementTask(lError) then
    begin
      AErrorText := lError;
      Exit;
    end;
    RecorderMic185Log(Format('CleanupEndpoint OK %s:%d', [AHost, APort]));
    Result := True;
  finally
    lClient.Free;
  end;
end;

function RecorderMic185IsSourceLinkOk(const ASourceId: string): Boolean;
var
  lHost: string;
  lPort: Word;
  lCanonId: string;
begin
  lCanonId := Trim(ASourceId);
  if RecorderHardwareIsSourceLinkOk(lCanonId) then
    Exit(True);
  if TryParseRecorderMic185SourceId(lCanonId, lHost, lPort) then
  begin
    lCanonId := RecorderMic185SourceId(lHost, lPort);
    if not SameText(lCanonId, Trim(ASourceId)) and
      RecorderHardwareIsSourceLinkOk(lCanonId) then
      Exit(True);
    if RecorderMic185RuntimeIsBusy(lHost, lPort) then
      Exit(True);
    Result := RecorderMic185TcpProbe(lHost, lPort, 1000);
    Exit;
  end;
  Result := False;
end;

function RecorderMic185TryGetLiveDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AAcquiring: Boolean): Boolean;
var
  lDevice: TRecorderMic185Device;
begin
  Result := False;
  ASerialNumber := 0;
  AVersionText := '';
  AAcquiring := False;
  if RecorderMic185RuntimeTryGetInfo(AHost, APort, ASerialNumber,
    AVersionText) then
  begin
    lDevice := RecorderMic185FindLiveDevice(AHost, APort);
    if lDevice <> nil then
      AAcquiring := lDevice.State = rdsStarted;
    Exit(True);
  end;
  lDevice := RecorderMic185FindLiveDevice(AHost, APort);
  if lDevice = nil then
    Exit;
  ASerialNumber := lDevice.DeviceSerial;
  if lDevice.SoftVersion <> 0 then
    AVersionText := Mic185FormatSoftVersion(lDevice.SoftVersion);
  AAcquiring := lDevice.State = rdsStarted;
  Result := True;
  RecorderMic185Log(Format(
    'LiveDeviceInfo %s:%d sn=%d ver=%s acquiring=%s state=%d',
    [Trim(AHost), APort, ASerialNumber, AVersionText, BoolToStr(AAcquiring, True),
     Ord(lDevice.State)]));
end;

function RecorderMic185IsEndpointLive(const AHost: string; APort: Word): Boolean;
begin
  Result := RecorderMic185IsLiveDeviceConnected(AHost, APort);
end;

procedure RecorderMic185Log(const AMessage: string);
begin
  RecorderMic185RuntimeLog(AMessage);
end;

function RecorderMic185NewLifecycleTraceId(const AOperation: string): string;
begin
  Result := Format('%s-%d-T%d', [Trim(AOperation), GetTickCount64,
    PtrUInt(GetThreadID)]);
end;

procedure RecorderMic185LifecycleLog(const ATraceId, ASourceId, APhase,
  AState, ADetails: string; AElapsedMs: QWord);
var
  lDetails: string;
begin
  lDetails := Trim(ADetails);
  if lDetails <> '' then
    lDetails := ' detail="' + StringReplace(lDetails, '"', '''',
      [rfReplaceAll]) + '"';
  RecorderMic185Log(Format(
    '[MIC185-LC] trace=%s source="%s" thread=%d phase=%s state=%s elapsed_ms=%d%s',
    [ATraceId, ASourceId, PtrUInt(GetThreadID), APhase, AState, AElapsedMs,
     lDetails]));
end;

function RecorderMic185SourceId(const AHost: string; APort: Word): string;
begin
  Result := CMic185SourcePrefix + Trim(AHost) + ':' + IntToStr(APort);
end;

function TryParseRecorderMic185SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
var
  lText: string;
  lPos: Integer;
  lPort: Integer;
begin
  Result := False;
  AHost := '';
  APort := 0;
  if Pos(CMic185SourcePrefix, ASourceId) <> 1 then
    Exit;
  lText := Trim(Copy(ASourceId, Length(CMic185SourcePrefix) + 1, MaxInt));
  lPos := RPos(':', lText);
  if lPos <= 1 then
    Exit;
  if not TryStrToInt(Copy(lText, lPos + 1, MaxInt), lPort) then
    Exit;
  if (lPort < 1) or (lPort > 65535) then
    Exit;
  AHost := Trim(Copy(lText, 1, lPos - 1));
  if AHost = '' then
    Exit;
  APort := Word(lPort);
  Result := True;
end;

function RecorderMic185ReadDeviceInfo(const AHost: string; APort: Word;
  out ASerialNumber: LongWord; out AVersionText: string;
  out AErrorText: string; ATimeoutMs: Cardinal): Boolean;
var
  lAcquiring: Boolean;
begin
  Result := False;
  ASerialNumber := 0;
  AVersionText := '';
  AErrorText := '';
  if Trim(AHost) = '' then
  begin
    AErrorText := 'MIC183/185 host is not set';
    Exit;
  end;

  if RecorderMic185TryGetLiveDeviceInfo(Trim(AHost), APort, ASerialNumber,
    AVersionText, lAcquiring) then
  begin
    Result := True;
    Exit;
  end;

  AErrorText := 'Нет активного подключения MIC183/185';
  RecorderMic185Log(Format('ReadDeviceInfo %s:%d: no live device (%s)',
    [Trim(AHost), APort, AErrorText]));
end;

constructor TRecorderMic185DataSource.Create(const ASourceId, AHost: string;
  APort: Word; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  ASelectedNames: TStrings);
begin
  inherited Create(ASourceId, 'MIC183/185 data source', AUpdateTimeMs);
  fHost := AHost;
  fPort := APort;
  fPollFrequencyHz := APollFrequencyHz;
  if fPollFrequencyHz <= 0 then
    fPollFrequencyHz := MIC185DefaultPollFrequencyHz;
  fChannelTagNames := TStringList.Create;
  fChannelTagNames.CaseSensitive := False;
  fSelectedNames := TStringList.Create;
  fSelectedNames.CaseSensitive := False;
  if ASelectedNames <> nil then
    fSelectedNames.Assign(ASelectedNames);
end;

destructor TRecorderMic185DataSource.Destroy;
begin
  Stop;
  { Destroy closes the device session. A normal Preview/Record -> Stop
    transition deliberately keeps it connected and programmed so that the
    next run only starts acquisition. }
  RecorderHardwareUnregisterLiveDevice(Self);
  fDevice := nil;
  fHardwarePrepared := False;
  fHardwarePrepareAttempted := False;
  fSelectedNames.Free;
  fChannelTagNames.Free;
  inherited Destroy;
end;

function TRecorderMic185DataSource.FindTagBySourceAddress(
  ARegistry: TRecorderTagRegistry; const AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, SourceId) and
      SameMic185Address(lTag.Address, AAddress) then
    begin
      { Миграция адреса, зависевшего от порядка обнаружения, на IP-адрес. }
      lTag.Address := Mic185CanonicalAddress(AAddress);
      Exit(lTag);
    end;
  end;
end;

function TRecorderMic185DataSource.ChannelSelected(
  const AChannel: TRecorderDeviceChannel): Boolean;
var
  I: Integer;
begin
  Result := (fSelectedNames.Count = 0) or
    (fSelectedNames.IndexOf(AChannel.Name) >= 0) or
    (fSelectedNames.IndexOf(AChannel.Address) >= 0);
  if Result then
    Exit;
  for I := 0 to fSelectedNames.Count - 1 do
    if SameMic185Address(fSelectedNames[I], AChannel.Address) then
      Exit(True);
end;

procedure TRecorderMic185DataSource.TraceZeroBalance(const AText: string);
begin
  if Assigned(fZeroBalanceTrace) then
    fZeroBalanceTrace(AText);
end;

procedure TRecorderMic185DataSource.SetZeroBalanceTrace(
  AHandler: TRecorderZeroBalanceTraceEvent);
begin
  fZeroBalanceTrace := AHandler;
end;

function TRecorderMic185DataSource.ZeroBalanceTags(AOwner: TComponent;
  ATags: TList; AMessages: TStrings): Boolean;
var
  I: Integer;
  lChannels: array of Integer;
  lIndex: Integer;
  lTag: TRecorderTag;
begin
  Result := False;
  if ATags = nil then
    Exit;
  SetLength(lChannels, 0);
  for I := 0 to ATags.Count - 1 do
  begin
    lTag := TRecorderTag(ATags[I]);
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;
    lIndex := RecorderMic185ChannelAddressToIndex(lTag.Address);
    if lIndex < 0 then
      Continue;
    SetLength(lChannels, Length(lChannels) + 1);
    lChannels[High(lChannels)] := lIndex;
  end;
  if Length(lChannels) = 0 then
  begin
    if AMessages <> nil then
      AMessages.Add('Нет измерительных каналов MIC183/185 для балансировки.');
    Exit;
  end;
  TraceZeroBalance(Format('MIC183/185 %s: channels=%d',
    [SourceId, Length(lChannels)]));
  Result := RecorderMic185ZeroBalanceChannels(Registry, SourceId, lChannels,
    AMessages);
  if Result then
  begin
    if fDevice <> nil then
      ApplyChannelProgramSettings
    else
    begin
      RecorderMic185BuildSourceProgramSettings(Registry, SourceId,
        fPollFrequencyHz, fRuntimeChannelSettings);
      CacheRuntimeChannels;
    end;
    RecorderMic185Log(Format(
      'ZeroBalance %s runtime transform cache refreshed', [SourceId]));
  end;
end;

procedure RecorderMic185SetKnownIdentity(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; ASerialNumber, ASoftVersion: LongWord);
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
begin
  lEntry := RecorderMic185EnsureConfiguredSource(ARegistry, ASourceId,
    MIC185DefaultPollFrequencyHz);
  lConfig := Mic185SourceConfigObject(lEntry, True);
  try
    if ASerialNumber <> 0 then
      lConfig.Integers['serialNumber'] := ASerialNumber;
    if ASoftVersion <> 0 then
      lConfig.Integers['softVersion'] := ASoftVersion;
    Mic185StoreSourceConfigObject(lEntry, lConfig);
  finally
    lConfig.Free;
  end;
end;

function RecorderMic185GetKnownIdentity(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; out ASerialNumber, ASoftVersion: LongWord): Boolean;
var
  lConfig: TJSONObject;
  lEntry: TRecorderConfiguredDataSource;
begin
  ASerialNumber := 0;
  ASoftVersion := 0;
  lEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
  lConfig := Mic185SourceConfigObject(lEntry, False);
  try
    if lConfig = nil then
      Exit(False);
    ASerialNumber := LongWord(lConfig.Get('serialNumber', 0));
    ASoftVersion := LongWord(lConfig.Get('softVersion', 0));
    Result := (ASerialNumber <> 0) or (ASoftVersion <> 0);
  finally
    lConfig.Free;
  end;
end;

procedure TRecorderMic185DataSource.ConfigureDevice;
var
  lKnownSerial, lKnownVersion: LongWord;
  lNative: TObject;
begin
  fDevice := CreateRecorderMic185Device;
  lNative := fDevice.GetNativeObject;
  if lNative is TRecorderMic185Device then
  begin
    TRecorderMic185Device(lNative).RecorderDeviceIndex :=
      RecorderMic185SourceDeviceIndex(Registry, SourceId);
    if RecorderMic185GetKnownIdentity(Registry, SourceId, lKnownSerial,
      lKnownVersion) then
      TRecorderMic185Device(lNative).ApplyKnownIdentity(lKnownSerial,
        lKnownVersion);
  end;
  fDevice.TrySetDeviceProperty(rdpHost, fHost);
  fDevice.TrySetDeviceProperty(rdpPort, Integer(fPort));
  fDevice.TrySetDeviceProperty(rdpPollFrequencyHz, fPollFrequencyHz);
  fDevice.TrySetDeviceProperty(rdpUpdateTimeMs, Integer(UpdateTimeMs));
end;

function Mic185BlockSize(AFrequencyHz: Double;
  AUpdateTimeMs: Cardinal): Word;
var
  lCount: Int64;
begin
  { Размер аппаратной порции задаётся в отсчётах канала. Оригинальный
    Recorder вычисляет его из частоты и периода данных перед Program. }
  lCount := Round(AFrequencyHz * AUpdateTimeMs / 1000.0);
  if lCount < 1 then
    lCount := 1
  else if lCount > High(Word) then
    lCount := High(Word);
  Result := Word(lCount);
end;

procedure TRecorderMic185DataSource.ApplyChannelProgramSettings;
var
  I: Integer;
  lDevice: TRecorderMic185Device;
  lGroupAddition: TMic185GroupAdditionArray;
  lModuleSettings: TMic185ModuleProgramSettings;
  lSummary: string;
  lSettings: TMic185ChannelProgramSettingsArray;
  lTemperatureCompensation: Boolean;
begin
  if (fDevice = nil) or (not (fDevice.GetNativeObject is TRecorderMic185Device)) then
    Exit;
  lDevice := TRecorderMic185Device(fDevice.GetNativeObject);

  RecorderMic185BuildSourceProgramSettings(Registry, SourceId, fPollFrequencyHz,
    lSettings);
  for I := 0 to High(lSettings) do
    lSettings[I].BlockSize := Mic185BlockSize(lSettings[I].FrequencyHz,
      UpdateTimeMs);
  fRuntimeChannelSettings := lSettings;
  RecorderMic185GetSourceGroupAddition(Registry, SourceId, lGroupAddition);
  RecorderMic185GetSourceModuleSettings(Registry, SourceId, lModuleSettings);
  lTemperatureCompensation :=
    RecorderMic185GetSourceTemperatureCompensation(Registry, SourceId);
  lSummary := '';

  for I := 0 to High(lSettings) do
  begin
    if lSummary <> '' then
      lSummary := lSummary + '; ';
    lSummary := lSummary + Format('ch%d range=%d commut=%d block=%d',
      [I + 1, lSettings[I].MeasRangeIndex,
       lSettings[I].CommutIndex, lSettings[I].BlockSize]);
  end;

  if lSummary <> '' then
    RecorderMic185Log(Format(
      'ApplyChannelProgramSettings %s power=%d tkc=%s groupAddition=%s: %s',
      [SourceId, lSettings[0].PowerMaCode,
       BoolToStr(lTemperatureCompensation, True),
       RecorderMic185FormatGroupAddition(lGroupAddition), lSummary]));
  lDevice.ApplyChannelProgramSettings(lSettings, lGroupAddition,
    lTemperatureCompensation, lModuleSettings);
  CacheRuntimeChannels;
end;

procedure TRecorderMic185DataSource.CacheRuntimeChannels;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lSettings: TMic185ChannelProgramSettings;
  lTag: TRecorderTag;
begin
  SetLength(fValueTransforms, Length(fChannelTags));
  for I := 0 to High(fChannelTags) do
  begin
    lTag := fChannelTags[I];
    SetLength(fValueTransforms[I].ChannelCalibrations, 0);
    fValueTransforms[I].IsLinear := True;
    fValueTransforms[I].K := 1.0;
    fValueTransforms[I].B := 0.0;
    if lTag = nil then
      Continue;

    lCalibration := Registry.FindTagHardwareCalibration(lTag);
    if lTag.HardwareCalibrationEnabled and (lCalibration = nil) and
      (Trim(lTag.HardwareCalibrationName) <> '') then
    begin
      RecorderMic185LoadHardwareCalibrationForTag(Registry, lTag, False);
      lCalibration := Registry.FindTagHardwareCalibration(lTag);
    end;

    if I > High(fRuntimeChannelSettings) then
      Continue;
    lSettings := fRuntimeChannelSettings[I];
    fValueTransforms[I] := Mic185BuildValueTransform(Registry, lTag,
      lSettings, lCalibration);
  end;
end;

procedure TRecorderMic185DataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lCapacity: Integer;
  lChannels: TRecorderDeviceChannelArray;
  lChannelSettings: TMic185ChannelProgramSettings;
  lTag: TRecorderTag;
  lCreated: Boolean;
  lUnitName: string;
begin
  if fDevice = nil then
    ConfigureDevice;

  ARegistry.RegisterActiveSource(SourceId);
  fChannelTagNames.Clear;
  lChannels := fDevice.GetChannels;
  SetLength(fChannelTags, Min(Length(lChannels), CMic185ChannelCountMax));
  SetLength(fTempTags, CMic185TempChannelCount);
  fUtsTag := nil;
  for I := 0 to High(lChannels) do
  begin
    if not ChannelSelected(lChannels[I]) then
      Continue;

    lTag := FindTagBySourceAddress(ARegistry, lChannels[I].Address);
    if lTag = nil then
      lTag := ARegistry.FindByName(lChannels[I].Name);
    lCreated := lTag = nil;
    if lTag = nil then
    begin
      lCapacity := Ceil(Max(4096, lChannels[I].PollFrequencyHz * 4));
      lTag := ARegistry.CreateTag(lChannels[I].Name, lCapacity);
    end;

    lTag.SourceId := SourceId;
    lTag.Address := lChannels[I].Address;
    lTag.ModuleType := CMic185ModuleName;
    lTag.PollFrequencyHz := lChannels[I].PollFrequencyHz;
    lTag.SourceValueMode := '';
    if I < CMic185ChannelCountMax then
    begin
      RecorderMic185GetSourceChannelMode(ARegistry, SourceId,
        lChannels[I].Address, lChannels[I].PollFrequencyHz, lChannelSettings);
      if lTag.HardwareCalibrationEnabled then
      begin
        lUnitName := RecorderMic185GetSourceChannelUnitName(ARegistry,
          SourceId, lChannels[I].Address);
        if lUnitName <> '' then
          lTag.UnitName := lUnitName
        else if Trim(lTag.UnitName) = '' then
          lTag.UnitName := RecorderMic185RangeUnitText(
            lChannelSettings.MeasRangeIndex);
      end
      else
        lTag.UnitName := 'код';
      lTag.RangeMax := RecorderMic185EffectiveRangeMaxForTag(ARegistry,
        lTag, lChannelSettings, lTag.UnitName);
      lTag.RangeMin := -lTag.RangeMax;
    end
    else
    begin
      lTag.UnitName := lChannels[I].UnitName;
      if I < CMic185ChannelCountMax + CMic185TempChannelCount then
      begin
        lTag.RangeMin := CMic185TempMinRangeC;
        lTag.RangeMax := CMic185TempMaxRangeC;
      end;
    end;
    if lCreated then
    begin
      lTag.AutoRange := False;
      lTag.AutoUnit := False;
    end;
    if lCreated or (Trim(lTag.Description) = '') then
      lTag.Description := Format('%s channel %s',
        [CMic185ModuleName, lChannels[I].Address]);
    lTag.EnsureBufferCapacity(Ceil(Max(4096, lChannels[I].PollFrequencyHz * 4)));
    fChannelTagNames.Add(lTag.Name);
    if I < Length(fChannelTags) then
      fChannelTags[I] := lTag
    else if I < CMic185ChannelCountMax + Length(fTempTags) then
      fTempTags[I - CMic185ChannelCountMax] := lTag
    else
      fUtsTag := lTag;
  end;
end;

procedure TRecorderMic185DataSource.PrepareHardware;
var
  lStartDelayMs: Cardinal;
  lTestError: string;
  lNativeDevice: TRecorderMic185Device;
  lInitializeOk: Boolean;
  lStageStartedAt: QWord;
  lTraceId: string;
begin
  if RecorderHardwareConsumeSourceResetRequest(SourceId) then
  begin
    fHardwarePrepared := False;
    fHardwarePrepareAttempted := False;
    RecorderHardwareClearSourceOffline(SourceId);
  end;
  if fHardwarePrepared or fHardwarePrepareAttempted then
    Exit;
  { До завершения протокольной проверки источник не считается исправным.
    Иначе дерево показывало зелёный статус сразу после загрузки конфигурации,
    хотя Connect/Initialize/Configure ещё не выполнялись. }
  RecorderHardwareMarkSourceOffline(SourceId,
    'Проверка связи и инициализация ещё не завершены');
  fHardwarePrepareAttempted := True;
  lTraceId := RecorderMic185NewLifecycleTraceId('startup');
  RecorderMic185LifecycleLog(lTraceId, SourceId, 'operation', 'BEGIN',
    Format('endpoint=%s:%d bind=%s', [fHost, fPort,
      RecorderNetworkBindAddress]));
  lStartDelayMs := Mic185EndpointStartDelayMs(fHost);
  if lStartDelayMs > 0 then
  begin
    RecorderMic185LifecycleLog(lTraceId, SourceId, 'startup-stagger', 'BEGIN',
      Format('delay_ms=%d', [lStartDelayMs]));
    Sleep(lStartDelayMs);
    RecorderMic185LifecycleLog(lTraceId, SourceId, 'startup-stagger', 'OK', '',
      lStartDelayMs);
  end;
  { Прошивка MIC-185 допускает параллельный сбор, но одновременное
    программирование нескольких контроллеров даёт нестабильный результат.
    Последовательно выполняется только connect/init/config. }
  inherited PrepareHardware;
  try
    if fDevice = nil then
      ConfigureDevice;
    ApplyChannelProgramSettings;
    { Connect/ProgramDevice могут бросать исключения и останавливать debugger.
      Для ожидаемо отключённого прибора сначала выполняется безопасный TEST. }
    if not (fDevice.GetNativeObject is TRecorderMic185Device) then
    begin
      RecorderHardwareMarkSourceOffline(SourceId,
        'MIC183/185 native device is unavailable');
      Exit;
    end;
    lNativeDevice := TRecorderMic185Device(fDevice.GetNativeObject);
    lStageStartedAt := GetTickCount64;
    RecorderMic185LifecycleLog(lTraceId, SourceId, 'connect', 'BEGIN', '');
    if not lNativeDevice.TryConnect(lTestError) then
    begin
      RecorderMic185LifecycleLog(lTraceId, SourceId, 'connect', 'FAIL',
        lTestError, GetTickCount64 - lStageStartedAt);
      RecorderMic185LifecycleLog(lTraceId, SourceId, 'operation', 'FAIL',
        'connect: ' + lTestError);
      RecorderHardwareMarkSourceOffline(SourceId, lTestError);
      RecorderHardwareUnregisterLiveDevice(Self);
      Exit;
    end;
    RecorderMic185LifecycleLog(lTraceId, SourceId, 'connect', 'OK', '',
      GetTickCount64 - lStageStartedAt);
    Mic185EnterPrepareCommandSlot(lTraceId, SourceId);
    try
      lStageStartedAt := GetTickCount64;
      RecorderMic185LifecycleLog(lTraceId, SourceId, 'initialize', 'BEGIN',
        'GetSoftVersion/read SN');
      lInitializeOk := lNativeDevice.TryInitializeSession(lTestError);
      if not lInitializeOk then
      begin
        RecorderMic185LifecycleLog(lTraceId, SourceId, 'initialize', 'FAIL',
          lTestError, GetTickCount64 - lStageStartedAt);
        RecorderMic185LifecycleLog(lTraceId, SourceId, 'operation', 'FAIL',
          'initialize: ' + lTestError);
        RecorderHardwareMarkSourceOffline(SourceId,
          'MIC183/185 initialization failed: ' + lTestError);
        RecorderHardwareUnregisterLiveDevice(Self);
        fDevice.Disconnect;
        Exit;
      end;
      RecorderMic185LifecycleLog(lTraceId, SourceId, 'initialize', 'OK',
        Format('sn=%d version=%s', [lNativeDevice.DeviceSerial,
          Mic185FormatSoftVersion(lNativeDevice.SoftVersion)]),
        GetTickCount64 - lStageStartedAt);
      RecorderMic185SetKnownIdentity(Registry, SourceId,
        lNativeDevice.DeviceSerial, lNativeDevice.SoftVersion);

      lStageStartedAt := GetTickCount64;
      RecorderMic185LifecycleLog(lTraceId, SourceId, 'configure', 'BEGIN', '');
      if not lNativeDevice.TryProgramDevice(lTestError) then
      begin
        RecorderMic185LifecycleLog(lTraceId, SourceId, 'configure', 'FAIL',
          lTestError, GetTickCount64 - lStageStartedAt);
        RecorderMic185LifecycleLog(lTraceId, SourceId, 'operation', 'FAIL',
          'configure: ' + lTestError);
        RecorderHardwareMarkSourceOffline(SourceId,
          'MIC183/185 programming failed: ' + lTestError);
        RecorderHardwareUnregisterLiveDevice(Self);
        fDevice.Disconnect;
        Exit;
      end;
      RecorderMic185LifecycleLog(lTraceId, SourceId, 'configure', 'OK', '',
        GetTickCount64 - lStageStartedAt);
    finally
      Mic185LeavePrepareCommandSlot;
    end;
    RecorderMic185RegisterLiveDevice(Self, fHost, fPort, fDevice);
    fHardwarePrepared := True;
    RecorderHardwareClearSourceOffline(SourceId);
    RecorderMic185LifecycleLog(lTraceId, SourceId, 'operation', 'OK',
      Format('sn=%d', [lNativeDevice.DeviceSerial]));
  except
    on E: Exception do
    begin
      RecorderMic185LifecycleLog(lTraceId, SourceId, 'operation', 'EXCEPTION',
        E.ClassName + ': ' + E.Message);
      RecorderHardwareMarkSourceOffline(SourceId, E.Message);
      RecorderHardwareUnregisterLiveDevice(Self);
      if fDevice <> nil then
      begin
        try
          fDevice.Disconnect;
        except
        end;
      end;
    end;
  end;
end;

procedure TRecorderMic185DataSource.Start;
var
  lError: string;
  lDevice: TRecorderMic185Device;
begin
  inherited Start;
  if RecorderHardwareIsSourceOffline(SourceId) then
    Exit;
  if fDevice = nil then
    ConfigureDevice;
  if (not fHardwarePrepared) and fHardwarePrepareAttempted then
    Exit;
  CacheRuntimeChannels;
  if fDevice.State <> rdsStarted then
  begin
    if not (fDevice.GetNativeObject is TRecorderMic185Device) then
    begin
      RecorderHardwareMarkSourceOffline(SourceId,
        'MIC183/185 native device is unavailable');
      Exit;
    end;
    lDevice := TRecorderMic185Device(fDevice.GetNativeObject);
    if not lDevice.TryStart(lError) then
    begin
      RecorderMic185Log(Format('%s start failed: %s', [SourceId, lError]));
      RecorderHardwareMarkSourceOffline(SourceId, lError);
      Exit;
    end;
  end;
  { A new acquisition session must publish its first UTS packet even if the
    datasource object is reused after Stop/Start. }
  fLastPublishedUtsGeneration := 0;
  fUtsPublishLogCount := 0;
  fDiagTick := GetTickCount64;
  fDiagBlocks := 0;
  fLastRxPackets := 0;
  fLastRxBlocks := 0;
  fLastRxTick := fDiagTick;
  fLastBlockTick := fDiagTick;
  fRxWarning := False;
  RecorderHardwareClearSourceWarning(SourceId);
end;

procedure TRecorderMic185DataSource.RequestStop;
begin
  RecorderMic185RuntimeHoldBusy(Trim(fHost), fPort, True);
  inherited RequestStop;
end;

procedure TRecorderMic185DataSource.Stop;
begin
  RecorderHardwareClearSourceWarning(SourceId);
  fRxWarning := False;
  if fDevice <> nil then
  begin
    try
      fDevice.Stop;
    except
      on E: Exception do
        ;
    end;
  end;
  RecorderMic185RuntimeHoldBusy(Trim(fHost), fPort, False);
  { Stop is an acquisition-stage operation, not Disconnect. Preserve the
    initialized/programmed session for a fast subsequent Preview or Record.
    A requested reset clears these flags at the next PrepareHardware call;
    destruction releases fDevice and closes the TCP session. }
  inherited Stop;
end;

procedure TRecorderMic185DataSource.PublishMeasurementBlock(const ABlock: TRecorderAcquisitionBlock);
var
  I, J: Integer;
  lCount: Integer;
  lTag: TRecorderTag;
  lTransform: TRecorderMic185ValueTransform;
begin
  if (Registry = nil) or (ABlock.SampleCount <= 0) or (ABlock.SampleRateHz <= 0) then
    Exit;
  // перепроверить!!! зачем в RunTime SetLength
  if Length(fTimes) < ABlock.SampleCount then
    SetLength(fTimes, ABlock.SampleCount);
  if Length(fValues) < ABlock.SampleCount then
    SetLength(fValues, ABlock.SampleCount);
  // нельзя формировать для каждой точки времена X - это задача для линий в чарте
  // там есть x0 для одномерных сигналов и dx - шейдер сам разворачивает X для каждой точки
  for J := 0 to ABlock.SampleCount - 1 do
    fTimes[J] := ABlock.FirstTimeSec + (J / ABlock.SampleRateHz);

  // собирает полный снимок настроек всех 64 измерительных каналов одного MIC-185 источника
  // из конфигурации проекта (registry / configuredDataSources), в виде массива
  // TMic185ChannelProgramSettingsArray
  // Этой функции не место в RunTime
  lCount := Min(ABlock.ChannelCount, Length(fChannelTags));
  if Length(fValueTransforms) < lCount then
    CacheRuntimeChannels;
  for I := 0 to lCount - 1 do
  begin
    // лучше хранить массив ссылок на теги. Поиск тега по имени каждый раз плохая операция!
    // у каждого канала может быть по нескольку ГХ в стеке, но если они все линейные то можно вычислить
    // итоговую линейную ГХ и делать однократное умножение в цикле.
    // Для плат которые меряют быстропеременные процессы и имеют десятки кГц
    // отсчетов за блок данных это критично. Еще применение линейной ГХ можно делать не поточечно а аппаратно ускоренными
    // функциями где сразу перемножается весь массив с константой (повод для модернизации в дальнейшем)
    lTag := fChannelTags[I];
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;
    if I <= High(fValueTransforms) then
    begin
      lTransform := fValueTransforms[I];
      if lTransform.IsLinear then
        for J := 0 to ABlock.SampleCount - 1 do
          fValues[J] := lTransform.K * ABlock.Values[I][J] + lTransform.B
      else
        for J := 0 to ABlock.SampleCount - 1 do
          fValues[J] := Mic185ApplyValueTransform(ABlock.Values[I][J],
            lTransform);
    end
    else
      for J := 0 to ABlock.SampleCount - 1 do
        fValues[J] := ABlock.Values[I][J];
    Registry.AddBlockSamples(lTag, fTimes, fValues, ABlock.SampleCount, True);
    { Значения уже пересчитаны: передаём тот же блок без повторного
      LastBlockSnapshot и второго поиска тега по имени. }
    Registry.PublishBlockNotifications(lTag, fTimes, fValues,
      ABlock.SampleCount);
  end;
  // не надо каждому отсчету время сопоставлять! вре5мя должно соответсвовать блоку а не каждому отсчету если это одномерный сигнал!
  PublishAuxChannels(fTimes[ABlock.SampleCount - 1]);
end;

// не надо каждому отсчету время сопоставлять! вре5мя должно соответсвовать блоку а не каждому отсчету если это одномерный сигнал!
procedure TRecorderMic185DataSource.PublishAuxChannels(ATimeSec: Double);
var
  I: Integer;
  lDevice: TRecorderMic185Device;
  lTag: TRecorderTag;
begin
  if (Registry = nil) or (fDevice = nil) or
    (not (fDevice.GetNativeObject is TRecorderMic185Device)) then
    Exit;
  lDevice := TRecorderMic185Device(fDevice.GetNativeObject);

  if lDevice.HasTempData then
    for I := 0 to Min(lDevice.TempChannelCount, Length(fTempTags)) - 1 do
    begin
      // поиск тега по строке в цикле на каждой итерации - не корректно!
      // надо хранить ссылки на теги
      lTag := fTempTags[I];
      // не надо каждому отсчету время сопоставлять!
      if lTag <> nil then
        Registry.PublishValue(lTag.Name, ATimeSec, lDevice.LastTempValue(I));
    end;

  if lDevice.HasUtsData and
    (lDevice.UtsGeneration <> fLastPublishedUtsGeneration) then
  begin
    lTag := fUtsTag;
    if lTag <> nil then
    begin
      { Original Recorder stores UTS as an XY pair: device-relative X and
        absolute UTS seconds Y. PublishValue preserves the same .x/.dat split. }
      Registry.PublishValue(lTag.Name, lDevice.LastUtsDeviceTimeSec,
        lDevice.LastUts);
      if fUtsPublishLogCount < 4 then
      begin
        Inc(fUtsPublishLogCount);
        RecorderMic185Log(Format(
          '[DataSource:%s] MIC-185 UTS published #%d tag=%s x=%.6f uts=%.0f gen=%d',
          [SourceId, fUtsPublishLogCount, lTag.Name,
           lDevice.LastUtsDeviceTimeSec, lDevice.LastUts,
           lDevice.UtsGeneration]));
      end;
      if Registry.TimeSystem <> nil then
        Registry.TimeSystem.UpdateFromTagSample(lDevice.LastUtsDeviceTimeSec,
          lDevice.LastUts);
    end;
    fLastPublishedUtsGeneration := lDevice.UtsGeneration;
  end;
end;

function RecorderMic185SameChannelAddress(const ALeft,
  ARight: string): Boolean;
begin
  Result := SameMic185Address(ALeft, ARight);
end;

procedure TRecorderMic185DataSource.DoTick;
var
  lBlock: TRecorderAcquisitionBlock;
  lDevice: TRecorderMic185Device;
  lError: string;
  lNow: QWord;
  lTimeout: Cardinal;
  lPackets: QWord;
  lStaleMs: QWord;
  lWarning: string;
begin
  if fDevice = nil then
    Exit;
  if RecorderHardwareIsSourceOffline(SourceId) then
    Exit;
  if fDevice.State <> rdsStarted then
  begin
    RecorderHardwareMarkSourceOffline(SourceId,
      'MIC183/185 acquisition was not started');
    Exit;
  end;

  lTimeout := Max(Cardinal(1000), UpdateTimeMs * 4);
  if fDevice.ReadBlock(lTimeout, lBlock) then
  begin
    Inc(fDiagBlocks);
    PublishMeasurementBlock(lBlock);
  end;

  if not (fDevice.GetNativeObject is TRecorderMic185Device) then
    Exit;
  lDevice := TRecorderMic185Device(fDevice.GetNativeObject);
  lNow := GetTickCount64;
  lPackets := lDevice.RxDataPacketCount;
  if lPackets <> fLastRxPackets then
  begin
    fLastRxPackets := lPackets;
    fLastRxTick := lNow;
  end;
  if fDiagBlocks <> fLastRxBlocks then
  begin
    fLastRxBlocks := fDiagBlocks;
    fLastBlockTick := lNow;
  end;
  lStaleMs := Max(QWord(3000), QWord(UpdateTimeMs) * 15);
  if fRxWarning and (lNow - fLastRxTick < lStaleMs) and
    (lNow - fLastBlockTick < lStaleMs) then
  begin
    RecorderDebugLog(Format('[MIC185-HEALTH] %s stream resumed: packets=%d blocks=%d',
      [SourceId, lPackets, fDiagBlocks]));
    RecorderHardwareClearSourceWarning(SourceId);
    fRxWarning := False;
  end;
  if (not fRxWarning) and ((lNow - fLastRxTick >= lStaleMs) or
    (lNow - fLastBlockTick >= lStaleMs)) then
  begin
    if lNow - fLastRxTick >= lStaleMs then
      lWarning := Format('TCP-сессия открыта, пакеты MIC-185 не поступают %d мс',
        [lNow - fLastRxTick])
    else
      lWarning := Format('пакеты MIC-185 поступают, готовые блоки не собраны %d мс',
        [lNow - fLastBlockTick]);
    RecorderHardwareSetSourceWarning(SourceId, lWarning);
    RecorderDebugLog(Format(
      '[MIC185-HEALTH] %s stalled: bytes=%d packets=%d data=%d blocks=%d buffered=%d maxbuf=%d compact=%d syncdrop=%d lost=%s; %s',
      [SourceId, lDevice.RxByteCount, lDevice.RxPacketCount, lPackets,
       fDiagBlocks, lDevice.RxBufferedByteCount, lDevice.RxMaxBuffered,
       lDevice.RxCompactCount, lDevice.RxSyncDropCount,
       BoolToStr(lDevice.ConnectionLost, True), lWarning]));
    fRxWarning := True;
  end;
  if lNow - fDiagTick >= 10000 then
  begin
    RecorderMic185Log(Format(
      '%s RX heartbeat: bytes=%d packets=%d data=%d blocks=%d buffered=%d maxbuf=%d compact=%d syncdrop=%d lost=%s state=%d',
      [SourceId, lDevice.RxByteCount, lDevice.RxPacketCount,
       lDevice.RxDataPacketCount, fDiagBlocks, lDevice.RxBufferedByteCount,
       lDevice.RxMaxBuffered, lDevice.RxCompactCount,
       lDevice.RxSyncDropCount, BoolToStr(lDevice.ConnectionLost, True),
       Ord(fDevice.State)]));
    fDiagTick := lNow;
  end;
  { Неполный TCP-пакет штатно остаётся в накопителе до следующего такта.
    Отсутствие готового блока не означает разрыв соединения. }
  if not lDevice.ConnectionLost then
    Exit;
  lError := Trim(lDevice.LastReadError);
  if lError = '' then
    lError := 'MIC183/185 TCP connection lost';
  RecorderMic185Log(Format('%s acquisition stopped: %s', [SourceId, lError]));
  { Не оставляем прибор владельцем зависшей Mebius-сессии. Иначе следующий
    клиент откроет TCP-порт, но прибор не будет отвечать на IoControl. }
  try
    fDevice.Disconnect;
  except
  end;
  RecorderHardwareUnregisterLiveDevice(Self);
  fHardwarePrepared := False;
  RecorderHardwareMarkSourceOffline(SourceId, lError);
end;

procedure Mic185ProjectTagLoaded(AJson: TJSONObject;
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag);
var
  lAddress: string;
  lSourceId: string;
begin
  if ATag = nil then
    Exit;
  lSourceId := RecorderNormalizeTagSourceId(ATag.SourceId);
  if not RecorderIsHardwareMic185TagSource(lSourceId) then
    Exit;

  lAddress := Mic185CanonicalAddress(ATag.Address);
  if Pos('-', lAddress) > 0 then
    lAddress := IntToStr(RecorderMic185SourceDeviceIndex(ARegistry,
      lSourceId)) + Copy(lAddress, Pos('-', lAddress), MaxInt);
  if (lAddress <> '') and (not SameText(lAddress, Trim(ATag.Address))) then
  begin
    RecorderMic185Log(Format(
      'Load tag normalized address source="%s" tag="%s": "%s" -> "%s"',
      [lSourceId, ATag.Name, ATag.Address, lAddress]));
    ATag.Address := lAddress;
  end;
end;

initialization
  InitCriticalSection(gMic185PrepareLock);
  RecorderRegisterFrequencyGrid('MIC-185:', CMic185Frequencies);
  RecorderRegisterProjectConfigExtension(@SaveMic185DataSourceConfigs,
    @LoadMic185DataSourceConfigs, @Mic185ProjectTagLoaded);
  RecorderRegisterHardwareSourceLinkProbe(@RecorderMic185HardwareLinkProbe);

finalization
  DoneCriticalSection(gMic185PrepareLock);

end.
