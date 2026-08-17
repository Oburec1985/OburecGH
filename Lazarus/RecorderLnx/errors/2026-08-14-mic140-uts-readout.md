# 2026-08-14 - MIC-140 UTS readout

## Symptom / Request

User asked to add MIC-140 UTS support "like MIC-185": inspect the original
Recorder behavior and finish readout.

## Acceptance Notes

- MIC-140 must publish UTS in the same project/tag model as MIC-185.
- Runtime code must use cached tag references/indexes, no repeated tag lookup
  by string in the hot path.
- Behavior must be verified against original Recorder source before coding.

## Checked Facts

- `Docs/mic140_protocol.md` is absent in this workspace; use current MIC-140
  implementation, RecorderLnx docs, and original Recorder sources instead.
- Original MIC-140 modules create AIn and TIn channels only in
  `MIC140_96_rce/*mod.cpp`; UTS is not a temperature channel.
- Original Recorder registers `ScanSEV` for MIC-140 apps. `mtc/sevscn.cpp`
  reads a 6-word `TUtsBios` payload, converts BCD `time_lo/time_hi` to
  `time_uts`, and calls `Device::AddTimeDev(time_dev)`.
- Original `mtc/sevchn.h` defines the SEV channel BIOS size as
  `CHAN_SIZE_WORD = 6` and marks the channel as `VT_R8|VT_UTS`.
- RecorderLnx MIC-185 publishes UTS through a cached tag and updates
  `Registry.TimeSystem.UpdateFromTagSample`.

## Hypotheses

- Rejected: UTS is not a special service/temperature word inside MIC-140
  AIn/TIn blocks.
- Rejected: MIC-140 UTS is not calculated from TIn words.
- Confirmed: adding a MIC-140 UTS tag can force the source to 1 Hz if generic
  MIC-140 frequency selection uses the first tag in the source. UTS and
  diagnostic tags must not be acquisition-frequency candidates.
- Confirmed by hardware: just parsing stream-0 is not enough; no UTS values
  appeared after selecting the tag. RecorderLnx must explicitly program the
  original `ScanSEV` path during device Configure.
- Active: MIC-140 SEV packets should appear on legacy stream 0 beside main scan
  packets after ScanSEV is configured by the BIOS/original scan setup.
- Active risk: exact local X time in original uses `CCDevice::GetTimeLocFromScanUTS`
  with CC clock/timer parameters. RecorderLnx currently approximates X from the
  SEV HCLK counter divided by 50 MHz; verify against hardware capture before
  using it as an acceptance-quality time base.
- Confirmed by code inspection: MIC-140 runtime source frequency was selected
  from any source tag with `PollFrequencyHz > 0`; therefore a selected
  `{node}-uts` tag with 1 Hz could become the source frequency and slow all
  normal AIn/TIn channels to 1 Hz.
- Confirmed by hardware log after the first SEV attempt: main MIC-140 packets
  still arrived (`mdpWords=120`, `scan=0/1` depending on programmed id), but
  RecorderLnx rejected them with `reason=routing`. Root cause was duplicate
  `CMic140LegacyScanId` definitions: old `uRecorderMic140Consts` had the
  working main scan id `1`, while the new `uRecorderMic140LegacyConstants` set
  it to `0`, so programming and parsing disagreed after adding the new unit.

## Changes Made

- Added MIC-140 UTS address helpers: `{node}-uts` address and
  `MIC140-{node-uts}` display name.
- Fixed MIC-140 address matching so node-qualified addresses from different
  devices are not treated as the same channel/UTS tag.
- Added UTS signal to MIC-140 source probe so users can select/create it like
  MIC-185 `uts`.
- Added low-level parsing of 6-word MIC-140 SEV/UTS packets in
  `TMic140v2Tcp.AbsorbScanWords`; recognized packets are cached separately and
  are not sent through normal AIn/TIn decommutation.
- Added `IMic140Device.LastUts` and runtime publication through cached
  `TRecorderTag` pointer. No `TextValue`, no runtime description mutation, and
  no per-sample string lookup.
- Added explicit MIC-140 `ScanSEV` programming:
  `APPENDSCANMAIN(type=17, scan=1)`, `SETSTATESCAN(scan=1,state=0)`,
  SEV FIFO descriptor via `SCAN_SET_BUFF`, and `CONFIG_SCANSEV`.
- MIC-140 start now also rearms SEV scan id 1 non-fatally, with a log message
  if the device rejects the command.
- MIC-140 source frequency selection now ignores UTS and diagnostic tags, so
  the 1 Hz UTS tag cannot lower the main channel acquisition frequency.
- SEV packet parser now accepts FIFO payloads containing one or more 6-word UTS
  entries and publishes the newest entry.
- Stabilization after regression: restored the working main
  `CMic140LegacyScanId = 1` in the shared legacy constants and disabled the
  automatic `ProgramSevScan`/SEV rearm calls. This should restore normal
  MIC-140 AIn/TIn data while keeping UTS tag creation, UTS frequency isolation,
  and passive UTS parser code.

## Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0 and linked `RecorderLnx.exe`.
- Existing post-build `copy_sdb_res.bat` still prints `#!/bin/sh` under
  Windows, but lazbuild reports success; this is unrelated to MIC-140 UTS.
- After the stabilization fix, `RecorderLnx.lpi` rebuilt again with exit code
  0. `git diff --check` reported only line-ending warnings.

## Remaining Hardware Check

- First verify that normal MIC-140 AIn/TIn data is restored. Expected:
  no repeated `reject stream0 ... reason=routing` for the main scan, no
  `no scan data`.
- UTS explicit programming is intentionally disabled until the original
  multi-scan id/order is rechecked. Next UTS step must not reuse ambiguous
  unqualified constants; qualify or consolidate legacy constants before
  re-enabling SEV.

## 2026-08-14 15:03 - UTS garbage guard and separate SEV programming

### New symptom

User reported that MIC-140 UTS values are incorrect and look like codes from
another channel or garbage.

### Checked facts

- Latest `LogWindows.log` shows MIC-140 main data on `192.168.14.42:4000`
  was clean: `published=102 read=102 readGaps=0 dupRead=0 corruptRead=0`.
- The same log has no `SEV scan OK`, so correct UTS packets were not confirmed
  in that run. Any visible UTS value could therefore come only from stale data
  or an over-permissive passive parser.
- Current parser accepted a UTS-looking packet if the payload length was a
  multiple of 6 and BCD looked valid; it rejected the known main `scan_id=1`
  but did not require the packet to belong to the separate SEV scan.
- Original Recorder programs UTS through separate `ScanSEV`:
  `TYPE_SEV=17`, `CMD_CONFIG_SCANSEV=91`, 6-word `TUtsBios`.

### Hypotheses

- Confirmed in code: passive UTS parsing was too permissive. A non-main
  stream-0 packet with BCD-looking words could publish garbage as UTS.
- Active: current separate SEV scan id should be `0`, while the working main
  MIC-140 scan id stays `1`. Hardware log must confirm this with
  `SEV scan OK scan=0` and `UTS packet accepted ... scan=0`.
- Rejected for this pass: changing main scan id. Main scan id `1` is known to
  work and must not be touched.

### Changes made

- `uRecorderMic140Protocol.pas`: `TryParseUtsWords` now requires
  `scan_id = CMic140LegacySevScanId`, rejects accidental equality with the
  main scan id, keeps BCD validation, and logs only the first four accepted UTS
  packets with type/scan/payload/raw BCD/HCLK.
- `uRecorderMic140Scan.pas`: `ProgramScan` now attempts separate original-style
  `ProgramSevScan` after successful main programming. SEV failure is logged as
  `SEV scan disabled: ...` and does not make main AIn/TIn programming fail.
- `uRecorderMic140Device.pas`: device stores `fSevProgrammed`; `Start` only
  rearms the SEV scan if configuration actually created it. Main scan rearm
  remains fatal as before, SEV rearm is diagnostic/non-fatal.

### Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0 after the parser guard.
- Same rebuild completed with exit code 0 after enabling separate SEV
  programming/rearm. Existing Windows post-build `#!/bin/sh` message remains
  non-blocking.

### Next hardware check

- Run Preview with a selected MIC-140 UTS tag.
- Expected log if SEV works: `SEV scan OK scan=0 ...`, `scan programmed ...
  sev=True`, then one to four `UTS packet accepted ... scan=0`.
- If main AIn/TIn remains clean but there is `SEV scan disabled`, compare that
  command stage with original Recorder traffic.
- If `UTS packet accepted` appears but values are still wrong, next hypothesis
  is not packet routing but the BCD/time field interpretation or local
  `GetTimeLocFromScanUTS` equivalent.

## 2026-08-14 15:17 - SEV order fixed, UTS publishes

### Checked facts

- Original Recorder programs all scans before `trigger_start_adc.Start`.
- RecorderLnx initially called `ProgramSevScan` after `START_TRIGGERSTARTADC`;
  hardware then accepted SEV, but following main packets could be rejected as
  stream routing/state mismatch.
- After moving SEV programming before `CONFIG_MESSAGE`,
  `CONFIG_SYNC_START`, and `START_TRIGGERSTARTADC`, the hardware log shows:
  `SEV scan OK scan=0`, `scan programmed ... sev=True`,
  `UTS packet accepted #1 ... scan=0`, and
  `MIC-140 UTS published #1 tag=MIC140_{42_uts}`.
- The same 10 second auto-preview run stopped cleanly:
  `published=54 read=54 readGaps=0 dupRead=0 corruptRead=0
  corruptPublish=0 mdpResync=0`, with no `reject stream0`.

### Final changes

- `uRecorderMic140Scan.pas`: SEV scan is programmed before trigger/ADC start,
  matching the original Recorder lifecycle.
- `uRecorderMic140Protocol.pas`: `AbsorbScanWords` now returns whether a main
  scan block was queued. UTS packets are accepted and cached, but do not count
  as the requested main packet in `PumpScanFromSocket`.
- `uRecorderMic140DataSource.pas`: first few UTS publications are logged
  through a cached tag pointer; runtime still avoids string `TextValue` and
  per-sample tag lookup.

### Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0 after the protocol/data-source changes.
- Hidden hardware run:
  `RecorderLnx.exe --preview-seconds=10`.
- Result: MIC-140 UTS is received from SEV scan 0 and published to the selected
  UTS tag while the main AIn/TIn stream remains clean.

### Remaining risk

- UTS value decoding currently follows the observed/original BCD seconds field
  (`time_lo/time_hi`). If the displayed wall-clock interpretation must exactly
  match the original UI, compare against original `GetTimeLocFromScanUTS` with
  a longer capture.

## 2026-08-14 15:25 - MIC-140 UTS compared with MIC-185

### New symptom

User reported that MIC-140 UTS still looked like garbage and should be
approximately equal to MIC-185 UTS.

### Checked facts

- Original `mtc/sevscn.cpp` stores the displayed UTS value from BCD
  `time_lo/time_hi`. It stores local X time separately from
  `CCDevice::GetTimeLocFromScanUTS`.
- Original `mtc/cc81ifc.cpp::GetTimeLocFromScanUTS` does not use a plain
  `HCLK / 50 MHz` conversion. It applies the CC timer period/counter formula.
- Hardware log at `15:25:18..15:25:21` showed one MIC-185 UTS group
  (`.147/.148/.151/.152/.155`) publishing `uts=15722..15725`.
- The same run showed MIC-140 `.14.42` accepting SEV frames at `15:25:23` with
  BCD `uts=15727`, then `15733`, then `15739`. This is consistent with the
  MIC-185 `1572x` group plus elapsed time.
- There is another MIC-185 UTS group (`.156/.158/.159`) around `20323..20326`.
  MIC-140 does not match that group, but it does match the first group.

### Hypotheses

- Rejected: MIC-140 UTS Y value is random or a channel code. Raw SEV BCD frames
  and MIC-185 comparison show the Y value is plausible.
- Confirmed: MIC-140 local X time was wrong. RecorderLnx divided the SEV HCLK
  counter by a hard-coded 50 MHz scale and produced about `0.0058` seconds.
  Raw HCLK increments and original code show the effective local-time formula
  must use the legacy timer period/frequency path.

### Changes made

- `uRecorderMic140Protocol.pas`: replaced the hard-coded HCLK/50 MHz UTS local
  X conversion with `Mic140SevLocalTimeSec`, using
  `CMic140LegacyTimerPeriod` and `CMic140LegacyFreqClkHz` like the original
  CC timer calculation.

### Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- Hidden hardware run `RecorderLnx.exe --preview-seconds=20` showed:
  `MIC-140 UTS published #1 ... x=5,382904 uts=15727`,
  then `x=11,383724 uts=15733`, then `x=17,384545 uts=15739`.
- MIC-185 `.147/.148/.151/.152/.155` in the same run published
  `uts=15722..15725` immediately before MIC-140 `15727`, so the MIC-140 UTS
  value is approximately equal to the compatible MIC-185 UTS group.
- Main MIC-140 stream remained clean:
  `published=105 read=105 readGaps=0 dupRead=0 corruptRead=0
  corruptPublish=0 mdpResync=0`.

### Remaining risk

- The stand appears to have at least two UTS source groups. If the UI compares
  MIC-140 with MIC-185 `.156/.158/.159`, values differ by about 4600 seconds;
  compare against `.147/.148/.151/.152/.155` for this MIC-140 group.

## 2026-08-14 15:34 - UTS display stalled between MIC-140 packets

### New symptom

User reported that MIC-140 time display keeps the same value for several
seconds and may still be incorrect.

### Checked facts

- Live MIC-140 SEV packets arrive as FIFO batches. Example hardware log:
  `frames=6` with BCD values `6230..6235`, then six seconds later
  `6236..6241`, then `6242..6247`.
- RecorderLnx published only the newest value from each batch, so the UTS tag
  and `TimeSystem` received updates every about six seconds:
  `uts=16235`, `uts=16241`, `uts=16247`.
- `TRecorderTimeSystem.Snapshot` in `rtskUtsTime` displayed exactly
  `fLastUtsTimeSec` without extrapolating from the moment the UTS sample was
  received. This made the status time freeze between MIC-140 SEV batches.
- Original Recorder stores a device-time/UTS pair in `AddTimeDev`; the status
  time should behave as a running clock between synchronization samples.

### Hypotheses

- Confirmed: the visible freeze is in the display time model, not in MIC-140
  packet reception. SEV packets and main stream are clean.
- Still open for data storage: MIC-140 UTS tag history currently records one
  tail value per FIFO packet. This is enough for status-time synchronization
  but does not preserve every intermediate SEV frame as separate tag samples.

### Changes made

- `uRecorderTimeSystem.pas`: stores the monotonic tick when a UTS sample is
  accepted and makes `Snapshot` display `last UTS + elapsed ticks since update`
  while the recorder is running.
- `RecorderTimeSystemTest.lpr`: added a regression check that UTS display
  advances between hardware packets.

### Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- Hidden hardware run `RecorderLnx.exe --preview-seconds=20` showed MIC-140
  SEV packets and a clean main stream:
  `published=105 read=105 readGaps=0 dupRead=0 corruptRead=0
  corruptPublish=0 mdpResync=0`.
- `RecorderTimeSystemTest.exe` passed. New check:
  after `UTS=7201`, sleeping about 1.1 s produced
  `LastUtsTimeSec=7202.109` and display `02:00:02`.

## 2026-08-14 15:44 - MIC-140 UTS tag must publish every FIFO frame

### New symptom

User clarified that the MIC-140 UTS tag itself is still wrong: it should
increment once per second, but the value stays around 16000 and almost never
changes.

### Checked facts

- Hardware SEV packets are FIFO batches with six 6-word UTS records. Example:
  accepted packet `raw [0]=6846 ... [5]=6851`.
- Before this pass RecorderLnx cached/published only the newest frame from the
  batch. Therefore the UTS tag changed once per SEV packet, with jumps of about
  six seconds.
- The previous `TimeSystem` interpolation fixed only status display between
  samples; it did not fix the numeric UTS tag history.
- Latest hardware preview after the change shows the first FIFO packet
  `16846..16851`, then tag publications:
  `uts=16846`, `uts=16847`, `uts=16848`, `uts=16849` at approximately one
  second intervals.

### Hypotheses

- Rejected: the UTS value is static because the BCD decoder is wrong. Raw BCD
  frames decode to consecutive seconds.
- Rejected: publishing the tail frame is acceptable if status display
  interpolates. User acceptance requires the UTS tag itself to update once per
  second.
- Confirmed: MIC-140 SEV FIFO payload must be expanded into individual UTS
  tag samples instead of collapsed to the newest frame.
- Confirmed during code review: the fast MIC-140 block pump must not drain the
  UTS FIFO internally, otherwise the data source cannot pace publications.

### Changes made

- `uRecorderMic140Protocol.pas`: replaced last-only UTS storage with a small
  FIFO queue. `AbsorbUtsWords` now parses every 6-word SEV frame in the
  packet and enqueues each decoded UTS sample with a generation counter.
- `uRecorderMic140Device.pas`: removed UTS draining from the main block pump.
  `LastUts` now dequeues one UTS sample only when the data source asks for it.
- `uRecorderMic140DataSource.pas`: `PublishUtsIfNew` publishes through the
  cached UTS tag at about 1 Hz, so queued frames are emitted as separate tag
  samples.

### Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- Hidden hardware run `RecorderLnx.exe --preview-seconds=20` completed with
  exit code 0. Log confirms MIC-140 `.14.42` accepted one SEV FIFO batch with
  raw UTS values `16846..16851`, then published `16846`, `16847`, `16848`,
  `16849` on the UTS tag at about one second cadence.

## 2026-08-14 17:24 - MIC-140 UTS must be current, not replayed

### New clarification

User clarified that SEV/UTS channels do not need every historical measurement
shown in the UI. The important behavior is the current mapping between crate
local clock and SEV/UTS clock, because all devices share the time code while
different controller quartz clocks drift differently.

### Checked facts

- After changing `CMic140LegacySevFifoReadyEntries` to `1`, the hardware log
  shows `SEV scan OK scan=0 fifoReady=6 fifoCapacity=12 count=17`.
- In the same run, first MIC-140 UTS arrived about one second after start:
  `UTS packet accepted #1 ... payload=6 frames=1 ... uts=22849`.
- MIC-185 devices published the same UTS second in the same interval:
  `MIC-185 UTS published ... uts=22849`.
- Main MIC-140 stream remained clean:
  `published=61 read=62 readGaps=0 dupRead=0 corruptRead=0
  corruptPublish=0 mdpResync=0`.

### Hypotheses

- Confirmed: the previous 5-second lag came from SEV FIFO readiness set to six
  6-word entries (`fifoReady=36`), so the first packet contained a backlog and
  publishing from the queue head displayed old UTS values.
- Confirmed: even with one-entry SEV FIFO, runtime must never replay stale UTS
  samples after a UI/thread delay. For time synchronization, the newest
  `(crate local time, UTS)` pair is the useful sample.
- Rejected: preserving every UTS FIFO frame is required for the MIC-140 UTS UI
  tag. That conflicts with the user's clarified acceptance rule.

### Changes made

- `uRecorderMic140LegacyConstants.pas`: set
  `CMic140LegacySevFifoReadyEntries = 1`, so SEV packets are requested after
  one 6-word UTS record instead of six records.
- `uRecorderMic140Protocol.pas`: `LastUtsPacket` now takes the newest queued
  UTS packet and clears older queued packets. This keeps the published UTS tag
  and `TimeSystem` synchronized to current hardware state instead of replaying
  stale seconds.

### Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0 after the SEV FIFO threshold change.
- Hidden hardware run `RecorderLnx.exe --preview-seconds=12` completed with
  exit code 0 and confirmed `fifoReady=6`, `frames=1`, and MIC-140/MIC-185 UTS
  values matching at `22849`, `22850`, `22851`, `22852`.

### Final verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0 after the newest-UTS queue change.
- Hidden hardware run `RecorderLnx.exe --preview-seconds=12` completed with
  exit code 0.
- Log confirms first MIC-140 UTS packet arrived immediately after start:
  `17:27:08.407 UTS packet accepted #1 ... payload=6 frames=1 ... uts=23031`.
- MIC-185 devices published the same UTS second in the same interval:
  `17:27:08.529..08.562 MIC-185 UTS published ... uts=23031`.
- MIC-140 published current UTS values one second apart:
  `23031`, `23032`, `23033`, `23034`.
- Main MIC-140 stream stayed clean:
  `published=62 read=62 readGaps=0 dupRead=0 corruptRead=0
  corruptPublish=0 mdpResync=0`.
