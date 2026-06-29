unit uRecorderMic140DeviceCore;

{
  Общая реализация драйвера MIC-140 (TCP, MDP, скан, чтение кадров).
  v1 и v2 — тонкие наследники; переопределяют только UsesRawRing.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants, Forms, SyncObjs,
  uRecorderDeviceInterfaces, uRecorderMebiusTcpProtocol,
  uRecorderMic140LegacyProtocol, uRecorderMic140Utils,
  uRecorderMic140StreamTypes, uRecorderMic140LegacyConstants,
  uRecorderMic140LegacyTiming,
  uRecorderMic140DeviceApi, uRecorderTags;

const
  MIC140DefaultChannelCount = 48;
  MIC140MaxChannelCount = 96;
  MIC140TemperatureChannelCount = 3;
  MIC140DefaultPollFrequencyHz = 100.0;

type
  TRecorderMic140DeviceCore = class(TInterfacedObject, IMic140Device)
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
    function LegacyPayloadStride: Integer;
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
    function UsesRawRing: Boolean; virtual;
    function ChannelCount: Integer;

    property Host: string read fHost;
    property Port: Word read fPort;
  end;


implementation

uses
  Math, StrUtils, LazFileUtils, Controls, Dialogs, LCLIntf,
  uSharedFileLogger, uRecorderMeraPaths, uRecorderDebugLog,
  uRecorderMeraSdbThermocouples, uRecorderSdbStore,
  uRecorderMic140FlashConstants,
  uRecorderMic140Thermocouple, uRecorderMic140MebiusConstants,
  uRecorderMic140DeviceConfig, uRecorderMic140Flash,
  uRecorderMic140MebiusTypes,
  uRecorderMic140LegacyChannelDesc, uRecorderMic140StreamHelpers,
  uRecorderMic140Calibration, uRecorderMic140ScanConfig
  {$IFDEF MSWINDOWS}, WinSock2{$ELSE}, BaseUnix, CTypes, Sockets{$ENDIF};

const
  CMic140ReadTimeoutMinMs = 1500;
  CMic140IoCtlTypeCallCommand = 2;
  CMic140IoCtlCmdSetControllerParams =
    (CMic140IoCtlTypeCallCommand shl 16) or ($000C shl 2);
  CMic140BalanceMinSamples = 30;
  CMic140BalanceDiscardSamples = 10;
  CMic140BalanceSampleFraction = 0.3;
  CMic140Range5mV = 2;

procedure TRecorderMic140DeviceCore.LogLegacyScanBlockDetail(
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

function TRecorderMic140DeviceCore.LegacyNoteReadSincePrevMs: QWord;
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

procedure TRecorderMic140DeviceCore.CheckLegacyNumBuffOnRead(
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

{ TRecorderMic140DeviceCore }

constructor TRecorderMic140DeviceCore.Create(const ADeviceId, AHost: string; APort: Word;
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

destructor TRecorderMic140DeviceCore.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

function TRecorderMic140DeviceCore.GetDeviceId: string;
begin
  Result := fDeviceId;
end;

function TRecorderMic140DeviceCore.GetName: string;
begin
  Result := Format('MIC-140 %s:%d', [fHost, fPort]);
end;

function TRecorderMic140DeviceCore.GetState: TRecorderDeviceState;
begin
  Result := fState;
end;

function TRecorderMic140DeviceCore.GetChannels: TRecorderDeviceChannelArray;
begin
  Result := Copy(fChannels, 0, Length(fChannels));
end;

function TRecorderMic140DeviceCore.GetDeviceProperty(AProperty: TRecorderDeviceProperty;
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

function TRecorderMic140DeviceCore.TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
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

procedure TRecorderMic140DeviceCore.BuildChannels;
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

function TRecorderMic140DeviceCore.LegacyAllocBuffer(AWordCount: Word; out APage,
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

function TRecorderMic140DeviceCore.LegacyAllocHeap(AWordCount: Word; out APage,
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

function TRecorderMic140DeviceCore.LegacyCalcFifoReadyWords: Word;
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
  { [ORIG] fifoReady = samples_per_ch × (AIn+TIn stride) }
  lChannelCount := LegacyPayloadStride;
  if lChannelCount <= 0 then
    lChannelCount := MIC140DefaultChannelCount + MIC140TemperatureChannelCount;
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

function TRecorderMic140DeviceCore.LegacyInternalScanChannelCount: Integer;
begin
  { [ORIG] stride payload = AIn + TIn (51); AIn — первые 48 слов строки }
  Result := fChannelCount + MIC140TemperatureChannelCount;
end;

function TRecorderMic140DeviceCore.LegacyPayloadStride: Integer;
begin
  Result := LegacyInternalScanChannelCount;
end;

function TRecorderMic140DeviceCore.LegacyTimerScale: Word;
begin
  if SameValue(RecorderMic140NormalizeFrequency(fPollFrequencyHz), 1.0, 0.001) then
    Result := 2
  else
    Result := 1;
end;

function TRecorderMic140DeviceCore.LegacyTimerPeriod: Word;
begin
  // MIC-140 uses the 16 MHz MC114 grid. For the safe 48-channel frequencies
  // exposed by the UI, the original scale_period_16000 table has period=640.
  Result := CMic140LegacyTimerPeriod;
end;

function TRecorderMic140DeviceCore.LegacyCalcScanDivider: Word;
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

procedure TRecorderMic140DeviceCore.LegacyRecoverTcpConnection;
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

function TRecorderMic140DeviceCore.LegacyProbeScanRunning: Boolean;
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

function TRecorderMic140DeviceCore.LegacyTrySoftRestartScan: Boolean;
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

function TRecorderMic140DeviceCore.GetDeviceSerial: Integer;
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

function TRecorderMic140DeviceCore.GetLegacyFirmware(
  out AFirmware: TRecorderMic140LegacyFirmware): Boolean;
begin
  Result := fUseLegacyProtocol and (fLegacyFirmware.DevType > 0);
  if Result then
    AFirmware := fLegacyFirmware;
end;

function TRecorderMic140DeviceCore.GetNodeNumber: Integer;
begin
  Result := fNodeNumber;
end;

function TRecorderMic140DeviceCore.ProgramLegacyDevice(out AErrorMessage: string): Boolean;
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

  if not LegacyAllocHeap(lInternalChannelCount, lPage, lValueAddr) then
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
  Mic140LegacyMe048ForPhysicalChannel(-1, lMe048W0, lMe048W1);
  lDescDump[0] := lMe048W1;
  lDescDump[1] := lMe048W1;
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
        Word(CMaskChanLeft or (lValueAddr + I));
    end
    else
    begin
      lTemperatureIndex := I - fChannelCount;
      Mic140LegacyPackTInMe04848(lTemperatureIndex, lMe048W0, lMe048W1);
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 0] := lMe048W0;
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 1] := lMe048W1;
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 2] :=
        Mic140LegacyTInDesc48(lTemperatureIndex);
      lDescDump[(I + 1) * CMic140LegacyDescChanWords + 4] :=
        Word(CMaskChanLeft or (lValueAddr + fChannelCount + lTemperatureIndex));
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

procedure TRecorderMic140DeviceCore.Connect;
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


procedure TRecorderMic140DeviceCore.ProgramDevice;
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

procedure TRecorderMic140DeviceCore.Disconnect;
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

procedure TRecorderMic140DeviceCore.Start;
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

procedure TRecorderMic140DeviceCore.RequestStopAcquisition;
begin
  fStopRequested := True;
end;

procedure TRecorderMic140DeviceCore.ClearLegacyScanBuffer;
begin
  if fLegacyClient <> nil then
    fLegacyClient.ClearBufferedPackets;
  fLegacyLastNumBuffValid := False;
  fLegacyLastReadTickValid := False;
  fLegacyLastGoodRawBlockValid := False;
end;

procedure TRecorderMic140DeviceCore.Stop;
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

function TRecorderMic140DeviceCore.RunServiceZeroBalance(
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

function TRecorderMic140DeviceCore.ReadLegacyRawBlock(ATimeoutMs: Cardinal;
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
  ARaw.PayloadStrideWords := Word(lInternalChannelCount);
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

function TRecorderMic140DeviceCore.LegacyDecommutateRawBlock(
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

function TRecorderMic140DeviceCore.LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;
begin
  Result := fLastAuxTemperature;
end;

function TRecorderMic140DeviceCore.LegacyStreamReadCount: Int64;
begin
  Result := fLegacyReadBlockCount;
end;

function TRecorderMic140DeviceCore.LegacyNumBuffGapCount: Integer;
begin
  Result := fLegacyNumBuffGapCount;
end;

function TRecorderMic140DeviceCore.LegacyDuplicateNumBuffCount: Integer;
begin
  Result := fLegacyDuplicateNumBuffCount;
end;

function TRecorderMic140DeviceCore.LegacyCorruptReadCount: Integer;
begin
  Result := fLegacyCorruptReadCount;
end;

function TRecorderMic140DeviceCore.LegacyTryRestartStreamAfterReadStall: Boolean;
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

function TRecorderMic140DeviceCore.LegacyMdpResyncByteCount: Int64;
begin
  if fLegacyClient <> nil then
    Result := fLegacyClient.MdpResyncByteCount
  else
    Result := 0;
end;

function TRecorderMic140DeviceCore.LegacyConsumeStreamSequenceReset: Boolean;
begin
  Result := fLegacyStreamSequenceReset;
  fLegacyStreamSequenceReset := False;
end;

function TRecorderMic140DeviceCore.ReadBlock(ATimeoutMs: Cardinal;
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


function TRecorderMic140DeviceCore.UsesRawRing: Boolean;
begin
  Result := False;
end;

function TRecorderMic140DeviceCore.ChannelCount: Integer;
begin
  Result := fChannelCount;
end;

end.
