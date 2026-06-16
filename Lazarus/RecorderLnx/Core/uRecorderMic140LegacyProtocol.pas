unit uRecorderMic140LegacyProtocol;

{
  MIC-140 48/96 legacy Ethernet protocol.

  This protocol is used by original Recorder modules MIC140_96_rce through
  mdpEthernet81/MC031. It is not compatible with Mebius MEBE packets.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ssockets;

type
  ERecorderMic140LegacyProtocol = class(Exception);

  TRecorderMic140LegacyWordArray = array of Word;
  TRecorderMic140LegacyByteArray = array of Byte;

  TRecorderMic140LegacyFirmware = record
    MdpType: Word;
    DeviceType: Word;
    DeviceRevision: Word;
    DeviceSerial: Word;
    ControllerType: Word;
    ControllerSerial: Word;
    BiosFunction: Word;
    BiosRevision: Word;
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
    function ReadBytes(var ABuffer; ACount: Integer): Boolean;
    function EnsureRxBytes(ACount: Integer): Boolean;
    procedure DropRxBytes(ACount: Integer);
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

    property Host: string read fHost;
    property Port: Word read fPort;
    property TimeoutMs: Cardinal read fTimeoutMs write SetTimeoutMs;
  end;

const
  MIC140_LEGACY_CMD_REPLY = 113;
  MIC140_LEGACY_CMD_WRITE_DM = 111;
  MIC140_LEGACY_CMD_START_SCAN_MAIN = 80;
  MIC140_LEGACY_CMD_STOP_SCAN_MAIN = 81;
  MIC140_LEGACY_DM_FLAG = Word($4000);

implementation

const
  CLegacySyncWord = Word($12B8);
  CLegacyStreamScan = Word(0);
  CLegacyStreamCommand = Word(1);
  CLegacyMaxPacketWords = 1024;
  CLegacyMaxWriteDmDataWords = 31;
  CLegacyHeaderBytes = 8;
  CLegacyScanHeaderWords = 10;

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
end;

destructor TRecorderMic140LegacyClient.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

procedure TRecorderMic140LegacyClient.Connect;
begin
  Disconnect;
  fSocket := TInetSocket.Create(fHost, fPort, Integer(fTimeoutMs));
  SetTimeoutMs(fTimeoutMs);
end;

procedure TRecorderMic140LegacyClient.Disconnect;
begin
  SetLength(fRxBuffer, 0);
  FreeAndNil(fSocket);
end;

procedure TRecorderMic140LegacyClient.ClearBufferedPackets;
begin
  SetLength(fRxBuffer, 0);
end;

procedure TRecorderMic140LegacyClient.SetTimeoutMs(AValue: Cardinal);
begin
  if AValue = 0 then
    AValue := 1;
  fTimeoutMs := AValue;
  if fSocket <> nil then
    fSocket.IOTimeout := Integer(fTimeoutMs);
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

procedure TRecorderMic140LegacyClient.DropRxBytes(ACount: Integer);
var
  lRemain: Integer;
begin
  if ACount <= 0 then
    Exit;
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
      DropRxBytes(1);
      Continue;
    end;

    APort := GetWordLE(fRxBuffer, 2);
    lSizeWords := GetWordLE(fRxBuffer, 4);
    lHeaderSum := Word((LongWord(CLegacySyncWord) + APort + lSizeWords) and $FFFF);
    if (GetWordLE(fRxBuffer, 6) <> lHeaderSum) or
      (lSizeWords > CLegacyMaxPacketWords) then
    begin
      DropRxBytes(1);
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
      DropRxBytes(1);
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
  Result := CallCommand(MIC140_LEGACY_CMD_REPLY, nil, 10, lReply, AErrorMessage);
  if not Result then
    Exit;
  AFirmware.MdpType := lReply[1];
  AFirmware.DeviceType := lReply[2];
  AFirmware.DeviceRevision := lReply[3];
  AFirmware.DeviceSerial := lReply[4];
  AFirmware.ControllerType := lReply[5];
  AFirmware.ControllerSerial := lReply[6];
  AFirmware.BiosFunction := lReply[8];
  AFirmware.BiosRevision := lReply[9];
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

function TRecorderMic140LegacyClient.ReadScanBlock(
  out ABlock: TRecorderMic140LegacyScanBlock; out AErrorMessage: string): Boolean;
var
  I: Integer;
  lDataCount: Integer;
  lPort: Word;
  lWords: TRecorderMic140LegacyWordArray;
begin
  Result := False;
  AErrorMessage := '';
  SetLength(ABlock.HeaderWords, 0);
  SetLength(ABlock.DataWords, 0);
  try
    repeat
      if not ReadPacket(lPort, lWords) then
      begin
        AErrorMessage := 'MIC-140 legacy scan timeout';
        Exit;
      end;
    until lPort = CLegacyStreamScan;

    if Length(lWords) < CLegacyScanHeaderWords then
    begin
      AErrorMessage := Format('MIC-140 legacy scan packet is too short: %d',
        [Length(lWords)]);
      Exit;
    end;

    // Original Recorder skips sizeof(THeaderMessage) before decommutation.
    // devapi/Types.h defines THeaderMessage as 10 WORDs; using fewer words
    // shifts time/buffer fields into channel data and makes values jump.
    SetLength(ABlock.HeaderWords, CLegacyScanHeaderWords);
    for I := 0 to High(ABlock.HeaderWords) do
      ABlock.HeaderWords[I] := lWords[I];

    lDataCount := Length(lWords) - Length(ABlock.HeaderWords);
    SetLength(ABlock.DataWords, lDataCount);
    for I := 0 to lDataCount - 1 do
      ABlock.DataWords[I] := lWords[I + Length(ABlock.HeaderWords)];

    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

end.
