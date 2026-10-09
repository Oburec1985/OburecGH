program PxiMx248BridgeProtocolTest;

{$APPTYPE CONSOLE}

uses System.SysUtils, System.Classes,
  uPxiMx248BridgeProtocol in '..\Source\uPxiMx248BridgeProtocol.pas';

procedure Check(AValue: Boolean; const AText: string);
begin
  if not AValue then raise Exception.Create(AText);
end;

var M: TMemoryStream; InHeader, OutHeader: TBridgeHeader; Payload: TBytes;
  ErrorText: string; Config, Decoded: TMx248ConfigureV1; I: Integer;
  ReadHeader,DecodedReadHeader: TMx248ReadChannelHeader;
begin
  M := TMemoryStream.Create;
  try
    InHeader.Magic := BRIDGE_MAGIC;
    InHeader.Version := BRIDGE_VERSION;
    InHeader.Command := Ord(bcHello);
    InHeader.RequestId := 42;
    InHeader.PayloadSize := 3;
    M.WriteBuffer(InHeader, SizeOf(InHeader));
    M.WriteBuffer(PAnsiChar(AnsiString('abc'))^, 3);
    M.Position := 0;
    Check(ReadFrame(M, OutHeader, Payload, ErrorText), 'valid frame rejected');
    Check((OutHeader.RequestId = 42) and (Length(Payload) = 3), 'frame changed');

    M.Clear;
    InHeader.PayloadSize := BRIDGE_MAX_PAYLOAD + 1;
    M.WriteBuffer(InHeader, SizeOf(InHeader)); M.Position := 0;
    Check(not ReadFrame(M, OutHeader, Payload, ErrorText), 'oversize accepted');
    Check(ErrorText = 'payload too large', 'wrong oversize diagnostic');

    FillChar(Config,SizeOf(Config),0); Config.SampleRateHz:=48000;
    Config.BlockSamples:=4096; Config.CalibrationMode:=2;
    for I:=0 to 7 do begin
      Config.Channels[I].Enabled:=Byte(I<>7);
      Config.Channels[I].AmplifierEnabled:=1; Config.Channels[I].InputMode:=I mod 3;
      Config.Channels[I].RangeIndex:=I; Config.Channels[I].LpfIndex:=7-I;
      Config.Channels[I].IcpCurrent:=I mod 3;
      Config.Channels[I].CalibrationEnabled:=Byte(I=0);
      Config.Channels[I].InputFloating:=Byte(I=1);
    end;
    SetLength(Payload,SizeOf(Config)); Move(Config,Payload[0],SizeOf(Config));
    Check(DecodeConfigureV1(Payload,Decoded,ErrorText),'CONFIGURE rejected: '+ErrorText);
    Check(CompareMem(@Config,@Decoded,SizeOf(Config)),'CONFIGURE round trip changed bytes');
    SetLength(Payload,SizeOf(Config)-1);
    Check(not DecodeConfigureV1(Payload,Decoded,ErrorText),'short CONFIGURE accepted');
    SetLength(Payload,SizeOf(Config)); Move(Config,Payload[0],SizeOf(Config)); Payload[13]:=1;
    Check(not DecodeConfigureV1(Payload,Decoded,ErrorText),'nonzero reserved byte accepted');
    Move(Config,Payload[0],SizeOf(Config)); Payload[16+5]:=3;
    Check(not DecodeConfigureV1(Payload,Decoded,ErrorText),'invalid ICP current accepted');

    SetLength(Payload,2*SizeOf(ReadHeader));
    ReadHeader.LogicalChannel:=1; ReadHeader.SampleType:=MX248_SAMPLE_VT_R4;
    ReadHeader.SampleCount:=16; Move(ReadHeader,Payload[0],SizeOf(ReadHeader));
    ReadHeader.LogicalChannel:=8; Move(ReadHeader,Payload[SizeOf(ReadHeader)],SizeOf(ReadHeader));
    Check(DecodeReadChannelHeader(Payload,0,DecodedReadHeader),'channel 1 header rejected');
    Check((DecodedReadHeader.LogicalChannel=1) and
      (DecodedReadHeader.SampleType=MX248_SAMPLE_VT_R4),'channel 1 mapping changed');
    Check(DecodeReadChannelHeader(Payload,SizeOf(ReadHeader),DecodedReadHeader),'channel 8 header rejected');
    Check((DecodedReadHeader.LogicalChannel=8) and
      (DecodedReadHeader.SampleType=MX248_SAMPLE_VT_R4),'disabled 1/8 mapping changed');
    Writeln('RESULT PXI MX-248 bridge protocol passed');
  finally M.Free end;
end.
