unit uRecorderMebiusTcpProtocol;

{
  Cross-platform subset of the Mebius Ethernet/TCP protocol used by MIC-140.

  The code mirrors the original Recorder CTCPLink/IoCtlMacro layer:
    MEBE_PACKET header + MEB_IOCTL_COMMAND body for IoControl calls;
    DATA_TRANSMIT_TASK_ID packets for measurement data.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ssockets;

type
  ERecorderMebiusProtocolError = class(Exception);

  TRecorderByteArray = array of Byte;
  TRecorderSingleArray = array of Single;

  TRecorderMebiusPacketKind = (mpkUnknown, mpkCommand, mpkData);

  TRecorderMebiusPacket = record
    Kind: TRecorderMebiusPacketKind;
    IdFrom: LongWord;
    IdTo: LongWord;
    Data: TRecorderByteArray;
  end;

  TRecorderMebiusFloatBlock = record
    DeviceId: LongWord;
    ChannelCount: Integer;
    SampleCount: Integer;
    Values: array of array of Single;
  end;

  TRecorderMebiusTcpClient = class
  private
    fHost: string;
    fPort: Word;
    fSocket: TInetSocket;
    fTimeoutMs: Cardinal;
    fClientTaskId: LongWord;
    function ReadBytes(var ABuffer; ACount: Integer): Boolean;
    procedure WriteBytes(const ABuffer; ACount: Integer);
    function ReadPacket(out APacket: TRecorderMebiusPacket): Boolean;
    function IoControl(AIoCode: LongWord; const AInData: TRecorderByteArray;
      AOutSize: Integer; out AOutData: TRecorderByteArray): LongInt;
  public
    constructor Create(const AHost: string; APort: Word = 4000;
      ATimeoutMs: Cardinal = 2000);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure StartMeasurement;
    procedure StopMeasurement;
    function ReadDataBlock(AChannelCount: Integer;
      out ABlock: TRecorderMebiusFloatBlock): Boolean;

    property Host: string read fHost;
    property Port: Word read fPort;
    property TimeoutMs: Cardinal read fTimeoutMs write fTimeoutMs;
  end;

function RecorderMebiusCtlCode(AType, AFunction, AMethod, AAccess: LongWord): LongWord;
function RecorderMebiusMakeTaskId(ACore, AClassId, AIndex, ASpec: LongWord): LongWord;
function RecorderMebiusBuildPacket(AIdTo, AIdFrom: LongWord;
  const AData: TRecorderByteArray): TRecorderByteArray;
function RecorderMebiusParseFloatBlock(const AData: TRecorderByteArray;
  AChannelCount: Integer; out ABlock: TRecorderMebiusFloatBlock): Boolean;

const
  REC_MEBE_PACKET_SIGNATURE = LongWord($A0A0CAFE);
  REC_MEBE_PACKET_SIGNATURE_SIZE_BIG = LongWord($A0A0CAFF);
  REC_MEBE_PACKET_HEADER_SIZE = 20;
  REC_MEB_IOCTL_COMMAND_SIGNATURE = Word($F10C);
  REC_MEB_IOCTL_COMMAND_HEADER_SIZE = 8;

  REC_CLASSID_BASE_TASKS = 200;
  REC_CLASSID_BASE_HOSTS = 1200;
  REC_MEASUREMENT_TASK_CLASSID = REC_CLASSID_BASE_TASKS + 1;
  REC_DATA_TRANSMITTER_TASK_CLASSID = REC_CLASSID_BASE_TASKS + 2;
  REC_MEASUREMENT_TASK_ID =
    (REC_MEASUREMENT_TASK_CLASSID shl 20) or (1 shl 14);
  REC_DATA_TRANSMIT_TASK_ID =
    (REC_DATA_TRANSMITTER_TASK_CLASSID shl 20) or (1 shl 14);
  REC_HOST_SETTINGS_PORT_ID =
    ((REC_CLASSID_BASE_HOSTS + 1) shl 20) or (1 shl 14);

  REC_TYPEIO_MEAS_TASK = 1;

  REC_IOCTL_MEASTASK_NULL = (REC_TYPEIO_MEAS_TASK shl 16);
  REC_IOCTL_MEASTASK_SET_SESSION_ID = (REC_TYPEIO_MEAS_TASK shl 16) or ($0009 shl 2);
  REC_IOCTL_MEASTASK_START = (REC_TYPEIO_MEAS_TASK shl 16) or ($000B shl 2);
  REC_IOCTL_MEASTASK_STOP = (REC_TYPEIO_MEAS_TASK shl 16) or ($000C shl 2);
  REC_IOCTL_MEASTASK_PROGRAM = (REC_TYPEIO_MEAS_TASK shl 16) or ($0010 shl 2);

  REC_S_MEB_OK = 0;

implementation

type
  TMebeHeader = packed record
    Signature: LongWord;
    Size: LongWord;
    IdTo: LongWord;
    IdFrom: LongWord;
    Crc: LongWord;
  end;

  TUniversalDataSampleHeader = packed record
    PacketType: Word;
    SampleCount: LongWord;
  end;

function RecorderMebiusCtlCode(AType, AFunction, AMethod, AAccess: LongWord): LongWord;
begin
  Result := (AType shl 16) or (AAccess shl 14) or (AFunction shl 2) or AMethod;
end;

function RecorderMebiusMakeTaskId(ACore, AClassId, AIndex, ASpec: LongWord): LongWord;
begin
  Result := (ACore shl 30) or (AClassId shl 20) or (AIndex shl 14) or ASpec;
end;

function MebiusHeaderCrc(const AHeader: TMebeHeader): LongWord;
begin
  Result := AHeader.Signature xor AHeader.Size xor AHeader.IdTo xor AHeader.IdFrom;
end;

procedure PutWordLE(var AData: TRecorderByteArray; AOffset: Integer; AValue: Word);
begin
  AData[AOffset] := Byte(AValue and $FF);
  AData[AOffset + 1] := Byte((AValue shr 8) and $FF);
end;

procedure PutLongLE(var AData: TRecorderByteArray; AOffset: Integer; AValue: LongWord);
begin
  AData[AOffset] := Byte(AValue and $FF);
  AData[AOffset + 1] := Byte((AValue shr 8) and $FF);
  AData[AOffset + 2] := Byte((AValue shr 16) and $FF);
  AData[AOffset + 3] := Byte((AValue shr 24) and $FF);
end;

function GetLongLE(const AData: TRecorderByteArray; AOffset: Integer): LongWord;
begin
  Result := LongWord(AData[AOffset]) or
    (LongWord(AData[AOffset + 1]) shl 8) or
    (LongWord(AData[AOffset + 2]) shl 16) or
    (LongWord(AData[AOffset + 3]) shl 24);
end;

function RecorderMebiusBuildPacket(AIdTo, AIdFrom: LongWord;
  const AData: TRecorderByteArray): TRecorderByteArray;
var
  lHeader: TMebeHeader;
  lSize: Integer;
begin
  lSize := REC_MEBE_PACKET_HEADER_SIZE + Length(AData);
  SetLength(Result, lSize);
  FillChar(lHeader, SizeOf(lHeader), 0);
  lHeader.Signature := REC_MEBE_PACKET_SIGNATURE;
  lHeader.Size := lSize;
  lHeader.IdTo := AIdTo;
  lHeader.IdFrom := AIdFrom;
  lHeader.Crc := MebiusHeaderCrc(lHeader);
  Move(lHeader, Result[0], SizeOf(lHeader));
  if Length(AData) > 0 then
    Move(AData[0], Result[REC_MEBE_PACKET_HEADER_SIZE], Length(AData));
end;

function SingleFromLE(const AData: TRecorderByteArray; AOffset: Integer): Single;
var
  lRaw: LongWord;
begin
  lRaw := GetLongLE(AData, AOffset);
  Move(lRaw, Result, SizeOf(Result));
end;

function RecorderMebiusParseFloatBlock(const AData: TRecorderByteArray;
  AChannelCount: Integer; out ABlock: TRecorderMebiusFloatBlock): Boolean;
var
  I: Integer;
  lCount: Integer;
  lDataOffset: Integer;
  lOffset: Integer;
  lSample: Integer;
begin
  FillChar(ABlock, SizeOf(ABlock), 0);
  Result := False;
  lDataOffset := SizeOf(LongWord) + SizeOf(TUniversalDataSampleHeader);
  if (AChannelCount <= 0) or (Length(AData) < lDataOffset) then
    Exit;
  lCount := GetLongLE(AData, SizeOf(LongWord) + SizeOf(Word));
  if lCount <= 0 then
    lCount := (Length(AData) - lDataOffset) div (AChannelCount * SizeOf(Single));
  if lCount <= 0 then
    Exit;
  if Length(AData) < lDataOffset + lCount * AChannelCount * SizeOf(Single) then
    Exit;

  ABlock.DeviceId := GetLongLE(AData, 0);
  ABlock.ChannelCount := AChannelCount;
  ABlock.SampleCount := lCount;
  SetLength(ABlock.Values, AChannelCount);
  for I := 0 to AChannelCount - 1 do
    SetLength(ABlock.Values[I], lCount);

  lOffset := lDataOffset;
  for lSample := 0 to lCount - 1 do
    for I := 0 to AChannelCount - 1 do
    begin
      ABlock.Values[I][lSample] := SingleFromLE(AData, lOffset);
      Inc(lOffset, SizeOf(Single));
    end;
  Result := True;
end;

constructor TRecorderMebiusTcpClient.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  fClientTaskId := REC_HOST_SETTINGS_PORT_ID;
end;

destructor TRecorderMebiusTcpClient.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

procedure TRecorderMebiusTcpClient.Connect;
begin
  Disconnect;
  fSocket := TInetSocket.Create(fHost, fPort, Integer(fTimeoutMs));
  fSocket.IOTimeout := Integer(fTimeoutMs);
end;

procedure TRecorderMebiusTcpClient.Disconnect;
begin
  FreeAndNil(fSocket);
end;

function TRecorderMebiusTcpClient.ReadBytes(var ABuffer; ACount: Integer): Boolean;
var
  lDone: Integer;
  lRead: Integer;
begin
  Result := False;
  if fSocket = nil then
    raise ERecorderMebiusProtocolError.Create('Mebius TCP socket is not connected');
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

procedure TRecorderMebiusTcpClient.WriteBytes(const ABuffer; ACount: Integer);
var
  lDone: Integer;
  lWritten: Integer;
begin
  if fSocket = nil then
    raise ERecorderMebiusProtocolError.Create('Mebius TCP socket is not connected');
  lDone := 0;
  while lDone < ACount do
  begin
    lWritten := fSocket.Write((PByte(@ABuffer) + lDone)^, ACount - lDone);
    if lWritten <= 0 then
      raise ERecorderMebiusProtocolError.Create('Mebius TCP write failed');
    Inc(lDone, lWritten);
  end;
end;

function TRecorderMebiusTcpClient.ReadPacket(out APacket: TRecorderMebiusPacket): Boolean;
var
  lBodySize: Integer;
  lHeader: TMebeHeader;
begin
  FillChar(APacket, SizeOf(APacket), 0);
  Result := False;
  if not ReadBytes(lHeader, SizeOf(lHeader)) then
    Exit;
  if (lHeader.Signature <> REC_MEBE_PACKET_SIGNATURE) and
    (lHeader.Signature <> REC_MEBE_PACKET_SIGNATURE_SIZE_BIG) then
    raise ERecorderMebiusProtocolError.CreateFmt(
      'Unexpected Mebius packet signature: %.8x', [lHeader.Signature]);
  if lHeader.Crc <> MebiusHeaderCrc(lHeader) then
    raise ERecorderMebiusProtocolError.Create('Mebius packet header CRC mismatch');
  if lHeader.Size < REC_MEBE_PACKET_HEADER_SIZE then
    raise ERecorderMebiusProtocolError.Create('Mebius packet size is invalid');

  lBodySize := lHeader.Size - REC_MEBE_PACKET_HEADER_SIZE;
  SetLength(APacket.Data, lBodySize);
  if (lBodySize > 0) and (not ReadBytes(APacket.Data[0], lBodySize)) then
    Exit;

  APacket.IdFrom := lHeader.IdFrom;
  APacket.IdTo := lHeader.IdTo;
  if (lHeader.IdFrom = REC_DATA_TRANSMIT_TASK_ID) or (lHeader.IdFrom = $3E904000) then
    APacket.Kind := mpkData
  else
    APacket.Kind := mpkCommand;
  Result := True;
end;

function TRecorderMebiusTcpClient.IoControl(AIoCode: LongWord;
  const AInData: TRecorderByteArray; AOutSize: Integer;
  out AOutData: TRecorderByteArray): LongInt;
var
  lBody: TRecorderByteArray;
  lPacket: TRecorderByteArray;
  lReply: TRecorderMebiusPacket;
  lReplyCode: LongWord;
begin
  SetLength(lBody, REC_MEB_IOCTL_COMMAND_HEADER_SIZE + Length(AInData));
  PutWordLE(lBody, 0, REC_MEB_IOCTL_COMMAND_SIGNATURE);
  PutWordLE(lBody, 2, REC_MEB_IOCTL_COMMAND_SIGNATURE);
  PutLongLE(lBody, 4, AIoCode);
  if Length(AInData) > 0 then
    Move(AInData[0], lBody[REC_MEB_IOCTL_COMMAND_HEADER_SIZE], Length(AInData));
  lPacket := RecorderMebiusBuildPacket(REC_MEASUREMENT_TASK_ID, fClientTaskId, lBody);
  WriteBytes(lPacket[0], Length(lPacket));

  repeat
    if not ReadPacket(lReply) then
      raise ERecorderMebiusProtocolError.Create('Mebius IoControl timeout');
  until lReply.Kind = mpkCommand;

  if Length(lReply.Data) < REC_MEB_IOCTL_COMMAND_HEADER_SIZE then
    raise ERecorderMebiusProtocolError.Create('Mebius IoControl reply is too short');
  lReplyCode := GetLongLE(lReply.Data, 4);
  if lReplyCode = REC_IOCTL_MEASTASK_NULL then
    raise ERecorderMebiusProtocolError.Create('Mebius device returned IOCTL_MEASTASK_NULL');
  if lReplyCode <> AIoCode then
    raise ERecorderMebiusProtocolError.CreateFmt(
      'Unexpected Mebius IoControl reply %.8x for %.8x', [lReplyCode, AIoCode]);

  SetLength(AOutData, Length(lReply.Data) - REC_MEB_IOCTL_COMMAND_HEADER_SIZE);
  if Length(AOutData) > 0 then
    Move(lReply.Data[REC_MEB_IOCTL_COMMAND_HEADER_SIZE], AOutData[0],
      Length(AOutData));
  if (AOutSize > 0) and (Length(AOutData) < AOutSize) then
    raise ERecorderMebiusProtocolError.Create('Mebius IoControl reply is shorter than expected');
  if Length(AOutData) >= SizeOf(LongInt) then
    Move(AOutData[0], Result, SizeOf(Result))
  else
    Result := REC_S_MEB_OK;
end;

procedure TRecorderMebiusTcpClient.StartMeasurement;
var
  lOut: TRecorderByteArray;
begin
  IoControl(REC_IOCTL_MEASTASK_START, nil, SizeOf(LongInt), lOut);
end;

procedure TRecorderMebiusTcpClient.StopMeasurement;
var
  lOut: TRecorderByteArray;
begin
  IoControl(REC_IOCTL_MEASTASK_STOP, nil, SizeOf(LongInt), lOut);
end;

function TRecorderMebiusTcpClient.ReadDataBlock(AChannelCount: Integer;
  out ABlock: TRecorderMebiusFloatBlock): Boolean;
var
  lPacket: TRecorderMebiusPacket;
begin
  Result := False;
  if not ReadPacket(lPacket) then
    Exit;
  if lPacket.Kind <> mpkData then
    Exit;
  Result := RecorderMebiusParseFloatBlock(lPacket.Data, AChannelCount, ABlock);
end;

end.
