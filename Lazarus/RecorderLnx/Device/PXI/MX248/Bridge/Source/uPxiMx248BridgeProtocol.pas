unit uPxiMx248BridgeProtocol;

interface

uses System.SysUtils, System.Classes, System.Math;

const
  BRIDGE_MAGIC = $42383432; { "248B" }
  BRIDGE_VERSION = 1;
  BRIDGE_MAX_PAYLOAD = 1024 * 1024;
  MX248_SAMPLE_VT_R4 = 4;

type
  TBridgeCommand = (bcHello = 1, bcStatus = 2, bcDiscover = 10,
    bcConnect = 11, bcInitialize = 12, bcTest = 13, bcConfigure = 14,
    bcStart = 15, bcStop = 16, bcReadBlock = 17, bcDisconnect = 18,
    bcShutdown = 255);
  TBridgeCode = (brOk, brBadFrame, brVersion, brUnsupported, brDevApi,
    brInternal);
  TBridgeHeader = packed record
    Magic: Cardinal;
    Version: Word;
    Command: Word;
    RequestId: Cardinal;
    PayloadSize: Cardinal;
  end;
  TMx248ChannelConfig = packed record
    Enabled, AmplifierEnabled, InputMode, RangeIndex: Byte;
    LpfIndex, IcpCurrent, CalibrationEnabled, InputFloating: Byte;
  end;
  TMx248ConfigureV1 = packed record
    SampleRateHz: Double;
    BlockSamples: Cardinal;
    CalibrationMode: Byte;
    Reserved: array[0..2] of Byte;
    Channels: array[0..7] of TMx248ChannelConfig;
  end;
  TMx248ReadChannelHeader = packed record
    LogicalChannel: Cardinal;
    SampleType: Cardinal;
    SampleCount: Cardinal;
  end;

function ReadExact(AStream: TStream; var ABuffer; ASize: Integer): Boolean;
function ReadFrame(AStream: TStream; out AHeader: TBridgeHeader;
  out APayload: TBytes; out AError: string): Boolean;
procedure WriteResult(AStream: TStream; const ARequest: TBridgeHeader;
  ACode: TBridgeCode; const AStage, AText: string; const AData: RawByteString);
function DecodeConfigureV1(const APayload: TBytes; out AConfig: TMx248ConfigureV1;
  out AError: string): Boolean;
function DecodeReadChannelHeader(const APayload: TBytes; AOffset: Integer;
  out AHeader: TMx248ReadChannelHeader): Boolean;

implementation

function DecodeReadChannelHeader(const APayload: TBytes; AOffset: Integer;
  out AHeader: TMx248ReadChannelHeader): Boolean;
begin
  FillChar(AHeader,SizeOf(AHeader),0);
  Result:=(AOffset>=0) and (AOffset<=Length(APayload)-SizeOf(AHeader));
  if Result then Move(APayload[AOffset],AHeader,SizeOf(AHeader));
end;

function DecodeConfigureV1(const APayload: TBytes; out AConfig: TMx248ConfigureV1;
  out AError: string): Boolean;
var I: Integer;
begin
  FillChar(AConfig, SizeOf(AConfig), 0); AError := '';
  if Length(APayload) <> SizeOf(AConfig) then begin
    AError := 'CONFIGURE v1 payload must be 80 bytes'; Exit(False)
  end;
  Move(APayload[0], AConfig, SizeOf(AConfig));
  if IsNan(AConfig.SampleRateHz) or IsInfinite(AConfig.SampleRateHz) or
     (AConfig.SampleRateHz <= 0) or (AConfig.BlockSamples = 0) or
     (AConfig.BlockSamples > 262144) then begin
    AError := 'invalid sample rate or block size'; Exit(False)
  end;
  if (AConfig.CalibrationMode > 2) or (AConfig.Reserved[0] <> 0) or
     (AConfig.Reserved[1] <> 0) or (AConfig.Reserved[2] <> 0) then begin
    AError := 'invalid flags or reserved bytes'; Exit(False)
  end;
  for I := 0 to 7 do
    with AConfig.Channels[I] do
      if (Enabled > 1) or (AmplifierEnabled > 1) or (IcpCurrent > 2) or
         (CalibrationEnabled > 1) or (InputFloating > 1) then begin
        AError := Format('invalid boolean in channel %d', [I]); Exit(False)
      end;
  Result := True;
end;

function ReadExact(AStream: TStream; var ABuffer; ASize: Integer): Boolean;
var P: PByte; N: Integer;
begin
  P := @ABuffer;
  while ASize > 0 do begin
    N := AStream.Read(P^, ASize);
    if N <= 0 then Exit(False);
    Inc(P, N); Dec(ASize, N);
  end;
  Result := True;
end;

function ReadFrame(AStream: TStream; out AHeader: TBridgeHeader;
  out APayload: TBytes; out AError: string): Boolean;
begin
  AError := ''; SetLength(APayload, 0);
  if not ReadExact(AStream, AHeader, SizeOf(AHeader)) then Exit(False);
  if AHeader.Magic <> BRIDGE_MAGIC then begin AError := 'bad magic'; Exit(False) end;
  if AHeader.Version <> BRIDGE_VERSION then begin AError := 'version mismatch'; Exit(False) end;
  if AHeader.PayloadSize > BRIDGE_MAX_PAYLOAD then begin AError := 'payload too large'; Exit(False) end;
  SetLength(APayload, AHeader.PayloadSize);
  Result := (AHeader.PayloadSize = 0) or ReadExact(AStream, APayload[0], Length(APayload));
  if not Result then AError := 'truncated payload';
end;

procedure PutText(AStream: TStream; const S: UTF8String);
var L: Cardinal;
begin
  L := Length(S); AStream.WriteBuffer(L, SizeOf(L));
  if L <> 0 then AStream.WriteBuffer(PAnsiChar(S)^, L);
end;

procedure PutRaw(AStream: TStream; const S: RawByteString);
var L: Cardinal;
begin
  L:=Length(S); AStream.WriteBuffer(L,SizeOf(L));
  if L<>0 then AStream.WriteBuffer(PAnsiChar(S)^,L);
end;

procedure WriteResult(AStream: TStream; const ARequest: TBridgeHeader;
  ACode: TBridgeCode; const AStage, AText: string; const AData: RawByteString);
var H: TBridgeHeader; M: TMemoryStream; C: Cardinal;
begin
  M := TMemoryStream.Create;
  try
    C := Ord(ACode); M.WriteBuffer(C, SizeOf(C));
    PutText(M, UTF8String(AStage)); PutText(M, UTF8String(AText));
    PutRaw(M, AData);
    H := ARequest; H.Magic := BRIDGE_MAGIC; H.Version := BRIDGE_VERSION;
    H.PayloadSize := M.Size;
    AStream.WriteBuffer(H, SizeOf(H));
    if M.Size <> 0 then begin M.Position := 0; AStream.CopyFrom(M, M.Size) end;
  finally M.Free end;
end;

end.
