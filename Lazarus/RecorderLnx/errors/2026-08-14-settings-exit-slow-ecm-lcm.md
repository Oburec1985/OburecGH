# 2026-08-14 - Settings exit is slow, ECM/LCM comparison

## Follow-up: Tag settings OK is slow after changing range

### Symptom

Opening a tag settings dialog, changing the hardware range, pressing `OK`, and
returning to the main window takes too long.

### Checked Facts

- `TMainForm.OpenSelectedTagSettings` handles `OK` from the per-tag settings
  dialog.
- If the tag changes its hardware programming signature, this path cleared the
  whole `DataSources` manager, rebuilt every runtime source, and then called
  `PrepareRuntimeForConfiguration`.
- `PrepareRuntimeForConfiguration` is intentionally a configuration boundary:
  it should run before Preview/Record so entering Preview does not pay the
  configuration cost.
- The inefficient part was the full manager clear/rebuild when only one
  source-id was affected by the tag dialog.
- After dialog close, the same path also refreshed live mnemonic editor state
  and base oscillograms even when those pages were not active.

### Hypotheses And Results

- Hypothesis: the delay is caused by unnecessary full source-manager rebuild
  before the required hardware preparation.
  - Check: inspected `OpenSelectedTagSettings` after range-change signature
    comparison.
  - Result: confirmed. The code called `fRecorder.DataSources.Clear` and
    invalidated all runtime contexts instead of replacing the changed source.

- Hypothesis: extra hidden-page UI refresh adds avoidable delay.
  - Check: inspected the post-dialog refresh block.
  - Result: confirmed. `RefreshLive` and `RefreshBaseOscillograms` were called
    without checking the active page.

### Fix

- `OpenSelectedTagSettings` now uses `RecorderReplaceRuntimeSource` for the
  source-id before/after the tag dialog instead of clearing all sources.
- `PrepareRuntimeForConfiguration` remains on the settings-OK path so changed
  hardware is prepared before the next Preview/Record.
- Hidden mnemonic/base pages are no longer refreshed from this dialog-close
  path.

### Verification

- `git diff --check` completed with only LF/CRLF warnings.
- `RecorderLnx.lpi` rebuilt successfully with exit code 0.
- `RecorderDataSourcesTest.exe` completed successfully with exit code 0.

## Symptom

Leaving the settings dialog and returning to the main screen takes too long.
User asked whether RecorderLnx has `ecm`/`lcm` (`EnterConfigMode` /
`LeaveConfigMode`) and whether behavior matches the original Recorder.

## Checked Facts

- Original Recorder has console commands `ecm` and `lcm` in
  `D:\works\windev-v3.9\rc_conui\rc_conui.cpp`.
- Original Recorder exposes `EnterConfigMode` / `LeaveConfigMode` in
  `D:\works\windev-v3.9\mr\iface\IRecorder.h`.
- Original implementation is in `D:\works\windev-v3.9\mr\rcmain.cpp`.
  `EnterConfigMode` denies entry from View/Record/Programming states, pushes
  `RS_CONFIGMODE`, calls `OnBeforeSetup`, and notifies plugins/UI.
- Original `LeaveConfigMode` decrements nested entry counters. Only the last
  leave calls `OnAfterSetup`, pops `RS_CONFIGMODE`, notifies plugins/UI, and
  resets config change flags.
- RecorderLnx currently has no literal `EnterConfigMode` or `LeaveConfigMode`
  API. Its equivalent is spread across `TMainForm.btnSettingsClick`,
  `TRecorderSettingsDialog.OkButtonClick`, source signatures, and runtime
  source replacement.
- `TRecorderSettingsDialog.OkButtonClick` itself does not call
  `PrepareHardwareAll`; it stores settings, syncs configured sources, creates
  selected tags, and closes.
- Previous related issue: reset-all in the modal settings dialog was slow
  because it called `DataSources.PrepareHardwareAll` synchronously.
- `TMainForm.btnSettingsClick` already compares per-source programming
  signatures and calls `RecorderReplaceRuntimeSource` only for changed
  source ids.
- Before this fix, `TRecorderDataSourceManager.ReplaceSource` always called
  `PrepareHardware` for an enabled replacement source, even when the manager
  was not running and the user was simply returning from settings to Stop mode.

## Hypotheses And Results

- Hypothesis: settings OK directly calls full `PrepareHardwareAll`.
  - Check: inspected `TRecorderSettingsDialog.OkButtonClick`.
  - Result: rejected. No direct `PrepareHardwareAll` there.

- Hypothesis: slow exit comes from replacing changed sources and immediately
  preparing hardware one by one.
  - Check: inspected `TMainForm.btnSettingsClick`,
    `RecorderReplaceRuntimeSource`, and `TRecorderDataSourceManager.ReplaceSource`.
  - Result: confirmed. The per-source filter exists, but each changed enabled
    source still synchronously performs `PrepareHardware`.

- Hypothesis: original ECM/LCM is an explicit state boundary, while RecorderLnx
  has only scattered dialog logic.
  - Check: searched original and RecorderLnx for `EnterConfigMode`,
    `LeaveConfigMode`, `ecm`, `lcm`, `ConfigMode`.
  - Result: confirmed. Original has explicit API/counters; RecorderLnx does not.

## Fix

- Added `APrepareNow` to `TRecorderDataSourceManager.ReplaceSource`.
- Added matching optional `APrepareNow` to `RecorderReplaceRuntimeSource`.
- `TMainForm.btnSettingsClick` now passes `APrepareNow = DataSources.Running`.
  When RecorderLnx is stopped, changed sources are replaced logically but their
  hardware is not connected/programmed before returning to the main screen.
  When acquisition is already running, replacement still prepares and starts
  the changed source immediately.

## Verification

- First `RecorderLnx.lpi` rebuild compiled successfully but failed at link with
  `error code: 5` because running `RecorderLnx.exe` PID 5212 locked the exe.
- Stopped PID 5212.
- Rebuilt `RecorderLnx.lpi` successfully with exit code 0.
- The known Windows post-build `#!/bin/sh` message remains non-blocking.

## Remaining Risk

This fixes the confirmed synchronous hardware prepare on settings exit in Stop
mode. It does not yet introduce a full explicit RecorderLnx
`EnterConfigMode`/`LeaveConfigMode` API with nested initiator counters like the
original. If settings exit is still slow, next checks should measure
`SyncToRegistry`, `CreateSelectedMeraTags`, `RebuildTagList`, and
`RenderActivePage` separately.

## Follow-up: First Preview was slow after settings/startup

### Symptom

User observed a very slow transition to Preview, about 30 seconds. A repeated
transition to Preview was fast.

### Checked Facts

- `C:\Mera Files\RecorderLnx\LogWindows.log` showed one slow start:
  `Data sources started in 25953 ms`, followed later by a fast repeated start:
  `Data sources started in 15 ms`.
- During the slow start, MIC-140 preparation ran first, then multiple MIC-185
  sources ran startup/connect/initialize/configure stages.
- `TRecorderDataSourceManager.StartAll` still called `PrepareHardware` for
  every enabled source before creating source threads. This made Preview a
  hidden hardware-programming point.
- `PrepareHardwareAll` was already intended to parallelize independent sources,
  but MIC-185 held `gMic185PrepareLock` across connect/init/config, so MIC-185
  network waits accumulated.
- Reset requests are stored separately in
  `uRecorderHardwareLiveDevices`. A pending reset must still force one future
  `PrepareHardware`.

### Hypotheses And Results

- Hypothesis: first Preview is slow because hardware preparation was deferred
  from settings/startup and `StartAll` performs it synchronously.
  - Check: inspected `StartDataSources`, `StartAll`, and the log timing.
  - Result: confirmed.

- Hypothesis: repeated Preview is fast because the device contexts remain
  prepared after Stop and Start only reuses them.
  - Check: inspected MIC-140/MIC-185 `Stop`/`Start` behavior and log timing.
  - Result: confirmed.

- Hypothesis: MIC-185 preparation is not truly parallel.
  - Check: inspected `TRecorderMic185DataSource.PrepareHardware`.
  - Result: confirmed. The global prepare lock covered connect/init/config.

### Fix

- Added a `Prepared` flag to `TRecorderDataSourceManager.TSourceContext`.
- Added `NeedsPrepareHardware`, which returns true for unprepared contexts and
  contexts with a pending reset request.
- Added `RecorderHardwareHasSourceResetRequest` so the manager can detect a
  pending reset without consuming it.
- `PrepareHardwareAll` now prepares only pending enabled contexts.
- `StartAll` no longer calls `PrepareHardware`; Preview starts only already
  prepared sources and reports a clear error for unprepared ones.
- Settings `OK/Apply` now replaces changed runtime sources without per-source
  immediate prepare, syncs enabled flags, and then performs one shared
  `PrepareRuntimeForConfiguration` for the changed/pending sources.
- MIC-185 no longer holds `gMic185PrepareLock` across connect/init/config; the
  lock now protects only the shared registry identity write.

### Verification

- First rebuild reached link and failed with `error code: 5` because
  `RecorderLnx.exe` PID 10360 was running and locked the target executable.
- Stopped PID 10360.
- Rebuilt `RecorderLnx.lpi` successfully with exit code 0.
- The known post-build `#!/bin/sh` message remains non-blocking.
