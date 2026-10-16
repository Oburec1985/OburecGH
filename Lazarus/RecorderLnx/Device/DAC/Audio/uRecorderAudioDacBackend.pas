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
    function DiscoverEndpoints(out AEndpoints: TRecorderDacEndpoints;
      out AResult: TRecorderDacResult): Boolean; override;
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
  lDeviceIndex: Integer;
  lDeviceInfo: PPaDeviceInfo;
  lOutput: TPaStreamParameters;
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
  if SameText(fEndpoint, 'default') then
    lError := fApi.OpenDefaultStream(@fStream, 0, AConfig.ChannelCount,
      CPaFloat32, AConfig.SampleRateHz, AConfig.FramesPerBlock, nil, nil)
  else
  begin
    if not TryStrToInt(fEndpoint, lDeviceIndex) then
    begin
      AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
        'Invalid PortAudio output device endpoint: ' + fEndpoint);
      Exit(False);
    end;
    lDeviceInfo := fApi.GetDeviceInfo(lDeviceIndex);
    if (lDeviceInfo = nil) or (lDeviceInfo^.MaxOutputChannels < AConfig.ChannelCount) then
    begin
      AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
        'PortAudio output device is unavailable: ' + fEndpoint);
      Exit(False);
    end;
    lOutput.Device := lDeviceIndex;
    lOutput.ChannelCount := AConfig.ChannelCount;
    lOutput.SampleFormat := CPaFloat32;
    lOutput.SuggestedLatency := lDeviceInfo^.DefaultLowOutputLatency;
    lOutput.HostApiSpecificStreamInfo := nil;
    lError := fApi.OpenStream(@fStream, nil, @lOutput,
      AConfig.SampleRateHz, AConfig.FramesPerBlock, CPaNoFlag, nil, nil);
  end;
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

function TRecorderAudioDacFactory.DiscoverEndpoints(
  out AEndpoints: TRecorderDacEndpoints;
  out AResult: TRecorderDacResult): Boolean;
var
  I, J, lCount, lDefaultDevice, lOutputCount, lHostApi, lDuplicateCount: Integer;
  lApi: TRecorderPortAudioApi;
  lInfo: PPaDeviceInfo;
  lText: string;
begin
  SetLength(AEndpoints, 0);
  lApi := TRecorderPortAudioApi.Create;
  try
    if not lApi.Load(lText) then
    begin
      AResult := RecorderDacFailed(rdeDriver, rdsgDiscover, lText);
      Exit(False);
    end;
    lCount := lApi.Initialize();
    if lCount <> CPaNoError then
    begin
      AResult := RecorderDacFailed(rdeDriver, rdsgDiscover,
        lApi.ErrorText(lCount), lCount);
      Exit(False);
    end;
    try
      lCount := lApi.GetDeviceCount();
      if lCount < 0 then
      begin
        AResult := RecorderDacFailed(rdeDriver, rdsgDiscover,
          lApi.ErrorText(lCount), lCount);
        Exit(False);
      end;
      lDefaultDevice := lApi.GetDefaultOutputDevice();
      lHostApi := -1;
      lInfo := lApi.GetDeviceInfo(lDefaultDevice);
      if lInfo <> nil then lHostApi := lInfo^.HostApi;
      lOutputCount := 0;
      for I := 0 to lCount - 1 do
      begin
        lInfo := lApi.GetDeviceInfo(I);
        if (lInfo = nil) or (lInfo^.MaxOutputChannels <= 0) then Continue;
        { Enumerate one host API: Windows exposes each physical endpoint again
          through MME, DirectSound, WASAPI and WDM/KS. Keep the default host's
          supported format behaviour instead of merging devices by name. }
        if (lHostApi >= 0) and (lInfo^.HostApi <> lHostApi) then Continue;
        lText := StrPas(lInfo^.Name);
        {$IFDEF WINDOWS}
        if SameText(lText, 'Microsoft Sound Mapper - Output') then Continue;
        {$ENDIF}
        SetLength(AEndpoints, lOutputCount + 1);
        AEndpoints[lOutputCount].BackendId := BackendId;
        if I = lDefaultDevice then
          AEndpoints[lOutputCount].Endpoint := 'default'
        else
          AEndpoints[lOutputCount].Endpoint := IntToStr(I);
        AEndpoints[lOutputCount].DisplayName := lText;
        Inc(lOutputCount);
      end;
      { Equal captions may be separate HDMI ports. Preserve both endpoints and
        make them distinguishable instead of deleting a physical output. }
      for I := 0 to High(AEndpoints) do
      begin
        lText := AEndpoints[I].DisplayName;
        lDuplicateCount := 0;
        for J := 0 to High(AEndpoints) do
          if SameText(lText, AEndpoints[J].DisplayName) then
            Inc(lDuplicateCount);
        if lDuplicateCount > 1 then
          for J := High(AEndpoints) downto I do
            if SameText(lText, AEndpoints[J].DisplayName) then
              AEndpoints[J].DisplayName := lText + ' [' +
                AEndpoints[J].Endpoint + ']';
      end;
      AResult := RecorderDacOk;
      Result := True;
    finally
      lApi.Terminate;
    end;
  finally
    lApi.Free;
  end;
end;

function TRecorderAudioDacFactory.CreateBackend(
  const AEndpoint: string): IRecorderDacBackend;
begin
  Result := TRecorderAudioDacBackend.Create(AEndpoint);
end;

end.
