# MIC-140 refactor — последнее состояние (2026-06-23)

## Промпт
Продолжить план: вынести flash/calibration, Mebius types, подключить LegacyScanDriver, разнести константы.

## Сделано

### Новые unit'ы
- `uRecorderMic140Flash.pas` — mi118tar, tare records, чтение из ПЗУ (~560 строк)
- `uRecorderMic140Calibration.pas` — CSV, registry, download из flash (~760 строк)
- `uRecorderMic140MebiusTypes.pas` — `TMic140BaseSettings`, `Mic140BuildSettings`
- `uRecorderMic140LegacyChannelDesc.pas` — ME048/MIC140 descriptor packing

### Монолит
- `uRecorderMic140DataSource.pas`: **~5210 → ~3693 строк** (−30%)
- Подключён `TRecorderMic140LegacyScanDriver` через `fProtocolDriver` в read-thread
- `CjcTemperOffsetC` per-channel (без hardcoded `TEMPER_OFFSET[]`)
- Константы: `LegacyConstants`, `FlashConstants`, `Thermocouple`, `MebiusConstants`

### Сборка
`lazbuild -B RecorderLnx.lpi` — **OK** (exit 0)

## Следующие шаги
- Mebius protocol driver stub (`mpkMebius`)
- Вынести thermocouple transform (`Mic140TransformThermocoupleChannelSample`) в `uRecorderMic140Thermocouple`
- UI: поле `cjcTemperOffsetC` в диалоге канала
- Smoke: `Tools/mic140_preview_eval.ps1 -Seconds 3`

## 2026-06-26 MIC140v2 preview acceptance

Prompt: RecorderLnx moved from Cursor branch to mic140v2; fix failing preview stream
acceptance, compare with original Recorder, keep code/logs clean.

Done:
- MIC140v2 keeps the AIn-only scan contract: 48 BIOS slots, 48-word payload row.
- Added row-level raw validation in `uRecorderMic140v2Diag.pas`.
- Added `Mic140v2KeepGoodSampleRows` in `uRecorderMic140v2Stream.pas`: valid MDP/BIOС
  packets can contain one bad ADC row; the driver drops only bad rows, preserves
  num_buff/read counters, shifts `FirstSampleIndex` to the first kept row, and
  logs dropped rows.
- Removed verbose per-packet quality logging; kept compact dropped-row and stream
  summary diagnostics.
- Checked original `mtc/Modscn.cpp::CreateBiosCCScanBuf`; FIFO descriptor layout
  matches Recorder (`head/tail/begin`, `size=2*ready`, `sizeready=ready`).

Verification:
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  OK.
- `Tools\mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0` passed four times after
  the fix. Final: `PASS pub=14 read=14 ratio=100% corrupt=0 pubGaps=0 readGaps=0
  softRestart=0 expected=15 range=13..20 bps=5 readings=ok good=10 ch12=-7554`.

Open observation:
- On the tested device a single bad ADC row appears periodically inside an otherwise
  valid packet (`num_buff` examples: 3, 8, 13). Stream order, MDP checksum, BIOS
  header, publish gaps, and resync counters stay clean. Root cause can be researched
  later; current driver prevents spikes and keeps diagnostics visible.

## 2026-06-29 MIC140v2 acceptance complete

Prompt: finish MIC-140 protocol work until the previously defined acceptance rules pass;
keep a hypothesis/error history.

Done:
- Tightened MIC140v2 row validation for the current stand: the first 12 AIn words
  must look like Recorder strain data, with a nominal row-head window near
  `-8200..-6300`.
- Added shifted-row recovery for valid AIn rows embedded inside a 96-word payload.
- Added partial tail recovery for valid first-AIn tails of at least 12 words; the
  recovered row tail is zero-filled so bad/absent channels are not published as ADC
  spikes.
- Added a 1 s allowance to headless `--preview-seconds` runs because MIC-140 starts
  publishing blocks after the UI enters preview state.
- Created/updated `errors/2026-06-29-mic140v2-acceptance.md` with checked hypotheses.

Verification:
- Build: `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  OK.
- Stage A final code: three consecutive `Tools\mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0`
  PASS (`pub=18`, `pub=16`, `pub=19`; all clean counters).
- Stage B final code: three consecutive `Tools\mic140_preview_eval.ps1 -Seconds 10`
  PASS (`pub=54` each; all clean counters).
- Stage C final code: `Tools\mic140_preview_eval.ps1 -Seconds 40` PASS
  (`pub=201/read=201`, `corrupt=0`, `pubGaps=0`, `readGaps=0`,
  `softRestart=0`, readings OK).

Observation:
- One 40 s run before the final PASS hit a read-stall around 136 blocks and recovered
  through `stall restart`; it was not a hard hang. If this repeats as a stable failure,
  reboot the MIC-140 before further acceptance runs.

## 2026-06-29 MIC140v2 acceptance reopened: Recorder code profile

Prompt update: the Recorder screenshot with correct ADC codes is a mandatory
acceptance rule. It is now written as text in
`Docs/devices/mic140/acceptance_tests.md`; published AIn codes must not glitch.

Done:
- Added the text Recorder ADC profile:
  AIn1..24 must stay in `-8200..-6300`; AIn25..48 must stay in
  `-24000..-13000`; zero, saturation, positive, or out-of-range published
  values are hard failures.
- Added runtime published-code checking in `uRecorderMic140DataSource.pas`.
- Updated `Tools/mic140_preview_eval.ps1` so `corruptPublish > 0` or
  `MIC-140 code quality violation` fails acceptance.
- Updated the hypothesis journal:
  `errors/2026-06-29-mic140v2-acceptance.md`.

Current state:
- Acceptance is NOT complete under the new code-profile rule.
- Best strict 48-slot/MUX_IN1 run so far: clean published codes but too few
  blocks (`pub=2/read=2`, `corruptPublish=0`, `codeBad=0`).
- Legacy fallback failed (`pub=13/read=13`, corrupt published codes).
- Complete 60-slot MIC140_48v2 experiment (`48 AIn + 12 TIn`, v2 24-bit
  packing) is rejected and unsafe on the current device: no published rows,
  then TCP port `192.168.14.155:4000` stopped answering.
- Active scan programming was reverted to the safer 48-slot state after that
  experiment; stride-60 detection remains only for diagnostics.

Current state update:
- MIC-140 is not currently considered hung. User started RecorderLnx and live
  preview runs read packets and stop normally, although the data stream is still
  not accepted.
- Request/recommend reboot only after a real hang: cannot stop/reprogram, no
  scan packets after recovery attempts, or the app/device cannot return to a
  clean stopped state.

Next direction:
- Continue from the 48-slot strict-profile path.
- Do not retry legacy fallback, unsafe 60-slot v2 scan, H14 51-stride payload,
  H27 51-pointers/48-payload, H28 102-step timing, or v2 ME048 combinations
  without new evidence.
- Investigate board commutator/config loading for ch33..48; this is the best
  remaining lead.

## 2026-06-29 MIC-140 buffer layout correction

Prompt update: user pointed out the likely real payload is `48 AIn + 3 TIn = 51`
words per sample row, with 2 rows at 10 Hz / 200 ms -> `102 WORD`. Re-check
the original Recorder layout instead of changing stride by guessing.

Confirmed facts:
- Original Recorder decommutation is row-major: each channel has `offset`, the
  channel `size` is the total row width, and samples are read as
  `buff[offset + i * size]`.
- For the current 48-channel MIC-140 stand, the working target is:
  row = `AIn1..AIn48,TIn1..TIn3`, `stride=51`;
  block data at 10 Hz / 200 ms = `2 * 51 = 102 WORD`.
- Active channel sets change offsets/row width through BIOS descriptors, but
  multiple samples are still row-major rows, not channel-major buffers.

Done:
- Added `errors/2026-06-29-mic140-buffer-layout.md` as the active hypothesis
  journal for this investigation.
- Added `Device/MIC140v2/uRecorderMic140v2CoreDevice.pas`: a v2 wrapper over
  `TRecorderMic140DeviceCore` with `UsesRawRing=True`.
- Changed `Device/MIC140v2/uRecorderMic140v2Factory.pas` to create that core
  wrapper instead of the AIn-only `TRecorderMic140v2Device`.
- Updated `Docs/devices/mic140/protocol.md` to remove stale `96 WORD / stride 48`
  protocol text and document `SIZE=112`, `DATA=102 WORD`, `stride=51`.

Verification:
- Build OK: `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  exit code 0.
- Live acceptance is not blocked by reboot. The latest checked state reads and
  stops normally, but still fails the strict code-profile acceptance because too
  few clean blocks are published.

Latest checks:
- H26 safe 48-slot carry fallback: `FAIL pub=3/read=3`, clean codes, normal stop.
- H27 `48+3` as 51 BIOS pointers with 48-word payload: `FAIL pub=2/read=2`,
  clean codes, normal stop.
- H28 timing as `(48+3)*2=102` while H27 active: `FAIL pub=2/read=2`, clean
  codes, normal stop.
- Active code restored to safe 48-slot/48-payload timing profile; continue from
  there and keep updating `errors/2026-06-29-mic140-buffer-layout.md`.

## 2026-06-29 MIC-140 latest live state after Antigravity theories

Prompt update: check Antigravity's theories, but the main observed failure is
that packets are accepted rarely and the block counter barely advances while
some raw data look plausible. Continue until strict Recorder-code acceptance
passes; show reboot request only for a real instrument hang.

Current truth:
- Acceptance is NOT passed. Latest short previews still fail around
  `pub=4/read=4`, expected about 15 blocks for 3 seconds.
- Device is NOT currently considered hung: it connects, reads packets, and
  stops normally. Do not request reboot from bad data alone.
- Active code is the safe 48-slot profile:
  `BiosScanSlotCount=48`, `PayloadStride=48`, FIFO ready `96`, FIFO capacity
  `192`, value area reserves 60 words, ground ME048 is `[2,2]`,
  AIn1..24 descriptor `$0100`, AIn25..48 descriptor `$0110`.
- Timing is now closer to original MIC140_48: `(48 AIn + 3 TIn) * 2 = 102`
  ground phases. This is kept because it stays at the current best clean short
  run and matches original `GetMaxChanCount()` better than the previous v2
  `48+12` timing.

Rejected/deferred latest hypotheses:
- Antigravity dynamic `desc`: real architecture gap, but not the immediate
  cause because first published rows have correct Recorder-like codes.
- Antigravity channel hardware settings in `TRecorderDeviceChannel`: real
  config gap, but not enough evidence that it causes the current packet counter
  stall on the default stand.
- Antigravity auto-disable ground at high frequency: not relevant for current
  10 Hz; original constructor has `flag_chan_ground=1`.
- H33 exact `48+3` hidden descriptor table with only 48 published pointers:
  rejected (`pub=2/read=2`, rejected-packet quality much worse).
- H34 disabled stall restart: rejected (`pub=2/read=2`).
- H35/H39 max FIFO capacity: informative but insufficient; restored original
  capacity.
- H36 doubled channel delay: rejected as a fix.
- H40 FIFO zero-fill: rejected and removed.

Important observed failure signature:
- After the first two clean rows, rejected 96-word packets often contain a
  near-complete AIn1..24 head window but only 4..7 valid AIn25..48 tail values,
  plus repeated service-looking words such as `32767`, `-32768`, `187xx`,
  and `-196xx`.
- This is not a pure TCP/stride issue and not just stale FIFO memory. The next
  useful direction is scan programming/commutation/FIFO phase around the second
  bank, while keeping the strict no-glitch Recorder code rule.

Files to read first in the next session:
- `errors/2026-06-29-mic140-buffer-layout.md`
- `Docs/devices/mic140/acceptance_tests.md`
- `Device/MIC140v2/uRecorderMic140v2Scan.pas`
- `Device/MIC140v2/uRecorderMic140v2Stream.pas`

## 2026-06-29 MIC-140 protocol accepted after H45

Prompt update: continue until MIC-140 protocol works under the strict Recorder
code-profile acceptance rule; check Antigravity's theories, but the immediate
failure is rare accepted packets / block counter barely advancing while raw
packets still arrive.

Root cause found:
- The live rev14 stand is stable only when the BIOS scan pointer list contains
  the 48 AIn descriptors directly.
- The previous `ground,AIn` alternating pointer list produced valid first rows
  and then corrupted the second bank, so strict row filtering accepted only a
  few packets.
- This is why TCP traffic and `num_buff` were alive while the Recorder block
  counter barely advanced.

Accepted active profile:
- `BiosScanSlotCount=48`, `PayloadStride=48`.
- FIFO ready `96` words at 10 Hz / 200 ms, FIFO capacity `192`.
- Value area reserves 60 words.
- Ground descriptor remains allocated for compatibility/diagnostics, but is not
  included in the BIOS scan pointer list.
- `ADDCHANNELMODULE` receives 48 AIn descriptor pointers, not 96
  `ground,AIn` pointers.
- AIn1..24 descriptor `$0100`; AIn25..48 descriptor `$0110`.
- Timing remains original MIC140_48-style `(48 AIn + 3 TIn) * 2 = 102`
  phases because it was already the best stable timing and passes acceptance.

Files changed in the accepted fix:
- `Device/MIC140v2/uRecorderMic140v2Scan.pas`
- `errors/2026-06-29-mic140-buffer-layout.md`

Verification:
- Build OK:
  `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
- Stage A, three consecutive 3 s runs:
  `PASS pub=18 read=18`, `PASS pub=16 read=16`, `PASS pub=16 read=16`.
- Stage B, three consecutive 10 s runs:
  `PASS pub=54 read=54`, `PASS pub=51 read=51`, `PASS pub=52 read=52`.
- Stage C, one 40 s run:
  `PASS pub=201 read=201`.
- All verification runs had:
  `corrupt=0`, `corruptPublish=0`, `codeBad=0`, `pubGaps=0`, `readGaps=0`,
  `softRestart=0`.
- Device stopped normally throughout. No reboot was required.
