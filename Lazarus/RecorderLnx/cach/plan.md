# План упрощения интерфейса IVForm и восстановления сборки

- [x] Шаг 1: Обновить uRecorderVisualControl.pas - убрать stubs для ITag, IRecorder, упростить интерфейс IVForm (убрать stdcall, оставить только 3 LCL метода: Configure, RefreshControl, GetChartControl). Удалить 12 stdcall заглушек из TRecorderStaticTextView и TRecorderTagValueView.
- [x] Шаг 2: Обновить uRecorderTrendView.pas - удалить 12 stdcall заглушек, убрать stdcall из методов класса. Сохранить оптимизацию в Configure.
- [x] Шаг 3: Обновить uRecorderOglOscillogramView.pas - удалить 12 stdcall заглушек, убрать stdcall из методов класса. Сохранить оптимизацию в Configure.
- [x] Шаг 4: Обновить uFormEditorController.pas - убедиться, что он использует простой IVForm.
- [x] Шаг 5: Обновить README_MnemonicControls.md с описанием упрощенного IVForm.
- [x] Шаг 6: Проверить кодировку cp1251 и CRLF во всех файлах и проверить успешность сборки (lazbuild).
