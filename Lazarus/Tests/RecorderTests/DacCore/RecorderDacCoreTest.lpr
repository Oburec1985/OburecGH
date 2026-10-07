program RecorderDacCoreTest;

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils, uRecorderTags, uRecorderDacTypes, uRecorderDacContracts,
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

begin
  try
    TestGeneratorToDacToTag;
    TestTagToDac;
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
