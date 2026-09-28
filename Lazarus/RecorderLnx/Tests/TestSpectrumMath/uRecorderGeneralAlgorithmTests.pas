unit uRecorderGeneralAlgorithmTests;

{$mode objfpc}{$H+}

interface

procedure RunRecorderGeneralAlgorithmTests;

implementation

uses
  SysUtils, Math, uRecorderTags, uRecorderCoreServices,
  uRecorderAlgorithmManager, uRecorderTachoPhaseAlgorithms,
  uRecorderScalarAlgorithms;

procedure AssertNear(const AName: string; AExpected, AActual,
  ATolerance: Double);
begin
  if Abs(AExpected - AActual) > ATolerance then
    raise Exception.CreateFmt('%s expected %.12g, got %.12g',
      [AName, AExpected, AActual]);
end;

procedure PrepareAlgorithm(AAlgorithm: TRecorderAlgorithm;
  ARegistry: TRecorderTagRegistry);
begin
  AAlgorithm.PrepareConfiguration;
  if not AAlgorithm.Ready then
    raise Exception.Create(AAlgorithm.NotReadyReason);
  AAlgorithm.LinkTags(ARegistry);
  if not AAlgorithm.Ready then
    raise Exception.Create(AAlgorithm.NotReadyReason);
  AAlgorithm.DoStart;
end;

procedure TestTachoThreshold;
const
  CSampleRateHz = 100.0;
  CFrequencyHz = 10.0;
var
  lEventBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lInput, lOutput: TRecorderTag;
  lAlgorithm: TRecorderTachoAlgorithm;
  lTimes: array[0..39] of Double;
  lValues: array[0..39] of Double;
  I: Integer;
begin
  lEventBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lEventBus);
  lAlgorithm := TRecorderTachoAlgorithm.Create;
  try
    lInput := lRegistry.CreateTag('TachoPulse', Length(lValues));
    lAlgorithm.Properties :=
      'Mode=Threshold;OutputTag=TachoThreshold;PeriodSec=0.1;' +
      'LowPercent=30;HighPercent=70;MinimumAmplitude=0.1';
    lAlgorithm.AddBinding(lInput);
    PrepareAlgorithm(lAlgorithm, lRegistry);
    for I := 0 to High(lValues) do
    begin
      lTimes[I] := I / CSampleRateHz;
      if (I mod 10) < 5 then
        lValues[I] := 1.0
      else
        lValues[I] := -1.0;
    end;
    lAlgorithm.DoEvalBlock(lInput, lTimes, lValues, Length(lValues));
    lOutput := lRegistry.FindByName('TachoThreshold');
    if (lOutput = nil) or (lOutput.SignalBuffer.Count = 0) then
      raise Exception.Create('Threshold tacho did not publish a result');
    AssertNear('Threshold tacho frequency', CFrequencyHz,
      lOutput.SignalBuffer.LatestValue, 1e-5);
  finally
    lAlgorithm.Free;
    lRegistry.Free;
    lEventBus.Free;
  end;
end;

procedure TestTachoSpectrum;
const
  CSampleRateHz = 64.0;
  CFrequencyHz = 8.0;
var
  lEventBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lInput, lOutput: TRecorderTag;
  lAlgorithm: TRecorderTachoAlgorithm;
  lTimes: array[0..63] of Double;
  lValues: array[0..63] of Double;
  I: Integer;
begin
  lEventBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lEventBus);
  lAlgorithm := TRecorderTachoAlgorithm.Create;
  try
    lInput := lRegistry.CreateTag('TachoWave', Length(lValues));
    lAlgorithm.Properties :=
      'Mode=Spectrum;OutputTag=TachoSpectrum;FFTSize=64;SampleRateHz=64;' +
      'MinimumFrequencyHz=2;MaximumFrequencyHz=20;MinimumAmplitude=0.01';
    lAlgorithm.AddBinding(lInput);
    PrepareAlgorithm(lAlgorithm, lRegistry);
    for I := 0 to High(lValues) do
    begin
      lTimes[I] := I / CSampleRateHz;
      lValues[I] := Sin(2.0 * Pi * CFrequencyHz * lTimes[I]);
    end;
    lAlgorithm.DoEvalBlock(lInput, lTimes, lValues, Length(lValues));
    lOutput := lRegistry.FindByName('TachoSpectrum');
    if (lOutput = nil) or (lOutput.SignalBuffer.Count = 0) then
      raise Exception.Create('Spectrum tacho did not publish a result');
    AssertNear('Spectrum tacho frequency', CFrequencyHz,
      lOutput.SignalBuffer.LatestValue, 1e-9);
  finally
    lAlgorithm.Free;
    lRegistry.Free;
    lEventBus.Free;
  end;
end;

procedure TestPhase;
const
  CSampleRateHz = 64.0;
  CFrequencyHz = 8.0;
  CPhaseDegrees = 90.0;
var
  lEventBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lSignal, lReference, lOutput: TRecorderTag;
  lAlgorithm: TRecorderPhaseAlgorithm;
  lTimes: array[0..63] of Double;
  lSignalValues: array[0..63] of Double;
  lReferenceValues: array[0..63] of Double;
  I: Integer;
begin
  lEventBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lEventBus);
  lAlgorithm := TRecorderPhaseAlgorithm.Create;
  try
    lSignal := lRegistry.CreateTag('PhaseSignal', Length(lSignalValues));
    lReference := lRegistry.CreateTag('PhaseReference', Length(lReferenceValues));
    lAlgorithm.Properties :=
      'OutputTag=PhaseResult;FFTSize=64;SampleRateHz=64;' +
      'MinimumFrequencyHz=2;MaximumFrequencyHz=20;MinimumAmplitude=0.01;' +
      'Harmonic=1';
    lAlgorithm.AddBinding(lSignal);
    lAlgorithm.AddBinding(lReference);
    PrepareAlgorithm(lAlgorithm, lRegistry);
    for I := 0 to High(lTimes) do
    begin
      lTimes[I] := I / CSampleRateHz;
      lReferenceValues[I] := Sin(2.0 * Pi * CFrequencyHz * lTimes[I]);
      lSignalValues[I] := Sin(2.0 * Pi * CFrequencyHz * lTimes[I] +
        CPhaseDegrees * Pi / 180.0);
    end;
    lAlgorithm.DoEvalBlock(lSignal, lTimes, lSignalValues,
      Length(lSignalValues));
    lAlgorithm.DoEvalBlock(lReference, lTimes, lReferenceValues,
      Length(lReferenceValues));
    lOutput := lRegistry.FindByName('PhaseResult');
    if (lOutput = nil) or (lOutput.SignalBuffer.Count = 0) then
      raise Exception.Create('Phase algorithm did not publish a result');
    AssertNear('Phase difference', CPhaseDegrees,
      lOutput.SignalBuffer.LatestValue, 0.1);
  finally
    lAlgorithm.Free;
    lRegistry.Free;
    lEventBus.Free;
  end;
end;

procedure TestCounter;
var
  lEventBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lInput, lOutput: TRecorderTag;
  lAlgorithm: TRecorderCounterAlgorithm;
  lTimes: array[0..8] of Double;
  lValues: array[0..8] of Double;
  I: Integer;
begin
  lEventBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lEventBus);
  lAlgorithm := TRecorderCounterAlgorithm.Create;
  try
    lInput := lRegistry.CreateTag('CounterPulse', Length(lValues));
    lAlgorithm.Properties :=
      'OutChannel=CounterResult;Relative=0;Lo=0.25;Hi=0.75;' +
      'MinThreshold=0;SaveVal=0';
    lAlgorithm.AddBinding(lInput);
    PrepareAlgorithm(lAlgorithm, lRegistry);
    lValues[0] := 0.0;
    lValues[1] := 0.5;
    lValues[2] := 1.0;
    lValues[3] := 0.5;
    lValues[4] := 0.0;
    lValues[5] := 0.5;
    lValues[6] := 1.0;
    lValues[7] := 0.5;
    lValues[8] := 0.0;
    for I := 0 to High(lTimes) do
      lTimes[I] := I * 0.01;
    lAlgorithm.DoEvalBlock(lInput, lTimes, lValues, Length(lValues));
    lOutput := lRegistry.FindByName('CounterResult');
    if (lOutput = nil) or (lOutput.SignalBuffer.Count = 0) then
      raise Exception.Create('Counter did not publish a result');
    AssertNear('Counter pulses', 2.0, lOutput.SignalBuffer.LatestValue, 1e-9);
  finally
    lAlgorithm.Free;
    lRegistry.Free;
    lEventBus.Free;
  end;
end;

procedure TestArithmeticOperation(const AOperation: string;
  AExpected: Double);
var
  lEventBus: TRecorderEventBus;
  lRegistry: TRecorderTagRegistry;
  lInputA, lInputB, lOutput: TRecorderTag;
  lAlgorithm: TRecorderArithmeticAlgorithm;
begin
  lEventBus := TRecorderEventBus.Create;
  lRegistry := TRecorderTagRegistry.Create(lEventBus);
  lAlgorithm := TRecorderArithmeticAlgorithm.Create;
  try
    lInputA := lRegistry.CreateTag('ArithmeticA', 8);
    lInputB := lRegistry.CreateTag('ArithmeticB', 8);
    lAlgorithm.Properties := 'Operation=' + AOperation +
      ';OutChannel=ArithmeticResult';
    lAlgorithm.AddBinding(lInputA);
    lAlgorithm.AddBinding(lInputB);
    PrepareAlgorithm(lAlgorithm, lRegistry);
    lAlgorithm.DoEvalValue(lInputA, 1.0, 12.0);
    lAlgorithm.DoEvalValue(lInputB, 1.0, 3.0);
    lOutput := lRegistry.FindByName('ArithmeticResult');
    if (lOutput = nil) or (lOutput.SignalBuffer.Count = 0) then
      raise Exception.Create('Arithmetic algorithm did not publish a result');
    AssertNear('Arithmetic ' + AOperation, AExpected,
      lOutput.SignalBuffer.LatestValue, 1e-9);
  finally
    lAlgorithm.Free;
    lRegistry.Free;
    lEventBus.Free;
  end;
end;

procedure RunRecorderGeneralAlgorithmTests;
begin
  Writeln('Recorder general algorithm tests...');
  TestTachoThreshold;
  TestTachoSpectrum;
  TestPhase;
  TestCounter;
  TestArithmeticOperation('add', 15.0);
  TestArithmeticOperation('sub', 9.0);
  TestArithmeticOperation('mul', 36.0);
  TestArithmeticOperation('div', 4.0);
  Writeln('Recorder general algorithm tests: PASS');
end;

end.
