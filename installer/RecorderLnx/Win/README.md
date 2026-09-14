# RecorderLnx Windows installer

Скрипт `RecorderLnx.iss` предназначен для Inno Setup 7.

## Сборка

```powershell
.\build-installer.ps1
```

Скрипт сначала полностью пересобирает `RecorderLnx.lpi` и
`RecorderHostAgent.lpi`, затем создаёт:
После forced-build агент копируется рядом с `RecorderLnx.exe`,
контрольные суммы обеих копий сравниваются, и Inno Setup берёт
именно этот соседний файл.

`Output\RecorderLnx-Setup-0.1.9.exe`

Для автоматической установки каталог данных можно передать параметром:

```powershell
RecorderLnx-Setup-0.1.9.exe /VERYSILENT /MERAFILES="D:\Mera Files"
```

## Устанавливаемая структура

По умолчанию приложение устанавливается в:

`C:\Program Files (x86)\Mera\RecorderLnx`

Рядом с exe создаются:

- `RecorderHostAgent.exe` — фоновый агент управления компьютером;
- `RecorderHostAgent.ini` — сохраняемый между обновлениями конфиг агента;
- `plugins` — плагины;
- `bios` — прошивки модулей;
- `syscom` — дополнительные библиотеки;
- `RecorderLnx.paths.ini` — системные пути.

Изменяемые конфигурации размещаются в
`C:\Mera Files\RecorderLnx\config`, а SDB и калибровки — в соответствующих
подкаталогах выбранного `Mera Files`. Это позволяет запускать RecorderLnx без
прав администратора после установки.

## Фоновый агент

Инсталлятор добавляет `RecorderHostAgent.exe` в общесистемный автозапуск
Windows и запускает его сразу после установки. Агент слушает TCP 8766, для
которого создаётся правило брандмауэра в private/domain-профилях.

При обновлении и удалении останавливается только процесс
`RecorderHostAgent.exe`. Автозапуск и правило брандмауэра удаляются вместе с
программой. `RecorderHostAgent.ini` намеренно остаётся в каталоге установки,
чтобы не потерять `api_token`, разрешение выключения и локальные настройки.
