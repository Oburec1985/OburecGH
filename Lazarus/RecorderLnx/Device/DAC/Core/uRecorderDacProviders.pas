unit uRecorderDacProviders;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Math, SysUtils, uRecorderTags, uRecorderDacTypes, uRecorderDacContracts;

type
  TRecorderDacSineProvider = class(TInterfacedObject,
    IRecorderDacSampleProvider)
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
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
  end;

  TRecorderDacTagProvider = class(TInterfacedObject,
    IRecorderDacSampleProvider, IRecorderDacSourceIdentity)
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
    procedure Reset;
    function FillBlock(ABuffer: PDouble; AFrameCapacity: Integer;
      out AFrameCount: Integer; out AResult: TRecorderDacResult): Boolean;
    function SourceIdentity: QWord;
    property TagName: string read fTagName;
  end;

implementation

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
