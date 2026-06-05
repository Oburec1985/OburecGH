# Заметки по рефакторингу

## Результаты
- Интегрирован общий модуль uSharedAlgorithms с generic-классом TBinarySearch.
- В uRecorderTrendView.pas выполнена оптимизация функции EstimateSlice с переходом на O(log N) поиск с помощью TDoubleSearch (специализации TBinarySearch<Double>).
- В uRecorderOglOscillogramView.pas рендеринг оптимизирован за счет поиска начального индекса отрисовки с помощью бинарного поиска вместо полного сканирования.
- Устранена дублирующаяся декларация метода CalculateSliceEstimate в классе TRecorderTrendView, вызвавшая ошибку компиляции.
- Реализованы проверки IsVisible для предотвращения лишней работы UI-компонентов.
- Все тесты проекта успешно компилируются и выполняются без ошибок через обновленный скрипт run-recorder-tests.ps1.

## 2026-06-05: расчет оценок тренда без копирования срезов

- Добавлена core-функция `CalculateRecorderTagEstimateRange` в `Core/uRecorderTags.pas`.
- `UI/uRecorderTrendView.pas` больше не собирает временные массивы для каждого временного среза: границы ищутся через `TBinarySearch<Double>`, расчет выполняет core-helper.
- Поведение интервала сохранено: берутся точки `(AStartTime; AEndTime]`.
- Проверка: `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` прошел успешно, остались только существующие warnings/hints.

## 2026-06-05: тренд по порциям оценок

- Тренд больше не режет данные по `UpdatePeriodSec`/временному окну: оценка строится по последовательным порциям `TRecorderTagEstimateSettings.PortionLength`.
- Время точки тренда берется как середина порции: `(firstTime + lastTime) / 2`.
- Размер порции по умолчанию считается как `Round(PollFrequencyHz * DataUpdateMs / 1000)`; исторический `17280` считается авто-дефолтом.
- При смене `DataUpdateMs` в настройках Recorder авто-размеры порций пересчитываются, но ручные значения пользователя сохраняются.
- При обновлении частоты MERA-канала авто-размер порции также пересчитывается под новую частоту.
- Проверка: `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` прошел успешно.

## 2026-06-05: исправление остановки обновления тренда

- Причина: старые проекты могли держать `PortionLength = 17280`; тренд ждал полную порцию, а для низких частот/малого буфера это выглядело как полная остановка графика.
- Исправление: при настройке источников `EnsureTagSignalBufferCapacities` пересчитывает авто/legacy-порцию под `PollFrequencyHz` и `DataUpdateMs`, а буфер тега расширяется минимум до `PortionLength + 1`.
- Проверка: `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` прошел успешно.
## 2026-06-05: scalar/vector trend tick handling
- Scalar tags now add one point per received scalar sample and use the latest tag/Recorder sample time as X.
- Vector tags calculate the trend portion from the trend update period and tag polling frequency, so one data update tick can produce several trend points.
- Legacy auto portion values and data-tick-sized vector portions are treated as auto for trend rendering.
- Verified with `lazbuild -B RecorderLnx.lpi`.
## 2026-06-05: trend X uses Recorder time
- Log analysis showed MERA vector blocks advance in Recorder/sample time normally; UI rendering was active.
- Trend points previously stored X relative to the first trend sample, which could make the trend axis lag or diverge from Recorder time.
- Trend points now store absolute tag/Recorder sample time for both scalar and vector branches; the visible X window is based on the latest absolute point time.
- Verified with `lazbuild -B RecorderLnx.lpi`.
