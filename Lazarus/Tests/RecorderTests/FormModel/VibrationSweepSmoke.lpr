program VibrationSweepSmoke;
{$mode objfpc}{$H+}
uses SysUtils, Math, uRecorderFormModel, uRecorderTags, uRecorderVibrationEstimate,
  uRecorderSpectrumEngine, uRecorderSpectrumRuntime, uRecorderCoreServices,
  uRecorderProjectFiles;
procedure AssertTrue(ACondition: Boolean; const AStep: string);
begin
  if not ACondition then raise Exception.Create(AStep);
end;

procedure TestVibrationSweepMaximum;
var
  lBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lModel: TRecorderVibrationEstimateComponent;
  lFrame: TRecorderSpectrumFrame;
  lValue, lFrequency: Double;
  lError: string;
  procedure Publish(AAmplitude: Double; ABin: Integer);
  var lData: TRecorderSpectrumFrameEventData;
  begin
    FillChar(lFrame.RectRms[0], Length(lFrame.RectRms) * SizeOf(Double), 0);
    FillChar(lFrame.Rms[0], Length(lFrame.Rms) * SizeOf(Double), 0);
    lFrame.RectRms[ABin] := AAmplitude;
    lFrame.Rms[ABin] := AAmplitude;
    lFrame.MaxIndex := ABin;
    Inc(lFrame.FrameIndex);
    lData := TRecorderSpectrumFrameEventData.Create(lFrame);
    try
      lBus.Publish(TRecorderEventBus.MakeEvent(rceSpectrumFrame, nil,
        lTag.Name, '', lTag.Id, lData));
    finally lData.Free; end;
  end;
begin
  AssertTrue(Ord(rvqDominantFrequency) = 3, 'old quantity ordinal preserved');
  AssertTrue(RecorderIsVibrationUnit('m/s2'), 'acceleration capability');
  AssertTrue(not RecorderIsVibrationUnit('mV'), 'voltage is not vibration');
  lBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lModel := TRecorderVibrationEstimateComponent.Create;
  try
    lTag := lRegistry.CreateTag('sweep');
    lTag.UnitName := 'mV';
    lModel.TagId := lTag.Id;
    lModel.TagName := lTag.Name;
    lModel.HoldMaximum := True;
    lModel.Quantity := rvqAcceleration;
    SetLength(lFrame.Rms, 8);
    SetLength(lFrame.RectRms, 8);
    lFrame.FrequencyStepHz := 10;
    lModel.ConfigureRuntime(lRegistry);
    Publish(50, 1);
    AssertTrue(not lModel.TryGetRuntimeEstimate(lValue, lFrequency), 'no prestart replay');
    lModel.BeginRuntimeSession;
    Publish(2, 2); Publish(5, 3); Publish(3, 4);
    AssertTrue(lModel.TryGetRuntimeEstimate(lValue, lFrequency) and
      (Abs(lValue - 5) < 1e-10) and (Abs(lFrequency - 30) < 1e-10),
      'hidden model holds maximum with corresponding frequency');
    lModel.ConfigureRuntime(lRegistry);
    AssertTrue(lModel.TryGetRuntimeEstimate(lValue, lFrequency), 'same configure preserves maximum');
    lModel.EndRuntimeSession; Publish(10, 5);
    AssertTrue(lModel.TryGetRuntimeEstimate(lValue, lFrequency) and (lValue = 5), 'stop freezes result');
    lModel.BeginRuntimeSession;
    AssertTrue(not lModel.TryGetRuntimeEstimate(lValue, lFrequency), 'restart clears result');
    Publish(1, 1);
    AssertTrue(lModel.TryGetRuntimeEstimate(lValue, lFrequency) and (lValue = 1), 'new sweep starts fresh');
    lModel.Quantity := rvqDominantFrequency; lModel.OutputUnit := 'Hz';
    lModel.ConfigureRuntime(lRegistry); Publish(8, 2); Publish(1, 6);
    AssertTrue(lModel.TryGetRuntimeEstimate(lValue, lFrequency) and
      (lValue = 20) and (lFrequency = 20), 'frequency mode follows maximum amplitude not frequency');
    AssertTrue(not RecorderTryCalculateVibrationEstimate(lFrame, 'mV',
      rvqAmplitude, -1, 'V', lValue, lError), 'raw amplitude forbids unit conversion');
    lModel.BeginRuntimeSession;
    Publish(NaN, 2);
    AssertTrue(not lModel.TryGetRuntimeEstimate(lValue, lFrequency), 'invalid initial score ignored');
    Publish(4, 3);
    AssertTrue(lModel.TryGetRuntimeEstimate(lValue, lFrequency) and
      (lValue = 30), 'finite frame recovers after NaN');
    Publish(2, 2);
    AssertTrue(RecorderTryCalculateVibrationEstimate(lFrame, 'm/s2',
      rvqVelocity, -1, 'mm/s', lValue, lError) and
      (Abs(lValue - 2000 / (2 * Pi * 20)) < 1e-8), 'prepared acceleration integral');
    lModel.OutputUnit := 'kHz';
    lModel.ConfigureRuntime(lRegistry); Publish(4, 3);
    AssertTrue(lModel.TryGetRuntimeEstimate(lValue, lFrequency) and
      (lValue = 30), 'non-vibration stale kHz is normalized to Hz');
  finally
    lModel.Free; lRegistry.Free; lBus.Free;
  end;
  Writeln('RESULT vibration sweep maximum passed');
end;

procedure TestPersistence;
var
  lFactory: TRecorderComponentFactory;
  lManager, lLoaded: TRecorderFormManager;
  lPage: TRecorderFormPage;
  lModel, lRestored: TRecorderVibrationEstimateComponent;
  lFile: string;
begin
  lFile := GetTempFileName(GetTempDir(False), 'vib');
  lFactory := TRecorderComponentFactory.Create;
  lManager := TRecorderFormManager.Create;
  lLoaded := TRecorderFormManager.Create;
  try
    lFactory.RegisterDefaultComponents;
    lPage := TRecorderFormPage.Create('vib', 'vib', 'vib');
    lModel := TRecorderVibrationEstimateComponent.Create;
    lModel.HoldMaximum := True;
    lModel.Quantity := rvqAmplitude;
    lModel.OutputUnit := 'mV';
    lModel.ManualBand := True;
    lModel.BandFromHz := 12.5;
    lModel.BandToHz := 345.5;
    lPage.AddComponent(lModel);
    lManager.AddPage(lPage);
    SaveRecorderGuiConfig(lFile, lManager);
    LoadRecorderGuiConfig(lFile, lLoaded, lFactory);
    lRestored := TRecorderVibrationEstimateComponent(lLoaded.Pages[0].Components[0]);
    AssertTrue(lRestored.HoldMaximum and (lRestored.Quantity = rvqAmplitude) and
      (lRestored.OutputUnit = 'mV'), 'hold and raw amplitude persistence');
    AssertTrue(lRestored.ManualBand and (lRestored.BandFromHz = 12.5) and
      (lRestored.BandToHz = 345.5), 'manual band persistence');
  finally
    lLoaded.Free; lManager.Free; lFactory.Free; DeleteFile(lFile);
  end;
  Writeln('RESULT vibration persistence passed');
end;

procedure TestManualBand;
var
  lBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lModel: TRecorderVibrationEstimateComponent;
  lFrame: TRecorderSpectrumFrame;
  lCalc: TRecorderVibrationCalculation;
  lData: TRecorderSpectrumFrameEventData;
  lValue, lFrequency: Double;
  lError: string;
begin
  SetLength(lFrame.Rms, 8);
  SetLength(lFrame.RectRms, 8);
  lFrame.FrequencyStepHz := 10;
  lFrame.MaxIndex := 6;
  lFrame.Rms[2] := 3; lFrame.Rms[3] := 4; lFrame.Rms[6] := 100;
  lFrame.RectRms[2] := 3; lFrame.RectRms[3] := 4; lFrame.RectRms[6] := 100;
  lCalc := RecorderPrepareVibrationCalculation('V', rvqAmplitude, 'V');
  lCalc.ManualBand := True; lCalc.BandFromHz := 20; lCalc.BandToHz := 30;
  AssertTrue(RecorderCalculatePreparedVibration(lFrame, lCalc, -1, lValue, lError)
    and (lValue = 5), 'manual energy inclusive edges excludes outside peak');
  lCalc.Quantity := rvqDominantFrequency;
  AssertTrue(RecorderCalculatePreparedVibration(lFrame, lCalc, -1, lValue, lError)
    and (lValue = 30), 'manual dominant frequency ignores cached global maximum');
  lFrame.Rms[2] := NaN;
  AssertTrue(RecorderCalculatePreparedVibration(lFrame, lCalc, -1, lValue, lError)
    and (lValue = 30), 'manual frequency skips invalid first bin');
  lFrame.Rms[3] := Infinity;
  AssertTrue(not RecorderCalculatePreparedVibration(lFrame, lCalc, -1, lValue, lError),
    'manual frequency rejects all nonfinite bins');
  lFrame.Rms[2] := 3; lFrame.Rms[3] := 4;
  lCalc.BandFromHz := 80;
  AssertTrue(not RecorderCalculatePreparedVibration(lFrame, lCalc, -1, lValue, lError),
    'reversed range rejected');
  lCalc.BandToHz := 100;
  AssertTrue(not RecorderCalculatePreparedVibration(lFrame, lCalc, -1, lValue, lError),
    'above Nyquist rejected');
  lCalc.BandFromHz := 20; lCalc.BandToHz := 1e100;
  AssertTrue(RecorderCalculatePreparedVibration(lFrame, lCalc, -1, lValue, lError)
    and (lValue = 60), 'huge finite upper boundary clipped before integer conversion');
  lCalc.BandFromHz := NaN;
  AssertTrue(not RecorderCalculatePreparedVibration(lFrame, lCalc, -1, lValue, lError),
    'nonfinite boundary rejected');
  lBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lBus);
  lModel := TRecorderVibrationEstimateComponent.Create;
  try
    lTag := lRegistry.CreateTag('manual'); lTag.UnitName := 'V';
    lModel.TagId := lTag.Id; lModel.TagName := lTag.Name;
    lModel.Quantity := rvqAmplitude; lModel.OutputUnit := 'V';
    lModel.HoldMaximum := True; lModel.ManualBand := True;
    lModel.BandFromHz := 20; lModel.BandToHz := 30;
    lModel.ConfigureRuntime(lRegistry); lModel.BeginRuntimeSession;
    lData := TRecorderSpectrumFrameEventData.Create(lFrame);
    try
      lBus.Publish(TRecorderEventBus.MakeEvent(rceSpectrumFrame, nil,
        lTag.Name, '', lTag.Id, lData));
    finally lData.Free; end;
    AssertTrue(lModel.TryGetRuntimeEstimate(lValue, lFrequency) and
      (lValue = 5) and (lFrequency = 30), 'hidden hold uses same manual range');
    lModel.BandToHz := 40; lModel.ConfigureRuntime(lRegistry);
    AssertTrue(not lModel.TryGetRuntimeEstimate(lValue, lFrequency),
      'edited bounds invalidate held result');
  finally lModel.Free; lRegistry.Free; lBus.Free; end;
  Writeln('RESULT manual vibration band passed');
end;

procedure BenchmarkPrepared;
var
  lFrame: TRecorderSpectrumFrame;
  lCalculation: TRecorderVibrationCalculation;
  lValue: Double;
  lError: string;
  lStart: QWord;
  I: Integer;
begin
  SetLength(lFrame.Rms, 8193);
  SetLength(lFrame.RectRms, 8193);
  lFrame.FrequencyStepHz := 1;
  lFrame.RectRms[100] := 1;
  lCalculation := RecorderPrepareVibrationCalculation('m/s2', rvqVelocity, 'mm/s');
  lStart := GetTickCount64;
  for I := 1 to 1000 do
    AssertTrue(RecorderCalculatePreparedVibration(lFrame, lCalculation, -1,
      lValue, lError), 'prepared benchmark calculation');
  Writeln('BENCH prepared 1000 x 8193 bins: ', GetTickCount64 - lStart, ' ms');
end;


begin
  TestVibrationSweepMaximum;
  TestPersistence;
  TestManualBand;
  BenchmarkPrepared;
end.
