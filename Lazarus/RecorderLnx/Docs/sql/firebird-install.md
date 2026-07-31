# Firebird для SQL-модуля RecorderLnx

Основная СУБД первой версии — Firebird 5. Один адаптер поддерживает локальный
файл `.fdb` в выбранном каталоге и подключение к удалённому серверу.

## Установка в Windows

1. Открыть <https://firebirdsql.org/en/firebird-5-0/>.
2. Скачать `Firebird-5.0.4.1812-0-windows-x64.exe`.
3. Запустить установщик от администратора.
4. Выбрать `SuperServer`, Windows Service и порт `3050`.
5. Задать пароль `SYSDBA`.
6. Создать переменную `RECORDERLNX_SQLDB_PASSWORD` с этим паролем и
   перезапустить RecorderLnx.

Официальное руководство:
<https://www.firebirdsql.org/file/documentation/html/en/firebirddocs/qsg5/firebird-5-quickstartguide.html>.

В RecorderLnx нажать `SQL`. Для локальной базы оставить host пустым, выбрать
каталог и `recorderlnx.fdb`. Для удалённой базы указать host, порт `3050`, имя
базы и пользователя. Для доступа через Интернет применять VPN/защищённый
туннель, не публиковать порт Firebird напрямую.
