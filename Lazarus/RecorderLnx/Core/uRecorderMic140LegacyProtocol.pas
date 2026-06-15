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

  TRecorderMic140LegacyClient = class
  private
    fHost: string;
    fPort: Word;
    fSocket: TInetSocket;
    fTimeoutMs: Cardinal;
    function ReadBytes(var ABuffer; ACount: Integer): Boolean;
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
    function ReadFirmware(out AFirmware: TRecorderMic140LegacyFirmware;
      out AErrorMessage: string): Boolean;

    property Host: string read fHost;
    property Port: Word read fPort;
    property TimeoutMs: Cardinal read fTimeoutMs write fTimeoutMs;
  end;

const
  MIC140_LEGACY_CMD_REPLY = 113;

implementation

const
  CLegacySyncWord = Word($12B8);
  CLegacyStreamCommand = Word(1);
  CLegacyMaxPacketWords = 1024;
  CLegacyHeaderBytes = 8;

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
  fSocket.IOTimeout := Integer(fTimeoutMs);
end;

procedure TRecorderMic140LegacyClient.Disconnect;
begin
  FreeAndNil(fSocket);
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
  lBytes: array of Byte;
  lDataSum: LongWord;
  lHeader: array[0..CLegacyHeaderBytes - 1] of Byte;
  lHeaderSum: Word;
  lSizeWords: Word;
begin
  Result := False;
  APort := 0;
  SetLength(AWords, 0);
  if not ReadBytes(lHeader[0], SizeOf(lHeader)) then
    Exit;
  if GetWordLE(lHeader, 0) <> CLegacySyncWord then
    raise ERecorderMic140LegacyProtocol.Create('MIC-140 legacy packet sync mismatch');
  APort := GetWordLE(lHeader, 2);
  lSizeWords := GetWordLE(lHeader, 4);
  lHeaderSum := Word((LongWord(CLegacySyncWord) + APort + lSizeWords) and $FFFF);
  if GetWordLE(lHeader, 6) <> lHeaderSum then
    raise ERecorderMic140LegacyProtocol.Create('MIC-140 legacy packet header checksum mismatch');

  SetLength(lBytes, (Integer(lSizeWords) + 1) * SizeOf(Word));
  if (Length(lBytes) > 0) and (not ReadBytes(lBytes[0], Length(lBytes))) then
    Exit;

  SetLength(AWords, lSizeWords);
  lDataSum := 0;
  for I := 0 to lSizeWords - 1 do
  begin
    AWords[I] := GetWordLE(lBytes, I * SizeOf(Word));
    Inc(lDataSum, AWords[I]);
  end;
  if GetWordLE(lBytes, lSizeWords * SizeOf(Word)) <> Word(lDataSum and $FFFF) then
    raise ERecorderMic140LegacyProtocol.Create('MIC-140 legacy packet data checksum mismatch');
  Result := True;
end;

function TRecorderMic140LegacyClient.CallCommand(ACommand: Word;
  const AArgs: TRecorderMic140LegacyWordArray; ARetWordCount: Integer;
  out ARet: TRecorderMic140LegacyWordArray; out AErrorMessage: string): Boolean;
var
  lPort: Word;
  lRequest: TRecorderMic140LegacyWordArray;
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
    if not ReadPacket(lPort, ARet) then
    begin
      AErrorMessage := 'MIC-140 legacy command timeout';
      Exit;
    end;
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

end.
