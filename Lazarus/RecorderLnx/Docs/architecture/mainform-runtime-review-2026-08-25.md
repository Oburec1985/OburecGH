# Ревью MainForm и runtime-памяти — 2026-08-25

## Повторный аудит — 2026-09-28

После первых выделений `TRecorderApplicationController` и
`TRecorderConfigurationService` форма снова выросла до 4172 строк. В её
интерфейсном `uses` находится 80 модулей, из них 54 проектных; в классе остаются
десятки runtime/service-полей и 176 методов. Поэтому длинный `uses` здесь не
косметический дефект, а симптом того, что `TMainForm` по-прежнему совмещает
несколько самостоятельных подсистем.

Подтверждённые границы ответственности:

1. UI и размещение страниц/компонентов;
2. lifecycle источников и аппаратной конфигурации;
3. применение настроек и подготовка алгоритмов;
4. открытие проекта и восстановление runtime;
5. сессия записи MERA и передача блоков;
6. coordinator client, JSON-команды и удалённое управление;
7. SQL DB application-сценарии и служебный тег.

Аудит выявил реальные ошибки на этих стыках:

- algorithm-only изменения могут не вызвать подготовку алгоритмов, если
  источники не изменились;
- диалог настроек меняет живой `TRecorder`, поэтому Cancel не откатывает уже
  выполненные операции;
- ошибка в середине реконфигурации может оставить state machine в Preview, а
  источники остановленными;
- `PN_ENTERRCCONFIG` не всегда имеет парный `PN_LEAVERCCONFIG` при Cancel или
  исключении;
- загрузка проекта обходит configuration service и не повторяет все шаги
  startup-сценария;
- `fRecordTimebase` создаётся формой, но не освобождается вместе с другими
  объектами сессии записи.

### Безопасный порядок разделения

Не выполнять массовый перенос методов. Каждый этап должен иметь один владелец
lifecycle и отдельные проверки отказа/отката.

1. Ввести `TRecorderRuntimeCoordinator`, единолично владеющий сценарием
   `stop -> replace -> prepare -> restart/rollback`. Исправить тестами случаи
   Cancel, algorithm-only change и исключение при prepare/restart.
2. Ввести транзакционный draft/change-set настроек. Диалог не должен получать
   право напрямую менять рабочий `TRecorder` до OK.
3. Вынести `TRecorderProjectSession`, объединив startup и загрузку другого
   проекта в один полный сценарий.
4. Вынести `TRecorderRecordingSession`, передав ему writer, frame manager,
   cursors, metadata и timebase.
5. Вынести `TRecorderCoordinatorFacade`; форма должна только показывать статус
   и передавать пользовательские команды.
6. Последним отделить связный UI-контроллер страниц/редактора мнемосхемы.

### Выполненный первый этап — 2026-09-28

`TRecorderRuntimeCoordinator` теперь владеет транзакцией остановки,
перестроения и восстановления acquisition. Подготовка алгоритмов выполняется
независимо от изменения аппаратных источников; при исключении после остановки
координатор пытается вернуть acquisition и сохраняет обе ошибки, если restart
тоже завершился неудачно. Уведомления плагинов о входе/выходе из конфигурации
сделаны парными через `finally`.

Проверки покрывают algorithm-only изменение, ошибку аппаратной подготовки и
ошибку восстановления. Следующий этап — транзакционный draft настроек, чтобы
Cancel не оставлял частично изменённый живой `TRecorder`.

Перенос части модулей из interface `uses` в implementation полезен как
безрисковая чистка зависимостей и ускорение перекомпиляции, но сам по себе не
исправляет архитектуру. Также нельзя заменять форму единым
`TRecorderMainFormService`: это лишь перенесёт God Object в другой модуль.

## Вывод

`TMainForm` (около 3800 строк) одновременно является UI, composition root,
application controller и координатором аппаратного lifecycle. Крупной
безусловной утечки sample-буферов не найдено, но подтверждены дорогие временные
копии и выделения в повторяющихся путях.

## Архитектурные границы

1. Вынести сценарии `Initialize/OpenProject/ApplySettings/Preview/Record/Stop`
   в `TRecorderApplicationController`; форма отправляет команды и отображает
   общий snapshot состояния.
2. Объединить две ветки реконфигурации из `btnSettingsClick` и
   `OpenSelectedTagSettings` в один configuration service, возвращающий
   change-set/result. Диалоги не должны запускать аппаратные действия через
   цепочки callback.
3. Убрать из формы распознавание `MIC-140:`/`MIC-185:` и UTS по строкам.
   Метаданные записи должен предоставлять общий capability источника/тега.
4. Перенести discovery warmup и health polling в общий hardware service.
   UI получает список нейтральных source-status records по revision.
5. Строить панель добавления компонентов по factory descriptors, чтобы форма
   не импортировала каждый конкретный тип компонента.

## Горячие пути памяти

Приоритет исправления:

1. `uRecorderOglOscillogramView.pas` + `uRecorderTags.pas`: полный `Snapshot`
   копирует всю историю `Times/Values` для каждой видимой линии. Нужен
   `SnapshotRangeInto` с переиспользуемыми буферами.
2. `uRecorderDeviceDataThread.pas`: acquisition block полностью копируется при
   `Push` и повторно при `Read`. Нужен lease/index на заранее выделенный slot.
3. `uRecorderMic140DataSource.pas`: `Times`, channel values и validity arrays
   выделяются на каждый блок. Перенести scratch-буферы в runtime cache.
4. `uRecorderSpectrumView.pas`: несколько копий кадра и пересоздание объектов
   полос. Использовать buffer swap и обновлять существующие band objects.
5. `uRecorderSqlTrendView.pas`: каждый live tick создаёт thread/repository,
   строки и merge arrays до `2*MaxPointsPerLine`. Нужен долгоживущий worker и
   reusable per-line buffers/rings.
6. MERA recording использует новый snapshot arrays для каждого блока/тега;
   writer должен получать reusable snapshot или две части кольца.

Статус на 2026-08-26: пункты 1–6 выполнены безопасными отдельными этапами.
Device acquisition использует bounded slot lease, MERA — caller-owned block
buffers, SQL trend — долгоживущий worker/repository и reusable merge buffers.

Дополнительно: исправить освобождение `lSignals` при раннем выходе SQL writer;
ограничить/coalesce очередь alarm events; заменить строковый `fLastSamples` на
индексированный числовой кэш.

## Порядок безопасного рефакторинга

Не выполнять big-bang rewrite. Сначала ввести application/configuration
interfaces без изменения поведения, затем перенести один сценарий и покрыть
его lifecycle-тестом. Оптимизацию памяти начинать с измерения allocations/RSS и
API range-snapshot; после каждого шага сравнивать значения и порядок
измерительного тракта.

## Выполненный этап: application lifecycle controller

Переходы `Preview/Record/Stop` и порядок их побочных действий вынесены в
`Core/uRecorderApplicationController.pas`. Контроллер знает только фасад
`TRecorder` и нейтральный `IRecorderApplicationLifecycle`; он не импортирует
LCL, драйверы приборов или формат MERA.

Порядок сохранён явно: при старте из Stop выполняются проверка алгоритмов,
уведомление `Before`, обработка алгоритмов, сброс display-сессий, запуск времени
и acquisition; для Record файл открывается до запуска acquisition. При Stop
сначала останавливается acquisition, затем закрывается record frame,
останавливается время и завершают переход алгоритмы. После сценария UI получает
одно уведомление состояния, публикуется `After` и формируется запись журнала.

`TMainForm` теперь реализует boundary-интерфейс и связывает общие операции с
существующими UI/MERA/data-source деталями. Следующий этап может заменять эти
адаптеры сервисами без изменения автомата состояний.

## Выполненный этап: configuration service

Сравнение programming state до/после диалога, вычисление набора изменённых
источников и сценарий `stop → replace → prepare → restart` вынесены в
`Core/uRecorderConfigurationService.pas`. Сервис получает immutable по смыслу
снимки подписей и флаги change-set, а детали runtime вызывает через
`IRecorderConfigurationRuntime`; зависимостей от LCL и конкретных MIC-модулей
нет. Результат содержит изменённые SourceId, сообщения, исходное running-state
и ошибку операции.

Общие настройки и настройки тегов используют один сценарий. Проверка
`programming already applied` выполняется до остановки acquisition, поэтому
повторный OK с той же аппаратной подписью не пересоздаёт и не программирует
прибор. UI-обработчики теперь отвечают только за диалог, локальные display
настройки и обновление представления.
