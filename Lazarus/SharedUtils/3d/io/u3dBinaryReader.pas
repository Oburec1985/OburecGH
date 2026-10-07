unit u3dBinaryReader;

{ Performs bounded little-endian reads for legacy scene decoders. The caller
  owns the stream; malformed or over-limit input raises E3dFormatError. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils;

type
  E3dFormatError = class(Exception);
    T3dReadLimits = record
      MaxFileBytes, MaxStringBytes, MaxNodes, MaxVertices, MaxTriangles,
      MaxShapePoints, MaxAnimationKeys: QWord;
    end;

    T3dBinaryReader = class
      private
        fStream: TStream;
        fLimit: Int64;
        procedure Need(ABytes: QWord);
      public
        constructor Create(AStream: TStream; ALimit: Int64);
        function Position: Int64;
        procedure Seek(APosition: Int64);
        function ReadByte: Byte;
        function ReadWordLE: Word;
        function ReadUInt32LE: LongWord;
        function ReadSingleLE: Single;
        function ReadCString(AMaxBytes: QWord): RawByteString;
    end;

    function Default3dReadLimits: T3dReadLimits;
    procedure RequireCount(AValue, AMaximum: QWord; const ALabel: string);

    implementation

    function Default3dReadLimits: T3dReadLimits;
    begin
      Result.MaxFileBytes := 256 * 1024 * 1024;
      Result.MaxStringBytes := 4096;
      Result.MaxNodes := 100000;
      Result.MaxVertices := 5000000;
      Result.MaxTriangles := 5000000;
      Result.MaxShapePoints := 5000000;
      Result.MaxAnimationKeys := 5000000;
    end;

    procedure RequireCount(AValue, AMaximum: QWord; const ALabel: string);
    begin
      if AValue > AMaximum then
        raise E3dFormatError.CreateFmt('%s count %d exceeds limit %d', [ALabel, AValue, AMaximum]);
    end;

    constructor T3dBinaryReader.Create(AStream: TStream; ALimit: Int64);
    begin
      inherited Create;
      fStream := AStream;
      fLimit := ALimit;
    end;

    procedure T3dBinaryReader.Need(ABytes: QWord);
    begin
      if (ABytes > QWord(High(Int64))) or (fStream.Position < 0) or
         (fStream.Position > fLimit) or (ABytes > QWord(fLimit - fStream.Position)) then
        raise E3dFormatError.CreateFmt('Unexpected end of data at offset %d', [fStream.Position]);
    end;

    function T3dBinaryReader.Position: Int64;
    begin
      Result := fStream.Position;
    end;
    procedure T3dBinaryReader.Seek(APosition: Int64);
    begin
      if (APosition < 0) or (APosition > fLimit) then
        raise E3dFormatError.Create(
                                    'Invalid file offset'
        );
      fStream.Position := APosition;
    end;

    function T3dBinaryReader.ReadByte: Byte;
    begin
      Result := 0;
      Need(1);
      fStream.ReadBuffer(Result, 1);
    end;

    function T3dBinaryReader.ReadWordLE: Word;

    var B: array[0..1] of Byte;
    begin
      B[0] := 0;
      B[1] := 0;
      Need(2);
      fStream.ReadBuffer(B, 2);
      Result := B[0] or (Word(B[1]) shl 8);
    end;

    function T3dBinaryReader.ReadUInt32LE: LongWord;

    var B: array[0..3] of Byte;
    begin
      FillChar(B, SizeOf(B), 0);
      Need(4);
      fStream.ReadBuffer(B, 4);
      Result := LongWord(B[0]) or (LongWord(B[1]) shl 8) or
                (LongWord(B[2]) shl 16) or (LongWord(B[3]) shl 24);
    end;

    function T3dBinaryReader.ReadSingleLE: Single;

    var U: LongWord;
    begin
      Result := 0;
      U := ReadUInt32LE;
      Move(U, Result, SizeOf(Result));
    end;

    function T3dBinaryReader.ReadCString(AMaxBytes: QWord): RawByteString;

    var B: Byte;
      N: QWord;
    begin
      Result := '';
      N := 0;
      repeat
        if N >= AMaxBytes then
          raise E3dFormatError.Create('String exceeds limit');
        B := ReadByte;
        if B = 0 then
          Break;
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result)] := AnsiChar(B);
        Inc(N);
      until False;
    end;

  end.
