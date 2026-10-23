unit uRecorderImpactDsp;

{ Подготавливает спектры ударного измерения. AddSample записывает в готовые
  буферы; окна, дополнение нулями, БПФ и усреднение Welch выполняются после сбора. }

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
    // Zero preserves the legacy decay ending at the last rectangular sample.
    ExponentialEndPositionFraction: Double;
    // Zero uses ExponentialEndFraction for legacy direct callers.
    ResponseExponentialEndLevel: Double;
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
    fDecayStartSample, fDecaySpanSamples: Double;
    fResponseDecayRate: Double;
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
{ Пересчитывает ряд с исходными метками на сетку, начинающуюся в
  AStartSeconds и содержащую ASampleCount точек с частотой ASampleRateHz.
  Возвращает False, если исходный ряд не покрывает весь целевой интервал. }
function ResampleImpactSeries(const ASeries: TRecorderSampleSeries;
  AStartSeconds, ASampleRateHz: Double; ASampleCount: Integer;
  out AValues: array of Double): Boolean;

implementation

{ Проверяет конечность значения перед спектральной обработкой. }
function Finite(AValue: Double): Boolean;
begin
  Result := not IsNan(AValue) and not IsInfinite(AValue);
end;

{ Пересчитывает временной ряд на равномерную сетку; при изменении частоты применяет оконный sinc-фильтр. }
function ResampleImpactSeries(const ASeries: TRecorderSampleSeries;
  AStartSeconds, ASampleRateHz: Double; ASampleCount: Integer;
  out AValues: array of Double): Boolean;
var
  SampleIndex: Integer;
  HighIndex: Integer;
  TargetTime: Double;
  TimeSpan: Double;
  Ratio: Double;
  I, LeftIndex, KernelIndex: Integer;
  SourceRate, Cutoff, HalfWindow, Delta, X, Weight, Sum, WeightSum: Double;
  FilterRateChange: Boolean;
begin
  Result := Finite(AStartSeconds) and Finite(ASampleRateHz) and
    (ASampleRateHz > 0) and (ASampleCount > 0) and
    (Length(AValues) >= ASampleCount) and (Length(ASeries) >= 2);
  if not Result then
    Exit;
  for I:=0 to High(ASeries) do
  begin
    if not Finite(ASeries[I].TimeSeconds) or not Finite(ASeries[I].Value) then Exit(False);
    if (I>0) and (ASeries[I].TimeSeconds<=ASeries[I-1].TimeSeconds) then Exit(False);
  end;
  SourceRate:=(Length(ASeries)-1)/
    (ASeries[High(ASeries)].TimeSeconds-ASeries[0].TimeSeconds);
  if not Finite(SourceRate) or (SourceRate<=0) then Exit(False);
  FilterRateChange:=(Length(ASeries)>=4) and
    (Abs(SourceRate-ASampleRateHz)>1E-3*Max(SourceRate,ASampleRateHz));
  { Симметричный оконный sinc не добавляет групповой задержки. При понижении Fs
    НЧ-фильтр подавляет частоты выше Найквиста отклика; при повышении Fs
    интерполируется имеющаяся полоса воздействия без экстраполяции сигнала.
    Для равных частот сохраняется прежняя линейная интерполяция. }
  Cutoff:=0.45*Min(SourceRate,ASampleRateHz);
  HalfWindow:=16/Min(SourceRate,ASampleRateHz);
  LeftIndex:=0;
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
    if not FilterRateChange then
    begin
      Ratio := (TargetTime - ASeries[HighIndex - 1].TimeSeconds) / TimeSpan;
      AValues[SampleIndex] := ASeries[HighIndex - 1].Value + Ratio *
        (ASeries[HighIndex].Value - ASeries[HighIndex - 1].Value);
    end
    else
    begin
      while (LeftIndex<High(ASeries)) and
        (ASeries[LeftIndex].TimeSeconds<TargetTime-HalfWindow) do Inc(LeftIndex);
      KernelIndex:=LeftIndex;
      Sum:=0; WeightSum:=0;
      while (KernelIndex<Length(ASeries)) and
        (ASeries[KernelIndex].TimeSeconds<=TargetTime+HalfWindow) do
      begin
        Delta:=ASeries[KernelIndex].TimeSeconds-TargetTime;
        X:=2*Cutoff*Delta;
        if Abs(X)<1E-12 then Weight:=1 else Weight:=Sin(Pi*X)/(Pi*X);
        Weight:=Weight*0.5*(1+Cos(Pi*Delta/HalfWindow));
        Sum:=Sum+Weight*ASeries[KernelIndex].Value;
        WeightSum:=WeightSum+Weight;
        Inc(KernelIndex);
      end;
      if Abs(WeightSum)<1E-12 then Exit(False);
      AValues[SampleIndex]:=Sum/WeightSum;
      if not Finite(AValues[SampleIndex]) then Exit(False);
    end;
  end;
  Result := True;
end;

{ Суммирует спектральные моменты ударов и рассчитывает оценку H0, H1 или H2. }
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

{ Освобождает план БПФ. }
destructor TRecorderImpactDspPipeline.Destroy;
begin
  fPlan.Free;
  inherited Destroy;
end;

{ Строит окно выбранного типа на длине сегмента БПФ. }
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

{ Обнуляет накопленные авто- и взаимные спектральные моменты. }
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

{ Возвращает число сегментов захвата для режима целой записи или Welch. }
function TRecorderImpactDspPipeline.SegmentCount: Integer;
begin
  if fSettings.WelchSegmentSamples < 2 then
    Exit(1);
  Result := 1 + (fSettings.CaptureSamples - fSegmentSamples) div fHopSamples;
end;

{ Формирует единицу передаточной функции из единиц числителя и знаменателя. }
function TRecorderImpactDspPipeline.UnitRatio(const ANumerator,
  ADenominator: string): string;
begin
  if ANumerator = '' then
    Exit('');
  if ADenominator = '' then
    Exit(ANumerator);
  Result := ANumerator + '/' + ADenominator;
end;

{ Проверяет настройки и выделяет буферы каналов, сегментов и спектральных сумм. }
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
     not Finite(ASettings.ExponentialEndPositionFraction) or
     not Finite(ASettings.ResponseExponentialEndLevel) or
     (ASettings.ResponseExponentialEndLevel < 0) or
     (ASettings.ResponseExponentialEndLevel > 1) or
     (ASettings.WindowStartFraction < 0) or
     (ASettings.WindowEndFraction > 1) or
     (ASettings.WindowEndFraction <= ASettings.WindowStartFraction) or
     (ASettings.ExponentialStartFraction < 0) or
     (ASettings.ExponentialStartFraction >= 1) or
     (ASettings.ExponentialEndPositionFraction < 0) or
     ((ASettings.ExponentialEndPositionFraction > 0) and
      (ASettings.ExponentialEndPositionFraction <= ASettings.ExponentialStartFraction))) then
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
  // Samples belong to the physical half-open interval [start, end). Nearest
  // rounding can retain a sample before the left cursor. The small tolerance
  // only absorbs floating-point multiplication noise at exact sample edges.
  fWindowStart := EnsureRange(Ceil(ASettings.CaptureSamples *
    ASettings.WindowStartFraction - 1E-9), 0, ASettings.CaptureSamples);
  fWindowEnd := EnsureRange(Ceil(ASettings.CaptureSamples *
    ASettings.WindowEndFraction - 1E-9), fWindowStart,
    ASettings.CaptureSamples);
  fExponentialStart := EnsureRange(Round(ASettings.CaptureSamples *
    ASettings.ExponentialStartFraction), 0, ASettings.CaptureSamples - 1);
  fDecayStartSample := fExponentialStart;
  fDecaySpanSamples := Max(1, fWindowEnd - 1 - fExponentialStart);
  if ASettings.ExponentialEndPositionFraction > 0 then
  begin
    // The handle position is physical time, not the last included sample.
    fDecayStartSample := ASettings.CaptureSamples *
      ASettings.ExponentialStartFraction;
    fDecaySpanSamples := ASettings.CaptureSamples *
      (ASettings.ExponentialEndPositionFraction -
       ASettings.ExponentialStartFraction);
  end;
  if ASettings.ResponseExponentialEndLevel > 0 then
    fResponseDecayRate := Ln(Max(1E-12,
      ASettings.ResponseExponentialEndLevel)) / fDecaySpanSamples
  else
    fResponseDecayRate := Ln(Max(1E-12,
      ASettings.ExponentialEndFraction)) / fDecaySpanSamples;
  if ASettings.WelchSegmentSamples < 2 then
    fHopSamples := fSegmentSamples
  else
    fHopSamples := Max(1, fSegmentSamples *
      (100 - ASettings.WelchOverlapPercent) div 100);
  fBins := ASettings.FftSize div 2 + 1;
  if (fPlan = nil) or (fPlan.Size <> ASettings.FftSize) then
  begin
    FreeAndNil(fPlan);
    fPlan := TRecorderSpectrumFFTPlan.Create(ASettings.FftSize);
  end;
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

{ Сбрасывает заполненность каналов, не меняя выделенную память. }
procedure TRecorderImpactDspPipeline.ResetCapture;
var
  lChannel: Integer;
begin
  for lChannel := 0 to High(fCounts) do
    fCounts[lChannel] := 0;
end;

{ Добавляет значение в канал: индекс 0 — воздействие, далее — отклики. }
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

{ Проверяет, что каждый канал получил CaptureSamples значений. }
function TRecorderImpactDspPipeline.Ready: Boolean;
var
  lChannel: Integer;
begin
  Result := Length(fCounts) > 0;
  for lChannel := 0 to High(fCounts) do
    Result := Result and (fCounts[lChannel] = fSettings.CaptureSamples);
end;

{ Для отклика AResponseIndex удаляет смещение, считает сегментные спектры и возвращает усреднённые моменты. }
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
  { У датчиков силы и отклика может быть большое постоянное смещение. Базовый
    уровень оценивается по последним 10% полного захвата до разбиения на окна
    БПФ/Welch. }
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
      { Ядро radix-2 ожидает вход в бит-реверсном порядке. При дополнении нулями
        подача обычного порядка даёт правдоподобные, но неверные спектральные моменты. }
      lWorkIndex := fPlan.BitReverse[lSample];
      // The rectangular gate belongs to excitation only; response has its
      // independent exponential envelope, including the tail beyond the gate.
      if not fSettings.WindowEnabled or
        ((lStart + lSample >= fWindowStart) and
         (lStart + lSample < fWindowEnd)) then
        fWorkX[lWorkIndex].Re :=
          (fExcitation[lStart + lSample] - lExcitationBase) * fWindow[lSample];
      fWorkY[lWorkIndex].Re :=
        (fResponses[AResponseIndex][lStart + lSample] - lResponseBase) *
        fWindow[lSample];
      if fSettings.WindowEnabled and
        (lStart + lSample > fDecayStartSample) then
        fWorkY[lWorkIndex].Re := fWorkY[lWorkIndex].Re *
          Exp(fResponseDecayRate * (lStart + lSample - fDecayStartSample));
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

{ Возвращает число принятых отсчётов указанного канала; индекс 0 соответствует воздействию. }
function TRecorderImpactDspPipeline.BufferedSampleCount(
  AChannelIndex: Integer): Integer;
begin
  if (AChannelIndex < 0) or (AChannelIndex > High(fCounts)) then
    Exit(0);
  Result := fCounts[AChannelIndex];
end;

{ Возвращает адрес буфера канала для диагностики повторного использования памяти. }
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
