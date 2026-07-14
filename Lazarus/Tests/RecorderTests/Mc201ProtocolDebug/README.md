# Отладка протокола MC-201

Автономный консольный и GUI-пример для проверки протокола MC-031/MC-032 +
MC-201.

Откуда взята информация:
- `D:\works\windev-v3.9\examples\mebius.daq\tests\medaq_mc_test\src\medaq_mc_test.cpp`
- `D:\works\windev-v3.9\mtcEthernet81\Mc031ethernetifc.cpp`
- `D:\works\windev-v3.9\mtc\CCDEVAPI.CPP`
- `D:\works\windev-v3.9\mtc\Ccdevice.h`
- `D:\works\windev-v3.9\mtc\Ccdevice.cpp`
- `D:\works\windev-v3.9\mtc\cc81ifc.cpp`
- `D:\works\windev-v3.9\mtc\Mc201.cpp`
- `D:\works\windev-v3.9\mtc\Module.cpp`

Тест не использует рабочие классы устройств RecorderLnx. Он открывает старый
MDP TCP-поток MC-031/032, читает `CMD_REPLY` контроллера и затем сканирует flash
слотов модулей:

- смещение flash `0`: тип модуля;
- смещение flash `1`: код версии/признак MC-201;
- смещения flash `61/62`: серийный номер.

Сборка и запуск GUI по умолчанию:

```powershell
C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\Mc201ProtocolDebug.lpi
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe
```

Ожидаемый живой стенд: четырехслотовый контроллер с четырьмя модулями MC-201:
слот 1 `01462`, слот 2 `01465`, слот 3 `01464`, слот 4 `01463`.

Подробные заметки по стенду лежат здесь:
`D:\works\OburecGH\Lazarus\RecorderLnx\Docs\devices\mc\mc201.md`.

## Бинарные ресурсы устройств

BIOS MC-201 скопирован в проект и вкомпилирован в exe:

```text
resources/devices/mc201/mc_201a.bio
resources/mc201_protocol_debug.rc
src/uMc201FirmwareResources.pas
```

Ресурс называется `MC201A_BIO`, тип ресурса `MC201BIO`. Тип сделан строковым,
а не платформенным `RT_RCDATA`, чтобы один и тот же код читался через
`TResourceStream` и на Windows, и на Linux.

Проверка без подключения к прибору:

```powershell
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe --cli --check-resources
```

Ожидаемая строка:

```text
RESOURCE MC201A_BIO OK source=resource:MC201A_BIO bytes=22040
```

Для будущих MIC-185 и других устройств бинарные файлы надо класть по той же
схеме: `resources/devices/<device>/...`, добавлять строку в `.rc`, добавлять
константу имени/типа ресурса в модуль загрузки и читать сначала из ресурса,
оставляя файловый путь только как отладочный fallback.

CLI-режим использует тот же проект и тот же exe:

```powershell
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe --cli --host=192.169.12.87 --port=4000 --slots=4
```

Регрессионный тест подключения GUI без нажатия кнопки:

```powershell
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe --gui-connect-on-create-test
```

Этот режим создает форму, вызывает тот же код подключения, что и кнопка
`Connect`, печатает `RESULT Mc201GuiConnectOnCreate ...` и выходит без
`Application.Run`.

`TMc032Device` поддерживает:
- `Search`: проверяет заданный host/port через `TEST_LOAD`.
- `TestConnection`: отправляет `CMD_TEST_LOAD`.
- `SearchModules`: ищет непустые слоты по flash модулей.
- `Connect` / `Disconnect`: открывает и закрывает MDP TCP-поток.
- `Reset`: отправляет контроллеру `CMD_RESET`.
- `Config`: сохраняет `TMc032Config`, применяет timeout чтения и отправляет
  последовательность программирования скана MC-201 по образцу Recorder:
  `CMD_RESETSCANMAIN`, `CMD_CONFIGSCANMAIN(scale=1, period=640)` для базы
  времени CC81 Ethernet, IDMA-дескрипторы модулей, цепочки каналов модулей,
  `GET_FINAL_FLAG_CC`, `CMD_APPENDSCANMAIN`, `CMD_ADDCHANNELMODULE`,
  `CMD_SCAN_SET_CHANS`, список стартовых триггеров ADC и
  `CMD_START_TRIGGERSTARTADC`.
- `Play` / `Stop`: отправляет `CMD_STARTSCANMAIN` / `CMD_STOPSCANMAIN` и
  запускает поток чтения. Сырые пакеты передаются через `TMc032DataCallback`;
  GUI callback рисует простую осциллограмму по сырым словам.

Проверка приемки:

```powershell
D:\works\OburecGH\Lazarus\Tests\RecorderTests\Mc201ProtocolDebug\lib\Mc201ProtocolDebug.exe --cli --acceptance-ms=5000 --update-ms=200 --timeout-ms=1200 --connect-attempts=3 --connect-retry-ms=1000 --slots=4
```

CLI собирает сырые Ethernet-кадры в блоки обновления по 200 мс. На текущем
стенде при `57600 Hz` ожидаемый результат за 5 секунд — `25` блоков обновления;
типичные размеры сырых кадров: около `266`, `532` и `798` слов.

## Заметки по реализации

В исходниках оставлены комментарии вокруг протокольных мест, найденных живой
отладкой:

- `uMc201ProtocolTypes.pas`: настройки живого стенда, отличие размера MDP-пакета
  от размера аргументов команды и предел IDMA-куска `26` слов.
- `uMc201LegacyMdpClient.pas`: GUI-подключение без исключения, выравнивание
  адресов PM при IDMA и быстрый путь использования уже загруженного BIOS MC-201.
- `uMc032Device.pas`: порядок программирования скана как в оригинальном Recorder
  и один повтор `Config` через reset/reconnect после отказа.
- `Mc201ProtocolDebug.lpr`: режим `--gui-connect-on-create-test`, вызывающий тот
  же код формы, что и кнопка GUI.

Не заменять IDMA-кусок `26` слов на максимум сырого пакета. Сырой MDP-пакет
может переносить больше данных, но вызовы команд в оригинальном
`mdpEthernet81` ограничены 32 словами аргументов. Проверка на стенде показала:
кусок `1016` слов уходит в timeout, кусок `27` слов сбивает следующий PM-адрес,
кусок `26` слов работает.

Для скорости `Config` сначала проверяет, не загружен ли BIOS модуля уже:
читается `VAR_TMODE`, ожидается `A5A5`, затем выполняется легкий `INIT` через
модульный BIOS. Если проверка проходит, тяжелая заливка `.bio` пропускается.
Если проверка не проходит, выполняется полная загрузка BIOS. Успешные слоты
кешируются только внутри текущего TCP-клиента. Полная загрузка берет данные из
встроенного ресурса `MC201A_BIO`; путь к файлу оригинального Recorder остается
только fallback для отладки.
