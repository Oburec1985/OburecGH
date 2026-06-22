unit uRecorderCalibrationListDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, StdCtrls, Grids,
  uRecorderTags, uRecorderCalibrationAddDialog,
  uRecorderCalibrationPropertiesDialog, uRecorderSdbStore,
  uRecorderSdbSelectDialog;

type
  TRecorderCalibrationListDialog = class(TForm)
    btnAdd: TButton;
    btnCancel: TButton;
    btnDelete: TButton;
    btnDown: TButton;
    btnOk: TButton;
    btnProperties: TButton;
    btnUp: TButton;
    gridList: TStringGrid;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnPropertiesClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure gridListDblClick(Sender: TObject);
  private
    fList: TRecorderCalibrationList;
    fPipelineNames: TStrings;
    fPipelineMode: Boolean;
    procedure RefreshGrid;
    procedure UpdateGridColumns;
    function CurrentIndex: Integer;
    function CalibrationByName(const AName: string): TRecorderCalibration;
  public
    procedure EditList(AList: TRecorderCalibrationList);
    procedure EditPipeline(AList: TRecorderCalibrationList; APipelineNames: TStrings);
  end;

function ShowRecorderCalibrationListDialog(AOwner: TComponent;
  AList: TRecorderCalibrationList; out ASelected: TRecorderCalibration): Boolean;
function ShowRecorderCalibrationPipelineDialog(AOwner: TComponent;
  AList: TRecorderCalibrationList; APipelineNames: TStrings): Boolean;

implementation

{$R *.lfm}

procedure TRecorderCalibrationListDialog.FormCreate(Sender: TObject);
begin
  gridList.ColCount := 2;
  gridList.RowCount := 2;
  gridList.FixedRows := 1;
  gridList.FixedCols := 0;
  gridList.Cells[0, 0] := 'Имя';
  gridList.Cells[1, 0] := 'ед';
  UpdateGridColumns;
end;

procedure TRecorderCalibrationListDialog.UpdateGridColumns;
begin
  if gridList = nil then
    Exit;
  gridList.ColWidths[1] := 80;
  gridList.ColWidths[0] := Max(120, gridList.ClientWidth -
    gridList.ColWidths[1] - 8);
end;

procedure TRecorderCalibrationListDialog.EditList(AList: TRecorderCalibrationList);
begin
  fList := AList;
  fPipelineNames := nil;
  fPipelineMode := False;
  RefreshGrid;
end;

procedure TRecorderCalibrationListDialog.EditPipeline(AList: TRecorderCalibrationList;
  APipelineNames: TStrings);
begin
  fList := AList;
  fPipelineNames := APipelineNames;
  fPipelineMode := True;
  RefreshGrid;
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
    Caption := 'Настройка Мульти ГХ';
    gridList.RowCount := Max(2, fPipelineNames.Count + 1);
    for I := 1 to gridList.RowCount - 1 do
    begin
      gridList.Cells[0, I] := '';
      gridList.Cells[1, I] := '';
    end;
    for I := 0 to fPipelineNames.Count - 1 do
    begin
      lCalibration := CalibrationByName(fPipelineNames[I]);
      gridList.Cells[0, I + 1] := fPipelineNames[I];
      if lCalibration <> nil then
        gridList.Cells[1, I + 1] := lCalibration.UnitOut;
    end;
    Exit;
  end;

  Caption := 'Список ГХ';
  gridList.RowCount := Max(2, fList.Count + 1);
  for I := 1 to gridList.RowCount - 1 do
  begin
    gridList.Cells[0, I] := '';
    gridList.Cells[1, I] := '';
  end;
  for I := 0 to fList.Count - 1 do
  begin
    lCalibration := fList[I];
    gridList.Cells[0, I + 1] := lCalibration.Name;
    gridList.Cells[1, I + 1] := lCalibration.UnitOut;
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
    if lKind = rckPiecewiseLinear then
    begin
      lCalibration.AddPoint(0, 0);
      lCalibration.AddPoint(1, 1);
    end;
    if ShowRecorderCalibrationPropertiesDialog(Self, lCalibration) then
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
  lIndex: Integer;
begin
  lIndex := CurrentIndex;
  if lIndex < 0 then
    Exit;
  if fPipelineMode then
  begin
    if fPipelineNames = nil then
      Exit;
    if ShowRecorderCalibrationPropertiesDialog(Self,
      CalibrationByName(fPipelineNames[lIndex])) then
      RefreshGrid;
    Exit;
  end;

  if ShowRecorderCalibrationPropertiesDialog(Self, fList[lIndex]) then
    RefreshGrid;
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
end;

procedure TRecorderCalibrationListDialog.gridListDblClick(Sender: TObject);
begin
  btnPropertiesClick(Sender);
end;

function ShowRecorderCalibrationListDialog(AOwner: TComponent;
  AList: TRecorderCalibrationList; out ASelected: TRecorderCalibration): Boolean;
var
  lDialog: TRecorderCalibrationListDialog;
begin
  lDialog := TRecorderCalibrationListDialog.Create(AOwner);
  try
    lDialog.EditList(AList);
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
begin
  lDialog := TRecorderCalibrationListDialog.Create(AOwner);
  try
    lDialog.EditPipeline(AList, APipelineNames);
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

end.
