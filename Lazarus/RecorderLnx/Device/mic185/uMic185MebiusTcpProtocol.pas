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
  Classes, SysUtils, sockets, ssockets,
  {$IFDEF WINDOWS}WinSock2,{$ENDIF}
  {$IFDEF UNIX}BaseUnix,{$ENDIF}
  uRecorderNetworkBinding;

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
    fSocket: TSocketStream;
    fTimeoutMs: Cardinal;
    fClientTaskId: LongWord;
    fRxByteCount: Int64;
    fRxPacketCountTotal: Int64;
    fRxDataPacketCount: Int64;
    fRxSyncDropCount: Int64;
    fRxCompactCount: Int64;
    fRxMaxBuffered: Integer;
    fConnectionLost: Boolean;
    fLastReadError: string;
    fRxBuffer: TRecorderByteArray;
    fRxStart: Integer;
    fRxCount: Integer;
    procedure ApplySocketTimeout;
    procedure SetTimeoutMs(AValue: Cardinal);
    function SocketHasData: Boolean;
    procedure CompactRx;
    procedure DropRx(ACount: Integer);
    function ReadAvailable(AWait: Boolean): Boolean;
    function TryTakePacket(out APacket: TRecorderMebiusPacket): Boolean;
    function TryWriteBytes(const ABuffer; ACount: Integer;
      out AErrorText: string): Boolean;
    procedure WriteBytes(const ABuffer; ACount: Integer);
    function ReadPacket(out APacket: TRecorderMebiusPacket;
      AWait: Boolean = True): Boolean;
    function IoControl(AIoCode: LongWord; const AInData: TRecorderByteArray;
      AOutSize: Integer; out AOutData: TRecorderByteArray): LongInt;
    function TryIoControl(AIoCode: LongWord; const AInData: TRecorderByteArray; AOutSize: Integer; out AOutData: TRecorderByteArray;      out AErrorMessage: string): Boolean;
    function CheckResult(const AData: TRecorderByteArray; out AErrorMessage: string): Boolean;
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
    function TryQuerySessionState(out AErrorMessage: string): Boolean;
    function TryCallCommand(ACommand: LongWord; const AInData: TRecorderByteArray;
      AOutSize: Integer; out AOutData: TRecorderByteArray;
      out AErrorMessage: string): Boolean;
    function TryProgramDeviceBin(const ASettings: TRecorderByteArray;
      out AErrorMessage: string): Boolean;
    function TryCleanupMeasurementTask(out AErrorMessage: string): Boolean;
    function TryProgramMeasurement(out AErrorMessage: string): Boolean;
    function TryStartMeasurement(out AErrorMessage: string): Boolean;
    function TryStopMeasurement(out AErrorMessage: string): Boolean;
    function ReadDataBlock(AChannelCount: Integer;
      out ABlock: TRecorderMebiusFloatBlock): Boolean;
    function ReadMeasDataBlock(AChannelCount: Integer;
      out ABlock: TRecorderMebiusFloatBlock;
      out ATempValues: TRecorderSingleArray; out AHasTemp: Boolean;
      out AUtsDeviceTimeSec, AUtsValueSec: Double;
      out AHasUts: Boolean): Boolean;
    function SniffPackets(APacketCount: Integer; ATimeoutMs: Cardinal): Integer;

    property Host: string read fHost;
    property Port: Word read fPort;
    property TimeoutMs: Cardinal read fTimeoutMs write SetTimeoutMs;
    property RxDataPacketCount: Int64 read fRxDataPacketCount;
    property RxByteCount: Int64 read fRxByteCount;
    property RxPacketCount: Int64 read fRxPacketCountTotal;
    property RxSyncDropCount: Int64 read fRxSyncDropCount;
    property RxCompactCount: Int64 read fRxCompactCount;
    property RxMaxBuffered: Integer read fRxMaxBuffered;
    property RxBufferedByteCount: Integer read fRxCount;
    property ConnectionLost: Boolean read fConnectionLost;
    property LastReadError: string read fLastReadError;
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
  out ADeviceTimeSec, AUtsValueSec: Double): Boolean;

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
  REC_IOCTL_MEASTASK_QUERY_SESSION_STATE =
    (REC_TYPEIO_MEAS_TASK shl 16) or ($0001 shl 2);
  REC_IOCTL_MEASTASK_DO_CLEANUP =
    (REC_TYPEIO_MEAS_TASK shl 16) or ($0002 shl 2);
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
  DateUtils, uMic185Constants, uMic185DebugLog, uRecorderMic185Runtime,
  uRecorderDebugLog;

type
  TMebeHeader = packed record
    Signature: LongWord;
    Size: LongWord;
    IdTo: LongWord;
    IdFrom: LongWord;
    Crc: LongWord;
  end;

  TMebeHeaderState = (mhsInvalid, mhsIncomplete, mhsReady);

  TUniversalDataSampleHeader = packed record
    PacketType: Word;
    _AlignPad: Word;  { MSVC выравнивает ULONG sampl_count_ на 4 }
    SampleCount: LongWord;
  end;

const
  { Размер SO_RCVBUF из CTCPLink оригинального Recorder. }
  CMebiusReceiveBufferSize = 4 * 1024 * 1024;
  CMebiusReceiveBlockSize = 2 * 1024 * 1024;
  CMebiusMaxPacketSize = 4 * 1024 * 1024;
  { ForceResetDevice оригинального Recorder ждёт 300 мс после Disconnect. }
  CMebiusDisconnectSettleMs = 300;

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

function MebiusHeaderState(const AHeader: TMebeHeader; ABuffered: Integer;
  out ASize: Integer): TMebeHeaderState;
var
  lLegacy: TMebeHeader;
  lSize: LongWord;
begin
  Result := mhsInvalid;
  ASize := 0;
  if AHeader.Signature = REC_MEBE_PACKET_SIGNATURE_SIZE_BIG then
  begin
    if AHeader.Crc <> MebiusHeaderCrc(AHeader) then
      Exit;
    lSize := AHeader.Size;
  end
  else if AHeader.Signature = REC_MEBE_PACKET_SIGNATURE then
  begin
    lLegacy := AHeader;
    if AHeader.Crc = MebiusHeaderCrc(AHeader) then
    begin
      lSize := AHeader.Size;
      if lSize > LongWord(ABuffered) then
        lSize := lSize and $FFFF;
    end
    else
    begin
      lLegacy.Size := lLegacy.Size and $FFFF;
      if AHeader.Crc <> MebiusHeaderCrc(lLegacy) then
        Exit;
      lSize := lLegacy.Size;
    end;
  end
  else
    Exit;

  if (lSize < REC_MEBE_PACKET_HEADER_SIZE) or
    (lSize > CMebiusMaxPacketSize) then
    Exit;
  ASize := Integer(lSize);
  if ASize > ABuffered then
    Exit(mhsIncomplete);
  Result := mhsReady;
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

function QWordFromLE(const AData: TRecorderByteArray; AOffset: Integer): QWord;
begin
  Result := QWord(GetLongLE(AData, AOffset)) or
    (QWord(GetLongLE(AData, AOffset + SizeOf(LongWord))) shl 32);
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
  out ADeviceTimeSec, AUtsValueSec: Double): Boolean;
var
  lData: array[0..9] of Word;
  lSeconds, lMinutes, lHours, lDays, lYears: Word;
  I: Integer;
  lPacketOffset: Integer;
  lFrameOffset: Integer;
  lType: LongWord;
  lStartClk: QWord;
  lSevClk: QWord;
  lSevSec: LongWord;
  lClkHz: LongWord;
begin
  ADeviceTimeSec := 0;
  AUtsValueSec := 0;
  Result := False;

  { UTS is not UNIVERSAL_DATA_SAMPLE<float>. The device sends
    UTS_TRANSPORT_PACKET: marker, SEV_PACKET(type, sample counter), TUtsFrame.
    PcUTSImpl.cpp converts its clocks to X and publishes m_Sev_Sec as Y. }
  lPacketOffset := SizeOf(LongWord);
  if Length(AData) < lPacketOffset + 2 * SizeOf(LongWord) then
    Exit;
  lType := GetLongLE(AData, lPacketOffset);
  { Some MSVC builds align the nested SEV_PACKET to 8 bytes. }
  if (lType <> 1) and (lType <> 2) and
    (Length(AData) >= 2 * SizeOf(LongWord) + 2 * SizeOf(LongWord)) then
  begin
    lPacketOffset := 2 * SizeOf(LongWord);
    lType := GetLongLE(AData, lPacketOffset);
  end;
  lFrameOffset := lPacketOffset + 2 * SizeOf(LongWord);
  if lType = 2 then
  begin
    if Length(AData) < lFrameOffset + 2 * SizeOf(QWord) +
      2 * SizeOf(LongWord) then Exit;
    lStartClk := QWordFromLE(AData, lFrameOffset);
    lSevClk := QWordFromLE(AData, lFrameOffset + SizeOf(QWord));
    lSevSec := GetLongLE(AData, lFrameOffset + 2 * SizeOf(QWord));
    lClkHz := GetLongLE(AData, lFrameOffset + 2 * SizeOf(QWord) +
      SizeOf(LongWord));
  end
  else if lType = 1 then
  begin
    { IRIG-B: ten 16-bit BCD words, then start/edge clocks and clock rate. }
    if Length(AData) < lFrameOffset + 10 * SizeOf(Word) +
      2 * SizeOf(QWord) + SizeOf(LongWord) then Exit;
    for I := 0 to 9 do
      lData[I] := GetWordLE(AData, lFrameOffset + I * SizeOf(Word));
    lStartClk := QWordFromLE(AData, lFrameOffset + 10 * SizeOf(Word));
    lSevClk := QWordFromLE(AData, lFrameOffset + 10 * SizeOf(Word) +
      SizeOf(QWord));
    lClkHz := GetLongLE(AData, lFrameOffset + 10 * SizeOf(Word) +
      2 * SizeOf(QWord));
    lSeconds := ((lData[0] shr 0) and 1) + ((lData[0] shr 1) and 1) * 2 +
      ((lData[0] shr 2) and 1) * 4 + ((lData[0] shr 3) and 1) * 8 +
      ((lData[0] shr 5) and 1) * 10 + ((lData[0] shr 6) and 1) * 20 +
      ((lData[0] shr 7) and 1) * 40;
    lMinutes := ((lData[1] shr 0) and 1) + ((lData[1] shr 1) and 1) * 2 +
      ((lData[1] shr 2) and 1) * 4 + ((lData[1] shr 3) and 1) * 8 +
      ((lData[1] shr 5) and 1) * 10 + ((lData[1] shr 6) and 1) * 20 +
      ((lData[1] shr 7) and 1) * 40;
    lHours := ((lData[2] shr 0) and 1) + ((lData[2] shr 1) and 1) * 2 +
      ((lData[2] shr 2) and 1) * 4 + ((lData[2] shr 3) and 1) * 8 +
      ((lData[2] shr 5) and 1) * 10 + ((lData[2] shr 6) and 1) * 20;
    lDays := ((lData[3] shr 0) and 1) + ((lData[3] shr 1) and 1) * 2 +
      ((lData[3] shr 2) and 1) * 4 + ((lData[3] shr 3) and 1) * 8 +
      ((lData[3] shr 5) and 1) * 10 + ((lData[3] shr 6) and 1) * 20 +
      ((lData[3] shr 7) and 1) * 40 + ((lData[3] shr 8) and 1) * 80 +
      ((lData[4] shr 0) and 1) * 100 + ((lData[4] shr 1) and 1) * 200;
    lYears := ((lData[5] shr 0) and 1) + ((lData[5] shr 1) and 1) * 2 +
      ((lData[5] shr 2) and 1) * 4 + ((lData[5] shr 3) and 1) * 8 +
      ((lData[5] shr 5) and 1) * 10 + ((lData[5] shr 6) and 1) * 20 +
      ((lData[5] shr 7) and 1) * 40 + ((lData[5] shr 8) and 1) * 80;
    if (lDays < 1) or (lHours > 23) or (lMinutes > 59) or
      (lSeconds > 60) then Exit;
    AUtsValueSec := (EncodeDate(2000 + lYears, 1, 1) + lDays - 1) *
      SecsPerDay + lHours * 3600 + lMinutes * 60 + lSeconds;
  end
  else
    Exit;
  if (lStartClk = 0) or (lClkHz = 0) or (lSevClk < lStartClk) then
    Exit;
  ADeviceTimeSec := (lSevClk - lStartClk) / Double(lClkHz);
  if lType = 2 then AUtsValueSec := lSevSec;
  if DeviceLogEnabled then
    Mic185Log(Format('UTS parsed type=%d x=%.6f y=%.0f clk=%d',
      [lType, ADeviceTimeSec, AUtsValueSec, lClkHz]));
  Result := True;
end;

procedure TRecorderMebiusTcpClient.ApplySocketTimeout;
begin
  if fSocket <> nil then
    fSocket.IOTimeout := Integer(fTimeoutMs);
end;

procedure TRecorderMebiusTcpClient.SetTimeoutMs(AValue: Cardinal);
begin
  if fTimeoutMs = AValue then
    Exit;
  fTimeoutMs := AValue;
  ApplySocketTimeout;
end;

procedure ConfigureMebiusSocket(ASocket: LongInt); forward;

procedure ConfigureMebiusSocket(ASocket: LongInt);
var
  lEnabled: LongInt;
  lSize: LongInt;
  {$IFDEF WINDOWS}
  lBytes: DWORD;
  lKeepAlive: record
    OnOff: LongWord;
    KeepAliveTime: LongWord;
    KeepAliveInterval: LongWord;
  end;
  {$ELSE}
  lKeepIdle: LongInt;
  lKeepInterval: LongInt;
  {$ENDIF}
begin
  if ASocket < 0 then
    Exit;
  lSize := CMebiusReceiveBufferSize;
  fpSetSockOpt(ASocket, SOL_SOCKET, SO_RCVBUF, @lSize, SizeOf(lSize));
  lEnabled := 1;
  fpSetSockOpt(ASocket, SOL_SOCKET, SO_KEEPALIVE, @lEnabled,
    SizeOf(lEnabled));
  {$IFDEF WINDOWS}
  lKeepAlive.OnOff := 1;
  lKeepAlive.KeepAliveTime := 5000;
  lKeepAlive.KeepAliveInterval := 1000;
  lBytes := 0;
  WinSock2.WSAIoctl(ASocket, WinSock2.IOC_IN or
    WinSock2.IOC_VENDOR or 4, @lKeepAlive, SizeOf(lKeepAlive), nil, 0,
    @lBytes, nil, nil);
  {$ELSE}
  lKeepIdle := 5;
  lKeepInterval := 1;
  fpSetSockOpt(ASocket, IPPROTO_TCP, TCP_KEEPIDLE, @lKeepIdle,
    SizeOf(lKeepIdle));
  fpSetSockOpt(ASocket, IPPROTO_TCP, TCP_KEEPINTVL, @lKeepInterval,
    SizeOf(lKeepInterval));
  {$ENDIF}
end;

function TRecorderMebiusTcpClient.SocketHasData: Boolean;
var
  lFds: TFDSet;
  lTime: TTimeVal;
begin
  Result := False;
  if fSocket = nil then
    Exit;
  lFds := Default(TFDSet);
  lTime.tv_sec := 0;
  lTime.tv_usec := 0;
  {$IFDEF UNIX}
  fpFD_Zero(lFds);
  fpFD_Set(fSocket.Handle, lFds);
  Result := fpSelect(fSocket.Handle + 1, @lFds, nil, nil, @lTime) > 0;
  {$ELSE}
  FD_Zero(lFds);
  FD_Set(fSocket.Handle, lFds);
  Result := WinSock2.select(0, @lFds, nil, nil, @lTime) > 0;
  {$ENDIF}
end;

constructor TRecorderMebiusTcpClient.Create(const AHost: string; APort: Word;
  ATimeoutMs: Cardinal);
begin
  inherited Create;
  fHost := AHost;
  fPort := APort;
  fTimeoutMs := ATimeoutMs;
  { Оригинальный CTCPLink передаёт (TASKID)this. Для прошивки это
    не адрес ядра, а уникальный адрес обратного ответа клиента.
    Общий SETTINGS_PORT_ID нельзя делить между сеансами: чтение
    паспорта ещё может пройти, а ProgramDeviceBin вернёт E_MEB_TIMEOUT. }
  fClientTaskId := LongWord(PtrUInt(Pointer(Self)) and $FFFFFFFF);
  if fClientTaskId = 0 then
    fClientTaskId := REC_HOST_SETTINGS_PORT_ID;
  fRxDataPacketCount := 0;
  fRxByteCount := 0;
  fRxPacketCountTotal := 0;
  fRxSyncDropCount := 0;
  fRxCompactCount := 0;
  fRxMaxBuffered := 0;
  fConnectionLost := False;
  fLastReadError := '';
  SetLength(fRxBuffer, CMebiusReceiveBufferSize);
  fRxStart := 0;
  fRxCount := 0;
end;

procedure TRecorderMebiusTcpClient.ResetRxCounters;
begin
  fRxDataPacketCount := 0;
  fRxByteCount := 0;
  fRxPacketCountTotal := 0;
  fRxSyncDropCount := 0;
  fRxCompactCount := 0;
  fRxMaxBuffered := 0;
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
    if not RecorderOpenBoundTcpStream(fHost, fPort, fTimeoutMs, fSocket,
      AErrorText, True, @ConfigureMebiusSocket) then
      Exit;
{$ifdef unix}
    fSocket.WriteFlags := fSocket.WriteFlags or MSG_NOSIGNAL;
{$endif}
    { Параметры транспорта установлены до connect: так делает CTCPLink
      оригинального Recorder, чтобы масштаб TCP-окна согласовался в SYN. }
    ApplySocketTimeout;
    fConnectionLost := False;
    fLastReadError := '';
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
var
  lHadSocket: Boolean;
begin
  // The original Recorder CTCPLink performs shutdown(SD_BOTH) before
  // closesocket.  This is important for MIC-183/185 firmware: without the
  // orderly TCP shutdown the device can keep the settings client/session
  // occupied and accept the next TCP connection without servicing IoControl.
  lHadSocket := fSocket <> nil;
  if lHadSocket then
  begin
    try
      fpShutdown(fSocket.Handle, SHUT_RDWR);
    except
      // Disconnect must remain idempotent and must not mask the original
      // protocol error which caused the reconnect.
    end;
  end;
  FreeAndNil(fSocket);
  fRxStart := 0;
  fRxCount := 0;
  RecorderMic185RuntimeUnregisterTcpClient(Self);
  { BIOS освобождает задачу Mebius не одновременно с closesocket. Без
    короткой выдержки немедленное переподключение может открыть TCP, но
    первая команда IoControl останется без ответа. }
  if lHadSocket then
    Sleep(CMebiusDisconnectSettleMs);
end;

procedure TRecorderMebiusTcpClient.CompactRx;
begin
  if (fRxStart = 0) or (fRxCount = 0) then
    Exit;
  Move(fRxBuffer[fRxStart], fRxBuffer[0], fRxCount);
  fRxStart := 0;
  Inc(fRxCompactCount);
end;

procedure TRecorderMebiusTcpClient.DropRx(ACount: Integer);
begin
  if ACount > fRxCount then
    ACount := fRxCount;
  Inc(fRxStart, ACount);
  Dec(fRxCount, ACount);
  if fRxCount = 0 then
    fRxStart := 0;
end;

function TRecorderMebiusTcpClient.ReadAvailable(AWait: Boolean): Boolean;
var
  lRead: Integer;
  lFree: Integer;
begin
  Result := False;
  if fSocket = nil then
    raise ERecorderMebiusProtocolError.Create('Mebius TCP socket is not connected');
  if (not AWait) and (not SocketHasData) then
    Exit;
  if fRxStart + fRxCount = Length(fRxBuffer) then
    CompactRx;
  lFree := Length(fRxBuffer) - fRxStart - fRxCount;
  if lFree <= 0 then
  begin
    fConnectionLost := True;
    fLastReadError := 'Mebius receive buffer overflow';
    Exit;
  end;
  if lFree > CMebiusReceiveBlockSize then
    lFree := CMebiusReceiveBlockSize;
  try
    lRead := fSocket.Read(fRxBuffer[fRxStart + fRxCount], lFree);
  except
    on E: Exception do
    begin
      fLastReadError := E.Message;
      if not AWait then
      begin
        fConnectionLost := True;
        Mic185Log(Format('TCP read failed %s:%d: %s',
          [fHost, fPort, fLastReadError]));
      end;
      Exit;
    end;
  end;
  if lRead <= 0 then
  begin
    fConnectionLost := True;
    fLastReadError := 'TCP connection closed by device';
    Mic185Log(Format('TCP EOF %s:%d', [fHost, fPort]));
    Exit;
  end;
  Inc(fRxByteCount, lRead);
  Inc(fRxCount, lRead);
  if fRxCount > fRxMaxBuffered then
    fRxMaxBuffered := fRxCount;
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
        fConnectionLost := True;
        AErrorText := 'Mebius TCP write failed';
        Exit;
      end;
      Inc(lDone, lWritten);
    end;
    Result := True;
  except
    on E: Exception do
    begin
      fConnectionLost := True;
      AErrorText := E.Message;
    end;
  end;
end;

function TRecorderMebiusTcpClient.TryTakePacket(
  out APacket: TRecorderMebiusPacket): Boolean;
var
  lBodySize: Integer;
  lHeader: TMebeHeader;
  lSize: Integer;
  lState: TMebeHeaderState;
begin
  FillChar(APacket, SizeOf(APacket), 0);
  Result := False;
  while fRxCount >= SizeOf(lHeader) do
  begin
    Move(fRxBuffer[fRxStart], lHeader, SizeOf(lHeader));
    lState := MebiusHeaderState(lHeader, fRxCount, lSize);
    if lState = mhsInvalid then
    begin
      DropRx(1);
      Inc(fRxSyncDropCount);
      Continue;
    end;
    if lState = mhsIncomplete then
      Exit;

    lBodySize := lSize - REC_MEBE_PACKET_HEADER_SIZE;
    SetLength(APacket.Data, lBodySize);
    if lBodySize > 0 then
      Move(fRxBuffer[fRxStart + REC_MEBE_PACKET_HEADER_SIZE],
        APacket.Data[0], lBodySize);
    DropRx(lSize);
    Inc(fRxPacketCountTotal);
    APacket.IdFrom := lHeader.IdFrom;
    APacket.IdTo := lHeader.IdTo;
    if (lHeader.IdFrom = REC_DATA_TRANSMIT_TASK_ID) or
      (lHeader.IdFrom = $3E904000) then
      APacket.Kind := mpkData
    else
      APacket.Kind := mpkCommand;
    Exit(True);
  end;
end;

function TRecorderMebiusTcpClient.ReadPacket(out APacket: TRecorderMebiusPacket;
  AWait: Boolean): Boolean;
begin
  repeat
    if TryTakePacket(APacket) then
      Exit(True);
    if not ReadAvailable(AWait) then
      Exit(False);
  until False;
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
  lSkipped: Integer;
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

    lSkipped := 0;
    while True do
    begin
      if not ReadPacket(lReply) then
      begin
        AErrorMessage := 'Mebius IoControl timeout';
        Exit;
      end;
      if lReply.Kind = mpkData then
        Continue;
      if Length(lReply.Data) < REC_MEB_IOCTL_COMMAND_HEADER_SIZE then
        Continue;
      lReplyCode := GetLongLE(lReply.Data, 4);
      if lReplyCode = AIoCode then
        Break;
      Inc(lSkipped);
      if lSkipped >= 64 then
      begin
        AErrorMessage := Format(
          'Mebius IoControl reply %.8x does not match %.8x',
          [lReplyCode, AIoCode]);
        Exit;
      end;
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
    lOut, AErrorMessage) and CheckResult(lOut, AErrorMessage);
end;

function TRecorderMebiusTcpClient.TryQuerySessionState(
  out AErrorMessage: string): Boolean;
var
  lOut: TRecorderByteArray;
begin
  Result := TryIoControl(REC_IOCTL_MEASTASK_QUERY_SESSION_STATE, nil,
    3 * SizeOf(LongWord), lOut, AErrorMessage);
end;

function TRecorderMebiusTcpClient.CheckResult(
  const AData: TRecorderByteArray; out AErrorMessage: string): Boolean;
var
  lCode: LongInt;
begin
  Result := False;
  if Length(AData) < SizeOf(lCode) then
  begin
    AErrorMessage := 'Mebius command result is missing';
    Exit;
  end;
  Move(AData[0], lCode, SizeOf(lCode));
  if lCode < 0 then
  begin
    AErrorMessage := Format('Mebius command failed: %.8x', [LongWord(lCode)]);
    Exit;
  end;
  Result := True;
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
    SizeOf(LongInt), lOut, AErrorMessage) and CheckResult(lOut, AErrorMessage);
end;

function TRecorderMebiusTcpClient.TryCleanupMeasurementTask(
  out AErrorMessage: string): Boolean;
var
  lOut: TRecorderByteArray;
begin
  Result := TryIoControl(REC_IOCTL_MEASTASK_DO_CLEANUP, nil,
    SizeOf(LongInt), lOut, AErrorMessage) and CheckResult(lOut, AErrorMessage);
end;

function TRecorderMebiusTcpClient.TryProgramMeasurement(
  out AErrorMessage: string): Boolean;
var
  lOut: TRecorderByteArray;
begin
  Result := TryIoControl(REC_IOCTL_MEASTASK_PROGRAM, nil, SizeOf(LongInt), lOut,
    AErrorMessage) and CheckResult(lOut, AErrorMessage);
end;

function TRecorderMebiusTcpClient.TryStartMeasurement(
  out AErrorMessage: string): Boolean;
var
  lOut: TRecorderByteArray;
begin
  Result := TryIoControl(REC_IOCTL_MEASTASK_START, nil, SizeOf(LongInt), lOut,
    AErrorMessage) and CheckResult(lOut, AErrorMessage);
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
    AErrorMessage) and CheckResult(lOut, AErrorMessage);
end;

function TRecorderMebiusTcpClient.ReadDataBlock(AChannelCount: Integer;
  out ABlock: TRecorderMebiusFloatBlock): Boolean;
var
  lTemp: TRecorderSingleArray;
  lHasTemp, lHasUts: Boolean;
  lUtsDeviceTime, lUts: Double;
begin
  Result := ReadMeasDataBlock(AChannelCount, ABlock, lTemp, lHasTemp,
    lUtsDeviceTime, lUts, lHasUts);
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
  out AUtsDeviceTimeSec, AUtsValueSec: Double;
  out AHasUts: Boolean): Boolean;
var
  lPacket: TRecorderMebiusPacket;
  lDevId: LongWord;
  lGotMeas: Boolean;
  lPending: TRecorderMebiusFloatBlock;
begin
  ClearMebiusFloatBlock(ABlock);
  SetLength(ATempValues, 0);
  AHasTemp := False;
  AHasUts := False;
  AUtsDeviceTimeSec := 0;
  AUtsValueSec := 0;
  lGotMeas := False;
  while ReadPacket(lPacket, False) do
  begin
      if lPacket.Kind = mpkData then
        Inc(fRxDataPacketCount);
      if lPacket.Kind <> mpkData then
        Continue;
      lDevId := Mic185PacketDeviceId(lPacket.Data);
      if lDevId = CMic185DevIdMeasChannels then
      begin
        if RecorderMebiusParseFloatBlock(lPacket.Data, AChannelCount,
          lPending) and AppendMebiusFloatBlock(ABlock, lPending) then
          lGotMeas := True;
        Continue;
      end;
      if lDevId = CMic185DevIdTempChannels then
      begin
        AHasTemp := Mic185ParseTempValues(lPacket.Data, CMic185TempChannelCount,
          ATempValues);
        if AHasTemp and DeviceLogEnabled then
          Mic185Log(Format('TEMP parsed count=%d first=%.3f',
            [Length(ATempValues), ATempValues[0]]));
      end
      else if lDevId = CMic185DevIdUts then
        AHasUts := Mic185ParseUtsValue(lPacket.Data, AUtsDeviceTimeSec,
          AUtsValueSec);
  end;
  Result := lGotMeas;
end;

end.
