unit uRecorderCalibrationListDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, Grids, Dialogs,
  uRecorderTags, uRecorderCalibrationAddDialog,
  uRecorderCalibrationPropertiesDialog, uRecorderSdbStore,
  uRecorderStrainCalibrationDialog,
  uRecorderSdbSelectDialog, uRecorderUnitManager;

type
  TRecorderCalibrationListDialog = class(TForm)
    btnAdd: TButton;
    btnCancel: TButton;
    btnDelete: TButton;
    btnDown: TButton;
    btnOk: TButton;
    btnProperties: TButton;
    btnUp: TButton;
    cbPipelineEnabled: TCheckBox;
    gridList: TStringGrid;
    lbPipelineSensitivity: TLabel;
    pnlBottom: TPanel;
    pnlPipeline: TPanel;
    splPipeline: TSplitter;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnPropertiesClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure gridListClick(Sender: TObject);
    procedure gridListDblClick(Sender: TObject);
  private
    fList: TRecorderCalibrationList;
    fPipelineNames: TStrings;
    fPipelineMode: Boolean;
    fPickMode: Boolean;
    procedure RefreshGrid;
    procedure RefreshPipelineSensitivity;
    procedure LayoutBottomPanel;
    procedure UpdateGridColumns;
    function TryGetPipelineSensitivity(out AValue: Double;
      out AUnitIn, AUnitOut: string): Boolean;
    function TryGetCalibrationScaleFactor(ACalibration: TRecorderCalibration;
      out AScale: Double): Boolean;
    function CurrentIndex: Integer;
    function CalibrationByName(const AName: string): TRecorderCalibration;
  public
    procedure EditList(AList: TRecorderCalibrationList);
    procedure PickListItem(AList: TRecorderCalibrationList);
    procedure EditPipeline(AList: TRecorderCalibrationList;
      APipelineNames: TStrings);
    procedure PickPipelineItem(AList: TRecorderCalibrationList;
      APipelineNames: TStrings);
  end;

function ShowRecorderCalibrationListDialog(AOwner: TComponent;
  AList: TRecorderCalibrationList; out ASelected: TRecorderCalibration): Boolean;
function ShowRecorderCalibrationPipelineDialog(AOwner: TComponent;
  AList: TRecorderCalibrationList; APipelineNames: TStrings): Boolean;
function ShowRecorderCalibrationPipelineItemDialog(AOwner: TComponent;
  AList: TRecorderCalibrationList; APipelineNames: TStrings;
  out ASelectedIndex: Integer): Boolean;

implementation

{$R *.lfm}

procedure TRecorderCalibrationListDialog.FormCreate(Sender: TObject);
begin
  cbPipelineEnabled.Visible := False;
  gridList.ColCount := 4;
  gridList.RowCount := 2;
  gridList.FixedRows := 1;
  gridList.FixedCols := 0;
  gridList.Cells[0, 0] := '№';
  gridList.Cells[1, 0] := 'Имя';
  gridList.Cells[2, 0] := 'ед';
  gridList.Cells[3, 0] := 'Вкл';
  gridList.Hint := 'ГХ применяются к входу сверху вниз';
  gridList.ShowHint := True;
  UpdateGridColumns;
  LayoutBottomPanel;
end;

procedure TRecorderCalibrationListDialog.LayoutBottomPanel;
const
  CMargin = 8;
  CGap = 5;
var
  lLabelTop: Integer;
begin
  if (pnlBottom = nil) or (btnOk = nil) then
    Exit;
  btnOk.Top := pnlBottom.ClientHeight - CMargin - btnOk.Height;
  btnCancel.Top := btnOk.Top;
  lLabelTop := btnAdd.Top + btnAdd.Height + CGap;
  lbPipelineSensitivity.Top := lLabelTop;
  lbPipelineSensitivity.Height := Max(34,
    btnOk.Top - CGap - lLabelTop);
end;

procedure TRecorderCalibrationListDialog.UpdateGridColumns;
begin
  if gridList = nil then
    Exit;
  gridList.ColWidths[0] := 38;
  gridList.ColWidths[2] := 80;
  if fPipelineMode then
    gridList.ColWidths[3] := 46
  else
    gridList.ColWidths[3] := 0;
  gridList.ColWidths[1] := Max(100, gridList.ClientWidth -
    gridList.ColWidths[0] - gridList.ColWidths[2] -
    gridList.ColWidths[3] - 8);
end;

procedure TRecorderCalibrationListDialog.EditList(AList: TRecorderCalibrationList);
begin
  fList := AList;
  fPipelineNames := nil;
  fPipelineMode := False;
  fPickMode := False;
  RefreshGrid;
end;

procedure TRecorderCalibrationListDialog.PickListItem(
  AList: TRecorderCalibrationList);
begin
  EditList(AList);
  fPickMode := True;
  btnAdd.Visible := False;
  btnDelete.Visible := False;
  btnProperties.Visible := False;
  btnUp.Visible := False;
  btnDown.Visible := False;
  cbPipelineEnabled.Visible := False;
  btnOk.Caption := 'Добавить выбранную';
  Caption := 'Выберите одну ГХ для добавления в цепочку';
end;

procedure TRecorderCalibrationListDialog.EditPipeline(AList: TRecorderCalibrationList;
  APipelineNames: TStrings);
begin
  fList := AList;
  fPipelineNames := APipelineNames;
  fPipelineMode := True;
  fPickMode := False;
  { Кнопка скрыта для компактности; двойной щелчок открывает свойства
    выбранной ступени pipeline. }
  btnProperties.Visible := False;
  cbPipelineEnabled.Visible := False;
  RefreshGrid;
end;

procedure TRecorderCalibrationListDialog.PickPipelineItem(
  AList: TRecorderCalibrationList; APipelineNames: TStrings);
begin
  fList := AList;
  fPipelineNames := APipelineNames;
  fPipelineMode := True;
  fPickMode := True;
  btnAdd.Visible := False;
  btnDelete.Visible := False;
  btnProperties.Visible := False;
  btnUp.Visible := False;
  btnDown.Visible := False;
  cbPipelineEnabled.Visible := False;
  btnOk.Caption := 'Выбрать';
  RefreshGrid;
  Caption := 'Выбор ГХ для редактирования';
end;

function TRecorderCalibrationListDialog.CurrentIndex: Integer;
begin
  Result := gridList.Row - 1;
  if (fList = nil) or (Result < 0) or
    ((not fPipelineMode) and (Result >= fList.Count)) or
    (fPipelineMode and ((fPipelineNames = nil) or
    (Result >= fPipelineNames.Count))) then
    Result := -1;
end;

procedure TRecorderCalibrationListDialog.RefreshGrid;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
begin
  if fList = nil then
    Exit;

  if fPipelineMode then
  begin
    if fPipelineNames = nil then
      Exit;
    if not fPickMode then
      Caption := 'Настройка Мульти ГХ';
    gridList.RowCount := Max(2, fPipelineNames.Count + 1);
    for I := 1 to gridList.RowCount - 1 do
    begin
      gridList.Cells[0, I] := '';
      gridList.Cells[1, I] := '';
      gridList.Cells[2, I] := '';
      gridList.Cells[3, I] := '';
    end;
    for I := 0 to fPipelineNames.Count - 1 do
    begin
      lCalibration := CalibrationByName(fPipelineNames[I]);
      gridList.Cells[0, I + 1] := IntToStr(I + 1);
      gridList.Cells[1, I + 1] := fPipelineNames[I];
      if lCalibration <> nil then
        gridList.Cells[2, I + 1] := lCalibration.UnitOut;
      if RecorderCalibrationStepEnabled(fPipelineNames, I) then
        gridList.Cells[3, I + 1] := 'Да'
      else
        gridList.Cells[3, I + 1] := 'Нет';
    end;
    RefreshPipelineSensitivity;
    Exit;
  end;

  Caption := 'Список ГХ';
  gridList.RowCount := Max(2, fList.Count + 1);
  for I := 1 to gridList.RowCount - 1 do
  begin
    gridList.Cells[0, I] := '';
    gridList.Cells[1, I] := '';
      gridList.Cells[2, I] := '';
      gridList.Cells[3, I] := '';
  end;
  for I := 0 to fList.Count - 1 do
  begin
    lCalibration := fList[I];
    gridList.Cells[0, I + 1] := IntToStr(I + 1);
    gridList.Cells[1, I + 1] := lCalibration.Name;
    gridList.Cells[2, I + 1] := lCalibration.UnitOut;
    gridList.Cells[3, I + 1] := '';
  end;
end;

function TRecorderCalibrationListDialog.CalibrationByName(
  const AName: string): TRecorderCalibration;
var
  I: Integer;
begin
  Result := nil;
  if fList = nil then
    Exit;
  for I := 0 to fList.Count - 1 do
    if (fList[I] <> nil) and SameText(fList[I].Name, AName) then
      Exit(fList[I]);
end;

procedure TRecorderCalibrationListDialog.btnAddClick(Sender: TObject);
var
  lAction: TRecorderCalibrationAddAction;
  lCalibrationName: string;
  lKey: string;
  lKind: TRecorderCalibrationKind;
  lCalibration: TRecorderCalibration;
  lSelected: TRecorderCalibration;
begin
  if fList = nil then
    Exit;

  if fPipelineMode then
  begin
    lSelected := nil;
    if ShowRecorderCalibrationListDialog(Self, fList, lSelected) and
      (lSelected <> nil) and (fPipelineNames <> nil) then
    begin
      fPipelineNames.Add(lSelected.Name);
      RefreshGrid;
    end;
    Exit;
  end;

  if not ShowRecorderCalibrationAddDialog(Self, lKind, lAction) then
    Exit;
  if lAction = rcaaLoadFromSdb then
  begin
    if ShowRecorderSdbSelectDialog(Self, '', lKey) and
      RecorderSdbImportCalibration(fList, lKey, lCalibrationName) then
      RefreshGrid;
    Exit;
  end;
  lCalibration := TRecorderCalibration.Create(lKind);
  try
    if lKind in [rckPiecewiseLinear, rckPolynomial] then
    begin
      lCalibration.AddPoint(0, 0);
      lCalibration.AddPoint(1, 1);
    end;
    if (((lKind = rckStrain) and
      ShowRecorderStrainCalibrationDialog(Self, lCalibration)) or
      ((lKind <> rckStrain) and
      ShowRecorderCalibrationPropertiesDialog(Self, lCalibration))) then
    begin
      fList.Add(lCalibration);
      lCalibration := nil;
      RefreshGrid;
    end;
  finally
    lCalibration.Free;
  end;
end;

procedure TRecorderCalibrationListDialog.btnDeleteClick(Sender: TObject);
var
  lIndex: Integer;
begin
  lIndex := CurrentIndex;
  if lIndex < 0 then
    Exit;
  if fPipelineMode then
    fPipelineNames.Delete(lIndex)
  else
    fList.Delete(lIndex);
  RefreshGrid;
end;

procedure TRecorderCalibrationListDialog.btnPropertiesClick(Sender: TObject);
var
  I: Integer;
  lIndex: Integer;
  lCalibration: TRecorderCalibration;
  lDraft: TRecorderCalibration;
  lError: string;
  lOldName: string;
  lSdbKey: string;
begin
  lIndex := CurrentIndex;
  if lIndex < 0 then
    Exit;

  if fPipelineMode then
    lCalibration := CalibrationByName(fPipelineNames[lIndex])
  else
    lCalibration := fList[lIndex];
  if lCalibration = nil then
    Exit;

  lDraft := lCalibration.Clone;
  try
    if not (((lDraft.Kind = rckStrain) and
      ShowRecorderStrainCalibrationDialog(Self, lDraft)) or
      ((lDraft.Kind <> rckStrain) and
      ShowRecorderCalibrationPropertiesDialog(Self, lDraft))) then
      Exit;

    if Trim(lDraft.Name) = '' then
    begin
      MessageDlg('Сохранение ГХ', 'Имя ГХ не может быть пустым.',
        mtError, [mbOK], 0);
      Exit;
    end;
    for I := 0 to fList.Count - 1 do
      if (fList[I] <> lCalibration) and
        SameText(Trim(fList[I].Name), Trim(lDraft.Name)) then
      begin
        MessageDlg('Сохранение ГХ', 'ГХ с именем «' + Trim(lDraft.Name) +
          '» уже существует.', mtError, [mbOK], 0);
        Exit;
      end;

    lOldName := lCalibration.Name;
    lSdbKey := Trim(lCalibration.SdbKey);
    if not RecorderSdbUpdateLinkedCalibration(lCalibration, lDraft,
      lError) then
    begin
      MessageDlg('Сохранение ГХ',
        'Не удалось обновить ГХ в БДГХ:' + LineEnding + lError,
        mtError, [mbOK], 0);
      Exit;
    end;

    lCalibration.Assign(lDraft);
    if lSdbKey <> '' then
      lCalibration.SdbKey := lSdbKey;
    if fPipelineMode and (fPipelineNames <> nil) and
      (lIndex < fPipelineNames.Count) and
      SameText(fPipelineNames[lIndex], lOldName) then
      fPipelineNames[lIndex] := lCalibration.Name;
    RefreshGrid;
  finally
    lDraft.Free;
  end;
end;

function TRecorderCalibrationListDialog.TryGetPipelineSensitivity(
  out AValue: Double; out AUnitIn, AUnitOut: string): Boolean;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lConversion: Double;
  lScale: Double;
  lPreviousUnit: string;
begin
  Result := False;
  AValue := 1.0;
  AUnitIn := '';
  AUnitOut := '';
  lPreviousUnit := '';
  if (fPipelineNames = nil) or (fPipelineNames.Count = 0) then
    Exit;

  for I := 0 to fPipelineNames.Count - 1 do
  begin
    if not RecorderCalibrationStepEnabled(fPipelineNames, I) then
      Continue;
    lCalibration := CalibrationByName(fPipelineNames[I]);
    if not TryGetCalibrationScaleFactor(lCalibration, lScale) then
      Exit;
    if AUnitIn = '' then
      AUnitIn := Trim(lCalibration.UnitIn)
    else if (lPreviousUnit <> '') and (Trim(lCalibration.UnitIn) <> '') and
      not SameText(lPreviousUnit, Trim(lCalibration.UnitIn)) then
    begin
      if not RecorderUnitManager.TryGetConversionFactor(lPreviousUnit,
        Trim(lCalibration.UnitIn), lConversion) then
        Exit;
      AValue := AValue * lConversion;
    end;
    AValue := AValue * lScale;
    lPreviousUnit := Trim(lCalibration.UnitOut);
  end;
  AUnitOut := lPreviousUnit;
  if SameValue(AValue, 0.0) then
    Exit;
  AValue := 1 / AValue;
  Result := True;
end;

function TRecorderCalibrationListDialog.TryGetCalibrationScaleFactor(
  ACalibration: TRecorderCalibration; out AScale: Double): Boolean;
var
  lA: TRecorderCalibrationPoint;
  lB: TRecorderCalibrationPoint;
  lOffset: Double;
begin
  Result := False;
  AScale := 0;
  if ACalibration = nil then
    Exit;
  case ACalibration.Kind of
    rckScale:
      AScale := ACalibration.Scale;
    rckLinear:
      begin
        if not SameValue(ACalibration.Offset, 0.0) then
          Exit;
        AScale := ACalibration.Scale;
      end;
    rckPiecewiseLinear:
      begin
        { Старые SDB сохраняли масштаб как таблицу из точек. Такая таблица
          остаётся линейным множителем, если содержит ровно одну прямую,
          проходящую через начало координат. }
        if ACalibration.PointCount <> 2 then
          Exit;
        lA := ACalibration.PointAt(0);
        lB := ACalibration.PointAt(1);
        if (lA = nil) or (lB = nil) or SameValue(lA.X, lB.X) then
          Exit;
        AScale := (lB.Y - lA.Y) / (lB.X - lA.X);
        lOffset := lA.Y - AScale * lA.X;
        if not SameValue(lOffset, 0.0) then
          Exit;
      end;
  else
    Exit;
  end;
  Result := not SameValue(AScale, 0.0);
end;

procedure TRecorderCalibrationListDialog.RefreshPipelineSensitivity;
var
  lUnitIn: string;
  lUnitOut: string;
  lValue: Double;
begin
  lbPipelineSensitivity.Visible := fPipelineMode and not fPickMode;
  if not lbPipelineSensitivity.Visible then
    Exit;
  if TryGetPipelineSensitivity(lValue, lUnitIn, lUnitOut) then
  begin
    if (lUnitIn <> '') and (lUnitOut <> '') then
      lbPipelineSensitivity.Caption := 'Сквозная чувствительность: ' +
        FormatFloat('0.###############', lValue) + ' ' + lUnitIn + '/' + lUnitOut
    else
      lbPipelineSensitivity.Caption := 'Сквозная чувствительность: ' +
        FormatFloat('0.###############', lValue);
  end
  else if (fPipelineNames = nil) or (fPipelineNames.Count = 0) then
    lbPipelineSensitivity.Caption := 'Сквозная чувствительность: цепочка пуста'
  else
    lbPipelineSensitivity.Caption :=
      'Сквозная чувствительность: нелинейная или несовместимые единицы';
end;

procedure TRecorderCalibrationListDialog.gridListClick(Sender: TObject);
var
  lIndex: Integer;
begin
  if (not fPipelineMode) or fPickMode or (gridList.Col <> 3) then
    Exit;
  lIndex := CurrentIndex;
  if lIndex < 0 then
    Exit;
  RecorderSetCalibrationStepEnabled(fPipelineNames, lIndex,
    not RecorderCalibrationStepEnabled(fPipelineNames, lIndex));
  RefreshGrid;
  gridList.Row := lIndex + 1;
  gridList.Col := 3;
end;

procedure TRecorderCalibrationListDialog.btnUpClick(Sender: TObject);
var
  lIndex: Integer;
begin
  lIndex := CurrentIndex;
  if lIndex <= 0 then
    Exit;
  if fPipelineMode then
    fPipelineNames.Exchange(lIndex, lIndex - 1)
  else
    fList.Exchange(lIndex, lIndex - 1);
  RefreshGrid;
  gridList.Row := lIndex;
end;

procedure TRecorderCalibrationListDialog.btnDownClick(Sender: TObject);
var
  lIndex: Integer;
begin
  lIndex := CurrentIndex;
  if (lIndex < 0) or
    ((not fPipelineMode) and (lIndex >= fList.Count - 1)) or
    (fPipelineMode and ((fPipelineNames = nil) or
    (lIndex >= fPipelineNames.Count - 1))) then
    Exit;
  if fPipelineMode then
    fPipelineNames.Exchange(lIndex, lIndex + 1)
  else
    fList.Exchange(lIndex, lIndex + 1);
  RefreshGrid;
  gridList.Row := lIndex + 2;
end;

procedure TRecorderCalibrationListDialog.FormResize(Sender: TObject);
begin
  UpdateGridColumns;
  LayoutBottomPanel;
end;

procedure TRecorderCalibrationListDialog.gridListDblClick(Sender: TObject);
begin
  if fPipelineMode and (gridList.Col = 3) then
    Exit;
  if fPickMode and (CurrentIndex >= 0) then
    ModalResult := mrOk
  else
    btnPropertiesClick(Sender);
end;

function ShowRecorderCalibrationListDialog(AOwner: TComponent;
  AList: TRecorderCalibrationList; out ASelected: TRecorderCalibration): Boolean;
var
  lDialog: TRecorderCalibrationListDialog;
begin
  lDialog := TRecorderCalibrationListDialog.Create(AOwner);
  try
    lDialog.PickListItem(AList);
    Result := lDialog.ShowModal = mrOk;
    ASelected := nil;
    if Result and (lDialog.CurrentIndex >= 0) then
      ASelected := AList[lDialog.CurrentIndex];
  finally
    lDialog.Free;
  end;
end;

function ShowRecorderCalibrationPipelineDialog(AOwner: TComponent;
  AList: TRecorderCalibrationList; APipelineNames: TStrings): Boolean;
var
  lDialog: TRecorderCalibrationListDialog;
  lWorkingNames: TStringList;
begin
  lWorkingNames := TStringList.Create;
  lDialog := TRecorderCalibrationListDialog.Create(AOwner);
  try
    if APipelineNames <> nil then
      lWorkingNames.Assign(APipelineNames);
    lDialog.EditPipeline(AList, lWorkingNames);
    Result := lDialog.ShowModal = mrOk;
    if Result and (APipelineNames <> nil) then
    begin
      APipelineNames.Assign(lWorkingNames);
    end;
  finally
    lDialog.Free;
    lWorkingNames.Free;
  end;
end;

function ShowRecorderCalibrationPipelineItemDialog(AOwner: TComponent;
  AList: TRecorderCalibrationList; APipelineNames: TStrings;
  out ASelectedIndex: Integer): Boolean;
var
  lDialog: TRecorderCalibrationListDialog;
begin
  ASelectedIndex := -1;
  lDialog := TRecorderCalibrationListDialog.Create(AOwner);
  try
    lDialog.PickPipelineItem(AList, APipelineNames);
    Result := lDialog.ShowModal = mrOk;
    if Result then
      ASelectedIndex := lDialog.CurrentIndex;
    Result := Result and (ASelectedIndex >= 0);
  finally
    lDialog.Free;
  end;
end;

end.
