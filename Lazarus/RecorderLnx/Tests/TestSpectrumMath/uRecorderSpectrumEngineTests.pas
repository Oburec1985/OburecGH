unit uRecorderSpectrumEngineTests;

{$mode objfpc}{$H+}

interface

procedure RunRecorderSpectrumEngineTests;

implementation

uses
  SysUtils, Math,
  uRecorderSpectrumEngine, uRecorderFrequencyBands, uRecorderTags, uRecorderSpectrumRuntime, uRecorderEventQueue, uRecorderCoreServices;

type
  TFrameCounter = class
  public
    Count: Integer;
    LastBins: Integer;
    LastFrameIndex: Int64;
    LastStartTime: Double;
    LastEndTime: Double;
    procedure HandleFrame(ASender: TObject; const AFrame: TRecorderSpectrumFrame);
  end;

procedure TFrameCounter.HandleFrame(ASender: TObject;
  const AFrame: TRecorderSpectrumFrame);
begin
  Inc(Count);
  LastBins := AFrame.Bins;
  LastFrameIndex := AFrame.FrameIndex;
  LastStartTime := AFrame.StartTimeSec;
  LastEndTime := AFrame.EndTimeSec;
  if Length(AFrame.Rms) <> AFrame.Bins then
    raise Exception.Create('Spectrum frame RMS length mismatch');
  if Length(AFrame.PhaseRad) <> AFrame.Bins then
    raise Exception.Create('Spectrum frame phase length mismatch');
end;

procedure FillTestBlock(var ATimes, AValues: array of Double; ASampleRateHz: Double);
var
  I: Integer;
begin
  for I := 0 to High(AValues) do
  begin
    ATimes[I] := I / ASampleRateHz;
    AValues[I] := Sin(2.0 * Pi * I / 8.0);
  end;
end;

procedure AssertEquals(const AName: string; AExpected, AActual: Int64);
begin
  if AExpected <> AActual then
    raise Exception.CreateFmt('%s expected %d, got %d', [AName, AExpected, AActual]);
end;

procedure TestSpectrumComputeManager;
var
  lManager: TRecorderSpectrumComputeManager;
  lPlan1: TRecorderSpectrumFFTPlan;
  lPlan2: TRecorderSpectrumFFTPlan;
  lPlan3: TRecorderSpectrumFFTPlan;
  lPlanCount: Integer;
begin
  lManager := RecorderSpectrumComputeManager;
  lPlanCount := lManager.PlanCount;
  lPlan1 := lManager.AcquirePlan(256);
  lPlan2 := lManager.AcquirePlan(256);
  if lPlan1 <> lPlan2 then
    raise Exception.Create('Spectrum compute manager did not reuse the FFT plan');
  if Trim(lPlan1.BackendName) = '' then
    raise Exception.Create('Spectrum compute manager did not select a backend');
  lPlan3 := lManager.AcquirePlan(512);
  if lPlan3 = lPlan1 then
    raise Exception.Create('Spectrum compute manager reused a plan for another FFT size');
  if lManager.PlanCount < lPlanCount + 2 then
    raise Exception.Create('Spectrum compute manager did not retain prepared plans');
end;

procedure TestMultipleFramesWithoutOverlap;
var
  lSettings: TRecorderSpectrumSettings;
  lChannel: TRecorderSpectrumChannel;
  lCounter: TFrameCounter;
  lTimes: array[0..15] of Double;
  lValues: array[0..15] of Double;
begin
  lSettings.SetDefaults;
  lSettings.FFTSize := 8;
  lSettings.Overlap := 0;
  lSettings.SampleRateHz := 800.0;
  lSettings.WindowKind := swkRect;
  FillTestBlock(lTimes, lValues, lSettings.SampleRateHz);

  lCounter := TFrameCounter.Create;
  lChannel := TRecorderSpectrumChannel.Create('TestTag', lSettings);
  try
    lChannel.OnFrame := @lCounter.HandleFrame;
    lChannel.FeedSamples(lTimes, lValues, Length(lValues));
    AssertEquals('No-overlap frame count', 2, lCounter.Count);
    AssertEquals('No-overlap last frame index', 1, lCounter.LastFrameIndex);
    AssertEquals('No-overlap pending count', 0, lChannel.PendingCount);
    AssertEquals('No-overlap bins', 4, lCounter.LastBins);
  finally
    lChannel.Free;
    lCounter.Free;
  end;
end;

procedure TestMultipleFramesWithOverlap;
var
  lSettings: TRecorderSpectrumSettings;
  lChannel: TRecorderSpectrumChannel;
  lCounter: TFrameCounter;
  lTimes: array[0..15] of Double;
  lValues: array[0..15] of Double;
begin
  lSettings.SetDefaults;
  lSettings.FFTSize := 8;
  lSettings.Overlap := 4;
  lSettings.SampleRateHz := 800.0;
  lSettings.WindowKind := swkRect;
  FillTestBlock(lTimes, lValues, lSettings.SampleRateHz);

  lCounter := TFrameCounter.Create;
  lChannel := TRecorderSpectrumChannel.Create('TestTag', lSettings);
  try
    lChannel.OnFrame := @lCounter.HandleFrame;
    lChannel.FeedSamples(lTimes, lValues, Length(lValues));
    AssertEquals('Overlap frame count', 3, lCounter.Count);
    AssertEquals('Overlap last frame index', 2, lCounter.LastFrameIndex);
    AssertEquals('Overlap pending count', 4, lChannel.PendingCount);
    AssertEquals('Overlap bins', 4, lCounter.LastBins);
  finally
    lChannel.Free;
    lCounter.Free;
  end;
end;

procedure TestConfigInheritance;
var
  lNode: TRecorderSpectrumConfigNode;
  lBinding: TRecorderSpectrumTagBinding;
  lSettings: TRecorderSpectrumSettings;
  lResolved: TRecorderSpectrumSettings;
begin
  lNode := TRecorderSpectrumConfigNode.Create('fft-main', 'Main FFT');
  try
    lSettings := lNode.Settings;
    lSettings.FFTSize := 16384;
    lSettings.Overlap := 8192;
    lSettings.SampleRateHz := 57600.0;
    lNode.Settings := lSettings;
    lBinding := lNode.AddBinding('1_датчик_X');

    lResolved := lBinding.ResolveSettings(lNode.Settings);
    AssertEquals('Inherited FFT size', 16384, lResolved.FFTSize);
    AssertEquals('Inherited overlap', 8192, lResolved.Overlap);

    lBinding.UseOwnSettings := True;
    lSettings := lBinding.Settings;
    lSettings.FFTSize := 8192;
    lSettings.Overlap := 4096;
    lSettings.SampleRateHz := 57600.0;
    lBinding.Settings := lSettings;
    lResolved := lBinding.ResolveSettings(lNode.Settings);
    AssertEquals('Own FFT size', 8192, lResolved.FFTSize);
    AssertEquals('Own overlap', 4096, lResolved.Overlap);
  finally
    lNode.Free;
  end;
end;

procedure TestFrequencyBands;
var
  lRegistry: TRecorderTagRegistry;
  lBands: TRecorderFrequencyBandList;
  lBand: TRecorderFrequencyBand;
  lF1, lF2: Double;
  lFrame: TRecorderSpectrumFrame;
  lManager: TRecorderSpectrumRuntimeManager;
  lEventBus: TRecorderEventBus;
  lNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
  lTimes: array[0..7] of Double;
  lValues: array[0..7] of Double;
  I: Integer;
begin
  lEventBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lEventBus);
  try
    // Создаем тахоканал
    lRegistry.CreateTag('Tacho1', 10);
    lRegistry.CreateTag('Sensor1', 4096);
    lRegistry.PublishValue('Tacho1', 0.0, 100.0);

    // Добавляем полосы частот
    lBands := lRegistry.FrequencyBands;
    
    lBand := lBands.AddBand('AbsBand');
    lBand.Kind := fbkAbsoluteHz;
    lBand.X1 := 50.0;
    lBand.X2 := 150.0;
    lBand.Evaluate(lRegistry, lF1, lF2);
    if (lF1 <> 50.0) or (lF2 <> 150.0) then
      raise Exception.Create('Absolute frequency band evaluate failed');

    lBand := lBands.AddBand('FormulaBand');
    lBand.Kind := fbkFormula;
    lBand.X1 := 0.9;
    lBand.X2 := 1.1;
    lBand.AddTerm('Tacho1', 1.0);
    lBand.Evaluate(lRegistry, lF1, lF2);
    if not SameValue(lF1, 90.0, 1e-9) or not SameValue(lF2, 110.0, 1e-9) then
      raise Exception.CreateFmt('Formula frequency band evaluate failed. Expected F1=90, F2=110, but got F1=%f, F2=%f', [lF1, lF2]);

    // Настраиваем конфиг спектра в реестре
    lNode := lRegistry.SpectrumConfigs.AddNode('fft-1', 'Test FFT');
    lSettings := lNode.Settings;
    lSettings.FFTSize := 8;
    lSettings.Overlap := 0;
    lSettings.SampleRateHz := 800.0;
    lSettings.WindowKind := swkRect;
    lSettings.KeepPhase := False;
    lNode.Settings := lSettings;
    lNode.AddBinding('Sensor1');

    // Инициализируем менеджер рантайма
    lManager := TRecorderSpectrumRuntimeManager.Create(lEventBus, lRegistry);
    try
      lManager.RebuildChannels;

      // Создаем синусоиду 100 Гц (период 8 точек при Fs=800 Гц)
      for I := 0 to 7 do
      begin
        lTimes[I] := I / 800.0;
        lValues[I] := Sin(2.0 * Pi * 100.0 * lTimes[I]);
      end;

      // Публикуем данные, это спровоцирует расчет спектра и полос в HandleChannelFrame
      lRegistry.PublishBlock('Sensor1', lTimes, lValues, 8);
      
      // Получаем результаты
      for I := 1 to 100 do
      begin
        if lManager.GetLastFrame('Sensor1', lFrame) then
          Break;
        Sleep(5);
      end;
      if not lManager.GetLastFrame('Sensor1', lFrame) then
        raise Exception.Create('GetLastFrame failed in integration test');
        
      if Length(lFrame.Bands) <> 2 then
        raise Exception.Create('Bands count mismatch in spectrum frame');
        
      // Проверяем расчеты для AbsBand (50..150 Гц)
      if lFrame.Bands[0].Rms <= 0.0 then
        raise Exception.Create('AbsBand RMS failed');
      if lFrame.Bands[0].MaxRms <= 0.0 then
        raise Exception.Create('AbsBand MaxRms failed');
      if lFrame.Bands[0].MaxFrequencyHz <> 100.0 then
        raise Exception.Create('AbsBand MaxFrequencyHz failed');

      // Проверяем расчеты для FormulaBand (90..110 Гц)
      if lFrame.Bands[1].Rms <= 0.0 then
        raise Exception.Create('FormulaBand RMS failed');
      if lFrame.Bands[1].MaxRms <= 0.0 then
        raise Exception.Create('FormulaBand MaxRms failed');
      if lFrame.Bands[1].MaxFrequencyHz <> 100.0 then
        raise Exception.Create('FormulaBand MaxFrequencyHz failed');
        
    finally
      lManager.Free;
    end;

  finally
    lRegistry.Free;
    lEventBus.Free;
  end;
end;

procedure RunRecorderSpectrumEngineTests;
begin
  Writeln('Recorder spectrum engine tests...');
  TestSpectrumComputeManager;
  TestMultipleFramesWithoutOverlap;
  TestMultipleFramesWithOverlap;
  TestConfigInheritance;
  TestFrequencyBands;
  Writeln('Recorder spectrum engine tests: PASS');
end;

end.
