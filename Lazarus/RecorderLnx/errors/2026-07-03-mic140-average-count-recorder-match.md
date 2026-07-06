# 2026-07-03 MIC140 average count must match Recorder

## Symptom

Original Windows Recorder showed MIC140 `count_aver` values:

- `327` for `period_decay = 57.000 us`, `period_decay2 = 19.688 us`,
  ground disabled, auto mode `AUTO_CALC_COUNT_AVER`;
- `318` for `period_decay = 100.000 us` with the same other settings.

The Codex MIC140 debug project used `Mic140EvalAverageSampleCount`, but the test
configuration forced `rdpPollFrequencyHz = 10.0`, which evaluates to `323/314`
for 51 slots.

## Confirmed Facts

- Original dialog code is `MIC140pp_rce/mic140ppext.cpp`.
- The dialog calls `module->GetFreqSFor(MIC140_AIN_CHTYPE)` and then
  `module->CheckPeriodDelay(...)`.
- MIC140-48 `GetMaxChanCount()` is `48 + 3 = 51`
  (`MIC140_96_rce/MIC140_48mod.cpp`).
- Original MIC140 count formula is in
  `MIC140_96_rce/mic140_96mod.cpp::CalcCountAver`.
- With the original formula, 51 slots, ground disabled, and
  `period_aver = 5 us`:
  - `freq = 10.0 Hz` gives `323/314`;
  - `freq ~= 9.875..9.885 Hz` gives exactly `327/318`.
- With default `GetFreqClk() = 16 MHz`, the legacy `scale_period_16000[]` rows
  for 10/20/25/50/100 Hz are exact:
  `10.000000`, `20.000000`, `25.000000`, `50.000000`, `100.000000`.
- The dialog does not compute `9.875 Hz` from `count_aver`; it first obtains
  `freq` via `ModuleMC114::GetFreqSFor(MIC140_AIN_CHTYPE)`, then passes it to
  `CheckPeriodDelay`.
- The frequency source is the first used AIn channel `GetFreq()` value
  (`CChannel::m_Fs`). When the user selects a frequency through `TagPP`, the
  value goes through `CChannelModule::SetFreq`, which stores
  `IndexToFreq(FreqToIndex(freq))`.
- `ModuleMC114::IndexToFreq` computes
  `2 * GetFreqClk() / (scale * period * count)`. Therefore the 10 Hz row
  (`scale=1`, `period=640`, `count=5000`) becomes exactly `9.875 Hz` if
  `GetFreqClk() = 15.8 MHz`.
- `ModuleMIC140_96` defaults to `SetFreqClk(16_000_000)`, but `Module::Load`
  reads `freq_clk` from the saved project frame. No automatic EEPROM/hardware
  read of MIC140 `freq_clk` was found in the checked dialog/module path.
- Checked the possible controller-read path:
  - `CCMC031EthernetInterface::Open` calls `ReadCfg()`, which sends `CMD_REPLY`
    and fills `TBiosInfoMC031` with device/controller type, revision, serial,
    EEPROM IDs, BIOS function/version. There is no quartz/frequency field.
  - `CCMC031EthernetInterface::GetFirmware` also sends `CMD_REPLY`, but returns
    only revision/type/function/version.
  - `CCMC031EthernetInterface::MeasureFreqCCFromFreqModule` and the similar
    `CCMC021USBWDInterface::MeasureFreqCCFromFreqModule` are stubs that return
    `ERROR_NOERROR` without modifying `*freq`.
  - The only found automatic correction path is `ScanClock::Decommutation`,
    which calls `cc->SetFreqClk(koef)` for the controller clock. MIC140 modules
    are initialized with `SetSelfClk(SELF_CLK)`, so `Module::GetFreqClk()` uses
    the module's own `freq_clk`, not the controller clock.
- If an external/project list applies the same `0.9875 * nominal` offset, the
  corresponding full frequencies are `19.750000`, `24.687500`, `49.375000`,
  `98.750000` Hz for nominal 20/25/50/100 Hz.
- Recorder writes the hardware/settings file as binary `CCfgStream` frames in
  `*.rcfg`: `CRcCore::SaveConfig` / `ExportSettings` open `CCfgStream`, write
  a top frame with `CurrentVersion` and `HostDevicesCount`, then call
  `SaveDevice` for each host device.
- `SaveDevice` writes a small frame with `type_class`, then calls the object's
  virtual `Save`.
- `CCDevice::Save` writes `module_count` and `module[i]`, closes the controller
  frame, writes each module object through `SaveDevice`, then reopens the next
  frame.
- `Module::Save` writes `bios_path`, `serial_no`, `self_clk`, and double
  `freq_clk`; `Module::Load` reads the same fields.
- A second, more direct source for the channel frequency exists in the same
  config stream: `CMeasurementTag::Save` writes double `Freq`, and
  `CMeasurementTag(CCfgStream&)` reads `Freq` and immediately calls
  `m_pDevChan->SetFreq(dblFrequency)`. Therefore the MIC140 dialog's
  `GetFreqSFor` can see `9.875 Hz` because a tag restored `Freq=9.875`, even if
  the current run does not recompute that value from `freq_clk`.

## Action

Changed only the Codex debug stand test frequency in
`Tests/Mic140ProtocolDebug_Codex/uMic140DebugForm.pas` from `10.0` to `9.875`.
The timing formula itself was left intact because it already matches the
original `CalcCountAver` path.

Documented the exact-vs-actual frequency nuance in:

- `Docs/devices/mic140/protocol/08_timing_and_count_aver.md`;
- `Docs/devices/mic140/protocol/03_scan_programming.md`;
- `Docs/devices/mic140/protocol/06_ui_parameters.md`.

## Verification

`C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0. Compiler emitted only existing hints/notes.

## Continuation 2026-07-06

New observed Recorder pair: `period_decay = 57 us -> count_aver = 327`,
`period_decay = 200 us -> count_aver = 298`. The same result appears with an
offline Recorder device, so it is not evidence of a fresh network/quartz read
from the MIC-140 controller.

Root cause in the Codex project: after adding timer/quartz diagnostics,
`Mic140EvalAverageSampleCount` used `Mc114.ActualFrequencyHz` when available.
With nominal `ModuleClockHz = 16 MHz` and divider 5000 this converts the
channel setting `9.875 Hz` back to timer frequency `10.000 Hz`, so the dialog
math regressed to the 10 Hz result (`323` at 57 us).

Fix: keep `ApplyTimerForFreq` for BIOS timer fields, but compute the dialog
frame period as `1 / AProg.Timing.FrequencyHz`, matching original
`GetFreqSFor -> CheckPeriodDelay`. The debug form now displays both
`Fs(ch)` and `Fs(timer)` so the two meanings are visible.

Verification:

- `C:\lazarus\lazbuild.exe -B
  D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebug_Codex.lpi`
  completed with exit code 0.
- `mic140_clock_test.lpr` compiled with FPC.
- `mic140_clock_test.exe` printed `327` for `Fs(ch)=9.875 Hz`,
  `period_decay=57 us`, and `298` for `Fs(ch)=9.875 Hz`,
  `period_decay=200 us`. The test also showed `TimerFs=10.000000 Hz`, which is
  expected and no longer used as the dialog count source.

### Follow-up: default object still showed 323

User reported that the project still showed `323`. Confirmed remaining path:
`TRecorderMic140Device.Create` still called `Mic140InitScanProgram48(..., 10)`
and did not initialize `fPollFrequencyHz`. Therefore an offline/default device
or a debugger stop before `ConfigureTestDevice` applied `rdpPollFrequencyHz`
still evaluated strict 10 Hz.

Fix: added `MIC140_48_RECORDER_DEFAULT_FREQ_HZ = 9.875`, initialized the base
poll frequency in the constructor with `inherited SetFs(...)`, initialized the
scan program with the same value, and changed the zero-frequency fallback in
`ReadMIC140State` to the same constant.

Verification: rebuilt `Mic140ProtocolDebug_Codex.lpi` successfully and rebuilt
`mic140_clock_test.lpr`. Running `mic140_clock_test.exe` now prints
`Default object: Fs(ch)=9.875000 Hz  count_aver=327`, plus the explicit
`9.875 / 200 us -> 298` diagnostic row.
