# Тестовый стенд MIC183/185 (Tests/mic185)

Автономный стенд RecorderLnx для отладки Mebius TCP без зависимости от MIC-140 и основного приложения Recorder.

**Каталог:** `Lazarus/RecorderLnx/Tests/mic185/`

## Сборка

```bat
C:\lazarus\lazbuild.exe -B Tests\mic185\mic185_acquire_test.lpi
C:\lazarus\lazbuild.exe -B Tests\mic185\mic185_acquire_gui.lpi
```

Перед пересборкой GUI закройте `mic185_acquire_gui.exe` (иначе линковщик не перезапишет exe).

## CLI: `mic185_acquire_test`

```bat
mic185_acquire_test.exe [options] [host] [port] [meas_fs_hz] [blocks]
```

| Опция | Назначение |
|-------|------------|
| `-sniff` | После чтения — sniff 3 data-пакетов в лог (`devId` в строке) |
| `-verify-codes` | Сверка кодов АЦП с эталоном [defaults.md](defaults.md) |

Дефолты: `192.168.9.142 4000 100 5`.

Цепочка: Connect → Program → Start → N× ReadBlock → Stop → Disconnect.

## GUI: `mic185_acquire_gui`

Интерактивно: Connect / Start / Stop / Disconnect, таблица 70 каналов, лог.

### Кнопки

| Кнопка | Действие |
|--------|----------|
| **Connect** | TCP Connect + `ProgramDevice` (дефолты Recorder), инициализация таблицы каналов |
| **Start** | Start acquisition, таймер опроса 200 ms |
| **Stop** | Stop, остановка таймера |
| **Disconnect** | Stop + Disconnect |

Кнопка Program скрыта (влита в Connect).

### Шапка формы

| Элемент | Содержание |
|---------|------------|
| State | Disconnected / Connected / Programmed / Started |
| Packets / Blocks | Счётчик TCP data-пакетов и успешно разобранных meas-блоков |
| Uptime | `Uptime` и `blocks×period` (period = 200 ms — интервал `tmrAcquire`) |
| Recorder ref | Сводка совпадений кодов с эталоном (тензо 1–50) |

### Таблица каналов

| Колонка | Содержание |
|---------|------------|
| Code | Последний код АЦП (тензо) или °C (temp) |
| Ref / Δ / Match | Сверка с эталоном Recorder (допуск ±3) |
| Updated | Время последнего обновления |

Строки с Match=OK подсвечиваются зелёным (`OnPrepareCanvas`, флаг `fChannelMatch[]`).

Строки 65–69 — температурные каналы (`MIC183_185-{3-t1}` …), обновляются из кеша `fLastTempValues` (~1 Гц). См. [temperature_channels.md](temperature_channels.md).

### Режимы командной строки

| Флаг | Действие |
|------|----------|
| `--connect` | Connect+Program, проверка, закрытие |
| `--auto` | Connect → Program → Start → 10 блоков → Stop |
| `--verify` | Program → Start → сверка кодов АЦП |
| `--stress` | Connect → Start → **120 с** непрерывного захвата (~1000 блоков) |

Пример регрессии стабильности:

```bat
mic185_acquire_gui.exe --stress
```

Ожидаемый лог: `STRESS OK: blocks=~1000 uptime=120s`.

## Лог

Файл: `mic185_protocol_debug.log` в каталоге exe.

- Запись **append** (не перезапись всего файла).
- Буфер в памяти: до 3000 строк.
- Memo в GUI: до 400 строк (старые удаляются).
- Вывод в Memo только через `tmrLog` (не из обработчиков кнопок — избегаем AV LCL).

## Код стенда

| Файл | Роль |
|------|------|
| `mic185_acquire_test.lpr` | CLI |
| `mic185_acquire_gui.lpr` | GUI |
| `uMic185DebugForm.pas` | Форма, таймеры, таблица, автотесты |
| `uMic185DebugLog.pas` | Лог (буфер + файл) |
| `uMic185CodeVerify.pas` | Эталонные коды АЦП каналов 3-1…3-50 |
| `device/uMic185MebiusTcpProtocol.pas` | TCP, IOCTL, парсинг пакетов, LM74→°C |
| `device/MIC185/uMic185Device.pas` | `IRecorderDevice`, Connect/Program/Start/ReadBlock |
| `device/MIC185/uMic185MebiusTypes.pas` | Blob `CMIC185V2_BASESETTINGS` (3976 байт) |
| `device/MIC185/uMic185Constants.pas` | Константы, `CMic185PacketDataOffset=12` |

## Чтение данных в стенде

### Meas-блок (`ReadBlock`)

- Возвращает **только** 64 тензоканала (`DEV_ID_MEAS_CHANNELS`).
- `sampl_count` в пакете — сквозной счётчик, не размер блока.
- Смещение float: **12 байт** (`CMic185PacketDataOffset`).

### Temp и UTS (side cache)

`ReadMeasDataBlock` за один вызов:
1. Читает первый пакет с **полным** timeout (200–500 ms).
2. Далее **drain** до 32 пакетов с timeout **2 ms** (не блокировать на пустом сокете).
3. Кеширует последний meas-блок и любые пакеты `dev_id=2` (temp), `dev_id=0` (UTS).

Без drain temp-пакеты (1 Гц) теряются за потоком meas (100 Гц). Подробнее: [temperature_channels.md](temperature_channels.md).

### Счётчик Packets

`RxDataPacketCount` — все data-пакеты, прочитанные в drain-цикле. При соотношении ~12:1 к Blocks это нормально (несколько meas-пакетов на один GUI-тик).

## Известные проблемы и исправления (2026-07-06)

| Симптом | Причина | Исправление |
|---------|---------|-------------|
| AV на Connect | Reentrancy LCL (Memo, grid) | Лог через таймер; `BeginUpdate` на grid |
| AV на Start (`brush.inc`) | Неверная сигнатура `OnPrepareCanvas` (лишний `aCanvas`) | Сигнатура LCL (4 параметра), `TStringGrid(Sender).Canvas` |
| Зависание/падение через минуты | Drain 64×500 ms; лог O(n²); memo без лимита | Drain 2 ms; append-лог; cap memo 400 |
| Temp не в градусах | Нет `ConvLM74CodeToC` | `Mic185ConvLM74CodeToC` в парсере |
| Неверные коды АЦП | Смещение данных 10 вместо 12 | MSVC padding в `INTERNAL_PACKET_HEADER` |
| Неверное программирование | FPC blob alignment | Явные `_Pad*` в `TMic185BaseChanSettings` |

Детали: `Tests/mic185/errors/mic185_acquire_stability.md`.

## Ограничения vs Recorder

| Возможность Recorder | Стенд |
|---------------------|-------|
| `LoadCalibrCoefficients` | Нет (для режима «коды» не нужно) |
| `CalcStartOffset` | Нет |
| Пересчёт код→мВ (`EvalU`) | Нет (режим кодов) |
| `CheckTempDeviation` (ТКС) | Нет (только `ConvLM74CodeToC`) |
| Выборочное подключение каналов | Все 64 Connected |

См. [windev_mic185_test.md](windev_mic185_test.md).

## Диагностика

1. Только **один** TCP-клиент на порт 4000.
2. Sniff: `mic185_acquire_test.exe -sniff …` — смотреть `devId=1/2/0` в логе.
3. Сверка кодов: `--verify` или `-verify-codes`.
4. Стабильность GUI: `--stress`.
