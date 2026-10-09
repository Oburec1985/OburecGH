# PXI MX-248 в RecorderLnx

> Каноническая документация нового драйвера. Точка входа проекта:
> [RecorderLnx device docs](../../../Docs/devices/README.md).

## Статус

На 2026-10-09 реализован и программно проверен полный Windows software path:

- типизированная конфигурация MX-248;
- транзакционные строковые `GetProperties`, `CalcProperties`, `SetProperties`;
- явный lifecycle, Win64 IPC transport и x86 DevAPI bridge;
- DevAPI discovery/connect/configure/start/stop/read/disconnect;
- автопоиск MX-248 в общем инспекторе устройств и предложение привязки
  вручную созданного узла в диалоге MX-248;
- datasource с восемью тегами, persistence и settings UI;
- регистрация production units в инспекторе проекта Lazarus;
- deterministic tests и installer build без оборудования.

Драйвер подключён к runtime RecorderLnx, но остаётся `software-ready`, а не
`hardware-accepted`: реальный MX-248 в этой итерации не сканировался и поток
с физического модуля не сравнивался с оригинальным Recorder.

## Принятое решение

На Windows используется обёртка над штатным Mera `DevAPI`. Она не переносит
в Lazarus внутренний MFC/C++ код `MICPXI` и `mx224v14`: vendor DLL остаются
владельцами PXI-шины, поиска модулей, аппаратного программирования и DMA/scan.

Установленные DLL имеют архитектуру x86:

- `C:\Program Files (x86)\Mera\Recorder\DevAPI.dll`;
- `C:\Program Files (x86)\Mera\Recorder\MICPXI.dll`;
- `C:\Program Files (x86)\Mera\Recorder\mx224v14.dll`.

Фактическое private dependency closure текущего vendor stack также включает
`MTC.dll`, `MDProtocol.dll`, `Comm.dll`, `GaugeCmn_rce.dll`, `BasePP.dll`,
`FTD2XX.dll` и `wd_utils.dll`. CRT/MFC предоставляется официальным VC++
2015–2022 x86 redistributable. Не подменять его случайным набором runtime DLL.
Точные SHA-256 и provenance находятся в
`Device/PXI/MX248/Vendor/Win32/{manifest.sha256,provenance.md}`; installer build
отклоняет смешанный или незнакомый комплект даже при совпадающей разрядности.

RecorderLnx сейчас собирается Win64. Поэтому Win64-процесс не имеет права
загружать эти DLL напрямую. Реализован отдельный x86 bridge-процесс,
собираемый имеющимся `DCC32`, и узкий versioned IPC-контракт. Если появится
официальный x64 DevAPI, backend можно заменить без изменения core/device и
datasource.

## Архитектурные границы

```text
RecorderLnx Win64
  datasource / tags / worker
          |
  TPxiMx248Device + typed config
          |
  IPxiMx248Transport
          |
  versioned local IPC
          |
  DevAPI bridge x86
          |
  DevAPI.dll -> MICPXI.dll + mx224v14.dll -> PXI MX-248
```

Обязательные ограничения:

1. `Core` не зависит от Windows API, DLL ABI, IPC и UI.
2. Только bridge x86 загружает vendor DLL и владеет DevAPI handles.
3. Один chassis/slot/module обслуживается ровно одной bridge-сессией.
4. Строковые свойства разбираются только вне `Running`; `SetProperties` во
   время сбора возвращает `rocInvalidState`. Runtime использует подготовленный
   typed snapshot и числовые handles/индексы.
5. `GetProperties` читает cache и не делает I/O. `CalcProperties` не меняет
   состояние. `SetProperties` применяет пакет атомарно через device façade и
   лишь помечает конфигурацию dirty; mutable store наружу не публикуется.
6. Порядок стадий: `Discover -> Connect -> Initialize -> Test/ReadProperties ->
   Configure -> Start -> Stop -> Disconnect`. Стадии не вызывают соседние
   скрыто.
7. Конфигурирование MX-248 сохраняет порядок оригинала:
   `CMD_MM248V2_SET_PROP`, затем `CMD_PROGRAMMING`; после первой ошибки второй
   шаг не выполняется.
8. Runtime читает данные блоками в заранее выделенные буферы, не ищет каналы
   по строкам, не меняет размеры массивов и не пишет лог для каждого отсчёта.
9. Публикация выполняется только через штатный путь datasource -> tags ->
   notify. UI не является источником измерительных данных.
10. Новые файлы этой подсистемы размещаются только в новых подкаталогах
    `Device/PXI/MX248`.
11. Persisted `pxi-mx248:<chassis>:<slot>` хранит стабильный PXI route:
    `chassis = TDevice.Route.Location.CrateSlot.CCSN`,
    `slot = CrateSlot.SlotNo`. Discovery array index не сохраняется.
12. Поиск является только перечислением: он вызывает `SearchDevices`, читает
    identity/route и не делает `CreateDeviceH`, `Config`, `Programming` или
    `Start`. Выбор найденной платы в UI меняет только редактируемый candidate;
    persisted source меняется по `Применить`/`ОК`.

## Автопоиск и привязка ручного узла

Общий диалог `Настройка -> Аппаратные свойства -> поиск` сначала запускает
локальное обнаружение PXI через x86 bridge. Каждая найденная MX-248 показывается
с именем DevAPI, серийным номером, номером шасси и слота. Устойчивая identity
для RecorderLnx строится как `pxi-mx248:<CCSN>:<SlotNo>`.

Если источник `PXI MX-248` создан вручную, в его диалоге доступна кнопка
`Найти платы`. Список предлагает обнаруженные платы; выбор заполняет шасси,
слот и новый source id, но не сохраняет изменение немедленно. Это позволяет
проверить предложенную привязку и отменить диалог без изменения проекта.

Реализация разделена по стадиям:

- `Transport/Windows/uRecorderPxiMx248WindowsTransport.pas` — IPC-команда
  discovery и строгий разбор ответа bridge;
- `UI/uRecorderPxiMx248SettingsDialog.pas/.lfm` — предложение привязки в
  карточке вручную созданного источника;
- `UI/uRecorderPxiMx248ConfiguredEditor.pas` — settings service;
- `../../../../UI/uRecorderSettingsDialog.pas` — общий поиск и добавление
  найденной платы в инспектор проекта;
- `Transport/Windows/Tests/PxiMx248WindowsTransportTest.lpr` и
  `UI/Tests/PxiMx248SettingsSmoke.lpr` — deterministic discovery/link tests.

Эталон фактически подключённой платы на стенде 2026-10-09 взят из снимков
оригинального Recorder `\\192.168.15.84\Mera Files\screens\1.png` … `6.png`:
`MX-248 PXI Card`, серийный номер `3253`, шасси `2`, слот `14`, восемь каналов,
firmware `524`. Снимки являются источником UI/identity, но не заменяют
hardware smoke RecorderLnx.

## Предметная модель MX-248

Оригинал задаёт восемь AIn. Каждый физический вход представлен парой базового
AIn и amplifier channel. Диапазон усилителя согласуется с диапазоном первого
каскада; transport не должен угадывать эту связь по UI-полям.

В typed snapshot должны сохраняться:

- частота и размер логического блока;
- enable базового AIn и amplifier;
- `differential` / `single-ended`;
- один из трёх диапазонов;
- ICP/IEPE: off, 4 mA, 10 mA;
- LPF;
- общий источник калибровки `reference` / `pxi`;
- отдельный признак включения калибровки каждого канала;
- floating input.

`MX248_TYPE=$614D`, число каналов, число диапазонов, ICP и LPF подтверждены
`devapi/Const.h` и `mx224v14/mx248const.h`. Текущие пределы sample rate и block
size в property schema являются защитными software-границами первого среза,
а не подтверждёнными аппаратными пределами; перед hardware acceptance их нужно
сверить с DevAPI property catalog и реальным прибором. Индексы range/LPF нельзя
превращать в физические значения без чтения flash/catalog через DevAPI.

## Карта первоисточников

### Оригинальный Recorder (`D:\works\windev-v3.9`)

- `devapi/DevAPI.h` — C ABI: поиск, создание/удаление устройств, lifecycle,
  properties, scan, lock/unlock.
- `devapi/Types.h` — `TDevice`, `TDeviceEnum`, route/location и размеры ABI.
- `devapi/Const.h` — `MX248_TYPE = $614D`, channel types и `TProperty` IDs.
- `devapi/DevAPI.cpp` — фактические C wrappers `SearchDevices`,
  `CreateDeviceH`, `Config`, `Programming`, `Start/Stop`, typed
  `GetProperty*/SetProperty*`.
- `MICPXI/MICPXI.cpp` и `MICPXI/PXIDev.*` — регистрация PXI device class и
  crate endpoint; эти файлы сами по себе не доказывают bus I/O и не являются
  реализацией MX-248.
- `mx224v14/mx224v14app.cpp` — регистрация `MX248_TYPE`, поиск и factory
  конкретного устройства.
- `mx224v14/mx248const.h` — 8 AIn, input modes, ranges, ICP и LPF constants.
- `mx224v14/mx248.h`, `mx248.cpp` — device fields, channel creation,
  формирование настроек и порядок `SET_PROP -> PROGRAMMING`.
- `mx224v14/mx248ain.*` — базовый AIn и связь с amplifier channel.
- `mx224v14/mx248amp.*` — свойства усилителя, диапазон, sensitivity,
  calibration enable/mode и floating input.
- `mx224v14/mx248flash.*` — чтение калибровок и метрологических данных.
- `mx224v14pp/mx248*.cpp` — только референс состава старого UI; MFC UI не
  переносится.

### Архитектурный шаблон Delphi 2020

- `D:\works\delphi2020\Recorder\Devices\MIC-140\device\uDeviceTypes.pas` —
  состояние, structured result и явный lifecycle.
- `...\device\uDevProps.pas` — строковый property channel.
- `...\device\140\uMIC140Factory.pas` — отдельная factory/capabilities.
- `...\device\140\uMIC140Dev.pas` — device orchestration.
- `...\device\140\uMIC140DataSource.pas` — граница устройства и публикации.

### RecorderLnx

- `Device/Architecture/uRecorderDriverContractsV2.pas` — operation result,
  descriptors и optional transactional property capability.
- `Device/Architecture/uRecorderDriverPropertiesV2.pas` — строгий parser,
  validation, candidate snapshot и atomic commit.
- `Device/Architecture/uRecorderHardwareDriverRegistryV2.pas` — additive
  factory registry; пока не подключён к production composition root.
- `Docs/devices/driver-v2-migration-plan.md` — общий план миграции.
- `Device/PXI/MX248/Core/uRecorderPxiMx248Types.pas` — typed snapshot.
- `Device/PXI/MX248/Core/uRecorderPxiMx248Properties.pas` — строковый adapter.
- `Device/PXI/MX248/Core/uRecorderPxiMx248Device.pas` — lifecycle orchestrator
  и transport boundary.
- `Device/PXI/MX248/Tests/PxiMx248CoreTest.lpr` — текущая software-проверка.
- `Device/PXI/MX248/Bridge` — Win32 DevAPI host, ABI probe и IPC tests.
- `Device/PXI/MX248/Transport/Windows` — Win64 bounded pipe client и codec.
- `Device/PXI/MX248/Runtime` — IRecorderDevice adapter, datasource и factory.
- `Device/PXI/MX248/UI` — offline schema editor и configured-source adapter.

## Требования к x86 DevAPI bridge

Bridge должен иметь versioned handshake и возвращать structured
`code/stage/text`, а не показывать окна и не пробрасывать исключения через IPC.
Минимальные операции: enumerate MX-248, open/close, read identity, test,
get/set typed property, configure, start/stop, read block. Handle и указатели
DevAPI никогда не передаются в Win64-процесс.

Bridge обязан ограничивать размеры сообщений и блоков, проверять protocol
version, завершать scan перед release handle и освобождать все handles при
разрыве IPC. После падения клиента следующий запуск должен снова обнаруживать
и открывать устройство без перезагрузки ПК.

## Правила логирования

Каждая значимая строка bridge/transport содержит:

```text
[MX248] session=<id> stage=<stage> chassis=<n> slot=<n> code=<code> text=<text>
```

Логировать переходы lifecycle, ошибки и редкую агрегированную статистику
блоков. Не логировать каждый пакет/отсчёт. В сообщениях о решениях и ограничениях
добавлять ссылку `Device/PXI/MX248/Docs/README.md`; подробности не копировать в
`cach/notes_last_state.md` и error-журналы.

## Приёмка

- property tests: all/subset, malformed/unknown/duplicate/read-only,
  invariant float, atomic rollback, pure Calc;
- lifecycle tests: идемпотентные Connect/Initialize/Stop/Disconnect, две пары
  Start/Stop при одном Init/Configure, first-failure configure;
- golden mapping DevAPI properties для восьми paired channels;
- блоки: порядок каналов, число отсчётов, единицы и отсутствие runtime alloc;
- forced build core test и RecorderLnx Windows/Linux;
- hardware smoke: discovery, identity, test, configure, two Start/Stop,
  reconfigure, disconnect/reconnect и controlled error для неверного slot;
- parity значений и частоты с оригинальным Windows Recorder.

До hardware smoke статус формулируется как `software-ready`, но не
`hardware-accepted`.
