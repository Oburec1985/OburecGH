# Device connection warning survives reconnect — 2026-10-28

## Symptom

The UI can continue showing `Device connection test failed` / `Preview ! 1`
after a datasource has reconnected and is again publishing tag values.

## Findings

- `RecorderHardwareRefreshLiveSourceWarnings` stores failed session checks in a
  separate warning registry.
- `RecorderHardwareRegisterLiveDevice` is called only after the datasource
  starts successfully, but previously it cleared only the offline registry.
- A later successful OPC UA session could therefore stream values while the
  previous warning remained and continued contributing to the UI warning count.
- Current workspace logs do not contain a runtime trace from the screenshot
  session; the UI state flow above is the confirmed stale-warning path.

## Fix

Registering a live device session now clears both its offline marker and its
old connectivity warning. The live session is stronger evidence of recovery
than the earlier failed probe.

## Verification and remaining risk

- Forced Win64 RecorderLnx build to
  `lib/x86_64-win64/RecorderLnx-device-warning-reconnect.exe`: exit code 0.
- Live UI reproduction was not available in this turn. Confirm that the warning
  clears after the datasource starts again and values resume.
