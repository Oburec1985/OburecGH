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
The source can send start/stop scan commands, write ADSP DM memory, and can read
stream `0` packets. RecorderLnx now contains the first 48-channel scan
programming path: reset/config main scan, append MIC-140 scan, create FIFO
descriptor, create ground/channel descriptor tables, add module channels, and
bind them to the scan.

## Original Recorder sources

The legacy MIC-140 implementation is spread across these original Recorder files:

- `D:\works\windev-v3.9\mtcEthernet81\Mc031ethernetifc.cpp`
  opens the TCP transport, default port `4000`, reads BIOS info by `CMD_REPLY`,
  and wraps DM/PM memory reads and writes.
- `D:\works\windev-v3.9\mdpEthernet81\mdpEthernet81.cpp`
  implements packet framing, stream demultiplexing, and `CallCommand`.
- `D:\works\windev-v3.9\include\VTBL.H`
  defines low-level/common commands such as `CMD_START_SCAN_MAIN = 4`,
  `CMD_STOP_SCAN_MAIN = 5`, `CMD_REPLY = 113`, `CMD_RESET = 125`.
- `D:\works\windev-v3.9\mtc\Ccdevice.h`
  defines CC BIOS scan commands such as `CMD_STARTSCANMAIN = 80`,
  `CMD_STOPSCANMAIN = 81`, `CMD_APPENDSCANMAIN = 82`,
  `CMD_SETSTATESCAN = 87`, `CMD_SCAN_SET_BUFF = 133`,
  `CMD_SCAN_SET_CHANS = 132`, `CMD_ADDCHANNELMODULE = 152`, and ADSP DM memory
  write `CMD_WRITEDM = 111`.
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

Original `mdpEthernet81::ProcessProtocol()` parses the TCP byte stream with
resynchronization. If a candidate packet has a bad sync word, bad header
checksum, or bad data checksum, it advances the raw input by one byte and tries
again. It does not drop the whole candidate packet. RecorderLnx must do the same
because stream `0` packets can be frequent; losing byte alignment after a single
checksum mismatch can make all following packets look broken and leave the
device scanning without a healthy reader.

Original `mdpEthernet81` also demultiplexes streams into separate FIFOs:
`m_ScanFifo` for stream `0` and `m_CommandFifo` for stream `1`. RecorderLnx reads
directly from one TCP socket, so `CallCommand()` must skip stream-`0` packets
while waiting for the stream-`1` reply. This matters especially for stop commands
sent while acquisition is already running.

RecorderLnx no longer sends `CMD_STOPSCANMAIN = 81` from inside `ReadBlock()` on
ordinary stream-`0` read timeouts. A live MIC-140 can still be sending scan
packets while the application side has a short read timeout, and calling a
command through the same TCP stream at that moment may make diagnostics worse.
Stop is sent only from the explicit source stop/disconnect path.

The legacy reader logs the first successful stream-`0` scan packet with header
word count, data word count, and the first five header words. This is used while
matching RecorderLnx parsing to original `THeaderMessage` handling in
`MIC140_96_rce\mic140_96scn.cpp`.

The current direct legacy reader is intentionally conservative about sampling
frequency. Original `mdpEthernet81` has a permanent RX thread and separate scan
and command FIFOs. RecorderLnx still reads the TCP stream synchronously from the
data-source thread, so frequencies above `1000 Hz` are clamped to the default
`100 Hz` for now to avoid overrunning the single reader while the protocol port
is being stabilized.

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

Important distinction: `VTBL.H` also has similarly named commands, but the
MIC-140 scan path goes through `Ccdevice.h` CC BIOS commands. For example,
`VTBL.H` has `CMD_WRITEDM = 16`, while
`CCMC031EthernetInterface::WriteRemoteWordArray(... IS_DM ...)` reaches
`Ccdevice.h` `CMD_WRITEDM = 111`. Using `16` for the scan FIFO/descriptor writes
makes the device time out. The same applies to main scan start/stop: original
`CCDevice::OnStartScanMain()` / `OnStopScanMain()` use `CMD_STARTSCANMAIN = 80`
and `CMD_STOPSCANMAIN = 81`, not `VTBL.H` commands `4/5`.

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

Additional live check before the scan table was ported:

```text
VTBL.H CMD_START_SCAN_MAIN = 4, request words: 4, 0, 1
reply stream=1 size=1 words=1
```

After this command the device did not send a stream `0` packet within the test
timeout. `CMD_STOP_SCAN_MAIN = 5` still answered on stream `1`. This confirmed
that command transport works, but this is not the CC BIOS scan start path used by
original Recorder for MIC-140.

RecorderLnx log after the first scan-programming implementation showed:

```text
Legacy Ethernet protocol detected: device=16703.270 serial=155 controller=16702 serial=164 BIOS=183.1
Legacy MIC-140 scan programming failed: FIFO descriptor DM write failed: MIC-140 legacy command timeout
```

That failure happened while `CMD_WRITEDM` was still incorrectly set to `16`.
The command has been corrected to `111`.

## Scan programming sequence

Original `ScanMIC140::ChannelsToBios()` performs the important setup before scan
start:

1. `ScanModule::CreateInternalScan()` calls `CMD_APPENDSCANMAIN = 82`.
2. `ScanModule::SetStateInternalScan()` calls `CMD_SETSTATESCAN = 87`.
3. `ScanModule::CreateBiosCCScanBuf()` allocates the BIOS scan buffer and calls
   `CMD_SCAN_SET_BUFF = 133`.
4. `ScanMIC140::ChannelsToBios()` allocates internal memory for instant channel
   values.
5. Allocates internal memory for channel descriptors.
6. Calls the selected module implementation, for example
   `ModuleMIC140_48::PrepareModuleDescForScan()` or
   `ModuleMIC140_96::PrepareModuleDescForScan()`.
7. Writes the descriptor array to ADSP DM memory through `WriteRemoteWordArray`.
8. Calls `CMD_ADDCHANNELMODULE = 152`.
9. Calls `CMD_SCAN_SET_CHANS = 132`.

Only after this descriptor path is complete does it make sense to start the scan
and read stream `0`. Sending only a start command without descriptors does not
match original Recorder behavior.

RecorderLnx 48-channel path currently follows this concrete sequence:

1. `CMD_RESETSCANMAIN = 83`.
2. `CMD_CONFIGSCANMAIN = 84` with `scale-1 = 0`, `period-1 = 639`
   (`scale=1`, `period=640` for the 16 MHz MIC-140 grid).
3. Allocate BIOS scan context from DM heap `0x0800..0x2BFF`.
4. `CMD_APPENDSCANMAIN = 82` with `TYPE_MIC140 = 12`, `scan_id = 0`.
5. `CMD_SETSTATESCAN = 87`, state `0`.
6. Allocate scan FIFO from DM buffer `0x0000..0x07FF`.
7. Write the 10-word BIOS FIFO descriptor to DM using `CMD_WRITEDM = 111`.
8. `CMD_SCAN_SET_BUFF = 133`.
9. Allocate instant-value cells and `TDescChanBios_MIC140_96` descriptors.
10. Build a ground descriptor plus one descriptor for each selected AIN channel.
11. Write descriptor array and channel-pointer array to DM.
12. `CMD_ADDCHANNELMODULE = 152`.
13. `CMD_SCAN_SET_CHANS = 132`.

## Current RecorderLnx implementation notes

`TRecorderMic140LegacyClient` currently supports:

- TCP connect/disconnect.
- Packet send/read with header and data checksums.
- Byte-stream resynchronization after broken packet candidates.
- `CallCommand`.
- `ReadFirmware` using `CMD_REPLY`.
- `WriteDmWords` using CC BIOS `CMD_WRITEDM = 111`.
- `StartScan` / `StopScan` using CC BIOS commands `80/81`.
- `ReadScanBlock` from stream `0`.

Current assumptions in `TRecorderMic140Device.ProgramLegacyDevice`:

- 48-channel execution only.
- Analog input channels only; temperature compensation channels are not yet
  inserted into the scan stream.
- Ground channel is enabled and inserted before each analog channel, matching
  `ModuleMIC140_48::PrepareModuleDescForScan()`.
- Timing constants are the original defaults: average delay derived from
  `period_aver=5 us`, channel delay from `period_decay=57 us`, and the minimum
  ground delay from `CalcMinPeriodDecay()`.

Next porting steps for full parity:

- Re-test the corrected `CMD_WRITEDM = 111` path on the reset device.
- Compare stream `0` packet layout with original `ScanMIC140::Decommutation()`.
- Add the 96-channel and v2/v5 descriptor variants.
- Port temperature-compensation channel settings and CJC table behavior.
- Replace hard-coded default timing values with the original auto-calculation
  model driven by selected frequency, averaging count, and commutation settings.
