# 2026-08-18 - Tag auto unit overwrites manual unit

## Symptom

In the tag settings dialog for a MIC183/185 channel, the user selects the
500 mV range, chooses `Ом` as the unit, leaves/checks `Auto`, and returns to
the main tag table. The Unit column still shows `мВ`.

## Confirmed Facts

- The main digital table displays `TRecorderTag.UnitName`.
- `TTagSettingsDialog.StoreToTags` first writes `fUnitCombo.Text` to
  `lTag.UnitName`.
- The same method then writes `lTag.AutoUnit := fAutoUnitCheck.Checked`.
- At the end of the method, when `AutoUnit=True` and the tag has a channel
  calibration, `TryGetChannelCalibrationOutputUnit` overwrites `lTag.UnitName`
  with `TRecorderCalibration.UnitOut`.
- For MIC183/185 hardware/calibration paths this output unit is commonly `мВ`,
  so a manual `Ом` selection can be lost during OK/Apply.

## Checked Hypotheses

- The MIC185 runtime conversion path itself supports `Ом`:
  `RecorderMic185ConvertValue` normalizes `UnitName` and converts mV to Ohms.
  The current symptom is therefore not caused by missing runtime conversion.
- The MIC185 channel dialog preserves `ATag.UnitName` when opening/saving.
  The overwrite happens in the common tag settings OK/Apply path.

## Action

- Preserve an explicit unit entered/selected in `fUnitCombo`.
- Apply automatic unit from channel calibration only when the unit field is
  empty.

## Verification

- Stopped running `RecorderLnx.exe` PID 10180 which held the output file.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.

## Current Conclusion

Root cause: common tag settings OK/Apply applied the automatic unit after the
manual unit field had already been saved. Manual `fUnitCombo.Text` now has
priority; auto calibration output unit is used only as a fallback for an empty
unit field.
