unit uRecorderOscillogramPageView;

{$mode objfpc}{$H+}

interface

uses
  Classes, Controls, ExtCtrls, TAGraph,
  uRecorderTags;

procedure RebuildRecorderOscillograms(AOwner: TComponent; APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ACount: Integer;
  ADisplaySeconds: Double);
procedure RefreshRecorderOscillograms(APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);

implementation

uses
  SysUtils, Math, Graphics, TASeries, uRecorderDebugLog;

procedure FillOscillogramChart(AChart: TChart; ATag: TRecorderTag;
  ADisplaySeconds: Double);
var
  I: Integer;
  lEndTime: Double;
  lMaxValue: Double;
  lMinValue: Double;
  lPointCount: Integer;
  lFrameNo: Integer;
  lSeries: TLineSeries;
  lSnapshot: TRecorderSignalSnapshot;
  lStartTime: Double;
  lValue: Double;
begin
  if AChart = nil then
    Exit;
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;

  if AChart.SeriesCount = 0 then
  begin
    lSeries := TLineSeries.Create(AChart);
    AChart.AddSeries(lSeries);
  end
  else
    lSeries := TLineSeries(AChart.Series[0]);

  lFrameNo := AChart.Tag + 1;
  AChart.Tag := lFrameNo;
  lSeries.Clear;
  if ATag = nil then
  begin
    AChart.Title.Text.Text := Format('No tag frame:%d', [lFrameNo]);
    AChart.BottomAxis.Range.Min := 0;
    AChart.BottomAxis.Range.Max := ADisplaySeconds;
    AChart.LeftAxis.Range.Min := -1;
    AChart.LeftAxis.Range.Max := 1;
    Exit;
  end;

  lSnapshot := ATag.Snapshot;
  AChart.Title.Text.Text := Format('%s frame:%d', [ATag.Name, lFrameNo]);
  if lSnapshot.Count = 0 then
  begin
    AChart.BottomAxis.Range.Min := 0;
    AChart.BottomAxis.Range.Max := ADisplaySeconds;
    AChart.LeftAxis.Range.Min := -1;
    AChart.LeftAxis.Range.Max := 1;
    Exit;
  end;

  lEndTime := lSnapshot.Times[lSnapshot.Count - 1];
  lStartTime := Max(lSnapshot.Times[0], lEndTime - ADisplaySeconds);
  lMinValue := 0;
  lMaxValue := 0;
  lPointCount := 0;
  for I := 0 to lSnapshot.Count - 1 do
  begin
    if lSnapshot.Times[I] < lStartTime then
      Continue;

    lValue := lSnapshot.Values[I];
    lSeries.AddXY(lSnapshot.Times[I] - lStartTime, lValue);
    if lPointCount = 0 then
    begin
      lMinValue := lValue;
      lMaxValue := lValue;
    end
    else
    begin
      if lValue < lMinValue then
        lMinValue := lValue;
      if lValue > lMaxValue then
        lMaxValue := lValue;
    end;
    Inc(lPointCount);
  end;

  AChart.BottomAxis.Range.Min := 0;
  AChart.BottomAxis.Range.Max := ADisplaySeconds;
  if lPointCount = 0 then
  begin
    AChart.LeftAxis.Range.Min := -1;
    AChart.LeftAxis.Range.Max := 1;
    AChart.Invalidate;
    Exit;
  end;

  if lMinValue = lMaxValue then
  begin
    AChart.LeftAxis.Range.Min := lMinValue - 1.0;
    AChart.LeftAxis.Range.Max := lMaxValue + 1.0;
  end
  else
  begin
    AChart.LeftAxis.Range.Min := lMinValue - Abs(lMaxValue - lMinValue) * 0.05;
    AChart.LeftAxis.Range.Max := lMaxValue + Abs(lMaxValue - lMinValue) * 0.05;
  end;
  RecorderDebugLog(Format('Osc render: tag=%s points=%d first=%.6f last=%.6f xMax=%.3f',
    [ATag.Name, lPointCount, lStartTime, lEndTime, ADisplaySeconds]));
  AChart.Invalidate;
end;

function CreateOscillogramChart(AOwner: TComponent;
  ATagRegistry: TRecorderTagRegistry; AIndex: Integer;
  ADisplaySeconds: Double): TChart;
var
  lSeries: TLineSeries;
  lTag: TRecorderTag;
begin
  Result := TChart.Create(AOwner);
  Result.BorderStyle := bsSingle;
  Result.Title.Visible := True;
  Result.Legend.Visible := False;
  Result.LeftAxis.Grid.Visible := True;
  Result.BottomAxis.Grid.Visible := True;
  Result.BottomAxis.Title.Caption := 't, s';
  Result.LeftAxis.Range.UseMin := True;
  Result.LeftAxis.Range.UseMax := True;
  Result.BottomAxis.Range.UseMin := True;
  Result.BottomAxis.Range.UseMax := True;

  lSeries := TLineSeries.Create(Result);
  lSeries.SeriesColor := clBlue;
  Result.AddSeries(lSeries);

  if (ATagRegistry <> nil) and (ATagRegistry.TagCount > 0) then
    lTag := ATagRegistry.Tags[AIndex mod ATagRegistry.TagCount]
  else
    lTag := nil;
  FillOscillogramChart(Result, lTag, ADisplaySeconds);
end;

procedure RebuildRecorderOscillograms(AOwner: TComponent; APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ACount: Integer;
  ADisplaySeconds: Double);
var
  I: Integer;
  lChart: TChart;
  lRow: Integer;
  lCol: Integer;
  lRows: Integer;
  lCols: Integer;
  lLeft: Integer;
  lTop: Integer;
  lWidth: Integer;
  lHeight: Integer;
  lCellHeight: Integer;
  lItemsInRow: Integer;
  lRowCellWidth: Integer;
begin
  if APanel = nil then
    Exit;
  if ACount < 1 then
    ACount := 1;

  while APanel.ControlCount > 0 do
    APanel.Controls[0].Free;

  lRows := Max(1, Round(Sqrt(ACount)));
  lCols := Ceil(ACount / lRows);
  lCellHeight := Max(1, APanel.ClientHeight div lRows);

  for I := 0 to ACount - 1 do
  begin
    lRow := I div lCols;
    lCol := I mod lCols;
    lItemsInRow := Min(lCols, ACount - lRow * lCols);
    lRowCellWidth := Max(1, APanel.ClientWidth div lItemsInRow);
    lLeft := lCol * lRowCellWidth;
    lTop := lRow * lCellHeight;
    lWidth := lRowCellWidth;
    lHeight := lCellHeight;

    if lCol = lItemsInRow - 1 then
      lWidth := APanel.ClientWidth - lLeft;
    if lRow = lRows - 1 then
      lHeight := APanel.ClientHeight - lTop;

    lChart := CreateOscillogramChart(AOwner, ATagRegistry, I, ADisplaySeconds);
    lChart.Parent := APanel;
    lChart.SetBounds(lLeft, lTop, lWidth, lHeight);
    lChart.Anchors := [akLeft, akTop];
  end;
end;

procedure RefreshRecorderOscillograms(APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
var
  I: Integer;
  lChart: TChart;
  lTag: TRecorderTag;
begin
  if APanel = nil then
    Exit;

  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TChart then
    begin
      lChart := TChart(APanel.Controls[I]);
      if (ATagRegistry <> nil) and (ATagRegistry.TagCount > 0) then
        lTag := ATagRegistry.Tags[I mod ATagRegistry.TagCount]
      else
        lTag := nil;
      FillOscillogramChart(lChart, lTag, ADisplaySeconds);
    end;
end;

end.
