unit uRecorderOpcUaBinaryClient;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, ssockets;

type
  TRecorderOpcUaStringArray = array of string;
  TRecorderOpcUaDoubleArray = array of Double;
  TRecorderOpcUaCardinalArray = array of Cardinal;
  TRecorderOpcUaDataChange = record
    ClientHandle: Cardinal;
    IsString: Boolean;
    NumericValue: Double;
    StringValue: string;
    TimestampSec: Double;
    Status: Cardinal;
  end;
  PRecorderOpcUaDataChange = ^TRecorderOpcUaDataChange;
  TRecorderOpcUaDataChangeArray = array of TRecorderOpcUaDataChange;

  TRecorderOpcUaDiscoveredNode = class
  public
    NodeId: string;
    DisplayName: string;
    BrowsePath: string;
    TypeDefinition: string;
    DataTypeNodeId: string;
    DataTypeName: string;
    ValueText: string;
    ValueTimestamp: string;
    ArrayValues: TStringList;
    ValueRank: LongInt;
    Historizing: Boolean;
    NodeClass: Cardinal;
    AccessLevel: Byte;
    UserAccessLevel: Byte;
    constructor Create;
    destructor Destroy; override;
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
    fRequestTimeoutMs: Cardinal;
    fBrowseTimeoutMs: Cardinal;
    fConfiguredBrowseTimeoutMs: Cardinal;
    fTimestampsToReturn: Cardinal;
    fSubscriptionId: Cardinal;
    fSubscriptionPublishingIntervalMs: Cardinal;
    fPendingPublishSequence: Cardinal;
    fSubscriptionEnabled: Boolean;
    fMaxReferencesPerNode: Cardinal;
    fRevisedSessionTimeoutMs: Double;
    function ActivateSession: Boolean;
    function BrowseNode(const ANodeId, APath: string; ANodes: TObjectList;
      AVisited: TStrings; ADepth: Integer): Boolean;
    function BrowseParentBatch(AParents: TList; ANodes,
      ANextParents: TObjectList; AVisited: TStrings): Boolean;
    function CreateSession: Boolean;
    procedure CloseSession;
    procedure CloseSecureChannel;
    function ExchangeService(ATypeId: Word; ABody: TMemoryStream;
      out AResponse: TMemoryStream): Boolean;
    function Hello: Boolean;
    function OpenSecureChannel: Boolean;
    function ParseEndpoint: Boolean;
    function CreateSubscription(ANodeIds: TRecorderOpcUaStringArray;
      AClientHandles: TRecorderOpcUaCardinalArray;
      APublishingIntervalMs: Cardinal): Boolean;
    function Publish(var ANotifications: TRecorderOpcUaDataChangeArray): Boolean;
    function ReadVariableAttributes(
      ANode: TRecorderOpcUaDiscoveredNode): Boolean;
    function ReadVariableAttributesBatch(ANodes: TObjectList): Boolean;
    function ReadPropertyValue(ANode: TRecorderOpcUaDiscoveredNode): Boolean;
    function SendMessage(AStream: TMemoryStream;
      const AStage: string): Boolean;
    procedure SetError(const AStage, AText: string);
  public
    constructor Create(const AEndpoint, AUserName, APassword: string;
      ASessionTimeoutMs: Cardinal; ARequestTimeoutMs: Cardinal = 4000;
      ATimestampsToReturn: Cardinal = 1;
      ABrowseTimeoutMs: Cardinal = 180000);
    destructor Destroy; override;
    function Connect: Boolean;
    procedure Disconnect;
    function Browse(ANodes: TObjectList;
      AMaxReferencesPerNode: Cardinal = 100): Boolean;
    function BrowseChildren(const ANodeId, ABrowsePath: string;
      ANodes: TObjectList; AMaxReferencesPerNode: Cardinal = 100): Boolean;
    function ReadDouble(const ANodeId: string; out AValue: Double;
      out AStatus: Cardinal; out ATimestampSec: Double): Boolean;
    function ReadDoubles(const ANodeIds: TRecorderOpcUaStringArray;
      out AValues, ATimestampsSec: TRecorderOpcUaDoubleArray;
      out AStatuses: TRecorderOpcUaCardinalArray): Boolean;
    function ReadStrings(const ANodeIds: TRecorderOpcUaStringArray;
      out AValues: TRecorderOpcUaStringArray;
      out ATimestampsSec: TRecorderOpcUaDoubleArray;
      out AStatuses: TRecorderOpcUaCardinalArray): Boolean;
    function WriteScalar(const ANodeId: string; var ADataTypeNodeId: string;
      AValue: Double): Boolean;
    function WriteScalars(const ANodeIds: TRecorderOpcUaStringArray;
      var ADataTypeNodeIds: TRecorderOpcUaStringArray;
      const AValues: TRecorderOpcUaDoubleArray): Boolean;
    function StartSubscription(ANodeIds: TRecorderOpcUaStringArray;
      AClientHandles: TRecorderOpcUaCardinalArray;
      APublishingIntervalMs: Cardinal): Boolean;
    function ReceiveSubscriptionChanges(
      out ANotifications: TRecorderOpcUaDataChangeArray): Boolean;
    property ErrorText: string read fErrorText;
  end;

implementation

uses
  Math, DateUtils, Base64, uRecorderNetworkBinding, uRecorderDebugLog,
  uRecorderOpcUaTypes;

const
  COpcUaMaxMessageSize = 16 * 1024 * 1024;
  COpcUaTimeoutMs = 4000;
  COpcUaMinimumBrowseTimeoutMs = 30000;
  COpcUaSecurityPolicyNone =
    'http://opcfoundation.org/UA/SecurityPolicy#None';
  COpcUaHierarchicalReferences = 'i=33';
  COpcUaNodeClassObject = 1;
  COpcUaNodeClassVariable = 2;
  COpcUaNodeClassMethod = 4;
  COpcUaOpenSecureChannelRequest = 446;
  COpcUaCreateSessionRequest = 461;
  COpcUaActivateSessionRequest = 467;
  COpcUaCloseSessionRequest = 473;
  COpcUaCloseSecureChannelRequest = 452;
  COpcUaBrowseRequest = 527;
  COpcUaBrowseNextRequest = 533;
  COpcUaReadRequest = 631;
  COpcUaWriteRequest = 673;
  COpcUaCreateMonitoredItemsRequest = 751;
  COpcUaCreateSubscriptionRequest = 787;
  COpcUaPublishRequest = 826;
  COpcUaDataChangeNotificationNodeId = 'i=811';
  COpcUaAttributeValue = 13;
  COpcUaMonitoringModeReporting = 2;
  COpcUaSubscriptionLifetimeCount = 30;
  COpcUaSubscriptionKeepAliveCount = 1;
  COpcUaSubscriptionMaxNotifications = 1000;
  COpcUaMonitoredItemQueueSize = 1;
  COpcUaAnonymousIdentityToken = 321;
  COpcUaUserNameIdentityToken = 324;
  COpcUaUnixEpochOffsetSeconds = 11644473600;
  COpcUaTicksPerSecond = 10000000;
  COpcUaVariantArrayFlag = $80;
  COpcUaVariantDimensionsFlag = $40;
  COpcUaVariantTypeMask = $3F;
  COpcUaBuiltInNull = 0;
  COpcUaBuiltInBoolean = 1;
  COpcUaBuiltInSByte = 2;
  COpcUaBuiltInByte = 3;
  COpcUaBuiltInInt16 = 4;
  COpcUaBuiltInUInt16 = 5;
  COpcUaBuiltInInt32 = 6;
  COpcUaBuiltInUInt32 = 7;
  COpcUaBuiltInInt64 = 8;
  COpcUaBuiltInUInt64 = 9;
  COpcUaBuiltInFloat = 10;
  COpcUaBuiltInDouble = 11;
  COpcUaBuiltInString = 12;
  COpcUaBuiltInDateTime = 13;
  COpcUaBuiltInGuid = 14;
  COpcUaBuiltInByteString = 15;
  COpcUaBuiltInXmlElement = 16;
  COpcUaBuiltInNodeId = 17;
  COpcUaBuiltInExpandedNodeId = 18;
  COpcUaBuiltInStatusCode = 19;
  COpcUaBuiltInQualifiedName = 20;
  COpcUaBuiltInLocalizedText = 21;
  COpcUaBuiltInExtensionObject = 22;
  COpcUaBuiltInDataValue = 23;
  COpcUaBuiltInVariant = 24;
  COpcUaBuiltInDiagnosticInfo = 25;

type
  EOpcUaBinaryError = class(Exception);
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
    procedure RewindByte;
    procedure SkipDiagnosticInfo;
    procedure SkipExtensionObject;
    function ResponseHeader: Cardinal;
    procedure SkipApplicationDescription;
  end;

function OpcUaTimestampText(ATicks: QWord): string; forward;

function OpcUaTimestampSeconds(ATimestampMode: Cardinal;
  ASourceTicks, AServerTicks: QWord): Double;
var
  lTicks: QWord;
begin
  case ATimestampMode of
    0: lTicks := ASourceTicks;
    1: lTicks := AServerTicks;
    2:
      if ASourceTicks <> 0 then lTicks := ASourceTicks
      else lTicks := AServerTicks;
  else
    lTicks := 0;
  end;
  if lTicks = 0 then Exit(0);
  Result := lTicks / COpcUaTicksPerSecond -
    COpcUaUnixEpochOffsetSeconds;
end;

function OpcUaJsonQuote(const AValue: string): string;
var
  I: Integer;
  C: Char;
  lBuilder: TStringBuilder;
begin
  lBuilder := TStringBuilder.Create;
  try
    lBuilder.Append('"');
    for I := 1 to Length(AValue) do
    begin
      C := AValue[I];
      case C of
        '"': lBuilder.Append('\"');
        '\': lBuilder.Append('\\');
        #8: lBuilder.Append('\b');
        #9: lBuilder.Append('\t');
        #10: lBuilder.Append('\n');
        #12: lBuilder.Append('\f');
        #13: lBuilder.Append('\r');
      else
        if Ord(C) < 32 then lBuilder.Append('\u00' + IntToHex(Ord(C), 2))
        else lBuilder.Append(C);
      end;
    end;
    lBuilder.Append('"');
    Result := lBuilder.ToString;
  finally
    lBuilder.Free;
  end;
end;

function OpcUaJsonFloat(AValue: Double): string;
var
  lSettings: TFormatSettings;
begin
  if IsNan(AValue) then Exit('"NaN"');
  if IsInfinite(AValue) then
    if AValue < 0 then Exit('"-Infinity"') else Exit('"Infinity"');
  lSettings := DefaultFormatSettings;
  lSettings.DecimalSeparator := '.';
  Result := FloatToStr(AValue, lSettings);
end;

function OpcUaBytesToBase64(const ABytes: TBytes): string;
var
  lRaw: RawByteString;
begin
  SetLength(lRaw, Length(ABytes));
  if Length(ABytes) > 0 then Move(ABytes[0], lRaw[1], Length(ABytes));
  Result := EncodeStringBase64(lRaw);
end;

function OpcUaVariantJson(AReader: TOpcUaReader; ADepth: Integer): string; forward;

function OpcUaScalarJson(AReader: TOpcUaReader; ATypeId: Byte;
  ADepth: Integer): string;
var
  lBytes: TBytes;
  lFlags, lEncoding: Byte;
  lLength, I, lNamespace: Integer;
  lNodeId, lBody, lName, lLocale: string;
  lRawGuid: TGuid;
  lGuidText: string;
begin
  if ADepth > 16 then
    raise EOpcUaBinaryError.Create('OPC UA Variant nesting is too deep');
  case ATypeId of
    COpcUaBuiltInNull: Result := 'null';
    COpcUaBuiltInBoolean:
      if AReader.BooleanValue then Result := 'true' else Result := 'false';
    COpcUaBuiltInSByte: Result := IntToStr(ShortInt(AReader.ByteValue));
    COpcUaBuiltInByte: Result := IntToStr(AReader.ByteValue);
    COpcUaBuiltInInt16: Result := IntToStr(SmallInt(AReader.UInt16));
    COpcUaBuiltInUInt16: Result := IntToStr(AReader.UInt16);
    COpcUaBuiltInInt32: Result := IntToStr(AReader.Int32);
    COpcUaBuiltInUInt32: Result := UIntToStr(AReader.UInt32);
    COpcUaBuiltInInt64: Result := IntToStr(Int64(AReader.UInt64));
    COpcUaBuiltInUInt64: Result := UIntToStr(AReader.UInt64);
    COpcUaBuiltInFloat: Result := OpcUaJsonFloat(AReader.SingleValue);
    COpcUaBuiltInDouble: Result := OpcUaJsonFloat(AReader.DoubleValue);
    COpcUaBuiltInString, COpcUaBuiltInXmlElement:
      Result := OpcUaJsonQuote(AReader.UaString);
    COpcUaBuiltInDateTime:
      Result := OpcUaJsonQuote(OpcUaTimestampText(AReader.UInt64));
    COpcUaBuiltInGuid:
      begin
        FillChar(lRawGuid, SizeOf(lRawGuid), 0);
        lRawGuid.D1 := AReader.UInt32;
        lRawGuid.D2 := AReader.UInt16;
        lRawGuid.D3 := AReader.UInt16;
        lBytes := AReader.Raw(8);
        Move(lBytes[0], lRawGuid.D4[0], 8);
        lGuidText := GUIDToString(lRawGuid);
        Result := OpcUaJsonQuote(Copy(lGuidText, 2, Length(lGuidText) - 2));
      end;
    COpcUaBuiltInByteString:
      Result := '{"encoding":"base64","value":' +
        OpcUaJsonQuote(OpcUaBytesToBase64(AReader.ByteString)) + '}';
    COpcUaBuiltInNodeId:
      begin
        lNodeId := AReader.NodeId(lBytes);
        Result := OpcUaJsonQuote(lNodeId);
      end;
    COpcUaBuiltInExpandedNodeId:
      Result := OpcUaJsonQuote(AReader.ExpandedNodeId);
    COpcUaBuiltInStatusCode:
      begin
        lLength := AReader.Int32;
        Result := '{"code":' + UIntToStr(Cardinal(lLength)) +
          ',"hex":"0x' + IntToHex(Cardinal(lLength), 8) + '"}';
      end;
    COpcUaBuiltInQualifiedName:
      begin
        lNamespace := AReader.UInt16;
        lName := AReader.UaString;
        Result := '{"namespaceIndex":' + IntToStr(lNamespace) +
          ',"name":' + OpcUaJsonQuote(lName) + '}';
      end;
    COpcUaBuiltInLocalizedText:
      begin
        lFlags := AReader.ByteValue;
        lLocale := '';
        lName := '';
        if (lFlags and 1) <> 0 then lLocale := AReader.UaString;
        if (lFlags and 2) <> 0 then lName := AReader.UaString;
        Result := '{"locale":' + OpcUaJsonQuote(lLocale) +
          ',"text":' + OpcUaJsonQuote(lName) + '}';
      end;
    COpcUaBuiltInExtensionObject:
      begin
        lNodeId := AReader.NodeId(lBytes);
        lEncoding := AReader.ByteValue;
        lBody := '';
        if lEncoding = 1 then
          lBody := OpcUaBytesToBase64(AReader.ByteString)
        else if lEncoding = 2 then
          lBody := AReader.UaString
        else if lEncoding <> 0 then
          raise EOpcUaBinaryError.CreateFmt(
            'Unsupported ExtensionObject encoding %d', [lEncoding]);
        Result := '{"typeId":' + OpcUaJsonQuote(lNodeId) +
          ',"encoding":' + IntToStr(lEncoding);
        if lEncoding = 1 then
          Result := Result + ',"bodyBase64":' + OpcUaJsonQuote(lBody)
        else if lEncoding = 2 then
          Result := Result + ',"bodyXml":' + OpcUaJsonQuote(lBody);
        Result := Result + '}';
      end;
    COpcUaBuiltInDataValue:
      begin
        lFlags := AReader.ByteValue;
        Result := '{';
        if (lFlags and 1) <> 0 then
        begin
          Result := Result + '"value":' + OpcUaVariantJson(AReader, ADepth + 1);
          if (lFlags and $FE) <> 0 then Result := Result + ',';
        end;
        if (lFlags and 2) <> 0 then
        begin
          Result := Result + '"status":' + UIntToStr(AReader.UInt32);
          if (lFlags and $FC) <> 0 then Result := Result + ',';
        end;
        if (lFlags and 4) <> 0 then
        begin
          Result := Result + '"sourceTimestamp":' +
            OpcUaJsonQuote(OpcUaTimestampText(AReader.UInt64));
          if (lFlags and $F8) <> 0 then Result := Result + ',';
        end;
        if (lFlags and 8) <> 0 then
        begin
          Result := Result + '"serverTimestamp":' +
            OpcUaJsonQuote(OpcUaTimestampText(AReader.UInt64));
          if (lFlags and $F0) <> 0 then Result := Result + ',';
        end;
        if (lFlags and 16) <> 0 then
        begin
          Result := Result + '"sourcePicoseconds":' + IntToStr(AReader.UInt16);
          if (lFlags and $E0) <> 0 then Result := Result + ',';
        end;
        if (lFlags and 32) <> 0 then
          Result := Result + '"serverPicoseconds":' + IntToStr(AReader.UInt16);
        Result := Result + '}';
      end;
    COpcUaBuiltInVariant:
      Result := OpcUaVariantJson(AReader, ADepth + 1);
    COpcUaBuiltInDiagnosticInfo:
      begin
        lFlags := AReader.ByteValue;
        Result := '{';
        if (lFlags and 1) <> 0 then
        begin Result := Result + '"symbolicId":' + IntToStr(AReader.Int32); if (lFlags and $FE) <> 0 then Result := Result + ','; end;
        if (lFlags and 2) <> 0 then
        begin Result := Result + '"namespaceUri":' + IntToStr(AReader.Int32); if (lFlags and $FC) <> 0 then Result := Result + ','; end;
        if (lFlags and 4) <> 0 then
        begin Result := Result + '"locale":' + IntToStr(AReader.Int32); if (lFlags and $F8) <> 0 then Result := Result + ','; end;
        if (lFlags and 8) <> 0 then
        begin Result := Result + '"localizedText":' + IntToStr(AReader.Int32); if (lFlags and $F0) <> 0 then Result := Result + ','; end;
        if (lFlags and 16) <> 0 then
        begin Result := Result + '"additionalInfo":' + OpcUaJsonQuote(AReader.UaString); if (lFlags and $E0) <> 0 then Result := Result + ','; end;
        if (lFlags and 32) <> 0 then
        begin Result := Result + '"innerStatusCode":' + UIntToStr(AReader.UInt32); if (lFlags and $C0) <> 0 then Result := Result + ','; end;
        if (lFlags and 64) <> 0 then Result := Result + '"innerDiagnosticInfo":' + OpcUaScalarJson(AReader, COpcUaBuiltInDiagnosticInfo, ADepth + 1);
        Result := Result + '}';
      end;
  else
    raise EOpcUaBinaryError.CreateFmt('Unsupported OPC UA built-in type %d',
      [ATypeId]);
  end;
end;

function OpcUaVariantJson(AReader: TOpcUaReader; ADepth: Integer): string;
var
  lMask, lTypeId: Byte;
  lCount, I, lDimensionCount: Integer;
  lValues, lDimensions: string;
  lBuilder: TStringBuilder;
begin
  if ADepth > 16 then
    raise EOpcUaBinaryError.Create('OPC UA Variant nesting is too deep');
  lMask := AReader.ByteValue;
  lTypeId := lMask and COpcUaVariantTypeMask;
  if (lMask and COpcUaVariantArrayFlag) = 0 then
  begin
    Result := OpcUaScalarJson(AReader, lTypeId, ADepth + 1);
    Exit;
  end;
  lCount := AReader.Int32;
  if (lCount < -1) or (lCount > COpcUaMaxMessageSize) then
    raise EOpcUaBinaryError.CreateFmt('Invalid OPC UA array length %d', [lCount]);
  lBuilder := TStringBuilder.Create;
  try
    for I := 0 to lCount - 1 do
    begin
      if I > 0 then lBuilder.Append(',');
      lBuilder.Append(OpcUaScalarJson(AReader, lTypeId, ADepth + 1));
    end;
    lValues := lBuilder.ToString;
  finally
    lBuilder.Free;
  end;
  Result := '{"kind":"array","typeId":' + IntToStr(lTypeId) +
    ',"values":[' + lValues + ']';
  if lCount < 0 then Result := Result + ',"isNull":true';
  if (lMask and COpcUaVariantDimensionsFlag) <> 0 then
  begin
    lDimensionCount := AReader.Int32;
    if (lDimensionCount < 0) or (lDimensionCount > 32) then
      raise EOpcUaBinaryError.CreateFmt(
        'Invalid OPC UA array dimensions count %d', [lDimensionCount]);
    lDimensions := '';
    for I := 0 to lDimensionCount - 1 do
    begin
      if I > 0 then lDimensions := lDimensions + ',';
      lDimensions := lDimensions + IntToStr(AReader.UInt32);
    end;
    Result := Result + ',"dimensions":[' + lDimensions + ']';
  end;
  Result := Result + '}';
end;

function ReadNotificationDataValue(AReader: TOpcUaReader;
  ATimestampMode: Cardinal;
  AChange: PRecorderOpcUaDataChange): Boolean;
var
  lMask, lVariantMask, lTypeId: Byte;
  lSourceTicks, lServerTicks: QWord;
  lStatus: Cardinal;
  lTextValue: string;
begin
  Result := False;
  lMask := AReader.ByteValue;
  if (lMask and 1) = 0 then
  begin
    if (lMask and 2) <> 0 then AChange^.Status := AReader.UInt32;
  end
  else
  begin
    lVariantMask := AReader.ByteValue;
    lTypeId := lVariantMask and COpcUaVariantTypeMask;
    AChange^.IsString := True;
    if ((lVariantMask and COpcUaVariantArrayFlag) = 0) and
      (lTypeId >= COpcUaBuiltInBoolean) and
      (lTypeId <= COpcUaBuiltInDouble) then
    begin
      case lTypeId of
        COpcUaBuiltInBoolean: AChange^.NumericValue := Ord(AReader.BooleanValue);
        COpcUaBuiltInSByte: AChange^.NumericValue := ShortInt(AReader.ByteValue);
        COpcUaBuiltInByte: AChange^.NumericValue := AReader.ByteValue;
        COpcUaBuiltInInt16: AChange^.NumericValue := SmallInt(AReader.UInt16);
        COpcUaBuiltInUInt16: AChange^.NumericValue := AReader.UInt16;
        COpcUaBuiltInInt32: AChange^.NumericValue := AReader.Int32;
        COpcUaBuiltInUInt32: AChange^.NumericValue := AReader.UInt32;
        COpcUaBuiltInInt64: AChange^.NumericValue := Int64(AReader.UInt64);
        COpcUaBuiltInUInt64: AChange^.NumericValue := AReader.UInt64;
        COpcUaBuiltInFloat: AChange^.NumericValue := AReader.SingleValue;
        COpcUaBuiltInDouble: AChange^.NumericValue := AReader.DoubleValue;
      end;
      AChange^.IsString := False;
    end
    else
    begin
      if ((lVariantMask and COpcUaVariantArrayFlag) = 0) and
        ((lTypeId = COpcUaBuiltInString) or
         (lTypeId = COpcUaBuiltInXmlElement)) then
        lTextValue := AReader.UaString
      else
      begin
        AReader.RewindByte;
        lTextValue := OpcUaVariantJson(AReader, 0);
      end;
      AChange^.StringValue := lTextValue;
    end;
    if (lMask and 2) <> 0 then
    begin
      lStatus := AReader.UInt32;
      AChange^.Status := lStatus;
    end;
  end;
  lSourceTicks := 0;
  lServerTicks := 0;
  if (lMask and 4) <> 0 then lSourceTicks := AReader.UInt64;
  if (lMask and 8) <> 0 then lServerTicks := AReader.UInt64;
  if (lMask and 16) <> 0 then AReader.UInt16;
  if (lMask and 32) <> 0 then AReader.UInt16;
  AChange^.TimestampSec := OpcUaTimestampSeconds(ATimestampMode,
    lSourceTicks, lServerTicks);
  Result := (lMask and 1) <> 0;
end;

type
  TOpcUaBrowseParent = class
  public
    NodeId: string;
    BrowsePath: string;
    Depth: Integer;
    ContinuationPoint: TBytes;
  end;

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
    procedure SingleValue(AValue: Single);
    procedure Raw(const AValue; ACount: Integer);
    procedure UaString(const AValue: string; ANull: Boolean = False);
    procedure ByteString(const AValue: TBytes; ANull: Boolean = False);
    procedure NodeId(const AValue: string);
    procedure EncodedNodeId(AEncodingId: Word);
    procedure ExtensionObjectNull;
    procedure RequestHeader(const AAuthenticationToken: TBytes;
      ARequestHandle: Cardinal; ATimeoutHintMs: Cardinal = COpcUaTimeoutMs);
  end;

constructor TRecorderOpcUaDiscoveredNode.Create;
begin
  inherited Create;
  ArrayValues := TStringList.Create;
end;

destructor TRecorderOpcUaDiscoveredNode.Destroy;
begin
  ArrayValues.Free;
  inherited Destroy;
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

procedure TOpcUaWriter.SingleValue(AValue: Single);
var B: Cardinal;
begin Move(AValue, B, 4); UInt32(B); end;

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
  lBytes: TBytes;
  lDecoded: RawByteString;
  lGuid: TGuid;
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
  if Pos('g=', LowerCase(lText)) = 1 then
  begin
    lIdentifier := Copy(lText, 3, MaxInt);
    if (Length(lIdentifier) = 0) or (lIdentifier[1] <> '{') then
      lIdentifier := '{' + lIdentifier + '}';
    try
      lGuid := StringToGUID(lIdentifier);
    except
      raise EOpcUaBinaryError.Create('Invalid GUID NodeId: ' + AValue);
    end;
    ByteValue(4); UInt16(Word(lNamespace));
    UInt32(lGuid.D1); UInt16(lGuid.D2); UInt16(lGuid.D3);
    Raw(lGuid.D4[0], Length(lGuid.D4));
    Exit;
  end;
  if Pos('b=', LowerCase(lText)) = 1 then
  begin
    lIdentifier := Copy(lText, 3, MaxInt);
    try
      lDecoded := DecodeStringBase64(lIdentifier);
    except
      raise EOpcUaBinaryError.Create('Invalid ByteString NodeId: ' + AValue);
    end;
    SetLength(lBytes, Length(lDecoded));
    if Length(lBytes) > 0 then Move(lDecoded[1], lBytes[0], Length(lBytes));
    ByteValue(5); UInt16(Word(lNamespace)); ByteString(lBytes);
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
  ARequestHandle: Cardinal; ATimeoutHintMs: Cardinal);
begin
  if Length(AAuthenticationToken) = 0 then begin ByteValue(0); ByteValue(0); end
  else Raw(AAuthenticationToken[0], Length(AAuthenticationToken));
  UInt64(OpcUaNow);
  UInt32(ARequestHandle);
  UInt32(0);
  UaString('', True);
  UInt32(ATimeoutHintMs);
  ExtensionObjectNull;
end;

constructor TOpcUaReader.Create(AStream: TStream);
begin inherited Create; fStream := AStream; end;

procedure TOpcUaReader.Need(ACount: Int64);
var
  I, lCount: Integer;
  lByte: Byte;
  lHex: string;
  lSaved, lStart: Int64;
begin
  if (ACount < 0) or (fStream.Position + ACount > fStream.Size) then
  begin
    lSaved := fStream.Position;
    lStart := lSaved - 24;
    if lStart < 0 then lStart := 0;
    lCount := Integer(lSaved - lStart);
    lHex := '';
    fStream.Position := lStart;
    for I := 0 to lCount - 1 do
    begin
      fStream.ReadBuffer(lByte, 1);
      if lHex <> '' then lHex := lHex + ' ';
      lHex := lHex + IntToHex(lByte, 2);
    end;
    fStream.Position := lSaved;
    raise EOpcUaBinaryError.CreateFmt(
      'Truncated OPC UA message: pos=%d need=%d size=%d before=%s',
      [fStream.Position, ACount, fStream.Size, lHex]);
  end;
end;

procedure TOpcUaReader.RewindByte;
begin
  if fStream.Position <= 0 then
    raise EOpcUaBinaryError.Create('Cannot rewind OPC UA reader');
  fStream.Position := fStream.Position - 1;
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
  I: Integer;
  lBytes: TBytes;
  lEncoding, lNs: Byte;
  lStart: Int64;
  lId, lGuidD1: Cardinal;
  lGuidD2, lGuidD3, lNs16: Word;
  lRaw: RawByteString;
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
    4: begin
         lNs16 := UInt16; lGuidD1 := UInt32; lGuidD2 := UInt16;
         lGuidD3 := UInt16; lBytes := Raw(8);
         lText := IntToHex(lGuidD1, 8) + '-' + IntToHex(lGuidD2, 4) + '-' +
           IntToHex(lGuidD3, 4) + '-' + IntToHex(lBytes[0], 2) +
           IntToHex(lBytes[1], 2) + '-';
         for I := 2 to 7 do lText := lText + IntToHex(lBytes[I], 2);
         Result := Format('ns=%d;g=%s', [lNs16, LowerCase(lText)]);
       end;
    5: begin
         lNs16 := UInt16; lBytes := ByteString;
         SetLength(lRaw, Length(lBytes));
         if Length(lBytes) > 0 then Move(lBytes[0], lRaw[1], Length(lBytes));
         Result := Format('ns=%d;b=%s',
           [lNs16, EncodeStringBase64(lRaw)]);
       end;
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
    4: begin UInt16; Raw(16); end;
    5: begin UInt16; ByteString; end;
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
  APassword: string; ASessionTimeoutMs: Cardinal; ARequestTimeoutMs: Cardinal;
  ATimestampsToReturn: Cardinal; ABrowseTimeoutMs: Cardinal);
begin
  inherited Create;
  fEndpoint := Trim(AEndpoint);
  fUserName := AUserName;
  fPassword := APassword;
  fSessionTimeoutMs := ASessionTimeoutMs;
  if fSessionTimeoutMs < 1000 then fSessionTimeoutMs := 1000;
  fRequestTimeoutMs := ARequestTimeoutMs;
  if fRequestTimeoutMs < 100 then fRequestTimeoutMs := 100;
  fBrowseTimeoutMs := fRequestTimeoutMs;
  fConfiguredBrowseTimeoutMs := ABrowseTimeoutMs;
  if fConfiguredBrowseTimeoutMs < COpcUaMinimumBrowseTimeoutMs then
    fConfiguredBrowseTimeoutMs := COpcUaMinimumBrowseTimeoutMs;
  if ATimestampsToReturn > 3 then ATimestampsToReturn := 1;
  fTimestampsToReturn := ATimestampsToReturn;
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

function TRecorderOpcUaBinaryClient.CreateSubscription(
  ANodeIds: TRecorderOpcUaStringArray;
  AClientHandles: TRecorderOpcUaCardinalArray;
  APublishingIntervalMs: Cardinal): Boolean;
var
  B, R: TMemoryStream;
  W: TOpcUaWriter;
  Q: TOpcUaReader;
  D: TBytes;
  I, N: Integer;
  lStatus: Cardinal;
begin
  Result := False;
  if Length(ANodeIds) <> Length(AClientHandles) then
  begin
    SetError('subscription', 'node and client-handle counts differ');
    Exit;
  end;
  if Length(ANodeIds) = 0 then Exit(True);
  B := TMemoryStream.Create;
  R := nil;
  try
    try
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle);
      W.RequestHeader(fAuthenticationToken, fRequestHandle,
        Max(fRequestTimeoutMs, 10000));
      W.DoubleValue(APublishingIntervalMs);
      W.UInt32(COpcUaSubscriptionLifetimeCount);
      W.UInt32(COpcUaSubscriptionKeepAliveCount);
      W.UInt32(COpcUaSubscriptionMaxNotifications);
      W.BooleanValue(True);
      W.ByteValue(0);
    finally
      W.Free;
    end;
    if not ExchangeService(COpcUaCreateSubscriptionRequest, B, R) then Exit;
    try
      Q := TOpcUaReader.Create(R);
      try
        Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D);
        lStatus := Q.ResponseHeader;
        if lStatus <> 0 then
        begin
          SetError('create subscription', Format('status 0x%.8x', [lStatus]));
          Exit;
        end;
        fSubscriptionId := Q.UInt32;
        fSubscriptionPublishingIntervalMs := Cardinal(Trunc(Max(10.0,
          Q.DoubleValue)));
        Q.UInt32; { revisedLifetimeCount }
        Q.UInt32; { revisedMaxKeepAliveCount }
      finally
        Q.Free;
      end;
    finally
      R.Free;
      R := nil;
    end;

    B.Size := 0;
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle);
      W.RequestHeader(fAuthenticationToken, fRequestHandle,
        Max(fRequestTimeoutMs, 10000));
      W.UInt32(fSubscriptionId);
      W.UInt32(fTimestampsToReturn);
      W.Int32(Length(ANodeIds));
      for I := 0 to High(ANodeIds) do
      begin
        W.NodeId(ANodeIds[I]);
        W.UInt32(COpcUaAttributeValue);
        W.UaString('', True);
        W.UInt16(0);
        W.UaString('', True);
        W.UInt32(COpcUaMonitoringModeReporting);
        W.UInt32(AClientHandles[I]);
        W.DoubleValue(APublishingIntervalMs);
        W.ExtensionObjectNull;
        W.UInt32(COpcUaMonitoredItemQueueSize);
        W.BooleanValue(True);
      end;
    finally
      W.Free;
    end;
    if not ExchangeService(COpcUaCreateMonitoredItemsRequest, B, R) then Exit;
    try
      Q := TOpcUaReader.Create(R);
      try
        Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D);
        lStatus := Q.ResponseHeader;
        if lStatus <> 0 then
        begin
          SetError('create monitored items', Format('status 0x%.8x',
            [lStatus]));
          Exit;
        end;
        N := Q.Int32;
        if N <> Length(ANodeIds) then
        begin
          SetError('create monitored items', Format(
            'server returned %d results for %d items', [N, Length(ANodeIds)]));
          Exit;
        end;
        for I := 0 to N - 1 do
        begin
          lStatus := Q.UInt32;
          Q.UInt32; { monitoredItemId }
          Q.DoubleValue;
          Q.UInt32;
          Q.SkipExtensionObject;
          if (lStatus and $C0000000) <> 0 then
          begin
            SetError('create monitored item', Format(
              'NodeId %s returned status 0x%.8x', [ANodeIds[I], lStatus]));
            Exit;
          end;
        end;
      finally
        Q.Free;
      end;
    finally
      R.Free;
      R := nil;
    end;
    fSubscriptionEnabled := True;
    Result := True;
    except
      on E: Exception do SetError('create subscription', E.Message);
    end;
  finally
    R.Free;
    B.Free;
  end;
end;

function TRecorderOpcUaBinaryClient.Publish(
  var ANotifications: TRecorderOpcUaDataChangeArray): Boolean;
var
  B, R, LBody: TMemoryStream;
  W: TOpcUaWriter;
  Q, LReader: TOpcUaReader;
  D, LEncoded: TBytes;
  I, J, N, LEncoding, LBodySize, LItemCount, LDiagnosticCount: Integer;
  LSubscriptionId, LSequence, LClientHandle, LStatus: Cardinal;
  LTypeId: string;
  LChange: TRecorderOpcUaDataChange;
  LPreviousTimeout, LPublishTimeout: Integer;
  LFirstUpdate: Boolean;
begin
  Result := False;
  if not fSubscriptionEnabled then Exit(True);
  B := TMemoryStream.Create;
  R := nil;
  LBody := nil;
  LPublishTimeout := Integer(Max(Cardinal(fRequestTimeoutMs),
    fSubscriptionPublishingIntervalMs * 3 + 5000));
  LPreviousTimeout := fStream.IOTimeout;
  fStream.IOTimeout := LPublishTimeout;
  try
    try
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle);
      W.RequestHeader(fAuthenticationToken, fRequestHandle,
        Cardinal(LPublishTimeout));
      if fPendingPublishSequence <> 0 then
      begin
        W.Int32(1);
        W.UInt32(fSubscriptionId);
        W.UInt32(fPendingPublishSequence);
      end
      else
        W.Int32(0);
    finally
      W.Free;
    end;
    if not ExchangeService(COpcUaPublishRequest, B, R) then Exit;
    fPendingPublishSequence := 0;
    Q := TOpcUaReader.Create(R);
    try
      Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D);
      LStatus := Q.ResponseHeader;
      if LStatus <> 0 then
      begin
        SetError('publish', Format('status 0x%.8x', [LStatus]));
        Exit;
      end;
      LSubscriptionId := Q.UInt32;
      if LSubscriptionId <> fSubscriptionId then
      begin
        SetError('publish', Format('unexpected subscription id %d',
          [LSubscriptionId]));
        Exit;
      end;
      N := Q.Int32;
      for I := 0 to N - 1 do Q.UInt32;
      Q.BooleanValue;
      LSequence := Q.UInt32;
      Q.UInt64; { publishTime }
      LItemCount := Q.Int32;
      LFirstUpdate := False;
      for I := 0 to LItemCount - 1 do
      begin
        LTypeId := Q.NodeId(LEncoded);
        LEncoding := Q.ByteValue;
        if LEncoding = 0 then Continue;
        LBodySize := Q.Int32;
        if (LBodySize < 0) or (LBodySize > COpcUaMaxMessageSize) then
          raise EOpcUaBinaryError.Create('Invalid notification body size');
        D := Q.Raw(LBodySize);
        if not SameText(LTypeId, COpcUaDataChangeNotificationNodeId) then
          Continue;
        LBody.Free;
        LBody := TMemoryStream.Create;
        if Length(D) > 0 then LBody.WriteBuffer(D[0], Length(D));
        LBody.Position := 0;
        LReader := TOpcUaReader.Create(LBody);
        try
          N := LReader.Int32;
          for J := 0 to N - 1 do
          begin
            LClientHandle := LReader.UInt32;
            LChange.IsString := False;
            LChange.NumericValue := 0;
            LChange.StringValue := '';
            LChange.TimestampSec := 0;
            LChange.Status := 0;
            LChange.ClientHandle := LClientHandle;
            if not ReadNotificationDataValue(LReader, fTimestampsToReturn,
              @LChange) then Continue;
            SetLength(ANotifications, Length(ANotifications) + 1);
            ANotifications[High(ANotifications)] := LChange;
            LFirstUpdate := True;
          end;
          LDiagnosticCount := LReader.Int32;
          for J := 0 to LDiagnosticCount - 1 do LReader.SkipDiagnosticInfo;
        finally
          LReader.Free;
        end;
      end;
      N := Q.Int32;
      for I := 0 to N - 1 do Q.UInt32;
      N := Q.Int32;
      for I := 0 to N - 1 do Q.SkipDiagnosticInfo;
      if LFirstUpdate then fPendingPublishSequence := LSequence;
      Result := True;
    finally
      Q.Free;
    end;
  except
    on E: Exception do SetError('publish', E.Message);
    end;
  finally
    if fStream <> nil then fStream.IOTimeout := LPreviousTimeout;
    LBody.Free;
    R.Free;
    B.Free;
  end;
end;

function TRecorderOpcUaBinaryClient.StartSubscription(
  ANodeIds: TRecorderOpcUaStringArray;
  AClientHandles: TRecorderOpcUaCardinalArray;
  APublishingIntervalMs: Cardinal): Boolean;
begin
  fSubscriptionEnabled := False;
  fSubscriptionId := 0;
  fPendingPublishSequence := 0;
  if Length(ANodeIds) = 0 then Exit(True);
  Result := CreateSubscription(ANodeIds, AClientHandles,
    APublishingIntervalMs);
end;

function TRecorderOpcUaBinaryClient.ReceiveSubscriptionChanges(
  out ANotifications: TRecorderOpcUaDataChangeArray): Boolean;
begin
  SetLength(ANotifications, 0);
  Result := Publish(ANotifications);
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
  fSubscriptionId := 0;
  fSubscriptionPublishingIntervalMs := 0;
  fPendingPublishSequence := 0;
  fSubscriptionEnabled := False;
  SetLength(fAuthenticationToken, 0);
end;

function TRecorderOpcUaBinaryClient.BrowseNode(const ANodeId, APath: string;
  ANodes: TObjectList; AVisited: TStrings; ADepth: Integer): Boolean;
var
  B, R: TMemoryStream;
  lErrorText: string;
  W: TOpcUaWriter;
  lContinuationPoint: TBytes;

  function ProcessBrowseResponse(AResponse: TMemoryStream;
    out AContinuationPoint: TBytes): Boolean;
  var
    Q: TOpcUaReader;
    D: TBytes;
    I, J, N, Count: LongInt;
    NodeClass, Status: Cardinal;
    NodeId, DisplayName, TypeDefinition, NodePath: string;
    lStage: string;
    LocalizedMask: Byte;
    Item: TRecorderOpcUaDiscoveredNode;
  begin
    Result := False;
    SetLength(AContinuationPoint, 0);
    Q := TOpcUaReader.Create(AResponse);
    try
      try
        lStage := 'message header';
      Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D);
      lStage := 'response header';
      Q.ResponseHeader;
      lStage := 'result count';
      N := Q.Int32;
      for I := 0 to N - 1 do
      begin
        lStage := Format('result[%d] status', [I]);
        Status := Q.UInt32;
        lStage := Format('result[%d] continuation', [I]);
        AContinuationPoint := Q.ByteString;
        lStage := Format('result[%d] reference count', [I]);
        Count := Q.Int32;
        if Status <> 0 then
        begin
          SetError('browse', 'status 0x' + IntToHex(Status, 8));
          Exit;
        end;
        for J := 0 to Count - 1 do
        begin
          lStage := Format('reference[%d] referenceTypeId', [J]);
          Q.NodeId(D); Q.BooleanValue; NodeId := Q.ExpandedNodeId;
          lStage := Format('reference[%d] browseName', [J]);
          Q.UInt16; Q.UaString;
          lStage := Format('reference[%d] displayName', [J]);
          LocalizedMask := Q.ByteValue;
          if (LocalizedMask and 1) <> 0 then Q.UaString;
          if (LocalizedMask and 2) <> 0 then DisplayName := Q.UaString
          else DisplayName := '';
          NodeClass := Q.UInt32;
          lStage := Format('reference[%d] typeDefinition', [J]);
          TypeDefinition := Q.ExpandedNodeId;
          if APath = '' then NodePath := DisplayName
          else NodePath := APath + '/' + DisplayName;

          Item := TRecorderOpcUaDiscoveredNode.Create;
          Item.NodeId := NodeId;
          Item.DisplayName := DisplayName;
          Item.BrowsePath := NodePath;
          Item.TypeDefinition := TypeDefinition;
          Item.NodeClass := NodeClass;
          Item.ValueRank := -1;
          ANodes.Add(Item);

          if NodeClass = COpcUaNodeClassObject then
            if not BrowseNode(NodeId, NodePath, ANodes, AVisited,
              ADepth + 1) then Exit;
          if NodeClass = COpcUaNodeClassVariable then
            if not Item.IsProperty then
              if not BrowseNode(NodeId, NodePath, ANodes, AVisited,
                ADepth + 1) then Exit;
        end;
      end;
        Result := True;
      except
        on E: Exception do
          raise EOpcUaBinaryError.CreateFmt('%s at pos=%d: %s',
            [lStage, AResponse.Position, E.Message]);
      end;
    finally
      Q.Free;
    end;
  end;
begin
  Result := False;
  if ADepth > 64 then Exit(True);
  if AVisited.IndexOf(ANodeId) >= 0 then Exit(True);
  AVisited.Add(ANodeId);
  B := TMemoryStream.Create;
  try
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle); W.RequestHeader(fAuthenticationToken, fRequestHandle,
        fBrowseTimeoutMs);
      W.NodeId('i=0'); W.UInt64(0); W.UInt32(0);
      W.UInt32(fMaxReferencesPerNode); W.Int32(1);
      W.NodeId(ANodeId); W.UInt32(0); W.NodeId(COpcUaHierarchicalReferences); W.BooleanValue(True);
      W.UInt32(COpcUaNodeClassObject or COpcUaNodeClassVariable or
        COpcUaNodeClassMethod); W.UInt32(63);
    finally W.Free; end;
    if not ExchangeService(COpcUaBrowseRequest, B, R) then
    begin
      lErrorText := fErrorText;
      SetError('browse request', Format('nodeId=%s path=%s depth=%d; %s',
        [ANodeId, APath, ADepth, lErrorText]));
      RecorderDebugLog(Format(
        '[TIME: %s] [TYPE: ERROR] [CONTEXT: TRecorderOpcUaBinaryClient.BrowseNode, Line: 1087] [DATA: endpoint=%s stage=Browse nodeId=%s browsePath=%s depth=%d error=%s]',
        [FormatDateTime('hh:nn:ss.zzz', Now), fEndpoint, ANodeId,
         APath, ADepth, lErrorText]));
      Exit;
    end;
    try
      if not ProcessBrowseResponse(R, lContinuationPoint) then Exit;
    finally R.Free; end;
    while Length(lContinuationPoint) > 0 do
    begin
      B.Clear;
      W := TOpcUaWriter.Create(B);
      try
        Inc(fRequestHandle);
        W.RequestHeader(fAuthenticationToken, fRequestHandle,
          fBrowseTimeoutMs);
        W.BooleanValue(False);
        W.Int32(1);
        W.ByteString(lContinuationPoint);
      finally
        W.Free;
      end;
      if not ExchangeService(COpcUaBrowseNextRequest, B, R) then
      begin
        lErrorText := fErrorText;
        SetError('browse next', Format(
          'nodeId=%s path=%s depth=%d; %s',
          [ANodeId, APath, ADepth, lErrorText]));
        RecorderDebugLog(Format(
          '[TIME: %s] [TYPE: ERROR] [CONTEXT: TRecorderOpcUaBinaryClient.BrowseNode, Line: 1113] [DATA: endpoint=%s stage=BrowseNext nodeId=%s browsePath=%s depth=%d error=%s]',
          [FormatDateTime('hh:nn:ss.zzz', Now), fEndpoint, ANodeId,
           APath, ADepth, lErrorText]));
        Exit;
      end;
      try
        if not ProcessBrowseResponse(R, lContinuationPoint) then Exit;
      finally
        R.Free;
      end;
    end;
    Result := True;
  finally B.Free; end;
end;

function TRecorderOpcUaBinaryClient.BrowseParentBatch(AParents: TList;
  ANodes, ANextParents: TObjectList; AVisited: TStrings): Boolean;
var
  I: Integer;
  B, R: TMemoryStream;
  W: TOpcUaWriter;
  lContinuations, lNextContinuations: TList;
  lErrorText: string;

  function ProcessResponse(AResponse: TMemoryStream; AResponseParents,
    AContinuationParents: TList): Boolean;
  var
    Q: TOpcUaReader;
    D: TBytes;
    I, J, N, Count: LongInt;
    NodeClass, Status: Cardinal;
    NodeId, DisplayName, TypeDefinition, NodePath: string;
    lLocalizedMask: Byte;
    lParent, lChild: TOpcUaBrowseParent;
    lItem: TRecorderOpcUaDiscoveredNode;
  begin
    Result := False;
    Q := TOpcUaReader.Create(AResponse);
    try
      Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D);
      Q.ResponseHeader;
      N := Q.Int32;
      if N <> AResponseParents.Count then
      begin
        SetError('browse batch', Format(
          'expected %d BrowseResults, received %d',
          [AResponseParents.Count, N]));
        Exit;
      end;
      for I := 0 to N - 1 do
      begin
        lParent := TOpcUaBrowseParent(AResponseParents[I]);
        Status := Q.UInt32;
        lParent.ContinuationPoint := Q.ByteString;
        Count := Q.Int32;
        if Status <> 0 then
        begin
          SetError('browse batch', Format(
            'nodeId=%s path=%s status=0x%s',
            [lParent.NodeId, lParent.BrowsePath, IntToHex(Status, 8)]));
          Exit;
        end;
        for J := 0 to Count - 1 do
        begin
          Q.NodeId(D);
          Q.BooleanValue;
          NodeId := Q.ExpandedNodeId;
          Q.UInt16;
          Q.UaString;
          lLocalizedMask := Q.ByteValue;
          if (lLocalizedMask and 1) <> 0 then Q.UaString;
          if (lLocalizedMask and 2) <> 0 then
            DisplayName := Q.UaString
          else
            DisplayName := '';
          NodeClass := Q.UInt32;
          TypeDefinition := Q.ExpandedNodeId;
          if lParent.BrowsePath = '' then
            NodePath := DisplayName
          else
            NodePath := lParent.BrowsePath + '/' + DisplayName;

          lItem := TRecorderOpcUaDiscoveredNode.Create;
          lItem.NodeId := NodeId;
          lItem.DisplayName := DisplayName;
          lItem.BrowsePath := NodePath;
          lItem.TypeDefinition := TypeDefinition;
          lItem.NodeClass := NodeClass;
          lItem.ValueRank := -1;
          ANodes.Add(lItem);

          if (lParent.Depth < 64) and
            ((NodeClass = COpcUaNodeClassObject) or
             ((NodeClass = COpcUaNodeClassVariable) and
              not lItem.IsProperty)) and
            (AVisited.IndexOf(NodeId) < 0) then
          begin
            AVisited.Add(NodeId);
            lChild := TOpcUaBrowseParent.Create;
            lChild.NodeId := NodeId;
            lChild.BrowsePath := NodePath;
            lChild.Depth := lParent.Depth + 1;
            ANextParents.Add(lChild);
          end;
        end;
        if Length(lParent.ContinuationPoint) > 0 then
          AContinuationParents.Add(lParent);
      end;
      Result := True;
    except
      on E: Exception do
        SetError('browse batch decode', E.Message);
    end;
    Q.Free;
  end;

  function ExchangeBrowse(ARequestParents: TList;
    AContinuation: Boolean; AContinuationParents: TList): Boolean;
  var
    I: Integer;
    lParent: TOpcUaBrowseParent;
  begin
    Result := False;
    B.Clear;
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle);
      W.RequestHeader(fAuthenticationToken, fRequestHandle,
        fBrowseTimeoutMs);
      if AContinuation then
      begin
        W.BooleanValue(False);
        W.Int32(ARequestParents.Count);
        for I := 0 to ARequestParents.Count - 1 do
        begin
          lParent := TOpcUaBrowseParent(ARequestParents[I]);
          W.ByteString(lParent.ContinuationPoint);
        end;
      end
      else
      begin
        W.NodeId('i=0'); W.UInt64(0); W.UInt32(0);
        W.UInt32(fMaxReferencesPerNode);
        W.Int32(ARequestParents.Count);
        for I := 0 to ARequestParents.Count - 1 do
        begin
          lParent := TOpcUaBrowseParent(ARequestParents[I]);
          W.NodeId(lParent.NodeId);
          W.UInt32(0);
          W.NodeId(COpcUaHierarchicalReferences);
          W.BooleanValue(True);
          W.UInt32(COpcUaNodeClassObject or COpcUaNodeClassVariable or
            COpcUaNodeClassMethod);
          W.UInt32(63);
        end;
      end;
    finally
      W.Free;
    end;
    if AContinuation then
      Result := ExchangeService(COpcUaBrowseNextRequest, B, R)
    else
      Result := ExchangeService(COpcUaBrowseRequest, B, R);
    if not Result then
    begin
      if ARequestParents.Count > 0 then
      begin
        lParent := TOpcUaBrowseParent(ARequestParents[0]);
        lErrorText := fErrorText;
        SetError('browse batch request', Format(
          'firstNodeId=%s path=%s count=%d; %s',
          [lParent.NodeId, lParent.BrowsePath, ARequestParents.Count,
           lErrorText]));
      end;
      Exit;
    end;
    Result := ProcessResponse(R, ARequestParents, AContinuationParents);
    R.Free;
    R := nil;
  end;

begin
  Result := False;
  if (AParents = nil) or (AParents.Count = 0) then Exit(True);
  if (ANodes = nil) or (ANextParents = nil) or (AVisited = nil) then Exit;
  B := TMemoryStream.Create;
  R := nil;
  lContinuations := TList.Create;
  lNextContinuations := TList.Create;
  try
    if not ExchangeBrowse(AParents, False, lContinuations) then Exit;
    while lContinuations.Count > 0 do
    begin
      lNextContinuations.Clear;
      if not ExchangeBrowse(lContinuations, True, lNextContinuations) then
        Exit;
      lContinuations.Clear;
      for I := 0 to lNextContinuations.Count - 1 do
        lContinuations.Add(lNextContinuations[I]);
    end;
    Result := True;
  finally
    R.Free;
    lNextContinuations.Free;
    lContinuations.Free;
    B.Free;
  end;
end;

function TRecorderOpcUaBinaryClient.Browse(ANodes: TObjectList;
  AMaxReferencesPerNode: Cardinal): Boolean;
const
  CBrowseNodesPerRequest = 2;
var
  J, lStart: Integer;
  lBrowseTimeoutMs: Cardinal;
  lPreviousBrowseTimeoutMs: Cardinal;
  lPreviousSocketTimeoutMs: Integer;
  lVisited: TStringList;
  lPendingParents, lNextParents, lSwapParents: TObjectList;
  lBrowseBatch: TList;
  lParent: TOpcUaBrowseParent;
begin
  Result := False;
  if ANodes = nil then Exit;
  if fStream = nil then
  begin
    SetError('browse', 'connection is not open');
    Exit;
  end;
  ANodes.Clear;
  lBrowseTimeoutMs := fConfiguredBrowseTimeoutMs;
  if lBrowseTimeoutMs < fRequestTimeoutMs then
    lBrowseTimeoutMs := fRequestTimeoutMs;
  if lBrowseTimeoutMs > Cardinal(High(Integer)) then
    lBrowseTimeoutMs := Cardinal(High(Integer));
  lPreviousBrowseTimeoutMs := fBrowseTimeoutMs;
  lPreviousSocketTimeoutMs := fStream.IOTimeout;
  fBrowseTimeoutMs := lBrowseTimeoutMs;
  fStream.IOTimeout := Integer(lBrowseTimeoutMs);
  fMaxReferencesPerNode := AMaxReferencesPerNode;
  if fMaxReferencesPerNode < 1 then fMaxReferencesPerNode := 1;
  lVisited := nil;
  lPendingParents := nil;
  lNextParents := nil;
  lBrowseBatch := nil;
  try
    lVisited := TStringList.Create;
    lVisited.CaseSensitive := True;
    lVisited.Sorted := True;
    lVisited.Duplicates := dupIgnore;
    lPendingParents := TObjectList.Create(True);
    lNextParents := TObjectList.Create(True);
    lBrowseBatch := TList.Create;
    lParent := TOpcUaBrowseParent.Create;
    lParent.NodeId := CRecorderOpcUaObjectsFolderNodeId;
    lParent.BrowsePath := 'Objects';
    lParent.Depth := 0;
    lPendingParents.Add(lParent);
    lVisited.Add(lParent.NodeId);
    try
      while lPendingParents.Count > 0 do
      begin
        lNextParents.Clear;
        lStart := 0;
        while lStart < lPendingParents.Count do
        begin
          lBrowseBatch.Clear;
          for J := lStart to Min(lStart + CBrowseNodesPerRequest - 1,
            lPendingParents.Count - 1) do
            lBrowseBatch.Add(lPendingParents[J]);
          if not BrowseParentBatch(lBrowseBatch, ANodes, lNextParents,
            lVisited) then Exit;
          Inc(lStart, CBrowseNodesPerRequest);
        end;
        lSwapParents := lPendingParents;
        lPendingParents := lNextParents;
        lNextParents := lSwapParents;
      end;
      Result := ReadVariableAttributesBatch(ANodes);
    except
      on E: Exception do SetError('browse', E.Message);
    end;
  finally
    if fStream <> nil then
      fStream.IOTimeout := lPreviousSocketTimeoutMs;
    fBrowseTimeoutMs := lPreviousBrowseTimeoutMs;
    lBrowseBatch.Free;
    lNextParents.Free;
    lPendingParents.Free;
    lVisited.Free;
  end;
end;

function TRecorderOpcUaBinaryClient.BrowseChildren(const ANodeId,
  ABrowsePath: string; ANodes: TObjectList;
  AMaxReferencesPerNode: Cardinal): Boolean;
var
  lBrowseTimeoutMs: Cardinal;
  lPreviousBrowseTimeoutMs: Cardinal;
  lPreviousSocketTimeoutMs: Integer;
  lVisited: TStringList;
  lParents, lChildren: TObjectList;
  lParentBatch: TList;
  lParent: TOpcUaBrowseParent;
begin
  Result := False;
  if (ANodes = nil) or (Trim(ANodeId) = '') then Exit;
  if fStream = nil then
  begin
    SetError('browse children', 'connection is not open');
    Exit;
  end;
  ANodes.Clear;
  lBrowseTimeoutMs := fConfiguredBrowseTimeoutMs;
  if lBrowseTimeoutMs < fRequestTimeoutMs then
    lBrowseTimeoutMs := fRequestTimeoutMs;
  if lBrowseTimeoutMs > Cardinal(High(Integer)) then
    lBrowseTimeoutMs := Cardinal(High(Integer));
  lPreviousBrowseTimeoutMs := fBrowseTimeoutMs;
  lPreviousSocketTimeoutMs := fStream.IOTimeout;
  fBrowseTimeoutMs := lBrowseTimeoutMs;
  fStream.IOTimeout := Integer(lBrowseTimeoutMs);
  fMaxReferencesPerNode := Max(1, AMaxReferencesPerNode);
  lVisited := TStringList.Create;
  lParents := TObjectList.Create(True);
  lChildren := TObjectList.Create(True);
  lParentBatch := TList.Create;
  try
    lVisited.CaseSensitive := True;
    lVisited.Sorted := True;
    lVisited.Duplicates := dupIgnore;
    lVisited.Add(ANodeId);
    lParent := TOpcUaBrowseParent.Create;
    lParent.NodeId := ANodeId;
    lParent.BrowsePath := ABrowsePath;
    lParent.Depth := 0;
    lParents.Add(lParent);
    lParentBatch.Add(lParent);
    try
      Result := BrowseParentBatch(lParentBatch, ANodes, lChildren, lVisited);
      if Result then Result := ReadVariableAttributesBatch(ANodes);
    except
      on E: Exception do SetError('browse children', E.Message);
    end;
  finally
    if fStream <> nil then
      fStream.IOTimeout := lPreviousSocketTimeoutMs;
    fBrowseTimeoutMs := lPreviousBrowseTimeoutMs;
    lParentBatch.Free;
    lChildren.Free;
    lParents.Free;
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

function OpcUaTimestampText(ATicks: QWord): string;
var
  lSeconds: Double;
begin
  if ATicks = 0 then Exit('');
  lSeconds := ATicks / COpcUaTicksPerSecond - COpcUaUnixEpochOffsetSeconds;
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',
    UnixToDateTime(Trunc(lSeconds), False) + Frac(lSeconds) / 86400.0);
end;

function ReadScalarDisplayText(Q: TOpcUaReader; ATypeId: Byte): string;
var
  lEncodedNodeId: TBytes;
  lLocalizedMask: Byte;
begin
  case ATypeId of
    1: if Q.BooleanValue then Result := 'True' else Result := 'False';
    2: Result := IntToStr(ShortInt(Q.ByteValue));
    3: Result := IntToStr(Q.ByteValue);
    4: Result := IntToStr(SmallInt(Q.UInt16));
    5: Result := IntToStr(Q.UInt16);
    6: Result := IntToStr(LongInt(Q.UInt32));
    7: Result := UIntToStr(Q.UInt32);
    8: Result := IntToStr(Int64(Q.UInt64));
    9: Result := UIntToStr(Q.UInt64);
    10: Result := FloatToStr(Q.SingleValue);
    11: Result := FloatToStr(Q.DoubleValue);
    12, 16: Result := Q.UaString;
    13: Result := IntToStr(Int64(Q.UInt64));
    14: begin Q.Raw(16); Result := '<Guid>'; end;
    15: begin Q.ByteString; Result := '<ByteString>'; end;
    17: Result := Q.NodeId(lEncodedNodeId);
    18: Result := Q.ExpandedNodeId;
    19: Result := '0x' + IntToHex(Q.UInt32, 8);
    20: begin Q.UInt16; Result := Q.UaString; end;
    21:
      begin
        Result := '';
        lLocalizedMask := Q.ByteValue;
        if (lLocalizedMask and 1) <> 0 then Q.UaString;
        if (lLocalizedMask and 2) <> 0 then Result := Q.UaString;
      end;
    22: begin Q.SkipExtensionObject; Result := '<Structure>'; end;
  else
    raise EOpcUaBinaryError.CreateFmt('Unsupported value type %d', [ATypeId]);
  end;
end;

function ReadDataValueDisplayText(Q: TOpcUaReader; out AValue,
  ATimestamp: string; AArrayValues: TStrings = nil): Boolean;
var
  lDataValueMask, lVariantMask, lTypeId: Byte;
  I, lCount, lDimensions: LongInt;
  lSourceTicks, lServerTicks: QWord;
begin
  Result := False;
  AValue := '';
  ATimestamp := '';
  if AArrayValues <> nil then AArrayValues.Clear;
  lDataValueMask := Q.ByteValue;
  if (lDataValueMask and 1) = 0 then
  begin
    if (lDataValueMask and 2) <> 0 then
      AValue := 'Status 0x' + IntToHex(Q.UInt32, 8);
    lSourceTicks := 0;
    lServerTicks := 0;
    if (lDataValueMask and 4) <> 0 then lSourceTicks := Q.UInt64;
    if (lDataValueMask and 8) <> 0 then lServerTicks := Q.UInt64;
    if (lDataValueMask and 16) <> 0 then Q.UInt16;
    if (lDataValueMask and 32) <> 0 then Q.UInt16;
    if lSourceTicks <> 0 then ATimestamp := OpcUaTimestampText(lSourceTicks)
    else if lServerTicks <> 0 then ATimestamp := OpcUaTimestampText(lServerTicks);
    Exit;
  end;
  lVariantMask := Q.ByteValue;
  if (lVariantMask and $80) <> 0 then
  begin
    lTypeId := lVariantMask and $3F;
    lCount := Q.Int32;
    if lCount < -1 then
      raise EOpcUaBinaryError.CreateFmt('Invalid array length %d', [lCount]);
    if lCount > 1000000 then
      raise EOpcUaBinaryError.CreateFmt('Array is too large: %d', [lCount]);
    for I := 0 to lCount - 1 do
      if AArrayValues <> nil then
        AArrayValues.Add(ReadScalarDisplayText(Q, lTypeId))
      else
        AValue := ReadScalarDisplayText(Q, lTypeId);
    if (lVariantMask and $40) <> 0 then
    begin
      lDimensions := Q.Int32;
      for I := 0 to lDimensions - 1 do Q.Int32;
    end;
    if lCount < 0 then AValue := '<null массив>'
    else AValue := Format('<массив: %d>', [lCount]);
  end;
  if (lVariantMask and $80) = 0 then
  begin
    lTypeId := lVariantMask and $3F;
    AValue := ReadScalarDisplayText(Q, lTypeId);
  end;
  if (lDataValueMask and 2) <> 0 then Q.UInt32;
  lSourceTicks := 0;
  lServerTicks := 0;
  if (lDataValueMask and 4) <> 0 then lSourceTicks := Q.UInt64;
  if (lDataValueMask and 8) <> 0 then lServerTicks := Q.UInt64;
  if (lDataValueMask and 16) <> 0 then Q.UInt16;
  if (lDataValueMask and 32) <> 0 then Q.UInt16;
  if lSourceTicks <> 0 then ATimestamp := OpcUaTimestampText(lSourceTicks)
  else if lServerTicks <> 0 then ATimestamp := OpcUaTimestampText(lServerTicks);
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
          Result := ReadDataValueDisplayText(Q, ANode.ValueText,
            ANode.ValueTimestamp, ANode.ArrayValues);
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
      W.RequestHeader(fAuthenticationToken, fRequestHandle,
        fBrowseTimeoutMs);
      W.DoubleValue(0);
      W.UInt32(0);
      W.Int32(6);
      W.NodeId(ANode.NodeId); W.UInt32(13); W.UaString('', True); W.UInt16(0); W.UaString('', True);
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
        if N <> 6 then
        begin
          SetError('attributes', 'unexpected variable attribute result count');
          Exit;
        end;
        ReadDataValueDisplayText(Q, ANode.ValueText, ANode.ValueTimestamp,
          ANode.ArrayValues);
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

function TRecorderOpcUaBinaryClient.ReadVariableAttributesBatch(
  ANodes: TObjectList): Boolean;
const
  CVariablesPerRequest = 8;
var
  I, J, lVariableCount, lStart, lChunkCount, lExpectedResults: Integer;
  lVariables: TList;
  lVariable: TRecorderOpcUaDiscoveredNode;
  B, R: TMemoryStream;
  W: TOpcUaWriter;
  Q: TOpcUaReader;
  D: TBytes;
  N: LongInt;
  lAttributeId: Cardinal;
  lAttributesOk: Boolean;
begin
  Result := False;
  if ANodes = nil then Exit;
  lVariables := TList.Create;
  try
    for I := 0 to ANodes.Count - 1 do
      if TRecorderOpcUaDiscoveredNode(ANodes[I]).NodeClass =
        COpcUaNodeClassVariable then
        lVariables.Add(ANodes[I]);
    lVariableCount := lVariables.Count;
    lStart := 0;
    while lStart < lVariableCount do
    begin
      lChunkCount := Min(CVariablesPerRequest, lVariableCount - lStart);
      lExpectedResults := lChunkCount * 6;
      B := TMemoryStream.Create;
      R := nil;
      try
        W := TOpcUaWriter.Create(B);
        try
          Inc(fRequestHandle);
          W.RequestHeader(fAuthenticationToken, fRequestHandle,
            fBrowseTimeoutMs);
          W.DoubleValue(0);
          W.UInt32(0);
          W.Int32(lExpectedResults);
          for I := 0 to lChunkCount - 1 do
          begin
            lVariable := TRecorderOpcUaDiscoveredNode(
              lVariables[lStart + I]);
            for J := 0 to 5 do
            begin
              case J of
                0: lAttributeId := 13;
                1: lAttributeId := 14;
                2: lAttributeId := 15;
                3: lAttributeId := 17;
                4: lAttributeId := 18;
              else
                lAttributeId := 20;
              end;
              W.NodeId(lVariable.NodeId);
              W.UInt32(lAttributeId);
              W.UaString('', True);
              W.UInt16(0);
              W.UaString('', True);
            end;
          end;
        finally
          W.Free;
        end;
        if not ExchangeService(COpcUaReadRequest, B, R) then
        begin
          SetError('browse attributes batch', Format(
            'firstNodeId=%s count=%d; %s',
            [TRecorderOpcUaDiscoveredNode(lVariables[lStart]).NodeId,
             lChunkCount, fErrorText]));
          Exit;
        end;
        try
          Q := TOpcUaReader.Create(R);
          try
            Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D);
            Q.ResponseHeader;
            N := Q.Int32;
            if N <> lExpectedResults then
            begin
              SetError('browse attributes batch', Format(
                'expected %d ReadResults, received %d',
                [lExpectedResults, N]));
              Exit;
            end;
            for I := 0 to lChunkCount - 1 do
            begin
              lVariable := TRecorderOpcUaDiscoveredNode(
                lVariables[lStart + I]);
              lAttributesOk := ReadDataValueDisplayText(Q,
                lVariable.ValueText, lVariable.ValueTimestamp,
                lVariable.ArrayValues);
              if not ReadDataValueNodeId(Q, lVariable.DataTypeNodeId) then
                lAttributesOk := False;
              lVariable.DataTypeName :=
                DataTypeDisplayName(lVariable.DataTypeNodeId);
              if not ReadDataValueInt32(Q, lVariable.ValueRank) then
                lAttributesOk := False;
              if not ReadDataValueByte(Q, lVariable.AccessLevel) then
                lAttributesOk := False;
              if not ReadDataValueByte(Q, lVariable.UserAccessLevel) then
                lAttributesOk := False;
              if not ReadDataValueBoolean(Q, lVariable.Historizing) then
                lAttributesOk := False;
              if not lAttributesOk then
                lVariable.DataTypeName := '<ошибка атрибутов>';
            end;
          finally
            Q.Free;
          end;
        finally
          R.Free;
        end;
      finally
        B.Free;
      end;
      Inc(lStart, lChunkCount);
    end;
    Result := True;
  finally
    lVariables.Free;
  end;
end;

function TRecorderOpcUaBinaryClient.ReadDoubles(
  const ANodeIds: TRecorderOpcUaStringArray;
  out AValues, ATimestampsSec: TRecorderOpcUaDoubleArray;
  out AStatuses: TRecorderOpcUaCardinalArray): Boolean;
var
  I: Integer;
  B, R: TMemoryStream;
  W: TOpcUaWriter;
  Q: TOpcUaReader;
  D: TBytes;
  Mask, VariantMask, TypeId: Byte;
  N: LongInt;
  SourceTicks, ServerTicks: QWord;
begin
  Result := False;
  SetLength(AValues, Length(ANodeIds));
  SetLength(ATimestampsSec, Length(ANodeIds));
  SetLength(AStatuses, Length(ANodeIds));
  if Length(ANodeIds) = 0 then Exit(True);
  R := nil;
  B := TMemoryStream.Create;
  try
    try
      W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle);
      W.RequestHeader(fAuthenticationToken, fRequestHandle, fRequestTimeoutMs);
      W.DoubleValue(0);
      W.UInt32(fTimestampsToReturn);
      W.Int32(Length(ANodeIds));
      for I := 0 to High(ANodeIds) do
      begin
        W.NodeId(ANodeIds[I]);
        W.UInt32(13);
        W.UaString('', True);
        W.UInt16(0);
        W.UaString('', True);
      end;
    finally
      W.Free;
    end;
    if not ExchangeService(COpcUaReadRequest, B, R) then Exit;
    Q := TOpcUaReader.Create(R);
    try
      Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D); Q.ResponseHeader;
      N := Q.Int32;
      if N <> Length(ANodeIds) then
      begin
        SetError('read', Format('server returned %d values for %d nodes',
          [N, Length(ANodeIds)]));
        Exit;
      end;
      for I := 0 to N - 1 do
      begin
        SourceTicks := 0;
        ServerTicks := 0;
        Mask := Q.ByteValue;
        if (Mask and 1) = 0 then
        begin
          if (Mask and 2) <> 0 then AStatuses[I] := Q.UInt32;
          SetError('read', Format('NodeId %s has no value; status 0x%.8x',
            [ANodeIds[I], AStatuses[I]]));
          Exit;
        end;
        VariantMask := Q.ByteValue;
        if (VariantMask and $80) <> 0 then
        begin
          SetError('read', 'array values are not supported for ' + ANodeIds[I]);
          Exit;
        end;
        TypeId := VariantMask and $3F;
        case TypeId of
          1: AValues[I] := Ord(Q.BooleanValue);
          2: AValues[I] := ShortInt(Q.ByteValue);
          3: AValues[I] := Q.ByteValue;
          4: AValues[I] := SmallInt(Q.UInt16);
          5: AValues[I] := Q.UInt16;
          6: AValues[I] := LongInt(Q.UInt32);
          7: AValues[I] := Q.UInt32;
          8: AValues[I] := Int64(Q.UInt64);
          9: AValues[I] := Q.UInt64;
          10: AValues[I] := Q.SingleValue;
          11: AValues[I] := Q.DoubleValue;
        else
          SetError('read', 'unsupported scalar type ' + IntToStr(TypeId) +
            ' for ' + ANodeIds[I]);
          Exit;
        end;
        if (Mask and 2) <> 0 then AStatuses[I] := Q.UInt32;
        if (Mask and 4) <> 0 then SourceTicks := Q.UInt64;
        if (Mask and 8) <> 0 then ServerTicks := Q.UInt64;
        if (Mask and 16) <> 0 then Q.UInt16;
        if (Mask and 32) <> 0 then Q.UInt16;
        if (AStatuses[I] and $80000000) <> 0 then
        begin
          SetError('read', Format('NodeId %s returned bad status 0x%.8x',
            [ANodeIds[I], AStatuses[I]]));
          Exit;
        end;
        ATimestampsSec[I] := OpcUaTimestampSeconds(fTimestampsToReturn,
          SourceTicks, ServerTicks);
      end;
      Result := True;
    finally
      Q.Free;
      end;
    except
      on E: Exception do SetError('read', E.Message);
    end;
  finally
    R.Free;
    B.Free;
  end;
end;

function TRecorderOpcUaBinaryClient.ReadStrings(
  const ANodeIds: TRecorderOpcUaStringArray;
  out AValues: TRecorderOpcUaStringArray;
  out ATimestampsSec: TRecorderOpcUaDoubleArray;
  out AStatuses: TRecorderOpcUaCardinalArray): Boolean;
var
  I: Integer;
  B, R: TMemoryStream;
  W: TOpcUaWriter;
  Q: TOpcUaReader;
  D: TBytes;
  N: LongInt;
  lChange: TRecorderOpcUaDataChange;
begin
  Result := False;
  SetLength(AValues, Length(ANodeIds));
  SetLength(ATimestampsSec, Length(ANodeIds));
  SetLength(AStatuses, Length(ANodeIds));
  if Length(ANodeIds) = 0 then Exit(True);
  R := nil;
  B := TMemoryStream.Create;
  try
    try
      W := TOpcUaWriter.Create(B);
      try
        Inc(fRequestHandle);
        W.RequestHeader(fAuthenticationToken, fRequestHandle,
          fRequestTimeoutMs);
        W.DoubleValue(0);
        W.UInt32(fTimestampsToReturn);
        W.Int32(Length(ANodeIds));
        for I := 0 to High(ANodeIds) do
        begin
          W.NodeId(ANodeIds[I]);
          W.UInt32(13);
          W.UaString('', True);
          W.UInt16(0);
          W.UaString('', True);
        end;
      finally
        W.Free;
      end;
      if not ExchangeService(COpcUaReadRequest, B, R) then Exit;
      Q := TOpcUaReader.Create(R);
      try
        Q.UInt32; Q.UInt32; Q.UInt32; Q.UInt32; Q.NodeId(D);
        Q.ResponseHeader;
        N := Q.Int32;
        if N <> Length(ANodeIds) then
        begin
          SetError('read strings', Format(
            'server returned %d values for %d nodes',
            [N, Length(ANodeIds)]));
          Exit;
        end;
        for I := 0 to N - 1 do
        begin
          FillChar(lChange, SizeOf(lChange), 0);
          if not ReadNotificationDataValue(Q, fTimestampsToReturn,
            @lChange) then
          begin
            AStatuses[I] := lChange.Status;
            SetError('read strings', Format(
              'NodeId %s has no value; status 0x%.8x',
              [ANodeIds[I], AStatuses[I]]));
            Exit;
          end;
          AStatuses[I] := lChange.Status;
          if (AStatuses[I] and $80000000) <> 0 then
          begin
            SetError('read strings', Format(
              'NodeId %s returned bad status 0x%.8x',
              [ANodeIds[I], AStatuses[I]]));
            Exit;
          end;
          if lChange.IsString then
            AValues[I] := lChange.StringValue
          else
            AValues[I] := FloatToStr(lChange.NumericValue);
          ATimestampsSec[I] := lChange.TimestampSec;
        end;
        Result := True;
      finally
        Q.Free;
      end;
    except
      on E: Exception do SetError('read strings', E.Message);
    end;
  finally
    R.Free;
    B.Free;
  end;
end;

function TRecorderOpcUaBinaryClient.ReadDouble(const ANodeId: string;
  out AValue: Double; out AStatus: Cardinal; out ATimestampSec: Double): Boolean;
var
  B, R: TMemoryStream;
  W: TOpcUaWriter;
  Q: TOpcUaReader;
  D: TBytes;
  Mask, VariantMask, TypeId: Byte;
  N: LongInt;
  SourceTicks, ServerTicks: QWord;
begin
  Result := False; AValue := 0; AStatus := 0; ATimestampSec := 0; B := TMemoryStream.Create;
  try
    W := TOpcUaWriter.Create(B);
    try
      Inc(fRequestHandle); W.RequestHeader(fAuthenticationToken, fRequestHandle);
      W.DoubleValue(0); W.UInt32(fTimestampsToReturn); W.Int32(1);
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
        SourceTicks := 0;
        ServerTicks := 0;
        if (Mask and 4) <> 0 then SourceTicks := Q.UInt64;
        if (Mask and 8) <> 0 then ServerTicks := Q.UInt64;
        if (Mask and 16) <> 0 then Q.UInt16;
        if (Mask and 32) <> 0 then Q.UInt16;
        ATimestampSec := OpcUaTimestampSeconds(fTimestampsToReturn,
          SourceTicks, ServerTicks);
        Result := True;
      finally Q.Free; R.Free; end;
    except
      on E: Exception do SetError('read', ANodeId + ': ' + E.Message);
    end;
  finally B.Free; end;
end;

function BuiltInDataTypeId(const ANodeId: string): Byte;
var
  lMarker: SizeInt;
begin
  lMarker := Pos('i=', LowerCase(Trim(ANodeId)));
  if lMarker = 0 then Exit(0);
  Result := Byte(StrToIntDef(Copy(ANodeId, lMarker + 2, MaxInt), 0));
  if Result > 11 then Result := 0;
end;

procedure WriteScalarVariant(AWriter: TOpcUaWriter; ATypeId: Byte;
  AValue: Double);
begin
  AWriter.ByteValue(ATypeId);
  case ATypeId of
    1: AWriter.BooleanValue(AValue <> 0);
    2: AWriter.ByteValue(Byte(ShortInt(Trunc(AValue))));
    3: AWriter.ByteValue(Byte(Trunc(AValue)));
    4: AWriter.UInt16(Word(SmallInt(Trunc(AValue))));
    5: AWriter.UInt16(Word(Trunc(AValue)));
    6: AWriter.Int32(LongInt(Trunc(AValue)));
    7: AWriter.UInt32(Cardinal(Trunc(AValue)));
    8: AWriter.UInt64(QWord(Int64(Trunc(AValue))));
    9: AWriter.UInt64(QWord(Trunc(AValue)));
    10: AWriter.SingleValue(Single(AValue));
    11: AWriter.DoubleValue(AValue);
  else
    raise EOpcUaBinaryError.CreateFmt(
      'unsupported writable scalar data type %d', [ATypeId]);
  end;
end;

function TRecorderOpcUaBinaryClient.WriteScalar(const ANodeId: string;
  var ADataTypeNodeId: string; AValue: Double): Boolean;
var
  lBody, lResponse: TMemoryStream;
  lWriter: TOpcUaWriter;
  lReader: TOpcUaReader;
  lEncodedNodeId: TBytes;
  lNode: TRecorderOpcUaDiscoveredNode;
  lResultCount: LongInt;
  lStatus: Cardinal;
  lTypeId: Byte;
begin
  Result := False;
  lResponse := nil;
  if Trim(ADataTypeNodeId) = '' then
  begin
    lNode := TRecorderOpcUaDiscoveredNode.Create;
    try
      lNode.NodeId := ANodeId;
      if not ReadVariableAttributes(lNode) then Exit;
      ADataTypeNodeId := lNode.DataTypeNodeId;
    finally
      lNode.Free;
    end;
  end;
  lTypeId := BuiltInDataTypeId(ADataTypeNodeId);
  if lTypeId = 0 then
  begin
    SetError('write', 'unsupported DataType ' + ADataTypeNodeId +
      ' for ' + ANodeId);
    Exit;
  end;
  lBody := TMemoryStream.Create;
  try
    try
      lWriter := TOpcUaWriter.Create(lBody);
      try
        Inc(fRequestHandle);
        lWriter.RequestHeader(fAuthenticationToken, fRequestHandle,
          fRequestTimeoutMs);
        lWriter.Int32(1);
        lWriter.NodeId(ANodeId);
        lWriter.UInt32(13);
        lWriter.UaString('', True);
        lWriter.ByteValue(1);
        WriteScalarVariant(lWriter, lTypeId, AValue);
      finally
        lWriter.Free;
      end;
      if not ExchangeService(COpcUaWriteRequest, lBody, lResponse) then Exit;
      lReader := TOpcUaReader.Create(lResponse);
      try
        lReader.UInt32;
        lReader.UInt32;
        lReader.UInt32;
        lReader.UInt32;
        lReader.NodeId(lEncodedNodeId);
        lReader.ResponseHeader;
        lResultCount := lReader.Int32;
        if lResultCount < 1 then
        begin
          SetError('write', 'server returned no StatusCode for ' + ANodeId);
          Exit;
        end;
        lStatus := lReader.UInt32;
        if lStatus <> 0 then
        begin
          SetError('write', Format('NodeId %s returned status 0x%.8x',
            [ANodeId, lStatus]));
          Exit;
        end;
        Result := True;
      finally
        lReader.Free;
      end;
    except
      on E: Exception do
        SetError('write', ANodeId + ': ' + E.Message);
    end;
  finally
    lResponse.Free;
    lBody.Free;
  end;
end;

function TRecorderOpcUaBinaryClient.WriteScalars(
  const ANodeIds: TRecorderOpcUaStringArray;
  var ADataTypeNodeIds: TRecorderOpcUaStringArray;
  const AValues: TRecorderOpcUaDoubleArray): Boolean;
var
  I: Integer;
  lBody, lResponse: TMemoryStream;
  lWriter: TOpcUaWriter;
  lReader: TOpcUaReader;
  lEncodedNodeId: TBytes;
  lNode: TRecorderOpcUaDiscoveredNode;
  lResultCount: LongInt;
  lStatus: Cardinal;
  lTypeId: Byte;
begin
  Result := False;
  lResponse := nil;
  if (Length(ANodeIds) = 0) or
    (Length(ADataTypeNodeIds) <> Length(ANodeIds)) or
    (Length(AValues) <> Length(ANodeIds)) then
  begin
    SetError('write', 'invalid batch dimensions');
    Exit;
  end;
  for I := 0 to High(ANodeIds) do
  begin
    if Trim(ADataTypeNodeIds[I]) = '' then
    begin
      lNode := TRecorderOpcUaDiscoveredNode.Create;
      try
        lNode.NodeId := ANodeIds[I];
        if not ReadVariableAttributes(lNode) then Exit;
        ADataTypeNodeIds[I] := lNode.DataTypeNodeId;
      finally
        lNode.Free;
      end;
    end;
    if BuiltInDataTypeId(ADataTypeNodeIds[I]) = 0 then
    begin
      SetError('write', 'unsupported DataType ' + ADataTypeNodeIds[I] +
        ' for ' + ANodeIds[I]);
      Exit;
    end;
  end;
  lBody := TMemoryStream.Create;
  try
    try
      lWriter := TOpcUaWriter.Create(lBody);
      try
        Inc(fRequestHandle);
        lWriter.RequestHeader(fAuthenticationToken, fRequestHandle,
          fRequestTimeoutMs);
        lWriter.Int32(Length(ANodeIds));
        for I := 0 to High(ANodeIds) do
        begin
          lWriter.NodeId(ANodeIds[I]);
          lWriter.UInt32(13);
          lWriter.UaString('', True);
          lWriter.ByteValue(1);
          lTypeId := BuiltInDataTypeId(ADataTypeNodeIds[I]);
          WriteScalarVariant(lWriter, lTypeId, AValues[I]);
        end;
      finally
        lWriter.Free;
      end;
      if not ExchangeService(COpcUaWriteRequest, lBody, lResponse) then Exit;
      lReader := TOpcUaReader.Create(lResponse);
      try
        lReader.UInt32;
        lReader.UInt32;
        lReader.UInt32;
        lReader.UInt32;
        lReader.NodeId(lEncodedNodeId);
        lReader.ResponseHeader;
        lResultCount := lReader.Int32;
        if lResultCount <> Length(ANodeIds) then
        begin
          SetError('write', Format('server returned %d StatusCodes for %d values',
            [lResultCount, Length(ANodeIds)]));
          Exit;
        end;
        for I := 0 to lResultCount - 1 do
        begin
          lStatus := lReader.UInt32;
          if lStatus <> 0 then
          begin
            SetError('write', Format('NodeId %s returned status 0x%.8x',
              [ANodeIds[I], lStatus]));
            Exit;
          end;
        end;
        Result := True;
      finally
        lReader.Free;
      end;
    except
      on E: Exception do SetError('write', 'batch: ' + E.Message);
    end;
  finally
    lResponse.Free;
    lBody.Free;
  end;
end;

end.
