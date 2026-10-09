unit uRecorderPxiMx248DeviceAdapter;

{
  Production adapter from the V2 MX-248 core to RecorderLnx IRecorderDevice.
  It translates the legacy procedure-based lifecycle without hiding stages:
  Connect, InitializeDevice, ConfigureDevice, Start, Stop and Disconnect each
  call exactly one core stage. ProgramDevice is the existing explicit composite.

  The adapter owns TPxiMx248Device. Expected block timeout returns False;
  other operation failures are retained in rdpError* and raised only where the
  legacy void interface cannot return TRecorderOperationResult. Streaming uses
  caller-owned buffers prepared before Start. See PXI/MX248/Docs/README.md.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Variants, uRecorderAcquisitionTypes, uRecorderDeviceInterfaces,
  uRecorderDriverContractsV2, uRecorderPxiMx248Device, uRecorderPxiMx248Types,
  uRecorderPxiMx248RuntimeTransport;

type
  TRecorderPxiMx248DeviceAdapter = class(TRecorderDevice)
  private
    fBlock: TRecorderAcquisitionBlock;
    fBlockTransport: IPxiMx248BlockTransport;
    fCore: TPxiMx248Device;
    fLastErrorCode: TRecorderOperationCode;
    fLastErrorText: string;
    procedure ApplyResult(const AResult: TRecorderOperationResult);
    procedure PrepareReadBuffer;
    procedure RaiseOnFailure(const AResult: TRecorderOperationResult);
    procedure SyncLegacyState;
  protected
    function BuildChannelName(AIndex: Integer): string; override;
    function BuildChannelAddress(AIndex: Integer): string; override;
    function GetChannels: TRecorderDeviceChannelArray; override;
  public
    constructor Create(const ADeviceId, AName: string;
      const ATransport: IPxiMx248BlockTransport); reintroduce;
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
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderAcquisitionBlock): Boolean; override;
    function TestLink(out AErrorText: string): Boolean; override;
  end;

implementation

function PropertyValue(const AResponse: string): string;
var
  lPos: SizeInt;
begin
  lPos := Pos('=', AResponse);
  if lPos > 0 then Result := Copy(AResponse, lPos + 1, MaxInt)
  else Result := AResponse;
end;

constructor TRecorderPxiMx248DeviceAdapter.Create(const ADeviceId, AName: string;
  const ATransport: IPxiMx248BlockTransport);
begin
  if ATransport = nil then
    raise EArgumentNilException.Create('MX-248 block transport is required');
  inherited Create(ADeviceId, AName);
  fBlockTransport := ATransport;
  fCore := TPxiMx248Device.Create(ATransport);
  fChannelCount := CPxiMx248ChannelCount;
  fPollFrequencyHz := 1000.0;
  fUpdateTimeMs := 256;
  fLastErrorCode := rocOk;
  PrepareReadBuffer;
end;

destructor TRecorderPxiMx248DeviceAdapter.Destroy;
begin
  fCore.Free;
  fBlockTransport := nil;
  inherited Destroy;
end;

procedure TRecorderPxiMx248DeviceAdapter.ApplyResult(
  const AResult: TRecorderOperationResult);
begin
  fLastErrorCode := AResult.Code;
  if AResult.IsSuccess then
    fLastErrorText := ''
  else
    fLastErrorText := AResult.Stage + ': ' + AResult.MessageText;
  SyncLegacyState;
end;

procedure TRecorderPxiMx248DeviceAdapter.RaiseOnFailure(
  const AResult: TRecorderOperationResult);
begin
  ApplyResult(AResult);
  if not AResult.IsSuccess then
    raise ERecorderDeviceError.Create(fLastErrorText);
end;

procedure TRecorderPxiMx248DeviceAdapter.SyncLegacyState;
begin
  case fCore.State of
    pmsCreated, pmsOffline: fState := rdsDisconnected;
    pmsConnected, pmsInitialized: fState := rdsConnected;
    pmsConfigured: fState := rdsProgrammed;
    pmsRunning: fState := rdsStarted;
  end;
end;

procedure TRecorderPxiMx248DeviceAdapter.PrepareReadBuffer;
var
  lBlockSamples: Integer;
  lResult: TRecorderOperationResult;
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

function TRecorderPxiMx248DeviceAdapter.BuildChannelName(AIndex: Integer): string;
begin
  Result := Format('MX-248 AIn%d', [AIndex + 1]);
end;

function TRecorderPxiMx248DeviceAdapter.BuildChannelAddress(AIndex: Integer): string;
begin
  Result := IntToStr(AIndex + 1);
end;

function TRecorderPxiMx248DeviceAdapter.GetChannels: TRecorderDeviceChannelArray;
var
  I: Integer;
  lResult: TRecorderOperationResult;
  lText: string;
begin
  Result := inherited GetChannels;
  lResult := fCore.GetProperties('sample-rate-hz', lText);
  if lResult.IsSuccess then
    TryStrToFloat(PropertyValue(lText), fPollFrequencyHz);
  for I := 0 to High(Result) do
  begin
    Result[I].UnitName := 'V';
    Result[I].ModuleType := 'PXI MX-248';
    Result[I].PollFrequencyHz := fPollFrequencyHz;
    lResult := fCore.GetProperties(Format('channel.%d.enabled', [I + 1]), lText);
    Result[I].Enabled := lResult.IsSuccess and
      SameText(PropertyValue(lText), 'True');
  end;
end;

function TRecorderPxiMx248DeviceAdapter.GetDeviceProperty(
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

function TRecorderPxiMx248DeviceAdapter.GetProp(const AName: string;
  AIndex: Integer): string;
var
  lResult: TRecorderOperationResult;
begin
  lResult := fCore.GetProperties(AName, Result);
  ApplyResult(lResult);
  if not lResult.IsSuccess then Result := '';
end;

function TRecorderPxiMx248DeviceAdapter.SetProp(const AText: string;
  AIndex: Integer): Boolean;
var
  lResult: TRecorderOperationResult;
begin
  if fState = rdsStarted then Exit(False);
  lResult := fCore.SetProperties(AText);
  ApplyResult(lResult);
  Result := lResult.IsSuccess;
  if Result then PrepareReadBuffer;
end;

procedure TRecorderPxiMx248DeviceAdapter.Connect;
begin
  RaiseOnFailure(fCore.Connect);
end;

procedure TRecorderPxiMx248DeviceAdapter.Disconnect;
begin
  fCore.Disconnect;
  fLastErrorCode := rocOk;
  fLastErrorText := '';
  SyncLegacyState;
end;

procedure TRecorderPxiMx248DeviceAdapter.InitializeDevice;
begin
  RaiseOnFailure(fCore.Initialize);
end;

procedure TRecorderPxiMx248DeviceAdapter.ConfigureDevice;
begin
  PrepareReadBuffer;
  RaiseOnFailure(fCore.Configure);
end;

procedure TRecorderPxiMx248DeviceAdapter.Start;
begin
  RaiseOnFailure(fCore.Start);
end;

procedure TRecorderPxiMx248DeviceAdapter.Stop;
begin
  RaiseOnFailure(fCore.Stop);
end;

function TRecorderPxiMx248DeviceAdapter.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderAcquisitionBlock): Boolean;
var
  lResult: TRecorderOperationResult;
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
    ApplyResult(TRecorderOperationResult.Failure(rocProtocol,
      'mx248.read', 'Invalid acquisition block dimensions'));
    Exit;
  end;
  ABlock := fBlock;
  Result := fBlock.SampleCount > 0;
end;

function TRecorderPxiMx248DeviceAdapter.TestLink(
  out AErrorText: string): Boolean;
var
  lResult: TRecorderOperationResult;
begin
  lResult := fCore.TestLink;
  ApplyResult(lResult);
  AErrorText := fLastErrorText;
  Result := lResult.IsSuccess;
end;

end.
