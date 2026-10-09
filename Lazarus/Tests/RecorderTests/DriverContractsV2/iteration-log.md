# DriverContractsV2 iteration log

## 2026-10-07 — безопасный rollback callback

**Запрос:** Исключить передачу owning mutable snapshot в `AfterCommit`, чтобы
override не мог повредить rollback или вызвать double-free.

**Сделано:** Hook получает отделённое сериализованное значение предыдущего
снимка. Тестовый override изменяет только локальную копию и выбрасывает
исключение; live snapshot корректно откатывается.

**Проверка:** forced-сборка — exit code 0; contract test — `RESULT ... passed`.

**Статус:** готово; последний P2 аудита закрыт.

## 2026-10-07 — ownership, schema и атомарный snapshot commit

**Запрос:** Закрыть mutable-доступ к registry, формализовать владение фабриками,
валидировать descriptor schema и исключить частичный commit свойств.

**Сделано:** Registry публикует только Count/indexed getter; дескрипторы и defaults
проверяются при создании; commit выполняется сменой снимка с rollback при ошибке hook.

**Проверка:** forced-сборка — exit code 0; contract test — `RESULT ... passed`.

**Статус:** готово; MIC/UI/runtime не изменялись.

## 2026-10-07 — pure CalcProperties и enum-дескрипторы

**Запрос:** Дополнить строковый контракт чистым расчётом зависимых свойств без
изменения live-конфигурации и строгими перечислимыми свойствами.

**Сделано:** Добавлены `CalcProperties`, pure hook `CalculateCandidate`, enum-kind
с каноническим набором значений и проверки неизменности снимка.

**Проверка:** forced-сборка — exit code 0; contract test — `RESULT ... passed`.

**Статус:** готово; runtime по-прежнему не подключён.

## 2026-10-07 — additive hardware-driver v2 contracts

**Запрос:** Добавить изолированный общий слой результатов операций, транзакционных строковых свойств с типизированным каталогом и реестра фабрик драйверов с совместимым выбором v1.

**Сделано:** Добавлены новые архитектурные units и отдельный console contract test без подключения к runtime и изменения MIC/UI.

**Проверка:** `lazbuild -B RecorderDriverContractsV2Test.lpi` — exit code 0;
`lib/RecorderDriverContractsV2Test.exe` — `RESULT ... passed`, exit code 0.

**Статус:** готово; подключение к runtime намеренно не выполнялось.
