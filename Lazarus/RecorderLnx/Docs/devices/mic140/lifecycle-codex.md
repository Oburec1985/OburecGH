# MIC-140 lifecycle (Codex)

Эталон GUI: `Tests/mic140/Mic140ProtocolDebug_Codex`.

## Sequence

```
Create(..., 48, 10 Hz, 200 ms, mppMic14048v3, Ground=True)
  → Connect
  → InitializeDevice      // разово на TCP-сессию
  → ConfigureDevice       // не в Play; на v3 без Disconnect осторожно
  → Start / Play          // scan + DataThread.StartPlay
  → ReadBlock             // pop из кольца DataThread
  → Stop                  // StopPlay + stop scan
  → Disconnect            // сброс Init/Config
```

## Production

| Этап | Где |
|------|-----|
| Create | `CreateMic140Device` → `uRecorderMic140Factory` |
| Prepare | `TRecorderMic140DataSource.PrepareHardware` |
| Play | `DataSource.Start` → `Device.Start` |
| Tick | `DoTick` → `Device.ReadBlock` |
| Stop | `Device.Stop` + `Disconnect` |

`TestLink`: Connected/Started → OK (без `ProbeScan`, как MIC-185).

Код: `Device/MIC140/`. Backup: `Device/backup/MIC140_legacy/`.
