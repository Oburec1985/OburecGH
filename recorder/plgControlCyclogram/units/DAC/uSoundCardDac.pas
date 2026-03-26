unit uSoundCardDac;
{******************************************************************************
 * Модуль реализации ЦАП на базе звуковой карты (uSoundCardDac.pas)
 *------------------------------------------------------------------------------
 * Назначение:
 *   Конкретная реализация TDacDevice поверх Windows waveOut API.
 *
 * Примечания:
 *   - Буферы подготавливаются через WAVEHDR и отправляются через waveOutWrite.
 *   - Сообщение WOM_DONE возвращает проигранный буфер обратно в нашу очередь.
 *   - Callback драйвера выполняется не в основном GUI-потоке.
 ******************************************************************************}
interface
uses
  Classes, Windows, MMSystem, uDacDevice, sysutils, SyncObjs,
  ucommonTypes,
  ulogfile
  ;
const
  WHDR_LOOP = $00000008; // Флаг зацикливания; может отсутствовать в старых SDK

type
  
  PSoundCardBlock = ^TSoundCardBlock;
  TSoundCardBlock = record
    Samples: tsmallintarray; // Буфер аудиосэмплов
    ValidBytes: Integer;   // Полезная длина буфера для отправки в драйвер
    Header: TWaveHdr;   // WAVE-заголовок для WinAPI
  end;

  TSoundCardDac = class(TDacDevice)
  private
    // Дескриптор устройства waveOut
    FDeviceHandle: HWAVEOUT;
    // Число циклов; 0 означает бесконечное воспроизведение
    FCurrentLoopCount: Cardinal;
    // Сколько буферов сейчас стоит в очереди драйвера
    FQueuedBuffers: Integer;

    // Внутренний обработчик callback-сообщений драйвера
    procedure WaveOutCallback(hwo: HWAVEOUT; uMsg: UINT; dwInstance: DWORD;
      dwParam1: DWORD; dwParam2: DWORD);

    // Сбросить все заголовки и состояние блоков
    procedure ResetAllBuffers;
    
    function AllocateBlock: Pointer; override;
    procedure FreeBlock(ABlock: Pointer); override;
  public
    constructor Create;
    destructor Destroy; override;

    // Открыть устройство waveOut
    function Open:cardinal;override;
    // Закрыть устройство и освободить буферы
    procedure Close; override;
    // Установить параметры и запустить воспроизведение
    procedure Start(ALoopCount: Cardinal = 1); override;
    // Остановить воспроизведение
    procedure Stop(AGraceful: Boolean = True); override;
    // Отправить следующий блок в waveOut
    function QueueBuffer:PBlockData; override;
    // Проверка состояния воспроизведения
    function IsPlay: Boolean; override;
    function GetDeviceList: TStringList; override;
    // Перевыделить буферы с новым размером
    procedure ReallocateBuffers(NewSize: Integer); override;
  end;
implementation
// Статическая callback-функция, передаваемая в WinAPI
procedure WaveOutProc(hwo: HWAVEOUT; uMsg: UINT;
                      dwInstance: DWORD;
                      dwParam1: DWORD; dwParam2: DWORD);stdcall;
var
  Instance: TSoundCardDac;
begin
  Instance := TSoundCardDac(dwInstance);
  if Instance <> nil then
    Instance.WaveOutCallback(hwo, uMsg, dwInstance, dwParam1, dwParam2);
end;
{ TSoundCardDac }
constructor TSoundCardDac.Create;
begin
  inherited Create;
  FDeviceHandle := 0;
end;
destructor TSoundCardDac.Destroy;
begin
  Close;
  inherited;
end;
procedure TSoundCardDac.ResetAllBuffers;
var
  i: Integer;
  Block: PSoundCardBlock;
begin
  // Проходим по всем блокам и делаем unprepare + сбрасываем флаги
  EnterCs;
  try
    for i := 0 to FBlockQueue.MaxBlocks - 1 do
    begin
      if FBlockQueue.GetBlockData(i).Data <> nil then
      begin
        Block := PSoundCardBlock(FBlockQueue.GetBlockData(i).Data);
        // Делаем unprepare, если буфер подготовлен
        if (Block.Header.dwFlags and WHDR_PREPARED) <> 0 then
        begin
          waveOutUnprepareHeader(FDeviceHandle, @Block.Header, SizeOf(TWaveHdr));
        end;
        // Сбрасываем флаги, dwLoops и полезную длину буфера
        Block.Header.dwFlags := 0;
        Block.Header.dwLoops := 0;
        Block.ValidBytes := 0;
      end;
    end;
  finally
    ExitCs;
  end;
end;
function TSoundCardDac.AllocateBlock: Pointer;
var
  Block: PSoundCardBlock;
  p:PSmallIntArray;
begin
  
  New(Block);
  // Обнуляем запись, чтобы не было мусора
  FillChar(Block^, SizeOf(TSoundCardBlock), 0);
  // Выделяем память под буфер аудиоданных.
  // FBufferSize должен быть рассчитан в методе Open.
  if BufferSize > 0 then
  begin
    setlength(Block^.Samples, BufferSize shr 1);
  end;
  Result := Block;
end;
procedure TSoundCardDac.FreeBlock(ABlock: Pointer);
var
  Block: PSoundCardBlock;
begin
  if ABlock = nil then
    Exit;
  Block := PSoundCardBlock(ABlock);
  // Освобождаем буфер аудиоданных
  if Block^.Samples <> nil then
  begin
    SetLength(Block.Samples, 0);
  end;
end;
function TSoundCardDac.Open:cardinal;
var
  wfx: TWaveFormatEx;
  i: Integer;
  ResultCode: MMRESULT;
  block: Pointer;
  blockdata:PBlockData;
begin
  if FState=stClosed then
  begin
    
    FillChar(wfx, SizeOf(wfx), 0);
    wfx.wFormatTag      := WAVE_FORMAT_PCM; // Формат: импульсно-кодовая модуляция (стандартный)
    wfx.nChannels       := Channels;        // Количество каналов (1 - моно, 2 - стерео)
    wfx.nSamplesPerSec  := SampleRate;      // Частота дискретизации (сэмплов в секунду)
    wfx.wBitsPerSample  := BitsPerSample;     // Разрядность сэмпла (8, 16, ...)
    wfx.nBlockAlign     := (wfx.nChannels * wfx.wBitsPerSample) div 8; // Размер одного блока во всех каналах
    wfx.nAvgBytesPerSec := wfx.nSamplesPerSec * wfx.nBlockAlign;      // Скорость потока в байтах в секунду
    wfx.cbSize          := 0;               // Дополнительные байты не используются для PCM
    // 2. Открытие устройства вывода звука через waveOutOpen
    ResultCode := waveOutOpen(
      @FDeviceHandle,     // Указатель на дескриптор устройства
      UINT_PTR(DeviceID), // Идентификатор устройства или WAVE_MAPPER
      @wfx,               // Параметры формата звука
      DWORD_PTR(@WaveOutProc),// Callback-функция драйвера
      DWORD_PTR(Self),    // Пользовательские данные для callback
      CALLBACK_FUNCTION   // Тип callback: функция
    );
    if ResultCode <> MMSYSERR_NOERROR then
      raise Exception.Create('Error opening waveOut device: ' + IntToStr(ResultCode));
    // 3. Расчет размера буфера в байтах
    CalculateBufferSize;
    // 4. Очищаем очередь и выделяем новые блоки
    // Освобождаем старые буферы, если они есть
    FreeAllBlocks;
    // 5. Выделение и инициализация блоков данных
    for i := 0 to NUM_BUFFERS - 1 do
    begin
      blockdata:=FBlockQueue.GetBlockData(i);
      // Выделяем память для блока
      blockdata.Data:= AllocateBlock;
    end;
    FCurrentLoopCount := 1; // По умолчанию однократное воспроизведение
  end;
  // Очищаем очередь (сброс индексов)
  ClearBlocks;
  // Сбрасываем счетчики и флаги
  FQueuedBuffers := 0;
  FState:= stOpened;
end;
//function TSoundCardDac.CheckDone(i: integer): boolean;
//var

//begin
//end;
procedure TSoundCardDac.Close;
begin
  //logMessage('Close BEGIN FQueuedBuffers='+inttostr(FQueuedBuffers));
  EnterCs;
  if FDeviceHandle <> 0 then
  begin
    // Reset устройства блокирует до возврата всех буферов
    waveOutReset(FDeviceHandle);
    // Проходим по всем блокам и делаем unprepare + сбрасываем флаги
    ResetAllBuffers;
    //logMessage('Close AFTER waveOutReset');
    // Now that all buffers are returned, we can close the device.
    waveOutClose(FDeviceHandle);
    FDeviceHandle := 0;
  end;
  // Сбрасываем счетчик
  FQueuedBuffers := 0;
  // Сбрасываем признак работы
  State:=stClosed;
  // Освобождаем память всех блоков
  FreeAllBlocks;
  // Очищаем очередь (сброс индексов)
  ClearBlocks;
  ExitCs;
  //logMessage('Close END');
end;
procedure TSoundCardDac.Start(ALoopCount: Cardinal = 1);
var
  i: Integer;
begin
  //logMessage('Start: BEGIN, FCurrentLoopCount='+inttostr(FCurrentLoopCount));
  FCurrentLoopCount := ALoopCount;
  //logMessage('Start: after inherited, FCurrentLoopCount='+inttostr(FCurrentLoopCount));
  // Предварительно заполняем очередь буферами для бесшовного воспроизведения
  // Это гарантирует, что в драйвере уже есть готовые буферы
  for i := 0 to 1 do // Заполняем два буфера заранее
  begin
    //logMessage('Start: calling FOnGenerateData #'+inttostr(i));
    
    if Assigned(OnBufferEnd) then
      OnBufferEnd(nil, 0);
  end;
  // Start вызываем в конце, после подготовки буферов
  inherited Start(ALoopCount);
end;
procedure TSoundCardDac.Stop(AGraceful: Boolean = True);
begin
  //logMessage('Stop: BEGIN, state='+inttostr(integer(State)));
  inherited Stop(AGraceful);
  //logMessage('Stop: after inherited, state='+inttostr(integer(State)));
  if state<>stplay then Exit;
  // Если остановка мгновенная, сбрасываем все буферы
  if not AGraceful then
  begin
    //logMessage('Stop: calling waveOutReset');
    // waveOutReset блокирует до возврата всех буферов
    waveOutReset(FDeviceHandle);
    // Проходим по всем блокам и делаем unprepare + сбрасываем флаги
    ResetAllBuffers;
    //logMessage('Stop: AFTER waveOutReset');
  end;
end;
function TSoundCardDac.QueueBuffer:PBlockData;
var
  ResultCode: MMRESULT;
  Block: PSoundCardBlock;
  p:pointer;
  lBlockData: pBlockData;
  i:integer;
begin
  EnterCs;
  try
  // Проверяем состояние: если не играем, выходим
  if state<>stplay then Exit;
  // Не ставим в очередь больше NUM_BUFFERS
  // Это защищает от переполнения очереди
  if FQueuedBuffers >= NUM_BUFFERS then
  begin
    exit;
  end;
    lBlockData:=FBlockQueue.PopBlock;
    result:=lBlockData;
    if lBlockData<>nil then
    Block:=lBlockData.Data;
    // Готовим заголовок
    Block.Header.lpData := @Block.Samples[0];
    if (Block.ValidBytes > 0) and (Block.ValidBytes <= Integer(BufferSize)) then
      Block.Header.dwBufferLength := Block.ValidBytes
    else
      Block.Header.dwBufferLength := BufferSize;
    Block.Header.dwUser := DWORD_PTR(Block); // Сохраняем указатель на наш блок
    // dwFlags и dwLoops уже обнулены через FillChar
    // Сначала выполняем prepare
    ResultCode := waveOutPrepareHeader(FDeviceHandle, @Block.Header, SizeOf(TWaveHdr));
    if ResultCode <> MMSYSERR_NOERROR then
      raise Exception.Create('Error preparing waveOut header: ' + IntToStr(ResultCode));
    // Логику зацикливания задаем после prepare
    if FCurrentLoopCount = 0 then // 0 считаем признаком бесконечного цикла
    begin
      Block.Header.dwLoops := MAXDWORD; // Для WinAPI бесконечный цикл задается через MAXDWORD
      Block.Header.dwFlags := WHDR_BEGINLOOP or WHDR_ENDLOOP or WHDR_LOOP;
    end
    else
    begin
      Block.Header.dwLoops := FCurrentLoopCount; // Проигрываем заданное число раз
      // dwFlags оставляем нулевым для однократного воспроизведения
    end;
    // Отправляем буфер на воспроизведение. После waveOutWrite менять его нельзя
    // В очереди может стоять несколько буферов
    //logMessage('Flags='+inttostr(Block.Header.dwFlags));
    ResultCode := waveOutWrite(FDeviceHandle, @Block.Header, SizeOf(TWaveHdr));
    i:=integer(GetBlockIndex(Block));
    if ResultCode <> MMSYSERR_NOERROR then
    begin
      //logMessage('Error writing to waveOut: ind='+inttostr(i)+' FQueuedBuffers='+inttostr(FQueuedBuffers)+' Flags='+inttostr(Block.Header.dwFlags));
      // Если отправка не удалась, отменяем подготовку заголовка
      waveOutUnprepareHeader(FDeviceHandle, @Block.Header, SizeOf(TWaveHdr));
      //raise Exception.CreateFmt('Error writing to waveOut device: %d, FQueuedBuffers=%d, dwFlags=%d', [ResultCode, FQueuedBuffers, Block.Header.dwFlags]);
    end
    else
    begin
      logMessage('QueueBuffer ind='+inttostr(i)+' FQueuedBuffers='+inttostr(FQueuedBuffers)+' Flags='+inttostr(Block.Header.dwFlags));
      InterlockedIncrement(FQueuedBuffers);
    end;
  finally
    ExitCs;
  end;
end;
function TSoundCardDac.IsPlay: Boolean;
begin
  Result := state=stPlay;
end;
// Возвращает список доступных устройств вывода
function TSoundCardDac.GetDeviceList: TStringList;
var
  DeviceCount: Integer;
  i: Integer;
  WaveOutCaps: TWaveOutCaps;
begin
  Result := TStringList.Create;
  // Получаем количество доступных устройств вывода
  DeviceCount := waveOutGetNumDevs;
  if DeviceCount = 0 then
    Exit;
  // Итерируемся по всем устройствам и читаем их имена
  for i := 0 to DeviceCount - 1 do
  begin
    // Получаем информацию о возможностях устройства
    if waveOutGetDevCaps(i, @WaveOutCaps, SizeOf(TWaveOutCaps)) = MMSYSERR_NOERROR then
    begin
      // Добавляем имя устройства в список
      Result.Add(WaveOutCaps.szPname);
    end;
  end;
end;
procedure TSoundCardDac.WaveOutCallback(hwo: HWAVEOUT; uMsg: UINT; dwInstance: DWORD; dwParam1: DWORD; dwParam2: DWORD);
var
  Header: PWAVEHDR;
  Block: PSoundCardBlock;
  //idx: Integer;
  lBufSizeBytes, ind: Integer;
begin
  if (uMsg <> WOM_DONE) then
  begin
    logMessage('WaveOutCallback uMsg <> WOM_DONE');
    Exit;
  end;
  // Защита от гонок: проверяем хендл перед любыми операциями
  if FDeviceHandle = 0 then
  begin
    logMessage('WaveOutCallback FDeviceHandle =0');
    Exit;
  end;
  Header := PWAVEHDR(dwParam1);
  if not Assigned(Header) then
  begin
    logMessage('WaveOutCallback not Assigned(Header)');
    Exit;
  end;
  // Получаем указатель на наш блок, сохраненный в dwUser
  Block := PSoundCardBlock(Header.dwUser);
  lBufSizeBytes := Header.dwBufferLength;
  // Делаем unprepare только если буфер был подготовлен
  if (Header.dwFlags and WHDR_PREPARED) <> 0 then
  begin
    // Драйвер отпускает буфер
    waveOutUnprepareHeader(FDeviceHandle, Header, SizeOf(TWAVEHDR));
  end;
  ind:=FBlockQueue.GetBlockIndex(Block);
  // Уменьшаем счетчик только если он больше нуля
  if FQueuedBuffers > 0 then
    InterlockedDecrement(FQueuedBuffers);
  // Запрашиваем генерацию следующего буфера через OnBufferEnd
  
  if Assigned(Block) and Assigned(OnBufferEnd) then
    OnBufferEnd(Block^.Samples, lBufSizeBytes);
end;
{ TSoundCardDac.ReallocateBuffers }
procedure TSoundCardDac.ReallocateBuffers(NewSize: Integer);
var
  i: Integer;
  blData:pBlockData;
  WasPlaying: Boolean;
begin
  if NewSize <= 0 then
    Exit;
  // Запоминаем, было ли устройство в режиме воспроизведения
  WasPlaying := (State = stPlay);
  // 1. Останавливаем воспроизведение, если оно шло
  if WasPlaying then
  begin
    waveOutReset(FDeviceHandle);
  end;
  EnterCs;
  try
    // 3. Сбрасываем заголовки перед перевыделением
    ResetAllBuffers;
    // 4. Старые блоки данных больше не используем
    // FreeAllBlocks;
    // 5. Очередь уже очищена ранее
    // ClearBlocks;
    // 6. Обновляем размер буфера
    BufferSize := NewSize;
    // 7. Выделяем память под новый размер
    for i := 0 to NUM_BUFFERS - 1 do
    begin
      blData:=FBlockQueue.GetBlockData(i);
      // Выделяем память для блока с новым размером
      blData.Data := PSoundCardBlock(AllocateBlock);
    end;
  finally
    ExitCs;
  end;
  // Если устройство играло, после reset продолжаем работу
  // Новые данные будут сгенерированы в следующем OnGenerateData
  if WasPlaying then
  begin
    // Повторный Start здесь не нужен
    
  end;
end;
end.
