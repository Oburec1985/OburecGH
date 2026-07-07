# MIC-140 debug stand — последнее состояние (2026-07-06)

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
