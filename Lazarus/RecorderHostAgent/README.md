# RecorderHostAgent

Фоновый HTTP-агент для управления компьютером RecorderLnx. По умолчанию
слушает TCP `8766`; настройки находятся рядом с executable в
`RecorderHostAgent.ini`.

Для управления с другого компьютера входящий TCP `8766` должен быть разрешён
межсетевым экраном Linux. DEB-пакет автоматически добавляет правило, когда
обнаруживает активный `ufw` или `firewalld`.

Для управления с другого компьютера входящий TCP `8766` должен быть разрешён
межсетевым экраном Linux. DEB-пакет автоматически добавляет правило, когда
обнаруживает активный `ufw` или `firewalld`.

```ini
[agent]
listen=0.0.0.0
port=8766
recorder_path=C:\Mera Files\RecorderLnx\RecorderLnx.exe
allow_shutdown=0
api_token=
```

API:

- `GET /api/v1/status` — минимальная диагностика агента, без сетевого
  инвентаря, путей и данных, которые публикует сам RecorderLnx;
- `POST /api/v1/recorder/start` — запустить RecorderLnx;
- `POST /api/v1/system/shutdown` — завершить работу ОС. Работает только при
  `allow_shutdown=1`.

В Linux агент работает в пользовательской графической сессии и не получает
полных прав root. DEB устанавливает отдельный root-owned helper без параметров
и разрешает выбранному desktop-пользователю запускать через `sudo -n` только
этот helper. Агент проверяет код завершения helper-а: успешный HTTP-ответ больше
не выдаётся, если sudoers не настроен или системная команда отклонена.
Установщик включает `allow_shutdown=1` только после успешной установки и
проверки этого узкого разрешения; если пользователь не определён или sudoers
некорректен, настройка остаётся выключенной.

Если `api_token` непустой, запрос должен содержать
`Authorization: Bearer <token>`. Для рабочих сетей токен обязателен.

Если `recorder_path` отсутствует в конфигурации, агент ищет `RecorderLnx`
рядом со своим executable (`RecorderLnx.exe` в Windows).

В rcPanel `uCoordinatorHostAgentClient.StartHostAgentRequest` запускает запрос
в отдельном потоке и возвращает результат в UI через callback. WOL реализован
в `uCoordinatorWakeOnLan.SendWakeOnLan`.

Установка автозапуска:

- Windows (PowerShell администратора):
  `Deployment\install-windows.ps1` — копирует агент рядом с RecorderLnx и
  добавляет запуск при входе пользователя;
- Linux (root): `Deployment/install-linux.sh` — устанавливает user-systemd
  unit. Агент и запускаемый им GUI RecorderLnx работают от вошедшего
  пользователя, а не от root.
