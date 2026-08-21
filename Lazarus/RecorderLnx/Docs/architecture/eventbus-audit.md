# Аудит использования EventBus

Дата аудита: 16.07.2026.

## Правило

EventBus используется только там, где набор получателей динамический и не
является частью обязательного порядка работы ядра: UI-наблюдатели, расширения,
плагины и универсальная очередь снимков событий. Штатные модели вызывают друг
друга явно.

## Явные штатные маршруты

| Маршрут | Реализация |
|---|---|
| публикация тега → алгоритмы | `TRecorderTagRegistry` вызывает `TRecorderAlgorithmManager` через назначенные scalar/block handlers |
| Recorder → lifecycle алгоритмов | `TMainForm` явно вызывает `PrepareConfiguration`, `ValidateStateTransition`, `HandleStateTransition` |
| публикация тега → тревоги | Для scalar и block-tail `TRecorderTagRegistry` вызывает модель `TRecorder.HandleTagAlarmValue`, затем `IRecorderAlarmEngine.ProcessTagValue` |
| менеджер → Spectrum | `TRecorderAlgorithmManager` явно вызывает `TRecorderSpectrumAlgorithm.DoEvalValue/DoEvalBlock` |

## Разрешённые динамические подписчики

| Подписчик | Почему EventBus допустим |
|---|---|
| `TRecorderSpectrumView` | UI-компонент создаётся/удаляется динамически и наблюдает готовые кадры спектра |
| `TRecorderExtensionManager` | состав расширений и их интерес к событиям неизвестен ядру во время компиляции |
| `TRecorderEventSnapshotQueue` | универсальный наблюдатель всех событий для журнала/UI; не управляет движковым lifecycle |

## Разрешённые публикации

- `rceDataUpdated` — уведомление динамических расширений и журнала после того,
  как обязательные алгоритмы и тревоги уже вызваны явно;
- `rceSpectrumFrame` — уведомление динамически созданных spectrum view;
- `rceAlarmChanged` — уведомление UI/расширений об уже рассчитанном состоянии;
- `rceInitialized`, `rceConfigurationPrepared`, `rceRunTransitionBefore/After` —
  внешние lifecycle-уведомления; сами штатные операции выполняются прямыми
  вызовами до публикации события.

## Запрещённый шаблон

Нельзя подписывать через EventBus алгоритм, тревоги, источник данных, хранилище
или другую обязательную модель только ради вызова её штатного метода. При новом
таком маршруте следует добавить явную зависимость/метод модели и оставить событие
только как последующее уведомление динамических потребителей.
