# USB DAC: привязка зеркала по физическому отклику PXI

## 2026-10-29 — Точность по сетке АЦП и фактическим timestamps

Пользователь предположил ошибку сопоставления отсчётов разных частот и потребовал считать в часах обратной связи. Проверка кода: MX248 WindowsTransport задаёт FirstTimeSec=fSampleCursor/configuredFs, увеличивает cursor на фактически прочитанный SampleCount; DataSource переводит эту ось фиксированным Start-якорем в Recorder-domain и публикует first+J/rate. Arrival-time отдельных блоков в шкалу не подставляется; GetDeviceTime для абсолютной привязки этой веткой не используется.

В NCC CandidateValue восстанавливал индекс через Floor((t-times[0])*PollFrequencyHz), игнорируя фактическую пару timestamps; это уязвимость для неравномерной/отличной от заявленной шкалы, но само по себе не доказательство причины текущей фазовой ошибки на равномерном MX248. Дополнительно256точек/12мс использовались и для финального score, а последний шаг поиска5.86мкс превышает период512кГц1.95мкс. Требуется actual-timestamp bracketing и финальное NCC на сетке обратной связи с дробным уточнением; coarse256 остаётся только поиском области.

## 2026-10-29 — NCC, ручной k и итоговый MERA Freq

Пользователь запросил корреляцию формы с домасштабированием, редактируемый k и последнюю запомненную частоту в MERA. Нормированная корреляция убирает DC/усиление; первое совмещение ideal→filtered задаёт выбранное соответствие формы, повторное observed→observed уточняет интервал без постоянной ошибки фильтра. Отдельно сохраняется LS gain fit. Результат физической фазы ещё не подтверждён.

Подтверждена гонка независимых UI setter: Pump мог уже сформировать/отправить old-rate блок, пока publisher получил new-rate карту. Исправлено bounded command перед FillBlock + factor/pivot в том же FIFO slot, commit publisher перед данным WriteTimedBlock. Нет setter без frame pivot. Ранее записанные координаты не меняются; новый slope начинается непрерывно на границе. Provider обновляет численные часы без сброса фазы/elapsed; неподдерживаемый TagProvider отказывается до pending.

MERA writer теперь отдельно хранит последний положительный APollFrequencyHz успешного блока для итогового Freq, а исходную частоту оставляет для backfill. Тест подтверждает final44095 и точные старые X. Feedback/Core/Lifecycle110/Boundary18/MeraTimebase/Storage/MeraBlockStorage build+run0; main build0. NCC шумной пары Fs44088.0355 против true44088; CPU benchmark10s512кГц detector~.182s на рабочем ПК. Пакет0FF01720 staged на MIC315, физический retest ожидается.

## 2026-10-29 — Требование колокола и подтверждение отсутствия DC

Пользователь уточнил: требуется заменить именно выдаваемый калибровочный сигнал на колокол и совмещать максимумы, а не продолжать выдавать прямоугольник с детектором лепестка. Предыдущий пакет 8ADD14A3 сохранял прямоугольный сигнал; это явно подтверждено пользователю.

Пользователь аппаратно проверил режим постоянного уровня: постоянка не проходит. Это свидетельство AC-связи в измеряемой цепи; оно само по себе не локализует фильтр в SoundBlaster или входном тракте MX-248. Требуется пара одинаковых гладких колоколов, известные индексы исходных максимумов и измеренные максимумы отклика. Общий сдвиг определяется по первому максимуму, Fs_eff — по разности максимумов. Корреляция не нужна.

Реализовано: таблица Hann20мс во всех трёх провайдерах, доминирующая signed вершина и интерполяция параболой по трём точкам. GeneratedBellMarker=True в runtime пересчитывает source peak из фактической backend Fs; внешние explicit offset совместимы при False. Forced main/Feedback/Lifecycle/MeraTimebase build/run0; read-only аудит пройден. Пакет284DE9D4 скопирован и сверён. Остаточный риск: шум смещает максимум, поэтому физическая точность и успешное обнаружение на стенде ещё не подтверждены.

## 2026-10-29 — Отказ второго фронта после AC-lobe патча

Стенд: видимый отклик приблизительно через 220–250 мс после предварительного зеркала. LogWindows run6: first=6636.77291131678, baseline=.0014421569, diagnostic step_height=-.0044969678, noise_rms=.0002224179, второго midpoint нет. Старая диагностика перезаписывала высоту даже отвергнутыми кандидатами, поэтому это не доказывает высоту принятого первого фронта.

Подтверждены кодом два механизма: слабый ранний кандидат закреплял первый якорь, более сильный настоящий отклик вне его второго окна игнорировался; фиксированные 16 мс могли отсечь основной лепесток, после чего следующий кандидат начинался выше 50% и терял фронт. Связь именно с аппаратным отказом пока требует повторного запуска.

Исправление: наблюдать кандидаты и между метками, заменять первый существенно более сильным откликом вне корректной пары, не завершать поиск до общего timeout из-за одного ошибочного якоря. Окно продолжается до 16 мс после доминирующего пика, ограничено min(128 мс, 0.4 интервала меток), память выделяется при Configure. Правильная вторая метка с усилением >2 сначала рассматривается как пара. Диагностика высоты обновляется только принятой меткой; добавлены итоговые счётчики candidates/first_replacements. Корреляция не применяется.

Проверки: synthetic early transient -0.0045, noise RMS .000222, true AC markers .1; начало настоящего фронта через 15 мс после шумового trigger; вторая метка x2.1; интервал .1 с. Полный FeedbackTest проходит. Аппаратная калибровка новой сборкой ещё не подтверждена.

## Запрос и критерий

MIC315 192.168.15.84: USB DAC подключён к первому входу PXI. Выдать известный фронт, найти отклик, привязать временную ось зеркала и начало MERA к измеренному фронту. QPC не должен подменять время отклика. Дополнительно проверить изломы измеренного синуса при чистом зеркале.

## Подтверждено

### Исследование скачка частоты на виджете (без правки production)

Пользователь прислал шесть снимков одной/нескольких порций: начало с близкими периодами, затем видимый скачок отношения частот примерно вдвое. Журнал MIC315 подтвердил реальную установку сборки (updater SUCCESS и побайтная сверка). Последние DAC runs: submitted=mirrored, provider underruns=0, dropped_mirror=0, пустой native result. Это не доказательство отсутствия всех аналоговых/аппаратных сбоев. Сохранённая конфигурация содержит sync=false и feedbackTagId=0; live несохранённые настройки из этого выводить нельзя.

Найден и воспроизведён software-дефект вне DAC:

1. `uRecorderImpactHammerService.pas:873–877` дописывает отсчёты канала, уже покрывшего конец окна, пока ждёт другой канал. Блоки разных источников приходят независимо.
2. `uRecorderImpactHammer.pas:353–380` при переполнении фиксированного capture-банка оставляет каждый второй старый отсчёт; новые продолжает добавлять с родным шагом. Возникает неравномерная сетка X (2/Fs, затем 1/Fs).
3. `uRecorderImpactHammerService.pas:1648–1649` переносит истинные X в presentation без исправления; `uRecorderImpactHammerView.pas:925–933` использует лишь первые два X как единственный DX для всего Y. Плотный хвост растягивается и отображается с половинной частотой.

Диагностический probe вызывает production TRecorderImpactCapture, затем повторяет реальный расчёт X0+i*DX: окно .5sec, capacity502, оба синуса10Hz/Fs1000; первый канал доставлен до .7sec, второй задержан до .5sec. Получены450/501отсчётов; dt2/Fs=251 и dt1/Fs=198. Видимая частота первого канала10→5Hz, второго10Hz, ошибка сохранённых Y относительно исходного синуса0. Лог прочитан root: `C:\Users\User\AppData\Local\Temp\impact-capture-overflow-20261028\ImpactCaptureOverflowProbe.log`, RESULT confirmed. Следовательно механизм ступеньки доказан без DAC; принадлежность конкретной аппаратной порции нужно подтвердить её raw X/Y, которых на доступной шаре пока нет.

DAC путь отдельно прочитан: WaveProvider сохраняет fPhase, Session передаёт блок в backend и копирует те же Double в mirror queue; backend преобразует в Single и вызывает blocking WriteStream. Для текущих200кадров/Fs44100 длительность блока4.535147ms, фаза между FillBlock не сбрасывается. Шов именно генераторного/программного выходного буфера не найден.

Исправление ещё не вносилось (запрос — проверка): ограничивать каждый capture-канал концом окна с нужным пограничным отсчётом; не прореживать raw молча; рисовать по фактическим X либо валидированной равномерной сетке. Проверить задержанные mixed-Fs блоки и переполнение отдельной регрессией. Самостоятельные аналоговые изломы обычной осциллограммы этим пока не объяснены.

- Пользователь подтвердил физический Sound Blaster в списке и совпадение частоты спектра примерно в пределах 2 Гц. Гипотеза неверного масштаба времени по одному скриншоту не подтверждена.
- Генератор WaveProvider сохраняет фазу между блоками. 100 блоков по 2048, Fs44100, F140: максимальная ошибка относительно аналитического синуса 8.46e-12; генераторный шов в этом сценарии не обнаружен. Это не проверка native audio underrun или аналогового тракта.
- Прежняя карта DAC была host-estimated; обратная связь теперь задаёт start=edge-markerIndex/Fdac, последующие timestamps=start+frameIndex/Fdac.
- До front-lock зеркало удерживает предвыделенную историю; при timeout/gap/reset/overflow публикация не подменяется приблизительной. Fs/domain/разрывы feedback проверяются и после lock.
- Общий домен зеркала задаётся при EnsureMirrorTag/Configure до записи. Production mirror→record origin→MERA→standard reader проверен: первый Start4.1, следующий блок4.3, restart7.1 и portion index400.
- Обработка pending выполняется publisher-потоком; GUI читает snapshot. Завершение ждёт finite feedback, Join/финальный drain предшествуют окончательному чтению MirrorResult.
- Синхронизация при Play вставляет малый маркер и получает новую привязку на каждый пуск. Calibrate — конечный тест .05 normalized, .1sec тишины, .02sec импульса, общий поток2.4sec. Порог baseline-relative по умолчанию .01 единиц входа; это время порогового пересечения, не компенсация произвольной АЧХ/ФЧХ фильтров.

## Проверка / артефакты

- `cach/build-dac-feedback.log`: forced Win64 build238671lines, exit0, `lib/x86_64-win64/RecorderLnx-dac-feedback.exe`.
- `RecorderDacCoreTest`, `RecorderDacFeedbackTest`, `RecorderDacMeraTimebaseTest`: RESULT passed. Feedback-тест также проверяет timeout, cancel/restart, ADC reset/refill, pending overflow, шумную предысторию и неизвестное смещение host epoch.
- Независимый skill/runtime audit: исправлены ранний domain, RemoteAudio, GUI drain и гонка результата до final drain; последних stop-ship замечаний нет.
- Запрет default/RDP output для calibration; discovery сохраняет числовой выбранный endpoint, а не default alias. По смене сессии/списка выбор физического устройства всё ещё нужно подтвердить; стабильный USB endpoint identity не реализован.
- На MIC315 stage в `C:\Mera Files\screens`: `RecorderLnx-dac-feedback.exe` SHA256 E14888CEB6EBA0296A6DC0CC21ECCB74A9085E7B718EAF658397D57A3DBB440F, `Mic315Updater.exe` SHA256 654BCCDA2F92A83701DE96C7CDD24C1F1AE6F61FCF6E9216F2E16601167B0B60. SMB копии сверены.
- Updater: one-shot, hostname+full image path verification, byte-verified backup/stage до kill, замена только EXE, rollback и launch. Forced build/dry-run/refusal unsafe override прошли. Real update ещё ожидает запуска пользователем/UAC.

## Стенд: текущее ограничение

SSH BatchMode отказал в аутентификации; RDP capture даёт timeout, затем чужое подключение прерывало сессию. Пользователь выбрал ручное нажатие кнопок/снимки, агент читает логи через SMB. Захват/управление экраном прекращены. Запрошен запуск обновлятора. Реальный loopback, hardware MERA и CPU/latency замеры не выполнены; нельзя объявлять завершённую аппаратную калибровку или причину аналоговых изломов.

## Следующий шаг

### 2026-10-29 — Возврат endpoints после явного mstsc и WinMM-truncation дубли

По просьбе пользователя root запустил новый mstsc с явным .rdp/audiomode1,
PID32672. После подключения пользователь подтвердил USB; raw14:38 уже
29devices, defaultHost0/native6SB3. До этого raw было4WDMKSHD и WinMM0.
Следовательно, воспроизведена зависимость от конкретного подключения/сеанса;
не делались service restart/driver/registry repairs. Точная серверная причина
различия старого и нового RDP-сеанса пока не выделена. Repairtoolне запускался,
staged CMD/PS переведены вno-op; оставлен read-only диагностика.

Появившиеся дубли объясняются MME31UTF16name truncation: native6
`Speakers (Sound Blaster Play! 3` иnative15/20 полноеимясзакрывающейскобкой.
Добавлена Windows-only уникальнаяprefixэвристика; ambiguouslongA/B сохранять,
same-hostports/maxcardinality/defaulttie прежние. Exactaliasesprimary/mapper
EN/RU исключены. Native6 сохранёнfixtureреальногоимени. Main/Selection25/
DACCore forcedbuild/run0. Пакет878CFF09... staged дляследующегоRefresh.

### 2026-10-29 — Windows inventory подтверждает отсутствие обычных аудиовыходов

Mic315-audio-20261029-143050.log: PnPSoundBlasterOK0 VID041EPID324D,
Audiosrv/EndpointBuilderRunning; native64probe MME/DS/WASAPIdevices0,
WDMKS4HD, waveOutcount0. Recorder не запущен. Ошибка воспроизводится в
независимом nativeпроцессе, поэтому дальнейшая правка списка Recorder
сама по себе этого не исправит. DLL307712байт Pa19.7devel, init/term0.

PSизTotalCommander был32битным (хотяnativeprobe64). MMDevices32registry
пуст; нельзя делать вывод о64registry. CMDпереведённаSysnative64;
nativeUTF8file читается один раз без дублирующего consoleencoding.
Следующее причинное действие: guarded перезапуск EndpointBuilder/AudioSrv
с сохранением исходных статусов, без driver/registry/PXI изменений.
Отдельный Repairhelper будет отказывать при RecorderLnxactive и неизвестных
зависимых службах; before/after64diagnostics, точные serviceerrors.

### 2026-10-29 — USB нет в исходном PortAudio snapshot после all-host hotfix

UpdaterSUCCESS14:22:11 и rawdiscovery подтверждены. `raw_count=4`, host3
у всех: index0HDmic(out0),1SPDIF(out2),2HDdigitalin(out0),3HDspeakers(out8).
Текущий фильтр Blaster не скрывает — его не отдаёт PortAudio до отбора.
Гипотеза «достаточно исправить ownhostfilter» для стенда не подтвердилась.
Не объявлять USB физически отсутствующим по PaGetDeviceCount.

Следующая различающая проверка: тот же загруженный DLLpath/hash/version,
PortAudioHostApiInfo и полный native inventory в отдельномread-onlyпроцессе,
WinMMwaveOut enumeration; Windows PnP SoundDevice и AudioEndpoint, состояния
MMDevicesRender и служб. Не делать reset/enable/driverinstall до evidence.
Для этого создан Tools/Mic315AudioProbe, PSwrapper пишет только отчёты в
свой каталог; запуск пользователем согласуется с его прежним режимом
ручных кнопок, захватов/управления RDP агент не выполняет.

### 2026-10-29 — Список после RDP reconnect содержит только HD Audio

Снимок и runtime log: candidates1=SPDIF,3=HD Audio; stored6 отсутствует.
Диспетчер устройств показывает SoundBlasterPlay3. Пользователь уточнил,
что вчера RDP работал; поэтому RDP не объявляется единственной причиной.
Найден доказанный дефект перечисления: все устройства, HostApi которых
не совпадает с default output HostApi, безусловно отбрасывались.

Исправлена фильтрация по полному snapshot native indices/имён/API/channels.
Для точного имени выбирается host с максимальной multiplicity; defaulthost
толькоtie, затем native-first; сохраняются все порты chosenhost. Это эвристика
по именам, не универсальная стабильная USB identity. Новое aggregate raw log
позволяет отличить ownfilter от отсутствия USB во всём PortAudio snapshot.
18selectioncases, DACCore, main forcedbuild/run0; snapshot+Init/Terminate
аудит пройден. Native global PaInitialize concurrency остаётся прежним
отдельным риском, не менялся без причинного evidence.

PayloadSHA `ACDCC11888913E4570C07BEC33EEA5B5A528F8DE97137ACAC8FA10C43C02D15D`
совпал local/remote; пользователю предложен updater+Refresh. Аппаратное
появление Blaster и успешный stream всё ещё ожидаются, не заявлены.

### 2026-10-29 — Play bounce при исчезновении физического USB endpoint в RDP

Remote logs13:46–13:47: каждый Play отклонён `Select an available physical
DAC, not redirected Remote Audio`; stream-start отсутствует. Storedendpoint6.
Пользователь подтвердил: SoundBlasterвиденлокально, исчезаетвRDP.
На клиенте Default.rdp для192.168.15.84 найден audiomode0; изменён на1,
байтово0→1 безперекодировки, backup `.mic315-audio-before-20261029.bak`.
ФайлMIC315-calibration-windowed.rdp ужеимел1. Для применения нужен reconnect.

Исправлен UI fallback missingendpoint→firstdevice: теперьвыборпустой,
identityсохраняется, status сверху. Play рисуетреальныйsnapshotвместо
optimisticStop; autoCalibrationRunning само по себе не значитStop.
Новаярадиогруппа3режима и explicitApplyOutputSettings проверены47lifecycle
assertions, main/Feedback/MeraTimebase forcedbuild/run0. Пакет staged.
Физическое восстановление SoundBlaster и phasecalibration пока непроверены.

### 2026-10-28 — Реальный отказ второго midpoint и амплитуда маркера

Установка auto50 версии подтверждена updater SUCCESS17:03:18. Runs2–6 после
5с выдачи завершаются `Expected second feedback midpoint was not detected in
its time gate`, underruns/drops0. Пользователь видит почти нулевой отклик.
В Runtime обнаружен fixed markerAmplitude0.05 независимо от выбранной1.0.
Одна причинная правка: брать amplitude компонента; test проверяет всю5с
реализацию при amplitude1.0. Добавлена одноразовая диагностика при teardown:
accepted edges/time/baseline/height/noise/polarity, плюс amplitude в prepare.

Нельзя утверждать, что это единственная причина: current error означает,
что какой-то первый кандидат был принят. При flat quantized baseline возможен
ложный DC-кандидат; при AC-связи экспоненциальный droop может не пройти
plateau criterion8..16ms (аналитическая HP20Hz модель ripple/H≈.29 >.25).
Обе гипотезы пока не подтверждены raw стенда. Алгоритм/gate вслепую не менялся.
После амплитудного патча нужен повторный пуск и чтение расширенного summary.

### 2026-10-28 — Автоматический midpoint и lifecycle потока

Remote log MIC315: 16:43:44/52 `threshold=0.1 edge_interval_sec=2`, обычный
Play `calibration_test=False`; 16:43:49/58 остановлен с `Expected second
feedback edge was not detected in its time gate`, underruns=0/drops=0.
Подтверждён останов из-за неудачной калибровки, а не конечного Sin. Гипотеза:
ручной физический порог пропускал низкий marker и давал ложную первую метку
на следующем сигнале. Выбор порога пользователем больше не требуется.

Реализована автооценка шума/устойчивого уровня и midpoint50% обоих фронтов с
интерполяцией; полярности обязаны совпадать, источник n−0.5. User изменил
жизненный цикл: длительность полного теста5с, stream start поопции Preview
или Play; потом нули/рабочий provider без нового backendStart. RecorderStop
закрывает поток. Таймер не зависит от видимости виджета, ждёт cursor новых
ADC данных и готовит генератор на Fs_eff один раз после lock. До готовности
Fs_eff он не выдаёт рабочие отсчёты. Nominal hardware config неизменен.

Синтетические gain/DC/noise/ringing/ramp/polarity проверки и постоянный
provider прошли, отдельный lifecycle test на production Runtime/Factory с
NullBackend подтвердил29 проверок, включая отмену pending/disable и hidden
config invalidation. Аппаратная проверка нового поведения ожидается.

### 2026-10-28 — Уточнение: поправка частоты по двум фронтам

Реализована оценка Fs_eff по целочисленному расстоянию двух DAC маркеров и
временам их отклика в выбранном AI. До второго фронта публикация запрещена,
затем зеркало получает start+n/Fs_eff; аппаратная Fs не меняется. Интервал
настраивается, проверяются rearm, допустимый drift ±1%, timeout и разрывы AI.
Постоянная остаточная фаза может зависеть от аналоговых фильтров/порога;
пользователь попросил обойтись без корреляции, рабочая фаза не вычитается.

MERA сохраняет измеренную частоту с первого блока, а при новом значении Fs
в том же кадре переходит на explicit X. Backfill сохраняет старые .prt паузы
и пишет пакетами8192 Double вместо одного I/O вызова на отсчёт. Независимый
аудит формул и пакетной записи пройден. Forced main/Core/Feedback/MeraTimebase/
Storage/MeraBlockStorage build+run0. Пакет staged в DacCalibrationUpdate,
SHA256 `C22EB6651B8A80F280C9FB6D0B7C8734D6E73C0C8D27C37A1F6CF19ABE87D446`.
Установка и аппаратная проверка именно этой двухфронтовой версии ожидаются.

### Запуск updater: «ничего не происходит»

После сообщения «обновилось» пользователь сообщил очистку screens. Проверка: в screens остался только Run-Mic315Updater.cmd, payload/updater/новые логи отсутствуют. Поэтому подтвердить замену EXE по удалённым артефактам нельзя; номер0.1.190 не менялся в этой тестовой сборке. Пакет заново staged в отдельном `C:\Mera Files\DacCalibrationUpdate` с SHA сверкой, чтобы не зависеть от очистки screens. На снимке endpoint снова sound mapper; до физического теста нужен явный Sound Blaster, калибровка RDP/default запрещает.

Пользователь сообщил отсутствие видимого результата. По SMB нет новых updater-логов и backup, поэтому успех не подтверждён. Обнаружен диагностический пробел: лог создавался только после elevation. Теперь real-mode пишет отдельный PID-log до проверки PE/UAC; dry-run остаётся read-only. Добавлен `Run-Mic315Updater.cmd`, сохраняющий stdout/stderr/exitcode в updater-launch.log и оставляющий окно открытым. Forced updater build и dry-run прошли, оба файла повторно staged в screens. Причина отказа реального запуска ещё неизвестна; требуется один запуск CMD пользователем.

Прочитать `updater-*.log` после запуска. Затем Preview (выдача DAC только явными Play/Calibrate; global Record более не включает выход), выбрать физический USB endpoint и feedback `2 AIn1`, дать успокоиться предыстории, Calibrate. Прочитать `[DAC feedback]`/`[DAC run]` и снимок; затем проверить несколько пусков и реальную запись в MERA. Для изломов сохранить одновременные mirror/AI raw, сравнить моменты искажений с границами/underrun и повторить на меньшей амплитуде. Причина пока не установлена.
