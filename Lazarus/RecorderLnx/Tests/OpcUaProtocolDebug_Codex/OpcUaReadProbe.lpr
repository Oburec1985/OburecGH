program OpcUaReadProbe;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, uRecorderOpcUaBinaryClient;

const
  CEndpoint = 'opc.tcp://192.168.15.130:4840';
  CSessionTimeoutMs = 15000;
  CNodeIds: array[0..2] of string = (
    'ns=4;s=|var|PLC210 OPC-UA.Application.GVL.blinkerplc',
    'ns=4;s=|var|PLC210 OPC-UA.Application.GVL.count_cmdbut',
    'ns=4;s=|var|PLC210 OPC-UA.Application.GVL.Tag'
  );

var
  I: Integer;
  lClient: TRecorderOpcUaBinaryClient;
  lQuality: Cardinal;
  lTime, lValue: Double;
begin
  lClient := TRecorderOpcUaBinaryClient.Create(CEndpoint, '', '',
    CSessionTimeoutMs);
  try
    if not lClient.Connect then
    begin
      WriteLn('CONNECT FAIL: ', lClient.ErrorText);
      Halt(2);
    end;
    WriteLn('CONNECT OK');
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
