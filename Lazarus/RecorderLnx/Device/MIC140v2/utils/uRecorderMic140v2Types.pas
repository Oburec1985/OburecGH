unit uRecorderMic140v2Types;

{
  Внутренние типы MIC140v2: подсостояния драйвера, параметры создания.

  См. Docs/devices/device_abstraction.md, Docs/devices/mic140/protocol.md
}

{$mode objfpc}{$H+}

interface

uses
  uRecorderDeviceInterfaces;

const
  MIC140v2DefaultChannelCount = 48;
  MIC140v2DefaultPollFrequencyHz = 100.0;

type
  { Подсостояния внутри этапа «подключён / настройка / опрос» (rdpStateWord). }
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
    mv2Idle: Result := 'ожидание';
    mv2TcpConnecting: Result := 'установка TCP';
    mv2Identifying: Result := 'идентификация';
    mv2Programming: Result := 'настройка скана';
    mv2ScanRunning: Result := 'опрос';
    mv2Recovering: Result := 'восстановление обмена';
    mv2Error: Result := 'ошибка';
  else
    Result := 'неизвестно';
  end;
end;

end.
