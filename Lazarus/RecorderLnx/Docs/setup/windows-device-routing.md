# Маршрутизация приборов через выбранный Ethernet-интерфейс

Для прямого соединения с приборами маршрут должен быть привязан к физическому
адаптеру, а не к текущему IP этого адаптера, записанному как шлюз. Windows
хранит такую привязку по `ifIndex`, поэтому после переустановки адаптера маршрут
нужно обновить по его имени.

Скрипт `Tools/configure-windows-device-routes.ps1`:

- находит актуальный `ifIndex` по имени `Ethernet 2`;
- обеспечивает локальные адреса `192.168.3.65/20` и `192.169.12.99/24`;
- создаёт on-link маршруты через найденный интерфейс с `NextHop 0.0.0.0`;
- не меняет default route и метрики Ethernet/Wi-Fi;
- опционально ставит задачу запуска от `SYSTEM` при старте Windows.

Запускать PowerShell от имени администратора:

```powershell
cd D:\works\OburecGH\Lazarus\RecorderLnx
.\Tools\configure-windows-device-routes.ps1 -InstallStartupTask
```

Для другого имени адаптера:

```powershell
.\Tools\configure-windows-device-routes.ps1 `
  -InterfaceAlias 'Ethernet 3' `
  -InstallStartupTask
```

Маршрут `/32` до `192.169.12.87` специфичнее VPN-маршрута
`192.169.0.0/16`, поэтому трафик прибора идёт по кабелю независимо от метрик.
Но маршрута недостаточно без обратного пути: у Ethernet должен быть локальный
адрес из сети прибора. Для этого скрипт добавляет `192.169.12.99/24` с
`SkipAsSource=False`.

Проверка:

```powershell
Find-NetRoute -RemoteIPAddress 192.169.12.87
ping -S 192.169.12.99 192.169.12.87
Test-NetConnection 192.169.12.87 -Port 4000 -InformationLevel Detailed
arp -a 192.169.12.87
```

Ожидаются `InterfaceAlias = Ethernet 2`, источник `192.169.12.99`, успешный
TCP/4000 и MAC прибора в ARP-таблице этого интерфейса. В Recorder после
обновления списка нужно выбирать `Ethernet 2 [192.169.12.99]`; сохранённый
старый APIPA-адрес вида `169.254.x.x` для TCP-bind непригоден.

Wi-Fi остаётся интернет-маршрутом, поскольку скрипт не создаёт default gateway
на Ethernet и не меняет метрики интерфейсов.
