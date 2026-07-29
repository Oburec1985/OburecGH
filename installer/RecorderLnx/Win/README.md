# RecorderLnx Windows installer

Скрипт `RecorderLnx.iss` предназначен для Inno Setup 7.

## Сборка

```powershell
.\build-installer.ps1
```

Скрипт сначала полностью пересобирает `RecorderLnx.lpi`, затем создаёт:

`Output\RecorderLnx-Setup-0.1.0.exe`

Для автоматической установки каталог данных можно передать параметром:

```powershell
RecorderLnx-Setup-0.1.0.exe /VERYSILENT /MERAFILES="D:\Mera Files"
```

## Устанавливаемая структура

По умолчанию приложение устанавливается в:

`C:\Program Files (x86)\Mera\RecorderLnx`

Рядом с exe создаются:

- `plugins` — плагины;
- `bios` — прошивки модулей;
- `syscom` — дополнительные библиотеки;
- `RecorderLnx.paths.ini` — системные пути.

Изменяемые конфигурации размещаются в
`C:\Mera Files\RecorderLnx\config`, а SDB и калибровки — в соответствующих
подкаталогах выбранного `Mera Files`. Это позволяет запускать RecorderLnx без
прав администратора после установки.
