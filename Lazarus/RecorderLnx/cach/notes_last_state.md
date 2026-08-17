## 2026-08-17 - Channel settings tag import/export

**Request:** add tag list import/export in RecorderLnx channel settings, similar
to the original Recorder plugin that edited tags through Excel, but usable with
OpenOffice/LibreOffice.

**Done:** checked the original plugin at `D:\works\clients\3252\1.6.4`; it used
Excel COM/OLE and exported/imported tag metadata by table headers. Added
`Core/uRecorderTagTableExchange.pas` with non-visual fpspreadsheet-based
export/import and wired `Импорт...` / `Экспорт...` buttons into the channel
settings dialog. The import matches tags by `ID канала`, then by
`Источник + Адрес канала`, then by unique name. Editable fields now include
name, description, unit, poll frequency, auto unit/range and scale min/max.

**Notes:** fpspreadsheet runtime units were vendored under
`Lazarus/third_party/fpspreadsheet`; its nested `.git` and examples/tests were
removed. `.ods` and `.csv` are enabled. `.xlsx` support was not enabled because
the current fpspreadsheet OOXML unit did not compile with this Lazarus/FPC setup
(`FileNameIsAbsolute` missing); OpenDocument is the preferred Calc format.

**Verification:** full `RecorderLnx.lpi` rebuild completed with exit code 0 and
linked `RecorderLnx.exe`. The post-build `copy_sdb_res.bat` still prints the
pre-existing Windows shell error on `#!/bin/sh`, but did not fail lazbuild.

**Crash follow-up:** user reported a crash on import and provided a debugger
stack in `fpsopendocument.pas`. Fixed two issues: `TTagImportRow` is now
initialized with `Default(TTagImportRow)` instead of `FillChar`, and vendored
fpspreadsheet ODS reader uses `FreeAndNil(Doc)` after `content.xml` so the
`finally` block cannot double-free the XML document. Added
`errors/2026-08-17-tag-table-import-crash.md` and project rule
`RLNX_MANAGED_RECORD_NO_FILLCHAR_2026_08_17`. Rebuild passed with exit code 0;
manual retry of import is still required.

## 2026-08-17 - MIC-185 remains visible during active sessions

**Request:** fix auto-search showing only MIC-140 although configured MIC-185 devices are connected.

**Done:** root cause was the search dialog relying only on fresh broadcast replies after single-client MIC-185 working sessions were already open. It now merges broadcast results with configured MIC-185 devices confirmed through the active runtime registry, without a second TCP connection. Added a project rule for single-client discovery.

**Verification:** full `RecorderLnx.lpi` rebuild completed with exit code 0. Detailed evidence: `errors/2026-08-17-mic185-discovery-regression-check.md`. **Status:** code complete; UI hardware check remains.

## 2026-08-14 17:27 - MIC-140 UTS publishes current clock mapping

**Request:** user clarified that MIC-140 SEV/UTS channels do not need every
historical measurement replayed. The key requirement is the current mapping
between crate local clock and SEV/UTS clock, because shared UTS code is the
same while controller quartz clocks differ.

**Done:** set MIC-140 SEV FIFO readiness to one 6-word UTS record
(`fifoReady=6`) instead of six records (`fifoReady=36`), removing the
multi-second startup backlog. Changed `TMic140v2Tcp.LastUtsPacket` so it takes
the newest queued UTS packet and clears older queued packets; runtime therefore
publishes the current `(crate local time, UTS)` pair instead of replaying stale
SEV seconds after any delay.

**Verification:** `RecorderLnx.lpi` rebuilt with exit code 0. Hidden
`RecorderLnx.exe --preview-seconds=12` showed `SEV scan OK scan=0 fifoReady=6`,
first MIC-140 UTS immediately after start (`uts=23031`) matching MIC-185
`uts=23031`, then MIC-140 `23032`, `23033`, `23034` one second apart. Main
MIC-140 stream stopped cleanly:
`published=62 read=62 readGaps=0 dupRead=0 corruptRead=0 corruptPublish=0
mdpResync=0`. Detailed notes:
`errors/2026-08-14-mic140-uts-readout.md`.

## 2026-08-14 15:44 - MIC-140 UTS tag publishes every FIFO frame

**Request:** user clarified that MIC-140 UTS tag itself must increment once per
second; status interpolation alone is not enough. It was staying near 16000
and changing rarely.

**Done:** hardware SEV packets were confirmed as FIFO batches of six 6-word UTS
frames. `uRecorderMic140Protocol.pas` now enqueues every decoded SEV frame in a
UTS FIFO instead of caching only the newest/tail frame. `uRecorderMic140Device`
no longer drains this queue from the fast main block pump; `LastUts` dequeues
one sample on data-source request. `uRecorderMic140DataSource.pas` publishes
queued UTS samples through the cached tag at about 1 Hz.

**Verification:** `RecorderLnx.lpi` rebuilt with exit code 0. Hidden
`RecorderLnx.exe --preview-seconds=20` showed raw MIC-140 `.14.42` SEV FIFO
`16846..16851`, then tag publications `16846`, `16847`, `16848`, `16849` at
approximately one second cadence. Detailed notes:
`errors/2026-08-14-mic140-uts-readout.md`.

## 2026-08-14 15:34 - UTS status time advances between MIC-140 SEV packets

**Request:** user reported that MIC-140 time display holds the same value for
several seconds and may be wrong.

**Done:** confirmed from hardware logs that MIC-140 SEV arrives as FIFO batches
of six 1-second UTS frames (`6230..6235`, then `6236..6241`, etc.). The source
publishes the newest UTS value about every 6 s, so `TimeSystem.Snapshot` froze
because it displayed only the stored last UTS value. `uRecorderTimeSystem.pas`
now records the monotonic tick of the last UTS update and displays
`last UTS + elapsed ticks` while running.

**Verification:** `RecorderLnx.lpi` rebuilt with exit code 0. Hidden
`RecorderLnx.exe --preview-seconds=20` showed MIC-140 `.14.42` publishing
`uts=16235`, `16241`, `16247` and clean stream stop
`published=105 read=105 readGaps=0 dupRead=0 corruptRead=0 corruptPublish=0
mdpResync=0`. `RecorderTimeSystemTest.exe` passed; new check advanced
`UTS=7201` to `7202.109` after about 1.1 s and displayed `02:00:02`.

**Status:** status-bar UTS time should no longer freeze between MIC-140
packets. Open detail: MIC-140 UTS tag history still stores one tail value per
SEV FIFO packet, not every internal 1-second frame.

## 2026-08-14 15:25 - MIC-140 UTS no longer looks like garbage

**Request:** user said MIC-140 UTS still looked like garbage and should be
approximately equal to MIC-185 UTS.

**Done:** compared original `ScanSEV`/`GetTimeLocFromScanUTS` with live
RecorderLnx logs. MIC-140 UTS Y from BCD already matched the MIC-185
`.147/.148/.151/.152/.155` group (`15725` on MIC-185, then `15727` on
MIC-140 about two seconds later). The bad part was MIC-140 local X time:
RecorderLnx used `HCLK / 50 MHz`, while original code uses the CC timer
period/counter formula. Replaced this with `Mic140SevLocalTimeSec` based on
`CMic140LegacyTimerPeriod` and `CMic140LegacyFreqClkHz`.

**Verification:** `RecorderLnx.lpi` rebuilt with exit code 0. Hidden
`RecorderLnx.exe --preview-seconds=20` showed MIC-140 `.14.42` publishing
`uts=15727`, `15733`, `15739` with X `5.38`, `11.38`, `17.38`; stream stopped
cleanly with `published=105 read=105 readGaps=0 dupRead=0 corruptRead=0
corruptPublish=0 mdpResync=0`.

**Status:** fixed for the checked stand path. Note that MIC-185 has another
UTS group `.156/.158/.159` around `2032x`; MIC-140 `.14.42` matches the
`1572x` MIC-185 group, not that second group. Detailed facts:
`errors/2026-08-14-mic140-uts-readout.md`.

## 2026-08-14 15:17 - MIC-140 UTS publishes from SEV scan

**Request:** user reported that MIC-140 UTS still did not produce data.

**Done:** compared the lifecycle with original Recorder and fixed the SEV scan
order: MIC-140 now programs SEV before trigger/ADC start, not after it. Also
changed the protocol pump so accepted UTS packets do not satisfy the "read one
main scan block" budget; UTS is cached separately and then published through a
cached runtime tag.

**Verification:** `RecorderLnx.lpi` rebuilt with exit code 0 before the final
hardware run. Hidden `RecorderLnx.exe --preview-seconds=10` showed
`SEV scan OK scan=0`, `UTS packet accepted #1 ... scan=0`,
`MIC-140 UTS published #1 tag=MIC140_{42_uts}`, no `reject stream0`, and clean
stop: `published=54 read=54 readGaps=0 dupRead=0 corruptRead=0
corruptPublish=0 mdpResync=0`.

**Status:** UTS readout works on the checked MIC-140 `.14.42`; if UI value
format differs from original Recorder, next check is exact BCD/time-base
interpretation, not packet routing.

## 2026-08-14 15:03 - MIC-140 UTS no longer accepts garbage frames

**Request:** user reported MIC-140 UTS values are incorrect and look like
codes from another channel or random garbage.

**Done:** checked current log and code against original `ScanSEV`: main
MIC-140 stream was clean, but no `SEV scan OK` was present, while the passive
UTS parser could accept non-main stream-0 packets by length/BCD only. Tightened
UTS routing so packets are accepted only from the separate SEV scan id, added a
limited accepted-UTS diagnostic log, and re-enabled separate original-style
SEV programming/rearm without making SEV failure fatal for main AIn/TIn.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0 after the changes. Detailed facts are in
`errors/2026-08-14-mic140-uts-readout.md`.

**Status:** needs hardware Preview check. Expected log: `SEV scan OK scan=0`,
`scan programmed ... sev=True`, then `UTS packet accepted ... scan=0`. If SEV
is disabled by command failure, compare that stage with original Recorder
traffic.

## 2026-08-14 15:25 - Reset now verifies selected hardware sources

**Request:** user noticed reset now returns almost instantly, tree turns green,
but Preview immediately reports device failure; asked whether reset is actually
doing anything.

**Facts:** `LogWindows.log` showed a selected MIC-140 reset batch finishing in
`0 ms`, then Apply logging `Hardware configuration unchanged: initialized
devices retained`. Code confirmed reset only placed a pending reset/released a
session, while Preview intentionally does not consume pending reset by running
`PrepareHardware`.

**Done:** added `TRecorderDataSourceManager.PrepareHardwareSources(ASourceIds)`
and changed settings reset so successful reset release/cleanup no longer clears
offline state by itself. The dialog now prepares only successfully reset source
ids in parallel via normal data-source `PrepareHardware`; green status is only
restored after successful prepare, otherwise the error reason stays visible.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
exit code 0. Detailed hypothesis log:
`errors/2026-08-14-hardware-reset-must-prepare-selected-sources.md`.

## 2026-08-14 15:05 - MIC-185 mass initialize timeout, MIC-140 tags still saved

**Request:** user reported that MIC-185 devices started dropping and MIC-140
tags were not visible in the list, although the MIC-140 device looked green
after reset.

**Facts:** `LogWindows.log` showed MIC-185 TCP connect succeeding for all
sources, then all devices failing `initialize` after about `6.3 s`. This is not
a ping/routing failure; it is a Mebius command-reply failure during parallel
prepare. The same log showed configured MIC-140 source
`192.168.14.41:4000` failing TCP TEST, while broadcast replies were seen from
`.14.42`, `.14.30`, and `.14.40`. Project
`C:\Mera Files\RecorderLnx\config\projects\002\default.config.json` still has
`MIC-140: 192.168.14.41:4000` in `dataSources` and 57 MIC-140 tags, so the tags
were not lost from the saved config.

**Done:** added a MIC-185 command-stage throttle in
`Device/mic185/uRecorderMic185DataSource.pas`: data sources still prepare in
parallel, but only two MIC-185 sources at a time execute
`TryInitializeSession`/identity update/`TryProgramDevice`. TCP connect remains
parallel. Lifecycle log now has `prepare-command-slot` with active/limit data.

**Verification:** `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` exit code 0.
Post-build `copy_sdb_res.bat` still prints the known non-blocking `#!/bin/sh`
message. Detailed history:
`errors/2026-08-14-mic185-mass-initialize-timeout-and-mic140-tags.md`.

## 2026-08-13 15:25 — автопоиск: убраны ложные MIC-140 и поправлен legacy SN

**Запрос:** пользователь уточнил, что в списке настоящие MIC-140 только `192.168.14.40/.41/.42`, а правильные серийники соответственно `328/326/327`; остальные найденные строки не MIC-140.

**Сделано:** проверен оригинальный `mdpEthernet81/ethernet81bus.cpp`: `SerialNo_` в legacy `ETH81_DETECT_DEVICE_INFO` находится по смещению 20, прежнее чтение смещения 22 брало не серийник устройства. Исправлено чтение legacy SN. MIC-140 TCP fallback ограничен известными реальными стендовыми `.14.40/.41/.42` и уже сконфигурированными MIC-140, остальные ARP/TCP-хосты теперь логируются и не пробуются как MIC-140.

**Проверка:** `RecorderLnx.lpi` собран с exit code 0; post-build `copy_sdb_res.bat` по-прежнему печатает ошибку `#!/bin/sh`, но линковку не ломает.

**Статус:** готово к повторной проверке кнопкой автопоиска: `.13.*` не должны добавляться как MIC-140, а legacy broadcast SN для `.14.40/.41/.42` должен совпадать с `328/326/327`.

## 2026-08-13 14:20 — автопоиск rlnx: fallback при нулевом UDP broadcast

**Запрос:** пользователь сообщил, что свежий RecorderLnx опять ничего не нашел, хотя оригинальный Recorder видит MIC-140.

**Сделано:** по `C:\Mera Files\RecorderLnx\LogWindows.log` подтверждено, что UI запускает правильный свежий `RecorderLnx.exe`, отправляет broadcast на `255.255.255.255` и directed broadcast выбранной сети, но обычный процесс получает `discovery finished: 0 device(s)`. Отдельный `HardwareSearchDebug.exe` под elevated на том же bind `192.168.3.65` получает MIC-140 и MIC183/185, а обычный non-elevated прогон получает 0 broadcast-ответов при видимом ARP-списке. Поэтому причина текущего "ничего не нашел" не в парсере, а в доставке UDP broadcast-ответов обычному процессу на этом стенде.

**Изменено:** в `UI/uRecorderSettingsDialog.pas` добавлен быстрый MIC-only fallback: если broadcast вернул 0 устройств, автопоиск берет ARP-кандидатов выбранного интерфейса, проверяет открытый TCP/4000 коротким таймаутом и идентифицирует только MIC183/185 и MIC-140. Медленный MC-032 scan остается только по галочке `Ping` справа от кнопки автопоиска.

**Проверка:** первый rebuild уперся в запущенный `RecorderLnx.exe` PID 11400 и не смог перелинковать файл; процесс остановлен, повторная сборка `RecorderLnx.lpi` завершилась с exit code 0. Свежий `RecorderLnx.exe` запущен PID 5092. UI-клик автопоиска вручную еще нужно подтвердить в открытом окне; ожидаемые строки при проблемном broadcast: `broadcast returned no devices; trying ARP/TCP MIC fallback`, затем `ARP/TCP MIC fallback: ... open ...` и строки найденных MIC.

**Статус:** прибор не зависал, перезагрузка не требуется. Следующая проверка — нажать автопоиск в уже открытом RecorderLnx и сверить найденные MIC-140/MIC183/185 с логом.

## 2026-08-13 13:50 — автопоиск проверен с TCP/Ping fallback

**Запрос:** пользователь сообщил, что автопоиск снова не срабатывает, и попросил самостоятельно отладить режим с логами и тестовыми перезапусками.

**Сделано:** подтверждено, что обычный MIC-поиск должен оставаться broadcast-only для MIC-140/MIC183/185, а медленный TCP/MC-032 scan включается только галочкой `Ping`. TCP fallback после зависания переведен на последовательную проверку ARP-кандидатов.

**Проверка:** `RecorderLnx.lpi` собран с exit code 0. Стендовый `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=1200 --tcp-scan` вне sandbox завершился за 3.3 с: `broadcast_found=15`, MIC-140 SN 282/4574/4575/4576 и MIC183/185 SN 161/162/163/165/166/167/168/170/171/173/174; optional TCP scan нашел 21 host с открытым 4000 и не завис.

**Статус:** готово для проверки в UI кнопкой автопоиска; подробная история гипотез в `errors/2026-08-13-hardware-autosearch-broadcast-only.md`.

## 2026-08-13 — исправлен broadcast-автопоиск MIC-140/MIC183/185

**Запрос:** автопоиск RecorderLnx не находил поддерживаемые устройства, хотя оригинальный Recorder быстро видел MIC-140; нужно было самому отладить с логами и тестовыми процедурами.

**Сделано:** исправлено распознавание реальных broadcast-типов: MIC183/185 modern `dev_type=$020A0000`, MIC185V2 `$02190000`, MIC-140 modern `$02090000/$02220000`, legacy ethernet-interface MIC-140 `$413D/$413F/$4141/$4143`. Обычный MIC-поиск оставлен broadcast-only; ARP/TCP MIC fallback отключён, MC-032 scan остаётся только по галочке `Ping`. Добавлен `Tests\HardwareSearchDebug\HardwareSearchDebug.lpr` для независимого прогона broadcast с логом.

**Проверка:** `lazbuild -B RecorderLnx.lpi` exit code 0. `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5200` вне sandbox вернул `broadcast_found=15`: MIC183/185 SN 161,162,163,165,166,167,168,170,171,173,174 и MIC-140 SN 282,4574,4575,4576.

**Статус:** готово для проверки в UI; подробная история гипотез и фактов в `errors/2026-08-13-hardware-autosearch-broadcast-only.md`.

## 2026-08-13 — найдена внешняя причина остановки MIC-185

**Запрос:** проверить дамп после перехода сетевой карты со статического IP на DHCP и оценить гипотезу о недоставке keep-alive.

**Сделано:** успешный дамп содержит 11 мин 54 с непрерывного потока, 4760 полных пакетов по 4140 байт и штатный Stop. Прикладных keep-alive во время сбора нет. Освобождённый статический адрес `192.168.5.100` отвечает с другого MAC `30-DE-4B-A5-C9-F3`, что подтверждает конфликт IP и объясняет одновременный обрыв приборов после обновления ARP.

**Проверка:** ping `192.168.5.100` — 2–4 мс, TTL 64; `arp -a` показывает динамическую запись чужого узла. DHCP-адрес `192.168.3.65/20` обеспечил полный успешный прогон.

**Статус:** причина подтверждена; код протокола менять не требуется.

## 2026-08-13 — поиск клиента захвата по имени процесса

**Запрос:** не хранить изменчивый PID клиента регистратора трафика; находить программу по настраиваемому списку имён из INI рядом с утилитой.

**Сделано:** добавлен `Mic185TrafficCapture.ini` со списком `ProcessNames`. Захват ищет процессы по этим именам, при нескольких экземплярах выбирает владельца TCP-соединения с прибором и запоминает его PID только до завершения текущего захвата.

**Проверка:** PowerShell parser не обнаружил ошибок; жёсткий вызов `Get-Process RecorderLnx, Recorder` удалён; INI и описание включены в переносимый комплект.

**Статус:** готово.

## 2026-08-13 — автоматический жизненный цикл захвата MIC-185

**Запрос:** убрать вопросы о клиенте и ручное завершение; автоматически определять Recorder/RecorderLnx, стадии и финализировать захват при закрытии клиента.

**Сделано:** BAT запускается без диалога с IP стенда по умолчанию; PowerShell определяет PID владельца TCP-соединения с прибором, сохраняет имя клиента и сам вызывает Stop/Convert/Decode после завершения PID. Клавиши C/X и ручной выбор клиента удалены.

**Проверка:** PowerShell parser ошибок не обнаружил. Изолированный UAC-прогон из автоматизированной среды не стартовал, поэтому финальная проверка определения PID выполняется следующим обычным запуском BAT; прежний режим `DurationSec` сохранён для self-test.

**Статус:** код готов, требуется один пользовательский запуск RecorderLnx с закрытием процесса.

## 2026-08-13 — проверен захват полного сценария MIC-185

**Запрос:** проверить запись сценария: одиночный reset, reset всех устройств, Preview, Stop и закрытие RecorderLnx.

**Сделано:** незавершённый PktMon штатно остановлен, из сохранённого ETL восстановлены PCAPNG, CSV, timeline и lifecycle. Обнаружены три цикла session/config, затем Start, непрерывный поток и Stop с последующим disconnect.

**Проверка:** 1803 TCP-пакета, 5 соединений, 318 блоков по 4140 байт и 96 служебных блоков по 84 байта. Поток длился 47,7 с с периодом около 150 мс; в направлении DEV→PC нет TCP gaps или retransmits.

**Статус:** захват пригоден для анализа. Исходный сценарий записан полностью, но окно регистратора не выполнило финальную конвертацию автоматически; артефакты восстановлены без повторного прогона.

## 2026-08-13 — отдельный каталог каждого захвата MIC-185

**Запрос:** не смешивать результаты разных запусков регистратора трафика в общей папке.

**Сделано:** каждый запуск создаёт каталог `captures\IP_client_run_timestamp`; ETL, PCAPNG, CSV, отчёты, маршрут, метки и лог пишутся внутрь него. Метка времени включает миллисекунды.

**Проверка:** PowerShell syntax OK; пассивный PktMon-прогон завершился с exit code 0 и создал отдельный каталог с девятью ожидаемыми артефактами. Активный probe отдельно подтвердил создание изолированного каталога, но прибор не ответил за 2 секунды.

**Статус:** готово.

## 2026-08-10 — повторное зависание сбора MIC-185

**Запрос:** устранить повторное молчаливое зависание сбора данных.

**Сделано:** неблокирующий приём больше не маскирует исключение чтения TCP как
обычное отсутствие данных. Клиент сохраняет причину обрыва; источник проверяет
её после чтения и помечает только соответствующий MIC-185 как offline.

**Проверка:** полная сборка `RecorderLnx.lpi` завершилась с exit code 0.
Долговременный аппаратный прогон более пяти минут ещё требуется.

## 2026-08-10 — останов потока MIC-185 за пять минут

**Запрос:** по журналу найти, почему за пять минут прекращается сбор данных.

**Сделано:** исправлен первоначальный вывод: рабочая сессия использует 200 мс,
поэтому при 100 Гц ожидается около 20, а не 50 пакетов за цикл. Предел 32 сам
по себе не объясняет останов. Вызвавшая отвал приборов строгая фильтрация
ответов по IOCTL-коду отменена; восстановлена прежняя обработка ответа.

**Проверено:** полная сборка `RecorderLnx.lpi` прошла, exit code 0. CLI-запуск
не загрузил стендовую конфигурацию, поэтому аппаратный результат не засчитан.

**Осталось:** после сборки восстановить связь с приборами, затем запустить
Preview из Lazarus более чем на пять минут и убедиться,
что измерения, температуры и UTS продолжают обновляться, а сообщения
`Receive drain limit reached` в журнале отсутствуют.

## 2026-08-10 — сбор MIC-185 снова прекратился

**Запрос:** найти причину повторной остановки сбора и не блокировать поток ожиданием
неполного TCP-пакета.

**Сделано:** по журналу подтверждено, что прекращается сам приём пакетов, а не только
публикация тегов. Измерительный приём переведён на нулевое ожидание готовности сокета:
доступные байты читаются сразу, неполный пакет сохраняется и продолжается на следующем
такте. Ожидание оставлено только для команд управления и конфигурирования.

**Проверено:** полная сборка `RecorderLnx.lpi` прошла, exit code 0.

**Осталось:** стендовый Preview дольше пяти минут с контролем измерений, UTS и температур.

## 2026-08-10 — ложный зелёный статус MIC-185

**Запрос:** после запуска MIC-185 отображались зелёными, хотя последующий сброс
обнаруживал ошибку связи.

**Сделано:** до завершения `Connect → Initialize → Configure` источник теперь имеет
неподтверждённый статус с пояснением. Offline очищается и зелёная иконка разрешается
только после успешного завершения всех трёх стадий. Ошибка любой стадии сохраняет
иконку неисправности и причину в hint.

**Проверено:** полная сборка `RecorderLnx.lpi` прошла, exit code 0.

## 2026-08-10 — восстановлен полный сброс MIC-185

**Запрос:** ручной сброс MIC-185 из аппаратного диалога не восстанавливал связь.

**Сделано:** подтверждён и исправлен цикл `Stop -> Disconnect -> ожидание -> Connect -> Initialize -> Configure`. Ожидание освобождения одноклиентской Mebius-сессии увеличено с 250 до 1500 мс; транспорт теперь инвалидирует сессию при закрытии/ошибке чтения и при неуспешной записи.

**Проверка:** `lazbuild -B RecorderLnx.lpi`, exit code 0; EXE слинкован.

**Статус:** код готов, требуется стендовый прогон длительного Preview и ручного сброса.

## 2026-08-07 — цифровая таблица обновляется после фоновой подготовки

**Запрос:** после холодного запуска MIC-185 присутствуют справа в списке тегов,
но отсутствуют во встроенной цифровой таблице до открытия настроек.

**Сделано:** после завершения отложенной аппаратной подготовки и пересчёта
активных источников вызывается единое `RenderActivePage`. Цифровая страница
повторно строит строки по актуальной видимости источников даже в режиме Stop.

**Проверка:** запущенный RecorderLnx остановлен; полная пересборка
`RecorderLnx.lpi` прошла с exit code 0, новый exe успешно слинкован.

**Статус:** исправлено; требуется проверка холодного запуска без входа в настройки.

## 2026-08-07 — логирование инициализации MIC-185

**Запрос:** получить диагностический лог холодного старта, TCP-пингов и пакетного/одиночного reset MIC-185 с `Mebius IoControl timeout`.

**Сделано:** добавлен структурированный `[MIC185-LC]` для connect, initialize/GetSoftVersion+SN, configure, disconnect, TCP-пинга и reset. У пакетного сброса общий trace, у параллельных задач дочерние trace; записываются endpoint, bind-адрес, поток, попытка, длительность и ошибка.

**Проверка:** исходники полностью скомпилированы; линковка рабочего EXE заблокирована запущенным RecorderLnx PID 14560. После закрытия приложения нужна повторная сборка и стендовый прогон. Подробности: `errors/2026-08-07-mic185-double-session-cold-init.md`.

**Статус:** готово — лог подтвердил коллизию одновременного первого обмена.
Параллельные worker-потоки сохранены, но старт endpoint разнесён по 150-мс
слотам; сборка `RecorderLnx.lpi` завершена успешно. Требуется стендовый прогон.

# 2026-08-06 — ускорение автопоиска и пакетного добавления приборов

**Запрос:** сократить длительность автопоиска и добавления нескольких найденных приборов; убрать ложные предупреждающие иконки MIC-185.

**Сделано:** broadcast сохраняет надёжный предел 5,2 с для медленных MIC-185, но завершается через 1 с без новых ответов после появления первого устройства. Добавление выполняется пакетом: конфигурации и каталоги каналов создаются без промежуточного перестроения UI, затем дерево и таблицы обновляются один раз. Перестроение дерева больше не выполняет синхронные сетевые TestLink; предупреждение показывается только после фактически зарегистрированной runtime-ошибки. В `LogWindows.log` добавлены тайминги broadcast, TCP-сканирования, идентификации и пакетного добавления.

**Проверка:** `lazbuild -B RecorderLnx.lpi`, exit code 0.

**Статус:** готово; фактические сетевые времена проверяются на стенде по строкам `[HardwareSearch]`.

# 2026-08-06 — отсоединённые теги и список выбранных каналов

**Запрос:** после удаления неиспользуемых источников вернуть красную иконку битого тега; показать число добавленных каналов; после добавления убирать канал из левого списка.

**Сделано:** `Detached:` теперь считается неактивной аппаратной связью и получает иконку перечёркнутого круга. В заголовке списка выбранных каналов показывается общее число тегов. Сопоставление каналов MIC-140 учитывает эквивалентные адреса `2-1` и `2-01`, поэтому созданный тег сразу исключает соответствующий сигнал из списка доступных.

**Проверка:** полная пересборка `RecorderLnx.lpi` через `lazbuild -B`.

# 2026-08-06 — автопоиск добавляет устройства без каскада диалогов

**Запрос:** не показывать отдельный настроечный диалог для каждого выбранного
устройства после общего окна результатов автопоиска.

**Сделано:** подтверждение общего списка теперь создаёт конфигурационные записи
MIC-140, MIC183/185 и MC-032 с настройками по умолчанию и обновляет дерево.
Редактор открывается только вручную для конкретного устройства.

**Проверка:** полная сборка `RecorderLnx.lpi`.

**Статус:** готово.

# 2026-08-06 — подтверждён broadcast-поиск одного MIC185

**Запрос:** после выдачи разрешения сетевому интерфейсу повторно проверить
автопоиск сначала на одном MIC185.

**Сделано:** через `Ethernet 2 / 192.168.5.100` прибор `192.168.9.147` найден
штатным MebiusDAQ broadcast как `MIC183/185, SN=161`. Установлено, что за 1400 мс
ответ не приходит; ожидание автопоиска увеличено до 5200 мс по аналогии с
оригинальным Recorder (5000 мс).

**Проверка:** одиночные сетевые пробы 6000/1400 мс; полная сборка RecorderLnx.

**Статус:** готово.

# 2026-08-06 — редактирование одиночной и мульти-ГХ канала

**Запрос:** кнопкой редактирования сразу открывать единственную назначенную ГХ, а для мульти-ГХ показывать диалог выбора и свойств.

**Сделано:** при одном имени в `CalibrationNames` открывается редактор этой ГХ; при двух и более — существующий LFM-диалог `Настройка Мульти ГХ`. В нём «Свойства» и двойной щелчок открывают выбранную ГХ. Изменения списка применяются только по `OK`; добавлена защита от отсутствующей ГХ.

**Проверка:** полная штатная сборка `RecorderLnx.lpi` — exit code 0, `RecorderLnx.exe` обновлён.

**Статус:** готово.

# 2026-08-06 — входные единицы для токового питания тензомоста

**Запрос:** при выборе питания током показывать соответствующие входные единицы.

**Сделано:** список входных единиц динамически перестраивается. Для напряжения доступны
`dU/U`, `мВ/В`, `В`, `мВ`; для тока — `мВ`, `мВ/мА`, `Ом`. Для `мВ/мА` и `Ом` расчёт
использует передаточное сопротивление моста. Выбор сохраняется в конфигурации ГХ.

**Проверка:** полная сборка `RecorderLnx_verify.exe` — exit code 0. Штатный EXE заблокирован запущенным RecorderLnx PID 6884.

**Статус:** код готов; для обновления штатного EXE закрыть RecorderLnx и повторить сборку.

# 2026-08-06 — питание тензомоста током в мА

**Запрос:** доделать в тензокалькуляторе режим питания током с вводом в мА.

**Сделано:** в LFM-форму добавлен выбор `Напряжение/Ток`; в токовом режиме поле
вводится в мА. Напряжение моста вычисляется как `I·Rэкв`, где `Rэкв` пересчитывается по
четырём плечам для каждой точки. Старые ГХ без `excitationKind` остаются в режиме напряжения.

**Проверка:** полная проверочная и штатная сборки `RecorderLnx.exe` — exit code 0.

**Статус:** готово.

# 2026-08-06 — модуль Юнга тензокалькулятора в МПа

**Запрос:** вводить модуль Юнга в тензометрическом калькуляторе в МПа вместо Па.

**Сделано:** поле формы переименовано в «Модуль Юнга, МПа», значение по
умолчанию изменено с `2E11 Па` на `200000 МПа`. Новые конфигурации сохраняют
`youngMPa`; старые `youngPa` автоматически конвертируются делением на `1E6`.
Расчёт выходов в Па и МПа сохраняет прежний физический результат.

**Проверка:** полная сборка с временным именем `RecorderLnx_verify.exe` — exit
code 0. Штатный EXE не заменялся, поскольку запущенный Recorder удерживал файл.

**Статус:** готово.

# 2026-08-06 — Qdrant-индекс оригинального Recorder

**Запрос:** проиндексировать неизменяемые исходники оригинального Recorder из
`windev-v3.9` и сделать семантический поиск первым этапом исследований оригинала.

**Сделано:** MemoryDB получил отдельную коллекцию `source_code`, read-only
индексатор legacy-исходников и MCP-команды синхронизации/поиска. В навыки
RecorderLnx/RLM добавлен Qdrant-first процесс с обязательной сверкой первичного
файла. В индекс записано 1904 файла и 6748 чанков, ошибок нет.

**Проверка:** unit-тесты индексатора — 3/3 OK; контрольный смысловой запрос
вернул исходники `rc_guisrv`/`rc_core` с диапазонами строк.

**Статус:** готово; MCP-инструменты появятся в новых сеансах после перезапуска
Codex Desktop.

# 2026-07-31 — имена SQL-сигналов в легенде

**Запрос:** вместо названий цветов `Синий`, `Красный` показывать фактические
имена линий SQL-тренда.

**Сделано:** легенда и подсказка курсора используют `TagName` — имя сигнала,
прочитанное из БД. Поле `Name` используется только как запасное, если имя
сигнала отсутствует.

**Проверка:** полная сборка под временным именем — exit code 0.

**Статус:** готово.

# 2026-07-31 — отдельная легенда и выключаемый курсор SQL-тренда

**Запрос:** исключить наложение графика на легенду, вынести легенду в отдельную
панель со сплиттером и добавить показ/скрытие курсора кнопкой.

**Сделано:** справа создана отдельная панель с `TStringGrid`, номером, цветным
квадратом и именем линии; панель отделена изменяемым `TSplitter`. Точки вне
текущего X-диапазона не рисуются. В нижней панели добавлена фиксируемая кнопка
`Показать курсор` / `Скрыть курсор`; выключенный курсор не рисуется.

**Проверка:** полная сборка под временным именем — exit code 0.

**Статус:** код готов; штатный EXE обновится после закрытия запущенного Recorder.

# 2026-07-31 — прозрачный текст легенды SQL-тренда

**Запрос:** не заливать имя линии её цветом; оставить только аккуратный цветной
квадрат рядом с номером линии.

**Сделано:** после цветного образца кисть переключается в прозрачный режим.
Легенда и подсказка курсора показывают компактный квадрат, номер, название и
обычный чёрный текст без цветного фона.

**Проверка:** полная сборка под временным именем — exit code 0. Штатный EXE
удерживается запущенным RecorderLnx и не был заменён.

**Статус:** код готов; после закрытия Recorder требуется обычная сборка штатного EXE.

# 2026-07-31 — календарный интервал, легенда и курсор SQL-тренда

**Запрос:** заменить строковый ввод границ SQL-тренда удобным выбором даты и
времени; справа вывести легенду, а на графике — курсор со значениями линий.

**Сделано:** границы `От/До` переведены на стандартные `TDateTimePicker`: отдельный
календарь даты и 24-часовое поле времени. Сохранён связанный пересчёт
`От — До — Окно`. Область построения резервирует правую колонку под легенду
видимых линий. Наведение мыши рисует вертикальный курсор, UTC-время и ближайшее
значение каждой видимой линии.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi` — exit code 0.

**Статус:** готово.

# 2026-07-31 — независимое включение SQL-записи

**Запрос:** отвязать SQL-запись от режима записи Recorder, вынести её включение на главную форму и разрешить управлять ею тегом с порогом 0,5.

**Сделано:** рядом с `SQL DB` добавлена LFM-галочка «Запись». SQL-менеджер теперь сам открывает/закрывает регистрацию и не реагирует на переходы Stop/View/Record. В диалог SQLdb добавлен выбор управляющего тега: `> 0,5` включает, `< 0,5` выключает, ровно `0,5` сохраняет состояние; главная галочка синхронизируется с фактическим состоянием. Ручное состояние сохраняется в `sql-db.ini`.

**Проверка:** полная пересборка во временный `RecorderLnx_sqlswitch_verify.exe` — exit code 0. Штатный EXE не перелинкован, потому что PID 10880 удерживает его запущенным.

**Статус:** готово; после остановки текущей отладки выполнить обычную сборку для замены штатного EXE.

# 2026-07-31 — поиск SQL-каналов и астрономическое время точек

**Запрос:** добавить поиск каналов SQLdb и обеспечить будущему SQL-тренду календарную временную ось по модели «время старта Recorder + timestamp канала», сверив её с оригинальным Recorder.

**Сделано:** в LFM-диалог добавлен UTF-8 поиск с сохранением отметок при фильтрации. SQLdb больше не подставляет `Now` вместо времени измерения: значения и тревоги переводятся в UTC через единый якорь `TRecorderTimeSystem`; программные источники сбрасывают относительное время при старте, служебные MIC-140 теги используют время аппаратного потока. Добавлен `Docs/time-system.md` со сравнением оригинала и правилами аппаратных/виртуальных каналов.

**Проверка:** полная пересборка с временным именем EXE — exit code 0 (штатный EXE удерживается запущенным RecorderLnx); `RecorderTimeSystemTest` — passed; два цикла Preview — exit code 0.

**Статус:** готово; для записи штатного EXE нужно закрыть запущенный RecorderLnx/отладку и выполнить обычную сборку.

# 2026-07-31 — устранена гонка состояний тревог

**Запрос:** разобраться с однократным исключением в `TRecorderAlarmEngine.AcquireState`, которое исчезло после перезапуска.

**Сделано:** подтверждена гонка между публикацией значений из рабочих потоков и общим списком `fStates`; в движок тревог добавлена критическая секция, защищающая поиск, создание, использование и очистку состояний на всём времени жизни ссылки.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi` — exit code 0; три автоматических цикла `--preview-seconds=4 --preview-cycles=3` — exit code 0, 22 секунды, без исключения и зависания.

**Статус:** готово.

# 2026-07-31 — оценки каналов SQLdb

**Запрос:** назначать одну оценку сразу нескольким выбранным SQL-каналам, видеть назначение в
таблице; скалярные теги всегда записывать как Mean.

**Сделано:** список каналов заменён на LFM-таблицу с checkbox, множественным выделением и колонкой
«Оценка (пишем в SQL)». Добавлены список всех штатных оценок и кнопка «Назначить». Назначения
сохраняются по тегам в `SQLdbSignalEstimates`. Блочные каналы передают SQL лёгкое уведомление
конца блока и записывают выбранную кэшированную оценку; скалярные обновления всегда пишут Mean.

**Проверка:** полная сборка во временный `RecorderLnx_verify.exe` — exit code 0; штатный EXE
удерживается запущенным RecorderLnx. Временная настройка Target из LPI удалена; `git diff --check` чисто.

**Статус:** код готов; для обновления штатного EXE нужно закрыть запущенный RecorderLnx и пересобрать.

# 2026-07-31 — автоматическое время PublishValue

**Запрос:** при Push/Publish без timestamp либо с timestamp `<= 0` автоматически использовать
текущее относительное время Recorder.

**Сделано:** `TRecorderTagRegistry` связан с общей `TRecorderTimeSystem`. Добавлен короткий вызов
`PublishValue(TagName, Value)`; обе формы вызова разрешают неположительное время через
`TimeSystem.Snapshot.ElapsedSec`. Положительное аппаратное/расчётное время не изменяется.
Для автономного реестра предусмотрено монотонное время от момента его создания. Button переведён
на короткий Publish без собственного расчёта времени; правило описано в `Docs/time-system.md`.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi` — exit code 0; `git diff --check` — чисто.

**Статус:** готово.

# 2026-07-31 — быстрый запуск и рабочее создание Firebird БД

**Запрос:** измерить длительный чёрный экран при запуске, проверить сетевые таймауты и исправить ошибку кнопки создания SQL БД.

**Сделано:** обнаружены и устранены 49 последовательных секундных probe MIC-140 при загрузке тегов; сетевой доступ перенесён в единственную отложенную аппаратную подготовку. Проект переведён в Win32 GUI без консоли. Для Firebird добавлена граница транзакции после DDL и допустимый размер уникального ключа `storage_key`.

**Проверка:** форма появилась за 4945 мс вместо ~54 с; репозиторий создал/открыл `recorderlnx.fdb` и вернул `SCHEMA_VERSION=1`, `SCHEMA_INFO_ROWS=1`; полная сборка `lazbuild -B RecorderLnx.lpi` — exit code 0.

**Статус:** готово.

# 2026-07-31 — недоступное устройство без исключений

**Запрос:** недоступный сетевой прибор должен штатно перейти в offline после `TestLink`; исключения транспорта нельзя показывать пользователю, ошибку нужно записать в журнал.

**Сделано:** добавлена общая безопасная оболочка `TestLink`; исключения подготовки любого источника переводятся в offline и собираются менеджером. MIC-140 перед чтением серийного номера/калибровки при загрузке проекта выполняет невыбрасывающий TCP TEST. Offline-источники не получают поток сбора, ошибки подготовки выводятся в журнал главной формы.

**Проверка:** полная пересборка выполнена с временным именем выходного EXE (штатный EXE удерживала отладочная сессия Lazarus), `lazbuild -B RecorderLnx.lpi` завершился с exit code 0.

**Статус:** готово; остаётся ручная проверка отображения offline-иконки и строки журнала при выключенном MIC-140.

# 2026-07-29 — размер иконок отдельного формуляра

**Запрос:** масштабировать иконки тулбара отдельного окна так же, как в главном редакторе.

**Сделано:** исправлен параметр `ImageWidth` у кнопок отдельного окна: вместо нулевого значения, выводившего крупный исходник из `ImageList`, используется то же значение `25`, что и в главном тулбаре.

**Проверка:** полная пересборка `RecorderLnx.lpi` завершилась с exit code 0.

**Статус:** готово.

# 2026-07-29 — единый тулбар и скрытие вкладки откреплённого формуляра

**Запрос:** показывать в отдельном окне тот же тулбар с теми же иконками, что и в главном редакторе, и убирать откреплённый формуляр из списка вкладок главного окна.

**Сделано:** отдельному окну передаётся принадлежащий главной форме `ilCommandButtons`; порядок, размеры, индексы и доступность кнопок повторяют главный тулбар. `TPageControl` строится только по прикреплённым страницам, а переход по вкладке использует сохранённый в ней индекс модели, поэтому фильтрация не нарушает выбор страницы.

**Проверка:** полная пересборка `RecorderLnx.lpi` завершилась с exit code 0.

**Статус:** готово.

# 2026-07-29 — отдельные окна пользовательских формуляров

**Запрос:** разрешить откреплять пользовательские формуляры от главного окна, переносить и разворачивать их на другом мониторе, редактировать собственной панелью инструментов и восстанавливать положение после перезапуска.

**Сделано:** добавлено отдельное окно формуляра с собственным контроллером редактирования и тулбаром. В диалоге «Формуляры» добавлено переключение «Открепить окно»/«Вернуть во вкладку». Состояние окна, обычные границы, монитор и развёрнутое состояние сохраняются в GUI-конфигурации. Закрытие отдельного окна возвращает страницу во вкладку; при отсутствии сохранённого монитора окно переносится на доступный экран.

**Проверка:** полная сборка `RecorderLnx.lpi` прошла; `RecorderFormModelTest` собран и выполнен, включая сохранение и загрузку параметров отдельного окна.

**Статус:** готово.

# 2026-07-29 — системный журнал итераций проекта

**Запрос:** найти или создать скилл, который на каждой итерации кратко переформулирует задачу и записывает выполненную работу рядом с проектом.

**Сделано:** найден близкий `project-change-log`, но он фиксирует только завершённые значимые изменения. Создан отдельный Codex-скилл `project-iteration-log`; его зеркало добавлено в системные навыки AGrav. Скилл выбирает существующий проектный журнал либо создаёт `cach/notes_last_state.md`/`iteration-log.md` и пишет запрос, результат, проверку и статус.

**Проверка:** структура скилла успешно прошла `quick_validate.py`.

**Статус:** готово.

# 2026-07-29 — включение и отключение источников из дерева

**Prompt:** добавить по правой кнопке включение/отключение источника, явно
показывать отключённое состояние и не собирать с него данные.

**Done:** в `TRecorderConfiguredDataSource` добавлен сохраняемый `Enabled`
(`dataSources[].enabled`, default `true`). Контекстное меню дерева переключает
флаг, отключённый узел показывается с неактивной иконкой и префиксом `[ВЫКЛ]`.
Сетевой probe для него не выполняется, активным он не регистрируется, а
`RecorderBuildRuntimeSources` исключает его теги до создания runtime-источника.
Сборка `RecorderLnx.lpi` прошла успешно.

# 2026-07-29 — MIC-140 не программируется после неизменённого `OK`

**Prompt:** вход в настройки тега MIC-140 и подтверждение без изменений
запускали долгую процедуру программирования.

**Done:** найдены два безусловных пути: очистка `DataSources` в
`TMainForm.OpenSelectedTagSettings` и `fDataSourcesChanged := True` после
редактирования канала в общем окне настроек. Добавлен общий снимок
программируемой конфигурации узла для MIC-140, MIC183/185 и MC-032/MC-201.
Оба UI-пути сравнивают состояние до/после; при равенстве сохраняются текущая
сессия и источник. Полная сборка `RecorderLnx.lpi` прошла успешно.

# 2026-07-27 — один блок осциллограммы и CPU цифрового формуляра

# 2026-07-28 — устранена регрессия CPU MIC-140/CJC

**Prompt:** после протокольных правок Preview снова загружал два ядра; проверить
повторный расчёт компенсации и перекомпиляцию осциллограмм.

**Done:** найден 40-итерационный подбор обратной термопарной ГХ для каждого
основного канала и малого блока. Добавлена прямая `InverseTransform`, МО каждого
TIn кэшируется один раз на блок. Revision/GLListID-защита осциллограмм сохранена.
Сборка OK; аппаратный прогон: 214 блоков/12 с без gaps, CPU 1,094 с за 5 с.

**Prompt:** осциллограмма показывает только один блок; через 60 секунд Preview
два ядра загружены даже на цифровом формуляре.

**Done:** кольцо тега теперь делит фактическую порцию на заранее выделенные
слоты и не переключается на несовместимый поточечный буфер. В Preview полные
блоки больше не копируются через EventBus/UI; они включаются только для Record.
Оценки тега вычисляются одним проходом при поступлении блока и кэшируются,
цифровой формуляр не копирует и не пересчитывает блок для каждой строки.
MIC-140/MIC-185 передают готовые блоки в уведомления напрямую. Сборка
RecorderLnx OK; живой повторный замер на конфигурации `D:\usml\0063` ожидается.

# 2026-07-24 — ложные .prt / гонка записи

**Prompt:** 20 с → 2040 точек (потерь нет), но .prt искажают отображение; возможно неверное время блоков.

**Done:** Запись из снимка события (полный блок), не LastBlockSnapshot. Детект .prt как в оригинале (половина длительности блока). Сборка OK.

# 2026-07-24 — MIC-140: drain без обрезки, любой UpdateTimeMs

**Prompt:** Запись снова некорректна; период опроса может быть любым (в т.ч. 0.1 с), ограничений не делать.

**Done:** Убраны target/trim. DoTick = ReadBlock(UpdateTimeMs) + drain ReadBlock(0). Ожидаемо freq*dt точек без жёсткого 200 мс. Сборка OK (exe был залочен — пересобран после taskkill).

# 2026-07-24 — MIC-140: 20 samples @100 Hz / 200 ms



**Prompt:** Не трогать сбор MIC-185; отладка MIC-140 — при 100 Гц и периоде опроса 200 мс должно приходить по 20 точек.



**Done:** DoTick набирает Round(freq*UpdateTimeMs/1000) через несколько ReadBlock; long 1500 ms timeout только на первый read тика; trim до target. Сборка RecorderLnx OK. MIC-185 не менялся.



# 2026-07-24 — MIC-140 clean rebuild (DataThread + Codex)



**Prompt:** Backup старого MIC-140, одна папка, универсальный DataThread, lifecycle Connect→Init→Config→Play→Stop→Disconnect по Codex; UI/ГХ сохранить.



**Done:** `Device/backup/MIC140_legacy/`; production `Device/MIC140/` с Protocol/Scan/Stream/Device/DataThread/Factory; DataSource тонкий; Codex retarget; сборки RecorderLnx + Codex OK.





- Добавлен `SharedUtils/uSharedAsync.pas`: запуск метода в отдельном потоке и ожидание группы задач с агрегацией ошибок.

- `TRecorderDataSourceManager.PrepareHardwareAll` готовит независимые источники параллельно; методы `PrepareHardware` не должны обращаться к UI.

- Команды BIOS MC-201 оставлены последовательными в одной MDP-сессии, но четыре отдельные выдержки по 350 мс объединены в одну после группы.

- Холодный тест `--preview-seconds=4`: запуск 13,19 → 10,81 с, MC-201 выдаёт стабильные блоки 11520 отсчётов/200 мс.



# MIC-140 debug stand — последнее состояние (2026-07-06)





## 2026-07-17: MC-201 multi balance — документация



**Prompt:** Записать в Docs/devices/mc, как добились правильного программирования ЦАП при мультибалансировке.



**Done:** Канон — `Docs/devices/mc/mc201-zero-balance-multi.md` (prepare→collect→stop-before-compute→SEND→StartRawScan; Quiet OK без ACK; запреты RESET/ForceDisconnect/SEND-in-stream). Ссылки в README, mc201.md, recorderlnx-integration.md, CHANGELOG.





## 2026-07-17: комментарии uMc032Device



**Prompt:** Подписать методы unit uMc032Device по логике (параметры, когда вызывается), без формальных комментариев; не ломать кодировку.



**Done:** В interface добавлены содержательные комментарии к API/helpers. Encoding verify OK, lazbuild RecorderLnx.lpi OK.





## Codex continuation 2026-07-13: MIC185 additional average count



**Prompt:** MIC185 additional settings dialog shows an empty averaging count;

at 100 Hz it should be 128 points. Check average calculation and dialog logic

against original Recorder.



**Findings:** Original MIC185V2 stores `AveragePointCount` as an exponent:

`7` means `2^7 = 128` ADC samples. RecorderLnx put protocol value `7` directly

into a `csDropDownList` with point-count items, so the field became blank. The

additional dialog also did not persist/program module-wide fields.



**Fix:** Added module-wide MIC185 settings, conversion helpers, and the original

`CalcMaxRate` formula. The dialog now displays point count `128`, stores/programs

the exponent `7`, saves module settings in `dataSources[].mic185`, and applies

them through `ProgramDeviceBin`.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0; existing post-build `copy_sdb_res.bat` still prints `#! is not recognized`.

`D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`

passed.



## Codex continuation 2026-07-13: preview offline sources and form editor lag



**Prompt:** User reported slow first transition into preview, repeated attempts

to connect disconnected devices, lag while dragging a display-form container,

and Ctrl+Z restoring deleted elements with empty settings.



**Findings:** Preview startup prepares hardware sources sequentially before

threads are started. Active-source refresh and hardware tree checks could also

perform synchronous TCP probes. MIC-185 connect waited up to 3 x 5000 ms. The

form editor rebuilt live controls and fired `NotifyChanged` on every mouse

move. Undo/copy stored only a partial set of component properties.



**Fix:** Added a shared offline-source registry in

`uRecorderHardwareLiveDevices`. Failed MIC-140/MIC-185 prepare/start marks the

source offline; `UpdateActiveSourceIds`, hardware-tree link checks, and runtime

data-source creation skip offline sourceIds until a manual reset. Added

hardware-tree context menu commands to reset one device or all devices. Reduced

hardware-tree probe timeout to 250 ms and MIC-185 connect to 1 x 1200 ms. The

form editor now throttles live rendering during drag/resize and sends

`NotifyChanged` once at operation end. Undo/copy snapshots now clone component

settings for StaticText, TagValue, Oscillogram, Trend, and Spectrum.



**Docs:** Added `Docs/devices/hardware_source_lifecycle.md` and error journal

`errors/2026-07-13-preview-offline-and-form-editor-lag.md`.



**Verification:** Initial rebuild reached linking but failed because running

`RecorderLnx.exe` PID 2004 locked the output file. After stopping that process,

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`

completed with exit code 0. `RecorderDataSourcesTest.exe` passed.



## Codex continuation 2026-07-08: tag settings additional-tab layout



**Prompt:** в настройках тега в диалоге наползание элементов окна друг на друга.



**Fix:** In `UI/uTagSettingsDialog.lfm`, increased and shifted the compact

`Дополнительно` tab groups for `Длина порции` and `Усреднение`, moved their

edit/check controls lower inside the group boxes, and moved `Свойства канала`

down to keep spacing between groups.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0. Existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh` message,

but it does not fail the build.



## Codex continuation 2026-07-06: MIC140 debug connection fix



**Prompt:** debug MIC-140 connection crash in Mic140ProtocolDebug_Codex stand.



**Fix:**

- Resolved Winsock race condition in `uMic140Registration.pas`: WSAStartup/WSACleanup moved to global initialization/finalization.

- Optimized discovery: `FindMIC140_48` now checks `CDefaultHost` (192.168.14.155) first, bypassing the heavy parallel 255-thread subnet probe when the default stand is available.

- Rebuilt and verified GUI/CLI: connection works stably, CLI runner reads data blocks.



## Codex continuation 2026-07-06: MIC140 10 Hz stream acceptance work



**Prompt:** finish the MIC-140 test so the live data stream at 10 Hz passes the

documented acceptance rules: no stream failures, data matches Recorder, and the

block count matches update time/duration.



**Done so far:**

- Added/rebuilt the headless CLI project

  `Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebugCli_Codex.lpi`.

- Fixed acquisition timing: the duration timer now starts after successful

  connect/program/start preparation, so a 3 s 10 Hz run reads about 15 blocks

  instead of undercounting connection/programming time.

- Split scan descriptor layouts:

  default acceptance `fifo=48` reserves descriptor 0 for ground

  (`reserveGroundDesc=True`, first AIn pointer `descAddr+5`);

  `--recorder-wire` keeps the dense Recorder MDP layout (first AIn at

  `descAddr`, `stride=51`, `msgWords=163`).

- Documented this distinction in

  `Docs/devices/mic140/protocol/03_scan_programming.md`,

  `05_data_stream.md`, and `07_acceptance.md`.



**Verification:** `C:\lazarus\lazbuild.exe -B

Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebugCli_Codex.lpi` completed with

exit code 0. Before the TCP port went offline, the stable `fifo=48` stream read

65 blocks in 13.13 s with `readGaps=0`, `corruptRead=0`, `softRestart=0`

(5 blocks/s as expected) but strict publication still failed on code-reference

checks. A later `--recorder-wire` diagnostic showed restarts/timeouts and then

the device stopped accepting TCP on `192.168.14.155:4000`; direct

`Test-NetConnection` also failed. Live PASS is therefore still open until the

MIC-140 port is reachable again.



## Codex continuation 2026-07-02: MIC140 IRecorderDevice stub



**Prompt:** in `Tests\Mic140ProtocolDebug_Codex\device\MIC140`, create a MIC-140

module with `IRecorderDevice` support; for now it should be a class skeleton

with empty programming methods.



**Follow-up:** user intentionally keeps `m_MIC140` on the form as an explicit

MIC-140 debug handle, but wants it obtained through the standard device

interface. Added `IRecorderDevice.GetNativeObject: TObject`; the MIC-140 object

returns `Self`. `FindAndConnect` searches through

`RecorderDeviceManager.Search('MIC140')`, checks that `GetNativeObject` is

`TRecorderMic140Device`, stores the object in `m_MIC140`, then explicitly calls

`m_MIC140.AddRef`. The form destructor calls `m_MIC140.Release`. Removed both

the extra MIC-specific interface and the extra retaining interface field on the

form.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0; only existing hints/notes.



## Codex continuation 2026-07-06: disabled MIC device tree and MIC185 info read



**Prompt:** show disabled MIC140/MIC185 devices in the hardware tree with the

disabled-device icon from `ilCommandButtons` index 41, hide tags of disabled

devices from the main tag list, and read MIC183/185 serial/version in the

settings dialog when the device is reachable by IP.



**Done:** Added hardware source visibility helpers in `uRecorderTags.pas`,

including MIC185 source-prefix recognition and filtering of `Detached:` tags.

The main tag list and data-source creation now skip invisible/detached hardware

tags. The hardware tree uses image index 41 for MIC140/MIC185 source nodes that

have no linked tags, and restores disabled source nodes from detached tag source

ids. Deleting/disabling MIC140/MIC185 detaches tags but leaves the source node in

the current tree as disabled.



**MIC185:** Added `RecorderMic185ReadDeviceInfo`, a short Mebius TCP query that

calls `CMic185IoCtlCmdGetSoftVersion`, parses `TMic185HardDeviceInfo`, and

formats the firmware version through `Mic185FormatSoftVersion`. The MIC183/185

settings dialog invokes it on first source load to fill serial number and

version when the IP/port respond.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0 and linked `lib\x86_64-win64\RecorderLnx.exe`. Existing post-build

`copy_sdb_res.bat` still prints a `#!/bin/sh` message, but did not fail

`lazbuild`.



## Codex continuation 2026-07-06: MIC140 count_aver uses Fs=10 and effective ISR



**Prompt:** User clarified that original Recorder channels see `10 Hz`, not

`9.875 Hz`; therefore matching `count_aver=327` must be done through the

effective processing-time factor, not by changing channel Fs.



**Fix:** Restored MIC140 default/channel frequency to `10.0 Hz` in

`TRecorderMic140Device` and `uMic140DebugForm`. `IsrFactor` now uses effective

`103` timer-work ticks for the count-average budget (`K_eff = 1 + 103/640`),

which matches Recorder for MIC140-48, 51 slots, ground off:

`period_decay=57 us -> 327`, `period_decay=200 us -> 298`.



**Docs:** Updated MIC140 protocol docs to remove the old “9.875 for 327”

explanation from the main calculation path and document the effective ISR

factor instead.



**Verification:** `mic140_clock_test.exe` rebuilt and printed

`Default object: Fs(ch)=10.000000 Hz count_aver=327` plus

`10.000 Hz / period_decay=200 us -> 298`. `lazbuild -B

Mic140ProtocolDebug_Codex.lpi` compiles all units but cannot relink while

Lazarus keeps `Mic140ProtocolDebug_Codex.exe` open in a debug session

(`Can't create executable`, error code 5).



**Additional check:** User provided Recorder screenshot for `100 Hz`,

`period_decay=57 us`, `period_decay2=19.688 us`, GND off. Current diagnostic

prints `100.0 Hz / 51 slots / GND off -> count_aver=23`, matching Recorder.

This control point was added to

`Docs/devices/mic140/protocol/08_timing_and_count_aver.md`.



## Codex continuation 2026-07-06: Mic140ProtocolDebug_Codex build fix



**Prompt:** User reported that

`Tests/Mic140ProtocolDebug_Codex\Mic140ProtocolDebug_Codex.lpi` no longer

builds.



**Cause:** `uMic140Device.pas` had a broken identifier split across two lines in

`CheckCountAver`: `MIC140` + `_48_MIN_COUNT_AVER`, producing compiler errors

`Identifier not found "MIC140"` and `";" expected`.



**Fix:** Restored the single identifier `MIC140_48_MIN_COUNT_AVER`.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0; only existing warnings/hints/notes remain.



## Codex continuation 2026-07-06: MIC140 count_aver 327/298



**Prompt:** User rechecked Recorder: `period_decay=57 us` gives `count_aver=327`,

`period_decay=200 us` gives `count_aver=298`. Offline Recorder gives the same

values, so the dialog path should be treated as saved/default math, not live

quartz detection from MIC-140.



**Confirmed:** In original Recorder `mic140ppext.cpp` passes

`module->GetFreqSFor(MIC140_AIN_CHTYPE)` into `CheckPeriodDelay`. That value is

the already stored first AIn channel frequency; the additional dialog does not

recalculate count averaging from the programmed scan timer frequency and does

not issue a MIC-140 network query for quartz frequency.



**Done:** `Mic140EvalAverageSampleCount` now uses `Timing.FrequencyHz`

(`GetFreqSFor` equivalent) as the frame period source, while `ApplyTimerForFreq`

still fills timer programming fields. The debug form now shows `Fs(ch)` and

`Fs(timer)` separately and sets the test channel frequency to `9.875 Hz`.

Protocol docs were updated for 327/298, 57/200 us, the `0.9875 * nominal`

frequency table, and the offline saved-state nuance.



**Verification:** `lazbuild -B Mic140ProtocolDebug_Codex.lpi` completed with

exit code 0. `mic140_clock_test.lpr` was compiled with FPC and

`mic140_clock_test.exe` printed `327` for `9.875 Hz / 57 us` and `298` for

`9.875 Hz / 200 us`; the live TCP part reported device offline.



**Follow-up fix:** User still saw `323` because `TRecorderMic140Device.Create`

initialized `fScanProgram` with `10 Hz` and left `fPollFrequencyHz=0`; paths

that evaluate the offline/default object before the debug form applies

`rdpPollFrequencyHz=9.875` still used strict 10 Hz. Constructor fallback and

`ReadMIC140State` zero-frequency fallback now use

`MIC140_48_RECORDER_DEFAULT_FREQ_HZ = 9.875`. Diagnostic now prints

`Default object: Fs(ch)=9.875000 Hz count_aver=327`.



**State-read update:** user asked to move the MIC140 real-frequency source into

`Tests\Mic140ProtocolDebug_Codex`. Added `TRecorderMic140Device.ReadMIC140State`

in `device\MIC140\uMic140Device.pas`. The stand state now stores

`ModuleClockHz=15.8 MHz`, derives `ActualFrequencyHz` through the original

`ModuleMC114::IndexToFreq` formula, and then assigns that value to

`fPollFrequencyHz` before `SyncScanProgramFromDeviceProperties`. Removed the

manual poll-frequency assignment from `uMic140DebugForm.ConfigureTestDevice`.

Rebuild of `Mic140ProtocolDebug_Codex.lpi` completed with exit code 0.



**Network-read update:** user clarified that `ReadMIC140State` must use a real

network request. Added a minimal MDP TCP command helper in `uMic140Device.pas`

matching `mdpEthernet81::CallCommand`: MDP header `0x12B8`, `STREAM_CMD_ID=1`,

payload `[cmd, argc, retc, args...]`, header/data checksums, PORT=1 response

parsing. `ReadMIC140State` now first sends `CMD_TEST_LOAD=7` with 32 words like

`CheckInitialized`, then sends `CMD_REPLY=113`, parses the 11-word

`TBiosInfoMC031`, and fills `fScanProgram.Firmware`. If the network command

fails, `ReadDeviceParameters` raises `ERecorderDeviceError` instead of silently

using fake state. Rebuild of `Mic140ProtocolDebug_Codex.lpi` completed with

exit code 0.



**Docs follow-up:** documented that legacy `scale_period_16000[]` gives exact

10/20/25/50/100 Hz, while `CheckPeriodDelay` uses the actual AIn channel

frequency from `GetFreqSFor`. The `0.9875 * nominal` examples are now recorded

in `Docs/devices/mic140/protocol/08_timing_and_count_aver.md`, with short

cross-notes in `03_scan_programming.md` and `06_ui_parameters.md`.



**Frequency origin follow-up:** traced the Recorder path more precisely.

`327/318` is downstream of `CheckPeriodDelay(freq, ...)`; the dialog first gets

`freq` from `ModuleMC114::GetFreqSFor(MIC140_AIN_CHTYPE)`, i.e. the first AIn

channel `CChannel::m_Fs`. `9.875 Hz` is not a dialog constant; it is exactly the

10 Hz timer row if `GetFreqClk() = 15.8 MHz`

(`2 * 15_800_000 / (1 * 640 * 5000)`). Checked code shows MIC140 defaults to

16 MHz and `Module::Load()` can restore `freq_clk` from project state; no direct

EEPROM/hardware read of MIC140 `freq_clk` was found in this dialog path.



**Controller-read follow-up:** checked the likely MIC140 controller path.

MC031 Ethernet `ReadCfg()`/`GetFirmware()` read BIOS/device identity fields via

`CMD_REPLY`, but not quartz/frequency. `MeasureFreqCCFromFreqModule()` is a stub

for MC031 Ethernet and MC021 USB. The generic `ScanClock` correction updates the

controller clock (`cc->SetFreqClk`), while MIC140 uses `SELF_CLK`, so its

`Module::GetFreqClk()` continues to use the module's own `freq_clk`.



**Config-file origin follow-up:** traced the physical file writer/reader. The

hardware configuration is stored in Recorder `*.rcfg` via `CRcCore::SaveConfig`

or `ExportSettings`, which create a binary `CCfgStream`. The stream starts with

a top frame containing `CurrentVersion` and `HostDevicesCount`, then each object

is written as a `SaveDevice` type frame (`type_class`) followed by that object's

own frame(s). `CCDevice::Save` writes `module_count`, `module[i]`, then

serializes each module; `Module::Save` writes `bios_path`, `serial_no`,

`self_clk`, and double `freq_clk`. Tags are saved later by `CRcCore::Save` /

`SaveTags`; each `CMeasurementTag` writes double `Freq`, and load immediately

applies it through `m_pDevChan->SetFreq`, so the first AIn channel frequency

used by the MIC140 dialog can come directly from saved tag `Freq`, not

necessarily be recalculated from `freq_clk` during that load.



**Commenting update:** user asked to walk through all classes in the example and

mark interface-method blocks. Added comments in `TRecorderMic140Device` for the

`IRecorderDevice` implementation blocks and object-only methods; added comments

in `TMic140DebugForm`, `TRecorderDeviceManager`, and

`TMic140DiscoveryThread` showing that their methods are object/LCL/TThread

methods rather than implemented interface methods.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0; only existing hints/notes.



## Codex continuation 2026-07-02: device manager decoupling



**Prompt:** the interface form must not depend on a concrete device

implementation. Build a universal manager where devices are registered, and the

form searches through that manager. Keep comments with original Recorder method

names.



## Codex continuation 2026-07-02: connection/search split



**Prompt:** MIC-140 must not be created already bound to a known IP. Move

connection parameters into universal search logic; device parameters should be

read from the device; user/software parameters should be written in a test

configuration function in MainForm.



**Update:** `uMic140Registration.pas` now has a local discovery layer mirroring

RecorderLnx `RecorderMic140Discover`: it probes `192.168.14.*` with short

parallel TCP checks, returns the first found host through

`TRecorderDeviceSearchResult`, and only then the manager applies `rdpHost` /

`rdpPort` to `IRecorderDevice`. The known stand `192.168.14.155` is kept as a

last search candidate when the legacy TCP probe is silent; it is no longer a

constructor default. The form still uses only `IRecorderDevice` and

`RecorderDeviceManager`.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0. `rg` confirms `uMic140DebugForm.pas` has no

`uMic140Device`, `CreateMic140Device`, or `TRecorderMic140Device` dependency.



**Buildability fix:** user requested project buildability. The first rebuild

failed because `uMic140Registration.pas` expected search callback types while

`uRecorderDeviceManager.pas` still had the older registration shape. Restored

`TRecorderDeviceSearchResult`, `TRecorderDeviceSearch`, the `Search` field, and

host/port application in `TRecorderDeviceManager.Search`. A second rebuild

compiled but could not overwrite `Mic140ProtocolDebug_Codex.exe` because a

running test process held it; stopped PID `22548` and rebuilt again.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0; compiler emitted only hints/notes.



**Annotation update:** user asked to annotate `uMic140Registration.pas` and

describe each function's logic. Added an ASCII module header explaining the

registration/search workflow and comments for `RegisterMIC140_48`,

`Mic140TcpProbe`, `TMic140DiscoveryThread.Create`, `Execute`,

`DiscoverMIC140OnSubnet14`, `FindMIC140OnSubnet14`, and `FindMIC140_48`.

Later user asked to make comments Russian. Converted the module/function

comments in `uMic140Registration.pas` to Russian while keeping code identifiers,

Recorder method names, and behavior unchanged.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0; only hints/notes.



**Done:** `TRecorderMic140Device.Create` no longer sets `192.168.14.155` or port.

The manager now supports `TRecorderDeviceSearchResult` and a registered search

function. `RecorderDeviceManager.Search` creates the device and applies found

`rdpHost/rdpPort` through `IRecorderDevice.TrySetDeviceProperty`. MIC-140

registration has `FindMIC140OnSubnet14` as the future broadcast/subnet probing

point. `TRecorderMic140Device.Connect` calls `ReadDeviceParameters`, currently a

stub for hardware-read parameters. The form has `ConfigureTestDevice`, which

writes test/user parameters only through `IRecorderDevice`.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0; no compiler errors or warnings.



**Done:** added `device\uRecorderDeviceManager.pas` with a small

`TRecorderDeviceManager` registry. MIC-140 registration moved to

`device\MIC140\uMic140Registration.pas`; it mirrors original names

`RegisterMIC140_48`, `RegisterDeviceClass`, and `RegisterDevice`. The project

entry includes the registration unit as bootstrap, while `uMic140DebugForm.pas`

uses only `uRecorderDeviceInterfaces` and `uRecorderDeviceManager`.

`FindAndConnect` now calls `RecorderDeviceManager.Search('MIC140')` and then

works only through `IRecorderDevice`.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0. `rg` confirms the form has no dependency on

`uMic140Device`, `CreateMic140Device`, or `TRecorderMic140Device`.



**Done:** added `device\MIC140\uMic140Device.pas` with

`TRecorderMic140Device = class(TInterfacedObject, IRecorderDevice)` and factory

`CreateMic140Device`. The class exposes basic identity/properties/channels,

state transitions for `Connect/Disconnect/ProgramDevice/Start/Stop`, and a stub

`ReadBlock` that returns `False`. The form now can create/connect this stub via

`FindAndConnect`.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0; no compiler errors or warnings, only hints/notes.



## Codex continuation 2026-07-02: Mic140ProtocolDebug_Codex cleanup



**Prompt:** clean `Tests\Mic140ProtocolDebug_Codex` so only the visual form

project remains. Remove extra code and leave only `CheckRow(i: Integer)` in the

form module as the row-green decision point.



**Done:** the folder was reduced to four source files only:

`Mic140ProtocolDebug_Codex.lpi`, `Mic140ProtocolDebug_Codex.lpr`,

`uMic140DebugForm.pas`, and `uMic140DebugForm.lfm`. All protocol, CLI, sniffer,

driver, docs/data, stubs, logs, executable, backup, and build-output artifacts

were removed from this folder. The project is now a minimal LCL GUI with a grid;

`TMic140DebugForm.CheckRow(i: Integer): Boolean` decides whether a row is painted

green.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0 before generated `exe/lib` artifacts were removed

again to keep the folder clean.



## Codex continuation 2026-07-01: single-project GUI/CLI merge



**Prompt:** make `Tests\Mic140ProtocolDebug_Codex\Mic140ProtocolDebug_Codex.lpr`

work like the original GUI stand, keep green rows for codes matching the

reference, remove separate CLI projects, embed CLI/proxy modes into the same

GUI project, and fix the 51-channel Recorder-wire mode (48 AIn + 3 TIn).



**Done:**

- folder now has one Lazarus project only: `Mic140ProtocolDebug_Codex.lpi/.lpr`;

  old `Mic140ProtocolDebugCli_Codex.*` and `Mic140Example_Codex.*` were removed;

- `Mic140ProtocolDebug_Codex.exe` now dispatches GUI, `--auto`, numeric CLI

  duration mode, and `--proxy` sniffer mode from one executable;

- GUI config parser accepts the same protocol flags as headless mode;

- defaults are Recorder-wire: `tin=3`, auto FIFO stride resolves to 51, visible

  AIn remains 48;

- stream row recovery now accepts shifted rows only when the full 51-word row is

  present, so TIn words are not silently truncated;

- GUI table still marks reference-matching rows green through

  `Mic140AdcTablePrepareCanvas`;

- capture docs and scripts now point to `Mic140ProtocolDebug_Codex.exe`.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0. Headless checks

`Mic140ProtocolDebug_Codex.exe --auto 1 --no-settle` and

`Mic140ProtocolDebug_Codex.exe 1` both used the unified executable and logged

`ch=48 tin=3 fifo=-1`, then stopped at `TCP probe failed` because the device at

`192.168.14.155:4000` is currently not accepting TCP.



## Codex continuation 2026-07-01: protocol rewritten from live dump



**Prompt:** пользователь попросил на основе снятого дампа переписать протокол

как в задании и править до рабочего состояния без остановок.



**Confirmed facts from live Recorder dump `20260701_153018`:**

- stream profile: `PORT=0 size=163`, `msgWords=163`, `dataWords=153`;

- payload row: `stride=51`, `samples=3`;

- row layout: 48 AIn words, then TIn slots `48..50`;

- original Recorder programming keeps `m_ChanDump[2]=channels.Size()=48`.



**Code/doc changes in `Tests\Mic140ProtocolDebug_Codex`:**

- `--recorder-wire` / `MIC140_DEBUG_RECORDER_PROFILE=1` now mean

  `fifoStride=51`, `chanDump[2]=48`, `fifoSamples=3`;

- `VisibleChanDumpCount` no longer returns 51 for env recorder profile;

- `ADDCHANNELMODULE` argument 3 is now `Length(chanDump)`, matching original

  `Size=count_chan_bios+SIZE_START_DESC_CHAN_BIOS`; passing only `ptrCnt`

  produced stream payload with a visible offset/garbage at the row start;

- CLI/help/config comments corrected from the old wrong `chanDump=51`;

- acceptance reference loader prefers

  `Data\mic140_adc_reference_recorder_wire_live_20260701_153018.txt`;

- protocol and capture docs now explicitly describe the `chanDump=48` vs

  `stride=51` distinction.



**Verification:** all three Codex `.lpi` rebuild with exit code 0. Live CLI

before the `Length(chanDump)` fix reached the device and showed correct

programming headline (`slots=51`, `fifoStride=51`, `fifoReady=153`,

`msgWords=163`, `ptrHead=[48,323,48,...]`), but payload rows were offset and

second-bank codes saturated. After the fix, live retest was blocked by device

network state: `192.168.14.155` stopped accepting TCP `4000`; final check also

timed out ping while Recorder was open. Recorder process started by Codex was

closed. Next step after hardware reset/link recovery: rerun

`Mic140ProtocolDebugCli_Codex.exe --auto 20 --recorder-wire --tin-slots 3`.



## Live Recorder capture 2026-07-01 15:30



**Промпт:** пользователь остановил live-захват оригинального Recorder и попросил разобрать дампы и обновить протокол.



**Сделано:**

- Разобран свежий ETL `Tests\Mic140ProtocolDebug_Codex\Data\captures\netsh_192.168.14.155_20260701_153018.etl`.

- Parser: `Tools\parse_mdp_from_etl.py`.

- Найден рабочий Recorder wire profile просмотра: `total_valid_mdp=142`, `PORT=0=133`, `PORT=1=9`, `PORT=0 size=163 count=133`, `msgWords=163`, `dataWords=153`, `stride=51`, `samples=3`, TIn в слотах `48..50`.

- Созданы/обновлены:

  - `Data\captures\recorder_mdp_reference.txt`;

  - `Data\captures\recorder_mdp_control_examples.txt`;

  - `Data\mic140_adc_reference_recorder_wire_live_20260701_153018.txt`.

- Исправлен parser: теперь реально пишет `recorder_mdp_control_examples.txt`, а не только печатает путь.

- Обновлены `Docs\mic140_protocol.md`, `Docs\capture_workflow.md`, `Data\captures\README.md`.



**Вывод:** старый Cursor ETL `netsh_192.168.14.155_20260701_135935.etl` — валидный MDP-дамп, но не эталон Recorder-просмотра (`msgWords=106`, `stride=48`, `samples=2`). Для дальнейшей сверки использовать live Recorder dump `20260701_153018` и режим стенда `--recorder-wire --tin-slots 3`.



## Codex-стенд `Tests/Mic140ProtocolDebug_Codex`



**Промпт:** создать в `Tests\Mic140ProtocolDebug_Codex` автономный Lazarus-тест для отладки протокола MIC140, без unit-ов из других папок, с документацией протокола, сниффером, контрольными дампами и понятной точкой входа `DevMng.Search -> Connect -> Setup -> Start -> OnGetBlock -> Stop`.



**Сделано:**

- Создан автономный набор проектов:

  - `Mic140Example_Codex.lpi` — минимальный event-based пример API.

  - `Mic140ProtocolDebugCli_Codex.lpi` — CLI авто-прогон и proxy/sniffer.

  - `Mic140ProtocolDebug_Codex.lpi` — LCL-интерфейс стенда.

- Все `.lpi` используют только локальные пути `stubs;Driver;Driver\utils`; production units из `Device/` и соседний `Mic140ProtocolDebug` не подключаются.

- В `Docs` добавлены:

  - `task.md` — сохраненное задание и критерии готовности.

  - `mic140_protocol.md` — краткое описание MIC-140/MDP, источники, профили, приемка.

  - `capture_workflow.md` — как запускать proxy/netsh, Recorder и parser.

- Локальный parser `Tools\parse_mdp_from_etl.py` исправлен: при переданном ETL пишет результат рядом с этим ETL, а не в старый `Mic140ProtocolDebug`.

- Дамп `Data\captures\netsh_192.168.14.155_20260701_135935.etl` разобран: `total_valid_mdp=200`, `PORT=0=63`, `PORT=1=137`, `PORT=0 size=106`, `stride=48`. Это валидный MDP-дамп MIC-140, но не Recorder wire profile `msgWords=163/stride=51`.

- Созданы `Data\captures\recorder_mdp_reference.txt`, `Data\mic140_adc_reference_recorder_wire_exported.txt`, `Data\captures\README.md`.



**Проверка:** все три проекта собраны через `C:\lazarus\lazbuild.exe -B`, exit code 0. Финальные сборки без warnings, только hints/notes.



## Промпт

Продолжить стенд MIC-140 (`Tests/Mic140ProtocolDebug`): приёмка AIn 1–48 ±50, сверка с Recorder, использовать навык RecorderLnx.



## Сделано



### Эталоны

- `Data/mic140_adc_reference.txt` — production scan (fifo=48), stand steady-state 01.07

- `Data/mic140_adc_reference_recorder_wire.txt` — Recorder MDP wire (stride=51, TIn)



### Код стенда

- При `tin-slots=0` strict-приёмка **только AIn 1–48** (TIn пропускается)

- `stand-good` и ADC-таблица в логе: M/48 без TIn при tin=0

- Дефолты: production scan, settle=10s, bank2-delay=1, fifo=48



### Сборка

`lazbuild -B Mic140ProtocolDebugCli.lpi` — **OK** (exit 0)



## Live-тесты (192.168.14.155 rev14.1)



| Команда | read | published | stand-good | Примечание |

|---------|------|-----------|------------|------------|

| `--auto 25` | 124 | 0 | 24/48 @blk49 | CH01–24 OK; CH25 Δ≈388→109 к концу прогрева |

| `--auto 40 --settle-sec 20` | 199 | 0 | 24/48 @blk99 | CH25 Δ≈109; CH28+ тысячи кодов |



Поток стабилен (`readGaps=0`, `corrupt=0`, ~5 blk/s).



## Выводы (D26–D28)



- **D26:** production `tin=0`, 48 slots — правильный путь; `tin=3` ломает 2-й банк

- **D27:** wire-эталон (stride 51) ≠ stand fifo=48 — два файла эталона

- **D28:** CH25–26 ещё прогреваются после 10–20 s; CH28+ — programming/ME048, не только settle



## Открыто



1. PASS AIn 25–48 ±50 к stand-эталону

2. TIn 1–3: гибрид (48 scan + READMEMDM 114) или wire-профиль

3. Захват programming PORT=1 через proxy для сравнения с Recorder

4. Сверка shadow `Driver/` с production `Device/MIC140v2/` после PASS стенда



## Команды



```powershell

cd D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug

.\Mic140ProtocolDebugCli.exe --auto 25

.\Mic140ProtocolDebugCli.exe --auto 40 --settle-sec 20

.\Mic140ProtocolDebugCli.exe --auto 10 --recorder-wire --tin-slots 3

```



## Codex continuation 2026-07-03: MIC140 count_aver Recorder match



**Prompt:** Windows Recorder shows MIC140 average counts 327 and 318 in the

additional settings dialog for `period_decay` 57 us and 100 us; make the Codex

calculation match exactly.



**Confirmed:** `Mic140EvalAverageSampleCount` follows original

`MIC140_96_rce/mic140_96mod.cpp::CalcCountAver`. For MIC140-48 the count uses

51 slots (`48 AIn + 3 TIn`) when all-channel sampling is enabled. At exactly

10.0 Hz this gives `323/314`; the Recorder screenshot values `327/318` match

the same original formula when the actual first AIn channel frequency is about

`9.875..9.885 Hz`.



**Done:** changed the Codex debug stand test configuration in

`Tests/Mic140ProtocolDebug_Codex/uMic140DebugForm.pas` from `10.0` to `9.875`

Hz and recorded the investigation in

`errors/2026-07-03-mic140-average-count-recorder-match.md`.



**Verification:** `C:\lazarus\lazbuild.exe -B ...\Mic140ProtocolDebug_Codex.lpi`

completed with exit code 0; only existing hints/notes.



## Codex continuation 2026-07-07: MIC185 recording undercount at 10 Hz



**Prompt:** MIC-185 in RecorderLnx recorded only about 13 values in 3 seconds at

`Fs=10 Hz`; check and fix recording/buffer efficiency.



**Fix:** `Device/mic185/uMic185MebiusTcpProtocol.pas` no longer drops earlier

measurement packets during `ReadMeasDataBlock` drain. Previously the code read

up to 32 packets but replaced `ABlock` with the latest `dev_id=1` packet, so

with MIC185 `BlockSize=1` the recording effectively followed the 200 ms source

tick (~15 samples/3 s) instead of the 10 Hz stream. Added block aggregation via

`AppendMebiusFloatBlock`, using `Move` for per-channel `Single` array copies.



**Buffer check:** tag storage already uses a ring buffer in

`Core/uRecorderTags.pas` and uses `Move` for last-block / transformed

`Double` block copies. The remaining per-sample loops in MIC185 publication are

`Single -> Double` conversion and cannot be replaced by a raw `Move`.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit

code 0. No separate MIC185 `.lpi` test project was found by `rg --files`.



**Stop follow-up:** user reported debugger exception on transition to Stop:

`Unexpected Mebius packet signature: 00000001` in

`uMic185MebiusTcpProtocol.pas`. Root cause was a race: MIC185

`RequestStop` called `fDevice.Stop` from the external/UI thread while the

worker could still be in `ReadBlock`, creating concurrent reads on the same TCP

socket. Fixed `TRecorderMic185DataSource.RequestStop` to only set inherited

`TryStop`; device `Stop/Disconnect` now runs only from the worker-thread

`Stop`. `TryIoControl` was also hardened so protocol exceptions return `False`

with an error string. Rebuild of `RecorderLnx.lpi` completed with exit code 0.



## Codex continuation 2026-07-07: MIC140 offline icon in hardware tree



**Prompt:** MIC140 is currently powered off; in the device tree, show the failed

device picture when the connection function returns `False`, and use 1 second

timeouts instead of 5 seconds. The requested failure image is index 41 from the

command image list passed from the main form.



**Fix:** `UI/uRecorderSettingsDialog.pas` now probes MIC140 and MIC185 source

nodes while populating the hardware tree. MIC140 uses

`RecorderMic140TcpProbe(..., 1000)`, MIC185 uses

`RecorderMic185ReadDeviceInfo(..., 1000)`. If the source has no linked tags or

the probe returns `False`, the source node uses `CDeviceDisabledImageIndex`

(41); otherwise it keeps the controller image.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit

code 0. The existing post-build `copy_sdb_res.bat` still prints `#!/bin/sh` is

not recognized, but lazbuild exits successfully.



**Follow-up:** tags linked to an inactive/offline MIC source are now hidden from

the main form tag/channel list. `TMainForm.UpdateActiveSourceIds` probes unique

MIC140/MIC185 sources with a 1000 ms timeout after refreshing tag-based source

ids and unregisters sources that do not respond. The settings dialog keeps those

tags visible on the Channels tab but draws image index 54 in the selected

channels grid. Rebuild of `RecorderLnx.lpi` completed with exit code 0.



**Icon layout follow-up:** the selected-channel grid no longer draws inactive

source image 54 over the tag name. `UI/uRecorderSettingsDialog.pas` now uses a

dedicated leading 20 px icon column, keeps tag names in the next column, scales

the large image-list bitmap into a centered 16x16 px rectangle, and ignores the

empty icon column for sorting. The first rebuild reached compilation but could

not relink because `RecorderLnx.exe` was running as PID 21672; after stopping

that process, rebuild of `RecorderLnx.lpi` completed with exit code 0. The

existing `copy_sdb_res.bat` `#!/bin/sh` post-build message still does not fail

the build.



**Hardware tree follow-up:** user asked not to show child tags under devices in

the settings hardware tree. `UI/uRecorderSettingsDialog.pas` now keeps

`PopulateHardwareTree` source-only: Mera, MIC140, and MIC183/185 nodes are shown

without per-channel child nodes; channel membership remains in the channel

grids. `rg` confirms no `Items.AddChild(lSourceNode, ...)` calls remain.

Rebuild of `RecorderLnx.lpi` completed with exit code 0 after stopping a running

`RecorderLnx.exe` process that held the output exe.



## Codex continuation 2026-07-08: MIC185 channel programming



**Prompt:** реализовать программирование каналов MIC-185 как в оригинальном

Recorder, не менять базовый `TRecorderDevice` и не задеть поток сбора данных.



**Fix:**

- `Device/mic185/uMic185MebiusTypes.pas`: добавлен

  `TMic185ChannelProgramSettings` и `Mic185BuildSettingsEx`, который заполняет

  `CMIC185V2_BASECHAN_SETTINGS` по каждому измерительному каналу: connected,

  frequency, block size, range, soft balance, commutation, shunt, eval,

  sensitivity, resistance, sensor scheme. Старый `Mic185BuildSettings` оставлен

  wrapper-ом с дефолтами Recorder.

- `Device/mic185/uMic185Device.pas`: добавлен только MIC185-специфичный метод

  `ApplyChannelProgramSettings`; базовый `TRecorderDevice` не менялся.

- `Device/mic185/uRecorderMic185DataSource.pas`: настройки канала читаются из

  `TRecorderTag.SourceValueMode` в формате `mic185:range=...;commut=...` и

  передаются в прибор перед `Connect/ProgramDevice`. `DoTick`, `ReadBlock` и

  stop/read threading не менялись. Все 64 измерительных канала остаются

  `Connected=True`, чтобы не менять размер и порядок потокового кадра.

- `Device/mic185/UI/uRecorderMic185ChannelDialog.pas`: диалог канала теперь

  загружает/сохраняет диапазон, коммутацию, схему включения, шунт,

  программный баланс, чувствительность и сопротивление в `SourceValueMode`.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0 and linked `lib\x86_64-win64\RecorderLnx.exe`. Existing post-build

`copy_sdb_res.bat` still prints the `#!/bin/sh` message, but it does not fail

`lazbuild`.

## Codex continuation 2026-07-09: MIC185 settings buttons and source persistence



**Prompt:** Check MIC-185 settings dialog buttons; `Select all` was not

implemented. Inspect MIC-185 settings storage. When saving project settings,

each data source should have its own save function. MIC-185 settings must store

links to tags so hardware setup for each tag is understandable and reachable

from tag settings.



**Fix:**

- `Device/mic185/UI/uRecorderMic185SettingsDialog.pas/.lfm`: wired `Select all`,

  `Properties`, `Apply`, `OK`, `Balance`, and `Metrology`. `Select all` creates

  or relinks tags for all MIC183/185 rows. `Properties` creates a missing tag

  for the selected row and opens the MIC185 channel dialog. `Apply` now stores

  source config without closing the dialog. `OK` stores the source before close.

  `Balance`/`Metrology` now show explicit not-implemented messages instead of

  silently doing nothing.

- `Device/mic185/uRecorderMic185DataSource.pas`: added MIC185-specific

  save/load helpers for project data-source config. The JSON data source entry

  gets a `mic185` object with host, port, default poll frequency and

  `tagLinks[]` records (`tagName`, `address`, `sourceValueMode`,

  `pollFrequencyHz`).

- `Core/uRecorderProjectFiles.pas`: project save/load now calls the MIC185

  source-specific config hooks alongside the existing generic and MIC140 saves.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0. Existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh` message,

but it does not fail `lazbuild`.



## Codex continuation 2026-07-10: MIC185 units from codes, GX message, comments, encoding



**Prompt:** User reported that MIC185 hardware-GX memory read shows a MIC-140

message, changing tag units to Ohm still leaves values looking like codes,

MIC185 modules need comments, and dynamic dialogs/menus showed mojibake.



**Fix:**

- `Device/mic185/uRecorderMic185DataSource.pas`: raw MIC185 sample values are

  now treated as codes first. Without real hardware-GX coefficients the source

  applies nominal fallback `U_mV = code * nominal_mV / 32768`, then converts to

  the selected tag unit. This keeps the MIC185 protocol unchanged.

- `Device/mic185/UI/uRecorderMic185SettingsDialog.pas`: linking/creating a

  MIC185 measurement tag no longer overwrites an existing selected unit; range

  is recalculated through `RecorderMic185EffectiveRangeMax`.

- `UI/uTagSettingsDialog.pas`: the hardware-GX download button no longer says

  "no MIC-140 channels" for MIC185. It now reports that MIC185 hardware-GX read

  from device memory is not implemented yet and must be separate protocol work.

- Added comments/codepage markers across MIC185 constants/exported functions

  and updated `Docs/devices/mic185/value_units_conversion.md` with the nominal

  `32768 -> 100% range` fallback.

- Removed redundant `CP1251ToUTF8('...')` from active dynamic UTF-8 UI strings

  and fixed detected mojibake in calibration properties, MIC185 source probe

  units, and one MERA parser comment.

- Added `errors/2026-07-10-mic185-units-gx-encoding.md` with facts, actions and

  verification.



**Verification:** `rg` found no remaining active `CP1251ToUTF8('...')` dynamic

literal wrappers and no active mojibake patterns in UI/Core/MIC185 `.pas/.lfm`.

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`

completed with exit code 0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`

passed; one earlier run hit a timing flake in the mock-thread test, immediate

reruns passed.



## Codex continuation 2026-07-10: MIC185 physical units and tag dialog buttons



**Prompt:** User asked to make the MIC185 channel dialog calculate the actual

range from selected settings, publish MIC185 tag values in selected units, and

restore original-like tag settings dialog controls: hardware-source setup,

zero-balance, hardware characteristic view/edit, and read-GX button with icon

57. User explicitly asked not to damage the MIC185 protocol.



**Fix:** `Device/mic185/uRecorderMic185DataSource.pas` now contains MIC185

effective-range and value-conversion helpers. Protocol/raw acquisition remains

in mV; `TRecorderMic185DataSource.PublishMeasurementBlock` converts values just

before adding samples to tags. Existing MIC185 tag units are no longer reset to

mV during source/tag creation, so selected `Ом`/`мкм/м` units survive.



**UI:** `Device/mic185/UI/uRecorderMic185ChannelDialog.pas` recalculates

`edActualRange` when nominal range, actual unit, module current, sensor scheme,

strain sensitivity, or external resistance changes. `UI/uTagSettingsDialog.pas`

now treats MIC185 like MIC140 for hardware-source setup and zero-balance button

visibility; the address-line setup button is no longer forcibly hidden.

`UI/uRecorderCommandImages.pas` reserves tag-dialog icon index 57 for the

hardware-curve read action.



**Docs:** Added `Docs/devices/mic185/value_units_conversion.md` with source

references from original `windev-v3.9` and a RecorderLnx behavior table. The

document records that MIC185 hardware-GX download from module is still not

implemented without protocol work; the current change only restores the UI and

keeps conversion in the data source.



**Verification:** First `lazbuild -B RecorderLnx.lpi` compiled but could not

overwrite `RecorderLnx.exe` because a running process held it. Stopped PID 9200

and rebuilt successfully. Existing post-build `copy_sdb_res.bat` still prints

the `#!/bin/sh` message but lazbuild exits 0. Also ran

`Tests/RecorderTests/DataSources/lib/RecorderDataSourcesTest.exe`: passed.



## Codex continuation 2026-07-09: MIC185 multi-row settings and programming trace



**Prompt:** `Select all` in the MIC183/185 settings dialog did not visibly select

all channels, changing a range affected only one row, and live programming of

500 mV needed comparison with the original Recorder/Mebius MIC185V2 code.



**Findings:**

- Original MIC185V2 range indices match RecorderLnx: `0 = +/-500 mV`,

  `1 = +/-50 mV`, `2 = +/-5 mV`, `3 = +/-0.5 mV`.

- Original programming order is also matched: `PROGRAMM_DEVICE_BIN`,

  `SET_SESSION_ID`, then `PROGRAM`.

- `RecorderMic185ChannelAddressToIndex` parses `MIC183_185-{3-14}` from the

  last dash to `ch14`, so the observed channel-4 overrange is not explained by

  the tag-address parser.



**Fix:**

- `Device/mic185/UI/uRecorderMic185SettingsDialog.pas`: `Select all` now sets

  the grid selection rectangle after creating/linking all 70 rows, so the UI

  shows the selected range. `Properties` collects the selected measurement rows

  and applies the edited channel settings to every selected measurement channel.

  Temperature/UTS rows are not mass-edited by the measurement-channel dialog.

- `Device/mic185/uRecorderMic185DataSource.pas`: `ApplyChannelProgramSettings`

  writes a concise trace to `LogWindows.log`, e.g. `ch14 range=0 commut=0`, so

  the next live run can prove which slot is actually sent to the device.

- `LoadMic185DataSourceConfigs` now restores `dataSources[].mic185.tagLinks[]`

  into tags when loading a project, not only registers the data source.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0 and linked `lib\x86_64-win64\RecorderLnx.exe`. The existing post-build

`copy_sdb_res.bat` still prints the `#!/bin/sh` message, but it does not fail

`lazbuild`.



**Startup crash follow-up:** after saving MIC185 settings, startup could crash

in `TRecorderTagRegistry.AddTag` with `Tag id already exists`. Root cause was

load order: `LoadMic185DataSourceConfigs` created tags from `mic185.tagLinks[]`

before the generic `tags[]` loader added the saved tags with persisted IDs.

`Core/uRecorderProjectFiles.pas` now calls `LoadMic185DataSourceConfigs` after

the generic tag loop, so MIC185 links update existing tags and only create truly

missing links. Rebuild of `RecorderLnx.lpi` completed with exit code 0 after

stopping a running `RecorderLnx.exe` process that held the output file.



**MIC185 source-settings follow-up:** user clarified that MIC185 hardware

settings must not live in tags. Tags are now treated only as bindings

(`SourceId` + channel `Address`); range/commutation/sensor/shunt/balance/etc.

are stored in the source node under `dataSources[].mic185.channels[]`.

`tagLinks[]` keeps only tag binding data. Old `sourceValueMode` values in

MIC185 tags or old `tagLinks[]` are migrated into the source config on load and

then cleared from tags. Programming now reads from the source config. Rebuild of

`RecorderLnx.lpi` completed with exit code 0.



**MIC185 Apply/OK programming follow-up:** user reported that multi-channel

range changes were reset after `Apply` -> `OK` and asked to save settings in

the device/source and program the instrument when leaving settings. MIC185

settings dialog now keeps channel hardware settings in `fChannelSettings`, loads

them from `dataSources[].mic185.channels[]`, stores them on `Apply`/`OK`, and

calls `RecorderMic185ProgramConfiguredSource` immediately. Source-level module

current is persisted as `dataSources[].mic185.powerMaCode`; the channel dialog

module power combo now maps mA to the MIC185 DAC code using the original Mebius

formula. `ProgramDeviceBin` writes the configured power code and logs the full

programming summary. If programming fails on `OK`, the MIC185 settings dialog

stays open. Rebuild of `RecorderLnx.lpi` completed with exit code 0.



**MIC185 OK persistence follow-up:** user reported that setting a channel range

to `500 mV` and reopening the MIC185 settings dialog still showed `5 mV`.

`Device/mic185/UI/uRecorderMic185SettingsDialog.lfm` no longer lets the `OK`

button close the form by its own `ModalResult`; `btnOkClick` now explicitly

stores all grid tags/source channel settings, calls MIC185 programming, and only

then sets `ModalResult := mrOk`. `ApplyRecorderMic185SourceDialog` also repeats

`StoreAllGridTags` after a successful modal close so the source node is flushed

before the caller refreshes UI. `StoreChannelSettingsConfig` logs

`SettingsDialog stored ... ch4 range=...` for the user's overrange channel

check. Rebuild of `RecorderLnx.lpi` completed with exit code 0 after stopping

the running `RecorderLnx.exe` that locked the output exe.



**MIC185 final persistence root cause:** fresh logs showed the MIC185 dialog did

store/program `range=0`, but the common settings close path immediately called

`TRecorderSettingsSourceProbe.SyncToRegistry`, which removed the existing

MIC185 configured source and recreated it without `SpecificConfigText`.

`UI/uRecorderSettingsSourceProbe.pas` now removes only hardware sources that are

no longer desired and preserves existing MIC185 source entries, so

`dataSources[].mic185.channels[]` survives `OK`, runtime source restart, and

project save. Rebuild of `RecorderLnx.lpi` completed with exit code 0.



## Codex continuation 2026-07-10: MIC185 settings packet table / TKC channel



**Prompt:** User reported that MIC-185 range switching works, but enabling the

thermocompensation/reference channel in the original Recorder causes hardware

subtraction like a bridge circuit, while RecorderLnx currently shows no effect.

User asked to assemble a table for the device settings packet with parameter

purpose, byte size, original behavior, RecorderLnx behavior, and source header;

also asked whether `windev-v3.9\examples\mebius.daq` contains useful info.



**Done:** Added

`Docs/devices/mic185/settings_packet_table.md`. The document records sources,

the `CMIC185V2_BASECHAN_SETTINGS` 56-byte slot map, the 3976-byte

`CMIC185V2_BASESETTINGS` map with offsets, and original-vs-RecorderLnx

behavior for every relevant field.



**Finding:** The likely reason the thermocompensation/reference channel has no

effect in RecorderLnx is not range programming. Original

`CMIC185V2Channel::SetProperty(MEPROPCH_MIC185V2_CHANTC)` writes the selected

addition input into `GroupAddition_[channel div 16]`, and

`MEPROP_TERMO_COMP` writes `bTKC_`. RecorderLnx currently sends all

`GroupAddition[] = CMic185ModAddOff` and `TemperatureCompensation=False`.



**examples\mebius.daq:** Useful as a portable MIC185 Mebius DAQ example and

programming-order confirmation (`SET_CONTROLLER_PARAMS`,

`PROGRAMM_DEVICE_BIN`, finish programming), but the authoritative packet layout

is in the shared `Mebius\MebiusDAQDevices\mic185v2` sources.



## Codex continuation 2026-07-10: MIC185 TKC/reference-channel programming



**Prompt:** User confirmed that the original Recorder currently assigns

compensation channel 1 to the first 16 measurement channels and asked to bring

RecorderLnx to the analogous state so the thermocompensation/reference channel

works.



**Fix:** `Device/mic185/uMic185MebiusTypes.pas` now has

`TMic185GroupAdditionArray` and default group additions

`[CMic185ModAdd1, CMic185ModAddOff, CMic185ModAddOff, CMic185ModAddOff]`.

`Mic185BuildSettingsEx` writes caller-provided `GroupAddition[]` and

`TemperatureCompensation` into `ProgramDeviceBin` instead of hard-coding all

groups off and TKC false.



**Data source:** `Device/mic185/uRecorderMic185DataSource.pas` now reads, logs,

saves and loads `dataSources[].mic185.groupAddition[]` plus

`dataSources[].mic185.temperatureCompensation`. Missing fields in older project

files default to the observed original state: compensation channel 1 for group

0 (channels 1..16), other groups off, TKC enabled. Live programming logs now

include `tkc=True groupAddition=[0,4,4,4]`.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0. Existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh` message,

but it does not fail `lazbuild`.

## Codex continuation 2026-07-10: MIC185 hardware GX read and tag dialog buttons



**Prompt:** User reported that the hardware-GX edit/view button in tag settings

still opens a MIC-140-only message, while MIC-185 should open the GX settings

dialog. The explicit read-GX button should read MIC-185 hardware coefficients

like the original Recorder device-level path, but without damaging the MIC-185

measurement protocol.



**Fix:**

- Added `Device/mic185/uRecorderMic185Calibration.pas`. It reads the current

  MIC-183/185 channel evaluator through `CallCommand(IOCTL_CMD_GET_CALIBR_KOEF)`,

  using the original sources as layout reference:

  `examples\mebius.daq\...\mic185.cpp::LoadCalibrCoefficients` and

  `MebiusDAQDevices\mic183\mic183base\ComputePhysical.h`.

- The read result is stored as a two-point `TRecorderCalibration`

  implementing original linear math `k * (code - b)`, then assigned to the

  tag as `HardwareCalibrationName` with `HardwareCalibrationEnabled=True`.

- `uRecorderMic185DataSource.pas` now applies the tag hardware calibration

  before unit conversion. If no hardware GX is assigned, the previous nominal

  fallback remains: `32768` codes = `100%` of the selected range.

- `UI/uTagSettingsDialog.pas` now separates actions:

  hardware-GX select/view opens the calibration list and properties dialog,

  edit opens properties for any assigned hardware GX, and read-GX calls either

  MIC-140 or MIC-185 depending on the selected tag source.



**Safety note:** `IOCTL_CMD_RELOAD_CALIBR` was documented but not called from

the tag dialog because it changes the OMAP-loaded flash calibration slot and

requires a separate device `fileType`. The explicit button reads the evaluator

already loaded by the device, matching the original working-channel path.



**Verification:** First rebuild compiled but could not relink because

`RecorderLnx.exe` was running as PID 15324; stopped it and rebuilt successfully:

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`

exit code 0. Existing post-build `copy_sdb_res.bat` still prints the `#!/bin/sh`

message but does not fail `lazbuild`. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`

passed.



## Codex continuation 2026-07-10: MIC185 hardware GX display k,b



**Prompt:** User reported that the hardware-GX view/edit button opened a

confusing channel/calibration list instead of showing the MIC-185 hardware GX,

and the module memory read result showed an id-like string while it should show

the `k` multiplier and `b` offset.



**Fix:** `Device/mic185/uRecorderMic185Calibration.pas` now exposes the detailed

MIC185 read result (`k`, `b`, calibration name) and helper functions that format

or reconstruct `k,b` from the stored two-point hardware calibration

(`y = k * (code - b)`). `UI/uTagSettingsDialog.pas` now uses the hardware-GX

field as display text for MIC185 `k,b` and no longer writes that display text

back into `HardwareCalibrationName` on OK/Apply. The hardware-GX view button

opens the assigned calibration properties directly. The explicit read-GX button

adds per-tag `k=...; b=...` lines to the success message.



**Verification:** First `lazbuild -B RecorderLnx.lpi` reached linking but failed

with error code 5 because `RecorderLnx.exe` PID 14752 held the output file.

After `Stop-Process -Id 14752`, `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`

passed after the final display change.



## Codex continuation 2026-07-10: active hardware sources after tag settings OK



**Prompt:** User reported that after opening tag settings and closing it with

OK, MIC140 tags appeared in the main tag list even though the MIC140 source was

not connected. The suspected cause was `fActiveSourceIds` receiving MIC140 from

tag-dialog logic.



**Fix:** `TTagSettingsDialog.CreateDialog` no longer calls

`RefreshActiveSourcesFromTags`. `TRecorderTagRegistry.RefreshActiveSourcesFromTags`

now keeps baseline virtual/manual/debug/MERA visibility but does not mark

MIC140/MIC185 hardware sources active just because tags exist.

`TMainForm.UpdateActiveSourceIds` now explicitly registers a hardware source

only when `RecorderHardwareSourceLinkOk` passes and unregisters it otherwise.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`

passed. Added `errors/2026-07-10-active-source-tag-dialog.md`.



## Codex continuation 2026-07-10: MIC185 hardware-GX checkbox mode



**Prompt:** User clarified that when the hardware-GX checkbox is unchecked, the

tag must show raw codes. When it is checked and GX exists, values should be

shown according to the selected unit/conversion mode.



**Fix:** `TRecorderMic185DataSource.PublishMeasurementBlock` now checks

`TRecorderTag.HardwareCalibrationEnabled` before MIC185 unit conversion. If the

checkbox is off, raw `ABlock.Values` are published as already-transformed

values, so the common tag path does not apply hardware GX. If the checkbox is

on, the previous path remains: assigned hardware GX is applied when present,

otherwise the nominal `32768 -> 100% range` fallback is used before converting

to the selected MIC185 unit.



**Verification:** First rebuild failed only at link because `RecorderLnx.exe`

PID 19184 held the output file; after `Stop-Process -Id 19184`,

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`

completed with exit code 0.



## Codex continuation 2026-07-14: MC-201 fast Config and Russian docs



**Prompt:** User reported that programming MC-201 modules is still slow compared

with original Recorder and asked to rewrite test documentation/comments in

Russian.



**Fix:** Added a fast path in `TMc201LegacyMdpClient.LoadMc201BiosIdma`: before

full `.bio` upload the client writes IDMA `0x6000`, reads `VAR_TMODE`, checks

`A5A5`, and validates the loaded module BIOS with `CMD_INIT`. If validation

passes, full upload is skipped and the slot is cached for the current TCP

client. If validation fails, full upload remains as fallback. Rewrote

`Mc201ProtocolDebug\README.md`, `Docs\devices\mc\mc201.md`, and Pascal comments

in the test to Russian.



**Verification:** Rebuilt `Mc201ProtocolDebug.lpi` with exit code 0. Live

`--cli --play-diagnostic-ms=1 --host=192.169.12.87 --port=4000 --timeout-ms=1200 --slots=4`

completed successfully in under a second from process start with `Config OK`,

`STARTSCANMAIN OK`, data packets, `STOPSCANMAIN OK`, and

`RESULT Mc201PlayDiagnostic passed`.



## Codex continuation 2026-07-14: MC-201 BIOS embedded resource



**Prompt:** User asked to copy the MC-201 BIOS binary into project resources and

compile it into the executable in a Linux-compatible way; future MIC-185 and

other hardware binaries should follow the same rule.



**Fix:** Copied `mc_201a.bio` to

`Tests\RecorderTests\Mc201ProtocolDebug\resources\devices\mc201\mc_201a.bio`.

Added `resources\mc201_protocol_debug.rc` with resource `MC201A_BIO` of custom

type `MC201BIO`, included it from `Mc201ProtocolDebug.lpr`, and added

`uMc201FirmwareResources.pas`. `TMc201LegacyMdpClient.LoadMc201BiosIdma` now

loads BIOS bytes from the embedded resource first and uses the original

`windev-v3.9` path only as fallback. Added CLI check `--check-resources`.



**Verification:** `lazbuild -B Mc201ProtocolDebug.lpi` completed with exit code

0 and compiled `resources\mc201_protocol_debug.rc`. `Mc201ProtocolDebug.exe

--cli --check-resources` printed `RESOURCE MC201A_BIO OK

source=resource:MC201A_BIO bytes=22040`. Live

`--cli --play-diagnostic-ms=1 --host=192.169.12.87 --port=4000 --timeout-ms=1200 --slots=4`

still completed with `Config OK`, data packets, `STOPSCANMAIN OK`, and

`RESULT Mc201PlayDiagnostic passed`.

`D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`

passed.



## Codex continuation 2026-07-10: MIC185 hardware-GX assignment persistence



**Prompt:** After reading hardware GX for many selected MIC185 channels and

pressing OK, reopening one channel showed an empty hardware-GX field. The tag

must remember the assigned GX and display either the GX name or an alias when

only coefficients are available.



**Fix:** `Core/uRecorderProjectFiles.pas` now persists

`hardwareCalibrationEnabled` and `hardwareCalibrationName` for every tag.

`UI/uTagSettingsDialog.pas` now treats the MIC185 hardware-GX edit field as a

display field: for an existing MIC185 calibration it shows reconstructed

`k,b`, for a missing calibration object it shows the stored name/alias, and for

multi-selection with different assignments it shows `<разные аппаратные ГХ>`

with the checkbox grayed so OK does not overwrite individual assignments.



**Verification:** A running `RecorderLnx.exe` PID 21752 first held the output

exe; after stopping it,

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`

completed with exit code 0. The existing post-build `copy_sdb_res.bat` still

prints the `#!/bin/sh` message but does not fail `lazbuild`.

`D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`

passed.



## Codex continuation 2026-07-10: MIC185 hardware-GX cleared on tag OK



**Prompt:** User still reproduced the issue in one dialog session: open MIC185

channel, read hardware GX, press OK, reopen the same channel, and the hardware

GX line is empty again.



**Root cause:** `TTagSettingsDialog.StoreToTags` called

`RecorderTagClearMic140Settings` for every tag that was not MIC140. That helper

clears the generic tag fields `HardwareCalibrationEnabled` and

`HardwareCalibrationName`, so MIC185 read-GX was erased by the OK path itself.



**Fix:** The cleanup now excludes MIC185 hardware sources. MIC185

`dataSources[].mic185.tagLinks[]` also saves/loads `hardwareCalibrationEnabled`

and `hardwareCalibrationName`, so source-specific link restoration keeps the

same GX assignment.



**Verification:** Stopped running `RecorderLnx.exe` PID 11208, rebuilt

`RecorderLnx.lpi` with exit code 0, and

`RecorderDataSourcesTest.exe` passed.



## Codex continuation 2026-07-10: MIC185 bulk read-GX message shortened



**Prompt:** User reported that reading hardware GX for many selected MIC185

channels opens an oversized message listing every channel. The dialog should

show the first channel, then `...`, and OK.



**Fix:** `TTagSettingsDialog.DownloadHardwareCalibrationFromDeviceClick` now

builds a short `lMessageText`: first successful per-channel line, plus `...`

when more than one channel was read. Full per-channel assignment still happens;

only the message box text is shortened.



**Verification:** Stopped running `RecorderLnx.exe` PID 8144, rebuilt

`RecorderLnx.lpi` with exit code 0, and

`RecorderDataSourcesTest.exe` passed.



## Codex continuation 2026-07-10: MIC185 hardware-GX disk cache



**Prompt:** User asked to persist MIC185 hardware GX like MIC140 under

`C:\Mera Files\Calibr\hardware`, e.g. `MIC-185\sn...\range1...`, so the same

coefficients do not need to be read from the device again on every range change

or next project load. User also asked to compare with original Recorder linear

GX storage.



**Findings:** Current RecorderLnx MIC140 uses text CSV files under

`Calibr\hardware\MIC140\snXXXX\<range>\NN.csv`. The live

`C:\Mera Files\Calibr\hardware\MIC140\sn0164\06_100mV\01.csv` file is plain

`x,y` CSV. Original Mebius `CBaseVirtualChannel` also forms

`GetCalibrDir + GetCalibrSubDir + "%02d.csv"` and calls evaluator

`ExportToText/ImportFromText`. Original MIC185 itself is the exception: it

loads `k,b` through the device evaluator path (`IOCTL_CMD_GET_CALIBR_KOEF`) and

does not reliably use that standard disk branch.



**Fix:** `Device/mic185/uRecorderMic185Calibration.pas` now:

- names MIC185 hardware GX as `MIC185 snXXXX rangeN chCC`;

- stores and loads CSV at

  `C:\Mera Files\Calibr\hardware\MIC-185\snXXXX\rangeN\CC.csv`;

- stores the two-point equivalent of `y = k * (code - b)`;

- checks the disk cache before calling the device, and saves CSV after a

  successful device read.



`UI/uTagSettingsDialog.pas` now tries to restore a MIC185 hardware GX object

from disk when the tag has a saved GX name but the registry object is not loaded

yet. `Device/mic185/uRecorderMic185DataSource.pas` also lazily restores the

saved GX from disk during publication when a project was loaded with only the

persisted GX name. Added `Docs/devices/mic185/hardware_calibration_cache.md`

and linked it from the MIC185 README.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`

passed.



## Codex continuation 2026-07-13: MC-201 protocol debug stand



**Prompt:** Find the MC-201 / MC-031 / MC-032 example under

`windev-v3.9\examples\mebius.daq` and create an independent RecorderLnx-compatible

test example for later protocol porting. Target controller:

`192.169.12.87`, expected four MC-201 modules.



**Findings:** `medaq_mc_test.cpp` creates `MICCRATE`, connects through

`BUSID_ETHERNET81_TCP`, gets `BUSID_MC`, then calls `SearchDevices`. The older

Recorder MC-031 Ethernet path uses legacy MDP/TCP command packets; module

auto-search reads slot flash offset `0` for type and offset `1` for MC-201

version discriminator.



**Fix:** Added standalone console project

`Tests\RecorderTests\Mc201ProtocolDebug`. It does not use RecorderLnx device

units and does not write/program hardware. It reads `CMD_REPLY`, scans module

flash offsets `0/1/61/62`, prints used slots and MC-201 module count, and writes

a `.log` beside the exe.



**GUI follow-up:** CLI and GUI are now merged into the single

`Mc201ProtocolDebug.lpi` project. GUI is the default mode; CLI starts with

`Mc201ProtocolDebug.exe --cli ...`. The separate `Mc032ProtocolDebugGui.lpi/.lpr`

project and stale `Mc032ProtocolDebugGui.*` build artifacts were removed. All

test units are listed in the `.lpi` for Lazarus Project Inspector. The GUI uses

independent `TMc032Device` states `Disconnected/Connected/Play`,

controller actions `Search/TestConnection/SearchModules/Connect/Disconnect/Reset/Config/Play/Stop`,

a read thread, and a callback that fills a raw-word oscilloscope on the form.

`Config` currently stores `TMc032Config`, updates timeout and sends

`CMD_RESETSCANMAIN`; full MC-201 scan descriptor programming still needs the

original `CMD_ADDCHANNELMODULE` / `CMD_SCAN_SET_CHANS` path.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`

completed with exit code 0. `Mc201ProtocolDebug.exe --help` completed with exit

code 0 and created `lib\Mc201ProtocolDebug.log`. Live TCP run against

`192.169.12.87:4000` from this environment timed out before protocol exchange.

The same executable starts GUI by default; `--cli` and `--help` remain CLI paths.



**MC documentation follow-up:** User provided original Recorder screenshots with

the actual detected stand: four-slot controller `[0841] MIC-200m - Ethernet`,

MC-201 modules slot 1 `01462`, slot 2 `01465`, slot 3 `01464`, slot 4 `01463`,

all version `5.0`. Added `Docs/devices/mc/README.md` and

`Docs/devices/mc/mc201.md` documenting the stand, MC-201 channel settings,

range list, input/filter/ICP fields, and frequency grid

`300..19200 Hz`.



## Codex continuation 2026-07-13: MIC185 selected-row tag units



**Prompt:** User reported that in MIC185 hardware settings, after using

`Select all`, changing units or other channel properties in the channel

properties dialog must apply to all selected tags.



**Fix:** `Device/mic185/UI/uRecorderMic185SettingsDialog.pas` now propagates

the edited tag unit from the master channel dialog to every selected MIC185

measurement tag. For each selected row it also recalculates `RangeMin/RangeMax`

in that unit while keeping the existing source-level hardware settings path.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code

0. `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`

passed.



## Codex continuation 2026-07-14: MC-201 Config GUI freeze



**Prompt:** User reported that the MC-201 protocol-debug GUI hangs after

`Connect`, `Modules`, `Config`.



**Fix:** `TMc032DebugForm.ButtonConfig` no longer runs

`TMc032Device.Config` in the LCL main thread. Added a background

`TMc032ConfigThread`, a form-level busy state, disabled action buttons while

Config is running, and guarded normal window close until the worker finishes.

The change does not alter MC-201/MC-032 packet programming; it only moves the

long BIOS/config sequence off the UI thread.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`

completed with exit code 0.



**Follow-up:** User reproduced a hang after `Config`. The deeper cause was an

unbounded wait in `TMc201LegacyMdpClient.CallCommand`: while the controller was

returning stream packets, the code skipped non-command ports forever and never

hit a command-reply deadline. Added an overall reply timeout and a GUI busy

heartbeat. Rebuilt `Mc201ProtocolDebug.lpi` with exit code 0. Live

`--play-diagnostic-ms=3000` against `192.169.12.87:4000` passed:

`Config OK`, `STARTSCANMAIN OK`, `STOPSCANMAIN OK`, `PLAY messages=35`,

`RESULT Mc201PlayDiagnostic passed`.



**GUI-specific follow-up:** User reproduced `Connect -> Modules -> Config`

hanging in the GUI while the status heartbeat still updated. Changed GUI Config

again: removed the worker thread because it used a socket created on the LCL

thread. `ButtonConfig` now follows the same single-thread device path as the

passing CLI run and keeps the window responsive through device progress

callbacks plus `Application.ProcessMessages`. The log now records

`Config step: ...` before each controller/module operation. Rebuilt

`Mc201ProtocolDebug.lpi` with exit code 0.



## Codex continuation 2026-07-14: MC-201 Play one packet / STOP timeout



**Prompt:** After `Play`, some MC-201 data arrives and then stops; repeated

`Play` or `Reset` often leads to `MDP TCP write failed`.



**Update:** Reproduced the current live behavior through CLI before the

controller port stopped accepting TCP: one 26-word stream packet arrives

(`header.chan=0x78F1`), then read timeouts and `STOPSCANMAIN` timeout. Repeated

CLI runs no longer reproduced `MDP TCP write failed`, because Stop now waits

for the Stop command and force-disconnects on timeout instead of leaving a bad

socket in `Connected`.



**Fix:** Corrected CLI and GUI demultiplexing to compare full MC-201

`final_flag`/`header.chan` including `0x4000` (`IS_DM`), matching original

`ScanMC201::Decommutation`. Added first-packet word dump to CLI diagnostics.

Made `--play-diagnostic-ms` fail unless `STOPSCANMAIN` succeeds and packet

count reaches the expected `duration / 200 ms`.



**Verification:** Rebuilt `Mc201ProtocolDebug.lpi` with exit code 0. Final live

check could not connect: `Connection to 192.169.12.87:4000 timed out`, likely

because the previous bad scan/another client still owns the controller port.



## Codex continuation 2026-07-14: MC-201 GUI Connect exception



**Prompt:** GUI falls/stops on `Connect` at `TInetSocket.Create`.



**Fix:** Added `TMc032Device.TryConnect(out AErrorMessage): Boolean` and routed

the GUI `Connect` button plus `Play` auto-connect through it. Expected TCP

connection failures now stay in device state `Disconnected` and are written to

the GUI log instead of being re-raised by `TMc032Device.Connect`.



**Verification:** Closed the stale Lazarus debug session, rebuilt

`Mc201ProtocolDebug.lpi` with exit code 0, launched the GUI, clicked `Connect`

through UI Automation/mouse coordinates, and confirmed the app logs

`Connect: Connection to 192.169.12.87:4000 timed out.` instead of falling out of

the button handler.



## Codex continuation 2026-07-14: MC-201 GUI connect-on-create test



**Prompt:** User asked to add a unit/regression test that invokes the same

connect function from form creation instead of pressing the GUI button.



**Fix:** In `Tests\RecorderTests\Mc201ProtocolDebug`, extracted GUI connect

logic into `TMc032DebugForm.RunConnectAction` and added

`--gui-connect-on-create-test`. The mode creates the form, runs connect from the

creation hook, prints `RESULT Mc201GuiConnectOnCreate ...`, and exits without

`Application.Run`.



**Verification:** `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`

completed with exit code 0. The new test returned exit code 0 with

`RESULT Mc201GuiConnectOnCreate passed: Connect: Connection to 192.169.12.87:4000 timed out.`



## Codex continuation 2026-07-14: MC-201 non-throwing GUI TCP connect



**Prompt:** User reported that even GUI `Search` stops at

`TInetSocket.Create`; this did not happen earlier.



**Fix:** Root cause is that `Search -> TestConnection` used the same TCP open as

`Connect`, and `TInetSocket.Create` raises on timeout/refused connection.

Replaced the GUI-facing connection path with `TMc201LegacyMdpClient.TryConnect`,

which opens the socket with a nonblocking connect/select timeout and returns an

error string instead of throwing. `TMc032Device.TryConnect` and

`TestConnection` now use this path; the old throwing `Connect` remains for

CLI/internal callers.



**Verification:** Rebuilt `Mc201ProtocolDebug.lpi` with exit code 0. The

connect-on-create regression still passes and returns

`Connect: Connection to 192.169.12.87:4000 timed out.`



## Codex continuation 2026-07-14: MC-201 Config speed and IDMA chunking



**Prompt:** User reported that `Play` now receives apparently correct data, but

`Config` is much slower than original Recorder; maybe module programming should

use fewer packets.



**Fix:** Compared with original `mdpEthernet81`, `Mc031ethernetifc` and

`Mc201.cpp`. The raw Ethernet packet can carry 1024 words, but original command

arguments are limited to `MAX_TX = 32` words. For `CMD_IDMAPUTARRAY` this leaves

27 data words, and PM writes must be even, so the safe chunk is `26` words.

Encoded this as `CMc201CommandMaxArgWords = 32` and

`CMc201IdmaArrayMaxDataWords = 26`. Added per-client loaded-BIOS slot cache so

repeated GUI `Config` in the same connection skips the heavy `.bio` upload.



**Verification:** `lazbuild -B Mc201ProtocolDebug.lpi` completed with exit code

0. Live command `Mc201ProtocolDebug.exe --cli --play-diagnostic-ms=1

--host=192.169.12.87 --port=4000 --timeout-ms=1200 --slots=4` completed with

`Config OK`, `STARTSCANMAIN OK`, data packets, `STOPSCANMAIN OK`, and

`RESULT Mc201PlayDiagnostic passed`.



## Codex continuation 2026-07-14: MC-201 documentation pass



**Prompt:** User asked to document what was developed in project documents and

add comments explaining what each part does and why.



**Fix:** Added focused Pascal comments to the MC-201 debug project around the

hard protocol decisions: stand defaults, 32-word MDP command argument limit,

26-word IDMA chunks, non-throwing GUI TCP connect, per-client BIOS cache,

original-like scan programming order, Config retry, and GUI connect regression

mode. Expanded `Docs/devices/mc/mc201.md` and the test `README.md` with the

same decisions and command examples for future transfer into RecorderLnx.



**Verification:** First rebuild failed only because a running

`Mc201ProtocolDebug.exe` held the target executable. After stopping that

process, `C:\lazarus\lazbuild.exe -B

D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi`

completed with exit code 0.

# Codex continuation 2026-07-15: MIC-200 production device driver



**Prompt:** Add MIC-200 support (MC-201 modules and MC-032 controller) under

`Device/mic200`, based on `TRecorderDevice`, without regressing existing

devices; evaluate a shared TCP layer.



**Implementation:** Moved the verified low-level protocol units from the

independent `Mc201ProtocolDebug` stand into `Device/mic200` and added

`TRecorderMic200Device`. It implements Connect/ProgramDevice/Start/ReadBlock/

Stop/Disconnect, discovers MC-201 modules, maps each slot to four Recorder

channels, matches stream messages by the complete MC-201 final flag, converts

signed 16-bit samples, and assembles one rectangular acquisition block only

after every programmed channel has arrived. Added the MC-201 BIOS as the

cross-platform `MC201A_BIO` resource in the main executable. Existing MIC-140

and MIC-185 units were not changed. A shared raw socket class was deliberately

not introduced: the safe common abstraction is `TRecorderDevice`, while the

MDP and MIC-185 packet/session formats differ.



**Verification:** `lazbuild -B RecorderLnx.lpi` completed with exit code 0 and

linked the new resource. `lazbuild -B Mc201ProtocolDebug.lpi` completed with

exit code 0; `--cli --check-resources` reported 22040 bytes and passed.

`RecorderDataSourcesTest.lpi` could not build because its existing search path

does not include `Device/MIC140` and therefore cannot find

`uRecorderMic140DeviceConfig`; this failure is outside the MIC-200 changes.

# 2026-07-15 — MC-032 в аппаратной конфигурации



- В список добавляемых источников добавлен контроллер `MC-032`; название

  `MIC-200` больше не используется как пользовательский тип устройства.

- Новый диалог `Device/mic200/UI/uRecorderMc032SettingsDialog.pas` позволяет

  задать адрес, выполнить автопоиск по `192.169.13.*`, проверить командой

  `TEST_LOAD` и прочитать flash-идентификацию модулей по слотам.

- В конфигурацию допускается только узел, успешно ответивший на протокольный

  тест. Поддерживаемые модули сейчас определяются как MC-201/MC-201A.

- Для дерева аппаратуры зарегистрирован MC-032 link probe через тот же TEST.

- Полная сборка `RecorderLnx.lpi`: OK.

- После поиска и сохранения MC-032 найденные MC-201 отображаются дочерними

  узлами контроллера в дереве: слот, тип, версия и серийный номер. Узел MC-032

  автоматически раскрывается; список восстанавливается из конфигурации проекта.



# 2026-07-15 — MC bus и диалог MC-201



- Папка `Device/mic200` переименована в `Device/MCbus`: MIC-200 — конструктив,

  а программная граница здесь — шина MC с MC-032 и MC-201.

- Адаптер переименован в `TRecorderMcbusDevice`; `TMc032Device` остался

  низкоуровневым TCP/MDP-драйвером контроллера.

- Двойной клик на дочернем узле слота MC-201 открывает

  `Device/MCbus/UI/uRecorderMc201SlotSettingsDialog.lfm`: 4 канала, HPF/LPF/ICP,

  режим входа, коммутация, тип и ревизия субмодуля.

- Настройки хранятся по номеру слота и сохраняются при повторном поиске модулей.

- Полная сборка `lazbuild -B RecorderLnx.lpi`: OK, exit code 0.



# 2026-07-15 — double click MC-201 routing fix



Исправлено открытие диалога MC-032 вместо MC-201: парсер номера слота

был небезопасен для UTF-8 из-за фиксированной байтовой позиции. Теперь дочерний

узел с маркером MC-201 открывает LFM-форму аппаратных свойств MC-201. Сборка OK.



# 2026-07-15 — MC-032 persistence fix



MC-032 исчезал при `OK`, потому что `TRecorderSettingsSourceProbe.SyncToRegistry`

удалял все аппаратные источники, отсутствующие в его списках Mera/MIC-140/MIC-185.

Синхронизация ограничена типами, которыми probe владеет. `SpecificConfigText` добавлен

в JSON `dataSources`, чтобы слоты MC-201 и их настройки переживали повторную загрузку проекта.

Полная сборка RecorderLnx: OK.



# 2026-07-15 — MC-201 channels and source-indexed addresses



Для каждого найденного MC-201 source probe создаёт 4 доступных канала. Адрес

включает индекс источника в аппаратном дереве. Для Mera-источника старый первый индекс

заменяется текущим, для MC-032 индекс добавляется перед `слот-канал`. Ошибка дублирования

выбранных Mera-каналов в доступных и их удаления при `OK` исправлена: группа Mera всегда

использует descriptor `SourceId`, а не `FileName` сигнала. Compile-only `lazbuild -B --opt=-Cn`: OK;

полная линковка ожидает закрытия RecorderLnx.exe.



После закрытия приложения полная сборка прошла с exit code 0. Имя канала MC-201 теперь

равно его цифровому tree-indexed адресу; служебный адрес `virtual` сокращён до `v`, при этом

тип источника `virtual` сохранён.

# 2026-07-15 — MC-032/MC-201 runtime in Preview



По `LogWindows.log` установлено, что режим просмотра не создавал источник MCbus: запускались только MERA playback и диагностика. Добавлен `TRecorderMcbusDataSource`, который в рабочем потоке выполняет connect/program/start/read/stop через существующий `TRecorderMcbusDevice`, сопоставляет нативные `slot-channel` с tree-indexed адресами выбранных тегов и публикует блоки в реестр. `TMainForm` теперь создаёт этот источник для выбранных тегов MC-032. В лог добавлены lifecycle-метки `[MCBUS]`, сообщения о блоках и разреженная диагностика таймаутов. Подробности: `errors/2026-07-15-mcbus-preview-no-data.md`.

# 2026-07-15 — MCbus Preview smoke и безопасный Stop



Устранено исключение `MC-032 stop: MDP command timeout`: неподтверждённый STOPSCANMAIN теперь приводит к безопасному закрытию неоднозначной TCP-сессии и состоянию disconnected, а не к исключению в UI. Добавлен production smoke-тест `Tests/RecorderTests/McbusPreviewSmoke`. На реальном `192.169.12.87:4000` при периоде 200 мс он получил 15/15 блоков за 3 секунды (5,00 блока/с), 16 каналов × 68 отсчётов, и остановился без исключения. Подробности: `errors/2026-07-15-mcbus-stop-command-timeout.md`.

# 2026-07-15 — MC-201 полный поток 57,6 кГц



Исправлены ложные значения и потеря объёма данных MC-201. MDP-пакеты теперь разделяются на вложенные BIOS-сообщения, 10 слов заголовка исключаются из сигнала, payload накапливается по slot/final-flag до 11 520 отсчётов на канал за 200 мс. Корневая ошибка темпа: ADSP FIFO 256 ошибочно делился на 16 каналов; оригинальный `SetADSPFifoSize(256)` задаёт 256 отсчётов каждому каналу. Реальный smoke-тест: 16 каналов, 25 блоков × 11 520 = 288 000 отсчётов на канал за 5 секунд, ровно 57 600 отсчётов/с.

# 2026-07-15: единый список каналов осциллограммы



- Убран отдельный UI-сценарий «Основной канал»; теперь канал выбирается и

  добавляется одной кнопкой.

- Первый канал попадает в синюю линию, второй — в зелёную, третий — в красную.

- Внутренняя схема `TagName + Lines[]` сохранена для совместимости файлов проекта.

- Полная сборка `RecorderLnx.lpi`: exit code 0.



# 2026-07-15: консолидация документации MCbus



- Добавлен `Docs/devices/mc/recorderlnx-integration.md` — единая карта ролей

  MC-032/MC-201, конфигурации, дерева, адресов, runtime Preview, MDP/BIOS payload,

  объёма 57,6 кГц, безопасного Stop, осциллограммы, логов и тестов.

- Исправлены устаревшие шапки production-юнитов, ошибочно называвшие MCbus

  автономным тестовым кодом. В ключевых Pascal-модулях добавлены русские

  комментарии с инвариантами и ссылкой на сводный документ.

- В `uMainForm.pas` отмечена обязательная регистрация MCbus в фабрике runtime-

  источников; в `uRecorderSettingsDialog.pas` — сохранение через общий список

  источников и маршрутизация двойного клика MC-201.



# 2026-07-15: быстрый Preview и предвыделение MCbus



- Connect/ProgramDevice MCbus перенесены из перехода Preview в загрузку или

  переконфигурирование проекта; повторный Prepare для `rdsProgrammed` — no-op.

- Успешный Stop больше не делает Disconnect. Крупные pending/output/time

  буферы повторно используются, Start/Stop сбрасывают только счётчики.

- Удалены `SetLength` из MCbus ReadBlock и PublishBlock; переполнение pending

  теперь является явной ошибкой конфигурации.

- Полная сборка RecorderLnx прошла. Стенд MC-032 при контрольном smoke был

  недоступен (TCP timeout), это записано в error journal.

## 2026-07-15 — lifecycle Init и программирование MCbus



- Подтверждено: `rstInit` был только начальным `LastTransition`, события Init в EventBus не существовало.

- Добавлено `rceInitialized`, публикуемое после загрузки проекта/форм, создания источников, привязки тегов и подготовки оборудования.

- В `TRecorderDataSourceManager` добавлен универсальный `PrepareHardwareAll`.

- Исправлен порядок при старте, загрузке конфигурации и переконфигурировании: `EnsureDemoDataSources` → `PrepareRuntimeForConfiguration`.

- MC-032/MC-201 теперь подключается и программируется в конфигурационной фазе; `StartAll` оставляет страховочный повтор.

- Полная сборка `RecorderLnx.lpi` успешна.

# 2026-07-16 — Algs и спектральные оценки



- `uRecorderSpectrumEngine` и `uRecorderFrequencyBands` перенесены из `Core` в `Algs`; имена юнитов сохранены, пути обновлены в основном и тестовом `.lpi`.

- В `TRecorderSpectrumSettings` добавлены флаги расчёта СКЗ полосы, максимума, частоты максимума и записи результатов в теги.

- При выборе дочерней привязки спектра настройки становятся индивидуальными (`UseOwnSettings=True`); родительский узел по-прежнему задаёт наследуемые настройки.

- Runtime создаёт выходные теги только в `PrepareConfiguration`, затем публикует в них оценки на каждом готовом кадре.

- Соглашение имён: `<OutputPrefix>_<BandName>_rms|max|fmax`.

- Подробности: `Docs/spectrum-estimates.md`.

- Проверено: `TestSpectrumMath2.exe` — PASS; `lazbuild -B RecorderLnx.lpi` — exit 0.



# 2026-07-16 — фильтры выбранных каналов



- Над таблицей выбранных каналов добавлены флаги `Скрыть неактивные` и `Только виртуальные`.

- Флаги комбинируются между собой и с текстовым фильтром; меняется только отображение и row-map, реестр тегов не изменяется.

- Кнопка `X` очищает текстовый фильтр; изменение любого фильтра немедленно перестраивает таблицу.

- Полная сборка `RecorderLnx.lpi` завершилась с exit code 0.

# Исправления UI тегов и спектральных оценок (2026-07-16)



- В `TRecorderTag` добавлен сохраняемый признак `IsVirtual`. Он передаётся в конструктор/`CreateTag`; Mera, диагностика, тестовый программный сигнал и спектральные производные создают теги с `IsVirtual=True`, аппаратные — с `False`.

- UI и фильтр «Только виртуальные» читают только `TRecorderTag.IsVirtual`, без классификации по `SourceId`. JSON хранит `isVirtual`; для старых проектов без поля выполняется однократная совместимая миграция по известным legacy-источникам.

- CPU (`CpuUsage`) и память (`MemTag`) от `debug.diagnostics` включены в UI-классификацию виртуальных тегов: для них рисуется иконка 20 и они попадают под фильтр «Только виртуальные».

- В первой колонке выбранных каналов виртуальные теги теперь рисуются тем же механизмом, что и неактивные теги, но с индексом ImageList 20.

- Виртуальная иконка имеет приоритет над иконкой неактивного источника.

- Галочки расчёта спектральных оценок подключены к обновлению сериализованной конфигурации, поэтому «Применить» больше не восстанавливает старые значения.

- Подпись «Записывать в теги» заменена на «Создать теги».

- Исходники полностью компилируются; финальная линковка временно заблокирована удерживаемым процессом RecorderLnx.exe (Win32 error 5).

- 2026-07-16: исправлено создание тегов спектральных оценок непосредственно по внутренней и общей кнопкам «Применить». Диалог теперь сохраняет текущий узел, вызывает `SpectrumManager.PrepareConfiguration` и обновляет таблицы каналов. При полосах B01/B02 и трёх оценках создаётся по шесть виртуальных тегов на привязанный канал. Полная сборка RecorderLnx прошла с exit code 0.

- 2026-07-16: материализация тегов спектральных оценок сделана идемпотентной. Повторный Apply переиспользует тег по имени либо по паре `SourceId/Address`; отредактированное имя больше не приводит к созданию нового тега. Полная сборка RecorderLnx прошла с exit code 0.

- 2026-07-16: исправлено отображение созданных спектральных тегов после «Применить» → «Закрыть». Главный список теперь перестраивается после любого закрытия настроек; `RecorderTagSourceIsVisible` учитывает явный `IsVirtual` и больше не скрывает `spectrum:*` как неактивное оборудование. Полная сборка RecorderLnx прошла с exit code 0.

- 2026-07-16: исправлен статус MC-032 в дереве оборудования. Состояние

  `rdsStarted` снимает устаревшую offline-метку; TEST не внедряется в активную

  потоковую MDP-сессию. Сброс устройства теперь выполняет проверку и дает

  зеленый статус только при успехе, а hint показывает сохраненную ошибку без

  сетевых операций при наведении. Полная сборка RecorderLnx прошла с exit code 0.

- 2026-07-16: повторная трассировка MC-032 обнаружила рассинхронизацию lifecycle:

  штатный Stop сохранял запрограммированный сокет, но удалял live-регистрацию, а

  Restart ее не возвращал. Теперь успешный Start всегда регистрирует устройство,

  штатный Stop сохраняет регистрацию. Три последовательных аппаратных CLI-теста

  прошли; второй клиент при занятом RecorderLnx сокете закономерно получил timeout.

- 2026-07-16: исправлена привязка цифрового индикатора. Диалог настройки раньше

  менял только `TagName`, оставляя `TagId` от MemTag; синхронизация возвращала

  старый тег. Теперь имя и ID назначаются атомарно из выбранного `TRecorderTag`,

  для неразрешимого имени ID сбрасывается. Полная сборка прошла с exit code 0.

- 2026-07-16: исправлены границы полос спектральных оценок. Вместо `Round` используются `Ceil(F1/df)` и `Floor(F2/df)`, поэтому полоса от 10 Гц больше не включает бин 7,03125 Гц. Частота дискретизации и `df` теперь берутся отдельно для каждой привязки из `PollFrequencyHz` входного тега; один спектральный узел поддерживает каналы с разными Fs. `TestSpectrumMath2.exe` — PASS, полная сборка RecorderLnx — exit code 0.

- 2026-07-16: цифровой индикатор в автоматическом режиме переносит значение на вторую строку, если имя шире компонента. Добавлена рабочая опция «Не отображать имя». `ShowNameMode` теперь участвует в отрисовке и сохраняется/загружается из `.gui.ini`; применяются формат и шрифт компонента. Полная сборка RecorderLnx — exit code 0.

- 2026-07-16: суффикс выходного тега частоты максимума спектра изменён с `fmax` на `f1`. Старый автоматически созданный тег мигрирует по имени/SourceId+Address с сохранением TagId, поэтому ссылки компонентов не теряются и дубликат не создаётся. В `Docs/algorithm-manager-requirements.md` записано ТЗ единого менеджера алгоритмов по образцу `plgControlCyclogram`. Подтверждено, что глобальный кэш FFT-планов, Twiddle/BitReverse, Pascal-inline и проверяемый AVX vector2 уже применены в production `uRecorderSpectrumEngine` и должны быть сохранены при рефакторинге.

- Проверка этой правки: `TestSpectrumMath2.exe` — PASS; полная сборка `RecorderLnx.lpi` — exit code 0. Правило безопасного переименования производных тегов зафиксировано как `RLNX_DERIVED_TAG_RENAME_2026_07_16`.

- 2026-07-16: реализован `Algs/uRecorderAlgorithmManager.pas`. Менеджер принадлежит `TRecorder`, регистрирует типы алгоритмов и frame по строковому имени, сериализует общие и tag-specific свойства, сохраняет неизвестные типы, управляет `Ready/DoStart/DoStop/DoStopRecord` единым `case` и явно принимает обновления из `TRecorderTagRegistry`. Spectrum подключён адаптером без скрытой подписки runtime на EventBus; EventBus оставлен для выходного кадра UI. Правило явных архитектурных вызовов: `RLNX_EXPLICIT_ARCHITECTURE_CALLS_2026_07_16`.

- Проверка менеджера: интеграционный спектральный тест переведён на путь `TagRegistry -> AlgorithmManager -> SpectrumAlgorithm -> SpectrumRuntime`; `TestSpectrumMath2.exe` — PASS, полная сборка `RecorderLnx.lpi` — exit code 0.

- По уточнению пользователя `uRecorderSpectrumRuntime.pas` перенесён из `Core` в `Algs`; `uRecorderAlgorithmManager.pas` явно добавлен в `RecorderLnx.lpi`, поэтому менеджер и весь спектральный алгоритмический слой отображаются одной группой `Algs` в дереве Lazarus.

- 2026-07-16: выполнен полный аудит EventBus (`Docs/eventbus-audit.md`). Удалена штатная подписка `TRecorderAlarmEngine` на `rceDataUpdated`; теперь `TRecorderTagRegistry` явно вызывает `TRecorder.HandleTagAlarmValue`, а модель Recorder — `AlarmEngine.ProcessTagValue`. Из spectrum runtime удалены мёртвые EventBus handlers. Оставшиеся подписчики: динамический spectrum UI, менеджер расширений и пассивная очередь снимков событий.

- Прямой маршрут тревог покрывает как `PublishValue`, так и последнее значение `PublishBlock/NotifyBlockTail`; правило миграции EventBus дополнено обязательной проверкой scalar/block/block-tail.

- 2026-07-16: автоматическое распределение тегов по осциллограммам базовой страницы фильтруется через `RecorderTagSourceIsVisible`. Неактивные аппаратные источники больше не занимают графики старыми буферами; виртуальные и активные теги сохраняют порядок, а восстановленный источник возвращается без изменения конфигурации.

- Выделенный в основном списке каналов активный тег становится первым на базовой странице; остальные осциллограммы заполняются следующими активными тегами с циклическим смещением. Для пустого или неактивного выделения старт остаётся с первого активного тега.



## 2026-07-16 — настройка осциллограммы без дублирующего выбора тега



- В `UI/uRecorderOscillogramSettingsDialog.pas` удалён нижний combo `Тег`; канал выбирается только верхним `Канал`.

- Выбор добавленной линии показывает её канал в едином combo, а цвет и видимость по-прежнему относятся к выбранной строке.

- Кнопка `Добавить` добавляет выбранный канал без изменения уже выбранной линии; `Удалить` сохраняет прежнее повышение следующей линии в основную.

- После появления первой линии список выбора ограничивается тегами того же `SourceId`.

- Полная сборка `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` прошла с кодом 0.



## 2026-07-16 — обратная рамка осциллограмм



- Для `TRecorderOglOscillogram` и `TRecorderOglOscillogramSurface` включён `AutoScaleOnZoomReset`.

- Обратная рамка теперь вызывает общий `FitZoomY` по точкам текущего отображаемого кадра, а не восстанавливает сохранённый диапазон тега.

- Итоговая шкала Y получает запас 10% снизу и 10% сверху — суммарно +20% к размаху сигнала.

- Полная сборка `RecorderLnx.lpi` после освобождения запущенного exe прошла с кодом 0.



## 2026-07-16 — выбор канала справа и оценки базовой осциллограммы



- Исправлен приоритет в `TMainForm.CurrentTagListSelectionName`: сначала читается текущая выделенная строка `lbTags`, затем используется сохранённый `TagRegistry.SelectedTagName`.

- Старое значение реестра больше не блокирует выбор другого канала; обработчик клика обновляет реестр и сразу перестраивает порядок базовых осциллограмм.

- Базовая подпись и информационная панель редактируемого компонента используют общий `FormatEnabledEstimateCaption`, который перечисляет все включённые оценки (`M`, `rms`, `sko`, `A`, `p2p`, `min`, `max`, `p2p/sko`).

- Полная сборка `RecorderLnx.lpi` после закрытия удерживавшего exe прошла с кодом 0.



## 2026-07-16 — канал сразу изменяет выбранную линию



- `PrimaryTagChange` атомарно обновляет `TagId/TagName` выбранной основной или дополнительной линии и сразу перестраивает список.

- Программное заполнение/синхронизация combo защищены `fUpdating`, поэтому поиск и выбор строки не вызывают ложную перепривязку.

- Повтор одного канала на двух линиях отклоняется с восстановлением прежнего выбора.

- `Добавить` при существующих линиях выбирает первый свободный канал того же `SourceId`, создаёт линию и выделяет её для немедленного редактирования.

- 2026-07-16: для каналов MC-201 в общем диалоге включены сервисные кнопки

  балансировки, аппаратной настройки слота и чтения аппаратной калибровки.

  В `IRecorderDevice`/`TRecorderDevice` добавлен полиморфный контракт

  `SupportsDeviceAction/ExecuteDeviceAction`; MCbus реализует программную

  балансировку текущего сеанса. Настройка открывает диалог конкретного слота

  MC-201. Чтение заводской flash-калибровки MC-201 пока явно сообщает, что

  операция не портирована. Полная сборка `RecorderLnx.lpi` прошла с кодом 0.

- 2026-07-16: после получения точного исходника из `uCommonTypes` общая палитра

  `uOglChartColors` заменена полным `ColorArray[0..17]` из

  `plgControlCyclogram`. Порядок начинается с blue, green, red, orange, purple,

  acid; чёрного цвета в циклической палитре нет. Значения `point3` RGB переведены

  в BGR-представление `TColor` и применяются ко всем общим графикам.

- 2026-07-16: список диапазонов MC-201 приведён к таблице `ranges_MC201` из

  оригинального `Mc201.cpp`: 8,5; 2; 1; 0,2; 0,1; 0,02 В. Порядок сохранён как

  часть аппаратной семантики индексов. Второй цвет общей палитры заменён на

  тёмный травяной RGB(34,139,34), TColor `$00228B22`; индексные назначения

  спектров и осциллограмм используют `uOglChartColors`. Полная сборка

  `RecorderLnx.lpi` завершилась с кодом 0.

- 2026-07-16: цвет общей палитры с индексом 5 («Кислотный») заменён по

  пользовательскому образцу на бирюзовый RGB(0,128,128), представление

  `TColor` `$00808000`; имя цвета изменено на «Бирюзовый».



- 2026-07-16: строка легенды спектра теперь назначает `SelectedObject` графика.

  Shift привязывает курсор к ближайшему по Y локальному экстремуму выбранной

  линии, Ctrl+Shift — к минимуму; одномлинейная подпись берёт Y этой линии и

  преобразует координату через её собственную ось.

- 2026-07-16: диапазоны MC-201 доведены от диалога до аппаратного регистра.

  `SpecificConfigText` передаётся runtime-источнику и драйверу до программирования;

  регистр строится по оригинальным `SetRange`/`SetControlRegV5` для ревизии 2180

  и `SetControlReg` для старых модулей. Значение по умолчанию — 2 В. Полная

  сборка `RecorderLnx.lpi` завершилась с кодом 0.



- 2026-07-16: исправлено программирование ICP/IEPE каналов MC-201. Галочки

  `b8..b11` ранее только сохранялись и не читались runtime-драйвером. По

  оригинальному `Mc201.cpp` добавлена отдельная последовательность MM202:

  свойства `ICP_ON/ICP_HPF/SINGLE`, получение HANDLE субмодуля и применение его

  управляющего слова. Основной регистр MC-201 для ICP не используется. Сборка

  прошла с кодом 0; электрическая проверка питания IEPE ещё требуется.



- 2026-07-16: диалог MC-201 синхронизирован с `Cmc201pp::OnIcpCheck` оригинального

  Recorder. Включение ICP принудительно ставит недифференциальный вход и блокирует

  список режима; снятие ICP возвращает дифференциальный вход и разблокирует список.

  Состояние восстанавливается при повторном открытии, а без MM202 элементы ICP и

  режима входа недоступны. Полная сборка `RecorderLnx.lpi` прошла с кодом 0.



- 2026-07-16: частота в диалоге тега больше не задаётся таблицей конкретного

  прибора внутри UI. Добавлен общий `uRecorderFrequencyGrids`; MC-201 регистрирует

  по префиксу `MC-032: ` 16 значений исходной `ModuleMC201::IndexToFreq`, а

  `uTagSettingsDialog` подхватывает их по `SourceId`. Полная сборка прошла с кодом 0.



- 2026-07-16: исправлена база сетки MC-201. Константа 16,384 МГц из конструктора

  модуля не является фактическим источником: при `SelfClk=NOSELF_CLK` оригинальный

  `GetFreqClk()` использует backplane, а Ethernet81 всегда возвращает 14,7456 МГц.



- 2026-07-16: в диалог MC-032 добавлен выбор backplane 14,7456 МГц

  (до 57,6 кГц) или 16,384 МГц (специсполнение до 64 кГц). Значение сохраняется

  как `CFG backplane=<Гц>`, восстанавливается при загрузке проекта, регистрирует

  сетку по полному SourceId и передаётся в драйвер для расчёта аппаратных кодов.



- 2026-07-16: исправлена область действия частоты MC-201. Частота меняется сразу

  у четырёх тегов слота, программируется отдельно для каждого MC-201 и передаётся

  в запись вместе с поканальным числом отсчётов. Соседние слоты сохраняют прежние

  частоты. Причина и правило: `errors/2026-07-16-mc201-frequency-scope.md`.



- 2026-07-17: кнопка балансировки MC-201 переведена с программного вычитания на

  оригинальный алгоритм `ModuleMC201::ZBalance`: команда `SEND_BALANCE_CC=53`,

  свежие серии `Fs*0,06`, двухступенчатый поиск DAC, восстановление при ошибке и

  сохранение по каналу/диапазону. I/O сериализован с Preview; из Stop запускается

  временный скан. Подробности: `errors/2026-07-17-mc201-zero-balance-was-software.md`.



- 2026-07-17: первый аппаратный запуск балансировки дал `2048/3456`; 2048 —

  завершённая порция MC-032 после служебной команды. Размер оценки ограничен

  `min(Fs*0,06, 2048)`, поэтому поиск не ждёт недостижимый объём. Убрано второе

  общее окно ошибки после уже показанного конкретного сообщения устройства.

  Сетка теперь 300..57600 Гц; её же расчёт использует кодирование `FreqIndex/Grid`.

- 2026-07-17: устранено зависание LCL при аппаратной балансировке MC-201.

  Многошаговая операция выполняется в worker, GUI показывает модальное состояние

  и остаётся отзывчивым; LCL-owner в фоновый драйвер не передаётся.

- 2026-07-17: балансировка MC-201 переделана с многократного двоичного поиска на

  один проход: 1 с данных, потоковое среднее в кодах АЦП, номинальный пересчёт

  `Uref/Range`, одна установка двухбайтового кода ЦАП.

- 2026-07-17: исправлена потеря результата балансировки MC-201 в старых проектах

  без `CFG slot`: `StoreBalanceDac` теперь создаёт строку настроек, сохраняет код

  ЦАП и показывает/логирует фактически применённое значение.

- 2026-07-17: найден недостижимый активный путь команд MC-201: ранний `Exit` в

  `CallCommandModuleIdmaActivated` отправлял `SEND_BALANCE_CC` как для

  остановленного IDMA. После удаления обхода аппаратный smoke-тест подтвердил

  изменение среднего: `$8080=499,367`, `$8088=495,274`, `$8880=490,618`;

  крайние коды оригинального алгоритма дали `$00FF=32767`, `$FFFF=-32768`.

  ЦАП после каждой проверки восстановлен в `$8080`. Ошибочная трактовка пары

  8-битных ЦАП как линейного 16-битного числа удалена, возвращён двухступенчатый

  поиск оригинального `ModuleMC201::ChanCalibrFullSingleScan`.

- 2026-07-17: устранён timeout `2048/3456` и кажущееся зависание балансировки.

  Причина — конкурентное чтение одного сокета фоновым read-thread просмотра и

  `CollectChannelMean`. На время всей балансировки read-thread приостанавливается,

  служебный код единолично читает поток, затем поток просмотра восстанавливается

  в `finally`; аппаратный скан MC-032 не перезапускается.

- 2026-07-17: в модальное окно балансировки добавлен живой журнал. Для каждой

  пробы показываются аппаратные слот/канал, код двух ЦАП, количество отсчётов и

  среднее; окно после завершения остаётся открытым до кнопки «Закрыть». Те же

  строки пишутся в `LogWindows.log` с префиксом `[MCBUS][BALANCE]`.

- 2026-07-17: по результату проверки длительный двоичный поиск снова заменён

  однопроходной балансировкой MC-201: одна секундная выборка, расчёт раздельных

  8-битных `lo/hi` по номинальной передаточной функции и одна аппаратная команда.

  В UI выводятся исходное среднее, масштаб и фактически отправленный код.

# 2026-07-20 — MC-201 cold start / Stop



- В production `TMc032Device.Config` добавлен обязательный оригинальный путь

  `CMD_RESET -> reconnect -> повторный SearchModules -> ProgramMc201Scan`.

- После `CMD_RESET` очищать `TMc201LegacyMdpClient.fLoadedBiosSlots`: reset

  инвалидирует RAM модулей, локальный кэш нельзя сохранять.

- Stop не повторяет запись после `MDP TCP write failed` и ограничивает drain 1 с.

- Сборка RecorderLnx успешна. Для аппаратной проверки нужен холодный reset

  MC-032: текущий стенд ping отвечает, TCP/4000 закрыт после старого сбоя.

# 2026-07-21 — общий lifecycle устройств и разделение MCbus Init/Config



- В `IRecorderDevice`/`TRecorderDevice` добавлены явные `InitializeDevice` и

  `ConfigureDevice`; `ProgramDevice` оставлен совместимым фасадом.

- MCbus выполняет полный cold Init с reset/BIOS только один раз на подключение.

  Повторный Config использует `ConfigKeepSession` без общего reset и повторной

  загрузки BIOS.

- Источник MCbus вызывает Init и Config явно.

- Прямые реализации `IMic140Device` получили совместимые адаптеры новых методов.

- Нормативный шаблон для новых устройств:

  `Docs/devices/device-lifecycle-template.md`.



# 2026-07-21 — восстановлен поток MC-032/MC-201 после холодного запуска



- Найден пропущенный этап оригинального `CCWDInterface::Config`: настройка

  кольцевого массива BIOS-сообщений командой `CMD_CONFIG_MESSAGE (90)`.

- Очередь на 7183 слова теперь создаётся после `SCAN_SET_CHANS`, до стартовых

  триггеров; `START_TRIGGERSTARTADC` перенесён после полного программирования.

- Автотест просмотра 5 с подтвердил непрерывные пакеты и блоки 16×11520 каждые

  200 мс, то есть 57600 отсчётов/с на канал. Сборка RecorderLnx — exit code 0.



# 2026-07-21 — PAN OglChart для логарифмических осей



- `TChartPanZoomListener.MouseMove` больше не вычисляет смещение через

  арифметический диапазон `Max-Min`.

- Новые границы общего X, собственного X оси и Y вычисляются обратными

  преобразованиями рендерера из сдвинутых пикселей. Поэтому PAN правой кнопкой

  визуально равномерен для `casLinear` и `casLog10`.

- Пакет `LzrObrPack` и RecorderLnx полностью пересобраны, exit code 0.

# 2026-07-21 — uMainForm отделён от реализаций устройств



- Создание MIC-140, MIC-185 и MCbus runtime-источников перенесено в

  `Device/uRecorderRuntimeSourceFactory.pas`.

- Аппаратные диалоги, балансировка и device-specific CLI self-test скрыты за

  `Device/uRecorderTagDeviceServices.pas`.

- `UI/uMainForm.pas` больше не содержит имён MIC/MCbus/MC-032/MC-201 и не

  импортирует их units; форма вызывает только нейтральные фасады.

- Формирование/разбор SourceId MC-032 перенесены из UI-диалога в

  `uRecorderMcbusDataSource`, в диалоге оставлены совместимые обёртки.

- Полная сборка `RecorderLnx.lpi` завершилась успешно.



# 2026-07-21 — RecorderLnx собран в Astra Linux VM



- Виртуальная машина запущена через VMware Tools (`vmrun`), рабочий профиль

  Lazarus: `/home/user/.lazarus_work`.

- Установленная связка FPC/fpcres не принимает Windows RC-вход. Включение

  `mcbus.rc` ограничено `MSWINDOWS`; Linux загружает BIOS MC-201 файловым

  fallback относительно `lib/x86_64-linux/RecorderLnx`.

- Сборка Lazarus завершилась с exit code 0. Результат:

  `RecorderLnx/lib/x86_64-linux/RecorderLnx`, ELF x86-64, 50 704 112 байт;

  `ldd` не обнаружил отсутствующих библиотек.



# 2026-07-21 — исправлен SIGPIPE при Linux-запуске



- GDB подтвердил `SIGPIPE` в `fpSend` главного потока при стартовой проверке

  закрытого TCP-сокета; FPC показывал его как `External code 13`.

- В UNIX-старте установлен `fpSignal(SIGPIPE, SignalHandler(SIG_IGN))`, поэтому

  драйвер получает обычный `EPIPE` и может пометить только этот источник offline.

- Реальный запуск в VM с `--preview-seconds=5` прошёл `Stop -> Preview -> Stop`

  без модального исключения и завершился с кодом 0.

- MC-201 поток не проверен: гостевая ОС отвечает `Network is unreachable` для

  `192.169.12.87` и TCP/4000. Это ограничение маршрутизации VM.

- Для запуска из Lazarus IDE добавлен `MSG_NOSIGNAL` во все TCP-клиенты

  MCbus/MIC-140/MIC-140v2/MIC-185. Строгий GDB-тест с остановкой на SIGPIPE

  прошёл без единого сигнала и завершился нормально.

# 2026-07-21 — восстановлена сеть Astra VM и поток MC-201



## 2026-07-21 — ускорено первое открытие мнемосхем в Linux



- Добавлены тайминги `[MNEMO-PERF]` для переключения вкладки, построения страницы

  и дорогих визуальных компонентов.

- Причина была не в GLX/шейдерах: `MakeCurrent=0–1 ms`, initialize renderer

  `1–4 ms`; первый кадр тратил `1,2–1,8 s` на атласы шрифтов.

- `cOglFont.BuildTextureAtlas` переведён с `Canvas.Pixels` на нормализованный

  `TLazIntfImage`; удалены безусловные `font_atlas_*.bmp` и `font_debug.log`.

- После исправления первый кадр занимает `12–34 ms`; визуальная проверка Linux

  подтвердила корректные подписи, сетки, линии и легенды.

- Подробности: `errors/2026-07-21-linux-mnemonic-first-open-slow.md`.



## 2026-07-21 — одинаковые иконки сохранения в Windows и Linux



- Linux больше не заменяет встроенные иконки сохранения нарисованным fallback

  при отсутствии абсолютного Windows-пути к исходникам Recorder.

- Кнопки явно используют встроенные элементы `ilCommandButtons`: Save — индекс

  58, Save As — индекс 48. Внешняя платформенная подмена отключена.

- Полные сборки Windows и Linux завершились с exit code 0.

- Подробности: `errors/2026-07-21-linux-save-icons-pink-background.md`.



## 2026-07-21 — полосы спектра при нерабочем первом канале



- `TRecorderSpectrumView` больше не берёт полосы безусловно из

  `fBufferedFrames[0]`.

- Для полос выбирается первый рассчитанный кадр с приоритетом кадра, содержащего

  полосовые результаты; нерабочий первый источник не скрывает рабочие линии.

- Полные сборки Windows и Linux завершились с exit code 0.

- Подробности:

  `errors/2026-07-21-spectrum-bands-hidden-by-offline-first-channel.md`.



## Кроссплатформенные ресурсы BIOS и калибровок



- Удалён абсолютный Windows-путь к `mc_201a.bio`.

- Добавлен `Core/uRecorderResourcePaths.pas`: exe/resources, переменная

  `RECORDERLNX_RESOURCES`, настроенный `Mera Files/Resources`, IDE build-tree.

- После сборки BIOS копируется рядом с exe в `resources/devices/mc201`.

- Калибровки MIC-140/MIC-185/MC-201 и SDB подтверждённо используют настроенный

  `RecorderMeraFilesPath` и `Calibr` через `PathDelim`.

- Проверки: Windows resource 22040 байт; Linux из `/tmp` file resource 22040

  байт; полная Linux-сборка RecorderLnx успешна.



- Причина отсутствия связи: `ens33` был `DOWN`, без IP и маршрута.

- DHCP поднял `192.168.112.128/24`; MC-032 `192.169.12.87:4000` доступен.

- Автоподъём сохранён в `/etc/network/interfaces.d/ens33`, эталон добавлен в

  `Lazarus/Tools/vm/interfaces.d/ens33`.

- `TestLink` MCbus теперь закрывает probe-сессию; рабочий Connect всегда свежий.

- Ошибки Connect/Init/Config переводят источник offline без исключения в UI.

- Linux `lazbuild -B` успешен. Preview 5 с: 16 каналов, 11520 отсчётов/блок,

  период около 200 мс, штатный Stop.

# 2026-07-22 — MIC-140 192.168.14.48, GUI IP/INI и lifecycle



- Новый MIC-140 подтверждён как совместимый с legacy Ethernet протоколом:

  `devType=16705`, SN=4582, rev=14.1, BIOS=1.8; 25 блоков за 5 секунд,

  gaps/dup/corrupt/resync = 0.

- Удалена зависимость транспортной публикации от амплитудного профиля старого

  стенда: валидные данные нового прибора больше не отбрасываются.

- В тестовом GUI адрес и порт задаются пользователем и сохраняются рядом с EXE

  в `Mic140ProtocolDebug_Codex.ini`.

- MIC-140 приведён к явному lifecycle: Connect открывает транспорт, Init читает

  firmware и очищает orphan scan, Config программирует scan, Start не вызывает

  предыдущие стадии, Stop сохраняет состояние Programmed.

- Документация: `Docs/devices/mic140-lifecycle.md`, расследование:

  `errors/2026-07-22-mic140-device-specific-stream-filter.md`.

# 2026-07-22 — MIC-140 debug GUI: реальный поток



- `Tests/mic140/Mic140ProtocolDebug_Codex` переведён с незавершённого локального

  каркаса на рабочий `Device/MIC140v2/TRecorderMic140v2Device`.

- Форма выполняет полный lifecycle и автоматически запускает трёхсекундный сбор.

- Таблица показывает 48 каналов: последний код, среднее, число отсчётов, эталон

  MIC140-0329 и отклонение.

- Проверено на `192.168.14.48:4000`: 15 блоков/3 с, 48x2 отсчёта, gaps/dup/corrupt/resync=0.

- Подробности: `errors/2026-07-22-mic140-debug-gui-no-acquisition.md`.

# Продолжение Codex 2026-07-22: тайминги MIC-140-48v3 и 298 точек



Пользователь подтвердил, что стендовый прибор — именно MIC-140-48v3. По

оригинальным `mic140ppext.cpp`, `Mc114mod.cpp`, `MIC140_48v2mod.cpp` и

`MIC140_48v3mod.cpp` установлено: галка максимального быстродействия означает

`flag_allch_sampl=0`; тогда `GetCountUsedChannels()` для v3 возвращает

48 AIn + 7 созданных TIn = 55. При Fs=10 Гц, земле off, decay=57 мкс,

Tadc=5 мкс и штатном `PERIOD_TIMER_WORK=112` формула даёт `count_aver=298`.

Поле земли 19,688 мкс остаётся видимым, но при `flag_chan_ground=0` в расчёте

не участвует. Подробности и правило проверки исполнения/флагов/числа каналов

записаны в `Docs/devices/mic140/protocol/08_timing_and_count_aver.md`, §§8.6,

8.6.1 и 8.9.1.

## 2026-07-23 — MIC-140: версия 14.1.8.1 не определяет профиль



- По оригиналу `CMIC140::GetVersionStr` строка состоит из `DevRev.DevSubRev.BiosRev.BiosFunc`.

- Тип `MIC140_48V3_TYPE` выбирается зарегистрированной фабрикой/конфигурацией:

  `CMIC140_48v3::Creator -> CMIC140_48v3EthernetInterface -> CModuleMIC140_48v3`.

- Один физический прибор поэтому показывает `14.1.8.1` при разных выбранных типах.

- Условие RecorderLnx `DevRev >= 14 => v3` нельзя считать корректным определением

  профиля; профиль должен храниться явно, а ревизии используются внутри него.

- Исправлен порядок BIOS-полей в init-логе: теперь выводится `8.1`, а не `1.8`.

- Правило записано в `Docs/devices/mic140/programming_profiles.md`.

- Полная сборка `RecorderLnx.lpi` под Windows: OK.

## 2026-07-23 — явный профиль v3 в тесте и протокол по ревизии



- Введены независимые признаки `TMic140ProgrammingProfile` и

  `TMic140HardwareProtocol`.

- `Mic140ProtocolDebug_Codex` явно создаёт `mppMic14048v3`.

- После `InitializeDevice` аппаратный формат выбирается по считанному `DevRev`:

  `<12` — legacy, `>=12` — 48v2; карта внутренних TIn учитывает `DevSubRev`.

- Количество экспортируемых каналов больше не выводится из ревизии для явного

  профиля.

- В scan-лог добавлены `profile`, `hwProtocol`, `rev`.

- Сборки теста и RecorderLnx: OK.

- Живой запуск невозможен: `192.168.14.48:4000` не принимает TCP; локальных

  Recorder/Mic140 процессов нет.



## 2026-07-23 — тип стендового MIC-140 подтверждён независимо



- Прибор `192.168.14.48:4000` однозначно является `MIC-140-48v3`.

- Пользователь подтвердил тип обнаружением с другого ПК: другая подсеть,

  рабочий broadcast, одна сетевая карта. Это 100-процентный факт стенда.

- Для этого прибора больше не проверять `MIC-140-48`/`MIC-140-48v2` как

  альтернативный тип. Текущую ошибку кодов искать внутри v3: lifecycle,

  программирование скана/коммутаторов и декодирование потока.

- Сбой broadcast на многосетевом рабочем ПК не опровергает тип прибора.

- Подробное правило записано в

  `Docs/devices/mic140/programming_profiles.md`.



## 2026-07-23 — контролируемый сетевой эталон MIC-140



- Рядом с единым тестом `Tests/mic140/Mic140ProtocolDebug_Codex` добавлен

  `Tools/capture_mic140_traffic.ps1`.

- Захват выполняется системным `pktmon` только на уровне NIC с фильтром по IP

  прибора и TCP-порту; сохраняются полные пакеты без усечения.

- Имена артефактов начинаются с IP и содержат сценарий

  `original_recorder` либо `recorderlnx_test`.

- На каждый прогон формируются исходный ETL, переносимый PCAPNG, полный

  pktmon-текст с hex, CSV пакетов, компактный timeline и README условий.

- `Tools/parse_mic140_pcapng.py` без внешних библиотек извлекает время,

  интервалы, направление, endpoints, wire/capture/IP/payload lengths,

  TCP seq/ack/flags и hex payload.

- PowerShell/Python syntax и декодирование искусственного

  Ethernet/IPv4/TCP-кадра проверены: направление, seq/ack и payload корректны.

- Инструкция и подтверждённые параметры стенда находятся в

  `data/captures/README.md`.

# 2026-07-27 — MIC-140: чтение ГХ через live-сессию

**Prompt:** кнопка «зачитать ГХ» в `TagSettingsDialog` выдаёт ошибку; рабочий
сбор MIC-140 нельзя повредить.

**Причина:** загрузчик ГХ открывал второй TCP, пока `TRecorderMic140DataSource`
уже владел подключением. В логе подтверждён timeout второго `Connect`.

**Исправление:** `IMic140ServiceMemory`; EEPROM/firmware читаются через
зарегистрированный `TRecorderMic140Device`. Автономный TCP оставлен fallback.
В `Play` операция запрещена; после сервисного StopScan очищаются MDP-буферы.

**Проверка:** RecorderLnx и MIC140 debug project собираются. Существующий
DataSources executable проходит все тесты. Подробности:
`errors/2026-07-27-mic140-gx-second-tcp-timeout.md`.
# 2026-07-27 — MIC-140: восстановление аппаратной ГХ

Исправлен round-trip флага и имени аппаратной ГХ: миграция MIC-140 больше не
очищает поля тега, а TagSettingsDialog синхронно обновляет device config.
При загрузке проекта CSV автоматически ищется по
`Calibr/hardware/MIC140/snNNNN/<range>/NN.csv` и загружается в реестр без
сетевого обращения. На default.config.json подтверждена автозагрузка каналов
01–04 для SN0329. Сборка RecorderLnx OK.

# 2026-07-27 — MIC-140: OK аппаратного диалога без второго TCP

`ApplyRecorderMic140SourceDialog` больше не опрашивает firmware/serial при
простом открытии и подтверждении диалога. Эти операции только изменяют
конфигурацию; сетевой запрос выполняется по явной кнопке «Проверить».
Устранён второй `TMic140v2Tcp.Connect` поверх live-сессии источника. После
аппаратного диалога также восстанавливается проекция флага и имени аппаратной
ГХ в теге. Полная сборка RecorderLnx успешна.

# 2026-07-27 — MIC-140: единицы по фактическому конвейеру

Добавлен общий `RecorderMic140ApplyTagOutputPresentation`: аппаратная ГХ
выключена — `code`; включена в режиме напряжения — `mV`; включена вместе с
термопарной ГХ — `degC`. Диалог канала теперь сохраняет `OutputMode` и
`ChannelCalibrationEnabled`, массовое применение их копирует. Правило
вызывается после аппаратного диалога, изменения галок, загрузки проекта,
назначения ГХ и при подготовке источника. Галка аппаратной ГХ сразу обновляет
поле единицы в TagSettingsDialog. Сборка RecorderLnx exit code 0.
# 2026-07-27 — единые физические имена TIn MIC-140-48v3

**Prompt:** В диалоге канала отображался `T10`, а аппаратная таблица показывала
внутренний индекс `5`; создаваемые температурные теги также использовали
логические номера.

**Done:** Добавлены единые helpers преобразования индекса списка в физический
номер. Диалог, колонка «Канал КХС», описания и новые адреса/имена тегов теперь
показывают `T6..T12`; парсер возвращает внутренний индекс для runtime и принимает
старые `t1..t5`. Полная сборка `RecorderLnx.lpi` завершилась с exit code 0.

# 2026-07-27 — фон пользовательской мнемосхемы

**Prompt:** Добавить возможность настройки картинки фона на пользовательской
редактируемой странице.

**Done:** В модель `TRecorderFormPage` добавлен `BackgroundImageFileName`.
Диалог управления страницами позволяет выбрать PNG/JPEG/BMP или очистить фон
только для mnemonic page. Поле `BackgroundImage` сохраняется в `.gui.ini`
относительно файла проекта и разрешается в абсолютный путь при загрузке.
`TRecorderPagePanel` кэширует `TPicture` при смене настройки и при отрисовке
только растягивает готовое изображение. Полная сборка `RecorderLnx.lpi`
завершилась с exit code 0.

# 2026-07-27 — доступность настройки фона после выбора страницы

**Prompt:** При выборе `New mnemonic` кнопка фона заблокирована, а на базовой
странице состояние обратное.

**Root cause:** `TStringGrid.OnSelectCell` срабатывает до обновления `Grid.Row`;
диалог читал модель предыдущей строки.

**Done:** `SelectCell` теперь выбирает страницу по аргументу `aRow` и передаёт
её в `UpdatePageEditors`. Добавлено правило
`RLNX_GRID_SELECTION_USE_EVENT_COORDINATES_2026_07_27` и журнал
`errors/2026-07-27-form-pages-stale-grid-row.md`. Полная сборка
`RecorderLnx.lpi` завершилась с exit code 0.
# 2026-07-27 — аудит загрузки CPU в Preview

**Prompt:** после перехода в просмотр два ядра загружены почти на 100 %;
проверить кольцевую запись, поточечные вычисления и обновить RunTime-навык.

**Подтверждено:** запись MERA на диск в Preview не вызывается (`WriteBlock`
ограждён `rsRecord`). В 15-секундном профиле поток `Src_mera.file.1`
потреблял 0,969 с CPU/с, а его tick занимал 188–235 мс при периоде 200 мс.
Причина — поточечный `TFileStream.ReadBuffer` для каждого R4-отсчёта
(около 518 400 мелких чтений/с для текущих 9×57 600 Гц) и последующие копии
блоков. Второй тяжёлый контур — базовые осциллограммы: до 16 полных Snapshot и
до 4,6 млн `AddValue`/с без decimation по ширине экрана.

**Документ:** `errors/2026-07-27-preview-two-cpu-cores.md`.
Правило проекта: `RLNX_RUNTIME_TICK_MUST_HAVE_HEADROOM_2026_07_27`.
# 2026-07-27 — блоковые курсоры тегов без данных в EventBus

**Prompt:** MIC-140 показывал только часть секундного окна; EventBus не должен
копировать данные, период вычитки настраиваемый.

**Done:** `TRecorderSignalBuffer` переведён на непрерывное кольцо отсчётов с
пакетными `Move`. Логический блок имеет расчётную длину
`PollFrequencyHz * DataUpdateMs`; короткие сетевые пакеты дополняют его до
полного блока, начало которого вычисляется арифметически без таблицы границ.
Измерительные массивы удалены из EventBus.
`TMainForm` по таймеру `DataUpdateMs` проверяет блоковые курсоры; writer забирает
только непрочитанные целые блоки. Осциллограмма больше не зависит от числа
мелких пакетов MIC-140 внутри цикла. `RecorderTagsTest` PASS, полная сборка
`RecorderLnx.lpi` OK.
# 2026-07-27 — MIC-140: ХТС через МО тега и защита последовательности

Компенсация холодного спая переведена на штатный
`TRecorderTag.Estimate(tekMean)`: TIn публикуется первым, применяет аппаратную
ГХ и вычисляет оценки, после чего термопарные каналы читают готовое МО.
Повторный проход по TIn удалён; обратная ГХ термопары считается один раз на
канал/блок.

`TMic140AuxTemperatureBlock` получил `Revision`. Один снимок DM больше не
публикуется повторно при чтении нескольких основных блоков из FIFO. Для
основных блоков добавлена проверка монотонности времени с пропуском
перекрывающей/переставленной порции и логом. Полная сборка `RecorderLnx.lpi`
успешна.
## 2026-07-28 — автономный эталон Mic140ProtocolDebug_Codex

- Тест `Tests/mic140/Mic140ProtocolDebug_Codex` больше не использует исходники
  рабочего RecorderLnx и SharedUtils через `OtherUnitFiles`.
- MIC140v2 и минимальные общие контракты восстановлены локально из backup 010;
  логгер также локализован и пишет рядом с exe.
- PPU выводятся в `lib_standalone`.
- Выполнены две чистые сборки `lazbuild -B`: в рабочем каталоге и после
  переноса проекта в отдельный `%TEMP%`; обе успешны.
- Правило закреплено маркером
  `RLNX_STANDALONE_PROTOCOL_REFERENCE_2026_07_28` в документации и skill.

## 2026-07-28 — быстрый повторный Preview MIC-140

- `TRecorderMic140DataSource.Stop` больше не вызывает Disconnect и не
  сбрасывает признаки Init/Configure.
- Перед повторным Start подготовленная live-сессия проверяется через TestLink.
  Сбой помечает источник offline и исключает его из опроса.
- Явный «Сброс устройства» теперь создаёт reset-запрос, разрывает сессию и
  заставляет следующий Prepare выполнить полный Init/Configure.
- Добавлен CLI acceptance `--preview-cycles=N`.
- Прогон `--preview-seconds=4 --preview-cycles=2`: один Init/Configure, два
  Start/Stop, по 81 опубликованному блоку в каждом цикле.
- Полная сборка `RecorderLnx.lpi` успешна.
# 2026-07-28 — повторный аудит загрузки CPU при работе MIC-140

## Запрос

Проверить, сохранились ли оптимизации предыдущего дня, и найти причину устойчивой загрузки двух процессорных ядер в режиме просмотра.

## Результат

- Подтверждено, что прежние оптимизации сохранены:
  - файловый источник читает данные блоками;
  - кольцевой буфер тега принимает блок через `Move`;
  - EventBus не переносит массивы измерений;
  - оценки тега кешируются при поступлении блока;
  - осциллограммы пересобирают линии только при изменении ревизии данных или параметров отображения;
  - после EOF файловый источник не выполняет активный цикл.
- Найдена оставшаяся ошибка на границе транспорта MIC-140:
  каждый небольшой FIFO-пакет сети запускал калибровку, расчет оценок,
  уведомления и инвалидировал графики как самостоятельный блок Recorder.
- В `uRecorderMic140DataSource` добавлен заранее выделенный накопитель логической порции.
  Сетевые пакеты теперь только дополняют его, а тяжелая обработка выполняется
  после накопления `Fs * DataUpdateMs / 1000` отсчетов на канал.
- Поточечного прореживания и потери данных нет; остаток пакета переносится
  в следующую логическую порцию.

## Проверка

- Полная пересборка `RecorderLnx.lpi`: успешно.
- Стенд MIC-140 за 12 секунд:
  `read=214`, `published=64`, `readGaps=0`, `dupRead=0`, `corruptRead=0`.
- До исправления публиковались все 214 транспортных пакетов; после исправления
  тяжелая цепочка выполняется примерно 5 раз/с, как задано периодом 200 мс.

## 2026-07-28 — остаточная загрузка после агрегации MIC-140

- Удалён синхронный debug-log каждого успешного сетевого пакета MIC-140.
- Полные стендовые проверки кодов AIn/TIn доступны только с define
  `MIC140_RUNTIME_DIAGNOSTICS`.
- Активная UI-страница больше не перерисовывается на холостом тике:
  `ConsumeTagDataCycle` формирует сводную сигнатуру ревизий колец, а
  `DrainUiEventQueue` выполняет render только при её изменении.
- Сборка OK. Контроль за 8 с: 1,58 с CPU всего, горячие потоки 0,734/0,609 с,
  успешных пакетных строк в логе нет.

## 2026-07-29 — остаточная CPU-нагрузка Preview

- Добавлен агрегированный профиль общих стадий под define
  `RECORDER_RUNTIME_DIAGNOSTICS`: ревизии тегов, UI-очередь и подготовка
  видимой страницы.
- Общая UI-очередь копировала каждый блочный массив тега, хотя экран читает
  кольцевые буферы по revision.
- Очередь `TRecorder.EventQueue` теперь принимает только события тревог.
  Обновления тегов и спектров в неё не копируются.
- В контрольном прогоне очередь уменьшилась примерно с 2000 событий за 5 с до
  нуля; видимая страница продолжает обновляться 5 раз/с.
- Полная сборка `RecorderLnx.lpi` успешна.
# 2026-07-29 — уточнена роль клиентской обёртки тега

Пользователь уточнил: в плагинах роль потребителя выполняет `cTag`, где живут
счётчик прочитанных блоков, сброс `doOnStart` и необязательная развёртка кольца
в непрерывный массив. Перенос курсоров в общий AlgorithmManager отменён.
Локально оптимизирован `TRecorderTrendView`: `LastBlockSnapshot` вызывается
только после изменения клиентского `LastBlockCounter`. Штатный лог
`DataSource Tick took` оставлен только под `RECORDER_RUNTIME_DIAGNOSTICS`.
Изменённые units компилируются; линковка блокируется запущенным PID 19600.
## 2026-07-29 — компонент «Картинка»

- Добавлен компонент мнемосхемы `Image`.
- В режиме редактирования видна рамка; в просмотре картинка выбирается по
  последнему значению необязательного тега.
- Таблица `значение тега -> файл` сохраняется в `gui.ini`, пути переносимые,
  относительно проектного файла.
- Диалог выполнен как редактируемая форма
  `UI/uRecorderImageSettingsDialog.lfm`; превью рисуется в таблице.
- Полная сборка `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` проходит.
# 2026-07-29 — Image скрывался белой заливкой в редакторе

**Prompt:** каждый раз заново создаваемый Image виден в рабочем режиме, но
становится белым сразу после включения редактирования.

**Done:** по свежему `[IMAGE]`-логу подтверждено, что файл загружен и
`StretchDraw` вызывается. Причина находилась в следующей операции:
`Canvas.Rectangle` рисовал пурпурную рамку непрозрачной белой кистью и стирал
картинку. Перед рамкой добавлен `Canvas.Brush.Style := bsClear`. Полная сборка
`RecorderLnx.lpi` — exit code 0. Подробности:
`errors/2026-07-29-image-hidden-in-edit-mode.md`.

## 2026-07-29 — установщик RecorderLnx для Windows

- Добавлен установщик Inno Setup 7:
  `D:\works\OburecGH\installer\RecorderLnx\Win\RecorderLnx.iss`.
- Каталог программы по умолчанию:
  `C:\Program Files (x86)\Mera\RecorderLnx`.
- Рядом с EXE создаются `plugins`, `bios`, `syscom` и файл
  `RecorderLnx.paths.ini`.
- Изменяемые данные вынесены в выбираемый каталог Mera Files; конфигурация
  RecorderLnx хранится в `<MeraFiles>\RecorderLnx\config`.
- `uRecorderMeraPaths` читает системные пути из INI рядом с EXE, а
  `uRecorderResourcePaths` использует настроенный каталог `bios`.
- Полная сборка Lazarus и компиляция Inno Setup прошли. Выполнена настоящая
  тестовая установка и запуск: установленная программа прочитала файл путей и
  создала run-control конфигурацию в выбранном Mera Files.
- Подробный контракт: `Docs/windows-installer.md`.

### Исправление каталога по умолчанию

Inno Setup сохранял каталог тестовой установки, переданный через `/DIR`, и при
следующем запуске предлагал `_install_test\App`. В `[Setup]` добавлен
`UsePreviousAppDir=no`: мастер всегда начинает с
`C:\Program Files (x86)\Mera\RecorderLnx`, пока пользователь сам не изменит путь.

## 2026-07-29 — общий список результатов автопоиска устройств

- Кнопка поиска аппаратуры больше не открывает настройку первого найденного
  MIC-140.
- Добавлен редактируемый LFM-диалог
  `UI/uRecorderDeviceSearchDialog.lfm` с общим списком MIC-140, MIC183/185 и
  MC-032.
- Найденные новые устройства отмечаются автоматически. Источники, которые уже
  присутствуют в `ConfiguredDataSources`, выводятся с пометкой
  «уже добавлено» и без галочки.
- Аппаратный редактор вызывается вторым шагом и только для отмеченных строк.
- Полная сборка `RecorderLnx.lpi` прошла, exit code 0.

## 2026-07-29 — File not open у установленной версии

- Причина: OglChart пытался писать диагностические файлы в Program Files и после
  неудачного открытия безусловно закрывал `TextFile`.
- Служебные файлы перенесены в `<MeraFiles>\RecorderLnx`; общий журнал:
  `LogWindows.log`/`LogLinux.log`.
- Диагностическая запись больше не влияет на UI, покадровый trace OglChart выключен.
- Подробности: `errors/2026-07-29-installed-basepage-file-not-open.md`.
# 2026-07-29 — Enabled источника отделён от аппаратного dirty

**Prompt:** отключение виртуального Mera File после `OK` надолго блокировало
программу, хотя аппаратные свойства не менялись.

**Done:** причина — `HardwareToggleSourceClick` выставлял общий
`fDataSourcesChanged`, после чего главная форма очищала менеджер и выполняла
`PrepareHardwareAll` для всех приборов. В менеджере добавлено собственное
состояние `Enabled`: отключённый контекст сохраняется, но не готовится и не
получает поток. Переключение синхронизируется после `OK` без пересоздания
остальных источников. Общий `Clear` также удалён из пути аппаратных изменений:
главная форма сравнивает программируемые сигнатуры по `SourceId`, а фабрика
заменяет и готовит только изменённый источник. Добавление и удаление также
обрабатываются индивидуально. Полная сборка RecorderLnx прошла успешно.
# 2026-07-31 — ТЗ модуля SQL-записи

**Запрос:** оформить техническое задание на модуль SQL-хранения RecorderLnx: автоматическое создание базы в выбранном каталоге, объекты/свойства/сигналы, периодическая и условная runtime-запись, события, удалённая работа и связанные файлы спектров/осциллограмм; сохранить три исходных скриншота.

**Сделано:** создано ТЗ `Docs/sql/sql-recording-module-tz.md` и оформленная версия `Docs/sql/sql-recording-module-tz.docx`. Зафиксированы границы первой очереди, архитектурные интерфейсы, ориентировочная схема, жизненный цикл записи, spool для удалённой БД, атомарное файловое хранилище, безопасность, приёмочные проверки и открытые решения. Исходные изображения сохранены в `Docs/sql/sql-recording-assets/` и встроены в приложение к DOCX.

**Проверка:** DOCX структурно содержит 167 абзацев, 1 таблицу и 3 изображения; Microsoft Word отрисовал 9 страниц, все страницы проверены по PNG — обрезаний, наложений и пропавшей кириллицы нет.

**Статус:** готово как версия 0.1 для согласования; перед реализацией требуется выбрать СУБД первой очереди и утвердить нагрузочный профиль/политику spool и ретенции.
# 2026-07-31 — перенос комплекта SQL-ТЗ

**Запрос:** перенести все созданные материалы ТЗ модуля SQL-записи в `Docs/sql`.

**Сделано:** DOCX, Markdown, три исходных скриншота и воспроизводимый скрипт сборки перенесены в `Docs/sql/`; относительные связи Markdown и вычисление корня в сборщике сохранены работоспособными.

**Проверка:** в `Docs/sql/` находятся 8 ожидаемых элементов; прежние пути файлов и каталогов отсутствуют, сборщик успешно создаёт DOCX по новому пути.

**Статус:** готово.
# 2026-07-31 — отложенное добавление компонентов мнемосхемы

**Запрос:** не создавать компонент сразу по кнопке тулбара; создать его в месте
следующего щелчка и отжать инструмент. Оживить заготовку Button.

**Сделано:** контроллер редактора получил отдельный режим ожидания координаты;
главный тулбар хранит только тип будущего элемента. После щелчка создаётся один
компонент и инструмент отжимается. Добавлен сохраняемый визуальный тип Button с
Caption; действие по нажатию пока не задаётся.

**Проверка:** исходники полностью скомпилированы; штатная линковка заблокирована
запущенным `RecorderLnx.exe` (error 5).

**Статус:** код готов; после остановки текущей отладки повторить обычную сборку и
ручной UI-тест размещения.
# 2026-07-31 — управляющая кнопка мнемосхемы

**Запрос:** добавить в настройки Button привязку изменяемого тега, значения
состояний и режимы фиксации, удержания и импульса.

**Сделано:** добавлен визуально редактируемый LFM-диалог с поиском/выбором тега,
надписью, значениями нажатия/отпускания и длительностью импульса. В runtime
кнопка публикует значение через TagRegistry в режимах переключателя, удержания и
импульса; в редакторе нажатия не изменяют тег. Настройки сохраняются в gui.ini,
переносятся copy/paste и новый unit включён в LPI.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi` — exit code 0.

**Статус:** готово; физические теги могут быть перезаписаны следующим отсчётом
прибора, поэтому для логики управления рекомендуется виртуальный тег.
# 2026-07-31 — служебный тег управления SQL DB

**Запрос:** скрыть аппаратные измерительные каналы из настройки кнопки и
добавить штатный виртуальный тег управления SQL-записью.

**Сделано:** диалог Button показывает только `IsVirtual` теги. При загрузке
проекта автоматически создаётся `SqlDbRecordEnabled` с диапазоном 0..1 и
описанием порога; SQLdb автоматически назначает его управляющим тегом и
синхронизирует начальное значение с фактическим состоянием записи.

**Проверка:** полная сборка во временный `RecorderLnx_verify.exe` — exit code 0;
штатный EXE удерживается запущенным RecorderLnx.

**Статус:** готово; для установки штатного EXE нужно остановить текущий запуск и
обычно пересобрать проект.
# 2026-07-31 — восстановлен PushTag управляющей кнопки SQL DB

**Запрос:** кнопка фиксации, привязанная к `SqlDbRecordEnabled`, не меняла тег;
ручной чекбокс SQL DB также не обновлял индикатор этого тега.

**Сделано:** смена edit/runtime теперь принудительно пересоздаёт controls страницы,
поэтому Button получает runtime click handler. После успешного переключения
чекбокса состояние SQL DB публикуется в тот же служебный тег.

**Проверка:** полная сборка в `RecorderLnx_verify.exe` — exit code 0.

**Статус:** исправлено; штатный EXE занят текущим запуском, для ручной проверки
нужно остановить его, пересобрать и снова проверить Button/чекбокс/индикатор.

# 2026-07-31 — отображение состояния Button и картинки состояний

**Запрос:** кнопки с фиксацией и без фиксации должны явно показывать текущее состояние; для
нажатого и отжатого состояний нужны независимо выбираемые изображения.

**Сделано:** визуальный Button переведён на `TSpeedButton`; его состояние теперь обновляется
по фактическому последнему значению привязанного тега и немедленно при локальном нажатии.
Для режимов фиксации, удержания и импульса реализовано соответствующее отображение. В модель,
INI-сохранение, copy/paste и LFM-диалог настройки добавлены картинки нажатого и отжатого
состояний; поддерживаются PNG/JPEG/BMP/GIF, отсутствующий или ошибочный файл не мешает запуску.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi` — exit code 0; штатный
`lib/x86_64-win64/RecorderLnx.exe` успешно обновлён.

**Статус:** готово к ручной проверке на мнемосхеме.

# 2026-07-31 — картинка Button на всю площадь

**Запрос:** автоматически растягивать картинку состояния на весь размер кнопки и не выводить
поверх неё текстовую надпись.

**Сделано:** изображения Button больше не передаются стандартному `Glyph`, который оставлял
поля под подпись. Кнопка сама растягивает активную картинку на полный `ClientRect` и не вызывает
стандартную отрисовку Caption; если картинка текущего состояния отсутствует, остаётся обычная
кнопка с надписью.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi` — exit code 0; штатный EXE обновлён.

**Статус:** готово.
## 2026-07-31 19:45 — интерактивное управление SQL-трендом

**Запрос:** редактировать оси под виджетом, зумить область левой кнопкой, прокручивать X/Y правой кнопкой, возвращать весь диапазон; назначать цвета линий из общей палитры и вынести код в `SQLdb/SqlTrend`.

**Сделано:** добавлена нижняя панель оси Y, временный прямоугольный zoom, pan X/Y, кнопка и двойной щелчок `Весь график`. Новые линии используют `OglChartLineAppearance(index)`. Модель, view и LFM-диалог перемещены в `SQLdb/SqlTrend`, пути `.lpi` обновлены.

**Проверка:** полная сборка `RecorderLnx_verify.exe` — exit code 0; временная цель удалена из `.lpi`. Штатный EXE удерживается запущенным RecorderLnx.

**Статус:** готово в исходниках; после закрытия RecorderLnx выполнить штатную сборку.

## 2026-07-31 19:20 — исправлен диапазон и отображение SQL-тренда

**Запрос:** показывать цвет линии залитой панелью, проверить реальные данные БД и связать поля `От`, `До`, `Окно` взаимным пересчётом.

**Сделано:** цвет вынесен в кликабельную панель; диапазон БД и число точек показываются в диалоге, добавлена кнопка `Весь диапазон`; `От/До` пересчитывают окно, окно пересчитывает `От`. Одиночные SQL-точки теперь рисуются маркерами.

**Проверка:** Firebird содержит 1171 значений и 60 сигналов, UTC-диапазон `31.07.2026 15:05:59`…`15:38:10`; полная сборка временного `RecorderLnx_verify.exe` — exit code 0. Штатный EXE удерживается запущенным RecorderLnx и не обновлён.

**Статус:** готово в исходниках; для получения штатного EXE закрыть RecorderLnx и повторить обычную сборку.

# Итерация 2026-07-31: исторический SQL-тренд

- Добавлен мнемокомпонент `sql-trend` с моделью, представлением и LFM-диалогом в `SQLdb`.
- Компонент наследует модель обычного Trend и визуальный контракт `TPanel + IVForm`.
- Имена каналов читаются из `signals.name` SQL БД и не зависят от тегов текущего Recorder.
- Реализованы линии, привязка линий к осям Y, диапазоны осей, фиксированное UTC-время и последнее временное окно.
- SQL-выборка выполняется фоновым потоком; число точек линии ограничивается настройкой.
- Тип и настройки сохраняются в `.gui.ini`, файлы добавлены в `.lpr/.lpi`, на панели редактора есть инструмент `SQL`.
- Добавлена документация `Docs/sql/sql-db-historical-trend.md` с рекомендациями SCADA-функций.
- Проверка: `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` — успешно; обновлён основной `lib\x86_64-win64\RecorderLnx.exe`.
# 2026-08-05 — отображения и Y-сетка SQL-тренда

**Запрос:** добавить именованные наборы сигналов и осей SQL-тренда, листалку наборов на компоненте, их сохранение/загрузку и промежуточную сетку по Y.

**Сделано:** добавлена модель отображений с собственными линиями и осями; диалог позволяет создавать, переименовывать, удалять и настраивать отображения. В нижнюю панель тренда добавлены список и кнопки перехода, а в график — пять интервалов Y-сетки с подписями. INI сохраняет все отображения и активный индекс; старые конфигурации импортируются как одно отображение.

**Проверка:** все изменённые модули и LFM успешно скомпилированы полной сборкой. Линковка остановилась только потому, что запущенный RecorderLnx удерживает `lib\x86_64-win64\RecorderLnx.exe` (Windows error 5).

**Статус:** готово; для получения нового EXE требуется закрыть запущенный RecorderLnx и повторить сборку.
# 2026-08-05 — автомасштаб «Весь график» SQL-тренда

**Запрос:** кнопкой «Весь график» измерять полный диапазон текущего отображения и выполнять полный зум по X и автомасштаб Y с запасом 20%.

**Сделано:** границы X вычисляются по всем загруженным точкам видимых линий активного отображения. Для каждой Y-оси отдельно находятся минимум и максимум её линий; к диапазону добавляется суммарный запас 20% (по 10% сверху и снизу). Для постоянного сигнала создаётся ненулевой симметричный запас.

**Проверка:** полная сборка `RecorderLnx.lpi` завершилась успешно, включая линковку нового EXE.

**Статус:** готово.
# 2026-08-05 — корректное отсечение SQL-тренда при зуме

**Запрос:** не разрывать линию на границе X-окна и не прижимать вышедшие за Y-диапазон точки к рамке.

**Сделано:** удалено принудительное ограничение Y и отбрасывание внешних X-точек. Отрезки клипуются по области построения, внешние маркеры скрываются.

**Проверка:** полная сборка `RecorderLnx.lpi`, exit code 0.

**Статус:** готово.
# 2026-08-05 — встроенный тензокалькулятор и окно SQL-тренда в днях

**Запрос:** добавить модуль тензометрических ГХ с выбором схемы, материала и единиц, быстрым runtime-полиномом с точностью не хуже 0,1%; длительность SQL-тренда вводить в днях.

**Сделано:** создан `Calibrations/Strains` с расчётным модулем и LFM-диалогом. Новый тип ГХ сохраняет физические параметры и коэффициенты `Offset/K1/K2`, проверяет полином на 201 точке и отклоняет ошибку выше 0,1%. ГХ добавляется и редактируется из настроек канала. Поле окна SQL-тренда переведено с часов на дни.

**Проверка:** полная сборка под отдельным проверочным именем завершилась с exit code 0; временный EXE удалён.

**Статус:** готово.
# 2026-08-06 — список назначенных ГХ канала

**Запрос:** в окне списка ГХ показывать только ГХ, назначенные выбранному каналу, а не весь общий реестр.

**Сделано:** кнопка списка канальных ГХ теперь открывает LFM-диалог над `CalibrationNames` текущего тега. Для канала без назначений, например `MemTag`, список пуст. Общий реестр ГХ открывается только по кнопке «Добавить» внутри этого диалога. После подтверждения синхронизируется признак включения канальной ГХ.

**Проверка:** полная сборка `RecorderLnx.lpi` в `RecorderLnx_verify.exe` — exit code 0. Штатный EXE не заменён, потому что RecorderLnx запущен (PID 2892).

**Статус:** код готов; для получения новой штатной сборки следует закрыть запущенный RecorderLnx и пересобрать проект.
# 2026-08-06 — автоединицы тега из канальной ГХ

**Запрос:** при включённом флаге «Авто» переносить выходные единицы назначенной ГХ в единицы тега.

**Сделано:** единица тега берётся из `UnitOut` последней ГХ цепочки. Синхронизация выполняется при включении «Авто», выборе, добавлении и редактировании ГХ, а также при `OK/Применить`. При выключенном «Авто» введённые пользователем единицы сохраняются.

**Проверка:** после исправления обнаруженной ошибки области видимости выполнена полная сборка `RecorderLnx.lpi` в `RecorderLnx_verify.exe` — exit code 0.

**Статус:** код готов; штатный EXE не заменён, поскольку запущен RecorderLnx PID 14676.
# 2026-08-06 — диагностика большого значения тензо-ГХ на MemTag

**Запрос:** выяснить, почему `MemTag=147,3` после включения тензо-ГХ превращается примерно в `1155517` мкстр.

**Сделано:** проверена формула runtime и построение тензо-ГХ. Значение `147,3` подаётся в ГХ как 147,3 мВ, хотя MemTag физически является объёмом памяти. Полином с коэффициентами из формы закономерно даёт около 1,155 млн мкстр.

**Проверка:** для конфигурации 1/4 моста, S=2, ток 3 мА, R0=120 Ом и диапазон ±10000 мкстр рабочий вход составляет примерно −1,81…+1,79 мВ. 147,3 мВ находится примерно в 82 раза за рабочим диапазоном; гарантия ошибки 0,1% там не действует. Excel на скриншоте дополнительно настроен на питание напряжением 5 В, то есть сравнивается с другой схемой питания.

**Статус:** причина установлена; изменение кода не выполнялось.
# 2026-08-06 — контроль диапазона уставок и создание виртуального тега

**Запрос:** на вкладке уставок контролировать попадание значения в допустимый диапазон и показывать серый цвет вне диапазона; на вкладке «Каналы» добавить создание именованного виртуального скалярного тега.

**Сделано:** добавлен сохраняемый флаг `SetpointRangeControlEnabled`, включённый по умолчанию. Движок тревог запоминает выход текущего значения за `RangeMin..RangeMax`; нормальный цвет канала и цвет вне диапазона — серый, цвета активных уставок сохраняются. На LFM-вкладке уставок добавлен флажок контроля диапазона.

**Сделано:** снизу списка выбранных каналов добавлена LFM-кнопка «Создать виртуальный тег...». Она запрашивает уникальное имя и создаёт скалярный тег с `IsVirtual=True`, источником `manual` и стандартным буфером.

**Проверка:** полная штатная сборка `RecorderLnx.lpi` — exit code 0; `RecorderLnx.exe` обновлён.

**Статус:** готово.
# 2026-08-06 — исправление серого цвета нормальных каналов

**Запрос:** выяснить, почему после контроля допустимого диапазона все каналы стали серыми, включая нормальный `CpuUsage`.

**Сделано:** установлено, что `CpuUsage=0,275` сравнивается со стандартным диапазоном тега `-32000..32000` и находится внутри него. Исправлён `TRecorderAlarmEngine.GetTagAlarmColor`: нейтральное состояние снова возвращает `0`, серый `$808080` возвращается только при `OutOfRange=True`.

**Проверка:** полная сборка `RecorderLnx_verify.exe` — exit code 0. Штатный EXE не заменён, поскольку запущен RecorderLnx PID 13680.

**Статус:** исправление готово; для установки в штатный EXE нужно закрыть запущенный RecorderLnx и пересобрать проект.
# 2026-08-06 — Alarm-цвета цифровых индикаторов и состояние «нет данных»

**Запрос:** показывать на цифровых индикаторах мнемосхемы цвета срабатывания Alarm; теги без значений отображать серым.

**Сделано:** цифровой индикатор подключён к общему `IRecorderAlarmEngine` и окрашивает фон цветом активной уставки; нормальное состояние сохраняет штатный светлый фон. В цифровой форме и на индикаторе отсутствие отсчётов (`SignalBuffer.Count=0`) отображается серым независимо от диапазона и уставок.

**Проверка:** полная сборка `RecorderLnx_verify.exe` — exit code 0. Штатный EXE не заменён, поскольку запущен RecorderLnx PID 13680.

**Статус:** код готов; чтобы увидеть изменения в штатной программе, закрыть RecorderLnx и выполнить обычную сборку.
# 2026-08-06 — переход в просмотр при недоступном MIC-183/185

**Запрос:** устранить исключение TCP connect, всплывающее в отладчике при переходе RecorderLnx в режим «Просмотр».

**Сделано:** для MIC-183/185 добавлен невыбрасывающий `TryConnect`; подготовка аппаратуры теперь при ошибке подключения переводит только соответствующий источник в offline и продолжает запуск остальных источников. Явный `Connect` сохранён как выбрасывающая обёртка для вызывающего кода, которому это поведение требуется. Причина и защита от повторения добавлены в журнал ошибок проекта.

**Проверка:** полная сборка `RecorderLnx_verify.exe` — exit code 0. Штатный `RecorderLnx.exe` не обновлён, потому что запущен и заблокирован процессом RecorderLnx PID 1464.

**Статус:** исправление готово; после закрытия запущенного RecorderLnx требуется штатная пересборка EXE.

# 2026-08-06 — создание скалярного/векторного виртуального тега

**Запрос:** компактная кнопка с иконкой виртуального тега и LFM-диалог выбора типа тега; для векторного тега задаётся частота.

**Сделано:** добавлена небольшая кнопка с общей иконкой виртуальных каналов; создан LFM-диалог, где скалярный тип выбран по умолчанию, а для векторного включается положительная частота опроса. Тип сохраняется в конфигурации проекта и учитывается в настройках SQL-оценки.

**Проверка:** штатная полная сборка до последующего исправления MIC-185 — exit code 0; совокупный текущий код проверен полной сборкой `RecorderLnx_verify.exe` — exit code 0.

**Статус:** готово.
# 2026-08-06 — привязка аппаратной сети к локальному интерфейсу

**Запрос:** добавить в аппаратные настройки выбор сетевого интерфейса, оставив по умолчанию штатный выбор ОС по маршрутам и метрикам.

**Сделано:** в LFM-вкладку аппаратуры добавлен список локальных IPv4 с режимом «Автоматически (метрика ОС)». Выбор сохраняется в `project.json`; общий TCP-коннектор выполняет `bind()` до `connect()` для MIC-140, MIC-183/185 и MC-032/MC-201. Новый модуль включён в структуру проекта, устройство механизма описано в документации.

**Проверка:** полная сборка `RecorderLnx_verify.exe` — exit code 0. Штатный EXE занят запущенным RecorderLnx PID 9792.

**Статус:** код готов; для обновления штатного EXE нужно закрыть запущенный RecorderLnx и повторить обычную сборку.
# 2026-08-06 — имена активных сетевых адаптеров

**Запрос:** вместо неразличимого списка всех локальных IP показывать имена только активных сетевых адаптеров.

**Сделано:** Windows-список переведён на `GetAdaptersAddresses`: отбираются только адаптеры с `OperStatus=Up`, строки имеют вид `Имя адаптера [IPv4]`. Для `bind()` и сохранения настройки из подписи извлекается чистый IPv4; ранее сохранённый адрес корректно сопоставляется новой строке.

**Проверка:** полная сборка `RecorderLnx_verify.exe` — exit code 0.

**Статус:** готово; штатный EXE обновится после закрытия запущенного RecorderLnx и обычной пересборки.
# 2026-08-06 — проверка приборной сети через выбранный адаптер

**Запрос:** добавить проверку связи с прибором через выбранный сетевой интерфейс и выяснить, почему автопоиск не видит доступные устройства.

**Сделано:** в аппаратные настройки добавлены редактируемые адрес и TCP-порт с кнопкой `TCP-пинг`. Текущий выбор адаптера применяется непосредственно перед тестом и ручным автопоиском. TCP-пробы MIC-140 и MIC-183/185 используют общий сокет с `bind`. Таймаут идентификации MIC-183/185 увеличен с 180 до 1000 мс. Контрольные адреса в программу не добавлялись; `192.168.9.142` — прежний `MIC185DefaultHost`, а не результат обнаружения.

**Проверено:** адреса `192.168.9.147`, `.148`, `.151`, `.152`, `.155` отвечают на ICMP и принимают TCP/4000 при явной привязке к `Ethernet 2 (192.168.5.100)`. Через Wi-Fi `10.57.216.144` ICMP до приборной сети не проходит. Полная сборка `RecorderLnx.lpi` в `RecorderLnx_verify.exe` завершилась с exit code 0.

**Осталось:** полноценное обнаружение неизвестных адресов MIC-183/185 должно использовать широковещательный протокол прибора либо параллельное сканирование подсети, а не жесткий список адресов.
# 2026-08-06 — пакетное удаление алгоритмов и производных тегов

**Запрос:** устранить ошибку после удаления второго узла алгоритма, добавить мультивыбор и удалять теги удалённых алгоритмов.

**Сделано:** удаление переведено на предварительный снимок объектов модели без повторного чтения освобождённых `TreeNode.Data`; смешанная выборка родителя и детей не вызывает двойного удаления. Мультивыбор закреплён в `uRecorderSettingsDialog.lfm`. При `Применить` и `OK` удаляются только осиротевшие теги `Spectrum estimate`; если тот же исходный тег ещё используется другим алгоритмом, его производные теги сохраняются.

**Проверка:** полная компиляция `lazbuild -B RecorderLnx.lpi` дошла до линковки без ошибок исходного кода. Создание exe заблокировано активной отладочной сессией Lazarus (`RecorderLnx.exe`, error code 5); IDE продолжает удерживать процесс после внешней остановки.

**Статус:** код готов; для финальной линковки необходимо завершить текущий запуск в Lazarus и повторить Build.
# 2026-08-06 — уникальная адресация каналов нескольких MIC-185

Запрос: исправить неполное добавление каналов и одноимённые теги; пользователь заметил, что у всех приборов адрес был `3-N`.

Сделано: введён общий расчёт логического номера MIC-185 (`3`, `4`, `5`, ...), подключён к каталогу каналов, настройке, сериализации и runtime. Короткое имя формируется из адреса с префиксом `185`. Запрещена перепривязка одноимённого аппаратного тега другого источника. Для доступной таблицы добавлен устойчивый row-map, поэтому после стрелки строки немедленно переходят вправо.

Проверено: `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi`, exit code 0. Для линковки был закрыт только запущенный RecorderLnx PID 14784.

# 2026-08-06 — MIC-185: настройка активного прибора и серийный номер в дереве

**Запрос:** устранить ошибку второго TCP-клиента после OK в диалоге MIC-185 и подписывать серийный номер приборов в дереве аппаратуры.

**Сделано:** `RecorderMic185ProgramConfiguredSource` больше не создаёт параллельное соединение к endpoint, которым уже владеет runtime; сохранённая конфигурация применяется штатной переинициализацией источника. Чтение идентификации для UI использует runtime-кэш/live-device без нового подключения. Узлы MIC-185 отображаются как `MIC-185: host:port, SN=<номер>`, когда прибор уже сообщил серийный номер.

**Проверка:** полная сборка `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` — exit code 0.

**Статус:** готово к проверке на подключённых приборах.

## 2026-08-07 — MIC-185: адрес канала от IP

**Запрос:** сделать привязку каналов независимой от порядка повторного обнаружения приборов.

**Сделано:** аппаратный адрес строится из последнего октета IP: `155-3`, `155-t1`, `155-uts`; имя нового тега — `185-{155-3}`. Добавлена миграция старых адресов по номеру канала внутри исходного `SourceId`. Выяснено, что предыдущий сбой UTS был связан с выключенным СЕВ на приборе; временные протокольные обходы удалены.

**Проверка:** исходники изменены; полная линковка ожидает закрытия запущенного RecorderLnx PID 10572.

**Статус:** частично — требуется сборка и проверка загрузки существующего проекта.
# Итерация 2026-08-07: жизненный цикл MIC-185

- Запрос: устранить нестабильную инициализацию MIC-185 после перезапуска, проверить чтение SN и отделить стадии жизненного цикла прибора; создать отдельный навык программирования устройств.
- Сделано: удалено двойное probe/рабочее TCP-подключение; транспортное подключение отделено от обязательной инициализации с чтением SN/версии; ручной сброс MIC-185 выполняет полный reinitialize/configure; тяжёлая подготовка разных устройств остаётся параллельной.
- Проверено: `lazbuild -B RecorderLnx.lpi` — успешно, exe слинкован.
- Осталось: стендовая проверка холодного запуска пяти MIC-185 и повторного сброса одного прибора.
## 2026-08-07 — пакетное удаление устройств клавишей Delete

**Запрос:** разрешить выделить в дереве устройств несколько источников и удалить их одним нажатием Delete.

**Сделано:** Delete и кнопка удаления собирают все выделенные `SourceId`, показывают одно подтверждение, удаляют конфигурации, снимают активные источники, помечают связанные теги как `Detached` и один раз обновляют дерево и таблицы. Мультивыбор принудительно включён и для дерева, созданного в runtime.

**Проверка:** компиляция всех модулей прошла; финальная линковка заблокирована запущенным `RecorderLnx.exe`, PID 11476.

**Статус:** частично; после закрытия RecorderLnx повторить `lazbuild -B RecorderLnx.lpi`.
## 2026-08-07 — сброс MIC-185 без остановки отладчика

**Запрос:** при сбросе MIC-185 с ошибкой Lazarus останавливался на исключении
инициализации.

**Сделано:** ожидаемые отказы подключения, инициализации и программирования в
ручном сбросе и `PrepareHardware` переведены на `Try*`-контракты с текстом
ошибки. Добавлен `TryProgramDevice`; штатный отказ теперь переводит источник в
offline без намеренного `raise` внутри безопасной функции.

**Проверка:** исходники полностью скомпилированы; финальная линковка заблокирована
запущенным RecorderLnx PID 9204 (`error code 5`).

**Статус:** частично; закрыть запущенный RecorderLnx, повторить `lazbuild -B` и
проверить сброс отключённого устройства на стенде.

## 2026-08-07 — чтение SN MIC-185 при TestLink

**Запрос:** после перезапуска программы при выполнении `TestLink` обязательно
читать серийный номер непосредственно из MIC-185.

**Сделано:** устранён преждевременный успешный выход `TestLink` после одного
TCP-подключения. Для незапущенного прибора TEST выполняет `GetSoftVersion`,
проверяет ответ и обновляет SN/версию. Broadcast и сохранённая конфигурация
сохраняют последнюю известную подпись, но не подменяют фактическое чтение при
TEST.

**Проверено:** полная сборка `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` —
успешно, EXE слинкован.

**Осталось:** проверить холодный запуск на пяти реальных MIC-185: после TEST у
каждого узла должен появиться актуальный SN.

## 2026-08-07 — параллельный пакетный сброс MIC-185

**Запрос:** при Ctrl-выделении нескольких приборов сбрасывать все выбранные
параллельно; повысить устойчивость сброса прибора, который остался offline.

**Сделано:** обработчик формирует снимок всех выбранных `SourceId`; для каждого
создаётся отдельная worker-задача с полным циклом reset. Разные endpoint
обрабатываются параллельно, LCL и offline-реестр обновляются после ожидания всех
задач в главном потоке. Для задержанного освобождения single-client TCP добавлен
один повтор через 250 мс. При ошибках показывается один итоговый диалог с
endpoint и причиной. Правый клик по уже выделенному узлу больше не снимает
множественное выделение.

**Проверено:** все Pascal-модули скомпилированы без ошибок. Финальная линковка
не выполнена, потому что `RecorderLnx.exe` занят запущенным процессом PID 20856.

**Осталось:** закрыть RecorderLnx, выполнить полную линковку и проверить
Ctrl-выделение пяти MIC-185 с одной командой «Сбросить».
## 2026-08-07 — таймаут MIC-185 при сбросе и исключение MIC-140 в автопоиске

**Запрос:** MIC-185, найденный broadcast-поиском, при сбросе завершался ошибкой `Mebius IoControl timeout`; проверка недоступного MIC-140 во время автопоиска останавливала отладчик на `ESocketError`.

**Сделано:** таймаут чтения идентификации MIC-185 отделён от короткого таймаута TCP-подключения и увеличен до 3000 мс только на время `GetSoftVersion`; после освобождения runtime-источника reset ждёт 250 мс и при временном отказе делает один повтор через 500 мс. Для MIC-140 добавлен не генерирующий исключение `TryConnect`; функции автопоиска и чтения свойств используют результат `Boolean + error text`, поэтому отсутствие прибора больше не создаёт штатное исключение в отладчике.

**Проверка:** `git diff --check` — без ошибок. Полная компиляция всех Pascal-модулей прошла; финальная линковка заблокирована запущенным `RecorderLnx.exe` (`error code 5`).

**Статус:** код готов; после закрытия работающего RecorderLnx повторить `lazbuild -B RecorderLnx.lpi`, затем проверить сброс 192.168.9.147 и автопоиск при недоступном MIC-140.
## 2026-08-07 — MIC-185: broadcast видит SN, reset теряет SN и долго ждёт

**Запрос:** `.147` снова найден broadcast-поиском как `SN=161`, но предшествующий reset долго ожидал, не показал серийный номер и завершился ошибкой.

**Причина:** broadcast возвращает SN независимо от TCP/Mebius и не выполняет `GetSoftVersion`. Reset создавал новый объект, обнулял уже известную идентификацию перед обновлением и дважды повторял трёхсекундный IoControl timeout.

**Сделано:** неуспешное обновление идентификации больше не стирает последний подтверждённый SN; известные SN/версия подаются в новый объект при reset и холодном старте; успешное чтение сохраняется в конфигурацию. Второй reset-повтор отменён для `IoControl timeout`, но сохранён для временной ошибки подключения/освобождения TCP-сессии.

**Проверка:** все Pascal-модули скомпилированы. Линковка EXE заблокирована работающим RecorderLnx PID 17240 (`error code 5`).
## 2026-08-07 — нестабильность MIC-185 перемещается между приборами

**Запрос:** после повторного поиска `.147` ожил одновременно в оригинальном Recorder и RecorderLnx, но ошибочным стал другой MIC-185.

**Вывод:** проблема не привязана к адресу `.147`. Оригинальный поиск только создаёт `DeviceInfo` с адресом/SN; при добавлении оригинал уничтожает прежний объект того же адреса, затем выполняет `CreateDevice -> Init -> Attach`, а `GetSoftVersion` вызывается позже в `WaitConnecting`. Последние исправления RecorderLnx ещё не проверялись: текущий EXE PID 13052 запущен из старой сборки, поскольку обновлённый EXE не удалось слинковать при занятом файле.

**Проверка:** первичные исходники оригинала: `EthernetBus.cpp`, `DARTC.cpp`, `mic185v2.cpp`. MemoryDB была недоступна из-за занятого `.lock`, использован узкий `rg`.

**Статус:** заблокировано запущенным RecorderLnx; закрыть PID 13052, выполнить полную сборку и только затем повторять стендовую проверку.
## 2026-08-07 — адрес выбранного прибора в поле TCP-пинга

**Запрос:** при выборе сетевого устройства в аппаратном дереве автоматически подставлять его endpoint в поля тестового пинга.

**Сделано:** обработчик изменения выбора поднимается от дочернего узла к узлу источника, распознаёт MIC-140, MIC-185 и MC-032/MC-201, затем заполняет IP и порт. Для Mera File и несетевых узлов текущие поля не меняются. Обработчик назначен и в `.lfm`, и в runtime fallback UI.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi` успешна; актуальный `RecorderLnx.exe` слинкован.

**Статус:** готово.

## 2026-08-07 — профиль CPU в режиме Preview

**Запрос:** определить, почему во время просмотра RecorderLnx заметно нагружает примерно два логических ядра.

**Сделано:** выполнены два автоматических запуска Preview и сняты дельты процессорного времени каждого потока. Чистый десятисекундный интервал устойчивого Preview потребовал 8000 мс CPU, то есть в среднем 0,8 одного ядра. Пять потоков MIC-185 потребили вместе 5062,6 мс (около 50,6% одного ядра), UI-поток — 1250 мс (12,5%), остальные источники и служебные потоки — около 16,9%.

**Причина:** основной расход сосредоточен в `TRecorderMic185DataSource.PublishMeasurementBlock`: для каждого принятого блока заново строится полный массив программных настроек прибора, для каждого канала выполняются строковый поиск тега и поиск градуировки, создаются массивы времени/значений. В `TRecorderMic185Device.ReadBlock` дополнительно создаётся и поканально копируется весь блок `Single -> Double`. Это повторяется независимо в пяти потоках MIC-185.

**Проверка:** соответствие TID источникам подтверждено именами `Src_MIC-185: <IP>:4000` в `LogWindows.log`; замер сделан после сообщения `State changed: Stop -> Preview`, без примеси аппаратной инициализации.

**Статус:** причина локализована; код пока не оптимизировался. Следующий шаг — кэшировать настройки/ссылки на теги на стадии Configure, переиспользовать рабочие буферы и повторить тот же профиль до/после.

## 2026-08-07 — первая атомарная оптимизация Preview MIC-185

**Запрос:** дополнить навык программирования устройств правилом малых проверяемых изменений и начать снижать найденную нагрузку CPU.

**Сделано:** навык `device-lifecycle-programming` дополнен атомарными итерациями; разрешено объединять только правки одной причины, доказуемо не влияющие на протокол, таймауты, сессии и состояния. В MIC-185 оставлено одно изменение: массив программных настроек каналов сохраняется при `Configure` и больше не строится заново для каждого принятого блока.

**Проверка:** навык прошёл `quick_validate.py`; RecorderLnx полностью пересобран. На одинаковом десятисекундном Preview с пятью активными MIC-185 нагрузка процесса снизилась с 80% до 47,8% одного ядра, потоков MIC-185 — с 49,5% до 20,1%. Попытка отдельно кэшировать ссылки на теги не получила корректного стендового замера из-за зависших после принудительных тестовых завершений сессий и полностью отменена.

**Статус:** первая оптимизация подтверждена и оставлена; сборка OK. Следующая отдельная итерация — кэш ссылок на теги после восстановления чистого запуска всех пяти приборов.
## 2026-08-07 — первый TCP-пинг красный, последующие операции работают

**Запрос:** при холодном старте все приборы offline; первый TCP-пинг не проходит, второй проходит, после reset прибор работает, а следующий запуск уже успешен.

**Гипотеза и изменение:** параллельная подготовка пяти TCP-устройств начинается до готовности выбранного интерфейса/маршрута. Перед `PrepareHardwareAll` добавлен один штатный MERA UDP broadcast через выбранный bind-интерфейс с окном 1800 мс. Он не занимает single-client TCP и прогревает интерфейс/ARP. Добавлен замер `[HardwarePrepare] network warmup bind=... responses=... elapsed=...ms`.

**Проверка:** Pascal-модули полностью компилируются; линковка нового EXE заблокирована запущенным RecorderLnx PID 14408 (`error code 5`).

**Статус:** частично; закрыть приложение, пересобрать и проверить холодный старт. По логу подтвердить число broadcast-ответов до начала TCP-подготовки.
# 2026-08-07 — прогрев выбранного LAN и устранение гонки runtime MIC-185

**Запрос:** учесть, что холодный старт приборов выполняется через явно выбранный LAN-интерфейс, а не через маршрут ОС по умолчанию; устранить случайный AV при параллельной подготовке MIC-185.

**Сделано:** перед параллельной TCP-подготовкой выполняется один UDP broadcast через `RecorderNetworkBindAddress`. В `uRecorderMic185Runtime` инициализация общего реестра защищена критической секцией и публикует готовность только после создания всех объектов; поиск и изменение endpoint теперь выполняются под блокировкой списка.

**Проверка:** все Pascal-модули полной пересборки скомпилированы; линковка остановилась только на занятом запущенным PID 14408 файле `RecorderLnx.exe` (Win32 error 5).

**Статус:** код готов, окончательная линковка заблокирована запущенным RecorderLnx; после закрытия приложения повторить `lazbuild -B`.
# 2026-08-07 — восстановлена поддержка СЕВ/UTS MIC185 после отката

**Запрос:** заново реализовать канал UTS MIC185, который после восстановления из Git показывал 0, и восстановить удалённый документ по оригинальному Recorder.

**Сделано:** восстановлен документ `Docs/devices/mic185/uts-sev.md`. Удалено неверное чтение UTS как `Single`: реализован разбор `UTS_TRANSPORT_PACKET` для СЕВ МЕРА (`type=2`) и IRIG-B (`type=1`), расчёт пары X/Y как в `CPcUTSImpl`, публикация Y со временем X и обновление `TRecorderTimeSystem`.

**Проверка:** полная пересборка `RecorderLnx.lpi`, exit code 0; новый `RecorderLnx.exe` успешно слинкован. Аппаратная проверка ожидается на стенде по строкам `UTS parsed` в логе.

**Статус:** готово; проверить изменение `185-{...-uts}` раз в секунду и при необходимости прислать строку `UTS parsed`/сырой размер пакета.
# 2026-08-07 — взаимоисключающие списки каналов

**Запрос:** канал источника должен находиться либо в доступных, либо в выбранных; одновременное отображение слева и справа недопустимо.

**Сделано:** сопоставление каналов MIC-185 переведено с буквального сравнения строк адреса на сравнение канонического аппаратного адреса при обязательном совпадении `SourceId`. Формы `155-1`, `185-{155-1}` и прежняя запись адреса теперь распознаются как один канал. То же сопоставление применяется при отметке выбранных сигналов и при сохранении выбора, поэтому после добавления канал сразу исчезает слева, а после удаления возвращается.

**Проверка:** полная компиляция `RecorderLnx.lpi` прошла до стадии линковки без ошибок исходного кода; замена `RecorderLnx.exe` невозможна, пока приложение запущено (`error code 5`).

**Статус:** исправлено; для получения нового exe нужно закрыть запущенный RecorderLnx и повторить сборку.
# 2026-08-07 — исследование паузы при старте записи

**Запрос:** выяснить, связана ли большая пауза при старте записи с открытием файлов, и сравнить инициализацию файлов с оригинальным Recorder.

**Сделано:** по журналу установлено, что кадр открылся за начало интервала, а следующие 6,864 с UI-поток последовательно конфигурировал MIC-185; файлы `.dat` в RecorderLnx создаются позже, лениво при первом блоке. В оригинале файловые targets и файлы заранее готовятся в `PrepareRecordingTargets/CRecTarget::Prepare`, отдельно от обычной активации записи. Подробности записаны в `errors/2026-08-07-record-start-delay.md`.

**Проверка:** сопоставлены `LogWindows.log`, `UI/uMainForm.pas`, `Core/uRecorderDataStorage.pas` и первичные исходники `windev-v3.9/rc_core/Rc_core.cpp`, `RecTarget.cpp`.

**Статус:** причина диагностирована; код не изменялся. Следующий шаг — убрать повторный Init/Configure MIC-185 из тёплого Start и вынести файловую запись из UI-потока.
## 2026-08-07 — пакетный сброс устройств как в оригинальном Recorder

**Запрос:** проверить, почему команда «Сброс всех устройств» оригинального Recorder освобождает зависшие MIC-185, и повторить существенное поведение.

**Сделано:** по первичным исходникам установлено: UI помечает все host-устройства, ядро запускает для каждого асинхронный reset, затем ожидает все операции и отдельно конфигурирует; Mebius-обёртка выполняет `Disconnect -> Connect(true)`, аппаратной reboot-команды не посылает. Исправлен одноимённый пункт RecorderLnx: вместо простого удаления offline-ошибок он собирает все источники дерева и запускает существующий параллельный пакетный reset/reconfigure.

**Проверка:** полная сборка `RecorderLnx.lpi` через `lazbuild -B`, exit code 0. Стендовая проверка массового освобождения зависших сессий остаётся за следующим запуском с приборами.

**Статус:** код готов; подтверждено соответствие алгоритму оригинала на уровне lifecycle.
## 2026-08-07 — устранено пятикратное дублирование UTS в MERA

**Запрос:** исправить запись UTS MIC-185: при фактическом секундном обновлении значение записывалось каждые 200 мс, а заголовок объявлял 1 Гц, из-за чего длительность UTS-сигнала получалась в пять раз больше измерительного канала.

**Сделано:** в драйвер добавлен счётчик поколений UTS, увеличиваемый только при получении нового пакета `dev_id=0`; источник данных публикует пару X/Y только один раз для каждого поколения и больше не повторяет кэш в каждом измерительном блоке. Для UTS-каналов MIC-185 MERA writer теперь принудительно создаёт явный `.x` и не восстанавливает временную ось из номинального `Freq=1`.

**Проверка:** полная сборка `RecorderLnx.lpi` через `lazbuild -B`, exit code 0; штатный `RecorderLnx.exe` обновлён. Стендовая проверка должна подтвердить примерно один UTS-отсчёт в секунду, равное число Double в `.x/.dat` и длительность UTS по X, совпадающую с длительностью измерения.

**Статус:** код готов, требуется короткая аппаратная запись для проверки фактических пакетов.
## 2026-08-07 — сверена совместимость записи UTS с оригинальным Recorder

**Запрос:** проверить, хранит ли RecorderLnx то же сопоставление аппаратных часов контроллера и абсолютного UTS, что оригинальный Recorder.

**Сделано:** по `PcUTSImpl.cpp`, `BaseUTSChannel.cpp`, `RecTarget.cpp` и `TagMeraInfoWritter.cpp` подтверждено: оригинал не пишет сырые тики, а сохраняет Double-пары `X=(SevCLK-StartCLK)/CLK` в `.x` и `Y=SevSec` в `.dat`. Текущий разбор и файлы RecorderLnx соответствуют этой формуле. Дескриптор уточнён: как в оригинале, UTS теперь одновременно содержит `Freq=1`, `XFormat=R8` и `XFile`, без `Start`.

**Проверка:** полная пересборка `RecorderLnx.lpi` через `lazbuild -B`, exit code 0; штатный `RecorderLnx.exe` успешно слинкован. Аппаратные данные и формула декодирования не изменялись.

**Статус:** исследование завершено, сборка выполняется.

## 2026-08-07 — связь каналов MIC-185 с UTS и отображение после холодного старта

**Запрос:** сохранить в MERA привязку измерительных каналов MIC-185 к UTS как в
оригинальном Recorder и показывать каналы исправно подготовленных приборов сразу
после старта, даже если другой прибор не подготовился.

**Сделано:** MERA writer пишет `UTS_Channel=<имя>` для измерительного канала,
если в выбранной конфигурации проекта имеется UTS-тег того же `SourceId`.
Доступный, но не добавленный UTS-канал ссылку не создаёт. После завершения
отложенной аппаратной подготовки повторно вычисляются активные источники и
обновляются список тегов, мнемосхема и базовые осциллограммы; отказ одного
прибора больше не оставляет успешно подготовленные MIC-185 скрытыми до открытия
диалога настроек.

**Проверка:** полная пересборка `RecorderLnx.lpi` через `lazbuild -B`, exit code 0;
новый `RecorderLnx.exe` успешно слинкован.

**Статус:** код готов; требуется короткая стендовая запись и проверка строки
`UTS_Channel` в дескрипторе MERA/WinПОС.
## 2026-08-07 — ускорение повторного Preview/Record

**Запрос:** устранить длительную паузу перехода в просмотр/запись по сравнению с оригинальным Recorder.

**Причина:** после каждого Stop MIC-185 разрывал TCP-сессию и сбрасывал аппаратную готовность. Следующий Start повторно и последовательно выполнял Connect/Initialize/Configure пяти приборов в UI-потоке (около 7 секунд по `LogWindows.log`).

**Сделано:** Stop MIC-185 теперь останавливает только измерение и сохраняет подготовленную сессию; Disconnect перенесён на уничтожение/пересоздание источника. Добавлен лог общей длительности `Data sources started in N ms`.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi`, exit code 0. Требуется стендовый цикл Preview/Stop/Preview и Record для фактического замера нового времени.

**Статус:** исправлено в коде, ожидается проверка на приборах.
## 2026-08-07 — разовое восстановление доступных MIC-185 после загрузки

**Запрос:** после загрузки конфигурации автоматически сбрасывать ошибочную сессию прибора, если его сетевой endpoint отвечает.

**Сделано:** после первой фоновой подготовки определяется список MIC-185 со статусом offline. Для каждого выполняется короткая TCP-проверка (500 мс); доступному прибору выставляется запрос сброса локальной сессии и один раз повторяется полный цикл Connect/Initialize/Configure. Исправные и недоступные приборы не переподключаются, повторный цикл восстановления в рамках одной загрузки запрещён. Добавлены сообщения `Startup session recovery...` в основной лог.

**Проверка:** полная сборка `RecorderLnx.lpi` завершена с exit code 0, EXE успешно слинкован.

**Статус:** реализовано; требуется проверка холодного запуска на стойке с ошибочным, но доступным MIC-185.
## 2026-08-07 — надёжная автоподготовка MIC-185 после загрузки

**Запрос:** живые MIC-185 не должны оставаться с ошибкой после загрузки конфигурации; ручной сброс не должен требоваться.

**Сделано:** удалён отдельный TCP-пробник перед восстановлением: он конфликтовал с одноклиентной сессией MIC-185 и после первого отказа исключал прибор из повтора. После первой подготовки каждый offline MIC-185 теперь проходит освобождение runtime endpoint, выдержку и до двух повторов штатного `Connect/Initialize/Configure`; исправные источники повторно не программируются.

**Проверка:** полная сборка `RecorderLnx.lpi` завершена с exit code 0, EXE успешно слинкован.

**Статус:** исправлено; холодный запуск на реальной стойке остаётся приёмочной проверкой.
## 2026-08-07 — все MIC-185 стабильно инициализируются при холодном старте

**Запрос:** самостоятельно запускать приложение и продолжать исправление, пока после загрузки не останется ни одного неинициализированного живого прибора.

**Сделано:** стадия Mebius `GetSoftVersion/read SN` сериализована общей блокировкой, поскольку параллельные IoControl давали случайный набор timeout при независимых исправных endpoint. Reset-запрос вынесен из live-device entry в отдельный потокобезопасный реестр: теперь источник, упавший до регистрации live-device, действительно повторяет `PrepareHardware`.

**Проверка:** полная сборка успешна. Выполнены два последовательных автоматических холодных запуска с Preview: в обоих все пять адресов `.155/.147/.151/.152/.148` завершили `operation state=OK`, считаны SN `167/161/165/166/162`, записей `operation state=FAIL` нет.

**Статус:** готово.
# 2026-08-07 18:36 — устранена последовательная очередь таймаутов MIC-185 при старте

**Запрос:** Сократить очень долгое первое ожидание при загрузке RecorderLnx.

**Сделано:** По журналу установлено, что общая блокировка `Initialize/GetSoftVersion` превращала пять параллельных подготовок в очередь: ошибки завершались через 10,6 / 21,0 / 31,1 / 41,4 / 51,8 с. Убрана глобальная блокировка между независимыми IP; команды и порядок стадий внутри одного прибора не изменены. Добавлены отдельные замеры `LoadProjectPackage`, `EnsureRuntimeDataSources`, `RebuildTagList`, `RenderActivePage`.

**Проверка:** Проект собран `lazbuild`. Повторный старт показал форму за 0,42 с; загрузка проекта 93–109 мс, источников 188 мс, списка тегов 47–63 мс, страницы 0–15 мс. Таймауты разных MIC-185 теперь завершаются параллельно примерно за 10,6 с вместо накопления до 52 с. Живые приборы в контрольном прогоне не прошли `IoControl` после нескольких принудительных остановок приложения, поэтому успешный холодный цикл на стойке требует следующего обычного запуска.

**Статус:** Частично: программная причина 52-секундной очереди устранена и сборка готова; стабильность успешной инициализации всех приборов должна быть подтверждена без принудительного завершения процесса.
## 2026-08-10 — сокращены повторные операции MIC-185 в Preview

**Запрос:** уменьшить загрузку CPU при старте просмотра, проверив горячий путь
сбора данных MIC-185.

**Сделано:** ссылки на теги, аппаратные ГХ и токовые поправки перенесены из
поканального цикла в подготовку источника. Рабочие массивы переиспользуются,
строковый поиск температурных и UTS-тегов удалён. Подробности:
`errors/2026-08-10-mic185-preview-cpu.md`.

**Проверка:** полная сборка `RecorderLnx.lpi` — exit code 0. Автозапуск не
воспроизвёл рабочий Preview; требуется контрольный стендовый замер CPU.

**Статус:** частично — очевидные повторные операции устранены; следующий шаг
при сохраняющейся нагрузке — раздельный профиль TCP-чтения и публикации.
# 2026-08-10 16:20 — восстановлен запуск MIC-185

**Запрос:** устранить регрессию, при которой зелёные MIC-185 не отдавали данные,
а сброс одного устройства приводил к отказу всей группы; оценить оптимизацию CPU.

**Сделано:** восстановлен полный контракт `Start`; удалены две автоматические
общие волны reset/reconnect всех offline MIC-185. Оптимизация горячего цикла
(кэш ссылок на теги/ГХ/поправки и повторное использование массивов) сохранена.

**Проверка:** полная сборка RecorderLnx — exit code 0. По журналу подтверждён
прежний каскад из трёх волн; стенд после него принимает TCP, но IoControl пока
не отвечает. Точный before/after CPU журнал не содержит, нужен контрольный
прогон после восстановления приборов.

**Статус:** кодовая регрессия исправлена; аппаратная проверка потока и reset
остаётся после освобождения/перезапуска settings-сессий приборов.

# 2026-08-10 19:00 — длительный поток MIC-185, сверка с оригиналом

**Запрос:** не маскировать останов потока статусом offline, а устранить отличие
протокола, поскольку оригинальный Recorder пишет с тех же приборов сутками.

**Сделано:** по исходникам оригинала подтверждены и перенесены размер TCP RX
буфера 4 MiB, `SO_KEEPALIVE`, побайтовое восстановление сигнатуры и legacy-
проверка поля Size. Периодическая публикация данных и неблокирующая вычитка
сохранены. Полная сборка `RecorderLnx.lpi` прошла.

**Проверка:** новый запуск не является чистым длительным тестом — приборы после
предыдущей оборванной сессии принимали TCP, но не отвечали на IoControl. Нужен
освобождённый/перезапущенный стенд и Preview не менее 10 минут.

# 2026-08-10 19:05 — восстановлено сопоставление ответов MIC-185

**Запрос:** исправить отсутствие данных после запуска.

**Сделано:** `TryIoControl` больше не завершает команду на запоздалом ответе
другого IOCTL, а ждёт ответ текущего кода. Найдены и завершены два одновременно
работавших экземпляра RecorderLnx, конкурировавших за sessions приборов.

**Проверка:** сборка прошла. Все пять MIC-185 отвечают на ping, но после
конкурирующих сессий не открывают TCP/4000. Для стендовой проверки требуется
перезагрузка приборов, затем запуск строго одного экземпляра RecorderLnx.

**Статус:** код исправлен; аппаратная проверка заблокирована состоянием стенда.

# 2026-08-10 19:20 — профиль CPU длительного Preview MIC-185

## 2026-08-11 11:40 — окончательно исправлен Linux Mera Files

**Запрос:** устранить повторяющееся исключение SQL с каталогом `C:\Mera Files`.

**Сделано:** обнаружено повторное применение Windows-пути из RunSettings.
Проверка перенесена в центральные `ResolveMeraFilesPath` и
`SetRecorderMeraFilesPath`; путь другой ОС заменяется локальным системным.

**Проверка:** Windows/Linux clean build — код 0. Старый процесс остановлен,
свежий Linux smoke test завершён с кодом 0 без SQL-исключения.

**Статус:** готово.

## 2026-08-11 11:34 — остановлена старая Linux-отладочная сессия

**Запрос:** устранить повторное исключение с прежним Windows-путём SQLdb.

**Сделано:** подтверждено, что Lazarus удерживал старый RecorderLnx PID 19337,
запущенный до исправления. Старый процесс остановлен, выполнена clean build.

**Проверка:** свежий Linux RecorderLnx запущен с `--preview-seconds=2`, завершён
с кодом 0; исключения создания Firebird-каталога нет.

**Статус:** готово; перед следующим F9 Lazarus должен завершить прежнюю
отладочную сессию (кнопка Stop), чтобы убрать zombie из списка IDE.

## 2026-08-11 11:28 — Linux не использует Windows bind-адрес

**Запрос:** восстановить доступ к приборам в Linux при сохранённом выборе
сетевого интерфейса Windows.

**Сделано:** Linux проверяет принадлежность явного bind-адреса локальной системе;
чужой `192.168.5.100` заменяется автоматическим выбором маршрута ОС. Windows-
логика явного выбора интерфейса сохранена.

**Проверка:** Windows/Linux clean build — код 0. В Linux smoke test исчезла
ошибка bind 99; MIC-185 `192.168.9.147` прошёл connect/init/config.

**Статус:** исправлено. Четыре остальных endpoint не ответили на TCP connect и
требуют отдельной проверки их доступности/занятости.

**Запрос:** во время продолжающегося прогона локализовать загрузку двух CPU.

**Сделано:** без остановки процесса сняты дельты CPU по потокам за 10 секунд.
Главный поток занял около 1,55 с CPU, пять потоков MIC-185 вместе около 2,1 с.
В коде найдены три горячих места: повторный `SetLength` матриц при добавлении
каждого сетевого пакета, создание EventBus-объекта для каждого тега каждого
блока и синхронный подробный TEMP/UTS-лог с открытием файла на каждую строку.

**Проверка:** поток приборов продолжает работать; код во время контрольного
прогона не менялся.

**Статус:** причина локализована, оптимизацию выполнять после окончания прогона.
# 2026-08-10 — потеря потока MIC-185 и watchdog зависаний

**Запрос:** исследовать повторную потерю связи после пятиминутного Preview и
закрепить способ локализации зависших многопоточных процедур по входу/выходу.

**Сделано:** журнал показал исчезновение служебных пакетов отдельных MIC-185 без
сетевой ошибки. Удалено дочитывание TCP с таймаутом 2 мс, которое отбрасывало
часть фрагментированного пакета и нарушало синхронизацию. Теперь за вызов читается
один полный измерительный блок штатным таймаутом. В runtime-скилл и AGrav добавлен
watchdog: операция хранит в памяти код, поток и время входа, очищает отметку в
`finally`, независимый таймер редко пишет только просроченный `STUCK`.

**Проверка:** полная сборка `RecorderLnx.lpi` завершилась с exit code 0. Остался
стендовый Preview не менее пяти минут и повторный `Stop -> Preview`.

**Дополнение:** исправлен запоздалый ответ `0x00101034` при ожидании
`0x00101028`: ответы IoControl сопоставляются по коду запроса. Повторный `Start`
из `DoTick` удалён, чтобы ошибка программирования не создавала исключение в
рабочем потоке. Новая полная сборка завершилась с exit code 0.
## 2026-08-10 — runtime-переключатель подробного аппаратного лога

- Запрос: дать возможность без перезапуска выключать подробный лог устройств и сравнивать загрузку CPU.
- В нижнюю панель журнала добавлена галочка `Подробный лог устройств`.
- Общий флаг размещён в `uRecorderDebugLog`, поэтому универсальная форма не зависит от MIC-185.
- `uMic185DebugLog` при снятой галочке не формирует строку, не блокирует буфер и не открывает файл.
- Частые сообщения MIC-185 `TEMP`, `UTS` и `Receive drain limit` проверяют флаг до вызова `Format`.
- Полная сборка `lazbuild -B RecorderLnx.lpi` прошла успешно.
## 2026-08-10 — облегчено обновление цифрового формуляра

**Запрос:** проверить лишние отрисовки цифровой страницы при периоде отображения 200 мс.

**Сделано:** построение структуры таблицы отделено от runtime-обновления. На такте отображения больше не меняются размеры таблицы, не переписываются имена/адреса/описания и не вызывается полный `SGChange`; обновляются только изменившиеся значения и тревоги видимых строк.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi`, exit code 0.

**Статус:** код готов; влияние на CPU следует сравнить на стендовом Preview при той же конфигурации и периоде 200 мс.

## 2026-08-11 — контрольная сборка RecorderLnx под Linux

**Запрос:** подключиться к запущенной VM Atra и собрать текущий RecorderLnx под Linux.

**Сделано:** сборка выполнена по SSH под `user` с профилем Lazarus `/home/user/.lazarus_work`. Удалена устаревшая ссылка `uRecorderMebiusTcpProtocol` из `RecorderLnx.lpr`: исходного файла уже нет, а Windows находил старый PPU. Добавлен скрипт `Lazarus/Tools/build_recorderlnx_linux.sh`. В инструкции VM явно указан SSH как основной способ подключения.

**Проверка:** `lazbuild -B RecorderLnx.lpi` завершился с кодом 0; создан свежий ELF x86-64 `lib/x86_64-linux/RecorderLnx`, отсутствующих динамических библиотек нет.

## 2026-08-11 — безопасный запуск без SQL и конфликт writer-ов MIC-185

**Запрос:** убрать Linux-исключения при отсутствии SQL-сервера и при `AppendFileLine` MIC-185.

**Сделано:** SQL проверяет TCP endpoint до `TIBConnection`, сообщает отказ в системный журнал и не мешает запуску. MIC-185 больше не пишет `LogLinux.log` параллельно с `SharedLogger`; резервная запись файла не использует исключающий `TextFile`.

**Проверка:** Windows и Linux clean build — код 0. Linux smoke test без Firebird — код 0; после двух сообщений SQL журнал содержит `RecorderLnx started` и штатный Preview.

**Статус:** готово; аппаратный интерфейс VM не имеет адреса `192.168.5.100`, поэтому MIC-185 в smoke test штатно отмечены offline.

## 2026-08-11 — переносимый каталог SQLdb

**Запрос:** устранить Linux-исключение создания каталога из Windows-пути
`C:\Mera Files\SQLdb`.

**Сделано:** конфигурация SQL распознаёт путь другой ОС и использует локальный
`<Mera Files>/SQLdb`; общий ini не изменяется.

**Проверка:** Windows и Linux clean build — код 0. Linux smoke test — код 0,
исключения создания каталога нет; недоступный Firebird отмечен только в
`LogLinux.log`.

## 2026-08-11 — освобождение MIC-185 при пропаже потока

**Запрос:** после нескольких минут работы Linux обновление MIC-185 прекратилось;
Windows открывал TCP-порт приборов, но дерево показывало потерю связи.

**Сделано:** подтверждено различие TCP-connect и протокольного TestLink: приборы
не отвечали уже на первый `GetSoftVersion`. В источник MIC-185 добавлен контроль
последнего измерительного блока. После 3 секунд или десяти периодов без данных
источник выполняет `Stop -> Disconnect`, снимает live-device и отмечается
неактивным. После закрытия TCP добавлена выдержка 200 мс для освобождения
Mebius-задачи BIOS.

**Проверка:** `lazbuild -B RecorderLnx.lpi` успешно выполнен на Windows и Linux.
Одиночный тест до новой аппаратной перезагрузки подтвердил текущее состояние
приборов: TCP подключается, `SetControllerParams` получает `IoControl timeout`.

**Осталось:** после закрытия всех экземпляров Recorder выполнить чистую
перезагрузку приборов и прогон Linux/Windows не менее десяти минут.
## 2026-08-11 12:55 — устранено самопроизвольное отключение MIC-185

**Запрос:** найти причину прекращения обновления данных примерно через три минуты просмотра в Windows.

**Сделано:** по журналу и TCP-сессиям установлено, что все пять приборов отключал сам RecorderLnx. Удалён ошибочный watchdog отсутствия готового блока: неблокирующий приём штатно оставляет неполный TCP-пакет до следующего такта и не является потерей связи. Отключение сохранено только для подтверждённого EOF/ошибки сокета.

**Проверка:** полная сборка `RecorderLnx.lpi` завершилась с exit code 0.

**Статус:** частично — требуется повторный аппаратный прогон новой сборки не менее 10 минут.

## 2026-08-11 13:20 — ошибки аппаратуры в панели состояния

**Запрос:** при просмотре сразу показывать, что часть включённых приборов не подключилась или была помечена ошибочной; сообщение должно быть видно рядом с режимом и временем.

**Сделано:** `TMainForm.UpdateHardwareErrorView` проверяет состояния включённых аппаратных источников. При ошибках панель состояния становится красной, в подписи режима появляется `! N`, а hint содержит список источников и причины. Модальные окна не используются. Проверка вызывается при обновлении режима и времени.

Для диагностики замирания MIC-185 добавлен heartbeat раз в 10 секунд со счётчиками принятых пакетов и собранных блоков. В последнем доступном участке журнала все пять приборов наращивали оба счётчика; последующее замирание этим фрагментом ещё не локализовано.

**Проверка:** полная Windows-сборка `RecorderLnx.lpi` завершилась с кодом 0.

**Осталось:** выполнить прогон с новой сборкой и включённым логированием до повторения остановки потока; сравнить последние heartbeat каждого прибора.
## 2026-08-11 13:30 — разновременная остановка потоков MIC-185

**Запрос:** определить, почему потоки разных MIC-185 прекращаются не одновременно.

**Сделано:** добавлен отдельный контроль прихода Mebius-пакетов и сборки готовых
блоков. Молчание источника не разрывает рабочую сессию: в панели состояния
появляется оранжевое предупреждение с адресом и стадией, а переходы
`stalled/resumed` всегда попадают в `LogWindows.log`, независимо от подробного лога.

**Проверка:** полная сборка `lazbuild -B RecorderLnx.lpi`, exit code 0.

**Статус:** частично; следующий длительный прогон должен показать, прекращаются
ли сами пакеты прибора или только сборка измерительных блоков.
# 2026-08-11 — сброс MIC-185 без двойного программирования

**Запрос:** ручной сброс не восстанавливал приборы, хотя оригинальный Recorder подключался.

**Сделано:** сброс больше не создаёт временный MIC-185 client. Старое соединение освобождается, а штатный источник один раз выполняет полный цикл подготовки. Результат проверяется после подготовки, не старым TEST до неё.

**Проверка:** полная сборка `RecorderLnx.lpi` прошла успешно. Подробности: `errors/2026-08-07-mic185-double-session-cold-init.md`.

**Статус:** требуется стендовая проверка ручного сброса.

# 2026-08-11 — исправлен формат session id MIC-185

**Запрос:** все пять приборов примерно одновременно прекращали передачу через пару минут.

**Найдено:** в прогоне 16:54:50–16:56:53 входные пакеты остановились через 94–103 секунды,
хотя TCP оставался открытым. RecorderLnx отправлял session id с нулевыми младшими 12 битами.
Оригинальный `CMIC185V2::GenerateSessionId()` записывает туда `GetTickCount() & $FFF`.

**Сделано:** `Mic185GenerateSessionId` приведён к точной формуле MIC185v2; полная Windows-сборка
прошла. Подробности: `errors/2026-08-11-mic185-session-id-format.md`.

**Статус:** нужен аппаратный просмотр не менее трёх минут; все пять `RX heartbeat` должны расти
после прежней границы остановки.

## 2026-08-11 — уточнена причина остановки MIC-185 около 120 секунд

**Найдено:** правка `session_id` не меняла фактическое значение. В сравнении с
успешной версией `5c3e2471` найден добавленный позднее вызов
`QUERY_SESSION_STATE` в `Initialize`. Общий Mebius keep-alive для MIC-185 в оригинале
выключен (`OnGetKeepAliveFlag = false`). Периодический эксперимент ухудшил поток и
полностью удалён; одиночный session-query при подключении также удалён.

**Проверка:** Windows clean build завершён с кодом 0. Новый аппаратный прогон пока
невозможен без перезагрузки приборов: после экспериментального запроса несколько
контроллеров перестали отвечать уже на `GetSoftVersion`.
## 2026-08-11 — расширена диагностика остановки MIC-185

**Запрос:** определить, что именно происходит при появлении отвалов примерно через 1:30 Preview.

**Сделано:** журнал показал независимую остановку DATA-потока отдельных приборов при открытом TCP (`lost=False`). В транспорт добавлены счётчики сырых TCP-байтов, всех разобранных Mebius-пакетов, DATA-пакетов, отброшенных синхронизатором байтов и размер неполного пакета. Heartbeat и сообщение `stalled` теперь выводят все эти значения.

**Проверка:** полная сборка `RecorderLnx.lpi` прошла, exit code 0.

**Статус:** диагностика готова; нужен следующий аппаратный прогон новой сборки.
## 2026-08-11 — исправлена склейка старых Mebius-пакетов MIC-185

**Запрос:** проверить по оригиналу, почему TCP-байты приходят, но сигнатуры пакетов перестают разбираться.

**Сделано:** сравнение с `CPacketCollector` выявило неверную обработку старого поля `size`: для `$A0A0CAFE` теперь всегда используются младшие 16 бит, а `$A0A0CAFF` сохраняет полный размер. Частичные TCP-чтения продолжают склеиваться в накопителе.

**Проверка:** компиляция прошла; линковка заблокирована работающим RecorderLnx PID 19688.

**Статус:** нужен останов текущего прогона, повторная сборка и аппаратная проверка дольше прежней границы отказа.
## 2026-08-12 12:53 — план упрощения приёма MIC-185

**Запрос:** Пока идёт стендовый прогон, продумать более простой и понятный сбор данных, близкий к оригинальному Recorder.

**Сделано:** Код не менялся. Сопоставлены текущие `FillRxPacket/ReadPacket/ReadMeasDataBlock` и оригинальные `recv -> AcceptBlock -> Select`. Намечен единый накопительный буфер: принять доступный фрагмент TCP, сохранить неполный хвост, извлечь все целые пакеты, затем отдельно разобрать измерения, температуры и UTS.

**Проверка:** По исходникам оригинала подтверждено: один `recv` принимает произвольный блок, `Select` сдвигается на один байт при нарушении синхронизации и удаляет из накопителя только полный пакет.

**Статус:** Частично. После завершения текущего прогона реализовать рефакторинг без изменения командного обмена и проверить длительным стендовым тестом.
## 2026-08-12 — накопительный приём MIC-185

**Запрос:** По логу проверить общий отвал приборов и упростить код чтения, удаляя заменённые части.

**Сделано:** Подтверждён одновременный останов пяти потоков примерно через 97 секунд при пустых накопителях. Чтение переделано на `ReadAvailable -> TryTakePacket`; старое чтение до ожидаемого размера и лимит 512 пакетов удалены.

**Проверка:** Полная сборка `RecorderLnx.lpi` прошла, exit code 0. Подробности: `errors/2026-08-12-mic185-stream-stops.md`.

**Статус:** Код готов к стендовому прогону более 5 минут.
## 2026-08-12 — MIC-185: точный двухминутный останов и keep-alive

**Запрос:** определить момент остановки потока и причину, по которой Reset уже
не восстанавливает приборы.

**Сделано:** по предыдущему журналу все пять MIC-185 перестали отдавать байты
через 121,1–121,5 с после старта. В оригинальном Mebius найден 20-секундный
`QUERY_SESSION_STATE`; в RecorderLnx его не было. Добавлена неблокирующая
отправка keep-alive раз в 20 с без ожидания ответа и без потери DATA-пакетов.

**Проверка:** полная сборка `RecorderLnx.lpi` Win64, exit code 0.

**Статус:** частично — нужен аппаратный прогон более трёх минут после
перезагрузки приборов; подробности в `errors/2026-08-12-mic185-stream-stops.md`.
## 2026-08-12 — проверка счётчиков и накопителя MIC-185

**Запрос:** выяснить, связан ли останов потока с заполнением или уплотнением TCP-накопителя и как считаются пакеты.

**Сделано:** подтверждено, что каждый IP имеет отдельный сокет, накопитель и счётчики; `bytes` считается после чтения, `packets` — после выделения целого пакета, `data` — после распознавания измерительного пакета. Keep-alive убран из потока чтения: в свежем логе один источник задержался на 23 с и затем принял накопившиеся пакеты. В heartbeat добавлены `maxbuf` и `compact`.

**Проверка:** полная сборка `RecorderLnx.lpi` завершилась с exit code 0. Нужен аппаратный прогон; `compact=0` исключит уплотнение как причину напрямую.

**Статус:** частично; следующий шаг — прогон до сбоя и анализ новых полей heartbeat.
## 2026-08-12 — системный TCP keep-alive MIC-185

**Запрос:** настроить keep-alive согласно уточнению разработчика: его отправляет ОС через параметры сокета с периодом 5 секунд.

**Сделано:** прикладная Mebius-команда keep-alive удалена. При подключении включается `SO_KEEPALIVE`; Windows получает `keepalivetime=5000` и `keepaliveinterval=5000` через `WSAIoctl`, Linux — `TCP_KEEPIDLE=5`, `TCP_KEEPINTVL=5`, `TCP_KEEPCNT=3`.

**Проверка:** полная Win64-сборка `RecorderLnx.lpi` прошла, exit code 0. Требуется аппаратный прогон дольше двух минут.

**Статус:** частично; программная часть готова, ожидается стендовая проверка.
## 2026-08-12 — сверка TCP keep-alive MIC-185 с оригиналом

**Запрос:** найти фактическую настройку keep-alive в исходниках оригинального Recorder.

**Сделано:** в `TCPLink.cpp` подтверждены `SO_KEEPALIVE`, `keepalivetime=5000 мс`, `keepaliveinterval=1000 мс`. Число probe-попыток не меняется. Прикладной поток `QUERY_SESSION_STATE` для MIC-185 выключен: базовый `OnGetKeepAliveFlag()` возвращает `false`. RecorderLnx приведён к тем же значениям на Windows и Linux.

**Проверка:** исходники оригинала просмотрены в местах `CTCPLink::InternalConnect`, `CKeepAliveThread::Run`, `CBaseDevice::OnGetKeepAliveFlag`; выполняется повторная сборка.

**Статус:** готово на уровне кода; требуется стендовый прогон.
## 2026-08-12 — выход из настроек и безопасный старт MIC-185

**Запрос:** убрать долгую паузу после выхода из настроек без изменений и исключение `StartMeasurement: Mebius IoControl timeout` при переходе в просмотр.

**Сделано:** удалён повторный последовательный `TestLink` всех аппаратных источников после закрытия диалога; входная проверка связи сохранена. Для MIC-185 добавлен `TryStart`, а источник данных теперь обрабатывает отказ запуска как ошибку конкретного источника без возбуждения исключения в UI/отладчике.

**Проверка:** Win64-сборка `RecorderLnx.lpi` прошла, exit code 0. В стендовом прогоне парсер работал без потерь синхронизации (`buffered=0`, `syncdrop=0`), однако приборы по очереди закрыли TCP-соединения; это отдельная проблема сопровождения сеанса, не накопителя пакетов.

**Статус:** исправления диалога и безопасного старта готовы; устойчивость длительного обмена MIC-185 ещё исследуется.
## 2026-08-12 — короткий таймаут сброса MIC-185

**Запрос:** при недоступном MIC-185 завершать ручной сброс с понятной ошибкой за несколько секунд, а не ждать длинный повторный цикл.

**Сделано:** TCP connect и ответ команды ограничены двумя секундами, ожидание готовности транспорта сокращено до 250 мс; повтор `disconnect → delay → connect → IoControl` после первого явного timeout удалён.

**Проверка:** полная компиляция исходников прошла; линковка нового EXE заблокирована запущенным RecorderLnx (`error code 5`).

**Статус:** код готов; после закрытия приложения требуется повторная сборка и стендовая проверка сброса.
## 2026-08-12 — исправлена семантика ручного сброса устройств

- Запрос: сброс должен восстанавливать связь как в оригинальном Recorder и не
  заставлять перезагружать MIC-185.
- Сделано: reset теперь выполняет `Stop -> TestLink`; исправная TCP-сессия
  сохраняется, а `Disconnect` вызывается только после неудачного TEST.
- Добавлен один резервный цикл пересоздания транспорта, если Initialize попал
  в полузакрытую сессию.
- Проверка: все исходники скомпилированы; линковка EXE заблокирована запущенным
  RecorderLnx (`error code 5`). Стендовый reset ещё требуется проверить.

## 2026-08-12 — разбор MEBE-пакетов MIC-185 приведён к оригиналу

- Восстановлена логика `CPacketCollector`: полный 32-битный размер имеет
  приоритет, 16-битный размер используется только для старого формата.
- Ошибка сигнатуры/CRC сдвигает поиск на один байт, неполный пакет остаётся в
  накопительном буфере, после успеха удаляется ровно целый пакет.
- Размер одного TCP-чтения ограничен оригинальными 2 МиБ при буфере 4 МиБ.
- Полезная нагрузка измерений не менялась.
- `lazbuild -B RecorderLnx.lpi` завершён успешно; требуется длительный стенд.

## 2026-08-12 — Shift-выделение устройств

- Дерево аппаратной конфигурации теперь использует `msShiftSelect` и выделяет
  диапазон видимых узлов между опорным и нажатым узлом.
- Ctrl-выделение отдельных узлов сохранено.
- Контрольная полная сборка и линковка под отдельным именем прошли успешно;
  штатный EXE удерживался запущенным RecorderLnx.

## 2026-08-12 — аудит программирования MIC-185 и останов через 121 секунду

- Запрос: проверить, не заполняется ли память прибора из-за неверного
  программирования аппаратных блоков.
- Подтверждено `BlockSize=20` при 100 Гц и периоде 200 мс. До остановки каждый
  прибор выдаёт ожидаемые 50 блоков за 10 секунд и 100 блоков за 20 секунд.
- Проверка первичного исходника уточнила: общий Mebius поддерживает
  `IOCTL_MEASTASK_QUERY_SESSION_STATE`, но MIC185v2 наследует
  `OnGetKeepAliveFlag() = false`. Поэтому экспериментальный запрос не оставлен.
- Полная сборка `RecorderLnx.lpi` под Win64 прошла. Следующий аудит должен
  сравнить весь `ProgramDeviceBin` и порядок `Program/Start` с MIC185v2.
## 2026-08-12 — переносимый захват трафика MIC-185

**Запрос:** подготовить переносимую утилиту для записи и сравнения полного сетевого цикла одного MIC-185 в RecorderLnx и оригинальном Recorder.

**Сделано:** добавлен комплект `Tools/Mic185TrafficCapture`: захват `pktmon` по IP/порту на всех сетевых картах, ручные метки init/reset/start/data/service/stop, фиксация выбранного Windows-маршрута, PCAPNG/ETL/hex/CSV и анализ Mebius/IOCTL.

**Проверка:** PowerShell-скрипты разобраны штатным parser API; Python-модули прошли `py_compile`; PCAPNG MIC-140 из прежнего исследования успешно преобразован в 805 строк, сравнительный отчёт сформирован. Реальный MIC-185-захват ещё не выполнялся.

**Статус:** утилита готова к переносу и двум стендовым захватам; после них требуется проверить фактические сигнатуры MIC-185 и сравнить жизненные циклы.
## 2026-08-12 — исправлен self-test захвата MIC-185

**Запрос:** самостоятельно запускать утилиту, читать лог и исправлять до рабочего результата.

**Сделано:** штатный ответ `pktmon stop` больше не обрывает подготовку; self-test создаёт контрольное
TCP-соединение, а обычный захват остаётся пассивным. Исправлена подпись MIC-185 в timeline.

**Проверка:** elevated-прогон дал exit code 0, 7 пакетов и полный набор ETL/PCAPNG/CSV/report.

**Статус:** готово.
## 2026-08-12 — записан трафик RecorderLnx с MIC-185

**Запрос:** самостоятельно записать сетевой обмен RecorderLnx с MIC-185.

**Сделано:** выполнен пассивный PktMon-захват `192.168.9.155:4000`; RecorderLnx автоматически
прошёл Preview 15 секунд и завершил Stop/Disconnect.

**Проверка:** оба процесса завершились с exit code 0; получено 583 пакета, 429420 байт DEV→PC,
распознаны configure, reset/session, start, поток блоков, stop и disconnect без retransmit.

**Статус:** готово; дамп `captures/192.168.9.155_recorderlnx_full_cycle_20260812_194753.*`.

## 2026-08-12 — отображение alive в дампе MIC-185

**Запрос:** отдельно показывать служебные команды alive в отчёте захвата трафика.

**Сделано:** анализатор различает прикладные `query_session` как `alive_request`/`alive_response` и системные TCP keep-alive probe по признаку `SEQ = SND.NXT - 1`. В отчёт добавлен отдельный раздел Alive / keep-alive; обычные ACK и 84-байтные служебные данные alive не считаются.

**Проверка:** повторно разобран полный дамп RecorderLnx; анализатор завершился без ошибок. В 15-секундном интервале обнаружено 0 `query_session` и 0 TCP probe, что явно отражено в отчёте.

**Статус:** готово; для наблюдения 20-секундного прикладного таймера нужен более длинный захват.
## 2026-08-13 — сравнение дампов Recorder и RecorderLnx для MIC-185

**Запрос:** найти различие настроек MIC-185 при 100 Гц и периоде данных 200/300 мс, объясняющее останов связи примерно через 1 мин 35 с.

**Сделано:** исправлена расшифровка вложенных `CALL_COMMAND` в анализаторе; сопоставлены транспорт, команды, жизненный цикл и сбросы. Подтверждено совпадение ритма пакетов, размера блока, TCP keep-alive и сборки TCP-потока. Полный сброс RecorderLnx отличается лишними переподключениями. `ProgramDeviceBin` 3976 байт отсутствует в дампах обеих программ, поэтому сравнить основной блок настроек по этим записям нельзя. Результат записан в `Tools/Mic185TrafficCapture/captures/COMPARISON_2026-08-13.md` и документацию протокола.

**Проверка:** анализатор успешно повторно обработал четыре захвата. Ни один захват RecorderLnx не содержит сам момент отказа: максимальный активный поток около 48 с, поэтому точная причина 95-секундного останова пока не доказана.

**Осталось:** записать текущий RecorderLnx от холодного подключения до отказа не менее 130 с и проверить наличие `ProgramDeviceBin`, TCP FIN/RST/retransmit/zero-window и последний полный Mebius-пакет.

**Статус:** анализ завершён, требуется захват самого отказа.

## 2026-08-13 — быстрый автопоиск аппаратуры по broadcast

**Запрос:** сделать автопоиск аналогичным оригинальному Recorder: быстро находить MIC-140 и MIC183/185 по broadcast, а поиск через ping/TCP scan включать только отдельной галочкой справа от кнопки автопоиска.

**Сделано:** в `uRecorderSettingsDialog.HardwareSearchClick` обычный путь теперь останавливается на broadcast-ответах MIC-140/MIC183/185 и не запускает полный обход подсети. Справа от кнопки автопоиска добавлена выключенная по умолчанию галочка `Ping`; если ее включить, выполняется старый TCP scan порта 4000, но идентифицируется только MC-032.

**Доправлено после стендового симптома:** если RecorderLnx писал, что поддерживаемые устройства не найдены, а оригинал видел `MIC-140-48v3`, причина была в распознавании modern broadcast-ответа. Порт ответа 4401 подтвержден оригинальным `EthernetBus` (`DETECTION_PORT + 1`), но `dev_type_` надо сравнивать с точными кодами из `devapi/Const.h`: например `MIC140_48V3_TYPE = $4140`. Старая маска `(dev_type shr 16) and $1ff` для `$4140` давала 0, поэтому MIC-140 отбрасывался. В `uRecorderNetworkBinding.RecorderDiscoverMeraBroadcast` добавлены exact-типы MIC-140/MIC183/MIC185 и чтение IP из поля `ip_` ответа.

**Проверка:** сверено с оригинальными исходниками `rc_guisrv/setup/SearchMdqDev.cpp`, `Mebius/MebiusDAQ/DAQ/EthernetBus/EthernetBus.cpp`, `Mebius/MebiusDAQ/DAQ/EthernetBus/DetectDeviceInfo.h`, `devapi/Const.h`, `mdpEthernet81/ethernet81bus.cpp`. Оригинал использует SearchDevices/WaitSearchDevices и broadcast timeout 5000/3000 мс, а не постоянный полный обход подсети. `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` завершился с exit code 0 и слинковал `RecorderLnx.exe`; post-build `copy_sdb_res.bat` отдельно ругается на `#!/bin/sh`, но сборку не ломает.

**Статус:** код готов к стендовой проверке: обычный автопоиск должен быть быстрым broadcast-only для MIC-140/MIC183/185, `Ping` включает медленный MC-032 scan.
## 2026-08-13 16:25 - MIC-140 autosearch regression fixed

**Symptom:** after the `CCSerNo_` change, UI autosearch stopped showing MIC-140 and showed only MIC183/185.

**Fix:** legacy `MERA:Eth81Srch` replies are accepted from `24` bytes again, so `DevType_` and `SerialNo_` can be parsed. `CCSerNo_` at offset `26` is now optional and read only when the reply is at least `28` bytes. This restores MIC-140 discovery without accepting non-MIC-140 types, because type filtering still uses `DevType_`.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` exit code 0.

## 2026-08-13 16:05 - MIC-140 autosearch serial source corrected

**Request:** after UI test, RecorderLnx found only real MIC-140 hosts `.14.40/.41/.42`, but displayed `SN=4574/4575/4576`; user asked whether MIC-140, like MIC-185, may send the display serial through another broadcast field.

**Done:** checked original `D:\works\windev-v3.9\mdpEthernet81\ethernet81bus.cpp` and `mdpEthernet81.cpp::SearchDLL`. Legacy discovery packet contains both `SerialNo_` and `CCSerNo_`; original Recorder registers the found MIC-140 device with `pDevInfo->SerialNo = DevInfo.Route.Location.EthernetSlot.CCSN`, i.e. `CCSerNo_`. RecorderLnx broadcast and directed legacy MIC-140 discovery now display `CCSerNo_` from offset `26`, with fallback to `SerialNo_` offset `22` only if `CCSerNo_` is zero.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` exit code 0. Expected next UI autosearch for `.14.40/.41/.42`: `SN=328/326/327`.

## 2026-08-13 17:05 - MIC-140 fallback when broadcast is zero

**Request:** UI autosearch still showed only MIC183/185; continue debugging until MIC-140 appears normally.

**Done:** `LogWindows.log` showed `broadcast: 0 device(s)` and then real `.14.40/.41/.42` were skipped because the fallback used directed legacy UDP. Added strict TCP MIC-140 fallback: `RecorderMic140QueryDeviceInfoWithTimeout(...)` reads firmware with `REPLY(113)` and accepts only known MIC-140 `DevType`; `HardwareSearchClick` now probes MIC183/185 first, then MIC-140 by this strict firmware check, with directed legacy UDP left as an extra path.

**Verification:** `RecorderLnx.lpi` rebuild exit code 0. Independent read-only TCP probe confirmed `.14.40/.41/.42` reply with `DevType=$4141`, version `14.1.8.1`, `CCSerNo=326/327/328`; false `.13.24` replies with `DevType=$412C` and should be rejected.

**Expected next UI result:** even when broadcast returns 0, autosearch should add real MIC-140 `.14.40/.41/.42`, while `.13.*` should not appear as MIC-140.

## 2026-08-13 17:35 - MIC-140 autosearch verified with strict TCP fallback

**Request:** continue debugging autosearch until real MIC-140 devices appear normally and false devices are not classified as MIC-140.

**Done:** stopped the running `RecorderLnx.exe`, rebuilt the main UI, rebuilt `Tests\HardwareSearchDebug`, and verified broadcast plus strict TCP MIC-140 info probing. MIC-140 serial for fallback now comes from `Mic140v2HardwareCalibrSerial`, matching the original Recorder-compatible `CCSerNo`/calibration serial instead of `DevSerNo`.

**Verification:** `RecorderLnx.lpi` build exit code `0`; `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5200 --tcp-scan --mic140-info` found `192.168.14.40 SN=326`, `.41 SN=327`, `.42 SN=328`, rejected MIC183/185 and false `192.168.13.24` as `not_mic140`.

**Status:** code is ready for UI autosearch check in the freshly rebuilt RecorderLnx.

## 2026-08-13 18:00 - default autosearch made fast again

**Request:** user reported that current autosearch became very slow.

**Done:** removed the ARP/TCP MIC fallback from the default button path and reduced UI broadcast wait from `5200 ms` to `1800 ms`. The slow ARP/TCP path now runs only when the `Ping` checkbox is enabled; it can probe MIC183/185, strict MIC-140 firmware info, and MC-032 there.

**Verification:** `RecorderLnx.lpi` build exit code `0`; standalone `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=1800` finished in about `1.7 s` and found MIC-140 `.14.40 SN=326`, `.14.41 SN=327`, `.14.42 SN=328`.

**Status:** fresh `RecorderLnx.exe` launched. Default autosearch should be fast; `Ping` intentionally enables slow TCP-assisted search.

## 2026-08-13 18:35 - default autosearch aligned with original broadcast logic

**Request:** user clarified that original Recorder searches devices by broadcast request and response parsing only; no ping, no direct per-address probing, no TCP scan in the normal path.

**Done:** checked original `EthernetBus.cpp` and `ethernet81bus.cpp`. RecorderLnx broadcast discovery now opens listeners on `4401/4002`, sends modern request from local UDP `4400` and legacy request from local UDP `4001` to `255.255.255.255`, using the selected bind IP or all local IPs like the original. Default UI search remains broadcast-only for MIC-140 and MIC183/185; probing stays only behind explicit diagnostic/`Ping` mode.

**Verification:** standalone broadcast-only check at `--bind=192.168.3.65 --timeout-ms=1800` found MIC-140 `.14.40 SN=326`, `.14.41 SN=327`, `.14.42 SN=328`, `.14.30 SN=286` plus MIC183/185. Main `RecorderLnx.lpi` build exit code `0`; fresh `RecorderLnx.exe` launched.

**Status:** next manual check is the UI Autosearch button in the opened RecorderLnx. If it returns zero while the standalone broadcast finds devices, investigate UDP receive/firewall/process binding, not ping fallback.
## 2026-08-13 16:30 - MIC autosearch GUI diagnostics

**Запрос:** Довести автопоиск RecorderLnx до поведения оригинального Recorder: быстрый broadcast-only поиск MIC-140/MIC185 без ping/TCP scan по умолчанию.

**Сделано:** default autosearch оставлен broadcast-only; для выбранного адаптера добавлен limited broadcast `255.255.255.255` и directed broadcast подсети; listener ставит `SO_REUSEADDR` + `SO_BROADCAST`; warmup поднят до `3000 ms`; кнопка автопоиска пишет отдельный `lib\x86_64-win64\hardware-search-ui.log`.

**Проверка:** `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5000` находит MIC-140 `14.40/14.41/14.42/14.30`, но fresh GUI warmup пока получает `0`; сборка `RecorderLnx.lpi` успешна.

**Статус:** частично. Следующий шаг: нажать UI-кнопку автопоиска и сравнить `hardware-search-ui.log` с working diagnostic log; проблема сейчас локализована в main GUI process/path, не в маршруте и не в приборах.
## 2026-08-13 16:45 - HardwareSearchDebug .lpi and broadcast recheck

**Запрос:** добавить все используемые модули в проект `Tests\HardwareSearchDebug`, чтобы они отображались в Lazarus Project Inspector, и продолжить удерживать автопоиск MIC-140/MIC185 на оригинальном broadcast-only пути.

**Сделано:** создан `D:\works\OburecGH\Lazarus\RecorderLnx\Tests\HardwareSearchDebug\HardwareSearchDebug.lpi` со списком диагностического `lpr` и используемых RecorderLnx core/device/MIC140/SDB/shared units. В `uRecorderNetworkBinding.pas` исправлен порядок аргументов `Format(...)` в debug-log и default discovery оставлен на original-style отправке: listener `4401/4002`, одноразовый sender с локального IP `4400/4001`, broadcast на `255.255.255.255`.

**Проверка:** `lazbuild -B HardwareSearchDebug.lpi` exit code 0. Запуск внутри sandbox дал `broadcast_found=0`, но тот же exe вне sandbox вернул `broadcast_found=10`, включая MIC-140 `192.168.14.40 SN=326`, `.14.41 SN=327`, `.14.42 SN=328`, `.14.30 SN=286`; ложные `.13.*` не добавлены. Main `RecorderLnx.lpi` после остановки запущенного exe собран с exit code 0.

**Статус:** проект инспектора готов; свежий GUI можно запускать для ручной проверки Autosearch. Подробности и гипотезы: `errors/2026-08-13-hardware-autosearch-broadcast-only.md`.
## 2026-08-13 19:10 - GUI autosearch external broadcast fallback

**Request:** user showed that RecorderLnx UI autosearch still reports no supported devices, while the original Recorder finds MIC-140 quickly. Keep default behavior aligned with original broadcast request/response discovery and do not fall back to ping/TCP scan by default.

**Done:** added a narrow fallback in `UI/uRecorderSettingsDialog.pas`: when the GUI's in-process `RecorderDiscoverMeraBroadcast(...)` returns 0, it runs the already-built `Tests\HardwareSearchDebug\HardwareSearchDebug.exe` with the same bind and parses only broadcast result lines for `MIC-140` and `MIC183/185`. `arp=` and other diagnostic lines are ignored; the `Ping` checkbox path remains separate.

**Verification:** rebuilt `HardwareSearchDebug.lpi` and `RecorderLnx.lpi`, both exit code 0. Standalone helper with `--bind=192.168.3.65 --timeout-ms=5000` returned `broadcast_found=15`, including MIC-140 `192.168.14.40 SN=326`, `.14.41 SN=327`, `.14.42 SN=328`, `.14.30 SN=286`.

**Status:** ready for manual UI check in freshly built RecorderLnx. Expected log if in-process broadcast still fails: `in-process broadcast returned 0; trying external broadcast helper`, then `external broadcast helper: 15 device(s)`.

## 2026-08-13 19:25 - autosearch marks already added devices

**Request:** in the found-devices dialog, devices already present in RecorderLnx must be marked as already added and unchecked by default.

**Done:** expanded `HardwareSearchClick.IsConfigured(...)` in `UI/uRecorderSettingsDialog.pas`. It now checks configured data sources, linked tags, active source ids, runtime data sources, and live hardware sessions before calling `TRecorderDeviceSearchDialog.AddDevice(...)`.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` exit code `0`.

**Status:** fresh UI check needed; expected rows for existing devices should show `(уже добавлено)` and have unchecked boxes.

## 2026-08-13 19:45 - autosearch already-added check corrected to IP

**Request:** user corrected the previous implementation: do not use tags to decide whether a found device is already added; determine it by device IP.

**Done:** `HardwareSearchClick.IsConfigured(...)` now parses host/IP from found MIC-140, MIC183/185, and MC-032 source ids and compares it with IPs from configured source ids plus the current hardware tree nodes. Tag-linked, active-source, runtime-data-source, and live-session checks are intentionally not used for this dialog rule.

**Verification:** after stopping the running `RecorderLnx.exe` that locked the output, `RecorderLnx.lpi` rebuilt with exit code `0`.

**Status:** next UI check should show rows with already configured IPs as `(уже добавлено)` and unchecked.

## 2026-08-13 20:05 - autosearch already-added IP detection fixed for real endpoints

**Request:** user showed that already read/connected sources still were not detected in the found-devices dialog.

**Done:** fixed the IP comparison source. For MIC-140, configured host is now resolved through `RecorderMic140ResolveEndpoint(...)`, so `mic140.host` is used even when the stored `SourceId` is stale. As a fallback, the hardware tree row text is scanned for IPv4 and compared with the found device IP.

**Verification:** first rebuild was blocked by running `RecorderLnx.exe` PID `9416`; after stopping it, `RecorderLnx.lpi` rebuilt with exit code `0`.

**Status:** fresh UI check should mark found rows whose IP already exists in the hardware tree as `(уже добавлено)` and uncheck them.
## 2026-08-13 20:55 - MIC-140 channel names include IP

**Request:** change MIC-140 channel/tag naming to be close to MIC185, requested as `140-ip-#кан`.

**Done:** in `UI/uRecorderSettingsSourceProbe.pas`, `BuildMic140` now names analog signals as `140-{<full_ip_with_underscores>-<channel>}` and temperature signals as `140-{<full_ip_with_underscores>-tN}`. After `MeraSignalToRecorderTagName`, tags become e.g. `140_{192_168_14_40_1}` and `140_{192_168_14_40_t1}`. Hardware addresses remain unchanged (`2-01`, `2-t1`).

**Verification:** first rebuild was blocked by running RecorderLnx processes; after stopping PID `1588` and `12776`, `RecorderLnx.lpi` rebuilt with exit code `0`.

## 2026-08-13 20:35 - MIC-140 endpoint and duplicate tag name fixes

**Request:** user showed MIC-140 rows in hardware tree as `MIC-140 (:0)`, MIC-140 settings with empty IP/Port 0, and `Tag name already exists: MIC140_01` when adding tags.

**Done:** fixed `UI/uRecorderSettingsDialog.pas`. `ApplyConfiguredSourceChange` now fills missing MIC-140 config Host/Port from parsed SourceId before `BuildMic140`. `CreateSelectedMeraTags` now uses a unique suffix (`_2`, `_3`, ...) if generated tag name is already occupied by another source.

**Verification:** `RecorderLnx.lpi` rebuilt with exit code `0`; known post-build `#!/bin/sh` message remains after link.

**Status:** next UI check should show MIC-140 as `MIC-140 (IP:4000)`, properties should have IP/Port filled, and selected tag creation should not abort on `MIC140_01`.

## 2026-08-13 20:20 - MIC-140 autosearch add now builds available channels

**Request:** user added MIC-140 via autosearch; devices appeared in hardware tree, but available tags/channels did not appear. After OK and reopening settings, MIC-140 devices disappeared from the tree.

**Done:** fixed `UI/uRecorderSettingsDialog.pas`. Broadcast MIC-140 rows now carry parsed serial number into the found-device item and store it through `RecorderMic140SetDeviceSerialForSource`. `ApplyConfiguredSourceChange` now mirrors restore-time behavior and calls `BuildMic140(..., MIC140DefaultChannelCount, nil, [])` when no private MIC-140 config exists yet.

**Why:** `OkButtonClick` calls `fSourceProbe.SyncToRegistry`; that method preserves only sources present in probe signal groups. Autosearch could create a configured MIC-140 without building its signals, so `SyncToRegistry` removed it as undesired.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code `0`. Existing post-build `copy_sdb_res.bat` still prints the known `#!/bin/sh` Windows error after link.

**Status:** next UI check should show MIC-140 available channels immediately after autosearch add, and MIC-140 should remain in the tree after OK/reopening settings.

## 2026-08-13 21:20 - autosearch external helper removed from UI

**Request:** user noticed a console window flash during Autosearch and correctly pointed out that launching a separate Windows exe from RecorderLnx will create cross-platform/package problems.

**Done:** removed the `HardwareSearchDebug.exe` fallback from `UI/uRecorderSettingsDialog.pas`. The settings UI now uses only the in-process `RecorderDiscoverMeraBroadcast(...)` path for default MIC-140/MIC183/185 autosearch. `Process` unit dependency and helper-launch/parsing routines were removed from the dialog.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code `0`.

**Status:** no console window should flash from Autosearch anymore. `Tests\HardwareSearchDebug` remains a standalone diagnostic project only, not a runtime dependency of RecorderLnx UI.

## 2026-08-13 21:35 - autosearch repeats debug recovery internally

**Request:** after removing the external helper, UI still reported no devices. User asked to repeat the procedure from the console debug tool inside RecorderLnx.

**Done:** `UI/uRecorderSettingsDialog.pas` now runs built-in ARP/TCP MIC recovery when broadcast returns 0. It uses `RecorderEnumerateArpIPv4(...)` like `Tests\HardwareSearchDebug`, then `RecorderFindOpenTcpHosts(...)`, then strict `ProbeMic185` / `ProbeMic140` identification. MC-032 probing remains only behind the `Ping` checkbox. No external exe is launched.

**Verification:** `RecorderLnx.lpi` rebuilt with exit code `0`; fresh `RecorderLnx.exe` launched from `lib\x86_64-win64`.

**Status:** next UI autosearch should log `internal ARP/TCP MIC recovery will run` if broadcast is still zero, and should populate MIC-140/MIC183/185 from the ARP/TCP recovery path.
## 2026-08-13 21:20 - Restore zero-broadcast internal MIC recovery

**Request:** after the previous speed/SN fix, autosearch again found no devices.

**Done:** logs confirmed UI broadcast returned `0` and the previous change skipped ARP/TCP recovery because `Ping` was off. Restored internal recovery when `broadcast=0`: use ARP candidates + TCP/4000 + strict MIC183/185/MIC-140 protocol identification. No external helper process is used; MC-032 remains behind `Ping`.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` exit code `0`; stopped old `RecorderLnx.exe` PID `15152` before linking.

## 2026-08-13 22:10 - broadcast listener bound to selected adapter

**Request:** after UI still did not find devices, user asked whether the problem could be adapter selection and where the working utility binds sockets.

**Done:** verified `HardwareSearchDebug.exe --bind=192.168.3.65` uses the same `RecorderDiscoverMeraBroadcast(...)` path as UI after setting the global bind IP. Changed `Core\uRecorderNetworkBinding.pas`: UDP reply listeners now bind to the configured adapter IP (`192.168.3.65:4401/4002`) instead of always `0.0.0.0`; if that fails, code logs the WSA error and falls back to wildcard.

**Verification:** rebuilt both `RecorderLnx.lpi` and `Tests\HardwareSearchDebug\HardwareSearchDebug.lpi`, exit code `0`. Real-network run `HardwareSearchDebug.exe --bind=192.168.3.65 --timeout-ms=5000` returned `broadcast_found=15`, including MIC-140 `.14.40 SN=326`, `.14.41 SN=327`, `.14.42 SN=328`, `.14.30 SN=286`.

**Status:** fresh UI check should show listener bind lines and then broadcast replies. If UI still shows zero while diagnostic finds 15, compare UI process timing/state against the diagnostic, not parser/route.

## 2026-08-13 21:05 - MIC-140 autosearch caption SN and speed

**Request:** autosearch worked but took too long, and added MIC-140 rows in the hardware tree did not show serial numbers.

**Done:** `Core/uRecorderHardwareTree.pas` now prints `SN` for MIC-140 source captions when `DeviceSerial` is stored. `UI/uRecorderSettingsDialog.pas` default autosearch uses `1800 ms` broadcast and does not run ARP/TCP recovery unless the `Ping` checkbox is enabled. Optional Ping/TCP MIC185/MIC140 identification timeout is reduced to `500 ms` per host.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` exit code `0`; running `RecorderLnx.exe` PID `20320` was stopped before linking.
## 2026-08-13 19:15 - autosearch broadcast fixed for GUI exe

**Request:** user reported that the normal RecorderLnx autosearch still found nothing, while the original Recorder and the debug utility found MIC-140 devices quickly by broadcast.

**Done:** fixed `Core/uRecorderNetworkBinding.pas` so discovery now sends modern/legacy search packets from the reply sockets too (`4401 -> 4400`, `4002 -> 4001`) before the older original-style `4400/4001` sends. This keeps broadcast-only discovery inside RecorderLnx and avoids external helper/TCP fallback in the default path.

**Verification:** temporary GUI-built debug executable changed from `broadcast_found=0` to `broadcast_found=15`. Fresh `RecorderLnx.exe --hardware-search-test --bind=192.168.3.65 --timeout-ms=5000` now returns `found=15`, including MIC-140 `192.168.14.42 SN=328`, `.14.30 SN=286`, `.14.40 SN=326`, `.14.41 SN=327`; non-MIC-140 `192.168.13.223 type=$412C` remains filtered out. `RecorderLnx.lpi` rebuild exit code `0`.

**Status:** ready for UI button check in freshly launched RecorderLnx; expected autosearch time is about the broadcast receive window, no console helper should appear.

## 2026-08-13 22:35 - MIC-140 channel names use last IP octet

**Request:** in MIC-140 channel/tag names keep only the last 3 digits/octet from the IP, e.g. avoid `140-{192_168_14_41-46}`.

**Done:** `UI/uRecorderSettingsSourceProbe.pas` now builds MIC-140 auto-created channel names from the last host segment only. For `192.168.14.41` generated names become `140-{41-46}`, `140-{41-t1}`, etc. The code also handles empty host as `unknown`.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` exit code `0`; running `RecorderLnx.exe` PID `16816` was stopped before linking.

## 2026-08-13 23:05 - MIC-140 runtime diagnostic tag cleanup

**Request:** user pointed out an error after some runtime and runtime-rule violations in `PublishDiagnostics`: changing `Description`, setting string `TextValue`, and searching tags by name during work.

**Done:** added `TRecorderTagRegistry.PublishValue(ATag, ...)` so hot code can publish through a cached tag pointer. `Device\MIC140\uRecorderMic140DataSource.pas` now caches status/block diagnostic tags during `DoCreateTags` and `BuildRuntimeCache`, publishes status and block counters through cached `TRecorderTag`, and no longer assigns `TextValue` or mutates status `Description` in runtime. MIC-140 temperature diagnostics also stopped assigning `TextValue` manually; the tag updates its numeric text from samples.

**Verification:** `rg` confirms MIC-140 `FindByName` remains only in setup/cache creation and no `TextValue` assignments remain in the MIC-140 data source. `RecorderLnx.lpi` rebuild exit code `0`; `RecorderDataSourcesTest.exe` exit code `0`.

**Details:** runtime investigation notes are in `errors/2026-08-13-mic140-runtime-diagnostic-tags.md`.

## 2026-08-13 23:35 - MIC-185 reset handles TCP-open/Mebius-timeout state

**Request:** user reported MIC-185 devices ping/TCP-ping successfully, but the hardware tree still shows errors; "reset all" did not help. User noted this did not happen before MIC-140 work, so common network/lifecycle changes needed checking.

**Done:** logs show broadcast discovery and TCP connect are OK through `Ethernet 2 [192.168.3.65]`, but first MIC-185 Mebius `GetSoftVersion/read SN` fails on every device with `Mebius IoControl timeout`. Added `REC_IOCTL_MEASTASK_DO_CLEANUP` / `TryCleanupMeasurementTask`, and MIC-185 manual reset now tries a soft Mebius task cleanup before `PrepareHardwareAll`. If reset still leaves a MIC-185 source offline with `IoControl timeout`, the reset dialog adds a direct power-cycle hint: TCP port is open, but the device Mebius task is not answering commands.

**Verification:** first `RecorderLnx.lpi` rebuild reached link but failed because running `RecorderLnx.exe` PID `7016` locked the output. After stopping it, rebuild completed with exit code `0`. Existing Windows post-build `#!/bin/sh` message remains non-blocking.

**Status:** fresh hardware check needed. If reset log shows `cleanup OK` and then `initialize OK`, power cycling was avoided. If it still shows `Mebius IoControl timeout`, reboot/power-cycle MIC-183/185 hardware.
## 2026-08-13 20:35 - MIC-140 source-only add no longer creates user tags or crashes calibration transform

**Request:** after adding MIC-140 devices by auto-search and pressing OK, the user re-opened settings and got MIC-140 source errors/crash near `TRecorderTagRegistry.TransformTagValue`; the user did not create channel tags.

**Done:** fixed MIC-140 `DoCreateTags` so an empty selected-tag list means no user measurement tags are created for source-only add. Internal MIC-140 status/block diagnostic tags are numeric and have calibration disabled. Cached runtime tag pointers are validated with `TRecorderTagRegistry.ContainsTag`; stale cached tags are ignored by publish paths. Calibration transform/save/load paths now guard nil tag/calibration lists. Detailed history: `errors/2026-08-13-mic140-source-only-tag-crash.md`.

**Verification:** `RecorderLnx.lpi` rebuilt with exit code 0. Live hardware communication was not checked in this pass because the user turned the devices off.

**Status:** ready for UI retest with devices powered on. Expected: auto-search can add MIC-140 sources without creating 48+3 user tags, re-entering settings and opening source properties does not crash; offline/error icons are expected while devices are off.

## 2026-08-14 10:40 - Project path persists after Save As / restart

**Request:** user saved config under `C:\Mera Files\RecorderLnx\config\projects\002`, restarted RecorderLnx, but the title still pointed to `D:\works\OburecGH\Lazarus\RecorderLnx\config\projects\default`.

**Done:** fixed `UI/uMainForm.pas` startup so it reads `[Application] DefaultProjectConfigDir` from app config instead of hardcoding `projects/default`. `Save As` and `Load From` now write the selected project dir back to `app.ini`. When `RecorderConfigPath` is empty, app config now falls back to `RecorderServicePath\config`, not the build-tree `GetDevProjectDir\config`. Updated real `C:\Mera Files\RecorderLnx\config\app.ini` to `DefaultProjectConfigDir=projects/002`.

**Verification:** `RecorderLnx.lpi` rebuilt with exit code `0`; old running `RecorderLnx.exe` was stopped before linking. Detailed hypothesis log: `errors/2026-08-14-project-config-default-path.md`.

## 2026-08-14 11:15 - Reset all devices no longer runs full prepare in modal UI

**Request:** user reported that "reset all devices" in hardware settings stayed busy for more than a minute; after it returned only one MIC-185 recovered, although other devices ping.

**Done:** `UI/uRecorderSettingsDialog.pas` no longer calls `DataSources.PrepareHardwareAll` synchronously after reset-all or retry. The reset command now releases/marks device reset requests and refreshes the tree quickly; actual Connect/Initialize/Configure is left to the normal data-source lifecycle. Successful reset tasks clear stale offline flags, while new protocol failures will be recorded on the next real prepare.

**Verification:** first rebuild failed only because running `RecorderLnx.exe` PID `21472` locked the exe; after stopping it, `RecorderLnx.lpi` rebuilt with exit code `0`. Detailed hypothesis log: `errors/2026-08-14-hardware-reset-all-blocks-ui.md`.
## 2026-08-14 11:23 - MIC-140 channel addresses now include device node

**Request:** user showed MIC-140 selected tags from different devices with identical addresses like `2-38`, while names contained different IP octets (`140_{30_38}`, `140_{41_38}`). Address must include the node number; the tree must not have two nodes with the same index.

**Done:** added MIC-140 node helpers based on the last IPv4 octet and used them in the source probe, runtime `TRecorderMic140Device`, datasource diagnostic setup, and MIC-140 source dialog. Existing old `2-*` tags are migrated by matching channel number inside the same `SourceId`, including when MIC-140 source properties are confirmed with OK, so `.30 ch38` becomes `30-38` and `.41 ch38` becomes `41-38`.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` exit code `0`; first link attempt was blocked by a running `RecorderLnx.exe`, then succeeded after stopping only that process. Details: `errors/2026-08-14-mic140-duplicate-node-addresses.md`.
## 2026-08-14 12:05 - Settings exit no longer prepares changed hardware while stopped

**Request:** user reported that leaving Settings and returning to the main screen is very slow, and asked whether RecorderLnx has `ecm/lcm` (`EnterConfigMode`/`LeaveConfigMode`) like the original.

**Findings:** original Recorder has explicit `ecm/lcm` console commands and `EnterConfigMode`/`LeaveConfigMode` API in `mr/rcmain.cpp`; RecorderLnx has no literal ECM/LCM API, only distributed settings-dialog logic. `OkButtonClick` does not call `PrepareHardwareAll`, but changed sources went through `RecorderReplaceRuntimeSource`, whose manager-level `ReplaceSource` synchronously called `PrepareHardware` even in stopped mode.

**Done:** added an `APrepareNow` flag through `TRecorderDataSourceManager.ReplaceSource` and `RecorderReplaceRuntimeSource`. `TMainForm.btnSettingsClick` now prepares replacement hardware immediately only when the data-source manager is already running; in Stop mode settings exit only rebuilds changed runtime source objects and defers device connect/programming until Preview/Record or explicit preparation.

**Verification:** first rebuild was blocked by running `RecorderLnx.exe` PID 5212; after stopping it, `RecorderLnx.lpi` rebuilt with exit code 0. Detailed notes: `errors/2026-08-14-settings-exit-slow-ecm-lcm.md`.
## 2026-08-14 — Preview не должен программировать железо

**Запрос:** первый переход в просмотр занял около 30 секунд, повторный переход был быстрым. Пользователь уточнил правило жизненного цикла: `HardPrepare` должен выполняться при применении конфигурации только для измененных приборов; в Preview программировать ничего нельзя; подготовка приборов должна идти параллельно, чтобы тайминги ожидания не складывались.

**Сделано:** по `C:\Mera Files\RecorderLnx\LogWindows.log` подтверждено `Data sources started in 25953 ms` на первом Preview и `15 ms` на повторном. В `Core/uRecorderDataSources.pas` добавлен флаг `Prepared` в контекст источника; `PrepareHardwareAll` теперь готовит только pending/reset источники, а `StartAll` больше не вызывает `PrepareHardware`. В `Core/uRecorderHardwareLiveDevices.pas` добавлена неразрушающая проверка pending reset. В `UI/uMainForm.pas` Apply/OK заменяет измененные runtime sources без одиночного prepare, синхронизирует enabled и затем вызывает общий prepare для changed/pending. В `Device/MIC185/uRecorderMic185DataSource.pas` снята глобальная сериализация connect/init/config; lock оставлен только вокруг записи identity в общий registry.

**Проверка:** первый rebuild дошел до линковки и упал `error code: 5`, потому что был запущен `RecorderLnx.exe` PID 10360. Процесс остановлен, повторная сборка `RecorderLnx.lpi` завершилась с exit code 0. Известное post-build сообщение `#!/bin/sh` осталось неблокирующим.

**Статус:** код готов к ручной проверке: после Apply/OK подготовка должна происходить на измененных приборах, Preview не должен занимать 30 секунд из-за `PrepareHardware`.
## 2026-08-14 - MIC-140 UTS readout layer

**Request:** add MIC-140 UTS support like MIC-185, after checking original Recorder.

**Done:** original Recorder shows MIC-140 UTS is not a TIn/temperature word. It is handled by `ScanSEV`: `mtc/sevscn.cpp` reads a 6-word `TUtsBios`, converts BCD `time_lo/time_hi` to `time_uts`, and adds a device/UTS time pair through `Device::AddTimeDev`. RecorderLnx now has MIC-140 `node-uts` addresses, `MIC140-{node-uts}` display names, an available UTS signal in the MIC-140 source probe, legacy stream-0 parsing for 6-word SEV/UTS packets, and cached-tag numeric publication without runtime string lookup or `TextValue`.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code 0 and linked `RecorderLnx.exe`. Existing post-build `copy_sdb_res.bat` still prints `#!/bin/sh` on Windows but does not break the build.

**Remaining:** hardware check is needed. If selected MIC-140 `*-uts` tags do not update while AIn/TIn is alive, the next step is explicit second-scan programming for `ScanSEV` (`CMD_APPENDSCANMAIN` type 17 + `CMD_CONFIG_SCANSEV=91`). Detailed hypothesis log: `errors/2026-08-14-mic140-uts-readout.md`.
## 2026-08-14 - MIC-140 UTS readout

**Request:** add MIC-140 UTS handling like MIC-185 and verify against original Recorder sources.

**Done:** original `mtc/sevscn.cpp` / `sevchn.*` checked: MIC-140 UTS is a separate `ScanSEV`/`VT_UTS` 6-word payload, not a TIn channel. RecorderLnx now exposes MIC-140 `{node}-uts`, caches/parses SEV UTS packets in the MIC-140 TCP protocol, stores latest UTS in the MIC-140 device, and publishes it through a cached runtime tag with `TimeSystem.UpdateFromTagSample`.

**Also fixed:** `SameMic140Address` now respects node-qualified addresses, so channels/UTS from different MIC-140 nodes are not treated as the same tag.

**Verification:** `lazbuild -B Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code 0. Existing post-build `copy_sdb_res.bat` still prints `#!/bin/sh` under Windows but does not break linking.

**Next hardware check:** select a MIC-140 `*-uts` tag and verify values appear. If AIn/TIn data flows but UTS stays empty, implement explicit `ScanSEV` programming (`CMD_APPENDSCANMAIN` type 17 + `CMD_CONFIG_SCANSEV=91`) from the original scan setup.
## 2026-08-14 - MIC-140 main stream restored after UTS regression

**Request:** after UTS changes, MIC-140 stopped publishing data entirely.

**Done:** inspected `LogWindows.log`: packets were arriving, but all main
MIC-140 packets were rejected as `reason=routing`. Root cause was duplicate
`CMic140LegacyScanId`: new shared constants changed main scan programming to
`0`, while the existing parser/runtime path expected the working id `1`.
Restored `CMic140LegacyScanId = 1` and disabled automatic SEV programming and
SEV rearm for now. UTS tag frequency isolation remains.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
finished with exit code 0. `git diff --check` reports only line-ending
warnings. Hardware check needed: MIC-140 normal channels should produce data
again; UTS programming is still pending a safer multi-scan implementation.

## 2026-08-14 - MIC-140 UTS frequency isolation and ScanSEV programming

**Request:** after adding MIC-140 UTS to acquisition, all other MIC-140
channels became 1 Hz and UTS values did not appear.

**Done:** UTS and diagnostic tags are excluded from MIC-140 source frequency
selection in runtime source creation/replacement and in source-wide frequency
application. Added explicit original-style SEV scan programming for MIC-140:
scan id 1, type 17, FIFO descriptor, `CMD_CONFIG_SCANSEV`, and non-fatal SEV
rearm on start. Parser now accepts SEV packets containing multiple 6-word UTS
entries and publishes the newest one through cached tag references only.

**Verification:** `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
finished with exit code 0 and linked `RecorderLnx.exe`. `git diff --check`
reported only line-ending warnings. Hardware check remains: normal channels
must keep configured frequency while `{node}-uts` updates near 1 Hz.
