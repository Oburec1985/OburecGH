# MIC-140 (документация по прибору)

Материалы по модулю MIC-140 в составе RecorderLnx: обмен с контроллером MC031,
настройка скана, приём блоков измерений.

## Документы

Главная точка входа для повторной реализации:

- [protocol/00_full_reproduction_spec.md](protocol/00_full_reproduction_spec.md) —
  транспорт, команды, ревизии, полный жизненный цикл, Config, форматы DM/FIFO,
  тайминги и формат потока на подтверждённом MIC-140-48v3.

| Файл | Содержание |
|------|------------|
| [protocol.md](protocol.md) | Краткое описание (устаревший монолит; см. [protocol/](protocol/)) |
| [protocol/](protocol/) | **Полное описание протокола** (MDP, коммутируемый АЦП, BIOS, приёмка) |
| [protocol/08_timing_and_count_aver.md](protocol/08_timing_and_count_aver.md) | Алгоритм таймингов: 640, 50 kHz, `PERIOD_TIMER_WORK`, расчёт `count_aver` |
| [acquisition_rules.md](acquisition_rules.md) | Правила приёма данных (resync, мусор, кольцо слотов, pacing) |
| [acceptance_tests.md](acceptance_tests.md) | Критерии успеха по логу: 3 проверки, прогоны 3/10/40 с |
| [migration_mic140v2.md](../migration_mic140v2.md) | Переход на реализацию `Device/MIC140v2` |

## Код

| Каталог | Назначение |
|---------|------------|
| `Device/MIC140/` | Рабочая реализация (поддержка, исправления обмена) |
| `Device/MIC140v2/` | Новая реализация по [device_abstraction.md](../device_abstraction.md) |
| `Tests/Mic140ProtocolDebug/` | Автономный стенд `Mic140Example` |

## Подробные материалы (архив)

Детальная отладка, история находок, длинные таблицы констант:

- [../../mic140_protocol.md](../../mic140_protocol.md)
- [../../mic140_legacy_scan_stream.md](../../mic140_legacy_scan_stream.md)
- [../../mic140_quickstart.md](../../mic140_quickstart.md)
