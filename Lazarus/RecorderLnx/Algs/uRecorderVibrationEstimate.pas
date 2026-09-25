unit uRecorderVibrationEstimate;

{ Pure vibration-estimate calculation over an already computed spectrum frame.
  This unit deliberately has no UI and does not request/recompute FFT data. }

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
    rvqDominantFrequency
  );

function RecorderVibrationQuantityCaption(
  AQuantity: TRecorderVibrationQuantity): string;
function RecorderVibrationDefaultUnit(
  AQuantity: TRecorderVibrationQuantity): string;
function RecorderTryGetDominantFrequency(const AFrame: TRecorderSpectrumFrame;
  ABandIndex: Integer; const AOutputUnit: string; out AValue: Double;
  out AError: string): Boolean;
function RecorderTryCalculateVibrationEstimate(const AFrame: TRecorderSpectrumFrame;
  const ASourceUnit: string; AQuantity: TRecorderVibrationQuantity;
  ABandIndex: Integer; const AOutputUnit: string; out AValue: Double;
  out AError: string): Boolean;

implementation

function RecorderVibrationQuantityId(
  AQuantity: TRecorderVibrationQuantity): string;
begin
  case AQuantity of
    rvqAcceleration: Result := RECORDER_QUANTITY_ACCELERATION;
    rvqVelocity: Result := RECORDER_QUANTITY_VELOCITY;
  else
    Result := RECORDER_QUANTITY_DISPLACEMENT;
  end;
end;

function RecorderVibrationQuantityCaption(
  AQuantity: TRecorderVibrationQuantity): string;
begin
  case AQuantity of
    rvqAcceleration: Result := 'Ускорение';
    rvqVelocity: Result := 'Скорость';
    rvqDisplacement: Result := 'Перемещение';
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

function RecorderTransformAmplitude(AAmplitudeBase, AFrequencyHz: Double;
  const ASourceQuantity, ATargetQuantity: string; out AResult: Double): Boolean;
var
  lOmega, lInverseOmega: Double;
begin
  Result := False;
  AResult := 0.0;
  if SameText(ASourceQuantity, ATargetQuantity) then
  begin
    AResult := AAmplitudeBase;
    Exit(True);
  end;
  { Integrals are undefined at DC. Callers intentionally exclude it. }
  if AFrequencyHz <= 0.0 then Exit;
  lOmega := HertzToAngularFrequency(AFrequencyHz);
  lInverseOmega := HertzToInverseAngularFrequency(AFrequencyHz);
  if SameText(ASourceQuantity, RECORDER_QUANTITY_ACCELERATION) then
  begin
    if SameText(ATargetQuantity, RECORDER_QUANTITY_VELOCITY) then
      AResult := AAmplitudeBase * lInverseOmega
    else if SameText(ATargetQuantity, RECORDER_QUANTITY_DISPLACEMENT) then
      AResult := AAmplitudeBase * Sqr(lInverseOmega)
    else
      Exit;
  end
  else if SameText(ASourceQuantity, RECORDER_QUANTITY_VELOCITY) then
  begin
    if SameText(ATargetQuantity, RECORDER_QUANTITY_ACCELERATION) then
      AResult := AAmplitudeBase * lOmega
    else if SameText(ATargetQuantity, RECORDER_QUANTITY_DISPLACEMENT) then
      AResult := AAmplitudeBase * lInverseOmega
    else
      Exit;
  end
  else if SameText(ASourceQuantity, RECORDER_QUANTITY_DISPLACEMENT) then
  begin
    if SameText(ATargetQuantity, RECORDER_QUANTITY_ACCELERATION) then
      AResult := AAmplitudeBase * Sqr(lOmega)
    else if SameText(ATargetQuantity, RECORDER_QUANTITY_VELOCITY) then
      AResult := AAmplitudeBase * lOmega
    else
      Exit;
  end
  else
    Exit;
  Result := True;
end;

function RecorderTryCalculateVibrationEstimate(const AFrame: TRecorderSpectrumFrame;
  const ASourceUnit: string; AQuantity: TRecorderVibrationQuantity;
  ABandIndex: Integer; const AOutputUnit: string; out AValue: Double;
  out AError: string): Boolean;
var
  lSourceInfo, lOutputInfo: TRecorderUnitInfo;
  lTargetQuantity: string;
  lFirstBin, lLastBin, I: Integer;
  lFrequency, lAmplitudeBase, lConvertedBase, lSumSquares: Double;
begin
  Result := False;
  AValue := 0.0;
  AError := '';
  if AQuantity = rvqDominantFrequency then
    Exit(RecorderTryGetDominantFrequency(AFrame, ABandIndex, AOutputUnit,
      AValue, AError));
  if not RecorderUnitManager.TryGetUnitInfo(ASourceUnit, lSourceInfo) then
  begin
    AError := 'Единица исходного тега не является вибрационной';
    Exit;
  end;
  lTargetQuantity := RecorderVibrationQuantityId(AQuantity);
  if not RecorderUnitManager.TryGetUnitInfo(AOutputUnit, lOutputInfo) or
    not SameText(lOutputInfo.QuantityId, lTargetQuantity) then
  begin
    AError := 'Недопустимая выходная единица';
    Exit;
  end;
  if not (SameText(lSourceInfo.QuantityId, RECORDER_QUANTITY_ACCELERATION) or
    SameText(lSourceInfo.QuantityId, RECORDER_QUANTITY_VELOCITY) or
    SameText(lSourceInfo.QuantityId, RECORDER_QUANTITY_DISPLACEMENT)) then
  begin
    AError := 'Для тега не назначена вибрационная ГХ';
    Exit;
  end;
  if (AFrame.FrequencyStepHz <= 0.0) or (Length(AFrame.Rms) = 0) then
  begin
    AError := 'Спектр ещё не рассчитан';
    Exit;
  end;
  if Length(AFrame.RectRms) <> Length(AFrame.Rms) then
  begin
    AError := 'Прямоугольный энергетический спектр не рассчитан';
    Exit;
  end;

  lFirstBin := 1; // DC never participates in vibration integrals.
  lLastBin := Length(AFrame.Rms) - 1;
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
  end;

  lSumSquares := 0.0;
  for I := lFirstBin to lLastBin do
  begin
    lFrequency := I * AFrame.FrequencyStepHz;
    lAmplitudeBase := AFrame.RectRms[I] * lSourceInfo.ScaleToBase;
    if not RecorderTransformAmplitude(lAmplitudeBase, lFrequency,
      lSourceInfo.QuantityId, lTargetQuantity, lConvertedBase) then
    begin
      AError := 'Невозможно пересчитать выбранную вибровеличину';
      Exit;
    end;
    lSumSquares := lSumSquares + Sqr(lConvertedBase);
  end;
  AValue := Sqrt(lSumSquares) / lOutputInfo.ScaleToBase;
  Result := True;
end;

end.
