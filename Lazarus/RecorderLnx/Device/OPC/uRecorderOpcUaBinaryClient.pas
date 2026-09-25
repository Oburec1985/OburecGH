unit uRecorderOpcUaBinaryClient;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, ssockets;

type
  TRecorderOpcUaDiscoveredNode = class
  public
    NodeId: string;
    DisplayName: string;
    BrowsePath: string;
    TypeDefinition: string;
    DataTypeNodeId: string;
    DataTypeName: string;
    ValueText: string;
    ValueRank: LongInt;
    Historizing: Boolean;
    NodeClass: Cardinal;
    AccessLevel: Byte;
    UserAccessLevel: Byte;
    function CanRead: Boolean;
    function CanWrite: Boolean;
    function CanHistoryRead: Boolean;
    function CanHistoryWrite: Boolean;
    function IsProperty: Boolean;
  end;

  TRecorderOpcUaBinaryClient = class
  private
    fEndpoint: string;
    fErrorText: string;
    fHost: string;
    fPort: Word;
    fStream: TSocketStream;
    fSecureChannelId: Cardinal;
    fSecurityTokenId: Cardinal;
    fSequenceNumber: Cardinal;
    fRequestId: Cardinal;
    fRequestHandle: Cardinal;
    fAuthenticationToken: TBytes;
    fAnonymousPolicyId: string;
    fUserPolicyId: string;
    fUserName: string;
    fPassword: string;
    fSessionTimeoutMs: Cardinal;
    fRevisedSessionTimeoutMs: Double;
    function ActivateSession: Boolean;
    function BrowseNode(const ANodeId, APath: string; ANodes: TObjectList;
      AVisited: TStrings; ADepth: Integer): Boolean;
    function CreateSession: Boolean;
    procedure CloseSession;
    procedure CloseSecureChannel;
    function ExchangeService(ATypeId: Word; ABody: TMemoryStream;
      out AResponse: TMemoryStream): Boolean;
    function Hello: Boolean;
    function OpenSecureChannel: Boolean;
    function ParseEndpoint: Boolean;
    function ReadVariableAttributes(
      ANode: TRecorderOpcUaDiscoveredNode): Boolean;
    function ReadPropertyValue(ANode: TRecorderOpcUaDiscoveredNode): Boolean;
    function SendMessage(AStream: TMemoryStream;
      const AStage: string): Boolean;
    procedure SetError(const AStage, AText: string);
  public
    constructor Create(const AEndpoint, AUserName, APassword: string;
      ASessionTimeoutMs: Cardinal);
    destructor Destroy; override;
    function Connect: Boolean;
    procedure Disconnect;
    function Browse(ANodes: TObjectList): Boolean;
    function ReadDouble(const ANodeId: string; out AValue: Double;
      out AStatus: Cardinal; out ATimestampSec: Double): Boolean;
    property ErrorText: string read fErrorText;
  end;

implementation

uses
  Math, DateUtils, uRecorderNetworkBinding;

const
  COpcUaMaxMessageSize = 16 * 1024 * 1024;
  COpcUaTimeoutMs = 4000;
  COpcUaSecurityPolicyNone =
    'http://opcfoundation.org/UA/SecurityPolicy#None';
  COpcUaObjectsFolder = 'i=85';
  COpcUaHierarchicalReferences = 'i=33';
  COpcUaNodeClassObject = 1;
  COpcUaNodeClassVariable = 2;
  COpcUaOpenSecureChannelRequest = 446;
  COpcUaCreateSessionRequest = 461;
  COpcUaActivateSessionRequest = 467;
  COpcUaCloseSessionRequest = 473;
  COpcUaCloseSecureChannelRequest = 452;
  COpcUaBrowseRequest = 527;
  COpcUaReadRequest = 631;
  COpcUaAnonymousIdentityToken = 321;
  COpcUaUserNameIdentityToken = 324;
  COpcUaUnixEpochOffsetSeconds = 11644473600;
  COpcUaTicksPerSecond = 10000000;

type
  EOpcUaBinaryError = class(Exception);

  TOpcUaWriter = class
  private
    fStream: TStream;
  public
    constructor Create(AStream: TStream);
    procedure ByteValue(AValue: Byte);
    procedure BooleanValue(AValue: Boolean);
    procedure UInt16(AValue: Word);
    procedure UInt32(AValue: Cardinal);
    procedure Int32(AValue: LongInt);
    procedure UInt64(AValue: QWord);
    procedure DoubleValue(AValue: Double);
    procedure Raw(const AValue; ACount: Integer);
    procedure UaString(const AValue: string; ANull: Boolean = False);
    procedure ByteString(const AValue: TBytes; ANull: Boolean = False);
    procedure NodeId(const AValue: string);
    procedure EncodedNodeId(AEncodingId: Word);
    procedure ExtensionObjectNull;
    procedure RequestHeader(const AAuthenticationToken: TBytes;
      ARequestHandle: Cardinal);
  end;

  TOpcUaReader = class
  private
    fStream: TStream;
    procedure Need(ACount: Int64);
  public
    constructor Create(AStream: TStream);
    function ByteValue: Byte;
    function BooleanValue: Boolean;
    function UInt16: Word;
    function UInt32: Cardinal;
    function Int32: LongInt;
    function UInt64: QWord;
    function SingleValue: Single;
    function DoubleValue: Double;
    function Raw(ACount: Integer): TBytes;
    function UaString: string;
    function ByteString: TBytes;
    function NodeId(out AEncoded: TBytes): string;
    function ExpandedNodeId: string;
    procedure SkipDiagnosticInfo;
    procedure SkipExtensionObject;
    function ResponseHeader: Cardinal;
    procedure SkipApplicationDescription;
  end;

function TRecorderOpcUaDiscoveredNode.CanRead: Boolean;
begin
  Result := (AccessLevel and UserAccessLevel and $01) <> 0;
end;

function TRecorderOpcUaDiscoveredNode.CanWrite: Boolean;
begin
  Result := (AccessLevel and UserAccessLevel and $02) <> 0;
end;

function TRecorderOpcUaDiscoveredNode.CanHistoryRead: Boolean;
begin
  Result := (AccessLevel and UserAccessLevel and $04) <> 0;
end;

function TRecorderOpcUaDiscoveredNode.CanHistoryWrite: Boolean;
begin
  Result := (AccessLevel and UserAccessLevel and $08) <> 0;
end;

function TRecorderOpcUaDiscoveredNode.IsProperty: Boolean;
begin
  Result := SameText(TypeDefinition, 'i=68') or
    SameText(TypeDefinition, 'ns=0;i=68');
end;

function BytesOfUtf8(const AValue: string): TBytes;
var
  lText: RawByteString;
begin
  lText := UTF8Encode(AValue);
  SetLength(Result, Length(lText));
  if Length(lText) > 0 then Move(lText[1], Result[0], Length(lText));
end;

function OpcUaNow: QWord;
var
  lUnixSeconds: Int64;
begin
  { OPC UA DateTime is the number of 100 ns intervals since 1601-01-01 UTC. }
  lUnixSeconds := DateTimeToUnix(Now, False);
  Result := QWord(lUnixSeconds + COpcUaUnixEpochOffsetSeconds) *
    COpcUaTicksPerSecond;
end;

constructor TOpcUaWriter.Create(AStream: TStream);
begin
  inherited Create;
  fStream := AStream;
end;

procedure TOpcUaWriter.Raw(const AValue; ACount: Integer);
begin
  if (ACount > 0) and (fStream.Write(AValue, ACount) <> ACount) then
    raise EOpcUaBinaryError.Create('OPC UA stream write failed');
end;

procedure TOpcUaWriter.ByteValue(AValue: Byte);
begin Raw(AValue, 1); end;

procedure TOpcUaWriter.BooleanValue(AValue: Boolean);
begin ByteValue(Ord(AValue)); end;

procedure TOpcUaWriter.UInt16(AValue: Word);
var B: array[0..1] of Byte;
begin
  B[0] := Byte(AValue); B[1] := Byte(AValue shr 8); Raw(B, 2);
end;

procedure TOpcUaWriter.UInt32(AValue: Cardinal);
var B: array[0..3] of Byte;
begin
  B[0] := Byte(AValue); B[1] := Byte(AValue shr 8);
  B[2] := Byte(AValue shr 16); B[3] := Byte(AValue shr 24); Raw(B, 4);
end;

procedure TOpcUaWriter.Int32(AValue: LongInt);
begin UInt32(Cardinal(AValue)); end;

procedure TOpcUaWriter.UInt64(AValue: QWord);
var B: array[0..7] of Byte; I: Integer;
begin
  for I := 0 to 7 do B[I] := Byte(AValue shr (I * 8)); Raw(B, 8);
end;

procedure TOpcUaWriter.DoubleValue(AValue: Double);
var B: QWord;
begin Move(AValue, B, 8); UInt64(B); end;

procedure TOpcUaWriter.UaString(const AValue: string; ANull: Boolean);
var B: TBytes;
begin
  if ANull then begin Int32(-1); Exit; end;
  B := BytesOfUtf8(AValue); Int32(Length(B));
  if Length(B) > 0 then Raw(B[0], Length(B));
end;

procedure TOpcUaWriter.ByteString(const AValue: TBytes; ANull: Boolean);
begin
  if ANull then begin Int32(-1); Exit; end;
  Int32(Length(AValue));
  if Length(AValue) > 0 then Raw(AValue[0], Length(AValue));
end;

procedure TOpcUaWriter.NodeId(const AValue: string);
var
  lId, lNamespace, P, S: Integer;
  lIdentifier, lText: string;
begin
  lText := Trim(AValue);
  lNamespace := 0;
  if Pos('ns=', LowerCase(lText)) = 1 then
  begin
    P := Pos(';', lText);
    if P = 0 then raise EOpcUaBinaryError.Create('Invalid NodeId: ' + AValue);
    lNamespace := StrToIntDef(Copy(lText, 4, P - 4), -1);
    lText := Copy(lText, P + 1, MaxInt);
  end;
  if Pos('i=', LowerCase(lText)) = 1 then
  begin
    lId := StrToIntDef(Copy(lText, 3, MaxInt), -1);
    if (lNamespace < 0) or (lNamespace > High(Word)) or (lId < 0) then
      raise EOpcUaBinaryError.Create('Invalid numeric NodeId: ' + AValue);
    if (lNamespace = 0) and (lId <= High(Byte)) then
    begin
      ByteValue(0); ByteValue(Byte(lId));
    end
    else if (lNamespace <= High(Byte)) and (lId <= High(Word)) then
    begin
      ByteValue(1); ByteValue(Byte(lNamespace)); UInt16(Word(lId));
    end
    else
    begin
      ByteValue(2); UInt16(Word(lNamespace)); UInt32(Cardinal(lId));
    end;
    Exit;
  end;
  if Pos('s=', LowerCase(lText)) = 1 then
  begin
    lIdentifier := Copy(lText, 3, MaxInt);
    ByteValue(3); UInt16(Word(lNamespace)); UaString(lIdentifier);
    Exit;
  end;
  S := 0;
  raise EOpcUaBinaryError.Create('Unsupported NodeId: ' + AValue + IntToStr(S));
end;

procedure TOpcUaWriter.EncodedNodeId(AEncodingId: Word);
begin
  ByteValue(1); ByteValue(0); UInt16(AEncodingId);
end;

procedure TOpcUaWriter.ExtensionObjectNull;
begin
  { Null ExtensionObject = null TwoByte NodeId (encoding + identifier),
    followed by the ExtensionObject encoding byte 0 (no body). }
  ByteValue(0); ByteValue(0); ByteValue(0);
end;

procedure TOpcUaWriter.RequestHeader(const AAuthenticationToken: TBytes;
  ARequestHandle: Cardinal);
begin
  if Length(AAuthenticationToken) = 0 then begin ByteValue(0); ByteValue(0); end
  else Raw(AAuthenticationToken[0], Length(AAuthenticationToken));
  UInt64(OpcUaNow);
  UInt32(ARequestHandle);
  UInt32(0);
  UaString('', True);
  UInt32(COpcUaTimeoutMs);
  ExtensionObjectNull;
end;

constructor TOpcUaReader.Create(AStream: TStream);
begin inherited Create; fStream := AStream; end;

procedure TOpcUaReader.Need(ACount: Int64);
begin
  if (ACount < 0) or (fStream.Position + ACount > fStream.Size) then
    raise EOpcUaBinaryError.Create('Truncated OPC UA message');
end;

function TOpcUaReader.Raw(ACount: Integer): TBytes;
begin
  Need(ACount); SetLength(Result, ACount);
  if ACount > 0 then fStream.ReadBuffer(Result[0], ACount);
end;

function TOpcUaReader.ByteValue: Byte;
begin Need(1); fStream.ReadBuffer(Result, 1); end;

function TOpcUaReader.BooleanValue: Boolean;
begin Result := ByteValue <> 0; end;

function TOpcUaReader.UInt16: Word;
var B: TBytes;
begin B := Raw(2); Result := Word(B[0]) or (Word(B[1]) shl 8); end;

function TOpcUaReader.UInt32: Cardinal;
var B: TBytes;
begin
  B := Raw(4); Result := Cardinal(B[0]) or (Cardinal(B[1]) shl 8) or
    (Cardinal(B[2]) shl 16) or (Cardinal(B[3]) shl 24);
end;

function TOpcUaReader.Int32: LongInt;
begin Result := LongInt(UInt32); end;

function TOpcUaReader.UInt64: QWord;
var B: TBytes; I: Integer;
begin
  B := Raw(8); Result := 0;
  for I := 0 to 7 do Result := Result or (QWord(B[I]) shl (I * 8));
end;

function TOpcUaReader.DoubleValue: Double;
var B: QWord;
begin B := UInt64; Move(B, Result, 8); end;

function TOpcUaReader.SingleValue: Single;
var B: Cardinal;
begin B := UInt32; Move(B, Result, SizeOf(Result)); end;

function TOpcUaReader.UaString: string;
var L: LongInt; B: TBytes; S: RawByteString;
begin
  L := Int32; if L < 0 then Exit('');
  if L > COpcUaMaxMessageSize then raise EOpcUaBinaryError.Create('OPC UA string too large');
  B := Raw(L); SetLength(S, L); if L > 0 then Move(B[0], S[1], L);
  Result := UTF8Decode(S);
end;

function TOpcUaReader.ByteString: TBytes;
var L: LongInt;
begin
  L := Int32; if L < 0 then Exit(nil);
  if L > COpcUaMaxMessageSize then raise EOpcUaBinaryError.Create('OPC UA bytestring too large');
  Result := Raw(L);
end;

function TOpcUaReader.NodeId(out AEncoded: TBytes): string;
var
  lEncoding, lNs: Byte;
  lStart: Int64;
  lId: Cardinal;
  lNs16: Word;
  lText: string;
begin
  lStart := fStream.Position;
  lEncoding := ByteValue and $3F;
  case lEncoding of
    0: begin lNs16 := 0; lId := ByteValue; Result := 'i=' + IntToStr(lId); end;
    1: begin lNs := ByteValue; lId := UInt16; lNs16 := lNs;
         Result := Format('ns=%d;i=%d', [lNs16, lId]); end;
    2: begin lNs16 := UInt16; lId := UInt32;
         Result := Format('ns=%d;i=%d', [lNs16, lId]); end;
    3: begin lNs16 := UInt16; lText := UaString;
         Result := Format('ns=%d;s=%s', [lNs16, lText]); end;
  else
    raise EOpcUaBinaryError.CreateFmt('Unsupported NodeId encoding %d', [lEncoding]);
  end;
  { Preserve the exact binary NodeId for the authentication token. }
  fStream.Position := lStart;
  lEncoding := ByteValue and $3F;
  case lEncoding of
    0: ByteValue;
    1: begin ByteValue; UInt16; end;
    2: begin UInt16; UInt32; end;
    3: begin UInt16; UaString; end;
  end;
  SetLength(AEncoded, fStream.Position - lStart);
  fStream.Position := lStart;
  if Length(AEncoded) > 0 then fStream.ReadBuffer(AEncoded[0], Length(AEncoded));
end;

function TOpcUaReader.ExpandedNodeId: string;
var E: Byte; Dummy: TBytes;
begin
  E := ByteValue;
  fStream.Position := fStream.Position - 1;
  Result := NodeId(Dummy);
  if (E and $80) <> 0 then UaString;
  if (E and $40) <> 0 then UInt32;
end;

procedure TOpcUaReader.SkipDiagnosticInfo;
var M: Byte; I, N: LongInt;
begin
  M := ByteValue;
  if (M and $01) <> 0 then Int32;
  if (M and $02) <> 0 then Int32;
  if (M and $04) <> 0 then Int32;
  if (M and $08) <> 0 then Int32;
  if (M and $10) <> 0 then UaString;
  if (M and $20) <> 0 then UInt32;
  if (M and $40) <> 0 then SkipDiagnosticInfo;
  N := 0; I := N;
end;

procedure TOpcUaReader.SkipExtensionObject;
var Dummy: TBytes; E: Byte; L: LongInt;
begin
  NodeId(Dummy); E := ByteValue;
  if E = 0 then Exit;
  L := Int32; if L < 0 then Exit; Need(L); fStream.Position := fStream.Position + L;
end;

function TOpcUaReader.ResponseHeader: Cardinal;
var I, N: LongInt;
begin
  UInt64; UInt32; Result := UInt32; SkipDiagnosticInfo;
  N := Int32;
  if N > 0 then for I := 0 to N - 1 do UaString;
  SkipExtensionObject;
end;

procedure TOpcUaReader.SkipApplicationDescription;
var I, N: LongInt; M: Byte;
begin
  UaString; UaString;
  M := ByteValue;
  if (M and 1) <> 0 then UaString;
  if (M and 2) <> 0 then UaString;
  Int32; UaString; UaString;
  N := Int32; if N > 0 then for I := 0 to N - 1 do UaString;
end;

constructor TRecorderOpcUaBinaryClient.Create(const AEndpoint, AUserName,
  APassword: string; ASessionTimeoutMs: Cardinal);
begin
  inherited Create;
  fEndpoint := Trim(AEndpoint);
  fUserName := AUserName;
  fPassword := APassword;
  fSessionTimeoutMs := ASessionTimeoutMs;
  if fSessionTimeoutMs < 1000 then fSessionTimeoutMs := 1000;
  fAnonymousPolicyId := 'anonymous';
  fUserPolicyId := 'username';
end;

destructor TRecorderOpcUaBinaryClient.Destroy;
begin Disconnect; inherited Destroy; end;

procedure TRecorderOpcUaBinaryClient.SetError(const AStage, AText: string);
begin fErrorText := AStage + ': ' + AText; end;

function TRecorderOpcUaBinaryClient.SendMessage(AStream: TMemoryStream;
  const AStage: string): Boolean;
var
  lOffset: Integer;
  lWritten: Integer;
begin
  Result := False;
  if fStream = nil then
  begin
    SetError(AStage, 'connection is not open');
    Exit;
  end;
  lOffset := 0;
  try
    while lOffset < AStream.Size do
    begin
      lWritten := fStream.Write((PByte(AStream.Memory) + lOffset)^,
        AStream.Size - lOffset);
      if lWritten <= 0 then
      begin
        SetError(AStage, 'connection closed while sending');
        Exit;
      end;
      Inc(lOffset, lWritten);
    end;
    Result := True;
  except
    on E: Exception do
      SetError(AStage, E.Message);
  end;
end;

function TRecorderOpcUaBinaryClient.ParseEndpoint: Boolean;
var P, S: Integer; T: string;
begin
  Result := False; T := fEndpoint;
  if Pos('opc.tcp://', LowerCase(T)) <> 1 then begin SetError('endpoint', 'ожидается opc.tcp://'); Exit; end;
  Delete(T, 1, Length('opc.tcp://'));
  S := Pos('/', T); if S > 0 then T := Copy(T, 1, S - 1);
  P := LastDelimiter(':', T);
  if P > 0 then begin fHost := Copy(T, 1, P - 1); fPort := Word(StrToIntDef(Copy(T, P + 1, MaxInt), 0)); end
  else begin fHost := T; fPort := 4840; end;
  Result := (fHost <> '') and (fPort <> 0);
  if not Result then SetError('endpoint', 'некорректный адрес');
end;

procedure WriteMessageHeader(AStream: TMemoryStream; const AType: RawByteString);
var W: TOpcUaWriter;
begin
  W := TOpcUaWriter.Create(AStream);
  try W.Raw(AType[1], 4); W.UInt32(0); finally W.Free; end;
end;

procedure FinishMessage(AStream: TMemoryStream);
var W: TOpcUaWriter; P: Int64;
begin
  P := AStream.Position; AStream.Position := 4; W := TOpcUaWriter.Create(AStream);
  try W.UInt32(AStream.Size); finally W.Free; end; AStream.Position := P;
end;

function ReadExact(AStream: TStream; var ABuffer; ACount: Integer): Boolean;
var N, P: Integer;
begin
  P := 0;
  while P < ACount do begin N := AStream.Read((PByte(@ABuffer) + P)^, ACount - P); if N <= 0 then Exit(False); Inc(P, N); end;
  Result := True;
end;

function ReceiveUaMessage(AStream: TStream; const AExpected: RawByteString;
  out APayload: TMemoryStream; out AError: string): Boolean;
var
  H: array[0..7] of Byte;
  L, lStatus: Cardinal;
  T: RawByteString;
  lReader: TOpcUaReader;
  lReason: string;
begin
  Result := False; APayload := nil; AError := '';
  if not ReadExact(AStream, H, 8) then begin AError := 'connection closed'; Exit; end;
  SetLength(T, 4); Move(H[0], T[1], 4);
  L := Cardinal(H[4]) or (Cardinal(H[5]) shl 8) or (Cardinal(H[6]) shl 16) or (Cardinal(H[7]) shl 24);
  if (L < 8) or (L > COpcUaMaxMessageSize) then begin AError := 'invalid message size'; Exit; end;
  APayload := TMemoryStream.Create; APayload.Size := L - 8;
  if (L > 8) and not ReadExact(AStream, APayload.Memory^, L - 8) then begin FreeAndNil(APayload); AError := 'truncated message'; Exit; end;
  APayload.Position := 0;
  if Copy(T, 1, 3) = 'ERR' then
  begin
    try
      lReader := TOpcUaReader.Create(APayload);
      try
        lStatus := lReader.UInt32;
        lReason := lReader.UaString;
      finally
        lReader.Free;
      end;
      AError := Format('UA-TCP ERR 0x%.8x: %s', [lStatus, lReason]);
    except
      on E: Exception do
        AError := 'UA-TCP ERR (decode failed: ' + E.Message + ')';
    end;
    FreeAndNil(APayload);
    Exit;
  end;
  if Copy(T, 1, 3) <> AExpected then
  begin
    AError := 'unexpected message ' + string(T);
    FreeAndNil(APayload);
    Exit;
  end;
  Result := True;
end;

function TRecorderOpcUaBinaryClient.Hello: Boolean;
var M, R: TMemoryStream; W: TOpcUaWriter; E: string;
begin
  Result := False; M := TMemoryStream.Create;
  try
    WriteMessageHeader(M, 'HELF'); W := TOpcUaWriter.Create(M);
    try W.UInt32(0); W.UInt32(65535); W.UInt32(65535); W.UInt32(COpcUaMaxMessageSize); W.UInt32(0); W.UaString(fEndpoint); finally W.Free; end;
    FinishMessage(M);
    if not SendMessage(M, 'HEL') then Exit;
    if not ReceiveUaMessage(fStream, 'ACK', R, E) then begin SetError('HEL/ACK', E); Exit; end;
    R.Free; Result := True;
  finally M.Free; end;
end;

function TRecorderOpcUaBinaryClient.OpenSecureChannel: Boolean;
var M, R: TMemoryStream; W: TOpcUaWriter; Q: TOpcUaReader; E: string; D: TBytes; Status: Cardinal;
begin
  Result := False; M := TMemoryStream.Create;
  try
    WriteMessageHeader(M, 'OPNF'); W := TOpcUaWriter.Create(M);
    try
      W.UInt32(0); W.UaString(COpcUaSecurityPolicyNone); W.ByteString(nil, True); W.ByteString(nil, True);
      Inc(fSequenceNumber); Inc(fRequestId); W.UInt32(fSequenceNumber); W.UInt32(fRequestId);
      W.EncodedNodeId(COpcUaOpenSecureChannelRequest); Inc(fRequestHandle); W.RequestHeader(nil, fRequestHandle);
      W.UInt32(0); W.UInt32(0); W.UInt32(1); W.ByteString(nil, True); W.UInt32(600000);
    finally W.Free; end;
    FinishMessage(M);
    if not SendMessage(M, 'OpenSecureChannel') then Exit;
    if not ReceiveUaMessage(fStream, 'OPN', R, E) then begin SetError('OpenSecureChannel', E); Exit; end;
    try
      Q := TOpcUaReader.Create(R);
      try
        fSecureChannelId := Q.UInt32; Q.UaString; Q.ByteString; Q.ByteString; Q.UInt32; Q.UInt32; Q.NodeId(D);
        Status := Q.ResponseHeader; if Status <> 0 then begin SetError('OpenSecureChannel', 'status 0x' + IntToHex(Status, 8)); Exit; end;
        Q.UInt32; fSecureChannelId := Q.UInt32; fSecurityTokenId := Q.UInt32; Q.UInt64; Q.UInt32; Q.ByteString;
      finally Q.Free; end;
    finally R.Free; end;
    Result := True;
  finally M.Free; end;
end;

function TRecorderOpcUaBinaryClient.ExchangeService(ATypeId: Word;
  ABody: TMemoryStream; out AResponse: TMemoryStream): Boolean;
var M: TMemoryStream; W: TOpcUaWriter; E: string; D: TBytes; Q: TOpcUaReader; Status: Cardinal;
begin
  Result := False; AResponse := nil; M := TMemoryStream.Create;
  try
    try
      WriteMessageHeader(M, 'MSGF'); W := TOpcUaWriter.Create(M);
      try
        W.UInt32(fSecureChannelId); W.UInt32(fSecurityTokenId); Inc(fSequenceNumber); Inc(fRequestId);
        W.UInt32(fSequenceNumber); W.UInt32(fRequestId); W.EncodedNodeId(ATypeId);
        if ABody <> nil then begin ABody.Position := 0; M.CopyFrom(ABody, ABody.Size); end;
      finally W.Free; end;
      FinishMessage(M);
      if not SendMessage(M, 'service send') then Exit;
      if not ReceiveUaMessage(fStream, 'MSG', AResponse, E) then begin SetError('service', E); Exit; end;
      Q := TOpcUaReader.Create(AResponse);
      try
        Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D); Status := Q.ResponseHeader;
        if Status <> 0 then begin SetError('service', 'status 0x' + IntToHex(Status, 8)); FreeAndNil(AResponse); Exit; end;
      finally Q.Free; end;
      AResponse.Position := 0;
      Result := True;
    except
      FreeAndNil(AResponse);
      raise;
    end;
  finally M.Free; end;
end;

procedure WriteApplicationDescription(W: TOpcUaWriter);
begin
  W.UaString('urn:mera:RecorderLnx'); W.UaString('urn:mera:RecorderLnx');
  W.ByteValue(2); W.UaString('RecorderLnx'); W.Int32(1); W.UaString('', True); W.UaString('', True); W.Int32(0);
end;

function TRecorderOpcUaBinaryClient.CreateSession: Boolean;
var B, R: TMemoryStream; W: TOpcUaWriter; Q: TOpcUaReader; D: TBytes; I, J, N, Tokens: LongInt; Mode, TokenType: Cardinal; S: string;
begin
  Result := False; B := TMemoryStream.Create;
  try
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle); W.RequestHeader(nil, fRequestHandle); WriteApplicationDescription(W);
      W.UaString('', True); W.UaString(fEndpoint); W.UaString('RecorderLnx'); W.ByteString(nil, True); W.ByteString(nil, True);
      W.DoubleValue(fSessionTimeoutMs); W.UInt32(COpcUaMaxMessageSize);
    finally W.Free; end;
    if not ExchangeService(COpcUaCreateSessionRequest, B, R) then Exit;
    try
      Q := TOpcUaReader.Create(R);
      try
        Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D); Q.ResponseHeader;
        Q.NodeId(D); Q.NodeId(fAuthenticationToken);
        fRevisedSessionTimeoutMs := Q.DoubleValue;
        Q.ByteString; Q.ByteString;
        N := Q.Int32;
        for I := 0 to N - 1 do
        begin
          Q.UaString; Q.SkipApplicationDescription; Q.ByteString; Mode := Q.UInt32; Q.UaString;
          Tokens := Q.Int32;
          for J := 0 to Tokens - 1 do
          begin
            S := Q.UaString; TokenType := Q.UInt32; Q.UaString; Q.UaString; Q.UaString;
            if (TokenType = 0) and (S <> '') then fAnonymousPolicyId := S;
            if (TokenType = 1) and (S <> '') then fUserPolicyId := S;
          end;
          Q.UaString; Q.ByteValue;
          if Mode = High(Cardinal) then Break;
        end;
      finally Q.Free; end;
    finally R.Free; end;
    Result := True;
  finally B.Free; end;
end;

function TRecorderOpcUaBinaryClient.ActivateSession: Boolean;
var B, R, Token: TMemoryStream; W, TW: TOpcUaWriter; TokenBytes, PasswordBytes: TBytes;
begin
  Result := False; B := TMemoryStream.Create; Token := TMemoryStream.Create;
  try
    TW := TOpcUaWriter.Create(Token);
    try
      if fUserName = '' then TW.UaString(fAnonymousPolicyId)
      else begin TW.UaString(fUserPolicyId); TW.UaString(fUserName); PasswordBytes := BytesOfUtf8(fPassword); TW.ByteString(PasswordBytes); TW.UaString('', True); end;
    finally TW.Free; end;
    SetLength(TokenBytes, Token.Size); if Token.Size > 0 then Move(Token.Memory^, TokenBytes[0], Token.Size);
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle); W.RequestHeader(fAuthenticationToken, fRequestHandle);
      W.UaString('', True); W.ByteString(nil, True); W.Int32(0); W.Int32(0);
      if fUserName = '' then W.EncodedNodeId(COpcUaAnonymousIdentityToken)
      else W.EncodedNodeId(COpcUaUserNameIdentityToken);
      W.ByteValue(1); W.Int32(Length(TokenBytes)); if Length(TokenBytes) > 0 then W.Raw(TokenBytes[0], Length(TokenBytes));
      W.UaString('', True); W.ByteString(nil, True);
    finally W.Free; end;
    Result := ExchangeService(COpcUaActivateSessionRequest, B, R);
    R.Free;
  finally Token.Free; B.Free; end;
end;

procedure TRecorderOpcUaBinaryClient.CloseSession;
var
  B, R: TMemoryStream;
  W: TOpcUaWriter;
begin
  if (fStream = nil) or (Length(fAuthenticationToken) = 0) then Exit;
  B := TMemoryStream.Create;
  try
    try
      W := TOpcUaWriter.Create(B);
      try
        Inc(fRequestHandle);
        W.RequestHeader(fAuthenticationToken, fRequestHandle);
        W.BooleanValue(True);
      finally
        W.Free;
      end;
      if ExchangeService(COpcUaCloseSessionRequest, B, R) then R.Free;
    except
      { Disconnect is best-effort. The transport is always released below. }
    end;
  finally
    B.Free;
  end;
end;

procedure TRecorderOpcUaBinaryClient.CloseSecureChannel;
var
  M: TMemoryStream;
  W: TOpcUaWriter;
begin
  if (fStream = nil) or (fSecureChannelId = 0) then Exit;
  M := TMemoryStream.Create;
  try
    WriteMessageHeader(M, 'CLOF');
    W := TOpcUaWriter.Create(M);
    try
      W.UInt32(fSecureChannelId);
      W.UInt32(fSecurityTokenId);
      Inc(fSequenceNumber);
      Inc(fRequestId);
      W.UInt32(fSequenceNumber);
      W.UInt32(fRequestId);
      W.EncodedNodeId(COpcUaCloseSecureChannelRequest);
      Inc(fRequestHandle);
      W.RequestHeader(nil, fRequestHandle);
    finally
      W.Free;
    end;
    FinishMessage(M);
    SendMessage(M, 'CloseSecureChannel');
  except
    { Closing the socket remains the final cleanup if CLO cannot be sent. }
  end;
  M.Free;
end;

function TRecorderOpcUaBinaryClient.Connect: Boolean;
var E: string;
begin
  Result := False; Disconnect; fErrorText := '';
  try
    if not ParseEndpoint then Exit;
    if not RecorderOpenBoundTcpStream(fHost, fPort, COpcUaTimeoutMs, fStream, E) then begin SetError('TCP', E); Exit; end;
    if not Hello or not OpenSecureChannel or not CreateSession or not ActivateSession then begin Disconnect; Exit; end;
    Result := True;
  except on X: Exception do begin SetError('protocol', X.Message); Disconnect; end; end;
end;

procedure TRecorderOpcUaBinaryClient.Disconnect;
begin
  if fStream <> nil then
  begin
    CloseSession;
    CloseSecureChannel;
  end;
  FreeAndNil(fStream);
  fSecureChannelId := 0;
  fSecurityTokenId := 0;
  SetLength(fAuthenticationToken, 0);
end;

function TRecorderOpcUaBinaryClient.BrowseNode(const ANodeId, APath: string;
  ANodes: TObjectList; AVisited: TStrings; ADepth: Integer): Boolean;
var B, R: TMemoryStream; W: TOpcUaWriter; Q: TOpcUaReader; D: TBytes; I, J, N, Count: LongInt; NodeClass, Status: Cardinal; NodeId, DisplayName, TypeDefinition, NodePath: string; LocalizedMask: Byte; Item: TRecorderOpcUaDiscoveredNode;
begin
  Result := False;
  if ADepth > 16 then Exit(True);
  if AVisited.IndexOf(ANodeId) >= 0 then Exit(True);
  AVisited.Add(ANodeId);
  B := TMemoryStream.Create;
  try
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle); W.RequestHeader(fAuthenticationToken, fRequestHandle);
      W.NodeId('i=0'); W.UInt64(0); W.UInt32(0); W.UInt32(0); W.Int32(1);
      W.NodeId(ANodeId); W.UInt32(0); W.NodeId(COpcUaHierarchicalReferences); W.BooleanValue(True);
      W.UInt32(COpcUaNodeClassObject or COpcUaNodeClassVariable); W.UInt32(63);
    finally W.Free; end;
    if not ExchangeService(COpcUaBrowseRequest, B, R) then Exit;
    try
      Q := TOpcUaReader.Create(R);
      try
        Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D); Q.ResponseHeader;
        N := Q.Int32;
        for I := 0 to N - 1 do
        begin
          Status := Q.UInt32; Q.ByteString; Count := Q.Int32;
          if Status <> 0 then begin SetError('browse', 'status 0x' + IntToHex(Status, 8)); Exit; end;
          for J := 0 to Count - 1 do
          begin
            Q.NodeId(D); Q.BooleanValue; NodeId := Q.ExpandedNodeId; Q.UInt16; Q.UaString;
            LocalizedMask := Q.ByteValue;
            if (LocalizedMask and 1) <> 0 then Q.UaString;
            if (LocalizedMask and 2) <> 0 then DisplayName := Q.UaString
            else DisplayName := '';
            NodeClass := Q.UInt32; TypeDefinition := Q.ExpandedNodeId;
            if APath = '' then NodePath := DisplayName
            else NodePath := APath + '/' + DisplayName;
            if NodeClass = COpcUaNodeClassVariable then
            begin
              Item := TRecorderOpcUaDiscoveredNode.Create;
              Item.NodeId := NodeId;
              Item.DisplayName := DisplayName;
              Item.BrowsePath := NodePath;
              Item.TypeDefinition := TypeDefinition;
              Item.NodeClass := NodeClass;
              Item.ValueRank := -1;
              if not ReadVariableAttributes(Item) then
              begin
                Item.Free;
                Exit;
              end;
              if Item.IsProperty and not ReadPropertyValue(Item) then
                Item.ValueText := '<ошибка чтения>';
              ANodes.Add(Item);
              if not Item.IsProperty then
                if not BrowseNode(NodeId, NodePath, ANodes, AVisited,
                  ADepth + 1) then Exit;
            end
            else if NodeClass = COpcUaNodeClassObject then
              if not BrowseNode(NodeId, NodePath, ANodes, AVisited,
                ADepth + 1) then Exit;
          end;
        end;
      finally Q.Free; end;
    finally R.Free; end;
    Result := True;
  finally B.Free; end;
end;

function TRecorderOpcUaBinaryClient.Browse(ANodes: TObjectList): Boolean;
var
  lVisited: TStringList;
begin
  Result := False; if ANodes = nil then Exit; ANodes.Clear;
  lVisited := TStringList.Create;
  try
    lVisited.CaseSensitive := True;
    lVisited.Sorted := True;
    lVisited.Duplicates := dupIgnore;
    try
      Result := BrowseNode(COpcUaObjectsFolder, 'Objects', ANodes,
        lVisited, 0);
    except
      on E: Exception do SetError('browse', E.Message);
    end;
  finally
    lVisited.Free;
  end;
end;

function ReadDataValueByte(Q: TOpcUaReader; out AValue: Byte): Boolean;
var
  lMask, lVariantMask: Byte;
begin
  Result := False;
  lMask := Q.ByteValue;
  if (lMask and 1) = 0 then Exit;
  lVariantMask := Q.ByteValue;
  if (lVariantMask and $BF) <> 3 then
    raise EOpcUaBinaryError.Create('Expected Byte attribute value');
  AValue := Q.ByteValue;
  if (lMask and 2) <> 0 then Q.UInt32;
  if (lMask and 4) <> 0 then Q.UInt64;
  if (lMask and 8) <> 0 then Q.UInt64;
  if (lMask and 16) <> 0 then Q.UInt16;
  if (lMask and 32) <> 0 then Q.UInt16;
  Result := True;
end;

function ReadDataValueInt32(Q: TOpcUaReader; out AValue: LongInt): Boolean;
var
  lMask, lVariantMask: Byte;
begin
  Result := False;
  lMask := Q.ByteValue;
  if (lMask and 1) = 0 then Exit;
  lVariantMask := Q.ByteValue;
  if (lVariantMask and $BF) <> 6 then
    raise EOpcUaBinaryError.Create('Expected Int32 attribute value');
  AValue := LongInt(Q.UInt32);
  if (lMask and 2) <> 0 then Q.UInt32;
  if (lMask and 4) <> 0 then Q.UInt64;
  if (lMask and 8) <> 0 then Q.UInt64;
  if (lMask and 16) <> 0 then Q.UInt16;
  if (lMask and 32) <> 0 then Q.UInt16;
  Result := True;
end;

function ReadDataValueBoolean(Q: TOpcUaReader;
  out AValue: Boolean): Boolean;
var
  lMask, lVariantMask: Byte;
begin
  Result := False;
  lMask := Q.ByteValue;
  if (lMask and 1) = 0 then Exit;
  lVariantMask := Q.ByteValue;
  if (lVariantMask and $BF) <> 1 then
    raise EOpcUaBinaryError.Create('Expected Boolean attribute value');
  AValue := Q.BooleanValue;
  if (lMask and 2) <> 0 then Q.UInt32;
  if (lMask and 4) <> 0 then Q.UInt64;
  if (lMask and 8) <> 0 then Q.UInt64;
  if (lMask and 16) <> 0 then Q.UInt16;
  if (lMask and 32) <> 0 then Q.UInt16;
  Result := True;
end;

function ReadDataValueDisplayText(Q: TOpcUaReader; out AValue: string): Boolean;
var
  lDataValueMask, lLocalizedMask, lVariantMask, lTypeId: Byte;
begin
  Result := False;
  AValue := '';
  lDataValueMask := Q.ByteValue;
  if (lDataValueMask and 1) = 0 then
  begin
    if (lDataValueMask and 2) <> 0 then
      AValue := 'Status 0x' + IntToHex(Q.UInt32, 8);
    Exit;
  end;
  lVariantMask := Q.ByteValue;
  if (lVariantMask and $80) <> 0 then
  begin
    AValue := '<массив>';
    Result := True;
    Exit;
  end;
  lTypeId := lVariantMask and $3F;
  case lTypeId of
    1: if Q.BooleanValue then AValue := 'True' else AValue := 'False';
    2: AValue := IntToStr(ShortInt(Q.ByteValue));
    3: AValue := IntToStr(Q.ByteValue);
    4: AValue := IntToStr(SmallInt(Q.UInt16));
    5: AValue := IntToStr(Q.UInt16);
    6: AValue := IntToStr(LongInt(Q.UInt32));
    7: AValue := UIntToStr(Q.UInt32);
    8: AValue := IntToStr(Int64(Q.UInt64));
    9: AValue := UIntToStr(Q.UInt64);
    10: AValue := FloatToStr(Q.SingleValue);
    11: AValue := FloatToStr(Q.DoubleValue);
    12, 16: AValue := Q.UaString;
    13: AValue := IntToStr(Int64(Q.UInt64));
    20:
      begin
        Q.UInt16;
        AValue := Q.UaString;
      end;
    21:
      begin
        lLocalizedMask := Q.ByteValue;
        if (lLocalizedMask and 1) <> 0 then Q.UaString;
        if (lLocalizedMask and 2) <> 0 then AValue := Q.UaString;
      end;
  else
    begin
      AValue := '<тип ' + IntToStr(lTypeId) + '>';
      Result := True;
      Exit;
    end;
  end;
  if (lDataValueMask and 2) <> 0 then Q.UInt32;
  if (lDataValueMask and 4) <> 0 then Q.UInt64;
  if (lDataValueMask and 8) <> 0 then Q.UInt64;
  if (lDataValueMask and 16) <> 0 then Q.UInt16;
  if (lDataValueMask and 32) <> 0 then Q.UInt16;
  Result := True;
end;

procedure SkipDataValueMetadata(Q: TOpcUaReader; AMask: Byte);
begin
  if (AMask and 2) <> 0 then Q.UInt32;
  if (AMask and 4) <> 0 then Q.UInt64;
  if (AMask and 8) <> 0 then Q.UInt64;
  if (AMask and 16) <> 0 then Q.UInt16;
  if (AMask and 32) <> 0 then Q.UInt16;
end;

function ReadDataValueNodeId(Q: TOpcUaReader; out AValue: string): Boolean;
var
  lEncoded: TBytes;
  lMask, lVariantMask: Byte;
begin
  Result := False;
  lMask := Q.ByteValue;
  if (lMask and 1) = 0 then Exit;
  lVariantMask := Q.ByteValue;
  if (lVariantMask and $BF) <> 17 then
    raise EOpcUaBinaryError.Create('Expected NodeId attribute value');
  AValue := Q.NodeId(lEncoded);
  SkipDataValueMetadata(Q, lMask);
  Result := True;
end;

function TRecorderOpcUaBinaryClient.ReadPropertyValue(
  ANode: TRecorderOpcUaDiscoveredNode): Boolean;
var
  B, R: TMemoryStream;
  W: TOpcUaWriter;
  Q: TOpcUaReader;
  D: TBytes;
  N: LongInt;
begin
  Result := False;
  B := TMemoryStream.Create;
  try
    try
      W := TOpcUaWriter.Create(B);
      try
        Inc(fRequestHandle);
        W.RequestHeader(fAuthenticationToken, fRequestHandle);
        W.DoubleValue(0);
        W.UInt32(0);
        W.Int32(1);
        W.NodeId(ANode.NodeId); W.UInt32(13); W.UaString('', True);
        W.UInt16(0); W.UaString('', True);
      finally
        W.Free;
      end;
      if not ExchangeService(COpcUaReadRequest, B, R) then Exit;
      try
        Q := TOpcUaReader.Create(R);
        try
          Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D); Q.ResponseHeader;
          N := Q.Int32;
          if N <> 1 then
          begin
            SetError('property value', 'unexpected result count');
            Exit;
          end;
          Result := ReadDataValueDisplayText(Q, ANode.ValueText);
        finally
          Q.Free;
        end;
      finally
        R.Free;
      end;
    except
      on E: Exception do
        SetError('property value', ANode.NodeId + ': ' + E.Message);
    end;
  finally
    B.Free;
  end;
end;

function DataTypeDisplayName(const ANodeId: string): string;
var
  lId: string;
begin
  lId := ANodeId;
  if Pos('ns=0;', lId) = 1 then Delete(lId, 1, Length('ns=0;'));
  case StrToIntDef(Copy(lId, 3, MaxInt), -1) of
    1: Result := 'Boolean';
    2: Result := 'SByte';
    3: Result := 'Byte';
    4: Result := 'Int16';
    5: Result := 'UInt16';
    6: Result := 'Int32';
    7: Result := 'UInt32';
    8: Result := 'Int64';
    9: Result := 'UInt64';
    10: Result := 'Float';
    11: Result := 'Double';
    12: Result := 'String';
    13: Result := 'DateTime';
    14: Result := 'Guid';
    15: Result := 'ByteString';
    16: Result := 'XmlElement';
    17: Result := 'NodeId';
    18: Result := 'ExpandedNodeId';
    19: Result := 'StatusCode';
    20: Result := 'QualifiedName';
    21: Result := 'LocalizedText';
    22: Result := 'Structure';
    23: Result := 'DataValue';
    24: Result := 'BaseDataType';
    25: Result := 'DiagnosticInfo';
    26: Result := 'Number';
    27: Result := 'Integer';
    28: Result := 'UInteger';
    29: Result := 'Enumeration';
  else
    Result := ANodeId;
  end;
end;

function TRecorderOpcUaBinaryClient.ReadVariableAttributes(
  ANode: TRecorderOpcUaDiscoveredNode): Boolean;
var
  B, R: TMemoryStream;
  W: TOpcUaWriter;
  Q: TOpcUaReader;
  D: TBytes;
  N: LongInt;
begin
  Result := False;
  B := TMemoryStream.Create;
  try
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle);
      W.RequestHeader(fAuthenticationToken, fRequestHandle);
      W.DoubleValue(0);
      W.UInt32(0);
      W.Int32(5);
      W.NodeId(ANode.NodeId); W.UInt32(14); W.UaString('', True); W.UInt16(0); W.UaString('', True);
      W.NodeId(ANode.NodeId); W.UInt32(15); W.UaString('', True); W.UInt16(0); W.UaString('', True);
      W.NodeId(ANode.NodeId); W.UInt32(17); W.UaString('', True); W.UInt16(0); W.UaString('', True);
      W.NodeId(ANode.NodeId); W.UInt32(18); W.UaString('', True); W.UInt16(0); W.UaString('', True);
      W.NodeId(ANode.NodeId); W.UInt32(20); W.UaString('', True); W.UInt16(0); W.UaString('', True);
    finally
      W.Free;
    end;
    if not ExchangeService(COpcUaReadRequest, B, R) then Exit;
    try
      Q := TOpcUaReader.Create(R);
      try
        Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D); Q.ResponseHeader;
        N := Q.Int32;
        if N <> 5 then
        begin
          SetError('attributes', 'unexpected variable attribute result count');
          Exit;
        end;
        if not ReadDataValueNodeId(Q, ANode.DataTypeNodeId) then Exit;
        ANode.DataTypeName := DataTypeDisplayName(ANode.DataTypeNodeId);
        if not ReadDataValueInt32(Q, ANode.ValueRank) then Exit;
        if not ReadDataValueByte(Q, ANode.AccessLevel) then Exit;
        if not ReadDataValueByte(Q, ANode.UserAccessLevel) then Exit;
        if not ReadDataValueBoolean(Q, ANode.Historizing) then Exit;
      finally
        Q.Free;
      end;
    finally
      R.Free;
    end;
    Result := True;
  finally
    B.Free;
  end;
end;

function TRecorderOpcUaBinaryClient.ReadDouble(const ANodeId: string;
  out AValue: Double; out AStatus: Cardinal; out ATimestampSec: Double): Boolean;
var B, R: TMemoryStream; W: TOpcUaWriter; Q: TOpcUaReader; D: TBytes; Mask, VariantMask, TypeId: Byte; N: LongInt; Ticks: QWord;
begin
  Result := False; AValue := 0; AStatus := 0; ATimestampSec := 0; B := TMemoryStream.Create;
  try
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle); W.RequestHeader(fAuthenticationToken, fRequestHandle); W.DoubleValue(0); W.UInt32(0); W.Int32(1);
      W.NodeId(ANodeId); W.UInt32(13); W.UaString('', True); W.UInt16(0); W.UaString('', True);
    finally W.Free; end;
    if not ExchangeService(COpcUaReadRequest, B, R) then Exit;
    try
      Q := TOpcUaReader.Create(R);
      try
        Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D); Q.ResponseHeader;
        N := Q.Int32;
        if N < 1 then
        begin
          SetError('read', 'server returned no DataValue for ' + ANodeId);
          Exit;
        end;
        Mask := Q.ByteValue;
        if (Mask and 1) = 0 then
        begin
          if (Mask and 2) <> 0 then AStatus := Q.UInt32;
          SetError('read', Format('NodeId %s has no value; status 0x%.8x',
            [ANodeId, AStatus]));
          Exit;
        end;
        VariantMask := Q.ByteValue;
        if (VariantMask and $80) <> 0 then
        begin
          SetError('read', 'array values are not supported for ' + ANodeId);
          Exit;
        end;
        TypeId := VariantMask and $3F;
        case TypeId of
          1: AValue := Ord(Q.BooleanValue);
          2: AValue := ShortInt(Q.ByteValue);
          3: AValue := Q.ByteValue;
          4: AValue := SmallInt(Q.UInt16);
          5: AValue := Q.UInt16;
          6: AValue := LongInt(Q.UInt32);
          7: AValue := Q.UInt32;
          8: AValue := Int64(Q.UInt64);
          9: AValue := Q.UInt64;
          10: AValue := Q.SingleValue;
          11: AValue := Q.DoubleValue;
        else SetError('read', 'unsupported scalar type ' + IntToStr(TypeId)); Exit;
        end;
        if (Mask and 2) <> 0 then AStatus := Q.UInt32;
        if (AStatus and $80000000) <> 0 then
        begin
          SetError('read', Format('NodeId %s returned bad status 0x%.8x',
            [ANodeId, AStatus]));
          Exit;
        end;
        if (Mask and 4) <> 0 then begin Ticks := Q.UInt64; ATimestampSec := Ticks / 10000000.0 - 11644473600.0; end;
        if (Mask and 8) <> 0 then Q.UInt64;
        if (Mask and 16) <> 0 then Q.UInt16;
        if (Mask and 32) <> 0 then Q.UInt16;
        Result := True;
      finally Q.Free; R.Free; end;
    except
      on E: Exception do SetError('read', ANodeId + ': ' + E.Message);
    end;
  finally B.Free; end;
end;

end.
