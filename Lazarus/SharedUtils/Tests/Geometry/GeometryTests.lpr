program GeometryTests;

{$mode delphi}{$H+}

uses
  SysUtils, Math, uCommonTypes, u2DMath;

function Pt(const X, Y: Single): point2;
begin
  Result.X := X;
  Result.Y := Y;
end;

procedure Check(Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

procedure CheckPoint(const Actual, Expected: point2; const MessageText: string);
begin
  Check((Actual.X = Expected.X) and (Actual.Y = Expected.Y), MessageText);
end;

procedure CheckHullPoint(const Hull: TPointArray; const Expected: point2;
  const MessageText: string);
var
  I: Integer;
begin
  for I := 0 to High(Hull) do
    if (Hull[I].X = Expected.X) and (Hull[I].Y = Expected.Y) then
      Exit;
  Check(False, MessageText);
end;

procedure TestEmptyAndCountClamping;
var
  Points, Hull: TPointArray;
  Diameter: TDiameterResult;
begin
  Points := nil;
  Hull := GrahamScanWithDiameter(Points, 1, Diameter);
  Check(Length(Hull) = 0, 'empty hull');
  Check((Diameter.Index1 = -1) and (Diameter.Index2 = -1), 'empty indices');
  Check(Diameter.Distance = 0, 'empty diameter');

  SetLength(Points, 1);
  Points[0] := Pt(2, 3);
  Hull := GrahamScanWithDiameter(Points, -5, Diameter);
  Check(Length(Hull) = 0, 'negative count is clamped to zero');
  Hull := GrahamScanWithDiameter(Points, 10, Diameter);
  Check(Length(Hull) = 1, 'oversized count is clamped to length');
end;

procedure TestOneAndTwoPoints;
var
  Points, Hull: TPointArray;
  Diameter: TDiameterResult;
begin
  SetLength(Points, 1);
  Points[0] := Pt(4, 5);
  Hull := GrahamScanWithDiameter(Points, Length(Points), Diameter);
  Check(Length(Hull) = 1, 'one point hull');
  Check((Diameter.Index1 = 0) and (Diameter.Index2 = 0), 'one point indices');
  CheckPoint(Diameter.Point1, Points[0], 'one point diameter endpoint');

  SetLength(Points, 2);
  Points[0] := Pt(3, 4);
  Points[1] := Pt(0, 0);
  Hull := GrahamScanWithDiameter(Points, Length(Points), Diameter);
  Check(Length(Hull) = 2, 'two point hull');
  Check(Abs(Diameter.Distance - 5) < 1E-9, 'two point diameter');
end;

procedure TestCollinearAndDuplicates;
var
  Points, Hull: TPointArray;
  Diameter: TDiameterResult;
begin
  SetLength(Points, 7);
  Points[0] := Pt(2, 2);
  Points[1] := Pt(0, 0);
  Points[2] := Pt(1, 1);
  Points[3] := Pt(3, 3);
  Points[4] := Pt(1, 1);
  Points[5] := Pt(0, 0);
  Points[6] := Pt(2, 2);
  Hull := GrahamScanWithDiameter(Points, Length(Points), Diameter);
  Check(Length(Hull) = 2, 'collinear hull has endpoints only');
  CheckPoint(Hull[0], Pt(0, 0), 'collinear first endpoint');
  CheckPoint(Hull[1], Pt(3, 3), 'collinear last endpoint');
  Check(Abs(Diameter.Distance - Sqrt(18)) < 1E-9, 'collinear diameter');
end;

procedure TestShuffledSquareAndConcavePoint;
var
  Points, Hull: TPointArray;
  Diameter: TDiameterResult;
begin
  SetLength(Points, 8);
  Points[0] := Pt(1, 1);
  Points[1] := Pt(0, 0);
  Points[2] := Pt(2, 2);
  Points[3] := Pt(2, 0);
  Points[4] := Pt(0, 2);
  Points[5] := Pt(1, 0.5);
  Points[6] := Pt(2, 2);
  Points[7] := Pt(0, 0);
  Hull := GrahamScanWithDiameter(Points, Length(Points), Diameter);
  Check(Length(Hull) = 4, 'square hull excludes concave and duplicate points');
  CheckHullPoint(Hull, Pt(0, 0), 'square lower-left');
  CheckHullPoint(Hull, Pt(2, 0), 'square lower-right');
  CheckHullPoint(Hull, Pt(2, 2), 'square upper-right');
  CheckHullPoint(Hull, Pt(0, 2), 'square upper-left');
  Check(Abs(Diameter.Distance - Sqrt(8)) < 1E-9, 'square diameter');
  CheckPoint(Diameter.Point1, Hull[Diameter.Index1], 'diameter index 1');
  CheckPoint(Diameter.Point2, Hull[Diameter.Index2], 'diameter index 2');
end;

begin
  TestEmptyAndCountClamping;
  TestOneAndTwoPoints;
  TestCollinearAndDuplicates;
  TestShuffledSquareAndConcavePoint;
  WriteLn('Geometry tests passed');
end.
