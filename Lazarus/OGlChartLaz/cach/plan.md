# План текущих доработок OglChart (Lazarus)

## Выполнено:
- [x] Регистрация класса TOglChart на уровне рантайма (`RegisterClass(TOglChart)`) для устранения ошибки `EClassNotFound`.
- [x] Оптимизация генерации данных в тесте производительности: заполнение локального массива в цикле с последующим единовременным вызовом `AddPoints` / `AddValues`.
- [x] Реализация пакетных методов добавления точек `AddPoints` в `cLineSeries` и значений `AddValues` в `cBuffTrend1d` (предотвращает частые медленные реаллокации памяти `SetLength`).
- [x] Реализация механизма ускорения рендеринга геометрии с помощью OpenGL Display Lists (`glNewList` / `glEndList` / `glCallList`) для `cLineSeries` и `cBuffTrend1d` при использовании шейдеров.
- [x] Массовое комментирование и добавление XML-аннотаций к классу `TOpenGLChartRenderer` в модуле `uOglChartRenderer.pas`.
