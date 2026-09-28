unit uRecorderLissajousView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Controls, Graphics, Math,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartTrend, uOglChartDrawObj, uOglChartTextLabel,
  uRecorderFormModel, uRecorderTags, uRecorderVisualControl;

type
  TRecorderLissajousRuntimeLine = class
  public
    XTag, YTag: TRecorderTag;
    XTimes, XValues, YTimes, YValues: TRecorderDoubleArray;
    PairX, PairY: TRecorderDoubleArray;
    Points: array of TChartPoint;
    PointCount, XCount, YCount: Integer;
    LastXRevision, LastYRevision: QWord;
    Series, CenterSeries, DiameterSeries, DiameterCenterSeries: cBuffTrend2d;
    DiameterLabel: TChartTextLabel;
    DiameterPoints: array[0..1] of TChartPoint;
    DiameterCenterPoint: array[0..0] of TChartPoint;
    Centers: array[0..3] of TChartPoint;
    CenterCount: Integer;
  end;

  TRecorderLissajousView = class(TCustomControl, IVForm)
  private
    fComponent: TRecorderLissajousComponent;
    fChart: TOglChart;
    fModel: TChartModel;
    fPage: TChartPage;
    fAxis: TChartAxis;
    fLines: TList;
    fTagRegistry: TRecorderTagRegistry;
    procedure ClearRuntimeLines;
    procedure BuildChart(ATagRegistry: TRecorderTagRegistry);
    function RuntimeLine(AIndex: Integer): TRecorderLissajousRuntimeLine;
    function RefreshLine(ALine: TRecorderLissajousRuntimeLine): Boolean;
    procedure UpdateCenter(ALine: TRecorderLissajousRuntimeLine);
    procedure UpdateDiameter(ALine: TRecorderLissajousRuntimeLine;
      ASettings: TRecorderLissajousLine);
    procedure ChartDblClick(Sender: TObject);
    procedure FitToLissajousData;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

uses
  uRecorderLissajousMath;

constructor TRecorderLissajousView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fLines := TList.Create;
  Color := clWhite;
end;

destructor TRecorderLissajousView.Destroy;
begin
  ClearRuntimeLines;
  fLines.Free;
  inherited Destroy;
end;

procedure TRecorderLissajousView.ClearRuntimeLines;
begin
  while fLines.Count > 0 do
  begin
    TObject(fLines[fLines.Count - 1]).Free;
    fLines.Delete(fLines.Count - 1);
  end;
end;

function TRecorderLissajousView.RuntimeLine(
  AIndex: Integer): TRecorderLissajousRuntimeLine;
begin
  Result := TRecorderLissajousRuntimeLine(fLines[AIndex]);
end;

procedure TRecorderLissajousView.BuildChart(ATagRegistry: TRecorderTagRegistry);
var
  I: Integer;
  lArea: TChartFloatRect;
  lSpace: TChartPixelRect;
  lState: TRecorderLissajousRuntimeLine;
  lLine: TRecorderLissajousLine;
begin
  if fChart = nil then
  begin
    fChart := TOglChart.Create(Self);
    fChart.Parent := Self;
    fChart.Align := alClient;
    fChart.OnDblClick := @ChartDblClick;
    fChart.AutoResizeViewport := True;
    fModel := TChartModel.Create;
    fChart.Model := fModel;
  end;
  { The renderer keeps non-owning hover/selection pointers.  Configuration
    rebuilds the model tree, so clear those pointers before freeing its pages
    and axes; otherwise the next redraw (notably on right-button pan) may
    dereference an object from the previous tree. }
  fChart.HoveredObject := nil;
  fChart.SelectedObject := nil;
  ClearRuntimeLines;
  fModel.ClearChildren;
  fModel.BackgroundColor := $FFFFFFFF;
  lArea.Left := 0.002; lArea.Top := 0.004;
  lArea.Right := 0.998; lArea.Bottom := 0.996;
  fModel.PageArea := lArea;

  fPage := TChartPage.Create;
  fPage.Name := 'LissajousPage';
  fPage.Caption := '';
  fPage.Align := cpaAuto;
  fPage.FillColor := $FFFFFFFF;
  fPage.BorderColor := $FF808080;
  lSpace.Left := 56; lSpace.Top := 12; lSpace.Right := 18; lSpace.Bottom := 36;
  fPage.PixelTabSpace := lSpace;
  fPage.XMinValue := fComponent.RangeMinX;
  fPage.XMaxValue := fComponent.RangeMaxX;
  fPage.PresetMinXValue := fComponent.RangeMinX;
  fPage.PresetMaxXValue := fComponent.RangeMaxX;
  fPage.HasPresetXRange := True;
  { Lissajous has its own data fit: the generic chart reset would restore the
    configured preset and could keep the actual figure outside the viewport. }
  fPage.ResetZoomOnDoubleClick := False;
  fPage.ReverseDragZoomOut := True;
  fPage.ReverseDragZoomOutBothAxes := True;
  fModel.AddChild(fPage);

  fAxis := TChartAxis.Create;
  fAxis.Name := 'Y';
  fAxis.MinValue := fComponent.RangeMinY;
  fAxis.MaxValue := fComponent.RangeMaxY;
  fAxis.PresetMinValue := fComponent.RangeMinY;
  fAxis.PresetMaxValue := fComponent.RangeMaxY;
  fAxis.HasPresetRange := True;
  fAxis.Color := $FF404040;
  fPage.AddChild(fAxis);

  for I := 0 to fComponent.LineCount - 1 do
  begin
    lLine := fComponent.Lines[I];
    lState := TRecorderLissajousRuntimeLine.Create;
    lState.XTag := lLine.ResolveXTag(ATagRegistry);
    lState.YTag := lLine.ResolveYTag(ATagRegistry);
    lState.LastXRevision := High(QWord);
    lState.LastYRevision := High(QWord);
    lState.Series := cBuffTrend2d.Create;
    lState.Series.Name := lLine.Name;
    lState.Series.Caption := lLine.Name;
    lState.Series.Color := (lLine.Color and $00FFFFFF) or $FF000000;
    lState.Series.LineWidth := lLine.Width;
    lState.Series.DrawLine := lLine.DrawLine;
    lState.Series.DrawMarkers := lLine.DrawPoints;
    if lState.XTag <> nil then
    begin
      SetLength(lState.XTimes, lState.XTag.SignalBuffer.Capacity);
      SetLength(lState.XValues, lState.XTag.SignalBuffer.Capacity);
    end;
    if lState.YTag <> nil then
    begin
      SetLength(lState.YTimes, lState.YTag.SignalBuffer.Capacity);
      SetLength(lState.YValues, lState.YTag.SignalBuffer.Capacity);
    end;
    SetLength(lState.PairX, Max(Length(lState.XTimes), Length(lState.YTimes)));
    SetLength(lState.PairY, Length(lState.PairX));
    SetLength(lState.Points, Length(lState.PairX));
    lState.Series.ReservePoints(Length(lState.Points));
    fAxis.AddChild(lState.Series);
    lState.CenterSeries := cBuffTrend2d.Create;
    lState.CenterSeries.Name := lLine.Name + '.centers';
    lState.CenterSeries.Caption := '';
    lState.CenterSeries.Color := $FFFF8000;
    lState.CenterSeries.DrawLine := False;
    lState.CenterSeries.DrawMarkers := True;
    lState.CenterSeries.MarkerSize := 4;
    fAxis.AddChild(lState.CenterSeries);
    lState.DiameterSeries := cBuffTrend2d.Create;
    lState.DiameterSeries.Name := lLine.Name + '.diameter';
    lState.DiameterSeries.Caption := '';
    lState.DiameterSeries.Color :=
      (lLine.DiameterColor and $00FFFFFF) or $FF000000;
    lState.DiameterSeries.LineWidth := Max(1, lLine.Width);
    lState.DiameterSeries.Visible := lLine.DrawMainDiameter;
    fAxis.AddChild(lState.DiameterSeries);
    lState.DiameterCenterSeries := cBuffTrend2d.Create;
    lState.DiameterCenterSeries.Name := lLine.Name + '.diameter-center';
    lState.DiameterCenterSeries.Caption := '';
    lState.DiameterCenterSeries.Color := lState.DiameterSeries.Color;
    lState.DiameterCenterSeries.DrawLine := False;
    lState.DiameterCenterSeries.DrawMarkers := True;
    lState.DiameterCenterSeries.MarkerSize := 7;
    lState.DiameterCenterSeries.Visible := lLine.DrawDiameterCenter;
    fAxis.AddChild(lState.DiameterCenterSeries);
    lState.DiameterLabel := TChartTextLabel.Create;
    lState.DiameterLabel.Name := lLine.Name + '.diameter-value';
    lState.DiameterLabel.Axis := fAxis;
    lState.DiameterLabel.IsWorldX := True;
    lState.DiameterLabel.IsWorldY := True;
    lState.DiameterLabel.Width := 110;
    lState.DiameterLabel.Height := 22;
    lState.DiameterLabel.Visible := lLine.ShowDiameterValue;
    fAxis.AddChild(lState.DiameterLabel);
    fLines.Add(lState);
  end;
  fModel.AlignPagesAuto;
  fChart.Redraw;
end;

procedure TRecorderLissajousView.ChartDblClick(Sender: TObject);
begin
  FitToLissajousData;
end;

procedure TRecorderLissajousView.FitToLissajousData;
var
  I, J: Integer;
  lLine: TRecorderLissajousRuntimeLine;
  lMinX, lMaxX, lMinY, lMaxY, lSpan: Double;
  lHasData: Boolean;
begin
  lHasData := False;
  lMinX := MaxDouble; lMaxX := -MaxDouble;
  lMinY := MaxDouble; lMaxY := -MaxDouble;
  for I := 0 to fLines.Count - 1 do
  begin
    lLine := RuntimeLine(I);
    for J := 0 to lLine.PointCount - 1 do
    begin
      lMinX := Min(lMinX, lLine.Points[J].X);
      lMaxX := Max(lMaxX, lLine.Points[J].X);
      lMinY := Min(lMinY, lLine.Points[J].Y);
      lMaxY := Max(lMaxY, lLine.Points[J].Y);
      lHasData := True;
    end;
  end;
  if not lHasData then Exit;
  lSpan := lMaxX - lMinX;
  if lSpan < 1E-12 then lSpan := Max(1.0, Abs(lMaxX) * 0.2);
  fPage.XMinValue := lMinX - lSpan * 0.05;
  fPage.XMaxValue := lMaxX + lSpan * 0.05;
  lSpan := lMaxY - lMinY;
  if lSpan < 1E-12 then lSpan := Max(1.0, Abs(lMaxY) * 0.2);
  fAxis.MinValue := lMinY - lSpan * 0.05;
  fAxis.MaxValue := lMaxY + lSpan * 0.05;
  fChart.Redraw;
end;

procedure TRecorderLissajousView.Configure(
  AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
begin
  fComponent := TRecorderLissajousComponent(AComponent);
  fTagRegistry := ATagRegistry;
  BuildChart(ATagRegistry);
end;

procedure TRecorderLissajousView.UpdateCenter(
  ALine: TRecorderLissajousRuntimeLine);
var
  I: Integer;
  lCenter: TChartPoint;
begin
  if ALine.PointCount = 0 then Exit;
  lCenter.X := 0; lCenter.Y := 0;
  for I := 0 to ALine.PointCount - 1 do
  begin
    lCenter.X := lCenter.X + ALine.Points[I].X;
    lCenter.Y := lCenter.Y + ALine.Points[I].Y;
  end;
  lCenter.X := lCenter.X / ALine.PointCount;
  lCenter.Y := lCenter.Y / ALine.PointCount;
  if ALine.CenterCount < Length(ALine.Centers) then Inc(ALine.CenterCount);
  for I := ALine.CenterCount - 1 downto 1 do
    ALine.Centers[I] := ALine.Centers[I - 1];
  ALine.Centers[0] := lCenter;
  ALine.CenterSeries.ReplacePoints(ALine.Centers, ALine.CenterCount);
end;

procedure TRecorderLissajousView.UpdateDiameter(
  ALine: TRecorderLissajousRuntimeLine; ASettings: TRecorderLissajousLine);
var
  lX1, lY1, lX2, lY2, lCenterX, lCenterY, lDiameter: Double;
begin
  if not CalculateLissajousMainDiameter(ALine.PairX, ALine.PairY,
    ALine.PointCount, lX1, lY1, lX2, lY2, lCenterX, lCenterY,
    lDiameter) then
  begin
    ALine.DiameterSeries.ClearPoints;
    ALine.DiameterCenterSeries.ClearPoints;
    ALine.DiameterLabel.Text := '';
    Exit;
  end;
  ALine.DiameterPoints[0].X := lX1;
  ALine.DiameterPoints[0].Y := lY1;
  ALine.DiameterPoints[1].X := lX2;
  ALine.DiameterPoints[1].Y := lY2;
  ALine.DiameterSeries.ReplacePoints(ALine.DiameterPoints, 2);
  ALine.DiameterSeries.Visible := ASettings.DrawMainDiameter;
  ALine.DiameterCenterPoint[0].X := lCenterX;
  ALine.DiameterCenterPoint[0].Y := lCenterY;
  ALine.DiameterCenterSeries.ReplacePoints(ALine.DiameterCenterPoint, 1);
  ALine.DiameterCenterSeries.Visible := ASettings.DrawDiameterCenter;
  ALine.DiameterLabel.WorldX := lCenterX;
  ALine.DiameterLabel.WorldY := lCenterY;
  ALine.DiameterLabel.Text := 'D = ' + FormatFloat('0.####', lDiameter);
  ALine.DiameterLabel.Visible := ASettings.ShowDiameterValue;
end;

function TRecorderLissajousView.RefreshLine(
  ALine: TRecorderLissajousRuntimeLine): Boolean;
var
  I, lCapacity: Integer;
  lLatest, lFrom: Double;
  lSettings: TRecorderLissajousLine;
begin
  Result := False;
  if (ALine.XTag = nil) and (fTagRegistry <> nil) then
    ALine.XTag := fComponent.Lines[fLines.IndexOf(ALine)].ResolveXTag(fTagRegistry);
  if (ALine.YTag = nil) and (fTagRegistry <> nil) then
    ALine.YTag := fComponent.Lines[fLines.IndexOf(ALine)].ResolveYTag(fTagRegistry);
  if (ALine.XTag = nil) or (ALine.YTag = nil) then Exit;
  if (ALine.LastXRevision = ALine.XTag.SignalBuffer.Revision) and
    (ALine.LastYRevision = ALine.YTag.SignalBuffer.Revision) then Exit;
  lLatest := Min(ALine.XTag.SignalBuffer.LatestTime,
    ALine.YTag.SignalBuffer.LatestTime);
  lFrom := lLatest - Max(0.001, fComponent.DurationSec);
  ALine.XTag.SnapshotRangeInto(lFrom, True, ALine.XTimes, ALine.XValues,
    ALine.XCount);
  ALine.YTag.SnapshotRangeInto(lFrom, True, ALine.YTimes, ALine.YValues,
    ALine.YCount);
  ALine.LastXRevision := ALine.XTag.SignalBuffer.Revision;
  ALine.LastYRevision := ALine.YTag.SignalBuffer.Revision;
  BuildLissajousPairs(ALine.XTimes, ALine.XValues, ALine.YTimes,
    ALine.YValues, ALine.XCount, ALine.YCount, ALine.PairX, ALine.PairY,
    ALine.PointCount);
  lCapacity := Min(ALine.XCount, ALine.YCount);
  if Length(ALine.Points) < lCapacity then SetLength(ALine.Points, lCapacity);
  for I := 0 to ALine.PointCount - 1 do
  begin
    ALine.Points[I].X := ALine.PairX[I];
    ALine.Points[I].Y := ALine.PairY[I];
  end;
  ALine.Series.ReplacePoints(ALine.Points, ALine.PointCount);
  UpdateCenter(ALine);
  lSettings := fComponent.Lines[fLines.IndexOf(ALine)];
  UpdateDiameter(ALine, lSettings);
  Result := True;
end;

procedure TRecorderLissajousView.RefreshControl(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
var
  I: Integer;
  lChanged: Boolean;
begin
  fTagRegistry := ATagRegistry;
  lChanged := False;
  for I := 0 to fLines.Count - 1 do
    if RefreshLine(RuntimeLine(I)) then lChanged := True;
  if lChanged and (fChart <> nil) then fChart.Redraw;
end;

function TRecorderLissajousView.GetChartControl: TOglChart;
begin
  Result := fChart;
end;

end.
