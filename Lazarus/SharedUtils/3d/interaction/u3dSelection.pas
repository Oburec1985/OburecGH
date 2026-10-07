unit u3dSelection;

{ Maintains stable node-ID selections for editor callers without retaining node
  pointers. Version changes let consumers invalidate derived UI state. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, u3dInteractionTypes;

type
  T3dSelection = class
  private
      fItems: array of T3dNodeId;
      fCount: Integer;
      fVersion: QWord;
      function IndexOf(AId: T3dNodeId): Integer;
      procedure Changed;
  public
      constructor Create(ACapacity: Integer = 8);
      procedure Clear;
      procedure Replace(AId: T3dNodeId);
      procedure Add(AId: T3dNodeId);
      procedure Remove(AId: T3dNodeId);
      procedure Toggle(AId: T3dNodeId);
      function Contains(AId: T3dNodeId): Boolean;
      function Item(AIndex: Integer): T3dNodeId;
      function PrimaryId: T3dNodeId;
      property Count: Integer read fCount;
      property Version: QWord read fVersion;
  end;

{ Vertex-pick misses must not discard the owning object: the next click still
  needs that node as the vertex search context. Ordinary object selection may
  pass AKeepCurrentOnMiss=False to retain its deselect-on-empty behavior. }
function NodeIdAfterPick(ACurrentId, AHitId: T3dNodeId;
  AKeepCurrentOnMiss: Boolean): T3dNodeId;

implementation

function NodeIdAfterPick(ACurrentId, AHitId: T3dNodeId;
  AKeepCurrentOnMiss: Boolean): T3dNodeId;
begin
  if AHitId <> 0 then
    Exit(AHitId);
  if AKeepCurrentOnMiss then
    Exit(ACurrentId);
  Result := 0;
end;

constructor T3dSelection.Create(ACapacity: Integer);
begin
  inherited Create;
  if ACapacity < 1 then
    ACapacity := 1;
  SetLength(fItems, ACapacity);
end;

function T3dSelection.IndexOf(AId: T3dNodeId): Integer;

var
  lIndex: Integer;
begin
  for lIndex := 0 to fCount - 1 do
    if fItems[lIndex] = AId then
      Exit(lIndex);
  Result := -1;
end;

procedure T3dSelection.Changed;
begin
  Inc(fVersion);
end;

procedure T3dSelection.Clear;
begin
  if fCount = 0 then
    Exit;
  fCount := 0;
  Changed;
end;

procedure T3dSelection.Replace(AId: T3dNodeId);
begin
  if AId = 0 then
    begin
      Clear;
      Exit;
    end;
  if (fCount = 1) and (fItems[0] = AId) then
    Exit;
  fItems[0] := AId;
  fCount := 1;
  Changed;
end;

procedure T3dSelection.Add(AId: T3dNodeId);
begin
  if (AId = 0) or Contains(AId) then
    Exit;
  if fCount = Length(fItems) then
    SetLength(fItems, Length(fItems) * 2);
  fItems[fCount] := AId;
  Inc(fCount);
  Changed;
end;

procedure T3dSelection.Remove(AId: T3dNodeId);

var
  lIndex, lMoveIndex: Integer;
begin
  lIndex := IndexOf(AId);
  if lIndex < 0 then
    Exit;
  for lMoveIndex := lIndex to fCount - 2 do
    fItems[lMoveIndex] := fItems[lMoveIndex + 1];
  Dec(fCount);
  Changed;
end;

procedure T3dSelection.Toggle(AId: T3dNodeId);
begin
  if Contains(AId) then
    Remove(AId)
  else Add(AId);
end;

function T3dSelection.Contains(AId: T3dNodeId): Boolean;
begin
  Result := IndexOf(AId) >= 0;
end;

function T3dSelection.Item(AIndex: Integer): T3dNodeId;
begin
  if (AIndex < 0) or (AIndex >= fCount) then
    raise ERangeError.CreateFmt('Selection index %d is out of range', [AIndex]);
  Result := fItems[AIndex];
end;

function T3dSelection.PrimaryId: T3dNodeId;
begin
  if fCount = 0 then
    Exit(0);
  Result := fItems[0];
end;

end.
