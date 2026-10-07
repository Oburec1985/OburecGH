unit uRecorderImpactDsp;

{ Preallocated impact-hammer spectral preparation. AddSample only writes fixed
  buffers; windowing, zero padding, FFT and Welch reduction run after capture. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, Math, uRecorderSpectrumEngine, uRecorderImpactHammer;

type
  TRecorderImpactWindowKind = (iwkRectangular, iwkHann, iwkHamming,
    iwkForce, iwkExponential);

  TRecorderImpactDspSettings = record
    SampleRateHz: Double;
    CaptureSamples: Integer;
    FftSize: Integer;
    WelchSegmentSamples: Integer;
    WelchOverlapPercent: Integer;
    ResponseCount: Integer;
    WindowKind: TRecorderImpactWindowKind;
    ForceWindowFraction: Double;
    ExponentialEndFraction: Double;
    WindowEnabled: Boolean;
    WindowStartFraction: Double;
    WindowEndFraction: Double;
    ExponentialStartFraction: Double;
    ExcitationUnitName: string;
    ResponseUnitNames: array of string;
  end;

  TRecorderImpactSpectrumMetadata = record
    SampleRateHz: Double;
    FftSize: Integer;
    FrequencyStepHz: Double;
    SegmentCount: Integer;
    ExcitationUnitName: string;
    ResponseUnitName: string;
    TransferUnitName: string;
  end;

  TRecorderImpactSpectralMoments = record
    FrequencyHz: array of Double;
    ExcitationPower: array of Double;
    ResponsePower: array of Double;
    CrossReal: array of Double;
    CrossImaginary: array of Double;
    Metadata: TRecorderImpactSpectrumMetadata;
  end;

  TRecorderImpactDspPipeline = class
  private
    fSettings: TRecorderImpactDspSettings;
    fPlan: TRecorderSpectrumFFTPlan;
    fExcitation: array of Double;
    fResponses: array of array of Double;
    fCounts: array of Integer;
    fWindow: array of Double;
    fWorkX, fWorkY: array of TRecorderSpectrumComplex;
    fSxx, fSyy: array of Double;
    fSxy: array of TRecorderSpectrumComplex;
    fSegmentSamples, fHopSamples, fBins: Integer;
    fWindowStart, fWindowEnd, fExponentialStart: Integer;
    procedure BuildWindow;
    procedure ClearMoments;
    function SegmentCount: Integer;
    function UnitRatio(const ANumerator, ADenominator: string): string;
  public
    destructor Destroy; override;
    function Configure(const ASettings: TRecorderImpactDspSettings;
      out AError: string): Boolean;
    procedure ResetCapture;
    function AddSample(AChannelIndex: Integer; AValue: Double): Boolean;
    function Ready: Boolean;
    function PrepareResponse(AResponseIndex: Integer;
      out AResult: TRecorderImpactSpectralMoments): Boolean;
    function BufferedSampleCount(AChannelIndex: Integer): Integer;
    function BufferIdentity(AChannelIndex: Integer): PtrUInt;
  end;

function EstimateImpactMoments(
  const AImpacts: array of TRecorderImpactSpectralMoments;
  AKind: TRecorderFrfEstimatorKind; out AEstimate: TRecorderFrfEstimate): Boolean;
function ResampleImpactSeries(const ASeries: TRecorderSampleSeries;
  AStartSeconds, ASampleRateHz: Double; ASampleCount: Integer;
  out AValues: array of Double): Boolean;

implementation

function ResampleImpactSeries(const ASeries: TRecorderSampleSeries;
  AStartSeconds, ASampleRateHz: Double; ASampleCount: Integer;
  out AValues: array of Double): Boolean;
var
  SampleIndex: Integer;
  HighIndex: Integer;
  TargetTime: Double;
  TimeSpan: Double;
  Ratio: Double;
begin
  Result := (ASampleRateHz > 0) and (ASampleCount > 0) and
    (Length(AValues) >= ASampleCount) and (Length(ASeries) >= 2);
  if not Result then
    Exit;
  HighIndex := 1;
  for SampleIndex := 0 to ASampleCount - 1 do
  begin
    TargetTime := AStartSeconds + SampleIndex / ASampleRateHz;
    while (HighIndex < High(ASeries)) and
      (ASeries[HighIndex].TimeSeconds < TargetTime) do
      Inc(HighIndex);
    if (ASeries[HighIndex].TimeSeconds < TargetTime) or
      (ASeries[HighIndex - 1].TimeSeconds > TargetTime) then
      Exit(False);
    TimeSpan := ASeries[HighIndex].TimeSeconds -
      ASeries[HighIndex - 1].TimeSeconds;
    if TimeSpan <= 0 then
      Exit(False);
    Ratio := (TargetTime - ASeries[HighIndex - 1].TimeSeconds) / TimeSpan;
    AValues[SampleIndex] := ASeries[HighIndex - 1].Value + Ratio *
      (ASeries[HighIndex].Value - ASeries[HighIndex - 1].Value);
  end;
  Result := True;
end;

function Finite(AValue: Double): Boolean;
begin
  Result := not IsNan(AValue) and not IsInfinite(AValue);
end;

function EstimateImpactMoments(
  const AImpacts: array of TRecorderImpactSpectralMoments;
  AKind: TRecorderFrfEstimatorKind; out AEstimate: TRecorderFrfEstimate): Boolean;
var
  lImpact, lBin, lBins: Integer;
  lSxx, lSyy, lCrossReal, lCrossImaginary: Double;
  lCrossPower, lMagnitude: Double;
  lResult: TRecorderFrfEstimate;
begin
  Result := False;
  lResult := Default(TRecorderFrfEstimate);
  if Length(AImpacts) = 0 then
    Exit;
  lBins := Length(AImpacts[0].FrequencyHz);
  if lBins = 0 then
    Exit;
  for lImpact := 0 to High(AImpacts) do
    if (Length(AImpacts[lImpact].FrequencyHz) <> lBins) or
      (Length(AImpacts[lImpact].ExcitationPower) <> lBins) or
      (Length(AImpacts[lImpact].ResponsePower) <> lBins) or
      (Length(AImpacts[lImpact].CrossReal) <> lBins) or
      (Length(AImpacts[lImpact].CrossImaginary) <> lBins) then
      Exit;
  SetLength(lResult.FrequencyHz, lBins);
  SetLength(lResult.Magnitude, lBins);
  SetLength(lResult.PhaseRadians, lBins);
  SetLength(lResult.Coherence, lBins);
  for lBin := 0 to lBins - 1 do
  begin
    lSxx := 0;
    lSyy := 0;
    lCrossReal := 0;
    lCrossImaginary := 0;
    lMagnitude := 0;
    for lImpact := 0 to High(AImpacts) do
    begin
      if not Finite(AImpacts[lImpact].FrequencyHz[lBin]) or
        not Finite(AImpacts[lImpact].ExcitationPower[lBin]) or
        not Finite(AImpacts[lImpact].ResponsePower[lBin]) or
        not Finite(AImpacts[lImpact].CrossReal[lBin]) or
        not Finite(AImpacts[lImpact].CrossImaginary[lBin]) or
        (AImpacts[lImpact].ExcitationPower[lBin] <= 1E-24) or
        (AImpacts[lImpact].ResponsePower[lBin] < 0) or
        ((lImpact > 0) and
         (Abs(AImpacts[lImpact].FrequencyHz[lBin] -
          AImpacts[0].FrequencyHz[lBin]) > 1E-10 *
          Max(1.0, Abs(AImpacts[0].FrequencyHz[lBin])))) then
        Exit;
      lSxx := lSxx + AImpacts[lImpact].ExcitationPower[lBin];
      lSyy := lSyy + AImpacts[lImpact].ResponsePower[lBin];
      lCrossReal := lCrossReal + AImpacts[lImpact].CrossReal[lBin];
      lCrossImaginary := lCrossImaginary +
        AImpacts[lImpact].CrossImaginary[lBin];
      lMagnitude := lMagnitude + Sqrt(
        AImpacts[lImpact].ResponsePower[lBin] /
        AImpacts[lImpact].ExcitationPower[lBin]);
    end;
    lCrossPower := Sqr(lCrossReal) + Sqr(lCrossImaginary);
    if lCrossPower <= 1E-24 * Max(1.0, lSxx * lSyy) then
      Exit;
    case AKind of
      fekH0:
        lMagnitude := lMagnitude / Length(AImpacts);
      fekH1:
        lMagnitude := Sqrt(lCrossPower) / lSxx;
      fekH2:
        lMagnitude := lSyy / Sqrt(lCrossPower);
    end;
    lResult.FrequencyHz[lBin] := AImpacts[0].FrequencyHz[lBin];
    lResult.Magnitude[lBin] := lMagnitude;
    lResult.PhaseRadians[lBin] := ArcTan2(lCrossImaginary, lCrossReal);
    lResult.Coherence[lBin] := EnsureRange(lCrossPower / (lSxx * lSyy),
      0.0, 1.0);
  end;
  AEstimate := lResult;
  Result := True;
end;

destructor TRecorderImpactDspPipeline.Destroy;
begin
  fPlan.Free;
  inherited Destroy;
end;

procedure TRecorderImpactDspPipeline.BuildWindow;
var
  lIndex: Integer;
  lPhase: Double;
begin
  SetLength(fWindow, fSegmentSamples);
  for lIndex := 0 to fSegmentSamples - 1 do
  begin
    if fSegmentSamples > 1 then
      lPhase := 2 * Pi * lIndex / (fSegmentSamples - 1)
    else
      lPhase := 0;
    case fSettings.WindowKind of
      iwkHann:
        fWindow[lIndex] := 0.5 - 0.5 * Cos(lPhase);
      iwkHamming:
        fWindow[lIndex] := 0.54 - 0.46 * Cos(lPhase);
      iwkForce:
        fWindow[lIndex] := 1;
      iwkExponential:
        fWindow[lIndex] := Exp(Ln(Max(1E-12,
          fSettings.ExponentialEndFraction)) * lIndex /
          Max(1, fSegmentSamples - 1));
    else
      fWindow[lIndex] := 1;
    end;
  end;
end;

procedure TRecorderImpactDspPipeline.ClearMoments;
var
  lBin: Integer;
begin
  for lBin := 0 to fBins - 1 do
  begin
    fSxx[lBin] := 0;
    fSyy[lBin] := 0;
    fSxy[lBin].Re := 0;
    fSxy[lBin].Im := 0;
  end;
end;

function TRecorderImpactDspPipeline.SegmentCount: Integer;
begin
  if fSettings.WelchSegmentSamples < 2 then
    Exit(1);
  Result := 1 + (fSettings.CaptureSamples - fSegmentSamples) div fHopSamples;
end;

function TRecorderImpactDspPipeline.UnitRatio(const ANumerator,
  ADenominator: string): string;
begin
  if ANumerator = '' then
    Exit('');
  if ADenominator = '' then
    Exit(ANumerator);
  Result := ANumerator + '/' + ADenominator;
end;

function TRecorderImpactDspPipeline.Configure(
  const ASettings: TRecorderImpactDspSettings; out AError: string): Boolean;
var
  lChannel: Integer;
  lSegmentSamples: Integer;
begin
  AError := '';
  lSegmentSamples := Min(ASettings.CaptureSamples, ASettings.FftSize);
  if ASettings.WelchSegmentSamples >= 2 then
    lSegmentSamples := ASettings.WelchSegmentSamples;
  if not Finite(ASettings.SampleRateHz) or (ASettings.SampleRateHz <= 0) then
    AError := 'Sample rate must be finite and positive'
  else if (ASettings.CaptureSamples < 2) or
    (ASettings.FftSize < 2) or
    (ASettings.FftSize < lSegmentSamples) or
    ((ASettings.FftSize and (ASettings.FftSize - 1)) <> 0) then
    AError := 'FFT size must be a power of two covering a Welch segment'
  else if ASettings.ResponseCount <= 0 then
    AError := 'At least one response is required'
  else if Length(ASettings.ResponseUnitNames) <> ASettings.ResponseCount then
    AError := 'Response unit metadata count mismatch'
  else if (ASettings.WelchSegmentSamples < 0) or
    (ASettings.WelchSegmentSamples > ASettings.CaptureSamples) then
    AError := 'Welch segment must fit capture'
  else if (ASettings.WelchOverlapPercent < 0) or
    (ASettings.WelchOverlapPercent > 95) then
    AError := 'Welch overlap must be between 0 and 95 percent'
  else if not Finite(ASettings.ForceWindowFraction) or
    (ASettings.ForceWindowFraction <= 0) or
    (ASettings.ForceWindowFraction > 1) then
    AError := 'Force window fraction must be within (0, 1]'
  else if not Finite(ASettings.ExponentialEndFraction) or
    (ASettings.ExponentialEndFraction <= 0) or
    (ASettings.ExponentialEndFraction > 1) then
    AError := 'Exponential end fraction must be within (0, 1]';
  if (AError = '') and ASettings.WindowEnabled and
    (not Finite(ASettings.WindowStartFraction) or
     not Finite(ASettings.WindowEndFraction) or
     not Finite(ASettings.ExponentialStartFraction) or
     (ASettings.WindowStartFraction < 0) or
     (ASettings.WindowEndFraction > 1) or
     (ASettings.WindowEndFraction <= ASettings.WindowStartFraction) or
     (ASettings.ExponentialStartFraction < ASettings.WindowStartFraction) or
     (ASettings.ExponentialStartFraction >= ASettings.WindowEndFraction)) then
    AError := 'Runtime filter window fractions are invalid';
  Result := AError = '';
  if not Result then
    Exit;
  fSettings := ASettings;
  fSettings.ResponseUnitNames := Copy(ASettings.ResponseUnitNames);
  if ASettings.WelchSegmentSamples >= 2 then
    fSegmentSamples := ASettings.WelchSegmentSamples
  else
    fSegmentSamples := Min(ASettings.CaptureSamples, ASettings.FftSize);
  fWindowStart := EnsureRange(Round(ASettings.CaptureSamples *
    ASettings.WindowStartFraction), 0, ASettings.CaptureSamples - 1);
  fWindowEnd := EnsureRange(Round(ASettings.CaptureSamples *
    ASettings.WindowEndFraction), fWindowStart + 1,
    ASettings.CaptureSamples);
  fExponentialStart := EnsureRange(Round(ASettings.CaptureSamples *
    ASettings.ExponentialStartFraction), fWindowStart, fWindowEnd - 1);
  if ASettings.WelchSegmentSamples < 2 then
    fHopSamples := fSegmentSamples
  else
    fHopSamples := Max(1, fSegmentSamples *
      (100 - ASettings.WelchOverlapPercent) div 100);
  fBins := ASettings.FftSize div 2 + 1;
  FreeAndNil(fPlan);
  fPlan := TRecorderSpectrumFFTPlan.Create(ASettings.FftSize);
  SetLength(fExcitation, ASettings.CaptureSamples);
  SetLength(fResponses, ASettings.ResponseCount);
  for lChannel := 0 to High(fResponses) do
    SetLength(fResponses[lChannel], ASettings.CaptureSamples);
  SetLength(fCounts, ASettings.ResponseCount + 1);
  SetLength(fWorkX, ASettings.FftSize);
  SetLength(fWorkY, ASettings.FftSize);
  SetLength(fSxx, fBins);
  SetLength(fSyy, fBins);
  SetLength(fSxy, fBins);
  BuildWindow;
  ResetCapture;
end;

procedure TRecorderImpactDspPipeline.ResetCapture;
var
  lChannel: Integer;
begin
  for lChannel := 0 to High(fCounts) do
    fCounts[lChannel] := 0;
end;

function TRecorderImpactDspPipeline.AddSample(AChannelIndex: Integer;
  AValue: Double): Boolean;
var
  lCount: Integer;
begin
  Result := (Length(fCounts) > 0) and (AChannelIndex >= 0) and
    (AChannelIndex <= fSettings.ResponseCount) and Finite(AValue);
  if not Result then
    Exit;
  lCount := fCounts[AChannelIndex];
  if lCount >= fSettings.CaptureSamples then
    Exit(False);
  if AChannelIndex = 0 then
    fExcitation[lCount] := AValue
  else
    fResponses[AChannelIndex - 1][lCount] := AValue;
  fCounts[AChannelIndex] := lCount + 1;
end;

function TRecorderImpactDspPipeline.Ready: Boolean;
var
  lChannel: Integer;
begin
  Result := Length(fCounts) > 0;
  for lChannel := 0 to High(fCounts) do
    Result := Result and (fCounts[lChannel] = fSettings.CaptureSamples);
end;

function TRecorderImpactDspPipeline.PrepareResponse(AResponseIndex: Integer;
  out AResult: TRecorderImpactSpectralMoments): Boolean;
var
  lSegment, lSegmentCount, lStart, lSample, lBin, lWorkIndex: Integer;
  lTailStart, lTailCount, lIndex: Integer;
  lExcitationBase, lResponseBase: Double;
  lX, lY: TRecorderSpectrumComplex;
begin
  AResult := Default(TRecorderImpactSpectralMoments);
  Result := Ready and (AResponseIndex >= 0) and
    (AResponseIndex < fSettings.ResponseCount);
  if not Result then
    Exit;
  { The impact and response sensors may carry large static offsets. The
    original FRF processing estimates the baseline from the last 10% of the
    complete capture, before segmenting it for FFT/Welch. }
  lTailStart := Trunc(0.9 * fSettings.CaptureSamples);
  lTailCount := fSettings.CaptureSamples - lTailStart;
  lExcitationBase := 0;
  lResponseBase := 0;
  for lIndex := lTailStart to fSettings.CaptureSamples - 1 do
  begin
    lExcitationBase := lExcitationBase + fExcitation[lIndex];
    lResponseBase := lResponseBase + fResponses[AResponseIndex][lIndex];
  end;
  lExcitationBase := lExcitationBase / lTailCount;
  lResponseBase := lResponseBase / lTailCount;
  ClearMoments;
  lSegmentCount := SegmentCount;
  for lSegment := 0 to lSegmentCount - 1 do
  begin
    lStart := lSegment * fHopSamples;
    for lSample := 0 to fSettings.FftSize - 1 do
    begin
      fWorkX[lSample].Re := 0;
      fWorkX[lSample].Im := 0;
      fWorkY[lSample].Re := 0;
      fWorkY[lSample].Im := 0;
    end;
    for lSample := 0 to Min(fSegmentSamples,
      fSettings.CaptureSamples - lStart) - 1 do
    begin
      { The in-place radix-2 kernel consumes bit-reversed input. This is
        especially visible when a capture is zero-padded: natural-order input
        silently produced plausible but wrong spectral moments. }
      lWorkIndex := fPlan.BitReverse[lSample];
      if fSettings.WindowEnabled and
        ((lStart + lSample < fWindowStart) or
         (lStart + lSample >= fWindowEnd)) then
        Continue;
      fWorkX[lWorkIndex].Re :=
        (fExcitation[lStart + lSample] - lExcitationBase) * fWindow[lSample];
      fWorkY[lWorkIndex].Re :=
        (fResponses[AResponseIndex][lStart + lSample] - lResponseBase) *
        fWindow[lSample];
      if fSettings.WindowEnabled and
        (lStart + lSample > fExponentialStart) then
        fWorkY[lWorkIndex].Re := fWorkY[lWorkIndex].Re *
          Exp(Ln(Max(1E-12, fSettings.ExponentialEndFraction)) *
          (lStart + lSample - fExponentialStart) /
          Max(1, fWindowEnd - 1 - fExponentialStart));
    end;
    fPlan.ExecuteForward(@fWorkX[0]);
    fPlan.ExecuteForward(@fWorkY[0]);
    for lBin := 0 to fBins - 1 do
    begin
      lX := fWorkX[lBin];
      lY := fWorkY[lBin];
      fSxx[lBin] := fSxx[lBin] + lX.Re * lX.Re + lX.Im * lX.Im;
      fSyy[lBin] := fSyy[lBin] + lY.Re * lY.Re + lY.Im * lY.Im;
      fSxy[lBin].Re := fSxy[lBin].Re + lY.Re * lX.Re + lY.Im * lX.Im;
      fSxy[lBin].Im := fSxy[lBin].Im + lY.Im * lX.Re - lY.Re * lX.Im;
    end;
  end;
  SetLength(AResult.FrequencyHz, fBins);
  SetLength(AResult.ExcitationPower, fBins);
  SetLength(AResult.ResponsePower, fBins);
  SetLength(AResult.CrossReal, fBins);
  SetLength(AResult.CrossImaginary, fBins);
  for lBin := 0 to fBins - 1 do
  begin
    AResult.FrequencyHz[lBin] := lBin * fSettings.SampleRateHz /
      fSettings.FftSize;
    AResult.ExcitationPower[lBin] := fSxx[lBin] / lSegmentCount;
    AResult.ResponsePower[lBin] := fSyy[lBin] / lSegmentCount;
    AResult.CrossReal[lBin] := fSxy[lBin].Re / lSegmentCount;
    AResult.CrossImaginary[lBin] := fSxy[lBin].Im / lSegmentCount;
  end;
  AResult.Metadata.SampleRateHz := fSettings.SampleRateHz;
  AResult.Metadata.FftSize := fSettings.FftSize;
  AResult.Metadata.FrequencyStepHz := fSettings.SampleRateHz /
    fSettings.FftSize;
  AResult.Metadata.SegmentCount := lSegmentCount;
  AResult.Metadata.ExcitationUnitName := fSettings.ExcitationUnitName;
  AResult.Metadata.ResponseUnitName :=
    fSettings.ResponseUnitNames[AResponseIndex];
  AResult.Metadata.TransferUnitName := UnitRatio(
    AResult.Metadata.ResponseUnitName,
    AResult.Metadata.ExcitationUnitName);
  Result := True;
end;

function TRecorderImpactDspPipeline.BufferedSampleCount(
  AChannelIndex: Integer): Integer;
begin
  if (AChannelIndex < 0) or (AChannelIndex > High(fCounts)) then
    Exit(0);
  Result := fCounts[AChannelIndex];
end;

function TRecorderImpactDspPipeline.BufferIdentity(
  AChannelIndex: Integer): PtrUInt;
begin
  Result := 0;
  if AChannelIndex = 0 then
  begin
    if Length(fExcitation) > 0 then
      Result := PtrUInt(@fExcitation[0]);
  end
  else if (AChannelIndex > 0) and
    (AChannelIndex <= Length(fResponses)) and
    (Length(fResponses[AChannelIndex - 1]) > 0) then
    Result := PtrUInt(@fResponses[AChannelIndex - 1][0]);
end;

end.
