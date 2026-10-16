program ModbusCoreTest;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, uModbusCoreTypes, uModbusCodec, uModbusValues, uModbusPlanner;

var
  gPassed, gFailed: Integer;

procedure Check(ACondition: Boolean; const AName: string);
begin
  if ACondition then begin Inc(gPassed); WriteLn('PASS ', AName); end
  else begin Inc(gFailed); WriteLn('FAIL ', AName); end;
end;

function Bytes(const AValues: array of Byte): TBytes;
var lIndex: Integer;
begin
  SetLength(Result, Length(AValues));
  for lIndex := 0 to High(AValues) do Result[lIndex] := AValues[lIndex];
end;

function SameBytes(const A, B: TBytes): Boolean;
begin
  Result := (Length(A) = Length(B)) and
    ((Length(A) = 0) or CompareMem(@A[0], @B[0], Length(A)));
end;

procedure TestCodec;
var
  lPdu, lFrame, lOut: TBytes;
  lResponse: TModbusResponse;
begin
  Check(BuildReadPdu(3, $006B, 3, lPdu) = mcOk, 'FC03 build result');
  Check(SameBytes(lPdu, Bytes([$03,$00,$6B,$00,$03])), 'FC03 golden PDU');
  lFrame := WrapTcp($1234, $11, lPdu);
  Check(SameBytes(lFrame, Bytes([$12,$34,$00,$00,$00,$06,$11,$03,$00,$6B,$00,$03])), 'MBAP golden');
  Check(UnwrapTcp(lFrame, $1234, $11, lOut) = mcOk, 'MBAP unwrap');
  Check(SameBytes(lOut, lPdu), 'MBAP payload');
  lFrame := WrapRtu($11, lPdu);
  Check(SameBytes(lFrame, Bytes([$11,$03,$00,$6B,$00,$03,$76,$87])), 'RTU CRC golden');
  Check(UnwrapRtu(lFrame, $11, lOut) = mcOk, 'RTU unwrap');
  lFrame[High(lFrame)] := lFrame[High(lFrame)] xor 1;
  Check(UnwrapRtu(lFrame, $11, lOut) = mcBadCrc, 'RTU rejects bad CRC');
  Check(ParseResponsePdu(Bytes([$83,$02]), 3, lResponse) = mcExceptionResponse, 'exception response');
  Check(lResponse.ExceptionCode = 2, 'exception code');
  Check(ParseResponsePdu(Bytes([$03,$04,$00,$01]), 3, lResponse) = mcBadLength, 'malformed byte count');
  Check(BuildWriteSinglePdu(5, 9, $FF00, lPdu) = mcOk, 'FC05');
  Check(BuildWriteSinglePdu(6, 9, $1234, lPdu) = mcOk, 'FC06');
  Check(BuildWriteMultiplePdu(15, 0, 9, Bytes([$55,$01]), lPdu) = mcOk, 'FC15');
  Check(BuildWriteMultiplePdu(16, 0, 2, Bytes([$00,$01,$00,$02]), lPdu) = mcOk, 'FC16');
  Check(BuildReadPdu(1, 0, 2000, lPdu) = mcOk, 'FC01 limit');
  Check(BuildReadPdu(2, 0, 2001, lPdu) = mcMalformed, 'FC02 over limit');
  Check(BuildReadPdu(4, 0, 125, lPdu) = mcOk, 'FC04 limit');
end;

procedure TestValues;
var
  lBytes: TBytes;
  lValue: Double;
  lOrder: TModbusByteOrder;
begin
  for lOrder := Low(TModbusByteOrder) to High(TModbusByteOrder) do begin
    Check(EncodeModbusValue(123.25, mdFloat32, lOrder, lBytes), 'encode F32');
    Check(DecodeModbusValue(lBytes, mdFloat32, lOrder, lValue) and SameValue(lValue, 123.25, 1E-6), 'roundtrip F32');
    Check(EncodeModbusValue(-123456, mdInt32, lOrder, lBytes), 'encode I32');
    Check(DecodeModbusValue(lBytes, mdInt32, lOrder, lValue) and (lValue = -123456), 'roundtrip I32');
    Check(EncodeModbusValue(1.25E100, mdFloat64, lOrder, lBytes), 'encode F64');
    Check(DecodeModbusValue(lBytes, mdFloat64, lOrder, lValue) and SameValue(lValue, 1.25E100, 1E85), 'roundtrip F64');
  end;
  Check(DecodeModbusValue(Bytes([$3F,$80,$00,$00]), mdFloat32, moABCD, lValue) and SameValue(lValue, 1.0), 'ABCD golden float');
  Check(DecodeModbusValue(Bytes([$80,$3F,$00,$00]), mdFloat32, moBADC, lValue) and SameValue(lValue, 1.0), 'BADC golden float');
  Check(DecodeModbusValue(Bytes([$00,$00,$3F,$80]), mdFloat32, moCDAB, lValue) and SameValue(lValue, 1.0), 'CDAB golden float');
  Check(DecodeModbusValue(Bytes([$00,$00,$80,$3F]), mdFloat32, moDCBA, lValue) and SameValue(lValue, 1.0), 'DCBA golden float');
end;

procedure TestConfigAndAddress;
var
  lBus, lCopy, lClone: TModbusBusConfig;
  lDevice: TModbusDeviceConfig;
  lTag: TModbusTagConfig;
  lText: string;
  lRegion: TModbusRegion;
  lAddress: Word;
begin
  lBus := TModbusBusConfig.Create; lCopy := TModbusBusConfig.Create; lClone := nil;
  try
    lBus.Alias := 'plant'; lBus.Transport := mtRtu; lBus.SerialPort := '/dev/ttyUSB0';
    lBus.PollIntervalMs := 250; lBus.Retries := 4;
    lDevice := lBus.AddDevice; lDevice.Alias := 'meter'; lDevice.Description := 'Main meter'; lDevice.UnitId := 7;
    lTag := lDevice.AddTag; lTag.Alias := 'power'; lTag.Description := 'Active power';
    lTag.Address := 12; lTag.DataType := mdFloat64; lTag.ByteOrder := moDCBA;
    lTag.EngineeringUnit := 'kW'; lTag.Scale := 0.1; lTag.Offset := 2;
    lText := lBus.ToJsonString; lCopy.LoadJsonString(lText);
    Check((lCopy.DeviceCount = 1) and (lCopy.DeviceAt(0).TagCount = 1), 'config tree roundtrip');
    Check(lCopy.DeviceAt(0).TagAt(0).Alias = 'power', 'config tag roundtrip');
    Check((lCopy.PollIntervalMs = 250) and (lCopy.Retries = 4), 'bus runtime fields roundtrip');
    Check((lCopy.DeviceAt(0).Description = 'Main meter') and
      (lCopy.DeviceAt(0).TagAt(0).EngineeringUnit = 'kW') and
      SameValue(lCopy.DeviceAt(0).TagAt(0).Scale, 0.1), 'metadata roundtrip');
    Check(lCopy.DeviceAt(0).TagAt(0).Id = lTag.Id, 'stable tag id roundtrip');
    lClone := lBus.Clone;
    Check((lClone.DeviceCount = 1) and (lClone.DeviceAt(0).Id = lDevice.Id), 'deep clone preserves identity');
    lClone.DeviceAt(0).TagAt(0).Alias := 'clonePower';
    Check(lBus.DeviceAt(0).TagAt(0).Alias = 'power', 'clone owns independent tags');
    Check(ModbusTagIdentity('sourceA', 'power') = 'sourceA/power', 'public identity hides path');
    Check(RecorderModbusSourceId('plant') = 'Modbus: plant', 'Recorder source id');
    Check(RecorderIsModbusSource('Modbus: plant') and not RecorderIsModbusSource('OPC UA: plant'), 'Recorder source predicate');
  finally lClone.Free; lCopy.Free; lBus.Free; end;
  Check(TryParseReferenceAddress('40001', lRegion, lAddress) and (lRegion = mrHoldingRegister) and (lAddress = 0), '40001 to zero based');
  Check(FormatReferenceAddress(mrInputRegister, 9) = '30010', 'zero based to 30001 notation');
  Check(not TryParseReferenceAddress('20001', lRegion, lAddress), 'reject ambiguous notation');
end;

procedure TestValidation;
var
  lBus: TModbusBusConfig;
  lDevice, lDevice2: TModbusDeviceConfig;
  lTag, lTag2: TModbusTagConfig;
  lError: string;
begin
  lBus := TModbusBusConfig.Create;
  try
    lBus.Alias := 'source';
    lDevice := lBus.AddDevice; lDevice.Alias := 'dev1'; lDevice.UnitId := 1;
    lTag := lDevice.AddTag; lTag.Alias := 'temperature'; lTag.Region := mrInputRegister; lTag.DataType := mdFloat32;
    Check(lBus.Validate(lError), 'valid configuration');
    lTag.Access := maReadWrite;
    Check(not lBus.Validate(lError), 'reject writes to input region');
    lTag.Access := maReadOnly; lTag.DataType := mdBool;
    Check(not lBus.Validate(lError), 'reject Bool in register region');
    lTag.DataType := mdFloat64; lTag.Address := 65534;
    Check(not lBus.Validate(lError), 'reject register span overflow');
    lTag.Address := 0;
    lDevice2 := lBus.AddDevice; lDevice2.Alias := 'dev2'; lDevice2.UnitId := 2;
    lTag2 := lDevice2.AddTag; lTag2.Alias := 'temperature'; lTag2.Region := mrCoil; lTag2.DataType := mdBool;
    Check(not lBus.Validate(lError), 'reject duplicate public tag alias');
    lTag2.Alias := 'switch'; lDevice2.UnitId := 0;
    Check(not lBus.Validate(lError), 'reject unit zero');
    lDevice2.UnitId := 2; lTag2.Region := mrDiscreteInput; lTag2.Access := maReadWrite;
    Check(not lBus.Validate(lError), 'reject write to discrete input');
    lTag2.Access := maReadOnly; lTag2.DataType := mdFloat64;
    Check(lTag2.RegisterCount = 1, 'bit channel occupies one Modbus bit');
    Check(lBus.Validate(lError), 'valid mixed region configuration');
    lDevice2.RemoveTag(lTag2);
    Check((lDevice2.TagCount = 0) and lBus.Validate(lError), 'remove tag');
    lBus.RemoveDevice(lDevice2);
    Check(lBus.DeviceCount = 1, 'remove device');
    lBus.Clear;
    Check(lBus.DeviceCount = 0, 'clear devices');
  finally lBus.Free; end;
end;

procedure TestPlanner;
var
  lDevice: TModbusDeviceConfig;
  lTag: TModbusTagConfig;
  lPlan: TModbusPlan;
begin
  lDevice := TModbusDeviceConfig.Create;
  try
    lDevice.UnitId := 9;
    lTag := lDevice.AddTag; lTag.Address := 2; lTag.DataType := mdUInt16;
    lTag := lDevice.AddTag; lTag.Address := 0; lTag.DataType := mdUInt32;
    lTag := lDevice.AddTag; lTag.Address := 124; lTag.DataType := mdUInt32;
    lTag := lDevice.AddTag; lTag.Address := 126; lTag.DataType := mdUInt16;
    BuildReadPlan(lDevice, lPlan);
    Check(Length(lPlan) = 2, 'planner splits 125-register limit');
    Check((lPlan[0].StartAddress = 0) and (lPlan[0].Count = 3) and (lPlan[0].TagCount = 2), 'planner groups contiguous tags');
    Check((lPlan[1].StartAddress = 124) and (lPlan[1].Count = 3), 'planner boundary second request');
    lTag := lDevice.AddTag; lTag.Region := mrCoil; lTag.Address := 0; lTag.DataType := mdBool;
    BuildReadPlan(lDevice, lPlan);
    Check((Length(lPlan) = 3) and (lPlan[0].FunctionCode = 1), 'planner separates regions deterministically');
  finally lDevice.Free; end;
end;

begin
  TestCodec; TestValues; TestConfigAndAddress; TestValidation; TestPlanner;
  WriteLn('RESULT ', gPassed, ' passed, ', gFailed, ' failed');
  if gFailed <> 0 then Halt(1);
end.
