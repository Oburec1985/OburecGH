unit uRecorderOpcUaTypes;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, fpjson, jsonparser, uRecorderMessages;

const
  CRecorderOpcUaModuleType = 'OPC UA';
  CRecorderOpcUaSourcePrefix = 'OPC UA: ';
  CRecorderOpcUaDefaultEndpoint = 'opc.tcp://localhost:4840';
  CRecorderOpcUaDefaultPublishingIntervalMs = 100;
  CRecorderOpcUaDefaultSessionTimeoutMs = 15000;
  CRecorderOpcUaDefaultRequestTimeoutMs = 10000;
  CRecorderOpcUaMinimumBrowseTimeoutMs = 30000;
  CRecorderOpcUaDefaultBrowseTimeoutMs = 180000;
  CRecorderOpcUaDefaultMaxNodesPerRequest = 100;
  CRecorderOpcUaMdnsGroupIPv4 = '224.0.0.251';
  CRecorderOpcUaMdnsPort = 5353;
  CRecorderOpcUaMdnsServiceName = '_opcua-tcp._tcp.local';
  CRecorderOpcUaDiscoveryTimeoutMs = 2500;
  CRecorderOpcUaDnsTypeA = 1;
  CRecorderOpcUaDnsTypePtr = 12;
  CRecorderOpcUaDnsTypeTxt = 16;
  CRecorderOpcUaDnsTypeSrv = 33;
  CRecorderOpcUaDnsClassIn = 1;
  CRecorderOpcUaIpProtocol = 0;
  {$ifdef windows}
  { Winsock2 IP_ADD_MEMBERSHIP from ws2ipdef.h (FPC's old winsock2.pp
    declares the legacy Winsock 1 value, which fails on modern UDP sockets). }
  CRecorderOpcUaIpAddMembership = 12;
  {$else}
  {$ifdef linux}
  CRecorderOpcUaIpAddMembership = 35;
  {$else}
  CRecorderOpcUaIpAddMembership = 12;
  {$endif}
  {$endif}
  { OPC UA standard Objects folder (namespace 0, numeric NodeId 85). }
  CRecorderOpcUaObjectsFolderNodeId = 'i=85';
  CRecorderOpcUaObjectsFolderBrowsePath = 'Objects';

type
  TRecorderOpcUaMode = (oumClient, oumServer);
  TRecorderOpcUaAuthenticationMode = (ouamAnonymous, ouamUserPassword);
  TRecorderOpcUaTimestampMode = (outSource, outServer, outBoth, outNeither);
  TRecorderOpcUaPollingType = (ouptRead, ouptSubscription);
  TRecorderOpcUaNodeRole = (ounrAuto, ounrTag, ounrMessage);

  TRecorderOpcUaNode = class
  public
    NodeId: string;
    TagName: string;
    RecorderTagId: Int64;
    DataTypeNodeId: string;
    ValueRank: Integer;
    Readable: Boolean;
    Writable: Boolean;
    Role: TRecorderOpcUaNodeRole;
    MessageKind: TRecorderMessageKind;
    MessageColor: LongInt;
  end;

  TRecorderOpcUaConfig = class
  private
    fBrowseCache: TStringList;
    fNodes: TObjectList;
  public
    Mode: TRecorderOpcUaMode;
    AuthenticationMode: TRecorderOpcUaAuthenticationMode;
    Endpoint: string;
    BrowseCacheEndpoint: string;
    UserName: string;
    PasswordEnvironment: string;
    PublishingIntervalMs: Cardinal;
    SessionTimeoutMs: Cardinal;
    RequestTimeoutMs: Cardinal;
    BrowseTimeoutMs: Cardinal;
    MaxNodesPerRead: Cardinal;
    MaxNodesPerWrite: Cardinal;
    MaxNodesPerBrowse: Cardinal;
    TimestampMode: TRecorderOpcUaTimestampMode;
    PollingType: TRecorderOpcUaPollingType;
    ArchiveEnabled: Boolean;
    ArchiveRecordsPerPoll: Cardinal;
    ArchiveDepthDays: Cardinal;
    ArchivePollingRate: Cardinal;
    ShowAdditionalSettings: Boolean;
    SimplifiedTree: Boolean;
    constructor Create;
    destructor Destroy; override;
    function AddNode(const ANodeId, ATagName: string;
      AWritable: Boolean = False; AReadable: Boolean = True;
      const ADataTypeNodeId: string = ''; AValueRank: Integer = -1):
      TRecorderOpcUaNode;
    function ToJson: string;
    function LoadJson(const AText: string; out AError: string): Boolean;
    property Nodes: TObjectList read fNodes;
    property BrowseCache: TStringList read fBrowseCache;
  end;

function RecorderOpcUaSourceId(const AEndpoint: string;
  AMode: TRecorderOpcUaMode): string;
function RecorderIsOpcUaSource(const ASourceId, AModuleType: string): Boolean;
function RecorderOpcUaNodeIsMessage(ANode: TRecorderOpcUaNode): Boolean;

implementation

constructor TRecorderOpcUaConfig.Create;
begin
  inherited Create;
  fBrowseCache := TStringList.Create;
  fNodes := TObjectList.Create(True);
  Mode := oumClient;
  AuthenticationMode := ouamAnonymous;
  Endpoint := CRecorderOpcUaDefaultEndpoint;
  BrowseCacheEndpoint := Endpoint;
  PublishingIntervalMs := CRecorderOpcUaDefaultPublishingIntervalMs;
  SessionTimeoutMs := CRecorderOpcUaDefaultSessionTimeoutMs;
  RequestTimeoutMs := CRecorderOpcUaDefaultRequestTimeoutMs;
  BrowseTimeoutMs := CRecorderOpcUaDefaultBrowseTimeoutMs;
  MaxNodesPerRead := CRecorderOpcUaDefaultMaxNodesPerRequest;
  MaxNodesPerWrite := CRecorderOpcUaDefaultMaxNodesPerRequest;
  MaxNodesPerBrowse := CRecorderOpcUaDefaultMaxNodesPerRequest;
  TimestampMode := outServer;
  PollingType := ouptRead;
  ArchiveEnabled := True;
  ArchiveRecordsPerPoll := 500;
  ArchiveDepthDays := 1;
  ArchivePollingRate := 1;
  ShowAdditionalSettings := True;
  SimplifiedTree := True;
end;

destructor TRecorderOpcUaConfig.Destroy;
begin
  fBrowseCache.Free;
  fNodes.Free;
  inherited Destroy;
end;

function TRecorderOpcUaConfig.AddNode(const ANodeId, ATagName: string;
  AWritable: Boolean; AReadable: Boolean;
  const ADataTypeNodeId: string; AValueRank: Integer): TRecorderOpcUaNode;
begin
  Result := TRecorderOpcUaNode.Create;
  Result.NodeId := Trim(ANodeId);
  Result.TagName := Trim(ATagName);
  Result.RecorderTagId := 0;
  Result.DataTypeNodeId := Trim(ADataTypeNodeId);
  Result.ValueRank := AValueRank;
  Result.Readable := AReadable;
  Result.Writable := AWritable;
  Result.Role := ounrAuto;
  Result.MessageKind := rmkInformation;
  Result.MessageColor := -1;
  fNodes.Add(Result);
end;

function TRecorderOpcUaConfig.ToJson: string;
var
  I: Integer;
  lArray, lBrowseArray: TJSONArray;
  lNode: TRecorderOpcUaNode;
  lObject, lRoot: TJSONObject;
begin
  lRoot := TJSONObject.Create;
  try
    if Mode = oumServer then
      lRoot.Add('mode', 'server')
    else
      lRoot.Add('mode', 'client');
    lRoot.Add('endpoint', Endpoint);
    lRoot.Add('browseCacheEndpoint', BrowseCacheEndpoint);
    if AuthenticationMode = ouamUserPassword then
      lRoot.Add('authentication', 'userPassword')
    else
      lRoot.Add('authentication', 'anonymous');
    lRoot.Add('userName', UserName);
    lRoot.Add('passwordEnv', PasswordEnvironment);
    lRoot.Add('publishingIntervalMs', Integer(PublishingIntervalMs));
    lRoot.Add('sessionTimeoutMs', Integer(SessionTimeoutMs));
    lRoot.Add('requestTimeoutMs', Integer(RequestTimeoutMs));
    lRoot.Add('browseTimeoutMs', Integer(BrowseTimeoutMs));
    lRoot.Add('maxNodesPerRead', Integer(MaxNodesPerRead));
    lRoot.Add('maxNodesPerWrite', Integer(MaxNodesPerWrite));
    lRoot.Add('maxNodesPerBrowse', Integer(MaxNodesPerBrowse));
    case TimestampMode of
      outSource: lRoot.Add('timestampMode', 'source');
      outBoth: lRoot.Add('timestampMode', 'both');
      outNeither: lRoot.Add('timestampMode', 'neither');
    else
      lRoot.Add('timestampMode', 'server');
    end;
    if PollingType = ouptSubscription then
      lRoot.Add('pollingType', 'subscription')
    else
      lRoot.Add('pollingType', 'read');
    lRoot.Add('archiveEnabled', ArchiveEnabled);
    lRoot.Add('archiveRecordsPerPoll', Integer(ArchiveRecordsPerPoll));
    lRoot.Add('archiveDepthDays', Integer(ArchiveDepthDays));
    lRoot.Add('archivePollingRate', Integer(ArchivePollingRate));
    lRoot.Add('showAdditionalSettings', ShowAdditionalSettings);
    lRoot.Add('simplifiedTree', SimplifiedTree);
    lBrowseArray := TJSONArray.Create;
    lRoot.Add('browseCache', lBrowseArray);
    for I := 0 to fBrowseCache.Count - 1 do
      lBrowseArray.Add(fBrowseCache[I]);
    lArray := TJSONArray.Create;
    lRoot.Add('nodes', lArray);
    for I := 0 to fNodes.Count - 1 do
    begin
      lNode := TRecorderOpcUaNode(fNodes[I]);
      lObject := TJSONObject.Create;
      lObject.Add('nodeId', lNode.NodeId);
      lObject.Add('tagName', lNode.TagName);
      lObject.Add('recorderTagId', lNode.RecorderTagId);
      lObject.Add('dataTypeNodeId', lNode.DataTypeNodeId);
      lObject.Add('valueRank', lNode.ValueRank);
      lObject.Add('readable', lNode.Readable);
      lObject.Add('writable', lNode.Writable);
      case lNode.Role of
        ounrTag: lObject.Add('role', 'tag');
        ounrMessage: lObject.Add('role', 'message');
      else
        lObject.Add('role', 'auto');
      end;
      lObject.Add('messageKind', RecorderMessageKindName(lNode.MessageKind));
      lObject.Add('messageColor', lNode.MessageColor);
      lArray.Add(lObject);
    end;
    Result := lRoot.AsJSON;
  finally
    lRoot.Free;
  end;
end;

function TRecorderOpcUaConfig.LoadJson(const AText: string;
  out AError: string): Boolean;
var
  I: Integer;
  lData: TJSONData;
  lItem, lRoot: TJSONObject;
  lNodes, lBrowseCache: TJSONArray;
begin
  Result := False;
  AError := '';
  fNodes.Clear;
  fBrowseCache.Clear;
  try
    lData := GetJSON(AText);
    try
      if not (lData is TJSONObject) then
      begin
        AError := 'OPC UA configuration must be a JSON object';
        Exit;
      end;
      lRoot := TJSONObject(lData);
      if SameText(lRoot.Get('mode', 'client'), 'server') then
        Mode := oumServer
      else
        Mode := oumClient;
      Endpoint := Trim(lRoot.Get('endpoint', CRecorderOpcUaDefaultEndpoint));
      { Older snapshots did not store their source endpoint. Treat their
        Browse cache as untrusted; the editor will discard it rather than
        showing a tree that may belong to another device. }
      BrowseCacheEndpoint := Trim(lRoot.Get('browseCacheEndpoint', ''));
      UserName := lRoot.Get('userName', '');
      PasswordEnvironment := lRoot.Get('passwordEnv', '');
      if SameText(lRoot.Get('authentication', ''), 'userPassword') or
        ((lRoot.Find('authentication') = nil) and
         ((Trim(UserName) <> '') or (Trim(PasswordEnvironment) <> ''))) then
        AuthenticationMode := ouamUserPassword
      else
        AuthenticationMode := ouamAnonymous;
      PublishingIntervalMs := Cardinal(lRoot.Get('publishingIntervalMs',
        CRecorderOpcUaDefaultPublishingIntervalMs));
      if PublishingIntervalMs < 10 then
        PublishingIntervalMs := 10;
      SessionTimeoutMs := Cardinal(lRoot.Get('sessionTimeoutMs',
        CRecorderOpcUaDefaultSessionTimeoutMs));
      if SessionTimeoutMs < 1000 then
        SessionTimeoutMs := 1000;
      RequestTimeoutMs := Cardinal(lRoot.Get('requestTimeoutMs',
        CRecorderOpcUaDefaultRequestTimeoutMs));
      if RequestTimeoutMs < 100 then RequestTimeoutMs := 100;
      BrowseTimeoutMs := Cardinal(lRoot.Get('browseTimeoutMs',
        CRecorderOpcUaDefaultBrowseTimeoutMs));
      if BrowseTimeoutMs < CRecorderOpcUaMinimumBrowseTimeoutMs then
        BrowseTimeoutMs := CRecorderOpcUaMinimumBrowseTimeoutMs;
      if BrowseTimeoutMs > 86400000 then BrowseTimeoutMs := 86400000;
      MaxNodesPerRead := Cardinal(lRoot.Get('maxNodesPerRead',
        CRecorderOpcUaDefaultMaxNodesPerRequest));
      MaxNodesPerWrite := Cardinal(lRoot.Get('maxNodesPerWrite',
        CRecorderOpcUaDefaultMaxNodesPerRequest));
      MaxNodesPerBrowse := Cardinal(lRoot.Get('maxNodesPerBrowse',
        CRecorderOpcUaDefaultMaxNodesPerRequest));
      if MaxNodesPerRead < 1 then MaxNodesPerRead := 1;
      if MaxNodesPerWrite < 1 then MaxNodesPerWrite := 1;
      if MaxNodesPerBrowse < 1 then MaxNodesPerBrowse := 1;
      if SameText(lRoot.Get('timestampMode', 'server'), 'source') then
        TimestampMode := outSource
      else if SameText(lRoot.Get('timestampMode', 'server'), 'both') then
        TimestampMode := outBoth
      else if SameText(lRoot.Get('timestampMode', 'server'), 'neither') then
        TimestampMode := outNeither
      else
        TimestampMode := outServer;
      if SameText(lRoot.Get('pollingType', 'read'), 'subscription') then
        PollingType := ouptSubscription
      else
        PollingType := ouptRead;
      ArchiveEnabled := lRoot.Get('archiveEnabled', True);
      ArchiveRecordsPerPoll := Cardinal(lRoot.Get('archiveRecordsPerPoll', 500));
      ArchiveDepthDays := Cardinal(lRoot.Get('archiveDepthDays', 1));
      ArchivePollingRate := Cardinal(lRoot.Get('archivePollingRate', 1));
      ShowAdditionalSettings := lRoot.Get('showAdditionalSettings', True);
      SimplifiedTree := lRoot.Get('simplifiedTree', True);
      if lRoot.Find('browseCache', lBrowseCache) and
        (lBrowseCache is TJSONArray) then
        for I := 0 to lBrowseCache.Count - 1 do
          fBrowseCache.Add(lBrowseCache.Strings[I]);
      if lRoot.Find('nodes', lNodes) and (lNodes is TJSONArray) then
        for I := 0 to lNodes.Count - 1 do
          if lNodes.Items[I] is TJSONObject then
          begin
            lItem := TJSONObject(lNodes.Items[I]);
            if Trim(lItem.Get('nodeId', '')) <> '' then
            begin
              AddNode(lItem.Get('nodeId', ''), lItem.Get('tagName', ''),
                lItem.Get('writable', False), lItem.Get('readable', True),
                lItem.Get('dataTypeNodeId', ''), lItem.Get('valueRank', -1));
              TRecorderOpcUaNode(fNodes[fNodes.Count - 1]).RecorderTagId :=
                lItem.Get('recorderTagId', Int64(0));
              if SameText(lItem.Get('role', 'auto'), 'tag') then
                TRecorderOpcUaNode(fNodes[fNodes.Count - 1]).Role := ounrTag
              else if SameText(lItem.Get('role', 'auto'), 'message') then
                TRecorderOpcUaNode(fNodes[fNodes.Count - 1]).Role := ounrMessage;
              TRecorderOpcUaNode(fNodes[fNodes.Count - 1]).MessageKind :=
                RecorderMessageKindFromName(lItem.Get('messageKind',
                'information'));
              TRecorderOpcUaNode(fNodes[fNodes.Count - 1]).MessageColor :=
                lItem.Get('messageColor', -1);
            end;
          end;
      if Endpoint = '' then
      begin
        AError := 'OPC UA endpoint is empty';
        Exit;
      end;
      Result := True;
    finally
      lData.Free;
    end;
  except
    on E: Exception do
      AError := E.Message;
  end;
end;

function RecorderOpcUaSourceId(const AEndpoint: string;
  AMode: TRecorderOpcUaMode): string;
begin
  if AMode = oumServer then
    Result := CRecorderOpcUaSourcePrefix + 'server ' + Trim(AEndpoint)
  else
    Result := CRecorderOpcUaSourcePrefix + 'client ' + Trim(AEndpoint);
end;

function RecorderIsOpcUaSource(const ASourceId, AModuleType: string): Boolean;
begin
  Result := SameText(Trim(AModuleType), CRecorderOpcUaModuleType) or
    (Pos(CRecorderOpcUaSourcePrefix, Trim(ASourceId)) = 1);
end;

function RecorderOpcUaNodeIsMessage(ANode: TRecorderOpcUaNode): Boolean;
var
  lTypeId, lNamespace: string;
  lPos, lId: Integer;
begin
  if ANode = nil then Exit(False);
  if ANode.Role = ounrMessage then Exit(True);
  { Arrays and non-numeric built-in/custom values have no lossless scalar
    RecorderTag representation; route them through the string message model. }
  if ANode.ValueRank <> -1 then Exit(True);
  lTypeId := Trim(ANode.DataTypeNodeId);
  if lTypeId = '' then Exit(False);
  lNamespace := '';
  if Pos('ns=', LowerCase(lTypeId)) = 1 then
  begin
    lPos := Pos(';', lTypeId);
    if lPos = 0 then Exit(True);
    lNamespace := Copy(lTypeId, 1, lPos - 1);
    Delete(lTypeId, 1, lPos);
  end;
  if lNamespace <> '' then
    if not SameText(lNamespace, 'ns=0') then Exit(True);
  if Pos('i=', LowerCase(lTypeId)) <> 1 then Exit(True);
  lId := StrToIntDef(Copy(lTypeId, 3, MaxInt), -1);
  Result := (lId < 1) or (lId > 11);
end;

end.
