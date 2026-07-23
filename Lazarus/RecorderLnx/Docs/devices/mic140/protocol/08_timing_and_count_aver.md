# 8. Алгоритм таймингов и расчёта `count_aver`

Подробное описание того, как оригинальный Recorder (`MIC140pp` / `ModuleMIC140_96`)
рассчитывает частоту кадра, время успокоения, заземление и **число точек усреднения**
(`count_aver`). Документ дополняет [02_commutated_adc.md](02_commutated_adc.md) и
[03_scan_programming.md](03_scan_programming.md).

**Источники в windev-v3.9:**

| Файл | Функции / данные |
|------|------------------|
| `MIC140_96_rce/mic140_96mod.cpp` | `CalcPeriodS`, `CalcPeriodDecay`, `CalcCountAver`, `PeriodDecayToSport` |
| `mtc/Mc114mod.cpp` | `CheckPeriodDelay`, `CheckPeriodDecay`, `CheckCountAver`, `GetCountChansFor`, `scale_period_16000` |
| `MIC140pp_rce/mic140ppext.cpp` | UI «Дополнительно», `period_decay`, `period_decay2`, режимы авторасчёта |
| `mtc/Ccdevice.cpp` | `ConfigScanMain` (CMD 84) |
| `mtc/Modscn.cpp` | `CreateInternalScan` (CMD 82), `GetDeviceTimerPeriodSec` |

**Порт в RecorderLnx:** `Device/MIC140v2/utils/uRecorderMic140v2Timing.pas`,
`Device/MIC140/uRecorderMic140LegacyTiming.pas`.

---

## 8.1. Два уровня времени

В MIC-140 одновременно работают **два «часовых механизма»**:

| Уровень | Что задаёт | Параметры | Результат |
|---------|------------|-----------|-----------|
| **1. Кадровый таймер MC114** | Как часто начинается новый кадр (Fs) | `TimerScale`, `TimerPeriod`, `ScanDivider` | Период кадра `T_frame = 1/Fs` |
| **2. Циклограмма канала (BIOS/SPORT)** | Что происходит **внутри** одного слота | `period_decay`, `period_decay2`, `count_aver`, `period_aver` | Длительность фаз MUX и число отсчётов АЦП |

```mermaid
flowchart TB
  subgraph L1 ["Уровень 1: кадровый таймер"]
    CONFIG["CONFIG 84: Scale, Period"]
    APPEND["APPEND 82: ScanDivider"]
    CONFIG --> FS["Fs — частота кадра"]
    APPEND --> FS
    FS --> TFR["T_frame = 1/Fs"]
  end

  subgraph L2 ["Уровень 2: слот канала"]
    TFR --> TEFF["T_eff — бюджет под каналы"]
    TEFF --> SLOT["T_slot = T_eff / N_ch"]
    SLOT --> DECAY["period_decay, period_decay2"]
    SLOT --> AVER["count_aver × period_aver"]
  end
```

Параметры уровня 1 программируются командами BIOS; параметры уровня 2 — в DM-дескрипторах
каналов и в `m_ChanDump`.

---

## 8.2. Кадровый таймер: `TimerScale`, `TimerPeriod`, `ScanDivider`

### 8.2.1. Куда уходят в BIOS

```text
ProgramScan:
  RESET 83
  CONFIG 84   → arg0 = Scale−1,  arg1 = Period−1
  APPEND 82   → word2 = ScanDivider
  …
```

Оригинал:

```cpp
// ModuleMIC140_96::WriteConfig
cc->ConfigScanMain(cc->iface->GetTimerScale(), cc->iface->GetTimerPeriod());

// ScanModule::Programming → CreateInternalScan
scan_divider = GetScanDivider();  // → ModuleMIC140_96::GetMainScanDivider()
```

Значения берутся из таблицы `scale_period_16000[]` в `Mc114mod.cpp` по частоте канала.

### 8.2.2. Формула частоты кадра

```cpp
// ModuleMC114::IndexToFreq
freq = 2 * freq_clk / (scale * period * count);
```

При `F_clk = 16 MHz`:

$$
F_s = \frac{32\,000\,000}{Scale \cdot Period \cdot ScanDivider}
$$

Тройка `(Scale, Period, ScanDivider)` подбирается из **дискретной сетки**, произвольную
частоту задать нельзя.

### 8.2.3. Таблица для UI (Period = 640)
У MR-114 циклограмма работает в часах привязанных к 50 кГц, одимн импульс часов 20мкС при частоте Clk 16Mhz=640 импульсов

| Fs        | Scale | Period  | ScanDivider |
| --------- | ----- | ------- | ----------- |
| 1 Гц      | 2     | 640     | 25000       |
| 2 Гц      | 1     | 640     | 25000       |
| 5 Гц      | 1     | 640     | 10000       |
| **10 Гц** | **1** | **640** | **5000**    |
| 20 Гц     | 1     | 640     | 2500        |
| 25 Гц     | 1     | 640     | 2000        |
| 50 Гц     | 1     | 640     | 1000        |
| 100 Гц    | 1     | 640     | 500         |
|           |       |         |             |

**Scale = 2** только для 1 Гц: при Scale=1 и Divider=25000 минимум был бы 2 Гц.

Важно: при дефолтной частоте кварца модуля `GetFreqClk() = 16 MHz` эта таблица
даёт **точные** частоты для строк 10/20/25/50/100 Гц:

| Номинал | Scale | Period | Divider | Фактическая Fs по `IndexToFreq` |
|---------|-------|--------|---------|---------------------------------|
| 10 Гц   | 1     | 640    | 5000    | 10.000000 Гц                    |
| 20 Гц   | 1     | 640    | 2500    | 20.000000 Гц                    |
| 25 Гц   | 1     | 640    | 2000    | 25.000000 Гц                    |
| 50 Гц   | 1     | 640    | 1000    | 50.000000 Гц                    |
| 100 Гц  | 1     | 640    | 500     | 100.000000 Гц                   |

В диалоге «Дополнительно» Recorder берёт частоту не из подписи комбобокса,
а из канала:

```cpp
freq = module->GetFreqSFor(MIC140_AIN_CHTYPE);
module->CheckPeriodDelay(freq, &period_decay, &count_aver, ...);
```

`GetFreqSFor()` возвращает фактическое `double`-значение частоты первого
используемого AIn-канала (`CChannel::m_Fs`). UI выбора частоты в `TagPP.cpp`
хранит список как `double`, но показывает его округлённо (`"%.1f"`). При
подтверждении выбора в канал уходит именно значение из списка, а не строка с
экрана.

Полная цепочка частоты:

```text
TagPP frequency combo
  -> CMeasurementTag::SetFreq(double)
  -> CChannelModule::SetFreq(freq)
  -> m_Fs = IndexToFreq(FreqToIndex(freq))
  -> ModuleMC114::IndexToFreq(index)
  -> 2 * GetFreqClk() / (scale * period * count)

MIC140 additional dialog
  -> ModuleMC114::GetFreqSFor(MIC140_AIN_CHTYPE)
  -> first AIn channel GetFreq()
  -> CheckPeriodDelay(freq, ...)
```

То есть первоисточник для `count_aver` — **фактическая частота канала**.
Значение `count_aver` не определяет частоту; наоборот, при открытии диалога уже
существующая `freq` подаётся в `CheckPeriodDelay`, и из неё вычисляется число
усреднений. В частности, 298 для MIC-140-48v3 является результатом Fs=10 Гц,
55 каналов и текущих флагов, а не источником одного из этих параметров.

Значение **9.875 Гц** не является константой диалога и не вычисляется из
`count_aver`. Для диалога это уже готовая частота канала. Она может появиться
из сохранённого состояния модуля/проекта как результат legacy-сетки 10 Гц при
`GetFreqClk() = 15.8 MHz`:

```text
2 * 15_800_000 / (1 * 640 * 5000) = 9.875 Hz
```

В исходниках `ModuleMIC140_96` дефолтно ставит `SetFreqClk(16_000_000)`, но
базовый `Module::Load()` читает `freq_clk` из сохранённого фрейма проекта. Поэтому
оффлайн-модуль может давать те же 9.875 Гц без физического прибора. В
проверенном коде диалог «Дополнительно» сам не измеряет частоту кварца и не
читает её из EEPROM MIC-140; он использует уже загруженное состояние модуля и
каналов.

Проверенный путь контроллера MIC-140/MC031 не меняет этот вывод:

- `CCMC031EthernetInterface::Open()` вызывает `ReadCfg()`, а `ReadCfg()` читает
  `TBiosInfoMC031` через `CMD_REPLY`. В этой структуре есть тип/ревизия,
  серийные номера, EEPROM ID и версия BIOS, но нет поля частоты кварца.
- `CCMC031EthernetInterface::GetFirmware()` тем же `CMD_REPLY` извлекает тип,
  ревизию и версию функции BIOS; частоту он тоже не возвращает.
- `CCMC031EthernetInterface::MeasureFreqCCFromFreqModule()` и аналогичная
  `CCMC021USBWDInterface::MeasureFreqCCFromFreqModule()` для USB являются
  заглушками: возвращают OK и не записывают новое значение в `freq`.
- Найденный автоматический замер `ScanClock::Decommutation()` корректирует
  частоту контроллера через `cc->SetFreqClk(koef)`. MIC-140 объявлен как
  `SELF_CLK`, поэтому `Module::GetFreqClk()` берёт собственный `freq_clk`
  модуля, а не частоту контроллера `cc`.

Если тот же относительный сдвиг `0.9875 × nominal` задан внешним списком/проектом,
то «некрасивые» значения будут такими:

| Номинал | Фактическая Fs при `0.9875 × nominal` |
|---------|---------------------------------------|
| 10 Гц   | 9.875000 Гц                           |
| 20 Гц   | 19.750000 Гц                          |
| 25 Гц   | 24.687500 Гц                          |
| 50 Гц   | 49.375000 Гц                          |
| 100 Гц  | 98.750000 Гц                          |

Это не отдельное правило диалога; это следствие того, что `CheckPeriodDelay`
считает по **фактической** Fs канала.

### 8.2.4. Смысл полей

| Поле в Codex / UI | BIOS | Смысл |
|-------------------|------|-------|
| `TimerScaleMinus1` | CONFIG arg0 | Предделитель таймера: 0→Scale=1, 1→Scale=2 |
| `TimerPeriodMinus1` | CONFIG arg1 | Длина одного **базового тика** супервизора в единицах `1/(2·F_clk)`; по умолчанию **639→640** |
| `ScanDivider` | APPEND word2 | Сколько базовых тиков между **стартами кадров** |

**CONFIG** задаёт глобальный таймер контроллера MC114; **ScanDivider** — делитель
конкретного скана MIC-140 в его контексте (DM).

---

## 8.3. Что такое 640 и откуда 50 000 Гц

### 8.3.1. `TIMER_PERIOD = 640`

Константа в `mic140_96mod.cpp`:

```cpp
const WORD TIMER_PERIOD = 640;  // делитель системного таймера (20 мкс)
```

То же значение передаётся в `ConfigScanMain` как `Period−1 = 639`.

**640 — не частота и не Fs.** Это число тактов **внутренней шкалы ADSP**, которые
супервизор скана считает между своими «тиками».

В MIC-140 микрооперации (SPORT, RegLatch, прерывания) измеряются периодами:

$$
T_{code}(N) = \frac{N}{2 \cdot F_{clk}}, \quad F_{clk} = 16\,\text{MHz}
$$

Один базовый тик системного таймера:

$$
T_{tick} = \frac{640}{2 \cdot F_{clk}} = \frac{640}{32\,\text{MHz}} = 20\,\mu\text{s}
$$

Комментарий «20 мкс» в исходнике — это **640 / (2·F_clk)**, а не 640/F_clk.

### 8.3.2. `TimerFreq = 50 000 Гц`

В `CalcCountAver` / `CalcPeriodS`:

```cpp
double TimerFreq = (2 * GetFreqClk()) / TIMER_PERIOD;
```

$$
f_{timer} = \frac{2 \cdot 16\,000\,000}{640} = 50\,000\,\text{Hz}
$$

| Величина | Значение | Что это |
|----------|----------|---------|
| **50 000 Гц** | 1 / 20 µs | Частота **базовых тиков супервизора** MC114 |
| **10 Гц** | 1 / 100 ms | **Частота кадра** Fs (опрос всех каналов) |
| **200 kHz** | 1 / 5 µs | Частота отсчётов ΣΔ при усреднении (`period_aver`) |

**50 kHz — не Fs.** Это «метроном» прошивки: каждые 20 µs срабатывает служебный
таймер, на котором крутится FSM скана.

Связь с кадром: при 10 Гц `ScanDivider = 5000`, то есть **5000 тиков × 20 µs = 100 ms**
на один кадр.

---

---

## 8.4. `PERIOD_TIMER_WORK` и поправка на прерывания

### 8.4.1. Константа

```cpp
const WORD PERIOD_TIMER_WORK = 80 + 32;  // обработка таймера; +32 для DIn, UTS
```

**112** — оценка длительности **одного обслуживания прерывания** системного таймера.
Единица та же, что у констант циклограммы слота (§8.3.3), но это **не шаг MUX/АЦП**,
а время обработчика прерывания кадрового супервизора.

В секундах:

$$
T_{isr} = \frac{112}{2 \cdot F_{clk}} = 3.5\,\mu\text{s}
$$

В расчёте необходимо использовать полное штатное значение **112**, то есть:

```text
K = 1 + 112 / 640 = 1.175
```

Ранее полученное совпадение через 103 тика было ложной компенсацией неверного
числа каналов. Для MIC-140-48v3 значение 298 получается при 55 фактически
используемых каналах, а не изменением `PERIOD_TIMER_WORK`. Частота канала при
этом остаётся `10.000000 Гц`.

| Состав | Тиков | Назначение (по комментарию) |
|--------|-------|----------------------------|
| 80 | базовая | Обработчик таймера скана |
| +32 | доп. | Задачи DIn, UTS |

### 8.4.2. Формула поправки

В `CalcPeriodS` (сколько **реально** занимают все каналы, включая ISR):
```cpp
periods *= (1 + TimerFreq * (PERIOD_TIMER_WORK / (2 * GetFreqClk())));
```
В `CalcCountAver` / `CalcPeriodDecay` (сколько **полезного** времени в кадре):
```cpp
periods /= (1 + TimerFreq * (PERIOD_TIMER_WORK / (2 * GetFreqClk())));
```
Обозначим:

$$
k = f_{timer} \cdot T_{isr} = 50\,000 \cdot 3.5\,\mu\text{s} = 0.175
$$
**Физический смысл:** пока идёт кадр, супервизор регулярно отвлекает процессор на ~3.5 µs.
В модели это «налог» **17.5%** на полезное время каналов.
$$
T_{eff} = \frac{T_{frame}}{1 + k}
$$
При `T_frame = 100 ms` (10 Гц):
$$
T_{eff} = \frac{100\,\text{ms}}{1.175} = 85.106\,\text{ms}
$$
```text
Кадр 100 ms (номинал Fs = 10 Гц)
│
├── ~14.9 ms  — «налог» ISR супервизора (~17.5%)
│
└── ~85.1 ms  — T_eff, бюджет под опрос каналов
      │
      ├── слот CH1: T_proc + T_decay + (count_aver−1)×T_aver
      ├── слот CH2: …
      └── …
```
Почему не «5000 × 3.5 µs» явно: в legacy-коде заложена **линейная аппроксимация**
с коэффициентом `k = 0.175`, а не пошаговый подсчёт каждого ISR.

---
## 8.5. `period_decay` и `period_decay2`

### 8.5.1. Различие

| UI (диалог «Дополнительно»)         | Переменная        | Фаза                                       | Куда в BIOS                         |
| ----------------------------------- | ----------------- | ------------------------------------------ | ----------------------------------- |
| **Время успокоения до усред., мкс** | `period_decay`    | Успокоение MUX **на измерительном канале** | `desc[i].delay` для AIn/TIn         |
| **Время успокоения земли, мкс**     | `m_period_decay2` | Слот **GND** (разряд ёмкости)              | `desc[0].delay` для GND-дескриптора |

Внутри слота при `flag_chan_ground = 1`:

```text
GND (decay2) → переключение MUX → decay → усреднение (count_aver × 5 µs)
```

### 8.5.2. Дефолты в конструкторе `ModuleMIC140_96`

```cpp
m_period_decay2 = CalcMinPeriodDecay();   // ≈ 19.688 µs — не 57!
period_decay    = INIT_PERIOD_DECAY;      // 57e-6 s = 57 µs
```

**57 µs** и **19.688 µs** — **разные** параметры. В UI оба видны, но при **выключенном
заземлении** `period_decay2` **не участвует** в `CalcCountAver`.

### 8.5.3. Запись в дескрипторы

```cpp
desc_chan_bios[i].delay = PeriodDecayToSport(period_decay) - 1;      // канал
desc_chan_bios[0].delay = PeriodDecayToSport(m_period_decay2) - 1;     // GND
```

Оба переводятся функцией `PeriodDecayToSport()` (вычитаются фиксированные накладные
циклограммы), но пишутся в **разные** дескрипторы.

`m_ChanDump[0]` — это **не** decay, а задержка **усреднения** (`PeriodAverageToSport(period_aver)−1`).

---

## 8.6. Число каналов для формул (`count_chans`)

```cpp
// ModuleMC114::GetCountChansFor
if (flag_allch_sampl)
    count_chans = GetMaxChanCount();
else
    count_chans = GetCountUsedChannels();
if (flag_ground)
    count_chans = 2 * count_chans;
```

| Исполнение и режим | Число каналов до учёта земли |
|---------------------|--------------------------------|
| Базовый MIC-140-48, полный опрос | 48 AIn + 3 TIn = **51** |
| MIC-140-48v2, аппаратный максимум предка | 48 AIn + 12 TIn = **60** |
| MIC-140-48v3, максимальное быстродействие | 48 AIn + 7 созданных TIn = **55** |
| Выборочный опрос | `GetCountUsedChannels()` / фактический `channels.Size()` |

При включённой земле итоговое число BIOS-слотов удваивается. Например,
для базового MIC-140-48 это 102, а для используемых 55 каналов MIC-140-48v3 —
110 слотов.

UI: «Режим максимального быстродействия» **выкл.** → `flag_allch_sampl = 1`.

### 8.6.1. Инверсия флага максимального быстродействия

Название UI и внутренний флаг имеют обратный смысл:

```cpp
// mic140ppext.cpp
m_flag_nch_sampl = flag_allch_sampl ? 0 : 1;
flag_allch_sampl = m_flag_nch_sampl ? 0 : 1;
```

- галка **снята**: `flag_allch_sampl=1`, формула использует
  `GetMaxChanCount()`;
- галка **установлена**: `flag_allch_sampl=0`, формула использует
  `GetCountUsedChannels()`.

Для MIC-140-48v3 нельзя подменять это число константой базового MIC-140-48.
Класс `CModuleMIC140_48v3` наследуется от `ModuleMIC140_48v2`, но создаёт только
семь доступных каналов ТХС (`MAX_COUNT_CHAN_RTIN_48V3 + 2 = 5 + 2`). Поэтому
в режиме максимального быстродействия расчёт выполняется по **48 + 7 = 55**,
а не по 51 и не по аппаратному максимуму предка 60.

> **Правило проверки:** перед сравнением `count_aver` с Recorder фиксировать
> точное исполнение прибора, состояние обеих галок и фактический результат
> `GetCountChansFor()`. Совпадение только частоты и времён недостаточно.

---

## 8.7. Режимы авторасчёта (`CheckPeriodDelay`)

Диалог «Дополнительно» → `CMic140ppext::OnKillfocus…` → `ModuleMC114::CheckPeriodDelay`.

| Режим UI | Константа | Поведение |
|----------|-----------|-----------|
| Ручной decay и aver | `OFF_AUTO_CALC_PERIOD_DELAY` | Оба поля редактируемы; decay и aver зажимаются в допустимые пределы |
| Авто decay | `AUTO_CALC_PERIOD_DECAY` | Decay = минимум; aver подбирается |
| **Авто aver** | **`AUTO_CALC_COUNT_AVER`** | **Decay фиксируется (57 µs); aver максимизируется** |

Типичный режим по умолчанию для MIC-140:

```cpp
const WORD INIT_MODE_AUTO_CALC_PERIOD_DELAY = ModuleMC114::AUTO_CALC_COUNT_AVER;
```

### 8.7.1. Алгоритм `AUTO_CALC_COUNT_AVER`

```cpp
count_aver   = 1;
period_decay = CheckPeriodDecay(1/freq, period_decay, period_aver, count_aver, ...);
count_aver   = MAX_COUNT_AVER;
count_aver   = CheckCountAver(1/freq, period_decay, period_aver, count_aver, ...);
```

1. Временно `count_aver = 1`, проверить что `period_decay` (57 µs) **влезает** в кадр.
2. Запросить максимум (`32767`), **обрезать** до реального `CalcCountAver`.

---

## 8.8. Формула `count_aver`

### 8.8.1. Земля выключена (`flag_chan_ground = 0`)

```cpp
// ModuleMIC140_96::CalcCountAver
periods /= (1 + TimerFreq * (PERIOD_TIMER_WORK / (2 * GetFreqClk())));
period_decay = SportToPeriodDecay(PeriodDecayToSport(period_decay));
period_aver  = SportToPeriodAverage(PeriodAverageToSport(period_aver));
period_proc  = GetPeriod2ChanCode() / (2.0 * GetFreqClk());  // PERIOD_2_CHAN_CODE = 27, см. §8.3.3

count_aver = (periods / count_chans - (period_proc + period_decay)) / period_aver + 1;
```

В математической записи:

$$
count\_aver = \left\lfloor \frac{T_{eff}/N_{ch} - (T_{proc} + T_{decay})}{T_{aver}} \right\rfloor + 1
$$

где:

- $T_{eff} = T_{frame} / (1 + k)$
- $T_{proc} = \text{PERIOD\_2\_CHAN\_CODE} / (2 \cdot F_{clk}) \approx 0.844\,\mu\text{s}$ — накладные «старт АЦП → RegLatch» в **каждом** слоте (§8.3.3)
- $T_{decay}$ — UI «57 µs» **после** вычитания PERIOD_1/3/DELTA_SPORT и SPORT-квантования
- $T_{aver} = 5\,\mu\text{s}$ — после квантования (`PeriodAverageToSport`)

**«+1»** в коде: первый отсчёт учитывается явно; в `CalcPeriodS` используется
`(count_aver − 1) × period_aver`.

### 8.8.2. Земля включена (`flag_chan_ground = 1`)

```cpp
count_aver = ((periods - (count_chans/2) * period_decay2) / (count_chans/2)
              - (period_proc + period_decay)) / period_aver + 1;
```

Здесь `count_chans` уже **удвоен** (`GetCountChansFor`), `period_decay2` берётся из
`GetPeriodDecay2()` (UI «время успокoения земли»).

---

## 8.9. Пример расчёта базового MIC-140-48

**Условия** (как в диалоге Recorder):

| Параметр                       | Значение                                                         |
| ------------------------------ | ---------------------------------------------------------------- |
| Fs                             | 10 Гц                                                            |
| MIC-140-48, опрос всех каналов | N_ch = 51                                                        |
| Заземление                     | **выкл.**                                                        |
| `period_decay`                 | 57.000 µs                                                        |
| `period_decay2`                | 19.688 µs (в расчёте **не используется**)                        |
| Авторасчёт                     | AUTO_CALC_COUNT_AVER                                             |
| `period_aver`                  | 5 µs (200kHz частота АЦП)                                        |
| Teff                           | Время на цикл измерения с учетом вычитки на накладные расходы () |
|                                |                                                                  |

### Шаг 1. Бюджет кадра

$$
T_{frame} = 100\,\text{ms},\quad k = 0.175,\quad T_{eff} = 85.106\,\text{ms}
$$

### Шаг 2. Слот канала

$$
T_{slot} = 85.106\,\text{ms} / 51 = 1668.75\,\mu\text{s}
$$

### Шаг 3. Накладные слота

$$
T_{proc} = 0.844\,\mu\text{s},\quad T_{decay} = 57.0\,\mu\text{s},\quad T_{aver} = 5.0\,\mu\text{s}
$$
$$
T_{proc}  время старта АЦП, Tdec - время ожидания, Taver - период АЦП
$$
Если нет заземления
### Шаг 4. Остаток под усреднение

$$
T_{avail} = 1668.75 - 0.844 - 57.0 = 1610.9\,\mu\text{s}
$$

### Шаг 5. Результат

$$
count\_aver = \lfloor 1610.9 / 5.0 \rfloor + 1 = 322 + 1 = \mathbf{323}
$$

При **строго 10 Гц** и **51 слоте** оригинал даёт **323**, не 327.

### 8.9.1. Почему для MIC-140-48v3 на 10 Гц получается 298

Для исполнения **MIC-140-48v3** при включённом режиме максимального
быстродействия оригинал сбрасывает `flag_allch_sampl` и вызывает
`GetCountUsedChannels()`. В циклограмме участвуют 48 AIn и семь доступных
каналов ТХС, созданных `CModuleMIC140_48v3`, то есть **55 каналов**. Это не
51 канал базового `ModuleMIC140_48` и не аппаратный максимум 60 каналов его
предка `ModuleMIC140_48v2`.

При снятой галке заземления, `Fs=10 Гц`, `period_decay=57 мкс` и штатной
поправке обработчика таймера `112/640`:

```text
Teff  = 0,1 / (1 + 112/640) = 0,085106383 с
Tchan = Teff / 55           = 1547,3888 мкс
count = floor((Tchan - 0,844 - 57) / 5) + 1 = 298
```

`period_decay2=19,688 мкс` в этом расчёте не участвует, потому что земля
выключена. Значение остаётся видимым в неактивном поле диалога.

Важно различать отображаемое значение и участие параметра в формуле:

- поле `period_decay2` продолжает показывать 19,688 мкс при снятой галке;
- `CalcCountAver()` не вычитает это время, пока `flag_chan_ground=0`;
- при установке галки `count_chans` сначала удваивается, после чего формула
  отдельно вычитает `N × period_decay2` для земляных слотов;
- число 298 нельзя воспроизводить искусственной заменой `112` на `103` такта:
  штатные накладные расходы остаются `PERIOD_TIMER_WORK=80+32=112`, а нужный
  результат возникает из корректных **55 каналов**.

Для точного совпадения с UI всегда проверяйте **реальную Fs первого AIn-канала**
в проекте (`GetFreqSFor`), а не только видимую подпись частоты.

---

## 8.10. Сводная схема алгоритма

```mermaid
flowchart TB
  subgraph IN ["Вход"]
    FS["Fs из канала"]
    UI["period_decay, period_decay2, flags"]
  end

  subgraph L1 ["Уровень 1"]
    FS --> TFR["T_frame = 1/Fs"]
    TFR --> CORR["T_eff = T_frame / (1+k)"]
    K["k = f_timer × T_isr<br/>f_timer = 2·Fclk/640<br/>T_isr = 112/(2·Fclk)"]
    K --> CORR
  end

  subgraph L2 ["Уровень 2"]
    CORR --> SLOT["T_slot = T_eff / N_ch"]
    UI --> DEC["T_decay, T_decay2, T_ground flag"]
    SLOT --> FORM["count_aver = floor((T_slot − T_proc − T_decay)/T_aver) + 1"]
    DEC --> FORM
  end

  subgraph OUT ["Выход"]
    FORM --> BIOS["m_ChanDump[1], desc[].delay"]
  end
```

---

## 8.11. Словарь символов

| Символ / константа     | Значение         | Где в коде                                                                         |
| ---------------------- | ---------------- | ---------------------------------------------------------------------------------- |
| `F_clk`                | 16 MHz           | `FREQ_CLK`, `GetFreqClk()`                                                         |
| `TIMER_PERIOD`         | 640              | `mic140_96mod.cpp`, CONFIG arg1                                                    |
| `T_tick`               | 20 µs            | 640 / (2·F_clk)                                                                    |
| `f_timer`              | 50 kHz           | `(2·F_clk) / TIMER_PERIOD`                                                         |
| `PERIOD_TIMER_WORK`    | 112              | накладные ISR                                                                      |
| `T_isr`                | 3.5 µs           | 112 / (2·F_clk)                                                                    |
| `k`                    | 0.175            | f_timer × T_isr                                                                    |
| `ScanDivider`          | см. табл. §8.2.3 | APPEND word2, `GetTimerCount()`                                                    |
| `PERIOD_1_CHAN_CODE`   | 30 тиков         | прерывание → старт АЦП; вычитается в `PeriodDecayToSport` / `PeriodAverageToSport` |
| `PERIOD_2_CHAN_CODE`   | 27 тиков         | старт АЦП → RegLatch; **`T_proc`** в `CalcCountAver`                               |
| `PERIOD_3_CHAN_CODE`   | 59 тиков         | RegLatch → SPORT; вычитается только для **decay**                                  |
| `PERIOD_21_CHAN_CODE`  | 21 тиков         | старт АЦП → SPORT; вычитается только для **averaging**                             |
| `PERIOD_4_CHAN_CODE`   | 120 тиков        | минимум GND-слота (`CalcMinPeriodDecay`)                                           |
| `DELTA_SPORT`          | 11 тиков         | поправка SPORT                                                                     |
| `PERIOD_AD_MKS`        | 5 µs             | T_aver в UI                                                                        |
| `INIT_PERIOD_DECAY`    | 57 µs            | дефолт period_decay                                                                |
| `CalcMinPeriodDecay()` | ≈ 19.688 µs      | дефолт period_decay2                                                               |
| `count_aver`           | 1…32767          | `m_ChanDump[1]`                                                                    |

---

## 8.12. Связанные документы

- [02_commutated_adc.md](02_commutated_adc.md) — фазы слота, краткие формулы
- [03_scan_programming.md](03_scan_programming.md) — CONFIG/APPEND, таблица ScanDivider
- [06_ui_parameters.md](06_ui_parameters.md) — поля диалога «Дополнительно»
- [../mic140_configuration_details.md](../mic140_configuration_details.md) — WRITEDM, `m_ChanDump`
