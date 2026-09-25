program SharedBinaryIOTest;

{$mode ObjFPC}{$H+}

uses
  Classes, Math, SysUtils, uSharedBinaryIO;

procedure Fail(const AMessage: string);
begin
  raise Exception.Create(AMessage);
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    Fail(AMessage);
end;

procedure TestRoundTrip;
var
  LBytes: TBytes;
  LReader: TSharedBinaryReader;
  LStream: TMemoryStream;
  LWriter: TSharedBinaryWriter;
begin
  LStream := TMemoryStream.Create;
  try
    LWriter := TSharedBinaryWriter.Create(LStream);
    try
      LWriter.WriteUInt8($FE);
      LWriter.WriteInt8(-2);
      LWriter.WriteUInt16LE($FEDC);
      LWriter.WriteInt16LE(-1234);
      LWriter.WriteUInt32LE($FEDCBA98);
      LWriter.WriteInt32LE(-123456789);
      LWriter.WriteSingleLE(1.25);
      LWriter.WriteDoubleLE(-1234.5);
      LWriter.WriteBoolean8(True);
      LWriter.WriteAnsi8(RawByteString('short'), 20);
      LWriter.WriteAnsi32(RawByteString('long string'), 20);
      LWriter.WriteCString(RawByteString('zero'), 20);
      LBytes := TBytes.Create(1, 2, 3, 255);
      LWriter.WriteFixedBytes(LBytes);
    finally
      LWriter.Free;
    end;

    LStream.Position := 0;
    LReader := TSharedBinaryReader.Create(LStream);
    try
      Check(LReader.ReadUInt8 = $FE, 'UInt8 roundtrip failed');
      Check(LReader.ReadInt8 = -2, 'Int8 roundtrip failed');
      Check(LReader.ReadUInt16LE = $FEDC, 'UInt16 roundtrip failed');
      Check(LReader.ReadInt16LE = -1234, 'Int16 roundtrip failed');
      Check(LReader.ReadUInt32LE = $FEDCBA98, 'UInt32 roundtrip failed');
      Check(LReader.ReadInt32LE = -123456789, 'Int32 roundtrip failed');
      Check(SameValue(LReader.ReadSingleLE, 1.25, 1E-6),
        'Single roundtrip failed');
      Check(SameValue(LReader.ReadDoubleLE, -1234.5, 1E-12),
        'Double roundtrip failed');
      Check(LReader.ReadBoolean8, 'Boolean8 roundtrip failed');
      Check(LReader.ReadAnsi8(20) = RawByteString('short'),
        'Ansi8 roundtrip failed');
      Check(LReader.ReadAnsi32(20) = RawByteString('long string'),
        'Ansi32 roundtrip failed');
      Check(LReader.ReadCString(20) = RawByteString('zero'),
        'CString roundtrip failed');
      LBytes := LReader.ReadFixedBytes(4);
      Check((Length(LBytes) = 4) and (LBytes[0] = 1) and
        (LBytes[1] = 2) and (LBytes[2] = 3) and (LBytes[3] = 255),
        'Fixed bytes roundtrip failed');
    finally
      LReader.Free;
    end;
  finally
    LStream.Free;
  end;
end;

procedure TestLittleEndianLayout;
var
  LData: PByte;
  LStream: TMemoryStream;
  LWriter: TSharedBinaryWriter;
begin
  LStream := TMemoryStream.Create;
  try
    LWriter := TSharedBinaryWriter.Create(LStream);
    try
      LWriter.WriteUInt16LE($1234);
      LWriter.WriteUInt32LE($89ABCDEF);
    finally
      LWriter.Free;
    end;
    Check(LStream.Size = 6, 'Little-endian sample has an invalid size');
    LData := LStream.Memory;
    Check((LData[0] = $34) and (LData[1] = $12) and
      (LData[2] = $EF) and (LData[3] = $CD) and
      (LData[4] = $AB) and (LData[5] = $89),
      'Little-endian byte layout is invalid');
  finally
    LStream.Free;
  end;
end;

procedure TestTruncatedRead;
var
  LRaised: Boolean;
  LReader: TSharedBinaryReader;
  LStream: TBytesStream;
begin
  LStream := TBytesStream.Create(TBytes.Create($01, $02));
  try
    LReader := TSharedBinaryReader.Create(LStream);
    try
      LRaised := False;
      try
        LReader.ReadUInt32LE;
      except
        on E: ESharedBinaryFormatError do
          LRaised := True;
      end;
      Check(LRaised, 'Truncated UInt32 did not raise a format error');
    finally
      LReader.Free;
    end;
  finally
    LStream.Free;
  end;
end;

procedure TestInvalidLength;
var
  LRaised: Boolean;
  LReader: TSharedBinaryReader;
  LStream: TBytesStream;
begin
  LStream := TBytesStream.Create(TBytes.Create(5, 0, 0, 0));
  try
    LReader := TSharedBinaryReader.Create(LStream);
    try
      LRaised := False;
      try
        LReader.ReadAnsi32(4);
      except
        on E: ESharedBinaryFormatError do
          LRaised := True;
      end;
      Check(LRaised, 'Oversized Ansi32 did not raise a format error');
    finally
      LReader.Free;
    end;
  finally
    LStream.Free;
  end;
end;

procedure TestCStringEof;
var
  LRaised: Boolean;
  LReader: TSharedBinaryReader;
  LStream: TBytesStream;
begin
  LStream := TBytesStream.Create(TBytes.Create(Ord('a'), Ord('b')));
  try
    LReader := TSharedBinaryReader.Create(LStream);
    try
      LRaised := False;
      try
        LReader.ReadCString(10);
      except
        on E: ESharedBinaryFormatError do
          LRaised := True;
      end;
      Check(LRaised, 'Unterminated CString did not raise a format error');
    finally
      LReader.Free;
    end;
  finally
    LStream.Free;
  end;
end;

begin
  TestRoundTrip;
  TestLittleEndianLayout;
  TestTruncatedRead;
  TestInvalidLength;
  TestCStringEof;
  WriteLn('SharedBinaryIO tests passed');
end.
