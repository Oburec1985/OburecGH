unit uRecorderLissajousSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Buttons, Dialogs, Grids,
  Graphics, uRecorderFormModel, uRecorderTags;

type
  TRecorderLissajousSettingsDialog = class(TForm)
    btnAddLine: TButton;
    btnCancel: TButton;
    btnColor: TColorButton;
    btnDiameterColor: TColorButton;
    btnDeleteLine: TButton;
    btnOk: TButton;
    cbDrawDiameterCenter: TCheckBox;
    cbDrawLine: TCheckBox;
    cbDrawMainDiameter: TCheckBox;
    cbDrawPoints: TCheckBox;
    cbShowDiameterValue: TCheckBox;
    edDuration: TEdit;
    edLineName: TEdit;
    edMaxX: TEdit;
    edMaxY: TEdit;
    edMinX: TEdit;
    edMinY: TEdit;
    edSearch: TEdit;
    edWidth: TEdit;
    gridAvailable: TStringGrid;
    lbLines: TListBox;
    lblAvailable: TLabel;
    lblColor: TLabel;
    lblDuration: TLabel;
    lblDiameterColor: TLabel;
    lblLineName: TLabel;
    lblLines: TLabel;
    lblMaxX: TLabel;
    lblMaxY: TLabel;
    lblMinX: TLabel;
    lblMinY: TLabel;
    lblSearch: TLabel;
    lblWidth: TLabel;
    pnlXTag: TPanel;
    pnlYTag: TPanel;
    procedure btnAddLineClick(Sender: TObject);
    procedure btnDeleteLineClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure lbAvailableDblClick(Sender: TObject);
    procedure lbLinesSelectionChange(Sender: TObject; User: Boolean);
    procedure TagDropDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TagDropDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private
    fComponent: TRecorderLissajousComponent;
    fDraft: TRecorderLissajousComponent;
    fRegistry: TRecorderTagRegistry;
    fSelectedLine: Integer;
    fLoading: Boolean;
    procedure AssignAvailableTag(AToX: Boolean);
    procedure FillAvailableTags(const AFilter: string);
    procedure FillLines;
    function LineCaption(ALine: TRecorderLissajousLine): string;
    function SelectedAvailableTag: TRecorderTag;
    function TagFrequencyText(ATag: TRecorderTag): string;
    procedure LoadCommonSettings;
    procedure LoadSelectedLine;
    function ReadFloat(AEdit: TEdit; const ACaption: string): Double;
    procedure SaveCommonSettings;
    procedure SaveSelectedLine;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderLissajousComponent;
      ARegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderLissajousSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderLissajousComponent;
  ARegistry: TRecorderTagRegistry): Boolean;

implementation

{$R *.lfm}

function ShowRecorderLissajousSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderLissajousComponent;
  ARegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderLissajousSettingsDialog;
begin
  lDialog := TRecorderLissajousSettingsDialog.CreateDialog(AOwner, AComponent,
    ARegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

constructor TRecorderLissajousSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderLissajousComponent; ARegistry: TRecorderTagRegistry);
begin
  inherited Create(AOwner);
  gridAvailable.Cells[0, 0] := 'Сигнал';
  gridAvailable.Cells[1, 0] := 'Частота опроса';
  fComponent := AComponent;
  fRegistry := ARegistry;
  fDraft := TRecorderLissajousComponent.Create;
  fDraft.Assign(AComponent);
  fSelectedLine := 0;
  LoadCommonSettings;
  FillLines;
  FillAvailableTags('');
  LoadSelectedLine;
end;

destructor TRecorderLissajousSettingsDialog.Destroy;
begin
  fDraft.Free;
  inherited Destroy;
end;

function TRecorderLissajousSettingsDialog.LineCaption(
  ALine: TRecorderLissajousLine): string;
begin
  Result := ALine.Name;
  if Trim(Result) = '' then Result := 'Линия';
  Result := Result + '  [' + ALine.XTagName + ' / ' + ALine.YTagName + ']';
end;

function TRecorderLissajousSettingsDialog.SelectedAvailableTag: TRecorderTag;
begin
  Result := nil;
  if (gridAvailable.Row > 0) and (gridAvailable.Row < gridAvailable.RowCount) then
    Result := TRecorderTag(gridAvailable.Objects[0, gridAvailable.Row]);
end;

function TRecorderLissajousSettingsDialog.TagFrequencyText(
  ATag: TRecorderTag): string;
begin
  if (ATag = nil) or (ATag.PollFrequencyHz <= 0) then Exit('-');
  Result := FormatFloat('0.###', ATag.PollFrequencyHz) + ' Гц';
end;

procedure TRecorderLissajousSettingsDialog.FillLines;
var
  I: Integer;
begin
  lbLines.Items.BeginUpdate;
  try
    lbLines.Clear;
    for I := 0 to fDraft.LineCount - 1 do
      lbLines.Items.AddObject(LineCaption(fDraft.Lines[I]), fDraft.Lines[I]);
    if fSelectedLine >= fDraft.LineCount then fSelectedLine := fDraft.LineCount - 1;
    lbLines.ItemIndex := fSelectedLine;
  finally
    lbLines.Items.EndUpdate;
  end;
end;

procedure TRecorderLissajousSettingsDialog.FillAvailableTags(
  const AFilter: string);
var
  I: Integer;
  lTag, lSelected: TRecorderTag;
  lNeedle, lText: string;
  lRow: Integer;
begin
  lSelected := SelectedAvailableTag;
  lNeedle := LowerCase(Trim(AFilter));
  gridAvailable.BeginUpdate;
  try
    gridAvailable.RowCount := 1;
    if fRegistry <> nil then
      for I := 0 to fRegistry.TagCount - 1 do
      begin
        lTag := fRegistry.Tags[I];
        lText := lTag.Name + '  ' + lTag.Address + '  ' + lTag.Description;
        if (lNeedle <> '') and (Pos(lNeedle, LowerCase(lText)) = 0) then Continue;
        lRow := gridAvailable.RowCount;
        gridAvailable.RowCount := lRow + 1;
        gridAvailable.Cells[0, lRow] := lTag.Name;
        gridAvailable.Cells[1, lRow] := TagFrequencyText(lTag);
        gridAvailable.Objects[0, lRow] := lTag;
        if lTag = lSelected then gridAvailable.Row := lRow;
      end;
  finally
    gridAvailable.EndUpdate;
  end;
end;

procedure TRecorderLissajousSettingsDialog.LoadCommonSettings;
begin
  edDuration.Text := FloatToStr(fDraft.DurationSec);
  edMinX.Text := FloatToStr(fDraft.RangeMinX);
  edMaxX.Text := FloatToStr(fDraft.RangeMaxX);
  edMinY.Text := FloatToStr(fDraft.RangeMinY);
  edMaxY.Text := FloatToStr(fDraft.RangeMaxY);
end;

procedure TRecorderLissajousSettingsDialog.LoadSelectedLine;
var
  lLine: TRecorderLissajousLine;
begin
  fLoading := True;
  try
    if (fSelectedLine < 0) or (fSelectedLine >= fDraft.LineCount) then Exit;
    lLine := fDraft.Lines[fSelectedLine];
    edLineName.Text := lLine.Name;
    pnlXTag.Caption := 'X: ' + lLine.XTagName;
    pnlYTag.Caption := 'Y: ' + lLine.YTagName;
    edWidth.Text := IntToStr(lLine.Width);
    btnColor.ButtonColor := TColor(lLine.Color);
    btnDiameterColor.ButtonColor := TColor(lLine.DiameterColor);
    cbDrawPoints.Checked := lLine.DrawPoints;
    cbDrawLine.Checked := lLine.DrawLine;
    cbDrawMainDiameter.Checked := lLine.DrawMainDiameter;
    cbDrawDiameterCenter.Checked := lLine.DrawDiameterCenter;
    cbShowDiameterValue.Checked := lLine.ShowDiameterValue;
  finally
    fLoading := False;
  end;
end;

procedure TRecorderLissajousSettingsDialog.SaveSelectedLine;
var
  lLine: TRecorderLissajousLine;
begin
  if fLoading or (fSelectedLine < 0) or
    (fSelectedLine >= fDraft.LineCount) then Exit;
  lLine := fDraft.Lines[fSelectedLine];
  lLine.Name := Trim(edLineName.Text);
  lLine.Width := StrToIntDef(edWidth.Text, 2);
  if lLine.Width < 1 then lLine.Width := 1;
  lLine.Color := btnColor.ButtonColor;
  lLine.DiameterColor := btnDiameterColor.ButtonColor;
  lLine.DrawPoints := cbDrawPoints.Checked;
  lLine.DrawLine := cbDrawLine.Checked;
  lLine.DrawMainDiameter := cbDrawMainDiameter.Checked;
  lLine.DrawDiameterCenter := cbDrawDiameterCenter.Checked;
  lLine.ShowDiameterValue := cbShowDiameterValue.Checked;
end;

procedure TRecorderLissajousSettingsDialog.SaveCommonSettings;
begin
  fDraft.DurationSec := ReadFloat(edDuration, 'Длина участка');
  fDraft.RangeMinX := ReadFloat(edMinX, 'X min');
  fDraft.RangeMaxX := ReadFloat(edMaxX, 'X max');
  fDraft.RangeMinY := ReadFloat(edMinY, 'Y min');
  fDraft.RangeMaxY := ReadFloat(edMaxY, 'Y max');
  if (fDraft.DurationSec <= 0) or
    (fDraft.RangeMaxX <= fDraft.RangeMinX) or
    (fDraft.RangeMaxY <= fDraft.RangeMinY) then
    raise Exception.Create('Проверьте диапазоны и длину участка');
end;

function TRecorderLissajousSettingsDialog.ReadFloat(AEdit: TEdit;
  const ACaption: string): Double;
begin
  if not TryStrToFloat(AEdit.Text, Result) then
    raise Exception.Create('Неверное значение: ' + ACaption);
end;

procedure TRecorderLissajousSettingsDialog.AssignAvailableTag(AToX: Boolean);
var
  lLine: TRecorderLissajousLine;
  lTag: TRecorderTag;
begin
  if (fSelectedLine < 0) or (SelectedAvailableTag = nil) then Exit;
  SaveSelectedLine;
  lLine := fDraft.Lines[fSelectedLine];
  lTag := SelectedAvailableTag;
  if AToX then lLine.SetXTag(lTag) else lLine.SetYTag(lTag);
  LoadSelectedLine;
  FillLines;
end;

procedure TRecorderLissajousSettingsDialog.TagDropDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = gridAvailable) and (SelectedAvailableTag <> nil);
end;

procedure TRecorderLissajousSettingsDialog.TagDropDragDrop(Sender,
  Source: TObject; X, Y: Integer);
begin
  if Source = gridAvailable then AssignAvailableTag(Sender = pnlXTag);
end;

procedure TRecorderLissajousSettingsDialog.lbAvailableDblClick(Sender: TObject);
begin
  if (fSelectedLine >= 0) and
    (fDraft.Lines[fSelectedLine].XTagId = 0) then AssignAvailableTag(True)
  else AssignAvailableTag(False);
end;

procedure TRecorderLissajousSettingsDialog.lbLinesSelectionChange(
  Sender: TObject; User: Boolean);
begin
  if fLoading or (lbLines.ItemIndex < 0) or
    (lbLines.ItemIndex = fSelectedLine) then Exit;
  SaveSelectedLine;
  fSelectedLine := lbLines.ItemIndex;
  LoadSelectedLine;
end;

procedure TRecorderLissajousSettingsDialog.btnAddLineClick(Sender: TObject);
var
  lLine: TRecorderLissajousLine;
begin
  SaveSelectedLine;
  lLine := fDraft.AddLine;
  lLine.Name := 'Линия ' + IntToStr(fDraft.LineCount);
  fSelectedLine := fDraft.LineCount - 1;
  FillLines;
  LoadSelectedLine;
end;

procedure TRecorderLissajousSettingsDialog.btnDeleteLineClick(Sender: TObject);
begin
  if fDraft.LineCount <= 1 then
  begin
    MessageDlg('Должна остаться хотя бы одна линия', mtInformation, [mbOK], 0);
    Exit;
  end;
  fDraft.DeleteLine(fSelectedLine);
  if fSelectedLine >= fDraft.LineCount then Dec(fSelectedLine);
  FillLines;
  LoadSelectedLine;
end;

procedure TRecorderLissajousSettingsDialog.btnOkClick(Sender: TObject);
var
  I: Integer;
begin
  try
    SaveSelectedLine;
    SaveCommonSettings;
    for I := 0 to fDraft.LineCount - 1 do
    begin
      if fDraft.Lines[I].XTagId = 0 then
        raise Exception.CreateFmt('Для линии %d не выбран сигнал X', [I + 1]);
      if fDraft.Lines[I].YTagId = 0 then
        raise Exception.CreateFmt('Для линии %d не выбран сигнал Y', [I + 1]);
    end;
    fComponent.Assign(fDraft);
    ModalResult := mrOk;
  except
    on E: Exception do MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderLissajousSettingsDialog.edSearchChange(Sender: TObject);
begin
  FillAvailableTags(edSearch.Text);
end;

end.
