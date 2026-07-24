## 2026-07-24 — Аудит MIC-185 RunTime + skill runtime-programming

**Задача:** По комментариям в hot path MIC-185 проверить сбор данных в RunTime и оформить skill, чтобы не повторять аллокации/поиск/разворот оси X в тике.

**Сделано:**
- Аудит цепочки `DoTick → ReadBlock → PublishMeasurementBlock` с вердиктами по каждому комментарию.
- Skill `runtime-programming` (Cursor + зеркало AGrav).
- Ссылки в AGrav `Скиллы_ИИ.md`, `Потоки_и_Память.md`, история изменений.

**Документация:** [mic185-runtime-audit-2026-07-24.md](Docs/mic185-runtime-audit-2026-07-24.md)

## 2026-07-17 — Digital form: серые ячейки единицы «код»

**Задача (переформулировка):** В таблице Digital form ячейки Unit со значением «код» выделить серым.

**Сделано:**
- `sgFormularPrepareCanvas`: Unit=`код`/`code` → `clSilver`
- lazbuild `-B` RecorderLnx — OK

## 2026-07-17 — MC-201: ГХ с диска при пустом имени (галочка по умолчанию)

**Задача (переформулировка):** Почему не подтянулась ГХ sn1465 — у тега была пустая галочка/имя, загрузка пропускалась.

**Сделано:**
- автозагрузка если имя ГХ пустое и CSV есть → имя + `Enabled=True`; пропуск только при снятой галочке с сохранённым именем
- разбор `SN=` без `UpperCase` по кириллице; открытие свойств тега тоже пробует load
- lazbuild `-B` RecorderLnx — OK (exe был занят — пересобран после unlock)

**Документация:** [mc201-hardware-scale.md](Docs/devices/mc/mc201-hardware-scale.md)

## 2026-07-17 — MC-201: автозагрузка аппаратной ГХ с диска

**Задача (переформулировка):** Если для SN модуля и выбранного диапазона уже лежат файлы ГХ в Mera Files, и галочка «использовать аппаратную ГХ» не снята — сразу подгружать её в реестр и на тег.

**Сделано:**
- `RecorderMc201TryLoadScaleFromCsv` / `Ensure…` / `ApplyHardwareCalibrations` по пути `…\MC-201\snXXXX\<range>\NN.csv`
- вызов при `BuildChannelMap`; новые MC-201-теги: `HardwareCalibrationEnabled=True` при первом bind
- lazbuild `-B` RecorderLnx — OK

**Документация:** [mc201-hardware-scale.md](Docs/devices/mc/mc201-hardware-scale.md)

## 2026-07-17 — MC-201: без ГХ по умолчанию коды, не вольты

**Задача (переформулировка):** У аппаратных каналов MC-201 без назначенной ГХ в таблице должны идти сырые коды АЦП (единица «код»), а не «В».

**Сделано:**
- probe новых каналов: `UnitsName := 'код'` вместо `'В'`
- `RecorderMc201SyncTagUnitFromHardwareGx` при привязке канала и после калибровки масштаба
- lazbuild `-B` RecorderLnx — OK

**Документация:** [mc201-hardware-scale.md](Docs/devices/mc/mc201-hardware-scale.md)

## 2026-07-17 — MC-201: калибровка масштаба К сдвигом балансировочного ЦАП

**Задача (переформулировка):** Сервисная калибровка диапазона MC-201: сдвинуть точный балансировочный ЦАП на известное V, вычислить K [В/код], назначить как аппаратную ГХ-коэффициент (`rckScale`, не кусочную), автосохранить в `Mera Files\Calibr\hardware\MTC\MC-201\snXXXX\…`; кнопка в диалоге слота для выбранных каналов.

**Сделано:**
- `CalibrateScaleByBalanceDacShift`: SEND $8080 → mean A → SEND сдвиг (Lo/Hi=20) → mean B → K=ΔV/Δcode → restore ЦАП
- `uRecorderMc201Calibration`: пути Mera Files, CSV+`.tid` (`ScaleTransformer.1`), upsert `rckScale`, привязка к тегам слота
- диалог MC-201: чекбоксы каналов + «Калибровка выбранных»; PublishBlock применяет аппаратную ГХ
- lazbuild `-B` RecorderLnx — OK

**Файлы:** `Device/MCbus/uRecorderMc201Calibration.pas`, `uRecorderMcbusDevice.pas`, `UI/uRecorderMc201SlotSettingsDialog.*`, `uRecorderMcbusDataSource.pas`

**Документация:** [mc201-hardware-scale.md](Docs/devices/mc/mc201-hardware-scale.md)

## 2026-07-17 — Документ: мультибаланс MC-201 / программирование ЦАП

**Задача:** Зафиксировать в Docs/devices/mc, как добились рабочего программирования ЦАП при мультибалансировке.

**Сделано:**
- добавлен [Docs/devices/mc/mc201-zero-balance-multi.md](Docs/devices/mc/mc201-zero-balance-multi.md)
- ссылки из `README.md`, `mc201.md`, `recorderlnx-integration.md` (секция балансировки обновлена)

**Документация:** [mc201-zero-balance-multi.md](Docs/devices/mc/mc201-zero-balance-multi.md)

## 2026-07-17 — Stop сразу после collect; quiet без ACK

**Задача:** `STOPSCANMAIN ack not seen drained=126 quiet=True` — поток встал, ACK на no-wait нет; требовать ACK было ошибкой. Плюс Stop после compute копил RX.

**Сделано:**
- порядок: collect → **Stop** → compute → SEND → StartRawScan
- `StopAfterHeavyStream`: CallCommand STOP (3с), иначе no-wait+quiet; **quiet без ACK = OK**
- не слать второй CallCommand STOP после quiet
- lazbuild `-B` exit 0

**Файлы:** `Device/MCbus/uMc032Device.pas`, `Device/MCbus/uRecorderMcbusDevice.pas`

## 2026-07-17 — Apply: сохранить ACK STOP при drain

**Задача:** Диалог зависал на `SEND while streaming`; soft-STOP раньше выбрасывал command-port ACK и глушил шину.

**Сделано:**
- `StopAfterHeavyStream`: no-wait STOP → drain, **command-port = ACK** (без второго CallCommand STOP)
- apply снова: keep-ACK stop → SEND → StartRawScan
- `SendBalanceDac`: без длинных 15с×4 retry (не вешать диалог)
- lazbuild `-B` exit 0

**Документация:** [errors/2026-07-17-mc201-soft-stop-kills-commands.md](errors/2026-07-17-mc201-soft-stop-kills-commands.md)

## 2026-07-17 — Apply: SEND на живом потоке (без Stop)

**Задача:** После soft/quiet STOP шина глухая (`sync STOP` / SEND → MDP timeout); prepare со Stop+reply работает.

**Сделано:**
- apply: только `TryApplySavedBalanceDac` при `mcsPlay`, без Stop/RESET/StartRawScan
- timeout ≥15с (reply среди data-port), как идея PlayDAC в оригинале
- зафиксировано в `errors/2026-07-17-mc201-soft-stop-kills-commands.md`
- lazbuild `-B` exit 0

**Документация:** [errors/2026-07-17-mc201-soft-stop-kills-commands.md](errors/2026-07-17-mc201-soft-stop-kills-commands.md)

## 2026-07-17 — Apply: sync STOP после quiet + SEND retry

**Задача:** После `StopAfterHeavyStream` quiet-ok SEND_BALANCE на ch0 всё ещё MDP timeout (~1.2с) — soft-тишина 300мс недостаточна / не было confirmed STOP как в prepare.

**Сделано:**
- quiet ≥1с → `CallCommand(STOP)` на тихой шине (как prepare) → ещё 400мс quiet; без sync — fail
- `TimeoutMs` setter пишет и в `fClient`
- `SendBalanceDac`: drain + IDMA-activated, fallback IDMA-not-activated, 2 попытки
- apply по-прежнему без RESET/`Start.Raise`
- lazbuild `-B` exit 0

**Файлы:** `Device/MCbus/uMc032Device.pas`, `Device/MCbus/uRecorderMcbusDevice.pas`

## 2026-07-17 — Apply: quiet Stop + SEND без Start.Raise

**Задача:** После Stop apply падал в `ApplySavedBalanceDac` (`SEND_BALANCE` MDP timeout) — soft preview-Stop ждал 15с и не давал тишины на шине.

**Сделано:**
- `StopAfterHeavyStream`: сразу STOP no-wait, drain до ≥300 мс тишины (без CallCommand)
- apply: StopAfterHeavyStream → `TryApplySavedBalanceDac` → `StartRawScan` (без `ProgramDevice`/`Start` raise)
- prepare без изменений (Stop+SEND $8080+Start)
- **сборка:** exe залочен отладчиком Lazarus (PID 9492 zombie) — Stop debugger (Ctrl+F2) и `lazbuild -B`

**Файлы:** `Device/MCbus/uMc032Device.pas`, `Device/MCbus/uRecorderMcbusDevice.pas`

## 2026-07-17 — Apply без RESETSCANMAIN (SEND как Programming)

**Задача:** В конце multi-balance `ProgramDevice` падал на `RESETSCANMAIN` / MDP timeout — нужен Stop как просмотр, затем запись ЦАП без полного Config.

**Сделано:**
- apply: Stop → (при необходимости Connect) → `Start` с `ApplySavedBalanceDac` + `StartRawScan`
- полный `ProgramDevice`/RESET только если нет `ProgramInfo` после Connect
- как оригинал `ModuleMC201::Programming()` — SEND на тихой шине
- lazbuild `-B` exit 0

**Файлы:** `Device/MCbus/uRecorderMcbusDevice.pas`

## 2026-07-17 — Apply: preview Stop + полное ProgramDevice

**Задача:** После multi-scan коды ЦАП посчитаны, но apply зависает на останове (`RESETSCANMAIN` / MDP timeout); нужен обычный Stop как из просмотра, затем программирование всего девайса.

**Сделано:**
- apply: soft-коды ЦАП → `TRecorderMcbusDevice.Stop` (как просмотр) → при обрыве Sleep+Connect → полное `ProgramDevice` → `Start`
- убраны apply-пути `StopAfterHeavyStream` / `ConfigKeepSession` / per-channel SEND
- `TMc032Device.Stop`: при промахе reply — no-wait STOP + drain, **без ForceDisconnect** (TCP жив для ProgramDevice)
- lazbuild `-B` exit 0

**Файлы:** `Device/MCbus/uRecorderMcbusDevice.pas`, `Device/MCbus/uMc032Device.pas`

## 2026-07-17 — Баланс apply без ForceDisconnect

**Задача:** После ForceDisconnect+reconnect контроллер «умирал» до сброса оригинальным Recorder; сброс у нас вешал UI.

**Сделано:**
- apply: StopAfterHeavyStream + ConfigKeepSession (RESETSCANMAIN/SEND на той же TCP)
- ConfigKeepSession: при сбое CMD_RESET + Sleep + Program без Disconnect
- ForceDisconnect из apply убран
- lazbuild exit

## 2026-07-17 — Apply: Config после reconnect (лог SEND timeout)

**Задача:** По логу StopAfterHeavyStream прошёл, SEND_BALANCE на той же сессии — MDP timeout.

**Сделано:**
- apply: soft-коды → ForceDisconnect → Sleep(1.5с) → TryConnect×5 → Config (SEND внутри) → Start
- prepare без изменений (Stop+SEND \)
- lazbuild exit 0

## 2026-07-17 — Почему apply stop тупит, а просмотр нет

**Задача:** apply stop MDP timeout при живом просмотре — найти разницу и починить только apply.

**Сделано:**
- Просмотр: ReadBlock постоянно дренирует RX → Stop видит короткий хвост.
- Баланс после collect: чтение стоп → RX забит → CallCommand(STOP) не находит reply → ForceDisconnect.
- StopAfterHeavyStream: no-wait STOP + drain до тишины, TCP жив для SEND; просмотр по-прежнему Stop.
- lazbuild exit code 0

## 2026-07-17 — Мультибаланс MC-201 v2 (без правок CallCommand)

**Задача:** Параллельная балансировка каналов на откатанной базе, не ломая просмотр.

**Сделано:**
- CollectChannelsMean + BalanceChannelsHardware: prepare всем → settle 1с → сбор по Fs → skip без данных → Stop+SEND+Start
- Stop: только TimeoutMs≥5с на STOPSCANMAIN
- CallCommand/DrainPackets не трогали
- lazbuild exit code 0

## 2026-07-17 — MC-201: исправлен показ вольт баланса (целочисленное деление)

**Задача (переформулировка):** UI всегда показывал 0 В для |Lo|,|Hi|<128 из-за Integer-division в VoltFromSigned.

**Сделано:**
- RecorderMc201BalanceVoltFromSigned считает через Double.
- Диалог: fUpdating при Lo/Hi, OnExit на DAC, FormatFloat + DefaultFormatSettings.
- lazbuild -B RecorderLnx.lpi — OK.

**Файлы:** uMc201ProtocolTypes.pas, uRecorderMc201SlotSettingsDialog.pas

## 2026-07-17 — Мульти-баланс MC-201: не затирать ЦАП соседних каналов

**Задача (переформулировка):** Баланс нескольких каналов отрабатывал, но в CFG/диалоге оставались нули — первый Store перечитывал CFG и сбрасывал soft-коды остальных в $8080.

**Сделано:**
- Перед persist снимается снапшот всех кодов с runtime.
- `StoreBalanceDac(..., AApplyRuntime=False)` пишет CFG без промежуточного reload.
- Один `SetSpecificConfigText` после всех каналов.

**Файлы:** `Device/MCbus/uRecorderMcbusDataSource.pas`

---
## 2026-07-17 — Диалог MC-201 показывает живые коды ЦАП

**Задача (переформулировка):** В свойствах слота ЦАП был 0/0, хотя ApplySavedBalanceDac шлёт реальный код ($E182).

**Сделано:**
- При открытии диалога коды подмешиваются из runtime fConfig живого MC-устройства (`MergeSlotBalanceDacsIntoConfigText`).
- Сборка OK.

**Файлы:** `uRecorderMcbusDevice.pas`, `uRecorderMc201SlotSettingsDialog.pas`, call sites

## 2026-07-17 — ЦАП MC-201: ввод в вольтах по ИОН 2.5 В

**Задача (переформулировка):** Рядом с Lo/Hi дать ввод смещения в вольтах; коды считать по ИОН из оригинала, не по эмпирическому 2.8.

**Сделано:**
- ИОН `CMc201BalanceUrefVolt = 2.5` (`UREF_DA_` из `Mc201.cpp`).
- `V = 2.5 · (Lo/128) · (Hi/128)`; обратный расчёт Lo/Hi при правке вольт.
- Колонка «ЦАП, В» в свойствах слота; сборка отдельно.

**Файлы:** `uMc201ProtocolTypes.pas`, `uRecorderMc201SlotSettingsDialog.pas/.lfm`

---
## 2026-07-17 — ЦАП MC-201 в диалоге: знаковые −128…+127

**Задача (переформулировка):** Показывать балансировочный ЦАП в десятичном виде ±128, а не hex `$8080`.

**Сделано:**
- Две колонки: «ЦАП груб.» (lo) и «ЦАП тонк.» (hi), значения −128…+127 (0 = нейтраль, байт 128).
- Упаковка в слово `hi<<8|lo` как в железе; сборка OK.

**Файлы:** `Device/MCbus/UI/uRecorderMc201SlotSettingsDialog.pas`, `.lfm`

---
## 2026-07-17 — ЦАП балансировки в свойствах слота MC-201

**Задача (переформулировка):** В настройках MC-201 показывать и давать править коды балансировочного ЦАП.

**Сделано:**
- В диалоге слота колонка «ЦАП» (`$xxxx`) для каналов 1–4; код привязан к выбранному диапазону канала (`dXrY`).
- Смена диапазона переключает отображаемый код; OK проверяет ввод и пишет CFG.
- Сборка OK.

**Файлы:** `Device/MCbus/UI/uRecorderMc201SlotSettingsDialog.pas`, `.lfm`

---
## 2026-07-17 — Без диалога после успешной балансировки нуля

**Задача (переформулировка):** После балансировки не показывать MessageDlg со средним и кодом ЦАП.

**Сделано:**
- `RecorderTryZeroBalanceTags`: при успехе диалог не показывается; при ошибке — `mtWarning` с текстом.
- Сборка OK.

**Файлы:** `Core/uRecorderTagBalance.pas`

---
## 2026-07-17 — Балансировка MC-201 всегда от нейтрали ЦАП

**Задача (переформулировка):** Вторая балансировка ломала первую (~9 кодов → почти нейтральный ЦАП → снова ~540). Нужно перед расчётом всегда гасить ЦАП.

**Сделано:**
- Перед измерением: Stop → `SEND_BALANCE $8080` → Start → среднее.
- Затем расчёт open-loop и Stop → SEND новый код → Start → verify.
- Повторные балансировки дают тот же результат независимо от предыдущего ЦАП.
- Сборка OK.

**Файлы:** `Device/MCbus/uRecorderMcbusDevice.pas`

---
## 2026-07-17 — CFG балансировки MC-201: `;` вместо `,`, soft ЦАП не затирать

**Задача (переформулировка):** После успешной балансировки (`$E182`, verifyMean≈8) следующая попытка снова видит `старый ЦАП=$8080` — soft/CFG теряли код.

**Сделано:**
- `StoreBalanceDac` всегда пишет поля через `;` и после persist вызывает `SetSpecificConfigText` (перезагрузка `fConfig`).
- `ApplySpecificConfigText` и чтение CFG в `StoreBalanceDac` нормализуют старые строки с `,` → `;`, чтобы `dXrY` читался.
- Лог `ApplySavedBalanceDac` для кодов ≠ `$8080`.
- Причина в логах 16:03: `DAC config created` с запятыми → парсер не видел `d0r1` → soft сбрасывался в `$8080`.

**Файлы:** `Device/MCbus/uRecorderMcbusDataSource.pas`, `uRecorderMcbusDevice.pas`

---
## 2026-07-17 — ЦАП балансировки MC-201 не сбрасывать на Stop/Start

**Задача (переформулировка):** Код ЦАП в логах верный, но после Stop/Start эффект пропадает — железо сбрасывает регистр.

**Сделано:**
- Код сохраняется в soft-config до apply-цикла.
- После `STOPSCANMAIN` повторный `SEND_BALANCE_CC` до `StartRawScan`.
- Логи restore after Stop; exe занят — нужна пересборка после закрытия приложения.

**Файлы:** `Device/MCbus/uRecorderMcbusDevice.pas`

---
## 2026-07-17 — Логи и размер выборки балансировки MC-201

**Задача (переформулировка):** Балансировка срабатывала только с 3-й попытки; добавить логи и устранить вероятный timeout выборки.

**Сделано:**
- Подробные `[MCBUS][BALANCE]` логи: старт/стоп, map тегов, CollectChannelMean (msgs/match/skip), SEND_BALANCE, apply cycle.
- Размер оценки: `min(2048, round(Fs*0.06))` вместо целой секунды Fs (раньше timeout 2048/57600).
- Таймаут сбора зависит от числа отсчётов.
- Модули компилируются; линковка exe заблокирована запущенным RecorderLnx (error 5).

**Файлы:** `Device/MCbus/uRecorderMcbusDevice.pas`, `uRecorderMcbusDataSource.pas`

---

## 2026-07-17 — Балансировка MC-201 без обязательного Preview

**Задача (переформулировка):** Кнопка балансировки в диалоге тега требовала «запущенный просмотр»; поднять служебный скан при необходимости.

**Сделано:**
- `ExecuteDeviceAction(rdaZeroBalance)` сам вызывает `Start`, если скан не активен; служебный скан гасится в `finally`.
- При уже идущем Preview — по-прежнему Pause/Resume reader.
- Сборка OK.

**Файлы:** `Device/MCbus/uRecorderMcbusDevice.pas`

---
## 2026-07-17 — Математика балансировки MC-201 в комментариях

**Задача (переформулировка):** Подробно пояснить формулу `BalanceChannelHardware` и сравнить с итеративным `ChanCalibrFullSingleScan` оригинала.

**Сделано:**
- В `uRecorderMcbusDevice.BalanceChannelHardware` — комментарии: модель `k*(lo-128)*(hi-128)`, разложение product→loOff/hiOff, отличие от бинарного поиска оригинала, защёлка Stop/Start.
- Encoding verify OK; сборка `RecorderLnx.lpi` — OK.

**Файлы:** `Device/MCbus/uRecorderMcbusDevice.pas`

**Документация:** [recorderlnx-integration.md](Docs/devices/mc/recorderlnx-integration.md); оригинал `mtc/Mc201.cpp`

---
## 2026-07-17 — Комментарии к API `uMc032Device`

**Задача (переформулировка):** Подписать методы низкоуровневого драйвера MC-032 по смыслу работы (параметры, момент вызова), без формальных «метод Stop останавливает».

**Сделано:**
- В секции `interface` добавлены комментарии к public/private API, helper-классам и callback’ам.
- Запись через encoding-safe `pas_io` (UTF-8+CRLF); `verify_russian_comments.py` — OK.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `Device/MCbus/uMc032Device.pas`

**Документация:** [recorderlnx-integration.md](Docs/devices/mc/recorderlnx-integration.md)

---
## 2026-07-08 — Splitter правой панели и колонки списка тегов

**Задача (переформулировка):** сделать правую панель ресайзируемой через `Splitter` и отрисовывать список каналов в виде двух визуальных колонок (имя и частота опроса), чтобы они выравнивались по ширине.

**Сделано:**
- Добавлен `TSplitter` (`SplitterRight`) между `pnMain` и `pnRight` для изменения ширины правой панели.
- `lbTags` переведён в owner-draw и рисует две колонки: имя слева, частоту опроса справа (выравнивание по ширине).
- Формат текста в `lbTags` обновлён на `<name><TAB><freq>`.
- Сборка OK.

**Файлы:** `UI/uMainForm.lfm`, `UI/uMainForm.pas`

---
## 2026-07-07 — Чтение серийника/версии MIC183/185 в диалоге настроек

**Задача:** При открытии диалога MIC183/185 показывать серийный номер и версию ПО прибора, не затрагивая существующий протокол опроса.

**Сделано:**
- Новый модуль `uRecorderMic185DeviceInfoProbe.pas` — отдельная функция `RecorderMic185ProbeDeviceInfo`.
- Порядок: live-сессия → кэш runtime при занятом порте → короткий TCP + IOCTL `GetSoftVersion`.
- `TRecorderMic185Device` и цикл опроса не изменялись.
- Диалог MIC185 вызывает probe при `LoadSource` / `RefreshDeviceInfo`.
- Сборка OK.

**Файлы:** `Device/mic185/uRecorderMic185DeviceInfoProbe.pas`, `Device/mic185/UI/uRecorderMic185SettingsDialog.pas`

---

## 2026-07-07 — MIC-185 в цифровом формуляре после загрузки проекта

**Задача:** Теги MIC-185 отображались в списке каналов, но не попадали в цифровой формуляр на главной форме.

**Сделано:**
- Причина: `RenderDigitalPage` вызывался при инициализации страниц до `UpdateActiveSourceIds`; Mera-теги видны через fallback по файлу, аппаратные — только при активном sourceId.
- После загрузки проекта и `RebuildTagList` добавлен `RenderActivePage`.
- Сборка OK.

**Файлы:** `UI/uMainForm.pas`

---

## 2026-07-07 — Диагностика MIC-185/Mera и видимость тегов

**Задача:** MIC-185 ошибочно показывался offline; теги Mera File не попадали в список каналов и цифровую форму при существующем файле.

**Сделано:**
- MIC-140/MIC-185: TCP-probe (1 с) когда нет live-сессии; MIC-185 учитывает `RuntimeIsBusy`.
- Mera File: `ExpandFileName` при проверке `FileExists`; эквивалентность sourceId по пути файла.
- `RecorderTagSourceIsVisible` — Mera-тег виден, если файл существует (даже при расхождении sourceId).
- Сборка OK.

**Файлы:** `Core/uRecorderHardwareTree.pas`, `Device/mic185/uRecorderMic185DataSource.pas`, `Core/uRecorderTags.pas`

---

## 2026-07-07 — Настройка источника через IRecorderConfiguredSourceEditor

**Задача:** Убрать сравнения с `MIC-140`/`MIC183/185` в обработчике двойного клика дерева устройств; по dblclick вызывать абстрактный метод настройки, конкретный диалог — в реализации устройства.

**Сделано:**
- `Device/uRecorderConfiguredSourceEditor.pas` — интерфейс `IRecorderConfiguredSourceEditor`, диспетчер `RecorderEditConfiguredDataSource`.
- Регистрация редакторов в `uRecorderMic140SettingsDialog` и `uRecorderMic185SettingsDialog` (initialization).
- `uRecorderSettingsDialog` — `EditHardwareSource` / dblclick / кнопка «…» вызывают диспетчер; удалены `ToggleHardwareSignal`, `ConfigureMic140/185`, `SelectedMic140/185*`.
- Mera file по-прежнему через `EditMeraFileSource` (virtual source).
- Сборка OK.

**Файлы:** `Device/uRecorderConfiguredSourceEditor.pas`, `UI/uRecorderSettingsDialog.pas`, `Device/MIC140/UI/uRecorderMic140SettingsDialog.pas`, `Device/mic185/UI/uRecorderMic185SettingsDialog.pas`

---

## 2026-07-07 — Неактивные источники: иконка в настройках, скрытие на формах

**Задача:** Помечать теги с неактивным источником иконкой в списке выбранных каналов диалога настроек; не показывать такие теги в списке каналов главной формы и на цифровой форме.

**Сделано:**
- `PopulateHardwareTree` — источник активен только при `HasLinkedTags and LinkOk` (раньше игнорировался offline).
- `UpdateActiveSourceIds` — probe связи для MIC/Mera всегда, не только при `DataSources.Running`.
- `RecorderTagSourceIsVisible` — фильтр и для virtual (Mera file), не только hardware.
- `RenderRecorderDigitalPage` — пропуск тегов с неактивным источником.
- Иконка 54 в колонке 0 сетки выбранных каналов (MIC/Mera offline).
- Сборка OK.

**Файлы:** `UI/uRecorderSettingsDialog.pas`, `UI/uMainForm.pas`, `Core/uRecorderTags.pas`, `UI/uRecorderDigitalPageView.pas`

---

## 2026-07-07 — Диалог настроек: только lfm, без динамического UI

**Задача:** В `uRecorderSettingsDialog` оставить только форму (`.lfm`) для внешнего вида; убрать мёртвый код динамической генерации контролов; исправить падение при открытии формы.

**Сделано:**
- Удалены `BuildUi`, `BuildRecorderTab`, `BuildHardwareTab`, `BuildPlaceholderTab` и хелперы `AddLabel`/`AddEdit`/… (~300 строк).
- `btnChannelEdit` и обработчики кнопок устройств/каталогов перенесены в `.lfm`; убраны `FindComponent` и runtime-создание кнопок в `Create`.
- **Исправлен AV при открытии:** `InitializeHardwareTree` больше не вызывает `PopulateHardwareTree` до `SetRecorder`; добавлены nil-проверки `fRecorder` в `PopulateHardwareTree` и `PopulateChannelGrids`.
- Сборка OK (`lazbuild -B RecorderLnx.lpi`).

**Файлы:** `UI/uRecorderSettingsDialog.pas`, `UI/uRecorderSettingsDialog.lfm`

---

## 2026-07-07 — Ядро без Channels; MIC-140 настройки вне TRecorderTag

**Задача:** Убрать `fChannels` из ядра; теги знают родителя через `SourceId` и отображаются в списке каналов диалога с сортировкой; базовые объекты ядра не ссылаются на MIC-140-специфичные поля в `TRecorderTag`.

**Сделано:**
- `TRecorder` — без `Channels`; удалён `Core/uRecorderChannelCatalog.pas`.
- `UI/uRecorderSettingsSourceProbe.pas` — UI-слой: временные `TMeraSignalInfo` для доступных каналов в диалоге настроек (`fSourceProbe`).
- `TRecorderTag` — удалены поля `MeasRangeIndex`, `Mic140*`; MIC-140 runtime/persist в `TRecorderMic140SourceConfig` и channel settings.
- Миграция legacy JSON тегов → device config при загрузке проекта (`RecorderMic140MigrateLegacyFieldsToDeviceConfig`).
- Обновлены MIC-140 data source, calibration, tag settings dialog.
- Сборка OK (`RecorderLnx_tagcore_buildtest.exe`).

**Файлы:** `Core/uRecorder.pas`, `Core/uRecorderTags.pas`, `UI/uRecorderSettingsSourceProbe.pas`, `UI/uRecorderSettingsDialog.pas`, `Device/MIC140/uRecorderMic140DeviceConfig.pas`

---

## 2026-07-07 — TRecorder: корневой объект ядра

**Задача:** Ввести корневой объект `TRecorder` (аналог `IRecorder`), владеющий менеджерами; главная форма и диалоги ссылаются на него.

**Сделано:**
- `Core/uRecorder.pas` — `TRecorder` владеет TagRegistry, DataSources, StateMachine, RunSettings, EventQueue, TimeSystem, SpectrumManager, AlarmEngine.
- `uMainForm` — поле `fRecorder: TRecorder` вместо разрозненных менеджеров.
- `uRecorderSettingsDialog` — `property Recorder`, probe-каналы в UI-слое (см. запись выше).

**Файлы:** `Core/uRecorder.pas`, `UI/uMainForm.pas`, `UI/uRecorderSettingsDialog.pas`

---

**Задача:** Список устройств — отдельный лист в движке; устройства только через менеджер (поиск/ручное добавление) или загрузку конфигурации; теги не должны создавать узлы в дереве и записи в `dataSources`.

**Сделано:**
- Новый модуль `Core/uRecorderConfiguredDataSources.pas` — `ConfiguredDataSources` в реестре, load/save секции `dataSources`.
- `RecorderCollectHardwareTreeEntries` и `RestoreDevicesFromRegistry` читают только `ConfiguredDataSources`, не теги.
- Удалены `Restore*FromTags` и `RecorderMic140RebuildDeviceConfigsFromTags` из load/save и диалога настроек.
- Добавление/удаление устройства в UI синхронизирует `ConfiguredDataSources`; при OK — `SyncConfiguredDevicesToRegistry`.
- Сборка OK (`RecorderLnx_buildtest.exe`).

**Файлы:** `Core/uRecorderConfiguredDataSources.pas`, `Core/uRecorderTags.pas`, `Core/uRecorderHardwareTree.pas`, `Core/uRecorderProjectFiles.pas`, `UI/uRecorderSettingsDialog.pas`

---

## 2026-07-07 — Дерево устройств: без manual и debug.diagnostics

**Задача:** Убрать из дерева устройств служебные источники `manual` и `debug.diagnostics`.

**Сделано:**
- `RecorderHardwareTreeShowsSourceId` — в дереве только Mera file и MIC-140/185.
- `RecorderCollectHardwareTreeEntries` фильтрует остальные sourceId.

**Файлы:** `Core/uRecorderTags.pas`, `Core/uRecorderHardwareTree.pas`

---

**Задача:** Убрать из `PopulateHardwareTree` прямые обращения к MeraFile/MIC140/MIC185; оставить только абстрактные методы источника; сократить `uses` в interface.

**Сделано:**
- Новый модуль `Core/uRecorderHardwareTree.pas` — сбор sourceId, подпись узла, link OK, привязка `SourceId` к `TTreeNode.Data`.
- `PopulateHardwareTree` — единый цикл по `TRecorderHardwareTreeEntry`, без вложенных `Mic140SourceConnected` / `fMeraFileName`.
- Из interface `uRecorderSettingsDialog` убраны MIC185/MIC140 dialog/runtime units; device-специфика — в `implementation`.
- `SignalSourceId` → `RecorderSignalConfiguredSourceId`.
- Сборка OK.

**Файлы:** `Core/uRecorderHardwareTree.pas`, `UI/uRecorderSettingsDialog.pas`

---

**Задача:** Устранить падение при выходе из RecorderLnx и показывать рабочий MIC185 в дереве устройств зелёной иконкой, без ложного «сбойного» состояния.

**Сделано:**
- `finalization` в `uRecorderMic185Runtime` и `uRecorderHardwareLiveDevices`: `Free` + `Delete(0)` вместо бесконечного `while Count > 0`.
- `TestLink` MIC185: при открытой сессии (`rdsConnected`+) OK без IOCTL во время опроса.
- Регистрация live-устройства через канонический `RecorderMic185RegisterLiveDevice(host, port)`.
- `RecorderMic185IsSourceLinkOk` — нормализация sourceId + fallback на `RuntimeIsBusy`.
- Дерево устройств и health probe используют новую проверку.
- Сборка OK.

**Файлы:** `uRecorderMic185Runtime.pas`, `uRecorderHardwareLiveDevices.pas`, `uMic185Device.pas`, `uRecorderMic185DataSource.pas`, `uRecorderSettingsDialog.pas`, `uMainForm.pas`

**Документация:** [errors/2026-07-07-mic185-dblclick-socket-busy.md](errors/2026-07-07-mic185-dblclick-socket-busy.md)

---

**Задача:** Восстановить сборку основного проекта RecorderLnx после ошибки компиляции.

**Сделано:**
- Убран `uMic185Registration` из `RecorderLnx.lpr` / `.lpi` — модуль только для тестового стенда (`Tests/mic185`) и тянет отсутствующий в основном проекте `uRecorderDeviceManager`.
- Сборка `lazbuild -B` проходит успешно (exit 0).

**Файлы:** `RecorderLnx.lpr`, `RecorderLnx.lpi`

---

## 2026-07-07 — IRecorderDevice.TestLink и зелёная иконка без второго TCP

**Задача:** Корректная диагностика MIC/MIC140 в дереве устройств: не открывать второе соединение; после connect держать «зелёное» состояние и проверять link тестовой командой на существующей сессии.

**Сделано:**
- `IRecorderDevice.TestLink` в абстракции устройства; реализации MIC185 (IOCTL sn), MIC140 core/v2 (ReadFirmware/ProbeScan).
- `uRecorderHardwareLiveDevices` — реестр live-сессий от data source.
- Дерево и health probe: `RecorderHardwareIsSourceLinkOk` вместо `TcpProbe`.
- Открытие настроек не останавливает preview (только запись).
- Сборка OK, self-test `LiveDeviceInfo` при активном опросе.

**Документация:** [errors/2026-07-07-mic185-dblclick-socket-busy.md](errors/2026-07-07-mic185-dblclick-socket-busy.md)

---

## 2026-07-07 — MIC185: состояние из TRecorderMic185Device, без probe TCP

**Задача:** Убрать ESocketError при редактировании MIC185; состояние «мик подключён» брать из класса устройства, не открывая дополнительное TCP-соединение.

**Сделано:**
- Реестр live-устройств (`RecorderMic185RegisterLiveDevice`) привязан к `TRecorderMic185Device` в data source.
- `ReadDeviceInfo` / диалог / дерево читают sn/версию/опрос только из live device.
- Probe TCP для UI полностью удалён.
- Автотест `--selftest-mic185-settings` на устройстве 192.168.9.142: `LiveDeviceInfo` без `opening probe TCP`.
- Сборка OK.

**Документация:** [errors/2026-07-07-mic185-dblclick-socket-busy.md](errors/2026-07-07-mic185-dblclick-socket-busy.md)

---

## 2026-07-07 — MIC185: self-test dblClick, HoldBusy, StopDataSources перед настройками

**Задача:** Воспроизвести и устранить ESocketError при dblClick/редактировании MIC185 в настройках во время или сразу после активного опроса; добавить автотест пути UI.

**Сделано:**
- `RuntimeHoldBusy` при `RequestStop` — порт помечен занятым до disconnect worker-thread.
- Порядок `Disconnect`: закрытие сокета до снятия из TCP-реестра.
- `btnSettings`: `StopDataSources` перед `ShowRecorderSettingsDialog`.
- `Mic185SourceConnected` без лишнего TCP при live endpoint.
- CLI `--selftest-mic185-settings`, `DebugEditMic185Source`, счётчик probe TCP.
- Сборка `RecorderLnx.lpi` — OK.

**Документация:** [errors/2026-07-07-mic185-dblclick-socket-busy.md](errors/2026-07-07-mic185-dblclick-socket-busy.md)

---

## 2026-07-07 — MIC185: runtime endpoint (v2, занятый порт при опросе)

**Задача:** dblClick на MIC185 при активном просмотре всё ещё давал ESocketError — второй TCP на :4000.

**Сделано:**
- `uRecorderMic185Runtime.pas` — реестр busy endpoint на уровне `TRecorderMic185Device`.
- `TryConnect` / `ReadDeviceInfo` не открывают сокет, если порт занят.
- Диалог: состояние «Опрос активен»; лог в `LogWindows.log`.
- Сборка `RecorderLnx.lpi` — OK.

**Документация:** [errors/2026-07-07-mic185-dblclick-socket-busy.md](errors/2026-07-07-mic185-dblclick-socket-busy.md)

---

## 2026-07-07 — MIC185: dblClick при активном опросе (занятый порт 4000)

**Задача:** При dblClick на MIC185 во время просмотра/записи — ESocketError timeout; не открывать второй TCP-клиент; логирование и устойчивость.

**Сделано:**
- Реестр live-сессии `TRecorderMic185DataSource` — `ReadDeviceInfo` берёт sn/версию из кэша без TCP.
- `RecorderMic185Log` → `LogWindows.log`.
- `TryWriteBytes` — IOCTL не бросает `ESocketError` наружу.
- Skill `recorderlnx`: всегда сам запускать логирование и итерации по ошибке.

**Документация:** [errors/2026-07-07-mic185-dblclick-socket-busy.md](errors/2026-07-07-mic185-dblclick-socket-busy.md)

---

## 2026-07-07 — MIC185: dblClick в дереве устройств (диалог настройки)

**Задача:** При двойном клике по MIC185 в дереве устройств RecorderLnx возникала ошибка (останов в `TInetSocket.Create`).

**Сделано:**
- Перед `TInetSocket.Create` добавлен TCP-probe (`RecorderMic140TcpProbe`), как у MIC-140 — без исключения при недоступном приборе.
- `RecorderMic185ReadDeviceInfo` использует `TryConnect` вместо `Connect`.
- Исправлены адреса каналов в `Format`: `MIC183_185-{%d-%d}` вместо ошибочного `{3-%d}`.

**Документация:** [Docs/devices/mic185/recorderlnx_integration.md](Docs/devices/mic185/recorderlnx_integration.md)

---

## 2026-07-06 — Документация MIC185: полное обновление Docs/devices/mic185

**Задача:** Синхронизировать документацию прибора с наработками стенда, temp, стабильностью.

**Сделано:**
- Новый [Docs/devices/mic185/test_stand.md](Docs/devices/mic185/test_stand.md).
- Обновлены README, protocol, architecture, defaults, source_map, temperature_channels, windev_mic185_test.
- Ссылки из Tests/mic185/README.md.

---

## 2026-07-06 — MIC183/185 GUI: стабильность после Start (RLM)

**Задача:** Устранить падение/зависание GUI через некоторое время после Start.

**Сделано:**
- Drain пакетов: короткий timeout (2 ms) после первого чтения; не блокировать по 500 ms × 64.
- Лог: append в файл вместо Load+Save; лимит memo 400 / буфер 3000 строк.
- Таймер acquire: `fAcquireBusy`, без ShowMessage/btnStopClick из timer.
- Режим `--stress` (120 с, ~1000 блоков) для регрессии.

**Документация:** [Tests/mic185/errors/mic185_acquire_stability.md](Tests/mic185/errors/mic185_acquire_stability.md)

---

## 2026-07-06 — MIC183/185: температурные каналы (LM74, 1 Гц)

**Задача:** Разобраться, почему temp не работают в стенде; как в Recorder; есть ли ГХ; задокументировать.

**Сделано:**
- Документ [Docs/devices/mic185/temperature_channels.md](Docs/devices/mic185/temperature_channels.md): отдельные пакеты `dev_id=2`, 1 Гц, `ConvLM74CodeToC` (×0.0625), **без ГХ**.
- В стенде: `Mic185ConvLM74CodeToC` + диапазон −50…100 °C; `ReadMeasDataBlock` сливает пачку пакетов (temp не теряется за meas 100 Гц).

**Файлы:** `uMic185MebiusTcpProtocol.pas`, `uMic185Constants.pas`

---

## 2026-07-06 — MIC183/185 GUI: время работы и раскладка шапки

**Задача:** Убрать перекрытие надписей кнопками; показать время работы и сверку `blocks × period ≈ uptime`.

**Сделано:**
- Статистика (`Packets/Blocks`, `Uptime`, `Recorder ref`) вынесена на отдельную строку под кнопками.
- Добавлен `lblWorkTime`: `Uptime` и `blocks×period` (period = `tmrAcquire.Interval`, 200 ms).
- Зелёный/красный цвет при совпадении/расхождении uptime и blocks×period.

**Файлы:** `Tests/mic185/uMic185DebugForm.pas`, `.lfm`

---

## 2026-07-06 — MIC183/185 GUI: fix AV на Start (OnPrepareCanvas)

**Задача:** Устранить Access Violation при нажатии Start (ошибка в `brush.inc`, чтение по адресу $0).

**Сделано:**
- Исправлена сигнатура `sgChannelsPrepareCanvas`: LCL передаёт 4 параметра, лишний `aCanvas` читался как `nil`.
- Цвет фона задаётся через `TStringGrid(Sender).Canvas.Brush.Color`.

**Файлы:** `Tests/mic185/uMic185DebugForm.pas`

---

## 2026-07-06 — MIC183/185 GUI: fix Access Violation при Connect

**Задача:** Устранить падение с Access Violation при нажатии Connect в GUI стенда MIC185.

**Сделано:**
- `OnPrepareCanvas` больше не читает `sgChannels.Cells` (reentrancy LCL) — флаг `fChannelMatch[]`.
- `InitChannelGrid` / `UpdateChannelGridFromBlock` обёрнуты в `BeginUpdate`/`EndUpdate`.
- Убрана прямая запись в Memo из `btnConnectClick`; лог только через `tmrLog`.
- При ошибке Connect — `Disconnect` без `ReleaseDevice` (таймеры не обращаются к уничтоженному объекту).
- Nil-guards для `fDev` в `ConfigureDevice`, `UpdateChannelGridFromBlock`, `FormDestroy` (отключение `tmrLog`).

**Файлы:** `Tests/mic185/uMic185DebugForm.pas`

---

## 2026-07-06 — MIC183/185: fix blob MSVC alignment, GUI Connect+Program, зелёная подсветка

**Задача:** Совпадение кодов АЦП с Recorder; зелёная подсветка совпадений; убрать кнопку Program (влить в Connect).

**Сделано:**
- **Критический fix:** `TMic185BaseChanSettings` — явные pad-поля под MSVC `#pragma pack(8)` (`BlockSize` был со смещением 6 вместо 8 → неверное программирование).
- Connect выполняет Connect + ProgramDevice (Recorder defaults).
- Кнопка Program скрыта; после Connect доступен сразу Start.
- Зелёная подсветка строк (Code/Ref/Δ/Match) при `OK`.

**Документация:** [Docs/devices/mic185/protocol.md](Docs/devices/mic185/protocol.md)

---

## 2026-07-06 — MIC183/185 GUI: счётчик пакетов и сверка кодов с Recorder

**Задача:** В GUI вывести счётчик пакетов, сравнение каналов с эталоном Recorder; программирование как в windev-примере.

**Сделано:**
- Счётчики `Packets` / `Blocks` в шапке формы (`RxDataPacketCount` в TCP-клиенте).
- Колонки таблицы: Code, Ref, Δ, Match + сводка `Recorder ref: OK/N mismatch`.
- Проверено на приборе s/n 157: Connect/Program/Start OK, коды АЦП читаются (не нули).

**Документация:** [Tests/mic185/README.md](Tests/mic185/README.md)

---

## 2026-07-06 — MIC183/185: выравнивание с windev mic185_test и сверка кодов АЦП

**Задача:** Скорректировать стенд и документацию по эталону `windev/examples/mebius.daq/tests/mic185_test`; программировать прибор с дефолтами Recorder; проверить коды АЦП.

**Сделано:**
- Исправлен парсер пакетов: смещение данных 12 байт (`INTERNAL_PACKET_HEADER` MSVC).
- `Mic185BuildSettings`: `GroupAddition = MOD_ADD_OFF (4)`; единица каналов «m» (коды).
- Модули `uMic185CodeVerify`, CLI `-verify-codes`, GUI `--verify`.
- Документация: [windev_mic185_test.md](Docs/devices/mic185/windev_mic185_test.md).

**Документация:** [Docs/devices/mic185/windev_mic185_test.md](Docs/devices/mic185/windev_mic185_test.md)

---

## 2026-07-06 — MIC183/185: документация дефолтов и кодов АЦП

**Задача:** Сохранить в документации настройки по умолчанию, доп. параметры коммутации и эталонные коды АЦП из Recorder.

**Сделано:**
- Новый [Docs/devices/mic185/defaults.md](Docs/devices/mic185/defaults.md): свойства канала, доп. свойства (коммутация, усреднение 128, 100/150 мкс), формула MaxFreq ≈ 105 Гц.
- Таблица кодов АЦП модуль 3, каналы 3-1…3-50 (эталон Recorder).
- Ссылки из `README.md`, `protocol.md`, `Tests/mic185/README.md`.

**Документация:** [Docs/devices/mic185/defaults.md](Docs/devices/mic185/defaults.md)

---

## 2026-07-06 — MIC183/185 GUI: исправлен AV при ручном Connect (лог в Memo)

**Задача:** Устранить падение при нажатии Connect в GUI (Access Violation на `Mic185Log` / `fDevice.Connect`).

**Сделано:**
- `uMic185DebugLog`: буфер строк + `Mic185LogPumpTo` вместо прямой записи в `Memo.Lines` из обработчиков кнопок.
- Форма: таймер `tmrLog` (150 ms) переносит новые строки в memo; `btnConnectClick` вызывает `EnsureDevice` явно.
- Режим `--connect` для автопроверки пути `btnConnectClick` без полного acquire.

**Документация:** [Tests/mic185/README.md](Tests/mic185/README.md)

---

## 2026-07-06 — MIC183/185: рабочий GUI/CLI, исправлен разбор пакетов

**Задача:** Довести стенд MIC185 до рабочего Connect/Start/сбор данных; устранить AV в GUI; автоматический прогон.

**Сделано:**
- Парсер meas-блоков: `sampl_count` — счётчик, не размер; учёт status ULONG; data `id_from` `0x3E904000`.
- `TryIoControl` пропускает data-пакеты в очереди (fix Start).
- Settings blob: `SerialNumber` + `SoftVersion` с прибора; `TimeoutMs` обновляет `IOTimeout` сокета.
- GUI: `CreateRecorderMic185Device`, отложенный `--auto`, `Mic185LogDetachLines` при автотесте.
- CLI/GUI auto: 10 блоков × 2 сэмпла × 64 канала — OK на `192.168.9.142:4000` s/n 157.
- Документация: `Tests/mic185/README.md`, обновлён `protocol.md`.

**Документация:** [Tests/mic185/README.md](Tests/mic185/README.md), [Docs/devices/mic185/protocol.md](Docs/devices/mic185/protocol.md)

---

## 2026-07-06 — MIC183/185 GUI: исправлен AV на Connect

**Задача:** Устранить Access Violation при нажатии Connect в `mic185_acquire_gui`.

**Сделано:**
- `EnsureDevice` всегда синхронизирует `fDev` с `fDevice` (раньше при `fDevice <> nil` выход без установки `fDev` → AV на `fDev.TrySetDeviceProperty`).
- Операции Connect/Program/Start/ReadBlock через `IRecorderDevice`; при ошибке Connect — `ReleaseDevice`.
- Явное подключение `uMic185Registration` в implementation формы.

**Документация:** [Docs/devices/mic185/README.md](Docs/devices/mic185/README.md)

---

## 2026-07-06 — MIC183/185: доработка стенда (сборка, temp/UTS)

**Задача:** Доправить пример MIC185: устранить ошибки сборки CLI/GUI, декоммутировать температуру и СЕВ вместе с тензоканалами.

**Сделано:**
- `uMic185DebugLog` — без LCL (`TStrings` вместо `TMemo`); CLI подключает юнит в `.lpi`.
- `ReadMeasDataBlock` в Mebius TCP: пропуск пакетов по `DEV_ID` (0=UTS, 1=meas, 2=temp).
- `TRecorderMic185Device.ReadBlock` сохраняет последние temp/UTS; GUI обновляет строки 65–70.
- Исправлен сломанный `TMebeHeader` и конструктор TCP-клиента.
- Сборка `mic185_acquire_test` и `mic185_acquire_gui` — OK.

**Документация:** [Docs/devices/mic185/README.md](Docs/devices/mic185/README.md)

---

## 2026-07-06 — MIC183/185: GUI-стенд с логом и таблицей каналов

**Задача:** Помимо CLI сделать форму с состоянием подключения, поканальными значениями и логом; приложение не закрывается сразу.

**Сделано:**
- `mic185_acquire_gui` — форма Connect/Program/Start/Stop, таблица каналов, таймер чтения блоков.
- `uMic185DebugLog.pas` — лог в `mic185_protocol_debug.log` и на форме.
- CLI тест пишет в тот же лог-файл.
- Сборка GUI — OK.

**Документация:** [Docs/devices/mic185/README.md](Docs/devices/mic185/README.md)

---

## 2026-07-06 — MIC185V2: документация и автономный тестовый стенд

**Задача:** Изучить оригинальные исходники MIC183/185, описать архитектуру и протокол; создать тест connect/program/read без зависимостей от каталога MIC-140.

**Сделано:**
- Документация в `Docs/devices/mic185/`: README, карта исходников, протокол Mebius TCP, архитектура (MIC185V2 vs legacy MIC0185).
- Автономный стенд `Tests/mic185/`: локальные копии `IRecorderDevice`, Mebius TCP-клиент, `TRecorderMic185Device`, консольный `mic185_acquire_test`.
- Дефолт прибора из конфигурации: `192.168.9.142:4000`, 20 каналов, Fs=10 Гц.
- Сборка `mic185_acquire_test.lpi` — OK (`lazbuild -B`).

**Документация:** [Docs/devices/mic185/README.md](Docs/devices/mic185/README.md)

---

## 2026-07-06 — Mic140ProtocolDebug: исправлен Exception в Connect при Run

**Задача:** При нажатии Run в Mic140ProtocolDebug_Codex падало исключение в `Connect`.

**Сделано:**
- Исправлена утечка `IRecorderDevice`: интерфейс освобождался в конце `FindAndConnect`, а форма держала «голый» `TRecorderMic140Device*` → повторный Run обращался к уничтоженному объекту.
- Добавлено поле `m_Device: IRecorderDevice` в форме — удерживает refcount на всё время жизни формы.
- `Connect` обёрнут в `try/except` с `ShowMessage` вместо необработанного исключения.
- Убран автоматический `FindAndConnect` из `FormCreate` (подключение только по кнопке Run).

---

## 2026-07-03 — MIC-140: частота кварца = номинал 16 МГц (как в оригинальном Recorder)

**Задача:** Определить реальный механизм получения частоты кварца MIC-140 из оригинального Recorder и убрать некорректный подгон 15.8 МГц.

**Сделано:**
- Исследован оригинальный код Recorder (C++): `MIC140_96_rce/mic140_96mod.cpp` → `FREQ_CLK = 16000000`, `SetSelfClk(SELF_CLK)`, `SetFreqClk(FREQ_CLK)`.
- Подтверждено: `CCMC031EthernetInterface::MeasureFreqCCFromFreqModule` — пустая заглушка (`return ERROR_NOERROR`), **не модифицирует** `*freq`. Аналогичные заглушки в COM и USB интерфейсах. Функция вообще нигде не вызывается в кодовой базе.
- Удалена константа `MIC140_48_RECORDER_FREQ_CLK_HZ = 15800000` — значение 15.8 МГц **не существовало** в оригинальном коде.
- `ResolveDeviceTiming` упрощён: CMD12 (для PCI) → номинал 16 МГц (для Ethernet). Убрана попытка `MeasureClockViaTimerCounter` (MC031 DM не имеет доступных бегущих счётчиков через Ethernet).
- Удалён метод `MeasureClockViaTimerCounter` и связанные зонды.
- Enum `TMic140ClockMeasureMethod`: убраны `mcmTimerCounter`/`mcmFallbackNominal` → `mcmNominal`.
- Тест `mic140_clock_test.lpr` — чистый: CMD_TEST_LOAD + CMD_REPLY + ResolveDeviceTiming + сетка Fs.
- Результат: `Fclk = 16.0 MHz → Fs = 10.000000 Hz` (Scale=1, Period=640, Div=5000). Сетка точно совпадает с оригиналом.

---

## 2026-07-03 — MIC-140 Codex: persistent TCP + измерение кварца + рефакторинг

**Задача:** Persistent TCP, измерение freq_clk модуля вместо хардкода, рефакторинг MDP-протокола — выделить базовую `SendPacket`/`CallCommandArgs`, убрать дублирующий код.

**Сделано:**
- `TMic140MdpConnection` — persistent TCP (аналог `hMDP`). Private `SendPacket` + public `CallCommandArgs`/`CallCommand` — базовые методы, `MeasureModuleClockHz`/`ResolveDeviceTiming` — прикладные.
- Удалены standalone `Mic140MdpCallCommand`/`Mic140MdpCallCommandArgs` (одноразовые connect/close) — нигде не использовались.
- Удалён `uMic140ClockMeasure.pas` — типы и логика перенесены в `uMic140Device`.
- Удалена `ProgramScan`-заглушка и неиспользуемые хелперы (`Mic140AppendBytes`, дублирующий `Mic140MdpBuildPacket` в standalone и в классе).
- Тайминг-функции (`CodeToPeriod`, `PeriodToSport`, `IsrFactor`, etc.) сокращены до компактных inline-функций в `implementation`.
- Сборка `lazbuild` OK (0 errors).

**Исправление MeasureModuleClockHz — 3 бага:**
1. `Period = Word(65536) = 0` (Word overflow) → `lPeriod: LongWord`, вычисления в LongWord
2. Stop-команда слала 5 аргументов вместо 1 → `StopArgs: array[0..0]` (только `$FFFF`)
3. Отсутствовал fallback-пересчёт Period при measure_count=0 (как в CCIFC.CPP:1573)
- Добавлены WriteLn-логи на каждый шаг для отладки через консоль
- Добавлены описания ко всем функциям/методам юнита
- NB: оригинальный Recorder имел STUB для Ethernet (Mc031) — мы первые, кто делает через TCP

**Верификация CMD_MEASURE_FREQ_MODULE через Ethernet:**
- Консольный тестер `mic140_clock_test.lpr`: CMD_TEST_LOAD+CMD_REPLY OK, CMD12 возвращает stale-данные от CMD_REPLY (firmware MC031 не обрабатывает CMD=12)
- Fallback изменён с 16 МГц (номинал кварца) на **15.8 МГц** (`MIC140_48_RECORDER_FREQ_CLK_HZ`) — калиброванное значение из конфигурации оригинального Recorder
- Результат: `Fclk=15.800 МГц → Fs=9.875 Hz` (при Scale=1, Period=640, Div=5000) — сетка Fs сходится

**Чистка остальных юнитов:**
- `uRecorderAcquisitionTypes` — удалены неиспользуемые типы `TRecorderTagFrameBlock`, `TRecorderChanDataDesc`, `TRecorderChanDataDescBatch`, `TRecorderScanHandlerEvent` и 8 функций вокруг них (315→57 строк).
- `uRecorderDeviceInterfaces` — убраны неиспользуемые `AddRef`/`Release`, `GetChannelUnitName`/`GetChannelModuleType`, избыточные комментарии (336→199).
- `uMic140Registration` — компактные имена, убраны избыточные комментарии, `Mic140TcpProbe`→`TcpProbe` (305→169).
- `uMic140DebugForm` — убраны лишние комментарии (142→100).

**Файлы:** `Tests/Mic140ProtocolDebug_Codex/device/` — все `.pas` юниты  
**Документация:** `errors/2026-07-03-mic140-average-count-recorder-match.md`

---

## 2026-06-23 — MIC-140 КТХС: mV-пайплайн и TIn-калибровка

**Задача:** RecorderLnx ~490 °C vs Recorder ~520 °C.

**Причина:** T_КТХС читался через ГХ термопары AIN-канала; для TIn после аппаратной ГХ значение уже в °C, лишняя `thermo.Eval` занижала T_спая и недокомпенсировала ~30 °C. Не загружалась аппаратная ГХ из `Calibr\hardware\MIC140\snCCCC\TIn\`.

**Сделано:**
- Цепочка КТХС: `код→мВ (аппаратная)` → `+inverse(термопара, T_КТХС)` → `forward(термопара, мВ)`.
- T_КТХС: TIn hardware → °C (или + своя ГХ T-канала, если есть).
- Загрузка `TIn\NN.csv`, привязка к тегам `2-t1`… при старте.
- Сборка OK.

**Файлы:** `Device/MIC140/uRecorderMic140DataSource.pas`

---

## 2026-06-23 — MIC-140 КТХС: цепочка как в ScanMIC140

**Задача:** Recorder 520 °C, RecorderLnx 495 °C — неполная компенсация холодного спая.

**Причина:** В оригинале (`ScanMIC140::Decommutation`) КТХС: `hardware Eval(code) + tare->EvalInverse(T_junction)` → `tare->Eval`. В RecorderLnx mV КТХС прибавлялись к сырым кодам, инверсия шла через полную цепочку ГХ (аппаратная + термопара).

**Сделано:**
- Раздельные `TransformTagHardwareValue`, `TransformTagThermocoupleValue`, `InvertTagThermocoupleValue`.
- КТХС: аппаратная ГХ → + inverse(термопара, T_КТХС+offset) → forward(термопара).
- T_КТХС: hardware(T-тег) + thermo(кривая канала), как `tar->Eval(tc_->loc_data)`.
- `PublishBlock(..., AValuesAlreadyTransformed)` для готовых °C.
- Сборка OK.

**Файлы:** `Core/uRecorderTags.pas`, `Device/MIC140/uRecorderMic140DataSource.pas`

---

## 2026-06-23 — SDB термопары: кириллические пути (K_ГОСТ Р 8.585-2001.csv)

**Задача:** `thermocouple curve was not loaded` для `ГОСТ\Термопары\K_ГОСТ Р 8.585-2001` при наличии файла на диске.

**Причина:** `ChangeFileExt` в `RecorderSdbNormalizeKey` воспринимал `.585-2001` в имени `K_ГОСТ Р 8.585-2001` как расширение файла и обрезал ключ до `K_ГОСТ Р 8` → искался несуществующий `K_ГОСТ Р 8.csv`.

**Сделано:**
- `RecorderSdbNormalizeKey` снимает только суффиксы `.xml`/`.csv`.
- То же для `RecorderMeraThermocoupleDisplayName`.
- В лог ошибки добавлен полный путь `csv=...`.

**Сделано:**
- `FileExistsUTF8` в `uRecorderSdbStore`, `uRecorderSdbPropBag`, `uRecorderMeraSdbThermocouples`.
- `RecorderMeraLoadThermocoupleCalibration` — SDB + запасная загрузка CSV.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `SDB/uRecorderSdbStore.pas`, `SDB/uRecorderSdbPropBag.pas`, `Core/uRecorderMeraSdbThermocouples.pas`, `Device/MIC140/uRecorderMic140DataSource.pas`

---

## 2026-06-23 — MIC-140: исправлен сбой serial=76 (неверный cast IRecorderDevice)

**Задача:** После фикса CCSerNo путь к ГХ стал `sn0076` вместо `sn0164`. В логе Connect: `ccSerNo=164`, сразу после — `ccSerNo=76`.

**Причина:** `TRecorderMic140Device(fDevice)` при `fDevice: IRecorderDevice` в FPC читает не тот объект; firmware на Connect записывалась правильно, `GetDeviceSerial` — из мусора.

**Сделано:**
- Поле `fMic140Device: TRecorderMic140Device` + `fDevice := fMic140Device` (без cast через interface).
- `fHardwareCalibrSerial` кэшируется в `Connect` сразу после `ReadFirmware`.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `Device/MIC140/uRecorderMic140DataSource.pas`

---

## 2026-06-23 — Аппаратная ГХ MIC-140: серийник sn0164 (CCSerNo)

**Задача (переформулировка):** КТХС и температурный расчёт не работали: аппаратная ГХ искалась в `sn0115`/`sn0155` вместо `sn0164`; DevSerNo=155 совпадает с последним октетом IP, а не с с/н MIC (CCSerNo=164).

**Сделано:**
- `RecorderMic140HardwareCalibrSerialFromFirmware` — только CCSerNo при известном CCType (как `owner->DeviceInfo.SerialNo` в MC031); DevSerNo для каталога calibr не используется.
- `RecorderMic140DisplaySerialFromFirmware` / `RecorderMic140HostLastOctet` — в UI и диалоге показывается CCSerNo, если DevSerNo = октет IP.
- `ResolveDeviceSerialForTag` и `RebuildMic140SourceConfigsFromTags` игнорируют устаревший `mic140DeviceSerial` = октет IP из конфига.
- Лог при старте: `devSerNo / ccSerNo / ccType -> hardware calibr serial`.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `Device/MIC140/uRecorderMic140LegacyProtocol.pas`, `Device/MIC140/uRecorderMic140DataSource.pas`, `Device/MIC140/UI/uRecorderMic140SettingsDialog.pas`, `UI/uRecorderSettingsDialog.pas`

**Документация:** [mic140_protocol.md](Docs/mic140_protocol.md)

---

## 2026-06-22 — КТХС MIC-140: применение компенсации холодного спая

**Задача (переформулировка):** Доработать КТХС для термопарных каналов MIC-140 — при включённой компенсации температура холодного спая не учитывалась в измерении.

**Сделано:**
- Исправлен выбор T-канала КТХС: при `Mic140CjcDefault` и сохранённом `Mic140CjcChannel=0` используется штатная таблица соответствия AIn→TIn (`RecorderMic140TagEffectiveCjcChannel`), а не сырой ноль.
- При старте источника синхронизируется `Mic140CjcChannel` на тегах; для термопарных каналов автоматически включается `Mic140ThermoCompensationEnabled`, если флаг не был сохранён.
- При сохранении MIC-140 КТХС включается автоматически, если хотя бы один выбранный канал использует ГХ термопары.
- В лог добавлен `block tin=` при недоступности TIn в блоке сканирования.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `Device/MIC140/uRecorderMic140DataSource.pas`, `Device/MIC140/UI/uRecorderMic140SettingsDialog.pas`

**Документация:** [mic140_protocol.md](Docs/mic140_protocol.md) (раздел «ThermoComp, Default CJC и CJC»)

---

## 2026-06-22 — Глубина тренда 100 с и плавное обновление

**Задача (переформулировка):** При настройке глубины тренда 100 с накапливалось ~30 с истории, затем интерфейс заедал; нужно корректное окно по `DurationSec` и стабильный refresh.

**Сделано:**
- Скалярные теги (MemTag, CpuUsage) добавляют точку не чаще `UpdatePeriodSec`, а не на каждый тик данных (~0,3 с).
- Ёмкость `cBuffTrendQueue` пересчитана: `DurationSec / UpdatePeriodSec` с запасом.
- Обрезка точек старше окна: `TrimBeforeTime` в `cBuffTrendQueue`, `PopFront` в `uSharedQueue`.
- Лимит catch-up: не более 64 порций за один кадр для векторных каналов.
- Сборка `RecorderLnx.lpi` — OK.

**Файлы:** `UI/uRecorderTrendView.pas`, `SharedUtils/.../uOglChartTrend.pas`, `SharedUtils/.../uSharedQueue.pas`

**Документация:** [original-recorder-trend-component.md](Docs/original-recorder-trend-component.md), [notes_trend.md](cach/notes_trend.md) (план миграции на TOglChart)

---

## 2026-06-22 — Краш и кодировка в настройках тренда

**Задача (переформулировка):** В диалоге настроек тренда — кракозябры в подписях; после правки подписей падение при открытии (access violation на `fLineTagCombo`).

**Сделано:**
- Убрана лишняя `CP1251ToUTF8()` при `{$codepage UTF8}` — устранена двойная перекодировка подписей.
- Восстановлено `fLineTagCombo := TComboBox.Create(Self)` (случайно удалено при смене подписи «Линии» → «Тег»).
- Удалён неиспользуемый `LConvEncoding` из uses.

**Файлы:** `UI/uRecorderTrendSettingsDialog.pas`

**Документация:** [source-encoding.md](Docs/source-encoding.md), [notes_encoding_fix.md](cach/notes_encoding_fix.md)

---

## 2026-06-22 — MIC-140: combobox ГХ термопар из SDB

**Задача (переформулировка):** Заполнить combobox «ГХ термопары» шкалами из `Mera Files\sdb\ГОСТ\Термопары`; исправить пустой список, массовое назначение только выделенным каналам и сохранение настроек между открытиями MIC-140.

**Сделано:**
- Модуль `Core/uRecorderMeraSdbThermocouples.pas`: поиск папки термопар через `FindFirst`, кэш, рекурсивный fallback.
- Путь Mera Files: приоритет `C:\Mera Files`, `SyncMeraFilesPathFromUi` в настройках рекордера.
- Диалог канала MIC-140: список ГХ, кнопки SDB и сброс; bulk-edit по выделению строк grid (не по галочкам «канал используется»).
- `fMic140SourceConfigs` — сохранение channel settings в сессии settings dialog; restore из тегов.
- Кнопка аппаратной настройки в `uTagSettingsDialog`; исправлен dblclick Mera vs MIC-140 в дереве устройств.
- Сборка — OK (исправлен конфликт `GetEnvironmentVariable` с модулем `Windows`).

**Файлы:** `Core/uRecorderMeraSdbThermocouples.pas`, `Core/uRecorderMeraPaths.pas`, `Device/MIC140/UI/uRecorderMic140ChannelDialog.pas`, `Device/MIC140/UI/uRecorderMic140SettingsDialog.pas`, `UI/uRecorderSettingsDialog.pas`, `UI/uTagSettingsDialog.pas`

**Документация:** [sdb.md](Docs/sdb.md), [mic140_protocol.md](Docs/mic140_protocol.md), [settings_dialog.md](Docs/settings_dialog.md)

---

## Ранее

Подробный архив до введения этого файла — в [cach/notes_last_state.md](cach/notes_last_state.md) (записи от 18–19.06.2026).
