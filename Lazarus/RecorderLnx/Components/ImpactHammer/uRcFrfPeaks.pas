unit uRcFrfPeaks;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

type
  TRcPeak = record
    Curve: string;
    Index: Integer;
    Frequency: Double;
    Value: Double;
    Decrement: Double;
  end;
  TRcPeaks = array of TRcPeak;
  TRcDoubles = array of Double;

{ Ищет завершённые пики выше порога. AX — частоты, AY — значения кривой той же
  длины; AMinFrequency/AMaxFrequency ограничивают AX, когда max больше min.
  Найденные пики с именем ACurve дописываются в массив APeaks. }
procedure FindRcPeaks(const AX, AY: TRcDoubles; AThreshold: Double;
  const ACurve: string; var APeaks: TRcPeaks;
  AMinFrequency: Double = 0; AMaxFrequency: Double = 0);

implementation

uses Math;

{ Считает декремент пика по ширине кривой на половине его амплитуды;
  AX и AY — частоты и значения, APeak — индекс вершины. }
function HalfWidth(const AX, AY: TRcDoubles; APeak: Integer): Double;
var
  lLeft, lRight: Integer;
  lHalf, lLx, lRx: Double;
begin
  Result := -1;
  if (APeak <= 0) or (APeak >= High(AY)) or (AX[APeak] <= 0) then Exit;
  lHalf := AY[APeak] * 0.5;
  lLeft := APeak;
  while (lLeft > 0) and (AY[lLeft] > lHalf) do Dec(lLeft);
  lRight := APeak;
  while (lRight < High(AY)) and (AY[lRight] > lHalf) do Inc(lRight);
  if (AY[lLeft] > lHalf) or (AY[lRight] > lHalf) or
     SameValue(AY[lLeft + 1], AY[lLeft]) or
     SameValue(AY[lRight], AY[lRight - 1]) then Exit;
  lLx := AX[lLeft] + (lHalf - AY[lLeft]) *
    (AX[lLeft + 1] - AX[lLeft]) / (AY[lLeft + 1] - AY[lLeft]);
  lRx := AX[lRight - 1] + (lHalf - AY[lRight - 1]) *
    (AX[lRight] - AX[lRight - 1]) / (AY[lRight] - AY[lRight - 1]);
  Result := (lRx - lLx) / (2 * AX[APeak]);
end;

{ Ищет завершённые пики выше AThreshold на частотной сетке AX и дописывает
  результат в APeaks; AY содержит значения кривой ACurve. }
procedure FindRcPeaks(const AX, AY: TRcDoubles; AThreshold: Double;
  const ACurve: string; var APeaks: TRcPeaks;
  AMinFrequency: Double; AMaxFrequency: Double);
var
  lI, lTop, lCount, lCapacity: Integer;
  lInside: Boolean;
  lValue: Double;
begin
  if (AThreshold <= 0) or (Length(AX) <> Length(AY)) or
     (Length(AY) < 3) then Exit;
  lInside := False;
  lTop := -1;
  lCount := Length(APeaks);
  lCapacity := lCount;
  for lI := 1 to High(AY) do
  begin
    if (AX[lI] < AMinFrequency) or
       ((AMaxFrequency > AMinFrequency) and (AX[lI] > AMaxFrequency)) then
    begin
      lInside := False;
      Continue;
    end;
    lValue := AY[lI];
    if IsNan(lValue) or IsInfinite(lValue) then
    begin
      lInside := False;
      Continue;
    end;
    if not lInside then
    begin
      if (AX[lI - 1] >= AMinFrequency) and
         (AY[lI - 1] <= AThreshold) and (lValue > AThreshold) then
      begin
        lInside := True;
        lTop := lI;
      end;
      Continue;
    end;
    if lValue > AY[lTop] then lTop := lI;
    if lValue > AThreshold then Continue;
    { Требуются оба пересечения порога и высота более чем на один процент выше
      линии; это отсекает мелкие колебания вокруг порога. }
    if AY[lTop] > AThreshold * 1.01 then
    begin
      if lCount >= lCapacity then
      begin
        lCapacity := Max(16, lCapacity * 2);
        SetLength(APeaks, lCapacity);
      end;
      APeaks[lCount].Curve := ACurve;
      APeaks[lCount].Index := lTop;
      APeaks[lCount].Frequency := AX[lTop];
      APeaks[lCount].Value := AY[lTop];
      APeaks[lCount].Decrement := HalfWidth(AX, AY, lTop);
      Inc(lCount);
    end;
    lInside := False;
  end;
  SetLength(APeaks, lCount);
end;

end.
