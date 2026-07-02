# 6. Параметры UI и конфигурация

## 6.1. Диалог расширенных свойств (`MIC140pp` → `mic140ppext.cpp`)

| Элемент UI | IDC | Переменная | Единицы в UI |
|------------|-----|------------|--------------|
| Число усреднений | EDIT_COUNT_AVER | `count_aver` | целое |
| Время переходного процесса | EDIT_PERIOD_DECAY | `period_decay` | мкс (`× MULT_PERIOD_DECAY`) |
| Время заземления 2 | EDIT_PERIOD_DECAY2 | `period_decay2` | мкс |
| Опрос всех каналов | — | `flag_allch_sampl` | bool |
| Заземление | — | `flag_chan_ground` | bool |
| Авторасчёт | — | `mode_auto_calc_period_delay` | bool |

При потере фокуса полей decay/aver вызывается `CheckPeriodDelay(freq, …)`.

Подробное описание формул и пример расчёта (10 Гц → 323 точки при 51 канале) —
[08_timing_and_count_aver.md](08_timing_and_count_aver.md).

## 6.2. Канал (`chanmic140pp.cpp`)

| Свойство | Метод | BIOS |
|----------|-------|------|
| Диапазон | `SetRangeIndex` → `amplif[]` | Word2 дескриптора / reg |
| Коммутатор | `SetCommutChan` | ME048 |
| Коммутатор платы | `SetCommutChanBoard` | reg MC114 |

Индексы диапазона: 0=80 mV … (см. `GetRangeStr` в модуле).

## 6.3. RecorderLnx JSON / properties

| Ключ | `TRecorderDeviceProperty` |
|------|---------------------------|
| Host, Port | `rdpHost`, `rdpPort` |
| Fs | `rdpPollFrequencyHz` |
| Update | `rdpUpdateTimeMs` |
| Range[i] | `rdpMic140RangeIndex` |
| Commut[i] | `rdpMic140CommutIndex` |
| BoardCommut[i] | `rdpMic140BoardCommutIndex` |

## 6.4. Автономный пример

Сводный record `TMic140Config` — `Tests/Mic140ProtocolDebug/uMic140Api.pas`.
