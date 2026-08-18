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
- `RecorderMebiusParseFloatBlock` reads MIC183/185 measurement packets as
  `Single` values. The runtime input for these channels is already the device
  measurement value in mV, not a signed ADC code that must be scaled by
  `range / 32768`.
- The previous transform incorrectly started from `code -> mV`. With a packet
  value around `2.5`, that produced an extra tiny coefficient; after the
  fallback path the visible result could remain close to the mV number.
- MIC185 excitation current calibration is read by `GET_CALIBR_KOEF` and cached
  through `RecorderMic185MakeCurrentCalibrationName`; it must be used when
  converting mV to `Ом` / `мкм/м`. If no cached current calibration exists, the
  nominal current from channel settings is the fallback.
- The hot path must apply a prepared transform and cached calibration pointers;
  no tag/calibration lookup by string should happen while samples are published.
- The reference `GaugeCmn` area is about the channel strain calculator, not the
  MIC185 protocol. Its useful rule here is to compile linear sensitivities into
  a single runtime coefficient where possible.

## Checked Hypotheses

- Unit label saving was already fixed separately:
  `2026-08-18-tag-auto-unit-overwrites-manual-unit.md`.
- The range calculation itself is not the failing path: it already displays
  `±125 Ом`, which matches the nominal 4 mA source current.
- Hypothesis rejected: MIC185 value blocks are raw ADC codes. Code inspection
  shows the protocol parser reads `Single` values from the device block.
- Hypothesis refined: merely keeping `fPowerMa` nominal is incomplete. Runtime
  must use calibrated excitation current when that calibration has been read,
  because the device can report per-channel current calibration.

## Action

- Replaced separate `fHardwareCalibrations` / `fPowerMa` runtime arrays with
  cached `TRecorderMic185ValueTransform`.
- `CacheRuntimeChannels` now builds a per-channel transform from:
  device mV value -> selected unit (`мВ` / `Ом` / `мкм/м`) -> enabled channel
  calibration pipeline.
- If all involved calibrations are linear, the runtime loop applies one
  precomputed `value = K * x + B`.
- If a non-linear calibration is configured, runtime falls back to cached
  calibration object references; it still avoids name lookups in the sample
  loop.
- The Ohm conversion uses `RecorderMic185ApplyCurrentCalibration(...)` when a
  cached current calibration exists and falls back to
  `Mic185EffectivePowerMa(settings)`. With nominal 4 mA, a visible `2.5 мВ`
  input becomes about `0.625 Ом`.
- `RecorderStrainBuildCalibration` was changed to compile a linear strain
  calibration (`K2 = 0`) instead of a polynomial; the dialog now displays
  `y = b + k*x` and reports the linear approximation error as diagnostic text.

## Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  finished with exit code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  finished with exit code 0.
- `git diff --check` for the touched files finished with exit code 0; only the
  existing LF/CRLF warnings were reported.

## 2026-08-18 Follow-up: displayed actual range

### Symptom

The original Recorder displayed per-channel actual ranges such as
`±124.943`, `±124.953`, `±125.023` for MIC185 SN168 on nominal `+500 мВ`,
`4 мА`, `Ом`. RecorderLnx displayed the same `±125.021` for every channel.

### Confirmed Facts

- The previous fix used calibrated current in runtime value conversion, but
  `Диап-н факт.` in the MIC185 settings grid still called the nominal
  `RecorderMic185EffectiveRangeMax/Text`.
- Because current calibration is per channel, the effective Ohm range must also
  be per channel: `range_mV / calibrated_current_mA`.
- Without a `Registry + Tag`, the range function cannot resolve the cached
  current calibration name, so a separate tag-aware API is required.

### Action

- Added `RecorderMic185EffectiveRangeMaxForTag` and
  `RecorderMic185EffectiveRangeTextForTag`; they apply
  `RecorderMic185ApplyCurrentCalibration(...)` before converting mV range to
  `Ом` / `мкм/м`.
- MIC185 tag creation/update paths now save `RangeMax/RangeMin` through the
  tag-aware function.
- MIC185 settings grid and channel properties dialog now display the
  tag-aware actual range, so channels with different calibrated excitation
  currents should no longer show one identical nominal range.

### Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  finished with exit code 0.
- First `RecorderDataSourcesTest.exe` run failed on the known timing-sensitive
  manager event/snapshot count check; immediate second run finished with exit
  code 0.
- `git diff --check` for the touched files finished with exit code 0; only the
  existing LF/CRLF warnings were reported.
