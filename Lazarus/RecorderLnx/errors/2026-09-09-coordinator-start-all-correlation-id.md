# Coordinator: остановка на «Запустить все»

## Симптом

При включённом Recorder групповая команда запуска приводила отладчик к
`TRecorderSqlDbRepository.BeginMeraRecording`, `ExecSQL`.

## Причина

GUI Coordinator создавал `correlation_id` через `GUIDToString` и оставлял
фигурные скобки. Получалось 38 символов, тогда как
`mera_recordings.correlation_id` имеет тип `varchar(36)`. Firebird выбрасывал
ошибку усечения строки при записи lifecycle.

Lazarus показывает first-chance exception до входа в обработчик. Основной
store перехватывал исходное исключение, однако аварийный `CloseRepository`
сам не был защищён и мог выпустить вторичное исключение.

## Исправление

- GUI отправляет UUID без `{}`;
- модель нормализует ID повторно на серверной HTTP-границе;
- oversized внешний ID не передаётся в Firebird;
- закрытие repository в exception-handler не выбрасывает вторичную ошибку.

## Проверка

- forced build `RecorderCoordinator.lpi` — OK;
- model test с UUID в скобках — OK;
- при работающем Recorder POST группового `recording.start` с UUID в скобках
  вернул канонический 36-символьный ID;
- Coordinator после команды остался Responding, `/api/v1/status` — OK.

## Предотвращение

Правило `RLNX_SQL_HTTP_UUID_BOUNDARY_2026_09_09` записано в
`Docs/architecture/development-rules.md`.
