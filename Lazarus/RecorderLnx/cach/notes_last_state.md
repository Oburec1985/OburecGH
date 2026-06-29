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

Blocker:
- MIC-140 appears hung after the 60-slot experiment. Reboot the MIC-140 before
  any further live acceptance or preview runs.

Next direction after reboot:
- Continue from the 48-slot strict-profile path.
- Do not retry legacy fallback, 60-slot v2 scan, `48+3`, `48+12`, or v2 ME048
  combinations without new evidence.
- Investigate board commutator/config loading for ch33..48; this is the best
  remaining lead.
