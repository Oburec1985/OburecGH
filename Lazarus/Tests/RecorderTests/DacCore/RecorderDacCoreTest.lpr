program RecorderDacCoreTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils, uRecorderTags, uRecorderBlockClock, uRecorderDacTypes, uRecorderDacContracts,
  uRecorderDacSession, uRecorderDacRunner, uRecorderDacProviders, uRecorderDacTagMirror,
  uRecorderNullDacBackend, uRecorderAudioDacBackend;

procedure Check(ACondition: Boolean; const AText: string);
begin
  if not ACondition then raise Exception.Create(AText);
end;

function DefaultConfig: TRecorderDacConfig;
begin
  Result.SampleRateHz := 1000;
  Result.ChannelCount := 1;
  Result.FramesPerBlock := 10;
  Result.MinimumValue := -1;
  Result.MaximumValue := 1;
  Result.SafeValue := 0;
  Result.UnderrunPolicy := rdupZero;
end;

procedure PublishInputBlock(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag);
var
  I: Integer;
  lTimes, lValues: array of Double;
begin
  SetLength(lTimes, 10);
  SetLength(lValues, 10);
  for I := 0 to 9 do
  begin
    lTimes[I] := I / 1000;
    lValues[I] := I / 10;
  end;
  ARegistry.PublishBlock(ATag.Name, lTimes, lValues, 10, True);
end;

procedure TestGeneratorToDacToTag;
var
  lBackend: IRecorderDacBackend;
  lConfig: TRecorderDacConfig;
  lMirror: IRecorderDacMirror;
  lProvider: IRecorderDacSampleProvider;
  lRegistry: TRecorderTagRegistry;
  lResult: TRecorderDacResult;
  lSession: TRecorderDacSession;
  lSnapshot: TRecorderSignalSnapshot;
  lTag: TRecorderTag;
begin
  lRegistry := TRecorderTagRegistry.Create;
  try
    lTag := lRegistry.CreateTag('DAC mirror', 128, True);
    lProvider := TRecorderDacSineProvider.Create(100, 2);
    lMirror := TRecorderDacTagMirror.Create(lRegistry, lTag);
    lBackend := TRecorderNullDacBackend.Create('memory');
    lSession := TRecorderDacSession.Create(lBackend, lProvider, lMirror);
    try
      lConfig := DefaultConfig;
      Check(lSession.Configure(lConfig, lResult), lResult.Text);
      Check(lSession.Start(lResult), lResult.Text);
      Check(lSession.Pump(lResult), lResult.Text);
      Check(lSession.FlushMirror(lResult), lResult.Text);
      Check(lSession.Counters.SubmittedFrames = 10, 'submitted frame count');
      Check(lSession.Counters.MirroredFrames = 10, 'mirrored frame count');
      lSnapshot := lTag.SignalBuffer.LastBlockSnapshot;
      Check(lSnapshot.Count = 10, 'mirror block count');
      Check(Abs(lSnapshot.Values[3]) <= 1, 'mirror must contain clamped values');
      Check(lSession.Stop(lResult), lResult.Text);
      Check(lSession.Start(lResult), lResult.Text);
      Check(lSession.Stop(lResult), lResult.Text);
      Check(lSession.Disconnect(lResult), lResult.Text);
    finally
      lSession.Free;
    end;
  finally
    lRegistry.Free;
  end;
end;

procedure TestMirrorRingHistory;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lMirror: IRecorderDacMirror;
  lConfig: TRecorderDacConfig;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderSignalSnapshot;
  lBuffer: array[0..9] of Double;
  I: Integer;
  lLastTime: Double;
begin
  lRegistry := TRecorderTagRegistry.Create;
  try
    lTag := lRegistry.CreateTag('DAC small ring', 10, True);
    lMirror := TRecorderDacTagMirror.Create(lRegistry, lTag);
    lConfig := DefaultConfig;
    Check(lMirror.Configure(lConfig, lResult), lResult.Text);
    FillChar(lBuffer, SizeOf(lBuffer), 0);
    for I := 1 to 600 do
      Check(lMirror.WriteBlock(@lBuffer[0], 10, lResult), lResult.Text);
    Check(lTag.BlockTimeDomain = btSessionRelative,
      'legacy mirror must not claim Recorder clock');
    lSnapshot := lTag.SignalBuffer.Snapshot;
    Check(lSnapshot.Count >= 4000, 'DAC mirror lost four-second history');
    Check(lSnapshot.Count <= lTag.SignalBuffer.Capacity, 'DAC ring overflow');
    lLastTime := lSnapshot.Times[lSnapshot.Count - 1];
    lMirror := nil;
    lMirror := TRecorderDacTagMirror.Create(lRegistry, lTag);
    Check(lMirror.Configure(lConfig, lResult), lResult.Text);
    Check(lMirror.WriteBlock(@lBuffer[0], 10, lResult), lResult.Text);
    lSnapshot := lTag.SignalBuffer.Snapshot;
    Check(lSnapshot.Count >= 4000, 'DAC reconfiguration cleared history');
    Check(lSnapshot.Times[lSnapshot.Count - 10] > lLastTime,
      'DAC mirror timeline moved backwards after recreation');
  finally
    lMirror := nil;
    lRegistry.Free;
  end;
end;

procedure TestSubmissionClock;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lSession: TRecorderDacSession;
  lResult: TRecorderDacResult;
  lSnapshot: TRecorderSignalSnapshot;
  lStart, lFirst, lSecond: Double;
  I: Integer;
begin
  lRegistry := TRecorderTagRegistry.Create;
  try
    lTag := lRegistry.CreateTag('Timed output', 128, True);
    lSession := TRecorderDacSession.Create(
      TRecorderNullDacBackend.Create('memory'),
      TRecorderDacSineProvider.Create(100, 0.5),
      TRecorderDacTagMirror.Create(lRegistry, lTag));
    try
      Check(lSession.Configure(DefaultConfig, lResult), lResult.Text);
      lStart := RecorderClockSeconds;
      Check(lSession.Start(lResult), lResult.Text);
      Check(lSession.Pump(lResult), lResult.Text);
      Sleep(40);
      Check(lSession.FlushMirror(lResult), lResult.Text);
      lSnapshot := lTag.SignalBuffer.LastBlockSnapshot;
      lFirst := lSnapshot.Times[0];
      Check(lTag.BlockTimeDomain = btRecorderMonotonic,
        'timed DAC tag must publish Recorder clock domain');
      Check(Abs(lFirst - lStart) < 0.025, 'flush latency retimed submitted block');
      Check(lSession.Pump(lResult), lResult.Text);
      Check(lSession.FlushMirror(lResult), lResult.Text);
      lSnapshot := lTag.SignalBuffer.LastBlockSnapshot;
      lSecond := lSnapshot.Times[0];
      Check(Abs(lSecond - lFirst - 0.01) < 1E-7,
        'continuous blocks must advance on sample clock');
      { Queue holds four blocks; losing the fifth must leave a time gap. }
      for I := 1 to 5 do Check(lSession.Pump(lResult), lResult.Text);
      Check(lSession.Counters.DroppedMirrorBlocks = 1, 'mirror overflow count');
      for I := 1 to 4 do Check(lSession.FlushMirror(lResult), lResult.Text);
      Check(lSession.Pump(lResult), lResult.Text);
      Check(lSession.FlushMirror(lResult), lResult.Text);
      lSnapshot := lTag.SignalBuffer.LastBlockSnapshot;
      Check(Abs(lSnapshot.Times[0] - lFirst - 0.07) < 1E-7,
        'dropped mirror block compressed device timeline');
      Check(lSession.Stop(lResult), lResult.Text);
      Sleep(100);
      Check(lSession.Start(lResult), lResult.Text);
      Check(lSession.Pump(lResult), lResult.Text);
      Check(lSession.FlushMirror(lResult), lResult.Text);
      lSnapshot := lTag.SignalBuffer.LastBlockSnapshot;
      Check(lSnapshot.Times[0] - lFirst > 0.12,
        'stop/start gap disappeared from Recorder timeline');
      Check(lSession.Stop(lResult), lResult.Text);
      Check(lSession.Disconnect(lResult), lResult.Text);
    finally
      lSession.Free;
    end;
  finally
    lRegistry.Free;
  end;
end;

procedure TestTagToDac;
var
  lBackend: IRecorderDacBackend;
  lConfig: TRecorderDacConfig;
  lProvider: IRecorderDacSampleProvider;
  lRegistry: TRecorderTagRegistry;
  lResult: TRecorderDacResult;
  lSession: TRecorderDacSession;
  lTag: TRecorderTag;
begin
  lRegistry := TRecorderTagRegistry.Create;
  try
    lTag := lRegistry.CreateTag('Generated input', 128, True);
    lTag.PollFrequencyHz := 1000;
    lTag.SignalBuffer.ConfigureBlockRing(10, 8);
    lProvider := TRecorderDacTagProvider.Create(lTag);
    lBackend := TRecorderNullDacBackend.Create('memory');
    lSession := TRecorderDacSession.Create(lBackend, lProvider);
    try
      lConfig := DefaultConfig;
      Check(lSession.Configure(lConfig, lResult), lResult.Text);
      Check(lSession.Start(lResult), lResult.Text);
      PublishInputBlock(lRegistry, lTag);
      Check(lSession.Pump(lResult), lResult.Text);
      Check(lSession.Counters.SubmittedFrames = 10, 'tag route frame count');
      Check(lSession.Stop(lResult), lResult.Text);
      Check(lSession.Disconnect(lResult), lResult.Text);
    finally
      lSession.Free;
    end;
  finally
    lRegistry.Free;
  end;
end;

procedure TestRejectedContracts;
var
  lConfig: TRecorderDacConfig;
  lMirror: IRecorderDacMirror;
  lProvider: IRecorderDacSampleProvider;
  lRegistry: TRecorderTagRegistry;
  lResult: TRecorderDacResult;
  lTag: TRecorderTag;
begin
  lRegistry := TRecorderTagRegistry.Create;
  try
    lTag := lRegistry.CreateTag('Loop tag', 128, True);
    lTag.PollFrequencyHz := 500;
    lTag.SignalBuffer.ConfigureBlockRing(10, 8);
    lConfig := DefaultConfig;
    lProvider := TRecorderDacTagProvider.Create(lTag);
    Check(not lProvider.Configure(lConfig, lResult), 'frequency mismatch accepted');
    Check(lResult.Error = rdeUnsupported, 'frequency mismatch error code');
    lMirror := TRecorderDacTagMirror.Create(lRegistry, lTag, lTag.Name);
    Check(not lMirror.Configure(lConfig, lResult), 'feedback loop accepted');
    Check(lResult.Error = rdeFeedbackLoop, 'feedback loop error code');
  finally
    lRegistry.Free;
  end;
end;

procedure TestPulseSeries;
var
  lProvider: IRecorderDacSampleProvider;
  lConfig: TRecorderDacConfig;
  lResult: TRecorderDacResult;
  lBuffer: array[0..6] of Double;
  lFrames, I, lTotal: Integer;
begin
  lConfig := DefaultConfig;
  { 100 Hz x 2 periods = 20 ms active; 50 ms interval, 3 pulses. }
  lProvider := TRecorderDacPulseProvider.Create(100, 0.5, 0.05, 2, 3);
  Check(lProvider.Configure(lConfig, lResult), lResult.Text);
  lTotal := 0;
  while lProvider.FillBlock(@lBuffer[0], Length(lBuffer), lFrames, lResult) do
    for I := 0 to lFrames - 1 do
    begin
      if (lTotal mod 50) >= 20 then
        Check(lBuffer[I] = 0, 'pulse pause is not silent');
      Check(Abs(lBuffer[I]) <= 0.5, 'pulse amplitude');
      Inc(lTotal);
    end;
  Check(lTotal = 150, 'pulse series frame count');
  Check(lResult.Error = rdeCompleted, 'pulse completion');
  lProvider.Reset;
  Check(lProvider.FillBlock(@lBuffer[0], 7, lFrames, lResult), 'pulse replay');
  Check(lBuffer[0] = 0, 'pulse replay initial phase');
  lProvider := TRecorderDacPulseProvider.Create(100, 0.5, 0.01, 2, 3);
  Check(not lProvider.Configure(lConfig, lResult), 'pulse interval overlaps T1');
  Check(lResult.Error = rdeInvalidConfig, 'pulse invalid result');
end;

procedure TestAudioRestart;
var
  I: Integer;
  lBackend: IRecorderDacBackend;
  lProvider: IRecorderDacSampleProvider;
  lConfig: TRecorderDacConfig;
  lSession: TRecorderDacSession;
  lRunner: TRecorderDacRunner;
  lResult: TRecorderDacResult;
  lDeadline: QWord;
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lMirror: IRecorderDacMirror;
begin
  lConfig := DefaultConfig;
  { Deliberately stale project rate: the hardware must override it for both
    generator and mirror, rather than keeping the tag at this old rate. }
  lConfig.SampleRateHz := 8000;
  lConfig.FramesPerBlock := 2048;
  for I := 0 to 19 do
  begin
    lBackend := TRecorderAudioDacBackend.Create('default');
    { Exercise 400 -> 50 Hz restarts silently on the real driver. }
    if Odd(I) then lProvider := TRecorderDacSineProvider.Create(50, 0)
    else lProvider := TRecorderDacSineProvider.Create(400, 0);
    lRegistry := TRecorderTagRegistry.Create;
    lTag := lRegistry.CreateTag('DAC hardware clock mirror', 2048, True);
    lMirror := TRecorderDacTagMirror.Create(lRegistry, lTag);
    lSession := TRecorderDacSession.Create(lBackend, lProvider, lMirror);
    lRunner := TRecorderDacRunner.Create(lSession, lConfig);
    try
      lRunner.StartRun;
      Sleep(150);
      lRunner.RequestStop;
      lDeadline := GetTickCount64 + 5000;
      while not lRunner.Finished and (GetTickCount64 < lDeadline) do Sleep(10);
      Check(lRunner.Finished, 'audio worker stop timeout');
      lRunner.WaitFor;
      lResult := lRunner.LastResult;
      Check(lResult.Error = rdeNone, lResult.Text);
      Check(lTag.PollFrequencyHz = lBackend.SampleRateHz,
        'mirror rate differs from hardware rate');
      Check(lSession.Disconnect(lResult), lResult.Text);
    finally
      lRunner.Free;
      lSession.Free;
      lBackend := nil;
      lProvider := nil;
      lMirror := nil;
      lRegistry.Free;
    end;
  end;
  Writeln('RESULT AudioRestart 20 cycles passed');
end;

procedure TestConstantLevel;
var
  lProvider: IRecorderDacSampleProvider;
  lConfig: TRecorderDacConfig;
  lResult: TRecorderDacResult;
  lBuffer: array[0..9] of Double;
  lCount, I, lTrial, lBlock: Integer;
  lLevel: Double;
begin
  lConfig := DefaultConfig;
  for lTrial := 0 to 1 do
  begin
    if lTrial = 0 then lLevel := 0.25 else lLevel := -0.375;
    lProvider := TRecorderDacConstantProvider.Create(lLevel);
    Check(lProvider.Configure(lConfig, lResult), lResult.Text);
    for lBlock := 0 to 3 do
    begin
      if lBlock = 2 then lProvider.Reset;
      Check(lProvider.FillBlock(@lBuffer[0], Length(lBuffer), lCount, lResult), lResult.Text);
      Check(lCount = Length(lBuffer), 'Constant provider must keep continuous full blocks');
      for I := 0 to lCount - 1 do
        Check(lBuffer[I] = lLevel, 'Constant samples must equal signed level across reset');
    end;
  end;
  lProvider := TRecorderDacConstantProvider.Create(2);
  Check(not lProvider.Configure(lConfig, lResult), 'Out-of-range DC level rejected');
  lProvider := TRecorderDacConstantProvider.Create(0.1);
  lConfig.ChannelCount := 2;
  Check(not lProvider.Configure(lConfig, lResult), 'Multichannel DC level rejected');
  Writeln('RESULT ConstantLevel positive/negative continuous/reset and range validation passed');
end;

begin
  try
    if FindCmdLineSwitch('audio-restart') then TestAudioRestart;
    TestConstantLevel;
    TestGeneratorToDacToTag;
    TestPulseSeries;
    TestTagToDac;
    TestMirrorRingHistory;
    TestSubmissionClock;
    TestRejectedContracts;
    Writeln('RESULT RecorderDacCoreTest passed');
  except
    on E: Exception do
    begin
      Writeln('RESULT RecorderDacCoreTest failed: ', E.Message);
      Halt(1);
    end;
  end;
end.
