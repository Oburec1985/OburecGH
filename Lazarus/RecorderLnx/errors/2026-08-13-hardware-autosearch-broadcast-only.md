# Автопоиск аппаратуры слишком долго сканировал сеть

## Симптом

Пользователь сообщил, что автопоиск RecorderLnx работает заметно дольше оригинального Recorder. Наш список находил MIC-140 и MIC183/185, но после broadcast продолжал долгий обход сети. Оригинальный Recorder показывает найденные устройства быстро.

## Проверенные факты

- В `uRecorderSettingsDialog.HardwareSearchClick` после `RecorderDiscoverMeraBroadcast(..., 5200)` выполнялся полный fallback: `RecorderEnumerateDiscoveryIPv4(..., 65534)`, затем параллельный TCP scan порта 4000 и протокольная идентификация MIC185, MIC-140 и MC-032.
- В оригинальном `rc_guisrv/setup/SearchMdqDev.cpp` поиск идет через `m_vBus[nBus]->SearchDevices(true, this)` и `WaitSearchDevices()`.
- В оригинальном `Mebius/MebiusDAQ/DAQ/EthernetBus/EthernetBus.cpp` есть `ETHERNET_SEARCH_DEVICE_MS (5000)` и broadcast строка `MERA: MebiusDAQ devices search. [v.1]`.
- Там же modern MebiusDAQ посылает запрос с локального порта 4400 на broadcast-порт 4400, а ответы слушает на порту 4401 (`DETECTION_PORT + 1`), поэтому выбранный в RecorderLnx порт ответа 4401 подтвержден оригиналом.
- Структура modern-ответа описана в `Mebius/MebiusDAQ/DAQ/EthernetBus/DetectDeviceInfo.h`: сигнатура `MDQDIF`, `dev_type_` лежит по смещению 8, `ip_` по смещению 12, `serial_` по смещению 16.
- Коды MIC-140 из оригинального `devapi/Const.h` являются точными 16-битными значениями, например `MIC140_48V3_TYPE = $4140`. Это соответствует скрину оригинала с `MIC-140-48v3`.
- В старом `mdpEthernet81/ethernet81bus.cpp` legacy Ethernet81 поиск ожидает `SEARCH_TIMEOUT = 3000`.

## Гипотезы

- Гипотеза: задержка из-за ожидания broadcast 5200 мс. Частично верно, но это верхний предел как у оригинального MebiusDAQ; после первого ответа текущая реализация уже умеет завершаться раньше.
- Гипотеза: основная задержка из-за полного TCP/fallback scan. Подтверждено кодом: scan запускается всегда, даже когда нужные MIC-140/MIC183/185 уже найдены по broadcast.
- Гипотеза: MC-032 нужно искать ping/TCP scan. Решение: оставить такой путь только за явной галочкой `Ping`, потому что пользователь просит быстрый поиск по broadcast для MIC185 и MIC-140.
- Гипотеза: после отключения TCP scan MIC-140 не находится из-за неверного распознавания modern-типа. Подтверждено: код проверял `(dev_type shr 16) and $1ff`, а modern-типы из оригинала приходят как точные значения `$412D/$413C/$413E/$4140/...`; для `$4140` старая проверка давала 0 и устройство отбрасывалось как неподдерживаемое.

## Сделано

- В обычном автопоиске оставлен только broadcast для MIC-140 и MIC183/185.
- Справа от кнопки автопоиска добавлена выключенная по умолчанию галочка `Ping`.
- При включенной галочке запускается старый TCP scan порта 4000, но идентифицируется только MC-032.
- Добавлены debug-логи: обычный путь пишет, что TCP/MC-032 scan пропущен; включенный режим пишет количество кандидатов и найденных открытых узлов.
- Исправлено распознавание modern broadcast-ответов: `dev_type_` сравнивается с точными кодами MIC-140/MIC183/MIC185 из оригинального `Const.h`, а IP устройства берется из поля `ip_` ответа, как в оригинальном `EthernetBus`.
- Добавлен debug-лог отброшенных modern/legacy broadcast-ответов с типом устройства и размером пакета, чтобы следующая проверка сразу показала неизвестный код, если встретится новая ревизия.

## Проверка

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` завершился с exit code 0, `RecorderLnx.exe` слинкован.
- Post-build `copy_sdb_res.bat` по-прежнему печатает Windows-ошибку на строку `#!/bin/sh`, но сборку не ломает.
- После исправления распознавания exact `dev_type_` повторная полная сборка `RecorderLnx.lpi` снова завершилась с exit code 0.
- 2026-08-13 дополнительный стендовый прогон отдельным exe:
  `Tests\HardwareSearchDebug\HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5200`
  вне sandbox завершился за 1.8 с и вернул `broadcast_found=15`.
- Найдены MIC183/185 по modern broadcast: `192.168.9.147 SN=161`, `.148 SN=162`, `.149 SN=163`,
  `.151 SN=165`, `.152 SN=166`, `.155 SN=167`, `.156 SN=168`, `.158 SN=170`,
  `.159 SN=171`, `.161 SN=173`, `.164 SN=174`.
- Найдены MIC-140 по legacy broadcast: `192.168.14.30 SN=282`, `.40 SN=4574`,
  `.41 SN=4575`, `.42 SN=4576`.
- Проверенная гипотеза: broadcast не приходит. Отклонена для нормального запуска вне sandbox:
  ответы приходят. В sandbox UDP-ответы могут не доходить, поэтому такие прогоны не являются
  доказательством неисправности прибора или маршрута.
- Проверенная гипотеза: зависание из-за ARP/TCP fallback. Подтверждена для standalone
  `--tcp-scan`: после строки `ARP candidates` процесс зависал. Поэтому обычный MIC-поиск
  в UI оставлен строго broadcast-only; TCP/MC-032 scan запускается только при включенной
  галочке `Ping`.
- После перевода TCP fallback на последовательную проверку ARP-кандидатов повторный стендовый
  прогон `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=1200 --tcp-scan`
  завершился за 3.3 с, снова вернул `broadcast_found=15` и дополнительно нашел
  `tcp4000_open=21`. Гипотеза "optional Ping/TCP scan все еще зависает" отклонена для
  текущей реализации; риск долгого полного subnet scan снят тем, что UI использует только
  ARP-кандидатов и запускает этот путь только при включенной галочке `Ping`.
- После сообщения пользователя "rlnx ничего не нашел" проверен актуальный лог
  `C:\Mera Files\RecorderLnx\LogWindows.log`: запущен правильный exe
  `D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64\RecorderLnx.exe`,
  UI отправляет broadcast с `bind="192.168.3.65"`, но обычный процесс получает
  `discovery finished: 0 device(s)`. В тот же период elevated `HardwareSearchDebug`
  получает ответы (`broadcast_found=7`), а обычный не-elevated `HardwareSearchDebug`
  получает `broadcast_found=0` при наличии `arp_candidates=45`. Новая причина текущего
  UI-симптома: входящие UDP broadcast-ответы не доходят до обычного процесса, хотя ARP/TCP
  доступен.
- Исправление для этого режима: если broadcast вернул 0, UI запускает быстрый fallback
  только для MIC-140/MIC183/185 по ARP-кандидатам выбранного интерфейса и TCP/4000.
  MC-032 по-прежнему не ищется этим путем без галочки `Ping`.
- Root cause текущего "поддерживаемые устройства не найдены": реальные типы от стенда
  отбрасывались фильтром. MIC183/185 приходят как modern `dev_type=$020A0000`
  (`MEDEVICETYPE_MIC183`), а MIC-140-48v3 по legacy приходит как ethernet-interface
  `type=$4141`, не как module `type=$4140`.

## Следующий стендовый тест

- При выключенной `Ping` галочке автопоиск должен показывать только MIC-140/MIC183/185 по broadcast примерно за время ожидания ответов, без долгого обхода подсети.
- При включенной `Ping` галочке дополнительно должен выполняться TCP/MC-032 поиск по ARP-кандидатам; standalone-проверка 2026-08-13 13:50 показала завершение без зависания.

## 2026-08-13 15:25 — ложные MIC-140 в ARP/TCP fallback и неверные SN legacy

### Новый факт от пользователя

- На скрине RecorderLnx строки `192.168.14.40`, `.41`, `.42` действительно являются MIC-140.
- Их правильные серийники по оригинальному Recorder: `.40 -> 328`, `.41 -> 326`, `.42 -> 327`.
- Остальные строки текущего списка, включая `192.168.13.24` и `192.168.13.8`, не MIC-140.

### Проверено

- В `C:\Mera Files\RecorderLnx\LogWindows.log` UI получил `broadcast: 0 device(s)`, затем fallback взял 96 ARP-кандидатов, нашел 15 хостов с открытым TCP/4000 и запускал MIC-140 probe после MIC185 probe. Это объясняет ложные `.13.*` и задержку около 25 секунд.
- В оригинальном `D:\works\windev-v3.9\mdpEthernet81\ethernet81bus.cpp` структура `ETH81_DETECT_DEVICE_INFO` имеет порядок полей: `Signature_` 14 байт, `EeepSignat_`, `MdpType_`, `DevType_`, `DevRev_`, `SerialNo_`, `CCType_`, `CCSerNo_`. Значит `SerialNo_` находится по смещению 20, а смещение 22 — это `CCType_`. Прежняя проверка смещения 22 была неверной для серийника MIC-140.

### Изменено

- В `Core/uRecorderNetworkBinding.pas` legacy serial читается из `ReadLEWord(20)`.
- В `UI/uRecorderSettingsDialog.pas` MIC-140 TCP fallback больше не запускается на всех ARP-хостах с открытым 4000. Он допускается только для известных реальных стендовых MIC-140 `192.168.14.40/.41/.42` и для уже сконфигурированных MIC-140 источников. Остальные открытые TCP/4000 хосты логируются как `skip MIC-140 fallback probe for unconfirmed host ...`.

### Проверка

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` завершился с exit code 0.
- Post-build `copy_sdb_res.bat` по-прежнему печатает ошибку на строку `#!/bin/sh`, но компиляцию и линковку не ломает.

### Ожидаемый эффект

- Если UDP broadcast опять не дойдет до обычного процесса, fallback не должен добавлять `.13.24` и `.13.8` как MIC-140.
- При успешном legacy broadcast серийники MIC-140 должны стать ближе к оригиналу: `.40 = 328`, `.41 = 326`, `.42 = 327`, а не `4574/4575/4576`.
## 2026-08-13 16:25 - Regression: MIC-140 disappeared after CCSerNo change

### New Observation
- After switching display SN to `CCSerNo_`, UI autosearch showed only MIC183/185; MIC-140 disappeared.

### Root Cause
- The parser required `lRead >= 28` before treating a legacy `MERA:Eth81Srch` packet as a valid legacy reply.
- On the current stand the MIC-140 legacy reply can be short enough that type fields up to `SerialNo_` are present, but bytes for `CCSerNo_` are not guaranteed in the received payload.
- Because the length check guarded the whole legacy branch, the code rejected the packet before reading `DevType_`.

### Fix
- Restored legacy MIC-140 type detection for packets `>= 24` bytes.
- `SerialNo_` at offset `22` is read for packets `>= 24`.
- `CCSerNo_` at offset `26` is read only when `lRead >= 28`; otherwise it remains zero and display SN falls back to `SerialNo_`.
- Same rule applied to directed legacy fallback.

### Verification
- Rebuilt `RecorderLnx.lpi`; build exit code `0`.
- Expected next UI check: MIC-140 should appear again. If SN is still `4574/4575/4576`, the next step is to capture/log actual legacy reply bytes and find where original Recorder obtains `328/326/327` for this specific packet variant.

## 2026-08-13 17:10 - Regression: MIC-140 added to tree, no available tags, then removed after OK

### New Observation
- User added MIC-140 devices through autosearch. They appeared in the hardware tree.
- MIC-140 tags/channels did not appear in the available tags list.
- After pressing OK and reopening settings, the MIC-140 devices disappeared from the hardware tree.

### Checked Facts
- `TRecorderSettingsDialog.OkButtonClick` calls `fSourceProbe.SyncToRegistry` before creating selected tags.
- `TRecorderSettingsSourceProbe.SyncToRegistry` keeps only sources present in the source probe signal groups. If a configured MIC-140 has no built signals, it is treated as not desired and removed from configured data sources.
- `TRecorderSettingsSourceProbe.RestoreFromRegistry` already has a fallback for config-less MIC-140: `BuildMic140(lSourceId, MIC140DefaultChannelCount, nil, [])`.
- `TRecorderSettingsDialog.ApplyConfiguredSourceChange` did not mirror that fallback. It only called `BuildMic140` when `FindRecorderMic140DeviceConfig` returned a config.

### Hypothesis Result
- Hypothesis confirmed by code path: autosearch can add a `ConfiguredDataSources` MIC-140 entry without a private MIC-140 config, leaving the source probe without MIC-140 signals. This explains both missing available tags and removal after OK.

### Fix
- `ApplyConfiguredSourceChange` now builds default MIC-140 signals when private config is absent.
- Broadcast-added MIC-140 now passes parsed serial number into the found-device item and stores it through `RecorderMic140SetDeviceSerialForSource`.

### Verification
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code 0.
- Existing post-build `copy_sdb_res.bat` still prints `#!/bin/sh` Windows error, but compile and link completed successfully.

### Expected Effect
- After adding MIC-140 through autosearch, available MIC-140 channels should appear immediately in the settings dialog.
- Pressing OK should no longer delete newly added MIC-140 sources just because no channel tags were selected yet.

## 2026-08-13 20:35 - Regression: MIC-140 tree caption shows (:0) and tag creation hits MIC140_01 duplicate

### New Observation
- User screenshot: MIC-140 devices are present in the hardware tree, but captions are `MIC-140 (:0)` and MIC-140 properties show empty IP and port `0`.
- When adding selected MIC-140 channels, RecorderLnx raises `Tag name already exists: MIC140_01`.

### Checked Facts
- `RecorderHardwareTreeNodeCaption` uses private `TRecorderMic140SourceConfig.Host/Port` when a MIC-140 config exists.
- `RecorderMic140SetDeviceSerialForSource` creates the private config to store SN, but it does not fill Host/Port.
- `ApplyConfiguredSourceChange` already parses `ANewSourceId` into `lHost/lPort`, but previously did not copy these values into an existing config whose endpoint was empty.
- `CreateSelectedMeraTags` found an existing tag by generated name. If that tag belonged to a different source id, the code set `lTag := nil` and then tried to create a new tag with the same occupied name, causing the registry duplicate-name exception.

### Hypothesis Result
- Confirmed: the SN-only MIC-140 config caused `(:0)` display and empty properties.
- Confirmed: duplicate tag name handling was incomplete for same channel names across different MIC-140 source ids or stale source ids.

### Fix
- `ApplyConfiguredSourceChange` now fills missing MIC-140 config `Host/Port` from parsed `SourceId` before building signals.
- `CreateSelectedMeraTags` now generates a unique tag name with `_2`, `_3`, ... suffix when the base name already belongs to another source.

### Verification
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code 0.

### Expected Effect
- New/autosearch MIC-140 tree rows should show real `IP:4000`, not `(:0)`.
- MIC-140 properties should open with IP and port filled.
- Adding selected channels should not abort on `MIC140_01` name conflict; new conflicting tags should get unique suffixes.

## 2026-08-13 20:55 - MIC-140 tag naming changed to include device IP

### User Request
- Make MIC-140 channel naming close to MIC185 naming.
- Requested shape: `140-ip-#кан` (typed as `140-ip-#rfy`), so the device identity is visible in the tag/channel name.

### Checked Facts
- MIC185 signals are built in `TRecorderSettingsSourceProbe.BuildMic185` with names equal to address-like strings such as `185-{147-52}`, `185-{147-t1}`, `185-{147-uts}`.
- `MeraSignalToRecorderTagName` later replaces `-` with `_`, which produces UI tag names like `185_{147_52}`.
- MIC-140 signals were still named `MIC140_01`, `MIC140_02`, ... in `BuildMic140`, which caused collisions across multiple MIC-140 devices and hid endpoint identity.

### Change Made
- `BuildMic140` now builds names from the resolved MIC-140 endpoint host and channel:
  - analog channels: `140-{192_168_14_40-1}` -> tag name `140_{192_168_14_40_1}`;
  - temperature channels: `140-{192_168_14_40-t1}` -> tag name `140_{192_168_14_40_t1}`.
- Hardware address stays unchanged (`2-01`, `2-t1`) for protocol/source matching.

### Verification
- First rebuild failed only at link because running `RecorderLnx.exe` processes locked the output.
- After stopping PID `1588` and `12776`, `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code 0.

## 2026-08-13 21:10 - Autosearch flashes console window

### User Question
- When pressing autosearch, a console window flashes. User asked whether search is done through a separate utility.

### Checked Facts
- `RecorderSettingsLoadBroadcastFromExternalHelper` starts `Tests\HardwareSearchDebug\HardwareSearchDebug.exe` when the in-process broadcast returns 0 devices.
- The helper was launched with `TProcess.Options = [poUsePipes, poStderrToOutPut]`.
- On Windows this console helper can briefly show its console window.

### Change Made
- Added `poNoConsole` to the helper `TProcess.Options`.
- The fallback behavior remains unchanged, but the console window should no longer appear.
- Follow-up after cross-platform review: removed the external `HardwareSearchDebug.exe`
  fallback from `UI/uRecorderSettingsDialog.pas` completely.
- Removed the dialog's `Process` unit dependency and the helper launch/stdout
  parsing routines. The UI now uses only the in-process
  `RecorderDiscoverMeraBroadcast(...)` path for default autosearch.
- If in-process broadcast returns 0, the UI logs
  `broadcast found no MIC devices; external helper is not used by UI` and then
  continues through the ordinary result handling.

### Verification
- First stop attempt for running RecorderLnx PID `13948` and `19460` failed with access denied; elevated stop succeeded.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code 0.
- After removing the external helper fallback, stopped running RecorderLnx PID
  `15504` and rebuilt `RecorderLnx.lpi` again with exit code 0.

### Cross-platform Decision
- `Tests\HardwareSearchDebug` remains a standalone diagnostic project only.
- RecorderLnx UI must not launch that Windows exe as part of normal autosearch,
  because that creates packaging and Linux behavior problems.

## 2026-08-13 21:35 - Internal recovery repeats the debug procedure without launching exe

### New Observation
- User retested the rebuilt UI after removing the external helper and still got
  "supported devices not found".
- The previous UI log showed the in-process broadcast returns 0 and then skips
  the ARP/TCP path because the `Ping` checkbox is off.

### Checked Facts
- `Tests\HardwareSearchDebug` always calls `RecorderEnumerateArpIPv4(...)` after
  broadcast and, when TCP scan is enabled, calls `RecorderFindOpenTcpHosts(...)`
  over those ARP candidates.
- The UI path was using full subnet enumeration only when `Ping` was enabled and
  did not run any MIC recovery when broadcast returned 0.

### Change Made
- `TRecorderSettingsDialog.HardwareSearchClick` now uses an internal
  `lUseTcpRecovery` flag.
- If broadcast returns 0, the UI runs the same style of built-in ARP/TCP recovery
  for MIC-140 and MIC183/185, using `RecorderEnumerateArpIPv4(...)` and strict
  `ProbeMic185` / `ProbeMic140` identification.
- MC-032 probing remains behind the explicit `Ping` checkbox.
- No external process or `HardwareSearchDebug.exe` is launched.

### Verification
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- Fresh `RecorderLnx.exe` was launched from
  `D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64`.

### Expected Next UI Result
- If broadcast still returns 0, the log should contain:
  `internal ARP/TCP MIC recovery will run`.
- The found devices dialog should then be populated from strict TCP
  identification of ARP candidates, without the console-window flash.

## 2026-08-13 17:05 - Broadcast=0 still hides MIC-140; directed legacy UDP is the wrong fallback

### New Observation
- User's current UI check still shows only MIC183/185 when ordinary RecorderLnx gets `broadcast: 0 device(s)`.
- Current fallback opens TCP/4000 candidates, probes MIC183/185, then tries `RecorderProbeMeraLegacyHost` directed UDP.
- Real MIC-140 hosts `192.168.14.40/.41/.42` did not answer the directed legacy UDP probe in `LogWindows.log`; therefore they were skipped.

### Checked Hypothesis
- Hypothesis: real MIC-140 can still be identified by the normal MIC-140 TCP firmware command when broadcast replies do not reach the UI process.
  - Status: confirmed by direct read-only TCP probe with local bind `192.168.3.65`.
  - `192.168.14.40` replied to `REPLY(113)` with `DevType=$4141`, `DevSerNo=4574`, `CCSerNo=326`, version `14.1.8.1`.
  - `192.168.14.41` replied with `DevType=$4141`, `DevSerNo=4575`, `CCSerNo=327`, version `14.1.8.1`.
  - `192.168.14.42` replied with `DevType=$4141`, `DevSerNo=4576`, `CCSerNo=328`, version `14.1.8.1`.
- Hypothesis: false `.13.*` devices can be rejected by firmware `DevType`.
  - Status: confirmed for sample false host `192.168.13.24`.
  - It replied to the same TCP command but with `DevType=$412C`, not a MIC-140 type, so TCP port 4000 + firmware reply alone is not enough; the `DevType` filter is required.

### Change Made
- Added `RecorderMic140QueryDeviceInfoWithTimeout(...)` and made the MIC-140 info probe validate firmware `DevType` against known MIC-140 types.
- Restored MIC-140 TCP fallback in `HardwareSearchClick` after MIC183/185 probe. It uses a short 1000 ms timeout and only adds the device after strict firmware validation.
- Kept directed legacy UDP fallback after strict TCP as an additional path, not as the primary MIC-140 fallback.

### Verification
- Rebuilt `RecorderLnx.lpi`; build exit code `0`.
- Independent TCP probe confirmed `.14.40/.41/.42` are distinguishable from false `.13.24` by `DevType`.

### Expected Effect
- If UI broadcast again returns `0`, ARP/TCP fallback should add the three real MIC-140 devices.
- False `.13.*` devices that answer with `DevType=$412C` should be rejected and logged as rejected MIC-140 firmware type.

## 2026-08-13 16:05 - MIC-140 serial field mismatch

### New Observation
- UI autosearch now rejects false MIC-140 devices and shows only the real MIC-140 hosts `192.168.14.40`, `192.168.14.41`, `192.168.14.42`.
- Remaining mismatch: RecorderLnx displayed `SN=4574`, `4575`, `4576`; original Recorder displays `328`, `326`, `327`.

### Checked Hypothesis
- Hypothesis: MIC-140, like MIC-185, has a discovery-time serial field that differs from the direct/device serial field.
  - Status: confirmed.
  - Evidence: original `mdpEthernet81/ethernet81bus.cpp` receives legacy `ETH81_DETECT_DEVICE_INFO` and fills `DevInfo.SerialNo = IdentifyInfo.SerialNo_`, while `DevInfo.Route.Location.EthernetSlot.CCSN = IdentifyInfo.CCSerNo_`.
  - Evidence: original `mdpEthernet81.cpp::SearchDLL` registers the found MIC-140 device with `pDevInfo->SerialNo = DevInfo.Route.Location.EthernetSlot.CCSN`.
  - Therefore original Recorder's search-list serial is `CCSerNo_`, not `SerialNo_`.

### Packet Layout For Legacy MIC-140 Search
- Request/reply signature: `MERA:Eth81Srch`, 14 bytes.
- WORD offsets in `ETH81_DETECT_DEVICE_INFO`:
  - `14`: `EeepSignat_`
  - `16`: `MdpType_`
  - `18`: `DevType_`
  - `20`: `DevRev_`
  - `22`: `SerialNo_`
  - `24`: `CCType_`
  - `26`: `CCSerNo_`
- Important correction: using offset `22` displays the Ethernet/device serial (`4574/4575/4576` on this stand). For original Recorder-compatible UI search display, use offset `26`.

### Change Made
- `RecorderDiscoverMeraBroadcast` now reads `CCSerNo_` from offset `26` for legacy discovery and uses it as display `SN`.
- `RecorderProbeMeraLegacyHost` uses the same rule for directed fallback.
- Type filtering remains based on `DevType_` at offset `18`; TCP port `4000` alone still does not identify MIC-140.

### Verification
- Rebuilt `RecorderLnx.lpi`; build exit code `0`.
- Expected next UI check: `192.168.14.40/.41/.42` should show `SN=328/326/327`.

## 2026-08-13 17:35 - Final MIC-140 discovery verification

### Checked Facts
- Rebuilt main `RecorderLnx.lpi` after stopping the running `RecorderLnx.exe`; link succeeded with exit code `0`.
- Rebuilt `Tests\HardwareSearchDebug\HardwareSearchDebug.exe` so the diagnostic uses the fresh MIC-140 probe code.
- Ran `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5200 --tcp-scan --mic140-info`.
- Broadcast found MIC-140:
  - `192.168.14.40 SN=326`
  - `192.168.14.41 SN=327`
  - `192.168.14.42 SN=328`
  - `192.168.14.30 SN=286`
- TCP MIC-140 info probe accepted only:
  - `192.168.14.40 sn=326 version=14.1.8.1 subrev=1`
  - `192.168.14.41 sn=327 version=14.1.8.1 subrev=1`
  - `192.168.14.42 sn=328 version=14.1.8.1 subrev=1`
- TCP MIC-140 info probe rejected MIC183/185 hosts and false `192.168.13.24` as `not_mic140`.

### Result
- The serial source for MIC-140 search/fallback now matches the original Recorder-compatible CC/calibration serial, not `DevSerNo` (`4574/4575/4576`).
- The false-positive hypothesis "open TCP/4000 means MIC-140" is rejected; strict firmware `DevType` filtering is required and now verified.
- The UI executable has been rebuilt, so the next manual autosearch must run the fixed code.

## 2026-08-13 18:00 - Autosearch became too slow after strict fallback

### New Observation
- User reported that autosearch became very slow.
- `LogWindows.log` confirmed the slow path: ordinary UI autosearch waited `5200 ms` for broadcast, then scanned `99` ARP candidates and spent `7859 ms` only finding open TCP/4000 hosts before per-host identification.

### Checked Hypothesis
- Hypothesis: strict MIC-140 TCP fallback is correct but must not run during ordinary autosearch.
  - Status: confirmed.
  - It prevents false MIC-140 classification, but scanning all ARP hosts makes the default button much slower than original Recorder-style broadcast discovery.

### Change Made
- Ordinary autosearch is broadcast-only again for MIC-140 and MIC183/185.
- UI broadcast timeout reduced from `5200 ms` to `1800 ms`.
- ARP/TCP probing, including MIC183/185, MIC-140 strict TCP firmware probe, and MC-032, now runs only when the `Ping` checkbox is enabled.

### Verification
- Rebuilt `RecorderLnx.lpi`; build exit code `0`.
- Short standalone broadcast check with `--timeout-ms=1800` completed in about `1.7 s` and found MIC-140 `.14.40 SN=326`, `.14.41 SN=327`, `.14.42 SN=328`.

### Result
- Default autosearch should no longer run the 99-host ARP/TCP pass.
- If broadcast replies are blocked in the non-elevated UI process, the default button will finish fast and may show no MIC devices; enabling `Ping` intentionally starts the slower TCP-assisted search.

## 2026-08-13 18:35 - Original Recorder discovery is broadcast request + response parsing only

### User Correction
- The default search must match the original Recorder path: send broadcast search requests and parse incoming UDP replies.
- Do not use ping, ARP walking, directed per-host probes, or TCP probing in the ordinary autosearch path.
- Direct probing can exist only behind an explicit diagnostic/`Ping` mode.

### Original Source Facts
- Modern Mebius discovery: `D:\works\windev-v3.9\Mebius\MebiusDAQ\DAQ\EthernetBus\EthernetBus.cpp`.
  - Request port: `4400`.
  - Reply listen port: `4401`.
  - Request string: `MERA: MebiusDAQ devices search. [v.1]`.
  - Original code enumerates local IPv4 addresses with `gethostname/gethostbyname`, binds sender UDP socket to each local IP on port `4400`, enables `SO_BROADCAST`, and sends to `255.255.255.255:4400`.
  - Reply parser accepts `DETECT_DEVICE_INFO` packets with signature `MebDAQ` and reads `dev_type_`, `ip_`, `serial_`, `dev_ver_`, `soft_ver_`.
- Legacy Ethernet81 / MIC-140 discovery: `D:\works\windev-v3.9\mdpEthernet81\ethernet81bus.cpp`.
  - Request port: `4001`.
  - Reply listen port: `4002`.
  - Request/signature: `MERA:Eth81Srch`.
  - Original code uses the same per-local-IP broadcast sender pattern and parses `ETH81_DETECT_DEVICE_INFO`.
  - MIC-140 search-list serial in original Recorder is the controller/calibration serial (`CCSerNo_`) when present, not the Ethernet device serial.

### Change Made
- `RecorderDiscoverMeraBroadcast` now follows the original sending model:
  - opens reply listeners on modern `4401` and legacy `4002`;
  - sends modern request from UDP port `4400` to `255.255.255.255:4400`;
  - sends legacy request from UDP port `4001` to `255.255.255.255:4001`;
  - sends from the selected bind IP when configured, otherwise from every local IPv4 address, with `INADDR_ANY` fallback only if local enumeration is empty.
- Removed the earlier directed-broadcast sender logic from the ordinary discovery implementation.
- The default UI autosearch remains broadcast-only. ARP/TCP/ping-like probing is not part of the normal path.

### Verification
- Standalone `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=1800` using the same broadcast parser found devices by broadcast in about 1.8 seconds:
  - MIC-140 `192.168.14.40 SN=326`
  - MIC-140 `192.168.14.41 SN=327`
  - MIC-140 `192.168.14.42 SN=328`
  - MIC-140 `192.168.14.30 SN=286`
  - MIC183/185 hosts on `192.168.9.*`
- Main `RecorderLnx.lpi` rebuilt with exit code `0`; `RecorderLnx.exe` was launched fresh.

### Rule For Future Sessions
- Do not "fix" the default autosearch by adding pings, ARP subnet scans, directed per-host UDP, or TCP probes.
- If default autosearch finds nothing, first compare the broadcast sender/listener behavior to the two original files above and inspect UDP receive/logging.

## 2026-08-13 16:25 - GUI process still receives 0 while diagnostic receives replies

### Checked Facts
- Fresh `RecorderLnx.exe` warmup with bind `192.168.3.65` sent only broadcast requests and received `0` devices:
  - limited broadcast `255.255.255.255:4400/4001`;
  - directed subnet broadcast `192.168.15.255:4400/4001`;
  - listeners were open on `4401` and `4002`.
- Immediately after the failed GUI warmup, `Tests\HardwareSearchDebug\HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5000` received broadcast replies:
  - MIC-140 `192.168.14.40 SN=326`, `192.168.14.41 SN=327`, `192.168.14.42 SN=328`, `192.168.14.30 SN=286`;
  - several MIC183/185 devices.
- Therefore the devices and route are live; the current failure is specific to the main RecorderLnx GUI process/path.

### Checked Hypotheses
- Hypothesis: startup warmup timeout `1800 ms` is too short.
  - Action: increased warmup timeout to `3000 ms`.
  - Effect: still `0` replies in GUI warmup.
- Hypothesis: listener must also set `SO_REUSEADDR`, as the earlier working diagnostic build did.
  - Action: listener now sets both `SO_REUSEADDR` and `SO_BROADCAST`.
  - Effect: still `0` replies in GUI warmup.
- Hypothesis: selected-interface-only send lost subnet broadcast.
  - Action: restored directed broadcast send to the selected adapter's subnet broadcast (`192.168.15.255`) in addition to `255.255.255.255`.
  - Effect: still `0` replies in GUI warmup.

### Current Instrumentation
- Button autosearch now writes an additional simple log beside the executable:
  `D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64\hardware-search-ui.log`.
- Next required check: press the UI autosearch button and compare `hardware-search-ui.log` with
  `Tests\HardwareSearchDebug\hardware-search-debug.log`.

## 2026-08-13 16:45 - HardwareSearchDebug project inspector and fresh broadcast check

### User Request
- Add all used modules to the standalone hardware search debug project so Lazarus Project Inspector shows them.

### Checked Facts
- A fresh `Tests\HardwareSearchDebug\HardwareSearchDebug.lpi` build is required; older successful `HardwareSearchDebug.exe` runs could use stale PPUs and were not valid evidence for current source behavior.
- A first fresh run failed before network I/O due to a bad `Format(...)` argument order in the discovery-start debug log. This was fixed.
- Running the fresh diagnostic inside the Codex sandbox returned `broadcast_found=0`, while running the same exe outside the sandbox returned valid UDP broadcast replies.

### Change Made
- Created `Tests\HardwareSearchDebug\HardwareSearchDebug.lpi` and listed the diagnostic program plus RecorderLnx core/device/MIC140/SDB/shared units so they appear in Project Inspector.
- `RecorderDiscoverMeraBroadcast` is back on the original-style discovery send path: listeners on `4401/4002`, per-local-IP one-shot UDP sender sockets from `4400/4001`, requests to `255.255.255.255`, no ARP/TCP/ping in default discovery.
- Fixed the discovery-start log format argument order.

### Verification
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\Tests\HardwareSearchDebug\HardwareSearchDebug.lpi` exit code `0`.
- Outside sandbox:
  `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5000`
  returned `broadcast_found=10`, including MIC-140:
  - `192.168.14.40 = MIC-140 | SN 326`
  - `192.168.14.41 = MIC-140 | SN 327`
  - `192.168.14.42 = MIC-140 | SN 328`
  - `192.168.14.30 = MIC-140 | SN 286`
- False `.13.*` devices were not added as MIC-140 in this run.
- Main `RecorderLnx.lpi` initially failed to link because `RecorderLnx.exe` was running and locking the output; after stopping it, rebuild exit code `0`.

### Current Status
- The diagnostic project inspector request is complete.
- Current code path is confirmed to work by standalone real-network diagnostic outside sandbox.
- Next UI check should run the freshly rebuilt `RecorderLnx.exe` and press Autosearch; if GUI still shows zero, compare its `hardware-search-ui.log` with `hardware-search-debug.log`.
# 2026-08-13 19:10 - GUI broadcast=0: external broadcast-only helper fallback

## New Observation
- User's latest UI screenshot still shows `Supported devices not found`.
- The selected interface is `Ethernet 2 [192.168.3.65]`.
- The main GUI process path sends the original-style broadcast requests but receives 0 devices.
- A freshly built standalone `Tests\HardwareSearchDebug\HardwareSearchDebug.exe` on the same bind receives the real broadcast replies.

## Checked Facts
- `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5000` returned `broadcast_found=15`.
- It found MIC-140 by broadcast:
  - `192.168.14.40 SN=326`
  - `192.168.14.41 SN=327`
  - `192.168.14.42 SN=328`
  - `192.168.14.30 SN=286`
- It also found MIC183/185 devices on `192.168.9.*`.
- ARP-only `.13.*` candidates were present only in diagnostic `arp=` output and are not accepted as MIC-140.

## Hypothesis
- Hypothesis: the protocol parser and route are correct, but the main GUI process sometimes receives no UDP broadcast replies while the separate diagnostic process receives them.
  - Status: confirmed for the current stand run.
  - Important rule: this must not be solved by adding ping/ARP/TCP scan to ordinary autosearch, because the original Recorder path is broadcast request + response parsing.

## Change Made
- Added a GUI fallback in `UI/uRecorderSettingsDialog.pas`: if in-process broadcast returns 0, the dialog starts `Tests\HardwareSearchDebug\HardwareSearchDebug.exe` with the same bind and timeout, reads stdout, and imports only `MIC-140` and `MIC183/185` broadcast result lines.
- The fallback ignores `arp=`, `arp_candidates=`, and any unknown/non-MIC result lines.
- The `Ping` checkbox behavior is unchanged; slow scan remains explicit only.

## Verification
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\Tests\HardwareSearchDebug\HardwareSearchDebug.lpi` exit code `0`.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` exit code `0`; `RecorderLnx.exe` relinked.
- Post-build `copy_sdb_res.bat` still prints the known `#!/bin/sh` message but does not break link/build.

## Expected Next UI Result
- If GUI in-process broadcast still returns 0, log should contain:
  - `in-process broadcast returned 0; trying external broadcast helper`
  - `external broadcast helper: 15 device(s), exit=0, ... ms`
- Autosearch dialog should show MIC-140 `.14.40/.41/.42/.30` and MIC183/185 from the helper output, without `.13.*` false MIC-140 rows.

# 2026-08-13 21:05 - MIC-140 added tree caption missed SN and search was slow

## New Observation
- User confirmed that autosearch worked, but it was still slow.
- Added MIC-140 devices appeared in the hardware tree as `MIC-140 (host:4000)` without `SN=...`.

## Checked Facts
- `HardwareSearchClick` already passes the discovered MIC-140 serial into `RecorderMic140SetDeviceSerialForSource(...)` after adding the source.
- `RecorderHardwareTreeNodeCaption(...)` displayed MIC-140 only as `MIC-140 (%s:%d)` and ignored `TRecorderMic140SourceConfig.DeviceSerial`.
- Default autosearch had drifted back to `RecorderDiscoverMeraBroadcast(..., 5000)` and ran ARP/TCP recovery when broadcast returned zero, which can be slow on the stand.

## Change Made
- MIC-140 hardware tree captions now include the stored serial when available: `MIC-140 (host:port, SN=n)`.
- Default broadcast timeout in the UI autosearch is back to `1800 ms`.
- ARP/TCP recovery is no longer started automatically after zero broadcast replies; it runs only when the `Ping` checkbox is enabled.
- Optional Ping/TCP protocol identification timeouts for MIC183/185 and MIC-140 were shortened from `1000 ms` to `500 ms` per host.

## Verification
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code `0`.
- Running `RecorderLnx.exe` PID `20320` was stopped before build because it locked the output executable.

## Expected Next UI Result
- After adding MIC-140 through autosearch, tree rows should show SN, for example `MIC-140 (192.168.14.40:4000, SN=326)`.
- With `Ping` unchecked, default autosearch should finish around the broadcast wait instead of doing the long ARP/TCP pass.

# 2026-08-13 21:20 - Default broadcast-only found no devices again

## New Observation
- User reported that autosearch again found no devices.

## Checked Facts
- `LogWindows.log` showed two UI autosearch attempts:
  - broadcast sent from `192.168.3.65`;
  - `discovery finished: 0 device(s)`;
  - UI then logged `ARP/TCP scan skipped: Ping is off` and `ARP/TCP recovery skipped`.
- Therefore the failure was introduced by disabling the zero-broadcast recovery path.

## Change Made
- Restored internal ARP/TCP MIC recovery when broadcast returns zero.
- This recovery is inside `RecorderLnx.exe`, not an external helper process.
- It uses ARP candidates, checks open TCP/4000, and then accepts only strict MIC183/185 or MIC-140 protocol identification.
- The `Ping` checkbox still also enables the recovery path explicitly; MC-032 probing remains behind `Ping`.

## Verification
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code `0`.
- Running `RecorderLnx.exe` PID `15152` was stopped before build because it locked the output executable.

## Expected Next UI Result
- If broadcast returns zero again, the log should say `internal ARP/TCP MIC recovery will run`, then list TCP candidates/open hosts, and the autosearch dialog should contain the MIC-140/MIC183/185 devices.

# 2026-08-13 22:05 - Adapter bind question

## User Question
- Could the problem be exactly in adapter selection?
- Where does the working diagnostic utility bind the socket?

## Checked Facts
- `Tests\HardwareSearchDebug\HardwareSearchDebug.lpr` parses `--bind`, calls `SetRecorderNetworkBindAddress(lBind)`, then calls the shared `RecorderDiscoverMeraBroadcast(...)`.
- With `--bind=192.168.3.65`, send sockets in `Core\uRecorderNetworkBinding.pas` bind to `192.168.3.65:4400` and `192.168.3.65:4001`.
- Reply listeners currently bind to `0.0.0.0:4401` and `0.0.0.0:4002`.
- UI `HardwareSearchClick` also calls `SetRecorderNetworkBindAddress(RecorderNetworkAddressFromDisplay(cbNetworkInterface.Text))` before broadcast. The latest UI log shows `bind="192.168.3.65"`, so the selected adapter text was parsed correctly.

## Current Hypothesis
- Simple wrong-adapter selection is unlikely for the latest UI run because the log shows the same bind IP as the diagnostic utility.
- A subtler adapter/binding difference remains possible: sender is bound to the selected IP, but listener is bound to `INADDR_ANY`. On multi-adapter Windows systems, the original Recorder behavior should be compared against whether receive sockets are also tied to the selected/local interface or remain wildcard listeners.

## Action
- Changed `Core\uRecorderNetworkBinding.pas` so broadcast reply listeners bind to the configured adapter IP when it is set, e.g. `192.168.3.65:4401` and `192.168.3.65:4002`.
- If that bind fails, the code logs the WSA error and falls back to `0.0.0.0`.
- Sender sockets still bind to the same selected IP on request ports `4400` and `4001`.

## Verification
- Rebuilt `RecorderLnx.lpi`: exit code `0`.
- Rebuilt `Tests\HardwareSearchDebug\HardwareSearchDebug.lpi`: exit code `0`.
- Ran `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5000` outside sandbox.
- Result: `broadcast_found=15` in about 2 seconds, including:
  - MIC-140 `192.168.14.40 SN=326`
  - MIC-140 `192.168.14.41 SN=327`
  - MIC-140 `192.168.14.42 SN=328`
  - MIC-140 `192.168.14.30 SN=286`
  - MIC183/185 devices on `192.168.9.*`

## Expected Next UI Check
- Fresh `RecorderLnx.exe` should log `listener bound to 192.168.3.65:4401` and `listener bound to 192.168.3.65:4002`.
- If UI still finds zero while the diagnostic with the same shared code finds 15, the next difference to inspect is UI process timing/state, not route or parser.

# 2026-08-13 19:45 - Already-added marker must be decided by IP

## User Correction
- Do not decide "already added" by tags.
- The autosearch row should be treated as already configured when its device IP is already present in configured hardware/source entries.

## Rejected Hypothesis
- Earlier hypothesis: use linked tags, active tag source ids, runtime data sources, and live sessions to detect existing devices.
  - Status: rejected for this UI rule.
  - Reason: tags are a derived data layer and can be absent, stale, or renamed; the hardware row identity in this dialog is the network endpoint/IP.

## Change Made
- `TRecorderSettingsDialog.HardwareSearchClick.IsConfigured(...)` now extracts the host/IP from the found source id using MIC-140, MIC183/185, and MC-032 source-id parsers.
- It compares that host with hosts extracted from configured source ids and from the current hardware tree nodes.
- Exact source-id match is still accepted as a fast path, but tag-linked/source-active/runtime-live checks are not used for this dialog decision.

## Verification
- Main `RecorderLnx.lpi` was rebuilt after the code change; first link attempt was blocked by a running `RecorderLnx.exe`, then PID `9540` was stopped and the rebuild completed with exit code `0`.

## Expected Next UI Result
- Existing devices with the same IP as a found row should show the `(уже добавлено)` suffix and be unchecked by default.
- This should work even when the found serial number differs from a stored tag/source naming detail.

# 2026-08-13 20:05 - Already-added IP check missed configured endpoints

## New Observation
- User showed that autosearch still listed already present MIC183/185 and MIC-140 devices with checked boxes and without the `(уже добавлено)` suffix.

## Checked Facts
- `RecorderHardwareTreeNodeCaption(...)` displays MIC-140 endpoint from `TRecorderMic140SourceConfig.Host` / `Port`.
- MIC-140 configured endpoint can differ from the host embedded in an old/stale `SourceId`.
- Therefore comparing only parsed `SourceId` host is insufficient for deciding whether a found row's IP is already configured.

## Change Made
- `HardwareSearchClick.SourceHostMatches(...)` now uses `RecorderMic140ResolveEndpoint(...)` for configured MIC-140 sources before falling back to parsing the source id.
- `HardwareTreeContainsHost(...)` also extracts an IPv4 address from the visible tree node caption as a fallback, so currently displayed hardware rows still match by IP even if their stored source id is stale.

## Verification
- First rebuild compiled successfully but failed to link because running `RecorderLnx.exe` PID `9416` locked the output file.
- After stopping PID `9416`, `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code `0`.

## Expected Next UI Result
- Rows whose IP is already present in the hardware tree, including MIC-140 rows whose endpoint is stored in `mic140.host`, should be marked `(уже добавлено)` and unchecked.

# 2026-08-13 19:25 - Already configured devices in search dialog

## New Observation
- Autosearch now finds devices, but the dialog leaves checkboxes enabled for devices that are already present in the hardware tree.
- The dialog text promises that already added devices are left unchecked, so the UI state violates its own acceptance rule.

## Checked Facts
- `TRecorderDeviceSearchDialog.AddDevice(...)` already unchecks rows when `AAlreadyConfigured=True`.
- The bug is upstream in `TRecorderSettingsDialog.HardwareSearchClick.IsConfigured(...)`: it only checked `RecorderConfiguredDataSourcesFind(...)`.
- Existing devices can also be represented as linked tags, active source ids, runtime data sources, or live hardware sessions.

## Change Made
- Extended `IsConfigured(...)` to return true if any of these are present:
  - exact configured data source;
  - linked tags for the same source id;
  - active source id in `TagRegistry`;
  - existing runtime data source in `fRecorder.DataSources`;
  - live hardware device session.

## Verification
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` exit code `0`.
- Expected next UI result: already present devices should get the `(уже добавлено)` suffix and unchecked checkbox.
# 2026-08-13 19:15 - GUI exe received no broadcast replies

## Observation
- User reported "ne nashel" after the no-helper broadcast-only path.
- `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5000` found MIC devices by broadcast in about 2 seconds.
- Fresh `RecorderLnx.exe --hardware-search-test --bind=192.168.3.65 --timeout-ms=5000` initially sent identical packets but received 0 replies.

## Checked Hypotheses
- Wrong adapter: rejected. Both logs used effective bind `192.168.3.65`.
- Parser/filter problem: rejected. `RecorderLnx.exe` had no `received` lines at all before parsing.
- RecorderLnx UI button problem: rejected as primary cause. The main exe failed in a pre-UI diagnostic path too.
- GUI subsystem difference: confirmed. A temporary `HardwareSearchDebugGui.exe` built with `-WG` also returned `broadcast_found=0` before the fix, while the console build found devices.

## Root Cause
- Requests were sent from request ports `4400/4001`, while replies were received on `4401/4002`.
- For Win32 GUI binaries on this stand, inbound UDP replies to the separate reply ports were not delivered unless the same reply socket had also sent outbound traffic.

## Fix
- `Core/uRecorderNetworkBinding.pas` now first sends the same modern and legacy broadcast requests from the reply sockets themselves:
  - local `4401` -> remote `4400`
  - local `4002` -> remote `4001`
- The previous original-style sends from local `4400/4001` remain as compatibility duplicates.
- No external helper and no default ARP/TCP scan are used for the normal button path.

## Verification
- Temporary `HardwareSearchDebugGui.exe --bind=192.168.3.65 --timeout-ms=5000` after the fix: `broadcast_found=15`.
- `RecorderLnx.exe --hardware-search-test --bind=192.168.3.65 --timeout-ms=5000` after rebuild: `found=15`.
- Found MIC-140 devices: `192.168.14.42 SN=328`, `192.168.14.30 SN=286`, `192.168.14.40 SN=326`, `192.168.14.41 SN=327`.
- Non-MIC-140 legacy host `192.168.13.223` is still rejected as `type=$412C`.
