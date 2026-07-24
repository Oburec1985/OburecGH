unit uRecorderMic140Types;

{
  ╨Т╨╜╤Г╤В╤А╨╡╨╜╨╜╨╕╨╡ ╤В╨╕╨┐╤Л MIC140v2: ╨┐╨╛╨┤╤Б╨╛╤Б╤В╨╛╤П╨╜╨╕╤П ╨┤╤А╨░╨╣╨▓╨╡╤А╨░, ╨┐╨░╤А╨░╨╝╨╡╤В╤А╤Л ╤Б╨╛╨╖╨┤╨░╨╜╨╕╤П.

  ╨б╨╝. Docs/devices/device_abstraction.md, Docs/devices/mic140/protocol.md
}

{$mode objfpc}{$H+}

interface

uses
  uRecorderDeviceInterfaces;

const
  MIC140v2DefaultChannelCount = 48;
  MIC140v2DefaultPollFrequencyHz = 100.0;

type
  { ╨Я╨╛╨┤╤Б╨╛╤Б╤В╨╛╤П╨╜╨╕╤П ╨▓╨╜╤Г╤В╤А╨╕ ╤Н╤В╨░╨┐╨░ ┬л╨┐╨╛╨┤╨║╨╗╤О╤З╤С╨╜ / ╨╜╨░╤Б╤В╤А╨╛╨╣╨║╨░ / ╨╛╨┐╤А╨╛╤Б┬╗ (rdpStateWord). }
  TMic140v2DriverPhase = (
    mv2Idle,
    mv2TcpConnecting,
    mv2Identifying,
    mv2Programming,
    mv2ScanRunning,
    mv2Recovering,
    mv2Error
  );

  TMic140v2CreateParams = record
    DeviceId: string;
    Host: string;
    Port: Word;
    ChannelCount: Integer;
    PollFrequencyHz: Double;
    UpdateTimeMs: Cardinal;
  end;

function Mic140v2DefaultCreateParams(const ADeviceId, AHost: string): TMic140v2CreateParams;
function Mic140v2PhaseToText(APhase: TMic140v2DriverPhase): string;

implementation

uses
  SysUtils;

function Mic140v2DefaultCreateParams(const ADeviceId, AHost: string): TMic140v2CreateParams;
begin
  Result.DeviceId := ADeviceId;
  Result.Host := AHost;
  Result.Port := 4000;
  Result.ChannelCount := MIC140v2DefaultChannelCount;
  Result.PollFrequencyHz := MIC140v2DefaultPollFrequencyHz;
  Result.UpdateTimeMs := 200;
end;

function Mic140v2PhaseToText(APhase: TMic140v2DriverPhase): string;
begin
  case APhase of
    mv2Idle: Result := '╨╛╨╢╨╕╨┤╨░╨╜╨╕╨╡';
    mv2TcpConnecting: Result := '╤Г╤Б╤В╨░╨╜╨╛╨▓╨║╨░ TCP';
    mv2Identifying: Result := '╨╕╨┤╨╡╨╜╤В╨╕╤Д╨╕╨║╨░╤Ж╨╕╤П';
    mv2Programming: Result := '╨╜╨░╤Б╤В╤А╨╛╨╣╨║╨░ ╤Б╨║╨░╨╜╨░';
    mv2ScanRunning: Result := '╨╛╨┐╤А╨╛╤Б';
    mv2Recovering: Result := '╨▓╨╛╤Б╤Б╤В╨░╨╜╨╛╨▓╨╗╨╡╨╜╨╕╨╡ ╨╛╨▒╨╝╨╡╨╜╨░';
    mv2Error: Result := '╨╛╤И╨╕╨▒╨║╨░';
  else
    Result := '╨╜╨╡╨╕╨╖╨▓╨╡╤Б╤В╨╜╨╛';
  end;
end;

end.
