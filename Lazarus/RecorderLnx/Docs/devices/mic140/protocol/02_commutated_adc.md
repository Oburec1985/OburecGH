# 2. Коммутируемый АЦП: тайминги и фазы слота

MIC-140 опрашивает входы через мультиплексор **ME048**. Один кадр (период `1/Fs`) делится между
включёнными каналами. При включённом заземлении (`flag_chan_ground`) каждый измерительный канал
чередуется со слотом **GND** (разряд ёмкости коммутатора).

Оригинал: `ModuleMIC140_96::CalcPeriodS`, `CalcPeriodDecay`, `CalcCountAver`, `CheckPeriodDelay`
(`mic140_96mod.cpp`); UI — `CMic140ppext` (`mic140ppext.cpp`); порт — `uRecorderMic140v2Timing.pas`.

> **Подробный разбор** кадрового таймера (640, 50 kHz), поправки ISR, `period_decay` vs
> `period_decay2` и пошаговый расчёт `count_aver` — см.
> [08_timing_and_count_aver.md](08_timing_and_count_aver.md).

---

## 2.1. Базовые константы (MC114, 16 МГц)

| Символ | Значение | Смысл |
|--------|----------|-------|
| `F_clk` | 16 MHz | Такт SPORT / таймера |
| `TIMER_PERIOD` | 640 | Период аппаратного таймера кадра |
| `PERIOD_AD` | 5 µs | Шаг оцифровки ΣΔ-АЦП (`period_aver` в UI) |
| `PERIOD_TIMER_WORK` | 112 тиков кода | Накладные расходы прерываний таймера |
| `flag_chan_ground` | по умолч. вкл. | Чередование GND↔канал |

Преобразование время ↔ SPORT-такты:

```
TactCount = Trunc(TimeSec × 16_000_000)   // младшие 24 бита
TimeSec   = TactCount / 16_000_000
```

Коды длительности фаз (тики «программирования» канала) вычитаются при расчёте
`PeriodDecayToSport` / `PeriodAverageToSport` — полная таблица и микроциклограмма:
[08_timing_and_count_aver.md §8.3.3](08_timing_and_count_aver.md#833-тики-кода-period_chan_code).

---

## 2.2. Период кадра и слот канала

**Период кадра** (время одной «строки» всех каналов в потоке данных):

```
T_frame = 1 / Fs
```

**Число логических слотов в кадре** (`count_chans` для формул):

| Режим | count_chans |
|-------|-------------|
| Заземление вкл., все каналы UI | `(N_AIn + N_TIn) × 2` — каждый AIn + GND |
| Заземление выкл. | `N_AIn + N_TIn` |
| Не все каналы (`flag_allch_sampl=0`) | число включённых в списке |

Для стенда **48 AIn, 10 Гц, ground on, all channels**: `count_chans = 48×2 = 96`
(в BIOS-циклограмме; в сетевом FIFO — только 48 слов AIn, см. §2.7).

**Среднее время на один измерительный канал** (без GND-слота):

```
T_slot ≈ T_frame / (N_parallel_groups)
```

Аппаратно 48 каналов — **3 банка по 16** (3 параллельных ΣΔ). При полном скане
`N_parallel_groups = 16`, т.е. за кадр каждый из 48 входов получает один усреднённый код.

С учётом прерываний таймера (`ModuleMIC140_96::CalcPeriodS`):

```
TimerFreq = (2 × F_clk) / TIMER_PERIOD
periods_eff = periods_raw / (1 + TimerFreq × (PERIOD_TIMER_WORK / (2×F_clk)))
```

где `periods_raw` — суммарное время опроса выбранного числа слотов.

---

## 2.3. Фазы внутри слота измерительного канала

```text
|-- GND (опц.) --|-- decay/settling --|-- averaging (N_adc × 5µs) --|
```

### Фаза A — заземление (Ground)

- Вход АЦП к схемной земле, сброс заряда коммутатора.
- Управляется отдельным **дескриптором GND** (`code 0x0002`, флаг `0x0110`).
- Длительность: `period_decay2` / `LegacyGroundDelaySport`, минимум `CalcMinPeriodDecay()` (~5.1 µs).
- Отключается флагом `flag_chan_ground = 0` (в Mebius: `GroundEnabled := False`).

### Фаза B — успокоение (Decay / Settling)

- После переключения MUX на канал отсчёты **не усредняются**.
- АЦП продолжает тактировать с периодом `period_aver` (5 µs).
- Параметр UI: **«Время переходного процесса»** (`m_period_decay`, мкс в диалоге = `period_decay × 10⁶`).
- Рекомендация оригинала: **≥ 30 µs** (`INIT_PERIOD_DECAY` ≈ 57 µs по умолчанию).
- В дескрипторе канала: `Word3 = LegacyChannelDelaySport - 1`.

Ограничение (`CheckPeriodDelay` / `Mic140v2CheckPeriodDecay`):

```
period_decay := min(запрошенный, CalcPeriodDecay(...))
period_decay := max(period_decay, CalcMinPeriodDecay())
```

### Фаза C — измерение (Averaging)

- `count_aver` отсчётов АЦП с шагом `period_aver` (5 µs).
- Среднее арифметическое → один код `SmallInt` в FIFO.
- UI: **«Число усреднений»** (`m_count_aver`).
- В BIOS: `m_ChanDump[1] = AverageSampleCount`, `m_ChanDump[0] = LegacyAverageDelaySport - 1`.

Расчёт максимума (`CalcCountAver`):

```
// при ground on:
count_aver = floor(
  ((periods_eff - (count_chans/2)×period_decay2) / (count_chans/2)
   - (period_proc + period_decay)) / period_aver
) + 1

// при ground off:
count_aver = floor(
  (periods_eff/count_chans - (period_proc + period_decay)) / period_aver
) + 1
```

`period_proc = PERIOD_2_CHAN_CODE / (2×F_clk)` — фиксированные накладные на переключение.

На **10 Гц** и 48 каналах типично `count_aver ≈ 300…330` (зависит от decay и ground).

---

## 2.4. Циклограмма опроса (ground on)

```text
GND → CH[1] → GND → CH[2] → GND → CH[3] → …
```

Таблица переходов `m_ChanDump` (нечётные → дескриптор GND, чётные → канал).
Подробнее — [04_channel_descriptors.md](04_channel_descriptors.md).

---

## 2.5. Смещение по времени внутри кадра (GetSettingTime)

Для канала `num_chan` задержка до «центра» усреднения относительно начала кадра:

```
st = CalcPeriodS(num_chan+1, ...)   // накопленное время слотов
st = period_timer_osc + st + ((count_aver-1)×paver)/2
```

Используется для синхронизации и отображения; на программирование BIOS влияет косвенно.

---

## 2.6. Связь UI ↔ драйвер

| Поле диалога (`mic140ppext`) | Переменная модуля | BIOS / дескриптор |
|------------------------------|-------------------|-------------------|
| Период переходного процесса | `period_decay` | `LegacyChannelDelaySport` |
| Период заземления (2) | `period_decay2` | GND-дескриптор |
| Число усреднений | `count_aver` | `m_ChanDump[1]` |
| Опрос всех каналов | `flag_allch_sampl` | `count_chans` в формулах |
| Заземление каналов | `flag_chan_ground` | чередование GND |
| Авторасчёт задержки | `mode_auto_calc_period_delay` | вызов `CheckPeriodDelay` |

При смене частоты `CheckPeriodDelay` пересчитывает допустимые `period_decay` и `count_aver`.

---

## 2.7. 48 каналов в сетевом FIFO (rev ≥ 12)

В режиме **48 AIn** внутренние TIn (холодный спай) **не кладутся** в циклический
сетевой буфер: stride payload = **48 слов/строка**. TIn читаются отдельным путём
(`MASK_CHAN_LEFT` в BIOS). Это снижает нагрузку на Ethernet и исключает путаницу
слотов в MDP-потоке.

Параметры стенда приёмки: `Fs=10`, `DataUpdateMs=200`, `range=0`, `commut=0`.

---

## 2.8. Типичные ошибки конфигурации

| Симптом | Вероятная причина |
|---------|------------------|
| ±32767, шум при верном MDP | неверный `count_aver` / decay для частоты |
| CH25+ систематически неверны | ME048 packing rev14 (`MIC140_48v2mod.cpp`) |
| TIn = 0 в 48-word строке | норма для AIn-only FIFO; TIn не в payload |
| `stride misalignment` | `SCAN_SET_BUFF` / `BiosScanSlotCount` ≠ фактический stride |

См. [07_acceptance.md](07_acceptance.md) и [../acquisition_rules.md](../acquisition_rules.md).
