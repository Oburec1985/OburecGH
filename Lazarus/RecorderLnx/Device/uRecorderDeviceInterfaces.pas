unit uRecorderDeviceInterfaces;

{
  Core-level device abstractions.

  Data sources use these interfaces instead of binding directly to files,
  sockets, DLLs or concrete hardware. A device can later be backed by a MERA
  file, MIC-140 over Ethernet, a simulator, or another acquisition module.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  ERecorderDeviceError = class(Exception);

  TRecorderDeviceState = (
    rdsDisconnected,
    rdsConnected,
    rdsProgrammed,
    rdsStarted
  );

  TRecorderDeviceChannel = record
    Name: string;
    Address: string;
    UnitName: string;
    ModuleType: string;
    PollFrequencyHz: Double;
    Enabled: Boolean;
  end;

  TRecorderDeviceChannelArray = array of TRecorderDeviceChannel;

  TRecorderDeviceSampleBlock = record
    ChannelCount: Integer;
    SampleCount: Integer;
    FirstTimeSec: Double;
    SampleRateHz: Double;
    Values: array of array of Double;
    TemperatureCount: Integer;
    TemperatureValues: array of array of Double;
    TemperatureValid: array of array of Boolean;
  end;

  IRecorderDevice = interface
    ['{39D2026D-851C-4EE4-97C7-3C86A02962A6}']
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;

    procedure Connect;
    procedure Disconnect;
    procedure ProgramDevice;
    procedure Start;
    procedure Stop;
    function ReadBlock(ATimeoutMs: Cardinal; out ABlock: TRecorderDeviceSampleBlock): Boolean;

    property DeviceId: string read GetDeviceId;
    property Name: string read GetName;
    property State: TRecorderDeviceState read GetState;
  end;

procedure ClearRecorderDeviceSampleBlock(var ABlock: TRecorderDeviceSampleBlock);
procedure CopyRecorderDeviceSampleBlock(const ASource: TRecorderDeviceSampleBlock;
  var ADest: TRecorderDeviceSampleBlock);

implementation

procedure CopyRecorderDeviceSampleBlock(const ASource: TRecorderDeviceSampleBlock;
  var ADest: TRecorderDeviceSampleBlock);
var
  I: Integer;
  lSampleCount: Integer;
begin
  ADest.ChannelCount := ASource.ChannelCount;
  ADest.SampleCount := ASource.SampleCount;
  ADest.FirstTimeSec := ASource.FirstTimeSec;
  ADest.SampleRateHz := ASource.SampleRateHz;
  ADest.TemperatureCount := ASource.TemperatureCount;

  SetLength(ADest.Values, ASource.ChannelCount);
  lSampleCount := ASource.SampleCount;
  for I := 0 to ASource.ChannelCount - 1 do
  begin
    SetLength(ADest.Values[I], lSampleCount);
    if lSampleCount > 0 then
      Move(ASource.Values[I][0], ADest.Values[I][0],
        lSampleCount * SizeOf(Double));
  end;

  SetLength(ADest.TemperatureValues, ASource.TemperatureCount);
  SetLength(ADest.TemperatureValid, ASource.TemperatureCount);
  for I := 0 to ASource.TemperatureCount - 1 do
  begin
    SetLength(ADest.TemperatureValues[I], lSampleCount);
    SetLength(ADest.TemperatureValid[I], lSampleCount);
    if lSampleCount > 0 then
      Move(ASource.TemperatureValues[I][0], ADest.TemperatureValues[I][0],
        lSampleCount * SizeOf(Double));
    if lSampleCount > 0 then
      Move(ASource.TemperatureValid[I][0], ADest.TemperatureValid[I][0],
        lSampleCount * SizeOf(Boolean));
  end;
end;

procedure ClearRecorderDeviceSampleBlock(var ABlock: TRecorderDeviceSampleBlock);
begin
  ABlock.ChannelCount := 0;
  ABlock.SampleCount := 0;
  ABlock.FirstTimeSec := 0;
  ABlock.SampleRateHz := 0;
  SetLength(ABlock.Values, 0);
  ABlock.TemperatureCount := 0;
  SetLength(ABlock.TemperatureValues, 0);
  SetLength(ABlock.TemperatureValid, 0);
end;

end.
