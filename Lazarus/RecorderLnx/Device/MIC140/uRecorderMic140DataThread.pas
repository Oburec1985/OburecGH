unit uRecorderMic140DataThread;

{
  ����� ����� MIC-140: ��������� TRecorderDeviceDataThread.

  ReadBlockFromDevice �������� callback ��������� (Device), ������� ������
  ���� ReadBlock �� ��� ��������� MDP-stream (��� Connect/Config � ������).
  ������ � prealloc � � ������� ������.
  ��. Docs/devices/mic140/protocol/ � Device/uRecorderDeviceDataThread.pas.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs,
  uRecorderAcquisitionTypes, uRecorderDeviceDataThread;

type
  { ���� ���� �� �������; True = ���� �����. ����� ������ �� DataThread. }
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
  { ���� ��� ��������� Device.Start �� StartPlay. }
end;

procedure TRecorderMic140DataThread.OnStop;
begin
  { ������� ����� ������ Device.Stop ����� StopPlay. }
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
