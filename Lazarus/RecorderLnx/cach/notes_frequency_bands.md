# Заметки по реализации частотных полос в RecorderLnx

## Исследование архитектуры
1. **Модель полос**: в `uRecorderFrequencyBands.pas` уже есть классы `TRecorderFrequencyBand` и `TRecorderFrequencyBandList`. Диалог `uRecorderFrequencyBandsDialog.pas` полностью готов и использует `fBands: TRecorderFrequencyBandList` для редактирования.
2. **Интеграция с ядром**:
   - `TRecorderTagRegistry` в `uRecorderTags.pas` будет хранить глобальный список полос `FrequencyBands`.
   - Проектные файлы `uRecorderProjectFiles.pas` будут сохранять полосы в секцию `frequencyBands` проектного JSON.
3. **Расчет в реальном времени**:
   - `TRecorderSpectrumRuntimeManager` в `uRecorderSpectrumRuntime.pas` получает кадры спектра от каналов и обрабатывает их.
   - Место расчета полос: `TRecorderSpectrumRuntimeManager.HandleChannelFrame`. В этом методе мы имеем доступ к `fTagRegistry` (откуда берем последние значения тахо-каналов для расчета формульных полос через `Evaluate`) и рассчитываем RMS/пики в полосах для каждого нового кадра.
4. **Визуализация на OpenGL**:
   - График в Lazarus использует OpenGL-компонент `TOglChart`.
   - Для отображения полос мы добавим поддержку кастомных названий в `TOpenGLChartRenderer.GetCursorLabelTextAndColors`.
   - В `TRecorderSpectrumView.pas` будем динамически создавать для каждой полосы `TChartCursor` с `CursorType = cctDouble` и устанавливать границы в соответствии с рассчитанными значениями полосы `F1`/`F2`.
