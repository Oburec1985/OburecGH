unit uRecorderPxiMx248Device;

{
  Назначение: стабильный lifecycle-оркестратор MX-248 между typed config и
  сменным IPxiMx248Transport. Его вызывает datasource/service; UI напрямую
  устройством не управляет.

  Контракт: стадии выполняются явно и не вызывают соседние скрыто. Device
  владеет property store; transport передаётся как interface и владеет своей
  сессией/handles. Configure всегда делает SetModuleProperties перед
  ProgramAcquisition и останавливается на первой ошибке. Core не зависит от
  Windows/DevAPI/IPC. Runtime I/O, блокировки и буферы принадлежат transport и
  datasource; callbacks из worker не должны входить в UI. Один owner thread
  сериализует lifecycle, property commits и destruction: классы не thread-safe
  и acquisition callback не имеет права re-enter эти методы. Caller владеет
  device; device удерживает ref-counted transport и освобождает property store.
  Mutable property store наружу не публикуется; SetProperties во время Running
  запрещён, чтобы cached snapshot не расходился с конфигурацией оборудования.
  Disconnect/Destroy выполняют best-effort cleanup. Retry Configure после
  ошибки повторяет оба аппаратных шага с тем же полным snapshot.

  Архитектура, lifecycle и первоисточники:
  Device/PXI/MX248/Docs/README.md
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, uRecorderDriverContractsV2, uRecorderPxiMx248Types,
  uRecorderPxiMx248Properties;

type
  { Все методы вызывает последовательно один owner thread. Connect создаёт
    одну bridge-сессию; Disconnect идемпотентно и без исключений освобождает
    её. Native handles никогда не покидают x86 bridge. }
  IPxiMx248Transport = interface
    ['{157709F3-115D-49A1-A67A-6E8FDB2F1038}']
    function Connect: TRecorderOperationResult;
    function Initialize(out ASerialNumber, AVersion: string):
      TRecorderOperationResult;
    function TestLink: TRecorderOperationResult;
    { Original MX-248 order: module properties first, acquisition programming
      second. Keeping the operations separate makes first-failure behavior
      explicit and testable. }
    function SetModuleProperties(const AConfiguration: TPxiMx248Configuration):
      TRecorderOperationResult;
    function ProgramAcquisition(const AConfiguration: TPxiMx248Configuration):
      TRecorderOperationResult;
    function Start: TRecorderOperationResult;
    function Stop: TRecorderOperationResult;
    procedure Disconnect;
  end;

  TPxiMx248Device = class
  private
    fConfiguration: TPxiMx248Configuration;
    fConfigurationDirty: Boolean;
    fProperties: TPxiMx248PropertyStore;
    fSerialNumber: string;
    fState: TPxiMx248State;
    fTransport: IPxiMx248Transport;
    fVersion: string;
    procedure PropertiesCommitted(
      const AConfiguration: TPxiMx248Configuration);
  public
    constructor Create(const ATransport: IPxiMx248Transport);
    destructor Destroy; override;
    function Connect: TRecorderOperationResult;
    function Initialize: TRecorderOperationResult;
    function TestLink: TRecorderOperationResult;
    function GetPropertyDescriptors: TRecorderPropertyDescriptorArray;
    function GetProperties(const ARequest: string; out AResponse: string):
      TRecorderOperationResult;
    function CalcProperties(const AProperties: string; out AResponse: string):
      TRecorderOperationResult;
    function SetProperties(const AProperties: string): TRecorderOperationResult;
    function Configure: TRecorderOperationResult;
    function Start: TRecorderOperationResult;
    function Stop: TRecorderOperationResult;
    procedure Disconnect;
    property SerialNumber: string read fSerialNumber;
    property State: TPxiMx248State read fState;
    property Version: string read fVersion;
  end;

implementation

function InvalidState(const AStage: string; AState: TPxiMx248State):
  TRecorderOperationResult;
begin
  Result := TRecorderOperationResult.Failure(rocInvalidState, AStage,
    Format('MX-248 state %d does not allow this operation', [Ord(AState)]));
end;

constructor TPxiMx248Device.Create(const ATransport: IPxiMx248Transport);
begin
  inherited Create;
  if ATransport = nil then
    raise EArgumentNilException.Create('MX-248 transport is required');
  fTransport := ATransport;
  PxiMx248DefaultConfiguration(fConfiguration);
  fConfigurationDirty := True;
  fProperties := TPxiMx248PropertyStore.Create(@PropertiesCommitted);
  fState := pmsCreated;
end;

destructor TPxiMx248Device.Destroy;
begin
  if fState = pmsRunning then Stop;
  Disconnect;
  fProperties.Free;
  inherited Destroy;
end;

procedure TPxiMx248Device.PropertiesCommitted(
  const AConfiguration: TPxiMx248Configuration);
begin
  fConfiguration := AConfiguration;
  fConfigurationDirty := True;
  if fState = pmsConfigured then fState := pmsInitialized;
end;

function TPxiMx248Device.Connect: TRecorderOperationResult;
begin
  if fState in [pmsConnected, pmsInitialized, pmsConfigured, pmsRunning] then
    Exit(TRecorderOperationResult.Success);
  if fState <> pmsCreated then Exit(InvalidState('mx248.connect', fState));
  Result := fTransport.Connect;
  if Result.IsSuccess then fState := pmsConnected else fState := pmsOffline;
end;

function TPxiMx248Device.Initialize: TRecorderOperationResult;
begin
  if fState in [pmsInitialized, pmsConfigured, pmsRunning] then
    Exit(TRecorderOperationResult.Success);
  if fState <> pmsConnected then
    Exit(InvalidState('mx248.initialize', fState));
  Result := fTransport.Initialize(fSerialNumber, fVersion);
  if Result.IsSuccess then fState := pmsInitialized else fState := pmsOffline;
end;

function TPxiMx248Device.TestLink: TRecorderOperationResult;
begin
  if not (fState in [pmsConnected, pmsInitialized, pmsConfigured]) then
    Exit(InvalidState('mx248.test', fState));
  Result := fTransport.TestLink;
end;

function TPxiMx248Device.GetPropertyDescriptors:
  TRecorderPropertyDescriptorArray;
begin
  Result := fProperties.GetPropertyDescriptors;
end;

function TPxiMx248Device.GetProperties(const ARequest: string;
  out AResponse: string): TRecorderOperationResult;
begin
  Result := fProperties.GetProperties(ARequest, AResponse);
end;

function TPxiMx248Device.CalcProperties(const AProperties: string;
  out AResponse: string): TRecorderOperationResult;
begin
  Result := fProperties.CalcProperties(AProperties, AResponse);
end;

function TPxiMx248Device.SetProperties(const AProperties: string):
  TRecorderOperationResult;
begin
  if fState = pmsRunning then
    Exit(InvalidState('mx248.properties.set', fState));
  Result := fProperties.SetProperties(AProperties);
end;

function TPxiMx248Device.Configure: TRecorderOperationResult;
begin
  if fState = pmsConfigured then Exit(TRecorderOperationResult.Success);
  if fState <> pmsInitialized then
    Exit(InvalidState('mx248.configure', fState));
  Result := fTransport.SetModuleProperties(fConfiguration);
  if not Result.IsSuccess then Exit;
  Result := fTransport.ProgramAcquisition(fConfiguration);
  if Result.IsSuccess then
  begin
    fConfigurationDirty := False;
    fState := pmsConfigured;
  end;
end;

function TPxiMx248Device.Start: TRecorderOperationResult;
begin
  if fState <> pmsConfigured then Exit(InvalidState('mx248.start', fState));
  if fConfigurationDirty then Exit(InvalidState('mx248.start.dirty', fState));
  Result := fTransport.Start;
  if Result.IsSuccess then fState := pmsRunning;
end;

function TPxiMx248Device.Stop: TRecorderOperationResult;
begin
  if fState <> pmsRunning then Exit(TRecorderOperationResult.Success);
  Result := fTransport.Stop;
  if Result.IsSuccess then
    if fConfigurationDirty then fState := pmsInitialized
    else fState := pmsConfigured;
end;

procedure TPxiMx248Device.Disconnect;
begin
  if fState = pmsCreated then Exit;
  if fState = pmsRunning then Stop;
  fTransport.Disconnect;
  fSerialNumber := '';
  fVersion := '';
  fState := pmsCreated;
end;

end.
