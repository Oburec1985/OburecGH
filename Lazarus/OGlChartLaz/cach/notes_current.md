# Заметки по текущей итерации доработки OGlChart (Страницы и Курсор)

## Что сделано:
1. **Разделение uOglChartFrameListener и uOglChartPageGeometryListener**:
   - Очищен uOglChartFrameListener.pas — теперь он содержит только базовый класс TChartFrameListener и процедуру LogToFile.
   - В uOglChartPageGeometryListener.pas перенесена и полностью реализована логика класса TChartPageGeometryListener. Устранена ошибка сборки Illegal unit name: uOglChartFrameListener.
   
2. **Диагональное изменение размера страниц (углы)**:
   - В TChartPageGeometryListener добавлены коды границ 5..8 для углов страниц:
     - 5: Верхний-левый угол (NWSE) -> курсор crSizeNWSE
     - 6: Верхний-правый угол (NESW) -> курсор crSizeNESW
     - 7: Нижний-левый угол (NESW) -> курсор crSizeNESW
     - 8: Нижний-правый угол (NWSE) -> курсор crSizeNWSE
   - Логика примагничивания (SnapX/SnapY) корректно работает по обеим осям при диагональном растяжении за углы.

3. **Устранение промаргивания (мерцания) курсора**:
   - Проверено, что ни один из слушателей не сбрасывает курсор в crDefault в методе MouseMove, если его собственное условие наведения не выполнено.
   - Главный цикл обработки мыши TOglChart.MouseMove сбрасывает курсор в crDefault перед запуском цепочки слушателей, после чего нужный слушатель выставляет правильный курсор (например, crSizeWE или crSizeNWSE). Это убрало конфликты между слушателями и мерцание курсора.
