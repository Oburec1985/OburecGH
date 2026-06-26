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
  Classes, SysUtils, Forms, SyncObjs,
  uRecorderDataSources, uRecorderDeviceInterfaces, uRecorderMebiusTcpProtocol,
  uRecorderMic140LegacyProtocol, uRecorderMic140Utils,
  uRecorderMic140StreamTypes, uRecorderMic140DoubleBuffer,
  uRecorderMic140ScanConfig, uRecorderMic140StreamFsm,
  uRecorderMic140AcquireTiming,
  uRecorderMic140StreamHelpers, uRecorderMic140LegacyTiming,
  uRecorderMic140Calibration, uRecorderMic140LegacyConstants,
  uRecorderMic140ProtocolDriver,
  uRecorderTags;

const
  MIC140DefaultDiscoverySubnet = '192.168.14.';
  CMic140Mic140SubRev1 = 1;
  { Re-exported from StreamTypes / LegacyConstants for legacy callers. }
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;
  MIC140DefaultPollFrequencyHz = 100.0;
  CMic140Range100mV = 0;
  CMic140RangeCount = 3;

type
  TRecorderMic140ChannelSettings = record
    ChannelAddress: string;
    RangeIndex: Integer;
    DefaultCjc: Boolean;
    CjcChannel: Integer;
    ThermocoupleScalePath: string;
    ThermocoupleScaleName: string;
    SoftBalance: Double;
    OutputMode: string;
    ChannelCalibrationEnabled: Boolean;
    HardwareCalibrationEnabled: Boolean;
    HardwareCalibrationName: string;
    { CJC offset °C per channel (SetTemperOffset); 0 = none. }
    CjcTemperOffsetC: Double;
  end;

  TRecorderMic140OutputMode = (
    momMillivolts,
    momTemperatureC
  );

  TRecorderMic140Device = class(TInterfacedObject, IRecorderDevice)
  private
    fChannelCount: Integer;
    fChannels: TRecorderDeviceChannelArray;
    fClient: TRecorderMebiusTcpClient;
    fDeviceId: string;
    fHost: string;
    fLegacyClient: TRecorderMic140LegacyClient;
    fLegacyFirmware: TRecorderMic140LegacyFirmware;
    fHardwareCalibrSerial: Integer;
    fLegacyMemAddrCur: Word;
    fLegacyMemHeapAddrCur: Word;
    fLegacyReadBlockCount: Int64;
    fLegacyReadErrorLogged: Boolean;
    fLegacyReadFailureCount: Integer;
    fLegacyReadPacketLogged: Boolean;
    fLegacyLastNumBuff: Word;
    fLegacyLastNumBuffValid: Boolean;
    fLegacyLastReadTick: QWord;
    fLegacyLastReadTickValid: Boolean;
    fLegacyLastGoodRawBlock: TMic140LegacyRawBlock;
    fLegacyLastGoodRawBlockValid: Boolean;
    fLegacyNumBuffGapCount: Integer;
    fLegacyDuplicateNumBuffCount: Integer;
    fLegacyCorruptReadCount: Integer;
    fLegacyConsecutiveCorruptCount: Integer;
    fLegacySoftRestartCount: Integer;
    fLegacyReadStallRestartCount: Integer;
    fLegacyScanWasStarted: Boolean;
    fLegacyStreamSequenceReset: Boolean;
    fNodeNumber: Integer;
    fUseLegacyProtocol: Boolean;
    fPollFrequencyHz: Double;
    fPort: Word;
    fSampleIndex: Int64;
    fState: TRecorderDeviceState;
    fStopRequested: Boolean;
    fUpdateTimeMs: Cardinal;
    fLastAuxTemperature: TMic140AuxTemperatureBlock;
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer): Variant;
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer): Boolean;
    procedure BuildChannels;
    function LegacyAllocBuffer(AWordCount: Word; out APage, AAddress: Word): Boolean;
    function LegacyAllocHeap(AWordCount: Word; out APage, AAddress: Word): Boolean;
    function LegacyInternalScanChannelCount: Integer;
    function LegacyCalcScanDivider: Word;
    function LegacyTimerPeriod: Word;
    function LegacyTimerScale: Word;
    function ProgramLegacyDevice(out AErrorMessage: string): Boolean;
    procedure CheckLegacyNumBuffOnRead(const ARaw: TMic140LegacyRawBlock;
      ASincePrevMs: QWord);
    procedure LogLegacyScanBlockDetail(const ARaw: TMic140LegacyRawBlock;
      ASincePrevMs: QWord);
    function LegacyNoteReadSincePrevMs: QWord;
    function LegacyTrySoftRestartScan: Boolean;
    procedure LegacyRecoverTcpConnection;
    function LegacyProbeScanRunning: Boolean;
  public
    constructor Create(const ADeviceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal);
    destructor Destroy; override;

    function GetDeviceSerial: Integer;
    function GetLegacyFirmware(out AFirmware: TRecorderMic140LegacyFirmware): Boolean;
    function GetNodeNumber: Integer;
    function LegacyCalcFifoReadyWords: Word;

    procedure Connect;
    procedure Disconnect;
    procedure ProgramDevice;
    procedure Start;
    procedure RequestStopAcquisition;
    procedure Stop;
    procedure ClearLegacyScanBuffer;
    function RunServiceZeroBalance(const AChannelNumbers: array of Integer;
      APollFrequencyHz: Double; out AMeans: TRecorderDoubleArray;
      out AErrorMessage: string): Boolean;
    function ReadLegacyRawBlock(ATimeoutMs: Cardinal;
      out ARaw: TMic140LegacyRawBlock): Boolean;
    function LegacyDecommutateRawBlock(const ARaw: TMic140LegacyRawBlock;
      out ABlock: TRecorderDeviceSampleBlock): Boolean;
    function ReadBlock(ATimeoutMs: Cardinal; out ABlock: TRecorderDeviceSampleBlock): Boolean;
    function LegacyStreamReadCount: Int64;
    function LegacyNumBuffGapCount: Integer;
    function LegacyDuplicateNumBuffCount: Integer;
    function LegacyCorruptReadCount: Integer;
    function LegacyMdpResyncByteCount: Int64;
    function LegacyTryRestartStreamAfterReadStall: Boolean;
    function LegacyConsumeStreamSequenceReset: Boolean;
    function LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;

    property Host: string read fHost;
    property Port: Word read fPort;
    property ChannelCount: Integer read fChannelCount;
  end;

  TRecorderMic140DataSource = class(TRecorderDataSourceBase, IRecorderZeroBalanceSupport)
  private
    fBlockPublishThread: TObject;
    fLegacyReadThread: TObject;
    fRawBuffer: TMic140RawDoubleBuffer;
    fAcquireTiming: TRecorderMic140AcquireTiming;
    fStreamFsm: TMic140StreamFsm;
    fScanConfig: TRecorderMic140ScanConfig;
    fProtocolDriver: TRecorderMic140ProtocolDriver;
    fHardwarePrepared: Boolean;
    fHardwarePrepareAttempted: Boolean;
    fChannelTagNames: TStringList;
    fDevice: IRecorderDevice;
    fMic140Device: TRecorderMic140Device;
    fGoodBlockCount: Int64;
    fLastStatusCode: Integer;
    fOutputMode: TRecorderMic140OutputMode;
    fPollFrequencyHz: Double;
    fReadFailCount: Integer;
    fBlockCountTagName: string;
    fStatusTagName: string;
    fTagNames: TStringList;
    fCjcActiveLogWritten: Boolean;
    fCjcCorrectLogWritten: Boolean;
    fTemperatureModeWarningLogged: Boolean;
    fTemperatureTagNames: TStringList;
    fDeviceSerial: Integer;
    fLastRawChannelMeans: array of Double;
    fLastRawBlockValid: Boolean;
  fLastChannelAdcSamples: array of Double;
  fLastChannelAdcValid: Boolean;
  fLastRingOverloadLogTick: QWord;
  fLastPublishedNumBuff: Word;
  fLastPublishedNumBuffValid: Boolean;
  fPublishedNumBuffGapCount: Integer;
  fPublishedCorruptCount: Integer;
    function FindTagBySourceAddress(ARegistry: TRecorderTagRegistry;
      const AAddress: string): TRecorderTag;
    function TemperatureChannelSelected(AIndex: Integer): Boolean;
    function ChannelIndexForTag(ATag: TRecorderTag): Integer;
    function GetLastRawChannelMean(AChannelIndex: Integer; out AMean: Double): Boolean;
    function Mic140RawSample(const ABlock: TRecorderDeviceSampleBlock;
      AChannelIndex, ASampleIndex: Integer; ATag: TRecorderTag): Double;
    procedure RebuildTemperatureTagNames;
    procedure PublishDiagnostics(AStatusCode: Integer; const AStatusText: string;
      AForce: Boolean = False);
    procedure PublishBlockCounter(ABlockCount: Int64);
    procedure PublishTemperatureBlocks(const AAux: TMic140AuxTemperatureBlock;
      const ATimes: TRecorderDoubleArray);
    procedure EnsureBlockPublishThread;
    procedure StopBlockPublishThread;
    procedure EnsureLegacyReadThread;
    procedure StopLegacyReadThread;
    procedure EnqueueLegacyRawBlock(const ARaw: TMic140LegacyRawBlock);
    function TryEnqueueGoodLegacyRawBlock(const ARaw: TMic140LegacyRawBlock): Boolean;
    procedure ProcessLegacyRawBlock(const ARaw: TMic140LegacyRawBlock);
    procedure CheckPublishedNumBuff(const ARaw: TMic140LegacyRawBlock);
    procedure LogMic140StreamSummary(const ARaw: TMic140LegacyRawBlock);
    procedure LogMic140StrideMisalignmentIfNeeded(const ARaw: TMic140LegacyRawBlock;
      const ABlock: TRecorderDeviceSampleBlock);
    procedure ProcessAndPublishBlock(const ABlock: TRecorderDeviceSampleBlock);
    procedure SyncScanConfig;
    procedure EnsureProtocolDriver;
    procedure FreeProtocolDriver;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
    procedure PrepareHardware; override;
  public
    constructor Create(const ASourceId, AHost: string; APort: Word;
      AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
      ATagNames: TStrings = nil; AOutputMode: TRecorderMic140OutputMode = momMillivolts);
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;
    procedure RequestStop; override;
    function ZeroBalanceTags(AOwner: TComponent; ATags: TList;
      AMessages: TStrings): Boolean;
  end;

function RecorderMic140ZeroBalanceTags(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATags: TList;
  ADataSources: TRecorderDataSourceManager; AMessages: TStrings): Boolean;
function RecorderMic140TestConnection(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal = 250): Boolean;
procedure RecorderMic140Discover(AFoundHosts: TStrings;
  const ASubnetPrefix: string = MIC140DefaultDiscoverySubnet;
  APort: Word = MIC140DefaultPort; ATimeoutMs: Cardinal = 180);
procedure RecorderMic140ApplySourceFrequency(ARegistry: TRecorderTagRegistry;
  const ASourceId: string; AFrequencyHz: Double);
function RecorderMic140OutputModeToConfigName(AValue: TRecorderMic140OutputMode): string;
function RecorderMic140ConfigNameToOutputMode(const AValue: string): TRecorderMic140OutputMode;
function RecorderMic140OutputModeUnitName(AValue: TRecorderMic140OutputMode): string;
function RecorderMic140QueryDeviceSerial(const AHost: string; APort: Word;
  out ADeviceSerial: Integer): Boolean;
function RecorderMic140QueryHardwareCalibrSerial(const AHost: string; APort: Word;
  out ACalibrSerial: Integer): Boolean;
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
function RecorderMic140TagEffectiveCjcChannel(ATag: TRecorderTag;
  AChannelIndex, ADevSubRev: Integer): Integer;
function RecorderMic140ChannelGradRangeText(
  const ASettings: TRecorderMic140ChannelSettings): string;
procedure RecorderMic140RestoreChannelSettingsFromTag(
  ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
  var ASettings: TRecorderMic140ChannelSettings);
function RecorderMic140EnsureThermocoupleCalibration(
  ARegistry: TRecorderTagRegistry;
  const ASettings: TRecorderMic140ChannelSettings): string;

implementation

uses
  Math, StrUtils, LazFileUtils, Controls, Dialogs, LCLIntf, Variants,
  uSharedFileLogger, uRecorderMeraPaths, uRecorderDebugLog,
  uRecorderMeraSdbThermocouples, uRecorderSdbStore,
  uRecorderMic140FlashConstants,
  uRecorderMic140Thermocouple, uRecorderMic140MebiusConstants,
  uRecorderMic140DeviceConfig, uRecorderMic140Flash,
  uRecorderMic140MebiusTypes,
  uRecorderMic140LegacyChannelDesc, uRecorderMic140LegacyScanDriver
  {$IFDEF MSWINDOWS}, WinSock2{$ELSE}, BaseUnix, CTypes, Sockets{$ENDIF};

const
  CMic140StatusDisconnected = 0;
  CMic140StatusConnected = 1;
  CMic140StatusProgrammed = 2;
  CMic140StatusStarted = 3;
  CMic140StatusError = -1;
  CMic140ReadTimeoutMinMs = 1500;
  CMic140IoCtlTypeCallCommand = 2;
  CMic140IoCtlCmdSetControllerParams =
    (CMic140IoCtlTypeCallCommand shl 16) or ($000C shl 2);
  CMic140BalanceMinSamples = 30;
  CMic140BalanceDiscardSamples = 10;
  CMic140BalanceSampleFraction = 0.3;
  CMic140Range5mV = 2;

procedure TRecorderMic140Device.LogLegacyScanBlockDetail(
  const ARaw: TMic140LegacyRawBlock; ASincePrevMs: QWord);
var
  lCorrupt: Boolean;
begin
  lCorrupt := Mic140LegacyRawBlockLooksCorrupt(ARaw, fChannelCount);
  if lCorrupt then
  begin
    Inc(fLegacyCorruptReadCount);
    Inc(fLegacyConsecutiveCorruptCount);
  end
  else
    fLegacyConsecutiveCorruptCount := 0;
  if (not fLegacyReadPacketLogged) or lCorrupt or
     (ARaw.ReadSerial <= CMic140LegacyScanDetailLogBlocks) then
  begin
    Mic140LogWarning(Format(
      '[MIC-140:%s:%d] Legacy scan: readSerial=%d num_buff=%d sincePrevMs=%d corrupt=%s',
      [fHost, fPort, ARaw.ReadSerial, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
       ASincePrevMs, BoolToStr(lCorrupt, True)]));
    fLegacyReadPacketLogged := True;
  end;
  if lCorrupt then
    LegacyTrySoftRestartScan;
end;

function TRecorderMic140Device.LegacyNoteReadSincePrevMs: QWord;
var
  lNow: QWord;
begin
  lNow := GetTickCount64;
  if fLegacyLastReadTickValid then
    Result := lNow - fLegacyLastReadTick
  else
    Result := 0;
  fLegacyLastReadTick := lNow;
  fLegacyLastReadTickValid := True;
end;

procedure TRecorderMic140Device.CheckLegacyNumBuffOnRead(
  const ARaw: TMic140LegacyRawBlock; ASincePrevMs: QWord);
var
  lCurNumBuff: Word;
  lExpected: Word;
  lMissed: Integer;
begin
  lCurNumBuff := ARaw.Header[CMic140LegacyBiosNumBuffIdx];
  if fLegacyLastNumBuffValid then
  begin
    if lCurNumBuff = fLegacyLastNumBuff then
    begin
      Inc(fLegacyDuplicateNumBuffCount);
      Mic140LogWarning(Format(
        '[MIC-140:%s:%d] Legacy num_buff duplicate: readSerial=%d num_buff=%d sincePrevMs=%d (prev=%d)',
        [fHost, fPort, ARaw.ReadSerial, lCurNumBuff, ASincePrevMs, fLegacyLastNumBuff]));
    end
    else
    begin
      lExpected := Word((Integer(fLegacyLastNumBuff) + 1) and $FFFF);
      if lCurNumBuff <> lExpected then
      begin
        lMissed := Integer(lCurNumBuff) - Integer(lExpected);
        if lMissed < 0 then
          Inc(lMissed, 65536);
        if lMissed >= CMic140LegacyNumBuffDesyncRestartMissed then
        begin
          Mic140LogWarning(Format(
            '[MIC-140:%s:%d] Legacy num_buff desync: readSerial=%d prev=%d expected=%d cur=%d missed=%d -> stream restart',
            [fHost, fPort, ARaw.ReadSerial, fLegacyLastNumBuff, lExpected, lCurNumBuff,
             lMissed]));
          fLegacyLastNumBuffValid := False;
          LegacyTryRestartStreamAfterReadStall;
          Exit;
        end;
        Inc(fLegacyNumBuffGapCount);
        Mic140LogWarning(Format(
          '[MIC-140:%s:%d] Legacy num_buff gap on read: readSerial=%d sincePrevMs=%d prev=%d expected=%d cur=%d missed=%d totalGaps=%d',
          [fHost, fPort, ARaw.ReadSerial, ASincePrevMs, fLegacyLastNumBuff, lExpected, lCurNumBuff,
           lMissed, fLegacyNumBuffGapCount]));
      end;
    end;
  end;
  fLegacyLastNumBuff := lCurNumBuff;
  fLegacyLastNumBuffValid := True;
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
  fHardwareCalibrSerial := 0;
  fStopRequested := False;
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

function TRecorderMic140Device.GetDeviceProperty(AProperty: TRecorderDeviceProperty;
  AIndex: Integer): Variant;
begin
  case AProperty of
    rdpName: Result := GetName;
    rdpHost: Result := fHost;
    rdpPort: Result := Integer(fPort);
    rdpPollFrequencyHz: Result := fPollFrequencyHz;
    rdpUpdateTimeMs: Result := Integer(fUpdateTimeMs);
    rdpChannelCount: Result := fChannelCount;
    rdpDeviceSerial: Result := GetDeviceSerial;
    rdpStateWord: Result := Ord(fState);
    rdpErrorCode: Result := 0;
    rdpErrorText: Result := '';
  else
    Result := Null;
  end;
end;

function TRecorderMic140Device.TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
  const AValue: Variant; AIndex: Integer): Boolean;
var
  lNum: Double;
begin
  Result := False;
  case AProperty of
    rdpHost:
      if VarIsStr(AValue) or VarIsType(AValue, varUString) then
      begin
        fHost := string(AValue);
        Exit(True);
      end;
    rdpPort:
      if VarIsNumeric(AValue) then
      begin
        lNum := AValue;
        fPort := Word(Trunc(lNum));
        Exit(True);
      end;
    rdpPollFrequencyHz:
      if VarIsNumeric(AValue) then
      begin
        fPollFrequencyHz := Double(AValue);
        Exit(True);
      end;
    rdpUpdateTimeMs:
      if VarIsNumeric(AValue) then
      begin
        lNum := AValue;
        fUpdateTimeMs := Cardinal(Trunc(lNum));
        Exit(True);
      end;
    rdpChannelCount:
      if VarIsNumeric(AValue) then
      begin
        lNum := AValue;
        if Trunc(lNum) > 0 then
        begin
          fChannelCount := Trunc(lNum);
          BuildChannels;
          Exit(True);
        end;
      end;
  end;
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
  // The live 48-channel MIC-140 currently stays stable only when the BIOS scan
  // stride contains user AIn channels. Internal TIn slots are handled by the
  // CJC pipeline later; adding them here makes every other payload block phase
  // into non-AIn data even though MDP framing remains valid.
  Result := fChannelCount;
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


function Mic140TagHasThermocoupleCalibration(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag): Boolean;
begin
  Result := (ARegistry <> nil) and
    (ARegistry.FindTagThermocoupleCalibration(ATag) <> nil);
end;

function Mic140TryInvertTagCalibration(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; ATemperatureC: Double; out AMillivolts: Double): Boolean;
begin
  Result := (ARegistry <> nil) and
    ARegistry.InvertTagThermocoupleValue(ATag, ATemperatureC, AMillivolts);
end;

function Mic140LegacyStopScanWithCommandTimeout(AClient: TRecorderMic140LegacyClient;
  out AErrorMessage: string): Boolean;
begin
  Result := False;
  AErrorMessage := '';
  if AClient = nil then
    Exit;
  AClient.TimeoutMs := CMic140LegacyCommandTimeoutMs;
  Result := AClient.StopScan(AErrorMessage);
  AClient.TimeoutMs := CMic140LegacyCommandTimeoutMs;
end;

procedure TRecorderMic140Device.LegacyRecoverTcpConnection;
var
  lErrorMessage: string;
begin
  if fLegacyClient = nil then
    Exit;
  try
    fLegacyClient.Disconnect;
  except
  end;
  try
    fLegacyClient.Connect;
    if fLegacyClient.ReadFirmware(fLegacyFirmware, lErrorMessage) then
    begin
      if not Mic140LegacyStopScanWithCommandTimeout(fLegacyClient, lErrorMessage) then
        Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy recover orphan stop failed: %s',
          [fHost, fPort, lErrorMessage]));
      fLegacyClient.ClearBufferedPackets;
      fLegacyScanWasStarted := False;
      Exit;
    end;
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy recover firmware read failed: %s',
      [fHost, fPort, lErrorMessage]));
  except
    on E: Exception do
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy recover connect failed: %s: %s',
        [fHost, fPort, E.ClassName, E.Message]));
  end;
end;

function TRecorderMic140Device.LegacyProbeScanRunning: Boolean;
var
  lBlock: TRecorderMic140LegacyScanBlock;
  lErrorMessage: string;
  lSavedTimeout: Cardinal;
begin
  Result := False;
  if fLegacyClient = nil then
    Exit;
  lSavedTimeout := fLegacyClient.TimeoutMs;
  try
    fLegacyClient.TimeoutMs := CMic140LegacyStartProbeTimeoutMs;
    Result := fLegacyClient.ReadScanBlock(lBlock, lErrorMessage) and
      (Length(lBlock.DataWords) > 0);
  finally
    fLegacyClient.TimeoutMs := lSavedTimeout;
  end;
end;

function TRecorderMic140Device.LegacyTrySoftRestartScan: Boolean;
var
  lErrorMessage: string;
  lFullReprogram: Boolean;
begin
  Result := False;
  if (fState <> rdsStarted) or (fLegacyClient = nil) then
    Exit;
  if fLegacyConsecutiveCorruptCount < CMic140LegacySoftRestartCorruptThreshold then
    Exit;
  if fLegacySoftRestartCount >= CMic140LegacySoftRestartMaxAttempts then
    Exit;
  Inc(fLegacySoftRestartCount);
  lFullReprogram := fLegacySoftRestartCount = CMic140LegacySoftRestartMaxAttempts;
  Mic140LogWarning(Format(
    '[MIC-140:%s:%d] Legacy scan soft restart %d/%d after %d consecutive corrupt reads (fullReprogram=%s)',
    [fHost, fPort, fLegacySoftRestartCount, CMic140LegacySoftRestartMaxAttempts,
     fLegacyConsecutiveCorruptCount, BoolToStr(lFullReprogram, True)]));
  fLegacyClient.TimeoutMs := CMic140LegacyCommandTimeoutMs;
  if not Mic140LegacyStopScanWithCommandTimeout(fLegacyClient, lErrorMessage) then
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy soft-restart stop failed: %s',
      [fHost, fPort, lErrorMessage]));
  fLegacyClient.ClearBufferedPackets;
  fLegacyStreamSequenceReset := True;
  fLegacyConsecutiveCorruptCount := 0;
  fLegacyReadPacketLogged := False;
  if lFullReprogram then
  begin
    fState := rdsConnected;
    ProgramDevice;
    if fState <> rdsProgrammed then
      Exit;
  end;
  if fLegacyClient.StartScan(lErrorMessage) then
  begin
    fLegacyScanWasStarted := True;
    fState := rdsStarted;
    Result := True;
    Exit;
  end;
  Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy soft-restart start failed: %s',
    [fHost, fPort, lErrorMessage]));
  fState := rdsConnected;
end;



function Mic140TryTransformTInSampleToJunctionC(ARegistry: TRecorderTagRegistry;
  ATemperatureTag: TRecorderTag; ADeviceSerial, ATInListIndex, ADevSubRev: Integer;
  ARawValue: Double; out AJunctionC: Double): Boolean;
var
  lCalName: string;
  lCalibration: TRecorderCalibration;
  lHardwareValue: Double;
  lGotHardware: Boolean;
begin
  Result := False;
  AJunctionC := 0.0;
  if ARegistry = nil then
    Exit;
  if (ATemperatureTag <> nil) and (not ATemperatureTag.HardwareCalibrationEnabled) then
    Exit;
  lGotHardware := False;
  if (ATemperatureTag <> nil) and ATemperatureTag.HardwareCalibrationEnabled and
    (Trim(ATemperatureTag.HardwareCalibrationName) <> '') then
  begin
    lHardwareValue := ARegistry.TransformTagHardwareValue(ATemperatureTag, ARawValue);
    lGotHardware := True;
  end
  else if RecorderMic140EnsureTInHardwareCalibration(ARegistry, ADeviceSerial,
    ATInListIndex, ADevSubRev, lCalName) then
  begin
    lCalibration := ARegistry.FindCalibrationByName(lCalName);
    if lCalibration <> nil then
    begin
      lHardwareValue := lCalibration.Transform(ARawValue);
      lGotHardware := True;
    end;
  end;
  if not lGotHardware then
    Exit;
  { ScanMIC140: tar->Eval(tc_->loc_data) only when T has its own tare; otherwise
    tc_->loc_data is junction temperature in degC from TIn hardware. }
  if Mic140TagHasThermocoupleCalibration(ARegistry, ATemperatureTag) then
    AJunctionC := ARegistry.TransformTagThermocoupleValue(ATemperatureTag,
      lHardwareValue)
  else
    AJunctionC := lHardwareValue;
  Result := Mic140JunctionTemperatureLooksValid(AJunctionC);
end;

function Mic140TransformThermocoupleChannelSample(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; AChannelIndex: Integer; ARawCode, AColdJunctionC: Double): Double;
var
  lChannelMv: Double;
  lCorrectedMv: Double;
  lJunctionC: Double;
  lJunctionMv: Double;
  lSettings: TRecorderMic140ChannelSettings;
  lChannelNumber: Integer;
  lCjcOffsetC: Double;
begin
  if (ARegistry = nil) or (ATag = nil) then
    Exit(ARawCode);
  if not ATag.HardwareCalibrationEnabled then
    Exit(ARawCode);
  { 1. Код АЦП -> мВ (аппаратная ГХ канала). }
  lChannelMv := ARegistry.TransformTagHardwareValue(ATag, ARawCode);
  if not Mic140TagHasThermocoupleCalibration(ARegistry, ATag) then
    Exit(lChannelMv);
  if AColdJunctionC <= CMic140CjcNotAvailable * 0.5 then
    Exit(ARegistry.TransformTagThermocoupleValue(ATag, lChannelMv));
  if not Mic140JunctionTemperatureLooksValid(AColdJunctionC) then
    Exit(ARegistry.TransformTagThermocoupleValue(ATag, lChannelMv));
  lCjcOffsetC := 0.0;
  if RecorderMic140TryGetChannelSettings(ARegistry, ATag, lChannelNumber,
    lSettings) then
    lCjcOffsetC := lSettings.CjcTemperOffsetC;
  { 2. По T_КТХС найти мВ на ГХ термопары и прибавить к мВ канала. }
  lJunctionC := AColdJunctionC + lCjcOffsetC;
  if not ARegistry.InvertTagThermocoupleValue(ATag, lJunctionC, lJunctionMv) then
    Exit(ARegistry.TransformTagThermocoupleValue(ATag, lChannelMv));
  lCorrectedMv := lChannelMv + lJunctionMv;
  { 3. Скорректированные мВ -> °C по ГХ термопары. }
  Result := ARegistry.TransformTagThermocoupleValue(ATag, lCorrectedMv);
end;

function Mic140TryGetColdJunctionTemperature(ARegistry: TRecorderTagRegistry;
  ATemperatureTag: TRecorderTag; const AAux: TMic140AuxTemperatureBlock;
  ACjcChannel, ADeviceSerial, ADevSubRev: Integer;
  out ATemperatureC: Double): Boolean;
var
  I: Integer;
  lCjcIndex: Integer;
  lCount: Integer;
  lSampleJunctionC: Double;
  lSum: Double;
begin
  Result := False;
  ATemperatureC := CMic140CjcNotAvailable;
  lCjcIndex := ACjcChannel - 1;
  if (ARegistry = nil) or (lCjcIndex < 0) or
    (lCjcIndex >= AAux.ChannelCount) or
    (lCjcIndex >= Length(AAux.Values)) then
    Exit;

  lSum := 0;
  lCount := 0;
  for I := 0 to AAux.SampleCount - 1 do
    if (lCjcIndex < Length(AAux.Valid)) and
      (I < Length(AAux.Valid[lCjcIndex])) and
      AAux.Valid[lCjcIndex][I] and
      (I < Length(AAux.Values[lCjcIndex])) then
    begin
      if Mic140TryTransformTInSampleToJunctionC(ARegistry, ATemperatureTag,
        ADeviceSerial, lCjcIndex, ADevSubRev,
        AAux.Values[lCjcIndex][I], lSampleJunctionC) then
      begin
        lSum := lSum + lSampleJunctionC;
        Inc(lCount);
      end;
    end;
  if lCount <= 0 then
    Exit;
  ATemperatureC := lSum / lCount;
  Result := True;
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

function RecorderMic140QueryHardwareCalibrSerial(const AHost: string; APort: Word;
  out ACalibrSerial: Integer): Boolean;
var
  lClient: TRecorderMic140LegacyClient;
  lErrorMessage: string;
  lFirmware: TRecorderMic140LegacyFirmware;
begin
  Result := False;
  ACalibrSerial := 0;
  lClient := TRecorderMic140LegacyClient.Create(AHost, APort, 5000);
  try
    lClient.Connect;
    if lClient.ReadFirmware(lFirmware, lErrorMessage) then
    begin
      ACalibrSerial := RecorderMic140HardwareCalibrSerialFromFirmware(lFirmware);
      Result := ACalibrSerial > 0;
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
      ADeviceSerial := RecorderMic140DisplaySerialFromFirmware(lFirmware, AHost);
      AVersionText := RecorderMic140FirmwareVersionText(lFirmware);
      ADevSubRev := RecorderMic140DevSubRevFromFirmware(lFirmware);
      Result := (ADeviceSerial > 0) or (AVersionText <> '');
    end;
  finally
    lClient.Free;
  end;
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
  ASettings.SoftBalance := 0;
  ASettings.CjcTemperOffsetC := 0.0;
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

function RecorderMic140TagEffectiveCjcChannel(ATag: TRecorderTag;
  AChannelIndex, ADevSubRev: Integer): Integer;
var
  lSettings: TRecorderMic140ChannelSettings;
begin
  RecorderMic140InitChannelSettings(lSettings, AChannelIndex, ADevSubRev);
  if ATag <> nil then
  begin
    lSettings.DefaultCjc := ATag.Mic140CjcDefault;
    if (not ATag.Mic140CjcDefault) and
      (ATag.Mic140CjcChannel >= 1) and
      (ATag.Mic140CjcChannel <= MIC140TemperatureChannelCount) then
      lSettings.CjcChannel := ATag.Mic140CjcChannel;
  end;
  Result := RecorderMic140ChannelCjcNumber(lSettings, AChannelIndex, ADevSubRev);
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
  lScaleKey: string;
begin
  if not RecorderMic140ChannelUsesTemperature(ASettings) then
    Exit('');
  lScaleKey := RecorderMeraResolveThermocoupleScaleKey(
    ASettings.ThermocoupleScalePath, ASettings.ThermocoupleScaleName);
  lIdx := ASettings.RangeIndex;
  if (lIdx < 0) or (lIdx >= CMic140RangeCount) then
    lIdx := CMic140Range100mV;
  lMinMv := CRangeMinMax[lIdx].MinV * 1000.0;
  lMaxMv := CRangeMinMax[lIdx].MaxV * 1000.0;
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderSdbLoadScaleCalibration(lScaleKey, lCalibration) then
      Exit('');
    lMinC := lCalibration.Transform(lMinMv);
    lMaxC := lCalibration.Transform(lMaxMv);
    if RecorderMeraThermocoupleDstRange(lScaleKey, lDstMin, lDstMax) then
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
  lResolvedKey: string;
begin
  if ATag = nil then
    Exit;
  if (ATag.MeasRangeIndex >= 0) and (ATag.MeasRangeIndex < CMic140RangeCount) then
    ASettings.RangeIndex := ATag.MeasRangeIndex;
  ASettings.SoftBalance := ATag.Mic140SoftBalance;
  ASettings.DefaultCjc := ATag.Mic140CjcDefault;
  if (ATag.Mic140CjcChannel >= 1) and
    (ATag.Mic140CjcChannel <= MIC140TemperatureChannelCount) then
    ASettings.CjcChannel := ATag.Mic140CjcChannel;
  if Trim(ATag.Mic140ThermocoupleScaleName) <> '' then
  begin
    ASettings.ThermocoupleScaleName := ATag.Mic140ThermocoupleScaleName;
    ASettings.ThermocoupleScalePath := ATag.Mic140ThermocoupleScalePath;
    if Trim(ASettings.ThermocoupleScalePath) = '' then
      ASettings.ThermocoupleScalePath :=
        RecorderMeraThermocoupleRelativePath(ASettings.ThermocoupleScaleName);
    lResolvedKey := RecorderMeraResolveThermocoupleScaleKey(
      ASettings.ThermocoupleScalePath, ASettings.ThermocoupleScaleName);
    if lResolvedKey <> '' then
      ASettings.ThermocoupleScalePath := lResolvedKey;
    Exit;
  end;
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
  lScaleKey: string;
begin
  Result := '';
  if (ARegistry = nil) or (not RecorderMic140ChannelUsesTemperature(ASettings)) then
    Exit;
  lScaleKey := RecorderMeraResolveThermocoupleScaleKey(
    ASettings.ThermocoupleScalePath, ASettings.ThermocoupleScaleName);
  if lScaleKey = '' then
    Exit;
  lCalibration := TRecorderCalibration.Create(rckPiecewiseLinear);
  try
    if not RecorderMeraLoadThermocoupleCalibration(ASettings.ThermocoupleScalePath,
      ASettings.ThermocoupleScaleName, lCalibration) then
      Exit;
    lCalibration.Extrapolation := True;
    lCalibration.UnitIn := 'mV';
    lCalibration.UnitOut := 'degC';
    lName := 'TC ' + ASettings.ThermocoupleScaleName;
    lCalibration.Name := lName;
    lCalibration.Description := lScaleKey;
    if RecorderMic140UpsertHardwareCalibration(ARegistry, lName, lCalibration) <> nil then
      Result := lName;
  finally
    lCalibration.Free;
  end;
end;



function TRecorderMic140Device.GetDeviceSerial: Integer;
begin
  if fUseLegacyProtocol then
  begin
    if fHardwareCalibrSerial > 0 then
      Exit(fHardwareCalibrSerial);
    Result := RecorderMic140HardwareCalibrSerialFromFirmware(fLegacyFirmware);
  end
  else
    Result := 0;
end;

function TRecorderMic140Device.GetLegacyFirmware(
  out AFirmware: TRecorderMic140LegacyFirmware): Boolean;
begin
  Result := fUseLegacyProtocol and (fLegacyFirmware.DevType > 0);
  if Result then
    AFirmware := fLegacyFirmware;
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
  CMaskChanLeft = Word($8000);
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
  lFifoPage: Word;
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
  lMe048W0: Word;
  lMe048W1: Word;
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

  // Original ScanModule::CreateBiosCCScanBuf uses size = 2 * sizeready in the
  // FIFO descriptor (double-buffered half of the ready portion), not the full
  // Ethernet DM span. Oversizing this field was linked to unstable scan blocks.
  // scan. If the previous run ended abnormally, this drains the old BIOS scan
  // state before RESETSCANMAIN and descriptor writes.
  fLegacyClient.TimeoutMs := CMic140LegacyCommandTimeoutMs;
  if not Mic140LegacyStopScanWithCommandTimeout(fLegacyClient, lStopErrorMessage) then
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy pre-program stop failed: %s',
      [fHost, fPort, lStopErrorMessage]));
  fLegacyClient.ClearBufferedPackets;
  fLegacyScanWasStarted := False;

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

  if not LegacyAllocBuffer(2 * lFifoReadyWords, lFifoPage, lFifoAddr) then
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
  lArgs[5] := lFifoPage;
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

  if not LegacyAllocHeap(fChannelCount, lPage, lValueAddr) then
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
    if I < fChannelCount then
    begin
      if I <= High(CAInNum48) then
        Mic140LegacyMe048ForPhysicalChannel(CAInNum48[I], lMe048W0, lMe048W1)
      else
      begin
        lMe048W0 := 0;
        lMe048W1 := 0;
      end;
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 0] := lMe048W0;
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 1] := lMe048W1;
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
        Word(CMaskChanLeft or (lValueAddr + 48 + lTemperatureIndex));
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
  // ModuleMIC140_48 keeps m_ChanDump[2] as channels.Size(): the number of
  // user channels shown at the top level. Internal TIn descriptors still
  // participate in the BIOS descriptor table and FIFO stride below.
  lChanDump[2] := Word(fChannelCount);
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
  fHardwareCalibrSerial := 0;
  fLegacyReadErrorLogged := False;
  fLegacyReadFailureCount := 0;
  fLegacyScanWasStarted := False;
  fLegacyReadStallRestartCount := 0;
  fLegacyClient := TRecorderMic140LegacyClient.Create(fHost, fPort, 5000);
  fLegacyReadBlockCount := 0;
  fLegacyReadPacketLogged := False;
  fLegacyLastNumBuffValid := False;
  fLegacyLastReadTickValid := False;
  fLegacyLastGoodRawBlockValid := False;
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
      fHardwareCalibrSerial :=
        RecorderMic140HardwareCalibrSerialFromFirmware(fLegacyFirmware);
      if not Mic140LegacyStopScanWithCommandTimeout(fLegacyClient, lErrorMessage) then
        Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy orphan StopScan on connect failed: %s',
          [fHost, fPort, lErrorMessage]))
      else
        Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy orphan StopScan on connect completed',
          [fHost, fPort]));
      fLegacyClient.ClearBufferedPackets;
      fLegacyScanWasStarted := False;
      fStopRequested := False;
      fState := rdsConnected;
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy Ethernet protocol detected: devType=%d devRev=%d devSerNo=%d ccType=%d ccSerNo=%d BIOS=%d.%d hardwareCalibrSerial=%d',
        [fHost, fPort, fLegacyFirmware.DevType, fLegacyFirmware.DevRevNo,
         fLegacyFirmware.DevSerNo, fLegacyFirmware.CCType,
         fLegacyFirmware.CCSerNo, fLegacyFirmware.BiosFunction,
         fLegacyFirmware.BiosVersion, fHardwareCalibrSerial]));
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
      end;
    end;
  end;
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
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy MIC-140 scan programmed: channels=%d scanStride=%d chanDumpCount=%d chanPtrs=%d descSlots=%d freq=%.3f Hz timerScale=%d timerPeriod=%d scanDivider=%d wait=%.3f us ground=%.3f us avgPeriod=%.3f us avgCount=%d sportWait=%d sportGround=%d sportAvg=%d fifoBegin=0x%.4x fifoEnd=0x%.4x fifoReadyWords=%d fifoCapacityWords=%d',
        [fHost, fPort, fChannelCount, LegacyInternalScanChannelCount, fChannelCount,
         LegacyInternalScanChannelCount * 2, LegacyInternalScanChannelCount + 1,
         fPollFrequencyHz,
         LegacyTimerScale, LegacyTimerPeriod, LegacyCalcScanDivider,
         lTiming.ChannelCommutationUs, lTiming.GroundCommutationUs,
         lTiming.AveragePeriodUs, lTiming.AverageSampleCount,
         lTiming.LegacyChannelDelaySport - 1,
         lTiming.LegacyGroundDelaySport - 1,
         lTiming.LegacyAverageDelaySport - 1,
         CMic140LegacyDmBufferBegin,
         CMic140LegacyDmBufferEnd,
         LegacyCalcFifoReadyWords, 2 * LegacyCalcFifoReadyWords]));
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
  fHardwareCalibrSerial := 0;
  FillChar(fLegacyFirmware, SizeOf(fLegacyFirmware), 0);
  fLegacyReadErrorLogged := False;
  fLegacyReadFailureCount := 0;
      fLegacyReadBlockCount := 0;
      fLegacyReadPacketLogged := False;
      fLegacyLastNumBuffValid := False;
      fLegacyLastReadTickValid := False;
      fLegacyLastGoodRawBlockValid := False;
  fLegacyScanWasStarted := False;
  fStopRequested := False;
  fState := rdsDisconnected;
end;

procedure TRecorderMic140Device.Start;
var
  lAttempt: Integer;
  lErrorMessage: string;
  lStartCmdOk: Boolean;
  lUsedProbe: Boolean;
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
    for lAttempt := 1 to CMic140LegacyStartAttempts do
    begin
      fLegacyClient.ClearBufferedPackets;
      fLegacyClient.TimeoutMs := CMic140LegacyStartCommandTimeoutMs;
      lStartCmdOk := fLegacyClient.StartScan(lErrorMessage);
      lUsedProbe := False;
      if not lStartCmdOk then
        lUsedProbe := LegacyProbeScanRunning;
      if lStartCmdOk or lUsedProbe then
      begin
        fLegacyClient.TimeoutMs := CMic140LegacyCommandTimeoutMs;
        fSampleIndex := 0;
        fLegacyReadFailureCount := 0;
        fLegacyReadBlockCount := 0;
        fLegacyReadPacketLogged := False;
        fLegacyLastNumBuffValid := False;
        fLegacyLastReadTickValid := False;
        fLegacyLastGoodRawBlockValid := False;
        fLegacyNumBuffGapCount := 0;
        fLegacyDuplicateNumBuffCount := 0;
        fLegacyCorruptReadCount := 0;
        fLegacyConsecutiveCorruptCount := 0;
        fLegacySoftRestartCount := 0;
        fLegacyScanWasStarted := True;
        fStopRequested := False;
        fState := rdsStarted;
        Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy CC BIOS scan start accepted: command=%d attempt=%d probe=%s',
          [fHost, fPort, MIC140_LEGACY_CMD_START_SCAN_MAIN, lAttempt,
           BoolToStr(lUsedProbe, True)]));
        Exit;
      end;
      fLegacyClient.TimeoutMs := CMic140LegacyCommandTimeoutMs;
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy scan start failed (attempt %d/%d): %s',
        [fHost, fPort, lAttempt, CMic140LegacyStartAttempts, lErrorMessage]));
      if not Mic140LegacyStopScanWithCommandTimeout(fLegacyClient, lErrorMessage) then
        Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy start-recovery stop failed: %s',
          [fHost, fPort, lErrorMessage]));
      fLegacyClient.ClearBufferedPackets;
      fLegacyScanWasStarted := False;
      if lAttempt < CMic140LegacyStartAttempts then
      begin
        LegacyRecoverTcpConnection;
        fState := rdsConnected;
        ProgramDevice;
        if fState <> rdsProgrammed then
          Break;
      end;
    end;
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
  end;
  fState := rdsConnected;
end;

procedure TRecorderMic140Device.RequestStopAcquisition;
begin
  fStopRequested := True;
end;

procedure TRecorderMic140Device.ClearLegacyScanBuffer;
begin
  if fLegacyClient <> nil then
    fLegacyClient.ClearBufferedPackets;
  fLegacyLastNumBuffValid := False;
  fLegacyLastReadTickValid := False;
  fLegacyLastGoodRawBlockValid := False;
end;

procedure TRecorderMic140Device.Stop;
var
  lErrorMessage: string;
begin
  fStopRequested := True;
  if fUseLegacyProtocol and (fLegacyClient <> nil) and
     ((fState = rdsStarted) or fLegacyScanWasStarted) then
  begin
    // LegacyReadThread drains queued packets with ReadBlock(0); that intentionally uses
    // a 1 ms receive timeout. StopScan shares the same socket, so force a
    // command timeout before sending CMD_STOPSCANMAIN and keep it afterwards.
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy StopScan begin: command=%d timeout=%d ms readBlocks=%d',
      [fHost, fPort, MIC140_LEGACY_CMD_STOP_SCAN_MAIN,
       CMic140LegacyCommandTimeoutMs, fLegacyReadBlockCount]));
    if not Mic140LegacyStopScanWithCommandTimeout(fLegacyClient, lErrorMessage) then
      Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy scan stop failed: %s',
        [fHost, fPort, lErrorMessage]))
    else
      Mic140LogWarning(Format(
        '[MIC-140:%s:%d] Legacy StopScan completed: readBlocks=%d lastNumBuff=%d readGaps=%d dupRead=%d corruptRead=%d mdpResync=%d',
        [fHost, fPort, fLegacyReadBlockCount, fLegacyLastNumBuff,
         fLegacyNumBuffGapCount, fLegacyDuplicateNumBuffCount, fLegacyCorruptReadCount,
         LegacyMdpResyncByteCount]));
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

function TRecorderMic140Device.RunServiceZeroBalance(
  const AChannelNumbers: array of Integer; APollFrequencyHz: Double;
  out AMeans: TRecorderDoubleArray; out AErrorMessage: string): Boolean;
var
  lBlock: TRecorderDeviceSampleBlock;
  lChannelIdx: Integer;
  lCounts: array of Integer;
  lEffectiveCounts: array of Integer;
  lI, lJ, lK: Integer;
  lNeedMore: Boolean;
  lSavedPollHz: Double;
  lSums: array of Double;
  lTargetSamples: Integer;
  lTimeoutAt: QWord;
begin
  Result := False;
  AErrorMessage := '';
  SetLength(AMeans, Length(AChannelNumbers));
  if Length(AChannelNumbers) = 0 then
  begin
    AErrorMessage := 'Не указаны каналы для балансировки';
    Exit;
  end;

  SetLength(lSums, Length(AChannelNumbers));
  SetLength(lCounts, Length(AChannelNumbers));
  SetLength(lEffectiveCounts, Length(AChannelNumbers));

  lTargetSamples := Max(CMic140BalanceMinSamples,
    Round(CMic140BalanceSampleFraction * APollFrequencyHz));
  lSavedPollHz := fPollFrequencyHz;
  fPollFrequencyHz := RecorderMic140NormalizeFrequency(APollFrequencyHz);

  try
    if fState = rdsStarted then
      Stop;
    if fState = rdsDisconnected then
      Connect;
    if fState = rdsDisconnected then
    begin
      AErrorMessage := 'Не удалось подключиться к MIC-140';
      Exit;
    end;
    ProgramDevice;
    if fState <> rdsProgrammed then
    begin
      AErrorMessage := 'Не удалось запрограммировать MIC-140 для служебного сбора';
      Exit;
    end;
    Start;
    if fState <> rdsStarted then
    begin
      AErrorMessage := 'Не удалось запустить служебный опрос MIC-140';
      Exit;
    end;

    lTimeoutAt := GetTickCount64 + 20000;
    while GetTickCount64 < lTimeoutAt do
    begin
      lNeedMore := False;
      for lJ := 0 to High(lEffectiveCounts) do
        if lEffectiveCounts[lJ] < lTargetSamples then
        begin
          lNeedMore := True;
          Break;
        end;
      if not lNeedMore then
        Break;
      if not ReadBlock(500, lBlock) then
        Continue;
      for lI := 0 to lBlock.SampleCount - 1 do
      begin
        for lJ := 0 to High(AChannelNumbers) do
        begin
          lChannelIdx := AChannelNumbers[lJ] - 1;
          if (lChannelIdx < 0) or (lChannelIdx >= lBlock.ChannelCount) then
            Continue;
          Inc(lCounts[lJ]);
          if lCounts[lJ] <= CMic140BalanceDiscardSamples then
            Continue;
          if lEffectiveCounts[lJ] >= lTargetSamples then
            Continue;
          lSums[lJ] := lSums[lJ] + lBlock.Values[lChannelIdx][lI];
          Inc(lEffectiveCounts[lJ]);
        end;
      end;
    end;

    Stop;
    for lJ := 0 to High(AChannelNumbers) do
    begin
      if lEffectiveCounts[lJ] < lTargetSamples then
      begin
        AErrorMessage := Format('Канал %d: недостаточно данных для балансировки (%d из %d)',
          [AChannelNumbers[lJ], lEffectiveCounts[lJ], lTargetSamples]);
        Exit;
      end;
      AMeans[lJ] := lSums[lJ] / lEffectiveCounts[lJ];
    end;
    Result := True;
  finally
    fPollFrequencyHz := lSavedPollHz;
    if fState <> rdsDisconnected then
      Disconnect;
  end;
end;

function TRecorderMic140Device.ReadLegacyRawBlock(ATimeoutMs: Cardinal;
  out ARaw: TMic140LegacyRawBlock): Boolean;
var
  lDataWords: Integer;
  lErrorMessage: string;
  lInternalChannelCount: Integer;
  lLegacyBlock: TRecorderMic140LegacyScanBlock;
  lSampleCount: Integer;
  lSincePrevMs: QWord;
begin
  FillChar(ARaw, SizeOf(ARaw), 0);
  Result := False;
  if fState <> rdsStarted then
    Exit;
  if not fUseLegacyProtocol then
    Exit;
  if fLegacyClient = nil then
    Exit;
  if fStopRequested then
  begin
    if ATimeoutMs = 0 then
      fLegacyClient.TimeoutMs := 1
    else if ATimeoutMs > CMic140StopReadTimeoutMs then
      fLegacyClient.TimeoutMs := CMic140StopReadTimeoutMs
    else
      fLegacyClient.TimeoutMs := ATimeoutMs;
  end
  else
    fLegacyClient.TimeoutMs := ATimeoutMs;
  if not fLegacyClient.ReadScanBlock(lLegacyBlock, lErrorMessage) then
  begin
    if ATimeoutMs > 0 then
    begin
      Inc(fLegacyReadFailureCount);
      if fLegacyReadFailureCount = 1 then
        RecorderDebugLog(Format(
          '[MIC-140:%s:%d] Legacy scan read timeout after %d good blocks (will retry): %s',
          [fHost, fPort, fLegacyReadBlockCount, lErrorMessage]))
      else
      if (fLegacyReadFailureCount >= CMic140LegacyReadTimeoutWarnAfter) and
        (not fLegacyReadErrorLogged) then
      begin
        Mic140LogWarning(Format(
          '[MIC-140:%s:%d] Legacy scan read failed after %d reads (%d timeouts): %s mdpResync=%d. The scan is left running; Stop/Disconnect will send StopScan explicitly.',
          [fHost, fPort, fLegacyReadBlockCount, fLegacyReadFailureCount,
           lErrorMessage, LegacyMdpResyncByteCount]));
        fLegacyReadErrorLogged := True;
      end;
    end;
    Exit;
  end;
  fLegacyReadErrorLogged := False;
  fLegacyReadFailureCount := 0;
  if Length(lLegacyBlock.HeaderWords) < CMic140LegacyBiosHeaderWords then
    Exit;
  Move(lLegacyBlock.HeaderWords[0], ARaw.Header[0],
    CMic140LegacyBiosHeaderWords * SizeOf(Word));
  lDataWords := Length(lLegacyBlock.DataWords);
  if lDataWords > CMic140LegacyMaxScanDataWords then
    lDataWords := CMic140LegacyMaxScanDataWords;
  if lDataWords > 0 then
    Move(lLegacyBlock.DataWords[0], ARaw.Data[0], lDataWords * SizeOf(Word));
  ARaw.DataWordCount := Word(lDataWords);
  lInternalChannelCount := LegacyInternalScanChannelCount;
  lSampleCount := lDataWords div lInternalChannelCount;
  if lSampleCount <= 0 then
  begin
    Mic140LogWarning(Format(
      '[MIC-140:%s:%d] Legacy scan packet has no full samples: dataWords=%d stride=%d userChannels=%d',
      [fHost, fPort, lDataWords, lInternalChannelCount, fChannelCount]));
    Exit;
  end;
  Inc(fLegacyReadBlockCount);
  ARaw.ReadSerial := fLegacyReadBlockCount;
  fLegacyReadStallRestartCount := 0;
  lSincePrevMs := LegacyNoteReadSincePrevMs;
  CheckLegacyNumBuffOnRead(ARaw, lSincePrevMs);
  if not fLegacyLastNumBuffValid then
  begin
    Dec(fLegacyReadBlockCount);
    Exit;
  end;
  if Mic140LegacyRawBlockLooksCorrupt(ARaw, fChannelCount) and
    fLegacyLastGoodRawBlockValid and
    (fLegacyLastGoodRawBlock.DataWordCount = ARaw.DataWordCount) then
  begin
    Move(fLegacyLastGoodRawBlock.Data[0], ARaw.Data[0],
      ARaw.DataWordCount * SizeOf(Word));
    Mic140LogWarning(Format(
      '[MIC-140:%s:%d] Legacy scan payload replaced with last good block: readSerial=%d num_buff=%d words=%d',
      [fHost, fPort, ARaw.ReadSerial, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
       ARaw.DataWordCount]));
  end
  else if not Mic140LegacyRawBlockLooksCorrupt(ARaw, fChannelCount) then
  begin
    fLegacyLastGoodRawBlock := ARaw;
    fLegacyLastGoodRawBlockValid := True;
  end;
  LogLegacyScanBlockDetail(ARaw, lSincePrevMs);
  ARaw.FirstSampleIndex := fSampleIndex;
  Inc(fSampleIndex, lSampleCount);
  Result := True;
end;

function TRecorderMic140Device.LegacyDecommutateRawBlock(
  const ARaw: TMic140LegacyRawBlock; out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  I: Integer;
  J: Integer;
  lDataIndex: Integer;
  lInternalChannelCount: Integer;
begin
  ClearRecorderDeviceSampleBlock(ABlock);
  ClearMic140AuxTemperatureBlock(fLastAuxTemperature);
  Result := False;
  lInternalChannelCount := LegacyInternalScanChannelCount;
  ABlock.ChannelCount := fChannelCount;
  if ABlock.ChannelCount <= 0 then
    Exit;
  ABlock.SampleCount := ARaw.DataWordCount div lInternalChannelCount;
  if ABlock.SampleCount <= 0 then
    Exit;
  ABlock.SampleRateHz := fPollFrequencyHz;
  ABlock.FirstTimeSec := ARaw.FirstSampleIndex / fPollFrequencyHz;
  SetLength(ABlock.Values, ABlock.ChannelCount);
  for I := 0 to ABlock.ChannelCount - 1 do
    SetLength(ABlock.Values[I], ABlock.SampleCount);
  for J := 0 to ABlock.SampleCount - 1 do
    for I := 0 to ABlock.ChannelCount - 1 do
    begin
      lDataIndex := J * lInternalChannelCount + I;
      ABlock.Values[I][J] := SmallInt(ARaw.Data[lDataIndex]);
    end;
  fLastAuxTemperature.ChannelCount := MIC140TemperatureChannelCount;
  fLastAuxTemperature.SampleCount := ABlock.SampleCount;
  SetLength(fLastAuxTemperature.Values, fLastAuxTemperature.ChannelCount);
  SetLength(fLastAuxTemperature.Valid, fLastAuxTemperature.ChannelCount);
  for I := 0 to fLastAuxTemperature.ChannelCount - 1 do
  begin
    SetLength(fLastAuxTemperature.Values[I], ABlock.SampleCount);
    SetLength(fLastAuxTemperature.Valid[I], ABlock.SampleCount);
    for J := 0 to ABlock.SampleCount - 1 do
    begin
      lDataIndex := J * lInternalChannelCount + fChannelCount + I;
      fLastAuxTemperature.Valid[I][J] := lDataIndex < ARaw.DataWordCount;
      if fLastAuxTemperature.Valid[I][J] then
        fLastAuxTemperature.Values[I][J] := SmallInt(ARaw.Data[lDataIndex]);
    end;
  end;
  Result := True;
end;

function TRecorderMic140Device.LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;
begin
  Result := fLastAuxTemperature;
end;

function TRecorderMic140Device.LegacyStreamReadCount: Int64;
begin
  Result := fLegacyReadBlockCount;
end;

function TRecorderMic140Device.LegacyNumBuffGapCount: Integer;
begin
  Result := fLegacyNumBuffGapCount;
end;

function TRecorderMic140Device.LegacyDuplicateNumBuffCount: Integer;
begin
  Result := fLegacyDuplicateNumBuffCount;
end;

function TRecorderMic140Device.LegacyCorruptReadCount: Integer;
begin
  Result := fLegacyCorruptReadCount;
end;

function TRecorderMic140Device.LegacyTryRestartStreamAfterReadStall: Boolean;
var
  lErrorMessage: string;
  lFullReprogram: Boolean;
begin
  Result := False;
  if (fState <> rdsStarted) or (fLegacyClient = nil) or fStopRequested then
    Exit;
  if fLegacyReadStallRestartCount >= CMic140LegacyReadStallRestartMaxAttempts then
    Exit;
  Inc(fLegacyReadStallRestartCount);
  lFullReprogram := fLegacyReadStallRestartCount >= CMic140LegacyReadStallRestartMaxAttempts;
  Mic140LogWarning(Format(
    '[MIC-140:%s:%d] Legacy scan read stall restart %d/%d after %d blocks (fullReprogram=%s)',
    [fHost, fPort, fLegacyReadStallRestartCount, CMic140LegacyReadStallRestartMaxAttempts,
     fLegacyReadBlockCount, BoolToStr(lFullReprogram, True)]));
  if not Mic140LegacyStopScanWithCommandTimeout(fLegacyClient, lErrorMessage) then
    Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy stall-restart stop failed: %s',
      [fHost, fPort, lErrorMessage]));
  fLegacyClient.ClearBufferedPackets;
  fLegacyStreamSequenceReset := True;
  fLegacyReadPacketLogged := False;
  fLegacyLastNumBuffValid := False;
  fLegacyLastReadTickValid := False;
  if lFullReprogram then
  begin
    fState := rdsConnected;
    ProgramDevice;
    if fState <> rdsProgrammed then
      Exit;
  end;
  if fLegacyClient.StartScan(lErrorMessage) then
  begin
    fLegacyScanWasStarted := True;
    fState := rdsStarted;
    Result := True;
    Exit;
  end;
  Mic140LogWarning(Format('[MIC-140:%s:%d] Legacy stall-restart start failed: %s',
    [fHost, fPort, lErrorMessage]));
  fState := rdsConnected;
end;

function TRecorderMic140Device.LegacyMdpResyncByteCount: Int64;
begin
  if fLegacyClient <> nil then
    Result := fLegacyClient.MdpResyncByteCount
  else
    Result := 0;
end;

function TRecorderMic140Device.LegacyConsumeStreamSequenceReset: Boolean;
begin
  Result := fLegacyStreamSequenceReset;
  fLegacyStreamSequenceReset := False;
end;

function TRecorderMic140Device.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
var
  I: Integer;
  J: Integer;
  lRaw: TRecorderMebiusFloatBlock;
  lLegacyRaw: TMic140LegacyRawBlock;
begin
  ClearRecorderDeviceSampleBlock(ABlock);
  Result := False;
  if fState <> rdsStarted then
    Exit;
  if fUseLegacyProtocol then
  begin
    if not ReadLegacyRawBlock(ATimeoutMs, lLegacyRaw) then
      Exit;
    Result := LegacyDecommutateRawBlock(lLegacyRaw, ABlock);
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
  lNodeNumber: Integer;
begin
  inherited Create(ASourceId, 'MIC-140', AUpdateTimeMs);
  fLastStatusCode := Low(Integer);
  fOutputMode := AOutputMode;
  fPollFrequencyHz := RecorderMic140NormalizeFrequency(APollFrequencyHz);
  fCjcCorrectLogWritten := False;
  fTemperatureModeWarningLogged := False;
  fDeviceSerial := 0;
  fLastRawBlockValid := False;
  lNodeNumber := MIC140DefaultNodeNumber;
  fStatusTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'status');
  fBlockCountTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'blocks');
  fChannelTagNames := TStringList.Create;
  fChannelTagNames.CaseSensitive := False;
  fChannelTagNames.Sorted := False;
  fTemperatureTagNames := TStringList.Create;
  fTemperatureTagNames.CaseSensitive := False;
  fTemperatureTagNames.Sorted := False;
  fTagNames := TStringList.Create;
  fTagNames.CaseSensitive := False;
  fTagNames.Sorted := False;
  if ATagNames <> nil then
    fTagNames.Assign(ATagNames);
  fMic140Device := TRecorderMic140Device.Create(ASourceId, AHost, APort,
    AChannelCount, APollFrequencyHz, AUpdateTimeMs);
  fDevice := fMic140Device;
  lNodeNumber := fMic140Device.GetNodeNumber;
  fStatusTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'status');
  fBlockCountTagName := RecorderMic140DiagnosticTagName(lNodeNumber, 'blocks');
  RebuildTemperatureTagNames;
  fRawBuffer := TMic140RawDoubleBuffer.Create;
  fAcquireTiming := TRecorderMic140AcquireTiming.Create(APollFrequencyHz, AUpdateTimeMs);
  fStreamFsm := TMic140StreamFsm.Create(fAcquireTiming);
  fScanConfig := TRecorderMic140ScanConfig.Create(AChannelCount, APollFrequencyHz, AUpdateTimeMs);
  fHardwarePrepared := False;
  fHardwarePrepareAttempted := False;
  fLastRingOverloadLogTick := 0;
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
  const AAux: TMic140AuxTemperatureBlock; const ATimes: TRecorderDoubleArray);
var
  I: Integer;
  lJ: Integer;
  lTag: TRecorderTag;
  lValues: TRecorderDoubleArray;
begin
  if (Registry = nil) or (AAux.ChannelCount <= 0) or (AAux.SampleCount <= 0) then
    Exit;
  SetLength(lValues, AAux.SampleCount);
  for I := 0 to Min(AAux.ChannelCount, fTemperatureTagNames.Count) - 1 do
  begin
    if not TemperatureChannelSelected(I + 1) then
      Continue;
    lTag := Registry.FindByName(fTemperatureTagNames[I]);
    if lTag = nil then
      lTag := FindTagBySourceAddress(Registry, fTemperatureTagNames[I]);
    if lTag = nil then
      Continue;
    for lJ := 0 to AAux.SampleCount - 1 do
    begin
      if (I < Length(AAux.Valid)) and
        (lJ < Length(AAux.Valid[I])) and
        AAux.Valid[I][lJ] then
        lValues[lJ] := AAux.Values[I][lJ]
      else
        lValues[lJ] := 0;
    end;
    lTag.TextValue := FormatFloat('0.###', lValues[AAux.SampleCount - 1]);
    Registry.PublishBlock(lTag.Name, ATimes, lValues, AAux.SampleCount);
  end;
end;

destructor TRecorderMic140DataSource.Destroy;
begin
  StopBlockPublishThread;
  Stop;
  fScanConfig.Free;
  fStreamFsm.Free;
  fAcquireTiming.Free;
  fRawBuffer.Free;
  fMic140Device := nil;
  fDevice := nil;
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

function TRecorderMic140DataSource.TemperatureChannelSelected(
  AIndex: Integer): Boolean;
var
  lDisplayName: string;
begin
  Result := fTagNames.Count = 0;
  if Result then
    Exit;
  if (AIndex < 1) or (AIndex > fTemperatureTagNames.Count) then
    Exit(False);
  Result := fTagNames.IndexOf(fTemperatureTagNames[AIndex - 1]) >= 0;
  if Result then
    Exit;
  if fDeviceSerial > 0 then
  begin
    lDisplayName := RecorderMic140TemperatureDisplayName(fDeviceSerial, AIndex);
    Result := fTagNames.IndexOf(lDisplayName) >= 0;
  end;
end;

procedure TRecorderMic140DataSource.RebuildTemperatureTagNames;
var
  I: Integer;
begin
  fTemperatureTagNames.Clear;
  for I := 1 to MIC140TemperatureChannelCount do
    fTemperatureTagNames.Add(RecorderMic140TemperatureAddressText(fDeviceSerial, I));
end;

function TRecorderMic140DataSource.ChannelIndexForTag(ATag: TRecorderTag): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (ATag = nil) or (fChannelTagNames = nil) then
    Exit;
  for I := 0 to fChannelTagNames.Count - 1 do
    if SameText(fChannelTagNames[I], ATag.Name) then
      Exit(I);
end;

function TRecorderMic140DataSource.GetLastRawChannelMean(AChannelIndex: Integer;
  out AMean: Double): Boolean;
begin
  Result := False;
  if not fLastRawBlockValid then
    Exit;
  if (AChannelIndex < 0) or (AChannelIndex >= Length(fLastRawChannelMeans)) then
    Exit;
  AMean := fLastRawChannelMeans[AChannelIndex];
  Result := True;
end;

function TRecorderMic140DataSource.Mic140RawSample(
  const ABlock: TRecorderDeviceSampleBlock; AChannelIndex, ASampleIndex: Integer;
  ATag: TRecorderTag): Double;
begin
  Result := ABlock.Values[AChannelIndex][ASampleIndex];
  if (ATag <> nil) and (ATag.Mic140SoftBalance <> 0) then
    Result := Result - ATag.Mic140SoftBalance;
end;

function TRecorderMic140DataSource.ZeroBalanceTags(AOwner: TComponent; ATags: TList;
  AMessages: TStrings): Boolean;
var
  lFiltered: TList;
  I: Integer;
  lTag: TRecorderTag;
begin
  lFiltered := TList.Create;
  try
    for I := 0 to ATags.Count - 1 do
    begin
      lTag := TRecorderTag(ATags[I]);
      if SameText(lTag.SourceId, SourceId) then
        lFiltered.Add(lTag);
    end;
    Result := RecorderMic140ZeroBalanceTags(AOwner, Registry, lFiltered, nil,
      AMessages);
  finally
    lFiltered.Free;
  end;
end;

function RecorderMic140ZeroBalanceTags(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; ATags: TList;
  ADataSources: TRecorderDataSourceManager; AMessages: TStrings): Boolean;
var
  lChannelNumbers: array of Integer;
  lDevice: TRecorderMic140Device;
  lFreq: Double;
  lHost: string;
  lMeans: TRecorderDoubleArray;
  lMessages: TStringList;
  lPort: Word;
  lSourceId: string;
  lTag: TRecorderTag;
  lTempIndex: Integer;
  lErrorMessage: string;
  lWasRunning: Boolean;
  I, J, lChannelNumber: Integer;
begin
  Result := False;
  if (ATags = nil) or (ATags.Count = 0) then
    Exit;
  if AMessages = nil then
  begin
    lMessages := TStringList.Create;
    try
      Result := RecorderMic140ZeroBalanceTags(AOwner, ARegistry, ATags,
        ADataSources, lMessages);
      if lMessages.Count > 0 then
        MessageDlg('Балансировка нуля', lMessages.Text, mtInformation, [mbOK], 0);
    finally
      lMessages.Free;
    end;
    Exit;
  end;

  lSourceId := TRecorderTag(ATags[0]).SourceId;
  for I := 1 to ATags.Count - 1 do
    if not SameText(TRecorderTag(ATags[I]).SourceId, lSourceId) then
    begin
      AMessages.Add('Все теги должны принадлежать одному источнику MIC-140');
      Exit;
    end;
  if not TryParseRecorderMic140SourceId(lSourceId, lHost, lPort) then
  begin
    AMessages.Add('Источник не является MIC-140');
    Exit;
  end;

  SetLength(lChannelNumbers, 0);
  lFreq := MIC140DefaultPollFrequencyHz;
  for I := 0 to ATags.Count - 1 do
  begin
    lTag := TRecorderTag(ATags[I]);
    if ParseMic140TemperatureChannelIndex(lTag.Address, lTempIndex) then
    begin
      AMessages.Add(Format('%s: балансировка недоступна для T-канала', [lTag.Name]));
      Continue;
    end;
    if not ParseMic140ChannelNumber(lTag.Address, lChannelNumber) then
    begin
      AMessages.Add(Format('%s: не удалось определить номер канала', [lTag.Name]));
      Continue;
    end;
    if lTag.PollFrequencyHz > 0 then
      lFreq := lTag.PollFrequencyHz;
    for J := 0 to High(lChannelNumbers) do
      if lChannelNumbers[J] = lChannelNumber then
        Break;
    if J > High(lChannelNumbers) then
    begin
      SetLength(lChannelNumbers, Length(lChannelNumbers) + 1);
      lChannelNumbers[High(lChannelNumbers)] := lChannelNumber;
    end;
  end;
  if Length(lChannelNumbers) = 0 then
    Exit;

  lWasRunning := (ADataSources <> nil) and ADataSources.Running;
  if lWasRunning then
    ADataSources.StopAll;
  if AOwner <> nil then
    Screen.Cursor := crHourGlass;
  lDevice := TRecorderMic140Device.Create('service-balance', lHost, lPort,
    MIC140DefaultChannelCount, lFreq, 200);
  try
    if not lDevice.RunServiceZeroBalance(lChannelNumbers, lFreq, lMeans,
      lErrorMessage) then
    begin
      if lErrorMessage <> '' then
        AMessages.Add(lErrorMessage)
      else
        AMessages.Add('Служебная балансировка MIC-140 не выполнена');
      Exit;
    end;
    AMessages.Clear;
    for I := 0 to ATags.Count - 1 do
    begin
      lTag := TRecorderTag(ATags[I]);
      if not ParseMic140ChannelNumber(lTag.Address, lChannelNumber) then
        Continue;
      for J := 0 to High(lChannelNumbers) do
        if lChannelNumbers[J] = lChannelNumber then
        begin
          lTag.Mic140SoftBalance := lMeans[J];
          AMessages.Add(Format('%s: смещение нуля %.3f', [lTag.Name, lMeans[J]]));
          Result := True;
          Break;
        end;
    end;
  finally
    lDevice.Free;
    if AOwner <> nil then
      Screen.Cursor := crDefault;
    if lWasRunning and (ADataSources <> nil) then
      ADataSources.StartAll;
  end;
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
    if not TemperatureChannelSelected(I + 1) then
      Continue;

    lTag := FindTagBySourceAddress(ARegistry, fTemperatureTagNames[I]);
    if lTag = nil then
      lTag := ARegistry.FindByName(fTemperatureTagNames[I]);
    if (lTag = nil) and (fDeviceSerial > 0) then
      lTag := ARegistry.FindByName(
        RecorderMic140TemperatureDisplayName(fDeviceSerial, I + 1));
    if lTag = nil then
      lTag := ARegistry.CreateTag(fTemperatureTagNames[I], 4096);
    lTag.Address := fTemperatureTagNames[I];
    lTag.UnitName := 'code';
    lTag.ModuleType := 'MIC-140';
    lTag.PollFrequencyHz := fPollFrequencyHz;
    lTag.SourceId := SourceId;
    lTag.Description := Format('MIC-140 temperature channel T%d', [I + 1]);
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

procedure TRecorderMic140DataSource.PrepareHardware;
var
  I: Integer;
  lChannelNumber: Integer;
  lCalibrationName: string;
  lFirmware: TRecorderMic140LegacyFirmware;
  lSettings: TRecorderMic140ChannelSettings;
  lTag: TRecorderTag;
begin
  if fHardwarePrepared or fHardwarePrepareAttempted then
    Exit;
  fHardwarePrepareAttempted := True;
  PublishDiagnostics(CMic140StatusDisconnected, 'connecting', True);
  fDevice.Connect;
  if fDevice.State = rdsDisconnected then
  begin
    PublishDiagnostics(CMic140StatusError, 'connection failed', True);
    Exit;
  end;
  PublishDiagnostics(CMic140StatusConnected, 'connected', True);
  if fMic140Device <> nil then
  begin
    fDeviceSerial := fMic140Device.GetDeviceSerial;
    if fMic140Device.GetLegacyFirmware(lFirmware) then
      Mic140LogWarning(Format(
        '[DataSource:%s] MIC-140 firmware devSerNo=%u ccSerNo=%u ccType=%u -> hardware calibr serial=%d',
        [SourceId, lFirmware.DevSerNo, lFirmware.CCSerNo, lFirmware.CCType,
         fDeviceSerial]))
    else
    if fDeviceSerial > 0 then
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 hardware calibr serial=%d',
        [SourceId, fDeviceSerial]));
    if fDeviceSerial > 0 then
    begin
      for I := 0 to Registry.TagCount - 1 do
      begin
        lTag := Registry.Tags[I];
        if SameText(lTag.SourceId, SourceId) and
          (Pos('diagnostics.', LowerCase(lTag.Address)) <> 1) then
          lTag.Mic140DeviceSerial := fDeviceSerial;
      end;
    end;
    RebuildTemperatureTagNames;
    if (fDeviceSerial > 0) and (Registry <> nil) then
    begin
      RecorderMic140ApplyHardwareCalibrations(Registry, SourceId, fDeviceSerial);
      RecorderMic140ApplyTInHardwareCalibrations(Registry, SourceId,
        fDeviceSerial, CMic140Mic140SubRev1, fTemperatureTagNames);
    end;
  end;
  if Registry <> nil then
    for I := 0 to Registry.TagCount - 1 do
    begin
      lTag := Registry.Tags[I];
      if not SameText(lTag.SourceId, SourceId) or
        (not ParseMic140ChannelNumber(lTag.Address, lChannelNumber)) then
        Continue;
      RecorderMic140InitChannelSettings(lSettings, lChannelNumber - 1,
        CMic140Mic140SubRev1);
      RecorderMic140RestoreChannelSettingsFromTag(Registry, lTag, lSettings);
      lTag.Mic140CjcChannel := RecorderMic140ChannelCjcNumber(lSettings,
        lChannelNumber - 1, CMic140Mic140SubRev1);
      if not RecorderMic140ChannelUsesTemperature(lSettings) then
        Continue;
      if not lTag.ChannelCalibrationEnabled then
        Continue;
      if not lTag.Mic140ThermoCompensationEnabled then
        lTag.Mic140ThermoCompensationEnabled := True;
      lCalibrationName := RecorderMic140EnsureThermocoupleCalibration(Registry,
        lSettings);
      if lCalibrationName = '' then
      begin
        Mic140LogWarning(Format(
          '[DataSource:%s] MIC-140 thermocouple curve was not loaded: tag=%s SDB=%s csv=%s',
          [SourceId, lTag.Name, lSettings.ThermocoupleScalePath,
           RecorderMeraThermocoupleCsvPath(lSettings.ThermocoupleScalePath)]));
        Continue;
      end;
      if lTag.CalibrationNames.IndexOf(lCalibrationName) < 0 then
        lTag.CalibrationNames.Add(lCalibrationName);
      lTag.Mic140ThermocoupleScalePath := lSettings.ThermocoupleScalePath;
      lTag.SourceValueMode := RecorderMic140OutputModeToConfigName(momTemperatureC);
      lTag.UnitName := RecorderMic140OutputModeUnitName(momTemperatureC);
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 thermocouple curve ready: tag=%s SDB=%s',
        [SourceId, lTag.Name, lSettings.ThermocoupleScalePath]));
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
  fHardwarePrepared := fDevice.State = rdsStarted;
  if not fHardwarePrepared then
  begin
    PublishDiagnostics(CMic140StatusError, 'start failed', True);
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 source is not started; preview will continue without device samples',
      [SourceId]));
    if fDevice <> nil then
    begin
      try
        fDevice.Stop;
      except
      end;
      try
        fDevice.Disconnect;
      except
      end;
    end;
  end;
end;


procedure TRecorderMic140DataSource.SyncScanConfig;
var
  lChannels: Integer;
begin
  lChannels := MIC140DefaultChannelCount;
  if fMic140Device <> nil then
    lChannels := fMic140Device.ChannelCount;
  if fScanConfig = nil then
    fScanConfig := TRecorderMic140ScanConfig.Create(lChannels, fPollFrequencyHz, UpdateTimeMs)
  else
  begin
    fScanConfig.ChannelCount := lChannels;
    fScanConfig.PollFrequencyHz := fPollFrequencyHz;
    fScanConfig.UpdateTimeMs := UpdateTimeMs;
  end;
  if fAcquireTiming <> nil then
    fAcquireTiming.Apply(fPollFrequencyHz, UpdateTimeMs);
end;

procedure TRecorderMic140DataSource.EnsureProtocolDriver;
begin
  SyncScanConfig;
  if fProtocolDriver <> nil then
    Exit;
  if (fDevice = nil) or (fMic140Device = nil) then
    Exit;
  fProtocolDriver := TRecorderMic140LegacyScanDriver.Create(
    fScanConfig, fDevice, fMic140Device);
end;

procedure TRecorderMic140DataSource.FreeProtocolDriver;
begin
  FreeAndNil(fProtocolDriver);
end;

procedure TRecorderMic140DataSource.Start;
begin
  inherited Start;
  SyncScanConfig;
  fGoodBlockCount := 0;
  fReadFailCount := 0;
  fLastChannelAdcValid := False;
  SetLength(fLastChannelAdcSamples, 0);
  fCjcActiveLogWritten := False;
  fCjcCorrectLogWritten := False;
  fTemperatureModeWarningLogged := False;
  fLastPublishedNumBuffValid := False;
  fPublishedNumBuffGapCount := 0;
  fPublishedCorruptCount := 0;
  if (not fHardwarePrepared) and (fDevice <> nil) and (fDevice.State <> rdsStarted) then
    Exit;
  if fDevice.State = rdsStarted then
  begin
    fStreamFsm.SetPhase(mspAcquiring);
    EnsureBlockPublishThread;
    EnsureLegacyReadThread;
    PublishDiagnostics(CMic140StatusStarted, 'started', True);
  end;
end;

procedure TRecorderMic140DataSource.RequestStop;
begin
  inherited RequestStop;
  if fStreamFsm <> nil then
    fStreamFsm.SetPhase(mspStopping);
  if fMic140Device <> nil then
    fMic140Device.RequestStopAcquisition;
end;

procedure TRecorderMic140DataSource.Stop;
var
  lBufferDropped: Int64;
begin
  if fStreamFsm <> nil then
    fStreamFsm.SetPhase(mspStopping);
  StopLegacyReadThread;
  FreeProtocolDriver;
  StopBlockPublishThread;
  if (fMic140Device <> nil) and
     ((fGoodBlockCount > 0) or (fMic140Device.LegacyStreamReadCount > 0)) then
  begin
    if fRawBuffer <> nil then
      lBufferDropped := fRawBuffer.DroppedCount
    else
      lBufferDropped := 0;
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 stream stop: published=%d read=%d readGaps=%d dupRead=%d corruptRead=%d publishGaps=%d corruptPublish=%d bufferDropped=%d mdpResync=%d',
      [SourceId, fGoodBlockCount, fMic140Device.LegacyStreamReadCount,
       fMic140Device.LegacyNumBuffGapCount, fMic140Device.LegacyDuplicateNumBuffCount,
       fMic140Device.LegacyCorruptReadCount, fPublishedNumBuffGapCount,
       fPublishedCorruptCount, lBufferDropped, fMic140Device.LegacyMdpResyncByteCount]));
  end;
  if fDevice <> nil then
  begin
    try
      fDevice.Stop;
    except
      on E: Exception do
        PublishDiagnostics(CMic140StatusError, 'device stop failed: ' + E.Message, True);
    end;
  end;
  inherited Stop;
  fHardwarePrepared := False;
  if fStreamFsm <> nil then
    fStreamFsm.SetPhase(mspOffline);
  fHardwarePrepareAttempted := False;
  if fDevice <> nil then
  begin
    try
      fDevice.Disconnect;
      PublishDiagnostics(CMic140StatusDisconnected, 'stopped', True);
    except
      on E: Exception do
      begin
        PublishDiagnostics(CMic140StatusError, 'stop failed: ' + E.Message, True);
      end;
    end;
  end;
end;

type
  TMic140BlockPublishThread = class(TThread)
  private
    fOwner: TRecorderMic140DataSource;
    fWakeEvent: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderMic140DataSource);
    destructor Destroy; override;
    procedure SignalWork;
    procedure Flush;
    procedure RequestStop;
  end;

  TMic140LegacyReadThread = class(TThread)
  private
    fOwner: TRecorderMic140DataSource;
    fWakeEvent: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderMic140DataSource);
    destructor Destroy; override;
    procedure RequestStop;
  end;


constructor TMic140BlockPublishThread.Create(AOwner: TRecorderMic140DataSource);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fWakeEvent := TEvent.Create(nil, False, False, '');
end;

destructor TMic140BlockPublishThread.Destroy;
begin
  fWakeEvent.Free;
  inherited Destroy;
end;

procedure TMic140BlockPublishThread.SignalWork;
begin
  fWakeEvent.SetEvent;
end;

procedure TMic140BlockPublishThread.Flush;
var
  lSpin: Integer;
begin
  lSpin := 0;
  while fOwner.fRawBuffer.HasPending do
  begin
    if lSpin >= 400 then
      Break;
    fWakeEvent.WaitFor(5);
    Inc(lSpin);
  end;
end;

procedure TMic140BlockPublishThread.RequestStop;
begin
  Terminate;
  fWakeEvent.SetEvent;
end;

procedure TMic140BlockPublishThread.Execute;
var
  lRaw: TMic140LegacyRawBlock;
begin
  while not Terminated do
  begin
    if not fOwner.fStreamFsm.ShouldPublish then
    begin
      fWakeEvent.WaitFor(fOwner.fStreamFsm.IdleWaitMs);
      Continue;
    end;
    if not fOwner.fRawBuffer.TryTake(lRaw) then
    begin
      fWakeEvent.WaitFor(fOwner.fStreamFsm.PublishBlockWaitMs);
      Continue;
    end;
    if not Terminated then
      fOwner.ProcessLegacyRawBlock(lRaw);
  end;

  while fOwner.fRawBuffer.TryTake(lRaw) do
    fOwner.ProcessLegacyRawBlock(lRaw);
end;

{ TMic140LegacyReadThread }

constructor TMic140LegacyReadThread.Create(AOwner: TRecorderMic140DataSource);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fWakeEvent := TEvent.Create(nil, False, False, '');
end;

destructor TMic140LegacyReadThread.Destroy;
begin
  fWakeEvent.Free;
  inherited Destroy;
end;

procedure TMic140LegacyReadThread.RequestStop;
begin
  Terminate;
  fWakeEvent.SetEvent;
end;

procedure TMic140LegacyReadThread.Execute;
var
  lConsecutiveFails: Integer;
  lRaw: TMic140LegacyRawBlock;
  lTimeoutMs: Cardinal;
begin
  lConsecutiveFails := 0;
  while not Terminated do
  begin
    if Terminated or not fOwner.fStreamFsm.ShouldRead or (fOwner.fDevice = nil) or
       (fOwner.fDevice.State <> rdsStarted) then
    begin
      fWakeEvent.WaitFor(fOwner.fStreamFsm.IdleWaitMs);
      Continue;
    end;
    fWakeEvent.WaitFor(fOwner.fStreamFsm.AcquirePacingMs);
    if Terminated then
      Break;
    lTimeoutMs := fOwner.fScanConfig.ReadTimeoutMs;
    try
      if (fOwner.fProtocolDriver <> nil) and
         fOwner.fProtocolDriver.ReadRawBlock(lRaw) then
      begin
        lConsecutiveFails := 0;
        fOwner.EnqueueLegacyRawBlock(lRaw);
      end
      else if (fOwner.fProtocolDriver = nil) and
        fOwner.fMic140Device.ReadLegacyRawBlock(lTimeoutMs, lRaw) then
      begin
        lConsecutiveFails := 0;
        fOwner.EnqueueLegacyRawBlock(lRaw);
      end
      else
      begin
        Inc(lConsecutiveFails);
        if (lConsecutiveFails >= fOwner.fScanConfig.ReadStallRestartAfter) and
          (
            ((fOwner.fProtocolDriver <> nil) and
             (fOwner.fProtocolDriver.StreamReadCount > 0) and
             fOwner.fProtocolDriver.TryRestartAfterReadStall) or
            ((fOwner.fProtocolDriver = nil) and
             (fOwner.fMic140Device.LegacyStreamReadCount > 0) and
             fOwner.fMic140Device.LegacyTryRestartStreamAfterReadStall)
          ) then
          lConsecutiveFails := 0;
        if lConsecutiveFails = fOwner.fScanConfig.ReadTimeoutWarnAfter then
          Mic140LogWarning(Format(
            '[DataSource:%s] MIC-140 read thread: %d consecutive timeouts (%d ms)',
            [fOwner.SourceId, lConsecutiveFails, lTimeoutMs]));
      end;
    except
      on E: Exception do
      begin
        Mic140LogWarning(Format('[DataSource:%s] MIC-140 read thread failed: %s: %s',
          [fOwner.SourceId, E.ClassName, E.Message]));
        fOwner.fStreamFsm.SetPhase(mspError, E.Message);
        fOwner.PublishDiagnostics(CMic140StatusError,
          'read exception: ' + E.Message, True);
        try
          fOwner.fDevice.Stop;
        except
        end;
        Terminate;
      end;
    end;
  end;
end;

procedure TRecorderMic140DataSource.EnsureBlockPublishThread;
var
  lThread: TMic140BlockPublishThread;
begin
  if fBlockPublishThread <> nil then
    Exit;
  lThread := TMic140BlockPublishThread.Create(Self);
  fBlockPublishThread := lThread;
  lThread.Start;
end;

procedure TRecorderMic140DataSource.StopBlockPublishThread;
var
  lThread: TMic140BlockPublishThread;
begin
  if fBlockPublishThread = nil then
    Exit;
  lThread := TMic140BlockPublishThread(fBlockPublishThread);
  lThread.RequestStop;
  lThread.Flush;
  lThread.WaitFor;
  lThread.Free;
  fBlockPublishThread := nil;
end;

procedure TRecorderMic140DataSource.EnsureLegacyReadThread;
var
  lThread: TMic140LegacyReadThread;
begin
  if fLegacyReadThread <> nil then
    Exit;
  EnsureProtocolDriver;
  lThread := TMic140LegacyReadThread.Create(Self);
  fLegacyReadThread := lThread;
  lThread.Start;
end;

procedure TRecorderMic140DataSource.StopLegacyReadThread;
var
  lThread: TMic140LegacyReadThread;
begin
  if fLegacyReadThread = nil then
    Exit;
  lThread := TMic140LegacyReadThread(fLegacyReadThread);
  lThread.RequestStop;
  lThread.WaitFor;
  lThread.Free;
  fLegacyReadThread := nil;
end;

procedure TRecorderMic140DataSource.EnqueueLegacyRawBlock(
  const ARaw: TMic140LegacyRawBlock);
var
  lDropped: Boolean;
  lNow: QWord;
  lThread: TMic140BlockPublishThread;
begin
  if fRawBuffer = nil then
  begin
    ProcessLegacyRawBlock(ARaw);
    Exit;
  end;
  lDropped := fRawBuffer.Publish(ARaw);
  lNow := GetTickCount64;
  if lDropped and (lNow - fLastRingOverloadLogTick >= CMic140RawBufferDropLogIntervalMs) then
  begin
    fLastRingOverloadLogTick := lNow;
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 raw buffer overflow: readSerial=%d num_buff=%d lag=%d',
      [SourceId, ARaw.ReadSerial, ARaw.Header[CMic140LegacyBiosNumBuffIdx],
       fRawBuffer.PendingLag]));
  end;
  if fBlockPublishThread <> nil then
  begin
    lThread := TMic140BlockPublishThread(fBlockPublishThread);
    lThread.SignalWork;
  end
  else
    ProcessLegacyRawBlock(ARaw);
end;

function TRecorderMic140DataSource.TryEnqueueGoodLegacyRawBlock(
  const ARaw: TMic140LegacyRawBlock): Boolean;
begin
  if (fMic140Device = nil) or
     Mic140LegacyRawBlockLooksCorrupt(ARaw, fMic140Device.ChannelCount) then
    Exit(False);
  EnqueueLegacyRawBlock(ARaw);
  Result := True;
end;

procedure TRecorderMic140DataSource.CheckPublishedNumBuff(
  const ARaw: TMic140LegacyRawBlock);
var
  lCurNumBuff: Word;
  lExpected: Word;
  lMissed: Integer;
begin
  if (fMic140Device <> nil) and fMic140Device.LegacyConsumeStreamSequenceReset then
    fLastPublishedNumBuffValid := False;
  lCurNumBuff := ARaw.Header[CMic140LegacyBiosNumBuffIdx];
  if fLastPublishedNumBuffValid then
  begin
    lExpected := Word((Integer(fLastPublishedNumBuff) + 1) and $FFFF);
    if lCurNumBuff <> lExpected then
    begin
      lMissed := Integer(lCurNumBuff) - Integer(lExpected);
      if lMissed < 0 then
        Inc(lMissed, 65536);
      if lMissed >= CMic140LegacyNumBuffDesyncRestartMissed then
      begin
        Mic140LogWarning(Format(
          '[DataSource:%s] MIC-140 num_buff desync on publish: readSerial=%d prev=%d expected=%d cur=%d missed=%d -> re-baseline',
          [SourceId, ARaw.ReadSerial, fLastPublishedNumBuff, lExpected, lCurNumBuff, lMissed]));
        fLastPublishedNumBuff := lCurNumBuff;
        fLastPublishedNumBuffValid := True;
        Exit;
      end;
      Inc(fPublishedNumBuffGapCount);
      Mic140LogWarning(Format(
        '[DataSource:%s] MIC-140 num_buff gap on publish: readSerial=%d prev=%d expected=%d cur=%d missed=%d publishGaps=%d ring=%d',
        [SourceId, ARaw.ReadSerial, fLastPublishedNumBuff, lExpected, lCurNumBuff,
         lMissed, fPublishedNumBuffGapCount, fRawBuffer.PendingLag]));
    end;
  end;
  fLastPublishedNumBuff := lCurNumBuff;
  fLastPublishedNumBuffValid := True;
end;

procedure TRecorderMic140DataSource.LogMic140StreamSummary(
  const ARaw: TMic140LegacyRawBlock);
begin
  if (fMic140Device = nil) or (fGoodBlockCount = 0) then
    Exit;
  if (fGoodBlockCount <> 1) and
     ((fGoodBlockCount mod CMic140LegacyStreamSummaryInterval) <> 0) then
    Exit;
  Mic140LogWarning(Format(
    '[DataSource:%s] MIC-140 stream: published=%d read=%d num_buff=%d readGaps=%d dupRead=%d corruptRead=%d publishGaps=%d ring=%d mdpResync=%d',
    [SourceId, fGoodBlockCount, fMic140Device.LegacyStreamReadCount,
     ARaw.Header[CMic140LegacyBiosNumBuffIdx],
     fMic140Device.LegacyNumBuffGapCount, fMic140Device.LegacyDuplicateNumBuffCount,
     fMic140Device.LegacyCorruptReadCount, fPublishedNumBuffGapCount,
     fRawBuffer.PendingLag, fMic140Device.LegacyMdpResyncByteCount]));
end;

procedure TRecorderMic140DataSource.ProcessLegacyRawBlock(
  const ARaw: TMic140LegacyRawBlock);
var
  lBlock: TRecorderDeviceSampleBlock;
begin
  CheckPublishedNumBuff(ARaw);
  if (fMic140Device = nil) or
     not fMic140Device.LegacyDecommutateRawBlock(ARaw, lBlock) then
    Exit;
  try
    LogMic140StrideMisalignmentIfNeeded(ARaw, lBlock);
    ProcessAndPublishBlock(lBlock);
    LogMic140StreamSummary(ARaw);
  finally
    ClearRecorderDeviceSampleBlock(lBlock);
  end;
end;

procedure TRecorderMic140DataSource.LogMic140StrideMisalignmentIfNeeded(
  const ARaw: TMic140LegacyRawBlock; const ABlock: TRecorderDeviceSampleBlock);
var
  lK: Integer;
  lPosCount: Integer;
  lSatCount: Integer;
  lPreview: string;
  lI: Integer;
begin
  if (fMic140Device = nil) or
    (not Mic140LegacyRawBlockLooksCorrupt(ARaw, fMic140Device.ChannelCount)) then
    Exit;

  Inc(fPublishedCorruptCount);
  lPosCount := 0;
  lSatCount := 0;
  for lI := 0 to ABlock.ChannelCount - 1 do
  begin
    if lI >= Length(ABlock.Values) then
      Continue;
    if Mic140AdcCodeIsSaturated(ABlock.Values[lI][0]) then
      Inc(lSatCount)
    else if ABlock.Values[lI][0] > CMic140MisalignPositiveThreshold then
      Inc(lPosCount);
  end;

  lPreview := '';
  for lK := 0 to Min(ABlock.ChannelCount - 1, 7) do
  begin
    if lK >= Length(ABlock.Values) then
      Break;
    if lK > 0 then
      lPreview := lPreview + ',';
    lPreview := lPreview + IntToStr(Trunc(ABlock.Values[lK][0]));
  end;
  RecorderDebugLog(Format(
    '[DataSource:%s] MIC-140 stride misalignment: publish=%d readSerial=%d num_buff=%d positive=%d sat=%d preview=[%s]',
    [SourceId, fGoodBlockCount + 1, ARaw.ReadSerial,
     ARaw.Header[CMic140LegacyBiosNumBuffIdx], lPosCount, lSatCount, lPreview]));
end;

procedure TRecorderMic140DataSource.ProcessAndPublishBlock(
  const ABlock: TRecorderDeviceSampleBlock);
var
  lChannels: TRecorderDeviceChannelArray;
  lCount: Integer;
  lI: Integer;
  lJ: Integer;
  lTag: TRecorderTag;
  lCjcChannel: Integer;
  lCjcTemperatureC: Double;
  lCjcPipelineActive: Boolean;
  lTTag: TRecorderTag;
  lUseCjc: Boolean;
  lAuxTemperature: TMic140AuxTemperatureBlock;
  lTimes: TRecorderDoubleArray;
  lValues: TRecorderDoubleArray;
  lSum: Double;
  lRaw: Double;
  lPreview: string;
begin
  lChannels := fDevice.GetChannels;
  lCount := Min(ABlock.ChannelCount, Length(lChannels));
  if lCount <= 0 then
    Exit;
  SetLength(fLastRawChannelMeans, lCount);
  for lI := 0 to lCount - 1 do
  begin
    lSum := 0;
    for lJ := 0 to ABlock.SampleCount - 1 do
      lSum := lSum + ABlock.Values[lI][lJ];
    if ABlock.SampleCount > 0 then
      fLastRawChannelMeans[lI] := lSum / ABlock.SampleCount;
  end;
  fLastRawBlockValid := True;
  Inc(fGoodBlockCount);
  fReadFailCount := 0;
  PublishDiagnostics(CMic140StatusStarted, 'started; data ok', False);
  PublishBlockCounter(fGoodBlockCount);
  if (fGoodBlockCount = 1) or ((fGoodBlockCount mod 20) = 0) then
    Mic140LogWarning(Format('[DataSource:%s] MIC-140 block=%d samples=%d stride=%d rate=%.3f Hz',
      [SourceId, fGoodBlockCount, ABlock.SampleCount, ABlock.ChannelCount +
       MIC140TemperatureChannelCount, ABlock.SampleRateHz]));
  if fGoodBlockCount = 1 then
  begin
    lPreview := '';
    for lI := 0 to lCount - 1 do
    begin
      if (lI > 7) and (lI <> 11) and (lI <> 23) then
        Continue;
      if lI >= fChannelTagNames.Count then
        Break;
      lTag := Registry.FindByName(fChannelTagNames[lI]);
      if lTag = nil then
        Continue;
      lRaw := Mic140RawSample(ABlock, lI, 0, lTag);
      if lTag.HardwareCalibrationEnabled then
        lSum := Registry.TransformTagHardwareValue(lTag, lRaw)
      else
        lSum := lRaw;
      if lPreview <> '' then
        lPreview := lPreview + '; ';
      lPreview := lPreview + Format('%s raw=%.0f mV=%.1f',
        [lTag.Name, lRaw, lSum]);
    end;
    if lPreview <> '' then
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 block1 channels: %s',
        [SourceId, lPreview]));
  end
  else if fGoodBlockCount <= CMic140LegacyScanDetailLogBlocks then
  begin
    lPreview := '';
    for lI := 0 to Min(lCount - 1, 3) do
    begin
      if lI >= Length(ABlock.Values) then
        Break;
      if lPreview <> '' then
        lPreview := lPreview + ',';
      lPreview := lPreview + IntToStr(Trunc(ABlock.Values[lI][0]));
    end;
    Mic140LogWarning(Format(
      '[DataSource:%s] MIC-140 block%d published d0=[%s]',
      [SourceId, fGoodBlockCount, lPreview]));
  end;

  SetLength(lTimes, ABlock.SampleCount);
  for lJ := 0 to ABlock.SampleCount - 1 do
    lTimes[lJ] := ABlock.FirstTimeSec + (lJ / ABlock.SampleRateHz);

  if fMic140Device <> nil then
    lAuxTemperature := fMic140Device.LastAuxTemperatureBlock
  else
    ClearMic140AuxTemperatureBlock(lAuxTemperature);
  PublishTemperatureBlocks(lAuxTemperature, lTimes);

  SetLength(lValues, ABlock.SampleCount);
  for lI := 0 to lCount - 1 do
  begin
    if ShouldStop then
      Exit;
    if lI >= fChannelTagNames.Count then
      Continue;
    lTag := Registry.FindByName(fChannelTagNames[lI]);
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;

    if not lTag.HardwareCalibrationEnabled then
    begin
      for lJ := 0 to ABlock.SampleCount - 1 do
        lValues[lJ] := Mic140RawSample(ABlock, lI, lJ, lTag);
      Registry.AddBlockSamples(lTag.Name, lTimes, lValues, ABlock.SampleCount, True);
      Continue;
    end;

    if not lTag.ChannelCalibrationEnabled then
    begin
      for lJ := 0 to ABlock.SampleCount - 1 do
      begin
        lRaw := Mic140RawSample(ABlock, lI, lJ, lTag);
        lValues[lJ] := Registry.TransformTagHardwareValue(lTag, lRaw);
      end;
      Registry.AddBlockSamples(lTag.Name, lTimes, lValues, ABlock.SampleCount, True);
      Continue;
    end;

    lCjcChannel := RecorderMic140TagEffectiveCjcChannel(lTag, lI,
      CMic140Mic140SubRev1);
    lTTag := nil;
    if (lCjcChannel >= 1) and (lCjcChannel <= fTemperatureTagNames.Count) then
    begin
      lTTag := FindTagBySourceAddress(Registry,
        fTemperatureTagNames[lCjcChannel - 1]);
      if lTTag = nil then
        lTTag := Registry.FindByName(fTemperatureTagNames[lCjcChannel - 1]);
    end;
    lUseCjc := lTag.Mic140ThermoCompensationEnabled and
      SameText(lTag.SourceValueMode,
        RecorderMic140OutputModeToConfigName(momTemperatureC));
    if lUseCjc then
      lUseCjc := Mic140TryGetColdJunctionTemperature(Registry, lTTag,
        lAuxTemperature, lCjcChannel, fDeviceSerial, CMic140Mic140SubRev1,
        lCjcTemperatureC);
    if lUseCjc and (not fCjcActiveLogWritten) then
    begin
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 CJC active: tag=%s T%d=%.3f degC',
        [SourceId, lTag.Name, lCjcChannel, lCjcTemperatureC]));
      fCjcActiveLogWritten := True;
    end;
    if (not lUseCjc) and lTag.Mic140ThermoCompensationEnabled and
      SameText(lTag.SourceValueMode,
        RecorderMic140OutputModeToConfigName(momTemperatureC)) and
      (not fTemperatureModeWarningLogged) then
    begin
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 CJC T%d unavailable (TIn cal missing or junction temp invalid, block tin=%d); channel will use thermocouple GХ without compensation',
        [SourceId, lCjcChannel, lAuxTemperature.ChannelCount]));
      fTemperatureModeWarningLogged := True;
    end;

    lCjcPipelineActive := lUseCjc and
      Mic140TagHasThermocoupleCalibration(Registry, lTag);
    for lJ := 0 to ABlock.SampleCount - 1 do
    begin
      lRaw := Mic140RawSample(ABlock, lI, lJ, lTag);
      if lCjcPipelineActive then
        lValues[lJ] := Mic140TransformThermocoupleChannelSample(Registry, lTag,
          lI, lRaw, lCjcTemperatureC)
      else
        lValues[lJ] := lRaw;
    end;
    if lUseCjc and (not lCjcPipelineActive) and (not fCjcCorrectLogWritten) then
    begin
      Mic140LogWarning(Format(
        '[DataSource:%s] MIC-140 CJC correction skipped for tag=%s: thermocouple GХ is missing or cannot be inverted',
        [SourceId, lTag.Name]));
      fCjcCorrectLogWritten := True;
    end;
    Registry.AddBlockSamples(lTag.Name, lTimes, lValues, ABlock.SampleCount,
      lCjcPipelineActive);
  end;

  if Registry = nil then
    Exit;
  for lI := 0 to lCount - 1 do
  begin
    if lI >= fChannelTagNames.Count then
      Continue;
    lTag := Registry.FindByName(fChannelTagNames[lI]);
    if (lTag = nil) or (not SameText(lTag.SourceId, SourceId)) then
      Continue;
    Registry.PublishBlockNotifications(lTag.Name);
  end;
end;

procedure TRecorderMic140DataSource.DoTick;
var
  lRaw: TMic140LegacyRawBlock;

  procedure StopDeviceIfRequested;
  begin
    if not ShouldStop then
      Exit;
    if fDevice = nil then
      Exit;
    try
      fDevice.Stop;
    except
      on E: Exception do
        Mic140LogWarning(Format('[DataSource:%s] MIC-140 stop on TryStop failed: %s',
          [SourceId, E.Message]));
    end;
  end;

begin
  if ShouldStop then
  begin
    StopDeviceIfRequested;
    Exit;
  end;
  if (fDevice = nil) or (fDevice.State <> rdsStarted) then
    Exit;
  if fLegacyReadThread <> nil then
  begin
    if ShouldStop then
      StopDeviceIfRequested;
    Exit;
  end;
  try
    if not fMic140Device.ReadLegacyRawBlock(
      fScanConfig.ReadTimeoutMs, lRaw) then
    begin
      Inc(fReadFailCount);
      if fReadFailCount = 1 then
        Mic140LogWarning(Format(
          '[DataSource:%s] MIC-140 read timeout after %d published blocks (read=%d mdpResync=%d)',
          [SourceId, fGoodBlockCount, fMic140Device.LegacyStreamReadCount,
           fMic140Device.LegacyMdpResyncByteCount]));
      if fReadFailCount = CMic140NoDataFailThreshold then
        PublishDiagnostics(CMic140StatusError, 'no scan data', True);
      StopDeviceIfRequested;
      Exit;
    end;
    fReadFailCount := 0;
    if ShouldStop then
    begin
      StopDeviceIfRequested;
      Exit;
    end;
    EnqueueLegacyRawBlock(lRaw);
    StopDeviceIfRequested;
  except
    on E: Exception do
    begin
      Mic140LogWarning(Format('[DataSource:%s] MIC-140 read failed: %s: %s',
        [SourceId, E.ClassName, E.Message]));
      PublishDiagnostics(CMic140StatusError, 'read exception: ' + E.Message, True);
      try
        fDevice.Stop;
      except
      end;
    end;
  end;
end;


end.
