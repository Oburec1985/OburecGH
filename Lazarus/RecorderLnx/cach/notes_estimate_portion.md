# Анализ порции расчета оценок

**Промпт:**
> почему при обновлении данных через 0,2 сек порция 30 отсчетов

### Причина
В функции `ShowTagSettingsDialog` (модуль `uTagSettingsDialog.pas`) создание диалога происходит следующим образом:
```pascal
lDialog := TTagSettingsDialog.CreateDialog(AOwner, ATagRegistry, ATags, AImages);
try
  lDialog.fDataUpdateMs := ADataUpdateMs;
  Result := lDialog.ShowModal = mrOk;
```
В конструкторе `CreateDialog` в самом конце вызывается метод `LoadFromTags`.
Внутри `LoadFromTags` происходит расчет порции по умолчанию:
```pascal
if (fTags.Count > 0) and RecorderTagEstimatePortionLengthIsAuto(lInt, TagAt(0).PollFrequencyHz, fDataUpdateMs) then
  lInt := RecorderTagDefaultEstimatePortionLength(TagAt(0).PollFrequencyHz, fDataUpdateMs);
```
Но на момент работы конструктора и вызова `LoadFromTags` поле `lDialog.fDataUpdateMs` еще равно `0`, так как присвоение `lDialog.fDataUpdateMs := ADataUpdateMs` выполняется **после** завершения конструктора.

При `fDataUpdateMs = 0` функция `RecorderTagDefaultEstimatePortionLength` подставляет дефолтный период `300` мс.
Для частоты опроса `100` Гц расчет дает:
`Round(100 * 300 / 1000) = 30` отсчетов (вместо `20` при `200` мс).

### Решение
1. Изменить сигнатуру конструктора `CreateDialog` в `TTagSettingsDialog` (добавить параметр `ADataUpdateMs: Cardinal = 200`):
   ```pascal
   constructor CreateDialog(AOwner: TComponent; ATagRegistry: TRecorderTagRegistry;
     ATags: TList; AImages: TCustomImageList = nil; ADataUpdateMs: Cardinal = 200); reintroduce;
   ```
2. Внутри конструктора присваивать `fDataUpdateMs := ADataUpdateMs;` перед вызовом `LoadFromTags`.
3. В функции `ShowTagSettingsDialog` передавать `ADataUpdateMs` в конструктор:
   ```pascal
   lDialog := TTagSettingsDialog.CreateDialog(AOwner, ATagRegistry, ATags, AImages, ADataUpdateMs);
   ```
