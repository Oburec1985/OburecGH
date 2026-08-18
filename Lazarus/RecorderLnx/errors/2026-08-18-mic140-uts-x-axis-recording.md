# 2026-08-18 - MIC-140 UTS X-axis recording

## Symptom

MIC-140 and MIC185 write the X axis differently in MERA records. MIC185 UTS
has a `.x` file and measurement channels can be correlated by UTS, while
`MIC140_{42_uts}.dat` is written without `MIC140_{42_uts}.x`; MIC-140
measurement channel properties show a regular time step and no SEV/UTS
correction channel.

## Confirmed Facts

- `TRecorderMeraTagWriter.WriteBlock` creates `.x` only when
  `AForceExplicitX=True` or when time steps are non-uniform.
- `TMainForm.ConsumeTagDataCycle` passed `AForceExplicitX=True` only for
  `MIC-185:*` tags whose address ends with `-uts`.
- `TMainForm.FindUtsChannelNameForTag` returned a UTS channel only for
  `MIC-185:*` sources.
- MIC-140 already publishes UTS as `(device time X, UTS seconds Y)` through
  `Registry.PublishValue(fRuntimeUtsTag, lDeviceTimeSec, lUtsValueSec)`, so
  storage was dropping the explicit-X contract rather than the datasource.

## Checked Hypotheses

- Hypothesis: MIC-140 datasource does not publish UTS at all.
  Check: `uRecorderMic140DataSource.pas` has `PublishUtsIfNew` publishing
  `fRuntimeUtsTag` with device-time X and UTS seconds Y. This is not the
  direct cause of missing `.x`.
- Hypothesis: storage only special-cases MIC185.
  Check: `uMainForm.pas` had hard-coded `StartsText('MIC-185:', SourceId)`.
  Confirmed.

## Change

`uMainForm.pas` now treats both `MIC-185:*` and `MIC-140:*` `*-uts` tags as
explicit-X UTS tags. `FindUtsChannelNameForTag` now maps ordinary MIC-140
tags to a selected UTS tag from the same source, exactly as it already did for
MIC185. `uRecorderDataStorage.pas` writes `UTS_Channel` only when the referenced
UTS tag actually produced a signal in the current record.

## Verification

- `git diff --check -- Lazarus\RecorderLnx\UI\uMainForm.pas`: exit code 0,
  only existing LF/CRLF warning before the storage descriptor guard.
- Full rebuild was intentionally skipped because `RecorderLnx.exe` PID 19944
  is currently running from the build output path.

## Expected Manual Check

Record with `MIC140_{42_uts}` selected. The frame directory should contain
`MIC140_{42_uts}.x`, and normal MIC-140 channel descriptors should include
`UTS_Channel=MIC140_{42_uts}` when that UTS tag is selected and receiving data.
