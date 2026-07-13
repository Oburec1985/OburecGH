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
