# 2026-07-09 MIC185 range programming and selection

## Symptom

In the MIC183/185 settings dialog, `Select all` created or linked channels but
did not visibly select all grid rows. Opening `Properties` after selecting
several rows changed only the current row. A live test with channel range
`+/-500 mV` showed overrange on another channel, so MIC185 programming needed
comparison with the original Recorder/Mebius implementation.

## Investigation

- Original MIC185V2 range table uses `0 = +/-500 mV`, `1 = +/-50 mV`,
  `2 = +/-5 mV`, `3 = +/-0.5 mV`. RecorderLnx constants match this mapping.
- Original `CMIC185V2::OnProgramDevice` sends `PROGRAMM_DEVICE_BIN`, then
  `IoCmd_FinishProgramming`, which performs `SET_SESSION_ID` and `PROGRAM`.
  RecorderLnx already follows the same command order.
- `RecorderMic185ChannelAddressToIndex` parses channel addresses from the last
  dash inside `MIC183_185-{3-N}`, so `MIC183_185-{3-14}` maps to channel 14,
  not channel 4.

## Fix

- `uRecorderMic185SettingsDialog.pas`
  - `Select all` now sets the grid selection rectangle after creating/linking
    rows, so the UI displays the full selection.
  - `Properties` collects selected measurement rows and copies the edited
    MIC185 channel mode to each selected measurement channel.
  - Temperature and UTS rows are excluded from measurement-channel group edits.

- `uRecorderMic185DataSource.pas`
  - `ApplyChannelProgramSettings` logs the prepared channel programming summary
    to `LogWindows.log`, including channel number, range index, commutation and
    block size.
  - `LoadMic185DataSourceConfigs` restores `dataSources[].mic185.tagLinks[]`
    into tags so MIC185 hardware bindings survive project load through the
    source-specific section.

## Verification

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0 and linked `lib\x86_64-win64\RecorderLnx.exe`.

The existing post-build `copy_sdb_res.bat` prints `#!/bin/sh is not recognized`,
but `lazbuild` still returns success.

## Follow-up

During the next live MIC185 run with channel 14 set to `+/-500 mV`, check
`LogWindows.log` for `ApplyChannelProgramSettings ... ch14 range=0 ...`. If the
log is correct but the hardware still reports overrange on channel 4, the next
suspect is device-side physical channel ordering or scan/result demultiplexing,
not tag-address parsing or range index encoding.

## 2026-07-09 load crash after saving config

### Symptom

After changing MIC185 settings and saving the project, RecorderLnx crashed on
startup in `TRecorderTagRegistry.AddTag` with `Tag id already exists`.

### Root Cause

`LoadRecorderProjectConfig` called `LoadMic185DataSourceConfigs` before loading
the main `tags[]` section. The new MIC185 `tagLinks[]` loader created tags from
the data-source section first. Then the generic `tags[]` loader created the same
saved tags with their persisted IDs and `AddTag` rejected the duplicate ID.

### Fix

Moved `LoadMic185DataSourceConfigs` in `Core/uRecorderProjectFiles.pas` to run
after the generic `tags[]` loop. MIC185 `tagLinks[]` now updates/restores
already loaded tags and only creates missing links after the registry has its
saved tag IDs.

### Verification

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0 after stopping a running `RecorderLnx.exe` process
that held the output file.

## 2026-07-09 hardware settings must belong to the MIC185 source

### Symptom

After loading the project, the MIC185 settings dialog again showed all
measurement channels as `+/-5 mV`, and live programming logged `range=2` for
all channels including channel 4. The saved `default.config.json` also contained
only `range=2`, so the previously selected `+/-500 mV` mode had not survived in
the persistent configuration.

### Architecture Decision

MIC185 hardware settings must not be stored in `TRecorderTag.SourceValueMode`.
The tag is only a binding: tag id/name + source id + channel address. Hardware
range, commutation, sensor scheme, shunt, balance, sensitivity, resistance and
block size belong to the MIC185 source node.

### Fix

- Added `SpecificConfigText` to `TRecorderConfiguredDataSource` as an in-memory
  holder for device-specific source configuration.
- MIC185 now persists channel hardware settings as
  `dataSources[].mic185.channels[]`.
- `dataSources[].mic185.tagLinks[]` now stores only tag binding data:
  `tagId`, `tagName`, `address`, `pollFrequencyHz`.
- `LoadMic185DataSourceConfigs` migrates old configs: if old
  `tagLinks[].sourceValueMode` or old MIC185 tag `SourceValueMode` exists, it is
  copied into the source `channels[]` config and then cleared from the tag.
- MIC185 settings dialog reads/writes channel hardware settings through
  `RecorderMic185GetSourceChannelMode` / `RecorderMic185SetSourceChannelMode`.
  The channel dialog may still use a tag object as a temporary UI container, but
  the value is moved into the source config and cleared from the tag after OK.
- `ApplyChannelProgramSettings` now reads programming settings from the source
  config, not from tags.

### Verification

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0 and linked `lib\x86_64-win64\RecorderLnx.exe`.

The existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh` message,
but `lazbuild` returned success.

### Remaining Note

The current saved project file already contains `range=2` everywhere, so the
lost `+/-500 mV` choice cannot be reconstructed automatically. Set the needed
channel/group to `+/-500 mV` once more; after this fix it should be saved under
`dataSources[].mic185.channels[]` and the next programming log should show
`range=0` for those channels.

## 2026-07-09 Apply/OK must persist and program the device

### Symptom

After changing several channels and pressing `Apply` then `OK`, reopening the
MIC183/185 settings dialog again showed the ranges as `+/-5 mV`. There was also
no visible proof that the device had been reprogrammed after leaving the
settings dialog.

### Fix

- `uRecorderMic185SettingsDialog.pas`
  - Keeps the current 64-channel hardware setup in `fChannelSettings` while the
    dialog is open.
  - Loads `fChannelSettings` from the MIC185 source config on entry, not from
    tags.
  - Writes all channel settings to the MIC185 source config on `Apply` and `OK`.
  - Calls `RecorderMic185ProgramConfiguredSource` on `Apply` and `OK`.
  - If programming fails on `OK`, the dialog stays open and shows the error
    instead of silently closing.

- `uRecorderMic185DataSource.pas`
  - Added `RecorderMic185ProgramConfiguredSource`: it builds the complete
    64-channel `ProgramDeviceBin` from the source node, connects a temporary
    MIC185 device, calls `ProgramDevice`, then disconnects.
  - Logs `ProgramConfiguredSource ... power=... chN range=... commut=...
    scheme=... shunt=... block=...` before programming.
  - Stores source-level `powerMaCode` under `dataSources[].mic185.powerMaCode`.

- `uMic185MebiusTypes.pas` / `uMic185Device.pas`
  - Added MIC185 current-source DAC conversion matching original Mebius:
    `code = (200 * (mA / 1000) + 2.5) * 16384 / 5`.
  - `ProgramDeviceBin` now writes configured `PowerMaCode` instead of always
    forcing the default value.

- `uRecorderMic185ChannelDialog.pas`
  - The module power combo now reads and writes the MIC185 power DAC code.
    It is persisted in the source node, not in tags.

### Verification

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0 and linked `lib\x86_64-win64\RecorderLnx.exe`.

The existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh`
message, but `lazbuild` returned success.

## 2026-07-09 source restart overwrote dialog programming

### Symptom

Changing MIC185 channels to `+/-500 mV` in the dialog did call programming:
`LogWindows.log` showed `ProgramConfiguredSource ... ch1 range=0 ... ch64
range=0`. A few seconds later, when the acquisition source resumed,
`ApplyChannelProgramSettings` logged `range=2` for all channels and programmed
the device back to `+/-5 mV`.

The saved `default.config.json` also had `dataSources[].mic185.tagLinks[]` but
no `dataSources[].mic185.channels[]` and no `powerMaCode`, so reopening the
dialog could only show defaults.

### Fix

- `SaveMic185DataSourceConfigs` now enumerates MIC185 sources from the
  configured-source list as well as from tags.
- MIC185 save now always writes the complete source-level hardware config:
  `dataSources[].mic185.powerMaCode` and `dataSources[].mic185.channels[64]`
  with `sourceValueMode` for every measurement channel.
- `TRecorderMic185DataSource.ApplyChannelProgramSettings` now builds the
  64-channel programming array directly from the MIC185 source config instead
  of looping over tags and falling back to defaults when tag hardware settings
  are empty.

### Verification

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0 and linked `lib\x86_64-win64\RecorderLnx.exe`.

The existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh`
message, but `lazbuild` returned success.

## 2026-07-09 OK close path still allowed stale reopen

### Symptom

The user changed a MIC185 channel range to `500 mV`, closed the settings dialog,
opened it again, and still saw `5 mV`.

### Fix

- `uRecorderMic185SettingsDialog.lfm`
  - Removed `ModalResult = mrOk` from the `OK` button. The form no longer closes
    automatically before the handler finishes the MIC185 source flush and
    programming path.

- `uRecorderMic185SettingsDialog.pas`
  - `btnOkClick` now explicitly sets `ModalResult := mrOk` only after
    `StoreAllGridTags` and `ApplySettingsToDevice` succeed.
  - `ApplyRecorderMic185SourceDialog` repeats `StoreAllGridTags` after a
    successful modal close so the caller sees the latest source node state.
  - `StoreChannelSettingsConfig` logs a diagnostic line for channel 4:
    `SettingsDialog stored ... ch4 range=... commut=... scheme=... power=...`.

### Verification

The first rebuild compiled but could not relink because a running
`RecorderLnx.exe` held the output file (`error code: 5`). After stopping that
process, `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0 and linked `lib\x86_64-win64\RecorderLnx.exe`.

The existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh`
message, but `lazbuild` returned success.

## 2026-07-09 common settings sync deleted MIC185 channel config

### Symptom

After selecting all MIC185 channels and changing the range to `500 mV`, the log
showed that the MIC185-specific dialog stored and programmed the expected
settings:

- `SettingsDialog stored ... ch4 range=0`
- `ProgramConfiguredSource ... ch1 range=0 ... ch64 range=0`

A few seconds later the runtime data source programmed the device back to
defaults:

- `ApplyChannelProgramSettings ... ch1 range=2 ... ch64 range=2`

The visible dialog also showed `5 mV` again on the next entry.

### Root Cause

`TRecorderSettingsSourceProbe.SyncToRegistry` removed every configured hardware
source shown in the hardware tree before re-adding the currently known sources.
For MIC185 this deleted `TRecorderConfiguredDataSource.SpecificConfigText`,
which is where `dataSources[].mic185.channels[]` lives. Re-adding the source
with `RecorderConfiguredDataSourcesEnsure` recreated only the generic source
record, so channel hardware settings were lost immediately after closing the
common settings dialog with `OK`.

### Fix

- `UI/uRecorderSettingsSourceProbe.pas`
  - Builds a desired hardware source-id set from the current Mera/MIC140/MIC185
    probe lists.
  - Removes only configured hardware sources that are no longer desired.
  - Keeps existing desired configured sources intact, preserving
    `SpecificConfigText` for MIC185 channel ranges, commutation, sensor scheme,
    shunt, balance, and power settings.

### Verification

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0 and linked `lib\x86_64-win64\RecorderLnx.exe`.

The existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh`
message, but `lazbuild` returned success.
