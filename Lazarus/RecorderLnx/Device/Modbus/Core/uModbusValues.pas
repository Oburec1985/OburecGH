unit uModbusValues;

{$mode objfpc}{$H+}

// Converts protocol register bytes to typed values without transport or tag
// registry dependencies. Byte order names describe bytes A..H in value order.
interface

uses
  SysUtils, uModbusCoreTypes;

function ModbusValueByteCount(ADataType: TModbusDataType): Integer;
function DecodeModbusValue(const ABytes: TBytes; ADataType: TModbusDataType;
  AOrder: TModbusByteOrder; out AValue: Double): Boolean;
function EncodeModbusValue(AValue: Double; ADataType: TModbusDataType;
  AOrder: TModbusByteOrder; out ABytes: TBytes): Boolean;

implementation

function ModbusValueByteCount(ADataType: TModbusDataType): Integer;
begin
  case ADataType of
    mdBool, mdUInt16, mdInt16: Result := 2;
    mdUInt32, mdInt32, mdFloat32: Result := 4;
    mdFloat64: Result := 8;
  end;
end;

procedure OrderedToCanonical(const ASource: TBytes; AOrder: TModbusByteOrder;
  out ADest: TBytes);
var
  lIndex, lWords: Integer;
begin
  SetLength(ADest, Length(ASource));
  lWords := Length(ASource) div 2;
  for lIndex := 0 to lWords - 1 do begin
    case AOrder of
      moABCD: begin ADest[lIndex * 2] := ASource[lIndex * 2]; ADest[lIndex * 2 + 1] := ASource[lIndex * 2 + 1]; end;
      moBADC: begin ADest[lIndex * 2] := ASource[lIndex * 2 + 1]; ADest[lIndex * 2 + 1] := ASource[lIndex * 2]; end;
      moCDAB: begin ADest[lIndex * 2] := ASource[(lWords - 1 - lIndex) * 2]; ADest[lIndex * 2 + 1] := ASource[(lWords - 1 - lIndex) * 2 + 1]; end;
      moDCBA: begin ADest[lIndex * 2] := ASource[Length(ASource) - 1 - lIndex * 2]; ADest[lIndex * 2 + 1] := ASource[Length(ASource) - 2 - lIndex * 2]; end;
    end;
  end;
end;

procedure CanonicalToOrdered(const ASource: TBytes; AOrder: TModbusByteOrder;
  out ADest: TBytes);
begin
  // All four permutations are involutions.
  OrderedToCanonical(ASource, AOrder, ADest);
end;

function DecodeModbusValue(const ABytes: TBytes; ADataType: TModbusDataType;
  AOrder: TModbusByteOrder; out AValue: Double): Boolean;
var
  lCanonical, lNative: TBytes;
  lIndex: Integer;
  lU16: Word;
  lI16: SmallInt;
  lU32: Cardinal;
  lI32: LongInt;
  lF32: Single;
  lF64: Double;
begin
  Result := Length(ABytes) = ModbusValueByteCount(ADataType);
  if not Result then Exit;
  OrderedToCanonical(ABytes, AOrder, lCanonical);
  SetLength(lNative, Length(lCanonical));
  for lIndex := 0 to High(lCanonical) do lNative[lIndex] := lCanonical[High(lCanonical) - lIndex];
  case ADataType of
    mdBool: begin lU16 := (Word(lCanonical[0]) shl 8) or lCanonical[1]; AValue := Ord(lU16 <> 0); end;
    mdUInt16: begin Move(lNative[0], lU16, 2); AValue := lU16; end;
    mdInt16: begin Move(lNative[0], lI16, 2); AValue := lI16; end;
    mdUInt32: begin Move(lNative[0], lU32, 4); AValue := lU32; end;
    mdInt32: begin Move(lNative[0], lI32, 4); AValue := lI32; end;
    mdFloat32: begin Move(lNative[0], lF32, 4); AValue := lF32; end;
    mdFloat64: begin Move(lNative[0], lF64, 8); AValue := lF64; end;
  end;
end;

function EncodeModbusValue(AValue: Double; ADataType: TModbusDataType;
  AOrder: TModbusByteOrder; out ABytes: TBytes): Boolean;
var
  lCanonical, lNative: TBytes;
  lIndex: Integer;
  lU16: Word;
  lI16: SmallInt;
  lU32: Cardinal;
  lI32: LongInt;
  lF32: Single;
  lF64: Double;
begin
  Result := True;
  SetLength(lNative, ModbusValueByteCount(ADataType));
  case ADataType of
    mdBool: begin if AValue <> 0 then lU16 := 1 else lU16 := 0; Move(lU16, lNative[0], 2); end;
    mdUInt16: begin if (AValue < 0) or (AValue > High(Word)) then Exit(False); lU16 := Trunc(AValue); Move(lU16, lNative[0], 2); end;
    mdInt16: begin if (AValue < Low(SmallInt)) or (AValue > High(SmallInt)) then Exit(False); lI16 := Trunc(AValue); Move(lI16, lNative[0], 2); end;
    mdUInt32: begin if (AValue < 0) or (AValue > High(Cardinal)) then Exit(False); lU32 := Trunc(AValue); Move(lU32, lNative[0], 4); end;
    mdInt32: begin if (AValue < Low(LongInt)) or (AValue > High(LongInt)) then Exit(False); lI32 := Trunc(AValue); Move(lI32, lNative[0], 4); end;
    mdFloat32: begin lF32 := AValue; Move(lF32, lNative[0], 4); end;
    mdFloat64: begin lF64 := AValue; Move(lF64, lNative[0], 8); end;
  end;
  SetLength(lCanonical, Length(lNative));
  for lIndex := 0 to High(lNative) do lCanonical[lIndex] := lNative[High(lNative) - lIndex];
  CanonicalToOrdered(lCanonical, AOrder, ABytes);
end;

end.
