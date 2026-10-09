# RecorderLnx Windows installer

Скрипт `RecorderLnx.iss` предназначен для Inno Setup 7.

Все входные файлы Inno Setup берёт только из локального staging-каталога
`files`. Дерево в нём повторяет назначение файлов:

- `files\app` — содержимое `{app}`: EXE, DLL, плагины, ресурсы, BIOS и MX-248;
- `files\mera-files` — начальная конфигурация общего каталога Mera Files;
- `files\redist` — устанавливаемые системные redistributable;
- `files\setup` — ресурсы самого установщика.

## Сборка

```powershell
.\build-installer.ps1
```

Полный скрипт сначала компилирует проекты и справку, затем вызывает
`collect-files.bat`, проверяет bridge уже в `files` и только после этого
запускает Inno Setup. Если сборки уже готовы, staging можно обновить отдельно:

```bat
collect-files.bat "C:\Program Files (x86)\Mera\Recorder" ^
  "C:\path\to\VC_redist.x86.exe"
```

Батник каждый раз полностью пересоздаёт `files`, поэтому устаревшие DLL и
ресурсы не остаются от предыдущей сборки. Запускать `RecorderLnx.iss` напрямую
следует только после успешного выполнения этого батника.

Для MX-248 сборка проверяет и включает x86 DevAPI-комплект. Другой каталог
можно передать явно:

```powershell
.\build-installer.ps1 `
  -VendorDevApiDir 'D:\MeraRuntime\Recorder' `
  -VcRedistX86Path 'D:\Redist\VC_redist.x86.exe'
```

Обязательные файлы: `DevAPI.dll`, `MICPXI.dll`, `mx224v14.dll`, `MTC.dll`,
`MDProtocol.dll`, `Comm.dll`, `GaugeCmn_rce.dll`, `BasePP.dll`, `FTD2XX.dll`,
`wd_utils.dll`. Дополнительно включается официальный VC++ 2015–2022 x86
redistributable; при установке он запускается тихо и идемпотентно. Скрипт
проверяет PE machine `0x014C` у каждого файла и прекращает сборку при неполном
или неверном комплекте. Канонический
контракт драйвера и карта исходников находятся в
`Lazarus/RecorderLnx/Device/PXI/MX248/Docs/README.md`.

Скрипт сначала полностью пересобирает `RecorderLnx.lpi` и
`RecorderHostAgent.lpi`. Проект агента своим `Target/Filename` выводит EXE
непосредственно рядом с `RecorderLnx.exe`; сборщик проверяет наличие этого
файла и переносит его в `files\app`. Затем создаётся:

`Output\RecorderLnx-Setup-<version>.exe`

Для автоматической установки каталог данных можно передать параметром:

```powershell
RecorderLnx-Setup-<version>.exe /VERYSILENT /MERAFILES="D:\Mera Files"
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
- `mx248\vendor` — изолированный x86 DevAPI-комплект для MX-248 bridge;
- `mx248\vendor\PxiMx248Bridge.exe` — on-demand Win32 bridge; RecorderLnx
  запускает его через локальные stdin/stdout pipes, без автозапуска и firewall;
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
