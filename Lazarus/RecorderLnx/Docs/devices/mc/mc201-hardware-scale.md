# MC-201: аппаратная ГХ как масштабный коэффициент

См. также: [CHANGELOG.md](../../../CHANGELOG.md), [mc201-zero-balance-multi.md](mc201-zero-balance-multi.md).

## Зачем

Балансировочный ЦАП MC-201 задаёт известное напряжение смещения
(`V = UREF · (Lo/128) · (Hi/128)`). По Δcode АЦП при известном ΔV получается
калибровочный коэффициент **K [В/код]** для текущего диапазона канала.

В RecorderLnx аппаратная ГХ хранится как **`rckScale`** (`Y = K · X`), а не как
кусочно-линейная интерполяция — одно умножение на отсчёт.

В оригинальном Recorder масштабный преобразователь — COM ProgID
`MeraRecorder.ScaleTransformer.1` (не `InterpolateTransformer`).

## Путь Mera Files

Как у `Module::GetCalibrHardwareDir` → `hardware\MTC\`:

```
C:\Mera Files\Calibr\hardware\MTC\MC-201\snXXXX\<rangeDir>\NN.csv
C:\Mera Files\Calibr\hardware\MTC\MC-201\snXXXX\<rangeDir>\NN.tid
```

Пример: `...\MC-201\sn1462\01_10V\01.csv`.

- `NN` — канал 1..4.
- `.tid` — UTF-16 LE BOM + `MeraRecorder.ScaleTransformer.1`.
- `.csv` — две точки `(0,0)` и `(1,K)` (эквивалент масштаба K; удобно смотреть глазами).

Имена каталогов диапазонов — как `ranges_MC201[].name` в `mtc/Mc201.cpp`
(`01_10V` … `06_20mV`, для rev≥2176 — `01_27_5V` …).

## Сервисная процедура

1. Stop потока (SEND только на тихой шине — см. multi-balance).
2. `SEND` нейтрали `$8080` → Start → среднее A.
3. `SEND` известного сдвига (Lo/Hi offs = 20 → ~0.061 В @ UREF=2.5) → Start → среднее B.
4. Восстановить прежний код ЦАП.
5. `K = ΔV / (meanB − meanA)`.
6. Запись CSV/TID + upsert `rckScale` в реестр + `HardwareCalibrationEnabled` на тегах слота.

Код:

- `TRecorderMcbusDevice.CalibrateScaleByBalanceDacShift`
- `uRecorderMc201Calibration.pas` — пути, save, apply к тегам, пакет по слоту

## UI

Диалог свойств слота MC-201: группа «Аппаратная ГХ (масштаб K, В/код)»,
чекбоксы каналов, кнопка «Калибровка выбранных (сдвиг ЦАП)».

Нужны: Preview/Connect (live device), корректный SN модуля в поле диалога.

## Автозагрузка с диска

При `PrepareHardware` / `BuildChannelMap`, если:

1. у тега **включена** галочка «использовать аппаратную ГХ»;
2. в `SpecificConfigText` есть SN модуля (`Слот N: … SN=1465`) и диапазон
   (`CFG slot=N;c{ch}=…`);
3. существует файл  
   `Calibr\hardware\MTC\MC-201\snXXXX\<rangeDir>\NN.csv`;

то ГХ сразу читается в реестр как `rckScale` и назначается тегу
(`RecorderMc201ApplyHardwareCalibrations`).

Пропуск только если галочку **сняли**, но имя ГХ в теге ещё задано
(явный отказ). Если имя пустое и CSV есть — ГХ подгружается и галочка
включается (в т.ч. при открытии свойств тега).

Новые теги MC-201 при первом bind получают `HardwareCalibrationEnabled=True`.

## Публикация значений

`PublishBlock(..., AValuesAlreadyTransformed=False)` → при включённой и
назначенной ГХ применяется `rckScale`; иначе в тег идут **сырые коды**,
единица `код`. После успешной загрузки/калибровки единица — `В`.
