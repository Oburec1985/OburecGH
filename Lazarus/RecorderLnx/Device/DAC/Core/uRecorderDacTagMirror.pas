unit uRecorderDacTagMirror;

{ Publishes DAC samples into the live tag ring. During feedback calibration,
  host-timed provisional samples update only that display ring, without SQL or
  block algorithm callbacks. Corrected replay also fills a separate recording
  ring, so the MERA consumer never sees provisional timestamps. Buffers are
  allocated by Configure; all writes use preallocated publisher-owned arrays. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderTags, uRecorderDacTypes, uRecorderDacContracts, uRecorderBlockClock;

type
  TRecorderDacTagMirror = class(TInterfacedObject, IRecorderDacMirror,
    IRecorderDacMirrorIdentity, IRecorderDacTimedMirror,
    IRecorderDacProvisionalMirror)
  private
    fRegistry: TRecorderTagRegistry;
    fTag: TRecorderTag;
    fInputTagName: string;
    fConfig: TRecorderDacConfig;
    fTimes: TRecorderDoubleArray;
    fValues: TRecorderDoubleArray;
    fNextTime: Double;
    fMinimumHistorySeconds: Double;
    fHasProvisionalHistory: Boolean;
    function PublishTimedBlock(ABuffer: PDouble; const ATime: TRecorderBlockTime;
      AProvisional: Boolean; out AResult: TRecorderDacResult): Boolean;
  public
    constructor Create(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      const AInputTagName: string = ''; AMinimumHistorySeconds: Double = 4);
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function WriteBlock(ABuffer: PDouble; AFrameCount: Integer;
      out AResult: TRecorderDacResult): Boolean;
    function WriteTimedBlock(ABuffer: PDouble; const ATime: TRecorderBlockTime;
      out AResult: TRecorderDacResult): Boolean;
    function MirrorIdentity: QWord;
    function WriteProvisionalTimedBlock(ABuffer: PDouble;
      const ATime: TRecorderBlockTime; out AResult: TRecorderDacResult): Boolean;
    function BeginCalibratedReplay(out AResult: TRecorderDacResult): Boolean;
  end;

implementation

uses SysUtils, Math;

constructor TRecorderDacTagMirror.Create(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const AInputTagName: string;
  AMinimumHistorySeconds: Double);
begin
  inherited Create;
  fRegistry := ARegistry;
  fTag := ATag;
  fInputTagName := AInputTagName;
  fMinimumHistorySeconds := Max(4, AMinimumHistorySeconds);
end;

function TRecorderDacTagMirror.MirrorIdentity: QWord;
begin
  if fTag <> nil then Result := fTag.Id else Result := 0;
end;

function TRecorderDacTagMirror.Configure(const AConfig: TRecorderDacConfig;
  out AResult: TRecorderDacResult): Boolean;
var
  lRevision, lBlockCounter: QWord;
  lCount: Integer;
  lLatestTime: Double;
begin
  Result := False;
  if (fRegistry = nil) or (fTag = nil) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC mirror registry and tag are required');
    Exit;
  end;
  if AConfig.ChannelCount <> 1 then
  begin
    AResult := RecorderDacFailed(rdeUnsupported, rdsgConfigure,
      'Tag mirror currently supports one DAC channel');
    Exit;
  end;
  if SameText(fInputTagName, fTag.Name) and (fInputTagName <> '') then
  begin
    AResult := RecorderDacFailed(rdeFeedbackLoop, rdsgConfigure,
      'DAC input tag cannot also be its mirror tag');
    Exit;
  end;
  fConfig := AConfig;
  if IsNan(fMinimumHistorySeconds) or IsInfinite(fMinimumHistorySeconds) or
    (fMinimumHistorySeconds > 64) then
  begin
    AResult := RecorderDacFailed(rdeInvalidConfig, rdsgConfigure,
      'DAC mirror history exceeds the bounded calibration window');
    Exit(False);
  end;
  { The recorder chooses its file clock domain before the first output block. }
  fTag.BlockTimeDomain := btRecorderMonotonic;
  SetLength(fTimes, AConfig.FramesPerBlock);
  SetLength(fValues, AConfig.FramesPerBlock);
  fTag.PollFrequencyHz := AConfig.SampleRateHz;
  { ConfigureBlockRing only defines logical block boundaries. The sample
    history needs its own capacity, as for ordinary hardware vector tags. }
  fTag.EnsureBufferCapacity(Ceil(Max(4096.0,
    Max(AConfig.SampleRateHz * fMinimumHistorySeconds * 1.01,
      AConfig.FramesPerBlock * 8.0))));
  fTag.SignalBuffer.ConfigureBlockRing(AConfig.FramesPerBlock, 8);
  fTag.EnsureRecordingBuffer(fTag.SignalBuffer.Capacity, AConfig.FramesPerBlock);
  { A new mirror object can attach to an existing tag after parameter edits.
    Starting at zero would make AddSamples discard the old time epoch. }
  fTag.ReadSignalInfo(lRevision, lBlockCounter, lCount, lLatestTime);
  if lCount > 0 then
    fNextTime := Max(fNextTime, lLatestTime + 1 / AConfig.SampleRateHz);
  AResult := RecorderDacOk;
  Result := True;
end;

procedure TRecorderDacTagMirror.Reset;
begin
  { Timeline remains monotonic across repeated Start/Stop cycles. }
  fHasProvisionalHistory := False;
end;

function TRecorderDacTagMirror.WriteBlock(ABuffer: PDouble;
  AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
var
  lTime: TRecorderBlockTime;
begin
  FillChar(lTime, SizeOf(lTime), 0);
  lTime.RecorderStartSeconds := fNextTime;
  lTime.SampleRateHz := fConfig.SampleRateHz;
  lTime.SampleCount := AFrameCount;
  Result := WriteTimedBlock(ABuffer, lTime, AResult);
end;

function TRecorderDacTagMirror.WriteTimedBlock(ABuffer: PDouble;
  const ATime: TRecorderBlockTime; out AResult: TRecorderDacResult): Boolean;
begin
  Result := PublishTimedBlock(ABuffer, ATime, False, AResult);
end;

function TRecorderDacTagMirror.WriteProvisionalTimedBlock(ABuffer: PDouble;
  const ATime: TRecorderBlockTime; out AResult: TRecorderDacResult): Boolean;
begin
  if (fTag = nil) or (ABuffer = nil) or (ATime.SampleCount <= 0) or
    (ATime.SampleCount > Length(fValues)) or (ATime.SampleRateHz <= 0) then
    Exit(PublishTimedBlock(ABuffer, ATime, True, AResult));
  if not fHasProvisionalHistory then
  begin
    fTag.ClearSignalHistory;
    fHasProvisionalHistory := True;
  end;
  Result := PublishTimedBlock(ABuffer, ATime, True, AResult);
end;

function TRecorderDacTagMirror.BeginCalibratedReplay(
  out AResult: TRecorderDacResult): Boolean;
begin
  if fHasProvisionalHistory then
  begin
    fTag.ClearSignalHistory;
    fHasProvisionalHistory := False;
  end;
  AResult := RecorderDacOk;
  Result := True;
end;

function TRecorderDacTagMirror.PublishTimedBlock(ABuffer: PDouble;
  const ATime: TRecorderBlockTime; AProvisional: Boolean;
  out AResult: TRecorderDacResult): Boolean;
var
  I: Integer;
begin
  Result := (fTag <> nil) and (ABuffer <> nil) and (ATime.SampleCount > 0) and
    (ATime.SampleCount <= Length(fValues)) and (ATime.SampleRateHz > 0);
  if not Result then
  begin
    AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
      'DAC mirror block exceeds configured capacity');
    Exit;
  end;
  { Publication metadata describes the calibrated sample clock. The hardware
    config remains nominal; only the tag/file timebase follows this rate. }
  if fTag.PollFrequencyHz <> ATime.SampleRateHz then
    fTag.PollFrequencyHz := ATime.SampleRateHz;
  for I := 0 to ATime.SampleCount - 1 do
  begin
    fTimes[I] := ATime.RecorderStartSeconds + I / ATime.SampleRateHz;
    fValues[I] := ABuffer[I];
  end;
  if ATime.Generation > 0 then
    fTag.BlockTimeDomain := btRecorderMonotonic
  else
    fTag.BlockTimeDomain := btSessionRelative;
  fRegistry.AddBlockSamples(fTag, fTimes, fValues, ATime.SampleCount, True);
  if not AProvisional then
  begin
    fTag.RecordingPollFrequencyHz := ATime.SampleRateHz;
    fTag.RecordingSignalBuffer.AddSamples(fTimes, fValues, ATime.SampleCount);
    fRegistry.PublishBlockNotifications(fTag, fTimes, fValues, ATime.SampleCount);
  end;
  fNextTime := ATime.RecorderStartSeconds + ATime.SampleCount / ATime.SampleRateHz;
  AResult := RecorderDacOk;
end;

end.
