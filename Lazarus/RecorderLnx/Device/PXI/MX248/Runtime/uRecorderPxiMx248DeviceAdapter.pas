unit uRecorderPxiMx248DeviceAdapter;

{
  Production adapter from the V2 MX-248 core to RecorderLnx IRecorderDevice.
  It translates the legacy procedure-based lifecycle without hiding stages:
  Connect, InitializeDevice, ConfigureDevice, Start, Stop and Disconnect each
  map to the corresponding hardware stage. Configure also restores the PXI
  control plane before Start; Apply must refresh the same persisted settings.
  ProgramDevice is the existing explicit composite.

  The adapter owns TPxiMx248Device. Expected block timeout returns False;
  other operation failures are retained in rdpError* and raised only where the
  legacy void interface cannot return TRecorderOperationResult. Streaming uses
  caller-owned buffers prepared before Start. See PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Variants, uRecorderAcquisitionTypes, uRecorderDeviceInterfaces,
  uRecorderDriverContractsV2, uRecorderPxiMx248Device, uRecorderPxiMx248Types,
  uRecorderPxiMx248RuntimeTransport;

type
  TRcPxiMx248DeviceAdapter = class(TRcDevice,
    IPxiMx248MaintenanceDevice, IPxiMx248LiveControlDevice)
  private
    fBlock: TRcAcquisitionBlock;
    fBlockTransport: IPxiMx248BlockTransport;
    fCore: TPxiMx248Device;
    fSourceAddress: string;
    fLastErrorCode: TRcOperationCode;
    fLastErrorText: string;
    fRtsiClock, fRtsiSync, fTriggerMode, fTriggerSource,
      fTriggerLevel: Integer;
    procedure ApplyResult(const AResult: TRcOperationResult);
    procedure PrepareReadBuffer;
    procedure RaiseOnFailure(const AResult: TRcOperationResult);
    procedure SyncLegacyState;
  protected
    function BuildChannelName(AIndex: Integer): string; override;
    function BuildChannelAddress(AIndex: Integer): string; override;
    function GetChannels: TRecorderDeviceChannelArray; override;
  public
    constructor Create(const ADeviceId, AName: string;
      const ATransport: IPxiMx248BlockTransport;
      const ASourceAddress: string = ''); reintroduce;
    destructor Destroy; override;
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant; override;
    function GetProp(const AName: string; AIndex: Integer = -1): string; override;
    function SetProp(const AText: string; AIndex: Integer = -1): Boolean; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure InitializeDevice; override;
    procedure ConfigureDevice; override;
    procedure Start; override;
    procedure Stop; override;
    procedure LoadPxiSettings(const AProperties: string);
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRcAcquisitionBlock): Boolean; override;
    function TestLink(out AErrorText: string): Boolean; override;
    function ZeroBalance(AChannelMask: Cardinal; out AValues: string): TRcOperationResult;
    function ReadLiveProperties(out AProperties: string): TRcOperationResult;
    function ApplyLive(const AProperties: string; ARtsiClock, ARtsiSync,
      ATriggerMode, ATriggerSource, ATriggerLevel: Integer;
      out AReadback: string): TRcOperationResult;
  end;

implementation

uses
  uRecorderPxiMx248Addressing;

function TRcPxiMx248DeviceAdapter.ReadLiveProperties(
  out AProperties: string): TRcOperationResult;
var
  lMaintenance: IPxiMx248MaintenanceTransport;
begin
  AProperties := '';
  if not Supports(fBlockTransport, IPxiMx248MaintenanceTransport,
    lMaintenance) then
    Exit(TRcOperationResult.Failure(rocUnsupported,
      'mx248.runtime.read', 'Transport does not support maintenance'));
  Result := lMaintenance.ReadLiveProperties(AProperties);
  ApplyResult(Result);
end;

function TRcPxiMx248DeviceAdapter.ApplyLive(const AProperties: string;
  ARtsiClock, ARtsiSync, ATriggerMode, ATriggerSource,
  ATriggerLevel: Integer; out AReadback: string): TRcOperationResult;
var
  lMaintenance: IPxiMx248MaintenanceTransport;
begin
  AReadback := '';
  if fCore.State = pmsRunning then
    Exit(TRcOperationResult.Failure(rocInvalidState,
      'mx248.runtime.apply', 'Stop acquisition before applying settings'));
  if not Supports(fBlockTransport, IPxiMx248MaintenanceTransport,
    lMaintenance) then
    Exit(TRcOperationResult.Failure(rocUnsupported,
      'mx248.runtime.apply', 'Transport does not support maintenance'));
  Result := fCore.SetProperties(AProperties);
  if Result.IsSuccess then Result := fCore.Configure;
  if Result.IsSuccess then Result := lMaintenance.ConfigurePxi(3, ARtsiClock,
    ARtsiSync, ATriggerMode, ATriggerSource, ATriggerLevel);
  if Result.IsSuccess then Result := lMaintenance.ReadLiveProperties(AReadback);
  if Result.IsSuccess then
  begin
    fRtsiClock:=ARtsiClock;
    fRtsiSync:=ARtsiSync;
    fTriggerMode:=ATriggerMode;
    fTriggerSource:=ATriggerSource;
    fTriggerLevel:=ATriggerLevel;
  end;
  ApplyResult(Result);
  if Result.IsSuccess then PrepareReadBuffer;
end;

function TRcPxiMx248DeviceAdapter.ZeroBalance(AChannelMask: Cardinal;
  out AValues: string): TRcOperationResult;
var
  lMaintenance: IPxiMx248MaintenanceTransport;
begin
  AValues := '';
  if fCore.State = pmsRunning then
    Exit(TRcOperationResult.Failure(rocInvalidState,
      'mx248.zero-balance', 'Stop acquisition before zero balance'));
  if fCore.State in [pmsCreated, pmsOffline] then
  begin
    Result := fCore.Connect;
    if not Result.IsSuccess then Exit;
  end;
  if fCore.State = pmsConnected then
  begin
    Result := fCore.Initialize;
    if not Result.IsSuccess then Exit;
  end;
  if not Supports(fBlockTransport, IPxiMx248MaintenanceTransport,
    lMaintenance) then
    Exit(TRcOperationResult.Failure(rocUnsupported,
      'mx248.zero-balance', 'Transport does not support maintenance'));
  Result := lMaintenance.ZeroBalance(AChannelMask, AValues);
  ApplyResult(Result);
end;

function PropertyValue(const AResponse: string): string;
var
  lPos: SizeInt;
begin
  lPos := Pos('=', AResponse);
  if lPos > 0 then Result := Copy(AResponse, lPos + 1, MaxInt)
  else Result := AResponse;
end;

constructor TRcPxiMx248DeviceAdapter.Create(const ADeviceId, AName: string;
  const ATransport: IPxiMx248BlockTransport; const ASourceAddress: string);
begin
  if ATransport = nil then
    raise EArgumentNilException.Create('MX-248 block transport is required');
  inherited Create(ADeviceId, AName);
  fSourceAddress := Trim(ASourceAddress);
  fBlockTransport := ATransport;
  fCore := TPxiMx248Device.Create(ATransport);
  fChannelCount := CPxiMx248ChannelCount;
  fPollFrequencyHz := 1000.0;
  fUpdateTimeMs := 256;
  fLastErrorCode := rocOk;
  LoadPxiSettings('');
  PrepareReadBuffer;
end;

procedure TRcPxiMx248DeviceAdapter.LoadPxiSettings(const AProperties: string);
var
  lValues: TStringList;
  lLine: string;
begin
  lValues := TStringList.Create;
  try
    lValues.StrictDelimiter := True;
    lValues.Delimiter := ';';
    lValues.DelimitedText := AProperties;
    fRtsiClock := 0;
    if SameText(lValues.Values['pxi.clock-source'], 'internal') then
      fRtsiClock := 3;
    fRtsiSync := 1;
    if SameText(lValues.Values['pxi.bus-role'], 'Slave') then fRtsiSync := 0
    else if SameText(lValues.Values['pxi.bus-role'], 'Hardwired') then
      fRtsiSync := 2;
    { Original Recorder configures TRIG_INTERNAL for the software Start pulse.
      An absent external trigger selection must not suppress that pulse. }
    fTriggerMode := 2;
    fTriggerSource := 0;
    lLine := lValues.Values['pxi.trigger-line'];
    if Pos('PXI_TRIG', UpperCase(lLine)) = 1 then
      fTriggerSource := StrToIntDef(Copy(lLine, 9, MaxInt), 0);
    fTriggerLevel := Ord(SameText(lValues.Values['pxi.trigger-level'], 'high') or
      SameText(lValues.Values['pxi.trigger-edge'], 'rising'));
  finally
    lValues.Free;
  end;
end;

destructor TRcPxiMx248DeviceAdapter.Destroy;
begin
  fCore.Free;
  fBlockTransport := nil;
  inherited Destroy;
end;

procedure TRcPxiMx248DeviceAdapter.ApplyResult(
  const AResult: TRcOperationResult);
begin
  fLastErrorCode := AResult.Code;
  if AResult.IsSuccess then
    fLastErrorText := ''
  else
    fLastErrorText := AResult.Stage + ': ' + AResult.MessageText;
  SyncLegacyState;
end;

procedure TRcPxiMx248DeviceAdapter.RaiseOnFailure(
  const AResult: TRcOperationResult);
begin
  ApplyResult(AResult);
  if not AResult.IsSuccess then
    raise ERecorderDeviceError.Create(fLastErrorText);
end;

procedure TRcPxiMx248DeviceAdapter.SyncLegacyState;
begin
  case fCore.State of
    pmsCreated, pmsOffline: fState := rdsDisconnected;
    pmsConnected, pmsInitialized: fState := rdsConnected;
    pmsConfigured: fState := rdsProgrammed;
    pmsRunning: fState := rdsStarted;
  end;
end;

procedure TRcPxiMx248DeviceAdapter.PrepareReadBuffer;
var
  lBlockSamples: Integer;
  lResult: TRcOperationResult;
  lText: string;
begin
  lResult := fCore.GetProperties('sample-rate-hz;block-samples', lText);
  RaiseOnFailure(lResult);
  if not TryStrToFloat(PropertyValue(Copy(lText, 1, Pos(';', lText) - 1)),
    fPollFrequencyHz) then fPollFrequencyHz := 1000.0;
  if not TryStrToInt(PropertyValue(Copy(lText, Pos(';', lText) + 1, MaxInt)),
    lBlockSamples) then lBlockSamples := 256;
  PreparePxiMx248Block(fBlock, CPxiMx248ChannelCount,
    lBlockSamples);
end;

function TRcPxiMx248DeviceAdapter.BuildChannelName(AIndex: Integer): string;
begin
  Result := Format('MX-248 AIn%d', [AIndex + 1]);
end;

function TRcPxiMx248DeviceAdapter.BuildChannelAddress(AIndex: Integer): string;
begin
  if fSourceAddress = '' then
    Result := IntToStr(AIndex + 1)
  else
    Result := PxiMx248ChannelAddress(fSourceAddress, AIndex + 1);
end;

function TRcPxiMx248DeviceAdapter.GetChannels: TRecorderDeviceChannelArray;
var
  I: Integer;
  lResult: TRcOperationResult;
  lText: string;
begin
  Result := inherited GetChannels;
  lResult := fCore.GetProperties('sample-rate-hz', lText);
  if lResult.IsSuccess then
    TryStrToFloat(PropertyValue(lText), fPollFrequencyHz);
  for I := 0 to High(Result) do
  begin
    lResult := fCore.GetProperties(Format('channel.%d.amplifier-enabled',
      [I + 1]), lText);
    if lResult.IsSuccess and SameText(PropertyValue(lText), 'True') then
      Result[I].UnitName := 'пКл'
    else Result[I].UnitName := 'V';
    Result[I].ModuleType := 'PXI MX-248';
    Result[I].PollFrequencyHz := fPollFrequencyHz;
    lResult := fCore.GetProperties(Format('channel.%d.enabled', [I + 1]), lText);
    Result[I].Enabled := lResult.IsSuccess and
      SameText(PropertyValue(lText), 'True');
  end;
end;

function TRcPxiMx248DeviceAdapter.GetDeviceProperty(
  AProperty: TRecorderDeviceProperty; AIndex: Integer): Variant;
begin
  case AProperty of
    rdpDeviceSerial: Result := fCore.SerialNumber;
    rdpErrorCode: Result := Ord(fLastErrorCode);
    rdpErrorText: Result := fLastErrorText;
  else
    Result := inherited GetDeviceProperty(AProperty, AIndex);
  end;
end;

function TRcPxiMx248DeviceAdapter.GetProp(const AName: string;
  AIndex: Integer): string;
var
  lResult: TRcOperationResult;
begin
  lResult := fCore.GetProperties(AName, Result);
  ApplyResult(lResult);
  if not lResult.IsSuccess then Result := '';
end;

function TRcPxiMx248DeviceAdapter.SetProp(const AText: string;
  AIndex: Integer): Boolean;
var
  lResult: TRcOperationResult;
begin
  if fState = rdsStarted then Exit(False);
  lResult := fCore.SetProperties(AText);
  ApplyResult(lResult);
  Result := lResult.IsSuccess;
  if Result then PrepareReadBuffer;
end;

procedure TRcPxiMx248DeviceAdapter.Connect;
begin
  RaiseOnFailure(fCore.Connect);
end;

procedure TRcPxiMx248DeviceAdapter.Disconnect;
begin
  fCore.Disconnect;
  fLastErrorCode := rocOk;
  fLastErrorText := '';
  SyncLegacyState;
end;

procedure TRcPxiMx248DeviceAdapter.InitializeDevice;
begin
  RaiseOnFailure(fCore.Initialize);
end;

procedure TRcPxiMx248DeviceAdapter.ConfigureDevice;
var
  lMaintenance: IPxiMx248MaintenanceTransport;
begin
  PrepareReadBuffer;
  RaiseOnFailure(fCore.Configure);
  if Supports(fBlockTransport, IPxiMx248MaintenanceTransport, lMaintenance) then
    RaiseOnFailure(lMaintenance.ConfigurePxi(3, fRtsiClock, fRtsiSync,
      fTriggerMode, fTriggerSource, fTriggerLevel));
end;

procedure TRcPxiMx248DeviceAdapter.Start;
begin
  RaiseOnFailure(fCore.Start);
end;

procedure TRcPxiMx248DeviceAdapter.Stop;
begin
  RaiseOnFailure(fCore.Stop);
end;

function TRcPxiMx248DeviceAdapter.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRcAcquisitionBlock): Boolean;
var
  lResult: TRcOperationResult;
begin
  Result := False;
  if fCore.State <> pmsRunning then Exit;
  lResult := fBlockTransport.ReadBlock(ATimeoutMs, fBlock);
  ApplyResult(lResult);
  if not lResult.IsSuccess then Exit;
  if (fBlock.ChannelCount <> CPxiMx248ChannelCount) or
    (fBlock.SampleCount < 0) or
    ((Length(fBlock.Values) > 0) and
     (fBlock.SampleCount > Length(fBlock.Values[0]))) then
  begin
    ApplyResult(TRcOperationResult.Failure(rocProtocol,
      'mx248.read', 'Invalid acquisition block dimensions'));
    Exit;
  end;
  ABlock := fBlock;
  Result := fBlock.SampleCount > 0;
end;

function TRcPxiMx248DeviceAdapter.TestLink(
  out AErrorText: string): Boolean;
var
  lResult: TRcOperationResult;
begin
  lResult := fCore.TestLink;
  ApplyResult(lResult);
  AErrorText := fLastErrorText;
  Result := lResult.IsSuccess;
end;

end.
