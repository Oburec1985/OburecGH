unit uRecorderMic140DataSource;

{
  MIC-140 core data source.

  The source uses the same RecorderLnx data-source contract as virtual/MERA
  playback sources. Transport/protocol code is isolated in
  uRecorderMebiusTcpProtocol and uRecorderMic140LegacyProtocol.
  Parsing helpers live in Device/MIC140/uRecorderMic140Utils (2026-06).
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uRecorderDataSources, uRecorderDeviceInterfaces, uRecorderMebiusTcpProtocol,
  uRecorderMic140LegacyProtocol, uRecorderMic140Utils,
  uRecorderTags;

const
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;
  MIC140DefaultPollFrequencyHz = 100.0;
  MIC140DefaultDiscoverySubnet = '192.168.14.';
  CMic140Range100mV = 0;
  CMic140RangeCount = 3;
  CMic140Mic140SubRev1 = 1;

type
  TRecorderMic140ChannelSettings = record
    RangeIndex: Integer;
    DefaultCjc: Boolean;
    CjcChannel: Integer;
    ThermocoupleScalePath: string;
    ThermocoupleScaleName: string;
  end;

  TRecorderMic140OutputMode = (
    momMillivolts,
    momTemperatureC
  );

  TRecorderMic140Timing = record
    FrequencyHz: Double;
    GroundCommutationUs: Double;
    ChannelCommutationUs: Double;
    AveragePeriodUs: Double;
    AverageSampleCount: Word;
    AveragePower: Word;
    LegacyGroundDelaySport: Word;
    LegacyChannelDelaySport: Word;
    LegacyAverageDelaySport: Word;
  end;

  TRecorderMic140Device = class(TInterfacedObject, IRecorderDevice)
  private
    fChannelCount: Integer;
    fChannels: TRecorderDeviceChannelArray;
    fClient: TRecorderMebiusTcpClient;
    fDeviceId: string;
    fHost: string;
    fLegacyClient: TRecorderMic140LegacyClient;
    fLegacyFirmware: TRecorderMic140LegacyFirmware;
    fLegacyMemAddrCur: Word;
    fLegacyMemHeapAddrCur: Word;
    fLegacyReadBlockCount: Int64;
    fLegacyReadErrorLogged: Boolean;
    fLegacyReadFailureCount: Integer;
    fLegacyReadPacketLogged: Boolean;
    fLegacyScanWasStarted: Boolean;
    fNodeNumber: Integer;
    fUseLegacyProtocol: Boolean;
    fPollFrequencyHz: Double;
    fPort: Word;
    fSampleIndex: Int64;
    fState: TRecorderDeviceState;
    fUpdateTimeMs: Cardinal;
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;
    procedure BuildChannels;
    function LegacyAllocBuffer(AWordCount: Word; out APage, AAddress: Word): Boolean;
    function LegacyAllocHeap(AWordCount: Word; out APage, AAddress: Word): Boolean;
    function LegacyInternalScanChannelCount: Integer;
    function LegacyCalcScanDivider: Word;
    function LegacyTimerPeriod: Word;
    function LegacyTimerScale: Word;
    function ProgramLegacyDevice(out AErrorMessage: string): Boolean;
  public
    constructor Create(const ADeviceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal);
    destructor Destroy; override;

    function GetDeviceSerial: Integer;
    function GetNodeNumber: Integer;
    function LegacyCalcFifoReadyWords: Word;

    procedure Connect;
    procedure Disconnect;
    procedure ProgramDevice;
    procedure Start;
    procedure Stop;
    function ReadBlock(ATimeoutMs: Cardinal; out ABlock: TRecorderDeviceSampleBlock): Boolean;

    property Host: string read fHost;
    property Port: Word read fPort;
    property ChannelCount: Integer read fChannelCount;
  end;

  TRecorderMic140DataSource = class(TRecorderDataSourceBase)
  private
    fChannelTagNames: TStringList;
    fDevice: IRecorderDevice;
    fGoodBlockCount: Int64;
    fLastStatusCode: Integer;
    fOutputMode: TRecorderMic140OutputMode;
    fPollFrequencyHz: Double;
    fReadFailCount: Integer;
    fBlockCountTagName: string;
    fStatusTagName: string;
    fTagNames: TStringList;
    fTemperatureModeWarningLogged: Boolean;
    fTemperatureTagNames: TStringList;
    fDeviceSerial: Integer;
    function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    procedure PublishDiagnostics(AStatusCode: Integer; const AStatusText: string;
      AForce: Boolean = False);
    procedure PublishBlockCounter(ABlockCount: Int64);
    procedure PublishTemperatureBlocks(const ABlock: TRecorderDeviceSampleBlock;
      const ATimes: TRecorderDoubleArray);
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
      ATagNames: TStrings = nil; AOutputMode: TRecorderMic140OutputMode = momMillivolts);
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
  end;

function RecorderMic140TestConnection(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal = 250): Boolean;
procedure RecorderMic140Discover(AFoundHosts: TStrings;
  const ASubnetPrefix: string = MIC140DefaultDiscoverySubnet;
  APort: Word = MIC140DefaultPort; ATimeoutMs: Cardinal = 180);
function RecorderMic140FrequencyCount: Integer;
function RecorderMic140Frequency(AIndex: Integer): Double;
function RecorderMic140NormalizeFrequency(AFrequencyHz: Double): Double;
function RecorderMic140TimingForFrequency(AFrequencyHz: Double): TRecorderMic140Timing;
procedure RecorderMic140ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double);
function RecorderMic140OutputModeToConfigName(AValue: TRecorderMic140OutputMode): string;
function RecorderMic140ConfigNameToOutputMode(const AValue: string): TRecorderMic140OutputMode;
function RecorderMic140OutputModeUnitName(AValue: TRecorderMic140OutputMode): string;
function RecorderMic140CalibrRootDir: string;
function RecorderMic140RangeCalibrDirName(ARangeIndex: Integer): string;
function RecorderMic140HardwareCalibrCsvPath(ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer): string;
function RecorderMic140LoadCalibrationFromCsv(const AFileName: string;
  ACalibration: TRecorderCalibration): Boolean;
function RecorderMic140QueryDeviceSerial(const AHost: string; APort: Word;
  out ADeviceSerial: Integer): Boolean;
function RecorderMic140QueryDeviceInfo(const AHost: string; APort: Word;
  out ADeviceSerial: Integer; out AVersionText: string;
  out ADevSubRev: Integer): Boolean;
function RecorderMic140DefaultCjcChannel(AChannelIndex: Integer;
  ADevSubRev: Integer): Integer;
function RecorderMic140FormatAdcRangeMv(ARangeIndex: Integer): string;
function RecorderMic140FormatAdcRangeGrad(ARangeIndex: Integer): string;
function RecorderMic140RangeComboLabel(ARangeIndex: Integer): string;
procedure RecorderMic140InitChannelSettings(out ASettings: TRecorderMic140ChannelSettings;
  AChannelIndex, ADevSubRev: Integer);
function RecorderMic140ChannelUsesTemperature(
  const ASettings: TRecorderMic140ChannelSettings): Boolean;
function RecorderMic140ChannelCjcNumber(const ASettings: TRecorderMic140ChannelSettings;
  AChannelIndex, ADevSubRev: Integer): Integer;
function RecorderMic140ChannelGradRangeText(
  const ASettings: TRecorderMic140ChannelSettings): string;
procedure RecorderMic140RestoreChannelSettingsFromTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var ASettings: TRecorderMic140ChannelSettings);
function RecorderMic140EnsureThermocoupleCalibration(
  ARegistry: TRecorderTagRegistry;
  const ASettings: TRecorderMic140ChannelSettings): string;
function RecorderMic140LoadHardwareCalibrationForTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  ADeviceSerial: Integer): Boolean;
function RecorderMic140DownloadHardwareCalibrationFromDevice(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AErrorMessage: string): Boolean;
procedure RecorderMic140ApplyHardwareCalibrations(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ADeviceSerial: Integer);

implementation

uses
  Math, StrUtils, uSharedFileLogger, uRecorderMeraPaths, uRecorderDebugLog,
  uRecorderMeraSdbThermocouples, uRecorderSdbStore
  {$IFDEF MSWINDOWS}, WinSock2{$ELSE}, BaseUnix, CTypes, Sockets{$ENDIF};

const
  CMic140StatusDisconnected = 0;
  CMic140StatusConnected = 1;
  CMic140StatusProgrammed = 2;
  CMic140StatusStarted = 3;
  CMic140StatusError = -1;
  CMic140ReadTimeoutMinMs = 1500;
  // A non-blocking drain uses 1 ms. BIOS commands must never inherit that
  // value because the device needs a normal round-trip time for stream 1.
  CMic140LegacyCommandTimeoutMs = 5000;
  CMic140NoDataFailThreshold = 10;
  CMic140ConnectAttempts = 3;
  CMic140LegacyMaxUiReadFrequencyHz = 1000.0;
  CMic140MebiusChannelCount = 16;
  CMic140MebiusTemperatureSettingsCount = 5;
  CMic140MebiusModuleCount = 4;
  CMic140FrequencyCount = 8;
  // Keep only the proven 48-channel legacy scan rate for now. The original
  // Recorder exposes lower rates too, but their timer/averaging programming must
  // be ported exactly before we let the UI send them to the real MIC-140.
  CMic140Frequencies: array[0..CMic140FrequencyCount - 1] of Double =
    (1.0, 2.0, 5.0, 10.0, 20.0, 25.0, 50.0, 100.0);
  CMic140IoCtlTypeCallCommand = 2;
  CMic140IoCtlCmdSetControllerParams =
    (CMic140IoCtlTypeCallCommand shl 16) or ($000C shl 2);
  CMic140ChannelCommutIn = 0;
  CMic140Range5mV = 2;
  CMic140RangeCalibrDirNames: array[0..CMic140RangeCount - 1] of string =
    ('06_100mV', '07_50mV', '8_25mV');
  CMic140HardwareCalibrSubDir = 'hardware' + PathDelim + 'MIC140' + PathDelim;
  CMic140TareTypeTable = 1;
  CMic140RangeCountMic140 = 3;
  CMic140Mi118TarFileName = 'mi118tar.bin';
  CMic140FlashDirOffset = 870;
  CMic140FlashDirSize = 400;
  CMic140FlashStorageBytes = 524288;
  CMic140FlashMaxDirEntries = 16;
  CMic140FlashNameLength = 13;
  CMic140MaxAinChannels96 = 96;
  CMic140MaxAinChannels48 = 48;
  CMic140MaxTinChannels96 = 3;
  CMic140TareTableMaxPoints = 5;
  CMic140SensorSchemeTenzo = 0;
  CMic140DefaultCorrectorId = 2;
  CMic140LegacyScanId = 0;
  CMic140LegacyTypeMic140 = 12;
  CMic140LegacyCmdAppendScanMain = 82;
  CMic140LegacyCmdResetScanMain = 83;
  CMic140LegacyCmdConfigScanMain = 84;
  CMic140LegacyCmdSetStateScan = 87;
  CMic140LegacyCmdScanSetChans = 132;
  CMic140LegacyCmdScanSetBuff = 133;
  CMic140LegacyCmdAddChannelModule = 152;
  CMic140LegacyDmBufferBegin = $0522;
  CMic140LegacyDmBufferEnd = $07FF;
  CMic140LegacyDmHeapBegin = $0800;
  CMic140LegacyDmHeapEnd = $2BFF;
  CMic140LegacyFreqClkHz = 16000000.0;
  CMic140LegacyTimerPeriod = 640;
  CMic140LegacySportSclkDivProgr = 4;
  CMic140LegacyPeriodProgrammingChanCode =
    (CMic140LegacySportSclkDivProgr + 1) * 2 * (16 * 2 + (16 + 3));
  CMic140LegacyPeriodAdSec = 5.0E-6;
  CMic140LegacyInitPeriodDecaySec = 57.0E-6;
  CMic140LegacyPeriodSumChanCode = 58;
  CMic140LegacyPeriodWriteChanCode = 115;
  CMic140LegacyPeriodTimerOsc = 62;
  CMic140LegacyDeltaSport = 11;
  CMic140LegacyPeriod1ChanCode = 30;
  CMic140LegacyPeriod21ChanCode = 21;
  CMic140LegacyPeriod2ChanCode = 27;
  CMic140LegacyPeriod3ChanCode = 59;
  CMic140LegacyPeriod4ChanCode = 120;
  CMic140LegacyPeriodTimerWork = 80 + 32;
  CMic140LegacyMinCountAver = 1;
  CMic140LegacyMaxCountAver = 32767;
  CMic140LegacyBiosScanContextWords = 6;
  CMic140LegacyBiosScanBufferDescWords = 10;
  CMic140LegacyDescChanWords = 5;
  CMic140LegacyStartDescChanWords = 3;
  CMic140LegacyMaskGroundChannel = $4000;
  CMic140CjcNotAvailable = -1.0E300;
  CMic140InverseCalibrationMinMv = -20.0;
  CMic140InverseCalibrationMaxMv = 100.0;
  CMic140InverseCalibrationIterations = 48;
  CMic140TemperOffset48: array[0..47] of Double =
    (-1.031435079, -0.937924386, -0.844413694, -0.750903001,
     -0.657392308, -0.563881616, -0.583159437, -0.602437259,
     -0.621715081, -0.640992902, -0.660270724, -0.679548546,
     -0.694781807, -0.710015069, -0.72524833, -0.740481592,
     -0.755714853, -0.770948114, -0.794092153, -0.817236192,
     -0.840380231, -0.863524269, -0.886668308, -0.909812347,
     -0.822163798, -0.719807632, -0.617451466, -0.5150953,
     -0.412739133, -0.310382967, -0.208026801, -0.27333683,
     -0.338646859, -0.403956888, -0.469266918, -0.534576947,
     -0.599886976, -0.61596964, -0.632052304, -0.648134968,
     -0.664217632, -0.680300296, -0.696382961, -0.793844092,
     -0.891305224, -0.988766356, -1.086227488, -1.18368862);
  CMic140TInNum: array[0..11] of Integer =
    (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
  CMic140TInNumSubRev1: array[0..11] of Integer =
    (4, 3, 2, 1, 0, 5, 6, 7, 8, 9, 10, 11);
  CMic140DefaultCjcSplitChannel = 24;

type
{$packrecords 8}
  TMic140BaseChanSettings = record
    FrequencyHz: Single;
    Connected: Boolean;
  end;

  TMic140BaseDeviceChanSettings = record
    FrequencyHz: Single;
    Connected: Boolean;
    Corrector: LongWord;
    TareName: array[0..127] of AnsiChar;
    DefaultCorrector: Boolean;
    SoftBalance: Single;
    BlockSize: Word;
    MeasRangeIndex: LongWord;
    CommutIndex: LongInt;
    ShuntOn: LongWord;
    EvalType: LongWord;
    TensoSensitivity: Double;
    Resistance: Double;
    SensorScheme: LongWord;
  end;

  TMic140BaseSettings = record
    Channels: array[0..CMic140MebiusChannelCount + CMic140MebiusTemperatureSettingsCount - 1] of TMic140BaseDeviceChanSettings;
    TemperatureChannels: array[0..CMic140MebiusTemperatureSettingsCount - 1] of TMic140BaseChanSettings;
    SerialNumber: LongWord;
    GroundEnabled: Boolean;
    GroundCommutationUs: LongWord;
    ChannelCommutationUs: LongWord;
    BalancePortionLength: LongWord;
    HardBalance: LongWord;
    AveragePointCount: Word;
    PowerMaCode: LongWord;
    Reserved: LongWord;
    MaxFreqMode: LongWord;
    CalibrShuntIndex: LongWord;
    GroupAddition: array[0..CMic140MebiusModuleCount - 1] of LongWord;
    DetermineBreak: Boolean;
    HardwareBalanceOn: Boolean;
    TemperatureCompensation: Boolean;
    SoftVersion: LongWord;
  end;
{$packrecords default}

procedure Mic140LogWarning(const AMessage: string);
begin
  SharedLogger.Enabled := True;
  SharedLogger.Warning(AMessage);
end;

procedure Mic140LogFlash(const AMessage: string);
begin
  SharedLogger.Enabled := True;
  SharedLogger.Info(AMessage);
end;

function Mic140FlashLogFilePath: string;
begin
  Result := SharedLogger.FileName;
  if Result = '' then
    Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\..\LogWindows.log');
end;

function Mic140BytesToHex(const AData; ASize, AMaxBytes: Integer): string;
var
  lCount: Integer;
  lI: Integer;
  lBytes: PByte;
begin
  Result := '';
  lBytes := @AData;
  lCount := ASize;
  if lCount > AMaxBytes then
    lCount := AMaxBytes;
  for lI := 0 to lCount - 1 do
    Result := Result + IntToHex(lBytes[lI], 2);
  if ASize > AMaxBytes then
    Result := Result + '...';
end;

function RecorderMic140FrequencyCount: Integer;
begin
  Result := CMic140FrequencyCount;
end;

function RecorderMic140Frequency(AIndex: Integer): Double;
begin
  if (AIndex < 0) or (AIndex >= CMic140FrequencyCount) then
    raise ERecorderDeviceError.CreateFmt('MIC-140 frequency index is invalid: %d',
      [AIndex]);
  Result := CMic140Frequencies[AIndex];
end;

function RecorderMic140NormalizeFrequency(AFrequencyHz: Double): Double;
var
  I: Integer;
  lBestDelta: Double;
  lDelta: Double;
begin
  Result := MIC140DefaultPollFrequencyHz;
  lBestDelta := MaxDouble;
  for I := 0 to High(CMic140Frequencies) do
  begin
    lDelta := Abs(CMic140Frequencies[I] - AFrequencyHz);
    if lDelta < lBestDelta then
    begin
      lBestDelta := lDelta;
      Result := CMic140Frequencies[I];
    end;
  end;
end;

function Mic140LegacyPeriodToSport(APeriodSec: Double): LongWord;
begin
  Result := LongWord(Trunc(APeriodSec * CMic140LegacyFreqClkHz + 1.0E-9)) and $00FFFFFF;
end;

function Mic140LegacySportToPeriod(ACount: LongWord): Double;
begin
  Result := (ACount and $00FFFFFF) / CMic140LegacyFreqClkHz;
end;

function Mic140LegacyCodeToPeriod(ACount: Double): Double;
begin
  Result := ACount / (2.0 * CMic140LegacyFreqClkHz);
end;

function Mic140LegacyMinProgrammingPeriod: Double;
begin
  Result := CMic140LegacyPeriodProgrammingChanCode /
    (2.0 * CMic140LegacyFreqClkHz);
end;

function Mic140LegacyMinGroundPeriod: Double;
var
  lPeriod: Double;
begin
  lPeriod := Mic140LegacyCodeToPeriod(CMic140LegacyPeriod4ChanCode) +
    Mic140LegacyMinProgrammingPeriod;
  if lPeriod < CMic140LegacyPeriodAdSec then
    lPeriod := CMic140LegacyPeriodAdSec;
  Result := Mic140LegacySportToPeriod(Mic140LegacyPeriodToSport(lPeriod));
end;

function Mic140LegacyPeriodDecayToSport(APeriodSec: Double): Word;
var
  lPeriod: Double;
begin
  // ModuleMIC140_96::PeriodDecayToSport(): the descriptor stores only the
  // SPORT wait part; fixed ADC/channel-programming delays are subtracted.
  lPeriod := APeriodSec -
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod3ChanCode) -
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod1ChanCode) -
    Mic140LegacyCodeToPeriod(CMic140LegacyDeltaSport) -
    Mic140LegacyMinProgrammingPeriod;
  if lPeriod < 0.0 then
    lPeriod := 0.0;
  Result := Word(Mic140LegacyPeriodToSport(lPeriod) and $FFFF);
end;

function Mic140LegacySportToPeriodDecay(ACount: Word): Double;
begin
  Result := Mic140LegacySportToPeriod(ACount) +
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod3ChanCode) +
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod1ChanCode) +
    Mic140LegacyCodeToPeriod(CMic140LegacyDeltaSport) +
    Mic140LegacyMinProgrammingPeriod;
end;

function Mic140LegacyPeriodAverageToSport(APeriodSec: Double): Word;
var
  lPeriod: Double;
begin
  lPeriod := APeriodSec -
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod21ChanCode) -
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod1ChanCode) -
    Mic140LegacyCodeToPeriod(CMic140LegacyDeltaSport);
  if lPeriod < 0.0 then
    lPeriod := 0.0;
  Result := Word(Mic140LegacyPeriodToSport(lPeriod) and $FFFF);
end;

function Mic140LegacySportToPeriodAverage(ACount: Word): Double;
begin
  Result := Mic140LegacySportToPeriod(ACount) +
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod21ChanCode) +
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriod1ChanCode) +
    Mic140LegacyCodeToPeriod(CMic140LegacyDeltaSport);
end;

function Mic140LegacyCalcPeriodDecay(ACountChans: Word; APeriodSec,
  APeriodAverSec: Double; ACountAver: Word; AGroundEnabled: Boolean): Double;
var
  lPeriodProc: Double;
  lPeriods: Double;
  lTimerFactor: Double;
  lGroundPeriod: Double;
begin
  lTimerFactor := 1.0 + (2.0 * CMic140LegacyFreqClkHz /
    CMic140LegacyTimerPeriod) *
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriodTimerWork);
  lPeriods := APeriodSec / lTimerFactor;
  APeriodAverSec := Mic140LegacySportToPeriodAverage(
    Mic140LegacyPeriodAverageToSport(APeriodAverSec));
  lPeriodProc := Mic140LegacyCodeToPeriod(CMic140LegacyPeriod2ChanCode);
  if AGroundEnabled then
  begin
    lGroundPeriod := Mic140LegacySportToPeriodDecay(
      Mic140LegacyPeriodDecayToSport(Mic140LegacyMinGroundPeriod));
    Result := (lPeriods - (ACountChans div 2) * lGroundPeriod) /
      (ACountChans div 2) - (lPeriodProc + (ACountAver - 1) * APeriodAverSec);
  end
  else
    Result := lPeriods / ACountChans -
      (lPeriodProc + (ACountAver - 1) * APeriodAverSec);
end;

function Mic140LegacyCalcCountAver(ACountChans: Word; APeriodSec,
  APeriodDecaySec, APeriodAverSec: Double; AGroundEnabled: Boolean): Word;
var
  lCount: LongInt;
  lPeriodProc: Double;
  lPeriods: Double;
  lTimerFactor: Double;
  lGroundPeriod: Double;
begin
  lTimerFactor := 1.0 + (2.0 * CMic140LegacyFreqClkHz /
    CMic140LegacyTimerPeriod) *
    Mic140LegacyCodeToPeriod(CMic140LegacyPeriodTimerWork);
  lPeriods := APeriodSec / lTimerFactor;
  APeriodDecaySec := Mic140LegacySportToPeriodDecay(
    Mic140LegacyPeriodDecayToSport(APeriodDecaySec));
  APeriodAverSec := Mic140LegacySportToPeriodAverage(
    Mic140LegacyPeriodAverageToSport(APeriodAverSec));
  lPeriodProc := Mic140LegacyCodeToPeriod(CMic140LegacyPeriod2ChanCode);
  if AGroundEnabled then
  begin
    lGroundPeriod := Mic140LegacySportToPeriodDecay(
      Mic140LegacyPeriodDecayToSport(Mic140LegacyMinGroundPeriod));
    lCount := Trunc(((lPeriods - (ACountChans div 2) * lGroundPeriod) /
      (ACountChans div 2) - (lPeriodProc + APeriodDecaySec)) /
      APeriodAverSec + 1.0);
  end
  else
    lCount := Trunc((lPeriods / ACountChans -
      (lPeriodProc + APeriodDecaySec)) / APeriodAverSec + 1.0);

  if lCount < CMic140LegacyMinCountAver then
    lCount := CMic140LegacyMinCountAver;
  if lCount > CMic140LegacyMaxCountAver then
    lCount := CMic140LegacyMaxCountAver;
  Result := Word(lCount);
end;

function Mic140LegacyTimingForFrequency(AFrequencyHz: Double;
  AChannelCount: Integer): TRecorderMic140Timing;
var
  lCountChans: Word;
  lPeriodDecaySec: Double;
begin
  Result.FrequencyHz := RecorderMic140NormalizeFrequency(AFrequencyHz);
  if AChannelCount <= 0 then
    AChannelCount := MIC140DefaultChannelCount;

  // Original default is ModuleMC114::AUTO_CALC_COUNT_AVER: keep the channel
  // settling time at 57 us and adjust the number of averaged ADC conversions.
  lCountChans := Word(AChannelCount * 2);
  lPeriodDecaySec := Mic140LegacyCalcPeriodDecay(lCountChans,
    1.0 / Result.FrequencyHz, CMic140LegacyPeriodAdSec, 1, True);
  if lPeriodDecaySec > CMic140LegacyInitPeriodDecaySec then
    lPeriodDecaySec := CMic140LegacyInitPeriodDecaySec;
  if lPeriodDecaySec < Mic140LegacyMinGroundPeriod then
    lPeriodDecaySec := Mic140LegacyMinGroundPeriod;
  lPeriodDecaySec := Mic140LegacySportToPeriod(
    Mic140LegacyPeriodToSport(lPeriodDecaySec));

  Result.AveragePeriodUs := CMic140LegacyPeriodAdSec * 1000000.0;
  Result.AverageSampleCount := Mic140LegacyCalcCountAver(lCountChans,
    1.0 / Result.FrequencyHz, lPeriodDecaySec, CMic140LegacyPeriodAdSec, True);
  Result.ChannelCommutationUs := lPeriodDecaySec * 1000000.0;
  Result.GroundCommutationUs := Mic140LegacySportToPeriodDecay(
    Mic140LegacyPeriodDecayToSport(Mic140LegacyMinGroundPeriod)) * 1000000.0;
  Result.LegacyChannelDelaySport := Mic140LegacyPeriodDecayToSport(
    lPeriodDecaySec);
  Result.LegacyGroundDelaySport := Mic140LegacyPeriodDecayToSport(
    Mic140LegacyMinGroundPeriod);
  Result.LegacyAverageDelaySport := Mic140LegacyPeriodAverageToSport(
    CMic140LegacyPeriodAdSec);

  // Newer Mebius/MDQ settings encode averaging as a power of two.
  Result.AveragePower := 7;
  if Result.FrequencyHz >= 10000.0 then
    Result.AveragePower := 0
  else if Result.FrequencyHz >= 400.0 then
    Result.AveragePower := 4
  else if Result.FrequencyHz >= 250.0 then
    Result.AveragePower := 5
  else if Result.FrequencyHz >= 150.0 then
    Result.AveragePower := 6;
end;

function RecorderMic140TimingForFrequency(AFrequencyHz: Double): TRecorderMic140Timing;
begin
  Result := Mic140LegacyTimingForFrequency(AFrequencyHz,
    MIC140DefaultChannelCount);
end;

procedure RecorderMic140ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double);
var
  I: Integer;
  lCapacity: Integer;
  lFrequencyHz: Double;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or (ASourceId = '') then
    Exit;

  lFrequencyHz := RecorderMic140NormalizeFrequency(AFrequencyHz);
  lCapacity := Ceil(Max(4096, lFrequencyHz));
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) then
    begin
      lTag.PollFrequencyHz := lFrequencyHz;
      lTag.EnsureBufferCapacity(lCapacity);
    end;
  end;
end;

function RecorderMic140TcpProbe(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
{$IFDEF MSWINDOWS}
var
  lAddr: TSockAddrIn;
  lBlockMode: u_long;
  lError: LongInt;
  lErrorLen: LongInt;
  lHost: string;
  lIp: u_long;
  lSocket: TSocket;
  lTimeVal: TTimeVal;
  lWriteSet: TFDSet;
  lWsaData: TWSAData;
begin
  Result := False;
  lHost := Trim(AHost);
  if lHost = '' then
    Exit;

  if WSAStartup($0202, lWsaData) <> 0 then
    Exit;
  try
    lIp := inet_addr(PChar(AnsiString(lHost)));
    if lIp = INADDR_NONE then
      Exit;

    lSocket := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if lSocket = INVALID_SOCKET then
      Exit;
    try
      FillChar(lAddr, SizeOf(lAddr), 0);
      lAddr.sin_family := AF_INET;
      lAddr.sin_port := htons(APort);
      lAddr.sin_addr.S_addr := lIp;

      lBlockMode := 1;
      if ioctlsocket(lSocket, LongInt(FIONBIO), lBlockMode) <> 0 then
        Exit;

      if WinSock2.connect(lSocket, @lAddr, SizeOf(lAddr)) = 0 then
        Exit(True);
      lError := WSAGetLastError;
      if lError <> WSAEWOULDBLOCK then
        Exit;

      FillChar(lTimeVal, SizeOf(lTimeVal), 0);
      lTimeVal.tv_sec := ATimeoutMs div 1000;
      lTimeVal.tv_usec := (ATimeoutMs mod 1000) * 1000;
      FD_ZERO(lWriteSet);
      FD_SET(lSocket, lWriteSet);
      if WinSock2.select(0, nil, @lWriteSet, nil, @lTimeVal) <= 0 then
        Exit;
      if not FD_ISSET(lSocket, lWriteSet) then
        Exit;

      lError := -1;
      lErrorLen := SizeOf(lError);
      if getsockopt(lSocket, SOL_SOCKET, SO_ERROR, lError, lErrorLen) <> 0 then
        Exit;
      Result := lError = 0;
    finally
      closesocket(lSocket);
    end;
  finally
    WSACleanup;
  end;
end;
{$ELSE}
const
  CWouldBlockError = ESysEINPROGRESS;
var
  lAddr: TInetSockAddr;
  lBlockMode: LongInt;
  lError: LongInt;
  lErrorLen: LongInt;
  lHost: string;
  lHostAddr: in_addr;
  lSocket: cint;
  lTimeVal: TTimeVal;
  lWriteSet: TFDSet;
begin
  Result := False;
  lHost := Trim(AHost);
  if lHost = '' then
    Exit;

  if not TryStrToHostAddr(AnsiString(lHost), lHostAddr) then
    Exit;

  lSocket := fpSocket(AF_INET, SOCK_STREAM, 0);
  if lSocket < 0 then
    Exit;
  try
    FillChar(lAddr, SizeOf(lAddr), 0);
    lAddr.sin_family := AF_INET;
    lAddr.sin_port := ShortHostToNet(APort);
    lAddr.sin_addr.s_addr := HostToNet(lHostAddr.s_addr);

    lBlockMode := 1;
    {$IFDEF UNIX}
    if FpFcntl(lSocket, F_SetFl, FpFcntl(lSocket, F_GetFl, 0) or O_NONBLOCK) <> 0 then
      Exit;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    if ioctlsocket(lSocket, LongInt(FIONBIO), @lBlockMode) <> 0 then
      Exit;
    {$ENDIF}

    if fpConnect(lSocket, @lAddr, SizeOf(lAddr)) = 0 then
      Exit(True);
    lError := SocketError;
    if lError <> CWouldBlockError then
      Exit;

    FillChar(lTimeVal, SizeOf(lTimeVal), 0);
    lTimeVal.tv_sec := ATimeoutMs div 1000;
    lTimeVal.tv_usec := (ATimeoutMs mod 1000) * 1000;
    FillChar(lWriteSet, SizeOf(lWriteSet), 0);
    {$IFDEF UNIX}
    fpFD_ZERO(lWriteSet);
    fpFD_SET(lSocket, lWriteSet);
    if fpSelect(lSocket + 1, nil, @lWriteSet, nil, @lTimeVal) <= 0 then
      Exit;
    if fpFD_ISSET(lSocket, lWriteSet) <> 1 then
      Exit;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    FD_ZERO(lWriteSet);
    FD_SET(lSocket, lWriteSet);
    if select(lSocket + 1, nil, @lWriteSet, nil, @lTimeVal) <= 0 then
      Exit;
    if not FD_ISSET(lSocket, lWriteSet) then
      Exit;
    {$ENDIF}

    lError := -1;
    lErrorLen := SizeOf(lError);
    if fpGetSockOpt(lSocket, SOL_SOCKET, SO_ERROR, @lError, @lErrorLen) <> 0 then
      Exit;
    Result := lError = 0;
  finally
    fpClose(lSocket);
  end;
end;
{$ENDIF}

function RecorderMic140TestConnection(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal): Boolean;
begin
  Result := RecorderMic140TcpProbe(AHost, APort, ATimeoutMs);
end;

type
  TMic140DiscoveryThread = class(TThread)
  private
    fFound: Boolean;
    fHost: string;
    fPort: Word;
    fTimeoutMs: Cardinal;
  protected
    procedure Execute; override;
  public
    constructor Create(const AHost: string; APort: Word; ATimeoutMs: Cardinal);
    property Found: Boolean read fFound;
    property Host: string read fHost;
  end;

constructor TMic140DiscoveryThread.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  Start;
end;

procedure TMic140DiscoveryThread.Execute;
begin
  fFound := RecorderMic140TestConnection(fHost, fPort, fTimeoutMs);
end;

procedure RecorderMic140Discover(AFoundHosts: TStrings;
  const ASubnetPrefix: string; APort: Word; ATimeoutMs: Cardinal);
var
  I: Integer;
  lThreads: TList;
  lThread: TMic140DiscoveryThread;
begin
  if AFoundHosts = nil then
    Exit;
  AFoundHosts.Clear;
  lThreads := TList.Create;
  try
    lThread := TMic140DiscoveryThread.Create(MIC140DefaultHost, APort, ATimeoutMs);
    lThreads.Add(lThread);
    for I := 1 to 254 do
    begin
      if SameText(ASubnetPrefix + IntToStr(I), MIC140DefaultHost) then
        Continue;
      lThread := TMic140DiscoveryThread.Create(ASubnetPrefix + IntToStr(I),
        APort, ATimeoutMs);
      lThreads.Add(lThread);
    end;

    for I := 0 to lThreads.Count - 1 do
    begin
      lThread := TMic140DiscoveryThread(lThreads[I]);
      lThread.WaitFor;
      if lThread.Found and (AFoundHosts.IndexOf(lThread.Host) < 0) then
        AFoundHosts.Add(lThread.Host);
      lThread.Free;
    end;
  finally
    lThreads.Free;
  end;
end;

{ TRecorderMic140Device }

constructor TRecorderMic140Device.Create(const ADeviceId, AHost: string; APort: Word;
  AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal);
begin
  inherited Create;
  if ADeviceId = '' then
    raise ERecorderDeviceError.Create('MIC-140 device id cannot be empty');
  if AHost = '' then
    raise ERecorderDeviceError.Create('MIC-140 host cannot be empty');
  if not (AChannelCount in [1..MIC140MaxChannelCount]) then
    raise ERecorderDeviceError.CreateFmt('MIC-140 channel count is invalid: %d',
      [AChannelCount]);
  if APollFrequencyHz <= 0 then
    APollFrequencyHz := MIC140DefaultPollFrequencyHz;
  APollFrequencyHz := RecorderMic140NormalizeFrequency(APollFrequencyHz);
  if APollFrequencyHz > CMic140LegacyMaxUiReadFrequencyHz then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] Requested frequency %.3f Hz is too high for current direct legacy reader; using %.3f Hz',
      [AHost, APort, APollFrequencyHz, MIC140DefaultPollFrequencyHz]));
    APollFrequencyHz := MIC140DefaultPollFrequencyHz;
  end;

  fDeviceId := ADeviceId;
  fHost := AHost;
  fPort := APort;
  fChannelCount := AChannelCount;
  fPollFrequencyHz := APollFrequencyHz;
  fUpdateTimeMs := AUpdateTimeMs;
  fNodeNumber := MIC140DefaultNodeNumber;
  fState := rdsDisconnected;
  BuildChannels;
end;

destructor TRecorderMic140Device.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

function TRecorderMic140Device.GetDeviceId: string;
begin
  Result := fDeviceId;
end;

function TRecorderMic140Device.GetName: string;
begin
  Result := Format('MIC-140 %s:%d', [fHost, fPort]);
end;

function TRecorderMic140Device.GetState: TRecorderDeviceState;
begin
  Result := fState;
end;

function TRecorderMic140Device.GetChannels: TRecorderDeviceChannelArray;
begin
  Result := Copy(fChannels, 0, Length(fChannels));
end;

procedure TRecorderMic140Device.BuildChannels;
var
  I: Integer;
begin
  SetLength(fChannels, fChannelCount);
  for I := 0 to fChannelCount - 1 do
  begin
    fChannels[I].Name := RecorderMic140ChannelTagName(fNodeNumber, I + 1);
    fChannels[I].Address := Format('%d-%2.2d', [fNodeNumber, I + 1]);
    fChannels[I].UnitName := '';
    fChannels[I].ModuleType := 'MIC-140';
    fChannels[I].PollFrequencyHz := fPollFrequencyHz;
    fChannels[I].Enabled := True;
  end;
end;

function RecorderMic140OutputModeToConfigName(
  AValue: TRecorderMic140OutputMode): string;
begin
  case AValue of
    momTemperatureC: Result := 'degC';
  else
    Result := 'mV';
  end;
end;

function RecorderMic140ConfigNameToOutputMode(
  const AValue: string): TRecorderMic140OutputMode;
begin
  if SameText(Trim(AValue), 'degC') or SameText(Trim(AValue), 'C') or
    SameText(Trim(AValue), 'temperature') then
    Result := momTemperatureC
  else
    Result := momMillivolts;
end;

function RecorderMic140OutputModeUnitName(
  AValue: TRecorderMic140OutputMode): string;
begin
  case AValue of
    momTemperatureC: Result := 'degC';
  else
    Result := 'mV';
  end;
end;

function TRecorderMic140Device.LegacyAllocBuffer(AWordCount: Word; out APage,
  AAddress: Word): Boolean;
begin
  // Mirrors CC81WDInterface::GetInternalMem(): scan FIFO data lives in the
  // low DM buffer area 0x0000..0x07FF.
  APage := 0;
  AAddress := fLegacyMemAddrCur;
  Result := (AWordCount > 0) and
    (LongWord(fLegacyMemAddrCur) + AWordCount - 1 <= CMic140LegacyDmBufferEnd);
  if Result then
    Inc(fLegacyMemAddrCur, AWordCount);
end;

function TRecorderMic140Device.LegacyAllocHeap(AWordCount: Word; out APage,
  AAddress: Word): Boolean;
begin
  // Mirrors CC81WDInterface::GetInternalMemHeap(): BIOS descriptors and
  // channel tables are allocated from DM heap 0x0800..0x2BFF.
  APage := 0;
  AAddress := fLegacyMemHeapAddrCur;
  Result := (AWordCount > 0) and
    (LongWord(fLegacyMemHeapAddrCur) + AWordCount - 1 <= CMic140LegacyDmHeapEnd);
  if Result then
    Inc(fLegacyMemHeapAddrCur, AWordCount);
end;

function TRecorderMic140Device.LegacyCalcFifoReadyWords: Word;
var
  lChannelCount: Integer;
  lMaxFifoAdspWords: Integer;
  lReadyWordsPerChannel: Integer;
  lTargetSamples: Integer;
  lUpdateTimeMs: Cardinal;
begin
  // Mirrors CCMC031EthernetInterface::GetDMAddrBeginBuffer() and
  // Scan::CalcFifoSize(). Ethernet MC031 reserves the lower DM area, so scan
  // FIFO must start at 0x0522. The original first computes ready samples per
  // channel, then multiplies by channel count to get the scan FIFO portion.
  lChannelCount := LegacyInternalScanChannelCount;
  if lChannelCount <= 0 then
    lChannelCount := MIC140DefaultChannelCount;
  lMaxFifoAdspWords := CMic140LegacyDmBufferEnd - CMic140LegacyDmBufferBegin + 1;

  lUpdateTimeMs := fUpdateTimeMs;
  if lUpdateTimeMs = 0 then
    lUpdateTimeMs := 200;

  lTargetSamples := Round(fPollFrequencyHz * lUpdateTimeMs / 1000.0);
  if lTargetSamples < 1 then
    lTargetSamples := 1;

  lReadyWordsPerChannel := (lMaxFifoAdspWords div 2) div lChannelCount;
  if lReadyWordsPerChannel <= 0 then
    lReadyWordsPerChannel := 1;

  if lTargetSamples < lReadyWordsPerChannel then
    lReadyWordsPerChannel := lTargetSamples;

  if lReadyWordsPerChannel > 1024 then
    lReadyWordsPerChannel := 1024;
  Result := Word(lReadyWordsPerChannel * lChannelCount);
end;

function TRecorderMic140Device.LegacyInternalScanChannelCount: Integer;
begin
  Result := fChannelCount + MIC140TemperatureChannelCount;
end;

function TRecorderMic140Device.LegacyTimerScale: Word;
begin
  if SameValue(RecorderMic140NormalizeFrequency(fPollFrequencyHz), 1.0, 0.001) then
    Result := 2
  else
    Result := 1;
end;

function TRecorderMic140Device.LegacyTimerPeriod: Word;
begin
  // MIC-140 uses the 16 MHz MC114 grid. For the safe 48-channel frequencies
  // exposed by the UI, the original scale_period_16000 table has period=640.
  Result := CMic140LegacyTimerPeriod;
end;

function TRecorderMic140Device.LegacyCalcScanDivider: Word;
var
  lFrequencyHz: Double;
begin
  // Mirrors ModuleMIC140_96::GetMainScanDivider() -> ModuleMC114::GetTimerCount().
  // CONFIGSCANMAIN receives scale/period, APPENDSCANMAIN receives this count.
  lFrequencyHz := RecorderMic140NormalizeFrequency(fPollFrequencyHz);
  if SameValue(lFrequencyHz, 1.0, 0.001) then
    Result := 25000
  else if SameValue(lFrequencyHz, 2.0, 0.001) then
    Result := 25000
  else if SameValue(lFrequencyHz, 5.0, 0.001) then
    Result := 10000
  else if SameValue(lFrequencyHz, 10.0, 0.001) then
    Result := 5000
  else if SameValue(lFrequencyHz, 20.0, 0.001) then
    Result := 2500
  else if SameValue(lFrequencyHz, 25.0, 0.001) then
    Result := 2000
  else if SameValue(lFrequencyHz, 50.0, 0.001) then
    Result := 1000
  else
    Result := 500;
end;

function Mic140LegacyMe048Code48(APhysicalChannel: Integer): Word;
var
  lGroup: Integer;
  lLow: Integer;
  lSelectLine: Integer;
begin
  // Equivalent to packing TRegME048 from MIC140_48mod.cpp. The first 24
  // physical channels use selector lines XA2..XA7; the second half uses
  // XA8..XA13 and sets the indicator bit.
  lLow := APhysicalChannel mod 4;
  if APhysicalChannel < 24 then
  begin
    lGroup := APhysicalChannel div 4;
    lSelectLine := 2 + lGroup;
    Result := 0;
  end
  else
  begin
    lGroup := (APhysicalChannel - 24) div 4;
    lSelectLine := 8 + lGroup;
    Result := 1;
  end;

  if (lLow and 1) <> 0 then
    Result := Result or (Word(1) shl 15);
  if (lLow and 2) <> 0 then
    Result := Result or (Word(1) shl 14);
  Result := Result or (Word(1) shl (15 - lSelectLine));
end;

function Mic140LegacyLevel0Code: Word;
begin
  Result := Word(1) shl 1;
end;

function Mic140LegacyTInCode48(ATemperatureIndex: Integer): Word;
begin
  // ModuleMIC140_48::code_chanTIn_48 and TInNum={1,0}. The third internal
  // slot is programmed as level0mV by the original driver, not as an external
  // user temperature channel.
  case ATemperatureIndex of
    0: Result := $C002;
    1: Result := $4002;
  else
    Result := Mic140LegacyLevel0Code;
  end;
end;

function Mic140LegacyTInDesc48(ATemperatureIndex: Integer): Word;
begin
  // TRegMIC140 packed bits: MUX_IN1 is bit 4, MUX_IN2 is bit 5, K1 is bit 8.
  // ModuleMIC140_48 forces the last TIn slot to board MUX 2 while keeping the
  // same hard-amplifier timing bits as ordinary scan channels.
  if ATemperatureIndex = MIC140TemperatureChannelCount - 1 then
    Result := $0120
  else
    Result := $0100;
end;

function Mic140LegacyWordAt(const AWords: TRecorderMic140LegacyWordArray;
  AIndex: Integer): Word;
begin
  if (AIndex >= 0) and (AIndex < Length(AWords)) then
    Result := AWords[AIndex]
  else
    Result := 0;
end;

function Mic140ChannelTemperOffset(AChannelIndex: Integer): Double;
begin
  if (AChannelIndex >= Low(CMic140TemperOffset48)) and
    (AChannelIndex <= High(CMic140TemperOffset48)) then
    Result := CMic140TemperOffset48[AChannelIndex]
  else
    Result := 0.0;
end;

function Mic140DefaultCjcTChannelNumber(AChannelIndex: Integer): Integer;
begin
  if (AChannelIndex >= 0) and (AChannelIndex < CMic140DefaultCjcSplitChannel) then
    Result := 1
  else if (AChannelIndex >= CMic140DefaultCjcSplitChannel) and
    (AChannelIndex < MIC140DefaultChannelCount) then
    Result := 2
  else
    Result := 0;
end;

function Mic140DefaultCjcIndex(AChannelIndex: Integer): Integer;
begin
  Result := Mic140DefaultCjcTChannelNumber(AChannelIndex) - 1;
end;

function Mic140TagHasCalibration(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and (ATag.CalibrationNames <> nil) and
    (ATag.CalibrationNames.Count > 0);
end;

function Mic140TryInvertTagCalibration(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; ATemperatureC: Double; out AMillivolts: Double): Boolean;
var
  I: Integer;
  lHi: Double;
  lLo: Double;
  lMid: Double;
  lMidValue: Double;
  lReverse: Boolean;
begin
  Result := False;
  AMillivolts := 0.0;
  if (ARegistry = nil) or (not Mic140TagHasCalibration(ATag)) then
    Exit;

  lLo := CMic140InverseCalibrationMinMv;
  lHi := CMic140InverseCalibrationMaxMv;
  lReverse := ARegistry.TransformTagValue(ATag, lLo) >
    ARegistry.TransformTagValue(ATag, lHi);

  for I := 0 to CMic140InverseCalibrationIterations - 1 do
  begin
    lMid := (lLo + lHi) * 0.5;
    lMidValue := ARegistry.TransformTagValue(ATag, lMid);
    if (lMidValue < ATemperatureC) xor lReverse then
      lLo := lMid
    else
      lHi := lMid;
  end;
  AMillivolts := (lLo + lHi) * 0.5;
  Result := True;
end;

function Mic140TryBuildCjcCorrectedRawValue(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; AChannelIndex: Integer; ARawMillivolts: Double;
  AColdJunctionC: Double; out ACorrectedRawValue: Double): Boolean;
var
  lColdJunctionMv: Double;
  lJunctionC: Double;
begin
  Result := False;
  ACorrectedRawValue := ARawMillivolts;
  if (ARegistry = nil) or (ATag = nil) or (not Mic140TagHasCalibration(ATag)) then
    Exit;
  if AColdJunctionC <= CMic140CjcNotAvailable * 0.5 then
    Exit;

  lJunctionC := AColdJunctionC + Mic140ChannelTemperOffset(AChannelIndex);
  if not Mic140TryInvertTagCalibration(ARegistry, ATag, lJunctionC,
    lColdJunctionMv) then
    Exit;

  // The generic registry will apply the hardware and thermocouple GХ once
  // after this pre-correction. Applying it here would transform the value twice.
  ACorrectedRawValue := ARawMillivolts + lColdJunctionMv;
  Result := True;
end;

function Mic140TryGetColdJunctionTemperature(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const ABlock: TRecorderDeviceSampleBlock;
  ACjcChannel: Integer; out ATemperatureC: Double): Boolean;
var
  I: Integer;
  lCjcIndex: Integer;
  lSum: Double;
  lCount: Integer;
begin
  Result := False;
  ATemperatureC := CMic140CjcNotAvailable;
  lCjcIndex := ACjcChannel - 1;
  if (ARegistry = nil) or (ATag = nil) or (lCjcIndex < 0) or
    (lCjcIndex >= ABlock.TemperatureCount) or
    (lCjcIndex >= Length(ABlock.TemperatureValues)) then
    Exit;

  // Same as ScanMIC140: a T-channel is converted through the thermocouple
  // curve, then averaged for the received scan block.
  lSum := 0;
  lCount := 0;
  for I := 0 to ABlock.SampleCount - 1 do
    if (lCjcIndex < Length(ABlock.TemperatureValid)) and
      (I < Length(ABlock.TemperatureValid[lCjcIndex])) and
      ABlock.TemperatureValid[lCjcIndex][I] and
      (I < Length(ABlock.TemperatureValues[lCjcIndex])) then
    begin
      lSum := lSum + ARegistry.TransformTagValue(ATag,
        ABlock.TemperatureValues[lCjcIndex][I]);
      Inc(lCount);
    end;
  if lCount <= 0 then
    Exit;
  ATemperatureC := lSum / lCount;
  Result := True;
end;

function RecorderMic140CalibrRootDir: string;
begin
  Result := RecorderMeraCalibrRootDir;
end;

function RecorderMic140RangeCalibrDirName(ARangeIndex: Integer): string;
begin
  if (ARangeIndex >= 0) and (ARangeIndex < CMic140RangeCount) then
    Result := CMic140RangeCalibrDirNames[ARangeIndex]
  else
    Result := CMic140RangeCalibrDirNames[CMic140Range100mV];
end;

function RecorderMic140HardwareCalibrCsvPath(ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer): string;
var
  lRangeDir: string;
begin
  if (ADeviceSerial <= 0) or (AChannelNumber <= 0) then
    Exit('');
  lRangeDir := RecorderMic140RangeCalibrDirName(ARangeIndex);
  Result := IncludeTrailingPathDelimiter(RecorderMic140CalibrRootDir) +
    CMic140HardwareCalibrSubDir + Format('sn%4.4d', [ADeviceSerial]) +
    PathDelim + lRangeDir + PathDelim + Format('%2.2d.csv', [AChannelNumber]);
end;

function RecorderMic140ParseCsvNumber(const AText: string; out AValue: Double): Boolean;
var
  lFS: TFormatSettings;
  lText: string;
begin
  lText := Trim(StringReplace(AText, ',', '.', [rfReplaceAll]));
  lFS := DefaultFormatSettings;
  lFS.DecimalSeparator := '.';
  Result := TryStrToFloat(lText, AValue, lFS);
end;

function RecorderMic140LoadCalibrationFromCsv(const AFileName: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  I: Integer;
  lLines: TStringList;
  lParts: TStringList;
  lX: Double;
  lY: Double;
begin
  Result := False;
  if (ACalibration = nil) or (Trim(AFileName) = '') or (not FileExists(AFileName)) then
    Exit;

  lLines := TStringList.Create;
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ',';
    lLines.LoadFromFile(AFileName);
    ACalibration.ClearPoints;
    for I := 0 to lLines.Count - 1 do
    begin
      if Trim(lLines[I]) = '' then
        Continue;
      lParts.DelimitedText := lLines[I];
      if lParts.Count < 2 then
        Continue;
      if not RecorderMic140ParseCsvNumber(lParts[0], lX) then
        Continue;
      if not RecorderMic140ParseCsvNumber(lParts[1], lY) then
        Continue;
      ACalibration.AddPoint(lX, lY);
    end;
    Result := ACalibration.PointCount > 0;
  finally
    lParts.Free;
    lLines.Free;
  end;
end;

function RecorderMic140MakeHardwareCalibrationName(ADeviceSerial, ARangeIndex,
  AChannelNumber: Integer): string;
begin
  Result := Format('MIC140 sn%4.4d %s ch%2.2d',
    [ADeviceSerial, RecorderMic140RangeCalibrDirName(ARangeIndex), AChannelNumber]);
end;

function RecorderMic140UpsertHardwareCalibration(ARegistry: TRecorderTagRegistry;
  const AName: string; ASource: TRecorderCalibration): TRecorderCalibration;
var
  lExisting: TRecorderCalibration;
begin
  Result := nil;
  if (ARegistry = nil) or (ASource = nil) or (Trim(AName) = '') then
    Exit;
  lExisting := ARegistry.FindCalibrationByName(AName);
  if lExisting = nil then
  begin
    Result := TRecorderCalibration.Create(rckPiecewiseLinear);
    Result.Assign(ASource);
    Result.Name := AName;
    ARegistry.Calibrations.Add(Result);
    Exit;
  end;
  lExisting.Assign(ASource);
  lExisting.Name := AName;
  Result := lExisting;
end;

function RecorderMic140QueryDeviceSerial(const AHost: string; APort: Word;
  out ADeviceSerial: Integer): Boolean;
var
  lClient: TRecorderMic140LegacyClient;
  lErrorMessage: string;
  lFirmware: TRecorderMic140LegacyFirmware;
begin
  Result := False;
  ADeviceSerial := 0;
  lClient := TRecorderMic140LegacyClient.Create(AHost, APort, 5000);
  try
    lClient.Connect;
    if lClient.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ADeviceSerial := RecorderMic140DeviceSerialFromFirmware(lFirmware);
      Result := ADeviceSerial > 0;
    end;
  finally
    lClient.Free;
  end;
end;

function RecorderMic140QueryDeviceInfo(const AHost: string; APort: Word;
  out ADeviceSerial: Integer; out AVersionText: string;
  out ADevSubRev: Integer): Boolean;
var
  lClient: TRecorderMic140LegacyClient;
  lErrorMessage: string;
  lFirmware: TRecorderMic140LegacyFirmware;
begin
  Result := False;
  ADeviceSerial := 0;
  AVersionText := '';
  ADevSubRev := 0;
  lClient := TRecorderMic140LegacyClient.Create(AHost, APort, 5000);
  try
    lClient.Connect;
    if lClient.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ADeviceSerial := RecorderMic140DeviceSerialFromFirmware(lFirmware);
      AVersionText := RecorderMic140FirmwareVersionText(lFirmware);
      ADevSubRev := RecorderMic140DevSubRevFromFirmware(lFirmware);
      Result := (ADeviceSerial > 0) or (AVersionText <> '');
    end;
  finally
    lClient.Free;
  end;
end;

function Mic140TInDisplayNumber(ATInListIndex, ADevSubRev: Integer): Integer;
begin
  if (ATInListIndex < 0) or (ATInListIndex > High(CMic140TInNum)) then
    Exit(0);
  if ADevSubRev = CMic140Mic140SubRev1 then
    Result := CMic140TInNumSubRev1[ATInListIndex] + 1
  else
    Result := CMic140TInNum[ATInListIndex] + 1;
end;

function RecorderMic140DefaultCjcChannel(AChannelIndex: Integer;
  ADevSubRev: Integer): Integer;
begin
  Result := Mic140DefaultCjcTChannelNumber(AChannelIndex);
end;

function RecorderMic140FormatAdcRangeMv(ARangeIndex: Integer): string;
const
  CMic140RangeMinMax: array[0..CMic140RangeCount - 1] of record MinV, MaxV: Double end =
    ((MinV: -0.02; MaxV: 0.08), (MinV: -0.01; MaxV: 0.04), (MinV: -0.005; MaxV: 0.02));
var
  lIdx: Integer;
begin
  lIdx := ARangeIndex;
  if (lIdx < 0) or (lIdx >= CMic140RangeCount) then
    lIdx := CMic140Range100mV;
  Result := Format('%.1f...%.1f', [
    CMic140RangeMinMax[lIdx].MinV * 1000.0,
    CMic140RangeMinMax[lIdx].MaxV * 1000.0]);
end;

function RecorderMic140FormatAdcRangeGrad(ARangeIndex: Integer): string;
begin
  Result := RecorderMic140FormatAdcRangeMv(ARangeIndex);
end;

function RecorderMic140RangeComboLabel(ARangeIndex: Integer): string;
const
  CLabels: array[0..CMic140RangeCount - 1] of string =
    ('-20..80mV', '-10..40mV', '-5..20mV');
begin
  if (ARangeIndex >= 0) and (ARangeIndex < CMic140RangeCount) then
    Result := CLabels[ARangeIndex]
  else
    Result := CLabels[CMic140Range100mV];
end;

procedure RecorderMic140InitChannelSettings(out ASettings: TRecorderMic140ChannelSettings;
  AChannelIndex, ADevSubRev: Integer);
begin
  ASettings.RangeIndex := CMic140Range100mV;
  ASettings.DefaultCjc := True;
  ASettings.CjcChannel := RecorderMic140DefaultCjcChannel(AChannelIndex, ADevSubRev);
  ASettings.ThermocoupleScalePath := '';
  ASettings.ThermocoupleScaleName := '';
end;

function RecorderMic140ChannelUsesTemperature(
  const ASettings: TRecorderMic140ChannelSettings): Boolean;
begin
  Result := Trim(ASettings.ThermocoupleScaleName) <> '';
end;

function RecorderMic140ChannelCjcNumber(const ASettings: TRecorderMic140ChannelSettings;
  AChannelIndex, ADevSubRev: Integer): Integer;
begin
  if ASettings.DefaultCjc then
    Result := RecorderMic140DefaultCjcChannel(AChannelIndex, ADevSubRev)
  else
    Result := ASettings.CjcChannel;
end;

function RecorderMic140ChannelGradRangeText(
  const ASettings: TRecorderMic140ChannelSettings): string;
const
  CRangeMinMax: array[0..CMic140RangeCount - 1] of record MinV, MaxV: Double end =
    ((MinV: -0.02; MaxV: 0.08), (MinV: -0.01; MaxV: 0.04), (MinV: -0.005; MaxV: 0.02));
var
  lCalibration: TRecorderCalibration;
  lDstMax: Double;
  lDstMin: Double;
  lIdx: Integer;
  lMaxC: Double;
  lMinC: Double;
  lMaxMv: Double;
  lMinMv: Double;
begin
  if not RecorderMic140ChannelUsesTemperature(ASettings) then
    Exit('');
  lIdx := ASettings.RangeIndex;
  if (lIdx < 0) or (lIdx >= CMic140RangeCount) then
    lIdx := CMic140Range100mV;
  lMinMv := CRangeMinMax[lIdx].MinV * 1000.0;
  lMaxMv := CRangeMinMax[lIdx].MaxV * 1000.0;
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderSdbLoadScaleCalibration(ASettings.ThermocoupleScalePath,
      lCalibration) then
      Exit('');
    lMinC := lCalibration.Transform(lMinMv);
    lMaxC := lCalibration.Transform(lMaxMv);
    if RecorderMeraThermocoupleDstRange(ASettings.ThermocoupleScalePath, lDstMin, lDstMax) then
    begin
      if lMinC < lDstMin then
        lMinC := lDstMin;
      if lMinC > lDstMax then
        lMinC := lDstMax;
      if lMaxC < lDstMin then
        lMaxC := lDstMin;
      if lMaxC > lDstMax then
        lMaxC := lDstMax;
    end;
    Result := Format('%.1f...%.1f', [Min(lMinC, lMaxC), Max(lMinC, lMaxC)]);
  finally
    lCalibration.Free;
  end;
end;

procedure RecorderMic140RestoreChannelSettingsFromTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var ASettings: TRecorderMic140ChannelSettings);
var
  J: Integer;
  lCal: TRecorderCalibration;
  lCalName: string;
begin
  if ATag = nil then
    Exit;
  if (ATag.MeasRangeIndex >= 0) and (ATag.MeasRangeIndex < CMic140RangeCount) then
    ASettings.RangeIndex := ATag.MeasRangeIndex;
  ASettings.DefaultCjc := ATag.Mic140CjcDefault;
  if (ATag.Mic140CjcChannel >= 1) and
    (ATag.Mic140CjcChannel <= MIC140TemperatureChannelCount) then
    ASettings.CjcChannel := ATag.Mic140CjcChannel;
  if ATag.CalibrationNames = nil then
    Exit;
  for J := 0 to ATag.CalibrationNames.Count - 1 do
  begin
    lCalName := Trim(ATag.CalibrationNames[J]);
    if Pos('TC ', lCalName) <> 1 then
      Continue;
    ASettings.ThermocoupleScaleName := Trim(Copy(lCalName, 4, MaxInt));
    if ARegistry <> nil then
    begin
      lCal := ARegistry.FindCalibrationByName(lCalName);
      if (lCal <> nil) and (Trim(lCal.Description) <> '') then
        ASettings.ThermocoupleScalePath := lCal.Description
      else if ASettings.ThermocoupleScaleName <> '' then
        ASettings.ThermocoupleScalePath :=
          RecorderMeraThermocoupleRelativePath(ASettings.ThermocoupleScaleName);
    end;
    Break;
  end;
end;

function RecorderMic140EnsureThermocoupleCalibration(
  ARegistry: TRecorderTagRegistry;
  const ASettings: TRecorderMic140ChannelSettings): string;
var
  lCalibration: TRecorderCalibration;
  lName: string;
begin
  Result := '';
  if (ARegistry = nil) or (not RecorderMic140ChannelUsesTemperature(ASettings)) then
    Exit;
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderSdbLoadScaleCalibration(ASettings.ThermocoupleScalePath,
      lCalibration) then
      Exit;
    lCalibration.Extrapolation := True;
    lCalibration.UnitIn := 'mV';
    lCalibration.UnitOut := 'degC';
    lName := 'TC ' + ASettings.ThermocoupleScaleName;
    lCalibration.Name := lName;
    lCalibration.Description := ASettings.ThermocoupleScalePath;
    if RecorderMic140UpsertHardwareCalibration(ARegistry, lName, lCalibration) <> nil then
      Result := lName;
  finally
    lCalibration.Free;
  end;
end;

function RecorderMic140ResolveDeviceSerialForTag(const ATag: TRecorderTag;
  ADeviceSerial: Integer): Integer;
var
  lHost: string;
  lPort: Word;
  lSerial: Integer;
begin
  if ADeviceSerial > 0 then
    Exit(ADeviceSerial);
  if (ATag <> nil) and (ATag.Mic140DeviceSerial > 0) then
    Exit(ATag.Mic140DeviceSerial);
  if (ATag <> nil) and TryParseRecorderMic140SourceId(ATag.SourceId, lHost, lPort) and
    RecorderMic140QueryDeviceSerial(lHost, lPort, lSerial) then
    Exit(lSerial);
  Result := 0;
end;

function RecorderMic140LoadHardwareCalibrationForTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  ADeviceSerial: Integer): Boolean;
var
  lCalibration: TRecorderCalibration;
  lChannelNumber: Integer;
  lCsvPath: string;
  lName: string;
  lRangeIndex: Integer;
  lSerial: Integer;
begin
  Result := False;
  if (ARegistry = nil) or (ATag = nil) then
    Exit;
  if Pos(CMic140SourcePrefix, ATag.SourceId) <> 1 then
    Exit;
  if not ParseMic140ChannelNumber(ATag.Address, lChannelNumber) then
    Exit;

  lSerial := RecorderMic140ResolveDeviceSerialForTag(ATag, ADeviceSerial);
  if lSerial <= 0 then
    Exit;

  lRangeIndex := ATag.MeasRangeIndex;
  if lRangeIndex >= CMic140RangeCount then
    lRangeIndex := CMic140Range100mV;

  lCsvPath := RecorderMic140HardwareCalibrCsvPath(lSerial, lRangeIndex,
    lChannelNumber);
  if lCsvPath = '' then
    Exit;

  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderMic140LoadCalibrationFromCsv(lCsvPath, lCalibration) then
    begin
      Mic140LogWarning(Format('[MIC-140] hardware calibration not found: %s',
        [lCsvPath]));
      Exit;
    end;
    lCalibration.Extrapolation := True;
    lName := RecorderMic140MakeHardwareCalibrationName(lSerial, lRangeIndex,
      lChannelNumber);
    if RecorderMic140UpsertHardwareCalibration(ARegistry, lName, lCalibration) = nil then
      Exit;
    ATag.Mic140DeviceSerial := lSerial;
    ATag.HardwareCalibrationName := lName;
    ATag.HardwareCalibrationEnabled := True;
    Result := True;
    Mic140LogWarning(Format('[MIC-140] loaded hardware calibration for tag %s from %s',
      [ATag.Name, lCsvPath]));
  finally
    lCalibration.Free;
  end;
end;

procedure RecorderMic140ApplyHardwareCalibrations(
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  ADeviceSerial: Integer);
var
  I: Integer;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or (Trim(ASourceId) = '') then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) and
      (Pos('diagnostics.', LowerCase(lTag.Address)) <> 1) then
      RecorderMic140LoadHardwareCalibrationForTag(ARegistry, lTag, ADeviceSerial);
  end;
end;

type
  TMic140FltPoint = packed record
    X: Single;
    Y: Single;
  end;

  TMic140TareType1 = packed record
    Date: Word;
    Time: Word;
    OperName: array[0..15] of Byte;
    TareType: Byte;
    Range: Byte;
    TableNodes: Byte;
    TablePoints: array[0..CMic140TareTableMaxPoints - 1] of TMic140FltPoint;
  end;

  TMic140TareType2 = packed record
    Date: Word;
    Time: Word;
    OperName: array[0..15] of Byte;
    TareType: Byte;
    Range: Byte;
    TableNodes: Byte;
    TablePoints: array[0..152] of TMic140FltPoint;
  end;

  TMic140FlashDirEntry = packed record
    Name: array[0..CMic140FlashNameLength - 1] of AnsiChar;
    Size: LongWord;
    FileTime: LongWord;
    Addr: LongWord;
  end;

function Mic140FlashDirEntryName(const AEntry: TMic140FlashDirEntry): string;
var
  I: Integer;
begin
  SetLength(Result, 0);
  for I := 0 to CMic140FlashNameLength - 1 do
  begin
    if (AEntry.Name[I] = #0) or (AEntry.Name[I] = AnsiChar(#$FF)) then
      Break;
    Result := Result + AEntry.Name[I];
  end;
  Result := Trim(Result);
end;

function Mic140FlashDirEntryIsEmpty(const AEntry: TMic140FlashDirEntry): Boolean;
var
  I: Integer;
  lEmpty: Boolean;
begin
  lEmpty := True;
  for I := 0 to CMic140FlashNameLength - 1 do
  begin
    if (AEntry.Name[I] <> #0) and (AEntry.Name[I] <> AnsiChar(#$FF)) then
      Exit(False);
  end;
  Result := lEmpty;
end;

function Mic140ParseFlashDirEntries(const AData: array of Byte;
  out AEntries: array of TMic140FlashDirEntry): Integer;
var
  I, lOffset: Integer;
begin
  Result := 0;
  for I := 0 to CMic140FlashMaxDirEntries - 1 do
  begin
    lOffset := I * SizeOf(TMic140FlashDirEntry);
    if lOffset + SizeOf(TMic140FlashDirEntry) > Length(AData) then
      Break;
    Move(AData[lOffset], AEntries[Result], SizeOf(TMic140FlashDirEntry));
    if Mic140FlashDirEntryIsEmpty(AEntries[Result]) then
      Break;
    Inc(Result);
  end;
end;

function Mic140Mic118TarFileSize(AMaxAinChannels, AMaxTinChannels: Integer): LongWord;
begin
  Result := LongWord(AMaxAinChannels) * SizeOf(TMic140TareType1) * CMic140RangeCountMic140 +
    LongWord(AMaxTinChannels) * SizeOf(TMic140TareType2) * CMic140RangeCountMic140;
end;

function Mic140ResolveMaxAinChannels(AChannelCountHint: Integer): Integer;
begin
  if (AChannelCountHint > 0) and (AChannelCountHint <= CMic140MaxAinChannels48) then
    Result := CMic140MaxAinChannels48
  else
    Result := CMic140MaxAinChannels96;
end;

function Mic140FindMi118TarBaseAddress(AClient: TRecorderMic140LegacyClient;
  AMaxAinChannels, AMaxTinChannels: Integer; out ABaseAddress: LongWord;
  out AErrorMessage: string; const ALogPrefix: string = ''): Boolean;
var
  lAddress: LongWord;
  lDirBytes: array of Byte;
  lEntries: array of TMic140FlashDirEntry;
  lFileCount: Integer;
  lFoundIndex: Integer;
  lI: Integer;
  lName: string;
  lPrefix: string;
  lSize: LongWord;
  lTareSize: LongWord;
begin
  Result := False;
  ABaseAddress := 0;
  AErrorMessage := '';
  lPrefix := ALogPrefix;
  if lPrefix <> '' then
    lPrefix := lPrefix + ' ';
  SetLength(lDirBytes, CMic140FlashDirSize);
  if not AClient.ReadFlashStorage(CMic140FlashDirOffset, lDirBytes[0],
    CMic140FlashDirSize, AErrorMessage) then
  begin
    Mic140LogFlash(lPrefix + 'flash dir read failed at offset ' +
      IntToStr(CMic140FlashDirOffset) + ': ' + AErrorMessage);
    Exit;
  end;

  SetLength(lEntries, CMic140FlashMaxDirEntries);
  lFileCount := Mic140ParseFlashDirEntries(lDirBytes, lEntries);
  Mic140LogFlash(lPrefix + Format('flash dir entries=%d tareRecSize=%d expectedTareFileSize=%d',
    [lFileCount, SizeOf(TMic140TareType1),
    Mic140Mic118TarFileSize(AMaxAinChannels, AMaxTinChannels)]));
  for lI := 0 to lFileCount - 1 do
  begin
    lName := Mic140FlashDirEntryName(lEntries[lI]);
    Mic140LogFlash(lPrefix + Format('flash dir[%d] name=%s addr=0x%.8x size=%u',
      [lI, lName, lEntries[lI].Addr, lEntries[lI].Size]));
  end;

  if lFileCount = 0 then
  begin
    AErrorMessage := 'Flash disk directory is empty';
    Mic140LogFlash(lPrefix + AErrorMessage);
    Exit;
  end;

  lTareSize := Mic140Mic118TarFileSize(AMaxAinChannels, AMaxTinChannels);
  lFoundIndex := -1;
  for lI := 0 to lFileCount - 1 do
  begin
    if SameText(Mic140FlashDirEntryName(lEntries[lI]), CMic140Mi118TarFileName) then
    begin
      lFoundIndex := lI;
      lAddress := lEntries[lI].Addr;
      lSize := lEntries[lI].Size;
      Break;
    end;
  end;

  if lFoundIndex >= 0 then
    Mic140LogFlash(lPrefix + Format('mi118tar found at index %d addr=0x%.8x size=%u expected=%u',
      [lFoundIndex, lAddress, lSize, lTareSize]))
  else
    Mic140LogFlash(lPrefix + 'mi118tar not found in flash dir, using fallback placement');

  if (lFoundIndex < 0) or (lSize <> lTareSize) then
  begin
    if lFoundIndex < 0 then
    begin
      lAddress := lEntries[lFileCount - 1].Addr;
      lSize := lEntries[lFileCount - 1].Size;
      Inc(lAddress, lSize);
    end;
    Inc(lAddress, lTareSize);
    Mic140LogFlash(lPrefix + Format('mi118tar fallback base=0x%.8x', [lAddress]));
  end;

  if lAddress > CMic140FlashStorageBytes then
  begin
    AErrorMessage := 'Calibration storage is outside flash memory';
    Mic140LogFlash(lPrefix + Format('%s (base=0x%.8x diskSize=%d)',
      [AErrorMessage, lAddress, CMic140FlashStorageBytes]));
    Exit;
  end;

  ABaseAddress := lAddress;
  Mic140LogFlash(lPrefix + Format('mi118tar base=0x%.8x', [ABaseAddress]));
  Result := True;
end;

function Mic140CalcBaseCalibrAddress(AMi118TarBase, AChanIndex, ARangeIndex,
  AMaxAinChannels, AMaxTinChannels: Integer): LongWord;
begin
  if AChanIndex < AMaxAinChannels then
    Result := AMi118TarBase +
      LongWord(AChanIndex) * SizeOf(TMic140TareType1) * CMic140RangeCountMic140 +
      LongWord(ARangeIndex) * SizeOf(TMic140TareType1)
  else
    Result := AMi118TarBase +
      LongWord(AMaxAinChannels) * SizeOf(TMic140TareType1) * CMic140RangeCountMic140 +
      LongWord(AChanIndex - AMaxAinChannels) * SizeOf(TMic140TareType2) *
      CMic140RangeCountMic140 +
      LongWord(ARangeIndex) * SizeOf(TMic140TareType2);
end;

function Mic140TareTypeRangeIsEmpty(const ATare: TMic140TareType1): Boolean;
var
  lValue: Word;
begin
  lValue := Word(ATare.TareType) or (Word(ATare.Range) shl 8);
  Result := (lValue = 0) or (lValue = $FFFF);
end;

function Mic140TareToCalibration(const ATare: TMic140TareType1;
  ACalibration: TRecorderCalibration): Boolean;
var
  lI: Integer;
begin
  Result := False;
  if ACalibration = nil then
    Exit;
  if ATare.TareType <> CMic140TareTypeTable then
    Exit;
  if (ATare.TableNodes = 0) or (ATare.TableNodes > CMic140TareTableMaxPoints) then
    Exit;

  ACalibration.ClearPoints;
  ACalibration.Kind := rckPiecewiseLinear;
  ACalibration.Extrapolation := True;
  for lI := 0 to ATare.TableNodes - 1 do
    ACalibration.AddPoint(ATare.TablePoints[lI].X, ATare.TablePoints[lI].Y);
  Result := ACalibration.PointCount > 0;
end;

function RecorderMic140SaveCalibrationToCsv(const AFileName: string;
  ACalibration: TRecorderCalibration): Boolean;
var
  lFS: TFormatSettings;
  lI: Integer;
  lLines: TStringList;
begin
  Result := False;
  if (ACalibration = nil) or (Trim(AFileName) = '') then
    Exit;
  ForceDirectories(ExtractFileDir(AFileName));
  lLines := TStringList.Create;
  try
    lFS := DefaultFormatSettings;
    lFS.DecimalSeparator := '.';
    for lI := 0 to ACalibration.PointCount - 1 do
      lLines.Add(Format('%.9g,%.9g',
        [ACalibration.PointAt(lI).X, ACalibration.PointAt(lI).Y], lFS));
    lLines.SaveToFile(AFileName);
    Result := lLines.Count > 0;
  finally
    lLines.Free;
  end;
end;

function Mic140HardwareTareIsUsable(const ATare: TMic140TareType1): Boolean;
begin
  Result := not Mic140TareTypeRangeIsEmpty(ATare) and
    (ATare.TareType = CMic140TareTypeTable) and
    (ATare.TableNodes > 0) and
    (ATare.TableNodes <= CMic140TareTableMaxPoints);
end;

function Mic140DescribeTareRecord(const ATare: TMic140TareType1): string;
begin
  Result := Format('date=%u time=%u type=%u range=%u nodes=%u recSize=%d hex=%s',
    [ATare.Date, ATare.Time, ATare.TareType, ATare.Range, ATare.TableNodes,
    SizeOf(ATare), Mic140BytesToHex(ATare, SizeOf(ATare), 24)]);
end;

function Mic140DescribeTareRejectReason(const ATare: TMic140TareType1): string;
begin
  if Mic140TareTypeRangeIsEmpty(ATare) then
    Exit('empty type/range word');
  if ATare.TareType <> CMic140TareTypeTable then
    Exit(Format('unsupported tare type %u (expected table=%u)',
      [ATare.TareType, CMic140TareTypeTable]));
  if ATare.TableNodes = 0 then
    Exit('table node count is zero');
  if ATare.TableNodes > CMic140TareTableMaxPoints then
    Exit(Format('table node count %u exceeds max %u',
      [ATare.TableNodes, CMic140TareTableMaxPoints]));
  Result := 'unknown reject reason';
end;

function Mic140ResolveMaxAinChannelsFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Integer;
begin
  if (AFirmware.DevType > 0) and (AFirmware.DevType <= CMic140MaxAinChannels48) then
    Result := CMic140MaxAinChannels48
  else
    Result := CMic140MaxAinChannels96;
end;

function Mic140TryReadHardwareTareFromFlash(AClient: TRecorderMic140LegacyClient;
  AMi118Base, AChanIndex, AMaxAinChannels, AMaxTinChannels,
  APreferredRangeIndex: Integer; out ATare: TMic140TareType1; out ARangeIndex: Integer;
  out AErrorMessage: string; const ALogPrefix: string = ''): Boolean;
var
  lAddress: LongWord;
  lCandidate: TMic140TareType1;
  lFoundAny: Boolean;
  lPrefix: string;
  lTryRange: Integer;
begin
  Result := False;
  ARangeIndex := -1;
  AErrorMessage := '';
  FillChar(ATare, SizeOf(ATare), 0);
  lFoundAny := False;
  lPrefix := ALogPrefix;
  if lPrefix <> '' then
    lPrefix := lPrefix + ' ';

  Mic140LogFlash(lPrefix + Format('scan tare slots: chanIndex=%d preferredRange=%d ain=%d tin=%d base=0x%.8x',
    [AChanIndex, APreferredRangeIndex, AMaxAinChannels, AMaxTinChannels, AMi118Base]));

  for lTryRange := 0 to CMic140RangeCountMic140 - 1 do
  begin
    lAddress := Mic140CalcBaseCalibrAddress(AMi118Base, AChanIndex, lTryRange,
      AMaxAinChannels, AMaxTinChannels);
    FillChar(lCandidate, SizeOf(lCandidate), 0);
    if not AClient.ReadFlashStorage(lAddress, lCandidate, SizeOf(lCandidate),
      AErrorMessage) then
    begin
      Mic140LogFlash(lPrefix + Format('range slot %d read failed at 0x%.8x: %s',
        [lTryRange, lAddress, AErrorMessage]));
      Exit;
    end;

    Mic140LogFlash(lPrefix + Format('range slot %d addr=0x%.8x %s',
      [lTryRange, lAddress, Mic140DescribeTareRecord(lCandidate)]));

    if not Mic140HardwareTareIsUsable(lCandidate) then
    begin
      Mic140LogFlash(lPrefix + Format('range slot %d rejected: %s',
        [lTryRange, Mic140DescribeTareRejectReason(lCandidate)]));
      Continue;
    end;

    ATare := lCandidate;
    if lCandidate.Range < CMic140RangeCountMic140 then
      ARangeIndex := lCandidate.Range
    else
      ARangeIndex := lTryRange;
    lFoundAny := True;

    if (APreferredRangeIndex >= 0) and (APreferredRangeIndex < CMic140RangeCountMic140) and
      ((lTryRange = APreferredRangeIndex) or (lCandidate.Range = Byte(APreferredRangeIndex))) then
    begin
      Mic140LogFlash(lPrefix + Format('selected range slot %d (preferred match)', [lTryRange]));
      Exit(True);
    end;
    if lCandidate.Range = Byte(lTryRange) then
    begin
      Mic140LogFlash(lPrefix + Format('selected range slot %d (range field match)', [lTryRange]));
      Exit(True);
    end;
  end;

  if lFoundAny then
  begin
    Mic140LogFlash(lPrefix + Format('selected first usable tare with rangeIndex=%d', [ARangeIndex]));
    Exit(True);
  end;

  AErrorMessage := 'Calibration was not found in device flash memory';
  Mic140LogFlash(lPrefix + AErrorMessage);
end;

function RecorderMic140DownloadHardwareCalibrationFromDevice(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  out AErrorMessage: string): Boolean;
var
  lCalibration: TRecorderCalibration;
  lCandidateAinCounts: array[0..1] of Integer;
  lChanIndex: Integer;
  lChannelNumber: Integer;
  lClient: TRecorderMic140LegacyClient;
  lCsvPath: string;
  lFirmware: TRecorderMic140LegacyFirmware;
  lHost: string;
  lLayoutIndex: Integer;
  lLogPrefix: string;
  lMaxAinChannels: Integer;
  lMi118Base: LongWord;
  lName: string;
  lPort: Word;
  lRangeIndex: Integer;
  lSerial: Integer;
  lStopError: string;
  lTare: TMic140TareType1;
  lTryError: string;
begin
  Result := False;
  AErrorMessage := '';
  lLogPrefix := Format('[MIC-140 flash:%s]', [IfThen(ATag <> nil, ATag.Name, '?')]);
  if (ARegistry = nil) or (ATag = nil) then
  begin
    AErrorMessage := 'Tag registry is not available';
    Exit;
  end;
  if Pos(CMic140SourcePrefix, ATag.SourceId) <> 1 then
  begin
    AErrorMessage := 'Tag is not linked to MIC-140';
    Exit;
  end;
  if Pos('-t', LowerCase(ATag.Address)) > 0 then
  begin
    AErrorMessage := 'Temperature channel flash export is not supported yet';
    Exit;
  end;
  if not ParseMic140ChannelNumber(ATag.Address, lChannelNumber) then
  begin
    AErrorMessage := 'Invalid MIC-140 channel address';
    Exit;
  end;
  if not TryParseRecorderMic140SourceId(ATag.SourceId, lHost, lPort) then
  begin
    AErrorMessage := 'Invalid MIC-140 source id';
    Exit;
  end;

  lRangeIndex := ATag.MeasRangeIndex;
  if lRangeIndex >= CMic140RangeCount then
    lRangeIndex := CMic140Range100mV;

  lChanIndex := lChannelNumber - 1;
  if lChanIndex < 0 then
  begin
    AErrorMessage := 'Invalid MIC-140 channel number';
    Exit;
  end;

  Mic140LogFlash(lLogPrefix + Format('start download host=%s port=%d address=%s chanIndex=%d tagRange=%d log=%s',
    [lHost, lPort, ATag.Address, lChanIndex, lRangeIndex, Mic140FlashLogFilePath()]));

  FillChar(lTare, SizeOf(lTare), 0);
  lClient := TRecorderMic140LegacyClient.Create(lHost, lPort, 10000);
  try
    lClient.Connect;
    if not lClient.ReadFirmware(lFirmware, AErrorMessage) then
    begin
      Mic140LogFlash(lLogPrefix + 'ReadFirmware failed: ' + AErrorMessage);
      Exit;
    end;

    Mic140LogFlash(lLogPrefix + Format('firmware sig=%u mdp=%u devType=%u devRev=%u devSerNo=%u ccType=%u ccSerNo=%u bios=%u.%u',
      [lFirmware.Signature, lFirmware.MdpType, lFirmware.DevType, lFirmware.DevRevNo, lFirmware.DevSerNo,
      lFirmware.CCType, lFirmware.CCSerNo, lFirmware.BiosFunction, lFirmware.BiosVersion]));

    if not lClient.StopScan(lStopError) then
      Mic140LogFlash(lLogPrefix + 'StopScan before flash read failed: ' + lStopError)
    else
      Mic140LogFlash(lLogPrefix + 'StopScan before flash read: ok');
    lClient.ClearBufferedPackets;

    lSerial := RecorderMic140DeviceSerialFromFirmware(lFirmware);
    Mic140LogFlash(lLogPrefix + Format(
      'using device serial=%d from CMD_REPLY (DevSerNo=%u CCType=%u CCSerNo=%u tag address=%s)',
      [lSerial, lFirmware.DevSerNo, lFirmware.CCType, lFirmware.CCSerNo, ATag.Address]));
    if lSerial <= 0 then
    begin
      AErrorMessage := 'Device serial number is unknown';
      Mic140LogFlash(lLogPrefix + AErrorMessage);
      Exit;
    end;

    lCandidateAinCounts[0] := CMic140MaxAinChannels48;
    lCandidateAinCounts[1] := CMic140MaxAinChannels96;
    if Mic140ResolveMaxAinChannelsFromFirmware(lFirmware) = CMic140MaxAinChannels96 then
    begin
      lCandidateAinCounts[0] := CMic140MaxAinChannels96;
      lCandidateAinCounts[1] := CMic140MaxAinChannels48;
    end;

    for lLayoutIndex := 0 to High(lCandidateAinCounts) do
    begin
      lMaxAinChannels := lCandidateAinCounts[lLayoutIndex];
      Mic140LogFlash(lLogPrefix + Format('try layout #%d maxAin=%d maxTin=%d',
        [lLayoutIndex, lMaxAinChannels, CMic140MaxTinChannels96]));
      if not Mic140FindMi118TarBaseAddress(lClient, lMaxAinChannels,
        CMic140MaxTinChannels96, lMi118Base, lTryError,
        lLogPrefix + Format('layout%d', [lLayoutIndex])) then
      begin
        AErrorMessage := lTryError;
        Continue;
      end;

      if Mic140TryReadHardwareTareFromFlash(lClient, lMi118Base, lChanIndex,
        lMaxAinChannels, CMic140MaxTinChannels96, lRangeIndex, lTare, lRangeIndex,
        lTryError, lLogPrefix + Format('layout%d', [lLayoutIndex])) then
        Break;

      AErrorMessage := lTryError;
    end;

    if not Mic140HardwareTareIsUsable(lTare) then
    begin
      if Trim(AErrorMessage) = '' then
        AErrorMessage := 'Calibration was not found in device flash memory';
      AErrorMessage := AErrorMessage + ' (details in ' + Mic140FlashLogFilePath() + ')';
      Mic140LogFlash(lLogPrefix + 'download failed: ' + AErrorMessage);
      Exit;
    end;

    lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
    try
      if not Mic140TareToCalibration(lTare, lCalibration) then
      begin
        AErrorMessage := 'Unsupported calibration format in device flash (details in ' +
          Mic140FlashLogFilePath() + ')';
        Mic140LogFlash(lLogPrefix + AErrorMessage + ' ' + Mic140DescribeTareRecord(lTare));
        Exit;
      end;

      lName := RecorderMic140MakeHardwareCalibrationName(lSerial, lRangeIndex,
        lChannelNumber);
      lCsvPath := RecorderMic140HardwareCalibrCsvPath(lSerial, lRangeIndex,
        lChannelNumber);
      if not RecorderMic140SaveCalibrationToCsv(lCsvPath, lCalibration) then
      begin
        AErrorMessage := 'Failed to save calibration CSV';
        Mic140LogFlash(lLogPrefix + AErrorMessage + ' path=' + lCsvPath);
        Exit;
      end;

      if RecorderMic140UpsertHardwareCalibration(ARegistry, lName, lCalibration) = nil then
      begin
        AErrorMessage := 'Failed to register hardware calibration';
        Mic140LogFlash(lLogPrefix + AErrorMessage);
        Exit;
      end;

      ATag.Mic140DeviceSerial := lSerial;
      ATag.MeasRangeIndex := LongWord(lRangeIndex);
      ATag.HardwareCalibrationName := lName;
      ATag.HardwareCalibrationEnabled := True;
      Mic140LogWarning(Format('[MIC-140] downloaded hardware calibration for tag %s to %s',
        [ATag.Name, lCsvPath]));
      Mic140LogFlash(lLogPrefix + Format('download success csv=%s points=%d',
        [lCsvPath, lCalibration.PointCount]));
      Result := True;
    finally
      lCalibration.Free;
    end;
  finally
    lClient.Free;
  end;
end;

function TRecorderMic140Device.GetDeviceSerial: Integer;
begin
  if fUseLegacyProtocol then
    Result := RecorderMic140DeviceSerialFromFirmware(fLegacyFirmware)
  else
    Result := 0;
end;

function TRecorderMic140Device.GetNodeNumber: Integer;
begin
  Result := fNodeNumber;
end;

function TRecorderMic140Device.ProgramLegacyDevice(out AErrorMessage: string): Boolean;
const
  CAInNum48: array[0..47] of Word =
    (24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
     36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
     23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12,
     11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);
  CNormalDesc = Word($0100);
  CGroundDesc = Word($0110);
var
  I: Integer;
  lArgs: TRecorderMic140LegacyWordArray;
  lChanDump: TRecorderMic140LegacyWordArray;
  lChanPtrCount: Integer;
  lDescAddr: Word;
  lDescCount: Integer;
  lDescDump: TRecorderMic140LegacyWordArray;
  lFifoAddr: Word;
  lFifoDescAddr: Word;
  lFifoReadyWords: Word;
  lInternalChannelCount: Integer;
  lPage: Word;
  lReply: TRecorderMic140LegacyWordArray;
  lScanChanAddr: Word;
  lScanDescAddr: Word;
  lStopErrorMessage: string;
  lTemperatureIndex: Integer;
  lTiming: TRecorderMic140Timing;
  lValueAddr: Word;
begin
  // The original ModuleMIC140_48 driver enables a ground descriptor before
  // every measured channel. The switched ADC depends on this table layout:
  // channel pointers are emitted as ground, channel, ground, channel...
  Result := False;
  AErrorMessage := '';
  if fLegacyClient = nil then
  begin
    AErrorMessage := 'MIC-140 legacy client is not connected';
    Exit;
  end;

  fLegacyMemAddrCur := CMic140LegacyDmBufferBegin;
  fLegacyMemHeapAddrCur := CMic140LegacyDmHeapBegin;
  lTiming := Mic140LegacyTimingForFrequency(fPollFrequencyHz, fChannelCount);
  lInternalChannelCount := LegacyInternalScanChannelCount;
  lFifoReadyWords := LegacyCalcFifoReadyWords;

  // Original CCDevice::Config() calls OnStopScanMain() before building a new
  // scan. If the previous run ended abnormally, this drains the old BIOS scan
  // state before RESETSCANMAIN and descriptor writes.
  if fLegacyScanWasStarted then
  begin
    if not fLegacyClient.StopScan(lStopErrorMessage) then
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy pre-program stop failed: %s',
        [fHost, fPort, lStopErrorMessage]));
    fLegacyClient.ClearBufferedPackets;
    fLegacyScanWasStarted := False;
  end;

  // Original CCDevice::OnResetScanMain clears BIOS scan contexts before a new
  // scan is appended, otherwise stale descriptors can keep the timer task busy.
  if not fLegacyClient.CallCommand(CMic140LegacyCmdResetScanMain, nil, 0,
    lReply, AErrorMessage) then
  begin
    AErrorMessage := 'RESETSCANMAIN failed: ' + AErrorMessage;
    Exit;
  end;

  SetLength(lArgs, 2);
  lArgs[0] := LegacyTimerScale - 1;
  lArgs[1] := LegacyTimerPeriod - 1;
  // ModuleMIC140_96::WriteConfig configures the main scan timer as
  // scale/period from the 16 MHz MC114 grid; CCDevice sends scale-1/period-1.
  if not fLegacyClient.CallCommand(CMic140LegacyCmdConfigScanMain, lArgs, 0,
    lReply, AErrorMessage) then
  begin
    AErrorMessage := 'CONFIGSCANMAIN failed: ' + AErrorMessage;
    Exit;
  end;

  if not LegacyAllocHeap(CMic140LegacyBiosScanContextWords, lPage,
    lScanDescAddr) then
  begin
    AErrorMessage := 'MIC-140 legacy scan context allocation failed';
    Exit;
  end;
  SetLength(lArgs, 5);
  lArgs[0] := CMic140LegacyTypeMic140;
  lArgs[1] := CMic140LegacyScanId;
  lArgs[2] := LegacyCalcScanDivider;
  lArgs[3] := lScanDescAddr;
  lArgs[4] := lPage;
  // ScanModule::CreateInternalScan: create scan_id=0 of TYPE_MIC140 and give
  // BIOS a small context block allocated from the heap.
  if not fLegacyClient.CallCommand(CMic140LegacyCmdAppendScanMain, lArgs, 0,
    lReply, AErrorMessage) then
  begin
    AErrorMessage := 'APPENDSCANMAIN failed: ' + AErrorMessage;
    Exit;
  end;

  SetLength(lArgs, 2);
  lArgs[0] := CMic140LegacyScanId;
  lArgs[1] := 0;
  if not fLegacyClient.CallCommand(CMic140LegacyCmdSetStateScan, lArgs, 0,
    lReply, AErrorMessage) then
  begin
    AErrorMessage := 'SETSTATESCAN failed: ' + AErrorMessage;
    Exit;
  end;

  if not LegacyAllocBuffer(2 * lFifoReadyWords, lPage, lFifoAddr) then
  begin
    AErrorMessage := 'MIC-140 legacy FIFO allocation failed';
    Exit;
  end;
  if not LegacyAllocHeap(CMic140LegacyBiosScanBufferDescWords, lPage,
    lFifoDescAddr) then
  begin
    AErrorMessage := 'MIC-140 legacy FIFO descriptor allocation failed';
    Exit;
  end;
  SetLength(lArgs, CMic140LegacyBiosScanBufferDescWords);
  lArgs[0] := 0;
  lArgs[1] := CMic140LegacyScanId;
  lArgs[2] := lFifoAddr;
  lArgs[3] := lFifoAddr;
  lArgs[4] := lFifoAddr;
  lArgs[5] := 0;
  lArgs[6] := 2 * lFifoReadyWords;
  lArgs[7] := lFifoReadyWords;
  lArgs[8] := 0;
  lArgs[9] := 0;
  // ScanModule::CreateBiosCCScanBuf: descriptor words are
  // state, scan_id, head, tail, begin, page, size, sizeready, numready, num.
  if not fLegacyClient.WriteDmWords(lFifoDescAddr, lArgs, AErrorMessage) then
  begin
    AErrorMessage := 'FIFO descriptor DM write failed: ' + AErrorMessage;
    Exit;
  end;
  SetLength(lArgs, 3);
  lArgs[0] := CMic140LegacyScanId;
  lArgs[1] := lFifoDescAddr;
  lArgs[2] := 0;
  if not fLegacyClient.CallCommand(CMic140LegacyCmdScanSetBuff, lArgs, 0,
    lReply, AErrorMessage) then
  begin
    AErrorMessage := 'SCAN_SET_BUFF failed: ' + AErrorMessage;
    Exit;
  end;

  if not LegacyAllocHeap(48 + 3, lPage, lValueAddr) then
  begin
    AErrorMessage := 'MIC-140 legacy channel value allocation failed';
    Exit;
  end;
  lDescCount := lInternalChannelCount + 1;
  if not LegacyAllocHeap(lDescCount * CMic140LegacyDescChanWords, lPage,
    lDescAddr) then
  begin
    AErrorMessage := 'MIC-140 legacy channel descriptor allocation failed';
    Exit;
  end;

  SetLength(lDescDump, lDescCount * CMic140LegacyDescChanWords);
  // TDescChanBios_MIC140_96 is five words:
  // code_ME048[0], code_ME048[1], MIC140 register desc, delay, value pointer.
  lDescDump[0] := Mic140LegacyLevel0Code;
  lDescDump[1] := Mic140LegacyLevel0Code;
  lDescDump[2] := CGroundDesc;
  lDescDump[3] := lTiming.LegacyGroundDelaySport - 1;
  lDescDump[4] := CMic140LegacyMaskGroundChannel;

  for I := 0 to lInternalChannelCount - 1 do
  begin
    lDescDump[(I + 1) * CMic140LegacyDescChanWords + 0] := 0;
    if I < fChannelCount then
    begin
      if I <= High(CAInNum48) then
        lDescDump[(I + 1) * CMic140LegacyDescChanWords + 1] :=
          Mic140LegacyMe048Code48(CAInNum48[I])
      else
        lDescDump[(I + 1) * CMic140LegacyDescChanWords + 1] := 0;
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 4] :=
        Word(lValueAddr + I);
    end
    else
    begin
      lTemperatureIndex := I - fChannelCount;
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 1] :=
        Mic140LegacyTInCode48(lTemperatureIndex);
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 2] :=
        Mic140LegacyTInDesc48(lTemperatureIndex);
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 4] :=
        Word(lValueAddr + 48 + lTemperatureIndex);
    end;
    if I < fChannelCount then
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 2] := CNormalDesc;
    lDescDump[(I + 1) * CMic140LegacyDescChanWords + 3] :=
      lTiming.LegacyChannelDelaySport - 1;
  end;

  if not fLegacyClient.WriteDmWords(lDescAddr, lDescDump, AErrorMessage) then
  begin
    AErrorMessage := 'channel descriptor DM write failed: ' + AErrorMessage;
    Exit;
  end;

  lChanPtrCount := lInternalChannelCount * 2;
  SetLength(lChanDump, CMic140LegacyStartDescChanWords + lChanPtrCount);
  lChanDump[0] := lTiming.LegacyAverageDelaySport - 1;
  lChanDump[1] := lTiming.AverageSampleCount;
  lChanDump[2] := lInternalChannelCount;
  for I := 0 to lInternalChannelCount - 1 do
  begin
    lChanDump[CMic140LegacyStartDescChanWords + I * 2] := lDescAddr;
    lChanDump[CMic140LegacyStartDescChanWords + I * 2 + 1] :=
      Word(lDescAddr + (I + 1) * CMic140LegacyDescChanWords);
  end;

  if not LegacyAllocHeap(CMic140LegacyDescChanWords, lPage, lScanChanAddr) then
  begin
    AErrorMessage := 'MIC-140 legacy scan channel descriptor allocation failed';
    Exit;
  end;
  if not LegacyAllocHeap(Length(lChanDump), lPage, lScanDescAddr) then
  begin
    AErrorMessage := 'MIC-140 legacy scan channel pointer allocation failed';
    Exit;
  end;
  if not fLegacyClient.WriteDmWords(lScanDescAddr, lChanDump, AErrorMessage) then
  begin
    AErrorMessage := 'channel pointer DM write failed: ' + AErrorMessage;
    Exit;
  end;

  SetLength(lArgs, 6);
  lArgs[0] := CMic140LegacyScanId;
  lArgs[1] := 0;
  lArgs[2] := lScanDescAddr;
  lArgs[3] := lChanPtrCount;
  lArgs[4] := lScanChanAddr;
  lArgs[5] := lPage;
  if not fLegacyClient.CallCommand(CMic140LegacyCmdAddChannelModule, lArgs, 0,
    lReply, AErrorMessage) then
  begin
    AErrorMessage := 'ADDCHANNELMODULE failed: ' + AErrorMessage;
    Exit;
  end;

  SetLength(lArgs, 4);
  lArgs[0] := CMic140LegacyScanId;
  lArgs[1] := 1;
  lArgs[2] := lScanChanAddr;
  lArgs[3] := lPage;
  if not fLegacyClient.CallCommand(CMic140LegacyCmdScanSetChans, lArgs, 0,
    lReply, AErrorMessage) then
  begin
    AErrorMessage := 'SCAN_SET_CHANS failed: ' + AErrorMessage;
    Exit;
  end;

  Result := True;
end;

procedure TRecorderMic140Device.Connect;
var
  lAttempt: Integer;
  lErrorMessage: string;
begin
  if fState <> rdsDisconnected then
    Exit;

  FreeAndNil(fLegacyClient);
  fUseLegacyProtocol := False;
  fLegacyReadErrorLogged := False;
  fLegacyReadFailureCount := 0;
  fLegacyScanWasStarted := False;
  fLegacyClient := TRecorderMic140LegacyClient.Create(fHost, fPort, 5000);
  fLegacyReadBlockCount := 0;
  fLegacyReadPacketLogged := False;
  try
    // TInetSocket.Create raises on timeout; probe first so a missing/busy
    // device is logged as a normal connection failure instead of stopping the
    // debugger on an expected exception.
    if not RecorderMic140TcpProbe(fHost, fPort, 800) then
    begin
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy TCP probe failed',
        [fHost, fPort]));
      FreeAndNil(fLegacyClient);
      Exit;
    end;

    fLegacyClient.Connect;
    if fLegacyClient.ReadFirmware(fLegacyFirmware, lErrorMessage) then
    begin
      fUseLegacyProtocol := True;
      fState := rdsConnected;
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy Ethernet protocol detected: devType=%d devRev=%d devSerNo=%d ccType=%d ccSerNo=%d BIOS=%d.%d',
        [fHost, fPort, fLegacyFirmware.DevType, fLegacyFirmware.DevRevNo,
         fLegacyFirmware.DevSerNo, fLegacyFirmware.CCType,
         fLegacyFirmware.CCSerNo, fLegacyFirmware.BiosFunction,
         fLegacyFirmware.BiosVersion]));
      Exit;
    end;
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy probe failed: %s',
      [fHost, fPort, lErrorMessage]));
  except
    on E: Exception do
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy connect failed: %s: %s',
        [fHost, fPort, E.ClassName, E.Message]));
  end;
  FreeAndNil(fLegacyClient);

  for lAttempt := 1 to CMic140ConnectAttempts do
  begin
    FreeAndNil(fClient);
    fClient := TRecorderMebiusTcpClient.Create(fHost, fPort, 5000);
    try
      fClient.Connect;
      fState := rdsConnected;
      Exit;
    except
      on E: Exception do
      begin
        Mic140LogWarning(Format('[MIC-140:%s:%d] Connect attempt %d/%d failed: %s: %s',
          [fHost, fPort, lAttempt, CMic140ConnectAttempts, E.ClassName, E.Message]));
        FreeAndNil(fClient);
        fState := rdsDisconnected;
        if lAttempt < CMic140ConnectAttempts then
          Sleep(250);
      end;
    end;
  end;
end;

function Mic140GenerateSessionId: LongWord;
begin
  Result := LongWord(GetTickCount64 and $00000FFF) or
    ((LongWord(Random($1000)) shl 12) and $00FFF000) or $14000000;
end;

function Mic140BuildSettings(AChannelCount: Integer;
  APollFrequencyHz: Double): TRecorderByteArray;
var
  I: Integer;
  lSettings: TMic140BaseSettings;
  lTiming: TRecorderMic140Timing;
begin
  FillChar(lSettings, SizeOf(lSettings), 0);
  lTiming := RecorderMic140TimingForFrequency(APollFrequencyHz);

  for I := 0 to High(lSettings.Channels) do
  begin
    lSettings.Channels[I].FrequencyHz := lTiming.FrequencyHz;
    lSettings.Channels[I].Connected :=
      I < Min(AChannelCount, CMic140MebiusChannelCount);
    if Mic140DefaultCjcTChannelNumber(I) > 0 then
      lSettings.Channels[I].Corrector := Mic140DefaultCjcTChannelNumber(I)
    else
      lSettings.Channels[I].Corrector := CMic140DefaultCorrectorId;
    lSettings.Channels[I].DefaultCorrector := False;
    lSettings.Channels[I].SoftBalance := 0;
    lSettings.Channels[I].BlockSize := 1;
    lSettings.Channels[I].MeasRangeIndex := CMic140Range100mV;
    lSettings.Channels[I].CommutIndex := CMic140ChannelCommutIn;
    lSettings.Channels[I].ShuntOn := 0;
    lSettings.Channels[I].EvalType := 0;
    lSettings.Channels[I].TensoSensitivity := 2;
    lSettings.Channels[I].Resistance := 200;
    lSettings.Channels[I].SensorScheme := CMic140SensorSchemeTenzo;
  end;

  for I := 0 to High(lSettings.TemperatureChannels) do
  begin
    lSettings.TemperatureChannels[I].FrequencyHz := lTiming.FrequencyHz;
    lSettings.TemperatureChannels[I].Connected := False;
  end;

  lSettings.SerialNumber := 0;
  lSettings.GroundEnabled := True;
  lSettings.GroundCommutationUs := Round(lTiming.GroundCommutationUs);
  lSettings.ChannelCommutationUs := Round(lTiming.ChannelCommutationUs);
  lSettings.BalancePortionLength := 30;
  lSettings.HardBalance := 8192;
  lSettings.AveragePointCount := lTiming.AveragePower;
  lSettings.PowerMaCode := 10813;
  lSettings.Reserved := 0;
  lSettings.MaxFreqMode := 0;
  lSettings.CalibrShuntIndex := 3;
  lSettings.DetermineBreak := False;
  lSettings.HardwareBalanceOn := False;
  lSettings.TemperatureCompensation := False;
  lSettings.SoftVersion := 0;

  SetLength(Result, SizeOf(lSettings));
  Move(lSettings, Result[0], SizeOf(lSettings));
end;

procedure TRecorderMic140Device.ProgramDevice;
var
  lCommandIn: TRecorderByteArray;
  lCommandOut: TRecorderByteArray;
  lErrorMessage: string;
  lSessionId: LongWord;
  lSettings: TRecorderByteArray;
  lStatusFlags: LongWord;
  lTiming: TRecorderMic140Timing;
begin
  if fState = rdsDisconnected then
    Connect;
  if fState = rdsDisconnected then
    Exit;
  if fUseLegacyProtocol then
  begin
    if ProgramLegacyDevice(lErrorMessage) then
    begin
      fState := rdsProgrammed;
      lTiming := Mic140LegacyTimingForFrequency(fPollFrequencyHz, fChannelCount);
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy MIC-140 scan programmed: channels=%d freq=%.3f Hz timerScale=%d timerPeriod=%d scanDivider=%d wait=%.3f us ground=%.3f us avgPeriod=%.3f us avgCount=%d sportWait=%d sportGround=%d sportAvg=%d fifoBegin=0x%.4x fifoEnd=0x%.4x fifoReadyWords=%d',
        [fHost, fPort, fChannelCount, fPollFrequencyHz,
         LegacyTimerScale, LegacyTimerPeriod, LegacyCalcScanDivider,
         lTiming.ChannelCommutationUs, lTiming.GroundCommutationUs,
         lTiming.AveragePeriodUs, lTiming.AverageSampleCount,
         lTiming.LegacyChannelDelaySport - 1,
         lTiming.LegacyGroundDelaySport - 1,
         lTiming.LegacyAverageDelaySport - 1,
         CMic140LegacyDmBufferBegin,
         CMic140LegacyDmBufferEnd,
         LegacyCalcFifoReadyWords]));
    end
    else
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy MIC-140 scan programming failed: %s',
        [fHost, fPort, lErrorMessage]));
    Exit;
  end;
  if fClient = nil then
    Exit;

  SetLength(lCommandIn, SizeOf(LongWord));
  lStatusFlags := 0;
  Move(lStatusFlags, lCommandIn[0], SizeOf(lStatusFlags));
  if not fClient.TryCallCommand(CMic140IoCtlCmdSetControllerParams, lCommandIn,
    0, lCommandOut, lErrorMessage) then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] SetControllerParams failed: %s',
      [fHost, fPort, lErrorMessage]));
    Exit;
  end;

  lSettings := Mic140BuildSettings(fChannelCount, fPollFrequencyHz);
  if not fClient.TryProgramDeviceBin(lSettings, lErrorMessage) then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] ProgramDeviceBin failed: %s',
      [fHost, fPort, lErrorMessage]));
    Exit;
  end;

  lSessionId := Mic140GenerateSessionId;
  if not fClient.TrySetSessionId(lSessionId, lErrorMessage) then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] SetSessionId failed: %s',
      [fHost, fPort, lErrorMessage]));
    Exit;
  end;

  if not fClient.TryProgramMeasurement(lErrorMessage) then
  begin
    Mic140LogWarning(Format('[MIC-140:%s:%d] ProgramMeasurement failed: %s',
      [fHost, fPort, lErrorMessage]));
    Exit;
  end;

  fState := rdsProgrammed;
end;

procedure TRecorderMic140Device.Disconnect;
begin
  if fState = rdsStarted then
    Stop;
  FreeAndNil(fClient);
  FreeAndNil(fLegacyClient);
  fUseLegacyProtocol := False;
  fLegacyReadErrorLogged := False;
  fLegacyReadFailureCount := 0;
  fLegacyReadBlockCount := 0;
  fLegacyReadPacketLogged := False;
  fLegacyScanWasStarted := False;
  fState := rdsDisconnected;
end;

procedure TRecorderMic140Device.Start;
var
  lAttempt: Integer;
  lErrorMessage: string;
begin
  if fState = rdsDisconnected then
    Connect;
  if fState = rdsDisconnected then
    Exit;
  if fState = rdsConnected then
    ProgramDevice;
  if fState <> rdsProgrammed then
    Exit;
  if fUseLegacyProtocol then
  begin
    if fLegacyClient = nil then
      Exit;
    if fLegacyClient.StartScan(lErrorMessage) then
    begin
      fLegacyClient.ClearBufferedPackets;
      fSampleIndex := 0;
      fLegacyReadFailureCount := 0;
      fLegacyReadBlockCount := 0;
      fLegacyReadPacketLogged := False;
      fLegacyScanWasStarted := True;
      fState := rdsStarted;
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy CC BIOS scan start accepted: command=%d',
        [fHost, fPort, MIC140_LEGACY_CMD_START_SCAN_MAIN]));
      Exit;
    end;
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy scan start failed: %s',
      [fHost, fPort, lErrorMessage]));
    fState := rdsConnected;
    Exit;
  end;
  if fClient = nil then
    Exit;

  for lAttempt := 1 to CMic140ConnectAttempts do
  begin
    if fClient.TryStartMeasurement(lErrorMessage) then
    begin
      fSampleIndex := 0;
      fState := rdsStarted;
      Exit;
    end;
    Mic140LogWarning(Format('[MIC-140:%s:%d] StartMeasurement attempt %d/%d failed: %s',
      [fHost, fPort, lAttempt, CMic140ConnectAttempts, lErrorMessage]));
    if lAttempt < CMic140ConnectAttempts then
      Sleep(250);
  end;
  fState := rdsConnected;
end;

procedure TRecorderMic140Device.Stop;
var
  lErrorMessage: string;
  lPreviousTimeoutMs: Cardinal;
begin
  if (fState = rdsStarted) and fUseLegacyProtocol and (fLegacyClient <> nil) then
  begin
    // DoTick drains queued packets with ReadBlock(0); that intentionally uses
    // a 1 ms receive timeout. StopScan shares the same socket, so restore a
    // command timeout before sending CMD_STOPSCANMAIN.
    lPreviousTimeoutMs := fLegacyClient.TimeoutMs;
    fLegacyClient.TimeoutMs := CMic140LegacyCommandTimeoutMs;
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy StopScan begin: command=%d timeout=%d ms readBlocks=%d',
      [fHost, fPort, MIC140_LEGACY_CMD_STOP_SCAN_MAIN,
       fLegacyClient.TimeoutMs, fLegacyReadBlockCount]));
    try
      if not fLegacyClient.StopScan(lErrorMessage) then
        Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy scan stop failed: %s',
          [fHost, fPort, lErrorMessage]))
      else
        Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy StopScan completed',
          [fHost, fPort]));
    finally
      fLegacyClient.TimeoutMs := lPreviousTimeoutMs;
    end;
    fLegacyClient.ClearBufferedPackets;
    fLegacyScanWasStarted := False;
    fLegacyReadFailureCount := 0;
  end
  else
  if (fState = rdsStarted) and (fClient <> nil) then
  begin
    if not fClient.TryStopMeasurement(lErrorMessage) then
      Mic140LogWarning(Format('[MIC-140:%s:%d] StopMeasurement failed: %s',
        [fHost, fPort, lErrorMessage]));
  end;
  if fState <> rdsDisconnected then
    fState := rdsConnected;
end;

function TRecorderMic140Device.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  I: Integer;
  J: Integer;
  lDataIndex: Integer;
  lErrorMessage: string;
  lInternalChannelCount: Integer;
  lLegacyBlock: TRecorderMic140LegacyScanBlock;
  lRaw: TRecorderMebiusFloatBlock;
begin
  ClearRecorderDeviceSampleBlock(ABlock);
  Result := False;
  if fState <> rdsStarted then
    Exit;
  if fUseLegacyProtocol then
  begin
    if fLegacyClient = nil then
      Exit;
    fLegacyClient.TimeoutMs := ATimeoutMs;
    if not fLegacyClient.ReadScanBlock(lLegacyBlock, lErrorMessage) then
    begin
      // ReadBlock(0) is the non-blocking drain after a valid packet. Its
      // timeout means only that the TCP queue is empty, not that MIC-140 has
      // stopped scanning. Report failures only for the timed main read.
      if ATimeoutMs > 0 then
      begin
        if not fLegacyReadErrorLogged then
        begin
          Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy scan read failed after %d good blocks: %s. The scan is left running; Stop/Disconnect will send StopScan explicitly.',
            [fHost, fPort, fLegacyReadBlockCount, lErrorMessage]));
          fLegacyReadErrorLogged := True;
        end;
        Inc(fLegacyReadFailureCount);
      end;
      Exit;
    end;
    fLegacyReadErrorLogged := False;
    fLegacyReadFailureCount := 0;
    Inc(fLegacyReadBlockCount);
    if not fLegacyReadPacketLogged then
    begin
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy first scan packet: headerWords=%d dataWords=%d stride=%d userChannels=%d tin=%d h=[%d,%d,%d,%d,%d,%d,%d,%d,%d,%d] d0=[%d,%d,%d,%d,%d,%d,%d,%d]',
        [fHost, fPort, Length(lLegacyBlock.HeaderWords),
         Length(lLegacyBlock.DataWords), LegacyInternalScanChannelCount,
         fChannelCount, MIC140TemperatureChannelCount,
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 0),
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 1),
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 2),
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 3),
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 4),
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 5),
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 6),
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 7),
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 8),
         Mic140LegacyWordAt(lLegacyBlock.HeaderWords, 9),
         Mic140LegacyWordAt(lLegacyBlock.DataWords, 0),
         Mic140LegacyWordAt(lLegacyBlock.DataWords, 1),
         Mic140LegacyWordAt(lLegacyBlock.DataWords, 2),
         Mic140LegacyWordAt(lLegacyBlock.DataWords, 3),
         Mic140LegacyWordAt(lLegacyBlock.DataWords, 4),
         Mic140LegacyWordAt(lLegacyBlock.DataWords, 5),
         Mic140LegacyWordAt(lLegacyBlock.DataWords, 6),
         Mic140LegacyWordAt(lLegacyBlock.DataWords, 7)]));
      fLegacyReadPacketLogged := True;
    end;

    lInternalChannelCount := LegacyInternalScanChannelCount;
    ABlock.ChannelCount := fChannelCount;
    if ABlock.ChannelCount <= 0 then
      Exit;
    ABlock.SampleCount := Length(lLegacyBlock.DataWords) div lInternalChannelCount;
    if ABlock.SampleCount <= 0 then
    begin
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy scan packet has no full samples: dataWords=%d stride=%d userChannels=%d',
        [fHost, fPort, Length(lLegacyBlock.DataWords), lInternalChannelCount,
         ABlock.ChannelCount]));
      Exit;
    end;
    ABlock.SampleRateHz := fPollFrequencyHz;
    ABlock.FirstTimeSec := fSampleIndex / fPollFrequencyHz;
    SetLength(ABlock.Values, ABlock.ChannelCount);
    for I := 0 to ABlock.ChannelCount - 1 do
      SetLength(ABlock.Values[I], ABlock.SampleCount);
    for J := 0 to ABlock.SampleCount - 1 do
      for I := 0 to ABlock.ChannelCount - 1 do
      begin
        lDataIndex := J * lInternalChannelCount + I;
        ABlock.Values[I][J] := SmallInt(lLegacyBlock.DataWords[lDataIndex]);
      end;
    ABlock.TemperatureCount := MIC140TemperatureChannelCount;
    SetLength(ABlock.TemperatureValues, ABlock.TemperatureCount);
    SetLength(ABlock.TemperatureValid, ABlock.TemperatureCount);
    for I := 0 to ABlock.TemperatureCount - 1 do
    begin
      SetLength(ABlock.TemperatureValues[I], ABlock.SampleCount);
      SetLength(ABlock.TemperatureValid[I], ABlock.SampleCount);
      for J := 0 to ABlock.SampleCount - 1 do
      begin
        lDataIndex := J * lInternalChannelCount + fChannelCount + I;
        ABlock.TemperatureValid[I][J] := lDataIndex < Length(lLegacyBlock.DataWords);
        if ABlock.TemperatureValid[I][J] then
          ABlock.TemperatureValues[I][J] := SmallInt(lLegacyBlock.DataWords[lDataIndex]);
      end;
    end;
    Inc(fSampleIndex, ABlock.SampleCount);
    Result := True;
    Exit;
  end;
  if fClient = nil then
    Exit;

  fClient.TimeoutMs := ATimeoutMs;
  if not fClient.ReadDataBlock(fChannelCount, lRaw) then
    Exit;

  ABlock.ChannelCount := lRaw.ChannelCount;
  ABlock.SampleCount := lRaw.SampleCount;
  ABlock.SampleRateHz := fPollFrequencyHz;
  ABlock.FirstTimeSec := fSampleIndex / fPollFrequencyHz;
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

{ TRecorderMic140DataSource }

constructor TRecorderMic140DataSource.Create(const ASourceId, AHost: string; APort: Word;
  AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  ATagNames: TStrings; AOutputMode: TRecorderMic140OutputMode);
var
  I: Integer;
  lNodeNumber: Integer;
begin
  inherited Create(ASourceId, 'MIC-140', AUpdateTimeMs);
  fLastStatusCode := Low(Integer);
  fOutputMode := AOutputMode;
  fPollFrequencyHz := RecorderMic140NormalizeFrequency(APollFrequencyHz);
  fTemperatureModeWarningLogged := False;
  fDeviceSerial := 0;
  lNodeNumber := MIC140DefaultNodeNumber;
  fStatusTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'status');
  fBlockCountTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'blocks');
  fChannelTagNames := TStringList.Create;
  fChannelTagNames.CaseSensitive := False;
  fChannelTagNames.Sorted := False;
  fTemperatureTagNames := TStringList.Create;
  fTemperatureTagNames.CaseSensitive := False;
  fTemperatureTagNames.Sorted := False;
  for I := 1 to 5 do
    fTemperatureTagNames.Add(RecorderMic140TemperatureTagName(lNodeNumber, I));
  fTagNames := TStringList.Create;
  fTagNames.CaseSensitive := False;
  fTagNames.Sorted := False;
  if ATagNames <> nil then
    fTagNames.Assign(ATagNames);
  fDevice := TRecorderMic140Device.Create(ASourceId, AHost, APort,
    AChannelCount, APollFrequencyHz, AUpdateTimeMs);
  lNodeNumber := TRecorderMic140Device(fDevice).GetNodeNumber;
  fStatusTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'status');
  fBlockCountTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'blocks');
  fTemperatureTagNames.Clear;
  for I := 1 to 5 do
    fTemperatureTagNames.Add(RecorderMic140TemperatureTagName(lNodeNumber, I));
end;

procedure TRecorderMic140DataSource.PublishDiagnostics(AStatusCode: Integer;
  const AStatusText: string; AForce: Boolean);
var
  lTag: TRecorderTag;
begin
  if Registry = nil then
    Exit;
  lTag := Registry.FindByName(fStatusTagName);
  if lTag = nil then
    Exit;
  lTag.TextValue := AStatusText;
  lTag.Description := Format('MIC-140 connection status: %s', [AStatusText]);
  if (not AForce) and (fLastStatusCode = AStatusCode) then
    Exit;
  fLastStatusCode := AStatusCode;
  Registry.PublishValue(fStatusTagName, GetTickCount64 / 1000.0, AStatusCode);
  Mic140LogWarning(Format('[DataSource:%s] MIC-140 status=%d %s',
    [SourceId, AStatusCode, AStatusText]));
end;

procedure TRecorderMic140DataSource.PublishBlockCounter(ABlockCount: Int64);
var
  lTag: TRecorderTag;
begin
  if Registry = nil then
    Exit;
  lTag := Registry.FindByName(fBlockCountTagName);
  if lTag = nil then
    Exit;
  lTag.TextValue := IntToStr(ABlockCount);
  Registry.PublishValue(fBlockCountTagName, GetTickCount64 / 1000.0, ABlockCount);
end;

procedure TRecorderMic140DataSource.PublishTemperatureBlocks(
  const ABlock: TRecorderDeviceSampleBlock; const ATimes: TRecorderDoubleArray);
var
  I: Integer;
  lJ: Integer;
  lTag: TRecorderTag;
  lValues: TRecorderDoubleArray;
begin
  if (Registry = nil) or (ABlock.TemperatureCount <= 0) or (ABlock.SampleCount <= 0) then
    Exit;
  SetLength(lValues, ABlock.SampleCount);
  for I := 0 to Min(ABlock.TemperatureCount, fTemperatureTagNames.Count) - 1 do
  begin
    if (fTagNames.Count > 0) and (fTagNames.IndexOf(fTemperatureTagNames[I]) < 0) and
      (fTagNames.IndexOf('diagnostics.cjc.T' + IntToStr(I + 1)) < 0) then
      Continue;
    lTag := Registry.FindByName(fTemperatureTagNames[I]);
    if lTag = nil then
      Continue;
    for lJ := 0 to ABlock.SampleCount - 1 do
    begin
      if (I < Length(ABlock.TemperatureValid)) and
        (lJ < Length(ABlock.TemperatureValid[I])) and
        ABlock.TemperatureValid[I][lJ] then
        lValues[lJ] := ABlock.TemperatureValues[I][lJ]
      else
        lValues[lJ] := 0;
    end;
    lTag.TextValue := FormatFloat('0.###', lValues[ABlock.SampleCount - 1]);
    Registry.PublishBlock(lTag.Name, ATimes, lValues, ABlock.SampleCount);
  end;
end;

destructor TRecorderMic140DataSource.Destroy;
begin
  Stop;
  fTagNames.Free;
  fTemperatureTagNames.Free;
  fChannelTagNames.Free;
  inherited Destroy;
end;

function TRecorderMic140DataSource.FindTagBySourceAddress(
  ARegistry: TRecorderTagRegistry; const AAddress: string): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  if ARegistry = nil then
    Exit;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].SourceId, SourceId) and
      SameMic140Address(ARegistry.Tags[I].Address, AAddress) then
      Exit(ARegistry.Tags[I]);
end;

procedure TRecorderMic140DataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lChannel: TRecorderDeviceChannel;
  lChannels: TRecorderDeviceChannelArray;
  lTag: TRecorderTag;
  lTagName: string;
begin
  lTag := ARegistry.FindByName(fStatusTagName);
  if lTag = nil then
    lTag := ARegistry.CreateTag(fStatusTagName, 4096);
  lTag.Address := 'diagnostics.status';
  lTag.UnitName := '';
  lTag.ModuleType := 'MIC-140 diagnostics';
  lTag.PollFrequencyHz := 1.0;
  lTag.SourceId := SourceId;
  lTag.Description := 'MIC-140 connection status: not checked';
  lTag.TextValue := 'not checked';

  lTag := ARegistry.FindByName(fBlockCountTagName);
  if lTag = nil then
    lTag := ARegistry.CreateTag(fBlockCountTagName, 4096);
  lTag.Address := 'diagnostics.blocks';
  lTag.UnitName := 'blocks';
  lTag.ModuleType := 'MIC-140 diagnostics';
  lTag.PollFrequencyHz := 1.0;
  lTag.SourceId := SourceId;
  lTag.Description := 'MIC-140 successfully received scan blocks';
  lTag.TextValue := '0';

  for I := 0 to fTemperatureTagNames.Count - 1 do
  begin
    if (fTagNames.Count > 0) and (fTagNames.IndexOf(fTemperatureTagNames[I]) < 0) and
      (fTagNames.IndexOf('diagnostics.cjc.T' + IntToStr(I + 1)) < 0) then
      Continue;

    lTag := ARegistry.FindByName(fTemperatureTagNames[I]);
    if lTag = nil then
      lTag := ARegistry.CreateTag(fTemperatureTagNames[I], 4096);
    lTag.Address := 'diagnostics.cjc.T' + IntToStr(I + 1);
    lTag.UnitName := 'code';
    lTag.ModuleType := 'MIC-140 diagnostics';
    lTag.PollFrequencyHz := fPollFrequencyHz;
    lTag.SourceId := SourceId;
    lTag.Description := Format('MIC-140 internal CJC channel T%d raw code; published for diagnostics only',
      [I + 1]);
    lTag.TextValue := '-';
  end;

  lChannels := fDevice.GetChannels;
  fChannelTagNames.Clear;
  for I := 0 to High(lChannels) do
  begin
    fChannelTagNames.Add('');
    lChannel := lChannels[I];
    if not lChannel.Enabled then
      Continue;
    if (fTagNames.Count > 0) and (fTagNames.IndexOf(lChannel.Name) < 0) and
      (fTagNames.IndexOf(lChannel.Address) < 0) then
      Continue;

    lTagName := lChannel.Name;
    lTag := FindTagBySourceAddress(ARegistry, lChannel.Address);
    if lTag <> nil then
      lTagName := lTag.Name
    else
      lTag := ARegistry.FindByName(lTagName);
    if lTag = nil then
      lTag := ARegistry.CreateTag(lTagName, Ceil(Max(4096, lChannel.PollFrequencyHz)));
    lTag.Address := lChannel.Address;
    // A source can contain both millivolt and thermocouple channels. Preserve
    // the mode chosen in the per-channel dialog instead of imposing the mode
    // inferred from the first source tag on every channel.
    if Trim(lTag.SourceValueMode) = '' then
      lTag.SourceValueMode := RecorderMic140OutputModeToConfigName(fOutputMode);
    if Trim(lTag.UnitName) = '' then
      lTag.UnitName := RecorderMic140OutputModeUnitName(fOutputMode);
    lTag.ModuleType := lChannel.ModuleType;
    lTag.PollFrequencyHz := lChannel.PollFrequencyHz;
    lTag.SourceId := SourceId;
    lTag.Description := Format('MIC-140 channel %s; freq=%s Hz; mode=%s',
      [lChannel.Address, FormatFloat('0.######', lChannel.PollFrequencyHz),
       lTag.SourceValueMode]);
    fChannelTagNames[I] := lTag.Name;
  end;
end;

procedure TRecorderMic140DataSource.Start;
begin
  inherited Start;
  fGoodBlockCount := 0;
  fReadFailCount := 0;
  fTemperatureModeWarningLogged := False;
  PublishDiagnostics(CMic140StatusDisconnected, 'connecting', True);
  fDevice.Connect;
  if fDevice.State = rdsDisconnected then
  begin
    PublishDiagnostics(CMic140StatusError, 'connection failed', True);
    Exit;
  end;
  PublishDiagnostics(CMic140StatusConnected, 'connected', True);
  if fDevice is TRecorderMic140Device then
  begin
    fDeviceSerial := TRecorderMic140Device(fDevice).GetDeviceSerial;
    if (fDeviceSerial > 0) and (Registry <> nil) then
      RecorderMic140ApplyHardwareCalibrations(Registry, SourceId, fDeviceSerial);
  end;
  fDevice.ProgramDevice;
  if fDevice.State = rdsProgrammed then
    PublishDiagnostics(CMic140StatusProgrammed, 'programmed', True)
  else
  if fDevice.State <> rdsStarted then
  begin
    PublishDiagnostics(CMic140StatusError, 'programming failed', True);
    Exit;
  end;
  fDevice.Start;
  if fDevice.State = rdsStarted then
    PublishDiagnostics(CMic140StatusStarted, 'started', True)
  else
  begin
    PublishDiagnostics(CMic140StatusError, 'start failed', True);
    Mic140LogWarning(Format('[DataSource:%s] MIC-140 source is not started; preview will continue without device samples',
      [SourceId]));
  end;
end;

procedure TRecorderMic140DataSource.Stop;
begin
  if fDevice <> nil then
  begin
    try
      fDevice.Stop;
      fDevice.Disconnect;
      PublishDiagnostics(CMic140StatusDisconnected, 'stopped', True);
    except
      on E: Exception do
      begin
        PublishDiagnostics(CMic140StatusError, 'stop failed: ' + E.Message, True);
      end;
    end;
  end;
  inherited Stop;
end;

procedure TRecorderMic140DataSource.DoTick;
var
  lBlock: TRecorderDeviceSampleBlock;
  lChannels: TRecorderDeviceChannelArray;
  lCount: Integer;

  procedure ProcessAndPublishBlock;
  var
    lI: Integer;
    lJ: Integer;
    lTag: TRecorderTag;
    lCjcTemperatureC: Double;
    lCjcCorrectedValue: Double;
    lUseCjc: Boolean;
    lTimes: TRecorderDoubleArray;
    lValues: TRecorderDoubleArray;
  begin
    lChannels := fDevice.GetChannels;
    lCount := Min(lBlock.ChannelCount, Length(lChannels));
    if lCount <= 0 then
      Exit;
    Inc(fGoodBlockCount);
    fReadFailCount := 0;
    PublishDiagnostics(CMic140StatusStarted, 'started; data ok', False);
    PublishBlockCounter(fGoodBlockCount);
    // Keep acquisition diagnostics useful without recreating the former
    // per-tag logging load in the 48-channel hot path.
    if (fGoodBlockCount = 1) or ((fGoodBlockCount mod 20) = 0) then
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 block=%d samples=%d stride=%d rate=%.3f Hz',
        [SourceId, fGoodBlockCount, lBlock.SampleCount, lBlock.ChannelCount +
         lBlock.TemperatureCount, lBlock.SampleRateHz]));

    SetLength(lTimes, lBlock.SampleCount);
    for lJ := 0 to lBlock.SampleCount - 1 do
      lTimes[lJ] := lBlock.FirstTimeSec + (lJ / lBlock.SampleRateHz);

    PublishTemperatureBlocks(lBlock, lTimes);

    SetLength(lValues, lBlock.SampleCount);
    for lI := 0 to lCount - 1 do
    begin
      if lI >= fChannelTagNames.Count then
        Continue;
      lTag := Registry.FindByName(fChannelTagNames[lI]);
      if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
        Continue;

      lUseCjc := lTag.Mic140ThermoCompensationEnabled and
        SameText(lTag.SourceValueMode,
          RecorderMic140OutputModeToConfigName(momTemperatureC));
      if lUseCjc then
        lUseCjc := Mic140TryGetColdJunctionTemperature(Registry, lTag, lBlock,
          lTag.Mic140CjcChannel, lCjcTemperatureC);
      if (not lUseCjc) and lTag.Mic140ThermoCompensationEnabled and
        SameText(lTag.SourceValueMode,
          RecorderMic140OutputModeToConfigName(momTemperatureC)) and
        (not fTemperatureModeWarningLogged) then
      begin
        Mic140LogWarning(Format('[DataSource:%s] MIC-140 CJC T%d is not available; raw value will pass through the thermocouple GХ without compensation',
          [SourceId, lTag.Mic140CjcChannel]));
        fTemperatureModeWarningLogged := True;
      end;

      for lJ := 0 to lBlock.SampleCount - 1 do
      begin
        lValues[lJ] := lBlock.Values[lI][lJ];
        if lUseCjc and Mic140TryBuildCjcCorrectedRawValue(Registry, lTag, lI,
          lValues[lJ], lCjcTemperatureC, lCjcCorrectedValue) then
          lValues[lJ] := lCjcCorrectedValue;
      end;
      Registry.PublishBlock(lTag.Name, lTimes, lValues, lBlock.SampleCount);
    end;
  end;

begin
  try
    if (fDevice = nil) or (fDevice.State <> rdsStarted) then
      Exit;
    if not fDevice.ReadBlock(Max(UpdateTimeMs, CMic140ReadTimeoutMinMs), lBlock) then
    begin
      Inc(fReadFailCount);
      if fReadFailCount = CMic140NoDataFailThreshold then
        PublishDiagnostics(CMic140StatusError, 'no scan data', True);
      Exit;
    end;
    ProcessAndPublishBlock;

    while fDevice.ReadBlock(0, lBlock) do
    begin
      ProcessAndPublishBlock;
    end;
  except
    on E: Exception do
    begin
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 read failed: %s: %s',
        [SourceId, E.ClassName, E.Message]));
      PublishDiagnostics(CMic140StatusError, 'read exception: ' + E.Message, True);
      fDevice.Stop;
      Exit;
    end;
  end;
end;

end.
