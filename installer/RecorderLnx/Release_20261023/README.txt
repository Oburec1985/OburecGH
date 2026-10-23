Назначение:
- RecorderLnx — сбор и просмотр данных.
- RCPanel — удалённое управление RecorderLnx.
- Firebird — база данных событий RecorderLnx и записи мониторинговых трендов.
- LinMng (LinuxSetupManager) — настройка Linux: имени компьютера, Wake-on-LAN и сетевых папок. Устанавливается вместе с RecorderLnx из DEB-пакета; ярлык «Настройка Linux» появляется в меню приложений.

Windows
RecorderLnx — запустите файл:
windows\RecorderLnx\RecorderLnx-Setup-0.1.190.exe
Отдельного установщика RCPanel для Windows в комплекте нет.

Linux
- RecorderLnx — откройте файл в графическом установщике пакетов: linux\RecorderLnx\recorderlnx_0.1.190_amd64.deb
- Firebird — локальный SQL-сервер для событий записи RecorderLnx. Для установки Firebird и RCPanel
запустите установщик дополнительных компонентов: linux\RecorderLnx\Install Firebird for RecorderLnx.desktop
 В окне по умолчанию выбраны Firebird и RCPanel. Оставьте оба пункта отмеченными,
чтобы установить их вместе. NTP-сервер — отдельный необязательный компонент.
