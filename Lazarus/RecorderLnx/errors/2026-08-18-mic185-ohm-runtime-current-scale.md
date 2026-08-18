# 2026-08-18 - MIC185 Ohm value must use one summary linear transform

## Symptom

For a MIC183/185 channel configured to the 500 mV range and displayed as
`Ом`, the settings grid shows an effective range around `±125 Ом`, but the
runtime value in the main tag table remains around `2.5`. The user correctly
noticed this looks like the old `2.5 мВ` value being shown inside an Ohm range.

## Confirmed Facts

- `RecorderMic185EffectiveRangeMax` computes Ohm range as
  `range_mV / Mic185EffectivePowerMa(settings)`.
- `CMic185DefaultPowerMaCode = 10813` decodes to about `4 мА`, so a 500 mV
  range becomes about `125 Ом`.
- `CacheRuntimeChannels` computed `fPowerMa[I]` from the same channel settings,
  but then, for `Ом` / `мкм/м` and enabled hardware calibration, replaced it
  with `RecorderMic185ApplyCurrentCalibration(...)`.
- `RecorderMic185ConvertValue` uses `fPowerMa[I]` to divide calibrated mV into
  Ohms. If current calibration maps nominal 4 mA to about 1 mA, 2.5 mV becomes
  2.5 Ohm instead of about 0.625 Ohm.
- The hot path still branched per sample and did not have one explicit summary
  characteristic from raw ADC code to tag value.

## Checked Hypotheses

- Unit label saving was already fixed separately:
  `2026-08-18-tag-auto-unit-overwrites-manual-unit.md`.
- The range calculation itself is not the failing path: it already displays
  `±125 Ом`, which matches the nominal 4 mA source current.
- Merely keeping `fPowerMa` nominal is not enough as an architectural fix:
  runtime must not re-interpret UI strings or repeatedly search calibration
  names. The channel settings dialog should imply one final `y = kx + b`
  transform for the acquisition loop.

## Action

- Replaced separate `fHardwareCalibrations` / `fPowerMa` runtime arrays with
  cached `TRecorderMic185ValueTransform`.
- `CacheRuntimeChannels` now builds a per-channel transform from:
  raw ADC code -> mV, selected unit conversion (`мВ` / `Ом` / `мкм/м`), and the
  enabled channel calibration pipeline.
- If all involved calibrations are linear, the runtime loop applies one
  precomputed `value = K * code + B`.
- If a non-linear calibration is configured, runtime falls back to cached
  calibration object references; it still avoids name lookups in the sample
  loop.
- The Ohm conversion uses the same `Mic185EffectivePowerMa(settings)` scale as
  the displayed range, so `500 мВ / ~4 мА = ~125 Ом` and values are in that same
  scale.

## Verification

- `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` finished with exit code 0.
- `RecorderDataSourcesTest.exe` finished with exit code 0.
- `git diff --check -- uRecorderMic185DataSource.pas` finished with exit code
  0; only the existing LF/CRLF warning was reported.
