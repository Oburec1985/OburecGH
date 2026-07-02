# 4. Дескрипторы каналов и коммутатор ME048

## 4.1. Физический порядок (CAInNum48)

Пользовательский канал UI **не равен** номеру входа ME048:

```pascal
CAInNum48: array[0..47] of Word = (
  24..47,   // UI CH01..24
  23..0     // UI CH25..48
);
```

## 4.2. Два индекса коммутации (MIC140pp)

| UI / свойство | Оригинал | Регистр дескриптора |
|---------------|----------|---------------------|
| «Вход» (калибр.) | `GetCommutIndex` / `calibr` | `code_ME048[]` |
| Плата MUX | `GetCommutIndexBoard` / `calibr2` | `Mic140v2AInRegDesc` (Word2) |

**Важно:** один `CommutIndex` на ME048 и MUX — ошибка конфигурации; в v2 разделены
`fCommutIndexes` и `fBoardCommutIndexes`.

## 4.3. Код ME048 (16 бит, rev ≤ 11)

`Mic140LegacyMe048Code48(physical)` — биты группы XA2..XA13, младшие биты канала в 14–15.

Для **rev ≥ 12** (48 каналов): упаковка через `code_chanAIn[]` → `code_ME048[0..1]`
по таблице `num_me048` (`MIC140_48v2mod.cpp`). Hybrid-упаковка только для `i≥24` —
временный обход; эталон — полная табличная v2.

## 4.4. Дескриптор канала (5 слов)

| Word | Измерительный канал | GND |
|------|---------------------|-----|
| 0 | 0 | `0x0002` |
| 1 | ME048 code | `0x0002` |
| 2 | `0x0100` (normal) | `0x0110` (ground) |
| 3 | `LegacyChannelDelaySport−1` | `LegacyGroundDelaySport−1` |
| 4 | адрес ячейки DM | `0x4000` (mask) |

## 4.5. m_ChanDump

| Индекс | Содержимое |
|--------|------------|
| 0 | `LegacyAverageDelaySport − 1` |
| 1 | `AverageSampleCount` (`count_aver`) |
| 2 | число измерительных каналов N |
| 3.. | пары указателей: GND desc, CH desc, … |

`BiosScanSlotCount` для BIOS = `PayloadStride + tin_slots` (TIn в BIOS, не в FIFO).
