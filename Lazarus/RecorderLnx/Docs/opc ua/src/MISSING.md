# Что ещё отсутствует в реализации OPC UA

Состояние снимка: 2026-09-28. Каталог содержит все девять файлов из рабочего
`RecorderLnx/Device/OPC`, форму `.lfm` и архитектурное описание. Хэши рабочих
OPC-файлов и их копий сверены.

## Внешние части RecorderLnx, необходимые этому снимку

Каталог `src` не является отдельным собираемым проектом. OPC-модули используют
общую архитектуру RecorderLnx:

- `Core/uRecorderTags.pas` — `TRecorderTag`, `TRecorderTagRegistry`, отдельная
  очередь `QueueExternalWrite/ReadExternalWrite` и `PublishExternalValue`;
- `UI/uRecorderVisualControl.pas` — кнопка и поле ввода вызывают
  `PublishExternalValue`, а не обычную публикацию измерения;
- `Core/uRecorderDataSources.pas` — базовый рабочий поток DataSource;
- `Device/uRecorderDeviceInterfaces.pas` — общий lifecycle устройства;
- `Core/uRecorderNetworkBinding.pas` — кроссплатформенное TCP-подключение и
  привязка к выбранному сетевому интерфейсу;
- `Core/uRecorderConfiguredDataSources.pas` и
  `Device/uRecorderConfiguredSourceEditor.pas` — хранение и редактирование
  источника в проекте;
- `Core/uRecorderProjectFiles.pas` — сохранение capability
  `ExternalWriteAllowed`;
- `UI/uRecorderButtonSettingsDialog.pas` и
  `UI/uRecorderInputFieldSettingsDialog.pas` — выбор только writable-тегов;
- `UI/uRecorderSettingsDialog.pas` — подключение OPC-редактора и тестового
  endpoint к общим настройкам;
- `Core/uRecorderDebugLog.pas` и `SharedUtils/uSharedFileLogger.pas` — журнал.

Поэтому простое копирование только этого каталога в другое приложение даст
протокольный клиент, но не готовую интеграцию с тегами и UI. Для отдельной
библиотеки потребуется вынести контракты транспорта, команды записи и
публикации данных в независимые интерфейсы.

## Критичные незавершённые возможности

1. **OPC UA server.** Режим присутствует в типах, API и форме, но
   `TRecorderOpcUaServerHandle` и функции AddVariable/Start/Iterate/Write пока
   являются заглушками.
2. **Защищённые endpoint.** Реализована только SecurityPolicy `None`. Нет
   сертификатов, Sign, SignAndEncrypt, trust store и выбора MessageSecurityMode.
3. **Subscription.** Нет CreateSubscription, MonitoredItem и Publish. Клиент
   последовательно выполняет отдельный ReadRequest для каждого readable-узла.
4. **Альтернативные пути узлов.** Browse теперь дочитывает ContinuationPoint
   через BrowseNext и сохраняет Object/Method, но visited-set по NodeId
   показывает узел только по первому найденному иерархическому пути.
5. **UA-TCP chunking.** Ответы `MSG C`/`MSG A` не собираются из нескольких
   chunks; поддержан только один конечный пакет.
6. **Обновление SecureChannel.** Токен secure channel не продлевается до
   истечения lifetime; восстановление сейчас выполняется полным reconnect
   после ошибки.

## Типы данных и атрибуты

- рабочие Read/Write поддерживают только скалярные Boolean и числа
  SByte..Double;
- массивы и Matrix целиком не публикуются как один рабочий тег; реальные
  индексные дочерние узлы сервера публикуются отдельно, а одномерные Variant-
  массивы без таких узлов редактор показывает fallback-строками при Browse;
  String, DateTime, ByteString, Enumeration и структуры также пока не
  публикуются как рабочие значения;
- не читаются `ArrayDimensions`, `Description` и
  `MinimumSamplingInterval`;
- custom DataType/subtype, отличный от прямого built-in NodeId `i=1..11`, не
  разрешается до базового типа;
- перед числовой записью пока нет явной проверки диапазона, поэтому выход за
  диапазон целевого типа должен возвращаться сервером как ошибка.

## Качество, время и диагностика

- `Bad StatusCode` блокирует публикацию, но полное соответствие
  Good/Uncertain/Bad модели качества Recorder отсутствует;
- OPC UA SourceTimestamp показывается в свойствах выбранного узла и
  диагностике, но в рабочем теге
  используется внутренняя шкала времени Recorder;
- нет ServerTimestamp, diagnostic info и человекочитаемой таблицы всех
  StatusCode;
- нет настраиваемого поведения «прочитать сразу после записи» и отдельного
  подтверждения фактического значения PLC;
- очередь внешней записи имеет 16 элементов на тег; при длительном offline и
  переполнении сохраняются последние команды, но отдельный счётчик потерь пока
  не выводится.
- доставка имеет семантику at-least-once: если PLC применил Write, но ответ
  потерялся, после reconnect команда может быть отправлена повторно. Для
  неидемпотентных команд нужен прикладной номер/подтверждение либо readback.

## Производительность и масштабирование

- нет batch Read/Write нескольких узлов одним service request;
- один медленный или ошибочный readable-узел завершает весь Iterate и вызывает
  reconnect источника;
- максимальная глубина Browse ограничена 64 уровнями;
- нет адаптации sampling interval и deadband на стороне сервера.

## Проверки, которых ещё не хватает

- живая write/readback-проверка `cmd_but` на PLC210: на момент последней
  проверки `192.168.15.130` отвечал на ping, но TCP 4840 был закрыт;
- автоматические протокольные тесты WriteRequest для всех поддерживаемых типов
  и Bad_TypeMismatch/Bad_UserAccessDenied;
- тест переполнения и порядка очереди `press → release`;
- тест восстановления чтения и неподтверждённой записи после обрыва кабеля;
- forced Linux-сборка и проверка на реальном Linux-хосте после добавления
  клиентской записи;
- совместимость с несколькими сторонними OPC UA servers, а не только PLC210.

## Рекомендуемый порядок следующих работ

1. Подтвердить Boolean write/readback на доступном PLC210 и сохранить дамп.
2. Добавить protocol tests для WriteRequest и очереди команд.
3. Реализовать UA-TCP chunk assembly и отображение альтернативных Browse-путей.
4. Перевести массовое чтение на batch Read, затем на Subscription.
5. Добавить secure channel renewal и защищённые политики.
6. Реализовать серверный backend либо скрыть режим Server из рабочего UI до
   его готовности.
