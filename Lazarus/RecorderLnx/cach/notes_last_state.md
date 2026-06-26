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
