# AV при добавлении Skin-кости

## Симптом

При нажатии «Добавить узловую точку» RecorderLnx выдавал access violation.
Стек заканчивался в `T3dScene.HashSlot -> FindNode ->
TRecorder3dSkinBindingAdapter.AttachScene`.

## Причина

Общий обработчик настроек заменял owned 3D scene. Skin adapter, в отличие от
других потребителей сцены, не отсоединялся до замены и сохранял non-owning
указатель. Его `Configure` скрыто выполнял `AttachScene(fScene)` уже после
освобождения старой сцены. Ошибка в hash index была следствием use-after-free,
а не дефектом хеширования.

## Исправление

- До `ApplyModel`, способного заменить сцену, отсоединяются Skin engine и
  Skin binding adapter.
- `TRecorder3dSkinBindingAdapter.Configure` сначала выполняет
  `AttachScene(nil)` и больше не подключает сохранённую сцену скрыто.
- Skin-редактор применяет изменения лёгким обновлением Skin, без вложенной
  полной пересборки сцены из обработчика кнопки.

## Проверка

- `Skin adapter scene replacement test passed`: adapter подключён к старой
  сцене, сцена освобождена, повторный `Configure` не обращается к ней.
- `Skin bone durable bind test passed`.
- `RecorderFormModelTest` и `ThreeDInteractionTest` прошли.
- Forced-сборка RecorderLnx успешно слинкована.

