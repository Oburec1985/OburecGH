unit uRecorderAcquisitionTypes;

{
  Форматы отсчётов на пути драйвер → источник данных → тег.

  TRecorderAcquisitionBlock — Lazarus: все каналы в одном пакете Values[channel][sample].

  TRecorderTagFrameBlock / TRecorderChanDataDesc — как в оригинальном Recorder:
    mr/iface/tgframe.h (tagFRAME), devapi/Types.h (TChanDataDesc, TChanDataDescArray),
    Mebius IDataPipeOut::PutBlock — один канал, непрерывный буфер из N отсчётов.
}

{$mode objfpc}{$H+}

interface

type
  // Lazarus: мультиканальный пакет одного ReadBlock (MIC-140 TCP → декоммутация).
  TRecorderAcquisitionBlock = record
    // Число логических каналов в пакете (AIn и т.п.).
    ChannelCount: Integer;
    // Число отсчётов на канал в этом пакете (строк FIFO за один ReadBlock).
    SampleCount: Integer;
    // Время первого отсчёта пакета, с — шкала прибора/скана.
    FirstTimeSec: Double;
    // Частота дискретизации каналов пакета, Гц.
    SampleRateHz: Double;
    // Сырые/инженерные значения [канал][отсчёт] до тарировки тега.
    Values: array of array of Double;
  end;

  {
    Один слот FIFO тега — аналог tagFRAME / FRAME (mr/iface/tgframe.h).
    Один канал, непрерывный буфер из SampleCount отсчётов.
  }
  TRecorderTagFrameBlock = record
    // Длина блока: число отсчётов в Samples[] и TarredSamples[] (аналог m_dwFrameSize).
    SampleCount: Integer;
    // Сырые отсчёты канала подряд (аналог FRAME.pData); коды АЦП или double до тарировки.
    Samples: array of Double;
    // Тарированные значения float (аналог FRAME.pTaredData); пустой, если IsTarred=False.
    TarredSamples: array of Single;
    // Время первого отсчёта блока по шкале прибора (аналог FRAME.dblTimeDevice).
    TimeDeviceSec: Double;
    // Время первого отсчёта по UTC/ПК (аналог FRAME.dblTimeUTS).
    TimeUtsSec: Double;
    // Флаги качества/состояния буфера (аналог FRAME.dwBlockState, см. datastat.h). }
    BlockState: Cardinal;
    // True, если TarredSamples[] заполнен тарировщиком (аналог FRAME.isTared). }
    IsTarred: Boolean;
    // Частота канала при формировании кадра, Гц (аналог FRAME.freq). }
    SampleRateHz: Double;
    // Режим пакетного канала: смещение/разметка пакетов в pData (аналог FRAME.isPacketMode). }
    IsPacketMode: Boolean;
  end;

  PRecorderTagFrameBlock = ^TRecorderTagFrameBlock;

  {
    Описатель одного готового канала — аналог TChanDataDesc (devapi/Types.h).
    Frame^ заменяет пару buf (→ pData) и bufinfo (→ FRAME).
  }
  TRecorderChanDataDesc = record
    // Индекс канала в пакете скана (0..ChannelCount-1).
    ChannelIndex: Integer;
    // Указатель на тег/канал-приёмник (аналог TChanDataDesc.handle / CMeasurementTag*)
    TagRef: Pointer;
    // Кадр с отсчётами канала; Samples[] — тот же буфер, что пишет PutBlock/Handler.
    Frame: PRecorderTagFrameBlock;
    // Состояние данных в буфере (аналог TChanDataDesc.bufstate, DATAST_*).
    BufState: Cardinal;
  end;

  { Пакет готовых каналов за один тик скана — аналог TChanDataDescArray. }
  TRecorderChanDataDescBatch = record
    // Число заполненных элементов Items[].
    Count: Integer;
    // По одному дескриптору на каждый канал, готовый к OnProcessData / публикации в тег.
    Items: array of TRecorderChanDataDesc;
  end;

  { Упрощённый аналог THandlerEvent — метаданные эпохи скана для всего пакета. }
  TRecorderScanHandlerEvent = record
    { Состояние скана/ошибки (аналог THandlerEvent.state). }
    State: Cardinal;
    { Тип задачи сканирования (аналог THandlerEvent.scan_type). }
    ScanType: Cardinal;
    { Размер полезной нагрузки буфера в байтах (аналог THandlerEvent.size_buf). }
    BufByteSize: Cardinal;
    { Локальное время блока по шкале прибора, с (аналог THandlerEvent.time_loc). }
    TimeLocSec: Double;
    { Время блока UTC, с (аналог THandlerEvent.time_uts). }
    TimeUtsSec: Double;
    { Счётчик потерянных буферов с прошлого вызова (аналог count_lost_buf). }
    LostBufferCount: Cardinal;
    { Время начала первого потерянного буфера (аналог time_loc_begin_lost). }
    TimeLocBeginLostSec: Double;
    { Имя скана для диагностики (аналог scan_name). }
    ScanName: string;
  end;

  TRecorderTagFrameBlockPtrArray = array of PRecorderTagFrameBlock;

procedure ClearRecorderAcquisitionBlock(var ABlock: TRecorderAcquisitionBlock);
procedure CopyRecorderAcquisitionBlock(const ASource: TRecorderAcquisitionBlock;
  var ADest: TRecorderAcquisitionBlock);

procedure ClearRecorderTagFrameBlock(var AFrame: TRecorderTagFrameBlock);
procedure CopyRecorderTagFrameBlock(const ASource: TRecorderTagFrameBlock;
  var ADest: TRecorderTagFrameBlock);

procedure ClearRecorderChanDataDesc(var ADesc: TRecorderChanDataDesc);
procedure ClearRecorderChanDataDescBatch(var ABatch: TRecorderChanDataDescBatch);
procedure CopyRecorderChanDataDescBatch(const ASource: TRecorderChanDataDescBatch;
  var ADest: TRecorderChanDataDescBatch);

{
  Разложить Lazarus-пакет в поканальные кадры (как после Scan::Handle / PutBlock).
  Для каждого канала выделяется TRecorderTagFrameBlock; указатели записываются в Items.
  AOwnedFrames принимает владение массивом кадров — освободить через
  FreeRecorderChanDataDescBatchFrames.
}
procedure AcquisitionBlockToChanDescBatch(const ABlock: TRecorderAcquisitionBlock;
  var ABatch: TRecorderChanDataDescBatch;
  var AOwnedFrames: TRecorderTagFrameBlockPtrArray);
procedure FreeRecorderChanDataDescBatchFrames(var AOwnedFrames: TRecorderTagFrameBlockPtrArray);
procedure ClearRecorderChanDataDescBatchAndFrames(var ABatch: TRecorderChanDataDescBatch;
  var AOwnedFrames: TRecorderTagFrameBlockPtrArray);

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

procedure ClearRecorderTagFrameBlock(var AFrame: TRecorderTagFrameBlock);
begin
  AFrame.SampleCount := 0;
  SetLength(AFrame.Samples, 0);
  SetLength(AFrame.TarredSamples, 0);
  AFrame.TimeDeviceSec := 0;
  AFrame.TimeUtsSec := 0;
  AFrame.BlockState := 0;
  AFrame.IsTarred := False;
  AFrame.SampleRateHz := 0;
  AFrame.IsPacketMode := False;
end;

procedure CopyRecorderTagFrameBlock(const ASource: TRecorderTagFrameBlock;
  var ADest: TRecorderTagFrameBlock);
begin
  ADest.SampleCount := ASource.SampleCount;
  ADest.TimeDeviceSec := ASource.TimeDeviceSec;
  ADest.TimeUtsSec := ASource.TimeUtsSec;
  ADest.BlockState := ASource.BlockState;
  ADest.IsTarred := ASource.IsTarred;
  ADest.SampleRateHz := ASource.SampleRateHz;
  ADest.IsPacketMode := ASource.IsPacketMode;

  SetLength(ADest.Samples, ASource.SampleCount);
  if ASource.SampleCount > 0 then
    Move(ASource.Samples[0], ADest.Samples[0],
      ASource.SampleCount * SizeOf(Double));

  if ASource.IsTarred and (ASource.SampleCount > 0) then
  begin
    SetLength(ADest.TarredSamples, ASource.SampleCount);
    Move(ASource.TarredSamples[0], ADest.TarredSamples[0],
      ASource.SampleCount * SizeOf(Single));
  end
  else
    SetLength(ADest.TarredSamples, 0);
end;

procedure ClearRecorderChanDataDesc(var ADesc: TRecorderChanDataDesc);
begin
  ADesc.ChannelIndex := -1;
  ADesc.TagRef := nil;
  ADesc.Frame := nil;
  ADesc.BufState := 0;
end;

procedure ClearRecorderChanDataDescBatch(var ABatch: TRecorderChanDataDescBatch);
var
  I: Integer;
begin
  ABatch.Count := 0;
  for I := 0 to High(ABatch.Items) do
    ClearRecorderChanDataDesc(ABatch.Items[I]);
  SetLength(ABatch.Items, 0);
end;

procedure CopyRecorderChanDataDescBatch(const ASource: TRecorderChanDataDescBatch;
  var ADest: TRecorderChanDataDescBatch);
var
  I: Integer;
  lFrame: PRecorderTagFrameBlock;
begin
  ClearRecorderChanDataDescBatch(ADest);
  ADest.Count := ASource.Count;
  SetLength(ADest.Items, ASource.Count);
  for I := 0 to ASource.Count - 1 do
  begin
    ADest.Items[I].ChannelIndex := ASource.Items[I].ChannelIndex;
    ADest.Items[I].TagRef := ASource.Items[I].TagRef;
    ADest.Items[I].BufState := ASource.Items[I].BufState;
    if ASource.Items[I].Frame <> nil then
    begin
      New(lFrame);
      CopyRecorderTagFrameBlock(ASource.Items[I].Frame^, lFrame^);
      ADest.Items[I].Frame := lFrame;
    end
    else
      ADest.Items[I].Frame := nil;
  end;
end;

procedure FreeRecorderChanDataDescBatchFrames(
  var AOwnedFrames: TRecorderTagFrameBlockPtrArray);
var
  I: Integer;
begin
  for I := 0 to High(AOwnedFrames) do
  begin
    if AOwnedFrames[I] <> nil then
    begin
      ClearRecorderTagFrameBlock(AOwnedFrames[I]^);
      Dispose(AOwnedFrames[I]);
      AOwnedFrames[I] := nil;
    end;
  end;
  SetLength(AOwnedFrames, 0);
end;

procedure ClearRecorderChanDataDescBatchAndFrames(var ABatch: TRecorderChanDataDescBatch;
  var AOwnedFrames: TRecorderTagFrameBlockPtrArray);
begin
  ClearRecorderChanDataDescBatch(ABatch);
  FreeRecorderChanDataDescBatchFrames(AOwnedFrames);
end;

procedure AcquisitionBlockToChanDescBatch(const ABlock: TRecorderAcquisitionBlock;
  var ABatch: TRecorderChanDataDescBatch;
  var AOwnedFrames: TRecorderTagFrameBlockPtrArray);
var
  I, J: Integer;
  lFrame: PRecorderTagFrameBlock;
begin
  ClearRecorderChanDataDescBatchAndFrames(ABatch, AOwnedFrames);

  if (ABlock.ChannelCount <= 0) or (ABlock.SampleCount <= 0) then
    Exit;

  ABatch.Count := ABlock.ChannelCount;
  SetLength(ABatch.Items, ABlock.ChannelCount);
  SetLength(AOwnedFrames, ABlock.ChannelCount);

  for I := 0 to ABlock.ChannelCount - 1 do
  begin
    New(lFrame);
    AOwnedFrames[I] := lFrame;
    lFrame^.SampleCount := ABlock.SampleCount;
    lFrame^.TimeDeviceSec := ABlock.FirstTimeSec;
    lFrame^.TimeUtsSec := ABlock.FirstTimeSec;
    lFrame^.BlockState := 0;
    lFrame^.IsTarred := False;
    lFrame^.SampleRateHz := ABlock.SampleRateHz;
    lFrame^.IsPacketMode := False;

    SetLength(lFrame^.Samples, ABlock.SampleCount);
    if (I <= High(ABlock.Values)) and (Length(ABlock.Values[I]) >= ABlock.SampleCount) then
    begin
      for J := 0 to ABlock.SampleCount - 1 do
        lFrame^.Samples[J] := ABlock.Values[I][J];
    end
    else
      for J := 0 to ABlock.SampleCount - 1 do
        lFrame^.Samples[J] := 0;

    ABatch.Items[I].ChannelIndex := I;
    ABatch.Items[I].TagRef := nil;
    ABatch.Items[I].Frame := lFrame;
    ABatch.Items[I].BufState := 0;
  end;
end;

end.
