# Параллельная миграция драйверов MIC-140/MIC-185 на v2

## Цель

Создать альтернативные чистые реализации `MIC140v2` и `MIC185v2`, не меняя
поведение существующих проектов и не дублируя общие механизмы RecorderLnx.
Ориентир — ясное разделение factory/device/datasource и строковый property
channel из `D:\works\delphi2020\Recorder\Devices\MIC-140`.

## Что сохраняется из RecorderLnx

- `TRecorderDataSourceBase`, manager, worker и параллельная подготовка;
- registry тегов, configured sources, live/offline registry;
- общие блоки acquisition и публикация в теги;
- отдельные protocol/stream/calibration/config units;
- общий UI facade и provider/capability boundaries.

Новый `TDeviceManager`, второй transport framework и polling worker тестового
MIC-140 не переносятся.

## Структура v2

Новые реализации размещаются в `Device/MIC140v2` и `Device/MIC185v2` с
уникальными unit/class names. Legacy units не переименовываются и продолжают
собираться одновременно.

Различаться могут protocol codec, transport/session и acquisition adapter.
Общими для v1/v2 должны быть:

- типизированная конфигурационная модель и validation;
- channel layout, адреса, единицы и configuration signature;
- lifecycle orchestrator и structured operation result;
- block transformer/publisher;
- property descriptors и общий settings dialog.

## Фабрики и выбор реализации

Ввести реестр `IRecorderHardwareDriverFactory` с устойчивыми идентификаторами:

- `FamilyId`: `mic140`, `mic185`;
- `ImplementationId`: `v1`, `v2`;
- recognize/config parse, capabilities/catalog;
- создание device, acquisition adapter и datasource composition.

Выбор хранится для каждого configured source как `DriverId`/implementation.
Старый проект без поля всегда выбирает `v1`. Один глобальный флаг и
compile-time selection не используются. Один endpoint может иметь только
одного владельца транспорта независимо от поколения драйвера.

Переключение разрешено только в stopped-состоянии:

`Stop/Disconnect old -> create/prepare new -> atomic replace`.

После начала I/O автоматический fallback между поколениями запрещён. При
неуспехе нового prepare сохраняются прежняя конфигурация и рабочая v1.

## Единый канал свойств

Строковый интерфейс — внешний адаптер для общего UI, скриптов и ABI, но не
внутренний источник истины. Внутри драйвера остаётся typed config.

Опциональный capability, не ломающий существующий `IRecorderDevice`:

- `Describe` — versioned typed property schema/catalog;
- `GetProperties` — чтение cached snapshot без I/O;
- `CalcProperties`/`Validate` — pure calculation без мутации;
- `SetProperties`/`Commit` — parse all, validate all, atomic typed commit;
- явный `Refresh` — единственная операция чтения прибора.

Descriptor содержит stable key, caption/category/order, type, scope,
read/write, value/default, unit, min/max/step, enum values и validation text.
Результат возвращает stage/code/text и требуемый effect: `none`,
`reconfigure`, `reconnect` или `restartAcquisition`.

Legacy `name=value;...` поддерживается адаптером, но production parser обязан
строго обрабатывать unknown/duplicate/read-only keys, locale-independent числа
и escaping. Неверный пакет не должен частично менять конфигурацию.

Общий диалог работает только через schema/capability и не содержит ветвлений
по MIC, v1/v2 или конкретным классам. Сетевые операции и lifecycle выполняются
service/orchestrator, не GUI-потоком.

## Атомарный порядок внедрения

1. Characterization tests текущих source factory и lifecycle.
2. Additive operation result, property capability/catalog и factory registry.
3. Адаптер v1 и общий schema-driven settings dialog без смены runtime-драйвера.
4. `MIC140v2`, A/B selection и rollback при stopped source.
5. После parity MIC-140 — `MIC185v2` на тех же общих контрактах.
6. Миграция default только после стендовой приёмки; удаление legacy отдельно.

## Обязательная проверка

- старые проекты без selector используют v1 и сохраняют SourceId/tag identity;
- forced Windows и Linux build одновременно содержат v1/v2;
- property tests: all/subset/unknown/malformed/duplicate/locale/read-only,
  invalid batch atomicity, Calc без мутации и I/O;
- parity: defaults, caps, channel layout, units/Fs, config signature;
- одинаковые raw frames дают одинаковый acquisition block;
- lifecycle trace и ошибки совпадают по публичным стадиям;
- v1 -> stopped switch -> v2 -> project reload -> v1 без потери тегов, ГХ и
  единиц;
- failed v2 prepare возвращает рабочую v1;
- два устройства разных поколений работают одновременно, но один endpoint не
  открывается двумя реализациями.

