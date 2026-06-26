unit uRecorderMic140LegacyProtocol;

{
  MIC-140 48/96 legacy Ethernet protocol.

  This protocol is used by original Recorder modules MIC140_96_rce through
  mdpEthernet81/MC031. It is not compatible with Mebius MEBE packets.

  2026-06: RecorderMic140DeviceSerialFromFirmware РІС‹РЅРµСЃРµРЅ СЃСЋРґР° РёР·
  uRecorderMic140DataSource (СЂР°Р·Р±РѕСЂ TBiosInfoMC031 / ETH81 identify).
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, SyncObjs, ssockets;

type
  ERecorderMic140LegacyProtocol = class(Exception);

  TRecorderMic140LegacyWordArray = array of Word;
  TRecorderMic140LegacyByteArray = array of Byte;

  TRecorderMic140LegacyFirmware = record
    { TBiosInfoMC031 / CMD_REPLY = 113, MC031 Ethernet BIOS layout }
    Signature: Word;
    MdpType: Word;
    DevType: Word;
    DevRevNo: Word;
    DevSerNo: Word;
    CCType: Word;
    CCSerNo: Word;
    EepromManufactId: Word;
    EepromDeviceId: Word;
    BiosFunction: Word;
    BiosVersion: Word;
  end;

  TRecorderMic140LegacyScanBlock = record
    HeaderWords: TRecorderMic140LegacyWordArray;
    DataWords: TRecorderMic140LegacyWordArray;
  end;

  TRecorderMic140LegacyClient = class
  private
    fHost: string;
    fPort: Word;
    fRxBuffer: TRecorderMic140LegacyByteArray;
    fSocket: TInetSocket;
    fTimeoutMs: Cardinal;
    fLock: TCriticalSection;
    fMdpResyncBytes: Int64;
    function ReadBytes(var ABuffer; ACount: Integer): Boolean;
    function EnsureRxBytes(ACount: Integer): Boolean;
    procedure DropRxBytes(ACount: Integer; AResync: Boolean = False);
    procedure DrainPendingSocket;
    procedure ApplyTimeoutMs(AValue: Cardinal);
    procedure SetTimeoutMs(AValue: Cardinal);
    procedure WriteBytes(const ABuffer; ACount: Integer);
    procedure SendPacket(APort: Word; const AWords: TRecorderMic140LegacyWordArray);
    function ReadPacket(out APort: Word; out AWords: TRecorderMic140LegacyWordArray): Boolean;
  public
    constructor Create(const AHost: string; APort: Word = 4000;
      ATimeoutMs: Cardinal = 5000);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    function CallCommand(ACommand: Word; const AArgs: TRecorderMic140LegacyWordArray;
      ARetWordCount: Integer; out ARet: TRecorderMic140LegacyWordArray;
      out AErrorMessage: string): Boolean;
    function WriteDmWords(AAddress: Word; const AWords: TRecorderMic140LegacyWordArray;
      out AErrorMessage: string): Boolean;
    function ReadFirmware(out AFirmware: TRecorderMic140LegacyFirmware;
      out AErrorMessage: string): Boolean;
    function StartScan(out AErrorMessage: string): Boolean;
    function StopScan(out AErrorMessage: string): Boolean;
    procedure ClearBufferedPackets;
    function ReadScanBlock(out ABlock: TRecorderMic140LegacyScanBlock;
      out AErrorMessage: string): Boolean;
    function ReadFlashStorage(AAddress: LongWord; var ABuffer; AByteCount: Integer;
      out AErrorMessage: string): Boolean;
    function MdpResyncByteCount: Int64;

    property Host: string read fHost;
    property Port: Word read fPort;
    property TimeoutMs: Cardinal read fTimeoutMs write SetTimeoutMs;
  end;

const
  MIC140_LEGACY_CMD_REPLY = 113;
  MIC140_LEGACY_CMD_WRITE_DM = 111;
  MIC140_LEGACY_CMD_START_SCAN_MAIN = 80;
  MIC140_LEGACY_CMD_STOP_SCAN_MAIN = 81;
  MIC140_LEGACY_CMD_READ_EEPROM = 126;
  MIC140_LEGACY_DM_FLAG = Word($4000);
  CMic140MaxPlausibleDeviceSerial = 9999;
  CMic140FirmwareDeviceIdentityMin = $4000;
  CMic140LegacyCrateTypeUnknown = Word($FFFF);

function RecorderMic140HostLastOctet(const AHost: string; out AOctet: Integer): Boolean;
function RecorderMic140DeviceSerialFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Integer;
function RecorderMic140DisplaySerialFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware; const AHost: string): Integer;
function RecorderMic140HardwareCalibrSerialFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Integer;
function RecorderMic140FirmwareVersionText(
  const AFirmware: TRecorderMic140LegacyFirmware): string;
function RecorderMic140DevRevFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Word;
function RecorderMic140DevSubRevFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Word;

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
  const AHeaderWords: TRecorderMic140LegacyWordArray; out AReason: string): Boolean;
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

constructor TRecorderMic140LegacyClient.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  fLock := TCriticalSection.Create;
  fMdpResyncBytes := 0;
end;

destructor TRecorderMic140LegacyClient.Destroy;
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

procedure TRecorderMic140LegacyClient.Connect;
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

procedure TRecorderMic140LegacyClient.Disconnect;
begin
  SetLength(fRxBuffer, 0);
  FreeAndNil(fSocket);
end;

procedure TRecorderMic140LegacyClient.DrainPendingSocket;
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

procedure TRecorderMic140LegacyClient.ClearBufferedPackets;
begin
  fLock.Acquire;
  try
    SetLength(fRxBuffer, 0);
    fMdpResyncBytes := 0;
    DrainPendingSocket;
  finally
    fLock.Release;
  end;
end;

function TRecorderMic140LegacyClient.MdpResyncByteCount: Int64;
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
  const AHeaderWords: TRecorderMic140LegacyWordArray; out AReason: string): Boolean;
var
  lVerdict: TMic140LegacyBiosHeaderVerdict;
begin
  Mic140LegacyEvaluateBiosScanHeader(AHeaderWords, 0, -1, 0, False, lVerdict);
  AReason := lVerdict.Detail;
  Result := lVerdict.TypeOk and (lVerdict.ActualMessageSize >= CLegacyScanHeaderWords + 1) and
    (lVerdict.ActualMessageSize <= CLegacyMaxPacketWords);
end;

procedure TRecorderMic140LegacyClient.ApplyTimeoutMs(AValue: Cardinal);
begin
  if AValue = 0 then
    AValue := 1;
  fTimeoutMs := AValue;
  if fSocket <> nil then
    fSocket.IOTimeout := Integer(fTimeoutMs);
end;

procedure TRecorderMic140LegacyClient.SetTimeoutMs(AValue: Cardinal);
begin
  fLock.Acquire;
  try
    ApplyTimeoutMs(AValue);
  finally
    fLock.Release;
  end;
end;

function TRecorderMic140LegacyClient.ReadBytes(var ABuffer; ACount: Integer): Boolean;
var
  lDone: Integer;
  lRead: Integer;
begin
  Result := False;
  if fSocket = nil then
    raise ERecorderMic140LegacyProtocol.Create('MIC-140 legacy socket is not connected');
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

function TRecorderMic140LegacyClient.EnsureRxBytes(ACount: Integer): Boolean;
var
  lOldLength: Integer;
  lReadCount: Integer;
  lRead: Integer;
begin
  Result := Length(fRxBuffer) >= ACount;
  if Result then
    Exit;
  if fSocket = nil then
    raise ERecorderMic140LegacyProtocol.Create('MIC-140 legacy socket is not connected');

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

procedure TRecorderMic140LegacyClient.DropRxBytes(ACount: Integer;
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

procedure TRecorderMic140LegacyClient.WriteBytes(const ABuffer; ACount: Integer);
var
  lDone: Integer;
  lWritten: Integer;
begin
  if fSocket = nil then
    raise ERecorderMic140LegacyProtocol.Create('MIC-140 legacy socket is not connected');
  lDone := 0;
  while lDone < ACount do
  begin
    lWritten := fSocket.Write((PByte(@ABuffer) + lDone)^, ACount - lDone);
    if lWritten <= 0 then
      raise ERecorderMic140LegacyProtocol.Create('MIC-140 legacy TCP write failed');
    Inc(lDone, lWritten);
  end;
end;

procedure TRecorderMic140LegacyClient.SendPacket(APort: Word;
  const AWords: TRecorderMic140LegacyWordArray);
var
  I: Integer;
  lBytes: array of Byte;
  lDataSum: LongWord;
  lHeaderSum: Word;
  lOffset: Integer;
begin
  if Length(AWords) > CLegacyMaxPacketWords then
    raise ERecorderMic140LegacyProtocol.Create('MIC-140 legacy packet is too large');

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

function TRecorderMic140LegacyClient.ReadPacket(out APort: Word;
  out AWords: TRecorderMic140LegacyWordArray): Boolean;
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

function TRecorderMic140LegacyClient.CallCommand(ACommand: Word;
  const AArgs: TRecorderMic140LegacyWordArray; ARetWordCount: Integer;
  out ARet: TRecorderMic140LegacyWordArray; out AErrorMessage: string): Boolean;
var
  lPort: Word;
  lRequest: TRecorderMic140LegacyWordArray;
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
        if not ReadPacket(lPort, ARet) then
        begin
          AErrorMessage := 'MIC-140 legacy command timeout';
          Exit;
        end;

        // Original mdpEthernet81 demultiplexes command and scan streams into
        // separate FIFOs. RecorderLnx currently reads the same TCP stream
        // directly, so command calls made while the scan is active must skip
        // stream-0 packets until the stream-1 reply arrives.
        if lPort = CLegacyStreamCommand then
          Break;
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

function TRecorderMic140LegacyClient.WriteDmWords(AAddress: Word;
  const AWords: TRecorderMic140LegacyWordArray; out AErrorMessage: string): Boolean;
var
  I: Integer;
  lArgs: TRecorderMic140LegacyWordArray;
  lCount: Integer;
  lOffset: Integer;
  lReply: TRecorderMic140LegacyWordArray;
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

    if not CallCommand(MIC140_LEGACY_CMD_WRITE_DM, lArgs, 0, lReply,
      AErrorMessage) then
      Exit;
    Inc(lOffset, lCount);
  end;
  Result := True;
end;

function TRecorderMic140LegacyClient.ReadFirmware(
  out AFirmware: TRecorderMic140LegacyFirmware; out AErrorMessage: string): Boolean;
var
  lReply: TRecorderMic140LegacyWordArray;
begin
  FillChar(AFirmware, SizeOf(AFirmware), 0);
  Result := CallCommand(MIC140_LEGACY_CMD_REPLY, nil, 11, lReply, AErrorMessage);
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

function TRecorderMic140LegacyClient.StartScan(out AErrorMessage: string): Boolean;
var
  lReply: TRecorderMic140LegacyWordArray;
begin
  // Start the CC BIOS main scan. VTBL.H also has CMD_START_SCAN_MAIN = 4,
  // but original CCDevice::OnStartScanMain reaches Ccdevice.h command 80.
  Result := CallCommand(MIC140_LEGACY_CMD_START_SCAN_MAIN, nil, 0, lReply,
    AErrorMessage);
end;

function TRecorderMic140LegacyClient.StopScan(out AErrorMessage: string): Boolean;
var
  lReply: TRecorderMic140LegacyWordArray;
begin
  // Paired with Ccdevice.h CMD_STOPSCANMAIN = 81.
  Result := CallCommand(MIC140_LEGACY_CMD_STOP_SCAN_MAIN, nil, 0, lReply,
    AErrorMessage);
end;

function TRecorderMic140LegacyClient.ReadFlashStorage(AAddress: LongWord;
  var ABuffer; AByteCount: Integer; out AErrorMessage: string): Boolean;
var
  lArgs: TRecorderMic140LegacyWordArray;
  lChunkBytes: Integer;
  lCopied: Integer;
  lReadBytes: Integer;
  lReply: TRecorderMic140LegacyWordArray;
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

    if not CallCommand(MIC140_LEGACY_CMD_READ_EEPROM, lArgs, lRetWords, lReply,
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

function TRecorderMic140LegacyClient.ReadScanBlock(
  out ABlock: TRecorderMic140LegacyScanBlock; out AErrorMessage: string): Boolean;
var
  I: Integer;
  lDataCount: Integer;
  lDrainMode: Boolean;
  lPort: Word;
  lWords: TRecorderMic140LegacyWordArray;
  lBiosReason: string;
  lMessageSize: Integer;
  lStartedAt: QWord;
begin
  Result := False;
  AErrorMessage := '';
  SetLength(ABlock.HeaderWords, 0);
  SetLength(ABlock.DataWords, 0);
  fLock.Acquire;
  try
    try
      { ReadLegacyRawBlock(0) maps to a 1 ms socket timeout — drain every already
        buffered MDP packet without a wall-clock cap, otherwise one rejected
        candidate ends burst after ~1 ms and the TCP queue stalls. }
      lDrainMode := fTimeoutMs <= 1;
      lStartedAt := GetTickCount64;
      while True do
      begin
        if (not lDrainMode) and (GetTickCount64 - lStartedAt >= fTimeoutMs) then
          Break;
        if not ReadPacket(lPort, lWords) then
        begin
          if lDrainMode then
            Exit;
          AErrorMessage := 'MIC-140 legacy scan timeout';
          Exit;
        end;
        if lPort <> CLegacyStreamScan then
          Continue;

        if Length(lWords) < CLegacyScanHeaderWords then
        begin
          RecorderDebugLog(Format(
            '[MIC-140:%s:%d] Legacy scan packet too short: mdpWords=%d mdpResync=%d',
            [fHost, fPort, Length(lWords), fMdpResyncBytes]));
          Continue;
        end;

        SetLength(ABlock.HeaderWords, CLegacyScanHeaderWords);
        for I := 0 to High(ABlock.HeaderWords) do
          ABlock.HeaderWords[I] := lWords[I];
        lMessageSize := ABlock.HeaderWords[1];
        if not Mic140LegacyBiosScanHeaderValid(ABlock.HeaderWords, lBiosReason) then
        begin
          RecorderDebugLog(Format(
            '[MIC-140:%s:%d] Legacy BIOS header invalid: %s mdpWords=%d h=[%d,%d,%d,%d,%d,%d,%d,%d,%d,%d] mdpResync=%d',
            [fHost, fPort, lBiosReason, Length(lWords),
             ABlock.HeaderWords[0], ABlock.HeaderWords[1], ABlock.HeaderWords[2],
             ABlock.HeaderWords[3], ABlock.HeaderWords[4], ABlock.HeaderWords[5],
             ABlock.HeaderWords[6], ABlock.HeaderWords[7], ABlock.HeaderWords[8],
             ABlock.HeaderWords[9], fMdpResyncBytes]));
          Continue;
        end;
        if (ABlock.HeaderWords[CMic140LegacyBiosScanIdIdx] <> 0) or
           (ABlock.HeaderWords[CMic140LegacyBiosStateIdx] <> 0) or
           (ABlock.HeaderWords[CMic140LegacyBiosSlotIdx] <> 0) or
           (ABlock.HeaderWords[CMic140LegacyBiosChanIdx] <> 0) then
        begin
          RecorderDebugLog(Format(
            '[MIC-140:%s:%d] Legacy BIOS header fields unexpected: scan_id=%d slot=%d chan=%d state=%d',
            [fHost, fPort, ABlock.HeaderWords[CMic140LegacyBiosScanIdIdx],
             ABlock.HeaderWords[CMic140LegacyBiosSlotIdx],
             ABlock.HeaderWords[CMic140LegacyBiosChanIdx],
             ABlock.HeaderWords[CMic140LegacyBiosStateIdx]]));
          Continue;
        end;
        if Length(lWords) < lMessageSize then
        begin
          RecorderDebugLog(Format(
            '[MIC-140:%s:%d] Legacy scan MDP short: headerSize=%d mdpWords=%d mdpResync=%d',
            [fHost, fPort, lMessageSize, Length(lWords), fMdpResyncBytes]));
          Continue;
        end;
        if Length(lWords) <> lMessageSize then
          RecorderDebugLog(Format(
            '[MIC-140:%s:%d] Legacy scan MDP extra words: headerSize=%d mdpWords=%d mdpResync=%d',
            [fHost, fPort, lMessageSize, Length(lWords), fMdpResyncBytes]));

        lDataCount := lMessageSize - CLegacyScanHeaderWords;
        SetLength(ABlock.DataWords, lDataCount);
        for I := 0 to lDataCount - 1 do
          ABlock.DataWords[I] := lWords[I + CLegacyScanHeaderWords];

        Result := True;
        Exit;
      end;
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

function RecorderMic140HostLastOctet(const AHost: string; out AOctet: Integer): Boolean;
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

function RecorderMic140DeviceSerialFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Integer;
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

function RecorderMic140DisplaySerialFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware; const AHost: string): Integer;
var
  lHostOctet: Integer;
begin
  Result := 0;
  { DevSerNo на Ethernet MIC часто совпадает с последним октетом IP, не с с/н MIC. }
  if RecorderMic140HostLastOctet(AHost, lHostOctet) and
     (Integer(AFirmware.DevSerNo) = lHostOctet) then
  begin
    if Mic140FirmwareWordIsPlausibleDeviceSerial(AFirmware.CCSerNo) then
      Exit(AFirmware.CCSerNo);
    Exit(0);
  end;
  Result := RecorderMic140DeviceSerialFromFirmware(AFirmware);
end;

function RecorderMic140HardwareCalibrSerialFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Integer;
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

function RecorderMic140DevRevFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Word;
begin
  { CMIC140::GetDevRev: PROP_REV = DeviceInfo.RevisionNo = bios_info.cfg.DevRevNo. }
  Result := AFirmware.DevRevNo and $FF;
end;

function RecorderMic140DevSubRevFromFirmware(
  const AFirmware: TRecorderMic140LegacyFirmware): Word;
begin
  Result := (AFirmware.DevRevNo shr 8) and $FF;
end;

function RecorderMic140FirmwareVersionText(
  const AFirmware: TRecorderMic140LegacyFirmware): string;
begin
  Result := Format('%u.%u.%u.%u', [
    RecorderMic140DevRevFromFirmware(AFirmware),
    RecorderMic140DevSubRevFromFirmware(AFirmware),
    AFirmware.BiosVersion,
    AFirmware.BiosFunction]);
end;

end.
