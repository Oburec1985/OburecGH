unit uRecorderMic140Factory;

{
  Фабрика MIC-140. Defaults как в Mic140ProtocolDebug_Codex:
  mppMic14048v3 + GroundEnabled=True.
  См. Docs/devices/mic140/protocol/ и lifecycle-codex.md.
}

{$mode objfpc}{$H+}

interface

uses
  uRecorderMic140DeviceApi, uRecorderMic140Scan;

function CreateMic140Device(const ADeviceId, AHost: string; APort: Word;
  AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  AProgrammingProfile: TMic140ProgrammingProfile = mppMic14048v3;
  AGroundEnabled: Boolean = True): IMic140Device;

implementation

uses
  uRecorderMic140Device;

function CreateMic140Device(const ADeviceId, AHost: string; APort: Word;
  AChannelCount: Integer; APollFrequencyHz: Double; AUpdateTimeMs: Cardinal;
  AProgrammingProfile: TMic140ProgrammingProfile;
  AGroundEnabled: Boolean): IMic140Device;
begin
  Result := TRecorderMic140Device.Create(ADeviceId, AHost, APort, AChannelCount,
    APollFrequencyHz, AUpdateTimeMs, AProgrammingProfile, AGroundEnabled);
end;

end.
