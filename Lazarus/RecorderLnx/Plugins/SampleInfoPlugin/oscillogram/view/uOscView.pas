unit uOscView;

{ Plugin-owned Oscillogram and base-surface view. Models, data facades and all
  interaction/render policy stay inside this plugin. No RecorderLnx Core/UI
  object or chart object may cross the flat SDK boundary. }
{$mode objfpc}{$H+}
{$codepage UTF8}
interface

uses
  Classes, Controls, ExtCtrls, StdCtrls, Graphics, Forms, ComCtrls, Menus,
  ImgList, Grids,
  uOglChart, uOglChartChart, uOglChartPage, uOglChartAxis,
  uOglChartCursor,
  uOglChartDrawObj,
  uOglChartTrend, uOglChartTypes, uOscModel, uOscTags, uOscBehavior,
  uOglChartColors, uOscUnits, uOscIconIds;
type
  TOscLegendSplitter = class(TSplitter)
  private
    fOnDragStarted: TNotifyEvent;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  published
    property OnDragStarted: TNotifyEvent read fOnDragStarted
      write fOnDragStarted;
  end;

  { TOscView
    Plugin-owned frame loaded from uOscView.lfm. The resource owns static
    controls; this class owns chart data, binding state and interaction. }
  TOscView = class(TFrame)
  published
    fToolBar: TToolBar;
    fToolImages: TImageList;
    fLevelButton: TToolButton;
    fAutoRangeButton: TToolButton;
    fXCursorButton: TToolButton;
    fLegendButton: TToolButton;
    fLegendHostPanel: TPanel;
    fLegendPanel: TScrollBox;
    fLegendSplitter: TOscLegendSplitter;
    fLegendGrid: TStringGrid;
    fXCursorMenu: TPopupMenu;
    CursorSingle: TMenuItem;
    CursorDouble: TMenuItem;
    procedure LegendPanelResize(Sender: TObject);
    procedure LegendGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LegendGridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LegendSplitterDragStarted(Sender: TObject);
    procedure LegendSplitterMoved(Sender: TObject);
    procedure LegendPrepareCanvas(Sender: TObject; ACol, ARow: Integer;
      AState: TGridDrawState);
    procedure LegendDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure PaintToolButton(Sender: TToolButton; State: Integer);
    procedure ToolButtonClick(Sender: TObject);
    procedure XCursorModeClick(Sender: TObject);
    fChart: TOglChart;
    fInfoPanel: TPanel;
    fControlPanel: TScrollBox;
    fSignalPanel: TPanel;
    fSignalLabel: TLabel;
    fSignalSplitter: TSplitter;
    fSignalGrid: TStringGrid;
    fXScaleEdit: TEdit;
    fXScaleSpin: TUpDown;
    fYScaleEdit: TEdit;
    fYScaleSpin: TUpDown;
    fOffsetEdit: TEdit;
    fTriggerCheck: TCheckBox;
    fTriggerFallingCheck: TCheckBox;
    fLevelEdit: TEdit;
    fPreRollEdit: TEdit;
    fClosedInputCheck: TCheckBox;
    fLevelCursorCheck: TCheckBox;
    procedure SignalGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ControlValueEdited(Sender: TObject);
    procedure TriggerChanged(Sender: TObject);
    procedure TriggerEdgeChanged(Sender: TObject);
    procedure ClosedInputChanged(Sender: TObject);
    procedure ScaleSpinClick(Sender: TObject; Button: TUDBtnType);
    procedure ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
    procedure ChartCursorChanged(Sender: TObject; ACursor: TObject);
  private
    fAbsoluteTagId: Int64;
    fAbsoluteTagName: string;
    fBindingMode: TOscBindingMode;
    fCurrentTagName: string;
    fComponent: TOscModel;
    fPluginCapabilities: QWord;
    fActiveSeriesIndex: Integer;
    fLegendColumnWidthsBeforeDrag: array[0..6] of Integer;
    fLegendColumnWidths: array[0..6] of Integer;
    fLegendUserSizedColumns: Boolean;
    fLegendLastRowCount: Integer;
    fLegendManualHeight: Integer;
    fLegendUserResized: Boolean;
    fLegendSplitterDragging: Boolean;
    fXCursorCount: Integer;
    fXCursorsInitialized: Boolean;
    fAutoRange: Boolean;
    fAutoRangeApplied: Boolean;
    fAppliedXMin, fAppliedXMax: Double;
    fAppliedYMin, fAppliedYMax: array of Double;
    fDraggingLevel: Boolean;
    fYRangeInitialized: Boolean;
    fYAxisTagId: Int64;
    fTagRegistry: TOscTagRegistry;
    fUpdatingControls: Boolean;
    fPluginMetricsValid: Boolean;
    fPluginPeak: Double;
    fPluginRms: Double;
    fPluginValues: TOscDoubleArray;
    fTriggerTimes: TOscDoubleArray;
    fTriggerValues: TOscDoubleArray;
    fTriggerArmed: Boolean;
    fTriggerHasFrame: Boolean;
    fLastTriggerTime: Double;
    fTriggerHoldUntil: Double;
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
    fDyLabel: TLabel;
    fInfoNextLeft: Integer;
    fTagOffset: Integer;
    fTagSlotIndex: Integer;
    fExtraLines: TList;
    fUnitNames: TStringList;
    fUnitCatalog: TOscUnitCatalog;
    fLineSnapshots: array of TOscSignalSnapshot;
    fLinePoints: array of TChartPoint;
    fModel: TObject;
    fPage: TObject;
    fAxis: TObject;
    fAxes: array of TChartAxis;
    fAxisSourceUnits: array of string;
    fAxisHasSourceUnit: array of Boolean;
    fAxisUnitDirty: array of Boolean;
    fSeries: array of cLineSeries;
    fMaximaIndices: array of array of Integer;
    fMinimaIndices: array of array of Integer;
    fMaximaCounts: array of Integer;
    fMinimaCounts: array of Integer;
    fAxisRangeInitialized: array of Boolean;
    fAxisHasRange: array of Boolean;
    fAxisMin: array of Double;
    fAxisMax: array of Double;
    fTrend: TObject;
    procedure InitControlPanel;
    procedure InitToolBar;
    procedure UpdateLegend;
    procedure UpdateLegendLayout;
    procedure RefreshLegendValues;
    function LegendValueAt(ASeries: cLineSeries; AX: Double;
      out AValue: Double): Boolean;
    procedure EnsureXCursorsInitialized;
    function PageCursor: TChartCursor;
    procedure RebuildExtremaCaches;
    function ActiveAxisIndex: Integer;
    function ActiveChartAxis: TChartAxis;
    function ActiveModelAxis: TOscAxis;
    procedure ActivateFirstSeriesOnAxis(AAxis: TChartAxis);
    procedure UpdateActiveSeriesRenderPriority;
    function UpdateAxisDisplayUnits: Boolean;
    procedure UpdateAxisSourceUnits;
    function TagForAxis(AAxisIndex: Integer): TOscTag;
    procedure UpdateSignalGrid;
    procedure DetectManualRange;
    procedure ApplyActiveYScale;
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
    procedure SyncViewportControls(AForceY: Boolean = False);
    procedure EnsureTrendCount;
    procedure AccumulateAxisRange(AAxisIndex: Integer; AMinValue,
      AMaxValue: Double; APointCount: Integer);
    function TriggerAxis: TChartAxis;
    procedure FillTrendFromSnapshot(ATrend: cLineSeries;
      const ASnapshot: TOscSignalSnapshot; ADisplayStart: Double;
      ADisplaySeconds: Double; out AMinValue, AMaxValue: Double;
      out APointCount: Integer);
    function GetTrendByIndex(AIndex: Integer): cLineSeries;
    function TrendLabelColor(AIndex: Integer): TColor;
    function ResolveTag(ATagRegistry: TOscTagRegistry): TOscTag;
    function ResolveTagByName(ATagRegistry: TOscTagRegistry;
      const ATagName: string): TOscTag;
    procedure LoadPluginCapabilities;
    function HasPluginCapability(ACapability: QWord): Boolean;
    function DispatchComponentEvent(const AName, AControlId: string;
      AValue1: Double = 0; AValue2: Double = 0; AIntValue: Int64 = 0;
      AFlags: QWord = 0): Boolean;
    procedure ResetFpsMeasure;
    procedure SyncLinesFromComponent(AComponent: TOscModel);
    procedure SetAxisRange(AMinValue, AMaxValue: Double);
    procedure SetChartTitle(const ATitle: string);
    procedure SetXRange(ADisplaySeconds: Double);
    procedure ClearInfoPanel;
    procedure AppendInfoPart(const AText: string; AColor: TColor);
    procedure UpdateInfoLabel(ATagRegistry: TOscTagRegistry; ATag: TOscTag);
  public
    { IVForm }
    procedure Configure(AComponent: TOscModel; ATagRegistry: TOscTagRegistry);
    procedure RefreshControl(ATagRegistry: TOscTagRegistry; ADisplaySeconds: Double);
    function GetChartControl: TOglChart;

    constructor Create(AOwner: TComponent); override;
    procedure SetUnitCatalog(ACatalog: TOscUnitCatalog);
    procedure PrepareHistoryBuffers(ADisplaySeconds: Double);
    property UnitCatalog: TOscUnitCatalog read fUnitCatalog write SetUnitCatalog;
    procedure Resize; override;
    destructor Destroy; override;

    { Creates the inner OpenGL chart, model, page, axis and trend. }
    procedure ConfigureDefault;

    { Refreshes chart data from the tag registry.
      ATagRegistry     - source tag registry.
      ADisplaySeconds  - visible time window in seconds.
      AMeasureFps      - True only while RecorderLnx measures display-loop FPS. }
    procedure Refresh(ATagRegistry: TOscTagRegistry;
      ADisplaySeconds: Double; AMeasureFps: Boolean = False);
    { Clears data and user zoom state at an acquisition-session boundary. }
    procedure ResetSessionData;
    { Forces an immediate LCL/OpenGL repaint after a page becomes visible.
      This is used on tab switching: OpenGL controls can keep an invalidated
      back buffer until the next window message, while Recorder users expect the
      formular to be fully drawn immediately after activation. }
    procedure ForceRepaint;

    property AbsoluteTagName: string read fAbsoluteTagName write fAbsoluteTagName;
    property BindingMode: TOscBindingMode read fBindingMode write fBindingMode;
    property ChartControl: TOglChart read fChart;
    property TagOffset: Integer read fTagOffset write fTagOffset;
    property TagSlotIndex: Integer read fTagSlotIndex write fTagSlotIndex;
  end;

  { TOscBaseSurface
    Host for the built-in Base page. Unlike TOscView, this class
    creates only one TOglChart/OpenGL context and places all oscillograms as
    TChartPage children inside one chart model. This avoids Win32 child-window
    repaint artifacts caused by many independent OpenGL controls. }
  TOscBaseSurface = class(TPanel)
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
    fSnapshots: array of TOscSignalSnapshot;
    fUnitNames: TStringList;
    fUnitCatalog: TOscUnitCatalog;
    fModel: TChartModel;
    procedure InitializeChart;
    function GetFpsText: string;
    procedure ChartAfterRender(Sender: TObject; ARenderTimeMs: Double);
    function GetAxis(AIndex: Integer): TChartAxis;
    function GetPage(AIndex: Integer): TChartPage;
    function GetTrend(AIndex: Integer): cBuffTrend1d;
    function RefreshRangeCaptions: Boolean;
    function ResolveTag(ATagRegistry: TOscTagRegistry;
      AIndex: Integer): TOscTag;
    procedure ResetFpsMeasure;
    procedure SetAxisRange(AAxis: TChartAxis; AMinValue, AMaxValue: Double);
    procedure UpdatePageCaption(APage: TChartPage; AAxis: TChartAxis;
      ATag: TOscTag);
    private
    fPageCaptionFontSize: Integer;
    function GetPageCaptionFontSize: Integer;
    procedure SetPageCaptionFontSize(AValue: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetUnitCatalog(ACatalog: TOscUnitCatalog);
    property UnitCatalog: TOscUnitCatalog read fUnitCatalog write SetUnitCatalog;
    destructor Destroy; override;

    { Recreates the internal chart pages only when the count changes. }
    procedure Rebuild(ATagRegistry: TOscTagRegistry; ACount: Integer;
      ADisplaySeconds: Double);
    { Refreshes all page trends from tag snapshots. }
    procedure Refresh(ATagRegistry: TOscTagRegistry;
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
procedure RebuildOscViews(AOwner: TComponent; APanel: TPanel;
  ATagRegistry: TOscTagRegistry; ACount: Integer;
  ADisplaySeconds: Double);
{ Refreshes all existing oscillograms on APanel. }
procedure RefreshOscViews(APanel: TPanel;
  ATagRegistry: TOscTagRegistry; ADisplaySeconds: Double;
  AMeasureFps: Boolean = False);
{ Immediately repaints already-created oscillograms on APanel. }
procedure RepaintOscViews(APanel: TPanel);

{ Returns the current FPS text of the base oscillogram surface. }
function OscViewsFpsText(APanel: TPanel): string;

implementation

{$R *.lfm}

uses
  SysUtils, Math, uSharedNumberFormat,
  uOglChartRenderer,
  uOglChartFontMng, GL;

const
  COscillogramLegendMinChartHeight = 64;


procedure TOscLegendSplitter.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and Assigned(fOnDragStarted) then
    fOnDragStarted(Self);
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure SelectOscillogramDisplayUnit(AUnits: TOscUnitCatalog;
  const ASourceUnit: string;
  AMaxAbsValue: Double; AUnitNames: TStrings; out ADisplayUnit: string;
  out ADisplayScale: Double);
var
  I: Integer;
  lCandidateInfo, lSourceInfo: TOscUnitInfo;
  lCandidateValue, lFactor, lScore, lBestScore: Double;
begin
  ADisplayUnit := Trim(ASourceUnit);
  ADisplayScale := 1.0;
  if (AUnits = nil) or (AUnitNames = nil) or (AMaxAbsValue <= 0) or
    not AUnits.TryGetUnitInfo(ASourceUnit, lSourceInfo) then
    Exit;
  lBestScore := MaxDouble;
  for I := 0 to AUnitNames.Count - 1 do
    if AUnits.TryGetUnitInfo(AUnitNames[I], lCandidateInfo) and
       SameText(lCandidateInfo.QuantityId, lSourceInfo.QuantityId) and
       AUnits.TryGetConversionFactor(ASourceUnit,
         lCandidateInfo.Name, lFactor) then
    begin
      lCandidateValue := AMaxAbsValue * lFactor;
      { Инженерная шкала должна оставаться читаемой: предпочтительно от 1 до
        1000, а среди подходящих единиц выбираем значение ближе к 100. }
      if (lCandidateValue < 1.0) or (lCandidateValue >= 1000.0) then
        Continue;
      lScore := Abs(Log10(lCandidateValue) - 2.0);
      if lScore < lBestScore then
      begin
        lBestScore := lScore;
        ADisplayUnit := lCandidateInfo.Name;
        ADisplayScale := lFactor;
      end;
    end;
end;

procedure ApplyOscillogramTagYRange(AAxis: TChartAxis; ATag: TOscTag;
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

function OscillogramEstimateShortName(AKind: TOscEstimate): string;
begin
  case AKind of
    ovMean: Result := 'M';
    ovRmsValue: Result := 'rms';
    ovRmsDeviation: Result := 'sko';
    ovPeak: Result := 'A';
    ovPeakToPeak: Result := 'p2p';
    ovMinimum: Result := 'min';
    ovMaximum: Result := 'max';
    ovPeakToPeakByRmsDeviation: Result := 'p2p/sko';
    ovLastValue: Result := 'last';
  else
    Result := '';
  end;
end;

function FormatOscillogramValue(const AValue, AYMaxAbs: Double;
  const ADisplayFormat: string): string;
var
  lDigits: Integer;
  lFormat: string;
  lResolution: Double;
  lRoundedValue: Double;
begin
  lRoundedValue := AValue;
  { Не показываем разряды мельче 0,01 % максимального модуля шкалы. }
  if AYMaxAbs > 0 then
  begin
    lResolution := Abs(AYMaxAbs) * 0.0001;
    if lResolution > 0 then
      lRoundedValue := Round(AValue / lResolution) * lResolution;
  end;
  lFormat := Trim(ADisplayFormat);
  lDigits := StrToIntDef(lFormat, 0);
  if (lDigits >= 1) and (lDigits <= 15) then
    Exit(FormatSignificant(lRoundedValue, lDigits));
  if lFormat <> '' then
    try
      Exit(FormatFloat(lFormat, lRoundedValue));
    except
      { Некорректная пользовательская маска не должна ломать отрисовку. }
    end;
  Result := FormatSignificant(lRoundedValue, 4);
end;

function FormatEnabledEstimateCaption(ATag: TOscTag;
  const AYRange: Double; const ADisplayFormat: string): string;
var
  lEstimate: TOscEstimateValue;
  lKind: TOscEstimate;
  lParts: TStringList;
  lSettings: TOscEstimateSettings;
begin
  Result := '';
  if ATag = nil then
    Exit;
  lSettings := ATag.EstimateSettings;
  lParts := TStringList.Create;
  try
    lParts.Delimiter := ' ';
    lParts.StrictDelimiter := True;
    for lKind := ovMean to ovPeakToPeakByRmsDeviation do
      if lSettings.EnabledKinds[lKind] then
      begin
        lEstimate := ATag.Estimate(lKind);
        if lEstimate.Valid then
          lParts.Add(Format('%s=%s',
            [OscillogramEstimateShortName(lKind),
            FormatOscillogramValue(lEstimate.Value, AYRange,
              ADisplayFormat)]))
        else
          lParts.Add(OscillogramEstimateShortName(lKind) + '=-');
      end;

    if lParts.Count = 0 then
    begin
      lEstimate := ATag.Estimate(lSettings.DefaultKind);
      if lEstimate.Valid then
        lParts.Add(Format('%s=%s',
          [OscillogramEstimateShortName(lSettings.DefaultKind),
          FormatOscillogramValue(lEstimate.Value, AYRange,
            ADisplayFormat)]))
      else
        lParts.Add(OscillogramEstimateShortName(lSettings.DefaultKind) +
          '=-');
    end;

    Result := lParts.DelimitedText;
  finally
    lParts.Free;
  end;
end;

{ TOscView }
procedure TOscView.SetUnitCatalog(ACatalog: TOscUnitCatalog);
begin
  fUnitCatalog := ACatalog;
  fUnitNames.Clear;
  if fUnitCatalog <> nil then fUnitCatalog.FillUnitNames(fUnitNames);
end;

function OscHistoryCapacity(ATags: TOscTagRegistry;
  AWindowSeconds: Double): Integer;
var
  I: Integer;
  lFrequency, lRequired: Double;
begin
  lFrequency := 0;
  if ATags <> nil then
    for I := 0 to ATags.TagCount - 1 do
      lFrequency := Max(lFrequency, ATags.Tags[I].PollFrequencyHz);
  lRequired := Ceil(lFrequency * Max(0.001, AWindowSeconds)) + 16;
  if lRequired > High(Integer) then
    raise EOscDataRead.Create('Oscillogram history window is too large');
  Result := Max(4096, Trunc(lRequired));
end;

procedure TOscView.PrepareHistoryBuffers(ADisplaySeconds: Double);
var
  I, lCapacity: Integer;
begin
  lCapacity := OscHistoryCapacity(fTagRegistry, Max(1.0, ADisplaySeconds) * 3);
  { Allocate the snapshot records before preparing their caller-owned arrays.
    Refresh must never discover an unprepared primary or additional line. }
  SetLength(fLineSnapshots, 1 + fExtraLines.Count);
  for I := 0 to High(fLineSnapshots) do
    PrepareOscHistory(fLineSnapshots[I].Times, fLineSnapshots[I].Values, lCapacity);
  PrepareOscHistory(fTriggerTimes, fTriggerValues, lCapacity);
  SetLength(fPluginValues, lCapacity);
end;

constructor TOscView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentBackground := False;
  Color := clWhite;
  fBindingMode := obRelativeSelectedTag;
  fTagOffset := 0;
  fTagSlotIndex := 0;
  fExtraLines := TList.Create;
  fUnitNames := TStringList.Create;
  { Unit catalog is injected by the plugin instance before Configure. }
  fActiveSeriesIndex := 0;
  fXCursorCount := 1;
  fXCursorsInitialized := False;
  fLegendLastRowCount := -1;
  fLegendManualHeight := 0;
  fLegendUserResized := False;
  fLegendSplitterDragging := False;
  InitControlPanel;
  InitToolBar;
end;

destructor TOscView.Destroy;
var
  I: Integer;
begin
  fHasDataSignature := False;
  if fExtraLines <> nil then
    for I := fExtraLines.Count - 1 downto 0 do
      TObject(fExtraLines[I]).Free;
  fExtraLines.Free;
  fUnitNames.Free;
  inherited Destroy;
end;

procedure TOscView.LoadPluginCapabilities;
begin
  fPluginCapabilities := OSC_ALL_CAPABILITIES;
end;

function TOscView.HasPluginCapability(
  ACapability: QWord): Boolean;
begin
  Result := (fPluginCapabilities and ACapability) <> 0;
end;

function TOscView.DispatchComponentEvent(
  const AName, AControlId: string; AValue1: Double; AValue2: Double;
  AIntValue: Int64; AFlags: QWord): Boolean;
var
  lEvent: TOscControlEvent;
  lResult: TOscControlResult;
begin
  lEvent := Default(TOscControlEvent);
  lEvent.Size := SizeOf(lEvent);
  StrPLCopy(@lEvent.Name[0], AName, High(lEvent.Name));
  StrPLCopy(@lEvent.ControlId[0], AControlId, High(lEvent.ControlId));
  lEvent.Value1 := AValue1;
  lEvent.Value2 := AValue2;
  lEvent.IntValue := AIntValue;
  lEvent.Flags := AFlags;
  lResult := Default(TOscControlResult);
  lResult.Size := SizeOf(lResult);
  Result := OscProcessControl(fComponent, @lEvent, @lResult) and
    lResult.Handled;
end;

procedure TOscView.Configure(AComponent: TOscModel; ATagRegistry: TOscTagRegistry);
var
  I: Integer;
begin
  fComponent := TOscModel(AComponent);
  LoadPluginCapabilities;
  if fModel = nil then
    ConfigureDefault;
  if fChart <> nil then
  begin
    if HasPluginCapability(OSC_CAP_INTERACTIVE_CHART) then
    begin
      fChart.OnMouseDown := @ChartMouseDown;
      fChart.OnMouseMove := @ChartMouseMove;
      fChart.OnMouseUp := @ChartMouseUp;
    end
    else
    begin
      fChart.OnMouseDown := nil;
      fChart.OnMouseMove := nil;
      fChart.OnMouseUp := nil;
    end;
  end;
  fBindingMode := TOscModel(AComponent).BindingMode;
  fTagRegistry := ATagRegistry;
  { The built-in Oscillogram is intentionally a simple chart.  Advanced
    controls belong only to oscillogram components registered by plugins.
    TypeId comparison must be case-insensitive: the built-in factory exposes
    "Oscillogram", while older code compared it with lowercase text and
    mistakenly enabled the plugin UI on the base component. }
  if fPluginCapabilities <> 0 then
  begin
    fControlPanel.Visible := HasPluginCapability(OSC_CAP_CONTROL_PANEL);
    fToolBar.Visible := HasPluginCapability(OSC_CAP_TOOLBAR);
    fLevelButton.Visible := HasPluginCapability(OSC_CAP_LEVEL_CURSOR);
    fAutoRangeButton.Visible := HasPluginCapability(OSC_CAP_AUTO_RANGE);
    fXCursorButton.Visible := HasPluginCapability(OSC_CAP_X_CURSOR);
    fLegendButton.Visible := HasPluginCapability(OSC_CAP_LEGEND);
    fAutoRange := fComponent.AutoRangeEnabled;
    fAutoRangeApplied := False;
    fXCursorCount := fComponent.XCursorCount;
    if (fXCursorCount < 1) or (fXCursorCount > 2) then
      fXCursorCount := 1;
    if fXCursorMenu <> nil then
      fXCursorMenu.Items[fXCursorCount - 1].Checked := True;
    if fXCursorButton <> nil then
      fXCursorButton.Down := fComponent.XCursorEnabled;
    if PageCursor <> nil then
    begin
      PageCursor.Visible := fComponent.XCursorEnabled;
      if fXCursorCount = 2 then
        PageCursor.CursorType := cctDouble
      else
        PageCursor.CursorType := cctSingle;
    end;
    if fAutoRangeButton <> nil then
      fAutoRangeButton.Down := fAutoRange;
    if fLegendButton <> nil then
      fLegendButton.Down := fComponent.LegendVisible;
    if fLegendHostPanel <> nil then
      fLegendHostPanel.Visible := HasPluginCapability(OSC_CAP_LEGEND) and
        fComponent.LegendVisible;
    if fLegendSplitter <> nil then
      fLegendSplitter.Visible := HasPluginCapability(OSC_CAP_LEGEND) and
        fComponent.LegendVisible;
    RefreshControlValues;
  end
  else
  begin
    if fControlPanel <> nil then fControlPanel.Visible := False;
    if fToolBar <> nil then fToolBar.Visible := False;
    if fLegendHostPanel <> nil then fLegendHostPanel.Visible := False;
    if fLegendSplitter <> nil then fLegendSplitter.Visible := False;
  end;
  fTagOffset := TOscModel(AComponent).TagOffset;
  fAbsoluteTagId := AComponent.TagId;
  fAbsoluteTagName := AComponent.TagName;
  SyncLinesFromComponent(TOscModel(AComponent));
  EnsureTrendCount;
  PrepareHistoryBuffers(Max(1.0, fComponent.XScale));
  UpdateLegend;
  for I := 0 to High(fAxisRangeInitialized) do
    fAxisRangeInitialized[I] := False;
  fHasDataSignature := False;
  fTriggerArmed := False;
  fTriggerHasFrame := False;
  fTriggerHoldUntil := 0;
  Refresh(ATagRegistry, 1.0);
end;

procedure TOscView.RefreshControl(ATagRegistry: TOscTagRegistry; ADisplaySeconds: Double);
begin
  Refresh(ATagRegistry, ADisplaySeconds);
end;

function TOscView.GetChartControl: TOglChart;
begin
  Result := fChart;
end;

procedure TOscView.ConfigureDefault;
var
  lChart: TOglChart;
  lModel: TChartModel;
  lPageArea: TChartFloatRect;
  lTabSpace: TChartPixelRect;
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
  fInfoNextLeft := 0;
  ClearInfoPanel;
  AppendInfoPart('-', clGray);
  lChart := fChart;
  { Chart-specific callbacks are public, not LCL-published properties. }
  lChart.OnAfterRender := @ChartAfterRender;
  lChart.OnCursorChanged := @ChartCursorChanged;
  if HasPluginCapability(OSC_CAP_INTERACTIVE_CHART) then
  begin
    lChart.OnMouseDown := @ChartMouseDown;
    lChart.OnMouseMove := @ChartMouseMove;
    lChart.OnMouseUp := @ChartMouseUp;
  end;
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
  lTabSpace := lPage.PixelTabSpace;
  { X labels are drawn below the plot rectangle. Reserve their full height so
    the bottom legend never covers or clips the labels. }
  lTabSpace.Bottom := 24;
  lPage.PixelTabSpace := lTabSpace;
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

procedure TOscView.ChartAfterRender(Sender: TObject;
  ARenderTimeMs: Double);
var
  lNowMs: QWord;
  lDyText: string;
  lActiveAxis: TChartAxis;
begin
  fFpsLastRenderTimeMs := ARenderTimeMs;
  if fPluginCapabilities <> 0 then
  begin
    DrawTriggerLevelCursor;
    DetectManualRange;
    SyncViewportControls;
    if UpdateAxisDisplayUnits and (fChart <> nil) then
      fChart.Invalidate;
  end;
  if (fDyLabel <> nil) and (fAxis <> nil) then
  begin
    lActiveAxis := ActiveChartAxis;
    if lActiveAxis = nil then
      lActiveAxis := TChartAxis(fAxis);
    lDyText := Format('; dY=%s %s', [FormatSignificant(
      (lActiveAxis.MaxValue - lActiveAxis.MinValue) *
      lActiveAxis.DisplayScale), lActiveAxis.DisplayUnit]);
    lDyText := TrimRight(lDyText);
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

procedure TOscView.ChartCursorChanged(Sender: TObject;
  ACursor: TObject);
var
  lCursor: TChartCursor;
begin
  if not (ACursor is TChartCursor) then
    Exit;
  lCursor := TChartCursor(ACursor);
  fXCursorCount := 1;
  if lCursor.CursorType = cctDouble then
    fXCursorCount := 2;
  if fComponent <> nil then
  begin
    fComponent.XCursorEnabled := lCursor.Visible;
    fComponent.XCursorCount := fXCursorCount;
    DispatchComponentEvent('cursor.changed', 'x_cursor', lCursor.X1,
      lCursor.X2, fXCursorCount, Ord(lCursor.Visible));
  end;
  if fXCursorButton <> nil then
    fXCursorButton.Down := lCursor.Visible;
  if (fXCursorMenu <> nil) and (fXCursorMenu.Items.Count >= fXCursorCount) then
    fXCursorMenu.Items[fXCursorCount - 1].Checked := True;
  RefreshLegendValues;
end;

procedure TOscView.ClearInfoPanel;
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

procedure TOscView.AppendInfoPart(const AText: string; AColor: TColor);
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
  fInfoPanel.Height := Max(fInfoPanel.Height, lLabel.Height + 4);
  Inc(fInfoNextLeft, lLabel.Width);
end;

procedure TOscView.UpdateInfoLabel(ATagRegistry: TOscTagRegistry;
  ATag: TOscTag);
var
  I, lIdx: Integer;
  lEstimateText: string;
  lLine: TOscLine;
  lLineTag: TOscTag;
  lShownTags: TStringList;
  lTagColors: array of TColor;
  lColor: TColor;
  lTagName: string;
begin
  ClearInfoPanel;
  { No channel means no useful statistics row. Do not reserve a blank band
    under the buttons merely to display a dash. }
  if fInfoPanel <> nil then fInfoPanel.Visible := ATag <> nil;
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
        lLine := TOscLine(fExtraLines[I - 1]);
        if not lLine.Visible then
          Continue;
        lLineTag := OscResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);
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
      if (fAxis <> nil) and (fComponent <> nil) then
        lEstimateText := FormatEnabledEstimateCaption(lLineTag,
          Max(Abs(TChartAxis(fAxis).MinValue),
            Abs(TChartAxis(fAxis).MaxValue)),
          fComponent.DisplayFormat)
      else
        lEstimateText := FormatEnabledEstimateCaption(lLineTag, 0, '4');
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

function TOscView.ResolveTag(
  ATagRegistry: TOscTagRegistry): TOscTag;
var
  I: Integer;
  lIndex: Integer;
  lSelected: TOscTag;
begin
  Result := nil;
  if (ATagRegistry = nil) or (ATagRegistry.TagCount = 0) then
    Exit;
  if fBindingMode = obAbsoluteTag then
  begin
    Result := OscResolveTag(ATagRegistry, fAbsoluteTagId, fAbsoluteTagName);
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

procedure TOscView.ResetFpsMeasure;
begin
  fFpsMeasured := 0;
  fFpsWindowFrames := 0;
  fFpsWindowFirstFrameMs := 0;
  fFpsWindowLastFrameMs := 0;
end;

procedure TOscView.SetAxisRange(AMinValue, AMaxValue: Double);
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

procedure TOscView.SetChartTitle(const ATitle: string);
begin
  if fModel <> nil then
    TChartModel(fModel).Title := ATitle;
end;

procedure TOscView.SetXRange(ADisplaySeconds: Double);
begin
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;
  if fPage <> nil then
  begin
    TChartPage(fPage).XMinValue := 0;
    TChartPage(fPage).XMaxValue := ADisplaySeconds;
  end;
end;

procedure TOscView.SyncLinesFromComponent(
  AComponent: TOscModel);
var
  I: Integer;
  lCopy: TOscLine;
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
    lCopy := TOscLine.Create;
    lCopy.Assign(AComponent.Lines[I]);
    fExtraLines.Add(lCopy);
  end;
end;

procedure TOscView.EnsureTrendCount;
var
  I, lAxisIndex, lAxisCount, lSeriesIndex: Integer;
  lAxis: TChartAxis;
  lLine: TOscLine;
  lNeed: Integer;
  lTrend: cLineSeries;
begin
  if fAxis = nil then
    Exit;
  lAxisCount := 1;
  if HasPluginCapability(OSC_CAP_MULTI_AXIS) and (fComponent <> nil) then
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
    if HasPluginCapability(OSC_CAP_MULTI_AXIS) and (fComponent <> nil) then
      if I = 0 then
        lAxisIndex := fComponent.PrimaryAxisIndex
      else
        lAxisIndex := TOscLine(fExtraLines[I - 1]).AxisIndex;
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
    lLine := TOscLine(fExtraLines[I]);
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
  fActiveSeriesIndex := EnsureRange(fActiveSeriesIndex, 0,
    Max(0, Length(fSeries) - 1));
  { The extrema indices belong to the previous series layout.  Channel
    removal can return from Refresh before RebuildExtremaCaches (for example
    when the primary tag is offline), so stale indices must not remain usable
    by the cursor handlers. }
  SetLength(fMaximaIndices, Length(fSeries));
  SetLength(fMinimaIndices, Length(fSeries));
  SetLength(fMaximaCounts, Length(fSeries));
  SetLength(fMinimaCounts, Length(fSeries));
  for I := 0 to High(fSeries) do
  begin
    fMaximaCounts[I] := 0;
    fMinimaCounts[I] := 0;
  end;
  UpdateSignalGrid;
end;

function TOscView.GetTrendByIndex(AIndex: Integer): cLineSeries;
begin
  Result := nil;
  if (AIndex >= 0) and (AIndex < Length(fSeries)) then
    Result := fSeries[AIndex];
end;

procedure TOscView.SignalGridSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := (ARow > 0) and (ARow <= Length(fSeries));
  if CanSelect then
  begin
    if not DispatchComponentEvent('signal.selected', 'signal_grid', 0, 0,
      ARow - 1) then
    begin
      CanSelect := False;
      Exit;
    end;
    fActiveSeriesIndex := ARow - 1;
    UpdateActiveSeriesRenderPriority;
    { Масштаб и смещение в правой панели относятся к оси выбранной линии,
      поэтому сразу показываем параметры новой активной оси. }
    SyncViewportControls(True);
    UpdateAxisSourceUnits;
    UpdateAxisDisplayUnits;
    if fChart <> nil then
      fChart.Redraw;
  end;
end;

function TOscView.TagForAxis(AAxisIndex: Integer): TOscTag;
var
  I: Integer;
  lLine: TOscLine;
begin
  Result := nil;
  { Для активной оси единицу задаёт выбранный сигнал. }
  if ActiveAxisIndex = AAxisIndex then
  begin
    if fActiveSeriesIndex = 0 then
      Exit(ResolveTag(fTagRegistry));
    if (fActiveSeriesIndex - 1 >= 0) and
       (fActiveSeriesIndex - 1 < fExtraLines.Count) then
    begin
      lLine := TOscLine(fExtraLines[fActiveSeriesIndex - 1]);
      Exit(OscResolveTag(fTagRegistry, lLine.TagId, lLine.TagName));
    end;
  end;
  if (fComponent <> nil) and (fComponent.PrimaryAxisIndex = AAxisIndex) then
    Result := ResolveTag(fTagRegistry);
  if Result <> nil then
    Exit;
  for I := 0 to fExtraLines.Count - 1 do
  begin
    lLine := TOscLine(fExtraLines[I]);
    if lLine.Visible and (lLine.AxisIndex = AAxisIndex) then
      Exit(OscResolveTag(fTagRegistry, lLine.TagId, lLine.TagName));
  end;
end;

function TOscView.UpdateAxisDisplayUnits: Boolean;
var
  I: Integer;
  lDisplayScale, lDisplayedSpan, lSpan: Double;
  lDisplayUnit: string;
begin
  Result := False;
  for I := 0 to High(fAxes) do
  begin
    if (I >= Length(fAxisHasSourceUnit)) or
       (not fAxisHasSourceUnit[I]) then
    begin
      if (fAxes[I].DisplayScale <> 1.0) or
         (fAxes[I].DisplayUnit <> '') then
        Result := True;
      fAxes[I].DisplayScale := 1.0;
      fAxes[I].DisplayUnit := '';
      if I < Length(fAxisUnitDirty) then
        fAxisUnitDirty[I] := False;
      Continue;
    end;
    lSpan := Abs(fAxes[I].MaxValue - fAxes[I].MinValue);
    lDisplayedSpan := lSpan * fAxes[I].DisplayScale;
    { AfterRender выполняется каждый кадр. Пока исходная единица прежняя и
      отображаемый диапазон остаётся в широком инженерном коридоре, никаких
      строковых поисков и обхода UnitManager здесь не требуется. }
    if (I < Length(fAxisUnitDirty)) and (not fAxisUnitDirty[I]) and
       (fAxes[I].DisplayScale > 0) and
       (lDisplayedSpan >= 0.8) and (lDisplayedSpan <= 1200.0) then
      Continue;
    SelectOscillogramDisplayUnit(fUnitCatalog, fAxisSourceUnits[I], lSpan, fUnitNames,
      lDisplayUnit, lDisplayScale);
    if (Abs(fAxes[I].DisplayScale - lDisplayScale) > 1E-15) or
       (fAxes[I].DisplayUnit <> lDisplayUnit) then
    begin
      fAxes[I].DisplayScale := lDisplayScale;
      fAxes[I].DisplayUnit := lDisplayUnit;
      Result := True;
    end;
    if I < Length(fAxisUnitDirty) then
      fAxisUnitDirty[I] := False;
  end;
end;

procedure TOscView.UpdateAxisSourceUnits;
var
  I: Integer;
  lNewUnit: string;
  lTag: TOscTag;
begin
  if Length(fAxisSourceUnits) <> Length(fAxes) then
  begin
    SetLength(fAxisSourceUnits, Length(fAxes));
    SetLength(fAxisHasSourceUnit, Length(fAxes));
    SetLength(fAxisUnitDirty, Length(fAxes));
    for I := 0 to High(fAxisUnitDirty) do
      fAxisUnitDirty[I] := True;
  end;
  for I := 0 to High(fAxes) do
  begin
    lTag := TagForAxis(I);
    if lTag <> nil then
      lNewUnit := lTag.UnitName
    else
      lNewUnit := '';
    { Строковое сравнение выполняется при синхронизации модели, не в Paint. }
    if fAxisSourceUnits[I] <> lNewUnit then
    begin
      fAxisSourceUnits[I] := lNewUnit;
      fAxisUnitDirty[I] := True;
    end;
    fAxisHasSourceUnit[I] := lNewUnit <> '';
  end;
end;

{ Returns the Y-axis assigned to the signal selected in the side grid. }
function TOscView.ActiveAxisIndex: Integer;
begin
  Result := 0;
  if not HasPluginCapability(OSC_CAP_MULTI_AXIS) or
    (fComponent = nil) then
    Exit;
  if fActiveSeriesIndex = 0 then
    Result := fComponent.PrimaryAxisIndex
  else if (fActiveSeriesIndex - 1 >= 0) and
          (fActiveSeriesIndex - 1 < fExtraLines.Count) then
    Result := TOscLine(
      fExtraLines[fActiveSeriesIndex - 1]).AxisIndex;
  Result := EnsureRange(Result, 0, Max(0, Length(fAxes) - 1));
end;

{ Returns the chart axis controlled by the Y scale/offset fields. }
function TOscView.ActiveChartAxis: TChartAxis;
var
  lIndex: Integer;
begin
  Result := nil;
  lIndex := ActiveAxisIndex;
  if (lIndex >= 0) and (lIndex < Length(fAxes)) then
    Result := fAxes[lIndex];
end;

{ Returns the persisted axis settings controlled by the Y fields. }
function TOscView.ActiveModelAxis: TOscAxis;
var
  lIndex: Integer;
begin
  Result := nil;
  if (fComponent = nil) or (fComponent.AxisCount = 0) then
    Exit;
  lIndex := EnsureRange(ActiveAxisIndex, 0, fComponent.AxisCount - 1);
  Result := fComponent.Axes[lIndex];
end;

procedure TOscView.ActivateFirstSeriesOnAxis(
  AAxis: TChartAxis);
var
  I: Integer;
begin
  if not HasPluginCapability(OSC_CAP_MULTI_AXIS) or (AAxis = nil) then
    Exit;
  for I := 0 to High(fSeries) do
    if fSeries[I].Visible and (fSeries[I].Parent = AAxis) then
    begin
      if fActiveSeriesIndex = I then
        Exit;
      fActiveSeriesIndex := I;
      if fSignalGrid <> nil then
        fSignalGrid.Row := I + 1;
      SyncViewportControls(True);
      UpdateAxisSourceUnits;
      UpdateAxisDisplayUnits;
      UpdateActiveSeriesRenderPriority;
      Exit;
    end;
end;

{ Marks the signal selected in the side grid as the chart's active trend.
  The renderer uses this reference only for the final overlay pass; the series
  array, axes and persisted channel order therefore remain unchanged. }
procedure TOscView.UpdateActiveSeriesRenderPriority;
var
  lActiveSeries: cLineSeries;
begin
  if fChart = nil then
    Exit;
  lActiveSeries := GetTrendByIndex(fActiveSeriesIndex);
  if fChart.SelectedObject = lActiveSeries then
    Exit;
  fChart.SelectedObject := lActiveSeries;
  fChart.Invalidate;
end;

procedure TOscView.UpdateSignalGrid;
var
  I, lAxisIndex: Integer;
  lLine: TOscLine;
  lName, lAxisText: string;
  lTag: TOscTag;
begin
  if fSignalGrid = nil then
    Exit;
  fSignalGrid.RowCount := Max(2, Length(fSeries) + 1);
  for I := 0 to High(fSeries) do
  begin
    lAxisIndex := 0;
    if I = 0 then
    begin
      lTag := ResolveTag(fTagRegistry);
      if lTag <> nil then
        lName := lTag.Name
      else if fComponent <> nil then
        lName := fComponent.TagName
      else
        lName := '';
      if fComponent <> nil then
        lAxisIndex := fComponent.PrimaryAxisIndex;
    end
    else
    begin
      lLine := TOscLine(fExtraLines[I - 1]);
      lTag := OscResolveTag(fTagRegistry, lLine.TagId, lLine.TagName);
      if lTag <> nil then
        lName := lTag.Name
      else if Trim(lLine.TagName) <> '' then
        lName := lLine.TagName
      else
        lName := lLine.Name;
      lAxisIndex := lLine.AxisIndex;
    end;
    if Trim(lName) = '' then
      lName := Format('Сигнал %d', [I + 1]);
    lAxisText := IntToStr(lAxisIndex + 1);
    if fSignalGrid.Cells[0, I + 1] <> lName then
      fSignalGrid.Cells[0, I + 1] := lName;
    if fSignalGrid.Cells[1, I + 1] <> lAxisText then
      fSignalGrid.Cells[1, I + 1] := lAxisText;
  end;
  fActiveSeriesIndex := EnsureRange(fActiveSeriesIndex, 0,
    Max(0, Length(fSeries) - 1));
  fSignalGrid.Row := fActiveSeriesIndex + 1;
  UpdateActiveSeriesRenderPriority;
  UpdateAxisSourceUnits;
end;

procedure TOscView.AccumulateAxisRange(AAxisIndex: Integer;
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

function TOscView.TriggerAxis: TChartAxis;
var
  I, lIndex: Integer;
  lLine: TOscLine;
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
      lLine := TOscLine(fExtraLines[I]);
      if SameText(fComponent.TriggerTagName, lLine.TagName) then
      begin
        lIndex := lLine.AxisIndex;
        Break;
      end;
    end;
  Result := fAxes[Max(0, Min(lIndex, High(fAxes)))];
end;

function TOscView.TrendLabelColor(AIndex: Integer): TColor;
var
  lTrend: cLineSeries;
begin
  lTrend := GetTrendByIndex(AIndex);
  if lTrend = nil then
    Exit(clGray);
  Result := TColor(lTrend.Color and $00FFFFFF);
end;

procedure TOscView.FillTrendFromSnapshot(ATrend: cLineSeries;
  const ASnapshot: TOscSignalSnapshot; ADisplayStart: Double;
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
    if lTime < 0 then
    begin
      if I = 0 then
        lTime := 0
      else
        Continue;
    end;
    if lTime > ADisplaySeconds then
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

procedure TOscView.InitControlPanel;
begin
  fSignalGrid.ColWidths[0] := 116;
  fSignalGrid.ColWidths[1] := 42;
  fSignalGrid.Cells[0, 0] := 'Сигнал';
  fSignalGrid.Cells[1, 0] := 'Ось';
  fSignalPanel.Height := fSignalLabel.Height +
    6 * fSignalGrid.DefaultRowHeight;
  fSignalSplitter.MinSize := fSignalLabel.Height +
    2 * fSignalGrid.DefaultRowHeight;
end;

procedure TOscView.InitToolBar;
begin
  if fToolImages.Count <> OscIconCount then
    raise Exception.Create('Oscillograph icon resource does not match named indices');
  fLevelButton.ImageIndex := OscIconLevel;
  fAutoRangeButton.ImageIndex := OscIconAutoRange;
  fXCursorButton.ImageIndex := OscIconXCursor;
  fLegendButton.ImageIndex := OscIconLegend;
  fLegendSplitter.ResizeControl := fLegendHostPanel;
  fLegendGrid.Cells[0, 0] := '';
  fLegendGrid.Cells[1, 0] := 'Сигнал';
  fLegendGrid.Cells[2, 0] := 'Y1';
  fLegendGrid.Cells[3, 0] := 'Y2';
  fLegendGrid.Cells[4, 0] := 'ΔY';
  fLegendGrid.Cells[5, 0] := 'ΔX';
  fLegendGrid.Cells[6, 0] := 'f';
end;

procedure TOscView.UpdateLegend;
begin
  if fLegendPanel = nil then Exit;
  fLegendGrid.RowCount := Max(1, Length(fSeries) + 1);
  UpdateLegendLayout;
  RefreshLegendValues;
end;

procedure TOscView.UpdateLegendLayout;
var
  lDesiredHeight, lAvailableHeight: Integer;
begin
  if (fLegendPanel = nil) or (fLegendGrid = nil) then
    Exit;
  lDesiredHeight := fLegendGrid.RowCount * fLegendGrid.DefaultRowHeight + 2;
  lAvailableHeight := ClientHeight - COscillogramLegendMinChartHeight -
    fLegendSplitter.Height;
  if fToolBar <> nil then
    Dec(lAvailableHeight, fToolBar.Height);
  if (fInfoPanel <> nil) and fInfoPanel.Visible then
    Dec(lAvailableHeight, fInfoPanel.Height);
  lAvailableHeight := Max(1, lAvailableHeight);
  if fLegendGrid.RowCount <> fLegendLastRowCount then
  begin
    fLegendLastRowCount := fLegendGrid.RowCount;
    fLegendUserResized := False;
    fLegendManualHeight := 0;
  end;
  if fLegendUserResized then
    lDesiredHeight := fLegendManualHeight;
  lDesiredHeight := EnsureRange(lDesiredHeight, 1, lAvailableHeight);
  if fLegendHostPanel.Height <> lDesiredHeight then
    fLegendHostPanel.Height := lDesiredHeight;
  { The grid fills the scrollbox client area; refresh columns after the host
    panel height changes and LCL has completed its alignment pass. }
  LegendPanelResize(fLegendPanel);
end;

procedure TOscView.LegendSplitterMoved(Sender: TObject);
begin
  fLegendUserResized := True;
  fLegendSplitterDragging := False;
  fLegendManualHeight := fLegendHostPanel.Height;
end;

procedure TOscView.LegendSplitterDragStarted(Sender: TObject);
begin
  fLegendSplitterDragging := True;
end;

procedure TOscView.LegendPanelResize(Sender: TObject);
var
  lWidth, lNameWidth, lNumericWidth, lTotalWidth, I: Integer;
begin
  if (fLegendGrid = nil) or (fLegendGrid.ColCount < 7) or
    (fLegendGrid.ClientWidth <= 0) then
    Exit;
  lWidth := Max(1, fLegendPanel.ClientWidth - 2);
  if fLegendUserSizedColumns then
  begin
    lTotalWidth := 0;
    for I := Low(fLegendColumnWidths) to High(fLegendColumnWidths) do
      Inc(lTotalWidth, fLegendColumnWidths[I]);
    if lTotalWidth <= 0 then Exit;
    for I := 0 to 5 do
      fLegendGrid.ColWidths[I] := Max(1,
        (fLegendColumnWidths[I] * lWidth) div lTotalWidth);
    lTotalWidth := 0;
    for I := 0 to 5 do
      Inc(lTotalWidth, fLegendGrid.ColWidths[I]);
    fLegendGrid.ColWidths[6] := Max(1, lWidth - lTotalWidth);
  end
  else
  begin
    fLegendGrid.ColWidths[0] := Min(18, lWidth);
    lNameWidth := Max(1, ((lWidth - fLegendGrid.ColWidths[0]) * 32) div 100);
    fLegendGrid.ColWidths[1] := lNameWidth;
    lNumericWidth := Max(1, (lWidth - fLegendGrid.ColWidths[0] - lNameWidth) div 5);
    for I := 2 to 5 do
      fLegendGrid.ColWidths[I] := lNumericWidth;
    fLegendGrid.ColWidths[6] := Max(1, lWidth - fLegendGrid.ColWidths[0] -
      lNameWidth - 4 * lNumericWidth);
  end;
end;

procedure TOscView.LegendGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  if fLegendGrid = nil then Exit;
  for I := Low(fLegendColumnWidthsBeforeDrag) to
    High(fLegendColumnWidthsBeforeDrag) do
    fLegendColumnWidthsBeforeDrag[I] := fLegendGrid.ColWidths[I];
end;

procedure TOscView.LegendGridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  if fLegendGrid = nil then Exit;
  for I := Low(fLegendColumnWidths) to High(fLegendColumnWidths) do
  begin
    fLegendColumnWidths[I] := fLegendGrid.ColWidths[I];
    if fLegendColumnWidths[I] <> fLegendColumnWidthsBeforeDrag[I] then
      fLegendUserSizedColumns := True;
  end;
end;

procedure TOscView.LegendPrepareCanvas(Sender: TObject;
  ACol, ARow: Integer; AState: TGridDrawState);
var
  lColor: TColor;
begin
  if not (Sender is TStringGrid) then
    Exit;
  if (ARow = 0) or (ARow > Length(fSeries)) then
  begin
    if ARow = 0 then
    begin
      TStringGrid(Sender).Canvas.Font.Color := clBlack;
      TStringGrid(Sender).Canvas.Font.Style := [fsBold];
    end;
    Exit;
  end;
  lColor := TrendLabelColor(ARow - 1);
  if ACol = 1 then
    TStringGrid(Sender).Canvas.Font.Color := lColor;
end;

procedure TOscView.LegendDrawCell(Sender: TObject;
  ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  lCanvas: TCanvas;
  lSquare: TRect;
begin
  if (ACol <> 0) or (ARow <= 0) or (ARow > Length(fSeries)) or
    not (Sender is TStringGrid) then
    Exit;
  lCanvas := TStringGrid(Sender).Canvas;
  lSquare := Bounds(Rect.Left + (Rect.Width - 9) div 2,
    Rect.Top + (Rect.Height - 9) div 2, 9, 9);
  lCanvas.Brush.Style := bsSolid;
  lCanvas.Brush.Color := TrendLabelColor(ARow - 1);
  lCanvas.Pen.Color := clGray;
  lCanvas.Rectangle(lSquare);
end;

procedure TOscView.Resize;
begin
  inherited Resize;
  if not fLegendSplitterDragging then
    UpdateLegendLayout;
end;

function TOscView.LegendValueAt(ASeries: cLineSeries;
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

procedure TOscView.RefreshLegendValues;
var
  I, lCol, lRow: Integer;
  lSeries: cLineSeries;
  lCursor: TChartCursor;
  lName: string;
  lValue1, lValue2: Double;
  lEvent: TOscControlEvent;
  lResult: TOscControlResult;
  lYRange: Double;
  lDisplayFormat: string;
  lHas1, lHas2: Boolean;
begin
  if (fLegendPanel = nil) or not fLegendPanel.Visible or
     (fPage = nil) or (fLegendGrid = nil) then Exit;
  EnsureXCursorsInitialized;
  lCursor := PageCursor;
  lYRange := 0;
  if fAxis <> nil then
    lYRange := Max(Abs(TChartAxis(fAxis).MinValue),
      Abs(TChartAxis(fAxis).MaxValue));
  lDisplayFormat := '4';
  if fComponent <> nil then
    lDisplayFormat := fComponent.DisplayFormat;
  lResult := Default(TOscControlResult);
  lResult.Size := SizeOf(lResult);
  if (lCursor <> nil) and lCursor.Visible and
    (lCursor.CursorType = cctDouble) and (fComponent <> nil) then
  begin
    lEvent := Default(TOscControlEvent);
    lEvent.Size := SizeOf(lEvent);
    StrPLCopy(@lEvent.Name[0], 'cursor.measure', High(lEvent.Name));
    lEvent.Value1 := lCursor.X1;
    lEvent.Value2 := lCursor.X2;
    OscProcessControl(fComponent, @lEvent, @lResult);
  end;
  for I := 0 to High(fSeries) do
  begin
    lRow := I + 1;
    lSeries := GetTrendByIndex(I);
    if (lSeries = nil) or not lSeries.Visible then
    begin
      for lCol := 0 to fLegendGrid.ColCount - 1 do
        fLegendGrid.Cells[lCol, lRow] := '';
      Continue;
    end;
    if (I = 0) and (fComponent <> nil) and
       (Trim(fComponent.TagName) <> '') then
      lName := fComponent.TagName
    else
      lName := lSeries.Caption;
    fLegendGrid.Cells[0, lRow] := '';
    fLegendGrid.Cells[1, lRow] := lName;
    fLegendGrid.Cells[2, lRow] := '';
    fLegendGrid.Cells[3, lRow] := '';
    fLegendGrid.Cells[4, lRow] := '';
    fLegendGrid.Cells[5, lRow] := '';
    fLegendGrid.Cells[6, lRow] := '';
    if (lCursor <> nil) and lCursor.Visible then
    begin
      lHas1 := LegendValueAt(lSeries, lCursor.X1, lValue1);
      if lHas1 then
        fLegendGrid.Cells[2, lRow] := FormatOscillogramValue(lValue1,
          lYRange, lDisplayFormat);
      if lCursor.CursorType = cctDouble then
      begin
        lHas2 := LegendValueAt(lSeries, lCursor.X2, lValue2);
        if lHas2 then
          fLegendGrid.Cells[3, lRow] := FormatOscillogramValue(lValue2,
            lYRange, lDisplayFormat);
        if lHas1 and lHas2 then
          fLegendGrid.Cells[4, lRow] := FormatOscillogramValue(
            lValue2 - lValue1, lYRange, lDisplayFormat);
        if lResult.Handled then
        begin
          fLegendGrid.Cells[5, lRow] := FormatOscillogramValue(
            lResult.Value1, Abs(lResult.Value1), lDisplayFormat);
          fLegendGrid.Cells[6, lRow] := FormatOscillogramValue(
            lResult.Value2, Abs(lResult.Value2), lDisplayFormat);
        end;
      end;
    end
    else if lSeries.PointCount > 0 then
      fLegendGrid.Cells[2, lRow] := FormatOscillogramValue(
        lSeries.Points[lSeries.PointCount - 1].Y, lYRange, lDisplayFormat);
  end;
end;

procedure TOscView.PaintToolButton(
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

procedure TOscView.ToolButtonClick(Sender: TObject);
var
  I: Integer;
  lControlId: string;
  lDown: Boolean;
begin
  lControlId := '';
  lDown := TToolButton(Sender).Down;
  if Sender = fLevelButton then lControlId := 'level_cursor'
  else if Sender = fAutoRangeButton then lControlId := 'auto_range'
  else if Sender = fXCursorButton then lControlId := 'x_cursor'
  else if Sender = fLegendButton then lControlId := 'legend';
  if (lControlId = '') or not DispatchComponentEvent('toolbar.toggle',
    lControlId, Ord(lDown)) then
  begin
    TToolButton(Sender).Down := not lDown;
    Exit;
  end;
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
    if PageCursor <> nil then
    begin
      EnsureXCursorsInitialized;
      PageCursor.Visible := fXCursorButton.Down;
      fChart.NotifyCursorChanged(PageCursor);
      fChart.Redraw;
    end;
  end
  else if Sender = fLegendButton then
  begin
    fLegendHostPanel.Visible := fLegendButton.Down;
    if fLegendSplitter <> nil then
      fLegendSplitter.Visible := fLegendButton.Down;
    if fComponent <> nil then fComponent.LegendVisible := fLegendButton.Down;
    RefreshLegendValues;
  end;
end;

procedure TOscView.XCursorModeClick(Sender: TObject);
begin
  if not DispatchComponentEvent('cursor.mode', 'x_cursor', 0, 0,
    TMenuItem(Sender).Tag) then
    Exit;
  EnsureXCursorsInitialized;
  fXCursorCount := TMenuItem(Sender).Tag;
  if PageCursor <> nil then
  begin
    if fXCursorCount = 2 then
      PageCursor.CursorType := cctDouble
    else
      PageCursor.CursorType := cctSingle;
    fChart.NotifyCursorChanged(PageCursor);
  end;
  TMenuItem(Sender).Checked := True;
  fChart.Redraw;
end;

function TOscView.PageCursor: TChartCursor;
begin
  Result := nil;
  if fPage <> nil then
    Result := GetOrCreatePageCursor(TChartPage(fPage));
end;

procedure TOscView.EnsureXCursorsInitialized;
var
  lPage: TChartPage;
  lCursor: TChartCursor;
  lRange: Double;
begin
  if fXCursorsInitialized or (fPage = nil) then
    Exit;
  { Начальную треть диапазона выбираем только после появления реального
    кадра, а не из временного диапазона 0..1, заданного при создании chart. }
  if (Length(fSeries) = 0) or (fSeries[0] = nil) or
     (fSeries[0].PointCount = 0) then
    Exit;
  lPage := TChartPage(fPage);
  lRange := lPage.XMaxValue - lPage.XMinValue;
  if lRange <= 0 then
    Exit;
  lCursor := PageCursor;
  if lCursor = nil then
    Exit;
  lCursor.X1 := lPage.XMinValue + 0.33 * lRange;
  lCursor.X2 := lPage.XMinValue + 0.67 * lRange;
  fXCursorsInitialized := True;
end;

procedure TOscView.RefreshControlValues;
var
  lAxis: TOscAxis;
begin
  if (fControlPanel = nil) or (fComponent = nil) then
    Exit;
  fUpdatingControls := True;
  try
  fControlPanel.Visible := True;
  fXScaleEdit.Text := FormatSignificant(fComponent.XScale);
  lAxis := ActiveModelAxis;
  if lAxis <> nil then
  begin
    fYScaleEdit.Text := FormatSignificant(lAxis.YScale);
    fOffsetEdit.Text := FormatSignificant(lAxis.YOffset);
  end
  else
  begin
    fYScaleEdit.Text := FormatSignificant(fComponent.YScale);
    fOffsetEdit.Text := FormatSignificant(fComponent.YOffset);
  end;
  fLevelEdit.Text := FormatSignificant(fComponent.TriggerLevel);
  fPreRollEdit.Text := FormatSignificant(fComponent.TriggerPreRollPercent);
  fTriggerCheck.Checked := fComponent.TriggerEnabled;
  fTriggerFallingCheck.Checked :=
    fComponent.TriggerEdge = oeFalling;
  fClosedInputCheck.Checked := fComponent.ClosedInput;
  fLevelCursorCheck.Checked := fComponent.LevelCursorVisible;
  if fLevelButton <> nil then
    fLevelButton.Down := fLevelCursorCheck.Checked;
  finally
    fUpdatingControls := False;
  end;
end;

procedure TOscView.SyncViewportControls(AForceY: Boolean);
var
  lAxis: TChartAxis;
  lModelAxis: TOscAxis;
  lPage: TChartPage;
  lBaseRange: Double;
  lScale: Double;
  lOffset: Double;

  procedure SetVisibleValue(AEdit: TEdit; AValue: Double;
    AForce: Boolean = False);
  var
    lText: string;
  begin
    if AEdit.Focused and not AForce then
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
  lAxis := ActiveChartAxis;
  if lAxis = nil then
    Exit;
  lModelAxis := ActiveModelAxis;
  lBaseRange := lAxis.PresetMaxValue - lAxis.PresetMinValue;
  if lModelAxis <> nil then
  begin
    lScale := lModelAxis.YScale;
    lOffset := lModelAxis.YOffset;
  end
  else
  begin
    lScale := fComponent.YScale;
    lOffset := fComponent.YOffset;
  end;
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
    SetVisibleValue(fYScaleEdit, lScale, AForceY);
    SetVisibleValue(fOffsetEdit, lOffset, AForceY);
  finally
    fUpdatingControls := False;
  end;
end;

function TOscView.CurrentDisplaySeconds: Double;
begin
  Result := fLastSignatureDisplaySeconds;
  if Result <= 0 then
    Result := 1.0;
end;

procedure TOscView.ControlValueEdited(Sender: TObject);
var
  lValue: Double;
  lCompanionValue: Double;
  lChartAxis: TChartAxis;
  lModelAxis: TOscAxis;
  lControlId: string;
begin
  if (fComponent = nil) or fUpdatingControls then
    Exit;
  if not TryStrToFloat(TEdit(Sender).Text, lValue) then
    Exit;
  lControlId := '';
  if Sender = fXScaleEdit then lControlId := 'x_scale'
  else if Sender = fYScaleEdit then lControlId := 'y_scale'
  else if Sender = fOffsetEdit then lControlId := 'y_offset'
  else if Sender = fLevelEdit then lControlId := 'trigger_level'
  else if Sender = fPreRollEdit then lControlId := 'trigger_preroll';
  if (lControlId = '') or not DispatchComponentEvent('control.changed',
    lControlId, lValue) then
  begin
    RefreshControlValues;
    Exit;
  end;
  if Sender = fXScaleEdit then
  begin
    if lValue <= 0 then Exit;
    fComponent.XScale := lValue;
    PrepareHistoryBuffers(lValue);
    fTriggerArmed := False;
    fTriggerHasFrame := False;
    fTriggerHoldUntil := 0;
    TChartPage(fPage).ZoomedX := False;
  end
  else if Sender = fYScaleEdit then
  begin
    if lValue <= 0 then Exit;
    fAutoRange := False;
    fComponent.AutoRangeEnabled := False;
    if fAutoRangeButton <> nil then fAutoRangeButton.Down := False;
    lModelAxis := ActiveModelAxis;
    if lModelAxis <> nil then
      lModelAxis.YScale := lValue
    else
      fComponent.YScale := lValue;
    if TryStrToFloat(fOffsetEdit.Text, lCompanionValue) then
      if lModelAxis <> nil then
        lModelAxis.YOffset := lCompanionValue
      else
        fComponent.YOffset := lCompanionValue;
    lChartAxis := ActiveChartAxis;
    if lChartAxis <> nil then
      lChartAxis.HasPresetRange := False;
    ApplyActiveYScale;
  end
  else if Sender = fOffsetEdit then
  begin
    fAutoRange := False;
    fComponent.AutoRangeEnabled := False;
    if fAutoRangeButton <> nil then fAutoRangeButton.Down := False;
    lModelAxis := ActiveModelAxis;
    if lModelAxis <> nil then
      lModelAxis.YOffset := lValue
    else
      fComponent.YOffset := lValue;
    if TryStrToFloat(fYScaleEdit.Text, lCompanionValue) and
      (lCompanionValue > 0) then
      if lModelAxis <> nil then
        lModelAxis.YScale := lCompanionValue
      else
        fComponent.YScale := lCompanionValue;
    lChartAxis := ActiveChartAxis;
    if lChartAxis <> nil then
      lChartAxis.HasPresetRange := False;
    ApplyActiveYScale;
  end
  else if Sender = fLevelEdit then
  begin
    fComponent.TriggerLevel := lValue;
    fTriggerArmed := False;
    fTriggerHasFrame := False;
    fTriggerHoldUntil := 0;
  end
  else if Sender = fPreRollEdit then
  begin
    fComponent.TriggerPreRollPercent := lValue;
    fPreRollEdit.Text := FormatSignificant(fComponent.TriggerPreRollPercent);
    fTriggerArmed := False;
    fTriggerHasFrame := False;
    fTriggerHoldUntil := 0;
  end;
  fHasDataSignature := False;
  Refresh(fTagRegistry, CurrentDisplaySeconds);
end;

procedure TOscView.ApplyActiveYScale;
var
  lAxis: TChartAxis;
  lModelAxis: TOscAxis;
  lBaseMin, lBaseMax, lCenter, lHalfRange: Double;
begin
  lAxis := ActiveChartAxis;
  lModelAxis := ActiveModelAxis;
  if (lAxis = nil) or (lModelAxis = nil) or (lModelAxis.YScale <= 0) then
    Exit;
  lBaseMin := lAxis.PresetMinValue;
  lBaseMax := lAxis.PresetMaxValue;
  if lBaseMax <= lBaseMin then Exit;
  lCenter := (lBaseMin + lBaseMax) * 0.5 + lModelAxis.YOffset;
  lHalfRange := (lBaseMax - lBaseMin) * lModelAxis.YScale * 0.5;
  lAxis.MinValue := lCenter - lHalfRange;
  lAxis.MaxValue := lCenter + lHalfRange;
  if fChart <> nil then fChart.Redraw;
end;

procedure TOscView.TriggerChanged(Sender: TObject);
var
  lControlId: string;
  lChecked: Boolean;
begin
  if (fComponent = nil) or fUpdatingControls then
    Exit;
  if Sender = fLevelCursorCheck then
  begin
    lControlId := 'level_cursor';
    lChecked := fLevelCursorCheck.Checked;
  end
  else
  begin
    lControlId := 'trigger';
    lChecked := fTriggerCheck.Checked;
  end;
  if not DispatchComponentEvent('control.toggle', lControlId,
    Ord(lChecked)) then
  begin
    RefreshControlValues;
    Exit;
  end;
  fComponent.TriggerEnabled := fTriggerCheck.Checked;
  if Sender = fLevelCursorCheck then
  begin
    fComponent.LevelCursorVisible := fLevelCursorCheck.Checked;
    if fLevelButton <> nil then fLevelButton.Down := fLevelCursorCheck.Checked;
  end;
  fTriggerArmed := False;
  fTriggerHasFrame := False;
  fTriggerHoldUntil := 0;
  fHasDataSignature := False;
  Refresh(fTagRegistry, CurrentDisplaySeconds);
end;

procedure TOscView.TriggerEdgeChanged(Sender: TObject);
var
  lEdge: TOscSignalEdge;
begin
  if (fComponent = nil) or fUpdatingControls then
    Exit;
  if fTriggerFallingCheck.Checked then
    lEdge := oeFalling
  else
    lEdge := oeRising;
  fComponent.TriggerEdge := lEdge;
  DispatchComponentEvent('control.changed', 'trigger_edge',
    Ord(lEdge));
  fTriggerArmed := False;
  fTriggerHasFrame := False;
  fTriggerHoldUntil := 0;
  fHasDataSignature := False;
  Refresh(fTagRegistry, CurrentDisplaySeconds);
end;

procedure TOscView.RebuildExtremaCaches;
var
  I, J, lPointCount: Integer;
  lPrevious, lValue, lNext: Double;
  lSeries: cLineSeries;
begin
  SetLength(fMaximaIndices, Length(fSeries));
  SetLength(fMinimaIndices, Length(fSeries));
  SetLength(fMaximaCounts, Length(fSeries));
  SetLength(fMinimaCounts, Length(fSeries));
  for I := 0 to High(fSeries) do
  begin
    fMaximaCounts[I] := 0;
    fMinimaCounts[I] := 0;
    lSeries := fSeries[I];
    if (lSeries = nil) or not lSeries.Visible then
      Continue;
    lPointCount := lSeries.PointCount;
    if lPointCount < 3 then
      Continue;
    if Length(fMaximaIndices[I]) < lPointCount then
      SetLength(fMaximaIndices[I], lPointCount);
    if Length(fMinimaIndices[I]) < lPointCount then
      SetLength(fMinimaIndices[I], lPointCount);
    for J := 1 to lPointCount - 2 do
    begin
      lPrevious := lSeries.Points[J - 1].Y;
      lValue := lSeries.Points[J].Y;
      lNext := lSeries.Points[J + 1].Y;
      if IsNan(lPrevious) or IsNan(lValue) or IsNan(lNext) then
        Continue;
      if ((lValue >= lPrevious) and (lValue > lNext)) or
         ((lValue > lPrevious) and (lValue >= lNext)) then
      begin
        fMaximaIndices[I][fMaximaCounts[I]] := J;
        Inc(fMaximaCounts[I]);
      end;
      if ((lValue <= lPrevious) and (lValue < lNext)) or
         ((lValue < lPrevious) and (lValue <= lNext)) then
      begin
        fMinimaIndices[I][fMinimaCounts[I]] := J;
        Inc(fMinimaCounts[I]);
      end;
    end;
  end;
end;

procedure TOscView.DetectManualRange;
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

procedure TOscView.ClosedInputChanged(Sender: TObject);
var
  I: Integer;
begin
  if (fComponent = nil) or fUpdatingControls then
    Exit;
  if not DispatchComponentEvent('control.toggle', 'closed_input',
    Ord(fClosedInputCheck.Checked)) then
  begin
    RefreshControlValues;
    Exit;
  end;
  fComponent.ClosedInput := fClosedInputCheck.Checked;
  fTriggerArmed := False;
  fTriggerHasFrame := False;
  fTriggerHoldUntil := 0;
  fYRangeInitialized := False;
  for I := 0 to High(fAxisRangeInitialized) do
    fAxisRangeInitialized[I] := False;
  fHasDataSignature := False;
  Refresh(fTagRegistry, CurrentDisplaySeconds);
end;

procedure TOscView.ScaleSpinClick(Sender: TObject;
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

procedure TOscView.DrawTriggerLevelCursor;
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

function TOscView.TriggerLevelHit(AX, AY: Integer): Boolean;
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

procedure TOscView.SetTriggerLevelFromPixel(AY: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  lValue: Double;
begin
  if (fComponent = nil) or (fChart = nil) or (fPage = nil) or
     (fAxis = nil) then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  lRect := lRenderer.GetPageContentRect(TChartPage(fPage));
  AY := Max(lRect.Top, Min(AY, lRect.Bottom));
  lValue := lRenderer.PixelToAxisValue(TriggerAxis, AY,
    lRect.Bottom, lRect.Top);
  if not DispatchComponentEvent('control.changed', 'trigger_level',
    lValue) then Exit;
  fComponent.TriggerLevel := lValue;
  fLevelEdit.Text := FormatSignificant(fComponent.TriggerLevel);
  fChart.Invalidate;
end;

procedure TOscView.ChartMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lAxis: TChartAxis;
  lHit: TChartTextHit;
  lRenderer: TOpenGLChartRenderer;
begin
  if not DispatchComponentEvent('chart.mouse_down', 'chart', X, Y,
    Ord(Button)) then
    Exit;
  if Button = mbLeft then
  begin
    { Activate the signal here, from the actual hit result, instead of waiting
      for MouseUp and relying on SelectedObject. Other chart listeners may
      replace SelectedObject between the two events. Both the axis line and
      its captions/tick labels belong to the same selectable axis. }
    if HasPluginCapability(OSC_CAP_INTERACTIVE_CHART) and
      (fChart <> nil) then
    begin
      lAxis := nil;
      lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
      if lRenderer <> nil then
      begin
        if lRenderer.GetTextHitAt(X, Y, lHit) and (lHit.Axis <> nil) then
          lAxis := lHit.Axis
        else if not lRenderer.GetAxisHitAt(fChart.Model, X, Y, lAxis) then
          lAxis := nil;
      end;
      if lAxis <> nil then
        ActivateFirstSeriesOnAxis(lAxis);
    end;
  end;
  if (Button <> mbLeft) or (ssCtrl in Shift) or
     not TriggerLevelHit(X, Y) then Exit;
  fDraggingLevel := True;
  fChart.MouseInputEnabled := False;
  SetTriggerLevelFromPixel(Y);
end;

procedure TOscView.ChartMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if not DispatchComponentEvent('chart.mouse_move', 'chart', X, Y) then
    Exit;
  if fDraggingLevel and (ssLeft in Shift) then
    SetTriggerLevelFromPixel(Y);
  if fDraggingLevel or TriggerLevelHit(X, Y) then
    fChart.Cursor := crSizeNS;
end;

procedure TOscView.ChartMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not DispatchComponentEvent('chart.mouse_up', 'chart', X, Y,
    Ord(Button)) then
    Exit;
  if (Button = mbLeft) and fDraggingLevel then
  begin
    SetTriggerLevelFromPixel(Y);
    fDraggingLevel := False;
    fChart.MouseInputEnabled := True;
    fTriggerArmed := False;
    fTriggerHasFrame := False;
    fTriggerHoldUntil := 0;
    fHasDataSignature := False;
    Refresh(fTagRegistry, CurrentDisplaySeconds);
  end;
  if (Button = mbLeft) and (fChart <> nil) and
     (fChart.SelectedObject is TChartAxis) then
    ActivateFirstSeriesOnAxis(TChartAxis(fChart.SelectedObject));
  DetectManualRange;
end;

function TOscView.ResolveTagByName(
  ATagRegistry: TOscTagRegistry; const ATagName: string): TOscTag;
begin
  Result := OscResolveTag(ATagRegistry, 0, ATagName);
end;

procedure TOscView.Refresh(ATagRegistry: TOscTagRegistry;
  ADisplaySeconds: Double; AMeasureFps: Boolean);
var
  I: Integer;
  lDisplayStart: Double;
  lHasRange: Boolean;
  lLine: TOscLine;
  lLineMin: Double;
  lLineMax: Double;
  lLinePoints: Integer;
  lMaxValue: Double;
  lMinValue: Double;
  lPointCount: Integer;
  lSnapshot: TOscSignalSnapshot;
  lTag: TOscTag;
  lTrend: cLineSeries;
  lDataSignature: QWord;
  lSignatureTag: TOscTag;
  lViewChanged: Boolean;
  lPluginFrame: TOscFrame;
  lAxisCenter: Double;
  lAxisHalfRange: Double;
  lAxisBaseMin: Double;
  lAxisBaseMax: Double;
  lTriggerTag: TOscTag;
  lTriggerCount: Integer;
  lTriggerSearchEnd: Double;
  lTriggerIndex: Integer;
  lTriggered: Boolean;
  lDisplayEnd: Double;
  lNewestTime: Double;
  lLatestTime: Double;
  lHasSamples: Boolean;
  lPrimaryTag: TOscTag;
  lTriggerMean: Double;
  lAxisIndex: Integer;
  lPluginMean: Double;
  lPluginIndex: Integer;
  lWindowSeconds: Double;
  lPreRollSeconds: Double;
  lTriggerEventTime: Double;
begin
  { The chart applies pan/zoom after our OnMouseUp handler, so inspect the
    viewport again before the next data update can apply automatic ranges. }
  if HasPluginCapability(OSC_CAP_INTERACTIVE_CHART) then
    DetectManualRange;
  if HasPluginCapability(OSC_CAP_CONTROL_PANEL) and
    (fComponent <> nil) and (fComponent.XScale > 0) then
    ADisplaySeconds := fComponent.XScale;
  if HasPluginCapability(OSC_CAP_AUTO_RANGE) and fAutoRange then
    for I := 0 to High(fAxisRangeInitialized) do
      fAxisRangeInitialized[I] := False;
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;
  lWindowSeconds := ADisplaySeconds;
  if HasPluginCapability(OSC_CAP_TRIGGER) and (fComponent <> nil) and
    fComponent.TriggerEnabled and
    TChartPage(fPage).ZoomedX then
    lWindowSeconds := TChartPage(fPage).XMaxValue -
      TChartPage(fPage).XMinValue;
  if (lWindowSeconds <= 0) or (lWindowSeconds > ADisplaySeconds) then
    lWindowSeconds := ADisplaySeconds;
  lPreRollSeconds := 0;
  if HasPluginCapability(OSC_CAP_TRIGGER) and (fComponent <> nil) and
    fComponent.TriggerEnabled then
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
    lLine := TOscLine(fExtraLines[I]);
    if not lLine.Visible then
      Continue;
    lSignatureTag := OscResolveTag(ATagRegistry, lLine.TagId,
      lLine.TagName);
    if lSignatureTag <> nil then
      lDataSignature := ((lDataSignature shl 5) or
        (lDataSignature shr 59)) xor
        (QWord(lSignatureTag.Id) + lSignatureTag.SignalBuffer.Revision);
  end;
  if HasPluginCapability(OSC_CAP_TRIGGER) and (fComponent <> nil) and
    fComponent.TriggerEnabled then
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
    if (fPluginCapabilities <> 0) and (fComponent <> nil) then
    begin
      lPluginFrame := Default(TOscFrame);
      lPluginFrame.Size := SizeOf(lPluginFrame);
      lPluginFrame.DisplaySeconds := ADisplaySeconds;
      OscProcessFrame( @lPluginFrame);
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
    lLine := TOscLine(fExtraLines[I]);
    if not lLine.Visible then
      Continue;
    lTag := OscResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);
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
      lLine := TOscLine(fExtraLines[I]);
      if not lLine.Visible then
        Continue;
      lTag := OscResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);
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
  if HasPluginCapability(OSC_CAP_TRIGGER) and (fComponent <> nil) and
    fComponent.TriggerEnabled then
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
      fTriggerHoldUntil := 0;
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
            (fTriggerTimes[lTriggerIndex] >= fTriggerHoldUntil)) and
          (fTriggerTimes[lTriggerIndex] <= lTriggerSearchEnd) and
          OscSignalCrossesTriggerLevel(
            fTriggerValues[lTriggerIndex - 1] - lTriggerMean,
            fTriggerValues[lTriggerIndex] - lTriggerMean,
            fComponent.TriggerLevel, fComponent.TriggerEdge) then
        begin
          lTriggerEventTime := fTriggerTimes[lTriggerIndex];
          lDisplayStart := lTriggerEventTime;
          lTriggered := True;
        end;
    end;
    if not lTriggered then
      Exit;
    fLastTriggerTime := lTriggerEventTime;
    fTriggerHasFrame := True;
    { Re-arm only after one full configured capture interval, not after the
      currently zoomed viewport. Otherwise a short manual zoom can let a later
      crossing replace the captured frame while its configured window is still
      in progress. }
    fTriggerHoldUntil := lTriggerEventTime + ADisplaySeconds;
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
  { Для разреженного change-only потока нужна точка перед левой границей:
    её значение остаётся действующим до первого события внутри окна. }
  lTag.SnapshotRangeInto(lDisplayStart, True,
    fLineSnapshots[0].Times, fLineSnapshots[0].Values,
    fLineSnapshots[0].Count, lDisplayStart + lWindowSeconds);
  while (fLineSnapshots[0].Count > 0) and
    (fLineSnapshots[0].Times[fLineSnapshots[0].Count - 1] >
      lDisplayStart + lWindowSeconds) do
    Dec(fLineSnapshots[0].Count);
  lSnapshot := fLineSnapshots[0];
  if (fPluginCapabilities <> 0) and (fComponent <> nil) then
  begin
    lPluginFrame := Default(TOscFrame);
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
    fPluginMetricsValid := OscProcessFrame( @lPluginFrame) and
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
    if HasPluginCapability(OSC_CAP_MULTI_AXIS) and (fComponent <> nil) then
      lAxisIndex := fComponent.PrimaryAxisIndex;
    AccumulateAxisRange(Max(0, Min(lAxisIndex, High(fAxes))),
      lMinValue, lMaxValue, lPointCount);
  end;
  for I := 0 to fExtraLines.Count - 1 do
  begin
    lLine := TOscLine(fExtraLines[I]);
    lTrend := GetTrendByIndex(I + 1);
    if lTrend = nil then
      Continue;
    if not lLine.Visible then
    begin
      lTrend.ClearPoints;
      Continue;
    end;
    lTag := OscResolveTag(ATagRegistry, lLine.TagId, lLine.TagName);
    if lTag = nil then
    begin
      lTrend.ClearPoints;
      Continue;
    end;
    lTag.SnapshotRangeInto(lDisplayStart, True,
      fLineSnapshots[I + 1].Times, fLineSnapshots[I + 1].Values,
      fLineSnapshots[I + 1].Count, lDisplayStart + lWindowSeconds);
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

  if HasPluginCapability(OSC_CAP_EXTREMA) or
    HasPluginCapability(OSC_CAP_SIGNAL_GRID) then
  begin
    RebuildExtremaCaches;
    UpdateSignalGrid;
  end;

  for I := 0 to High(fAxes) do
  begin
    if fAxisHasRange[I] and not fAxisRangeInitialized[I] then
    begin
      lTag := nil;
      if HasPluginCapability(OSC_CAP_MULTI_AXIS) and
        (fComponent <> nil) and
        (fComponent.PrimaryAxisIndex = I) then
        lTag := lPrimaryTag;
    if HasPluginCapability(OSC_CAP_AUTO_RANGE) and fAutoRange then
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
    if HasPluginCapability(OSC_CAP_AUTO_RANGE) and fAutoRange then Continue;
    if not HasPluginCapability(OSC_CAP_MULTI_AXIS) or
      (fComponent = nil) or
      (I >= fComponent.AxisCount) or
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
  UpdateAxisDisplayUnits;
  if HasPluginCapability(OSC_CAP_AUTO_RANGE) and fAutoRange then
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
  { Diagnostics are owned by the plugin entry point. }
  if fChart is TOglChart then
    TOglChart(fChart).Redraw;
end;

procedure TOscView.ForceRepaint;
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

procedure TOscView.ResetSessionData;
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
  fTriggerHoldUntil := 0;
  fHasDataSignature := False;
  fCurrentTagName := '';
  ResetFpsMeasure;
  if Visible and (fChart <> nil) then
    fChart.Redraw;
end;

{ TOscBaseSurface }
procedure TOscBaseSurface.SetUnitCatalog(ACatalog: TOscUnitCatalog);
begin
  fUnitCatalog := ACatalog;
  fUnitNames.Clear;
  if fUnitCatalog <> nil then fUnitCatalog.FillUnitNames(fUnitNames);
end;

constructor TOscBaseSurface.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ParentBackground := False;
  Color := clWhite;
  fPageCaptionFontSize := 10;
  fUnitNames := TStringList.Create;
  { Unit catalog is injected by the plugin instance before Configure. }
end;

destructor TOscBaseSurface.Destroy;
begin
  fUnitNames.Free;
  inherited Destroy;
end;

procedure TOscBaseSurface.InitializeChart;
var
  lPageArea: TChartFloatRect;
begin
  if fChart <> nil then
    Exit;
  if Parent = nil then
    Exit;
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
  SetPageCaptionFontSize(fPageCaptionFontSize);
end;

function TOscBaseSurface.GetPageCaptionFontSize: Integer;
begin
  Result := fPageCaptionFontSize;
end;

procedure TOscBaseSurface.SetPageCaptionFontSize(AValue: Integer);
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

procedure TOscBaseSurface.ChartAfterRender(Sender: TObject;
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

function TOscBaseSurface.GetFpsText: string;
begin
  if fFpsMeasureEnabled and (fFpsMeasured > 0) then
    Result := Format('FPS %.1f', [fFpsMeasured])
  else
    Result := 'FPS -';
end;

function TOscBaseSurface.GetPage(AIndex: Integer): TChartPage;
begin
  Result := nil;
  if (fModel <> nil) and (AIndex >= 0) and (AIndex < fModel.ChildCount) and
    (fModel.Children[AIndex] is TChartPage) then
    Result := TChartPage(fModel.Children[AIndex]);
end;

function TOscBaseSurface.GetAxis(AIndex: Integer): TChartAxis;
var
  lPage: TChartPage;
begin
  Result := nil;
  lPage := GetPage(AIndex);
  if (lPage <> nil) and (lPage.ChildCount > 0) and
    (lPage.Children[0] is TChartAxis) then
    Result := TChartAxis(lPage.Children[0]);
end;

function TOscBaseSurface.GetTrend(AIndex: Integer): cBuffTrend1d;
var
  lAxis: TChartAxis;
begin
  Result := nil;
  lAxis := GetAxis(AIndex);
  if (lAxis <> nil) and (lAxis.ChildCount > 0) and
    (lAxis.Children[0] is cBuffTrend1d) then
    Result := cBuffTrend1d(lAxis.Children[0]);
end;

function TOscBaseSurface.ResolveTag(
  ATagRegistry: TOscTagRegistry; AIndex: Integer): TOscTag;
var
  I: Integer;
  lActiveCount: Integer;
  lActiveIndex: Integer;
  lSelectedActiveIndex: Integer;
  lCurrentActiveIndex: Integer;
  lSelectedTag: TOscTag;
  lTag: TOscTag;
begin
  Result := nil;
  if (ATagRegistry = nil) or (ATagRegistry.TagCount = 0) then
    Exit;

  { Базовая страница назначает графики автоматически, поэтому отключённый
    аппаратный источник не должен занимать страницу старым буфером. Настройки
    тегов не меняются: после восстановления источника тег снова попадёт в цикл. }
  lActiveCount := 0;
  for I := 0 to ATagRegistry.TagCount - 1 do
    if OscTagSourceIsVisible(ATagRegistry, ATagRegistry.Tags[I]) then
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
    OscTagSourceIsVisible(ATagRegistry, lSelectedTag) then
    for I := 0 to ATagRegistry.TagCount - 1 do
    begin
      lTag := ATagRegistry.Tags[I];
      if not OscTagSourceIsVisible(ATagRegistry, lTag) then
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
    if not OscTagSourceIsVisible(ATagRegistry, lTag) then
      Continue;
    if lActiveIndex = 0 then
      Exit(lTag);
    Dec(lActiveIndex);
  end;
end;

function TOscBaseSurface.RefreshRangeCaptions: Boolean;
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

procedure TOscBaseSurface.ResetFpsMeasure;
begin
  fFpsMeasured := 0;
  fFpsWindowFirstFrameMs := 0;
  fFpsWindowLastFrameMs := 0;
  fFpsWindowFrames := 0;
end;

procedure TOscBaseSurface.SetAxisRange(AAxis: TChartAxis;
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

procedure TOscBaseSurface.UpdatePageCaption(APage: TChartPage;
  AAxis: TChartAxis; ATag: TOscTag);
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
  if AAxis <> nil then
    lEstimateText := FormatEnabledEstimateCaption(ATag,
      Max(Abs(AAxis.MinValue), Abs(AAxis.MaxValue)), '4')
  else
    lEstimateText := FormatEnabledEstimateCaption(ATag, 0, '4');
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

procedure TOscBaseSurface.Rebuild(
  ATagRegistry: TOscTagRegistry; ACount: Integer; ADisplaySeconds: Double);
var
  I, lCapacity: Integer;
  lAxis: TChartAxis;
  lPage: TChartPage;
  lTabSpace: TChartPixelRect;
  lTrend: cBuffTrend1d;
begin
  InitializeChart;
  if fChart = nil then
    Exit;
  if ACount < 1 then
    ACount := 1;
  if ACount > 16 then
    ACount := 16;
  if ADisplaySeconds <= 0 then
    ADisplaySeconds := 1.0;
  fDisplaySeconds := ADisplaySeconds;
  { Rebuild is the cold configuration boundary, even when page count is
    unchanged. Frequency/window changes must prepare caller-owned history
    before Refresh, and cached revisions must not hide a newly rebound tag. }
  lCapacity := OscHistoryCapacity(ATagRegistry, ADisplaySeconds);
  SetLength(fSnapshots, ACount);
  SetLength(fLastDataRevisions, ACount);
  for I := 0 to ACount - 1 do
  begin
    PrepareOscHistory(fSnapshots[I].Times, fSnapshots[I].Values, lCapacity);
    fSnapshots[I].Count := 0;
    fLastDataRevisions[I] := 0;
  end;
  fHasDataRevision := False;
  if (fCount = ACount) and (fModel <> nil) and
    (fModel.ChildCount = ACount) then
  begin
    fModel.AlignPagesAuto;
    Refresh(ATagRegistry, ADisplaySeconds, fFpsMeasureEnabled);
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

procedure TOscBaseSurface.Refresh(
  ATagRegistry: TOscTagRegistry; ADisplaySeconds: Double;
  AMeasureFps: Boolean);
var
  I: Integer;
  lDisplayStart: Double;
  lFirst: Boolean;
  lMaxValue: Double;
  lMinValue: Double;
  lPage: TChartPage;
  lPointCount: Integer;
  lSnapshot: TOscSignalSnapshot;
  lTag: TOscTag;
  lTrend: cBuffTrend1d;
  lAxis: TChartAxis;
  lValueIndex: Integer;
  lDataChanged: Boolean;
  lViewChanged: Boolean;
  lRevision: QWord;
  lDisplayScale: Double;
  lDisplayUnit: string;
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
  if (Length(fLastDataRevisions) <> fCount) or
    (Length(fSnapshots) <> fCount) then
    raise EOscDataRead.Create('Base surface requires Rebuild before Refresh');
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
      lAxis.DisplayScale := 1.0;
      lAxis.DisplayUnit := '';
      UpdatePageCaption(lPage, lAxis, lTag);
      Continue;
    end;

    lTag.CopyLatestInto(ADisplaySeconds, fSnapshots[I].Times,
      fSnapshots[I].Values, fSnapshots[I].Count, lDisplayStart);
    lSnapshot := fSnapshots[I];
    if lSnapshot.Count = 0 then
    begin
      SetAxisRange(lAxis, -1, 1);
      SelectOscillogramDisplayUnit(fUnitCatalog, lTag.UnitName,
        Abs(lAxis.MaxValue - lAxis.MinValue), fUnitNames,
        lDisplayUnit, lDisplayScale);
      lAxis.DisplayScale := lDisplayScale;
      lAxis.DisplayUnit := lDisplayUnit;
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
    SelectOscillogramDisplayUnit(fUnitCatalog, lTag.UnitName,
      Abs(lAxis.MaxValue - lAxis.MinValue), fUnitNames,
      lDisplayUnit, lDisplayScale);
    lAxis.DisplayScale := lDisplayScale;
    lAxis.DisplayUnit := lDisplayUnit;
    UpdatePageCaption(lPage, lAxis, lTag);
  end;

  { Diagnostics are owned by the plugin entry point. }
  fChart.Redraw;
end;

procedure TOscBaseSurface.ForceRepaint;
begin
  Invalidate;
  if fChart <> nil then
  begin
    fChart.Invalidate;
    fChart.Repaint;
  end;
end;

procedure RebuildOscViews(AOwner: TComponent; APanel: TPanel;
  ATagRegistry: TOscTagRegistry; ACount: Integer;
  ADisplaySeconds: Double);
var
  I: Integer;
  lSurface: TOscBaseSurface;
begin
  if APanel = nil then
    Exit;
  if ACount < 1 then
    ACount := 1;
  lSurface := nil;
  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TOscBaseSurface then
      lSurface := TOscBaseSurface(APanel.Controls[I]);
  if lSurface = nil then
  begin
    while APanel.ControlCount > 0 do
      APanel.Controls[0].Free;
    lSurface := TOscBaseSurface.Create(AOwner);
    lSurface.Parent := APanel;
    lSurface.Align := alClient;
  end;

  lSurface.Rebuild(ATagRegistry, ACount, ADisplaySeconds);
  lSurface.BringToFront;
end;

procedure RefreshOscViews(APanel: TPanel;
  ATagRegistry: TOscTagRegistry; ADisplaySeconds: Double;
  AMeasureFps: Boolean);
var
  I: Integer;
begin
  if APanel = nil then
    Exit;
  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TOscBaseSurface then
    begin
      TOscBaseSurface(APanel.Controls[I]).Refresh(ATagRegistry,
        ADisplaySeconds, AMeasureFps);
      Exit;
    end;
end;

procedure RepaintOscViews(APanel: TPanel);
var
  I: Integer;
begin
  if APanel = nil then
    Exit;
  APanel.Invalidate;
  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TOscBaseSurface then
    begin
      TOscBaseSurface(APanel.Controls[I]).ForceRepaint;
      Break;
    end;
  APanel.Update;
end;

function OscViewsFpsText(APanel: TPanel): string;
var
  I: Integer;
begin
  Result := 'FPS -';
  if APanel = nil then
    Exit;
  for I := 0 to APanel.ControlCount - 1 do
    if APanel.Controls[I] is TOscBaseSurface then
      Exit(TOscBaseSurface(APanel.Controls[I]).FpsText);
end;

initialization
  RegisterClass(TOscView);
  RegisterClass(TOscBaseSurface);
end.


