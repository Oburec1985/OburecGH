unit uRecorderPxiMx248Factory;

{
  Production composition entry for one configured MX-248 source. It creates
  the on-demand Win64-to-Win32 bridge transport, applies the persisted atomic
  property packet before Configure, and returns the generic datasource.

  No hardware stage runs during construction. The datasource worker later owns
  PrepareHardware/Start/Read/Stop. See Device/PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderDataSources, uRecorderConfiguredDataSources;

function RecorderCreatePxiMx248DataSource(
  AConfigured: TRecorderConfiguredDataSource; AUpdateTimeMs: Cardinal):
  IRecorderDataSource;

implementation

uses
  SysUtils, uRecorderDeviceInterfaces, uRecorderPxiMx248ConfiguredEditor,
  uRecorderPxiMx248RuntimeTransport, uRecorderPxiMx248WindowsTransport,
  uRecorderPxiMx248DeviceAdapter, uRecorderPxiMx248DataSource;

function RecorderCreatePxiMx248DataSource(
  AConfigured: TRecorderConfiguredDataSource; AUpdateTimeMs: Cardinal):
  IRecorderDataSource;
var
  lChassis, lSlot: Integer;
  lDevice: IRecorderDevice;
  lTransport: IPxiMx248BlockTransport;
begin
  Result := nil;
  if AConfigured = nil then Exit;
  if not TryParseRecorderPxiMx248SourceId(AConfigured.SourceId,
    lChassis, lSlot) then
    raise ERecorderDataSourceError.Create('Invalid PXI MX-248 source id: ' +
      AConfigured.SourceId);
  lTransport := TRecorderPxiMx248WindowsTransport.Create(lChassis, lSlot);
  lDevice := TRecorderPxiMx248DeviceAdapter.Create(AConfigured.SourceId,
    CRecorderPxiMx248ModuleType, lTransport);
  if (Trim(AConfigured.SpecificConfigText) <> '') and
    not lDevice.SetProp(AConfigured.SpecificConfigText) then
    raise ERecorderDataSourceError.Create('Invalid PXI MX-248 configuration');
  Result := TRecorderPxiMx248DataSource.Create(AConfigured.SourceId,
    lDevice, AUpdateTimeMs);
end;

end.
