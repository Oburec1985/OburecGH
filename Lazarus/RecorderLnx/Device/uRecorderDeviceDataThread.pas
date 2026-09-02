unit uRecorderDeviceDataThread;

{
  Универсальный поток сбора данных с приборов (Lazarus/RecorderLnx).
  Не привязан к конкретному протоколу конкретного прибора.
  
  Реализует:
  - Предварительное выделение памяти (в Config) во избежание аллокаций в RunTime.
  - Управление состоянием (Play/Stop) строго изнутри потока.
  - Кольцевой буфер блоков данных защищен критической секцией.
}

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, SyncObjs, uRecorderAcquisitionTypes;

type
  TDataThreadState = (dtsIdle, dtsStarting, dtsPlaying, dtsStopping);

  PRecorderAcquisitionBlock = ^TRecorderAcquisitionBlock;

  { Borrowed immutable view of one ring slot. Block remains valid until the
    same consumer calls ReleaseReadBlock. }
  TRecorderAcquisitionBlockLease = record
    Block: PRecorderAcquisitionBlock;
    SlotIndex: Integer;
    Generation: QWord;
  end;

  TRecorderRingSlotState = (rssEmpty, rssReady, rssReading);

  { Callback для передачи прочитанного блока данных. Вызывается в контексте потока. }
  TDataThreadBlockCallback = procedure(const ABlock: TRecorderAcquisitionBlock) of object;

  TRecorderDeviceDataThread = class(TThread)
  private
    fState: TDataThreadState;
    fCommandPlay: Boolean;
    fCommandStop: Boolean;
    fConfigured: Boolean;
    fCallback: TDataThreadBlockCallback;
    fLock: TCriticalSection;
    
    { Кольцевой буфер блоков }
    fBlocks: array of TRecorderAcquisitionBlock;
    fSlotStates: array of TRecorderRingSlotState;
    fSlotGenerations: array of QWord;
    fCapacity: Integer;
    fReadIndex: Integer;
    fWriteIndex: Integer;
    fBlockCount: Integer;
    
    { Запасной блок для чтения и отбрасывания при заполненном кольце. }
    fActiveBlock: TRecorderAcquisitionBlock;
    fWriteReserved: Boolean;
    fReservedWriteIndex: Integer;
    
    procedure SetState(AState: TDataThreadState);
    function ReserveWriteBlock(out ABlock: PRecorderAcquisitionBlock): Boolean;
    procedure PublishReservedBlock;
    procedure CancelReservedBlock;
  protected
    procedure PushBlock(const ABlock: TRecorderAcquisitionBlock);
    procedure Execute; override;
    
    { Разовые операции при старте и стопе (переопределяются в наследниках) }
    procedure OnStart; virtual;
    procedure OnStop; virtual;
    
    { Чтение сырых данных из прибора и заполнение ABlock.
      Должен быть переопределен в потомке. Возвращает True, если блок успешно собран. }
    function ReadBlockFromDevice(var ABlock: TRecorderAcquisitionBlock): Boolean; virtual; abstract;
    
    { Переопределяемый метод отправки (если прибору нужно что-то слать периодически) }
    procedure SendBlockToDevice; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    
    { Выделение памяти под структуры данных и буферы (вызывать из основного потока!) }
    procedure Config(AChannelCount: Integer; ASampleCount: Integer; ASampleRateHz: Double); virtual;
    
    { Команды управления (вызываются извне, только взводят флаги-команды) }
    procedure StartPlay;
    procedure StopPlay;
    
    { Чтение блока из кольцевого буфера внешним потребителем (без аллокаций) }
    function ReadBlock(out ABlock: TRecorderAcquisitionBlock): Boolean; virtual;

    { Zero-copy SPSC read. One lease may be active at a time; release is
      mandatory in a finally block. }
    function AcquireReadBlock(out ALease: TRecorderAcquisitionBlockLease): Boolean;
    procedure ReleaseReadBlock(var ALease: TRecorderAcquisitionBlockLease);
    
    { Очистка данных буферов без перевыделения памяти }
    procedure Clear; virtual;
    
    property State: TDataThreadState read fState;
    property Callback: TDataThreadBlockCallback read fCallback write fCallback;
    property Configured: Boolean read fConfigured;
  end;

implementation

{ Вспомогательная процедура копирования данных блока без перевыделения памяти, если размеры совпадают }
procedure CopyBlockData(const ASource: TRecorderAcquisitionBlock; var ADest: TRecorderAcquisitionBlock);
var
  lChan, lSamples: Integer;
  I: Integer;
begin
  ADest.ChannelCount := ASource.ChannelCount;
  ADest.SampleCount := ASource.SampleCount;
  ADest.FirstTimeSec := ASource.FirstTimeSec;
  ADest.SampleRateHz := ASource.SampleRateHz;
  
  lChan := ASource.ChannelCount;
  lSamples := ASource.SampleCount;
  
  if Length(ADest.ChannelSampleCounts) <> Length(ASource.ChannelSampleCounts) then
    ADest.ChannelSampleCounts := Copy(ASource.ChannelSampleCounts)
  else if Length(ASource.ChannelSampleCounts) > 0 then
    Move(ASource.ChannelSampleCounts[0], ADest.ChannelSampleCounts[0], Length(ASource.ChannelSampleCounts) * SizeOf(Integer));
    
  if Length(ADest.ChannelFirstTimesSec) <> Length(ASource.ChannelFirstTimesSec) then
    ADest.ChannelFirstTimesSec := Copy(ASource.ChannelFirstTimesSec)
  else if Length(ASource.ChannelFirstTimesSec) > 0 then
    Move(ASource.ChannelFirstTimesSec[0], ADest.ChannelFirstTimesSec[0], Length(ASource.ChannelFirstTimesSec) * SizeOf(Double));

  if Length(ADest.ChannelSampleRatesHz) <> Length(ASource.ChannelSampleRatesHz) then
    ADest.ChannelSampleRatesHz := Copy(ASource.ChannelSampleRatesHz)
  else if Length(ASource.ChannelSampleRatesHz) > 0 then
    Move(ASource.ChannelSampleRatesHz[0], ADest.ChannelSampleRatesHz[0], Length(ASource.ChannelSampleRatesHz) * SizeOf(Double));

  if Length(ADest.Values) <> lChan then
    SetLength(ADest.Values, lChan);
    
  for I := 0 to lChan - 1 do
  begin
    if Length(ADest.Values[I]) <> lSamples then
      SetLength(ADest.Values[I], lSamples);
    if lSamples > 0 then
      Move(ASource.Values[I][0], ADest.Values[I][0], lSamples * SizeOf(Double));
  end;
end;

constructor TRecorderDeviceDataThread.Create;
begin
  { Создаем поток в приостановленном состоянии }
  inherited Create(True);
  fState := dtsIdle;
  fCommandPlay := False;
  fCommandStop := False;
  fConfigured := False;
  fLock := TCriticalSection.Create;
  fCapacity := 32; { Емкость кольцевого буфера по умолчанию }
  fReadIndex := 0;
  fWriteIndex := 0;
  fBlockCount := 0;
  fWriteReserved := False;
  fReservedWriteIndex := -1;
end;

destructor TRecorderDeviceDataThread.Destroy;
begin
  Terminate;
  StopPlay;
  
  { Ждем завершения потока }
  inherited Destroy;
  
  Clear;
  fLock.Free;
end;

procedure TRecorderDeviceDataThread.SetState(AState: TDataThreadState);
begin
  fState := AState;
end;

procedure TRecorderDeviceDataThread.Config(AChannelCount: Integer; ASampleCount: Integer; ASampleRateHz: Double);
var
  I, J: Integer;
begin
  fLock.Acquire;
  try
    for I := 0 to Length(fSlotStates) - 1 do
      if fSlotStates[I] = rssReading then
        raise EInvalidOperation.Create(
          'Cannot configure device data ring while a read lease is active');
    fConfigured := False;
    
    { Выделяем память под кольцевой буфер блоков }
    SetLength(fBlocks, fCapacity);
    SetLength(fSlotStates, fCapacity);
    SetLength(fSlotGenerations, fCapacity);
    for I := 0 to fCapacity - 1 do
    begin
      ClearRecorderAcquisitionBlock(fBlocks[I]);
      fSlotStates[I] := rssEmpty;
      fSlotGenerations[I] := 0;
      fBlocks[I].ChannelCount := AChannelCount;
      fBlocks[I].SampleCount := ASampleCount;
      fBlocks[I].SampleRateHz := ASampleRateHz;
      SetLength(fBlocks[I].Values, AChannelCount);
      for J := 0 to AChannelCount - 1 do
        SetLength(fBlocks[I].Values[J], ASampleCount);
    end;
    
    { Выделяем память под активный рабочий блок }
    ClearRecorderAcquisitionBlock(fActiveBlock);
    fActiveBlock.ChannelCount := AChannelCount;
    fActiveBlock.SampleCount := ASampleCount;
    fActiveBlock.SampleRateHz := ASampleRateHz;
    SetLength(fActiveBlock.Values, AChannelCount);
    for J := 0 to AChannelCount - 1 do
      SetLength(fActiveBlock.Values[J], ASampleCount);
      
    fReadIndex := 0;
    fWriteIndex := 0;
    fBlockCount := 0;
    fWriteReserved := False;
    fReservedWriteIndex := -1;
    fConfigured := True;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderDeviceDataThread.StartPlay;
begin
  fCommandPlay := True;
  fCommandStop := False;
  { Запускаем выполнение потока, если он был заморожен при создании }
  if Suspended then
    Start;
end;

procedure TRecorderDeviceDataThread.StopPlay;
begin
  fCommandStop := True;
  fCommandPlay := False;
end;

procedure TRecorderDeviceDataThread.Clear;
var
  I: Integer;
begin
  fLock.Acquire;
  try
    for I := 0 to Length(fBlocks) - 1 do
      ClearRecorderAcquisitionBlock(fBlocks[I]);
    SetLength(fBlocks, 0);
    SetLength(fSlotStates, 0);
    SetLength(fSlotGenerations, 0);
    ClearRecorderAcquisitionBlock(fActiveBlock);
    fReadIndex := 0;
    fWriteIndex := 0;
    fBlockCount := 0;
    fWriteReserved := False;
    fReservedWriteIndex := -1;
    fConfigured := False;
  finally
    fLock.Release;
  end;
end;

function TRecorderDeviceDataThread.ReserveWriteBlock(
  out ABlock: PRecorderAcquisitionBlock): Boolean;
begin
  ABlock := nil;
  fLock.Acquire;
  try
    Result := (not fWriteReserved) and (fBlockCount < fCapacity) and
      (fCapacity > 0) and (fSlotStates[fWriteIndex] = rssEmpty);
    if not Result then
      Exit;
    fWriteReserved := True;
    fReservedWriteIndex := fWriteIndex;
    ABlock := @fBlocks[fReservedWriteIndex];
  finally
    fLock.Release;
  end;
end;

procedure TRecorderDeviceDataThread.PublishReservedBlock;
var
  lIndex: Integer;
begin
  fLock.Acquire;
  try
    if not fWriteReserved then
      Exit;
    lIndex := fReservedWriteIndex;
    Inc(fSlotGenerations[lIndex]);
    fSlotStates[lIndex] := rssReady;
    fWriteIndex := (lIndex + 1) mod fCapacity;
    Inc(fBlockCount);
    fWriteReserved := False;
    fReservedWriteIndex := -1;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderDeviceDataThread.CancelReservedBlock;
begin
  fLock.Acquire;
  try
    fWriteReserved := False;
    fReservedWriteIndex := -1;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderDeviceDataThread.PushBlock(
  const ABlock: TRecorderAcquisitionBlock);
var
  lDest: PRecorderAcquisitionBlock;
begin
  if not ReserveWriteBlock(lDest) then
    Exit;
  try
    CopyBlockData(ABlock, lDest^);
    if Assigned(fCallback) then
      fCallback(lDest^);
    PublishReservedBlock;
  except
    CancelReservedBlock;
    raise;
  end;
end;

function TRecorderDeviceDataThread.ReadBlock(out ABlock: TRecorderAcquisitionBlock): Boolean;
var
  lLease: TRecorderAcquisitionBlockLease;
begin
  Result := AcquireReadBlock(lLease);
  if not Result then
    Exit;
  try
    CopyBlockData(lLease.Block^, ABlock);
  finally
    ReleaseReadBlock(lLease);
  end;
end;

function TRecorderDeviceDataThread.AcquireReadBlock(
  out ALease: TRecorderAcquisitionBlockLease): Boolean;
begin
  ALease.Block := nil;
  ALease.SlotIndex := -1;
  ALease.Generation := 0;
  Result := False;
  fLock.Acquire;
  try
    if (fBlockCount <= 0) or (fSlotStates[fReadIndex] <> rssReady) then
      Exit;
    fSlotStates[fReadIndex] := rssReading;
    ALease.Block := @fBlocks[fReadIndex];
    ALease.SlotIndex := fReadIndex;
    ALease.Generation := fSlotGenerations[fReadIndex];
    Result := True;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderDeviceDataThread.ReleaseReadBlock(
  var ALease: TRecorderAcquisitionBlockLease);
var
  lIndex: Integer;
begin
  lIndex := ALease.SlotIndex;
  fLock.Acquire;
  try
    if (ALease.Block = nil) or (lIndex <> fReadIndex) or
      (lIndex < 0) or (lIndex >= fCapacity) or
      (fSlotStates[lIndex] <> rssReading) or
      (fSlotGenerations[lIndex] <> ALease.Generation) then
      Exit;
    fSlotStates[lIndex] := rssEmpty;
    fReadIndex := (lIndex + 1) mod fCapacity;
    Dec(fBlockCount);
  finally
    fLock.Release;
    ALease.Block := nil;
    ALease.SlotIndex := -1;
    ALease.Generation := 0;
  end;
end;

procedure TRecorderDeviceDataThread.SendBlockToDevice;
begin
  { По умолчанию ничего не делаем }
end;

procedure TRecorderDeviceDataThread.OnStart;
begin
  { Переопределяется в потомках }
end;

procedure TRecorderDeviceDataThread.OnStop;
begin
  { Переопределяется в потомках }
end;

procedure TRecorderDeviceDataThread.Execute;
var
  I: Integer;
  lWriteBlock: PRecorderAcquisitionBlock;
begin
  while not Terminated do
  begin
    case fState of
      dtsIdle:
        begin
          if fCommandPlay and fConfigured then
          begin
            fCommandPlay := False;
            SetState(dtsStarting);
          end
          else
            Sleep(20);
        end;
        
      dtsStarting:
        begin
          try
            OnStart;
            SetState(dtsPlaying);
          except
            on E: Exception do
            begin
              { В случае ошибки старта возвращаемся в Idle }
              fCommandPlay := False;
              SetState(dtsIdle);
            end;
          end;
        end;
        
      dtsPlaying:
        begin
          if fCommandStop or Terminated then
          begin
            fCommandStop := False;
            SetState(dtsStopping);
          end
          else
          begin
            try
              { Producer fills an empty ring slot directly. When the bounded
                ring is full, the device is still drained into preallocated
                scratch and that newest block is deliberately dropped. }
              if ReserveWriteBlock(lWriteBlock) then
              begin
                try
                  if ReadBlockFromDevice(lWriteBlock^) then
                  begin
                    if Assigned(fCallback) then
                      fCallback(lWriteBlock^);
                    PublishReservedBlock;
                  end
                  else
                    CancelReservedBlock;
                except
                  CancelReservedBlock;
                  raise;
                end;
              end
              else
                ReadBlockFromDevice(fActiveBlock);
                
              SendBlockToDevice;
            except
              on E: Exception do
              begin
                { При возникновении ошибки связи можно остановить скан }
                SetState(dtsStopping);
              end;
            end;
            
            { Небольшая пауза, чтобы не забивать процессор, если ReadBlockFromDevice вернул False }
            Sleep(1);
          end;
        end;
        
      dtsStopping:
        begin
          try
            OnStop;
          finally
            fLock.Acquire;
            try
              for I := 0 to Length(fSlotStates) - 1 do
                fSlotStates[I] := rssEmpty;
              fReadIndex := 0;
              fWriteIndex := 0;
              fBlockCount := 0;
              fWriteReserved := False;
              fReservedWriteIndex := -1;
            finally
              fLock.Release;
            end;
            SetState(dtsIdle);
          end;
        end;
    end;
  end;
  
  { Если поток завершается во время работы, принудительно вызываем OnStop }
  if (fState = dtsPlaying) or (fState = dtsStarting) then
  begin
    try
      OnStop;
    except
      { Игнорируем ошибки при деструкции }
    end;
  end;
end;

end.
