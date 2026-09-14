Дополнительные компоненты RecorderLnx для Linux
================================================

Установщик предлагает два независимых компонента:

- Firebird — локальный SQL-сервер для событий записи;
- rcPanel — графическая панель управления RecorderLnx. Внутреннее имя
  исполняемого файла пока остается RecorderCoordinator.

Подготовка комплекта на Windows
-------------------------------

Для обычного обновления перед копированием на флешку запустите двойным щелчком:

  update-offline-installer.bat

BAT проверит актуальность Linux-сборки rcPanel, обновит её исполняемый файл,
иконку и контрольные суммы в payload, затем проверит полноту переносимой папки.
Этот комплект не собирает и не проверяет RecorderLnx или RecorderHostAgent:
для них используется отдельный DEB-установщик из `installer/RecorderLnx/linux`.
Если ELF rcPanel старее его исходников, BAT остановится с требованием сначала
собрать RecorderCoordinator на Linux. После сообщения READY копируйте на флешку
всю эту папку целиком. Для запуска без Pause используйте
`update-offline-installer.bat --no-pause`.

После сборки Linux-версии RecorderCoordinator выполните из этой папки:

  powershell -ExecutionPolicy Bypass -File .\prepare-installer.ps1

Скрипт копирует
Lazarus/RecorderCoordinator/lib/x86_64-linux/RecorderCoordinator в
payload/RecorderCoordinator и создает payload/RecorderCoordinator.sha256.

Установка
---------

1. Скопируйте всю папку на Linux ПК.
2. Запустите ярлык «Install RecorderLnx components» или команду:

     bash install-firebird-recorderlnx.sh

   При запуске без параметров Zenity покажет выбор Firebird и rcPanel.
3. Введите пароль администратора, если sudo его запросит.

Установка без графического окна:

  bash install-firebird-recorderlnx.sh --firebird --no-gui
  bash install-firebird-recorderlnx.sh --rcpanel --no-gui
  bash install-firebird-recorderlnx.sh --all --no-gui

Firebird
--------

Рядом должен лежать Firebird-*-linux-x64.tar.gz. Локальные зависимости Debian
или ОС «Орел» можно положить в deps/*.deb. По умолчанию apt-репозитории не
используются. Явно разрешить online-зависимости можно так:

  RECORDERLNX_FIREBIRD_ONLINE_DEPS=1 bash install-firebird-recorderlnx.sh --firebird

Установщик создает /var/opt/mera/SQLdb, совместимый старый каталог
/var/opt/mera/RecorderLnx/sqldb и устанавливает реальный пароль Firebird
SYSDBA равным 123. Старый пароль ищется в SYSDBA.password и legacy sql-db.ini;
после изменения обязательно выполняется реальный вход через gsec. Пароль не
помещается в общий profile и проектные конфиги.

Для удалённых клиентов установщик создаёт серверный alias `recorderlnx.fdb`.
Физический путь `/var/opt/mera/SQLdb/recorderlnx.fdb` остаётся локальной
настройкой сервера и не передаётся клиентам.

rcPanel
-------

Программа устанавливается в /opt/mera/RecorderCoordinator, а команда запуска —
/usr/bin/rcpanel. Создаются общий ярлык /usr/share/applications/rcpanel.desktop,
конфигурация и лог рядом с программой, а также архив
/var/opt/mera/RecorderCoordinator/archive. Конфигурация, лог и архив передаются
пользователю, от имени которого был вызван sudo. Системная служба для rcPanel не
создается: это обычное графическое приложение.

Проверка
--------

  bash check-firebird-recorderlnx.sh --firebird
  bash check-firebird-recorderlnx.sh --rcpanel
  bash check-firebird-recorderlnx.sh --all

Без параметров проверяются оба компонента. Проверку прав записи rcPanel нужно
запускать от того же обычного пользователя, который будет запускать панель.

Лог установки: /tmp/recorderlnx-firebird-install.log
