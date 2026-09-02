unit uRecorderMeasurementSectionSettingsDialog;

{
  Форма настройки компонента "Измерительное сечение".
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Grids, Dialogs, ExtCtrls,
  Graphics,
  Math, uRecorderFormModel, uRecorderTags, uRecorderMeasurementSectionModel;

type

  { TRecorderMeasurementSectionSettingsDialog }

  TRecorderMeasurementSectionSettingsDialog = class(TForm)
  published
    fCaptionEdit: TEdit;
    fBackgroundColorPanel: TPanel;
    fCaptionFontButton: TButton;
    fCaptionFontCombo: TComboBox;
    fFormatAllButton: TButton;
    fSectionIdEdit: TEdit;
    fGrid: TStringGrid;
    fTagFilterEdit: TEdit;
    fTagList: TListBox;
    fYoungEdit: TEdit;
    fPoissonEdit: TEdit;
    fTempCoeffEdit: TEdit;
    fTempRefEdit: TEdit;
    fStressFontButton: TButton;
    fStressFontCombo: TComboBox;
    fTextBackgroundColorPanel: TPanel;
    fOkButton: TButton;
    fCancelButton: TButton;
    fAddButton: TButton;
    fDeleteButton: TButton;
    fImportButton: TButton;
    fExportButton: TButton;
    lblCaption: TLabel;
    lblCaptionFont: TLabel;
    lblPoisson: TLabel;
    lblSection: TLabel;
    lblStressFont: TLabel;
    lblTags: TLabel;
    lblTempCoeff: TLabel;
    lblTempRef: TLabel;
    lblYoung: TLabel;
    pnlButtons: TPanel;
    pnlSettings: TPanel;
    pnlTags: TPanel;
    procedure AddClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure GridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure GridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ImportClick(Sender: TObject);
    procedure ChooseFontClick(Sender: TObject);
    procedure ColorPanelDblClick(Sender: TObject);
    procedure FontNameChange(Sender: TObject);
    procedure FormatAllClick(Sender: TObject);
    procedure TagFilterChange(Sender: TObject);
    procedure TagListDblClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
  private
    fCaptionFont: TRecorderFontSnapshot;
    fComponent: TRecorderMeasurementSectionComponent;
    fDraft: TRecorderMeasurementSectionComponent;
    fFormatAllRequested: Boolean;
    fRegistry: TRecorderTagRegistry;
    fStressFont: TRecorderFontSnapshot;
    procedure AssignSelectedTagToGrid;
    procedure ApplyFontsToFactory;
    procedure LoadFromComponent;
    procedure PopulateTagList(const AFilter: string);
    procedure RefreshGrid;
    procedure StoreGrid;
    procedure StoreToComponent;
    procedure FillFontCombo(ACombo: TComboBox);
    procedure LoadNamedFont(ACombo: TComboBox;
      var AFont: TRecorderFontSnapshot);
    procedure SyncSharedFont(AChangedCombo: TComboBox);
    procedure DefineNamedFont(ACombo: TComboBox;
      const AFont: TRecorderFontSnapshot);
    function CurrentSectionId: string;
    function ParseFloatText(const AText: string; ADefault: Double): Double;
    function SelectedListTag: TRecorderTag;
    function TagByName(const AName: string): TRecorderTag;
    procedure ExportToFile(const AFileName: string);
    procedure ImportFromFile(const AFileName: string;
      out APointCount, ABindingCount: Integer);
    procedure InitGrid;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderMeasurementSectionComponent;
      ATagRegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderMeasurementSectionSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderMeasurementSectionComponent;
  ATagRegistry: TRecorderTagRegistry): Boolean;

implementation

{$R *.lfm}

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
  CMaxHeaderColumn = 255;

type
  TSectionColumn = (scolTagName, scolSection, scolPoint, scolRole,
    scolRosette, scolPosition, scolDescription, scolAddress, scolSource,
    scolModuleType, scolTagId, scolUnit, scolPollFrequency, scolSqlRecord,
    scolGroup);
  TSectionColumnMap = array[TSectionColumn] of Integer;

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

function ReadMappedCell(ASheet: TsWorksheet; ARow: Cardinal;
  ACol: Integer): string;
begin
  if ACol < 0 then
    Exit('');
  Result := ReadCell(ASheet, ARow, Cardinal(ACol));
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
  // LibreOffice can serialize a repeated empty tail up to column 16383.
  // Such cells are not table columns and must not expand a header lookup.
  lLastCol := Min(Max(Integer(ASheet.GetLastColIndex(True)), 0),
    CMaxHeaderColumn);
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
  inherited Create(AOwner);
  fComponent := AComponent;
  fRegistry := ATagRegistry;
  fDraft := TRecorderMeasurementSectionComponent.Create;
  fFormatAllRequested := False;
  InitGrid;
  FillFontCombo(fCaptionFontCombo);
  FillFontCombo(fStressFontCombo);
  LoadFromComponent;
end;

procedure TRecorderMeasurementSectionSettingsDialog.InitGrid;
begin
  fGrid.ColCount := CGridCols;
  fGrid.RowCount := 2;
  fGrid.Cells[CColPoint, 0] := 'N точки';
  fGrid.Cells[CColRosette, 0] := 'Тип розетки';
  fGrid.Cells[CColPosition, 0] := 'Расположение';
  fGrid.Cells[CColE1, 0] := 'e1';
  fGrid.Cells[CColE2, 0] := 'e2';
  fGrid.Cells[CColE3, 0] := 'e3';
  fGrid.Cells[CColTemp, 0] := 't';
  fGrid.ColWidths[CColPoint] := 70;
  fGrid.ColWidths[CColRosette] := 90;
  fGrid.ColWidths[CColPosition] := 90;
  fGrid.ColWidths[CColE1] := 130;
  fGrid.ColWidths[CColE2] := 130;
  fGrid.ColWidths[CColE3] := 130;
  fGrid.ColWidths[CColTemp] := 130;
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

procedure TRecorderMeasurementSectionSettingsDialog.LoadFromComponent;
begin
  fDraft.AssignSection(fComponent);
  if fDraft.RowCount = 0 then
    fDraft.AddRow;
  fCaptionEdit.Text := fDraft.Caption;
  fBackgroundColorPanel.Color := TColor(fDraft.BackgroundColor);
  fTextBackgroundColorPanel.Color := TColor(fDraft.TextBackgroundColor);
  fSectionIdEdit.Text := fDraft.SectionId;
  fYoungEdit.Text := FloatToStr(fDraft.YoungModulusMPa);
  fPoissonEdit.Text := FloatToStr(fDraft.PoissonRatio);
  fTempCoeffEdit.Text := FloatToStr(fDraft.TemperatureCoefficient);
  fTempRefEdit.Text := FloatToStr(fDraft.ReferenceTemperatureC);
  fCaptionFont := fDraft.CaptionFont;
  fStressFont := fDraft.StressFont;
  fCaptionFontCombo.Text := fDraft.NamedFontName;
  fStressFontCombo.Text := fDraft.StressNamedFontName;
  LoadNamedFont(fCaptionFontCombo, fCaptionFont);
  LoadNamedFont(fStressFontCombo, fStressFont);
  PopulateTagList('');
  RefreshGrid;
end;

procedure TRecorderMeasurementSectionSettingsDialog.ColorPanelDblClick(
  Sender: TObject);
var
  lDialog: TColorDialog;
  lPanel: TPanel;
begin
  if not (Sender is TPanel) then
    Exit;
  lPanel := TPanel(Sender);
  lDialog := TColorDialog.Create(Self);
  try
    lDialog.Color := lPanel.Color;
    if lDialog.Execute then
      lPanel.Color := lDialog.Color;
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderMeasurementSectionSettingsDialog.FillFontCombo(
  ACombo: TComboBox);
var
  I: Integer;
begin
  if (ACombo = nil) or (fComponent = nil) or
    (fComponent.NamedFonts = nil) then
    Exit;
  for I := 0 to fComponent.NamedFonts.Count - 1 do
    ACombo.Items.Add(fComponent.NamedFonts.Items[I].Name);
end;

procedure TRecorderMeasurementSectionSettingsDialog.LoadNamedFont(
  ACombo: TComboBox; var AFont: TRecorderFontSnapshot);
var
  lFont: TRecorderNamedFont;
begin
  if (ACombo = nil) or (fComponent = nil) or
    (fComponent.NamedFonts = nil) then
    Exit;
  lFont := fComponent.NamedFonts.Find(ACombo.Text);
  if lFont = nil then
    Exit;
  AFont.Name := lFont.FontName;
  AFont.Size := lFont.FontSize;
  AFont.Color := lFont.FontColor;
  AFont.Bold := lFont.Bold;
  AFont.Italic := lFont.Italic;
end;

procedure TRecorderMeasurementSectionSettingsDialog.DefineNamedFont(
  ACombo: TComboBox; const AFont: TRecorderFontSnapshot);
var
  lName: string;
begin
  if (ACombo = nil) or (fComponent = nil) or
    (fComponent.NamedFonts = nil) then
    Exit;
  lName := Trim(ACombo.Text);
  if lName <> '' then
    fComponent.NamedFonts.Define(lName, AFont.Name, AFont.Size, AFont.Color,
      AFont.Bold, AFont.Italic);
end;

procedure TRecorderMeasurementSectionSettingsDialog.SyncSharedFont(
  AChangedCombo: TComboBox);
begin
  if not SameText(Trim(fCaptionFontCombo.Text),
    Trim(fStressFontCombo.Text)) then
    Exit;
  if AChangedCombo = fCaptionFontCombo then
    fStressFont := fCaptionFont
  else if AChangedCombo = fStressFontCombo then
    fCaptionFont := fStressFont;
end;

procedure TRecorderMeasurementSectionSettingsDialog.FormatAllClick(
  Sender: TObject);
begin
  if Trim(fCaptionFontCombo.Text) = '' then
  begin
    MessageDlg('Шрифт', 'Введите имя шрифта заголовка.', mtWarning,
      [mbOK], 0);
    Exit;
  end;
  if Trim(fStressFontCombo.Text) = '' then
  begin
    MessageDlg('Шрифт', 'Введите имя шрифта механических напряжений.',
      mtWarning, [mbOK], 0);
    Exit;
  end;
  fFormatAllRequested := True;
  fFormatAllButton.Caption := 'Будет применено ко всем';
end;

procedure TRecorderMeasurementSectionSettingsDialog.ApplyFontsToFactory;
var
  I: Integer;
  lItem: TRecorderMeasurementSectionComponent;
begin
  if (fComponent = nil) or (fComponent.Factory = nil) then
    Exit;
  for I := 0 to fComponent.Factory.ChildCount - 1 do
    if fComponent.Factory.Children[I] is
      TRecorderMeasurementSectionComponent then
    begin
      lItem := TRecorderMeasurementSectionComponent(
        fComponent.Factory.Children[I]);
      lItem.NamedFontName := fComponent.NamedFontName;
      lItem.CaptionFont := fComponent.CaptionFont;
      lItem.StressNamedFontName := fComponent.StressNamedFontName;
      lItem.StressFont := fComponent.StressFont;
    end;
end;

procedure TRecorderMeasurementSectionSettingsDialog.FontNameChange(
  Sender: TObject);
begin
  if Sender = fCaptionFontCombo then
    LoadNamedFont(fCaptionFontCombo, fCaptionFont)
  else if Sender = fStressFontCombo then
    LoadNamedFont(fStressFontCombo, fStressFont);
end;

procedure TRecorderMeasurementSectionSettingsDialog.ChooseFontClick(
  Sender: TObject);
var
  lDialog: TFontDialog;
  lFont: ^TRecorderFontSnapshot;
  lCombo: TComboBox;
begin
  if Sender = fCaptionFontButton then
  begin
    lFont := @fCaptionFont;
    lCombo := fCaptionFontCombo;
  end
  else if Sender = fStressFontButton then
  begin
    lFont := @fStressFont;
    lCombo := fStressFontCombo;
  end
  else
    Exit;

  lDialog := TFontDialog.Create(Self);
  try
    lDialog.Font.Name := lFont^.Name;
    lDialog.Font.Size := lFont^.Size;
    lDialog.Font.Color := lFont^.Color;
    lDialog.Font.Style := [];
    if lFont^.Bold then
      lDialog.Font.Style := lDialog.Font.Style + [fsBold];
    if lFont^.Italic then
      lDialog.Font.Style := lDialog.Font.Style + [fsItalic];
    if not lDialog.Execute then
      Exit;
    lFont^.Name := lDialog.Font.Name;
    lFont^.Size := lDialog.Font.Size;
    lFont^.Color := lDialog.Font.Color;
    lFont^.Bold := fsBold in lDialog.Font.Style;
    lFont^.Italic := fsItalic in lDialog.Font.Style;
    // One manager name is one shared definition. Keep both local drafts in
    // sync so the second role cannot overwrite the just-edited definition.
    SyncSharedFont(lCombo);
  finally
    lDialog.Free;
  end;
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
  fDraft.BackgroundColor := LongInt(fBackgroundColorPanel.Color);
  fDraft.TextBackgroundColor := LongInt(fTextBackgroundColorPanel.Color);
  fDraft.SectionId := CurrentSectionId;
  fDraft.YoungModulusMPa := ParseFloatText(fYoungEdit.Text,
    fDraft.YoungModulusMPa);
  fDraft.PoissonRatio := ParseFloatText(fPoissonEdit.Text,
    fDraft.PoissonRatio);
  fDraft.TemperatureCoefficient := ParseFloatText(fTempCoeffEdit.Text,
    fDraft.TemperatureCoefficient);
  fDraft.ReferenceTemperatureC := ParseFloatText(fTempRefEdit.Text,
    fDraft.ReferenceTemperatureC);
  fDraft.NamedFontName := Trim(fCaptionFontCombo.Text);
  fDraft.CaptionFont := fCaptionFont;
  fDraft.StressNamedFontName := Trim(fStressFontCombo.Text);
  fDraft.StressFont := fStressFont;
  DefineNamedFont(fCaptionFontCombo, fCaptionFont);
  if not SameText(fDraft.NamedFontName, fDraft.StressNamedFontName) then
    DefineNamedFont(fStressFontCombo, fStressFont);
  fComponent.AssignSection(fDraft);
  if fFormatAllRequested then
    ApplyFontsToFactory;
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
  lPointCount, lBindingCount: Integer;
begin
  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Импорт измерительного сечения';
    lDialog.Filter := 'OpenDocument (*.ods)|*.ods|CSV (*.csv)|*.csv|Все файлы|*.*';
    lDialog.InitialDir := RecorderMeraFilesPath;
    if lDialog.Execute then
    begin
      ImportFromFile(lDialog.FileName, lPointCount, lBindingCount);
      RefreshGrid;
      MessageDlg('Импорт измерительного сечения', Format(
        'Импортировано точек: %d, привязок каналов: %d.',
        [lPointCount, lBindingCount]), mtInformation, [mbOK], 0);
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
  const AFileName: string; out APointCount, ABindingCount: Integer);
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
  APointCount := 0;
  ABindingCount := 0;
  lBook := TsWorkbook.Create;
  try
    lBook.ReadFromFile(AFileName, TableFormatByFileName(AFileName));
    if lBook.GetWorksheetCount = 0 then
      Exit;
    lSheet := lBook.GetWorksheetByName(CSheetName);
    if lSheet = nil then
      lSheet := lBook.GetWorksheetByIndex(0);
    BuildColumnMap(lSheet, False, lMap);
    if (lMap[scolTagName] < 0) or (lMap[scolSection] < 0) or
      (lMap[scolPoint] < 0) or (lMap[scolRole] < 0) or
      (lMap[scolRosette] < 0) or (lMap[scolPosition] < 0) then
      raise Exception.Create('В таблице отсутствуют обязательные колонки ' +
        'измерительного сечения.');
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
        Inc(APointCount);
      end;
      lText := ReadCell(lSheet, lRowIndex, lMap[scolRosette]);
      if lText <> '' then
        lRow.RosetteType := RecorderRosetteTypeFromText(lText);
      lRow.PositionDeg := ParseFloatText(ReadCell(lSheet, lRowIndex,
        lMap[scolPosition]), lRow.PositionDeg);
      lTag := nil;
      lText := ReadMappedCell(lSheet, lRowIndex, lMap[scolTagId]);
      if (fRegistry <> nil) and TryStrToInt64(lText, lTagId) then
        lTag := fRegistry.FindById(lTagId);
      lTagName := ReadCell(lSheet, lRowIndex, lMap[scolTagName]);
      if (lTag = nil) and (fRegistry <> nil) and (lTagName <> '') then
        lTag := fRegistry.FindByName(lTagName);
      if lTag <> nil then
      begin
        lRow.BindTag(lRole, lTag);
        Inc(ABindingCount);
      end
      else
      begin
        lRow.TagNames[lRole] := lTagName;
        if lTagName <> '' then
          Inc(ABindingCount);
      end;
    end;
  finally
    lBook.Free;
  end;
end;

end.
