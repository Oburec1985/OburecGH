# 2026-08-14 - hardware reset must verify selected sources

## Symptom

User reported that "reset device" now returns very quickly: the hardware tree
turns green, but entering Preview immediately shows the device as failed again.
Question from the user: does reset do anything at all?

## Confirmed Facts

- `LogWindows.log` showed a reset batch for `MIC-140: 192.168.14.41:4000`
  finishing in effectively `0 ms`.
- The next Apply path logged `Hardware configuration unchanged: initialized
  devices retained`.
- `RecorderHardwareRequestSourceReset(...)` only records a pending reset and
  disconnects any live session. The pending reset is consumed only by
  `PrepareHardware`.
- Preview intentionally does not run `PrepareHardware`, per the runtime rule
  already discussed: programming/configuring hardware belongs to Apply/reset
  lifecycle, not Preview.
- Therefore the previous quick-reset behavior could clear the old offline icon
  without proving that the endpoint was connected/initialized/configured again.

## Hypotheses Checked

- **Network route/firewall:** not the direct cause for this symptom. The code
  path itself proved reset was only a request/release stage and did not run
  prepare.
- **Device hang requiring reboot:** not proven by the reset action itself. If
  the follow-up prepare fails with an IoControl timeout, then a power-cycle may
  still be needed; a zero-millisecond reset is not such proof.
- **Preview should consume reset request:** rejected. Preview must not program
  hardware.

## Done

- Added `TRecorderDataSourceManager.PrepareHardwareSources(ASourceIds)`.
  It prepares only explicitly selected sources, in parallel, and only when
  their context says prepare is needed.
- Changed `HardwareResetSourceClick` so successful reset tasks no longer call
  `RecorderHardwareClearSourceOffline` by themselves.
- After reset release/cleanup, the dialog now runs `PrepareHardwareSources` for
  the successfully reset SourceId list and logs a `reset-prepare` phase.
- Green state now comes only from a successful normal prepare path; failed
  reset/prepare leaves a real offline/error reason.

## Verification

- Built with:
  `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
- Build/link exit code: `0`.
- Existing Windows post-build script still prints the known non-blocking
  `#!/bin/sh` message.

## Next Manual Check

Click reset for one MIC-140/MIC-185 source and inspect `LogWindows.log`.
Expected sequence:

- `reset-batch BEGIN`
- per-source `reset BEGIN/OK`
- `reset-prepare BEGIN`
- either `reset-prepare OK` and green tree state, or `reset-prepare FAIL` with
  the same reason Preview would otherwise hit later.
