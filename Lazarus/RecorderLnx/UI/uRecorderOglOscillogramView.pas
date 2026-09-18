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
{$codepage UTF8}
interface

uses
  Classes, Controls, ExtCtrls, StdCtrls, Graphics, Forms, ComCtrls, Menus, ImgList,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartDrawObj,
  uOglChartTrend, uOglChartTypes, uRecorderFormModel, uRecorderTags, uRecorderVisualControl,
  uOglChartColors, uRecorderTagRefs, uRecorderPluginApi,
  uRecorderPluginRuntime;
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
    fComponent: TRecorderOscillogramComponent;
    fControlPanel: TScrollBox;
    fToolBar: TToolBar;
    fToolImages: TImageList;
    fLevelButton: TToolButton;
    fAutoRangeButton: TToolButton;
    fXCursorButton: TToolButton;
    fLegendButton: TToolButton;
    fLegendPanel: TScrollBox;
    fLegendLabels: array of TLabel;
    fXCursorMenu: TPopupMenu;
    fXCursorCount: Integer;
    fXCursors: array[0..1] of Double;
    fDraggingXCursor: Integer;
    fAutoRange: Boolean;
    fAutoRangeApplied: Boolean;
    fAppliedXMin, fAppliedXMax: Double;
    fAppliedYMin, fAppliedYMax: array of Double;
    fXScaleEdit: TEdit;
    fXScaleSpin: TUpDown;
    fYScaleEdit: TEdit;
    fYScaleSpin: TUpDown;
    fOffsetEdit: TEdit;
    fTriggerCheck: TCheckBox;
    fLevelEdit: TEdit;
    fPreRollEdit: TEdit;
    fClosedInputCheck: TCheckBox;
    fLevelCursorCheck: TCheckBox;
    fDraggingLevel: Boolean;
    fYRangeInitialized: Boolean;
    fYAxisTagId: TRecorderTagId;
    fTagRegistry: TRecorderTagRegistry;
    fUpdatingControls: Boolean;
    fPluginMetricsValid: Boolean;
    fPluginPeak: Double;
    fPluginRms: Double;
    fPluginValues: TRecorderDoubleArray;
    fTriggerTimes: TRecorderDoubleArray;
    fTriggerValues: TRecorderDoubleArray;
    fTriggerArmed: Boolean;
    fTriggerHasFrame: Boolean;
    fLastTriggerTime: Double;
    fFpsLastRenderTimeMs: Double;
    fFpsMeasureEnabled: Boolean;
    fFpsMeasured: Double;
    fFpsWindowFirstFrameMs: QWord;
    fFpsWindowFrames: Integer;
    fFpsWindowLastFrameMs: QWord;
    fFrameNo: Integer;
    fHasDataSignature: Boolean;
    fLastDataSignature: QWord;
    fLastSignatureDisplaySeconds: Double;
    fInfoPanel: TPanel;
    fDyLabel: TLabel;
    fInfoNextLeft: Integer;
    fTagOffset: Integer;
    fTagSlotIndex: Integer;
    fExtraLines: TList;
    fLineSnapshots: array of TRecorderSignalSnapshot;
    fLinePoints: array of TChartPoint;
    fModel: TObject;
    fPage: TObject;
    fAxis: TObject;
    fAxes: array of TChartAxis;
    fSeries: array of cLineSeries;
    fAxisRangeInitialized: array of Boolean;
    fAxisHasRange: array of Boolean;
    fAxisMin: array of Double;
    fAxisMax: array of Double;
    fTrend: TObject;
    procedure ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
    procedure BuildPluginControls;
    procedure BuildToolBar;
    procedure UpdateLegend;
    procedure RefreshLegendValues;
    function LegendValueAt(ASeries: cLineSeries; AX: Double;
      out AValue: Double): Boolean;
    procedure PaintToolButton(Sender: TToolButton; State: Integer);
    procedure ToolButtonClick(Sender: TObject);
    procedure XCursorModeClick(Sender: TObject);
    procedure DrawXCursors;
    function XCursorHit(AX, AY: Integer): Integer;
    procedure SetXCursorFromPixel(AIndex, AX: Integer);
    procedure DetectManualRange;
    procedure ControlValueEdited(Sender: TObject);
    procedure TriggerChanged(Sender: TObject);
    procedure ClosedInputChanged(Sender: TObject);
    procedure ScaleSpinClick(Sender: TObject; Button: TUDBtnType);
    procedure ChartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChartMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ChartMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetTriggerLevelFromPixel(AY: Integer);
    procedure DrawTriggerLevelCursor;
    function TriggerLevelHit(AX, AY: Integer): Boolean;
    procedure RefreshControlValues;
    function CurrentDisplaySeconds: Double;
    procedure SyncViewportControls;
    procedure EnsureTrendCount;
    procedure AccumulateAxisRange(AAxisIndex: Integer; AMinValue,
      AMaxValue: Double; APointCount: Integer);
    function TriggerAxis: TChartAxis;
    procedure FillTrendFromSnapshot(ATrend: cLineSeries;
      const ASnapshot: TRecorderSignalSnapshot; ADisplayStart: Double;
      ADisplaySeconds: Double; out AMinValue, AMaxValue: Double;
      out APointCount: Integer);
    function GetTrendByIndex(AIndex: Integer): cLineSeries;
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
    { Clears data and user zoom state at an acquisition-session boundary. }
    procedure ResetSessionData;
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
    fHasDataRevision: Boolean;
    fLastDataRevisions: array of QWord;
    fLastRevisionDisplaySeconds: Double;
    fSnapshots: array of TRecorderSignalSnapshot;
    fModel: TChartModel;
    function GetFpsText: string;
    procedure ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
    function GetAxis(AIndex: Integer): TChartAxis;
    function GetPage(AIndex: Integer): TChartPage;
    function GetTrend(AIndex: Integer): cBuffTrend1d;
    function RefreshRangeCaptions: Boolean;
    function ResolveTag(ATagRegistry: TRecorderTagRegistry;
      AIndex: Integer): TRecorderTag;
    procedure ResetFpsMeasure;
    procedure SetAxisRange(AAxis: TChartAxis; AMinValue, AMaxValue: Double);
    procedure UpdatePageCaption(APage: TChartPage; AAxis: TChartAxis;
      ATag: TRecorderTag);
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
  SysUtils, Math, uSharedNumberFormat,
  uRecorderDebugLog, uOglChartRenderer, uOglChartFontMng, GL;

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

function ClampOscillogramPageX(APage: TChartPage;
  ADisplaySeconds: Double): Boolean;
var
  lFullWidth: Double;
  lOldMax: Double;
  lOldMin: Double;
  lWidth: Double;
begin
  Result := False;
  if APage = nil then
    Exit;
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;

  lOldMin := APage.XMinValue;
  lOldMax := APage.XMaxValue;
  lFullWidth := ADisplaySeconds;
  lWidth := APage.XMaxValue - APage.XMinValue;

  if (lWidth <= 0) or (lWidth >= lFullWidth) then
  begin
    APage.XMinValue := 0;
    APage.XMaxValue := lFullWidth;
    APage.ZoomedX := False;
  end
  else
  begin
    if APage.XMinValue < 0 then
    begin
      APage.XMaxValue := lWidth;
      APage.XMinValue := 0;
    end;
    if APage.XMaxValue > lFullWidth then
    begin
      APage.XMinValue := lFullWidth - lWidth;
      APage.XMaxValue := lFullWidth;
    end;
    if APage.XMinValue < 0 then
      APage.XMinValue := 0;
  end;

  APage.PresetMinXValue := 0;
  APage.PresetMaxXValue := lFullWidth;
  Result := (Abs(lOldMin - APage.XMinValue) > 1E-12) or
    (Abs(lOldMax - APage.XMaxValue) > 1E-12);
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
            FormatSignificant(lEstimate.Value)]))
        else
          lParts.Add(OscillogramEstimateShortName(lKind) + '=-');
      end;

    if lParts.Count = 0 then
    begin
      lEstimate := ATag.Estimate(lSettings.DefaultKind);
      if lEstimate.Valid then
        lParts.Add(Format('%s=%s',
          [OscillogramEstimateShortName(lSettings.DefaultKind),
          FormatSignificant(lEstimate.Value)]))
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
  fDraggingXCursor := -1;
  fXCursorCount := 1;
  fXCursors[0] := 0.33;
  fXCursors[1] := 0.67;
  ConfigureDefault;
end;

destructor TRecorderOglOscillogram.Destroy;
var
  I: Integer;
begin
  fHasDataSignature := False;
  for I := fExtraLines.Count - 1 downto 0 do
    TObject(fExtraLines[I]).Free;
  fExtraLines.Free;
  inherited Destroy;
end;

procedure TRecorderOglOscillogram.Configure(AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
var
  I: Integer;
begin
  if fChart = nil then
    ConfigureDefault;
  fBindingMode := TRecorderOscillogramComponent(AComponent).BindingMode;
  fComponent := TRecorderOscillogramComponent(AComponent);
  fTagRegistry := ATagRegistry;
  if (fComponent.Factory <> nil) and
    (fComponent.Factory.TypeId <> 'oscillogram') then
  begin
    if fControlPanel = nil then
      BuildPluginControls;
    if fToolBar = nil then
      BuildToolBar;
    fAutoRange := fComponent.AutoRangeEnabled;
    fAutoRangeApplied := False;
    fXCursorCount := fComponent.XCursorCount;
    if (fXCursorCount < 1) or (fXCursorCount > 2) then
      fXCursorCount := 1;
    fXCursorMenu.Items[fXCursorCount - 1].Checked := True;
    fXCursorButton.Down := fComponent.XCursorEnabled;
    fAutoRangeButton.Down := fAutoRange;
    fLegendButton.Down := fComponent.LegendVisible;
    fLegendPanel.Visible := fComponent.LegendVisible;
    RefreshControlValues;
  end
  else
  begin
    if fControlPanel <> nil then fControlPanel.Visible := False;
    if fToolBar <> nil then fToolBar.Visible := False;
    if fLegendPanel <> nil then fLegendPanel.Visible := False;
  end;
  fTagOffset := TRecorderOscillogramComponent(AComponent).TagOffset;
  fAbsoluteTagId := AComponent.TagId;
  fAbsoluteTagName := AComponent.TagName;
  SyncLinesFromComponent(TRecorderOscillogramComponent(AComponent));
  EnsureTrendCount;
  UpdateLegend;
  for I := 0 to High(fAxisRangeInitialized) do
    fAxisRangeInitialized[I] := False;
  fHasDataSignature := False;
  fTriggerArmed := False;
  fTriggerHasFrame := False;
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
  lTrend: cLineSeries;
begin
  SetLength(fAxes, 0);
  SetLength(fSeries, 0);
  SetLength(fAxisRangeInitialized, 0);
  fYRangeInitialized := False;
  fAutoRange := False;
  fAutoRangeApplied := False;
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
  lChart.OnMouseDown := @ChartMouseDown;
  lChart.OnMouseMove := @ChartMouseMove;
  lChart.OnMouseUp := @ChartMouseUp;
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
  { Обратная рамка масштабирует по точкам текущего кадра. Общий FitZoomY
    добавляет по 10% сверху и снизу, то есть 20% к полному диапазону сигнала. }
  lPage.AutoScaleOnZoomReset := True;
  lPage.ResetZoomOnDoubleClick := True;
  lPage.ReverseDragZoomOut := True;
  lPage.PreserveAutoFitZoomY := True;
  lAxis := TChartAxis.Create;
  lAxis.Name := 'Axis1';
  lAxis.Caption := '';
  lAxis.MinValue := -1;
  lAxis.MaxValue := 1;
  lAxis.Color := $FF404040;
  lTrend := cLineSeries.Create;
  lTrend.Name := 'Signal';
  lTrend.Caption := '';
  lTrend.Color := $FFFF0000;
  lAxis.AddChild(lTrend);
  lPage.AddChild(lAxis);
  lModel.AddChild(lPage);
  lChart.Model := lModel;
  fChart := lChart;
  fModel := lModel;
  fPage := lPage;
  fAxis := lAxis;
  fTrend := lTrend;
  SetLength(fAxes, 1);
  fAxes[0] := lAxis;
  SetLength(fSeries, 1);
  fSeries[0] := lTrend;
  SetLength(fAxisRangeInitialized, 1);
  fYRangeInitialized := False;
  fYAxisTagId := 0;
  ResetFpsMeasure;
end;

procedure TRecorderOglOscillogram.ChartAfterRender(Sender: TObject;
  ARenderTimeMs: Double);
var
  lNowMs: QWord;
  lDyText: string;
begin
  fFpsLastRenderTimeMs := ARenderTimeMs;
  DrawTriggerLevelCursor;
  DrawXCursors;
  DetectManualRange;
  SyncViewportControls;
  if (fDyLabel <> nil) and (fAxis <> nil) then
  begin
    lDyText := Format('; dY=%s', [FormatSignificant(
      TChartAxis(fAxis).MaxValue - TChartAxis(fAxis).MinValue)]);
    if fDyLabel.Caption <> lDyText then
      fDyLabel.Caption := lDyText;
  end;
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
  fDyLabel := nil;
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
    if fAxis <> nil then
    begin
      AppendInfoPart(Format('; dY=%s', [FormatSignificant(
        TChartAxis(fAxis).MaxValue - TChartAxis(fAxis).MinValue)]), clGray);
      fDyLabel := TLabel(fInfoPanel.Controls[fInfoPanel.ControlCount - 1]);
    end;
    if fPluginMetricsValid then
      AppendInfoPart(Format('; Peak=%s RMS=%s',
        [FormatSignificant(fPluginPeak),
         FormatSignificant(fPluginRms)]), clGray);
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
    if fAxis <> nil then
    begin
      AppendInfoPart(Format('; dY=%s',
        [FormatSignificant(TChartAxis(fAxis).MaxValue -
          TChartAxis(fAxis).MinValue)]), clGray);
      fDyLabel := TLabel(fInfoPanel.Controls[fInfoPanel.ControlCount - 1]);
    end;
    if fPluginMetricsValid then
      AppendInfoPart(Format('; Peak=%s RMS=%s',
        [FormatSignificant(fPluginPeak),
         FormatSignificant(fPluginRms)]), clGray);
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
  I, lAxisIndex, lAxisCount, lSeriesIndex: Integer;
  lAxis: TChartAxis;
  lLine: TRecorderTrendLine;
  lNeed: Integer;
  lTrend: cLineSeries;
begin
  if fAxis = nil then
    Exit;
  lAxisCount := 1;
  if fComponent <> nil then
    lAxisCount := Max(1, fComponent.AxisCount);
  if Length(fAxes) > lAxisCount then
  begin
    for I := 0 to High(fSeries) do
      if fSeries[I].Parent <> fAxes[0] then
        fAxes[0].AddChild(fSeries[I]);
  end;
  while Length(fAxes) > lAxisCount do
  begin
    fAxes[High(fAxes)].Free;
    SetLength(fAxes, Length(fAxes) - 1);
  end;
  while Length(fAxes) < lAxisCount do
  begin
    lAxis := TChartAxis.Create;
    lAxis.Name := Format('Axis%d', [Length(fAxes) + 1]);
    lAxis.MinValue := -1;
    lAxis.MaxValue := 1;
    lAxis.Color := $FF404040;
    TChartPage(fPage).AddChild(lAxis);
    SetLength(fAxes, Length(fAxes) + 1);
    fAxes[High(fAxes)] := lAxis;
  end;
  SetLength(fAxisRangeInitialized, lAxisCount);
  SetLength(fAxisHasRange, lAxisCount);
  SetLength(fAxisMin, lAxisCount);
  SetLength(fAxisMax, lAxisCount);
  lAxis := TChartAxis(fAxis);
  lNeed := 1 + fExtraLines.Count;
  while Length(fSeries) > lNeed do
  begin
    fSeries[High(fSeries)].Free;
    SetLength(fSeries, Length(fSeries) - 1);
  end;
  while Length(fSeries) < lNeed do
  begin
    lTrend := cLineSeries.Create;
    lTrend.Name := OglChartLinePaletteName(Length(fSeries));
    lTrend.Caption := lTrend.Name;
    lTrend.Color := OglChartLinePaletteGLColor(Length(fSeries));
    lAxis.AddChild(lTrend);
    SetLength(fSeries, Length(fSeries) + 1);
    fSeries[High(fSeries)] := lTrend;
  end;
  for I := 0 to lNeed - 1 do
  begin
    lAxisIndex := 0;
    if fComponent <> nil then
      if I = 0 then
        lAxisIndex := fComponent.PrimaryAxisIndex
      else
        lAxisIndex := TRecorderTrendLine(fExtraLines[I - 1]).AxisIndex;
    lAxisIndex := Max(0, Min(lAxisIndex, lAxisCount - 1));
    if fSeries[I].Parent <> fAxes[lAxisIndex] then
      fAxes[lAxisIndex].AddChild(fSeries[I]);
  end;
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
  for I := 0 to High(fAxes) do
  begin
    fAxes[I].Color := $FF404040;
    for lSeriesIndex := 0 to High(fSeries) do
      if fSeries[lSeriesIndex].Visible and
         (fSeries[lSeriesIndex].Parent = fAxes[I]) then
      begin
        fAxes[I].Color := fSeries[lSeriesIndex].Color;
        Break;
      end;
  end;
  fTrend := GetTrendByIndex(0);
end;

function TRecorderOglOscillogram.GetTrendByIndex(AIndex: Integer): cLineSeries;
begin
  Result := nil;
  if (AIndex >= 0) and (AIndex < Length(fSeries)) then
    Result := fSeries[AIndex];
end;

procedure TRecorderOglOscillogram.AccumulateAxisRange(AAxisIndex: Integer;
  AMinValue, AMaxValue: Double; APointCount: Integer);
begin
  if (APointCount <= 0) or (AAxisIndex < 0) or
    (AAxisIndex >= Length(fAxisHasRange)) then
    Exit;
  if not fAxisHasRange[AAxisIndex] then
  begin
    fAxisMin[AAxisIndex] := AMinValue;
    fAxisMax[AAxisIndex] := AMaxValue;
    fAxisHasRange[AAxisIndex] := True;
  end
  else
  begin
    fAxisMin[AAxisIndex] := Min(fAxisMin[AAxisIndex], AMinValue);
    fAxisMax[AAxisIndex] := Max(fAxisMax[AAxisIndex], AMaxValue);
  end;
end;

function TRecorderOglOscillogram.TriggerAxis: TChartAxis;
var
  I, lIndex: Integer;
  lLine: TRecorderTrendLine;
begin
  Result := TChartAxis(fAxis);
  if (fComponent = nil) or (Length(fAxes) = 0) then
    Exit;
  lIndex := 0;
  if SameText(fComponent.TriggerTagName, fComponent.TagName) then
    lIndex := fComponent.PrimaryAxisIndex
  else
    for I := 0 to fExtraLines.Count - 1 do
    begin
      lLine := TRecorderTrendLine(fExtraLines[I]);
      if SameText(fComponent.TriggerTagName, lLine.TagName) then
      begin
        lIndex := lLine.AxisIndex;
        Break;
      end;
    end;
  Result := fAxes[Max(0, Min(lIndex, High(fAxes)))];
end;

function TRecorderOglOscillogram.TrendLabelColor(AIndex: Integer): TColor;
var
  lTrend: cLineSeries;
begin
  lTrend := GetTrendByIndex(AIndex);
  if lTrend = nil then
    Exit(clGray);
  Result := TColor(lTrend.Color and $00FFFFFF);
end;

procedure TRecorderOglOscillogram.FillTrendFromSnapshot(ATrend: cLineSeries;
  const ASnapshot: TRecorderSignalSnapshot; ADisplayStart: Double;
  ADisplaySeconds: Double; out AMinValue, AMaxValue: Double;
  out APointCount: Integer);
var
  I: Integer;
  lTime: Double;
  lMean: Double;
  lMeanCount: Integer;
  lValue: Double;
begin
  APointCount := 0;
  AMinValue := 0;
  AMaxValue := 0;
  if ATrend = nil then
    Exit;
  if ASnapshot.Count = 0 then
  begin
    ATrend.ClearPoints;
    Exit;
  end;
  if Length(fLinePoints) < ASnapshot.Count then
    SetLength(fLinePoints, ASnapshot.Count);
  lMean := 0;
  lMeanCount := 0;
  if (fComponent <> nil) and fComponent.ClosedInput then
  begin
    for I := 0 to ASnapshot.Count - 1 do
      if (ASnapshot.Times[I] >= ADisplayStart) and
         (ASnapshot.Times[I] <= ADisplayStart + ADisplaySeconds) then
      begin
        lMean := lMean + ASnapshot.Values[I];
        Inc(lMeanCount);
      end;
    if lMeanCount > 0 then
      lMean := lMean / lMeanCount;
  end;
  for I := 0 to ASnapshot.Count - 1 do
  begin
    lTime := ASnapshot.Times[I] - ADisplayStart;
    if (lTime < 0) or (lTime > ADisplaySeconds) then
      Continue;
    lValue := ASnapshot.Values[I] - lMean;
    fLinePoints[APointCount].X := lTime;
    fLinePoints[APointCount].Y := lValue;
    if APointCount = 0 then
    begin
      AMinValue := lValue;
      AMaxValue := lValue;
    end
    else
    begin
      if lValue < AMinValue then
        AMinValue := lValue;
      if lValue > AMaxValue then
        AMaxValue := lValue;
    end;
    Inc(APointCount);
  end;
  ATrend.ReplacePoints(fLinePoints, APointCount);
end;

procedure TRecorderOglOscillogram.BuildPluginControls;
var
  lLabel: TLabel;

  procedure AddLabel(const ACaption: string; ATop: Integer);
  begin
    lLabel := TLabel.Create(Self);
    lLabel.Parent := fControlPanel;
    lLabel.Left := 8;
    lLabel.Top := ATop;
    lLabel.Caption := ACaption;
  end;

  function AddEdit(ATop: Integer): TEdit;
  begin
    Result := TEdit.Create(Self);
    Result.Parent := fControlPanel;
    Result.Left := 8;
    Result.Top := ATop;
    Result.Width := 105;
    Result.OnEditingDone := @ControlValueEdited;
  end;

begin
  fControlPanel := TScrollBox.Create(Self);
  fControlPanel.Parent := Self;
  fControlPanel.Align := alRight;
  fControlPanel.Width := 152;
  fControlPanel.BorderStyle := bsSingle;
  fControlPanel.AutoScroll := True;
  fControlPanel.Color := clBtnFace;
  AddLabel('Развертка X, с', 8);
  fXScaleEdit := AddEdit(27);
  fXScaleSpin := TUpDown.Create(Self);
  fXScaleSpin.Parent := fControlPanel;
  fXScaleSpin.SetBounds(113, 27, 25, 23);
  fXScaleSpin.OnClick := @ScaleSpinClick;
  AddLabel('Масштаб Y', 57);
  fYScaleEdit := AddEdit(76);
  fYScaleSpin := TUpDown.Create(Self);
  fYScaleSpin.Parent := fControlPanel;
  fYScaleSpin.SetBounds(113, 76, 25, 23);
  fYScaleSpin.OnClick := @ScaleSpinClick;
  AddLabel('Смещение Y', 106);
  fOffsetEdit := AddEdit(125);
  fTriggerCheck := TCheckBox.Create(Self);
  fTriggerCheck.Parent := fControlPanel;
  fTriggerCheck.Left := 8;
  fTriggerCheck.Top := 155;
  fTriggerCheck.Caption := 'Триггер';
  fTriggerCheck.OnChange := @TriggerChanged;
  AddLabel('Уровень', 184);
  fLevelEdit := AddEdit(203);
  fLevelCursorCheck := TCheckBox.Create(Self);
  fLevelCursorCheck.Parent := fControlPanel;
  fLevelCursorCheck.SetBounds(8, 233, 136, 23);
  fLevelCursorCheck.Caption := 'Курсор уровня';
  fLevelCursorCheck.Visible := False;
  fLevelCursorCheck.OnChange := @TriggerChanged;
  fClosedInputCheck := TCheckBox.Create(Self);
  fClosedInputCheck.Parent := fControlPanel;
  fClosedInputCheck.SetBounds(8, 233, 136, 23);
  fClosedInputCheck.Caption := 'Закрытый вход';
  fClosedInputCheck.OnChange := @ClosedInputChanged;
  AddLabel('До триггера, % окна', 263);
  fPreRollEdit := AddEdit(282);
end;

procedure TRecorderOglOscillogram.BuildToolBar;
var
  lBitmap: TBitmap;
  lItem: TMenuItem;
  I: Integer;

  procedure AddIcon(AKind: Integer);
  begin
    lBitmap.Canvas.Brush.Color := clFuchsia;
    lBitmap.Canvas.FillRect(Rect(0, 0, 16, 16));
    lBitmap.Canvas.Pen.Color := clNavy;
    case AKind of
      0: begin
        lBitmap.Canvas.Pen.Style := psDash;
        lBitmap.Canvas.MoveTo(1, 8);
        lBitmap.Canvas.LineTo(15, 8);
        lBitmap.Canvas.Pen.Style := psSolid;
      end;
      1: begin
        lBitmap.Canvas.Rectangle(1, 2, 15, 14);
        lBitmap.Canvas.MoveTo(2, 11);
        lBitmap.Canvas.LineTo(6, 8);
        lBitmap.Canvas.LineTo(10, 10);
        lBitmap.Canvas.LineTo(14, 4);
      end;
      2: begin
        lBitmap.Canvas.MoveTo(8, 1);
        lBitmap.Canvas.LineTo(8, 15);
        lBitmap.Canvas.MoveTo(5, 11);
        lBitmap.Canvas.LineTo(5, 15);
      end;
      3: begin
        lBitmap.Canvas.Rectangle(1, 2, 15, 14);
        lBitmap.Canvas.MoveTo(3, 6);
        lBitmap.Canvas.LineTo(13, 6);
        lBitmap.Canvas.MoveTo(3, 10);
        lBitmap.Canvas.LineTo(13, 10);
      end;
    end;
    fToolImages.AddMasked(lBitmap, clFuchsia);
  end;

  function AddButton(const AHint: string; AImageIndex: Integer): TToolButton;
  begin
    Result := TToolButton.Create(Self);
    Result.Parent := fToolBar;
    Result.Style := tbsCheck;
    Result.ImageIndex := AImageIndex;
    Result.Hint := AHint;
    Result.ShowHint := True;
    Result.OnClick := @ToolButtonClick;
  end;

begin
  fToolImages := TImageList.Create(Self);
  fToolImages.Width := 16;
  fToolImages.Height := 16;
  lBitmap := TBitmap.Create;
  try
    lBitmap.SetSize(16, 16);
    for I := 0 to 3 do AddIcon(I);
  finally
    lBitmap.Free;
  end;
  fToolBar := TToolBar.Create(Self);
  fToolBar.Parent := Self;
  fToolBar.Align := alTop;
  fToolBar.Height := 26;
  fToolBar.Images := fToolImages;
  fToolBar.OnPaintButton := @PaintToolButton;
  fToolBar.ShowCaptions := False;
  fLevelButton := AddButton('Курсор уровня', 0);
  fAutoRangeButton := AddButton('Автодиапазон всех осей', 1);
  fXCursorButton := AddButton('Курсор X (режим — правой кнопкой)', 2);
  fLegendButton := AddButton('Показать/скрыть легенду', 3);
  fXCursorMenu := TPopupMenu.Create(Self);
  for I := 1 to 2 do
  begin
    lItem := TMenuItem.Create(fXCursorMenu);
    if I = 1 then lItem.Caption := 'Один курсор X'
    else lItem.Caption := 'Два курсора X';
    lItem.Tag := I;
    lItem.RadioItem := True;
    lItem.GroupIndex := 1;
    lItem.Checked := I = 1;
    lItem.OnClick := @XCursorModeClick;
    fXCursorMenu.Items.Add(lItem);
  end;
  fXCursorButton.PopupMenu := fXCursorMenu;
  fLegendPanel := TScrollBox.Create(Self);
  fLegendPanel.Parent := Self;
  fLegendPanel.Align := alBottom;
  fLegendPanel.Height := 25;
  fLegendPanel.BorderStyle := bsSingle;
  fLegendPanel.AutoScroll := True;
  fLegendButton.Down := True;
end;

procedure TRecorderOglOscillogram.UpdateLegend;
var
  I: Integer;
begin
  if fLegendPanel = nil then Exit;
  for I := 0 to High(fLegendLabels) do
    fLegendLabels[I].Free;
  SetLength(fLegendLabels, Length(fSeries));
  for I := 0 to High(fSeries) do
  begin
    fLegendLabels[I] := TLabel.Create(Self);
    fLegendLabels[I].Parent := fLegendPanel;
    fLegendLabels[I].Top := 5;
  end;
  RefreshLegendValues;
end;

function TRecorderOglOscillogram.LegendValueAt(ASeries: cLineSeries;
  AX: Double; out AValue: Double): Boolean;
var
  lFirst, lLast, lMiddle: Integer;
  lLeft, lRight: TChartPoint;
begin
  Result := False;
  if (ASeries = nil) or (ASeries.PointCount = 0) then Exit;
  lFirst := 0;
  lLast := ASeries.PointCount - 1;
  if (AX < ASeries.Points[lFirst].X) or
     (AX > ASeries.Points[lLast].X) then Exit;
  while lFirst < lLast do
  begin
    lMiddle := (lFirst + lLast) div 2;
    if ASeries.Points[lMiddle].X < AX then
      lFirst := lMiddle + 1
    else
      lLast := lMiddle;
  end;
  lRight := ASeries.Points[lFirst];
  if (lFirst = 0) or (lRight.X = AX) then
    AValue := lRight.Y
  else
  begin
    lLeft := ASeries.Points[lFirst - 1];
    if lRight.X = lLeft.X then
      AValue := lRight.Y
    else
      AValue := lLeft.Y + (lRight.Y - lLeft.Y) *
        (AX - lLeft.X) / (lRight.X - lLeft.X);
  end;
  Result := True;
end;

procedure TRecorderOglOscillogram.RefreshLegendValues;
var
  I, lLeft: Integer;
  lSeries: cLineSeries;
  lCaption, lName: string;
  lX, lValue1, lValue2: Double;
  lHas1, lHas2: Boolean;
  lPage: TChartPage;
begin
  if (fLegendPanel = nil) or not fLegendPanel.Visible or
     (fPage = nil) then Exit;
  lPage := TChartPage(fPage);
  lLeft := 8;
  for I := 0 to High(fLegendLabels) do
  begin
    lSeries := GetTrendByIndex(I);
    fLegendLabels[I].Visible := (lSeries <> nil) and lSeries.Visible;
    if not fLegendLabels[I].Visible then Continue;
    if (I = 0) and (fComponent <> nil) and
       (Trim(fComponent.TagName) <> '') then
      lName := fComponent.TagName
    else
      lName := lSeries.Caption;
    lCaption := '■ ' + lName;
    if (fXCursorButton <> nil) and fXCursorButton.Down then
    begin
      lX := lPage.XMinValue + fXCursors[0] *
        (lPage.XMaxValue - lPage.XMinValue);
      lHas1 := LegendValueAt(lSeries, lX, lValue1);
      if lHas1 then
        lCaption := lCaption + '  Y1=' + FormatSignificant(lValue1)
      else
        lCaption := lCaption + '  Y1=-';
      if fXCursorCount = 2 then
      begin
        lX := lPage.XMinValue + fXCursors[1] *
          (lPage.XMaxValue - lPage.XMinValue);
        lHas2 := LegendValueAt(lSeries, lX, lValue2);
        if lHas2 then
          lCaption := lCaption + '  Y2=' + FormatSignificant(lValue2)
        else
          lCaption := lCaption + '  Y2=-';
        if lHas1 and lHas2 then
          lCaption := lCaption + '  Δ=' +
            FormatSignificant(lValue2 - lValue1);
      end;
    end
    else if lSeries.PointCount > 0 then
      lCaption := lCaption + '  Y=' +
        FormatSignificant(lSeries.Points[lSeries.PointCount - 1].Y)
    else
      lCaption := lCaption + '  Y=-';
    if fLegendLabels[I].Caption <> lCaption then
      fLegendLabels[I].Caption := lCaption;
    fLegendLabels[I].Font.Color := TrendLabelColor(I);
    fLegendLabels[I].Left := lLeft;
    lLeft := lLeft + fLegendLabels[I].Width + 16;
  end;
end;

procedure TRecorderOglOscillogram.PaintToolButton(
  Sender: TToolButton; State: Integer);
var
  lRect: TRect;
begin
  lRect := Sender.ClientRect;
  if Sender.Down then
    Sender.Canvas.Brush.Color := RGBToColor(188, 220, 255)
  else
    Sender.Canvas.Brush.Color := fToolBar.Color;
  Sender.Canvas.FillRect(lRect);
  if Sender.Down then
  begin
    Sender.Canvas.Pen.Color := RGBToColor(45, 102, 170);
    Sender.Canvas.Brush.Style := bsClear;
    Sender.Canvas.Rectangle(lRect);
    Sender.Canvas.Brush.Style := bsSolid;
  end;
  fToolImages.Draw(Sender.Canvas,
    (Sender.Width - fToolImages.Width) div 2,
    (Sender.Height - fToolImages.Height) div 2,
    Sender.ImageIndex, Sender.Enabled);
end;

procedure TRecorderOglOscillogram.ToolButtonClick(Sender: TObject);
var
  I: Integer;
begin
  if Sender = fLevelButton then
  begin
    fLevelCursorCheck.Checked := fLevelButton.Down;
    if fComponent <> nil then fComponent.LevelCursorVisible := fLevelButton.Down;
    fChart.Invalidate;
  end
  else if Sender = fAutoRangeButton then
  begin
    fAutoRange := fAutoRangeButton.Down;
    if fComponent <> nil then fComponent.AutoRangeEnabled := fAutoRange;
    fAutoRangeApplied := False;
    if fAutoRange then
    begin
      TChartPage(fPage).ZoomedX := False;
      for I := 0 to High(fAxisRangeInitialized) do
        fAxisRangeInitialized[I] := False;
    end;
    fHasDataSignature := False;
    Refresh(fTagRegistry, CurrentDisplaySeconds);
  end
  else if Sender = fXCursorButton then
  begin
    if fComponent <> nil then fComponent.XCursorEnabled := fXCursorButton.Down;
    RefreshLegendValues;
    fChart.Invalidate;
  end
  else if Sender = fLegendButton then
  begin
    fLegendPanel.Visible := fLegendButton.Down;
    if fComponent <> nil then fComponent.LegendVisible := fLegendButton.Down;
    RefreshLegendValues;
  end;
end;

procedure TRecorderOglOscillogram.XCursorModeClick(Sender: TObject);
begin
  fXCursorCount := TMenuItem(Sender).Tag;
  if fComponent <> nil then fComponent.XCursorCount := fXCursorCount;
  TMenuItem(Sender).Checked := True;
  RefreshLegendValues;
  fChart.Invalidate;
end;

procedure TRecorderOglOscillogram.RefreshControlValues;
begin
  if (fControlPanel = nil) or (fComponent = nil) then
    Exit;
  fUpdatingControls := True;
  try
  fControlPanel.Visible := True;
  fXScaleEdit.Text := FormatSignificant(fComponent.XScale);
  fYScaleEdit.Text := FormatSignificant(fComponent.YScale);
  fOffsetEdit.Text := FormatSignificant(fComponent.YOffset);
  fLevelEdit.Text := FormatSignificant(fComponent.TriggerLevel);
  fPreRollEdit.Text := FormatSignificant(fComponent.TriggerPreRollPercent);
  fTriggerCheck.Checked := fComponent.TriggerEnabled;
  fClosedInputCheck.Checked := fComponent.ClosedInput;
  fLevelCursorCheck.Checked := fComponent.LevelCursorVisible;
  if fLevelButton <> nil then
    fLevelButton.Down := fLevelCursorCheck.Checked;
  finally
    fUpdatingControls := False;
  end;
end;

procedure TRecorderOglOscillogram.SyncViewportControls;
var
  lAxis: TChartAxis;
  lPage: TChartPage;
  lBaseRange: Double;
  lScale: Double;
  lOffset: Double;

  procedure SetVisibleValue(AEdit: TEdit; AValue: Double);
  var
    lText: string;
  begin
    if AEdit.Focused then
      Exit;
    lText := FormatSignificant(AValue);
    if AEdit.Text <> lText then
      AEdit.Text := lText;
  end;

begin
  if (fControlPanel = nil) or not fControlPanel.Visible or
    (fComponent = nil) or (fPage = nil) or (fAxis = nil) then
    Exit;
  lPage := TChartPage(fPage);
  lAxis := TChartAxis(fAxis);
  lBaseRange := lAxis.PresetMaxValue - lAxis.PresetMinValue;
  lScale := fComponent.YScale;
  lOffset := fComponent.YOffset;
  if lBaseRange > 0 then
  begin
    lScale := (lAxis.MaxValue - lAxis.MinValue) / lBaseRange;
    lOffset := (lAxis.MinValue + lAxis.MaxValue -
      lAxis.PresetMinValue - lAxis.PresetMaxValue) / 2;
  end;
  fUpdatingControls := True;
  try
    if lPage.XMaxValue > lPage.XMinValue then
      SetVisibleValue(fXScaleEdit, lPage.XMaxValue - lPage.XMinValue);
    SetVisibleValue(fYScaleEdit, lScale);
    SetVisibleValue(fOffsetEdit, lOffset);
  finally
    fUpdatingControls := False;
  end;
end;

function TRecorderOglOscillogram.CurrentDisplaySeconds: Double;
begin
  Result := fLastSignatureDisplaySeconds;
  if Result <= 0 then
    Result := 1.0;
end;

procedure TRecorderOglOscillogram.ControlValueEdited(Sender: TObject);
var
  lValue: Double;
  lCompanionValue: Double;
begin
  if (fComponent = nil) or fUpdatingControls then
    Exit;
  if not TryStrToFloat(TEdit(Sender).Text, lValue) then
    Exit;
  if Sender = fXScaleEdit then
  begin
    if lValue <= 0 then Exit;
    fComponent.XScale := lValue;
    fTriggerArmed := False;
    fTriggerHasFrame := False;
    TChartPage(fPage).ZoomedX := False;
  end
  else if Sender = fYScaleEdit then
  begin
    if lValue <= 0 then Exit;
    fAutoRange := False;
    fComponent.AutoRangeEnabled := False;
    if fAutoRangeButton <> nil then fAutoRangeButton.Down := False;
    fComponent.YScale := lValue;
    if TryStrToFloat(fOffsetEdit.Text, lCompanionValue) then
      fComponent.YOffset := lCompanionValue;
    TChartAxis(fAxis).HasPresetRange := False;
  end
  else if Sender = fOffsetEdit then
  begin
    fAutoRange := False;
    fComponent.AutoRangeEnabled := False;
    if fAutoRangeButton <> nil then fAutoRangeButton.Down := False;
    fComponent.YOffset := lValue;
    if TryStrToFloat(fYScaleEdit.Text, lCompanionValue) and
      (lCompanionValue > 0) then
      fComponent.YScale := lCompanionValue;
    TChartAxis(fAxis).HasPresetRange := False;
  end
  else if Sender = fLevelEdit then
  begin
    fComponent.TriggerLevel := lValue;
    fTriggerArmed := False;
    fTriggerHasFrame := False;
  end
  else if Sender = fPreRollEdit then
  begin
    fComponent.TriggerPreRollPercent := lValue;
    fPreRollEdit.Text := FormatSignificant(fComponent.TriggerPreRollPercent);
    fTriggerArmed := False;
    fTriggerHasFrame := False;
  end;
  fHasDataSignature := False;
  Refresh(fTagRegistry, CurrentDisplaySeconds);
end;

procedure TRecorderOglOscillogram.TriggerChanged(Sender: TObject);
begin
  if (fComponent = nil) or fUpdatingControls then
    Exit;
  fComponent.TriggerEnabled := fTriggerCheck.Checked;
  if Sender = fLevelCursorCheck then
  begin
    fComponent.LevelCursorVisible := fLevelCursorCheck.Checked;
    if fLevelButton <> nil then fLevelButton.Down := fLevelCursorCheck.Checked;
  end;
  fTriggerArmed := False;
  fTriggerHasFrame := False;
  fHasDataSignature := False;
  Refresh(fTagRegistry, CurrentDisplaySeconds);
end;

procedure TRecorderOglOscillogram.DrawXCursors;
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  lPage: TChartPage;
  lX: Single;
  I: Integer;
begin
  if (fXCursorButton = nil) or not fXCursorButton.Down or
     (fChart = nil) or (fPage = nil) then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  lPage := TChartPage(fPage);
  lRect := lRenderer.GetPageContentRect(lPage);
  for I := 0 to fXCursorCount - 1 do
  begin
    lX := lRect.Left + fXCursors[I] * (lRect.Right - lRect.Left);
    glColor3f(0.8, 0.1, 0.1);
    glLineWidth(1.5);
    glLineStipple(1, $00FF);
    glEnable(GL_LINE_STIPPLE);
    glBegin(GL_LINES);
    glVertex2f(lX, lRect.Top);
    glVertex2f(lX, lRect.Bottom);
    glEnd;
    glDisable(GL_LINE_STIPPLE);
    glLineWidth(1);
  end;
end;

function TRecorderOglOscillogram.XCursorHit(AX, AY: Integer): Integer;
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  I: Integer;
begin
  Result := -1;
  if (fXCursorButton = nil) or not fXCursorButton.Down or
     (fChart = nil) or (fPage = nil) then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  lRect := lRenderer.GetPageContentRect(TChartPage(fPage));
  if (AY < lRect.Top) or (AY > lRect.Bottom) then Exit;
  for I := 0 to fXCursorCount - 1 do
    if Abs(AX - (lRect.Left + fXCursors[I] *
      (lRect.Right - lRect.Left))) <= 6 then Exit(I);
end;

procedure TRecorderOglOscillogram.SetXCursorFromPixel(AIndex, AX: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
begin
  if (AIndex < 0) or (AIndex > 1) or (fChart = nil) then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  lRect := lRenderer.GetPageContentRect(TChartPage(fPage));
  if lRect.Right <= lRect.Left then Exit;
  fXCursors[AIndex] := EnsureRange((AX - lRect.Left) /
    (lRect.Right - lRect.Left), 0.0, 1.0);
  if fXCursorButton <> nil then
    fXCursorButton.Hint := Format('X%d = %s с', [AIndex + 1,
      FormatSignificant(TChartPage(fPage).XMinValue + fXCursors[AIndex] *
        (TChartPage(fPage).XMaxValue - TChartPage(fPage).XMinValue))]);
  RefreshLegendValues;
  fChart.Invalidate;
end;

procedure TRecorderOglOscillogram.DetectManualRange;
var
  I: Integer;
  lChanged: Boolean;
begin
  if not fAutoRange or not fAutoRangeApplied or (fPage = nil) then Exit;
  lChanged := (Abs(TChartPage(fPage).XMinValue - fAppliedXMin) > 1E-9) or
    (Abs(TChartPage(fPage).XMaxValue - fAppliedXMax) > 1E-9);
  for I := 0 to Min(High(fAxes), High(fAppliedYMin)) do
    lChanged := lChanged or
      (Abs(fAxes[I].MinValue - fAppliedYMin[I]) > 1E-9) or
      (Abs(fAxes[I].MaxValue - fAppliedYMax[I]) > 1E-9);
  if lChanged then
  begin
    fAutoRange := False;
    if fComponent <> nil then fComponent.AutoRangeEnabled := False;
    fAutoRangeApplied := False;
    if fAutoRangeButton <> nil then fAutoRangeButton.Down := False;
  end;
end;

procedure TRecorderOglOscillogram.ClosedInputChanged(Sender: TObject);
var
  I: Integer;
begin
  if (fComponent = nil) or fUpdatingControls then
    Exit;
  fComponent.ClosedInput := fClosedInputCheck.Checked;
  fTriggerArmed := False;
  fTriggerHasFrame := False;
  fYRangeInitialized := False;
  for I := 0 to High(fAxisRangeInitialized) do
    fAxisRangeInitialized[I] := False;
  fHasDataSignature := False;
  Refresh(fTagRegistry, CurrentDisplaySeconds);
end;

procedure TRecorderOglOscillogram.ScaleSpinClick(Sender: TObject;
  Button: TUDBtnType);
var
  lEdit: TEdit;
  lValue, lUnit, lScaled: Double;
begin
  if (fComponent = nil) or fUpdatingControls then
    Exit;
  if Sender = fXScaleSpin then
    lEdit := fXScaleEdit
  else
    lEdit := fYScaleEdit;
  if not TryStrToFloat(lEdit.Text, lValue) or (lValue <= 0) then
  begin
    if Sender = fXScaleSpin then
      lValue := TChartPage(fPage).XMaxValue - TChartPage(fPage).XMinValue
    else
      lValue := 1;
  end;
  lUnit := Power(10, Floor(Log10(Max(lValue, 1E-9))));
  lScaled := lValue / lUnit;
  if Button = btNext then
  begin
    if lScaled < 1.5 then lValue := 2 * lUnit
    else if lScaled < 3.5 then lValue := 5 * lUnit
    else lValue := 10 * lUnit;
  end
  else
  begin
    if lScaled > 7.5 then lValue := 5 * lUnit
    else if lScaled > 3.5 then lValue := 2 * lUnit
    else if lScaled > 1.5 then lValue := lUnit
    else lValue := 0.5 * lUnit;
  end;
  lEdit.Text := FormatSignificant(Max(lValue, 1E-6));
  ControlValueEdited(lEdit);
end;

procedure TRecorderOglOscillogram.DrawTriggerLevelCursor;
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  lY: Single;
begin
  if (fComponent = nil) or (fChart = nil) or (fPage = nil) or
     (fLevelCursorCheck = nil) or not fLevelCursorCheck.Checked then
    Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if (lRenderer = nil) or (TriggerAxis = nil) then Exit;
  lRect := lRenderer.GetPageContentRect(TChartPage(fPage));
  lY := lRenderer.AxisValueToPixel(TriggerAxis, fComponent.TriggerLevel,
    lRect.Bottom, lRect.Top);
  if (lY < lRect.Top) or (lY > lRect.Bottom) then Exit;
  glColor3f(1, 0, 0);
  glLineWidth(1.5);
  glLineStipple(1, $00FF);
  glEnable(GL_LINE_STIPPLE);
  glBegin(GL_LINES);
  glVertex2f(lRect.Left, lY);
  glVertex2f(lRect.Right, lY);
  glEnd;
  glDisable(GL_LINE_STIPPLE);
  glLineWidth(1);
end;

function TRecorderOglOscillogram.TriggerLevelHit(AX, AY: Integer): Boolean;
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  lY: Single;
begin
  Result := False;
  if (fComponent = nil) or (fChart = nil) or (fPage = nil) or
     (fLevelCursorCheck = nil) or not fLevelCursorCheck.Checked then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if (lRenderer = nil) or (TriggerAxis = nil) then Exit;
  lRect := lRenderer.GetPageContentRect(TChartPage(fPage));
  if (AX < lRect.Left) or (AX > lRect.Right) or
     (AY < lRect.Top) or (AY > lRect.Bottom) then Exit;
  lY := lRenderer.AxisValueToPixel(TriggerAxis, fComponent.TriggerLevel,
    lRect.Bottom, lRect.Top);
  Result := Abs(AY - lY) <= 6;
end;

procedure TRecorderOglOscillogram.SetTriggerLevelFromPixel(AY: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
begin
  if (fComponent = nil) or (fChart = nil) or (fPage = nil) or
     (fAxis = nil) then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  lRect := lRenderer.GetPageContentRect(TChartPage(fPage));
  AY := Max(lRect.Top, Min(AY, lRect.Bottom));
  fComponent.TriggerLevel := lRenderer.PixelToAxisValue(TriggerAxis,
    AY, lRect.Bottom, lRect.Top);
  fLevelEdit.Text := FormatSignificant(fComponent.TriggerLevel);
  fChart.Invalidate;
end;

procedure TRecorderOglOscillogram.ChartMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and not (ssCtrl in Shift) then
  begin
    fDraggingXCursor := XCursorHit(X, Y);
    if fDraggingXCursor >= 0 then
    begin
      fChart.MouseInputEnabled := False;
      SetXCursorFromPixel(fDraggingXCursor, X);
      Exit;
    end;
  end;
  if (Button <> mbLeft) or (ssCtrl in Shift) or
     not TriggerLevelHit(X, Y) then Exit;
  fDraggingLevel := True;
  fChart.MouseInputEnabled := False;
  SetTriggerLevelFromPixel(Y);
end;

procedure TRecorderOglOscillogram.ChartMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (fDraggingXCursor >= 0) and (ssLeft in Shift) then
    SetXCursorFromPixel(fDraggingXCursor, X);
  if (fDraggingXCursor >= 0) or (XCursorHit(X, Y) >= 0) then
  begin
    fChart.Cursor := crSizeWE;
    Exit;
  end;
  if fDraggingLevel and (ssLeft in Shift) then
    SetTriggerLevelFromPixel(Y);
  if fDraggingLevel or TriggerLevelHit(X, Y) then
    fChart.Cursor := crSizeNS;
end;

procedure TRecorderOglOscillogram.ChartMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (fDraggingXCursor >= 0) then
  begin
    SetXCursorFromPixel(fDraggingXCursor, X);
    fDraggingXCursor := -1;
    fChart.MouseInputEnabled := True;
    Exit;
  end;
  if (Button = mbLeft) and fDraggingLevel then
  begin
    SetTriggerLevelFromPixel(Y);
    fDraggingLevel := False;
    fChart.MouseInputEnabled := True;
    fTriggerArmed := False;
    fTriggerHasFrame := False;
    fHasDataSignature := False;
    Refresh(fTagRegistry, CurrentDisplaySeconds);
  end;
  DetectManualRange;
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
  lTrend: cLineSeries;
  lDataSignature: QWord;
  lSignatureTag: TRecorderTag;
  lViewChanged: Boolean;
  lPluginFrame: TRecorderPluginOscillogramFrame;
  lAxisCenter: Double;
  lAxisHalfRange: Double;
  lAxisBaseMin: Double;
  lAxisBaseMax: Double;
  lTriggerTag: TRecorderTag;
  lTriggerCount: Integer;
  lTriggerSearchEnd: Double;
  lTriggerIndex: Integer;
  lTriggered: Boolean;
  lDisplayEnd: Double;
  lNewestTime: Double;
  lLatestTime: Double;
  lHasSamples: Boolean;
  lPrimaryTag: TRecorderTag;
  lTriggerMean: Double;
  lAxisIndex: Integer;
  lPluginMean: Double;
  lPluginIndex: Integer;
  lWindowSeconds: Double;
  lPreRollSeconds: Double;
begin
  { The chart applies pan/zoom after our OnMouseUp handler, so inspect the
    viewport again before the next data update can apply automatic ranges. }
  DetectManualRange;
  if (fComponent <> nil) and (fComponent.XScale > 0) then
    ADisplaySeconds := fComponent.XScale;
  if fAutoRange then
    for I := 0 to High(fAxisRangeInitialized) do
      fAxisRangeInitialized[I] := False;
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;
  lWindowSeconds := ADisplaySeconds;
  if (fComponent <> nil) and fComponent.TriggerEnabled and
    TChartPage(fPage).ZoomedX then
    lWindowSeconds := TChartPage(fPage).XMaxValue -
      TChartPage(fPage).XMinValue;
  if (lWindowSeconds <= 0) or (lWindowSeconds > ADisplaySeconds) then
    lWindowSeconds := ADisplaySeconds;
  lPreRollSeconds := 0;
  if (fComponent <> nil) and fComponent.TriggerEnabled then
    lPreRollSeconds := lWindowSeconds *
      fComponent.TriggerPreRollPercent / 100.0;
  if fFpsMeasureEnabled <> AMeasureFps then
    ResetFpsMeasure;
  fFpsMeasureEnabled := AMeasureFps;
  { GLListID у OglChart уже является штатным needRecompile. Не заменяем точки,
    пока данные всех линий и окно отображения прежние. }
  lDataSignature := QWord($CBF29CE484222325);
  lSignatureTag := ResolveTag(ATagRegistry);
  if lSignatureTag <> nil then
    lDataSignature := (lDataSignature xor QWord(lSignatureTag.Id)) +
      (lSignatureTag.SignalBuffer.Revision shl 1);
  for I := 0 to fExtraLines.Count - 1 do
  begin
    lLine := TRecorderTrendLine(fExtraLines[I]);
    if not lLine.Visible then
      Continue;
    lSignatureTag := RecorderResolveTag(ATagRegistry, lLine.TagId,
      lLine.TagName);
    if lSignatureTag <> nil then
      lDataSignature := ((lDataSignature shl 5) or
        (lDataSignature shr 59)) xor
        (QWord(lSignatureTag.Id) + lSignatureTag.SignalBuffer.Revision);
  end;
  if (fComponent <> nil) and fComponent.TriggerEnabled then
  begin
    lSignatureTag := ResolveTagByName(ATagRegistry,
      fComponent.TriggerTagName);
    if lSignatureTag <> nil then
      lDataSignature := lDataSignature xor
        (QWord(lSignatureTag.Id) + lSignatureTag.SignalBuffer.Revision);
  end;
  lViewChanged := ClampOscillogramPageX(TChartPage(fPage), ADisplaySeconds);
  if fHasDataSignature and (fLastDataSignature = lDataSignature) and
    (Abs(fLastSignatureDisplaySeconds - ADisplaySeconds) <= 1E-12) then
  begin
    if lViewChanged and (fChart is TOglChart) then
      TOglChart(fChart).Redraw;
    Exit;
  end;
  fHasDataSignature := True;
  fLastDataSignature := lDataSignature;
  fLastSignatureDisplaySeconds := ADisplaySeconds;
  if not TChartPage(fPage).ZoomedX then
  begin
    SetXRange(ADisplaySeconds);
    TChartPage(fPage).PresetMinXValue := 0;
    TChartPage(fPage).PresetMaxXValue := ADisplaySeconds;
  end;
  ClampOscillogramPageX(TChartPage(fPage), ADisplaySeconds);
  EnsureTrendCount;
  if Length(fLineSnapshots) <> 1 + fExtraLines.Count then
    SetLength(fLineSnapshots, 1 + fExtraLines.Count);
  if fTrend = nil then
    Exit;
  fPluginMetricsValid := False;
  lTag := ResolveTag(ATagRegistry);
  if lTag = nil then
  begin
    if fComponent <> nil then
    begin
      lPluginFrame := Default(TRecorderPluginOscillogramFrame);
      lPluginFrame.Size := SizeOf(lPluginFrame);
      lPluginFrame.DisplaySeconds := ADisplaySeconds;
      RecorderPluginRepaint(fComponent, @lPluginFrame);
    end;
    fCurrentTagName := '';
    SetChartTitle(Format('No tag frame:%d', [fFrameNo]));
    if not TChartAxis(fAxis).HasPresetRange then
      SetAxisRange(-1, 1);
    UpdateInfoLabel(ATagRegistry, nil);
    RefreshLegendValues;
    if fChart is TOglChart then
      TOglChart(fChart).Redraw;
    Exit;
  end;

  lPrimaryTag := lTag;
  if fYAxisTagId <> lPrimaryTag.Id then
  begin
    fYAxisTagId := lPrimaryTag.Id;
    fYRangeInitialized := False;
    for I := 0 to High(fAxisRangeInitialized) do
      fAxisRangeInitialized[I] := False;
  end;
  fCurrentTagName := lPrimaryTag.Name;
  lHasSamples := lPrimaryTag.SignalBuffer.Count > 0;
  lNewestTime := lPrimaryTag.SignalBuffer.LatestTime;
  lDisplayEnd := lNewestTime;
  for I := 0 to fExtraLines.Count - 1 do
  begin
    lLine := TRecorderTrendLine(fExtraLines[I]);
    if not lLine.Visible then
      Continue;
    lTag := RecorderResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);
    if (lTag = nil) or (lTag.SignalBuffer.Count = 0) then
      Continue;
    lLatestTime := lTag.SignalBuffer.LatestTime;
    if (not lHasSamples) or (lLatestTime > lNewestTime) then
      lNewestTime := lLatestTime;
    lHasSamples := True;
  end;
  if lHasSamples then
  begin
    lDisplayEnd := lNewestTime;
    if (lPrimaryTag.SignalBuffer.Count > 0) and
      (lPrimaryTag.SignalBuffer.LatestTime >= lNewestTime - ADisplaySeconds) then
      lDisplayEnd := Min(lDisplayEnd, lPrimaryTag.SignalBuffer.LatestTime);
    for I := 0 to fExtraLines.Count - 1 do
    begin
      lLine := TRecorderTrendLine(fExtraLines[I]);
      if not lLine.Visible then
        Continue;
      lTag := RecorderResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);
      if (lTag = nil) or (lTag.SignalBuffer.Count = 0) then
        Continue;
      lLatestTime := lTag.SignalBuffer.LatestTime;
      if lLatestTime >= lNewestTime - ADisplaySeconds then
        lDisplayEnd := Min(lDisplayEnd, lLatestTime);
    end;
    lDisplayStart := lDisplayEnd - ADisplaySeconds;
  end
  else
  begin
    lDisplayStart := 0;
    fLineSnapshots[0].Count := 0;
  end;
  lTag := lPrimaryTag;
  lTriggered := False;
  if (fComponent <> nil) and fComponent.TriggerEnabled then
  begin
    if Trim(fComponent.TriggerTagName) = '' then
      lTriggerTag := lPrimaryTag
    else
      lTriggerTag := ResolveTagByName(ATagRegistry,
        fComponent.TriggerTagName);
    if lTriggerTag = nil then
    begin
      fTriggerArmed := False;
      fTriggerHasFrame := False;
      Exit;
    end;
    if not fTriggerArmed then
    begin
      { После включения ждём новое пересечение, а не используем старый
        кадр, случайно оставшийся в кольце. }
      fLastTriggerTime := lTriggerTag.SignalBuffer.LatestTime;
      fTriggerArmed := True;
      Exit;
    end;
    lTriggerTag.CopyLatestInto(ADisplaySeconds * 3,
      fTriggerTimes, fTriggerValues, lTriggerCount, lTriggerSearchEnd);
    lTriggered := False;
    if lTriggerCount > 1 then
    begin
      lTriggerMean := 0;
      if fComponent.ClosedInput then
      begin
        for lTriggerIndex := 0 to lTriggerCount - 1 do
          lTriggerMean := lTriggerMean + fTriggerValues[lTriggerIndex];
        lTriggerMean := lTriggerMean / lTriggerCount;
      end;
      lTriggerSearchEnd := Min(fTriggerTimes[lTriggerCount - 1],
        lDisplayEnd) - (lWindowSeconds - lPreRollSeconds);
      for lTriggerIndex := 1 to lTriggerCount - 1 do
        if (fTriggerTimes[lTriggerIndex] > fLastTriggerTime) and
          ((not fTriggerHasFrame) or
            (fTriggerTimes[lTriggerIndex] >=
              fLastTriggerTime + lWindowSeconds)) and
          (fTriggerTimes[lTriggerIndex] <= lTriggerSearchEnd) and
          (fTriggerValues[lTriggerIndex - 1] - lTriggerMean < fComponent.TriggerLevel) and
          (fTriggerValues[lTriggerIndex] - lTriggerMean >= fComponent.TriggerLevel) then
        begin
          lDisplayStart := fTriggerTimes[lTriggerIndex];
          lTriggered := True;
        end;
    end;
    if not lTriggered then
      Exit;
    fLastTriggerTime := lDisplayStart;
    fTriggerHasFrame := True;
    lDisplayStart := lDisplayStart - lPreRollSeconds;
    { Источник остаётся полным кольцевым буфером; только видимое окно
      пересчитывается относительно его левой границы. }
    TChartPage(fPage).XMinValue := 0;
    TChartPage(fPage).XMaxValue := lWindowSeconds;
    TChartPage(fPage).PresetMinXValue := 0;
    TChartPage(fPage).PresetMaxXValue := ADisplaySeconds;
    TChartPage(fPage).ZoomedX := lWindowSeconds < ADisplaySeconds;
  end;
  Inc(fFrameNo);
  lTag.SnapshotRangeInto(lDisplayStart, False,
    fLineSnapshots[0].Times, fLineSnapshots[0].Values,
    fLineSnapshots[0].Count);
  while (fLineSnapshots[0].Count > 0) and
    (fLineSnapshots[0].Times[fLineSnapshots[0].Count - 1] >
      lDisplayStart + lWindowSeconds) do
    Dec(fLineSnapshots[0].Count);
  lSnapshot := fLineSnapshots[0];
  if fComponent <> nil then
  begin
    lPluginFrame := Default(TRecorderPluginOscillogramFrame);
    lPluginFrame.Size := SizeOf(lPluginFrame);
    lPluginFrame.SampleCount := lSnapshot.Count;
    lPluginFrame.DisplaySeconds := lWindowSeconds;
    if lSnapshot.Count > 0 then
    begin
      if fComponent.ClosedInput then
      begin
        if Length(fPluginValues) < lSnapshot.Count then
          SetLength(fPluginValues, lSnapshot.Count);
        lPluginMean := 0;
        for lPluginIndex := 0 to lSnapshot.Count - 1 do
          lPluginMean := lPluginMean + lSnapshot.Values[lPluginIndex];
        lPluginMean := lPluginMean / lSnapshot.Count;
        for lPluginIndex := 0 to lSnapshot.Count - 1 do
          fPluginValues[lPluginIndex] :=
            lSnapshot.Values[lPluginIndex] - lPluginMean;
        lPluginFrame.Values := @fPluginValues[0];
      end
      else
        lPluginFrame.Values := @lSnapshot.Values[0];
    end;
    fPluginMetricsValid := RecorderPluginRepaint(fComponent, @lPluginFrame) and
      (lSnapshot.Count > 0);
    if fPluginMetricsValid then
    begin
      fPluginPeak := Max(Abs(lPluginFrame.MinValue),
        Abs(lPluginFrame.MaxValue));
      fPluginRms := lPluginFrame.RmsValue;
    end;
  end;
  SetChartTitle(Format('%s frame:%d', [lTag.Name, fFrameNo]));
  lHasRange := False;
  for I := 0 to High(fAxisHasRange) do
    fAxisHasRange[I] := False;
  lPointCount := 0;
  lTrend := GetTrendByIndex(0);
  FillTrendFromSnapshot(lTrend, lSnapshot, lDisplayStart, lWindowSeconds,
    lMinValue, lMaxValue, lPointCount);
  if lPointCount > 0 then
  begin
    lHasRange := True;
    lAxisIndex := 0;
    if fComponent <> nil then
      lAxisIndex := fComponent.PrimaryAxisIndex;
    AccumulateAxisRange(Max(0, Min(lAxisIndex, High(fAxes))),
      lMinValue, lMaxValue, lPointCount);
  end;
  for I := 0 to fExtraLines.Count - 1 do
  begin
    lLine := TRecorderTrendLine(fExtraLines[I]);
    lTrend := GetTrendByIndex(I + 1);
    if lTrend = nil then
      Continue;
    if not lLine.Visible then
    begin
      lTrend.ClearPoints;
      Continue;
    end;
    lTag := RecorderResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);
    if lTag = nil then
    begin
      lTrend.ClearPoints;
      Continue;
    end;
    lTag.SnapshotRangeInto(lDisplayStart, False,
      fLineSnapshots[I + 1].Times, fLineSnapshots[I + 1].Values,
      fLineSnapshots[I + 1].Count);
    while (fLineSnapshots[I + 1].Count > 0) and
      (fLineSnapshots[I + 1].Times[fLineSnapshots[I + 1].Count - 1] >
        lDisplayStart + lWindowSeconds) do
      Dec(fLineSnapshots[I + 1].Count);
    lSnapshot := fLineSnapshots[I + 1];
    FillTrendFromSnapshot(lTrend, lSnapshot, lDisplayStart, lWindowSeconds,
      lLineMin, lLineMax, lLinePoints);
    if lLinePoints = 0 then
      Continue;
    AccumulateAxisRange(Max(0, Min(lLine.AxisIndex, High(fAxes))),
      lLineMin, lLineMax, lLinePoints);
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

  for I := 0 to High(fAxes) do
  begin
    if fAxisHasRange[I] and not fAxisRangeInitialized[I] then
    begin
      lTag := nil;
      if (fComponent <> nil) and (fComponent.PrimaryAxisIndex = I) then
        lTag := lPrimaryTag;
      if fAutoRange then
      begin
        fAxes[I].HasPresetRange := False;
        ApplyOscillogramTagYRange(fAxes[I], nil,
          fAxisMin[I], fAxisMax[I]);
      end
      else
        ApplyOscillogramTagYRange(fAxes[I], lTag,
          fAxisMin[I], fAxisMax[I]);
      fAxisRangeInitialized[I] := True;
    end;
    if fAutoRange then Continue;
    if (fComponent = nil) or (I >= fComponent.AxisCount) or
      (fComponent.Axes[I].YScale <= 0) or fAxes[I].HasPresetRange then
      Continue;
    lAxisBaseMin := fAxes[I].PresetMinValue;
    lAxisBaseMax := fAxes[I].PresetMaxValue;
    lAxisCenter := (lAxisBaseMin + lAxisBaseMax) / 2 +
      fComponent.Axes[I].YOffset;
    lAxisHalfRange := (lAxisBaseMax - lAxisBaseMin) *
      fComponent.Axes[I].YScale / 2;
    fAxes[I].MinValue := lAxisCenter - lAxisHalfRange;
    fAxes[I].MaxValue := lAxisCenter + lAxisHalfRange;
  end;
  fYRangeInitialized := fAxisRangeInitialized[0];
  if fAutoRange then
  begin
    if Length(fAppliedYMin) <> Length(fAxes) then
      SetLength(fAppliedYMin, Length(fAxes));
    if Length(fAppliedYMax) <> Length(fAxes) then
      SetLength(fAppliedYMax, Length(fAxes));
    for I := 0 to High(fAxes) do
    begin
      fAppliedYMin[I] := fAxes[I].MinValue;
      fAppliedYMax[I] := fAxes[I].MaxValue;
    end;
    fAppliedXMin := TChartPage(fPage).XMinValue;
    fAppliedXMax := TChartPage(fPage).XMaxValue;
    fAutoRangeApplied := True;
  end;
  UpdateInfoLabel(ATagRegistry, ResolveTag(ATagRegistry));
  RefreshLegendValues;
  { MIC-140 stream debug: oscillogram render diag suppressed.
  RecorderDebugLog(Format('Ogl osc render: tag=%s points=%d lines=%d frame=%d window=%.3f',
    [fCurrentTagName, lPointCount, 1 + fExtraLines.Count, fFrameNo, ADisplaySeconds])); }
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

procedure TRecorderOglOscillogram.ResetSessionData;
var
  I: Integer;
  lTrend: cLineSeries;
  lPage: TChartPage;
  lAxis: TChartAxis;
begin
  for I := 0 to fExtraLines.Count do
  begin
    lTrend := GetTrendByIndex(I);
    if lTrend <> nil then
      lTrend.ClearPoints;
  end;
  lPage := TChartPage(fPage);
  lAxis := TChartAxis(fAxis);
  if lPage <> nil then
  begin
    lPage.ZoomedX := False;
    if lPage.PresetMaxXValue > lPage.PresetMinXValue then
    begin
      lPage.XMinValue := lPage.PresetMinXValue;
      lPage.XMaxValue := lPage.PresetMaxXValue;
    end;
  end;
  for I := 0 to High(fAxes) do
  begin
    fAxes[I].HasPresetRange := False;
    fAxisRangeInitialized[I] := False;
  end;
  fYRangeInitialized := False;
  fTriggerArmed := False;
  fTriggerHasFrame := False;
  fHasDataSignature := False;
  fCurrentTagName := '';
  ResetFpsMeasure;
  if Visible and (fChart <> nil) then
    fChart.Redraw;
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
  if RefreshRangeCaptions then
    fChart.Invalidate;
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
var
  I: Integer;
  lActiveCount: Integer;
  lActiveIndex: Integer;
  lSelectedActiveIndex: Integer;
  lCurrentActiveIndex: Integer;
  lSelectedTag: TRecorderTag;
  lTag: TRecorderTag;
begin
  Result := nil;
  if (ATagRegistry = nil) or (ATagRegistry.TagCount = 0) then
    Exit;

  { Базовая страница назначает графики автоматически, поэтому отключённый
    аппаратный источник не должен занимать страницу старым буфером. Настройки
    тегов не меняются: после восстановления источника тег снова попадёт в цикл. }
  lActiveCount := 0;
  for I := 0 to ATagRegistry.TagCount - 1 do
    if RecorderTagSourceIsVisible(ATagRegistry, ATagRegistry.Tags[I]) then
      Inc(lActiveCount);
  if lActiveCount = 0 then
    Exit;

  { Первая осциллограмма начинается с выделенного в списке каналов тега.
    Следующие страницы получают последующие активные теги с циклическим
    переходом к началу списка. }
  lSelectedTag := ATagRegistry.SelectedTag;
  lSelectedActiveIndex := 0;
  lCurrentActiveIndex := 0;
  if (lSelectedTag <> nil) and
    RecorderTagSourceIsVisible(ATagRegistry, lSelectedTag) then
    for I := 0 to ATagRegistry.TagCount - 1 do
    begin
      lTag := ATagRegistry.Tags[I];
      if not RecorderTagSourceIsVisible(ATagRegistry, lTag) then
        Continue;
      if lTag = lSelectedTag then
      begin
        lSelectedActiveIndex := lCurrentActiveIndex;
        Break;
      end;
      Inc(lCurrentActiveIndex);
    end;

  lActiveIndex := (lSelectedActiveIndex + AIndex) mod lActiveCount;
  for I := 0 to ATagRegistry.TagCount - 1 do
  begin
    lTag := ATagRegistry.Tags[I];
    if not RecorderTagSourceIsVisible(ATagRegistry, lTag) then
      Continue;
    if lActiveIndex = 0 then
      Exit(lTag);
    Dec(lActiveIndex);
  end;
end;

function TRecorderOglOscillogramSurface.RefreshRangeCaptions: Boolean;
var
  I, lSeparator: Integer;
  lAxis: TChartAxis;
  lCaption, lPrefix: string;
  lPage: TChartPage;
begin
  Result := False;
  for I := 0 to fCount - 1 do
  begin
    lPage := GetPage(I);
    lAxis := GetAxis(I);
    if (lPage = nil) or (lAxis = nil) then Continue;
    lSeparator := LastDelimiter('|', lPage.Caption);
    if lSeparator > 0 then
      lPrefix := TrimRight(Copy(lPage.Caption, 1, lSeparator - 1))
    else
      lPrefix := lPage.Caption;
    lCaption := Format('%s | dY=%s', [lPrefix, FormatSignificant(
      lAxis.MaxValue - lAxis.MinValue)]);
    if lPage.Caption <> lCaption then
    begin
      lPage.Caption := lCaption;
      Result := True;
    end;
  end;
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
  AAxis: TChartAxis; ATag: TRecorderTag);
var
  lEstimateText: string;
  lTagName: string;
  lDeltaText: string;
begin
  if APage = nil then
    Exit;
  if ATag <> nil then
    lTagName := ATag.Name
  else
    lTagName := 'None';
  lEstimateText := FormatEnabledEstimateCaption(ATag);
  if AAxis <> nil then
    lDeltaText := Format('dY=%s', [FormatSignificant(
      AAxis.MaxValue - AAxis.MinValue)])
  else
    lDeltaText := 'dY=-';
  if lEstimateText <> '' then
    APage.Caption := Format('%s | %s | %s',
      [lTagName, lEstimateText, lDeltaText])
  else
    APage.Caption := Format('%s | %s', [lTagName, lDeltaText]);
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
    { Для базовой страницы действует тот же сброс по текущему кадру +20%,
      что и для осциллограммы на редактируемой странице. }
    lPage.AutoScaleOnZoomReset := True;
    lPage.FillColor := $FFFFFFFF;
    lPage.BorderColor := $FF808080;
    lTabSpace.Left := 42;
    lTabSpace.Top := 30;
    lTabSpace.Right := 10;
    lTabSpace.Bottom := 24;
    lPage.PixelTabSpace := lTabSpace;
    lPage.XMinValue := 0;
    lPage.XMaxValue := ADisplaySeconds;
    lPage.PresetMinXValue := 0;
    lPage.PresetMaxXValue := ADisplaySeconds;
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
  lDataChanged: Boolean;
  lViewChanged: Boolean;
  lRevision: QWord;
begin
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;
  if fFpsMeasureEnabled <> AMeasureFps then
    ResetFpsMeasure;
  fFpsMeasureEnabled := AMeasureFps;
  fDisplaySeconds := ADisplaySeconds;
  lViewChanged := False;
  for I := 0 to fCount - 1 do
    lViewChanged := ClampOscillogramPageX(GetPage(I), ADisplaySeconds) or
      lViewChanged;
  lDataChanged := (not fHasDataRevision) or
    (Abs(fLastRevisionDisplaySeconds - ADisplaySeconds) > 1E-12) or
    (Length(fLastDataRevisions) <> fCount);
  if Length(fLastDataRevisions) <> fCount then
    SetLength(fLastDataRevisions, fCount);
  if Length(fSnapshots) <> fCount then
    SetLength(fSnapshots, fCount);
  for I := 0 to fCount - 1 do
  begin
    lTag := ResolveTag(ATagRegistry, I);
    if lTag <> nil then
      lRevision := lTag.BlockCounter
    else
      lRevision := 0;
    if fLastDataRevisions[I] <> lRevision then
      lDataChanged := True;
    fLastDataRevisions[I] := lRevision;
  end;
  fHasDataRevision := True;
  fLastRevisionDisplaySeconds := ADisplaySeconds;
  if not lDataChanged then
  begin
    if lViewChanged then
      fChart.Redraw;
    Exit;
  end;
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
    ClampOscillogramPageX(lPage, ADisplaySeconds);
    lTrend.ClearValues;
    lTrend.X0 := 0;
    lTrend.DX := 1;
    lTag := ResolveTag(ATagRegistry, I);
    if lTag = nil then
    begin
      SetAxisRange(lAxis, -1, 1);
      UpdatePageCaption(lPage, lAxis, lTag);
      Continue;
    end;

    lTag.CopyLatestInto(ADisplaySeconds, fSnapshots[I].Times,
      fSnapshots[I].Values, fSnapshots[I].Count, lDisplayStart);
    lSnapshot := fSnapshots[I];
    if lSnapshot.Count = 0 then
    begin
      SetAxisRange(lAxis, -1, 1);
      UpdatePageCaption(lPage, lAxis, lTag);
      Continue;
    end;

    lFirst := True;
    lPointCount := 0;
    for lValueIndex := 0 to lSnapshot.Count - 1 do
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

      Inc(lPointCount);
    end;
    lTrend.ReplaceValues(lSnapshot.Values, 0, lSnapshot.Count);

    if lPointCount = 0 then
      SetAxisRange(lAxis, -1, 1)
    else
      ApplyOscillogramTagYRange(lAxis, lTag, lMinValue, lMaxValue);
    UpdatePageCaption(lPage, lAxis, lTag);
  end;

  { MIC-140 stream debug: oscillogram surface render diag suppressed.
  RecorderDebugLog(Format('Ogl surface render: charts=%d frame=%d window=%.3f',
    [fCount, fFrameNo, ADisplaySeconds])); }
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
