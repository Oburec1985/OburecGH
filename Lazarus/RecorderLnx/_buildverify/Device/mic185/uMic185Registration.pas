unit uMic185Registration;

{
  Регистрация MIC183/185 в локальном менеджере тестового стенда.
  Имя как в Recorder UI; драйвер Mebius — medaq_mic185v2 (внутреннее имя MIC185V2).
}

{$mode objfpc}{$H+}

interface

procedure RegisterMIC183_185;

implementation

uses
  SysUtils,
  uRecorderDeviceManager, uMic185Device;

const
  CDefaultHost = '192.168.9.142';
  CDefaultPort = 4000;
  CDeviceType = 'MIC183/185';

function FindMIC183_185(out AResult: TRecorderDeviceSearchResult): Boolean;
begin
  AResult.DeviceType := CDeviceType;
  AResult.Host := CDefaultHost;
  AResult.Port := CDefaultPort;
  Result := True;
end;

procedure RegisterMIC183_185;
begin
  RecorderDeviceManager.RegisterDeviceClass(
    CDeviceType, 'MIC183/185', 'Комплекс тензоизмерительный MIC183/185',
    @CreateRecorderMic185Device, @FindMIC183_185);
  { Алиас для старых вызовов Search('MIC185'). }
  RecorderDeviceManager.RegisterDeviceClass(
    'MIC185', 'MIC183/185', 'Комплекс тензоизмерительный MIC183/185',
    @CreateRecorderMic185Device, @FindMIC183_185);
end;

initialization
  RegisterMIC183_185;

end.
