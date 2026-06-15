# MIC-140 Ethernet protocol

## Status in RecorderLnx

RecorderLnx has two protocol layers for MIC-140:

- `Core/uRecorderMebiusTcpProtocol.pas` - Mebius/MEAS task protocol used by newer
  MIC140MDQ code.
- `Core/uRecorderMic140LegacyProtocol.pas` - legacy Ethernet protocol used by the
  48/96-channel MIC-140 hardware from original Recorder.

The 48-channel device at `192.168.14.155:4000` answered the legacy protocol and
did not answer Mebius packets. The source `Core/uRecorderMic140DataSource.pas`
therefore probes the legacy protocol first. If `CMD_REPLY` succeeds, the source
logs firmware/controller information and does not continue with the Mebius
programming path.

At this point the low-level legacy command exchange is implemented and compiled.
Full scan streaming still requires porting the original scan descriptor
programming from `ScanMIC140::ChannelsToBios()` and module descriptor builders.

## Original Recorder sources

The legacy MIC-140 implementation is spread across these original Recorder files:

- `D:\works\windev-v3.9\mtcEthernet81\Mc031ethernetifc.cpp`
  opens the TCP transport, default port `4000`, reads BIOS info by `CMD_REPLY`,
  and wraps DM/PM memory reads and writes.
- `D:\works\windev-v3.9\mdpEthernet81\mdpEthernet81.cpp`
  implements packet framing, stream demultiplexing, and `CallCommand`.
- `D:\works\windev-v3.9\mdprotocol\2181Items.h`
  defines ADSP memory commands such as `CMD_WRITEMEMDM = 111`,
  `CMD_READMEMDM = 114`, `CMD_WRITEMEMPM = 112`, `CMD_READMEMPM = 115`.
- `D:\works\windev-v3.9\include\VTBL.H`
  defines common BIOS commands such as `CMD_START_SCAN_MAIN = 4`,
  `CMD_STOP_SCAN_MAIN = 5`, `CMD_REPLY = 113`, `CMD_RESET = 125`.
- `D:\works\windev-v3.9\MIC140_96_rce\mic140_96scn.cpp`
  builds and sends the scan channel table to BIOS.
- `D:\works\windev-v3.9\MIC140_96_rce\MIC140_48mod.cpp`,
  `MIC140_48v2mod.cpp`, `mic140_96mod.cpp`, `MIC140_96v2mod.cpp`
  build module-specific channel descriptors for 48/96-channel hardware.

## Transport packet

The old MIC-140 Ethernet transport is little-endian TCP. One TCP connection is
opened to the device, normally on port `4000`.

Every packet has an 8-byte header followed by `size` data words and one data
checksum word:

```text
WORD syn       = 0x12B8
WORD port      = stream id
WORD size      = number of data words
WORD cs        = (syn + port + size) & 0xFFFF
WORD data[size]
WORD data_cs   = sum(data[0..size-1]) & 0xFFFF
```

Known streams:

- `0` - scan/data stream.
- `1` - command stream used by `CallCommand`.

## Command packet

Commands are sent on stream `1`. The command payload starts with three words:

```text
WORD cmd
WORD argc      = number of argument words
WORD retc      = expected number of reply words
WORD argv[argc]
```

Original `mdpEthernet81::CallCommand()` treats `retc = 0` as one reply word, so
RecorderLnx does the same in the legacy client.

The reply is a normal stream-`1` packet whose data words are the command result.
For `CMD_REPLY` the original code reads the BIOS/controller information into the
MC031 BIOS info structure.

## Verified exchange with the device

The live device at `192.168.14.155:4000` answered `CMD_REPLY = 113` with the
legacy framing.

Request data words:

```text
113, 0, 10
```

Response bytes:

```text
B8 12 01 00 0A 00 C3 12 F0 01 27 41 3F 41 0E 01
9B 00 3E 41 A4 00 BF 00 B7 00 01 00 58 C9
```

Parsed header:

```text
syn  = 0x12B8
port = 1
size = 10 words
cs   = 0x12C3
```

Parsed data words:

```text
0x01F0, 0x4127, 0x413F, 0x010E, 0x009B,
0x413E, 0x00A4, 0x00BF, 0x00B7, 0x0001
```

This proves that the physical MIC-140 uses the old MC031/mdpEthernet81 transport,
not the Mebius `MEBE_PACKET` transport.

## Scan programming sequence

Original `ScanMIC140::ChannelsToBios()` performs the important setup before scan
start:

1. Allocates internal memory for instant channel values.
2. Allocates internal memory for channel descriptors.
3. Calls the selected module implementation, for example
   `ModuleMIC140_48::PrepareModuleDescForScan()` or
   `ModuleMIC140_96::PrepareModuleDescForScan()`.
4. Writes the descriptor array to ADSP DM memory through `WriteRemoteWordArray`.
5. Calls `CMD_ADDCHANNELMODULE`.
6. Calls `CMD_SCAN_SET_CHANS`.

Only after this descriptor path is complete does it make sense to start the scan
and read stream `0`. Sending only a start command without descriptors does not
match original Recorder behavior.

## Current RecorderLnx implementation notes

`TRecorderMic140LegacyClient` currently supports:

- TCP connect/disconnect.
- Packet send/read with header and data checksums.
- `CallCommand`.
- `ReadFirmware` using `CMD_REPLY`.

Next porting steps for real samples:

- Add DM/PM memory helpers equivalent to `ReadRemoteWordArray` and
  `WriteRemoteWordArray`.
- Port the 48/96-channel descriptor builders from the original module files.
- Port the frequency/averaging/commutation tables into a single MIC-140 settings
  model.
- Implement scan stream reading from stream `0` and decommutation into
  RecorderLnx tag blocks.
