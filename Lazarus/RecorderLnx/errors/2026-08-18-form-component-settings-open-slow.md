# 2026-08-18 Form component settings open slow

## Symptom

- Пользователь сообщил, что вход в редактирование элемента на формуляре
  долгий: после входа в редактирование и клика на элемент/фокус интерфейс
  заметно тупит.

## Related History Checked

- `errors/2026-07-13-preview-offline-and-form-editor-lag.md`: прежняя причина
  была в drag/resize, где `UpdateOperation` делал `NotifyChanged` и
  `RenderLive` на каждый `MouseMove`.
- `errors/2026-07-21-linux-mnemonic-first-open-slow.md`: прежняя причина
  первого открытия мнемосхемы была в построении OpenGL font atlas.

Эти причины не совпадают с текущим симптомом: пользователь описывает задержку
при входе/фокусе на элементе, а код открытия свойств компонента выполнялся
синхронно в UI-потоке.

## Confirmed Facts

- `TComponentSettingsDialog.LoadFromComponent` вызывал `PopulateTags('')` при
  каждом открытии диалога свойств компонента.
- `PopulateTags('')` проходил весь `TRecorderTagRegistry`, для каждого тега
  формировал поисковую строку `Name + Address + Description`, делал `LclText`
  и добавлял тег в `TComboBox`.
- В больших проектах с сотнями/тысячами тегов это создаёт паузу в GUI-потоке
  до того, как пользователь начал искать другой тег.

## Checked Hypotheses

- Повтор старой гипотезы про drag/resize: не подтверждён как основная причина
  этой задержки, потому что старый fix уже убрал рендер/notify на каждый
  `MouseMove`, а текущая задержка связана с открытием/инициализацией диалога.
- Повтор гипотезы про первое построение font atlas: не подтверждён как
  основная причина, потому что задержка привязана к свойствам компонента и
  списку тегов.
- Full tag combo build on dialog open: подтверждено по коду.
- После ручной проверки пользователь уточнил, что долгим остаётся именно выбор
  элементов. Это опровергло достаточность fix по `TComponentSettingsDialog`.
- Simple click selection path: подтверждён второй корень. `ComponentMouseDown`
  выделял компонент, затем `MouseUp` вызывал `UpdateOperation` даже при
  нулевом смещении. `UpdateOperation` для `feoDrag` вызывал
  `RenderLiveDuringOperation(False)`, а тот безусловно ставил
  `fOperationChanged := True`. В результате простой клик без движения
  считался изменением модели, вызывал `NotifyChanged` и полный `Render`.

## Fix

- `TComponentSettingsDialog.LoadFromComponent` больше не строит полный список
  тегов при открытии.
- Добавлен `PopulateInitialTagSelection`: в combo кладется только текущий тег
  компонента, найденный по `TagId`, затем по `TagName`.
- Полный поиск остается доступен через поле фильтра; при пустом фильтре список
  ограничен первыми 200 тегами, чтобы случайное очищение поиска не подвешивало
  UI.
- Добавлен лёгкий `TFormEditorController.RefreshSelectionVisuals`: он только
  обновляет bevel выбранных панелей и ручки resize, не пересоздаёт компоненты и
  не вызывает `IVForm.RefreshControl` по всей странице.
- `UpdateOperation` больше не делает runtime/render работу при нулевом
  смещении мыши.
- `ComponentMouseUp`, `ChildMouseUp` и `CanvasMouseUp` при отсутствии реального
  изменения модели вызывают только `RefreshSelectionVisuals`, а не полный
  `Render`.

## Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  завершился с exit code 0.
- После второй правки первый rebuild дошёл до линковки, но был заблокирован
  запущенным `RecorderLnx.exe` PID 10076 (`error code: 5`). Процесс остановлен,
  повторный rebuild завершился с exit code 0.
- Ручная проверка выбора элементов пользователем ещё нужна. Если задержка
  останется, следующий шаг - смотреть частоту `[MNEMO-PERF] render ...` при
  одном клике: после fix обычный выбор не должен писать полный render на
  каждый `MouseUp`.
