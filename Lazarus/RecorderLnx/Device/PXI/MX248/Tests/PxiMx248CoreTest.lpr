program PxiMx248CoreTest;

{
  Deterministic software test typed properties and lifecycle without DevAPI or
  hardware. It uses the production core units and a transport fake; it must
  never grow a second protocol implementation. Hardware/IPC acceptance is a
  separate scenario described in Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, uRecorderDriverContractsV2, uRecorderPxiMx248Types,
  uRecorderPxiMx248Device;

type
  TFakeTransport = class(TInterfacedObject, IPxiMx248Transport)
  public
    ConfigureCount: Integer;
    ModulePropertyCount: Integer;
    ConfigureTrace: string;
    FailModuleProperties: Boolean;
    FailProgramming: Boolean;
    InitializeCount: Integer;
    LastModuleConfiguration: TPxiMx248Configuration;
    LastProgramConfiguration: TPxiMx248Configuration;
    StartCount: Integer;
    StopCount: Integer;
    function Connect: TRecorderOperationResult;
    function Initialize(out ASerialNumber, AVersion: string):
      TRecorderOperationResult;
    function TestLink: TRecorderOperationResult;
    function SetModuleProperties(
      const AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
    function ProgramAcquisition(
      const AConfiguration: TPxiMx248Configuration):
      TRecorderOperationResult;
    function Start: TRecorderOperationResult;
    function Stop: TRecorderOperationResult;
    procedure Disconnect;
  end;

function TFakeTransport.Connect: TRecorderOperationResult;
begin Result := TRecorderOperationResult.Success end;
function TFakeTransport.Initialize(out ASerialNumber, AVersion: string):
  TRecorderOperationResult;
begin
  Inc(InitializeCount); ASerialNumber := '248'; AVersion := '1.1';
  Result := TRecorderOperationResult.Success;
end;
function TFakeTransport.TestLink: TRecorderOperationResult;
begin Result := TRecorderOperationResult.Success end;
function TFakeTransport.SetModuleProperties(
  const AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
begin
  Inc(ModulePropertyCount); ConfigureTrace := ConfigureTrace + 'properties;';
  LastModuleConfiguration := AConfiguration;
  if FailModuleProperties then
    Exit(TRecorderOperationResult.Failure(rocTransport, 'fake.properties',
      'injected failure'));
  Result := TRecorderOperationResult.Success;
end;
function TFakeTransport.ProgramAcquisition(
  const AConfiguration: TPxiMx248Configuration): TRecorderOperationResult;
begin
  Inc(ConfigureCount); ConfigureTrace := ConfigureTrace + 'program;';
  LastProgramConfiguration := AConfiguration;
  if FailProgramming then
    Exit(TRecorderOperationResult.Failure(rocTransport, 'fake.program',
      'injected failure'));
  Result := TRecorderOperationResult.Success;
end;
function TFakeTransport.Start: TRecorderOperationResult;
begin Inc(StartCount); Result := TRecorderOperationResult.Success end;
function TFakeTransport.Stop: TRecorderOperationResult;
begin Inc(StopCount); Result := TRecorderOperationResult.Success end;
procedure TFakeTransport.Disconnect;
begin end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

var
  lDevice: TPxiMx248Device;
  lFake: TFakeTransport;
  lResponse: string;
  lBeforeCalc: string;
  lResult: TRecorderOperationResult;
begin
  lFake := TFakeTransport.Create;
  lDevice := TPxiMx248Device.Create(lFake);
  try
    lResult := lDevice.GetProperties('sample-rate-hz;channel.1.input-mode',
      lResponse);
    Check(lResult.IsSuccess and (Pos('sample-rate-hz=1000', lResponse) > 0),
      'getprop failed');
    lResult := lDevice.SetProperties(
      'sample-rate-hz=2000;block-samples=512;calibration-mode=pxi;' +
      'channel.1.enabled=false;channel.1.amplifier-enabled=false;' +
      'channel.1.input-mode=single-ended;channel.1.range-index=2;' +
      'channel.1.lpf-index=1;channel.1.icp-current=10;' +
      'channel.1.calibration-enabled=true;channel.1.input-floating=true;' +
      'channel.8.icp-current=4');
    Check(lResult.IsSuccess, 'setprop failed');
    lResult := lDevice.SetProperties(
      'sample-rate-hz=3000;unknown=1');
    Check(not lResult.IsSuccess, 'unknown property accepted');
    lDevice.GetProperties('sample-rate-hz', lResponse);
    Check(lResponse = 'sample-rate-hz=2000', 'invalid batch was not atomic');
    lResult := lDevice.SetProperties('device.type=1');
    Check(not lResult.IsSuccess, 'read-only property accepted');
    lResult := lDevice.SetProperties('sample-rate-hz=2000.5');
    Check(lResult.IsSuccess, 'invariant decimal property rejected');
    lResult := lDevice.SetProperties('sample-rate-hz');
    Check(not lResult.IsSuccess, 'malformed property accepted');
    lResult := lDevice.SetProperties('block-samples=128;block-samples=256');
    Check(not lResult.IsSuccess, 'duplicate property accepted');
    lDevice.GetProperties('block-samples', lBeforeCalc);
    lResult := lDevice.CalcProperties('block-samples=1024', lResponse);
    Check(lResult.IsSuccess and (Pos('block-samples=1024', lResponse) > 0),
      'calc properties failed');
    lDevice.GetProperties('block-samples', lResponse);
    Check(lResponse = lBeforeCalc, 'CalcProperties mutated committed values');
    Check(lDevice.Connect.IsSuccess, 'connect failed');
    Check(lDevice.Initialize.IsSuccess, 'initialize failed');
    lFake.FailModuleProperties := True;
    Check(not lDevice.Configure.IsSuccess, 'module property failure ignored');
    Check(lFake.ConfigureCount = 0, 'program ran after first configure failure');
    lFake.FailModuleProperties := False;
    lFake.FailProgramming := True;
    Check(not lDevice.Configure.IsSuccess, 'programming failure ignored');
    Check(lDevice.State = pmsInitialized,
      'programming failure changed lifecycle state');
    lFake.FailProgramming := False;
    lFake.ConfigureTrace := '';
    Check(lDevice.Configure.IsSuccess, 'configure failed');
    Check(lFake.LastModuleConfiguration.SampleRateHz = 2000.5,
      'sample rate mapping differs');
    Check((lFake.LastModuleConfiguration.BlockSamples = 512) and
      (lFake.LastModuleConfiguration.CalibrationMode = pcmPxi),
      'device property mapping differs');
    Check((not lFake.LastModuleConfiguration.Channels[0].Enabled) and
      (not lFake.LastModuleConfiguration.Channels[0].AmplifierEnabled) and
      (lFake.LastModuleConfiguration.Channels[0].InputMode = pimSingleEnded) and
      (lFake.LastModuleConfiguration.Channels[0].RangeIndex = 2) and
      (lFake.LastModuleConfiguration.Channels[0].LowPassFilterIndex = 1) and
      (lFake.LastModuleConfiguration.Channels[0].IcpCurrent = pic10mA) and
      lFake.LastModuleConfiguration.Channels[0].CalibrationEnabled and
      lFake.LastModuleConfiguration.Channels[0].InputFloating,
      'channel 1 property mapping differs');
    Check(lFake.LastModuleConfiguration.Channels[7].IcpCurrent = pic4mA,
      'channel 8 property mapping differs');
    Check(lFake.LastProgramConfiguration.SampleRateHz =
      lFake.LastModuleConfiguration.SampleRateHz,
      'configure stages received different snapshots');
    Check(lDevice.Start.IsSuccess, 'first start failed');
    lResult := lDevice.SetProperties('sample-rate-hz=3000');
    Check((not lResult.IsSuccess) and (lDevice.State = pmsRunning),
      'running property commit was not rejected');
    lDevice.GetProperties('sample-rate-hz', lResponse);
    Check(lResponse = 'sample-rate-hz=2000.5',
      'running rejection changed cached configuration');
    Check(lDevice.Stop.IsSuccess, 'first stop failed');
    Check(lDevice.Start.IsSuccess, 'second start failed');
    Check(lDevice.Stop.IsSuccess, 'second stop failed');
    Check(lDevice.Stop.IsSuccess, 'idempotent stop failed');
    Check(lDevice.Connect.IsSuccess, 'idempotent connect failed');
    Check(lDevice.Initialize.IsSuccess, 'idempotent initialize failed');
    Check((lFake.InitializeCount = 1) and (lFake.ConfigureCount = 2) and
      (lFake.ModulePropertyCount = 3),
      'start/stop repeated initialize or configure');
    Check(lFake.ConfigureTrace = 'properties;program;',
      'MX-248 configure command order differs from original');
    Check((lFake.StartCount = 2) and (lFake.StopCount = 2),
      'start/stop counts differ');
    WriteLn('RESULT PXI MX-248 core passed');
  finally
    lDevice.Free;
  end;
end.
