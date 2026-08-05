# Заметки: Начальный анализ OglChart

## Дата: 2026-05-29

## Что сделано
1. Полный обзор 18 файлов пакета chart_lzr
2. Обзор тестового проекта Test_component
3. Обзор Delphi-прототипа chart_dpk (каталог chart/ с uChart.pas 36KB)
4. Успешная сборка проекта через lazbuild

## Ключевые находки

### Архитектура
- Дерево объектов: cBaseObj → cDrawObj → cMoveObj → (cBasePage, cAxis, cTrend...)
- cChart — корень модели, cChartMng — менеджер с плоским реестром
- TOglChart — LCL-компонент, наследник TOpenGLControl
- TOglChartControl — альтернативный контрол с CriticalSection (для потокобезопасности)
- TChartFrameListener — цепочка обработчиков (Pan/Zoom/Select/BezierEdit)

### Проблемы кроссплатформенности
- `uoglchart.pas:71` — `uses Windows` (QueryPerformanceFrequency/Counter)
  - Нужно: {$IFDEF WINDOWS}Windows{$ELSE}...{$ENDIF} или EpikTimer/GetTickCount64

### Кодировка
- Большинство .pas файлов — UTF-8 (без BOM)
- Некоторые комментарии в cp1251 → при просмотре UTF-8 выглядят мусором
- uOglChartDrawObj.pas, uOglChartTypes.pas — комментарии битые

### Delphi-прототип
- `chart_dpk\chart\uChart.pas` — 36KB, монолитный файл
- Lazarus-версия разделена на 14+ модулей — хорошая декомпозиция

### Тестовый проект
- 4 демо-страницы: Trend (Bezier), Signals (2 оси), Bars (BuffTrend1d), OwnX
- TreeView для навигации по дереву объектов
- StatusBar с координатами мыши в единицах осей
- Замер FPS через QueryPerformanceCounter
