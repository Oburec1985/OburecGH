# Active hardware sources after tag settings OK

## Symptom

Opening tag settings and closing it with OK could make MIC140 tags visible in
the main tag list even when the MIC140 device was not connected.

## Cause

`TTagSettingsDialog.CreateDialog` called
`TRecorderTagRegistry.RefreshActiveSourcesFromTags`. That registry method
cleared the active-source list and then registered MIC140/MIC185 hardware
sources only because tags with these source ids existed. This turned persisted
or detached hardware tags into visible tags without a live source check.

## Fix

- The tag settings dialog no longer recalculates active hardware sources.
- `RefreshActiveSourcesFromTags` no longer auto-registers MIC140/MIC185 source
  ids from tags.
- `TMainForm.UpdateActiveSourceIds` explicitly calls
  `RecorderHardwareSourceLinkOk` and registers a hardware source only when the
  source link test succeeds.

This keeps the current registry shape but moves behavior toward the intended
model: source visibility is derived from source availability, not from the mere
presence of tags.

## Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  passed.
