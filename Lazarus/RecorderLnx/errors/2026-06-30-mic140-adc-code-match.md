# MIC-140 ADC code match with Recorder

## Symptom
- RecorderLnx stream can be alive, but published ADC codes do not match the original Recorder reference within about 20 raw codes.
- User supplied a fresh Recorder screenshot for stand `0164`; channels 29 and 30 are intentionally positive because an external signal was applied.

## Acceptance Rule
- Published AIn1..48 values must match the Recorder reference table within `±20` raw ADC codes.
- This supersedes the older broad-band rule (`AIn1..24=-8200..-6300`, `AIn25..48=-24000..-13000`) for the current bench state because that broad rule rejects the valid positive signal on channels 29 and 30.

## Recorder Reference

| Ch | Raw | Ch | Raw | Ch | Raw | Ch | Raw |
| --- | ---: | --- | ---: | --- | ---: | --- | ---: |
| 01 | -7176 | 13 | -7176 | 25 | -16793 | 37 | -20524 |
| 02 | -7129 | 14 | -7125 | 26 | -15931 | 38 | -17895 |
| 03 | -6605 | 15 | -6605 | 27 | -17766 | 39 | -18407 |
| 04 | -7239 | 16 | -7237 | 28 | -17550 | 40 | -18592 |
| 05 | -7178 | 17 | -7175 | 29 | 6074 | 41 | -20674 |
| 06 | -7127 | 18 | -7126 | 30 | 13499 | 42 | -17309 |
| 07 | -6606 | 19 | -6604 | 31 | -12571 | 43 | -17422 |
| 08 | -7238 | 20 | -7239 | 32 | -15394 | 44 | -17725 |
| 09 | -7176 | 21 | -7178 | 33 | -16066 | 45 | -19990 |
| 10 | -7130 | 22 | -7127 | 34 | -13795 | 46 | -15853 |
| 11 | -6603 | 23 | -6605 | 35 | -16349 | 47 | -16980 |
| 12 | -7241 | 24 | -7239 | 36 | -17467 | 48 | -19364 |

## Hypotheses

| ID | Hypothesis | Check | Result | Status |
| --- | --- | --- | --- | --- |
| H46 | The stream did not actually hang; the preview script failed because no published blocks produced the `stream stop: published=` line. | Ran `mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0` and inspected `LogWindows.log`. | Confirmed. The device stopped normally with `[MIC140v2] stopped blocks=0`; no reboot condition. | confirmed |
| H47 | The current code uses the wrong commutator split: logical AIn1..24 are programmed through MUX1 because the branch checks physical `CAInNum48[i] >= 24`. | Inspected `uRecorderMic140v2Scan.pas` and the live descriptor dump. `desc1=[0,129,272,...]` means logical channel 1 uses `$0110`; raw packets show first 24 words near `-19690` instead of Recorder `-7xxx`. | Confirmed. Change descriptor split to logical `i >= 24`: AIn1..24 `$0100`, AIn25..48 `$0110`. | checking |
| H48 | The older broad acceptance profile is now wrong because the user's current Recorder reference has valid positive channels 29/30. | Compared the screenshot values with `Mic140v2RawRowRecorderProfile` and `CheckPublishedRecorderCodes`. | Confirmed. Replace broad ranges with exact Recorder table ±20 for the current acceptance. | checking |
| H49 | Recorder's current board commutator is likely MUX0 for all AIn, not a split profile, because original `commut_b[]` defaults to `0` and the property page applies one `calibr2` to all channels. | After H47, logical AIn1..24 became `-7xxx`, but AIn25..48 all became near `-19690`, losing the user's positive test signal on ch29/ch30. Patch all AIn descriptors to `$0100`, rebuild, rerun preview. | Checking. | checking |
| H50 | The remaining mismatch is ME048 packing: rev14 original `MIC140_48v2` uses 24-bit `code_chanAIn`, while the active scan still used legacy 16-bit ME048 packing. | Keep all AIn MUX0 and switch AIn/ground ME048 packing to `Mic140v2PackMe04848v2` / `Mic140v2PackLevel0Me04848v2`, rebuild, rerun preview. | Rejected. The device stopped normally, but no rows were published and first 24 values moved far away from the Recorder table (`-17xxx/-8xxx/...` instead of the previous `-7xxx` group). Reverted to 16-bit ME048 packing. | rejected |
| H51 | Exact Recorder ±20 matching must not be used as the row-extraction gate, because it freezes the block counter while data are plausible but still mismatched. | Keep exact ±20 in `CheckPublishedRecorderCodes`, but relax `Mic140v2RawRowRecorderProfile` back to transport/sanity validity (`not Mic140v2RawRowCorrupt`). Build and rerun preview. | Checking. | checking |

## Actions
- Patched `uRecorderMic140v2Scan.pas`: descriptor MUX split now follows logical channel index, not reversed physical ME048 index.
- Patched `uRecorderMic140v2Diag.pas`, `uRecorderMic140v2Stream.pas`, and `uRecorderMic140DataSource.pas`: strict Recorder profile is a 48-value table with ±20 tolerance.
- H47 live result after build: device stopped normally, but no rows were published. Raw packets had AIn1..24 near `-7xxx` and AIn25..48 near constant `-19690`; this proves the previous physical-index split was wrong but the logical split is still not Recorder-equivalent for the tail bank.
- H49 patch: changed AIn descriptors to all `$0100` for the next live check.
- H49 live result: device stopped normally. Tail bank is no longer constant; ch29 shows a positive signal near `5948`, close to Recorder `6074`, so all-MUX0 is a better commutator hypothesis. Exact table still fails, so continue with ME048 packing.
- H50 live result: device stopped normally (`stopped blocks=0`), no reboot required. 24-bit v2 ME048 packing is worse on the current active scan profile. Reverted to 16-bit ME048 packing with all AIn descriptors `$0100`.
- H51 patch: row extraction no longer requires exact Recorder ±20. Exact match remains an acceptance rule and is logged after publication; this should keep the block counter moving while we continue fixing code differences.
# 2026-06-30 continuation

| ID | Hypothesis | Check | Result | Status |
| --- | --- | --- | --- | --- |
| H52 | Current Ethernet BIOS still needs original alternating ground/AIn pointer descriptors. | Temporarily programmed `ptrCnt=intCnt*2` and `chanDump` as alternating ground+AIn descriptors. | Rejected for the current live rev14 path. Stream produced only 4 blocks then read timeout; full-row match was still bad (`good=1/48`), and pointer head contained alternating `48,4,48,2124...`. Reverted to AIn-only pointer list. No device reboot was required. | rejected |
| H53 | Low-frequency averaging should use the calculated original value instead of the conservative cap `AverageSampleCount<=4`. | Removed the cap and ran preview. | Rejected as a transport stability change. The preview failed without a stream-stop line and no RecorderLnx process remained afterward, so this is not a device hang, but it is worse than the previous live baseline. Restored the cap. | rejected |

- H52 live result: alternating ground descriptors are not accepted as the active publication layout on the current setup. Keep AIn-only pointer publication unless a separate BIOS/configuration proves otherwise.
- H53 live result: removing the low-frequency average cap destabilized the preview run. Restored `AverageSampleCount <= 4` for `FrequencyHz <= 10`.

| H54 | Antigravity's range/commutator theory explains why Recorder and RecorderLnx can differ even with the same ME048 channel order. | Inspected active v2 path: `TRecorderMic140ChannelSettings.RangeIndex` existed in device config, but `TMic140v2ScanProgrammer` received only channel count/frequency/update and hardcoded every AIn descriptor through `$0100`. | Confirmed as a real code gap. Added per-channel `rdpMic140RangeIndex` and `rdpMic140CommutIndex`, passed them into v2 scan programming, and build remained green. Default remains `$0100`, so existing projects without settings keep previous behavior. | implemented |
| H55 | Current failure to run preview is caused by the device/port being unavailable, not by a local RecorderLnx process hang. | Ran preview twice, checked `LogWindows.log`, checked local Recorder processes, `Get-NetTCPConnection`, and `Test-NetConnection 192.168.14.155 -Port 4000`. | Confirmed. Logs show `TCP probe failed` followed by normal stopped status; no Recorder process is running; no local TCP owner exists; direct TCP connect to port 4000 fails/timeouts. Live acceptance cannot proceed until the device is rebooted/available or the network/power issue is cleared. | blocked |

- H54 code changes: `uRecorderDeviceInterfaces.pas` adds MIC-140 per-channel range/commut properties; `uRecorderMic140DataSource.pas` sends restored channel settings before `ProgramDevice`; `uRecorderMic140v2Device.pas` stores arrays and passes them to the scan programmer; `uRecorderMic140v2ChanDesc.pas` builds MIC-140 register descriptors from range/commut; `uRecorderMic140DeviceConfig.pas` persists `commutIndex`.
- H55 operator action: reboot or otherwise make MIC-140 at `192.168.14.155:4000` accept TCP connections again, then rerun `Tools\mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0`.

| H56 | Recorder-visible row has 51 channels (`48 AIn + T1..T3`), so `m_ChanDump[2]` must be 51 when `ptrCnt=51`; leaving it at 48 can make BIOS accept 51 pointers but use the wrong row width/phase. | Patch `chanDump[2] := Word(ptrCnt)` in `uRecorderMic140v2Scan.pas`, rebuild, run live preview, and compare T1/T2 against Recorder (`T1=8844`, `T2=9019`, tolerance +/-20). | Checking. | checking |

- H56 action: changed scan channel dump header from AIn-only count (`48`) to the actual pointer/visible channel count (`51`) for the active `48 AIn + 3 TIn` experiment. This is intentionally small and will be reverted if live data get worse.

| H57 | The rev14.1 device uses `MIC140_48v2` TIn coding, not old `MIC140_48` TIn coding. For `DevSubRev=1`, original `TInNum_SUBREV1` maps visible T1..T3 to internal TIn `4,3,2`. | Keep AIn packing unchanged, but pack only TIn slots through `Mic140v2PackTInMe04848v2()` with subrev1 mapping `4,3,2`; rebuild and run preview. | Checking. | checking |

- H57 action: changed only TIn ME048 programming for the active 51-slot experiment. AIn channel ME048 packing remains the legacy path that previously produced Recorder-like AIn groups.

| H58 | The stream recovery for 48-channel AIn-only mode is corrupting the 51-word `AIn+TIn` layout: it finds a shifted 48-word AIn-looking window and publishes the following three words as fake T1..T3. | Disable shifted-row recovery when `AStride > AUserCh` (51-word mode), rebuild, and rerun preview. | Checking. | checking |

- H58 action: row recovery now only shifts rows for AIn-only layouts. For `48+3` rows it accepts/drops full row-boundary samples, preserving the real TIn tail positions for diagnosis and acceptance.

| H59 | TIn descriptors are being treated as synthetic `chan=nil` channels because their value pointers use `MASK_CHAN_LEFT`. In Recorder, T1..T3 are visible channels, so `mask_chan_left=0` and ptr should be `var_addr+48+i`, like AIn. | Remove `MASK_CHAN_LEFT` from TIn descriptor ptrs, rebuild, confirm log changes TIn ptr from `0x8840` to `0x0840`, then run preview. | Checking. | checking |

- H59 action: TIn value pointers now use the same non-masked value area addressing as visible AIn channels.

| H60 | User-visible window activity was Recorder/RecorderLnx, not a hard MIC-140 hang. | Ran `mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0` after the user clarified the window did not hang. | Confirmed. Live result: `pub=16 read=16 ratio=100% corrupt=0 readGaps=0 pubGaps=0 softRestart=0`. Do not request reboot from this symptom. | confirmed |
| H61 | The 48-word AIn-only payload must not be decoded as fake TIn by reading the next AIn row tail. | In `Mic140v2StreamDecommutate`, clear aux temperature and exit when `AStride <= AChCnt`; reran preview. | Confirmed as a guard. The latest script reports `tin=no TIn line` instead of fake T1/T2 values copied from AIn data. Acceptance still fails because real TIn is missing. | implemented |
| H62 | Defaulting AIn25..48 to board MUX1 (`$0110`) is wrong for the current Recorder reference; original Recorder defaults/applies `commut_b[]` uniformly, initially all zero. | Current split-default run logged `desc48=[0,8192,272,...]` and `block1 all48` tail 25..48 near constant `-19689`. Original `mic140_96mod.cpp` initializes `commut_b[i]=0`; property page applies one `calibr2` to all channels. | Checking all-MUX0 default again with exact profile active. | checking |

- H62 live result: all-MUX0 restored a live second bank (`desc48=[0,8192,256,...]`), so the constant `-19689` tail was caused by `$0110`. Acceptance still fails: sample0 `good=2/48`, sample1 `good=1/48`, TIn missing. Keep all-MUX0 as the safer default, continue with channel code/ME048 programming.

| H63 | Rev14.1 should use the original `MIC140_48v2` 24-bit ME048 packing while keeping the stable 48-word payload and all-MUX0 descriptors. The previous v2-packing test was done before row extraction stopped requiring exact Recorder +/-20 matching. | Patch only ME048 AIn/ground packing to `Mic140v2PackMe04848v2` / `Mic140v2PackLevel0Me04848v2`, rebuild, run 3 s preview, compare stream health and `block1 sample0/sample1`. | Rejected. The device stopped normally, not hung (`stopped blocks=0`), but no rows were published; every 96-word packet had very poor profile matches (`full48` mostly 0..3/48) and raw heads moved to `-17xxx/-8xxx/...`. Reverted to the previous 16-bit ME048 packing. | rejected |
| H64 | The window activity reported by the operator is Recorder/RecorderLnx UI activity, not a MIC-140 hard hang. | Reran live preview after the clarification. | Confirmed again. Current run reads and publishes normally (`pub=18 read=18 ratio=100%`, no gaps, no soft restart) and stops cleanly. Reboot is not required for this state. | confirmed |
| H65 | Antigravity's hardware-settings theory exposes a real RecorderLnx bug: migrated per-channel MIC-140 settings in `dataSources/mic140/channels` are ignored by parts of the active path, so range/commut/hardware calibration can diverge from Recorder/UI settings. | Inspected `PrepareHardware` and `ProcessAndPublishBlock`. Programming recreated defaults from the tag and ignored source config; publishing checked `lTag.HardwareCalibrationEnabled` instead of `RecorderMic140TagHardwareCalibrationEnabled(...)`. Built and ran live preview after the fix. | Implemented and build OK. Live preview remained transport-clean (`pub=18 read=18`) but still failed exact raw ADC/TIn acceptance. Current project JSON has no saved `commutIndex`, so descriptors stayed all-MUX0 (`desc1/desc48=$0100`). This is a real config-path fix, not the root cause of the raw ADC mismatch. | implemented |
| H66 | The user's `102 WORD` idea should be tested as the minimal current-base layout: 48 AIn + 3 visible TIn pointers, no ground pointers, AIn descriptors unchanged, TIn descriptors from MIC140_48, `PayloadStride=51`. | Patched only `uRecorderMic140v2Scan.pas`, built, ran `mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0`. | Rejected in this direct form. The device/app stopped normally and produced `DATA=102`, but acceptance regressed to `pub=2/read=2`; TIn was present but wrong (`T1=-19690`, `T2=-19689`, `T3=18594` instead of `8844/9019`). Reverted scan back to stable 48 AIn payload. No reboot required. | rejected |

## Current live fact after H64
- The active 48-word payload is healthy as a transport: latest log shows `header=OK size=106 data=96 samples=2 stride=48`, `read=18`, `published=18`, `readGaps=0`, `publishGaps=0`, `softRestart=0`, normal stop.
- Acceptance still fails: every published block violates the exact Recorder ADC profile and no real TIn line is present (`tin=no TIn line`).
- The current network payload is `2 * 48 WORD` per block, not `2 * 51 WORD`; TIn is not present in the live payload under the current scan program.

## 2026-07-23: разделение legacy и MIC-140-48v3

| ID | Гипотеза | Проверка | Результат | Статус |
| --- | --- | --- | --- | --- |
| H67 | Расхождение вызвано неверным диапазоном `-20..80 мВ`. | Сопоставлены `ranges_mi118`, `ampl1_mc114v5`, `ampl2_mc114v5`, `SetRangeIndex` оригинала и живой дамп дескриптора RecorderLnx. | Оригинал и порт дают `hard_amplif=100`, `amplif=1`, итоговый `desc=$0100`. Диапазон не является причиной. | rejected |
| H68 | Один физический MIC-140 допускает два разных штатных профиля программирования, которые нельзя смешивать при сравнении кодов. | Пользователь добавил тот же IP в оригинальном Recorder другим типом/профилем. Legacy дал AIn1..24 около `-6 тыс.`, AIn25..48 около `-14..-18 тыс.`, `count_aver=344`, ground включён. MIC-140-48v3 без ground ранее дал индивидуальные коды каналов и `count_aver=298`. | Подтверждено. Текущий RecorderLnx лог `rev=14.1`, `slots=60`, `stride=55`, `count=298`, `desc0=[0,128,256,...]` соответствует именно v3, а не legacy. | confirmed |

Правило приёмки: эталонные коды сравнивать только внутри одного аппаратного
профиля. Для текущей задачи эталоном является `MIC-140-48v3`, без заземления,
с семью видимыми TIn и `count_aver=298`. Набор legacy с `count_aver=344` не
использовать для оценки правильности v3, хотя он работает с тем же IP.

| H69 | В тестовом приложении профиль и аппаратная ревизия были смешаны условием `DevRev >= 14 => v3`. | Введены отдельные `TMic140ProgrammingProfile` и `TMic140HardwareProtocol`. Тест явно передаёт `mppMic14048v3`; аппаратный формат после `Init` выбирается по считанному `DevRev` (`<12` legacy, `>=12` 48v2), карта — по `DevSubRev`. | Реализовано. Обе сборки успешны. Живая проверка отложена: `192.168.14.48:4000` сейчас не принимает TCP, локальных Recorder/Mic140 процессов нет. | implemented |
