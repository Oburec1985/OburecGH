program RecorderDriverContractsV2Test;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  SysUtils, Classes,
  uRecorderDeviceInterfaces, uRecorderDriverContractsV2,
  uRecorderDriverPropertiesV2, uRecorderHardwareDriverRegistryV2;

type
  TTestPropertyStore = class(TRecorderTransactionalPropertyStore)
  private
    fFailAfterCommit: Boolean;
  protected
    function CalculateCandidate(AValues: TStrings): TRecorderOperationResult; override;
    function ValidateCandidate(AValues: TStrings): TRecorderOperationResult; override;
    procedure AfterCommit(const APreviousValues: string); override;
  public
    property FailAfterCommit: Boolean read fFailAfterCommit write fFailAfterCommit;
  end;

  TTestFactory = class(TRecorderHardwareDriverFactory)
  private
    fDriverId: string;
  public
    constructor Create(const ADriverId: string);
    destructor Destroy; override;
    function ModuleType: string; override;
    function DriverId: string; override;
    function CreateDevice(const ASourceId: string; out ADevice: IRecorderDevice):
      TRecorderOperationResult; override;
  end;

var
  gFactoryDestroyCount: Integer = 0;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

function TTestPropertyStore.ValidateCandidate(AValues: TStrings):
  TRecorderOperationResult;
var
  lFrequency, lLimit: Double;
  lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  if not TryStrToFloat(AValues.Values['acquisition.frequency_hz'], lFrequency,
    lFormat) or not TryStrToFloat(AValues.Values['acquisition.limit_hz'],
    lLimit, lFormat) then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'properties.validate', 'Invalid frequency pair'));
  if lFrequency > lLimit then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'properties.validate', 'Frequency exceeds limit'));
  Result := TRecorderOperationResult.Success;
end;

function TTestPropertyStore.CalculateCandidate(AValues: TStrings):
  TRecorderOperationResult;
var
  lFrequency: Double;
  lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  if not TryStrToFloat(AValues.Values['acquisition.frequency_hz'], lFrequency,
    lFormat) then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'properties.calculate', 'Invalid frequency'));
  AValues.Values['acquisition.limit_hz'] := FloatToStr(lFrequency * 2, lFormat);
  Result := TRecorderOperationResult.Success;
end;

procedure TTestPropertyStore.AfterCommit(const APreviousValues: string);
var
  lDetachedCopy: string;
begin
  lDetachedCopy := APreviousValues;
  if lDetachedCopy <> '' then
    lDetachedCopy[1] := '#';
  if fFailAfterCommit then
    raise Exception.Create('injected post-commit failure');
end;

constructor TTestFactory.Create(const ADriverId: string);
begin
  inherited Create;
  fDriverId := ADriverId;
end;

destructor TTestFactory.Destroy;
begin
  Inc(gFactoryDestroyCount);
  inherited Destroy;
end;

function TTestFactory.ModuleType: string;
begin
  Result := 'TEST-MODULE';
end;

function TTestFactory.DriverId: string;
begin
  Result := fDriverId;
end;

function TTestFactory.CreateDevice(const ASourceId: string;
  out ADevice: IRecorderDevice): TRecorderOperationResult;
begin
  ADevice := nil;
  Result := TRecorderOperationResult.Failure(rocUnsupported, 'device.create',
    'Test factory does not create a device');
end;

function NewStore: TTestPropertyStore;
var
  lDescriptors: array[0..4] of TRecorderPropertyDescriptor;
begin
  lDescriptors[0] := RecorderPropertyDescriptor('acquisition.frequency_hz',
    rpkFloat, rpaReadWrite, '10', rpsDevice, 'Hz', '1', '1000');
  lDescriptors[1] := RecorderPropertyDescriptor('acquisition.limit_hz',
    rpkFloat, rpaReadWrite, '100', rpsDevice, 'Hz', '1', '1000');
  lDescriptors[2] := RecorderPropertyDescriptor('acquisition.ground',
    rpkBoolean, rpaReadWrite, 'False');
  lDescriptors[3] := RecorderPropertyDescriptor('device.serial',
    rpkInteger, rpaReadOnly, '123');
  lDescriptors[4] := RecorderPropertyDescriptor('acquisition.mode',
    rpkEnum, rpaReadWrite, 'Voltage', rpsDevice, '', '', '', '1',
    'Voltage|Current|Resistance');
  Result := TTestPropertyStore.Create(lDescriptors);
end;

procedure TestStrictAndAtomic;
var
  lKeepAlive: IRecorderTransactionalProperties;
  lResult: TRecorderOperationResult;
  lStore: TTestPropertyStore;
begin
  lStore := NewStore;
  lKeepAlive := lStore;
  lResult := lStore.SetProperties(
    'acquisition.frequency_hz=20;acquisition.ground=true');
  Check(lResult.IsSuccess, 'valid packet rejected');
  Check(lStore.ValueOf('acquisition.frequency_hz') = '20',
    'float was not canonicalized');
  Check(lStore.ValueOf('acquisition.ground') = 'True',
    'boolean was not canonicalized');

  lResult := lStore.SetProperties(
    'acquisition.frequency_hz=30;acquisition.frequency_hz=40');
  Check((not lResult.IsSuccess) and
    (lStore.ValueOf('acquisition.frequency_hz') = '20'),
    'duplicate key changed live configuration');
  lResult := lStore.SetProperties(
    'acquisition.frequency_hz=30;unknown.property=1');
  Check((not lResult.IsSuccess) and
    (lStore.ValueOf('acquisition.frequency_hz') = '20'),
    'unknown key changed live configuration');
  lResult := lStore.SetProperties(
    'acquisition.frequency_hz=2000;acquisition.ground=false');
  Check((not lResult.IsSuccess) and
    (lStore.ValueOf('acquisition.frequency_hz') = '20'),
    'range validation was not atomic');
  lResult := lStore.SetProperties('device.serial=456');
  Check((not lResult.IsSuccess) and (lStore.ValueOf('device.serial') = '123'),
    'read-only property changed');
end;

procedure TestLocaleIndependentFloat;
var
  lKeepAlive: IRecorderTransactionalProperties;
  lOldSeparator: Char;
  lResult: TRecorderOperationResult;
  lStore: TTestPropertyStore;
begin
  lOldSeparator := DefaultFormatSettings.DecimalSeparator;
  DefaultFormatSettings.DecimalSeparator := ',';
  try
    lStore := NewStore;
    lKeepAlive := lStore;
    lResult := lStore.SetProperties('acquisition.frequency_hz=12.5');
    Check(lResult.IsSuccess, 'dot decimal rejected under comma locale');
    Check(lStore.ValueOf('acquisition.frequency_hz') = '12.5',
      'float response depends on process locale');
    lResult := lStore.SetProperties('acquisition.frequency_hz=12,5');
    Check(not lResult.IsSuccess, 'locale-specific decimal accepted');
  finally
    DefaultFormatSettings.DecimalSeparator := lOldSeparator;
  end;
end;

procedure TestGetContract;
var
  lKeepAlive: IRecorderTransactionalProperties;
  lResponse: string;
  lResult: TRecorderOperationResult;
  lStore: TTestPropertyStore;
begin
  lStore := NewStore;
  lKeepAlive := lStore;
  lResult := lStore.GetProperties('acquisition.frequency_hz;device.serial',
    lResponse);
  Check(lResult.IsSuccess, 'valid get request rejected');
  Check(lResponse = 'acquisition.frequency_hz=10;device.serial=123',
    'get response is not canonical');
  lResult := lStore.GetProperties('unknown.property', lResponse);
  Check(not lResult.IsSuccess, 'unknown get key accepted');
end;

procedure TestPureCalculationAndEnum;
var
  lAfter, lBefore, lCalculated: string;
  lKeepAlive: IRecorderTransactionalProperties;
  lResult: TRecorderOperationResult;
  lStore: TTestPropertyStore;
begin
  lStore := NewStore;
  lKeepAlive := lStore;
  lResult := lStore.GetProperties('*', lBefore);
  Check(lResult.IsSuccess, 'initial snapshot failed');
  lResult := lStore.CalcProperties(
    'acquisition.frequency_hz=25;acquisition.mode=current', lCalculated);
  Check(lResult.IsSuccess, 'pure calculation failed');
  Check(Pos('acquisition.frequency_hz=25', lCalculated) > 0,
    'calculation did not contain candidate frequency');
  Check(Pos('acquisition.limit_hz=50', lCalculated) > 0,
    'dependent value was not calculated');
  Check(Pos('acquisition.mode=Current', lCalculated) > 0,
    'enum value was not canonicalized');
  lResult := lStore.GetProperties('*', lAfter);
  Check(lResult.IsSuccess and (lAfter = lBefore),
    'CalcProperties mutated the live snapshot');
  lResult := lStore.CalcProperties('acquisition.mode=power', lCalculated);
  Check(not lResult.IsSuccess, 'unknown enum value accepted');
  lResult := lStore.GetProperties('*', lAfter);
  Check(lAfter = lBefore, 'rejected enum calculation mutated live state');
end;

procedure TestDriverRegistry;
var
  lBeforeDestroy: Integer;
  lDuplicate: TTestFactory;
  lFactory: TRecorderHardwareDriverFactory;
  lRegistry: TRecorderHardwareDriverRegistry;
  lResult: TRecorderOperationResult;
begin
  lRegistry := TRecorderHardwareDriverRegistry.Create;
  try
    lResult := lRegistry.RegisterFactory(TTestFactory.Create('v1'));
    Check(lResult.IsSuccess, 'v1 factory registration failed');
    lResult := lRegistry.RegisterFactory(TTestFactory.Create('v2'));
    Check(lResult.IsSuccess, 'v2 factory registration failed');
    lResult := lRegistry.Resolve('TEST-MODULE', '', lFactory);
    Check(lResult.IsSuccess and SameText(lFactory.DriverId, 'v1'),
      'empty driver id did not preserve v1 semantics');
    lResult := lRegistry.Resolve('TEST-MODULE', 'v2', lFactory);
    Check(lResult.IsSuccess and SameText(lFactory.DriverId, 'v2'),
      'explicit v2 selection failed');
    lDuplicate := TTestFactory.Create('v1');
    lBeforeDestroy := gFactoryDestroyCount;
    lResult := lRegistry.RegisterFactory(lDuplicate);
    Check(not lResult.IsSuccess, 'duplicate driver registration accepted');
    Check(gFactoryDestroyCount = lBeforeDestroy,
      'registry took ownership after failed registration');
    lDuplicate.Free;
    Check(gFactoryDestroyCount = lBeforeDestroy + 1,
      'caller could not release rejected factory');
    Check((lRegistry.FactoryCount = 2) and
      SameText(lRegistry.Factories[0].DriverId, 'v1'),
      'read-only registry access is inconsistent');
  finally
    lRegistry.Free;
  end;
end;

procedure ExpectDescriptorFailure(
  const ADescriptor: TRecorderPropertyDescriptor; const AMessage: string);
var
  lStore: TRecorderTransactionalPropertyStore;
begin
  lStore := nil;
  try
    try
      lStore := TRecorderTransactionalPropertyStore.Create([ADescriptor]);
    except
      on E: EArgumentException do Exit;
    end;
    raise Exception.Create(AMessage);
  finally
    lStore.Free;
  end;
end;

procedure TestDescriptorSchemaValidation;
begin
  ExpectDescriptorFailure(RecorderPropertyDescriptor('bad;name', rpkString,
    rpaReadWrite, ''), 'invalid descriptor name accepted');
  ExpectDescriptorFailure(RecorderPropertyDescriptor('bad.bounds', rpkFloat,
    rpaReadWrite, '5', rpsDevice, '', '10', '1'),
    'reversed bounds accepted');
  ExpectDescriptorFailure(RecorderPropertyDescriptor('bad.default', rpkInteger,
    rpaReadWrite, 'abc'), 'invalid numeric default accepted');
  ExpectDescriptorFailure(RecorderPropertyDescriptor('bad.enum', rpkEnum,
    rpaReadWrite, 'A', rpsDevice, '', '', '', '1', 'A|a'),
    'duplicate enum values accepted');
  ExpectDescriptorFailure(RecorderPropertyDescriptor('bad.enum.default', rpkEnum,
    rpaReadWrite, 'C', rpsDevice, '', '', '', '1', 'A|B'),
    'enum default outside catalog accepted');
end;

procedure TestCommitFailureRollback;
var
  lKeepAlive: IRecorderTransactionalProperties;
  lResult: TRecorderOperationResult;
  lStore: TTestPropertyStore;
begin
  lStore := NewStore;
  lKeepAlive := lStore;
  lStore.FailAfterCommit := True;
  lResult := lStore.SetProperties('acquisition.frequency_hz=25');
  Check((not lResult.IsSuccess) and (lResult.Code = rocInternal),
    'post-commit exception was not converted to a result');
  Check(lStore.ValueOf('acquisition.frequency_hz') = '10',
    'post-commit failure did not restore the immutable snapshot');
  Check(lStore.ValueOf('acquisition.limit_hz') = '100',
    'post-commit failure partially retained a calculated value');
end;

begin
  try
    TestStrictAndAtomic;
    TestLocaleIndependentFloat;
    TestGetContract;
    TestPureCalculationAndEnum;
    TestDriverRegistry;
    TestDescriptorSchemaValidation;
    TestCommitFailureRollback;
    Writeln('RESULT RecorderDriverContractsV2Test passed');
  except
    on E: Exception do
    begin
      Writeln(StdErr, 'RESULT RecorderDriverContractsV2Test failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
