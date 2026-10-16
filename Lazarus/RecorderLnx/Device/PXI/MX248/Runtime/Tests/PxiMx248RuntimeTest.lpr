program PxiMx248RuntimeTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, uRecorderAcquisitionTypes, uRecorderDataSources, uRecorderTags,
  uRecorderDeviceInterfaces, uRecorderDriverContractsV2,
  uRecorderPxiMx248Device, uRecorderPxiMx248Types,
  uRecorderPxiMx248RuntimeTransport, uRecorderPxiMx248DeviceAdapter,
  uRecorderPxiMx248DataSource, uRecorderHardwareLiveDevices;

type
  TFakeTransport = class(TInterfacedObject, IPxiMx248BlockTransport,
    IPxiMx248MaintenanceTransport)
  public
    ConnectCount: Integer;
    InitializeCount: Integer;
    ModulePropertiesCount: Integer;
    ProgramCount: Integer;
    StartCount: Integer;
    StopCount: Integer;
    ReadCount: Integer;
    SamplesPerRead: Integer;
    ConfigurePxiCount: Integer;
    function Connect: TRcOperationResult;
    function Initialize(out ASerialNumber, AVersion: string): TRcOperationResult;
    function TestLink: TRcOperationResult;
    function SetModuleProperties(const AConfiguration: TPxiMx248Configuration): TRcOperationResult;
    function ProgramAcquisition(const AConfiguration: TPxiMx248Configuration): TRcOperationResult;
    function Start: TRcOperationResult;
    function Stop: TRcOperationResult;
    procedure Disconnect;
    function ReadBlock(ATimeoutMs: Cardinal;
      var ABlock: TRcAcquisitionBlock): TRcOperationResult;
    function ReadLiveProperties(out AProperties: string): TRcOperationResult;
    function ZeroBalance(AChannelMask: Cardinal; out AValues: string): TRcOperationResult;
    function ConfigurePxi(ARtsiSev, ARtsiClock, ARtsiSync, ATriggerMode,
      ATriggerSource, ATriggerLevel: Integer): TRcOperationResult;
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

function TFakeTransport.Connect: TRcOperationResult;
begin
  Inc(ConnectCount);
  Result := TRcOperationResult.Success;
end;

function TFakeTransport.Initialize(out ASerialNumber, AVersion: string): TRcOperationResult;
begin
  Inc(InitializeCount);
  if InitializeCount > 1 then
    Exit(TRcOperationResult.Failure(rocTransport, 'fake.initialize',
      'exclusive owner error 20'));
  ASerialNumber := '248001';
  AVersion := '1.1';
  Result := TRcOperationResult.Success;
end;

function TFakeTransport.ReadLiveProperties(out AProperties: string):
  TRcOperationResult;
begin
  AProperties := 'sample-rate-hz=512000';
  Result := TRcOperationResult.Success;
end;

function TFakeTransport.ZeroBalance(AChannelMask: Cardinal;
  out AValues: string): TRcOperationResult;
begin
  AValues := 'ok';
  Result := TRcOperationResult.Success;
end;

function TFakeTransport.ConfigurePxi(ARtsiSev, ARtsiClock, ARtsiSync,
  ATriggerMode, ATriggerSource, ATriggerLevel: Integer):
  TRcOperationResult;
begin
  Inc(ConfigurePxiCount);
  Result := TRcOperationResult.Success;
end;

function TFakeTransport.TestLink: TRcOperationResult;
begin
  Result := TRcOperationResult.Success;
end;

function TFakeTransport.SetModuleProperties(
  const AConfiguration: TPxiMx248Configuration): TRcOperationResult;
begin
  Inc(ModulePropertiesCount);
  Result := TRcOperationResult.Success;
end;

function TFakeTransport.ProgramAcquisition(
  const AConfiguration: TPxiMx248Configuration): TRcOperationResult;
begin
  Inc(ProgramCount);
  Result := TRcOperationResult.Success;
end;

function TFakeTransport.Start: TRcOperationResult;
begin
  Inc(StartCount);
  Result := TRcOperationResult.Success;
end;

function TFakeTransport.Stop: TRcOperationResult;
begin
  Inc(StopCount);
  Result := TRcOperationResult.Success;
end;

procedure TFakeTransport.Disconnect;
begin
end;

function TFakeTransport.ReadBlock(ATimeoutMs: Cardinal;
  var ABlock: TRcAcquisitionBlock): TRcOperationResult;
var
  I, J: Integer;
begin
  Inc(ReadCount);
  Check(Length(ABlock.Values) = CPxiMx248ChannelCount,
    'transport did not receive preallocated channels');
  Check(Length(ABlock.Values[0]) >= 4,
    'transport did not receive preallocated samples');
  ABlock.ChannelCount := CPxiMx248ChannelCount;
  if SamplesPerRead > 0 then ABlock.SampleCount := SamplesPerRead
  else ABlock.SampleCount := 4;
  ABlock.FirstTimeSec := 10.0;
  ABlock.SampleRateHz := 1000.0;
  for I := 0 to CPxiMx248ChannelCount - 1 do
    for J := 0 to ABlock.SampleCount - 1 do
      ABlock.Values[I][J] := I * 100 + J;
  Result := TRcOperationResult.Success;
end;

procedure TestAdapterAndDataSource;
var
  lAdapter: TRecorderPxiMx248DeviceAdapter;
  lDevice: IRecorderDevice;
  lFake: TFakeTransport;
  lRegistry: TRecorderTagRegistry;
  lSource: TRecorderPxiMx248DataSource;
  lSnapshot: TRecorderSignalSnapshot;
  lRuntime: IPxiMx248RuntimeSettings;
  lResult: TRcOperationResult;
  lReadback: string;
  lSourceRef: IRecorderDataSource;
begin
  lFake := TFakeTransport.Create;
  lAdapter := TRecorderPxiMx248DeviceAdapter.Create('pxi-0-2', 'PXI MX-248', lFake);
  lDevice := lAdapter;
  Check(lDevice.SetProp('sample-rate-hz=422;block-samples=4'),
    'string properties rejected');
  Check(Pos('block-samples=4', lDevice.GetProp('block-samples')) > 0,
    'string property readback failed');

  lRegistry := TRecorderTagRegistry.Create;
  try
    lSource := TRecorderPxiMx248DataSource.Create('PXI:0:2', lDevice, 4);
    lSourceRef := lSource;
    try
      lSource.ConfigureTags(lRegistry);
      Check(lRegistry.TagCount = CPxiMx248ChannelCount,
        'datasource must create eight tags');
      lSource.PrepareHardware;
      Check(RecorderHardwareFindLiveDevice('PXI:0:2') <> nil,
        'prepared MX-248 datasource was not registered as live');
      Check((lFake.ConnectCount = 1) and (lFake.InitializeCount = 1),
        'prepare lifecycle count mismatch');
      Check((lFake.ModulePropertiesCount = 1) and (lFake.ProgramCount = 1),
        'configure order/count mismatch');
      Check(Supports(lSource, IPxiMx248RuntimeSettings, lRuntime),
        'runtime settings interface missing');
      lResult := lRuntime.RuntimeApplyLive(
        'sample-rate-hz=512000;block-samples=4', 0, 1, 0, 0, 1,
        lReadback);
      Check(lResult.IsSuccess, 'live apply via owned session failed');
      Check(lFake.InitializeCount = 1,
        'live apply opened a second exclusive session (error 20)');
      Check((lFake.ModulePropertiesCount = 2) and (lFake.ProgramCount = 2) and
        (lFake.ConfigurePxiCount = 1),
        'dirty runtime configuration was not programmed once');
      lSource.Start;
      lResult := lRuntime.RuntimeApplyLive(
        'sample-rate-hz=512000;block-samples=4', 0, 1, 0, 0, 1,
        lReadback);
      Check(lResult.Code = rocInvalidState,
        'running source must reject live Apply');
      Check(lFake.ConfigurePxiCount = 1,
        'running rejection touched the transport');
      lSource.Tick;
      lSource.Stop;
      lSource.Start;
      lSource.Tick;
      lSource.Stop;
      Check((lFake.StartCount = 2) and (lFake.StopCount = 2),
        'two Start/Stop cycles expected');
      Check((lFake.InitializeCount = 1) and (lFake.ProgramCount = 2),
        'Start/Stop must not initialize or configure again');
      lSnapshot := lRegistry.FindByName('PXI:0:2 AIn8').LastBlockSnapshot;
      Check((lSnapshot.Count = 4) and (Abs(lSnapshot.Values[3] - 703.0) < 1e-9),
        'eighth tag block publication mismatch');
    finally
      lRuntime := nil;
      lSourceRef := nil;
      Check(RecorderHardwareFindLiveDevice('PXI:0:2') = nil,
        'destroyed MX-248 datasource remained registered as live');
    end;
  finally
    lRegistry.Free;
    lDevice := nil;
  end;
end;

procedure TestHighRateTickDrainsMultipleBlocks;
var
  lDevice: IRecorderDevice;
  lFake: TFakeTransport;
  lRegistry: TRecorderTagRegistry;
  lSource: TRecorderPxiMx248DataSource;
begin
  lFake := TFakeTransport.Create;
  lFake.SamplesPerRead := 256;
  lDevice := TRecorderPxiMx248DeviceAdapter.Create('pxi-2-14', 'PXI MX-248',
    lFake);
  Check(lDevice.SetProp('sample-rate-hz=512000;block-samples=256'),
    'high-rate test configuration rejected');
  lRegistry := TRecorderTagRegistry.Create;
  try
    lSource := TRecorderPxiMx248DataSource.Create('PXI:2:14', lDevice, 4);
    try
      lSource.ConfigureTags(lRegistry);
      lSource.PrepareHardware;
      lSource.Start;
      lSource.Tick;
      lSource.Stop;
      Check(lFake.ReadCount = 8,
        'one 4 ms tick at 512 kHz must drain eight 256-sample blocks');
    finally
      lSource.Free;
    end;
  finally
    lRegistry.Free;
    lDevice := nil;
  end;
end;

begin
  try
    TestAdapterAndDataSource;
    TestHighRateTickDrainsMultipleBlocks;
    WriteLn('RESULT PXI MX-248 runtime passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT PXI MX-248 runtime failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
