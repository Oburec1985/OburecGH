# Добавление ступени pipeline выглядело как автозаполнение цепочки

## Симптом

В пустом pipeline ГХ после нажатия «Добавить» пользователь видел три строки
`ГХ 132`, `D1`, `y1` и воспринимал их как автоматически добавленные ступени.

## Подтверждённая причина

`TRecorderCalibrationListDialog.btnAddClick` в режиме pipeline открывал
`ShowRecorderCalibrationListDialog`. Это второй экземпляр того же диалога,
но уже со всем общим реестром `TRecorderCalibrationList`. Заголовок «Список ГХ»
и доступные кнопки управления не объясняли, что строки являются вариантами для
выбора одной ступени. До `OK` pipeline не изменялся; после `OK` добавлялось
только имя выбранной ГХ.

Call chain:

1. `TTagSettingsDialog.SelectCalibrationButtonClick`;
2. `ShowRecorderCalibrationPipelineDialog`;
3. `TRecorderCalibrationListDialog.btnAddClick`;
4. `ShowRecorderCalibrationListDialog`;
5. после подтверждения — один `fPipelineNames.Add(lSelected.Name)`.

## Исправление

Для выбора существующей ГХ введён явный режим `PickListItem`: заголовок теперь
просит выбрать одну ГХ, кнопка подтверждения называется «Добавить выбранную»,
а кнопки изменения общего списка скрыты. Компоновка LFM и данные pipeline не
изменялись.

## Проверка

Forced Windows build `RecorderLnx.lpi`: exit code 0, 54 warnings, 345 hints.

