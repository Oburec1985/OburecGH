# Устройства и захват данных (RecorderLnx)

Каталог описывает **общий слой устройств** — соглашение между источником данных и драйвером
прибора, файла или симулятора.

## Документы

| Файл | Содержание |
|------|------------|
| [device_abstraction.md](device_abstraction.md) | Этапы работы, свойства, потоки, роли слоёв |
| [migration_mic140v2.md](migration_mic140v2.md) | Переход `Device/MIC140` → `Device/MIC140v2` |
| [mic140/](mic140/) | Документация по прибору MIC-140 (протокол обмена) |

## Связанные материалы

- [data_sources_architecture.md](../data_sources_architecture.md) — источники данных и теги
- [recorder_run_lifecycle.md](../recorder_run_lifecycle.md) — жизненный цикл Recorder
- Оригинал: `windev-v3.9` — `IDevice.h`, `HubAPI/Device.h`, `hwiface/idevice.h`

## Код

```
Device/
  uRecorderDeviceInterfaces.pas   — IRecorderDevice, свойства, этапы
  uRecorderAcquisitionTypes.pas   — блок отсчётов
  MIC140/                         — рабочая реализация (багфиксы обмена)
  MIC140v2/                       — новая реализация
```

