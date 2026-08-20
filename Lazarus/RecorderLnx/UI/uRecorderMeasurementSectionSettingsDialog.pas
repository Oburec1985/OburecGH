unit uRecorderMeasurementSectionSettingsDialog;

{
  Форма настройки компонента "Измерительное сечение".
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Grids, Dialogs, ExtCtrls,
  Math, uRecorderTags, uRecorderMeasurementSectionModel;

function ShowRecorderMeasurementSectionSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderMeasurementSectionComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

uses
  fpspreadsheet, fpstypes, fpsopendocument, fpscsv, uRecorderMeraPaths;

const
  CColPoint = 0;
  CColRosette = 1;
  CColPosition = 2;
  CColE1 = 3;
  CColE2 = 4;
  CColE3 = 5;
  CColTemp = 6;
  CGridCols = 7;

  CSheetName = 'Recorder_Tags';

type
  TSectionColumn = (scolTagName, scolSection, scolPoint, scolRole,
    scolRosette, scolPosition, scolDescription, scolAddress, scolSource,
    scolModuleType, scolTagId, scolUnit, scolPollFrequency, scolSqlRecord,
    scolGroup);
  TSectionColumnMap = array[TSectionColumn] of Integer;

  TRecorderMeasurementSectionSettingsDialog = class(TForm)
  private
    fCaptionEdit: TEdit;
    fSectionIdEdit: TEdit;
    fDraft: TRecorderMeasurementSectionComponent;
    fGrid: TStringGrid;
    fRegistry: TRecorderTagRegistry;
    fComponent: TRecorderMeasurementSectionComponent;
    fTagFilterEdit: TEdit;
    fTagList: TListBox;
    fYoungEdit: TEdit;
    fPoissonEdit: TEdit;
    fTempCoeffEdit: TEdit;
    fTempRefEdit: TEdit;
    fOkButton: TButton;
    fCancelButton: TButton;
    fAddButton: TButton;
    fDeleteButton: TButton;
    fImportButton: TButton;
    fExportButton: TButton;
    procedure AddClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure GridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure GridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ImportClick(Sender: TObject);
    procedure TagFilterChange(Sender: TObject);
    procedure TagListDblClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure BuildUi;
    procedure BuildTagListPanel;
    procedure AssignSelectedTagToGrid;
    procedure LoadFromComponent;
    procedure PopulateTagList(const AFilter: string);
    procedure RefreshGrid;
    procedure StoreGrid;
    procedure StoreToComponent;
    function CurrentSectionId: string;
    function ParseFloatText(const AText: string; ADefault: Double): Double;
    function SelectedListTag: TRecorderTag;
    function TagByName(const AName: string): TRecorderTag;
    procedure ExportToFile(const AFileName: string);
    procedure ImportFromFile(const AFileName: string);
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderMeasurementSectionComponent;
      ATagRegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

const
  CHeaders: array[TSectionColumn] of string = (
    'Имя канала',
    'Объект/Сечение',
    'N точки',
    'Роль',
    'Тип розетки',
    'Расположение',
    'Описание канала',
    'Адрес канала',
    'Источник',
    'Тип канала',
    'ID канала',
    'Ед. изм.',
    'Частота опроса',
    'Запись SQL',
    'Группа'
  );

function ShowRecorderMeasurementSectionSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderMeasurementSectionComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TRecorderMeasurementSectionSettingsDialog;
begin
  lDialog := TRecorderMeasurementSectionSettingsDialog.CreateDialog(AOwner,
    AComponent, ATagRegistry);
  try
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

function TableFormatByFileName(const AFileName: string): TsSpreadsheetFormat;
begin
  if SameText(ExtractFileExt(AFileName), '.csv') then
    Result := sfCSV
  else
    Result := sfOpenDocument;
end;

function ReadCell(ASheet: TsWorksheet; ARow, ACol: Cardinal): string;
begin
  Result := Trim(ASheet.ReadAsUTF8Text(ARow, ACol));
end;

procedure WriteCell(ASheet: TsWorksheet; ARow, ACol: Cardinal;
  const AText: string);
begin
  ASheet.WriteUTF8Text(ARow, ACol, AText);
end;

function HeaderIndex(ASheet: TsWorksheet; const AHeader: string): Integer;
var
  I: Integer;
  lLastCol: Integer;
begin
  Result := -1;
  if ASheet = nil then
    Exit;
  lLastCol := Max(Integer(ASheet.GetLastColIndex(True)), 0);
  for I := 0 to lLastCol do
    if SameText(ReadCell(ASheet, 0, I), AHeader) then
      Exit(I);
end;

procedure BuildColumnMap(ASheet: TsWorksheet; AAllowDefault: Boolean;
  out AMap: TSectionColumnMap);
var
  lCol: TSectionColumn;
begin
  for lCol := Low(TSectionColumn) to High(TSectionColumn) do
  begin
    AMap[lCol] := HeaderIndex(ASheet, CHeaders[lCol]);
    if (AMap[lCol] < 0) and (lCol = scolSection) then
      AMap[lCol] := HeaderIndex(ASheet, 'Сечение');
    if (AMap[lCol] < 0) and AAllowDefault then
      AMap[lCol] := Ord(lCol);
  end;
end;

function NextAppendColumn(ASheet: TsWorksheet): Integer;
begin
  if (ASheet = nil) or (ASheet.GetCellCount = 0) then
    Result := 0
  else
    Result := Integer(ASheet.GetLastColIndex(True)) + 1;
end;

procedure EnsureColumns(ASheet: TsWorksheet; var AMap: TSectionColumnMap);
var
  lCol: TSectionColumn;
begin
  for lCol := Low(TSectionColumn) to High(TSectionColumn) do
  begin
    if AMap[lCol] < 0 then
      AMap[lCol] := NextAppendColumn(ASheet);
    WriteCell(ASheet, 0, AMap[lCol], CHeaders[lCol]);
  end;
end;

function FormatValue(AValue: Double): string;
var
  lFormat: TFormatSettings;
begin
  lFormat := DefaultFormatSettings;
  lFormat.DecimalSeparator := '.';
  Result := FloatToStr(AValue, lFormat);
end;

function SameSectionId(const ALeft, ARight: string): Boolean;
begin
  Result := SameText(Trim(ALeft), Trim(ARight));
end;

{ TRecorderMeasurementSectionSettingsDialog }

constructor TRecorderMeasurementSectionSettingsDialog.CreateDialog(
  AOwner: TComponent; AComponent: TRecorderMeasurementSectionComponent;
  ATagRegistry: TRecorderTagRegistry);
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  fRegistry := ATagRegistry;
  fDraft := TRecorderMeasurementSectionComponent.Create;
  Caption := 'Настройка измерительного сечения';
  BorderStyle := bsSizeable;
  Position := poOwnerFormCenter;
  Width := 880;
  Height := 560;
  BuildUi;
  LoadFromComponent;
end;

destructor TRecorderMeasurementSectionSettingsDialog.Destroy;
begin
  fDraft.Free;
  inherited Destroy;
end;

function TRecorderMeasurementSectionSettingsDialog.ParseFloatText(
  const AText: string; ADefault: Double): Double;
var
  lText: string;
begin
  lText := Trim(AText);
  lText := StringReplace(lText, '.', DecimalSeparator, [rfReplaceAll]);
  lText := StringReplace(lText, ',', DecimalSeparator, [rfReplaceAll]);
  Result := StrToFloatDef(lText, ADefault);
end;

function TRecorderMeasurementSectionSettingsDialog.CurrentSectionId: string;
begin
  Result := Trim(fSectionIdEdit.Text);
  if Result = '' then
    Result := fDraft.SectionId;
  Result := Trim(Result);
  if Result = '' then
    Result := '1';
end;

function TRecorderMeasurementSectionSettingsDialog.SelectedListTag: TRecorderTag;
begin
  Result := nil;
  if (fTagList <> nil) and (fTagList.ItemIndex >= 0) then
    Result := TRecorderTag(fTagList.Items.Objects[fTagList.ItemIndex]);
end;

function TRecorderMeasurementSectionSettingsDialog.TagByName(
  const AName: string): TRecorderTag;
begin
  Result := nil;
  if (fRegistry <> nil) and (Trim(AName) <> '') then
    Result := fRegistry.FindByName(Trim(AName));
end;

procedure TRecorderMeasurementSectionSettingsDialog.BuildTagListPanel;
var
  lPanel: TPanel;
  lLabel: TLabel;
begin
  lPanel := TPanel.Create(Self);
  lPanel.Parent := Self;
  lPanel.Align := alRight;
  lPanel.Width := 260;
  lPanel.BevelOuter := bvNone;
  lPanel.BorderSpacing.Left := 6;

  lLabel := TLabel.Create(lPanel);
  lLabel.Parent := lPanel;
  lLabel.Align := alTop;
  lLabel.Height := 22;
  lLabel.Caption := 'Теги';

  fTagFilterEdit := TEdit.Create(lPanel);
  fTagFilterEdit.Parent := lPanel;
  fTagFilterEdit.Align := alTop;
  fTagFilterEdit.TextHint := 'Фильтр';
  fTagFilterEdit.OnChange := @TagFilterChange;

  fTagList := TListBox.Create(lPanel);
  fTagList.Parent := lPanel;
  fTagList.Align := alClient;
  fTagList.DragMode := dmAutomatic;
  fTagList.OnDblClick := @TagListDblClick;
end;

procedure TRecorderMeasurementSectionSettingsDialog.BuildUi;
var
  lLabel: TLabel;
  lPanel: TPanel;
begin
  lPanel := TPanel.Create(Self);
  lPanel.Parent := Self;
  lPanel.Align := alTop;
  lPanel.Height := 146;
  lPanel.BevelOuter := bvNone;

  lLabel := TLabel.Create(lPanel);
  lLabel.Parent := lPanel;
  lLabel.SetBounds(12, 14, 80, 18);
  lLabel.Caption := 'Подпись';
  fCaptionEdit := TEdit.Create(lPanel);
  fCaptionEdit.Parent := lPanel;
  fCaptionEdit.SetBounds(96, 10, 260, 24);

  lLabel := TLabel.Create(lPanel);
  lLabel.Parent := lPanel;
  lLabel.SetBounds(12, 48, 120, 18);
  lLabel.Caption := 'Объект/Сечение';
  fSectionIdEdit := TEdit.Create(lPanel);
  fSectionIdEdit.Parent := lPanel;
  fSectionIdEdit.SetBounds(136, 44, 120, 24);

  lLabel := TLabel.Create(lPanel);
  lLabel.Parent := lPanel;
  lLabel.SetBounds(380, 14, 90, 18);
  lLabel.Caption := 'E, МПа';
  fYoungEdit := TEdit.Create(lPanel);
  fYoungEdit.Parent := lPanel;
  fYoungEdit.SetBounds(470, 10, 90, 24);

  lLabel := TLabel.Create(lPanel);
  lLabel.Parent := lPanel;
  lLabel.SetBounds(580, 14, 40, 18);
  lLabel.Caption := 'nu';
  fPoissonEdit := TEdit.Create(lPanel);
  fPoissonEdit.Parent := lPanel;
  fPoissonEdit.SetBounds(620, 10, 70, 24);

  lLabel := TLabel.Create(lPanel);
  lLabel.Parent := lPanel;
  lLabel.SetBounds(12, 82, 150, 18);
  lLabel.Caption := 'Темп. коэф., мкстрн/°C';
  fTempCoeffEdit := TEdit.Create(lPanel);
  fTempCoeffEdit.Parent := lPanel;
  fTempCoeffEdit.SetBounds(170, 78, 90, 24);

  lLabel := TLabel.Create(lPanel);
  lLabel.Parent := lPanel;
  lLabel.SetBounds(280, 82, 120, 18);
  lLabel.Caption := 'Опорная T, °C';
  fTempRefEdit := TEdit.Create(lPanel);
  fTempRefEdit.Parent := lPanel;
  fTempRefEdit.SetBounds(400, 78, 90, 24);

  fAddButton := TButton.Create(lPanel);
  fAddButton.Parent := lPanel;
  fAddButton.SetBounds(12, 114, 86, 26);
  fAddButton.Caption := 'Добавить';
  fAddButton.OnClick := @AddClick;

  fDeleteButton := TButton.Create(lPanel);
  fDeleteButton.Parent := lPanel;
  fDeleteButton.SetBounds(104, 114, 86, 26);
  fDeleteButton.Caption := 'Удалить';
  fDeleteButton.OnClick := @DeleteClick;

  fImportButton := TButton.Create(lPanel);
  fImportButton.Parent := lPanel;
  fImportButton.SetBounds(210, 114, 90, 26);
  fImportButton.Caption := 'Импорт...';
  fImportButton.OnClick := @ImportClick;

  fExportButton := TButton.Create(lPanel);
  fExportButton.Parent := lPanel;
  fExportButton.SetBounds(306, 114, 90, 26);
  fExportButton.Caption := 'Экспорт...';
  fExportButton.OnClick := @ExportClick;

  fGrid := TStringGrid.Create(Self);
  fGrid.Parent := Self;
  fGrid.Align := alClient;
  fGrid.FixedCols := 0;
  fGrid.FixedRows := 1;
  fGrid.ColCount := CGridCols;
  fGrid.RowCount := 2;
  fGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
    goEditing, goRowSelect, goColSizing];
  fGrid.Cells[CColPoint, 0] := 'N точки';
  fGrid.Cells[CColRosette, 0] := 'Тип розетки';
  fGrid.Cells[CColPosition, 0] := 'Расположение';
  fGrid.Cells[CColE1, 0] := 'e1';
  fGrid.Cells[CColE2, 0] := 'e2';
  fGrid.Cells[CColE3, 0] := 'e3';
  fGrid.Cells[CColTemp, 0] := 't';
  fGrid.OnDragOver := @GridDragOver;
  fGrid.OnDragDrop := @GridDragDrop;
  fGrid.ColWidths[CColPoint] := 70;
  fGrid.ColWidths[CColRosette] := 90;
  fGrid.ColWidths[CColPosition] := 90;
  fGrid.ColWidths[CColE1] := 130;
  fGrid.ColWidths[CColE2] := 130;
  fGrid.ColWidths[CColE3] := 130;
  fGrid.ColWidths[CColTemp] := 130;

  lPanel := TPanel.Create(Self);
  lPanel.Parent := Self;
  lPanel.Align := alBottom;
  lPanel.Height := 44;
  lPanel.BevelOuter := bvNone;

  fOkButton := TButton.Create(lPanel);
  fOkButton.Parent := lPanel;
  fOkButton.SetBounds(676, 8, 90, 26);
  fOkButton.Caption := 'OK';
  fOkButton.Default := True;
  fOkButton.OnClick := @OkClick;

  fCancelButton := TButton.Create(lPanel);
  fCancelButton.Parent := lPanel;
  fCancelButton.SetBounds(772, 8, 90, 26);
  fCancelButton.Caption := 'Отмена';
  fCancelButton.ModalResult := mrCancel;

  BuildTagListPanel;
end;

procedure TRecorderMeasurementSectionSettingsDialog.LoadFromComponent;
begin
  fDraft.AssignSection(fComponent);
  if fDraft.RowCount = 0 then
    fDraft.AddRow;
  fCaptionEdit.Text := fDraft.Caption;
  fSectionIdEdit.Text := fDraft.SectionId;
  fYoungEdit.Text := FloatToStr(fDraft.YoungModulusMPa);
  fPoissonEdit.Text := FloatToStr(fDraft.PoissonRatio);
  fTempCoeffEdit.Text := FloatToStr(fDraft.TemperatureCoefficient);
  fTempRefEdit.Text := FloatToStr(fDraft.ReferenceTemperatureC);
  PopulateTagList('');
  RefreshGrid;
end;

procedure TRecorderMeasurementSectionSettingsDialog.PopulateTagList(
  const AFilter: string);
var
  I: Integer;
  lFilter: string;
  lText: string;
  lTag: TRecorderTag;
begin
  if fTagList = nil then
    Exit;
  fTagList.Items.BeginUpdate;
  try
    fTagList.Items.Clear;
    if fRegistry = nil then
      Exit;
    lFilter := LowerCase(Trim(AFilter));
    for I := 0 to fRegistry.TagCount - 1 do
    begin
      lTag := fRegistry.Tags[I];
      if lTag = nil then
        Continue;
      lText := lTag.Name;
      if lTag.Address <> '' then
        lText := lText + ' [' + lTag.Address + ']';
      if (lFilter <> '') and
        (Pos(lFilter, LowerCase(lText + ' ' + lTag.Description)) = 0) then
        Continue;
      fTagList.Items.AddObject(lText, lTag);
    end;
  finally
    fTagList.Items.EndUpdate;
  end;
end;

procedure TRecorderMeasurementSectionSettingsDialog.RefreshGrid;
var
  I: Integer;
  lRow: TRecorderMeasurementSectionRow;
begin
  fGrid.RowCount := Max(2, fDraft.RowCount + 1);
  for I := 0 to fDraft.RowCount - 1 do
  begin
    lRow := fDraft.Rows[I];
    fGrid.Cells[CColPoint, I + 1] := IntToStr(lRow.PointNo);
    fGrid.Cells[CColRosette, I + 1] := RecorderRosetteTypeToText(lRow.RosetteType);
    fGrid.Cells[CColPosition, I + 1] := FloatToStr(lRow.PositionDeg);
    fGrid.Cells[CColE1, I + 1] := lRow.TagNames[rrrE1];
    fGrid.Cells[CColE2, I + 1] := lRow.TagNames[rrrE2];
    fGrid.Cells[CColE3, I + 1] := lRow.TagNames[rrrE3];
    fGrid.Cells[CColTemp, I + 1] := lRow.TagNames[rrrTemperature];
  end;
end;

procedure TRecorderMeasurementSectionSettingsDialog.StoreGrid;
var
  I: Integer;
  lRow: TRecorderMeasurementSectionRow;
  lTag: TRecorderTag;
begin
  fDraft.ClearRows;
  for I := 1 to fGrid.RowCount - 1 do
  begin
    if (Trim(fGrid.Cells[CColPoint, I]) = '') and
      (Trim(fGrid.Cells[CColRosette, I]) = '') and
      (Trim(fGrid.Cells[CColPosition, I]) = '') and
      (Trim(fGrid.Cells[CColE1, I]) = '') and
      (Trim(fGrid.Cells[CColE2, I]) = '') and
      (Trim(fGrid.Cells[CColE3, I]) = '') and
      (Trim(fGrid.Cells[CColTemp, I]) = '') then
      Continue;
    lRow := fDraft.AddRow;
    lRow.PointNo := StrToIntDef(Trim(fGrid.Cells[CColPoint, I]), I);
    lRow.RosetteType := RecorderRosetteTypeFromText(fGrid.Cells[CColRosette, I]);
    lRow.PositionDeg := ParseFloatText(fGrid.Cells[CColPosition, I], 0.0);
    lRow.TagNames[rrrE1] := Trim(fGrid.Cells[CColE1, I]);
    lTag := TagByName(lRow.TagNames[rrrE1]);
    if lTag <> nil then lRow.BindTag(rrrE1, lTag);
    lRow.TagNames[rrrE2] := Trim(fGrid.Cells[CColE2, I]);
    lTag := TagByName(lRow.TagNames[rrrE2]);
    if lTag <> nil then lRow.BindTag(rrrE2, lTag);
    lRow.TagNames[rrrE3] := Trim(fGrid.Cells[CColE3, I]);
    lTag := TagByName(lRow.TagNames[rrrE3]);
    if lTag <> nil then lRow.BindTag(rrrE3, lTag);
    lRow.TagNames[rrrTemperature] := Trim(fGrid.Cells[CColTemp, I]);
    lTag := TagByName(lRow.TagNames[rrrTemperature]);
    if lTag <> nil then lRow.BindTag(rrrTemperature, lTag);
  end;
end;

procedure TRecorderMeasurementSectionSettingsDialog.StoreToComponent;
begin
  StoreGrid;
  fDraft.Caption := Trim(fCaptionEdit.Text);
  if fDraft.Caption = '' then
    fDraft.Caption := 'Измерительное сечение';
  fDraft.SectionId := CurrentSectionId;
  fDraft.YoungModulusMPa := ParseFloatText(fYoungEdit.Text,
    fDraft.YoungModulusMPa);
  fDraft.PoissonRatio := ParseFloatText(fPoissonEdit.Text,
    fDraft.PoissonRatio);
  fDraft.TemperatureCoefficient := ParseFloatText(fTempCoeffEdit.Text,
    fDraft.TemperatureCoefficient);
  fDraft.ReferenceTemperatureC := ParseFloatText(fTempRefEdit.Text,
    fDraft.ReferenceTemperatureC);
  fComponent.AssignSection(fDraft);
end;

procedure TRecorderMeasurementSectionSettingsDialog.AddClick(Sender: TObject);
begin
  StoreGrid;
  fDraft.AddRow;
  RefreshGrid;
  fGrid.Row := fGrid.RowCount - 1;
end;

procedure TRecorderMeasurementSectionSettingsDialog.DeleteClick(Sender: TObject);
var
  lIndex: Integer;
begin
  StoreGrid;
  lIndex := fGrid.Row - 1;
  fDraft.DeleteRow(lIndex);
  RefreshGrid;
end;

procedure TRecorderMeasurementSectionSettingsDialog.AssignSelectedTagToGrid;
var
  lTag: TRecorderTag;
begin
  lTag := SelectedListTag;
  if (lTag = nil) or (fGrid.Row <= 0) or
    (fGrid.Col < CColE1) or (fGrid.Col > CColTemp) then
    Exit;
  fGrid.Cells[fGrid.Col, fGrid.Row] := lTag.Name;
end;

procedure TRecorderMeasurementSectionSettingsDialog.GridDragDrop(
  Sender, Source: TObject; X, Y: Integer);
var
  lCol: Integer;
  lRow: Integer;
begin
  if Source <> fTagList then
    Exit;
  fGrid.MouseToCell(X, Y, lCol, lRow);
  if (lRow <= 0) or (lCol < CColE1) or (lCol > CColTemp) then
    Exit;
  fGrid.Row := lRow;
  fGrid.Col := lCol;
  AssignSelectedTagToGrid;
end;

procedure TRecorderMeasurementSectionSettingsDialog.GridDragOver(
  Sender, Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  lCol: Integer;
  lRow: Integer;
begin
  Accept := False;
  if (Source <> fTagList) or (SelectedListTag = nil) then
    Exit;
  fGrid.MouseToCell(X, Y, lCol, lRow);
  Accept := (lRow > 0) and (lCol >= CColE1) and (lCol <= CColTemp);
end;

procedure TRecorderMeasurementSectionSettingsDialog.TagFilterChange(
  Sender: TObject);
begin
  PopulateTagList(fTagFilterEdit.Text);
end;

procedure TRecorderMeasurementSectionSettingsDialog.TagListDblClick(
  Sender: TObject);
begin
  AssignSelectedTagToGrid;
end;

procedure TRecorderMeasurementSectionSettingsDialog.OkClick(Sender: TObject);
begin
  StoreToComponent;
  ModalResult := mrOk;
end;

procedure TRecorderMeasurementSectionSettingsDialog.ExportClick(Sender: TObject);
var
  lDialog: TSaveDialog;
begin
  StoreGrid;
  fDraft.Caption := Trim(fCaptionEdit.Text);
  if fDraft.Caption = '' then
    fDraft.Caption := 'Измерительное сечение';
  fDraft.SectionId := CurrentSectionId;
  fDraft.YoungModulusMPa := ParseFloatText(fYoungEdit.Text,
    fDraft.YoungModulusMPa);
  fDraft.PoissonRatio := ParseFloatText(fPoissonEdit.Text,
    fDraft.PoissonRatio);
  fDraft.TemperatureCoefficient := ParseFloatText(fTempCoeffEdit.Text,
    fDraft.TemperatureCoefficient);
  fDraft.ReferenceTemperatureC := ParseFloatText(fTempRefEdit.Text,
    fDraft.ReferenceTemperatureC);
  lDialog := TSaveDialog.Create(Self);
  try
    lDialog.Title := 'Экспорт измерительного сечения';
    lDialog.Filter := 'OpenDocument (*.ods)|*.ods|CSV (*.csv)|*.csv|Все файлы|*.*';
    lDialog.DefaultExt := 'ods';
    lDialog.InitialDir := RecorderMeraFilesPath;
    if lDialog.Execute then
      ExportToFile(lDialog.FileName);
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderMeasurementSectionSettingsDialog.ImportClick(Sender: TObject);
var
  lDialog: TOpenDialog;
begin
  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Импорт измерительного сечения';
    lDialog.Filter := 'OpenDocument (*.ods)|*.ods|CSV (*.csv)|*.csv|Все файлы|*.*';
    lDialog.InitialDir := RecorderMeraFilesPath;
    if lDialog.Execute then
    begin
      ImportFromFile(lDialog.FileName);
      RefreshGrid;
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderMeasurementSectionSettingsDialog.ExportToFile(
  const AFileName: string);
var
  lBook: TsWorkbook;
  lSheet: TsWorksheet;
  lMap: TSectionColumnMap;
  I: Integer;
  lRole: TRecorderRosetteRole;
  lRowIndex: Integer;
  lRow: TRecorderMeasurementSectionRow;
  lTag: TRecorderTag;
begin
  lBook := TsWorkbook.Create;
  try
    if FileExists(AFileName) then
      lBook.ReadFromFile(AFileName, TableFormatByFileName(AFileName));
    lSheet := lBook.GetWorksheetByName(CSheetName);
    if lSheet = nil then
      if lBook.GetWorksheetCount > 0 then
        lSheet := lBook.GetWorksheetByIndex(0)
      else
        lSheet := lBook.AddWorksheet(CSheetName);
    BuildColumnMap(lSheet, not FileExists(AFileName), lMap);
    EnsureColumns(lSheet, lMap);
    lRowIndex := Integer(lSheet.GetLastRowIndex(True)) + 1;
    if lRowIndex < 1 then
      lRowIndex := 1;
    for I := 0 to fDraft.RowCount - 1 do
    begin
      lRow := fDraft.Rows[I];
      for lRole := Low(TRecorderRosetteRole) to High(TRecorderRosetteRole) do
      begin
        lTag := lRow.ResolveTag(fRegistry, lRole);
        if lTag <> nil then
          WriteCell(lSheet, lRowIndex, lMap[scolTagName], lTag.Name)
        else
          WriteCell(lSheet, lRowIndex, lMap[scolTagName],
            lRow.TagNames[lRole]);
        WriteCell(lSheet, lRowIndex, lMap[scolSection], fDraft.SectionId);
        WriteCell(lSheet, lRowIndex, lMap[scolPoint], IntToStr(lRow.PointNo));
        WriteCell(lSheet, lRowIndex, lMap[scolRole],
          RecorderRosetteRoleToText(lRole));
        WriteCell(lSheet, lRowIndex, lMap[scolRosette],
          RecorderRosetteTypeToText(lRow.RosetteType));
        WriteCell(lSheet, lRowIndex, lMap[scolPosition],
          FormatValue(lRow.PositionDeg));
        if lTag <> nil then
        begin
          WriteCell(lSheet, lRowIndex, lMap[scolDescription], lTag.Description);
          WriteCell(lSheet, lRowIndex, lMap[scolAddress], lTag.Address);
          WriteCell(lSheet, lRowIndex, lMap[scolSource], lTag.SourceId);
          WriteCell(lSheet, lRowIndex, lMap[scolModuleType], lTag.ModuleType);
          WriteCell(lSheet, lRowIndex, lMap[scolTagId], IntToStr(lTag.Id));
          WriteCell(lSheet, lRowIndex, lMap[scolUnit], lTag.UnitName);
          WriteCell(lSheet, lRowIndex, lMap[scolPollFrequency],
            FormatValue(lTag.PollFrequencyHz));
          WriteCell(lSheet, lRowIndex, lMap[scolGroup], lTag.GroupPath);
        end;
        WriteCell(lSheet, lRowIndex, lMap[scolSqlRecord], '');
        Inc(lRowIndex);
      end;
    end;
    lBook.WriteToFile(AFileName, TableFormatByFileName(AFileName), True);
  finally
    lBook.Free;
  end;
end;

procedure TRecorderMeasurementSectionSettingsDialog.ImportFromFile(
  const AFileName: string);
var
  lBook: TsWorkbook;
  lSheet: TsWorksheet;
  lMap: TSectionColumnMap;
  lLastRow, lRowIndex: Cardinal;
  lPoint: Integer;
  lRole: TRecorderRosetteRole;
  lRow: TRecorderMeasurementSectionRow;
  lTag: TRecorderTag;
  lTagId: TRecorderTagId;
  lSectionId, lTagName, lText: string;
  I: Integer;
begin
  lBook := TsWorkbook.Create;
  try
    lBook.ReadFromFile(AFileName, TableFormatByFileName(AFileName));
    if lBook.GetWorksheetCount = 0 then
      Exit;
    lSheet := lBook.GetWorksheetByIndex(0);
    BuildColumnMap(lSheet, True, lMap);
    fDraft.SectionId := CurrentSectionId;
    fDraft.ClearRows;
    lLastRow := lSheet.GetLastRowIndex(True);
    for lRowIndex := 1 to lLastRow do
    begin
      lSectionId := ReadCell(lSheet, lRowIndex, lMap[scolSection]);
      if (lSectionId <> '') and
        (not SameSectionId(lSectionId, fDraft.SectionId)) then
        Continue;
      if not RecorderRosetteRoleFromText(ReadCell(lSheet, lRowIndex,
        lMap[scolRole]), lRole) then
        Continue;
      lPoint := StrToIntDef(ReadCell(lSheet, lRowIndex, lMap[scolPoint]),
        Integer(lRowIndex));
      lRow := nil;
      for I := 0 to fDraft.RowCount - 1 do
        if fDraft.Rows[I].PointNo = lPoint then
        begin
          lRow := fDraft.Rows[I];
          Break;
        end;
      if lRow = nil then
      begin
        lRow := fDraft.AddRow;
        lRow.PointNo := lPoint;
      end;
      lText := ReadCell(lSheet, lRowIndex, lMap[scolRosette]);
      if lText <> '' then
        lRow.RosetteType := RecorderRosetteTypeFromText(lText);
      lRow.PositionDeg := ParseFloatText(ReadCell(lSheet, lRowIndex,
        lMap[scolPosition]), lRow.PositionDeg);
      lTag := nil;
      lText := ReadCell(lSheet, lRowIndex, lMap[scolTagId]);
      if (fRegistry <> nil) and TryStrToInt64(lText, lTagId) then
        lTag := fRegistry.FindById(lTagId);
      lTagName := ReadCell(lSheet, lRowIndex, lMap[scolTagName]);
      if (lTag = nil) and (fRegistry <> nil) and (lTagName <> '') then
        lTag := fRegistry.FindByName(lTagName);
      if lTag <> nil then
        lRow.BindTag(lRole, lTag)
      else
        lRow.TagNames[lRole] := lTagName;
    end;
  finally
    lBook.Free;
  end;
end;

end.
