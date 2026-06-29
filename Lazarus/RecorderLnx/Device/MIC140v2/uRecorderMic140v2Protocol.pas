unit uRecorderMic140v2Protocol;

{ TCP + MDP, CC Ethernet BIOS. Только v2. }

{
  MIC-140 48/96 legacy Ethernet protocol.

  This protocol is used by original Recorder modules MIC140_96_rce through
  mdpEthernet81/MC031. It is not compatible with Mebius MEBE packets.

  2026-06: Mic140v2DeviceSerialFromFirmware РІС‹РЅРµСЃРµРЅ СЃСЋРґР° РёР·
  uRecorderMic140DataSource (СЂР°Р·Р±РѕСЂ TBiosInfoMC031 / ETH81 identify).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, SyncObjs, ssockets,
  uRecorderMic140v2WireTypes;

type
  TMic140v2Firmware = uRecorderMic140v2WireTypes.TRecorderMic140LegacyFirmware;

  EMic140v2Protocol = class(Exception);

  TMic140v2WordBuf = array of Word;
  TMic140v2ByteBuf = array of Byte;



  TMic140v2ScanPacket = record
    HeaderWords: TMic140v2WordBuf;
    DataWords: TMic140v2WordBuf;
  end;

  TMic140v2Tcp = class
  private
    fHost: string;
    fPort: Word;
    fRxBuffer: TMic140v2ByteBuf;
    fSocket: TInetSocket;
    fTimeoutMs: Cardinal;
    fLock: TCriticalSection;
    fMdpResyncBytes: Int64;
    fScanQueue: array of TMic140v2ScanPacket;
    fScanQueueHead: Integer;
    fScanQueueCount: Integer;
    fScanQueueDropped: Int64;
    fScanRejectLogCount: Integer;
    function ReadBytes(var ABuffer; ACount: Integer): Boolean;
    function EnsureRxBytes(ACount: Integer): Boolean;
    procedure DropRxBytes(ACount: Integer; AResync: Boolean = False);
    procedure DrainPendingSocket;
    procedure ApplyTimeoutMs(AValue: Cardinal);
    procedure SetTimeoutMs(AValue: Cardinal);
    procedure WriteBytes(const ABuffer; ACount: Integer);
    procedure SendPacket(APort: Word; const AWords: TMic140v2WordBuf);
    function ReadPacket(out APort: Word; out AWords: TMic140v2WordBuf): Boolean;
    procedure ClearScanQueue;
    function ScanQueueCapacity: Integer;
    function TryDequeueScan(out ABlock: TMic140v2ScanPacket): Boolean;
    procedure EnqueueScan(const ABlock: TMic140v2ScanPacket);
    function TryParseScanWords(const AWords: TMic140v2WordBuf;
      out ABlock: TMic140v2ScanPacket): Boolean;
    procedure LogRejectedScanWords(const AReason: string;
      const AWords: TMic140v2WordBuf);
    procedure AbsorbScanWords(const AWords: TMic140v2WordBuf);
    procedure PumpScanFromSocket(AMaxPackets: Integer; ATimeoutMs: Cardinal);
  public
    constructor Create(const AHost: string; APort: Word = 4000;
      ATimeoutMs: Cardinal = 5000);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    function CallCommand(ACommand: Word; const AArgs: TMic140v2WordBuf;
      ARetWordCount: Integer; out ARet: TMic140v2WordBuf;
      out AErrorMessage: string): Boolean;
    function WriteDmWords(AAddress: Word; const AWords: TMic140v2WordBuf;
      out AErrorMessage: string): Boolean;
    function ReadFirmware(out AFirmware: TMic140v2Firmware;
      out AErrorMessage: string): Boolean;
    function StartScan(out AErrorMessage: string): Boolean;
    function StopScan(out AErrorMessage: string): Boolean;
    procedure ClearBufferedPackets;
    function ReadScanBlock(out ABlock: TMic140v2ScanPacket;
      out AErrorMessage: string): Boolean;
    function ReadFlashStorage(AAddress: LongWord; var ABuffer; AByteCount: Integer;
      out AErrorMessage: string): Boolean;
    function MdpResyncByteCount: Int64;
    function ScanQueueDepth: Integer;
    function ScanQueueDropCount: Int64;

    property Host: string read fHost;
    property Port: Word read fPort;
    property TimeoutMs: Cardinal read fTimeoutMs write SetTimeoutMs;
  end;

const
  MIC140v2_CMD_REPLY = 113;
  MIC140v2_CMD_WRITE_DM = 111;
  MIC140v2_CMD_START_SCAN_MAIN = 80;
  MIC140v2_CMD_STOP_SCAN_MAIN = 81;
  MIC140v2_CMD_READ_EEPROM = 126;
  MIC140_LEGACY_DM_FLAG = Word($4000);
  CMic140MaxPlausibleDeviceSerial = 9999;
  CMic140FirmwareDeviceIdentityMin = $4000;
  CMic140LegacyCrateTypeUnknown = Word($FFFF);

function Mic140v2HostLastOctet(const AHost: string; out AOctet: Integer): Boolean;
function Mic140v2DeviceSerialFromFirmware(
  const AFirmware: TMic140v2Firmware): Integer;
function Mic140v2DisplaySerialFromFirmware(
  const AFirmware: TMic140v2Firmware; const AHost: string): Integer;
function Mic140v2HardwareCalibrSerial(
  const AFirmware: TMic140v2Firmware): Integer;
function Mic140v2FirmwareVersionText(
  const AFirmware: TMic140v2Firmware): string;
function Mic140v2DevRevFromFirmware(
  const AFirmware: TMic140v2Firmware): Word;
function Mic140v2DevSubRevFromFirmware(
  const AFirmware: TMic140v2Firmware): Word;

const
  CMic140LegacyBiosScanIdIdx = 2;
  CMic140LegacyBiosSlotIdx = 3;
  CMic140LegacyBiosChanIdx = 4;
  CMic140LegacyBiosNumBuffIdx = 8;
  CMic140LegacyBiosStateIdx = 9;
  CMic140LegacyBiosMessageType = 0;
  CMic140LegacyBiosMessageSizeWords = 106;

type
  TMic140LegacyBiosHeaderVerdict = record
    Ok: Boolean;
    TypeOk: Boolean;
    SizeOk: Boolean;
    ScanIdOk: Boolean;
    StateOk: Boolean;
    SlotOk: Boolean;
    ChanOk: Boolean;
    DataWordsOk: Boolean;
    NumBuffOk: Boolean;
    ExpectedMessageSize: Word;
    ActualMessageSize: Word;
    ExpectedDataWords: Word;
    ActualDataWords: Word;
    Detail: string;
  end;

procedure Mic140LegacyEvaluateBiosScanHeader(
  const AHeaderWords: array of Word; AExpectedMessageSizeWords: Word;
  AActualDataWords: Integer; APreviousNumBuff: Word;
  APreviousNumBuffValid: Boolean; out AVerdict: TMic140LegacyBiosHeaderVerdict);
function Mic140LegacyBiosScanHeaderValid(
  const AHeaderWords: TMic140v2WordBuf; out AReason: string): Boolean;
function Mic140LegacyBiosHeaderVerdictText(
  const AVerdict: TMic140LegacyBiosHeaderVerdict): string;

implementation

uses
  uRecorderDebugLog;

const
  CLegacySyncWord = Word($12B8);
  CLegacyStreamScan = Word(0);
  CLegacyStreamCommand = Word(1);
  CLegacyMaxPacketWords = 1024;
  CLegacyMaxWriteDmDataWords = 31;
  CLegacyHeaderBytes = 8;
  CLegacyScanHeaderWords = 10;
  CLegacyFlashReadChunkBytes = 256;
  CMic140v2ScanQueueCapacity = 32;

function WordSum(const AWords: array of Word): Word;
var
  I: Integer;
  lSum: LongWord;
begin
  lSum := 0;
  for I := 0 to High(AWords) do
    Inc(lSum, AWords[I]);
  Result := Word(lSum and $FFFF);
end;

function GetWordLE(const AData: array of Byte; AOffset: Integer): Word;
begin
  Result := Word(AData[AOffset]) or (Word(AData[AOffset + 1]) shl 8);
end;

procedure PutWordLE(var AData: array of Byte; AOffset: Integer; AValue: Word);
begin
  AData[AOffset] := Byte(AValue and $FF);
  AData[AOffset + 1] := Byte((AValue shr 8) and $FF);
end;

constructor TMic140v2Tcp.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  fLock := TCriticalSection.Create;
  fMdpResyncBytes := 0;
  SetLength(fScanQueue, CMic140v2ScanQueueCapacity);
  fScanQueueHead := 0;
  fScanQueueCount := 0;
  fScanQueueDropped := 0;
end;

destructor TMic140v2Tcp.Destroy;
begin
  fLock.Acquire;
  try
    Disconnect;
  finally
    fLock.Release;
    fLock.Free;
  end;
  inherited Destroy;
end;

procedure TMic140v2Tcp.Connect;
begin
  fLock.Acquire;
  try
    Disconnect;
    fSocket := TInetSocket.Create(fHost, fPort, Integer(fTimeoutMs));
    ApplyTimeoutMs(fTimeoutMs);
  finally
    fLock.Release;
  end;
end;

procedure TMic140v2Tcp.Disconnect;
begin
  SetLength(fRxBuffer, 0);
  FreeAndNil(fSocket);
end;

procedure TMic140v2Tcp.DrainPendingSocket;
var
  lBuf: array[0..4095] of Byte;
  lOldTimeout: Cardinal;
  lRead: Integer;
begin
  if fSocket = nil then
    Exit;
  lOldTimeout := fTimeoutMs;
  try
    ApplyTimeoutMs(1);
    repeat
      lRead := fSocket.Read(lBuf[0], SizeOf(lBuf));
    until lRead <= 0;
  finally
    ApplyTimeoutMs(lOldTimeout);
  end;
end;

procedure TMic140v2Tcp.ClearBufferedPackets;
begin
  fLock.Acquire;
  try
    SetLength(fRxBuffer, 0);
    fMdpResyncBytes := 0;
    fScanRejectLogCount := 0;
    ClearScanQueue;
    DrainPendingSocket;
  finally
    fLock.Release;
  end;
end;

function TMic140v2Tcp.ScanQueueCapacity: Integer;
begin
  Result := Length(fScanQueue);
end;

procedure TMic140v2Tcp.ClearScanQueue;
begin
  fScanQueueHead := 0;
  fScanQueueCount := 0;
end;

function TMic140v2Tcp.TryDequeueScan(out ABlock: TMic140v2ScanPacket): Boolean;
begin
  Result := fScanQueueCount > 0;
  if not Result then
    Exit;
  ABlock := fScanQueue[fScanQueueHead];
  fScanQueueHead := (fScanQueueHead + 1) mod ScanQueueCapacity;
  Dec(fScanQueueCount);
end;

procedure TMic140v2Tcp.EnqueueScan(const ABlock: TMic140v2ScanPacket);
var
  lIdx: Integer;
begin
  if ScanQueueCapacity <= 0 then
    Exit;
  if fScanQueueCount >= ScanQueueCapacity then
  begin
    fScanQueueHead := (fScanQueueHead + 1) mod ScanQueueCapacity;
    Dec(fScanQueueCount);
    Inc(fScanQueueDropped);
  end;
  lIdx := (fScanQueueHead + fScanQueueCount) mod ScanQueueCapacity;
  fScanQueue[lIdx] := ABlock;
  Inc(fScanQueueCount);
end;

procedure TMic140v2Tcp.LogRejectedScanWords(const AReason: string;
  const AWords: TMic140v2WordBuf);
var
  l0, l1, l2, l3, l4, l8, l9: Word;
begin
  if fScanRejectLogCount >= 12 then
    Exit;
  Inc(fScanRejectLogCount);
  l0 := 0;
  l1 := 0;
  l2 := 0;
  l3 := 0;
  l4 := 0;
  l8 := 0;
  l9 := 0;
  if Length(AWords) > 0 then l0 := AWords[0];
  if Length(AWords) > 1 then l1 := AWords[1];
  if Length(AWords) > 2 then l2 := AWords[2];
  if Length(AWords) > 3 then l3 := AWords[3];
  if Length(AWords) > 4 then l4 := AWords[4];
  if Length(AWords) > 8 then l8 := AWords[8];
  if Length(AWords) > 9 then l9 := AWords[9];
  RecorderDebugLog(Format(
    '[MIC140v2:%s:%d] reject stream0 #%d reason=%s mdpWords=%d h0=%d size=%d scan=%d slot=%d chan=%d nb=%d state=%d q=%d',
    [fHost, fPort, fScanRejectLogCount, AReason, Length(AWords),
     l0, l1, l2, l3, l4, l8, l9, fScanQueueCount]));
end;

function TMic140v2Tcp.TryParseScanWords(const AWords: TMic140v2WordBuf;
  out ABlock: TMic140v2ScanPacket): Boolean;
var
  I, lDataCount, lMessageSize: Integer;
  lBiosReason: string;
begin
  Result := False;
  SetLength(ABlock.HeaderWords, 0);
  SetLength(ABlock.DataWords, 0);
  if Length(AWords) < CLegacyScanHeaderWords then
  begin
    LogRejectedScanWords('short', AWords);
    Exit;
  end;

  SetLength(ABlock.HeaderWords, CLegacyScanHeaderWords);
  for I := 0 to High(ABlock.HeaderWords) do
    ABlock.HeaderWords[I] := AWords[I];
  lMessageSize := ABlock.HeaderWords[1];
  if not Mic140LegacyBiosScanHeaderValid(ABlock.HeaderWords, lBiosReason) then
  begin
    LogRejectedScanWords('header ' + lBiosReason, AWords);
    Exit;
  end;
  if (ABlock.HeaderWords[CMic140LegacyBiosScanIdIdx] <> 0) or
     (ABlock.HeaderWords[CMic140LegacyBiosStateIdx] <> 0) or
     (ABlock.HeaderWords[CMic140LegacyBiosSlotIdx] <> 0) or
     (ABlock.HeaderWords[CMic140LegacyBiosChanIdx] <> 0) then
  begin
    LogRejectedScanWords('routing', AWords);
    Exit;
  end;
  if Length(AWords) < lMessageSize then
  begin
    LogRejectedScanWords('truncated message', AWords);
    Exit;
  end;

  lDataCount := lMessageSize - CLegacyScanHeaderWords;
  if lDataCount <= 0 then
  begin
    LogRejectedScanWords('empty data', AWords);
    Exit;
  end;
  SetLength(ABlock.DataWords, lDataCount);
  for I := 0 to lDataCount - 1 do
    ABlock.DataWords[I] := AWords[I + CLegacyScanHeaderWords];
  Result := True;
end;

procedure TMic140v2Tcp.AbsorbScanWords(const AWords: TMic140v2WordBuf);
var
  lBlock: TMic140v2ScanPacket;
begin
  if TryParseScanWords(AWords, lBlock) then
    EnqueueScan(lBlock);
end;

procedure TMic140v2Tcp.PumpScanFromSocket(AMaxPackets: Integer;
  ATimeoutMs: Cardinal);
var
  lPort: Word;
  lWords: TMic140v2WordBuf;
  lOldTimeout: Cardinal;
  lStartedAt: QWord;
  lPumped: Integer;
  lDrainMode: Boolean;
begin
  if AMaxPackets <= 0 then
    Exit;
  lDrainMode := ATimeoutMs <= 1;
  lOldTimeout := fTimeoutMs;
  if lDrainMode then
    fTimeoutMs := 1
  else
    fTimeoutMs := ATimeoutMs;
  lStartedAt := GetTickCount64;
  lPumped := 0;
  try
    while lPumped < AMaxPackets do
    begin
      if (not lDrainMode) and (GetTickCount64 - lStartedAt >= fTimeoutMs) then
        Break;
      if not ReadPacket(lPort, lWords) then
      begin
        if fScanRejectLogCount < 12 then
        begin
          Inc(fScanRejectLogCount);
          RecorderDebugLog(Format(
            '[MIC140v2:%s:%d] scan pump timeout #%d after %d ms q=%d rx=%d resync=%d',
            [fHost, fPort, fScanRejectLogCount, GetTickCount64 - lStartedAt,
             fScanQueueCount, Length(fRxBuffer), fMdpResyncBytes]));
        end;
        Break;
      end;
      if lPort = CLegacyStreamScan then
      begin
        if fScanRejectLogCount < 12 then
          RecorderDebugLog(Format(
            '[MIC140v2:%s:%d] scan pump stream0 words=%d q=%d',
            [fHost, fPort, Length(lWords), fScanQueueCount]));
        AbsorbScanWords(lWords);
        Inc(lPumped);
      end;
    end;
  finally
    fTimeoutMs := lOldTimeout;
  end;
end;

function TMic140v2Tcp.ScanQueueDepth: Integer;
begin
  fLock.Acquire;
  try
    Result := fScanQueueCount;
  finally
    fLock.Release;
  end;
end;

function TMic140v2Tcp.ScanQueueDropCount: Int64;
begin
  fLock.Acquire;
  try
    Result := fScanQueueDropped;
  finally
    fLock.Release;
  end;
end;

function TMic140v2Tcp.MdpResyncByteCount: Int64;
begin
  fLock.Acquire;
  try
    Result := fMdpResyncBytes;
  finally
    fLock.Release;
  end;
end;

procedure Mic140LegacyEvaluateBiosScanHeader(
  const AHeaderWords: array of Word; AExpectedMessageSizeWords: Word;
  AActualDataWords: Integer; APreviousNumBuff: Word;
  APreviousNumBuffValid: Boolean; out AVerdict: TMic140LegacyBiosHeaderVerdict);
var
  lExpected: Word;
  lNumBuff: Word;
begin
  FillChar(AVerdict, SizeOf(AVerdict), 0);
  AVerdict.Detail := 'short header';
  if Length(AHeaderWords) < CLegacyScanHeaderWords then
    Exit;

  AVerdict.ActualMessageSize := AHeaderWords[1];
  AVerdict.ExpectedMessageSize := AExpectedMessageSizeWords;
  AVerdict.ActualDataWords := AActualDataWords;
  if AExpectedMessageSizeWords > CLegacyScanHeaderWords then
    AVerdict.ExpectedDataWords := AExpectedMessageSizeWords - CLegacyScanHeaderWords
  else
    AVerdict.ExpectedDataWords := 0;

  AVerdict.TypeOk := AHeaderWords[0] = CMic140LegacyBiosMessageType;
  if AExpectedMessageSizeWords > 0 then
    AVerdict.SizeOk := AHeaderWords[1] = AExpectedMessageSizeWords
  else
    AVerdict.SizeOk := (AHeaderWords[1] >= CLegacyScanHeaderWords + 1) and
      (AHeaderWords[1] <= CLegacyMaxPacketWords);
  AVerdict.ScanIdOk := AHeaderWords[CMic140LegacyBiosScanIdIdx] = 0;
  AVerdict.SlotOk := AHeaderWords[CMic140LegacyBiosSlotIdx] = 0;
  AVerdict.ChanOk := AHeaderWords[CMic140LegacyBiosChanIdx] = 0;
  AVerdict.StateOk := AHeaderWords[CMic140LegacyBiosStateIdx] = 0;
  if AVerdict.ExpectedDataWords > 0 then
    AVerdict.DataWordsOk := AActualDataWords = AVerdict.ExpectedDataWords
  else
    AVerdict.DataWordsOk := AActualDataWords >= 0;

  lNumBuff := AHeaderWords[CMic140LegacyBiosNumBuffIdx];
  if not APreviousNumBuffValid then
    AVerdict.NumBuffOk := lNumBuff > 0
  else
  begin
    lExpected := Word((Integer(APreviousNumBuff) + 1) and $FFFF);
    AVerdict.NumBuffOk := lNumBuff = lExpected;
  end;

  AVerdict.Ok := AVerdict.TypeOk and AVerdict.SizeOk and AVerdict.ScanIdOk and
    AVerdict.StateOk and AVerdict.SlotOk and AVerdict.ChanOk and
    AVerdict.DataWordsOk;

  if AVerdict.Ok then
  begin
    if AVerdict.NumBuffOk then
      AVerdict.Detail := Format('OK size=%d scan_id=0 state=0 data=%d num_buff=%d',
        [AVerdict.ActualMessageSize, AActualDataWords, lNumBuff])
    else
      AVerdict.Detail := Format('OK size=%d scan_id=0 state=0 data=%d num_buff=%d seq=gap',
        [AVerdict.ActualMessageSize, AActualDataWords, lNumBuff]);
  end
  else
  begin
  AVerdict.Detail := '';
    if not AVerdict.TypeOk then
      AVerdict.Detail := AVerdict.Detail + Format('type=%d ', [AHeaderWords[0]]);
    if not AVerdict.SizeOk then
      AVerdict.Detail := AVerdict.Detail + Format('size=%d expected=%d ',
        [AVerdict.ActualMessageSize, AVerdict.ExpectedMessageSize]);
    if not AVerdict.ScanIdOk then
      AVerdict.Detail := AVerdict.Detail + Format('scan_id=%d ',
        [AHeaderWords[CMic140LegacyBiosScanIdIdx]]);
    if not AVerdict.StateOk then
      AVerdict.Detail := AVerdict.Detail + Format('state=%d ',
        [AHeaderWords[CMic140LegacyBiosStateIdx]]);
    if not AVerdict.SlotOk then
      AVerdict.Detail := AVerdict.Detail + Format('slot=%d ',
        [AHeaderWords[CMic140LegacyBiosSlotIdx]]);
    if not AVerdict.ChanOk then
      AVerdict.Detail := AVerdict.Detail + Format('chan=%d ',
        [AHeaderWords[CMic140LegacyBiosChanIdx]]);
    if not AVerdict.DataWordsOk then
      AVerdict.Detail := AVerdict.Detail + Format('dataWords=%d expected=%d ',
        [AActualDataWords, AVerdict.ExpectedDataWords]);
    if not AVerdict.NumBuffOk then
    begin
      if APreviousNumBuffValid then
        AVerdict.Detail := AVerdict.Detail + Format('num_buff=%d expected=%d ',
          [lNumBuff, Word((Integer(APreviousNumBuff) + 1) and $FFFF)])
      else
        AVerdict.Detail := AVerdict.Detail + Format('num_buff=%d ', [lNumBuff]);
    end;
    AVerdict.Detail := Trim(AVerdict.Detail);
  end;
end;

function Mic140LegacyBiosHeaderVerdictText(
  const AVerdict: TMic140LegacyBiosHeaderVerdict): string;
begin
  if AVerdict.Ok then
    Result := 'header=' + AVerdict.Detail
  else
    Result := 'header=BAD ' + AVerdict.Detail;
end;

function Mic140LegacyBiosScanHeaderValid(
  const AHeaderWords: TMic140v2WordBuf; out AReason: string): Boolean;
var
  lVerdict: TMic140LegacyBiosHeaderVerdict;
begin
  Mic140LegacyEvaluateBiosScanHeader(AHeaderWords, 0, -1, 0, False, lVerdict);
  AReason := lVerdict.Detail;
  Result := lVerdict.TypeOk and (lVerdict.ActualMessageSize >= CLegacyScanHeaderWords + 1) and
    (lVerdict.ActualMessageSize <= CLegacyMaxPacketWords);
end;

procedure TMic140v2Tcp.ApplyTimeoutMs(AValue: Cardinal);
begin
  if AValue = 0 then
    AValue := 1;
  fTimeoutMs := AValue;
  if fSocket <> nil then
    fSocket.IOTimeout := Integer(fTimeoutMs);
end;

procedure TMic140v2Tcp.SetTimeoutMs(AValue: Cardinal);
begin
  fLock.Acquire;
  try
    ApplyTimeoutMs(AValue);
  finally
    fLock.Release;
  end;
end;

function TMic140v2Tcp.ReadBytes(var ABuffer; ACount: Integer): Boolean;
var
  lDone: Integer;
  lRead: Integer;
begin
  Result := False;
  if fSocket = nil then
    raise EMic140v2Protocol.Create('MIC-140 legacy socket is not connected');
  lDone := 0;
  while lDone < ACount do
  begin
    lRead := fSocket.Read((PByte(@ABuffer) + lDone)^, ACount - lDone);
    if lRead <= 0 then
      Exit(False);
    Inc(lDone, lRead);
  end;
  Result := True;
end;

function TMic140v2Tcp.EnsureRxBytes(ACount: Integer): Boolean;
var
  lOldLength: Integer;
  lReadCount: Integer;
  lRead: Integer;
begin
  Result := Length(fRxBuffer) >= ACount;
  if Result then
    Exit;
  if fSocket = nil then
    raise EMic140v2Protocol.Create('MIC-140 legacy socket is not connected');

  while Length(fRxBuffer) < ACount do
  begin
    lOldLength := Length(fRxBuffer);
    lReadCount := ACount - lOldLength;
    SetLength(fRxBuffer, ACount);
    lRead := fSocket.Read(fRxBuffer[lOldLength], lReadCount);
    if lRead <= 0 then
    begin
      SetLength(fRxBuffer, lOldLength);
      Exit(False);
    end;
    SetLength(fRxBuffer, lOldLength + lRead);
  end;
  Result := True;
end;

procedure TMic140v2Tcp.DropRxBytes(ACount: Integer;
  AResync: Boolean);
var
  lRemain: Integer;
begin
  if ACount <= 0 then
    Exit;
  if AResync then
    Inc(fMdpResyncBytes, ACount);
  if ACount >= Length(fRxBuffer) then
  begin
    SetLength(fRxBuffer, 0);
    Exit;
  end;

  lRemain := Length(fRxBuffer) - ACount;
  Move(fRxBuffer[ACount], fRxBuffer[0], lRemain);
  SetLength(fRxBuffer, lRemain);
end;

procedure TMic140v2Tcp.WriteBytes(const ABuffer; ACount: Integer);
var
  lDone: Integer;
  lWritten: Integer;
begin
  if fSocket = nil then
    raise EMic140v2Protocol.Create('MIC-140 legacy socket is not connected');
  lDone := 0;
  while lDone < ACount do
  begin
    lWritten := fSocket.Write((PByte(@ABuffer) + lDone)^, ACount - lDone);
    if lWritten <= 0 then
      raise EMic140v2Protocol.Create('MIC-140 legacy TCP write failed');
    Inc(lDone, lWritten);
  end;
end;

procedure TMic140v2Tcp.SendPacket(APort: Word;
  const AWords: TMic140v2WordBuf);
var
  I: Integer;
  lBytes: array of Byte;
  lDataSum: LongWord;
  lHeaderSum: Word;
  lOffset: Integer;
begin
  if Length(AWords) > CLegacyMaxPacketWords then
    raise EMic140v2Protocol.Create('MIC-140 legacy packet is too large');

  SetLength(lBytes, CLegacyHeaderBytes + (Length(AWords) + 1) * SizeOf(Word));
  lHeaderSum := Word((LongWord(CLegacySyncWord) + APort + Length(AWords)) and $FFFF);
  PutWordLE(lBytes, 0, CLegacySyncWord);
  PutWordLE(lBytes, 2, APort);
  PutWordLE(lBytes, 4, Length(AWords));
  PutWordLE(lBytes, 6, lHeaderSum);

  lOffset := CLegacyHeaderBytes;
  lDataSum := 0;
  for I := 0 to High(AWords) do
  begin
    PutWordLE(lBytes, lOffset, AWords[I]);
    Inc(lDataSum, AWords[I]);
    Inc(lOffset, SizeOf(Word));
  end;
  PutWordLE(lBytes, lOffset, Word(lDataSum and $FFFF));
  WriteBytes(lBytes[0], Length(lBytes));
end;

function TMic140v2Tcp.ReadPacket(out APort: Word;
  out AWords: TMic140v2WordBuf): Boolean;
var
  I: Integer;
  lDataSum: LongWord;
  lHeaderSum: Word;
  lPacketBytes: Integer;
  lSizeWords: Word;
begin
  Result := False;
  APort := 0;
  SetLength(AWords, 0);
  while True do
  begin
    if not EnsureRxBytes(CLegacyHeaderBytes) then
      Exit;

    // Original mdpEthernet81::ProcessProtocol consumes one byte on any broken
    // candidate packet. Keeping the remaining bytes is important for stream 0:
    // dropping the whole candidate on checksum error desynchronizes the TCP
    // stream and can leave the device running without a reader.
    if GetWordLE(fRxBuffer, 0) <> CLegacySyncWord then
    begin
      DropRxBytes(1, True);
      Continue;
    end;

    APort := GetWordLE(fRxBuffer, 2);
    lSizeWords := GetWordLE(fRxBuffer, 4);
    lHeaderSum := Word((LongWord(CLegacySyncWord) + APort + lSizeWords) and $FFFF);
    if (GetWordLE(fRxBuffer, 6) <> lHeaderSum) or
      (lSizeWords > CLegacyMaxPacketWords) then
    begin
      DropRxBytes(1, True);
      Continue;
    end;

    lPacketBytes := CLegacyHeaderBytes + (Integer(lSizeWords) + 1) * SizeOf(Word);
    if not EnsureRxBytes(lPacketBytes) then
      Exit;

    lDataSum := 0;
    for I := 0 to lSizeWords - 1 do
      Inc(lDataSum, GetWordLE(fRxBuffer,
        CLegacyHeaderBytes + I * SizeOf(Word)));
    if GetWordLE(fRxBuffer, CLegacyHeaderBytes + lSizeWords * SizeOf(Word)) <>
      Word(lDataSum and $FFFF) then
    begin
      DropRxBytes(1, True);
      Continue;
    end;

    SetLength(AWords, lSizeWords);
    for I := 0 to lSizeWords - 1 do
      AWords[I] := GetWordLE(fRxBuffer,
        CLegacyHeaderBytes + I * SizeOf(Word));
    DropRxBytes(lPacketBytes);
    Exit(True);
  end;
end;

function TMic140v2Tcp.CallCommand(ACommand: Word;
  const AArgs: TMic140v2WordBuf; ARetWordCount: Integer;
  out ARet: TMic140v2WordBuf; out AErrorMessage: string): Boolean;
var
  lPort: Word;
  lRequest: TMic140v2WordBuf;
  lWords: TMic140v2WordBuf;
  lStartedAt: QWord;
begin
  fLock.Acquire;
  try
    Result := False;
    AErrorMessage := '';
    SetLength(ARet, 0);
    try
      if ARetWordCount <= 0 then
        ARetWordCount := 1;
      SetLength(lRequest, 3 + Length(AArgs));
      lRequest[0] := ACommand;
      lRequest[1] := Length(AArgs);
      lRequest[2] := ARetWordCount;
      if Length(AArgs) > 0 then
        Move(AArgs[0], lRequest[3], Length(AArgs) * SizeOf(Word));

      SendPacket(CLegacyStreamCommand, lRequest);
      lStartedAt := GetTickCount64;
      repeat
        if not ReadPacket(lPort, lWords) then
        begin
          AErrorMessage := 'MIC-140 legacy command timeout';
          Exit;
        end;

        { [ORIG] mdpEthernet81: stream 0 → scan FIFO, stream 1 → command reply. }
        if lPort = CLegacyStreamScan then
        begin
          AbsorbScanWords(lWords);
          Continue;
        end;
        if lPort = CLegacyStreamCommand then
        begin
          ARet := lWords;
          Break;
        end;
      until GetTickCount64 - lStartedAt >= fTimeoutMs;

      if lPort <> CLegacyStreamCommand then
      begin
        AErrorMessage := Format('MIC-140 legacy unexpected reply stream: %d', [lPort]);
        Exit;
      end;
      if Length(ARet) < ARetWordCount then
      begin
        AErrorMessage := Format('MIC-140 legacy reply is too short: %d/%d',
          [Length(ARet), ARetWordCount]);
        Exit;
      end;
      Result := True;
    except
      on E: Exception do
        AErrorMessage := E.Message;
    end;
  finally
    fLock.Release;
  end;
end;

function TMic140v2Tcp.WriteDmWords(AAddress: Word;
  const AWords: TMic140v2WordBuf; out AErrorMessage: string): Boolean;
var
  I: Integer;
  lArgs: TMic140v2WordBuf;
  lCount: Integer;
  lOffset: Integer;
  lReply: TMic140v2WordBuf;
begin
  // This is ADSP DM write used by CC BIOS commands, not the low-level MDP
  // resource write from VTBL.H. Original path: Mc031ethernetifc.cpp
  // WriteRemoteWordArray(...IS_DM...) -> Ccdevice.h CMD_WRITEDM = 111.
  Result := False;
  AErrorMessage := '';
  lOffset := 0;
  while lOffset < Length(AWords) do
  begin
    lCount := Length(AWords) - lOffset;
    if lCount > CLegacyMaxWriteDmDataWords then
      lCount := CLegacyMaxWriteDmDataWords;

    SetLength(lArgs, lCount + 1);
    lArgs[0] := MIC140_LEGACY_DM_FLAG or Word(AAddress + lOffset);
    for I := 0 to lCount - 1 do
      lArgs[I + 1] := AWords[lOffset + I];

    if not CallCommand(MIC140v2_CMD_WRITE_DM, lArgs, 0, lReply,
      AErrorMessage) then
      Exit;
    Inc(lOffset, lCount);
  end;
  Result := True;
end;

function TMic140v2Tcp.ReadFirmware(
  out AFirmware: TMic140v2Firmware; out AErrorMessage: string): Boolean;
var
  lReply: TMic140v2WordBuf;
begin
  FillChar(AFirmware, SizeOf(AFirmware), 0);
  Result := CallCommand(MIC140v2_CMD_REPLY, nil, 11, lReply, AErrorMessage);
  if not Result then
    Exit;
  if Length(lReply) < 5 then
  begin
    AErrorMessage := 'Firmware reply is too short';
    Result := False;
    Exit;
  end;
  { TBiosInfoMC031: 11 WORDs at lReply[0..10], same layout as CCMC031EthernetInterface::ReadCfg. }
  AFirmware.Signature := lReply[0];
  AFirmware.MdpType := lReply[1];
  AFirmware.DevType := lReply[2];
  AFirmware.DevRevNo := lReply[3];
  AFirmware.DevSerNo := lReply[4];
  if Length(lReply) >= 6 then
    AFirmware.CCType := lReply[5];
  if Length(lReply) >= 7 then
    AFirmware.CCSerNo := lReply[6];
  if Length(lReply) >= 8 then
    AFirmware.EepromManufactId := lReply[7];
  if Length(lReply) >= 9 then
    AFirmware.EepromDeviceId := lReply[8];
  if Length(lReply) >= 10 then
    AFirmware.BiosFunction := lReply[9];
  if Length(lReply) >= 11 then
    AFirmware.BiosVersion := lReply[10];
end;

function TMic140v2Tcp.StartScan(out AErrorMessage: string): Boolean;
var
  lReply: TMic140v2WordBuf;
begin
  // Start the CC BIOS main scan. VTBL.H also has CMD_START_SCAN_MAIN = 4,
  // but original CCDevice::OnStartScanMain reaches Ccdevice.h command 80.
  Result := CallCommand(MIC140v2_CMD_START_SCAN_MAIN, nil, 0, lReply,
    AErrorMessage);
end;

function TMic140v2Tcp.StopScan(out AErrorMessage: string): Boolean;
var
  lReply: TMic140v2WordBuf;
begin
  // Paired with Ccdevice.h CMD_STOPSCANMAIN = 81.
  Result := CallCommand(MIC140v2_CMD_STOP_SCAN_MAIN, nil, 0, lReply,
    AErrorMessage);
end;

function TMic140v2Tcp.ReadFlashStorage(AAddress: LongWord;
  var ABuffer; AByteCount: Integer; out AErrorMessage: string): Boolean;
var
  lArgs: TMic140v2WordBuf;
  lChunkBytes: Integer;
  lCopied: Integer;
  lReadBytes: Integer;
  lReply: TMic140v2WordBuf;
  lRetWords: Integer;
  lSrc: PByte;
begin
  Result := False;
  AErrorMessage := '';
  if AByteCount <= 0 then
    Exit(True);
  lSrc := PByte(@ABuffer);
  lCopied := 0;
  while lCopied < AByteCount do
  begin
    lChunkBytes := AByteCount - lCopied;
    if lChunkBytes > CLegacyFlashReadChunkBytes then
      lChunkBytes := CLegacyFlashReadChunkBytes;
    if lChunkBytes mod 2 <> 0 then
      Inc(lChunkBytes);

    lRetWords := (lChunkBytes + 1) div 2;
    SetLength(lArgs, 3);
    lArgs[0] := Word(AAddress + LongWord(lCopied));
    lArgs[1] := Word((AAddress + LongWord(lCopied)) shr 16);
    lArgs[2] := Word(lChunkBytes);

    if not CallCommand(MIC140v2_CMD_READ_EEPROM, lArgs, lRetWords, lReply,
      AErrorMessage) then
      Exit;

    lReadBytes := AByteCount - lCopied;
    if lReadBytes > lChunkBytes then
      lReadBytes := lChunkBytes;
    if Length(lReply) * SizeOf(Word) < lReadBytes then
    begin
      AErrorMessage := Format('MIC-140 flash read reply is too short: %d/%d bytes',
        [Length(lReply) * SizeOf(Word), lReadBytes]);
      Exit;
    end;
    Move(lReply[0], lSrc[lCopied], lReadBytes);
    Inc(lCopied, lReadBytes);
  end;
  Result := True;
end;

function TMic140v2Tcp.ReadScanBlock(
  out ABlock: TMic140v2ScanPacket; out AErrorMessage: string): Boolean;
var
  lDrainMode: Boolean;
begin
  Result := False;
  AErrorMessage := '';
  SetLength(ABlock.HeaderWords, 0);
  SetLength(ABlock.DataWords, 0);
  fLock.Acquire;
  try
    try
      if TryDequeueScan(ABlock) then
        Exit(True);

      { ReadLegacyRawBlock(0) → 1 ms timeout: drain TCP into scan queue. }
      lDrainMode := fTimeoutMs <= 1;
      if lDrainMode then
        PumpScanFromSocket(MaxInt, 1)
      else
        PumpScanFromSocket(1, fTimeoutMs);

      Result := TryDequeueScan(ABlock);
      if not Result then
        AErrorMessage := 'MIC-140 legacy scan timeout (no valid BIOS packet)';
    except
      on E: Exception do
        AErrorMessage := E.Message;
    end;
  finally
    fLock.Release;
  end;
end;

function Mic140FirmwareWordLooksLikeDeviceIdentity(AValue: Word): Boolean;
begin
  Result := AValue >= CMic140FirmwareDeviceIdentityMin;
end;

function Mic140FirmwareWordIsPlausibleDeviceSerial(AValue: Word): Boolean;
begin
  Result := (AValue > 0) and (AValue <= CMic140MaxPlausibleDeviceSerial) and
    not Mic140FirmwareWordLooksLikeDeviceIdentity(AValue);
end;

function Mic140v2HostLastOctet(const AHost: string; out AOctet: Integer): Boolean;
var
  lDotPos: Integer;
  lPart: string;
begin
  Result := False;
  AOctet := 0;
  lDotPos := Length(AHost);
  while (lDotPos > 0) and (AHost[lDotPos] <> '.') do
    Dec(lDotPos);
  if lDotPos <= 0 then
    Exit;
  lPart := Trim(Copy(AHost, lDotPos + 1, MaxInt));
  if lPart = '' then
    Exit;
  Result := TryStrToInt(lPart, AOctet);
end;

function Mic140v2DeviceSerialFromFirmware(
  const AFirmware: TMic140v2Firmware): Integer;
begin
  Result := 0;
  { Номер в заголовке диалога / адресе канала (DETECT DevSerNo). }
  if Mic140FirmwareWordIsPlausibleDeviceSerial(AFirmware.DevSerNo) then
    Exit(AFirmware.DevSerNo);
  if Mic140FirmwareWordIsPlausibleDeviceSerial(AFirmware.CCSerNo) then
    Exit(AFirmware.CCSerNo);
  if Mic140FirmwareWordIsPlausibleDeviceSerial(AFirmware.CCType) then
    Exit(AFirmware.CCType);
end;

function Mic140v2DisplaySerialFromFirmware(
  const AFirmware: TMic140v2Firmware; const AHost: string): Integer;
var
  lHostOctet: Integer;
begin
  Result := 0;
  { DevSerNo на Ethernet MIC часто совпадает с последним октетом IP, не с с/н MIC. }
  if Mic140v2HostLastOctet(AHost, lHostOctet) and
     (Integer(AFirmware.DevSerNo) = lHostOctet) then
  begin
    if Mic140FirmwareWordIsPlausibleDeviceSerial(AFirmware.CCSerNo) then
      Exit(AFirmware.CCSerNo);
    Exit(0);
  end;
  Result := Mic140v2DeviceSerialFromFirmware(AFirmware);
end;

function Mic140v2HardwareCalibrSerial(
  const AFirmware: TMic140v2Firmware): Integer;
begin
  Result := 0;
  { CCMC031EthernetInterface::ReadCfg: owner->DeviceInfo.SerialNo = CCSerNo;
    CChannelMIC140::GetSerialNumOwner -> cc->DeviceInfo.SerialNo.
    DevSerNo — только идентификатор Ethernet MDP, не каталог calibr/hardware. }
  if (AFirmware.CCType <> 0) and
     (AFirmware.CCType <> CMic140LegacyCrateTypeUnknown) and
     (AFirmware.CCSerNo > 0) and
     not Mic140FirmwareWordLooksLikeDeviceIdentity(AFirmware.CCSerNo) then
    Exit(AFirmware.CCSerNo);
  if Mic140FirmwareWordIsPlausibleDeviceSerial(AFirmware.CCSerNo) then
    Exit(AFirmware.CCSerNo);
end;

function Mic140v2DevRevFromFirmware(
  const AFirmware: TMic140v2Firmware): Word;
begin
  { CMIC140::GetDevRev: PROP_REV = DeviceInfo.RevisionNo = bios_info.cfg.DevRevNo. }
  Result := AFirmware.DevRevNo and $FF;
end;

function Mic140v2DevSubRevFromFirmware(
  const AFirmware: TMic140v2Firmware): Word;
begin
  Result := (AFirmware.DevRevNo shr 8) and $FF;
end;

function Mic140v2FirmwareVersionText(
  const AFirmware: TMic140v2Firmware): string;
begin
  Result := Format('%u.%u.%u.%u', [
    Mic140v2DevRevFromFirmware(AFirmware),
    Mic140v2DevSubRevFromFirmware(AFirmware),
    AFirmware.BiosVersion,
    AFirmware.BiosFunction]);
end;

end.
