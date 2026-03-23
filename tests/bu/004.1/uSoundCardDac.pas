unit uSoundCardDac;

{******************************************************************************
 * Модуль реализации ЦАП для звуковой карты (uSoundCardDac.pas)
 *------------------------------------------------------------------------------
 * НАЗНАЧЕНИЕ:
 *   Этот модуль содержит конкретную реализацию класса TDacDevice для работы
 *   со стандартной звуковой картой Windows через мультимедиа API (waveOut).
 *
 * АРХИТЕКТУРА РАБОТЫ С WINAPI:
 *   1. Открытие устройства: Через waveOutOpen открывается звуковое устройство.
 *      Ключевым моментом является передача указателя на callback-функцию
 *      (WaveOutProc) с флагом CALLBACK_FUNCTION. Это говорит системе, что мы
 *      хотим получать уведомления о событиях асинхронно.
 *
 *   2. Двойная буферизация: Класс управляет несколькими буферами (их число
 *      задается константой NUM_BUFFERS). Пока один буфер проигрывается
 *      устройством, другие могут заполняться данными.
 *
 *   3. Постановка в очередь: Метод QueueBuffer подготавливает заголовок
 *      (WAVEHDR), связывает его с данными и отправляет драйверу через
 *      waveOutWrite. После этого вызова драйвер "владеет" этим буфером.
 *
 *   4. Callback и возврат буфера: Когда драйвер завершает проигрывание
 *      буфера, он вызывает нашу callback-функцию WaveOutProc с сообщением
 *      WOM_DONE. Внутри обработчика мы обязаны "разрегистрировать" заголовок
 *      через waveOutUnprepareHeader, после чего буфер снова становится
 *      свободным для использования. Затем вызывается событие OnBufferEnd.
 *
 * ПОТОКОВАЯ МОДЕЛЬ:
 *   Callback-функция WaveOutProc выполняется в специальном, высокоприоритетном
 *   потоке, управляемом мультимедиа-подсистемой Windows. Это не основной поток
 *   GUI. Это обеспечивает точное по времени срабатывание событий, независимое
 *   от загрузки основного потока (например, перемещения окна).
 *****************************************************************************}

interface

uses
  Classes, Windows, MMSystem, uDacDevice, sysutils, SyncObjs,
  ulogfile
  ;

const
  WHDR_LOOP = $00000008; // Флаг зацикливания, может отсутствовать в старых SDK

type
  // Структура блока данных для TSoundCardDac
  PSoundCardBlock = ^TSoundCardBlock;

  TSoundCardBlock = record
    Samples: PAnsiChar; // Указатель на буфер с аудиоданными
    Header: TWaveHdr;   // Заголовок WAVE для WinAPI
  end;

  TSoundCardDac = class(TDacDevice)
  private
    // Хендл устройства waveOut
    FDeviceHandle: HWAVEOUT;

    // Текущее значение для зацикливания. Если 0 - игра по циклу
    FCurrentLoopCount: Cardinal;
    // Счетчик буферов в очереди драйвера (сколько накопилось в очереди)
    FQueuedBuffers: Integer;
    // Событие для синхронизации - сигнализирует о завершении всех callback
    FResetDoneEvent: THandle;

    // Приватный метод-обработчик callback-сообщений от драйвера
    procedure WaveOutCallback(hwo: HWAVEOUT; uMsg: UINT; dwInstance: DWORD;
      dwParam1: DWORD; dwParam2: DWORD);
  public
    constructor Create;
    destructor Destroy; override;

    // Открывает звуковое устройство waveOut
    function Open:cardinal;override;
    // Закрывает звуковое устройство и освобождает буферы       lj,fd
    procedure Close; override;
    // Устанавливает параметры и запускает воспроизведение
    procedure Start(ALoopCount: Cardinal = 1); override;
    // Останавливает воспроизведение
    procedure Stop(AGraceful: Boolean = True); override;
    // Отправляет буфер данных драйверу waveOut
    procedure QueueBuffer(const ABuffer; ASize: Integer); override;
    // Возвращает текущее состояние активности
    function IsPlay: Boolean; override;
    function GetDeviceList: TStringList; override;
    //function CheckDone(i:integer):boolean;override;

    // Выделяет и освобождает память для блока данных TSoundCardBlock
    function AllocateBlock: Pointer; override;
    procedure FreeBlock(ABlock: Pointer); override;
  end;

implementation

// Статическая callback-функция, т.к. ее адрес передается в WinAPI
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
  // Создаем очередь блоков
  FBlockQueue := TBlockQueue.Create(NUM_BUFFERS);
end;

destructor TSoundCardDac.Destroy;
begin
  Close;
  // Освобождаем очередь блоков
  FBlockQueue.Free;
  inherited;
end;

function TSoundCardDac.AllocateBlock: Pointer;
var
  Block: PSoundCardBlock;
begin
  // Выделяем память под саму запись TSoundCardBlock
  New(Block);
  // Обнуляем, чтобы не было мусора
  FillChar(Block^, SizeOf(TSoundCardBlock), 0);
  // Выделяем память под буфер для аудиоданных.
  // FBufferSize должен быть рассчитан в методе Open.
  if FBufferSize > 0 then
    Block^.Samples := AllocMem(FBufferSize);

  Result := Block;
end;

procedure TSoundCardDac.FreeBlock(ABlock: Pointer);
var
  Block: PSoundCardBlock;
begin
  if ABlock = nil then
    Exit;

  Block := PSoundCardBlock(ABlock);

  // Освобождаем память из-под буфера с аудиоданными
  if Block^.Samples <> nil then
    FreeMem(Block^.Samples);

  // Освобождаем память из-под самой записи
  Dispose(Block);
end;



function TSoundCardDac.Open:cardinal;
var
  wfx: TWaveFormatEx;
  i: Integer;
  ResultCode: MMRESULT;
  block: Pointer;
begin
  if FState<>stClosed then
    Exit;

  // 1. Инициализация формата звуковых данных (структура WAVEFORMATEX)
  FillChar(wfx, SizeOf(wfx), 0);
  wfx.wFormatTag      := WAVE_FORMAT_PCM; // Формат: импульсно-кодовая модуляция (стандартный)
  wfx.nChannels       := Channels;        // Количество каналов (1 - моно, 2 - стерео)
  wfx.nSamplesPerSec  := SampleRate;      // Частота дискретизации (сэмплов в секунду)
  wfx.wBitsPerSample  := BitsPerSample;     // Битность (разрядность) сэмпла (8, 16, ...)
  wfx.nBlockAlign     := (wfx.nChannels * wfx.wBitsPerSample) div 8; // Размер одного блока (сэмпла) в байтах для всех каналов
  wfx.nAvgBytesPerSec := wfx.nSamplesPerSec * wfx.nBlockAlign;      // Требуемая скорость потока (байт в секунду)
  wfx.cbSize          := 0;               // Дополнительные байты информации (не используются для PCM)

  // 2. Открытие устройства вывода звука (функция WinAPI waveOutOpen)
  ResultCode := waveOutOpen(
    @FDeviceHandle,     // Указатель на хендл устройства (заполняется функцией)
    UINT_PTR(DeviceID), // Идентификатор устройства. Может быть реальным ID или WAVE_MAPPER (-1) для устройства по умолчанию.
    @wfx,               // Указатель на структуру с форматом звука
    DWORD_PTR(@WaveOutProc),// Адрес callback-функции для обработки сообщений
    DWORD_PTR(Self),    // Пользовательские данные, передаваемые в callback (указатель на наш класс)
    CALLBACK_FUNCTION   // Тип callback: функция
  );

  if ResultCode <> MMSYSERR_NOERROR then
    raise Exception.Create('Error opening waveOut device: ' + IntToStr(ResultCode));

  // 3. Расчет размера буфера в байтах
  CalculateBufferSize;

  // 4. Очищаем очередь и выделяем новые блоки
  // Используем ClearBlocks для сброса очереди без пересоздания
  EnterCs;
  try
    // Освобождаем старые буферы если они есть
    FreeAllBlocks;
    // Очищаем очередь (сброс индексов)
    ClearBlocks;
  finally
    ExitCs;
  end;

  // 5. Выделение и инициализация блоков данных
  for i := 0 to NUM_BUFFERS - 1 do
  begin
    // Выделяем память для блока
    block := AllocateBlock;
    // Добавляем в очередь. Изначально все блоки свободны.
    FBlockQueue.Add(block);
  end;

  // Сбрасываем счетчики и флаги
  FQueuedBuffers := 0;
  FCurrentLoopCount := 1; // По умолчанию однократное воспроизведение
  
  FState:= stOpened;
end;

//function TSoundCardDac.CheckDone(i: integer): boolean;
//var
//  bl:TSoundCardBlock;
//begin

//end;

procedure TSoundCardDac.Close;
begin
  //logMessage('Close BEGIN FQueuedBuffers='+inttostr(FQueuedBuffers));

  if FDeviceHandle <> 0 then
  begin
    // Reset the device - эта функция блокирует до возврата всех буферов
    // callback автоматически сделает unprepare для всех буферов
    waveOutReset(FDeviceHandle);
    //logMessage('Close AFTER waveOutReset');

    // Now that all buffers are returned, we can close the device.
    waveOutClose(FDeviceHandle);
    FDeviceHandle := 0;
  end;

  // Сбрасываем счетчик
  FQueuedBuffers := 0;

  // Set the stopping flag
  State:=stClosed;

  EnterCs;
  try
    // Освобождаем память всех блоков
    FreeAllBlocks;
    // Очищаем очередь (сброс индексов)
    ClearBlocks;
  finally
    ExitCs;
  end;
  //logMessage('Close END');
end;

procedure TSoundCardDac.Start(ALoopCount: Cardinal = 1);
var
  i: Integer;
begin
  //logMessage('Start: BEGIN, FCurrentLoopCount='+inttostr(FCurrentLoopCount));
  inherited Start(ALoopCount);
  FCurrentLoopCount := ALoopCount;
  //logMessage('Start: after inherited, FCurrentLoopCount='+inttostr(FCurrentLoopCount));

  // Сбрасываем счетчик буферов перед запуском
  FQueuedBuffers := 0;
  //logMessage('Start: FQueuedBuffers reset to 0');

  // Предварительно заполняем очередь буферами для безшовного воспроизведения
  // Это гарантирует что в драйвере всегда есть несколько готовых буферов
  for i := 0 to 1 do // Заполняем 2 буфера заранее
  begin
    //logMessage('Start: calling FOnGenerateData #'+inttostr(i));
    if Assigned(FOnGenerateData) then
      FOnGenerateData(Self);
  end;
  //logMessage('Start: END');
end;

procedure TSoundCardDac.Stop(AGraceful: Boolean = True);
var
  i: Integer;
  Block: PSoundCardBlock;
begin
  //logMessage('Stop: BEGIN, state='+inttostr(integer(State)));
  inherited Stop(AGraceful);
  //logMessage('Stop: after inherited, state='+inttostr(integer(State)));
  if state<>stplay then Exit;

  //logMessage('Stop: FQueuedBuffers='+inttostr(FQueuedBuffers));

  // Сбрасываем счетчик чтобы остановить постановку новых буферов
  FQueuedBuffers := 0;
  //logMessage('Stop: FQueuedBuffers reset to 0');

  // если мгновенный останов - сбрасываем все буферы
  if not AGraceful then
  begin
    //logMessage('Stop: calling waveOutReset');
    // waveOutReset блокирует до возврата всех буферов
    waveOutReset(FDeviceHandle);
    
    // Проходим по всем блокам и делаем unprepare
    EnterCs;
    try
      for i := 0 to FBlockQueue.MaxBlocks - 1 do
      begin
        if FBlockQueue.GetBlockData(i).Data <> nil then
        begin
          Block := PSoundCardBlock(FBlockQueue.GetBlockData(i).Data);
          if (Block.Header.dwFlags and WHDR_PREPARED) <> 0 then
          begin
            waveOutUnprepareHeader(FDeviceHandle, @Block.Header, SizeOf(TWaveHdr));
          end;
        end;
      end;
    finally
      ExitCs;
    end;
    
    //logMessage('Stop: AFTER waveOutReset');
  end;
end;

procedure TSoundCardDac.QueueBuffer(const ABuffer; ASize: Integer);
var
  ResultCode: MMRESULT;
  Block: PSoundCardBlock;
  BlockPtr: Pointer;
  i:integer;
begin
  // Проверяем состояние - если не играем, выходим
  if state<>stplay then Exit;

  // Проверка: не ставим в очередь больше NUM_BUFFERS
  // Это предотвращает переполнение и гонку буферов
  if FQueuedBuffers >= NUM_BUFFERS then
  begin
    exit;
  end;

  // Получаем самый старый (свободный) блок из очереди
  if not FBlockQueue.GetOldest(BlockPtr) then
    exit; // Нет свободных буферов

  Block := PSoundCardBlock(BlockPtr);

  if ASize > FBufferSize then
    raise Exception.CreateFmt('QueueBuffer: Data size (%d) exceeds allocated buffer size (%d).', [ASize, FBufferSize]);

  // Копируем данные
  Move(ABuffer, Block.Samples^, ASize);

  // Полный сброс заголовка перед подготовкой
  FillChar(Block.Header, SizeOf(TWaveHdr), 0);

  // Готовим заголовок
  Block.Header.lpData := Block.Samples;
  Block.Header.dwBufferLength := ASize;
  Block.Header.dwUser := DWORD_PTR(Block); // Сохраняем указатель на наш блок
  // dwFlags и dwLoops уже = 0 после FillChar

  // Сначала делаем prepare
  ResultCode := waveOutPrepareHeader(FDeviceHandle, @Block.Header, SizeOf(TWaveHdr));
  if ResultCode <> MMSYSERR_NOERROR then
    raise Exception.Create('Error preparing waveOut header: ' + IntToStr(ResultCode));

  // Устанавливаем логику зацикливания ПОСЛЕ prepare
  if FCurrentLoopCount = 0 then // 0 - наш флаг бесконечного цикла
  begin
    Block.Header.dwLoops := MAXDWORD; // Для WinAPI бесконечный цикл - это MAXDWORD
    Block.Header.dwFlags := WHDR_BEGINLOOP or WHDR_ENDLOOP or WHDR_LOOP;
  end
  else
  begin
    Block.Header.dwLoops := FCurrentLoopCount; // Проигрываем заданное число раз
    // dwFlags остается 0 для однократного воспроизведения
  end;

  // Отправляем на воспроизведение. После waveOutWrite нельзя менять буфер!!!
  // можно поставить несколько буферов в очередь
  ResultCode := waveOutWrite(FDeviceHandle, @Block.Header, SizeOf(TWaveHdr));
  i:=integer(GetBlockIndex(Block));
  if ResultCode <> MMSYSERR_NOERROR then
  begin
    logMessage('Error writing to waveOut: ind='+inttostr(i)+' FQueuedBuffers='+inttostr(FQueuedBuffers)+' Flags='+inttostr(Block.Header.dwFlags));
    // Если отправка не удалась, нужно отменить подготовку заголовка
    waveOutUnprepareHeader(FDeviceHandle, @Block.Header, SizeOf(TWaveHdr));
    //raise Exception.CreateFmt('Error writing to waveOut device: %d, FQueuedBuffers=%d, dwFlags=%d', [ResultCode, FQueuedBuffers, Block.Header.dwFlags]);
  end
  else
    logMessage('QueueBuffer ind='+inttostr(i)+' FQueuedBuffers='+inttostr(FQueuedBuffers)+' Flags='+inttostr(Block.Header.dwFlags));

  // Помечаем блок как "удаленный" из очереди доступных, так как он передан драйверу
  FBlockQueue.MarkOldestAsDeleted;

  InterlockedIncrement(FQueuedBuffers);
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
  // Получаем количество доступных устройств вывода звука
  DeviceCount := waveOutGetNumDevs;
  if DeviceCount = 0 then
    Exit;

  // Итерируемся по всем устройствам и получаем их имена
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
begin
  if (uMsg <> WOM_DONE) then
    Exit;

  // Защита от гонок - проверяем хендл перед любыми операциями
  if FDeviceHandle = 0 then
    Exit;

  Header := PWAVEHDR(dwParam1);

  if not Assigned(Header) then
    Exit;

  // Получаем указатель на наш блок, который мы сохранили в dwUser
  Block := PSoundCardBlock(Header.dwUser);

  // Делаем unprepare только если буфер подготовлен
  if (Header.dwFlags and WHDR_PREPARED) <> 0 then
  begin
    // драйвер отпускает буфер
    waveOutUnprepareHeader(FDeviceHandle, Header, SizeOf(TWAVEHDR));
  end;

  // Возвращаем блок в очередь как доступный для повторного использования
  if Assigned(Block) then
  begin
    FBlockQueue.Add(Block);
    //idx := integer(GetBlockIndex(Block));
    //logMessage('Callback ind='+inttostr(idx)+' FQueuedBuffers='+inttostr(FQueuedBuffers)+' BEFORE dec');
  end;

  // Уменьшаем счетчик только если он больше 0
  if FQueuedBuffers > 0 then
    InterlockedDecrement(FQueuedBuffers);

  //logMessage('Callback ind='+inttostr(idx)+' FQueuedBuffers='+inttostr(FQueuedBuffers)+' AFTER dec');
  // DoBufferEnd больше не нужен - поток генерирует данные непрерывно
  // doBufferEnd(Self);
end;
end.
