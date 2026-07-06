# MIC183/185 (тензоизмерительный комплекс)

Документация по прибору **MIC183/185** (в конфигураторе Recorder — «Комплекс тензоизмерительный») для порта RecorderLnx.

Прибор с прошивкой **20.x.x** (например `20.6.6`, s/n 157, `192.168.9.142:4000`) в конфигураторе Recorder отображается как **MIC183/185**. Внутри Mebius используется драйвер `medaq_mic185v2` (код типа `MIC185V2_DEVICE_TYPE = 0x442A`) — это не отдельный «v2»-прибор в UI, а имя модуля в исходниках.

Каналы в Recorder: **64** тензо (100 Гц) + **5** температурных (1 Гц) + **1** СЕВ/UTS (1 Гц) → `rdpChannelCount = 70`.

## Документы

| Файл | Содержание |
|------|------------|
| [protocol.md](protocol.md) | Mebius TCP: подключение, программирование, старт, приём блоков |
| [defaults.md](defaults.md) | **Настройки по умолчанию**, коммутация, усреднение, **коды АЦП** (эталон Recorder) |
| [windev_mic185_test.md](windev_mic185_test.md) | Эталонный GTest `windev/examples/mebius.daq/tests/mic185_test` |
| [source_map.md](source_map.md) | Карта исходников оригинального Recorder (windev-v3.9) |
| [architecture.md](architecture.md) | Аппаратная структура, каналы, пакеты данных |

## Код RecorderLnx

| Каталог | Назначение |
|---------|------------|
| `Tests/mic185/` | CLI `mic185_acquire_test` + GUI `mic185_acquire_gui` |
| `Device/MIC140/uRecorderMebiusTcpProtocol.pas` | Общий Mebius TCP-клиент (в основном приложении; в тесте — локальная копия) |

## Два пути в оригинальном Recorder

| Путь | Тип устройства | Протокол | Когда |
|------|----------------|----------|-------|
| **MIC185V2** (Mebius) | `MIC185V2_DEVICE_TYPE = 0x442A` | TCP:4000, MEBE + IOCTL | Прошивка OMAP 19–20, комплекс MS046+MI183 |
| **MIC0185** (legacy) | `MIC0185_TYPE = 0x4129` | MDP через MC031, модуль MC114 | Старые конфигурации с модулем MC114 |

Для прибора из скриншота (версия `20.6.6`, 20 каналов, ±5 мВ) актуален путь **MIC185V2**.

## См. также

- [MIC-140](../mic140/README.md) — аналогичный Mebius TCP-стек для другого прибора
- [device_abstraction.md](../device_abstraction.md) — абстракция `IRecorderDevice`
