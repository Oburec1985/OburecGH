unit uRecorderMic140DataSource;

{
  MIC-140 core data source.

  The source uses the same RecorderLnx data-source contract as virtual/MERA
  playback sources. Transport/protocol code is isolated in
  uRecorderMebiusTcpProtocol, so the UI and storage layers do not depend on
  MIC-140 details.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uRecorderDataSources, uRecorderDeviceInterfaces, uRecorderMebiusTcpProtocol,
  uRecorderMic140LegacyProtocol,
  uRecorderTags;

const
  MIC140DefaultHost = '192.168.14.155';
  MIC140DefaultPort = 4000;
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 5;
  MIC140DefaultPollFrequencyHz = 100.0;
  MIC140DefaultDiscoverySubnet = '192.168.14.';

type
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
    fUseLegacyProtocol: Boolean;
    fPollFrequencyHz: Double;
    fPort: Word;
    fSampleIndex: Int64;
    fState: TRecorderDeviceState;
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;
    procedure BuildChannels;
    function LegacyAllocBuffer(AWordCount: Word; out APage, AAddress: Word): Boolean;
    function LegacyAllocHeap(AWordCount: Word; out APage, AAddress: Word): Boolean;
    function LegacyCalcFifoReadyWords: Word;
    function LegacyCalcScanDivider: Word;
    function LegacyTimerPeriod: Word;
    function LegacyTimerScale: Word;
    function ProgramLegacyDevice(out AErrorMessage: string): Boolean;
  public
    constructor Create(const ADeviceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double);
    destructor Destroy; override;

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
    fReadFailCount: Integer;
    fBlockCountTagName: string;
    fStatusTagName: string;
    fTagNames: TStringList;
    function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    procedure PublishDiagnostics(AStatusCode: Integer; const AStatusText: string;
      AForce: Boolean = False);
    procedure PublishBlockCounter(ABlockCount: Int64);
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
      ATagNames: TStrings = nil);
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
  end;

function RecorderMic140SourceId(const AHost: string; APort: Word): string;
function TryParseRecorderMic140SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
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

implementation

uses
  Math, StrUtils, uSharedFileLogger
  {$IFDEF MSWINDOWS}, WinSock2{$ELSE}, BaseUnix, CTypes, Sockets{$ENDIF};

const
  CMic140SourcePrefix = 'MIC-140:';
  CMic140StatusDisconnected = 0;
  CMic140StatusConnected = 1;
  CMic140StatusProgrammed = 2;
  CMic140StatusStarted = 3;
  CMic140StatusError = -1;
  CMic140ReadTimeoutMinMs = 1500;
  CMic140NoDataFailThreshold = 10;
  CMic140ConnectAttempts = 3;
  CMic140LegacyMaxUiReadFrequencyHz = 1000.0;
  CMic140MebiusChannelCount = 16;
  CMic140MebiusTemperatureSettingsCount = 5;
  CMic140MebiusModuleCount = 4;
  CMic140FrequencyCount = 8;
  CMic140Frequencies: array[0..CMic140FrequencyCount - 1] of Double =
    (1.0, 2.0, 5.0, 10.0, 20.0, 25.0, 50.0, 100.0);
  CMic140IoCtlTypeCallCommand = 2;
  CMic140IoCtlCmdSetControllerParams =
    (CMic140IoCtlTypeCallCommand shl 16) or ($000C shl 2);
  CMic140ChannelCommutIn = 0;
  CMic140Range5mV = 2;
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

function RecorderMic140SourceId(const AHost: string; APort: Word): string;
begin
  Result := CMic140SourcePrefix + ' ' + Trim(AHost) + ':' + IntToStr(APort);
end;

function TryParseRecorderMic140SourceId(const ASourceId: string;
  out AHost: string; out APort: Word): Boolean;
var
  lHostPort: string;
  lPos: Integer;
  lPort: Integer;
begin
  Result := False;
  AHost := '';
  APort := MIC140DefaultPort;
  if Pos(CMic140SourcePrefix, ASourceId) <> 1 then
    Exit;

  lHostPort := Trim(Copy(ASourceId, Length(CMic140SourcePrefix) + 1, MaxInt));
  if lHostPort = '' then
    lHostPort := MIC140DefaultHost + ':' + IntToStr(MIC140DefaultPort);

  lPos := RPos(':', lHostPort);
  if lPos > 0 then
  begin
    AHost := Trim(Copy(lHostPort, 1, lPos - 1));
    if not TryStrToInt(Trim(Copy(lHostPort, lPos + 1, MaxInt)), lPort) then
      Exit;
    if (lPort <= 0) or (lPort > High(Word)) then
      Exit;
    APort := Word(lPort);
  end
  else
    AHost := lHostPort;

  Result := AHost <> '';
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
  AChannelCount: Integer; APollFrequencyHz: Double);
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
    fChannels[I].Name := Format('MIC140_%2.2d', [I + 1]);
    fChannels[I].Address := IntToStr(I + 1);
    fChannels[I].UnitName := '';
    fChannels[I].ModuleType := 'MIC-140';
    fChannels[I].PollFrequencyHz := fPollFrequencyHz;
    fChannels[I].Enabled := True;
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
begin
  // Mirrors CCMC031EthernetInterface::GetDMAddrBeginBuffer() and
  // Scan::CalcFifoSize(). Ethernet MC031 reserves the lower DM area, so scan
  // FIFO must start at 0x0522. The original first computes ready samples per
  // channel, then multiplies by channel count to get the scan FIFO portion.
  lChannelCount := fChannelCount;
  if lChannelCount <= 0 then
    lChannelCount := MIC140DefaultChannelCount;
  lMaxFifoAdspWords := CMic140LegacyDmBufferEnd - CMic140LegacyDmBufferBegin + 1;
  lReadyWordsPerChannel := (lMaxFifoAdspWords div 2) div lChannelCount;
  if lReadyWordsPerChannel <= 0 then
    lReadyWordsPerChannel := 1;
  if lReadyWordsPerChannel > 1024 then
    lReadyWordsPerChannel := 1024;
  Result := Word(lReadyWordsPerChannel * lChannelCount);
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

function Mic140LegacyWordAt(const AWords: TRecorderMic140LegacyWordArray;
  AIndex: Integer): Word;
begin
  if (AIndex >= 0) and (AIndex < Length(AWords)) then
    Result := AWords[AIndex]
  else
    Result := 0;
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
  lPage: Word;
  lReply: TRecorderMic140LegacyWordArray;
  lScanChanAddr: Word;
  lScanDescAddr: Word;
  lStopErrorMessage: string;
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
  lDescCount := fChannelCount + 1;
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

  for I := 0 to fChannelCount - 1 do
  begin
    lDescDump[(I + 1) * CMic140LegacyDescChanWords + 0] := 0;
    if I <= High(CAInNum48) then
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 1] :=
        Mic140LegacyMe048Code48(CAInNum48[I])
    else
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 1] := 0;
    lDescDump[(I + 1) * CMic140LegacyDescChanWords + 2] := CNormalDesc;
    lDescDump[(I + 1) * CMic140LegacyDescChanWords + 3] :=
      lTiming.LegacyChannelDelaySport - 1;
    lDescDump[(I + 1) * CMic140LegacyDescChanWords + 4] :=
      Word(lValueAddr + I);
  end;
  if not fLegacyClient.WriteDmWords(lDescAddr, lDescDump, AErrorMessage) then
  begin
    AErrorMessage := 'channel descriptor DM write failed: ' + AErrorMessage;
    Exit;
  end;

  lChanPtrCount := fChannelCount * 2;
  SetLength(lChanDump, CMic140LegacyStartDescChanWords + lChanPtrCount);
  lChanDump[0] := lTiming.LegacyAverageDelaySport - 1;
  lChanDump[1] := lTiming.AverageSampleCount;
  lChanDump[2] := fChannelCount;
  for I := 0 to fChannelCount - 1 do
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
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy Ethernet protocol detected: device=%d.%d serial=%d controller=%d serial=%d BIOS=%d.%d',
        [fHost, fPort, fLegacyFirmware.DeviceType, fLegacyFirmware.DeviceRevision,
         fLegacyFirmware.DeviceSerial, fLegacyFirmware.ControllerType,
         fLegacyFirmware.ControllerSerial, fLegacyFirmware.BiosFunction,
         fLegacyFirmware.BiosRevision]));
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
    lSettings.Channels[I].Corrector := CMic140DefaultCorrectorId;
    lSettings.Channels[I].DefaultCorrector := False;
    lSettings.Channels[I].SoftBalance := 0;
    lSettings.Channels[I].BlockSize := 1;
    lSettings.Channels[I].MeasRangeIndex := CMic140Range5mV;
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
begin
  if (fState = rdsStarted) and fUseLegacyProtocol and (fLegacyClient <> nil) then
  begin
    if not fLegacyClient.StopScan(lErrorMessage) then
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy scan stop failed: %s',
        [fHost, fPort, lErrorMessage]));
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
      if not fLegacyReadErrorLogged then
      begin
        Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy scan read failed after %d good blocks: %s. The scan is left running; Stop/Disconnect will send StopScan explicitly.',
          [fHost, fPort, fLegacyReadBlockCount, lErrorMessage]));
        fLegacyReadErrorLogged := True;
      end;
      Inc(fLegacyReadFailureCount);
      Exit;
    end;
    fLegacyReadErrorLogged := False;
    fLegacyReadFailureCount := 0;
    Inc(fLegacyReadBlockCount);
    if not fLegacyReadPacketLogged then
    begin
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy first scan packet: headerWords=%d dataWords=%d h=[%d,%d,%d,%d,%d,%d,%d,%d,%d,%d] d0=[%d,%d,%d,%d,%d,%d,%d,%d]',
        [fHost, fPort, Length(lLegacyBlock.HeaderWords),
         Length(lLegacyBlock.DataWords),
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

    ABlock.ChannelCount := fChannelCount;
    if ABlock.ChannelCount <= 0 then
      Exit;
    ABlock.SampleCount := Length(lLegacyBlock.DataWords) div ABlock.ChannelCount;
    if ABlock.SampleCount <= 0 then
    begin
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy scan packet has no full samples: dataWords=%d channels=%d',
        [fHost, fPort, Length(lLegacyBlock.DataWords), ABlock.ChannelCount]));
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
        lDataIndex := J * ABlock.ChannelCount + I;
        ABlock.Values[I][J] := SmallInt(lLegacyBlock.DataWords[lDataIndex]);
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
  ATagNames: TStrings);
var
  lDiagnosticPrefix: string;
begin
  inherited Create(ASourceId, 'MIC-140', AUpdateTimeMs);
  fLastStatusCode := Low(Integer);
  lDiagnosticPrefix := StringReplace(ASourceId, CMic140SourcePrefix, 'MIC140',
    [rfIgnoreCase]);
  lDiagnosticPrefix := StringReplace(Trim(lDiagnosticPrefix), ' ', '_',
    [rfReplaceAll]);
  lDiagnosticPrefix := StringReplace(lDiagnosticPrefix, ':', '_',
    [rfReplaceAll]);
  lDiagnosticPrefix := StringReplace(lDiagnosticPrefix, '.', '_',
    [rfReplaceAll]);
  fStatusTagName := lDiagnosticPrefix + '_Status';
  fBlockCountTagName := lDiagnosticPrefix + '_Blocks';
  fChannelTagNames := TStringList.Create;
  fChannelTagNames.CaseSensitive := False;
  fChannelTagNames.Sorted := False;
  fTagNames := TStringList.Create;
  fTagNames.CaseSensitive := False;
  fTagNames.Sorted := False;
  if ATagNames <> nil then
    fTagNames.Assign(ATagNames);
  fDevice := TRecorderMic140Device.Create(ASourceId, AHost, APort,
    AChannelCount, APollFrequencyHz);
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

destructor TRecorderMic140DataSource.Destroy;
begin
  Stop;
  fTagNames.Free;
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
      SameText(ARegistry.Tags[I].Address, AAddress) then
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
    lTag.UnitName := lChannel.UnitName;
    lTag.ModuleType := lChannel.ModuleType;
    lTag.PollFrequencyHz := lChannel.PollFrequencyHz;
    lTag.SourceId := SourceId;
    lTag.Description := Format('MIC-140 channel %s; freq=%s Hz',
      [lChannel.Address, FormatFloat('0.######', lChannel.PollFrequencyHz)]);
    fChannelTagNames[I] := lTag.Name;
  end;
end;

procedure TRecorderMic140DataSource.Start;
begin
  inherited Start;
  fGoodBlockCount := 0;
  fReadFailCount := 0;
  PublishDiagnostics(CMic140StatusDisconnected, 'connecting', True);
  fDevice.Connect;
  if fDevice.State = rdsDisconnected then
  begin
    PublishDiagnostics(CMic140StatusError, 'connection failed', True);
    Exit;
  end;
  PublishDiagnostics(CMic140StatusConnected, 'connected', True);
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
  I: Integer;
  J: Integer;
  lBlock: TRecorderDeviceSampleBlock;
  lChannels: TRecorderDeviceChannelArray;
  lCount: Integer;
  lTag: TRecorderTag;
  lTimes: TRecorderDoubleArray;
  lValues: TRecorderDoubleArray;
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
  lChannels := fDevice.GetChannels;
  lCount := Min(lBlock.ChannelCount, Length(lChannels));
  if lCount <= 0 then
    Exit;
  Inc(fGoodBlockCount);
  fReadFailCount := 0;
  PublishDiagnostics(CMic140StatusStarted, 'started; data ok', False);
  PublishBlockCounter(fGoodBlockCount);

  SetLength(lTimes, lBlock.SampleCount);
  for J := 0 to lBlock.SampleCount - 1 do
    lTimes[J] := lBlock.FirstTimeSec + (J / lBlock.SampleRateHz);

  SetLength(lValues, lBlock.SampleCount);
  for I := 0 to lCount - 1 do
  begin
    if I >= fChannelTagNames.Count then
      Continue;
    lTag := Registry.FindByName(fChannelTagNames[I]);
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;

    for J := 0 to lBlock.SampleCount - 1 do
      lValues[J] := lBlock.Values[I][J];
    Registry.PublishBlock(lTag.Name, lTimes, lValues, lBlock.SampleCount);
  end;
end;

end.
