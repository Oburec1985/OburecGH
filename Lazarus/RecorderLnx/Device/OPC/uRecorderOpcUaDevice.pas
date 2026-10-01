unit uRecorderOpcUaDevice;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Variants, Math, uRecorderDeviceInterfaces,
  uRecorderOpcUaTypes, uRecorderOpcUaApi;

type
  { Protocol/session layer. It owns the Pascal protocol handle and knows nothing about
    Recorder tags or the data-source worker. }
  TRecorderOpcUaDevice = class(TRecorderDevice)
  private
    fConfig: TRecorderOpcUaConfig;
    fHandle: TRecorderOpcUaHandle;
    fLastError: string;
    fConfigValid: Boolean;
    fNodeIndexes: array of Integer;
    fNodesConfigured: Boolean;
    procedure CloseSession;
    procedure Fail(const AStage, AText: string);
  protected
    function GetChannels: TRecorderDeviceChannelArray; override;
  public
    constructor Create(const ADeviceId, AConfigText: string);
    destructor Destroy; override;
    procedure Connect; override;
    procedure InitializeDevice; override;
    procedure ConfigureDevice; override;
    procedure Start; override;
    procedure Stop; override;
    procedure Disconnect; override;
    function TestLink(out AErrorText: string): Boolean; override;
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant; override;
    function Iterate: Boolean;
    function ReadChanged(AIndex: Integer; out AValue,
      ATimestampSec: Double; out AQuality: Cardinal): Boolean;
    function WriteClientValue(AIndex: Integer; AValue: Double): Boolean;
    function WriteClientValues(const AIndexes: TRecorderOpcUaIntegerArray;
      const AValues: TRecorderOpcUaDoubleArray): Boolean;
    function ConfigureServerNode(AIndex: Integer; const ATagName: string;
      AInitialValue: Double): Boolean;
    function WriteServerValue(AIndex: Integer; AValue: Double): Boolean;
    function NodeCount: Integer;
    function Node(AIndex: Integer): TRecorderOpcUaNode;
    property Config: TRecorderOpcUaConfig read fConfig;
    property LastError: string read fLastError;
  end;

implementation

uses
  uRecorderDebugLog;

constructor TRecorderOpcUaDevice.Create(const ADeviceId,
  AConfigText: string);
var
  lError: string;
begin
  inherited Create(ADeviceId, 'OPC UA');
  fConfig := TRecorderOpcUaConfig.Create;
  fConfigValid := fConfig.LoadJson(AConfigText, lError);
  if not fConfigValid then
    fLastError := 'configuration: ' + lError;
  fChannelCount := fConfig.Nodes.Count;
  fUpdateTimeMs := fConfig.PublishingIntervalMs;
  if fConfig.PublishingIntervalMs > 0 then
    fPollFrequencyHz := 1000.0 / fConfig.PublishingIntervalMs;
end;

destructor TRecorderOpcUaDevice.Destroy;
begin
  CloseSession;
  fConfig.Free;
  inherited Destroy;
end;

procedure TRecorderOpcUaDevice.Fail(const AStage, AText: string);
begin
  fLastError := AStage + ': ' + AText;
  RecorderDebugLog(Format('[OPC UA] source=%s endpoint=%s stage=%s error=%s',
    [DeviceId, fConfig.Endpoint, AStage, AText]));
end;

procedure TRecorderOpcUaDevice.CloseSession;
begin
  if fHandle <> nil then
    if fConfig.Mode = oumServer then
      RecorderOpcUaServerDestroy(fHandle)
    else
      RecorderOpcUaClientDestroy(fHandle);
  fHandle := nil;
  fNodesConfigured := False;
  SetLength(fNodeIndexes, 0);
  fState := rdsDisconnected;
end;

procedure TRecorderOpcUaDevice.Connect;
var
  lError: string;
begin
  if fState <> rdsDisconnected then Exit;
  if not fConfigValid then
  begin
    RecorderDebugLog('[OPC UA] source=' + DeviceId + ' ' + fLastError);
    Exit;
  end;
  fLastError := '';
  if not RecorderOpcUaLoad(lError) then
  begin
    Fail('connect', lError);
    Exit;
  end;
  if fConfig.Mode = oumServer then
    fHandle := RecorderOpcUaServerCreate(fConfig.Endpoint)
  else
    if fConfig.AuthenticationMode = ouamUserPassword then
      fHandle := RecorderOpcUaClientCreate(fConfig.Endpoint, fConfig.UserName,
        GetEnvironmentVariable(fConfig.PasswordEnvironment),
        fConfig.PublishingIntervalMs, fConfig.SessionTimeoutMs,
        fConfig.RequestTimeoutMs, Ord(fConfig.TimestampMode))
    else
      fHandle := RecorderOpcUaClientCreate(fConfig.Endpoint, '', '',
        fConfig.PublishingIntervalMs, fConfig.SessionTimeoutMs,
        fConfig.RequestTimeoutMs, Ord(fConfig.TimestampMode));
  if fHandle = nil then
  begin
    Fail('connect', 'cannot create OPC UA session');
    Exit;
  end;
  fState := rdsConnected;
end;

procedure TRecorderOpcUaDevice.InitializeDevice;
begin
  { The pure Pascal client performs the protocol handshake in Start.
    This explicit lifecycle stage validates that the session object exists. }
  if fState = rdsDisconnected then
    Fail('initialize', 'session is not connected');
end;

procedure TRecorderOpcUaDevice.ConfigureDevice;
var
  I: Integer;
begin
  if fState = rdsDisconnected then
  begin
    Fail('configure', 'session is not connected');
    Exit;
  end;
  if fNodesConfigured then
  begin
    fState := rdsProgrammed;
    Exit;
  end;
  SetLength(fNodeIndexes, fConfig.Nodes.Count);
  for I := 0 to fConfig.Nodes.Count - 1 do
  begin
    if fConfig.Mode = oumServer then
      { Server variables are added later by the source, when the initial tag
        values are known. Keep an explicit slot for every configured node. }
      fNodeIndexes[I] := -1
    else
      fNodeIndexes[I] := RecorderOpcUaClientAddNode(fHandle,
        Node(I).NodeId, Node(I).Readable, Node(I).Writable,
        Node(I).DataTypeNodeId);
    if (fConfig.Mode = oumClient) and (fNodeIndexes[I] < 0) then
    begin
      Fail('configure', RecorderOpcUaLastError(fHandle));
      Exit;
    end;
  end;
  fNodesConfigured := True;
  fState := rdsProgrammed;
end;

procedure TRecorderOpcUaDevice.Start;
var
  lOk: Boolean;
begin
  if fState <> rdsProgrammed then
  begin
    Fail('start', 'device is not configured');
    Exit;
  end;
  if fConfig.Mode = oumServer then
    lOk := RecorderOpcUaServerStart(fHandle)
  else
    lOk := RecorderOpcUaClientConnect(fHandle);
  if not lOk then
  begin
    Fail('start', RecorderOpcUaLastError(fHandle));
    Exit;
  end;
  fState := rdsStarted;
end;

procedure TRecorderOpcUaDevice.Stop;
begin
  { Closing the transport here guarantees a clean secure channel and session
    on the next Start. }
  CloseSession;
end;

procedure TRecorderOpcUaDevice.Disconnect;
begin
  CloseSession;
end;

function TRecorderOpcUaDevice.TestLink(out AErrorText: string): Boolean;
begin
  AErrorText := fLastError;
  Result := fState <> rdsDisconnected;
end;

function TRecorderOpcUaDevice.GetDeviceProperty(
  AProperty: TRecorderDeviceProperty; AIndex: Integer): Variant;
begin
  case AProperty of
    rdpHost: Result := fConfig.Endpoint;
    rdpUpdateTimeMs: Result := fConfig.PublishingIntervalMs;
    rdpChannelCount: Result := fConfig.Nodes.Count;
    rdpErrorCode: Result := Ord(fLastError <> '');
    rdpErrorText: Result := fLastError;
  else
    Result := inherited GetDeviceProperty(AProperty, AIndex);
  end;
end;

function TRecorderOpcUaDevice.GetChannels: TRecorderDeviceChannelArray;
var
  I: Integer;
begin
  SetLength(Result, fConfig.Nodes.Count);
  for I := 0 to High(Result) do
  begin
    Result[I].Name := Node(I).TagName;
    if Result[I].Name = '' then Result[I].Name := Node(I).NodeId;
    Result[I].Address := Node(I).NodeId;
    Result[I].ModuleType := CRecorderOpcUaModuleType;
    Result[I].PollFrequencyHz := fPollFrequencyHz;
    Result[I].Enabled := True;
  end;
end;

function TRecorderOpcUaDevice.Iterate: Boolean;
begin
  Result := fState = rdsStarted;
  if not Result then Exit;
  if fConfig.Mode = oumServer then
    Result := RecorderOpcUaServerIterate(fHandle, False)
  else
    Result := RecorderOpcUaClientIterate(fHandle, 0,
      Min(fConfig.MaxNodesPerRead, CRecorderOpcUaDefaultMaxNodesPerRequest));
  if not Result then Fail('iterate', RecorderOpcUaLastError(fHandle));
end;

function TRecorderOpcUaDevice.ReadChanged(AIndex: Integer; out AValue,
  ATimestampSec: Double; out AQuality: Cardinal): Boolean;
begin
  Result := (fConfig.Mode = oumClient) and (AIndex >= 0) and
    (AIndex < Length(fNodeIndexes)) and
    RecorderOpcUaClientReadChanged(fHandle, fNodeIndexes[AIndex], AValue,
      ATimestampSec, AQuality);
end;

function TRecorderOpcUaDevice.WriteClientValue(AIndex: Integer;
  AValue: Double): Boolean;
begin
  Result := (fConfig.Mode = oumClient) and (AIndex >= 0) and
    (AIndex < Length(fNodeIndexes)) and
    RecorderOpcUaClientWrite(fHandle, fNodeIndexes[AIndex], AValue);
  if not Result then
    Fail('write', RecorderOpcUaLastError(fHandle));
end;

function TRecorderOpcUaDevice.WriteClientValues(
  const AIndexes: TRecorderOpcUaIntegerArray;
  const AValues: TRecorderOpcUaDoubleArray): Boolean;
var
  I: Integer;
  lHandleIndexes: TRecorderOpcUaIntegerArray;
begin
  Result := (fConfig.Mode = oumClient) and
    (Length(AIndexes) > 0) and (Length(AIndexes) = Length(AValues));
  if not Result then Exit;
  SetLength(lHandleIndexes, Length(AIndexes));
  for I := 0 to High(AIndexes) do
  begin
    if (AIndexes[I] < 0) or (AIndexes[I] >= Length(fNodeIndexes)) then
      Exit(False);
    lHandleIndexes[I] := fNodeIndexes[AIndexes[I]];
  end;
  Result := RecorderOpcUaClientWriteBatch(fHandle, lHandleIndexes, AValues);
  if not Result then
    Fail('write batch', RecorderOpcUaLastError(fHandle));
end;

function TRecorderOpcUaDevice.ConfigureServerNode(AIndex: Integer;
  const ATagName: string; AInitialValue: Double): Boolean;
var
  lNode: TRecorderOpcUaNode;
begin
  Result := False;
  if (fConfig.Mode <> oumServer) or (AIndex < 0) or
    (AIndex >= Length(fNodeIndexes)) or (fHandle = nil) then
    Exit;
  lNode := Node(AIndex);
  fNodeIndexes[AIndex] := RecorderOpcUaServerAddVariable(fHandle,
    lNode.NodeId, ATagName, AInitialValue, lNode.Writable);
  Result := fNodeIndexes[AIndex] >= 0;
  if not Result then
    Fail('configure', RecorderOpcUaLastError(fHandle));
end;

function TRecorderOpcUaDevice.WriteServerValue(AIndex: Integer;
  AValue: Double): Boolean;
begin
  Result := (fConfig.Mode = oumServer) and (AIndex >= 0) and
    (AIndex < Length(fNodeIndexes)) and (fNodeIndexes[AIndex] >= 0) and
    RecorderOpcUaServerWrite(fHandle, fNodeIndexes[AIndex], AValue);
end;

function TRecorderOpcUaDevice.NodeCount: Integer;
begin
  Result := fConfig.Nodes.Count;
end;

function TRecorderOpcUaDevice.Node(AIndex: Integer): TRecorderOpcUaNode;
begin
  Result := TRecorderOpcUaNode(fConfig.Nodes[AIndex]);
end;

end.
