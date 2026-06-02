# План доработки проекта RecorderLnx (Добавление комментариев и аннотаций)

## Список задач
- [x] Определение требований к аннотациям и комментариям
- [x] Анализ кодировки и комментариев во всех файлах проекта
- [x] Добавление комментариев в модули Core:
  - [x] uRecorderCoreServices.pas
  - ...
  - [x] uRecorderTimeSystem.pas
- [x] Добавление комментариев в модули UI:
  - [x] uFormEditorController.pas
  - ...
  - [x] uTagSettingsDialog.pas
- [x] Проверка кодировки cp1251 во всех измененных файлах, отсутствие BOM, CRLF

## Итерация: Рефакторинг кнопок редактора мнемосхем
- [x] Разработка метода `AddEditMnemoToolBarButton` в `TMainForm`
- [x] Рефакторинг `EnsureEditorSurface` с использованием нового метода
- [x] Проверка сборки проекта через `lazbuild.exe`
- [x] Проверка кодировки cp1251 в `uMainForm.pas`, переводы строк CRLF, без BOM

## Итерация: Сетка осциллограмм на базовой странице (Auto-Align)
- [x] Интеграция математики сетки AlignPagesAuto в `RebuildRecorderOglOscillograms`
- [x] Перевод позиционирования контроллеров на `SetBounds`
- [x] Проверка сборки проекта через `lazbuild.exe`
- [x] Проверка кодировки cp1251 в `uRecorderOglOscillogramView.pas`, переводы строк CRLF, без BOM

## Итерация: Отображение тега и FPS в TOglChart
- [x] Добавление TLabel и сохранение имени текущего тега в `TRecorderOglOscillogram`
- [x] Подписка на OnAfterRender и расчет FPS
- [ ] Проверка сборки проекта через `lazbuild.exe`
- [x] Проверка кодировки cp1251 в `uRecorderOglOscillogramView.pas`, переводы строк CRLF, без BOM
