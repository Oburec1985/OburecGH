# MIC185 recording undercount at 10 Hz

## Symptom

At MIC183/185 `Fs=10 Hz`, a 3 second recording produced about 13 values
instead of the expected 30 values.

## Context

- Production source: `Device/mic185/uRecorderMic185DataSource.pas`.
- Production TCP protocol: `Device/mic185/uMic185MebiusTcpProtocol.pas`.
- MIC185 settings currently program measurement channel `BlockSize = 1`, so
  the device can send one measurement sample per TCP data packet.
- RecorderLnx data update is normally about 200 ms, so reading only one
  one-sample packet per tick gives about 15 samples in 3 seconds, matching the
  observed undercount.

## Facts

- `ReadMeasDataBlock` drained up to 32 packets, but for `dev_id=1` it assigned
  `ABlock := lPending`, replacing the previously parsed measurement block.
- Therefore all earlier measurement packets read during the same drain cycle
  were discarded before reaching the tag ring buffer or recording writer.
- `Core/uRecorderTags.pas` uses a ring buffer (`fStart`, `fCount`,
  `fCapacity`) and uses `Move` for last-block copies and already transformed
  `Double` blocks.

## Actions

- Changed `ReadMeasDataBlock` to append every parsed measurement packet into
  the returned block instead of keeping only the last one.
- Added `AppendMebiusFloatBlock`, which grows per-channel `Single` arrays and
  uses `Move` for block copies.
- Kept temperature and UTS packets as side-cache data, as before.
- Built `RecorderLnx.lpi` with `lazbuild -B`: exit code 0.
- Follow-up: Stop raised `Unexpected Mebius packet signature: 00000001` from
  `ReadPacket` while switching to stop. Root cause was a lifecycle race:
  `TRecorderMic185DataSource.RequestStop` called `fDevice.Stop` from the
  external/UI thread while the worker thread could still be inside
  `DoTick -> ReadBlock`, so two code paths could read the same TCP socket.
- Fixed the race by making MIC185 `RequestStop` only set the inherited
  `TryStop` flag. The actual device `Stop/Disconnect` remains in
  `TRecorderMic185DataSource.Stop`, which the data-source worker calls after
  leaving its polling loop.
- Hardened `TryIoControl`: protocol/read/write exceptions now make the `Try*`
  method return `False` with `AErrorMessage` instead of escaping directly.
- Rebuilt `RecorderLnx.lpi` again with `lazbuild -B`: exit code 0.

## Current Conclusion

Root cause: MIC185 packet drain lost measurement packets by overwriting the
current block with the latest packet. At 10 Hz and `BlockSize=1`, this made the
recording rate follow the UI/source tick rather than the device sample rate.

The fix preserves all measurement packets drained in one source tick and passes
them to the existing tag ring buffer as one aggregated block.

Follow-up root cause for the Stop exception: MIC185 violated the
`IRecorderDataSource.RequestStop` contract by touching hardware from the
external stop request path. Stop is now serialized through the worker thread,
which prevents concurrent socket reads during shutdown.
