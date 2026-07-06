# 5. Поток данных и разбор кадра

## 5.1. Структура Payload (PORT=0)

```
[ THeaderMessage — 10 слов ]
[ строка 0: SampleCount × PayloadStride слов SmallInt ]
[ строка 1: ... ]
...
```

| Поле заголовка | Назначение |
|----------------|------------|
| BIOS-NUM_BUFF | Порядковый номер; пропуски → `readGaps` |
| BIOS-STATE | Флаги ошибок АЦП |
| время BIOS | Метка времени блока |

## 5.2. Размер блока

```
MessageWords = 10 + SampleCount × PayloadStride
```

10 Гц, `DataUpdateMs=200` → 2 строки:

| fifo-stride | dataWords | MessageWords (без MDP-обёртки) |
|-------------|-----------|--------------------------------|
| 48 | 96 | **106** |
| 51 | 102 | **112** |

## 5.3. Порядок каналов в строке

Индекс `0..47` → UI `MIC140_01..MIC140_48` после decommutation.
Значения — **signed 16-bit** (код АЦП до тарировки).

## 5.4. Правила приёма (кратко)

1. Побайтовый MDP resync — [01_mdp_transport.md](01_mdp_transport.md).
2. Верный заголовок + мусор в ADC → ошибка **программирования**, не Ethernet.
3. Кольцо слотов raw-блоков — читатель и разбор не делят один буфер.
4. Row-level validation: отбрасывать только явно битые строки (saturation heuristic).

Подробно: [../acquisition_rules.md](../acquisition_rules.md).

## 5.5. TIn

| fifo-stride | Источник T1..T3 |
|-------------|-----------------|
| 51 | слова 48..50 каждой строки payload |
| 48 | `CMD_READMEMDM=114`, адрес `valAddr+48..50` (ptr с `0x8000` в BIOS) |

Эталон стенда: T1=8306, T2=8496, T3=18624 (±50).

## 5.6. 10 Hz live-test profile (2026-07-06)

For acceptance at `Fs=10 Hz` and `DataUpdateMs=200`, the stable profile is:

- payload stride `48`;
- FIFO ready `96` data words;
- MDP message length `106` words;
- host rate about `5` published blocks/sec;
- TIn is read separately through `CMD_READMEMDM=114`, not from payload words.

The captured Recorder-wire profile (`stride=51`, `msgWords=163`, three
51-word rows with TIn in slots 48..50) is kept as a comparison/diagnostic mode.
On the live stand it can restart or time out after reprogramming, so it is not
the default acceptance stream until it passes the same no-gap/no-restart rules.
