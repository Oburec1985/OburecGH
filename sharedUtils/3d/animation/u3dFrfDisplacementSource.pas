unit u3dFrfDisplacementSource;

interface

uses
  SysUtils, Math, u3dCoreTypes, u3dContracts;

type
  T3dDoubleArray = array of Double;

  T3dFrfAxisSeries = record
    Amplitude: T3dDoubleArray;
    PhaseDegrees: T3dDoubleArray;
  end;

  T3dFrfPointSeries = record
    X: T3dFrfAxisSeries;
    Y: T3dFrfAxisSeries;
    Z: T3dFrfAxisSeries;
  end;

  T3dFrfDisplacementSource = class(TInterfacedObject,
    I3dDisplacementSource)
  private
    fPoints: array of T3dFrfPointSeries;
    fFrequencyStep: Double;
    fFrequency: Double;
    fPhaseRadians: Double;
    fVersion: Cardinal;
    procedure CopySeries(const ASource: T3dFrfAxisSeries;
      out ADestination: T3dFrfAxisSeries);
    procedure ValidateSeries(const ASource: T3dFrfAxisSeries);
    function SampleAxis(const ASeries: T3dFrfAxisSeries;
      const AFrequency, APhase: Double): Double;
  public
    procedure Configure(const AFrequencyStep: Double;
      const APoints: array of T3dFrfPointSeries);
    procedure SetFrame(const AFrequency, APhaseRadians: Double;
      const AVersion: Cardinal);
    function PointCount: Integer;
    function TryReadDisplacement(const APointIndex: Integer;
      const ATime: Double; out AValue: T3dVector3;
      out AVersion: Cardinal): Boolean;
  end;

implementation

procedure T3dFrfDisplacementSource.CopySeries(
  const ASource: T3dFrfAxisSeries;
  out ADestination: T3dFrfAxisSeries);
var
  lCount: Integer;
begin
  lCount := Length(ASource.Amplitude);
  SetLength(ADestination.Amplitude, lCount);
  SetLength(ADestination.PhaseDegrees, lCount);
  if lCount > 0 then
  begin
    Move(ASource.Amplitude[0], ADestination.Amplitude[0],
      lCount * SizeOf(Double));
    Move(ASource.PhaseDegrees[0], ADestination.PhaseDegrees[0],
      lCount * SizeOf(Double));
  end;
end;

procedure T3dFrfDisplacementSource.ValidateSeries(
  const ASource: T3dFrfAxisSeries);
begin
  if Length(ASource.Amplitude) <> Length(ASource.PhaseDegrees) then
    raise EArgumentException.Create('FRF amplitude and phase sizes differ');
end;

procedure T3dFrfDisplacementSource.Configure(
  const AFrequencyStep: Double;
  const APoints: array of T3dFrfPointSeries);
var
  lIndex: Integer;
begin
  if AFrequencyStep <= 0 then
    raise EArgumentException.Create('FRF frequency step must be positive');
  for lIndex := 0 to High(APoints) do
  begin
    ValidateSeries(APoints[lIndex].X);
    ValidateSeries(APoints[lIndex].Y);
    ValidateSeries(APoints[lIndex].Z);
  end;
  fFrequencyStep := AFrequencyStep;
  SetLength(fPoints, Length(APoints));
  for lIndex := 0 to High(APoints) do
  begin
    CopySeries(APoints[lIndex].X, fPoints[lIndex].X);
    CopySeries(APoints[lIndex].Y, fPoints[lIndex].Y);
    CopySeries(APoints[lIndex].Z, fPoints[lIndex].Z);
  end;
end;

procedure T3dFrfDisplacementSource.SetFrame(const AFrequency,
  APhaseRadians: Double; const AVersion: Cardinal);
begin
  fFrequency := AFrequency;
  fPhaseRadians := APhaseRadians;
  fVersion := AVersion;
end;

function T3dFrfDisplacementSource.PointCount: Integer;
begin
  Result := Length(fPoints);
end;

function T3dFrfDisplacementSource.SampleAxis(
  const ASeries: T3dFrfAxisSeries; const AFrequency,
  APhase: Double): Double;
var
  lAmplitude: Double;
  lFraction: Double;
  lPhaseDegrees: Double;
  lPhaseDelta: Double;
  lIndex: Integer;
  lCount: Integer;
begin
  Result := 0;
  lCount := Length(ASeries.Amplitude);
  if lCount = 0 then
    Exit;
  if lCount = 1 then
  begin
    lAmplitude := ASeries.Amplitude[0];
    lPhaseDegrees := ASeries.PhaseDegrees[0];
  end
  else
  begin
    lIndex := Trunc(AFrequency / fFrequencyStep);
    if lIndex < 0 then
      lIndex := 0;
    if lIndex >= lCount - 1 then
      lIndex := lCount - 2;
    lFraction := (AFrequency - lIndex * fFrequencyStep) /
      fFrequencyStep;
    if lFraction < 0 then
      lFraction := 0
    else if lFraction > 1 then
      lFraction := 1;
    lAmplitude := ASeries.Amplitude[lIndex] +
      (ASeries.Amplitude[lIndex + 1] - ASeries.Amplitude[lIndex]) *
      lFraction;
    lPhaseDelta := ASeries.PhaseDegrees[lIndex + 1] -
      ASeries.PhaseDegrees[lIndex];
    while lPhaseDelta > 180 do
      lPhaseDelta := lPhaseDelta - 360;
    while lPhaseDelta < -180 do
      lPhaseDelta := lPhaseDelta + 360;
    lPhaseDegrees := ASeries.PhaseDegrees[lIndex] +
      lPhaseDelta * lFraction;
  end;
  Result := lAmplitude * Sin(DegToRad(lPhaseDegrees) + APhase);
end;

function T3dFrfDisplacementSource.TryReadDisplacement(
  const APointIndex: Integer; const ATime: Double;
  out AValue: T3dVector3; out AVersion: Cardinal): Boolean;
begin
  Result := (APointIndex >= 0) and (APointIndex < Length(fPoints));
  if not Result then
    Exit;
  AValue.X := SampleAxis(fPoints[APointIndex].X, fFrequency,
    fPhaseRadians);
  AValue.Y := SampleAxis(fPoints[APointIndex].Y, fFrequency,
    fPhaseRadians);
  AValue.Z := SampleAxis(fPoints[APointIndex].Z, fFrequency,
    fPhaseRadians);
  AVersion := fVersion;
end;

end.
