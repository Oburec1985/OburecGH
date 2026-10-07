unit uRecorderAudioDacBackend;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderDacTypes, uRecorderDacContracts, uRecorderPortAudioApi;

type
  { One PortAudio backend is used on Windows and Linux. }
  TRecorderAudioDacBackend = class(TInterfacedObject, IRecorderDacBackend)
  private
    fApi: TRecorderPortAudioApi;
    fStream: TPaStream;
    fEndpoint: string;
    fState: TRecorderDacState;
    fConfig: TRecorderDacConfig;
    fFloatBuffer: array of Single;
    fPortAudioInitialized: Boolean;
    function Check(AError: TPaError; AStage: TRecorderDacStage;
      out AResult: TRecorderDacResult): Boolean;
    function RequireState(AExpected: TRecorderDacState;
      AStage: TRecorderDacStage; out AResult: TRecorderDacResult): Boolean;
    procedure CloseNativeStream;
  public
    constructor Create(const AEndpoint: string);
    destructor Destroy; override;
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
  end;

  TRecorderAudioDacFactory = class(TRecorderDacBackendFactory)
  public
    function BackendId: string; override;
    function CreateBackend(const AEndpoint: string): IRecorderDacBackend; override;
  end;

implementation

uses SysUtils;

constructor TRecorderAudioDacBackend.Create(const AEndpoint: string);
begin
  inherited Create;
  fEndpoint := AEndpoint;
  if fEndpoint = '' then fEndpoint := 'default';
  fApi := TRecorderPortAudioApi.Create;
  fState := rdsClosed;
end;

destructor TRecorderAudioDacBackend.Destroy;
var
  lResult: TRecorderDacResult;
begin
  if fState = rdsRunning then Stop(lResult);
  if fState <> rdsClosed then Disconnect(lResult);
  fApi.Free;
  inherited Destroy;
end;

function TRecorderAudioDacBackend.BackendId: string;
begin
  Result := 'audio.portaudio';
end;

function TRecorderAudioDacBackend.Endpoint: string;
begin
  Result := fEndpoint;
end;

function TRecorderAudioDacBackend.State: TRecorderDacState;
begin
  Result := fState;
end;

function TRecorderAudioDacBackend.Check(AError: TPaError;
  AStage: TRecorderDacStage; out AResult: TRecorderDacResult): Boolean;
begin
  Result := AError = CPaNoError;
  if Result then AResult := RecorderDacOk
  else AResult := RecorderDacFailed(rdeDriver, AStage,
    fApi.ErrorText(AError), AError);
end;

function TRecorderAudioDacBackend.RequireState(AExpected: TRecorderDacState;
  AStage: TRecorderDacStage; out AResult: TRecorderDacResult): Boolean;
begin
  Result := fState = AExpected;
  if not Result then AResult := RecorderDacFailed(rdeInvalidState, AStage,
    'PortAudio DAC lifecycle state mismatch');
end;

function TRecorderAudioDacBackend.Connect(out AResult: TRecorderDacResult): Boolean;
var
  lText: string;
begin
  if not RequireState(rdsClosed, rdsgConnect, AResult) then Exit(False);
  Result := fApi.Load(lText);
  if not Result then
  begin
    AResult := RecorderDacFailed(rdeDriver, rdsgConnect, lText);
    Exit;
  end;
  fState := rdsConnected;
  AResult := RecorderDacOk;
end;

function TRecorderAudioDacBackend.Initialize(
  out AResult: TRecorderDacResult): Boolean;
begin
  if not RequireState(rdsConnected, rdsgInitialize, AResult) then Exit(False);
  Result := Check(fApi.Initialize(), rdsgInitialize, AResult);
  if Result then
  begin
    fPortAudioInitialized := True;
    fState := rdsInitialized;
  end;
end;

function TRecorderAudioDacBackend.ReadProperties(
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := RequireState(rdsInitialized, rdsgReadProperties, AResult);
  if Result then AResult := RecorderDacOk;
end;

function TRecorderAudioDacBackend.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
var
  lError: TPaError;
begin
  if not RequireState(rdsInitialized, rdsgConfigure, AResult) then Exit(False);
  if not RecorderDacValidateConfig(AConfig, AResult) then Exit(False);
  if (AConfig.MinimumValue < -1) or (AConfig.MaximumValue > 1) or
    (AConfig.SafeValue < -1) or (AConfig.SafeValue > 1) then
  begin
    AResult := RecorderDacFailed(rdeUnsupported, rdsgConfigure,
      'PortAudio float output uses normalized values from -1 to +1');
    Exit(False);
  end;
  if not SameText(fEndpoint, 'default') then
  begin
    AResult := RecorderDacFailed(rdeUnsupported, rdsgConfigure,
      'The first PortAudio backend supports the default output device only');
    Exit(False);
  end;
  lError := fApi.OpenDefaultStream(@fStream, 0, AConfig.ChannelCount,
    CPaFloat32, AConfig.SampleRateHz, AConfig.FramesPerBlock, nil, nil);
  Result := Check(lError, rdsgConfigure, AResult);
  if not Result then Exit;
  fConfig := AConfig;
  SetLength(fFloatBuffer, AConfig.FramesPerBlock * AConfig.ChannelCount);
  fState := rdsConfigured;
end;

procedure TRecorderAudioDacBackend.Abort;
begin
  if (fState = rdsRunning) or (fState = rdsStopping) then
  begin
    fApi.AbortStream(fStream);
    fState := rdsConfigured;
  end;
end;

function TRecorderAudioDacBackend.Start(out AResult: TRecorderDacResult): Boolean;
begin
  if not RequireState(rdsConfigured, rdsgStart, AResult) then Exit(False);
  Result := Check(fApi.StartStream(fStream), rdsgStart, AResult);
  if Result then fState := rdsRunning;
end;

function TRecorderAudioDacBackend.SubmitBlock(ABuffer: PDouble;
  AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
var
  I, lSampleCount: Integer;
begin
  if not RequireState(rdsRunning, rdsgWrite, AResult) then Exit(False);
  lSampleCount := AFrameCount * fConfig.ChannelCount;
  if lSampleCount > Length(fFloatBuffer) then
  begin
    AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
      'PortAudio block exceeds configured capacity');
    Exit(False);
  end;
  for I := 0 to lSampleCount - 1 do fFloatBuffer[I] := ABuffer[I];
  Result := Check(fApi.WriteStream(fStream, @fFloatBuffer[0], AFrameCount),
    rdsgWrite, AResult);
end;

function TRecorderAudioDacBackend.Stop(out AResult: TRecorderDacResult): Boolean;
var
  I: Integer;
begin
  if not RequireState(rdsRunning, rdsgStop, AResult) then Exit(False);
  fState := rdsStopping;
  for I := 0 to Length(fFloatBuffer) - 1 do
    fFloatBuffer[I] := fConfig.SafeValue;
  if not Check(fApi.WriteStream(fStream, @fFloatBuffer[0],
    fConfig.FramesPerBlock), rdsgStop, AResult) then
  begin
    fApi.AbortStream(fStream);
    fState := rdsOffline;
    Exit(False);
  end;
  Result := Check(fApi.StopStream(fStream), rdsgStop, AResult);
  if Result then fState := rdsConfigured else fState := rdsOffline;
end;

procedure TRecorderAudioDacBackend.CloseNativeStream;
begin
  if fStream = nil then Exit;
  fApi.CloseStream(fStream);
  fStream := nil;
end;

function TRecorderAudioDacBackend.Disconnect(
  out AResult: TRecorderDacResult): Boolean;
var
  lError: TPaError;
begin
  if fState = rdsRunning then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgDisconnect,
      'Stop PortAudio DAC before disconnect');
    Exit(False);
  end;
  CloseNativeStream;
  lError := CPaNoError;
  if fPortAudioInitialized then lError := fApi.Terminate();
  fPortAudioInitialized := False;
  Result := Check(lError, rdsgDisconnect, AResult);
  fApi.Unload;
  fState := rdsClosed;
end;

function TRecorderAudioDacFactory.BackendId: string;
begin
  Result := 'audio.portaudio';
end;

function TRecorderAudioDacFactory.CreateBackend(
  const AEndpoint: string): IRecorderDacBackend;
begin
  Result := TRecorderAudioDacBackend.Create(AEndpoint);
end;

end.
