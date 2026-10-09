program PxiMx248RuntimeTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, uRecorderAcquisitionTypes, uRecorderDataSources, uRecorderTags,
  uRecorderDeviceInterfaces, uRecorderDriverContractsV2,
  uRecorderPxiMx248Device, uRecorderPxiMx248Types,
  uRecorderPxiMx248RuntimeTransport, uRecorderPxiMx248DeviceAdapter,
  uRecorderPxiMx248DataSource;

type
  TFakeTransport = class(TInterfacedObject, IPxiMx248BlockTransport)
  public
    ConnectCount: Integer;
    InitializeCount: Integer;
    ModulePropertiesCount: Integer;
    ProgramCount: Integer;
    StartCount: Integer;
    StopCount: Integer;
    ReadCount: Integer;
    function Connect: TRecorderOperationResult;
    function Initialize(out ASerialNumber, AVersion: string): TRecorderOperationResult;
    function TestLink: TRecorderOperationResult;
    function SetModuleProperties(const AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
    function ProgramAcquisition(const AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
    function Start: TRecorderOperationResult;
    function Stop: TRecorderOperationResult;
    procedure Disconnect;
    function ReadBlock(ATimeoutMs: Cardinal;
      var ABlock: TRecorderAcquisitionBlock): TRecorderOperationResult;
  end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

function TFakeTransport.Connect: TRecorderOperationResult;
begin
  Inc(ConnectCount);
  Result := TRecorderOperationResult.Success;
end;

function TFakeTransport.Initialize(out ASerialNumber, AVersion: string): TRecorderOperationResult;
begin
  Inc(InitializeCount);
  ASerialNumber := '248001';
  AVersion := '1.1';
  Result := TRecorderOperationResult.Success;
end;

function TFakeTransport.TestLink: TRecorderOperationResult;
begin
  Result := TRecorderOperationResult.Success;
end;

function TFakeTransport.SetModuleProperties(
  const AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
begin
  Inc(ModulePropertiesCount);
  Result := TRecorderOperationResult.Success;
end;

function TFakeTransport.ProgramAcquisition(
  const AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
begin
  Inc(ProgramCount);
  Result := TRecorderOperationResult.Success;
end;

function TFakeTransport.Start: TRecorderOperationResult;
begin
  Inc(StartCount);
  Result := TRecorderOperationResult.Success;
end;

function TFakeTransport.Stop: TRecorderOperationResult;
begin
  Inc(StopCount);
  Result := TRecorderOperationResult.Success;
end;

procedure TFakeTransport.Disconnect;
begin
end;

function TFakeTransport.ReadBlock(ATimeoutMs: Cardinal;
  var ABlock: TRecorderAcquisitionBlock): TRecorderOperationResult;
var
  I, J: Integer;
begin
  Inc(ReadCount);
  Check(Length(ABlock.Values) = CPxiMx248ChannelCount,
    'transport did not receive preallocated channels');
  Check(Length(ABlock.Values[0]) >= 4,
    'transport did not receive preallocated samples');
  ABlock.ChannelCount := CPxiMx248ChannelCount;
  ABlock.SampleCount := 4;
  ABlock.FirstTimeSec := 10.0;
  ABlock.SampleRateHz := 1000.0;
  for I := 0 to CPxiMx248ChannelCount - 1 do
    for J := 0 to ABlock.SampleCount - 1 do
      ABlock.Values[I][J] := I * 100 + J;
  Result := TRecorderOperationResult.Success;
end;

procedure TestAdapterAndDataSource;
var
  lAdapter: TRecorderPxiMx248DeviceAdapter;
  lDevice: IRecorderDevice;
  lFake: TFakeTransport;
  lRegistry: TRecorderTagRegistry;
  lSource: TRecorderPxiMx248DataSource;
  lSnapshot: TRecorderSignalSnapshot;
begin
  lFake := TFakeTransport.Create;
  lAdapter := TRecorderPxiMx248DeviceAdapter.Create('pxi-0-2', 'PXI MX-248', lFake);
  lDevice := lAdapter;
  Check(lDevice.SetProp('sample-rate-hz=1000;block-samples=4'),
    'string properties rejected');
  Check(Pos('block-samples=4', lDevice.GetProp('block-samples')) > 0,
    'string property readback failed');

  lRegistry := TRecorderTagRegistry.Create;
  try
    lSource := TRecorderPxiMx248DataSource.Create('PXI:0:2', lDevice, 4);
    try
      lSource.ConfigureTags(lRegistry);
      Check(lRegistry.TagCount = CPxiMx248ChannelCount,
        'datasource must create eight tags');
      lSource.PrepareHardware;
      Check((lFake.ConnectCount = 1) and (lFake.InitializeCount = 1),
        'prepare lifecycle count mismatch');
      Check((lFake.ModulePropertiesCount = 1) and (lFake.ProgramCount = 1),
        'configure order/count mismatch');
      lSource.Start;
      lSource.Tick;
      lSource.Stop;
      lSource.Start;
      lSource.Tick;
      lSource.Stop;
      Check((lFake.StartCount = 2) and (lFake.StopCount = 2),
        'two Start/Stop cycles expected');
      Check((lFake.InitializeCount = 1) and (lFake.ProgramCount = 1),
        'Start/Stop must not initialize or configure again');
      lSnapshot := lRegistry.FindByName('PXI:0:2 AIn8').LastBlockSnapshot;
      Check((lSnapshot.Count = 4) and (Abs(lSnapshot.Values[3] - 703.0) < 1e-9),
        'eighth tag block publication mismatch');
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
    WriteLn('RESULT PXI MX-248 runtime passed');
  except
    on E: Exception do
    begin
      WriteLn('RESULT PXI MX-248 runtime failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
