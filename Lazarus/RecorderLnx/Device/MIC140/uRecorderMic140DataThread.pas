unit uRecorderMic140DataThread;

{
  Рабочий поток MIC-140: наследник TRecorderDeviceDataThread.

  ReadBlockFromDevice вызывает callback владельца (Device), который читает
  один ReadBlock из уже открытого MDP-stream (без Connect/Config в потоке).
  Память с prealloc и без лишних аллокаций.
  См. Docs/devices/mic140/protocol/ и Device/uRecorderDeviceDataThread.pas.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs,
  uRecorderAcquisitionTypes, uRecorderDeviceDataThread;

type
  { Один блок из прибора; True = блок готов. Вызов только из DataThread. }
  TMic140DataThreadReadFunc = function(ATimeoutMs: Cardinal;
    var ABlock: TRecorderAcquisitionBlock): Boolean of object;

  TRecorderMic140DataThread = class(TRecorderDeviceDataThread)
  private
    fReadFunc: TMic140DataThreadReadFunc;
    fReadTimeoutMs: Cardinal;
  protected
    procedure OnStart; override;
    procedure OnStop; override;
    function ReadBlockFromDevice(var ABlock: TRecorderAcquisitionBlock): Boolean; override;
  public
    constructor Create(AReadFunc: TMic140DataThreadReadFunc;
      AReadTimeoutMs: Cardinal = 500);
    procedure Config(AChannelCount: Integer; ASampleCount: Integer;
      ASampleRateHz: Double); override;
    property ReadTimeoutMs: Cardinal read fReadTimeoutMs write fReadTimeoutMs;
  end;

implementation

constructor TRecorderMic140DataThread.Create(AReadFunc: TMic140DataThreadReadFunc;
  AReadTimeoutMs: Cardinal);
begin
  inherited Create;
  fReadFunc := AReadFunc;
  fReadTimeoutMs := AReadTimeoutMs;
end;

procedure TRecorderMic140DataThread.Config(AChannelCount: Integer;
  ASampleCount: Integer; ASampleRateHz: Double);
begin
  inherited Config(AChannelCount, ASampleCount, ASampleRateHz);
end;

procedure TRecorderMic140DataThread.OnStart;
begin
  { Место для подготовки Device.Start до StartPlay. }
end;

procedure TRecorderMic140DataThread.OnStop;
begin
  { Очистка после вызова Device.Stop после StopPlay. }
end;

function TRecorderMic140DataThread.ReadBlockFromDevice(
  var ABlock: TRecorderAcquisitionBlock): Boolean;
begin
  Result := False;
  if not Assigned(fReadFunc) then
    Exit;
  Result := fReadFunc(fReadTimeoutMs, ABlock);
end;

end.
