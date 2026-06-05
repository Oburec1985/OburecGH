unit uSharedAlgorithms;

{$mode objfpc}{$H+}

interface

type
  { Generic class for binary search on sorted types supporting direct comparison operators }
  generic TBinarySearch<T> = class
  public
    type
      TArrayType = array of T;
    
    class function FindFirstGreater(constref AArray: TArrayType; ALength: Integer; const AValue: T): Integer;
    class function FindFirstGreaterOrEqual(constref AArray: TArrayType; ALength: Integer; const AValue: T): Integer;
  end;

implementation

class function TBinarySearch.FindFirstGreater(constref AArray: TArrayType; ALength: Integer; const AValue: T): Integer;
var
  lLow, lHigh, lMid: Integer;
begin
  lLow := 0;
  lHigh := ALength - 1;
  Result := ALength;
  while lLow <= lHigh do
  begin
    lMid := lLow + (lHigh - lLow) div 2;
    if AArray[lMid] > AValue then
    begin
      Result := lMid;
      lHigh := lMid - 1;
    end
    else
      lLow := lMid + 1;
  end;
end;

class function TBinarySearch.FindFirstGreaterOrEqual(constref AArray: TArrayType; ALength: Integer; const AValue: T): Integer;
var
  lLow, lHigh, lMid: Integer;
begin
  lLow := 0;
  lHigh := ALength - 1;
  Result := ALength;
  while lLow <= lHigh do
  begin
    lMid := lLow + (lHigh - lLow) div 2;
    if AArray[lMid] >= AValue then
    begin
      Result := lMid;
      lHigh := lMid - 1;
    end
    else
      lLow := lMid + 1;
  end;
end;

end.
