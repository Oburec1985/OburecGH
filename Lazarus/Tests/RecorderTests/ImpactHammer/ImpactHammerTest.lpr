program ImpactHammerTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  Classes, SysUtils, Math, complex, uRecorderFrfContracts, uRecorderImpactHammer,
  uRecorderImpactDsp, uRecorderSpectrumEngine, uRecorderImpactHammerContracts,
  uRecorderImpactHammerPresenter, uRecorderImpactHammerModel,
  uRcFrfPeaks;

procedure Check(ACondition: Boolean; const AMessage: string); forward;
procedure CheckNear(AActual, AExpected: Double; const AMessage: string); forward;

procedure TestFrfThresholdPeaks;
var
  lX, lY: TRcDoubles;
  lPeaks: TRcPeaks;
  lI: Integer;
begin
  SetLength(lX, 7);
  SetLength(lY, 7);
  for lI := 0 to High(lX) do lX[lI] := lI;
  lY[0] := 0;
  lY[1] := 1.005;  { below the 1% hysteresis margin }
  lY[2] := 0;
  lY[3] := 1.02;   { completed hill }
  lY[4] := 0;
  lY[5] := 2;      { no second crossing before data ends }
  lY[6] := 2;
  FindRcPeaks(lX, lY, 1, 'hammer', lPeaks);
  Check(Length(lPeaks) = 1, 'FRF threshold must retain one completed hill');
  Check(lPeaks[0].Index = 3, 'FRF peak index');
  CheckNear(lPeaks[0].Frequency, 3, 'FRF peak frequency');
  CheckNear(lPeaks[0].Value, 1.02, 'FRF peak amplitude');

  lY[0] := 0;
  lY[1] := 1;
  lY[2] := 4;
  lY[3] := 1;
  lY[4] := 0;
  SetLength(lX, 5);
  SetLength(lY, 5);
  SetLength(lPeaks, 0);
  FindRcPeaks(lX, lY, 1, 'response', lPeaks);
  Check(Length(lPeaks) = 1, 'FRF half-width peak');
  CheckNear(lPeaks[0].Decrement, 1 / 3, 'FRF half-width decrement');
end;

function ReferenceWindow(AKind: TRecorderImpactWindowKind; AIndex,
  ACount: Integer; AForceFraction, AExponentialEnd: Double): Double;
var
  Phase, Decay: Double;
begin
  if ACount > 1 then
    Phase := 2 * Pi * AIndex / (ACount - 1)
  else
    Phase := 0;
  case AKind of
    iwkHann: Result := 0.5 - 0.5 * Cos(Phase);
    iwkHamming: Result := 0.54 - 0.46 * Cos(Phase);
    iwkForce: Result := 1;
    iwkExponential:
      begin
        Decay := -Ln(Max(1E-12, AExponentialEnd));
        Result := Exp(-Decay * AIndex / Max(1, ACount - 1));
      end;
  else
    Result := 1;
  end;
end;

procedure ReferenceDft(const AValues: array of Double; AStart, ASegment,
  AFftSize, ABin: Integer; AKind: TRecorderImpactWindowKind;
  AResponse: Boolean;
  AForceFraction, AExponentialEnd: Double; out AReal, AImaginary: Double);
var
  I: Integer;
  Angle, V, lBase: Double;
begin
  AReal := 0;
  AImaginary := 0;
  lBase := 0;
  for I := Trunc(0.9 * Length(AValues)) to High(AValues) do
    lBase := lBase + AValues[I];
  lBase := lBase / (Length(AValues) - Trunc(0.9 * Length(AValues)));
  for I := 0 to ASegment - 1 do
  begin
    V := AValues[AStart + I] - lBase;
    V := V * ReferenceWindow(AKind, I, ASegment,
      AForceFraction, AExponentialEnd);
    Angle := 2 * Pi * ABin * I / AFftSize;
    AReal := AReal + V * Cos(Angle);
    AImaginary := AImaginary - V * Sin(Angle);
  end;
end;

procedure TestAllWindowsZeroPadAndWelchGolden;
const
  Input: array[0..11] of Double = (1, -0.5, 2, 0.25, -1, 0.75,
    0.5, -0.25, 1.5, 0, -0.75, 0.125);
var
  Kind: TRecorderImpactWindowKind;
  CaseIndex, I, Bin, SegmentIndex, Hop, SegmentCount: Integer;
  SegmentSizes: array[0..2] of Integer = (12, 6, 4);
  Overlaps: array[0..2] of Integer = (0, 50, 75);
  FftSizes: array[0..2] of Integer = (16, 16, 16);
  SettingsValue: TRecorderImpactDspSettings;
  Pipeline: TRecorderImpactDspPipeline;
  Moments: TRecorderImpactSpectralMoments;
  ErrorText: string;
  Xr, Xi, Yr, Yi, Sxx, Syy, SxyR, SxyI: Double;
  Response: array[0..11] of Double;
begin
  for I := 0 to High(Input) do
    Response[I] := 1.75 * Input[I] + 0.1 * Sin(I * 0.7);
  for Kind := Low(TRecorderImpactWindowKind) to High(TRecorderImpactWindowKind) do
    for CaseIndex := 0 to High(SegmentSizes) do
    begin
      SettingsValue := Default(TRecorderImpactDspSettings);
      SettingsValue.SampleRateHz := 48;
      SettingsValue.CaptureSamples := Length(Input);
      SettingsValue.FftSize := FftSizes[CaseIndex];
      SettingsValue.WelchSegmentSamples := SegmentSizes[CaseIndex];
      SettingsValue.WelchOverlapPercent := Overlaps[CaseIndex];
      SettingsValue.ResponseCount := 1;
      SettingsValue.WindowKind := Kind;
      SettingsValue.ForceWindowFraction := 0.4;
      SettingsValue.ExponentialEndFraction := 0.08;
      SettingsValue.ExcitationUnitName := 'N';
      SettingsValue.ResponseUnitNames := ['m/s2'];
      Pipeline := TRecorderImpactDspPipeline.Create;
      try
        Check(Pipeline.Configure(SettingsValue, ErrorText), ErrorText);
        for I := 0 to High(Input) do
        begin
          Check(Pipeline.AddSample(0, Input[I]), 'golden input add');
          Check(Pipeline.AddSample(1, Response[I]), 'golden response add');
        end;
        Check(Pipeline.PrepareResponse(0, Moments), 'golden prepare');
        Hop := Max(1, SegmentSizes[CaseIndex] -
          SegmentSizes[CaseIndex] * Overlaps[CaseIndex] div 100);
        SegmentCount := 1 + (Length(Input) - SegmentSizes[CaseIndex]) div Hop;
        Check(Moments.Metadata.SegmentCount = SegmentCount,
          'golden Welch segment count');
        for Bin := 0 to High(Moments.FrequencyHz) do
        begin
          Sxx := 0; Syy := 0; SxyR := 0; SxyI := 0;
          for SegmentIndex := 0 to SegmentCount - 1 do
          begin
            ReferenceDft(Input, SegmentIndex * Hop, SegmentSizes[CaseIndex],
              FftSizes[CaseIndex], Bin, Kind, False, 0.4, 0.08, Xr, Xi);
            ReferenceDft(Response, SegmentIndex * Hop, SegmentSizes[CaseIndex],
              FftSizes[CaseIndex], Bin, Kind, True, 0.4, 0.08, Yr, Yi);
            Sxx := Sxx + Sqr(Xr) + Sqr(Xi);
            Syy := Syy + Sqr(Yr) + Sqr(Yi);
            SxyR := SxyR + Yr * Xr + Yi * Xi;
            SxyI := SxyI + Yi * Xr - Yr * Xi;
          end;
          CheckNear(Moments.ExcitationPower[Bin], Sxx / SegmentCount,
            Format('independent Sxx window=%d case=%d bin=%d',
              [Ord(Kind), CaseIndex, Bin]));
          CheckNear(Moments.ResponsePower[Bin], Syy / SegmentCount,
            'independent Syy');
          CheckNear(Moments.CrossReal[Bin], SxyR / SegmentCount,
            'independent Sxy real');
          CheckNear(Moments.CrossImaginary[Bin], SxyI / SegmentCount,
            'independent Sxy imaginary');
        end;
      finally
        Pipeline.Free;
      end;
    end;
end;

procedure TestCaptureLongerThanFft;
var
  SettingsValue: TRecorderImpactDspSettings;
  SpectrumSettings: TRecorderSpectrumSettings;
  Pipeline: TRecorderImpactDspPipeline;
  Evaluator: TRecorderSpectrumEvaluator;
  Frame: TRecorderSpectrumFrame;
  Moments: TRecorderImpactSpectralMoments;
  ErrorText: string;
  I, Bin: Integer;
  Input: array[0..19] of Double;
begin
  SettingsValue := Default(TRecorderImpactDspSettings);
  SettingsValue.SampleRateHz := 48;
  SettingsValue.CaptureSamples := 20;
  SettingsValue.FftSize := 16;
  SettingsValue.WelchSegmentSamples := 0;
  SettingsValue.WelchOverlapPercent := 75;
  SettingsValue.ResponseCount := 1;
  SettingsValue.WindowKind := iwkRectangular;
  SettingsValue.ForceWindowFraction := 1;
  SettingsValue.ExponentialEndFraction := 1;
  SettingsValue.ResponseUnitNames := ['m/s2'];
  for I := 0 to High(Input) do
    Input[I] := 0;
  Input[5] := 120;
  Input[8] := 38;
  Input[11] := -14;
  { Non-Welch processing must not mix a later capture tail into the first FFT. }
  Input[18] := 70;
  Input[19] := -70;
  Pipeline := TRecorderImpactDspPipeline.Create;
  SpectrumSettings.SetDefaults;
  SpectrumSettings.FFTSize := SettingsValue.FftSize;
  SpectrumSettings.SampleRateHz := SettingsValue.SampleRateHz;
  Evaluator := TRecorderSpectrumEvaluator.Create(SpectrumSettings);
  try
    Check(Pipeline.Configure(SettingsValue, ErrorText), ErrorText);
    for I := 0 to High(Input) do
    begin
      Check(Pipeline.AddSample(0, Input[I]), 'long capture excitation');
      Check(Pipeline.AddSample(1, 2 * Input[I]), 'long capture response');
    end;
    Check(Pipeline.PrepareResponse(0, Moments), 'long capture prepare');
    Check(Moments.Metadata.SegmentCount = 1, 'one FFT without Welch');
    Evaluator.Eval(@Input[0], Frame);
    for Bin := 0 to Frame.Bins - 1 do
    begin
      CheckNear(Sqrt(Moments.ExcitationPower[Bin]) * Sqrt(2) /
        SettingsValue.FftSize, Frame.Rms[Bin],
        Format('hammer/ordinary spectrum bin %d', [Bin]));
      CheckNear(Moments.ResponsePower[Bin],
        4 * Moments.ExcitationPower[Bin], 'long capture response power');
    end;
  finally
    Evaluator.Free;
    Pipeline.Free;
  end;
end;

procedure TestFullSizeHammerSpectrumParity;
const
  CCapture = 20160;
  CFft = 16384;
var
  SettingsValue: TRecorderImpactDspSettings;
  SpectrumSettings: TRecorderSpectrumSettings;
  Pipeline: TRecorderImpactDspPipeline;
  Evaluator: TRecorderSpectrumEvaluator;
  Frame: TRecorderSpectrumFrame;
  Moments: TRecorderImpactSpectralMoments;
  Input, Detrended: array of Double;
  ErrorText: string;
  I, Bin: Integer;
  Base, Pulse: Double;
begin
  SettingsValue := Default(TRecorderImpactDspSettings);
  SettingsValue.SampleRateHz := 57600;
  SettingsValue.CaptureSamples := CCapture;
  SettingsValue.FftSize := CFft;
  SettingsValue.ResponseCount := 1;
  SettingsValue.WindowKind := iwkForce;
  SettingsValue.ForceWindowFraction := 1;
  SettingsValue.ExponentialEndFraction := 1;
  SettingsValue.ResponseUnitNames := ['V'];
  SetLength(Input, CCapture);
  SetLength(Detrended, CFft);
  for I := 0 to CCapture - 1 do
  begin
    Pulse := 0;
    if (I >= 2880) and (I < 2920) then
      Pulse := 12000 * Sin(Pi * (I - 2880) / 40);
    Input[I] := 250 + Pulse + 0.2 * Sin(2 * Pi * 113 * I / 57600);
  end;
  Base := 0;
  for I := Trunc(0.9 * CCapture) to CCapture - 1 do
    Base := Base + Input[I];
  Base := Base / (CCapture - Trunc(0.9 * CCapture));
  for I := 0 to CFft - 1 do
    Detrended[I] := Input[I] - Base;
  Pipeline := TRecorderImpactDspPipeline.Create;
  SpectrumSettings.SetDefaults;
  SpectrumSettings.FFTSize := CFft;
  SpectrumSettings.SampleRateHz := SettingsValue.SampleRateHz;
  Evaluator := TRecorderSpectrumEvaluator.Create(SpectrumSettings);
  try
    Check(Pipeline.Configure(SettingsValue, ErrorText), ErrorText);
    for I := 0 to CCapture - 1 do
    begin
      Check(Pipeline.AddSample(0, Input[I]), 'full-size hammer add');
      Check(Pipeline.AddSample(1, 0.5 * Input[I]),
        'full-size response add');
    end;
    Check(Pipeline.PrepareResponse(0, Moments), 'full-size FFT');
    Check(Moments.Metadata.SegmentCount = 1,
      'full-size non-Welch capture uses one FFT');
    Evaluator.Eval(@Detrended[0], Frame);
    for Bin := 0 to Frame.Bins - 1 do
      CheckNear(Sqrt(Moments.ExcitationPower[Bin]) * Sqrt(2) / CFft,
        Frame.Rms[Bin], Format('full-size hammer bin %d', [Bin]));
  finally
    Evaluator.Free;
    Pipeline.Free;
  end;
end;

procedure TestImpactBaselineAndForcePosition;
var
  SettingsValue: TRecorderImpactDspSettings;
  Pipeline: TRecorderImpactDspPipeline;
  Moments: array[0..1] of TRecorderImpactSpectralMoments;
  ErrorText: string;
  Pass, I: Integer;
  lOffset: Double;
begin
  SettingsValue := Default(TRecorderImpactDspSettings);
  SettingsValue.SampleRateHz := 1000;
  SettingsValue.CaptureSamples := 32;
  SettingsValue.FftSize := 32;
  SettingsValue.ResponseCount := 1;
  SettingsValue.WindowKind := iwkForce;
  SettingsValue.ForceWindowFraction := 0.125;
  SettingsValue.ExponentialEndFraction := 0.01;
  SettingsValue.ResponseUnitNames := ['a.u.'];
  for Pass := 0 to 1 do
  begin
    Pipeline := TRecorderImpactDspPipeline.Create;
    try
      Check(Pipeline.Configure(SettingsValue, ErrorText), ErrorText);
      lOffset := Pass * 250;
      for I := 0 to 31 do
      begin
        Check(Pipeline.AddSample(0, lOffset + Ord(I = 8)),
          'offset force add');
        Check(Pipeline.AddSample(1, lOffset + Ord(I = 8) + Ord(I = 12)),
          'offset response add');
      end;
      Check(Pipeline.PrepareResponse(0, Moments[Pass]),
        'offset force prepare');
    finally
      Pipeline.Free;
    end;
  end;
  Check(Moments[0].ExcitationPower[1] > 0,
    'force window excluded the impact at trigger sample');
  Check(Moments[0].ResponsePower[0] > 0.15,
    'response tail was clipped by force window');
  for I := 0 to High(Moments[0].FrequencyHz) do
  begin
    CheckNear(Moments[0].ExcitationPower[I],
      Moments[1].ExcitationPower[I], 'excitation ignores DC offset');
    CheckNear(Moments[0].ResponsePower[I],
      Moments[1].ResponsePower[I], 'response ignores DC offset');
  end;
end;

procedure TestLegacyEstimatorMigration;
var
  Model: TRecorderImpactHammerComponent;
  Values: TStringList;
  ResponseBinding: TImpactResponseBinding;
  ErrorText: string;
begin
  Model := TRecorderImpactHammerComponent.Create;
  Values := TStringList.Create;
  try
    Model.HammerTagId := 1;
    ResponseBinding := Model.AddResponse;
    ResponseBinding.TagId := 2;
    ResponseBinding.CurveId := 10;
    Model.SaveToStrings(Values, 'Impact.');
    Values.Values['Impact.Version'] := '';
    Values.Values['Impact.Estimator'] := '0';
    Check(Model.LoadFromStrings(Values, 'Impact.', ErrorText), ErrorText);
    Check(Model.Estimator = ifeH1, 'unversioned estimator migration');
    Values.Values['Impact.Version'] := '1';
    Values.Values['Impact.Estimator'] := '1';
    Check(Model.LoadFromStrings(Values, 'Impact.', ErrorText), ErrorText);
    Check(Model.Estimator = ifeH2, 'v1 estimator migration');
  finally
    Values.Free;
    Model.Free;
  end;
end;

procedure TestSteadyStateIngestAllocations;
var
  Pipeline: TRecorderImpactDspPipeline;
  SettingsValue: TRecorderImpactDspSettings;
  ErrorText: string;
  Cycle, I: Integer;
  HeapBefore, HeapAfter: THeapStatus;
begin
  SettingsValue := Default(TRecorderImpactDspSettings);
  SettingsValue.SampleRateHz := 1024;
  SettingsValue.CaptureSamples := 64;
  SettingsValue.FftSize := 64;
  SettingsValue.WelchSegmentSamples := 64;
  SettingsValue.ResponseCount := 1;
  SettingsValue.WindowKind := iwkHann;
  SettingsValue.ForceWindowFraction := 0.25;
  SettingsValue.ExponentialEndFraction := 0.1;
  SettingsValue.ExcitationUnitName := 'N';
  SettingsValue.ResponseUnitNames := ['m/s2'];
  Pipeline := TRecorderImpactDspPipeline.Create;
  try
    Check(Pipeline.Configure(SettingsValue, ErrorText), ErrorText);
    { Warm up the memory manager and branch paths before measuring. }
    Pipeline.ResetCapture;
    for I := 0 to 63 do
    begin
      Check(Pipeline.AddSample(0, I), 'allocation warmup excitation');
      Check(Pipeline.AddSample(1, I * 2), 'allocation warmup response');
    end;
    HeapBefore := GetHeapStatus;
    for Cycle := 1 to 1000 do
    begin
      Pipeline.ResetCapture;
      for I := 0 to 63 do
      begin
        Check(Pipeline.AddSample(0, I + Cycle), 'steady excitation');
        Check(Pipeline.AddSample(1, I - Cycle), 'steady response');
      end;
    end;
    HeapAfter := GetHeapStatus;
    Check(HeapAfter.TotalAllocated = HeapBefore.TotalAllocated,
      Format('steady ingest heap changed: %d -> %d',
        [HeapBefore.TotalAllocated, HeapAfter.TotalAllocated]));
  finally
    Pipeline.Free;
  end;
end;

procedure TestPresentation;
var
  lPresenter: TRecorderImpactHammerPresenter;
  lSnapshot: TRecorderImpactHammerSnapshot;
  lFrame: TRecorderImpactPresentationFrame;
  lAxis: TImpactResultAxisState;
begin
  lSnapshot := Default(TRecorderImpactHammerSnapshot);
  lSnapshot.Results[irtFrfMagnitude].XUnitName := 'Hz';
  SetLength(lSnapshot.Results[irtFrfMagnitude].Curves, 2);
  lSnapshot.Results[irtFrfMagnitude].Curves[0].Name := 'shown';
  lSnapshot.Results[irtFrfMagnitude].Curves[0].Visible := True;
  lSnapshot.Results[irtFrfMagnitude].Curves[0].X := [10.0, 20.0];
  lSnapshot.Results[irtFrfMagnitude].Curves[0].Y := [2.0, 6.0];
  lSnapshot.Results[irtFrfMagnitude].Curves[1].Name := 'hidden';
  lSnapshot.Results[irtFrfMagnitude].Curves[1].Visible := False;
  lSnapshot.Cursor.FrequencyHz := 15;
  lSnapshot.Cursor.FrequencyHz2 := 17.5;
  lSnapshot.Cursor.HasSecond := True;
  lAxis := Default(TImpactResultAxisState);
  lAxis.AutoScale := True;
  lPresenter := TRecorderImpactHammerPresenter.Create;
  try
    lPresenter.Configure(irtFrfMagnitude, lAxis);
    Check(lPresenter.Build(lSnapshot, lFrame), 'presentation frame missing');
    Check(Length(lFrame.Curves) = 1, 'hidden curve was presented');
    Check(lFrame.Curves[0].Name = 'shown', 'wrong presented curve');
    CheckNear(lFrame.Cursor.Values[0], 4.0, 'cursor interpolation');
    CheckNear(lFrame.Cursor.Values2[0], 5.0, 'second cursor interpolation');
    Check(lFrame.XUnitName = 'Hz', 'presentation unit lost');
  finally
    lPresenter.Free;
  end;
end;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure CheckNear(AActual, AExpected: Double; const AMessage: string);
begin
  if Abs(AActual - AExpected) > 1E-8 then
    raise Exception.CreateFmt('%s: expected %.8f, got %.8f',
      [AMessage, AExpected, AActual]);
end;

function Settings: TRecorderImpactSettings;
begin
  Result.SampleRateHz := 1000;
  Result.Threshold := 5;
  Result.Hysteresis := 1;
  Result.PretriggerSeconds := 0.02;
  Result.CaptureSeconds := 0.1;
  Result.Capacity := 2;
  Result.ResponseCount := 1;
  Result.Polarity := ipPositive;
  Result.Estimator := fekH1;
end;

procedure TestValidationAndLifecycle;
var
  lRuntime: TRecorderImpactRuntime;
  lSettings: TRecorderImpactSettings;
  lError: string;
begin
  lRuntime := TRecorderImpactRuntime.Create;
  try
    lSettings := Settings;
    lSettings.Hysteresis := lSettings.Threshold;
    Check(not lRuntime.Configure(lSettings, lError), 'invalid settings accepted');
    Check(lRuntime.State = isIdle, 'failed configure changed lifecycle');
    lSettings := Settings;
    Check(lRuntime.Configure(lSettings, lError), lError);
    Check(lRuntime.State = isStopped, 'configure did not stop runtime');
    Check(lRuntime.Arm, 'configured runtime did not arm');
    Check(lRuntime.State = isArmed, 'arm state missing');
    lRuntime.Stop;
    Check(lRuntime.State = isStopped, 'stop state missing');
  finally
    lRuntime.Free;
  end;
end;

procedure TestTriggerPolarityAndHysteresis;
var
  lTrigger: TRecorderImpactTrigger;
  lSettings: TRecorderImpactSettings;
  lEvent: TRecorderImpactTriggerEvent;
begin
  lTrigger := TRecorderImpactTrigger.Create;
  try
    lSettings := Settings;
    lTrigger.Configure(lSettings);
    Check(not lTrigger.ProcessSample(1.0, 5.5, lEvent), 'trigger fired on rise');
    Check(not lTrigger.ProcessSample(1.01, 8.0, lEvent), 'trigger fired at peak');
    Check(lTrigger.ProcessSample(1.02, 3.5, lEvent), 'trigger event missing');
    CheckNear(lEvent.PeakTimeSeconds, 1.01, 'peak time');
    CheckNear(lEvent.PeakValue, 8.0, 'peak value');
    CheckNear(lEvent.CaptureStartSeconds, 0.99, 'pretrigger start');
    CheckNear(lEvent.CaptureEndSeconds, 1.09, 'capture end');
    lSettings.Polarity := ipNegative;
    lTrigger.Configure(lSettings);
    Check(not lTrigger.ProcessSample(2.0, -6.0, lEvent), 'negative rise fired early');
    Check(lTrigger.ProcessSample(2.01, -3.0, lEvent), 'negative trigger missing');
    CheckNear(lEvent.PeakValue, -6.0, 'negative peak');
    lSettings.Polarity := ipAbsolute;
    lTrigger.Configure(lSettings);
    Check(not lTrigger.ProcessSample(3.0, -7.0, lEvent), 'absolute rise fired early');
    Check(lTrigger.ProcessSample(3.01, -3.0, lEvent), 'absolute trigger missing');
    CheckNear(lEvent.PeakValue, -7.0, 'absolute peak retained wrong sign');
  finally
    lTrigger.Free;
  end;
end;

procedure TestBoundedAcceptedRejectedSet;
var
  lSet: TRecorderImpactSet;
begin
  lSet := TRecorderImpactSet.Create;
  try
    lSet.Configure(2);
    lSet.Add(1, 5, True, irrNone, nil);
    lSet.Add(2, 6, False, irrOverload, nil);
    lSet.Add(3, 7, True, irrNone, nil);
    Check(lSet.Count = 2, 'bounded set count');
    Check(lSet.Item(0).Sequence = 2, 'oldest impact was not evicted');
    Check(not lSet.Item(0).Accepted, 'rejected impact lost');
    Check(lSet.Item(0).RejectReason = irrOverload, 'reject reason lost');
    Check(lSet.Item(1).Sequence = 3, 'newest impact missing');
  finally
    lSet.Free;
  end;
end;

function ComplexValue(AReal, AImaginary: Double): TComplex_d;
begin
  Result.Re := AReal;
  Result.Im := AImaginary;
end;

function EmptyCapture(AToken: QWord): TRecorderImpactCaptureBlock;
var
  lExcitation: TRecorderSampleSeries;
  lResponses: array of TRecorderSampleSeries;
begin
  SetLength(lExcitation, 0);
  SetLength(lResponses, 0);
  Result := TRecorderImpactCaptureBlock.Create(AToken, 0, 1,
    lExcitation, lResponses);
end;

procedure TestRingCaptureAssociation;
var
  lSet: TRecorderImpactSet;
begin
  lSet := TRecorderImpactSet.Create;
  try
    lSet.Configure(2);
    lSet.Add(1, 1, True, irrNone, EmptyCapture(11));
    lSet.Add(2, 2, True, irrNone, EmptyCapture(12));
    lSet.Add(3, 3, True, irrNone, EmptyCapture(13));
    Check(lSet.Item(0).Sequence = 2, 'ring sequence after overwrite');
    Check(lSet.Capture(0).Token = 12, 'ring capture association shifted');
    Check(lSet.Capture(1).Token = 13, 'ring newest capture association');
    Check(lSet.SetHidden(2, True) and lSet.Item(0).Hidden, 'hide hook');
    Check(lSet.MarkForRecompute(2) and lSet.Item(0).RecomputeRequired,
      'recompute hook');
    Check(lSet.Delete(2) and (lSet.Count = 1), 'delete hook');
    Check(lSet.Capture(0).Token = 13, 'capture association after delete');
  finally
    lSet.Free;
  end;
end;

procedure TestGoldenEstimators;
var
  lEstimator: IRecorderFrfEstimator;
  lSpectra: array[0..1] of TRecorderImpactSpectrum;
  lEstimate: TRecorderFrfEstimate;
  lIndex: Integer;
begin
  for lIndex := 0 to 1 do
  begin
    SetLength(lSpectra[lIndex].FrequencyHz, 1);
    SetLength(lSpectra[lIndex].Excitation, 1);
    SetLength(lSpectra[lIndex].Response, 1);
    lSpectra[lIndex].FrequencyHz[0] := 10;
    lSpectra[lIndex].Excitation[0] := ComplexValue(2, 0);
    lSpectra[lIndex].Response[0] := ComplexValue(0, 6);
  end;
  lEstimator := TRecorderCrossSpectrumEstimator.Create;
  Check(lEstimator.Estimate(lSpectra, fekH0, lEstimate), 'H0 failed');
  CheckNear(lEstimate.Magnitude[0], 3, 'H0 magnitude');
  CheckNear(lEstimate.PhaseRadians[0], Pi / 2, 'H0 phase');
  CheckNear(lEstimate.Coherence[0], 1, 'coherence');
  Check(lEstimator.Estimate(lSpectra, fekH1, lEstimate), 'H1 failed');
  CheckNear(lEstimate.Magnitude[0], 3, 'H1 magnitude');
  Check(lEstimator.Estimate(lSpectra, fekH2, lEstimate), 'H2 failed');
  CheckNear(lEstimate.Magnitude[0], 3, 'H2 magnitude');
end;

procedure TestDiscriminatingEstimators;
var
  lEstimator: IRecorderFrfEstimator;
  lSpectra: array[0..1] of TRecorderImpactSpectrum;
  lEstimate: TRecorderFrfEstimate;
begin
  lSpectra[0].FrequencyHz := [10.0];
  lSpectra[0].Excitation := [ComplexValue(1, 0)];
  lSpectra[0].Response := [ComplexValue(2, 0)];
  lSpectra[1].FrequencyHz := [10.0];
  lSpectra[1].Excitation := [ComplexValue(2, 0)];
  lSpectra[1].Response := [ComplexValue(0, 2)];
  lEstimator := TRecorderCrossSpectrumEstimator.Create;
  Check(lEstimator.Estimate(lSpectra, fekH0, lEstimate), 'H0 estimate');
  CheckNear(lEstimate.Magnitude[0], 1.5, 'legacy H0 magnitude');
  CheckNear(lEstimate.PhaseRadians[0], ArcTan2(4, 2), 'H0 aggregate phase');
  CheckNear(lEstimate.Coherence[0], 0.5, 'H0 coherence');
  Check(lEstimator.Estimate(lSpectra, fekH1, lEstimate), 'H1 estimate');
  CheckNear(lEstimate.Magnitude[0], Sqrt(20) / 5, 'H1 magnitude');
  CheckNear(lEstimate.PhaseRadians[0], ArcTan2(4, 2), 'H1 phase');
  Check(lEstimator.Estimate(lSpectra, fekH2, lEstimate), 'H2 estimate');
  CheckNear(lEstimate.Magnitude[0], 8 / Sqrt(20), 'H2 magnitude');
  CheckNear(lEstimate.PhaseRadians[0], ArcTan2(4, 2), 'H2 phase');
  lSpectra[1].Excitation[0] := ComplexValue(0, 0);
  Check(not lEstimator.Estimate(lSpectra, fekH0, lEstimate),
    'zero excitation denominator accepted');
  lSpectra[1].Excitation[0] := ComplexValue(NaN, 0);
  Check(not lEstimator.Estimate(lSpectra, fekH1, lEstimate),
    'NaN complex bin accepted');
  lSpectra[1].Excitation[0] := ComplexValue(2, 0);
  lSpectra[1].Response[0] := ComplexValue(Infinity, 0);
  Check(not lEstimator.Estimate(lSpectra, fekH2, lEstimate),
    'infinite complex bin accepted');
  lSpectra[1].Response[0] := ComplexValue(0, 2);
  lSpectra[1].Excitation[0] := ComplexValue(1E-20, 0);
  Check(not lEstimator.Estimate(lSpectra, fekH0, lEstimate),
    'scale-near-zero excitation accepted');
  lSpectra[0].Excitation[0] := ComplexValue(1, 0);
  lSpectra[0].Response[0] := ComplexValue(-1, 1);
  lSpectra[1].Excitation[0] := ComplexValue(2, 0);
  lSpectra[1].Response[0] := ComplexValue(-2, 2);
  Check(lEstimator.Estimate(lSpectra, fekH1, lEstimate),
    'quadrant estimate failed');
  CheckNear(lEstimate.PhaseRadians[0], 3 * Pi / 4, 'phase quadrant');
end;

procedure TestCaptureCompletionAndToken;
var
  lRuntime: TRecorderImpactRuntime;
  lSettings: TRecorderImpactSettings;
  lError: string;
  lEvent: TRecorderImpactTriggerEvent;
  lSequence: QWord;
  lToken: QWord;
  lStartSeconds, lEndSeconds: Double;
  lBlock: TRecorderImpactCaptureBlock;
begin
  lRuntime := TRecorderImpactRuntime.Create;
  try
    lSettings := Settings;
    lSettings.ResponseCount := 2;
    Check(lRuntime.Configure(lSettings, lError), lError);
    Check(lRuntime.Arm, 'capture runtime did not arm');
    Check(not lRuntime.ProcessTriggerSample(1.0, 7, lEvent), 'rise fired');
    Check(lRuntime.ProcessTriggerSample(1.01, 3, lEvent), 'fall missing');
    Check(lEvent.CaptureToken <> 0, 'capture token missing');
    lToken := lEvent.CaptureToken;
    lStartSeconds := lEvent.CaptureStartSeconds;
    lEndSeconds := lEvent.CaptureEndSeconds;
    Check(lRuntime.RecordImpact(lToken, True, irrNone) = 0,
      'incomplete capture recorded');
    Check(not lRuntime.AddExcitationSample(lToken + 1,
      lStartSeconds, 1), 'foreign token accepted');
    Check(lRuntime.AddExcitationSample(lToken,
      lStartSeconds, 1), 'pretrigger boundary rejected');
    Check(lRuntime.AddExcitationSample(lToken,
      lEndSeconds, 2), 'excitation end rejected');
    Check(lRuntime.AddResponseSample(lToken, 0,
      lStartSeconds, 3), 'response zero start rejected');
    Check(lRuntime.AddResponseSample(lToken, 0,
      lEndSeconds, 4), 'response zero end rejected');
    Check(lRuntime.AddResponseSample(lToken, 1,
      lStartSeconds, 5), 'late response start rejected');
    Check(not lRuntime.ProcessTriggerSample(1.02, 8, lEvent),
      'capturing runtime accepted another trigger');
    Check(not lRuntime.CaptureReady(lToken),
      'unequal response arrival reported ready');
    Check(lRuntime.AddResponseSample(lToken, 1,
      lEndSeconds, 6), 'late response end rejected');
    Check(lRuntime.CaptureReady(lToken), 'complete capture not ready');
    lSequence := lRuntime.RecordImpact(lToken, True, irrNone);
    Check(lSequence <> 0, 'complete capture not recorded');
    lBlock := lRuntime.Impacts.Capture(0);
    Check((lBlock <> nil) and (lBlock.Token = lToken),
      'capture association lost');
    Check(lBlock.ResponseCount = 2, 'response count lost');
    Check(not lRuntime.AddExcitationSample(lBlock.Token, 2, 7),
      'completed capture token remained active');
  finally
    lRuntime.Free;
  end;
end;

procedure TestDspPipelineGoldenAndPreallocation;
var
  lPipeline: TRecorderImpactDspPipeline;
  lSettings: TRecorderImpactDspSettings;
  lMoments: TRecorderImpactSpectralMoments;
  lEstimate: TRecorderFrfEstimate;
  lImpactMoments: array[0..0] of TRecorderImpactSpectralMoments;
  lError: string;
  lIndex: Integer;
  lBeforeX, lBeforeY: PtrUInt;
  lExcitation: Double;
begin
  lPipeline := TRecorderImpactDspPipeline.Create;
  try
    lSettings := Default(TRecorderImpactDspSettings);
    lSettings.SampleRateHz := 8;
    lSettings.CaptureSamples := 8;
    lSettings.FftSize := 8;
    lSettings.WelchSegmentSamples := 4;
    lSettings.WelchOverlapPercent := 50;
    lSettings.ResponseCount := 1;
    lSettings.WindowKind := iwkRectangular;
    lSettings.ForceWindowFraction := 0.25;
    lSettings.ExponentialEndFraction := 0.1;
    lSettings.ExcitationUnitName := 'N';
    lSettings.ResponseUnitNames := ['m/s2'];
    Check(lPipeline.Configure(lSettings, lError), lError);
    lBeforeX := lPipeline.BufferIdentity(0);
    lBeforeY := lPipeline.BufferIdentity(1);
    for lIndex := 0 to 7 do
    begin
      lExcitation := 0;
      if lIndex = 0 then
        lExcitation := 1;
      Check(lPipeline.AddSample(0, lExcitation), 'DSP excitation add');
      Check(lPipeline.AddSample(1, 2 * lExcitation), 'DSP response add');
    end;
    Check(lPipeline.BufferIdentity(0) = lBeforeX,
      'AddSample reallocated excitation buffer');
    Check(lPipeline.BufferIdentity(1) = lBeforeY,
      'AddSample reallocated response buffer');
    Check(lPipeline.Ready, 'DSP capture not ready');
    Check(lPipeline.PrepareResponse(0, lMoments), 'DSP prepare failed');
    Check(lMoments.Metadata.SegmentCount = 3, 'Welch segment count');
    CheckNear(lMoments.Metadata.FrequencyStepHz, 1, 'frequency grid step');
    Check(lMoments.Metadata.TransferUnitName = 'm/s2/N', 'transfer unit');
    for lIndex := 0 to High(lMoments.FrequencyHz) do
    begin
      CheckNear(lMoments.ResponsePower[lIndex],
        4 * lMoments.ExcitationPower[lIndex], 'response power ratio');
      CheckNear(lMoments.CrossReal[lIndex],
        2 * lMoments.ExcitationPower[lIndex], 'cross spectrum ratio');
      CheckNear(lMoments.CrossImaginary[lIndex], 0, 'cross spectrum phase');
    end;
    lImpactMoments[0] := lMoments;
    Check(EstimateImpactMoments(lImpactMoments, fekH1, lEstimate),
      'prepared-moment H1 estimate');
    for lIndex := 0 to High(lEstimate.FrequencyHz) do
    begin
      if lMoments.ExcitationPower[lIndex] > 1E-12 then
      begin
        CheckNear(lEstimate.Magnitude[lIndex], 2, 'prepared H1 magnitude');
        CheckNear(lEstimate.Coherence[lIndex], 1, 'prepared coherence');
      end;
    end;
  finally
    lPipeline.Free;
  end;
end;

procedure TestHighRateCaptureRemainsBoundedAndCompletes;
var
  Capture: TRecorderImpactCapture;
  Block: TRecorderImpactCaptureBlock;
  CopyCountBeforeFreeze: QWord;
  ResizeCountBeforeBegin: QWord;
  I: Integer;
begin
  Capture := TRecorderImpactCapture.Create;
  try
    Capture.PrepareBuffers(1, 4);
    Capture.BeginCapture(17, 0, 1, 1, 4);
    for I := 0 to 100 do
    begin
      Check(Capture.AddExcitation(I / 100, I),
        'high-rate excitation sample rejected');
      Check(Capture.AddResponse(0, I / 100, I * 2),
        'high-rate response sample rejected');
    end;
    Check(Capture.IsReady,
      'bounded high-rate capture did not retain its end boundary');
    CopyCountBeforeFreeze := RecorderImpactFreezePayloadCopyCount;
    Block := Capture.Freeze;
    try
      Check((Block <> nil) and (Block.Token = 17),
        'bounded high-rate capture did not freeze');
      Check(RecorderImpactFreezePayloadCopyCount = CopyCountBeforeFreeze,
        'Freeze copied sample payload instead of transferring ownership');
      Capture.PrepareSpareBuffers(1, 4);
      ResizeCountBeforeBegin := RecorderImpactCaptureResizeCount;
      Capture.BeginCapture(18, 2, 3, 1, 4);
      Check(RecorderImpactCaptureResizeCount = ResizeCountBeforeBegin,
        'next BeginCapture resized payload buffers in acquisition path');
    finally
      Block.Free;
    end;
  finally
    Capture.Free;
  end;
end;

procedure TestNoPartialPublish;
var
  lRuntime: TRecorderImpactRuntime;
  lEstimate, lInvalid: TRecorderFrfEstimate;
  lSettings: TRecorderImpactSettings;
  lError: string;
  lBefore: IRecorderFrfSampler;
  lMagnitude, lPhase: Double;
begin
  lRuntime := TRecorderImpactRuntime.Create;
  try
    lSettings := Settings;
    Check(lRuntime.Configure(lSettings, lError), lError);
    SetLength(lEstimate.FrequencyHz, 2);
    SetLength(lEstimate.Magnitude, 2);
    SetLength(lEstimate.PhaseRadians, 2);
    SetLength(lEstimate.Coherence, 2);
    lEstimate.FrequencyHz[0] := 10;
    lEstimate.FrequencyHz[1] := 20;
    lEstimate.Magnitude[0] := 2;
    lEstimate.Magnitude[1] := 4;
    lEstimate.PhaseRadians[0] := 0;
    lEstimate.PhaseRadians[1] := Pi;
    Check(lRuntime.Publish(7, lEstimate), 'valid publish failed');
    lBefore := lRuntime.Provider.AcquireSnapshot;
    SetLength(lInvalid.FrequencyHz, 1);
    Check(not lRuntime.Publish(7, lInvalid), 'invalid publish accepted');
    Check(lRuntime.Provider.AcquireSnapshot = lBefore,
      'failed publish replaced snapshot');
    Check(lBefore.TrySample(7, 15, lMagnitude, lPhase), 'snapshot sample failed');
    CheckNear(lMagnitude, 3, 'snapshot interpolation');
  finally
    lRuntime.Free;
  end;
end;

procedure TestTimestampResamplingPhaseGolden;
const
  CCount = 64;
  CTargetRate = 64.0;
  CExcitationRate = 1001.0;
  CResponseRate = 833.0;
  CFrequency = 5.0;
  CPhase = 0.45;
var
  ExcitationSeries: TRecorderSampleSeries;
  ResponseSeries: TRecorderSampleSeries;
  Excitation: array of Double;
  Response: array of Double;
  SettingsValue: TRecorderImpactDspSettings;
  Pipeline: TRecorderImpactDspPipeline;
  Moments: TRecorderImpactSpectralMoments;
  Estimate: TRecorderFrfEstimate;
  ImpactMoments: array[0..0] of TRecorderImpactSpectralMoments;
  ErrorText: string;
  I: Integer;
  TimeValue: Double;
  XReal, XImaginary: Double;
  YReal, YImaginary: Double;
  CrossReal, CrossImaginary: Double;
  XPower: Double;
  AnalyticMagnitude, AnalyticPhase: Double;
begin
  SetLength(ExcitationSeries, 1020);
  for I := 0 to High(ExcitationSeries) do
  begin
    TimeValue := I / CExcitationRate + 0.00007 * Sin(I * 0.73);
    ExcitationSeries[I].TimeSeconds := TimeValue;
    ExcitationSeries[I].Value := Sin(2 * Pi * CFrequency * TimeValue);
  end;
  SetLength(ResponseSeries, 850);
  for I := 0 to High(ResponseSeries) do
  begin
    TimeValue := I / CResponseRate + 0.00009 * Sin(I * 0.51 + 0.2);
    ResponseSeries[I].TimeSeconds := TimeValue;
    ResponseSeries[I].Value := 2 * Sin(2 * Pi * CFrequency * TimeValue + CPhase);
  end;
  SetLength(Excitation, CCount);
  SetLength(Response, CCount);
  Check(ResampleImpactSeries(ExcitationSeries, 0.01, CTargetRate,
    CCount, Excitation), 'jittered excitation resampling');
  Check(ResampleImpactSeries(ResponseSeries, 0.01, CTargetRate,
    CCount, Response), 'jittered response resampling');
  XReal := 0;
  XImaginary := 0;
  YReal := 0;
  YImaginary := 0;
  for I := 0 to CCount - 1 do
  begin
    TimeValue := 2 * Pi * CFrequency * I / CTargetRate;
    XReal := XReal + Excitation[I] * Cos(TimeValue);
    XImaginary := XImaginary - Excitation[I] * Sin(TimeValue);
    YReal := YReal + Response[I] * Cos(TimeValue);
    YImaginary := YImaginary - Response[I] * Sin(TimeValue);
  end;
  CrossReal := YReal * XReal + YImaginary * XImaginary;
  CrossImaginary := YImaginary * XReal - YReal * XImaginary;
  XPower := Sqr(XReal) + Sqr(XImaginary);
  AnalyticMagnitude := Sqrt(Sqr(CrossReal) + Sqr(CrossImaginary)) / XPower;
  AnalyticPhase := ArcTan2(CrossImaginary, CrossReal);
  Check(Abs(AnalyticMagnitude - 2) < 0.01,
    Format('resampled analytic magnitude: %.8f', [AnalyticMagnitude]));
  Check(Abs(AnalyticPhase - CPhase) < 0.01,
    Format('resampled analytic phase: %.8f', [AnalyticPhase]));
  SettingsValue := Default(TRecorderImpactDspSettings);
  SettingsValue.SampleRateHz := CTargetRate;
  SettingsValue.CaptureSamples := CCount;
  SettingsValue.FftSize := CCount;
  SettingsValue.WelchSegmentSamples := CCount;
  SettingsValue.ResponseCount := 1;
  SettingsValue.ExcitationUnitName := 'N';
  SettingsValue.ResponseUnitNames := ['m/s2'];
  SettingsValue.WindowKind := iwkRectangular;
  SettingsValue.ForceWindowFraction := 1;
  SettingsValue.ExponentialEndFraction := 0.01;
  Pipeline := TRecorderImpactDspPipeline.Create;
  try
    Check(Pipeline.Configure(SettingsValue, ErrorText), ErrorText);
    for I := 0 to CCount - 1 do
    begin
      Check(Pipeline.AddSample(0, Excitation[I]), 'resampled excitation add');
      Check(Pipeline.AddSample(1, Response[I]), 'resampled response add');
    end;
    Check(Pipeline.PrepareResponse(0, Moments), 'resampled moments');
    ImpactMoments[0] := Moments;
    Check(EstimateImpactMoments(ImpactMoments, fekH1, Estimate),
      'resampled phase estimate');
    Check(not IsNan(Estimate.PhaseRadians[5]) and
      not IsInfinite(Estimate.PhaseRadians[5]),
      'DSP phase is not finite after timestamp resampling');
  finally
    Pipeline.Free;
  end;
end;

begin
  try
    TestFrfThresholdPeaks;
    TestAllWindowsZeroPadAndWelchGolden;
    TestCaptureLongerThanFft;
    TestFullSizeHammerSpectrumParity;
    TestImpactBaselineAndForcePosition;
    TestLegacyEstimatorMigration;
    TestSteadyStateIngestAllocations;
    TestValidationAndLifecycle;
    TestTriggerPolarityAndHysteresis;
    TestBoundedAcceptedRejectedSet;
    TestRingCaptureAssociation;
    TestGoldenEstimators;
    TestDiscriminatingEstimators;
    TestCaptureCompletionAndToken;
    TestHighRateCaptureRemainsBoundedAndCompletes;
    TestDspPipelineGoldenAndPreallocation;
    TestNoPartialPublish;
    TestTimestampResamplingPhaseGolden;
    TestPresentation;
    WriteLn('RESULT ImpactHammer passed');
  except
    on E: Exception do
    begin
      WriteLn(StdErr, 'RESULT ImpactHammer failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
