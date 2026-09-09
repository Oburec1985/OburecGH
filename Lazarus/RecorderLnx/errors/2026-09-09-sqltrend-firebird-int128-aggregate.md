# SQL-тренд: `Fieldtype Unknown is not supported`

## Симптом

После появления MERA events SQL-тренд очищался и показывал
`Fieldtype Unknown is not supported`.

## Подтверждённая причина

`ListMeraRecordingEvents` и `ListMeraPackages` вычисляли
`COALESCE(SUM(data_files.file_size),0)`. `file_size` имеет тип `BIGINT`, но
Firebird 4/5 возвращает для `SUM(BIGINT)` тип `INT128`. Драйвер
FPC 3.2.2 `TIBConnection/SQLDB` этот тип не поддерживает и не может открыть
result dataset. `MAX`, `MIN` и `COUNT` из этих запросов ошибку не вызывали.

SQLite-тест ошибку не обнаруживал, а прежний Firebird-режим проверял только
версию схемы, но не открывал проблемные запросы.

## Исправление

В обоих запросах итог агрегата приведён снаружи:

```sql
CAST(COALESCE(SUM(f.file_size), 0) AS BIGINT)
```

Схема и сохранённые данные не изменяются.

## Проверка

- forced build `RecorderSqlDbMeraEventsTest.lpi` — OK;
- на настроенной Firebird `ListMeraRecordingEvents` вернул 1 событие;
- `ListMeraPackages` вернул 1 пакет;
- forced build `RecorderLnx.lpi` — OK.

## Правило предотвращения

См. `RLNX_FIREBIRD_AGGREGATE_RESULT_TYPE_2026_09_09` в
`Docs/architecture/development-rules.md`: SQL с агрегатами принимать открытием
реального dataset на Firebird, а неподдерживаемые расширенные типы приводить к
типу, поддерживаемому SQLDB.
