program SharedStatisticsTest;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, uSharedStatistics;

type
  TDoubleArray = array of Double;

var
  TestCount: Integer = 0;

procedure Fail(const MessageText: String);
begin
  WriteLn(StdErr, 'FAILED: ', MessageText);
  Halt(1);
end;

procedure Check(Condition: Boolean; const MessageText: String);
begin
  Inc(TestCount);
  if not Condition then
    Fail(MessageText);
end;

procedure CheckNear(Actual, Expected, Tolerance: Double;
  const MessageText: String);
begin
  Check(Abs(Actual - Expected) <= Tolerance,
    Format('%s: expected %.15g, got %.15g', [MessageText, Expected, Actual]));
end;

procedure TestSummary;
var
  Values: array[0..3] of Double = (1.0, 2.0, 3.0, 4.0);
  Summary: TStatisticsSummary;
begin
  Check(TrySummary(Values, Summary), 'summary succeeds');
  Check(Summary.Count = 4, 'summary count');
  CheckNear(Summary.Sum, 10.0, 1E-12, 'summary sum');
  CheckNear(Summary.Mean, 2.5, 1E-12, 'summary mean');
  CheckNear(Summary.Minimum, 1.0, 1E-12, 'summary minimum');
  CheckNear(Summary.Maximum, 4.0, 1E-12, 'summary maximum');
  CheckNear(Summary.PopulationVariance, 1.25, 1E-12, 'population variance');
  CheckNear(Summary.SampleVariance, Double(5) / 3, 1E-12, 'sample variance');
end;

procedure TestInvalidInputs;
var
  Empty: TDoubleArray;
  One: array[0..0] of Double = (7.0);
  InvalidNan: array[0..1] of Double;
  InvalidInf: array[0..1] of Double;
  Other: array[0..1] of Double = (1.0, 2.0);
  Value: Double;
  Summary: TStatisticsSummary;
begin
  Empty := nil;
  Check(not TrySummary(Empty, Summary), 'empty summary rejected');
  Check(TryMean(One, Value), 'single mean succeeds');
  CheckNear(Value, 7.0, 0.0, 'single mean');
  Check(TryPopulationVariance(One, Value), 'single population variance succeeds');
  CheckNear(Value, 0.0, 0.0, 'single population variance');
  Check(not TrySampleVariance(One, Value), 'single sample variance rejected');
  InvalidNan[0] := 1.0;
  InvalidNan[1] := NaN;
  InvalidInf[0] := 1.0;
  InvalidInf[1] := Infinity;
  Check(not TryMean(InvalidNan, Value), 'NaN rejected');
  Check(not TryMean(InvalidInf, Value), 'infinity rejected');
  Check(not TryCovariance(One, Other, Value), 'mismatched lengths rejected');
end;

procedure TestStableMoments;
var
  Values: array[0..3] of Double =
    (1000000000001.0, 1000000000002.0, 1000000000003.0, 1000000000004.0);
  Value: Double;
begin
  Check(TryPopulationVariance(Values, Value), 'large-offset variance succeeds');
  CheckNear(Value, 1.25, 1E-12, 'large-offset variance');
  Check(TryStandardDeviation(Values, vkPopulation, Value),
    'population standard deviation succeeds');
  CheckNear(Value, Sqrt(1.25), 1E-12, 'population standard deviation');
  Check(TryStandardDeviation(Values, vkSample, Value),
    'sample standard deviation succeeds');
  CheckNear(Value, Sqrt(Double(5) / 3), 1E-12, 'sample standard deviation');
end;

procedure TestPairedStatistics;
var
  X: array[0..3] of Double = (1.0, 2.0, 3.0, 4.0);
  Same: array[0..3] of Double = (1.0, 2.0, 3.0, 4.0);
  Reverse: array[0..3] of Double = (4.0, 3.0, 2.0, 1.0);
  ConstantValues: array[0..3] of Double = (2.0, 2.0, 2.0, 2.0);
  Value: Double;
begin
  Check(TryCovariance(X, Same, Value), 'covariance succeeds');
  CheckNear(Value, 1.25, 1E-12, 'population covariance');
  Check(TryCorrelation(X, Same, Value), 'positive correlation succeeds');
  CheckNear(Value, 1.0, 1E-12, 'positive correlation');
  Check(TryCorrelation(X, Reverse, Value), 'negative correlation succeeds');
  CheckNear(Value, -1.0, 1E-12, 'negative correlation');
  Check(not TryCorrelation(X, ConstantValues, Value),
    'constant correlation rejected');
end;

begin
  TestSummary;
  TestInvalidInputs;
  TestStableMoments;
  TestPairedStatistics;
  WriteLn('PASSED: ', TestCount, ' checks');
end.
