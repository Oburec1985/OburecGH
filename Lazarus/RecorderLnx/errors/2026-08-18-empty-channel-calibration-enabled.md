# 2026-08-18 - Empty channel calibration remains enabled

## Symptom

The tag settings dialog shows the channel calibration checkbox enabled even
though the channel calibration pipeline is empty. Opening the pipeline displays
an empty list, which makes the enabled checkbox misleading.

## Confirmed Facts

- `TTagSettingsDialog.UpdateChannelCurveText` displayed the checkbox state from
  `TRecorderTag.ChannelCalibrationEnabled`.
- An old or intermediate tag state can have `ChannelCalibrationEnabled=True`
  while `CalibrationNames.Count=0`.
- `SelectCalibrationButtonClick` already disables the flag after closing the
  pipeline with OK when the list is empty, but it did not normalize the state
  before opening/displaying the dialog.

## Action

- Added normalization in the tag settings dialog: if a tag has no channel
  calibration names, `ChannelCalibrationEnabled` is immediately set to `False`.
- Added the same guard in `StoreToTags`, so the checkbox cannot save an enabled
  empty channel calibration.

## Verification

- `Get-Process RecorderLnx` returned no running app before rebuild.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.

## Current Conclusion

Root cause: the common tag dialog trusted a stale `ChannelCalibrationEnabled`
flag even when the channel calibration name list was empty. The dialog now
normalizes this state before display and before saving.
