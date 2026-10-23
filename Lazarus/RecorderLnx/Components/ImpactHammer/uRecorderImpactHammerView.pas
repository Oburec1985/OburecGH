unit uRecorderImpactHammerView;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Экран компонента ударного FRF: отображает снимок сервиса и передаёт ему
  команды пользователя; сбор и обработка сигналов выполняются вне формы.
  Интерактивное окно меняет параметры сервиса, а не исходные отсчёты. }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, Spin,
  LResources,
  ComCtrls,
  Math, uOglChart, uOglChartColors, uOglChartChart, uOglChartPage,
  uOglChartAxis, uOglChartTrend, uOglChartRenderer,
  uOglChartDrawObj, uOglChartCursor, uOglChartTextLabel,
  uRecorderFormModel, uRecorderTags,
  uRecorderVisualControl,
  uRecorderFrfContracts, uRecorderFrfRoute,
  uRecorderImpactSessionContracts,
  uRecorderImpactHammerModel, uRecorderImpactHammerContracts,
  uRecorderImpactHammerPresenter, uRecorderImpactMeraAdapter,
  uRecorderImpactGeometryBindingDialog,
  uRecorderFrfRouteDialog,
  uRcFrfPeaks, uRcFrfPeakForm, uSharedColorCheckTable;

type
  { Форма показывает состояние ударного FRF. ApplySnapshot — единственная
    точка приёма состояния; обработчики команд делегируют их сервису. }
  TRecorderImpactHammerView = class(TPanel, IVForm)
    btnSettings: TBitBtn;
    btnDelete: TButton;
    btnHide: TButton;
    btnNextImpact: TButton;
    btnPreviousImpact: TButton;
    chkTrigger: TCheckBox;
    lblCaptureStatus: TLabel;
    btnCapturePortion: TButton;
    btnGeometryBindings: TButton;
    btnRoute:TButton;
    chkScenario:TCheckBox;
    seRoutePoint: TSpinEdit;
    chkRouteTagSync, chkRouteAuto: TCheckBox;
    lblRoutePoint: TLabel;
    chkResultReview, chkResultValues: TCheckBox;
    btnSaveSession: TButton;
    btnSaveCsv: TButton;
    btnSaveMdb: TButton;
    btnCompare: TButton;
    btnWinPos: TButton;
    chkAutoScale: TCheckBox;
    chkExtrema: TCheckBox;
    chkLogX: TCheckBox;
    chkLogY: TCheckBox;
    clbCurves: TSharedColorCheckTable;
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
    pnlCommands: TPanel;
    procedure btnDeleteClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnNextImpactClick(Sender: TObject);
    procedure btnPreviousImpactClick(Sender: TObject);
    procedure TriggerChange(Sender: TObject);
    procedure btnCapturePortionClick(Sender: TObject);
    procedure btnGeometryBindingsClick(Sender: TObject);
    procedure btnRouteClick(Sender:TObject);
    procedure ScenarioChange(Sender:TObject);
    procedure RoutePointChange(Sender: TObject);
    procedure RouteTagSyncChange(Sender: TObject);
    procedure RouteAutoChange(Sender: TObject);
    procedure ResultReviewChange(Sender: TObject);
    procedure sessionCommandClick(Sender: TObject);
    procedure axisOptionsChange(Sender: TObject);
    procedure extremaChange(Sender: TObject);
    procedure axisRangeEditingDone(Sender: TObject);
    procedure curveVisibilityClickCheck(Sender: TObject; AIndex: Integer);
    procedure curveSelectionClick(Sender: TObject);
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
    fUpdatingRoutePoint: Boolean;
    fUpdatingRouteTagSync: Boolean;
    fSelectingReviewPoint: Boolean;
    fSelectedReviewPoint: string;
    fMdbUpdateQueued: Boolean;
    fUpdatingTrigger: Boolean;
    fUpdatingResultReview, fResultReviewEnabled: Boolean;
    procedure ScenePointSelected(const ASelection: TRecorderModelPointSelection);
    procedure MdbContextChanged(Sender: TObject);
    procedure ApplyMdbContextChange(Data: PtrInt);
    procedure UpdateRoutePointControls;
    function EnsureRouteDirectory: Boolean;
    procedure SaveGeometryStep;
  private
    fApplicationService: IRecorderImpactHammerApplicationService;
    fRouteService:IRecorderFrfRouteService;
    fBindingForm: TRecorderImpactGeometryBindingDialog;
    fRouteForm:TRecorderFrfRouteDialog;
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
    fTrackedFrequencyCursor: TObject;
    fFrequencyCursorX1, fFrequencyCursorX2: Double;
    fTriggerCursor: TChartHorizontalCursor;
    fTriggerDragging: Boolean;
    fDrawLevel: Double;
    fFitImpactIndex: Integer;
    fFitImpactCount: Integer;
    fPresentedRouteIndex: Integer;
    fMdbContextRevision: QWord;
    fStorageDirectory: string;
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
    fLastPeakRefreshTick: QWord;
    fPresenter: TRecorderImpactHammerPresenter;
    fUpdatingOptions: Boolean;
    fUpdatingWindow: Boolean;
    { Preview remains authoritative while coalesced worker requests rebuild
      the signal. Accepted state protects handles from older UI snapshots. }
    fWindowPreview: TRecorderImpactFilterWindow;
    fWindowDragStart, fWindowAccepted: TRecorderImpactFilterWindow;
    fWindowAcceptedPending, fWindowPreviewDirty: Boolean;
    fWindowRefreshPending: Boolean;
    fWindowTimer: TTimer;
    fWindowLastSubmit: QWord;
    fWindowDrag: Integer;
    fWindowGrabOffset: Integer;
    fSessionCommands: IRecorderImpactSessionCommandPort;
    fExportContext: TRecorderImpactExportContext;
    procedure BuildCharts;
    procedure GeometryPreview(Sender: TObject);
    procedure RouteStart(Sender:TObject);
    procedure RouteCapture(Sender:TObject);
    procedure RouteAssemble(Sender:TObject);
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
    procedure DrawFilterWindow(Sender: TObject; ARenderTimeMs: Double);
    function WindowHandleAt(X, Y: Integer): Integer;
    procedure MoveWindowHandle(X, Y: Integer);
    procedure CommitFilterWindow;
    procedure WindowPreviewTick(Sender: TObject);
    procedure CancelWindowDrag(Sender: TObject);
    procedure WindowKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UpdateTriggerLine(AValue: Double);
    procedure InvalidateExtrema;
    procedure RefreshExtrema;
    procedure PeakSelectionChange(Sender: TObject);
    procedure PresentExtrema(AType: TRecorderImpactResultType;
      const AFrame: TRecorderImpactPresentationFrame);
    procedure UpdatePeakLine;
    procedure SetPeakThresholdFromPixel(AY: Integer);
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
  uOglChartPanZoomListener, uRecorderMeraBaseModel,
  uRecorderImpactHammerService, uRecorderImpactSessionCommands, uRecorderMdbManager,
  uRecorderProjectFiles, GL, LCLType, LMessages;

type
  { Mouse capture loss (Alt-Tab, another window) must not leave chart input
    disabled or commit an unfinished window edit. }
  TImpactWindowChart = class(TOglChart)
  private
    fDispatchingRelease: Boolean;
  public
    OnWindowCaptureLost: TNotifyEvent;
    property MouseCapture;
  protected
    procedure CaptureChanged; override;
    procedure WndProc(var Message: TLMessage); override;
  end;

function SameFilterWindow(const A, B: TRecorderImpactFilterWindow): Boolean;
begin
  Result := (A.Enabled = B.Enabled) and
    SameValue(A.StartSeconds, B.StartSeconds) and
    SameValue(A.EndSeconds, B.EndSeconds) and
    SameValue(A.ExponentialStartSeconds, B.ExponentialStartSeconds) and
    SameValue(A.ExponentialEndSeconds, B.ExponentialEndSeconds) and
    SameValue(A.ExponentialEndLevel, B.ExponentialEndLevel);
end;

procedure TImpactWindowChart.WndProc(var Message: TLMessage);
begin
  { LCL releases capture BEFORE calling OnMouseUp. This normal release must
    commit the drag, not run the external capture-loss cancellation path. }
  if Message.Msg = LM_LBUTTONUP then
  begin
    fDispatchingRelease := True;
    try inherited WndProc(Message);
    finally fDispatchingRelease := False end;
  end
  else inherited WndProc(Message);
end;

procedure TImpactWindowChart.CaptureChanged;
begin
  inherited CaptureChanged;
  if not MouseCapture and not fDispatchingRelease and
     Assigned(OnWindowCaptureLost) then
    OnWindowCaptureLost(Self);
end;

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
  fPresentedRouteIndex := -1;
  BuildCharts;
  fWindowTimer := TTimer.Create(Self);
  fWindowTimer.Enabled := False;
  fWindowTimer.Interval := 40;
  fWindowTimer.OnTimer := @WindowPreviewTick;
  SubscribeRecorderModelPointSelection(@ScenePointSelected);
  SubscribeRecorderMdbContextChanged(@MdbContextChanged);
end;

destructor TRecorderImpactHammerView.Destroy;
begin
  if fWindowTimer <> nil then fWindowTimer.Enabled := False;
  CancelWindowDrag(nil);
  if fWindowTimer <> nil then fWindowTimer.Enabled := False;
  if fChart <> nil then
  begin
    TImpactWindowChart(fChart).OnWindowCaptureLost := nil;
    fChart.OnAfterRender := nil;
  end;
  UnsubscribeRecorderMdbContextChanged(@MdbContextChanged);
  Application.RemoveAsyncCalls(Self);
  UnsubscribeRecorderModelPointSelection(@ScenePointSelected);
  FreeAndNil(fBindingForm);
  FreeAndNil(fRouteForm);
  fRouteService:=nil;
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
    { Эти сохранённые параметры отражают флаги работающего сервиса. Остановка,
      ручной сбор и ошибка автоматики не должны пересоздавать сервис сбора. }
    lValues.Values['Impact.RouteAutoEnabled'] := '';
    lValues.Values['Impact.RouteTagSyncEnabled'] := '';
    lValues.Values['Impact.ResultValuesVisible'] := '';
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
var Error: string;
begin
  if (Sender = btnSaveSession) and (fComponent <> nil) and
    fComponent.ScenarioEnabled then
  begin
    if not EnsureRouteDirectory then
    begin
      MessageDlg('Задайте папку маршрута или выберите объект базы данных испытаний.',
        mtInformation, [mbOK], 0);
      Exit;
    end;
    if fRouteService.RoutePointHasData and
      (MessageDlg('В текущем шаге уже есть данные FRF. Перезаписать?',
        mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;
    if not fRouteService.SaveRoutePoint(Error) then
      MessageDlg(Error, mtError, [mbOK], 0);
    UpdateRoutePointControls;
    RefreshControl(nil, 0);
    Exit;
  end;
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
  CancelWindowDrag(nil);
  fComponent := TRecorderImpactHammerComponent(AComponent);
  fWindowAcceptedPending := False;
  fWindowRefreshPending := False;
  fWindowTimer.Enabled := False;
  if fComponent.RouteConfigFileName = '' then
    fComponent.RouteConfigFileName := RecorderFrfRouteConfigFileName(
      RecorderProjectConfigurationDirectory, fComponent.Id);
  // Для неподвижного набора датчиков используется маршрут из одного шага.
  fComponent.ScenarioEnabled := True;
  fConfiguredRegistry := ATagRegistry;
  chkScenario.OnClick:=nil;
  chkScenario.Checked:=fComponent.ScenarioEnabled;
  chkScenario.OnClick:=@ScenarioChange;
  ConfigureTimeAxes;
  if chkExtrema <> nil then
    chkExtrema.Checked := fComponent.ShowExtrema;
  if fComponent.ActiveResultType = irtTime then
    fComponent.ActiveResultType := irtFrfMagnitude;
  rgFrequencyResult.ItemIndex := Ord(fComponent.ActiveResultType) -
    Ord(irtSpectrum);
  FreeAndNil(fRouteForm);
  FreeAndNil(fBindingForm);
  fRouteService:=nil;
  fApplicationService := nil;
  fUpdatingResultReview := True;
  try
    fResultReviewEnabled := False;
    chkResultReview.Checked := False;
    chkResultValues.Checked := fComponent.ResultValuesVisible;
    chkResultValues.Enabled := False;
  finally
    fUpdatingResultReview := False;
  end;
  fSnapshot := Default(TRecorderImpactHammerSnapshot);
  fConfigureError := '';
  fSessionCommands := nil;
  FreeAndNil(fExportContext);
  fLastRevision := 0;
  fFitImpactIndex := -1;
  fFitImpactCount := -1;
  fPresentedRouteIndex := -1;
  Service := TRecorderImpactHammerService.Create;
  if Service.Configure(TRecorderImpactHammerComponent(AComponent),
    ATagRegistry) then
  begin
    fApplicationService := Service;
    Supports(fApplicationService, IRecorderFrfRouteService, fRouteService);
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
  begin
    RememberSettings;
    if fComponent.ScenarioEnabled then EnsureRouteDirectory;
    if (fRouteService <> nil) and (fRouteService.Route.Count = 0) then
      SaveGeometryStep;
  end;
  UpdateRoutePointControls;
  if (fComponent <> nil) and fComponent.ScenarioEnabled then RoutePointChange(nil);
  { Настроенные каналы отображаются до поступления первых данных. }
  if fApplicationService <> nil then
  begin
    fLastRevision := High(QWord);
    RefreshControl(nil, 0);
  end;
end;

procedure TRecorderImpactHammerView.RefreshControl(
  ATagRegistry: TRecorderTagRegistry; ADisplaySeconds: Double);
var
  CurrentRevision: QWord;
  PreviousRouteIndex: Integer;
begin
  if RecorderMeraContextRevision<>fMdbContextRevision then
  begin
    fMdbContextRevision:=RecorderMeraContextRevision;
    EnsureRouteDirectory;
  end;
  if (fRouteService<>nil) and (fStorageDirectory<>fRouteService.Route.Directory) then
  begin
    fStorageDirectory:=fRouteService.Route.Directory;
    fUpdatingResultReview:=True;
    try
      fResultReviewEnabled:=False;
      chkResultReview.Checked:=False;
      chkResultValues.Enabled:=False;
    finally fUpdatingResultReview:=False; end;
    if fRouteForm<>nil then fRouteForm.RefreshStorage;
    fLastRevision:=High(QWord);
  end;
  if (fApplicationService <> nil) and
    fApplicationService.PollRouteTagSync then
  begin
    fSelectedReviewPoint := '';
    RememberSettings;
  end;
  UpdateRoutePointControls;
  if fApplicationService <> nil then
  begin
    CurrentRevision := fApplicationService.Revision;
    if CurrentRevision = fLastRevision then
      Exit;
    fApplicationService.FillSnapshot(fSnapshot);
    fLastRevision := CurrentRevision;
    PreviousRouteIndex := fPresentedRouteIndex;
    ApplySnapshot(fSnapshot);
    { FillSnapshot применяет выбранные рабочим потоком привязки в UI-потоке.
      Сохраняем переход до следующего сравнения конфигурации владельцем. }
    if PreviousRouteIndex <> fPresentedRouteIndex then RememberSettings;
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
  lDuration: Double;
  lKeepTimeX, lTimeZoomed: Boolean;
  lTimeMin, lTimeMax: Double;
  lRouteIndex: Integer;
  lKeepRouteScale: Boolean;
  lFrequencyMin, lFrequencyMax: Double;
  lTimeYMin, lTimeYMax, lHammerYMin, lHammerYMax: Double;
  lFrequencyYMin, lFrequencyYMax: Double;
  lFrequencyZoomed: Boolean;
begin
  lRouteIndex := -1;
  if fRouteService <> nil then lRouteIndex := fRouteService.Route.CurrentIndex;
  lKeepRouteScale := (fPresentedRouteIndex >= 0) and
    (lRouteIndex <> fPresentedRouteIndex);
  lFrequencyMin := fFrequencyPage.XMinValue;
  lFrequencyMax := fFrequencyPage.XMaxValue;
  lFrequencyZoomed := fFrequencyPage.ZoomedX;
  lTimeYMin := fTimeAxis.MinValue;
  lTimeYMax := fTimeAxis.MaxValue;
  lFrequencyYMin := fFrequencyAxis.MinValue;
  lFrequencyYMax := fFrequencyAxis.MaxValue;
  lHammerYMin := 0;
  lHammerYMax := 0;
  if fHammerTimeAxis <> nil then
  begin
    lHammerYMin := fHammerTimeAxis.MinValue;
    lHammerYMax := fHammerTimeAxis.MaxValue;
  end;
  { После инициализации масштаб X задаёт пользователь и навигация его не
    сбрасывает. ZoomedX показывает факт масштабирования, а не владельца диапазона. }
  lTimeZoomed := fTimePage.ZoomedX;
  lKeepTimeX := fTimePage.HasPresetXRange or lTimeZoomed;
  lTimeMin := fTimePage.XMinValue;
  lTimeMax := fTimePage.XMaxValue;
  fSnapshot := ASnapshot;
  { Only an incoming service presentation acknowledges an accepted request;
    repainting local state after release must not acknowledge itself. }
  if fWindowAcceptedPending and
     SameFilterWindow(ASnapshot.FilterWindow, fWindowAccepted) then
    fWindowAcceptedPending := False;
  lDuration := 0;
  if (fComponent <> nil) and (fComponent.SampleRateHz > 0) then
    lDuration := fComponent.CaptureSamples / fComponent.SampleRateHz;
  if lDuration <= 0 then lDuration := ASnapshot.CaptureDurationSeconds;
  fTimePage.HasPresetXRange := lDuration > 0;
  if fTimePage.HasPresetXRange then
  begin
    fTimePage.PresetMinXValue := 0;
    fTimePage.PresetMaxXValue := lDuration;
  end;
  ApplyCurvePalette;
  Inc(fExtremaDataRevision);
  UpdateImpactPosition;
  UpdateCommandAvailability;
  UpdateFilterWindow;
  PresentWorkspace;
  if not lKeepTimeX then
    FitTimePage
  else if (ASnapshot.ImpactCount > 0) and
     ((ASnapshot.ImpactIndex <> fFitImpactIndex) or
      (ASnapshot.ImpactCount <> fFitImpactCount)) then
    FitZoomY(fTimePage);
  if lKeepTimeX and (lTimeMax > lTimeMin) then
  begin
    fTimePage.XMinValue := lTimeMin;
    fTimePage.XMaxValue := lTimeMax;
    fTimePage.ZoomedX := lTimeZoomed;
    fChart.Redraw;
  end;
  fFitImpactIndex := ASnapshot.ImpactIndex;
  fFitImpactCount := ASnapshot.ImpactCount;
  if lKeepRouteScale then
  begin
    fFrequencyPage.XMinValue := lFrequencyMin;
    fFrequencyPage.XMaxValue := lFrequencyMax;
    fFrequencyPage.ZoomedX := lFrequencyZoomed;
    fTimeAxis.MinValue := lTimeYMin;
    fTimeAxis.MaxValue := lTimeYMax;
    fFrequencyAxis.MinValue := lFrequencyYMin;
    fFrequencyAxis.MaxValue := lFrequencyYMax;
    if (fHammerTimeAxis <> nil) and (lHammerYMax > lHammerYMin) then
    begin
      fHammerTimeAxis.MinValue := lHammerYMin;
      fHammerTimeAxis.MaxValue := lHammerYMax;
    end;
    fChart.Redraw;
  end;
  fPresentedRouteIndex := lRouteIndex;
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
begin
  { Контейнер графика хранится в форме Lazarus и остаётся видимым при
    масштабировании. Страницы OglChart создаются при запуске как узлы рендерера. }
  fChart := TImpactWindowChart.Create(Self);
  TImpactWindowChart(fChart).OnWindowCaptureLost := @CancelWindowDrag;
  fChart.Parent := ChartHostPan;
  fChart.Align := alClient;
  fChart.AutoResizeViewport := True;
  fChart.OnMouseMove := @chartMouseMove;
  fChart.OnMouseDown := @chartMouseDown;
  fChart.OnMouseUp := @chartMouseUp;
  fChart.OnDblClick := @chartDblClick;
  fChart.OnCursorChanged := @chartCursorChanged;
  fChart.OnAfterRender := @DrawFilterWindow;
  fChart.OnKeyDown := @WindowKeyDown;
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
  fTriggerCursor := TChartHorizontalCursor.Create;
  fTriggerCursor.Name := 'TriggerLevel';
  fTriggerCursor.Axis := fTimeAxis;
  fTriggerCursor.Color := OglChartColorToGL(clRed);
  fTriggerCursor.LineWidth := 2;
  fTriggerCursor.StipplePattern := $0F0F;
  fTimePage.AddChild(fTriggerCursor);
  fFrequencyPage := TChartPage.Create;
  fFrequencyPage.Name := 'FrequencyPage';
  fFrequencyPage.Caption := 'Частота';
  fFrequencyPage.Align := cpaAuto;
  { Диапазон оси восстанавливается обработчиком chartDblClick, а не автоподбором. }
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
  fTimeCursor.Color := OglChartColorToGL(clBlue);
  fTimeCursor.ShowLabel := False;
  fChartModel.AlignPagesAuto;
end;

procedure TRecorderImpactHammerView.ConfigureTimeAxes;
var
  lAxis: TChartAxis;
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
  if fTriggerCursor <> nil then fTriggerCursor.Axis := lAxis;
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
  { Границы частоты — сохранённые настройки измерения. Применяем их после
    обновления кривых, чтобы автоподбор графика не заменил верхнюю границу. }
  fFrequencyPage.PresetMinXValue := AAxisState.XMin;
  fFrequencyPage.PresetMaxXValue := AAxisState.XMax;
  SetRecorderFrfDisplayRange(AAxisState.XMin,AAxisState.XMax);
  fFrequencyPage.HasPresetXRange := True;
  if not fFrequencyPage.ZoomedX then
  begin
    fFrequencyPage.XMinValue := AAxisState.XMin;
    fFrequencyPage.XMaxValue := AAxisState.XMax;
  end;
  { Автомасштабирование Y выбирает верхнюю границу, сохраняя заданный минимум. }
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

procedure TRecorderImpactHammerView.RefreshExtrema;
var
  lType: TRecorderImpactResultType;
  lFrame: TRecorderImpactPresentationFrame;
begin
  if fComponent = nil then Exit;
  lType := ActiveFrequencyResult;
  InvalidateExtrema;
  if BuildPresentationFrame(lType, fComponent.AxisStates[lType], lFrame) then
    PresentExtrema(lType, lFrame);
  fChart.Redraw;
end;

procedure TRecorderImpactHammerView.PeakSelectionChange(Sender: TObject);
begin
  RefreshExtrema;
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

procedure TRecorderImpactHammerView.SetPeakThresholdFromPixel(AY: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
begin
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  lRect := lRenderer.GetPageContentRect(fFrequencyPage);
  fPeakThreshold := Max(1E-9, lRenderer.PixelToAxisValue(fFrequencyAxis,
    EnsureRange(AY, lRect.Top, lRect.Bottom), lRect.Bottom, lRect.Top));
  UpdatePeakLine;
end;

procedure TRecorderImpactHammerView.PresentExtrema(
  AType: TRecorderImpactResultType;
  const AFrame: TRecorderImpactPresentationFrame);
var
  lCurveIndex: Integer;
  lLabelIndex: Integer;
  lPeakIndex: Integer;
  lFirstPeak: Integer;
  lSelectedCurve: Integer;
  lAxisState: TImpactResultAxisState;
  lSelectedPeak: TRcPeak;
  lHasSelectedPeak, lIsSelected: Boolean;

  procedure EnsureLabel;
  begin
    if lLabelIndex >= Length(fExtremaLabels) then
    begin
      SetLength(fExtremaLabels, lLabelIndex + 1);
      fExtremaLabels[lLabelIndex] := TChartFlagLabel.Create;
      fExtremaLabels[lLabelIndex].Name :=
        Format('ImpactExtremum%d', [lLabelIndex]);
      fExtremaLabels[lLabelIndex].AttachToAllTrends := False;
      fExtremaLabels[lLabelIndex].AutoLayout := True;
      fFrequencyPage.AddChild(fExtremaLabels[lLabelIndex]);
    end;
  end;

  procedure ShowLabel(const APeak: TRcPeak; AHighlighted: Boolean);
  begin
    EnsureLabel;
    fExtremaLabels[lLabelIndex].Trend := fChartSeries[AType][lCurveIndex];
    fExtremaLabels[lLabelIndex].AnchorX := APeak.Frequency;
    fExtremaLabels[lLabelIndex].Text := Format('%.4g Hz; %.4g',
      [APeak.Frequency, APeak.Value]);
    fExtremaLabels[lLabelIndex].Highlighted := AHighlighted;
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
  lSelectedCurve := clbCurves.SelectedIndex;
  lHasSelectedPeak := (fPeakForm <> nil) and
    fPeakForm.TryGetSelectedPeak(lSelectedPeak);
  lAxisState := fComponent.AxisStates[AType];
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
      AFrame.Curves[lCurveIndex].Name, fPeaks,
      lAxisState.XMin, lAxisState.XMax);
    for lPeakIndex := lFirstPeak to High(fPeaks) do
    begin
      lIsSelected := lHasSelectedPeak and
        (fPeaks[lPeakIndex].Curve = lSelectedPeak.Curve) and
        (fPeaks[lPeakIndex].Index = lSelectedPeak.Index) and
        SameValue(fPeaks[lPeakIndex].Frequency, lSelectedPeak.Frequency);
      if (lSelectedCurve < 0) or (lSelectedCurve = lCurveIndex) or
         lIsSelected then
        ShowLabel(fPeaks[lPeakIndex], lIsSelected);
    end;
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
  lNow: QWord;
begin
  if Sender <> fChart then
    Exit;
  if fWindowDrag <> 0 then
  begin
    { Capture loss has its own cancellation callback. Backend hover messages
      without button flags must not discard a still-captured drag. }
    if ssLeft in Shift then MoveWindowHandle(X, Y);
    Exit;
  end;
  if fPeakDragging then
  begin
    SetPeakThresholdFromPixel(Y);
    lNow := GetTickCount64;
    if lNow - fLastPeakRefreshTick >= 25 then
    begin
      RefreshExtrema;
      fLastPeakRefreshTick := lNow;
    end
    else
      fChart.Redraw;
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
  lLevel: Double;
begin
  if (fTriggerCursor = nil) or (fComponent = nil) then Exit;
  lLevel := AValue;
  if fComponent.TriggerPolarity = itpNegative then lLevel := -lLevel;
  if SameValue(lLevel, fDrawLevel) then Exit;
  fTriggerCursor.Y := lLevel;
  lblTriggerLevel.Caption := Format('Порог: %.6g', [lLevel]);
  fDrawLevel := lLevel;
end;

procedure TRecorderImpactHammerView.FitTimePage;
begin
  FitPageZoom(fTimePage);
  if fTimePage.HasPresetXRange then
  begin
    fTimePage.XMinValue := fTimePage.PresetMinXValue;
    fTimePage.XMaxValue := fTimePage.PresetMaxXValue;
    fTimePage.ZoomedX := False;
  end;
  fChart.Redraw;
end;

procedure TRecorderImpactHammerView.RestoreFrequencyPage;
var
  lState: TImpactResultAxisState;
begin
  if fComponent = nil then Exit;
  lState := fComponent.AxisStates[ActiveFrequencyResult];
  fFrequencyPage.ZoomedX := False;
  ApplyConfiguredFrequencyRange(lState);
  fFrequencyPage.ZoomedX := False;
  fFrequencyAxis.HasPresetRange := False;
  if lState.YMax > lState.YMin then
  begin
    fFrequencyAxis.MinValue := lState.YMin;
    fFrequencyAxis.MaxValue := lState.YMax;
  end;
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
  fWindowDrag := WindowHandleAt(X, Y);
  if fWindowDrag <> 0 then
  begin
    fWindowDragStart := fWindowPreview;
    fWindowPreviewDirty := False;
    fWindowLastSubmit := 0;
    fChart.MouseInputEnabled := False;
    TImpactWindowChart(fChart).MouseCapture := True;
    Exit;
  end;
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
  if (fWindowDrag <> 0) and (Button = mbLeft) then
  begin
    MoveWindowHandle(X, Y);
    fWindowDrag := 0;
    fWindowTimer.Enabled := False;
    fChart.MouseInputEnabled := True;
    TImpactWindowChart(fChart).MouseCapture := False;
    CommitFilterWindow;
    Exit;
  end;
  if fPeakDragging and (Button = mbLeft) then
  begin
    fPeakDragging := False;
    fChart.MouseInputEnabled := True;
    SetPeakThresholdFromPixel(Y);
    RefreshExtrema;
    fLastPeakRefreshTick := GetTickCount64;
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
  lSelected := clbCurves.SelectedIndex;
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
    // По plgEvalFRF: ширина на уровне половины амплитуды делится на 2*f_peak.
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
    clbCurves.BeginUpdate;
    try
      clbCurves.Clear;
      for I := 0 to High(fSnapshot.Results[AType].Curves) do
        clbCurves.AddItem(fSnapshot.Results[AType].Curves[I].Name,
          CurveColor(I), fSnapshot.Results[AType].Curves[I].Visible);
    finally
      clbCurves.EndUpdate;
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

procedure TRecorderImpactHammerView.curveVisibilityClickCheck(Sender: TObject;
  AIndex: Integer);
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
  if (AIndex < 0) or
    (AIndex > High(fSnapshot.Results[ResultType].Curves)) then
    Exit;
  lVisible := clbCurves.Checked[AIndex];
  CurveId := fSnapshot.Results[ResultType].Curves[AIndex].CurveId;
  if fSnapshot.Results[ResultType].Curves[AIndex].ReadOnly then
  begin
    fSnapshot.Results[ResultType].Curves[AIndex].Visible := lVisible;
    PresentResult(ResultType);
    Exit;
  end;
  for lType := Low(TRecorderImpactResultType) to
    High(TRecorderImpactResultType) do
    for I := 0 to High(fSnapshot.Results[lType].Curves) do
      if fSnapshot.Results[lType].Curves[I].CurveId = CurveId then
        if (CurveId = 0) and (lType = irtTime) then
          fSnapshot.Results[lType].Curves[I].Visible := True
        else
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
begin
  if fUpdatingOptions or (fComponent = nil) then Exit;
  RefreshExtrema;
end;

procedure TRecorderImpactHammerView.extremaChange(Sender: TObject);
begin
  if fComponent <> nil then
    fComponent.ShowExtrema := chkExtrema.Checked;
  if chkExtrema.Checked then
  begin
    if fPeakForm = nil then
    begin
      fPeakForm := TRcFrfPeakForm.Create(Self);
      fPeakForm.OnPeakSelected := @PeakSelectionChange;
    end;
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
begin
  if fWindowDrag <> 0 then Exit;
  fUpdatingWindow := True;
  try
    if fWindowAcceptedPending then fWindowPreview := fWindowAccepted
    else fWindowPreview := fSnapshot.FilterWindow;
    chkFilterWindow.Checked := fWindowPreview.Enabled;
    fTimeCursor.X1 := fWindowPreview.StartSeconds;
    fTimeCursor.X2 := fWindowPreview.EndSeconds;
    fTimeCursor.Visible := chkFilterWindow.Checked;
  finally
    fUpdatingWindow := False;
  end;
end;

procedure TRecorderImpactHammerView.filterWindowChange(Sender: TObject);
var
  lEnabled: Boolean;
begin
  if fUpdatingWindow then Exit;
  lEnabled := chkFilterWindow.Checked;
  CancelWindowDrag(Sender);
  fWindowPreview.Enabled := lEnabled;
  CommitFilterWindow;
end;

procedure TRecorderImpactHammerView.CommitFilterWindow;
var
  lError: string;
begin
  if fApplicationService = nil then
  begin
    UpdateFilterWindow;
    Exit;
  end;
  if fApplicationService.TrySetFilterWindow(fWindowPreview, lError) then
  begin
    fWindowAccepted := fWindowPreview;
    fWindowAcceptedPending := True;
    fWindowRefreshPending := True;
    fWindowTimer.Enabled := True;
    fWindowPreviewDirty := False;
    fWindowLastSubmit := GetTickCount64;
  end
  else
  begin
    fWindowPreviewDirty := False;
    lblCaptureStatus.Caption := lError;
  end;
  UpdateFilterWindow;
  fChart.Redraw;
end;

procedure TRecorderImpactHammerView.WindowPreviewTick(Sender: TObject);
begin
  if (fWindowDrag = 0) and not fWindowRefreshPending then
  begin
    fWindowTimer.Enabled := False;
    Exit;
  end;
  if fWindowPreviewDirty and
     (GetTickCount64 - fWindowLastSubmit >= 40) then CommitFilterWindow;
  { Present completed worker generations even when the mouse is stationary;
    only changed revisions build a snapshot, never every MouseMove. }
  if (fApplicationService <> nil) and
     (fApplicationService.Revision <> fLastRevision) then RefreshControl(nil, 0);
  { Releasing the mouse or switching the checkbox is not the end of the
    asynchronous edit: present its completed worker generation first. }
  if fWindowRefreshPending and not fWindowAcceptedPending and
     not fSnapshot.FilterRebuildPending then fWindowRefreshPending := False;
  if (fWindowDrag = 0) and not fWindowRefreshPending then
    fWindowTimer.Enabled := False;
end;

procedure TRecorderImpactHammerView.CancelWindowDrag(Sender: TObject);
begin
  if fWindowDrag = 0 then Exit;
  fWindowDrag := 0;
  fWindowTimer.Enabled := False;
  fWindowPreview := fWindowDragStart;
  CommitFilterWindow;
  fChart.MouseInputEnabled := True;
  TImpactWindowChart(fChart).MouseCapture := False;
  UpdateFilterWindow;
  fChart.Redraw;
end;

procedure TRecorderImpactHammerView.WindowKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (fWindowDrag <> 0) then
  begin
    CancelWindowDrag(Sender);
    Key := 0;
  end;
end;

function TRecorderImpactHammerView.WindowHandleAt(X, Y: Integer): Integer;
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  lX0, lX1, lY0, lY1: Double;
begin
  Result := 0;
  fWindowGrabOffset := 0;
  if not fWindowPreview.Enabled then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  lRect := lRenderer.GetPageContentRect(fTimePage);
  if (X < lRect.Left) or (X > lRect.Right) or
     (Y < lRect.Top) or (Y > lRect.Bottom) then Exit;
  { Dedicated bottom handles remain unambiguous when an exponential marker
    shares the same time coordinate as a rectangular boundary. }
  if Y >= lRect.Bottom - 16 then
  begin
    lX0 := lRenderer.XValueToPixel(fTimePage, nil,
      fWindowPreview.StartSeconds, lRect.Left, lRect.Right);
    lX1 := lRenderer.XValueToPixel(fTimePage, nil,
      fWindowPreview.EndSeconds, lRect.Left, lRect.Right);
    if Abs(X - (lX0 + 14)) <= 6 then
    begin fWindowGrabOffset := 14; Exit(1) end;
    if Abs(X - (lX1 - 14)) <= 6 then
    begin fWindowGrabOffset := -14; Exit(2) end;
  end;
  lX0 := lRenderer.XValueToPixel(fTimePage, nil,
    fWindowPreview.ExponentialStartSeconds, lRect.Left, lRect.Right);
  lX1 := lRenderer.XValueToPixel(fTimePage, nil,
    fWindowPreview.ExponentialEndSeconds, lRect.Left, lRect.Right);
  lY0 := lRect.Top + 8;
  lY1 := lY0 + Max(1, lRect.Bottom - lRect.Top - 16) *
    (1 - fWindowPreview.ExponentialEndLevel);
  if (Abs(X - lX1) <= 8) and (Abs(Y - lY1) <= 8) then Exit(4);
  if (Abs(X - lX0) <= 8) and (Abs(Y - lY0) <= 8) then Exit(3);
  lX0 := lRenderer.XValueToPixel(fTimePage, nil,
    fWindowPreview.StartSeconds, lRect.Left, lRect.Right);
  lX1 := lRenderer.XValueToPixel(fTimePage, nil,
    fWindowPreview.EndSeconds, lRect.Left, lRect.Right);
  if Abs(X - lX0) <= 8 then Exit(1);
  if Abs(X - lX1) <= 8 then Exit(2);
end;

procedure TRecorderImpactHammerView.MoveWindowHandle(X, Y: Integer);
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  lTime, lEpsilon, lDuration: Double;
  lBefore: TRecorderImpactFilterWindow;
begin
  lBefore := fWindowPreview;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if (lRenderer = nil) or (fWindowDrag = 0) then Exit;
  lRect := lRenderer.GetPageContentRect(fTimePage);
  lDuration := fSnapshot.CaptureDurationSeconds;
  { Partial ring captures are shorter than the configured filter domain. }
  if (fComponent <> nil) and (fComponent.SampleRateHz > 0) then
    lDuration := fComponent.CaptureSamples / fComponent.SampleRateHz;
  if lDuration <= 0 then Exit;
  lEpsilon := Max(1E-12, lDuration * 1E-6);
  if (fComponent <> nil) and (fComponent.SampleRateHz > 0) then
    lEpsilon := Min(lDuration, 1 / fComponent.SampleRateHz);
  lTime := EnsureRange(lRenderer.PixelToXValue(fTimePage, nil, X - fWindowGrabOffset,
    lRect.Left, lRect.Right), 0, lDuration);
  with fWindowPreview do
    case fWindowDrag of
      1: begin
           StartSeconds := EnsureRange(lTime, 0, EndSeconds - lEpsilon);
         end;
      2: begin
           EndSeconds := EnsureRange(lTime, StartSeconds + lEpsilon, lDuration);
         end;
      3: ExponentialStartSeconds := EnsureRange(lTime, 0,
           ExponentialEndSeconds - lEpsilon);
      4: begin
           ExponentialEndSeconds := EnsureRange(lTime,
             ExponentialStartSeconds + lEpsilon, lDuration);
           ExponentialEndLevel := EnsureRange(1 -
             (Y - lRect.Top - 8) / Max(1, lRect.Bottom - lRect.Top - 16),
             1E-6, 1);
         end;
    end;
  fTimeCursor.X1 := fWindowPreview.StartSeconds;
  fTimeCursor.X2 := fWindowPreview.EndSeconds;
  if not SameFilterWindow(lBefore, fWindowPreview) then
  begin
    fWindowPreviewDirty := True;
    fWindowTimer.Enabled := True;
    if GetTickCount64 - fWindowLastSubmit >= 40 then CommitFilterWindow;
  end;
  fChart.Redraw;
end;

procedure TRecorderImpactHammerView.DrawFilterWindow(Sender: TObject;
  ARenderTimeMs: Double);
var
  lRenderer: TOpenGLChartRenderer;
  lRect: TChartPixelRect;
  lIndex: Integer;
  lTime, lLevel, lSpan, lX, lY, lHeight: Double;
  lDuration: Double;

  procedure RectCursor(ATime: Double; ADirection: Integer);
  var lHandleX: Double;
  begin
    lX := lRenderer.XValueToPixel(fTimePage, nil, ATime,
      lRect.Left, lRect.Right);
    glBegin(GL_LINES);
    glVertex2d(lX, lRect.Top);
    glVertex2d(lX, lRect.Bottom);
    lHandleX := lX + ADirection * 14;
    glVertex2d(lX, lRect.Bottom - 8);
    glVertex2d(lHandleX, lRect.Bottom - 8);
    glEnd;
    glBegin(GL_QUADS);
    glVertex2d(lHandleX - 6, lRect.Bottom - 14);
    glVertex2d(lHandleX + 6, lRect.Bottom - 14);
    glVertex2d(lHandleX + 6, lRect.Bottom - 2);
    glVertex2d(lHandleX - 6, lRect.Bottom - 2);
    glEnd;
  end;

  procedure Handle(ATime, ALevel: Double);
  begin
    lX := lRenderer.XValueToPixel(fTimePage, nil, ATime,
      lRect.Left, lRect.Right);
    lY := lRect.Top + 8 + (1 - ALevel) * lHeight;
    glBegin(GL_LINE_LOOP);
    glVertex2d(lX - 7, lY - 7);
    glVertex2d(lX + 7, lY - 7);
    glVertex2d(lX + 7, lY + 7);
    glVertex2d(lX - 7, lY + 7);
    glEnd;
  end;

begin
  if not fWindowPreview.Enabled then Exit;
  lRenderer := TOpenGLChartRenderer(fChart.GetRenderer);
  if lRenderer = nil then Exit;
  lRect := lRenderer.GetPageContentRect(fTimePage);
  lHeight := Max(1, lRect.Bottom - lRect.Top - 16);
  lSpan := Max(1E-12, fWindowPreview.ExponentialEndSeconds -
    fWindowPreview.ExponentialStartSeconds);
  lDuration := fSnapshot.CaptureDurationSeconds;
  if (fComponent <> nil) and (fComponent.SampleRateHz > 0) then
    lDuration := fComponent.CaptureSamples / fComponent.SampleRateHz;
  { Last OpenGL overlay pass: normalized amplitude is independent of signal
    axes and cannot affect auto-fit or disappear after SwapBuffers. }
  glPushAttrib(GL_ENABLE_BIT or GL_CURRENT_BIT or GL_LINE_BIT or GL_SCISSOR_BIT);
  try
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_LINE_STIPPLE);
    glEnable(GL_SCISSOR_TEST);
    glScissor(lRect.Left, fChart.Height - lRect.Bottom,
      Max(0, lRect.Right - lRect.Left), Max(0, lRect.Bottom - lRect.Top));
    glColor3f(0, 0, 1);
    glLineWidth(3);
    RectCursor(fWindowPreview.StartSeconds, 1);
    RectCursor(fWindowPreview.EndSeconds, -1);
    glColor3f(1, 0.5, 0);
    glLineWidth(2);
    glBegin(GL_LINE_STRIP);
    for lIndex := 0 to 128 do
    begin
      lTime := lIndex * lDuration / 128;
      if lTime <= fWindowPreview.ExponentialStartSeconds then lLevel := 1
      else lLevel := Exp(Ln(Max(1E-6, fWindowPreview.ExponentialEndLevel)) *
        (lTime - fWindowPreview.ExponentialStartSeconds) / lSpan);
      lX := lRenderer.XValueToPixel(fTimePage, nil, lTime,
        lRect.Left, lRect.Right);
      glVertex2d(lX, lRect.Top + 8 + (1 - lLevel) * lHeight);
    end;
    glEnd;
    Handle(fWindowPreview.ExponentialStartSeconds, 1);
    Handle(fWindowPreview.ExponentialEndSeconds,
      fWindowPreview.ExponentialEndLevel);
  finally
    glPopAttrib;
  end;
end;

procedure TRecorderImpactHammerView.chartCursorChanged(Sender: TObject;
  ACursor: TObject);
var
  ChartCursor: TChartCursor;
begin
  if (ACursor is TChartCursor) and
    (TChartCursor(ACursor).Parent = fFrequencyPage) then
  begin
    ChartCursor:=TChartCursor(ACursor);
    if ChartCursor.Visible then
    begin
      if fComponent<>nil then
        with fComponent.AxisStates[ActiveFrequencyResult] do
          SetRecorderFrfDisplayRange(XMin,XMax);
      { У двойного курсора две подвижные частотные линии. Определяем, какая
        линия изменилась, чтобы при перетаскивании X1 не читать всегда X2. }
      if (ChartCursor.CursorType=cctDouble) and
        ((fTrackedFrequencyCursor<>ChartCursor) or
         not SameValue(fFrequencyCursorX2,ChartCursor.X2)) then
        SetRecorderSelectedFrfFrequency(ChartCursor.X2)
      else if (fTrackedFrequencyCursor<>ChartCursor) or
        not SameValue(fFrequencyCursorX1,ChartCursor.X1) then
        SetRecorderSelectedFrfFrequency(ChartCursor.X1);
      fTrackedFrequencyCursor:=ChartCursor;
      fFrequencyCursorX1:=ChartCursor.X1;
      fFrequencyCursorX2:=ChartCursor.X2;
    end;
    Exit;
  end;
  { Time-window boundaries are edited by our capture/release gesture above;
    an ordinary measurement cursor must not enqueue a DSP recalculation. }
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
  fUpdatingTrigger := True;
  try
    chkTrigger.Checked := fSnapshot.TriggerEnabled;
  finally
    fUpdatingTrigger := False;
  end;
  chkTrigger.Enabled := fApplicationService <> nil;
  fUpdatingRouteTagSync := True;
  try
    chkRouteTagSync.Checked := fSnapshot.RouteTagSync;
    chkRouteAuto.Checked := fSnapshot.RouteAutoMode;
  finally
    fUpdatingRouteTagSync := False;
  end;
  chkRouteTagSync.Enabled := (fApplicationService <> nil) and
    fSnapshot.RecorderRunning and (fComponent <> nil) and
    ((fComponent.RoutePointTagId <> 0) or (fComponent.RoutePointTagName <> ''));
  chkRouteAuto.Enabled := (fApplicationService <> nil) and fSnapshot.RecorderRunning;
  if fRouteForm <> nil then
    fRouteForm.UpdateAutomationState(fSnapshot.RouteAutoMode, fSnapshot.RouteTagSync);
  lblCaptureStatus.Caption := fSnapshot.StatusText;
  lblCaptureStatus.Hint := fSnapshot.StatusText;
  btnCapturePortion.Enabled := fSnapshot.CanCapturePortion;
  chkScenario.Enabled:=fApplicationService<>nil;
  btnRoute.Enabled:=(fApplicationService<>nil) and (fComponent<>nil) and
    fComponent.ScenarioEnabled;
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

procedure TRecorderImpactHammerView.TriggerChange(Sender: TObject);
begin
  if fUpdatingTrigger or (fApplicationService = nil) then Exit;
  fApplicationService.SetTriggerEnabled(chkTrigger.Checked);
  RefreshControl(nil, 0);
end;

procedure TRecorderImpactHammerView.btnCapturePortionClick(Sender: TObject);
var ErrorText:string;
begin
  if fApplicationService=nil then Exit;
  fApplicationService.SetRouteAutoMode(False);
  if fApplicationService.TryCaptureRingPortion(ErrorText) then
  begin
    fUpdatingResultReview:=True;
    try
      fResultReviewEnabled:=False;
      chkResultReview.Checked:=False;
      chkResultValues.Enabled:=False;
    finally fUpdatingResultReview:=False; end;
  end
  else if ErrorText<>'' then
    MessageDlg(ErrorText,mtInformation,[mbOK],0);
  RefreshControl(nil,0);
end;

procedure TRecorderImpactHammerView.btnGeometryBindingsClick(Sender: TObject);
begin
  if fComponent = nil then Exit;
  if fBindingForm = nil then
    fBindingForm := TRecorderImpactGeometryBindingDialog.ShowBinding(
      Self, fComponent, @GeometryPreview)
  else
  begin
    fBindingForm.Show;
    fBindingForm.BringToFront;
  end;
end;

procedure TRecorderImpactHammerView.GeometryPreview(Sender: TObject);
var Error: string;
begin
  if (fComponent <> nil) and (fRouteService <> nil) and
    (chkResultValues.Checked <> fComponent.ResultValuesVisible) then
  begin
    fUpdatingResultReview := True;
    try chkResultValues.Checked := fComponent.ResultValuesVisible;
    finally fUpdatingResultReview := False end;
    if not fRouteService.SetResultReview(fResultReviewEnabled,
      fComponent.ResultValuesVisible, Error) then
      lblCaptureStatus.Caption := Error;
  end;
  if fApplicationService <> nil then fApplicationService.SavePointBindings;
  RememberSettings;
end;

procedure TRecorderImpactHammerView.SaveGeometryStep;
var Entry: TRecorderFrfRouteEntry; Binding: TRecorderFrfRouteBinding;
  I, Index, Count: Integer;
begin
  if (fRouteService = nil) or (fComponent = nil) then Exit;
  fRouteService.Route.ConfigFileName := fComponent.RouteConfigFileName;
  if fRouteService.Route.Count = 0 then
  begin
    Entry := Default(TRecorderFrfRouteEntry);
    Entry.PointLabel := '1';
    fRouteService.Route.Add(Entry);
    fRouteService.Route.CurrentIndex := 0;
  end;
  Index := fRouteService.Route.CurrentIndex;
  if (Index < 0) or (Index >= fRouteService.Route.Count) then Exit;
  Entry := fRouteService.Route.Entries[Index];
  SetLength(Entry.Bindings, fComponent.ResponseCount);
  Count := 0;
  for I := 0 to fComponent.ResponseCount - 1 do
    if (fComponent.Responses[I].PointNumber > 0) and
      (fComponent.Responses[I].Target3dNodeId <> 0) and
      (fComponent.Responses[I].PointLabel <> '') then
    begin
      Binding := Default(TRecorderFrfRouteBinding);
      Binding.ChannelIndex := I;
      Binding.PointNumber := fComponent.Responses[I].PointNumber;
      Binding.SceneComponentId := fComponent.Target3dComponentId;
      Binding.TargetNodeId := fComponent.Responses[I].Target3dNodeId;
      Binding.TargetNodeName := fComponent.Responses[I].Target3dNodeName;
      Binding.PointLabel := fComponent.Responses[I].PointLabel;
      Entry.Bindings[Count] := Binding;
      Inc(Count);
    end;
  SetLength(Entry.Bindings, Count);
  fRouteService.Route.UpdateEntry(Index, Entry);
  UpdateRoutePointControls;
end;

procedure TRecorderImpactHammerView.MdbContextChanged(Sender: TObject);
begin
  if fMdbUpdateQueued then Exit;
  fMdbUpdateQueued := True;
  { Объединяем изменения BasePath/ObjectId/TestId и читаем XML после фиксации
    выбора, а не внутри обработчика свойства другой модели. }
  Application.QueueAsyncCall(@ApplyMdbContextChange, 0);
end;

procedure TRecorderImpactHammerView.ApplyMdbContextChange(Data: PtrInt);
begin
  fMdbUpdateQueued := False;
  fMdbContextRevision := High(QWord);
  RefreshControl(nil, 0);
end;

function TRecorderImpactHammerView.EnsureRouteDirectory: Boolean;
var Directory: string;
begin
  Result := False;
  if (fRouteService = nil) or (fComponent = nil) then Exit;
  fRouteService.Route.ConfigFileName := fComponent.RouteConfigFileName;
  if (fRouteService.Route.Directory<>'') and (fRouteForm<>nil) and
    not fRouteForm.chkMdb.Checked then Exit(True);
  Directory := Trim(fComponent.ExportPath);
  if (fRouteForm <> nil) and fRouteForm.chkMdb.Checked then Directory := '';
  if Directory = '' then
  begin
    Directory := RecorderMeraObjectDirectory;
    if Directory = '' then Directory := RecorderMdbActiveObjectDirectory;
    if Directory <> '' then Directory := IncludeTrailingPathDelimiter(Directory) + 'frf';
  end;
  if Directory = '' then
  begin
    fRouteService.Route.SetDirectory('');
    Exit;
  end;
  Directory := IncludeTrailingPathDelimiter(Directory) + 'track';
  if SameFileName(ExcludeTrailingPathDelimiter(fRouteService.Route.Directory),
    ExcludeTrailingPathDelimiter(ExpandFileName(Directory))) then Exit(True);
  try
    if (fRouteService.Route.Count = 0) and
      fRouteService.Route.HasManifest(Directory) then
      fRouteService.Route.Load(Directory)
    else
      fRouteService.Route.SetDirectory(Directory);
    Result := True;
  except
    on E: Exception do MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderImpactHammerView.ScenePointSelected(
  const ASelection: TRecorderModelPointSelection);
var
  lStep, lOffset, lBindingIndex: Integer;
  lEntry: TRecorderFrfRouteEntry;
  lBinding: TRecorderFrfRouteBinding;
  lScene, lError: string;
begin
  if fSelectingReviewPoint or not fResultReviewEnabled or
    (fRouteService = nil) or (fComponent = nil) or
    (fRouteService.Route.Count = 0) then Exit;
  { Если вершина входит в несколько шагов, сохраняем текущий шаг. Уведомления
    сцены приходят в UI-потоке; переход не удаляет несохранённые данные в памяти. }
  for lOffset := 0 to fRouteService.Route.Count - 1 do
  begin
    lStep := (Max(0, fRouteService.Route.CurrentIndex) + lOffset) mod
      fRouteService.Route.Count;
    lEntry := fRouteService.Route[lStep];
    for lBindingIndex := 0 to High(lEntry.Bindings) do
    begin
      lBinding := lEntry.Bindings[lBindingIndex];
      lScene := lBinding.SceneComponentId;
      if lScene = '' then lScene := fComponent.Target3dComponentId;
      if (lScene <> ASelection.SceneComponentId) or
        (lBinding.TargetNodeId <> ASelection.NodeId) or
        (lBinding.PointNumber <> ASelection.PointNumber) then Continue;
      fSelectingReviewPoint := True;
      try
        if fApplicationService <> nil then
        begin
          fApplicationService.SetRouteAutoMode(False);
          fApplicationService.SetRouteTagSync(False);
        end;
        if not fRouteService.SelectRoutePoint(lStep, lError) then
        begin
          lblCaptureStatus.Caption := lError;
          Exit;
        end;
        fSelectedReviewPoint := lBinding.PointLabel;
        if fSelectedReviewPoint = '' then
          fSelectedReviewPoint := IntToStr(ASelection.PointNumber);
        RememberSettings;
        UpdateRoutePointControls;
        RefreshControl(nil, 0);
      finally fSelectingReviewPoint := False end;
      Exit;
    end;
  end;
end;

procedure TRecorderImpactHammerView.UpdateRoutePointControls;
var Count, Index: Integer; CaptionText: string;
begin
  if fUpdatingRoutePoint then Exit;
  fUpdatingRoutePoint := True;
  try
    Count := 0;
    Index := 0;
    if fRouteService <> nil then
    begin
      Count := fRouteService.Route.Count;
      Index := fRouteService.Route.CurrentIndex;
    end;
    seRoutePoint.Enabled := (fComponent <> nil) and chkScenario.Checked and (Count > 0);
    seRoutePoint.MaxValue := Max(1, Count);
    seRoutePoint.Value := EnsureRange(Index + 1, 1, Max(1, Count));
    CaptionText := 'Шаги маршрута не заданы';
    if (Index >= 0) and (Index < Count) then
      CaptionText := 'Шаг ' + IntToStr(Index + 1) + ' из ' + IntToStr(Count) + ': ' +
        fRouteService.Route.Entries[Index].PointLabel;
    if fResultReviewEnabled and (fSelectedReviewPoint <> '') then
      CaptionText := CaptionText + ' — Точка: ' + fSelectedReviewPoint;
    if lblRoutePoint.Caption <> CaptionText then lblRoutePoint.Caption := CaptionText;
    if fRouteService <> nil then
    begin
      seRoutePoint.Hint := fRouteService.Route.Directory;
      seRoutePoint.ShowHint := True;
    end;
  finally
    fUpdatingRoutePoint := False;
  end;
end;

procedure TRecorderImpactHammerView.RoutePointChange(Sender: TObject);
var Error: string;
begin
  if fUpdatingRoutePoint or not seRoutePoint.Enabled or (fRouteService = nil) then Exit;
  if not fSelectingReviewPoint then fSelectedReviewPoint := '';
  if (Sender = seRoutePoint) and (fApplicationService <> nil) then
  begin
    fApplicationService.SetRouteAutoMode(False);
    fApplicationService.SetRouteTagSync(False);
  end;
  if not fRouteService.SelectRoutePoint(seRoutePoint.Value - 1, Error) then
    MessageDlg(Error, mtError, [mbOK], 0);
  if (fBindingForm <> nil) and fBindingForm.Visible then
    fBindingForm.Initialize(fComponent, @GeometryPreview);
  RememberSettings;
  UpdateRoutePointControls;
  RefreshControl(nil, 0);
end;

procedure TRecorderImpactHammerView.RouteTagSyncChange(Sender: TObject);
begin
  if fUpdatingRouteTagSync or (fApplicationService = nil) then Exit;
  fApplicationService.SetRouteTagSync(chkRouteTagSync.Checked);
  RefreshControl(nil, 0);
end;

procedure TRecorderImpactHammerView.RouteAutoChange(Sender: TObject);
begin
  if fUpdatingRouteTagSync or (fApplicationService = nil) then Exit;
  fApplicationService.SetRouteAutoMode(chkRouteAuto.Checked);
  RememberSettings;
  RefreshControl(nil, 0);
end;

procedure TRecorderImpactHammerView.ResultReviewChange(Sender: TObject);
var Error: string;
begin
  if fUpdatingResultReview or (fRouteService = nil) then Exit;
  fUpdatingResultReview := True;
  try
    if fRouteService.SetResultReview(chkResultReview.Checked, fComponent.ResultValuesVisible, Error) then
      fResultReviewEnabled := chkResultReview.Checked
    else
    begin
      chkResultReview.Checked := fResultReviewEnabled;
      MessageDlg(Error, mtInformation, [mbOK], 0);
    end;
    chkResultValues.Enabled := fResultReviewEnabled;
    if not fResultReviewEnabled then fSelectedReviewPoint := '';
  finally
    fUpdatingResultReview := False;
  end;
  RefreshControl(nil, 0);
end;

procedure TRecorderImpactHammerView.btnRouteClick(Sender:TObject);
begin
  if (fApplicationService=nil) or (fComponent=nil) then Exit;
  if not fComponent.ScenarioEnabled then Exit;
  if not Supports(fApplicationService,IRecorderFrfRouteService,fRouteService) then Exit;
  if fRouteForm=nil then
    fRouteForm:=TRecorderFrfRouteDialog.ShowRoute(Self,fComponent,
      fRouteService.Route,@RouteStart,@RouteCapture,@RouteAssemble,
      fConfiguredRegistry)
  else
  begin
    fRouteForm.Show;
    fRouteForm.BringToFront;
  end;
end;

procedure TRecorderImpactHammerView.ScenarioChange(Sender:TObject);
begin
  if fComponent=nil then Exit;
  fComponent.ScenarioEnabled:=chkScenario.Checked;
  if not chkScenario.Checked then
  begin
    if fRouteForm<>nil then fRouteForm.Hide;
    if Supports(fApplicationService,IRecorderFrfRouteService,fRouteService) then
      fRouteService.UseLiveRoute;
  end;
  RememberSettings;
  UpdateCommandAvailability;
  if chkScenario.Checked then
  begin
    EnsureRouteDirectory;
    UpdateRoutePointControls;
    RoutePointChange(nil);
  end
  else
    UpdateRoutePointControls;
end;

procedure TRecorderImpactHammerView.RouteStart(Sender:TObject);
var Error: string;
begin
  if fRouteService = nil then Exit;
  if not fRouteService.SelectRoutePoint(fRouteService.Route.CurrentIndex, Error) then
    MessageDlg(Error, mtError, [mbOK], 0);
  if fApplicationService <> nil then fApplicationService.SavePointBindings;
  if (fBindingForm <> nil) and fBindingForm.Visible then
    fBindingForm.Initialize(fComponent, @GeometryPreview);
  RememberSettings;
  UpdateRoutePointControls;
  RefreshControl(nil, 0);
end;

procedure TRecorderImpactHammerView.RouteCapture(Sender:TObject);
var lError:string;
begin
  if not fRouteService.CaptureRouteStep(lError) then
    raise Exception.Create(lError);
end;

procedure TRecorderImpactHammerView.RouteAssemble(Sender:TObject);
var lError:string;
begin
  if not fRouteService.ShowSavedRoute(lError) then
    raise Exception.Create(lError);
end;

initialization
  TRecorderVisualControlRegistry.RegisterControl(
    TRecorderImpactHammerComponent, TRecorderImpactHammerView);

end.
