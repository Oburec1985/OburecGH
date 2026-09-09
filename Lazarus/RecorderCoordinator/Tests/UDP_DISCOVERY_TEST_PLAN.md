# UDP discovery: проверочный сценарий

Скрипт `Tools/Test-UdpDiscovery.ps1` проверяет прохождение UDP-запроса и
ответа отдельно от RecorderLnx/rcPanel. Его magic, JSON и порт являются
диагностическими и не задают production-контракт.

## Один Windows-ПК

В первом терминале:

```powershell
powershell -ExecutionPolicy Bypass -File .\Tools\Test-UdpDiscovery.ps1 `
  -Mode Responder -BindAddress 0.0.0.0
```

Во втором терминале:

```powershell
powershell -ExecutionPolicy Bypass -File .\Tools\Test-UdpDiscovery.ps1 `
  -Mode Discover -BindAddress 0.0.0.0 -Targets 127.0.0.1
```

Критерий: responder печатает `RX` и `TX`, discover — `FOUND` и
`RESULT passed`. Loopback выбран намеренно: несколько процессов, слушающих один
broadcast-порт на Windows, не гарантированно получают по копии одной дейтаграммы.

## Два ПК в одной LAN

Узнать адрес и prefix интерфейса:

```powershell
Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object AddressState -eq Preferred |
  Format-Table InterfaceAlias,IPAddress,PrefixLength
```

На ПК A запустить responder с IP нужного интерфейса. На ПК B запустить discover
с IP своего интерфейса и directed broadcast подсети, например для
`192.168.9.0/24` это `192.168.9.255`:

```powershell
powershell -ExecutionPolicy Bypass -File .\Tools\Test-UdpDiscovery.ps1 `
  -Mode Responder -BindAddress 192.168.9.10

powershell -ExecutionPolicy Bypass -File .\Tools\Test-UdpDiscovery.ps1 `
  -Mode Discover -BindAddress 192.168.9.20 -Targets 192.168.9.255
```

Критерий: ответ приходит с адреса ПК A. Проверить в обоих направлениях, поменяв
роли ПК. Для нескольких NIC повторить отдельно для каждой пары интерфейсов;
отправка только на `255.255.255.255` не считается достаточной проверкой.

## Firewall и занятый порт

Проверка процесса, занявшего порт:

```powershell
Get-NetUDPEndpoint -LocalPort 37651 |
  Format-Table LocalAddress,LocalPort,OwningProcess
```

Если loopback работает, а LAN нет, временно разрешить входящий UDP только для
EXE или тестового порта в профиле Private/Domain и повторить тест. Постоянное
правило установщика должно быть привязано к исполняемому файлу, а не открывать
порт для любой программы. Проверить, что сеть Windows не имеет профиль Public
без соответствующего разрешения.

## Критерии production discovery

- listener привязан к `0.0.0.0:<port>` либо создаётся по listener на каждый NIC;
- sender включает `SO_BROADCAST`, использует ephemeral source port и отправляет
  limited плюс directed broadcast каждого подходящего IPv4-интерфейса;
- responder отвечает unicast на фактический source endpoint запроса;
- в ответе есть версия протокола, тип сервиса, устойчивый instance ID, HTTP
  endpoint и имя хоста; адрес endpoint не берётся слепо из недоверенного JSON;
- дубликаты limited/directed broadcast сводятся по `(service, instance_id)`;
- собственный instance ID исключается, неизвестные версии и malformed JSON
  журналируются и игнорируются без исключения;
- discovery не блокирует GUI, останавливается с конечным timeout и корректно
  освобождает socket;
- установленный firewall допускает входящий запрос и unicast-ответ для
  RecorderLnx и rcPanel на Private/Domain сетях.
