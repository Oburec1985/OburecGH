unit uRecorderCalibrationPropertiesDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ComCtrls, Grids, ExtCtrls,
  Graphics, Dialogs, LCLIntf, LCLType,
  uRecorderTags, uRecorderUnitManager;

type
  TRecorderCalibrationPropertiesDialog = class(TForm)
    btnAddPoint: TButton;
    btnApply: TButton;
    btnCancel: TButton;
    btnDeletePoint: TButton;
    btnOk: TButton;
    btnOpenSourceFolder: TButton;
    cbExtrapolation: TCheckBox;
    cbType: TComboBox;
    edDescription: TEdit;
    edName: TEdit;
    edOffset: TEdit;
    edScale: TEdit;
    edScaleInv: TEdit;
    edSourceFile: TEdit;
    edUnitIn: TComboBox;
    edUnitOut: TComboBox;
    gridPoints: TStringGrid;
    gridProps: TStringGrid;
    lbChanged: TLabel;
    lbDescription: TLabel;
    lbName: TLabel;
    lbOffset: TLabel;
    lbScale: TLabel;
    lbScaleInv: TLabel;
    lbScaleResult: TLabel;
    lbSourceFile: TLabel;
    lbType: TLabel;
    lbUnitIn: TLabel;
    lbUnitOut: TLabel;
    pcMain: TPageControl;
    pbGraph: TPaintBox;
    pan1: TPanel;
    pan2: TPanel;
    pan3: TPanel;
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
    procedure btnOpenSourceFolderClick(Sender: TObject);
    procedure pbGraphPaint(Sender: TObject);
    procedure UnitComboChange(Sender: TObject);
    procedure UnitComboDropDown(Sender: TObject);
    procedure UnitComboKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    fCalibration: TRecorderCalibration;
    fUpdating: Boolean;
    fUnitNames: TStringList;
    fDisplayedUnitIn: string;
    fDisplayedUnitOut: string;
    function ComboCalibrationKind: TRecorderCalibrationKind;
    function CanonicalUnit(const AUnitName: string): string;
    function ReadFloat(const AText: string; out AValue: Double): Boolean;
    procedure ApplyToCalibration;
    procedure LoadFromCalibration;
    procedure FilterUnitCombo(ACombo: TComboBox);
    procedure ConvertDisplayedInputUnit(const ANewUnit: string);
    procedure ConvertDisplayedOutputUnit(const ANewUnit: string);
    procedure RenumberPoints;
    procedure SelectComboCalibrationKind(AKind: TRecorderCalibrationKind);
    procedure UpdateGridColumns;
    procedure UpdateUnitPresentation;
    procedure UpdateTypeControls;
    procedure UpdateSourceFileControls;
  public
    destructor Destroy; override;
    procedure EditCalibration(ACalibration: TRecorderCalibration);
    procedure EmbedIn(AParent: TWinControl;
      ACalibration: TRecorderCalibration);
    procedure ApplyChanges;
  end;

function ShowRecorderCalibrationPropertiesDialog(AOwner: TComponent;
  ACalibration: TRecorderCalibration): Boolean;

implementation

{$R *.lfm}

procedure TRecorderCalibrationPropertiesDialog.FormCreate(Sender: TObject);
begin
  fUnitNames := TStringList.Create;
  RecorderUnitManager.FillUnitNames(fUnitNames);
  cbType.Items.Clear;
  cbType.Items.AddObject('Масштабный множитель', TObject(PtrInt(Ord(rckScale))));
  cbType.Items.AddObject('Прямая k*x+b', TObject(PtrInt(Ord(rckLinear))));
  cbType.Items.AddObject('Кусочно-линейная интерполяция', TObject(PtrInt(Ord(rckPiecewiseLinear))));
  cbType.Items.AddObject('Полином', TObject(PtrInt(Ord(rckPolynomial))));
  gridProps.ColCount := 2;
  gridProps.RowCount := 2;
  gridProps.FixedRows := 1;
  gridProps.Cells[0, 0] := 'Свойство';
  gridProps.Cells[1, 0] := 'Значение';
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
  edUnitIn.Items.Assign(fUnitNames);
  edUnitOut.Items.Assign(fUnitNames);
  UpdateGridColumns;
  UpdateUnitPresentation;
  UpdateSourceFileControls;
end;

destructor TRecorderCalibrationPropertiesDialog.Destroy;
begin
  FreeAndNil(fUnitNames);
  inherited Destroy;
end;

function TRecorderCalibrationPropertiesDialog.CanonicalUnit(
  const AUnitName: string): string;
var
  lInfo: TRecorderUnitInfo;
begin
  Result := Trim(AUnitName);
  if RecorderUnitManager.TryGetUnitInfo(Result, lInfo) then
    Result := lInfo.Name;
end;

function TRecorderCalibrationPropertiesDialog.ComboCalibrationKind:
  TRecorderCalibrationKind;
begin
  Result := rckPiecewiseLinear;
  if (cbType.ItemIndex >= 0) and
    (cbType.ItemIndex < cbType.Items.Count) then
    Result := TRecorderCalibrationKind(
      PtrInt(cbType.Items.Objects[cbType.ItemIndex]));
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
  UpdateSourceFileControls;
end;

procedure TRecorderCalibrationPropertiesDialog.EmbedIn(AParent: TWinControl;
  ACalibration: TRecorderCalibration);
begin
  BorderStyle := bsNone;
  Parent := AParent;
  Align := alClient;
  pnButtons.Visible := False;
  pcMain.Align := alClient;
  EditCalibration(ACalibration);
  Show;
end;

procedure TRecorderCalibrationPropertiesDialog.ApplyChanges;
begin
  ApplyToCalibration;
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
    fDisplayedUnitIn := CanonicalUnit(fCalibration.UnitIn);
    fDisplayedUnitOut := CanonicalUnit(fCalibration.UnitOut);
    cbExtrapolation.Checked := fCalibration.Extrapolation;
    SelectComboCalibrationKind(fCalibration.Kind);
    if fCalibration.Scale <> 0 then
      edScale.Text := FormatFloat('0.######', 1 / fCalibration.Scale)
    else
      edScale.Text := '';
    edOffset.Text := FormatFloat('0.######', fCalibration.Offset);
    edScaleInv.Text := FormatFloat('0.######', fCalibration.Scale);
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
    pbGraph.Invalidate;
  finally
    fUpdating := False;
  end;
  UpdateUnitPresentation;
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
  ConvertDisplayedInputUnit(CanonicalUnit(edUnitIn.Text));
  ConvertDisplayedOutputUnit(CanonicalUnit(edUnitOut.Text));
  fCalibration.Name := Trim(edName.Text);
  fCalibration.Description := Trim(edDescription.Text);
  fCalibration.UnitIn := CanonicalUnit(edUnitIn.Text);
  fCalibration.UnitOut := CanonicalUnit(edUnitOut.Text);
  fCalibration.Extrapolation := cbExtrapolation.Checked;
  fCalibration.Kind := ComboCalibrationKind;
  if ReadFloat(edScaleInv.Text, lScale) then
    fCalibration.Scale := lScale;
  if ReadFloat(edOffset.Text, lScale) then
    fCalibration.Offset := lScale;
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
  lKind: TRecorderCalibrationKind;
  lFormulaMode: Boolean;
begin
  lKind := ComboCalibrationKind;
  lFormulaMode := lKind in [rckScale, rckLinear];
  gridPoints.Visible := not lFormulaMode;
  btnAddPoint.Visible := not lFormulaMode;
  btnDeletePoint.Visible := not lFormulaMode;
  pnScale.Visible := lFormulaMode;
  lbOffset.Visible := lKind = rckLinear;
  edOffset.Visible := lKind = rckLinear;
  if lKind = rckPolynomial then
  begin
    gridPoints.Cells[1, 0] := 'Степень';
    gridPoints.Cells[2, 0] := 'Коэффициент';
  end
  else
    UpdateUnitPresentation;
  pbGraph.Invalidate;
end;

procedure TRecorderCalibrationPropertiesDialog.ConvertDisplayedInputUnit(
  const ANewUnit: string);
var
  I, lDegree: Integer;
  lFactor, lValue: Double;
begin
  if (ANewUnit = '') or (fDisplayedUnitIn = '') or
    SameText(ANewUnit, fDisplayedUnitIn) or
    not RecorderUnitManager.TryGetConversionFactor(fDisplayedUnitIn,
      ANewUnit, lFactor) then
    Exit;
  if ComboCalibrationKind in [rckScale, rckLinear] then
  begin
    if ReadFloat(edScale.Text, lValue) then
      edScale.Text := FormatFloat('0.############', lValue * lFactor);
  end
  else if ComboCalibrationKind = rckPiecewiseLinear then
  begin
    for I := 1 to gridPoints.RowCount - 1 do
      if ReadFloat(gridPoints.Cells[1, I], lValue) then
        gridPoints.Cells[1, I] := FormatFloat('0.############', lValue * lFactor);
  end
  else if ComboCalibrationKind = rckPolynomial then
  begin
    for I := 1 to gridPoints.RowCount - 1 do
      if ReadFloat(gridPoints.Cells[1, I], lValue) then
      begin
        lDegree := Max(0, Round(lValue));
        if ReadFloat(gridPoints.Cells[2, I], lValue) then
          gridPoints.Cells[2, I] := FormatFloat('0.############',
            lValue / IntPower(lFactor, lDegree));
      end;
  end;
  fDisplayedUnitIn := ANewUnit;
  edScaleChange(edScale);
end;

procedure TRecorderCalibrationPropertiesDialog.ConvertDisplayedOutputUnit(
  const ANewUnit: string);
var
  I: Integer;
  lFactor, lValue: Double;
begin
  if (ANewUnit = '') or (fDisplayedUnitOut = '') or
    SameText(ANewUnit, fDisplayedUnitOut) or
    not RecorderUnitManager.TryGetConversionFactor(fDisplayedUnitOut,
      ANewUnit, lFactor) then
    Exit;
  if ComboCalibrationKind in [rckScale, rckLinear] then
  begin
    if ReadFloat(edScale.Text, lValue) then
      edScale.Text := FormatFloat('0.############', lValue / lFactor);
    if (ComboCalibrationKind = rckLinear) and ReadFloat(edOffset.Text, lValue) then
      edOffset.Text := FormatFloat('0.############', lValue * lFactor);
  end
  else
    for I := 1 to gridPoints.RowCount - 1 do
      if ReadFloat(gridPoints.Cells[2, I], lValue) then
        gridPoints.Cells[2, I] := FormatFloat('0.############', lValue * lFactor);
  fDisplayedUnitOut := ANewUnit;
  edScaleChange(edScale);
end;

procedure TRecorderCalibrationPropertiesDialog.FilterUnitCombo(
  ACombo: TComboBox);
var
  lSelectionStart: Integer;
  lText: string;
begin
  if (ACombo = nil) or (fUnitNames = nil) or fUpdating then
    Exit;
  lText := ACombo.Text;
  lSelectionStart := ACombo.SelStart;
  fUpdating := True;
  try
    RecorderUnitManager.FillUnitNames(ACombo.Items, lText);
    ACombo.Text := lText;
    ACombo.SelStart := lSelectionStart;
  finally
    fUpdating := False;
  end;
end;

procedure TRecorderCalibrationPropertiesDialog.UpdateUnitPresentation;
var
  lInfo: TRecorderUnitInfo;
  lUnitIn, lUnitOut, lRatio: string;
begin
  lUnitIn := CanonicalUnit(edUnitIn.Text);
  lUnitOut := CanonicalUnit(edUnitOut.Text);
  lbUnitIn.Caption := 'Вход';
  if RecorderUnitManager.TryGetUnitInfo(lUnitIn, lInfo) then
    lbUnitIn.Caption := UTF8Decode('Вход — ' +
      RecorderUnitManager.QuantityCaption(lInfo.QuantityId));
  lbUnitOut.Caption := 'Выход';
  if RecorderUnitManager.TryGetUnitInfo(lUnitOut, lInfo) then
    lbUnitOut.Caption := UTF8Decode('Выход — ' +
      RecorderUnitManager.QuantityCaption(lInfo.QuantityId));

  if lUnitIn = '' then lUnitIn := '?';
  if lUnitOut = '' then lUnitOut := '?';
  lRatio := lUnitOut + '/' + lUnitIn;
  lbScale.Caption := UTF8Decode('Чувствительность [' + lUnitIn + '/' +
    lUnitOut + ']:');
  lbScaleInv.Caption := UTF8Decode('Масштаб [' + lRatio + ']:');
  lbOffset.Caption := UTF8Decode('Смещение b [' + lUnitOut + ']:');
  if ComboCalibrationKind = rckLinear then
    lbScaleResult.Caption := UTF8Decode('Результат: y [' + lUnitOut +
      '] = Масштаб [' + lRatio + '] × x [' + lUnitIn + '] + b [' + lUnitOut + ']')
  else
    lbScaleResult.Caption := UTF8Decode('Результат: y [' + lUnitOut +
      '] = x / Чувствительность = Масштаб [' + lRatio + '] × x [' +
      lUnitIn + ']');
  if ComboCalibrationKind = rckPolynomial then
  begin
    gridPoints.Cells[1, 0] := 'Степень';
    gridPoints.Cells[2, 0] := 'Коэффициент';
  end
  else
  begin
    gridPoints.Cells[1, 0] := 'X(i), ' + lUnitIn;
    gridPoints.Cells[2, 0] := 'Y(i), ' + lUnitOut;
  end;
end;

procedure TRecorderCalibrationPropertiesDialog.UnitComboChange(Sender: TObject);
var
  lInfo: TRecorderUnitInfo;
  lUnitName: string;
begin
  if fUpdating or not (Sender is TComboBox) then
    Exit;
  FilterUnitCombo(TComboBox(Sender));
  lUnitName := CanonicalUnit(TComboBox(Sender).Text);
  if RecorderUnitManager.TryGetUnitInfo(lUnitName, lInfo) then
  begin
    if Sender = edUnitIn then
      ConvertDisplayedInputUnit(lUnitName)
    else if Sender = edUnitOut then
      ConvertDisplayedOutputUnit(lUnitName);
  end;
  UpdateUnitPresentation;
  if TComboBox(Sender).Focused and
    (TComboBox(Sender).Items.Count > 0) then
    TComboBox(Sender).DroppedDown := True;
end;

procedure TRecorderCalibrationPropertiesDialog.UnitComboKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
var
  lCombo: TComboBox;
begin
  if (Key <> VK_RETURN) or not (Sender is TComboBox) then
    Exit;
  lCombo := TComboBox(Sender);
  lCombo.DroppedDown := False;
  UnitComboChange(lCombo);
  { Enter завершает ввод единицы, но не доходит до
    Default-кнопки OK формы. }
  Key := 0;
end;

procedure TRecorderCalibrationPropertiesDialog.UnitComboDropDown(Sender: TObject);
begin
  if Sender is TComboBox then
    FilterUnitCombo(TComboBox(Sender));
end;

procedure TRecorderCalibrationPropertiesDialog.UpdateSourceFileControls;
var
  lSourceFileName: string;
begin
  lSourceFileName := '';
  if fCalibration <> nil then
    lSourceFileName := Trim(fCalibration.SourceFileName);
  edSourceFile.Text := lSourceFileName;
  edSourceFile.Hint := lSourceFileName;
  edSourceFile.ShowHint := lSourceFileName <> '';
  btnOpenSourceFolder.Enabled := (lSourceFileName <> '') and
    DirectoryExists(ExtractFileDir(ExpandFileName(lSourceFileName)));
end;

procedure TRecorderCalibrationPropertiesDialog.btnOpenSourceFolderClick(
  Sender: TObject);
var
  lDirectory: string;
begin
  if (fCalibration = nil) or (Trim(fCalibration.SourceFileName) = '') then
    Exit;
  lDirectory := ExtractFileDir(ExpandFileName(fCalibration.SourceFileName));
  if not DirectoryExists(lDirectory) then
  begin
    MessageDlg('Каталог ГХ не найден:' + LineEnding + lDirectory,
      mtWarning, [mbOK], 0);
    Exit;
  end;
  if not OpenDocument(lDirectory) then
    MessageDlg('Не удалось открыть каталог ГХ:' + LineEnding + lDirectory,
      mtWarning, [mbOK], 0);
end;

procedure TRecorderCalibrationPropertiesDialog.pbGraphPaint(Sender: TObject);
const
  CGraphMargin = 44;
var
  I: Integer;
  lArea: TRect;
  lPoint: TRecorderCalibrationPoint;
  lMinX, lMaxX, lMinY, lMaxY: Double;
  lX, lY: Integer;

  function GraphX(AValue: Double): Integer;
  begin
    Result := lArea.Left + Round((AValue - lMinX) /
      (lMaxX - lMinX) * (lArea.Right - lArea.Left));
  end;

  function GraphY(AValue: Double): Integer;
  begin
    Result := lArea.Bottom - Round((AValue - lMinY) /
      (lMaxY - lMinY) * (lArea.Bottom - lArea.Top));
  end;

  procedure IncludePoint(AX, AY: Double);
  begin
    lMinX := Min(lMinX, AX);
    lMaxX := Max(lMaxX, AX);
    lMinY := Min(lMinY, AY);
    lMaxY := Max(lMaxY, AY);
  end;

begin
  pbGraph.Canvas.Brush.Color := clWindow;
  pbGraph.Canvas.FillRect(pbGraph.ClientRect);
  lArea := Rect(CGraphMargin, 16, pbGraph.ClientWidth - 16,
    pbGraph.ClientHeight - CGraphMargin);
  if (fCalibration = nil) or (lArea.Right <= lArea.Left) or
    (lArea.Bottom <= lArea.Top) then
    Exit;

  lMinX := MaxDouble;
  lMaxX := -MaxDouble;
  lMinY := MaxDouble;
  lMaxY := -MaxDouble;
  if fCalibration.Kind in [rckScale, rckLinear] then
  begin
    IncludePoint(-1, -fCalibration.Scale + fCalibration.Offset);
    IncludePoint(1, fCalibration.Scale + fCalibration.Offset);
  end
  else
    for I := 0 to fCalibration.PointCount - 1 do
    begin
      lPoint := fCalibration.PointAt(I);
      IncludePoint(lPoint.X, lPoint.Y);
    end;
  if lMinX = MaxDouble then
  begin
    pbGraph.Canvas.TextOut(16, 16, 'Нет точек для построения графика');
    Exit;
  end;
  if SameValue(lMinX, lMaxX) then
  begin
    lMinX := lMinX - 1;
    lMaxX := lMaxX + 1;
  end;
  if SameValue(lMinY, lMaxY) then
  begin
    lMinY := lMinY - 1;
    lMaxY := lMaxY + 1;
  end;

  pbGraph.Canvas.Pen.Color := clGray;
  pbGraph.Canvas.Rectangle(lArea);
  if (lMinX <= 0) and (lMaxX >= 0) then
  begin
    lX := GraphX(0);
    pbGraph.Canvas.Line(lX, lArea.Top, lX, lArea.Bottom);
  end;
  if (lMinY <= 0) and (lMaxY >= 0) then
  begin
    lY := GraphY(0);
    pbGraph.Canvas.Line(lArea.Left, lY, lArea.Right, lY);
  end;
  pbGraph.Canvas.TextOut(lArea.Left, lArea.Bottom + 6,
    FormatFloat('0.###', lMinX));
  pbGraph.Canvas.TextOut(lArea.Right - 54, lArea.Bottom + 6,
    FormatFloat('0.###', lMaxX));
  pbGraph.Canvas.TextOut(4, lArea.Top, FormatFloat('0.###', lMaxY));
  pbGraph.Canvas.TextOut(4, lArea.Bottom - 14, FormatFloat('0.###', lMinY));

  pbGraph.Canvas.Pen.Color := clBlue;
  pbGraph.Canvas.Pen.Width := 2;
  if fCalibration.Kind in [rckScale, rckLinear] then
  begin
    pbGraph.Canvas.MoveTo(GraphX(-1),
      GraphY(-fCalibration.Scale + fCalibration.Offset));
    pbGraph.Canvas.LineTo(GraphX(1),
      GraphY(fCalibration.Scale + fCalibration.Offset));
  end
  else if fCalibration.PointCount > 0 then
  begin
    lPoint := fCalibration.PointAt(0);
    pbGraph.Canvas.MoveTo(GraphX(lPoint.X), GraphY(lPoint.Y));
    for I := 1 to fCalibration.PointCount - 1 do
    begin
      lPoint := fCalibration.PointAt(I);
      pbGraph.Canvas.LineTo(GraphX(lPoint.X), GraphY(lPoint.Y));
    end;
  end;
  pbGraph.Canvas.Pen.Width := 1;
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
  pbGraph.Invalidate;
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
  lSensitivity: Double;
begin
  if fUpdating then
    Exit;
  if ReadFloat(edScale.Text, lSensitivity) and (lSensitivity <> 0) then
  begin
    fUpdating := True;
    try
      edScaleInv.Text := FormatFloat('0.######', 1 / lSensitivity);
    finally
      fUpdating := False;
    end;
  end;
end;

procedure TRecorderCalibrationPropertiesDialog.edScaleInvChange(Sender: TObject);
var
  lScale: Double;
begin
  if fUpdating then
    Exit;
  if ReadFloat(edScaleInv.Text, lScale) and (lScale <> 0) then
  begin
    fUpdating := True;
    try
      edScale.Text := FormatFloat('0.######', 1 / lScale);
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
