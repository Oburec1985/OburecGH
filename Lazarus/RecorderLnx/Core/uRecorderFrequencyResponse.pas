unit uRecorderFrequencyResponse;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math;

type
  TRecorderFrequencyResponseMergeMode = (frmmReplace, frmmMaximum, frmmAverage);

  TRecorderFrequencyResponsePoint = record
    FrequencyHz: Double;
    Value: Double;
    SampleCount: Cardinal;
    Valid: Boolean;
  end;

  { Fixed-capacity frequency-domain accumulator. Configure performs every
    allocation; AddPoint only maps and merges a point in-place. }
  TRecorderFrequencyResponseBuffer = class
  private
    fPoints: array of TRecorderFrequencyResponsePoint;
    fMinFrequencyHz: Double;
    fMaxFrequencyHz: Double;
    fUniformX: Boolean;
    fFrequencyStepHz: Double;
    fMergeMode: TRecorderFrequencyResponseMergeMode;
    fCount: Integer;
    function GetCapacity: Integer;
    function FindNearestIndex(AFrequencyHz: Double): Integer;
    function FindInsertIndex(AFrequencyHz: Double): Integer;
    procedure MergePoint(AIndex: Integer; AFrequencyHz, AValue: Double);
  public
    procedure Configure(AMinFrequencyHz, AMaxFrequencyHz: Double;
      ACapacity: Integer; AUniformX: Boolean; AFrequencyStepHz: Double;
      AMergeMode: TRecorderFrequencyResponseMergeMode);
    procedure Clear;
    function AddPoint(AFrequencyHz, AValue: Double): Boolean;
    function Point(AIndex: Integer): TRecorderFrequencyResponsePoint;
    property Count: Integer read fCount;
    property Capacity: Integer read GetCapacity;
  end;

implementation

function TRecorderFrequencyResponseBuffer.GetCapacity: Integer;
begin
  Result := Length(fPoints);
end;

procedure TRecorderFrequencyResponseBuffer.Configure(AMinFrequencyHz,
  AMaxFrequencyHz: Double; ACapacity: Integer; AUniformX: Boolean;
  AFrequencyStepHz: Double; AMergeMode: TRecorderFrequencyResponseMergeMode);
begin
  if AMaxFrequencyHz <= AMinFrequencyHz then
    raise EArgumentException.Create('Maximum frequency must exceed minimum frequency');
  if ACapacity < 1 then
    raise EArgumentException.Create('Frequency response capacity must be positive');
  if AUniformX and (AFrequencyStepHz <= 0.0) then
    raise EArgumentException.Create('Uniform frequency step must be positive');
  fMinFrequencyHz := AMinFrequencyHz;
  fMaxFrequencyHz := AMaxFrequencyHz;
  fUniformX := AUniformX;
  fFrequencyStepHz := AFrequencyStepHz;
  fMergeMode := AMergeMode;
  SetLength(fPoints, ACapacity);
  Clear;
end;

procedure TRecorderFrequencyResponseBuffer.Clear;
begin
  fCount := 0;
  if Length(fPoints) > 0 then
    FillChar(fPoints[0], Length(fPoints) * SizeOf(fPoints[0]), 0);
end;

function TRecorderFrequencyResponseBuffer.FindNearestIndex(
  AFrequencyHz: Double): Integer;
var
  lIndex: Integer;
  lTolerance: Double;
begin
  Result := -1;
  if fCount = 0 then Exit;
  if fUniformX then
  begin
    lIndex := Round((AFrequencyHz - fMinFrequencyHz) / fFrequencyStepHz);
    if (lIndex >= 0) and (lIndex < fCount) and fPoints[lIndex].Valid then
      Exit(lIndex);
    Exit;
  end;
  lIndex := FindInsertIndex(AFrequencyHz);
  lTolerance := Max(1.0, Abs(AFrequencyHz)) * 1E-9;
  if (lIndex < fCount) and
    (Abs(fPoints[lIndex].FrequencyHz - AFrequencyHz) <= lTolerance) then
    Exit(lIndex);
  if (lIndex > 0) and
    (Abs(fPoints[lIndex - 1].FrequencyHz - AFrequencyHz) <= lTolerance) then
    Exit(lIndex - 1);
end;

function TRecorderFrequencyResponseBuffer.FindInsertIndex(
  AFrequencyHz: Double): Integer;
var
  lLow, lHigh, lMid: Integer;
begin
  lLow := 0;
  lHigh := fCount;
  while lLow < lHigh do
  begin
    lMid := (lLow + lHigh) div 2;
    if fPoints[lMid].FrequencyHz < AFrequencyHz then
      lLow := lMid + 1
    else
      lHigh := lMid;
  end;
  Result := lLow;
end;

procedure TRecorderFrequencyResponseBuffer.MergePoint(AIndex: Integer;
  AFrequencyHz, AValue: Double);
begin
  case fMergeMode of
    frmmReplace:
      fPoints[AIndex].Value := AValue;
    frmmMaximum:
      if Abs(AValue) > Abs(fPoints[AIndex].Value) then
        fPoints[AIndex].Value := AValue;
    frmmAverage:
      fPoints[AIndex].Value := fPoints[AIndex].Value +
        (AValue - fPoints[AIndex].Value) / (fPoints[AIndex].SampleCount + 1);
  end;
  fPoints[AIndex].FrequencyHz := AFrequencyHz;
  Inc(fPoints[AIndex].SampleCount);
end;

function TRecorderFrequencyResponseBuffer.AddPoint(AFrequencyHz,
  AValue: Double): Boolean;
var
  I, lIndex: Integer;
  lFrequencyHz: Double;
begin
  Result := False;
  if IsNan(AFrequencyHz) or IsInfinite(AFrequencyHz) or IsNan(AValue) or
    IsInfinite(AValue) or (AFrequencyHz < fMinFrequencyHz) or
    (AFrequencyHz > fMaxFrequencyHz) then Exit;
  if fUniformX then
  begin
    lIndex := Round((AFrequencyHz - fMinFrequencyHz) / fFrequencyStepHz);
    if (lIndex < 0) or (lIndex >= Length(fPoints)) then Exit;
    lFrequencyHz := fMinFrequencyHz + lIndex * fFrequencyStepHz;
    if fPoints[lIndex].Valid then
      MergePoint(lIndex, lFrequencyHz, AValue)
    else
    begin
      fPoints[lIndex].FrequencyHz := lFrequencyHz;
      fPoints[lIndex].Value := AValue;
      fPoints[lIndex].SampleCount := 1;
      fPoints[lIndex].Valid := True;
      if lIndex >= fCount then fCount := lIndex + 1;
    end;
    Exit(True);
  end;
  lIndex := FindNearestIndex(AFrequencyHz);
  if lIndex >= 0 then
  begin
    MergePoint(lIndex, AFrequencyHz, AValue);
    Exit(True);
  end;
  if fCount >= Length(fPoints) then Exit;
  lIndex := FindInsertIndex(AFrequencyHz);
  for I := fCount downto lIndex + 1 do
    fPoints[I] := fPoints[I - 1];
  fPoints[lIndex].FrequencyHz := AFrequencyHz;
  fPoints[lIndex].Value := AValue;
  fPoints[lIndex].SampleCount := 1;
  fPoints[lIndex].Valid := True;
  Inc(fCount);
  Result := True;
end;

function TRecorderFrequencyResponseBuffer.Point(
  AIndex: Integer): TRecorderFrequencyResponsePoint;
begin
  if (AIndex < 0) or (AIndex >= fCount) then
    raise ERangeError.CreateFmt('Frequency response point index %d is out of range',
      [AIndex]);
  Result := fPoints[AIndex];
end;

end.
