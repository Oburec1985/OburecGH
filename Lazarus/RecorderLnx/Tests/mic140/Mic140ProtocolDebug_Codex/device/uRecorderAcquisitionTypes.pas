unit uRecorderAcquisitionTypes;

{
  Формат блока отсчётов: драйвер → источник данных → тег.
  TRecorderAcquisitionBlock — все каналы в одном пакете Values[channel][sample].
}

{$mode objfpc}{$H+}

interface

type
  TRecorderAcquisitionBlock = record
    ChannelCount: Integer;
    SampleCount: Integer;
    FirstTimeSec: Double;
    SampleRateHz: Double;
    Values: array of array of Double;
  end;

procedure ClearRecorderAcquisitionBlock(var ABlock: TRecorderAcquisitionBlock);
procedure CopyRecorderAcquisitionBlock(const ASource: TRecorderAcquisitionBlock;
  var ADest: TRecorderAcquisitionBlock);

implementation

procedure ClearRecorderAcquisitionBlock(var ABlock: TRecorderAcquisitionBlock);
begin
  ABlock.ChannelCount := 0;
  ABlock.SampleCount := 0;
  ABlock.FirstTimeSec := 0;
  ABlock.SampleRateHz := 0;
  SetLength(ABlock.Values, 0);
end;

procedure CopyRecorderAcquisitionBlock(const ASource: TRecorderAcquisitionBlock;
  var ADest: TRecorderAcquisitionBlock);
var
  I, N: Integer;
begin
  ADest.ChannelCount := ASource.ChannelCount;
  ADest.SampleCount := ASource.SampleCount;
  ADest.FirstTimeSec := ASource.FirstTimeSec;
  ADest.SampleRateHz := ASource.SampleRateHz;
  N := ASource.SampleCount;
  SetLength(ADest.Values, ASource.ChannelCount);
  for I := 0 to ASource.ChannelCount - 1 do
  begin
    SetLength(ADest.Values[I], N);
    if N > 0 then
      Move(ASource.Values[I][0], ADest.Values[I][0], N * SizeOf(Double));
  end;
end;

end.
