# MIC183/185 in RecorderLnx

Дата фиксации: 2026-07-06.

## Код

Production-копии файлов стенда лежат в `Device/mic185/`. RecorderLnx не
подключается к `Tests/mic185` через unit path и не зависит от тестового проекта.

Основные файлы:

| Файл | Назначение |
|---|---|
| `Device/mic185/uMic185Device.pas` | `TRecorderMic185Device`, программирование прибора и `ReadBlock` |
| `Device/mic185/uMic185MebiusTcpProtocol.pas` | Mebius TCP, IOCTL, чтение data-пакетов |
| `Device/mic185/uMic185MebiusTypes.pas` | blob `CMIC185V2_BASESETTINGS` |
| `Device/mic185/uRecorderMic185DataSource.pas` | адаптер в `TRecorderDataSourceBase` |
| `Device/mic185/UI/uRecorderMic185SettingsDialog.pas/.lfm` | главный диалог MIC183/185 |
| `Device/mic185/UI/uRecorderMic185AdditionalDialog.pas/.lfm` | дополнительные свойства |
| `Device/mic185/UI/uRecorderMic185ChannelDialog.pas/.lfm` | свойства канала |

В `Device/uRecorderDeviceInterfaces.pas` добавлен базовый `TRecorderDevice` и
`IRecorderDevice.GetNativeObject`, как в MIC185-стенде. Старые MIC140-классы
возвращают `Self`, чтобы контракт остался совместимым.

## SourceId и теги

MIC185-источник имеет вид:

```text
MIC-185: 192.168.9.142:4000
```

Логические каналы:

| Группа | Адрес/имя | Частота |
|---|---|---|
| Измерительные | `MIC183_185-{3-1}` ... `MIC183_185-{3-64}` | 100 Гц по умолчанию |
| Температурные | `MIC183_185-{3-t1}` ... `MIC183_185-{3-t5}` | 1 Гц |
| UTS | `MIC183_185-{3-uts}` | 1 Гц |

Диалог настроек RecorderLnx восстанавливает MIC185-источники из тегов и
`ActiveSourceIds`, показывает их в дереве устройств, а double-click по каналу
добавляет или снимает тег так же, как для MIC140.

## Поток данных

`TRecorderMic185DataSource` в `PrepareHardware` делает:

1. `CreateRecorderMic185Device`
2. `Connect`
3. `ProgramDevice`

В `Start` выполняется `StartMeasurement`. В каждом `Tick` вызывается
`ReadBlock(timeout)`. Измерительные каналы публикуются блоком через:

```text
TRecorderTagRegistry.AddBlockSamples
TRecorderTagRegistry.PublishBlockNotifications
```

Это сохраняет блочную структуру потока. Для 10 Гц при `DataUpdateMs = 100` в
нормальном режиме ожидается около одного измерительного sample-а на блок; при
большем периоде обновления количество sample-ов в блоке пропорционально растет.
Температура и UTS приходят в той же TCP-сессии как отдельные `dev_id=2` и
`dev_id=0`; драйвер кеширует последние значения, а data source публикует их как
скалярные теги после измерительного блока.

## Диалоги

Эталонные скриншоты Recorder сохранены в `images/`:

| Диалог | Файл |
|---|---|
| Главный MIC183/185 | `images/recorder_mic185_main.png` |
| Дополнительные свойства | `images/recorder_mic185_additional.png` |
| Свойства канала | `images/recorder_mic185_channel.png` |
| Коммутация | `images/recorder_mic185_commutation_combo.png` |
| Питание | `images/recorder_mic185_power_combo.png` |
| Схема датчика | `images/recorder_mic185_sensor_combo.png` |
| Канал термокомпенсации | `images/recorder_mic185_thermo_combo.png` |
| Единицы | `images/recorder_mic185_units_combo.png` |

Текущие LFM-диалоги повторяют набор полей и списков из этих скриншотов. На
этом шаге они подключены к дереву устройств и тегам; расширенное сохранение
каждого аппаратного поля в blob настроек нужно делать следующим слоем, когда
будет утверждена схема хранения MIC185-параметров в проектном файле.

## Проверка сборки

Проверено:

```bat
C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi
```

Результат: `RecorderLnx.exe` собран. Post-build `copy_sdb_res.bat` печатает
строку `#!/bin/sh` как Windows-команду, но `lazbuild` завершился с кодом 0.
