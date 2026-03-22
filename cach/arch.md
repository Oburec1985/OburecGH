# Архитектура проекта TestDAC

## Назначение
Тестовый проект для работы с ЦАП (цифро-аналоговым преобразователем) на основе звуковой карты Windows.

## Структура модулей

### 1. Unit1.pas (TDACFrm)
**Назначение:** UI форма управления ЦАП

**Основные компоненты:**
- `btnPlayStop` - кнопка Play/Stop
- `rgMode` - переключатель режимов (Sin / SweepSin)
- `gbSin` - группа параметров синусоиды (частота, амплитуда)
- `gbSweepSin` - группа параметров развертки (начальная/конечная частота, время)
- `cbDacDevices` - выбор устройства вывода
- `cChart1` - визуализация сигнала

**Поток работы:**
1. Пользователь нажимает "Play" → вызывается `FDacDevice.Start(1)`
2. Если устройство закрыто → открывается с параметрами (SampleRate=44100, BitsPerSample=16, Channels=1)
3. Вызывается `GenerateAndQueueData` для генерации первого буфера
4. При окончании буфера драйвер вызывает callback → снова `GenerateAndQueueData`

### 2. uDacDevice.pas (TDacDevice)
**Назначение:** Абстрактный базовый класс для всех реализаций ЦАП

**Ключевые компоненты:**

#### TBlockQueue - потокобезопасная циклическая очередь блоков
```
Характеристики:
- Хранит указатели на блоки данных (Pointer)
- Не владеет памятью блоков (создание/удаление у пользователя)
- При переполнении перезаписывает самый старый блок
- Отложенное удаление (блоки помечаются флагом IsDeleted)
```

**Методы:**
- `Create(AMaxBlocks)` - создание очереди
- `Add(ADataPtr)` - добавить блок в очередь
- `GetOldest(out ADataPtr)` - получить самый старый не удалённый блок
- `MarkOldestAsDeleted` - пометить блок как удалённый

#### TDataGeneratorThread - поток генерации данных
```
Особенности:
- Запускается в фоновом режиме
- Использует TEvent для синхронизации
- Вызывает OnGenerateData при готовности буфера
```

**Свойства TDacDevice:**
- `SampleRate` - частота дискретизации (Гц)
- `BitsPerSample` - разрядность (8, 16, ...)
- `Channels` - количество каналов (1=моно, 2=стерео)
- `BufferSizeMS` - длительность буфера в мс
- `BufferSize` - размер буфера в байтах (рассчитывается автоматически)
- `DeviceID` - идентификатор устройства
- `OnGenerateData` - событие для генерации данных

### 3. uSoundCardDac.pas (TSoundCardDac)
**Назначение:** Конкретная реализация TDacDevice для звуковой карты Windows (waveOut API)

**Структура блока данных:**
```pascal
TSoundCardBlock = record
  Samples: PAnsiChar;  // буфер аудиоданных
  Header: TWaveHdr;    // заголовок WAVE для WinAPI
end;
```

**Поток работы с waveOut:**
1. `Open` → waveOutOpen с callback `WaveOutProc`
2. Выделяется NUM_BUFFERS блоков (по умолчанию 4)
3. `QueueBuffer` → waveOutPrepareHeader → waveOutWrite
4. Драйвер воспроизводит буфер
5. Callback `WaveOutProc` с uMsg=WOM_DONE
6. waveOutUnprepareHeader → возврат блока в очередь
7. Вызов `DoBufferEnd` → сигнал потоку генерации

**Callback модель:**
- WaveOutProc выполняется в потоке мультимедиа-подсистемы Windows (не GUI поток!)
- Высокий приоритет, точное время срабатывания
- При получении WOM_DONE → разрегистрировать заголовок → вернуть блок в очередь

## Режимы генерации сигнала

### Sin
Генерация синусоиды фиксированной частоты:
```pascal
Value := Ampl * Sin(2 * PI * Freq * i / SampleRate)
```

### SweepSin
Линейная развертка частоты от StartFreq до EndFreq за SweepTime секунд:
```pascal
FSweepCurrentFreq := StartFreq + (EndFreq - StartFreq) * (CurrentTime / SweepTime)
Value := Ampl * Sin(FSweepPhase)
FSweepPhase := FSweepPhase + 2 * PI * FSweepCurrentFreq / SampleRate
```

## Двойная буферизация
Принцип работы для непрерывного воспроизведения:
```
Пока звуковая карта играет буфер №1 →
  в это время генерируется буфер №2 →
  ставится в очередь →
  после окончания №1 сразу начинается №2
```

**Константа:** `NUM_BUFFERS = 4` (количество буферов в циклической очереди)

## Состояния устройства (TDACState)
- `stClosed` - устройство не инициализировано
- `stOpened` - устройство открыто, готово к работе
- `stPlay` - воспроизведение активно

## Файлы проекта
- `Project1.dpr` - главный файл проекта
- `Unit1.pas/.dfm` - форма приложения
- `uDacDevice.pas` - абстрактный класс ЦАП + TBlockQueue
- `uSoundCardDac.pas` - реализация для waveOut
- `Project1.ini` - файл настроек (сохраняется/загружается автоматически)

## Зависимости
- `sharedUtils\math\uCommonMath.pas`
- `sharedUtils\uCommonTypes.pas`
- `sharedUtils\math\MathFunction.pas`
- `sharedUtils\utils\uLogFile.pas`
- `sharedUtils\components\uChart.pas`
