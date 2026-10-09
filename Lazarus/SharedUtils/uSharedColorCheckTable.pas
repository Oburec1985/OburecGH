unit uSharedColorCheckTable;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Math, Graphics, Controls, StdCtrls, Grids,
  LCLType, LCLIntf;

type
  TSharedColorCheckItem = record
    Caption: string;
    Color: TColor;
    Checked: Boolean;
    Data: TObject;
  end;

  TSharedColorCheckEvent = procedure(Sender: TObject; AIndex: Integer) of object;

  { Reusable table for named rows with optional visibility and color columns.
    Data objects are referenced but never owned by the control. }
  TSharedColorCheckTable = class(TStringGrid)
  private
    fItems: array of TSharedColorCheckItem;
    fShowCheckboxes: Boolean;
    fShowColorBoxes: Boolean;
    fCheckColumnTitle: string;
    fColorColumnTitle: string;
    fNameColumnTitle: string;
    fUpdateCount: Integer;
    fOnCheckChanged: TSharedColorCheckEvent;
    function GetCheckColumn: Integer;
    function GetColorColumn: Integer;
    function GetNameColumn: Integer;
    function GetItemCount: Integer;
    function GetSelectedIndex: Integer;
    function GetChecked(AIndex: Integer): Boolean;
    function GetItemColor(AIndex: Integer): TColor;
    function GetItemCaption(AIndex: Integer): string;
    function GetItemData(AIndex: Integer): TObject;
    procedure SetShowCheckboxes(AValue: Boolean);
    procedure SetShowColorBoxes(AValue: Boolean);
    procedure SetCheckColumnTitle(const AValue: string);
    procedure SetColorColumnTitle(const AValue: string);
    procedure SetNameColumnTitle(const AValue: string);
    procedure SetSelectedIndex(AValue: Integer);
    procedure SetChecked(AIndex: Integer; AValue: Boolean);
    procedure SetItemColor(AIndex: Integer; AValue: TColor);
    procedure SetItemCaption(AIndex: Integer; const AValue: string);
    procedure SetItemData(AIndex: Integer; AValue: TObject);
    procedure UpdateColumns;
    procedure UpdateRows;
    procedure ToggleCheck(AIndex: Integer);
    procedure DrawCellBorder(const ARect: TRect);
  protected
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect;
      AState: TGridDrawState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    function AddItem(const ACaption: string; AColor: TColor;
      AChecked: Boolean; AData: TObject = nil): Integer;
    property ItemCount: Integer read GetItemCount;
    property SelectedIndex: Integer read GetSelectedIndex write SetSelectedIndex;
    property Checked[AIndex: Integer]: Boolean read GetChecked write SetChecked;
    property ItemColor[AIndex: Integer]: TColor read GetItemColor write SetItemColor;
    property ItemCaption[AIndex: Integer]: string read GetItemCaption
      write SetItemCaption;
    property ItemData[AIndex: Integer]: TObject read GetItemData write SetItemData;
    property CheckColumn: Integer read GetCheckColumn;
    property ColorColumn: Integer read GetColorColumn;
    property NameColumn: Integer read GetNameColumn;
  published
    property ShowCheckboxes: Boolean read fShowCheckboxes
      write SetShowCheckboxes default True;
    property ShowColorBoxes: Boolean read fShowColorBoxes
      write SetShowColorBoxes default True;
    property CheckColumnTitle: string read fCheckColumnTitle
      write SetCheckColumnTitle;
    property ColorColumnTitle: string read fColorColumnTitle
      write SetColorColumnTitle;
    property NameColumnTitle: string read fNameColumnTitle
      write SetNameColumnTitle;
    property OnCheckChanged: TSharedColorCheckEvent read fOnCheckChanged
      write fOnCheckChanged;
  end;

implementation

constructor TSharedColorCheckTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fShowCheckboxes := True;
  fShowColorBoxes := True;
  fCheckColumnTitle := '';
  fColorColumnTitle := 'Color';
  fNameColumnTitle := 'Name';
  FixedRows := 1;
  RowCount := 1;
  DefaultRowHeight := 20;
  Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
    goRowSelect, goThumbTracking];
  ScrollBars := ssAutoBoth;
  UpdateColumns;
end;

function TSharedColorCheckTable.GetCheckColumn: Integer;
begin
  if fShowCheckboxes then Result := 0 else Result := -1;
end;

function TSharedColorCheckTable.GetColorColumn: Integer;
begin
  if not fShowColorBoxes then Exit(-1);
  Result := 0;
  if fShowCheckboxes then Inc(Result);
end;

function TSharedColorCheckTable.GetNameColumn: Integer;
begin
  Result := 0;
  if fShowCheckboxes then Inc(Result);
  if fShowColorBoxes then Inc(Result);
end;

function TSharedColorCheckTable.GetItemCount: Integer;
begin
  Result := Length(fItems);
end;

function TSharedColorCheckTable.GetSelectedIndex: Integer;
begin
  Result := Row - 1;
  if (Result < 0) or (Result >= ItemCount) then Result := -1;
end;

function TSharedColorCheckTable.GetChecked(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < ItemCount) and fItems[AIndex].Checked;
end;

function TSharedColorCheckTable.GetItemColor(AIndex: Integer): TColor;
begin
  if (AIndex >= 0) and (AIndex < ItemCount) then
    Result := fItems[AIndex].Color
  else
    Result := clNone;
end;

function TSharedColorCheckTable.GetItemCaption(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex < ItemCount) then
    Result := fItems[AIndex].Caption
  else
    Result := '';
end;

function TSharedColorCheckTable.GetItemData(AIndex: Integer): TObject;
begin
  if (AIndex >= 0) and (AIndex < ItemCount) then
    Result := fItems[AIndex].Data
  else
    Result := nil;
end;

procedure TSharedColorCheckTable.SetShowCheckboxes(AValue: Boolean);
begin
  if fShowCheckboxes = AValue then Exit;
  fShowCheckboxes := AValue;
  UpdateColumns;
end;

procedure TSharedColorCheckTable.SetShowColorBoxes(AValue: Boolean);
begin
  if fShowColorBoxes = AValue then Exit;
  fShowColorBoxes := AValue;
  UpdateColumns;
end;

procedure TSharedColorCheckTable.SetCheckColumnTitle(const AValue: string);
begin
  if fCheckColumnTitle = AValue then Exit;
  fCheckColumnTitle := AValue;
  UpdateColumns;
end;

procedure TSharedColorCheckTable.SetColorColumnTitle(const AValue: string);
begin
  if fColorColumnTitle = AValue then Exit;
  fColorColumnTitle := AValue;
  UpdateColumns;
end;

procedure TSharedColorCheckTable.SetNameColumnTitle(const AValue: string);
begin
  if fNameColumnTitle = AValue then Exit;
  fNameColumnTitle := AValue;
  UpdateColumns;
end;

procedure TSharedColorCheckTable.SetSelectedIndex(AValue: Integer);
begin
  if ItemCount = 0 then Exit;
  if AValue < 0 then AValue := 0;
  if AValue >= ItemCount then AValue := ItemCount - 1;
  Row := AValue + 1;
end;

procedure TSharedColorCheckTable.SetChecked(AIndex: Integer; AValue: Boolean);
begin
  if (AIndex < 0) or (AIndex >= ItemCount) or
     (fItems[AIndex].Checked = AValue) then Exit;
  fItems[AIndex].Checked := AValue;
  if fUpdateCount = 0 then Invalidate;
end;

procedure TSharedColorCheckTable.SetItemColor(AIndex: Integer; AValue: TColor);
begin
  if (AIndex < 0) or (AIndex >= ItemCount) or
     (fItems[AIndex].Color = AValue) then Exit;
  fItems[AIndex].Color := AValue;
  if fUpdateCount = 0 then Invalidate;
end;

procedure TSharedColorCheckTable.SetItemCaption(AIndex: Integer;
  const AValue: string);
begin
  if (AIndex < 0) or (AIndex >= ItemCount) or
     (fItems[AIndex].Caption = AValue) then Exit;
  fItems[AIndex].Caption := AValue;
  if fUpdateCount = 0 then Invalidate;
end;

procedure TSharedColorCheckTable.SetItemData(AIndex: Integer; AValue: TObject);
begin
  if (AIndex < 0) or (AIndex >= ItemCount) then Exit;
  fItems[AIndex].Data := AValue;
end;

procedure TSharedColorCheckTable.UpdateColumns;
var
  lUsedWidth: Integer;
begin
  ColCount := 1 + Ord(fShowCheckboxes) + Ord(fShowColorBoxes);
  if CheckColumn >= 0 then
  begin
    Cells[CheckColumn, 0] := fCheckColumnTitle;
    ColWidths[CheckColumn] := 54;
  end;
  if ColorColumn >= 0 then
  begin
    Cells[ColorColumn, 0] := fColorColumnTitle;
    ColWidths[ColorColumn] := 54;
  end;
  Cells[NameColumn, 0] := fNameColumnTitle;
  lUsedWidth := 0;
  if CheckColumn >= 0 then Inc(lUsedWidth, ColWidths[CheckColumn] + 1);
  if ColorColumn >= 0 then Inc(lUsedWidth, ColWidths[ColorColumn] + 1);
  ColWidths[NameColumn] := Max(80, ClientWidth - lUsedWidth - 4);
  if fUpdateCount = 0 then Invalidate;
end;

procedure TSharedColorCheckTable.UpdateRows;
begin
  RowCount := Max(1, ItemCount + 1);
  if ItemCount > 0 then
    Row := EnsureRange(Row, 1, ItemCount)
  else
    Row := 0;
  if fUpdateCount = 0 then Invalidate;
end;

procedure TSharedColorCheckTable.ToggleCheck(AIndex: Integer);
begin
  if not fShowCheckboxes or (AIndex < 0) or (AIndex >= ItemCount) then Exit;
  fItems[AIndex].Checked := not fItems[AIndex].Checked;
  Invalidate;
  if Assigned(fOnCheckChanged) then fOnCheckChanged(Self, AIndex);
end;

procedure TSharedColorCheckTable.DrawCellBorder(const ARect: TRect);
begin
  Canvas.Pen.Color := clBtnShadow;
  Canvas.Pen.Width := 1;
  Canvas.MoveTo(ARect.Right - 1, ARect.Top);
  Canvas.LineTo(ARect.Right - 1, ARect.Bottom);
  Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
  Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
end;

procedure TSharedColorCheckTable.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  lRect: TRect;
  lIndex: Integer;
begin
  if gdSelected in AState then
  begin
    Canvas.Brush.Color := clHighlight;
    Canvas.Font.Color := clHighlightText;
  end
  else if ARow = 0 then
  begin
    Canvas.Brush.Color := FixedColor;
    Canvas.Font.Color := Font.Color;
  end
  else
  begin
    Canvas.Brush.Color := Color;
    Canvas.Font.Color := Font.Color;
  end;
  Canvas.FillRect(ARect);
  if ARow = 0 then
  begin
    DrawText(Canvas.Handle, PChar(Cells[ACol, 0]), -1, ARect,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
    DrawCellBorder(ARect);
    Exit;
  end;
  lIndex := ARow - 1;
  if (lIndex < 0) or (lIndex >= ItemCount) then
  begin
    DrawCellBorder(ARect);
    Exit;
  end;
  if ACol = CheckColumn then
  begin
    lRect := Rect(ARect.Left + (ARect.Width - 13) div 2,
      ARect.Top + (ARect.Height - 13) div 2, 0, 0);
    lRect.Right := lRect.Left + 13;
    lRect.Bottom := lRect.Top + 13;
    Canvas.Brush.Color := clWindow;
    Canvas.Pen.Color := clWindowText;
    Canvas.Rectangle(lRect);
    if fItems[lIndex].Checked then
    begin
      Canvas.Pen.Width := 2;
      Canvas.MoveTo(lRect.Left + 2, lRect.Top + 6);
      Canvas.LineTo(lRect.Left + 5, lRect.Bottom - 2);
      Canvas.LineTo(lRect.Right - 2, lRect.Top + 3);
      Canvas.Pen.Width := 1;
    end;
  end
  else if ACol = ColorColumn then
  begin
    lRect := Rect(ARect.Left + (ARect.Width - 13) div 2,
      ARect.Top + (ARect.Height - 13) div 2, 0, 0);
    lRect.Right := lRect.Left + 13;
    lRect.Bottom := lRect.Top + 13;
    Canvas.Brush.Color := fItems[lIndex].Color;
    Canvas.Pen.Color := clWindowText;
    Canvas.Rectangle(lRect);
  end
  else if ACol = NameColumn then
  begin
    Inc(ARect.Left, 5);
    DrawText(Canvas.Handle, PChar(fItems[lIndex].Caption), -1, ARect,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  end;
  DrawCellBorder(ARect);
end;

procedure TSharedColorCheckTable.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  lCol, lRow: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  MouseToCell(X, Y, lCol, lRow);
  if (Button = mbLeft) and (lRow > 0) and (lCol = CheckColumn) then
  begin
    Row := lRow;
    ToggleCheck(lRow - 1);
  end;
end;

procedure TSharedColorCheckTable.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_SPACE) and (SelectedIndex >= 0) and fShowCheckboxes then
  begin
    ToggleCheck(SelectedIndex);
    Key := 0;
    Exit;
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TSharedColorCheckTable.Resize;
begin
  inherited Resize;
  UpdateColumns;
end;

procedure TSharedColorCheckTable.BeginUpdate;
begin
  Inc(fUpdateCount);
end;

procedure TSharedColorCheckTable.EndUpdate;
begin
  if fUpdateCount = 0 then Exit;
  Dec(fUpdateCount);
  if fUpdateCount = 0 then
  begin
    UpdateRows;
    UpdateColumns;
  end;
end;

procedure TSharedColorCheckTable.Clear;
begin
  SetLength(fItems, 0);
  UpdateRows;
end;

function TSharedColorCheckTable.AddItem(const ACaption: string; AColor: TColor;
  AChecked: Boolean; AData: TObject): Integer;
begin
  Result := Length(fItems);
  SetLength(fItems, Result + 1);
  fItems[Result].Caption := ACaption;
  fItems[Result].Color := AColor;
  fItems[Result].Checked := AChecked;
  fItems[Result].Data := AData;
  if fUpdateCount = 0 then UpdateRows;
end;

initialization
  RegisterClass(TSharedColorCheckTable);

finalization
  UnregisterClass(TSharedColorCheckTable);

end.
