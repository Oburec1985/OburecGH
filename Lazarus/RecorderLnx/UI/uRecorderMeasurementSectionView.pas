unit uRecorderMeasurementSectionView;

{
  Визуальное представление компонента "Измерительное сечение".
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Grids, Graphics,
  Math, uOglChart, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uRecorderMeasurementSectionModel;

type
  TRecorderMeasurementSectionTableForm = class(TForm)
  private
    fBalanceButton: TButton;
    fBadCells: array of array of Boolean;
    fComponent: TRecorderMeasurementSectionComponent;
    fGrid: TStringGrid;
    fRegistry: TRecorderTagRegistry;
    fTimer: TTimer;
    procedure BalanceClick(Sender: TObject);
    procedure CaptureSelectedBalance;
    function FormatMaybe(AHasValue: Boolean; AValue: Double;
      const AFormat: string): string;
    procedure GridPrepareCanvas(Sender: TObject; ACol, ARow: Integer;
      AState: TGridDrawState);
    procedure MarkBadCell(ACol, ARow: Integer);
    function SelectedCellsIncludeColumn(ACol: Integer): Boolean;
    function TagValueOutOfTolerance(ATag: TRecorderTag): Boolean;
    procedure TimerTick(Sender: TObject);
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
  Height := 360;

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

  fTimer := TTimer.Create(Self);
  fTimer.Interval := 250;
  fTimer.OnTimer := @TimerTick;
  fTimer.Enabled := True;
  RefreshTable;
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
    fGrid.Cells[CColAngle, I + 1] := FormatMaybe(lValues.HasAngle,
      lValues.AngleDeg, '0.###');
    if lBadTemp then
      MarkBadCell(CColTemp, I + 1);
    if lBadE1 then
      MarkBadCell(CColE1, I + 1);
    if lBadE2 then
      MarkBadCell(CColE2, I + 1);
    if lBadE3 then
      MarkBadCell(CColE3, I + 1);
    if lBadTemp or lBadE1 or lBadE2 or lBadE3 then
    begin
      MarkBadCell(CColSigma1, I + 1);
      MarkBadCell(CColSigma2, I + 1);
      MarkBadCell(CColAngle, I + 1);
    end;
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
  Result := False;
  if (ATag = nil) or (ATag.SignalBuffer.Count = 0) or
    (ATag.RangeMax <= ATag.RangeMin) then
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
  lBestStrain: Double;
  lValues: TRecorderMeasurementSectionValues;
begin
  Result := '';
  if fComponent = nil then
    Exit;
  lBestPoint := 0;
  lBestStrain := -1.0;
  for I := 0 to fComponent.RowCount - 1 do
  begin
    fComponent.CalculateRow(fRegistry, fComponent.Rows[I], lValues);
    if lValues.MaxAbsStrain > lBestStrain then
    begin
      lBestStrain := lValues.MaxAbsStrain;
      lBestPoint := fComponent.Rows[I].PointNo;
    end;
  end;
  if lBestPoint > 0 then
    Result := Format('Точка %d: e=%.3f мкстрн', [lBestPoint, lBestStrain]);
end;

procedure TRecorderMeasurementSectionView.Paint;
var
  lCaption, lSummary: string;
  lTextY: Integer;
begin
  inherited Paint;
  if fComponent = nil then
    Exit;

  lCaption := fComponent.Caption;
  lSummary := BuildSummaryText;

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color := clWindowText;
  lTextY := 6;
  if lCaption <> '' then
  begin
    Canvas.TextOut(6, lTextY, lCaption);
    Inc(lTextY, Canvas.TextHeight(lCaption) + 4);
  end;
  if lSummary <> '' then
    Canvas.TextOut(6, lTextY, lSummary);
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(
    TRecorderMeasurementSectionComponent, TRecorderMeasurementSectionView);

end.
