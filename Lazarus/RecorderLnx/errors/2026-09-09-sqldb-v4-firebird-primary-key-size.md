# SQLdb v4: Firebird key size exceeds implementation restriction

## Симптом

При подключении RecorderLnx к существующей Firebird БД миграция schema v4
завершалась на `Commit` ошибкой `key size exceeds implementation restriction`
для автоматически названного индекса `RDB$PRIMARY...`.

## Причина

Добавленная вместе с MERA events таблица `mera_recording_files` использовала
составной первичный ключ `(recording_id, relative_name)`. Для Firebird/UTF8
максимальный ключ `varchar(36) + varchar(500)` занимает примерно 2144 байта без
учёта служебных данных и превышает предел индексного ключа.

SQLite-тест schema v4 не моделирует ограничения индексов Firebird, поэтому
дефект не был обнаружен до работы с реальной БД.

## Исправление

Первичный ключ изменён на компактный `(recording_id, file_id)`. Оба значения —
UUID длиной 36 символов, поэтому ключ безопасен для Firebird. Полное
`relative_name varchar(500)` остаётся неиндексируемым и не обрезается. Логика
идемпотентного upsert по `(recording_id, relative_name)` сохранена.

Если предыдущая попытка миграции была откатана Firebird, при следующем запуске
таблица создаётся с исправленным ключом. Существующие прикладные таблицы и
данные не удаляются.

## Остаточные риски

`data_files.storage_key varchar(500) unique` остаётся близко к пределу ключа
Firebird. На текущей БД он создавался раньше проблемного PK, но для поддержки
малого page size нужен отдельный hash-key и реальный Firebird integration test.

## Проверка

- `RecorderLnx.lpi` и `RecorderSqlDbMeraEventsTest.lpi` собраны с `-B`, exit 0;
- тест выполнен на рабочей `C:\Mera Files\SQLdb\recorderlnx.fdb` два раза;
- оба запуска: `RESULT SQLdb Firebird schema v4 migration passed`;
- `schema_info` обновлена с версии 3 до 4;
- Firebird подтверждает PK `(RECORDING_ID, FILE_ID)`;
- прежняя таблица `signals` сохранена и содержит 1363 записи; все четыре
  таблицы событий/пакетов schema v4 присутствуют;
- `git diff --check` не обнаружил ошибок.
