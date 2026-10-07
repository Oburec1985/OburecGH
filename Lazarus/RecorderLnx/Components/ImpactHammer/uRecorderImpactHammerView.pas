unit uRecorderImpactHammerView;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons,
  LResources,
  ComCtrls,
  CheckLst,
  LCLType,
  Math, uOglChart, uOglChartColors, uOglChartChart, uOglChartPage,
  uOglChartAxis, uOglChartTrend, uOglChartRenderer,
  uOglChartDrawObj, uOglChartCursor, uOglChartTextLabel,
  uRecorderFormModel, uRecorderTags,
  uRecorderVisualControl,
  uRecorderFrfContracts,
  uRecorderImpactSessionContracts,
  uRecorderImpactHammerModel, uRecorderImpactHammerContracts,
  uRecorderImpactHammerPresenter, uRecorderImpactMeraAdapter,
  uRcFrfPeaks, uRcFrfPeakForm;

type
  { Runtime surface for the impact-hammer workflow. ApplySnapshot is the only
    state input; button handlers only delegate commands to ApplicationService. }
  TRecorderImpactHammerView = class(TPanel, IVForm)
    btnSettings: TBitBtn;
    btnArm: TButton;
    btnDelete: TButton;
    btnHide: TButton;
    btnNextImpact: TButton;
    btnPreviousImpact: TButton;
    btnStart: TButton;
    btnStop: TButton;
    btnSavePoints: TButton;
    btnPlayModel: TButton;
    btnStopModel: TButton;
    btnSaveSession: TButton;
    btnSaveCsv: TButton;
    btnSaveMdb: TButton;
    btnCompare: TButton;
    btnWinPos: TButton;
    chkAutoScale: TCheckBox;
    chkExtrema: TCheckBox;
    chkLogX: TCheckBox;
    chkLogY: TCheckBox;
    clbCurves: TCheckListBox;
    cmbEstimator: TComboBox;
    cmbWindow: TComboBox;
    rgFrequencyResult: TRadioGroup;
    edtXMax: TEdit;
    edtXMin: TEdit;
    edtYMax: TEdit;
    edtYMin: TEdit;
    lblImpactPosition: TLabel;
    lblCursor: TLabel;
    lblTriggerLevel: TLabel;
    lblFftWindow: TLabel;
    ClientPan: TPanel;
    ChartHostPan: TPanel;
    NavigationPan: TScrollBox;
    RightPan: TScrollBox;
    RightSplitter: TSplitter;
    chkFilterWindow: TCheckBox;
    lblWindowStart: TLabel;
    lblWindowEnd: TLabel;
    lblExponentialStart: TLabel;
    lblExponentialLevel: TLabel;
    tbWindowStart: TTrackBar;
    tbWindowEnd: TTrackBar;
    tbExponentialStart: TTrackBar;
    tbExponentialLevel: TTrackBar;
    pnlCommands: TPanel;
    procedure btnArmClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnNextImpactClick(Sender: TObject);
    procedure btnPreviousImpactClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnSavePointsClick(Sender: TObject);
    procedure btnPlayModelClick(Sender: TObject);
    procedure btnStopModelClick(Sender: TObject);
    procedure sessionCommandClick(Sender: TObject);
    procedure axisOptionsChange(Sender: TObject);
    procedure extremaChange(Sender: TObject);
    procedure axisRangeEditingDone(Sender: TObject);
    procedure curveVisibilityClickCheck(Sender: TObject);
    procedure curveSelectionClick(Sender: TObject);
    procedure curveDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure processingOptionsChange(Sender: TObject);
    procedure frequencyResultChange(Sender: TObject);
    procedure filterWindowChange(Sender: TObject);
    procedure chartCursorChanged(Sender: TObject; ACursor: TObject);
    procedure chartMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure chartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chartMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chartDblClick(Sender: TObject);
  private
    fApplicationService: IRecorderImpactHammerApplicationService;
    fConfigureError: string;
    fConfiguredRegistry: TRecorderTagRegistry;
    fConfiguredSettings: string;
    fSnapshot: TRecorderImpactHammerSnapshot;
    fLastRevision: QWord;
    fComponent: TRecorderImpactHammerComponent;
    fChart: TOglChart;
    fChartModel: TChartModel;
    fTimePage: TChartPage;
    fFrequencyPage: TChartPage;
    fTimeAxis: TChartAxis;
    fHammerTimeAxis: TChartAxis;
    fFrequencyAxis: TChartAxis;
    fLastChartClick: TPoint;
    fHasChartClick: Boolean;
    fTimeCursor: TChartCursor;
    fTriggerLines: array of cLineSeries;
    fTriggerDragging: Boolean;
    fDrawLevel: Double;
    fDrawDuration: Double;
    fFitImpactIndex: Integer;
    fFitImpactCount: Integer;
    fChartSeries: array[TRecorderImpactResultType] of array of cBuffTrend1d;
    fExtremaLabels: array of TChartFlagLabel;
    fExtremaDataRevision: QWord;
    fExtremaBuiltRevision: QWord;
    fExtremaBuiltResult: TRecorderImpactResultType;
    fPeaks: TRcPeaks;
    fPeakForm: TRcFrfPeakForm;
    fPeakLine: cLineSeries;
    fPeakThreshold: Double;
    fPeakDragging: Boolean;
    fPresenter: TRecorderImpactHammerPresenter;
    fUpdatingOptions: Boolean;
    fUpdatingWindow: Boolean;
    fSessionCommands: IRecorderImpactSessionCommandPort;
    fExportContext: TRecorderImpactExportContext;
    procedure BuildCharts;
    procedure PresentResult(AType: TRecorderImpactResultType);
    procedure ShowResultOptions(AType: TRecorderImpactResultType);
    procedure UpdateCommandAvailability;
    procedure UpdateImpactPosition;
    procedure UpdateCursorCaption(const AFrame: TRecorderImpactPresentationFrame);
    function ActiveFrequencyResult: TRecorderImpactResultType;
    function PageFor(AType: TRecorderImpactResultType): TChartPage;
    function AxisFor(AType: TRecorderImpactResultType): TChartAxis;
    procedure PresentWorkspace;
    procedure UpdateFilterWindow;
    procedure UpdateTriggerLine(AValue: Double);
    procedure InvalidateExtrema;
    procedure PresentExtrema(AType: TRecorderImpactResultType;
      const AFrame: TRecorderImpactPresentationFrame);
    procedure UpdatePeakLine;
    procedure FitTimePage;
    procedure ConfigureTimeAxes;
    function CurrentSettings: string;
    procedure RememberSettings;
    function TriggerAxis: TChartAxis;
    procedure RestoreFrequencyPage;
    procedure ApplyCurvePalette;
    function BuildPresentationFrame(AType: TRecorderImpactResultType;
      const AAxisState: TImpactResultAxisState;
      out AFrame: TRecorderImpactPresentationFrame): Boolean;
    class function CurveColor(AIndex: Integer): TColor; static;
    procedure ApplyConfiguredFrequencyRange(
      const AAxisState: TImpactResultAxisState);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplySnapshot(const ASnapshot: TRecorderImpactHammerSnapshot);
    procedure Configure(AComponent: TRecorderVisualComponent;
      ATagRegistry: TRecorderTagRegistry);
    procedure RefreshControl(ATagRegistry: TRecorderTagRegistry;
      ADisplaySeconds: Double);
    function GetChartControl: TOglChart;
    function FrfProvider: IRecorderFrfProvider;
    function ResultSeriesCount(AType: TRecorderImpactResultType): Integer;
    function ResultVisibleSeriesCount(AType: TRecorderImpactResultType): Integer;
    function ResultSampleCount(AType: TRecorderImpactResultType;
      ASeriesIndex: Integer): Integer;
    function ResultSeriesIdentity(AType: TRecorderImpactResultType;
      ASeriesIndex: Integer): PtrUInt;
    property ApplicationService: IRecorderImpactHammerApplicationService
      read fApplicationService write fApplicationService;
    function ChartPageCount: Integer;
    function ChartPagesUseAutoLayout: Boolean;
    function ChartPagesVisible: Boolean;
    property SessionCommands: IRecorderImpactSessionCommandPort
      read fSessionCommands write fSessionCommands;
  end;

implementation

uses
  uOglChartPanZoomListener,
  uRecorderImpactHammerService, uRecorderImpactSessionCommands;

{$R *.lfm}

constructor TRecorderImpactHammerView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if not InitInheritedComponent(Self, TPanel) then
    raise EStreamError.Create('Cannot load TRecorderImpactHammerView resource');
  BevelOuter := bvNone;
  fPresenter := TRecorderImpactHammerPresenter.Create;
  fPeakThreshold := 1.0;
  fFitImpactIndex := -1;
  fFitImpactCount := -1;
  BuildCharts;
end;

destructor TRecorderImpactHammerView.Destroy;
begin
  fSessionCommands := nil;
  fExportContext.Free;
  fPresenter.Free;
  fPeakForm.Free;
  fApplicationService := nil;
  fSnapshot := Default(TRecorderImpactHammerSnapshot);
  fConfigureError := '';
  fLastRevision := 0;
  inherited Destroy;
end;

function TRecorderImpactHammerView.CurrentSettings: string;
var
  lValues: TStringList;
begin
  Result := '';
  if fComponent = nil then
    Exit;
  lValues := TStringList.Create;
  try
    fComponent.SaveToStrings(lValues, 'Impact.');
    Result := lValues.Text;
  finally
    lValues.Free;
  end;
end;

procedure TRecorderImpactHammerView.RememberSettings;
begin
  fConfiguredSettings := CurrentSettings;
end;

procedure TRecorderImpactHammerView.sessionCommandClick(Sender: TObject);
begin
  if fSessionCommands = nil then
    Exit;
  if Sender = btnSaveSession then
    fSessionCommands.Execute(iscSavePortable)
  else if Sender = btnSaveCsv then
    fSessionCommands.Execute(iscSaveCsv)
  else if Sender = btnSaveMdb then
    fSessionCommands.Execute(iscSaveMdb)
  else if Sender = btnCompare then
    fSessionCommands.Execute(iscImportComparison)
  else if Sender = btnWinPos then
    fSessionCommands.Execute(iscLaunchWinPos);
end;

procedure TRecorderImpactHammerView.Configure(
  AComponent: TRecorderVisualComponent; ATagRegistry: TRecorderTagRegistry);
var
  Service: TRecorderImpactHammerService;
begin
  if not (AComponent is TRecorderImpactHammerComponent) then
    Exit;
  if (fApplicationService <> nil) and (fComponent = AComponent) and
    (fConfiguredRegistry = ATagRegistry) and
    (fConfiguredSettings = CurrentSettings) then
    Exit;
  fComponent := TRecorderImpactHammerComponent(AComponent);
  fConfiguredRegistry := ATagRegistry;
  ConfigureTimeAxes;
  if chkExtrema <> nil then
    chkExtrema.Checked := fComponent.ShowExtrema;
  if fComponent.ActiveResultType = irtTime then
    fComponent.ActiveResultType := irtFrfMagnitude;
  rgFrequencyResult.ItemIndex := Ord(fComponent.ActiveResultType) -
    Ord(irtSpectrum);
  fApplicationService := nil;
  fSnapshot := Default(TRecorderImpactHammerSnapshot);
  fConfigureError := '';
  fSessionCommands := nil;
  FreeAndNil(fExportContext);
  fLastRevision := 0;
  fFitImpactIndex := -1;
  fFitImpactCount := -1;
  Service := TRecorderImpactHammerService.Create;
  if Service.Configure(TRecorderImpactHammerComponent(AComponent),
    ATagRegistry) then
  begin
    fApplicationService := Service;
    fExportContext := TRecorderImpactExportContext.Create;
    fSessionCommands := TRecorderImpactSessionCommands.Create(Service,
      TRecorderImpactMeraFolderAdapter.Create(fExportContext),
      TRecorderImpactWinPosLauncher.Create(fExportContext),
      fComponent.ExportPath);
  end
  else
  begin
    fConfigureError := Service.LastError;
    Service.Free;
  end;
  PresentWorkspace;
  ShowResultOptions(ActiveFrequencyResult);
  if fConfigureError <> '' then
  begin
    lblImpactPosition.Caption := fConfigureError;
    lblImpactPosition.Hint := fConfigureError;
    lblImpactPosition.ShowHint := True;
  end;
  if fApplicationService <> nil then
    RememberSettings;
end;

procedure TRecorderImpactHammerView.RefreshControl(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
var
  CurrentRevision: QWord;
begin
  if fApplicationService <> nil then
  begin
    CurrentRevision := fApplicationService.Revision;
    if CurrentRevision = fLastRevision then
      Exit;
    fApplicationService.FillSnapshot(fSnapshot);
    fLastRevision := CurrentRevision;
    ApplySnapshot(fSnapshot);
  end;
end;

function TRecorderImpactHammerView.GetChartControl: TOglChart;
begin
  Result := fChart;
end;

function TRecorderImpactHammerView.FrfProvider: IRecorderFrfProvider;
begin
  Result := nil;
  if fApplicationService <> nil then
    Result := fApplicationService.Provider;
end;

function TRecorderImpactHammerView.ResultSeriesCount(
  AType: TRecorderImpactResultType): Integer;
begin
  Result := Length(fChartSeries[AType]);
end;

function TRecorderImpactHammerView.ResultSampleCount(
  AType: TRecorderImpactResultType; ASeriesIndex: Integer): Integer;
begin
  if (ASeriesIndex < 0) or
    (ASeriesIndex >= Length(fChartSeries[AType])) then
    Exit(0);
  Result := fChartSeries[AType][ASeriesIndex].Count;
end;

function TRecorderImpactHammerView.ResultSeriesIdentity(
  AType: TRecorderImpactResultType; ASeriesIndex: Integer): PtrUInt;
begin
  Result := 0;
  if (ASeriesIndex >= 0) and
    (ASeriesIndex < Length(fChartSeries[AType])) then
    Result := PtrUInt(fChartSeries[AType][ASeriesIndex]);
end;

function TRecorderImpactHammerView.ResultVisibleSeriesCount(
  AType: TRecorderImpactResultType): Integer;
var
  lSeries: cBuffTrend1d;
begin
  Result := 0;
  for lSeries in fChartSeries[AType] do
    if lSeries.Visible then
      Inc(Result);
end;

procedure TRecorderImpactHammerView.ApplySnapshot(
  const ASnapshot: TRecorderImpactHammerSnapshot);
var
  I: Integer;
  lMinX, lMaxX: Double;
  lHasSamples: Boolean;
begin
  fSnapshot := ASnapshot;
  { Bound reverse zoom by the visible samples, including a small negative
    pretrigger offset if the acquired timestamps contain one. }
  lHasSamples := False;
  lMinX := 0;
  lMaxX := 0;
  for I := 0 to High(ASnapshot.Results[irtTime].Curves) do
    if Length(ASnapshot.Results[irtTime].Curves[I].X) > 1 then
    begin
      if not lHasSamples then
      begin
        lMinX := ASnapshot.Results[irtTime].Curves[I].X[0];
        lMaxX := ASnapshot.Results[irtTime].Curves[I].X[
          High(ASnapshot.Results[irtTime].Curves[I].X)];
        lHasSamples := True;
      end
      else
      begin
        lMinX := Min(lMinX, ASnapshot.Results[irtTime].Curves[I].X[0]);
        lMaxX := Max(lMaxX, ASnapshot.Results[irtTime].Curves[I].X[
          High(ASnapshot.Results[irtTime].Curves[I].X)]);
      end;
    end;
  fTimePage.HasPresetXRange := lHasSamples and (lMaxX > lMinX);
  if fTimePage.HasPresetXRange then
  begin
    fTimePage.PresetMinXValue := lMinX;
    fTimePage.PresetMaxXValue := lMaxX;
  end;
  ApplyCurvePalette;
  Inc(fExtremaDataRevision);
  UpdateImpactPosition;
  UpdateCommandAvailability;
  UpdateFilterWindow;
  PresentWorkspace;
  if (ASnapshot.ImpactCount > 0) and
     ((ASnapshot.ImpactIndex <> fFitImpactIndex) or
      (ASnapshot.ImpactCount <> fFitImpactCount)) then
    FitTimePage;
  fFitImpactIndex := ASnapshot.ImpactIndex;
  fFitImpactCount := ASnapshot.ImpactCount;
end;

class function TRecorderImpactHammerView.CurveColor(AIndex: Integer): TColor;
begin
  Result := OglChartLinePaletteColor(AIndex);
end;

procedure TRecorderImpactHammerView.ApplyCurvePalette;
var
  lType: TRecorderImpactResultType;
  lCurveIndex: Integer;
begin
  for lType := Low(TRecorderImpactResultType) to
    High(TRecorderImpactResultType) do
    for lCurveIndex := 0 to High(fSnapshot.Results[lType].Curves) do
      fSnapshot.Results[lType].Curves[lCurveIndex].Color :=
        CurveColor(lCurveIndex);
end;

function TRecorderImpactHammerView.BuildPresentationFrame(
  AType: TRecorderImpactResultType; const AAxisState: TImpactResultAxisState;
  out AFrame: TRecorderImpactPresentationFrame): Boolean;
begin
  fPresenter.Configure(AType, AAxisState);
  Result := fPresenter.Build(fSnapshot, AFrame);
end;

procedure TRecorderImpactHammerView.BuildCharts;
var
  I: Integer;
begin
  { The host panel is streamed so the layout remains visible and resizable in
    Lazarus. OglChart model pages are runtime objects because they belong to
    the renderer object tree rather than to the LCL component stream. }
  fChart := TOglChart.Create(Self);
  fChart.Parent := ChartHostPan;
  fChart.Align := alClient;
  fChart.AutoResizeViewport := True;
  fChart.OnMouseMove := @chartMouseMove;
  fChart.OnMouseDown := @chartMouseDown;
  fChart.OnMouseUp := @chartMouseUp;
  fChart.OnDblClick := @chartDblClick;
  fChart.OnCursorChanged := @chartCursorChanged;
  fChartModel := TChartModel.Create;
  fChartModel.BackgroundColor := $FFFFFFFF;
  fChart.Model := fChartModel;
  fTimePage := TChartPage.Create;
  fTimePage.Name := 'TimePage';
  fTimePage.Caption := 'Время';
  fTimePage.Align := cpaAuto;
  fTimePage.ReverseDragZoomOut := True;
  fChartModel.AddChild(fTimePage);
  fTimeAxis := TChartAxis.Create;
  fTimeAxis.Name := 'ResponsesTimeAxis';
  fTimeAxis.Color := $FF404040;
  fTimePage.AddChild(fTimeAxis);
  SetLength(fTriggerLines, 1);
  for I := 0 to High(fTriggerLines) do
  begin
    fTriggerLines[I] := cLineSeries.Create;
    fTriggerLines[I].Name := 'TriggerLevel' + IntToStr(I);
    fTriggerLines[I].Caption := '';
    fTriggerLines[I].Color := OglChartColorToGL(clRed);
    fTriggerLines[I].LineWidth := 2;
    fTriggerLines[I].StipplePattern := $0F0F;
    fTimeAxis.AddChild(fTriggerLines[I]);
  end;
  fFrequencyPage := TChartPage.Create;
  fFrequencyPage.Name := 'FrequencyPage';
  fFrequencyPage.Caption := 'Частота';
  fFrequencyPage.Align := cpaAuto;
  { Restore the saved axis range in chartDblClick, not the generic data fit. }
  fFrequencyPage.ResetZoomOnDoubleClick := False;
  fChartModel.AddChild(fFrequencyPage);
  fFrequencyAxis := TChartAxis.Create;
  fFrequencyPage.AddChild(fFrequencyAxis);
  fPeakLine := cLineSeries.Create;
  fPeakLine.Name := 'PeakThreshold';
  fPeakLine.Caption := '';
  fPeakLine.Color := OglChartColorToGL(clRed);
  fPeakLine.LineWidth := 2;
  fPeakLine.StipplePattern := $0F0F;
  fPeakLine.Visible := False;
  fFrequencyAxis.AddChild(fPeakLine);
  fTimeCursor := GetOrCreatePageCursor(fTimePage);
  fTimeCursor.Visible := True;
  fTimeCursor.CursorType := cctDouble;
  fChartModel.AlignPagesAuto;
end;

procedure TRecorderImpactHammerView.ConfigureTimeAxes;
var
  lAxis: TChartAxis;
  I: Integer;
begin
  if (fComponent <> nil) and fComponent.ExcitationOwnAxis then
  begin
    if fHammerTimeAxis = nil then
    begin
      fHammerTimeAxis := TChartAxis.Create;
      fHammerTimeAxis.Name := 'HammerTimeAxis';
      fHammerTimeAxis.Color := OglChartColorToGL(clRed);
      fTimePage.AddChild(fHammerTimeAxis);
    end;
    lAxis := fHammerTimeAxis;
  end
  else
    lAxis := fTimeAxis;
  if (Length(fChartSeries[irtTime]) > 0) and
     (fChartSeries[irtTime][0] <> nil) then
    lAxis.AddChild(fChartSeries[irtTime][0]);
  for I := 0 to High(fTriggerLines) do
    lAxis.AddChild(fTriggerLines[I]);
  if (lAxis = fTimeAxis) and (fHammerTimeAxis <> nil) then
    FreeAndNil(fHammerTimeAxis);
end;

function TRecorderImpactHammerView.TriggerAxis: TChartAxis;
begin
  if fHammerTimeAxis <> nil then
    Result := fHammerTimeAxis
  else
    Result := fTimeAxis;
end;

function TRecorderImpactHammerView.ChartPageCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if fChartModel = nil then
    Exit;
  for I := 0 to fChartModel.ChildCount - 1 do
    if fChartModel.Children[I] is TChartPage then
      Inc(Result);
end;

function TRecorderImpactHammerView.ChartPagesUseAutoLayout: Boolean;
begin
  Result := (fTimePage <> nil) and (fFrequencyPage <> nil) and
    (fTimePage.Align = cpaAuto) and (fFrequencyPage.Align = cpaAuto);
end;

function TRecorderImpactHammerView.ChartPagesVisible: Boolean;
begin
  Result := (fTimePage <> nil) and (fFrequencyPage <> nil) and
    fTimePage.Visible and fFrequencyPage.Visible;
end;

function TRecorderImpactHammerView.ActiveFrequencyResult:
  TRecorderImpactResultType;
begin
  Result := TRecorderImpactResultType(Ord(irtSpectrum) +
    EnsureRange(rgFrequencyResult.ItemIndex, 0,
      Ord(High(TRecorderImpactResultType)) - Ord(irtSpectrum)));
end;

function TRecorderImpactHammerView.PageFor(
  AType: TRecorderImpactResultType): TChartPage;
begin
  if AType = irtTime then
    Result := fTimePage
  else
    Result := fFrequencyPage;
end;

function TRecorderImpactHammerView.AxisFor(
  AType: TRecorderImpactResultType): TChartAxis;
begin
  if AType = irtTime then
    Result := fTimeAxis
  else
    Result := fFrequencyAxis;
end;

procedure TRecorderImpactHammerView.PresentWorkspace;
begin
  PresentResult(irtTime);
  PresentResult(ActiveFrequencyResult);
  ShowResultOptions(ActiveFrequencyResult);
end;

procedure TRecorderImpactHammerView.PresentResult(
  AType: TRecorderImpactResultType);
var
  Frame: TRecorderImpactPresentationFrame;
  AxisState: TImpactResultAxisState;
  Series: cBuffTrend1d;
  I: Integer;
begin
  if AType <> irtTime then
    for I := Ord(irtSpectrum) to Ord(High(TRecorderImpactResultType)) do
      if TRecorderImpactResultType(I) <> AType then
        for Series in fChartSeries[TRecorderImpactResultType(I)] do
          Series.Visible := False;
  if fComponent <> nil then
    AxisState := fComponent.AxisStates[AType]
  else
  begin
    AxisState := Default(TImpactResultAxisState);
    AxisState.AutoScale := True;
  end;
  BuildPresentationFrame(AType, AxisState, Frame);
  if Length(fChartSeries[AType]) < Length(Frame.Curves) then
  begin
    I := Length(fChartSeries[AType]);
    SetLength(fChartSeries[AType], Length(Frame.Curves));
    while I < Length(fChartSeries[AType]) do
    begin
      fChartSeries[AType][I] := cBuffTrend1d.Create;
      if (AType = irtTime) and (I = 0) and
         (fHammerTimeAxis <> nil) then
        fHammerTimeAxis.AddChild(fChartSeries[AType][I])
      else
        AxisFor(AType).AddChild(fChartSeries[AType][I]);
      Inc(I);
    end;
  end;
  if AxisState.LogX then
    PageFor(AType).XScale := casLog10
  else
    PageFor(AType).XScale := casLinear;
  if AxisState.LogY then
    AxisFor(AType).Scale := casLog10
  else
    AxisFor(AType).Scale := casLinear;
  if not AxisState.AutoScale then
  begin
    if AType = irtTime then
    begin
      PageFor(AType).XMinValue := AxisState.XMin;
      PageFor(AType).XMaxValue := AxisState.XMax;
    end;
    AxisFor(AType).MinValue := AxisState.YMin;
    AxisFor(AType).MaxValue := AxisState.YMax;
  end;
  for I := 0 to High(Frame.Curves) do
  begin
    Series := fChartSeries[AType][I];
    Series.Visible := True;
    Series.Name := Frame.Curves[I].Name;
    Series.Caption := Frame.Curves[I].Name;
    Series.Color := OglChartColorToGL(TColor(Frame.Curves[I].Color));
    if Length(Frame.Curves[I].X) > 0 then
      Series.X0 := Frame.Curves[I].X[0];
    if Length(Frame.Curves[I].X) > 1 then
      Series.DX := Frame.Curves[I].X[1] - Frame.Curves[I].X[0]
    else
      Series.DX := 1;
    Series.ReplaceValues(Frame.Curves[I].Y, 0,
      Length(Frame.Curves[I].Y));
  end;
  for I := Length(Frame.Curves) to High(fChartSeries[AType]) do
    fChartSeries[AType][I].Visible := False;
  if AType <> irtTime then
    ApplyConfiguredFrequencyRange(AxisState);
  PresentExtrema(AType, Frame);
  if (AType = irtTime) and (fComponent <> nil) then
    UpdateTriggerLine(fComponent.TriggerThreshold);
  UpdateCursorCaption(Frame);
  fChart.Redraw;
end;

procedure TRecorderImpactHammerView.ApplyConfiguredFrequencyRange(
  const AAxisState: TImpactResultAxisState);
begin
  if AAxisState.XMax <= AAxisState.XMin then
    Exit;
  { Frequency limits are a saved measurement setting. Apply them after series
    updates so chart auto-ranging cannot replace the configured maximum. }
  fFrequencyPage.PresetMinXValue := AAxisState.XMin;
  fFrequencyPage.PresetMaxXValue := AAxisState.XMax;
  fFrequencyPage.HasPresetXRange := True;
  fFrequencyPage.XMinValue := AAxisState.XMin;
  fFrequencyPage.XMaxValue := AAxisState.XMax;
  { Auto Y may choose its upper bound, but must not discard the saved floor. }
  if AAxisState.AutoScale then
  begin
    if fFrequencyAxis.MaxValue <= AAxisState.YMin then
      fFrequencyAxis.MaxValue := Max(AAxisState.YMax,
        AAxisState.YMin + Max(Abs(AAxisState.YMin) * 0.1, 1E-9));
    fFrequencyAxis.MinValue := AAxisState.YMin;
  end;
end;

procedure TRecorderImpactHammerView.InvalidateExtrema;
begin
  fExtremaBuiltRevision := High(QWord);
end;

procedure TRecorderImpactHammerView.UpdatePeakLine;
var
  lState: TImpactResultAxisState;
begin
  if (fComponent = nil) or (fPeakLine = nil) then Exit;
  fPeakLine.Visible := chkExtrema.Checked;
  if not fPeakLine.Visible then Exit;
  lState := fComponent.AxisStates[ActiveFrequencyResult];
  fPeakLine.ClearPoints;
  fPeakLine.AddPoint(lState.XMin, fPeakThreshold);
  fPeakLine.AddPoint(lState.XMax, fPeakThreshold);
  if fPeakForm <> nil then
    fPeakForm.Caption := Format('Экстремумы FRF — порог %.4g',
      [fPeakThreshold]);
end;

procedure TRecorderImpactHammerView.PresentExtrema(
  AType: TRecorderImpactResultType;
  const AFrame: TRecorderImpactPresentationFrame);
var
  lCurveIndex: Integer;
  lLabelIndex: Integer;
  lPeakIndex: Integer;
  lFirstPeak: Integer;

  procedure EnsureLabel;
  begin
    if lLabelIndex >= Length(fExtremaLabels) then
    begin
      SetLength(fExtremaLabels, lLabelIndex + 1);
      fExtremaLabels[lLabelIndex] := TChartFlagLabel.Create;
      fExtremaLabels[lLabelIndex].Name :=
        Format('ImpactExtremum%d', [lLabelIndex]);
      fExtremaLabels[lLabelIndex].AttachToAllTrends := False;
      fFrequencyPage.AddChild(fExtremaLabels[lLabelIndex]);
    end;
  end;

  procedure ShowLabel(const APeak: TRcPeak);
  begin
    EnsureLabel;
    fExtremaLabels[lLabelIndex].Trend := fChartSeries[AType][lCurveIndex];
    fExtremaLabels[lLabelIndex].AnchorX := APeak.Frequency;
    fExtremaLabels[lLabelIndex].Text := Format('%.4g Hz; %.4g',
      [APeak.Frequency, APeak.Value]);
    fExtremaLabels[lLabelIndex].Visible := True;
    Inc(lLabelIndex);
  end;

begin
  if (AType = irtTime) or (chkExtrema = nil) or not chkExtrema.Checked then
  begin
    if fPeakLine <> nil then fPeakLine.Visible := False;
    for lLabelIndex := 0 to High(fExtremaLabels) do
      fExtremaLabels[lLabelIndex].Visible := False;
    Exit;
  end;
  UpdatePeakLine;
  if (fExtremaBuiltRevision = fExtremaDataRevision) and
    (fExtremaBuiltResult = AType) then
    Exit;

  lLabelIndex := 0;
  SetLength(fPeaks, 0);
  for lCurveIndex := 0 to High(AFrame.Curves) do
  begin
    if not AFrame.Curves[lCurveIndex].Visible then Continue;
    if (Length(AFrame.Curves[lCurveIndex].X) = 0) or
      (Length(AFrame.Curves[lCurveIndex].X) <>
       Length(AFrame.Curves[lCurveIndex].Y)) then
      Continue;
    lFirstPeak := Length(fPeaks);
    FindRcPeaks(AFrame.Curves[lCurveIndex].X,
      AFrame.Curves[lCurveIndex].Y, fPeakThreshold,
      AFrame.Curves[lCurveIndex].Name, fPeaks);
    for lPeakIndex := lFirstPeak to High(fPeaks) do
      ShowLabel(fPeaks[lPeakIndex]);
  end;
  while lLabelIndex < Length(fExtremaLabels) do
  begin
    fExtremaLabels[lLabelIndex].Visible := False;
    Inc(lLabelIndex);
  end;
  fExtremaBuiltRevision := fExtremaDataRevision;
  fExtremaBuiltResult := AType;
  if fPeakForm <> nil then fPeakForm.SetPeaks(fPeaks);
end;

procedure TRecorderImpactHammerView.chartMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  ResultType: TRecorderImpactResultType;
  Renderer: TOpenGLChartRenderer;
  ContentRect: TChartPixelRect;
  CursorFrame: TRecorderImpactPresentationFrame;
  AxisState: TImpactResultAxisState;
begin
  if Sender <> fChart then
    Exit;
  if fPeakDragging then
  begin
    Renderer := TOpenGLChartRenderer(fChart.GetRenderer);
    if Renderer <> nil then
    begin
      ContentRect := Renderer.GetPageContentRect(fFrequencyPage);
      fPeakThreshold := Max(1E-9, Renderer.PixelToAxisValue(fFrequencyAxis,
        EnsureRange(Y, ContentRect.Top, ContentRect.Bottom),
        ContentRect.Bottom, ContentRect.Top));
      UpdatePeakLine;
      InvalidateExtrema;
      fChart.Redraw;
    end;
    Exit;
  end;
  if fTriggerDragging then
  begin
    Renderer := TOpenGLChartRenderer(fChart.GetRenderer);
    if Renderer <> nil then
    begin
      ContentRect := Renderer.GetPageContentRect(fTimePage);
      UpdateTriggerLine(Abs(Renderer.PixelToAxisValue(TriggerAxis,
        EnsureRange(Y, ContentRect.Top, ContentRect.Bottom),
        ContentRect.Bottom, ContentRect.Top)));
      fChart.Redraw;
    end;
    Exit;
  end;
  ResultType := ActiveFrequencyResult;
  Renderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if Renderer = nil then
    Exit;
  ContentRect := Renderer.GetPageContentRect(fFrequencyPage);
  if (X < ContentRect.Left) or (X > ContentRect.Right) or
    (Y < ContentRect.Top) or (Y > ContentRect.Bottom) then
    Exit;
      if ssCtrl in Shift then
      begin
        fSnapshot.Cursor.FrequencyHz2 := Renderer.PixelToXValue(
          fFrequencyPage, nil, X, ContentRect.Left,
          ContentRect.Right);
        fSnapshot.Cursor.HasSecond := True;
      end
      else
        fSnapshot.Cursor.FrequencyHz := Renderer.PixelToXValue(
          fFrequencyPage, nil, X, ContentRect.Left,
          ContentRect.Right);
      AxisState := fComponent.AxisStates[ResultType];
      fPresenter.Configure(ResultType, AxisState);
      CursorFrame := Default(TRecorderImpactPresentationFrame);
      fPresenter.BuildCursor(fSnapshot, CursorFrame.Cursor);
      UpdateCursorCaption(CursorFrame);
  fChart.Redraw;
end;

procedure TRecorderImpactHammerView.UpdateTriggerLine(AValue: Double);
var
  lLevel, lDuration: Double;
begin
  if (Length(fTriggerLines) = 0) or (fComponent = nil) then Exit;
  lLevel := AValue;
  if fComponent.TriggerPolarity = itpNegative then lLevel := -lLevel;
  lDuration := Max(1E-6, fSnapshot.CaptureDurationSeconds);
  if (fTriggerLines[0].PointCount = 2) and
    SameValue(lLevel, fDrawLevel) and
    SameValue(lDuration, fDrawDuration) then Exit;
  fTriggerLines[0].ClearPoints;
  fTriggerLines[0].AddPoint(0, lLevel);
  fTriggerLines[0].AddPoint(lDuration, lLevel);
  lblTriggerLevel.Caption := Format('Порог: %.6g', [lLevel]);
  fDrawLevel := lLevel;
  fDrawDuration := lDuration;
end;

procedure TRecorderImpactHammerView.FitTimePage;
begin
  FitPageZoom(fTimePage);
  fChart.Redraw;
end;

procedure TRecorderImpactHammerView.RestoreFrequencyPage;
var
  lState: TImpactResultAxisState;
begin
  if fComponent = nil then Exit;
  lState := fComponent.AxisStates[ActiveFrequencyResult];
  if lState.AutoScale then
  begin
    FitZoomY(fFrequencyPage);
    if fFrequencyAxis.MaxValue <= lState.YMin then
      fFrequencyAxis.MaxValue := Max(lState.YMax,
        lState.YMin + Max(Abs(lState.YMin) * 0.1, 1E-9));
    fFrequencyAxis.MinValue := lState.YMin;
  end
  else
  begin
    fFrequencyAxis.MinValue := lState.YMin;
    fFrequencyAxis.MaxValue := lState.YMax;
  end;
  ApplyConfiguredFrequencyRange(lState);
  fChart.Redraw;
end;

procedure TRecorderImpactHammerView.chartDblClick(Sender: TObject);
var
  lRenderer: TOpenGLChartRenderer;
  lPoint: TPoint;
  lRect: TChartPixelRect;
begin
  if Sender <> fChart then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  if fHasChartClick then
    lPoint := fLastChartClick
  else
    lPoint := fChart.ScreenToClient(Mouse.CursorPos);
  fHasChartClick := False;
  lRect := lRenderer.GetPageRect(fTimePage);
  if (lPoint.X >= lRect.Left) and (lPoint.X <= lRect.Right) and
     (lPoint.Y >= lRect.Top) and (lPoint.Y <= lRect.Bottom) then
    FitTimePage
  else
  begin
    lRect := lRenderer.GetPageRect(fFrequencyPage);
    if (lPoint.X >= lRect.Left) and (lPoint.X <= lRect.Right) and
       (lPoint.Y >= lRect.Top) and (lPoint.Y <= lRect.Bottom) then
      RestoreFrequencyPage;
  end;
end;

procedure TRecorderImpactHammerView.chartMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  lLevel: Double;
begin
  fLastChartClick := Point(X, Y);
  fHasChartClick := True;
  if (Button <> mbLeft) or (fComponent = nil) then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  if chkExtrema.Checked then
  begin
    lRect := lRenderer.GetPageContentRect(fFrequencyPage);
    if (X >= lRect.Left) and (X <= lRect.Right) and
       (Y >= lRect.Top) and (Y <= lRect.Bottom) and
       (Abs(Y - lRenderer.AxisValueToPixel(fFrequencyAxis,
         fPeakThreshold, lRect.Bottom, lRect.Top)) <= 8) then
    begin
      fPeakDragging := True;
      fChart.MouseInputEnabled := False;
      Exit;
    end;
  end;
  lRect := lRenderer.GetPageContentRect(fTimePage);
  if (X < lRect.Left) or (X > lRect.Right) or
     (Y < lRect.Top) or (Y > lRect.Bottom) then Exit;
  lLevel := fComponent.TriggerThreshold;
  if fComponent.TriggerPolarity = itpNegative then lLevel := -lLevel;
  fTriggerDragging := Abs(Y - lRenderer.AxisValueToPixel(TriggerAxis,
    lLevel, lRect.Bottom, lRect.Top)) <= 8;
  if fTriggerDragging then fChart.MouseInputEnabled := False;
end;

procedure TRecorderImpactHammerView.chartMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  lValue: Double;
  lError: string;
begin
  if fPeakDragging and (Button = mbLeft) then
  begin
    fPeakDragging := False;
    fChart.MouseInputEnabled := True;
    InvalidateExtrema;
    PresentResult(ActiveFrequencyResult);
    Exit;
  end;
  if not fTriggerDragging or (Button <> mbLeft) then Exit;
  fTriggerDragging := False;
  fChart.MouseInputEnabled := True;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  lRect := lRenderer.GetPageContentRect(fTimePage);
  lValue := lRenderer.PixelToAxisValue(TriggerAxis,
    EnsureRange(Y, lRect.Top, lRect.Bottom), lRect.Bottom, lRect.Top);
  if fComponent.TriggerPolarity = itpNegative then lValue := -lValue;
  lValue := Max(1E-9, lValue);
  lError := 'Служба измерения не настроена.';
  if (fApplicationService = nil) or
     not fApplicationService.TrySetTriggerThreshold(lValue, lError) then
    MessageDlg('Порог запуска', lError, mtError, [mbOK], 0);
  RememberSettings;
  UpdateTriggerLine(fComponent.TriggerThreshold);
  fChart.Redraw;
end;

function TryPeakDecrement(const ACurve: TRecorderImpactPresentationCurve;
  ACursorIndex: Integer; out APeakHz, ADecrement: Double): Boolean;
var
  lIndex, lPeak, lLeft, lRight: Integer;
  lHalf, lLeftHz, lRightHz: Double;
begin
  Result := False;
  if (Length(ACurve.X) <> Length(ACurve.Y)) or
     (Length(ACurve.X) < 3) or (ACursorIndex < 0) then Exit;
  lPeak := -1;
  for lIndex := Max(1, ACursorIndex - 10) to
    Min(High(ACurve.Y) - 1, ACursorIndex + 10) do
    if (ACurve.Y[lIndex] > 0) and
       (ACurve.Y[lIndex] >= ACurve.Y[lIndex - 1]) and
       (ACurve.Y[lIndex] >= ACurve.Y[lIndex + 1]) and
       ((lPeak < 0) or (ACurve.Y[lIndex] > ACurve.Y[lPeak])) then
      lPeak := lIndex;
  if (lPeak < 0) or (ACurve.X[lPeak] <= 0) then Exit;
  lHalf := ACurve.Y[lPeak] * 0.5;
  lLeft := lPeak - 1;
  while (lLeft > 0) and (ACurve.Y[lLeft] > lHalf) do Dec(lLeft);
  lRight := lPeak + 1;
  while (lRight < High(ACurve.Y)) and
    (ACurve.Y[lRight] > lHalf) do Inc(lRight);
  if (ACurve.Y[lLeft] > lHalf) or
     (ACurve.Y[lRight] > lHalf) or
     (ACurve.Y[lLeft + 1] = ACurve.Y[lLeft]) or
     (ACurve.Y[lRight] = ACurve.Y[lRight - 1]) then Exit;
  lLeftHz := ACurve.X[lLeft] +
    (lHalf - ACurve.Y[lLeft]) *
    (ACurve.X[lLeft + 1] - ACurve.X[lLeft]) /
    (ACurve.Y[lLeft + 1] - ACurve.Y[lLeft]);
  lRightHz := ACurve.X[lRight - 1] +
    (lHalf - ACurve.Y[lRight - 1]) *
    (ACurve.X[lRight] - ACurve.X[lRight - 1]) /
    (ACurve.Y[lRight] - ACurve.Y[lRight - 1]);
  APeakHz := ACurve.X[lPeak];
  ADecrement := (lRightHz - lLeftHz) / (2 * APeakHz);
  Result := (ADecrement >= 0) and not IsNan(ADecrement);
end;

procedure TRecorderImpactHammerView.UpdateCursorCaption(
  const AFrame: TRecorderImpactPresentationFrame);
var
  lType: TRecorderImpactResultType;
  lCurve, lVisible, lSelected, lLo, lHi, lMid, lIndex: Integer;
  lX1, lPeakHz, lDecrement: Double;
begin
  lType := ActiveFrequencyResult;
  lSelected := clbCurves.ItemIndex;
  if (lSelected < 0) or
     (lSelected > High(fSnapshot.Results[lType].Curves)) or
     not fSnapshot.Results[lType].Curves[lSelected].Visible then
  begin
    lSelected := -1;
    for lCurve := 0 to High(fSnapshot.Results[lType].Curves) do
      if fSnapshot.Results[lType].Curves[lCurve].Visible then
      begin
        lSelected := lCurve;
        Break;
      end;
  end;
  if lSelected < 0 then
  begin
    lblCursor.Caption := 'Курсор: нет видимых каналов';
    Exit;
  end;
  lVisible := 0;
  for lCurve := 0 to lSelected - 1 do
    if fSnapshot.Results[lType].Curves[lCurve].Visible then
      Inc(lVisible);
  if lVisible > High(AFrame.Cursor.Values) then Exit;

  lX1 := AFrame.Cursor.FrequencyHz;
  lblCursor.Caption := Format('%s'#10'X: %.5g Гц   Y: %.5g',
    [fSnapshot.Results[lType].Curves[lSelected].Name,
     lX1, AFrame.Cursor.Values[lVisible]]);
  lIndex := -1;
  with fSnapshot.Results[lType].Curves[lSelected] do
    if Length(X) > 0 then
    begin
      lLo := 0;
      lHi := High(X);
      while lLo < lHi do
      begin
        lMid := lLo + (lHi - lLo) div 2;
        if X[lMid] < lX1 then lLo := lMid + 1 else lHi := lMid;
      end;
      lIndex := lLo;
      if (lIndex > 0) and
         (Abs(X[lIndex - 1] - lX1) <= Abs(X[lIndex] - lX1)) then
        Dec(lIndex);
    end;
  if lIndex >= 0 then
    lblCursor.Caption := lblCursor.Caption + Format('   Отсчёт: %d', [lIndex]);
  if (lType = irtFrfMagnitude) and
     TryPeakDecrement(fSnapshot.Results[lType].Curves[lSelected], lIndex,
       lPeakHz, lDecrement) then
    // plgEvalFRF: full bandwidth at half amplitude divided by 2*f_peak.
    lblCursor.Caption := lblCursor.Caption +
      Format(#10'Декремент: %.4g (пик %.5g Гц)',
        [lDecrement, lPeakHz]);
  if AFrame.Cursor.HasSecond then
    lblCursor.Caption := lblCursor.Caption + Format(#10'X2: %.5g Гц   Y2: %.5g',
      [AFrame.Cursor.FrequencyHz2, AFrame.Cursor.Values2[lVisible]]);
end;

procedure TRecorderImpactHammerView.ShowResultOptions(
  AType: TRecorderImpactResultType);
var
  AxisState: TImpactResultAxisState;
  I: Integer;
begin
  if fComponent = nil then
    Exit;
  fUpdatingOptions := True;
  try
    AxisState := fComponent.AxisStates[AType];
    chkLogX.Checked := AxisState.LogX;
    chkLogY.Checked := AxisState.LogY;
  chkAutoScale.Checked := AxisState.AutoScale;
    cmbEstimator.ItemIndex := Ord(fComponent.Estimator);
    cmbWindow.ItemIndex := Ord(fComponent.WindowKind);
    edtXMin.Text := FloatToStr(AxisState.XMin);
    edtXMax.Text := FloatToStr(AxisState.XMax);
    edtYMin.Text := FloatToStr(AxisState.YMin);
    edtYMax.Text := FloatToStr(AxisState.YMax);
    edtXMin.Enabled := not AxisState.AutoScale;
    edtXMax.Enabled := not AxisState.AutoScale;
    edtYMin.Enabled := not AxisState.AutoScale;
    edtYMax.Enabled := not AxisState.AutoScale;
    clbCurves.Items.BeginUpdate;
    try
      clbCurves.Clear;
      for I := 0 to High(fSnapshot.Results[AType].Curves) do
      begin
        clbCurves.Items.Add(fSnapshot.Results[AType].Curves[I].Name);
        clbCurves.Checked[I] := fSnapshot.Results[AType].Curves[I].Visible;
      end;
    finally
      clbCurves.Items.EndUpdate;
    end;
  finally
    fUpdatingOptions := False;
  end;
end;

procedure TRecorderImpactHammerView.processingOptionsChange(Sender: TObject);
var
  Settings: TRecorderImpactProcessingSettings;
  ErrorText: string;
begin
  if fUpdatingOptions or (fApplicationService = nil) then
    Exit;
  Settings.Estimator := cmbEstimator.ItemIndex;
  Settings.WindowKind := cmbWindow.ItemIndex;
  Settings.WelchEnabled := fComponent.WelchEnabled;
  Settings.WelchSegmentSize := fComponent.WelchSegmentSize;
  Settings.WelchOverlapPercent := fComponent.WelchOverlapPercent;
  if not fApplicationService.TryUpdateProcessingSettings(Settings,
    ErrorText) then
  begin
    MessageDlg('Ударный FRF', ErrorText, mtError, [mbOK], 0);
    ShowResultOptions(ActiveFrequencyResult);
  end;
  RememberSettings;
end;

procedure TRecorderImpactHammerView.axisOptionsChange(Sender: TObject);
var
  ResultType: TRecorderImpactResultType;
  AxisState: TImpactResultAxisState;
begin
  if fUpdatingOptions or (fComponent = nil) then
    Exit;
  ResultType := ActiveFrequencyResult;
  AxisState := fComponent.AxisStates[ResultType];
  AxisState.LogX := chkLogX.Checked;
  AxisState.LogY := chkLogY.Checked;
  AxisState.AutoScale := chkAutoScale.Checked;
  fComponent.AxisStates[ResultType] := AxisState;
  PresentResult(ResultType);
  RememberSettings;
end;

procedure TRecorderImpactHammerView.axisRangeEditingDone(Sender: TObject);
var
  ResultType: TRecorderImpactResultType;
  AxisState: TImpactResultAxisState;
  XMinValue, XMaxValue, YMinValue, YMaxValue: Double;
begin
  if fUpdatingOptions or (fComponent = nil) or
    not TryStrToFloat(edtXMin.Text, XMinValue) or
    not TryStrToFloat(edtXMax.Text, XMaxValue) or
    not TryStrToFloat(edtYMin.Text, YMinValue) or
    not TryStrToFloat(edtYMax.Text, YMaxValue) or
    (XMaxValue <= XMinValue) or (YMaxValue <= YMinValue) then
    Exit;
  ResultType := ActiveFrequencyResult;
  AxisState := fComponent.AxisStates[ResultType];
  AxisState.XMin := XMinValue;
  AxisState.XMax := XMaxValue;
  AxisState.YMin := YMinValue;
  AxisState.YMax := YMaxValue;
  fComponent.AxisStates[ResultType] := AxisState;
  PresentResult(ResultType);
  RememberSettings;
end;

procedure TRecorderImpactHammerView.curveVisibilityClickCheck(Sender: TObject);
var
  ResultType: TRecorderImpactResultType;
  lType: TRecorderImpactResultType;
  CurveId: QWord;
  I: Integer;
  lVisible: Boolean;
begin
  if fUpdatingOptions then
    Exit;
  InvalidateExtrema;
  ResultType := ActiveFrequencyResult;
  if (clbCurves.ItemIndex < 0) or
    (clbCurves.ItemIndex > High(fSnapshot.Results[ResultType].Curves)) then
    Exit;
  lVisible := clbCurves.Checked[clbCurves.ItemIndex];
  CurveId := fSnapshot.Results[ResultType].Curves[
    clbCurves.ItemIndex].CurveId;
  if fSnapshot.Results[ResultType].Curves[
    clbCurves.ItemIndex].ReadOnly then
  begin
    fSnapshot.Results[ResultType].Curves[
      clbCurves.ItemIndex].Visible := lVisible;
    PresentResult(ResultType);
    Exit;
  end;
  for lType := Low(TRecorderImpactResultType) to
    High(TRecorderImpactResultType) do
    for I := 0 to High(fSnapshot.Results[lType].Curves) do
      if fSnapshot.Results[lType].Curves[I].CurveId = CurveId then
        fSnapshot.Results[lType].Curves[I].Visible := lVisible;
  if fComponent <> nil then
  begin
    if CurveId = 0 then
      fComponent.ExcitationVisible := lVisible
    else
      for I := 0 to fComponent.ResponseCount - 1 do
        if fComponent.Responses[I].CurveId = CurveId then
        begin
          fComponent.Responses[I].Visible := lVisible;
          Break;
        end;
  end;
  PresentResult(irtTime);
  PresentResult(ResultType);
  RememberSettings;
end;

procedure TRecorderImpactHammerView.curveSelectionClick(Sender: TObject);
var
  lResultType: TRecorderImpactResultType;
  lCurveIndex: Integer;
begin
  for lCurveIndex := 0 to clbCurves.Count - 1 do
    if clbCurves.Checked[lCurveIndex] then
      Exit;
  lResultType := ActiveFrequencyResult;
  PresentResult(irtTime);
  PresentResult(lResultType);
end;

procedure TRecorderImpactHammerView.curveDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  lBox: TRect;
  lCheck: TRect;
  lBackground: TColor;
begin
  if (Index < 0) or (Index >= clbCurves.Items.Count) then
    Exit;
  if odSelected in State then
    lBackground := clHighlight
  else
    lBackground := clbCurves.Color;
  clbCurves.Canvas.Brush.Color := lBackground;
  clbCurves.Canvas.FillRect(ARect);
  { Win32 skips native checkbox painting for owner-drawn checklists. Keep the
    painted box inside the item clip and inside its checkbox hit area. }
  lCheck.Left := ARect.Left + 2;
  lCheck.Top := ARect.Top + (ARect.Bottom - ARect.Top - 13) div 2;
  lCheck.Right := lCheck.Left + 13;
  lCheck.Bottom := lCheck.Top + 13;
  clbCurves.Canvas.Brush.Color := clWindow;
  clbCurves.Canvas.Pen.Color := clWindowText;
  clbCurves.Canvas.Rectangle(lCheck);
  if clbCurves.Checked[Index] then
  begin
    clbCurves.Canvas.Pen.Width := 2;
    clbCurves.Canvas.MoveTo(lCheck.Left + 2, lCheck.Top + 6);
    clbCurves.Canvas.LineTo(lCheck.Left + 5, lCheck.Top + 9);
    clbCurves.Canvas.LineTo(lCheck.Right - 2, lCheck.Top + 3);
    clbCurves.Canvas.Pen.Width := 1;
  end;
  lBox.Left := lCheck.Right + 4;
  lBox.Top := ARect.Top + (ARect.Bottom - ARect.Top - 10) div 2;
  lBox.Right := lBox.Left + 10;
  lBox.Bottom := lBox.Top + 10;
  clbCurves.Canvas.Brush.Color := CurveColor(Index);
  clbCurves.Canvas.Pen.Color := clBlack;
  clbCurves.Canvas.Rectangle(lBox);
  if odSelected in State then
  begin
    clbCurves.Canvas.Brush.Color := clHighlight;
    clbCurves.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    clbCurves.Canvas.Brush.Color := clbCurves.Color;
    clbCurves.Canvas.Font.Color := clbCurves.Font.Color;
  end;
  clbCurves.Canvas.TextOut(lBox.Right + 5,
    ARect.Top + (ARect.Bottom - ARect.Top - clbCurves.Canvas.TextHeight('Ag')) div 2,
    clbCurves.Items[Index]);
end;

procedure TRecorderImpactHammerView.extremaChange(Sender: TObject);
begin
  if fComponent <> nil then
    fComponent.ShowExtrema := chkExtrema.Checked;
  if chkExtrema.Checked then
  begin
    if fPeakForm = nil then
      fPeakForm := TRcFrfPeakForm.Create(Self);
    fPeakForm.Show;
  end
  else if fPeakForm <> nil then
    fPeakForm.Hide;
  InvalidateExtrema;
  PresentResult(ActiveFrequencyResult);
  RememberSettings;
end;

procedure TRecorderImpactHammerView.frequencyResultChange(Sender: TObject);
begin
  if fUpdatingOptions then
    Exit;
  InvalidateExtrema;
  if fComponent <> nil then
    fComponent.ActiveResultType := ActiveFrequencyResult;
  PresentWorkspace;
  RememberSettings;
end;

procedure TRecorderImpactHammerView.UpdateFilterWindow;
var
  Duration: Double;

  function ToTrackbar(ASeconds: Double): Integer;
  begin
    Result := Round(1000 * ASeconds / Max(1E-12, Duration));
  end;

begin
  Duration := fSnapshot.CaptureDurationSeconds;
  if Duration <= 0 then
    Exit;
  fUpdatingWindow := True;
  try
    chkFilterWindow.Checked := fSnapshot.FilterWindow.Enabled;
    tbWindowStart.Position := ToTrackbar(
      fSnapshot.FilterWindow.StartSeconds);
    tbWindowEnd.Position := ToTrackbar(fSnapshot.FilterWindow.EndSeconds);
    tbExponentialStart.Position := ToTrackbar(
      fSnapshot.FilterWindow.ExponentialStartSeconds);
    tbExponentialLevel.Position := Round(-100 * Log10(Max(1E-6,
      fSnapshot.FilterWindow.ExponentialEndLevel)) / 6);
    { On the time page the two draggable lines delimit the response decay.
      The capture start remains adjustable by its trackbar below. }
    fTimeCursor.X1 := fSnapshot.FilterWindow.ExponentialStartSeconds;
    fTimeCursor.X2 := fSnapshot.FilterWindow.ExponentialEndSeconds;
    fTimeCursor.Visible := chkFilterWindow.Checked;
  finally
    fUpdatingWindow := False;
  end;
end;

procedure TRecorderImpactHammerView.filterWindowChange(Sender: TObject);
var
  FilterWindow: TRecorderImpactFilterWindow;
  Duration: Double;
  ErrorText: string;
  StartPosition: Integer;
  EndPosition: Integer;
  ExponentialStartPosition: Integer;
begin
  if fUpdatingWindow or (fApplicationService = nil) then
    Exit;
  Duration := fSnapshot.CaptureDurationSeconds;
  if Duration <= 0 then
    Exit;
  StartPosition := EnsureRange(tbWindowStart.Position, 0, 999);
  EndPosition := EnsureRange(tbWindowEnd.Position,
    StartPosition + 1, 1000);
  ExponentialStartPosition := EnsureRange(tbExponentialStart.Position,
    StartPosition, EndPosition - 1);
  fUpdatingWindow := True;
  try
    tbWindowStart.Position := StartPosition;
    tbWindowEnd.Position := EndPosition;
    tbExponentialStart.Position := ExponentialStartPosition;
  finally
    fUpdatingWindow := False;
  end;
  FilterWindow.Enabled := chkFilterWindow.Checked;
  FilterWindow.StartSeconds := Duration * StartPosition / 1000;
  FilterWindow.EndSeconds := Duration * EndPosition / 1000;
  FilterWindow.ExponentialStartSeconds := Duration *
    ExponentialStartPosition / 1000;
  FilterWindow.ExponentialEndSeconds := FilterWindow.EndSeconds;
  FilterWindow.ExponentialEndLevel := Power(10,
    -6 * tbExponentialLevel.Position / 100);
  if not fApplicationService.TrySetFilterWindow(FilterWindow, ErrorText) then
  begin
    MessageDlg('Ударный FRF', ErrorText, mtError, [mbOK], 0);
    UpdateFilterWindow;
  end;
end;

procedure TRecorderImpactHammerView.chartCursorChanged(Sender: TObject;
  ACursor: TObject);
var
  ChartCursor: TChartCursor;
begin
  if fUpdatingWindow or (ACursor <> fTimeCursor) then
    Exit;
  ChartCursor := TChartCursor(ACursor);
  fUpdatingWindow := True;
  try
    tbExponentialStart.Position := Round(1000 * ChartCursor.X1 /
      Max(1E-12, fSnapshot.CaptureDurationSeconds));
    tbWindowEnd.Position := Round(1000 * ChartCursor.X2 /
      Max(1E-12, fSnapshot.CaptureDurationSeconds));
  finally
    fUpdatingWindow := False;
  end;
  filterWindowChange(Sender);
end;

procedure TRecorderImpactHammerView.UpdateImpactPosition;
begin
  if fSnapshot.ImpactCount <= 0 then
    lblImpactPosition.Caption := 'Ударов нет'
  else
    lblImpactPosition.Caption := Format('%d из %d', [
      fSnapshot.ImpactIndex + 1,
      fSnapshot.ImpactCount
    ]);

  if fSnapshot.ImpactHidden then
    btnHide.Caption := 'Показать'
  else
    btnHide.Caption := 'Скрыть';
end;

procedure TRecorderImpactHammerView.UpdateCommandAvailability;
begin
  btnPreviousImpact.Enabled := fSnapshot.CanNavigatePrevious;
  btnNextImpact.Enabled := fSnapshot.CanNavigateNext;
  btnHide.Enabled := fSnapshot.CanHide;
  btnDelete.Enabled := fSnapshot.CanDelete;
  btnStart.Enabled := fSnapshot.CanStart;
  btnArm.Enabled := fSnapshot.CanArm;
  btnStop.Enabled := fSnapshot.CanStop;
end;

procedure TRecorderImpactHammerView.btnPreviousImpactClick(Sender: TObject);
begin
  if Assigned(fApplicationService) then
  begin
    fApplicationService.NavigateToPreviousImpact;
    RefreshControl(nil, 0);
  end;
end;

procedure TRecorderImpactHammerView.btnNextImpactClick(Sender: TObject);
begin
  if Assigned(fApplicationService) then
  begin
    fApplicationService.NavigateToNextImpact;
    RefreshControl(nil, 0);
  end;
end;

procedure TRecorderImpactHammerView.btnHideClick(Sender: TObject);
begin
  if Assigned(fApplicationService) then
    fApplicationService.SetCurrentImpactHidden(not fSnapshot.ImpactHidden);
end;

procedure TRecorderImpactHammerView.btnDeleteClick(Sender: TObject);
begin
  if Assigned(fApplicationService) then
    fApplicationService.DeleteCurrentImpact;
end;

procedure TRecorderImpactHammerView.btnStartClick(Sender: TObject);
begin
  if Assigned(fApplicationService) then
    fApplicationService.StartMeasurement;
end;

procedure TRecorderImpactHammerView.btnArmClick(Sender: TObject);
begin
  if Assigned(fApplicationService) then
    fApplicationService.ArmMeasurement;
end;

procedure TRecorderImpactHammerView.btnStopClick(Sender: TObject);
begin
  if Assigned(fApplicationService) then
    fApplicationService.StopMeasurement;
end;

procedure TRecorderImpactHammerView.btnSavePointsClick(Sender: TObject);
begin
  if fApplicationService <> nil then
    fApplicationService.SavePointBindings;
end;

procedure TRecorderImpactHammerView.btnPlayModelClick(Sender: TObject);
begin
  if fApplicationService <> nil then
    fApplicationService.PlayModelAnimation;
end;

procedure TRecorderImpactHammerView.btnStopModelClick(Sender: TObject);
begin
  if fApplicationService <> nil then
    fApplicationService.StopModelAnimation;
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(
    TRecorderImpactHammerComponent, TRecorderImpactHammerView);

end.
