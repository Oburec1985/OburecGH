unit uRecorderSpectrumView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Graphics, Grids, Math, LConvEncoding,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartTrend, uOglChartDrawObj,
  uOglChartCursor, uOglChartRenderer, uOglChartTextLabel,
  uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uRecorderSpectrumEngine, uRecorderSpectrumRuntime, uRecorderCoreServices,
  uComponentServices, SyncObjs;

type
  TBufferedFrame = record
    TagName: string;
    Rms: array of Double;
    PhaseRad: array of Double;
    FrequencyStepHz: Double;
    MaxIndex: Integer;
    MaxFrequencyHz: Double;
    MaxRms: Double;
    Bands: array of TRecorderSpectrumBandResult;
    HasNewData: Boolean;
  end;

  TRecorderSpectrumView = class(TPanel, IVForm)
  private
    fComponent: TRecorderSpectrumComponent;
    fChart: TOglChart;
    fHeaderPanel: TPanel;
    fLegendGrid: TStringGrid;
    fModel: TChartModel;
    fPage: TChartPage;
    fAxisY: TChartAxis;
    fSeriesList: TList;
    fMaxFlags: TList;
    fTagRegistry: TRecorderTagRegistry;
    fToken: Integer;
    fHeaderSignature: string;
    fBufferedFrames: array of TBufferedFrame;
    fLock: TCriticalSection;
    fSplitter: TSplitter;
    fLegendHeightInitialized: Boolean;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure ChartMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
    procedure ChartCursorChanged(Sender: TObject; ACursor: TObject);
    procedure LegendPrepareCanvas(Sender: TObject; ACol, ARow: Integer;
      AState: TGridDrawState);
    procedure ClearSeries;
    procedure ClearHeader;
    procedure ClearBandObjects;
    function GetSpectrumColor(AIndex: Integer): TColor;
    function FindPageCursor: TChartCursor;
    function SeriesValueAtX(ASeries: cBuffTrend1d; AX: Double; out AY: Double): Boolean;
    function SeriesIndexLeftOfX(ASeries: cBuffTrend1d; AX: Double): Integer;
    function CalcFullRms(ASeries: cBuffTrend1d): Double;
    function CalcBandRms(ASeries: cBuffTrend1d; AX1, AX2: Double): Double;
    function FindNearestTagAtPixel(AX, AY: Integer): string;
    function BuildHeaderSignature: string;
    procedure ConfigureLegendGrid;
    procedure UpdateMaxFlag(AIndex: Integer; ASeries: cBuffTrend1d);
    procedure UpdateHeader(AForce: Boolean = False);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
  end;

implementation

constructor TRecorderSpectrumView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ParentBackground := False;
  Color := clWhite;
  fSeriesList := TList.Create;
  fMaxFlags := TList.Create;
  fLock := TCriticalSection.Create;
  fSplitter := nil;
  fLegendHeightInitialized := False;
end;

destructor TRecorderSpectrumView.Destroy;
begin
  if fToken <> 0 then
  begin
    if (fTagRegistry <> nil) and (fTagRegistry.EventBus <> nil) then
      fTagRegistry.EventBus.Unsubscribe(fToken);
    fToken := 0;
  end;
  ClearSeries;
  FreeAndNil(fSeriesList);
  FreeAndNil(fMaxFlags);
  FreeAndNil(fLock);
  inherited Destroy;
end;

procedure TRecorderSpectrumView.ClearSeries;
begin
  if Assigned(fSeriesList) then
    fSeriesList.Clear;
  if Assigned(fMaxFlags) then
    fMaxFlags.Clear;
end;

procedure TRecorderSpectrumView.ClearBandObjects;
var
  I: Integer;
begin
  if fPage = nil then Exit;
  for I := fPage.ChildCount - 1 downto 0 do
    if fPage.Children[I] is TChartFrequencyBand then
      fPage.Children[I].Free;
end;

procedure TRecorderSpectrumView.ClearHeader;
begin
  if fHeaderPanel = nil then
    Exit;
  while fHeaderPanel.ControlCount > 0 do
    fHeaderPanel.Controls[fHeaderPanel.ControlCount - 1].Free;
  fLegendGrid := nil;
end;

procedure TRecorderSpectrumView.LegendPrepareCanvas(Sender: TObject; ACol,
  ARow: Integer; AState: TGridDrawState);
begin
  if not (Sender is TStringGrid) then
    Exit;
  if ARow = 0 then
  begin
    TStringGrid(Sender).Canvas.Font.Color := clBlack;
    TStringGrid(Sender).Canvas.Font.Style := [fsBold];
  end
  else
  begin
    TStringGrid(Sender).Canvas.Font.Color := GetSpectrumColor(ARow - 1);
    TStringGrid(Sender).Canvas.Font.Style := [];
  end;
end;

function TRecorderSpectrumView.GetSpectrumColor(AIndex: Integer): TColor;
const
  CColors: array[0..7] of TColor = (
    $0000FF, $008000, $FF0000, $00A5FF,
    $800080, $808000, $808080, $0080FF
  );
begin
  Result := CColors[AIndex mod 8];
end;

function TRecorderSpectrumView.FindPageCursor: TChartCursor;
var
  I: Integer;
begin
  Result := nil;
  if fPage = nil then
    Exit;
  for I := 0 to fPage.ChildCount - 1 do
    if fPage.Children[I] is TChartCursor then
      Exit(TChartCursor(fPage.Children[I]));
end;

function TRecorderSpectrumView.SeriesValueAtX(ASeries: cBuffTrend1d; AX: Double;
  out AY: Double): Boolean;
var
  lRatio: Double;
  lIdx: Integer;
begin
  Result := False;
  AY := 0.0;
  if (ASeries = nil) or (ASeries.Count = 0) or (ASeries.DX = 0.0) then
    Exit;
  lRatio := (AX - ASeries.X0) / ASeries.DX;
  if (lRatio < 0.0) or (lRatio > ASeries.Count - 1) then
    Exit;
  lIdx := Trunc(lRatio);
  if lIdx >= ASeries.Count - 1 then
    AY := ASeries.Values[ASeries.Count - 1]
  else
    AY := ASeries.Values[lIdx] + (lRatio - lIdx) *
      (ASeries.Values[lIdx + 1] - ASeries.Values[lIdx]);
  Result := True;
end;

function TRecorderSpectrumView.SeriesIndexLeftOfX(ASeries: cBuffTrend1d;
  AX: Double): Integer;
var
  lRatio: Double;
begin
  Result := -1;
  if (ASeries = nil) or (ASeries.Count = 0) or (ASeries.DX = 0.0) then
    Exit;
  lRatio := (AX - ASeries.X0) / ASeries.DX;
  if lRatio < 0.0 then
    Exit;
  Result := Floor(lRatio);
  if Result >= ASeries.Count then
    Result := ASeries.Count - 1;
end;

function TRecorderSpectrumView.CalcFullRms(ASeries: cBuffTrend1d): Double;
var
  I: Integer;
begin
  Result := 0.0;
  if ASeries = nil then
    Exit;
  for I := 0 to ASeries.Count - 1 do
    Result := Result + Sqr(ASeries.Values[I]);
  Result := Sqrt(Result);
end;

function TRecorderSpectrumView.CalcBandRms(ASeries: cBuffTrend1d; AX1,
  AX2: Double): Double;
var
  I: Integer;
  lX, lMinX, lMaxX: Double;
begin
  Result := 0.0;
  if (ASeries = nil) or (ASeries.Count = 0) then
    Exit;
  lMinX := Min(AX1, AX2);
  lMaxX := Max(AX1, AX2);
  for I := 0 to ASeries.Count - 1 do
  begin
    lX := ASeries.X0 + I * ASeries.DX;
    if (lX >= lMinX) and (lX <= lMaxX) then
      Result := Result + Sqr(ASeries.Values[I]);
  end;
  Result := Sqrt(Result);
end;

function TRecorderSpectrumView.BuildHeaderSignature: string;
var
  I: Integer;
  lSeries: cBuffTrend1d;
  lCursor: TChartCursor;
begin
  Result := '';
  if fComponent <> nil then
    Result := Result + Format('legend=%s;', [BoolToStr(fComponent.LegendVisible, True)]);

  lCursor := FindPageCursor;
  if (lCursor <> nil) and lCursor.Visible then
    Result := Result + Format('cursor=1;%d;%.12g;%.12g;',
      [Ord(lCursor.CursorType), lCursor.X1, lCursor.X2])
  else
    Result := Result + 'cursor=0;';

  for I := 0 to fSeriesList.Count - 1 do
  begin
    lSeries := cBuffTrend1d(fSeriesList[I]);
    Result := Result + Format('%s:%d:%.12g:%.12g;',
      [lSeries.Caption, lSeries.Count, CalcFullRms(lSeries), lSeries.DX]);
  end;
end;

procedure TRecorderSpectrumView.ConfigureLegendGrid;
begin
  if fLegendGrid = nil then
  begin
    fLegendGrid := TStringGrid.Create(fHeaderPanel);
    fLegendGrid.Parent := fHeaderPanel;
    fLegendGrid.Align := alClient;
    fLegendGrid.FixedCols := 0;
    fLegendGrid.FixedRows := 1;
    fLegendGrid.DefaultRowHeight := 20;
    fLegendGrid.Options := fLegendGrid.Options + [goFixedVertLine,
      goFixedHorzLine, goVertLine, goHorzLine, goColSizing] -
      [goEditing, goRangeSelect];
    fLegendGrid.OnPrepareCanvas := @LegendPrepareCanvas;
  end;
end;

procedure TRecorderSpectrumView.UpdateMaxFlag(AIndex: Integer;
  ASeries: cBuffTrend1d);
var
  lFlag: TChartFlagLabel;
  lFrame: TBufferedFrame;
begin
  if (fMaxFlags = nil) or (AIndex < 0) or (AIndex >= fMaxFlags.Count) then
    Exit;
  lFlag := TChartFlagLabel(fMaxFlags[AIndex]);
  if (ASeries = nil) or (AIndex >= Length(fBufferedFrames)) or
    (fComponent = nil) or (fComponent.ResultType <> 0) then
  begin
    lFlag.Visible := False;
    Exit;
  end;

  lFrame := fBufferedFrames[AIndex];
  lFlag.Visible := (lFrame.MaxIndex >= 0) and (lFrame.MaxIndex < ASeries.Count) and (lFrame.MaxFrequencyHz >= 10.0);
  if not lFlag.Visible then
    Exit;
  lFlag.Trend := ASeries;
  lFlag.Axis := fAxisY;
  lFlag.AnchorX := lFrame.MaxFrequencyHz;
  lFlag.WorldX := lFrame.MaxFrequencyHz;
  lFlag.WorldY := lFrame.MaxRms;
  lFlag.Text := Format('MAX %d: X=%s'#13#10'Y=%s', [lFrame.MaxIndex,
    FormatFloat('0.######', lFrame.MaxFrequencyHz),
    FormatFloat('0.######', lFrame.MaxRms)]);
end;

procedure TRecorderSpectrumView.UpdateHeader(AForce: Boolean);
var
  I, lRow, lCol, lColCount: Integer;
  lSeries: cBuffTrend1d;
  lCursor: TChartCursor;
  lHasCursor, lHasDouble: Boolean;
  lX1, lX2, lY1, lY2: Double;
  lIdx1, lIdx2: Integer;
  lSignature: string;
begin
  if fHeaderPanel = nil then
    Exit;

  lSignature := BuildHeaderSignature;
  if (not AForce) and (lSignature = fHeaderSignature) then
    Exit;
  fHeaderSignature := lSignature;

  if (fComponent = nil) or (not fComponent.LegendVisible) then
  begin
    fHeaderPanel.Visible := False;
    fHeaderPanel.Height := 0;
    fLegendHeightInitialized := False;
    if fSplitter <> nil then
      fSplitter.Visible := False;
    Exit;
  end;

  ConfigureLegendGrid;
  fHeaderPanel.Visible := True;
  
  if fSplitter = nil then
  begin
    fSplitter := TSplitter.Create(Self);
    fSplitter.Parent := Self;
    fSplitter.Align := alBottom;
    fSplitter.Height := 4;
    fSplitter.Cursor := crVSplit;
  end;
  fSplitter.Visible := True;
  lCursor := FindPageCursor;
  lHasCursor := (lCursor <> nil) and lCursor.Visible;
  lHasDouble := lHasCursor and (lCursor.CursorType = cctDouble);

  lColCount := 5;
  if lHasCursor then
    Inc(lColCount, 3);
  if lHasDouble then
    Inc(lColCount, 4);

  fLegendGrid.ColCount := lColCount;
  fLegendGrid.RowCount := Max(2, fSeriesList.Count + 1);
  lCol := 0;
  fLegendGrid.Cells[lCol, 0] := 'Tag'; Inc(lCol);
  fLegendGrid.Cells[lCol, 0] := 'Full RMS'; Inc(lCol);
  fLegendGrid.Cells[lCol, 0] := 'Max i'; Inc(lCol);
  fLegendGrid.Cells[lCol, 0] := 'Max X'; Inc(lCol);
  fLegendGrid.Cells[lCol, 0] := 'Max Y'; Inc(lCol);
  if lHasCursor then
  begin
    fLegendGrid.Cells[lCol, 0] := 'i1'; Inc(lCol);
    fLegendGrid.Cells[lCol, 0] := 'x1'; Inc(lCol);
    fLegendGrid.Cells[lCol, 0] := 'y1'; Inc(lCol);
  end;
  if lHasDouble then
  begin
    fLegendGrid.Cells[lCol, 0] := 'i2'; Inc(lCol);
    fLegendGrid.Cells[lCol, 0] := 'x2'; Inc(lCol);
    fLegendGrid.Cells[lCol, 0] := 'y2'; Inc(lCol);
    fLegendGrid.Cells[lCol, 0] := 'Band RMS';
  end;

  for I := 0 to fSeriesList.Count - 1 do
  begin
    lRow := I + 1;
    lSeries := cBuffTrend1d(fSeriesList[I]);
    lCol := 0;
    fLegendGrid.Cells[lCol, lRow] := lSeries.Caption; Inc(lCol);
    fLegendGrid.Cells[lCol, lRow] := FormatFloat('0.######', CalcFullRms(lSeries)); Inc(lCol);
    if I < Length(fBufferedFrames) then
    begin
      fLegendGrid.Cells[lCol, lRow] := IntToStr(fBufferedFrames[I].MaxIndex); Inc(lCol);
      fLegendGrid.Cells[lCol, lRow] := FormatFloat('0.######', fBufferedFrames[I].MaxFrequencyHz); Inc(lCol);
      fLegendGrid.Cells[lCol, lRow] := FormatFloat('0.######', fBufferedFrames[I].MaxRms); Inc(lCol);
    end
    else
    begin
      fLegendGrid.Cells[lCol, lRow] := '-'; Inc(lCol);
      fLegendGrid.Cells[lCol, lRow] := '-'; Inc(lCol);
      fLegendGrid.Cells[lCol, lRow] := '-'; Inc(lCol);
    end;

    if lHasCursor then
    begin
      lX1 := lCursor.X1;
      lIdx1 := SeriesIndexLeftOfX(lSeries, lX1);
      fLegendGrid.Cells[lCol, lRow] := IntToStr(lIdx1); Inc(lCol);
      fLegendGrid.Cells[lCol, lRow] := FormatFloat('0.######', lX1); Inc(lCol);
      if SeriesValueAtX(lSeries, lX1, lY1) then
        fLegendGrid.Cells[lCol, lRow] := FormatFloat('0.######', lY1)
      else
        fLegendGrid.Cells[lCol, lRow] := '-';
      Inc(lCol);

      if lHasDouble then
      begin
        lX2 := lCursor.X2;
        lIdx2 := SeriesIndexLeftOfX(lSeries, lX2);
        fLegendGrid.Cells[lCol, lRow] := IntToStr(lIdx2); Inc(lCol);
        fLegendGrid.Cells[lCol, lRow] := FormatFloat('0.######', lX2); Inc(lCol);
        if SeriesValueAtX(lSeries, lX2, lY2) then
          fLegendGrid.Cells[lCol, lRow] := FormatFloat('0.######', lY2)
        else
          fLegendGrid.Cells[lCol, lRow] := '-';
        Inc(lCol);
        fLegendGrid.Cells[lCol, lRow] := FormatFloat('0.######',
          CalcBandRms(lSeries, lX1, lX2));
      end;
    end;
    UpdateMaxFlag(I, lSeries);
  end;

  SGChange(fLegendGrid, 48, 220, 18);
  if not fLegendHeightInitialized then
  begin
    fHeaderPanel.Height := Min(180, Max(44, fLegendGrid.RowCount * fLegendGrid.DefaultRowHeight + 6));
    fLegendHeightInitialized := True;
  end;
end;

procedure TRecorderSpectrumView.Configure(AComponent: TRecorderVisualComponent;
  ATagRegistry: TRecorderTagRegistry);
var
  I, J: Integer;
  lSeries: cBuffTrend1d;
  lFlag: TChartFlagLabel;
  lPageArea: TChartFloatRect;
  lFrame: TRecorderSpectrumFrame;
begin
  fComponent := TRecorderSpectrumComponent(AComponent);
  fTagRegistry := ATagRegistry;

  if fHeaderPanel = nil then
  begin
    fHeaderPanel := TPanel.Create(Self);
    fHeaderPanel.Parent := Self;
    fHeaderPanel.Align := alBottom;
    fHeaderPanel.BevelOuter := bvNone;
    fHeaderPanel.Color := clWhite;
    fHeaderPanel.ParentBackground := False;
    fHeaderPanel.Height := 0;
    fHeaderPanel.Visible := False;
  end;

  if fChart = nil then
  begin
    fChart := TOglChart.Create(Self);
    fChart.Parent := Self;
    fChart.Align := alClient;
    fChart.AutoResizeViewport := True;
    fChart.ShowHint := True;
    fChart.OnMouseMove := @ChartMouseMove;
    fChart.OnAfterRender := @ChartAfterRender;
    fChart.OnCursorChanged := @ChartCursorChanged;

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

  fChart.SelectedObject := nil;
  fChart.HoveredObject := nil;
  fModel.ClearChildren;
  ClearSeries;
  ClearHeader;

  fLock.Enter;
  try
    SetLength(fBufferedFrames, fComponent.TagNames.Count);
    for I := 0 to fComponent.TagNames.Count - 1 do
    begin
      fBufferedFrames[I].TagName := fComponent.TagNames[I];
      SetLength(fBufferedFrames[I].Rms, 0);
      SetLength(fBufferedFrames[I].PhaseRad, 0);
      fBufferedFrames[I].FrequencyStepHz := 0.0;
      fBufferedFrames[I].MaxIndex := -1;
      fBufferedFrames[I].MaxFrequencyHz := 0.0;
      fBufferedFrames[I].MaxRms := 0.0;
      fBufferedFrames[I].HasNewData := False;

      if TRecorderSpectrumRuntimeManager.Instance <> nil then
      begin
        lFrame.SourceTagName := '';
        if TRecorderSpectrumRuntimeManager.Instance.GetLastFrame(fComponent.TagNames[I], lFrame) then
        begin
          fBufferedFrames[I].FrequencyStepHz := lFrame.FrequencyStepHz;
          fBufferedFrames[I].MaxIndex := lFrame.MaxIndex;
          fBufferedFrames[I].MaxFrequencyHz := lFrame.MaxFrequencyHz;
          fBufferedFrames[I].MaxRms := lFrame.MaxRms;
          SetLength(fBufferedFrames[I].Rms, Length(lFrame.Rms));
          if Length(lFrame.Rms) > 0 then
            Move(lFrame.Rms[0], fBufferedFrames[I].Rms[0], Length(lFrame.Rms) * SizeOf(Double));
          SetLength(fBufferedFrames[I].PhaseRad, Length(lFrame.PhaseRad));
          if Length(lFrame.PhaseRad) > 0 then
            Move(lFrame.PhaseRad[0], fBufferedFrames[I].PhaseRad[0], Length(lFrame.PhaseRad) * SizeOf(Double));
          SetLength(fBufferedFrames[I].Bands, Length(lFrame.Bands));
          for J := 0 to Length(lFrame.Bands) - 1 do
            fBufferedFrames[I].Bands[J] := lFrame.Bands[J];
          fBufferedFrames[I].HasNewData := True;
        end;
      end;
    end;
  finally
    fLock.Leave;
  end;

  fPage := TChartPage.Create;
  fPage.Name := 'SpectrumPage';
  fPage.Caption := '';
  fPage.Align := cpaAuto;
  fPage.FillColor := $FFFFFFFF;
  fPage.BorderColor := $FF808080;
  fPage.XMinValue := fComponent.RangeMinX;
  fPage.XMaxValue := fComponent.RangeMaxX;
  fPage.PresetMinXValue := fComponent.RangeMinX;
  fPage.PresetMaxXValue := fComponent.RangeMaxX;
  fPage.HasPresetXRange := True;
  if fComponent.LgX then
    fPage.XScale := casLog10
  else
    fPage.XScale := casLinear;
  fModel.AddChild(fPage);
  fModel.AlignPagesAuto;

  fAxisY := TChartAxis.Create;
  fAxisY.Name := 'Amplitude';
  fAxisY.MinValue := fComponent.RangeMinY;
  fAxisY.MaxValue := fComponent.RangeMaxY;
  fAxisY.PresetMinValue := fComponent.RangeMinY;
  fAxisY.PresetMaxValue := fComponent.RangeMaxY;
  fAxisY.HasPresetRange := True;
  if fComponent.LgY then
    fAxisY.Scale := casLog10
  else
    fAxisY.Scale := casLinear;
  fPage.AddChild(fAxisY);

  for I := 0 to fComponent.TagNames.Count - 1 do
  begin
    lSeries := cBuffTrend1d.Create;
    lSeries.Name := fComponent.TagNames[I];
    lSeries.Caption := fComponent.TagNames[I];
    lSeries.X0 := 0.0;
    lSeries.DX := 1.0;
    lSeries.Color := (GetSpectrumColor(I) and $00FFFFFF) or $FF000000;
    lSeries.Visible := True;
    fAxisY.AddChild(lSeries);
    fSeriesList.Add(lSeries);
    lFlag := TChartFlagLabel.Create;
    lFlag.Name := Format('MaxFlag%d', [I]);
    lFlag.Caption := lFlag.Name;
    lFlag.Visible := False;
    lFlag.Width := 160;
    lFlag.Height := 40;
    lFlag.Trend := lSeries;
    lFlag.Axis := fAxisY;
    fAxisY.AddChild(lFlag);
    fMaxFlags.Add(lFlag);
  end;

  if fToken = 0 then
    if (fTagRegistry <> nil) and (fTagRegistry.EventBus <> nil) then
      fToken := fTagRegistry.EventBus.Subscribe(@HandleEvent);

  RefreshControl(fTagRegistry, 0.0);
  UpdateHeader(True);
  fChart.Redraw;
  Invalidate;
end;

procedure TRecorderSpectrumView.RefreshControl(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double);
var
  I, J, K: Integer;
  lSeries: cBuffTrend1d;
  lNeedsRedraw: Boolean;
  lValues: array of Double;
  lBand: TChartFrequencyBand;
begin
  lNeedsRedraw := False;

  fLock.Enter;
  try
    for I := 0 to Length(fBufferedFrames) - 1 do
    begin
      if fBufferedFrames[I].HasNewData then
      begin
        for J := 0 to fSeriesList.Count - 1 do
        begin
          lSeries := cBuffTrend1d(fSeriesList[J]);
          if SameText(lSeries.Name, fBufferedFrames[I].TagName) then
          begin
            lSeries.X0 := 0.0;
            lSeries.DX := fBufferedFrames[I].FrequencyStepHz;
            lSeries.ClearValues;
            if fComponent.ResultType = 0 then
            begin
              SetLength(lValues, Length(fBufferedFrames[I].Rms));
              if Length(lValues) > 0 then
              begin
                Move(fBufferedFrames[I].Rms[0], lValues[0], Length(lValues) * SizeOf(Double));
                if fComponent.ZeroY0 then
                  lValues[0] := 0.0;
              end;
              lSeries.AddValues(lValues);
            end
            else
              lSeries.AddValues(fBufferedFrames[I].PhaseRad);
            UpdateMaxFlag(J, lSeries);
            lNeedsRedraw := True;
            Break;
          end;
        end;
        
        // Copy bands from active frame
        SetLength(fBufferedFrames[I].Bands, Length(fBufferedFrames[I].Bands)); // Ensure allocated
        fBufferedFrames[I].HasNewData := False;
      end;
    end;

    // Synchronize the bands on the page
    if (fPage <> nil) and (Length(fBufferedFrames) > 0) then
    begin
      ClearBandObjects;
      for K := 0 to Length(fBufferedFrames[0].Bands) - 1 do
      begin
        lBand := TChartFrequencyBand.Create;
        lBand.Name := Format('FreqBand_%d', [K]);
        lBand.Caption := CP1251ToUTF8(Format('%s'#13'RMS: %.4f', [
          fBufferedFrames[0].Bands[K].BandName,
          fBufferedFrames[0].Bands[K].Rms
        ]));
        lBand.X1 := fBufferedFrames[0].Bands[K].F1;
        lBand.X2 := fBufferedFrames[0].Bands[K].F2;
        lBand.PeakX := fBufferedFrames[0].Bands[K].MaxFrequencyHz;
        lBand.PeakY := fBufferedFrames[0].Bands[K].MaxRms;
        lBand.Rms := fBufferedFrames[0].Bands[K].Rms;
        lBand.Visible := True;
        lBand.Color := $1E808080; // Gray transparency
        fPage.AddChild(lBand);
      end;
    end;
  finally
    fLock.Leave;
  end;

  if lNeedsRedraw and (fChart <> nil) then
  begin
    fChart.Invalidate;
    fChart.Redraw;
  end;
  UpdateHeader(True);
end;

function TRecorderSpectrumView.GetChartControl: TOglChart;
begin
  Result := fChart;
end;

function TRecorderSpectrumView.FindNearestTagAtPixel(AX, AY: Integer): string;
var
  lRenderer: TOpenGLChartRenderer;
  lContentRect: TChartPixelRect;
  lWorldX, lY, lPixelY: Double;
  I: Integer;
  lSeries: cBuffTrend1d;
  lDist, lBestDist: Double;
begin
  Result := '';
  if (fChart = nil) or (fPage = nil) or (fAxisY = nil) then
    Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then
    Exit;
  lContentRect := lRenderer.GetPageContentRect(fPage);
  if (AX < lContentRect.Left) or (AX > lContentRect.Right) or
    (AY < lContentRect.Top) or (AY > lContentRect.Bottom) then
    Exit;
  lWorldX := lRenderer.PixelToXValue(fPage, fAxisY, AX,
    lContentRect.Left, lContentRect.Right);
  lBestDist := 7.0;
  for I := 0 to fSeriesList.Count - 1 do
  begin
    lSeries := cBuffTrend1d(fSeriesList[I]);
    if SeriesValueAtX(lSeries, lWorldX, lY) then
    begin
      lPixelY := lRenderer.AxisValueToPixel(fAxisY, lY,
        lContentRect.Bottom, lContentRect.Top);
      lDist := Abs(AY - lPixelY);
      if lDist < lBestDist then
      begin
        lBestDist := lDist;
        Result := lSeries.Caption;
      end;
    end;
  end;
end;

procedure TRecorderSpectrumView.ChartMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  lTagName: string;
begin
  lTagName := FindNearestTagAtPixel(X, Y);
  if lTagName <> '' then
    fChart.Hint := lTagName
  else
    fChart.Hint := '';
  UpdateHeader;
end;

procedure TRecorderSpectrumView.ChartAfterRender(Sender: TObject;
  ARenderTimeMs: Double);
begin
  UpdateHeader;
end;

procedure TRecorderSpectrumView.ChartCursorChanged(Sender: TObject;
  ACursor: TObject);
begin
  UpdateHeader(True);
end;

procedure TRecorderSpectrumView.HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
var
  lEventData: TRecorderSpectrumFrameEventData;
  I, J: Integer;
begin
  if not IsVisible then Exit;
  if (AEvent.Kind <> rceSpectrumFrame) or (not (AEvent.Data is TRecorderSpectrumFrameEventData)) then
    Exit;

  lEventData := TRecorderSpectrumFrameEventData(AEvent.Data);

  fLock.Enter;
  try
    for I := 0 to Length(fBufferedFrames) - 1 do
    begin
      if SameText(fBufferedFrames[I].TagName, AEvent.Name) then
      begin
        fBufferedFrames[I].FrequencyStepHz := lEventData.Frame.FrequencyStepHz;
        fBufferedFrames[I].MaxIndex := lEventData.Frame.MaxIndex;
        fBufferedFrames[I].MaxFrequencyHz := lEventData.Frame.MaxFrequencyHz;
        fBufferedFrames[I].MaxRms := lEventData.Frame.MaxRms;
        SetLength(fBufferedFrames[I].Rms, Length(lEventData.Frame.Rms));
        if Length(lEventData.Frame.Rms) > 0 then
          Move(lEventData.Frame.Rms[0], fBufferedFrames[I].Rms[0],
            Length(lEventData.Frame.Rms) * SizeOf(Double));
        SetLength(fBufferedFrames[I].PhaseRad, Length(lEventData.Frame.PhaseRad));
        if Length(lEventData.Frame.PhaseRad) > 0 then
          Move(lEventData.Frame.PhaseRad[0], fBufferedFrames[I].PhaseRad[0],
            Length(lEventData.Frame.PhaseRad) * SizeOf(Double));
        SetLength(fBufferedFrames[I].Bands, Length(lEventData.Frame.Bands));
        for J := 0 to Length(lEventData.Frame.Bands) - 1 do
          fBufferedFrames[I].Bands[J] := lEventData.Frame.Bands[J];
        fBufferedFrames[I].HasNewData := True;
        Break;
      end;
    end;
  finally
    fLock.Leave;
  end;
end;

end.
