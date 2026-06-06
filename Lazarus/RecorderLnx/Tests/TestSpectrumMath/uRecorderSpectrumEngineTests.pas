unit uRecorderSpectrumEngineTests;

{$mode objfpc}{$H+}

interface

procedure RunRecorderSpectrumEngineTests;

implementation

uses
  SysUtils, Math,
  uRecorderSpectrumEngine;

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

procedure RunRecorderSpectrumEngineTests;
begin
  Writeln('Recorder spectrum engine tests...');
  TestMultipleFramesWithoutOverlap;
  TestMultipleFramesWithOverlap;
  TestConfigInheritance;
  Writeln('Recorder spectrum engine tests: PASS');
end;

end.
