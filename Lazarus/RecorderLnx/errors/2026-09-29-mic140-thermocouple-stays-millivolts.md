# MIC-140 thermocouple output remained in millivolts

## Symptom

On KIP4, assigning a thermocouple characteristic in MIC-140 channel properties
still left the channel output and automatic unit in mV.

## Confirmed facts

- KIP4 was running package `0.1.115`.
- Its active project is `/home/user/Mera files/configs/001/default.config.json`.
- The persisted MIC-140 channel records contained an empty
  `thermocoupleScaleName` and `outputMode: mV`.
- The SDB selection button assigns `TComboBox.ItemIndex` programmatically; LCL
  does not invoke `OnChange` for that assignment.

## Root cause

The explicit `mV/degC` output selector introduced in 0.1.115 was synchronized
only by the thermocouple combo's `OnChange`. Selection through the `...` button
did not fire that event, so `StoreToSettings` saved the channel as mV.

## Fix

- Selecting an SDB curve through `...` explicitly selects output mode `degC`.
- Clearing the curve explicitly selects output mode `mV`.
- The thermocouple curve remains a MIC-140 hardware-stage setting and no longer
  toggles the independent sensor/channel-GX flag.

## Verification

- Forced Linux build: exit 0, no missing shared libraries.
- DEB `0.1.116`, SHA-256
  `8ECBB082B1E7194CBBA082AAF009C6F44EBB847DF565DDD31AFF5DA164C3C0B0`.
- Installed on KIP4 (`192.168.9.85`): 1 succeeded, 0 failed.
- Windows sources compile through linking; replacement of the local executable
  is currently blocked by a running local RecorderLnx process.

## Follow-up: TIn hardware GX was cleared on dialog exit

`TRecorderMic140DataSource.DoCreateTags` reset existing compensation tags to
`HardwareCalibrationEnabled=False`, cleared the calibration name/pipeline and
forced `UnitName=code` whenever a source was recreated. Defaults are now
assigned only to newly created TIn tags. Existing TIn settings survive source
dialog Apply/recreation.

The project-wide default was also aligned for supported disk-backed hardware
calibrations: if a channel has no persisted hardware calibration name yet and
a calibration file is found, MIC-140 AIn/TIn, MIC-185 and MC-201 enable the
hardware GX by default. A user-disabled channel retains its calibration name,
so subsequent loads do not turn the checkbox back on.

Version 0.1.117: Windows and Linux forced builds passed; deployment succeeded
on KIP-1, KIP-2, KIP-3 and KIP-4 (4/4).
