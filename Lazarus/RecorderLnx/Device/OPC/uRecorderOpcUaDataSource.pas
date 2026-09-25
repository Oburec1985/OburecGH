unit uRecorderOpcUaDataSource;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderDataSources, uRecorderTags,
  uRecorderDeviceInterfaces, uRecorderOpcUaDevice, uRecorderOpcUaTypes;

type
  { Tag/worker adapter. The protocol session belongs to the device; this class
    only binds stable Recorder tags to device channels. }
  TRecorderOpcUaDataSource = class(TRecorderDataSourceBase)
  private
    fDevice: IRecorderDevice;
    fNodeTags: array of TRecorderTag;
    fNextPrepareAtMs: QWord;
    fPrepared: Boolean;
    fPrepareError: string;
    fBindingError: string;
    function OpcDevice: TRecorderOpcUaDevice;
    function BindServerNodes: Boolean;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ADevice: IRecorderDevice; AUpdateTimeMs: Cardinal);
    procedure PrepareHardware; override;
    procedure Start; override;
    procedure Stop; override;
    property Device: IRecorderDevice read fDevice;
    property PrepareError: string read fPrepareError;
  end;

implementation

uses
  Math, uRecorderDebugLog;

const
  CRecorderOpcUaReconnectDelayMs = 5000;

constructor TRecorderOpcUaDataSource.Create(const ADevice: IRecorderDevice;
  AUpdateTimeMs: Cardinal);
begin
  if ADevice = nil then
    raise EArgumentNilException.Create('OPC UA device is required');
  fDevice := ADevice;
  inherited Create(ADevice.DeviceId, CRecorderOpcUaModuleType,
    Max(10, AUpdateTimeMs));
end;

function TRecorderOpcUaDataSource.OpcDevice: TRecorderOpcUaDevice;
begin
  Result := TRecorderOpcUaDevice(fDevice.GetNativeObject);
end;

procedure TRecorderOpcUaDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lName: string;
  lNode: TRecorderOpcUaNode;
begin
  fBindingError := '';
  SetLength(fNodeTags, OpcDevice.NodeCount);
  for I := 0 to OpcDevice.NodeCount - 1 do
  begin
    lNode := OpcDevice.Node(I);
    lName := lNode.TagName;
    if lName = '' then lName := lNode.NodeId;
    fNodeTags[I] := ARegistry.FindByName(lName);
    if OpcDevice.Config.Mode = oumServer then
    begin
      if fNodeTags[I] = nil then
        fBindingError := Format('OPC UA server tag "%s" was not found',
          [lName]);
      Continue;
    end;
    if fNodeTags[I] = nil then
      fNodeTags[I] := ARegistry.CreateTag(lName, 4096);
    fNodeTags[I].SourceId := SourceId;
    fNodeTags[I].Address := lNode.NodeId;
    fNodeTags[I].ModuleType := CRecorderOpcUaModuleType;
    fNodeTags[I].ExternalWriteAllowed := lNode.Writable;
    fNodeTags[I].PollFrequencyHz := 1000.0 /
      Max(10, OpcDevice.Config.PublishingIntervalMs);
  end;
end;

function TRecorderOpcUaDataSource.BindServerNodes: Boolean;
var
  I: Integer;
  lValue: Double;
begin
  Result := True;
  if OpcDevice.Config.Mode <> oumServer then Exit;
  for I := 0 to High(fNodeTags) do
  begin
    if fNodeTags[I] = nil then Exit(False);
    lValue := 0;
    if fNodeTags[I].SignalBuffer.Count > 0 then
      lValue := fNodeTags[I].SignalBuffer.LatestValue;
    if not OpcDevice.ConfigureServerNode(I, fNodeTags[I].Name, lValue) then
      Exit(False);
  end;
end;

procedure TRecorderOpcUaDataSource.PrepareHardware;
begin
  fPrepared := False;
  if (OpcDevice.Config.Mode = oumClient) and (OpcDevice.NodeCount = 0) then
  begin
    fPrepareError := 'Не выбраны OPC UA-каналы';
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    Exit;
  end;
  if fBindingError <> '' then
  begin
    fPrepareError := fBindingError;
    Exit;
  end;
  fPrepareError := '';
  fDevice.Disconnect;
  fDevice.Connect;
  if fDevice.State = rdsDisconnected then
  begin
    fPrepareError := OpcDevice.LastError;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    Exit;
  end;
  fDevice.InitializeDevice;
  fDevice.ConfigureDevice;
  if fDevice.State <> rdsProgrammed then
  begin
    fPrepareError := OpcDevice.LastError;
    fDevice.Disconnect;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    Exit;
  end;
  if not BindServerNodes then
  begin
    fPrepareError := OpcDevice.LastError;
    fDevice.Disconnect;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    Exit;
  end;
  fDevice.Start;
  fPrepared := fDevice.State = rdsStarted;
  if not fPrepared then
  begin
    fPrepareError := OpcDevice.LastError;
    fDevice.Disconnect;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
  end;
  if fPrepared then fNextPrepareAtMs := 0;
  if (not fPrepared) and (fPrepareError <> '') then
    RecorderDebugLog(Format('[OPC UA] source=%s error=%s',
      [SourceId, fPrepareError]));
end;

procedure TRecorderOpcUaDataSource.Start;
begin
  if not fPrepared then PrepareHardware;
  { Expected network failures are retried by the worker and do not escape into
    the UI. This matches the MIC-140 source lifecycle. }
  inherited Start;
end;

procedure TRecorderOpcUaDataSource.DoTick;
var
  I: Integer;
  lQuality: Cardinal;
  lTime, lValue: Double;
begin
  if not fPrepared then
  begin
    if GetTickCount64 < fNextPrepareAtMs then Exit;
    PrepareHardware;
    if not fPrepared then Exit;
  end;
  if not OpcDevice.Iterate then
  begin
    fPrepareError := OpcDevice.LastError;
    fDevice.Disconnect;
    fPrepared := False;
    fNextPrepareAtMs := GetTickCount64 + CRecorderOpcUaReconnectDelayMs;
    RecorderDebugLog(Format(
      '[OPC UA] source=%s connection lost; reconnect in %d ms: %s',
      [SourceId, CRecorderOpcUaReconnectDelayMs, fPrepareError]));
    Exit;
  end;
  if OpcDevice.Config.Mode = oumServer then
  begin
    for I := 0 to High(fNodeTags) do
      if (fNodeTags[I] <> nil) and (fNodeTags[I].SignalBuffer.Count > 0) then
        OpcDevice.WriteServerValue(I,
          fNodeTags[I].SignalBuffer.LatestValue);
    Exit;
  end;
  for I := 0 to High(fNodeTags) do
    if OpcDevice.ReadChanged(I, lValue, lTime, lQuality) then
      { OPC UA SourceTimestamp is absolute Unix time. Recorder tags use the
        project elapsed-time scale, which the registry supplies here. }
      Registry.PublishValue(fNodeTags[I], lValue);
end;

procedure TRecorderOpcUaDataSource.Stop;
begin
  fDevice.Stop;
  fPrepared := False;
  inherited Stop;
end;

end.
