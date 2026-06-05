# План упрощения интерфейса IVForm и восстановления сборки

- [x] Шаг 1: Обновить uRecorderVisualControl.pas - убрать stubs для ITag, IRecorder, упростить интерфейс IVForm (убрать stdcall, оставить только 3 LCL метода: Configure, RefreshControl, GetChartControl). Удалить 12 stdcall заглушек из TRecorderStaticTextView и TRecorderTagValueView.
- [x] Шаг 2: Обновить uRecorderTrendView.pas - удалить 12 stdcall заглушек, убрать stdcall из методов класса. Сохранить оптимизацию в Configure.
- [x] Шаг 3: Обновить uRecorderOglOscillogramView.pas - удалить 12 stdcall заглушек, убрать stdcall из методов класса. Сохранить оптимизацию в Configure.
- [x] Шаг 4: Обновить uFormEditorController.pas - убедиться, что он использует простой IVForm.
- [x] Шаг 5: Обновить README_MnemonicControls.md с описанием упрощенного IVForm.
- [x] Шаг 6: Проверить кодировку cp1251 и CRLF во всех файлах и проверить успешность сборки (lazbuild).
- [x] Шаг 7: Оптимизация работы с файлами MERA. Перевод PublishVectorDue на блочное чтение без постоянных вызовов ReadBuffer и копирование через Move.
- [x] Шаг 8: Оптимизация копирования динамических массивов через Move в uRecorderEventQueue.pas и uRecorderTags.pas для снижения нагрузки на CPU.
- [x] Шаг 9: Восстановление корректных условий IndexOf (исправление регрессии виртуального девайса) и добавление именования потоков в логе (UIThread, Src_mera.file.1, Src_debug.diagnostics).
- [x] Шаг 10: Очистка лог-файла при старте приложения (удаление старого файла лога в секции initialization модуля uRecorderDebugLog.pas).
- [x] Шаг 11: Оптимизация циклов (бинарный поиск интервалов за O(log N) в трендах и осциллограммах) и предотвращение перерисовок скрытых элементов (Visibility Throttling).
