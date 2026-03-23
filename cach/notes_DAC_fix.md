# Исправление ошибки повторного запуска ЦАП

## Проблема
При запуске ЦАП → останове → повторном запуске происходила ошибка:
`raise Exception.Create('Error writing to waveOut device: ' + IntToStr(ResultCode))`

Код ошибки: 33 (MMSYSERR_INVALPARAM)

## Корневые причины
1. **Счетчик FQueuedBuffers не сбрасывался** - после Stop/Start счетчик оставался > 0
2. **Флаги цикла устанавливались до waveOutPrepareHeader** - WHDR_BEGINLOOP и WHDR_ENDLOOP должны ставиться ПОСЛЕ prepare
3. **Буферы не очищались между запусками** - при повторном запуске из stOpened использовались старые буферы
4. **Очередь блоков возвращала не те блоки** - после Stop блоки не возвращались в очередь корректно

## Решение

### 1. Сброс FQueuedBuffers
- В `Start`: сброс в 0 перед заполнением очереди
- В `Stop`: сброс в 0 для остановки постановки новых буферов

### 2. Порядок операций в QueueBuffer
```pascal
// Правильный порядок:
FillChar(Block.Header, SizeOf(TWaveHdr), 0);
Block.Header.lpData := Block.Samples;
Block.Header.dwBufferLength := ASize;
Block.Header.dwUser := DWORD_PTR(Block);

// 1. Сначала prepare БЕЗ флагов цикла
ResultCode := waveOutPrepareHeader(...);

// 2. Потом устанавливаем флаги цикла
if FCurrentLoopCount = 0 then
  Block.Header.dwFlags := WHDR_BEGINLOOP or WHDR_ENDLOOP or WHDR_LOOP
else
  Block.Header.dwLoops := FCurrentLoopCount;

// 3. Потом write
ResultCode := waveOutWrite(...);
```

### 3. Защита в callback
```pascal
if FDeviceHandle = 0 then
  Exit;  // Защита от гонок при закрытии
```

### 4. Логика QueueBuffer
```pascal
if not FBlockQueue.GetOldest(BlockPtr) then
  exit; // Нет свободных буферов - выходим без ошибки
```

### 5. Инициализация в Open
```pascal
FQueuedBuffers := 0;
FCurrentLoopCount := 1; // По умолчанию однократное воспроизведение
```

### 6. Новые методы
- `TBlockQueue.GetBlockIndex(ADataPtr: Pointer): Integer` - поиск индекса блока по указателю
- `TDacDevice.GetBlockIndex(ADataPtr: Pointer): Integer` - обертка для доступа из наследников

## Итог
ЦАП теперь корректно работает в режиме: запуск → останов → запуск (многократно)

**Измененные файлы:**
- `tests/TestDAC/uSoundCardDac.pas`
- `tests/TestDAC/uDacDevice.pas`
- `tests/TestDAC/Unit1.pas`
