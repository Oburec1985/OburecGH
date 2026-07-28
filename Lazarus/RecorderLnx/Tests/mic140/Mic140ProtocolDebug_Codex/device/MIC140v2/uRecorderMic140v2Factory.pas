unit uRecorderMic140v2Factory;

{
  Фабрика MIC-140 v2 (единственная рабочая ветка опроса).
}

{$mode objfpc}{$H+}

interface

uses
  uRecorderMic140DeviceApi;

function CreateMic140Device(const ADeviceId, AHost: string; APort: Word;
  AChannelCount: Integer; APollFrequencyHz: Double;
  AUpdateTimeMs: Cardinal): IMic140Device;

implementation

uses
  uRecorderMic140v2Device;

function CreateMic140Device(const ADeviceId, AHost: string; APort: Word;
  AChannelCount: Integer; APollFrequencyHz: Double;
  AUpdateTimeMs: Cardinal): IMic140Device;
begin
  Result := TRecorderMic140v2Device.Create(ADeviceId, AHost, APort, AChannelCount,
    APollFrequencyHz, AUpdateTimeMs);
end;

end.
