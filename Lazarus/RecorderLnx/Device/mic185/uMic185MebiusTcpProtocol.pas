unit uMic185MebiusTcpProtocol;

{
  Cross-platform subset of the Mebius Ethernet/TCP protocol (MIC185V2 stand).

  Mirrors original Recorder CTCPLink/IoCtlMacro layer:
    MEBE_PACKET header + MEB_IOCTL_COMMAND body for IoControl calls;
    DATA_TRANSMIT_TASK_ID packets for measurement data.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sockets, ssockets;

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
    HeaderSampleCount: LongWord;
    Values: array of array of Single;
  end;

  TRecorderMebiusTcpClient = class
  private
    fHost: string;
    fPort: Word;
    fSocket: TInetSocket;
    fTimeoutMs: Cardinal;
    fClientTaskId: LongWord;
    fRxDataPacketCount: Int64;
    procedure ApplySocketTimeout;
    procedure SetTimeoutMs(AValue: Cardinal);
    function ReadBytes(var ABuffer; ACount: Integer): Boolean;
    function TryWriteBytes(const ABuffer; ACount: Integer;
      out AErrorText: string): Boolean;
    procedure WriteBytes(const ABuffer; ACount: Integer);
    function ReadPacket(out APacket: TRecorderMebiusPacket): Boolean;
    function IoControl(AIoCode: LongWord; const AInData: TRecorderByteArray;
      AOutSize: Integer; out AOutData: TRecorderByteArray): LongInt;
    function TryIoControl(AIoCode: LongWord; const AInData: TRecorderByteArray;
      AOutSize: Integer; out AOutData: TRecorderByteArray;
      out AErrorMessage: string): Boolean;
  public
    constructor Create(const AHost: string; APort: Word = 4000;
      ATimeoutMs: Cardinal = 2000);
    destructor Destroy; override;

    function TryConnect(out AErrorText: string): Boolean;
    procedure Connect;
    procedure Disconnect;
    procedure StartMeasurement;
    procedure StopMeasurement;
    function TrySetSessionId(ASessionId: LongWord; out AErrorMessage: string): Boolean;
    function TryCallCommand(ACommand: LongWord; const AInData: TRecorderByteArray;
      AOutSize: Integer; out AOutData: TRecorderByteArray;
      out AErrorMessage: string): Boolean;
    function TryProgramDeviceBin(const ASettings: TRecorderByteArray;
      out AErrorMessage: string): Boolean;
    function TryProgramMeasurement(out AErrorMessage: string): Boolean;
    function TryStartMeasurement(out AErrorMessage: string): Boolean;
    function TryStopMeasurement(out AErrorMessage: string): Boolean;
    function ReadDataBlock(AChannelCount: Integer;
      out ABlock: TRecorderMebiusFloatBlock): Boolean;
    function ReadMeasDataBlock(AChannelCount: Integer;
      out ABlock: TRecorderMebiusFloatBlock;
      out ATempValues: TRecorderSingleArray; out AHasTemp: Boolean;
      out AUtsValue: Single; out AHasUts: Boolean): Boolean;
    function SniffPackets(APacketCount: Integer; ATimeoutMs: Cardinal): Integer;

    property Host: string read fHost;
    property Port: Word read fPort;
    property TimeoutMs: Cardinal read fTimeoutMs write SetTimeoutMs;
    property RxDataPacketCount: Int64 read fRxDataPacketCount;
    procedure ResetRxCounters;
  end;

{ Собирает IOCTL code по той же битовой раскладке, что IoCtlMacro.h. }
function RecorderMebiusCtlCode(AType, AFunction, AMethod, AAccess: LongWord): LongWord;
{ Собирает task id Mebius из core/class/index/spec для заголовка MEBE_PACKET. }
function RecorderMebiusMakeTaskId(ACore, AClassId, AIndex, ASpec: LongWord): LongWord;
{ Упаковывает полезные данные в сетевой MEBE_PACKET с checksum заголовка. }
function RecorderMebiusBuildPacket(AIdTo, AIdFrom: LongWord;
  const AData: TRecorderByteArray): TRecorderByteArray;
{ Разбирает пакет измерительных Single-значений в матрицу channel x sample. }
function RecorderMebiusParseFloatBlock(const AData: TRecorderByteArray;
  AChannelCount: Integer; out ABlock: TRecorderMebiusFloatBlock): Boolean;
{ Читает dev_id из начала Mebius DATA_TRANSMIT payload. }
function Mic185PacketDeviceId(const AData: TRecorderByteArray): LongWord;
{ Переводит 13-битный код LM74 в градусы C. }
function Mic185ConvLM74CodeToC(ACode: Word): Single;
{ Разбирает температурный DATA_TRANSMIT payload в массив градусов C. }
function Mic185ParseTempValues(const AData: TRecorderByteArray;
  AChannelCount: Integer; out AValues: TRecorderSingleArray): Boolean;
{ Разбирает UTS/SEV значение времени из отдельного DATA_TRANSMIT payload. }
function Mic185ParseUtsValue(const AData: TRecorderByteArray;
  out AValue: Single): Boolean;

const
  { Заголовок сетевого пакета Mebius Ethernet. }
  REC_MEBE_PACKET_SIGNATURE = LongWord($A0A0CAFE);
  REC_MEBE_PACKET_SIGNATURE_SIZE_BIG = LongWord($A0A0CAFF);
  REC_MEBE_PACKET_HEADER_SIZE = 20;
  { Заголовок тела MEB_IOCTL_COMMAND внутри командного пакета. }
  REC_MEB_IOCTL_COMMAND_SIGNATURE = Word($F10C);
  REC_MEB_IOCTL_COMMAND_HEADER_SIZE = 8;

  { Базовые идентификаторы задач/портов Mebius. }
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

  { IOCTL-команды задачи измерения MIC185V2. }
  REC_TYPEIO_MEAS_TASK = 1;

  REC_IOCTL_MEASTASK_NULL = (REC_TYPEIO_MEAS_TASK shl 16);
  REC_IOCTL_MEASTASK_SET_SESSION_ID = (REC_TYPEIO_MEAS_TASK shl 16) or ($0009 shl 2);
  REC_IOCTL_MEASTASK_PROGRAMM_DEVICE_BIN = (REC_TYPEIO_MEAS_TASK shl 16) or ($000A shl 2);
  REC_IOCTL_MEASTASK_START = (REC_TYPEIO_MEAS_TASK shl 16) or ($000B shl 2);
  REC_IOCTL_MEASTASK_STOP = (REC_TYPEIO_MEAS_TASK shl 16) or ($000C shl 2);
  REC_IOCTL_MEASTASK_CALL_COMMAND = (REC_TYPEIO_MEAS_TASK shl 16) or ($000D shl 2);
  REC_IOCTL_MEASTASK_PROGRAM = (REC_TYPEIO_MEAS_TASK shl 16) or ($0010 shl 2);

  { Код успешного ответа Mebius. }
  REC_S_MEB_OK = 0;

implementation

uses
  uMic185Constants, uMic185DebugLog, uRecorderMic185Runtime;

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
    _AlignPad: Word;  { MSVC выравнивает ULONG sampl_count_ на 4 }
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

function GetWordLE(const AData: TRecorderByteArray; AOffset: Integer): Word;
begin
  Result := Word(AData[AOffset]) or (Word(AData[AOffset + 1]) shl 8);
end;

function Mic185MeasSamplesInPacket(const AData: TRecorderByteArray;
  AChannelCount: Integer): Integer;
var
  lDataOffset: Integer;
  lPayloadBytes: Integer;
  lPacketType: Word;
begin
  Result := 0;
  lDataOffset := CMic185PacketDataOffset;
  if (AChannelCount <= 0) or (Length(AData) < lDataOffset) then
    Exit;
  lPacketType := GetWordLE(AData, CMic185PacketDeviceIdSize);
  lPayloadBytes := Length(AData) - lDataOffset;
  { Статус по каналам присутствует при type_ <> 0 (UniversalDataSample.h). }
  if lPacketType <> 0 then
    Dec(lPayloadBytes, AChannelCount * SizeOf(LongWord));
  if lPayloadBytes <= 0 then
    Exit;
  Result := lPayloadBytes div (AChannelCount * SizeOf(Single));
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
  lHeaderCount: LongWord;
begin
  FillChar(ABlock, SizeOf(ABlock), 0);
  Result := False;
  lDataOffset := CMic185PacketDataOffset;
  if (AChannelCount <= 0) or (Length(AData) < lDataOffset) then
    Exit;

  { sampl_count_ в пакете — сквозной счётчик (см. MIC185V2scan.cpp), не размер блока. }
  lCount := Mic185MeasSamplesInPacket(AData, AChannelCount);
  if lCount <= 0 then
    Exit;

  lHeaderCount := GetLongLE(AData, CMic185PacketDeviceIdSize + SizeOf(Word) * 2);
  if Length(AData) < lDataOffset + lCount * AChannelCount * SizeOf(Single) then
    Exit;

  ABlock.DeviceId := GetLongLE(AData, 0);
  ABlock.ChannelCount := AChannelCount;
  ABlock.SampleCount := lCount;
  ABlock.HeaderSampleCount := lHeaderCount;
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

procedure ClearMebiusFloatBlock(var ABlock: TRecorderMebiusFloatBlock);
begin
  SetLength(ABlock.Values, 0);
  ABlock.DeviceId := 0;
  ABlock.ChannelCount := 0;
  ABlock.SampleCount := 0;
  ABlock.HeaderSampleCount := 0;
end;

function AppendMebiusFloatBlock(var ADest: TRecorderMebiusFloatBlock;
  const ASrc: TRecorderMebiusFloatBlock): Boolean;
var
  I: Integer;
  lOldCount: Integer;
  lNewCount: Integer;
begin
  Result := False;
  if (ASrc.ChannelCount <= 0) or (ASrc.SampleCount <= 0) then
    Exit;

  if ADest.SampleCount = 0 then
  begin
    ADest.DeviceId := ASrc.DeviceId;
    ADest.ChannelCount := ASrc.ChannelCount;
    ADest.HeaderSampleCount := ASrc.HeaderSampleCount;
    SetLength(ADest.Values, ASrc.ChannelCount);
    for I := 0 to ASrc.ChannelCount - 1 do
    begin
      SetLength(ADest.Values[I], ASrc.SampleCount);
      Move(ASrc.Values[I][0], ADest.Values[I][0],
        ASrc.SampleCount * SizeOf(Single));
    end;
    ADest.SampleCount := ASrc.SampleCount;
    Exit(True);
  end;

  if (ADest.DeviceId <> ASrc.DeviceId) or
    (ADest.ChannelCount <> ASrc.ChannelCount) then
    Exit;

  lOldCount := ADest.SampleCount;
  lNewCount := lOldCount + ASrc.SampleCount;
  for I := 0 to ADest.ChannelCount - 1 do
  begin
    SetLength(ADest.Values[I], lNewCount);
    Move(ASrc.Values[I][0], ADest.Values[I][lOldCount],
      ASrc.SampleCount * SizeOf(Single));
  end;
  ADest.SampleCount := lNewCount;
  ADest.HeaderSampleCount := ASrc.HeaderSampleCount;
  Result := True;
end;

function Mic185PacketDeviceId(const AData: TRecorderByteArray): LongWord;
begin
  if Length(AData) < SizeOf(LongWord) then
    Result := LongWord($FFFFFFFF)
  else
    Result := GetLongLE(AData, 0);
end;

{ CMIC185V2Base::ConvLM74CodeToC — градусы из кода LM74, без таблицы ГХ. }
function Mic185ConvLM74CodeToC(ACode: Word): Single;
var
  lSign: Single;
  lConvCode: Word;
begin
  lSign := 1.0;
  lConvCode := ACode;
  if (ACode and CMic185TempNegValueMask) <> 0 then
  begin
    lSign := -1.0;
    lConvCode := (not ACode and $0FFF) + 1;
  end;
  Result := lConvCode * lSign * CMic185TempCodesToValueCoeff;
end;

function Mic185ParseTempValues(const AData: TRecorderByteArray;
  AChannelCount: Integer; out AValues: TRecorderSingleArray): Boolean;
var
  I: Integer;
  lOffset: Integer;
  lRaw: Single;
  lCode: Word;
  lDegC: Single;
begin
  SetLength(AValues, 0);
  Result := False;
  lOffset := SizeOf(LongWord) + SizeOf(TUniversalDataSampleHeader);
  if (AChannelCount <= 0) or
    (Length(AData) < lOffset + AChannelCount * SizeOf(Single)) then
    Exit;
  SetLength(AValues, AChannelCount);
  for I := 0 to AChannelCount - 1 do
  begin
    lRaw := SingleFromLE(AData, lOffset + I * SizeOf(Single));
    lCode := Word(Trunc(lRaw));
    lDegC := Mic185ConvLM74CodeToC(lCode);
    if (lDegC < CMic185TempMinRangeC) or (lDegC > CMic185TempMaxRangeC) then
      lDegC := CMic185BrokenSensorTempC;
    AValues[I] := lDegC;
  end;
  Result := True;
end;

function Mic185ParseUtsValue(const AData: TRecorderByteArray;
  out AValue: Single): Boolean;
var
  lOffset: Integer;
begin
  AValue := 0;
  Result := False;
  lOffset := SizeOf(LongWord) + SizeOf(TUniversalDataSampleHeader);
  if Length(AData) < lOffset + SizeOf(Single) then
    Exit;
  AValue := SingleFromLE(AData, lOffset);
  Result := True;
end;

procedure TRecorderMebiusTcpClient.ApplySocketTimeout;
begin
  if fSocket <> nil then
    fSocket.IOTimeout := Integer(fTimeoutMs);
end;

procedure TRecorderMebiusTcpClient.SetTimeoutMs(AValue: Cardinal);
begin
  fTimeoutMs := AValue;
  ApplySocketTimeout;
end;

constructor TRecorderMebiusTcpClient.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  fClientTaskId := REC_HOST_SETTINGS_PORT_ID;
  fRxDataPacketCount := 0;
end;

procedure TRecorderMebiusTcpClient.ResetRxCounters;
begin
  fRxDataPacketCount := 0;
end;

destructor TRecorderMebiusTcpClient.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

function TRecorderMebiusTcpClient.TryConnect(out AErrorText: string): Boolean;
begin
  Result := False;
  AErrorText := '';
  Disconnect;
  if Trim(fHost) = '' then
  begin
    AErrorText := 'MIC183/185 host is not set';
    Exit;
  end;
  if RecorderMic185RuntimeHasForeignTcpClient(fHost, fPort, Self) then
  begin
    AErrorText := Format(
      'MIC183/185 %s:%d already has an active TCP client in RecorderLnx',
      [fHost, fPort]);
    Exit;
  end;
  if RecorderMic185RuntimeIsBusy(fHost, fPort) then
  begin
    AErrorText := Format('MIC183/185 %s:%d is busy by active RecorderLnx session',
      [fHost, fPort]);
    Exit;
  end;
  try
    fSocket := TInetSocket.Create(fHost, fPort, Integer(fTimeoutMs));
{$ifdef unix}
    fSocket.WriteFlags := fSocket.WriteFlags or MSG_NOSIGNAL;
{$endif}
    ApplySocketTimeout;
    RecorderMic185RuntimeRegisterTcpClient(Self, fHost, fPort);
    Result := True;
  except
    on E: Exception do
      AErrorText := E.Message;
  end;
end;

procedure TRecorderMebiusTcpClient.Connect;
var
  lErrorText: string;
begin
  if not TryConnect(lErrorText) then
    raise ERecorderMebiusProtocolError.CreateFmt(
      'MIC183/185 TCP connect to %s:%d failed: %s', [fHost, fPort, lErrorText]);
end;

procedure TRecorderMebiusTcpClient.Disconnect;
begin
  FreeAndNil(fSocket);
  RecorderMic185RuntimeUnregisterTcpClient(Self);
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
  lErrorText: string;
begin
  if not TryWriteBytes(ABuffer, ACount, lErrorText) then
    raise ERecorderMebiusProtocolError.Create(lErrorText);
end;

function TRecorderMebiusTcpClient.TryWriteBytes(const ABuffer; ACount: Integer;
  out AErrorText: string): Boolean;
var
  lDone: Integer;
  lWritten: Integer;
begin
  Result := False;
  AErrorText := '';
  if fSocket = nil then
  begin
    AErrorText := 'Mebius TCP socket is not connected';
    Exit;
  end;
  lDone := 0;
  try
    while lDone < ACount do
    begin
      lWritten := fSocket.Write((PByte(@ABuffer) + lDone)^, ACount - lDone);
      if lWritten <= 0 then
      begin
        AErrorText := 'Mebius TCP write failed';
        Exit;
      end;
      Inc(lDone, lWritten);
    end;
    Result := True;
  except
    on E: Exception do
      AErrorText := E.Message;
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
  lErrorMessage: string;
begin
  if not TryIoControl(AIoCode, AInData, AOutSize, AOutData, lErrorMessage) then
    raise ERecorderMebiusProtocolError.Create(lErrorMessage);
  if Length(AOutData) >= SizeOf(LongInt) then
    Move(AOutData[0], Result, SizeOf(Result))
  else
    Result := REC_S_MEB_OK;
end;

function TRecorderMebiusTcpClient.TryIoControl(AIoCode: LongWord;
  const AInData: TRecorderByteArray; AOutSize: Integer;
  out AOutData: TRecorderByteArray; out AErrorMessage: string): Boolean;
var
  lBody: TRecorderByteArray;
  lPacket: TRecorderByteArray;
  lReply: TRecorderMebiusPacket;
  lReplyCode: LongWord;
begin
  Result := False;
  AErrorMessage := '';
  SetLength(AOutData, 0);
  try
    SetLength(lBody, REC_MEB_IOCTL_COMMAND_HEADER_SIZE + Length(AInData));
    PutWordLE(lBody, 0, REC_MEB_IOCTL_COMMAND_SIGNATURE);
    PutWordLE(lBody, 2, REC_MEB_IOCTL_COMMAND_SIGNATURE);
    PutLongLE(lBody, 4, AIoCode);
    if Length(AInData) > 0 then
      Move(AInData[0], lBody[REC_MEB_IOCTL_COMMAND_HEADER_SIZE], Length(AInData));
    lPacket := RecorderMebiusBuildPacket(REC_MEASUREMENT_TASK_ID, fClientTaskId, lBody);
    if not TryWriteBytes(lPacket[0], Length(lPacket), AErrorMessage) then
      Exit;

    while True do
    begin
      if not ReadPacket(lReply) then
      begin
        AErrorMessage := 'Mebius IoControl timeout';
        Exit;
      end;
      if lReply.Kind = mpkData then
        Continue;
      Break;
    end;

    if Length(lReply.Data) < REC_MEB_IOCTL_COMMAND_HEADER_SIZE then
    begin
      AErrorMessage := 'Mebius IoControl reply is too short';
      Exit;
    end;
    lReplyCode := GetLongLE(lReply.Data, 4);
    if lReplyCode = REC_IOCTL_MEASTASK_NULL then
    begin
      AErrorMessage := 'Mebius device returned IOCTL_MEASTASK_NULL';
      Exit;
    end;
    if lReplyCode <> AIoCode then
    begin
      AErrorMessage := Format(
        'Unexpected Mebius IoControl reply %.8x for %.8x', [lReplyCode, AIoCode]);
      Exit;
    end;

    SetLength(AOutData, Length(lReply.Data) - REC_MEB_IOCTL_COMMAND_HEADER_SIZE);
    if Length(AOutData) > 0 then
      Move(lReply.Data[REC_MEB_IOCTL_COMMAND_HEADER_SIZE], AOutData[0],
        Length(AOutData));
    if (AOutSize > 0) and (Length(AOutData) < AOutSize) then
    begin
      AErrorMessage := 'Mebius IoControl reply is shorter than expected';
      Exit;
    end;
    Result := True;
  except
    on E: Exception do
      AErrorMessage := E.Message;
  end;
end;

procedure TRecorderMebiusTcpClient.StartMeasurement;
var
  lOut: TRecorderByteArray;
begin
  IoControl(REC_IOCTL_MEASTASK_START, nil, SizeOf(LongInt), lOut);
end;

function TRecorderMebiusTcpClient.TrySetSessionId(ASessionId: LongWord;
  out AErrorMessage: string): Boolean;
var
  lIn: TRecorderByteArray;
  lOut: TRecorderByteArray;
begin
  SetLength(lIn, SizeOf(ASessionId));
  Move(ASessionId, lIn[0], SizeOf(ASessionId));
  Result := TryIoControl(REC_IOCTL_MEASTASK_SET_SESSION_ID, lIn, SizeOf(LongInt),
    lOut, AErrorMessage);
end;

function TRecorderMebiusTcpClient.TryCallCommand(ACommand: LongWord;
  const AInData: TRecorderByteArray; AOutSize: Integer;
  out AOutData: TRecorderByteArray; out AErrorMessage: string): Boolean;
var
  lBlock: TRecorderByteArray;
  lOut: TRecorderByteArray;
  lPayloadSize: Integer;
begin
  SetLength(AOutData, 0);
  lPayloadSize := SizeOf(LongWord) + Length(AInData);
  SetLength(lBlock, SizeOf(LongWord) * 2 + lPayloadSize);
  PutLongLE(lBlock, 0, 0);
  PutLongLE(lBlock, SizeOf(LongWord),
    (LongWord(Length(AInData)) shl 16) or LongWord(AOutSize));
  PutLongLE(lBlock, SizeOf(LongWord) * 2, ACommand);
  if Length(AInData) > 0 then
    Move(AInData[0], lBlock[SizeOf(LongWord) * 3], Length(AInData));

  Result := TryIoControl(REC_IOCTL_MEASTASK_CALL_COMMAND, lBlock,
    SizeOf(LongWord) * 2 + AOutSize, lOut, AErrorMessage);
  if (not Result) or (AOutSize <= 0) then
    Exit;

  if Length(lOut) < SizeOf(LongWord) * 2 + AOutSize then
  begin
    Result := False;
    AErrorMessage := 'Mebius CallCommand reply is shorter than expected';
    Exit;
  end;
  SetLength(AOutData, AOutSize);
  Move(lOut[SizeOf(LongWord) * 2], AOutData[0], AOutSize);
end;

function TRecorderMebiusTcpClient.TryProgramDeviceBin(
  const ASettings: TRecorderByteArray; out AErrorMessage: string): Boolean;
var
  lBlock: TRecorderByteArray;
  lOut: TRecorderByteArray;
begin
  SetLength(lBlock, SizeOf(LongWord) * 2 + Length(ASettings));
  PutLongLE(lBlock, 0, 0);
  PutLongLE(lBlock, SizeOf(LongWord), Length(ASettings));
  if Length(ASettings) > 0 then
    Move(ASettings[0], lBlock[SizeOf(LongWord) * 2], Length(ASettings));

  Result := TryIoControl(REC_IOCTL_MEASTASK_PROGRAMM_DEVICE_BIN, lBlock,
    SizeOf(LongInt), lOut, AErrorMessage);
end;

function TRecorderMebiusTcpClient.TryProgramMeasurement(
  out AErrorMessage: string): Boolean;
var
  lOut: TRecorderByteArray;
begin
  Result := TryIoControl(REC_IOCTL_MEASTASK_PROGRAM, nil, SizeOf(LongInt), lOut,
    AErrorMessage);
end;

function TRecorderMebiusTcpClient.TryStartMeasurement(
  out AErrorMessage: string): Boolean;
var
  lOut: TRecorderByteArray;
begin
  Result := TryIoControl(REC_IOCTL_MEASTASK_START, nil, SizeOf(LongInt), lOut,
    AErrorMessage);
  if Result then
    ResetRxCounters;
end;

procedure TRecorderMebiusTcpClient.StopMeasurement;
var
  lOut: TRecorderByteArray;
begin
  IoControl(REC_IOCTL_MEASTASK_STOP, nil, SizeOf(LongInt), lOut);
end;

function TRecorderMebiusTcpClient.TryStopMeasurement(
  out AErrorMessage: string): Boolean;
var
  lOut: TRecorderByteArray;
begin
  Result := TryIoControl(REC_IOCTL_MEASTASK_STOP, nil, SizeOf(LongInt), lOut,
    AErrorMessage);
end;

function TRecorderMebiusTcpClient.ReadDataBlock(AChannelCount: Integer;
  out ABlock: TRecorderMebiusFloatBlock): Boolean;
var
  lTemp: TRecorderSingleArray;
  lHasTemp, lHasUts: Boolean;
  lUts: Single;
begin
  Result := ReadMeasDataBlock(AChannelCount, ABlock, lTemp, lHasTemp, lUts, lHasUts);
end;

function TRecorderMebiusTcpClient.SniffPackets(APacketCount: Integer;
  ATimeoutMs: Cardinal): Integer;
var
  I: Integer;
  lPacket: TRecorderMebiusPacket;
  lSaved: Cardinal;
begin
  Result := 0;
  lSaved := fTimeoutMs;
  try
    fTimeoutMs := ATimeoutMs;
    ApplySocketTimeout;
    for I := 1 to APacketCount do
    begin
      if not ReadPacket(lPacket) then
        Break;
      Inc(Result);
      Mic185Log(Format('Sniff #%d kind=%d idFrom=%.8x dataLen=%d devId=%d',
        [I, Ord(lPacket.Kind), lPacket.IdFrom, Length(lPacket.Data),
         Mic185PacketDeviceId(lPacket.Data)]));
    end;
  finally
    fTimeoutMs := lSaved;
    ApplySocketTimeout;
  end;
end;

function TRecorderMebiusTcpClient.ReadMeasDataBlock(AChannelCount: Integer;
  out ABlock: TRecorderMebiusFloatBlock;
  out ATempValues: TRecorderSingleArray; out AHasTemp: Boolean;
  out AUtsValue: Single; out AHasUts: Boolean): Boolean;
const
  MAX_DRAIN_PACKETS = 32;
  DRAIN_TIMEOUT_MS = 2;
var
  I: Integer;
  lPacket: TRecorderMebiusPacket;
  lDevId: LongWord;
  lGotMeas: Boolean;
  lPending: TRecorderMebiusFloatBlock;
  lSavedTimeout: Cardinal;
begin
  ClearMebiusFloatBlock(ABlock);
  SetLength(ATempValues, 0);
  AHasTemp := False;
  AHasUts := False;
  AUtsValue := 0;
  lGotMeas := False;
  Result := False;
  lSavedTimeout := fTimeoutMs;
  try
    { Первый пакет — полный таймаут; далее короткий drain без блокировки на пустом сокете. }
    for I := 1 to MAX_DRAIN_PACKETS do
    begin
      if I = 1 then
        SetTimeoutMs(lSavedTimeout)
      else
        SetTimeoutMs(DRAIN_TIMEOUT_MS);
      if not ReadPacket(lPacket) then
        Break;
      if lPacket.Kind = mpkData then
        Inc(fRxDataPacketCount);
      if lPacket.Kind <> mpkData then
        Continue;
      lDevId := Mic185PacketDeviceId(lPacket.Data);
      if lDevId = CMic185DevIdMeasChannels then
      begin
        if RecorderMebiusParseFloatBlock(lPacket.Data, AChannelCount, lPending) then
        begin
          if AppendMebiusFloatBlock(ABlock, lPending) then
            lGotMeas := True;
        end;
        Continue;
      end;
      if lDevId = CMic185DevIdTempChannels then
        AHasTemp := Mic185ParseTempValues(lPacket.Data, CMic185TempChannelCount,
          ATempValues);
      if lDevId = CMic185DevIdUts then
        AHasUts := Mic185ParseUtsValue(lPacket.Data, AUtsValue);
    end;
  finally
    SetTimeoutMs(lSavedTimeout);
  end;
  Result := lGotMeas;
end;

end.
