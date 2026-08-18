Firebird для RecorderLnx ставится отдельно от RecorderLnx.

Комплект папки:

- Firebird-*-linux-x64.tar.gz
- install-firebird-recorderlnx.sh
- check-firebird-recorderlnx.sh
- Install Firebird for RecorderLnx.desktop

Установка одной кнопкой:

1. Скопируйте всю папку на Linux ПК.
2. Откройте папку в файловом менеджере.
3. Запустите `Install Firebird for RecorderLnx.desktop`
   или командой `bash install-firebird-recorderlnx.sh`.
4. Введите пароль администратора, если система запросит sudo.

Что делает скрипт:

- ищет рядом архив `Firebird-*-linux-x64.tar.gz`;
- ставит зависимости через `apt-get`, если он доступен;
- распаковывает архив во временную папку;
- запускает `install.sh -silent`;
- включает и запускает `firebird.service`;
- создает `/etc/profile.d/recorderlnx-sqldb.sh` с переменной
  `RECORDERLNX_SQLDB_PASSWORD` для RecorderLnx.

Firebird в silent-режиме сам генерирует пароль SYSDBA и сохраняет его в:

`/opt/firebird/SYSDBA.password`

Проверка:

```bash
bash check-firebird-recorderlnx.sh
```

После установки нужно заново войти в систему или перезапустить RecorderLnx,
чтобы программа увидела `RECORDERLNX_SQLDB_PASSWORD`.

Лог установки:

`/tmp/recorderlnx-firebird-install.log`
