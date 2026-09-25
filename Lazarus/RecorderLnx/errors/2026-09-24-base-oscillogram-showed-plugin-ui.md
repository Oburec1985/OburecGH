# Базовая осциллограмма показывала интерфейс плагинного осциллографа

## Симптом

После развития плагинного `Oscillograph` простая встроенная осциллограмма
получила расширенную панель управления, предназначенную только для плагина.

## Подтверждённая причина

`TRecorderOscillogramComponent.TypeId` возвращает `Oscillogram`, а
`TRecorderOglOscillogram.Configure` проверял базовый тип регистрозависимым
сравнением с литералом `oscillogram`. Условие всегда считало встроенную фабрику
плагинной и вызывало `BuildPluginControls` / `BuildToolBar`.

## Исправление

- Тип фабрики сравнивается через `SameText` с
  `TRecorderOscillogramComponent.TypeId`.
- Расширенная панель остаётся только у фабрик осциллограмм, зарегистрированных
  плагинами.
- Базовой многооконной поверхности возвращены прежние безопасные отступы
  подписей `42/30/10/24`.
- Отложенное создание OpenGL-контрола после назначения `Parent` сохранено: это
  отдельное исправление ошибки `Control has no parent window`.

После повторного сравнения с родителем коммита `3b4d1f56` выяснилось, что
регрессия затронула не только видимость панели. В общий view и общий диалог
попали mouse handlers, trigger/cursor state, несколько осей и расширенные ключи
сериализации. Исправление расширено:

- в модели введены единые capability-проверки
  `RecorderIsBuiltInOscillogram` / `RecorderIsPluginOscillograph`;
- mouse handlers, trigger, cursor snapping, plugin repaint, X/Y scale и
  multi-axis ветки выполняются только для plugin Oscillograph;
- базовый диалог снова компактный и содержит исторические настройки каналов,
  привязки, цвета и видимости; расширенные оси/масштабы/триггер показываются
  только плагину;
- базовая осциллограмма снова запрещает дубли каналов и каналы разных
  `SourceId`, как до plugin integration;
- расширенные `Osc*` ключи сохраняются и читаются только для plugin factory;
  при чтении базового компонента следы ошибочно записанного advanced-state
  игнорируются и сбрасываются к одной простой оси.

## Проверка

Forced-сборки завершились успешно:

- `RecorderLnx.lpi` — exit code 0;
- `Plugins/SampleInfoPlugin/SampleInfoPlugin.lpi` — exit code 0.

После полного capability-разделения повторная forced-сборка
`RecorderLnx.lpi` также завершилась с exit code 0.

`RecorderFormModelTest` обновлён двумя раздельными сценариями round-trip:

- base Oscillogram сохраняет привязку и линии, но отбрасывает `ClosedInput`,
  дополнительные оси и назначения линий на plugin-оси;
- factory `test.oscillograph` сохраняет `ClosedInput`, `XScale`, две оси,
  масштабы/смещения и назначение линии на вторую ось.

Forced-сборка теста и запуск `RecorderFormModelTest.exe` — exit code 0, все
пять сценариев passed.
