program PxiMx248HardwareDiscoverCli;

{$mode objfpc}{$H+}

uses
  SysUtils, uRecorderDriverContractsV2, uRecorderPxiMx248Types,
  uRecorderPxiMx248WindowsTransport;

var
  I: Integer;
  lBridgePath: string;
  lDevices: TPxiMx248DiscoveredDevices;
  lResult: TRecorderOperationResult;
  lTransport: TRecorderPxiMx248WindowsTransport;
  lSerial, lVersion: string;
begin
  if (ParamCount <> 1) or not FileExists(ParamStr(1)) then
  begin
    WriteLn('Usage: PxiMx248HardwareDiscoverCli <bridge.exe>');
    Halt(2);
  end;
  lBridgePath := ExpandFileName(ParamStr(1));
  WriteLn('bridge=', lBridgePath);
  WriteLn('vendor_dir=', GetEnvironmentVariable('RECORDER_MX248_VENDOR_DIR'));
  lResult := RecorderDiscoverPxiMx248(lDevices, lBridgePath);
  WriteLn('result_code=', Ord(lResult.Code));
  WriteLn('result_stage=', lResult.Stage);
  WriteLn('result_text=', lResult.MessageText);
  WriteLn('device_count=', Length(lDevices));
  for I := 0 to High(lDevices) do
    WriteLn(Format('device[%d]=index:%d serial:%d revision:%d name:%s ' +
      'chassis_type:%d chassis:%d slot:%d', [I, lDevices[I].DeviceIndex,
      lDevices[I].SerialNumber, lDevices[I].Revision, lDevices[I].DeviceName,
      lDevices[I].ChassisType, lDevices[I].Chassis, lDevices[I].Slot]));
  if not lResult.IsSuccess then Halt(1);
  if Length(lDevices) = 0 then Halt(3);
  lTransport := TRecorderPxiMx248WindowsTransport.Create(lDevices[0].Chassis,
    lDevices[0].Slot, lBridgePath, 30000);
  try
    lResult := lTransport.Connect;
    WriteLn('connect_code=', Ord(lResult.Code));
    WriteLn('connect_stage=', lResult.Stage);
    WriteLn('connect_text=', lResult.MessageText);
    if not lResult.IsSuccess then Halt(4);
    lResult := lTransport.Initialize(lSerial, lVersion);
    WriteLn('initialize_code=', Ord(lResult.Code));
    WriteLn('initialize_stage=', lResult.Stage);
    WriteLn('initialize_text=', lResult.MessageText);
    WriteLn('serial=', lSerial);
    WriteLn('version=', lVersion);
    if not lResult.IsSuccess then Halt(5);
    lResult := lTransport.TestLink;
    WriteLn('test_code=', Ord(lResult.Code));
    WriteLn('test_stage=', lResult.Stage);
    WriteLn('test_text=', lResult.MessageText);
    if not lResult.IsSuccess then Halt(6);
  finally
    lTransport.Disconnect;
    lTransport.Free;
  end;
end.
