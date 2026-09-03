Firebird для RecorderLnx ставится отдельно от RecorderLnx.

Комплект папки:

- Firebird-*-linux-x64.tar.gz
- install-firebird-recorderlnx.sh
- check-firebird-recorderlnx.sh
- Install Firebird for RecorderLnx.desktop
- deps\*.deb (необязательно, локальные зависимости Debian/Орел без интернета)

Установка с флешки без интернета:

1. Скопируйте всю папку на флешку или сразу на Linux ПК.
2. Если на целевом ПК нет интернета, положите недостающие пакеты `.deb`
   в подпапку `deps`.
   Скрипт сам выполнит `dpkg -i deps/*.deb`.
   Репозитории apt по умолчанию не используются.
3. Откройте папку в файловом менеджере.
4. Запустите `Install Firebird for RecorderLnx.desktop`
   или командой `bash install-firebird-recorderlnx.sh`.
5. Введите пароль администратора, если система запросит sudo.

Важно:

- По умолчанию установка полностью offline и не делает `apt-get update`.
- Если специально нужна online-установка зависимостей через apt, запустите:

```bash
sudo RECORDERLNX_FIREBIRD_ONLINE_DEPS=1 bash install-firebird-recorderlnx.sh
```

Что делает скрипт:

- ищет рядом архив `Firebird-*-linux-x64.tar.gz`;
- ставит локальные зависимости из `deps/*.deb`, если они есть;
- не использует apt-репозитории без явного
  `RECORDERLNX_FIREBIRD_ONLINE_DEPS=1`;
- распаковывает архив во временную папку;
- запускает `install.sh -silent`;
- включает и запускает `firebird.service`;
- создает системный каталог Mera Files для SQL БД:
  `/var/opt/mera/SQLdb`;
- назначает владельцем этого каталога пользователя Firebird
  (`firebird`/`firebirdsql`, если такой пользователь есть);
- создает совместимый старый каталог `/var/opt/mera/RecorderLnx/sqldb`;
- создает `/etc/profile.d/recorderlnx-sqldb.sh` только с путем
  `RECORDERLNX_SQLDB_ROOT=/var/opt/mera/SQLdb`;
- сохраняет пароль в конфигурации RecorderLnx с правами `0600`.

Для локального Firebird не используйте `/home/user/Mera Files/SQLdb` как
каталог файла БД: сервер Firebird работает отдельным пользователем и часто не
имеет права прохода в домашний каталог пользователя. Используйте системный
Mera Files: `/var/opt/mera/SQLdb`.

Firebird в silent-режиме сам генерирует пароль SYSDBA и сохраняет его в:

`/opt/firebird/SYSDBA.password`

Установщик переносит этот пароль в проектный `sql-db.ini`, если RecorderLnx уже
установлен и защищает файл правами `0600`. Пусковой файл
`/usr/bin/recorderlnx` загружает из `/etc/profile.d/recorderlnx-sqldb.sh`
только путь к каталогу SQLdb; пароль в общем profile не хранится.

Проверка:

```bash
bash check-firebird-recorderlnx.sh
```

Если в проверке есть строки `not found`, нужно добавить соответствующие
Debian/Орел `.deb` пакеты в `deps` и повторить установку.

После установки перезапустите RecorderLnx. Повторный вход в систему для запуска
через штатный ярлык больше не требуется.

Лог установки:

`/tmp/recorderlnx-firebird-install.log`
