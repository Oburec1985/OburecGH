unit uRecorderOpcUaApi;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

type
  TRecorderOpcUaHandle = Pointer;
  TRecorderOpcUaIntegerArray = array of Integer;
  TRecorderOpcUaDoubleArray = array of Double;
  TRecorderOpcUaStringArray = array of string;

function RecorderOpcUaLoad(out AError: string): Boolean;
procedure RecorderOpcUaUnload;
function RecorderOpcUaLastError(AHandle: TRecorderOpcUaHandle): string;
function RecorderOpcUaClientCreate(const AEndpoint, AUserName,
  APassword: string; APublishingIntervalMs, ASessionTimeoutMs: Cardinal;
  ARequestTimeoutMs: Cardinal = 4000;
  ATimestampsToReturn: Cardinal = 1): TRecorderOpcUaHandle;
function RecorderOpcUaClientAddNode(AHandle: TRecorderOpcUaHandle;
  const ANodeId: string; AReadable: Boolean = True;
  AWritable: Boolean = False; const ADataTypeNodeId: string = ''): Integer;
function RecorderOpcUaClientConnect(AHandle: TRecorderOpcUaHandle): Boolean;
function RecorderOpcUaClientBrowse(AHandle: TRecorderOpcUaHandle;
  ALines: TStrings; AMaxReferencesPerNode: Cardinal = 100): Boolean;
function RecorderOpcUaClientIterate(AHandle: TRecorderOpcUaHandle;
  ATimeoutMs: Cardinal; AMaxNodesPerRead: Cardinal = 100): Boolean;
function RecorderOpcUaClientReadChanged(AHandle: TRecorderOpcUaHandle;
  AIndex: Integer; out AValue, ATimestampSec: Double;
  out AQuality: Cardinal): Boolean;
function RecorderOpcUaClientReadMessageChanged(AHandle: TRecorderOpcUaHandle;
  AIndex: Integer; out AValue: string; out ATimestampSec: Double;
  out AQuality: Cardinal): Boolean;
function RecorderOpcUaClientWrite(AHandle: TRecorderOpcUaHandle;
  AIndex: Integer; AValue: Double): Boolean;
function RecorderOpcUaClientWriteBatch(AHandle: TRecorderOpcUaHandle;
  const AIndexes: TRecorderOpcUaIntegerArray;
  const AValues: TRecorderOpcUaDoubleArray): Boolean;
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
  TRecorderOpcUaStringMatrix = array of
    uRecorderOpcUaBinaryClient.TRecorderOpcUaStringArray;

  TRecorderOpcUaHandleBase = class
  public
    ErrorText: string;
  end;

  TRecorderOpcUaClientHandle = class(TRecorderOpcUaHandleBase)
  public
    Client: TRecorderOpcUaBinaryClient;
    NodeIds: TStringList;
    Readable: array of Boolean;
    Writable: array of Boolean;
    DataTypeNodeIds: array of string;
    IsStringNode: array of Boolean;
    Values: array of Double;
    StringValues: array of string;
    Times: array of Double;
    Qualities: array of Cardinal;
    Changed: array of Boolean;
    HasValues: array of Boolean;
    NumericNodeIds: uRecorderOpcUaBinaryClient.TRecorderOpcUaStringArray;
    NumericIndexes: TRecorderOpcUaIntegerArray;
    StringNodeIds: uRecorderOpcUaBinaryClient.TRecorderOpcUaStringArray;
    StringIndexes: TRecorderOpcUaIntegerArray;
    NumericChunks: TRecorderOpcUaStringMatrix;
    StringChunks: TRecorderOpcUaStringMatrix;
    ChunkSize: Cardinal;
    constructor Create(const AEndpoint, AUserName, APassword: string;
      ASessionTimeoutMs, ARequestTimeoutMs,
      ATimestampsToReturn: Cardinal);
    destructor Destroy; override;
  end;

  TRecorderOpcUaServerHandle = class(TRecorderOpcUaHandleBase)
  end;

constructor TRecorderOpcUaClientHandle.Create(const AEndpoint, AUserName,
  APassword: string; ASessionTimeoutMs, ARequestTimeoutMs,
  ATimestampsToReturn: Cardinal);
begin
  inherited Create;
  Client := TRecorderOpcUaBinaryClient.Create(AEndpoint, AUserName, APassword,
    ASessionTimeoutMs, ARequestTimeoutMs, ATimestampsToReturn);
  NodeIds := TStringList.Create;
end;

procedure BuildReadChunks(const ANodeIds:
  uRecorderOpcUaBinaryClient.TRecorderOpcUaStringArray; AChunkSize: Integer;
  out AChunks: TRecorderOpcUaStringMatrix);
var
  I, J, lCount, lStart: Integer;
begin
  if Length(ANodeIds) = 0 then
  begin
    SetLength(AChunks, 0);
    Exit;
  end;
  lCount := (Length(ANodeIds) + AChunkSize - 1) div AChunkSize;
  SetLength(AChunks, lCount);
  for I := 0 to lCount - 1 do
  begin
    lStart := I * AChunkSize;
    SetLength(AChunks[I], Min(AChunkSize, Length(ANodeIds) - lStart));
    for J := 0 to High(AChunks[I]) do
      AChunks[I][J] := ANodeIds[lStart + J];
  end;
end;

function IsStringDataType(const ANodeId: string): Boolean;
begin
  Result := SameText(Trim(ANodeId), 'i=12') or
    SameText(Trim(ANodeId), 'ns=0;i=12');
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
  ASessionTimeoutMs, ARequestTimeoutMs,
  ATimestampsToReturn: Cardinal): TRecorderOpcUaHandle;
begin
  Result := TRecorderOpcUaClientHandle.Create(AEndpoint, AUserName, APassword,
    ASessionTimeoutMs, ARequestTimeoutMs, ATimestampsToReturn);
  if APublishingIntervalMs = 0 then
    TRecorderOpcUaClientHandle(Result).ErrorText :=
      'Publishing interval must be greater than zero';
end;

function RecorderOpcUaClientAddNode(AHandle: TRecorderOpcUaHandle;
  const ANodeId: string; AReadable: Boolean; AWritable: Boolean;
  const ADataTypeNodeId: string): Integer;
var
  lHandle: TRecorderOpcUaClientHandle;
begin
  Result := -1;
  if AHandle = nil then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  lHandle.ChunkSize := 0;
  Result := lHandle.NodeIds.Add(Trim(ANodeId));
  SetLength(lHandle.Values, lHandle.NodeIds.Count);
  SetLength(lHandle.StringValues, lHandle.NodeIds.Count);
  SetLength(lHandle.Times, lHandle.NodeIds.Count);
  SetLength(lHandle.Qualities, lHandle.NodeIds.Count);
  SetLength(lHandle.Changed, lHandle.NodeIds.Count);
  SetLength(lHandle.HasValues, lHandle.NodeIds.Count);
  SetLength(lHandle.Readable, lHandle.NodeIds.Count);
  SetLength(lHandle.Writable, lHandle.NodeIds.Count);
  SetLength(lHandle.DataTypeNodeIds, lHandle.NodeIds.Count);
  SetLength(lHandle.IsStringNode, lHandle.NodeIds.Count);
  lHandle.Readable[Result] := AReadable;
  lHandle.Writable[Result] := AWritable;
  lHandle.DataTypeNodeIds[Result] := Trim(ADataTypeNodeId);
  lHandle.IsStringNode[Result] := IsStringDataType(ADataTypeNodeId);
  if not AReadable then Exit;
  if lHandle.IsStringNode[Result] then
  begin
    SetLength(lHandle.StringNodeIds, Length(lHandle.StringNodeIds) + 1);
    SetLength(lHandle.StringIndexes, Length(lHandle.StringIndexes) + 1);
    lHandle.StringNodeIds[High(lHandle.StringNodeIds)] := Trim(ANodeId);
    lHandle.StringIndexes[High(lHandle.StringIndexes)] := Result;
  end
  else
  begin
    SetLength(lHandle.NumericNodeIds, Length(lHandle.NumericNodeIds) + 1);
    SetLength(lHandle.NumericIndexes, Length(lHandle.NumericIndexes) + 1);
    lHandle.NumericNodeIds[High(lHandle.NumericNodeIds)] := Trim(ANodeId);
    lHandle.NumericIndexes[High(lHandle.NumericIndexes)] := Result;
  end;
end;

function RecorderOpcUaClientWrite(AHandle: TRecorderOpcUaHandle;
  AIndex: Integer; AValue: Double): Boolean;
var
  lHandle: TRecorderOpcUaClientHandle;
begin
  Result := False;
  if AHandle = nil then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  if (AIndex < 0) or (AIndex >= lHandle.NodeIds.Count) then
  begin
    lHandle.ErrorText := 'Invalid OPC UA node index for write';
    Exit;
  end;
  if not lHandle.Writable[AIndex] then
  begin
    lHandle.ErrorText := 'Node is not configured as writable: ' +
      lHandle.NodeIds[AIndex];
    Exit;
  end;
  Result := lHandle.Client.WriteScalar(lHandle.NodeIds[AIndex],
    lHandle.DataTypeNodeIds[AIndex], AValue);
  lHandle.ErrorText := lHandle.Client.ErrorText;
end;

function RecorderOpcUaClientWriteBatch(AHandle: TRecorderOpcUaHandle;
  const AIndexes: TRecorderOpcUaIntegerArray;
  const AValues: TRecorderOpcUaDoubleArray): Boolean;
var
  I: Integer;
  lHandle: TRecorderOpcUaClientHandle;
  lNodeIds, lDataTypes: TRecorderOpcUaStringArray;
  lBatchValues: uRecorderOpcUaBinaryClient.TRecorderOpcUaDoubleArray;
begin
  Result := False;
  if AHandle = nil then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  if (Length(AIndexes) = 0) or (Length(AIndexes) <> Length(AValues)) then
  begin
    lHandle.ErrorText := 'Invalid OPC UA write batch dimensions';
    Exit;
  end;
  SetLength(lNodeIds, Length(AIndexes));
  SetLength(lDataTypes, Length(AIndexes));
  SetLength(lBatchValues, Length(AIndexes));
  for I := 0 to High(AIndexes) do
  begin
    if (AIndexes[I] < 0) or (AIndexes[I] >= lHandle.NodeIds.Count) then
    begin
      lHandle.ErrorText := 'Invalid OPC UA node index for batch write';
      Exit;
    end;
    if not lHandle.Writable[AIndexes[I]] then
    begin
      lHandle.ErrorText := 'Node is not configured as writable: ' +
        lHandle.NodeIds[AIndexes[I]];
      Exit;
    end;
    lNodeIds[I] := lHandle.NodeIds[AIndexes[I]];
    lDataTypes[I] := lHandle.DataTypeNodeIds[AIndexes[I]];
    lBatchValues[I] := AValues[I];
  end;
  Result := lHandle.Client.WriteScalars(lNodeIds, lDataTypes, lBatchValues);
  for I := 0 to High(AIndexes) do
    lHandle.DataTypeNodeIds[AIndexes[I]] := lDataTypes[I];
  lHandle.ErrorText := lHandle.Client.ErrorText;
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
  ALines: TStrings; AMaxReferencesPerNode: Cardinal): Boolean;
var
  I, J: Integer;
  lHandle: TRecorderOpcUaClientHandle;
  lNode: TRecorderOpcUaDiscoveredNode;
  lNodes: TObjectList;
begin
  Result := False;
  if (AHandle = nil) or (ALines = nil) then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  lNodes := TObjectList.Create(True);
  try
    Result := lHandle.Client.Browse(lNodes, AMaxReferencesPerNode);
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
          BoolToStr(lNode.CanHistoryWrite, True) + #9 +
          IntToStr(lNode.NodeClass) + #9 + lNode.ValueTimestamp + #9 +
          IntToStr(lNode.ArrayValues.Count));
        for J := 0 to lNode.ArrayValues.Count - 1 do
          ALines[ALines.Count - 1] := ALines[ALines.Count - 1] + #9 +
            StringReplace(StringReplace(StringReplace(lNode.ArrayValues[J],
            #9, ' ', [rfReplaceAll]), #13, ' ', [rfReplaceAll]), #10, ' ',
            [rfReplaceAll]);
      end;
    finally
      ALines.EndUpdate;
    end;
  finally
    lNodes.Free;
  end;
end;

function RecorderOpcUaClientIterate(AHandle: TRecorderOpcUaHandle;
  ATimeoutMs: Cardinal; AMaxNodesPerRead: Cardinal): Boolean;
var
  I, J, lStart, lChunkCount, lIndex: Integer;
  lHandle: TRecorderOpcUaClientHandle;
  lValues, lTimes: uRecorderOpcUaBinaryClient.TRecorderOpcUaDoubleArray;
  lStringValues: uRecorderOpcUaBinaryClient.TRecorderOpcUaStringArray;
  lQualities: TRecorderOpcUaCardinalArray;
begin
  Result := False;
  if AHandle = nil then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  if AMaxNodesPerRead < 1 then AMaxNodesPerRead := 1;
  if lHandle.ChunkSize <> AMaxNodesPerRead then
  begin
    BuildReadChunks(lHandle.NumericNodeIds, AMaxNodesPerRead,
      lHandle.NumericChunks);
    BuildReadChunks(lHandle.StringNodeIds, AMaxNodesPerRead,
      lHandle.StringChunks);
    lHandle.ChunkSize := AMaxNodesPerRead;
  end;
  lStart := 0;
  for I := 0 to High(lHandle.NumericChunks) do
  begin
    lChunkCount := Length(lHandle.NumericChunks[I]);
    if not lHandle.Client.ReadDoubles(lHandle.NumericChunks[I],
      lValues, lTimes, lQualities) then
    begin
      lHandle.ErrorText := lHandle.Client.ErrorText;
      if lHandle.ErrorText = '' then
        lHandle.ErrorText := 'OPC UA batch read failed';
      Exit;
    end;
    for J := 0 to lChunkCount - 1 do
    begin
      lIndex := lHandle.NumericIndexes[lStart + J];
      lHandle.Changed[lIndex] := (not lHandle.HasValues[lIndex]) or
        (not SameValue(lHandle.Values[lIndex], lValues[J]));
      lHandle.Values[lIndex] := lValues[J];
      lHandle.Times[lIndex] := lTimes[J];
      lHandle.Qualities[lIndex] := lQualities[J];
      lHandle.HasValues[lIndex] := True;
    end;
    Inc(lStart, lChunkCount);
  end;
  lStart := 0;
  for I := 0 to High(lHandle.StringChunks) do
  begin
    lChunkCount := Length(lHandle.StringChunks[I]);
    if not lHandle.Client.ReadStrings(lHandle.StringChunks[I], lStringValues, lTimes,
      lQualities) then
    begin
      lHandle.ErrorText := lHandle.Client.ErrorText;
      Exit;
    end;
    for J := 0 to lChunkCount - 1 do
    begin
      lIndex := lHandle.StringIndexes[lStart + J];
      lHandle.Changed[lIndex] := (not lHandle.HasValues[lIndex]) or
        (lHandle.StringValues[lIndex] <> lStringValues[J]) or
        (not SameValue(lHandle.Times[lIndex], lTimes[J])) or
        (lHandle.Qualities[lIndex] <> lQualities[J]);
      lHandle.StringValues[lIndex] := lStringValues[J];
      lHandle.Times[lIndex] := lTimes[J];
      lHandle.Qualities[lIndex] := lQualities[J];
      lHandle.HasValues[lIndex] := True;
    end;
    Inc(lStart, lChunkCount);
  end;
  if ATimeoutMs > 0 then Sleep(Min(ATimeoutMs, 10));
  Result := True;
end;

function RecorderOpcUaClientReadMessageChanged(
  AHandle: TRecorderOpcUaHandle; AIndex: Integer; out AValue: string;
  out ATimestampSec: Double; out AQuality: Cardinal): Boolean;
var
  lHandle: TRecorderOpcUaClientHandle;
begin
  Result := False;
  if AHandle = nil then Exit;
  lHandle := TRecorderOpcUaClientHandle(AHandle);
  if (AIndex < 0) or (AIndex >= Length(lHandle.Changed)) or
    not lHandle.IsStringNode[AIndex] or
    not lHandle.Changed[AIndex] then Exit;
  AValue := lHandle.StringValues[AIndex];
  ATimestampSec := lHandle.Times[AIndex];
  AQuality := lHandle.Qualities[AIndex];
  lHandle.Changed[AIndex] := False;
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
    lHandle.IsStringNode[AIndex] or
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
