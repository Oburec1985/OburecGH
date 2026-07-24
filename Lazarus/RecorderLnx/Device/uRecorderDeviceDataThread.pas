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

interface

uses
  Classes, SysUtils, SyncObjs, uRecorderAcquisitionTypes;

type
  TDataThreadState = (dtsIdle, dtsStarting, dtsPlaying, dtsStopping);

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
    fCapacity: Integer;
    fReadIndex: Integer;
    fWriteIndex: Integer;
    fBlockCount: Integer;
    
    { Активный блок для накопления в RunTime (выделен заранее) }
    fActiveBlock: TRecorderAcquisitionBlock;
    
    procedure SetState(AState: TDataThreadState);
    procedure PushBlock(const ABlock: TRecorderAcquisitionBlock);
  protected
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
    fConfigured := False;
    
    { Выделяем память под кольцевой буфер блоков }
    SetLength(fBlocks, fCapacity);
    for I := 0 to fCapacity - 1 do
    begin
      ClearRecorderAcquisitionBlock(fBlocks[I]);
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
    ClearRecorderAcquisitionBlock(fActiveBlock);
    fReadIndex := 0;
    fWriteIndex := 0;
    fBlockCount := 0;
    fConfigured := False;
  finally
    fLock.Release;
  end;
end;

procedure TRecorderDeviceDataThread.PushBlock(const ABlock: TRecorderAcquisitionBlock);
begin
  fLock.Acquire;
  try
    if fCapacity <= 0 then Exit;
    
    { Копируем данные без перевыделения памяти }
    CopyBlockData(ABlock, fBlocks[fWriteIndex]);
    
    fWriteIndex := (fWriteIndex + 1) mod fCapacity;
    if fBlockCount < fCapacity then
      Inc(fBlockCount)
    else
      fReadIndex := (fReadIndex + 1) mod fCapacity; { Буфер переполнен, сдвигаем индекс чтения }
  finally
    fLock.Release;
  end;
  
  { Вызываем Callback, если он зарегистрирован }
  if Assigned(fCallback) then
    fCallback(ABlock);
end;

function TRecorderDeviceDataThread.ReadBlock(out ABlock: TRecorderAcquisitionBlock): Boolean;
begin
  Result := False;
  fLock.Acquire;
  try
    if fBlockCount > 0 then
    begin
      { Глубокое копирование блока для внешнего потребителя }
      CopyRecorderAcquisitionBlock(fBlocks[fReadIndex], ABlock);
      fReadIndex := (fReadIndex + 1) mod fCapacity;
      Dec(fBlockCount);
      Result := True;
    end;
  finally
    fLock.Release;
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
              { Опрашиваем прибор и пишем в преаллоцированный fActiveBlock }
              if ReadBlockFromDevice(fActiveBlock) then
                PushBlock(fActiveBlock);
                
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
              fReadIndex := 0;
              fWriteIndex := 0;
              fBlockCount := 0;
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
