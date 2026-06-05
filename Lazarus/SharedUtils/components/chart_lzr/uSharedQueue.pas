unit uSharedQueue;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  generic cQueue<T> = class
  private
    fItems: array of T;
    fCapacity: Integer;
    fCount: Integer;
    fFirst: Integer;
    function PhysicalIndex(ALogicalIndex: Integer): Integer;
    function GetItem(ALogicalIndex: Integer): T;
  public
    procedure Clear;
    procedure SetCapacity(ACapacity: Integer);
    procedure PushBack(const AValue: T);

    property Capacity: Integer read fCapacity;
    property Count: Integer read fCount;
    property FirstIndex: Integer read fFirst;
    property Items[ALogicalIndex: Integer]: T read GetItem; default;
  end;

implementation

function cQueue.PhysicalIndex(ALogicalIndex: Integer): Integer;
begin
  if (ALogicalIndex < 0) or (ALogicalIndex >= fCount) then
    raise ERangeError.CreateFmt('Queue index out of range: %d', [ALogicalIndex]);
  if fCapacity <= 0 then
    raise ERangeError.Create('Queue capacity is zero');
  Result := (fFirst + ALogicalIndex) mod fCapacity;
end;

function cQueue.GetItem(ALogicalIndex: Integer): T;
begin
  Result := fItems[PhysicalIndex(ALogicalIndex)];
end;

procedure cQueue.Clear;
begin
  fCount := 0;
  fFirst := 0;
end;

procedure cQueue.SetCapacity(ACapacity: Integer);
var
  I: Integer;
  lKeep: Integer;
  lOldCount: Integer;
  lOldItems: array of T;
begin
  if ACapacity < 0 then
    raise EArgumentException.Create('Queue capacity cannot be negative');
  if ACapacity = fCapacity then
    Exit;

  lOldCount := fCount;
  SetLength(lOldItems, lOldCount);
  for I := 0 to lOldCount - 1 do
    lOldItems[I] := Items[I];

  SetLength(fItems, ACapacity);
  fCapacity := ACapacity;
  fFirst := 0;
  fCount := 0;

  if ACapacity <= 0 then
    Exit;

  lKeep := lOldCount;
  if lKeep > ACapacity then
    lKeep := ACapacity;

  for I := lOldCount - lKeep to lOldCount - 1 do
    PushBack(lOldItems[I]);
end;

procedure cQueue.PushBack(const AValue: T);
var
  lIndex: Integer;
begin
  if fCapacity <= 0 then
    Exit;

  if fCount < fCapacity then
  begin
    lIndex := (fFirst + fCount) mod fCapacity;
    Inc(fCount);
  end
  else
  begin
    lIndex := fFirst;
    fFirst := (fFirst + 1) mod fCapacity;
  end;

  fItems[lIndex] := AValue;
end;

end.
