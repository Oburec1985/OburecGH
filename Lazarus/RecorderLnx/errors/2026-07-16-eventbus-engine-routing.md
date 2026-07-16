# Штатные модели были связаны через EventBus

## Симптом и риск

`TRecorderAlarmEngine` получал значения тегов только через подписку на
`rceDataUpdated`. Обязательная связь ядра была скрыта в runtime-списке подписок.
При первоначальном переносе на прямой scalar-callback обнаружился риск пропуска
блочных каналов: их итоговое значение приходит через block-tail.

## Причина

EventBus одновременно использовался как внешний механизм уведомлений и как
внутренний вызов штатной функции. Это скрывало полный контракт доставки данных.

## Исправление

- `TRecorderTagRegistry` явно вызывает модель `TRecorder` для scalar и block-tail;
- `TRecorder` явно вызывает `IRecorderAlarmEngine.ProcessTagValue`;
- AlarmEngine больше не подписывается на `rceDataUpdated`;
- spectrum runtime не содержит неиспользуемых EventBus handlers;
- EventBus сохранён только для UI, расширений и пассивного журнала событий.

## Проверка

- полная сборка `RecorderLnx.lpi`: exit code 0;
- `RecorderTagsTest.exe`: PASS;
- `RecorderEventQueueTest.exe`: PASS;
- `TestSpectrumMath2.exe`: PASS;
- статический поиск активных `Subscribe` показывает только spectrum UI,
  extension manager и snapshot queue.

## Правило предотвращения

См. `RLNX_EXPLICIT_ARCHITECTURE_CALLS_2026_07_16` и дополнение о проверке
scalar/block/block-tail в `Docs/development-rules.md`.
