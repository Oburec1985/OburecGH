# Смена объекта MDB сохраняла старые отметки FRF

Симптом: после смены объекта и пути FRF отображались два сохранённых шага
предыдущего объекта. Captured жил в маршрутных записях независимо от каталога;
смена root не очищала stored session, repository и result review. Виджет также
возвращал успех для любого уже заданного каталога, не замечая новый объект MDB.

Исправление: SetDirectory нормализует новый путь без записи файлов, сохраняет
структуру шагов/связей, пересчитывает Captured по session.json/curve.frf нового
каталога. Save(newpath) и Load используют ту же фактическую проверку.
Service отслеживает directory context: старые repository/provider, stored
presentation и review инвалидируются, fHasUnsavedRuntime и captures не меняются.
UI снимает review-галку, обновляет открытую форму маршрута. MDB model setters
увеличивают revision; XML-путь разрешается только при изменении контекста, не
при каждом кадровом обновлении. Ручной путь с MDB=False не заменяется.

Проверка: service route-point-only A(saved)→B(empty)→A, существующие файлы
не удаляются, rebind не создаёт route.ini, 3 RAM-удара сохраняются. UI
mdb-model-path-only меняет ObjectId компонента на другой странице и проверяет
путь виджета/открытой формы и MDB-режим; route-spinner-only и
live-geometry-binding-only также PASS. Forced app/UI/service builds exit0.
Пользовательская БД не использовалась: только GUID/test temp fixtures.
