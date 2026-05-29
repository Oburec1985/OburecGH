# План внедрения аннотаций OGLChart

- [x] Создание uOglChartTextLabel.pas (TChartTextLabel, TChartFlagLabel)
- [x] Интеграция рендеринга DrawTextLabel в TOpenGLChartRenderer
- [x] Поддержка переноса строк, мировых и оконных координат
- [x] Расчет проекций и интерполяция значений трендов для флагов
- [x] Реализация интерактивного перетаскивания и изменения размеров меток в TChartPanZoomListener
- [x] Динамическое изменение формы курсора мыши в TChartSelectListener
- [x] Исправление полиморфной десериализации JSON в TJsonChartSerializer
- [x] Добавление модульных тестов uOglChartTextLabelTests.pas
- [x] Регистрация всех модулей в lzrObrPack.lpk
- [x] Реализация функций полного зума FitZoomX, FitZoomY, FitZoomXY (перегруженных для TChartPage/TChartAxis) с рекурсивным обходом всех объектов (включая TChartTextLabel и TChartFlagLabel)
- [x] Исправление привязки осей для флагов (`TChartFlagLabel`) в `ProcessObjectBounds` (исправление бага "флаги не призумливаются")
