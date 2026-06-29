# Миграция MIC-140 → MIC140v2

## Принцип

- `Device/MIC140/` — **рабочий** код; только исправления обмена и критические баги.
- `Device/MIC140v2/` — новая реализация по [device_abstraction.md](device_abstraction.md).
- Переключение в источнике данных — одна точка (фабрика / флаг).

## Этапы

| # | Этап | Артефакт | Критерий готовности |
|---|------|----------|---------------------|
| 1 | Документация | `Docs/devices/*`, [mic140/protocol.md](mic140/protocol.md) | Описаны этапы, свойства, протокол |
| 2 | Интерфейс | `uRecorderDeviceInterfaces`, `uRecorderAcquisitionTypes` | Сборка, без TIn в Core |
| 3 | Каркас v2 | `MIC140v2/*.pas` | Connect/Program/Start, логи |
| 4 | Обмен v2 | transport + workers | **этап A:** 3× PASS `mic140_preview_eval.ps1 -Seconds 3` |
| 5 | Подключение | DataSource → v2 | **этап B:** 3× PASS `-Seconds 10` |
| 6 | Упрощение | Удаление дублей | **этап C:** PASS `-Seconds 40` |

Критерии трёх проверок и порядок прогонов: [mic140/acceptance_tests.md](mic140/acceptance_tests.md).

## Что не переносим в Core

- Массивы температуры TIn в универсальном блоке отсчётов
- Заводские `TEMPER_OFFSET` в коде (только конфиг прибора)
- Тайминги scan в const — только `ScanConfig` + `LegacyTiming`

## Что переносим в MIC140v2

- Отдельный поток чтения + передача готового блока (вместо опроса `ReadBlock` из нескольких мест)
- `TRecorderMic140ProtocolDriver` как единая точка legacy/Mebius
- Конфигурация из `TRecorderMic140SourceConfig` / JSON

