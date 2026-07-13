# MIC-185: дисковый кэш аппаратной ГХ

## Откуда взята информация

- `D:\works\OburecGH\Lazarus\RecorderLnx\Device\MIC140\uRecorderMic140Calibration.pas` - текущая рабочая схема RecorderLnx для MIC140: `Calibr\hardware\MIC140\snXXXX\<range>\NN.csv`.
- `C:\Mera Files\Calibr\hardware\MIC140\sn0164\06_100mV\01.csv` - проверенный на стенде файл MIC140: простой текстовый CSV `x,y`, без заголовка.
- `D:\works\windev-v3.9\Mebius\MebiusDAQ\Base\BaseVirtualChannel.cpp` - стандартный путь оригинального Mebius/Recorder: `GetCalibrDir + GetCalibrSubDir + "%02d.csv"`, затем `m_evaluator.ExportToText/ImportFromText`.
- `D:\works\windev-v3.9\Mebius\System\MebiusScaleLinear.cpp` и `ScaleEvaluators.h` - линейный evaluator хранит коэффициенты `A/B` и вычисляет линейное преобразование.
- `D:\works\windev-v3.9\examples\mebius.daq\mebius_daq_devices\ms\mic185\mic185.cpp` - для MIC185 коэффициенты `k,b` читаются из прибора через `IOCTL_CMD_GET_CALIBR_KOEF`.
- RecorderLnx: `Device/mic185/uRecorderMic185Calibration.pas`.

## Путь

Для MIC185 RecorderLnx использует тот же тип хранилища, что и MIC140, но в отдельной ветке:

```text
C:\Mera Files\Calibr\hardware\MIC-185\snXXXX\rangeN\CC.csv
C:\Mera Files\Calibr\hardware\MIC-185\snXXXX\current\CC.csv
```

Где:

- `snXXXX` - серийный номер прибора с ведущими нулями, например `sn0164`;
- `rangeN` - выбранный диапазон MIC185 в пользовательской нумерации `1..4`;
- `current` - линейная аппаратная ГХ тока питания датчика, используемая оригинальным Recorder в пересчете Ом как `mV / power_mA`;
- `CC.csv` - номер измерительного канала `01..64`.

Пример:

```text
C:\Mera Files\Calibr\hardware\MIC-185\sn0164\range1\01.csv
```

## Формат файла

Файл является текстовым CSV без заголовка, как в текущем MIC140-хранилище RecorderLnx:

```text
x0,y0
x1,y1
```

Для MIC185 аппаратная ГХ из прибора приходит как `k,b`, где исходная формула evaluator:

```text
y = k * (code - b)
```

RecorderLnx сохраняет ее как двухточечную кусочно-линейную ГХ:

```text
0,-k*b
1,k*(1-b)
```

При чтении из CSV `k,b` восстанавливаются из двух точек и отображаются в диалоге тега как:

```text
k=...; b=...
```

## Поведение RecorderLnx

- При нажатии кнопки вычитки ГХ для MIC185 сначала вычисляется текущий канал и диапазон.
- Если известен серийный номер и CSV уже есть на диске, ГХ поднимается с диска и прибор не опрашивается повторно.
- Если CSV нет, RecorderLnx читает текущий evaluator из прибора командой `IOCTL_CMD_GET_CALIBR_KOEF`, регистрирует ГХ в `TRecorderTagRegistry`, назначает ее тегу и сохраняет CSV.
- Стабильное имя ГХ теперь имеет вид `MIC185 snXXXX rangeN chCC`; оно сохраняется в проекте и позволяет после следующей загрузки найти CSV на диске.
- При открытии диалога тега, если имя ГХ сохранено в теге, но объект ГХ еще не загружен в registry, RecorderLnx пытается поднять его из дискового кэша.
- При публикации данных MIC185 выполняется такая же ленивая подгрузка: если флаг аппаратной ГХ включен, имя сохранено, а объект ГХ не загружен, источник сначала пробует CSV-кэш и только затем продолжает штатный путь пересчета.

## Совместимость с оригинальным Recorder

Стандартная Mebius-логика для виртуальных/аппаратных ГХ работает через каталог `Calibr`, подкаталог устройства и файл `NN.csv`. Это подтверждено в `CBaseVirtualChannel::UpdateDevTareDB/QueryDevTareFromDB`.

Для MIC185 в оригинальном Recorder эта стандартная ветка фактически обходится: коэффициенты канала читаются драйвером из прибора и кладутся прямо в evaluator. Поэтому RecorderLnx сохраняет MIC185 в стандартное CSV-дерево самостоятельно, чтобы не перечитывать прибор при каждом открытии/смене диапазона и сохранить совместимость с уже используемой схемой `Mera Files\Calibr`.
