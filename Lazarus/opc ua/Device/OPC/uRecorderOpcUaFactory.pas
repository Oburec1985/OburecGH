unit uRecorderOpcUaFactory;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderDataSources;

function RecorderCreateOpcUaDataSource(const ASourceId, AConfigText: string;
  AUpdateTimeMs: Cardinal): IRecorderDataSource;

implementation

uses
  uRecorderDeviceInterfaces, uRecorderOpcUaDevice, uRecorderOpcUaDataSource;

function RecorderCreateOpcUaDataSource(const ASourceId, AConfigText: string;
  AUpdateTimeMs: Cardinal): IRecorderDataSource;
var
  lDevice: IRecorderDevice;
begin
  { Composition root, modelled after Delphi2020 MIC-140 factories: create the
    protocol device first, then inject it into the tag-facing data source. }
  lDevice := TRecorderOpcUaDevice.Create(ASourceId, AConfigText);
  Result := TRecorderOpcUaDataSource.Create(lDevice, AUpdateTimeMs);
end;

end.
