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


## Итерация: Отображение уставок и Right Click формы настроек
- [x] Отображение цветом уставок в визуальных компонентах и таблице sgFormular
- [x] Формы настроек визуальных компонентов по Right Click (динамические диалоги с поиском тега по подстроке)

## Итерация: Текстурный атлас шрифтов (Font Atlas) и размер шрифта меток
- [x] Реализация текстурного атласа cOglFont в uOglChartFontMng.pas с использованием TBitmap и Canvas LCL
- [x] Реализация аппаратного рендеринга DrawTextHardware с текстурными координатами и смешиванием
- [x] Реализация программного fallback-рендеринга DrawTextSoftware по матрице GlyphRow
- [x] Делегирование рендеринга из TOpenGLChartRenderer.DrawText в cOglFont.DrawText
- [x] Добавление свойства PageCaptionFontSize в TRecorderOglOscillogramSurface для управления размером шрифта
- [x] Коррекция кодировок файлов (Windows-1251), переводы строк CRLF, без BOM
- [x] Написание юнит-тестов для проверки корректности работы и масштабирования шрифтов
- [x] Успешная компиляция и сборка проекта RecorderLnx через lazbuild.exe

## Итерация: Поддержка кириллицы (WideChar наборы)
- [x] Замена статической cp1251 константы SUPPORTED_CHARS на динамическое заполнение WideString кэша в cOglFont.Create через Unicode-диапазоны ASCII и кириллицы
- [x] Явное приведение к WideString в BuildTextureAtlas перед вызовом UTF8Encode(WideString(lChar)) для кроссплатформенной корректности
- [x] Успешная перекомпиляция и тестирование запуска RecorderLnx.exe

## Итерация: Безопасное отсутствие файла виртуального девайса
- [x] Обработка отсутствия файла в TRecorderMeraFileDataSource.DoCreateTags и TRecorderMeraFileDataSource.Start (выход без генерации исключения)
- [x] Отображение иконки нерабочего устройства (индекс 31) в PopulateHardwareTree диалога настроек для отсутствующего файла Mera
- [x] Пункт меню "Настройка источника..." в дереве устройств для открытия TOpenDialog и изменения пути к файлу
- [x] Автоматическое обновление SourceId у связанных тегов в реестре при смене файла
- [x] Успешная сборка проекта
