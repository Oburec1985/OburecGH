unit uSharedBinaryIO;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  ESharedBinaryFormatError = class(Exception);

  { TSharedBinaryReader }

  TSharedBinaryReader = class
  private
    FStream: TStream;
    procedure ReadExact(var ABuffer; ACount: SizeInt);
    procedure CheckLength(ALength, AMaxBytes: Cardinal;
      const AValueName: string);
  public
    constructor Create(AStream: TStream);
    function ReadUInt8: Byte;
    function ReadInt8: ShortInt;
    function ReadUInt16LE: Word;
    function ReadInt16LE: SmallInt;
    function ReadUInt32LE: Cardinal;
    function ReadInt32LE: LongInt;
    function ReadSingleLE: Single;
    function ReadDoubleLE: Double;
    function ReadBoolean8: Boolean;
    function ReadAnsi8(AMaxBytes: Cardinal): RawByteString;
    function ReadAnsi32(AMaxBytes: Cardinal): RawByteString;
    function ReadCString(AMaxBytes: Cardinal): RawByteString;
    function ReadFixedBytes(ACount: Cardinal): TBytes;
    property Stream: TStream read FStream;
  end;

  { TSharedBinaryWriter }

  TSharedBinaryWriter = class
  private
    FStream: TStream;
    procedure WriteExact(const ABuffer; ACount: SizeInt);
    procedure CheckStringLength(const AValue: RawByteString;
      AMaxBytes, AFormatMaxBytes: Cardinal; const AValueName: string);
  public
    constructor Create(AStream: TStream);
    procedure WriteUInt8(AValue: Byte);
    procedure WriteInt8(AValue: ShortInt);
    procedure WriteUInt16LE(AValue: Word);
    procedure WriteInt16LE(AValue: SmallInt);
    procedure WriteUInt32LE(AValue: Cardinal);
    procedure WriteInt32LE(AValue: LongInt);
    procedure WriteSingleLE(AValue: Single);
    procedure WriteDoubleLE(AValue: Double);
    procedure WriteBoolean8(AValue: Boolean);
    procedure WriteAnsi8(const AValue: RawByteString; AMaxBytes: Cardinal);
    procedure WriteAnsi32(const AValue: RawByteString; AMaxBytes: Cardinal);
    procedure WriteCString(const AValue: RawByteString; AMaxBytes: Cardinal);
    procedure WriteFixedBytes(const AValue: TBytes);
    property Stream: TStream read FStream;
  end;

implementation

procedure RequireStream(AStream: TStream);
begin
  if AStream = nil then
    raise EArgumentNilException.Create('Stream must be assigned');
end;

{ TSharedBinaryReader }

constructor TSharedBinaryReader.Create(AStream: TStream);
begin
  inherited Create;
  RequireStream(AStream);
  FStream := AStream;
end;

procedure TSharedBinaryReader.ReadExact(var ABuffer; ACount: SizeInt);
var
  LChunkSize: LongInt;
  LOffset: SizeInt;
  LRead: LongInt;
begin
  LOffset := 0;
  while LOffset < ACount do
  begin
    if ACount - LOffset > High(LongInt) then
      LChunkSize := High(LongInt)
    else
      LChunkSize := ACount - LOffset;
    LRead := FStream.Read((PByte(@ABuffer) + LOffset)^, LChunkSize);
    if LRead <= 0 then
      raise ESharedBinaryFormatError.CreateFmt(
        'Unexpected end of stream: needed %d more byte(s)',
        [ACount - LOffset]);
    Inc(LOffset, LRead);
  end;
end;

procedure TSharedBinaryReader.CheckLength(ALength, AMaxBytes: Cardinal;
  const AValueName: string);
begin
  if ALength > AMaxBytes then
    raise ESharedBinaryFormatError.CreateFmt(
      '%s length %d exceeds limit %d', [AValueName, ALength, AMaxBytes]);
  if QWord(ALength) > QWord(High(SizeInt)) then
    raise ESharedBinaryFormatError.CreateFmt(
      '%s length %d cannot be represented on this platform',
      [AValueName, ALength]);
end;

function TSharedBinaryReader.ReadUInt8: Byte;
begin
  ReadExact(Result, SizeOf(Result));
end;

function TSharedBinaryReader.ReadInt8: ShortInt;
begin
  ReadExact(Result, SizeOf(Result));
end;

function TSharedBinaryReader.ReadUInt16LE: Word;
var
  LBytes: array[0..1] of Byte;
begin
  ReadExact(LBytes, SizeOf(LBytes));
  Result := Word(LBytes[0]) or (Word(LBytes[1]) shl 8);
end;

function TSharedBinaryReader.ReadInt16LE: SmallInt;
begin
  Result := SmallInt(ReadUInt16LE);
end;

function TSharedBinaryReader.ReadUInt32LE: Cardinal;
var
  LBytes: array[0..3] of Byte;
begin
  ReadExact(LBytes, SizeOf(LBytes));
  Result := Cardinal(LBytes[0]) or (Cardinal(LBytes[1]) shl 8) or
    (Cardinal(LBytes[2]) shl 16) or (Cardinal(LBytes[3]) shl 24);
end;

function TSharedBinaryReader.ReadInt32LE: LongInt;
begin
  Result := LongInt(ReadUInt32LE);
end;

function TSharedBinaryReader.ReadSingleLE: Single;
var
  LBits: Cardinal;
begin
  LBits := ReadUInt32LE;
  Move(LBits, Result, SizeOf(Result));
end;

function TSharedBinaryReader.ReadDoubleLE: Double;
var
  LBytes: array[0..7] of Byte;
  LBits: QWord;
begin
  ReadExact(LBytes, SizeOf(LBytes));
  LBits := QWord(LBytes[0]) or (QWord(LBytes[1]) shl 8) or
    (QWord(LBytes[2]) shl 16) or (QWord(LBytes[3]) shl 24) or
    (QWord(LBytes[4]) shl 32) or (QWord(LBytes[5]) shl 40) or
    (QWord(LBytes[6]) shl 48) or (QWord(LBytes[7]) shl 56);
  Move(LBits, Result, SizeOf(Result));
end;

function TSharedBinaryReader.ReadBoolean8: Boolean;
var
  LValue: Byte;
begin
  LValue := ReadUInt8;
  case LValue of
    0: Result := False;
    1: Result := True;
  else
    raise ESharedBinaryFormatError.CreateFmt(
      'Invalid Boolean8 value %d; expected 0 or 1', [LValue]);
  end;
end;

function TSharedBinaryReader.ReadAnsi8(AMaxBytes: Cardinal): RawByteString;
var
  LLength: Byte;
begin
  LLength := ReadUInt8;
  CheckLength(LLength, AMaxBytes, 'Ansi8 string');
  SetLength(Result, LLength);
  if LLength > 0 then
    ReadExact(Result[1], LLength);
end;

function TSharedBinaryReader.ReadAnsi32(AMaxBytes: Cardinal): RawByteString;
var
  LLength: Cardinal;
begin
  LLength := ReadUInt32LE;
  CheckLength(LLength, AMaxBytes, 'Ansi32 string');
  SetLength(Result, SizeInt(LLength));
  if LLength > 0 then
    ReadExact(Result[1], LLength);
end;

function TSharedBinaryReader.ReadCString(AMaxBytes: Cardinal): RawByteString;
var
  LByte: Byte;
  LLength: Cardinal;
begin
  Result := '';
  LLength := 0;
  while LLength <= AMaxBytes do
  begin
    LByte := ReadUInt8;
    if LByte = 0 then
      Exit;
    if LLength = AMaxBytes then
      raise ESharedBinaryFormatError.CreateFmt(
        'CString exceeds limit %d', [AMaxBytes]);
    Inc(LLength);
    SetLength(Result, LLength);
    Result[LLength] := AnsiChar(LByte);
  end;
end;

function TSharedBinaryReader.ReadFixedBytes(ACount: Cardinal): TBytes;
begin
  Result := nil;
  CheckLength(ACount, High(Cardinal), 'Fixed byte array');
  SetLength(Result, SizeInt(ACount));
  if ACount > 0 then
    ReadExact(Result[0], ACount);
end;

{ TSharedBinaryWriter }

constructor TSharedBinaryWriter.Create(AStream: TStream);
begin
  inherited Create;
  RequireStream(AStream);
  FStream := AStream;
end;

procedure TSharedBinaryWriter.WriteExact(const ABuffer; ACount: SizeInt);
var
  LChunkSize: LongInt;
  LOffset: SizeInt;
  LWritten: LongInt;
begin
  LOffset := 0;
  while LOffset < ACount do
  begin
    if ACount - LOffset > High(LongInt) then
      LChunkSize := High(LongInt)
    else
      LChunkSize := ACount - LOffset;
    LWritten := FStream.Write((PByte(@ABuffer) + LOffset)^, LChunkSize);
    if LWritten <= 0 then
      raise EWriteError.CreateFmt('Could not write %d byte(s)',
        [ACount - LOffset]);
    Inc(LOffset, LWritten);
  end;
end;

procedure TSharedBinaryWriter.CheckStringLength(const AValue: RawByteString;
  AMaxBytes, AFormatMaxBytes: Cardinal; const AValueName: string);
var
  LEffectiveMax: Cardinal;
  LLength: QWord;
begin
  LLength := Length(AValue);
  LEffectiveMax := AMaxBytes;
  if AFormatMaxBytes < LEffectiveMax then
    LEffectiveMax := AFormatMaxBytes;
  if (LLength > AMaxBytes) or (LLength > AFormatMaxBytes) then
    raise ESharedBinaryFormatError.CreateFmt(
      '%s length %d exceeds limit %d',
      [AValueName, LLength, LEffectiveMax]);
end;

procedure TSharedBinaryWriter.WriteUInt8(AValue: Byte);
begin
  WriteExact(AValue, SizeOf(AValue));
end;

procedure TSharedBinaryWriter.WriteInt8(AValue: ShortInt);
begin
  WriteExact(AValue, SizeOf(AValue));
end;

procedure TSharedBinaryWriter.WriteUInt16LE(AValue: Word);
var
  LBytes: array[0..1] of Byte;
begin
  LBytes[0] := Byte(AValue);
  LBytes[1] := Byte(AValue shr 8);
  WriteExact(LBytes, SizeOf(LBytes));
end;

procedure TSharedBinaryWriter.WriteInt16LE(AValue: SmallInt);
begin
  WriteUInt16LE(Word(AValue));
end;

procedure TSharedBinaryWriter.WriteUInt32LE(AValue: Cardinal);
var
  LBytes: array[0..3] of Byte;
begin
  LBytes[0] := Byte(AValue);
  LBytes[1] := Byte(AValue shr 8);
  LBytes[2] := Byte(AValue shr 16);
  LBytes[3] := Byte(AValue shr 24);
  WriteExact(LBytes, SizeOf(LBytes));
end;

procedure TSharedBinaryWriter.WriteInt32LE(AValue: LongInt);
begin
  WriteUInt32LE(Cardinal(AValue));
end;

procedure TSharedBinaryWriter.WriteSingleLE(AValue: Single);
var
  LBits: Cardinal;
begin
  Move(AValue, LBits, SizeOf(LBits));
  WriteUInt32LE(LBits);
end;

procedure TSharedBinaryWriter.WriteDoubleLE(AValue: Double);
var
  LBits: QWord;
  LBytes: array[0..7] of Byte;
  LIndex: Integer;
begin
  Move(AValue, LBits, SizeOf(LBits));
  for LIndex := 0 to High(LBytes) do
    LBytes[LIndex] := Byte(LBits shr (LIndex * 8));
  WriteExact(LBytes, SizeOf(LBytes));
end;

procedure TSharedBinaryWriter.WriteBoolean8(AValue: Boolean);
begin
  WriteUInt8(Ord(AValue));
end;

procedure TSharedBinaryWriter.WriteAnsi8(const AValue: RawByteString;
  AMaxBytes: Cardinal);
begin
  CheckStringLength(AValue, AMaxBytes, High(Byte), 'Ansi8 string');
  WriteUInt8(Length(AValue));
  if AValue <> '' then
    WriteExact(AValue[1], Length(AValue));
end;

procedure TSharedBinaryWriter.WriteAnsi32(const AValue: RawByteString;
  AMaxBytes: Cardinal);
begin
  CheckStringLength(AValue, AMaxBytes, High(Cardinal), 'Ansi32 string');
  WriteUInt32LE(Length(AValue));
  if AValue <> '' then
    WriteExact(AValue[1], Length(AValue));
end;

procedure TSharedBinaryWriter.WriteCString(const AValue: RawByteString;
  AMaxBytes: Cardinal);
begin
  CheckStringLength(AValue, AMaxBytes, High(Cardinal), 'CString');
  if Pos(#0, AValue) <> 0 then
    raise ESharedBinaryFormatError.Create(
      'CString cannot contain an embedded null byte');
  if AValue <> '' then
    WriteExact(AValue[1], Length(AValue));
  WriteUInt8(0);
end;

procedure TSharedBinaryWriter.WriteFixedBytes(const AValue: TBytes);
begin
  if Length(AValue) > 0 then
    WriteExact(AValue[0], Length(AValue));
end;

end.
