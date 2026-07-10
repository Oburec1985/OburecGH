# MIC-185: пересчет значений и диапазонов в физических единицах

Информация взята из:

- `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2base\computephysical.h`
- `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2base\computephysical.cpp`
- `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2_pc\computephysical_pc.cpp`
- `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2_pc\mic185v2chan.h`
- `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2_pc\mic185v2chan.cpp`
- RecorderLnx: `Device/mic185/uRecorderMic185DataSource.pas`

## Как сделано в оригинале

Оригинальный канал MIC185V2 сначала переводит код АЦП в мВ через аппаратную ГХ/паспорт канала (`EvalU`). После этого физическая величина вычисляется в зависимости от режима:

| Режим/единица | Формула после пересчета кода в мВ |
| --- | --- |
| мВ | `value = U_mV` |
| Ом | `value = U_mV / I_mA` |
| Терморезистор | `R = U_mV / I_mA`, затем таблица ГХ термодатчика |
| Термопара | `U_mV`, затем таблица ГХ термопары |
| мВ(тензо) | `value = U_mV` на тензодиапазоне |

Ток питания в оригинале считается из DAC-кода:

```text
I_mA = ((((code * 5.0) / 16384.0) - 2.5) / 200.0) * 1000.0
```

Если расчетный ток равен нулю, оригинал использует защитный fallback `1 мА`.

## Как сделано в RecorderLnx

Протокол MIC-185 не меняется. Поток данных от устройства сейчас трактуется как сырой код канала. Перед записью samples в теги `TRecorderMic185DataSource.PublishMeasurementBlock` сначала переводит код в номинальные мВ, а затем пересчитывает результат в выбранные единицы.

Пока реальная аппаратная ГХ MIC-185 не прочитана из памяти прибора, используется номинальный fallback:

```text
U_mV = code * nominal_mV / 32768
```

Runtime mode note, 2026-07-10:

- If `TRecorderTag.HardwareCalibrationEnabled = False`, RecorderLnx publishes
  MIC185 raw ADC codes into the tag. The selected display unit and the stored
  hardware calibration name are not used in this mode.
- If `TRecorderTag.HardwareCalibrationEnabled = True`, RecorderLnx converts the
  code before publishing: assigned hardware GX is used when present; otherwise
  the nominal fallback above is used. The result is then converted to the
  selected MIC185 tag unit (`mV`, `Ohm`, `microstrain`, `mV(tenzo)`).

То есть `32768` кодов соответствует `100%` выбранного номинального диапазона. После появления чтения аппаратной ГХ этот шаг должен быть заменен пересчетом по реальным коэффициентам канала.

| Единица тега | Расчет значения в источнике данных | Расчет фактического диапазона |
| --- | --- | --- |
| мВ | `value = U_mV` | `± nominal_mV` |
| мВ(тензо) | `value = U_mV` | `± nominal_mV` |
| Ом | `value = U_mV / I_mA` | `± nominal_mV / I_mA` |
| мкм/м | `value = (U_mV / (I_mA * R_ohm)) * (schemeCoeff / K) * 1_000_000` | такая же формула от `nominal_mV` |

Для `мкм/м` используются настройки канала:

- `I_mA` - питание датчика из настройки модуля;
- `R_ohm` - номинал внешнего сопротивления;
- `K` - тензочувствительность;
- `schemeCoeff`: тензометр `4`, полумост `2`, мост `1`.

Аппаратная ГХ важна на первом шаге: она определяет, как коды устройства превращаются в мВ. В текущей реализации RecorderLnx чтение аппаратной ГХ MIC-185 из памяти прибора пока не реализовано без изменения протокольного слоя, поэтому используется номинальный пересчет `32768 -> 100% диапазона`.

## UI

Диалог свойств канала MIC-185 использует тот же расчет диапазона, что и источник данных. Поэтому поле "Входной диапазон фактический" обновляется при изменении:

- номинального диапазона;
- единицы фактического диапазона;
- питания датчика;
- схемы подключения;
- тензочувствительности;
- номинала внешнего сопротивления.
