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
  Classes, Windows, MMSystem, uDacDevice, sysutils, SyncObjs;

const
  NUM_BUFFERS = 4; // Количество используемых буферов
  WHDR_LOOP = $00000008; // Флаг зацикливания, может отсутствовать в старых SDK

type
  TSoundCardDac = class(TDacDevice)
  private
    FLock: TRTLCriticalSection; // Объект для синхронизации потоков
    // Хендл устройства waveOut
    FDeviceHandle: HWAVEOUT;
    // Заголовки буферов
    FWaveHeaders: array[0..NUM_BUFFERS - 1] of TWaveHdr;
    // Указатели на память буферов
    FBuffers: array[0..NUM_BUFFERS - 1] of PAnsiChar;
    // Размер одного буфера в байтах
    FBufferSize: Cardinal;
    // Флаг активности устройства
    FIsActive: Boolean;
    // Флаг процесса остановки
    FStopping: Boolean;
    // Текущее значение для зацикливания
    FCurrentLoopCount: Cardinal;
    // Счетчик буферов в очереди драйвера
    FQueuedBuffers: Integer;
    // Вспомогательная функция для поиска свободного буфера
    function GetFreeHeaderIndex: Integer;
    // Вспомогательная функция для проверки, что все буферы возвращены драйвером
    function AllHeadersDone: Boolean;

    // Приватный метод-обработчик callback-сообщений от драйвера
    procedure WaveOutCallback(hwo: HWAVEOUT; uMsg: UINT; dwInstance: DWORD;
      dwParam1: DWORD; dwParam2: DWORD);
  public
    constructor Create;
    destructor Destroy; override;

    // Открывает звуковое устройство waveOut
    function Open:cardinal;override;
    // Закрывает звуковое устройство и освобождает буферы
    procedure Close; override;
    // Устанавливает параметры и запускает воспроизведение
    procedure Start(ALoopCount: Cardinal = 1); override;
    // Останавливает воспроизведение
    procedure Stop(AGraceful: Boolean = True); override;
    // Отправляет буфер данных драйверу waveOut
    procedure QueueBuffer(const ABuffer; ASize: Integer); override;
    // Возвращает текущее состояние активности
    function IsActive: Boolean; override;
    function GetDeviceList: TStringList; override;
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
  InitializeCriticalSection(FLock);
  FDeviceHandle := 0;
  FIsActive := False;
  FStopping := False;
end;

destructor TSoundCardDac.Destroy;
begin
  Close;
  DeleteCriticalSection(FLock);
  inherited;
end;

function TSoundCardDac.GetFreeHeaderIndex: Integer;
begin
  for Result := 0 to NUM_BUFFERS - 1 do
  begin
    if (FWaveHeaders[Result].dwFlags and WHDR_PREPARED) = 0 then
      Exit;
  end;
  Result := -1;
end;

function TSoundCardDac.AllHeadersDone: Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to NUM_BUFFERS - 1 do
  begin
    if (FWaveHeaders[i].dwFlags and WHDR_PREPARED) <> 0 then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function TSoundCardDac.Open:cardinal;
var
  wfx: TWaveFormatEx;
  i: Integer;
  ResultCode: MMRESULT;
begin
  if FIsActive then
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

  // 3. Расчет размера и выделение памяти под буферы
  FBufferSize := round(SampleRate * BufferSizeMS / 1000) * (Channels * BitsPerSample div 8);
  if FBufferSize = 0 then FBufferSize := 4096; // Sanity check

  for i := 0 to NUM_BUFFERS - 1 do
  begin
    FBuffers[i] := AllocMem(FBufferSize);
    FillChar(FBuffers[i]^, FBufferSize, 0);
  end;

  FIsActive := True;
  FStopping := False;
end;

procedure TSoundCardDac.Close;
var
  i: Integer;
  StartTime: Cardinal;
  isAllDone: Boolean;
begin
  // Set the stopping flag. This needs to be thread-safe.
  EnterCriticalSection(FLock);
  try
    if FDeviceHandle = 0 then Exit;
    FStopping := True;
    FIsActive := False;
  finally
    LeaveCriticalSection(FLock);
  end;

  // Reset the device. This will cause WOM_DONE messages to be sent for all pending buffers.
  waveOutReset(FDeviceHandle);

  // Now, wait for the callbacks to finish processing all those buffers.
  // This loop does NOT hold the lock, so the callbacks can acquire it.
  StartTime := GetTickCount;
  while True do
  begin
    EnterCriticalSection(FLock);
    try
      isAllDone := AllHeadersDone;
    finally
      LeaveCriticalSection(FLock);
    end;

    if isAllDone then
      break; // Exit loop

    // Use a timeout to prevent an infinite loop in case of an unexpected issue.
    if (GetTickCount - StartTime) > 2000 then Break;
    Sleep(10);
  end;

  // Now that all buffers are hopefully returned and unprepared, we can close the device.
  EnterCriticalSection(FLock);
  try
    if FDeviceHandle <> 0 then
    begin
      waveOutClose(FDeviceHandle);
      FDeviceHandle := 0;
    end;

    // Free memory buffers
    for i := 0 to NUM_BUFFERS - 1 do
    begin
      if FBuffers[i] <> nil then
      begin
        FreeMem(FBuffers[i]);
        FBuffers[i] := nil;
      end;
    end;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

procedure TSoundCardDac.Start(ALoopCount: Cardinal = 1);
begin
  FStopping := False;
  FCurrentLoopCount := ALoopCount;
  FIsActive := True;
end;

procedure TSoundCardDac.Stop(AGraceful: Boolean = True);
var
  isAllDone: Boolean;
  StartTime: Cardinal;
begin
  EnterCriticalSection(FLock);
  try
    if not FIsActive then Exit;
    FStopping := True;
    FIsActive := False;
  finally
    LeaveCriticalSection(FLock);
  end;

  if FCurrentLoopCount = 0 then
  begin
    waveOutBreakLoop(FDeviceHandle);
  end;

  if not AGraceful then
  begin;
    waveOutReset(FDeviceHandle);
    // Wait for callbacks to finish to prevent race conditions
    StartTime := GetTickCount;
    while True do
    begin
      EnterCriticalSection(FLock);
      try
        isAllDone := AllHeadersDone;
      finally
        LeaveCriticalSection(FLock);
      end;
      if isAllDone then break;
      if (GetTickCount - StartTime) > 1000 then Break; // Timeout
      Sleep(10);
    end;
  end;
end;

procedure TSoundCardDac.QueueBuffer(const ABuffer; ASize: Integer);
var
  HeaderIndex: Integer;
  ResultCode: MMRESULT;
begin
  if FStopping then Exit;

  HeaderIndex := GetFreeHeaderIndex;
  if HeaderIndex = -1 then
    Exit; // Нет свободных буферов

  if ASize > FBufferSize then
    raise Exception.CreateFmt('QueueBuffer: Data size (%d) exceeds allocated buffer size (%d).', [ASize, FBufferSize]);

  // Копируем данные
  Move(ABuffer, FBuffers[HeaderIndex]^, ASize);

  // Готовим заголовок
  with FWaveHeaders[HeaderIndex] do
  begin
    lpData := FBuffers[HeaderIndex];
    dwBufferLength := ASize;
    dwFlags := 0; // Сбрасываем флаги

    // Устанавливаем логику зацикливания
    if FCurrentLoopCount = 0 then // 0 - наш флаг бесконечного цикла
    begin
      dwLoops := MAXDWORD; // Для WinAPI бесконечный цикл - это MAXDWORD
      dwFlags := WHDR_BEGINLOOP or WHDR_ENDLOOP or WHDR_LOOP;
    end
    else
    begin
      dwLoops := FCurrentLoopCount; // Проигрываем заданное число раз
    end;
  end;

  ResultCode := waveOutPrepareHeader(FDeviceHandle, @FWaveHeaders[HeaderIndex], SizeOf(TWaveHdr));
  if ResultCode <> MMSYSERR_NOERROR then
    raise Exception.Create('Error preparing waveOut header: ' + IntToStr(ResultCode));

  // Отправляем на воспроизведение
  ResultCode := waveOutWrite(FDeviceHandle, @FWaveHeaders[HeaderIndex], SizeOf(TWaveHdr));
  if ResultCode <> MMSYSERR_NOERROR then
    raise Exception.Create('Error writing to waveOut device: ' + IntToStr(ResultCode));

  InterlockedIncrement(FQueuedBuffers);
end;

function TSoundCardDac.IsActive: Boolean;
begin
  Result := FIsActive;
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
begin
  EnterCriticalSection(FLock);
  try
    if (FDeviceHandle = 0) or (uMsg <> WOM_DONE) then
      Exit;

    Header := PWAVEHDR(dwParam1);

    if not Assigned(Header) then
      Exit;

    if (Header.dwFlags and WHDR_PREPARED) <> 0 then
      waveOutUnprepareHeader(FDeviceHandle, Header, SizeOf(TWAVEHDR));

    InterlockedDecrement(FQueuedBuffers);

    if FStopping and (FQueuedBuffers = 0) then
    begin;
      FIsActive := False;
    end;

    if Assigned(OnBufferEnd) and not FStopping and (FCurrentLoopCount <> 0) then
      OnBufferEnd(Self);
  finally
    LeaveCriticalSection(FLock);
  end;
end;
end.
