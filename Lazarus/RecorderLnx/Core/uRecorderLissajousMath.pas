unit uRecorderLissajousMath;

{$mode objfpc}{$H+}

interface

uses uRecorderTags;

procedure BuildLissajousPairs(const AXTimes, AXValues, AYTimes, AYValues:
  TRecorderDoubleArray; AXCount, AYCount: Integer;
  var AOutX, AOutY: TRecorderDoubleArray; out ACount: Integer);
function CalculateLissajousMainDiameter(const AX, AY: TRecorderDoubleArray;
  ACount: Integer; out AX1, AY1, AX2, AY2, ACenterX, ACenterY,
  ADiameter: Double): Boolean;

implementation

uses Math, uCommonTypes, u2DMath;

procedure BuildLissajousPairs(const AXTimes, AXValues, AYTimes, AYValues:
  TRecorderDoubleArray; AXCount, AYCount: Integer;
  var AOutX, AOutY: TRecorderDoubleArray; out ACount: Integer);
var
  I, J, lCapacity: Integer;
  lStartTime, lEndTime, lTime, lPart: Double;
begin
  ACount := 0;
  if (AXCount < 1) or (AYCount < 2) then Exit;
  lStartTime := Max(AXTimes[0], AYTimes[0]);
  lEndTime := Min(AXTimes[AXCount - 1], AYTimes[AYCount - 1]);
  if lEndTime < lStartTime then Exit;
  { Y is interpolated at every X timestamp, so the output may contain up to
    AXCount points even when Y has fewer samples. }
  lCapacity := AXCount;
  if Length(AOutX) < lCapacity then SetLength(AOutX, lCapacity);
  if Length(AOutY) < lCapacity then SetLength(AOutY, lCapacity);
  I := 0; J := 1;
  while (I < AXCount) and (AXTimes[I] < lStartTime) do Inc(I);
  while (I < AXCount) and (AXTimes[I] <= lEndTime) do
  begin
    lTime := AXTimes[I];
    while (J < AYCount) and (AYTimes[J] < lTime) do Inc(J);
    if J >= AYCount then Break;
    AOutX[ACount] := AXValues[I];
    if AYTimes[J] = AYTimes[J - 1] then AOutY[ACount] := AYValues[J]
    else begin
      lPart := (lTime - AYTimes[J - 1]) / (AYTimes[J] - AYTimes[J - 1]);
      AOutY[ACount] := AYValues[J - 1] + lPart * (AYValues[J] - AYValues[J - 1]);
    end;
    Inc(ACount); Inc(I);
  end;
end;

function CalculateLissajousMainDiameter(const AX, AY: TRecorderDoubleArray;
  ACount: Integer; out AX1, AY1, AX2, AY2, ACenterX, ACenterY,
  ADiameter: Double): Boolean;
var
  I: Integer;
  lPoints, lHull: TPointArray;
  lDiameter: TDiameterResult;
begin
  Result := False;
  if (ACount < 2) or (Length(AX) < ACount) or (Length(AY) < ACount) then Exit;
  SetLength(lPoints, ACount);
  for I := 0 to ACount - 1 do
  begin
    lPoints[I].X := AX[I];
    lPoints[I].Y := AY[I];
  end;
  lHull := GrahamScanWithDiameter(lPoints, ACount, lDiameter);
  if (Length(lHull) = 0) or (lDiameter.Index1 < 0) or
     (lDiameter.Index2 < 0) or (lDiameter.Distance <= 0) then Exit;
  AX1 := lDiameter.Point1.X;
  AY1 := lDiameter.Point1.Y;
  AX2 := lDiameter.Point2.X;
  AY2 := lDiameter.Point2.Y;
  ACenterX := (AX1 + AX2) * 0.5;
  ACenterY := (AY1 + AY2) * 0.5;
  ADiameter := lDiameter.Distance;
  Result := True;
end;

end.
