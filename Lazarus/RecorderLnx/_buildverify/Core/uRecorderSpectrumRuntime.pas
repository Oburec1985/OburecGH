unit uRecorderSpectrumRuntime;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, SyncObjs, uRecorderCoreServices, uRecorderTags, uRecorderSpectrumEngine, uRecorderFrequencyBands;

type
  { TRecorderCachedSpectrumFrame
    Кэш кадра спектра в памяти для предотвращения очистки графиков при переключениях страниц. }
  TRecorderCachedSpectrumFrame = class(TObject)
  public
    SourceTagName: string;
    FrameIndex: Int64;
    StartTimeSec: Double;
    EndTimeSec: Double;
    SampleRateHz: Double;
    FFTSize: Integer;
    Bins: Integer;
    FrequencyStepHz: Double;
    MaxIndex: Integer;
    MaxFrequencyHz: Double;
    MaxRms: Double;
    Rms: array of Double;
    PhaseRad: array of Double;
    Bands: array of TRecorderSpectrumBandResult;
    constructor Create(const AFrame: TRecorderSpectrumFrame);
    procedure AssignFrom(const AFrame: TRecorderSpectrumFrame);
  end;

  { TRecorderSpectrumFrameEventData
    Контейнер события для передачи кадра спектра через EventBus. }
  TRecorderSpectrumFrameEventData = class(TObject)
  private
    fFrame: TRecorderSpectrumFrame;
  public
    constructor Create(const AFrame: TRecorderSpectrumFrame);
    property Frame: TRecorderSpectrumFrame read fFrame;
  end;

  TRecorderSpectrumInputBlock = class(TObject)
  public
    TagName: string;
    Times: TRecorderDoubleArray;
    Values: TRecorderDoubleArray;
    constructor Create(const ATagName: string; const ATimes, AValues: array of Double;
      ACount: Integer);
    procedure AssignSamples(const ATimes, AValues: array of Double; ACount: Integer);
  end;

  { TRecorderSpectrumRuntimeManager
    Менеджер рантайм-вычислений спектров. }
  TRecorderSpectrumRuntimeManager = class(TObject)
  private
    fEventBus: TRecorderEventBus;
    fTagRegistry: TRecorderTagRegistry;
    fToken: Integer;
    fChannels: TList; // Список TRecorderSpectrumChannel
    fCache: TList;    // Список кэшированных кадров (TRecorderCachedSpectrumFrame)
    fLock: TCriticalSection;
    fChannelLock: TCriticalSection;
    fProcessLock: TCriticalSection;
    fInputLock: TCriticalSection;
    fInputQueue: TList;
    fInputEvent: TEvent;
    fWorker: TThread;
    fPrepared: Boolean;
    procedure HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
    procedure HandleChannelFrame(ASender: TObject; const AFrame: TRecorderSpectrumFrame);
    function FindChannel(const ATagName: string): TRecorderSpectrumChannel;
    procedure UpdateCache(const AFrame: TRecorderSpectrumFrame);
    procedure ClearCache;
    procedure ClearInputQueue;
    procedure QueueInput(const ATagName: string; const ATimes, AValues: array of Double;
      ACount: Integer);
    procedure ProcessQueuedInputs;
    procedure HandleTagRegistryBlockPublished(Sender: TObject; const ATagName: string;
      const ATimes, AValues: array of Double; ACount: Integer);
  public
    class var fInstance: TRecorderSpectrumRuntimeManager;
    class function Instance: TRecorderSpectrumRuntimeManager;
    constructor Create(AEventBus: TRecorderEventBus; ATagRegistry: TRecorderTagRegistry);
    destructor Destroy; override;
    procedure PrepareConfiguredPlans;
    procedure PrepareConfiguration;
    procedure RebuildChannels;
    procedure ResetForNextRun;
    procedure ClearChannels;
    function GetLastFrame(const ATagName: string; var AFrame: TRecorderSpectrumFrame): Boolean;
    procedure FeedTagSamples(const ATagName: string; const ATimes, AValues: array of Double;
      ACount: Integer);
    property IsPrepared: Boolean read fPrepared;
  end;

implementation

uses
  uRecorderDebugLog;

type
  TRecorderSpectrumWorker = class(TThread)
  private
    fManager: TRecorderSpectrumRuntimeManager;
  protected
    procedure Execute; override;
  public
    constructor Create(AManager: TRecorderSpectrumRuntimeManager);
  end;

constructor TRecorderSpectrumInputBlock.Create(const ATagName: string;
  const ATimes, AValues: array of Double; ACount: Integer);
begin
  inherited Create;
  TagName := ATagName;
  AssignSamples(ATimes, AValues, ACount);
end;

procedure TRecorderSpectrumInputBlock.AssignSamples(const ATimes,
  AValues: array of Double; ACount: Integer);
begin
  if ACount < 0 then
    ACount := 0;
  SetLength(Times, ACount);
  SetLength(Values, ACount);
  if ACount > 0 then
  begin
    Move(ATimes[0], Times[0], ACount * SizeOf(Double));
    Move(AValues[0], Values[0], ACount * SizeOf(Double));
  end;
end;

constructor TRecorderSpectrumWorker.Create(AManager: TRecorderSpectrumRuntimeManager);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fManager := AManager;
  Start;
end;

procedure TRecorderSpectrumWorker.Execute;
begin
  while not Terminated do
  begin
    try
      fManager.ProcessQueuedInputs;
    except
      on E: Exception do
        { MIC-140 stream debug: spectrum worker errors suppressed.
        RecorderDebugLog('Spectrum worker failed: ' + E.ClassName + ': ' + E.Message); }
    end;
    fManager.fInputEvent.WaitFor(50);
  end;
  try
    fManager.ProcessQueuedInputs;
  except
    on E: Exception do
      { MIC-140 stream debug: spectrum worker shutdown errors suppressed.
      RecorderDebugLog('Spectrum worker shutdown failed: ' + E.ClassName + ': ' + E.Message); }
  end;
end;

{ TRecorderCachedSpectrumFrame }

constructor TRecorderCachedSpectrumFrame.Create(const AFrame: TRecorderSpectrumFrame);
begin
  inherited Create;
  AssignFrom(AFrame);
end;

procedure TRecorderCachedSpectrumFrame.AssignFrom(const AFrame: TRecorderSpectrumFrame);
var
  I: Integer;
begin
  SourceTagName := AFrame.SourceTagName;
  FrameIndex := AFrame.FrameIndex;
  StartTimeSec := AFrame.StartTimeSec;
  EndTimeSec := AFrame.EndTimeSec;
  SampleRateHz := AFrame.SampleRateHz;
  FFTSize := AFrame.FFTSize;
  Bins := AFrame.Bins;
  FrequencyStepHz := AFrame.FrequencyStepHz;
  MaxIndex := AFrame.MaxIndex;
  MaxFrequencyHz := AFrame.MaxFrequencyHz;
  MaxRms := AFrame.MaxRms;
  
  SetLength(Rms, Length(AFrame.Rms));
  if Length(AFrame.Rms) > 0 then
    Move(AFrame.Rms[0], Rms[0], Length(AFrame.Rms) * SizeOf(Double));
    
  SetLength(PhaseRad, Length(AFrame.PhaseRad));
  if Length(AFrame.PhaseRad) > 0 then
    Move(AFrame.PhaseRad[0], PhaseRad[0], Length(AFrame.PhaseRad) * SizeOf(Double));

  SetLength(Bands, Length(AFrame.Bands));
  for I := 0 to Length(AFrame.Bands) - 1 do
  begin
    Bands[I].BandName := AFrame.Bands[I].BandName;
    Bands[I].F1 := AFrame.Bands[I].F1;
    Bands[I].F2 := AFrame.Bands[I].F2;
    Bands[I].Rms := AFrame.Bands[I].Rms;
    Bands[I].MaxRms := AFrame.Bands[I].MaxRms;
    Bands[I].MaxFrequencyHz := AFrame.Bands[I].MaxFrequencyHz;
  end;
end;

{ TRecorderSpectrumFrameEventData }

constructor TRecorderSpectrumFrameEventData.Create(const AFrame: TRecorderSpectrumFrame);
begin
  inherited Create;
  fFrame := AFrame;
end;

{ TRecorderSpectrumRuntimeManager }

class function TRecorderSpectrumRuntimeManager.Instance: TRecorderSpectrumRuntimeManager;
begin
  Result := fInstance;
end;

constructor TRecorderSpectrumRuntimeManager.Create(AEventBus: TRecorderEventBus; ATagRegistry: TRecorderTagRegistry);
begin
  inherited Create;
  fEventBus := AEventBus;
  fTagRegistry := ATagRegistry;
  fChannels := TList.Create;
  fCache := TList.Create;
  fLock := TCriticalSection.Create;
  fChannelLock := TCriticalSection.Create;
  fProcessLock := TCriticalSection.Create;
  fInputLock := TCriticalSection.Create;
  fInputQueue := TList.Create;
  fInputEvent := TEvent.Create(nil, False, False, '');
  fInstance := Self;
  if fEventBus <> nil then
    fToken := fEventBus.Subscribe(@HandleEvent);
  if fTagRegistry <> nil then
    fTagRegistry.SetBlockPublishedHandler(Self, @HandleTagRegistryBlockPublished);
  fWorker := TRecorderSpectrumWorker.Create(Self);
end;

destructor TRecorderSpectrumRuntimeManager.Destroy;
begin
  if fInstance = Self then
    fInstance := nil;
  if fTagRegistry <> nil then
    fTagRegistry.SetBlockPublishedHandler(nil, nil);
  if (fEventBus <> nil) and (fToken <> 0) then
  begin
    fEventBus.Unsubscribe(fToken);
    fToken := 0;
  end;
  if fWorker <> nil then
  begin
    fWorker.Terminate;
    fInputEvent.SetEvent;
    fWorker.WaitFor;
    FreeAndNil(fWorker);
  end;
  ClearChannels;
  ClearInputQueue;
  fInputEvent.Free;
  fInputQueue.Free;
  fInputLock.Free;
  fProcessLock.Free;
  fChannels.Free;
  ClearCache;
  fCache.Free;
  fChannelLock.Free;
  fLock.Free;
  inherited Destroy;
end;

procedure TRecorderSpectrumRuntimeManager.ClearCache;
var
  I: Integer;
begin
  fLock.Enter;
  try
    for I := 0 to fCache.Count - 1 do
      TObject(fCache[I]).Free;
    fCache.Clear;
  finally
    fLock.Leave;
  end;
end;

procedure TRecorderSpectrumRuntimeManager.UpdateCache(const AFrame: TRecorderSpectrumFrame);
var
  I: Integer;
  lCached: TRecorderCachedSpectrumFrame;
  lFound: Boolean;
begin
  fLock.Enter;
  try
    lFound := False;
    for I := 0 to fCache.Count - 1 do
    begin
      lCached := TRecorderCachedSpectrumFrame(fCache[I]);
      if SameText(lCached.SourceTagName, AFrame.SourceTagName) then
      begin
        lCached.AssignFrom(AFrame);
        lFound := True;
        Break;
      end;
    end;
    if not lFound then
      fCache.Add(TRecorderCachedSpectrumFrame.Create(AFrame));
  finally
    fLock.Leave;
  end;
end;

function TRecorderSpectrumRuntimeManager.GetLastFrame(const ATagName: string; var AFrame: TRecorderSpectrumFrame): Boolean;
var
  I, J: Integer;
  lCached: TRecorderCachedSpectrumFrame;
begin
  Result := False;
  fLock.Enter;
  try
    for I := 0 to fCache.Count - 1 do
    begin
      lCached := TRecorderCachedSpectrumFrame(fCache[I]);
      if SameText(lCached.SourceTagName, ATagName) then
      begin
        AFrame.SourceTagName := lCached.SourceTagName;
        AFrame.FrameIndex := lCached.FrameIndex;
        AFrame.StartTimeSec := lCached.StartTimeSec;
        AFrame.EndTimeSec := lCached.EndTimeSec;
        AFrame.SampleRateHz := lCached.SampleRateHz;
        AFrame.FFTSize := lCached.FFTSize;
        AFrame.Bins := lCached.Bins;
        AFrame.FrequencyStepHz := lCached.FrequencyStepHz;
        AFrame.MaxIndex := lCached.MaxIndex;
        AFrame.MaxFrequencyHz := lCached.MaxFrequencyHz;
        AFrame.MaxRms := lCached.MaxRms;
        
        SetLength(AFrame.Rms, Length(lCached.Rms));
        if Length(lCached.Rms) > 0 then
          Move(lCached.Rms[0], AFrame.Rms[0], Length(lCached.Rms) * SizeOf(Double));
          
        SetLength(AFrame.PhaseRad, Length(lCached.PhaseRad));
        if Length(lCached.PhaseRad) > 0 then
          Move(lCached.PhaseRad[0], AFrame.PhaseRad[0], Length(lCached.PhaseRad) * SizeOf(Double));

        SetLength(AFrame.Bands, Length(lCached.Bands));
        for J := 0 to Length(lCached.Bands) - 1 do
        begin
          AFrame.Bands[J].BandName := lCached.Bands[J].BandName;
          AFrame.Bands[J].F1 := lCached.Bands[J].F1;
          AFrame.Bands[J].F2 := lCached.Bands[J].F2;
          AFrame.Bands[J].Rms := lCached.Bands[J].Rms;
          AFrame.Bands[J].MaxRms := lCached.Bands[J].MaxRms;
          AFrame.Bands[J].MaxFrequencyHz := lCached.Bands[J].MaxFrequencyHz;
        end;
          
        Result := True;
        Break;
      end;
    end;
  finally
    fLock.Leave;
  end;
end;

function TRecorderSpectrumRuntimeManager.FindChannel(const ATagName: string): TRecorderSpectrumChannel;
var
  I: Integer;
  lChan: TRecorderSpectrumChannel;
begin
  Result := nil;
  for I := 0 to fChannels.Count - 1 do
  begin
    lChan := TRecorderSpectrumChannel(fChannels[I]);
    if SameText(lChan.SourceTagName, ATagName) then
      Exit(lChan);
  end;
end;

procedure TRecorderSpectrumRuntimeManager.ClearChannels;
var
  I: Integer;
begin
  fPrepared := False;
  ClearInputQueue;
  fProcessLock.Acquire;
  try
    fChannelLock.Acquire;
    try
      for I := 0 to fChannels.Count - 1 do
        TObject(fChannels[I]).Free;
      fChannels.Clear;
    finally
      fChannelLock.Release;
    end;
  finally
    fProcessLock.Release;
  end;
end;

procedure TRecorderSpectrumRuntimeManager.ClearInputQueue;
var
  I: Integer;
begin
  fInputLock.Acquire;
  try
    for I := 0 to fInputQueue.Count - 1 do
      TObject(fInputQueue[I]).Free;
    fInputQueue.Clear;
  finally
    fInputLock.Release;
  end;
end;

procedure TRecorderSpectrumRuntimeManager.QueueInput(const ATagName: string;
  const ATimes, AValues: array of Double; ACount: Integer);
var
  lInput: TRecorderSpectrumInputBlock;
  I: Integer;
begin
  if ACount <= 0 then
    Exit;
  fInputLock.Acquire;
  try
    for I := 0 to fInputQueue.Count - 1 do
    begin
      lInput := TRecorderSpectrumInputBlock(fInputQueue[I]);
      if SameText(lInput.TagName, ATagName) then
      begin
        // Spectrum is derived real-time output. Coalescing preserves the
        // newest input without allowing a slow FFT to backlog MIC-140 blocks.
        lInput.AssignSamples(ATimes, AValues, ACount);
        fInputEvent.SetEvent;
        Exit;
      end;
    end;
    lInput := TRecorderSpectrumInputBlock.Create(ATagName, ATimes, AValues, ACount);
    fInputQueue.Add(lInput);
  finally
    fInputLock.Release;
  end;
  fInputEvent.SetEvent;
end;

procedure TRecorderSpectrumRuntimeManager.ProcessQueuedInputs;
var
  lInput: TRecorderSpectrumInputBlock;
  lChannel: TRecorderSpectrumChannel;
begin
  repeat
    lInput := nil;
    fInputLock.Acquire;
    try
      if fInputQueue.Count > 0 then
      begin
        lInput := TRecorderSpectrumInputBlock(fInputQueue[0]);
        fInputQueue.Delete(0);
      end;
    finally
      fInputLock.Release;
    end;
    if lInput = nil then
      Exit;

    try
      fProcessLock.Acquire;
      try
        fChannelLock.Acquire;
        try
          lChannel := FindChannel(lInput.TagName);
        finally
          fChannelLock.Release;
        end;
        if lChannel <> nil then
          lChannel.FeedSamples(lInput.Times, lInput.Values, Length(lInput.Values));
      finally
        fProcessLock.Release;
      end;
    finally
      lInput.Free;
    end;
  until False;
end;

procedure TRecorderSpectrumRuntimeManager.PrepareConfiguredPlans;
var
  I, J: Integer;
  lNode: TRecorderSpectrumConfigNode;
  lBinding: TRecorderSpectrumTagBinding;
  lSettings: TRecorderSpectrumSettings;
begin
  if (fTagRegistry = nil) or (fTagRegistry.SpectrumConfigs = nil) then
    Exit;

  // This is called while Recorder is stopped, after project loading or a
  // spectrum configuration change. It allocates plans and benchmarks SIMD
  // implementations before the acquisition thread can publish its first tag.
  for I := 0 to fTagRegistry.SpectrumConfigs.NodeCount - 1 do
  begin
    lNode := fTagRegistry.SpectrumConfigs.Nodes[I];
    for J := 0 to lNode.BindingCount - 1 do
    begin
      lBinding := lNode.Bindings[J];
      lSettings := lBinding.ResolveSettings(lNode.Settings);
      try
        lSettings.Validate;
        RecorderSpectrumComputeManager.AcquirePlan(lSettings.FFTSize);
      except
        on E: Exception do
          ; // The runtime will skip the same invalid binding when started.
      end;
    end;
  end;
end;

procedure TRecorderSpectrumRuntimeManager.PrepareConfiguration;
begin
  { This method is intentionally called only while Recorder is stopped.
    It owns all expensive spectrum setup: FFT plan selection/benchmarking,
    evaluator creation and channel input buffers. Starting View/Record must
    only activate already prepared objects. }
  fPrepared := False;
  PrepareConfiguredPlans;
  RebuildChannels;
  fPrepared := True;
end;

procedure TRecorderSpectrumRuntimeManager.RebuildChannels;
var
  I, J: Integer;
  lNode: TRecorderSpectrumConfigNode;
  lBinding: TRecorderSpectrumTagBinding;
  lSettings: TRecorderSpectrumSettings;
  lChannel: TRecorderSpectrumChannel;
  lTagName: string;
begin
  ClearChannels;
  if (fTagRegistry = nil) or (fTagRegistry.SpectrumConfigs = nil) then
    Exit;

  for I := 0 to fTagRegistry.SpectrumConfigs.NodeCount - 1 do
  begin
    lNode := fTagRegistry.SpectrumConfigs.Nodes[I];
    for J := 0 to lNode.BindingCount - 1 do
    begin
      lBinding := lNode.Bindings[J];
      lTagName := lBinding.SourceTagName;
      lSettings := lBinding.ResolveSettings(lNode.Settings);

      // Валидируем настройки
      try
        lSettings.Validate;
      except
        on E: Exception do
          Continue; // Пропускаем невалидные привязки
      end;

      lChannel := TRecorderSpectrumChannel.Create(lTagName, lSettings);
      lChannel.OnFrame := @HandleChannelFrame;
      fChannels.Add(lChannel);
    end;
  end;
end;

procedure TRecorderSpectrumRuntimeManager.ResetForNextRun;
var
  I: Integer;
begin
  { Keep configured channels and their allocations alive between runs. }
  ClearInputQueue;
  fProcessLock.Acquire;
  try
    fChannelLock.Acquire;
    try
      for I := 0 to fChannels.Count - 1 do
        TRecorderSpectrumChannel(fChannels[I]).Clear;
    finally
      fChannelLock.Release;
    end;
  finally
    fProcessLock.Release;
  end;
  ClearCache;
end;

procedure TRecorderSpectrumRuntimeManager.FeedTagSamples(const ATagName: string;
  const ATimes, AValues: array of Double; ACount: Integer);
var
  lHasChannel: Boolean;
begin
  if ACount <= 0 then
    Exit;
  fChannelLock.Acquire;
  try
    lHasChannel := FindChannel(ATagName) <> nil;
  finally
    fChannelLock.Release;
  end;
  if not lHasChannel then
    Exit;
  QueueInput(ATagName, ATimes, AValues, ACount);
end;

procedure TRecorderSpectrumRuntimeManager.HandleTagRegistryBlockPublished(
  Sender: TObject; const ATagName: string; const ATimes, AValues: array of Double;
  ACount: Integer);
begin
  FeedTagSamples(ATagName, ATimes, AValues, ACount);
end;

procedure TRecorderSpectrumRuntimeManager.HandleEvent(ASender: TObject; const AEvent: TRecorderEvent);
var
  lTagData: TRecorderTagUpdateEventData;
  lHasChannel: Boolean;
begin
  if (AEvent.Kind <> rceDataUpdated) or (not (AEvent.Data is TRecorderTagUpdateEventData)) then
    Exit;

  lTagData := TRecorderTagUpdateEventData(AEvent.Data);
  if lTagData.SampleCount > 1 then
  begin
    fChannelLock.Acquire;
    try
      lHasChannel := FindChannel(lTagData.Tag.Name) <> nil;
    finally
      fChannelLock.Release;
    end;
    if not lHasChannel then
      Exit;
    QueueInput(lTagData.Tag.Name, lTagData.Times, lTagData.Values,
      lTagData.SampleCount);
    Exit;
  end;

  fChannelLock.Acquire;
  try
    lHasChannel := FindChannel(lTagData.Tag.Name) <> nil;
  finally
    fChannelLock.Release;
  end;
  if not lHasChannel then
    Exit;

  if lTagData.BlockTailNotify then
    Exit;

  // Scalar updates from PublishValue.
  QueueInput(lTagData.Tag.Name, [lTagData.TimeSec], [lTagData.Value], 1);
end;

procedure TRecorderSpectrumRuntimeManager.HandleChannelFrame(ASender: TObject; const AFrame: TRecorderSpectrumFrame);
var
  lEventData: TRecorderSpectrumFrameEventData;
  lEvent: TRecorderEvent;
  lFrame: TRecorderSpectrumFrame;
  I, K: Integer;
  lBand: TRecorderFrequencyBand;
  lF1, lF2: Double;
  lIdx1, lIdx2: Integer;
  lSumSq, lMaxVal, lMaxHz: Double;
begin
  lFrame := AFrame;
  
  if (fTagRegistry <> nil) and (fTagRegistry.FrequencyBands <> nil) and (fTagRegistry.FrequencyBands.BandCount > 0) then
  begin
    SetLength(lFrame.Bands, fTagRegistry.FrequencyBands.BandCount);
    for I := 0 to fTagRegistry.FrequencyBands.BandCount - 1 do
    begin
      lBand := fTagRegistry.FrequencyBands.Bands[I];
      lBand.Evaluate(fTagRegistry, lF1, lF2);
      
      lFrame.Bands[I].BandName := lBand.Name;
      lFrame.Bands[I].F1 := lF1;
      lFrame.Bands[I].F2 := lF2;
      
      if lFrame.FrequencyStepHz > 0 then
      begin
        lIdx1 := Round(lF1 / lFrame.FrequencyStepHz);
        lIdx2 := Round(lF2 / lFrame.FrequencyStepHz);
      end
      else
      begin
        lIdx1 := 0;
        lIdx2 := 0;
      end;
      
      if lIdx1 < 0 then lIdx1 := 0;
      if lIdx1 >= lFrame.Bins then lIdx1 := lFrame.Bins - 1;
      if lIdx2 < 0 then lIdx2 := 0;
      if lIdx2 >= lFrame.Bins then lIdx2 := lFrame.Bins - 1;
      
      if lIdx1 > lIdx2 then
      begin
        K := lIdx1;
        lIdx1 := lIdx2;
        lIdx2 := K;
      end;
      
      lSumSq := 0.0;
      lMaxVal := -1.0;
      lMaxHz := 0.0;
      
      if (lIdx1 < lFrame.Bins) and (lIdx2 < lFrame.Bins) then
      begin
        for K := lIdx1 to lIdx2 do
        begin
          lSumSq := lSumSq + Sqr(lFrame.Rms[K]);
          if lFrame.Rms[K] > lMaxVal then
          begin
            lMaxVal := lFrame.Rms[K];
            lMaxHz := K * lFrame.FrequencyStepHz;
          end;
        end;
      end;
      
      if lMaxVal < 0.0 then lMaxVal := 0.0;
      
      lFrame.Bands[I].Rms := Sqrt(lSumSq);
      lFrame.Bands[I].MaxRms := lMaxVal;
      lFrame.Bands[I].MaxFrequencyHz := lMaxHz;
    end;
  end
  else
    SetLength(lFrame.Bands, 0);

  UpdateCache(lFrame);
  if fEventBus = nil then Exit;
  lEventData := TRecorderSpectrumFrameEventData.Create(lFrame);
  try
    lEvent := TRecorderEventBus.MakeEvent(rceSpectrumFrame, Self, lFrame.SourceTagName, '', 0, lEventData);
    fEventBus.Publish(lEvent);
  finally
    lEventData.Free;
  end;
end;

end.
