unit uRecorderOglOscillogramView;

{$mode objfpc}{$H+}

interface

uses
  Classes, Controls, ExtCtrls, StdCtrls,
  uOglChart, uRecorderFormModel, uRecorderTags;

type
  { TRecorderOglOscillogram
    Thin RecorderLnx wrapper around oglChart. It owns a default chart model with
    one page, one axis and one buffered trend. }
  TRecorderOglOscillogram = class(TPanel)
  private
    fAbsoluteTagName: string;
    fBindingMode: TRecorderTagBindingMode;
    fChart: TOglChart;
    fInfoLabel: TLabel;
    fCurrentTagName: string;
    fFrameNo: Integer;
    fTagOffset: Integer;
    fTagSlotIndex: Integer;
    fModel: TObject;
    fPage: TObject;
    fAxis: TObject;
    fTrend: TObject;
    procedure ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
    function ResolveTag(ATagRegistry: TRecorderTagRegistry): TRecorderTag;
    procedure SetAxisRange(AMinValue, AMaxValue: Double);
    procedure SetChartTitle(const ATitle: string);
    procedure SetXRange(ADisplaySeconds: Double);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ConfigureDefault;
    procedure Refresh(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    property AbsoluteTagName: string read fAbsoluteTagName write fAbsoluteTagName;
    property BindingMode: TRecorderTagBindingMode read fBindingMode
      write fBindingMode;
    property ChartControl: TOglChart read fChart;
    property TagOffset: Integer read fTagOffset write fTagOffset;
    property TagSlotIndex: Integer read fTagSlotIndex write fTagSlotIndex;
  end;

procedure RebuildRecorderOglOscillograms(AOwner: TComponent; APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ACount: Integer;
  ADisplaySeconds: Double);
procedure RefreshRecorderOglOscillograms(APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);

implementation

uses
  SysUtils, Math, Graphics,
  uOglChartChart, uOglChartPage, uOglChartAxis, uOglChartTrend,
  uOglChartDrawObj, uRecorderDebugLog;

{ TRecorderOglOscillogram }

constructor TRecorderOglOscillogram.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ParentBackground := False;
  Color := clWhite;
  fBindingMode := rtbmRelativeSelectedTag;
  fTagOffset := 0;
  fTagSlotIndex := 0;
  ConfigureDefault;
end;

destructor TRecorderOglOscillogram.Destroy;
begin
  inherited Destroy;
end;

procedure TRecorderOglOscillogram.ConfigureDefault;
var
  lChart: TOglChart;
  lModel: TChartModel;
  lPageArea: TChartFloatRect;
  lPage: TChartPage;
  lAxis: TChartAxis;
  lTrend: cBuffTrend1d;
begin
  while ControlCount > 0 do
    Controls[0].Free;

  fInfoLabel := TLabel.Create(Self);
  fInfoLabel.Parent := Self;
  fInfoLabel.Align := alTop;
  fInfoLabel.Font.Name := 'Segoe UI';
  fInfoLabel.Font.Size := 9;
  fInfoLabel.Font.Style := [fsBold];
  fInfoLabel.Font.Color := $00404040;
  fInfoLabel.BorderSpacing.Around := 4;
  fInfoLabel.Caption := 'Tag: None | FPS: 0.0';

  lChart := TOglChart.Create(Self);
  lChart.Parent := Self;
  lChart.Align := alClient;
  lChart.AutoResizeViewport := True;
  lChart.OnAfterRender := @ChartAfterRender;

  lModel := TChartModel.Create;
  lModel.Title := '';
  lModel.BackgroundColor := $FFFFFFFF;
  lPageArea.Left := 0.0;
  lPageArea.Top := 0.0;
  lPageArea.Right := 1.0;
  lPageArea.Bottom := 1.0;
  lModel.PageArea := lPageArea;

  lPage := TChartPage.Create;
  lPage.Name := 'Page1';
  lPage.Caption := '';
  lPage.Align := cpaClient;
  lPage.FillColor := $FFFFFFFF;
  lPage.BorderColor := $FF707070;
  lPage.XMinValue := 0;
  lPage.XMaxValue := 1;

  lAxis := TChartAxis.Create;
  lAxis.Name := 'Axis1';
  lAxis.Caption := '';
  lAxis.MinValue := -1;
  lAxis.MaxValue := 1;

  lTrend := cBuffTrend1d.Create;
  lTrend.Name := 'Signal';
  lTrend.Caption := '';
  lTrend.Color := $FFFF0000;
  lTrend.X0 := 0;
  lTrend.DX := 1;

  lAxis.AddChild(lTrend);
  lPage.AddChild(lAxis);
  lModel.AddChild(lPage);
  lChart.Model := lModel;

  fChart := lChart;
  fModel := lModel;
  fPage := lPage;
  fAxis := lAxis;
  fTrend := lTrend;
end;

procedure TRecorderOglOscillogram.ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
var
  lFps: Double;
  lTagName: string;
begin
  if ARenderTimeMs > 0 then
    lFps := 1000.0 / ARenderTimeMs
  else
    lFps := 0;

  if fCurrentTagName <> '' then
    lTagName := fCurrentTagName
  else
    lTagName := 'None';

  fInfoLabel.Caption := Format('Tag: %s | FPS: %.1f (%.2f ms)', [lTagName, lFps, ARenderTimeMs]);
end;

function TRecorderOglOscillogram.ResolveTag(
  ATagRegistry: TRecorderTagRegistry): TRecorderTag;
var
  I: Integer;
  lIndex: Integer;
  lSelected: TRecorderTag;
begin
  Result := nil;
  if (ATagRegistry = nil) or (ATagRegistry.TagCount = 0) then
    Exit;

  if fBindingMode = rtbmAbsoluteTag then
  begin
    if fAbsoluteTagName <> '' then
      Result := ATagRegistry.FindByName(fAbsoluteTagName);
    if Result = nil then
      Result := ATagRegistry.Tags[Min(Max(fTagSlotIndex, 0),
        ATagRegistry.TagCount - 1)];
    Exit;
  end;

  lIndex := -1;
  lSelected := ATagRegistry.SelectedTag;
  if lSelected <> nil then
    for I := 0 to ATagRegistry.TagCount - 1 do
      if ATagRegistry.Tags[I] = lSelected then
      begin
        lIndex := I;
        Break;
      end;

  if lIndex < 0 then
    lIndex := fTagSlotIndex;
  lIndex := lIndex + fTagOffset;
  if lIndex < 0 then
    lIndex := 0;
  if lIndex >= ATagRegistry.TagCount then
    lIndex := ATagRegistry.TagCount - 1;
  Result := ATagRegistry.Tags[lIndex];
end;

procedure TRecorderOglOscillogram.SetAxisRange(AMinValue, AMaxValue: Double);
var
  lPad: Double;
begin
  if fAxis = nil then
    Exit;

  if SameValue(AMinValue, AMaxValue) then
  begin
    AMinValue := AMinValue - 1.0;
    AMaxValue := AMaxValue + 1.0;
  end
  else
  begin
    lPad := Abs(AMaxValue - AMinValue) * 0.05;
    AMinValue := AMinValue - lPad;
    AMaxValue := AMaxValue + lPad;
  end;
  TChartAxis(fAxis).MinValue := AMinValue;
  TChartAxis(fAxis).MaxValue := AMaxValue;
end;

procedure TRecorderOglOscillogram.SetChartTitle(const ATitle: string);
begin
  if fModel <> nil then
    TChartModel(fModel).Title := ATitle;
end;

procedure TRecorderOglOscillogram.SetXRange(ADisplaySeconds: Double);
begin
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;
  if fPage <> nil then
  begin
    TChartPage(fPage).XMinValue := 0;
    TChartPage(fPage).XMaxValue := ADisplaySeconds;
  end;
end;

procedure TRecorderOglOscillogram.Refresh(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  I: Integer;
  lDisplayStart: Double;
  lEndTime: Double;
  lFirst: Boolean;
  lMinValue: Double;
  lMaxValue: Double;
  lPointCount: Integer;
  lSnapshot: TRecorderSignalSnapshot;
  lTag: TRecorderTag;
  lTrend: cBuffTrend1d;
begin
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;

  Inc(fFrameNo);
  SetXRange(ADisplaySeconds);
  if fTrend = nil then
    Exit;

  lTrend := cBuffTrend1d(fTrend);
  lTrend.ClearValues;
  lTrend.X0 := 0;
  lTrend.DX := 1;

  lTag := ResolveTag(ATagRegistry);
  if lTag = nil then
  begin
    fCurrentTagName := '';
    SetChartTitle(Format('No tag frame:%d', [fFrameNo]));
    SetAxisRange(-1, 1);
    if fChart is TOglChart then
      TOglChart(fChart).Redraw;
    Exit;
  end;

  fCurrentTagName := lTag.Name;

  lSnapshot := lTag.Snapshot;
  SetChartTitle(Format('%s frame:%d', [lTag.Name, fFrameNo]));
  if lSnapshot.Count = 0 then
  begin
    SetAxisRange(-1, 1);
    if fChart is TOglChart then
      TOglChart(fChart).Redraw;
    Exit;
  end;

  lEndTime := lSnapshot.Times[lSnapshot.Count - 1];
  lDisplayStart := Max(lSnapshot.Times[0], lEndTime - ADisplaySeconds);
  lFirst := True;
  lPointCount := 0;
  for I := 0 to lSnapshot.Count - 1 do
  begin
    if lSnapshot.Times[I] < lDisplayStart then
      Continue;

    if lFirst then
    begin
      lMinValue := lSnapshot.Values[I];
      lMaxValue := lSnapshot.Values[I];
      lTrend.X0 := lSnapshot.Times[I] - lDisplayStart;
      if (I < lSnapshot.Count - 1) and
        (lSnapshot.Times[I + 1] > lSnapshot.Times[I]) then
        lTrend.DX := lSnapshot.Times[I + 1] - lSnapshot.Times[I]
      else
        lTrend.DX := ADisplaySeconds;
      lFirst := False;
    end
    else
    begin
      if lSnapshot.Values[I] < lMinValue then
        lMinValue := lSnapshot.Values[I];
      if lSnapshot.Values[I] > lMaxValue then
        lMaxValue := lSnapshot.Values[I];
    end;
    lTrend.AddValue(lSnapshot.Values[I]);
    Inc(lPointCount);
  end;

  if lPointCount = 0 then
    SetAxisRange(-1, 1)
  else
    SetAxisRange(lMinValue, lMaxValue);

  RecorderDebugLog(Format('Ogl osc render: tag=%s points=%d frame=%d window=%.3f',
    [lTag.Name, lPointCount, fFrameNo, ADisplaySeconds]));
  if fChart is TOglChart then
    TOglChart(fChart).Redraw;
end;

procedure RebuildRecorderOglOscillograms(AOwner: TComponent; APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ACount: Integer;
  ADisplaySeconds: Double);
const
  lGapX = 4;
  lGapY = 4;
var
  I: Integer;
  lChart: TRecorderOglOscillogram;
  lCols, lRows: Integer;
  lRow, lCol: Integer;
  lRowStart, lRowCount: Integer;
  lAreaWidth, lAreaHeight: Integer;
  lCellHeight, lRowCellWidth: Integer;
  lLeft, lTop: Integer;
begin
  if APanel = nil then
    Exit;
  if ACount < 1 then
    ACount := 1;

  while APanel.ControlCount > 0 do
    APanel.Controls[0].Free;

  // Оптимальное число столбцов и строк в сетке по аналогии с AlignPagesAuto
  if ACount <= 1 then
    lCols := 1
  else
    lCols := Max(1, Round(Sqrt(ACount)));

  if lCols > ACount then
    lCols := ACount;
  if (ACount mod lCols) > 0 then
    lRows := (ACount div lCols) + 1
  else
    lRows := ACount div lCols;
  if lRows = 0 then
    lRows := 1;

  lAreaWidth := APanel.ClientWidth;
  lAreaHeight := APanel.ClientHeight;
  lCellHeight := (lAreaHeight - (lRows - 1) * lGapY) div lRows;
  if lCellHeight < 80 then
    lCellHeight := 80;

  for I := 0 to ACount - 1 do
  begin
    lChart := TRecorderOglOscillogram.Create(AOwner);
    lChart.Parent := APanel;
    lChart.Align := alNone;

    lRow := I div lCols;
    lCol := I mod lCols;
    lRowStart := lRow * lCols;
    lRowCount := Min(lCols, ACount - lRowStart);

    lRowCellWidth := (lAreaWidth - (lRowCount - 1) * lGapX) div lRowCount;
    lLeft := lCol * (lRowCellWidth + lGapX);
    lTop := lRow * (lCellHeight + lGapY);

    lChart.SetBounds(lLeft, lTop, lRowCellWidth, lCellHeight);

    lChart.TagSlotIndex := 0;
    lChart.TagOffset := I;
    lChart.Refresh(ATagRegistry, ADisplaySeconds);
  end;
end;

procedure RefreshRecorderOglOscillograms(APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
var
  I: Integer;
begin
  if APanel = nil then
    Exit;

  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TRecorderOglOscillogram then
      TRecorderOglOscillogram(APanel.Controls[I]).Refresh(ATagRegistry,
        ADisplaySeconds);
end;

end.
