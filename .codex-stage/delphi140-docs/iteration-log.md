## 2026-09-04 20:35 — подготовлено ТЗ источников данных и временной базы

**Запрос:** На основе исследований подготовить ТЗ для развития Delphi 2020 MIC-140 как короткого эффективного примера работы с источниками данных.

**Сделано:** В `Docs/architecture/data-source-timebase-task-card.md` зафиксированы общий контракт блока, единая семантика DeviceTime/UTS/Start, lifecycle без пересоздания, служебные TIn, runtime-ограничения, пример приложения, этапы и критерии приёмки. В `Docs/README.md` добавлена ссылка.

**Проверка:** Сверены существующие интерфейсы и реализации MIC-140/MIC-185, архитектурные документы и контракт RecorderLnx. Независимое ревью исправило семантику Start без UTS, полноту time metadata, владение массивами и измеримость критериев; код не менялся, сборка N/A.

**Статус:** готово; реализация должна выполняться отдельными атомарными этапами по ТЗ.

## 2026-08-26 19:00 — исправлен layout тегов MIC-140

**Запрос:** TCP-байты и main scan приходят, decoder вызывает callback, но `BCount` и теги остаются пустыми.

**Сделано:** По счётчикам `Main=Pub>0`, `BCount=0` найден ранний выход callback: datasource создавал 49 тегов по discovery-типу, decoder публиковал 56 каналов по прочитанному `$4141`. `EnsureChannelTags` теперь берёт `Configuration.DeviceType`, а `Info.DeviceType` использует только до конфигурации. Добавлено правило runtime-layout.

**Проверка:** Delphi Win32 Debug собран в `Win32\CodexBuild`, exit code 0. Аппаратный прогон исправленной версии ещё не выполнен.

**Статус:** частично до подтверждения роста `BCount` на MIC-140.

## 2026-08-26 18:35 — диагностика TCP-потока MIC-140

**Запрос:** Play переходит в Running, но блоки данных MIC-140 не публикуются.

**Сделано:** Сравнены `TTCPDev.DoUpdate`, parser/decoder и callback с рабочим backup — поведенческих отличий нет. В `TTCPDev` добавлен монотонный `ReceivedByteCount`; при нулевом `BCount` форма показывает `Rx`.

**Проверка:** Delphi Win32 Debug собран в `Win32\CodexBuild`, exit code 0; `FrmMIC140.pas` возвращён в Windows-1251 и проверен по русскому литералу.

**Статус:** частично; по показанию `Rx` нужно выбрать следующую атомарную правку transport либо decoder.

## 2026-08-26 18:05 — отменено неподтверждённое программирование scan

**Запрос:** Устранить зависание Play и `Data source start timeout`, появившиеся после предыдущей правки.

**Сделано:** Вызов `ProgramMainScan` удалён из `Configure`. Причина: непроверенная последовательность сама запускала ADC/таймер, ждала 4200 мс, после чего `Start` повторно посылал `START_SCAN` и не укладывался в 2-секундный timeout worker.

**Проверка:** Delphi Win32 Debug собран в отдельный `Win32\CodexBuild`, exit code 0. Штатный exe был занят запущенным приложением.

**Статус:** timeout-регрессия исправлена; исходное отсутствие блоков MIC-140 требует отдельной атомарной диагностики.

## 2026-08-26 17:30 — восстановлена стадия Configure MIC-140

**Запрос:** Найти регрессию, из-за которой после добавления MIC-185 цепочка Connect -> Play MIC-140 не публиковала данные; сравнить с рабочим backup.

**Сделано:** Проверены фабрика, общий worker, callback и layout тегов. В `TMIC140Dev.Configure` восстановлен вызов `ProgramMainScan`; состояние `dsConfigured` теперь достигается только после успешного программирования scan.

**Проверка:** forced Build Delphi Win32 Debug, exit code 0. Аппаратный Search -> Connect -> Read -> Play в этой итерации не выполнялся.

**Skills/роли:** `device-lifecycle-programming` — Протоколист; `recorderlnx`/`rlm-search` — Системщик; `project-iteration-log` — Куратор; независимый review — Аудитор. Runtime/UI/INI не изменялись.

**Статус:** частично; нужен аппаратный прогон и контроль роста `BCount`.

## 2026-08-25 — полный реестр programming skills команды

**Запрос:** Просмотреть все skills из `C:\Users\User\.codex\skills` и
распределить всё относящееся к программированию между участниками команды.

**Сделано:** Проверены 19 `SKILL.md`. В `development-team.md` добавлена матрица
из 18 programming/process skills с триггером, владельцем и независимым
контролёром; `imagegen` явно отделён как непrogramming skill. Добавлены наборы
skills для Core, Device/Network, Runtime/Blocks, VCL/INI и исправления дефектов,
а также обязательный evidence каждой роли. `AGENTS.md` теперь требует выбирать
skills по матрице и запрещает автору самостоятельно выдавать независимые
verdicts. Карточка BlockManager дополнена `lazarus-native-apps` и
`review-agent`.

**Проверка:** документация перечитана; программные skills имеют владельца и
контролёра, условные skills требуют явного `N/A`. Независимый review обнаружил
и помог исправить самоконтроль двух skills, неверное число gates и безусловное
требование build для документации. Изменения только в Markdown, сборка проекта
отмечена `N/A`.

**Статус:** распределение завершено; при следующей кодовой итерации команда
должна записать выбранный поднабор skills и evidence в Task Card/журнал.

## 2026-08-25 — распределение команды для BlockManager

**Запрос:** До переделки блоков назначить команде явные обязанности и контролёров skills, runtime и логирования.

**Сделано:** Создан Task Card миграции на единый BlockManager. Назначены Куратор, Системщик, Протоколист, Эргономист, независимые Runtime-контролёр, контролёр логирования и QA; закреплены обязательные skills, этапы, evidence и пять отдельных PASS-gates.

**Проверка:** Документ сопоставлен с `runtime-programming`, `device-lifecycle-programming`, `clear-code`, `learn-from-fixes` и правилами команды MIC-140. Код и сборка не изменялись.

**Статус:** распределение готово; реализация блоков ещё не начиналась.

## 2026-08-25 — аудит блоков и IBlockAccess

**Запрос:** Сверить архитектуру блоков MIC-140 с Recorder, включая отдельный блок и связь с DeviceTime/UTSTime.

**Сделано:** Подтверждено, что Recorder выдаёт `IBlockAccess` через QueryInterface тега, но фактически интерфейс реализует принадлежащий тегу DataVector/FIFO. Отдельного публичного `IBlock` не найдено: один блок представлен внутренним FRAME/слотом кольца с DeviceTime, UTSTime, состоянием, частотой и данными. В MIC-140 обнаружены два независимых кольца — в DataSource и Tag; локальный IBlockAccess урезан и имеет другой GUID.

**Проверка:** Сопоставлены первичные C++ исходники `windev-v3.9/mr`, Pascal-интерфейсы Recorder и текущие units MIC-140; независимые Системщик, Протоколист и Аудитор пришли к одному выводу. Сборка не выполнялась, код не изменялся.

**Статус:** анализ готов; следующая итерация — спроектировать единый BlockManager с временными метаданными и делегированием IBlockAccess через Tag.

## 2026-08-25 — команда разработки и история IP

**Запрос:** Подключить проектную команду субагентов и заменить поле IP на ComboBox, сохраняющий найденные адреса и последний выбор.

**Сделано:** Добавлены AGENTS.md и описание шести ролей команды; HostE заменён на редактируемый ComboBox. Поиск дополняет список IP без дублей, INI хранит историю и последний адрес; смена адреса корректно останавливает источник, отключает прежний прибор и сбрасывает его свойства.

**Проверка:** Независимые review `COMPLIANCE: PASS` и `QA PASS`; Delphi 11 Win32/Debug собран MSBuild с временными каталогами вывода, exit code 0. CP1251 модуля и CRLF DFM проверены. Реальный поиск и повторное открытие формы в RAD Studio не выполнялись.

**Статус:** готово; остаётся ручная проверка `поиск → выбор → закрытие → повторный запуск` на приборной сети.

## 2026-08-21 — splitter таблицы и осциллограммы

**Запрос:** Добавить splitter между таблицей каналов и cChart.

**Сделано:** В нижнюю панель добавлен вертикальный OscillSplitter с интерактивным изменением ширины; таблица занимает оставшуюся область, панель осциллограммы закреплена справа.

**Проверка:** MIC140protocol Debug/Win32 собран без ошибок.

**Статус:** Выполнено.

## 2026-08-21 — устранение артефактов cChart

**Запрос:** Исправить разваливающийся красный индикатор active и связанные графические артефакты.

**Сделано:** Найдено переполнение локального буфера: GL_CURRENT_COLOR возвращает RGBA (4 Single), а код выделял point3 (3 Single). Буферы исправлены во всех трех найденных местах локального SharedUtils.

**Проверка:** MIC140protocol Debug/Win32 собран без ошибок.

**Статус:** Готово к runtime-проверке.

# Журнал итераций

## 2026-08-21 20:40 — ComponentsLib автоматически подгружает старый dcl_own

**Запрос:** Устранить повторный конфликт dcl_own после перезапуска IDE.

**Сделано:** Установлена цепочка загрузки: зарегистрированный ComponentsLib стартует вместе с IDE, требует пакет по базовому имени dcl_own, после чего загрузчик находит старый BPL в стандартном Public Bpl. Поэтому ручной Install локального dcl_own конфликтует даже после удаления его собственной регистрации.

**Проверка:** В Known Packages ранее оставался локальный ComponentsLib при отсутствии записи dcl_own; сообщение после перезапуска указывает на автоматически загруженный Public Bpl dcl_own.

**Статус:** требуется удалить ComponentsLib, перезапустить IDE и установить локальные dcl_own → ComponentsLib.

## 2026-08-21 20:35 — старый dcl_own остался в памяти IDE

**Запрос:** После удаления старого пакета и повторного Install устранить сообщение same base name already loaded.

**Сделано:** Проверено: запись старого dcl_own из Known Packages удалена, но текущий bds.exe продолжает держать старый BPL загруженным. Локальный ComponentsLib остаётся зарегистрирован.

**Проверка:** В реестре dcl_own отсутствует; bds.exe PID 9356 работает с 19:47:55.

**Статус:** требуется полный перезапуск IDE, после чего зарегистрировать локальный dcl_own.

## 2026-08-21 20:30 — двойная загрузка dcl_own

**Запрос:** Исправить ошибку Install: TBaseVirtualTree already registered.

**Сделано:** Подтверждено, что IDE продолжает загружать старый C:\Users\Public\Documents\Embarcadero\Studio\22.0\Bpl\dcl_own.bpl, после чего пользователь пытается установить локальный пакет с теми же классами. Состав пакета не изменялся.

**Проверка:** Старый путь присутствует в BDS 22.0 Known Packages одновременно с локальным ComponentsLib.

**Статус:** требуется удалить старый dcl_own из Install Packages либо закрыть IDE и заменить его регистрацию.

## 2026-08-21 20:20 — чистая пересборка локальных пакетов

**Запрос:** После закрытия IDE пересобрать независимую цепочку пакетов delphi2020 без обращения к другой версии.

**Сделано:** Выполнен Rebuild Debug/Win32 в порядке dcl_own → ComponentsLib → MIC140protocol. Все BPL/DCP создаются внутри соответствующих каталогов delphi2020 Platform/Config.

**Проверка:** Все три проекта завершили сборку с exit code 0. Старый GlPackage из другого дерева не использовался.

**Статус:** сборка готова; в IDE требуется переустановить сначала локальный dcl_own, затем локальный ComponentsLib.

## 2026-08-21 20:10 — разделение версий Delphi

**Запрос:** Полностью исключить пересечение исходников и пакетов разных версий Delphi и пересобрать локальную цепочку.

**Сделано:** dcl_own и ComponentsLib переведены на собственные каталоги Platform/Config; ComponentsLib ссылается на DCP локального dcl_own той же конфигурации. Старый GlPackage из другого дерева не подключается. Предложенная правка рендера не применялась.

**Проверка:** Локальный dcl_own Rebuild Debug/Win32 завершён успешно. Rebuild ComponentsLib остановлен Windows: загруженный в bds.exe ComponentsLib.bpl заблокирован и не может быть заменён.

**Статус:** заблокировано до закрытия Delphi IDE; затем выполнить Rebuild ComponentsLib и MIC140protocol.

## 2026-08-21 19:55 — конфликт установленного ComponentsLib

**Запрос:** Устранить ошибку установки нового ComponentsLib.bpl.

**Сделано:** Установлено, что Delphi 11 хранит в HKCU\Software\Embarcadero\BDS\22.0\Known Packages старый пакет d:\works\delphi11\Bpl\ComponentsLib.bpl. Новый пакет имеет то же базовое имя и не может быть загружен одновременно.

**Проверка:** Старое значение найдено точным поиском в реестре; IDE bds.exe сейчас запущена, поэтому пакет остаётся загруженным.

**Статус:** частично; требуется выгрузить старый пакет в IDE либо закрыть IDE для безопасной замены регистрации.

## 2026-08-21 19:45 — локальный SharedUtils и обе конфигурации

**Запрос:** Проект должен использовать только соседний SharedUtils; старое дерево OburecGH изменять запрещено. Исправить несобирающийся проект.

**Сделано:** Все зависимости чарта перенесены в D:\works\delphi2020\SharedUtils, пути ComponentsLib и MIC140protocol сделаны локальными и относительными. Ранее изменённые uSimpleObjects и uFloatLabel в OburecGH восстановлены. Путь DCP исправлен с Win32\Debug на конфигурационные Platform/Config.

**Проверка:** ComponentsLib и MIC140protocol собраны в Win32 Debug и Release; ошибки отсутствуют. В dproj больше нет ссылок на OburecGH, Delphi 11 и старый Documents and Settings.

**Статус:** готово.

## 2026-08-21 19:31 — штатная сборка ComponentsLib

**Запрос:** Проверить Build/Install пакета и устранить повторную потерю исходников при установке компонента.

**Сделано:** Удалены широкие пути старой 3D-библиотеки и старый каталог BPL Delphi 11. Оставлены только исходники uNode, uMNode, uQuat и uConfigFile3d, реально используемые чартом, без зависимости от 3D-пакетов. Выход BPL/DCP перенесён в локальный Win32\Debug; MIC140protocol привязан к этому DCP и к тем же локальным исходникам чарта. Из проекта удалены дубли путей старого чарта, 3dProj, 3d\core и сокращён список runtime-пакетов до фактически используемых.

**Проверка:** Штатные Build ComponentsLib.dproj и повторная сборка очищенного MIC140protocol.dproj Debug/Win32 завершены без ошибок. MSBuild-цели Install у Delphi-проекта нет; установку BPL выполняет IDE.

**Статус:** готово.

## 2026-08-21 — Stop и осциллограмма без runtime-аллокаций

**Запрос:** Исправить ошибку заголовка при Stop, вывести выбранный канал на OscillPanel и убрать необъяснённую математику/SetLength из runtime-декодера.

**Сделано:** Проверка MDP-заголовка теперь использует порт принятого пакета, поэтому промежуточный data-port перед ответом Stop допустим. Добавлена осциллограмма выбранной строки. Канальные, статистические, UI- и TCP-буферы заранее выделяются в Create/Configure/Start; фактические sample count передаются отдельно. Layout AIn/TIn/UTS и формулы статистики подробно описаны в коде.

**Проверка:** Win32 Debug, MSBuild/DCC32 — сборка OK (exit code 0); новых предупреждений нет.

**Статус:** код готов; физический сценарий Play -> Stop и вид осциллограммы нужно повторить на MIC-140.

## 2026-08-21 — Время сбора, TIn и UTS

**Запрос:** Рядом с BCount показывать секунды от старта; добавить в таблицу температурные каналы и UTS; подписать назначение констант источника.

**Сделано:** Источник хранит длительность сеанса и публикует её UI; период worker теперь действительно берётся из UpdateEdit. Для MIC-140 v3 добавлены строки T1–T7 и UTS, разбор температурного хвоста основного скана и отдельного BCD-скана UTS. Служебные строки исключены из выбора ГХ. Константы источника и новые значения протокола снабжены комментариями.

**Проверка:** Win32 Debug, MSBuild/DCC32 — сборка OK (exit code 0), остались только прежние warnings/hints общих компонентов.

**Статус:** готово; фактические TIn/UTS требуют проверки на подключённом приборе и наличия соответствующих сканов в его текущей конфигурации.

## 2026-08-21 — Приём блоков MIC-140 по Play и вывод в таблицу

**Запрос:** запускать сбор кнопкой Play с периодом UpdateFe, показывать число пришедших блоков в BCount и измеренные значения каналов в таблице.

**Сделано:** MIC140Dev запускает/останавливает BIOS-скан командами 80/81, собирает MDP PORT=0 кадры, проверяет заголовок/checksum и рассчитывает LastValue/Average/Amplitude по каналам. MIC140DataSource работает с периодом UpdateFe, хранит потокобезопасный последний снимок и счётчик блоков. Таймер формы с периодом ScreenUpdateFe выводит BCount и столбцы Значение/Амплитуда/Среднее. CallCommand пропускает встреченные data-кадры при ожидании Stop-ответа.

**Проверка:** Win32 Debug собран без ошибок. Аппаратный поток не проверялся.

**Статус:** частично: приём и отображение готовы; текущий Configure всё ещё не программирует полный BIOS ProgramScan, поэтому после холодного старта прибора может потребоваться отдельный перенос scan-programmer из RecorderLnx.## 2026-08-21 — Описания и просветы между методами DataSource

**Запрос:** улучшить читаемость Delphi-модуля: разделить реализации просветами и подписать назначение функций.

**Сделано:** весь uDataSource.pas отформатирован; перед каждым конструктором, деструктором, методом и функцией добавлено краткое описание назначения; между реализациями добавлены вертикальные интервалы. Правило записано в development-rules.md.

**Проверка:** Win32 Debug собран без ошибок.

**Статус:** готово.## 2026-08-21 — Worker переведён с Events на автомат состояний

**Запрос:** заменить трудно читаемую событийную синхронизацию источника на состояние под критической секцией; использовать явные EnterCS/ExitCS.

**Сделано:** удалены TEvent; добавлены состояния Stopped/TryStart/Play/TryStop/Terminate, защищённые TCriticalSection. Цикл выполняет DoObStart, DoUpdate или DoObStop по состоянию и содержит одну точку рабочего Sleep. Прямые Acquire/Release скрыты за EnterCS/ExitCS для будущего логирования и замеров.

**Проверка:** поиск подтверждает отсутствие TEvent и прямых Acquire/Release вне обёрток; Win32 Debug собран без ошибок.

**Статус:** готово к проверке Connect/Play/Stop на приборе.## 2026-08-21 — Создание worker полностью вынесено из Connect

**Запрос:** устранить повторное исключение EThread в TThread.AfterConstruction при Connect.

**Сделано:** TCustomDataSource.Create больше не создаёт TDataSourceThread; worker создаётся лениво только в первом TCustomDataSource.Start, вызываемом по Play. Для suspended-создания явно выбрана перегрузка TThread.Create(True, 0); Stop/Destroy/IsRunning учитывают ещё не созданный worker.

**Проверка:** поиск показывает единственное создание TDataSourceThread внутри TCustomDataSource.Start; Win32 Debug собран без ошибок. Аппаратный Connect не выполнялся.

**Статус:** исправление готово к повторной проверке Connect и Play на приборе.## 2026-08-21 — Поток источника запускается только по Play

**Запрос:** исправить исключение EThread при Connect и сохранить ожидаемый жизненный цикл: worker не работает до нажатия Play.

**Сделано:** удалён TThread.Start из конструктора TDataSourceThread; однократный системный запуск перенесён в StartAcquisition. Деструктор учитывает источник, у которого worker ещё ни разу не запускался. Правило жизненного цикла добавлено в development-rules.md.

**Проверка:** Win32 Debug пересобран без ошибок. Аппаратная проверка Connect/Play не выполнялась.

**Статус:** исправление готово к проверке на приборе.## 2026-08-21 — Поток сбора перенесён в DataSource

**Запрос:** перенести владение потоком сбора из устройства в источник данных; оставить устройству явно вызываемые worker-callbacks; конкретный источник MIC-140 разместить рядом с модулем прибора.

**Сделано:** добавлены общий IDataSource/TCustomDataSource и worker в device\uDataSource.pas; TMIC140DataSource расположен в device\140\uMIC140DataSource.pas. Worker вызывает последовательность DoObStart -> DoUpdate -> DoObStop. Из TTCPDev удалён собственный поток, оставлены сокет, состояние и один ограниченный по времени шаг чтения. Форма запускает и останавливает сбор через источник данных и уничтожает его раньше устройства. Теги используют общий интерфейс IDataSource.

**Проверка:** поиск не находит прежние TTCPReadThread/ReadThread и прямые вызовы FCurrentDevice.Start/Stop из формы; проект пересобран Win32 Debug без ошибок.

**Статус:** каркас жизненного цикла готов. Аппаратный запуск не проверялся; ParsePackets и публикация готовых блоков в теги остаются следующим этапом.
## 2026-08-21 — Минимальный слой тегов и кольцевых блоков

**Запрос:** создать в `tags` понятный шаблон кольцевого буфера, тега с расчетами/ГХ/источником и менеджера тегов, сохранив знакомый плагинам Recorder интерфейс доступа.

**Сделано:** добавлены `uTagRingBuffer`, `uTag` и `uTagManager`; блоки и рабочие массивы выделяются заранее, публикация считает min/max/mean/RMS/last и применяет две ступени ГХ. Поддержаны `ITag`, запрос `IBlockAccess`, старый маршрут `LockVector/GetVectorR8` и новый безопасный курсор `CopyNextBlock`. Добавлен краткий README с producer/consumer примером.

**Проверка:** модули подключены к `MIC140protocol.dpr/.dproj`; Win32 Debug собран Delphi 35.0. После аудита исправлен повтор кольца при курсоре на конце и устранено использование producer-массивов при чтении размера.

**Статус:** готово как изолированный шаблон; подключение реального потока MIC-140 к менеджеру тегов является следующей отдельной итерацией.

## 2026-08-21 — Трёхточечная кусочно-линейная аппаратная ГХ

**Запрос:** не сводить заводскую ГХ MIC-140 к одной прямой; уточнить, читаются ли диапазоны отдельными командами.

**Сделано:** применение аппаратной ГХ переведено на кусочно-линейную интерполяцию между сохранёнными точками с экстраполяцией крайним участком. Таблица формы показывает три исходные точки выбранного диапазона. По коду протокола подтверждено: один общий `mi118tar.bin` содержит записи всех каналов и трёх диапазонов; `READ_FLASH` повторяется только для чтения блока частями.

**Проверка:** Win32 Debug собран MSBuild/Delphi 35.0, ошибок нет; остались прежние warnings общих компонентов.

**Статус:** готово; фактические значения трёх диапазонов нужно проверить на подключённом приборе.

## 2026-08-21 — Read без конфигурирования, ГХ всех диапазонов и Mera Files

**Запрос:** показывать прочитанный SN в списке, упростить `ReadMemBtnClick`, убрать конфигурирование из Read, учитывать разные ГХ диапазонов и синхронизировать их с Mera Files.

**Сделано:** Read разделён на чтение, busy-state и отображение; вызовы `ApplyDeviceConfiguration`/`SaveCfg` удалены. SN записывается в объект устройства и сразу обновляет список. `TMIC140Dev` хранит `канал × 3 диапазона` с исходными точками; смена Range немедленно выбирает соответствующую ГХ. После Read все валидные диапазоны сохраняются в совместимые CSV `C:\Mera Files\Calibr\hardware\MIC140\snNNNN\<range>\CC.csv`; при Connect существующие CSV загружаются автоматически. SN сохраняется в INI при штатном сохранении формы.

**Проверка:** обнаружен существующий каталог `sn0328` совместимого формата; Win32 Debug собран без ошибок; приложение запускается (`Responding=True`). Физическое чтение трёх диапазонов требуется повторить на приборе.

**Статус:** готово к аппаратной проверке.

## 2026-08-21 — Исправлено падение Read на checksum flash

**Запрос:** устранить падение операции `Read` внутри `CallCommand` при чтении аппаратных ГХ.

**Сделано:** подтверждено переполнение 16-битного аккумулятора суммы на большом flash-ответе. Аккумулятор заменён на `Cardinal`, сужение до `Word` оставлено только на wire-границе. Добавлены error-note и правило предотвращения.

**Проверка:** Win32 Debug собран без ошибок; физический повтор Read ожидается на подключённом приборе.

**Статус:** исправление готово, требуется проверка на MIC-140.

## 2026-08-21 — Граница абстракции CallCommand

**Запрос:** проверить, следует ли поднять `CallCommand` в общий родительский Device для повторного использования MIC-185.

**Сделано:** сопоставлены `TMIC140Dev.CallCommand`, базовые `TCustomDevice`/`TTCPDev` и `TRecorderMebiusTcpClient.TryCallCommand` MIC-185 в RecorderLnx. У MIC-140 legacy wire-format с 16-битными словами и `$12B8`; MIC-185 использует Mebius packet + IoControl, 32-битную команду, task IDs и фильтрацию ответов. Общим является только смысл request/reply, а не протокол.

**Проверка:** выполнено чтение реализаций; код не изменялся.

**Статус:** `CallCommand` не поднимать в общий Device. При росте проекта допустимо вынести его из `TMIC140Dev` в отдельный `TMIC140LegacyProtocol`; в `TTCPDev` оставлять только нейтральные транспортные операции.

## 2026-08-21 — Именованные значения протокола MIC-140

**Запрос:** исключить непонятные числовые значения из приборных протокольных записей; смещения полей именовать не требуется.

**Сделано:** sync, command port, число служебных слов, ограничения и команды 113/126 вынесены в `uMIC140Types`; `TMIC140Dev` переведён на эти константы. Правило добавлено в локальные и системные стандарты.

**Проверка:** поиск не находит прежние локальные константы и прямые `CallCommand(113/126)`; Win32 Debug собран без ошибок.

**Статус:** готово.

## 2026-08-21 14:53 — цветовая индикация сбора

**Запрос:** окрашивать панель под Play в жёлтый цвет во время сбора и в серый вне сбора.

**Сделано:** сохранённая как Panel1 панель переименована в PlayPan. UpdatePlayButton отключает ParentBackground и ставит clYellow только для dsRunning, иначе clBtnFace; существующие вызовы после Start, Stop, Connect и при создании формы обновляют цвет централизованно.

**Проверка:** Debug/Win32 собран без ошибок; тестовый EXE запускается и отвечает; изменения PAS/DFM сохранились после сборки.

**Статус:** готово.


## 2026-08-21 13:02 — серийный номер в списке и INI

**Запрос:** убрать SN=0 в списке устройств после чтения 328 и восстанавливать серийный номер при следующем Connect без отдельного Read.

**Сделано:** TCustomDevice получил SetSerialNumber; успешный Read обновляет метаданные объекта и правый список. Тип и SN сохраняются по IP в секции [Device:<IP>]; LoadCfg загружает SN до создания устройства, поэтому Connect сразу показывает кэшированный номер.

**Проверка:** Debug/Win32 собран без ошибок; тестовый EXE запущен и Responding=True.

**Статус:** частично: изменение TCustomDevice сохранено, но FrmMIC140.pas перезаписан открытым stale-буфером Delphi. Требуется Reload from disk или закрытие вкладки без сохранения, затем повторное применение и сборка.


## 2026-08-21 12:48 — исправлен запуск с пустой таблицей

**Запрос:** устранить EInvalidGridOperation «Fixed row count must be less than row count» при старте.

**Сделано:** InitializeChannelsGrid сначала сбрасывает FixedRows, затем задаёт RowCount; заголовок фиксируется только при наличии каналов. Для неизвестного типа сохраняется одна нефикисрованная строка заголовка.

**Проверка:** Debug/Win32 собран без ошибок; EXE запущен без INI и неизвестного типа, через 3 секунды Responding=True, исключения нет.

**Статус:** готово.


## 2026-08-21 12:43 — каналы после определения типа

**Запрос:** после Connect заполнять таблицу каналов, если аппаратный тип получен через Read или загружен из INI.

**Сделано:** добавлено определение 48/96 аналоговых каналов по известным ID. Успешный Read сохраняет DeviceType вместе с IP, заполняет таблицу и обновляет кэш; загруженный из INI тип применяется только после успешного Connect. При смене IP старый тип и строки сбрасываются.

**Проверка:** Debug/Win32 собран без ошибок; тестовый EXE запускается и отвечает. Обмен Connect/Read со стендом в этой итерации не запускался.

**Статус:** готово; аппаратный сценарий остаётся проверить кнопками Connect и Read.


## 2026-08-21 12:31 — читаемое имя типа и комментарии формы

**Запрос:** показывать аппаратный тип понятным названием с исходным ID в скобках и подписать назначение процедур формы.

**Сделано:** добавлена общая MIC140DeviceTypeName для всех известных ID; тип $4141 выводится как MIC-140-48v3 Ethernet ($4141). В ReadMem обновлены заголовок и строка статуса. Ко всем обработчикам и приватным методам TMIC140frm добавлены краткие комментарии об ответственности.

**Проверка:** Debug/Win32 собран без ошибок в отдельный каталог; CP1251-комментарий прочитан обратно без искажения.

**Статус:** готово.


## 2026-08-21 12:24 — изменение высоты таблицы каналов

**Запрос:** добавить сплиттер для изменения размера нижней таблицы каналов.

**Сделано:** над ChannelsSG добавлен горизонтальный ChannelsSplitter с Align=alBottom, высотой 6 px, MinSize=100 и ResizeStyle=rsUpdate; объявление компонента добавлено в форму с сохранением Windows-1251.

**Проверка:** Debug/Win32 собран без ошибок в отдельный каталог; тестовый EXE запущен и остался в состоянии Responding=True.

**Статус:** готово.


## 2026-08-21 12:20 — Ping независимо от занятой TCP-сессии

**Запрос:** сохранить название Ping, но обеспечить проверку доступности даже при занятом другим клиентом приборе.

**Сделано:** TCP-probe заменён на ICMP Echo через выбранный локальный адаптер; порт больше не участвует в Ping. Статус формы изменён с TCP endpoint на Ping IP, WinSock2 удалён из модуля.

**Проверка:** Debug/Win32 собран без ошибок в отдельный каталог; EXE запущен и отвечал. ICMP от 192.168.3.65 к 192.168.14.30 получил ответ менее чем за 1 мс при 0% потерь.

**Статус:** готово. Основной Debug EXE не перезаписан, пока прежний экземпляр запущен.


## 2026-08-21 12:18 — проверка сохранности TCP-пинга

**Запрос:** проверить, не откатилась ли реализация пинга после успешной пересборки и предыдущего падения приложения.

**Сделано:** подтверждено наличие привязки к адаптеру, неблокирующего connect, таймаута 1500 мс, select и проверки SO_ERROR. Запущенный MIC140protocol.exe отвечает и не падает при старте.

**Проверка:** повторный Rebuild дошёл до удаления EXE и остановился из-за работающего процесса PID 18480; текущий EXE собран 21.08.2026 12:13:32 и имеет состояние Responding=True.

**Статус:** проверено, правки пинга сохранены; для ещё одной чистой пересборки требуется закрыть запущенное приложение.


## 2026-08-21 — TCP-пинг как в RecorderLnx

**Запрос:** заменить проверку связи в MIC-140 на простой TCP-пинг из диалога настройки аппаратных средств RecorderLnx.

**Сделано:** TEthernetDeviceBus.TestLink приведён к алгоритму RecorderLnx: привязка временного сокета к выбранному адаптеру, неблокирующий connect, select, проверка SO_ERROR, таймаут 1500 мс.

**Проверено:** полная сборка Debug/Win32 без ошибок; независимое подключение от 192.168.3.65 к 192.168.14.30:4000 завершилось таймаутом.

**Статус:** реализация завершена; на момент проверки TCP-порт прибора не принимал соединение. Следует исключить занятую другим приложением одноклиентскую сессию.


## 2026-08-21 11:22 — исправлена кодировка русских надписей

**Запрос:** убрать иероглифы в заголовках таблицы и остальных русских строках формы.

**Сделано:** FrmMIC140.pas преобразован из ошибочного UTF-8 обратно в Windows-1251. Проверены заголовки «№ канала», «Значение», «Амплитуда», «Среднее» и новые сообщения Read. Правило сохранения кодировки расширено на .pas формы.

**Проверка:** все контрольные строки корректно декодируются как CP1251; полный Rebuild Debug/Win32 завершён с 0 ошибок.

**Статус:** готово.


## 2026-08-21 11:09 — чтение идентификационных свойств MIC-140

**Запрос:** реализовать ReadMemBtnClick для чтения серийника, типа и версии прибора по действующей реализации RecorderLnx; канальные градуировки оставить отдельной операцией.

**Сделано:** TMIC140Dev читает 11-словный TBiosInfoMC031 командой 113, проверяет MDP-заголовок, контрольные суммы и тип MIC-140. Форма выводит CCSerNo, тип и версию revision.subrevision.BIOS.function; чтение при запущенном сборе запрещено.

**Проверка:** полный Rebuild Debug/Win32 завершён успешно, 0 ошибок. Обмен с реальным прибором не выполнялся.

**Статус:** готово для аппаратной проверки; чтение градуировок каналов остаётся отдельной следующей процедурой.

## 2026-08-17 - Create current device from discovery identity

**Request:** make Connect create FCurrentDevice when it is nil, while preserving that the concrete device type is determined only by auto-discovery.

**Done:** Connect calls EnsureCurrentDevice. It applies the selected NIC, runs manager discovery, matches HostE against returned endpoints, and passes the original TFoundDeviceInfo to the registered factory. No device class or bus id is hard-coded by the form. Restored DeviceIPAddress INI persistence after an open IDE buffer overwrote it.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors. Runtime discovery-connect still requires hardware verification.

**Status:** complete.

## 2026-08-17 - Persist selected device IP

**Request:** save the selected MIC-140 IP and restore it from the INI file.

**Done:** added Network/DeviceIPAddress, SaveCfg now stores HostE independently of adapter validity, LoadCfg restores HostE and reapplies the saved local adapter to the device manager, and device selection saves the configuration immediately.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors. Runtime close/reopen verification was not performed.

**Status:** complete.

## 2026-08-17 - Bound TCP link test through selected adapter

**Request:** investigate why MIC-140 discovered by broadcast does not pass the button link test and bind the test to the selected NIC like RecorderLnx.

**Done:** bus-level TestLink now creates a temporary TCP socket, binds it to TMebiusEthernetBus.LocalAddress, and connects to HostE/PortIE with a 500 ms limit. The temporary socket is always released. Device-level TTCPDev.TestLink remains ICMP-based.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors. Broadcast discovery already confirms UDP traffic through the selected adapter; the new TCP path still needs a hardware button check.

**Status:** code complete.

## 2026-08-17 - Fast bounded ping probe

**Request:** make FDeviceManager.TestEthernetLink return quickly and compare it with RecorderLnx.

**Done:** confirmed Synapse PingHost inherits a 5000 ms default timeout; added shared PingHostTimeout with one explicit 500 ms ICMP attempt and used it in bus-level and device-level TestLink. RecorderLnx uses an explicit 1500 ms TCP-connect bound for its UI button and 500 ms for fast discovery probes.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors. Hardware elapsed-time verification remains.

**Status:** code complete.

## 2026-08-17 - Link tests on bus and device levels

**Request:** allow ping before a device object exists while retaining TestLink on created devices.

**Done:** added TEthernetDeviceBus.TestLink and TDeviceManager.TestEthernetLink for arbitrary addresses; PingBtn now tests HostE through the manager-owned bus. TCustomDevice.TestLink and TTCPDev.TestLink remain available for an existing device endpoint.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors. Hardware ping was not executed in this iteration.

**Status:** complete.

## 2026-08-17 - Ping link test button

**Request:** implement the Ping button as a device link test.

**Done:** PingBtnClick now requires a selected device, disables the button during ICMP wait, calls FCurrentDevice.TestLink, writes the result and endpoint to the status edit, and shows the returned error on failure. The test does not open or change the TCP session.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors. Hardware ping was not executed from the application in this iteration.

**Status:** complete.

## 2026-08-17 - Repair form event insertion corruption

**Request:** repair FrmMIC140 after creating a component event broke the form code and explain why it happened.

**Done:** restored FDeviceManager, moved PingBtnClick into the event-handler section, bound PingBtn.OnClick in the DFM, and documented the stale-editor-offset prevention rule.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors; declaration, implementation, and DFM binding were checked.

**Status:** complete.

## 2026-08-17 - Connection lamp moved to ImageList

**Request:** stop loading lamp PNG files on every state refresh and use ImageList1 indices c_ConnectImg and c_DisconectImg.

**Done:** removed ConnectionLampFileName and disk LoadFromFile calls; UpdateConnectionLamp now selects an index by IsConnected and copies the bitmap from ImageList1.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors; search confirms no remaining lamp file-loading references.

**Status:** complete.

## 2026-08-17 - Restore missing RangeCB form field

**Request:** fix E2003 Undeclared identifier RangeCB in FrmMIC140.pas.

**Done:** synchronized the form class with FrmMIC140.dfm by restoring RangeCB: TComboBox in TMIC140frm.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors.

**Status:** complete.

## 2026-08-17 - Device connection lamp beside IP address

**Request:** add a green/gray device connection indicator beside the IP field and store its assets in resources.

**Done:** added two 16px PNG lamps, a TImage beside HostE, device creation after search, Connect button handling, and state-driven lamp refresh.

**Verification:** Debug/Win32 build completed successfully after validating and repairing form method placement; existing component warnings remain.

**Status:** complete.

## 2026-08-17 - MIC-140 one-time initialization stage

**Request:** add an explicit MIC-140 initialization stage that is not repeated by Configure.

**Done:** TMIC140Dev now overrides Initialize, rejects disconnected calls, and returns immediately when the current session is already initialized/configured/running.

**Verification:** Debug/Win32 build completed successfully; existing component warnings remain.

**Status:** complete; future MIC-140 session preparation commands have a dedicated insertion point.

## 2026-08-17 - Device classes moved to device folder

**Request:** move device modules out of units and remove the old module paths.

**Done:** moved uDeviceTypes and uTCPDev to device; updated DPR, DPROJ, and Delphi local project paths. Infrastructure modules remain in units.

**Verification:** Debug/Win32 build completed successfully; existing component warnings remain.

**Status:** complete.

## 2026-08-17 - Generic TCP device and MIC-140 protocol layer

**Request:** turn the old TCP link into a reusable device and derive a MIC-140 protocol device from it.

**Done:** added TCustomDevice -> TTCPDev -> TMIC140Dev hierarchy, receive-thread callback, MIC-140 packet buffer, and MIC-140 factory registration; removed old modules and names.

**Verification:** Debug/Win32 build completed successfully; existing component warnings remain.

**Status:** complete; MIC-140 packet framing and identity command remain explicit protocol TODOs.

## 2026-08-17 - Link and protocol connection tests separated

**Request:** use TestLink for transport reachability and TestConnected for a protocol-level session check.

**Done:** replaced TestLinked with abstract TestLink and TestConnected contracts; IsConnected remains the stored local flag.

**Verification:** Debug/Win32 build completed successfully; existing warnings remain.

**Status:** complete.

## 2026-08-17 - TCustomDevice connection checks documented

**Request:** document every TCustomDevice operation and separate stored connection state from a physical link test.

**Done:** added method annotations, stored `fConnected`, base `IsConnected`, protected `SetConnected`, and abstract device-specific `TestLinked`.

**Verification:** Debug/Win32 build completed successfully; existing warnings remain.

**Status:** complete.

## 2026-08-17 — UDP discovery queue drain verified

**Request:** verify that the queue-draining change was not accidentally undone.

**Done:** confirmed that `ReceiveDevices` still keeps the discovery deadline and drains all currently queued UDP datagrams with `repeat ... until not ASocket.CanRead(0)`.

**Verification:** Debug/Win32 build completed with 0 errors; existing warnings remain. **Status:** complete.

## 2026-08-17 — MIC-140 discovery type filter

**Request:** show only MIC-140 devices and exclude MIC-185 from the selection list.

**Done:** Mebius replies are now accepted only for MIC-140 `$02090000` and MIC-140V2 `$02220000`. The project path was updated to the user-moved form under `units\ui`; temporary root duplicates were removed.

**Verification:** Debug/Win32 build completed with 0 errors. Mixed-hardware runtime check remains for the user. **Status:** code complete.

## 2026-08-17 — device dialog encoding fixed

**Request:** remove mojibake from the MIC-140 device selection form.

**Done:** all visible `FrmDeviceSelect.dfm` captions were replaced with ASCII text. Added a project rule requiring an encoding/visual check for Delphi form resources created outside the IDE.

**Verification:** the DFM contains no non-ASCII bytes; Debug/Win32 build completed with 0 errors. **Status:** done.

## 2026-08-17 — отдельная форма выбора найденного прибора

**Запрос:** при нескольких результатах поиска показать отдельную форму выбора, ориентируясь на RecorderLnx.

**Сделано:** добавлена `TDeviceSelectFrm`, принимающая `TFoundDeviceArray` и возвращающая индекс выбранного устройства. Один прибор выбирается автоматически; при нескольких открывается модальный список с именем, IP и SN.

**Проверка:** `MIC140protocol.dproj`, Debug/Win32 — сборка успешна, 0 ошибок. **Статус:** готово.

## 2026-08-17 — broadcast-поиск MIC-140

- Запрос: по кнопке Search выполнить поиск MIC-140 через broadcast с сохранением архитектуры менеджер → шина → описания устройств.
- Сделано: добавлена конкретная Mebius Ethernet-шина; запрос отправляется на UDP 4400, ответы принимаются на 4401 в течение 5 секунд и преобразуются в `TFoundDeviceInfo`. Форма передаёт выбранный адаптер менеджеру и показывает первый найденный IP и серийный номер.
- Проверка: `MIC140protocol.dproj`, Debug/Win32 — сборка успешна, 0 ошибок.
- Статус: частично — нужно добавить фильтрацию общих Mebius-ответов по типам MIC-140 `$02090000` и MIC-140V2 `$02220000`; песочница заблокировала заключительный патч существующего файла.

## 2026-08-17 — инициализация ядра MIC-140

- Запрос: реализовать `TMIC140frm.InitCore`, создать менеджер устройств и необходимые объекты движка.
- Сделано: форма владеет `TDeviceManager`; `InitCore` создаёт менеджер, `DoneCore` освобождает его. Инициализация вызывается первой в `FormCreate`, освобождение — в `FormDestroy` после сохранения настроек.
- Архитектурное решение: поиск, подключение и запуск устройств не выполняются при создании формы. Конкретные шины и фабрики будут регистрироваться в `InitCore`, когда появятся их реализации; существующие базовые классы абстрактны.
- Проверка: `MIC140protocol.dproj`, Debug/Win32 — сборка успешна, 0 ошибок. Остались прежние предупреждения сторонних и существующих модулей.


## 2026-08-17 — Delphi and RecorderLnx discovery gap identified

**Request:** explain why RecorderLnx finds several MIC-140 devices while the Delphi example finds none.

**Done:** confirmed that the Delphi bus sends only modern discovery to UDP/4400 from a separate ephemeral sender, listens only on 4401, and accepts two modern type IDs. RecorderLnx sends from the reply sockets, also uses legacy UDP/4001-4002, directed broadcast, and the complete known MIC-140 type set. The receive queue loop is not the cause.

**Verification:** direct source comparison. **Status:** cause confirmed; full dual-protocol port remains to implement.

## 2026-08-17 — dual-protocol MIC-140 discovery

**Request:** improve discovery because RecorderLnx finds several MIC-140 devices while the Delphi example finds none.

**Done:** modern discovery now sends from the bound UDP/4401 reply socket; legacy discovery was added on UDP/4001-4002. Both receive queues are drained during the common five-second window. Modern and legacy MIC-140 type identifiers are accepted, the source endpoint supplies the IP address, and duplicate replies are collapsed by IP. MIC-185 and unrelated Mebius devices remain excluded.

**Verification:** `MIC140protocol.dproj`, Debug/Win32 — successful build, 0 errors. Existing warnings are outside this change. **Remaining:** verify the resulting device list against the live network.


## 2026-08-17 — original source ports added to MIC-140 discovery

**Request:** continue fixing discovery because the dual-protocol build still reports no MIC-140 devices.

**Done:** compared the send path with the working RecorderLnx implementation and found that it additionally transmits modern and legacy requests from source ports 4400 and 4001. Added these original-style sends while retaining sends from reply sockets 4401 and 4002.

**Verification:** `MIC140protocol.dproj`, Debug/Win32 — successful build, 0 errors. **Status:** partial until the user verifies discovery against live MIC-140 hardware; the source-port dependency is supported by the working implementation but not yet confirmed on this Delphi build.


## 2026-08-17 — discovery procedure annotations

**Request:** document the purpose of functions and procedures around `TMebiusEthernetBus.Search`.

**Done:** added Russian intent comments for conversion, validation, filtering, result accumulation, broadcast sending, modern and legacy queue parsing, bus construction, the public search scenario, and the common receive loop. The comments also state that `Search` returns endpoint descriptions and does not create working devices.

**Verification:** `MIC140protocol.dproj`, Debug/Win32 — successful build, 0 errors. **Status:** complete.


## 2026-08-17 — redundant discovery sends removed

**Request:** make `TMebiusEthernetBus.Search` as short and efficient as possible while preserving the working MIC-140 search.

**Done:** removed two disabled sends from the reply sockets and the obsolete explanatory block. The saved hardware-tested path remains: separate modern and legacy sender sockets issue one request each, while reply sockets collect and fully drain both response queues.

**Verification:** the user confirmed MIC-140 discovery with the removed calls disabled; `MIC140protocol.dproj`, Debug/Win32 — successful build, 0 errors. **Status:** complete for the confirmed two-protocol path. A one-protocol reduction requires a separate hardware test.


## 2026-08-17 — MIC-140-specific declarations separated

**Request:** collect constants and types specific to MIC-140 under `device/140`.

**Done:** added `device/140/uMIC140Types.pas` with the MIC-140 class ID, named device-type constants for all currently recognized hardware variants, and the type-classification function. `uDeviceBuses` now imports that module; generic Mebius reply records, UDP ports, signatures, and parsing offsets remain with the transport protocol.

**Verification:** `MIC140protocol.dproj`, Debug/Win32 — successful build, 0 errors. **Status:** complete.


## 2026-08-17 - Move Ethernet bus ownership into device manager

- Request: create and destroy the Mebius Ethernet bus inside `TDeviceManager`.
- Done: manager now creates, registers, configures, and owns `TMebiusEthernetBus`.
- Done: form no longer stores the concrete bus; it passes the selected local IP through the manager API.
- Ownership: the owning bus list releases the Ethernet bus during manager destruction.
- Verification: Win32 Debug build of `MIC140protocol.dproj` completed successfully.

## 2026-08-17 - Reuse created device by IP

**Request:** when the same discovered device is selected repeatedly, do not create duplicate device objects.

**Done:** TDeviceManager.CreateDevice now searches its owned device list by trimmed, case-insensitive IP before calling the factory. An existing object is returned unchanged; the factory and fDevices.Add are skipped. Empty addresses are not treated as identical devices.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors; existing shared-component warnings remain.

**Status:** complete.

## 2026-08-17 - Display created devices in DeviceLB

**Request:** show the manager-owned created devices in the DeviceLB list after search.

**Done:** added RefreshDeviceList, which rebuilds DeviceLB from FDeviceManager.Devices and displays device name, IP, and serial number. It runs after successful creation from Search and from the Connect fallback path. Reused devices therefore remain a single list row.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors; existing shared-component warnings remain.

**Status:** complete.

## 2026-08-17 - Connect button reflects connection state

**Request:** show Disconnect on the connection button while the current device is connected and perform the corresponding inverse action when clicked.

**Done:** UpdateConnectionLamp now updates both the lamp image and ConnectBtn.Caption from FCurrentDevice.IsConnected. ConnectBtnClick already dispatches Disconnect for a connected device and Connect otherwise.

**Verification:** source behavior inspected; full Rebuild is currently blocked because the running MIC140protocol process (PID 5144) holds Win32/Debug/MIC140protocol.exe.

**Status:** code complete; rebuild remains after closing the running application.

## 2026-08-17 - MIC-140 timing, channel grid, and Play lifecycle

**Request:** calculate ADC averaging from Fs, ground, and Twait; initialize ChannelsSG; configure on first measurement entry; start acquisition from Play.

**Done:** uMIC140Types now owns the MIC-140 configuration record, verified MIC-140-48v3 averaging formula, and per-channel block statistics. The form creates a 48-row grid with channel/value/amplitude/mean columns, recalculates averaging on timing changes, passes settings to TMIC140Dev, and runs Initialize -> Configure -> Start or Stop from Play.

**Verification:** the 10 Hz, Twait 57 us control case returns 298 without ground and 294 with ground. Full Debug/Win32 Rebuild completed with 0 errors.

**Status:** lifecycle/UI complete. Live grid values remain blocked by the existing unimplemented TMIC140Dev.ParsePackets and wire programming command; no synthetic measurements were added.

## 2026-08-17 - Directional Avr and Twait recalculation

**Request:** preserve settling time when frequency or other timing controls change; only a direct edit of averaging count may recalculate settling time.

**Done:** added CalculateMIC140ChannelWaitUs as the inverse of the shared MIC-140 slot-budget formula. TimingControlChange distinguishes the edited control: AvrIE recalculates TwaitFE, while FsCB, TwaitFE, and ground preserve Twait and recalculate AvrIE. A guard prevents recursive OnChange calls, and AvrIE is now bound to the common handler.

**Verification:** full Debug/Win32 Rebuild completed with 0 errors. The existing 10 Hz, 57 us forward control remains 298 samples.

**Status:** complete.

## 2026-08-21 — Аппаратная ГХ и выбор ГХ термопары

**Запрос:** добавить в таблицу каналов аппаратную ГХ и выбор ГХ термопары; читать заводские ГХ вместе со свойствами и учитывать флажок их применения.

**Сделано:** в `TMIC140Dev` добавлены общий legacy-вызов команды, чтение flash командой 126 и отдельная `ReadHardwareCalibrations`. Из каталога flash находится `mi118tar.bin`, для выбранного диапазона разбираются поканальные таблицы и вычисляются коэффициенты `y=k*x+b`. Добавлен `ApplyHardwareCalibration`, который применяет коэффициенты только при включённом `UseHardwareCalibration`. В таблице добавлены столбцы «Аппаратная ГХ» и «ГХ термопары», коэффициенты выводятся как `k=...; b=...`, выбор термопары выполняется выпадающим списком и сохраняется в конфигурации каналов. `ReadMemBtnClick` читает свойства, затем отдельным этапом ГХ.

**Проверено:** Win32 Debug собран Delphi 11/MSBuild без ошибок; приложение из `Win32/CodexDebug` запущено скрыто, через 2 секунды `HasExited=False`, `Responding=True`. Физическое чтение flash требует подключённого MIC-140 и оставлено для проверки на приборе.
## 2026-08-21 — Восстановление событий формы после переноса компонентов

**Запрос:** заново привязать слетевшие события элементов главной формы.

**Сделано:** в `FrmMIC140.dfm` восстановлены `OnSelectCell` таблицы, `OnChange` для Update/Fs/Range/Twait, `OnClick` для Ground/UseHardwareCalibration и `PlayBtn`. Существующие привязки формы, Ping, Connect, Search и Read проверены. Динамический список термопар сохраняет программные `OnChange`/`OnExit`. У `ResetBtn` обработчика в классе формы нет, поэтому к несуществующей операции он не привязывался.

**Проверено:** Win32 Debug собран Delphi 11/MSBuild без ошибок.
## 2026-08-21 — Активация элементов главной панели

**Запрос:** элементы формы отображаются неактивными и не нажимаются.

**Причина:** у общего контейнера `alClientPan` после переноса компонентов сохранилось `Enabled=False`, поэтому VCL отключала всех дочерних контролов независимо от их событий.

**Сделано:** `alClientPan.Enabled` установлен в `True` в DFM.

**Проверено:** Win32 Debug собран без ошибок.
## 2026-08-21 — cChart, кольцевая осциллограмма и русские аннотации

**Запрос:** вывести выбранный канал штатным `cChart`/`cBuffTrend1d`, показывать длину кольцевого буфера и снабдить все модули русскими пояснениями.

**Сделано:** удалено перекрытие design-time `cChart1` старым `TPaintBox`. Создан один `cBuffTrend1d`; `x0=0`, `dx=1/Fs`, буфер ряда выделяется один раз. Источник MIC-140 хранит для каждого канала кольцо из 8 предвыделенных блоков по 512 отсчётов. `CopySnapshotY` за короткую критическую секцию копирует все занятые слоты по времени, поэтому осциллограмма показывает до 4096 отсчётов, а не только последний сетевой блок. В 16 Pascal-модулей добавлены русские назначения модулей и комментарии перед реализациями; сложный разбор MDP/BIOS-пакетов описан отдельно. CP1251 сохранена у `FrmMIC140.pas` и `uTCPLink.pas`, остальные модули сохранены как UTF-8 BOM.

Для сборки старого cChart под Delphi 11 добавлены его исходные пути и две совместимостные правки в OburecGH: явная проверка `GLboolean <> GL_FALSE` и `FormatSettings.DecimalSeparator`.

**Проверено:** `Debug|Win32` собран MSBuild без ошибок. Остались только предупреждения старых библиотек cChart/VCL.
## 2026-08-21 — Общие пути исходников cChart

**Запрос:** после добавления проекта chart в Project Group настроить пути MIC140protocol так же, как в рабочем примере `OburecGH/tests/Chart`, чтобы Code Insight видел зависимости.

**Сделано:** полный список каталогов chart, sharedUtils, OpenGL, 3d, JCL, Mera и вспомогательных модулей перенесён из секции `Debug|Win32` в базовую конфигурацию `MIC140protocol.dproj`. Теперь его наследуют Code Insight, Debug и Release; удалено конфигурационное дублирование.

**Проверено:** Debug|Win32 и Release|Win32 собраны без ошибок. Остались существующие предупреждения старых библиотек.
## 2026-08-25 — блоки и IBlockAccess по модели оригинального Recorder

**Запрос:** Не изобретать отдельный интерфейс блока, а повторить механику
`IBlockAccess` и блоков оригинального Recorder; один обычный блок должен
содержать один массив данных.

**Сделано:** Реализована цепочка `TTag -> TDataVector -> TFifo -> TFrame` по
аналогии `CBufferSupportTag -> CDataVector -> CFifo -> FRAME`. `TFrame` содержит
один заранее выделенный массив и метаданные блока. `IBlockAccess` перенесён с
GUID и порядком методов Pascal SDK Recorder. Разделены монотонный
`GetReadyBlocksCount` и число удерживаемых кольцом блоков `GetBlocksCount`.
Исправлены неполные блоки, вычисление времени отсчётов, делегирование интерфейса
через тег и безопасное завершение worker перед снятием callback.

**Проверка:** `BlockManagerTest: PASS`: wrap 20/8 и 21/8, хронологическое
чтение, времена, неполные блоки 3+2+4 и срез через границу блоков. Forced build
`MIC140protocol.dproj` Debug/Win32 завершён с exit code 0. Независимый runtime
review: `PASS`; архитектурное замечание о счётчиках исправлено и отправлено на
повторную проверку.

**Статус:** модель блока приведена к оригинальному Recorder; аппаратная точность
UTS остаётся отдельной стендовой проверкой.
## 2026-08-25 — модель DoRepaint по плагинам Recorder

**Запрос:** Построить обновление экрана как в `plgEvalFRF`: source thread
заполняет теги, отдельный цикл вызывает `DoRepaint` компонентов, а каждый
компонент обновляется только при появлении новых данных.

**Сделано:** Проверена цепочка `doUpdateData`, `ctag.UpdateTagData` и
`ISRSFrm.doRepaint` в `plgEvalFRF`/SharedRUnits. Зафиксирован проектный контракт
`Play -> source -> tags -> GUI repaint scheduler -> visual components`,
индивидуальный cursor по `GetReadyBlocksCount` и разделение расчёта/отрисовки в
`Docs/architecture/visual-update-model.md`.

**Проверка:** исследование первичных Pascal-исходников; код проекта не менялся,
поэтому сборка не выполнялась.

**Статус:** архитектура согласована на уровне документа; следующий шаг —
выделить table и waveform view из текущего `DisplayAcquiredData`.
## 2026-08-25 — visual-компоненты с DoRepaint

**Запрос:** Реализовать модель плагинов Recorder: worker источника публикует
данные в теги, GUI-цикл вызывает `DoRepaint`, а компонент обновляется только
при наличии нового блока.

**Сделано:** Добавлены менеджер visual-компонентов, table-view и waveform-view
с независимыми cursors. Таймер формы больше не читает данные и не разбирает
текст периода. Смена source проходит через единый detach; Start восстанавливает
binding тега, Stop не перерисовывает старый кадр. Waveform копирует снимок
непосредственно из сохранённого `ITag` и фиксирует cursor после успешной копии.

**Проверка:** forced build `MIC140protocol.dproj` Debug/Win32 — exit code 0;
кодировка `FrmMIC140.pas` проверена как Windows-1251. Независимые verdicts:
`ARCHITECTURE: PASS`, `RUNTIME: PASS`.

**Статус:** готово; стендовая проверка Play, смены канала и Stop остаётся
ручным аппаратным сценарием.
## 2026-08-25 — обзор архитектуры и масштабирования

**Запрос:** Создать в каталоге документации описание основных архитектурных
решений, причин их принятия и расширения проекта новыми устройствами,
источниками, обработками и видами отображения.

**Сделано:** Добавлены `Docs/README.md` и подробный
`Docs/architecture-overview.md`: слои Bus/Factory/Device/DataSource/Tag/Storage/
Visual, жизненный цикл, владение, потоки, время данных, рецепты расширения и
ограничения текущего примера.

**Проверка:** документы сопоставлены с актуальными классами проекта и частными
архитектурными заметками. Pascal-код не менялся, сборка не требовалась.

**Статус:** документация готова; `Docs/README.md` является точкой входа.
# 2026-08-25 — MIC-183/185 vertical slice

Request: add MIC-185 by analogy with MIC-140, preserve project structure, and
keep tags/visuals independent from a concrete device.

Implemented:

- generalized visual/source boundary to `IMeasurementDataSource` and renamed
  the visual module/classes to device-neutral names;
- extended common discovery descriptors with numeric `DeviceType` and taught
  the Mebius bus to classify MIC-140, MIC-183/185 and MIC-185V2 replies;
- added `device/185` with packed settings, MEBE/TCP device, source and factory;
- manager now owns both factories and creates sources through their common API;
- form persists the selected `DeviceClassID` and numeric type in INI;
- corrected `IBlockAccess` block-index semantics and physical ring capacity to
  match original Recorder consumers;
- removed per-data-packet `TBytes` allocation and full RX-buffer shifting;
- documented supported lifecycle, stream channels and current UTS scope.

Verification:

- compared discovery, lifecycle, settings layout, task/IOCTL ids, temperature
  and UTS parsing with original Recorder and RecorderLnx using two independent
  reviewers;
- forced Delphi 11 Win32 Debug build completed successfully;
- existing warnings originate primarily in legacy shared chart/components;
  there are no new compiler errors.

# 2026-08-25 — MIC-140 Play regression, properties and service collection

**Запрос:** восстановить поиск/Play MIC-140; добавить строковые
Get/SetProperties для универсального конфигуратора; добавить сервисный сбор
выбранных тегов с ожиданием переходного процесса, длительностью порции,
callback и Balance как частным случаем.

**Сделано:** устранён сброс `DeviceType` и числа каналов при выборе нового IP;
modern Mebius-типы MIC-140 учтены при определении 48 каналов. В `uDeviceTypes`
добавлены общий формат `name=value;...`, парсер и виртуальный контракт. MIC-140
и MIC-185 транзакционно разбирают собственные строковые настройки. Добавлен
`uTagCollectionService`: отдельный сервисный worker использует обычный source и
Recorder `IBlockAccess`, отбрасывает wait-интервал, собирает точное число
отсчётов по времени порции и вызывает callback; `Balance` использует тот же
путь с приборным обработчиком средних.

**Проверка:** два независимых ревью нашли точную цепочку регрессии и проверили
границы lifecycle/runtime. После первого runtime-review сервис исправлен: он не
останавливает чужой source, не очищает общие теги, использует publication
baseline, кеширует IBlockAccess и вызывает обработку после Stop. Выполнена
принудительная Delphi 11 Win32 Debug сборка; ошибок компилятора нет. Приложение
успешно прошло проверку запуска без подключения. По указанию пользователя
приборы выключены, поэтому Search -> Play и запись balance-кодов на стенде в
этой итерации не выполнялись.

Финальный независимый verdict: `RUNTIME: PASS`. Готовность порции считается по
монотонному числу успешно опубликованных отсчётов тега, а не по числу блоков;
подготовка выполняется после Start, когда источником уже установлены частоты.

**Профилактика:** в `development-rules.md` добавлены правила атомарного снимка
endpoint/type/channel-count и транзакционного применения строковых свойств;
архитектура описана в
`Docs/architecture/device-properties-and-services.md`.
## 2026-08-26 20:10 — исключены сборочные артефакты из Git

**Запрос:** Убрать из GitHub мусорные файлы, сохранив исходники, конфигурации и ресурсы проекта.

**Сделано:** В корень репозитория добавлен `.gitignore` для каталогов Delphi `Win32/Win64`, DCU и других результатов компиляции, локального состояния IDE, логов и временных файлов. Исходники, формы, файлы проектов, INI/JSON/XML и ресурсы намеренно не исключены. Ранее отслеживаемый каталог `Recorder/Devices/MIC-140/Win32` подготовлен к удалению только из индекса Git без удаления локальных файлов.

**Проверка:** `git check-ignore` подтверждает исключение DCU/EXE в `Win32`; исходные `.pas`, `.dproj`, `.ini` вне build-каталогов и файлы ресурсов не подпадают под правила.

**Статус:** выполнено.
## 2026-08-26 20:30 — начато отделение формы от классов приборов

**Запрос:** Перевести общие поля формы (Fs, диапазон, заземление, усреднение и ожидание) на общий контракт устройств, завести реестр строковых свойств и использовать короткие публичные имена.

**Сделано:** Добавлен `uDevProps` с едиными ключами `dp*`, сборщиком и поиском свойств; добавлены алиасы `TDev/TDevRes`. `ApplyDeviceConfiguration`, списки Fs/диапазонов и число каналов теперь работают через `GetProperties/SetProperties` без cast к MIC-140/MIC-185. MIC-140 и MIC-185 публикуют общие capability-свойства; MIC-185 поддерживает выборку списка имён, MIC-140 валидирует Fs и число термопар. Ошибка свойств теперь останавливает Play.

**Проверка:** skills: `device-lifecycle-programming`, `clear-code`, `runtime-programming`, `project-iteration-log`; автор — Куратор/Системщик, независимое ревью — Протоколист/Аудитор. Forced Delphi Win32 Debug build в `Win32\CodexBuild`, exit code 0; форма возвращена в CP1251, русский контрольный литерал читается без replacement chars; `git diff --check` без ошибок.

**Статус:** частично: общий путь конфигурации и capability UI отвязан; сервисное чтение flash/аппаратной ГХ и расширенная MIC-140 диагностика пока остаются специализированными участками формы и требуют отдельного адаптера/сервиса.
## 2026-08-26 21:00 — допустимые значения свойств перенесены в фабрики

**Запрос:** отвязать главную форму от MIC-140/MIC-185 и получать допустимые диапазоны, частоты и другие возможности через общую абстракцию фабрики устройства.

**Сделано:** в базовую фабрику добавлены `GetPropRangeList` и `GetCaps`, в менеджер — делегирующие методы. Фабрики MIC-140 и MIC-185 публикуют собственные списки `range`/`Fs` и размеры каналов. Форма работает только с общими ключами `uDevProps`, `TCustomDevice` и менеджером; конкретные MIC-модули, классы и резервные захардкоженные списки удалены. Общие операции чтения и расчёта параметров вынесены в `Refresh` и `CalcProps` устройства. По итогам независимого ревью транспортный счётчик Rx также поднят в общий виртуальный контракт, а capability-запросы переведены с поиска подстроки на точное сопоставление ключей.

**Проверка:** Delphi Win32 Debug собран принудительно в `Win32\CodexBuild`, exit code 0; поиск конкретных MIC-символов в `FrmMIC140.pas` ничего не нашёл; `git diff --check` не выявил ошибок патча.

**Статус:** выполнено; аппаратная проверка не проводилась.
## 2026-08-26 21:30 — восстановлен расчёт усреднения после Search

**Запрос:** после архитектурного рефакторинга Play завершался ошибкой `Invalid mic140.average_count`; ранее при `Fs=10`, `Twait=57` форма показывала `Avr=298`.

**Сделано:** после создания выбранного устройства снова вызывается общий `CalcProps`, поэтому `Avr` заполняется до конфигурирования. `ApplyDeviceConfiguration` защитно пересчитывает нулевое усреднение. Ручное изменение `Avr` теперь пересчитывает `Twait`, а остальные временные параметры — `Avr`; вложенные события блокируются флагом `FUpdatingTiming`. По замечанию независимого ревью подавление событий перенесено также внутрь процедур программной записи `Avr` и `Twait`, чтобы программный расчёт не воспринимался как ручной ввод.

**Проверка:** Delphi Win32 Debug собран в `Win32\CodexBuild`, exit code 0; форма сохранена в Windows-1251. Аппаратный запуск не выполнялся.

**Статус:** исправлено, требуется подтверждение на приборе.
## 2026-08-26 22:00 — фабричные тайминги MIC-140 и коммутаторы MIC-185

**Запрос:** автоматически подставлять `Avr`/`Twait` для MIC-140; устранить timeout Read MIC-185 и автоматически заполнить его коммутаторы.

**Сделано:** добавлен общий фабричный контракт `GetDefaultProps`; MIC-140 публикует `Twait=57` и `Avr=298`, форма загружает их при создании выбранного прибора и затем уточняет связанный параметр через `CalcProps`. MIC-185 публикует список коммутации `Вход,Земля,49 мВ`; таблица динамически добавляет колонку и заполняет аналоговые каналы значением `Вход`, совпадающим с протокольным `CommutationIndex=0`. Read больше не отправляет второй подряд запрос свойств, если `Initialize` уже успешно прочитал непустую версию MIC-185.

**Проверка:** Delphi Win32 Debug собран в `Win32\CodexBuild`, exit code 0; форма сохранена в Windows-1251. Аппаратное подтверждение Read ещё требуется.

**Статус:** реализовано, ожидается проверка на MIC-185.
## 2026-08-26 22:30 — исправлен legacy-размер ответов MIC-185

**Запрос:** MIC-185 стабильно завершал чтение свойств сообщением `MIC-185 protocol response timeout`.

**Сделано:** пакетный парсер сопоставлен с рабочим RecorderLnx. Добавлена поддержка legacy Mebius-заголовка, где фактический размер находится в младших 16 битах и CRC рассчитан по маскированному размеру. Ранее такие ответы удалялись как повреждённые до истечения timeout. Та же проверка применяется к командным и измерительным пакетам. Восстановлен фактический вызов фабричных defaults MIC-140 из формы. Для MIC-185 колонка коммутации пока честно публикует и программирует только поддержанный тестовым примером режим `Вход`.

**Проверка:** Delphi Win32 Debug собран в `Win32\CodexBuild`, exit code 0; форма сохранена в Windows-1251. Требуется повторный Read на физическом MIC-185.

**Статус:** исправлено по рабочей реализации RecorderLnx, ожидается аппаратное подтверждение.
## 2026-08-26 18:30 — MIC-185 Connect/Read подтверждён на приборе

**Запрос:** самостоятельно отладить MIC-185 по адресу `192.168.9.151` с тестами и логами до успешного чтения базовых свойств.

**Сделано:** создан read-only wire-probe `Tools/mic185_read_probe.py`. Сырые ответы показали, что прошивка возвращает `IDTo=0` и очищенные request-signatures, тогда как Delphi-драйвер требовал echo обоих полей и отбрасывал корректный ответ до timeout. Проверка ответа приведена к рабочему контракту RecorderLnx: команда определяется по IOCTL-коду в offset 4. Сохранена поддержка legacy low16 packet size. Добавлены командные Tx/Rx и identity-сообщения в штатный журнал.

**Проверка:** прямой probe дважды прочитал `SN=165`, `SW=01401806`, `HW=00000000`; сырой журнал сохранён в `Tools\mic185_read_probe.log`. Затем собранная Delphi-форма была запущена и через Windows UI Automation выполнен штатный `Connect -> Read`: журнал подтвердил `rx ioctl=00010034`, те же SN/SW/HW и переход в `dsInitialized`. В отдельном прогоне MIC-185 опубликовал 241 блок данных. Win32 Debug build завершён с exit code 0; тестовый процесс отключён и остановлен.

**Статус:** выполнено и подтверждено на физическом MIC-185.
## 2026-08-26 20:10 — свойства экземпляра сериализуются целиком

**Запрос:** `GetProperties('*')` должен возвращать все текущие свойства dev: defaults до настройки, последние принятые значения после `SetProperties` и обновлённые протоколом читаемые поля.

**Сделано:** контракт закреплён в `TCustomDevice`; defaults перенесены в типизированные конфигурации MIC-140/MIC-185, фабричный `GetDefaultProps` удалён. Все реально программируемые параметры MIC-185 вынесены из литералов сборщика пакета в `TMIC185Configuration`, зарегистрированы строковые ключи и добавлены в транзакционные Get/Set. Форма загружает состояние через общий `GetProperties('*')`.

**Проверка:** полная сборка Delphi Win32 Debug в `Win32\CodexBuild`, exit code 0. Физический обмен не требовался: изменение касается кэша конфигурации и сериализации.

**Статус:** готово.
## 2026-08-26 19:15 — документирован протокол MIC-140 по стадиям

**Запрос:** Создать в документации проекта описание протокола MIC-140 для Search → Connect → Initialize → Configure → Play → Stop → Disconnect с транспортом и побайтовыми таблицами пакетов.

**Сделано:** Добавлен `docs/devices/mic140-protocol.md`: modern/legacy UDP discovery, общий MDP frame, command request/reply, READ_PROPERTIES, START/STOP_SCAN, потоковый BIOS data-frame, правила потоков и TCP lifecycle. Отдельно отмечено, что текущие Initialize/Configure/Disconnect пакетов не отправляют, а `ProgramMainScan` реализован, но пока не включён в Configure. Ссылка добавлена в `docs/README.md`.

**Проверка:** Все 7 стадий присутствуют; проверены 17 таблиц с требуемыми заголовками, смещения и суммы сверены с текущими Delphi-модулями и оригинальными `mdprotocol`/`mdpEthernet81`.

**Статус:** готово.
## 2026-08-26 19:30 — добавлена модель таймингов MIC-140

**Запрос:** Дополнить протокол зависимостями Fs, времени успокоения, Ground/коммутации и числа точек усреднения; показать эффективное время цикла с накладными расходами.

**Сделано:** В `docs/devices/mic140-protocol.md` добавлены кадровый таймер, коэффициент ISR `1.175`, полезный бюджет `Teff`, прямой/обратный расчёт Avr↔Twait, `Toccupied`/`Treserve`, примеры 10 Гц для Ground Off/On, SPORT-кодирование delay, структура MUX/GND descriptors и расчёт периода блока. Отмечено несоответствие неактивного `ProgramMainScan` (48 слов) рабочему профилю 55 каналов.

**Проверка:** Формулы и константы сверены с `uMIC140Types.pas`, `uMIC140Dev.pas` и RecorderLnx `08_timing_and_count_aver.md`; примеры пересчитаны отдельно. Markdown-таблицы проверены на согласованное число колонок.

**Статус:** готово.
