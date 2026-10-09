program PxiMx248BridgeCodecTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, uRecorderAcquisitionTypes, uRecorderPxiMx248Types,
  uRecorderPxiMx248RuntimeTransport, uRecorderPxiMx248BridgeCodec,
  uRecorderPxiMx248WindowsTransport;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure PutU32(AValue: Cardinal; var ABuffer: array of Byte; AOffset: Integer);
begin
  ABuffer[AOffset] := Byte(AValue);
  ABuffer[AOffset + 1] := Byte(AValue shr 8);
  ABuffer[AOffset + 2] := Byte(AValue shr 16);
  ABuffer[AOffset + 3] := Byte(AValue shr 24);
end;

procedure PutI16(AValue: SmallInt; var ABuffer: array of Byte; AOffset: Integer);
begin
  ABuffer[AOffset] := Byte(Word(AValue));
  ABuffer[AOffset + 1] := Byte(Word(AValue) shr 8);
end;

procedure PutSingle(AValue: Single; var ABuffer: array of Byte; AOffset: Integer);
begin
  Move(AValue, ABuffer[AOffset], SizeOf(AValue));
end;

procedure TestHeaderAndConfigure;
var
  lHeader, lDecoded: TPxiMx248BridgeHeader;
  lHeaderBytes: array[0..15] of Byte;
  lConfigure: array[0..79] of Byte;
  lConfiguration: TPxiMx248Configuration;
  lError: string;
begin
  lHeader.Magic := CPxiMx248BridgeMagic;
  lHeader.Version := CPxiMx248BridgeVersion;
  lHeader.Command := CPxiMx248CommandConfigure;
  lHeader.RequestId := $10203040;
  lHeader.PayloadSize := 80;
  PxiMx248EncodeHeader(lHeader, lHeaderBytes);
  Check(PxiMx248DecodeHeader(lHeaderBytes, lDecoded, lError), lError);
  Check((lDecoded.RequestId = $10203040) and
    (lDecoded.Command = CPxiMx248CommandConfigure), 'header roundtrip');

  PxiMx248DefaultConfiguration(lConfiguration);
  lConfiguration.SampleRateHz := 1250.5;
  lConfiguration.BlockSamples := 33;
  lConfiguration.CalibrationMode := pcmPxi;
  lConfiguration.Channels[7].Enabled := False;
  lConfiguration.Channels[7].IcpCurrent := pic10mA;
  PxiMx248EncodeConfigure(lConfiguration, lConfigure);
  Check((lConfigure[8] = 33) and (lConfigure[12] = Ord(pcmPxi)),
    'configure fixed header');
  Check((lConfigure[16 + 7 * 8] = 0) and
    (lConfigure[16 + 7 * 8 + 5] = Ord(pic10mA)),
    'configure channel bytes');
end;

procedure TestResultAndPreallocatedBlock;
var
  lPayload: array[0..55] of Byte;
  lBlock: TRecorderAcquisitionBlock;
  lCode, lOffset, lSize: Cardinal;
  lStage, lText, lError: string;
begin
  FillChar(lPayload, SizeOf(lPayload), 0);
  { result: code, empty stage/text, 40-byte data }
  PutU32(40, lPayload, 12);
  PutU32(2, lPayload, 16);
  { sparse logical channel 7: int16 samples=-1,2 }
  PutU32(8, lPayload, 20);
  PutU32(2, lPayload, 24);
  PutU32(2, lPayload, 28);
  PutI16(-1, lPayload, 32);
  PutI16(2, lPayload, 34);
  { sparse logical channel 2: IEEE float32 samples=3.5,-4.25 }
  PutU32(3, lPayload, 36);
  PutU32(4, lPayload, 40);
  PutU32(2, lPayload, 44);
  PutSingle(3.5, lPayload, 48);
  PutSingle(-4.25, lPayload, 52);
  Check(PxiMx248DecodeResult(lPayload, 56, lCode, lStage, lText,
    lOffset, lSize, lError), lError);
  Check((lCode = 0) and (lOffset = 16) and (lSize = 40),
    'result envelope offsets');

  PreparePxiMx248Block(lBlock, CPxiMx248ChannelCount, 2);
  Check(PxiMx248DecodeBlock(lPayload, lOffset, lSize, 1250.5,
    lBlock, lError), lError);
  Check((lBlock.ChannelCount = CPxiMx248ChannelCount) and
    (lBlock.SampleCount = 2),
    'decoded block dimensions');
  Check((lBlock.Values[7][0] = -1) and (lBlock.Values[7][1] = 2) and
    (Abs(lBlock.Values[2][0] - 3.5) < 1e-7) and
    (Abs(lBlock.Values[2][1] + 4.25) < 1e-7),
    'decoded sparse int16/float32 samples');
  Check((lBlock.Values[0][0] = 0) and (lBlock.Values[6][1] = 0),
    'disabled logical channels must be cleared');
  Check(Abs(lBlock.SampleRateHz - 1250.5) < 1e-12,
    'decoded sample rate');
end;

begin
  try
    TestHeaderAndConfigure;
    TestResultAndPreallocatedBlock;
    WriteLn('RESULT PXI MX-248 bridge codec passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT PXI MX-248 bridge codec failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
