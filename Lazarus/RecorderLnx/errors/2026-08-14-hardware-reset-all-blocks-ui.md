# 2026-08-14 - Hardware reset all blocks settings dialog

## Symptom

User reported that "reset all devices" in the hardware settings tree stayed busy for more than a minute. After it returned, only one MIC-185 recovered while other MIC-185 endpoints still showed errors. User confirmed other endpoints are pingable.

## Checked Facts

- The settings dialog had a running RecorderLnx process PID `21472`; this process also locked the exe during rebuild.
- `HardwareResetSourceClick(nil)` enumerates all hardware sources from the tree.
- The reset task itself already runs endpoints through `SharedRunParallel`.
- After the parallel reset tasks, the handler synchronously called `fRecorder.DataSources.PrepareHardwareAll`.
- For MIC-185, `PrepareHardware` enters `gMic185PrepareLock`, so Connect/Initialize/Configure is serialized per MIC-185 source.
- The handler then retried failed sources and called `PrepareHardwareAll` a second time from the modal settings dialog.
- Ping/TCP reachability does not prove the MIC-185 Mebius protocol task is answering; previous logs had `IoControl timeout` with TCP open.

## Hypotheses And Results

- Hypothesis: reset task parallelism itself is missing.
  - Check: inspected `TRecorderHardwareResetTask` and `SharedRunParallel(lProcedures)`.
  - Result: rejected. Reset tasks are parallel.

- Hypothesis: the modal dialog blocks because it runs full hardware preparation after reset.
  - Check: inspected `HardwareResetSourceClick`.
  - Result: confirmed. It called `PrepareHardwareAll` once after reset and again for retry.

- Hypothesis: MIC-185 preparation can take about device_count * timeout.
  - Check: inspected `TRecorderMic185DataSource.PrepareHardware`.
  - Result: confirmed. MIC-185 Connect/Initialize/Configure is guarded by `gMic185PrepareLock`, so many offline/error MIC-185 sources are effectively serialized.

## Fix

- Removed synchronous `PrepareHardwareAll` from the settings-dialog reset command.
- Removed the immediate retry `PrepareHardwareAll` pass from "reset all".
- A successful reset task now clears the old offline flag because the old flag describes the pre-reset state. The next real lifecycle entry point will consume the reset request and mark a fresh error if Connect/Initialize/Configure still fails.
- The reset command still logs the batch and still releases MIC-185 runtime/session state through the reset task.

## Verification

- First rebuild reached link but failed with `error code: 5` because running `RecorderLnx.exe` PID `21472` locked the output executable.
- Stopped PID `21472`.
- Rebuilt `RecorderLnx.lpi` successfully with exit code `0`.
- Existing post-build `#!/bin/sh` message remains non-blocking.

## Remaining Risk

This change fixes the long modal UI wait. It does not guarantee that every pingable MIC-185 will initialize: if the TCP port answers but Mebius `IoControl` times out, the device can still need a hardware power-cycle.
