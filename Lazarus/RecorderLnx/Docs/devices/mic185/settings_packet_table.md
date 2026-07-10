# MIC183/185 - таблица настроечного пакета

## Откуда взята информация

Сведения собраны 2026-07-10 по первичным исходникам и текущему порту RecorderLnx.

| Источник                                                                                     | Что взято                                                                                                                                                                                                                               |
| -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2base\mic185v2base.h`          | Структура `CMIC185V2_BASESETTINGS`, порядок полей, `#pragma pack(8)`, storage-id для настроек.                                                                                                                                          |
| `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2base\mic185v2chanbase.h/.cpp` | Структура `CMIC185V2_BASECHAN_SETTINGS`, дефолты канала, диапазон/коммутация/схема датчика.                                                                                                                                             |
| `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2base\computephysical.h/.cpp`  | Коды диапазонов, схем, шунтов, токов, групповых дополнений `ModAdditions`, расчет TKC.                                                                                                                                                  |
| `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2_pc\mic185v2.cpp/.h`          | Оригинальная последовательность программирования `SET_CONTROLLER_PARAMS -> PROGRAMM_DEVICE_BIN -> FINISH_PROGRAMMING`.                                                                                                                  |
| `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2_pc\mic185v2chan.cpp`         | Как режим канала принудительно выставляет диапазон, ток, схему датчика и термокомпенсационный канал.                                                                                                                                    |
| `D:\works\windev-v3.9\Mebius\MebiusDAQDevices\mic185v2\mic185v2_pc\mic185v2scan.cpp`         | Как `bTKC_` включает обработку температурных каналов для TKC.                                                                                                                                                                           |
| `D:\works\windev-v3.9\examples\mebius.daq\mebius_daq_devices\ms\mic185\`                     | Полезный переносимый пример Mebius DAQ по MIC185: подтверждает порядок программирования и заполнение `mod_settings`; самих базовых структур там нет, они подтягиваются через `mic185_base.h`/`mic185_chan_base.h` из общей Mebius-базы. |
| `D:\works\OburecGH\Lazarus\RecorderLnx\Device\mic185\uMic185MebiusTypes.pas`                 | Текущий Pascal-layout `TMic185BaseSettings`, `TMic185BaseChanSettings`, сборка `ProgramDeviceBin`.                                                                                                                                      |
| `D:\works\OburecGH\Lazarus\RecorderLnx\Device\mic185\uRecorderMic185DataSource.pas`          | Как RecorderLnx сейчас хранит и передает настройки каналов из source-config.                                                                                                                                                            |

Итоговый размер blob `CMIC185V2_BASESETTINGS` / `TMic185BaseSettings`: **3976 байт** при MSVC/FPC pack(8).

## Главный вывод по термокомпенсационному каналу

В оригинале выбор "канала термокомпенсации" для тензорежима не является полем отдельного измерительного канала. Он проходит через `MEPROPCH_MIC185V2_CHANTC` и записывает групповое поле прибора `GroupAddition_[group]` (`MEPROP_QUATER_BRIDGE_ADDITION_INDEX`). Затем `CopySettingsToPhysical()` переносит это в `CComputePhysical::AdditionIndex_`, а `EvalTKC()` использует выбранное дополнение для вычитания поправки.

В RecorderLnx до правки 2026-07-10 `GroupAddition[0..3]` всегда заполнялся `CMic185ModAddOff = 4`, а `TemperatureCompensation` (`bTKC_`) всегда был `False`. Теперь source-config хранит `groupAddition[]` и `temperatureCompensation`; дефолт для совместимости с текущим оригиналом: `groupAddition=[0,4,4,4]`, где `0 = CMic185ModAdd1`, и `temperatureCompensation=true`.

## `CMIC185V2_BASECHAN_SETTINGS` - один измерительный слот

Размер одного слота: **56 байт**. В пакете таких слотов **69**: 64 измерительных + 5 неиспользуемых в этом массиве температурных слотов. Отдельные температурные каналы идут ниже в `tCh[5]`.

| Offset внутри слота | Размер | Назначение | Оригинал Recorder / Mebius | RecorderLnx сейчас |
| ---: | ---: | --- | --- | --- |
| 0 | 4 | Частота канала, `m_fltFreq` | `CMIC185V2ChannelBase::Init` ставит 100 Гц; `UpdateFreq()` меняет все 64 канала. | `FrequencyHz`, обычно 100 Гц из source/default poll frequency. |
| 4 | 1 | Канал подключен, `m_bConnected` | `Connect()` ставит true, `Disconnect()` false. | Все 64 измерительных канала принудительно `Connected=True`, чтобы не менять порядок/размер потока. |
| 5 | 3 | Padding после `bool` | MSVC pack(8). | Явное `_PadAfterConnected`. |
| 8 | 2 | `BlockSize` | Дефолт 1, используется сканом для `SamplesInBlock`. | Дефолт/настройка `block`, обычно 1. |
| 10 | 2 | Padding перед ULONG | Выравнивание `MeasRangeIndex_`. | Явное `_PadBeforeMeasRange`. |
| 12 | 4 | Номинальный диапазон, `MeasRangeIndex_` | `CHN_500_mV=0`, `CHN_50_mV=1`, `CHN_5_mV=2`, `CHN_05_mV=3`. Режимы канала могут принудительно выбирать диапазон. | `range` сохраняется в `dataSources[].mic185.channels[].sourceValueMode` и пишется в пакет. |
| 16 | 4 | Программный баланс, `SoftBalance_` | `MEPROPCH_BALANCE_SOFT`, ограничен диапазоном `-32768..32767`. | `soft` пишется в пакет; отдельная процедура балансировки пока не реализована. |
| 20 | 4 | Коммутация, `CommutIndex_` | `0=Вход`, `1=Земля`, `2=49 мВ` (в старом UI может называться 39,2 мВ). | `commut` пишется в пакет. |
| 24 | 4 | Канальный шунт, `bShuntOn_` | `MEPROPCH_SHUNT_ON`; шунты: 63.6 кОм, 31.9 кОм, внешний+1 кОм, откл. | `shunt` пишется в пакет, UI-логика ограничена. |
| 28 | 4 | Тип КХ, `EvalType_` | `MEPROPCH_EVAL`, выбор таблицы преобразования. | `eval` пишется в пакет, обычно 0. |
| 32 | 8 | Тензочувствительность, `Tensosensitivity_` | Дефолт 2.0. | `sens` пишется в пакет, дефолт 2.0. |
| 40 | 8 | Номинал сопротивления датчика, `Resistance_` | Дефолт 200 Ом; используется в расчетах TKC. | `res` пишется в пакет, дефолт 200. |
| 48 | 4 | Схема датчика, `SensorScheme` | `CIRC_TENZO=0`, `CIRC_HALF=1`, `CIRC_BRIDGE=2`. В некоторых режимах принудительно задается через `MEPROPCH_SENSOR_TYPE`. | `scheme` пишется в пакет, но без `GroupAddition[]` и `bTKC_` сам по себе не включает опорный канал. |
| 52 | 4 | Хвостовое выравнивание | Размер структуры выравнивается до 56 байт. | Совпадает за счет FPC `{$PACKRECORDS 8}` и явных padding-полей. |

## `CMIC185V2_BASESETTINGS` - общий пакет прибора

| Offset | Размер | Назначение | Оригинал Recorder / Mebius | RecorderLnx сейчас |
| ---: | ---: | --- | --- | --- |
| 0 | 3864 | `ch[69]` | 64 измерительных канала заполняются из `pChan->GetSettings()`. Оставшиеся 5 слотов есть в структуре, но температурные настройки реально пишутся в `tCh[5]`. | Первые 64 слота заполняются из `TMic185ChannelProgramSettings`; слоты 64..68 очищаются нулями. |
| 3864 | 40 | `tCh[5]` | 5 температурных каналов `BASE_CHAN_SETTINGS`: частота 1 Гц, connected=true. | Все 5 температурных каналов: `FrequencyHz=ATempFrequencyHz`, `Connected=True`. |
| 3904 | 4 | `SN_` | Серийный номер прибора. | Пишется из `ADeviceSerial`, прочитанного через `GET_SOFT_VERSION`. |
| 3908 | 1 | `Gnd_` | Земля в циклограмме, в `Init` true. | `GroundEnabled := True`. |
| 3909 | 3 | Padding после `bool` | MSVC pack(8). | Явное `_PadAfterGround`. |
| 3912 | 4 | `GndCommutMks_` | Дефолт 100 мкс, `MEPROP_PERIOD_DECAY`. | `CMic185DefaultGndCommutUs = 100`. |
| 3916 | 4 | `ChnCommutMks_` | Дефолт 150 мкс, `MEPROP_COMMUT_ADCWAIT`. | `CMic185DefaultChnCommutUs = 150`. |
| 3920 | 4 | `BlnPortionLength_` | Дефолт 30, длина порции балансировки. | `CMic185DefaultBlnPortionLength = 30`. |
| 3924 | 4 | `HardBalance_` | Дефолт 8192, код ЦАП аппаратного баланса. | `CMic185DefaultHardBalance = 8192`. |
| 3928 | 2 | `AveragePointCount` | Дефолт 7, то есть 2^7 = 128 измерений усреднения. | `CMic185DefaultAveragePointCount = 7`. |
| 3930 | 2 | Padding после `USHORT` | Выравнивание `PowermA_`. | Явное `_PadAfterAverage`. |
| 3932 | 4 | `PowermA_` | Питание мА в кодах ЦАП; дефолт 10813 примерно 4 мА. | `PowerMaCode`; сохраняется как `dataSources[].mic185.powerMaCode`, пишется в пакет. |
| 3936 | 4 | `reserved_` | Перед программированием выставляется 0. | `Reserved := 0`. |
| 3940 | 4 | `bMaxFreqMode_` | Режим максимальной частоты на 1 канал. | Всегда 0. |
| 3944 | 4 | `CalibrShuntIndex_` | Дефолт 3 (`MOD_SHUNT_OFF`). | `CMic185DefaultCalibrShuntIndex = 3`. |
| 3948 | 16 | `GroupAddition_[4]` | Групповой выбор входа дополнения: `0..3` = вход 1..4, `4` = откл. `MEPROPCH_MIC185V2_CHANTC` пишет сюда по группе `channel div 16`. Это поле участвует в TKC/вычитании поправки. | Сохраняется как `dataSources[].mic185.groupAddition[]` и передается в `ProgramDeviceBin`. Дефолт: `[0,4,4,4]`, т.е. 1-й канал компенсации назначен первой группе 16 измерительных каналов. |
| 3964 | 1 | `bDetermineBreak_` | Определение обрыва/КЗ датчика. | `DetermineBreak := False`. |
| 3965 | 1 | `bHdBlnOn_` | Аппаратная балансировка включена/выключена. | `HardwareBalanceOn := False`. |
| 3966 | 1 | `bTKC_` | Общий флаг термокомпенсации, `MEPROP_TERMO_COMP`. В скане температурных каналов включает `CheckTempDeviation`, а расчеты TKC используют температуры модулей. | Сохраняется как `dataSources[].mic185.temperatureCompensation`, по умолчанию `true`, и передается в `ProgramDeviceBin` как `TemperatureCompensation`. |
| 3967 | 1 | Padding перед `nSoftVersion` | Выравнивание ULONG. | Явное `_PadBeforeSoftVersion`. |
| 3968 | 4 | `nSoftVersion` | Версия ПО прибора, проверяется оригинальным драйвером. | `SoftVersion := ASoftVersion`. |
| 3972 | 4 | Хвостовое выравнивание структуры | Итоговый размер до кратности 8: 3976. | Совпадает: `SizeOf(TMic185BaseSettings)` ожидается 3976. |

## Как оригинал связывает режим, схему и TKC

| Действие в оригинале | Поле пакета | Что делает |
| --- | --- | --- |
| Выбор диапазона/режима канала | `ch[i].MeasRangeIndex_` и общий `m_MeasRangeIndex` | `CMIC185V2Channel::SetProperty(MEPROPCH_MODE_ID)` может заменить пользовательский диапазон на диапазон, заданный режимом. |
| Выбор схемы датчика | `ch[i].SensorScheme` и общий `m_SensorScheme` | `MEPROPCH_SENSOR_TYPE` может быть принудительно задан режимом (`CountSensType == 1`). |
| Выбор тока питания | `PowermA_` | `MEPROPCH_MIC185V2_CURRENT` пишет общий `MEPROP_DAC_POWER_VALUE`. |
| Выбор термокомпенсационного канала | `GroupAddition_[channel div 16]` | `MEPROPCH_MIC185V2_CHANTC` кодирует `(AddInd << 8) | GroupNum` и вызывает `MEPROP_QUATER_BRIDGE_ADDITION_INDEX`. |
| Включение термокомпенсации | `bTKC_` | `MEPROP_TERMO_COMP` пишет `bTKC_`; температурный скан обновляет температуры модулей, а физический расчет использует `AdditionIndex_`. |

## Практическое расхождение для текущего бага

До правки 2026-07-10 RecorderLnx писал в пакет диапазон, коммутацию, шунт, программный баланс, чувствительность, сопротивление и `SensorScheme`, но два параметра, которые в оригинале отвечают за опорный/термокомпенсационный вход, не были представлены в настройках источника и не передавались в `ProgramDeviceBin`:

1. `GroupAddition_[4]` - выбор входа дополнения/термокомпенсационного канала по группе из 16 каналов.
2. `bTKC_` - общий флаг термокомпенсации.

После правки эти поля идут из source-config в устройство. Для старых проектов без явных полей применяется дефолт текущего оригинала: `GroupAddition[0]=CMic185ModAdd1`, остальные группы `CMic185ModAddOff`, `bTKC_=true`.
