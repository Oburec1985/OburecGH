# Текущее состояние RecorderLnx

Краткое состояние: последние 40 записей (свежие сверху). Полная история — в архиве и журнале:

- [`notes_archive_2026-10.md`](./notes_archive_2026-10.md) — записи до 
2026-10-16
;
- [`..\iteration-log.md`](../iteration-log.md) — хронологический журнал проекта.

Новую запись добавлять сразу после этого блока.

---

## 2026-10-23 — OPC UA: переключатель адреса и общая подстрока имён

**Дополнение:** короткая форма имени больше не включает вложенные сегменты пути `Application.GVL` и т.п.; NodeId сокращается до namespace/типа, сегмента устройства после `|var|` и конечного имени узла. Снятие галки удаляет сокращённый адрес и прежний полный NodeId. При открытии старые имена с полным NodeId также нормализуются. Нажатие «Удалить» автоматически снимает галку без повторной обработки имён.
**Проверка:** forced Win64 build exit 0, 235063 строк: `lib/x86_64-win64/RecorderLnx-opc-address.exe`. Штатный `RecorderLnx.exe` занят PID 10940, поэтому оставлен работающему процессу; для проверки изменений используйте отдельный EXE или закройте штатный перед заменой.

**Запрос:** вместо кнопки «Добавить адрес» сделать галку, снимающую адрес из имён; при нескольких выбранных тегах показывать общую подстроку.
**Сделано:** `Добавлять адрес` теперь CheckBox: включает добавление NodeId к именам всех выбранных тегов, снятие удаляет адрес и восстанавливает короткое имя. Общая часть ищется как самая длинная UTF-8 подстрока в любой позиции, регистр игнорируется, `***` — только маркер совпадения. Для операции «Заменить» маркер `***` не попадает в итог.
**Проверка:** forced Win64 build exit 0: `lib/x86_64-win64/RecorderLnx-opc-name-check.exe` (235023 строк). Штатный `RecorderLnx.exe` был занят работающим процессом PID 29592, поэтому сборка выведена в отдельный EXE; запущенный процесс не затрагивал.
**Статус:** готово в исходниках; собранный проверочный EXE оставлен рядом с приложением. Визуальный smoke формы не запускался.

## 2026-10-23 — OPC UA: имя Recorder, stable link и офлайн-дерево

**Запрос:** отделить имя тега Recorder от имени/адреса OPC UA-узла; переживать обычное переименование тега; показывать сохранённое дерево при недоступном сервере; обновлять его только по кнопке; показывать полный путь OPC UA-канала в общих настройках тега.
**Сделано:** в `nodes[]` добавлен `recorderTagId`; runtime и OPC UA-редактор разрешают связь по stable `TRecorderTag.Id`, для старых конфигов оставлена миграция по `SourceId+NodeId`. В свойствах используемого узла редактируется `Имя тега Recorder`; NodeId не меняется. Успешные Browse-строки хранятся в `browseCache`; диалог загружает их офлайн и не обращается к серверу до `Обновить дерево`. Общий диалог тега показывает `OPC UA: client <endpoint> | <NodeId>`.
**Проверка:** `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` — exit 0, 234699 строк; `RecorderLnx.exe` запущен и оставался жив после 5 секунд, затем остановлен smoke-проверкой.
**Статус:** готово в исходниках; живая проверка Browse с отключённым PLC не выполнялась.

## 2026-10-22 — фильтр событий SQL-тренда и пометка неразрешимых замеров

**Запрос:** галочками вкл/выкл фильтровать события аварий на SQL-тренде; события, у которых данные в WinПОС не найдены, помечать иконкой при щелчке; в таблице пакетов иконкой подписывать, что замер не резолвится.
**Сделано:** `ShowTagRangeEvents` и `ShowOnlyUnresolvedEventPoints` в модели; `ListTimelineEvents` получил третий флаг и отдельное SQL-условие для `tag.range`; пять галочек в контекстном меню тренда и в диалоге настроек (общая / записи / аварии / уставки / только без замера), сохранение в проекте через `SqlShowTagRangeEvents` и `SqlShowOnlyUnresolvedEventPoints`. `TRecorderSqlDbMeraEvent.MeraFileCount` из SQL: событие записи без файлов пакета считается неразрешимым. На графике — иконка «нет данных» и пометка в подписи, кнопка «Открыть в WinПОС» блокируется с подсказкой; щелчок по маркеру сразу открывает карточку. В карточке ячейки «Замер»/«Путь MERA» рисуются с иконкой при нерезолвящемся пути, статус сообщает число таких пакетов.
**Проверка:** forced main build exit 0; новый `Tests/RecorderTests/SqlTrendEvents/SqlTrendEventsSmoke` — 17/17 PASS (дефолты, копирование флагов, детект неразрешимого события, наличие/чтение/запись галочек). Снимок диалога настроек на реальном виджетсете проверен визуально. `RecorderSqlDbMeraEventsTest` собирается чисто; падения `RecorderDataSourcesTest` и `RecorderFormModelTest` — существующие в них устаревшие имена типов, не связаны с правкой.
**Статус:** готово в исходниках, на MIC-315 не устанавливалось; живой прогон на реальной Firebird с событиями не выполнялся. Документация: `Docs/sql/sql-db-historical-trend.md`.

## 2026-10-19 — живые окна и восстановление, 0.1.189 (частично)

**Запрос:** убрать откат маркеров после release, пересчитывать временные/частотные линии во время движения; прямоугольник только EXC, экспонента только RESP. Снятие галки восстанавливает сигналы.
**Сделано:** release guard для реального LCL dispatch, объединение запросов 40 мс, независимые маски и отдельный уровень от глобального FFT-окна; cached DSP/FFT и коэффициенты, latest-wins и owned raw snapshots. Отключение во время drag сохраняет желаемый флаг. Финальный UI-таймер теперь живёт до snapshot.FilterRebuildPending=false, чтобы представить результат release/checkbox без refresh владельца. Временный trace удалён.
**Проверка:** DSP full/изоляция iwRectangular+iwExponential PASS; service latest-wins/delete/ring/saved/manual/response-fs PASS; отключение ring/saved восстанавливает каждый Y времени/SPM/FRF/ph/coh. 1с/57600Hz FFT65536: max31мс, 8 rebuild CPU93.75мс. UI live real-LM проходил, но synthetic native-capture прогоны нестабильны; создан GUI alias ImpactHammerNativeSmoke.exe с логом TEMP/ImpactHammerNativeSmoke.log для physical-input acceptance. Последний forced UI/GUI build PASS. Main Windows/Linux PASS были до последнего completion/checkbox изменения и требуют повтора.
**Статус:** частично. Нативная проверка остановлена физическим Escape пользователя через Computer Use; больше UI-действий не выполнять в этом ходе. Продолжение: повторить forced main Win/Linux, проверить native drag/release/checkbox по реальным линиям через GUI fixture, обновить итоговый SHA. Не устанавливалось. Последний app build lib/x86_64-win64/RecorderLnx-live-windows.exe ещё не содержит финальный completion fix; не выдавать его за финальный. Расследование errors/2026-10-19-frf-window-endpoint.md.

## 2026-10-19 — графическое редактирование окон FRF, 0.1.188

**Запрос:** убрать отдельные ползунки окон с компонента; экспоненту настраивать визуальными маркерами, прямоугольное окно — курсорами, как в оригинальном plgFrf.
**Сделано:** четыре native trackbar заменены графическими границами прямоугольника и оранжевой экспонентой с двумя маркерами; preview во время drag, применение при отпускании, отмена Escape/потерей захвата. Независимый конец экспоненты передан в DSP с физическим временем; raw-замеры не изменяются.
**Проверка:** forced Windows/Linux main builds PASS; полный DSP suite PASS; UI graph gestures/GL readback и route-spinner PASS, оранжевые маркеры проверены на снимке. Service focused manual-portion, response-fs и window-integration PASS. Полный service suite не прошёл соседнюю проверку цвета `half maximum FRF maps yellow`; общий RunIntegration также имеет ошибку deferred-stop за пределами оконной секции — эти проверки не объявлены успешными.
**Артефакт:** lib/x86_64-win64/RecorderLnx-graph-windows.exe, SHA256 4703A9D744B8027D9A466597364FDF82BFF68C497CE0BD3C36232089EA93E708. Не установлен.
**Статус:** оконный сценарий готов; подробности errors/2026-10-19-frf-window-endpoint.md. Соседние service-регрессии остаются отдельным ограничением проверки.

## 2026-10-19 18:53 — удалены корневые дубли LFM

**Запрос:** убрать `.lfm` из корня RecorderLnx и определить назначение копий в каталоге сборки.
**Сделано:** 41 устаревший корневой дубликат удалён; исходные формы оставлены рядом с `.pas` в тематических каталогах; добавлен ignore `/*.lfm`. Подтверждено, что 52 `.lfm` в `lib/x86_64-win64` — штатные промежуточные ресурсы Lazarus/FPC.
**Проверка:** корень содержит 0 `.lfm`; forced-сборка `RecorderLnx_lfm_verify.exe` завершилась успешно при запущенном основном приложении.
**Статус:** готово. Подробности: `errors/2026-10-19-duplicate-lfm-artifacts.md`.

## 2026-10-16 — поиск тега прямо в комбобоксе

**Запрос:** убрать отдельные Edit поиска у тегов маршрута, предлагать совпадения при вводе в сам ComboBox.
**Сделано:** три редактируемых ComboBox с cached substring suggestions по имени/адресу/описанию; отдельные поля удалены из PAS/LFM. Native dropdown показывает кандидатов, выбор/Enter подтверждает stable TagId; незавершённый ввод не меняет модель, Escape восстанавливает выбор. Prefix autocomplete LCL не используется, т.к. заменяет ввод и преждевременно вызывает Select.
**Проверка:** forced main/UI builds OK; route-tag-sync и route-spinner PASS. Подстрока/регистр/address/description, отсутствие совпадений, Enter, Escape, очистка и повторное открытие; readonly output отфильтрован. Windows screenshot проверен без отдельных полей.
**Статус:** готово lib/x86_64-win64/RecorderLnx-inline-tag-combo.exe SHA256B0340E09D9813F0E903D0CD54C9443BF1546B8B8BC78ED8B97F4B363B3671DC7, без установки. Docs/frf-route-automation.md обновлён.

## 2026-10-16 — автоматика маршрута, конфигурация и IDE

**Запрос:** авторежим «На точке → съём → сохранить → След. шаг», перезапись отдельно, searchable combos/импульс; вынести route.ini в конфигурацию; исправить отсутствующий класс дизайнера; перенести значения в FRF display и Auto под tag-sync.
**Сделано:** service-owned worker/latch/pulse, выход через external-write queue, skip сохранённого шага без перезаписи, ошибка без движения, отмена/Stop/destruct сбрасывают0. Авто работает без виджета; UI/runtime flags не сбрасывают RAM. Модельv16 с roundtrip. Routev3 config/results separation, Captured определяется MERA, старый route.ini read-only migration. Явный active-project context исключает запись тестов в persisteddefault. Галка значений в FRF display, AutoLeft198Top80. Пакет и IDE зарегистрировали TSharedColorCheckTable.
**Проверка:** forced main/service/UI/model/route/package/IDE builds OK; auto capture/save/skip/overwrite/hold/hidden/cancel/Stop/destruct/savefail PASS, manual и routepoint PASS; UI tag-sync/spinner/MDB/livegeometry PASS, modelroundtrip и configmigration PASS. Windows layout screenshot проверен. Аппаратная команда не испытывалась; Linux UI не запускался.
**Артефакт:** lib/x86_64-win64/RecorderLnx-route-auto.exe SHA2563D8C4C2F18AE264534D3AC68E180CDCBC813804FCD2781E616BE4BCE6A9FCA79, приложение не устанавливалось. IDE установлена C:/lazarus/lazarus.exe SHA2563ACF32A253D2134D3F5A4161619B552223D19BEA3AADD3F3917F78160789F1F1, предыдущая сохранена как lazarus.before-shared-table-40be0f668d5747f4a31a2a210611bcd5.exe. Новая IDE не запускалась.
**Статус:** готово; Docs/frf-route-automation.md, Docs/frf-route-storage.md и errors/2026-10-16-shared-table-designer-registration.md. Отмена ждёт текущую файловую запись, программный импульс не является аппаратным realtime.

## 2026-10-16 21:12 — пояснения к захвату FRF удара

**Запрос:** добавить короткие русские комментарии к поиску триггера, накоплению
истории удара и синхронизации каналов воздействия и отклика.
**Сделано:** пояснены порог/гистерезис/пре-триггер, владение capture-буферами,
независимые временные ряды, ручная общая граница и пересчёт откликов по своей Fs.
**Проверка:** Погоняла приняла комментарии; `lazbuild -B RecorderLnx.lpi` — exit 0.
**Статус:** готово; логика захвата не менялась.

## 2026-10-16 — ручная частотная полоса виброоценки

**Запрос:** задавать границы полосы компонента вручную, а не только выбирать
всю полосу или готовую полосу проекта.
**Сделано:** вариант «Задать вручную», поля «От/До» в Гц, собственные сохраняемые
границы компонента; единый диапазон для амплитуды, частоты и MAX, без изменения
глобальных полос. Версия 0.1.187.
**Проверка:** forced main/core/UI сборки OK; реальные core/UI smoke PASS:
сохранение/повторное открытие, ввод/ошибка обратных границ, NaN/Inf, большой
пик вне полосы, границы вне спектра, hidden MAX и сброс при смене диапазона.
**Статус:** готово локально _buildverify_vib187/RecorderLnx.exe; установки не было.
Контракт: Docs/vibration-estimate-sweep.md.

## 2026-10-16 — умная настройка АФЧХ

**Запрос:** дерево узлов АЧХ/Фаза/FRF, справа таблица имя/Fs и поиск, групповой drag, настройки осей вместе внизу; авто RMS/тахо и варианты чтения частоты.
**Сделано:** LFM-диалог из трёх панелей со splitters, тип принадлежит узлу. Configure-only resolver находит RMS в полосе и её 1*tacho, существующие phase/FRF/f1/Tacho результаты; scalar X last, vector МО/спектр/тахо. Автопривязки display-only, hint+блокировка; shared search включает combos и сохраняет identity. LogX/Y реально применяются, новые поля Assign/GUI save/load с legacy inference. Runtime commit только по новому Y, без загрязнения mean/max от X-only.
**Проверка:** forced main/UI/focused binding builds OK; UI smoke table/search/group-drag/nodekind/axes/cancel/commit/RMS-lock PASS, screenshot visual Windows; binding/roundtrip/legacy и runtime XY/mean/same-tag PASS. Общий старый FormModel test имеет посторонние CameraYaw/Pitch/Roll ошибки, поэтому АФЧХ проверяется отдельной целью FrequencyResponseBindingTest, старый файл не менялся.
**Ограничения:** компонент использует существующие расчёты, не создаёт FFT/тахо скрыто; сложная формула полосы не считается однозначным тахо. У независимых RMS/тахо нет общего frame ID, при Y читается последнее X. Linux UI в этой итерации не запускался.
**Статус:** готово в lib/x86_64-win64/RecorderLnx-smart-afchx.exe, SHA25634BD6E5C2C11BB8DB3AD1D9A53CC277D40F70208A7588BACA6B798E6D54A096D; без установки. Docs/frequency-response-smart-bindings.md.

## 2026-10-16 — короткие MERA-имена и единственный формат FRF

**Запрос:** имя тега + номер + короткий тип линии; frf вместо aka; не хранить curve.frf, просмотр из MERA.
**Сделано:** каналы/файлы tag_N_exc/time/frf/ph/coh/spm (exc_spm для спектра воздействия), исходные имена/ID отдельно в metadata. Новая запись point/frf/session.mera; старый aka читается. JSON/curve.frf fallback удалён; route только отмечает уже committed MERA. Старый curve.frf удаляется после успешного commit следующего сохранения, массовой очистки существующих данных нет.
**Проверка:** forced main/service/UI/codec/route builds OK; route navigation, manual portion, route spinner, FrfRoute и ImpactSession проверки. MERA roundtrip/повреждение/Unicode; текущие RAM замеры сохраняются. Сборка lib/x86_64-win64/RecorderLnx-frf-mera.exe, без установки.
**Статус:** готово; правила сохранения описаны в Docs/aka-response-sampling.md.

## 2026-10-16 — запрос локальной установки MDB notify

**Запрос:** установить новую версию локально.
**Проверка:** подготовлен RecorderLnx-mdb-notify.exe, SHA2565CD6E89C89BBC110F7330B18AE4195786CCEFBFF412C44D4A6A6C27B127A5D4F. Перед заменой обнаружен запущенный локальный RecorderLnx PID54308 из D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64\RecorderLnx.exe. Первоначально проверялся установленный ProgramFiles EXE, но активная локальная копия находится в build-каталоге; требуется закрытие перед обновлением используемой копии.
**Завершение:** после «закрыл» обновлён именно используемый build-каталог lib/x86_64-win64/RecorderLnx.exe. SHA2565CD6E89C89BBC110F7330B18AE4195786CCEFBFF412C44D4A6A6C27B127A5D4F совпал. Backup RecorderLnx.before-mdb-notify-20261016-80954fb2263a4d18bb5e5eb3e2e0ca80.exe рядом. Настройки и ProgramFiles-копия не менялись; приложение не запускалось.
**Статус:** локальная используемая копия обновлена.

## 2026-10-16 — MDB уведомляет FRF о смене каталога/объекта

**Запрос:** включение MDB не перечитывало путь после выбора другого объекта; пробросить нотификацию.
**Сделано:** общий UI-thread MDB context changed publisher с безопасной отпиской; manager/model уведомляют о commit/path/activate/clear. FRF widget и открытый route editor подписаны, coalesced QueueAsyncCall читает итоговый контекст после серии setters, Destroy удаляет подписки/async. Включение MDB сбрасывает приоритет ручного ExportPath и немедленно получает актуальный путь; EnsureRouteDirectory не возвращает старый ручной каталог. Недоступный контекст очищает путь вместо старого объекта.
**Проверка:** forced main/MDB/UI builds OK; MDB notifier unit, UI mdb-model-path (без ручного Refresh, switchback, старый manual→MDB), route-spinner PASS. Текущие замеры не пересоздаются; сохранённость пересчитывает прежний storage-change механизм.
**Статус:** готово локально lib/x86_64-win64/RecorderLnx-mdb-notify.exe; на MIC315 не установлено. Выбор MDB применяется существующей кнопкой «Применить» (draft combo не коммитим автоматически).

## 2026-10-16 — выбор точки сцены в просмотре результата

**Запрос:** отображать выбранную на 3D точку в просмотре результата, выровнять галки синхронизации и значений.
**Сделано:** виджет подписывается на UI scene selection с отпиской при Destroy; в review ищет привязанный шаг (текущий предпочтителен при повторяющейся точке), обновляет spin/сохранённые графики и показывает «Точка: подпись». Явный выбор отключает tag-sync, несохранённая RAM остаётся под прежней защитой. Галочки имеют общий Left198.
**Проверка:** forced main/UI builds OK; route smoke включает реальное включение review, scene-notification→saved step/time, scene-notification→empty step/label и равенство Left. Route-tag-sync и livegeometry smoke PASS.
**Статус:** готово локально lib/x86_64-win64/RecorderLnx-review-selection.exe; на MIC315 эта правка ещё не установлена.

## 2026-10-16 — установка block-sync на MIC-315

**Запрос:** переустановить подготовленную версию.
**Сделано:** на закрытом MIC-315 установлен RecorderLnx-aka-block-sync.exe как штатный EXE; предыдущий сохранён в C:\Mera Files\screens\rlnx-aka-block-sync-20261016\backup\RecorderLnx.exe.
**Проверка:** повторный preflight свободен, staged/installed SHA256 A74CC8A454C570797BBF1BB82F149C26EA085821D4A3A9A637844ACB4EEA3AD3 совпали; все62 файла настроек неизменны. DAQ/ЦАП не запускались.
**Статус:** установлено.

## 2026-10-16 — снимок колец, общая шкала DAC/ADC и резервные последние блоки

**Запрос:** показывать все накопленные блоки/частичную порцию; при буфере1с считать N=Fs полноценной секундой; связать Recorder и device time, а если интервалы не совмещаются — последние DAC/ADC блоки без синхро.
**Сделано:** ручная кнопка снимает кольца сразу, old futureAPI сохранён отдельно. Worker считает FRF по последнему общему интервалу; исходные времена сохранены. Разрывы/нетобщегоинтервала → зафиксированные на нажатии LastBlockSnapshot, DSP-копии обнуляются отдельно, явно помечены unsynchronized (SessionId сохраняется/показывает предупреждение после загрузки). Raw/SPM/FRF сохраняются из показанного снимка, не старой истории.
**Время:** Core/uRecorderBlockClock QPC/CLOCK_MONOTONIC, reversible device↔Recorder map на каждый Start. DAC фиксирует timestamp при submission, очередь не ретаймит flush; MX сохраняет native spacing и якорь Start, паузы не склеиваются. Явный Tag.BlockTimeDomain: SQL UTC/alarms/UI/общая область записи учитывают новую шкалу. Это host-привязка с неопределённостью, не аппаратный phase lock/drift calibration.
**Проверка:** forced main/service/UI/TimeSystem/DAC/MX builds OK. Ring exactN/partial/wrap/click-ownedfallback/rawpreservation/save/retry; manual/responseFs/routepoint; UIroute; TimeSystem UTC+обратное преобразование+restart; DACdelayflush/overflow/gaps; MXlate/restart PASS. SQLMeraEvents собран, запуск блокирован отсутствующей sqlite3.dll (не кодом изменения); отдельный старый EventQueue test имеет зависимость/cyclic compiler issue. Аудит без текущих кодовых блокеров.
**Статус:** готово локально lib/x86_64-win64/RecorderLnx-aka-block-sync.exe; на MIC315 ещё не установлено, аппаратный прогон новой версии не выполнялся.

## 2026-10-16 — установка диагностики ручного захвата на MIC-315

**Запрос:** установить подготовленную сборку после снимка ожидания обоих входов.
**Сделано:** сборка aka-deadline (route tag sync + бинарный MERA) загружена в C:\Mera Files\screens\rlnx-aka-deadline-20261016\RecorderLnx.exe.
**Проверка:** staged SHA256 11A4A34A2F522095CA983F6BFDDDDD431FA86E131D4C7FBCF2E126CAA9E29683 совпал. Первый preflight был свободен, но повторная проверка непосредственно перед заменой обнаружила запущенное приложение/bridge; операция прервана ДО backup/copy. Установленный EXE/настройки не менялись.
**Завершение:** после сообщения «закрыл» повторный preflight свободен. Предыдущий EXE сохранён в screens\rlnx-aka-deadline-20261016\backup; установленный EXE проверен SHA256 11A4A34A2F522095CA983F6BFDDDDD431FA86E131D4C7FBCF2E126CAA9E29683. Все62 файла настроек неизменны; DAQ не запускался.
**Статус:** установлено. Аппаратное ожидание диагностировать по AKA.Portion в следующем запуске.

## 2026-10-16 — ограничение зависшего ручного захвата АКА

**Запрос:** повторно нет данных после «Снять порцию», кнопка остаётся выключенной.
**Сделано:** ручной захват без полного интервала входов теперь отменяется через duration+5с, выдаёт статус с отсутствующим входом и разблокирует повторный съём. Старые реализации сохранены. Обработка DSP не прерывается. При команде/timeout пишется редкая диагностика времён всех входов (не на отсчёт). Первопричина текущего аппаратного ожидания пока не определена; запрошен снимок состояния.
**Проверка:** forced main/service builds OK; manual suite PASS, включая реальное ожидание6с, отсутствиеresponse-y, сохранность старого замера и успешный retry. MIC315 остаётся с работающим приложением; новая сборка lib/x86_64-win64/RecorderLnx-aka-deadline.exe ещё не установлена.
**Статус:** recovery исправлено; успешный аппаратный сценарий требует проверки и журналов новой версии.

## 2026-10-16 — синхронизация номера шага АКА с тегом

**Запрос:** в настройке маршрута выбрать тег номера шага; рядом со спином галка «Синхро с тегом», работает только Play, ручное переключение снимает её.
**Сделано:** persistent RoutePointTagId/Name (v15, Assign/Save/Load); общий поисковый tag picker в route editor. Виджет читает последний целый номер1..Count через cached tag только при Preview/Record, SelectRoutePoint сохраняет защиту RAM. Ручной спин отключает sync, Stop снимает/блокирует. На автопереходах config cache обновляется без пересоздания сервиса; MDB storage синхронизируется до Poll.
**Проверка:** forced main/model/UI/service builds OK; route-tag-sync, route-spinner, MDB/livegeometry/intensity, manual-portion и route-point PASS; независимый аудит без блокеров. На MIC315 эта новая сборка ещё не устанавливалась.
**Статус:** готово локально; lib/x86_64-win64/RecorderLnx-route-tag.exe.

## 2026-10-16 — бинарный MERA для маршрута, установка MIC-315

**Запрос:** ускорить Save секундной порции, хранить бинарный MERA как оригинальный плагин; повторно установить на MIC-315.
**Сделано:** новый standard R8 MERA point codec (.dat/.x, session.mera), raw/FRF/SPM/phase/coherence без текстовых массивов. Route Save копирует только выбранный замер. Новые данные в шаг/aka, предыдущая генерация сохраняется, JSON остаётся read fallback; прерванная замена выявляется явно. Статус объясняет отключение съёма при global Stop.
**Проверка:** forced main/service/UI/codec builds OK; manual-portion-only, route-point-only и реальный UI Save→next→second capture PASS. Codec native MERA reader/точный roundtrip/optional spectra/path traversal/truncation PASS. Benchmark1с44.1/54к: JSON2609мс, MERA15мс. Самостоятельная блокировка от перехода шага не воспроизведена; remote log содержит global Stop.
**Установка:** свободный MIC-315, только EXE; SHA256 3B041FA7F39E2B7C35E4191AB6531F68800E993A283896AB65EA44006F50AC4C совпал; все62 файла настроек без изменений. Backup C:\Mera Files\screens\rlnx-aka-mera-20261016\backup\RecorderLnx.exe. DAQ не запускался.
**Статус:** готово, установлено.

## 2026-10-16 — режимы АКА и начальная таблица каналов, установка MIC-315

**Запрос:** убрать Start/Arm/Stop, оставить триггер или ручной съём; каналы показывать до порции; установить на MIC-315.
**Сделано:** флажок «По триггеру» с lifecycle/reconfigure/rearm, ручной съём выключает триггер; видимая строка статуса с ожидаемыми входами. Configure делает первый snapshot. Пустое дисковое представление теперь возвращает metadata-only каналы вместо очистки легенды и не раскрывает старые RAM-данные.
**Проверка:** forced main/service/UI builds OK; manual-portion-only, route-point-only, response-fs-only и UI route-spinner/MDB-path/live-geometry/intensity-markers PASS. Независимый read-only аудит без блокеров. Аппаратный захват DAC+ADC не подтверждён: общий timestamp контракт остаётся открытым в errors/2026-10-16-manual-portion-independent-clocks.md.
**Установка:** на свободном MIC-315 заменён только EXE; SHA256 5446BE01CCEF26E6EA8280FEB9303A37D83AE3435A441B499FD3EC1C837F95BC совпал, все62 app.ini/config неизменны. Backup C:\Mera Files\screens\rlnx-aka-modes-20261016\backup\RecorderLnx.exe. Приложение/DAQ не запускались.
**Статус:** UI и установка готовы; фактический DAC/ADC capture остаётся проверять отдельно.

## 2026-10-16 — расследование отсутствия результата ручной порции

**Запрос:** после «Снять порцию» не появились осциллограммы и АКА.
**Сделано:** прочитаны remote log/config; воздействие DAC70.out, отклик MX248 2 AIn1. Найден дефект сравнения независимых эпох DAC/ADC через общий max latest; остановленный DAC пока не исключён. Независимый read-only аудит подтвердил риск фазовой ошибки при простом обнулении по callback.
**Проверка:** сопоставлены TryCapturePortion, DAC mirror и MX248 transport; remote настройки не менялись. Подробности errors/2026-10-16-manual-portion-independent-clocks.md.
**Статус:** расследование, запрошен статус после нажатия и состояние Play; исправление ещё не применено.

## 2026-10-16 — ручная порция установлена на MIC-315

**Запрос:** после штатного закрытия приложения завершить установку кнопки «Снять порцию».
**Сделано:** заменён только установленный RecorderLnx.exe подготовленной сборкой; предыдущий EXE сохранён в C:\Mera Files\screens\rlnx-aka-portion-20261016-1792165593301\backup.
**Проверка:** перед заменой RecorderLnx/bridge отсутствовали; SHA256 установленного EXE 80316B3FA1A00B4B34353E3C7258155D6CF8C3F50B5F5469C1C61CA7DD4C8776 совпал с проверенной сборкой. Все 62 файла app.ini/config неизменны. Приложение и сбор данных не запускались.
**Статус:** готово.

## 2026-10-16 — последовательное удаление осциллограмм

**Запрос:** устранить падение после удаления 2–3 осциллограмм подряд.
**Сделано:** views уничтожаются до моделей при Delete/Undo; график отключает
callbacks и освобождается раньше подписей и metadata; teardown не делает layout.
**Проверка:** forced main 0.1.186 OK; native -gh/-gl regression — 120 удалений
и 60 Undo с resize/repaint/message pump, exit 0, invalid free/heap errors нет.
**Статус:** lifetime-нарушения исправлены; точное первичное повреждение FCaption
не доказано: sandbox baseline тоже прошёл тест. Устранение исходного падения
пока не подтверждено. Готова изолированная сборка _buildverify_delete186.
Расследование: errors/2026-10-16-oscillogram-sequential-delete.md.

## 2026-10-16 — виброоценка произвольного входа и максимум свипа

**Запрос:** для невибрационного входа убрать интегралы/смену единиц, оставить
амплитуду и частоту; запоминать максимум прохода со сбросом Stop→Start.
**Сделано:** итоговая Tag.UnitName определяет доступные величины; режим MAX
хранит амплитуду и частоту одного кадра независимо от видимой страницы.
Явный lifecycle сбора сохраняет результат после Stop и сбрасывает при Start;
настройка сохраняется в проекте, диалог перенесён в designer LFM.
**Проверка:** forced main 0.1.185 и native VibrationUiSmoke — OK; isolated
VibrationSweepSmoke проверяет кадры без view, Stop/Start, paired frequency и NaN.
**Статус:** готово, финальные сборка и аудит PASS; аппаратный свип не запускался.
Контракт: Docs/vibration-estimate-sweep.md. На MIC-315 эта версия не установлена.

## 2026-10-16 — подготовка установки ручной порции на MIC-315

**Запрос:** установить сборку с кнопкой «Снять порцию» на MIC-315.
**Сделано:** проверенный EXE передан в C:\Mera Files\screens\rlnx-aka-portion-20261016-1792165593301; SHA256 staged совпал с локальным 80316B3FA1A00B4B34353E3C7258155D6CF8C3F50B5F5469C1C61CA7DD4C8776.
**Проверка:** повторный preflight перед заменой обнаружил запущенный RecorderLnx или bridge. Замена EXE и изменения настроек не выполнялись; процессы не останавливали.
**Статус:** заблокировано до штатного закрытия приложения на MIC-315; затем повторить backup, замену EXE и проверку хешей настроек.

## 2026-10-16 — ручная порция АКА после нажатия

**Запрос:** кнопкой снять воздействие и отклики после нажатия, без ударного порога, для установившегося синуса ЦАП.
**Сделано:** кнопка «Снять порцию» в ряду команд, единое snapshot-enabled. Одна порция заданной длительности без pretrigger; queue/stream boundary исключает старые данные, common start ждёт новые отсчёты всех каналов. Busy блокирует повтор, Stop отменяет, завершение не rearm. Старые измерения/файлы не меняются, сохранение обычной кнопкой текущего шага. Нужное окно расчёта выбирается существующими настройками.
**Проверка:** forced app/core/service/UI builds OK; manual-portion-only (scalar/block, mixedFs, response-ahead до клика, busy/Stop/normaltrigger), response-fs-only, route-point-only, полный ImpactHammerTest и 4 UI-targets PASS. UI проверяет реальный Click, состояние кнопок и отсутствие перекрытий. Аппаратный ЦАП-сеанс не запускался. Для сборки перепакован chart, старые orphan .ppu/.o перенесены в lib/x86_64-win64/stale-chart-cursor-20261016 (исходники не тронуты).
**Статус:** готово; RecorderLnx-aka-manual-portion.exe. Описание: Docs/aka-response-sampling.md.

## 2026-10-16 — оси осцилла, курсоры спектра и обновление MIC-315

**Запрос:** удалять пустые оси осциллографа; горизонтальный курсор спектра с
подписью и drag; исправить Shift; добавить слежение за локальным максимумом и
перенос подписи влево. Установить на MIC-315.
**Сделано:** plugin axes pruning; spectrum context/label/follower X1/X2; общий
Shift=max, Ctrl+Shift=min; обе подписи left/right; horizontal drag по своей оси.
**Проверка:** model/editor/native plugin (7 страниц), SpectrumUiSmoke EventBus и
CursorSnapSmoke mouse/key/drag/JSON — PASS; forced EXE/DLL 0.1.184 — OK.
**Установка:** 0.1.183 уже установлена; SHA совпали, все 62 файла config/app.ini
неизменны, backup screens\rlnx-0183-20261016-osc-spectrum\backup.
0.1.184 готова локально в _buildverify_tracking184, но preflight обнаружил
работающие RecorderLnx/bridge на MIC-315; процессов не останавливали, замен нет.
**Статус:** требуется штатно закрыть RecorderLnx для установки 0.1.184.

## 2026-10-16 — обновление MIC-315 до 0.1.182

Запрос: обновить RLNX на 192.168.15.84, сохранив настройки.
Forced EXE/плагины собраны изолированно; после параллельного обновления общего
chart повторены сборки chart/plugin/main. Native OscillogramRuntimeSmoke и
MX248SettingsSmoke PASS. Заменены только EXE, SampleInfoPlugin и LuaCalcPlugin.
Хеши установленных файлов проверены, remote plugin probe PASS. Деплой не писал
в app.ini/config. Из 62 наблюдаемых файлов два (default.config.json/default.gui.ini)
изменились за время итерации вне операций деплоя; они сохранены как есть,
не откатывались к исходному снимку. Bridge и настройки платы нами не менялись.
EXE SHA256 7BCCE9FD93A67EDB4C78550C764DF3B979A6F246BD94692D801974F0079A1E7A.
Backup: C:\Mera Files\screens\rlnx-update-0182-20261016\backup-152816.
Статус: готово; GUI и сбор после обновления не запускались.

## 2026-10-16 — АКА пересчитывается к Fs отклика

**Запрос:** при разных Fs воздействия и отклика приводить к Fs отклика, не к меньшей.
**Сделано:** общая подготовка пары во всех путях capture/rebuild/filter; индивидуальные Fs/FFT/частотные оси для разных откликов. Длительность и raw-данные сохраняются; raw-банки вмещают самый быстрый канал. Ресемплер с centered-sinc/anti-alias при изменении Fs, без экстраполяции; equal-rate путь сохранён.
**Проверка:** forced app/core/service builds OK; полный ImpactHammerTest PASS (phase, alias, up/down/fractional), --response-fs-only и --route-point-only PASS. Воздействие64Гц/отклики32+128Гц, перестановка, equalFs, rawcounts/time и повторное окно. 1с57.6→14.4кГц:31–47мс. Аппаратный сеанс не выполнялся.
**Статус:** готово; RecorderLnx-aka-response-fs.exe. Контракт: Docs/aka-response-sampling.md.

## 2026-10-16 — диагностика слабого отклика MX-248

Запрос: сравнить транспортные флаги с оригиналом Recorder. Read-only audit
core/codec/bridge и оригинального mx248 подтвердил совпадение amplifier,
diff/single, range, LPF, ICP, floating, ELECTR. Повторного ADC/gain scaling нет;
remote обе ГХ False, source/display=пКл, коэффициент тега 1. Сохранённые
настройки: charge amp=True, range1=±10000пКл, IEPEoff, ch1–2 single-ended.
AutoRange=True: metadata±32000 сами по себе не доказывают масштаб графика.
Найдены отдельные неисправленные ошибки: calibration index+1 при включении
калибратора, подпись диапазона2 «→10В» вместо оригинальных «→1В».
Они не объясняют текущий режим (калибратор выключен, range1).
Статус: сравнение выполнено, причина слабого отклика не установлена; нужен
номер канала/тип датчика и согласованный live readback без второй сессии.
Настройки/код не менялись, работающий Recorder не останавливался.
Подробности: errors/2026-10-16-mx248-weak-response-flags.md.

## 2026-10-16 — MX-248 multiedit установлен на MIC-315

Запрос: обновить RLNX на 192.168.15.84 после реализации групповой настройки.
Установлен проверенный forced-build EXE с Ctrl/Shift и ПКМ → Редактировать.
Recorder/bridge перед заменой не работали; force-kill и запись конфигов не нужны.
SHA256 установленного EXE: 2315582AA1D6C090B8BAE208769B78B0E506C3BE166A287895DECB4700947DED.
Резервная копия: C:\Mera Files\screens\RecorderLnx-before-multiedit-20261016-144256.exe.
Все 62 файла app.ini/config побайтно неизменны по SHA256. Сборка и UI smoke
прошли в предыдущей итерации; удалённый сбор/GUI после замены не запускался.
Статус: готово. Поведение: Device/PXI/MX248/Docs/README.md.

## 2026-10-16 — групповое редактирование каналов MX-248

**Запрос:** выбирать несколько каналов и редактировать их через контекстное меню.
**Сделано:** Ctrl/Shift multi-range выбор, ПКМ → «Редактировать», общий редактор
со смешанными значениями; точечный patch только изменённых полей выделенных
каналов. ПКМ по выделению сохраняет группу, по другой строке выбирает её.
Отмена сохраняет черновик; двойной щелчок IEPE прежний; аппаратные вызовы
остались только у общего Apply/OK. Конфиги пользователя/удалённый ПК не менялись.
**Проверка:** forced main build exit 0; расширенный PxiMx248SettingsSmoke PASS:
реальные Ctrl/Shift clicks, ПКМ, modal edit/Cancel, mixed/common/unselected,
IEPE и нулевые service counters до Apply. UI source UTF8; diff-check OK.
**Статус:** готово в исходниках и проверочной сборке, на MIC-315 не установлено.
**Документация:** Device/PXI/MX248/Docs/README.md, «Групповая настройка каналов».

## 2026-10-16 — имена каталогов MDB

Запрос: имена Obj_001/Reg_001 расходятся с каталогами Object_0001/Reg_0001.
Причина: AddNode использовал автонумерацию вместо введённого Name.
Изменено создание новых узлов: каталог равен имени; недопустимые символы
и занятые пути отклоняются явно. Добавлены проверки полного именованного пути.
Существующие каталоги не перенесены: это отдельная миграция реальных данных,
прежние XML и замеры сохраняются на своих путях. Mdb suite PASS.

## 2026-10-16 — FRF и несколько MDB-компонентов

Исправлен выбор базы FRF: последний явно применённый MDB-компонент имеет
приоритет перед первым компонентом проекта, включая неактивные страницы.
Forced app build OK; GUI smoke --mdb-model-path-only PASS с двумя моделями.
Хранение FRF остаётся объект/frf/track. Исправленный EXE подготовлен на MIC315,
запущенная удалённая программа и её настройки не изменены.

## 2026-10-16 — путь активного MDB-контекста MIC315

Запрос: неправильный путь при выборе объекта/испытания на MIC315.
Подтверждено: новая XML-ветка содержит перевёрнутые имена Test_001/Obj_002,
показанный путь соответствует этим данным; исходная Object_001/Test_001
игнорировалась загрузчиком. Исправлены порядок групп, сохранение выбранных ID
при обновлении и совместимость чтения legacy XML; пути из расположения файлов.
Проверка: Mdb PASS, чтение реальной legacy-ветки по UNC PASS; forced app build
exit 0. Удалённые XML/конфигурация не менялись; запущенный remote EXE ещё старый.
Подробности: errors/2026-10-16-mdb-context-path-mic315.md.

## 2026-10-16 — актуализация MIC-315 до 0.1.181 без изменения настроек

Запрос: актуализировать RLNX на 192.168.15.84. Принудительно собраны EXE,
bridge и плагины; SampleInfoPlugin собран изолированно из-за DLL, занятой
локальным Recorder. Native waveform smoke и CommandImagesSmoke PASS.
На удалённом ПК Recorder/bridge отсутствовали; обновлены только программные
файлы (EXE, два плагина, bridge), SHA256 всех четырёх проверены.
EXE: EEE1B9C0C57BB10786BB73EDF3AFF1D0AF608AF5E3702AB38AC01AD52B7BC3DB.
Backup: C:\Mera Files\screens\rlnx-update-0181-20261016\backup-142545.
Удалённый plugin probe PASS; 62 файла app.ini/config совпали до/после.
Статус: обновление готово, сбор данных не запускался. Installer 0.1.181
не создан: общий packaging остановился на locked DLL; развернуты свежие
проверенные бинарники напрямую, старый installer не использовался.

## 2026-10-16 — исправлен вход в редактор АФЧХ

**Запрос:** ошибка Unknown property TabOrder при входе в редактор компонента.
**Сделано:** удалён неподдерживаемый fColor.TabOrder у TColorButton; поля
статических controls и обработчики редактора явно опубликованы.
**Проверка:** новый FrequencyResponseUiSmoke воспроизвёл исходную ошибку;
после исправления public modal entry/resize/cancel — PASS. Версия 0.1.182.
**Статус:** исправлено в исходниках; без установки на удалённые ПК.

## 2026-10-16 — отключённые источники: серый цвет и скрытие тегов

**Запрос:** источник «Выкл» серый в дереве, его теги скрыты, аппаратную ошибку
из-за него не показывать.
**Сделано:** custom draw дерева с наследованием серого дочерними узлами;
active-регистрация учитывает Enabled, общий фильтр тегов проверяет Enabled до
virtual/MERA fallbacks. Существующий skip в аппаратной сводке сохранён.
**Проверка:** main forced build OK; новый visibility regression PASS (hardware,
virtual, file, manual, reenable). Общий Tags suite падает в прежнем EventBus
assertion TestTagBlockEstimates; визуальная проверка серого не выполнялась.
**Статус:** код готов, версия 0.1.181; удалённые ПК не менялись.

## 2026-10-16 — исправлены native view и иконка плагина MIC-315

Запрос: иконка отсутствует, при размещении Plugin view unavailable; конфиг не менять.
Причина view: неподдерживаемые published-свойства TToolBar ParentBiDiMode/BiDiMode
в uOscView.lfm. Удалены только две строки; metadata/state probe этот путь не покрывал.
Иконка: generic plugin-visual-component не был сопоставлен индексу; добавлен alias.
Проверка: forced app/plugin/icon smoke OK; direct OscViewSmoke и production native
harness локально PASS, включая waveform/clear/refill/recreate. На MIC-315 скрытый
SSH-тест создал native root, но не подтвердил framebuffer (скрытые окна, pixels=0).
Заменены только EXE и DLL; все 56 файлов проекта и app.ini неизменны по SHA256.
EXE SHA256 0F778E06FE8464A7D89CC165768534996775F80074A75A191FA270F626E8B80F;
DLL SHA256 37FBF65C7E881B3DB12221B2F685B164A9BD470A02E37B667DA5E2E0FEFFAFB5.
Backup: C:\Mera Files\screens\osc-native-fix-20261016\backup-binaries-141402.
Подробности: errors/2026-10-14-osc-plugin-production-native-smoke.md.
Статус: исправление установлено; видимый пользовательский GUI после замены не запускался.

## 2026-10-16 — проверка отсутствующего осциллографа MIC-315

Запрос: исправить отсутствующий plugin, не менять уже отредактированный конфиг.
Гипотеза пропущенной DLL опровергнута: файл установлен, global app.ini Count=1,
SampleInfoPlugin прописан; remote log содержит успешный [Plugin V2] loaded 1.3.
Forced isolated rebuild plugin/probe OK; свежая DLL побайтно совпала с удалённой
(SHA256 CF2BA260C60A069F5983CA7B6CD38B0117C66D5B4DB4EAF872C548338334DC6F).
Probe непосредственно установленной DLL на MIC-315: descriptor/state/lifecycle
PASS, exit 0. Ненужная замена бинарника не выполнялась. Пункт палитры находится
в выпадающей группе Графики, название Осциллограф, TypeId sample.oscillogram.
Все 56 файлов проекта и app.ini сверены до/после, не изменились.
Статус: отсутствие/ошибка загрузки не воспроизведены; нужен конкретный UI-симптом.

## 2026-10-16 — USB ЦАП на MIC-315: Creative PLAY! 3

Запрос: найти USB ID ЦАП и установить драйвер на 192.168.15.84.
Найден Sound Blaster PLAY! 3, VID_041E&PID_324D (audio interface MI_00).
Официальный пакет Creative SBP3_PCDRV_L12_1_01_08.exe проверен: Authenticode Valid,
Creative Technology Ltd. Извлечён штатным tar; INF содержит точное hardware ID.
pnputil /add-driver ksusbaud.inf /install завершён exit 0, опубликован oem45.inf.
Повторная PnP-проверка: Creative 1.16.1.14, служба KsUSBa64, ProblemCode=0,
Speakers/Microphone endpoints OK. WMI сразу после установки показывала старый
драйвер; актуальные DEVPKEY_Device_* подтвердили переключение.
Статус: готово; перезагрузка и генерация сигнала не выполнялись, PXI не трогался.
Источник: https://files.creative.com/manualdn/Drivers/100181/0x39E28843/SBP3_PCDRV_L12_1_01_08.exe

# 2026-10-23 — OPC UA offline tree and used-channel properties

- Old OPC UA configurations without `browseCache` now show saved used nodes in an explicit offline fallback branch.
- The used-channel tab has a resizable properties grid with Recorder name, endpoint, full connection string, NodeId, Browse attributes and live read fields.
- Recorder name is editable in the right properties grid and stays bound by NodeId/stable tag id.
- Verified by clean Lazarus build (234856 lines) and five-second Windows smoke run.

