# SharedUtils 3D

Новый Delphi-слой для независимого 3D-виджета. Он не зависит от Recorder,
`cTag`, `TSRSFrm`, VCL-форм или конкретного OpenGL renderer.

Стабильный сценарий: `Configure sources/bindings -> Load scene -> Apply snapshot
-> Render if dirty -> Release context`.

Текущие точки расширения:

- `I3dDisplacementSource` поставляет готовые смещения точек;
- `I3dTransformTarget` адаптирует helper/кость конкретной модели;
- `T3dHelperMotionEngine` связывает источник и helper с настраиваемым базисом
  осей, масштабом и исходной позицией;
- `T3dFrfDisplacementSource` интерполирует амплитуду/фазу FRF и выдаёт
  гармонические смещения без зависимости от `SrsFrm`;
- `I3dSceneLoader` является границей для compatibility-loader `.obr/.oba`.
- `T3dLegacySceneLoader` подключает существующий `cScene.LoadFile_Obr` (и
  сопровождаемый им `.oba`) через callback, не затягивая legacy scene graph в
  контракты нового виджета;
- `T3dWidget` — VCL-host, управляющий окном и dirty-render lifecycle; renderer
  подключается через `I3dRenderer`;
- `T3dOpenGLRenderer` — минимальный Win32/WGL backend с корректным владением
  DC/RC; `DrawScene` является точкой расширения до scene renderer;
- `T3dFrfAnimationComponent` объединяет FRF-source и движок helper-привязок,
  не импортируя Recorder или OpenGL.

Legacy-источники используются как эталон поведения, а не копируются целиком:

- `3d/objects/uObrFile.pas`, `uObaFile.pas`, `uSkin.pas`,
  `uBaseDeformer.pas` — форматы, skin weights и деформация;
- `recorder/plgControlCyclogram/units/u3dMoveEngine.pas` — движение по каналам;
- `recorder/plgControlCyclogram/units/uModelPointMng.pas` — FRF-анимация.

Следующие обязательные слои: независимый codec `.obr/.oba`, scene renderer и
Recorder adapter, который один раз разрешает теги в источники. Они не должны
добавлять зависимости Recorder в core/animation/contracts.
