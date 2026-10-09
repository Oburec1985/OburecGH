# 2026-07-13 Preview offline sources and form editor lag

## Symptoms

- Первый запуск просмотра долго переходит в просмотр, особенно когда в проекте
  есть отключенные аппаратные источники.
- Отключенный прибор продолжает проверяться автоматически, хотя пользователь
  ожидает повторную попытку только после ручного сброса устройства.
- При редактировании формуляра перетаскивание контейнера заметно тормозит.
- После удаления элемента и Ctrl+Z элемент возвращается с пустыми/дефолтными
  настройками.

## Confirmed facts

- `TRecorderDataSourceManager.StartAll` вызывает `PrepareHardware` всех
  источников последовательно до запуска потоков.
- `TMainForm.UpdateActiveSourceIds` и дерево аппаратуры могли синхронно
  проверять sourceId через TCP probe.
- MIC-185 connect использовал 3 попытки по 5000 ms.
- `TFormEditorController.UpdateOperation` на каждый MouseMove вызывал
  `NotifyChanged` и `RenderLive`.
- Undo/copy snapshot хранил вручную только часть свойств `StaticText`,
  `TagValue` и `Oscillogram`; настройки тренда/спектра и часть свойств текста
  терялись.

## Fix

- Добавлен общий offline-реестр в `uRecorderHardwareLiveDevices`.
- MIC-140 и MIC-185 помечают sourceId offline при неудачном connect/start.
- `UpdateActiveSourceIds`, `RecorderHardwareSourceLinkOk` и создание runtime
  data source учитывают offline-метку.
- В аппаратное дерево добавлены ручные команды сброса состояния одного или всех
  устройств.
- Probe дерева сокращен до 250 ms, MIC-185 connect - до 1 попытки по 1200 ms.
- Drag/resize в редакторе форм больше не вызывает `NotifyChanged` на каждый
  MouseMove; live-render throttled до 40 ms и принудительно выполняется в конце
  операции.
- Undo/copy теперь сохраняет snapshot компонента с переносом свойств для
  StaticText, TagValue, Oscillogram, Trend и Spectrum.

## Verification

- Первый `lazbuild` дошел до линковки, но `RecorderLnx.exe` был занят
  запущенным PID 2004.
- После `Stop-Process -Id 2004` повторный `C:\lazarus\lazbuild.exe -B
  D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` завершился с exit
  code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  завершился с exit code 0.

## Follow-up 2026-10-09: 3D component reset after Ctrl+Z

### Symptom

- После удаления настроенного 3D-компонента и Ctrl+Z компонент возвращался с
  настройками по умолчанию.

### Root cause and fix

- Undo создаёт снимки через общий `CopyComponentState`, но в диспетчере не было
  ветки `TRecorder3dComponent`; в снимок попадали только базовые поля.
- В общий путь Undo/Copy/Paste подключён глубокий
  `TRecorder3dComponent.Assign`, сохраняющий сцену, камеру, примитивы, Skin,
  матрицы, градиенты и якоря цветов вершин.
- Общий флаг `UseInactiveTag` теперь также переносится во все снимки.

### Verification

- Forced build `RecorderFormModelTest.lpi` — exit code 0; изолированный запуск
  `--3d-editor-snapshot-only` проверяет именно общий dispatcher Undo/Copy,
  включая base state, сцену и вложенный Skin, exit code 0.
- Forced build `RecorderLnxDragVerify.lpi` — exit code 0.
- Основной `RecorderLnx.lpi` полностью скомпилирован и дошёл до линковки; замена
  `RecorderLnx.exe` заблокирована запущенным процессом (Windows error 5).
