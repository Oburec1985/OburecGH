unit uComponentServices;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, ComCtrls, Grids, LConvEncoding, LazUTF8, uBaseClass;

type
  TStoredString = class
  public
    Value: string;
    constructor Create(const AValue: string);
  end;

function LclText(const AText: string): string;
function AddStoredString(AItems: TStrings; const ACaption, AValue: string): Integer;
function GetStoredString(AItems: TStrings; AIndex: Integer; const ADefault: string = ''): string;
procedure ClearStoredStrings(AItems: TStrings);

procedure SGChange(AGrid: TStringGrid; AMinWidth: Integer = 32;
  AMaxWidth: Integer = 600; APadding: Integer = 16);
procedure LVChange(AListView: TListView; AMinWidth: Integer = 32;
  AMaxWidth: Integer = 600; APadding: Integer = 18);

function SyncToTreeView(AObj: TBaseObj; ATreeView: TTreeView;
  AParentNode: TTreeNode = nil): TTreeNode;
procedure SyncFromTreeView(AObj: TBaseObj; ATreeView: TTreeView; ANode: TTreeNode);

implementation

constructor TStoredString.Create(const AValue: string);
begin
  inherited Create;
  Value := AValue;
end;

function LclText(const AText: string): string;
begin
  if (AText = '') or (FindInvalidUTF8Codepoint(PChar(AText), Length(AText), True) = -1) then
    Result := AText
  else
    Result := CP1251ToUTF8(AText);
end;

function AddStoredString(AItems: TStrings; const ACaption, AValue: string): Integer;
begin
  if AItems = nil then
    Exit(-1);
  Result := AItems.AddObject(ACaption, TStoredString.Create(AValue));
end;

function GetStoredString(AItems: TStrings; AIndex: Integer; const ADefault: string): string;
begin
  Result := ADefault;
  if (AItems = nil) or (AIndex < 0) or (AIndex >= AItems.Count) then
    Exit;
  if AItems.Objects[AIndex] is TStoredString then
    Result := TStoredString(AItems.Objects[AIndex]).Value
  else
    Result := AItems[AIndex];
end;

procedure ClearStoredStrings(AItems: TStrings);
var
  I: Integer;
begin
  if AItems = nil then
    Exit;
  for I := 0 to AItems.Count - 1 do
    if AItems.Objects[I] is TStoredString then
      AItems.Objects[I].Free;
  AItems.Clear;
end;

procedure SGChange(AGrid: TStringGrid; AMinWidth: Integer; AMaxWidth: Integer;
  APadding: Integer);
var
  lCol: Integer;
  lRow: Integer;
  lWidth: Integer;
  lTextWidth: Integer;
begin
  if AGrid = nil then
    Exit;

  AGrid.Canvas.Font.Assign(AGrid.Font);
  for lCol := 0 to AGrid.ColCount - 1 do
  begin
    lWidth := AMinWidth;
    for lRow := 0 to AGrid.RowCount - 1 do
    begin
      lTextWidth := AGrid.Canvas.TextWidth(AGrid.Cells[lCol, lRow]) + APadding;
      if lTextWidth > lWidth then
        lWidth := lTextWidth;
    end;
    if lWidth > AMaxWidth then
      lWidth := AMaxWidth;
    AGrid.ColWidths[lCol] := lWidth;
  end;
end;

procedure LVChange(AListView: TListView; AMinWidth: Integer; AMaxWidth: Integer;
  APadding: Integer);
var
  lCol: Integer;
  lItem: Integer;
  lWidth: Integer;
  lText: string;
begin
  if AListView = nil then
    Exit;

  AListView.Canvas.Font.Assign(AListView.Font);
  for lCol := 0 to AListView.Columns.Count - 1 do
  begin
    lWidth := AListView.Canvas.TextWidth(AListView.Columns[lCol].Caption) + APadding;
    if lWidth < AMinWidth then
      lWidth := AMinWidth;

    for lItem := 0 to AListView.Items.Count - 1 do
    begin
      if lCol = 0 then
        lText := AListView.Items[lItem].Caption
      else if lCol - 1 < AListView.Items[lItem].SubItems.Count then
        lText := AListView.Items[lItem].SubItems[lCol - 1]
      else
        lText := '';
      lWidth := Max(lWidth, AListView.Canvas.TextWidth(lText) + APadding);
    end;

    if lWidth > AMaxWidth then
      lWidth := AMaxWidth;
    AListView.Columns[lCol].Width := lWidth;
  end;
end;

function SyncToTreeView(AObj: TBaseObj; ATreeView: TTreeView;
  AParentNode: TTreeNode): TTreeNode;
var
  I: Integer;
begin
  Result := nil;
  if (AObj = nil) or (ATreeView = nil) then
    Exit;

  Result := ATreeView.Items.AddChildObject(AParentNode, AObj.Caption, AObj);

  for I := 0 to AObj.ChildCount - 1 do
    SyncToTreeView(AObj[I], ATreeView, Result);
end;

procedure SyncFromTreeView(AObj: TBaseObj; ATreeView: TTreeView; ANode: TTreeNode);
var
  lChildNode: TTreeNode;
begin
  if (AObj = nil) or (ATreeView = nil) or (ANode = nil) then
    Exit;

  lChildNode := ANode.GetFirstChild;
  while Assigned(lChildNode) do
  begin
    if Assigned(lChildNode.Data) and (TObject(lChildNode.Data) is TBaseObj) then
      SyncFromTreeView(TBaseObj(lChildNode.Data), ATreeView, lChildNode);
    lChildNode := lChildNode.GetNextSibling;
  end;
end;

end.
