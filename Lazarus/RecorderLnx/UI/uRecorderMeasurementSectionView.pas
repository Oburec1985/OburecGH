unit uRecorderMeasurementSectionView;

{
  Визуальное представление компонента "Измерительное сечение".
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Grids, Graphics,
  LCLType, LCLIntf,
  Math, uOglChart, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uRecorderMeasurementSectionModel;

type
  TRecorderMeasurementSectionTableForm = class(TForm)
  private
    fBalanceButton: TButton;
    fBadCells: array of array of Boolean;
    fComponent: TRecorderMeasurementSectionComponent;
    fGrid: TStringGrid;
    fPointInfoMemo: TMemo;
    fReportButton: TButton;
    fReportOptionsPanel: TPanel;
    fReportPanel: TPanel;
    fReportScope: TRadioGroup;
    fReportSplitter: TSplitter;
    fRegistry: TRecorderTagRegistry;
    fTimer: TTimer;
    procedure BalanceClick(Sender: TObject);
    procedure CaptureSelectedBalance;
    function FormatMaybe(AHasValue: Boolean; AValue: Double;
      const AFormat: string): string;
    procedure GridPrepareCanvas(Sender: TObject; ACol, ARow: Integer;
      AState: TGridDrawState);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure MarkBadCell(ACol, ARow: Integer);
    function SelectedCellsIncludeColumn(ACol: Integer): Boolean;
    function TagValueOutOfTolerance(ATag: TRecorderTag): Boolean;
    procedure TimerTick(Sender: TObject);
    procedure ReportClick(Sender: TObject);
    procedure UpdatePointInfo(ARow: Integer);
  public
    constructor CreateTable(AOwner: TComponent;
      AComponent: TRecorderMeasurementSectionComponent;
      ARegistry: TRecorderTagRegistry); reintroduce;
    procedure RefreshTable;
  end;

  TRecorderMeasurementSectionView = class(TPanel, IVForm)
  private
    fComponent: TRecorderMeasurementSectionComponent;
    fEditMode: Boolean;
    fRegistry: TRecorderTagRegistry;
    fTableForm: TRecorderMeasurementSectionTableForm;
    function BuildSummaryText: string;
    procedure ApplyFont(const AFont: TRecorderFontSnapshot);
    function DrawWrappedText(const AText: string; ATop: Integer;
      const AFont: TRecorderFontSnapshot): Integer;
    procedure OpenTable(Sender: TObject);
    procedure TableDestroyed(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
    property EditMode: Boolean read fEditMode write fEditMode;
  end;

implementation

uses
  Dialogs, IniFiles, fpspreadsheet, fpstypes, fpsopendocument,
  uRecorderMeraPaths;

const
  CColPoint = 0;
  CColTemp = 1;
  CColE1 = 2;
  CColE2 = 3;
  CColE3 = 4;
  CColSigma1 = 5;
  CColSigma2 = 6;
  CColAngle = 7;

{ TRecorderMeasurementSectionTableForm }

constructor TRecorderMeasurementSectionTableForm.CreateTable(AOwner: TComponent;
  AComponent: TRecorderMeasurementSectionComponent; ARegistry: TRecorderTagRegistry);
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent;
  fRegistry := ARegistry;
  Caption := 'Измерительное сечение';
  if fComponent <> nil then
    Caption := fComponent.Caption;
  FormStyle := fsStayOnTop;
  Position := poDesigned;
  Width := 760;
  Height := 520;

  fBalanceButton := TButton.Create(Self);
  fBalanceButton.Parent := Self;
  fBalanceButton.Align := alTop;
  fBalanceButton.Height := 28;
  fBalanceButton.Caption := 'Обновить балансировку';
  fBalanceButton.OnClick := @BalanceClick;

  fGrid := TStringGrid.Create(Self);
  fGrid.Parent := Self;
  fGrid.Align := alClient;
  fGrid.FixedCols := 0;
  fGrid.FixedRows := 1;
  fGrid.ColCount := 8;
  fGrid.RowCount := 2;
  fGrid.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
    goRangeSelect, goColSizing];
  fGrid.OnPrepareCanvas := @GridPrepareCanvas;
  fGrid.OnSelectCell := @GridSelectCell;
  fGrid.Cells[CColPoint, 0] := 'N точки';
  fGrid.Cells[CColTemp, 0] := 'Температура, °C';
  fGrid.Cells[CColE1, 0] := 'e1, мкстрн';
  fGrid.Cells[CColE2, 0] := 'e2, мкстрн';
  fGrid.Cells[CColE3, 0] := 'e3, мкстрн';
  fGrid.Cells[CColSigma1, 0] := 'sigma1, МПа';
  fGrid.Cells[CColSigma2, 0] := 'sigma2, МПа';
  fGrid.Cells[CColAngle, 0] := 'Угол, °';
  fGrid.ColWidths[CColPoint] := 70;
  fGrid.ColWidths[CColTemp] := 110;
  fGrid.ColWidths[CColE1] := 90;
  fGrid.ColWidths[CColE2] := 90;
  fGrid.ColWidths[CColE3] := 90;
  fGrid.ColWidths[CColSigma1] := 100;
  fGrid.ColWidths[CColSigma2] := 100;
  fGrid.ColWidths[CColAngle] := 80;

  fReportPanel := TPanel.Create(Self);
  fReportPanel.Parent := Self;
  fReportPanel.Align := alBottom;
  fReportPanel.Height := 145;
  fReportPanel.BevelOuter := bvNone;

  fReportOptionsPanel := TPanel.Create(Self);
  fReportOptionsPanel.Parent := fReportPanel;
  fReportOptionsPanel.Align := alLeft;
  fReportOptionsPanel.Width := 230;
  fReportOptionsPanel.BevelOuter := bvNone;

  fReportButton := TButton.Create(Self);
  fReportButton.Parent := fReportOptionsPanel;
  fReportButton.Align := alBottom;
  fReportButton.Height := 32;
  fReportButton.Caption := 'Сформировать отчет...';
  fReportButton.OnClick := @ReportClick;

  fReportScope := TRadioGroup.Create(Self);
  fReportScope.Parent := fReportOptionsPanel;
  fReportScope.Align := alClient;
  fReportScope.Caption := 'Отчет';
  fReportScope.Items.Add('По текущему сечению');
  fReportScope.Items.Add('По текущей странице');
  fReportScope.Items.Add('По всем сечениям');
  fReportScope.ItemIndex := 0;

  fPointInfoMemo := TMemo.Create(Self);
  fPointInfoMemo.Parent := fReportPanel;
  fPointInfoMemo.Align := alClient;
  fPointInfoMemo.ReadOnly := True;
  fPointInfoMemo.ScrollBars := ssAutoVertical;
  fPointInfoMemo.TextHint := 'Информация о выбранной точке';

  fReportSplitter := TSplitter.Create(Self);
  fReportSplitter.Parent := Self;
  fReportSplitter.Align := alBottom;
  fReportSplitter.Height := 5;

  fTimer := TTimer.Create(Self);
  fTimer.Interval := 250;
  fTimer.OnTimer := @TimerTick;
  fTimer.Enabled := True;
  RefreshTable;
  UpdatePointInfo(1);
end;

procedure TRecorderMeasurementSectionTableForm.BalanceClick(Sender: TObject);
begin
  CaptureSelectedBalance;
  RefreshTable;
end;

procedure TRecorderMeasurementSectionTableForm.CaptureSelectedBalance;
var
  I, lTop, lBottom: Integer;
  lAnyRoleColumn: Boolean;
  lSelection: TGridRect;
begin
  if (fComponent = nil) or (fGrid.RowCount <= 1) then
    Exit;
  lSelection := fGrid.Selection;
  if lSelection.Top < lSelection.Bottom then
  begin
    lTop := lSelection.Top;
    lBottom := lSelection.Bottom;
  end
  else
  begin
    lTop := lSelection.Bottom;
    lBottom := lSelection.Top;
  end;
  if lTop < 1 then
    lTop := 1;
  if lBottom > fComponent.RowCount then
    lBottom := fComponent.RowCount;

  lAnyRoleColumn := SelectedCellsIncludeColumn(CColE1) or
    SelectedCellsIncludeColumn(CColE2) or SelectedCellsIncludeColumn(CColE3);
  for I := lTop to lBottom do
  begin
    if (not lAnyRoleColumn) or SelectedCellsIncludeColumn(CColE1) then
      fComponent.CaptureRowBalance(fRegistry, fComponent.Rows[I - 1], rrrE1);
    if (not lAnyRoleColumn) or SelectedCellsIncludeColumn(CColE2) then
      fComponent.CaptureRowBalance(fRegistry, fComponent.Rows[I - 1], rrrE2);
    if (not lAnyRoleColumn) or SelectedCellsIncludeColumn(CColE3) then
      fComponent.CaptureRowBalance(fRegistry, fComponent.Rows[I - 1], rrrE3);
  end;
end;

function TRecorderMeasurementSectionTableForm.FormatMaybe(AHasValue: Boolean;
  AValue: Double; const AFormat: string): string;
begin
  if AHasValue then
    Result := FormatFloat(AFormat, AValue)
  else
    Result := '-';
end;

procedure TRecorderMeasurementSectionTableForm.GridPrepareCanvas(
  Sender: TObject; ACol, ARow: Integer; AState: TGridDrawState);
begin
  if (gdSelected in AState) or (ARow <= 0) or (ACol < 0) or
    (ARow >= Length(fBadCells)) or (ACol >= Length(fBadCells[ARow])) then
    Exit;
  if fBadCells[ARow][ACol] then
  begin
    fGrid.Canvas.Brush.Color := clSilver;
    fGrid.Canvas.Font.Color := clBlack;
  end;
end;

procedure TRecorderMeasurementSectionTableForm.GridSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  UpdatePointInfo(ARow);
end;

procedure TRecorderMeasurementSectionTableForm.UpdatePointInfo(ARow: Integer);
begin
  if fPointInfoMemo = nil then
    Exit;
  if (fComponent <> nil) and (ARow > 0) and
    (ARow <= fComponent.RowCount) then
    fPointInfoMemo.Text := fComponent.Rows[ARow - 1].PointInfo
  else
    fPointInfoMemo.Clear;
end;

procedure TRecorderMeasurementSectionTableForm.ReportClick(Sender: TObject);
const
  CIniSection = 'MeasurementSectionReport';
  CIniDirectory = 'LastDirectory';
var
  lBook: TsWorkbook;
  lSheet: TsWorksheet;
  lDialog: TSaveDialog;
  lIni: TIniFile;
  lSections: TList;
  lSection: TRecorderMeasurementSectionComponent;
  lRow: TRecorderMeasurementSectionRow;
  lValues: TRecorderMeasurementSectionValues;
  lTag: TRecorderTag;
  lFileName, lDirectory: string;
  I, J, lLastRow, lOutRow: Integer;

  procedure WriteText(ACol: Integer; const AText: string);
  begin
    lSheet.WriteUTF8Text(lOutRow, ACol, AText);
  end;

  procedure WriteValue(ACol: Integer; AHasValue: Boolean; AValue: Double);
  begin
    if AHasValue then
      lSheet.WriteNumber(lOutRow, ACol, AValue);
  end;

  function ChannelName(ARole: TRecorderRosetteRole): string;
  begin
    lTag := lRow.ResolveTag(fRegistry, ARole);
    if lTag <> nil then
      Result := lTag.Name
    else
      Result := lRow.TagNames[ARole];
  end;

  procedure StyleHeaderRow(ARow: Integer);
  var
    lCol: Integer;
  begin
    for lCol := 0 to 13 do
    begin
      lSheet.WriteBackgroundColor(ARow, lCol, scYellow);
      lSheet.WriteFontStyle(ARow, lCol, [fssBold]);
      lSheet.WriteBorders(ARow, lCol, [cbNorth, cbWest, cbEast, cbSouth]);
      lSheet.WriteWordwrap(ARow, lCol, True);
      lSheet.WriteVertAlignment(ARow, lCol, vaCenter);
    end;
  end;

  procedure StyleDataRow(ARow: Integer);
  var
    lCol: Integer;
  begin
    for lCol := 0 to 13 do
    begin
      lSheet.WriteBorders(ARow, lCol, [cbNorth, cbWest, cbEast, cbSouth]);
      lSheet.WriteVertAlignment(ARow, lCol, vaCenter);
    end;
    lSheet.WriteWordwrap(ARow, 0, True);
    lSheet.WriteWordwrap(ARow, 2, True);
  end;

  procedure ApplyColumnWidths;
  const
    CWidths: array[0..13] of Single =
      (30, 12, 22, 14, 14, 14, 14, 14, 14, 14, 11, 18, 18, 12);
  var
    lCol: Integer;
  begin
    for lCol := 0 to 13 do
      lSheet.WriteColWidth(lCol, CWidths[lCol]);
  end;
begin
  if fComponent = nil then
    Exit;
  lDialog := TSaveDialog.Create(Self);
  lSections := TList.Create;
  try
    try
      lDirectory := RecorderMeraFilesPath;
    if FileExists(RecorderAppConfigFileName) then
    begin
      lIni := TIniFile.Create(RecorderAppConfigFileName);
      try
        lDirectory := lIni.ReadString(CIniSection, CIniDirectory, lDirectory);
      finally
        lIni.Free;
      end;
    end;
    if not DirectoryExists(lDirectory) then
      lDirectory := RecorderMeraFilesPath;
    lDialog.Filter := 'Таблица OpenDocument (*.ods)|*.ods';
    lDialog.DefaultExt := 'ods';
    lDialog.InitialDir := lDirectory;
    lDialog.FileName := 'measurement-sections-' +
      FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now) + '.ods';
    if not lDialog.Execute then
      Exit;
    lFileName := lDialog.FileName;
    if ExtractFileExt(lFileName) = '' then
      lFileName := lFileName + '.ods';

    if (fReportScope.ItemIndex = 2) and (fComponent.Factory <> nil) then
    begin
      for I := 0 to fComponent.Factory.ChildCount - 1 do
        if fComponent.Factory.Children[I] is TRecorderMeasurementSectionComponent then
          lSections.Add(fComponent.Factory.Children[I]);
    end
    else if (fReportScope.ItemIndex = 1) and
      (fComponent.ParentPage <> nil) then
    begin
      for I := 0 to fComponent.ParentPage.ComponentCount - 1 do
        if fComponent.ParentPage.Components[I] is
          TRecorderMeasurementSectionComponent then
          lSections.Add(fComponent.ParentPage.Components[I]);
    end
    else
      lSections.Add(fComponent);

    { The opened table is the authoritative live component.  Some projects
      created by older builds can have an incomplete page/factory ownership
      link after loading.  Never let that make a selected or all-pages report
      silently lose the section the user is currently looking at. }
    if lSections.IndexOf(fComponent) < 0 then
      lSections.Insert(0, fComponent);
    if fComponent.RowCount = 0 then
    begin
      MessageDlg('В текущем сечении нет точек для отчета.',
        mtInformation, [mbOK], 0);
      Exit;
    end;

    lBook := TsWorkbook.Create;
    try
      if FileExists(lFileName) then
        lBook.ReadFromFile(lFileName, sfOpenDocument);
      lSheet := lBook.GetWorksheetByName('Отчет');
      if lSheet = nil then
        if lBook.GetWorksheetCount > 0 then
          lSheet := lBook.GetWorksheetByIndex(0)
        else
          lSheet := lBook.AddWorksheet('Отчет');

      { Append after the last block.  Deliberately inspect column A only:
        internal spacer rows (between report time and header) remain part of
        their block, while the first empty A cell after the final data row is
        the insertion point requested by the operator. }
      lOutRow := 0;
      if lSheet.GetCellCount > 0 then
      begin
        lLastRow := Integer(lSheet.GetLastRowIndex(True));
        for I := 0 to lLastRow do
          if Trim(lSheet.ReadAsUTF8Text(I, 0)) <> '' then
            lOutRow := I + 1;
      end;
      ApplyColumnWidths;
      WriteText(0, 'Время отчета');
      WriteText(1, FormatDateTime('dd.mm.yyyy hh:nn:ss', Now));
      lSheet.WriteFontStyle(lOutRow, 0, [fssBold]);
      Inc(lOutRow, 2);
      WriteText(0, 'Сечение'); WriteText(1, 'N точки');
      WriteText(2, 'Информация о точке'); WriteText(3, 'Канал E1');
      WriteText(4, 'Канал E2'); WriteText(5, 'Канал E3');
      WriteText(6, 'Канал t'); WriteText(7, 'e1, мкстрн');
      WriteText(8, 'e2, мкстрн'); WriteText(9, 'e3, мкстрн');
      WriteText(10, 't, °C'); WriteText(11, 'sigma1, МПа');
      WriteText(12, 'sigma2, МПа'); WriteText(13, 'Угол, °');
      StyleHeaderRow(lOutRow);
      Inc(lOutRow);
      for I := 0 to lSections.Count - 1 do
      begin
        lSection := TRecorderMeasurementSectionComponent(lSections[I]);
        for J := 0 to lSection.RowCount - 1 do
        begin
          lRow := lSection.Rows[J];
          lSection.CalculateRow(fRegistry, lRow, lValues);
          WriteText(0, lSection.Caption);
          lSheet.WriteNumber(lOutRow, 1, lRow.PointNo);
          WriteText(2, lRow.PointInfo);
          WriteText(3, ChannelName(rrrE1)); WriteText(4, ChannelName(rrrE2));
          WriteText(5, ChannelName(rrrE3)); WriteText(6, ChannelName(rrrTemperature));
          WriteValue(7, lValues.HasE1, lValues.E1);
          WriteValue(8, lValues.HasE2, lValues.E2);
          WriteValue(9, lValues.HasE3, lValues.E3);
          WriteValue(10, lValues.HasTemperature, lValues.Temperature);
          WriteValue(11, lValues.HasSigma1, lValues.Sigma1);
          WriteValue(12, lValues.HasSigma2, lValues.Sigma2);
          if lValues.HasAngle then
            lSheet.WriteNumber(lOutRow, 13, lValues.AngleDeg)
          else
            lSheet.WriteNumber(lOutRow, 13, lRow.PositionDeg);
          StyleDataRow(lOutRow);
          Inc(lOutRow);
        end;
      end;
      lBook.WriteToFile(lFileName, sfOpenDocument, True);
    finally
      lBook.Free;
    end;

    ForceDirectories(ExtractFilePath(RecorderAppConfigFileName));
    lIni := TIniFile.Create(RecorderAppConfigFileName);
    try
      lIni.WriteString(CIniSection, CIniDirectory,
        ExcludeTrailingPathDelimiter(ExtractFilePath(lFileName)));
    finally
      lIni.Free;
    end;
    if MessageDlg('Отчет сохранен',
      'Отчет сохранен.' + LineEnding + 'Открыть его сейчас?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      if not OpenDocument(lFileName) then
        MessageDlg('Не удалось открыть отчет.', mtWarning, [mbOK], 0);
    except
      on E: Exception do
        MessageDlg('Ошибка создания отчета: ' + E.Message,
          mtError, [mbOK], 0);
    end;
  finally
    lSections.Free;
    lDialog.Free;
  end;
end;

procedure TRecorderMeasurementSectionTableForm.MarkBadCell(ACol,
  ARow: Integer);
begin
  if (ARow >= 0) and (ARow < Length(fBadCells)) and
    (ACol >= 0) and (ACol < Length(fBadCells[ARow])) then
    fBadCells[ARow][ACol] := True;
end;

procedure TRecorderMeasurementSectionTableForm.TimerTick(Sender: TObject);
begin
  RefreshTable;
end;

procedure TRecorderMeasurementSectionTableForm.RefreshTable;
var
  I: Integer;
  J: Integer;
  lBadE1: Boolean;
  lBadE2: Boolean;
  lBadE3: Boolean;
  lBadTemp: Boolean;
  lRow: TRecorderMeasurementSectionRow;
  lValues: TRecorderMeasurementSectionValues;
begin
  if fComponent = nil then
    Exit;
  fGrid.RowCount := Max(2, fComponent.RowCount + 1);
  SetLength(fBadCells, fGrid.RowCount);
  for I := 0 to fGrid.RowCount - 1 do
  begin
    SetLength(fBadCells[I], fGrid.ColCount);
    for J := 0 to fGrid.ColCount - 1 do
      fBadCells[I][J] := False;
  end;
  for I := 0 to fComponent.RowCount - 1 do
  begin
    lRow := fComponent.Rows[I];
    fComponent.CalculateRow(fRegistry, lRow, lValues);
    lBadTemp := TagValueOutOfTolerance(lRow.ResolveTag(fRegistry,
      rrrTemperature));
    lBadE1 := TagValueOutOfTolerance(lRow.ResolveTag(fRegistry, rrrE1));
    lBadE2 := TagValueOutOfTolerance(lRow.ResolveTag(fRegistry, rrrE2));
    lBadE3 := TagValueOutOfTolerance(lRow.ResolveTag(fRegistry, rrrE3));
    fGrid.Cells[CColPoint, I + 1] := IntToStr(lRow.PointNo);
    fGrid.Cells[CColTemp, I + 1] := FormatMaybe(lValues.HasTemperature,
      lValues.Temperature, '0.###');
    fGrid.Cells[CColE1, I + 1] := FormatMaybe(lValues.HasE1, lValues.E1,
      '0.###');
    fGrid.Cells[CColE2, I + 1] := FormatMaybe(lValues.HasE2, lValues.E2,
      '0.###');
    fGrid.Cells[CColE3, I + 1] := FormatMaybe(lValues.HasE3, lValues.E3,
      '0.###');
    fGrid.Cells[CColSigma1, I + 1] := FormatMaybe(lValues.HasSigma1,
      lValues.Sigma1, '0.###');
    fGrid.Cells[CColSigma2, I + 1] := FormatMaybe(lValues.HasSigma2,
      lValues.Sigma2, '0.###');
    if lValues.HasAngle then
      fGrid.Cells[CColAngle, I + 1] := FormatFloat('0.###', lValues.AngleDeg)
    else
      fGrid.Cells[CColAngle, I + 1] := FormatFloat('0.###', lRow.PositionDeg);
    if lBadTemp then
      MarkBadCell(CColTemp, I + 1);
    if lBadE1 then
      MarkBadCell(CColE1, I + 1);
    if lBadE2 then
      MarkBadCell(CColE2, I + 1);
    if lBadE3 then
      MarkBadCell(CColE3, I + 1);
    if not lValues.HasSigma1 then
      MarkBadCell(CColSigma1, I + 1);
    if not lValues.HasSigma2 then
      MarkBadCell(CColSigma2, I + 1);
  end;
end;

function TRecorderMeasurementSectionTableForm.SelectedCellsIncludeColumn(
  ACol: Integer): Boolean;
var
  lLeft, lRight: Integer;
  lSelection: TGridRect;
begin
  lSelection := fGrid.Selection;
  if lSelection.Left < lSelection.Right then
  begin
    lLeft := lSelection.Left;
    lRight := lSelection.Right;
  end
  else
  begin
    lLeft := lSelection.Right;
    lRight := lSelection.Left;
  end;
  Result := (ACol >= lLeft) and (ACol <= lRight);
end;

function TRecorderMeasurementSectionTableForm.TagValueOutOfTolerance(
  ATag: TRecorderTag): Boolean;
var
  lValue: Double;
begin
  Result := (ATag = nil) or (ATag.SignalBuffer.Count = 0);
  if Result or (ATag.RangeMax <= ATag.RangeMin) then
    Exit;
  lValue := ATag.SignalBuffer.LatestValue;
  Result := (lValue < ATag.RangeMin) or (lValue > ATag.RangeMax);
end;

{ TRecorderMeasurementSectionView }

constructor TRecorderMeasurementSectionView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvLowered;
  ParentBackground := False;
  Color := $00FFF4E8;
  Caption := '';
  Alignment := taCenter;
  OnClick := @OpenTable;
end;

destructor TRecorderMeasurementSectionView.Destroy;
begin
  if fTableForm <> nil then
  begin
    fTableForm.OnDestroy := nil;
    FreeAndNil(fTableForm);
  end;
  inherited Destroy;
end;

procedure TRecorderMeasurementSectionView.Configure(
  AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
begin
  if not (AComponent is TRecorderMeasurementSectionComponent) then
    Exit;
  fComponent := TRecorderMeasurementSectionComponent(AComponent);
  fRegistry := ATagRegistry;
  Caption := '';
  Hint := fComponent.Caption;
end;

procedure TRecorderMeasurementSectionView.RefreshControl(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
begin
  if ATagRegistry <> nil then
    fRegistry := ATagRegistry;
  if fTableForm <> nil then
    fTableForm.RefreshTable;
  Invalidate;
end;

function TRecorderMeasurementSectionView.GetChartControl: TOglChart;
begin
  Result := nil;
end;

procedure TRecorderMeasurementSectionView.OpenTable(Sender: TObject);
begin
  if (fComponent = nil) or fEditMode then
    Exit;
  if fTableForm = nil then
  begin
    fTableForm := TRecorderMeasurementSectionTableForm.CreateTable(Self,
      fComponent, fRegistry);
    fTableForm.OnDestroy := @TableDestroyed;
  end;
  fTableForm.Show;
  fTableForm.BringToFront;
  fTableForm.RefreshTable;
  Invalidate;
end;

procedure TRecorderMeasurementSectionView.TableDestroyed(Sender: TObject);
begin
  fTableForm := nil;
  Invalidate;
end;

function TRecorderMeasurementSectionView.BuildSummaryText: string;
var
  I: Integer;
  lBestPoint: Integer;
  lBestSigma: Integer;
  lBestStress: Double;
  lStress: Double;
  lSigma: Integer;
  lValues: TRecorderMeasurementSectionValues;
begin
  Result := '';
  if fComponent = nil then
    Exit;
  lBestPoint := 0;
  lBestSigma := 0;
  lBestStress := -1.0;
  for I := 0 to fComponent.RowCount - 1 do
  begin
    fComponent.CalculateRow(fRegistry, fComponent.Rows[I], lValues);
    lStress := -1.0;
    lSigma := 0;
    if lValues.HasSigma1 then
    begin
      lStress := Abs(lValues.Sigma1);
      lSigma := 1;
    end;
    if lValues.HasSigma2 and (Abs(lValues.Sigma2) > lStress) then
    begin
      lStress := Abs(lValues.Sigma2);
      lSigma := 2;
    end;
    if lStress > lBestStress then
    begin
      lBestStress := lStress;
      lBestPoint := fComponent.Rows[I].PointNo;
      lBestSigma := lSigma;
    end;
  end;
  if lBestPoint > 0 then
    Result := Format('Точка %d: S%d=%.3f МПа',
      [lBestPoint, lBestSigma, lBestStress]);
end;

procedure TRecorderMeasurementSectionView.ApplyFont(
  const AFont: TRecorderFontSnapshot);
begin
  Canvas.Font.Name := AFont.Name;
  Canvas.Font.Size := AFont.Size;
  Canvas.Font.Color := TColor(AFont.Color);
  Canvas.Font.Style := [];
  if AFont.Bold then
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];
  if AFont.Italic then
    Canvas.Font.Style := Canvas.Font.Style + [fsItalic];
end;

function TRecorderMeasurementSectionView.DrawWrappedText(
  const AText: string; ATop: Integer;
  const AFont: TRecorderFontSnapshot): Integer;
var
  lRect: TRect;
begin
  Result := ATop;
  if AText = '' then
    Exit;
  ApplyFont(AFont);
  lRect := Rect(6, ATop, Max(7, ClientWidth - 6), ClientHeight - 6);
  DrawText(Canvas.Handle, PChar(AText), Length(AText), lRect,
    DT_WORDBREAK or DT_NOPREFIX or DT_CALCRECT);
  lRect.Right := Max(7, ClientWidth - 6);
  lRect.Bottom := Min(lRect.Bottom, ClientHeight - 6);
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := TColor(fComponent.TextBackgroundColor);
  Canvas.FillRect(lRect);
  Canvas.Brush.Style := bsClear;
  DrawText(Canvas.Handle, PChar(AText), Length(AText), lRect,
    DT_WORDBREAK or DT_NOPREFIX);
  Result := lRect.Bottom;
end;

procedure TRecorderMeasurementSectionView.Paint;
var
  lCaptionFont: TRecorderFontSnapshot;
  lCaption, lSummary: string;
  lStressFont: TRecorderFontSnapshot;
  lTextY: Integer;
begin
  if fComponent <> nil then
    Color := TColor(fComponent.BackgroundColor);
  inherited Paint;
  if fComponent = nil then
    Exit;

  lCaption := fComponent.Caption;
  lSummary := BuildSummaryText;

  Canvas.Brush.Style := bsClear;
  lTextY := 6;
  if lCaption <> '' then
  begin
    fComponent.GetCaptionFont(lCaptionFont);
    lTextY := DrawWrappedText(lCaption, lTextY, lCaptionFont) + 4;
  end;
  if lSummary <> '' then
  begin
    fComponent.GetStressFont(lStressFont);
    DrawWrappedText(lSummary, lTextY, lStressFont);
  end;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(
    TRecorderMeasurementSectionComponent, TRecorderMeasurementSectionView);

end.
