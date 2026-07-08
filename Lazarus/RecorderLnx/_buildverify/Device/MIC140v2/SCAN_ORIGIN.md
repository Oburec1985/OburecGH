# MIC-140 v2: сверка программирования скана с Recorder

Эталон: `D:\works\windev-v3.9`

| Файл оригинала | Что сверяли |
|----------------|-------------|
| `MIC140_96_rce/MIC140_48mod.cpp` | AInNum, ME048, ground/TIn descriptors |
| `MIC140_96_rce/mic140_96scn.cpp` | ChannelsToBios, ADDCHANNELMODULE |
| `mtc/Modscn.cpp` | APPENDSCAN, CreateBiosCCScanBuf, SCAN_SET_* |
| `mtc/Mc114mod.cpp` | scale_period_16000 (freq / scale / period / divider) |
| `mtc/Ccdevice.h` | команды BIOS 82–87, 132–133, 152, TYPE_MIC140=12 |
| `mtc/cc81ifc.h` | DM heap 0x800..0x2BFF, buffer end 0x7FF |
| `mtcEthernet81/Mc031ethernetifc.cpp` | DM buffer begin **0x0522** (Ethernet MC031) |

Метки в `.pas`: `[ORIG]` — из Recorder, `[LNX]` — добавлено в RecorderLnx.

---

## Совпадает с оригиналом

| Константа / шаг | Оригинал |
|-----------------|----------|
| `CAInNum48` | `AInNum[]` в MIC140_48mod.cpp — **байт-в-байт** |
| BIOS-команды 82,83,84,87,132,133,152 | `Ccdevice.h` |
| `TYPE_MIC140=12`, `scan_id=0` | Modscn / ScanMIC140 |
| Timer period **640**, scale **2@1Hz / 1@остальное** | `scale_period_16000` |
| Divider 25000/10000/5000/…/500 | `GetTimerCount()` для 1–100 Гц |
| FIFO descriptor 10 words, `size=2*sizeready` | `CreateBiosCCScanBuf` |
| `TDescChanBios` 5 words, chanDump header 3 words | MIC140_48mod / mic140_96mod |
| Ground slot: `MASK_CHAN_GR` ($4000), level0 ME048 | MIC140_48mod ground block |
| `CNormalDesc=$0100`, `CGroundDesc=$0110` | типичный reg_MC114 AIn / ground |
| CONFIG/APPEND/SETSTATE/FIFO/ADDCHANNEL/SET_CHANS порядок | Modscn + mic140_96scn |

---

## Отличия RecorderLnx (требуют решения)

### 1. Stride FIFO и TIn — **главный кандидат на «скачущие коды»**

| | Оригинал (MIC140_48) | RecorderLnx v2 |
|--|----------------------|----------------|
| Дескрипторов каналов | 1 ground + **48 AIn + 3 TIn** = 52 | 1 ground + **48 AIn** = 49 |
| `chan_bios` указателей | `2×(48+3)` = **102** (с ground) | `2×48` = **96** |
| Payload FIFO stride | AIn + TIn в каждом sample | **только AIn** (`ScanStride=fChCnt`) |
| TIn в `ProgramScan` | `code_chanTIn_48`, ptr `0x8000\|(48+idx)` | ветка TIn **не выполняется** (`intCnt=fChCnt`) |

CJC/TIn в Lazarus задумывались через `TMic140AuxTemperatureBlock` после декоммутации, но BIOS в оригинале **всё равно крутит TIn в scan**.

### 2. FIFO `sizeready`

| | Оригинал | LNX |
|--|----------|-----|
| Размер | `ScanMIC140::GetChanMaxFifoSizeCC()` | `fUpdateTimeMs` UI (200 ms), cap **1024** words/channel batch |

### 3. Только LNX (не BIOS)

- StopScan + `ClearBufferedPackets` перед программированием
- TCP timeouts, num_buff restart, corrupt heuristic (`uRecorderMic140v2Diag`)
- `ReadSerial`, `FirstSampleIndex` в wire-типах
- `SoftRestartMaxAttempts=0`

---

## Следующий шаг сверки

1. Включить в scan **48+3 TIn** как в `PrepareModuleDescForScan` (MIC140_48mod.cpp:311–316).
2. Сравнить один DM-dump дескрипторов: Recorder vs Lazarus log после `ProgramScan`.
3. Проверить `code_ME048[0..1]` для каналов 1, 12, 24, 48 — таблица `code_chanAIn_48`.
