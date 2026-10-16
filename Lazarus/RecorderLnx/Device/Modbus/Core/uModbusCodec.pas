unit uModbusCodec;

{$mode objfpc}{$H+}

// Stateless Modbus PDU/ADU codec. Expected protocol failures are returned as
// result codes so transport workers never need exception-based flow control.
interface

uses
  SysUtils;

type
  TModbusCodecResult = (mcOk, mcTooShort, mcBadProtocolId, mcBadLength,
    mcBadUnitId, mcBadFunction, mcExceptionResponse, mcBadCrc, mcMalformed);
  TModbusResponse = record
    FunctionCode: Byte;
    ExceptionCode: Byte;
    Data: TBytes;
  end;

function BuildReadPdu(AFunction: Byte; AAddress, ACount: Word; out APdu: TBytes): TModbusCodecResult;
function BuildWriteSinglePdu(AFunction: Byte; AAddress, AValue: Word; out APdu: TBytes): TModbusCodecResult;
function BuildWriteMultiplePdu(AFunction: Byte; AAddress, ACount: Word;
  const AValues: TBytes; out APdu: TBytes): TModbusCodecResult;
function ParseResponsePdu(const APdu: TBytes; AExpectedFunction: Byte;
  out AResponse: TModbusResponse): TModbusCodecResult;
function WrapTcp(ARequestId: Word; AUnitId: Byte; const APdu: TBytes): TBytes;
function UnwrapTcp(const AFrame: TBytes; AExpectedRequestId: Word;
  AExpectedUnitId: Byte; out APdu: TBytes): TModbusCodecResult;
function ModbusCrc16(const AData: TBytes; ACount: Integer): Word;
function WrapRtu(AUnitId: Byte; const APdu: TBytes): TBytes;
function UnwrapRtu(const AFrame: TBytes; AExpectedUnitId: Byte;
  out APdu: TBytes): TModbusCodecResult;

implementation

procedure PutWord(var AData: TBytes; AOffset: Integer; AValue: Word);
begin
  AData[AOffset] := AValue shr 8;
  AData[AOffset + 1] := AValue and $FF;
end;

function GetWord(const AData: TBytes; AOffset: Integer): Word;
begin
  Result := (Word(AData[AOffset]) shl 8) or AData[AOffset + 1];
end;

function IsReadFunction(AFunction: Byte): Boolean;
begin
  Result := AFunction in [1, 2, 3, 4];
end;

function BuildReadPdu(AFunction: Byte; AAddress, ACount: Word; out APdu: TBytes): TModbusCodecResult;
var
  lMax: Word;
begin
  APdu := nil;
  if not IsReadFunction(AFunction) then Exit(mcBadFunction);
  if AFunction in [1, 2] then lMax := 2000 else lMax := 125;
  if (ACount = 0) or (ACount > lMax) or (Cardinal(AAddress) + ACount > 65536) then Exit(mcMalformed);
  SetLength(APdu, 5);
  APdu[0] := AFunction;
  PutWord(APdu, 1, AAddress);
  PutWord(APdu, 3, ACount);
  Result := mcOk;
end;

function BuildWriteSinglePdu(AFunction: Byte; AAddress, AValue: Word; out APdu: TBytes): TModbusCodecResult;
begin
  APdu := nil;
  if not (AFunction in [5, 6]) then Exit(mcBadFunction);
  if (AFunction = 5) and (AValue <> $0000) and (AValue <> $FF00) then Exit(mcMalformed);
  SetLength(APdu, 5);
  APdu[0] := AFunction;
  PutWord(APdu, 1, AAddress);
  PutWord(APdu, 3, AValue);
  Result := mcOk;
end;

function BuildWriteMultiplePdu(AFunction: Byte; AAddress, ACount: Word;
  const AValues: TBytes; out APdu: TBytes): TModbusCodecResult;
var
  lExpected: Integer;
begin
  APdu := nil;
  if not (AFunction in [15, 16]) then Exit(mcBadFunction);
  if AFunction = 15 then begin
    if (ACount = 0) or (ACount > 1968) then Exit(mcMalformed);
    lExpected := (ACount + 7) div 8;
  end else begin
    if (ACount = 0) or (ACount > 123) then Exit(mcMalformed);
    lExpected := ACount * 2;
  end;
  if (Length(AValues) <> lExpected) or (Cardinal(AAddress) + ACount > 65536) then Exit(mcMalformed);
  SetLength(APdu, 6 + lExpected);
  APdu[0] := AFunction;
  PutWord(APdu, 1, AAddress);
  PutWord(APdu, 3, ACount);
  APdu[5] := lExpected;
  if lExpected > 0 then Move(AValues[0], APdu[6], lExpected);
  Result := mcOk;
end;

function ParseResponsePdu(const APdu: TBytes; AExpectedFunction: Byte;
  out AResponse: TModbusResponse): TModbusCodecResult;
var
  lByteCount: Integer;
begin
  AResponse.FunctionCode := 0; AResponse.ExceptionCode := 0; AResponse.Data := nil;
  if Length(APdu) < 2 then Exit(mcTooShort);
  AResponse.FunctionCode := APdu[0];
  if APdu[0] = (AExpectedFunction or $80) then begin
    if Length(APdu) <> 2 then Exit(mcMalformed);
    AResponse.ExceptionCode := APdu[1];
    Exit(mcExceptionResponse);
  end;
  if APdu[0] <> AExpectedFunction then Exit(mcBadFunction);
  if IsReadFunction(APdu[0]) then begin
    lByteCount := APdu[1];
    if Length(APdu) <> lByteCount + 2 then Exit(mcBadLength);
    SetLength(AResponse.Data, lByteCount);
    if lByteCount > 0 then Move(APdu[2], AResponse.Data[0], lByteCount);
  end else if APdu[0] in [5, 6, 15, 16] then begin
    if Length(APdu) <> 5 then Exit(mcBadLength);
    SetLength(AResponse.Data, 4);
    Move(APdu[1], AResponse.Data[0], 4);
  end else Exit(mcBadFunction);
  Result := mcOk;
end;

function WrapTcp(ARequestId: Word; AUnitId: Byte; const APdu: TBytes): TBytes;
begin
  Result := nil;
  SetLength(Result, 7 + Length(APdu));
  PutWord(Result, 0, ARequestId);
  PutWord(Result, 2, 0);
  PutWord(Result, 4, Length(APdu) + 1);
  Result[6] := AUnitId;
  if Length(APdu) > 0 then Move(APdu[0], Result[7], Length(APdu));
end;

function UnwrapTcp(const AFrame: TBytes; AExpectedRequestId: Word;
  AExpectedUnitId: Byte; out APdu: TBytes): TModbusCodecResult;
var
  lLength: Word;
begin
  APdu := nil;
  if Length(AFrame) < 8 then Exit(mcTooShort);
  if GetWord(AFrame, 0) <> AExpectedRequestId then Exit(mcMalformed);
  if GetWord(AFrame, 2) <> 0 then Exit(mcBadProtocolId);
  lLength := GetWord(AFrame, 4);
  if (lLength < 2) or (Length(AFrame) <> 6 + lLength) then Exit(mcBadLength);
  if AFrame[6] <> AExpectedUnitId then Exit(mcBadUnitId);
  SetLength(APdu, lLength - 1);
  Move(AFrame[7], APdu[0], lLength - 1);
  Result := mcOk;
end;

function ModbusCrc16(const AData: TBytes; ACount: Integer): Word;
var
  lCrc: Cardinal;
  lByte, lBit: Integer;
begin
  lCrc := $FFFF;
  for lByte := 0 to ACount - 1 do begin
    lCrc := lCrc xor AData[lByte];
    for lBit := 0 to 7 do
      if (lCrc and 1) <> 0 then lCrc := (lCrc shr 1) xor $A001
      else lCrc := lCrc shr 1;
  end;
  Result := Word(lCrc and $FFFF);
end;

function WrapRtu(AUnitId: Byte; const APdu: TBytes): TBytes;
var
  lCrc: Word;
begin
  Result := nil;
  SetLength(Result, Length(APdu) + 3);
  Result[0] := AUnitId;
  if Length(APdu) > 0 then Move(APdu[0], Result[1], Length(APdu));
  lCrc := ModbusCrc16(Result, Length(Result) - 2);
  Result[High(Result) - 1] := lCrc and $FF;
  Result[High(Result)] := lCrc shr 8;
end;

function UnwrapRtu(const AFrame: TBytes; AExpectedUnitId: Byte;
  out APdu: TBytes): TModbusCodecResult;
var
  lCrc: Word;
begin
  APdu := nil;
  if Length(AFrame) < 4 then Exit(mcTooShort);
  if AFrame[0] <> AExpectedUnitId then Exit(mcBadUnitId);
  lCrc := ModbusCrc16(AFrame, Length(AFrame) - 2);
  if (AFrame[High(AFrame) - 1] <> (lCrc and $FF)) or
     (AFrame[High(AFrame)] <> (lCrc shr 8)) then Exit(mcBadCrc);
  SetLength(APdu, Length(AFrame) - 3);
  Move(AFrame[1], APdu[0], Length(APdu));
  Result := mcOk;
end;

end.
