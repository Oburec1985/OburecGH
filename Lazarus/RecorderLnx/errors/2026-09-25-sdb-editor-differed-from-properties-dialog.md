# 2026-09-25 — Редактор ГХ в БДГХ отличался от диалога свойств

## Симптом

Тензометрическая ГХ в просмотрщике БДГХ использовала общий редактор-frame,
а масштаб, прямая, таблица и полином отображались отдельными элементами
`uRecorderSdbSelectDialog`. Поэтому набор полей и поведение настройки одной и
той же ГХ зависели от места открытия.

## Причина

`TRecorderSdbSelectDialog.ShowStrainDetails` встраивал
`TRecorderStrainCalibrationFrame`, но остальные типы проходили через
специальные `gridPoints`/`pnFormulaDetails`. Общий диалог
`TRecorderCalibrationPropertiesDialog` не имел режима встраивания.

## Исправление

- `TRecorderCalibrationPropertiesDialog` получил режим `EmbedIn` без нижних
  modal-кнопок и публичное применение данных `ApplyChanges`.
- Для scale, linear, piecewise-linear и polynomial БДГХ создаёт clone и
  встраивает тот же редактор свойств в свою вкладку «Настройка».
- Кнопка «Сохранить ГХ» применяет этот редактор и обновляет исходную запись по
  её ключу; тензометрическая ГХ продолжает использовать свой общий frame.

## Проверка

`C:\lazarus\lazbuild.exe -B Lazarus\RecorderLnx\RecorderLnx.lpi` — успешно,
exit code 0. Визуальная проверка в Linux/MIC-200 относится к общей сборке и
deploy родительской итерации.

