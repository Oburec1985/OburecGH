unit uRecorderDacProviders;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Math, SysUtils, uRecorderTags, uRecorderDacTypes, uRecorderDacContracts;

type
  TRecorderDacWaveMode = (rdwmSine, rdwmAccurateSine, rdwmSweepSine);

  { Continuous mono engineering level, independent of oscillator frequency.
    Configure validates the immutable level; FillBlock allocates nothing. }
  TRecorderDacConstantProvider = class(TInterfacedObject, IRecorderDacSampleProvider, IRecorderDacPlaybackRateControl)
  private
    fLevel: Double;
    fFramesPerBlock: Integer;
  public
    constructor Create(ALevel: Double);
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function CanSetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    function SetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
  end;

  { Finite sine bursts. Interval includes the silent tail; parameters are
    immutable during playback, and frame counters persist across blocks. }
  TRecorderDacPulseProvider = class(TInterfacedObject, IRecorderDacSampleProvider, IRecorderDacPlaybackRateControl)
  private
    fFrequency, fAmplitude, fInterval: Double;
    fPeriods, fCount: Integer;
    fConfig: TRecorderDacConfig;
    fActiveSec, fElapsedSeconds: Double;
  public
    constructor Create(AFrequency, AAmplitude, AInterval: Double;
      APeriods, ACount: Integer);
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function CanSetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    function SetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
  end;

  TRecorderDacWaveProvider = class(TInterfacedObject,
    IRecorderDacSampleProvider, IRecorderDacPlaybackRateControl)
  private
    fMode: TRecorderDacWaveMode;
    fFrequencyHz: Double;
    fAmplitude: Double;
    fSweepStartHz: Double;
    fSweepEndHz: Double;
    fSweepTimeSec: Double;
    fPhase: Double;
    fElapsedSec: Double;
    fConfig: TRecorderDacConfig;
    function CurrentFrequency: Double;
  public
    constructor Create(AMode: TRecorderDacWaveMode; AFrequencyHz,
      AAmplitude, ASweepStartHz, ASweepEndHz, ASweepTimeSec: Double);
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function CanSetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    function SetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
  end;

  TRecorderDacSineProvider = class(TInterfacedObject,
    IRecorderDacSampleProvider, IRecorderDacPlaybackRateControl)
  private
    fAmplitude: Double;
    fFrequencyHz: Double;
    fOffset: Double;
    fPhase: Double;
    fStep: Double;
    fConfig: TRecorderDacConfig;
  public
    constructor Create(AFrequencyHz, AAmplitude: Double; AOffset: Double = 0);
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function CanSetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    function SetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
  end;

  TRecorderDacTagProvider = class(TInterfacedObject,
    IRecorderDacSampleProvider, IRecorderDacSourceIdentity, IRecorderDacPlaybackRateControl)
  private
    fTag: TRecorderTag;
    fTagName: string;
    fBlockCursor: QWord;
    fTimes: TRecorderDoubleArray;
    fValues: TRecorderDoubleArray;
    fConfig: TRecorderDacConfig;
  public
    constructor Create(ATag: TRecorderTag);
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    function CanSetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    function SetPlaybackSampleRate(AHz: Double; out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
    function SourceIdentity: QWord;
    property TagName: string read fTagName;
  end;

implementation

function ValidPlaybackRate(ARate, AFrequency: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := not IsNan(ARate) and not IsInfinite(ARate) and
    (ARate > 0) and (AFrequency <= ARate / 2);
  if Result then AResult := RecorderDacOk
  else AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure, 'Invalid playback sample rate');
end;

function TRecorderDacConstantProvider.CanSetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := ValidPlaybackRate(AHz, 0, AResult);
end;

function TRecorderDacConstantProvider.SetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := CanSetPlaybackSampleRate(AHz, AResult);
end;

function TRecorderDacWaveProvider.CanSetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
var
  lMaximum: Double;
begin
  lMaximum := fFrequencyHz;
  if fMode = rdwmSweepSine then lMaximum := Max(fSweepStartHz, fSweepEndHz);
  Result := ValidPlaybackRate(AHz, lMaximum, AResult);
end;

function TRecorderDacWaveProvider.SetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := CanSetPlaybackSampleRate(AHz, AResult);
  if Result then fConfig.SampleRateHz := AHz;
end;

function TRecorderDacSineProvider.CanSetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := ValidPlaybackRate(AHz, fFrequencyHz, AResult);
end;

function TRecorderDacSineProvider.SetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := CanSetPlaybackSampleRate(AHz, AResult);
  if not Result then Exit;
  fConfig.SampleRateHz := AHz;
  fStep := 2 * Pi * fFrequencyHz / AHz;
end;

function TRecorderDacPulseProvider.CanSetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := ValidPlaybackRate(AHz, fFrequency, AResult);
end;

function TRecorderDacPulseProvider.SetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := CanSetPlaybackSampleRate(AHz, AResult);
  if Result then fConfig.SampleRateHz := AHz;
end;

function TRecorderDacTagProvider.CanSetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := ValidPlaybackRate(AHz, 0, AResult) and
    (Abs(AHz - fConfig.SampleRateHz) < 1e-9);
  if not Result then AResult := RecorderDacFailed(rdeUnsupported, rdsgConfigure,
    'Tag provider cannot change playback clock without resampling');
end;

function TRecorderDacTagProvider.SetPlaybackSampleRate(AHz: Double;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := CanSetPlaybackSampleRate(AHz, AResult);
end;

constructor TRecorderDacConstantProvider.Create(ALevel: Double);
begin
  inherited Create;
  fLevel := ALevel;
end;

function TRecorderDacConstantProvider.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
begin
  fFramesPerBlock := 0;
  Result := False;
  if not RecorderDacValidateConfig(AConfig, AResult) then Exit;
  if (AConfig.ChannelCount <> 1) or IsNan(fLevel) or IsInfinite(fLevel) or
    (fLevel < AConfig.MinimumValue) or (fLevel > AConfig.MaximumValue) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Constant level requires mono output and a finite level within DAC range');
    Exit;
  end;
  fFramesPerBlock := AConfig.FramesPerBlock;
  AResult := RecorderDacOk;
  Result := True;
end;

procedure TRecorderDacConstantProvider.Reset;
begin
  { A constant level has no phase or finite-series cursor to reset. }
end;

function TRecorderDacConstantProvider.FillBlock(ABuffer: PDouble;
  AFrameCapacity: Integer; out AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
var
  I: Integer;
begin
  AFrameCount := 0;
  Result := (ABuffer <> nil) and (fFramesPerBlock > 0) and
    (AFrameCapacity >= fFramesPerBlock);
  if not Result then
  begin
    AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
      'Constant level block requires configured output buffer capacity');
    Exit;
  end;
  for I := 0 to fFramesPerBlock - 1 do ABuffer[I] := fLevel;
  AFrameCount := fFramesPerBlock;
  AResult := RecorderDacOk;
end;

constructor TRecorderDacPulseProvider.Create(AFrequency, AAmplitude,
  AInterval: Double; APeriods, ACount: Integer);
begin
  inherited Create;
  fFrequency := AFrequency;
  fAmplitude := AAmplitude;
  fInterval := AInterval;
  fPeriods := APeriods;
  fCount := ACount;
end;

function TRecorderDacPulseProvider.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
begin
  Result := False;
  if not RecorderDacValidateConfig(AConfig, AResult) then Exit;
  AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
    'Pulse requires F > 0, periods/count > 0, interval >= periods/F and F <= Fs/2');
  if IsNan(fFrequency) or IsInfinite(fFrequency) or
    IsNan(fInterval) or IsInfinite(fInterval) or
    IsNan(fAmplitude) or IsInfinite(fAmplitude) then Exit;
  if (fFrequency <= 0) or (fFrequency > AConfig.SampleRateHz / 2) or
    (fPeriods <= 0) or (fCount <= 0) or (fAmplitude < 0) then Exit;
  fActiveSec := fPeriods / fFrequency;
  if (fInterval < fActiveSec) or
    (fInterval * AConfig.SampleRateHz > High(Int64) / fCount / 2) then Exit;
  if Round(fInterval * AConfig.SampleRateHz) < 1 then Exit;
  fConfig := AConfig;
  Reset;
  AResult := RecorderDacOk;
  Result := True;
end;

procedure TRecorderDacPulseProvider.Reset;
begin
  fElapsedSeconds := 0;
end;

function TRecorderDacPulseProvider.FillBlock(ABuffer: PDouble;
  AFrameCapacity: Integer; out AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
var
  I, J: Integer;
  lTime, lValue: Double;
begin
  AFrameCount := 0;
  if fElapsedSeconds >= fInterval * fCount - 1e-12 then
  begin
    AResult := RecorderDacFailed(rdeCompleted, rdsgWrite, 'Pulse series completed');
    Exit(False);
  end;
  AFrameCount := Min(AFrameCapacity, Ceil((fInterval * fCount - fElapsedSeconds) *
    fConfig.SampleRateHz - 1e-9));
  for I := 0 to AFrameCount - 1 do
  begin
    lTime := fElapsedSeconds - Floor((fElapsedSeconds + 1e-12) / fInterval) * fInterval;
    if lTime < fActiveSec then
      lValue := fAmplitude * Sin(2 * Pi * fFrequency * lTime)
    else lValue := 0;
    for J := 0 to fConfig.ChannelCount - 1 do
    begin
      ABuffer^ := lValue;
      Inc(ABuffer);
    end;
    fElapsedSeconds := fElapsedSeconds + 1 / fConfig.SampleRateHz;
  end;
  AResult := RecorderDacOk;
  Result := True;
end;

constructor TRecorderDacWaveProvider.Create(AMode: TRecorderDacWaveMode;
  AFrequencyHz, AAmplitude, ASweepStartHz, ASweepEndHz,
  ASweepTimeSec: Double);
begin
  inherited Create;
  fMode := AMode;
  fFrequencyHz := AFrequencyHz;
  fAmplitude := AAmplitude;
  fSweepStartHz := ASweepStartHz;
  fSweepEndHz := ASweepEndHz;
  fSweepTimeSec := ASweepTimeSec;
end;

function TRecorderDacWaveProvider.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
var
  lMaxFrequency: Double;
begin
  fConfig := AConfig;
  if fMode = rdwmSweepSine then lMaxFrequency := Max(fSweepStartHz, fSweepEndHz)
  else lMaxFrequency := fFrequencyHz;
  Result := (fAmplitude >= 0) and (lMaxFrequency >= 0) and
    (lMaxFrequency <= AConfig.SampleRateHz / 2) and
    ((fMode <> rdwmSweepSine) or (fSweepTimeSec > 0));
  if Result then AResult := RecorderDacOk
  else AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
    'DAC signal parameters are outside the sample-rate range');
end;

procedure TRecorderDacWaveProvider.Reset;
begin
  fPhase := 0;
  fElapsedSec := 0;
end;

function TRecorderDacWaveProvider.CurrentFrequency: Double;
var
  lFraction: Double;
begin
  if fMode <> rdwmSweepSine then Exit(fFrequencyHz);
  lFraction := Frac(fElapsedSec / fSweepTimeSec);
  Result := fSweepStartHz + (fSweepEndHz - fSweepStartHz) * lFraction;
end;

function TRecorderDacWaveProvider.FillBlock(ABuffer: PDouble;
  AFrameCapacity: Integer; out AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
var
  I, lChannel: Integer;
  lValue: Double;
begin
  AFrameCount := AFrameCapacity;
  for I := 0 to AFrameCount - 1 do
  begin
    lValue := fAmplitude * Sin(fPhase);
    for lChannel := 0 to fConfig.ChannelCount - 1 do
    begin
      ABuffer^ := lValue;
      Inc(ABuffer);
    end;
    fPhase := fPhase + 2 * Pi * CurrentFrequency / fConfig.SampleRateHz;
    fPhase := fPhase - Floor(fPhase / (2 * Pi)) * 2 * Pi;
    fElapsedSec := fElapsedSec + 1 / fConfig.SampleRateHz;
  end;
  AResult := RecorderDacOk;
  Result := True;
end;

constructor TRecorderDacSineProvider.Create(AFrequencyHz, AAmplitude: Double;
  AOffset: Double);
begin
  inherited Create;
  fFrequencyHz := AFrequencyHz;
  fAmplitude := AAmplitude;
  fOffset := AOffset;
end;

function TRecorderDacSineProvider.Configure(
  const AConfig: TRecorderDacConfig; out AResult: TRecorderDacResult): Boolean;
begin
  fConfig := AConfig;
  Result := (fFrequencyHz >= 0) and (fFrequencyHz <= AConfig.SampleRateHz / 2);
  if Result then
  begin
    fStep := 2 * Pi * fFrequencyHz / AConfig.SampleRateHz;
    AResult := RecorderDacOk;
  end
  else
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'Generator frequency must be between zero and Nyquist frequency');
end;

procedure TRecorderDacSineProvider.Reset;
begin
  fPhase := 0;
end;

function TRecorderDacSineProvider.FillBlock(ABuffer: PDouble;
  AFrameCapacity: Integer; out AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
var
  I, lChannel: Integer;
  lValue: Double;
begin
  AFrameCount := AFrameCapacity;
  for I := 0 to AFrameCount - 1 do
  begin
    lValue := fOffset + fAmplitude * Sin(fPhase);
    for lChannel := 0 to fConfig.ChannelCount - 1 do
    begin
      ABuffer^ := lValue;
      Inc(ABuffer);
    end;
    fPhase := fPhase + fStep;
    if fPhase >= 2 * Pi then
      fPhase := fPhase - Floor(fPhase / (2 * Pi)) * 2 * Pi;
  end;
  AResult := RecorderDacOk;
  Result := True;
end;

constructor TRecorderDacTagProvider.Create(ATag: TRecorderTag);
begin
  inherited Create;
  fTag := ATag;
  if fTag <> nil then fTagName := fTag.Name;
end;

function TRecorderDacTagProvider.SourceIdentity: QWord;
begin
  if fTag <> nil then Result := fTag.Id else Result := 0;
end;

function TRecorderDacTagProvider.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
var
  lBlockCapacity: Integer;
begin
  Result := False;
  if fTag = nil then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC input tag is not assigned');
    Exit;
  end;
  if AConfig.ChannelCount <> 1 then
  begin
    AResult := RecorderDacFailed(rdeUnsupported, rdsgConfigure,
      'Tag provider currently supports one DAC channel');
    Exit;
  end;
  if Abs(fTag.PollFrequencyHz - AConfig.SampleRateHz) > 0.000001 then
  begin
    AResult := RecorderDacFailed(rdeUnsupported, rdsgConfigure,
      Format('Tag frequency %.6g Hz differs from DAC frequency %.6g Hz',
        [fTag.PollFrequencyHz, AConfig.SampleRateHz]));
    Exit;
  end;
  lBlockCapacity := fTag.SignalBuffer.CurrentBlockSampleCapacity;
  if lBlockCapacity <> AConfig.FramesPerBlock then
  begin
    AResult := RecorderDacFailed(rdeUnsupported, rdsgConfigure,
      Format('Tag block has %d frames; DAC requires %d',
        [lBlockCapacity, AConfig.FramesPerBlock]));
    Exit;
  end;
  fConfig := AConfig;
  SetLength(fTimes, lBlockCapacity);
  SetLength(fValues, lBlockCapacity);
  AResult := RecorderDacOk;
  Result := True;
end;

procedure TRecorderDacTagProvider.Reset;
begin
  if fTag <> nil then
    fBlockCursor := fTag.SignalBuffer.CurrentBlockCursor
  else
    fBlockCursor := 0;
end;

function TRecorderDacTagProvider.FillBlock(ABuffer: PDouble;
  AFrameCapacity: Integer; out AFrameCount: Integer;
  out AResult: TRecorderDacResult): Boolean;
begin
  AFrameCount := 0;
  Result := fTag.SignalBuffer.SnapshotNextBlockInto(fBlockCursor, fTimes,
    fValues, AFrameCount);
  if not Result then
  begin
    AResult := RecorderDacFailed(rdeNoData, rdsgWrite,
      'No unread complete tag block');
    Exit;
  end;
  if AFrameCount > AFrameCapacity then
  begin
    AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
      'DAC buffer is smaller than tag block');
    Exit(False);
  end;
  if AFrameCount <> fConfig.FramesPerBlock then
  begin
    AResult := RecorderDacFailed(rdeNoData, rdsgWrite,
      'Input tag returned an incomplete logical block');
    Exit(False);
  end;
  Move(fValues[0], ABuffer^, AFrameCount * SizeOf(Double));
  AResult := RecorderDacOk;
end;

end.
