unit uRecorderOglOscillogramView;

{
  Unit uRecorderOglOscillogramView
  Purpose:
    LCL wrapper for OpenGL oscillogram controls used on RecorderLnx formulars.
    Chart controls are intentionally long-lived: switching pages or resizing the
    base page must relayout existing controls instead of recreating OpenGL state.
  FPS policy:
    FPS is measured only when the caller explicitly enables it, normally in
    Preview mode. The value is calculated from rendered frames collected during
    an approximately one-second display window, not from a single render time.
}
{$mode objfpc}{$H+}
interface

uses
  Classes, Controls, ExtCtrls, StdCtrls, Graphics,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartTrend, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uOglChartColors, uRecorderTagRefs;
type
  { TRecorderOglOscillogram
    Thin RecorderLnx wrapper around oglChart. It owns a default chart model with
    one page, one axis and one buffered trend. }
  TRecorderOglOscillogram = class(TPanel, IVForm)
  private
    fAbsoluteTagId: TRecorderTagId;
    fAbsoluteTagName: string;
    fBindingMode: TRecorderTagBindingMode;
    fChart: TOglChart;
    fCurrentTagName: string;
    fFpsLastRenderTimeMs: Double;
    fFpsMeasureEnabled: Boolean;
    fFpsMeasured: Double;
    fFpsWindowFirstFrameMs: QWord;
    fFpsWindowFrames: Integer;
    fFpsWindowLastFrameMs: QWord;
    fFrameNo: Integer;
    fInfoPanel: TPanel;
    fInfoNextLeft: Integer;
    fTagOffset: Integer;
    fTagSlotIndex: Integer;
    fExtraLines: TList;
    fModel: TObject;
    fPage: TObject;
    fAxis: TObject;
    fTrend: TObject;
    procedure ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
    procedure EnsureTrendCount;
    procedure FillTrendFromSnapshot(ATrend: cBuffTrend1d;
      const ASnapshot: TRecorderSignalSnapshot; ADisplayStart: Double;
      ADisplaySeconds: Double; out AMinValue, AMaxValue: Double;
      out APointCount: Integer);
    function GetTrendByIndex(AIndex: Integer): cBuffTrend1d;
    function TrendLabelColor(AIndex: Integer): TColor;
    function ResolveTag(ATagRegistry: TRecorderTagRegistry): TRecorderTag;
    function ResolveTagByName(ATagRegistry: TRecorderTagRegistry;
      const ATagName: string): TRecorderTag;
    procedure ResetFpsMeasure;
    procedure SyncLinesFromComponent(AComponent: TRecorderOscillogramComponent);
    procedure SetAxisRange(AMinValue, AMaxValue: Double);
    procedure SetChartTitle(const ATitle: string);
    procedure SetXRange(ADisplaySeconds: Double);
    procedure ClearInfoPanel;
    procedure AppendInfoPart(const AText: string; AColor: TColor);
    procedure UpdateInfoLabel(ATagRegistry: TRecorderTagRegistry; ATag: TRecorderTag);
  public
    { IVForm }
    procedure Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Creates the inner OpenGL chart, model, page, axis and trend. }
    procedure ConfigureDefault;

    { Refreshes chart data from the tag registry.
      ATagRegistry     - source tag registry.
      ADisplaySeconds  - visible time window in seconds.
      AMeasureFps      - True only while RecorderLnx measures display-loop FPS. }
    procedure Refresh(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double; AMeasureFps: Boolean = False);
    { Forces an immediate LCL/OpenGL repaint after a page becomes visible.
      This is used on tab switching: OpenGL controls can keep an invalidated
      back buffer until the next window message, while Recorder users expect the
      formular to be fully drawn immediately after activation. }
    procedure ForceRepaint;

    property AbsoluteTagName: string read fAbsoluteTagName write fAbsoluteTagName;
    property BindingMode: TRecorderTagBindingMode read fBindingMode write fBindingMode;
    property ChartControl: TOglChart read fChart;
    property TagOffset: Integer read fTagOffset write fTagOffset;
    property TagSlotIndex: Integer read fTagSlotIndex write fTagSlotIndex;
  end;

  { TRecorderOglOscillogramSurface
    Host for the built-in Base page. Unlike TRecorderOglOscillogram, this class
    creates only one TOglChart/OpenGL context and places all oscillograms as
    TChartPage children inside one chart model. This avoids Win32 child-window
    repaint artifacts caused by many independent OpenGL controls. }
  TRecorderOglOscillogramSurface = class(TPanel)
  private
    fChart: TOglChart;
    fCount: Integer;
    fDisplaySeconds: Double;
    fFpsLastRenderTimeMs: Double;
    fFpsMeasureEnabled: Boolean;
    fFpsMeasured: Double;
    fFpsWindowFirstFrameMs: QWord;
    fFpsWindowFrames: Integer;
    fFpsWindowLastFrameMs: QWord;
    fFrameNo: Integer;
    fModel: TChartModel;
    function GetFpsText: string;
    procedure ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
    function GetAxis(AIndex: Integer): TChartAxis;
    function GetPage(AIndex: Integer): TChartPage;
    function GetTrend(AIndex: Integer): cBuffTrend1d;
    function ResolveTag(ATagRegistry: TRecorderTagRegistry;
      AIndex: Integer): TRecorderTag;
    procedure ResetFpsMeasure;
    procedure SetAxisRange(AAxis: TChartAxis; AMinValue, AMaxValue: Double);
    procedure UpdatePageCaption(APage: TChartPage; ATag: TRecorderTag);
    private
    fPageCaptionFontSize: Integer;
    function GetPageCaptionFontSize: Integer;
    procedure SetPageCaptionFontSize(AValue: Integer);
  public
    constructor Create(AOwner: TComponent); override;

    { Recreates the internal chart pages only when the count changes. }
    procedure Rebuild(ATagRegistry: TRecorderTagRegistry; ACount: Integer;
      ADisplaySeconds: Double);
    { Refreshes all page trends from tag snapshots. }
    procedure Refresh(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double; AMeasureFps: Boolean = False);
    { Forces a paint of the single OpenGL context. }
    procedure ForceRepaint;

    property ChartControl: TOglChart read fChart;
    property Count: Integer read fCount;
    property FpsText: string read GetFpsText;
      property PageCaptionFontSize: Integer read GetPageCaptionFontSize write SetPageCaptionFontSize;
  end;

{ Ensures that APanel contains ACount oscillograms and lays them out.
  Existing controls are preserved when the count is unchanged. }
procedure RebuildRecorderOglOscillograms(AOwner: TComponent; APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ACount: Integer;
  ADisplaySeconds: Double);
{ Refreshes all existing oscillograms on APanel. }
procedure RefreshRecorderOglOscillograms(APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double;
  AMeasureFps: Boolean = False);
{ Immediately repaints already-created oscillograms on APanel. }
procedure RepaintRecorderOglOscillograms(APanel: TPanel);

{ Returns the current FPS text of the base oscillogram surface. }
function RecorderOglOscillogramsFpsText(APanel: TPanel): string;

implementation

uses
  SysUtils, Math,
  uOglChartDrawObj, uRecorderDebugLog, uOglChartRenderer, uOglChartFontMng, uSharedAlgorithms;

type
  TDoubleSearch = specialize TBinarySearch<Double>;

procedure ApplyOscillogramTagYRange(AAxis: TChartAxis; ATag: TRecorderTag;
  ADataMin, ADataMax: Double);
var
  lMin, lMax, lPad: Double;
begin
  if AAxis = nil then
    Exit;
  if AAxis.HasPresetRange then
    Exit;
  if (ATag <> nil) and (not ATag.AutoRange) and (ATag.RangeMax > ATag.RangeMin) then
  begin
    if (ADataMax >= ATag.RangeMin) and (ADataMin <= ATag.RangeMax) then
    begin
      AAxis.PresetMinValue := ATag.RangeMin;
      AAxis.PresetMaxValue := ATag.RangeMax;
      AAxis.MinValue := ATag.RangeMin;
      AAxis.MaxValue := ATag.RangeMax;
      Exit;
    end;
  end;
  if SameValue(ADataMin, ADataMax) then
  begin
    lMin := ADataMin - 1.0;
    lMax := ADataMax + 1.0;
  end
  else
  begin
    lPad := Abs(ADataMax - ADataMin) * 0.05;
    lMin := ADataMin - lPad;
    lMax := ADataMax + lPad;
  end;
  AAxis.MinValue := lMin;
  AAxis.MaxValue := lMax;
  AAxis.PresetMinValue := lMin;
  AAxis.PresetMaxValue := lMax;
end;

function OscillogramEstimateShortName(AKind: TRecorderTagEstimateKind): string;
begin
  case AKind of
    tekMean: Result := 'M';
    tekRmsValue: Result := 'rms';
    tekRmsDeviation: Result := 'sko';
    tekPeak: Result := 'A';
    tekPeakToPeak: Result := 'p2p';
    tekMinimum: Result := 'min';
    tekMaximum: Result := 'max';
    tekPeakToPeakByRmsDeviation: Result := 'p2p/sko';
    tekLastValue: Result := 'last';
  else
    Result := RecorderTagEstimateKindToShortName(AKind);
  end;
end;

function FormatEnabledEstimateCaption(ATag: TRecorderTag): string;
var
  lEstimate: TRecorderTagEstimate;
  lKind: TRecorderTagEstimateKind;
  lParts: TStringList;
  lSettings: TRecorderTagEstimateSettings;
begin
  Result := '';
  if ATag = nil then
    Exit;
  lSettings := ATag.EstimateSettings;
  lParts := TStringList.Create;
  try
    lParts.Delimiter := ' ';
    lParts.StrictDelimiter := True;
    for lKind := tekMean to tekPeakToPeakByRmsDeviation do
      if lSettings.EnabledKinds[lKind] then
      begin
        lEstimate := ATag.Estimate(lKind);
        if lEstimate.Valid then
          lParts.Add(Format('%s=%s',
            [OscillogramEstimateShortName(lKind),
            FormatFloat('0.###', lEstimate.Value)]))
        else
          lParts.Add(OscillogramEstimateShortName(lKind) + '=-');
      end;

    if lParts.Count = 0 then
    begin
      lEstimate := ATag.Estimate(lSettings.DefaultKind);
      if lEstimate.Valid then
        lParts.Add(Format('%s=%s',
          [OscillogramEstimateShortName(lSettings.DefaultKind),
          FormatFloat('0.###', lEstimate.Value)]))
      else
        lParts.Add(OscillogramEstimateShortName(lSettings.DefaultKind) +
          '=-');
    end;

    Result := lParts.DelimitedText;
  finally
    lParts.Free;
  end;
end;

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
  fExtraLines := TList.Create;
  ConfigureDefault;
end;

destructor TRecorderOglOscillogram.Destroy;
var
  I: Integer;
begin
  for I := fExtraLines.Count - 1 downto 0 do
    TObject(fExtraLines[I]).Free;
  fExtraLines.Free;
  inherited Destroy;
end;

procedure TRecorderOglOscillogram.Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
begin
  if fChart = nil then
    ConfigureDefault;
  fBindingMode := TRecorderOscillogramComponent(AComponent).BindingMode;
  fTagOffset := TRecorderOscillogramComponent(AComponent).TagOffset;
  fAbsoluteTagId := AComponent.TagId;
  fAbsoluteTagName := AComponent.TagName;
  SyncLinesFromComponent(TRecorderOscillogramComponent(AComponent));
  EnsureTrendCount;
  Refresh(ATagRegistry, 1.0);
end;

procedure TRecorderOglOscillogram.RefreshControl(ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
begin
  Refresh(ATagRegistry, ADisplaySeconds);
end;

function TRecorderOglOscillogram.GetChartControl: TOglChart;
begin
  Result := fChart;
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
  fInfoPanel := TPanel.Create(Self);
  fInfoPanel.Parent := Self;
  fInfoPanel.Align := alTop;
  fInfoPanel.Height := 22;
  fInfoPanel.BevelOuter := bvNone;
  fInfoPanel.ParentBackground := True;
  fInfoPanel.BorderSpacing.Around := 4;
  fInfoNextLeft := 0;
  ClearInfoPanel;
  AppendInfoPart('-', clGray);
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
  lPage.AutoScaleOnZoomReset := False;
  lAxis := TChartAxis.Create;
  lAxis.Name := 'Axis1';
  lAxis.Caption := '';
  lAxis.MinValue := -1;
  lAxis.MaxValue := 1;
  lAxis.Color := $FF404040;
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
  ResetFpsMeasure;
end;

procedure TRecorderOglOscillogram.ChartAfterRender(Sender: TObject;
  ARenderTimeMs: Double);
var
  lNowMs: QWord;
begin
  fFpsLastRenderTimeMs := ARenderTimeMs;
  if fFpsMeasureEnabled then
  begin
    lNowMs := GetTickCount64;
    if fFpsWindowFrames = 0 then
    begin
      fFpsWindowFirstFrameMs := lNowMs;
      fFpsWindowLastFrameMs := lNowMs;
      fFpsWindowFrames := 1;
    end
    else
    begin
      Inc(fFpsWindowFrames);
      fFpsWindowLastFrameMs := lNowMs;
    end;

    if (fFpsWindowLastFrameMs - fFpsWindowFirstFrameMs) >= 1000 then
    begin
      fFpsMeasured := fFpsWindowFrames * 1000.0 /
        Max(1.0, fFpsWindowLastFrameMs - fFpsWindowFirstFrameMs);
      fFpsWindowFirstFrameMs := lNowMs;
      fFpsWindowLastFrameMs := lNowMs;
      fFpsWindowFrames := 0;
    end;

  end
  else
    ResetFpsMeasure;
end;

procedure TRecorderOglOscillogram.ClearInfoPanel;
var
  I: Integer;
begin
  if fInfoPanel = nil then
    Exit;
  for I := fInfoPanel.ControlCount - 1 downto 0 do
    fInfoPanel.Controls[I].Free;
  fInfoNextLeft := 0;
end;

procedure TRecorderOglOscillogram.AppendInfoPart(const AText: string; AColor: TColor);
var
  lLabel: TLabel;
begin
  if (fInfoPanel = nil) or (AText = '') then
    Exit;
  lLabel := TLabel.Create(fInfoPanel);
  lLabel.Parent := fInfoPanel;
  lLabel.Caption := AText;
  lLabel.ParentFont := False;
  lLabel.Font.Name := 'Segoe UI';
  lLabel.Font.Size := 9;
  lLabel.Font.Style := [fsBold];
  lLabel.Font.Color := AColor;
  lLabel.AutoSize := True;
  lLabel.Left := fInfoNextLeft;
  lLabel.Top := 2;
  Inc(fInfoNextLeft, lLabel.Width);
end;

procedure TRecorderOglOscillogram.UpdateInfoLabel(ATagRegistry: TRecorderTagRegistry;
  ATag: TRecorderTag);
var
  I, lIdx: Integer;
  lEstimateText: string;
  lLine: TRecorderTrendLine;
  lLineTag: TRecorderTag;
  lShownTags: TStringList;
  lTagColors: array of TColor;
  lColor: TColor;
  lTagName: string;
begin
  ClearInfoPanel;
  if ATag = nil then
  begin
    AppendInfoPart('-', clGray);
    Exit;
  end;

  lShownTags := TStringList.Create;
  try
    lShownTags.CaseSensitive := False;

    for I := 0 to fExtraLines.Count do
    begin
      if I = 0 then
        lTagName := ATag.Name
      else
      begin
        lLine := TRecorderTrendLine(fExtraLines[I - 1]);
        if not lLine.Visible then
          Continue;
        lLineTag := RecorderResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);
        if lLineTag <> nil then
          lTagName := lLineTag.Name
        else
          lTagName := Trim(lLine.TagName);
      end;
      if lTagName = '' then
        Continue;

      lColor := TrendLabelColor(I);
      lIdx := lShownTags.IndexOf(lTagName);
      if lIdx < 0 then
      begin
        lShownTags.Add(lTagName);
        SetLength(lTagColors, lShownTags.Count);
        lTagColors[lShownTags.Count - 1] := lColor;
      end
      else
        lTagColors[lIdx] := lColor;
    end;

    for I := 0 to lShownTags.Count - 1 do
    begin
      if I > 0 then
        AppendInfoPart('; ', clGray);
      lTagName := lShownTags[I];
      lLineTag := ATagRegistry.FindByName(lTagName);
      lEstimateText := FormatEnabledEstimateCaption(lLineTag);
      if lEstimateText <> '' then
        AppendInfoPart(Format('%s | %s', [lTagName, lEstimateText]), lTagColors[I])
      else
        AppendInfoPart(lTagName, lTagColors[I]);
    end;
  finally
    lShownTags.Free;
  end;
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
    Result := RecorderResolveTag(ATagRegistry, fAbsoluteTagId, fAbsoluteTagName);
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

procedure TRecorderOglOscillogram.ResetFpsMeasure;
begin
  fFpsMeasured := 0;
  fFpsWindowFrames := 0;
  fFpsWindowFirstFrameMs := 0;
  fFpsWindowLastFrameMs := 0;
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

procedure TRecorderOglOscillogram.SyncLinesFromComponent(
  AComponent: TRecorderOscillogramComponent);
var
  I: Integer;
  lCopy: TRecorderTrendLine;
begin
  for I := fExtraLines.Count - 1 downto 0 do
  begin
    TObject(fExtraLines[I]).Free;
    fExtraLines.Delete(I);
  end;
  if AComponent = nil then
    Exit;
  for I := 0 to AComponent.LineCount - 1 do
  begin
    lCopy := TRecorderTrendLine.Create;
    lCopy.Assign(AComponent.Lines[I]);
    fExtraLines.Add(lCopy);
  end;
end;

procedure TRecorderOglOscillogram.EnsureTrendCount;
var
  I: Integer;
  lAxis: TChartAxis;
  lLine: TRecorderTrendLine;
  lNeed: Integer;
  lTrend: cBuffTrend1d;
begin
  if fAxis = nil then
    Exit;
  lAxis := TChartAxis(fAxis);
  lNeed := 1 + fExtraLines.Count;
  while lAxis.ChildCount < lNeed do
  begin
    lTrend := cBuffTrend1d.Create;
    lTrend.Name := OglChartLinePaletteName(lAxis.ChildCount);
    lTrend.Caption := lTrend.Name;
    lTrend.Color := OglChartLinePaletteGLColor(lAxis.ChildCount);
    lTrend.X0 := 0;
    lTrend.DX := 1;
    lAxis.AddChild(lTrend);
  end;
  while lAxis.ChildCount > lNeed do
    lAxis.Children[lAxis.ChildCount - 1].Free;
  lTrend := GetTrendByIndex(0);
  if lTrend <> nil then
  begin
    lTrend.Name := OglChartLinePaletteName(0);
    lTrend.Caption := lTrend.Name;
    lTrend.Color := OglChartLinePaletteGLColor(0);
    lTrend.Visible := True;
  end;
  for I := 0 to fExtraLines.Count - 1 do
  begin
    lLine := TRecorderTrendLine(fExtraLines[I]);
    lTrend := GetTrendByIndex(I + 1);
    if lTrend = nil then
      Continue;
    if Trim(lLine.Name) <> '' then
      lTrend.Name := lLine.Name
    else
      lTrend.Name := OglChartLinePaletteName(I + 1);
    lTrend.Caption := lTrend.Name;
    lTrend.Color := OglChartColorToGL(TColor(lLine.Color));
    lTrend.Visible := lLine.Visible;
  end;
  fTrend := GetTrendByIndex(0);
end;

function TRecorderOglOscillogram.GetTrendByIndex(AIndex: Integer): cBuffTrend1d;
var
  lAxis: TChartAxis;
begin
  Result := nil;
  if fAxis = nil then
    Exit;
  lAxis := TChartAxis(fAxis);
  if (AIndex >= 0) and (AIndex < lAxis.ChildCount) and
    (lAxis.Children[AIndex] is cBuffTrend1d) then
    Result := cBuffTrend1d(lAxis.Children[AIndex]);
end;

function TRecorderOglOscillogram.TrendLabelColor(AIndex: Integer): TColor;
var
  lTrend: cBuffTrend1d;
begin
  lTrend := GetTrendByIndex(AIndex);
  if lTrend = nil then
    Exit(clGray);
  Result := TColor(lTrend.Color and $00FFFFFF);
end;

procedure TRecorderOglOscillogram.FillTrendFromSnapshot(ATrend: cBuffTrend1d;
  const ASnapshot: TRecorderSignalSnapshot; ADisplayStart: Double;
  ADisplaySeconds: Double; out AMinValue, AMaxValue: Double;
  out APointCount: Integer);
var
  I: Integer;
  lFirst: Boolean;
  lStartIdx: Integer;
begin
  APointCount := 0;
  AMinValue := 0;
  AMaxValue := 0;
  if ATrend = nil then
    Exit;
  ATrend.ClearValues;
  ATrend.X0 := 0;
  ATrend.DX := 1;
  if ASnapshot.Count = 0 then
    Exit;
  lStartIdx := TDoubleSearch.FindFirstGreaterOrEqual(ASnapshot.Times,
    ASnapshot.Count, ADisplayStart);
  lFirst := True;
  for I := lStartIdx to ASnapshot.Count - 1 do
  begin
    if lFirst then
    begin
      AMinValue := ASnapshot.Values[I];
      AMaxValue := ASnapshot.Values[I];
      ATrend.X0 := ASnapshot.Times[I] - ADisplayStart;
      if (I < ASnapshot.Count - 1) and
        (ASnapshot.Times[I + 1] > ASnapshot.Times[I]) then
        ATrend.DX := ASnapshot.Times[I + 1] - ASnapshot.Times[I]
      else
        ATrend.DX := ADisplaySeconds;
      lFirst := False;
    end
    else
    begin
      if ASnapshot.Values[I] < AMinValue then
        AMinValue := ASnapshot.Values[I];
      if ASnapshot.Values[I] > AMaxValue then
        AMaxValue := ASnapshot.Values[I];
    end;
    ATrend.AddValue(ASnapshot.Values[I]);
    Inc(APointCount);
  end;
end;

function TRecorderOglOscillogram.ResolveTagByName(
  ATagRegistry: TRecorderTagRegistry; const ATagName: string): TRecorderTag;
begin
  Result := RecorderResolveTag(ATagRegistry, 0, ATagName);
end;

procedure TRecorderOglOscillogram.Refresh(ATagRegistry: TRecorderTagRegistry;
  ADisplaySeconds: Double; AMeasureFps: Boolean);
var
  I: Integer;
  lDisplayStart: Double;
  lEndTime: Double;
  lHasRange: Boolean;
  lLine: TRecorderTrendLine;
  lLineMin: Double;
  lLineMax: Double;
  lLinePoints: Integer;
  lMaxValue: Double;
  lMinValue: Double;
  lPointCount: Integer;
  lSnapshot: TRecorderSignalSnapshot;
  lTag: TRecorderTag;
  lTrend: cBuffTrend1d;
begin
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;
  if fFpsMeasureEnabled <> AMeasureFps then
    ResetFpsMeasure;
  fFpsMeasureEnabled := AMeasureFps;
  Inc(fFrameNo);
  if not TChartPage(fPage).ZoomedX then
  begin
    SetXRange(ADisplaySeconds);
    TChartPage(fPage).PresetMinXValue := 0;
    TChartPage(fPage).PresetMaxXValue := ADisplaySeconds;
  end;
  EnsureTrendCount;
  if fTrend = nil then
    Exit;
  lTag := ResolveTag(ATagRegistry);
  if lTag = nil then
  begin
    fCurrentTagName := '';
    UpdateInfoLabel(ATagRegistry, nil);
    SetChartTitle(Format('No tag frame:%d', [fFrameNo]));
    SetAxisRange(-1, 1);
    if fChart is TOglChart then
      TOglChart(fChart).Redraw;
    Exit;
  end;

  fCurrentTagName := lTag.Name;
  UpdateInfoLabel(ATagRegistry, lTag);
  lSnapshot := lTag.Snapshot;
  SetChartTitle(Format('%s frame:%d', [lTag.Name, fFrameNo]));
  if lSnapshot.Count = 0 then
  begin
    for I := 0 to fExtraLines.Count do
    begin
      lTrend := GetTrendByIndex(I);
      if lTrend <> nil then
        lTrend.ClearValues;
    end;
    SetAxisRange(-1, 1);
    if fChart is TOglChart then
      TOglChart(fChart).Redraw;
    Exit;
  end;

  lEndTime := lSnapshot.Times[lSnapshot.Count - 1];
  lDisplayStart := Max(lSnapshot.Times[0], lEndTime - ADisplaySeconds);
  lHasRange := False;
  lPointCount := 0;
  lTrend := GetTrendByIndex(0);
  FillTrendFromSnapshot(lTrend, lSnapshot, lDisplayStart, ADisplaySeconds,
    lMinValue, lMaxValue, lPointCount);
  if lPointCount > 0 then
    lHasRange := True;
  for I := 0 to fExtraLines.Count - 1 do
  begin
    lLine := TRecorderTrendLine(fExtraLines[I]);
    lTrend := GetTrendByIndex(I + 1);
    if lTrend = nil then
      Continue;
    if not lLine.Visible then
    begin
      lTrend.ClearValues;
      Continue;
    end;
    lTag := RecorderResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);
    if lTag = nil then
    begin
      lTrend.ClearValues;
      Continue;
    end;
    lSnapshot := lTag.Snapshot;
    FillTrendFromSnapshot(lTrend, lSnapshot, lDisplayStart, ADisplaySeconds,
      lLineMin, lLineMax, lLinePoints);
    if lLinePoints = 0 then
      Continue;
    if not lHasRange then
    begin
      lMinValue := lLineMin;
      lMaxValue := lLineMax;
      lHasRange := True;
    end
    else
    begin
      if lLineMin < lMinValue then
        lMinValue := lLineMin;
      if lLineMax > lMaxValue then
        lMaxValue := lLineMax;
    end;
    Inc(lPointCount, lLinePoints);
  end;

  if not lHasRange then
    SetAxisRange(-1, 1)
  else
    ApplyOscillogramTagYRange(TChartAxis(fAxis), lTag, lMinValue, lMaxValue);
  RecorderDebugLog(Format('Ogl osc render: tag=%s points=%d lines=%d frame=%d window=%.3f',
    [fCurrentTagName, lPointCount, 1 + fExtraLines.Count, fFrameNo, ADisplaySeconds]));
  if fChart is TOglChart then
    TOglChart(fChart).Redraw;
end;

procedure TRecorderOglOscillogram.ForceRepaint;
begin
  Invalidate;
  if fInfoPanel <> nil then
    fInfoPanel.Invalidate;
  if fChart <> nil then
  begin
    fChart.Invalidate;
    fChart.Repaint;
  end;
end;

{ TRecorderOglOscillogramSurface }
constructor TRecorderOglOscillogramSurface.Create(AOwner: TComponent);
var
  lPageArea: TChartFloatRect;
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ParentBackground := False;
  Color := clWhite;
  fChart := TOglChart.Create(Self);
  fChart.Parent := Self;
  fChart.Align := alClient;
  fChart.AutoResizeViewport := True;
  fChart.OnAfterRender := @ChartAfterRender;
  fModel := fChart.Model;
  fModel.BackgroundColor := $FFFFFFFF;
  lPageArea.Left := 0.002;
  lPageArea.Top := 0.010;
  lPageArea.Right := 0.998;
  lPageArea.Bottom := 0.990;
  fModel.PageArea := lPageArea;
  fModel.PageGapX := 0.004;
  fModel.PageGapY := 0.006;
  SetPageCaptionFontSize(10);
end;

function TRecorderOglOscillogramSurface.GetPageCaptionFontSize: Integer;
begin
  Result := fPageCaptionFontSize;
end;

procedure TRecorderOglOscillogramSurface.SetPageCaptionFontSize(AValue: Integer);
var
  lRenderer: TOpenGLChartRenderer;
begin
  if AValue < 5 then AValue := 5;
  if AValue > 48 then AValue := 48;
  fPageCaptionFontSize := AValue;
  if fChart <> nil then
  begin
    lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
    if Assigned(lRenderer) and Assigned(lRenderer.FontManager) then
    begin
      lRenderer.FontManager.Font(cfPageCaption).Scale := AValue / 7.2;
      fChart.Redraw;
    end;
  end;
end;

procedure TRecorderOglOscillogramSurface.ChartAfterRender(Sender: TObject;
  ARenderTimeMs: Double);
var
  lNowMs: QWord;
begin
  fFpsLastRenderTimeMs := ARenderTimeMs;
  if not fFpsMeasureEnabled then
    Exit;
  lNowMs := GetTickCount64;
  if fFpsWindowFirstFrameMs = 0 then
  begin
    fFpsWindowFirstFrameMs := lNowMs;
    fFpsWindowLastFrameMs := lNowMs;
    fFpsWindowFrames := 1;
    Exit;
  end;

  Inc(fFpsWindowFrames);
  fFpsWindowLastFrameMs := lNowMs;
  if (fFpsWindowLastFrameMs - fFpsWindowFirstFrameMs) >= 1000 then
  begin
    if fFpsWindowLastFrameMs > fFpsWindowFirstFrameMs then
      fFpsMeasured := fFpsWindowFrames * 1000.0 /
        (fFpsWindowLastFrameMs - fFpsWindowFirstFrameMs)
    else
      fFpsMeasured := 0;
    fFpsWindowFirstFrameMs := lNowMs;
    fFpsWindowLastFrameMs := lNowMs;
    fFpsWindowFrames := 0;
  end;
end;

function TRecorderOglOscillogramSurface.GetFpsText: string;
begin
  if fFpsMeasureEnabled and (fFpsMeasured > 0) then
    Result := Format('FPS %.1f', [fFpsMeasured])
  else
    Result := 'FPS -';
end;

function TRecorderOglOscillogramSurface.GetPage(AIndex: Integer): TChartPage;
begin
  Result := nil;
  if (fModel <> nil) and (AIndex >= 0) and (AIndex < fModel.ChildCount) and
    (fModel.Children[AIndex] is TChartPage) then
    Result := TChartPage(fModel.Children[AIndex]);
end;

function TRecorderOglOscillogramSurface.GetAxis(AIndex: Integer): TChartAxis;
var
  lPage: TChartPage;
begin
  Result := nil;
  lPage := GetPage(AIndex);
  if (lPage <> nil) and (lPage.ChildCount > 0) and
    (lPage.Children[0] is TChartAxis) then
    Result := TChartAxis(lPage.Children[0]);
end;

function TRecorderOglOscillogramSurface.GetTrend(AIndex: Integer): cBuffTrend1d;
var
  lAxis: TChartAxis;
begin
  Result := nil;
  lAxis := GetAxis(AIndex);
  if (lAxis <> nil) and (lAxis.ChildCount > 0) and
    (lAxis.Children[0] is cBuffTrend1d) then
    Result := cBuffTrend1d(lAxis.Children[0]);
end;

function TRecorderOglOscillogramSurface.ResolveTag(
  ATagRegistry: TRecorderTagRegistry; AIndex: Integer): TRecorderTag;
begin
  Result := nil;
  if (ATagRegistry <> nil) and (ATagRegistry.TagCount > 0) then
    Result := ATagRegistry.Tags[AIndex mod ATagRegistry.TagCount];
end;

procedure TRecorderOglOscillogramSurface.ResetFpsMeasure;
begin
  fFpsMeasured := 0;
  fFpsWindowFirstFrameMs := 0;
  fFpsWindowLastFrameMs := 0;
  fFpsWindowFrames := 0;
end;

procedure TRecorderOglOscillogramSurface.SetAxisRange(AAxis: TChartAxis;
  AMinValue, AMaxValue: Double);
var
  lPad: Double;
begin
  if AAxis = nil then
    Exit;
  if AMinValue = AMaxValue then
  begin
    AAxis.MinValue := AMinValue - 1.0;
    AAxis.MaxValue := AMaxValue + 1.0;
  end
  else
  begin
    lPad := Abs(AMaxValue - AMinValue) * 0.05;
    AAxis.MinValue := AMinValue - lPad;
    AAxis.MaxValue := AMaxValue + lPad;
  end;
end;

procedure TRecorderOglOscillogramSurface.UpdatePageCaption(APage: TChartPage;
  ATag: TRecorderTag);
var
  lEstimateText: string;
  lTagName: string;
begin
  if APage = nil then
    Exit;
  if ATag <> nil then
    lTagName := ATag.Name
  else
    lTagName := 'None';
  lEstimateText := FormatEnabledEstimateCaption(ATag);
  if lEstimateText <> '' then
    APage.Caption := Format('%s | %s', [lTagName, lEstimateText])
  else
    APage.Caption := lTagName;
end;

procedure TRecorderOglOscillogramSurface.Rebuild(
  ATagRegistry: TRecorderTagRegistry; ACount: Integer; ADisplaySeconds: Double);
var
  I: Integer;
  lAxis: TChartAxis;
  lPage: TChartPage;
  lTabSpace: TChartPixelRect;
  lTrend: cBuffTrend1d;
begin
  if ACount < 1 then
    ACount := 1;
  if ACount > 16 then
    ACount := 16;
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;
  fDisplaySeconds := ADisplaySeconds;
  if (fCount = ACount) and (fModel <> nil) and
    (fModel.ChildCount = ACount) then
  begin
    fModel.AlignPagesAuto;
    Exit;
  end;

  fCount := ACount;
  fModel.ClearChildren;
  for I := 0 to ACount - 1 do
  begin
    lPage := TChartPage.Create;
    lPage.Name := Format('OscPage%d', [I + 1]);
    lPage.Caption := 'Tag: None | FPS: -';
    lPage.Align := cpaAuto;
    lPage.AutoScaleOnZoomReset := False;
    lPage.FillColor := $FFFFFFFF;
    lPage.BorderColor := $FF808080;
    lTabSpace.Left := 42;
    lTabSpace.Top := 30;
    lTabSpace.Right := 10;
    lTabSpace.Bottom := 24;
    lPage.PixelTabSpace := lTabSpace;
    lPage.XMinValue := 0;
    lPage.XMaxValue := ADisplaySeconds;
    fModel.AddChild(lPage);
    lAxis := TChartAxis.Create;
    lAxis.Name := Format('Axis%d', [I + 1]);
    lAxis.Caption := 'Y';
    lAxis.MinValue := -1;
    lAxis.MaxValue := 1;
    lAxis.Color := $FF404040;
    lPage.AddChild(lAxis);
    lTrend := cBuffTrend1d.Create;
    lTrend.Name := Format('Trend%d', [I + 1]);
    lTrend.Caption := 'Signal';
    lTrend.Color := $FFFF0000;
    lTrend.X0 := 0;
    lTrend.DX := ADisplaySeconds;
    lAxis.AddChild(lTrend);
  end;

  fModel.AlignPagesAuto;
  Refresh(ATagRegistry, ADisplaySeconds, fFpsMeasureEnabled);
end;

procedure TRecorderOglOscillogramSurface.Refresh(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double;
  AMeasureFps: Boolean);
var
  I: Integer;
  lDisplayStart: Double;
  lEndTime: Double;
  lFirst: Boolean;
  lMaxValue: Double;
  lMinValue: Double;
  lPage: TChartPage;
  lPointCount: Integer;
  lSnapshot: TRecorderSignalSnapshot;
  lTag: TRecorderTag;
  lTrend: cBuffTrend1d;
  lAxis: TChartAxis;
  lValueIndex: Integer;
  lStartIdx: Integer;
begin
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;
  if fFpsMeasureEnabled <> AMeasureFps then
    ResetFpsMeasure;
  fFpsMeasureEnabled := AMeasureFps;
  fDisplaySeconds := ADisplaySeconds;
  Inc(fFrameNo);
  for I := 0 to fCount - 1 do
  begin
    lPage := GetPage(I);
    lAxis := GetAxis(I);
    lTrend := GetTrend(I);
    if (lPage = nil) or (lAxis = nil) or (lTrend = nil) then
      Continue;
    if not lPage.ZoomedX then
    begin
      lPage.XMinValue := 0;
      lPage.XMaxValue := ADisplaySeconds;
      lPage.PresetMinXValue := 0;
      lPage.PresetMaxXValue := ADisplaySeconds;
    end;
    lTrend.ClearValues;
    lTrend.X0 := 0;
    lTrend.DX := 1;
    lTag := ResolveTag(ATagRegistry, I);
    UpdatePageCaption(lPage, lTag);
    if lTag = nil then
    begin
      SetAxisRange(lAxis, -1, 1);
      Continue;
    end;

    lSnapshot := lTag.Snapshot;
    if lSnapshot.Count = 0 then
    begin
      SetAxisRange(lAxis, -1, 1);
      Continue;
    end;

    lEndTime := lSnapshot.Times[lSnapshot.Count - 1];
    lDisplayStart := Max(lSnapshot.Times[0], lEndTime - ADisplaySeconds);
    lFirst := True;
    lPointCount := 0;
    lStartIdx := TDoubleSearch.FindFirstGreaterOrEqual(lSnapshot.Times, lSnapshot.Count, lDisplayStart);
    for lValueIndex := lStartIdx to lSnapshot.Count - 1 do
    begin
      if lFirst then
      begin
        lMinValue := lSnapshot.Values[lValueIndex];
        lMaxValue := lSnapshot.Values[lValueIndex];
        lTrend.X0 := lSnapshot.Times[lValueIndex] - lDisplayStart;
        if (lValueIndex < lSnapshot.Count - 1) and
          (lSnapshot.Times[lValueIndex + 1] > lSnapshot.Times[lValueIndex]) then
          lTrend.DX := lSnapshot.Times[lValueIndex + 1] -
            lSnapshot.Times[lValueIndex]
        else
          lTrend.DX := ADisplaySeconds;
        lFirst := False;
      end
      else
      begin
        if lSnapshot.Values[lValueIndex] < lMinValue then
          lMinValue := lSnapshot.Values[lValueIndex];
        if lSnapshot.Values[lValueIndex] > lMaxValue then
          lMaxValue := lSnapshot.Values[lValueIndex];
      end;

      lTrend.AddValue(lSnapshot.Values[lValueIndex]);
      Inc(lPointCount);
    end;

    if lPointCount = 0 then
      SetAxisRange(lAxis, -1, 1)
    else
      ApplyOscillogramTagYRange(lAxis, lTag, lMinValue, lMaxValue);
  end;

  RecorderDebugLog(Format('Ogl surface render: charts=%d frame=%d window=%.3f',
    [fCount, fFrameNo, ADisplaySeconds]));
  fChart.Redraw;
end;

procedure TRecorderOglOscillogramSurface.ForceRepaint;
begin
  Invalidate;
  if fChart <> nil then
  begin
    fChart.Invalidate;
    fChart.Repaint;
  end;
end;

procedure RebuildRecorderOglOscillograms(AOwner: TComponent; APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ACount: Integer;
  ADisplaySeconds: Double);
var
  I: Integer;
  lSurface: TRecorderOglOscillogramSurface;
begin
  if APanel = nil then
    Exit;
  if ACount < 1 then
    ACount := 1;
  lSurface := nil;
  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TRecorderOglOscillogramSurface then
      lSurface := TRecorderOglOscillogramSurface(APanel.Controls[I]);
  if lSurface = nil then
  begin
    while APanel.ControlCount > 0 do
      APanel.Controls[0].Free;
    lSurface := TRecorderOglOscillogramSurface.Create(AOwner);
    lSurface.Parent := APanel;
    lSurface.Align := alClient;
  end;

  lSurface.Rebuild(ATagRegistry, ACount, ADisplaySeconds);
  lSurface.BringToFront;
end;

procedure RefreshRecorderOglOscillograms(APanel: TPanel;
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double;
  AMeasureFps: Boolean);
var
  I: Integer;
begin
  if APanel = nil then
    Exit;
  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TRecorderOglOscillogramSurface then
    begin
      TRecorderOglOscillogramSurface(APanel.Controls[I]).Refresh(ATagRegistry,
        ADisplaySeconds, AMeasureFps);
      Exit;
    end;
end;

procedure RepaintRecorderOglOscillograms(APanel: TPanel);
var
  I: Integer;
begin
  if APanel = nil then
    Exit;
  APanel.Invalidate;
  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TRecorderOglOscillogramSurface then
    begin
      TRecorderOglOscillogramSurface(APanel.Controls[I]).ForceRepaint;
      Break;
    end;
  APanel.Update;
end;

function RecorderOglOscillogramsFpsText(APanel: TPanel): string;
var
  I: Integer;
begin
  Result := 'FPS -';
  if APanel = nil then
    Exit;
  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TRecorderOglOscillogramSurface then
      Exit(TRecorderOglOscillogramSurface(APanel.Controls[I]).FpsText);
end;

end.
