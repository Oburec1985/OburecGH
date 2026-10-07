# 3D Skin не обновлялся при drag, примитивы были чёрными

## Симптомы

- После `OK` вершина принимала положение helper, но последующий drag helper не
  менял сетку.
- Процедурный/default cube выглядел чёрным и визуально сглаженным.

## Подтверждённые причины

- `T3dLclWidget` вызывал `OnNodeTransformChanged`, но
  `TRecorder3dView.NodeTransformChanged` только сохранял transform. Skin
  применялся позднее лишь через configure/tag/FRF paths.
- Engine-created mesh не получал явный цвет и нормали. Нулевой RGB оставался
  чёрным, а renderer подставлял одну нормаль `(0,0,1)` всем граням.
- Старый default cube разделял восемь вершин между шестью гранями, поэтому
  усреднённые vertex normals создавали нежелательное сглаживание.

## Исправление

- Drag SkinBone применяет уже подготовленный `T3dSkinEngine` без reconfigure и
  без изменения bind pose.
- Добавлен общий пересчёт нормалей после создания и Skin-деформации.
- Default cube строится тем же face-corner builder, что процедурный куб;
  procedural mesh получает нейтральный видимый цвет.
- Semantic wire edges процедурных grid-полигонов хранятся отдельно, без
  внутренних диагоналей триангуляции.
- Добавлена команда возврата всех helper к `BindLocalTransform`.

## Проверка

- Forced `RecorderLnx.lpi` собирается и линкуется.
- `ThreeDInteractionTest` проверяет повторное движение helper, immutable bind,
  независимые разбиения балки, цвет и нормали.
- `RecorderFormModelTest` проверяет round-trip поперечного разбиения.

