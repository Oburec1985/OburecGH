unit uRecorderDacFeedbackCalibration;

{ Feedback calibration is a mirror decorator, not an audio-driver clock.
  Configure allocates storage; Reset starts a new trial before submission.
  Until two observed rising edges anchor offset and rate, only provisional
  live samples are published; recording waits. Poll must also be called after finite output has completed.
  The publisher polls; UI reads snapshots or cancels. Mutable state is
  serialized. The feedback tag is borrowed for the trial lifetime. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Math, uRecorderTags, uRecorderBlockClock, uRecorderDacTypes,
  uRecorderDacContracts;

type
  TRecorderDacFeedbackState = (rdfsIdle, rdfsWaiting, rdfsLocked, rdfsFailed);

  TRecorderDacFeedbackSettings = record
    MarkerOffsetSeconds: Double;
    GeneratedBellMarker: Boolean;
    EdgeIntervalSeconds: Double;
    Threshold: Double; { Deprecated: ignored; midpoint level is measured. }
    TimeoutSeconds: Double;
    Polarity: Integer; { Deprecated: polarity is detected from each marker. }
  end;

  TRecorderDacFeedbackSnapshot = record
    State: TRecorderDacFeedbackState;
    EdgeRecorderSeconds: Double;
    SecondEdgeRecorderSeconds: Double;
    EffectiveSampleRateHz: Double;
    DriftPpm: Double;
    DetectedEdges: Integer;
    DacStartRecorderSeconds: Double;
    HostOffsetSeconds: Double;
    Baseline: Double;
    Threshold: Double;
    StepHeight: Double;
    NoiseRms: Double;
    DetectedPolarity: Integer;
    PendingFrames: Integer;
    CandidateCount: Integer;
    FirstReplacements: Integer;
    CorrelationFirst, CorrelationSecond: Double;
    CorrelationGainFirst, CorrelationGainSecond: Double;
    ManualRate: Boolean;
    Error: string;
  end;

  TRecorderDacFeedbackMirror = class(TInterfacedObject, IRecorderDacMirror,
    IRecorderDacTimedMirror, IRecorderDacMirrorIdentity,
    IRecorderDacMirrorMaintenance, IRecorderDacRateControlledMirror)
  private
    fMirror: IRecorderDacMirror;
    fTimedMirror: IRecorderDacTimedMirror;
    fProvisionalMirror: IRecorderDacProvisionalMirror;
    fFeedback: TRecorderTag;
    fSettings: TRecorderDacFeedbackSettings;
    fConfig: TRecorderDacConfig;
    fSnapshot: TRecorderDacFeedbackSnapshot;
    fLock: TRTLCriticalSection;
    fPending: array of Double;
    fPendingTimes: array of TRecorderBlockTime;
    fPendingOffsets: array of Integer;
    fPendingCount, fPendingFrames: Integer;
    fReadTimes, fReadValues: TRecorderDoubleArray;
    fCursor: QWord;
    fStartedAt, fHostStart, fPreviousTime, fPreviousValue: Double;
    fHavePrevious, fHaveHostStart, fConfigured: Boolean;
    fNextDeviceSeconds: Double;
    fGeneration: QWord;
    fFeedbackRate: Double;
    fCancelled: Boolean;
    fMarkerFrame, fEdgeIntervalFrames: Int64;
    fQuietSamples: Integer;
    fRearmed: Boolean;
    fRearmSamples: Integer;
    fMinimumMeasuredInterval, fMaximumMeasuredInterval: Double;
    fNoiseRms, fNoisePeak, fNoiseLimit, fLastHeight: Double;
    fFirstMarkerHeight, fCandidatePeakHeight, fCandidatePeakTime: Double;
    fCandidateMaximumSeconds: Double;
    fCandidateTimes, fCandidateValues: TRecorderDoubleArray;
    fCandidateCount, fCandidatePolarity: Integer;
    fFirstMarkerPolarity: Integer;
    fCorrelationIdeal, fCorrelationReference, fCorrelationScratch: TRecorderDoubleArray;
    fNativeOffsets, fNativeIdeal, fNativeReferenceOffsets,
      fNativeReference, fNativeScratch, fCorrelationSourceBell: TRecorderDoubleArray;
    fNativeReferenceCount: Integer;
    fRateAnchorFrame, fPublishedEndFrame: Int64;
    fRateAnchorSeconds: Double;
    fHistoryTimes, fHistoryValues: TRecorderDoubleArray;
    fHistoryCount, fHistoryCursor: Integer;
    function ValidateRateFactorLocked(AFactor: Double; out AResult: TRecorderDacResult): Boolean;
    function CandidateValue(ATime: Double; out AValue: Double): Boolean;
    function CorrelateCandidate(ACoarseTime: Double; AUseObserved: Boolean;
      out ATime, ARho, AGain: Double): Boolean;
    function ProcessFeedbackSample(ATime, AValue: Double;
      out AResult: TRecorderDacResult): Boolean;
    function CompleteCandidate(out AResult: TRecorderDacResult): Boolean;
    function AcceptEdge(AEdgeTime, AHeight: Double; APolarity: Integer;
      out AResult: TRecorderDacResult): Boolean;
    procedure StoreAcceptedHeight(AHeight: Double; APolarity: Integer);
    function Fail(const AText: string; out AResult: TRecorderDacResult): Boolean;
    function PollLocked(out AResult: TRecorderDacResult): Boolean;
    function PublishPending(out AResult: TRecorderDacResult): Boolean;
    function PublishBlock(ABuffer: PDouble; const ATime: TRecorderBlockTime;
      out AResult: TRecorderDacResult): Boolean;
  public
    function CanSetRateFactor(AFactor: Double; out AResult: TRecorderDacResult): Boolean;
    function SetRateFactorAtFrame(AFactor: Double; APivotFrame: QWord;
      out AResult: TRecorderDacResult): Boolean;
    constructor Create(const AMirror: IRecorderDacMirror;
      AFeedback: TRecorderTag; const ASettings: TRecorderDacFeedbackSettings);
    destructor Destroy; override;
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function WriteBlock(ABuffer: PDouble; AFrameCount: Integer;
      out AResult: TRecorderDacResult): Boolean;
    function WriteTimedBlock(ABuffer: PDouble; const ATime: TRecorderBlockTime;
      out AResult: TRecorderDacResult): Boolean;
    function Poll(out AResult: TRecorderDacResult): Boolean;
    function Pending: Boolean;
    procedure Cancel;
    function Snapshot: TRecorderDacFeedbackSnapshot;
    function MirrorIdentity: QWord;
  end;

  { Finite low-amplitude electrical marker. MarkerOffsetSeconds is the
    actual rounded first positive sample, not the requested unrounded delay. }
  TRecorderDacCalibrationProvider = class(TInterfacedObject,
    IRecorderDacSampleProvider)
  private
    fAmplitude, fSampleRate, fEdgeIntervalSeconds: Double;
    fBell: TRecorderDoubleArray;
    fPosition, fMarkerFrame, fPulseEndFrame, fTotalFrames: Int64;
    fSecondMarkerFrame, fSecondPulseEndFrame: Int64;
  public
    constructor Create(AAmplitude: Double = 0.05;
      AEdgeIntervalSeconds: Double = 2.0);
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
    function MarkerOffsetSeconds: Double;
  end;

  { Prepends a short marker to ordinary playback, so every Start gets its
    own physical anchor instead of reusing a previous USB queue delay. }
  TRecorderDacFeedbackProvider = class(TInterfacedObject,
    IRecorderDacSampleProvider, IRecorderDacSourceIdentity)
  private
    fProvider: IRecorderDacSampleProvider;
    fAmplitude, fSampleRate, fEdgeIntervalSeconds: Double;
    fBell: TRecorderDoubleArray;
    fPosition, fMarkerFrame, fPulseEndFrame, fPrefixFrames: Int64;
    fSecondMarkerFrame, fSecondPulseEndFrame: Int64;
  public
    constructor Create(const AProvider: IRecorderDacSampleProvider;
      AAmplitude: Double = 0.05; AEdgeIntervalSeconds: Double = 2.0);
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
    function SourceIdentity: QWord;
  end;

  IRecorderDacPlaybackControl = interface
    ['{7F7B98EB-08BE-4E58-991C-908A584690EC}']
    procedure SetPlaying(APlaying: Boolean);
    function SetProvider(const AProvider: IRecorderDacSampleProvider;
      out AResult: TRecorderDacResult): Boolean;
    function IsCalibrating: Boolean;
    function IsPlaying: Boolean;
    function SetPlaybackSampleRate(AEffective: Double;
      out AResult: TRecorderDacResult): Boolean;
  end;

  { One continuous native session: calibration window, then mute or playback.
    UI replaces/configures inner providers outside FillBlock; the control lock
    protects the handover. Start/Stop playback never resets the device clock. }
  TRecorderDacPersistentProvider = class(TInterfacedObject,
    IRecorderDacSampleProvider, IRecorderDacPlaybackControl,
    IRecorderDacSourceIdentity, IRecorderDacPlaybackRateControl)
  private
    fLock: TRTLCriticalSection;
    fProvider: IRecorderDacSampleProvider;
    fConfig: TRecorderDacConfig;
    fAmplitude, fDurationSeconds: Double;
    fBell: TRecorderDoubleArray;
    fPosition, fFirstMarker, fSecondMarker, fPulseFrames, fCalibrationFrames: Int64;
    fConfigured, fPlaying, fRequestedPlaying, fPlaybackRateReady: Boolean;
    fPlaybackRate: Double;
  public
    function CanSetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    constructor Create(const AProvider: IRecorderDacSampleProvider;
      AAmplitude: Double = 0.05; ACalibrationDurationSec: Double = 5);
    destructor Destroy; override;
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
    procedure SetPlaying(APlaying: Boolean);
    function SetProvider(const AProvider: IRecorderDacSampleProvider;
      out AResult: TRecorderDacResult): Boolean;
    function IsCalibrating: Boolean;
    function IsPlaying: Boolean;
    function SetPlaybackSampleRate(AEffective: Double;
      out AResult: TRecorderDacResult): Boolean;
    function SourceIdentity: QWord;
  end;

function RecorderDacDefaultFeedbackSettings: TRecorderDacFeedbackSettings;
function RecorderDacCalibrationPeakOffsetSeconds(ASampleRateHz: Double): Double;

implementation

uses uSharedStatistics;

const
  CFeedbackMaximumRelativeDrift = 0.01;
  CFeedbackMinimumEdgeInterval = 0.1;
  CFeedbackMaximumEdgeInterval = 30.0;
  CFeedbackPulseSeconds = 0.02;
  CFeedbackQuietSeconds = 0.02;
  CFeedbackMarkerSeconds = 0.1;
  CFeedbackCandidateSeconds = 0.016;
  CFeedbackMaximumCandidateSeconds = 0.128;
  CCorrelationPoints = 256;
  CCorrelationHalfWindow = 0.006;
  CCorrelationMinimum = 0.8;
  CCorrelationSearchRadius = 0.007; { Coarse lag bound; native refinement adds 5.34/Fadc. }

function BellFrames(ASampleRate: Double): Int64;
begin
  Result := 2 * Max(Int64(1), Round(0.5 * CFeedbackPulseSeconds * ASampleRate));
end;

function RecorderDacCalibrationPeakOffsetSeconds(ASampleRateHz: Double): Double;
begin
  if ASampleRateHz > 0 then
    Result := (Round(CFeedbackMarkerSeconds * ASampleRateHz) +
      BellFrames(ASampleRateHz) div 2) / ASampleRateHz
  else Result := 0.11;
end;

procedure PrepareBell(var ATable: TRecorderDoubleArray; AFrames: Int64; AAmplitude: Double);
var
  I: Integer;
begin
  SetLength(ATable, AFrames);
  for I := 0 to High(ATable) do
    ATable[I] := AAmplitude * 0.5 * (1 - Cos(2 * Pi * I / AFrames));
end;

function BellValue(APosition, AStart: Int64; const ATable: TRecorderDoubleArray): Double;
begin
  if (APosition < AStart) or (APosition >= AStart + Length(ATable)) then Exit(0);
  Result := ATable[APosition - AStart];
end;

function ValidEdgeInterval(ASeconds: Double): Boolean;
begin
  Result := not IsNan(ASeconds) and not IsInfinite(ASeconds) and
    (ASeconds >= CFeedbackMinimumEdgeInterval) and
    (ASeconds <= CFeedbackMaximumEdgeInterval);
end;

function RecorderDacDefaultFeedbackSettings: TRecorderDacFeedbackSettings;
begin
  Result.MarkerOffsetSeconds := 0.11;
  Result.GeneratedBellMarker := False;
  Result.EdgeIntervalSeconds := 2.0;
  Result.Threshold := 0.01;
  Result.TimeoutSeconds := 10;
  Result.Polarity := 1;
end;

constructor TRecorderDacFeedbackMirror.Create(const AMirror: IRecorderDacMirror;
  AFeedback: TRecorderTag; const ASettings: TRecorderDacFeedbackSettings);
begin
  inherited Create;
  InitCriticalSection(fLock);
  fMirror := AMirror;
  Supports(AMirror, IRecorderDacTimedMirror, fTimedMirror);
  Supports(AMirror, IRecorderDacProvisionalMirror, fProvisionalMirror);
  fFeedback := AFeedback;
  fSettings := ASettings;
end;

destructor TRecorderDacFeedbackMirror.Destroy;
begin
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderDacFeedbackMirror.Fail(const AText: string;
  out AResult: TRecorderDacResult): Boolean;
begin
  fSnapshot.State := rdfsFailed;
  fSnapshot.Error := AText;
  AResult := RecorderDacFailed(rdeNoData, rdsgWrite, AText);
  Result := False;
end;

function TRecorderDacFeedbackMirror.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
var
  lCapacity, I: Integer;
begin
  Result := False;
  fConfigured := False;
  if not RecorderDacValidateConfig(AConfig, AResult) then Exit;
  if (fTimedMirror = nil) or (fFeedback = nil) or
    (AConfig.ChannelCount <> 1) or
    (fSettings.TimeoutSeconds < 0.5) or (fSettings.TimeoutSeconds > 60) or
    IsNan(fSettings.TimeoutSeconds) or
    not ValidEdgeInterval(fSettings.EdgeIntervalSeconds) or
    (fSettings.TimeoutSeconds <= fSettings.MarkerOffsetSeconds +
      fSettings.EdgeIntervalSeconds + 0.1) or
    (fSettings.MarkerOffsetSeconds < 0) or
    (fSettings.MarkerOffsetSeconds >= fSettings.TimeoutSeconds) or
    IsNan(fSettings.MarkerOffsetSeconds) or
    IsInfinite(fSettings.MarkerOffsetSeconds) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Feedback calibration requires timed mono mirror, input tag and valid threshold/timeout');
    Exit;
  end;
  if (fFeedback.Id = MirrorIdentity) or (fFeedback.PollFrequencyHz <= 0) or
    IsNan(fFeedback.PollFrequencyHz) or IsInfinite(fFeedback.PollFrequencyHz) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Feedback must be a distinct sampled input, not the DAC mirror');
    Exit;
  end;
  if fFeedback.BlockTimeDomain <> btRecorderMonotonic then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Feedback input must be running in the recorder-monotonic time domain');
    Exit;
  end;
  { Validate the memory budget before the downstream mirror allocates history. }
  if (fSettings.TimeoutSeconds + 1) * AConfig.SampleRateHz > 10000000 then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Pending calibration exceeds ten million samples');
    Exit;
  end;
  if not fMirror.Configure(AConfig, AResult) then Exit;
  fConfig := AConfig;
  { The actual configured hardware rate may differ from the model rate.
    Derive the sample-exact source bell peak from that actual configuration. }
  if fSettings.GeneratedBellMarker then
    fMarkerFrame := Round(CFeedbackMarkerSeconds * AConfig.SampleRateHz) +
      BellFrames(AConfig.SampleRateHz) div 2
  else fMarkerFrame := Round(fSettings.MarkerOffsetSeconds * AConfig.SampleRateHz);
  fEdgeIntervalFrames := Round(fSettings.EdgeIntervalSeconds * AConfig.SampleRateHz);
  fFeedbackRate := fFeedback.PollFrequencyHz;
  { Never let one candidate consume the next calibration marker. }
  fCandidateMaximumSeconds := Min(CFeedbackMaximumCandidateSeconds,
    0.4 * fSettings.EdgeIntervalSeconds);
  fRearmSamples := Ceil(CFeedbackQuietSeconds * fFeedbackRate);
  fMinimumMeasuredInterval := fEdgeIntervalFrames /
    (fConfig.SampleRateHz * (1 + CFeedbackMaximumRelativeDrift)) -
    2 / fFeedbackRate;
  fMaximumMeasuredInterval := fEdgeIntervalFrames /
    (fConfig.SampleRateHz * (1 - CFeedbackMaximumRelativeDrift)) +
    2 / fFeedbackRate;
  lCapacity := Ceil((fSettings.TimeoutSeconds + 1) * AConfig.SampleRateHz);
  SetLength(fPending, lCapacity);
  SetLength(fPendingTimes, Ceil(lCapacity / AConfig.FramesPerBlock) + 1);
  SetLength(fPendingOffsets, Length(fPendingTimes));
  SetLength(fReadTimes, fFeedback.SignalBuffer.Capacity);
  SetLength(fReadValues, Length(fReadTimes));
  SetLength(fCandidateTimes, Ceil(CFeedbackMaximumCandidateSeconds * fFeedbackRate) + 4);
  SetLength(fCandidateValues, Length(fCandidateTimes));
  SetLength(fHistoryTimes, Ceil(0.01 * fFeedbackRate) + 2);
  SetLength(fHistoryValues, Length(fHistoryTimes));
  SetLength(fCorrelationIdeal, CCorrelationPoints);
  SetLength(fCorrelationReference, CCorrelationPoints);
  SetLength(fCorrelationScratch, CCorrelationPoints);
  SetLength(fNativeOffsets, Ceil(0.016 * fFeedbackRate) + 8);
  SetLength(fNativeIdeal, Length(fNativeOffsets));
  SetLength(fNativeReferenceOffsets, Length(fNativeOffsets));
  SetLength(fNativeReference, Length(fNativeOffsets));
  SetLength(fNativeScratch, Length(fNativeOffsets));
  PrepareBell(fCorrelationSourceBell, BellFrames(AConfig.SampleRateHz), 1);
  for I := 0 to CCorrelationPoints - 1 do
    fCorrelationIdeal[I] := 0.5 * (1 + Cos(Pi *
      (-CCorrelationHalfWindow + 2 * CCorrelationHalfWindow * I /
       (CCorrelationPoints - 1)) / (0.5 * CFeedbackPulseSeconds)));
  fConfigured := True;
  fSnapshot.State := rdfsIdle;
  AResult := RecorderDacOk;
  Result := True;
end;

procedure TRecorderDacFeedbackMirror.Reset;
var
  lCount, lBaselineCount, I: Integer;
  lBaselineStart, lSum, lMinimum, lMaximum, lMean, lM2, lDelta: Double;
  lFailure: TRecorderDacResult;
begin
  EnterCriticalSection(fLock);
  try
    fPendingCount := 0;
    fPendingFrames := 0;
    fHavePrevious := False;
    fHaveHostStart := False;
    fNextDeviceSeconds := 0;
    fGeneration := 0;
    fCancelled := False;
    fSnapshot.Error := '';
    fSnapshot.EdgeRecorderSeconds := 0;
    fSnapshot.SecondEdgeRecorderSeconds := 0;
    fSnapshot.EffectiveSampleRateHz := 0;
    fSnapshot.DriftPpm := 0;
    fSnapshot.DetectedEdges := 0;
    fSnapshot.CandidateCount := 0;
    fSnapshot.FirstReplacements := 0;
    fQuietSamples := 0;
    fRearmed := False;
    fCandidateCount := 0;
    fFirstMarkerPolarity := 0;
    fLastHeight := 0;
    fFirstMarkerHeight := 0;
    fCandidatePeakHeight := 0;
    fCandidatePeakTime := 0;
    fSnapshot.DacStartRecorderSeconds := 0;
    fSnapshot.HostOffsetSeconds := 0;
    fSnapshot.PendingFrames := 0;
    fSnapshot.Baseline := 0;
    fSnapshot.Threshold := 0;
    fSnapshot.CorrelationFirst := 0;
    fSnapshot.CorrelationSecond := 0;
    fSnapshot.CorrelationGainFirst := 0;
    fSnapshot.CorrelationGainSecond := 0;
    fSnapshot.ManualRate := False;
    fNativeReferenceCount := 0;
    fHistoryCount := 0;
    fHistoryCursor := 0;
    fSnapshot.StepHeight := 0;
    fSnapshot.NoiseRms := 0;
    fSnapshot.DetectedPolarity := 0;
    fNoiseRms := 0;
    fNoisePeak := 0;
    if not fConfigured then Exit;
    if fFeedback.SignalBuffer.Capacity > Length(fReadTimes) then
    begin
      Fail('Feedback ring capacity changed; configure a new calibration', lFailure);
      Exit;
    end;
    { One ring-locked snapshot establishes both baseline and sample cursor.
      Separate CurrentCursor/CopyLatest calls can include a new block in the
      baseline while leaving it unread, then falsely diagnose a clock reset. }
    fCursor := 0;
    fFeedback.SignalBuffer.SnapshotSinceInto(fCursor, fReadTimes, fReadValues, lCount);
    lSum := 0;
    lBaselineCount := 0;
    lMean := 0;
    lM2 := 0;
    if lCount > 0 then
    begin
      lBaselineStart := fReadTimes[lCount - 1] - 0.05;
      lMinimum := fReadValues[lCount - 1];
      lMaximum := lMinimum;
      for I := lCount - 1 downto 0 do
      begin
        if fReadTimes[I] < lBaselineStart then Break;
        if IsNan(fReadValues[I]) or IsInfinite(fReadValues[I]) then
        begin
          Fail('Non-finite pretrigger feedback sample', lFailure);
          Exit;
        end;
        lSum := lSum + fReadValues[I];
        lMinimum := Min(lMinimum, fReadValues[I]);
        lMaximum := Max(lMaximum, fReadValues[I]);
        Inc(lBaselineCount);
        lDelta := fReadValues[I] - lMean;
        lMean := lMean + lDelta / lBaselineCount;
        lM2 := lM2 + lDelta * (fReadValues[I] - lMean);
      end;
      if lBaselineCount > 0 then fSnapshot.Baseline := lSum / lBaselineCount;
      if lBaselineCount > 0 then fNoiseRms := Sqrt(Max(0, lM2 / lBaselineCount));
      fNoisePeak := Max(Abs(lMaximum - fSnapshot.Baseline),
        Abs(lMinimum - fSnapshot.Baseline));
      fPreviousTime := fReadTimes[lCount - 1];
      fPreviousValue := fReadValues[lCount - 1];
      fHavePrevious := True;
    end;
    { Only the noise gate decides when to save a bounded candidate. It is
      never used as the timing reference; the measured 50% level is. }
    fNoiseLimit := Max(Max(6 * fNoiseRms, 2 * fNoisePeak),
      Max(1e-15, Abs(fSnapshot.Baseline) * 1e-13));
    fSnapshot.NoiseRms := fNoiseRms;
    fStartedAt := RecorderClockSeconds;
    fSnapshot.State := rdfsWaiting;
    fMirror.Reset;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacFeedbackMirror.PublishBlock(ABuffer: PDouble;
  const ATime: TRecorderBlockTime; out AResult: TRecorderDacResult): Boolean;
var
  lTime: TRecorderBlockTime;
begin
  lTime := ATime;
  lTime.RecorderStartSeconds := fRateAnchorSeconds +
    (Round(ATime.DeviceStartSeconds * fConfig.SampleRateHz) - fRateAnchorFrame) /
    fSnapshot.EffectiveSampleRateHz;
  lTime.SampleRateHz := fSnapshot.EffectiveSampleRateHz;
  lTime.UncertaintySeconds := Max(ATime.UncertaintySeconds,
    1 / fFeedbackRate);
  Result := fTimedMirror.WriteTimedBlock(ABuffer, lTime, AResult);
  if Result then fPublishedEndFrame :=
    Round(ATime.DeviceStartSeconds * fConfig.SampleRateHz) + ATime.SampleCount;
end;

procedure TRecorderDacFeedbackMirror.StoreAcceptedHeight(AHeight: Double;
  APolarity: Integer);
begin
  fSnapshot.Threshold := fSnapshot.Baseline + APolarity * 0.5 * AHeight;
  fSnapshot.StepHeight := APolarity * AHeight;
  fSnapshot.DetectedPolarity := APolarity;
  fLastHeight := AHeight;
end;

function TRecorderDacFeedbackMirror.AcceptEdge(AEdgeTime, AHeight: Double;
  APolarity: Integer;
  out AResult: TRecorderDacResult): Boolean;
var
  lInterval, lMeasuredRate: Double;
begin
  AResult := RecorderDacOk;
  lInterval := AEdgeTime - fSnapshot.EdgeRecorderSeconds;
  if (fSnapshot.DetectedEdges = 0) or
    ((AHeight > 2 * fFirstMarkerHeight) and
      ((lInterval < fMinimumMeasuredInterval) or
       (lInterval > fMaximumMeasuredInterval) or
       (APolarity <> fFirstMarkerPolarity))) then
  begin
    if fSnapshot.DetectedEdges > 0 then Inc(fSnapshot.FirstReplacements);
    fSnapshot.EdgeRecorderSeconds := AEdgeTime;
    fSnapshot.DetectedEdges := 1;
    fFirstMarkerHeight := AHeight;
    fFirstMarkerPolarity := APolarity;
    StoreAcceptedHeight(AHeight, APolarity);
    fRearmed := False;
    fQuietSamples := 0;
    Exit(True);
  end;
  if not fRearmed then Exit(True);
  { Ignore ringing/extra crossings of the first pulse. A second marker can
    only correspond to the known frame separation, never an arbitrary edge. }
  if lInterval < fMinimumMeasuredInterval then Exit(True);
  if lInterval > fMaximumMeasuredInterval then Exit(True);
  if (APolarity <> fFirstMarkerPolarity) or
    (AHeight < 0.5 * fFirstMarkerHeight) then Exit(True);
  lMeasuredRate := fEdgeIntervalFrames / lInterval;
  if Abs(lMeasuredRate / fConfig.SampleRateHz - 1) >
    CFeedbackMaximumRelativeDrift then
    Exit(Fail('Measured DAC rate differs from nominal by more than one percent', AResult));
  fSnapshot.SecondEdgeRecorderSeconds := AEdgeTime;
  StoreAcceptedHeight(AHeight, APolarity);
  fSnapshot.DetectedEdges := 2;
  fSnapshot.EffectiveSampleRateHz := lMeasuredRate;
  fSnapshot.DriftPpm := (lMeasuredRate / fConfig.SampleRateHz - 1) * 1e6;
  fSnapshot.DacStartRecorderSeconds := fSnapshot.EdgeRecorderSeconds -
    fMarkerFrame / lMeasuredRate;
  fRateAnchorFrame := 0;
  fPublishedEndFrame := 0;
  fRateAnchorSeconds := fSnapshot.DacStartRecorderSeconds;
  fSnapshot.HostOffsetSeconds := fSnapshot.DacStartRecorderSeconds - fHostStart;
  fSnapshot.State := rdfsLocked;
  if (fProvisionalMirror <> nil) and
    not fProvisionalMirror.BeginCalibratedReplay(AResult) then
    Exit(Fail(AResult.Text, AResult));
  Result := PublishPending(AResult);
  if not Result then Fail(AResult.Text, AResult);
end;

function TRecorderDacFeedbackMirror.PublishPending(
  out AResult: TRecorderDacResult): Boolean;
var
  I: Integer;
begin
  for I := 0 to fPendingCount - 1 do
    if not PublishBlock(@fPending[fPendingOffsets[I]], fPendingTimes[I], AResult)
      then Exit(False);
  fPendingCount := 0;
  fPendingFrames := 0;
  fSnapshot.PendingFrames := 0;
  AResult := RecorderDacOk;
  Result := True;
end;

function TRecorderDacFeedbackMirror.CandidateValue(ATime: Double;
  out AValue: Double): Boolean;
var
  lFraction: Double;
  I, lLeft, lRight, lMiddle: Integer;
begin
  Result := (fCandidateCount >= 2) and (ATime >= fCandidateTimes[0]) and
    (ATime <= fCandidateTimes[fCandidateCount - 1]);
  if not Result then Exit;
  lLeft := 0;
  lRight := fCandidateCount - 1;
  while lRight - lLeft > 1 do
  begin
    lMiddle := lLeft + (lRight - lLeft) div 2;
    if fCandidateTimes[lMiddle] <= ATime then lLeft := lMiddle
    else lRight := lMiddle;
  end;
  I := lLeft;
  lFraction := (ATime - fCandidateTimes[I]) /
    (fCandidateTimes[I + 1] - fCandidateTimes[I]);
  AValue := fCandidateValues[I] + lFraction *
    (fCandidateValues[I + 1] - fCandidateValues[I]);
end;

function TRecorderDacFeedbackMirror.CorrelateCandidate(ACoarseTime: Double;
  AUseObserved: Boolean; out ATime, ARho, AGain: Double): Boolean;
var
  lReference: TRecorderDoubleArray;
  I, J, lStage, lBestIndex, lNativeCount, lSourceIndex: Integer;
  lNativeReference, lNativeOffsets: TRecorderDoubleArray;
  lCenter, lStep, lTrial, lRho, lBest, lSign, lScore: Double;
  lOffset, lSourcePosition, lSourceFraction: Double;
  lMinimumInterval, lQuarterInterval: Double;
  lMeanX, lMeanY, lVariance, lCovariance, lLeft, lRight, lMiddle, lShift: Double;
  function Score(ACenter: Double; out ARawRho: Double): Double;
  var
    K: Integer;
    lOffset: Double;
  begin
    for K := 0 to CCorrelationPoints - 1 do
    begin
      lOffset := -CCorrelationHalfWindow +
        2 * CCorrelationHalfWindow * K / (CCorrelationPoints - 1);
      if not CandidateValue(ACenter + lOffset, fCorrelationScratch[K]) then Exit(-2);
    end;
    if not TryCorrelation(lReference, fCorrelationScratch, ARawRho) then Exit(-2);
    Result := ARawRho * lSign;
  end;
  function NativeScore(ACenter: Double; out ARawRho: Double): Double;
  var
    K, lCursor: Integer;
    lTime, lFraction: Double;
  begin
    lCursor := 0;
    for K := 0 to lNativeCount - 1 do
    begin
      lTime := ACenter + lNativeOffsets[K];
      if (lTime < fCandidateTimes[0]) or
        (lTime > fCandidateTimes[fCandidateCount - 1]) then Exit(-2);
      while (lCursor < fCandidateCount - 2) and
        (fCandidateTimes[lCursor + 1] < lTime) do Inc(lCursor);
      lFraction := (lTime - fCandidateTimes[lCursor]) /
        (fCandidateTimes[lCursor + 1] - fCandidateTimes[lCursor]);
      fNativeScratch[K] := fCandidateValues[lCursor] + lFraction *
        (fCandidateValues[lCursor + 1] - fCandidateValues[lCursor]);
    end;
    if not TryCorrelation(Slice(lNativeReference, lNativeCount),
      Slice(fNativeScratch, lNativeCount), ARawRho) then Exit(-2);
    Result := ARawRho * lSign;
  end;
begin
  if AUseObserved then
  begin
    lReference := fCorrelationReference;
    lSign := fCandidatePolarity * fFirstMarkerPolarity;
  end
  else
  begin
    lReference := fCorrelationIdeal;
    lSign := fCandidatePolarity;
  end;
  lCenter := ACoarseTime;
  lStep := 0.006 / 16;
  lBest := -2;
  for lStage := 0 to 2 do
  begin
    lBest := -2;
    lBestIndex := 0;
    for J := -16 to 16 do
    begin
      lTrial := lCenter + J * lStep;
      lScore := Score(lTrial, lRho);
      if lScore > lBest then begin lBest := lScore; lBestIndex := J end;
    end;
    lCenter := lCenter + lBestIndex * lStep;
    if lStage < 2 then lStep := lStep / 8;
  end;
  { The small grid only seeds the lag. Acceptance, confidence and gain below
    use the native AI sample positions, never that coarse downsampled grid. }
  Result := lBest > -1;
  if not Result then Exit;
  if AUseObserved then
  begin
    lNativeOffsets := fNativeReferenceOffsets;
    lNativeReference := fNativeReference;
    lNativeCount := fNativeReferenceCount;
  end
  else
  begin
    lNativeCount := 0;
    for I := 0 to fCandidateCount - 1 do
      if Abs(fCandidateTimes[I] - lCenter) <= CCorrelationHalfWindow then
      begin
        if lNativeCount >= Length(fNativeOffsets) then Exit(False);
        lOffset := fCandidateTimes[I] - lCenter;
        fNativeOffsets[lNativeCount] := lOffset;
        lSourcePosition := Length(fCorrelationSourceBell) div 2 +
          lOffset * fConfig.SampleRateHz;
        lSourceIndex := Floor(lSourcePosition);
        if (lSourceIndex < 0) or
          (lSourceIndex >= High(fCorrelationSourceBell)) then Exit(False);
        lSourceFraction := lSourcePosition - lSourceIndex;
        fNativeIdeal[lNativeCount] := fCorrelationSourceBell[lSourceIndex] +
          lSourceFraction * (fCorrelationSourceBell[lSourceIndex + 1] -
          fCorrelationSourceBell[lSourceIndex]);
        Inc(lNativeCount);
      end;
    lNativeOffsets := fNativeOffsets;
    lNativeReference := fNativeIdeal;
  end;
  if lNativeCount < 8 then Exit(False);
  { Published neighboring timestamps, including the retained first-response
    grid, bound final resolution. Nominal Fs is only a conservative upper
    bound when the actual intervals are longer. }
  lMinimumInterval := 1 / fFeedbackRate;
  for I := 1 to fCandidateCount - 1 do
    lMinimumInterval := Min(lMinimumInterval,
      fCandidateTimes[I] - fCandidateTimes[I - 1]);
  for I := 1 to lNativeCount - 1 do
    lMinimumInterval := Min(lMinimumInterval,
      lNativeOffsets[I] - lNativeOffsets[I - 1]);
  if lMinimumInterval <= 0 then Exit(False);
  lQuarterInterval := 0.25 * lMinimumInterval;
  lStep := Max(lStep, lMinimumInterval);
  repeat
    lBest := -2;
    lBestIndex := 0;
    for J := -4 to 4 do
    begin
      lScore := NativeScore(lCenter + J * lStep, lRho);
      if lScore > lBest then begin lBest := lScore; lBestIndex := J end;
    end;
    lCenter := lCenter + lBestIndex * lStep;
    if lStep <= lQuarterInterval then Break;
    lStep := Max(lQuarterInterval, lStep / 4);
  until False;
  if lBest < CCorrelationMinimum then Exit(False);
  lLeft := NativeScore(lCenter - lStep, lRho);
  lMiddle := NativeScore(lCenter, lRho);
  lRight := NativeScore(lCenter + lStep, lRho);
  lShift := 0;
  if (lLeft > -1) and (lRight > -1) and
    (lLeft - 2 * lMiddle + lRight < -1e-15) then
    lShift := EnsureRange(0.5 * (lLeft - lRight) /
      (lLeft - 2 * lMiddle + lRight), -0.5, 0.5);
  ATime := lCenter + lShift * lStep;
  if NativeScore(ATime, ARho) < CCorrelationMinimum then Exit(False);
  lMeanX := 0;
  lMeanY := 0;
  for I := 0 to lNativeCount - 1 do
  begin
    lMeanX := lMeanX + lNativeReference[I] / lNativeCount;
    lMeanY := lMeanY + fNativeScratch[I] / lNativeCount;
  end;
  lVariance := 0;
  lCovariance := 0;
  for I := 0 to lNativeCount - 1 do
  begin
    lVariance := lVariance + Sqr(lNativeReference[I] - lMeanX);
    lCovariance := lCovariance + (lNativeReference[I] - lMeanX) *
      (fNativeScratch[I] - lMeanY);
  end;
  Result := lVariance > 0;
  if Result then AGain := lCovariance / lVariance;
end;

function TRecorderDacFeedbackMirror.CompleteCandidate(
  out AResult: TRecorderDacResult): Boolean;
var
  I, lPeakIndex, lSupport: Integer;
  lDelta, lHeight: Double;
  lPrevious, lCurrent, lNext, lDenominator, lFraction, lEdge: Double;
  lRho, lGain, lOffset: Double;
  lUseObserved: Boolean;
begin
  Result := True;
  AResult := RecorderDacOk;
  lHeight := 0;
  lPeakIndex := 0;
  for I := 1 to fCandidateCount - 1 do
  begin
    lDelta := fCandidateValues[I] - fSnapshot.Baseline;
    if Abs(lDelta) > lHeight then
    begin
      lHeight := Abs(lDelta);
      lPeakIndex := I;
      if lDelta > 0 then fCandidatePolarity := 1 else fCandidatePolarity := -1;
    end;
  end;
  { AC-coupled audio can have no plateau: estimate its dominant response
    lobe instead. An isolated ADC spike must have another supporting sample. }
  if (lHeight <= Max(12 * fNoiseRms, Max(3 * fNoisePeak,
    Max(1e-15, Abs(fSnapshot.Baseline) * 4e-13)))) then Exit;
  lSupport := 0;
  for I := 1 to fCandidateCount - 1 do
    if (fCandidateValues[I] - fSnapshot.Baseline) * fCandidatePolarity >=
      0.5 * lHeight then Inc(lSupport);
  if lSupport < 2 then Exit;
  Inc(fSnapshot.CandidateCount);
  { Both DAC markers have the same sign. A falling edge/undershoot in the
    second gate must not silently replace the first marker's polarity. }
  { A stronger physical response may replace an earlier noise candidate,
    including one with the opposite sign. Pair polarity is checked only
    after that replacement decision, in AcceptEdge. }
  if (lPeakIndex < 1) or (lPeakIndex >= fCandidateCount - 1) then Exit;
  lPrevious := (fCandidateValues[lPeakIndex - 1] - fSnapshot.Baseline) * fCandidatePolarity;
  lCurrent := (fCandidateValues[lPeakIndex] - fSnapshot.Baseline) * fCandidatePolarity;
  lNext := (fCandidateValues[lPeakIndex + 1] - fSnapshot.Baseline) * fCandidatePolarity;
  lDenominator := lPrevious - 2 * lCurrent + lNext;
  lFraction := 0;
  if lDenominator < 0 then
    lFraction := EnsureRange(0.5 * (lPrevious - lNext) / lDenominator, -0.5, 0.5);
  lEdge := fCandidateTimes[lPeakIndex];
  if lFraction >= 0 then
    lEdge := lEdge + lFraction * (fCandidateTimes[lPeakIndex + 1] - lEdge)
  else
    lEdge := lEdge + lFraction * (lEdge - fCandidateTimes[lPeakIndex - 1]);
  lUseObserved := (fSnapshot.DetectedEdges = 1) and
    (fCandidatePolarity = fFirstMarkerPolarity) and
    (lEdge - fSnapshot.EdgeRecorderSeconds >=
      fMinimumMeasuredInterval - CCorrelationSearchRadius - 5.34 / fFeedbackRate) and
    (lEdge - fSnapshot.EdgeRecorderSeconds <=
      fMaximumMeasuredInterval + CCorrelationSearchRadius + 5.34 / fFeedbackRate);
  if not CorrelateCandidate(lEdge, lUseObserved, lEdge, lRho, lGain) then Exit;
  Result := AcceptEdge(lEdge, lHeight, fCandidatePolarity, AResult);
  if not Result then Exit;
  if (fSnapshot.DetectedEdges = 1) and (fSnapshot.EdgeRecorderSeconds = lEdge) then
  begin
    fSnapshot.CorrelationFirst := lRho;
    fSnapshot.CorrelationGainFirst := lGain;
    fNativeReferenceCount := 0;
    for I := 0 to fCandidateCount - 1 do
      if Abs(fCandidateTimes[I] - lEdge) <= CCorrelationHalfWindow then
      begin
        if fNativeReferenceCount >= Length(fNativeReference) then
          Exit(Fail('Native feedback template exceeds prepared capacity', AResult));
        fNativeReferenceOffsets[fNativeReferenceCount] := fCandidateTimes[I] - lEdge;
        fNativeReference[fNativeReferenceCount] := fCandidateValues[I];
        Inc(fNativeReferenceCount);
      end;
    for I := 0 to CCorrelationPoints - 1 do
    begin
      lOffset := -CCorrelationHalfWindow + 2 * CCorrelationHalfWindow * I /
        (CCorrelationPoints - 1);
      CandidateValue(lEdge + lOffset, fCorrelationReference[I]);
    end;
  end
  else if (fSnapshot.State = rdfsLocked) then
  begin
    fSnapshot.CorrelationSecond := lRho;
    fSnapshot.CorrelationGainSecond := lGain;
  end;
end;

function TRecorderDacFeedbackMirror.ProcessFeedbackSample(ATime,
  AValue: Double; out AResult: TRecorderDacResult): Boolean;
var
  I, lHistoryIndex: Integer;
  lDelta, lQuietLevel: Double;
begin
  AResult := RecorderDacOk;
  Result := True;
  if fSnapshot.State <> rdfsWaiting then Exit;
  lDelta := AValue - fSnapshot.Baseline;
  if fSnapshot.DetectedEdges = 1 then
  begin
    lQuietLevel := Max(fNoiseLimit, 0.1 * fLastHeight);
    if Abs(lDelta) < lQuietLevel then Inc(fQuietSamples)
    else fQuietSamples := 0;
    if fQuietSamples >= fRearmSamples then fRearmed := True;
  end;
  if fCandidateCount > 0 then
  begin
    if fCandidateCount >= Length(fCandidateTimes) then
      Exit(Fail('Feedback midpoint candidate exceeds prepared capacity', AResult));
    fCandidateTimes[fCandidateCount] := ATime;
    fCandidateValues[fCandidateCount] := AValue;
    Inc(fCandidateCount);
    if Abs(lDelta) > fCandidatePeakHeight then
    begin
      fCandidatePeakHeight := Abs(lDelta);
      fCandidatePeakTime := ATime;
    end;
    { Keep the complete rising lobe when a real response begins near the
      end of a noise-triggered window. Storage remains bounded/preallocated. }
    if ((ATime - fCandidateTimes[1] >= CFeedbackCandidateSeconds) and
      (ATime - fCandidatePeakTime >= CFeedbackCandidateSeconds)) or
      (ATime - fCandidateTimes[1] >= fCandidateMaximumSeconds) then
    begin
      Result := CompleteCandidate(AResult);
      fCandidateCount := 0;
    end;
    Exit;
  end;
  if not fHaveHostStart or not fHavePrevious or
    (Abs(lDelta) <= fNoiseLimit) then Exit;
  { Observe candidates between the two markers as well: otherwise a small
    early transient permanently owns the first marker's clock origin. }
  if lDelta > 0 then fCandidatePolarity := 1 else fCandidatePolarity := -1;
  for I := 0 to fHistoryCount - 1 do
  begin
    lHistoryIndex := (fHistoryCursor - fHistoryCount + I + Length(fHistoryTimes)) mod Length(fHistoryTimes);
    fCandidateTimes[I] := fHistoryTimes[lHistoryIndex];
    fCandidateValues[I] := fHistoryValues[lHistoryIndex];
  end;
  fCandidateCount := fHistoryCount;
  fCandidateTimes[fCandidateCount] := ATime;
  fCandidateValues[fCandidateCount] := AValue;
  Inc(fCandidateCount);
  fCandidatePeakHeight := Abs(lDelta);
  fCandidatePeakTime := ATime;
end;

function TRecorderDacFeedbackMirror.PollLocked(
  out AResult: TRecorderDacResult): Boolean;
var
  lCount, I: Integer;
  lCursorBefore, lCursorNow: QWord;
begin
  if fSnapshot.State = rdfsFailed then
    Exit(Fail(fSnapshot.Error, AResult));
  AResult := RecorderDacOk;
  if not (fSnapshot.State in [rdfsWaiting, rdfsLocked]) or fCancelled then Exit(True);
  if (fFeedback.BlockTimeDomain <> btRecorderMonotonic) or
    (fFeedback.PollFrequencyHz <> fFeedbackRate) then
    Exit(Fail('Feedback clock domain or sample rate changed during calibration', AResult));
  if fFeedback.SignalBuffer.Capacity > Length(fReadTimes) then
    Exit(Fail('Feedback ring capacity changed during calibration', AResult));
  if (fSnapshot.State = rdfsLocked) and
    (fFeedback.SignalBuffer.Count = 0) then
    Exit(Fail('Feedback ring was cleared after calibration', AResult));
  lCursorBefore := fCursor;
  lCursorNow := fFeedback.SignalBuffer.CurrentCursor;
  if (lCursorNow < fCursor) or
    (lCursorNow - fCursor > QWord(Length(fReadTimes))) then
    Exit(Fail('Feedback samples were reset or overwritten during calibration', AResult));
  fFeedback.SignalBuffer.SnapshotSinceInto(fCursor, fReadTimes, fReadValues, lCount);
  if fCursor - lCursorBefore <> QWord(lCount) then
    Exit(Fail('Feedback sample gap during calibration', AResult));
  for I := 0 to lCount - 1 do
  begin
    if IsNan(fReadValues[I]) or IsInfinite(fReadValues[I]) or
      IsNan(fReadTimes[I]) or IsInfinite(fReadTimes[I]) then
      Exit(Fail('Non-finite feedback sample', AResult));
    if fHavePrevious and (fReadTimes[I] <= fPreviousTime) then
      Exit(Fail('Feedback clock restarted during calibration', AResult));
    if ((fSnapshot.State = rdfsLocked) or (fSnapshot.DetectedEdges > 0)) and fHavePrevious and
      (fReadTimes[I] - fPreviousTime > 1.5 / fFeedbackRate) then
      Exit(Fail('Feedback timestamp gap invalidated calibration', AResult));
    if not ProcessFeedbackSample(fReadTimes[I], fReadValues[I], AResult) then Exit(False);
    fHistoryTimes[fHistoryCursor] := fReadTimes[I];
    fHistoryValues[fHistoryCursor] := fReadValues[I];
    fHistoryCursor := (fHistoryCursor + 1) mod Length(fHistoryTimes);
    if fHistoryCount < Length(fHistoryTimes) then Inc(fHistoryCount);
    fPreviousTime := fReadTimes[I];
    fPreviousValue := fReadValues[I];
    fHavePrevious := True;
  end;
  if (fSnapshot.State = rdfsWaiting) and
    (RecorderClockSeconds - fStartedAt > fSettings.TimeoutSeconds) then
    Exit(Fail('Both feedback rising edges were not detected before calibration timeout', AResult));
  Result := True;
end;

function TRecorderDacFeedbackMirror.Pending: Boolean;
begin
  EnterCriticalSection(fLock);
  try
    Result := not fCancelled and (fSnapshot.State = rdfsWaiting);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderDacFeedbackMirror.Cancel;
begin
  EnterCriticalSection(fLock);
  try
    fCancelled := True;
    fPendingCount := 0;
    fPendingFrames := 0;
    fSnapshot.PendingFrames := 0;
    if fSnapshot.State = rdfsWaiting then
    begin
      fSnapshot.State := rdfsFailed;
      fSnapshot.Error := 'Calibration cancelled';
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacFeedbackMirror.Poll(out AResult: TRecorderDacResult): Boolean;
begin
  EnterCriticalSection(fLock);
  try
    if fCancelled then Exit(Fail('Calibration cancelled', AResult));
    Result := PollLocked(AResult);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacFeedbackMirror.WriteTimedBlock(ABuffer: PDouble;
  const ATime: TRecorderBlockTime; out AResult: TRecorderDacResult): Boolean;
begin
  EnterCriticalSection(fLock);
  try
    if fCancelled then Exit(Fail('Calibration cancelled', AResult));
    if not fConfigured or (fSnapshot.State = rdfsIdle) then
      Exit(Fail('Reset configured feedback calibration before output', AResult));
    if (ABuffer = nil) or (ATime.SampleCount < 1) or
      (ATime.SampleCount > fConfig.FramesPerBlock) or
      (ATime.SampleRateHz <> fConfig.SampleRateHz) or (ATime.Generation = 0) then
      Exit(Fail('Invalid or untimed DAC block for feedback calibration', AResult));
    if (Abs(ATime.DeviceStartSeconds - fNextDeviceSeconds) >
      0.1 / fConfig.SampleRateHz) or
      ((fGeneration <> 0) and (fGeneration <> ATime.Generation)) then
      Exit(Fail('DAC mirror block gap or generation change during calibration', AResult));
    fNextDeviceSeconds := ATime.DeviceStartSeconds +
      ATime.SampleCount / fConfig.SampleRateHz;
    fGeneration := ATime.Generation;
    if not fHaveHostStart then
    begin
      fHostStart := ATime.RecorderStartSeconds - ATime.DeviceStartSeconds;
      fHaveHostStart := True;
    end;
    if not PollLocked(AResult) then Exit(False);
    if fSnapshot.State = rdfsLocked then
      Exit(PublishBlock(ABuffer, ATime, AResult));
    if (fPendingCount >= Length(fPendingTimes)) or
      (ATime.SampleCount > Length(fPending) - fPendingFrames) then
      Exit(Fail('Pending DAC calibration buffer is full', AResult));
    fPendingTimes[fPendingCount] := ATime;
    fPendingOffsets[fPendingCount] := fPendingFrames;
    Move(ABuffer^, fPending[fPendingFrames], ATime.SampleCount * SizeOf(Double));
    Inc(fPendingFrames, ATime.SampleCount);
    Inc(fPendingCount);
    fSnapshot.PendingFrames := fPendingFrames;
    if (fProvisionalMirror <> nil) and
      not fProvisionalMirror.WriteProvisionalTimedBlock(ABuffer, ATime, AResult) then
      Exit(Fail(AResult.Text, AResult));
    AResult := RecorderDacOk;
    Result := True;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacFeedbackMirror.WriteBlock(ABuffer: PDouble;
  AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
begin
  AResult := RecorderDacFailed(rdeInvalidConfig, rdsgWrite,
    'Feedback calibration requires timed DAC blocks');
  Result := False;
end;

function TRecorderDacFeedbackMirror.ValidateRateFactorLocked(AFactor: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := (fSnapshot.State = rdfsLocked) and not fCancelled and
    (fPendingCount = 0) and not IsNan(AFactor) and not IsInfinite(AFactor) and
    (AFactor >= 0.99) and (AFactor <= 1.01);
  if Result then AResult := RecorderDacOk
  else AResult := RecorderDacFailed(rdeInvalidConfig, rdsgWrite,
    'Manual rate requires completed calibration and factor 0.99..1.01');
end;

function TRecorderDacFeedbackMirror.CanSetRateFactor(AFactor: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  EnterCriticalSection(fLock);
  try
    Result := ValidateRateFactorLocked(AFactor, AResult);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacFeedbackMirror.SetRateFactorAtFrame(AFactor: Double;
  APivotFrame: QWord; out AResult: TRecorderDacResult): Boolean;
begin
  EnterCriticalSection(fLock);
  try
    Result := ValidateRateFactorLocked(AFactor, AResult);
    if not Result then Exit;
    if APivotFrame <> QWord(fPublishedEndFrame) then
    begin
      AResult := RecorderDacFailed(rdeInvalidState, rdsgWrite,
        'Manual clock transition must match the next published frame');
      Exit(False);
    end;
    fRateAnchorSeconds := fRateAnchorSeconds +
      (fPublishedEndFrame - fRateAnchorFrame) / fSnapshot.EffectiveSampleRateHz;
    fRateAnchorFrame := fPublishedEndFrame;
    fSnapshot.EffectiveSampleRateHz := fConfig.SampleRateHz * AFactor;
    fSnapshot.DriftPpm := (AFactor - 1) * 1e6;
    fSnapshot.ManualRate := True;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacFeedbackMirror.Snapshot: TRecorderDacFeedbackSnapshot;
begin
  EnterCriticalSection(fLock);
  try
    Result := fSnapshot;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacFeedbackMirror.MirrorIdentity: QWord;
var
  lIdentity: IRecorderDacMirrorIdentity;
begin
  if Supports(fMirror, IRecorderDacMirrorIdentity, lIdentity) then
    Result := lIdentity.MirrorIdentity else Result := 0;
end;

constructor TRecorderDacCalibrationProvider.Create(AAmplitude,
  AEdgeIntervalSeconds: Double);
begin
  inherited Create;
  fAmplitude := AAmplitude;
  fEdgeIntervalSeconds := AEdgeIntervalSeconds;
end;

function TRecorderDacCalibrationProvider.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := False;
  if not RecorderDacValidateConfig(AConfig, AResult) then Exit;
  if not ValidEdgeInterval(fEdgeIntervalSeconds) or
    (AConfig.ChannelCount <> 1) or IsNan(fAmplitude) or
    IsInfinite(fAmplitude) or (fAmplitude <= 0) or
    (fAmplitude > AConfig.MaximumValue) or (AConfig.MinimumValue > 0) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Calibration marker requires mono output and positive in-range amplitude');
    Exit;
  end;
  fSampleRate := AConfig.SampleRateHz;
  fMarkerFrame := Round(CFeedbackMarkerSeconds * fSampleRate);
  fPulseEndFrame := fMarkerFrame + BellFrames(fSampleRate);
  PrepareBell(fBell, fPulseEndFrame - fMarkerFrame, fAmplitude);
  fSecondMarkerFrame := fMarkerFrame + Round(fEdgeIntervalSeconds * fSampleRate);
  fSecondPulseEndFrame := fSecondMarkerFrame + (fPulseEndFrame - fMarkerFrame);
  fTotalFrames := Max(fSecondPulseEndFrame + 1,
    Round((CFeedbackMarkerSeconds + fEdgeIntervalSeconds + 0.3) * fSampleRate));
  Reset;
  AResult := RecorderDacOk;
  Result := True;
end;

procedure TRecorderDacCalibrationProvider.Reset;
begin
  fPosition := 0;
end;

function TRecorderDacCalibrationProvider.MarkerOffsetSeconds: Double;
begin
  if fSampleRate > 0 then Result := (fMarkerFrame + (fPulseEndFrame - fMarkerFrame) div 2) / fSampleRate
  else Result := 0.1;
end;

function TRecorderDacCalibrationProvider.FillBlock(ABuffer: PDouble;
  AFrameCapacity: Integer; out AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
var
  I: Integer;
begin
  AFrameCount := 0;
  if fPosition >= fTotalFrames then
  begin
    AResult := RecorderDacFailed(rdeCompleted, rdsgWrite, 'Calibration marker completed');
    Exit(False);
  end;
  AFrameCount := Min(Int64(AFrameCapacity), fTotalFrames - fPosition);
  for I := 0 to AFrameCount - 1 do
  begin
    if ((fPosition >= fMarkerFrame) and (fPosition < fPulseEndFrame)) or
      ((fPosition >= fSecondMarkerFrame) and (fPosition < fSecondPulseEndFrame)) then
      ABuffer[I] := BellValue(fPosition, fMarkerFrame, fBell) +
        BellValue(fPosition, fSecondMarkerFrame, fBell)
    else ABuffer[I] := 0;
    Inc(fPosition);
  end;
  AResult := RecorderDacOk;
  Result := True;
end;

constructor TRecorderDacFeedbackProvider.Create(
  const AProvider: IRecorderDacSampleProvider; AAmplitude,
  AEdgeIntervalSeconds: Double);
begin
  inherited Create;
  fProvider := AProvider;
  fAmplitude := AAmplitude;
  fEdgeIntervalSeconds := AEdgeIntervalSeconds;
end;

function TRecorderDacFeedbackProvider.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := False;
  if not RecorderDacValidateConfig(AConfig, AResult) then Exit;
  if not ValidEdgeInterval(fEdgeIntervalSeconds) or
    (fProvider = nil) or (AConfig.ChannelCount <> 1) or
    IsNan(fAmplitude) or IsInfinite(fAmplitude) or (fAmplitude <= 0) or
    (fAmplitude > AConfig.MaximumValue) or (AConfig.MinimumValue > 0) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Feedback marker requires mono output and positive in-range amplitude');
    Exit;
  end;
  if not fProvider.Configure(AConfig, AResult) then Exit;
  fSampleRate := AConfig.SampleRateHz;
  fMarkerFrame := Round(CFeedbackMarkerSeconds * fSampleRate);
  fPulseEndFrame := fMarkerFrame + BellFrames(fSampleRate);
  PrepareBell(fBell, fPulseEndFrame - fMarkerFrame, fAmplitude);
  fSecondMarkerFrame := fMarkerFrame + Round(fEdgeIntervalSeconds * fSampleRate);
  fSecondPulseEndFrame := fSecondMarkerFrame + (fPulseEndFrame - fMarkerFrame);
  fPrefixFrames := Max(fSecondPulseEndFrame + 1,
    Round((CFeedbackMarkerSeconds + fEdgeIntervalSeconds + 0.2) * fSampleRate));
  Reset;
  Result := True;
end;

procedure TRecorderDacFeedbackProvider.Reset;
begin
  fPosition := 0;
  fProvider.Reset;
end;

function TRecorderDacFeedbackProvider.FillBlock(ABuffer: PDouble;
  AFrameCapacity: Integer; out AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
var
  lTailCount: Integer;
  lTailResult: Boolean;
begin
  AFrameCount := 0;
  while (fPosition < fPrefixFrames) and (AFrameCount < AFrameCapacity) do
  begin
    if ((fPosition >= fMarkerFrame) and (fPosition < fPulseEndFrame)) or
      ((fPosition >= fSecondMarkerFrame) and (fPosition < fSecondPulseEndFrame)) then
      ABuffer[AFrameCount] := BellValue(fPosition, fMarkerFrame, fBell) +
        BellValue(fPosition, fSecondMarkerFrame, fBell)
    else ABuffer[AFrameCount] := 0;
    Inc(fPosition);
    Inc(AFrameCount);
  end;
  if AFrameCount < AFrameCapacity then
  begin
    lTailResult := fProvider.FillBlock(@ABuffer[AFrameCount],
      AFrameCapacity - AFrameCount, lTailCount, AResult);
    if lTailResult then Inc(AFrameCount, lTailCount)
    else if (AFrameCount = 0) or (AResult.Error <> rdeCompleted) then Exit(False);
  end;
  AResult := RecorderDacOk;
  Result := AFrameCount > 0;
end;

function TRecorderDacFeedbackProvider.SourceIdentity: QWord;
var
  lIdentity: IRecorderDacSourceIdentity;
begin
  if Supports(fProvider, IRecorderDacSourceIdentity, lIdentity) then
    Result := lIdentity.SourceIdentity else Result := 0;
end;

constructor TRecorderDacPersistentProvider.Create(
  const AProvider: IRecorderDacSampleProvider; AAmplitude,
  ACalibrationDurationSec: Double);
begin
  inherited Create;
  InitCriticalSection(fLock);
  fProvider := AProvider;
  fAmplitude := AAmplitude;
  fDurationSeconds := ACalibrationDurationSec;
end;

destructor TRecorderDacPersistentProvider.Destroy;
begin
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderDacPersistentProvider.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
begin
  EnterCriticalSection(fLock);
  try
  Result := False;
  fConfigured := False;
  if not RecorderDacValidateConfig(AConfig, AResult) then Exit;
  if (fProvider = nil) or (AConfig.ChannelCount <> 1) or
    ((fDurationSeconds <> 0) and not ValidEdgeInterval(fDurationSeconds - 0.4)) or
    ((fDurationSeconds > 0) and
      (IsNan(fAmplitude) or IsInfinite(fAmplitude) or (fAmplitude <= 0) or
       (fAmplitude > AConfig.MaximumValue) or (AConfig.MinimumValue > 0))) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Persistent calibration requires valid mono provider, duration and amplitude');
    Exit;
  end;
  if not fProvider.Configure(AConfig, AResult) then Exit;
  fConfig := AConfig;
  fFirstMarker := Round(CFeedbackMarkerSeconds * AConfig.SampleRateHz);
  fSecondMarker := fFirstMarker + Round((fDurationSeconds - 0.4) * AConfig.SampleRateHz);
  fPulseFrames := BellFrames(AConfig.SampleRateHz);
  PrepareBell(fBell, fPulseFrames, fAmplitude);
  fCalibrationFrames := Round(fDurationSeconds * AConfig.SampleRateHz);
  fConfigured := True;
  fPlaybackRate := fConfig.SampleRateHz;
  fPlaybackRateReady := fDurationSeconds = 0;
  fPosition := 0;
  fPlaying := fRequestedPlaying;
  fProvider.Reset;
  AResult := RecorderDacOk;
  Result := True;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderDacPersistentProvider.Reset;
begin
  EnterCriticalSection(fLock);
  try
    fPosition := 0;
    fPlaybackRate := fConfig.SampleRateHz;
    fPlaybackRateReady := fDurationSeconds = 0;
    fPlaying := fRequestedPlaying;
    if fProvider <> nil then fProvider.Reset;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacPersistentProvider.FillBlock(ABuffer: PDouble;
  AFrameCapacity: Integer; out AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
var
  lPrefix, lCount, I: Integer;
begin
  EnterCriticalSection(fLock);
  try
    AFrameCount := 0;
    if not fConfigured or (ABuffer = nil) or (AFrameCapacity <= 0) then
    begin
      AResult := RecorderDacFailed(rdeInvalidState, rdsgWrite,
        'Configure persistent DAC provider before FillBlock');
      Exit(False);
    end;
    lPrefix := 0;
    while (lPrefix < AFrameCapacity) and (fPosition < fCalibrationFrames) do
    begin
      if ((fPosition >= fFirstMarker) and (fPosition < fFirstMarker + fPulseFrames)) or
        ((fPosition >= fSecondMarker) and (fPosition < fSecondMarker + fPulseFrames)) then
        ABuffer[lPrefix] := BellValue(fPosition, fFirstMarker, fBell) +
          BellValue(fPosition, fSecondMarker, fBell)
      else ABuffer[lPrefix] := 0;
      Inc(lPrefix);
      Inc(fPosition);
    end;
    lCount := 0;
    { Calibration changes the synthesis clock, not the native stream clock.
      While the preparation owner applies measured Fs, keep emitting zeros;
      generating even a short nominal-Fs signal would reintroduce phase drift. }
    if fPlaying and fPlaybackRateReady and (lPrefix < AFrameCapacity) then
    begin
      if not fProvider.FillBlock(@ABuffer[lPrefix], AFrameCapacity - lPrefix,
        lCount, AResult) then
      begin
        if AResult.Error <> rdeCompleted then Exit(False);
        fPlaying := False;
        fRequestedPlaying := False;
        lCount := 0;
      end;
      if (lCount < 0) or (lCount > AFrameCapacity - lPrefix) then
      begin
        AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
          'Inner playback provider returned an invalid frame count');
        Exit(False);
      end;
    end;
    for I := lPrefix + lCount to AFrameCapacity - 1 do ABuffer[I] := 0;
    Inc(fPosition, AFrameCapacity - lPrefix);
    AFrameCount := AFrameCapacity;
    AResult := RecorderDacOk;
    Result := True;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderDacPersistentProvider.SetPlaying(APlaying: Boolean);
begin
  EnterCriticalSection(fLock);
  try
    if APlaying and not fPlaying and (fProvider <> nil) then fProvider.Reset;
    fPlaying := APlaying;
    fRequestedPlaying := APlaying;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacPersistentProvider.SetProvider(
  const AProvider: IRecorderDacSampleProvider;
  out AResult: TRecorderDacResult): Boolean;
var
  lPlaybackConfig: TRecorderDacConfig;
begin
  EnterCriticalSection(fLock);
  try
    if AProvider = nil then
    begin
      AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
        'Playback provider is required');
      Exit(False);
    end;
    lPlaybackConfig := fConfig;
    lPlaybackConfig.SampleRateHz := fPlaybackRate;
    if fConfigured and not AProvider.Configure(lPlaybackConfig, AResult) then Exit(False);
    fProvider := AProvider;
    fProvider.Reset;
    AResult := RecorderDacOk;
    Result := True;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacPersistentProvider.IsCalibrating: Boolean;
begin
  EnterCriticalSection(fLock);
  try
    Result := fConfigured and ((fPosition < fCalibrationFrames) or not fPlaybackRateReady);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacPersistentProvider.CanSetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
var
  lControl: IRecorderDacPlaybackRateControl;
begin
  EnterCriticalSection(fLock);
  try
    Result := False;
    if not fConfigured or not fPlaybackRateReady or IsNan(AHz) or IsInfinite(AHz) or
      (AHz <= 0) or (Abs(AHz / fConfig.SampleRateHz - 1) >
       CFeedbackMaximumRelativeDrift + 1e-12) then
    begin
      AResult := RecorderDacFailed(rdeInvalidState, rdsgConfigure,
        'Complete calibration before changing the playback clock');
      Exit;
    end;
    if not Supports(fProvider, IRecorderDacPlaybackRateControl, lControl) then
    begin
      AResult := RecorderDacFailed(rdeUnsupported, rdsgConfigure,
        'Playback provider cannot preserve phase during a clock change');
      Exit;
    end;
    Result := lControl.CanSetPlaybackSampleRate(AHz, AResult);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacPersistentProvider.SetPlaybackSampleRate(AEffective: Double;
  out AResult: TRecorderDacResult): Boolean;
var
  lPlaybackConfig: TRecorderDacConfig;
  lRateControl: IRecorderDacPlaybackRateControl;
begin
  EnterCriticalSection(fLock);
  try
    if not fConfigured then
    begin
      AResult := RecorderDacFailed(rdeInvalidState, rdsgConfigure,
        'Configure native DAC before applying measured playback sample rate');
      Exit(False);
    end;
    if IsNan(AEffective) or IsInfinite(AEffective) or (AEffective <= 0) or
      (Abs(AEffective / fConfig.SampleRateHz - 1) > CFeedbackMaximumRelativeDrift + 1e-12) then
    begin
      AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
        'Measured playback rate must be finite, positive and within one percent of native rate');
      Exit(False);
    end;
    if fPlaybackRateReady and (AEffective = fPlaybackRate) then
    begin
      AResult := RecorderDacOk;
      Exit(True);
    end;
    if fPlaybackRateReady then
    begin
      if not Supports(fProvider, IRecorderDacPlaybackRateControl, lRateControl) then
      begin
        AResult := RecorderDacFailed(rdeUnsupported, rdsgConfigure,
          'Playback provider cannot preserve phase during a clock change');
        Exit(False);
      end;
      if not lRateControl.SetPlaybackSampleRate(AEffective, AResult) then Exit(False);
    end
    else
    begin
      lPlaybackConfig := fConfig;
      lPlaybackConfig.SampleRateHz := AEffective;
      if not fProvider.Configure(lPlaybackConfig, AResult) then Exit(False);
      fProvider.Reset;
    end;
    fPlaybackRate := AEffective;
    fPlaybackRateReady := True;
    AResult := RecorderDacOk;
    Result := True;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacPersistentProvider.IsPlaying: Boolean;
begin
  EnterCriticalSection(fLock);
  try
    Result := fPlaying;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderDacPersistentProvider.SourceIdentity: QWord;
var
  lIdentity: IRecorderDacSourceIdentity;
begin
  EnterCriticalSection(fLock);
  try
    if Supports(fProvider, IRecorderDacSourceIdentity, lIdentity) then
      Result := lIdentity.SourceIdentity else Result := 0;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

end.
