# MIC183/185 (тензоизмерительный комплекс)

Документация по прибору **MIC183/185** (в конфигураторе Recorder — «Комплекс тензоизмерительный») для порта RecorderLnx.

Прибор с прошивкой **20.x.x** (например `20.6.6`, s/n 157, `192.168.9.142:4000`) в конфигураторе Recorder отображается как **MIC183/185**. Внутри Mebius используется драйвер `medaq_mic185v2` (код типа `MIC185V2_DEVICE_TYPE = 0x442A`) — это не отдельный «v2»-прибор в UI, а имя модуля в исходниках.

Каналы в Recorder: **64** тензо (100 Гц) + **5** температурных (1 Гц) + **1** СЕВ/UTS (1 Гц) → `rdpChannelCount = 70`.

## Документы

| Файл | Содержание |
|------|------------|
| [protocol.md](protocol.md) | Mebius TCP: IOCTL, blob, пакеты данных, drain |
| [architecture.md](architecture.md) | Аппаратная структура, потоки данных, отличия от MIC-140 |
| [defaults.md](defaults.md) | Настройки по умолчанию, коммутация, **коды АЦП** (эталон Recorder) |
| [temperature_channels.md](temperature_channels.md) | Temp LM74, 1 Гц, `dev_id=2`, без ГХ |
| [test_stand.md](test_stand.md) | **Стенд Lazarus**: CLI/GUI, стабильность, диагностика |
| [windev_mic185_test.md](windev_mic185_test.md) | Эталонный GTest windev |
| [source_map.md](source_map.md) | Карта исходников windev и порта Lazarus |
| [settings_packet_table.md](settings_packet_table.md) | Таблица `ProgramDeviceBin`: назначение, размер, оригинал, RecorderLnx |
| [hardware_calibration_cache.md](hardware_calibration_cache.md) | Дисковый кэш аппаратной ГХ MIC185 в `Mera Files\Calibr\hardware\MIC-185` |
| [recorderlnx_integration.md](recorderlnx_integration.md) | Интеграция драйвера MIC183/185 в RecorderLnx, LFM-диалоги и поток тегов |

## Быстрый старт (стенд)

```bat
cd Lazarus\RecorderLnx\Tests\mic185
lazbuild -B mic185_acquire_gui.lpi
mic185_acquire_gui.exe
```

Connect → Start. Лог: `mic185_protocol_debug.log`.

Регрессия: `mic185_acquire_gui.exe --stress` (120 с).

## Код RecorderLnx

| Каталог | Назначение |
|---------|------------|
| `Tests/mic185/` | CLI + GUI стенд (полная копия протокола) |
| `Device/MIC140/uRecorderMebiusTcpProtocol.pas` | Общий Mebius TCP в основном приложении |

Стенд **автономен**: `device/uMic185MebiusTcpProtocol.pas` — локальная копия с доработками MIC185.

## Два пути в оригинальном Recorder

| Путь | Тип устройства | Протокол | Когда |
|------|----------------|----------|-------|
| **MIC185V2** (Mebius) | `MIC185V2_DEVICE_TYPE = 0x442A` | TCP:4000, MEBE + IOCTL | Прошивка OMAP 19–20, комплекс MS046+MI183 |
| **MIC0185** (legacy) | `MIC0185_TYPE = 0x4129` | MDP через MC031, модуль MC114 | Старые конфигурации с модулем MC114 |

Для прибора из примера (версия `20.6.6`, 20 активных тензоканалов, ±5 мВ) актуален путь **MIC185V2**.

## Потоки данных (кратко)

```
TCP :4000
  ├─ dev_id=1  meas   100 Гц   float[64]  коды АЦП
  ├─ dev_id=2  temp     1 Гц   float[5]   LM74 → °C в драйвере
  └─ dev_id=0  UTS      1 Гц   float[1]   время (СЕВ)
```

## См. также

- [MIC-140](../mic140/README.md) — аналогичный Mebius TCP-стек для другого прибора
- [device_abstraction.md](../device_abstraction.md) — абстракция `IRecorderDevice`
- [Tests/mic185/README.md](../../../Tests/mic185/README.md) — краткий README стенда
