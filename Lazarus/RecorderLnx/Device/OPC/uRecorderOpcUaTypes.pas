unit uRecorderOpcUaTypes;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Contnrs, fpjson, jsonparser;

const
  CRecorderOpcUaModuleType = 'OPC UA';
  CRecorderOpcUaSourcePrefix = 'OPC UA: ';
  CRecorderOpcUaDefaultEndpoint = 'opc.tcp://localhost:4840';
  CRecorderOpcUaDefaultPublishingIntervalMs = 100;
  CRecorderOpcUaDefaultSessionTimeoutMs = 15000;

type
  TRecorderOpcUaMode = (oumClient, oumServer);
  TRecorderOpcUaAuthenticationMode = (ouamAnonymous, ouamUserPassword);

  TRecorderOpcUaNode = class
  public
    NodeId: string;
    TagName: string;
    Readable: Boolean;
    Writable: Boolean;
  end;

  TRecorderOpcUaConfig = class
  private
    fNodes: TObjectList;
  public
    Mode: TRecorderOpcUaMode;
    AuthenticationMode: TRecorderOpcUaAuthenticationMode;
    Endpoint: string;
    UserName: string;
    PasswordEnvironment: string;
    PublishingIntervalMs: Cardinal;
    SessionTimeoutMs: Cardinal;
    SimplifiedTree: Boolean;
    constructor Create;
    destructor Destroy; override;
    function AddNode(const ANodeId, ATagName: string;
      AWritable: Boolean = False; AReadable: Boolean = True): TRecorderOpcUaNode;
    function ToJson: string;
    function LoadJson(const AText: string; out AError: string): Boolean;
    property Nodes: TObjectList read fNodes;
  end;

function RecorderOpcUaSourceId(const AEndpoint: string;
  AMode: TRecorderOpcUaMode): string;
function RecorderIsOpcUaSource(const ASourceId, AModuleType: string): Boolean;

implementation

constructor TRecorderOpcUaConfig.Create;
begin
  inherited Create;
  fNodes := TObjectList.Create(True);
  Mode := oumClient;
  AuthenticationMode := ouamAnonymous;
  Endpoint := CRecorderOpcUaDefaultEndpoint;
  PublishingIntervalMs := CRecorderOpcUaDefaultPublishingIntervalMs;
  SessionTimeoutMs := CRecorderOpcUaDefaultSessionTimeoutMs;
  SimplifiedTree := True;
end;

destructor TRecorderOpcUaConfig.Destroy;
begin
  fNodes.Free;
  inherited Destroy;
end;

function TRecorderOpcUaConfig.AddNode(const ANodeId, ATagName: string;
  AWritable: Boolean; AReadable: Boolean): TRecorderOpcUaNode;
begin
  Result := TRecorderOpcUaNode.Create;
  Result.NodeId := Trim(ANodeId);
  Result.TagName := Trim(ATagName);
  Result.Readable := AReadable;
  Result.Writable := AWritable;
  fNodes.Add(Result);
end;

function TRecorderOpcUaConfig.ToJson: string;
var
  I: Integer;
  lArray: TJSONArray;
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
    if AuthenticationMode = ouamUserPassword then
      lRoot.Add('authentication', 'userPassword')
    else
      lRoot.Add('authentication', 'anonymous');
    lRoot.Add('userName', UserName);
    lRoot.Add('passwordEnv', PasswordEnvironment);
    lRoot.Add('publishingIntervalMs', Integer(PublishingIntervalMs));
    lRoot.Add('sessionTimeoutMs', Integer(SessionTimeoutMs));
    lRoot.Add('simplifiedTree', SimplifiedTree);
    lArray := TJSONArray.Create;
    lRoot.Add('nodes', lArray);
    for I := 0 to fNodes.Count - 1 do
    begin
      lNode := TRecorderOpcUaNode(fNodes[I]);
      lObject := TJSONObject.Create;
      lObject.Add('nodeId', lNode.NodeId);
      lObject.Add('tagName', lNode.TagName);
      lObject.Add('readable', lNode.Readable);
      lObject.Add('writable', lNode.Writable);
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
  lNodes: TJSONArray;
begin
  Result := False;
  AError := '';
  fNodes.Clear;
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
      SimplifiedTree := lRoot.Get('simplifiedTree', True);
      if lRoot.Find('nodes', lNodes) and (lNodes is TJSONArray) then
        for I := 0 to lNodes.Count - 1 do
          if lNodes.Items[I] is TJSONObject then
          begin
            lItem := TJSONObject(lNodes.Items[I]);
            if Trim(lItem.Get('nodeId', '')) <> '' then
              AddNode(lItem.Get('nodeId', ''), lItem.Get('tagName', ''),
                lItem.Get('writable', False), lItem.Get('readable', True));
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

end.
