# MC-201 Protocol Debug

Standalone console and GUI example for MC-031/MC-032 + MC-201 protocol checks.

Sources used:
- `D:\works\windev-v3.9\examples\mebius.daq\tests\medaq_mc_test\src\medaq_mc_test.cpp`
- `D:\works\windev-v3.9\mtcEthernet81\Mc031ethernetifc.cpp`
- `D:\works\windev-v3.9\mtc\CCDEVAPI.CPP`
- `D:\works\windev-v3.9\mtc\Ccdevice.h`
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

`TMc032Device` supports:
- `Search`: probes the configured host/port with `TEST_LOAD`.
- `TestConnection`: sends `CMD_TEST_LOAD`.
- `SearchModules`: scans module flash for non-empty slots.
- `Connect` / `Disconnect`: open and close MDP TCP stream.
- `Reset`: sends controller `CMD_RESET`.
- `Config`: stores `TMc032Config`, applies read timeout and sends
  `CMD_RESETSCANMAIN`. Full MC-201 scan descriptor programming still requires
  porting the original `CMD_ADDCHANNELMODULE` / `CMD_SCAN_SET_CHANS` path.
- `Play` / `Stop`: sends `CMD_STARTSCANMAIN` / `CMD_STOPSCANMAIN` and starts a
  read thread. Raw stream packets are delivered through `TMc032DataCallback`;
  the GUI callback draws a simple raw-word oscilloscope.
