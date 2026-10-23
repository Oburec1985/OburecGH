program FrequencyResponseBindingTest;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Classes, SysUtils, IniFiles, uRecorderTags, uRecorderFormModel,
 uRecorderProjectFiles, uRecorderFrequencyResponseModel, uRecorderFrequencyBands,
 uRecorderCoreServices, uRecorderFrequencyResponseView, uRecorderFrequencyResponse;
procedure AssertTrue(AValue:Boolean; const AMessage:string);
begin if not AValue then raise Exception.Create(AMessage) end;
procedure TestFrequencyResponseSmartBindings;
var
  lRegistry: TRecorderTagRegistry;
  lSource, lRms, lTacho, lF1: TRecorderTag;
  lBand: TRecorderFrequencyBand;
  lModel, lCopy, lRestored: TRecorderFrequencyResponseComponent;
  lBinding: TRecorderFrequencyResponseBinding;
  lFactory: TRecorderComponentFactory;
  lForms, lLoaded: TRecorderFormManager;
  lPage: TRecorderFormPage;
  lFileName: string;
  lIni: TIniFile;
begin
  lRegistry := TRecorderTagRegistry.Create;
  lModel := TRecorderFrequencyResponseComponent.Create;
  lCopy := TRecorderFrequencyResponseComponent.Create;
  lFactory := TRecorderComponentFactory.Create;
  lForms := TRecorderFormManager.Create;
  lLoaded := TRecorderFormManager.Create;
  lFileName := GetTempDir(False) + 'RecorderFrequencySmart.gui.ini';
  try
    lSource := lRegistry.CreateTag('sensor', 16);
    lSource.PollFrequencyHz := 100;
    lRms := lRegistry.CreateTag('sensor-band-rms', 16);
    lRms.SourceId := 'spectrum:sensor';
    lRms.Address := 'first/rms';
    lF1 := lRegistry.CreateTag('sensor-band-f1', 16);
    lF1.SourceId := 'spectrum:sensor';
    lF1.Address := 'first/f1';
    lTacho := lRegistry.CreateTag('speed', 16);
    lBand := lRegistry.FrequencyBands.AddBand('first');
    lBand.Kind := fbkFormula;
    lBand.AddTerm('speed', 1);
    lModel.Lines[0].SetSourceTag(lSource);
    lBinding := RecorderResolveFrequencyResponseBinding(lRegistry, lModel.Lines[0]);
    AssertTrue((lBinding.ValueTag = lRms) and (lBinding.FrequencyTag = lTacho) and
      lBinding.FrequencyLocked and (lBinding.Hint <> ''),
      'band RMS must resolve its own locked tacho, not its spectral peak');
    lModel.Lines[0].SetValueTag(lSource);
    lModel.Lines[0].SetFrequencyTag(lTacho);
    lModel.Lines[0].FrequencyMode := frfmMean;
    lBinding := RecorderResolveFrequencyResponseBinding(lRegistry, lModel.Lines[0]);
    AssertTrue((lBinding.FrequencyMode = frfmLast) and
      (lBinding.FrequencyTag = lTacho) and not lBinding.FrequencyLocked,
      'scalar frequency uses the last value');
    lModel.Lines[0].SetFrequencyTag(lSource);
    lBinding := RecorderResolveFrequencyResponseBinding(lRegistry, lModel.Lines[0]);
    AssertTrue((lBinding.FrequencyMode = frfmMean) and
      (lBinding.FrequencyTag = lSource), 'vector frequency mean mode');
    lModel.Lines[0].FrequencyMode := frfmSpectrum;
    lBinding := RecorderResolveFrequencyResponseBinding(lRegistry, lModel.Lines[0]);
    AssertTrue((lBinding.FrequencyTag = lF1) and
      (lBinding.FrequencyMode = frfmSpectrum), 'vector spectrum finds computed f1');
    lRegistry.AlgorithmConfigs.Add('Type=Tacho' + LineEnding +
      'Binding.0.TagId=' + UIntToStr(QWord(lSource.Id)) + LineEnding +
      'Binding.0.TagName=sensor' + LineEnding + 'Properties=OutputTag=speed');
    lModel.Lines[0].FrequencyMode := frfmTacho;
    lBinding := RecorderResolveFrequencyResponseBinding(lRegistry, lModel.Lines[0]);
    AssertTrue((lBinding.FrequencyTag = lTacho) and
      (lBinding.FrequencyMode = frfmTacho), 'vector tacho resolves linked output');
    lModel.Axes[0].Kind := frkPhase;
    lModel.Lines[0].Kind := frkPhase;
    lModel.Axes[0].Logarithmic := True;
    lModel.Axes[0].MinValue := 0.1;
    lModel.LogFrequency := True;
    lModel.MinFrequencyHz := 1;
    lCopy.Free;
    lFactory.RegisterDefaultComponents;
    RegisterRecorderFrequencyResponseFactory(lFactory);
    lCopy := TRecorderFrequencyResponseComponent(lFactory.CreateComponent(
      TRecorderFrequencyResponseComponent.TypeId));
    lCopy.Assign(lModel);
    AssertTrue(lCopy.LogFrequency and (lCopy.Axes[0].Kind = frkPhase) and
      (lCopy.Lines[0].FrequencyMode = frfmTacho), 'smart settings deep copy');
    lPage := TRecorderFormPage.Create('smart', 'smart', 'smart');
    lForms.AddPage(lPage);
    lPage.AddComponent(lCopy);
    lCopy := nil;
    SaveRecorderGuiConfig(lFileName, lForms);
    LoadRecorderGuiConfig(lFileName, lLoaded, lFactory);
    lRestored := TRecorderFrequencyResponseComponent(lLoaded.Pages[0].Components[0]);
    AssertTrue(lRestored.LogFrequency and lRestored.Axes[0].Logarithmic and
      (lRestored.Axes[0].Kind = frkPhase) and
      (lRestored.Lines[0].FrequencyMode = frfmTacho), 'smart settings roundtrip');
    lIni := TIniFile.Create(lFileName);
    try
      lIni.DeleteKey('Page.0.Component.0', 'FrAxis0Kind');
    finally lIni.Free end;
    LoadRecorderGuiConfig(lFileName, lLoaded, lFactory);
    lRestored := TRecorderFrequencyResponseComponent(lLoaded.Pages[0].Components[0]);
    AssertTrue(lRestored.Axes[0].Kind = frkPhase, 'legacy node kind follows its line');
    Writeln('RESULT FrequencyResponse smart binding/roundtrip passed');
  finally
    lCopy.Free; lModel.Free; lRegistry.Free;
    lForms.Free; lLoaded.Free; lFactory.Free;
    DeleteFile(lFileName);
  end;
end;


procedure TestRuntimePairing;
var
  lBus: TRecorderEventBus;
  lTags: TRecorderTagRegistry;
  lModel: TRecorderFrequencyResponseComponent;
  lView: TRecorderFrequencyResponseView;
  lX, lY: TRecorderTag;
  lPoint: TRecorderFrequencyResponsePoint;
  lSettings: TRecorderTagEstimateSettings;
begin
  lBus := TRecorderEventBus.Create;
  lTags := TRecorderTagRegistry.Create(lBus);
  lModel := TRecorderFrequencyResponseComponent.Create;
  lView := TRecorderFrequencyResponseView.Create(nil);
  try
    lX := lTags.CreateTag('frequency', 16);
    lY := lTags.CreateTag('amplitude', 16);
    lModel.Lines[0].SetSourceTag(lY);
    lModel.Lines[0].SetValueTag(lY);
    lModel.Lines[0].SetFrequencyTag(lX);
    lModel.Lines[0].MergeMode := frmmAverage;
    lView.Configure(lModel, lTags);
    lTags.PublishValue(lX, 0, 10);
    AssertTrue(lView.LinePointCount(0) = 0, 'X notification created a point');
    lTags.PublishValue(lY, 0, 100);
    lTags.PublishValue(lX, 1, 20);
    AssertTrue(lView.LinePointCount(0) = 1, 'X paired new frequency with old Y');
    lTags.PublishValue(lY, 1, 200);
    AssertTrue(lView.TryGetLinePoint(0, 1, lPoint) and
      (lPoint.FrequencyHz = 20) and (lPoint.Value = 200) and
      (lPoint.SampleCount = 1), 'average bin contaminated by X-only event');
    lTags.PublishValue(lY, 2, 300);
    AssertTrue(lView.TryGetLinePoint(0, 1, lPoint) and
      (lPoint.Value = 250) and (lPoint.SampleCount = 2), 'average result changed');
    lX.PollFrequencyHz := 100;
    lSettings := lX.EstimateSettings;
    lSettings.PortionLength := 2;
    lSettings.EnabledKinds[tekMean] := True;
    lX.EstimateSettings := lSettings;
    lModel.Lines[0].FrequencyMode := frfmMean;
    lView.Configure(lModel, lTags);
    lTags.PublishBlock(lX, [3.0, 3.01], [30.0, 50.0], 2, True);
    lTags.PublishValue(lY, 3.01, 8);
    AssertTrue(lView.TryGetLinePoint(0, 0, lPoint) and
      (lPoint.FrequencyHz = 40) and (lPoint.Value = 8), 'runtime vector mean');
    lModel.Lines[0].SetFrequencyTag(lY);
    lModel.Lines[0].FrequencyMode := frfmAutomatic;
    lView.Configure(lModel, lTags);
    lTags.PublishValue(lY, 4, 12);
    AssertTrue(lView.TryGetLinePoint(0, 0, lPoint) and
      (lPoint.FrequencyHz = 12) and (lPoint.Value = 12), 'same tag X/Y update');
    Writeln('RESULT FrequencyResponse runtime pairing/mean passed');
  finally
    lView.Free; lModel.Free; lTags.Free; lBus.Free;
  end;
end;

begin
 Application.Initialize; Application.ShowMainForm := False;
 try TestFrequencyResponseSmartBindings; TestRuntimePairing;
 except on E:Exception do begin Writeln('FAILED ',E.Message); Halt(1) end end;
end.
