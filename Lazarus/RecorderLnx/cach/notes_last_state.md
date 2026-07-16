# MIC-140 debug stand — последнее состояние (2026-07-06)

## Codex continuation 2026-07-13: MIC185 additional average count

**Prompt:** MIC185 additional settings dialog shows an empty averaging count;
at 100 Hz it should be 128 points. Check average calculation and dialog logic
against original Recorder.

**Findings:** Original MIC185V2 stores `AveragePointCount` as an exponent:
`7` means `2^7 = 128` ADC samples. RecorderLnx put protocol value `7` directly
into a `csDropDownList` with point-count items, so the field became blank. The
additional dialog also did not persist/program module-wide fields.

**Fix:** Added module-wide MIC185 settings, conversion helpers, and the original
`CalcMaxRate` formula. The dialog now displays point count `128`, stores/programs
the exponent `7`, saves module settings in `dataSources[].mic185`, and applies
them through `ProgramDeviceBin`.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0; existing post-build `copy_sdb_res.bat` still prints `#! is not recognized`.
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
passed.

## Codex continuation 2026-07-13: preview offline sources and form editor lag

**Prompt:** User reported slow first transition into preview, repeated attempts
to connect disconnected devices, lag while dragging a display-form container,
and Ctrl+Z restoring deleted elements with empty settings.

**Findings:** Preview startup prepares hardware sources sequentially before
threads are started. Active-source refresh and hardware tree checks could also
perform synchronous TCP probes. MIC-185 connect waited up to 3 x 5000 ms. The
form editor rebuilt live controls and fired `NotifyChanged` on every mouse
move. Undo/copy stored only a partial set of component properties.

**Fix:** Added a shared offline-source registry in
`uRecorderHardwareLiveDevices`. Failed MIC-140/MIC-185 prepare/start marks the
source offline; `UpdateActiveSourceIds`, hardware-tree link checks, and runtime
data-source creation skip offline sourceIds until a manual reset. Added
hardware-tree context menu commands to reset one device or all devices. Reduced
hardware-tree probe timeout to 250 ms and MIC-185 connect to 1 x 1200 ms. The
form editor now throttles live rendering during drag/resize and sends
`NotifyChanged` once at operation end. Undo/copy snapshots now clone component
settings for StaticText, TagValue, Oscillogram, Trend, and Spectrum.

**Docs:** Added `Docs/devices/hardware_source_lifecycle.md` and error journal
`errors/2026-07-13-preview-offline-and-form-editor-lag.md`.

**Verification:** Initial rebuild reached linking but failed because running
`RecorderLnx.exe` PID 2004 locked the output file. After stopping that process,
`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0. `RecorderDataSourcesTest.exe` passed.

## Codex continuation 2026-07-08: tag settings additional-tab layout

**Prompt:** в настройках тега в диалоге наползание элементов окна друг на друга.

**Fix:** In `UI/uTagSettingsDialog.lfm`, increased and shifted the compact
`Дополнительно` tab groups for `Длина порции` and `Усреднение`, moved their
edit/check controls lower inside the group boxes, and moved `Свойства канала`
down to keep spacing between groups.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0. Existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh` message,
but it does not fail the build.

## Codex continuation 2026-07-06: MIC140 debug connection fix

**Prompt:** debug MIC-140 connection crash in Mic140ProtocolDebug_Codex stand.

**Fix:**
- Resolved Winsock race condition in `uMic140Registration.pas`: WSAStartup/WSACleanup moved to global initialization/finalization.
- Optimized discovery: `FindMIC140_48` now checks `CDefaultHost` (192.168.14.155) first, bypassing the heavy parallel 255-thread subnet probe when the default stand is available.
- Rebuilt and verified GUI/CLI: connection works stably, CLI runner reads data blocks.

## Codex continuation 2026-07-06: MIC140 10 Hz stream acceptance work

**Prompt:** finish the MIC-140 test so the live data stream at 10 Hz passes the
documented acceptance rules: no stream failures, data matches Recorder, and the
block count matches update time/duration.

**Done so far:**
- Added/rebuilt the headless CLI project
  `Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebugCli_Codex.lpi`.
- Fixed acquisition timing: the duration timer now starts after successful
  connect/program/start preparation, so a 3 s 10 Hz run reads about 15 blocks
  instead of undercounting connection/programming time.
- Split scan descriptor layouts:
  default acceptance `fifo=48` reserves descriptor 0 for ground
  (`reserveGroundDesc=True`, first AIn pointer `descAddr+5`);
  `--recorder-wire` keeps the dense Recorder MDP layout (first AIn at
  `descAddr`, `stride=51`, `msgWords=163`).
- Documented this distinction in
  `Docs/devices/mic140/protocol/03_scan_programming.md`,
  `05_data_stream.md`, and `07_acceptance.md`.

**Verification:** `C:\lazarus\lazbuild.exe -B
Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebugCli_Codex.lpi` completed with
exit code 0. Before the TCP port went offline, the stable `fifo=48` stream read
65 blocks in 13.13 s with `readGaps=0`, `corruptRead=0`, `softRestart=0`
(5 blocks/s as expected) but strict publication still failed on code-reference
checks. A later `--recorder-wire` diagnostic showed restarts/timeouts and then
the device stopped accepting TCP on `192.168.14.155:4000`; direct
`Test-NetConnection` also failed. Live PASS is therefore still open until the
MIC-140 port is reachable again.

## Codex continuation 2026-07-02: MIC140 IRecorderDevice stub

**Prompt:** in `Tests\Mic140ProtocolDebug_Codex\device\MIC140`, create a MIC-140
module with `IRecorderDevice` support; for now it should be a class skeleton
with empty programming methods.

**Follow-up:** user intentionally keeps `m_MIC140` on the form as an explicit
MIC-140 debug handle, but wants it obtained through the standard device
interface. Added `IRecorderDevice.GetNativeObject: TObject`; the MIC-140 object
returns `Self`. `FindAndConnect` searches through
`RecorderDeviceManager.Search('MIC140')`, checks that `GetNativeObject` is
`TRecorderMic140Device`, stores the object in `m_MIC140`, then explicitly calls
`m_MIC140.AddRef`. The form destructor calls `m_MIC140.Release`. Removed both
the extra MIC-specific interface and the extra retaining interface field on the
form.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; only existing hints/notes.

## Codex continuation 2026-07-06: disabled MIC device tree and MIC185 info read

**Prompt:** show disabled MIC140/MIC185 devices in the hardware tree with the
disabled-device icon from `ilCommandButtons` index 41, hide tags of disabled
devices from the main tag list, and read MIC183/185 serial/version in the
settings dialog when the device is reachable by IP.

**Done:** Added hardware source visibility helpers in `uRecorderTags.pas`,
including MIC185 source-prefix recognition and filtering of `Detached:` tags.
The main tag list and data-source creation now skip invisible/detached hardware
tags. The hardware tree uses image index 41 for MIC140/MIC185 source nodes that
have no linked tags, and restores disabled source nodes from detached tag source
ids. Deleting/disabling MIC140/MIC185 detaches tags but leaves the source node in
the current tree as disabled.

**MIC185:** Added `RecorderMic185ReadDeviceInfo`, a short Mebius TCP query that
calls `CMic185IoCtlCmdGetSoftVersion`, parses `TMic185HardDeviceInfo`, and
formats the firmware version through `Mic185FormatSoftVersion`. The MIC183/185
settings dialog invokes it on first source load to fill serial number and
version when the IP/port respond.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0 and linked `lib\x86_64-win64\RecorderLnx.exe`. Existing post-build
`copy_sdb_res.bat` still prints a `#!/bin/sh` message, but did not fail
`lazbuild`.

## Codex continuation 2026-07-06: MIC140 count_aver uses Fs=10 and effective ISR

**Prompt:** User clarified that original Recorder channels see `10 Hz`, not
`9.875 Hz`; therefore matching `count_aver=327` must be done through the
effective processing-time factor, not by changing channel Fs.

**Fix:** Restored MIC140 default/channel frequency to `10.0 Hz` in
`TRecorderMic140Device` and `uMic140DebugForm`. `IsrFactor` now uses effective
`103` timer-work ticks for the count-average budget (`K_eff = 1 + 103/640`),
which matches Recorder for MIC140-48, 51 slots, ground off:
`period_decay=57 us -> 327`, `period_decay=200 us -> 298`.

**Docs:** Updated MIC140 protocol docs to remove the old “9.875 for 327”
explanation from the main calculation path and document the effective ISR
factor instead.

**Verification:** `mic140_clock_test.exe` rebuilt and printed
`Default object: Fs(ch)=10.000000 Hz count_aver=327` plus
`10.000 Hz / period_decay=200 us -> 298`. `lazbuild -B
Mic140ProtocolDebug_Codex.lpi` compiles all units but cannot relink while
Lazarus keeps `Mic140ProtocolDebug_Codex.exe` open in a debug session
(`Can't create executable`, error code 5).

**Additional check:** User provided Recorder screenshot for `100 Hz`,
`period_decay=57 us`, `period_decay2=19.688 us`, GND off. Current diagnostic
prints `100.0 Hz / 51 slots / GND off -> count_aver=23`, matching Recorder.
This control point was added to
`Docs/devices/mic140/protocol/08_timing_and_count_aver.md`.

## Codex continuation 2026-07-06: Mic140ProtocolDebug_Codex build fix

**Prompt:** User reported that
`Tests/Mic140ProtocolDebug_Codex\Mic140ProtocolDebug_Codex.lpi` no longer
builds.

**Cause:** `uMic140Device.pas` had a broken identifier split across two lines in
`CheckCountAver`: `MIC140` + `_48_MIN_COUNT_AVER`, producing compiler errors
`Identifier not found "MIC140"` and `";" expected`.

**Fix:** Restored the single identifier `MIC140_48_MIN_COUNT_AVER`.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; only existing warnings/hints/notes remain.

## Codex continuation 2026-07-06: MIC140 count_aver 327/298

**Prompt:** User rechecked Recorder: `period_decay=57 us` gives `count_aver=327`,
`period_decay=200 us` gives `count_aver=298`. Offline Recorder gives the same
values, so the dialog path should be treated as saved/default math, not live
quartz detection from MIC-140.

**Confirmed:** In original Recorder `mic140ppext.cpp` passes
`module->GetFreqSFor(MIC140_AIN_CHTYPE)` into `CheckPeriodDelay`. That value is
the already stored first AIn channel frequency; the additional dialog does not
recalculate count averaging from the programmed scan timer frequency and does
not issue a MIC-140 network query for quartz frequency.

**Done:** `Mic140EvalAverageSampleCount` now uses `Timing.FrequencyHz`
(`GetFreqSFor` equivalent) as the frame period source, while `ApplyTimerForFreq`
still fills timer programming fields. The debug form now shows `Fs(ch)` and
`Fs(timer)` separately and sets the test channel frequency to `9.875 Hz`.
Protocol docs were updated for 327/298, 57/200 us, the `0.9875 * nominal`
frequency table, and the offline saved-state nuance.

**Verification:** `lazbuild -B Mic140ProtocolDebug_Codex.lpi` completed with
exit code 0. `mic140_clock_test.lpr` was compiled with FPC and
`mic140_clock_test.exe` printed `327` for `9.875 Hz / 57 us` and `298` for
`9.875 Hz / 200 us`; the live TCP part reported device offline.

**Follow-up fix:** User still saw `323` because `TRecorderMic140Device.Create`
initialized `fScanProgram` with `10 Hz` and left `fPollFrequencyHz=0`; paths
that evaluate the offline/default object before the debug form applies
`rdpPollFrequencyHz=9.875` still used strict 10 Hz. Constructor fallback and
`ReadMIC140State` zero-frequency fallback now use
`MIC140_48_RECORDER_DEFAULT_FREQ_HZ = 9.875`. Diagnostic now prints
`Default object: Fs(ch)=9.875000 Hz count_aver=327`.

**State-read update:** user asked to move the MIC140 real-frequency source into
`Tests\Mic140ProtocolDebug_Codex`. Added `TRecorderMic140Device.ReadMIC140State`
in `device\MIC140\uMic140Device.pas`. The stand state now stores
`ModuleClockHz=15.8 MHz`, derives `ActualFrequencyHz` through the original
`ModuleMC114::IndexToFreq` formula, and then assigns that value to
`fPollFrequencyHz` before `SyncScanProgramFromDeviceProperties`. Removed the
manual poll-frequency assignment from `uMic140DebugForm.ConfigureTestDevice`.
Rebuild of `Mic140ProtocolDebug_Codex.lpi` completed with exit code 0.

**Network-read update:** user clarified that `ReadMIC140State` must use a real
network request. Added a minimal MDP TCP command helper in `uMic140Device.pas`
matching `mdpEthernet81::CallCommand`: MDP header `0x12B8`, `STREAM_CMD_ID=1`,
payload `[cmd, argc, retc, args...]`, header/data checksums, PORT=1 response
parsing. `ReadMIC140State` now first sends `CMD_TEST_LOAD=7` with 32 words like
`CheckInitialized`, then sends `CMD_REPLY=113`, parses the 11-word
`TBiosInfoMC031`, and fills `fScanProgram.Firmware`. If the network command
fails, `ReadDeviceParameters` raises `ERecorderDeviceError` instead of silently
using fake state. Rebuild of `Mic140ProtocolDebug_Codex.lpi` completed with
exit code 0.

**Docs follow-up:** documented that legacy `scale_period_16000[]` gives exact
10/20/25/50/100 Hz, while `CheckPeriodDelay` uses the actual AIn channel
frequency from `GetFreqSFor`. The `0.9875 * nominal` examples are now recorded
in `Docs/devices/mic140/protocol/08_timing_and_count_aver.md`, with short
cross-notes in `03_scan_programming.md` and `06_ui_parameters.md`.

**Frequency origin follow-up:** traced the Recorder path more precisely.
`327/318` is downstream of `CheckPeriodDelay(freq, ...)`; the dialog first gets
`freq` from `ModuleMC114::GetFreqSFor(MIC140_AIN_CHTYPE)`, i.e. the first AIn
channel `CChannel::m_Fs`. `9.875 Hz` is not a dialog constant; it is exactly the
10 Hz timer row if `GetFreqClk() = 15.8 MHz`
(`2 * 15_800_000 / (1 * 640 * 5000)`). Checked code shows MIC140 defaults to
16 MHz and `Module::Load()` can restore `freq_clk` from project state; no direct
EEPROM/hardware read of MIC140 `freq_clk` was found in this dialog path.

**Controller-read follow-up:** checked the likely MIC140 controller path.
MC031 Ethernet `ReadCfg()`/`GetFirmware()` read BIOS/device identity fields via
`CMD_REPLY`, but not quartz/frequency. `MeasureFreqCCFromFreqModule()` is a stub
for MC031 Ethernet and MC021 USB. The generic `ScanClock` correction updates the
controller clock (`cc->SetFreqClk`), while MIC140 uses `SELF_CLK`, so its
`Module::GetFreqClk()` continues to use the module's own `freq_clk`.

**Config-file origin follow-up:** traced the physical file writer/reader. The
hardware configuration is stored in Recorder `*.rcfg` via `CRcCore::SaveConfig`
or `ExportSettings`, which create a binary `CCfgStream`. The stream starts with
a top frame containing `CurrentVersion` and `HostDevicesCount`, then each object
is written as a `SaveDevice` type frame (`type_class`) followed by that object's
own frame(s). `CCDevice::Save` writes `module_count`, `module[i]`, then
serializes each module; `Module::Save` writes `bios_path`, `serial_no`,
`self_clk`, and double `freq_clk`. Tags are saved later by `CRcCore::Save` /
`SaveTags`; each `CMeasurementTag` writes double `Freq`, and load immediately
applies it through `m_pDevChan->SetFreq`, so the first AIn channel frequency
used by the MIC140 dialog can come directly from saved tag `Freq`, not
necessarily be recalculated from `freq_clk` during that load.

**Commenting update:** user asked to walk through all classes in the example and
mark interface-method blocks. Added comments in `TRecorderMic140Device` for the
`IRecorderDevice` implementation blocks and object-only methods; added comments
in `TMic140DebugForm`, `TRecorderDeviceManager`, and
`TMic140DiscoveryThread` showing that their methods are object/LCL/TThread
methods rather than implemented interface methods.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; only existing hints/notes.

## Codex continuation 2026-07-02: device manager decoupling

**Prompt:** the interface form must not depend on a concrete device
implementation. Build a universal manager where devices are registered, and the
form searches through that manager. Keep comments with original Recorder method
names.

## Codex continuation 2026-07-02: connection/search split

**Prompt:** MIC-140 must not be created already bound to a known IP. Move
connection parameters into universal search logic; device parameters should be
read from the device; user/software parameters should be written in a test
configuration function in MainForm.

**Update:** `uMic140Registration.pas` now has a local discovery layer mirroring
RecorderLnx `RecorderMic140Discover`: it probes `192.168.14.*` with short
parallel TCP checks, returns the first found host through
`TRecorderDeviceSearchResult`, and only then the manager applies `rdpHost` /
`rdpPort` to `IRecorderDevice`. The known stand `192.168.14.155` is kept as a
last search candidate when the legacy TCP probe is silent; it is no longer a
constructor default. The form still uses only `IRecorderDevice` and
`RecorderDeviceManager`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0. `rg` confirms `uMic140DebugForm.pas` has no
`uMic140Device`, `CreateMic140Device`, or `TRecorderMic140Device` dependency.

**Buildability fix:** user requested project buildability. The first rebuild
failed because `uMic140Registration.pas` expected search callback types while
`uRecorderDeviceManager.pas` still had the older registration shape. Restored
`TRecorderDeviceSearchResult`, `TRecorderDeviceSearch`, the `Search` field, and
host/port application in `TRecorderDeviceManager.Search`. A second rebuild
compiled but could not overwrite `Mic140ProtocolDebug_Codex.exe` because a
running test process held it; stopped PID `22548` and rebuilt again.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; compiler emitted only hints/notes.

**Annotation update:** user asked to annotate `uMic140Registration.pas` and
describe each function's logic. Added an ASCII module header explaining the
registration/search workflow and comments for `RegisterMIC140_48`,
`Mic140TcpProbe`, `TMic140DiscoveryThread.Create`, `Execute`,
`DiscoverMIC140OnSubnet14`, `FindMIC140OnSubnet14`, and `FindMIC140_48`.
Later user asked to make comments Russian. Converted the module/function
comments in `uMic140Registration.pas` to Russian while keeping code identifiers,
Recorder method names, and behavior unchanged.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; only hints/notes.

**Done:** `TRecorderMic140Device.Create` no longer sets `192.168.14.155` or port.
The manager now supports `TRecorderDeviceSearchResult` and a registered search
function. `RecorderDeviceManager.Search` creates the device and applies found
`rdpHost/rdpPort` through `IRecorderDevice.TrySetDeviceProperty`. MIC-140
registration has `FindMIC140OnSubnet14` as the future broadcast/subnet probing
point. `TRecorderMic140Device.Connect` calls `ReadDeviceParameters`, currently a
stub for hardware-read parameters. The form has `ConfigureTestDevice`, which
writes test/user parameters only through `IRecorderDevice`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; no compiler errors or warnings.

**Done:** added `device\uRecorderDeviceManager.pas` with a small
`TRecorderDeviceManager` registry. MIC-140 registration moved to
`device\MIC140\uMic140Registration.pas`; it mirrors original names
`RegisterMIC140_48`, `RegisterDeviceClass`, and `RegisterDevice`. The project
entry includes the registration unit as bootstrap, while `uMic140DebugForm.pas`
uses only `uRecorderDeviceInterfaces` and `uRecorderDeviceManager`.
`FindAndConnect` now calls `RecorderDeviceManager.Search('MIC140')` and then
works only through `IRecorderDevice`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0. `rg` confirms the form has no dependency on
`uMic140Device`, `CreateMic140Device`, or `TRecorderMic140Device`.

**Done:** added `device\MIC140\uMic140Device.pas` with
`TRecorderMic140Device = class(TInterfacedObject, IRecorderDevice)` and factory
`CreateMic140Device`. The class exposes basic identity/properties/channels,
state transitions for `Connect/Disconnect/ProgramDevice/Start/Stop`, and a stub
`ReadBlock` that returns `False`. The form now can create/connect this stub via
`FindAndConnect`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; no compiler errors or warnings, only hints/notes.

## Codex continuation 2026-07-02: Mic140ProtocolDebug_Codex cleanup

**Prompt:** clean `Tests\Mic140ProtocolDebug_Codex` so only the visual form
project remains. Remove extra code and leave only `CheckRow(i: Integer)` in the
form module as the row-green decision point.

**Done:** the folder was reduced to four source files only:
`Mic140ProtocolDebug_Codex.lpi`, `Mic140ProtocolDebug_Codex.lpr`,
`uMic140DebugForm.pas`, and `uMic140DebugForm.lfm`. All protocol, CLI, sniffer,
driver, docs/data, stubs, logs, executable, backup, and build-output artifacts
were removed from this folder. The project is now a minimal LCL GUI with a grid;
`TMic140DebugForm.CheckRow(i: Integer): Boolean` decides whether a row is painted
green.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0 before generated `exe/lib` artifacts were removed
again to keep the folder clean.

## Codex continuation 2026-07-01: single-project GUI/CLI merge

**Prompt:** make `Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebug_Codex.lpr`
work like the original GUI stand, keep green rows for codes matching the
reference, remove separate CLI projects, embed CLI/proxy modes into the same
GUI project, and fix the 51-channel Recorder-wire mode (48 AIn + 3 TIn).

**Done:**
- folder now has one Lazarus project only: `Mic140ProtocolDebug_Codex.lpi/.lpr`;
  old `Mic140ProtocolDebugCli_Codex.*` and `Mic140Example_Codex.*` were removed;
- `Mic140ProtocolDebug_Codex.exe` now dispatches GUI, `--auto`, numeric CLI
  duration mode, and `--proxy` sniffer mode from one executable;
- GUI config parser accepts the same protocol flags as headless mode;
- defaults are Recorder-wire: `tin=3`, auto FIFO stride resolves to 51, visible
  AIn remains 48;
- stream row recovery now accepts shifted rows only when the full 51-word row is
  present, so TIn words are not silently truncated;
- GUI table still marks reference-matching rows green through
  `Mic140AdcTablePrepareCanvas`;
- capture docs and scripts now point to `Mic140ProtocolDebug_Codex.exe`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0. Headless checks
`Mic140ProtocolDebug_Codex.exe --auto 1 --no-settle` and
`Mic140ProtocolDebug_Codex.exe 1` both used the unified executable and logged
`ch=48 tin=3 fifo=-1`, then stopped at `TCP probe failed` because the device at
`192.168.14.155:4000` is currently not accepting TCP.

## Codex continuation 2026-07-01: protocol rewritten from live dump

**Prompt:** пользователь попросил на основе снятого дампа переписать протокол
как в задании и править до рабочего состояния без остановок.

**Confirmed facts from live Recorder dump `20260701_153018`:**
- stream profile: `PORT=0 size=163`, `msgWords=163`, `dataWords=153`;
- payload row: `stride=51`, `samples=3`;
- row layout: 48 AIn words, then TIn slots `48..50`;
- original Recorder programming keeps `m_ChanDump[2]=channels.Size()=48`.

**Code/doc changes in `Tests\Mic140ProtocolDebug_Codex`:**
- `--recorder-wire` / `MIC140_DEBUG_RECORDER_PROFILE=1` now mean
  `fifoStride=51`, `chanDump[2]=48`, `fifoSamples=3`;
- `VisibleChanDumpCount` no longer returns 51 for env recorder profile;
- `ADDCHANNELMODULE` argument 3 is now `Length(chanDump)`, matching original
  `Size=count_chan_bios+SIZE_START_DESC_CHAN_BIOS`; passing only `ptrCnt`
  produced stream payload with a visible offset/garbage at the row start;
- CLI/help/config comments corrected from the old wrong `chanDump=51`;
- acceptance reference loader prefers
  `Data\mic140_adc_reference_recorder_wire_live_20260701_153018.txt`;
- protocol and capture docs now explicitly describe the `chanDump=48` vs
  `stride=51` distinction.

**Verification:** all three Codex `.lpi` rebuild with exit code 0. Live CLI
before the `Length(chanDump)` fix reached the device and showed correct
programming headline (`slots=51`, `fifoStride=51`, `fifoReady=153`,
`msgWords=163`, `ptrHead=[48,323,48,...]`), but payload rows were offset and
second-bank codes saturated. After the fix, live retest was blocked by device
network state: `192.168.14.155` stopped accepting TCP `4000`; final check also
timed out ping while Recorder was open. Recorder process started by Codex was
closed. Next step after hardware reset/link recovery: rerun
`Mic140ProtocolDebugCli_Codex.exe --auto 20 --recorder-wire --tin-slots 3`.

## Live Recorder capture 2026-07-01 15:30

**Промпт:** пользователь остановил live-захват оригинального Recorder и попросил разобрать дампы и обновить протокол.

**Сделано:**
- Разобран свежий ETL `Tests\Mic140ProtocolDebug_Codex\Data\captures\netsh_192.168.14.155_20260701_153018.etl`.
- Parser: `Tools\parse_mdp_from_etl.py`.
- Найден рабочий Recorder wire profile просмотра: `total_valid_mdp=142`, `PORT=0=133`, `PORT=1=9`, `PORT=0 size=163 count=133`, `msgWords=163`, `dataWords=153`, `stride=51`, `samples=3`, TIn в слотах `48..50`.
- Созданы/обновлены:
  - `Data\captures\recorder_mdp_reference.txt`;
  - `Data\captures\recorder_mdp_control_examples.txt`;
  - `Data\mic140_adc_reference_recorder_wire_live_20260701_153018.txt`.
- Исправлен parser: теперь реально пишет `recorder_mdp_control_examples.txt`, а не только печатает путь.
- Обновлены `Docs\mic140_protocol.md`, `Docs\capture_workflow.md`, `Data\captures\README.md`.

**Вывод:** старый Cursor ETL `netsh_192.168.14.155_20260701_135935.etl` — валидный MDP-дамп, но не эталон Recorder-просмотра (`msgWords=106`, `stride=48`, `samples=2`). Для дальнейшей сверки использовать live Recorder dump `20260701_153018` и режим стенда `--recorder-wire --tin-slots 3`.

## Codex-стенд `Tests/Mic140ProtocolDebug_Codex`

**Промпт:** создать в `Tests\Mic140ProtocolDebug_Codex` автономный Lazarus-тест для отладки протокола MIC140, без unit-ов из других папок, с документацией протокола, сниффером, контрольными дампами и понятной точкой входа `DevMng.Search -> Connect -> Setup -> Start -> OnGetBlock -> Stop`.

**Сделано:**
- Создан автономный набор проектов:
  - `Mic140Example_Codex.lpi` — минимальный event-based пример API.
  - `Mic140ProtocolDebugCli_Codex.lpi` — CLI авто-прогон и proxy/sniffer.
  - `Mic140ProtocolDebug_Codex.lpi` — LCL-интерфейс стенда.
- Все `.lpi` используют только локальные пути `stubs;Driver;Driver\utils`; production units из `Device/` и соседний `Mic140ProtocolDebug` не подключаются.
- В `Docs` добавлены:
  - `task.md` — сохраненное задание и критерии готовности.
  - `mic140_protocol.md` — краткое описание MIC-140/MDP, источники, профили, приемка.
  - `capture_workflow.md` — как запускать proxy/netsh, Recorder и parser.
- Локальный parser `Tools\parse_mdp_from_etl.py` исправлен: при переданном ETL пишет результат рядом с этим ETL, а не в старый `Mic140ProtocolDebug`.
- Дамп `Data\captures\netsh_192.168.14.155_20260701_135935.etl` разобран: `total_valid_mdp=200`, `PORT=0=63`, `PORT=1=137`, `PORT=0 size=106`, `stride=48`. Это валидный MDP-дамп MIC-140, но не Recorder wire profile `msgWords=163/stride=51`.
- Созданы `Data\captures\recorder_mdp_reference.txt`, `Data\mic140_adc_reference_recorder_wire_exported.txt`, `Data\captures\README.md`.

**Проверка:** все три проекта собраны через `C:\lazarus\lazbuild.exe -B`, exit code 0. Финальные сборки без warnings, только hints/notes.

## Промпт
Продолжить стенд MIC-140 (`Tests/Mic140ProtocolDebug`): приёмка AIn 1–48 ±50, сверка с Recorder, использовать навык RecorderLnx.

## Сделано

### Эталоны
- `Data/mic140_adc_reference.txt` — production scan (fifo=48), stand steady-state 01.07
- `Data/mic140_adc_reference_recorder_wire.txt` — Recorder MDP wire (stride=51, TIn)

### Код стенда
- При `tin-slots=0` strict-приёмка **только AIn 1–48** (TIn пропускается)
- `stand-good` и ADC-таблица в логе: M/48 без TIn при tin=0
- Дефолты: production scan, settle=10s, bank2-delay=1, fifo=48

### Сборка
`lazbuild -B Mic140ProtocolDebugCli.lpi` — **OK** (exit 0)

## Live-тесты (192.168.14.155 rev14.1)

| Команда | read | published | stand-good | Примечание |
|---------|------|-----------|------------|------------|
| `--auto 25` | 124 | 0 | 24/48 @blk49 | CH01–24 OK; CH25 Δ≈388→109 к концу прогрева |
| `--auto 40 --settle-sec 20` | 199 | 0 | 24/48 @blk99 | CH25 Δ≈109; CH28+ тысячи кодов |

Поток стабилен (`readGaps=0`, `corrupt=0`, ~5 blk/s).

## Выводы (D26–D28)

- **D26:** production `tin=0`, 48 slots — правильный путь; `tin=3` ломает 2-й банк
- **D27:** wire-эталон (stride 51) ≠ stand fifo=48 — два файла эталона
- **D28:** CH25–26 ещё прогреваются после 10–20 s; CH28+ — programming/ME048, не только settle

## Открыто

1. PASS AIn 25–48 ±50 к stand-эталону
2. TIn 1–3: гибрид (48 scan + READMEMDM 114) или wire-профиль
3. Захват programming PORT=1 через proxy для сравнения с Recorder
4. Сверка shadow `Driver/` с production `Device/MIC140v2/` после PASS стенда

## Команды

```powershell
cd D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug
.\Mic140ProtocolDebugCli.exe --auto 25
.\Mic140ProtocolDebugCli.exe --auto 40 --settle-sec 20
.\Mic140ProtocolDebugCli.exe --auto 10 --recorder-wire --tin-slots 3
```

## Codex continuation 2026-07-03: MIC140 count_aver Recorder match

**Prompt:** Windows Recorder shows MIC140 average counts 327 and 318 in the
additional settings dialog for `period_decay` 57 us and 100 us; make the Codex
calculation match exactly.

**Confirmed:** `Mic140EvalAverageSampleCount` follows original
`MIC140_96_rce/mic140_96mod.cpp::CalcCountAver`. For MIC140-48 the count uses
51 slots (`48 AIn + 3 TIn`) when all-channel sampling is enabled. At exactly
10.0 Hz this gives `323/314`; the Recorder screenshot values `327/318` match
the same original formula when the actual first AIn channel frequency is about
`9.875..9.885 Hz`.

**Done:** changed the Codex debug stand test configuration in
`Tests/Mic140ProtocolDebug_Codex/uMic140DebugForm.pas` from `10.0` to `9.875`
Hz and recorded the investigation in
`errors/2026-07-03-mic140-average-count-recorder-match.md`.

**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`
completed with exit code 0; only existing hints/notes.

## Codex continuation 2026-07-07: MIC185 recording undercount at 10 Hz

**Prompt:** MIC-185 in RecorderLnx recorded only about 13 values in 3 seconds at
`Fs=10 Hz`; check and fix recording/buffer efficiency.

**Fix:** `Device/mic185/uMic185MebiusTcpProtocol.pas` no longer drops earlier
measurement packets during `ReadMeasDataBlock` drain. Previously the code read
up to 32 packets but replaced `ABlock` with the latest `dev_id=1` packet, so
with MIC185 `BlockSize=1` the recording effectively followed the 200 ms source
tick (~15 samples/3 s) instead of the 10 Hz stream. Added block aggregation via
`AppendMebiusFloatBlock`, using `Move` for per-channel `Single` array copies.

**Buffer check:** tag storage already uses a ring buffer in
`Core/uRecorderTags.pas` and uses `Move` for last-block / transformed
`Double` block copies. The remaining per-sample loops in MIC185 publication are
`Single -> Double` conversion and cannot be replaced by a raw `Move`.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit
code 0. No separate MIC185 `.lpi` test project was found by `rg --files`.

**Stop follow-up:** user reported debugger exception on transition to Stop:
`Unexpected Mebius packet signature: 00000001` in
`uMic185MebiusTcpProtocol.pas`. Root cause was a race: MIC185
`RequestStop` called `fDevice.Stop` from the external/UI thread while the
worker could still be in `ReadBlock`, creating concurrent reads on the same TCP
socket. Fixed `TRecorderMic185DataSource.RequestStop` to only set inherited
`TryStop`; device `Stop/Disconnect` now runs only from the worker-thread
`Stop`. `TryIoControl` was also hardened so protocol exceptions return `False`
with an error string. Rebuild of `RecorderLnx.lpi` completed with exit code 0.

## Codex continuation 2026-07-07: MIC140 offline icon in hardware tree

**Prompt:** MIC140 is currently powered off; in the device tree, show the failed
device picture when the connection function returns `False`, and use 1 second
timeouts instead of 5 seconds. The requested failure image is index 41 from the
command image list passed from the main form.

**Fix:** `UI/uRecorderSettingsDialog.pas` now probes MIC140 and MIC185 source
nodes while populating the hardware tree. MIC140 uses
`RecorderMic140TcpProbe(..., 1000)`, MIC185 uses
`RecorderMic185ReadDeviceInfo(..., 1000)`. If the source has no linked tags or
the probe returns `False`, the source node uses `CDeviceDisabledImageIndex`
(41); otherwise it keeps the controller image.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit
code 0. The existing post-build `copy_sdb_res.bat` still prints `#!/bin/sh` is
not recognized, but lazbuild exits successfully.

**Follow-up:** tags linked to an inactive/offline MIC source are now hidden from
the main form tag/channel list. `TMainForm.UpdateActiveSourceIds` probes unique
MIC140/MIC185 sources with a 1000 ms timeout after refreshing tag-based source
ids and unregisters sources that do not respond. The settings dialog keeps those
tags visible on the Channels tab but draws image index 54 in the selected
channels grid. Rebuild of `RecorderLnx.lpi` completed with exit code 0.

**Icon layout follow-up:** the selected-channel grid no longer draws inactive
source image 54 over the tag name. `UI/uRecorderSettingsDialog.pas` now uses a
dedicated leading 20 px icon column, keeps tag names in the next column, scales
the large image-list bitmap into a centered 16x16 px rectangle, and ignores the
empty icon column for sorting. The first rebuild reached compilation but could
not relink because `RecorderLnx.exe` was running as PID 21672; after stopping
that process, rebuild of `RecorderLnx.lpi` completed with exit code 0. The
existing `copy_sdb_res.bat` `#!/bin/sh` post-build message still does not fail
the build.

**Hardware tree follow-up:** user asked not to show child tags under devices in
the settings hardware tree. `UI/uRecorderSettingsDialog.pas` now keeps
`PopulateHardwareTree` source-only: Mera, MIC140, and MIC183/185 nodes are shown
without per-channel child nodes; channel membership remains in the channel
grids. `rg` confirms no `Items.AddChild(lSourceNode, ...)` calls remain.
Rebuild of `RecorderLnx.lpi` completed with exit code 0 after stopping a running
`RecorderLnx.exe` process that held the output exe.

## Codex continuation 2026-07-08: MIC185 channel programming

**Prompt:** реализовать программирование каналов MIC-185 как в оригинальном
Recorder, не менять базовый `TRecorderDevice` и не задеть поток сбора данных.

**Fix:**
- `Device/mic185/uMic185MebiusTypes.pas`: добавлен
  `TMic185ChannelProgramSettings` и `Mic185BuildSettingsEx`, который заполняет
  `CMIC185V2_BASECHAN_SETTINGS` по каждому измерительному каналу: connected,
  frequency, block size, range, soft balance, commutation, shunt, eval,
  sensitivity, resistance, sensor scheme. Старый `Mic185BuildSettings` оставлен
  wrapper-ом с дефолтами Recorder.
- `Device/mic185/uMic185Device.pas`: добавлен только MIC185-специфичный метод
  `ApplyChannelProgramSettings`; базовый `TRecorderDevice` не менялся.
- `Device/mic185/uRecorderMic185DataSource.pas`: настройки канала читаются из
  `TRecorderTag.SourceValueMode` в формате `mic185:range=...;commut=...` и
  передаются в прибор перед `Connect/ProgramDevice`. `DoTick`, `ReadBlock` и
  stop/read threading не менялись. Все 64 измерительных канала остаются
  `Connected=True`, чтобы не менять размер и порядок потокового кадра.
- `Device/mic185/UI/uRecorderMic185ChannelDialog.pas`: диалог канала теперь
  загружает/сохраняет диапазон, коммутацию, схему включения, шунт,
  программный баланс, чувствительность и сопротивление в `SourceValueMode`.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0 and linked `lib\x86_64-win64\RecorderLnx.exe`. Existing post-build
`copy_sdb_res.bat` still prints the `#!/bin/sh` message, but it does not fail
`lazbuild`.
## Codex continuation 2026-07-09: MIC185 settings buttons and source persistence

**Prompt:** Check MIC-185 settings dialog buttons; `Select all` was not
implemented. Inspect MIC-185 settings storage. When saving project settings,
each data source should have its own save function. MIC-185 settings must store
links to tags so hardware setup for each tag is understandable and reachable
from tag settings.

**Fix:**
- `Device/mic185/UI/uRecorderMic185SettingsDialog.pas/.lfm`: wired `Select all`,
  `Properties`, `Apply`, `OK`, `Balance`, and `Metrology`. `Select all` creates
  or relinks tags for all MIC183/185 rows. `Properties` creates a missing tag
  for the selected row and opens the MIC185 channel dialog. `Apply` now stores
  source config without closing the dialog. `OK` stores the source before close.
  `Balance`/`Metrology` now show explicit not-implemented messages instead of
  silently doing nothing.
- `Device/mic185/uRecorderMic185DataSource.pas`: added MIC185-specific
  save/load helpers for project data-source config. The JSON data source entry
  gets a `mic185` object with host, port, default poll frequency and
  `tagLinks[]` records (`tagName`, `address`, `sourceValueMode`,
  `pollFrequencyHz`).
- `Core/uRecorderProjectFiles.pas`: project save/load now calls the MIC185
  source-specific config hooks alongside the existing generic and MIC140 saves.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0. Existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh` message,
but it does not fail `lazbuild`.

## Codex continuation 2026-07-10: MIC185 units from codes, GX message, comments, encoding

**Prompt:** User reported that MIC185 hardware-GX memory read shows a MIC-140
message, changing tag units to Ohm still leaves values looking like codes,
MIC185 modules need comments, and dynamic dialogs/menus showed mojibake.

**Fix:**
- `Device/mic185/uRecorderMic185DataSource.pas`: raw MIC185 sample values are
  now treated as codes first. Without real hardware-GX coefficients the source
  applies nominal fallback `U_mV = code * nominal_mV / 32768`, then converts to
  the selected tag unit. This keeps the MIC185 protocol unchanged.
- `Device/mic185/UI/uRecorderMic185SettingsDialog.pas`: linking/creating a
  MIC185 measurement tag no longer overwrites an existing selected unit; range
  is recalculated through `RecorderMic185EffectiveRangeMax`.
- `UI/uTagSettingsDialog.pas`: the hardware-GX download button no longer says
  "no MIC-140 channels" for MIC185. It now reports that MIC185 hardware-GX read
  from device memory is not implemented yet and must be separate protocol work.
- Added comments/codepage markers across MIC185 constants/exported functions
  and updated `Docs/devices/mic185/value_units_conversion.md` with the nominal
  `32768 -> 100% range` fallback.
- Removed redundant `CP1251ToUTF8('...')` from active dynamic UTF-8 UI strings
  and fixed detected mojibake in calibration properties, MIC185 source probe
  units, and one MERA parser comment.
- Added `errors/2026-07-10-mic185-units-gx-encoding.md` with facts, actions and
  verification.

**Verification:** `rg` found no remaining active `CP1251ToUTF8('...')` dynamic
literal wrappers and no active mojibake patterns in UI/Core/MIC185 `.pas/.lfm`.
`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
passed; one earlier run hit a timing flake in the mock-thread test, immediate
reruns passed.

## Codex continuation 2026-07-10: MIC185 physical units and tag dialog buttons

**Prompt:** User asked to make the MIC185 channel dialog calculate the actual
range from selected settings, publish MIC185 tag values in selected units, and
restore original-like tag settings dialog controls: hardware-source setup,
zero-balance, hardware characteristic view/edit, and read-GX button with icon
57. User explicitly asked not to damage the MIC185 protocol.

**Fix:** `Device/mic185/uRecorderMic185DataSource.pas` now contains MIC185
effective-range and value-conversion helpers. Protocol/raw acquisition remains
in mV; `TRecorderMic185DataSource.PublishMeasurementBlock` converts values just
before adding samples to tags. Existing MIC185 tag units are no longer reset to
mV during source/tag creation, so selected `Ом`/`мкм/м` units survive.

**UI:** `Device/mic185/UI/uRecorderMic185ChannelDialog.pas` recalculates
`edActualRange` when nominal range, actual unit, module current, sensor scheme,
strain sensitivity, or external resistance changes. `UI/uTagSettingsDialog.pas`
now treats MIC185 like MIC140 for hardware-source setup and zero-balance button
visibility; the address-line setup button is no longer forcibly hidden.
`UI/uRecorderCommandImages.pas` reserves tag-dialog icon index 57 for the
hardware-curve read action.

**Docs:** Added `Docs/devices/mic185/value_units_conversion.md` with source
references from original `windev-v3.9` and a RecorderLnx behavior table. The
document records that MIC185 hardware-GX download from module is still not
implemented without protocol work; the current change only restores the UI and
keeps conversion in the data source.

**Verification:** First `lazbuild -B RecorderLnx.lpi` compiled but could not
overwrite `RecorderLnx.exe` because a running process held it. Stopped PID 9200
and rebuilt successfully. Existing post-build `copy_sdb_res.bat` still prints
the `#!/bin/sh` message but lazbuild exits 0. Also ran
`Tests/RecorderTests/DataSources/lib/RecorderDataSourcesTest.exe`: passed.

## Codex continuation 2026-07-09: MIC185 multi-row settings and programming trace

**Prompt:** `Select all` in the MIC183/185 settings dialog did not visibly select
all channels, changing a range affected only one row, and live programming of
500 mV needed comparison with the original Recorder/Mebius MIC185V2 code.

**Findings:**
- Original MIC185V2 range indices match RecorderLnx: `0 = +/-500 mV`,
  `1 = +/-50 mV`, `2 = +/-5 mV`, `3 = +/-0.5 mV`.
- Original programming order is also matched: `PROGRAMM_DEVICE_BIN`,
  `SET_SESSION_ID`, then `PROGRAM`.
- `RecorderMic185ChannelAddressToIndex` parses `MIC183_185-{3-14}` from the
  last dash to `ch14`, so the observed channel-4 overrange is not explained by
  the tag-address parser.

**Fix:**
- `Device/mic185/UI/uRecorderMic185SettingsDialog.pas`: `Select all` now sets
  the grid selection rectangle after creating/linking all 70 rows, so the UI
  shows the selected range. `Properties` collects the selected measurement rows
  and applies the edited channel settings to every selected measurement channel.
  Temperature/UTS rows are not mass-edited by the measurement-channel dialog.
- `Device/mic185/uRecorderMic185DataSource.pas`: `ApplyChannelProgramSettings`
  writes a concise trace to `LogWindows.log`, e.g. `ch14 range=0 commut=0`, so
  the next live run can prove which slot is actually sent to the device.
- `LoadMic185DataSourceConfigs` now restores `dataSources[].mic185.tagLinks[]`
  into tags when loading a project, not only registers the data source.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0 and linked `lib\x86_64-win64\RecorderLnx.exe`. The existing post-build
`copy_sdb_res.bat` still prints the `#!/bin/sh` message, but it does not fail
`lazbuild`.

**Startup crash follow-up:** after saving MIC185 settings, startup could crash
in `TRecorderTagRegistry.AddTag` with `Tag id already exists`. Root cause was
load order: `LoadMic185DataSourceConfigs` created tags from `mic185.tagLinks[]`
before the generic `tags[]` loader added the saved tags with persisted IDs.
`Core/uRecorderProjectFiles.pas` now calls `LoadMic185DataSourceConfigs` after
the generic tag loop, so MIC185 links update existing tags and only create truly
missing links. Rebuild of `RecorderLnx.lpi` completed with exit code 0 after
stopping a running `RecorderLnx.exe` process that held the output file.

**MIC185 source-settings follow-up:** user clarified that MIC185 hardware
settings must not live in tags. Tags are now treated only as bindings
(`SourceId` + channel `Address`); range/commutation/sensor/shunt/balance/etc.
are stored in the source node under `dataSources[].mic185.channels[]`.
`tagLinks[]` keeps only tag binding data. Old `sourceValueMode` values in
MIC185 tags or old `tagLinks[]` are migrated into the source config on load and
then cleared from tags. Programming now reads from the source config. Rebuild of
`RecorderLnx.lpi` completed with exit code 0.

**MIC185 Apply/OK programming follow-up:** user reported that multi-channel
range changes were reset after `Apply` -> `OK` and asked to save settings in
the device/source and program the instrument when leaving settings. MIC185
settings dialog now keeps channel hardware settings in `fChannelSettings`, loads
them from `dataSources[].mic185.channels[]`, stores them on `Apply`/`OK`, and
calls `RecorderMic185ProgramConfiguredSource` immediately. Source-level module
current is persisted as `dataSources[].mic185.powerMaCode`; the channel dialog
module power combo now maps mA to the MIC185 DAC code using the original Mebius
formula. `ProgramDeviceBin` writes the configured power code and logs the full
programming summary. If programming fails on `OK`, the MIC185 settings dialog
stays open. Rebuild of `RecorderLnx.lpi` completed with exit code 0.

**MIC185 OK persistence follow-up:** user reported that setting a channel range
to `500 mV` and reopening the MIC185 settings dialog still showed `5 mV`.
`Device/mic185/UI/uRecorderMic185SettingsDialog.lfm` no longer lets the `OK`
button close the form by its own `ModalResult`; `btnOkClick` now explicitly
stores all grid tags/source channel settings, calls MIC185 programming, and only
then sets `ModalResult := mrOk`. `ApplyRecorderMic185SourceDialog` also repeats
`StoreAllGridTags` after a successful modal close so the source node is flushed
before the caller refreshes UI. `StoreChannelSettingsConfig` logs
`SettingsDialog stored ... ch4 range=...` for the user's overrange channel
check. Rebuild of `RecorderLnx.lpi` completed with exit code 0 after stopping
the running `RecorderLnx.exe` that locked the output exe.

**MIC185 final persistence root cause:** fresh logs showed the MIC185 dialog did
store/program `range=0`, but the common settings close path immediately called
`TRecorderSettingsSourceProbe.SyncToRegistry`, which removed the existing
MIC185 configured source and recreated it without `SpecificConfigText`.
`UI/uRecorderSettingsSourceProbe.pas` now removes only hardware sources that are
no longer desired and preserves existing MIC185 source entries, so
`dataSources[].mic185.channels[]` survives `OK`, runtime source restart, and
project save. Rebuild of `RecorderLnx.lpi` completed with exit code 0.

## Codex continuation 2026-07-10: MIC185 settings packet table / TKC channel

**Prompt:** User reported that MIC-185 range switching works, but enabling the
thermocompensation/reference channel in the original Recorder causes hardware
subtraction like a bridge circuit, while RecorderLnx currently shows no effect.
User asked to assemble a table for the device settings packet with parameter
purpose, byte size, original behavior, RecorderLnx behavior, and source header;
also asked whether `windev-v3.9\examples\mebius.daq` contains useful info.

**Done:** Added
`Docs/devices/mic185/settings_packet_table.md`. The document records sources,
the `CMIC185V2_BASECHAN_SETTINGS` 56-byte slot map, the 3976-byte
`CMIC185V2_BASESETTINGS` map with offsets, and original-vs-RecorderLnx
behavior for every relevant field.

**Finding:** The likely reason the thermocompensation/reference channel has no
effect in RecorderLnx is not range programming. Original
`CMIC185V2Channel::SetProperty(MEPROPCH_MIC185V2_CHANTC)` writes the selected
addition input into `GroupAddition_[channel div 16]`, and
`MEPROP_TERMO_COMP` writes `bTKC_`. RecorderLnx currently sends all
`GroupAddition[] = CMic185ModAddOff` and `TemperatureCompensation=False`.

**examples\mebius.daq:** Useful as a portable MIC185 Mebius DAQ example and
programming-order confirmation (`SET_CONTROLLER_PARAMS`,
`PROGRAMM_DEVICE_BIN`, finish programming), but the authoritative packet layout
is in the shared `Mebius\MebiusDAQDevices\mic185v2` sources.

## Codex continuation 2026-07-10: MIC185 TKC/reference-channel programming

**Prompt:** User confirmed that the original Recorder currently assigns
compensation channel 1 to the first 16 measurement channels and asked to bring
RecorderLnx to the analogous state so the thermocompensation/reference channel
works.

**Fix:** `Device/mic185/uMic185MebiusTypes.pas` now has
`TMic185GroupAdditionArray` and default group additions
`[CMic185ModAdd1, CMic185ModAddOff, CMic185ModAddOff, CMic185ModAddOff]`.
`Mic185BuildSettingsEx` writes caller-provided `GroupAddition[]` and
`TemperatureCompensation` into `ProgramDeviceBin` instead of hard-coding all
groups off and TKC false.

**Data source:** `Device/mic185/uRecorderMic185DataSource.pas` now reads, logs,
saves and loads `dataSources[].mic185.groupAddition[]` plus
`dataSources[].mic185.temperatureCompensation`. Missing fields in older project
files default to the observed original state: compensation channel 1 for group
0 (channels 1..16), other groups off, TKC enabled. Live programming logs now
include `tkc=True groupAddition=[0,4,4,4]`.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0. Existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh` message,
but it does not fail `lazbuild`.
## Codex continuation 2026-07-10: MIC185 hardware GX read and tag dialog buttons

**Prompt:** User reported that the hardware-GX edit/view button in tag settings
still opens a MIC-140-only message, while MIC-185 should open the GX settings
dialog. The explicit read-GX button should read MIC-185 hardware coefficients
like the original Recorder device-level path, but without damaging the MIC-185
measurement protocol.

**Fix:**
- Added `Device/mic185/uRecorderMic185Calibration.pas`. It reads the current
  MIC-183/185 channel evaluator through `CallCommand(IOCTL_CMD_GET_CALIBR_KOEF)`,
  using the original sources as layout reference:
  `examples\mebius.daq\...\mic185.cpp::LoadCalibrCoefficients` and
  `MebiusDAQDevices\mic183\mic183base\ComputePhysical.h`.
- The read result is stored as a two-point `TRecorderCalibration`
  implementing original linear math `k * (code - b)`, then assigned to the
  tag as `HardwareCalibrationName` with `HardwareCalibrationEnabled=True`.
- `uRecorderMic185DataSource.pas` now applies the tag hardware calibration
  before unit conversion. If no hardware GX is assigned, the previous nominal
  fallback remains: `32768` codes = `100%` of the selected range.
- `UI/uTagSettingsDialog.pas` now separates actions:
  hardware-GX select/view opens the calibration list and properties dialog,
  edit opens properties for any assigned hardware GX, and read-GX calls either
  MIC-140 or MIC-185 depending on the selected tag source.

**Safety note:** `IOCTL_CMD_RELOAD_CALIBR` was documented but not called from
the tag dialog because it changes the OMAP-loaded flash calibration slot and
requires a separate device `fileType`. The explicit button reads the evaluator
already loaded by the device, matching the original working-channel path.

**Verification:** First rebuild compiled but could not relink because
`RecorderLnx.exe` was running as PID 15324; stopped it and rebuilt successfully:
`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
exit code 0. Existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh`
message but does not fail `lazbuild`. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
passed.

## Codex continuation 2026-07-10: MIC185 hardware GX display k,b

**Prompt:** User reported that the hardware-GX view/edit button opened a
confusing channel/calibration list instead of showing the MIC-185 hardware GX,
and the module memory read result showed an id-like string while it should show
the `k` multiplier and `b` offset.

**Fix:** `Device/mic185/uRecorderMic185Calibration.pas` now exposes the detailed
MIC185 read result (`k`, `b`, calibration name) and helper functions that format
or reconstruct `k,b` from the stored two-point hardware calibration
(`y = k * (code - b)`). `UI/uTagSettingsDialog.pas` now uses the hardware-GX
field as display text for MIC185 `k,b` and no longer writes that display text
back into `HardwareCalibrationName` on OK/Apply. The hardware-GX view button
opens the assigned calibration properties directly. The explicit read-GX button
adds per-tag `k=...; b=...` lines to the success message.

**Verification:** First `lazbuild -B RecorderLnx.lpi` reached linking but failed
with error code 5 because `RecorderLnx.exe` PID 14752 held the output file.
After `Stop-Process -Id 14752`, `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
passed after the final display change.

## Codex continuation 2026-07-10: active hardware sources after tag settings OK

**Prompt:** User reported that after opening tag settings and closing it with
OK, MIC140 tags appeared in the main tag list even though the MIC140 source was
not connected. The suspected cause was `fActiveSourceIds` receiving MIC140 from
tag-dialog logic.

**Fix:** `TTagSettingsDialog.CreateDialog` no longer calls
`RefreshActiveSourcesFromTags`. `TRecorderTagRegistry.RefreshActiveSourcesFromTags`
now keeps baseline virtual/manual/debug/MERA visibility but does not mark
MIC140/MIC185 hardware sources active just because tags exist.
`TMainForm.UpdateActiveSourceIds` now explicitly registers a hardware source
only when `RecorderHardwareSourceLinkOk` passes and unregisters it otherwise.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
passed. Added `errors/2026-07-10-active-source-tag-dialog.md`.

## Codex continuation 2026-07-10: MIC185 hardware-GX checkbox mode

**Prompt:** User clarified that when the hardware-GX checkbox is unchecked, the
tag must show raw codes. When it is checked and GX exists, values should be
shown according to the selected unit/conversion mode.

**Fix:** `TRecorderMic185DataSource.PublishMeasurementBlock` now checks
`TRecorderTag.HardwareCalibrationEnabled` before MIC185 unit conversion. If the
checkbox is off, raw `ABlock.Values` are published as already-transformed
values, so the common tag path does not apply hardware GX. If the checkbox is
on, the previous path remains: assigned hardware GX is applied when present,
otherwise the nominal `32768 -> 100% range` fallback is used before converting
to the selected MIC185 unit.

**Verification:** First rebuild failed only at link because `RecorderLnx.exe`
PID 19184 held the output file; after `Stop-Process -Id 19184`,
`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0.

## Codex continuation 2026-07-14: MC-201 fast Config and Russian docs

**Prompt:** User reported that programming MC-201 modules is still slow compared
with original Recorder and asked to rewrite test documentation/comments in
Russian.

**Fix:** Added a fast path in `TMc201LegacyMdpClient.LoadMc201BiosIdma`: before
full `.bio` upload the client writes IDMA `0x6000`, reads `VAR_TMODE`, checks
`A5A5`, and validates the loaded module BIOS with `CMD_INIT`. If validation
passes, full upload is skipped and the slot is cached for the current TCP
client. If validation fails, full upload remains as fallback. Rewrote
`Mc201ProtocolDebug\README.md`, `Docs\devices\mc\mc201.md`, and Pascal comments
in the test to Russian.

**Verification:** Rebuilt `Mc201ProtocolDebug.lpi` with exit code 0. Live
`--cli --play-diagnostic-ms=1 --host=192.169.12.87 --port=4000 --timeout-ms=1200 --slots=4`
completed successfully in under a second from process start with `Config OK`,
`STARTSCANMAIN OK`, data packets, `STOPSCANMAIN OK`, and
`RESULT Mc201PlayDiagnostic passed`.

## Codex continuation 2026-07-14: MC-201 BIOS embedded resource

**Prompt:** User asked to copy the MC-201 BIOS binary into project resources and
compile it into the executable in a Linux-compatible way; future MIC-185 and
other hardware binaries should follow the same rule.

**Fix:** Copied `mc_201a.bio` to
`Tests\RecorderTests\Mc201ProtocolDebug\resources\devices\mc201\mc_201a.bio`.
Added `resources\mc201_protocol_debug.rc` with resource `MC201A_BIO` of custom
type `MC201BIO`, included it from `Mc201ProtocolDebug.lpr`, and added
`uMc201FirmwareResources.pas`. `TMc201LegacyMdpClient.LoadMc201BiosIdma` now
loads BIOS bytes from the embedded resource first and uses the original
`windev-v3.9` path only as fallback. Added CLI check `--check-resources`.

**Verification:** `lazbuild -B Mc201ProtocolDebug.lpi` completed with exit code
0 and compiled `resources\mc201_protocol_debug.rc`. `Mc201ProtocolDebug.exe
--cli --check-resources` printed `RESOURCE MC201A_BIO OK
source=resource:MC201A_BIO bytes=22040`. Live
`--cli --play-diagnostic-ms=1 --host=192.169.12.87 --port=4000 --timeout-ms=1200 --slots=4`
still completed with `Config OK`, data packets, `STOPSCANMAIN OK`, and
`RESULT Mc201PlayDiagnostic passed`.
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
passed.

## Codex continuation 2026-07-10: MIC185 hardware-GX assignment persistence

**Prompt:** After reading hardware GX for many selected MIC185 channels and
pressing OK, reopening one channel showed an empty hardware-GX field. The tag
must remember the assigned GX and display either the GX name or an alias when
only coefficients are available.

**Fix:** `Core/uRecorderProjectFiles.pas` now persists
`hardwareCalibrationEnabled` and `hardwareCalibrationName` for every tag.
`UI/uTagSettingsDialog.pas` now treats the MIC185 hardware-GX edit field as a
display field: for an existing MIC185 calibration it shows reconstructed
`k,b`, for a missing calibration object it shows the stored name/alias, and for
multi-selection with different assignments it shows `<разные аппаратные ГХ>`
with the checkbox grayed so OK does not overwrite individual assignments.

**Verification:** A running `RecorderLnx.exe` PID 21752 first held the output
exe; after stopping it,
`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0. The existing post-build `copy_sdb_res.bat` still
prints the `#!/bin/sh` message but does not fail `lazbuild`.
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
passed.

## Codex continuation 2026-07-10: MIC185 hardware-GX cleared on tag OK

**Prompt:** User still reproduced the issue in one dialog session: open MIC185
channel, read hardware GX, press OK, reopen the same channel, and the hardware
GX line is empty again.

**Root cause:** `TTagSettingsDialog.StoreToTags` called
`RecorderTagClearMic140Settings` for every tag that was not MIC140. That helper
clears the generic tag fields `HardwareCalibrationEnabled` and
`HardwareCalibrationName`, so MIC185 read-GX was erased by the OK path itself.

**Fix:** The cleanup now excludes MIC185 hardware sources. MIC185
`dataSources[].mic185.tagLinks[]` also saves/loads `hardwareCalibrationEnabled`
and `hardwareCalibrationName`, so source-specific link restoration keeps the
same GX assignment.

**Verification:** Stopped running `RecorderLnx.exe` PID 11208, rebuilt
`RecorderLnx.lpi` with exit code 0, and
`RecorderDataSourcesTest.exe` passed.

## Codex continuation 2026-07-10: MIC185 bulk read-GX message shortened

**Prompt:** User reported that reading hardware GX for many selected MIC185
channels opens an oversized message listing every channel. The dialog should
show the first channel, then `...`, and OK.

**Fix:** `TTagSettingsDialog.DownloadHardwareCalibrationFromDeviceClick` now
builds a short `lMessageText`: first successful per-channel line, plus `...`
when more than one channel was read. Full per-channel assignment still happens;
only the message box text is shortened.

**Verification:** Stopped running `RecorderLnx.exe` PID 8144, rebuilt
`RecorderLnx.lpi` with exit code 0, and
`RecorderDataSourcesTest.exe` passed.

## Codex continuation 2026-07-10: MIC185 hardware-GX disk cache

**Prompt:** User asked to persist MIC185 hardware GX like MIC140 under
`C:\Mera Files\Calibr\hardware`, e.g. `MIC-185\sn...\range1...`, so the same
coefficients do not need to be read from the device again on every range change
or next project load. User also asked to compare with original Recorder linear
GX storage.

**Findings:** Current RecorderLnx MIC140 uses text CSV files under
`Calibr\hardware\MIC140\snXXXX\<range>\NN.csv`. The live
`C:\Mera Files\Calibr\hardware\MIC140\sn0164\06_100mV\01.csv` file is plain
`x,y` CSV. Original Mebius `CBaseVirtualChannel` also forms
`GetCalibrDir + GetCalibrSubDir + "%02d.csv"` and calls evaluator
`ExportToText/ImportFromText`. Original MIC185 itself is the exception: it
loads `k,b` through the device evaluator path (`IOCTL_CMD_GET_CALIBR_KOEF`) and
does not reliably use that standard disk branch.

**Fix:** `Device/mic185/uRecorderMic185Calibration.pas` now:
- names MIC185 hardware GX as `MIC185 snXXXX rangeN chCC`;
- stores and loads CSV at
  `C:\Mera Files\Calibr\hardware\MIC-185\snXXXX\rangeN\CC.csv`;
- stores the two-point equivalent of `y = k * (code - b)`;
- checks the disk cache before calling the device, and saves CSV after a
  successful device read.

`UI/uTagSettingsDialog.pas` now tries to restore a MIC185 hardware GX object
from disk when the tag has a saved GX name but the registry object is not loaded
yet. `Device/mic185/uRecorderMic185DataSource.pas` also lazily restores the
saved GX from disk during publication when a project was loaded with only the
persisted GX name. Added `Docs/devices/mic185/hardware_calibration_cache.md`
and linked it from the MIC185 README.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
passed.

## Codex continuation 2026-07-13: MC-201 protocol debug stand

**Prompt:** Find the MC-201 / MC-031 / MC-032 example under
`windev-v3.9\examples\mebius.daq` and create an independent RecorderLnx-compatible
test example for later protocol porting. Target controller:
`192.169.12.87`, expected four MC-201 modules.

**Findings:** `medaq_mc_test.cpp` creates `MICCRATE`, connects through
`BUSID_ETHERNET81_TCP`, gets `BUSID_MC`, then calls `SearchDevices`. The older
Recorder MC-031 Ethernet path uses legacy MDP/TCP command packets; module
auto-search reads slot flash offset `0` for type and offset `1` for MC-201
version discriminator.

**Fix:** Added standalone console project
`Tests\RecorderTests\Mc201ProtocolDebug`. It does not use RecorderLnx device
units and does not write/program hardware. It reads `CMD_REPLY`, scans module
flash offsets `0/1/61/62`, prints used slots and MC-201 module count, and writes
a `.log` beside the exe.

**GUI follow-up:** CLI and GUI are now merged into the single
`Mc201ProtocolDebug.lpi` project. GUI is the default mode; CLI starts with
`Mc201ProtocolDebug.exe --cli ...`. The separate `Mc032ProtocolDebugGui.lpi/.lpr`
project and stale `Mc032ProtocolDebugGui.*` build artifacts were removed. All
test units are listed in the `.lpi` for Lazarus Project Inspector. The GUI uses
independent `TMc032Device` states `Disconnected/Connected/Play`,
controller actions `Search/TestConnection/SearchModules/Connect/Disconnect/Reset/Config/Play/Stop`,
a read thread, and a callback that fills a raw-word oscilloscope on the form.
`Config` currently stores `TMc032Config`, updates timeout and sends
`CMD_RESETSCANMAIN`; full MC-201 scan descriptor programming still needs the
original `CMD_ADDCHANNELMODULE` / `CMD_SCAN_SET_CHANS` path.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
completed with exit code 0. `Mc201ProtocolDebug.exe --help` completed with exit
code 0 and created `lib\Mc201ProtocolDebug.log`. Live TCP run against
`192.169.12.87:4000` from this environment timed out before protocol exchange.
The same executable starts GUI by default; `--cli` and `--help` remain CLI paths.

**MC documentation follow-up:** User provided original Recorder screenshots with
the actual detected stand: four-slot controller `[0841] MIC-200m - Ethernet`,
MC-201 modules slot 1 `01462`, slot 2 `01465`, slot 3 `01464`, slot 4 `01463`,
all version `5.0`. Added `Docs/devices/mc/README.md` and
`Docs/devices/mc/mc201.md` documenting the stand, MC-201 channel settings,
range list, input/filter/ICP fields, and frequency grid
`300..19200 Hz`.

## Codex continuation 2026-07-13: MIC185 selected-row tag units

**Prompt:** User reported that in MIC185 hardware settings, after using
`Select all`, changing units or other channel properties in the channel
properties dialog must apply to all selected tags.

**Fix:** `Device/mic185/UI/uRecorderMic185SettingsDialog.pas` now propagates
the edited tag unit from the master channel dialog to every selected MIC185
measurement tag. For each selected row it also recalculates `RangeMin/RangeMax`
in that unit while keeping the existing source-level hardware settings path.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code
0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
passed.

## Codex continuation 2026-07-14: MC-201 Config GUI freeze

**Prompt:** User reported that the MC-201 protocol-debug GUI hangs after
`Connect`, `Modules`, `Config`.

**Fix:** `TMc032DebugForm.ButtonConfig` no longer runs
`TMc032Device.Config` in the LCL main thread. Added a background
`TMc032ConfigThread`, a form-level busy state, disabled action buttons while
Config is running, and guarded normal window close until the worker finishes.
The change does not alter MC-201/MC-032 packet programming; it only moves the
long BIOS/config sequence off the UI thread.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
completed with exit code 0.

**Follow-up:** User reproduced a hang after `Config`. The deeper cause was an
unbounded wait in `TMc201LegacyMdpClient.CallCommand`: while the controller was
returning stream packets, the code skipped non-command ports forever and never
hit a command-reply deadline. Added an overall reply timeout and a GUI busy
heartbeat. Rebuilt `Mc201ProtocolDebug.lpi` with exit code 0. Live
`--play-diagnostic-ms=3000` against `192.169.12.87:4000` passed:
`Config OK`, `STARTSCANMAIN OK`, `STOPSCANMAIN OK`, `PLAY messages=35`,
`RESULT Mc201PlayDiagnostic passed`.

**GUI-specific follow-up:** User reproduced `Connect -> Modules -> Config`
hanging in the GUI while the status heartbeat still updated. Changed GUI Config
again: removed the worker thread because it used a socket created on the LCL
thread. `ButtonConfig` now follows the same single-thread device path as the
passing CLI run and keeps the window responsive through device progress
callbacks plus `Application.ProcessMessages`. The log now records
`Config step: ...` before each controller/module operation. Rebuilt
`Mc201ProtocolDebug.lpi` with exit code 0.

## Codex continuation 2026-07-14: MC-201 Play one packet / STOP timeout

**Prompt:** After `Play`, some MC-201 data arrives and then stops; repeated
`Play` or `Reset` often leads to `MDP TCP write failed`.

**Update:** Reproduced the current live behavior through CLI before the
controller port stopped accepting TCP: one 26-word stream packet arrives
(`header.chan=0x78F1`), then read timeouts and `STOPSCANMAIN` timeout. Repeated
CLI runs no longer reproduced `MDP TCP write failed`, because Stop now waits
for the Stop command and force-disconnects on timeout instead of leaving a bad
socket in `Connected`.

**Fix:** Corrected CLI and GUI demultiplexing to compare full MC-201
`final_flag`/`header.chan` including `0x4000` (`IS_DM`), matching original
`ScanMC201::Decommutation`. Added first-packet word dump to CLI diagnostics.
Made `--play-diagnostic-ms` fail unless `STOPSCANMAIN` succeeds and packet
count reaches the expected `duration / 200 ms`.

**Verification:** Rebuilt `Mc201ProtocolDebug.lpi` with exit code 0. Final live
check could not connect: `Connection to 192.169.12.87:4000 timed out`, likely
because the previous bad scan/another client still owns the controller port.

## Codex continuation 2026-07-14: MC-201 GUI Connect exception

**Prompt:** GUI falls/stops on `Connect` at `TInetSocket.Create`.

**Fix:** Added `TMc032Device.TryConnect(out AErrorMessage): Boolean` and routed
the GUI `Connect` button plus `Play` auto-connect through it. Expected TCP
connection failures now stay in device state `Disconnected` and are written to
the GUI log instead of being re-raised by `TMc032Device.Connect`.

**Verification:** Closed the stale Lazarus debug session, rebuilt
`Mc201ProtocolDebug.lpi` with exit code 0, launched the GUI, clicked `Connect`
through UI Automation/mouse coordinates, and confirmed the app logs
`Connect: Connection to 192.169.12.87:4000 timed out.` instead of falling out of
the button handler.

## Codex continuation 2026-07-14: MC-201 GUI connect-on-create test

**Prompt:** User asked to add a unit/regression test that invokes the same
connect function from form creation instead of pressing the GUI button.

**Fix:** In `Tests\RecorderTests\Mc201ProtocolDebug`, extracted GUI connect
logic into `TMc032DebugForm.RunConnectAction` and added
`--gui-connect-on-create-test`. The mode creates the form, runs connect from the
creation hook, prints `RESULT Mc201GuiConnectOnCreate ...`, and exits without
`Application.Run`.

**Verification:** `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
completed with exit code 0. The new test returned exit code 0 with
`RESULT Mc201GuiConnectOnCreate passed: Connect: Connection to 192.169.12.87:4000 timed out.`

## Codex continuation 2026-07-14: MC-201 non-throwing GUI TCP connect

**Prompt:** User reported that even GUI `Search` stops at
`TInetSocket.Create`; this did not happen earlier.

**Fix:** Root cause is that `Search -> TestConnection` used the same TCP open as
`Connect`, and `TInetSocket.Create` raises on timeout/refused connection.
Replaced the GUI-facing connection path with `TMc201LegacyMdpClient.TryConnect`,
which opens the socket with a nonblocking connect/select timeout and returns an
error string instead of throwing. `TMc032Device.TryConnect` and
`TestConnection` now use this path; the old throwing `Connect` remains for
CLI/internal callers.

**Verification:** Rebuilt `Mc201ProtocolDebug.lpi` with exit code 0. The
connect-on-create regression still passes and returns
`Connect: Connection to 192.169.12.87:4000 timed out.`

## Codex continuation 2026-07-14: MC-201 Config speed and IDMA chunking

**Prompt:** User reported that `Play` now receives apparently correct data, but
`Config` is much slower than original Recorder; maybe module programming should
use fewer packets.

**Fix:** Compared with original `mdpEthernet81`, `Mc031ethernetifc` and
`Mc201.cpp`. The raw Ethernet packet can carry 1024 words, but original command
arguments are limited to `MAX_TX = 32` words. For `CMD_IDMAPUTARRAY` this leaves
27 data words, and PM writes must be even, so the safe chunk is `26` words.
Encoded this as `CMc201CommandMaxArgWords = 32` and
`CMc201IdmaArrayMaxDataWords = 26`. Added per-client loaded-BIOS slot cache so
repeated GUI `Config` in the same connection skips the heavy `.bio` upload.

**Verification:** `lazbuild -B Mc201ProtocolDebug.lpi` completed with exit code
0. Live command `Mc201ProtocolDebug.exe --cli --play-diagnostic-ms=1
--host=192.169.12.87 --port=4000 --timeout-ms=1200 --slots=4` completed with
`Config OK`, `STARTSCANMAIN OK`, data packets, `STOPSCANMAIN OK`, and
`RESULT Mc201PlayDiagnostic passed`.

## Codex continuation 2026-07-14: MC-201 documentation pass

**Prompt:** User asked to document what was developed in project documents and
add comments explaining what each part does and why.

**Fix:** Added focused Pascal comments to the MC-201 debug project around the
hard protocol decisions: stand defaults, 32-word MDP command argument limit,
26-word IDMA chunks, non-throwing GUI TCP connect, per-client BIOS cache,
original-like scan programming order, Config retry, and GUI connect regression
mode. Expanded `Docs/devices/mc/mc201.md` and the test `README.md` with the
same decisions and command examples for future transfer into RecorderLnx.

**Verification:** First rebuild failed only because a running
`Mc201ProtocolDebug.exe` held the target executable. After stopping that
process, `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
completed with exit code 0.
# Codex continuation 2026-07-15: MIC-200 production device driver

**Prompt:** Add MIC-200 support (MC-201 modules and MC-032 controller) under
`Device/mic200`, based on `TRecorderDevice`, without regressing existing
devices; evaluate a shared TCP layer.

**Implementation:** Moved the verified low-level protocol units from the
independent `Mc201ProtocolDebug` stand into `Device/mic200` and added
`TRecorderMic200Device`. It implements Connect/ProgramDevice/Start/ReadBlock/
Stop/Disconnect, discovers MC-201 modules, maps each slot to four Recorder
channels, matches stream messages by the complete MC-201 final flag, converts
signed 16-bit samples, and assembles one rectangular acquisition block only
after every programmed channel has arrived. Added the MC-201 BIOS as the
cross-platform `MC201A_BIO` resource in the main executable. Existing MIC-140
and MIC-185 units were not changed. A shared raw socket class was deliberately
not introduced: the safe common abstraction is `TRecorderDevice`, while the
MDP and MIC-185 packet/session formats differ.

**Verification:** `lazbuild -B RecorderLnx.lpi` completed with exit code 0 and
linked the new resource. `lazbuild -B Mc201ProtocolDebug.lpi` completed with
exit code 0; `--cli --check-resources` reported 22040 bytes and passed.
`RecorderDataSourcesTest.lpi` could not build because its existing search path
does not include `Device/MIC140` and therefore cannot find
`uRecorderMic140DeviceConfig`; this failure is outside the MIC-200 changes.
# 2026-07-15 — MC-032 в аппаратной конфигурации

- В список добавляемых источников добавлен контроллер `MC-032`; название
  `MIC-200` больше не используется как пользовательский тип устройства.
- Новый диалог `Device/mic200/UI/uRecorderMc032SettingsDialog.pas` позволяет
  задать адрес, выполнить автопоиск по `192.169.13.*`, проверить командой
  `TEST_LOAD` и прочитать flash-идентификацию модулей по слотам.
- В конфигурацию допускается только узел, успешно ответивший на протокольный
  тест. Поддерживаемые модули сейчас определяются как MC-201/MC-201A.
- Для дерева аппаратуры зарегистрирован MC-032 link probe через тот же TEST.
- Полная сборка `RecorderLnx.lpi`: OK.
- После поиска и сохранения MC-032 найденные MC-201 отображаются дочерними
  узлами контроллера в дереве: слот, тип, версия и серийный номер. Узел MC-032
  автоматически раскрывается; список восстанавливается из конфигурации проекта.

# 2026-07-15 — MC bus и диалог MC-201

- Папка `Device/mic200` переименована в `Device/MCbus`: MIC-200 — конструктив,
  а программная граница здесь — шина MC с MC-032 и MC-201.
- Адаптер переименован в `TRecorderMcbusDevice`; `TMc032Device` остался
  низкоуровневым TCP/MDP-драйвером контроллера.
- Двойной клик на дочернем узле слота MC-201 открывает
  `Device/MCbus/UI/uRecorderMc201SlotSettingsDialog.lfm`: 4 канала, HPF/LPF/ICP,
  режим входа, коммутация, тип и ревизия субмодуля.
- Настройки хранятся по номеру слота и сохраняются при повторном поиске модулей.
- Полная сборка `lazbuild -B RecorderLnx.lpi`: OK, exit code 0.

# 2026-07-15 — double click MC-201 routing fix

Исправлено открытие диалога MC-032 вместо MC-201: парсер номера слота
был небезопасен для UTF-8 из-за фиксированной байтовой позиции. Теперь дочерний
узел с маркером MC-201 открывает LFM-форму аппаратных свойств MC-201. Сборка OK.

# 2026-07-15 — MC-032 persistence fix

MC-032 исчезал при `OK`, потому что `TRecorderSettingsSourceProbe.SyncToRegistry`
удалял все аппаратные источники, отсутствующие в его списках Mera/MIC-140/MIC-185.
Синхронизация ограничена типами, которыми probe владеет. `SpecificConfigText` добавлен
в JSON `dataSources`, чтобы слоты MC-201 и их настройки переживали повторную загрузку проекта.
Полная сборка RecorderLnx: OK.

# 2026-07-15 — MC-201 channels and source-indexed addresses

Для каждого найденного MC-201 source probe создаёт 4 доступных канала. Адрес
включает индекс источника в аппаратном дереве. Для Mera-источника старый первый индекс
заменяется текущим, для MC-032 индекс добавляется перед `слот-канал`. Ошибка дублирования
выбранных Mera-каналов в доступных и их удаления при `OK` исправлена: группа Mera всегда
использует descriptor `SourceId`, а не `FileName` сигнала. Compile-only `lazbuild -B --opt=-Cn`: OK;
полная линковка ожидает закрытия RecorderLnx.exe.

После закрытия приложения полная сборка прошла с exit code 0. Имя канала MC-201 теперь
равно его цифровому tree-indexed адресу; служебный адрес `virtual` сокращён до `v`, при этом
тип источника `virtual` сохранён.
# 2026-07-15 — MC-032/MC-201 runtime in Preview

По `LogWindows.log` установлено, что режим просмотра не создавал источник MCbus: запускались только MERA playback и диагностика. Добавлен `TRecorderMcbusDataSource`, который в рабочем потоке выполняет connect/program/start/read/stop через существующий `TRecorderMcbusDevice`, сопоставляет нативные `slot-channel` с tree-indexed адресами выбранных тегов и публикует блоки в реестр. `TMainForm` теперь создаёт этот источник для выбранных тегов MC-032. В лог добавлены lifecycle-метки `[MCBUS]`, сообщения о блоках и разреженная диагностика таймаутов. Подробности: `errors/2026-07-15-mcbus-preview-no-data.md`.
# 2026-07-15 — MCbus Preview smoke и безопасный Stop

Устранено исключение `MC-032 stop: MDP command timeout`: неподтверждённый STOPSCANMAIN теперь приводит к безопасному закрытию неоднозначной TCP-сессии и состоянию disconnected, а не к исключению в UI. Добавлен production smoke-тест `Tests/RecorderTests/McbusPreviewSmoke`. На реальном `192.169.12.87:4000` при периоде 200 мс он получил 15/15 блоков за 3 секунды (5,00 блока/с), 16 каналов × 68 отсчётов, и остановился без исключения. Подробности: `errors/2026-07-15-mcbus-stop-command-timeout.md`.
# 2026-07-15 — MC-201 полный поток 57,6 кГц

Исправлены ложные значения и потеря объёма данных MC-201. MDP-пакеты теперь разделяются на вложенные BIOS-сообщения, 10 слов заголовка исключаются из сигнала, payload накапливается по slot/final-flag до 11 520 отсчётов на канал за 200 мс. Корневая ошибка темпа: ADSP FIFO 256 ошибочно делился на 16 каналов; оригинальный `SetADSPFifoSize(256)` задаёт 256 отсчётов каждому каналу. Реальный smoke-тест: 16 каналов, 25 блоков × 11 520 = 288 000 отсчётов на канал за 5 секунд, ровно 57 600 отсчётов/с.
# 2026-07-15: единый список каналов осциллограммы

- Убран отдельный UI-сценарий «Основной канал»; теперь канал выбирается и
  добавляется одной кнопкой.
- Первый канал попадает в синюю линию, второй — в зелёную, третий — в красную.
- Внутренняя схема `TagName + Lines[]` сохранена для совместимости файлов проекта.
- Полная сборка `RecorderLnx.lpi`: exit code 0.

# 2026-07-15: консолидация документации MCbus

- Добавлен `Docs/devices/mc/recorderlnx-integration.md` — единая карта ролей
  MC-032/MC-201, конфигурации, дерева, адресов, runtime Preview, MDP/BIOS payload,
  объёма 57,6 кГц, безопасного Stop, осциллограммы, логов и тестов.
- Исправлены устаревшие шапки production-юнитов, ошибочно называвшие MCbus
  автономным тестовым кодом. В ключевых Pascal-модулях добавлены русские
  комментарии с инвариантами и ссылкой на сводный документ.
- В `uMainForm.pas` отмечена обязательная регистрация MCbus в фабрике runtime-
  источников; в `uRecorderSettingsDialog.pas` — сохранение через общий список
  источников и маршрутизация двойного клика MC-201.

# 2026-07-15: быстрый Preview и предвыделение MCbus

- Connect/ProgramDevice MCbus перенесены из перехода Preview в загрузку или
  переконфигурирование проекта; повторный Prepare для `rdsProgrammed` — no-op.
- Успешный Stop больше не делает Disconnect. Крупные pending/output/time
  буферы повторно используются, Start/Stop сбрасывают только счётчики.
- Удалены `SetLength` из MCbus ReadBlock и PublishBlock; переполнение pending
  теперь является явной ошибкой конфигурации.
- Полная сборка RecorderLnx прошла. Стенд MC-032 при контрольном smoke был
  недоступен (TCP timeout), это записано в error journal.
## 2026-07-15 — lifecycle Init и программирование MCbus

- Подтверждено: `rstInit` был только начальным `LastTransition`, события Init в EventBus не существовало.
- Добавлено `rceInitialized`, публикуемое после загрузки проекта/форм, создания источников, привязки тегов и подготовки оборудования.
- В `TRecorderDataSourceManager` добавлен универсальный `PrepareHardwareAll`.
- Исправлен порядок при старте, загрузке конфигурации и переконфигурировании: `EnsureDemoDataSources` → `PrepareRuntimeForConfiguration`.
- MC-032/MC-201 теперь подключается и программируется в конфигурационной фазе; `StartAll` оставляет страховочный повтор.
- Полная сборка `RecorderLnx.lpi` успешна.
# 2026-07-16 — Algs и спектральные оценки

- `uRecorderSpectrumEngine` и `uRecorderFrequencyBands` перенесены из `Core` в `Algs`; имена юнитов сохранены, пути обновлены в основном и тестовом `.lpi`.
- В `TRecorderSpectrumSettings` добавлены флаги расчёта СКЗ полосы, максимума, частоты максимума и записи результатов в теги.
- При выборе дочерней привязки спектра настройки становятся индивидуальными (`UseOwnSettings=True`); родительский узел по-прежнему задаёт наследуемые настройки.
- Runtime создаёт выходные теги только в `PrepareConfiguration`, затем публикует в них оценки на каждом готовом кадре.
- Соглашение имён: `<OutputPrefix>_<BandName>_rms|max|fmax`.
- Подробности: `Docs/spectrum-estimates.md`.
- Проверено: `TestSpectrumMath2.exe` — PASS; `lazbuild -B RecorderLnx.lpi` — exit 0.

# 2026-07-16 — фильтры выбранных каналов

- Над таблицей выбранных каналов добавлены флаги `Скрыть неактивные` и `Только виртуальные`.
- Флаги комбинируются между собой и с текстовым фильтром; меняется только отображение и row-map, реестр тегов не изменяется.
- Кнопка `X` очищает текстовый фильтр; изменение любого фильтра немедленно перестраивает таблицу.
- Полная сборка `RecorderLnx.lpi` завершилась с exit code 0.
# Исправления UI тегов и спектральных оценок (2026-07-16)

- В `TRecorderTag` добавлен сохраняемый признак `IsVirtual`. Он передаётся в конструктор/`CreateTag`; Mera, диагностика, тестовый программный сигнал и спектральные производные создают теги с `IsVirtual=True`, аппаратные — с `False`.
- UI и фильтр «Только виртуальные» читают только `TRecorderTag.IsVirtual`, без классификации по `SourceId`. JSON хранит `isVirtual`; для старых проектов без поля выполняется однократная совместимая миграция по известным legacy-источникам.
- CPU (`CpuUsage`) и память (`MemTag`) от `debug.diagnostics` включены в UI-классификацию виртуальных тегов: для них рисуется иконка 20 и они попадают под фильтр «Только виртуальные».
- В первой колонке выбранных каналов виртуальные теги теперь рисуются тем же механизмом, что и неактивные теги, но с индексом ImageList 20.
- Виртуальная иконка имеет приоритет над иконкой неактивного источника.
- Галочки расчёта спектральных оценок подключены к обновлению сериализованной конфигурации, поэтому «Применить» больше не восстанавливает старые значения.
- Подпись «Записывать в теги» заменена на «Создать теги».
- Исходники полностью компилируются; финальная линковка временно заблокирована удерживаемым процессом RecorderLnx.exe (Win32 error 5).
- 2026-07-16: исправлено создание тегов спектральных оценок непосредственно по внутренней и общей кнопкам «Применить». Диалог теперь сохраняет текущий узел, вызывает `SpectrumManager.PrepareConfiguration` и обновляет таблицы каналов. При полосах B01/B02 и трёх оценках создаётся по шесть виртуальных тегов на привязанный канал. Полная сборка RecorderLnx прошла с exit code 0.
- 2026-07-16: материализация тегов спектральных оценок сделана идемпотентной. Повторный Apply переиспользует тег по имени либо по паре `SourceId/Address`; отредактированное имя больше не приводит к созданию нового тега. Полная сборка RecorderLnx прошла с exit code 0.
- 2026-07-16: исправлено отображение созданных спектральных тегов после «Применить» → «Закрыть». Главный список теперь перестраивается после любого закрытия настроек; `RecorderTagSourceIsVisible` учитывает явный `IsVirtual` и больше не скрывает `spectrum:*` как неактивное оборудование. Полная сборка RecorderLnx прошла с exit code 0.
- 2026-07-16: исправлен статус MC-032 в дереве оборудования. Состояние
  `rdsStarted` снимает устаревшую offline-метку; TEST не внедряется в активную
  потоковую MDP-сессию. Сброс устройства теперь выполняет проверку и дает
  зеленый статус только при успехе, а hint показывает сохраненную ошибку без
  сетевых операций при наведении. Полная сборка RecorderLnx прошла с exit code 0.
- 2026-07-16: повторная трассировка MC-032 обнаружила рассинхронизацию lifecycle:
  штатный Stop сохранял запрограммированный сокет, но удалял live-регистрацию, а
  Restart ее не возвращал. Теперь успешный Start всегда регистрирует устройство,
  штатный Stop сохраняет регистрацию. Три последовательных аппаратных CLI-теста
  прошли; второй клиент при занятом RecorderLnx сокете закономерно получил timeout.
- 2026-07-16: исправлена привязка цифрового индикатора. Диалог настройки раньше
  менял только `TagName`, оставляя `TagId` от MemTag; синхронизация возвращала
  старый тег. Теперь имя и ID назначаются атомарно из выбранного `TRecorderTag`,
  для неразрешимого имени ID сбрасывается. Полная сборка прошла с exit code 0.
- 2026-07-16: исправлены границы полос спектральных оценок. Вместо `Round` используются `Ceil(F1/df)` и `Floor(F2/df)`, поэтому полоса от 10 Гц больше не включает бин 7,03125 Гц. Частота дискретизации и `df` теперь берутся отдельно для каждой привязки из `PollFrequencyHz` входного тега; один спектральный узел поддерживает каналы с разными Fs. `TestSpectrumMath2.exe` — PASS, полная сборка RecorderLnx — exit code 0.
- 2026-07-16: цифровой индикатор в автоматическом режиме переносит значение на вторую строку, если имя шире компонента. Добавлена рабочая опция «Не отображать имя». `ShowNameMode` теперь участвует в отрисовке и сохраняется/загружается из `.gui.ini`; применяются формат и шрифт компонента. Полная сборка RecorderLnx — exit code 0.
