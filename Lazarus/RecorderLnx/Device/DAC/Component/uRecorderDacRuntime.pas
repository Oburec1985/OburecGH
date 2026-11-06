unit uRecorderDacRuntime;

{ Runtime owner for one DAC component. Tag lookup, validation and allocation
  happen only while configuring; the runner hot loop uses direct references. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, LazUTF8, ExtCtrls, uRecorderFormModel, uRecorderTags, uRecorderDacTypes,
  uRecorderDacBackendRegistry, uRecorderDacComponentModel, uRecorderDacContracts,
  uRecorderDacFeedbackCalibration;

type
  TRecorderDacRuntime = class(TInterfacedObject, IRecorderDacComponentRuntime)
  private
    fComponent: TRecorderDacComponent;
    fBackends: TRecorderDacBackendRegistry;
    fRegistry: TRecorderTagRegistry;
    fSession: TObject;
    fRunner: TObject;
    fCalibration: TObject; { borrowed; the session owns its mirror interface }
    fCalibrationTest: Boolean;
    fUseFeedback: Boolean;
    fCalibrationReported: Boolean;
    fRunSerial: QWord;
    fConfiguredRevision: LongInt;
    fPlayback: IRecorderDacPlaybackControl;
    fPreviewActive, fRequestedPlaying, fStartPending, fStreamStopping: Boolean;
    fStartTimer: TTimer;
    fStartFeedback: TRecorderTag;
    fFreshTag: TRecorderTag;
    fFreshCursor: QWord;
    fFreshMinimumSamples: QWord;
    fFreshAfterStop: Boolean;
    fStartRevision: LongInt;
    fStartPhaseMode: TRecorderDacPhaseCalibrationMode;
    fStartSynchronize: Boolean;
    fStartConstant: Boolean;
    fObservedRevision: LongInt;
    fStartDeadline: Double;
    fStreamConfig: TRecorderDacConfig;
    fStreamBackend, fStreamEndpoint: string;
    fStreamFeedbackId, fStreamMirrorId: TRecorderTagId;
    fStreamSynchronize, fStreamMirrorEnabled: Boolean;
    fStreamConstant: Boolean;
    fStreamPhaseMode: TRecorderDacPhaseCalibrationMode;
    fStreamDuration, fStreamTimeout: Double;
    fAppliedPlaybackRate: Double;
    fLastResult: TRecorderDacResult;
    fLock: TRTLCriticalSection;
    function ResolveTag(ATagId: TRecorderTagId;
      const ATagName: string): TRecorderTag;
    function ConfigureSession: Boolean;
    function CreateSignalProvider: IRecorderDacSampleProvider;
    function UpdateSignalProvider: Boolean;
    function StreamConfigMatches: Boolean;
    procedure BeginStream(APlaying, AUseFeedback, AForceRestart: Boolean);
    procedure StartTimerTick(Sender: TObject);
    procedure LaunchStream;
    procedure ShutdownStream;
    procedure ObserveConfiguration;
    procedure PrepareCalibratedPlayback;
    procedure ReleaseSession;
    procedure StoreResult(const AResult: TRecorderDacResult);
    function ValidateFeedbackOutput(AFactory: TRecorderDacBackendFactory): Boolean;
  public
    constructor Create(AComponent: TRecorderDacComponent;
      ABackends: TRecorderDacBackendRegistry);
    destructor Destroy; override;
    function Component: TRecorderVisualComponent;
    procedure SetTagRegistry(ARegistry: TRecorderTagRegistry);
    procedure StartOutput;
    procedure StartCalibration;
    procedure ApplyOutputSettings;
    function SetRateFactor(AFactor: Double; out AResult: TRecorderDacResult): Boolean;
    procedure EnterPreview;
    procedure LeavePreview;
    procedure StopOutput;
    function Snapshot: TRecorderDacRuntimeSnapshot;
  end;

implementation

uses
  uRecorderDacProviders,
  uRecorderDacTagMirror, uRecorderDacSession, uRecorderDacRunner,
  uRecorderBlockClock, uRecorderDebugLog;

constructor TRecorderDacRuntime.Create(AComponent: TRecorderDacComponent;
  ABackends: TRecorderDacBackendRegistry);
begin
  inherited Create;
  fComponent := AComponent;
  fBackends := ABackends;
  fLastResult := RecorderDacOk;
  InitCriticalSection(fLock);
  fStartTimer := TTimer.Create(nil);
  fStartTimer.Enabled := False;
  fStartTimer.Interval := 50;
  fStartTimer.OnTimer := @StartTimerTick;
end;

destructor TRecorderDacRuntime.Destroy;
begin
  ShutdownStream;
  FreeAndNil(fStartTimer);
  ReleaseSession;
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderDacRuntime.Component: TRecorderVisualComponent;
begin
  Result := fComponent;
end;

procedure TRecorderDacRuntime.SetTagRegistry(ARegistry: TRecorderTagRegistry);
begin
  if fRegistry = ARegistry then Exit;
  ShutdownStream;
  ReleaseSession;
  fRegistry := ARegistry;
  fFreshTag := nil;
  fStartFeedback := nil;
  if (fRegistry <> nil) and (fComponent <> nil) and fComponent.MirrorEnabled then
    fComponent.EnsureMirrorTag(fRegistry);
end;

procedure TRecorderDacRuntime.StoreResult(const AResult: TRecorderDacResult);
begin
  if not (AResult.Error in [rdeNone, rdeCompleted]) then
    RecorderDebugLog('[DAC] error=' + AResult.Text);
  EnterCriticalSection(fLock);
  try
    fLastResult := AResult;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacRuntime.ResolveTag(ATagId: TRecorderTagId;
  const ATagName: string): TRecorderTag;
begin
  Result := nil;
  if fRegistry = nil then Exit;
  if ATagId <> 0 then Result := fRegistry.FindById(ATagId);
  if (Result = nil) and (ATagName <> '') then
    Result := fRegistry.FindByName(ATagName);
end;

function TRecorderDacRuntime.ConfigureSession: Boolean;
var
  lBackendFactory: TRecorderDacBackendFactory;
  lBackend: IRecorderDacBackend;
  lProvider: IRecorderDacSampleProvider;
  lMirror: IRecorderDacMirror;
  lInputTag, lMirrorTag, lFeedbackTag: TRecorderTag;
  lSession: TRecorderDacSession;
  lSettings: TRecorderDacFeedbackSettings;
  lFeedbackMirror: TRecorderDacFeedbackMirror;
  lPersistent: TRecorderDacPersistentProvider;
  lSynchronize: Boolean;
  lMirrorHistorySeconds: Double;
begin
  Result := False;
  lSynchronize := fUseFeedback;
  lMirrorHistorySeconds := 4;
  if lSynchronize then
    lMirrorHistorySeconds := fComponent.FeedbackTimeoutSec + 2;
  lFeedbackTag := nil;
  if lSynchronize then
  begin
    lFeedbackTag := ResolveTag(fComponent.FeedbackTagId, fComponent.FeedbackTagName);
    if (lFeedbackTag = nil) or lFeedbackTag.IsVirtual or
      (lFeedbackTag.BlockTimeDomain <> btRecorderMonotonic) or
      (lFeedbackTag.SignalBuffer.Count = 0) then
    begin
      StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
        'Start hardware acquisition and select a live feedback vector channel'));
      Exit;
    end;
    if SameText(fComponent.Endpoint, 'default') or
      SameText(fComponent.BackendId, 'null') then
    begin
      StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
        'Feedback requires an explicitly selected physical DAC, not default/test output'));
      Exit;
    end;
  end;
  if (fRegistry = nil) and ((fComponent.SourceMode = rdsmTag) or
    fComponent.MirrorEnabled) then
  begin
    StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC tag registry is not available'));
    Exit;
  end;
  lBackendFactory := fBackends.FindFactory(fComponent.BackendId);
  if lBackendFactory = nil then
  begin
    StoreResult(RecorderDacFailed(rdeUnsupported, rdsgConfigure,
      'Unknown DAC backend: ' + fComponent.BackendId));
    Exit;
  end;
  if lSynchronize and not ValidateFeedbackOutput(lBackendFactory) then Exit;
  lInputTag := nil;
  if fComponent.SourceMode = rdsmTag then
    lInputTag := ResolveTag(fComponent.InputTagId, fComponent.InputTagName);
  if (fComponent.SourceMode = rdsmTag) and (lInputTag = nil) then
  begin
    StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC input tag is not found'));
    Exit;
  end;
  lMirror := nil;
  if fComponent.MirrorEnabled or lSynchronize then
  begin
    if lSynchronize then fComponent.MirrorEnabled := True;
    lMirrorTag := fComponent.EnsureMirrorTag(fRegistry);
    if lMirrorTag = nil then
    begin
      StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
        'DAC mirror tag is not found'));
      Exit;
    end;
    if lMirrorTag = lFeedbackTag then
    begin
      StoreResult(RecorderDacFailed(rdeFeedbackLoop, rdsgConfigure,
        'Physical feedback and DAC mirror must be different tags'));
      Exit;
    end;
    { Record-domain selection happens before the first sample is published. }
    lMirrorTag.BlockTimeDomain := btRecorderMonotonic;
    if lInputTag <> nil then
      lMirror := TRecorderDacTagMirror.Create(fRegistry, lMirrorTag,
        lInputTag.Name, lMirrorHistorySeconds)
    else
      lMirror := TRecorderDacTagMirror.Create(fRegistry, lMirrorTag,
        fComponent.Name, lMirrorHistorySeconds);
  end;
  lBackend := lBackendFactory.CreateBackend(fComponent.Endpoint);
  lProvider := CreateSignalProvider;
  if lProvider = nil then Exit;
  if lSynchronize then
  begin
    lPersistent := TRecorderDacPersistentProvider.Create(lProvider, Abs(fComponent.Amplitude),
      fComponent.FeedbackCalibrationDurationSec);
    lSettings := RecorderDacDefaultFeedbackSettings;
    lSettings.GeneratedBellMarker := True;
    lSettings.MarkerOffsetSeconds := RecorderDacCalibrationPeakOffsetSeconds(
      fComponent.SampleRateHz);
    lSettings.TimeoutSeconds := fComponent.FeedbackTimeoutSec;
    lSettings.EdgeIntervalSeconds := fComponent.FeedbackCalibrationDurationSec - 0.4;
    lFeedbackMirror := TRecorderDacFeedbackMirror.Create(lMirror,
      lFeedbackTag, lSettings);
    lMirror := lFeedbackMirror;
    fCalibration := lFeedbackMirror;
    fCalibrationReported := False;
  end
  else
    lPersistent := TRecorderDacPersistentProvider.Create(lProvider, 0.05, 0);
  fPlayback := lPersistent;
  fAppliedPlaybackRate := 0;
  lProvider := lPersistent;
  fPlayback.SetPlaying(fRequestedPlaying);
  lSession := TRecorderDacSession.Create(lBackend, lProvider, lMirror, lSynchronize);
  fSession := lSession;
  fStreamConfig := fComponent.BuildConfig;
  fStreamBackend := fComponent.BackendId;
  fStreamEndpoint := fComponent.Endpoint;
  fStreamFeedbackId := fComponent.FeedbackTagId;
  fStreamMirrorId := fComponent.MirrorTagId;
  fStreamSynchronize := fComponent.SynchronizeByFeedback;
  fStreamConstant := fComponent.SourceMode = rdsmConstant;
  fStreamPhaseMode := fComponent.PhaseCalibrationMode;
  fStreamMirrorEnabled := fComponent.MirrorEnabled;
  fStreamDuration := fComponent.FeedbackCalibrationDurationSec;
  fStreamTimeout := fComponent.FeedbackTimeoutSec;
  fConfiguredRevision := fComponent.Revision;
  StoreResult(RecorderDacOk);
  Result := True;
end;

function TRecorderDacRuntime.CreateSignalProvider: IRecorderDacSampleProvider;
var
  lInputTag: TRecorderTag;
begin
  Result := nil;
  lInputTag := nil;
  if fComponent.SourceMode = rdsmTag then
  begin
    lInputTag := ResolveTag(fComponent.InputTagId, fComponent.InputTagName);
    if lInputTag = nil then
    begin
      StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
        'DAC input tag is not found'));
      Exit;
    end;
    if (lInputTag.Id = fComponent.MirrorTagId) then
    begin
      StoreResult(RecorderDacFailed(rdeFeedbackLoop, rdsgConfigure,
        'DAC input and mirror must be different tags'));
      Exit;
    end;
  end;
  case fComponent.SourceMode of
    rdsmConstant:
      Result := TRecorderDacConstantProvider.Create(fComponent.Amplitude);
    rdsmPulse:
      Result := TRecorderDacPulseProvider.Create(fComponent.FrequencyHz,
        fComponent.Amplitude, fComponent.PulseIntervalSec,
        fComponent.PulsePeriods, fComponent.PulseCount);
    rdsmSine:
      Result := TRecorderDacWaveProvider.Create(rdwmSine,
        fComponent.FrequencyHz, fComponent.Amplitude,
        fComponent.SweepStartHz, fComponent.SweepEndHz,
        fComponent.SweepTimeSec);
    rdsmAccurateSine:
      Result := TRecorderDacWaveProvider.Create(rdwmAccurateSine,
        fComponent.FrequencyHz, fComponent.Amplitude,
        fComponent.SweepStartHz, fComponent.SweepEndHz,
        fComponent.SweepTimeSec);
    rdsmSweepSine:
      Result := TRecorderDacWaveProvider.Create(rdwmSweepSine,
        fComponent.FrequencyHz, fComponent.Amplitude,
        fComponent.SweepStartHz, fComponent.SweepEndHz,
        fComponent.SweepTimeSec);
  else
    Result := TRecorderDacTagProvider.Create(lInputTag);
  end;
end;

function TRecorderDacRuntime.ValidateFeedbackOutput(
  AFactory: TRecorderDacBackendFactory): Boolean;
var
  lEndpoints: TRecorderDacEndpoints;
  lResult: TRecorderDacResult;
  lName, lSelectedName, lReason, lCandidates: string;
  I: Integer;
begin
  Result := False;
  lSelectedName := '';
  lReason := 'selected endpoint was not returned by discovery';
  lCandidates := '';
  if not AFactory.DiscoverEndpoints(lEndpoints, lResult) then
  begin
    StoreResult(lResult);
    Exit;
  end;
  for I := 0 to High(lEndpoints) do
    begin
      if lCandidates <> '' then lCandidates := lCandidates + '; ';
      lCandidates := lCandidates + lEndpoints[I].Endpoint + '=' +
        lEndpoints[I].DisplayName;
      if lEndpoints[I].Endpoint <> fComponent.Endpoint then Continue;
      lSelectedName := lEndpoints[I].DisplayName;
      lName := UTF8LowerCase(lEndpoints[I].DisplayName);
      if (Pos('remote audio', lName) > 0) or
        (Pos('удал', lName) > 0) or (Pos('переназнач', lName) > 0) then
      begin
        lReason := 'selected endpoint is redirected Remote Audio';
        Continue;
      end;
      RecorderDebugLog(Format('[DAC feedback] prepare endpoint=%s device=%s feedback=%s edge_method=bell_correlation marker_amplitude=%g timeout=%g calibration_duration_sec=%g',
        [fComponent.Endpoint, lEndpoints[I].DisplayName,
        fComponent.FeedbackTagName, fComponent.Amplitude,
        fComponent.FeedbackTimeoutSec, fComponent.FeedbackCalibrationDurationSec]));
      Exit(True);
    end;
  StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
    Format('Select an available physical DAC, not redirected Remote Audio. '+
      'backend=%s endpoint=%s selected=%s reason=%s candidates=[%s]',
      [fComponent.BackendId, fComponent.Endpoint, lSelectedName, lReason, lCandidates])));
end;

procedure TRecorderDacRuntime.ReleaseSession;
var
  lResult: TRecorderDacResult;
  lFeedback: TRecorderDacFeedbackSnapshot;
begin
  if fRunner <> nil then
  begin
    TRecorderDacRunner(fRunner).RequestStop;
    TRecorderDacRunner(fRunner).WaitFor;
    lResult := TRecorderDacRunner(fRunner).LastResult;
    if (lResult.Error <> rdeNone) or (fLastResult.Error in [rdeNone, rdeCompleted]) then
      StoreResult(lResult);
    FreeAndNil(fRunner);
  end;
  if fSession = nil then Exit;
  if fCalibration <> nil then
  begin
    lFeedback := TRecorderDacFeedbackMirror(fCalibration).Snapshot;
    RecorderDebugLog(Format('[DAC feedback] final run=%d edge_method=bell_correlation state=%d matches=%d first_center=%g second_center=%g baseline=%g peak_height=%g noise_rms=%g legacy_half_level=%g polarity=%d candidates=%d first_replacements=%d rho1=%g rho2=%g fit_gain1=%g fit_gain2=%g error=%s',
      [fRunSerial, Ord(lFeedback.State), lFeedback.DetectedEdges,
      lFeedback.EdgeRecorderSeconds, lFeedback.SecondEdgeRecorderSeconds,
      lFeedback.Baseline, lFeedback.StepHeight, lFeedback.NoiseRms,
      lFeedback.Threshold, lFeedback.DetectedPolarity, lFeedback.CandidateCount,
      lFeedback.FirstReplacements, lFeedback.CorrelationFirst,
      lFeedback.CorrelationSecond, lFeedback.CorrelationGainFirst,
      lFeedback.CorrelationGainSecond, lFeedback.Error]));
  end;
  TRecorderDacSession(fSession).Disconnect(lResult);
  if lResult.Error <> rdeNone then StoreResult(lResult);
  FreeAndNil(fSession);
  fCalibration := nil;
  fPlayback := nil;
  fConfiguredRevision := 0;
end;

procedure TRecorderDacRuntime.StartOutput;
var
  lUseFeedback, lForceRestart: Boolean;
begin
  if fComponent = nil then Exit;
  if fComponent.SourceMode = rdsmConstant then
  begin
    { DC is a direct output diagnostic. Saved phase settings must neither
      insert markers nor wait for an ADC channel before its Play request. }
    fCalibrationTest := False;
    BeginStream(True, False, False);
    Exit;
  end;
  if fStartPending and fUseFeedback and
    (fComponent.PhaseCalibrationMode <> rdpcmPlay) then
  begin
    { A Play request during measurement-start/manual calibration queues only
      playback. It must not restart the pending native/calibration lifecycle. }
    fRequestedPlaying := True;
    if (fPlayback <> nil) and not fStreamStopping then fPlayback.SetPlaying(True);
    Exit;
  end;
  if fComponent.SynchronizeByFeedback and
    (fComponent.PhaseCalibrationMode = rdpcmMeasurementStart) and
    ((fRunner = nil) or TRecorderDacRunner(fRunner).Finished or
     fStreamStopping or not fUseFeedback or not StreamConfigMatches) then
  begin
    StoreResult(RecorderDacFailed(rdeInvalidState, rdsgStart,
      'Phase calibration is not ready. Press Phase calibration or restart measurement'));
    Exit;
  end;
  fCalibrationTest := False;
  lUseFeedback := fComponent.SynchronizeByFeedback and
    (fComponent.PhaseCalibrationMode <> rdpcmButton);
  { Manual mode retains an explicitly calibrated stream, but ordinary Play
    before the button has been used is allowed to open a nominal stream. }
  if fComponent.SynchronizeByFeedback and
    (fComponent.PhaseCalibrationMode = rdpcmButton) and
    (fSession <> nil) and not fStreamStopping and StreamConfigMatches then
    lUseFeedback := fUseFeedback;
  lForceRestart := fComponent.SynchronizeByFeedback and
    (fComponent.PhaseCalibrationMode = rdpcmPlay);
  BeginStream(True, lUseFeedback, lForceRestart);
end;

procedure TRecorderDacRuntime.StartCalibration;
var
  lResumePlaying: Boolean;
begin
  lResumePlaying := fRequestedPlaying;
  if (fPlayback <> nil) and not fStreamStopping then
    lResumePlaying := fPlayback.IsPlaying;
  fCalibrationTest := True;
  BeginStream(lResumePlaying, True, True);
end;

function TRecorderDacRuntime.SetRateFactor(AFactor: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := False;
  if (fComponent = nil) or (fComponent.SourceMode = rdsmConstant) or
    fStreamStopping or (fCalibration = nil) or (fPlayback = nil) or (fSession = nil) then
  begin
    AResult := RecorderDacFailed(rdeInvalidState, rdsgConfigure,
      'Manual clock correction requires a calibrated non-DC output stream');
    StoreResult(AResult);
    Exit;
  end;
  { The worker consumes this bounded command before FillBlock; its FIFO slot
    carries the same frame pivot to the mirror publisher. No GUI-side setters. }
  Result := TRecorderDacSession(fSession).RequestRateFactor(AFactor, AResult);
  StoreResult(AResult);
  if Result then
    RecorderDebugLog(Format('[DAC] manual-clock-request run=%d k_rate=%.9f',
      [fRunSerial, AFactor]));
end;

procedure TRecorderDacRuntime.ApplyOutputSettings;
begin
  if (fComponent = nil) or (fSession = nil) or fStreamStopping then Exit;
  ObserveConfiguration;
  if fStreamStopping or (fPlayback = nil) then Exit;
  { Parameter edits are not a Play gesture. Preserve both the native stream
    and the current play/mute state; only swap the prepared signal provider. }
  if not UpdateSignalProvider then ShutdownStream;
end;

function TRecorderDacRuntime.StreamConfigMatches: Boolean;
var
  lConfig: TRecorderDacConfig;
begin
  lConfig := fComponent.BuildConfig;
  Result := (fStreamBackend = fComponent.BackendId) and
    (fStreamEndpoint = fComponent.Endpoint) and
    (lConfig.SampleRateHz = fStreamConfig.SampleRateHz) and
    (lConfig.FramesPerBlock = fStreamConfig.FramesPerBlock) and
    (lConfig.MinimumValue = fStreamConfig.MinimumValue) and
    (lConfig.MaximumValue = fStreamConfig.MaximumValue) and
    (lConfig.SafeValue = fStreamConfig.SafeValue) and
    (lConfig.UnderrunPolicy = fStreamConfig.UnderrunPolicy) and
    (fStreamFeedbackId = fComponent.FeedbackTagId) and
    (fStreamMirrorId = fComponent.MirrorTagId) and
    (fStreamSynchronize = fComponent.SynchronizeByFeedback) and
    (fStreamConstant = (fComponent.SourceMode = rdsmConstant)) and
    (fStreamPhaseMode = fComponent.PhaseCalibrationMode) and
    (fStreamMirrorEnabled = fComponent.MirrorEnabled) and
    (fStreamDuration = fComponent.FeedbackCalibrationDurationSec) and
    (fStreamTimeout = fComponent.FeedbackTimeoutSec);
end;

function TRecorderDacRuntime.UpdateSignalProvider: Boolean;
var
  lProvider: IRecorderDacSampleProvider;
  lResult: TRecorderDacResult;
begin
  Result := True;
  if fConfiguredRevision = fComponent.Revision then Exit;
  lProvider := CreateSignalProvider;
  Result := (lProvider <> nil);
  if not Result then Exit;
  Result := fPlayback.SetProvider(lProvider, lResult);
  StoreResult(lResult);
  if Result then fConfiguredRevision := fComponent.Revision;
end;

procedure TRecorderDacRuntime.BeginStream(APlaying, AUseFeedback,
  AForceRestart: Boolean);
begin
  if (fComponent = nil) or not fComponent.Enabled then Exit;
  if AUseFeedback and not fPreviewActive then
  begin
    StoreResult(RecorderDacFailed(rdeInvalidState, rdsgStart,
      'Enter Preview before starting feedback calibration'));
    Exit;
  end;
  fRequestedPlaying := APlaying;
  if (fRunner <> nil) and TRecorderDacRunner(fRunner).Finished then
    ReleaseSession;
  if fRunner <> nil then
  begin
    if not fStreamStopping and not AForceRestart and
      (AUseFeedback = fUseFeedback) and StreamConfigMatches then
    begin
      if UpdateSignalProvider then fPlayback.SetPlaying(APlaying);
      Exit;
    end;
    ShutdownStream;
    fRequestedPlaying := APlaying;
    fUseFeedback := AUseFeedback;
    fFreshAfterStop := AUseFeedback;
    fStartPending := True;
    fStartFeedback := nil;
    if fUseFeedback then
      fStartFeedback := ResolveTag(fComponent.FeedbackTagId, fComponent.FeedbackTagName);
    fStartRevision := fComponent.Revision;
    fStartPhaseMode := fComponent.PhaseCalibrationMode;
    fStartSynchronize := fComponent.SynchronizeByFeedback;
    fStartConstant := fComponent.SourceMode = rdsmConstant;
    fStartDeadline := RecorderClockSeconds + fComponent.FeedbackTimeoutSec;
    fStartTimer.Enabled := True;
    Exit;
  end;
  if fSession <> nil then ReleaseSession;
  fUseFeedback := AUseFeedback;
  fFreshAfterStop := False;
  fStartFeedback := nil;
  if fUseFeedback then
  begin
    if not fPreviewActive then
    begin
      StoreResult(RecorderDacFailed(rdeInvalidState, rdsgStart,
        'Enter Preview before starting feedback calibration'));
      Exit;
    end;
    fStartFeedback := ResolveTag(fComponent.FeedbackTagId, fComponent.FeedbackTagName);
  end;
  fStartDeadline := RecorderClockSeconds + fComponent.FeedbackTimeoutSec;
  fStartRevision := fComponent.Revision;
  fStartPhaseMode := fComponent.PhaseCalibrationMode;
  fStartSynchronize := fComponent.SynchronizeByFeedback;
  fStartConstant := fComponent.SourceMode = rdsmConstant;
  fStartPending := True;
  fStartTimer.Enabled := True;
  StartTimerTick(nil);
end;

procedure TRecorderDacRuntime.StartTimerTick(Sender: TObject);
begin
  if fStartPending and ((fComponent = nil) or not fComponent.Enabled) then
  begin
    ShutdownStream;
    Exit;
  end;
  if not fStartPending then
  begin
    if fRunner <> nil then
    begin
      if TRecorderDacRunner(fRunner).Finished then ReleaseSession
      else
      begin
        if not fStreamStopping then
        begin
          ObserveConfiguration;
          PrepareCalibratedPlayback;
        end;
        Exit;
      end;
    end;
    fStartTimer.Enabled := False;
    Exit;
  end;
  if fUseFeedback and not fPreviewActive then
  begin
    ShutdownStream;
    Exit;
  end;
  if (fStartPhaseMode <> fComponent.PhaseCalibrationMode) or
    (fStartSynchronize <> fComponent.SynchronizeByFeedback) or
    (fStartConstant <> (fComponent.SourceMode = rdsmConstant)) then
  begin
    ShutdownStream;
    StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC phase calibration mode changed; start a new output request'));
    Exit;
  end;
  if fStartRevision <> fComponent.Revision then
  begin
    fStartFeedback := nil;
    if fUseFeedback then
      fStartFeedback := ResolveTag(fComponent.FeedbackTagId, fComponent.FeedbackTagName);
    fStartRevision := fComponent.Revision;
  end;
  if fRunner <> nil then
  begin
    if not TRecorderDacRunner(fRunner).Finished then Exit;
    ReleaseSession;
    if fUseFeedback then
      fStartFeedback := ResolveTag(fComponent.FeedbackTagId, fComponent.FeedbackTagName);
  end;
  if fUseFeedback and fFreshAfterStop and (fStartFeedback <> nil) then
  begin
    { ShutdownStream may already have retired a finished runner. Capture the
      fresh baseline boundary in either case, never only in the join branch. }
    fFreshTag := fStartFeedback;
    fFreshCursor := fFreshTag.SignalBuffer.CurrentCursor;
    fFreshMinimumSamples := QWord(Max(1, Ceil(0.05 * fFreshTag.PollFrequencyHz) + 1));
    fFreshAfterStop := False;
  end;
  if fUseFeedback then
  begin
    if fStartFeedback <> fFreshTag then
    begin
      fFreshTag := fStartFeedback;
      if fFreshTag <> nil then
      begin
        fFreshCursor := fFreshTag.SignalBuffer.CurrentCursor;
        fFreshMinimumSamples := QWord(Max(1, Ceil(0.05 * fFreshTag.PollFrequencyHz) + 1));
      end;
    end;
    if (fStartFeedback = nil) or
      (fStartFeedback.BlockTimeDomain <> btRecorderMonotonic) or
      (fStartFeedback.SignalBuffer.Count = 0) or
      ((fStartFeedback = fFreshTag) and
        ((fStartFeedback.SignalBuffer.CurrentCursor < fFreshCursor) or
         (fStartFeedback.SignalBuffer.CurrentCursor - fFreshCursor < fFreshMinimumSamples))) then
    begin
      if RecorderClockSeconds < fStartDeadline then Exit;
      fStartPending := False;
      fStartTimer.Enabled := False;
      StoreResult(RecorderDacFailed(rdeNoData, rdsgStart,
        'No current feedback data arrived after entering Preview'));
      Exit;
    end;
  end;
  fStartPending := False;
  fStartTimer.Enabled := True;
  LaunchStream;
end;

procedure TRecorderDacRuntime.LaunchStream;
var
  lRunner: TRecorderDacRunner;
begin
  if (fSession = nil) and not ConfigureSession then Exit;
  fStreamStopping := False;
  fObservedRevision := fComponent.Revision;
  fCalibrationReported := False;
  Inc(fRunSerial);
  RecorderDebugLog(Format('[DAC] stream-start run=%d playing=%s calibration_test=%s',
    [fRunSerial, BoolToStr(fRequestedPlaying, True), BoolToStr(fCalibrationTest, True)]));
  lRunner := TRecorderDacRunner.Create(TRecorderDacSession(fSession),
    fComponent.BuildConfig);
  fRunner := lRunner;
  lRunner.StartRun;
end;

procedure TRecorderDacRuntime.StopOutput;
begin
  fRequestedPlaying := False;
  if fStartPending then
  begin
    ShutdownStream;
    Exit;
  end;
  if (fPlayback <> nil) and fPlayback.IsCalibrating then
  begin
    ShutdownStream;
    Exit;
  end;
  if fPlayback <> nil then fPlayback.SetPlaying(False);
end;

procedure TRecorderDacRuntime.EnterPreview;
begin
  if fPreviewActive then Exit;
  fPreviewActive := True;
  { Constant output is started only by Play, never by automatic calibration. }
  if fComponent.SourceMode = rdsmConstant then Exit;
  fFreshTag := ResolveTag(fComponent.FeedbackTagId, fComponent.FeedbackTagName);
  if fFreshTag <> nil then
  begin
    fFreshCursor := fFreshTag.SignalBuffer.CurrentCursor;
    fFreshMinimumSamples := QWord(Max(1, Ceil(0.05 * fFreshTag.PollFrequencyHz) + 1));
  end;
  fCalibrationTest := False;
  if fComponent.SynchronizeByFeedback then
  begin
    if fComponent.PhaseCalibrationMode = rdpcmMeasurementStart then
      BeginStream(False, True, False);
  end
  else if fComponent.StartStreamOnPreview then
    BeginStream(False, False, False);
end;

procedure TRecorderDacRuntime.ObserveConfiguration;
begin
  if (fSession = nil) or (fObservedRevision = fComponent.Revision) then Exit;
  fObservedRevision := fComponent.Revision;
  if not fComponent.Enabled or not StreamConfigMatches then
  begin
    ShutdownStream;
    StoreResult(RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC device or feedback settings changed; start a new stream to recalibrate'));
  end;
end;

procedure TRecorderDacRuntime.PrepareCalibratedPlayback;
var
  lFeedback: TRecorderDacFeedbackSnapshot;
  lResult: TRecorderDacResult;
  lRateFactor, lNominalRate: Double;
begin
  if fStreamStopping or (fCalibration = nil) or (fPlayback = nil) or
    (fAppliedPlaybackRate > 0) then Exit;
  lFeedback := TRecorderDacFeedbackMirror(fCalibration).Snapshot;
  if lFeedback.State <> rdfsLocked then Exit;
  { One-time preparation on the control thread. Work samples stay gated
    until the provider has been configured with the measured DAC clock. }
  if fPlayback.SetPlaybackSampleRate(lFeedback.EffectiveSampleRateHz, lResult) then
  begin
    fAppliedPlaybackRate := lFeedback.EffectiveSampleRateHz;
    lRateFactor := 1 + lFeedback.DriftPpm * 1E-6;
    lNominalRate := fAppliedPlaybackRate / lRateFactor;
    RecorderDebugLog(Format('[DAC] playback-clock run=%d nominal_hz=%g effective_hz=%g k_rate=%.9f',
      [fRunSerial, lNominalRate, fAppliedPlaybackRate, lRateFactor]));
  end
  else
  begin
    StoreResult(lResult);
    ShutdownStream;
  end;
end;

procedure TRecorderDacRuntime.LeavePreview;
begin
  fPreviewActive := False;
  ShutdownStream;
end;

procedure TRecorderDacRuntime.ShutdownStream;
var
  lRunner: TRecorderDacRunner;
begin
  fStreamStopping := True;
  fFreshAfterStop := False;
  fStartPending := False;
  fRequestedPlaying := False;
  fStartTimer.Enabled := fRunner <> nil;
  if fPlayback <> nil then fPlayback.SetPlaying(False);
  if fRunner = nil then
  begin
    ReleaseSession;
    Exit;
  end;
  lRunner := TRecorderDacRunner(fRunner);
  lRunner.RequestStop;
  { The worker stops its stream after the current block. Joining/freeing is
    deferred until it finishes; the GUI never calls the driver concurrently. }
  if lRunner.Finished then
    ReleaseSession;
end;

function TRecorderDacRuntime.Snapshot: TRecorderDacRuntimeSnapshot;
var
  lFeedback: TRecorderDacFeedbackSnapshot;
  lRunnerResult: TRecorderDacResult;
begin
  if not fStreamStopping then ObserveConfiguration;
  if (fRunner <> nil) and TRecorderDacRunner(fRunner).Finished then
    ReleaseSession;
  Result.CalibrationStateText := '';
  Result.CalibrationDelaySec := 0;
  Result.CalibrationEdgeSec := 0;
  Result.CalibrationStartSec := 0;
  Result.CalibrationSampleRateHz := 0;
  Result.CalibrationRateFactor := 0;
  Result.CalibrationCorrelationFirst := 0;
  Result.CalibrationCorrelationSecond := 0;
  Result.CalibrationManualRate := False;
  Result.CalibrationRatePending := (fSession <> nil) and
    TRecorderDacSession(fSession).RateFactorPending;
  Result.CalibrationDriftPpm := 0;
  Result.CalibrationSecondEdgeSec := 0;
  Result.CalibrationDetectedEdges := 0;
  Result.CalibrationValid := False;
  Result.OutputPlaying := fRequestedPlaying and fStartPending;
  Result.CalibrationRunning := fStartPending and fUseFeedback;
  if (fPlayback <> nil) and (fRunner <> nil) and not fStreamStopping then
  begin
    Result.OutputPlaying := fPlayback.IsPlaying;
    Result.CalibrationRunning := fPlayback.IsCalibrating;
  end;
  if (fCalibration <> nil) and (fRunner <> nil) and not fStreamStopping then
  begin
    lFeedback := TRecorderDacFeedbackMirror(fCalibration).Snapshot;
    Result.CalibrationValid := lFeedback.State = rdfsLocked;
    Result.CalibrationRunning := Result.CalibrationRunning or
      (lFeedback.State = rdfsWaiting);
    Result.CalibrationDelaySec := lFeedback.HostOffsetSeconds;
    Result.CalibrationEdgeSec := lFeedback.EdgeRecorderSeconds;
    Result.CalibrationStartSec := lFeedback.DacStartRecorderSeconds;
    Result.CalibrationSampleRateHz := lFeedback.EffectiveSampleRateHz;
    Result.CalibrationDriftPpm := lFeedback.DriftPpm;
    Result.CalibrationCorrelationFirst := lFeedback.CorrelationFirst;
    Result.CalibrationCorrelationSecond := lFeedback.CorrelationSecond;
    Result.CalibrationManualRate := lFeedback.ManualRate;
    if Result.CalibrationValid then
      Result.CalibrationRateFactor := 1 + lFeedback.DriftPpm * 1E-6;
    Result.CalibrationSecondEdgeSec := lFeedback.SecondEdgeRecorderSeconds;
    Result.CalibrationDetectedEdges := lFeedback.DetectedEdges;
    case lFeedback.State of
      rdfsIdle: Result.CalibrationStateText := 'Подготовка';
      rdfsWaiting:
        if lFeedback.DetectedEdges = 0 then
          Result.CalibrationStateText := 'Предварительное зеркало: сопоставление формы первого колокола'
        else Result.CalibrationStateText := 'Предварительное зеркало: сопоставление формы второго колокола';
      rdfsLocked: Result.CalibrationStateText := 'Начало и частота привязаны по корреляции формы двух колоколов';
      rdfsFailed: Result.CalibrationStateText := 'Время зеркала предварительное: ' + lFeedback.Error;
    end;
    if Result.CalibrationValid and not fCalibrationReported then
    begin
      fCalibrationReported := True;
      RecorderDebugLog(Format('[DAC feedback] run=%d edge_method=bell_correlation center1=%g center2=%g start=%g effective_rate_hz=%g k_rate=%.9f drift_ppm=%g host_offset_sec=%g legacy_half_level=%g peak_height=%g noise_rms=%g rho1=%g rho2=%g fit_gain1=%g fit_gain2=%g',
        [fRunSerial, lFeedback.EdgeRecorderSeconds, lFeedback.SecondEdgeRecorderSeconds,
        lFeedback.DacStartRecorderSeconds, lFeedback.EffectiveSampleRateHz,
        Result.CalibrationRateFactor,
        lFeedback.DriftPpm, lFeedback.HostOffsetSeconds, lFeedback.Threshold,
        lFeedback.StepHeight, lFeedback.NoiseRms,
        lFeedback.CorrelationFirst, lFeedback.CorrelationSecond,
        lFeedback.CorrelationGainFirst, lFeedback.CorrelationGainSecond]));
    end;
    if (lFeedback.State = rdfsFailed) and not fCalibrationReported then
    begin
      fCalibrationReported := True;
      RecorderDebugLog(Format('[DAC feedback] run=%d failed=%s',
        [fRunSerial, lFeedback.Error]));
    end;
  end;
  Result.Counters := Default(TRecorderDacCounters);
  Result.State := rdsClosed;
  if fSession <> nil then
  begin
    Result.State := TRecorderDacSession(fSession).State;
    Result.Counters := TRecorderDacSession(fSession).Counters;
  end;
  EnterCriticalSection(fLock);
  try
    Result.LastResult := fLastResult;
  finally
    LeaveCriticalSection(fLock);
  end;
  if fRunner <> nil then
  begin
    lRunnerResult := TRecorderDacRunner(fRunner).LastResult;
    if (lRunnerResult.Error <> rdeNone) or
      (Result.LastResult.Error in [rdeNone, rdeCompleted]) then
      Result.LastResult := lRunnerResult;
  end;
end;

end.
