# VM Atra: установка Lazarus-пакетов для RecorderLnx

## Назначение

Повторяемая процедура установки Lazarus-пакетов RecorderLnx в Linux VM `Atra`, где параллельно проверяется работа `RecorderLnx` под Astra Linux.

## VM

- Каталог VM на Windows: `D:\works\VMMachins\Atra\`
- Файл VMX: `D:\works\VMMachins\Atra\Debian 12.x 64-bit_Astra.vmx`
- Тип: VMware Workstation.
- Гостевая ОС: Astra Linux / Debian 12 compatible.
- VMware Tools работают; `vmrun` guest operations доступны после входа с учетными данными гостевого пользователя.
- Shared folder Windows `D:\works` внутри VM смонтирован как `/mnt/win_share`.
- Локальная техническая учетка VM: пользователь `user`, пароль `11111111`.

Основной способ выполнения сборочных команд — SSH:

```text
ssh user@192.168.112.128
```

Также пользовательский стенд может быть доступен по имени:

```text
ssh user@linux
```

Пароль для обеих записей: `11111111`. Актуальный адрес при изменении DHCP можно узнать через
`vmrun getGuestIPAddress`; `runProgramInGuest` оставлен как резервный способ,
если SSH недоступен.

## Рабочий профиль Lazarus и dockable-интерфейс

Ярлык на рабочем столе запускает рабочую IDE с отдельным профилем:

```text
startlazarus-2.2.6 --pcp=/home/user/.lazarus_work
```

Настраивать пакеты и раскладку нужно именно в `/home/user/.lazarus_work`, а не
в `/home/user/.lazarus`: это две независимые конфигурации Lazarus.

Для включения dockable-окон используется макрос:

```text
/mnt/win_share/OburecGH/Lazarus/Tools/configure_lazarus_docking_linux.sh
```

Он создаёт резервную копию рабочего профиля, подключает штатные пакеты
`AnchorDocking` и `AnchorDockingDsgn`, пересобирает IDE и устраняет ложный
диалог о понижении версии каталога конфигурации. Запускать его нужно так:

```bash
bash /mnt/win_share/OburecGH/Lazarus/Tools/configure_lazarus_docking_linux.sh /home/user/.lazarus_work
```

Для восстановления одной командой на Windows см. [памятку и BAT-файл](lazarus_vm_docking.md).

## Команды VMware

Путь к `vmrun` на Windows:

```powershell
C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe
```

Запуск VM:

```powershell
& "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start "D:\works\VMMachins\Atra\Debian 12.x 64-bit_Astra.vmx" nogui
```

Проверка списка запущенных VM:

```powershell
& "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" list
```

Получение IP:

```powershell
& "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" getGuestIPAddress "D:\works\VMMachins\Atra\Debian 12.x 64-bit_Astra.vmx" -wait
```

Проверка VMware Tools:

```powershell
& "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" -T ws checkToolsState "D:\works\VMMachins\Atra\Debian 12.x 64-bit_Astra.vmx"
```

Запуск команды внутри VM выполняется через `runProgramInGuest` с гостевыми учетными данными.

Шаблон:

```powershell
& "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" -T ws -gu user -gp 11111111 runProgramInGuest "D:\works\VMMachins\Atra\Debian 12.x 64-bit_Astra.vmx" /bin/bash -lc "<linux_command>"
```

## Установка LzrObrPack

Скрипт в рабочем дереве:

```text
D:\works\OburecGH\Lazarus\Tools\install_lzrobrpack_linux.sh
```

Путь к нему внутри VM:

```text
/mnt/win_share/OburecGH/Lazarus/Tools/install_lzrobrpack_linux.sh
```

Запуск через `vmrun`:

```powershell
& "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" -T ws -gu user -gp 11111111 runProgramInGuest "D:\works\VMMachins\Atra\Debian 12.x 64-bit_Astra.vmx" /bin/bash /mnt/win_share/OburecGH/Lazarus/Tools/install_lzrobrpack_linux.sh
```

Скрипт делает:

- находит shared folder `/mnt/win_share`, `/mnt/hgfs/works` или `/home/user/win_share`;
- собирает пакет `SharedUtils/components/chart_lzr/lzrObrPack.lpk`;
- регистрирует пакет через `lazbuild --add-package-link`;
- добавляет пакет в installed packages через `lazbuild --add-package ... --build-ide=`;
- собирает демо `OGlChartLaz/Test_component/project1.lpi`;
- собирает `RecorderLnx/RecorderLnx.lpi`.

## Успешный результат

После успешной установки:

- пользовательская IDE находится в `/home/user/.lazarus/bin/lazarus`;
- `/home/user/.lazarus/packagefiles.xml` содержит `LzrObrPack`;
- `/home/user/.lazarus/staticpackages.inc` содержит `lzrObrPack`;
- `/home/user/.lazarus/idemake.cfg` содержит путь `SharedUtils/components/chart_lzr/lib/x86_64-linux`;
- `RecorderLnx` собирается в `/mnt/win_share/OburecGH/Lazarus/RecorderLnx/lib/x86_64-linux/RecorderLnx`.

Проверка регистрации пакета:

```powershell
& "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" -T ws -gu user -gp 11111111 runProgramInGuest "D:\works\VMMachins\Atra\Debian 12.x 64-bit_Astra.vmx" /bin/bash -lc "grep -R 'LzrObrPack\|lzrObrPack' /home/user/.lazarus/packagefiles.xml /home/user/.lazarus/staticpackages.inc"
```

## Важные замечания

- SSH в VM может быть закрыт; использовать VMware Tools через `vmrun`.
- `captureScreen` и другие guest operations тоже требуют гостевого логина.
- В Linux файловая система чувствительна к регистру. В ходе установки была исправлена ошибка `uBaseObjLaz`: uses/UnitName должны совпадать с именем файла `uBaseObjLaz.pas`.
- Если `lazbuild` сообщает, что системные каталоги `/usr/lib/lazarus/...` не writable, это нормально: Lazarus складывает пользовательские сборочные артефакты в `/home/user/.lazarus/lib/...` и пересобирает IDE в `/home/user/.lazarus/bin/lazarus`.
- Контрольная сборка проекта выполняется командой
  `lazbuild --pcp=/home/user/.lazarus_work -B RecorderLnx.lpi` из каталога
  `/mnt/win_share/OburecGH/Lazarus/RecorderLnx`.
- Маркер правила: `RLNX_LINUX_FIRMWARE_RESOURCE_FALLBACK_2026_07_21`.
  Windows RC-ресурсы с firmware нельзя делать обязательными для Linux-сборки:
  под Windows BIOS MC-201 встраивается из `mcbus.rc`, под Linux загрузчик обязан
  иметь проверяемый файловый fallback относительно каталога приложения.
  Проверка: полная Linux-сборка завершается с кодом 0, полученный файл является
  ELF x86-64, а путь fallback BIOS существует от `lib/x86_64-linux/RecorderLnx`.

## Relationships

- [План работ RecorderLnx](../../cach/plan.md)
- [OpenGLChartLazarus](../../../../../AGrav/20_Проекты/Разработка_Delphi/OpenGLChartLazarus/Summary.md)


Bat для восстановления докинга в Linux
D:\works\OburecGH\Lazarus\Tools\Restore_Lazarus_Docking_VM.bat - запускать из windows

## Сеть VM для Ethernet-приборов

VM использует `ens33` через VMware NAT (`VMnet8`). Постоянная конфигурация
находится в `/etc/network/interfaces.d/ens33`, эталон хранится в
`Lazarus/Tools/vm/interfaces.d/ens33`. Интерфейс обязан автоматически получать
DHCP-адрес; состояние `ens33 DOWN` означает, что RecorderLnx не увидит ни один
сетевой прибор.

Проверка перед аппаратным тестом:

```bash
ip -brief address show ens33
ip route get 192.169.12.87
timeout 3 bash -c '</dev/tcp/192.169.12.87/4000'
```

Проверенный профиль: `ens33=192.168.112.128/24`, маршрут к MC-032 идёт через
`192.168.112.2`; `192.169.12.87:4000` доступен из гостя.
