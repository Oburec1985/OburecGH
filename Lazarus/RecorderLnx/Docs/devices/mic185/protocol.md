# Протокол MIC185V2 (Mebius TCP)

Обмен с комплексом MIC183/185 версии 19–20 ведётся по **Mebius Ethernet/TCP** на порту **4000**. Это **не** legacy MDP (MC031/MC114), используемый старым MIC0185.

## Транспорт: MEBE-пакет

Заголовок (`EthernetPacket.h`):

| Поле      | Тип   | Значение                             |
| --------- | ----- | ------------------------------------ |
| signature | ULONG | `0xA0A0CAFE`                         |
| size      | ULONG | размер всего пакета                  |
| id_to     | ULONG | TASKID получателя                    |
| id_from   | ULONG | TASKID отправителя                   |
| crc       | ULONG | `sig XOR size XOR id_to XOR id_from` |

Тело IOCTL-команды (`IoControlIds.h`):

| Смещение | Поле |
|----------|------|
| 0 | signature `0xF10C` (WORD) |
| 2 | signature `0xF10C` (WORD, дубль) |
| 4 | `IOCTL_CODE` (ULONG) |
| 8 | параметры (до 256 байт) |

TASK ID задачи измерения: `MEASUREMENT_TASK_ID = MAKE_TASKID(0, CLASSID_BASE_TASKS+1, 1, 0)`.

## Последовательность программирования

Соответствует `CMIC185V2::OnProgram()` и `CMIC185V2::OnProgramDevice()`:

1. **TCP Connect** — `CTCPLink::InternalConnect`, порт 4000.
2. **SET_CONTROLLER_PARAMS** — `IOCTL_MEASTASK_CALL_COMMAND` + `IOCTL_CMD_SET_CONTROLLER_PARAMS` (флаги СЕВ, `TASKSEV_EN_FLAG`).
3. **PROGRAMM_DEVICE_BIN** — `IOCTL_MEASTASK_PROGRAMM_DEVICE_BIN` с бинарным blob `CMIC185V2_BASESETTINGS`.
4. **SET_SESSION_ID** — `IOCTL_MEASTASK_SET_SESSION_ID` (генерируется из s/n и tick).
5. **PROGRAM** — `IOCTL_MEASTASK_PROGRAM` (программирование задачи измерения/скана).
6. **START** — `IOCTL_MEASTASK_START`.
7. Приём **data-пакетов** — `id_from` = `DATA_TRANSMIT_TASK_ID` **или** `0x3E904000` (оба варианта в `PacketDispatch.cpp`).
8. **STOP** — `IOCTL_MEASTASK_STOP`.

Практическая проверка дампами от 2026-08-13: перед запуском текущей конфигурации в трафике должен быть виден `PROGRAMM_DEVICE_BIN` размером около 4 КБ. Если его нет, нельзя считать прибор переконфигурированным только по успешным `SET_SESSION_ID`, `PROGRAM` и `START`. Подробное сравнение: [COMPARISON_2026-08-13.md](../../../Tools/Mic185TrafficCapture/captures/COMPARISON_2026-08-13.md).

## IOCTL-коды (основные)

```
IOCTL_MEASTASK_PROGRAMM_DEVICE_BIN = CTL_CODE(TYPEIO_MEAS_TASK, 0x000A, 0, 0)
IOCTL_MEASTASK_SET_SESSION_ID      = CTL_CODE(TYPEIO_MEAS_TASK, 0x0009, 0, 0)
IOCTL_MEASTASK_PROGRAM             = CTL_CODE(TYPEIO_MEAS_TASK, 0x0010, 0, 0)
IOCTL_MEASTASK_START               = CTL_CODE(TYPEIO_MEAS_TASK, 0x000B, 0, 0)
IOCTL_MEASTASK_STOP                = CTL_CODE(TYPEIO_MEAS_TASK, 0x000C, 0, 0)
IOCTL_MEASTASK_CALL_COMMAND        = CTL_CODE(TYPEIO_MEAS_TASK, 0x000D, 0, 0)

IOCTL_CMD_SET_CONTROLLER_PARAMS    = CTL_CODE(TYPEIO_CALL_COMMAND, 0x000C, 0, 0)
IOCTL_CMD_GET_SOFT_VERSION         = CTL_CODE(TYPEIO_CALL_COMMAND, 0x0002, 0, 0)
```

## Блок настроек `CMIC185V2_BASESETTINGS`

Структура в `mic185v2base.h` (выравнивание MSVC `#pragma pack(8)`):

- `ch[69]` — `CMIC185V2_BASECHAN_SETTINGS` (64 измерительных + 5 темп. слотов в общем массиве)
- `tCh[5]` — `BASE_CHAN_SETTINGS` (частота + connected)
- Параметры комплекса: SN, земля, времена коммутации (мкс), усреднение, питание DAC, шунт, групповые дополнения, флаги TKC/балансировки, `nSoftVersion`

Дефолты модуля (`MIC185V2_DEFAULT` в `computephysical.h`):

| Параметр | Значение |
|----------|----------|
| GndCommutMks_ | 100 мкс |
| ChnCommutMks_ | 150 мкс |
| BlnPortionLength_ | 30 |
| HardBalance_ | 8192 |
| AveragePointCount | 7 (2^7 усреднений) |
| PowermA_ | 10813 (~4 мА) |

Структура в `uMic185MebiusTypes.pas` должна совпадать с MSVC `#pragma pack(8)` (явные `_Pad*` после `bool` и `Word`). Размер blob: **3976** байт; `BlockSize` на смещении **8**, `MeasRangeIndex` на **12** внутри канала.

Дефолты канала (`mic185v2chanbase.cpp::Init`) и модуля (`MIC185V2_DEFAULT`):

| Параметр | Значение |
|----------|----------|
| MeasRangeIndex_ | `CHN_5_mV` (2) → ±5 мВ |
| CommutIndex_ | `CHN_COMMUT_IN` (0) → «Вход» |
| BlockSize | 1 |
| m_fltFreq | 100 Гц (задаётся при программировании) |

**Полная таблица UI ↔ blob ↔ коды АЦП:** [defaults.md](defaults.md).

## Пакеты данных

Типы (`mic185v2base.h`):

| idDev | Имя | Содержание |
|-------|-----|------------|
| 0 | `DEV_ID_UTS` | СЕВ (время) |
| 1 | `DEV_ID_MEAS_CHANNELS` | Измерительные каналы (float) |
| 2 | `DEV_ID_TEMP_CHANNELS` | Температурные каналы модулей |

Подробно: [temperature_channels.md](temperature_channels.md) — LM74, 1 Гц, отдельные пакеты, без ГХ.

Разбор измерительного блока — `CMIC185V2Scan::Decommutate`, case `DEV_ID_MEAS_CHANNELS`: interleaved float по каналам и сэмплам.

**Важно для порта (Lazarus):** поле `sampl_count_` в `UNIVERSAL_DATA_SAMPLE` — сквозной счётчик сэмплов (`pak.sampl_count()` в `mic185v2scan.cpp`), а не число float в текущем TCP-пакете. Число сэмплов в пакете вычисляется по длине payload (`Mic185MeasSamplesInPacket` в `uMic185MebiusTcpProtocol.pas`), с учётом ULONG-статусов по каналам при `type_ <> 0`.

Смещение массива float от начала payload: **12 байт** (`device_id` 4 + `INTERNAL_PACKET_HEADER` 8 с padding MSVC). Константа `CMic185PacketDataOffset`.

При активном потоке данных `TryIoControl` должен **пропускать** data-пакеты (`mpkData`), иначе ответы START/PROGRAM парсятся как IOCTL и дают ошибку.

## Чтение data-пакетов в стенде (`ReadMeasDataBlock`)

Три независимых потока (`device_id` 0/1/2) приходят в **одну TCP-сессию**. Стенд не может читать по одному meas-пакету на вызов — temp (1 Гц) теряется за meas (100 Гц).

Алгоритм `TRecorderMebiusTcpClient.ReadMeasDataBlock` (`uMic185MebiusTcpProtocol.pas`):

1. Цикл до **512** пакетов за такт источника.
2. Перед каждым чтением выполняется неблокирующая проверка сокета.
3. Неполный TCP-пакет сохраняется и дочитывается на следующем такте.
4. Пакеты `dev_id=1` → парсинг meas, запоминается **последний** успешный блок.
5. Пакеты `dev_id=2` → `Mic185ParseTempValues` (LM74→°C).
6. Пакеты `dev_id=0` → UTS.
7. Возврат: `True`, если хотя бы один meas-блок разобран.

`ReadBlock` в `uMic185Device.pas` возвращает только meas; temp/UTS — side cache (`fLastTempValues`, `fHasLastTemp`).

Счётчик `RxDataPacketCount` растёт на **все** data-пакеты в drain-цикле (обычно в несколько раз больше числа Blocks).

### Отличия транспорта, обязательные для длительного сбора

Оригинальный `CTCPLink` (`MebiusDAQ/DAQ/TCPLink/TCPLink.cpp`) задаёт
`SO_RCVBUF=4 MiB`, включает `SO_KEEPALIVE` и постоянно вычитывает TCP в
отдельном приёмном цикле. RecorderLnx сохраняет настраиваемый период публикации
данных, но также задаёт приёмный буфер 4 MiB и за один такт полностью осушает
доступный хвост. Малый системный буфер при периодической вычитке создаёт
обратное давление TCP и способен остановить задачу передачи в прошивке.

Разборщик повторяет восстановление `CPacketCollector`: при неверной сигнатуре
или CRC поиск заголовка сдвигается на один байт, а для старых пакетов проверяется
вариант `Size and $FFFF`. Ошибка одного фрагмента не должна завершать длительный
измерительный поток.

## Диагностика: версия ПО

`IOCTL_CMD_GET_SOFT_VERSION` возвращает `MIC185V2_HARD_DEVICE_INFO` (s/n, SoftVersion, HardVersion, Revision, метролог).

Кодирование SoftVersion: OMAP в битах 20+, NIOS в 10+, маска каналов `0x3FF`.

## Тестовый стенд

Подробно: [test_stand.md](test_stand.md).

| Инструмент | Команда |
|------------|---------|
| CLI | `mic185_acquire_test.exe [host] [port] [fs] [blocks]` |
| GUI | `mic185_acquire_gui.exe` |
| Автотест | `mic185_acquire_gui.exe --auto` |
| Сверка кодов | `mic185_acquire_gui.exe --verify` |
| Стабильность | `mic185_acquire_gui.exe --stress` (120 с) |
| Connect-only | `mic185_acquire_gui.exe --connect` |

Лог: `mic185_protocol_debug.log` (append, буфер до 3000 строк).

Параметры по умолчанию:

- Host: `192.168.9.142`
- Port: `4000`
- Каналов: `70` (64+5+1)
- Fs измерительных: `100` Гц
- Fs температурных: `1` Гц
- GUI poll: `tmrAcquire` **200 ms**
