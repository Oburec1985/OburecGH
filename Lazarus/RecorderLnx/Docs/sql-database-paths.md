# Локальный и удалённый путь Firebird

LocalDatabase — путь базы на этом ПК. RemoteDatabase — путь базы на выбранном
удалённом сервере; он связан с RemoteDatabaseHost. RootDirectory остаётся
локальной настройкой хранения и не меняется командой RCPanel.

Пустой хост, localhost, loopback и собственный IPv4 выбирают LocalDatabase.
Другой адрес выбирает RemoteDatabase именно этого адреса. Диалог сохраняет
черновики при переключении; для неизвестного сервера не подставляет стандартный
путь или путь другого сервера.

Команда config.sql_database.set передаёт адрес и порт. Панель добавляет
server_database только из sql_local_database, полученного в HTTP heartbeat
Recorder выбранного сервера. Локальный сервер игнорирует этот удалённый путь;
удалённые клиенты сохраняют его отдельно от LocalDatabase. Поля старых команд
database/username/password не используются для подмены локальной настройки.

Совместимость: INI продолжает содержать Database как текущий активный путь;
новые LocalDatabase/RemoteDatabase/RemoteDatabaseHost сохраняют раздельные
настройки. Старый INI мигрирует при чтении без удаления исходного пути.

Проверки: RecorderSqlRemoteAddressTest, CoordinatorSqlServerPathTest,
CoordinatorSqlQueueTest и SqlDbPathDialogProbe (настоящий LCL-диалог).
