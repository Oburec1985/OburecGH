unit uRecorderPxiMx248BridgeCodec;

{
  Platform-neutral codec for MX-248 Bridge IPC v1. It is the only client unit
  that knows the 16-byte little-endian frame header and payload layouts.
  It performs no process or device I/O and owns no external resources.

  DecodeBlock writes only into a caller-preallocated acquisition block. It
  never changes dynamic-array lengths; malformed lengths and channel counts
  fail before sample data is copied. Wire logical channels 1..8 map to stable
  Values[0..7]; sample type 4 is IEEE-754 float32. See
  Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, uRecorderAcquisitionTypes, uRecorderPxiMx248Types;

const
  CPxiMx248BridgeMagic = $42383432;
  CPxiMx248BridgeVersion = 1;
  CPxiMx248BridgeHeaderSize = 16;
  CPxiMx248BridgeMaxPayload = 1024 * 1024;

  CPxiMx248CommandHello = 1;
  CPxiMx248CommandStatus = 2;
  CPxiMx248CommandDiscover = 10;
  CPxiMx248CommandConnect = 11;
  CPxiMx248CommandInitialize = 12;
  CPxiMx248CommandTest = 13;
  CPxiMx248CommandConfigure = 14;
  CPxiMx248CommandStart = 15;
  CPxiMx248CommandStop = 16;
  CPxiMx248CommandReadBlock = 17;
  CPxiMx248CommandDisconnect = 18;
  CPxiMx248CommandShutdown = 255;

type
  TPxiMx248BridgeHeader = record
    Magic: Cardinal;
    Version: Word;
    Command: Word;
    RequestId: Cardinal;
    PayloadSize: Cardinal;
  end;

procedure PxiMx248EncodeHeader(const AHeader: TPxiMx248BridgeHeader;
  var ABuffer: array of Byte);
function PxiMx248DecodeHeader(const ABuffer: array of Byte;
  out AHeader: TPxiMx248BridgeHeader; out AError: string): Boolean;
procedure PxiMx248EncodeInt32(AValue: LongInt; var ABuffer: array of Byte);
procedure PxiMx248EncodeConfigure(const AConfiguration: TPxiMx248Configuration;
  var ABuffer: array of Byte);
function PxiMx248DecodeResult(const APayload: array of Byte; APayloadSize: Cardinal;
  out ACode: Cardinal; out AStage, AText: string;
  out ADataOffset, ADataSize: Cardinal; out AError: string): Boolean;
function PxiMx248DecodeBlock(const APayload: array of Byte;
  AOffset, ASize: Cardinal; ASampleRateHz: Double;
  var ABlock: TRecorderAcquisitionBlock; out AError: string): Boolean;

implementation

function ReadU16(const ABuffer: array of Byte; AOffset: Cardinal): Word;
begin
  Result := Word(ABuffer[AOffset]) or (Word(ABuffer[AOffset + 1]) shl 8);
end;

function ReadU32(const ABuffer: array of Byte; AOffset: Cardinal): Cardinal;
begin
  Result := Cardinal(ABuffer[AOffset]) or
    (Cardinal(ABuffer[AOffset + 1]) shl 8) or
    (Cardinal(ABuffer[AOffset + 2]) shl 16) or
    (Cardinal(ABuffer[AOffset + 3]) shl 24);
end;

procedure WriteU16(AValue: Word; var ABuffer: array of Byte; AOffset: Cardinal);
begin
  ABuffer[AOffset] := Byte(AValue);
  ABuffer[AOffset + 1] := Byte(AValue shr 8);
end;

procedure WriteU32(AValue: Cardinal; var ABuffer: array of Byte;
  AOffset: Cardinal);
begin
  ABuffer[AOffset] := Byte(AValue);
  ABuffer[AOffset + 1] := Byte(AValue shr 8);
  ABuffer[AOffset + 2] := Byte(AValue shr 16);
  ABuffer[AOffset + 3] := Byte(AValue shr 24);
end;

procedure PxiMx248EncodeHeader(const AHeader: TPxiMx248BridgeHeader;
  var ABuffer: array of Byte);
begin
  if Length(ABuffer) < CPxiMx248BridgeHeaderSize then
    raise EArgumentException.Create('MX-248 header buffer is too small');
  WriteU32(AHeader.Magic, ABuffer, 0);
  WriteU16(AHeader.Version, ABuffer, 4);
  WriteU16(AHeader.Command, ABuffer, 6);
  WriteU32(AHeader.RequestId, ABuffer, 8);
  WriteU32(AHeader.PayloadSize, ABuffer, 12);
end;

function PxiMx248DecodeHeader(const ABuffer: array of Byte;
  out AHeader: TPxiMx248BridgeHeader; out AError: string): Boolean;
begin
  AError := '';
  if Length(ABuffer) < CPxiMx248BridgeHeaderSize then
  begin
    AError := 'truncated bridge header';
    Exit(False);
  end;
  AHeader.Magic := ReadU32(ABuffer, 0);
  AHeader.Version := ReadU16(ABuffer, 4);
  AHeader.Command := ReadU16(ABuffer, 6);
  AHeader.RequestId := ReadU32(ABuffer, 8);
  AHeader.PayloadSize := ReadU32(ABuffer, 12);
  if AHeader.Magic <> CPxiMx248BridgeMagic then
    AError := 'bad bridge magic'
  else if AHeader.Version <> CPxiMx248BridgeVersion then
    AError := 'bridge version mismatch'
  else if AHeader.PayloadSize > CPxiMx248BridgeMaxPayload then
    AError := 'bridge payload exceeds 1 MiB';
  Result := AError = '';
end;

procedure PxiMx248EncodeInt32(AValue: LongInt; var ABuffer: array of Byte);
begin
  if Length(ABuffer) < SizeOf(LongInt) then
    raise EArgumentException.Create('MX-248 Int32 buffer is too small');
  WriteU32(Cardinal(AValue), ABuffer, 0);
end;

procedure PxiMx248EncodeConfigure(
  const AConfiguration: TPxiMx248Configuration; var ABuffer: array of Byte);
var
  I, lOffset: Integer;
  lBits: QWord;
begin
  if Length(ABuffer) < 80 then
    raise EArgumentException.Create('MX-248 configure buffer is too small');
  FillChar(ABuffer[0], 80, 0);
  lBits := 0;
  Move(AConfiguration.SampleRateHz, lBits, SizeOf(lBits));
  WriteU32(Cardinal(lBits), ABuffer, 0);
  WriteU32(Cardinal(lBits shr 32), ABuffer, 4);
  WriteU32(Cardinal(AConfiguration.BlockSamples), ABuffer, 8);
  ABuffer[12] := Ord(AConfiguration.CalibrationMode);
  for I := 0 to CPxiMx248ChannelCount - 1 do
  begin
    lOffset := 16 + I * 8;
    ABuffer[lOffset] := Ord(AConfiguration.Channels[I].Enabled);
    ABuffer[lOffset + 1] := Ord(AConfiguration.Channels[I].AmplifierEnabled);
    ABuffer[lOffset + 2] := Ord(AConfiguration.Channels[I].InputMode);
    ABuffer[lOffset + 3] := Byte(AConfiguration.Channels[I].RangeIndex);
    ABuffer[lOffset + 4] := Byte(AConfiguration.Channels[I].LowPassFilterIndex);
    ABuffer[lOffset + 5] := Ord(AConfiguration.Channels[I].IcpCurrent);
    ABuffer[lOffset + 6] := Ord(AConfiguration.Channels[I].CalibrationEnabled);
    ABuffer[lOffset + 7] := Ord(AConfiguration.Channels[I].InputFloating);
  end;
end;

function ReadText(const APayload: array of Byte; APayloadSize: Cardinal;
  var AOffset: Cardinal;
  out AText: string): Boolean;
var
  lSize: Cardinal;
begin
  AText := '';
  if (APayloadSize > Cardinal(Length(APayload))) or (AOffset > APayloadSize) or
    (APayloadSize - AOffset < 4) then Exit(False);
  lSize := ReadU32(APayload, AOffset);
  Inc(AOffset, 4);
  if lSize > APayloadSize - AOffset then Exit(False);
  if lSize > 0 then SetString(AText, PChar(@APayload[AOffset]), lSize);
  Inc(AOffset, lSize);
  Result := True;
end;

function PxiMx248DecodeResult(const APayload: array of Byte; APayloadSize: Cardinal;
  out ACode: Cardinal; out AStage, AText: string;
  out ADataOffset, ADataSize: Cardinal; out AError: string): Boolean;
var
  lOffset: Cardinal;
begin
  AError := '';
  ACode := 0;
  AStage := '';
  AText := '';
  ADataOffset := 0;
  ADataSize := 0;
  if (APayloadSize > Cardinal(Length(APayload))) or (APayloadSize < 4) then
  begin
    AError := 'truncated bridge result code';
    Exit(False);
  end;
  ACode := ReadU32(APayload, 0);
  lOffset := 4;
  if not ReadText(APayload, APayloadSize, lOffset, AStage) or
    not ReadText(APayload, APayloadSize, lOffset, AText) then
  begin
    AError := 'truncated bridge result text';
    Exit(False);
  end;
  if APayloadSize - lOffset < 4 then
  begin
    AError := 'truncated bridge result data length';
    Exit(False);
  end;
  ADataSize := ReadU32(APayload, lOffset);
  Inc(lOffset, 4);
  if ADataSize <> APayloadSize - lOffset then
  begin
    AError := 'bridge result data length mismatch';
    Exit(False);
  end;
  ADataOffset := lOffset;
  Result := True;
end;

function ReadSignedSample(const APayload: array of Byte; AOffset,
  AWidth: Cardinal; out AValue: Double): Boolean;
var
  lI8: ShortInt;
  lI16: SmallInt;
  lSingle: Single;
  lI64: Int64;
begin
  Result := True;
  case AWidth of
    1: begin lI8 := ShortInt(APayload[AOffset]); AValue := lI8 end;
    2: begin lI16 := SmallInt(ReadU16(APayload, AOffset)); AValue := lI16 end;
    4:
      begin
        Move(APayload[AOffset], lSingle, SizeOf(lSingle));
        AValue := lSingle;
      end;
    8:
      begin
        lI64 := Int64(QWord(ReadU32(APayload, AOffset)) or
          (QWord(ReadU32(APayload, AOffset + 4)) shl 32));
        AValue := lI64;
      end;
  else
    Result := False;
  end;
end;

function PxiMx248DecodeBlock(const APayload: array of Byte;
  AOffset, ASize: Cardinal; ASampleRateHz: Double;
  var ABlock: TRecorderAcquisitionBlock; out AError: string): Boolean;
var
  I, J: Integer;
  lChannelCount, lChannelId, lWidth, lCount, lFirstCount: Cardinal;
  lLimit: Cardinal;
  lValue: Double;
  lSeen: array[0..CPxiMx248ChannelCount - 1] of Boolean;
begin
  AError := '';
  FillChar(lSeen, SizeOf(lSeen), 0);
  if (AOffset > Cardinal(Length(APayload))) or
    (ASize > Cardinal(Length(APayload)) - AOffset) then
  begin
    AError := 'block lies outside bridge payload';
    Exit(False);
  end;
  lLimit := AOffset + ASize;
  if lLimit - AOffset < 4 then
  begin
    AError := 'truncated block channel count';
    Exit(False);
  end;
  lChannelCount := ReadU32(APayload, AOffset);
  Inc(AOffset, 4);
  if (lChannelCount = 0) or (lChannelCount > Cardinal(Length(ABlock.Values))) then
  begin
    AError := 'block channel count exceeds prepared capacity';
    Exit(False);
  end;
  lFirstCount := 0;
  for I := 0 to Integer(lChannelCount) - 1 do
  begin
    if lLimit - AOffset < 12 then
    begin
      AError := 'truncated block channel header';
      Exit(False);
    end;
    lChannelId := ReadU32(APayload, AOffset);
    lWidth := ReadU32(APayload, AOffset + 4);
    lCount := ReadU32(APayload, AOffset + 8);
    Inc(AOffset, 12);
    if (lChannelId < 1) or (lChannelId > CPxiMx248ChannelCount) or
      (lChannelId > Cardinal(Length(ABlock.Values))) then
    begin
      AError := 'logical channel index exceeds prepared capacity';
      Exit(False);
    end;
    Dec(lChannelId);
    if lSeen[lChannelId] then
    begin
      AError := 'duplicate logical channel index';
      Exit(False);
    end;
    lSeen[lChannelId] := True;
    if not (lWidth in [1, 2, 4, 8]) then
    begin
      AError := 'unsupported block sample width';
      Exit(False);
    end;
    if (lCount > Cardinal(Length(ABlock.Values[lChannelId]))) or
      (lCount > (lLimit - AOffset) div lWidth) then
    begin
      AError := 'block sample count exceeds prepared capacity';
      Exit(False);
    end;
    if I = 0 then lFirstCount := lCount
    else if lCount <> lFirstCount then
    begin
      AError := 'different per-channel sample counts are unsupported';
      Exit(False);
    end;
    for J := 0 to Integer(lCount) - 1 do
    begin
      if not ReadSignedSample(APayload, AOffset, lWidth, lValue) then
      begin
        AError := 'invalid block sample';
        Exit(False);
      end;
      ABlock.Values[lChannelId][J] := lValue;
      Inc(AOffset, lWidth);
    end;
  end;
  if AOffset <> lLimit then
  begin
    AError := 'unexpected trailing block bytes';
    Exit(False);
  end;
  for I := 0 to Length(ABlock.Values) - 1 do
    if not lSeen[I] then
      for J := 0 to Integer(lFirstCount) - 1 do ABlock.Values[I][J] := 0;
  ABlock.ChannelCount := Length(ABlock.Values);
  ABlock.SampleCount := lFirstCount;
  ABlock.FirstTimeSec := 0;
  ABlock.SampleRateHz := ASampleRateHz;
  Result := True;
end;

end.
