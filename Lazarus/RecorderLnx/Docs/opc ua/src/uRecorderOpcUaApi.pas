unit uRecorderOpcUaApi;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

type
  TRecorderOpcUaHandle = Pointer;

function RecorderOpcUaLoad(out AError: string): Boolean;
procedure RecorderOpcUaUnload;
function RecorderOpcUaLastError(AHandle: TRecorderOpcUaHandle): string;
function RecorderOpcUaClientCreate(const AEndpoint, AUserName,
  APassword: string; APublishingIntervalMs, ASessionTimeoutMs: Cardinal): TRecorderOpcUaHandle;
function RecorderOpcUaClientAddNode(AHandle: TRecorderOpcUaHandle;
  const ANodeId: string; AReadable: Boolean = True): Integer;
function RecorderOpcUaClientConnect(AHandle: TRecorderOpcUaHandle): Boolean;
function RecorderOpcUaClientBrowse(AHandle: TRecorderOpcUaHandle;
  ALines: TStrings): Boolean;
function RecorderOpcUaClientIterate(AHandle: TRecorderOpcUaHandle;
  ATimeoutMs: Cardinal): Boolean;
function RecorderOpcUaClientReadChanged(AHandle: TRecorderOpcUaHandle;
  AIndex: Integer; out AValue, ATimestampSec: Double;
  out AQuality: Cardinal): Boolean;
procedure RecorderOpcUaClientDestroy(AHandle: TRecorderOpcUaHandle);

function RecorderOpcUaServerCreate(const AEndpoint: string): TRecorderOpcUaHandle;
function RecorderOpcUaServerAddVariable(AHandle: TRecorderOpcUaHandle;
  const ANodeId, ADisplayName: string; AInitialValue: Double;
  AWritable: Boolean): Integer;
function RecorderOpcUaServerStart(AHandle: TRecorderOpcUaHandle): Boolean;
function RecorderOpcUaServerIterate(AHandle: TRecorderOpcUaHandle;
  AWaitInternal: Boolean): Boolean;
function RecorderOpcUaServerWrite(AHandle: TRecorderOpcUaHandle;
  AIndex: Integer; AValue: Double): Boolean;
procedure RecorderOpcUaServerDestroy(AHandle: TRecorderOpcUaHandle);

implementation

uses
  Contnrs, Math, uRecorderOpcUaBinaryClient;

type
  TRecorderOpcUaHandleBase = class
  public
    ErrorText: string;
  end;

  TRecorderOpcUaClientHandle = class(TRecorderOpcUaHandleBase)
  public
    Client: TRecorderOpcUaBinaryClient;
    NodeIds: TStringList;
    Readable: array of Boolean;
    Values: array of Double;
    Times: array of Double;
    Qualities: array of Cardinal;
    Changed: array of Boolean;
    HasValues: array of Boolean;
    constructor Create(const AEndpoint, AUserName, APassword: string;
      ASessionTimeoutMs: Cardinal);
    destructor Destroy; override;
  end;

  TRecorderOpcUaServerHandle = class(TRecorderOpcUaHandleBase)
  end;

constructor TRecorderOpcUaClientHandle.Create(const AEndpoint, AUserName,
  APassword: string; ASessionTimeoutMs: Cardinal);
begin
  inherited Create;
  Client := TRecorderOpcUaBinaryClient.Create(AEndpoint, AUserName, APassword,
    ASessionTimeoutMs);
  NodeIds := TStringList.Create;
end;

destructor TRecorderOpcUaClientHandle.Destroy;
begin
  Client.Free;
  NodeIds.Free;
  inherited Destroy;
end;

function RecorderOpcUaLoad(out AError: string): Boolean;
begin
  AError := '';
  Result := True;
end;

procedure RecorderOpcUaUnload;
begin
end;

function RecorderOpcUaLastError(AHandle: TRecorderOpcUaHandle): string;
begin
  if AHandle = nil then Exit('invalid OPC UA handle');
  Result := TRecorderOpcUaHandleBase(AHandle).ErrorText;
end;

function RecorderOpcUaClientCreate(const AEndpoint, AUserName,
  APassword: string; APublishingIntervalMs,
  ASessionTimeoutMs: Cardinal): TRecorderOpcUaHandle;
begin
  Result := TRecorderOpcUaClientHandle.Create(AEndpoint, AUserName, APassword,
    ASessionTimeoutMs);
  if APublishingIntervalMs = 0 then
    TRecorderOpcUaClientHandle(Result).ErrorText :=
      'Publishing interval must be greater than zero';
end;

function RecorderOpcUaClientAddNode(AHandle: TRecorderOpcUaHandle;
  const ANodeId: string; AReadable: Boolean): Integer;
var
  lHandle: TRecorderOpcUaClientHandle;
begin
  Result := -1;
  if AHandle = nil then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  Result := lHandle.NodeIds.Add(Trim(ANodeId));
  SetLength(lHandle.Values, lHandle.NodeIds.Count);
  SetLength(lHandle.Times, lHandle.NodeIds.Count);
  SetLength(lHandle.Qualities, lHandle.NodeIds.Count);
  SetLength(lHandle.Changed, lHandle.NodeIds.Count);
  SetLength(lHandle.HasValues, lHandle.NodeIds.Count);
  SetLength(lHandle.Readable, lHandle.NodeIds.Count);
  lHandle.Readable[Result] := AReadable;
end;

function RecorderOpcUaClientConnect(AHandle: TRecorderOpcUaHandle): Boolean;
var lHandle: TRecorderOpcUaClientHandle;
begin
  Result := False;
  if AHandle = nil then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  Result := lHandle.Client.Connect;
  lHandle.ErrorText := lHandle.Client.ErrorText;
end;

function RecorderOpcUaClientBrowse(AHandle: TRecorderOpcUaHandle;
  ALines: TStrings): Boolean;
var
  I: Integer;
  lHandle: TRecorderOpcUaClientHandle;
  lNode: TRecorderOpcUaDiscoveredNode;
  lNodes: TObjectList;
begin
  Result := False;
  if (AHandle = nil) or (ALines = nil) then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  lNodes := TObjectList.Create(True);
  try
    Result := lHandle.Client.Browse(lNodes);
    lHandle.ErrorText := lHandle.Client.ErrorText;
    if not Result then Exit;
    ALines.BeginUpdate;
    try
      ALines.Clear;
      for I := 0 to lNodes.Count - 1 do
      begin
        lNode := TRecorderOpcUaDiscoveredNode(lNodes[I]);
        ALines.Add(lNode.NodeId + #9 + lNode.DisplayName + #9 +
          lNode.BrowsePath + #9 + lNode.TypeDefinition + #9 +
          IntToStr(lNode.AccessLevel) + #9 + IntToStr(lNode.UserAccessLevel) +
          #9 + lNode.DataTypeNodeId + #9 + lNode.DataTypeName + #9 +
          StringReplace(StringReplace(StringReplace(lNode.ValueText, #9, ' ',
          [rfReplaceAll]), #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll]) +
          #9 + IntToStr(lNode.ValueRank) + #9 +
          BoolToStr(lNode.Historizing, True) + #9 +
          BoolToStr(lNode.CanHistoryRead, True) + #9 +
          BoolToStr(lNode.CanHistoryWrite, True));
      end;
    finally
      ALines.EndUpdate;
    end;
  finally
    lNodes.Free;
  end;
end;

function RecorderOpcUaClientIterate(AHandle: TRecorderOpcUaHandle;
  ATimeoutMs: Cardinal): Boolean;
var
  I: Integer;
  lHandle: TRecorderOpcUaClientHandle;
  lQuality: Cardinal;
  lTime, lValue: Double;
begin
  Result := False;
  if AHandle = nil then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  for I := 0 to lHandle.NodeIds.Count - 1 do
  begin
    if not lHandle.Readable[I] then Continue;
    if not lHandle.Client.ReadDouble(lHandle.NodeIds[I], lValue,
      lQuality, lTime) then
    begin
      lHandle.ErrorText := lHandle.Client.ErrorText;
      if lHandle.ErrorText = '' then
        lHandle.ErrorText := 'Read failed for NodeId ' + lHandle.NodeIds[I];
      Exit;
    end;
    lHandle.Changed[I] := (not lHandle.HasValues[I]) or
      (not SameValue(lHandle.Values[I], lValue)) or
      (lHandle.Times[I] <> lTime);
    lHandle.Values[I] := lValue;
    lHandle.Times[I] := lTime;
    lHandle.Qualities[I] := lQuality;
    lHandle.HasValues[I] := True;
  end;
  if ATimeoutMs > 0 then Sleep(Min(ATimeoutMs, 10));
  Result := True;
end;

function RecorderOpcUaClientReadChanged(AHandle: TRecorderOpcUaHandle;
  AIndex: Integer; out AValue, ATimestampSec: Double;
  out AQuality: Cardinal): Boolean;
var lHandle: TRecorderOpcUaClientHandle;
begin
  Result := False;
  if AHandle = nil then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  if (AIndex < 0) or (AIndex >= Length(lHandle.Changed)) or
    not lHandle.Changed[AIndex] then Exit;
  AValue := lHandle.Values[AIndex];
  ATimestampSec := lHandle.Times[AIndex];
  AQuality := lHandle.Qualities[AIndex];
  lHandle.Changed[AIndex] := False;
  Result := True;
end;

procedure RecorderOpcUaClientDestroy(AHandle: TRecorderOpcUaHandle);
begin
  if AHandle <> nil then TRecorderOpcUaClientHandle(AHandle).Free;
end;

function RecorderOpcUaServerCreate(const AEndpoint: string): TRecorderOpcUaHandle;
begin
  Result := TRecorderOpcUaServerHandle.Create;
  TRecorderOpcUaServerHandle(Result).ErrorText :=
    'Pure Pascal OPC UA server is not implemented yet: ' + AEndpoint;
end;

function RecorderOpcUaServerAddVariable(AHandle: TRecorderOpcUaHandle;
  const ANodeId, ADisplayName: string; AInitialValue: Double;
  AWritable: Boolean): Integer;
begin Result := -1; end;

function RecorderOpcUaServerStart(AHandle: TRecorderOpcUaHandle): Boolean;
begin Result := False; end;

function RecorderOpcUaServerIterate(AHandle: TRecorderOpcUaHandle;
  AWaitInternal: Boolean): Boolean;
begin Result := False; end;

function RecorderOpcUaServerWrite(AHandle: TRecorderOpcUaHandle;
  AIndex: Integer; AValue: Double): Boolean;
begin Result := False; end;

procedure RecorderOpcUaServerDestroy(AHandle: TRecorderOpcUaHandle);
begin if AHandle <> nil then TRecorderOpcUaServerHandle(AHandle).Free; end;

end.
