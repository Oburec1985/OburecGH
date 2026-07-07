# MIC183/185 — автономный стенд (Tests/mic185)

Стенд для отладки Mebius TCP (MIC185V2) без зависимости от MIC-140.

## Сборка

```bat
C:\lazarus\lazbuild.exe -B mic185_acquire_test.lpi
C:\lazarus\lazbuild.exe -B mic185_acquire_gui.lpi
```

Перед пересборкой GUI закройте `mic185_acquire_gui.exe` (иначе линковщик не перезапишет exe).

## CLI: connect → program → start → read

```bat
mic185_acquire_test.exe [host] [port] [meas_fs_hz] [blocks]
```

По умолчанию: `192.168.9.142 4000 100 5`.

С sniff пакетов (лог в `mic185_protocol_debug.log`):

```bat
mic185_acquire_test.exe -sniff 192.168.9.142 4000 100 3
```

## GUI

Интерактивно: `mic185_acquire_gui.exe` — Connect / Program / Start / Stop, таблица 70 каналов, лог.

Автотест (без ручных кликов, для CI/отладки):

```bat
mic185_acquire_gui.exe --auto
mic185_acquire_gui.exe --verify
mic185_acquire_gui.exe --stress
```

`--stress`: Connect → Start → 120 с захвата (для проверки стабильности GUI).

### GUI: счётчик пакетов и сверка с Recorder

В шапке формы:
- **Packets / Blocks** — TCP data-пакеты и успешно разобранные meas-блоки
- **Recorder ref** — сводка совпадений с эталоном (`defaults.md`)

Таблица каналов: **Code | Ref | Δ | Match** (для тензоканалов 1–50 с эталоном).

`--verify`: Program с дефолтами Recorder → Start → сверка кодов АЦП с `defaults.md` (модуль `uMic185CodeVerify`).

Цепочка `--auto`: Connect → Program → Start → 10× ReadBlock → Stop → Disconnect. Код выхода 0 при успехе.

CLI со сверкой кодов:

```bat
mic185_acquire_test.exe -verify-codes 192.168.9.142 4000 100 5
```

## Каналы

Как в Recorder: **64** тензо + **5** темп + **1** СЕВ (`rdpChannelCount=70`).

Температура: отдельные пакеты `dev_id=2`, 1 Гц, LM74→°C без ГХ — [temperature_channels.md](../../Docs/devices/mic185/temperature_channels.md).

## Лог

`mic185_protocol_debug.log` в каталоге exe. GUI дублирует в Memo (в режиме `--auto` сначала только файл, чтобы не ловить AV при ранней инициализации LCL).

## Известные детали протокола

- Data-пакеты: `id_from = DATA_TRANSMIT_TASK_ID` или `0x3E904000` (см. `PacketDispatch.cpp` в windev).
- В теле пакета `sampl_count` — **сквозной счётчик**, не число сэмплов в блоке; размер блока считается по длине payload (`Mic185MeasSamplesInPacket`).
- `TryIoControl` пропускает data-пакеты в очереди (иначе Start/Program ломаются при активном потоке данных).
- `ProgramDeviceBin`: в blob передаются `SerialNumber` и `SoftVersion` с устройства; `GroupAddition[]=MOD_ADD_OFF(4)`.
- Парсинг meas: смещение данных **12** байт (MSVC `INTERNAL_PACKET_HEADER`); см. `CMic185PacketDataOffset`.

## Документация

Подробнее: [Docs/devices/mic185/](../../Docs/devices/mic185/README.md)  
Настройки и коды АЦП: [defaults.md](../../Docs/devices/mic185/defaults.md)  
Температура (LM74): [temperature_channels.md](../../Docs/devices/mic185/temperature_channels.md)  
Полное описание стенда: [test_stand.md](../../Docs/devices/mic185/test_stand.md)  
Эталон windev: [windev_mic185_test.md](../../Docs/devices/mic185/windev_mic185_test.md)
