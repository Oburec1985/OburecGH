# MIC140v2

Изолированная ветка опроса MIC-140. Legacy — `Device/MIC140/`.

## Ядро (`MIC140v2/`)

| Unit | Назначение |
|------|------------|
| `uRecorderMic140v2Device.pas` | `IMic140Device` |
| `uRecorderMic140v2Protocol.pas` | TCP + MDP |
| `uRecorderMic140v2Scan.pas` | Программирование BIOS-скана |
| `uRecorderMic140v2Stream.pas` | Чтение кадров, num_buff |
| `uRecorderMic140v2RawRing.pas` | Кольцо 8 слотов |
| `uRecorderMic140v2Factory.pas` | `CreateMic140Device` → v2 |

## Utils (`MIC140v2/utils/`)

| Unit | Назначение |
|------|------------|
| `uRecorderMic140v2WireTypes.pas` | Wire-типы кадра |
| `uRecorderMic140v2Consts.pas` | BIOS/DM константы |
| `uRecorderMic140v2Timing.pas` | Таймер MC114 |
| `uRecorderMic140v2ChanDesc.pas` | ME048-коды |
| `uRecorderMic140v2Diag.pas` | Лог, corrupt |
| `uRecorderMic140v2Helper.pas` | TCP-probe, StopScan |
| `uRecorderMic140v2Types.pas` | Параметры создания |

Контракт: `Device/uRecorderMic140DeviceApi.pas`.

Приёмка: `Tools/mic140_preview_eval.ps1` → `Docs/devices/mic140/acceptance_tests.md`.
