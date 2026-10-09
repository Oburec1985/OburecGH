# MX-248 DevAPI bridge (Win32)

The bridge is a Delphi Win32 console helper for a Win64 RecorderLnx client. It
uses inherited stdin/stdout pipes and loads the original Win32 `DevAPI.dll`.

## IPC v1

All integers are little-endian. Every frame starts with this packed 16-byte
header: `magic:u32=0x42383432, version:u16=1, command:u16, requestId:u32,
payloadSize:u32`. Payload size is limited to 1 MiB.

A response retains request command/id. Its payload is `code:u32`, then three
length-prefixed values: `stageLength:u32 + stage:UTF-8`, `textLength:u32 +
text:UTF-8`, and `dataLength:u32 + data:bytes`.

Stable command payloads:

| command | request data | successful response `data` |
|---|---|---|
| `DISCOVER` (10) | empty | UTF-8 `index,serial,revision,name,CCType,CCSN,SlotNo` entries separated by `;` |
| `CONNECT` (11) | production `CCSN:i32,SlotNo:i32`; legacy `deviceIndex:i32` | empty |
| `CONFIGURE` (14) | fixed 80-byte `ConfigureV1` below | empty |
| `START` (15), `STOP` (16), `DISCONNECT` (18) | empty | empty |
| `READ_BLOCK` (17) | `requestedSamples:i32` | self-describing block below |

`ConfigureV1` is packed and uses an IEEE-754 binary64 rate:

```text
sampleRateHz:f64
blockSamples:u32                 # 1..262144
calibrationMode:u8               # 0..2, vendor global mode
reserved:u8[3]                   # must be zero
channel[8]:
  enabled:u8                     # boolean
  amplifierEnabled:u8            # boolean
  inputMode:u8
  rangeIndex:u8
  lpfIndex:u8
  icpCurrent:u8                  # 0=off, 1=4 mA, 2=10 mA
  calibrationEnabled:u8          # boolean
  inputFloating:u8               # boolean
```

The rate must match one of the rates enumerated by DevAPI (absolute tolerance
`max(1e-6, rate*1e-9)`). For an MC-bus/PXI route, UI `chassis` means controller
serial `CCSN`, not discovery index. Production uses the 8-byte route selector;
the 4-byte index selector is explicitly legacy.

The read response is channel-major. `sampleType=4` is Windows `VT_R4` and means
IEEE-754 little-endian float32:

```text
channelCount:u32
repeat channelCount times:
  logicalChannel:u32, sampleType:u32, sampleCount:u32,
  samples:f32[sampleCount]
```

## Proven original mappings

`DevAPI/Tools.cpp` establishes channel enumeration via `CHAN_CNT_DEV`,
`CollectChanID`, `GetChannel`, block sizing with `PROP_CHAN_T_BLOCK`, and reads
via `Lock`/two ring segments/`Unlock`. Lock sizes and block size are sample
counts; `PROP_CHAN_WORDLENGTH` supplies sample width. Each used channel ID is
matched back to the eight available AIn IDs, preserving logical indices 1..8
when channels are disabled. `mx224v14ain.cpp` fixes acquisition output to
`sizeof(float)` / `VT_R4`; the bridge refuses any other type or width.

Configuration follows the original virtual properties:

- rate: enumerate `PROP_CHAN_FREQ_COUNT`, read indexed `PROP_CHAN_FREQ`, then
  write the selected frequency **index** with `SetPropertyL`;
- main input: `PROP_CHAN_ON`, `PROP_CHAN_T_BLOCK`, `PROP_ICP`;
- amplifier handle: `PROP_AMPLIFIER` (`0x5058`, confirmed by the C++ probe);
- amplifier: `PROP_CHAN_ON`, `PROP_INPUT_MODE`, `INDEX_RANGE_CHAN`,
  `PROP_LPF_CHAN`, `PROP_CALIBRATION`, `PROP_CHAN_FLOAT`.

`mx248amp.cpp` proves calibration is zero when disabled or global mode plus one
when enabled. `MeasChannel.cpp` routes range and LPF indices to
`SetAInRangeIndex`/`SetLpfIndex`. Properties are applied before
`Config`/`Programming`; used inputs are rebound afterwards.

The Win32 ABI probe against original headers proves pointer size 4,
`TLocation=140`, `TDeviceRoute=144`, `TDevice=1196`, `TDeviceEnum=132760`.
The Delphi adapter asserts these sizes at startup.

```text
dcc32 -B -E. PxiMx248Bridge.dpr
cd Tests
dcc32 -B -E. PxiMx248BridgeProtocolTest.dpr
PxiMx248BridgeProtocolTest.exe
```

Set `RECORDER_MX248_VENDOR_DIR` to the installed DevAPI/device DLL directory.
DevAPI `SearchDevices` runs its own allow-listed DLL registration through
`InitDLLs("*.dll")`. Tests do not perform hardware discovery.
