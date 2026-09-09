# События MERA-записи в SQL и распределённый архив

**Статус:** ADR-lite / решение для реализации  
**Дата:** 04.09.2026  
**Команда:** Куратор, Системщик, Протоколист, Эргономист, Скептик

## Контекст

Несколько RecorderLnx на разных ПК могут писать разные приборы в одну SQL БД.
SQL-тренд должен показывать события MERA-записи, позволять выбрать событие,
открыть его замеры в WinПОС и скопировать их на ПК SQL-сервера.

Schema v3 уже содержит `events`, `data_files`, `data_file_links` и
`ListAttachments`. Но MERA-контур не вызывает `SubmitFile`, а текущий
`TRecorderSqlDbFileStore` копирует один файл в локальный каталог клиента. При
удалённом Firebird это не каталог серверного ПК. Кроме того, MERA-замер — пакет:
`.mera`, `frame.ini` и связанные `.dat/.x/.ptr/.prt`.

## Решение и инварианты

1. Расширить существующую файловую модель, не создавать параллельную систему.
2. Один `mera_recording` описывает пакет одного Recorder. Связанное событие
   `events.event_type='mera.recording'` является маркером тренда.
3. Пишущий ПК идентифицируется постоянным UUID экземпляра Recorder, не IP,
   hostname или локальным путём.
4. В SQL хранятся UTC-время, метаданные и относительные ключи. Для совместимости
   v4 сохраняет текущий формат `Double/TDateTime`.
5. `ready` означает, что файл найден и проверен по размеру и SHA-256.
6. SQL-соединение не переносит файлы. Копирование выполняет отдельный
   `RecorderArchiveService` либо явно выбранный SMB-адаптер.
7. GUI, сбор данных и `Paint/MouseMove` не выполняют blocking I/O. Ошибка SQL
   или архива не останавливает основную MERA-запись.
8. «Перенести» в первой версии означает скопировать и проверить; исходник не
   удаляется.

## Schema v4

### `recorder_instances`

`id varchar(36) PK`, `instance_key varchar(100) unique`, `host_name`,
`display_name`, `platform`, `last_seen_at_utc`. `instance_key` создаётся один
раз и сохраняется локально.

### `system_settings`

Прикладная, а не системная `RDB$` таблица: `setting_key PK`, `value_text`,
`value_type`, `updated_at_utc`, `updated_by_instance_id`. Обязательные ключи:
`archive.mera.root` (каталог на ПК архивного сервиса) и
`archive.service.base_url`. Корень меняет только `archive_admin`; секреты здесь
не хранятся.

### `mera_recordings`

`id PK`, `event_id`, `recorder_instance_id`, nullable `registration_id`,
nullable `correlation_id`, `display_name`, `started_at_utc`, `finished_at_utc`,
`state`, `entry_file_id`, `project_name`, `error_text`.

Состояния: `recording -> finalizing -> ready-local -> transferring -> archived`;
ошибки: `incomplete`, `failed`, `missing`. `correlation_id` объединяет общий
запуск нескольких ПК; группировать только по близости времени нельзя.

### `mera_recording_files`

Связь пакета с существующими `data_files`: `recording_id`, `file_id`,
`file_role`, `relative_name`, `ordinal`; уникальность
`(recording_id, relative_name)`. Роли: `entry-mera`, `channel-data`, `time`,
`index`, `frame-info`, `aux`.

### `data_file_locations`

`id PK`, `file_id`, nullable `recorder_instance_id`, `location_kind`,
`path_key`, `state`, `created_at_utc`, `verified_at_utc`, `error_text`;
уникальность `(file_id, location_kind, recorder_instance_id)`. Расположения:
`source`, `server-archive`, `cache`; состояния: `pending`, `uploading`, `ready`,
`missing`, `corrupt`, `failed`. `data_files.storage_key` остаётся legacy-полем.

Индексы: `events(event_type,timestamp_utc)`,
`data_file_links(anchor_time_utc)`,
`mera_recordings(started_at_utc,finished_at_utc,state)`,
`data_file_locations(file_id,state)`.

## Жизненный цикл

1. `OpenRecordFrame` создаёт UUID, сохраняет его в `frame.ini` и асинхронно
   публикует `recording`. Это не зависит от медленной SQL-регистрации.
2. При Stop сначала останавливается сбор, затем `fMeraWriter.Close` формирует
   окончательный descriptor.
3. До очистки `CurrentFrameDir` строится manifest: относительные имена, роли,
   размеры и SHA-256.
4. Одной транзакцией выполняется идемпотентный upsert события, пакета, файлов,
   связей и исходных расположений; состояние становится `ready-local`.
5. После аварии UUID восстанавливается из `frame.ini`, а пакет становится
   `incomplete` или дозавершается reconciler-ом.

## Архивный сервис

`RecorderArchiveService` на ПК сервера читает `archive.mera.root`, принимает
manifest и чанки, пишет в `<root>/.incoming/<recording>/*.part`, проверяет
размер/SHA-256, атомарно публикует и только затем отмечает location как `ready`.
Повтор с тем же UUID и checksum идемпотентен. Нужны resume, cancel, прогресс и
ограниченный параллелизм. `path_key` всегда относительный; `..`, абсолютные
диски и выход за корень запрещены.

## Сетевой клиент RecorderLnx

RecorderLnx содержит отдельный `RecorderCoordinatorClient`, который работает
в собственном worker-потоке и первым устанавливает исходящее соединение с
координатором. Recorder по умолчанию не открывает управляющий TCP-порт: это
упрощает firewall, Linux/Windows-развёртывание и работу через маршрутизаторы.

Транспорт разделён по назначению:

- постоянный `WSS` control channel — команды, подтверждения, heartbeat и
  небольшие события;
- `HTTPS` API — получение/изменение конфигурации, manifest, upload/download и
  диагностические операции;
- CLI и GUI координатора используют тот же публичный API, а не отдельные
  реализации протокола.

Адреса endpoint, TLS и режим клиента задаются в одном конфигурационном объекте
RecorderLnx; URL нельзя прошивать в формах или сетевых units. Для первой
локальной отладки допустим явный opt-in HTTP, production-профиль требует TLS.

### Версионированный конверт

Каждое JSON-сообщение имеет поля:

```text
protocol_version, message_id, message_type, instance_id,
correlation_id, reply_to, sent_at_utc, payload
```

`message_id` и `command_id` обеспечивают идемпотентность. Получатель сначала
отвечает `accepted/rejected`, затем отдельным `result` после фактического
выполнения. Повтор уже завершённой команды возвращает прежний результат и не
повторяет Start/Stop.

### Сообщения Recorder → Coordinator

- `client.hello` — instance UUID, версия, ОС, возможности и проект;
- `client.heartbeat` — состояние приложения, запись, свободное место и ошибки;
- `state.changed` — значимое изменение без ожидания следующего heartbeat;
- `recording.started`, `recording.completed`, `recording.failed`;
- `recording.manifest.ready` — метаданные законченного MERA-пакета;
- `command.accepted`, `command.rejected`, `command.result`;
- `config.applied`, `config.rejected`;
- `storage.test.result` и `diagnostics.result`.

### Команды Coordinator → Recorder

- `state.get`;
- `recording.current.get` — текущий и последний законченный замер;
- `recording.get` — карточка замера по `recording_id`;
- `recording.manifest.get` — полный состав законченного пакета;
- `recording.location.resolve` — актуальное исходное расположение и
  доступность файлов;
- `recording.prepare`;
- `recording.start_at` с `correlation_id` и UTC-временем;
- `recording.stop`;
- `recording.cancel_prepare`;
- `config.validate`, `config.apply`, `config.get`;
- `storage.test`;
- `manifest.resend` и `file.upload.request`.

Ответ `recording.current`/`recording.info` содержит `recording_id`,
`correlation_id`, времена, состояние, `source_uri`, локальный абсолютный путь
для диагностики, entry `.mera`, число файлов, общий размер и признак
доступности. Основной ссылкой является
`recorder://<instance_id>/<recording_id>/<relative_name>`: локальный путь может
измениться, иметь другой синтаксис в Linux и не обязан быть доступен серверу.

Для активной записи путь уже может быть возвращён, но manifest помечается
`building`, а файлы нельзя считать готовыми к переносу до
`recording.completed`. Если каталог исчез, Recorder отвечает `missing`, а не
возвращает прежний путь как доступный. Запрос состояния/пути является только
чтением и никогда не запускает финализацию или копирование скрыто.

Удалённая команда не вызывает устройства или LCL прямо из сетевого потока.
Клиент передаёт типизированную команду в `RecorderCommandDispatcher`, который
проверяет состояние и вызывает публичный `ApplicationController`. Результат
возвращается кодом (`noError`, `notReady`, `alreadyRecording`,
`deviceOffline`, `insufficientDiskSpace`, `invalidProject`, `timeout`,
`accessDenied`); исключения оставлены для внутренних дефектов.

### Конфигурация и владение

Настройки координатора изменяются через API самого координатора. Recorder
может читать разрешённый snapshot и запрашивать изменение, но не редактирует
напрямую `system_settings`. Настройки конкретного Recorder передаются как
версионированный документ с `revision`, `expected_revision` и checksum:

1. `config.validate` выполняет проверку без применения;
2. `config.apply` принимается только при совпадении ревизии;
3. изменение сохраняется атомарно;
4. ответ перечисляет применённые и отклонённые поля;
5. настройки устройств применяются только через штатные lifecycle-команды.

Пароли и ключи не передаются как обычные поля проекта. Используются ссылки на
локальное защищённое хранилище секретов. Права разделяются на `viewer`,
`operator`, `config_admin`, `archive_admin`.

### Состояние соединения и offline

Состояния клиента: `disabled`, `connecting`, `authenticating`, `online`,
`backoff`, `offline`, `stopping`. Heartbeat отправляется раз в 2–5 секунд;
координатор использует lease, например 15 секунд. Reconnect выполняется с
ограниченным exponential backoff и jitter.

Критичные события и результаты команд до подтверждения хранятся в ограниченном
локальном spool. При восстановлении они отправляются с прежними UUID. Сбор и
локальная MERA-запись продолжаются без координатора. Устаревшая команда
`start_at` не выполняется после reconnect, если её deadline уже прошёл.

### Групповой запуск

Координатор выполняет `prepare -> ready/error -> start_at`. Все участники
получают общий `correlation_id`; `start_at` задаётся с запасом после подготовки.
При ручном старте одного Recorder он сообщает `recording.started`, после чего
координатор по политике может подготовить и запустить остальные. Временное
окно используется только как fallback для записей без общего ID.

Точность командного старта ограничена синхронизацией часов ОС и планировщиком.
Для точного совмещения измерений источником истины остаётся аппаратное
время/UTS, а не момент получения сетевой команды.

### Реализованный SQL lifecycle координатора

Координатор может создавать SQL-события записи. Флаг
`events/create_recording_events` в соседнем `RecorderCoordinator.ini` и
галочка «Создавать события записи в SQL БД» включают или полностью отключают
эту функцию. Подключение к БД задаётся секцией `[SQLdb]` того же INI; при
необходимости `events/sql_db_config` указывает отдельный файл SQL-настроек.

Любой `recording.started` создаёт событие либо присоединяется к последнему
событию, если от первого старта прошло строго меньше `EventWindowSec`. Причина
старта и входной `correlation_id` на группировку не влияют. Старт ровно на
границе окна создаёт новое событие. Для каждого Recorder создаётся отдельная
`mera_recordings`. `recording.completed` завершает ранее начатую запись только
по устойчивому `recording_id`; объединять завершения по близости времени
запрещено. Путь
entry-файла хранится в `data_file_locations.path_key`, переносимый ключ — в
`mera_recording_files.storage_key`. Повтор lifecycle-сообщения идемпотентен.
Ошибка или отсутствие SQL не блокирует локальную MERA-запись.

### Безопасность и ограничения

- TLS с проверкой сертификата; предпочтительно mTLS либо короткоживущий token;
- allow-list команд и schema-validation payload;
- защита от replay по message ID, deadline и времени;
- аудит инициатора, команды, результата и целевого Recorder;
- ограничение размеров сообщений, очереди, upload и числа параллельных задач;
- удалённая конфигурация и запись могут быть запрещены локальной политикой;
- `Stop` и аварийные локальные команды имеют определённый приоритет над
  удалённым Start.

## SQL-тренд и WinПОС

Расширение выполняется в `TRecorderSqlTrendView`:

- события `mera.recording` загружаются всеми SQL-клиентами и рисуются
  пунктирными вертикальными маркерами;
- наведение выбирает событие и включает кнопку «Открыть в WinПОС»;
- диалог пакетов разрешает физический файл только через
  `data_file_locations.path_key` и запускает его системным `OpenDocument`
  (`ShellExecute` в Windows); логический `recorder://` как путь не используется.

- существующий worker загружает точки и immutable snapshot событий диапазона;
- начало рисуется вертикальным пунктиром, длительность — тонкой полосой сверху;
- события в 4–6 px объединяются в кластер с числом;
- `MouseMove` использует binary search и допуск 6 px без SQL/FileExists;
- hover показывает время, длительность, ПК, число пакетов, размер и статус;
- клик закрепляет выбор, иначе после ухода к кнопке hover исчезнет;
- локальная кнопка `Открыть в WinПОС` активна при hover/selection. Глобальная
  кнопка главной формы остаётся для последнего локального замера.

Новый `TRecorderMeraEventDialog` показывает логические пакеты и команды:
`Открыть выбранные`, `Открыть все`, `Перенести выбранные`, `Перенести все`.
Локальный `ready` открывается напрямую; серверный `ready` скачивается в кэш,
проверяется и затем открывается через entry `.mera`. Все передачи фоновые, с
progress/cancel и отдельным результатом каждой строки.

## Атомарный порядок реализации

1. **v4a:** общие DTO, JSON envelope и тесты совместимости протокола.
2. **v4b:** client state machine, heartbeat, reconnect и локальный mock server.
3. **v4c:** command dispatcher для `state/prepare/start_at/stop`.
4. **v4d:** schema + repository API + migration/upsert/query tests.
5. **v4e:** lifecycle и manifest завершённого локального пакета.
6. **v4f:** read-only markers, hover и pin в SQL-тренде.
7. **v4g:** диалог и открытие локальных пакетов в WinПОС.
8. **v4h:** archive-service, upload/download, staging, resume, reconciler.
9. **v4i:** серверный open через проверенный локальный cache.

Каждый этап принимается отдельно. Независимые непротокольные правки можно
объединять; за одну итерацию меняется не более одного протокольного контракта.

## Приёмочная матрица

- один локальный пакет: точный UTC-маркер, hover, pin, открытие `.mera`;
- несколько пакетов: `все` и `выбранные` не смешиваются;
- одинаковые локальные пути разных ПК не конфликтуют;
- перекрывающиеся события выбираются из кластера;
- offline source + server copy открывается через проверенный кэш;
- missing/corrupt файл не запускается и не мешает остальным;
- повтор submit/upload не создаёт дублей;
- multi-GB передача не блокирует GUI, поддерживает cancel/resume;
- live reload не сбрасывает zoom/pan;
- курсоры, zoom, удаление интервала и легенда не регрессируют;
- пустая и существующая v3 БД мигрируют на поддерживаемых backend;
- пробелы/кириллица и отсутствие ассоциации `.mera` диагностируются;
- вредоносный `path_key` не выходит за archive/cache root.
- повтор команды с тем же UUID не создаёт второй Start/Stop;
- disconnect/reconnect не теряет подтверждённые события и не исполняет
  просроченный `start_at`;
- сетевой worker не обращается к LCL и устройствам напрямую;
- запрос текущего и завершённого замера возвращает устойчивый URI, реальный
  локальный путь и достоверную доступность без запуска побочных операций;
- активный незакрытый пакет нельзя выдать за готовый к переносу;
- конфликт ревизии конфигурации отклоняется без частичного применения;
- локально запрещённое дистанционное управление остаётся запрещённым.

## Открытые продуктовые решения

До этапа v4e выбрать транспорт: HTTPS `RecorderArchiveService`
(рекомендуется) либо SMB. Также определить источник общего `correlation_id`,
ретенцию, права удаления и поведение WinПОС при открытии нескольких `.mera`.
