# Журнал итераций 3d / Delphi 2010

## 2026-10-01 — ошибка SetImages при размещении cBaseGlComponent

Запрос: устранить ошибку Delphi 2010 «точка входа `TBaseVirtualTree.SetImages` не найдена в `GlPackage.bpl`», возникающую при перетаскивании `cBaseGlComponent` на форму.

Сделано:

- установлено, что `VirtualTrees.pas` неявно включался сразу в `dcl_own.bpl` и `GlPackage.bpl`, а штатный runtime-пакет VirtualTrees отсутствовал;
- `VirtualTreesR` добавлен в `requires` и project references пакетов `dcl_own` и `GlPackage`;
- собраны `VirtualTreesR14.bpl`, `dcl_own.bpl` и `GlPackage.bpl` для Delphi 2010;
- через `tdump` подтверждено, что `GlPackage.bpl` теперь импортирует `TBaseVirtualTree.SetImages` из `VirtualTreesR14.bpl`, который экспортирует этот символ.

Проверка после перезапуска IDE: положить `cBaseGlComponent` на форму. Запущенная IDE пока держит прежние BPL в памяти.
