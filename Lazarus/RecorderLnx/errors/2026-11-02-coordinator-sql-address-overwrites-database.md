# Смена адреса Firebird подменяла путь базы

На сервере пользователь выбрал /mnt/sda1/base/firebird/recorderlnx.fdb.
После команды RCPanel config.sql_database.set поле Database становилось
/var/opt/mera/SQLdb/recorderlnx.fdb, хотя RootDirectory оставался /mnt/sda1/base.

Причина: панель отправляла собственные database/username/password, а Recorder
безусловно присваивал их конфигурации. Сохранённая очередь также переносила
путь Database вместе с адресом.

Контракт исправления: команда смены сетевого сервера изменяет Host и Port,
сохраняя локальный путь базы, RootDirectory, учётные данные, TLS и настройки
записи. LocalDatabase и RemoteDatabase хранятся отдельно; удалённый путь связан
с RemoteDatabaseHost. Пустой хост, localhost и собственный IP выбирают локальный
путь. Для удалённого сервера панель получает sql_local_database из его HTTP
heartbeat и передаёт server_database. Эта величина меняет только удалённый путь.
Старое поле database игнорируется. Неизвестный путь другого сервера не подменяется
путём панели или предыдущего сервера; такая настройка выдаёт понятную ошибку.

На сервере восстановлена одна строка Database из app.ini.before-kip3-20261102;
создана резервная копия app.ini.before-database-restore-20261102. Перед правкой
Recorder штатно закрыт в состоянии Stop. Содержимое файла БД не изменялось.

Проверка и развёртывание фиксируются в cach/notes_last_state.md.
