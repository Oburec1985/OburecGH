program OpcUaReadProbe;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, Contnrs, uRecorderOpcUaBinaryClient;

const
  CEndpoint = 'opc.tcp://192.168.15.130:4840';
  CSessionTimeoutMs = 15000;
  CNodeIds: array[0..1] of string = (
    'ns=4;s=|var|PLC210 OPC-UA.Application.GVL.blinkerplc',
    'ns=4;s=|var|PLC210 OPC-UA.Application.GVL.count_cmdbut'
  );

var
  I, J, lTagChildren, lTagsChildren: Integer;
  lEndpoint: string;
  lClient: TRecorderOpcUaBinaryClient;
  lNode: TRecorderOpcUaDiscoveredNode;
  lNodes: TObjectList;
  lQuality: Cardinal;
  lTime, lValue: Double;
  lStringNodeId: string;
  lStringNodeIds, lStringValues: TRecorderOpcUaStringArray;
  lStringTimes: TRecorderOpcUaDoubleArray;
  lStringQualities: TRecorderOpcUaCardinalArray;
begin
  if ParamCount > 0 then lEndpoint := ParamStr(1)
  else lEndpoint := CEndpoint;
  WriteLn('ENDPOINT: ', lEndpoint);
  lClient := TRecorderOpcUaBinaryClient.Create(lEndpoint, '', '',
    CSessionTimeoutMs);
  try
    if not lClient.Connect then
    begin
      WriteLn('CONNECT FAIL: ', lClient.ErrorText);
      Halt(2);
    end;
    WriteLn('CONNECT OK');
    lNodes := TObjectList.Create(True);
    try
      if not lClient.Browse(lNodes) then
      begin
        WriteLn('BROWSE FAIL: ', lClient.ErrorText);
        Halt(4);
      end;
      WriteLn('BROWSE OK: nodes=', lNodes.Count);
      lTagChildren := 0;
      lTagsChildren := 0;
      for I := 0 to lNodes.Count - 1 do
      begin
        lNode := TRecorderOpcUaDiscoveredNode(lNodes[I]);
        if (lStringNodeId = '') and
          (SameText(lNode.DataTypeNodeId, 'i=12') or
           SameText(lNode.DataTypeNodeId, 'ns=0;i=12')) and
          lNode.CanRead then
          lStringNodeId := lNode.NodeId;
        if Pos('Tag_[', lNode.DisplayName) = 1 then
        begin
          Inc(lTagChildren);
          if lTagChildren <= 3 then
            WriteLn('TAG CHILD: name=', lNode.DisplayName,
              ' path=', lNode.BrowsePath, ' nodeId=', lNode.NodeId);
        end;
        if Pos('Tags_[', lNode.DisplayName) = 1 then
        begin
          Inc(lTagsChildren);
          if lTagsChildren <= 3 then
            WriteLn('TAGS CHILD: name=', lNode.DisplayName,
              ' path=', lNode.BrowsePath, ' nodeId=', lNode.NodeId);
        end;
        if lNode.ArrayValues.Count = 0 then Continue;
        WriteLn('ARRAY: ', lNode.NodeId, ' count=', lNode.ArrayValues.Count,
          ' timestamp=', lNode.ValueTimestamp);
        for J := 0 to lNode.ArrayValues.Count - 1 do
        begin
          if J = 10 then
          begin
            WriteLn('  ... ', lNode.ArrayValues.Count - J,
              ' more elements');
            Break;
          end;
          WriteLn('  ', J + 1, ' = ', lNode.ArrayValues[J]);
        end;
      end;
      WriteLn('INDEXED COUNTS: Tag_=', lTagChildren,
        ' Tags_=', lTagsChildren);
      if lStringNodeId <> '' then
      begin
        SetLength(lStringNodeIds, 1);
        lStringNodeIds[0] := lStringNodeId;
        if not lClient.ReadStrings(lStringNodeIds, lStringValues,
          lStringTimes, lStringQualities) then
        begin
          WriteLn('STRING READ FAIL: ', lClient.ErrorText);
          Halt(5);
        end;
        WriteLn('STRING READ OK: ', lStringNodeId, ' value=',
          lStringValues[0], ' quality=0x',
          IntToHex(lStringQualities[0], 8));
      end
      else
        WriteLn('STRING READ SKIP: no readable String node');
    finally
      lNodes.Free;
    end;
    if lEndpoint <> CEndpoint then Exit;
    for I := Low(CNodeIds) to High(CNodeIds) do
      if lClient.ReadDouble(CNodeIds[I], lValue, lQuality, lTime) then
        WriteLn('READ OK: ', CNodeIds[I], ' value=', FloatToStr(lValue),
          ' quality=0x', IntToHex(lQuality, 8), ' time=', FloatToStr(lTime))
      else
      begin
        WriteLn('READ FAIL: ', lClient.ErrorText);
        Halt(3);
      end;
  finally
    lClient.Free;
  end;
end.
