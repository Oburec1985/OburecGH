# Устройства и захват данных (RecorderLnx)

Каталог описывает **общий слой устройств** — соглашение между источником данных и драйвером
прибора, файла или симулятора.

## Документы

| Файл | Содержание |
|------|------------|
| [device_abstraction.md](device_abstraction.md) | Этапы работы, свойства, потоки, роли слоёв |
| [migration_mic140v2.md](migration_mic140v2.md) | Переход `Device/MIC140` → `Device/MIC140v2` |
| [mic140/](mic140/) | Документация по прибору MIC-140 (протокол обмена) |
| [mic185/](mic185/) | MIC183/185V2 — Mebius TCP, карта исходников, тестовый стенд |
| [mc/](mc/) | MC-крейты и MC-модули, включая MC-201 |

## Связанные материалы

- [data_sources_architecture.md](../architecture/data_sources_architecture.md) — источники данных и теги
- [recorder_run_lifecycle.md](../architecture/recorder_run_lifecycle.md) — жизненный цикл Recorder
- Оригинал: `windev-v3.9` — `IDevice.h`, `HubAPI/Device.h`, `hwiface/idevice.h`

## Код

```
Device/
  uRecorderDeviceInterfaces.pas   — IRecorderDevice, свойства, этапы
  uRecorderAcquisitionTypes.pas   — блок отсчётов
  MIC140/                         — рабочая реализация (багфиксы обмена)
  MIC140v2/                       — новая реализация
  MCbus/                          — MC-032, модули MC-201, runtime-источник и UI
Tests/mic185/                     — автономный стенд MIC185V2 (connect/program/read)
```
