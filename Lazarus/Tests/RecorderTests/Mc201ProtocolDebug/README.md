# MC-201 Protocol Debug

Standalone console and GUI example for MC-031/MC-032 + MC-201 protocol checks.

Sources used:
- `D:\works\windev-v3.9\examples\mebius.daq\tests\medaq_mc_test\src\medaq_mc_test.cpp`
- `D:\works\windev-v3.9\mtcEthernet81\Mc031ethernetifc.cpp`
- `D:\works\windev-v3.9\mtc\CCDEVAPI.CPP`
- `D:\works\windev-v3.9\mtc\Ccdevice.h`
- `D:\works\windev-v3.9\mtc\Ccdevice.cpp`
- `D:\works\windev-v3.9\mtc\cc81ifc.cpp`
- `D:\works\windev-v3.9\mtc\Mc201.cpp`
- `D:\works\windev-v3.9\mtc\Module.cpp`

The test does not use RecorderLnx device units. It opens the legacy MC-031/032
MDP TCP command stream, reads controller `CMD_REPLY`, then scans module flash
slots:

- flash offset `0`: module type
- flash offset `1`: MC-201 version discriminator
- flash offsets `61/62`: serial number

Default target:

```powershell
C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe
```

Expected live stand: four-slot controller with four MC-201 modules:
slot 1 `01462`, slot 2 `01465`, slot 3 `01464`, slot 4 `01463`.

Detailed stand notes are stored in:
`D:\works\OburecGH\Lazarus\RecorderLnx\Docs\devices\mc\mc201.md`.

CLI mode uses the same project and executable:

```powershell
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe --cli --host=192.169.12.87 --port=4000 --slots=16
```

GUI connect-on-create regression test:

```powershell
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe --gui-connect-on-create-test
```

This creates the GUI form, calls the same connect action from the form creation
path, prints `RESULT Mc201GuiConnectOnCreate ...`, and exits without
`Application.Run`.

`TMc032Device` supports:
- `Search`: probes the configured host/port with `TEST_LOAD`.
- `TestConnection`: sends `CMD_TEST_LOAD`.
- `SearchModules`: scans module flash for non-empty slots.
- `Connect` / `Disconnect`: open and close MDP TCP stream.
- `Reset`: sends controller `CMD_RESET`.
- `Config`: stores `TMc032Config`, applies read timeout and sends
  the Recorder-like MC-201 scan programming sequence: `CMD_RESETSCANMAIN`,
  `CMD_CONFIGSCANMAIN(scale=1, period=640)` for the CC81 Ethernet timing base,
  module IDMA descriptors, module channel chains, `GET_FINAL_FLAG_CC`,
  `CMD_APPENDSCANMAIN`, `CMD_ADDCHANNELMODULE`, `CMD_SCAN_SET_CHANS`, ADC start
  trigger list and `CMD_START_TRIGGERSTARTADC`.
- `Play` / `Stop`: sends `CMD_STARTSCANMAIN` / `CMD_STOPSCANMAIN` and starts a
  read thread. Raw stream packets are delivered through `TMc032DataCallback`;
  the GUI callback draws a simple raw-word oscilloscope.

Acceptance check:

```powershell
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe --cli --acceptance-ms=5000 --update-ms=200 --timeout-ms=1200 --connect-attempts=3 --connect-retry-ms=1000 --slots=4
```

The CLI aggregates raw Ethernet stream frames into 200 ms update blocks. On the
current stand at `57600 Hz`, the expected 5-second result is `25` update blocks;
raw frame sizes are normally around `266`, `532`, and `798` words.

## Implementation Notes

The source files contain comments around the protocol traps found during live
debugging:

- `uMc201ProtocolTypes.pas`: live-stand defaults, MDP packet size versus
  command argument size, and the 26-word IDMA chunk limit.
- `uMc201LegacyMdpClient.pas`: non-throwing GUI TCP connect, IDMA PM address
  chunking, and per-client MC-201 BIOS cache.
- `uMc032Device.pas`: original-like scan programming order and the single
  reset/reconnect retry used by `Config`.
- `Mc201ProtocolDebug.lpr`: `--gui-connect-on-create-test`, which invokes the
  same form connect action as the GUI button.

Do not replace the 26-word IDMA chunk with the raw packet maximum. A raw MDP
packet can carry more data, but original `mdpEthernet81` command calls are
limited to 32 argument words. Live testing showed that 1016-word chunks time out
and 27-word PM chunks misalign the next PM address; 26-word chunks pass.

Repeated GUI `Config` in one TCP session is faster because successfully loaded
BIOS slots are cached in `TMc201LegacyMdpClient`. The cache is not persisted and
is not shared across reconnects; a fresh TCP client reloads the module BIOS for
safety.
