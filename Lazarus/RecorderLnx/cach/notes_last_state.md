# MIC-140 refactor — последнее состояние (2026-06-23)

## Промпт
Продолжить план: вынести flash/calibration, Mebius types, подключить LegacyScanDriver, разнести константы.

## Сделано

### Новые unit'ы
- `uRecorderMic140Flash.pas` — mi118tar, tare records, чтение из ПЗУ (~560 строк)
- `uRecorderMic140Calibration.pas` — CSV, registry, download из flash (~760 строк)
- `uRecorderMic140MebiusTypes.pas` — `TMic140BaseSettings`, `Mic140BuildSettings`
- `uRecorderMic140LegacyChannelDesc.pas` — ME048/MIC140 descriptor packing

### Монолит
- `uRecorderMic140DataSource.pas`: **~5210 → ~3693 строк** (−30%)
- Подключён `TRecorderMic140LegacyScanDriver` через `fProtocolDriver` в read-thread
- `CjcTemperOffsetC` per-channel (без hardcoded `TEMPER_OFFSET[]`)
- Константы: `LegacyConstants`, `FlashConstants`, `Thermocouple`, `MebiusConstants`

### Сборка
`lazbuild -B RecorderLnx.lpi` — **OK** (exit 0)

## Следующие шаги
- Mebius protocol driver stub (`mpkMebius`)
- Вынести thermocouple transform (`Mic140TransformThermocoupleChannelSample`) в `uRecorderMic140Thermocouple`
- UI: поле `cjcTemperOffsetC` в диалоге канала
- Smoke: `Tools/mic140_preview_eval.ps1 -Seconds 3`

## 2026-06-26 MIC140v2 preview acceptance

Prompt: RecorderLnx moved from Cursor branch to mic140v2; fix failing preview stream
acceptance, compare with original Recorder, keep code/logs clean.

Done:
- MIC140v2 keeps the AIn-only scan contract: 48 BIOS slots, 48-word payload row.
- Added row-level raw validation in `uRecorderMic140v2Diag.pas`.
- Added `Mic140v2KeepGoodSampleRows` in `uRecorderMic140v2Stream.pas`: valid MDP/BIOС
  packets can contain one bad ADC row; the driver drops only bad rows, preserves
  num_buff/read counters, shifts `FirstSampleIndex` to the first kept row, and
  logs dropped rows.
- Removed verbose per-packet quality logging; kept compact dropped-row and stream
  summary diagnostics.
- Checked original `mtc/Modscn.cpp::CreateBiosCCScanBuf`; FIFO descriptor layout
  matches Recorder (`head/tail/begin`, `size=2*ready`, `sizeready=ready`).

Verification:
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  OK.
- `Tools\mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0` passed four times after
  the fix. Final: `PASS pub=14 read=14 ratio=100% corrupt=0 pubGaps=0 readGaps=0
  softRestart=0 expected=15 range=13..20 bps=5 readings=ok good=10 ch12=-7554`.

Open observation:
- On the tested device a single bad ADC row appears periodically inside an otherwise
  valid packet (`num_buff` examples: 3, 8, 13). Stream order, MDP checksum, BIOS
  header, publish gaps, and resync counters stay clean. Root cause can be researched
  later; current driver prevents spikes and keeps diagnostics visible.
