program RecorderDacFeedbackTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  {$IFDEF MSWINDOWS}Windows,{$ENDIF}
  SysUtils, Classes, Math, uRecorderTags, uRecorderBlockClock, uRecorderDacTypes,
  uRecorderDacContracts, uRecorderDacProviders, uRecorderDacFeedbackCalibration;

type
  TCaptureMirror = class(TInterfacedObject, IRecorderDacMirror,
    IRecorderDacTimedMirror, IRecorderDacProvisionalMirror)
  public
    Count: Integer;
    ProvisionalCount, ReplayCount: Integer;
    Times: array[0..31] of TRecorderBlockTime;
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function WriteBlock(ABuffer: PDouble; AFrameCount: Integer;
      out AResult: TRecorderDacResult): Boolean;
    function WriteTimedBlock(ABuffer: PDouble; const ATime: TRecorderBlockTime;
      out AResult: TRecorderDacResult): Boolean;
    function WriteProvisionalTimedBlock(ABuffer: PDouble; const ATime: TRecorderBlockTime;
      out AResult: TRecorderDacResult): Boolean;
    function BeginCalibratedReplay(out AResult: TRecorderDacResult): Boolean;
  end;

  { Synthetic hardware source has its own continuous sample cursor and
    arbitrary host epoch. Delivery can be delayed without retiming samples. }
  TFixture = class
  public
    Registry: TRecorderTagRegistry;
    Tag: TRecorderTag;
    Capture: TCaptureMirror;
    Feedback: TRecorderDacFeedbackMirror;
    Mirror, KeepAlive: IRecorderDacMirror;
    Settings: TRecorderDacFeedbackSettings;
    Config: TRecorderDacConfig;
    Times, Values: TRecorderDoubleArray;
    Buffer: array[0..199] of Double;
    NominalRate, EffectiveRate, AdcRate, FirstEdge, SecondEdge: Double;
    Gain, DcOffset, NoiseAmplitude, RampSeconds, Ringing, DecayHz: Double;
    PreRinging: Boolean;
    TransientStart, TransientAmplitude, TransientDuration: Double;
    PollSeconds: Double;
    Polarity: Integer;
    SecondPolarityMultiplier: Integer;
    SecondGain: Double;
    UnrelatedShape: Boolean;
    AdcTimeOffset, AdcClockPpm, AdcJitterSamples, PhysicalLatency: Double;
    GeneratedSamples: TRecorderDoubleArray;
    ReferenceFirstPeak, ReferenceSecondPeak: Double;
    AdcIndex, DacFrames: Int64;
    Generation: QWord;
    constructor Create(ANominal, AEffective, AAdcRate: Double;
      APolarity: Integer = 1; AInterval: Double = 2; ATimeout: Double = 10);
    destructor Destroy; override;
    function Submit(out AResult: TRecorderDacResult): Boolean;
    function FeedUntil(ATime: Double; ASecondEdge: Boolean;
      out AResult: TRecorderDacResult): Boolean;
    procedure PrepareBaseline;
    function CapturedPeak(ACenter: Double; ACount: Integer): Double;
    function SampleTime(AIndex: Int64): Double;
  end;

procedure Check(ACondition: Boolean; const AText: string);
begin
  if not ACondition then raise Exception.Create(AText);
end;

function DefaultConfig: TRecorderDacConfig;
begin
  Result.SampleRateHz := 1000;
  Result.ChannelCount := 1;
  Result.FramesPerBlock := 200;
  Result.MinimumValue := -1;
  Result.MaximumValue := 1;
  Result.SafeValue := 0;
  Result.UnderrunPolicy := rdupStop;
end;

function TCaptureMirror.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
begin
  AResult := RecorderDacOk;
  Result := True;
end;

procedure TCaptureMirror.Reset;
begin
  Count := 0;
end;

function TCaptureMirror.WriteBlock(ABuffer: PDouble; AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
begin
  AResult := RecorderDacFailed(rdeInvalidConfig, rdsgWrite, 'Timed path required');
  Result := False;
end;

function TCaptureMirror.WriteTimedBlock(ABuffer: PDouble;
  const ATime: TRecorderBlockTime; out AResult: TRecorderDacResult): Boolean;
begin
  Check(Count < Length(Times), 'Capture storage overflow');
  Times[Count] := ATime;
  Inc(Count);
  AResult := RecorderDacOk;
  Result := True;
end;

constructor TFixture.Create(ANominal, AEffective, AAdcRate: Double;
  APolarity: Integer; AInterval: Double; ATimeout: Double);
var
  lResult: TRecorderDacResult;
begin
  inherited Create;
  NominalRate := ANominal;
  EffectiveRate := AEffective;
  AdcRate := AAdcRate;
  Polarity := APolarity;
  SecondPolarityMultiplier := 1;
  SecondGain := 1;
  Gain := 1;
  RampSeconds := 0.002;
  Generation := 1;
  Config := DefaultConfig;
  Config.SampleRateHz := NominalRate;
  Registry := TRecorderTagRegistry.Create;
  Tag := Registry.CreateTag('PXI feedback', 200000, True);
  Tag.PollFrequencyHz := AdcRate;
  Tag.BlockTimeDomain := btRecorderMonotonic;
  SetLength(Times, Tag.SignalBuffer.Capacity);
  SetLength(Values, Length(Times));
  Times[0] := 1000 - 1 / AdcRate;
  Values[0] := 0;
  Registry.AddBlockSamples(Tag, Times, Values, 1, True);
  Capture := TCaptureMirror.Create;
  Mirror := Capture;
  Settings := RecorderDacDefaultFeedbackSettings;
  Settings.GeneratedBellMarker := True;
  Settings.Threshold := 0.1; { Legacy value deliberately exceeds some test markers. }
  Settings.Polarity := 1; { Negative response must be detected automatically. }
  Settings.EdgeIntervalSeconds := AInterval;
  Settings.TimeoutSeconds := ATimeout;
  FirstEdge := 1000 + Round(RecorderDacCalibrationPeakOffsetSeconds(NominalRate) * NominalRate) / EffectiveRate;
  SecondEdge := FirstEdge + Round(AInterval * NominalRate) / EffectiveRate;
  Feedback := TRecorderDacFeedbackMirror.Create(Mirror, Tag, Settings);
  KeepAlive := Feedback;
  Check(Feedback.Configure(Config, lResult), lResult.Text);
  Feedback.Reset;
end;

procedure TFixture.PrepareBaseline;
var
  I, lCount: Integer;
begin
  Tag.SignalBuffer.Clear;
  lCount := Round(0.05 * AdcRate);
  for I := 0 to lCount - 1 do
  begin
    Times[I] := SampleTime(I - lCount);
    Values[I] := DcOffset + NoiseAmplitude * Sin(2 * Pi * I * 0.317);
  end;
  Registry.AddBlockSamples(Tag, Times, Values, lCount, True);
  Feedback.Reset;
  DacFrames := 0;
  AdcIndex := 0;
end;

destructor TFixture.Destroy;
begin
  KeepAlive := nil;
  Mirror := nil;
  Registry.Free;
  inherited Destroy;
end;

function TFixture.Submit(out AResult: TRecorderDacResult): Boolean;
var
  lTime: TRecorderBlockTime;
begin
  FillChar(lTime, SizeOf(lTime), 0);
  lTime.Generation := Generation;
  lTime.SampleRateHz := NominalRate;
  lTime.SampleCount := Length(Buffer);
  lTime.DeviceStartSeconds := DacFrames / NominalRate;
  lTime.RecorderStartSeconds := 3000 + lTime.DeviceStartSeconds;
  Result := Feedback.WriteTimedBlock(@Buffer[0], lTime, AResult);
  if Result then Inc(DacFrames, Length(Buffer));
end;

function PulseValue(ATime, AEdge, ARamp, ARinging: Double): Double;
begin
  if Abs(ATime - AEdge) > 0.01 then Exit(0);
  Result := 0.1 * Exp(-0.5 * Sqr((ATime - AEdge) / ARamp));
  if ATime > AEdge + 0.003 then
    Result := Result + 0.1 * ARinging * Exp(-(ATime - AEdge - 0.003) / 0.002) *
      Sin(2 * Pi * 1200 * (ATime - AEdge - 0.003));
end;

function TFixture.CapturedPeak(ACenter: Double; ACount: Integer): Double;
var
  I, lPeak: Integer;
  lBest, lValue, lLeft, lMiddle, lRight, lFraction, lDenominator: Double;
begin
  lBest := 0;
  lPeak := -1;
  for I := 1 to ACount - 2 do
    if Abs(Times[I] - ACenter) < 0.009 then
    begin
      lValue := Abs(Values[I] - DcOffset);
      if lValue > lBest then begin lBest := lValue; lPeak := I end;
    end;
  Check(lPeak >= 1, 'Reference response peak is present in delivered ADC data');
  lLeft := Abs(Values[lPeak - 1] - DcOffset);
  lMiddle := Abs(Values[lPeak] - DcOffset);
  lRight := Abs(Values[lPeak + 1] - DcOffset);
  lDenominator := lLeft - 2 * lMiddle + lRight;
  lFraction := 0;
  if lDenominator < 0 then lFraction := 0.5 * (lLeft - lRight) / lDenominator;
  Result := Times[lPeak] + lFraction / AdcRate;
end;

function TFixture.SampleTime(AIndex: Int64): Double;
begin
  Result := 1000 + AdcTimeOffset + AIndex / (AdcRate * (1 + AdcClockPpm * 1e-6)) +
    AdcJitterSamples / AdcRate * Sin(0.47 * AIndex);
end;

function TFixture.FeedUntil(ATime: Double; ASecondEdge: Boolean;
  out AResult: TRecorderDacResult): Boolean;
var
  lCount, lSourceIndex: Integer;
  lTime, lValue, lBefore, lSourcePosition, lSourceFraction: Double;
begin
  lCount := 0;
  while SampleTime(AdcIndex) <= ATime do
  begin
    Check(lCount < Length(Times), 'Synthetic delivery exceeds ring');
    lTime := SampleTime(AdcIndex);
    lValue := PulseValue(lTime, FirstEdge, RampSeconds, Ringing);
    if ASecondEdge then lValue := lValue + SecondGain * SecondPolarityMultiplier *
      PulseValue(lTime, SecondEdge, RampSeconds, Ringing);
    if UnrelatedShape then lValue := lValue * Sin(2 * Pi * 4000 * lTime);
    if DecayHz > 0 then
    begin
      if (lTime >= FirstEdge) and (lTime < FirstEdge + 0.02) then
        lValue := lValue * Exp(-2 * Pi * DecayHz * (lTime - FirstEdge));
      if ASecondEdge and (lTime >= SecondEdge) and (lTime < SecondEdge + 0.02) then
        lValue := lValue * Exp(-2 * Pi * DecayHz * (lTime - SecondEdge));
    end;
    if PreRinging then
    begin
      if (lTime >= FirstEdge - 0.0004) and (lTime < FirstEdge - RampSeconds) then
        lValue := -0.015 * Sin(Pi * (lTime - FirstEdge + 0.0004) / 0.0004);
      if ASecondEdge and (lTime >= SecondEdge - 0.0004) and
        (lTime < SecondEdge - RampSeconds) then
        lValue := -0.015 * Sin(Pi * (lTime - SecondEdge + 0.0004) / 0.0004);
    end;
    if Length(GeneratedSamples) > 0 then
    begin
      lSourcePosition := (lTime - 1000 - PhysicalLatency) * EffectiveRate;
      lSourceIndex := Floor(lSourcePosition);
      lValue := 0;
      if (lSourceIndex >= 0) and (lSourceIndex < High(GeneratedSamples)) then
      begin
        lSourceFraction := lSourcePosition - lSourceIndex;
        lValue := GeneratedSamples[lSourceIndex] + lSourceFraction *
          (GeneratedSamples[lSourceIndex + 1] - GeneratedSamples[lSourceIndex]);
      end;
    end;
    Times[lCount] := lTime;
    Values[lCount] := DcOffset + Gain * Polarity * lValue +
      NoiseAmplitude * Sin(2 * Pi * AdcIndex * 0.317);
    if (TransientDuration > 0) and (lTime >= TransientStart) and
      (lTime < TransientStart + TransientDuration) then
      Values[lCount] := Values[lCount] + TransientAmplitude *
        Sin(Pi * (lTime - TransientStart) / TransientDuration);
    Inc(lCount);
    Inc(AdcIndex);
  end;
  Registry.AddBlockSamples(Tag, Times, Values, lCount, True);
  if (lCount > 2) and (Times[0] <= FirstEdge - 0.009) and
    (Times[lCount - 1] >= FirstEdge + 0.009) then
    ReferenceFirstPeak := CapturedPeak(FirstEdge, lCount);
  if ASecondEdge and (lCount > 2) and (Times[0] <= SecondEdge - 0.009) and
    (Times[lCount - 1] >= SecondEdge + 0.009) then
    ReferenceSecondPeak := CapturedPeak(SecondEdge, lCount);
  lBefore := RecorderClockSeconds;
  Result := Feedback.Poll(AResult);
  PollSeconds := PollSeconds + RecorderClockSeconds - lBefore;
end;

procedure TestTwoEdges(ANominal, AEffective, AAdcRate: Double; APolarity: Integer);
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderDacFeedbackSnapshot;
begin
  lFixture := TFixture.Create(ANominal, AEffective, AAdcRate, APolarity);
  try
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(lFixture.FeedUntil(lFixture.FirstEdge + 0.06, True, lResult), lResult.Text);
    lSnapshot := lFixture.Feedback.Snapshot;
    Check((lSnapshot.DetectedEdges = 1) and (lSnapshot.State = rdfsWaiting),
      'First edge must not finalize offset/rate');
    Check((lSnapshot.EffectiveSampleRateHz = 0) and (lFixture.Capture.Count = 0),
      'First edge must not publish nominally timed history');
    Check(lFixture.Submit(lResult), lResult.Text);
    { The second hardware block is delivered much later in host time, but
      retains its exact ADC sample timeline. }
    Sleep(10);
    Check(lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult), lResult.Text);
    lSnapshot := lFixture.Feedback.Snapshot;
    Check((lSnapshot.State = rdfsLocked) and (lSnapshot.DetectedEdges = 2), 'Both edges lock');
    Check(not lFixture.Feedback.Pending, 'Completed trial releases wait');
    Check(Abs(lSnapshot.EffectiveSampleRateHz - AEffective) < 1e-4,
      'Measured effective DAC rate');
    Check(Abs(lSnapshot.DacStartRecorderSeconds - 1000) < 0.25 / AAdcRate,
      Format('Physical start epoch (error %.12f s)', [lSnapshot.DacStartRecorderSeconds - 1000]));
    Check(lSnapshot.HostOffsetSeconds < -1000, 'No gating by approximate host epoch');
    Check(lFixture.Capture.Count = 2, 'Pending history replayed exactly once');
    Check(Abs(lFixture.Capture.Times[0].SampleRateHz - AEffective) < 1e-4,
      'Downstream metadata uses effective rate');
    Check(Abs(lFixture.Capture.Times[1].RecorderStartSeconds -
      (lSnapshot.DacStartRecorderSeconds + 200 / lSnapshot.EffectiveSampleRateHz)) < 1e-8, 'Next block uses device frame index/effective rate');
    Check(Abs(lSnapshot.DriftPpm - (AEffective / ANominal - 1) * 1e6) < 0.2,
      'Drift ppm matches independent clock');
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(Abs(lFixture.Capture.Times[2].RecorderStartSeconds -
      (lSnapshot.DacStartRecorderSeconds + 400 / lSnapshot.EffectiveSampleRateHz)) < 1e-8, 'Future block preserves rate mapping');
    lFixture.Tag.SignalBuffer.Clear;
    Check(not lFixture.Feedback.Poll(lResult), 'ADC reset invalidates completed calibration');
  finally
    lFixture.Free;
  end;
end;

procedure TestFailureLifecycle;
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  I: Integer;
begin
  lFixture := TFixture.Create(1000, 1000, 1000, 1, 0.1, 0.5);
  try
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(lFixture.FeedUntil(lFixture.FirstEdge + 0.06, False, lResult), lResult.Text);
    Check(lFixture.Feedback.Snapshot.DetectedEdges = 1, 'First of two edges detected');
    Sleep(550);
    Check(not lFixture.Feedback.Poll(lResult), 'Missing second edge times out');
    Check((lFixture.Capture.Count = 0) and not lFixture.Feedback.Pending,
      'Timeout publishes nothing and terminates pending');
    lFixture.Tag.SignalBuffer.Clear;
    lFixture.Feedback.Reset;
    lFixture.DacFrames := 0;
    Check(lFixture.Submit(lResult), lResult.Text);
    lFixture.Feedback.Cancel;
    Check(not lFixture.Feedback.Pending, 'Cancel terminates pending');
    Check(not lFixture.Submit(lResult), 'Cancelled late block cannot publish');
    lFixture.Tag.SignalBuffer.Clear;
    lFixture.Feedback.Reset;
    lFixture.DacFrames := 0;
    lFixture.AdcIndex := 0;
    Inc(lFixture.Generation);
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult), lResult.Text);
    Check(lFixture.Feedback.Snapshot.State = rdfsLocked,
      'Restart after cancellation reacquires both edges successfully');
    lFixture.Tag.SignalBuffer.Clear;
    lFixture.Feedback.Reset;
    lFixture.DacFrames := 0;
    for I := 0 to 6 do Check(lFixture.Submit(lResult), lResult.Text);
    Check(not lFixture.Submit(lResult), 'Pending storage overflow fails explicitly');
    Check(lFixture.Capture.Count = 0, 'Overflow cannot leak uncalibrated data');
  finally
    lFixture.Free;
  end;
  lFixture := TFixture.Create(1000, 980, 1000);
  try
    Check(lFixture.Submit(lResult), lResult.Text);
    lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult);
    Check(lFixture.Feedback.Snapshot.State <> rdfsLocked,
      'Two percent clock error must be rejected');
    Check(lFixture.Capture.Count = 0, 'Invalid edge interval publishes nothing');
  finally
    lFixture.Free;
  end;
end;

procedure TestProviders;
var
  lProvider, lInner: IRecorderDacSampleProvider;
  lResult: TRecorderDacResult;
  lBuffer: array[0..399] of Double;
  lCount: Integer;
begin
  lProvider := TRecorderDacCalibrationProvider.Create(0.05, 0.1);
  Check(lProvider.Configure(DefaultConfig, lResult), lResult.Text);
  Check(lProvider.FillBlock(@lBuffer[0], 400, lCount, lResult), lResult.Text);
  Check((lBuffer[99] = 0) and (lBuffer[110] = 0.05) and
    (lBuffer[100] = 0) and (lBuffer[120] = 0) and
    (lBuffer[199] = 0) and (lBuffer[210] = 0.05) and
    (lBuffer[200] = 0) and (lBuffer[220] = 0), 'Two exact source marker boundaries');
  lInner := TRecorderDacSineProvider.Create(100, 0.2);
  lProvider := TRecorderDacFeedbackProvider.Create(lInner, 0.05, 0.1);
  Check(lProvider.Configure(DefaultConfig, lResult), lResult.Text);
  Check(lProvider.FillBlock(@lBuffer[0], 400, lCount, lResult), lResult.Text);
  Check((lBuffer[110] = 0.05) and (lBuffer[210] = 0.05) and
    (lBuffer[399] = 0), 'Two-marker prefix retains silence before original waveform');
  Check(lProvider.FillBlock(@lBuffer[0], 10, lCount, lResult), lResult.Text);
  Check(Abs(lBuffer[1]) > 0.01, 'Original provider starts after full marker prefix');
  lProvider := TRecorderDacCalibrationProvider.Create(0.05, 0.05);
  Check(not lProvider.Configure(DefaultConfig, lResult), 'Too short marker interval rejected');
end;

procedure TestAutomaticMidpoint(AGain, ADc, ANoise, ARamp, ARinging: Double;
  APolarity: Integer);
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderDacFeedbackSnapshot;
  lBoundary: Double;
begin
  lFixture := TFixture.Create(44100, 44088, 54000, APolarity);
  try
    lFixture.Gain := AGain;
    lFixture.DcOffset := ADc;
    lFixture.NoiseAmplitude := ANoise;
    lFixture.RampSeconds := ARamp;
    lFixture.Ringing := ARinging;
    lFixture.PrepareBaseline;
    Check(lFixture.Submit(lResult), lResult.Text);
    { Candidate starts in one delivery and completes in another. }
    lBoundary := lFixture.FirstEdge + 0.003;
    Check(lFixture.FeedUntil(lBoundary, True, lResult), lResult.Text);
    Check(lFixture.Feedback.Snapshot.DetectedEdges = 0, 'Wait for measured step height');
    Check(lFixture.FeedUntil(lFixture.FirstEdge + 0.06, True, lResult), lResult.Text);
    Check(lFixture.Feedback.Snapshot.DetectedEdges = 1, 'Automatic first midpoint');
    Check(lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult), lResult.Text);
    lSnapshot := lFixture.Feedback.Snapshot;
    Check(lSnapshot.State = rdfsLocked, 'Automatic two-midpoint calibration locks');
    Check(lSnapshot.DetectedPolarity = APolarity, 'Automatic response polarity');
    Check((Abs(lSnapshot.StepHeight) >= Abs(AGain) * 0.098) and
      (Abs(lSnapshot.StepHeight) <= Abs(AGain) * 0.15),
      'Dominant response height follows gain instead of a fixed physical threshold');
    Check(Abs(lSnapshot.Threshold - (ADc + AGain * APolarity * 0.05)) <
      Abs(AGain) * 0.025, 'Reported physical midpoint level includes baseline');
    Check(Abs(lSnapshot.DacStartRecorderSeconds - 1000) < 0.01,
      'Filtered bell maximum remains within the known response window');
    Check(Abs(lSnapshot.EffectiveSampleRateHz - 44088) < 5,
      'Noisy sampled bell peaks retain bounded sample-rate error');
  finally
    lFixture.Free;
  end;
end;

function TCaptureMirror.WriteProvisionalTimedBlock(ABuffer: PDouble;
  const ATime: TRecorderBlockTime; out AResult: TRecorderDacResult): Boolean;
begin
  Inc(ProvisionalCount);
  AResult := RecorderDacOk;
  Result := True;
end;

function TCaptureMirror.BeginCalibratedReplay(out AResult: TRecorderDacResult): Boolean;
begin
  Inc(ReplayCount);
  AResult := RecorderDacOk;
  Result := True;
end;

procedure TestAcCoupledLobe(ADecayHz: Double; APolarity: Integer);
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderDacFeedbackSnapshot;
  I: Integer;
  lValue, lSum, lSumSquares, lMean, lRipple: Double;
begin
  lSum := 0;
  lSumSquares := 0;
  for I := 0 to 99 do
  begin
    lValue := Exp(-2 * Pi * ADecayHz * (0.008 + I * 0.00008));
    lSum := lSum + lValue;
    lSumSquares := lSumSquares + Sqr(lValue);
  end;
  lMean := lSum / 100;
  lRipple := Sqrt(lSumSquares / 100 - Sqr(lMean));
  Check(lRipple > 0.25 * lMean,
    'AC response violates obsolete stable-plateau criterion');
  lFixture := TFixture.Create(44100, 44088, 54000, APolarity);
  try
    lFixture.DecayHz := ADecayHz;
    lFixture.PreRinging := True;
    lFixture.Ringing := 0.4;
    lFixture.DcOffset := -0.00152;
    lFixture.NoiseAmplitude := 0.00002;
    lFixture.PrepareBaseline;
    Check(lFixture.Submit(lResult), lResult.Text);
    Check((lFixture.Capture.ProvisionalCount = 1) and (lFixture.Capture.Count = 0),
      'Pending block displays provisionally before calibrated publication');
    Check(lFixture.FeedUntil(lFixture.FirstEdge + 0.06, True, lResult), lResult.Text);
    Check(lFixture.Feedback.Snapshot.DetectedEdges = 1,
      'AC-coupled decaying first lobe is accepted without a plateau');
    Check(lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult), lResult.Text);
    lSnapshot := lFixture.Feedback.Snapshot;
    Check(lSnapshot.State = rdfsLocked, 'AC-coupled ringing pair locks');
    Check((lFixture.Capture.ReplayCount = 1) and (lFixture.Capture.Count = 1),
      'One rebase precedes exactly one calibrated history replay');
    Check(lFixture.Submit(lResult), lResult.Text);
    Check((lFixture.Capture.ReplayCount = 1) and (lFixture.Capture.ProvisionalCount = 1) and
      (lFixture.Capture.Count = 2), 'Locked blocks publish directly without provisional duplication');
    Check(lSnapshot.DetectedPolarity = APolarity, 'AC-coupled inverted gain preserves polarity');
    Check(Abs(lSnapshot.CorrelationFirst) >= 0.8,
      'First filtered response has sufficient normalized shape correlation');
    Check(lSnapshot.CorrelationSecond > 0.99,
      'Second marker matches the first observed filtered response');
    Check(Abs(lSnapshot.EffectiveSampleRateHz - 44088) < 0.2,
      'Observed-template correlation cancels repeatable filter shape');
  finally
    lFixture.Free;
  end;
end;

procedure TestEarlyTransientBeforeTrueMarkers(ALeadSeconds: Double);
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderDacFeedbackSnapshot;
  lPollOk: Boolean;
begin
  lFixture := TFixture.Create(44100, 44088, 54000, 1);
  try
    lFixture.DcOffset := 0.001442;
    lFixture.NoiseAmplitude := Sqrt(2) * 0.000222;
    lFixture.DecayHz := 20;
    lFixture.Ringing := 0.4;
    { A finite rise lets the 16ms-window boundary cut through the true lobe.
      The perturbation has enough support and SNR to pass an isolated peak
      rule, but cannot form the known pair of two genuine DAC markers. }
    lFixture.RampSeconds := 0.004;
    lFixture.TransientStart := lFixture.FirstEdge - ALeadSeconds;
    lFixture.TransientDuration := 0.002;
    lFixture.TransientAmplitude := -0.0045;
    lFixture.PrepareBaseline;
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(lFixture.FeedUntil(lFixture.FirstEdge + 0.06, True, lResult), lResult.Text);
    lPollOk := lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult);
    lSnapshot := lFixture.Feedback.Snapshot;
    WriteLn(Format('Transient lead=%.6f poll=%s state=%d first=%.9f expected=%.9f polarity=%d rate=%.6f error=%s',
      [ALeadSeconds, BoolToStr(lPollOk, True), Ord(lSnapshot.State),
       lSnapshot.EdgeRecorderSeconds, lFixture.FirstEdge, lSnapshot.DetectedPolarity,
       lSnapshot.EffectiveSampleRateHz, lSnapshot.Error]));
    Check(lPollOk and (lSnapshot.State = rdfsLocked),
      'Small early noise lobe must not prevent pairing the true DAC markers');
    Check(lSnapshot.DetectedPolarity = 1,
      'True positive marker pair replaces the unrelated negative transient');
    Check(Abs(lSnapshot.EdgeRecorderSeconds - lFixture.FirstEdge) < 0.002,
      'Correlated response alignment survives transient-window boundary');
    Check(Abs(lSnapshot.EffectiveSampleRateHz - 44088) < 0.2,
      'Observed-template correlation reduces noisy-peak clock error');
  finally
    lFixture.Free;
  end;
end;

procedure TestSecondMarkerGainAndMinimumInterval(AInterval, ASecondGain: Double;
  ARamp: Double = 0.002; ADecay: Double = 20);
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderDacFeedbackSnapshot;
  lFirstDetected: Double;
begin
  lFixture := TFixture.Create(44100, 44088, 54000, 1, AInterval);
  try
    lFixture.SecondGain := ASecondGain;
    lFixture.DecayHz := ADecay;
    lFixture.RampSeconds := ARamp;
    lFixture.Ringing := 0.4;
    lFixture.NoiseAmplitude := 0.00002;
    lFixture.DcOffset := 0.001442;
    lFixture.PrepareBaseline;
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(lFixture.FeedUntil(lFixture.FirstEdge + 0.06, True, lResult), lResult.Text);
    lSnapshot := lFixture.Feedback.Snapshot;
    Check((lSnapshot.State = rdfsWaiting) and (lSnapshot.DetectedEdges = 1),
      'First ringing marker remains a separate candidate before the minimum interval');
    lFirstDetected := lSnapshot.EdgeRecorderSeconds;
    Check(lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult), lResult.Text);
    lSnapshot := lFixture.Feedback.Snapshot;
    Check((lSnapshot.State = rdfsLocked) and (lSnapshot.DetectedEdges = 2),
      'Same-polarity marker pair locks despite second gain or minimum spacing');
    Check(lSnapshot.EdgeRecorderSeconds = lFirstDetected,
      'Valid stronger second marker never replaces the first marker');
    Check(Abs(lSnapshot.CorrelationGainSecond - ASecondGain) < 0.01,
      'Observed-template least-squares fit recovers marker amplitude scaling');
    Check(lSnapshot.CorrelationSecond > 0.99,
      'Filtered second marker uses the observed template within minimum interval');
    if ARamp > 0.003 then
      Check(Abs(lFixture.ReferenceSecondPeak - lFirstDetected -
        Round(AInterval * lFixture.NominalRate) / lFixture.EffectiveRate) >
        AInterval * 0.01 + 2 / lFixture.AdcRate,
        'Filtered raw peak lies outside strict gate before NCC refinement');
    Check(Abs(lSnapshot.EffectiveSampleRateHz - 44088) < 0.5,
      'Normalized correlation preserves rate across gain/minimum interval');
    Check(lFixture.Capture.ReplayCount = 1,
      'Gain/minimum-interval pair performs one calibrated replay');
  finally
    lFixture.Free;
  end;
end;

procedure TestBellProviderIdentityAndUsbDelay;
var
  lProviders: array[0..2] of IRecorderDacSampleProvider;
  lCalibration: TRecorderDacCalibrationProvider;
  lInner: IRecorderDacSampleProvider;
  lConfig: TRecorderDacConfig;
  lResult: TRecorderDacResult;
  lValues: array[0..2, 0..4499] of Double;
  I, J, lCount, lPeakFrame: Integer;
  lFixture: TFixture;
  lSnapshot: TRecorderDacFeedbackSnapshot;
begin
  lConfig := DefaultConfig;
  lConfig.SampleRateHz := 11025;
  lPeakFrame := Round(0.1 * 11025) + Round(0.01 * 11025);
  Check(lPeakFrame <> Round(0.11 * 11025), 'Odd hardware rate distinguishes rounded peak from literal offset');
  lCalibration := TRecorderDacCalibrationProvider.Create(0.1, 0.2);
  lProviders[0] := lCalibration;
  lInner := TRecorderDacSineProvider.Create(10, 0.1);
  lProviders[1] := TRecorderDacFeedbackProvider.Create(lInner, 0.1, 0.2);
  lProviders[2] := TRecorderDacPersistentProvider.Create(lInner, 0.1, 0.6);
  for J := 0 to 2 do
  begin
    Check(lProviders[J].Configure(lConfig, lResult), lResult.Text);
    Check(lProviders[J].FillBlock(@lValues[J, 0], 4000, lCount, lResult), lResult.Text);
  end;
  Check(lCalibration.MarkerOffsetSeconds = lPeakFrame / 11025,
    'MarkerOffsetSeconds exports exact source maximum at actual hardware rate');
  for I := 0 to 3999 do
    Check((lValues[0,I] = lValues[1,I]) and (lValues[0,I] = lValues[2,I]),
      'All three providers emit identical precomputed bells');
  Check(lValues[0,lPeakFrame] = 0.1, 'Hann bell reaches exact configured amplitude on peak sample');
  Check(Abs(lValues[0,lPeakFrame - 1] - lValues[0,lPeakFrame + 1]) < 1e-15,
    'Sampled source bell is symmetric around exact peak');
  for J := 0 to 1 do
  begin
    lFixture := TFixture.Create(11025, 11022, 48000, 1 - 2 * J);
    try
      lFixture.FirstEdge := lFixture.FirstEdge + 0.25;
      lFixture.SecondEdge := lFixture.SecondEdge + 0.25;
      lFixture.TransientStart := 1000.04;
      lFixture.TransientDuration := 0.002;
      lFixture.TransientAmplitude := -0.0045;
      lFixture.PrepareBaseline;
      Check(lFixture.Submit(lResult), lResult.Text);
      Check(lFixture.FeedUntil(lFixture.FirstEdge + 0.06, True, lResult), lResult.Text);
      Check(lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult), lResult.Text);
      lSnapshot := lFixture.Feedback.Snapshot;
      Check(lSnapshot.State = rdfsLocked, 'USB-delayed bell pair locks after earlier transient');
      Check(Abs(lSnapshot.DacStartRecorderSeconds - 1000.25) < 0.25 / lFixture.AdcRate,
        'Physical 250ms USB latency moves source origin without host submission gating');
      Check(Abs(lSnapshot.EffectiveSampleRateHz - 11022) < 0.001,
        'USB latency preserves effective clock rate and odd-rate exact source peak');
    finally
      lFixture.Free;
    end;
  end;
end;

procedure TestCorrelationAndManualClock;
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  lBefore, lAfter: TRecorderDacFeedbackSnapshot;
  lProvider: IRecorderDacSampleProvider;
  lRate: IRecorderDacPlaybackRateControl;
  lConfig: TRecorderDacConfig;
  lBuffer: array[0..199] of Double;
  lCount, I: Integer;
  lEnd, lOriginalTime: Double;
begin
  lFixture := TFixture.Create(44100, 44088, 54000, -1);
  try
    lFixture.Gain := 0.13;
    lFixture.NoiseAmplitude := Sqrt(2) * 0.001;
    lFixture.DcOffset := 3;
    lFixture.PrepareBaseline;
    Check(not lFixture.Feedback.CanSetRateFactor(1, lResult), 'Pending trial rejects manual rate');
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(lFixture.FeedUntil(lFixture.FirstEdge + 0.06, True, lResult), lResult.Text);
    Check(lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult), lResult.Text);
    lBefore := lFixture.Feedback.Snapshot;
    Check(lBefore.State = rdfsLocked, 'NCC locks a DC-shifted inverted response at SNR13');
    Check((lBefore.CorrelationFirst < -0.8) and (lBefore.CorrelationSecond > 0.8),
      'Normalized correlation exposes signed inversion and repeated-shape confidence');
    Check(lBefore.CorrelationGainFirst < 0, 'Least-squares amplitude fit preserves inversion');
    lOriginalTime := lFixture.Capture.Times[0].RecorderStartSeconds;
    lEnd := lOriginalTime + 200 / lBefore.EffectiveSampleRateHz;
    Check(not lFixture.Feedback.SetRateFactorAtFrame(0.995, 201, lResult),
      'Clock transition rejects an unmatched FIFO frame boundary');
    Check(lFixture.Feedback.SetRateFactorAtFrame(0.995, 200, lResult), lResult.Text);
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(Abs(lFixture.Capture.Times[1].RecorderStartSeconds - lEnd) < 1e-10,
      'Manual factor changes rate continuously at the exact next block');
    Check(lFixture.Capture.Times[0].RecorderStartSeconds = lOriginalTime,
      'Manual factor never rewrites previously published timestamps');
    lAfter := lFixture.Feedback.Snapshot;
    Check(lAfter.ManualRate and (lAfter.EdgeRecorderSeconds = lBefore.EdgeRecorderSeconds) and
      (lAfter.DacStartRecorderSeconds = lBefore.DacStartRecorderSeconds),
      'Manual clock retains original measured source-pair anchor');
    Check(not lFixture.Feedback.SetRateFactorAtFrame(1.02, 400, lResult),
      'Out-of-range manual rate rejects without mutation');
  finally
    lFixture.Free;
  end;
  lFixture := TFixture.Create(44100, 44088, 54000);
  try
    lFixture.UnrelatedShape := True;
    lFixture.PrepareBaseline;
    Check(lFixture.Submit(lResult), lResult.Text);
    lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult);
    Check(lFixture.Feedback.Snapshot.State <> rdfsLocked,
      'Energetic unrelated waveform cannot pass normalized correlation');
  finally
    lFixture.Free;
  end;
  lProvider := TRecorderDacWaveProvider.Create(rdwmSine, 13, 0.5, 10, 20, 1);
  lConfig := DefaultConfig;
  Check(lProvider.Configure(lConfig, lResult), lResult.Text);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  Check(Supports(lProvider, IRecorderDacPlaybackRateControl, lRate), 'Wave supports phase-preserving clock updates');
  Check(lRate.SetPlaybackSampleRate(990, lResult), lResult.Text);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  for I := 0 to 199 do
    Check(Abs(lBuffer[I] - 0.5 * Sin(2 * Pi * 13 * (0.2 + I / 990))) < 1e-11,
      'Manual rate updates oscillator step without resetting phase');
  lProvider := TRecorderDacPulseProvider.Create(13, 0.5, 1, 10, 2);
  Check(lProvider.Configure(lConfig, lResult), lResult.Text);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  Check(Supports(lProvider, IRecorderDacPlaybackRateControl, lRate), 'Pulse supports phase-preserving clock updates');
  Check(lRate.SetPlaybackSampleRate(990, lResult), lResult.Text);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  for I := 0 to 199 do
    Check(Abs(lBuffer[I] - 0.5 * Sin(2 * Pi * 13 * (0.2 + I / 990))) < 1e-10,
      'Manual pulse rate update preserves elapsed burst position');
end;

procedure TestAuthoritativeNativeGrid(ASourceRate, AEffectiveRate, AAdcRate: Double);
var
  lFixture: TFixture;
  lProvider: IRecorderDacSampleProvider;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderDacFeedbackSnapshot;
  lCount: Integer;
  lFirstError, lRateError: Double;
begin
  lFixture := TFixture.Create(ASourceRate, AEffectiveRate, AAdcRate, -1);
  try
    lFixture.AdcTimeOffset := 0.37 / AAdcRate;
    lFixture.AdcClockPpm := 2000;
    lFixture.AdcJitterSamples := 0.2;
    lFixture.PhysicalLatency := 0.25000073;
    lFixture.Gain := 3;
    lFixture.DcOffset := 12;
    lFixture.FirstEdge := lFixture.FirstEdge + lFixture.PhysicalLatency;
    lFixture.SecondEdge := lFixture.SecondEdge + lFixture.PhysicalLatency;
    lProvider := TRecorderDacCalibrationProvider.Create(0.1, 2);
    Check(lProvider.Configure(lFixture.Config, lResult), lResult.Text);
    SetLength(lFixture.GeneratedSamples, Ceil(2.4 * ASourceRate));
    Check(lProvider.FillBlock(@lFixture.GeneratedSamples[0],
      Length(lFixture.GeneratedSamples), lCount, lResult), lResult.Text);
    SetLength(lFixture.GeneratedSamples, lCount);
    lFixture.PrepareBaseline;
    Check(lFixture.Submit(lResult), lResult.Text);
    { Small delayed deliveries preserve every actual nonuniform AI timestamp. }
    while lFixture.SampleTime(lFixture.AdcIndex) < lFixture.SecondEdge + 0.06 do
      Check(lFixture.FeedUntil(Min(lFixture.SecondEdge + 0.06,
        lFixture.SampleTime(lFixture.AdcIndex) + 0.075), True, lResult), lResult.Text);
    lSnapshot := lFixture.Feedback.Snapshot;
    Check(lSnapshot.State = rdfsLocked, 'Actual source table and nonuniform native ADC grid lock');
    lFirstError := lSnapshot.DacStartRecorderSeconds - (1000 + lFixture.PhysicalLatency);
    lRateError := lSnapshot.EffectiveSampleRateHz - AEffectiveRate;
    WriteLn(Format('Native actual-grid source=%.0f ADC=%.0f origin_error=%.12fs rate_error=%.9fHz rho2=%.9f',
      [ASourceRate, AAdcRate, lFirstError, lRateError, lSnapshot.CorrelationSecond]));
    Check(Abs(lFirstError) < 0.25 / AAdcRate,
      'Native correlation respects known fractional latency within quarter ADC sample');
    Check(Abs(lRateError) < 0.02,
      'Published nonuniform timestamps determine effective clock, not nominal index spacing');
    Check(lSnapshot.CorrelationSecond > 0.999,
      'Native-grid observed template retains DC/gain invariant confidence');
  finally
    lFixture.Free;
  end;
end;

procedure TestNoResponse;
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
begin
  lFixture := TFixture.Create(1000, 1000, 1000, 1, 0.1, 0.5);
  try
    lFixture.Gain := 0;
    lFixture.DcOffset := 100;
    lFixture.NoiseAmplitude := 0.001;
    lFixture.PrepareBaseline;
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult), lResult.Text);
    Check(lFixture.Feedback.Snapshot.DetectedEdges = 0, 'Noise alone cannot become a marker');
    Sleep(550);
    Check(not lFixture.Feedback.Poll(lResult), 'No response fails with timeout');
    Check(lFixture.Capture.Count = 0, 'No response never publishes nominally guessed timing');
  finally
    lFixture.Free;
  end;
end;

procedure TestOppositeSecondMarker;
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderDacFeedbackSnapshot;
begin
  lFixture := TFixture.Create(44100, 44088, 54000);
  try
    lFixture.SecondPolarityMultiplier := -1;
    Check(lFixture.Submit(lResult), lResult.Text);
    Check(lFixture.FeedUntil(lFixture.FirstEdge + 0.06, True, lResult), lResult.Text);
    Check(lFixture.Feedback.Snapshot.DetectedEdges = 1, 'Positive first marker detected');
    lFixture.FeedUntil(lFixture.SecondEdge + 0.06, True, lResult);
    lSnapshot := lFixture.Feedback.Snapshot;
    Check((lSnapshot.State <> rdfsLocked) and (lSnapshot.DetectedEdges = 1),
      'Opposite-polarity second marker cannot complete calibration');
    Check((lSnapshot.DetectedPolarity = 1) and (lSnapshot.StepHeight > 0),
      'Rejected opposite pulse cannot replace first-marker sign or height');
    Check(lFixture.Capture.Count = 0, 'Opposite second pulse publishes no guessed timing');
    Check(lFixture.Feedback.Pending,
      'Missing same-polarity second marker waits for the overall timeout');
  finally
    lFixture.Free;
  end;
end;

procedure TestPersistentPlayback;
var
  lInner, lProvider: IRecorderDacSampleProvider;
  lPersistent: TRecorderDacPersistentProvider;
  lControl: IRecorderDacPlaybackControl;
  lResult: TRecorderDacResult;
  lConfig: TRecorderDacConfig;
  lBuffer: array[0..199] of Double;
  lCount, lBlock, I: Integer;
  lEnergy: Double;
begin
  lInner := TRecorderDacSineProvider.Create(100, 0.2);
  lPersistent := TRecorderDacPersistentProvider.Create(lInner, 0.05, 5);
  lProvider := lPersistent;
  lControl := lPersistent;
  lConfig := DefaultConfig;
  Check(lProvider.Configure(lConfig, lResult), lResult.Text);
  for lBlock := 0 to 29 do
  begin
    Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
    Check(lCount = 200, 'Continuous calibration/mute provider always fills full block');
    if (lBlock = 0) or (lBlock = 23) then
      Check((lBuffer[99] = 0) and (lBuffer[110] = 0.05) and
        (lBuffer[100] = 0) and (lBuffer[120] = 0),
        'Default five-second calibration markers lie at 0.1 and 4.7 seconds');
    if lBlock >= 25 then
      for I := 0 to 199 do Check(lBuffer[I] = 0, 'After calibration output stays muted');
  end;
  Check(lControl.IsCalibrating, 'Calibration waits for measured synthesis clock after marker window');
  lControl.SetPlaying(True);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  for I := 0 to 199 do Check(lBuffer[I] = 0, 'No nominal-clock playback while measured rate is pending');
  Check(lControl.SetPlaybackSampleRate(990, lResult), lResult.Text);
  Check(not lControl.IsCalibrating, 'Measured playback clock completes preparation');
  for lBlock := 0 to 29 do
  begin
    Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
    lEnergy := 0;
    for I := 0 to 199 do lEnergy := lEnergy + Sqr(lBuffer[I]);
    Check(lEnergy > 0.1, 'Sin remains playing for more than five seconds');
  end;
  Check(lControl.IsPlaying, 'Continuous Sin must not finish at marker interval');
  lControl.SetPlaying(False);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  for I := 0 to 199 do Check(lBuffer[I] = 0, 'Stop playback keeps native session alive with zeros');
  lInner := TRecorderDacSineProvider.Create(50, 0.1);
  Check(lControl.SetProvider(lInner, lResult), lResult.Text);
  lControl.SetPlaying(True);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  Check(Abs(lBuffer[1] - 0.1 * Sin(2 * Pi * 50 / 990)) < 1e-12,
    'Prepared provider replacement affects playback without new calibration');
  lInner := TRecorderDacPulseProvider.Create(100, 0.1, 0.1, 1, 1);
  Check(lControl.SetProvider(lInner, lResult), lResult.Text);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  Check(not lControl.IsPlaying, 'Finite pulse completion mutes instead of closing session');
  lPersistent := TRecorderDacPersistentProvider.Create(lInner, 0.05, 0);
  lProvider := lPersistent;
  lControl := lPersistent;
  lControl.SetPlaying(True); { May precede worker Configure and Start.Reset. }
  Check(lProvider.Configure(lConfig, lResult), lResult.Text);
  lProvider.Reset;
  Check(lControl.IsPlaying and not lControl.IsCalibrating,
    'No-sync mode preserves Play requested before worker configuration');
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  Check(lBuffer[1] <> 0, 'No-sync mode plays immediately without a marker prefix');
  lInner := TRecorderDacSineProvider.Create(10, 0.005);
  lPersistent := TRecorderDacPersistentProvider.Create(lInner, 0.05, 0);
  lProvider := lPersistent;
  lControl := lPersistent;
  lConfig.MinimumValue := -0.01;
  lConfig.MaximumValue := 0.01;
  Check(lProvider.Configure(lConfig, lResult),
    'No-sync narrow output range must not be rejected by unused calibration amplitude');
  lControl.SetPlaying(True);
  Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  Check(Abs(lBuffer[1] - 0.005 * Sin(2 * Pi * 10 / 1000)) < 1e-12,
    'No-sync narrow-range playback follows its own signal amplitude');
end;

procedure TestEffectiveSynthesisClock;
var
  lInner, lProvider: IRecorderDacSampleProvider;
  lPersistent: TRecorderDacPersistentProvider;
  lControl: IRecorderDacPlaybackControl;
  lConfig: TRecorderDacConfig;
  lResult: TRecorderDacResult;
  lBuffer: array[0..199] of Double;
  lCount, lBlock, I: Integer;
begin
  lInner := TRecorderDacSineProvider.Create(10, 0.5);
  lPersistent := TRecorderDacPersistentProvider.Create(lInner, 0.05, 1);
  lProvider := lPersistent;
  lControl := lPersistent;
  lConfig := DefaultConfig;
  lControl.SetPlaying(True);
  Check(lProvider.Configure(lConfig, lResult), lResult.Text);
  for lBlock := 0 to 4 do
    Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
  Check(lControl.IsCalibrating, 'Keep stream alive while effective rate is unresolved');
  Check(lControl.SetPlaybackSampleRate(990, lResult), lResult.Text);
  for lBlock := 0 to 2 do
  begin
    Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
    for I := 0 to 199 do
      Check(Abs(lBuffer[I] - 0.5 * Sin(2 * Pi * 10 *
        (lBlock * 200 + I) / 990)) < 1e-11,
        'Generator must use measured 990 Hz, not native stream 1000 Hz');
    if lBlock = 0 then
      Check(lControl.SetPlaybackSampleRate(990, lResult), lResult.Text);
  end;
  Check(lConfig.SampleRateHz = 1000, 'Native DAC configuration remains nominal');
  Check(not lControl.SetPlaybackSampleRate(900, lResult), 'Implausible rate update rejected');
end;

procedure TestFullScalePersistentMarkers;
var
  lInner, lProvider: IRecorderDacSampleProvider;
  lResult: TRecorderDacResult;
  lBuffer: array[0..199] of Double;
  lCount, lBlock, I: Integer;
begin
  lInner := TRecorderDacSineProvider.Create(100, 1);
  lProvider := TRecorderDacPersistentProvider.Create(lInner, 1, 5);
  Check(lProvider.Configure(DefaultConfig, lResult), lResult.Text);
  for lBlock := 0 to 24 do
  begin
    Check(lProvider.FillBlock(@lBuffer[0], 200, lCount, lResult), lResult.Text);
    for I := 0 to 199 do
      if ((lBlock = 0) or (lBlock = 23)) and (I >= 100) and (I < 120) then
        Check(Abs(lBuffer[I] - 0.5 * (1 - Cos(2 * Pi *
          ((lBlock * 200 + I - 100) mod 100) / 20))) < 1e-12,
          'Configured full-scale markers follow the precomputed Hann bell')
      else
        Check(lBuffer[I] = 0, 'Full-scale calibration markers retain exact twenty-ms boundaries');
  end;
end;

procedure TestContinuousWave;
const
  lFrequency = 140;
  lRate = 44100;
  lFrames = 200;
var
  lProvider: IRecorderDacSampleProvider;
  lConfig: TRecorderDacConfig;
  lResult: TRecorderDacResult;
  lValues: array[0..lFrames-1] of Double;
  lBlock, I, lCount: Integer;
  lExpected, lMaxError: Double;
begin
  lProvider := TRecorderDacWaveProvider.Create(rdwmAccurateSine,
    lFrequency, 0.5, 100, 1000, 10);
  lConfig := DefaultConfig;
  lConfig.SampleRateHz := lRate;
  lConfig.FramesPerBlock := lFrames;
  Check(lProvider.Configure(lConfig, lResult), lResult.Text);
  lProvider.Reset;
  lMaxError := 0;
  for lBlock := 0 to 999 do
  begin
    Check(lProvider.FillBlock(@lValues[0], lFrames, lCount, lResult), lResult.Text);
    for I := 0 to lCount - 1 do
    begin
      lExpected := 0.5 * Sin(2 * Pi * lFrequency *
        (Int64(lBlock) * lFrames + I) / lRate);
      lMaxError := Max(lMaxError, Abs(lExpected - lValues[I]));
    end;
  end;
  Check(lMaxError < 1e-8, 'AccurateSin remains phase continuous with 200-frame blocks');
  WriteLn('WaveProvider 140Hz/Fs44100/200 frames max error=', lMaxError);
end;

function ProcessCpuSeconds: Double;
{$IFDEF MSWINDOWS}
var
  lCreation, lExit, lKernel, lUser: TFileTime;
{$ENDIF}
begin
  Result := 0;
  {$IFDEF MSWINDOWS}
  if GetProcessTimes(GetCurrentProcess, lCreation, lExit, lKernel, lUser) then
    Result := (Double(lKernel.dwHighDateTime) * 4294967296.0 + lKernel.dwLowDateTime +
      Double(lUser.dwHighDateTime) * 4294967296.0 + lUser.dwLowDateTime) * 1e-7;
  {$ENDIF}
end;

procedure TestDetectorWorkload(ALog: TStrings; AAdcRate: Double = 54000);
var
  lFixture: TFixture;
  lResult: TRecorderDacResult;
  lWallBefore, lCpuBefore, lWall, lCpu: Double;
  I: Integer;
  lText: string;
begin
  lFixture := TFixture.Create(44100, 44088, AAdcRate);
  try
    Check(lFixture.Submit(lResult), lResult.Text);
    lWallBefore := RecorderClockSeconds;
    lCpuBefore := ProcessCpuSeconds;
    for I := 1 to 100 do
      Check(lFixture.FeedUntil(1000 + I * 0.1, True, lResult), lResult.Text);
    lWall := RecorderClockSeconds - lWallBefore;
    lCpu := ProcessCpuSeconds - lCpuBefore;
    Check(lFixture.Feedback.Snapshot.State = rdfsLocked, 'Fixed detector workload locks');
    Check(lFixture.PollSeconds < 1, 'Ten seconds of ADC samples must process within one second');
    lText := Format('Synthetic 10s @%.0fHz: detector_wall=%.6fs suite_wall=%.6fs process_cpu=%.6fs',
      [AAdcRate, lFixture.PollSeconds, lWall, lCpu]);
    WriteLn(lText);
    ALog.Add(lText);
  finally
    lFixture.Free;
  end;
end;

var
  lLog: TStringList;
begin
  lLog := TStringList.Create;
  try
    try
      if ParamStr(1) = '--early-transient-only' then
        TestEarlyTransientBeforeTrueMarkers(0.06)
      else if ParamStr(1) = '--boundary-transient-only' then
        TestEarlyTransientBeforeTrueMarkers(0.015)
      else
      begin
      TestTwoEdges(44100, 44088, 54000, 1);
      TestTwoEdges(44100, 44112, 48000, -1);
      TestTwoEdges(1000, 1000, 1000, 1);
      TestFailureLifecycle;
      TestProviders;
      TestAutomaticMidpoint(0.0001, 1000, 1e-9, 0.002, 0.4, 1);
      TestAutomaticMidpoint(10000, -100, 0.001, 0.004, 0.4, -1);
      TestAcCoupledLobe(20, 1);
      TestAcCoupledLobe(50, -1);
      TestNoResponse;
      TestOppositeSecondMarker;
      TestPersistentPlayback;
      TestEffectiveSynthesisClock;
      TestFullScalePersistentMarkers;
      TestContinuousWave;
      TestDetectorWorkload(lLog);
      TestEarlyTransientBeforeTrueMarkers(0.06);
      TestEarlyTransientBeforeTrueMarkers(0.015);
      TestSecondMarkerGainAndMinimumInterval(2, 2.1);
      TestSecondMarkerGainAndMinimumInterval(0.1, 1);
      TestSecondMarkerGainAndMinimumInterval(0.1, 1, 0.004, 50);
      TestBellProviderIdentityAndUsbDelay;
      TestCorrelationAndManualClock;
      TestAuthoritativeNativeGrid(44100, 44088, 54000);
      TestAuthoritativeNativeGrid(44100, 44088, 512000);
      TestAuthoritativeNativeGrid(11025, 11022, 512000);
      TestAuthoritativeNativeGrid(1000, 1000, 1000);
      TestDetectorWorkload(lLog, 512000);
      end;
      lLog.Add('RESULT RecorderDacFeedbackTest passed');
      WriteLn(lLog[lLog.Count - 1]);
    except
      on E: Exception do
      begin
        lLog.Add('RESULT RecorderDacFeedbackTest FAILED: ' + E.Message);
        WriteLn(lLog[lLog.Count - 1]);
        ExitCode := 1;
      end;
    end;
    lLog.SaveToFile(ChangeFileExt(ParamStr(0), '.log'));
  finally
    lLog.Free;
  end;
end.
