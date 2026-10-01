# SQL data source выбрасывал ошибку при открытии

## Симптом

Двойной клик по `SQL database` в дереве устройств сразу открывал Firebird
для чтения сигналов. При недоступном сервере показывалось модальное
сообщение, а в отладчике была остановка на `ERecorderSqlDbError`.

## Причина

`ShowRecorderSqlDataSourceSettings` вызывал общий click-handler
`btnReadDbSignalsClick(nil)`. Автоматическая проверка не была отделена от
явной команды пользователя и не обновляла offline-cache дерева.

## Исправление

- Чтение списка сигналов вынесено в `TryReadDbSignals` с невыбрасывающим
  TCP-preflight и возвратом текста ошибки.
- Автозагрузка при открытии диалога не показывает MessageDlg; кнопка
  явного чтения сохраняет диагностику для пользователя.
- Неуспех помечает `SQL database` через общий
  `RecorderHardwareMarkSourceOffline`; успех очищает признак.
- Дерево сразу перестраивается и использует общую сбойную иконку
  data source.

## Проверка

- Forced Windows build `RecorderLnx.lpi`: exit code 0.
- `git diff --check`: без ошибок пробелов.
