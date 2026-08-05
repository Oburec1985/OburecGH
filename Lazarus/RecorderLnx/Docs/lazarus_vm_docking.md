# Восстановление dockable-интерфейса Lazarus в VM Atra

## Для чего это нужно

Рабочий Lazarus в Astra Linux использует профиль
`/home/user/.lazarus_work`. В нём включён штатный пакет `AnchorDocking`, который
собирает окна IDE в одну закрепляемую раскладку: инспектор объектов слева,
редактор по центру, обозреватель справа и сообщения снизу.

Если окна снова стали отдельными или раскладка повредилась, закройте Lazarus и
запустите на Windows рабочем столе `Restore_Lazarus_Docking_VM.bat`.

## Что делает BAT-файл

1. Проверяет, запущена ли VM Atra, и при необходимости запускает её.
2. Выполняет внутри VM `Tools/configure_lazarus_docking_linux.sh`.
3. Сохраняет резервную копию профиля `.lazarus_work`.
4. Подключает `AnchorDocking` и `AnchorDockingDsgn`, пересобирает IDE.
5. Запускает Lazarus той же командой, что ярлык рабочего стола VM:
   `startlazarus-2.2.6 --pcp=/home/user/.lazarus_work`.

Не запускайте восстановление, пока Lazarus открыт: закрытие IDE предотвращает
конфликт с файлами конфигурации и незапланированную потерю несохранённых правок.

## Ручной запуск

Если BAT-файл недоступен, в VM можно выполнить:

```bash
bash /mnt/win_share/OburecGH/Lazarus/Tools/configure_lazarus_docking_linux.sh /home/user/.lazarus_work
```

Затем откройте ярлык `Lazarus (2.2.6)` на рабочем столе VM.

## Связанные материалы

- [VM Atra: установка Lazarus-пакетов](vm_atra_lazarus.md)
- [Linux-макрос настройки](../../Tools/configure_lazarus_docking_linux.sh)
