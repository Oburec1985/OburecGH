unit uSharedStatistics;

{$mode objfpc}{$H+}

interface

type
  TVarianceKind = (vkPopulation, vkSample);

  TStatisticsSummary = record
    Count: Integer;
    Sum: Double;
    Mean: Double;
    Minimum: Double;
    Maximum: Double;
    PopulationVariance: Double;
    SampleVariance: Double;
  end;

function TryMean(const Values: array of Double; out Value: Double): Boolean;
function TryPopulationVariance(const Values: array of Double;
  out Value: Double): Boolean;
function TrySampleVariance(const Values: array of Double;
  out Value: Double): Boolean;
function TryStandardDeviation(const Values: array of Double;
  Kind: TVarianceKind; out Value: Double): Boolean;
function TryCovariance(const X, Y: array of Double; out Value: Double): Boolean;
function TryCorrelation(const X, Y: array of Double; out Value: Double): Boolean;
function TrySummary(const Values: array of Double;
  out Summary: TStatisticsSummary): Boolean;

implementation

uses
  Math;

function IsFiniteValue(const Value: Double): Boolean; inline;
begin
  Result := not IsNan(Value) and not IsInfinite(Value);
end;

function TrySummary(const Values: array of Double;
  out Summary: TStatisticsSummary): Boolean;
var
  I, Count: Integer;
  Delta, DeltaAfterMean, M2, NewMean, Sum: Double;
begin
  Summary := Default(TStatisticsSummary);
  if Length(Values) = 0 then
    Exit(False);

  Count := 0;
  Sum := 0.0;
  M2 := 0.0;
  for I := Low(Values) to High(Values) do
  begin
    if not IsFiniteValue(Values[I]) then
      Exit(False);

    Inc(Count);
    if Count = 1 then
    begin
      Summary.Mean := Values[I];
      Summary.Minimum := Values[I];
      Summary.Maximum := Values[I];
    end
    else
    begin
      Delta := Values[I] - Summary.Mean;
      NewMean := Summary.Mean + Delta / Count;
      DeltaAfterMean := Values[I] - NewMean;
      M2 := M2 + Delta * DeltaAfterMean;
      Summary.Mean := NewMean;
      if Values[I] < Summary.Minimum then
        Summary.Minimum := Values[I];
      if Values[I] > Summary.Maximum then
        Summary.Maximum := Values[I];
    end;
    Sum := Sum + Values[I];
  end;

  if not IsFiniteValue(Sum) or not IsFiniteValue(Summary.Mean) or
    not IsFiniteValue(M2) then
    Exit(False);

  Summary.Count := Count;
  Summary.Sum := Sum;
  Summary.PopulationVariance := M2 / Count;
  if Count > 1 then
    Summary.SampleVariance := M2 / (Count - 1)
  else
    Summary.SampleVariance := 0.0;
  Result := True;
end;

function TryMean(const Values: array of Double; out Value: Double): Boolean;
var
  Summary: TStatisticsSummary;
begin
  Result := TrySummary(Values, Summary);
  if Result then
    Value := Summary.Mean
  else
    Value := 0.0;
end;

function TryPopulationVariance(const Values: array of Double;
  out Value: Double): Boolean;
var
  Summary: TStatisticsSummary;
begin
  Result := TrySummary(Values, Summary);
  if Result then
    Value := Summary.PopulationVariance
  else
    Value := 0.0;
end;

function TrySampleVariance(const Values: array of Double;
  out Value: Double): Boolean;
var
  Summary: TStatisticsSummary;
begin
  Result := TrySummary(Values, Summary) and (Summary.Count > 1);
  if Result then
    Value := Summary.SampleVariance
  else
    Value := 0.0;
end;

function TryStandardDeviation(const Values: array of Double;
  Kind: TVarianceKind; out Value: Double): Boolean;
begin
  case Kind of
    vkPopulation:
      Result := TryPopulationVariance(Values, Value);
    vkSample:
      Result := TrySampleVariance(Values, Value);
  else
    Result := False;
  end;
  if Result then
    Value := Sqrt(Value)
  else
    Value := 0.0;
end;

function TryPairedMoments(const X, Y: array of Double; out Count: Integer;
  out M2X, M2Y, CoMoment: Double): Boolean;
var
  I: Integer;
  DeltaX, DeltaY, MeanX, MeanY: Double;
begin
  Count := 0;
  MeanX := 0.0;
  MeanY := 0.0;
  M2X := 0.0;
  M2Y := 0.0;
  CoMoment := 0.0;
  if (Length(X) = 0) or (Length(X) <> Length(Y)) then
    Exit(False);

  for I := Low(X) to High(X) do
  begin
    if not IsFiniteValue(X[I]) or not IsFiniteValue(Y[I]) then
      Exit(False);
    Inc(Count);
    DeltaX := X[I] - MeanX;
    MeanX := MeanX + DeltaX / Count;
    DeltaY := Y[I] - MeanY;
    MeanY := MeanY + DeltaY / Count;
    M2X := M2X + DeltaX * (X[I] - MeanX);
    M2Y := M2Y + DeltaY * (Y[I] - MeanY);
    CoMoment := CoMoment + DeltaX * (Y[I] - MeanY);
  end;
  Result := IsFiniteValue(M2X) and IsFiniteValue(M2Y) and
    IsFiniteValue(CoMoment);
end;

function TryCovariance(const X, Y: array of Double; out Value: Double): Boolean;
var
  Count: Integer;
  M2X, M2Y, CoMoment: Double;
begin
  Result := TryPairedMoments(X, Y, Count, M2X, M2Y, CoMoment);
  if Result then
    Value := CoMoment / Count
  else
    Value := 0.0;
end;

function TryCorrelation(const X, Y: array of Double; out Value: Double): Boolean;
var
  Count: Integer;
  M2X, M2Y, CoMoment, Denominator: Double;
begin
  Result := TryPairedMoments(X, Y, Count, M2X, M2Y, CoMoment) and
    (M2X > 0.0) and (M2Y > 0.0);
  if not Result then
  begin
    Value := 0.0;
    Exit;
  end;
  { Multiplying both moments first can overflow even when the normalized
    correlation is representable. Taking square roots separately preserves
    the same result with a wider usable range. }
  Denominator := Sqrt(M2X) * Sqrt(M2Y);
  Result := IsFiniteValue(Denominator) and (Denominator > 0.0);
  if Result then
    Value := CoMoment / Denominator
  else
    Value := 0.0;
end;

end.
