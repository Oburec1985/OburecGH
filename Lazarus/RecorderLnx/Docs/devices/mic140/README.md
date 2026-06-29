# MIC-140 (документация по прибору)

Материалы по модулю MIC-140 в составе RecorderLnx: обмен с контроллером MC031,
настройка скана, приём блоков измерений.

## Документы

| Файл | Содержание |
|------|------------|
| [protocol.md](protocol.md) | Краткое описание протокола: поиск, настройка, опрос, восстановление обмена |
| [acquisition_rules.md](acquisition_rules.md) | Правила приёма данных (resync, мусор, кольцо слотов, pacing) |
| [acceptance_tests.md](acceptance_tests.md) | Критерии успеха по логу: 3 проверки, прогоны 3/10/40 с |
| [migration_mic140v2.md](../migration_mic140v2.md) | Переход на реализацию `Device/MIC140v2` |

## Код

| Каталог | Назначение |
|---------|------------|
| `Device/MIC140/` | Рабочая реализация (поддержка, исправления обмена) |
| `Device/MIC140v2/` | Новая реализация по [device_abstraction.md](../device_abstraction.md) |

## Подробные материалы (архив)

Детальная отладка, история находок, длинные таблицы констант:

- [../../mic140_protocol.md](../../mic140_protocol.md)
- [../../mic140_legacy_scan_stream.md](../../mic140_legacy_scan_stream.md)
- [../../mic140_quickstart.md](../../mic140_quickstart.md)
