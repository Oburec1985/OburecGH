unit uRecorderDacTagMirror;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderTags, uRecorderDacTypes, uRecorderDacContracts;

type
  TRecorderDacTagMirror = class(TInterfacedObject, IRecorderDacMirror,
    IRecorderDacMirrorIdentity)
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
    function MirrorIdentity: QWord;
  end;

implementation

uses SysUtils;

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
  fTag.SignalBuffer.ConfigureBlockRing(AConfig.FramesPerBlock, 8);
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
  I: Integer;
begin
  Result := (AFrameCount > 0) and (AFrameCount <= Length(fValues));
  if not Result then
  begin
    AResult := RecorderDacFailed(rdeBufferTooSmall, rdsgWrite,
      'DAC mirror block exceeds configured capacity');
    Exit;
  end;
  for I := 0 to AFrameCount - 1 do
  begin
    fTimes[I] := fNextTime + I / fConfig.SampleRateHz;
    fValues[I] := ABuffer[I];
  end;
  fRegistry.AddBlockSamples(fTag, fTimes, fValues, AFrameCount, True);
  fRegistry.PublishBlockNotifications(fTag, fTimes, fValues, AFrameCount);
  fNextTime := fNextTime + AFrameCount / fConfig.SampleRateHz;
  AResult := RecorderDacOk;
end;

end.
