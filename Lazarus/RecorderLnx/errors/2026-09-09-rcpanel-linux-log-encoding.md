# rcPanel: кракозябры в журнале Linux

## Симптом

В Linux GUI строка результата команды начиналась повреждённым текстом, тогда
как следующий за ним ASCII JSON оставался читаемым.

## Причина

`TCoordinatorMainForm.SendCommandTo` объединял русский строковый литерал из
UTF-8 исходника с `TJSONData.AsJSON` типа `UTF8String`. Активные модули
Coordinator с русскими литералами не объявляли кодовую страницу исходника.
Из-за смешения кодовых страниц литерал перекодировался повторно; HTTP-пакет и
JSON повреждены не были.

## Исправление

В `uCoordinatorMainForm`, `uCoordinatorModel` и `uCoordinatorConfig` добавлена
директива `{$codepage UTF8}`. Runtime-преобразования не добавлялись, чтобы не
создать вторую перекодировку.

## Проверка

Чистые сборки RecorderCoordinator для Windows и Linux завершены с кодом 0.
Linux payload rcPanel обновлён. Сценарий проверки: команда Preview/Record должна
дать строку `Команда поставлена: {"result_code":"noError",...}`.

