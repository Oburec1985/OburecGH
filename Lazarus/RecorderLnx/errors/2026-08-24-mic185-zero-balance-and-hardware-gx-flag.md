# 2026-08-24 - MIC185 zero balance and hardware GX flag

## Symptom

- MIC183/185 balance button in RecorderLnx did not implement the original
  device balance behavior.
- If a tag had `HardwareCalibrationEnabled = false`, opening MIC185 hardware
  settings, enabling hardware balance and pressing OK unexpectedly enabled the
  tag's hardware calibration checkbox.

## Confirmed Facts

- Original Recorder MIC185 code uses `CMIC185V2::ZBalanceMultiEx`.
- `ZBalanceMultiEx` filters out UTS/AUX channels and sends selected
  measurement channel numbers to `CMD_ZBALANCE`.
- `CMD_ZBALANCE` is `CTL_CODE(TYPEIO_MEAS_TASK, 0x0006, 0, 1)`.
- The command returns one signed 16-bit soft-balance value per requested
  channel.
- Original Recorder writes the returned value to channel property
  `MEPROPCH_BALANCE_SOFT`.
- MIC185 module hardware balance is a separate setting:
  `MEPROP_BALANCE_DAC` stores DAC/common balance value and
  `MEPROP_BALANCE_ON` stores hardware-balance enable flag.
- Original Recorder hardware balance dialog edits module properties, so the
  hardware DAC balance is common for the whole 64-channel MIC185 module.
- Original Recorder software balance is channel-specific: the balance button
  stores the returned value in `MEPROPCH_BALANCE_SOFT` for each selected
  channel.
- RecorderLnx already had `SoftBalance`, `HardBalance`, and
  `HardwareBalanceOn` fields in MIC185 programming structures.
- `HardwareCalibrationEnabled` is an explicit tag-level user flag. It controls
  whether runtime applies hardware GX/KX to the tag value. It must not be
  flipped by merely changing hardware balance settings.
- Original Recorder keeps `MEPROPCH_BALANCE_SOFT` as a raw ADC-code offset.
  The physical UI value is derived through the channel `Eval`/`EvalInverse`
  path, but the stored command result itself is not a second runtime
  calibration stage.
- RecorderLnx zero-balance previously reused existing `SoftBalance` values
  while asking the device to calculate a new one. That made repeated balancing
  work from a non-clean input and could accumulate offsets.
- `CMD_ZBALANCE` returns a new per-channel soft-balance code, but RecorderLnx
  had already programmed the live device with the clean temporary
  `soft=0` setup before calling that command. The returned value was saved to
  source settings, but the live device was not programmed again with this new
  value before returning to acquisition.

## Checked Hypotheses

- Hypothesis: balance button should only change module hardware-balance fields.
  Rejected. Original button path writes per-channel `MEPROPCH_BALANCE_SOFT`.
- Hypothesis: selecting physical units or opening hardware settings may safely
  enable tag hardware GX. Rejected. Previous MIC185 GX regressions showed that
  this silently changes raw-code/physical-unit behavior and surprises the user.
- Hypothesis: hardware balance and hardware GX are the same switch. Rejected.
  Original Recorder stores them in different properties.
- Hypothesis: after storing `SoftBalance`, runtime should also subtract it in
  `Mic185ApplyValueTransform`. Rejected and reverted. User-side measurements
  showed the balance was already taking effect; adding this subtraction risks
  double correction. The software balance must be written/programmed as part of
  the MIC185 channel settings, not applied as an extra independent transform.

## Done

- After the user still observed about 30 ADC codes after balance, checked
  `LogWindows.log`. The latest zero-balance sequence did clear old balance,
  receive `returned soft=4898 code`, and program it back, but the new
  fractional correction did not run:
  `fine residual skipped: MIC183/185 fine zero-balance read did not return samples`.
  This confirms the immediate issue was not correction sign, but that the
  post-balance residual sampler tried to read too soon after `Start`.
- Updated `MeasureFineSoftBalance` to wait for fresh acquisition data after
  `TryStart`: it now sleeps a short settle interval, polls until a total wait
  deadline, does not abort on an empty/non-ready read, and logs the number of
  read attempts as `tries=...`. This keeps the correction local to the
  zero-balance action and does not change the normal runtime acquisition loop.
- Added `CMic185IoCtlCmdZeroBalance`.
- Added `TRecorderMic185Device.TryZeroBalanceChannels`: packs selected channel
  indices, calls the MIC185 zero-balance command, stores returned soft-balance
  values into runtime channel program settings.
- Added `RecorderMic185ZeroBalanceChannels`: creates/programs a MIC185 device
  from current source settings, executes zero balance, and persists returned
  soft balances back into source channel settings.
- MIC185 source now implements common zero-balance support so shared balance UI
  can use the same mechanism.
- MIC185 device settings dialog `Балансировать` now balances selected
  measurement rows and reloads the grid.
- MIC185 unit/hardware-mode helper no longer forces
  `HardwareCalibrationEnabled := True` for physical units. Raw `код/code`
  still explicitly disables hardware GX.
- Fixed explicit hardware settings Apply/OK while RecorderLnx already owns the
  MIC185 TCP session. `RecorderMic185ProgramConfiguredSource` no longer returns
  fake success with `DEFERRED` for an active live device; it applies current
  source channel/module settings to the live device and calls `TryProgramDevice`.
- Zero-balance now also reuses the live MIC185 device when present, instead of
  opening a second TCP client against the same endpoint.
- Added an in-session applied-programming signature cache. After successful
  hardware Apply/OK, the current source programming signature is marked as
  already applied. Main settings exit and tag settings exit skip duplicate
  `RecorderReplaceRuntimeSource`/`PrepareRuntimeForConfiguration` for that same
  signature.
- Fixed MIC185 channel properties dialog persistence for balance values:
  the dialog now receives source module settings, shows the common hardware
  DAC balance as mV, saves it back to `TMic185ModuleProgramSettings.HardBalance`,
  and writes module settings to the configured source.
- Fixed MIC185 soft-balance UI units. Original Recorder edits
  `MEPROPCH_MIC185V2_BALANCE_SOFT_PHYS`, while the protocol packet stores
  `SoftBalance_` as ADC codes. RecorderLnx now converts soft balance
  `mV <-> ADC code` using the selected input range instead of rounding the UI
  text as a raw code.
- Fixed MIC185 additional settings dialog so it no longer resets
  `HardBalance` to the default DAC zero (`8192`) when saving unrelated module
  options.
- MIC185 hardware settings grid now displays hardware and software balance in
  UI mV values instead of always showing `0.000` hardware balance and raw
  soft-balance codes.
- Fixed a crash after successful hardware settings Apply/OK in
  `RecorderMarkSourceProgrammingApplied`. The applied-signature cache now:
  guards against `nil` registry, computes the source signature before touching
  the global cache, stores signatures in the same one-line format used by
  comparisons, and protects the global `TStringList` with a critical section.
- Reverted the MIC185 runtime soft-balance subtraction from
  `Mic185ApplyValueTransform` and the effective `k/b` display path, because it
  was a likely double-subtraction regression.
- MIC185 zero-balance now clears old `SoftBalance` for selected channels in the
  temporary programming settings, programs that clean configuration into the
  device, executes `CMD_ZBALANCE`, then stores the returned raw balance code as
  the new per-channel `SoftBalance`.
- MIC185 zero-balance logs both the returned raw code and the approximate UI mV
  value for each balanced channel. This gives a direct check whether a residual
  offset comes from the device command result, stale pre-balance samples, or a
  later display path.
- After `CMD_ZBALANCE` returns, RecorderLnx now applies the updated channel
  settings back to the MIC185 device and sends `ProgramDeviceBin` again. This
  pins the same returned `SoftBalance` into the device configuration before
  preview/acquisition resumes.
- If zero-balance is run against a live started device, RecorderLnx stops it for
  the clean reprogram/balance sequence and attempts to restart it even if
  programming or balancing fails.
- Added fractional zero-balance correction `SoftBalanceFine`. The integer
  `SoftBalance` still goes to the MIC185 binary programming packet; the
  fractional residual is stored only in the RecorderLnx channel mode string as
  `softFine=...` and is applied mathematically in ADC-code space before
  hardware GX/unit/channel transformations.
- After programming the returned integer `SoftBalance`, zero-balance briefly
  starts acquisition, reads a few fresh blocks, averages selected raw channel
  codes, and saves that mean as `SoftBalanceFine`. This is intended to remove
  the remaining quantization/residual offset without pretending the device
  supports fractional DAC/soft-balance command values.
- Fixed the first `SoftBalanceFine` implementation: after saving the fine
  residual, the active MIC185 data source now refreshes its
  `fRuntimeChannelSettings` / `fValueTransforms` cache immediately. Without
  this, the source could continue displaying values through the old transform
  until a later runtime rebuild.
- Fine residual measurement now discards the first freshly read block after
  Start, then logs how many blocks and samples were averaged. This avoids using
  a transitional/stale block as the post-balance mathematical expectation.

## Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed successfully with exit code `0`.
- After the live-programming fix, `lazbuild -B` compiled Pascal units without
  source errors and failed only at final link because
  `lib\x86_64-win64\RecorderLnx.exe` was already locked by a running process
  (`error code: 5`). The running process was not stopped intentionally.
- After the applied-signature cache fix, `C:\lazarus\lazbuild.exe -B
  D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed successfully
  with exit code `0`.
- After the balance persistence/unit fix, `lazbuild -B` compiled Pascal source
  successfully and stopped only at final link because
  `lib\x86_64-win64\RecorderLnx.exe` was locked by a running RecorderLnx
  process (`error code: 5`). The process was intentionally not stopped.
- After the applied-signature cache crash fix,
  `C:\lazarus\lazbuild.exe -B
  D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed successfully
  with exit code `0`.
- After reverting the runtime soft-balance transform and adding clean
  zero-balance setup, `C:\lazarus\lazbuild.exe -B
  D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed
  successfully with exit code `0`.
- After adding post-balance reprogramming with returned `SoftBalance`, build
  verification completed once with exit code `0`.
- After adding `SoftBalanceFine`, `lazbuild -B` compiled Pascal sources and
  stopped only at final link because
  `lib\x86_64-win64\RecorderLnx.exe` was locked by a running RecorderLnx
  process (`error code: 5`). The process was intentionally not stopped.
- After refreshing the runtime transform cache and discarding the first
  fine-measurement block,
  `C:\lazarus\lazbuild.exe -B
  D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed
  successfully with exit code `0`.

## Manual Acceptance

- In MIC185 hardware settings select measurement rows and press
  `Балансировать`: soft-balance values should update in the grid/source
  settings without changing unrelated channels.
- With a tag's hardware GX checkbox unchecked, open hardware settings, enable
  hardware balance and press OK: the tag hardware GX checkbox must remain
  unchecked.
- With RecorderLnx holding an initialized MIC185 session, change a hardware
  balance/range option in MIC185 hardware settings and press OK: the live device
  must be reprogrammed immediately, so the next Preview uses the new balance
  without entering tag settings or pressing tag balance.
- In MIC185 channel hardware properties set `Балансировка программная` in mV
  and/or `Балансировка аппаратная общая` in mV, press Apply/OK, reopen the
  dialog: both values should be preserved and should program the device.
- After balancing a selected MIC185 channel, the log must contain
  `ZeroBalance ... clean setup`, `returned soft=... code`, and
  `applied returned soft balances to device`. When post-balance samples are
  readable, the log must also contain `fine residual=... code`. Values displayed
  in `код` should have mean close to zero after fresh post-balance samples
  arrive. If the mean still sits near `20` codes, compare that residual with the
  logged `fine residual` and check whether the displayed points are stale
  pre-balance samples.
- Leaving the outer settings dialog after a successful hardware Apply/OK should
  log `Source programming already applied` and must not program the same MIC185
  source a second time unless the hardware signature changed again.
- Applying MIC185 hardware settings must not stop in
  `RecorderMarkSourceProgrammingApplied` after the device has been programmed.
