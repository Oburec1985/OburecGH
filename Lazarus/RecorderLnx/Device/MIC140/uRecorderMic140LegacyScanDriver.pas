unit uRecorderMic140LegacyScanDriver;

{
  Legacy MIC-140 scan transport. Wraps IMic140Device TCP/MDP read path
  behind TRecorderMic140ProtocolDriver virtual methods.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uRecorderDeviceInterfaces, uRecorderMic140ProtocolDriver,
  uRecorderMic140ScanConfig, uRecorderMic140StreamTypes,
  uRecorderMic140DeviceApi;

type
  TRecorderMic140LegacyScanDriver = class(TRecorderMic140ProtocolDriver)
  private
    fDevice: IRecorderDevice;
    fMic: IMic140Device;
  public
    constructor Create(AConfig: TRecorderMic140ScanConfig;
      ADevice: IRecorderDevice; AMic140: IMic140Device); reintroduce;
    function ProtocolKind: TRecorderMic140ProtocolKind; override;
    function Connect(out AError: string): Boolean; override;
    procedure Disconnect; override;
    function ProgramDevice(out AError: string): Boolean; override;
    function StartScan(out AError: string): Boolean; override;
    function StopScan: Boolean; override;
    function ReadRawBlock(out ARaw: TMic140LegacyRawBlock): Boolean; override;
    function Decommutate(const ARaw: TMic140LegacyRawBlock;
      out ABlock: TRecorderDeviceSampleBlock): Boolean; override;
    function TryRestartAfterReadStall: Boolean; override;
    function StreamReadCount: Int64; override;
  end;

implementation

constructor TRecorderMic140LegacyScanDriver.Create(
  AConfig: TRecorderMic140ScanConfig; ADevice: IRecorderDevice;
  AMic140: IMic140Device);
begin
  inherited Create(AConfig);
  fDevice := ADevice;
  fMic := AMic140;
end;

function TRecorderMic140LegacyScanDriver.ProtocolKind: TRecorderMic140ProtocolKind;
begin
  Result := mpkLegacy;
end;

function TRecorderMic140LegacyScanDriver.Connect(out AError: string): Boolean;
begin
  AError := '';
  Result := False;
  if fDevice = nil then
  begin
    AError := 'legacy driver: device is nil';
    Exit;
  end;
  try
    fDevice.Connect;
    fConnected := fDevice.State <> rdsDisconnected;
    Result := fConnected;
    if not Result then
      AError := 'connection failed';
  except
    on E: Exception do
    begin
      AError := E.Message;
      fConnected := False;
    end;
  end;
end;

procedure TRecorderMic140LegacyScanDriver.Disconnect;
begin
  if fDevice <> nil then
  begin
    try
      fDevice.Disconnect;
    except
    end;
  end;
  fConnected := False;
  fStreaming := False;
end;

function TRecorderMic140LegacyScanDriver.ProgramDevice(out AError: string): Boolean;
begin
  AError := '';
  Result := False;
  if fDevice = nil then
    Exit;
  try
    fDevice.ProgramDevice;
    Result := fDevice.State in [rdsProgrammed, rdsStarted];
    if not Result then
      AError := 'programming failed';
  except
    on E: Exception do
      AError := E.Message;
  end;
end;

function TRecorderMic140LegacyScanDriver.StartScan(out AError: string): Boolean;
begin
  AError := '';
  Result := False;
  if fDevice = nil then
    Exit;
  try
    fDevice.Start;
    fStreaming := fDevice.State = rdsStarted;
    Result := fStreaming;
    if not Result then
      AError := 'start failed';
  except
    on E: Exception do
      AError := E.Message;
  end;
end;

function TRecorderMic140LegacyScanDriver.StopScan: Boolean;
begin
  Result := False;
  if fDevice = nil then
    Exit;
  try
    fDevice.Stop;
    fStreaming := False;
    Result := True;
  except
    Result := False;
  end;
end;

function TRecorderMic140LegacyScanDriver.ReadRawBlock(
  out ARaw: TMic140LegacyRawBlock): Boolean;
begin
  Result := False;
  if fMic = nil then
    Exit;
  Result := fMic.ReadLegacyRawBlock(fConfig.ReadTimeoutMs, ARaw);
end;

function TRecorderMic140LegacyScanDriver.Decommutate(const ARaw: TMic140LegacyRawBlock;
  out ABlock: TRecorderDeviceSampleBlock): Boolean;
begin
  Result := False;
  if fMic = nil then
    Exit;
  Result := fMic.LegacyDecommutateRawBlock(ARaw, ABlock);
end;

function TRecorderMic140LegacyScanDriver.TryRestartAfterReadStall: Boolean;
begin
  Result := False;
  if fMic <> nil then
    Result := fMic.LegacyTryRestartStreamAfterReadStall;
end;

function TRecorderMic140LegacyScanDriver.StreamReadCount: Int64;
begin
  Result := 0;
  if fMic <> nil then
    Result := fMic.LegacyStreamReadCount;
end;

end.
