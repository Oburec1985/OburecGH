unit uRecorderFrfSnapshot;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Immutable FRF data source for consumers that need frequency interpolation
  without knowing Recorder tags. A producer fills a new instance, then
  publishes it through IRecorderFrfSampler; interface lifetime owns it. }

interface

uses
  uRecorderFrfContracts;

type
  TRecorderFrfPoint = record
    FrequencyHz: Double;
    Magnitude: Double;
    PhaseRadians: Double;
  end;

  TRecorderFrfCurve = record
    Id: QWord;
    Points: array of TRecorderFrfPoint;
  end;

  { A configured snapshot is read-only and safe to publish to consumers. }
  TRecorderLegacyFrfSnapshot = class(TInterfacedObject, IRecorderFrfSampler)
  private
    fCurves: array of TRecorderFrfCurve;
    fVersion: QWord;
    function FindCurve(AId: QWord): Integer;
  public
    constructor Create(AVersion: QWord);
    procedure AddCurve(AId: QWord; const APoints: array of TRecorderFrfPoint);
    function TrySample(ACurveId: QWord; AFrequencyHz: Double;
      out AMagnitude, APhaseRadians: Double): Boolean;
    function Version: QWord;
  end;

implementation

uses
  SysUtils, Math;

constructor TRecorderLegacyFrfSnapshot.Create(AVersion: QWord);
begin
  inherited Create;
  fVersion := AVersion;
end;

function TRecorderLegacyFrfSnapshot.FindCurve(AId: QWord): Integer;
begin
  for Result := 0 to High(fCurves) do
    if fCurves[Result].Id = AId then
      Exit;
  Result := -1;
end;

procedure TRecorderLegacyFrfSnapshot.AddCurve(AId: QWord;
  const APoints: array of TRecorderFrfPoint);
var
  lCurve, lIndex: Integer;
begin
  if AId = 0 then
    raise EArgumentException.Create('FRF curve ID must be non-zero');
  if FindCurve(AId) >= 0 then
    raise EArgumentException.CreateFmt('Duplicate FRF curve ID %d', [AId]);
  lCurve := Length(fCurves);
  SetLength(fCurves, lCurve + 1);
  fCurves[lCurve].Id := AId;
  SetLength(fCurves[lCurve].Points, Length(APoints));
  for lIndex := 0 to High(APoints) do
  begin
    if (lIndex > 0) and
      (APoints[lIndex].FrequencyHz <= APoints[lIndex-1].FrequencyHz) then
      raise EArgumentException.Create('FRF frequencies must be strictly increasing');
    fCurves[lCurve].Points[lIndex] := APoints[lIndex];
  end;
end;

function TRecorderLegacyFrfSnapshot.TrySample(ACurveId: QWord;
  AFrequencyHz: Double; out AMagnitude, APhaseRadians: Double): Boolean;
var
  lCurve, lLow, lHigh, lMiddle: Integer;
  lRatio, lPhaseDelta: Double;
begin
  Result := False;
  lCurve := FindCurve(ACurveId);
  if (lCurve < 0) or (Length(fCurves[lCurve].Points) = 0) or
    IsNan(AFrequencyHz) or IsInfinite(AFrequencyHz) then
    Exit;
  lLow := 0;
  lHigh := High(fCurves[lCurve].Points);
  if (AFrequencyHz < fCurves[lCurve].Points[lLow].FrequencyHz) or
    (AFrequencyHz > fCurves[lCurve].Points[lHigh].FrequencyHz) then
    Exit;
  while lLow < lHigh do
  begin
    lMiddle := (lLow + lHigh) div 2;
    if fCurves[lCurve].Points[lMiddle].FrequencyHz < AFrequencyHz then
      lLow := lMiddle + 1
    else
      lHigh := lMiddle;
  end;
  if fCurves[lCurve].Points[lLow].FrequencyHz = AFrequencyHz then
  begin
    AMagnitude := fCurves[lCurve].Points[lLow].Magnitude;
    APhaseRadians := fCurves[lCurve].Points[lLow].PhaseRadians;
    Exit(True);
  end;
  lHigh := lLow;
  Dec(lLow);
  lRatio := (AFrequencyHz-fCurves[lCurve].Points[lLow].FrequencyHz) /
    (fCurves[lCurve].Points[lHigh].FrequencyHz-
     fCurves[lCurve].Points[lLow].FrequencyHz);
  AMagnitude := fCurves[lCurve].Points[lLow].Magnitude + lRatio *
    (fCurves[lCurve].Points[lHigh].Magnitude-
     fCurves[lCurve].Points[lLow].Magnitude);
  lPhaseDelta := ArcTan2(
    Sin(fCurves[lCurve].Points[lHigh].PhaseRadians-
      fCurves[lCurve].Points[lLow].PhaseRadians),
    Cos(fCurves[lCurve].Points[lHigh].PhaseRadians-
      fCurves[lCurve].Points[lLow].PhaseRadians));
  APhaseRadians := fCurves[lCurve].Points[lLow].PhaseRadians +
    lRatio*lPhaseDelta;
  Result := True;
end;

function TRecorderLegacyFrfSnapshot.Version: QWord;
begin
  Result := fVersion;
end;

end.
