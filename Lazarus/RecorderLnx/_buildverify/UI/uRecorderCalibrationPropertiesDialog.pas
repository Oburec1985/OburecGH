unit uRecorderCalibrationPropertiesDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ComCtrls, Grids, ExtCtrls,
  uRecorderTags;

type
  TRecorderCalibrationPropertiesDialog = class(TForm)
    btnAddPoint: TButton;
    btnApply: TButton;
    btnCancel: TButton;
    btnDeletePoint: TButton;
    btnOk: TButton;
    cbExtrapolation: TCheckBox;
    cbType: TComboBox;
    edDescription: TEdit;
    edName: TEdit;
    edScale: TEdit;
    edScaleInv: TEdit;
    edUnitIn: TEdit;
    edUnitOut: TEdit;
    gridPoints: TStringGrid;
    gridProps: TStringGrid;
    lbChanged: TLabel;
    lbDescription: TLabel;
    lbName: TLabel;
    lbScale: TLabel;
    lbScaleInv: TLabel;
    lbScaleResult: TLabel;
    lbType: TLabel;
    lbUnitIn: TLabel;
    lbUnitOut: TLabel;
    pcMain: TPageControl;
    pnButtons: TPanel;
    pnScale: TPanel;
    tsCommon: TTabSheet;
    tsData: TTabSheet;
    tsGraph: TTabSheet;
    procedure btnAddPointClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnDeletePointClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure cbTypeChange(Sender: TObject);
    procedure edScaleChange(Sender: TObject);
    procedure edScaleInvChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    fCalibration: TRecorderCalibration;
    fUpdating: Boolean;
    function ComboCalibrationKind: TRecorderCalibrationKind;
    function ReadFloat(const AText: string; out AValue: Double): Boolean;
    procedure ApplyToCalibration;
    procedure LoadFromCalibration;
    procedure RenumberPoints;
    procedure SelectComboCalibrationKind(AKind: TRecorderCalibrationKind);
    procedure UpdateGridColumns;
    procedure UpdateTypeControls;
  public
    procedure EditCalibration(ACalibration: TRecorderCalibration);
  end;

function ShowRecorderCalibrationPropertiesDialog(AOwner: TComponent;
  ACalibration: TRecorderCalibration): Boolean;

implementation

{$R *.lfm}

procedure TRecorderCalibrationPropertiesDialog.FormCreate(Sender: TObject);
begin
  cbType.Items.Clear;
  cbType.Items.AddObject('РљСѓСЃРѕС‡РЅРѕ-Р»РёРЅРµР№РЅР°СЏ РёРЅС‚РµСЂРїРѕР»СЏС†РёСЏ', TObject(PtrInt(Ord(rckPiecewiseLinear))));
  cbType.Items.AddObject('РњР°СЃС€С‚Р°Р±РЅС‹Р№ РјРЅРѕР¶РёС‚РµР»СЊ', TObject(PtrInt(Ord(rckScale))));
  gridProps.ColCount := 2;
  gridProps.RowCount := 2;
  gridProps.FixedRows := 1;
  gridProps.Cells[0, 0] := 'РЎРІРѕР№СЃС‚РІРѕ';
  gridProps.Cells[1, 0] := 'Р—РЅР°С‡РµРЅРёРµ';
  gridPoints.ColCount := 3;
  gridPoints.RowCount := 2;
  gridPoints.FixedRows := 1;
  gridPoints.FixedCols := 1;
  gridPoints.Options := gridPoints.Options + [goEditing, goTabs];
  gridPoints.ColWidths[0] := 36;
  gridPoints.ColWidths[1] := 140;
  gridPoints.ColWidths[2] := 140;
  gridPoints.Cells[0, 0] := 'i';
  gridPoints.Cells[1, 0] := 'X(i)';
  gridPoints.Cells[2, 0] := 'Y(i)';
  UpdateGridColumns;
end;

function TRecorderCalibrationPropertiesDialog.ComboCalibrationKind:
  TRecorderCalibrationKind;
begin
  Result := rckPiecewiseLinear;
  if (cbType.ItemIndex >= 0) and
    (cbType.ItemIndex < cbType.Items.Count) and
    (PtrInt(cbType.Items.Objects[cbType.ItemIndex]) = Ord(rckScale)) then
    Result := rckScale;
end;

function TRecorderCalibrationPropertiesDialog.ReadFloat(const AText: string;
  out AValue: Double): Boolean;
var
  lText: string;
begin
  lText := StringReplace(Trim(AText), '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  Result := TryStrToFloat(lText, AValue);
end;

procedure TRecorderCalibrationPropertiesDialog.EditCalibration(
  ACalibration: TRecorderCalibration);
begin
  fCalibration := ACalibration;
  LoadFromCalibration;
end;

procedure TRecorderCalibrationPropertiesDialog.LoadFromCalibration;
var
  I: Integer;
  lPoint: TRecorderCalibrationPoint;
begin
  if fCalibration = nil then
    Exit;
  fUpdating := True;
  try
    edName.Text := fCalibration.Name;
    edDescription.Text := fCalibration.Description;
    edUnitIn.Text := fCalibration.UnitIn;
    edUnitOut.Text := fCalibration.UnitOut;
    cbExtrapolation.Checked := fCalibration.Extrapolation;
    SelectComboCalibrationKind(fCalibration.Kind);
    edScale.Text := FormatFloat('0.######', fCalibration.Scale);
    if fCalibration.Scale <> 0 then
      edScaleInv.Text := FormatFloat('0.######', 1 / fCalibration.Scale)
    else
      edScaleInv.Text := '';
    gridPoints.RowCount := Max(2, fCalibration.PointCount + 1);
    for I := 1 to gridPoints.RowCount - 1 do
    begin
      gridPoints.Cells[0, I] := IntToStr(I);
      gridPoints.Cells[1, I] := '';
      gridPoints.Cells[2, I] := '';
    end;
    for I := 0 to fCalibration.PointCount - 1 do
    begin
      lPoint := fCalibration.PointAt(I);
      gridPoints.Cells[0, I + 1] := IntToStr(I + 1);
      gridPoints.Cells[1, I + 1] := FormatFloat('0.######', lPoint.X);
      gridPoints.Cells[2, I + 1] := FormatFloat('0.######', lPoint.Y);
    end;
    UpdateTypeControls;
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderCalibrationPropertiesDialog.ApplyToCalibration;
var
  I: Integer;
  lX: Double;
  lY: Double;
  lScale: Double;
begin
  if fCalibration = nil then
    Exit;
  fCalibration.Name := Trim(edName.Text);
  fCalibration.Description := Trim(edDescription.Text);
  fCalibration.UnitIn := Trim(edUnitIn.Text);
  fCalibration.UnitOut := Trim(edUnitOut.Text);
  fCalibration.Extrapolation := cbExtrapolation.Checked;
  fCalibration.Kind := ComboCalibrationKind;
  if ReadFloat(edScale.Text, lScale) then
    fCalibration.Scale := lScale;
  fCalibration.ClearPoints;
  for I := 1 to gridPoints.RowCount - 1 do
    if ReadFloat(gridPoints.Cells[1, I], lX) and
      ReadFloat(gridPoints.Cells[2, I], lY) then
      fCalibration.AddPoint(lX, lY);
end;

procedure TRecorderCalibrationPropertiesDialog.RenumberPoints;
var
  I: Integer;
begin
  for I := 1 to gridPoints.RowCount - 1 do
    gridPoints.Cells[0, I] := IntToStr(I);
end;

procedure TRecorderCalibrationPropertiesDialog.SelectComboCalibrationKind(
  AKind: TRecorderCalibrationKind);
var
  I: Integer;
begin
  cbType.ItemIndex := 0;
  for I := 0 to cbType.Items.Count - 1 do
    if PtrInt(cbType.Items.Objects[I]) = Ord(AKind) then
    begin
      cbType.ItemIndex := I;
      Exit;
    end;
end;

procedure TRecorderCalibrationPropertiesDialog.UpdateGridColumns;
var
  lWidth: Integer;
begin
  if gridProps <> nil then
    gridProps.ColWidths[1] := Max(80, gridProps.ClientWidth -
      gridProps.ColWidths[0] - 8);

  if gridPoints <> nil then
  begin
    lWidth := Max(80, (gridPoints.ClientWidth - gridPoints.ColWidths[0] - 12) div 2);
    gridPoints.ColWidths[1] := lWidth;
    gridPoints.ColWidths[2] := lWidth;
  end;
end;

procedure TRecorderCalibrationPropertiesDialog.UpdateTypeControls;
var
  lScaleMode: Boolean;
begin
  lScaleMode := ComboCalibrationKind = rckScale;
  gridPoints.Visible := not lScaleMode;
  btnAddPoint.Visible := not lScaleMode;
  btnDeletePoint.Visible := not lScaleMode;
  pnScale.Visible := lScaleMode;
end;

procedure TRecorderCalibrationPropertiesDialog.btnAddPointClick(Sender: TObject);
begin
  gridPoints.RowCount := gridPoints.RowCount + 1;
  RenumberPoints;
  gridPoints.Row := gridPoints.RowCount - 1;
  gridPoints.Col := 1;
  gridPoints.SetFocus;
end;

procedure TRecorderCalibrationPropertiesDialog.btnDeletePointClick(Sender: TObject);
begin
  if (gridPoints.Row > 0) and (gridPoints.RowCount > 2) then
  begin
    gridPoints.DeleteRow(gridPoints.Row);
    RenumberPoints;
  end;
end;

procedure TRecorderCalibrationPropertiesDialog.btnApplyClick(Sender: TObject);
begin
  ApplyToCalibration;
  LoadFromCalibration;
end;

procedure TRecorderCalibrationPropertiesDialog.btnOkClick(Sender: TObject);
begin
  ApplyToCalibration;
  ModalResult := mrOk;
end;

procedure TRecorderCalibrationPropertiesDialog.cbTypeChange(Sender: TObject);
begin
  UpdateTypeControls;
end;

procedure TRecorderCalibrationPropertiesDialog.edScaleChange(Sender: TObject);
var
  lScale: Double;
begin
  if fUpdating then
    Exit;
  if ReadFloat(edScale.Text, lScale) and (lScale <> 0) then
  begin
    fUpdating := True;
    try
      edScaleInv.Text := FormatFloat('0.######', 1 / lScale);
    finally
      fUpdating := False;
    end;
  end;
end;

procedure TRecorderCalibrationPropertiesDialog.edScaleInvChange(Sender: TObject);
var
  lScaleInv: Double;
begin
  if fUpdating then
    Exit;
  if ReadFloat(edScaleInv.Text, lScaleInv) and (lScaleInv <> 0) then
  begin
    fUpdating := True;
    try
      edScale.Text := FormatFloat('0.######', 1 / lScaleInv);
    finally
      fUpdating := False;
    end;
  end;
end;

procedure TRecorderCalibrationPropertiesDialog.FormResize(Sender: TObject);
begin
  UpdateGridColumns;
end;

function ShowRecorderCalibrationPropertiesDialog(AOwner: TComponent;
  ACalibration: TRecorderCalibration): Boolean;
var
  lDialog: TRecorderCalibrationPropertiesDialog;
begin
  lDialog := TRecorderCalibrationPropertiesDialog.Create(AOwner);
  try
    lDialog.EditCalibration(ACalibration);
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

end.
