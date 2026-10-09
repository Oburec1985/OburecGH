program FakePxiMx248Bridge;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Windows, uRecorderPxiMx248BridgeCodec;

function ReadExact(AStream: TStream; var ABuffer; ACount: Integer): Boolean;
var
  lRead: Integer;
  lTarget: PByte;
begin
  lTarget := @ABuffer;
  while ACount > 0 do
  begin
    lRead := AStream.Read(lTarget^, ACount);
    if lRead <= 0 then Exit(False);
    Inc(lTarget, lRead);
    Dec(ACount, lRead);
  end;
  Result := True;
end;

procedure PutU32(AValue: Cardinal; var ABuffer: array of Byte; AOffset: Integer);
begin
  ABuffer[AOffset] := Byte(AValue);
  ABuffer[AOffset + 1] := Byte(AValue shr 8);
  ABuffer[AOffset + 2] := Byte(AValue shr 16);
  ABuffer[AOffset + 3] := Byte(AValue shr 24);
end;

procedure PutSingle(AValue: Single; var ABuffer: array of Byte; AOffset: Integer);
begin
  Move(AValue, ABuffer[AOffset], SizeOf(AValue));
end;

procedure WriteReply(AOutput: TStream; const ARequest: TPxiMx248BridgeHeader;
  AWrongRequestId, ABlock, ADiscovery: Boolean; ACode: Cardinal);
var
  lHeader: TPxiMx248BridgeHeader;
  lHeaderBytes: array[0..15] of Byte;
  lPayload: array[0..255] of Byte;
  lPayloadSize: Integer;
  lDiscovery: RawByteString;
begin
  FillChar(lPayload, SizeOf(lPayload), 0);
  PutU32(ACode, lPayload, 0);
  if ADiscovery then
  begin
    lDiscovery := '0,3253,524,MX-248 PXI Card,1,2,14';
    lPayloadSize := 16 + Length(lDiscovery);
    PutU32(Length(lDiscovery), lPayload, 12);
    Move(PAnsiChar(lDiscovery)^, lPayload[16], Length(lDiscovery));
  end
  else if ABlock then
  begin
    lPayloadSize := 56;
    PutU32(40, lPayload, 12);
    PutU32(2, lPayload, 16);
    PutU32(8, lPayload, 20);
    PutU32(2, lPayload, 24);
    PutU32(2, lPayload, 28);
    lPayload[32] := $FF; lPayload[33] := $FF;
    lPayload[34] := 2; lPayload[35] := 0;
    PutU32(3, lPayload, 36);
    PutU32(4, lPayload, 40);
    PutU32(2, lPayload, 44);
    PutSingle(3.5, lPayload, 48);
    PutSingle(-4.25, lPayload, 52);
  end
  else
  begin
    lPayloadSize := 16;
    PutU32(0, lPayload, 12);
  end;
  lHeader := ARequest;
  if AWrongRequestId then Inc(lHeader.RequestId);
  lHeader.PayloadSize := lPayloadSize;
  PxiMx248EncodeHeader(lHeader, lHeaderBytes);
  AOutput.WriteBuffer(lHeaderBytes[0], SizeOf(lHeaderBytes));
  AOutput.WriteBuffer(lPayload[0], lPayloadSize);
end;

var
  lInput, lOutput: THandleStream;
  lHeader: TPxiMx248BridgeHeader;
  lHeaderBytes: array[0..15] of Byte;
  lPayload: array of Byte;
  lError: string;
  lRunning, lConfigureErrorPending: Boolean;
begin
  lInput := THandleStream.Create(GetStdHandle(STD_INPUT_HANDLE));
  lOutput := THandleStream.Create(GetStdHandle(STD_OUTPUT_HANDLE));
  try
    lRunning := True;
    lConfigureErrorPending := True;
    while lRunning and ReadExact(lInput, lHeaderBytes[0], SizeOf(lHeaderBytes)) do
    begin
      if not PxiMx248DecodeHeader(lHeaderBytes, lHeader, lError) then Halt(2);
      SetLength(lPayload, lHeader.PayloadSize);
      if (lHeader.PayloadSize > 0) and
        not ReadExact(lInput, lPayload[0], lHeader.PayloadSize) then Halt(3);
      WriteReply(lOutput, lHeader, lHeader.Command = CPxiMx248CommandTest,
        lHeader.Command = CPxiMx248CommandReadBlock,
        lHeader.Command = CPxiMx248CommandDiscover,
        Ord((lHeader.Command = CPxiMx248CommandConfigure) and
          lConfigureErrorPending) * 2);
      if lHeader.Command = CPxiMx248CommandConfigure then
        lConfigureErrorPending := False;
      lRunning := lHeader.Command <> CPxiMx248CommandShutdown;
    end;
  finally
    lOutput.Free;
    lInput.Free;
  end;
end.
