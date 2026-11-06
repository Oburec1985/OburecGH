unit uRecorderDacSession;

{ DAC worker lifecycle and fixed-capacity mirror handoff. Each successful
  hardware Start creates a device-frame to Recorder-time anchor. Queue entries
  retain submission metadata, so publisher delays/loss do not retime output. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, uRecorderDacTypes, uRecorderDacContracts, uRecorderBlockClock;

type
  { Stable DAC lifecycle orchestrator. Pump is called by a backend worker or test. }
  TRecorderDacSession = class
  private
    fBackend: IRecorderDacBackend;
    fProvider: IRecorderDacSampleProvider;
    fMirror: IRecorderDacMirror;
    fTimedMirror: IRecorderDacTimedMirror;
    fMirrorMaintenance: IRecorderDacMirrorMaintenance;
    fRateProvider: IRecorderDacPlaybackRateControl;
    fRateMirror: IRecorderDacRateControlledMirror;
    fRatePending, fRateApplying: Boolean;
    fRequestedRateFactor: Double;
    fQueuedRateCommands: Integer;
    fClockMap: TRecorderDeviceTimeMap;
    fRunFrames: QWord;
    fConfig: TRecorderDacConfig;
    fBuffer: array of Double;
    fLastFrame: array of Double;
    fCounters: TRecorderDacCounters;
    fConfigured: Boolean;
    fRequireCompleteMirror: Boolean;
    fMirrorFailure: TRecorderDacResult;
    fMirrorQueue: array of Double;
    fMirrorFlushBuffer: array of Double;
    fMirrorCounts: array[0..63] of Integer;
    fMirrorTimes: array[0..63] of TRecorderBlockTime;
    fMirrorRateFactors: array[0..63] of Double;
    fMirrorRatePivots: array[0..63] of QWord;
    fMirrorSlots: Integer;
    fMirrorRead: Integer;
    fMirrorWrite: Integer;
    fMirrorCount: Integer;
    fMirrorLock: TRTLCriticalSection;
    procedure ClampBlock(AFrameCount: Integer);
    procedure FillUnderrunBlock(out AFrameCount: Integer);
    procedure RememberLastFrame(AFrameCount: Integer);
    function EnqueueMirror(const ATime: TRecorderBlockTime;
      ARateFactor: Double; APivotFrame: QWord): Boolean;
  public
    constructor Create(const ABackend: IRecorderDacBackend;
      const AProvider: IRecorderDacSampleProvider;
      const AMirror: IRecorderDacMirror = nil;
      ARequireCompleteMirror: Boolean = False);
    destructor Destroy; override;
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function Start(out AResult: TRecorderDacResult): Boolean;
    function Pump(out AResult: TRecorderDacResult): Boolean;
    function RequestRateFactor(AFactor: Double; out AResult: TRecorderDacResult): Boolean;
    function RateFactorPending: Boolean;
    function FlushMirror(out AResult: TRecorderDacResult): Boolean;
    procedure MaintainMirror;
    function MirrorPending: Boolean;
    function MirrorResult: TRecorderDacResult;
    procedure CancelMirror;
    function Stop(out AResult: TRecorderDacResult): Boolean;
    procedure Abort;
    function Disconnect(out AResult: TRecorderDacResult): Boolean;
    function State: TRecorderDacState;
    property Counters: TRecorderDacCounters read fCounters;
  end;

implementation

constructor TRecorderDacSession.Create(const ABackend: IRecorderDacBackend;
  const AProvider: IRecorderDacSampleProvider; const AMirror: IRecorderDacMirror;
  ARequireCompleteMirror: Boolean);
begin
  inherited Create;
  InitCriticalSection(fMirrorLock);
  fBackend := ABackend;
  fProvider := AProvider;
  fMirror := AMirror;
  fRequireCompleteMirror := ARequireCompleteMirror;
  fMirrorFailure := RecorderDacOk;
end;

destructor TRecorderDacSession.Destroy;
begin
  DoneCriticalSection(fMirrorLock);
  inherited Destroy;
end;

function TRecorderDacSession.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
var
  lMirrorIdentity: IRecorderDacMirrorIdentity;
  lSourceIdentity: IRecorderDacSourceIdentity;
begin
  Result := False;
  if (fBackend = nil) or (fProvider = nil) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC backend and provider are required');
    Exit;
  end;
  if not RecorderDacValidateConfig(AConfig, AResult) then Exit;
  if Supports(fProvider, IRecorderDacSourceIdentity, lSourceIdentity) and
    Supports(fMirror, IRecorderDacMirrorIdentity, lMirrorIdentity) and
    (lSourceIdentity.SourceIdentity <> 0) and
    (lSourceIdentity.SourceIdentity = lMirrorIdentity.MirrorIdentity) then
  begin
    AResult := RecorderDacFailed(rdeFeedbackLoop, rdsgConfigure,
      'DAC input tag cannot also be its mirror tag');
    Exit;
  end;
  if fBackend.State = rdsConfigured then
    if not fBackend.Disconnect(AResult) then Exit;
  if (fBackend.State = rdsClosed) and not fBackend.Connect(AResult) then Exit;
  if (fBackend.State = rdsConnected) and not fBackend.Initialize(AResult) then Exit;
  if (fBackend.State = rdsInitialized) and
    not fBackend.ReadProperties(AResult) then Exit;
  fConfig := AConfig;
  { Hardware selects the sampling clock. Every consumer must use that same
    rate, especially the tag timestamps and the pulse duration calculation. }
  if fBackend.SampleRateHz > 0 then fConfig.SampleRateHz := fBackend.SampleRateHz;
  if not fProvider.Configure(fConfig, AResult) then Exit;
  if (fMirror <> nil) and not fMirror.Configure(fConfig, AResult) then Exit;
  Supports(fMirror, IRecorderDacTimedMirror, fTimedMirror);
  Supports(fMirror, IRecorderDacMirrorMaintenance, fMirrorMaintenance);
  Supports(fMirror, IRecorderDacRateControlledMirror, fRateMirror);
  Supports(fProvider, IRecorderDacPlaybackRateControl, fRateProvider);
  if not fBackend.Configure(fConfig, AResult) then Exit;
  SetLength(fBuffer, AConfig.FramesPerBlock * AConfig.ChannelCount);
  SetLength(fLastFrame, AConfig.ChannelCount);
  if fMirror <> nil then
  begin
    fMirrorSlots := 4;
    { Small audio blocks can be queued in a burst before native Write blocks.
      Calibrated output must preserve that burst, not silently drop history. }
    if fRequireCompleteMirror then fMirrorSlots := Length(fMirrorCounts);
    SetLength(fMirrorQueue, fMirrorSlots * AConfig.FramesPerBlock * AConfig.ChannelCount);
    SetLength(fMirrorFlushBuffer, AConfig.FramesPerBlock * AConfig.ChannelCount);
  end
  else
  begin
    SetLength(fMirrorQueue, 0);
    SetLength(fMirrorFlushBuffer, 0);
  end;
  fMirrorRead := 0;
  fMirrorWrite := 0;
  fMirrorCount := 0;
  FillChar(fCounters, SizeOf(fCounters), 0);
  fConfigured := True;
  Result := True;
end;

function TRecorderDacSession.EnqueueMirror(const ATime: TRecorderBlockTime;
  ARateFactor: Double; APivotFrame: QWord): Boolean;
var
  lOffset: Integer;
  lSampleCount: Integer;
begin
  if fMirror = nil then Exit(False);
  EnterCriticalSection(fMirrorLock);
  try
    if fMirrorCount = fMirrorSlots then Exit(False);
    lSampleCount := ATime.SampleCount * fConfig.ChannelCount;
    lOffset := fMirrorWrite * fConfig.FramesPerBlock * fConfig.ChannelCount;
    Move(fBuffer[0], fMirrorQueue[lOffset], lSampleCount * SizeOf(Double));
    fMirrorCounts[fMirrorWrite] := ATime.SampleCount;
    fMirrorTimes[fMirrorWrite] := ATime;
    fMirrorRateFactors[fMirrorWrite] := ARateFactor;
    fMirrorRatePivots[fMirrorWrite] := APivotFrame;
    if ARateFactor > 0 then Inc(fQueuedRateCommands);
    fMirrorWrite := (fMirrorWrite + 1) mod fMirrorSlots;
    Inc(fMirrorCount);
    Result := True;
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
end;

function TRecorderDacSession.Start(out AResult: TRecorderDacResult): Boolean;
var
  lBefore, lAfter: Double;
begin
  if not fConfigured then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgStart,
      'Configure DAC session before Start');
    Exit(False);
  end;
  if fBackend.State = rdsRunning then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgStart,
      'DAC session is already running');
    Exit(False);
  end;
  fProvider.Reset;
  EnterCriticalSection(fMirrorLock);
  try
    fMirrorFailure := RecorderDacOk;
    fMirrorRead := 0;
    fMirrorWrite := 0;
    fMirrorCount := 0;
    fRatePending := False;
    fRateApplying := False;
    fQueuedRateCommands := 0;
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
  if fMirror <> nil then fMirror.Reset;
  lBefore := RecorderClockSeconds;
  Result := fBackend.Start(AResult);
  lAfter := RecorderClockSeconds;
  if Result then
  begin
    { Host start is an estimate, not hardware phase synchronization. Include
      one output block in uncertainty until a backend exposes its DAC clock. }
    fClockMap.BeginSession(0, (lBefore + lAfter) * 0.5,
      (lAfter - lBefore) * 0.5 + RecorderClockResolution +
      fConfig.FramesPerBlock / fConfig.SampleRateHz);
    fRunFrames := 0;
  end;
end;

procedure TRecorderDacSession.ClampBlock(AFrameCount: Integer);
var
  I: Integer;
  lSampleCount: Integer;
begin
  lSampleCount := AFrameCount * fConfig.ChannelCount;
  for I := 0 to lSampleCount - 1 do
    if fBuffer[I] < fConfig.MinimumValue then
      fBuffer[I] := fConfig.MinimumValue
    else if fBuffer[I] > fConfig.MaximumValue then
      fBuffer[I] := fConfig.MaximumValue;
end;

procedure TRecorderDacSession.FillUnderrunBlock(out AFrameCount: Integer);
var
  I, lChannel: Integer;
begin
  AFrameCount := fConfig.FramesPerBlock;
  for I := 0 to AFrameCount - 1 do
    for lChannel := 0 to fConfig.ChannelCount - 1 do
      if fConfig.UnderrunPolicy = rdupHoldLast then
        fBuffer[I * fConfig.ChannelCount + lChannel] := fLastFrame[lChannel]
      else
        fBuffer[I * fConfig.ChannelCount + lChannel] := fConfig.SafeValue;
end;

procedure TRecorderDacSession.RememberLastFrame(AFrameCount: Integer);
var
  I, lOffset: Integer;
begin
  if AFrameCount <= 0 then Exit;
  lOffset := (AFrameCount - 1) * fConfig.ChannelCount;
  for I := 0 to fConfig.ChannelCount - 1 do
    fLastFrame[I] := fBuffer[lOffset + I];
end;

function TRecorderDacSession.RequestRateFactor(AFactor: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := False;
  if (fBackend.State <> rdsRunning) or not fRequireCompleteMirror or
    (fRateProvider = nil) or (fRateMirror = nil) then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgConfigure,
      'DAC stream does not support synchronized manual clock correction');
    Exit;
  end;
  if not fRateMirror.CanSetRateFactor(AFactor, AResult) then Exit;
  if not fRateProvider.CanSetPlaybackSampleRate(fConfig.SampleRateHz * AFactor, AResult) then Exit;
  EnterCriticalSection(fMirrorLock);
  try
    fRequestedRateFactor := AFactor;
    fRatePending := True;
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
  AResult := RecorderDacOk;
  Result := True;
end;

function TRecorderDacSession.RateFactorPending: Boolean;
begin
  EnterCriticalSection(fMirrorLock);
  try
    Result := fRatePending or fRateApplying or (fQueuedRateCommands > 0);
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
end;

function TRecorderDacSession.Pump(out AResult: TRecorderDacResult): Boolean;
var
  lFrameCount: Integer;
  lProviderResult: TRecorderDacResult;
  lTime: TRecorderBlockTime;
  lRateFactor: Double;
  lPivotFrame: QWord;
begin
  if fRequireCompleteMirror then
  begin
    EnterCriticalSection(fMirrorLock);
    try
      AResult := fMirrorFailure;
    finally
      LeaveCriticalSection(fMirrorLock);
    end;
    if AResult.Error <> rdeNone then Exit(False);
  end;
  if fBackend.State <> rdsRunning then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgWrite,
      'DAC session is not running');
    Exit(False);
  end;
  Inc(fCounters.RequestedFrames, fConfig.FramesPerBlock);
  lRateFactor := 0;
  lPivotFrame := fRunFrames;
  EnterCriticalSection(fMirrorLock);
  try
    if fRatePending then
    begin
      lRateFactor := fRequestedRateFactor;
      fRatePending := False;
      fRateApplying := True;
    end;
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
  if (lRateFactor > 0) and
    not fRateProvider.SetPlaybackSampleRate(fConfig.SampleRateHz * lRateFactor, AResult) then
    Exit(False);
  if not fProvider.FillBlock(@fBuffer[0], fConfig.FramesPerBlock,
    lFrameCount, lProviderResult) then
  begin
    Inc(fCounters.Underruns);
    if lProviderResult.Error = rdeCompleted then
    begin
      Dec(fCounters.Underruns);
      AResult := lProviderResult;
      Exit(False);
    end;
    if fConfig.UnderrunPolicy = rdupStop then
    begin
      AResult := lProviderResult;
      Exit(False);
    end;
    FillUnderrunBlock(lFrameCount);
  end;
  if (lFrameCount <= 0) or (lFrameCount > fConfig.FramesPerBlock) then
  begin
    AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
      'DAC provider returned an invalid frame count');
    Exit(False);
  end;
  ClampBlock(lFrameCount);
  RememberLastFrame(lFrameCount);
  lTime.DeviceStartSeconds := fRunFrames / fConfig.SampleRateHz;
  lTime.RecorderStartSeconds := fClockMap.ToRecorder(lTime.DeviceStartSeconds);
  lTime.SubmittedRecorderSeconds := RecorderClockSeconds;
  lTime.SampleRateHz := fConfig.SampleRateHz;
  lTime.SampleCount := lFrameCount;
  lTime.Generation := fClockMap.Generation;
  lTime.UncertaintySeconds := fClockMap.UncertaintySeconds;
  if not fBackend.SubmitBlock(@fBuffer[0], lFrameCount, AResult) then Exit(False);
  Inc(fRunFrames, lFrameCount);
  Inc(fCounters.SubmittedFrames, lFrameCount);
  if (fMirror <> nil) and not EnqueueMirror(lTime, lRateFactor, lPivotFrame) then
  begin
    Inc(fCounters.DroppedMirrorBlocks);
    if fRequireCompleteMirror then
    begin
      AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
        'Calibrated DAC mirror queue overflow; output stopped');
      Exit(False);
    end;
  end;
  EnterCriticalSection(fMirrorLock);
  try
    fRateApplying := False;
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
  Result := True;
end;

function TRecorderDacSession.FlushMirror(
  out AResult: TRecorderDacResult): Boolean;
var
  lFrameCount: Integer;
  lOffset: Integer;
  lTime: TRecorderBlockTime;
  lRateFactor: Double;
  lPivotFrame: QWord;
begin
  if fMirror = nil then
  begin
    AResult := RecorderDacOk;
    Exit(False);
  end;
  EnterCriticalSection(fMirrorLock);
  try
    if fMirrorCount = 0 then
    begin
      AResult := RecorderDacOk;
      Exit(False);
    end;
    lFrameCount := fMirrorCounts[fMirrorRead];
    lTime := fMirrorTimes[fMirrorRead];
    lRateFactor := fMirrorRateFactors[fMirrorRead];
    lPivotFrame := fMirrorRatePivots[fMirrorRead];
    lOffset := fMirrorRead * fConfig.FramesPerBlock * fConfig.ChannelCount;
    Move(fMirrorQueue[lOffset], fMirrorFlushBuffer[0],
      lFrameCount * fConfig.ChannelCount * SizeOf(Double));
    fMirrorRead := (fMirrorRead + 1) mod fMirrorSlots;
    Dec(fMirrorCount);
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
  Result := True;
  if lRateFactor > 0 then
    Result := fRateMirror.SetRateFactorAtFrame(lRateFactor, lPivotFrame, AResult);
  if not Result then
  begin
    EnterCriticalSection(fMirrorLock);
    try
      fMirrorFailure := AResult;
      Dec(fQueuedRateCommands);
    finally
      LeaveCriticalSection(fMirrorLock);
    end;
    Exit;
  end;
  if fTimedMirror <> nil then
    Result := fTimedMirror.WriteTimedBlock(@fMirrorFlushBuffer[0], lTime, AResult)
  else
    Result := fMirror.WriteBlock(@fMirrorFlushBuffer[0], lFrameCount, AResult);
  if Result then Inc(fCounters.MirroredFrames, lFrameCount);
  if lRateFactor > 0 then
  begin
    EnterCriticalSection(fMirrorLock);
    try
      Dec(fQueuedRateCommands);
    finally
      LeaveCriticalSection(fMirrorLock);
    end;
  end;
  if not Result and fRequireCompleteMirror and (AResult.Error <> rdeNone) then
  begin
    EnterCriticalSection(fMirrorLock);
    try
      fMirrorFailure := AResult;
    finally
      LeaveCriticalSection(fMirrorLock);
    end;
  end;
end;

function TRecorderDacSession.Stop(out AResult: TRecorderDacResult): Boolean;
begin
  Result := fBackend.Stop(AResult);
end;

procedure TRecorderDacSession.MaintainMirror;
var
  lResult: TRecorderDacResult;
begin
  if fMirrorMaintenance = nil then Exit;
  if fMirrorMaintenance.Poll(lResult) then Exit;
  EnterCriticalSection(fMirrorLock);
  try
    fMirrorFailure := lResult;
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
end;

function TRecorderDacSession.MirrorPending: Boolean;
begin
  Result := (fMirrorMaintenance <> nil) and fMirrorMaintenance.Pending;
end;

function TRecorderDacSession.MirrorResult: TRecorderDacResult;
begin
  EnterCriticalSection(fMirrorLock);
  try
    Result := fMirrorFailure;
  finally
    LeaveCriticalSection(fMirrorLock);
  end;
end;

procedure TRecorderDacSession.CancelMirror;
begin
  if fMirrorMaintenance <> nil then fMirrorMaintenance.Cancel;
end;

procedure TRecorderDacSession.Abort;
begin
  fBackend.Abort;
end;

function TRecorderDacSession.State: TRecorderDacState;
begin
  Result := fBackend.State;
end;

function TRecorderDacSession.Disconnect(out AResult: TRecorderDacResult): Boolean;
begin
  if fBackend.State = rdsRunning then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgDisconnect,
      'Stop DAC session before disconnect');
    Exit(False);
  end;
  fConfigured := False;
  Result := fBackend.Disconnect(AResult);
end;

end.
