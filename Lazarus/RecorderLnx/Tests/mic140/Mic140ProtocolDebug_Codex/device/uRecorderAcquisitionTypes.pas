unit uRecorderAcquisitionTypes;

{
  Универсальный блок отсчётов захвата.

  Формат передачи отсчётов от драйвера прибора к источнику данных.
  Особенности MIC-140 (TIn, CJC) остаются в драйвере; в тегах TIn — обычные каналы.
}

{$mode objfpc}{$H+}

interface

type
  TRecorderAcquisitionBlock = record
    ChannelCount: Integer;
    SampleCount: Integer;
    FirstTimeSec: Double;
    SampleRateHz: Double;
    { Values[channel][sample] — коды или физические величины до тарировки тега. }
    Values: array of array of Double;
  end;

procedure ClearRecorderAcquisitionBlock(var ABlock: TRecorderAcquisitionBlock);
{
  Глубокое копирование блока для передачи между потоками (чтение → публикация).

  Скалярные поля копируются присвоением. Массивы отсчётов — отдельными буферами:
  присвоение записи с dynamic array дало бы общий буфер, а исходный блок в потоке
  чтения сразу перезаписывается следующим кадром. Для тел отсчётов используется Move
  (копирование байт), а не «перенос» владения — оба блока должны существовать независимо.
}
procedure CopyRecorderAcquisitionBlock(const ASource: TRecorderAcquisitionBlock;
  var ADest: TRecorderAcquisitionBlock);
implementation

procedure CopyRecorderAcquisitionBlock(const ASource: TRecorderAcquisitionBlock;
  var ADest: TRecorderAcquisitionBlock);
var
  I: Integer;
  lSampleCount: Integer;
begin
  ADest.ChannelCount := ASource.ChannelCount;
  ADest.SampleCount := ASource.SampleCount;
  ADest.FirstTimeSec := ASource.FirstTimeSec;
  ADest.SampleRateHz := ASource.SampleRateHz;

  SetLength(ADest.Values, ASource.ChannelCount);
  lSampleCount := ASource.SampleCount;
  for I := 0 to ASource.ChannelCount - 1 do
  begin
    SetLength(ADest.Values[I], lSampleCount);
    if lSampleCount > 0 then
      Move(ASource.Values[I][0], ADest.Values[I][0],
        lSampleCount * SizeOf(Double));
  end;
end;

procedure ClearRecorderAcquisitionBlock(var ABlock: TRecorderAcquisitionBlock);
begin
  ABlock.ChannelCount := 0;
  ABlock.SampleCount := 0;
  ABlock.FirstTimeSec := 0;
  ABlock.SampleRateHz := 0;
  SetLength(ABlock.Values, 0);
end;

end.
