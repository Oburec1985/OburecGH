# OPC UA editor crash and Preview lag check — 2026-10-28

## Symptoms

- Opening the OPC UA datasource settings crashes in `UpdateControlState` at the
  assignment to `fDiscoveryButton.Enabled`.
- The user also observes lag when switching to Preview and asks whether host
  load or RecorderLnx is responsible.

## OPC UA editor crash

### Confirmed cause

The editor is loaded from `uRecorderOpcUaSourceEditor.lfm` by
`inherited Create(AOwner)`. The form class declares `fDiscoveryButton`, and
`CreateEditor` calls `UpdateControlState`, but the LFM had no such control.
The old dynamic UI builder that created the button followed an `Exit` in
`CreateEditor`, so it was unreachable. The field was nil when
`UpdateControlState` accessed it.

### Fix and verification

- Added `fDiscoveryButton` to the LFM, with `DiscoveryClick`, right anchoring,
  and a correspondingly shorter Endpoint edit.
- Removed the unreachable legacy UI builder after the early `Exit`; the live
  LFM initialization remains the only UI construction path.
- Forced Win64 build completed successfully: 236,582 lines compiled, exit 0.

## Preview lag

### Checks and evidence

- `TRecorderApplicationController.EnterActiveState` synchronously resets
  display sessions, starts the time system, and calls `StartAcquisition`.
- `TMainForm.StartDataSources` calls `TRecorderDataSourceManager.StartAll`.
  Current `StartAll` checks prepared state and starts worker threads; each
  source's `Start` and `Tick` execute on its worker thread, so OPC Browse/read
  is not awaited by the UI during the Preview transition.
- `LogWindows.previous.log` records `Data sources started in 0 ms` at
  09:36:19.634 and `Stop -> Preview` at 09:36:19.640. A second transition
  took 0 ms to start sources and 4 ms to publish the state change. In those
  captures the synchronous reset and start path was not slow.
- The same logs show full rebuilds of `Mnemonic6` (10 components) at 219–234 ms
  on the UI thread. Those redraws can be perceptible but are not the measured
  `Stop -> Preview` path.
- Startup hardware preparation performs network warmup on `UIThread` and took
  1,750–1,766 ms in two captures. This is outside `StartPreview`, but can
  contribute to apparent startup/configuration delays.
- A SQL DB timeout was logged on a worker thread, not the UI thread.
- A current system CPU sample was 14%, but it was taken after the reported
  incident and cannot establish past host load.

### Conclusion and remaining evidence

The available logs do not support the hypothesis that OPC UA acquisition or
system load makes the Preview state transition itself slow. The lag was not
reproduced in a controlled run, so its exact cause remains unconfirmed. If the
visible pause occurs after `Stop -> Preview`, capture window-message latency
while reproducing and correlate it with `[MNEMO-PERF]` and device worker logs.

## Commands

- `lazbuild -B RecorderLnx.lpi` — passed on 2026-10-28.
- `Select-String LogWindows*.log -SimpleMatch -Pattern 'Data sources started','State changed:','[MNEMO-PERF] render','[HardwarePrepare] network warmup'` — used to correlate UI and worker timings.
