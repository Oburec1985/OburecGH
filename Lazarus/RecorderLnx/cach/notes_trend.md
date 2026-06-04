# Анализ uRecorderTrendView и uRecorderTrendSettingsDialog

## Текущая реализация uRecorderTrendView.pas
- Сейчас `TRecorderTrendView` наследуется от `TCustomControl` и рисует график вручную через `Canvas.MoveTo`/`LineTo` в процедуре `Paint`.
- Захват данных и расчет оценок происходят в `RefreshTrend` через периодические интервалы (`UpdatePeriodSec`), сохраняя точки в `fSeries` (очистка старых данных происходит в `PruneSeries`).

## Реализация TOglChart (OpenGL)
- Использует древовидную модель: `TChartModel` -> `TChartPage` -> `TChartAxis` -> `cLineSeries` (или `cBuffTrend1d`).
- Поддерживает автоматическое размещение страниц (`AlignPagesAuto`), сетку, курсоры, авто-масштабирование и отрисовку через шейдеры/OpenGL списки.
- Цвета передаются как `RGBA` (`(Color and $00FFFFFF) or $FF000000`).

## План переработки uRecorderTrendView
1. Заменить базовую прорисовку в `TRecorderTrendView` на использование встроенного `TOglChart`.
2. В `TRecorderTrendView` создать `fChart: TOglChart` как дочерний элемент (`alClient`).
3. Поддерживать динамическое создание `TChartPage`, `TChartAxis` и `cLineSeries` (из `uOglChartTrend.pas`) на основе настроек `fComponent`.
4. В `RefreshTrend` собирать точки в `fSeries` (display history) и переносить их в соответствующие `cLineSeries` модели `TOglChart`.
5. Для легенды (если `fComponent.LegendVisible` включено) выводить легенду справа, используя `TPaintBox` или `TPanel` с отрисовкой на Canvas, чтобы не ломать OpenGL-контекст рендерера (поскольку встроенный `TOglChartRenderer` не рисует легенду тренда).
