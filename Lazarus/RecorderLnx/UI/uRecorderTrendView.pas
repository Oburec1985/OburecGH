unit uRecorderTrendView;

{
  Модуль: uRecorderTrendView
  Описание: Визуальный компонент реального времени "Тренд" на базе OpenGL (TOglChart).
            Отображает графики изменения параметров во времени с поддержкой осей,
            периодического расчета оценок и легенды.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, Controls, Graphics, Math, SysUtils, ExtCtrls,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartTrend, uOglChartTypes, uOglChartDrawObj,
  uRecorderFormModel, uRecorderTags, uRecorderVisualControl, uSharedAlgorithms, uRecorderDebugLog;

type
  { TRecorderTrendView
    Реализация тренда на базе TOglChart. Реализует IVForm
    для единообразной обработки контроллером редактора/рантайма. }
  TRecorderTrendView = class(TPanel, IVForm)
  private type
    TTrendSeries = record
      LastProcessedTime: Double;
      Times: array of Double;
      Values: array of Double;
      Count: Integer;
      LastValue: Double;
      HasValue: Boolean;
      OglSeries: cBuffTrendQueue;
          LastBlockKind: string;
      LastPortionLength: Integer;
      LastPointsAdded: Integer;
      LastSnapshotCount: Integer;
      LastBlockCount: Integer;
      LastSnapshotTime: Double;
end;
  private
    fComponent: TRecorderTrendComponent;
    fSeries: array of TTrendSeries;
    fTagRegistry: TRecorderTagRegistry;
    fChart: TOglChart;
    fModel: TChartModel;
    fLegendPaintBox: TPaintBox;
    fLastTrendDiagTickMs: QWord;
    fConfiguredAxisCount: Integer;
    function CalcTrendQueueCapacity: Integer;
    procedure AddPoint(ALineIndex: Integer; ATime, AValue: Double);
    procedure AddScalarPoint(ALineIndex: Integer; const ASnapshot: TRecorderSignalSnapshot);
    function EffectivePortionLength(ATag: TRecorderTag;
      ALastBlockCount: Integer): Integer;
    procedure RebuildOglSeries(ALineIndex: Integer);
    function EstimatePortion(const ASnapshot: TRecorderSignalSnapshot;
      AStartIndex, ACount: Integer; AKind: TRecorderTagEstimateKind;
      out ATime, AValue: Double): Boolean;
    procedure EnsureSeries;
    procedure TrimSeriesToDurationWindow;
    procedure PruneSeries(ALineIndex: Integer);
    procedure DrawLegend(ACanvas: TCanvas; const ARect: TRect);
    procedure UpdateLegendLayout;
    procedure LegendPaintBoxPaint(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    { Методы интерфейса IVForm }
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
    
    procedure RefreshTrend;
    property ChartControl: TOglChart read fChart;
  end;

implementation

uses
  uRecorderTagRefs;

type
  TDoubleSearch = specialize TBinarySearch<Double>;

const
  CMaxTrendPortionsPerRefresh = 64;

function TRecorderTrendView.CalcTrendQueueCapacity: Integer;
var
  lDurationSec: Double;
  lPeriodSec: Double;
begin
  if fComponent = nil then
    Exit(128);
  lDurationSec := Max(1.0, fComponent.DurationSec);
  lPeriodSec := Max(0.001, fComponent.UpdatePeriodSec);
  Result := Ceil(lDurationSec / lPeriodSec * 1.25) + 32;
  if Result < 64 then
    Result := 64;
end;

constructor TRecorderTrendView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ParentBackground := False;
  Color := clWhite;
end;

destructor TRecorderTrendView.Destroy;
begin
  inherited Destroy;
end;

procedure TRecorderTrendView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
var
  I, J, K: Integer;
  lPage: TChartPage;
  lAxis: TChartAxis;
  lOglLine: cBuffTrendQueue;
  lCompLine: TRecorderTrendLine;
  lCompAxis: TRecorderTrendAxis;
  lPageArea: TChartFloatRect;
  lTabSpace: TChartPixelRect;
  lPageCount: Integer;
  lAxisCount: Integer;
  lQueueCapacity: Integer;
  lPages: array of TChartPage;
  lOglAxes: array of TChartAxis;
begin
  if (fComponent = AComponent) and (fComponent <> nil) and
    (Length(fSeries) = TRecorderTrendComponent(AComponent).LineCount) and
    (fConfiguredAxisCount = TRecorderTrendComponent(AComponent).AxisCount) then
  begin
    fTagRegistry := ATagRegistry;
    lQueueCapacity := CalcTrendQueueCapacity;
    SetLength(lOglAxes, fComponent.AxisCount);
    for I := 0 to fComponent.AxisCount - 1 do
    begin
      lCompAxis := fComponent.Axes[I];
      lAxis := nil;
      if fModel <> nil then
      begin
        for J := 0 to fModel.ChildCount - 1 do
        begin
          if fModel.Children[J] is TChartPage then
          begin
            lPage := TChartPage(fModel.Children[J]);
            for K := 0 to lPage.ChildCount - 1 do
            begin
              if (lPage.Children[K] is TChartAxis) and (TChartAxis(lPage.Children[K]).Name = lCompAxis.Name) then
              begin
                lAxis := TChartAxis(lPage.Children[K]);
                Break;
              end;
            end;
          end;
          if lAxis <> nil then Break;
        end;
      end;
      if lAxis <> nil then
      begin
        lAxis.MinValue := lCompAxis.RangeMin;
        lAxis.MaxValue := lCompAxis.RangeMax;
        lAxis.PresetMinValue := lCompAxis.RangeMin;
        lAxis.PresetMaxValue := lCompAxis.RangeMax;
        lAxis.HasPresetRange := True;
        lAxis.Color := $FF404040;
        lOglAxes[I] := lAxis;
      end;
    end;

    for I := 0 to fComponent.LineCount - 1 do
    begin
      lCompLine := fComponent.Lines[I];
      if (I < Length(fSeries)) and (fSeries[I].OglSeries <> nil) then
      begin
        fSeries[I].OglSeries.Color := (lCompLine.Color and $00FFFFFF) or $FF000000;
        fSeries[I].OglSeries.Visible := lCompLine.Visible;
        fSeries[I].OglSeries.Allocate(lQueueCapacity);
        J := Max(0, Min(lCompLine.AxisIndex, fComponent.AxisCount - 1));
        if (J < Length(lOglAxes)) and Assigned(lOglAxes[J]) and
          (fSeries[I].OglSeries.Parent <> lOglAxes[J]) then
          lOglAxes[J].AddChild(fSeries[I].OglSeries);
      end;
    end;

    UpdateLegendLayout;
    if fChart <> nil then
      fChart.Redraw;
    Invalidate;
    Exit;
  end;
  // Приводим к конкретному типу модели тренда
  fComponent := TRecorderTrendComponent(AComponent);
  fTagRegistry := ATagRegistry;

  if fChart = nil then
  begin
    fChart := TOglChart.Create(Self);
    fChart.Parent := Self;
    fChart.Align := alClient;
    fChart.AutoResizeViewport := True;
  end;

  if fModel = nil then
  begin
    fModel := TChartModel.Create;
    fModel.BackgroundColor := $FFFFFFFF;
    lPageArea.Left := 0.002;
    lPageArea.Top := 0.004;
    lPageArea.Right := 0.998;
    lPageArea.Bottom := 0.996;
    fModel.PageArea := lPageArea;
    fModel.PageGapX := 0.004;
    fModel.PageGapY := 0.004;
    fChart.Model := fModel;
  end;

  fModel.ClearChildren;
  fConfiguredAxisCount := 0;

  if fComponent = nil then
  begin
    EnsureSeries;
    UpdateLegendLayout;
    Exit;
  end;

  lPageCount := 1;
  lAxisCount := Max(1, fComponent.AxisCount);

  SetLength(lPages, lPageCount);
  for I := 0 to lPageCount - 1 do
  begin
    lPage := TChartPage.Create;
    lPage.Name := Format('Page%d', [I + 1]);
    lPage.Align := cpaAuto;
    lPage.FillColor := $FFFFFFFF;
    lPage.BorderColor := $FF808080;
    
    lTabSpace.Left := 42;
    lTabSpace.Top := 20;
    lTabSpace.Right := 8;
    lTabSpace.Bottom := 22;
    lPage.PixelTabSpace := lTabSpace;
    lPage.XMinValue := 0;
    lPage.XMaxValue := Max(1.0, fComponent.DurationSec);
    lPage.Caption := 'Page ' + IntToStr(I + 1);
    
    fModel.AddChild(lPage);
    lPages[I] := lPage;
  end;

  fModel.AlignPagesAuto;

  SetLength(lOglAxes, fComponent.AxisCount);
  for I := 0 to fComponent.AxisCount - 1 do
  begin
    lCompAxis := fComponent.Axes[I];
    lAxis := TChartAxis.Create;
    lAxis.Name := lCompAxis.Name;
    lAxis.MinValue := lCompAxis.RangeMin;
    lAxis.MaxValue := lCompAxis.RangeMax;
    lAxis.PresetMinValue := lCompAxis.RangeMin;
    lAxis.PresetMaxValue := lCompAxis.RangeMax;
    lAxis.HasPresetRange := True;
    lAxis.Color := $FF404040;
    lOglAxes[I] := lAxis;

    lPages[0].AddChild(lAxis);
  end;

  EnsureSeries;

  for I := 0 to fComponent.LineCount - 1 do
  begin
    lCompLine := fComponent.Lines[I];
    lOglLine := cBuffTrendQueue.Create;
    lOglLine.Allocate(CalcTrendQueueCapacity);
    lOglLine.Name := lCompLine.Name;
    lOglLine.Color := (lCompLine.Color and $00FFFFFF) or $FF000000;
    lOglLine.Visible := lCompLine.Visible;
    fSeries[I].OglSeries := lOglLine;
    fSeries[I].LastValue := 0;
    fSeries[I].HasValue := False;
    fSeries[I].Count := 0;

    J := Max(0, Min(lCompLine.AxisIndex, fComponent.AxisCount - 1));
    if J < Length(lOglAxes) then
      lOglAxes[J].AddChild(lOglLine);
  end;

  fConfiguredAxisCount := fComponent.AxisCount;
  UpdateLegendLayout;
  fChart.Redraw;
  Invalidate;
end;

procedure TRecorderTrendView.EnsureSeries;
var
  I: Integer;
begin
  if fComponent = nil then
    SetLength(fSeries, 0)
  else
  begin
    SetLength(fSeries, fComponent.LineCount);
    for I := 0 to fComponent.LineCount - 1 do
    begin
      fSeries[I].OglSeries := nil;
      fSeries[I].Count := 0;
      fSeries[I].LastValue := 0;
      fSeries[I].HasValue := False;
      fSeries[I].LastBlockKind := '';
      fSeries[I].LastPortionLength := 0;
      fSeries[I].LastPointsAdded := 0;
      fSeries[I].LastSnapshotCount := 0;
      fSeries[I].LastBlockCount := 0;
      fSeries[I].LastSnapshotTime := 0;
    end;
  end;
end;

procedure TRecorderTrendView.AddPoint(ALineIndex: Integer; ATime,
  AValue: Double);
var
  lSeries: ^TTrendSeries;
begin
  if (ALineIndex < 0) or (ALineIndex >= Length(fSeries)) then
    Exit;

  lSeries := @fSeries[ALineIndex];
  if lSeries^.OglSeries = nil then
    Exit;

  lSeries^.OglSeries.AddPoint(ATime, AValue);
  lSeries^.Count := lSeries^.OglSeries.Count;
  lSeries^.LastValue := AValue;
  lSeries^.HasValue := True;
end;
procedure TRecorderTrendView.AddScalarPoint(ALineIndex: Integer;
  const ASnapshot: TRecorderSignalSnapshot);
var
  lPeriodSec: Double;
  lPointTime: Double;
  lValue: Double;
begin
  if (ASnapshot.Count <= 0) or (ALineIndex < 0) or
    (ALineIndex >= Length(fSeries)) or (fComponent = nil) then
    Exit;

  lPointTime := ASnapshot.Times[ASnapshot.Count - 1];
  if (fSeries[ALineIndex].LastProcessedTime > 0) and
    (lPointTime <= fSeries[ALineIndex].LastProcessedTime) then
    Exit;

  lPeriodSec := Max(0.001, fComponent.UpdatePeriodSec);
  if (fSeries[ALineIndex].LastProcessedTime > 0) and
    (lPointTime - fSeries[ALineIndex].LastProcessedTime < lPeriodSec) then
    Exit;

  lValue := ASnapshot.Values[ASnapshot.Count - 1];
  AddPoint(ALineIndex, lPointTime, lValue);
  fSeries[ALineIndex].LastProcessedTime := lPointTime;
end;

function TRecorderTrendView.EffectivePortionLength(ATag: TRecorderTag;
  ALastBlockCount: Integer): Integer;
var
  lTrendPeriodMs: Cardinal;
begin
  Result := 1;
  if ATag = nil then
    Exit;

  lTrendPeriodMs := Round(Max(0.001, fComponent.UpdatePeriodSec) * 1000.0);
  Result := ATag.EstimateSettings.PortionLength;

  if RecorderTagEstimatePortionLengthIsAuto(Result, ATag.PollFrequencyHz,
    lTrendPeriodMs) or ((ALastBlockCount > 1) and (Result = ALastBlockCount)) then
    Result := RecorderTagDefaultEstimatePortionLength(ATag.PollFrequencyHz,
      lTrendPeriodMs);

  if Result < 1 then
    Result := 1;
end;

procedure TRecorderTrendView.RebuildOglSeries(ALineIndex: Integer);
begin
  { cBuffTrendQueue is the storage itself, so there is no secondary OGL series
    to rebuild in the realtime path. }
end;
procedure TRecorderTrendView.PruneSeries(ALineIndex: Integer);
begin
  { Ring buffer capacity is sized for DurationSec/UpdatePeriodSec. }
end;

procedure TRecorderTrendView.TrimSeriesToDurationWindow;
var
  I: Integer;
  lMaxT: Double;
  lMinT: Double;
begin
  if fComponent = nil then
    Exit;

  lMaxT := 0;
  for I := 0 to High(fSeries) do
    if (fSeries[I].OglSeries <> nil) and (fSeries[I].OglSeries.Count > 0) then
      lMaxT := Max(lMaxT, fSeries[I].OglSeries.LastTime);
  if lMaxT <= 0 then
    Exit;

  lMinT := Max(0.0, lMaxT - Max(1.0, fComponent.DurationSec));
  for I := 0 to High(fSeries) do
    if fSeries[I].OglSeries <> nil then
    begin
      fSeries[I].OglSeries.TrimBeforeTime(lMinT);
      fSeries[I].Count := fSeries[I].OglSeries.Count;
    end;
end;
function TRecorderTrendView.EstimatePortion(
  const ASnapshot: TRecorderSignalSnapshot; AStartIndex, ACount: Integer;
  AKind: TRecorderTagEstimateKind; out ATime, AValue: Double): Boolean;
var
  lEstimate: TRecorderTagEstimate;
begin
  Result := False;
  ATime := 0;
  AValue := 0;
  if (ACount <= 0) or (AStartIndex < 0) or
    (AStartIndex + ACount > ASnapshot.Count) then
    Exit;

  lEstimate := CalculateRecorderTagEstimateRange(ASnapshot, AStartIndex,
    ACount, AKind);
  Result := lEstimate.Valid;
  if Result then
  begin
    ATime := (ASnapshot.Times[AStartIndex] +
      ASnapshot.Times[AStartIndex + ACount - 1]) / 2.0;
    AValue := lEstimate.Value;
  end;
end;
procedure TRecorderTrendView.RefreshTrend;
var
  I: Integer;
  lLine: TRecorderTrendLine;
  lLastBlock: TRecorderSignalSnapshot;
  lTag: TRecorderTag;
  lValue: Double;
  lPointTime: Double;
  lMaxT, lMinT: Double;
  lStartIdx: Integer;
  lPortionLength: Integer;
  lNowTick: QWord;
  lDiagLine: Integer;
  lRecorderNow: Double;
  lLagSec: Double;
  lIterations: Integer;
begin
  if (fComponent = nil) or (fTagRegistry = nil) then
    Exit;

  for I := 0 to fComponent.LineCount - 1 do
  begin
    lLine := fComponent.Lines[I];
    if not lLine.Visible then
      Continue;

    lTag := RecorderResolveTag(fTagRegistry, lLine.TagId, lLine.TagName);
    if lTag <> nil then
      RecorderBindTrendLineTag(lLine, lTag);
    if lTag = nil then
      Continue;

    lLastBlock := lTag.LastBlockSnapshot;
    if lLastBlock.Count = 0 then
      Continue;

    fSeries[I].LastPointsAdded := 0;
    fSeries[I].LastSnapshotCount := lTag.SignalBuffer.Count;
    fSeries[I].LastSnapshotTime := lLastBlock.Times[lLastBlock.Count - 1];
    fSeries[I].LastBlockCount := lLastBlock.Count;

    if lLastBlock.Count <= 1 then
    begin
      lValue := fSeries[I].Count;
      AddScalarPoint(I, lLastBlock);
      fSeries[I].LastBlockKind := 'scalar';
      fSeries[I].LastPortionLength := 1;
      fSeries[I].LastPointsAdded := fSeries[I].Count - Trunc(lValue);
      Continue;
    end;

    lPortionLength := EffectivePortionLength(lTag, lLastBlock.Count);
    fSeries[I].LastBlockKind := 'vector';
    fSeries[I].LastPortionLength := lPortionLength;

    if fSeries[I].LastProcessedTime <= 0 then
      lStartIdx := 0
    else
      lStartIdx := TDoubleSearch.FindFirstGreater(lLastBlock.Times,
        lLastBlock.Count, fSeries[I].LastProcessedTime);

    lIterations := 0;
    while (lStartIdx + lPortionLength <= lLastBlock.Count) and
      (lIterations < CMaxTrendPortionsPerRefresh) do
    begin
      if EstimatePortion(lLastBlock, lStartIdx, lPortionLength,
        lLine.EstimateKind, lPointTime, lValue) then
      begin
        AddPoint(I, lPointTime, lValue);
        Inc(fSeries[I].LastPointsAdded);
        fSeries[I].LastProcessedTime :=
          lLastBlock.Times[lStartIdx + lPortionLength - 1];
      end;
      Inc(lStartIdx, lPortionLength);
      Inc(lIterations);
    end;
  end;

  TrimSeriesToDurationWindow;

  lMaxT := 0;
  for I := 0 to fComponent.LineCount - 1 do
    if (I < Length(fSeries)) and (fSeries[I].OglSeries <> nil) and
      (fSeries[I].OglSeries.Count > 0) then
      lMaxT := Max(lMaxT, fSeries[I].OglSeries.LastTime);

  lMinT := Max(0.0, lMaxT - Max(1.0, fComponent.DurationSec));

  lNowTick := GetTickCount64;
  if (fLastTrendDiagTickMs = 0) or (lNowTick - fLastTrendDiagTickMs >= 1000) then
  begin
    fLastTrendDiagTickMs := lNowTick;
    lDiagLine := -1;
    lRecorderNow := 0;
    for I := 0 to fComponent.LineCount - 1 do
      if (I < Length(fSeries)) and (fSeries[I].LastSnapshotTime > lRecorderNow) then
      begin
        lRecorderNow := fSeries[I].LastSnapshotTime;
        lDiagLine := I;
      end;
    lLagSec := lRecorderNow - lMaxT;
    if lDiagLine >= 0 then
      RecorderDebugLog(Format('Trend diag: comp=%s recNow=%.6f trendMax=%.6f lag=%.6f window=[%.6f..%.6f] line=%d tag=%s kind=%s snap=%d block=%d portion=%d added=%d lastProcessed=%.6f visible=%s',
        [fComponent.Name, lRecorderNow, lMaxT, lLagSec, lMinT, Max(lMinT + 1.0, lMaxT),
         lDiagLine, fComponent.Lines[lDiagLine].TagName, fSeries[lDiagLine].LastBlockKind,
         fSeries[lDiagLine].LastSnapshotCount, fSeries[lDiagLine].LastBlockCount,
         fSeries[lDiagLine].LastPortionLength, fSeries[lDiagLine].LastPointsAdded,
         fSeries[lDiagLine].LastProcessedTime, BoolToStr(IsVisible, True)]));
  end;

  if not IsVisible then
    Exit;

  if fModel <> nil then
  begin
    for I := 0 to fModel.ChildCount - 1 do
      if fModel.Children[I] is TChartPage then
      begin
        if not TChartPage(fModel.Children[I]).ZoomedX then
        begin
          TChartPage(fModel.Children[I]).XMinValue := lMinT;
          TChartPage(fModel.Children[I]).XMaxValue := Max(lMinT + 1.0, lMaxT);
        end;
      end;
  end;

  if fChart <> nil then
    fChart.Redraw;

  if (fLegendPaintBox <> nil) and fLegendPaintBox.Visible then
    fLegendPaintBox.Invalidate;

  Invalidate;
end;
procedure TRecorderTrendView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
begin
  RefreshTrend;
end;

function TRecorderTrendView.GetChartControl: TOglChart;
begin
  Result := fChart;
end;

procedure TRecorderTrendView.UpdateLegendLayout;
begin
  if (fComponent <> nil) and fComponent.LegendVisible then
  begin
    if fLegendPaintBox = nil then
    begin
      fLegendPaintBox := TPaintBox.Create(Self);
      fLegendPaintBox.Parent := Self;
      fLegendPaintBox.Align := alRight;
      fLegendPaintBox.Width := 130;
      fLegendPaintBox.OnPaint := @LegendPaintBoxPaint;
    end;
    fLegendPaintBox.Visible := True;
  end
  else
  begin
    if fLegendPaintBox <> nil then
      fLegendPaintBox.Visible := False;
  end;
end;

procedure TRecorderTrendView.LegendPaintBoxPaint(Sender: TObject);
begin
  DrawLegend(fLegendPaintBox.Canvas, fLegendPaintBox.ClientRect);
end;

procedure TRecorderTrendView.DrawLegend(ACanvas: TCanvas; const ARect: TRect);
var
  I: Integer;
  lLine: TRecorderTrendLine;
  lText: string;
  lY: Integer;
begin
  if (fComponent = nil) or (not fComponent.LegendVisible) then
    Exit;

  ACanvas.Brush.Color := Color;
  ACanvas.FillRect(ARect);

  lY := ARect.Top + 4;
  for I := 0 to fComponent.LineCount - 1 do
  begin
    lLine := fComponent.Lines[I];
    ACanvas.Pen.Color := TColor(lLine.Color);
    ACanvas.Pen.Width := 2;
    ACanvas.MoveTo(ARect.Left + 4, lY + 8);
    ACanvas.LineTo(ARect.Left + 24, lY + 8);

    ACanvas.Font.Color := clBlack;
    ACanvas.Font.Name := 'Segoe UI';
    ACanvas.Font.Size := 9;
    // берем именно имя тега в легенду
    lText := lLine.TagName;
    if (I < Length(fSeries)) and fSeries[I].HasValue and
      fComponent.ShowCurrentValues then
      lText := Format('%s %.3f', [lText, fSeries[I].LastValue]);
    ACanvas.TextOut(ARect.Left + 28, lY, lText);
    Inc(lY, 18);
  end;
end;

end.
