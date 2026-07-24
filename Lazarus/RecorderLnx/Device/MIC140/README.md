# MIC-140

Единственная папка драйвера MIC-140 в RecorderLnx.

## Lifecycle

`Connect → InitializeDevice → ConfigureDevice → Start (Play) → ReadBlock → Stop → Disconnect`

Эталон: `Tests/mic140/Mic140ProtocolDebug_Codex`  
Docs: `Docs/devices/mic140/lifecycle-codex.md`, `Docs/devices/mic140/protocol/`

Create defaults (Factory): `mppMic14048v3`, `GroundEnabled=True`.

## Слои

| Unit | Роль |
|------|------|
| `uRecorderDeviceDataThread` (Device/) | Универсальный Play/Stop + кольцо блоков |
| `uRecorderMic140DataThread` | Pump MDP-stream → кольцо |
| `uRecorderMic140Device` | `IMic140Device` / lifecycle |
| `uRecorderMic140Protocol/Scan/Stream/RawRing` | TCP + BIOS + кадры |
| `utils/*` | WireTypes, Consts, Timing, ChanDesc, Diag, Helper |
| `uRecorderMic140DataSource` | Prepare/Start/DoTick/Stop → теги |
| `Calibration/Flash/Thermocouple/UI` | ГХ и диалоги |

Старый код: `Device/backup/MIC140_legacy/` (не в search path).
