# RecorderCoordinator

Утилита управления RecorderLnx и файловыми хранилищами. Один executable
работает как GUI, CLI или постоянный HTTP-сервис.

## Запуск

```text
RecorderCoordinator.exe
RecorderCoordinator.exe --serve --listen=0.0.0.0 --port=8765
RecorderCoordinator.exe --cli --status
RecorderCoordinator.exe --cli --list-hosts
RecorderCoordinator.exe --cli --command=start --host=<instance-id>
```

Настройки сохраняются рядом с executable в `RecorderCoordinator.ini`. Для SMB
на Windows допустим UNC-путь, на Linux — смонтированный CIFS-каталог. Пароли в
INI не сохраняются. SFTP предусмотрен моделью конфигурации, но транспортный
адаптер пока не подключён.

## HTTP API v1

| Метод | Endpoint | Назначение |
| --- | --- | --- |
| GET | `/api/v1/status` | Состояние сервиса |
| GET | `/api/v1/hosts` | Список RecorderLnx |
| POST | `/api/v1/clients/hello` | Регистрация экземпляра |
| POST | `/api/v1/clients/heartbeat` | Состояние и путь текущего замера |
| POST | `/api/v1/events` | Старт/изменение события записи |
| GET | `/api/v1/events` | События записи |
| POST | `/api/v1/commands` | Поставить команду хосту |
| GET | `/api/v1/commands/next?instance_id=...` | Long-poll/poll команды |
| POST | `/api/v1/commands/result` | Результат команды |
| GET | `/api/v1/recordings/current?instance_id=...` | Путь текущего замера |

Ожидаемые ошибки возвращаются JSON-кодом `result_code`; HTTP 400 используется
для невалидного JSON, HTTP 404 — для неизвестного endpoint.

## Автоматическое обнаружение в локальной сети

Coordinator/rcPanel и RecorderLnx обнаруживают друг друга через UDP broadcast,
после чего продолжают работу через штатный HTTP API. Coordinator принимает
discovery на UDP `38765`, RecorderLnx — на UDP `38766`; HTTP остаётся на TCP
`8765` (либо на порту из настройки Coordinator). Адрес в UDP-пакете не
доверяется: URL собирается из фактического IP отправителя и объявленного порта.

Полное описание протокола v1, жизненного цикла, диагностики и поведения при
сбоях: [LAN discovery](../RecorderLnx/Docs/setup/lan-discovery.md).

В Windows Firewall для частных и доменных сетей должны быть разрешены входящие
подключения к соответствующим приложениям: UDP `38765` для rcPanel и UDP
`38766` для RecorderLnx. Для вручную запускаемой Windows-сборки rcPanel правило
можно создать от администратора:

```powershell
netsh advfirewall firewall add rule name="Mera rcPanel discovery" dir=in action=allow program="C:\path\to\RecorderCoordinator.exe" protocol=UDP localport=38765 profile=domain,private enable=yes
```
