unit uRecorderDacTagMirror;

{ Publishes final DAC samples into the tag ring. Timed session writes retain
  their Recorder timestamps; legacy callers keep their relative sample clock. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderTags, uRecorderDacTypes, uRecorderDacContracts, uRecorderBlockClock;

type
  TRecorderDacTagMirror = class(TInterfacedObject, IRecorderDacMirror,
    IRecorderDacMirrorIdentity, IRecorderDacTimedMirror)
  private
    fRegistry: TRecorderTagRegistry;
    fTag: TRecorderTag;
    fInputTagName: string;
    fConfig: TRecorderDacConfig;
    fTimes: TRecorderDoubleArray;
    fValues: TRecorderDoubleArray;
    fNextTime: Double;
  public
    constructor Create(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag;
      const AInputTagName: string = '');
    function Configure(const AConfig: TRecorderDacConfig;
      out AResult: TRecorderDacResult): Boolean;
    procedure Reset;
    function WriteBlock(ABuffer: PDouble; AFrameCount: Integer;
      out AResult: TRecorderDacResult): Boolean;
    function WriteTimedBlock(ABuffer: PDouble; const ATime: TRecorderBlockTime;
      out AResult: TRecorderDacResult): Boolean;
    function MirrorIdentity: QWord;
  end;

implementation

uses SysUtils, Math;

constructor TRecorderDacTagMirror.Create(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag; const AInputTagName: string);
begin
  inherited Create;
  fRegistry := ARegistry;
  fTag := ATag;
  fInputTagName := AInputTagName;
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
  SetLength(fTimes, AConfig.FramesPerBlock);
  SetLength(fValues, AConfig.FramesPerBlock);
  fTag.PollFrequencyHz := AConfig.SampleRateHz;
  { ConfigureBlockRing only defines logical block boundaries. The sample
    history needs its own capacity, as for ordinary hardware vector tags. }
  fTag.EnsureBufferCapacity(Ceil(Max(4096.0,
    Max(AConfig.SampleRateHz * 4, AConfig.FramesPerBlock * 8.0))));
  fTag.SignalBuffer.ConfigureBlockRing(AConfig.FramesPerBlock, 8);
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
var
  I: Integer;
begin
  Result := (ATime.SampleCount > 0) and
    (ATime.SampleCount <= Length(fValues)) and (ATime.SampleRateHz > 0);
  if not Result then
  begin
    AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
      'DAC mirror block exceeds configured capacity');
    Exit;
  end;
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
  fRegistry.PublishBlockNotifications(fTag, fTimes, fValues, ATime.SampleCount);
  fNextTime := ATime.RecorderStartSeconds + ATime.SampleCount / ATime.SampleRateHz;
  AResult := RecorderDacOk;
end;

end.
