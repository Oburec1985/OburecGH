# MC-201 Protocol Debug Stand

## Symptom

Need an independent RecorderLnx-compatible test example for MC-201 modules via
MC-031/MC-032 controller at `192.169.12.87`.

## Context

The user wants protocol debugging isolated from existing RecorderLnx devices.
The original C++ example lives under `windev-v3.9\examples\mebius.daq`.

## Facts

- `medaq_mc_test.cpp` creates a `MICCRATE`, connects it through
  `BUSID_ETHERNET81_TCP`, gets `BUSID_MC`, then calls `SearchDevices`.
- Original MC-031 Ethernet path uses legacy MDP/TCP command packets for
  `CMD_REPLY` and memory/flash reads.
- `AutoSearchModule` reads slot flash offset `0` as module type and matches
  MC-201 by type `201` plus version-code offset `1`.

## Actions

- Added standalone Lazarus console project
  `Tests\RecorderTests\Mc201ProtocolDebug`.
- Implemented a minimal legacy MDP TCP client and read-only slot flash scanner.
- Kept the example independent from RecorderLnx device units.
- Merged GUI and CLI into the single `Mc201ProtocolDebug.lpi` project. GUI is
  the default application mode; CLI starts explicitly through
  `Mc201ProtocolDebug.exe --cli ...`. The separate
  `Mc032ProtocolDebugGui.lpi/.lpr` project and stale GUI exe artifacts were
  removed.
- Added all test units to the `.lpi` so Lazarus Project Inspector shows the
  form, device class, MDP client, runner and protocol types.
- The shared GUI path has `TMc032Device` with states `Disconnected`,
  `Connected`, `Play`, a read thread, controller actions, and a raw-word
  oscilloscope callback.
- `Config` currently stores `TMc032Config`, updates the read timeout and sends
  `CMD_RESETSCANMAIN`. Full MC-201 scan descriptor programming still requires
  porting the original `CMD_ADDCHANNELMODULE` / `CMD_SCAN_SET_CHANS` flow.

## Current Conclusion

The first diagnostic stand is suitable for live protocol checks and raw stream
capture without touching RecorderLnx device implementations.
If a controller firmware requires the newer Mebius `IOCTL_CMD_SEARCH_DEVICE_*`
path instead of direct legacy flash reads, add that as a second client without
touching existing RecorderLnx device implementations.

## Codex continuation 2026-07-14: GUI freezes on Config

**Prompt:** User reported that the MC-201 debug GUI hangs after pressing
`Connect`, `Modules`, `Config`.

**Finding:** `TMc032DebugForm.ButtonConfig` called `TMc032Device.Config`
directly from the LCL main thread. After MC-201 BIOS loading was added for each
slot, this operation can take about 20 seconds, so the window stops repainting
and looks frozen even though the protocol call is still running.

**Fix:** Added `TMc032ConfigThread` in `uMc032DebugForm.pas`. The GUI now starts
Config in a worker thread, sets a local busy state, disables device action
buttons while configuration is running, logs start/completion, and blocks normal
window close until the worker finishes.

**Verification:** Rebuilt
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
with `C:\lazarus\lazbuild.exe -B`; exit code 0.

## Codex continuation 2026-07-14: Config still does not return

**Prompt:** User reported that the GUI froze again after pressing `Config`.

**Finding:** The previous GUI-thread fix made the form responsive in principle,
but `TMc201LegacyMdpClient.CallCommand` could still wait forever for a command
reply. If the controller was already producing scan stream packets,
`CallCommand` kept reading and discarding non-command-port packets without an
overall deadline, so `Config` never completed and the GUI stayed in busy state.

**Fix:** Added an overall command-reply timeout to
`TMc201LegacyMdpClient.CallCommand`. Non-command packets are still skipped, but
if no command reply appears before `TimeoutMs`, the function returns
`MDP command reply timeout` instead of spinning forever. Added a GUI busy
heartbeat timer so the status line updates while Config is running.

**Verification:** Rebuilt
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
with exit code 0. Live CLI run:
`Mc201ProtocolDebug.exe --cli --play-diagnostic-ms=3000 --host=192.169.12.87 --port=4000 --timeout-ms=1200 --slots=4`
completed with `Config OK`, `STARTSCANMAIN OK`, `STOPSCANMAIN OK`,
`PLAY messages=35`, and `RESULT Mc201PlayDiagnostic passed`.

## Codex continuation 2026-07-14: GUI-specific Config hang

**Prompt:** User reproduced the same sequence in GUI:
`Connect -> Modules -> Config`; the status line kept updating
`Config running`, but Config did not finish.

**Finding:** CLI passed because connect/modules/config all used the same thread.
The GUI version created the TCP client in the LCL thread during `Connect` and
then used that same socket object from a worker thread during `Config`. This
made the GUI behavior differ from the working CLI path and could leave Config
stuck before the new progress logs appeared.

**Fix:** Removed the GUI Config worker. `ButtonConfig` now runs
`TMc032Device.Config` in the same thread that created the connection, but device
programming emits progress callbacks before each controller/module command.
The form logs `Config step: ...`, updates the status label, and calls
`Application.ProcessMessages` between commands so the window remains alive.
The unused `TMc032ConfigThread` class was removed.

**Verification:** Rebuilt
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
with exit code 0. Live CLI run of the same sequential device path against
`192.169.12.87:4000` completed with `Config OK`, `STARTSCANMAIN OK`,
`STOPSCANMAIN OK`, `PLAY messages=35`, and
`RESULT Mc201PlayDiagnostic passed`.

## Codex continuation 2026-07-14: Play button disabled in disconnected state

**Prompt:** User reported that the GUI `Play` button is disabled and cannot be
pressed. Screenshot showed `State: Disconnected`, where the old button-state
logic intentionally disabled Play.

**Fix:** `Play` is now a top-level action in the debug GUI. The button is
enabled whenever the device is not already in `Play` state. If pressed while
disconnected, it applies host/port/timeout settings and auto-connects. If no
MC-201 scan program exists yet, it runs the same visible Config path first and
then starts acquisition.

**Verification:** Rebuilt
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
with exit code 0. Live CLI diagnostic against `192.169.12.87:4000` still
completed with `Config OK`, `STARTSCANMAIN OK`, `STOPSCANMAIN OK`, and
`RESULT Mc201PlayDiagnostic passed`.

## Codex continuation 2026-07-14: Play gives one packet, then stop/reset errors

**Prompt:** User reported that after pressing `Play` some data arrives and then
the stream stops; repeated `Play` or `Reset` often causes an error such as
`MDP TCP write failed`.

**Findings:**
- Two consecutive live CLI runs no longer reproduced `MDP TCP write failed`
  after the Stop path was changed to wait for `CMD_STOPSCANMAIN` and force a
  disconnect on Stop timeout. This prevents later commands from writing to a
  half-dead socket.
- Current scan programming still does not meet acceptance. At `57600 Hz` and
  `200 ms` update expectation the stand should receive about 5 update packets
  per second. The live run produced exactly one stream packet and then read
  timeouts:
  `RX packet port=0 words=26 head=[0 26 0 1 0x78F1 0 50 315 1 0x0000]`,
  followed by `STOPSCANMAIN failed: MDP command timeout`.
- Original `devapi/Types.h` confirms `THeaderMessage` is 10 WORD:
  `type,size,scan_id,slot,chan,time_hi,time_lo,time_cnt,num_buff,state`.
  Original `ScanMC201::Decommutation` compares
  `module->final_flag[chan] == header->chan` without masking.
- The debug stand was masking `0x4000` from both the expected final flag and
  the packet header channel, so a valid `0x78F1` packet was displayed/logged as
  if it did not belong to the selected channel.
- After adding a full first-packet dump, the controller stopped accepting TCP
  connects from the test environment:
  `Connection to 192.169.12.87:4000 timed out`. This prevents continuing the
  live iteration until the port is released or the controller is reset.

**Fixes in this iteration:**
- `TMc201PlayStats` and the GUI oscilloscope now compare the full MC-201
  `final_flag` / `header.chan`, preserving the `IS_DM` bit (`0x4000`).
- CLI `--play-diagnostic-ms` now dumps all words of the first stream packet,
  so future runs can verify header layout and payload without attaching a
  debugger.
- CLI diagnostic no longer reports success for a single packet. It now requires
  `STOPSCANMAIN OK` and at least `duration / 200 ms` stream messages.

**Verification:**
- `C:\lazarus\lazbuild.exe -B
  D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
  completed with exit code 0 after the final changes.
- Live check after the stricter diagnostic could not proceed because the
  controller TCP port timed out on connect. Last successful live protocol state
  before that was still one 26-word packet and `STOPSCANMAIN` timeout.

**Remaining work:**
- Re-run the live CLI diagnostic after the controller is released/reset.
- If the first packet dump still shows one packet only, continue comparing
  `ScanMC201::Programming`, `ModuleMC201::Programming`, and
  `CTriggerStartScan/ADC` order. Current leading suspicion is still scan start
  context/programming, not GUI painting or packet header size.

## Codex continuation 2026-07-14: GUI Connect stops in TInetSocket.Create

**Prompt:** User reported that pressing GUI `Connect` stops/falls at
`TMc201LegacyMdpClient.Connect`, line creating `TInetSocket`.

**Finding:** `TInetSocket.Create(host, port, timeout)` performs the TCP connect
inside the constructor and raises on timeout/refused connection. The GUI button
caught the final exception, but `TMc032Device.Connect` re-raised it after
cleanup, so Lazarus/debugger stopped on the expected connection failure path.

**Fix:** Added `TMc032Device.TryConnect(out AErrorMessage): Boolean`, which
cleans up failed sockets and keeps state `Disconnected` without re-raising.
The GUI `Connect` button and `Play` auto-connect now use `TryConnect` and log
`Connect: <error>` / `Play auto-connect: <error>` instead of propagating the
exception through the form action.

**Verification:** Closed the stale Lazarus debug session that held
`Mc201ProtocolDebug.exe`, rebuilt `Mc201ProtocolDebug.lpi` with exit code 0,
then launched the GUI and clicked the real `Connect` button via UI Automation /
mouse coordinates. The GUI did not crash or leave the exception path; it logged:
`Connect request host=192.169.12.87 port=4000 timeout=1200`, then
`Connect: Connection to 192.169.12.87:4000 timed out.`

## Codex continuation 2026-07-14: Connect regression from form creation

**Prompt:** User asked for a unit/regression test that calls the same function
from form creation instead of pressing the `Connect` button.

**Fix:** Extracted the GUI connect button body into
`TMc032DebugForm.RunConnectAction`. Added the
`--gui-connect-on-create-test` executable mode: it creates the LCL form, enables
the form-creation connect hook, runs the same connect action, prints
`RESULT Mc201GuiConnectOnCreate ...`, and exits without showing/running the GUI.

**Verification:** Rebuilt
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
with exit code 0. Ran
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe --gui-connect-on-create-test`;
it returned exit code 0 and printed
`RESULT Mc201GuiConnectOnCreate passed: Connect: Connection to 192.169.12.87:4000 timed out.`

## Codex continuation 2026-07-14: Search also stops at TInetSocket.Create

**Prompt:** User reported that even the GUI `Search` button stops at
`TMc201LegacyMdpClient.Connect`, which previously did not happen.

**Finding:** `Search` delegates to `TestConnection`, and `TestConnection`
opened the same MDP TCP client as `Connect`. When the controller TCP port is
not accepting connections, `TInetSocket.Create` raises `ESocketError` from its
constructor. Lazarus debugger can stop on that handled exception before the GUI
catch block converts it to a normal "not found/timeout" result. Earlier this
was less visible while the port answered quickly.

**Fix:** Removed `TInetSocket.Create` from the normal GUI connection path.
`TMc201LegacyMdpClient` now has `TryConnect(out error)`, implemented with a
non-throwing nonblocking socket open and timeout. `TMc032Device.TryConnect` and
`TestConnection` use it, so GUI `Connect`, `Play` auto-connect, `Test`, and
`Search` receive timeout/refused connection as text instead of an exception.
The old `Connect` method remains for CLI/internal paths that still want an
exception on failure.

**Verification:** Rebuilt
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`
with exit code 0. Ran
`D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe --gui-connect-on-create-test`;
it returned exit code 0 and printed
`RESULT Mc201GuiConnectOnCreate passed: Connect: Connection to 192.169.12.87:4000 timed out.`
