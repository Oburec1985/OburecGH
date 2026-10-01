# SharedUtils 3D for Lazarus

Платформонезависимая основа 3D-компонентов RecorderLnx.

- `core` — типы камеры и геометрии без LCL/OpenGL/тегов;
- `contracts` — границы host, renderer и animation snapshot;
- `io` — безопасные платформонезависимые загрузчики legacy `OBR`/`OBA`;
- `interaction` — state machine ввода, камера, picking и gizmo без LCL;
- `render/opengl` — OpenGL renderer, не владеющий нативным контекстом;
- `lcl` — единственный адаптер к `TOpenGLControl` и его lifecycle.

RecorderLnx подключает эту библиотеку через собственные model/view adapters.
Tag registry, FRF и другие источники движения не должны попадать в renderer:
они подают типизированные versioned snapshots через отдельные adapters.

Delphi-каталог `sharedUtils/3d` остаётся источником legacy-алгоритмов для
контролируемого переноса. VCL/WGL host из него не используется в Lazarus.
