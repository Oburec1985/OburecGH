unit uRecorderModbusDevice;

{ Common Recorder device adapter for one Modbus bus.  It owns transport and
  protocol runtime; the datasource owns only Recorder tag bindings. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Variants, uRecorderDeviceInterfaces, uRecorderAcquisitionTypes,
  uModbusCoreTypes, uRecorderModbusRuntime, uRecorderModbusTransport;

type
  TRecorderModbusDevice = class(TRcDevice)
  private
    fConfig: TModbusBusConfig;
    fRuntime: TRecorderModbusBusRuntime;
    fLastResult: TRecorderModbusTransportResult;
    fLastError: string;
    function ApplyResult(const AStage: string;
      const AResult: TRecorderModbusTransportResult): Boolean;
  protected
    function GetChannels: TRecorderDeviceChannelArray; override;
  public
    constructor Create(AConfig: TModbusBusConfig;
      const ATransport: IRecorderModbusTransport);
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure InitializeDevice; override;
    procedure ConfigureDevice; override;
    procedure Start; override;
    procedure Stop; override;
    function TestLink(out AErrorText: string): Boolean; override;
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant; override;
    function Iterate: Boolean;
    function WriteValue(ADeviceIndex, ATagIndex: Integer;
      AValue: Double): Boolean;
    function TagAt(ADeviceIndex, ATagIndex: Integer): TRecorderModbusTagRuntime;
    property Config: TModbusBusConfig read fConfig;
    property LastResult: TRecorderModbusTransportResult read fLastResult;
  end;

implementation

constructor TRecorderModbusDevice.Create(AConfig: TModbusBusConfig;
  const ATransport: IRecorderModbusTransport);
begin
  if AConfig = nil then
    raise EArgumentNilException.Create('Modbus configuration is required');
  inherited Create(RecorderModbusSourceId(AConfig.Alias),
    CRecorderModbusModuleType);
  fConfig := AConfig;
  fPollFrequencyHz := 1000.0 / fConfig.PollIntervalMs;
  fUpdateTimeMs := fConfig.PollIntervalMs;
  fRuntime := TRecorderModbusBusRuntime.Create(fConfig, ATransport);
end;

destructor TRecorderModbusDevice.Destroy;
begin
  fRuntime.Disconnect;
  FreeAndNil(fRuntime);
  FreeAndNil(fConfig);
  inherited Destroy;
end;

function TRecorderModbusDevice.ApplyResult(const AStage: string;
  const AResult: TRecorderModbusTransportResult): Boolean;
begin
  fLastResult := AResult;
  Result := AResult.Code = mtcOk;
  if Result then fLastError := ''
  else fLastError := AStage + ': ' + AResult.Detail;
end;

procedure TRecorderModbusDevice.Connect;
begin
  if ApplyResult('connect', fRuntime.Connect) then fState := rdsConnected;
end;

procedure TRecorderModbusDevice.InitializeDevice;
begin
  ApplyResult('initialize', fRuntime.Initialize);
end;

procedure TRecorderModbusDevice.ConfigureDevice;
begin
  if ApplyResult('configure', fRuntime.Configure) then fState := rdsProgrammed;
end;

procedure TRecorderModbusDevice.Start;
begin
  if ApplyResult('start', fRuntime.Start) then fState := rdsStarted;
end;

procedure TRecorderModbusDevice.Stop;
begin
  ApplyResult('stop', fRuntime.Stop);
  if fRuntime.State = mrsConfigured then fState := rdsProgrammed;
end;

procedure TRecorderModbusDevice.Disconnect;
begin
  ApplyResult('disconnect', fRuntime.Disconnect);
  fState := rdsDisconnected;
end;

function TRecorderModbusDevice.Iterate: Boolean;
begin
  Result := ApplyResult('poll', fRuntime.Tick);
  if Result and (fRuntime.State = mrsRunning) then fState := rdsStarted;
end;

function TRecorderModbusDevice.WriteValue(ADeviceIndex, ATagIndex: Integer;
  AValue: Double): Boolean;
begin
  Result := ApplyResult('write', fRuntime.WriteValue(ADeviceIndex, ATagIndex,
    AValue));
end;

function TRecorderModbusDevice.TagAt(ADeviceIndex, ATagIndex: Integer):
  TRecorderModbusTagRuntime;
begin
  Result := fRuntime.TagAt(ADeviceIndex, ATagIndex);
end;

function TRecorderModbusDevice.TestLink(out AErrorText: string): Boolean;
begin
  AErrorText := fLastError;
  Result := (fState <> rdsDisconnected) and (fLastResult.Code = mtcOk);
end;

function TRecorderModbusDevice.GetDeviceProperty(
  AProperty: TRecorderDeviceProperty; AIndex: Integer): Variant;
begin
  case AProperty of
    rdpHost: if fConfig.Transport = mtTcp then Result := fConfig.Host
      else Result := fConfig.SerialPort;
    rdpPort: Result := fConfig.Port;
    rdpPollFrequencyHz: Result := fPollFrequencyHz;
    rdpUpdateTimeMs: Result := fUpdateTimeMs;
    rdpChannelCount: Result := fChannelCount;
    rdpErrorCode: Result := Ord(fLastResult.Code);
    rdpErrorText: Result := fLastError;
  else
    Result := inherited GetDeviceProperty(AProperty, AIndex);
  end;
end;

function TRecorderModbusDevice.GetChannels: TRecorderDeviceChannelArray;
var
  I, J, K: Integer;
  lTag: TModbusTagConfig;
begin
  SetLength(Result, 0);
  K := 0;
  for I := 0 to fConfig.DeviceCount - 1 do
    for J := 0 to fConfig.DeviceAt(I).TagCount - 1 do
    begin
      lTag := fConfig.DeviceAt(I).TagAt(J);
      SetLength(Result, K + 1);
      Result[K].Name := lTag.Alias;
      Result[K].Address := ModbusTagIdentity(fConfig.Alias, lTag.Alias);
      Result[K].UnitName := lTag.EngineeringUnit;
      Result[K].ModuleType := CRecorderModbusModuleType;
      Result[K].PollFrequencyHz := fPollFrequencyHz;
      Result[K].Enabled := fConfig.DeviceAt(I).Enabled and lTag.Enabled;
      Inc(K);
    end;
  fChannelCount := K;
end;

end.
