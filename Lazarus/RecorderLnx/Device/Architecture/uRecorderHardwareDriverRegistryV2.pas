unit uRecorderHardwareDriverRegistryV2;

{
  Explicit composition-root registry for hardware drivers. An empty requested
  driver id resolves only to the module's registered v1 default. The registry
  owns factories but never creates devices during registration or lookup.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderDeviceInterfaces, uRecorderDriverContractsV2;

type
  TRecorderHardwareDriverFactory = class abstract
  public
    function ModuleType: string; virtual; abstract;
    function DriverId: string; virtual; abstract;
    function IsDefaultV1: Boolean; virtual;
    function CreateDevice(const ASourceId: string; out ADevice: IRecorderDevice):
      TRecorderOperationResult; virtual; abstract;
  end;

  TRecorderHardwareDriverRegistry = class
  private
    fFactories: TFPList;
    function GetFactoryCount: Integer;
    function GetFactory(AIndex: Integer): TRecorderHardwareDriverFactory;
  public
    constructor Create;
    destructor Destroy; override;
    { Ownership transfers to the registry only when Success is returned. }
    function RegisterFactory(AFactory: TRecorderHardwareDriverFactory):
      TRecorderOperationResult;
    function Resolve(const AModuleType, ADriverId: string;
      out AFactory: TRecorderHardwareDriverFactory): TRecorderOperationResult;
    property FactoryCount: Integer read GetFactoryCount;
    property Factories[AIndex: Integer]: TRecorderHardwareDriverFactory
      read GetFactory;
  end;

implementation

function TRecorderHardwareDriverRegistry.GetFactoryCount: Integer;
begin
  Result := fFactories.Count;
end;

function TRecorderHardwareDriverRegistry.GetFactory(
  AIndex: Integer): TRecorderHardwareDriverFactory;
begin
  if (AIndex < 0) or (AIndex >= fFactories.Count) then
    raise ERangeError.CreateFmt('Factory index out of range: %d', [AIndex]);
  Result := TRecorderHardwareDriverFactory(fFactories[AIndex]);
end;

function TRecorderHardwareDriverFactory.IsDefaultV1: Boolean;
begin
  Result := SameText(DriverId, 'v1');
end;

constructor TRecorderHardwareDriverRegistry.Create;
begin
  inherited Create;
  fFactories := TFPList.Create;
end;

destructor TRecorderHardwareDriverRegistry.Destroy;
var
  I: Integer;
begin
  for I := 0 to fFactories.Count - 1 do TObject(fFactories[I]).Free;
  fFactories.Free;
  inherited Destroy;
end;

function TRecorderHardwareDriverRegistry.RegisterFactory(
  AFactory: TRecorderHardwareDriverFactory): TRecorderOperationResult;
var
  I: Integer;
  lExisting: TRecorderHardwareDriverFactory;
begin
  if (AFactory = nil) or (Trim(AFactory.ModuleType) = '') or
    (Trim(AFactory.DriverId) = '') then
    Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
      'driver.register', 'Factory, module type and driver id are required'));
  for I := 0 to fFactories.Count - 1 do
  begin
    lExisting := TRecorderHardwareDriverFactory(fFactories[I]);
    if SameText(lExisting.ModuleType, AFactory.ModuleType) and
      SameText(lExisting.DriverId, AFactory.DriverId) then
      Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
        'driver.register', 'Duplicate driver registration'));
    if SameText(lExisting.ModuleType, AFactory.ModuleType) and
      lExisting.IsDefaultV1 and AFactory.IsDefaultV1 then
      Exit(TRecorderOperationResult.Failure(rocInvalidArgument,
        'driver.register', 'Duplicate v1 default'));
  end;
  fFactories.Add(AFactory);
  Result := TRecorderOperationResult.Success;
end;

function TRecorderHardwareDriverRegistry.Resolve(const AModuleType,
  ADriverId: string; out AFactory: TRecorderHardwareDriverFactory):
  TRecorderOperationResult;
var
  I: Integer;
  lCandidate: TRecorderHardwareDriverFactory;
begin
  AFactory := nil;
  for I := 0 to fFactories.Count - 1 do
  begin
    lCandidate := TRecorderHardwareDriverFactory(fFactories[I]);
    if not SameText(lCandidate.ModuleType, Trim(AModuleType)) then Continue;
    if ((Trim(ADriverId) = '') and lCandidate.IsDefaultV1) or
      SameText(lCandidate.DriverId, Trim(ADriverId)) then
    begin
      AFactory := lCandidate;
      Exit(TRecorderOperationResult.Success);
    end;
  end;
  Result := TRecorderOperationResult.Failure(rocUnsupported, 'driver.resolve',
    'Hardware driver is not registered');
end;

end.
