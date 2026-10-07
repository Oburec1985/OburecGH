unit uRecorderNullDacBackend;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderDacTypes, uRecorderDacContracts;

type
  TRecorderNullDacBackend = class(TInterfacedObject, IRecorderDacBackend)
  private
    fEndpoint: string;
    fState: TRecorderDacState;
    fConfig: TRecorderDacConfig;
    fLastBlock: array of Double;
    fSubmittedFrames: QWord;
    function RequireState(AExpected: TRecorderDacState;
      AStage: TRecorderDacStage; out AResult: TRecorderDacResult): Boolean;
  public
    constructor Create(const AEndpoint: string);
    function BackendId: string;
    function Endpoint: string;
    function State: TRecorderDacState;
    function Connect(out AResult: TRecorderDacResult): Boolean;
    function Initialize(out AResult: TRecorderDacResult): Boolean;
    function ReadProperties(out AResult: TRecorderDacResult): Boolean;
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function Start(out AResult: TRecorderDacResult): Boolean;
    function SubmitBlock(ABuffer: PDouble; AFrameCount: Integer;
      out AResult: TRecorderDacResult): Boolean;
    function Stop(out AResult: TRecorderDacResult): Boolean;
    procedure Abort;
    function Disconnect(out AResult: TRecorderDacResult): Boolean;
    property SubmittedFrames: QWord read fSubmittedFrames;
  end;

  TRecorderNullDacFactory = class(TRecorderDacBackendFactory)
  public
    function BackendId: string; override;
    function CreateBackend(const AEndpoint: string): IRecorderDacBackend; override;
  end;

implementation

constructor TRecorderNullDacBackend.Create(const AEndpoint: string);
begin
  inherited Create;
  fEndpoint := AEndpoint;
  fState := rdsClosed;
end;

function TRecorderNullDacBackend.BackendId: string;
begin
  Result := 'null';
end;

function TRecorderNullDacBackend.Endpoint: string;
begin
  Result := fEndpoint;
end;

function TRecorderNullDacBackend.State: TRecorderDacState;
begin
  Result := fState;
end;

function TRecorderNullDacBackend.RequireState(AExpected: TRecorderDacState;
  AStage: TRecorderDacStage; out AResult: TRecorderDacResult): Boolean;
begin
  Result := fState = AExpected;
  if not Result then
    AResult := RecorderDacFailed(rdeInvalidState, AStage,
      'Null DAC lifecycle state mismatch');
end;

function TRecorderNullDacBackend.Connect(out AResult: TRecorderDacResult): Boolean;
begin
  Result := RequireState(rdsClosed, rdsgConnect, AResult);
  if Result then begin fState := rdsConnected; AResult := RecorderDacOk; end;
end;

function TRecorderNullDacBackend.Initialize(out AResult: TRecorderDacResult): Boolean;
begin
  Result := RequireState(rdsConnected, rdsgInitialize, AResult);
  if Result then begin fState := rdsInitialized; AResult := RecorderDacOk; end;
end;

function TRecorderNullDacBackend.ReadProperties(out AResult: TRecorderDacResult): Boolean;
begin
  Result := RequireState(rdsInitialized, rdsgReadProperties, AResult);
  if Result then AResult := RecorderDacOk;
end;

function TRecorderNullDacBackend.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := RequireState(rdsInitialized, rdsgConfigure, AResult) and
    RecorderDacValidateConfig(AConfig, AResult);
  if Result then
  begin
    fConfig := AConfig;
    SetLength(fLastBlock, AConfig.FramesPerBlock * AConfig.ChannelCount);
    fState := rdsConfigured;
  end;
end;

function TRecorderNullDacBackend.Start(out AResult: TRecorderDacResult): Boolean;
begin
  Result := RequireState(rdsConfigured, rdsgStart, AResult);
  if Result then begin fState := rdsRunning; AResult := RecorderDacOk; end;
end;

function TRecorderNullDacBackend.SubmitBlock(ABuffer: PDouble;
  AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
var
  lSampleCount: Integer;
begin
  Result := RequireState(rdsRunning, rdsgWrite, AResult);
  if not Result then Exit;
  lSampleCount := AFrameCount * fConfig.ChannelCount;
  if lSampleCount > Length(fLastBlock) then
  begin
    AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
      'Null DAC block exceeds configured capacity');
    Exit(False);
  end;
  Move(ABuffer^, fLastBlock[0], lSampleCount * SizeOf(Double));
  Inc(fSubmittedFrames, AFrameCount);
  AResult := RecorderDacOk;
end;

function TRecorderNullDacBackend.Stop(out AResult: TRecorderDacResult): Boolean;
var
  I: Integer;
begin
  Result := RequireState(rdsRunning, rdsgStop, AResult);
  if Result then
  begin
    for I := 0 to Length(fLastBlock) - 1 do
      fLastBlock[I] := fConfig.SafeValue;
    fState := rdsConfigured;
    AResult := RecorderDacOk;
  end;
end;

procedure TRecorderNullDacBackend.Abort;
begin
  if fState = rdsRunning then fState := rdsConfigured;
end;

function TRecorderNullDacBackend.Disconnect(out AResult: TRecorderDacResult): Boolean;
begin
  Result := fState in [rdsConnected, rdsInitialized, rdsConfigured, rdsOffline];
  if Result then begin fState := rdsClosed; AResult := RecorderDacOk; end
  else AResult := RecorderDacFailed(rdeInvalidState, rdsgDisconnect,
    'Stop DAC before disconnect');
end;

function TRecorderNullDacFactory.BackendId: string;
begin
  Result := 'null';
end;

function TRecorderNullDacFactory.CreateBackend(
  const AEndpoint: string): IRecorderDacBackend;
begin
  Result := TRecorderNullDacBackend.Create(AEndpoint);
end;

end.
