unit uRecorderImpactHammerService;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Сервис связывает идентификаторы тегов, сбор ударов, обработку сигнала и
  общий репозиторий FRF. Автоматический маршрут работает в потоке сбора без
  формы: фронт входного тега фиксирует снимок кольцевого буфера, а следующий
  импульс маршрута выдаётся после успешной записи MERA. Команды сериализуются
  отдельно от блокировки сбора; внешние теги и файлы обрабатываются вне неё. }

interface

uses
  Classes, SysUtils, Math, SyncObjs, uRecorderTags, uRecorderCoreServices,
  uRecorderStateMachine,
  u3dMotionContracts,
  uRecorderImpactHammerModel, uRecorderImpactHammer, uRecorderImpactDsp,
  uRecorderFrfContracts, uRecorderFrfRepository, uRecorderFrfRoute,
  uRecorderImpactHammerContracts, uRecorderImpactSessionContracts;

type
  TRecorderImpactHammerService = class;

  // Единственный поток-потребитель отложенных снимков: выполняет DSP, пересчёт
  // фильтров и маршрутную автоматику вне уведомлений данных и UI.
  TRecorderImpactWorker = class(TThread)
  private
    fOwner: TRecorderImpactHammerService;
    fWake: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TRecorderImpactHammerService);
    destructor Destroy; override;
    procedure Wake;
  end;

  TRecorderImpactMomentsArray = array of TRecorderImpactSpectralMoments;
  TRecorderImpactMomentsMatrix = array of TRecorderImpactMomentsArray;
  TRecorderFrfCurveArray = array of TRecorderFrfCurveData;
  TRecorderCaptureBlockArray = array of TRecorderImpactCaptureBlock;
  TRecorderImpactSampleBufferArray = array of TRecorderDoubleArray;

  { Кэширует спектральные моменты удара по Sequence для повторного усреднения. }
  TRecorderPreparedImpact = class
  public
    Sequence: QWord;
    Responses: TRecorderImpactMomentsArray;
  end;

  TRecorderImpactHammerService = class(TInterfacedObject,
    IRecorderImpactHammerApplicationService, IRecorderFrfRouteService)
  private
    fModel: TRecorderImpactHammerComponent;
    fRegistry: TRecorderTagRegistry;
    fHammerTag: TRecorderTag;
    fResponseTags: array of TRecorderTag;
    fPreloadTimes: TRecorderImpactSampleBufferArray;
    fPreloadValues: TRecorderImpactSampleBufferArray;
    fBlockTimes: TRecorderImpactSampleBufferArray;
    fBlockValues: TRecorderImpactSampleBufferArray;
    fBlockCursors: array of QWord;
    fRuntime: TRecorderImpactRuntime;
    fDsp: TRecorderImpactDspPipeline;
    fFilterDsp: TRecorderImpactDspPipeline;
    fSubscription: Integer;
    fCaptureToken: QWord;
    fManualPortion: Boolean;
    fManualRequestTick: QWord;
    fTriggerEnabled: Boolean;
    fRouteTagSync: Boolean;
    fRoutePointTag: TRecorderTag;
    fRouteAtPointTag, fRouteNextStepTag: TRecorderTag;
    fRouteAutoMode, fAutoAtPointHigh, fAutoCapturePending: Boolean;
    fAutoPulseHigh: Boolean;
    fAutoPulseUntil: QWord;
    fAutoCaptureIndex: Integer;
    fAutoCaptureDirectory: string;
    fAutoConfiguredPulseMs: Integer;
    fAutoStepPresentationPending: Boolean;
    fAutoCommandLock: TCriticalSection;
    fManualStartBoundary: Double;
    fManualFirstTimes: array of Double;
    fCaptureStartSeconds: Double;
    fCaptureEndSeconds: Double;
    fCurrentImpact: Integer;
    fLastError: string;
    fQualityOk: Boolean;
    fPublishedCurves: array of TRecorderFrfCurveData;
    fPrepared: TList;
    fWorker: TRecorderImpactWorker;
    fCompletionPending: Boolean;
    fStopDeferred: Boolean;
    fFilterRebuildPending: Boolean;
    fFilterGeneration: QWord;
    fChannelTagKeys: array of PtrUInt;
    fChannelTagValues: array of Integer;
    fRevision: QWord;
    fComparison: TRecorderImpactSessionSnapshot;
    fHasComparison: Boolean;
    fLock: TCriticalSection;
    fPointCatalog: IRecorderModelPointCatalog;
    fPointBindingSink: IRecorderModelPointBindingSink;
    fRecorderRunning: Boolean;
    fRecorderFaulted: Boolean;
    fFilterWindow: TRecorderImpactFilterWindow;
    fTimeGlobalDecayRate, fTimeResponseDecayRate: Double;
    fRoute: TRecorderFrfRoute;
    fRouteRepository: TRecorderFrfRepository;
    fRouteProvider: IRecorderFrfProvider;
    fLastRouteSequence: QWord;
    // Просмотр дисковых данных отделён от текущих измерений в памяти.
    fHasUnsavedRuntime: Boolean;
    fShowingStoredPoint: Boolean;
    fRouteBindingsPending: Boolean;
    fResultReview, fShowIntensityValues: Boolean;
    fStoredPoint: TRecorderImpactSessionSnapshot;
    fRingSnapshot: TRecorderImpactSessionSnapshot;
    fRingSpectrumPresentation, fStoredSpectrumPresentation: TRecorderImpactResultCurves;
    fRingFilterStatus: string;
    fShowingRing, fRingPending: Boolean;
    fRingDuration: Double;
    fRingStatus: string;
    fRingRepository: TRecorderFrfRepository;
    fRingProvider: IRecorderFrfProvider;
    fRingLastBlocks: array of TRecorderSignalSnapshot;
    fPresentationDirectory: string;
    procedure SynchronizeRouteDirectory;
    procedure BindRoutePointTag;
    procedure BindRouteAutomationTags;
    function AutomationWaitMs: Cardinal;
    procedure SyncAutomationStep;
    procedure RefreshAutomationPresentation;
    procedure CheckManualDeadline;
    function StoreRoutePoint(AAdvance: Boolean; out AError: string): Boolean;
    procedure PublishCurrentRouteBindings;
    function RoutePointLabel(const ABinding: TRecorderFrfRouteBinding): string;
    procedure FillStoredPresentation(var ASnapshot: TRecorderImpactHammerSnapshot;
      ARing: Boolean = False);
    procedure ProcessPendingRing;
    function StoreRingPoint(AAdvance: Boolean; out AError: string): Boolean;
    procedure BuildSnapshot(out ASnapshot: TRecorderImpactSessionSnapshot;
      AImpactIndex: Integer);
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure ProcessSample(ATag: TRecorderTag; AChannel: Integer;
      ATime, AValue: Double);
    procedure ProcessPublishedBlocks(ATag: TRecorderTag);
    procedure PreloadCapture;
    procedure AddSnapshot(ATag: TRecorderTag; AChannel: Integer);
    procedure CompleteCapture;
    procedure ProcessPendingCapture;
    procedure ProcessPendingFilter;
    function BuildSpectrumPresentation(const AMoments: TRecorderImpactMomentsArray):
      TRecorderImpactResultCurves;
    function FilteredTimeValue(AIndex: Integer; ATime, AValue,
      ABase: Double): Double;
    procedure UpdateTimeWindowCoefficients;
    procedure RecomputeAndPublish;
    function RebuildPreparedImpacts(out AError: string): Boolean;
    function FindPrepared(ASequence: QWord): TRecorderPreparedImpact;
    procedure RemovePrepared(ASequence: QWord);
    procedure ClearPrepared;
    function ResolveTags: Boolean;
    procedure PrepareCaptureBuffers;
    function ConfigureRuntime: Boolean;
    function ConfigureDsp: Boolean;
    function PrepareCapturedResponses(ABlock: TRecorderImpactCaptureBlock;
      const AWindow: TRecorderImpactFilterWindow;
      ADsp: TRecorderImpactDspPipeline; out AResponses: TRecorderImpactMomentsArray;
      out AError: string; AUseSeriesRate: Boolean = False): Boolean;
    function ImpactSequence: QWord;
    procedure FillPresentation(var ASnapshot: TRecorderImpactHammerSnapshot;
      AMetadataOnly: Boolean = False);
    procedure AppendComparison(var ASnapshot: TRecorderImpactHammerSnapshot);
    procedure SetRecorderLifecycle(ARunning, AFaulted: Boolean);
    function ChannelForTag(ATag: TRecorderTag): Integer;
    procedure BuildChannelCache;
    procedure CollectIncludedMoments(AAdditional: TRecorderPreparedImpact;
      out AIncluded: TRecorderImpactMomentsMatrix);
    function EstimateCurves(const AIncluded: TRecorderImpactMomentsMatrix;
      out ACurves: TRecorderFrfCurveArray;
      out AQualityOk: Boolean): Boolean;
    procedure ApplyGeometryDisplay(var ABinding:TRecorderModelPointBinding;
      AResponse:TImpactResponseBinding; const ALabel:string);
  public
    constructor Create;
    destructor Destroy; override;
    function Configure(AComponent: TRecorderImpactHammerComponent;
      ARegistry: TRecorderTagRegistry): Boolean;
    procedure NavigateToPreviousImpact;
    procedure NavigateToNextImpact;
    procedure SetCurrentImpactHidden(AHidden: Boolean);
    procedure DeleteCurrentImpact;
    procedure StartMeasurement;
    procedure ArmMeasurement;
    procedure SetTriggerEnabled(AEnabled: Boolean);
    procedure SetRouteTagSync(AEnabled: Boolean);
    function PollRouteTagSync: Boolean;
    procedure SetRouteAutoMode(AEnabled: Boolean);
    procedure CancelRouteAutomation;
    procedure PollRouteAutomation;
    function TryCapturePortion(out AError: string): Boolean;
    function TryCaptureRingPortion(out AError: string): Boolean;
    procedure StopMeasurement;
    procedure SavePointBindings;
    procedure PlayModelAnimation;
    procedure StopModelAnimation;
    procedure ConfigurePointBindingTarget(
      const ACatalog: IRecorderModelPointCatalog;
      const ASink: IRecorderModelPointBindingSink);
    function Provider: IRecorderFrfProvider;
    function Route: TRecorderFrfRoute;
    function CaptureRouteStep(out AError: string): Boolean;
    function SelectRoutePoint(AIndex: Integer; out AError: string): Boolean;
    function SaveRoutePoint(out AError: string): Boolean;
    function RoutePointHasData: Boolean;
    function ShowSavedRoute(out AError: string): Boolean;
    function SetResultReview(AEnabled, AShowValues: Boolean; out AError: string): Boolean;
    procedure UseLiveRoute;
    function Revision: QWord;
    function TryUpdateProcessingSettings(
      const ASettings: TRecorderImpactProcessingSettings;
      out AError: string): Boolean;
    function TrySetFilterWindow(const AWindow: TRecorderImpactFilterWindow;
      out AError: string): Boolean;
    function TrySetTriggerThreshold(AValue: Double;
      out AError: string): Boolean;
    function PublishPointBindings(ABasePointNumber: Integer;
      const ACatalog: IRecorderModelPointCatalog;
      const ASink: IRecorderModelPointBindingSink;
      out AError: string): Boolean;
    procedure FillSnapshot(out ASnapshot: TRecorderImpactHammerSnapshot);
    procedure BuildSessionSnapshot(out ASnapshot: TRecorderImpactSessionSnapshot);
    function SaveSession(const AFileName: string;
      const AStore: IRecorderImpactSessionStore;
      const AOptions: TRecorderImpactSessionSaveOptions;
      out AError: string): Boolean;
    function ImportComparison(const AFileName: string;
      const APort: IRecorderImpactComparisonPort;
      out AError: string): Boolean;
    procedure ClearComparison;
    property LastError: string read fLastError;
  end;

implementation

uses uRecorderFrfPointStore, uRecorderDebugLog;

// Нормирует амплитуды кривой по максимуму, сохраняя нулевой результат для пустого или вырожденного диапазона.
procedure FillAmplitude(var ACurve: TRecorderFrfCurveData;  const AImpacts: TRecorderImpactMomentsArray);
var
  Bin, Impact: Integer;
  Power: Double;
begin
  if Length(AImpacts) = 0 then Exit;
  SetLength(ACurve.Amplitude, Length(ACurve.FrequencyHz));
  for Bin := 0 to High(ACurve.Amplitude) do
  begin
    Power := 0;
    for Impact := 0 to High(AImpacts) do
    begin
      Power := Power + AImpacts[Impact].ResponsePower[Bin];
    end;
    ACurve.Amplitude[Bin] := Sqrt(Max(0, Power / Length(AImpacts))) *
      Sqrt(2.0) / Max(1, AImpacts[0].Metadata.FftSize);
  end;
end;

// Обновляет состояние записи под блокировкой и останавливает захват либо повторно взводит триггер по новому состоянию.
procedure TRecorderImpactHammerService.SetRecorderLifecycle(
  ARunning, AFaulted: Boolean);
begin
  if not ARunning or AFaulted then CancelRouteAutomation;
  fLock.Enter;
  try
    fRecorderRunning := ARunning;
    fRecorderFaulted := AFaulted;
    if not ARunning or AFaulted then
    begin
      fRouteTagSync := False;
      if fCompletionPending then fStopDeferred := True
      else
      begin
        fRuntime.Stop;
        fCaptureToken := 0;
        fManualPortion := False;
      end;
    end
    else if fTriggerEnabled and (fModel <> nil) and fModel.Enabled and
      not fCompletionPending and
      not fFilterRebuildPending and not fManualPortion and
      (fRuntime.State = isStopped) then
      fRuntime.Arm;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

// Создаёт рабочий поток владельца и связывает его с сервисом.
constructor TRecorderImpactWorker.Create(AOwner: TRecorderImpactHammerService);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fWake := TEvent.Create(nil, False, False, '');
  Start;
end;

// Останавливает рабочий поток и освобождает его синхронизацию.
destructor TRecorderImpactWorker.Destroy;
begin
  Terminate;
  fWake.SetEvent;
  WaitFor;
  fWake.Free;
  inherited Destroy;
end;

// Будит рабочий поток после публикации новых данных или команды.
procedure TRecorderImpactWorker.Wake;
begin
  fWake.SetEvent;
end;

// Ждёт сигнала или срока таймера и обрабатывает готовые снимки, фильтры и маршрутную автоматику.
procedure TRecorderImpactWorker.Execute;
begin
  while not Terminated do
  begin
    fWake.WaitFor(fOwner.AutomationWaitMs);
    if not Terminated then
    begin
      fOwner.ProcessPendingCapture;
      fOwner.ProcessPendingRing;
      fOwner.ProcessPendingFilter;
      fOwner.PollRouteAutomation;
    end;
  end;
end;

// Создаёт runtime, блокировки, хранилища и поток фоновой обработки.
constructor TRecorderImpactHammerService.Create;
begin
  inherited Create;
  fTriggerEnabled := True;
  fRuntime := TRecorderImpactRuntime.Create;
  fDsp := TRecorderImpactDspPipeline.Create;
  fLock := TCriticalSection.Create;
  fAutoCommandLock := TCriticalSection.Create;
  fPrepared := TList.Create;
  fFilterDsp := TRecorderImpactDspPipeline.Create;
  fWorker := TRecorderImpactWorker.Create(Self);
  fQualityOk := True;
  Inc(fRevision);
  fCurrentImpact := -1;
  fRoute := TRecorderFrfRoute.Create;
  fRouteRepository := TRecorderFrfRepository.Create;
  fRouteProvider := fRouteRepository;
  fRingRepository := TRecorderFrfRepository.Create;
  fRingProvider := fRingRepository;
end;

// Останавливает сбор и фоновый поток, затем освобождает связанные ресурсы.
destructor TRecorderImpactHammerService.Destroy;
begin
  CancelRouteAutomation;
  if (fSubscription <> 0) and (fRegistry <> nil) and
    (fRegistry.EventBus <> nil) then
    fRegistry.EventBus.Unsubscribe(fSubscription);
  fWorker.Free;
  UnregisterRecorderFrfProvider(Self);
  UnregisterRecorderFrfProvider(fRoute);
  fRouteProvider := nil;
  fRingProvider := nil;
  fRoute.Free;
  ClearPrepared;
  fPrepared.Free;
  fFilterDsp.Free;
  fDsp.Free;
  fRuntime.Free;
  fLock.Free;
  fAutoCommandLock.Free;
  inherited Destroy;
end;

// Разрешает выбранные теги воздействия и отклика; False означает, что конфигурация пока неполна.
function TRecorderImpactHammerService.ResolveTags: Boolean;
var
  I: Integer;
begin
  Result := (fRegistry <> nil) and (fModel <> nil);
  if not Result then
    Exit;
  fHammerTag := fRegistry.FindById(fModel.HammerTagId);
  Result := fHammerTag <> nil;
  if not Result then
  begin
    fLastError := 'Не найден тег ударного молотка.';
    Exit;
  end;
  SetLength(fResponseTags, fModel.ResponseCount);
  for I := 0 to fModel.ResponseCount - 1 do
  begin
    fResponseTags[I] := fRegistry.FindById(fModel.Responses[I].TagId);
    if fResponseTags[I] = nil then
    begin
      fLastError := Format('Не найден тег отклика %s.',
        [fModel.Responses[I].TagName]);
      Exit(False);
    end;
  end;
  BuildChannelCache;
end;

// Строит соответствие тегов и каналов, используемое при разборе опубликованных блоков.
procedure TRecorderImpactHammerService.BuildChannelCache;
var
  I: Integer;
  J: Integer;
  Key: PtrUInt;
  Value: Integer;
begin
  SetLength(fChannelTagKeys, Length(fResponseTags) + 1);
  SetLength(fChannelTagValues, Length(fResponseTags) + 1);
  fChannelTagKeys[0] := PtrUInt(fHammerTag);
  fChannelTagValues[0] := 0;
  for I := 0 to High(fResponseTags) do
  begin
    fChannelTagKeys[I + 1] := PtrUInt(fResponseTags[I]);
    fChannelTagValues[I + 1] := I + 1;
  end;
  for I := 1 to High(fChannelTagKeys) do
  begin
    Key := fChannelTagKeys[I];
    Value := fChannelTagValues[I];
    J := I - 1;
    while (J >= 0) and (fChannelTagKeys[J] > Key) do
    begin
      fChannelTagKeys[J + 1] := fChannelTagKeys[J];
      fChannelTagValues[J + 1] := fChannelTagValues[J];
      Dec(J);
    end;
    fChannelTagKeys[J + 1] := Key;
    fChannelTagValues[J + 1] := Value;
  end;
end;

// Возвращает индекс канала для тега или -1, если тег не входит в текущую конфигурацию.
function TRecorderImpactHammerService.ChannelForTag(
  ATag: TRecorderTag): Integer;
var
  LowIndex: Integer;
  HighIndex: Integer;
  Middle: Integer;
  Key: PtrUInt;
begin
  Result := -1;
  Key := PtrUInt(ATag);
  LowIndex := 0;
  HighIndex := High(fChannelTagKeys);
  while LowIndex <= HighIndex do
  begin
    Middle := LowIndex + (HighIndex - LowIndex) div 2;
    if fChannelTagKeys[Middle] = Key then
      Exit(fChannelTagValues[Middle]);
    if fChannelTagKeys[Middle] < Key then
      LowIndex := Middle + 1
    else
      HighIndex := Middle - 1;
  end;
end;

// Создаёт и сбрасывает буферы каналов под текущие частоты дискретизации и длину окна.
procedure TRecorderImpactHammerService.PrepareCaptureBuffers;
var
  Channel: Integer;
  Tag: TRecorderTag;
begin
  SetLength(fPreloadTimes, Length(fResponseTags) + 1);
  SetLength(fPreloadValues, Length(fResponseTags) + 1);
  SetLength(fBlockTimes, Length(fResponseTags) + 1);
  SetLength(fBlockValues, Length(fResponseTags) + 1);
  SetLength(fBlockCursors, Length(fResponseTags) + 1);
  SetLength(fManualFirstTimes, Length(fResponseTags) + 1);
  for Channel := 0 to High(fPreloadTimes) do
  begin
    if Channel = 0 then
      Tag := fHammerTag
    else
      Tag := fResponseTags[Channel - 1];
    SetLength(fPreloadTimes[Channel], Tag.SignalBuffer.Capacity);
    SetLength(fPreloadValues[Channel], Tag.SignalBuffer.Capacity);
    SetLength(fBlockTimes[Channel], Tag.SignalBuffer.Capacity);
    SetLength(fBlockValues[Channel], Tag.SignalBuffer.Capacity);
    fBlockCursors[Channel] := Tag.SignalBuffer.CurrentBlockCursor;
  end;
end;

// Настраивает сбор исходных блоков и их подписки; False сообщает о невозможности запустить runtime.
function TRecorderImpactHammerService.ConfigureRuntime: Boolean;
var
  RuntimeSettings: TRecorderImpactSettings;
  I: Integer;
begin
  RuntimeSettings := Default(TRecorderImpactSettings);
  RuntimeSettings.SampleRateHz := fModel.SampleRateHz;
  // Частота задаёт размер сырых буферов, но не временную сетку обработки FRF.
  RuntimeSettings.SampleRateHz := Max(RuntimeSettings.SampleRateHz,
    fHammerTag.PollFrequencyHz);
  for I := 0 to High(fResponseTags) do
    RuntimeSettings.SampleRateHz := Max(RuntimeSettings.SampleRateHz,
      fResponseTags[I].PollFrequencyHz);
  RuntimeSettings.Threshold := fModel.TriggerThreshold;
  RuntimeSettings.Hysteresis := fModel.TriggerHysteresis;
  RuntimeSettings.PretriggerSeconds := fModel.PretriggerSamples /
    fModel.SampleRateHz;
  RuntimeSettings.CaptureSeconds := fModel.CaptureSamples /
    fModel.SampleRateHz;
  RuntimeSettings.Capacity := fModel.ImpactCapacity;
  RuntimeSettings.ResponseCount := fModel.ResponseCount;
  RuntimeSettings.Polarity := TRecorderImpactPolarity(
    Ord(fModel.TriggerPolarity));
  RuntimeSettings.Estimator := TRecorderFrfEstimatorKind(
    Ord(fModel.Estimator));
  Result := fRuntime.Configure(RuntimeSettings, fLastError);
  if not Result then
    Exit;
  Result := ConfigureDsp;
end;

// Передаёт DSP актуальные настройки воздействия и откликов и подготавливает расчётные буферы.
function TRecorderImpactHammerService.ConfigureDsp: Boolean;
var
  DspSettings: TRecorderImpactDspSettings;
  I: Integer;
begin
  DspSettings := Default(TRecorderImpactDspSettings);
  DspSettings.SampleRateHz := fModel.SampleRateHz;
  DspSettings.CaptureSamples := fModel.CaptureSamples;
  DspSettings.FftSize := fModel.FftSize * fModel.ZeroPadFactor;
  if fModel.WelchEnabled then
    DspSettings.WelchSegmentSamples := fModel.WelchSegmentSize
  else
    DspSettings.WelchSegmentSamples := 0;
  DspSettings.WelchOverlapPercent := fModel.WelchOverlapPercent;
  DspSettings.ResponseCount := fModel.ResponseCount;
  DspSettings.WindowKind := TRecorderImpactWindowKind(Ord(fModel.WindowKind));
  DspSettings.ForceWindowFraction := fModel.ForceWindowFraction;
  DspSettings.ExponentialEndFraction := fModel.ExponentialEndFraction;
  DspSettings.WindowEnabled := fFilterWindow.Enabled;
  DspSettings.WindowStartFraction := fFilterWindow.StartSeconds /
    Max(1E-12, fModel.CaptureSamples / fModel.SampleRateHz);
  DspSettings.WindowEndFraction := fFilterWindow.EndSeconds /
    Max(1E-12, fModel.CaptureSamples / fModel.SampleRateHz);
  DspSettings.ExponentialStartFraction :=
    fFilterWindow.ExponentialStartSeconds /
    Max(1E-12, fModel.CaptureSamples / fModel.SampleRateHz);
  DspSettings.ExponentialEndPositionFraction :=
    fFilterWindow.ExponentialEndSeconds /
    Max(1E-12, fModel.CaptureSamples / fModel.SampleRateHz);
  if fFilterWindow.ExponentialEndLevel > 0 then
    DspSettings.ResponseExponentialEndLevel :=
      fFilterWindow.ExponentialEndLevel;
  DspSettings.ExcitationUnitName := fModel.ExcitationUnitName;
  SetLength(DspSettings.ResponseUnitNames, fModel.ResponseCount);
  for I := 0 to fModel.ResponseCount - 1 do
    DspSettings.ResponseUnitNames[I] := fModel.Responses[I].ResponseUnitName;
  Result := fDsp.Configure(DspSettings, fLastError);
end;

// Пересчитывает отклики на частотную сетку воздействия; общий CaptureStart сохраняет временное совмещение каналов.
function TRecorderImpactHammerService.PrepareCapturedResponses(
  ABlock: TRecorderImpactCaptureBlock;
  const AWindow: TRecorderImpactFilterWindow; ADsp: TRecorderImpactDspPipeline;
  out AResponses: TRecorderImpactMomentsArray; out AError: string;
  AUseSeriesRate: Boolean): Boolean;
var
  Settings: TRecorderImpactDspSettings;
  Response: TRecorderSampleSeries;
  Values: array of Double;
  Duration, SampleRate, Span, Step: Double;
  Uniform: Boolean;
  I, J, RequiredFft: Integer;
begin
  Result := False;
  AError := '';
  Duration := Min(fModel.CaptureSamples / fModel.SampleRateHz,  ABlock.EndSeconds - ABlock.StartSeconds);
  SetLength(AResponses, fModel.ResponseCount);
  for I := 0 to fModel.ResponseCount - 1 do
  begin
    Response := ABlock.Response(I);
    SampleRate := fModel.SampleRateHz;
    if not AUseSeriesRate and (I < Length(fResponseTags)) and
      (fResponseTags[I].PollFrequencyHz > 0) then
      SampleRate := fResponseTags[I].PollFrequencyHz
    else if Length(Response) >= 2 then
    begin
      Span := Response[High(Response)].TimeSeconds - Response[0].TimeSeconds;
      if Span > 0 then
      begin
        Step := Span / (Length(Response) - 1);
        Uniform := True;
        for J := 1 to High(Response) do
          if Abs(Response[J].TimeSeconds - Response[J-1].TimeSeconds - Step) >
            Step * 0.001 then Uniform := False;
        // Неравномерный ряд не задаёт надёжную частоту: пропуск отсчёта нельзя
        // принимать за более низкую Fs, поэтому остаётся настроенная сетка.
        if Uniform then SampleRate := 1 / Step;
      end;
    end;
    // Длительность окна сохраняется, а частота берётся отдельно для каждого отклика.
    Settings := Default(TRecorderImpactDspSettings);
    Settings.SampleRateHz := SampleRate;
    Settings.CaptureSamples := Max(2, Round(Duration * SampleRate));
    RequiredFft := Max(2, Round(fModel.FftSize * SampleRate / fModel.SampleRateHz));
    Settings.FftSize := 2;
    while Settings.FftSize < RequiredFft do
      Settings.FftSize := Settings.FftSize * 2;
    Settings.FftSize := Settings.FftSize * fModel.ZeroPadFactor;
    if fModel.WelchEnabled then
      Settings.WelchSegmentSamples := EnsureRange(Round( fModel.WelchSegmentSize * SampleRate / fModel.SampleRateHz), 2, Settings.CaptureSamples);
    Settings.WelchOverlapPercent := fModel.WelchOverlapPercent;
    Settings.ResponseCount := 1;
    Settings.WindowKind := TRecorderImpactWindowKind(Ord(fModel.WindowKind));
    Settings.ForceWindowFraction := fModel.ForceWindowFraction;
    Settings.ExponentialEndFraction := fModel.ExponentialEndFraction;
    Settings.WindowEnabled := AWindow.Enabled;
    Settings.WindowStartFraction := AWindow.StartSeconds / Duration;
    { A short ring portion clips the rectangular support, not the physical
      exponential reference point (which may lie beyond available samples). }
    Settings.WindowEndFraction := Min(1, AWindow.EndSeconds / Duration);
    Settings.ExponentialStartFraction := AWindow.ExponentialStartSeconds / Duration;
    Settings.ExponentialEndPositionFraction := AWindow.ExponentialEndSeconds / Duration;
    if AWindow.ExponentialEndLevel > 0 then
      Settings.ResponseExponentialEndLevel := AWindow.ExponentialEndLevel;
    Settings.ExcitationUnitName := fModel.ExcitationUnitName;
    SetLength(Settings.ResponseUnitNames, 1);
    Settings.ResponseUnitNames[0] := fModel.Responses[I].ResponseUnitName;
    if not ADsp.Configure(Settings, AError) then Exit;
    { Воздействие и этот отклик пересчитываются от общей CaptureStart на одну
      сетку Fs. В исходном блоке у каждого канала остаются свои временные метки. }
    SetLength(Values, Settings.CaptureSamples);
    if not ResampleImpactSeries(ABlock.Excitation, ABlock.StartSeconds,
      SampleRate, Settings.CaptureSamples, Values) then
    begin
      AError := 'Cannot align excitation to response sampling rate';
      Exit;
    end;
    for J := 0 to High(Values) do ADsp.AddSample(0, Values[J]);
    if not ResampleImpactSeries(Response, ABlock.StartSeconds,
      SampleRate, Settings.CaptureSamples, Values) then
    begin
      AError := 'Cannot align response capture';
      Exit;
    end;
    for J := 0 to High(Values) do ADsp.AddSample(1, Values[J]);
    if not ADsp.PrepareResponse(0, AResponses[I]) then
    begin
      AError := 'Cannot prepare response spectral moments';
      Exit;
    end;
  end;
  Result := True;
end;

// Применяет модель и зависимости сервиса, затем заново разрешает теги и подготавливает сбор.
function TRecorderImpactHammerService.Configure(
  AComponent: TRecorderImpactHammerComponent;
  ARegistry: TRecorderTagRegistry): Boolean;
begin
  CancelRouteAutomation;
  UnregisterRecorderFrfProvider(Self);
  if (fSubscription <> 0) and (fRegistry <> nil) and
    (fRegistry.EventBus <> nil) then
    fRegistry.EventBus.Unsubscribe(fSubscription);
  fSubscription := 0;
  FreeAndNil(fWorker);
  fLock.Enter;
  try
    fModel := AComponent;
    fRoute.ConfigFileName := AComponent.RouteConfigFileName;
    fRegistry := ARegistry;
    BindRoutePointTag;
    BindRouteAutomationTags;
    fLastError := '';
    fCaptureToken := 0;
    fManualPortion := False;
    fCurrentImpact := -1;
    fHasUnsavedRuntime := False;
    fShowingStoredPoint := False;
    fRouteBindingsPending := False;
    fAutoStepPresentationPending := False;
    fResultReview := False;
    fShowIntensityValues := fModel.ResultValuesVisible;
    fStoredPoint := Default(TRecorderImpactSessionSnapshot);
    fRingSpectrumPresentation := Default(TRecorderImpactResultCurves);
    fStoredSpectrumPresentation := Default(TRecorderImpactResultCurves);
    fCompletionPending := False;
    fStopDeferred := False;
    fFilterWindow := Default(TRecorderImpactFilterWindow);
    fFilterWindow.StartSeconds := 0;
    fFilterWindow.EndSeconds := fModel.CaptureSamples / fModel.SampleRateHz;
    fFilterWindow.ExponentialStartSeconds := 0;
    fFilterWindow.ExponentialEndSeconds := fFilterWindow.EndSeconds;
    fFilterWindow.ExponentialEndLevel := fModel.ExponentialEndFraction;
    UpdateTimeWindowCoefficients;
    fRuntime.Stop;
    ClearPrepared;
    fRuntime.ClearPublished;
    fQualityOk := True;
    Inc(fRevision);
    Result := ResolveTags and ConfigureRuntime;
    fRecorderFaulted := not Result;
    if Result then
      PrepareCaptureBuffers;
    if Result and fTriggerEnabled and fRecorderRunning and fModel.Enabled then
      fRuntime.Arm;
    fWorker := TRecorderImpactWorker.Create(Self);
    if Result and (fRegistry.EventBus <> nil) then
      fSubscription := fRegistry.EventBus.Subscribe(@HandleEvent);
    if Result then
      RegisterRecorderFrfProvider(Self, fRuntime.Provider);
  finally
    fLock.Leave;
  end;
end;

// Повторно рассчитывает сохранённые удары с новыми параметрами; AError содержит причину отказа.
function TRecorderImpactHammerService.RebuildPreparedImpacts(
  out AError: string): Boolean;
var
  Block: TRecorderImpactCaptureBlock;
  Prepared: TRecorderPreparedImpact;
  ImpactIndex: Integer;
begin
  AError := '';
  ClearPrepared;
  for ImpactIndex := 0 to fRuntime.Impacts.Count - 1 do
  begin
    Block := fRuntime.Impacts.Capture(ImpactIndex);
    Prepared := TRecorderPreparedImpact.Create;
    Prepared.Sequence := fRuntime.Impacts.Item(ImpactIndex).Sequence;
    if not PrepareCapturedResponses(Block, fFilterWindow, fDsp,
      Prepared.Responses, AError) then
    begin
      Prepared.Free;
      Exit(False);
    end;
    fPrepared.Add(Prepared);
  end;
  RecomputeAndPublish;
  Result := True;
end;

// Принимает событие записи и передаёт соответствующий тег и блок в обработку.
procedure TRecorderImpactHammerService.HandleEvent(ASender: TObject;
  const AEvent: TRecorderEvent);
var
  Data: TRecorderTagUpdateEventData;
  Channel: Integer;
begin
  if AEvent.Kind in [rceStopped, rceAfterStop] then
  begin
    SetRecorderLifecycle(False, False);
    StopMeasurement;
    Exit;
  end;
  if AEvent.Kind = rceStarted then
  begin
    SetRecorderLifecycle(True, False);
    Exit;
  end;
  if (AEvent.Kind = rceRunTransitionAfter) and
    (AEvent.Transition in [rstStopToView, rstStopToRecord]) then
  begin
    SetRecorderLifecycle(True, False);
    Exit;
  end;
  if (AEvent.Kind = rceRunTransitionAfter) and
    (AEvent.Transition in [rstViewToStop, rstRecordToStop]) then
  begin
    SetRecorderLifecycle(False, False);
    StopMeasurement;
    Exit;
  end;
  if (AEvent.Kind <> rceDataUpdated) or
    not (AEvent.Data is TRecorderTagUpdateEventData) then
    Exit;
  Data := TRecorderTagUpdateEventData(AEvent.Data);
  fLock.Enter;
  try
    if Data.SampleCount > 0 then
      ProcessPublishedBlocks(Data.Tag)
    else
    begin
      Channel := ChannelForTag(Data.Tag);
      if Channel >= 0 then
        ProcessSample(Data.Tag, Channel, Data.TimeSec, Data.Value);
    end;
  finally
    fLock.Leave;
  end;
end;

// Читает новые блоки по отдельному курсору каждого канала; объединение выполняется по времени отсчётов, а не по порядку уведомлений.
procedure TRecorderImpactHammerService.ProcessPublishedBlocks(
  ATag: TRecorderTag);
var
  Channel: Integer;
  Count: Integer;
  I: Integer;
begin
  Channel := ChannelForTag(ATag);
  if Channel < 0 then
    Exit;
  // Каждый вход читается от собственного курсора блока; время отсчёта, а не
  //  порядок прихода уведомлений, связывает молоток с каналами отклика.
  while ATag.SignalBuffer.SnapshotNextBlockInto(fBlockCursors[Channel],
    fBlockTimes[Channel], fBlockValues[Channel], Count) do
    for I := 0 to Count - 1 do
      ProcessSample(ATag, Channel, fBlockTimes[Channel][I],
        fBlockValues[Channel][I]);
end;

// Обрабатывает один отсчёт. Ручная порция стартует после первого посткомандного отсчёта каждого канала; общий интервал закрывается только при покрытии всеми каналами.
procedure TRecorderImpactHammerService.ProcessSample(ATag: TRecorderTag;
  AChannel: Integer; ATime, AValue: Double);
var
  TriggerEvent: TRecorderImpactTriggerEvent;
  Channel, I: Integer;
  FirstStart: Double;
begin
  // Пока рабочий поток завершает удар, новые отсчёты отбрасываются: повторный
  //  захват использовал бы те же объекты расчёта одновременно.
  if fCompletionPending or fFilterRebuildPending or fRingPending then
    Exit;
  if fManualPortion and (ATime <= fManualStartBoundary) then Exit;
  if fManualPortion and (fManualFirstTimes[AChannel] = -MaxDouble) then
    fManualFirstTimes[AChannel] := ATime;
  if (ATag = fHammerTag) and (fCaptureToken = 0) then
  begin
    if fManualPortion then
    begin
      { Старт разрешён после первого нового отсчёта каждого входа; фактическое
        время задаёт первый отсчёт молотка не раньше самой поздней такой отметки. }
      FirstStart := -MaxDouble;
      for I := 0 to High(fManualFirstTimes) do
      begin
        if fManualFirstTimes[I] = -MaxDouble then Exit;
        FirstStart := Max(FirstStart, fManualFirstTimes[I]);
      end;
      if ATime < FirstStart then Exit;
      fRuntime.BeginPortion(ATime, TriggerEvent);
    end
    else
      fRuntime.ProcessTriggerSample(ATime, AValue, TriggerEvent);
    if TriggerEvent.Triggered then
    begin
      fCaptureToken := TriggerEvent.CaptureToken;
      fCaptureStartSeconds := TriggerEvent.CaptureStartSeconds;
      fCaptureEndSeconds := TriggerEvent.CaptureEndSeconds;
      PreloadCapture;
    end;
  end;
  if fCaptureToken = 0 then
    Exit;
  // Каналы поступают независимо: каждый добавляет свои отсчёты с родными
  //  временными метками в одно окно. PreloadCapture добавляет историю до
  //  триггера, а готовность наступает лишь после покрытия окна всеми входами.
  Channel := AChannel;
  if Channel = 0 then
    fRuntime.AddExcitationSample(fCaptureToken, ATime, AValue);
  if Channel > 0 then
    fRuntime.AddResponseSample(fCaptureToken, Channel - 1, ATime, AValue);
  if fRuntime.CaptureReady(fCaptureToken) then
  begin
    fCompletionPending := True;
    Inc(fRevision);
    fWorker.Wake;
  end;
end;

// Забирает готовую порцию и передаёт её в расчёт, не удерживая блокировку входного кольца.
procedure TRecorderImpactHammerService.ProcessPendingCapture;
begin
  fLock.Enter;
  try
    if not fCompletionPending then
      Exit;
  finally
    fLock.Leave;
  end;
  try
    try
      CompleteCapture;
    except
      on E: Exception do
      begin
        fLock.Enter;
        try
          fLastError := 'Ошибка обработки удара: ' + E.Message;
        finally
          fLock.Leave;
        end;
      end;
    end;
  finally
    fLock.Enter;
    try
      fCompletionPending := False;
      if fManualPortion then
      begin
        fRuntime.Stop;
        fCaptureToken := 0;
        fManualPortion := False;
      end;
      if fStopDeferred then
      begin
        fRuntime.Stop;
        fCaptureToken := 0;
        fStopDeferred := False;
      end;
      if fTriggerEnabled and fRecorderRunning and not fRecorderFaulted and
        fModel.Enabled and not fFilterRebuildPending and
        (fRuntime.State = isStopped) then
        fRuntime.Arm;
      Inc(fRevision);
    finally
      fLock.Leave;
    end;
  end;
end;

// Применяет отложенное изменение фильтра и публикует пересчитанные результаты.
// Spectra remain measurable even where division by an excitation/cross-spectrum
// null makes the transfer estimate unavailable. Build this independent result
// on the worker; never retain an old spectrum as if it belonged to a new window.
function TRecorderImpactHammerService.BuildSpectrumPresentation(
  const AMoments: TRecorderImpactMomentsArray): TRecorderImpactResultCurves;
var
  lChannel, lBin, lResponse: Integer;
begin
  Result := Default(TRecorderImpactResultCurves);
  Result.ResultType := irtSpectrum;
  Result.XUnitName := 'Hz';
  if Length(AMoments) = 0 then Exit;
  SetLength(Result.Curves, Length(AMoments) + 1);
  for lChannel := 0 to High(Result.Curves) do
  begin
    lResponse := Max(0, lChannel - 1);
    with Result.Curves[lChannel] do
    begin
      if lChannel = 0 then
      begin
        Name := fModel.HammerTagName;
        UnitName := fModel.ExcitationUnitName;
        Color := $0000FF;
        Visible := fModel.ExcitationVisible;
      end
      else
      begin
        CurveId := fModel.Responses[lResponse].CurveId;
        Name := fModel.Responses[lResponse].TagName;
        UnitName := fModel.Responses[lResponse].ResponseUnitName;
        Color := fModel.Responses[lResponse].Color;
        Visible := fModel.Responses[lResponse].Visible;
      end;
      X := Copy(AMoments[lResponse].FrequencyHz);
      SetLength(Y, Length(X));
      for lBin := 0 to High(Y) do
        if lChannel = 0 then
          Y[lBin] := Sqrt(Max(0, AMoments[0].ExcitationPower[lBin])) *
            Sqrt(2.0) / AMoments[0].Metadata.FftSize
        else
          Y[lBin] := Sqrt(Max(0, AMoments[lResponse].ResponsePower[lBin])) *
            Sqrt(2.0) / AMoments[lResponse].Metadata.FftSize;
    end;
  end;
end;

procedure TRecorderImpactHammerService.ProcessPendingFilter;
var
  Generation: QWord;
  Window: TRecorderImpactFilterWindow;
  Blocks: TRecorderCaptureBlockArray;
  IncludedFlags: array of Boolean;
  Sequences: array of QWord;
  LocalDsp: TRecorderImpactDspPipeline;
  NewPrepared: TList;
  OldPrepared: TList;
  Prepared: TRecorderPreparedImpact;
  Included: TRecorderImpactMomentsMatrix;
  Curves: TRecorderFrfCurveArray;
  QualityOk: Boolean;
  ErrorText: string;
  I: Integer;
  IncludedCount: Integer;
  DisplaySession: TRecorderImpactSessionSnapshot;
  DisplayRing, DisplayStored: Boolean;
  DisplayRouteIndex: Integer;
  DisplayCurves: TRecorderFrfCurveArray;
  DisplaySpectrum: TRecorderImpactResultCurves;
  FrfUnavailable: Boolean;

  // History deletion may run while FFT is outside fLock. Own the raw payload
  // snapshot until this generation completes instead of retaining freed objects.
  function PinBlock(ASource: TRecorderImpactCaptureBlock): TRecorderImpactCaptureBlock;
  var
    lExcitation: TRecorderSampleSeries;
    lResponses: array of TRecorderSampleSeries;
    lCounts: array of Integer;
    J: Integer;
  begin
    lExcitation := ASource.Excitation;
    SetLength(lResponses, ASource.ResponseCount);
    SetLength(lCounts, ASource.ResponseCount);
    for J := 0 to High(lResponses) do
    begin
      lResponses[J] := ASource.Response(J);
      lCounts[J] := Length(lResponses[J]);
    end;
    Result := TRecorderImpactCaptureBlock.Adopt(ASource.Token,
      ASource.StartSeconds, ASource.EndSeconds, lExcitation, lResponses,
      Length(lExcitation), lCounts);
  end;

  function RequestCurrent: Boolean;
  begin
    fLock.Enter;
    try Result := Generation = fFilterGeneration;
    finally fLock.Leave end;
    if not Result then fWorker.Wake;
  end;

  // Work only on detached arrays; raw session samples remain immutable.
  function RebuildDisplaySession: Boolean;
  var
    lHit, lResponse, lSample, lCurve: Integer;
    lExcitation: TRecorderSampleSeries;
    lResponses: array of TRecorderSampleSeries;
    lBlock: TRecorderImpactCaptureBlock;
    lMoments: TRecorderImpactMomentsArray;
    lHits: TRecorderImpactMomentsMatrix;
    lCurves: TRecorderFrfCurveArray;
    lStart, lEnd, lStep: Double;
    lQuality: Boolean;
    lUnsynchronized: Boolean;

    procedure CopySeries(const ASource: TRecorderImpactSessionSeries;
      out ATarget: TRecorderSampleSeries);
    var J: Integer; lOrigin: Double;
    begin
      SetLength(ATarget, Length(ASource.Samples));
      lOrigin := 0;
      if lUnsynchronized and
        (Length(ASource.Samples) > 0) then
        lOrigin := ASource.Samples[0].TimeSeconds;
      for J := 0 to High(ATarget) do
      begin
        ATarget[J].TimeSeconds := ASource.Samples[J].TimeSeconds - lOrigin;
        ATarget[J].Value := ASource.Samples[J].Value;
      end;
    end;

  begin
    Result := True;
    if Length(DisplaySession.Impacts) = 0 then Exit;
    lUnsynchronized := Pos(':unsynchronized', DisplaySession.SessionId) > 0;
    lHits := nil;
    for lHit := 0 to High(DisplaySession.Impacts) do
    begin
      if not RequestCurrent then Exit(False);
      CopySeries(DisplaySession.Impacts[lHit].Excitation, lExcitation);
      if Length(lExcitation) < 2 then Exit;
      lStart := lExcitation[0].TimeSeconds;
      lStep := (lExcitation[High(lExcitation)].TimeSeconds - lStart) /
        (Length(lExcitation) - 1);
      lEnd := lExcitation[High(lExcitation)].TimeSeconds + lStep;
      SetLength(lResponses, Length(DisplaySession.Impacts[lHit].Responses));
      for lResponse := 0 to High(lResponses) do
        CopySeries(DisplaySession.Impacts[lHit].Responses[lResponse],
          lResponses[lResponse]);
      lBlock := TRecorderImpactCaptureBlock.Create(1, lStart, lEnd,
        lExcitation, lResponses);
      try
        if not PrepareCapturedResponses(lBlock, Window, LocalDsp,
          lMoments, ErrorText, True) then Exit(False);
      finally lBlock.Free end;
      if DisplaySession.Impacts[lHit].Accepted and
        not DisplaySession.Impacts[lHit].Hidden then
      begin
        SetLength(lHits, Length(lHits) + 1);
        lHits[High(lHits)] := lMoments;
      end;
    end;
    if Length(lHits) = 0 then Exit;
    DisplaySpectrum := BuildSpectrumPresentation(lMoments);
    if not EstimateCurves(lHits, lCurves, lQuality) then
    begin
      lCurves := nil;
      FrfUnavailable := True;
    end;
    DisplaySession.Curves := Copy(DisplaySession.Curves);
    SetLength(DisplaySession.Curves, Length(lCurves));
    DisplayCurves := lCurves;
    for lCurve := 0 to Min(High(lCurves), High(DisplaySession.Curves)) do
      with DisplaySession.Curves[lCurve] do
      begin
        CurveId := lCurves[lCurve].Id;
        TagId := fModel.Responses[lCurve].TagId;
        Name := fModel.Responses[lCurve].TagName;
        ExcitationUnitName := fModel.ExcitationUnitName;
        ResponseUnitName := fModel.Responses[lCurve].ResponseUnitName;
        FrequencyHz := lCurves[lCurve].FrequencyHz;
        Magnitude := lCurves[lCurve].Magnitude;
        PhaseRadians := lCurves[lCurve].PhaseRadians;
        Coherence := lCurves[lCurve].Coherence;
        ExcitationSpectrum := nil;
        ResponseSpectrum := nil;
        SetLength(ExcitationSpectrum, Length(lMoments[lCurve].ExcitationPower));
        SetLength(ResponseSpectrum, Length(lMoments[lCurve].ResponsePower));
        for lSample := 0 to High(ExcitationSpectrum) do
        begin
          ExcitationSpectrum[lSample] := Sqrt(Max(0,
            lMoments[lCurve].ExcitationPower[lSample])) * Sqrt(2.0) /
            lMoments[lCurve].Metadata.FftSize;
          ResponseSpectrum[lSample] := Sqrt(Max(0,
            lMoments[lCurve].ResponsePower[lSample])) * Sqrt(2.0) /
            lMoments[lCurve].Metadata.FftSize;
        end;
      end;
  end;

  // Освобождает объекты подготовленных ударов из временного списка.
  procedure FreePreparedList(AList: TList);
  begin
    if AList = nil then
      Exit;
    while AList.Count > 0 do
    begin
      TObject(AList.Last).Free;
      AList.Delete(AList.Count - 1);
    end;
    AList.Free;
  end;

  // Завершает текущий запрос фильтра с сообщением AMessage и восстанавливает согласованное состояние очереди.
  procedure FailCurrentRequest(const AMessage: string);
  begin
    fLock.Enter;
    try
      if Generation = fFilterGeneration then
      begin
        fLastError := AMessage;
        fFilterRebuildPending := False;
        Inc(fRevision);
      end;
    finally
      fLock.Leave;
    end;
  end;

begin
  fLock.Enter;
  try
    if not fFilterRebuildPending or fCompletionPending then
      Exit;
    Generation := fFilterGeneration;
    Window := fFilterWindow;
    DisplayRing := fShowingRing;
    DisplayStored := fShowingStoredPoint;
    DisplayRouteIndex := fRoute.CurrentIndex;
    if DisplayRing then DisplaySession := fRingSnapshot
    else if DisplayStored then DisplaySession := fStoredPoint;
    SetLength(Blocks, fRuntime.Impacts.Count);
    SetLength(IncludedFlags, fRuntime.Impacts.Count);
    SetLength(Sequences, fRuntime.Impacts.Count);
    for I := 0 to fRuntime.Impacts.Count - 1 do
    begin
      Blocks[I] := PinBlock(fRuntime.Impacts.Capture(I));
      IncludedFlags[I] := fRuntime.Impacts.Item(I).Accepted and
        not fRuntime.Impacts.Item(I).Hidden;
      Sequences[I] := fRuntime.Impacts.Item(I).Sequence;
    end;
  finally
    fLock.Leave;
  end;

  LocalDsp := fFilterDsp;
  FrfUnavailable := False;
  NewPrepared := TList.Create;
  OldPrepared := nil;
  try
    SetLength(Included, Length(Blocks));
    IncludedCount := 0;
    for I := 0 to High(Blocks) do
    begin
      fLock.Enter;
      try
        if Generation <> fFilterGeneration then
        begin
          fWorker.Wake;
          Exit;
        end;
      finally
        fLock.Leave;
      end;
      Prepared := TRecorderPreparedImpact.Create;
      Prepared.Sequence := Sequences[I];
      if not PrepareCapturedResponses(Blocks[I], Window, LocalDsp,
        Prepared.Responses, ErrorText) then
      begin
        Prepared.Free;
        FailCurrentRequest(ErrorText);
        Exit;
      end;
      NewPrepared.Add(Prepared);
      if IncludedFlags[I] then
      begin
        Included[IncludedCount] := Copy(Prepared.Responses);
        Inc(IncludedCount);
      end;
    end;
    SetLength(Included, IncludedCount);
    if (DisplayRing or DisplayStored) and not RebuildDisplaySession then
    begin
      if RequestCurrent then FailCurrentRequest(ErrorText);
      Exit;
    end;
    if (IncludedCount > 0) and
      not EstimateCurves(Included, Curves, QualityOk) then
    begin
      Curves := nil;
      FrfUnavailable := True;
    end;
    fLock.Enter;
    try
      if Generation <> fFilterGeneration then
      begin
        fWorker.Wake;
        Exit;
      end;
      if DisplayRing and fShowingRing then
      begin
        fRingSnapshot := DisplaySession;
        fRingSpectrumPresentation := DisplaySpectrum;
        if Length(DisplayCurves) > 0 then
        begin
          fRingRepository.Publish(DisplayCurves);
          NotifyRecorderFrfProviderChanged(fRingProvider);
        end;
        if Length(DisplayCurves) = 0 then
        begin
          fRingRepository.Clear;
          NotifyRecorderFrfProviderChanged(fRingProvider);
        end;
      end
      else if DisplayStored and fShowingStoredPoint and
        (DisplayRouteIndex = fRoute.CurrentIndex) then
      begin
        fStoredPoint := DisplaySession;
        fStoredSpectrumPresentation := DisplaySpectrum;
      end;
      OldPrepared := fPrepared;
      fPrepared := NewPrepared;
      NewPrepared := nil;
      if (IncludedCount = 0) or (Length(Curves) = 0) then
      begin
        fRuntime.ClearPublished;
        SetLength(fPublishedCurves, 0);
        fQualityOk := True;
      end
      else
      begin
        fRuntime.PublishCurves(Curves);
        fPublishedCurves := Copy(Curves);
        fQualityOk := QualityOk;
      end;
      fFilterRebuildPending := False;
      if FrfUnavailable then
        fLastError := 'Спектры пересчитаны; FRF недоступна: нет энергии воздействия или взаимного спектра в частотных бинах.'
      else fLastError := '';
      if DisplayRing then fRingFilterStatus := fLastError;
      Inc(fRevision);
    finally
      fLock.Leave;
    end;
  finally
    for I := 0 to High(Blocks) do Blocks[I].Free;
    FreePreparedList(OldPrepared);
    FreePreparedList(NewPrepared);
  end;
end;

// Добавляет отсчёты канала в текущую порцию, сохраняя исходные метки времени.
procedure TRecorderImpactHammerService.AddSnapshot(ATag: TRecorderTag;
  AChannel: Integer);
var
  Times: TRecorderDoubleArray;
  Values: TRecorderDoubleArray;
  Count: Integer;
  I: Integer;
begin
  { Берём из кольцевого буфера опубликованную часть окна, включая соседний
    отсчёт перед его началом для интерполяции. Новые отсчёты дополнят этот ряд. }
  Times := fPreloadTimes[AChannel];
  Values := fPreloadValues[AChannel];
  ATag.SnapshotRangeInto(fCaptureStartSeconds, True, Times, Values, Count);
  fPreloadTimes[AChannel] := Times;
  fPreloadValues[AChannel] := Values;
  for I := 0 to Count - 1 do
  begin
    if fManualPortion and (Times[I] <= fManualStartBoundary) then Continue;
    if fManualPortion and (AChannel = 0) and
      (Times[I] < fCaptureStartSeconds) then Continue;
    if AChannel = 0 then
      fRuntime.AddExcitationSample(fCaptureToken, Times[I], Values[I])
    else
      fRuntime.AddResponseSample(fCaptureToken, AChannel - 1,
        Times[I], Values[I]);
    if Times[I] >= fCaptureEndSeconds then
      Break;
  end;
end;

// Переносит предысторию из кольцевых буферов в новую порцию, включая соседний отсчёт для интерполяции границы.
procedure TRecorderImpactHammerService.PreloadCapture;
var
  I: Integer;
begin
  AddSnapshot(fHammerTag, 0);
  for I := 0 to High(fResponseTags) do
    AddSnapshot(fResponseTags[I], I + 1);
end;

// Собирает матрицу ударов, включённых в усреднение, с учётом дополнительного ещё не опубликованного удара.
procedure TRecorderImpactHammerService.CollectIncludedMoments(
  AAdditional: TRecorderPreparedImpact;
  out AIncluded: TRecorderImpactMomentsMatrix);
var
  RecordItem: TRecorderImpactRecord;
  Prepared: TRecorderPreparedImpact;
  I: Integer;
  Count: Integer;
begin
  SetLength(AIncluded, fRuntime.Impacts.Count);
  Count := 0;
  for I := 0 to fRuntime.Impacts.Count - 1 do
  begin
    RecordItem := fRuntime.Impacts.Item(I);
    if not RecordItem.Accepted or RecordItem.Hidden then
      Continue;
    if (AAdditional <> nil) and
      (AAdditional.Sequence = RecordItem.Sequence) then
      Prepared := AAdditional
    else
      Prepared := FindPrepared(RecordItem.Sequence);
    if Prepared = nil then
      Continue;
    AIncluded[Count] := Copy(Prepared.Responses);
    Inc(Count);
  end;
  SetLength(AIncluded, Count);
end;

// Рассчитывает FRF-кривые по матрице ударов; AError возвращает диагностическую причину неуспеха.
function TRecorderImpactHammerService.EstimateCurves(
  const AIncluded: TRecorderImpactMomentsMatrix;
  out ACurves: TRecorderFrfCurveArray; out AQualityOk: Boolean): Boolean;
var
  EstimateInput: TRecorderImpactMomentsArray;
  Estimate: TRecorderFrfEstimate;
  ResponseIndex: Integer;
  I: Integer;
  J: Integer;
begin
  Result := Length(AIncluded) > 0;
  SetLength(ACurves, 0);
  AQualityOk := True;
  if not Result then
    Exit;
  SetLength(ACurves, fModel.ResponseCount);
  SetLength(EstimateInput, Length(AIncluded));
  for ResponseIndex := 0 to fModel.ResponseCount - 1 do
  begin
    for I := 0 to High(AIncluded) do
      EstimateInput[I] := AIncluded[I][ResponseIndex];
    if not EstimateImpactMoments(EstimateInput,
      TRecorderFrfEstimatorKind(Ord(fModel.Estimator)), Estimate) then
      Exit(False);
    ACurves[ResponseIndex].Id := fModel.Responses[ResponseIndex].CurveId;
    ACurves[ResponseIndex].FrequencyHz := Estimate.FrequencyHz;
    ACurves[ResponseIndex].Magnitude := Estimate.Magnitude;
    ACurves[ResponseIndex].PhaseRadians := Estimate.PhaseRadians;
    ACurves[ResponseIndex].Coherence := Estimate.Coherence;
    FillAmplitude(ACurves[ResponseIndex], EstimateInput);
    for J := 0 to High(Estimate.Coherence) do
      if Estimate.Coherence[J] < fModel.CoherenceThreshold then
        AQualityOk := False;
  end;
end;

// Завершает запись порции, обновляет историю удара и возвращает освобождённые банки в запас.
procedure TRecorderImpactHammerService.CompleteCapture;
var
  Block: TRecorderImpactCaptureBlock;
  Prepared: TRecorderPreparedImpact;
  Sequence: QWord;
  Curves: TRecorderFrfCurveArray;
  Included: TRecorderImpactMomentsMatrix;
  QualityOk: Boolean;
  ImpactIndex: Integer;
begin
  fLock.Enter;
  try
    Sequence := fRuntime.RecordImpact(fCaptureToken, True, irrNone);
    fCaptureToken := 0;
    ImpactIndex := fRuntime.Impacts.Count - 1;
    if Sequence <> 0 then
      Block := fRuntime.Impacts.Capture(ImpactIndex);
  finally
    fLock.Leave;
  end;
  if Sequence = 0 then
    Exit;
  { Запасные банки заполняет рабочий поток; следующий триггер в callback сбора
    только сбросит счётчики, не выделяя память. }
  fRuntime.PrepareCaptureSpareBuffers;
  Prepared := TRecorderPreparedImpact.Create;
  Prepared.Sequence := Sequence;
  if not PrepareCapturedResponses(Block, fFilterWindow, fDsp,
    Prepared.Responses, fLastError) then
  begin
    Prepared.Free;
    Exit;
  end;

  fLock.Enter;
  try
    CollectIncludedMoments(Prepared, Included);
  finally
    fLock.Leave;
  end;
  if not EstimateCurves(Included, Curves, QualityOk) then
  begin
    Prepared.Free;
    Exit;
  end;
  fLock.Enter;
  try
    fPrepared.Add(Prepared);
    fRuntime.PublishCurves(Curves);
    fPublishedCurves := Copy(Curves);
    fQualityOk := QualityOk;
    fCurrentImpact := ImpactIndex;
    fShowingRing := False;
    RegisterRecorderFrfProvider(Self, fRuntime.Provider);
    fHasUnsavedRuntime := True;
    if not fResultReview then
    begin
      if fShowingStoredPoint then fRouteBindingsPending := True;
      fShowingStoredPoint := False;
    end;
  finally
    fLock.Leave;
  end;
end;

// Находит подготовленный удар по последовательности или возвращает nil.
function TRecorderImpactHammerService.FindPrepared(
  ASequence: QWord): TRecorderPreparedImpact;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fPrepared.Count - 1 do
    if TRecorderPreparedImpact(fPrepared[I]).Sequence = ASequence then
      Exit(TRecorderPreparedImpact(fPrepared[I]));
end;

// Удаляет удар с номером ASequence из истории подготовленных данных.
procedure TRecorderImpactHammerService.RemovePrepared(ASequence: QWord);
var
  Item: TRecorderPreparedImpact;
begin
  Item := FindPrepared(ASequence);
  if Item = nil then
    Exit;
  fPrepared.Remove(Item);
  Item.Free;
end;

// Освобождает всю историю подготовленных ударов.
procedure TRecorderImpactHammerService.ClearPrepared;
begin
  while fPrepared.Count > 0 do
  begin
    TObject(fPrepared.Last).Free;
    fPrepared.Delete(fPrepared.Count - 1);
  end;
end;

// Пересчитывает агрегированные кривые и атомарно публикует их для читателей.
procedure TRecorderImpactHammerService.RecomputeAndPublish;
var
  Curves: array of TRecorderFrfCurveData;
  Included: array of TRecorderImpactMomentsArray;
  EstimateInput: TRecorderImpactMomentsArray;
  Estimate: TRecorderFrfEstimate;
  RecordItem: TRecorderImpactRecord;
  Prepared: TRecorderPreparedImpact;
  I: Integer;
  J: Integer;
  ResponseIndex: Integer;
  Count: Integer;
begin
  SetLength(Included, fRuntime.Impacts.Count);
  Count := 0;
  for I := 0 to fRuntime.Impacts.Count - 1 do
  begin
    RecordItem := fRuntime.Impacts.Item(I);
    if not RecordItem.Accepted or RecordItem.Hidden then
      Continue;
    Prepared := FindPrepared(RecordItem.Sequence);
    if Prepared <> nil then
    begin
      Included[Count] := Prepared.Responses;
      Inc(Count);
    end;
  end;
  if Count = 0 then
  begin
    fRuntime.ClearPublished;
    SetLength(fPublishedCurves, 0);
    fQualityOk := True;
    Exit;
  end;
  SetLength(Curves, fModel.ResponseCount);
  fQualityOk := True;
  for ResponseIndex := 0 to fModel.ResponseCount - 1 do
  begin
    SetLength(EstimateInput, Count);
    for I := 0 to Count - 1 do
      EstimateInput[I] := Included[I][ResponseIndex];
    if not EstimateImpactMoments(EstimateInput,
      TRecorderFrfEstimatorKind(Ord(fModel.Estimator)), Estimate) then
      Exit;
    Curves[ResponseIndex].Id := fModel.Responses[ResponseIndex].CurveId;
    Curves[ResponseIndex].FrequencyHz := Estimate.FrequencyHz;
    Curves[ResponseIndex].Magnitude := Estimate.Magnitude;
    Curves[ResponseIndex].PhaseRadians := Estimate.PhaseRadians;
    Curves[ResponseIndex].Coherence := Estimate.Coherence;
    FillAmplitude(Curves[ResponseIndex], EstimateInput);
    for J := 0 to High(Estimate.Coherence) do
      if Estimate.Coherence[J] < fModel.CoherenceThreshold then
        fQualityOk := False;
  end;
  fRuntime.PublishCurves(Curves);
  fPublishedCurves := Copy(Curves);
end;

// Собирает UI-снимок из живых расчётных кривых и временных рядов.
// Shared by runtime, manual and saved views; rectangular cursors affect only
// excitation, while response decay is independent of those cursor positions.
procedure TRecorderImpactHammerService.UpdateTimeWindowCoefficients;
begin
  fTimeGlobalDecayRate := Ln(Max(1E-12, fModel.ExponentialEndFraction)) /
    Max(1E-12, (fModel.CaptureSamples - 1) / fModel.SampleRateHz);
  fTimeResponseDecayRate := Ln(Max(1E-12, fFilterWindow.ExponentialEndLevel)) /
    Max(1E-12, fFilterWindow.ExponentialEndSeconds -
      fFilterWindow.ExponentialStartSeconds);
end;

function TRecorderImpactHammerService.FilteredTimeValue(AIndex: Integer;
  ATime, AValue, ABase: Double): Double;
begin
  Result := AValue;
  if not fFilterWindow.Enabled then Exit;
  Result := Result - ABase;
  if (AIndex = 0) and ((ATime < fFilterWindow.StartSeconds) or
    (ATime >= fFilterWindow.EndSeconds)) then Exit(0);
  if fModel.WindowKind = iwExponential then
    Result := Result * Exp(fTimeGlobalDecayRate * ATime);
  if (AIndex > 0) and (ATime > fFilterWindow.ExponentialStartSeconds) then
    Result := Result * Exp(fTimeResponseDecayRate *
      (ATime - fFilterWindow.ExponentialStartSeconds));
end;

procedure TRecorderImpactHammerService.FillPresentation(
  var ASnapshot: TRecorderImpactHammerSnapshot; AMetadataOnly: Boolean);
var
  Block: TRecorderImpactCaptureBlock;
  Prepared: TRecorderPreparedImpact;
  Series: TRecorderSampleSeries;
  Curve: ^TRecorderImpactPresentationCurve;
  ResultType: TRecorderImpactResultType;
  ResponseIndex: Integer;
  CurveIndex: Integer;

  // Создаёт в снимке слот результата указанного типа и индекса.
  procedure InitializeResult(AType: TRecorderImpactResultType;
    const AXUnit: string; ACount: Integer);
  begin
    ASnapshot.Results[AType].ResultType := AType;
    ASnapshot.Results[AType].XUnitName := AXUnit;
    SetLength(ASnapshot.Results[AType].Curves, ACount);
  end;

  // Записывает идентификаторы, имя и единицы выбранной кривой в слот результата.
  procedure SetCurveIdentity(AType: TRecorderImpactResultType;
    AIndex: Integer; AId: QWord; const AName, AUnit: string;
    AColor: LongInt; AVisible: Boolean);
  begin
    Curve := @ASnapshot.Results[AType].Curves[AIndex];
    Curve^.CurveId := AId;
    Curve^.Name := AName;
    Curve^.UnitName := AUnit;
    Curve^.Color := AColor;
    Curve^.Visible := AVisible;
    Curve^.Quality := icqGood;
  end;

  // Копирует временной ряд выбранного типа в UI-снимок.
  procedure CopyTimeSeries(AType: TRecorderImpactResultType; AIndex: Integer;
    const ASeries: TRecorderSampleSeries);
  var
    I: Integer;
    lTailStart: Integer;
    lBase: Double;
    lTime: Double;
    lValue: Double;
  begin
    Curve := @ASnapshot.Results[AType].Curves[AIndex];
    SetLength(Curve^.X, Length(ASeries));
    SetLength(Curve^.Y, Length(ASeries));
    lBase := 0;
    if fFilterWindow.Enabled and (Length(ASeries) > 0) then
    begin
      lTailStart := Trunc(0.9 * Length(ASeries));
      for I := lTailStart to High(ASeries) do
        lBase := lBase + ASeries[I].Value;
      lBase := lBase / (Length(ASeries) - lTailStart);
    end;
    for I := 0 to High(ASeries) do
    begin
      lTime := ASeries[I].TimeSeconds - Block.StartSeconds;
      Curve^.X[I] := lTime;
      lValue := FilteredTimeValue(AIndex, lTime, ASeries[I].Value, lBase);
      Curve^.Y[I] := lValue;
    end;
  end;

  // Копирует частоты и мощности в слот спектра, согласуя длины входных массивов.
  procedure CopySpectrum(AIndex: Integer; const AFrequency, APower: array of Double;
    AFftSize: Integer);
  var
    I: Integer;
    lScale: Double;
  begin
    Curve := @ASnapshot.Results[irtSpectrum].Curves[AIndex];
    SetLength(Curve^.X, Length(AFrequency));
    for I := 0 to High(AFrequency) do
      Curve^.X[I] := AFrequency[I];
    SetLength(Curve^.Y, Length(APower));
    lScale := Sqrt(2.0) / Max(1, AFftSize);
    for I := 0 to High(APower) do
      Curve^.Y[I] := Sqrt(Max(0.0, APower[I])) * lScale;
  end;

  // Переносит опубликованную FRF-кривую в слот снимка, если такая кривая доступна.
  procedure CopyPublished(AType: TRecorderImpactResultType; AIndex: Integer;
    const AX, AY: array of Double);
  var
    I: Integer;
  begin
    Curve := @ASnapshot.Results[AType].Curves[AIndex];
    SetLength(Curve^.X, Length(AX));
    SetLength(Curve^.Y, Length(AY));
    for I := 0 to High(AX) do
      Curve^.X[I] := AX[I];
    for I := 0 to High(AY) do
      Curve^.Y[I] := AY[I];
  end;

begin
  for ResultType := Low(TRecorderImpactResultType) to
    High(TRecorderImpactResultType) do
  begin
    ASnapshot.Results[ResultType].ResultType := ResultType;
    SetLength(ASnapshot.Results[ResultType].Curves, 0);
  end;
  if AMetadataOnly or (fCurrentImpact < 0) or
    (fCurrentImpact >= fRuntime.Impacts.Count) then
  begin
    InitializeResult(irtTime, 's', fModel.ResponseCount + 1);
    InitializeResult(irtSpectrum, 'Hz', fModel.ResponseCount + 1);
    for ResultType := irtFrfMagnitude to irtCoherence do
      InitializeResult(ResultType, 'Hz', fModel.ResponseCount);
    { Видимость силы задаёт только частотное представление. Временной канал
      воздействия остаётся на графике для контроля удара и найденного триггера. }
    SetCurveIdentity(irtTime, 0, 0, fModel.HammerTagName,
      fModel.ExcitationUnitName, $0000FF, True);
    SetCurveIdentity(irtSpectrum, 0, 0, fModel.HammerTagName,
      fModel.ExcitationUnitName, $0000FF, fModel.ExcitationVisible);
    for ResponseIndex := 0 to fModel.ResponseCount - 1 do
    begin
      SetCurveIdentity(irtTime, ResponseIndex + 1,
        fModel.Responses[ResponseIndex].CurveId,
        fModel.Responses[ResponseIndex].TagName,
        fModel.Responses[ResponseIndex].ResponseUnitName,
        fModel.Responses[ResponseIndex].Color,
        fModel.Responses[ResponseIndex].Visible);
      SetCurveIdentity(irtSpectrum, ResponseIndex + 1,
        fModel.Responses[ResponseIndex].CurveId,
        fModel.Responses[ResponseIndex].TagName,
        fModel.Responses[ResponseIndex].ResponseUnitName,
        fModel.Responses[ResponseIndex].Color,
        fModel.Responses[ResponseIndex].Visible);
      for ResultType := irtFrfMagnitude to irtCoherence do
        SetCurveIdentity(ResultType, ResponseIndex,
          fModel.Responses[ResponseIndex].CurveId,
          fModel.Responses[ResponseIndex].TagName,
          fModel.Responses[ResponseIndex].ResponseUnitName,
          fModel.Responses[ResponseIndex].Color,
          fModel.Responses[ResponseIndex].Visible);
    end;
    Exit;
  end;
  Block := fRuntime.Impacts.Capture(fCurrentImpact);
  Prepared := FindPrepared(fRuntime.Impacts.Item(fCurrentImpact).Sequence);

  InitializeResult(irtTime, 's', fModel.ResponseCount + 1);
  SetCurveIdentity(irtTime, 0, 0, fModel.HammerTagName,
    fModel.ExcitationUnitName, $0000FF, True);
  Series := Block.Excitation;
  CopyTimeSeries(irtTime, 0, Series);
  for ResponseIndex := 0 to fModel.ResponseCount - 1 do
  begin
    SetCurveIdentity(irtTime, ResponseIndex + 1,
      fModel.Responses[ResponseIndex].CurveId,
      fModel.Responses[ResponseIndex].TagName,
      fModel.Responses[ResponseIndex].ResponseUnitName,
      fModel.Responses[ResponseIndex].Color,
      fModel.Responses[ResponseIndex].Visible);
    Series := Block.Response(ResponseIndex);
    CopyTimeSeries(irtTime, ResponseIndex + 1, Series);
  end;

  if Prepared <> nil then
  begin
    InitializeResult(irtSpectrum, 'Hz', fModel.ResponseCount + 1);
    SetCurveIdentity(irtSpectrum, 0, 0, fModel.HammerTagName,
      fModel.ExcitationUnitName, $0000FF, fModel.ExcitationVisible);
    if Length(Prepared.Responses) > 0 then
      CopySpectrum(0, Prepared.Responses[0].FrequencyHz,
        Prepared.Responses[0].ExcitationPower,
        Prepared.Responses[0].Metadata.FftSize);
    for ResponseIndex := 0 to High(Prepared.Responses) do
    begin
      SetCurveIdentity(irtSpectrum, ResponseIndex + 1,
        fModel.Responses[ResponseIndex].CurveId,
        fModel.Responses[ResponseIndex].TagName,
        fModel.Responses[ResponseIndex].ResponseUnitName,
        fModel.Responses[ResponseIndex].Color,
        fModel.Responses[ResponseIndex].Visible);
      CopySpectrum(ResponseIndex + 1,
        Prepared.Responses[ResponseIndex].FrequencyHz,
        Prepared.Responses[ResponseIndex].ResponsePower,
        Prepared.Responses[ResponseIndex].Metadata.FftSize);
    end;
  end;

  for ResultType := irtFrfMagnitude to irtCoherence do
    InitializeResult(ResultType, 'Hz', Length(fPublishedCurves));
  for CurveIndex := 0 to High(fPublishedCurves) do
  begin
    ResponseIndex := CurveIndex;
    for ResultType := irtFrfMagnitude to irtCoherence do
      SetCurveIdentity(ResultType, CurveIndex,
        fPublishedCurves[CurveIndex].Id,
        fModel.Responses[ResponseIndex].TagName,
        fModel.Responses[ResponseIndex].ResponseUnitName,
        fModel.Responses[ResponseIndex].Color,
        fModel.Responses[ResponseIndex].Visible);
    CopyPublished(irtFrfMagnitude, CurveIndex,
      fPublishedCurves[CurveIndex].FrequencyHz,
      fPublishedCurves[CurveIndex].Magnitude);
    CopyPublished(irtPhase, CurveIndex,
      fPublishedCurves[CurveIndex].FrequencyHz,
      fPublishedCurves[CurveIndex].PhaseRadians);
    CopyPublished(irtCoherence, CurveIndex,
      fPublishedCurves[CurveIndex].FrequencyHz,
      fPublishedCurves[CurveIndex].Coherence);
  end;
end;

// Формирует снимок по сохранённым данным выбранной точки маршрута.
procedure TRecorderImpactHammerService.FillStoredPresentation(
  var ASnapshot: TRecorderImpactHammerSnapshot; ARing: Boolean);
var
  lType: TRecorderImpactResultType;
  lIndex: Integer;
  lStart: Double;
  lSession: TRecorderImpactSessionSnapshot;

  // Заполняет слот сохранённой кривой и её идентификаторами.
  procedure SetCurve(AType: TRecorderImpactResultType; AIndex: Integer;
    AId: QWord; const AName, AUnit: string; const AX, AY: array of Double);
  var
    lCurve: ^TRecorderImpactPresentationCurve;
    lSample, lResponse: Integer;
  begin
    if Length(ASnapshot.Results[AType].Curves) <= AIndex then
      SetLength(ASnapshot.Results[AType].Curves, AIndex + 1);
    lCurve := @ASnapshot.Results[AType].Curves[AIndex];
    lCurve^.CurveId := AId;
    lCurve^.Name := AName;
    lCurve^.UnitName := AUnit;
    lCurve^.Color := $0000FF;
    lCurve^.Visible := (AType = irtTime) or fModel.ExcitationVisible;
    lCurve^.ReadOnly := True;
    lCurve^.Quality := icqGood;
    for lResponse := 0 to fModel.ResponseCount - 1 do
      if fModel.Responses[lResponse].CurveId = AId then
      begin
        lCurve^.Color := fModel.Responses[lResponse].Color;
        lCurve^.Visible := fModel.Responses[lResponse].Visible;
        Break;
      end;
    SetLength(lCurve^.X, Length(AX));
    SetLength(lCurve^.Y, Length(AY));
    for lSample := 0 to High(AX) do lCurve^.X[lSample] := AX[lSample];
    for lSample := 0 to High(AY) do lCurve^.Y[lSample] := AY[lSample];
  end;

  // Копирует сохранённую временную серию в снимок без изменения временной привязки.
  procedure SetTime(AIndex: Integer; const ASeries: TRecorderImpactSessionSeries);
  var
    lX, lY: array of Double;
    lSample, lTail: Integer;
    lBase: Double;
  begin
    if (Pos(':ring', lSession.SessionId) > 0) and
      (Length(ASeries.Samples) > 0) then
      lStart := ASeries.Samples[0].TimeSeconds;
    SetLength(lX, Length(ASeries.Samples));
    SetLength(lY, Length(ASeries.Samples));
    lBase := 0;
    if fFilterWindow.Enabled and (Length(ASeries.Samples) > 0) then
    begin
      lTail := Trunc(0.9 * Length(ASeries.Samples));
      for lSample := lTail to High(ASeries.Samples) do
        lBase := lBase + ASeries.Samples[lSample].Value;
      lBase := lBase / (Length(ASeries.Samples) - lTail);
    end;
    for lSample := 0 to High(ASeries.Samples) do
    begin
      lX[lSample] := ASeries.Samples[lSample].TimeSeconds - lStart;
      lY[lSample] := FilteredTimeValue(AIndex, lX[lSample],
        ASeries.Samples[lSample].Value, lBase);
    end;
    SetCurve(irtTime, AIndex, ASeries.CurveId, ASeries.Name,
      ASeries.UnitName, lX, lY);
  end;

begin
  if ARing then lSession := fRingSnapshot else lSession := fStoredPoint;
  for lType := Low(TRecorderImpactResultType) to High(TRecorderImpactResultType) do
  begin
    ASnapshot.Results[lType].ResultType := lType;
    ASnapshot.Results[lType].XUnitName := 'Hz';
    ASnapshot.Results[lType].Curves := nil;
  end;
  ASnapshot.Results[irtTime].XUnitName := 's';
  ASnapshot.CanHide := False;
  ASnapshot.CanDelete := False;
  ASnapshot.CanNavigatePrevious := False;
  ASnapshot.CanNavigateNext := False;
  ASnapshot.ImpactCount := Length(lSession.Impacts);
  ASnapshot.ImpactIndex := ASnapshot.ImpactCount - 1;
  if (Length(lSession.Impacts) = 0) and
    (Length(lSession.Curves) = 0) then
  begin
    { Пустой шаг скрывает измерения предыдущего шага, но оставляет в легенде
      настроенные каналы. }
    FillPresentation(ASnapshot, True);
    Exit;
  end;
  if Length(lSession.Impacts) > 0 then
  begin
    lStart := 0;
    if Length(lSession.Impacts[0].Excitation.Samples) > 0 then
      lStart := lSession.Impacts[0].Excitation.Samples[0].TimeSeconds;
    SetTime(0, lSession.Impacts[0].Excitation);
    for lIndex := 0 to High(lSession.Impacts[0].Responses) do
      SetTime(lIndex + 1, lSession.Impacts[0].Responses[lIndex]);
  end;
  for lIndex := 0 to High(lSession.Curves) do
    with lSession.Curves[lIndex] do
    begin
      if lIndex = 0 then
        SetCurve(irtSpectrum, 0, 0, fModel.HammerTagName,
          ExcitationUnitName, FrequencyHz, ExcitationSpectrum);
      SetCurve(irtSpectrum, lIndex + 1, CurveId, Name,
        ResponseUnitName, FrequencyHz, ResponseSpectrum);
      SetCurve(irtFrfMagnitude, lIndex, CurveId, Name,
        ResponseUnitName + '/' + ExcitationUnitName, FrequencyHz, Magnitude);
      SetCurve(irtPhase, lIndex, CurveId, Name, 'rad', FrequencyHz, PhaseRadians);
      SetCurve(irtCoherence, lIndex, CurveId, Name, '', FrequencyHz, Coherence);
    end;
  if ARing and (Length(fRingSpectrumPresentation.Curves) > 0) then
    ASnapshot.Results[irtSpectrum] := fRingSpectrumPresentation
  else if not ARing and (Length(fStoredSpectrumPresentation.Curves) > 0) then
    ASnapshot.Results[irtSpectrum] := fStoredSpectrumPresentation;
  ASnapshot.Results[irtSpectrum].Curves := Copy(ASnapshot.Results[irtSpectrum].Curves);
  for lIndex := 0 to High(ASnapshot.Results[irtSpectrum].Curves) do
    if lIndex = 0 then
      ASnapshot.Results[irtSpectrum].Curves[lIndex].Visible := fModel.ExcitationVisible
    else if lIndex <= fModel.ResponseCount then
    begin
      ASnapshot.Results[irtSpectrum].Curves[lIndex].Visible := fModel.Responses[lIndex - 1].Visible;
      ASnapshot.Results[irtSpectrum].Curves[lIndex].Color := fModel.Responses[lIndex - 1].Color;
    end;
end;

// Добавляет импортированные сравнительные кривые в снимок, не подменяя текущий результат.
procedure TRecorderImpactHammerService.AppendComparison(
  var ASnapshot: TRecorderImpactHammerSnapshot);
var
  ResultType: TRecorderImpactResultType;
  BaseIndex: Integer;
  I: Integer;

  // Добавляет одну кривую сравнения указанного типа и индекса.
  procedure AddCurve(AType: TRecorderImpactResultType; AIndex: Integer;
    const AY: array of Double);
  var
    J: Integer;
  begin
    ASnapshot.Results[AType].Curves[AIndex].CurveId :=
      fComparison.Curves[I].CurveId;
    ASnapshot.Results[AType].Curves[AIndex].Name := '[сравнение] ' +
      fComparison.Curves[I].Name;
    ASnapshot.Results[AType].Curves[AIndex].UnitName :=
      fComparison.Curves[I].ResponseUnitName;
    ASnapshot.Results[AType].Curves[AIndex].Color := $808080;
    ASnapshot.Results[AType].Curves[AIndex].Visible := True;
    ASnapshot.Results[AType].Curves[AIndex].ReadOnly := True;
    ASnapshot.Results[AType].Curves[AIndex].X :=
      Copy(fComparison.Curves[I].FrequencyHz);
    SetLength(ASnapshot.Results[AType].Curves[AIndex].Y, Length(AY));
    for J := 0 to High(AY) do
      ASnapshot.Results[AType].Curves[AIndex].Y[J] := AY[J];
  end;

begin
  if not fHasComparison then
    Exit;
  for ResultType := irtFrfMagnitude to irtCoherence do
  begin
    BaseIndex := Length(ASnapshot.Results[ResultType].Curves);
    SetLength(ASnapshot.Results[ResultType].Curves,
      BaseIndex + Length(fComparison.Curves));
    for I := 0 to High(fComparison.Curves) do
      case ResultType of
        irtFrfMagnitude:
          AddCurve(ResultType, BaseIndex + I,
            fComparison.Curves[I].Magnitude);
        irtPhase:
          AddCurve(ResultType, BaseIndex + I,
            fComparison.Curves[I].PhaseRadians);
        irtCoherence:
          AddCurve(ResultType, BaseIndex + I,
            fComparison.Curves[I].Coherence);
      end;
  end;
end;

// Возвращает последовательность текущего удара либо ноль, когда удар не выбран.
function TRecorderImpactHammerService.ImpactSequence: QWord;
begin
  Result := 0;
  if (fCurrentImpact >= 0) and
    (fCurrentImpact < fRuntime.Impacts.Count) then
    Result := fRuntime.Impacts.Item(fCurrentImpact).Sequence;
end;

// Переключает просмотр на предыдущий доступный удар.
procedure TRecorderImpactHammerService.NavigateToPreviousImpact;
begin
  fLock.Enter;
  try
    if fCompletionPending then
      Exit;
    if fCurrentImpact > 0 then
    begin
      Dec(fCurrentImpact);
      Inc(fRevision);
    end;
  finally
    fLock.Leave;
  end;
end;

// Переключает просмотр на следующий доступный удар.
procedure TRecorderImpactHammerService.NavigateToNextImpact;
begin
  fLock.Enter;
  try
    if fCompletionPending then
      Exit;
    if fCurrentImpact + 1 < fRuntime.Impacts.Count then
    begin
      Inc(fCurrentImpact);
      Inc(fRevision);
    end;
  finally
    fLock.Leave;
  end;
end;

// Меняет признак участия текущего удара в расчёте; AHidden=True исключает его из усреднения.
procedure TRecorderImpactHammerService.SetCurrentImpactHidden(AHidden: Boolean);
var
  RebuildQueued: Boolean;
begin
  RebuildQueued := False;
  fLock.Enter;
  try
    if fCompletionPending then
      Exit;
    if ImpactSequence <> 0 then
      if fRuntime.Impacts.SetHidden(ImpactSequence, AHidden) then
      begin
        Inc(fFilterGeneration);
        fFilterRebuildPending := True;
        Inc(fRevision);
        RebuildQueued := True;
      end;
  finally
    fLock.Leave;
  end;
  if RebuildQueued then
    fWorker.Wake;
end;

// Удаляет текущий удар из истории и обновляет агрегированные кривые.
procedure TRecorderImpactHammerService.DeleteCurrentImpact;
var
  RebuildQueued: Boolean;
begin
  RebuildQueued := False;
  fLock.Enter;
  try
    if fCompletionPending then
      Exit;
    if ImpactSequence <> 0 then
    begin
      RemovePrepared(ImpactSequence);
      if fRuntime.Impacts.Delete(ImpactSequence) then
      begin
        if fCurrentImpact >= fRuntime.Impacts.Count then
          fCurrentImpact := fRuntime.Impacts.Count - 1;
        Inc(fFilterGeneration);
        fFilterRebuildPending := True;
        Inc(fRevision);
        RebuildQueued := True;
      end;
    end;
  finally
    fLock.Leave;
  end;
  if RebuildQueued then
    fWorker.Wake;
end;

// Запускает сбор и взводит триггер для автоматической регистрации удара.
procedure TRecorderImpactHammerService.StartMeasurement;
begin
  fLock.Enter;
  try
    if fCompletionPending or fFilterRebuildPending or not fModel.Enabled or
      fRecorderFaulted then
      Exit;
    fRuntime.Stop;
    fRuntime.Arm;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

// Взводит триггер без изменения выбранной конфигурации измерения.
procedure TRecorderImpactHammerService.ArmMeasurement;
begin
  fLock.Enter;
  try
    if fCompletionPending or fFilterRebuildPending or not fModel.Enabled or
      fRecorderFaulted then
      Exit;
    fRuntime.Arm;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

// Останавливает сбор и завершает либо отменяет незакрытую порцию.
procedure TRecorderImpactHammerService.StopMeasurement;
begin
  CancelRouteAutomation;
  fLock.Enter;
  try
    if fCompletionPending then
    begin
      fStopDeferred := True;
      Inc(fRevision);
      Exit;
    end;
    fRuntime.Stop;
    fCaptureToken := 0;
    fManualPortion := False;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

// Привязывает тег текущей точки маршрута для синхронизации положения.
procedure TRecorderImpactHammerService.BindRoutePointTag;
var lTag: TRecorderTag;
begin
  lTag := nil;
  if (fRegistry <> nil) and (fModel <> nil) and
    (fModel.RoutePointTagId <> 0) then
    lTag := fRegistry.FindById(fModel.RoutePointTagId);
  if (fRegistry <> nil) and (fModel <> nil) and
    (fModel.RoutePointTagId = 0) and (fModel.RoutePointTagName <> '') then
  begin
    lTag := fRegistry.FindByName(fModel.RoutePointTagName);
    if lTag <> nil then fModel.RoutePointTagId := lTag.Id;
  end;
  if lTag <> fRoutePointTag then fRouteTagSync := False;
  fRoutePointTag := lTag;
end;

// Разрешает теги управления автоматическим обходом маршрута.
procedure TRecorderImpactHammerService.BindRouteAutomationTags;
var lAtPoint, lNextStep: TRecorderTag;

  // Ищет тег сначала по стабильному AId, затем по имени AName для совместимости старых привязок.
  function ResolveTag(AId: QWord; const AName: string): TRecorderTag;
  begin
    Result := nil;
    if fRegistry = nil then Exit;
    if AId <> 0 then Result := fRegistry.FindById(AId)
    else if AName <> '' then Result := fRegistry.FindByName(AName);
  end;

begin
  if fModel = nil then Exit;
  lAtPoint := ResolveTag(fModel.RouteAtPointTagId, fModel.RouteAtPointTagName);
  lNextStep := ResolveTag(fModel.RouteNextStepTagId, fModel.RouteNextStepTagName);
  if (lAtPoint = fRouteAtPointTag) and (lNextStep = fRouteNextStepTag) and
    (fAutoConfiguredPulseMs = fModel.RouteNextStepPulseMs) then Exit;
  CancelRouteAutomation;
  fLock.Enter;
  try
    fRouteAtPointTag := lAtPoint;
    fRouteNextStepTag := lNextStep;
    fAutoConfiguredPulseMs := fModel.RouteNextStepPulseMs;
  finally fLock.Leave end;
end;

// Возвращает паузу автоперехода в миллисекундах из текущих настроек.
function TRecorderImpactHammerService.AutomationWaitMs: Cardinal;
begin
  fLock.Enter;
  try
    if fRouteAutoMode or fAutoPulseHigh then Result := 25 else Result := INFINITE;
  finally
    fLock.Leave
  end;
end;

// Сбрасывает ожидание и команды автоматического перехода по маршруту.
procedure TRecorderImpactHammerService.CancelRouteAutomation;
begin
  SetRouteAutoMode(False);
end;

// Включает или выключает обход точек; при отключении отменяет отложенные шаги.
procedure TRecorderImpactHammerService.SetRouteAutoMode(AEnabled: Boolean);
var lResetTag: TRecorderTag; lEffective: Boolean;
begin
  // Остановка сразу запрещает следующий импульс, даже если запись точки уже идёт.
  if not AEnabled then
  begin
    fLock.Enter;
    try fRouteAutoMode := False finally fLock.Leave end;
  end;
  fAutoCommandLock.Enter;
  try
    lResetTag := nil;
    fLock.Enter;
    try
      lEffective := AEnabled and fRecorderRunning and not fRecorderFaulted
        and (fModel <> nil) and fModel.Enabled and fModel.ScenarioEnabled
        and (fRouteAtPointTag <> nil) and (fRouteNextStepTag <> nil)
        and (fRouteAtPointTag <> fRouteNextStepTag)
        and (fRoutePointTag <> fRouteNextStepTag)
        and fRouteNextStepTag.ExternalWriteAllowed;
      if lEffective and fRouteAutoMode then Exit;
      fRouteAutoMode := lEffective;
      if fModel <> nil then fModel.RouteAutoEnabled := fRouteAutoMode;
      if not fRouteAutoMode then
      begin
        if fAutoPulseHigh then lResetTag := fRouteNextStepTag;
        fAutoPulseHigh := False;
        fAutoCapturePending := False;
      end;
      fAutoAtPointHigh := False;
      Inc(fRevision);
    finally fLock.Leave end;
    // Запись тега вызывает подписчиков, поэтому блокировку сбора здесь не держим.
    if (lResetTag <> nil) and (fRegistry <> nil) then
      fRegistry.PublishExternalValue(lResetTag, 0);
    if fRouteAutoMode then SetTriggerEnabled(False);
    if fWorker <> nil then fWorker.Wake;
  finally fAutoCommandLock.Leave end;
end;

// Синхронизирует состояние автоматизации с выбранным шагом маршрута.
procedure TRecorderImpactHammerService.SyncAutomationStep;
var lValue: Double; lIndex: Integer;
begin
  // Числовая синхронизация выполняется без формы; обновление дискового
  // представления и геометрии откладывается до снимка в UI-потоке.
  if not fRouteAutoMode or not fRouteTagSync or fAutoCapturePending or
    fAutoPulseHigh or (fRoutePointTag = nil) or
    (fRoutePointTag.SignalBuffer.Count = 0) then Exit;
  lValue := fRoutePointTag.SignalBuffer.LatestValue;
  if IsNan(lValue) or IsInfinite(lValue) or (lValue < 1) or
    (lValue > fRoute.Count) or (Frac(lValue) <> 0) then Exit;
  lIndex := Trunc(lValue) - 1;
  if lIndex = fRoute.CurrentIndex then Exit;
  fRoute.CurrentIndex := lIndex;
  fAutoStepPresentationPending := True;
  Inc(fRevision);
end;

// Обновляет отображаемую точку маршрута после автоматического перехода.
procedure TRecorderImpactHammerService.RefreshAutomationPresentation;
var lPending: Boolean; lError: string;
begin
  fLock.Enter;
  try lPending := fAutoStepPresentationPending finally fLock.Leave end;
  if not lPending then Exit;
  fAutoCommandLock.Enter;
  try
    fLock.Enter;
    try
      lPending := fAutoStepPresentationPending;
      fAutoStepPresentationPending := False;
    finally fLock.Leave end;
    if lPending then SelectRoutePoint(fRoute.CurrentIndex, lError);
  finally fAutoCommandLock.Leave end;
end;

// Продвигает автоматизацию по таймеру и выполняет готовый переход в UI-потоке.
procedure TRecorderImpactHammerService.PollRouteAutomation;
var
  lHigh, lCapture, lSave, lSkip: Boolean;
  lWriteTag: TRecorderTag;
  lError: string;
begin
  fAutoCommandLock.Enter;
  try
    lCapture := False;
    lSave := False;
    lSkip := False;
    lWriteTag := nil;
    fLock.Enter;
    try
      if fAutoPulseHigh and (GetTickCount64 >= fAutoPulseUntil) then
      begin
        fAutoPulseHigh := False;
        lWriteTag := fRouteNextStepTag;
      end;
    finally fLock.Leave end;
    // Сначала завершаем команду, затем проверяем зависящее от состояния условие.
    if lWriteTag <> nil then fRegistry.PublishExternalValue(lWriteTag, 0);
    fLock.Enter;
    try
      if not fRouteAutoMode then Exit;
      if not fRecorderRunning or fRecorderFaulted then Exit;
      SyncAutomationStep;
      if (fRouteAtPointTag.SignalBuffer.Count > 0) and
        (fRouteAtPointTag.SignalBuffer.LatestValue <> 1) then
        fAutoAtPointHigh := False;
      if fAutoCapturePending then
      begin
        if fRingPending then Exit;
        lSave := (Length(fRingSnapshot.Curves) > 0) and
          (fRoute.CurrentIndex = fAutoCaptureIndex) and
          SameFileName(fRoute.Directory, fAutoCaptureDirectory);
        if not lSave then
        begin
          fRouteAutoMode := False;
          fModel.RouteAutoEnabled := False;
          fAutoCapturePending := False;
          fLastError := 'Авто: FRF не рассчитана или изменён шаг/каталог; переход отменён.';
          Inc(fRevision);
        end;
      end
      else if not fAutoPulseHigh and not fRingPending and
        not fCompletionPending and not fFilterRebuildPending then
      begin
        lHigh := (fRouteAtPointTag.SignalBuffer.Count > 0) and
          (fRouteAtPointTag.SignalBuffer.LatestValue = 1);
        lCapture := lHigh and not fAutoAtPointHigh;
        fAutoAtPointHigh := lHigh;
        if lCapture then
        begin
          fAutoCaptureIndex := fRoute.CurrentIndex;
          fAutoCaptureDirectory := fRoute.Directory;
          lSkip := not fModel.RouteAutoOverwrite and
            (fAutoCaptureIndex >= 0) and (fAutoCaptureIndex < fRoute.Count) and
            fRoute[fAutoCaptureIndex].Captured;
          if lSkip then lCapture := False;
        end;
      end;
    finally fLock.Leave end;
    if lCapture then
    begin
      if TryCaptureRingPortion(lError) then
      begin
        fLock.Enter;
        try fAutoCapturePending := True finally fLock.Leave end;
      end
      else
      begin
        SetRouteAutoMode(False);
        fLock.Enter;
        try fLastError := 'Авто: ' + lError; Inc(fRevision);
        finally fLock.Leave end;
      end;
    end;
    if lSave or lSkip then
    begin
      if lSkip or StoreRingPoint(False, lError) then
      begin
        fLock.Enter;
        try
          fAutoCapturePending := False;
          if not fRouteAutoMode or not fRecorderRunning or fRecorderFaulted then Exit;
          fAutoPulseHigh := True;
          fAutoPulseUntil := GetTickCount64 + QWord(Max(1, fModel.RouteNextStepPulseMs));
        finally fLock.Leave end;
        fRegistry.PublishExternalValue(fRouteNextStepTag, 1);
      end
      else
      begin
        SetRouteAutoMode(False);
        fLock.Enter;
        try fLastError := 'Авто: ' + lError; Inc(fRevision);
        finally fLock.Leave end;
      end;
    end;
  finally fAutoCommandLock.Leave end;
end;

// Включает синхронизацию выбранной точки с тегом маршрута.
procedure TRecorderImpactHammerService.SetRouteTagSync(AEnabled: Boolean);
begin
  fLock.Enter;
  try
    fRouteTagSync := AEnabled and fRecorderRunning and not fRecorderFaulted
      and (fRoutePointTag <> nil);
    if fModel <> nil then fModel.RouteTagSyncEnabled := fRouteTagSync;
    Inc(fRevision);
  finally fLock.Leave end;
end;

// Считывает изменение тега точки; True означает, что выбор маршрута был обновлён.
function TRecorderImpactHammerService.PollRouteTagSync: Boolean;
var lValue: Double; lIndex: Integer; lError: string;
begin
  Result := False;
  fLock.Enter;
  try
    if fRouteAutoMode or fAutoCapturePending or fAutoPulseHigh or not fRouteTagSync or not fRecorderRunning or fRecorderFaulted or
      (fRoutePointTag = nil) or (fRoutePointTag.SignalBuffer.Count = 0) then Exit;
    lValue := fRoutePointTag.SignalBuffer.LatestValue;
    { Значение тега — номер шага маршрута с единицы, а не ID вершины.
      Дробные и выходящие за диапазон значения отклоняются без округления. }
    if IsNan(lValue) or IsInfinite(lValue) or (lValue < 1) or
      (lValue > fRoute.Count) or (Frac(lValue) <> 0) then Exit;
    lIndex := Trunc(lValue) - 1;
    if lIndex = fRoute.CurrentIndex then Exit;
  finally fLock.Leave end;
  { Переход и отображение выполняются при обновлении UI, не при доставке тега
    или сборе данных. Существующая логика переходов сохраняет несохранённые удары. }
  Result := SelectRoutePoint(lIndex, lError);
  if not Result then
  begin
    fLock.Enter;
    try
      fLastError := lError;
      fRouteTagSync := False;
      Inc(fRevision);
    finally fLock.Leave end;
  end;
end;

// Разрешает или запрещает автоматический поиск удара.
procedure TRecorderImpactHammerService.SetTriggerEnabled(AEnabled: Boolean);
begin
  fLock.Enter;
  try
    if fTriggerEnabled = AEnabled then Exit;
    fTriggerEnabled := AEnabled;
    if fCompletionPending then
      fStopDeferred := True
    else
    begin
      fRuntime.Stop;
      fCaptureToken := 0;
      fManualPortion := False;
      if AEnabled and fRecorderRunning and not fRecorderFaulted and
        fModel.Enabled and not fFilterRebuildPending then
        fRuntime.Arm;
    end;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

// Снимает порцию из уже накопленной истории кольцевых буферов; AError описывает неполный или несогласованный набор.
function TRecorderImpactHammerService.TryCaptureRingPortion(
  out AError: string): Boolean;
var
  lSnapshot: TRecorderImpactSessionSnapshot;
  lChannel, lIndex, lCount, lTotal: Integer;
  lTag: TRecorderTag;
  lSeries: ^TRecorderImpactSessionSeries;
  lDuration: Double;
begin
  Result := False;
  AError := '';
  fLock.Enter;
  try
    if not fRecorderRunning or fRecorderFaulted or not fModel.Enabled then
      AError := 'Сначала запустите сбор данных.'
    else if fCompletionPending or fFilterRebuildPending or fRingPending then
      AError := 'Дождитесь завершения обработки порции.';
    if AError <> '' then Exit;
    lSnapshot := Default(TRecorderImpactSessionSnapshot);
    lSnapshot.FormatVersion := 1;
    lSnapshot.SessionId := fModel.Name + ':ring';
    lSnapshot.CreatedUtc := Now;
    lSnapshot.SampleRateHz := fModel.SampleRateHz;
    SetLength(lSnapshot.Impacts, 1);
    lSnapshot.Impacts[0].Sequence := GetTickCount64;
    lSnapshot.Impacts[0].Accepted := True;
    SetLength(lSnapshot.Impacts[0].Responses, fModel.ResponseCount);
    lTotal := 0;
    SetLength(fRingLastBlocks, Length(fPreloadTimes));
    fRingDuration := 0;
    fRingStatus := 'Накопленные данные:';
    for lChannel := 0 to High(fPreloadTimes) do
    begin
      if lChannel = 0 then
      begin
        lTag := fHammerTag;
        lSeries := @lSnapshot.Impacts[0].Excitation;
        lSeries^.CurveId := 0;
        lSeries^.UnitName := fModel.ExcitationUnitName;
      end
      else
      begin
        lTag := fResponseTags[lChannel - 1];
        lSeries := @lSnapshot.Impacts[0].Responses[lChannel - 1];
        lSeries^.CurveId := fModel.Responses[lChannel - 1].CurveId;
        lSeries^.UnitName := fModel.Responses[lChannel - 1].ResponseUnitName;
      end;
      lSeries^.Name := lTag.Name;
      lSeries^.TagId := lTag.Id;
      { Фиксируем блоки в момент команды: рабочий поток не должен читать более
        новые блоки вместо доступных при нажатии. }
      fRingLastBlocks[lChannel] := lTag.LastBlockSnapshot;
      lTag.SnapshotRangeInto(-MaxDouble, False, fPreloadTimes[lChannel],
        fPreloadValues[lChannel], lCount);
      SetLength(lSeries^.Samples, lCount);
      for lIndex := 0 to lCount - 1 do
      begin
        lSeries^.Samples[lIndex].TimeSeconds := fPreloadTimes[lChannel][lIndex];
        lSeries^.Samples[lIndex].Value := fPreloadValues[lChannel][lIndex];
      end;
      Inc(lTotal, lCount);
      lDuration := 0;
      if lCount > 0 then
      begin
        lDuration := lSeries^.Samples[lCount - 1].TimeSeconds -
          lSeries^.Samples[0].TimeSeconds;
        if lCount > 1 then
          lDuration := lDuration + lDuration / (lCount - 1)
        else if lTag.PollFrequencyHz > 0 then
          lDuration := lDuration + 1 / lTag.PollFrequencyHz;
      end;
      fRingDuration := Max(fRingDuration, lDuration);
      fRingStatus := fRingStatus + Format(' %s: %d отсч., %.4g с;',
        [lTag.Name, lCount, lDuration]);
    end;
    if lTotal = 0 then
    begin
      AError := 'В кольцевых буферах ещё нет данных.';
      Exit;
    end;
    fRuntime.Stop;
    fCaptureToken := 0;
    fManualPortion := False;
    fTriggerEnabled := False;
    fRingSnapshot := lSnapshot;
    fRingSpectrumPresentation := Default(TRecorderImpactResultCurves);
    fRingFilterStatus := '';
    fRingRepository.Clear;
    RegisterRecorderFrfProvider(Self, fRingProvider);
    NotifyRecorderFrfProviderChanged(fRingProvider);
    fShowingRing := True;
    fShowingStoredPoint := False;
    fResultReview := False;
    fHasUnsavedRuntime := True;
    fLastError := '';
    fRingPending := True;
    fRouteBindingsPending := True;
    Inc(fRevision);
    fWorker.Wake;
    Result := True;
  finally
    fLock.Leave;
  end;
end;

// Преобразует ожидающий снимок кольца в исходные серии, не теряя временные границы.
procedure TRecorderImpactHammerService.ProcessPendingRing;
var
  lExcitation: TRecorderSampleSeries;
  lResponses: array of TRecorderSampleSeries;
  lStart, lEnd, lStep, lRate: Double;
  lChannel, lIndex: Integer;
  lBlock: TRecorderImpactCaptureBlock;
  lDsp: TRecorderImpactDspPipeline;
  lMoments: TRecorderImpactMomentsArray;
  lIncluded: TRecorderImpactMomentsMatrix;
  lCurves: TRecorderFrfCurveArray;
  lQuality: Boolean;
  lError: string;
  lFallbackReady, lTimeGap, lSpectraReady: Boolean;

  // Выбирает хвост серии нужной длины для выравнивания канала по времени.
  procedure SelectLastBlock(var ASeries: TRecorderImpactSessionSeries;
    AChannel: Integer);
  var J: Integer;
  begin
    SetLength(ASeries.Samples, fRingLastBlocks[AChannel].Count);
    for J := 0 to High(ASeries.Samples) do
    begin
      ASeries.Samples[J].TimeSeconds := fRingLastBlocks[AChannel].Times[J];
      ASeries.Samples[J].Value := fRingLastBlocks[AChannel].Values[J];
    end;
  end;

  // Приводит блок серии к единой временной сетке перед копированием.
  procedure NormalizeBlock(var ASeries: TRecorderSampleSeries);
  var J: Integer; lOrigin: Double;
  begin
    if Length(ASeries) = 0 then Exit;
    lOrigin := ASeries[0].TimeSeconds;
    for J := 0 to High(ASeries) do
      ASeries[J].TimeSeconds := ASeries[J].TimeSeconds - lOrigin;
  end;

  // Копирует исходные значения и временные метки серии в целевой массив.
  procedure CopyRaw(const ASource: TRecorderImpactSessionSeries;
    out ADestination: TRecorderSampleSeries; ATag: TRecorderTag);
  var J: Integer;
  begin
    SetLength(ADestination, Length(ASource.Samples));
    for J := 0 to High(ADestination) do
    begin
      ADestination[J].TimeSeconds := ASource.Samples[J].TimeSeconds;
      ADestination[J].Value := ASource.Samples[J].Value;
    end;
    if Length(ADestination) < 2 then
    begin lError := 'Недостаточно отсчётов: ' + ASource.Name; Exit end;
    lRate := ATag.PollFrequencyHz;
    if (lRate <= 0) and
      (ADestination[High(ADestination)].TimeSeconds > ADestination[0].TimeSeconds) then
      lRate := (Length(ADestination) - 1) /
        (ADestination[High(ADestination)].TimeSeconds - ADestination[0].TimeSeconds);
    if lRate <= 0 then lRate := fModel.SampleRateHz;
    lStep := 1 / lRate;
    for J := 1 to High(ADestination) do
      if Abs((ADestination[J].TimeSeconds - ADestination[J - 1].TimeSeconds) -
        lStep) > Max(1E-8, lStep * 0.01) then lTimeGap := True;
    lStart := Max(lStart, ADestination[0].TimeSeconds);
    { N отсчётов занимают полуоткрытый интервал N/Fs, а не (N-1)/Fs. }
    lEnd := Min(lEnd, ADestination[High(ADestination)].TimeSeconds + lStep);
  end;
begin
  fLock.Enter;
  try
    if not fRingPending then Exit;
  finally fLock.Leave end;
  lBlock := nil;
  lDsp := nil;
  lError := '';
  lSpectraReady := False;
  try
    try
      lStart := -MaxDouble;
      lEnd := MaxDouble;
      lTimeGap := False;
      CopyRaw(fRingSnapshot.Impacts[0].Excitation, lExcitation, fHammerTag);
      SetLength(lResponses, fModel.ResponseCount);
      for lChannel := 0 to High(lResponses) do
        CopyRaw(fRingSnapshot.Impacts[0].Responses[lChannel],
          lResponses[lChannel], fResponseTags[lChannel]);
      if (lEnd <= lStart) or lTimeGap then
      begin
        lFallbackReady := True;
        for lChannel := 0 to High(fRingLastBlocks) do
          if fRingLastBlocks[lChannel].Count < 2 then lFallbackReady := False;
        if lFallbackReady then
        begin
          fLock.Enter;
          try
            SelectLastBlock(fRingSnapshot.Impacts[0].Excitation, 0);
            for lChannel := 0 to High(lResponses) do
              SelectLastBlock(fRingSnapshot.Impacts[0].Responses[lChannel], lChannel + 1);
            fRingStatus := 'Последние блоки без синхронизации; фаза не синхронизирована.';
            fRingSnapshot.SessionId := fModel.Name + ':ring:unsynchronized';
            Inc(fRevision);
          finally fLock.Leave end;
          lError := '';
          lStart := -MaxDouble;
          lEnd := MaxDouble;
          CopyRaw(fRingSnapshot.Impacts[0].Excitation, lExcitation, fHammerTag);
          NormalizeBlock(lExcitation);
          for lChannel := 0 to High(lResponses) do
          begin
            CopyRaw(fRingSnapshot.Impacts[0].Responses[lChannel],
              lResponses[lChannel], fResponseTags[lChannel]);
            NormalizeBlock(lResponses[lChannel]);
          end;
          lStart := 0;
          lEnd := MaxDouble;
          if Length(lExcitation) > 1 then
            lEnd := lExcitation[High(lExcitation)].TimeSeconds +
              (lExcitation[High(lExcitation)].TimeSeconds / (Length(lExcitation) - 1));
          for lChannel := 0 to High(lResponses) do
            if Length(lResponses[lChannel]) > 1 then
              lEnd := Min(lEnd, lResponses[lChannel][High(lResponses[lChannel])].TimeSeconds +
                lResponses[lChannel][High(lResponses[lChannel])].TimeSeconds /
                  (Length(lResponses[lChannel]) - 1));
          fLock.Enter;
          try fRingDuration := lEnd;
          finally fLock.Leave end;
        end
        else
          lError := 'Разные временные шкалы; последний блок содержит менее двух отсчётов, FRF не вычислена.';
      end;
      if lError = '' then
      begin
        lStart := Max(lStart, lEnd - fModel.CaptureSamples / fModel.SampleRateHz);
        lBlock := TRecorderImpactCaptureBlock.Create(1, lStart, lEnd,
          lExcitation, lResponses);
        lDsp := TRecorderImpactDspPipeline.Create;
        if not PrepareCapturedResponses(lBlock, fFilterWindow, lDsp,
          lMoments, lError, True) then
          lError := 'Показана неполная порция; FRF: ' + lError
        else
        begin
          lSpectraReady := True;
          SetLength(lIncluded, 1);
          lIncluded[0] := lMoments;
          if not EstimateCurves(lIncluded, lCurves, lQuality) then
            lError := 'Показаны накопленные данные; FRF не вычислена: недостаточная энергия воздействия.';
        end;
      end;
      fLock.Enter;
      try
        if lSpectraReady then
          fRingSpectrumPresentation := BuildSpectrumPresentation(lMoments);
        if (lError = '') and (Length(lCurves) > 0) then
        begin
          fRingRepository.Publish(lCurves);
          NotifyRecorderFrfProviderChanged(fRingProvider);
          SetLength(fRingSnapshot.Curves, Length(lCurves));
          for lIndex := 0 to High(lCurves) do
          begin
            fRingSnapshot.Curves[lIndex].CurveId := lCurves[lIndex].Id;
            fRingSnapshot.Curves[lIndex].TagId := fResponseTags[lIndex].Id;
            fRingSnapshot.Curves[lIndex].Name := fResponseTags[lIndex].Name;
            fRingSnapshot.Curves[lIndex].ExcitationUnitName := fModel.ExcitationUnitName;
            fRingSnapshot.Curves[lIndex].ResponseUnitName := fModel.Responses[lIndex].ResponseUnitName;
            fRingSnapshot.Curves[lIndex].FrequencyHz := lCurves[lIndex].FrequencyHz;
            fRingSnapshot.Curves[lIndex].Magnitude := lCurves[lIndex].Magnitude;
            fRingSnapshot.Curves[lIndex].PhaseRadians := lCurves[lIndex].PhaseRadians;
            fRingSnapshot.Curves[lIndex].Coherence := lCurves[lIndex].Coherence;
            SetLength(fRingSnapshot.Curves[lIndex].ExcitationSpectrum,
              Length(lMoments[lIndex].ExcitationPower));
            SetLength(fRingSnapshot.Curves[lIndex].ResponseSpectrum,
              Length(lMoments[lIndex].ResponsePower));
            for lChannel := 0 to High(lMoments[lIndex].ExcitationPower) do
            begin
              fRingSnapshot.Curves[lIndex].ExcitationSpectrum[lChannel] :=
                Sqrt(Max(0, lMoments[lIndex].ExcitationPower[lChannel])) *
                Sqrt(2.0) / lMoments[lIndex].Metadata.FftSize;
              fRingSnapshot.Curves[lIndex].ResponseSpectrum[lChannel] :=
                Sqrt(Max(0, lMoments[lIndex].ResponsePower[lChannel])) *
                Sqrt(2.0) / lMoments[lIndex].Metadata.FftSize;
            end;
          end;
        end;
        if lError <> '' then
          if lSpectraReady then fRingFilterStatus := lError
          else fRingStatus := fRingStatus + ' ' + lError;
      finally fLock.Leave end;
    except
      on E: Exception do
      begin
        fLock.Enter;
        try fRingStatus := fRingStatus + ' FRF: ' + E.Message;
        finally fLock.Leave end;
      end;
    end;
  finally
    lDsp.Free;
    lBlock.Free;
    fLock.Enter;
    try fRingPending := False; Inc(fRevision);
    finally fLock.Leave end;
  end;
end;

// Принимает запрос, фиксирует курсоры и ждёт новые отсчёты; False означает, что сбор сейчас недоступен.
function TRecorderImpactHammerService.TryCapturePortion(
  out AError: string): Boolean;
var
  Channel: Integer;
  Tag: TRecorderTag;
begin
  Result := False;
  AError := '';
  fLock.Enter;
  try
    if (fModel = nil) or not fModel.Enabled or not fRecorderRunning or
      fRecorderFaulted then
      AError := 'Сначала запустите сбор данных.'
    else if fCompletionPending or fFilterRebuildPending or fRingPending or fManualPortion or
      (fRuntime.State = isCapturing) then
      AError := 'Дождитесь окончания текущей порции.';
    if AError <> '' then Exit;
    { Фиксируем курсор каждого входа и общую границу по самому позднему
      времени в буферах. После щелчка ждём первый новый отсчёт каждого канала;
      старые/опережающие данные и часы ПК в порцию не попадают. }
    fManualStartBoundary := -MaxDouble;
    for Channel := 0 to High(fBlockCursors) do
    begin
      if Channel = 0 then Tag := fHammerTag
      else Tag := fResponseTags[Channel - 1];
      fBlockCursors[Channel] := Tag.SignalBuffer.CurrentBlockCursor;
      fManualFirstTimes[Channel] := -MaxDouble;
      if Tag.SignalBuffer.Count > 0 then
        fManualStartBoundary := Max(fManualStartBoundary,
          Tag.SignalBuffer.LatestTime);
    end;
    fRuntime.Stop;
    Result := fRuntime.Arm;
    fManualPortion := Result;
    if Result then
    begin
      fManualRequestTick := GetTickCount64;
      RecorderDebugLog(Format('[AKA.Portion] request boundary=%.9g duration=%.9g',
        [fManualStartBoundary, fModel.CaptureSamples / fModel.SampleRateHz]));
      for Channel := 0 to High(fBlockCursors) do
      begin
        if Channel = 0 then Tag := fHammerTag
        else Tag := fResponseTags[Channel - 1];
        RecorderDebugLog(Format('[AKA.Portion] input=%s count=%d latest=%.9g',
          [Tag.Name, Tag.SignalBuffer.Count, Tag.SignalBuffer.LatestTime]));
      end;
      fShowingRing := False;
      fTriggerEnabled := False;
      fLastError := '';
      fResultReview := False;
      fShowingStoredPoint := False;
      fRouteBindingsPending := True;
    end;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

// Применяет координаты и метку геометрической привязки к отображаемой точке.
procedure TRecorderImpactHammerService.ApplyGeometryDisplay(
  var ABinding:TRecorderModelPointBinding; AResponse:TImpactResponseBinding;
  const ALabel:string);
begin
  ABinding.PointLabel:=ALabel;
  if Trim(ABinding.PointLabel)='' then
    ABinding.PointLabel:=IntToStr(ABinding.PointNumber);
  ABinding.Color:=fModel.MarkerColor;
  ABinding.Visualization:=fModel.MarkerVisualization;
  ABinding.MarkerSizePixels:=fModel.MarkerSizePixels;
  ABinding.IntensityLogScale:=fModel.IntensityLogScale;
  ABinding.GradientEnabled:=fModel.MarkerGradientEnabled;
  ABinding.CreateColorModifier:=fModel.CreateColorModifier;
  ABinding.HideAnchors:=not fModel.ShowAnchorMarkers;
  ABinding.OnlySensors:=fModel.OnlySensors;
  ABinding.ShowIntensityValues:=fShowIntensityValues;
  ABinding.IntensitySource:=AResponse.IntensitySource;
  ABinding.BandRms:=AResponse.BandRms;
  ABinding.BandTolerancePercent:=AResponse.BandTolerancePercent;
  ABinding.EnvelopeXEnabled:=AResponse.EnvelopeXEnabled;
  ABinding.EnvelopeYEnabled:=AResponse.EnvelopeYEnabled;
  ABinding.EnvelopeZEnabled:=AResponse.EnvelopeZEnabled;
  ABinding.EnvelopeX:=AResponse.EnvelopeX;
  ABinding.EnvelopeY:=AResponse.EnvelopeY;
  ABinding.EnvelopeZ:=AResponse.EnvelopeZ;
end;

// Возвращает текущий объект маршрута.
function TRecorderImpactHammerService.Route: TRecorderFrfRoute;
begin
  Result := fRoute;
end;

// Запускает захват для выбранного шага маршрута; AError содержит причину отказа.
function TRecorderImpactHammerService.CaptureRouteStep(out AError: string): Boolean;
begin
  Result := StoreRoutePoint(True, AError);
end;

// Сохраняет рассчитанный результат в выбранную точку маршрута.
function TRecorderImpactHammerService.SaveRoutePoint(out AError: string): Boolean;
begin
  Result := StoreRoutePoint(False, AError);
end;

// Проверяет, содержит ли текущая точка маршрута сохранённый результат.
function TRecorderImpactHammerService.RoutePointHasData: Boolean;
begin
  Result := (fRoute.CurrentIndex >= 0) and
    (fRoute.CurrentIndex < fRoute.Count) and
    TRecorderFrfPointStore.Exists(fRoute.PointDirectory(fRoute.CurrentIndex));
end;

// Выбирает точку по AIndex и возвращает причину ошибки через AError.
function TRecorderImpactHammerService.SelectRoutePoint(AIndex: Integer;
  out AError: string): Boolean;
var
  lStored: TRecorderImpactSessionSnapshot;
  lDirectory: string;
  lEntry: TRecorderFrfRouteEntry;
  lBinding: TRecorderFrfRouteBinding;
  I: Integer;
begin
  SynchronizeRouteDirectory;
  AError := '';
  Result := False;
  fLock.Enter;
  try
    if fAutoCapturePending and (AIndex <> fAutoCaptureIndex) then
    begin AError := 'Дождитесь автоматического сохранения шага.'; Exit end;
    if (AIndex < 0) or (AIndex >= fRoute.Count) then
    begin AError := 'Нет такой точки маршрута.'; Exit; end;
    fRoute.CurrentIndex := AIndex;
    lEntry := fRoute[AIndex];
    for I := 0 to fModel.ResponseCount - 1 do
    begin
      fModel.Responses[I].Target3dNodeId := 0;
      fModel.Responses[I].Target3dNodeName := '';
      fModel.Responses[I].PointNumber := 0;
      fModel.Responses[I].PointLabel := '';
    end;
    for I := 0 to High(lEntry.Bindings) do
    begin
      lBinding := lEntry.Bindings[I];
      if (lBinding.ChannelIndex < 0) or (lBinding.ChannelIndex >= fModel.ResponseCount) then Continue;
      fModel.Responses[lBinding.ChannelIndex].Target3dNodeId := lBinding.TargetNodeId;
      fModel.Responses[lBinding.ChannelIndex].Target3dNodeName := lBinding.TargetNodeName;
      fModel.Responses[lBinding.ChannelIndex].PointNumber := lBinding.PointNumber;
      fModel.Responses[lBinding.ChannelIndex].PointLabel := RoutePointLabel(lBinding);
      if lBinding.SceneComponentId <> '' then
        fModel.Target3dComponentId := lBinding.SceneComponentId;
    end;
    // Переход на точку без файла не должен удалять только что измеренный удар.
    if not fResultReview and (fHasUnsavedRuntime or fCompletionPending or
      (fRuntime.State = isCapturing)) then
    begin
      fShowingStoredPoint := False;
      Inc(fRevision);
      PublishCurrentRouteBindings;
      Exit(True);
    end;
    lDirectory := fRoute.PointDirectory(AIndex);
    lStored := Default(TRecorderImpactSessionSnapshot);
    if TRecorderFrfPointStore.Exists(lDirectory) then
      if not TRecorderFrfPointStore.Load(lDirectory, lStored, AError) then Exit;
    fStoredPoint := lStored;
    fStoredSpectrumPresentation := Default(TRecorderImpactResultCurves);
    fShowingRing := False;
    fShowingStoredPoint := True;
    Inc(fFilterGeneration);
    if fFilterWindow.Enabled then
    begin
      fFilterRebuildPending := True;
      fWorker.Wake;
    end;
    if not fResultReview then PublishCurrentRouteBindings;
    Inc(fRevision);
    Result := True;
  finally
    fLock.Leave;
  end;
end;

// Формирует краткую подпись точки по её привязке и метаданным.
function TRecorderImpactHammerService.RoutePointLabel(const ABinding: TRecorderFrfRouteBinding): string;
var lCatalog: IRecorderModelPointCatalog; lLabels: IRecorderModelLabeledPointCatalog;
  lSink: IRecorderModelPointBindingSink; lInfo: TRecorderModelPointInfo;
  lScene: string; I: Integer;
begin
  Result := ABinding.PointLabel;
  lScene := ABinding.SceneComponentId;
  if lScene = '' then lScene := fModel.Target3dComponentId;
  if not FindRecorderModelPointTarget(lScene, lCatalog, lSink) or
    not Supports(lCatalog, IRecorderModelLabeledPointCatalog, lLabels) then Exit;
  Result := '';
  for I := 0 to lLabels.PointCount(ABinding.TargetNodeId) - 1 do
    if lLabels.PointInfo(ABinding.TargetNodeId, I, lInfo) and
      (lInfo.PointNumber = ABinding.PointNumber) then Exit(lInfo.LabelText);
end;

// Публикует в модель геометрические привязки текущего маршрута.
procedure TRecorderImpactHammerService.PublishCurrentRouteBindings;
var lEntry: TRecorderFrfRouteEntry; lMapping: TRecorderFrfRouteBinding;
  lCatalog: IRecorderModelPointCatalog; lSink: IRecorderModelPointBindingSink;
  lBindings: array of TRecorderModelPointBinding;
  lLabelMode: IRecorderModelVertexLabelMode;
  lStepPoints: array of TRecorderModelPointBinding;
  lPointCount: Integer;
  lCurves: TRecorderRouteCurveArray;
  lResponse: TImpactResponseBinding; lScenes: TStringList;
  lScene: string; I, J, K, lCount: Integer;
begin
  if fResultReview then Exit;
  if (fRoute.CurrentIndex < 0) or (fRoute.CurrentIndex >= fRoute.Count) then Exit;
  lEntry := fRoute[fRoute.CurrentIndex];
  if fShowingStoredPoint then
  begin
    SetLength(lCurves, Length(fStoredPoint.Curves));
    for I := 0 to High(fStoredPoint.Curves) do
    begin
      { Сохранённые кривые не должны дублировать ID текущих каналов агрегатора.
        В привязках сцены сохраняем идентификатор, принадлежащий маршруту. }
      lCurves[I].Id := lEntry.CurveId xor (QWord(I + 1) shl 32);
      lCurves[I].FrequencyHz := Copy(fStoredPoint.Curves[I].FrequencyHz);
      lCurves[I].Magnitude := Copy(fStoredPoint.Curves[I].Magnitude);
      lCurves[I].PhaseRadians := Copy(fStoredPoint.Curves[I].PhaseRadians);
      lCurves[I].Coherence := Copy(fStoredPoint.Curves[I].Coherence);
      lCurves[I].Amplitude := Copy(fStoredPoint.Curves[I].ResponseSpectrum);
    end;
    if Length(lCurves) > 0 then
    begin
      fRouteRepository.Publish(lCurves);
      RegisterRecorderFrfProvider(fRoute, fRouteProvider);
      NotifyRecorderFrfProviderChanged(fRouteProvider);
    end;
  end
  else UnregisterRecorderFrfProvider(fRoute);
  lScenes := TStringList.Create;
  try
    GetRecorderModelPointTargetIds(lScenes);
    for I := 0 to High(lEntry.Bindings) do
    begin
      lScene := lEntry.Bindings[I].SceneComponentId;
      if lScene = '' then lScene := fModel.Target3dComponentId;
      if lScenes.IndexOf(lScene) < 0 then lScenes.Add(lScene);
    end;
    for I := 0 to lScenes.Count - 1 do
    begin
      if not FindRecorderModelPointTarget(lScenes[I], lCatalog, lSink) then Continue;
      if Supports(lSink, IRecorderModelVertexLabelMode, lLabelMode) then
        lLabelMode.SetVertexLabelMode(fModel.OnlySensors);
      SetLength(lBindings, Length(lEntry.Bindings)); lCount := 0;
      SetLength(lStepPoints, Length(lEntry.Bindings)); lPointCount := 0;
      for J := 0 to High(lEntry.Bindings) do
      begin
        lMapping := lEntry.Bindings[J];
        lScene := lMapping.SceneComponentId;
        if lScene = '' then lScene := fModel.Target3dComponentId;
        if lScene <> lScenes[I] then Continue;
        if (lMapping.ChannelIndex < 0) or (lMapping.ChannelIndex >= fModel.ResponseCount) then Continue;
        lStepPoints[lPointCount] := Default(TRecorderModelPointBinding);
        lStepPoints[lPointCount].TargetNodeId := lMapping.TargetNodeId;
        lStepPoints[lPointCount].PointNumber := lMapping.PointNumber;
        Inc(lPointCount);
        lResponse := fModel.Responses[lMapping.ChannelIndex];
        lBindings[lCount] := Default(TRecorderModelPointBinding);
        lBindings[lCount].CurveId := lResponse.CurveId;
        if fShowingStoredPoint then
        begin
          K := 0;
          while (K < Length(fStoredPoint.Curves)) and (fStoredPoint.Curves[K].TagId <> lResponse.TagId) do Inc(K);
          if K >= Length(fStoredPoint.Curves) then Continue;
          lBindings[lCount].CurveId := lCurves[K].Id;
        end;
        lBindings[lCount].PointNumber := lMapping.PointNumber;
        lBindings[lCount].TargetNodeId := lMapping.TargetNodeId;
        lBindings[lCount].ModifierTargetNodeId := lMapping.TargetNodeId;
        lBindings[lCount].Enabled := True;
        lBindings[lCount].Mode := fModel.GeometryBindingMode;
        lBindings[lCount].IntensityOnly := lResponse.IntensityOnly;
        if lResponse.IntensityOnly then
          lBindings[lCount].Mode := rgbmIntensity;
        lBindings[lCount].Gain := lResponse.Gain;
        lBindings[lCount].Axis := T3dMotionAxis(Ord(lResponse.Axis));
        lBindings[lCount].Space := T3dMotionSpace(Ord(lResponse.Space));
        ApplyGeometryDisplay(lBindings[lCount], lResponse, RoutePointLabel(lMapping));
        Inc(lCount);
      end;
      SetLength(lBindings, lCount);
      SetLength(lStepPoints, lPointCount);
      if Supports(lSink, IRecorderModelVertexLabelMode, lLabelMode) then
        lLabelMode.SetCurrentStepPoints(lStepPoints);
      lSink.PublishBindings(fModel.Id, lScenes[I], lBindings);
    end;
  finally lScenes.Free end;
end;

// Сохраняет снимок кольцевой записи в точку; AAdvance управляет переходом к следующему шагу.
function TRecorderImpactHammerService.StoreRingPoint(AAdvance: Boolean;
  out AError: string): Boolean;
var
  lSnapshot: TRecorderImpactSessionSnapshot;
  lEntry: TRecorderFrfRouteEntry;
  lCurve: TRecorderFrfCurveData;
  lPoint: Integer;
begin
  Result := False;
  AError := '';
  fLock.Enter;
  try
    if fRingPending or fFilterRebuildPending then
    begin AError := 'Дождитесь расчёта порции.'; Exit end;
    lPoint := fRoute.CurrentIndex;
    if (lPoint < 0) or (lPoint >= fRoute.Count) or
      (Trim(fRoute.Directory) = '') then
    begin AError := 'Задайте текущий шаг и каталог маршрута.'; Exit end;
    lSnapshot := fRingSnapshot;
    lEntry := fRoute[lPoint];
  finally fLock.Leave end;
  Result := TRecorderFrfPointStore.Save(fRoute.PointDirectory(lPoint), lSnapshot, AError);
  if not Result then Exit;
  try
    if Length(lSnapshot.Curves) > 0 then
    begin
      lCurve := Default(TRecorderFrfCurveData);
      lCurve.FrequencyHz := lSnapshot.Curves[0].FrequencyHz;
      lCurve.Magnitude := lSnapshot.Curves[0].Magnitude;
      lCurve.PhaseRadians := lSnapshot.Curves[0].PhaseRadians;
      lCurve.Coherence := lSnapshot.Curves[0].Coherence;
      fRoute.CaptureEntry(lPoint, lCurve);
    end
    else
    begin
      lEntry.Captured := True;
      fRoute.UpdateEntry(lPoint, lEntry);
      fRoute.Save(fRoute.Directory);
    end;
    fLock.Enter;
    try
      if fShowingRing and (Length(fRingSnapshot.Impacts) > 0) and
        (fRingSnapshot.Impacts[0].Sequence = lSnapshot.Impacts[0].Sequence) then
        fHasUnsavedRuntime := False;
      Inc(fRevision);
    finally fLock.Leave end;
    if AAdvance and (lPoint + 1 < fRoute.Count) then
      Result := SelectRoutePoint(lPoint + 1, AError);
  except
    on E: Exception do begin AError := E.Message; Result := False end;
  end;
end;

// Записывает рассчитанные данные в точку маршрута; AAdvance задаёт переход после успешной записи.
function TRecorderImpactHammerService.StoreRoutePoint(AAdvance: Boolean;
  out AError: string): Boolean;
var
  lEntry: TRecorderFrfRouteEntry;
  lPrepared: TRecorderPreparedImpact;
  lIncluded: TRecorderImpactMomentsMatrix;
  lCurves: TRecorderFrfCurveArray;
  lCurve: TRecorderFrfCurveData;
  lSequence: QWord;
  lQuality: Boolean;
  lSnapshot: TRecorderImpactSessionSnapshot;
  lIndex: Integer;
begin
  SynchronizeRouteDirectory;
  if fShowingRing then Exit(StoreRingPoint(AAdvance, AError));
  Result := False;
  AError := '';
  fLock.Enter;
  try
    if fFilterRebuildPending then
    begin AError := 'Дождитесь пересчёта фильтра.'; Exit end;
    if (fRoute.CurrentIndex < 0) or (fRoute.CurrentIndex >= fRoute.Count) then
    begin AError := 'Нет текущей точки маршрута.'; Exit; end;
    if Trim(fRoute.Directory) = '' then
    begin AError := 'Сначала задайте каталог и сохраните маршрут.'; Exit; end;
    if fShowingStoredPoint then
    begin AError := 'Для сохранения получите новую реализацию FRF.'; Exit; end;
    if fCurrentImpact < 0 then
    begin AError := 'Для этой точки сначала получите FRF реализацию.'; Exit; end;
    lSequence := fRuntime.Impacts.Item(fCurrentImpact).Sequence;
    if AAdvance and (lSequence = fLastRouteSequence) then
    begin AError := 'Эта реализация уже сохранена. Получите новый удар для следующей точки.'; Exit; end;
    lEntry := fRoute.Entries[fRoute.CurrentIndex];
    if (lEntry.ChannelIndex < 0) or (lEntry.ChannelIndex >= fModel.ResponseCount) then
    begin AError := 'Канал маршрута отсутствует в настройках FRF.'; Exit; end;
    lPrepared := FindPrepared(lSequence);
    if lPrepared = nil then
    begin AError := 'Дождитесь завершения обработки удара.'; Exit; end;
    SetLength(lIncluded,1);
    lIncluded[0] := lPrepared.Responses;
    if not EstimateCurves(lIncluded,lCurves,lQuality) then
    begin AError := 'Не удалось вычислить отдельную FRF реализацию.'; Exit; end;
    lCurve := lCurves[lEntry.ChannelIndex];
    BuildSnapshot(lSnapshot, fCurrentImpact);
    if Length(lSnapshot.Curves) <> Length(lCurves) then
    begin AError := 'Дождитесь публикации кривых всех каналов.'; Exit; end;
    // Точка маршрута содержит один удар, а не среднее по всей сессии.
    for lIndex := 0 to High(lCurves) do
    begin
      lSnapshot.Curves[lIndex].FrequencyHz := Copy(lCurves[lIndex].FrequencyHz);
      lSnapshot.Curves[lIndex].Magnitude := Copy(lCurves[lIndex].Magnitude);
      lSnapshot.Curves[lIndex].PhaseRadians := Copy(lCurves[lIndex].PhaseRadians);
      lSnapshot.Curves[lIndex].Coherence := Copy(lCurves[lIndex].Coherence);
    end;
  finally fLock.Leave; end;
  try
    if not TRecorderFrfPointStore.Save(fRoute.PointDirectory(fRoute.CurrentIndex),
      lSnapshot, AError) then Exit;
    if AAdvance then fRoute.CaptureCurrent(lCurve)
    else fRoute.CaptureEntry(fRoute.CurrentIndex, lCurve);
    Result := True;
  except
    on E: Exception do AError := E.Message;
  end;
  if Result then
  begin
    fLock.Enter;
    try
      fLastRouteSequence := lSequence;
      // Удар, завершившийся во время записи на диск, остаётся несохранённым.
      if ImpactSequence = lSequence then fHasUnsavedRuntime := False;
      Inc(fRevision);
    finally fLock.Leave; end;
  end;
end;

// Загружает сохранённые результаты маршрута; AError сообщает, почему просмотр не открылся.
function TRecorderImpactHammerService.ShowSavedRoute(out AError: string): Boolean;
var
  lCurves: TRecorderRouteCurveArray;
  lBindings: array of TRecorderModelPointBinding;
  lBindingScenes: array of string;
  lSceneBindings: array of TRecorderModelPointBinding;
  lEntry: TRecorderFrfRouteEntry;
  lMapping: TRecorderFrfRouteBinding;
  lStored: TRecorderImpactSessionSnapshot;
  lSavedCurve: TRecorderImpactSessionCurve;
  lResponse: TImpactResponseBinding;
  lCatalog: IRecorderModelPointCatalog;
  lSink: IRecorderModelPointBindingSink;
  lIndex, J, K, lCount, lSceneIndex: Integer;
  lScene: string;
  lScenes: TStringList;
begin
  SynchronizeRouteDirectory;
  Result := False;
  AError := '';
  if not FindRecorderModelPointTarget(fModel.Target3dComponentId,lCatalog,lSink) then
  begin AError := 'Не найден 3D-компонент для маршрута.'; Exit; end;
  lCount := 0;
  for lIndex := 0 to fRoute.Count - 1 do
    Inc(lCount, Length(fRoute[lIndex].Bindings));
  SetLength(lBindings, lCount);
  SetLength(lBindingScenes, lCount);
  SetLength(lCurves, lCount);
  lCount := 0;
  for lIndex:=0 to fRoute.Count-1 do
  begin
    lEntry:=fRoute.Entries[lIndex];
    // Несохранённые шаги не входят в сводный результат. Ошибка чтения имеющегося
    // файла не считается отсутствием данных и не должна скрываться.
    if not TRecorderFrfPointStore.Exists(fRoute.PointDirectory(lIndex)) then Continue;
    if not TRecorderFrfPointStore.Load(fRoute.PointDirectory(lIndex), lStored, AError) then Exit;
    for J := 0 to High(lEntry.Bindings) do
    begin
    lMapping := lEntry.Bindings[J];
    lScene := lMapping.SceneComponentId;
    if lScene = '' then lScene := fModel.Target3dComponentId;
    if (lMapping.ChannelIndex<0) or (lMapping.ChannelIndex>=fModel.ResponseCount) then
    begin AError:='В маршруте указан отсутствующий канал.'; Exit; end;
    lResponse:=fModel.Responses[lMapping.ChannelIndex];
    K := 0;
    while (K < Length(lStored.Curves)) and
      (lStored.Curves[K].TagId <> lResponse.TagId) do Inc(K);
    if K = Length(lStored.Curves) then
    begin AError := 'Сохранённый шаг не содержит канал ' + lResponse.TagName; Exit; end;
    lSavedCurve := lStored.Curves[K];
    lCurves[lCount].Id := lEntry.CurveId xor (QWord(J + 1) shl 32);
    lCurves[lCount].FrequencyHz := Copy(lSavedCurve.FrequencyHz);
    lCurves[lCount].Magnitude := Copy(lSavedCurve.Magnitude);
    lCurves[lCount].PhaseRadians := Copy(lSavedCurve.PhaseRadians);
    lCurves[lCount].Coherence := Copy(lSavedCurve.Coherence);
    lCurves[lCount].Amplitude := Copy(lSavedCurve.ResponseSpectrum);
    lBindings[lCount]:=Default(TRecorderModelPointBinding);
    lBindings[lCount].CurveId:=lCurves[lCount].Id;
    lBindingScenes[lCount] := lScene;
    lBindings[lCount].PointNumber:=lMapping.PointNumber;
    lBindings[lCount].TargetNodeId:=lMapping.TargetNodeId;
    lBindings[lCount].ModifierTargetNodeId:=lMapping.TargetNodeId;
    lBindings[lCount].Mode:=rgbmIntensity;
    lBindings[lCount].Enabled:=True;
    lBindings[lCount].IntensityOnly:=True;
    lBindings[lCount].Gain:=lResponse.Gain;
    lBindings[lCount].Axis:=T3dMotionAxis(Ord(lResponse.Axis));
    lBindings[lCount].Space:=T3dMotionSpace(Ord(lResponse.Space));
    ApplyGeometryDisplay(lBindings[lCount],lResponse,RoutePointLabel(lMapping));
    Inc(lCount);
    end;
  end;
  if lCount = 0 then
  begin AError := 'В маршруте нет сохранённых FRF с привязками к точкам.'; Exit; end;
  SetLength(lCurves, lCount);
  SetLength(lBindings, lCount);
  SetLength(lBindingScenes, lCount);
  if not fRouteRepository.Publish(lCurves) then
  begin AError:='Сохранённые FRF реализации повреждены.'; Exit; end;
  RegisterRecorderFrfProvider(fRoute,fRouteProvider);
  NotifyRecorderFrfProviderChanged(fRouteProvider);
  lScenes := TStringList.Create;
  try
    GetRecorderModelPointTargetIds(lScenes);
    for lSceneIndex := 0 to lScenes.Count - 1 do
      if FindRecorderModelPointTarget(lScenes[lSceneIndex], lCatalog, lSink) then
      begin
        SetLength(lSceneBindings, Length(lBindings)); K := 0;
        for J := 0 to High(lBindings) do
          if lBindingScenes[J] = lScenes[lSceneIndex] then
          begin lSceneBindings[K] := lBindings[J]; Inc(K) end;
        SetLength(lSceneBindings, K);
        lSink.PublishBindings(fModel.Id, lScenes[lSceneIndex], lSceneBindings);
      end;
  finally lScenes.Free end;
  Result:=True;
end;

// Переключает просмотр сохранённого результата; AShowValues задаёт показ числовых значений.
function TRecorderImpactHammerService.SetResultReview(AEnabled,
  AShowValues: Boolean; out AError: string): Boolean;
var lPreviousValues: Boolean;
begin
  AError := '';
  lPreviousValues := fShowIntensityValues;
  fShowIntensityValues := AShowValues;
  if AEnabled then
  begin
    // Проверяем сохранённые шаги до замены поставщика данных для 3D-сцены.
    Result := ShowSavedRoute(AError);
    if not Result then
    begin fShowIntensityValues := lPreviousValues; Exit end;
    fResultReview := True;
    Result := SelectRoutePoint(fRoute.CurrentIndex, AError);
  end
  else
  begin
    fResultReview := False;
    Result := SelectRoutePoint(fRoute.CurrentIndex, AError);
  end;
end;

// Возвращает сервис от просмотра сохранённых результатов к живым данным маршрута.
procedure TRecorderImpactHammerService.UseLiveRoute;
begin
  fResultReview := False;
  fLock.Enter;
  try
    fShowingStoredPoint := False;
    Inc(fRevision);
  finally fLock.Leave; end;
  UnregisterRecorderFrfProvider(fRoute);
  fRouteRepository.Clear;
  fLastRouteSequence:=0;
  SavePointBindings;
end;

// Возвращает FRF-провайдер сервиса для подписчиков.
function TRecorderImpactHammerService.Provider: IRecorderFrfProvider;
begin
  if fShowingRing then Result := fRingProvider else Result := fRuntime.Provider;
end;

// Проверяет тайм-аут ручного захвата и завершает порцию, если истёк срок ожидания.
procedure TRecorderImpactHammerService.CheckManualDeadline;
var lLimit: QWord; lChannel: Integer; lTag: TRecorderTag;
begin
  fLock.Enter;
  try
    if not fManualPortion or fCompletionPending then Exit;
    lLimit := Ceil(1000 * fModel.CaptureSamples / fModel.SampleRateHz) + 5000;
    if GetTickCount64 - fManualRequestTick < lLimit then Exit;
    fLastError := 'Порция не получена: нет полного интервала данных. Можно повторить съём.';
    for lChannel := 0 to High(fManualFirstTimes) do
    begin
      if lChannel = 0 then lTag := fHammerTag
      else lTag := fResponseTags[lChannel - 1];
      RecorderDebugLog(Format('[AKA.Portion] timeout input=%s first=%.9g latest=%.9g boundary=%.9g',
        [lTag.Name, fManualFirstTimes[lChannel], lTag.SignalBuffer.LatestTime,
         fManualStartBoundary]));
      if fManualFirstTimes[lChannel] = -MaxDouble then
        fLastError := fLastError + ' Ожидается: ' + lTag.Name + '.';
    end;
    { Не прерываем обработку, владеющую данными. Здесь обрабатываются только
      отсутствие входа или неполный сбор; завершённые удары сохраняются. }
    fRuntime.Stop;
    fCaptureToken := 0;
    fManualPortion := False;
    Inc(fRevision);
  finally fLock.Leave end;
end;

// Возвращает номер ревизии опубликованного состояния для обнаружения обновлений.
function TRecorderImpactHammerService.Revision: QWord;
begin
  CheckManualDeadline;
  SynchronizeRouteDirectory;
  fLock.Enter;
  try
    Result := fRevision;
  finally
    fLock.Leave;
  end;
end;

// Согласует каталог хранения с каталогом, назначенным текущему маршруту.
procedure TRecorderImpactHammerService.SynchronizeRouteDirectory;
begin
  if SameFileName(fPresentationDirectory, fRoute.Directory) then Exit;
  fPresentationDirectory := fRoute.Directory;
  fLock.Enter;
  try
    { Дисковое представление относится к каталогу объекта; данные в памяти — нет. }
    fResultReview := False;
    fShowingStoredPoint := not fHasUnsavedRuntime;
    fAutoStepPresentationPending := False;
    fStoredPoint := Default(TRecorderImpactSessionSnapshot);
    fStoredSpectrumPresentation := Default(TRecorderImpactResultCurves);
    Inc(fFilterGeneration);
    fRouteRepository.Clear;
    UnregisterRecorderFrfProvider(fRoute);
    fLastRouteSequence := 0;
    fRouteBindingsPending := True;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

// Проверяет и применяет настройки обработки; AError содержит причину отклонения.
function TRecorderImpactHammerService.TryUpdateProcessingSettings(
  const ASettings: TRecorderImpactProcessingSettings;
  out AError: string): Boolean;
var
  OldEstimator: TImpactFrfEstimator;
  OldWindow: TImpactWindowKind;
  OldWelchSize: Integer;
  OldWelchOverlap: Integer;
  OldWelchEnabled: Boolean;
begin
  Result := False;
  AError := '';
  fLock.Enter;
  try
    if fFilterRebuildPending or
      (fRuntime.State in [isArmed, isCapturing]) then
    begin
      AError := 'Остановите измерение перед изменением обработки.';
      Exit;
    end;
    if (ASettings.Estimator < Ord(Low(TImpactFrfEstimator))) or
      (ASettings.Estimator > Ord(High(TImpactFrfEstimator))) or
      (ASettings.WindowKind < Ord(Low(TImpactWindowKind))) or
      (ASettings.WindowKind > Ord(High(TImpactWindowKind))) then
    begin
      AError := 'Некорректный тип оценки или окна.';
      Exit;
    end;
    OldEstimator := fModel.Estimator;
    OldWindow := fModel.WindowKind;
    OldWelchSize := fModel.WelchSegmentSize;
    OldWelchOverlap := fModel.WelchOverlapPercent;
    OldWelchEnabled := fModel.WelchEnabled;
    fModel.Estimator := TImpactFrfEstimator(ASettings.Estimator);
    fModel.WindowKind := TImpactWindowKind(ASettings.WindowKind);
    fModel.WelchSegmentSize := ASettings.WelchSegmentSize;
    fModel.WelchOverlapPercent := ASettings.WelchOverlapPercent;
    fModel.WelchEnabled := ASettings.WelchEnabled;
    if not fModel.Validate(AError) or not ConfigureRuntime then
    begin
      if AError = '' then
        AError := fLastError;
      fModel.Estimator := OldEstimator;
      fModel.WindowKind := OldWindow;
      fModel.WelchSegmentSize := OldWelchSize;
      fModel.WelchOverlapPercent := OldWelchOverlap;
      fModel.WelchEnabled := OldWelchEnabled;
      ConfigureRuntime;
      Exit;
    end;
    ClearPrepared;
    fRuntime.ClearPublished;
    SetLength(fPublishedCurves, 0);
    fCurrentImpact := -1;
    Inc(fRevision);
    Result := True;
  finally
    fLock.Leave;
  end;
end;

// Проверяет окно фильтра и ставит пересчёт в очередь; AError описывает недопустимые параметры.
function TRecorderImpactHammerService.TrySetFilterWindow(
  const AWindow: TRecorderImpactFilterWindow; out AError: string): Boolean;
var
  CaptureDuration: Double;
begin
  Result := False;
  AError := '';
  CaptureDuration := fModel.CaptureSamples / fModel.SampleRateHz;
  if (AWindow.StartSeconds < 0) or
    (AWindow.EndSeconds > CaptureDuration) or
    (AWindow.EndSeconds <= AWindow.StartSeconds) or
    (AWindow.ExponentialStartSeconds < 0) or
    (AWindow.ExponentialStartSeconds >= CaptureDuration) or
    (AWindow.ExponentialEndSeconds <= AWindow.ExponentialStartSeconds) or
    (AWindow.ExponentialEndSeconds > CaptureDuration) or
    (AWindow.ExponentialEndLevel <= 0) or
    (AWindow.ExponentialEndLevel > 1) then
  begin
    AError := 'Границы временного или экспоненциального окна неверны.';
    Exit;
  end;
  fLock.Enter;
  try
    if fCompletionPending or (fRuntime.State = isCapturing) then
    begin
      AError := 'Дождитесь окончания регистрации текущего удара.';
      Exit;
    end;
    fFilterWindow := AWindow;
    UpdateTimeWindowCoefficients;
    Inc(fFilterGeneration);
    fFilterRebuildPending := True;
    Inc(fRevision);
    Result := True;
  finally
    fLock.Leave;
  end;
  if Result then
    fWorker.Wake;
end;

// Проверяет порог срабатывания и применяет его; AError объясняет отказ.
function TRecorderImpactHammerService.TrySetTriggerThreshold(AValue: Double;
  out AError: string): Boolean;
begin
  Result := False;
  AError := '';
  if IsNan(AValue) or IsInfinite(AValue) or (AValue <= 0) then
  begin
    AError := 'Порог запуска должен быть больше нуля.';
    Exit;
  end;
  fLock.Enter;
  try
    if fCompletionPending or (fRuntime.State = isCapturing) then
    begin
      AError := 'Дождитесь окончания регистрации текущего удара.';
      Exit;
    end;
    fModel.TriggerThreshold := AValue;
    fRuntime.SetThreshold(AValue);
    Inc(fRevision);
    Result := True;
  finally
    fLock.Leave;
  end;
end;

// Публикует набор привязок начиная с ABasePointNumber; AError сообщает о некорректной геометрии.
function TRecorderImpactHammerService.PublishPointBindings(
  ABasePointNumber: Integer; const ACatalog: IRecorderModelPointCatalog;
  const ASink: IRecorderModelPointBindingSink; out AError: string): Boolean;
var
  Bindings: array of TRecorderModelPointBinding;
  Response: TImpactResponseBinding;
  NodeId: QWord;
  I: Integer;
begin
  AError := '';
  Result := (fModel <> nil) and (ACatalog <> nil) and (ASink <> nil);
  if not Result then
  begin
    AError := 'Не задан каталог точек модели или приёмник привязок.';
    Exit;
  end;
  SetLength(Bindings, fModel.ResponseCount);
  for I := 0 to fModel.ResponseCount - 1 do
  begin
    Response := fModel.Responses[I];
    Bindings[I].CurveId := Response.CurveId;
    Bindings[I].PointGroup := Response.PointGroup;
    Bindings[I].PointNumber := Response.PointNumber;
    if Bindings[I].PointNumber < 1 then
      Bindings[I].PointNumber := ABasePointNumber +
        Response.PointIncrement + 1;
    Bindings[I].Mode := fModel.GeometryBindingMode;
    if Response.IntensityOnly then
      Bindings[I].Mode := rgbmIntensity;
    Bindings[I].ModifierTargetNodeId := Response.Target3dNodeId;
    if Bindings[I].ModifierTargetNodeId = 0 then
      Bindings[I].ModifierTargetNodeId := fModel.Target3dNodeId;
    if Bindings[I].Mode = rgbmIntensity then
      NodeId := Bindings[I].ModifierTargetNodeId
    else if not ACatalog.ResolvePoint(Bindings[I].PointGroup,
      Bindings[I].PointNumber, NodeId) then
    begin
      AError := Format('Не найден helper точки %s:%d.',
        [Bindings[I].PointGroup, Bindings[I].PointNumber]);
      Exit(False);
    end;
    Bindings[I].TargetNodeId := NodeId;
    Bindings[I].Axis := T3dMotionAxis(Ord(Response.Axis));
    Bindings[I].Space := T3dMotionSpace(Ord(Response.Space));
    Bindings[I].Gain := Response.Gain;
    Bindings[I].Enabled := Response.Enabled;
    Bindings[I].IntensityOnly := Response.IntensityOnly;
    Bindings[I].Visualization := Response.Visualization;
    Bindings[I].Color := Response.DisplayColor;
    Bindings[I].MarkerSizePixels := Response.MarkerSizePixels;
    Bindings[I].IntensitySource := Response.IntensitySource;
    Bindings[I].BandRms := Response.BandRms;
    Bindings[I].BandTolerancePercent := Response.BandTolerancePercent;
    ApplyGeometryDisplay(Bindings[I],Response,Response.PointLabel);
  end;
  ASink.PublishBindings(fModel.Id, fModel.Target3dComponentId, Bindings);
  Result := True;
end;

// Задаёт целевой объект геометрических привязок для последующего сохранения.
procedure TRecorderImpactHammerService.ConfigurePointBindingTarget(
  const ACatalog: IRecorderModelPointCatalog;
  const ASink: IRecorderModelPointBindingSink);
begin
  fPointCatalog := ACatalog;
  fPointBindingSink := ASink;
end;

// Сохраняет текущие привязки геометрии в назначенное хранилище.
procedure TRecorderImpactHammerService.SavePointBindings;
var
  ErrorText: string;
  Catalog: IRecorderModelPointCatalog;
  Sink: IRecorderModelPointBindingSink;
  lAutoEnabled, lSyncEnabled: Boolean;
begin
  lAutoEnabled := fModel.RouteAutoEnabled;
  lSyncEnabled := fModel.RouteTagSyncEnabled;
  BindRouteAutomationTags;
  fLock.Enter;
  try BindRoutePointTag finally fLock.Leave end;
  if lSyncEnabled <> fRouteTagSync then SetRouteTagSync(lSyncEnabled);
  if lAutoEnabled <> fRouteAutoMode then SetRouteAutoMode(lAutoEnabled);
  if fResultReview then
  begin
    if not ShowSavedRoute(ErrorText) then fLastError:=ErrorText;
    Inc(fRevision);
    Exit;
  end;
  if fModel.ScenarioEnabled and (fRoute.CurrentIndex >= 0) and
    (fRoute.CurrentIndex < fRoute.Count) then
  begin
    PublishCurrentRouteBindings;
    Inc(fRevision);
    Exit;
  end;
  Catalog := fPointCatalog;
  Sink := fPointBindingSink;
  if (Catalog = nil) or (Sink = nil) then
    FindRecorderModelPointTarget(fModel.Target3dComponentId, Catalog, Sink);
  if Sink <> nil then
    Sink.ConfigureAnimation(fModel.Id, fModel.AnimationScale,
      fModel.AnimationFrequencyHz);
  if not PublishPointBindings(fModel.BasePointNumber, Catalog,
    Sink, ErrorText) then
    fLastError := ErrorText
  else
    fLastError := '';
  Inc(fRevision);
end;

// Запускает анимацию модели для показа текущего измерительного шага.
procedure TRecorderImpactHammerService.PlayModelAnimation;
var
  Catalog: IRecorderModelPointCatalog;
  Sink: IRecorderModelPointBindingSink;
begin
  Catalog := fPointCatalog;
  Sink := fPointBindingSink;
  if (Catalog = nil) or (Sink = nil) then
    FindRecorderModelPointTarget(fModel.Target3dComponentId, Catalog, Sink);
  if Sink <> nil then
  begin
    Sink.ConfigureAnimation(fModel.Id, fModel.AnimationScale,
      fModel.AnimationFrequencyHz);
    Sink.PlayAnimation(fModel.Id);
  end;
end;

// Останавливает анимацию модели и освобождает её временное состояние.
procedure TRecorderImpactHammerService.StopModelAnimation;
var
  Catalog: IRecorderModelPointCatalog;
  Sink: IRecorderModelPointBindingSink;
begin
  Catalog := fPointCatalog;
  Sink := fPointBindingSink;
  if (Catalog = nil) or (Sink = nil) then
    FindRecorderModelPointTarget(fModel.Target3dComponentId, Catalog, Sink);
  if Sink <> nil then
    Sink.StopAnimation(fModel.Id);
end;

// Собирает независимый снимок сессии для сериализации или экспорта.
procedure TRecorderImpactHammerService.BuildSessionSnapshot(
  out ASnapshot: TRecorderImpactSessionSnapshot);
begin
  fLock.Enter;
  try
    if fShowingRing then
    begin ASnapshot := fRingSnapshot; Exit end;
  finally fLock.Leave end;
  BuildSnapshot(ASnapshot, -1);
end;

// Копирует текущие серии и параметры сервиса в снимок сессии.
procedure TRecorderImpactHammerService.BuildSnapshot(
  out ASnapshot: TRecorderImpactSessionSnapshot; AImpactIndex: Integer);
var
  Block: TRecorderImpactCaptureBlock;
  RecordItem: TRecorderImpactRecord;
  Prepared: TRecorderPreparedImpact;
  Source: TRecorderSampleSeries;
  I, J, K, lFirst, lCount, lSourceIndex: Integer;

  // Копирует исходную серию в структуру снимка с сохранением начала и шага времени.
  procedure CopySeries(const ASource: TRecorderSampleSeries;
    ATagId, ACurveId: QWord; const AName, AUnit: string;
    out ADestination: TRecorderImpactSessionSeries);
  var
    SampleIndex: Integer;
  begin
    ADestination.TagId := ATagId;
    ADestination.CurveId := ACurveId;
    ADestination.Name := AName;
    ADestination.UnitName := AUnit;
    SetLength(ADestination.Samples, Length(ASource));
    for SampleIndex := 0 to High(ASource) do
    begin
      ADestination.Samples[SampleIndex].TimeSeconds :=
        ASource[SampleIndex].TimeSeconds;
      ADestination.Samples[SampleIndex].Value := ASource[SampleIndex].Value;
    end;
  end;

begin
  fLock.Enter;
  try
    ASnapshot := Default(TRecorderImpactSessionSnapshot);
    ASnapshot.FormatVersion := 1;
    ASnapshot.SessionId := fModel.Name;
    ASnapshot.CreatedUtc := Now;
    ASnapshot.SampleRateHz := fModel.SampleRateHz;
    lFirst := 0;
    lCount := fRuntime.Impacts.Count;
    if AImpactIndex >= 0 then
    begin
      if AImpactIndex >= lCount then
        raise ERangeError.Create('Impact snapshot index out of range');
      lFirst := AImpactIndex;
      lCount := 1;
    end;
    { Сохраняется один удар маршрута. Не копируем всю сессию в память, чтобы
      затем удалить из копии все остальные удары. }
    SetLength(ASnapshot.Impacts, lCount);
    for I := 0 to lCount - 1 do
    begin
      lSourceIndex := lFirst + I;
      RecordItem := fRuntime.Impacts.Item(lSourceIndex);
      Block := fRuntime.Impacts.Capture(lSourceIndex);
      ASnapshot.Impacts[I].Sequence := RecordItem.Sequence;
      ASnapshot.Impacts[I].TriggerTimeSeconds := RecordItem.PeakTimeSeconds;
      ASnapshot.Impacts[I].Accepted := RecordItem.Accepted;
      ASnapshot.Impacts[I].Hidden := RecordItem.Hidden;
      Source := Block.Excitation;
      CopySeries(Source, fModel.HammerTagId, 0, fModel.HammerTagName,
        fModel.ExcitationUnitName, ASnapshot.Impacts[I].Excitation);
      SetLength(ASnapshot.Impacts[I].Responses, fModel.ResponseCount);
      for J := 0 to fModel.ResponseCount - 1 do
      begin
        Source := Block.Response(J);
        CopySeries(Source, fModel.Responses[J].TagId,
          fModel.Responses[J].CurveId, fModel.Responses[J].TagName,
          fModel.Responses[J].ResponseUnitName,
          ASnapshot.Impacts[I].Responses[J]);
      end;
    end;
    Prepared := nil;
    lSourceIndex := fCurrentImpact;
    if AImpactIndex >= 0 then lSourceIndex := AImpactIndex;
    if lSourceIndex >= 0 then
      Prepared := FindPrepared(fRuntime.Impacts.Item(lSourceIndex).Sequence);
    SetLength(ASnapshot.Curves, Length(fPublishedCurves));
    for I := 0 to High(fPublishedCurves) do
    begin
      ASnapshot.Curves[I].CurveId := fPublishedCurves[I].Id;
      if I < fModel.ResponseCount then
      begin
        ASnapshot.Curves[I].TagId := fModel.Responses[I].TagId;
        ASnapshot.Curves[I].Name := fModel.Responses[I].TagName;
        ASnapshot.Curves[I].ResponseUnitName :=
          fModel.Responses[I].ResponseUnitName;
      end;
      ASnapshot.Curves[I].ExcitationUnitName := fModel.ExcitationUnitName;
      ASnapshot.Curves[I].FrequencyHz :=
        Copy(fPublishedCurves[I].FrequencyHz);
      ASnapshot.Curves[I].Magnitude := Copy(fPublishedCurves[I].Magnitude);
      ASnapshot.Curves[I].PhaseRadians :=
        Copy(fPublishedCurves[I].PhaseRadians);
      ASnapshot.Curves[I].Coherence := Copy(fPublishedCurves[I].Coherence);
      if Prepared <> nil then
      begin
        if I < Length(Prepared.Responses) then
        begin
          SetLength(ASnapshot.Curves[I].ExcitationSpectrum,
            Length(Prepared.Responses[I].ExcitationPower));
          SetLength(ASnapshot.Curves[I].ResponseSpectrum,
            Length(Prepared.Responses[I].ResponsePower));
          for K := 0 to High(Prepared.Responses[I].ExcitationPower) do
          begin
            ASnapshot.Curves[I].ExcitationSpectrum[K] := Sqrt(Max(0.0,
              Prepared.Responses[I].ExcitationPower[K])) * Sqrt(2.0) /
              Max(1, Prepared.Responses[I].Metadata.FftSize);
            ASnapshot.Curves[I].ResponseSpectrum[K] := Sqrt(Max(0.0,
              Prepared.Responses[I].ResponsePower[K])) * Sqrt(2.0) /
              Max(1, Prepared.Responses[I].Metadata.FftSize);
          end;
        end;
      end;
    end;
  finally
    fLock.Leave;
  end;
end;

// Сохраняет снимок сессии в AFileName; AError возвращает ошибку сериализации или записи.
function TRecorderImpactHammerService.SaveSession(const AFileName: string;
  const AStore: IRecorderImpactSessionStore;
  const AOptions: TRecorderImpactSessionSaveOptions;
  out AError: string): Boolean;
var
  Snapshot: TRecorderImpactSessionSnapshot;
begin
  if AStore = nil then
  begin
    AError := 'Не задан адаптер сохранения сессии.';
    Exit(False);
  end;
  BuildSessionSnapshot(Snapshot);
  Result := AStore.Save(AFileName, Snapshot, AOptions, AError);
end;

// Загружает сессию из AFileName как сравнение, не заменяя живые данные; AError описывает отказ.
function TRecorderImpactHammerService.ImportComparison(
  const AFileName: string; const APort: IRecorderImpactComparisonPort;
  out AError: string): Boolean;
var
  Snapshot: TRecorderImpactSessionSnapshot;
begin
  if APort = nil then
  begin
    AError := 'Не задан адаптер импорта сравнения.';
    Exit(False);
  end;
  Result := APort.ImportComparison(AFileName, Snapshot, AError);
  if not Result then
    Exit;
  fLock.Enter;
  try
    fComparison := Snapshot;
    fHasComparison := True;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

// Удаляет импортированное сравнение и публикует снимок без него.
procedure TRecorderImpactHammerService.ClearComparison;
begin
  fLock.Enter;
  try
    fComparison := Default(TRecorderImpactSessionSnapshot);
    fHasComparison := False;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

// Снимает согласованное состояние для интерфейса; данные копируются под блокировкой, UI обновляет их отдельно.
procedure TRecorderImpactHammerService.FillSnapshot(
  out ASnapshot: TRecorderImpactHammerSnapshot);
var
  Item: TRecorderImpactRecord;
  lChannel: Integer;
begin
  CheckManualDeadline;
  SynchronizeRouteDirectory;
  RefreshAutomationPresentation;
  fLock.Enter;
  try
  { Представление обновляет UI-поток. Рабочий поток только отмечает смену
    источника; обработчики сцены и модели из него не вызываются. }
  if fRouteBindingsPending then
  begin
    fRouteBindingsPending := False;
    if not fResultReview then PublishCurrentRouteBindings;
  end;
  ASnapshot := Default(TRecorderImpactHammerSnapshot);
  ASnapshot.TriggerEnabled := fTriggerEnabled;
  ASnapshot.RecorderRunning := fRecorderRunning and not fRecorderFaulted;
  ASnapshot.RouteTagSync := fRouteTagSync;
  ASnapshot.RouteAutoMode := fRouteAutoMode;
  ASnapshot.FilterWindow := fFilterWindow;
  ASnapshot.FilterRebuildPending := fFilterRebuildPending;
  if fModel <> nil then
    ASnapshot.CaptureDurationSeconds := fModel.CaptureSamples /
      fModel.SampleRateHz;
  if fCompletionPending then
  begin
    ASnapshot.State := ihsRunning;
    ASnapshot.StatusText := 'Обработка удара...';
    ASnapshot.CanStop := False;
  end;
  if fFilterRebuildPending then
  begin
    ASnapshot.State := ihsRunning;
    ASnapshot.StatusText := 'Пересчёт фильтра...';
    ASnapshot.CanStop := False;
  end;
  if not fFilterRebuildPending and not fCompletionPending then
  case fRuntime.State of
    isIdle:
      ASnapshot.State := ihsIdle;
    isArmed:
      ASnapshot.State := ihsArmed;
    isCapturing:
      ASnapshot.State := ihsRunning;
    isStopped:
      ASnapshot.State := ihsIdle;
    isFaulted:
      ASnapshot.State := ihsFault;
  end;
  if fRecorderFaulted then
    ASnapshot.State := ihsFault;
  if not fFilterRebuildPending and not fCompletionPending then
    ASnapshot.StatusText := fLastError;
  if (ASnapshot.StatusText = '') and not fRecorderRunning then
    ASnapshot.StatusText := 'Сбор остановлен. Включите Preview для съёма порции.';
  if (ASnapshot.StatusText = '') and not fQualityOk then
    ASnapshot.StatusText := 'Когерентность ниже заданного порога.';
  if fManualPortion and not fCompletionPending then
    if fCaptureToken = 0 then
    begin
      ASnapshot.StatusText := 'Ожидание новых данных для порции:';
      for lChannel := 0 to High(fManualFirstTimes) do
        if fManualFirstTimes[lChannel] = -MaxDouble then
        begin
          if lChannel = 0 then
          begin
            ASnapshot.StatusText := ASnapshot.StatusText + ' ' + fModel.HammerTagName
          end
          else
          begin
            ASnapshot.StatusText := ASnapshot.StatusText + ' ' + fModel.Responses[lChannel - 1].TagName;
          end;
        end;
    end
    else
      ASnapshot.StatusText := 'Запись порции...';
  ASnapshot.ImpactIndex := fCurrentImpact;
  ASnapshot.ImpactCount := fRuntime.Impacts.Count;
  ASnapshot.CanNavigatePrevious := fCurrentImpact > 0;
  ASnapshot.CanNavigateNext := fCurrentImpact + 1 < fRuntime.Impacts.Count;
  ASnapshot.CanHide := fCurrentImpact >= 0;
  ASnapshot.CanDelete := fCurrentImpact >= 0;
  ASnapshot.CanStart := fModel.Enabled and fRecorderRunning and
    not fRecorderFaulted and (fRuntime.State = isStopped);
  ASnapshot.CanArm := ASnapshot.CanStart;
  ASnapshot.CanCapturePortion := fModel.Enabled and fRecorderRunning and
    not fRecorderFaulted and not fCompletionPending and
    not fFilterRebuildPending and not fManualPortion and not fRingPending and
    (fRuntime.State in [isStopped, isArmed]);
  ASnapshot.CanStop := fModel.Enabled and fRecorderRunning and
    (fRuntime.State in [isArmed, isCapturing, isFaulted]) and
    not fFilterRebuildPending and not fCompletionPending;
  if fCurrentImpact >= 0 then
  begin
    Item := fRuntime.Impacts.Item(fCurrentImpact);
    ASnapshot.ImpactHidden := Item.Hidden;
  end;
  FillPresentation(ASnapshot);
  if fShowingStoredPoint then
  begin
    FillStoredPresentation(ASnapshot);
    if Pos(':unsynchronized', fStoredPoint.SessionId) > 0 then
      ASnapshot.StatusText := 'Сохранённые последние блоки без синхронизации; фаза не синхронизирована.';
  end;
  if fShowingRing then
  begin
    FillStoredPresentation(ASnapshot, True);
    ASnapshot.CaptureDurationSeconds := fRingDuration;
    ASnapshot.StatusText := fRingStatus;
    if fRingFilterStatus <> '' then
      ASnapshot.StatusText := ASnapshot.StatusText + ' ' + fRingFilterStatus;
    if fRingPending then ASnapshot.StatusText := fRingStatus + ' Расчёт FRF...';
  end;
  AppendComparison(ASnapshot);
  finally
    fLock.Leave;
  end;
end;

end.
