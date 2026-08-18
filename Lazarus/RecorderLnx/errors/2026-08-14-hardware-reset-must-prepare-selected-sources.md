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

## 2026-08-18 Follow-up - reset differs from program restart

### Symptom

User reported that several MIC-185 devices stayed red after "reset devices",
although TCP-ping was OK. After restarting RecorderLnx, the same devices became
green without power-cycling hardware.

### Confirmed Facts

- Fresh `C:\Mera Files\RecorderLnx\LogWindows.log` after restart shows MIC-185
  `192.168.9.156`, `.158`, `.159` passing `connect` and `initialize` in about
  one second each.
- The previous failure pattern was not a physical device hang: restart of the
  program was enough to recover.
- Cold startup applies MIC-185 per-endpoint stagger before protocol
  initialization. Manual reset used `0 ms` start delay for all endpoints.
- Reset already performed release/cleanup and then `PrepareHardwareSources`,
  but did not retry endpoints that remained offline after the first prepare.

### Hypotheses Checked

- **Hardware needs power-cycle:** rejected for this case, because application
  restart restored all three MIC-185 devices.
- **TCP-ping proves device is healthy:** rejected. TCP-ping only proves the
  port accepts a connection; Mebius `GetSoftVersion/read SN` can still timeout.
- **Reset should mimic cold-start lifecycle more closely:** accepted. Manual
  reset must release/cleanup, then prepare with MIC-185 stagger, and retry only
  endpoints that still failed protocol initialization.

### Done

- MIC-185 reset tasks now use the same host-octet based start staggering as
  MIC-185 startup (`last_octet mod 10 * 150 ms`).
- After the first reset/prepare, sources that are still offline are collected
  from the hardware offline registry, not by parsing error strings.
- For those failed sources only, reset now runs one additional
  release/cleanup/prepare pass with an extra `500 ms` delay.
- Final warning reports only sources still offline after the retry; recovered
  first-pass failures are not shown as failed.

### Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  compiled the changed Pascal units and reached link.
- Link failed with `error code: 5` because a running `RecorderLnx.exe` held
  `lib\x86_64-win64\RecorderLnx.exe`. The application was not stopped
  automatically to avoid interrupting the user's live session.

### Next Manual Check

After closing/restarting RecorderLnx from the new build, press "reset devices"
on a batch containing MIC-185. Expected log sequence for transient failures:

- `reset-prepare FAIL failed=N`
- `reset-retry BEGIN`
- `reset-retry-prepare OK` and green tree state, or a final warning with the
  real protocol error if the device still cannot initialize.
