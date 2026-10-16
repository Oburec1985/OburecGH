unit uModbusPlanner;

{$mode objfpc}{$H+}

// Deterministic configuration-time planner. It groups only compatible tags
// from one unit/region and splits requests at Modbus protocol limits.
interface

uses
  Classes, SysUtils, uModbusCoreTypes;

type
  TModbusPlanItem = record
    UnitId: Byte;
    Region: TModbusRegion;
    FunctionCode: Byte;
    StartAddress: Word;
    Count: Word;
    FirstTagIndex: Integer;
    TagCount: Integer;
  end;
  TModbusPlan = array of TModbusPlanItem;

procedure BuildReadPlan(ADevice: TModbusDeviceConfig; out APlan: TModbusPlan);

implementation

type
  TTagRef = record
    Tag: TModbusTagConfig;
    OriginalIndex: Integer;
  end;
  TTagRefs = array of TTagRef;

function FunctionForRegion(ARegion: TModbusRegion): Byte;
begin
  case ARegion of
    mrCoil: Result := 1;
    mrDiscreteInput: Result := 2;
    mrInputRegister: Result := 4;
    mrHoldingRegister: Result := 3;
  end;
end;

function LimitForRegion(ARegion: TModbusRegion): Word;
begin
  if ARegion in [mrCoil, mrDiscreteInput] then Result := 2000 else Result := 125;
end;

function CompareTags(const A, B: TTagRef): Integer;
begin
  Result := Ord(A.Tag.Region) - Ord(B.Tag.Region);
  if Result = 0 then Result := Integer(A.Tag.Address) - Integer(B.Tag.Address);
  if Result = 0 then Result := A.OriginalIndex - B.OriginalIndex;
end;

procedure SortRefs(var ARefs: TTagRefs);
var
  lI, lJ: Integer;
  lValue: TTagRef;
begin
  for lI := 1 to High(ARefs) do begin
    lValue := ARefs[lI];
    lJ := lI - 1;
    while (lJ >= 0) and (CompareTags(ARefs[lJ], lValue) > 0) do begin
      ARefs[lJ + 1] := ARefs[lJ]; Dec(lJ);
    end;
    ARefs[lJ + 1] := lValue;
  end;
end;

procedure AppendItem(var APlan: TModbusPlan; AUnitId: Byte; const ARef: TTagRef);
var
  lIndex: Integer;
begin
  lIndex := Length(APlan);
  SetLength(APlan, lIndex + 1);
  APlan[lIndex].UnitId := AUnitId;
  APlan[lIndex].Region := ARef.Tag.Region;
  APlan[lIndex].FunctionCode := FunctionForRegion(ARef.Tag.Region);
  APlan[lIndex].StartAddress := ARef.Tag.Address;
  APlan[lIndex].Count := ARef.Tag.RegisterCount;
  APlan[lIndex].FirstTagIndex := ARef.OriginalIndex;
  APlan[lIndex].TagCount := 1;
end;

procedure BuildReadPlan(ADevice: TModbusDeviceConfig; out APlan: TModbusPlan);
var
  lRefs: TTagRefs;
  lIndex, lLast: Integer;
  lEndAddress, lNewEnd: Cardinal;
begin
  SetLength(APlan, 0);
  SetLength(lRefs, ADevice.TagCount);
  for lIndex := 0 to ADevice.TagCount - 1 do begin
    lRefs[lIndex].Tag := ADevice.TagAt(lIndex);
    lRefs[lIndex].OriginalIndex := lIndex;
  end;
  SortRefs(lRefs);
  for lIndex := 0 to High(lRefs) do begin
    if Length(APlan) = 0 then begin AppendItem(APlan, ADevice.UnitId, lRefs[lIndex]); Continue; end;
    lLast := High(APlan);
    lEndAddress := Cardinal(APlan[lLast].StartAddress) + APlan[lLast].Count;
    lNewEnd := Cardinal(lRefs[lIndex].Tag.Address) + lRefs[lIndex].Tag.RegisterCount;
    if (APlan[lLast].Region <> lRefs[lIndex].Tag.Region) or
       (lRefs[lIndex].Tag.Address > lEndAddress) or
       (lNewEnd - APlan[lLast].StartAddress > LimitForRegion(APlan[lLast].Region)) then
      AppendItem(APlan, ADevice.UnitId, lRefs[lIndex])
    else begin
      if lNewEnd > lEndAddress then
        APlan[lLast].Count := lNewEnd - APlan[lLast].StartAddress;
      Inc(APlan[lLast].TagCount);
    end;
  end;
end;

end.
