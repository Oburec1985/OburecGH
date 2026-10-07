unit uRecorderImpactHammerService;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Recorder adapter joining stable tag identities, the headless impact runtime,
  post-capture DSP, and the shared immutable FRF repository. }

interface

uses
  Classes, SysUtils, Math, SyncObjs, uRecorderTags, uRecorderCoreServices,
  uRecorderStateMachine,
  u3dMotionContracts,
  uRecorderImpactHammerModel, uRecorderImpactHammer, uRecorderImpactDsp,
  uRecorderFrfContracts, uRecorderFrfRepository,
  uRecorderImpactHammerContracts, uRecorderImpactSessionContracts;

type
  TRecorderImpactHammerService = class;

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

  TRecorderPreparedImpact = class
  public
    Sequence: QWord;
    Responses: TRecorderImpactMomentsArray;
  end;

  TRecorderImpactHammerService = class(TInterfacedObject,
    IRecorderImpactHammerApplicationService)
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
    fSubscription: Integer;
    fCaptureToken: QWord;
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
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure ProcessSample(ATag: TRecorderTag; AChannel: Integer;
      ATime, AValue: Double);
    procedure ProcessPublishedBlocks(ATag: TRecorderTag);
    procedure PreloadCapture;
    procedure AddSnapshot(ATag: TRecorderTag; AChannel: Integer);
    procedure CompleteCapture;
    procedure ProcessPendingCapture;
    procedure ProcessPendingFilter;
    procedure RecomputeAndPublish;
    function RebuildPreparedImpacts(out AError: string): Boolean;
    function FindPrepared(ASequence: QWord): TRecorderPreparedImpact;
    procedure RemovePrepared(ASequence: QWord);
    procedure ClearPrepared;
    function ResolveTags: Boolean;
    procedure PrepareCaptureBuffers;
    function ConfigureRuntime: Boolean;
    function ConfigureDsp: Boolean;
    function ImpactSequence: QWord;
    procedure FillPresentation(var ASnapshot: TRecorderImpactHammerSnapshot);
    procedure AppendComparison(var ASnapshot: TRecorderImpactHammerSnapshot);
    procedure SetRecorderLifecycle(ARunning, AFaulted: Boolean);
    function ChannelForTag(ATag: TRecorderTag): Integer;
    procedure BuildChannelCache;
    procedure CollectIncludedMoments(AAdditional: TRecorderPreparedImpact;
      out AIncluded: TRecorderImpactMomentsMatrix);
    function EstimateCurves(const AIncluded: TRecorderImpactMomentsMatrix;
      out ACurves: TRecorderFrfCurveArray;
      out AQualityOk: Boolean): Boolean;
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
    procedure StopMeasurement;
    procedure SavePointBindings;
    procedure PlayModelAnimation;
    procedure StopModelAnimation;
    procedure ConfigurePointBindingTarget(
      const ACatalog: IRecorderModelPointCatalog;
      const ASink: IRecorderModelPointBindingSink);
    function Provider: IRecorderFrfProvider;
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

procedure TRecorderImpactHammerService.SetRecorderLifecycle(
  ARunning, AFaulted: Boolean);
begin
  fLock.Enter;
  try
    fRecorderRunning := ARunning;
    fRecorderFaulted := AFaulted;
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

constructor TRecorderImpactWorker.Create(AOwner: TRecorderImpactHammerService);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fOwner := AOwner;
  fWake := TEvent.Create(nil, False, False, '');
  Start;
end;

destructor TRecorderImpactWorker.Destroy;
begin
  Terminate;
  fWake.SetEvent;
  WaitFor;
  fWake.Free;
  inherited Destroy;
end;

procedure TRecorderImpactWorker.Wake;
begin
  fWake.SetEvent;
end;

procedure TRecorderImpactWorker.Execute;
begin
  while not Terminated do
  begin
    fWake.WaitFor(INFINITE);
    if not Terminated then
    begin
      fOwner.ProcessPendingCapture;
      fOwner.ProcessPendingFilter;
    end;
  end;
end;

constructor TRecorderImpactHammerService.Create;
begin
  inherited Create;
  fRuntime := TRecorderImpactRuntime.Create;
  fDsp := TRecorderImpactDspPipeline.Create;
  fLock := TCriticalSection.Create;
  fPrepared := TList.Create;
  fWorker := TRecorderImpactWorker.Create(Self);
  fQualityOk := True;
  Inc(fRevision);
  fCurrentImpact := -1;
end;

destructor TRecorderImpactHammerService.Destroy;
begin
  if (fSubscription <> 0) and (fRegistry <> nil) and
    (fRegistry.EventBus <> nil) then
    fRegistry.EventBus.Unsubscribe(fSubscription);
  fWorker.Free;
  UnregisterRecorderFrfProvider(Self);
  ClearPrepared;
  fPrepared.Free;
  fDsp.Free;
  fRuntime.Free;
  fLock.Free;
  inherited Destroy;
end;

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

function TRecorderImpactHammerService.ConfigureRuntime: Boolean;
var
  RuntimeSettings: TRecorderImpactSettings;
begin
  RuntimeSettings := Default(TRecorderImpactSettings);
  RuntimeSettings.SampleRateHz := fModel.SampleRateHz;
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
  if fFilterWindow.ExponentialEndLevel > 0 then
    DspSettings.ExponentialEndFraction :=
      fFilterWindow.ExponentialEndLevel;
  DspSettings.ExcitationUnitName := fModel.ExcitationUnitName;
  SetLength(DspSettings.ResponseUnitNames, fModel.ResponseCount);
  for I := 0 to fModel.ResponseCount - 1 do
    DspSettings.ResponseUnitNames[I] := fModel.Responses[I].ResponseUnitName;
  Result := fDsp.Configure(DspSettings, fLastError);
end;

function TRecorderImpactHammerService.Configure(
  AComponent: TRecorderImpactHammerComponent;
  ARegistry: TRecorderTagRegistry): Boolean;
begin
  UnregisterRecorderFrfProvider(Self);
  if (fSubscription <> 0) and (fRegistry <> nil) and
    (fRegistry.EventBus <> nil) then
    fRegistry.EventBus.Unsubscribe(fSubscription);
  fSubscription := 0;
  FreeAndNil(fWorker);
  fLock.Enter;
  try
    fModel := AComponent;
    fRegistry := ARegistry;
    fLastError := '';
    fCaptureToken := 0;
    fCurrentImpact := -1;
    fCompletionPending := False;
    fStopDeferred := False;
    fFilterWindow := Default(TRecorderImpactFilterWindow);
    fFilterWindow.StartSeconds := 0;
    fFilterWindow.EndSeconds := fModel.CaptureSamples / fModel.SampleRateHz;
    fFilterWindow.ExponentialStartSeconds := 0;
    fFilterWindow.ExponentialEndSeconds := fFilterWindow.EndSeconds;
    fFilterWindow.ExponentialEndLevel := fModel.ExponentialEndFraction;
    fRuntime.Stop;
    ClearPrepared;
    fRuntime.ClearPublished;
    fQualityOk := True;
    Inc(fRevision);
    Result := ResolveTags and ConfigureRuntime;
    fRecorderFaulted := not Result;
    if Result then
      PrepareCaptureBuffers;
    fWorker := TRecorderImpactWorker.Create(Self);
    if Result and (fRegistry.EventBus <> nil) then
      fSubscription := fRegistry.EventBus.Subscribe(@HandleEvent);
    if Result then
      RegisterRecorderFrfProvider(Self, fRuntime.Provider);
  finally
    fLock.Leave;
  end;
end;

function TRecorderImpactHammerService.RebuildPreparedImpacts(
  out AError: string): Boolean;
var
  Block: TRecorderImpactCaptureBlock;
  Series: TRecorderSampleSeries;
  Resampled: array of Double;
  Moments: TRecorderImpactSpectralMoments;
  Prepared: TRecorderPreparedImpact;
  ImpactIndex: Integer;
  ResponseIndex: Integer;
  SampleIndex: Integer;
begin
  AError := '';
  ClearPrepared;
  SetLength(Resampled, fModel.CaptureSamples);
  for ImpactIndex := 0 to fRuntime.Impacts.Count - 1 do
  begin
    Block := fRuntime.Impacts.Capture(ImpactIndex);
    fDsp.ResetCapture;
    Series := Block.Excitation;
    if not ResampleImpactSeries(Series, Block.StartSeconds,
      fModel.SampleRateHz, fModel.CaptureSamples, Resampled) then
    begin
      AError := 'Не удалось подготовить канал молотка для пересчёта.';
      Exit(False);
    end;
    for SampleIndex := 0 to fModel.CaptureSamples - 1 do
      fDsp.AddSample(0, Resampled[SampleIndex]);
    for ResponseIndex := 0 to fModel.ResponseCount - 1 do
    begin
      Series := Block.Response(ResponseIndex);
      if not ResampleImpactSeries(Series, Block.StartSeconds,
        fModel.SampleRateHz, fModel.CaptureSamples, Resampled) then
      begin
        AError := 'Не удалось подготовить канал отклика для пересчёта.';
        Exit(False);
      end;
      for SampleIndex := 0 to fModel.CaptureSamples - 1 do
        fDsp.AddSample(ResponseIndex + 1, Resampled[SampleIndex]);
    end;
    Prepared := TRecorderPreparedImpact.Create;
    Prepared.Sequence := fRuntime.Impacts.Item(ImpactIndex).Sequence;
    SetLength(Prepared.Responses, fModel.ResponseCount);
    for ResponseIndex := 0 to fModel.ResponseCount - 1 do
      if not fDsp.PrepareResponse(ResponseIndex, Moments) then
      begin
        Prepared.Free;
        AError := 'Не удалось пересчитать спектральные моменты удара.';
        Exit(False);
      end
      else
        Prepared.Responses[ResponseIndex] := Moments;
    fPrepared.Add(Prepared);
  end;
  RecomputeAndPublish;
  Result := True;
end;

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
    if fModel.Enabled then
      ArmMeasurement;
    Exit;
  end;
  if (AEvent.Kind = rceRunTransitionAfter) and
    (AEvent.Transition in [rstStopToView, rstStopToRecord]) then
  begin
    SetRecorderLifecycle(True, False);
    if fModel.Enabled then
      ArmMeasurement;
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
  while ATag.SignalBuffer.SnapshotNextBlockInto(fBlockCursors[Channel],
    fBlockTimes[Channel], fBlockValues[Channel], Count) do
    for I := 0 to Count - 1 do
      ProcessSample(ATag, Channel, fBlockTimes[Channel][I],
        fBlockValues[Channel][I]);
end;

procedure TRecorderImpactHammerService.ProcessSample(ATag: TRecorderTag;
  AChannel: Integer; ATime, AValue: Double);
var
  TriggerEvent: TRecorderImpactTriggerEvent;
  Channel: Integer;
begin
  { The worker owns runtime/prepared state until the completed impact is
    committed. Samples arriving meanwhile are deliberately dropped; starting
    another capture would race the same runtime and DSP instances. }
  if fCompletionPending or fFilterRebuildPending then
    Exit;
  if (ATag = fHammerTag) and (fCaptureToken = 0) and
    fRuntime.ProcessTriggerSample(ATime, AValue, TriggerEvent) then
  begin
    fCaptureToken := TriggerEvent.CaptureToken;
    fCaptureStartSeconds := TriggerEvent.CaptureStartSeconds;
    fCaptureEndSeconds := TriggerEvent.CaptureEndSeconds;
    PreloadCapture;
  end;
  if fCaptureToken = 0 then
    Exit;
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
      if fStopDeferred then
      begin
        fRuntime.Stop;
        fCaptureToken := 0;
        fStopDeferred := False;
      end;
      Inc(fRevision);
    finally
      fLock.Leave;
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
  DspSettings: TRecorderImpactDspSettings;
  LocalDsp: TRecorderImpactDspPipeline;
  NewPrepared: TList;
  OldPrepared: TList;
  Prepared: TRecorderPreparedImpact;
  Series: TRecorderSampleSeries;
  Resampled: array of Double;
  Moments: TRecorderImpactSpectralMoments;
  Included: TRecorderImpactMomentsMatrix;
  Curves: TRecorderFrfCurveArray;
  QualityOk: Boolean;
  ErrorText: string;
  I: Integer;
  J: Integer;
  K: Integer;
  IncludedCount: Integer;

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
    SetLength(Blocks, fRuntime.Impacts.Count);
    SetLength(IncludedFlags, fRuntime.Impacts.Count);
    SetLength(Sequences, fRuntime.Impacts.Count);
    for I := 0 to fRuntime.Impacts.Count - 1 do
    begin
      Blocks[I] := fRuntime.Impacts.Capture(I);
      IncludedFlags[I] := fRuntime.Impacts.Item(I).Accepted and
        not fRuntime.Impacts.Item(I).Hidden;
      Sequences[I] := fRuntime.Impacts.Item(I).Sequence;
    end;
  finally
    fLock.Leave;
  end;

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
  DspSettings.WindowEnabled := Window.Enabled;
  DspSettings.WindowStartFraction := Window.StartSeconds /
    Max(1E-12, fModel.CaptureSamples / fModel.SampleRateHz);
  DspSettings.WindowEndFraction := Window.EndSeconds /
    Max(1E-12, fModel.CaptureSamples / fModel.SampleRateHz);
  DspSettings.ExponentialStartFraction := Window.ExponentialStartSeconds /
    Max(1E-12, fModel.CaptureSamples / fModel.SampleRateHz);
  if Window.ExponentialEndLevel > 0 then
    DspSettings.ExponentialEndFraction := Window.ExponentialEndLevel;
  DspSettings.ExcitationUnitName := fModel.ExcitationUnitName;
  SetLength(DspSettings.ResponseUnitNames, fModel.ResponseCount);
  for I := 0 to fModel.ResponseCount - 1 do
    DspSettings.ResponseUnitNames[I] := fModel.Responses[I].ResponseUnitName;

  LocalDsp := TRecorderImpactDspPipeline.Create;
  NewPrepared := TList.Create;
  OldPrepared := nil;
  try
    if not LocalDsp.Configure(DspSettings, ErrorText) then
    begin
      FailCurrentRequest(ErrorText);
      Exit;
    end;
    SetLength(Resampled, fModel.CaptureSamples);
    SetLength(Included, Length(Blocks));
    IncludedCount := 0;
    for I := 0 to High(Blocks) do
    begin
      LocalDsp.ResetCapture;
      Series := Blocks[I].Excitation;
      if not ResampleImpactSeries(Series, Blocks[I].StartSeconds,
        fModel.SampleRateHz, fModel.CaptureSamples, Resampled) then
      begin
        FailCurrentRequest('Не удалось пересчитать канал молотка.');
        Exit;
      end;
      for K := 0 to fModel.CaptureSamples - 1 do
        LocalDsp.AddSample(0, Resampled[K]);
      for J := 0 to fModel.ResponseCount - 1 do
      begin
        Series := Blocks[I].Response(J);
        if not ResampleImpactSeries(Series, Blocks[I].StartSeconds,
          fModel.SampleRateHz, fModel.CaptureSamples, Resampled) then
        begin
          FailCurrentRequest('Не удалось пересчитать канал отклика.');
          Exit;
        end;
        for K := 0 to fModel.CaptureSamples - 1 do
          LocalDsp.AddSample(J + 1, Resampled[K]);
      end;
      Prepared := TRecorderPreparedImpact.Create;
      Prepared.Sequence := Sequences[I];
      SetLength(Prepared.Responses, fModel.ResponseCount);
      for J := 0 to fModel.ResponseCount - 1 do
      begin
        if not LocalDsp.PrepareResponse(J, Moments) then
        begin
          Prepared.Free;
          FailCurrentRequest('Не удалось подготовить спектральные моменты.');
          Exit;
        end;
        Prepared.Responses[J] := Moments;
      end;
      NewPrepared.Add(Prepared);
      if IncludedFlags[I] then
      begin
        Included[IncludedCount] := Copy(Prepared.Responses);
        Inc(IncludedCount);
      end;
    end;
    SetLength(Included, IncludedCount);
    if (IncludedCount > 0) and
      not EstimateCurves(Included, Curves, QualityOk) then
    begin
      FailCurrentRequest('Не удалось пересчитать FRF.');
      Exit;
    end;
    fLock.Enter;
    try
      if Generation <> fFilterGeneration then
      begin
        fWorker.Wake;
        Exit;
      end;
      OldPrepared := fPrepared;
      fPrepared := NewPrepared;
      NewPrepared := nil;
      if IncludedCount = 0 then
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
      Inc(fRevision);
    finally
      fLock.Leave;
    end;
  finally
    FreePreparedList(OldPrepared);
    FreePreparedList(NewPrepared);
    LocalDsp.Free;
  end;
end;

procedure TRecorderImpactHammerService.AddSnapshot(ATag: TRecorderTag;
  AChannel: Integer);
var
  Times: TRecorderDoubleArray;
  Values: TRecorderDoubleArray;
  Count: Integer;
  I: Integer;
begin
  Times := fPreloadTimes[AChannel];
  Values := fPreloadValues[AChannel];
  ATag.SnapshotRangeInto(fCaptureStartSeconds, True, Times, Values, Count);
  fPreloadTimes[AChannel] := Times;
  fPreloadValues[AChannel] := Values;
  for I := 0 to Count - 1 do
  begin
    if AChannel = 0 then
      fRuntime.AddExcitationSample(fCaptureToken, Times[I], Values[I])
    else
      fRuntime.AddResponseSample(fCaptureToken, AChannel - 1,
        Times[I], Values[I]);
    if Times[I] >= fCaptureEndSeconds then
      Break;
  end;
end;

procedure TRecorderImpactHammerService.PreloadCapture;
var
  I: Integer;
begin
  AddSnapshot(fHammerTag, 0);
  for I := 0 to High(fResponseTags) do
    AddSnapshot(fResponseTags[I], I + 1);
end;

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
    for J := 0 to High(Estimate.Coherence) do
      if Estimate.Coherence[J] < fModel.CoherenceThreshold then
        AQualityOk := False;
  end;
end;

procedure TRecorderImpactHammerService.CompleteCapture;
var
  Block: TRecorderImpactCaptureBlock;
  Series: TRecorderSampleSeries;
  Resampled: array of Double;
  Moments: TRecorderImpactSpectralMoments;
  Prepared: TRecorderPreparedImpact;
  Sequence: QWord;
  Curves: TRecorderFrfCurveArray;
  Included: TRecorderImpactMomentsMatrix;
  QualityOk: Boolean;
  ImpactIndex: Integer;
  I: Integer;
  J: Integer;
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
  { Replenish the detached capture bank on the completion worker. The next
    trigger therefore only resets counters in its acquisition callback. }
  fRuntime.PrepareCaptureSpareBuffers;
  fDsp.ResetCapture;
  SetLength(Resampled, fModel.CaptureSamples);
  Series := Block.Excitation;
  if not ResampleImpactSeries(Series, Block.StartSeconds,
    fModel.SampleRateHz, fModel.CaptureSamples, Resampled) then
    Exit;
  for J := 0 to fModel.CaptureSamples - 1 do
    fDsp.AddSample(0, Resampled[J]);
  for I := 0 to fModel.ResponseCount - 1 do
  begin
    Series := Block.Response(I);
    if not ResampleImpactSeries(Series, Block.StartSeconds,
      fModel.SampleRateHz, fModel.CaptureSamples, Resampled) then
      Exit;
    for J := 0 to fModel.CaptureSamples - 1 do
      fDsp.AddSample(I + 1, Resampled[J]);
  end;
  if not fDsp.Ready then
    Exit;
  Prepared := TRecorderPreparedImpact.Create;
  Prepared.Sequence := Sequence;
  SetLength(Prepared.Responses, fModel.ResponseCount);
  for I := 0 to fModel.ResponseCount - 1 do
  begin
    if not fDsp.PrepareResponse(I, Moments) then
    begin
      Prepared.Free;
      Exit;
    end;
    Prepared.Responses[I] := Moments;
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
  finally
    fLock.Leave;
  end;
end;

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

procedure TRecorderImpactHammerService.ClearPrepared;
begin
  while fPrepared.Count > 0 do
  begin
    TObject(fPrepared.Last).Free;
    fPrepared.Delete(fPrepared.Count - 1);
  end;
end;

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
    for J := 0 to High(Estimate.Coherence) do
      if Estimate.Coherence[J] < fModel.CoherenceThreshold then
        fQualityOk := False;
  end;
  fRuntime.PublishCurves(Curves);
  fPublishedCurves := Copy(Curves);
end;

procedure TRecorderImpactHammerService.FillPresentation(
  var ASnapshot: TRecorderImpactHammerSnapshot);
var
  Block: TRecorderImpactCaptureBlock;
  Prepared: TRecorderPreparedImpact;
  Series: TRecorderSampleSeries;
  Curve: ^TRecorderImpactPresentationCurve;
  ResultType: TRecorderImpactResultType;
  ResponseIndex: Integer;
  CurveIndex: Integer;

  procedure InitializeResult(AType: TRecorderImpactResultType;
    const AXUnit: string; ACount: Integer);
  begin
    ASnapshot.Results[AType].ResultType := AType;
    ASnapshot.Results[AType].XUnitName := AXUnit;
    SetLength(ASnapshot.Results[AType].Curves, ACount);
  end;

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

  procedure CopyTimeSeries(AType: TRecorderImpactResultType; AIndex: Integer;
    const ASeries: TRecorderSampleSeries);
  var
    I: Integer;
    lTailStart: Integer;
    lBase: Double;
    lTime: Double;
    lValue: Double;
    lDuration: Double;
    lDecaySpan: Double;
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
    lDuration := Max(1E-12, fModel.CaptureSamples / fModel.SampleRateHz);
    lDecaySpan := Max(1E-12, fFilterWindow.ExponentialEndSeconds -
      fFilterWindow.ExponentialStartSeconds);
    for I := 0 to High(ASeries) do
    begin
      lTime := ASeries[I].TimeSeconds - Block.StartSeconds;
      Curve^.X[I] := lTime;
      lValue := ASeries[I].Value;
      if fFilterWindow.Enabled then
      begin
        lValue := lValue - lBase;
        if (lTime < fFilterWindow.StartSeconds) or
          (lTime >= fFilterWindow.EndSeconds) then
          lValue := 0
        else
        begin
          if fModel.WindowKind = iwExponential then
            lValue := lValue * Exp(Ln(Max(1E-12,
              fFilterWindow.ExponentialEndLevel)) *
              lTime / lDuration);
          if (AIndex > 0) and
            (lTime > fFilterWindow.ExponentialStartSeconds) then
            lValue := lValue * Exp(Ln(Max(1E-12,
              fFilterWindow.ExponentialEndLevel)) *
              (lTime - fFilterWindow.ExponentialStartSeconds) /
              lDecaySpan);
        end;
      end;
      Curve^.Y[I] := lValue;
    end;
  end;

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
  if (fCurrentImpact < 0) or (fCurrentImpact >= fRuntime.Impacts.Count) then
  begin
    InitializeResult(irtTime, 's', fModel.ResponseCount + 1);
    InitializeResult(irtSpectrum, 'Hz', fModel.ResponseCount + 1);
    for ResultType := irtFrfMagnitude to irtCoherence do
      InitializeResult(ResultType, 'Hz', fModel.ResponseCount);
    SetCurveIdentity(irtTime, 0, 0, fModel.HammerTagName,
      fModel.ExcitationUnitName, $0000FF, fModel.ExcitationVisible);
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
    fModel.ExcitationUnitName, $0000FF, fModel.ExcitationVisible);
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

procedure TRecorderImpactHammerService.AppendComparison(
  var ASnapshot: TRecorderImpactHammerSnapshot);
var
  ResultType: TRecorderImpactResultType;
  BaseIndex: Integer;
  I: Integer;

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

function TRecorderImpactHammerService.ImpactSequence: QWord;
begin
  Result := 0;
  if (fCurrentImpact >= 0) and
    (fCurrentImpact < fRuntime.Impacts.Count) then
    Result := fRuntime.Impacts.Item(fCurrentImpact).Sequence;
end;

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

procedure TRecorderImpactHammerService.StopMeasurement;
begin
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
    Inc(fRevision);
  finally
    fLock.Leave;
  end;
end;

function TRecorderImpactHammerService.Provider: IRecorderFrfProvider;
begin
  Result := fRuntime.Provider;
end;

function TRecorderImpactHammerService.Revision: QWord;
begin
  fLock.Enter;
  try
    Result := fRevision;
  finally
    fLock.Leave;
  end;
end;

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
    (AWindow.ExponentialStartSeconds < AWindow.StartSeconds) or
    (AWindow.ExponentialStartSeconds >= AWindow.EndSeconds) or
    (AWindow.ExponentialEndSeconds < AWindow.ExponentialStartSeconds) or
    (AWindow.ExponentialEndSeconds > AWindow.EndSeconds) or
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
    Bindings[I].PointNumber := ABasePointNumber +
      Response.PointIncrement + 1;
    if not ACatalog.ResolvePoint(Bindings[I].PointGroup,
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
  end;
  ASink.PublishBindings(fModel.Id, fModel.Target3dComponentId, Bindings);
  Result := True;
end;

procedure TRecorderImpactHammerService.ConfigurePointBindingTarget(
  const ACatalog: IRecorderModelPointCatalog;
  const ASink: IRecorderModelPointBindingSink);
begin
  fPointCatalog := ACatalog;
  fPointBindingSink := ASink;
end;

procedure TRecorderImpactHammerService.SavePointBindings;
var
  ErrorText: string;
  Catalog: IRecorderModelPointCatalog;
  Sink: IRecorderModelPointBindingSink;
begin
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

procedure TRecorderImpactHammerService.BuildSessionSnapshot(
  out ASnapshot: TRecorderImpactSessionSnapshot);
var
  Block: TRecorderImpactCaptureBlock;
  RecordItem: TRecorderImpactRecord;
  Prepared: TRecorderPreparedImpact;
  Source: TRecorderSampleSeries;
  I, J, K: Integer;

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
    SetLength(ASnapshot.Impacts, fRuntime.Impacts.Count);
    for I := 0 to fRuntime.Impacts.Count - 1 do
    begin
      RecordItem := fRuntime.Impacts.Item(I);
      Block := fRuntime.Impacts.Capture(I);
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
      if fCurrentImpact >= 0 then
      begin
        Prepared := FindPrepared(fRuntime.Impacts.Item(
          fCurrentImpact).Sequence);
        if (Prepared <> nil) and (I < Length(Prepared.Responses)) then
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

procedure TRecorderImpactHammerService.FillSnapshot(
  out ASnapshot: TRecorderImpactHammerSnapshot);
var
  Item: TRecorderImpactRecord;
begin
  fLock.Enter;
  try
  ASnapshot := Default(TRecorderImpactHammerSnapshot);
  ASnapshot.FilterWindow := fFilterWindow;
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
  if (ASnapshot.StatusText = '') and not fQualityOk then
    ASnapshot.StatusText := 'Когерентность ниже заданного порога.';
  ASnapshot.ImpactIndex := fCurrentImpact;
  ASnapshot.ImpactCount := fRuntime.Impacts.Count;
  ASnapshot.CanNavigatePrevious := fCurrentImpact > 0;
  ASnapshot.CanNavigateNext := fCurrentImpact + 1 < fRuntime.Impacts.Count;
  ASnapshot.CanHide := fCurrentImpact >= 0;
  ASnapshot.CanDelete := fCurrentImpact >= 0;
  ASnapshot.CanStart := fModel.Enabled and fRecorderRunning and
    not fRecorderFaulted and (fRuntime.State = isStopped);
  ASnapshot.CanArm := ASnapshot.CanStart;
  ASnapshot.CanStop := fModel.Enabled and fRecorderRunning and
    (fRuntime.State in [isArmed, isCapturing, isFaulted]) and
    not fFilterRebuildPending and not fCompletionPending;
  if fCurrentImpact >= 0 then
  begin
    Item := fRuntime.Impacts.Item(fCurrentImpact);
    ASnapshot.ImpactHidden := Item.Hidden;
  end;
  FillPresentation(ASnapshot);
  AppendComparison(ASnapshot);
  finally
    fLock.Leave;
  end;
end;

end.
