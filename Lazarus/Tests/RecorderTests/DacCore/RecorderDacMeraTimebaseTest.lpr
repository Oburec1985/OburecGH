program RecorderDacMeraTimebaseTest;

{ Integration regression for the calibrated mirror -> shared recording origin
  -> MERA Start/portion metadata path. Hardware detection is tested separately. }

{$mode objfpc}{$H+}
{$codepage UTF8}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Classes, SysUtils, Math, uRecorderTags, uRecorderBlockClock, uRecorderDacTypes,
  uRecorderDacContracts, uRecorderDacTagMirror, uRecorderRecordTimebase,
  uRecorderDataStorage, uMeraFile;

const
  CFeedbackOrigin = 1000.0;
  CCalibratedStart = 4.1;
  CNextBlockStart = 4.3;
  CRestartStart = 7.1;
  CFrameCount = 200;
  CSampleRate = 1000.0;

var
  gLog: TStringList;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
  gLog.Add('PASS ' + AMessage);
end;

procedure CheckNear(AActual, AExpected: Double; const AMessage: string);
begin
  Check(Abs(AActual - AExpected) < 1E-8,
    AMessage + Format(' expected=%.9f actual=%.9f', [AExpected, AActual]));
end;

function SignalByName(ASignals: TList; const AName: string): TMeraSignalInfo;
var
  lIndex: Integer;
begin
  for lIndex := 0 to ASignals.Count - 1 do
    if TMeraSignalInfo(ASignals[lIndex]).Name = AName then
      Exit(TMeraSignalInfo(ASignals[lIndex]));
  raise Exception.Create('MERA signal is missing: ' + AName);
end;

procedure TestMirrorMeraTimebase;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lMirror: IRecorderDacMirror;
  lTimedMirror: IRecorderDacTimedMirror;
  lConfig: TRecorderDacConfig;
  lTime: TRecorderBlockTime;
  lResult: TRecorderDacResult;
  lBuffer: array[0..CFrameCount - 1] of Double;
  lSnapshot: TRecorderSignalSnapshot;
  lTimebase: TRecorderRecordTimebase;
  lDacDomain, lFeedbackDomain: Integer;
  lFeedbackTime, lFeedbackValue: array[0..0] of Double;
  lManager: TRecorderRecordFrameManager;
  lWriter: TRecorderMeraTagWriter;
  lSignals: TList;
  lFeedbackInfo, lDacInfo: TMeraSignalInfo;
  lFrameDir, lRootDir: string;
  lPortions: TStringList;
  lParts: TStringList;
  lFile: TFileStream;
  lFormat: TFormatSettings;
  lIndex: Integer;

  procedure WriteMirrorBlock(AStartSec: Double);
  begin
    lTime.RecorderStartSeconds := CFeedbackOrigin + AStartSec;
    Check(lTimedMirror.WriteTimedBlock(@lBuffer[0], lTime, lResult),
      'calibrated block accepted by production mirror');
    lSnapshot := lTag.RecordingSignalBuffer.LastBlockSnapshot;
    Check(lSnapshot.Count = CFrameCount, 'mirror preserves the whole block');
    CheckNear(lSnapshot.Times[0], CFeedbackOrigin + AStartSec,
      'mirror preserves the calibrated first timestamp');
    Check(lTimebase.Normalize(lDacDomain, lSnapshot.Times, lSnapshot.Count),
      'mirror uses the feedback recording origin');
    CheckNear(lSnapshot.Times[0], AStartSec, 'normalization retains DAC delay');
    lWriter.WriteBlock('DacMirror', 'V', 'calibrated DAC mirror', '', '',
      lSnapshot.Times, lSnapshot.Values, lSnapshot.Count, CSampleRate);
  end;

begin
  lRegistry := TRecorderTagRegistry.Create;
  lTimebase := TRecorderRecordTimebase.Create;
  lRootDir := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'dac-mera-timebase-' + FormatDateTime('yyyymmdd-hhnnss-zzz', Now);
  lManager := TRecorderRecordFrameManager.Create(lRootDir);
  lWriter := TRecorderMeraTagWriter.Create;
  lSignals := TList.Create;
  lPortions := TStringList.Create;
  lParts := TStringList.Create;
  try
    lTag := lRegistry.CreateTag('DacMirror', 4096, True);
    lMirror := TRecorderDacTagMirror.Create(lRegistry, lTag);
    Check(Supports(lMirror, IRecorderDacTimedMirror, lTimedMirror),
      'production mirror exposes timed writes');
    lConfig.SampleRateHz := CSampleRate;
    lConfig.ChannelCount := 1;
    lConfig.FramesPerBlock := CFrameCount;
    lConfig.MinimumValue := -1;
    lConfig.MaximumValue := 1;
    lConfig.SafeValue := 0;
    lConfig.UnderrunPolicy := rdupZero;
    Check(lMirror.Configure(lConfig, lResult), 'production mirror configures');
    lFeedbackDomain := lTimebase.RequireDomain('recorder-monotonic');
    lDacDomain := lTimebase.RequireDomain('recorder-monotonic');
    Check(lDacDomain = lFeedbackDomain, 'feedback and DAC share recording domain');
    lTimebase.SetOrigin(lFeedbackDomain, CFeedbackOrigin);
    { The mirror cannot replace an already established feedback origin. }
    lTimebase.SetOrigin(lDacDomain, CFeedbackOrigin + CCalibratedStart);
    lFrameDir := lManager.OpenNextFrame;
    lWriter.Open(lFrameDir);
    lFeedbackTime[0] := CFeedbackOrigin;
    lFeedbackValue[0] := 0;
    Check(lTimebase.Normalize(lFeedbackDomain, lFeedbackTime, 1),
      'feedback origin is ready before the first DAC block');
    lWriter.WriteBlock('PxiFeedback', 'V', 'reference input', '', '',
      lFeedbackTime, lFeedbackValue, 1, CSampleRate);
    for lIndex := 0 to High(lBuffer) do lBuffer[lIndex] := 0.05;
    lTime := Default(TRecorderBlockTime);
    lTime.Generation := 1;
    lTime.SampleCount := CFrameCount;
    lTime.SampleRateHz := CSampleRate;
    WriteMirrorBlock(CCalibratedStart);
    Check(lTag.BlockTimeDomain = btRecorderMonotonic,
      'timed mirror advertises recorder monotonic domain');
    WriteMirrorBlock(CNextBlockStart);
    lTime.Generation := 2;
    WriteMirrorBlock(CRestartStart);
    lWriter.Close;

    LoadMeraSignalsFromFile(lFrameDir + '0001.mera', lSignals);
    lFeedbackInfo := SignalByName(lSignals, 'PxiFeedback');
    lDacInfo := SignalByName(lSignals, 'DacMirror');
    CheckNear(lFeedbackInfo.StartSec, 0, 'MERA feedback starts at common origin');
    CheckNear(lDacInfo.StartSec, CCalibratedStart,
      'standard MERA reader retains nonzero first DAC Start');
    CheckNear(lDacInfo.FrequencyHz, CSampleRate, 'MERA preserves DAC sampling rate');
    CheckNear(lDacInfo.StartSec + CFrameCount / lDacInfo.FrequencyHz,
      CNextBlockStart, 'MERA next continuous block starts at 4.3 seconds');
    Check(not lDacInfo.HasXData, 'regular mirror stays in native MERA Y format');
    lFile := TFileStream.Create(lFrameDir + 'DacMirror.dat', fmOpenRead);
    try
      Check(lFile.Size = 3 * CFrameCount * SizeOf(Double),
        'MERA preserves every submitted mirror sample');
    finally
      lFile.Free;
    end;
    lPortions.LoadFromFile(lFrameDir + 'DacMirror.prt');
    Check(lPortions.Count = 1, 'MERA creates one portion for DAC restart');
    lParts.Delimiter := ' ';
    lParts.StrictDelimiter := False;
    lParts.DelimitedText := Trim(lPortions[0]);
    Check(lParts.Count = 2, 'MERA restart portion has timestamp and sample index');
    lFormat := DefaultFormatSettings;
    lFormat.DecimalSeparator := '.';
    CheckNear(StrToFloat(lParts[0], lFormat), CRestartStart,
      'MERA restart retains the measured start time');
    Check(StrToInt(lParts[1]) = 2 * CFrameCount,
      'MERA restart portion points after both continuous blocks');
    gLog.Add('ARTIFACT ' + lFrameDir);
  finally
    lTimedMirror := nil;
    lMirror := nil;
    lParts.Free;
    lPortions.Free;
    ClearMeraSignals(lSignals);
    lSignals.Free;
    lWriter.Free;
    lManager.Free;
    lTimebase.Free;
    lRegistry.Free;
  end;
end;

procedure TestCorrectedRateMera;
const
  CHardwareRate: Double = 44100;
  CFirstRate: Double = 44088.25;
  CSecondRate: Double = 44095;
  CStart: Double = 4.1;
  CRestart: Double = 7.1;
  CNewRateStart: Double = 9.1;
  CFrames = 2048;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lMirror: IRecorderDacMirror;
  lTimedMirror: IRecorderDacTimedMirror;
  lConfig: TRecorderDacConfig;
  lTime: TRecorderBlockTime;
  lResult: TRecorderDacResult;
  lBuffer: array[0..CFrames - 1] of Double;
  lExpected: array[0..6 * CFrames - 1] of Double;
  lSnapshot: TRecorderSignalSnapshot;
  lTimebase: TRecorderRecordTimebase;
  lDomain: Integer;
  lManager: TRecorderRecordFrameManager;
  lWriter: TRecorderMeraTagWriter;
  lSignals: TList;
  lInfo: TMeraSignalInfo;
  lFrameDir: string;
  lXStream: TFileStream;
  lIndex, lBlock: Integer;
  lActual, lMaxError: Double;

  procedure WriteRateBlock(AStart, ARate: Double; AGeneration: QWord);
  var
    lSample: Integer;
  begin
    lTime := Default(TRecorderBlockTime);
    lTime.Generation := AGeneration;
    lTime.SampleCount := CFrames;
    lTime.SampleRateHz := ARate;
    lTime.RecorderStartSeconds := CFeedbackOrigin + AStart;
    Check(lTimedMirror.WriteTimedBlock(@lBuffer[0], lTime, lResult),
      'measured-rate mirror block accepted');
    CheckNear(lTag.PollFrequencyHz, ARate,
      'mirror publishes effective rate without changing hardware settings');
    CheckNear(lConfig.SampleRateHz, CHardwareRate, 'nominal hardware rate stays unchanged');
    lSnapshot := lTag.RecordingSignalBuffer.LastBlockSnapshot;
    CheckNear(lSnapshot.Times[High(lSnapshot.Times)],
      CFeedbackOrigin + AStart + (CFrames - 1) / ARate,
      'mirror block endpoint follows measured DAC clock');
    Check(lTimebase.Normalize(lDomain, lSnapshot.Times, lSnapshot.Count),
      'corrected-rate mirror shares feedback origin');
    for lSample := 0 to CFrames - 1 do
      lExpected[lBlock * CFrames + lSample] := AStart + lSample / ARate;
    lWriter.WriteBlock('CorrectedDac', 'V', 'measured clock; nominalFs=44100', '', '',
      lSnapshot.Times, lSnapshot.Values, lSnapshot.Count, lTag.RecordingPollFrequencyHz);
    { This independent channel ends before any restart/rate change, so the
      final descriptor can verify the constant measured-rate Y representation
      without requiring Flush to publish an unfinished frame descriptor. }
    if lBlock < 2 then
      lWriter.WriteBlock('ConstantRateDac', 'V', 'nominalFs=44100', '', '',
        lSnapshot.Times, lSnapshot.Values, lSnapshot.Count, lTag.RecordingPollFrequencyHz);
    Inc(lBlock);
  end;

begin
  lRegistry := TRecorderTagRegistry.Create;
  lTimebase := TRecorderRecordTimebase.Create;
  lManager := TRecorderRecordFrameManager.Create(
    IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'dac-mera-rate-' + FormatDateTime('yyyymmdd-hhnnss-zzz', Now));
  lWriter := TRecorderMeraTagWriter.Create;
  lSignals := TList.Create;
  try
    lTag := lRegistry.CreateTag('CorrectedDac', 16384, True);
    lMirror := TRecorderDacTagMirror.Create(lRegistry, lTag);
    Check(Supports(lMirror, IRecorderDacTimedMirror, lTimedMirror),
      'corrected-rate test uses production timed mirror');
    lConfig.SampleRateHz := CHardwareRate;
    lConfig.ChannelCount := 1;
    lConfig.FramesPerBlock := CFrames;
    lConfig.MinimumValue := -1;
    lConfig.MaximumValue := 1;
    lConfig.SafeValue := 0;
    lConfig.UnderrunPolicy := rdupZero;
    Check(lMirror.Configure(lConfig, lResult), 'corrected-rate mirror configures');
    lDomain := lTimebase.RequireDomain('recorder-monotonic');
    lTimebase.SetOrigin(lDomain, CFeedbackOrigin);
    lFrameDir := lManager.OpenNextFrame;
    lWriter.Open(lFrameDir);
    for lIndex := 0 to High(lBuffer) do lBuffer[lIndex] := 0.05;
    lBlock := 0;
    WriteRateBlock(CStart, CFirstRate, 1);
    WriteRateBlock(CStart + CFrames / CFirstRate, CFirstRate, 1);
    { First restart still uses the old rate, creating .prt history which
      must survive the later conversion to explicit X. }
    WriteRateBlock(CRestart, CFirstRate, 2);
    WriteRateBlock(CRestart + CFrames / CFirstRate, CFirstRate, 2);
    WriteRateBlock(CNewRateStart, CSecondRate, 3);
    WriteRateBlock(CNewRateStart + CFrames / CSecondRate, CSecondRate, 3);
    lWriter.Close;
    LoadMeraSignalsFromFile(lFrameDir + '0001.mera', lSignals);
    lInfo := SignalByName(lSignals, 'ConstantRateDac');
    CheckNear(lInfo.StartSec, CStart,
      'constant fractional-rate MERA preserves first calibrated Start');
    CheckNear(lInfo.FrequencyHz, CFirstRate,
      'constant fractional-rate MERA preserves effective frequency');
    Check(not lInfo.HasXData, 'constant corrected rate keeps native uniform MERA format');
    lInfo := SignalByName(lSignals, 'CorrectedDac');
    CheckNear(lInfo.StartSec, 0,
      'explicit-X MERA has no extra Start offset to add twice');
    CheckNear(lInfo.FrequencyHz, CSecondRate,
      'MERA descriptor retains the last applied effective rate');
    Check(Pos('nominalFs=44100', lInfo.Description) > 0,
      'MERA preserves nominal hardware rate provenance');
    Check(lInfo.HasXData, 'changed effective rate promotes MERA to explicit timestamps');
    lXStream := TFileStream.Create(lInfo.XFileName, fmOpenRead);
    try
      Check(lXStream.Size = Length(lExpected) * SizeOf(Double),
        'explicit X contains backfilled old samples and both new-rate blocks');
      lMaxError := 0;
      for lIndex := 0 to High(lExpected) do
      begin
        lXStream.ReadBuffer(lActual, SizeOf(lActual));
        lMaxError := Max(lMaxError, Abs(lActual - lExpected[lIndex]));
      end;
      CheckNear(lMaxError, 0,
        'all MERA timestamps preserve measured rates and restart without rewriting past');
    finally
      lXStream.Free;
    end;
    gLog.Add(Format('MEASURED CLOCK first=%.6f Hz drift=%.3f ppm second=%.6f Hz',
      [CFirstRate, (CFirstRate / CHardwareRate - 1) * 1E6, CSecondRate]));
    gLog.Add('ARTIFACT ' + lFrameDir);
  finally
    lTimedMirror := nil;
    lMirror := nil;
    ClearMeraSignals(lSignals);
    lSignals.Free;
    lWriter.Free;
    lManager.Free;
    lTimebase.Free;
    lRegistry.Free;
  end;
end;

procedure TestProvisionalRecordingIsolation;
var
  lRegistry: TRecorderTagRegistry;
  lTag: TRecorderTag;
  lMirror: IRecorderDacMirror;
  lTimed: IRecorderDacTimedMirror;
  lProvisional: IRecorderDacProvisionalMirror;
  lConfig: TRecorderDacConfig;
  lTime: TRecorderBlockTime;
  lResult: TRecorderDacResult;
  lValues: array[0..3] of Double;
  lTimes, lReadValues: TRecorderDoubleArray;
  lCursor: QWord;
  lCount: Integer;
begin
  lRegistry := TRecorderTagRegistry.Create;
  try
    lTag := lRegistry.CreateTag('ProvisionalDac', 4096, True);
    lTag.AddSample(1, 0);
    lCursor := lTag.SignalBuffer.CurrentCursor;
    lMirror := TRecorderDacTagMirror.Create(lRegistry, lTag);
    Check(Supports(lMirror, IRecorderDacTimedMirror, lTimed), 'timed recording interface');
    Check(Supports(lMirror, IRecorderDacProvisionalMirror, lProvisional), 'live-only provisional interface');
    lConfig := Default(TRecorderDacConfig);
    lConfig.SampleRateHz := 1000;
    lConfig.ChannelCount := 1;
    lConfig.FramesPerBlock := 4;
    lConfig.MinimumValue := -1;
    lConfig.MaximumValue := 1;
    Check(lMirror.Configure(lConfig, lResult), 'separate recording ring configured');
    Check(lTag.RecordingSignalBuffer.CurrentCursor = lCursor, 'recording ring seeds existing cursor');
    lTime := Default(TRecorderBlockTime);
    lTime.Generation := 1;
    lTime.SampleRateHz := 1000;
    lTime.SampleCount := 4;
    lTime.RecorderStartSeconds := 2;
    lValues[0] := 0; lValues[1] := 0.05; lValues[2] := 0.05; lValues[3] := 0;
    Check(lProvisional.WriteProvisionalTimedBlock(@lValues[0], lTime, lResult), 'pending marker published live immediately');
    Check(lTag.SignalBuffer.Count = 4, 'oscilloscope sees provisional marker');
    lTag.RecordingSignalBuffer.SnapshotSinceInto(lCursor, lTimes, lReadValues, lCount);
    Check(lCount = 0, 'MERA cannot consume provisional samples');
    Check(lProvisional.BeginCalibratedReplay(lResult), 'begin corrected replay');
    Check(lTag.SignalBuffer.Count = 0, 'provisional display cleared before replay');
    lTime.RecorderStartSeconds := 4.1;
    lTime.SampleRateHz := 999.5;
    Check(lTimed.WriteTimedBlock(@lValues[0], lTime, lResult), 'corrected replay published');
    CheckNear(lTag.RecordingPollFrequencyHz, 999.5, 'recording metadata uses calibrated rate');
    { Leave corrected samples unconsumed while a new nominal trial starts. }
    lTime.RecorderStartSeconds := 5;
    lTime.SampleRateHz := 1000;
    Check(lProvisional.WriteProvisionalTimedBlock(@lValues[0], lTime, lResult), 'second provisional trial published');
    CheckNear(lTag.RecordingPollFrequencyHz, 999.5, 'pending nominal display cannot overwrite recording rate');
    Check(lProvisional.BeginCalibratedReplay(lResult), 'second corrected replay begins');
    lTag.RecordingSignalBuffer.SnapshotSinceInto(lCursor, lTimes, lReadValues, lCount);
    Check(lCount = 4, 'previous unconsumed calibrated tail survives next calibration');
    CheckNear(lTimes[0], 4.1, 'first recorded timestamp retains feedback alignment');
    CheckNear(lTimes[3], 4.1 + 3 / 999.5, 'recorded sample clock remains calibrated');
  finally
    lProvisional := nil;
    lTimed := nil;
    lMirror := nil;
    lRegistry.Free;
  end;
end;

begin
  gLog := TStringList.Create;
  try
    try
      TestMirrorMeraTimebase;
      TestCorrectedRateMera;
      TestProvisionalRecordingIsolation;
      gLog.Add('RESULT RecorderDacMeraTimebaseTest passed');
      Writeln(gLog.Text);
      gLog.SaveToFile(ChangeFileExt(ParamStr(0), '.log'));
    except
      on E: Exception do
      begin
        gLog.Add('RESULT RecorderDacMeraTimebaseTest failed: ' + E.Message);
        Writeln(gLog.Text);
        gLog.SaveToFile(ChangeFileExt(ParamStr(0), '.log'));
        ExitCode := 1;
      end;
    end;
  finally
    gLog.Free;
  end;
end.
