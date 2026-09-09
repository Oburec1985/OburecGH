# Обнаружение RecorderLnx и RecorderCoordinator в локальной сети

RecorderLnx и RecorderCoordinator (rcPanel) автоматически находят друг друга
в одном широковещательном сегменте IPv4. UDP используется только для
обнаружения адреса; регистрация, heartbeat и команды после этого выполняются
через штатный HTTP API v1 Coordinator.

## Порты

| Транспорт | Порт | Получатель | Назначение |
| --- | ---: | --- | --- |
| UDP | `38765` | RecorderCoordinator | запросы и объявления RecorderLnx |
| UDP | `38766` | RecorderLnx | объявления и ответы RecorderCoordinator |
| TCP | `8765` по умолчанию | RecorderCoordinator | HTTP API управления |

HTTP-порт настраивается в Coordinator и передаётся в discovery-пакете. Поэтому
при смене TCP-порта фиксированные UDP-порты менять не требуется.

## Протокол discovery v1

Каждый пакет — UTF-8 JSON, отправленный на IPv4 broadcast
`255.255.255.255`. Максимальный принимаемый пакет — 2048 байт.

```json
{
  "magic": "RecorderLnxDiscovery",
  "version": 1,
  "kind": "coordinator.available",
  "instance_id": "coordinator",
  "display_name": "Recorder Coordinator",
  "http_port": 8765
}
```

Поддерживаемые значения `kind`:

| `kind` | Отправитель | Назначение |
| --- | --- | --- |
| `discover.coordinator` | RecorderLnx | запросить координатор |
| `recorder.available` | RecorderLnx | объявить экземпляр RecorderLnx |
| `coordinator.available` | Coordinator | объявить HTTP endpoint |

Пакеты с другим `magic`, другой версией или невалидным JSON игнорируются.
URL Coordinator строится из фактического IP отправителя и поля `http_port`;
адрес внутри пакета не принимается на доверии.

## Жизненный цикл

Discovery запускается и останавливается вместе с HTTP-сервисом Coordinator и
вместе с включённым клиентом Coordinator в RecorderLnx. Работа выполняется в
отдельном потоке и не блокирует интерфейс или сбор данных.

Раз в 3 секунды:

1. RecorderLnx отправляет `discover.coordinator` и `recorder.available` на UDP
   `38765`.
2. Coordinator отправляет `coordinator.available` на UDP `38766` и отдельно
   отвечает на `discover.coordinator`.
3. Coordinator добавляет найденный RecorderLnx в модель хостов в состоянии
   `discovered`; последующие HTTP hello/heartbeat уточняют его состояние.
4. RecorderLnx запоминает найденный HTTP URL. Рабочий адрес, явно заданный в
   конфигурации, не заменяется. Найденный адрес применяется только после
   неуспешной HTTP-проверки настроенного endpoint.

Если доступно несколько Coordinator, автоматический выбор не гарантирует
приоритет конкретного экземпляра. Для такой сети следует задать URL нужного
Coordinator вручную либо разделить широковещательные сегменты.

## Граница безопасности

Discovery не передаёт команды управления, токены, параметры записи и пути к
файлам. Он только сообщает идентификатор, отображаемое имя и HTTP-порт. Все
операции управления остаются в HTTP-контракте и подчиняются его настройкам
разрешения удалённого управления.

UDP broadcast не является механизмом аутентификации. Обнаруженный адрес нужно
считать подсказкой для подключения, а сеть — доверенным локальным сегментом.
При работе в недоверенной сети discovery следует блокировать брандмауэром и
использовать явно заданный endpoint.

## Брандмауэр и границы сети

На Windows разрешите входящий UDP для приложений в профилях Domain/Private:

- `RecorderCoordinator.exe`: UDP `38765`;
- `RecorderLnx.exe`: UDP `38766`.

Установщик RecorderLnx создаёт правило UDP `38766` автоматически только для
профилей Domain/Private. Для профиля Public требуется отдельное осознанное
правило либо смена типа доверенной локальной сети. Входящий TCP-порт HTTP API
Coordinator разрешается отдельно: discovery-правило его не открывает.

Пример для вручную установленного Coordinator (PowerShell от администратора):

```powershell
netsh advfirewall firewall add rule name="Mera rcPanel discovery" dir=in action=allow program="C:\path\to\RecorderCoordinator.exe" protocol=UDP localport=38765 profile=domain,private enable=yes
```

HTTP-сервис Coordinator должен слушать доступный из LAN интерфейс (обычно
`0.0.0.0`), иначе UDP-обнаружение сработает, но HTTP-соединение не установится.

Broadcast обычно не проходит через маршрутизаторы и между VLAN. Оба приложения
должны находиться в одном широковещательном сегменте; иначе задайте URL
Coordinator вручную. В Linux необходимо аналогично разрешить UDP-порты в
используемом `nftables`/`firewalld`/`ufw`.

## Отказоустойчивость и диагностика

Ошибка создания или привязки UDP-сокета отключает только автоматическое
обнаружение. RecorderLnx продолжает автономную работу и периодически проверяет
настроенный HTTP endpoint; Coordinator продолжает обслуживать HTTP, если его
TCP-сервис запущен.

Полезные строки журналов:

```text
Discovery listening on UDP/38765
Discovery listening on UDP/38766
Discovery recorder found: <name> <ip>
Discovery coordinator found: http://<ip>:<port>
Coordinator endpoint selected by discovery: http://<ip>:<port>
Discovery bind failed on UDP/<port>
Discovery invalid packet from <ip>: <error>
Discovery stopped
```

Журналы находятся рядом с executable: `RecorderCoordinator.log` для
Coordinator и `LogWindows.log`/`LogLinux.log` для RecorderLnx. Если приложения
не видят друг друга, сначала проверьте наличие строки `Discovery listening`,
профиль сети Windows, правила обоих UDP-портов и принадлежность ПК одному
broadcast-сегменту. Затем проверьте доступность HTTP-порта Coordinator.
