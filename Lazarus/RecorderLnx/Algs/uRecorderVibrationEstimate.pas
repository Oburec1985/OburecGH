unit uRecorderVibrationEstimate;

{ Pure estimates over an already computed rectangular energy spectrum.
  Prepare resolves units once during configuration; CalculatePrepared consumes
  numeric scaling/derivative order and optional component-local Hz bounds only.
  Manual bands intersect actual FFT bin centers (inclusive), always exclude DC
  and never fall back to the full spectrum when their intersection is empty.
  Raw amplitude preserves arbitrary tag
  units; integrations are permitted only for vibration quantities. No UI/FFT. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, uCommonTypes, uRecorderSpectrumEngine, uRecorderUnitManager;

type
  TRecorderVibrationQuantity = (
    rvqAcceleration,
    rvqVelocity,
    rvqDisplacement,
    rvqDominantFrequency,
    rvqAmplitude
  );
  TRecorderVibrationCalculation = record
    Valid: Boolean;
    Quantity: TRecorderVibrationQuantity;
    DerivativeOrder: Integer;
    Scale, FrequencyScale: Double;
    ManualBand: Boolean;
    BandFromHz, BandToHz: Double;
  end;

function RecorderPrepareVibrationCalculation(const ASourceUnit: string;
  AQuantity: TRecorderVibrationQuantity; const AOutputUnit: string):
  TRecorderVibrationCalculation;
function RecorderCalculatePreparedVibration(const AFrame: TRecorderSpectrumFrame;
  const ACalculation: TRecorderVibrationCalculation; ABandIndex: Integer;
  out AValue: Double; out AError: string): Boolean;

function RecorderVibrationQuantityCaption(
  AQuantity: TRecorderVibrationQuantity): string;
function RecorderVibrationDefaultUnit(
  AQuantity: TRecorderVibrationQuantity): string;
function RecorderIsVibrationUnit(const AUnit: string): Boolean;
function RecorderTryGetDominantFrequency(const AFrame: TRecorderSpectrumFrame;
  ABandIndex: Integer; const AOutputUnit: string; out AValue: Double;
  out AError: string): Boolean;
function RecorderTryCalculateVibrationEstimate(const AFrame: TRecorderSpectrumFrame;
  const ASourceUnit: string; AQuantity: TRecorderVibrationQuantity;
  ABandIndex: Integer; const AOutputUnit: string; out AValue: Double;
  out AError: string): Boolean;

implementation

uses Math;

function ManualBinRange(const AFrame: TRecorderSpectrumFrame;
  const ACalculation: TRecorderVibrationCalculation; out AFirst, ALast: Integer): Boolean;
begin
  Result := not IsNan(ACalculation.BandFromHz) and
    not IsInfinite(ACalculation.BandFromHz) and
    not IsNan(ACalculation.BandToHz) and
    not IsInfinite(ACalculation.BandToHz) and
    (ACalculation.BandFromHz >= 0) and
    (ACalculation.BandToHz > ACalculation.BandFromHz) and
    (AFrame.FrequencyStepHz > 0) and (Length(AFrame.Rms) > 1) and
    (ACalculation.BandFromHz <= High(AFrame.Rms) * AFrame.FrequencyStepHz);
  if Result then
    Result := RecorderSpectrumBandBinRange(ACalculation.BandFromHz,
      Min(ACalculation.BandToHz, High(AFrame.Rms) * AFrame.FrequencyStepHz),
      AFrame.FrequencyStepHz, Length(AFrame.Rms), AFirst, ALast);
  if Result then
  begin
    AFirst := Max(1, AFirst);
    Result := AFirst <= ALast;
  end;
end;

function RecorderPrepareVibrationCalculation(const ASourceUnit: string;
  AQuantity: TRecorderVibrationQuantity; const AOutputUnit: string):
  TRecorderVibrationCalculation;
var
  lSource, lTarget: TRecorderUnitInfo;
  lSourceOrder, lTargetOrder: Integer;
  function QuantityOrder(const AId: string): Integer;
  begin
    if SameText(AId, RECORDER_QUANTITY_ACCELERATION) then Exit(2);
    if SameText(AId, RECORDER_QUANTITY_VELOCITY) then Exit(1);
    if SameText(AId, RECORDER_QUANTITY_DISPLACEMENT) then Exit(0);
    Result := -1;
  end;
begin
  Result := Default(TRecorderVibrationCalculation);
  Result.Quantity := AQuantity;
  Result.Scale := 1;
  Result.FrequencyScale := 1;
  if AQuantity = rvqAmplitude then
  begin
    Result.Valid := SameText(ASourceUnit, AOutputUnit);
    Exit;
  end;
  if AQuantity = rvqDominantFrequency then
  begin
    Result.Valid := SameText(AOutputUnit, 'Hz') or SameText(AOutputUnit, 'kHz');
    if SameText(AOutputUnit, 'kHz') then Result.FrequencyScale := 0.001;
    Exit;
  end;
  if not RecorderUnitManager.TryGetUnitInfo(ASourceUnit, lSource) or
    not RecorderUnitManager.TryGetUnitInfo(AOutputUnit, lTarget) then Exit;
  lSourceOrder := QuantityOrder(lSource.QuantityId);
  lTargetOrder := QuantityOrder(lTarget.QuantityId);
  Result.Valid := (lSourceOrder >= 0) and (lTargetOrder >= 0) and
    (((AQuantity = rvqAcceleration) and (lTargetOrder = 2)) or
     ((AQuantity = rvqVelocity) and (lTargetOrder = 1)) or
     ((AQuantity = rvqDisplacement) and (lTargetOrder = 0)));
  Result.DerivativeOrder := lTargetOrder - lSourceOrder;
  if lTarget.ScaleToBase <> 0 then
    Result.Scale := lSource.ScaleToBase / lTarget.ScaleToBase
  else Result.Valid := False;
end;

function RecorderCalculatePreparedVibration(const AFrame: TRecorderSpectrumFrame;
  const ACalculation: TRecorderVibrationCalculation; ABandIndex: Integer;
  out AValue: Double; out AError: string): Boolean;
var
  lFirst, lLast, I, lMaxBin: Integer;
  lAmplitude, lOmega, lSum: Double;
begin
  Result := False;
  AValue := 0;
  AError := '';
  if not ACalculation.Valid then
  begin
    AError := 'Недопустимая величина или единица';
    Exit;
  end;
  if ACalculation.Quantity = rvqDominantFrequency then
  begin
    if ACalculation.ManualBand then
    begin
      if not ManualBinRange(AFrame, ACalculation, lFirst, lLast) then
      begin
        AError := 'В заданной полосе нет гармоник';
        Exit;
      end;
      lMaxBin := -1;
      for I := lFirst to lLast do
        if not IsNan(AFrame.Rms[I]) and not IsInfinite(AFrame.Rms[I]) then
          if (lMaxBin < 0) or (AFrame.Rms[I] > AFrame.Rms[lMaxBin]) then lMaxBin := I;
      if lMaxBin < 0 then
      begin
        AError := 'В заданной полосе нет конечных значений спектра';
        Exit;
      end;
      AValue := lMaxBin * AFrame.FrequencyStepHz * ACalculation.FrequencyScale;
      Exit(True);
    end;
    Result := RecorderTryGetDominantFrequency(AFrame, ABandIndex, 'Hz', AValue, AError);
    AValue := AValue * ACalculation.FrequencyScale;
    Exit;
  end;
  if (Length(AFrame.RectRms) < 2) or
    (Length(AFrame.RectRms) <> Length(AFrame.Rms)) or
    (AFrame.FrequencyStepHz <= 0) then
  begin
    AError := 'Прямоугольный энергетический спектр не рассчитан';
    Exit;
  end;
  lFirst := 1;
  lLast := High(AFrame.RectRms);
  if ACalculation.ManualBand then
  begin
    if not ManualBinRange(AFrame, ACalculation, lFirst, lLast) then
    begin
      AError := 'В заданной полосе нет гармоник';
      Exit;
    end;
  end
  else if ABandIndex >= 0 then
  begin
    if (ABandIndex >= Length(AFrame.Bands)) or
      not RecorderSpectrumBandBinRange(AFrame.Bands[ABandIndex].F1,
        AFrame.Bands[ABandIndex].F2, AFrame.FrequencyStepHz,
        Length(AFrame.RectRms), lFirst, lLast) then
    begin
      AError := 'Частотная полоса не пересекает спектр';
      Exit;
    end;
    if lFirst < 1 then lFirst := 1;
  end;
  lSum := 0;
  for I := lFirst to lLast do
  begin
    lAmplitude := AFrame.RectRms[I] * ACalculation.Scale;
    lOmega := 2 * Pi * I * AFrame.FrequencyStepHz;
    case ACalculation.DerivativeOrder of
      -2: lAmplitude := lAmplitude / Sqr(lOmega);
      -1: lAmplitude := lAmplitude / lOmega;
       1: lAmplitude := lAmplitude * lOmega;
       2: lAmplitude := lAmplitude * Sqr(lOmega);
    end;
    lSum := lSum + Sqr(lAmplitude);
  end;
  AValue := Sqrt(lSum);
  Result := True;
end;

function RecorderIsVibrationUnit(const AUnit: string): Boolean;
var
  lInfo: TRecorderUnitInfo;
begin
  Result := RecorderUnitManager.TryGetUnitInfo(AUnit, lInfo) and
    (SameText(lInfo.QuantityId, RECORDER_QUANTITY_ACCELERATION) or
     SameText(lInfo.QuantityId, RECORDER_QUANTITY_VELOCITY) or
     SameText(lInfo.QuantityId, RECORDER_QUANTITY_DISPLACEMENT));
end;


function RecorderVibrationQuantityCaption(
  AQuantity: TRecorderVibrationQuantity): string;
begin
  case AQuantity of
    rvqAcceleration: Result := 'Ускорение';
    rvqVelocity: Result := 'Скорость';
    rvqDisplacement: Result := 'Перемещение';
    rvqAmplitude: Result := 'Амплитуда';
  else
    Result := 'Частота главной гармоники';
  end;
end;

function RecorderVibrationDefaultUnit(
  AQuantity: TRecorderVibrationQuantity): string;
begin
  case AQuantity of
    rvqAcceleration: Result := 'm/s2';
    rvqVelocity: Result := 'mm/s';
    rvqDisplacement: Result := 'um';
    rvqAmplitude: Result := '';
  else
    Result := 'Hz';
  end;
end;

function RecorderTryGetDominantFrequency(const AFrame: TRecorderSpectrumFrame;
  ABandIndex: Integer; const AOutputUnit: string; out AValue: Double;
  out AError: string): Boolean;
var
  lFirstBin, lLastBin, lMaxBin, I: Integer;
  lMaxAmplitude: Double;
begin
  Result := False;
  AValue := 0.0;
  AError := '';
  if (AFrame.FrequencyStepHz <= 0.0) or (Length(AFrame.Rms) = 0) then
  begin
    AError := 'Спектр ещё не рассчитан';
    Exit;
  end;

  lFirstBin := 1; // DC is not a harmonic.
  lLastBin := Length(AFrame.Rms) - 1;
  if (ABandIndex < 0) and (AFrame.MaxIndex >= lFirstBin) and
    (AFrame.MaxIndex <= lLastBin) then
    lMaxBin := AFrame.MaxIndex
  else
    lMaxBin := -1;
  if ABandIndex >= 0 then
  begin
    if ABandIndex >= Length(AFrame.Bands) then
    begin
      AError := 'Выбранная частотная полоса отсутствует';
      Exit;
    end;
    if not RecorderSpectrumBandBinRange(AFrame.Bands[ABandIndex].F1,
      AFrame.Bands[ABandIndex].F2, AFrame.FrequencyStepHz,
      Length(AFrame.Rms), lFirstBin, lLastBin) then
    begin
      AError := 'Частотная полоса не пересекает спектр';
      Exit;
    end;
    if lFirstBin < 1 then lFirstBin := 1;
    if AFrame.Bands[ABandIndex].MaxFrequencyHz > 0.0 then
      lMaxBin := Round(AFrame.Bands[ABandIndex].MaxFrequencyHz /
        AFrame.FrequencyStepHz);
  end;
  if lFirstBin > lLastBin then
  begin
    AError := 'В выбранной полосе нет гармоник';
    Exit;
  end;

  { Reuse cached maximums first. The scan fallback supports old bindings whose
    CalculateBandMaximumFrequency flag was saved as False; it is not an FFT. }
  if (lMaxBin < lFirstBin) or (lMaxBin > lLastBin) then
  begin
    lMaxBin := lFirstBin;
    lMaxAmplitude := AFrame.Rms[lFirstBin];
    for I := lFirstBin + 1 to lLastBin do
      if AFrame.Rms[I] > lMaxAmplitude then
      begin
        lMaxAmplitude := AFrame.Rms[I];
        lMaxBin := I;
      end;
  end;
  AValue := lMaxBin * AFrame.FrequencyStepHz;
  if SameText(AOutputUnit, 'kHz') then
    AValue := AValue / 1000.0
  else if not SameText(AOutputUnit, 'Hz') then
  begin
    AError := 'Недопустимая единица частоты';
    Exit;
  end;
  Result := True;
end;


function RecorderTryCalculateVibrationEstimate(const AFrame: TRecorderSpectrumFrame;
  const ASourceUnit: string; AQuantity: TRecorderVibrationQuantity;
  ABandIndex: Integer; const AOutputUnit: string; out AValue: Double;
  out AError: string): Boolean;
var
  lCalculation: TRecorderVibrationCalculation;
begin
  lCalculation := RecorderPrepareVibrationCalculation(ASourceUnit, AQuantity,
    AOutputUnit);
  Result := RecorderCalculatePreparedVibration(AFrame, lCalculation,
    ABandIndex, AValue, AError);
end;

end.
