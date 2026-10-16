unit uRecorderModbusFactory;

{ Composition root for persisted Modbus Master sources.  Construction parses
  configuration and selects a transport; hardware I/O starts only in the
  datasource worker's PrepareHardware stage. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderDataSources, uRecorderConfiguredDataSources;

function RecorderCreateModbusDataSource(
  AConfigured: TRecorderConfiguredDataSource; AUpdateTimeMs: Cardinal):
  IRecorderDataSource;

implementation

uses
  SysUtils, uModbusCoreTypes, uRecorderModbusTransport,
  uRecorderModbusTcpTransport, uRecorderModbusRtuTransport,
  uRecorderModbusDataSource, uRecorderModbusDevice,
  uRecorderDeviceInterfaces;

function RtuParity(AValue: Char): TRecorderModbusParity;
begin
  case UpCase(AValue) of
    'O': Result := mpOdd;
    'E': Result := mpEven;
  else
    Result := mpNone;
  end;
end;

function RecorderCreateModbusDataSource(
  AConfigured: TRecorderConfiguredDataSource; AUpdateTimeMs: Cardinal):
  IRecorderDataSource;
var
  lConfig: TModbusBusConfig;
  lError: string;
  lDevice: IRecorderDevice;
  lTransport: IRecorderModbusTransport;
begin
  if AConfigured = nil then
    raise EArgumentNilException.Create('Configured Modbus source is required');
  lConfig := TModbusBusConfig.Create;
  try
    lConfig.LoadJsonString(AConfigured.SpecificConfigText);
    if not lConfig.Validate(lError) then
      raise ERecorderDataSourceError.Create('Invalid Modbus configuration: ' +
        lError);
    if not SameText(RecorderModbusSourceId(lConfig.Alias),
      AConfigured.SourceId) then
      raise ERecorderDataSourceError.Create('Modbus alias does not match source id');
    if lConfig.Transport = mtTcp then
      lTransport := TRecorderModbusTcpTransport.Create(lConfig.Host,
        lConfig.Port, lConfig.TimeoutMs)
    else
      lTransport := TRecorderModbusRtuTransport.Create(lConfig.SerialPort,
        lConfig.BaudRate, lConfig.DataBits, RtuParity(lConfig.Parity),
        lConfig.StopBits);
    lDevice := TRecorderModbusDevice.Create(lConfig, lTransport);
    lConfig := nil;
    Result := TRecorderModbusDataSource.Create(lDevice, AUpdateTimeMs);
  finally
    lConfig.Free;
  end;
end;

end.
