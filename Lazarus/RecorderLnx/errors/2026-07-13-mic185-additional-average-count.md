# MIC185 additional settings: blank average count

Date: 2026-07-13

## Symptom

The MIC183/185 additional settings dialog showed an empty "average count" combo.
At 100 Hz the original Recorder shows 128 averaging points, while the debugger in
RecorderLnx could show value 7.

## Cause

The original MIC185V2 driver stores `AveragePointCount` as the exponent of two,
not as a visible point count. `AveragePointCount = 7` means `2^7 = 128` ADC
measurements. RecorderLnx wrote this protocol value directly into a
`csDropDownList` combo that contained `1,2,4,8,16,32,64,128`, so value `7` had no
matching item and the control looked blank.

The same dialog also loaded only constants and did not persist/program the
module-wide fields from the dialog.

## Fix

- Added `TMic185ModuleProgramSettings` for the module-wide MIC185V2 settings.
- Kept protocol compatibility: JSON and ProgramDeviceBin use exponent `7`;
  the UI displays point count `128`.
- Added conversion helpers and the original max-rate formula from
  `CMIC185V2Base::CalcMaxRate`.
- Persisted module settings in `dataSources[].mic185` and passed them into
  `ProgramDeviceBin`.

## Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0. Existing post-build `copy_sdb_res.bat` still prints
  `#! is not recognized`, but does not fail the build.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  passed.
