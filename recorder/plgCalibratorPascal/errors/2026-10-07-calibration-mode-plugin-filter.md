# Плагин не получает уведомления в режиме поверки

## Симптом

Нужно определить, будет ли `plgCalibratorPascal` продолжать опрос Elmetra Pascal и передачу давления в виртуальный тег при сборе данных во время поверки Recorder.

## Подтверждённые факты

- Recorder при `RS_CALIBRATE_MODE` перед каждым уведомлением вызывает у плагина `getproperty(PLGPROP_CLB_ASSIGNED, ...)` и пропускает уведомление, если значение ложно: `D:\works\windev-v3.9\mr\pluginsman.cpp:343-348`.
- Исключение сделано только для `PN_ON_SWITCH_CALIBR_MODE`; остальные уведомления, включая `PN_RCSTART`, `PN_RCSTOP`, `PN_UPDATEDATA`, отфильтровываются.
- В `TCalPascalPlg.GetProperty` реализован только `PLGPROP_INFOSTRING`: `units\uCalibratorPluginClass.pas:573-584`. Поэтому значение `PLGPROP_CLB_ASSIGNED` остаётся `false`, которым Recorder заранее инициализирует `VARIANT`.
- В используемом модуле `SharedRUnits\interfaces\plugin.pas` после `PLGPROP_STATE = 2` отсутствует `PLGPROP_CLB_ASSIGNED = 3`.
- Поток опроса запускается из обработки перехода Recorder в `RS_VIEW`/`RS_REC` через `PN_RCSTART`: `units\uCalibratorPluginClass.pas:210-295, 533-538`.
- Сам поток опрашивает прибор и вызывает `FInputTag.PushValue(...)`, только когда Recorder не в `RS_STOP`: `units\uCalibratorThread.pas:226-320`.
- Собранная DLL датирована 2026-07-02 и соответствует текущему исходнику без поддержки `PLGPROP_CLB_ASSIGNED`.

## Вывод

Текущая DLL не гарантирует и в штатном сценарии не должна участвовать в сборе данных в режиме поверки: Recorder исключает её из рассылки до запуска/обновления логики плагина.

## Требуемое исправление

1. Добавить в актуальный Pascal-интерфейс `PLGPROP_CLB_ASSIGNED = 3` (следующее значение C++ enum после `PLGPROP_STATE`).
2. В `TCalPascalPlg.GetProperty` возвращать для этого ID `Value := True; Result := True;`. Присваивание Boolean в `OleVariant` формирует ожидаемый `VT_BOOL`.
3. Пересобрать DLL Delphi 2010 и проверить в Recorder сценарий: вход в поверку → старт сбора → рост значения `Pascal_Pressure` → останов → выход из поверки.

## Остаточный риск

Стендовая проверка с запущенным Recorder и физическим калибратором ещё не выполнена.

## Исправление и проверка

- В оба Pascal-описания интерфейса добавлено `PLGPROP_CLB_ASSIGNED = 3`.
- `TCalPascalPlg.GetProperty` возвращает `Value := True; Result := True`.
- Устранено безусловное затирание результата `Notify`; общая обработка уведомления теперь по умолчанию успешна.
- Полная Release-сборка Delphi 2010 прошла успешно после замены несовместимого с Delphi 2010 `FormatSettings.DecimalSeparator` на глобальный `DecimalSeparator` в `sharedUtils\math\uCommonMath.pas`.

## Правило предотвращения

При переносе новых свойств Recorder синхронно обновлять все Pascal-копии интерфейса и проверять числовые значения по C++ SDK; затем выполнять полную Delphi 2010 Release-сборку. В общем коде, собираемом Delphi 2010, использовать доступный этой версии глобальный `DecimalSeparator`, а не поздний `FormatSettings.DecimalSeparator`.
