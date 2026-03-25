# План доработок - Задание 4 (Режимы генерации DAC)

## Статус: Выполнено

1. Восстановить отдельный режим `SweepSin` в `tests\TestDAC`.
2. Перенести этот же режим на форму `uDACFrm` в `plgControlCyclogram`.
3. Убрать дублирование логики генерации из формы и держать генерацию в классах программ DAC.
4. Сохранить параметры `Mode`, `ProgramType`, `StartFreq`, `EndFreq`, `SweepTime` в INI.

## Итог

- В `uDacProgram.pas` добавлен `TSweepSinProgram`.
- В `tests\TestDAC\Unit1` добавлены переключение `Sin / SweepSin` и поля sweep-параметров.
- В `recorder\plgControlCyclogram\forms\uDACFrm` подключён тот же режим.
- Формы теперь выбирают активную программу, а не генерируют звук внутри UI.

- Исправлена перекодировка изменённых Delphi-файлов: рабочие .pas сохранены обратно в Windows-1251, в .dfm убраны склейки строк после правки.

- uDACFrm переведена на TRecFrm + cDacFrmFactory; gbSweepSin убран, параметры сведены в одну панель.
