# MIC185 dblClick: ESocketError при занятом порте 4000

## Симптом

При dblClick по MIC185 в дереве устройств (во время активного просмотра/записи) —
`ESocketError: Connection to 192.168.9.142:4000 timed out` в `TInetSocket.Write` /
`WriteBytes` при открытии диалога настройки.

## Подтверждённые факты

- MIC185V2 допускает **один TCP-клиент** на порт 4000.
- При запущенном `TRecorderMic185DataSource` сокет уже занят классом устройства.
- `RecorderMic185ReadDeviceInfo` открывал **второе** подключение для IOCTL `GetSoftVersion`.
- Probe TCP проходит, но `WriteBytes` IOCTL зависает/таймаутит при занятом приборе.
- Просмотр тренда при этом работает — данные идут через существующую сессию.

## Отвергнутые гипотезы

- Неверный `Format` адреса каналов — исправлен ранее, но не причина `ESocketError` на write.
- Только отсутствие TCP-probe — probe есть, но не решает конфликт двух клиентов.

## Исправление

1. **Live session registry** в `uRecorderMic185DataSource.pas`:
   - `TRecorderMic185LiveSession` регистрируется при `PrepareHardware`/`Start`;
   - `RecorderMic185ReadDeviceInfo` при активной сессии возвращает кэш sn/версии **без TCP**.
2. **`RecorderMic185Log`** → `LogWindows.log` + `mic185` буфер.
3. **`TryWriteBytes`** в `uMic185MebiusTcpProtocol` — `ESocketError` не пробрасывается из IOCTL.
4. Дерево устройств: `Mic185SourceConnected` учитывает `RecorderMic185IsEndpointLive`.

## Исправление (v2)

1. **`uRecorderMic185Runtime.pas`** — глобальный реестр endpoint `host:port`, привязанный к **реальному сокету драйвера** (`TRecorderMic185Device.Connect/Disconnect/Start/Stop`).
2. **`RecorderMic185ReadDeviceInfo`** и **`TryConnect`** — если порт занят RecorderLnx, **TCP не открывается**.
3. Диалог MIC185 при активном опросе показывает «Опрос активен» и sn/версию из runtime.
4. `MainForm.TagHardwareSourceSetup` — добавлена ветка MIC185.

## Исправление (v6) — shutdown + статус дерева

1. **`finalization`** — `Delete(0)` после `Free` в списках runtime/live-devices (был бесконечный цикл / AV при выходе).
2. **`TestLink` MIC185** — `rdsConnected`/`rdsProgrammed`/`rdsStarted` = link OK без IOCTL на занятом сокете.
3. **`RecorderMic185RegisterLiveDevice(host, port)`** — канонический sourceId в реестре.
4. **`RecorderMic185IsSourceLinkOk`** — нормализация id + fallback `RuntimeIsBusy` для дерева устройств.

---

1. **`IRecorderDevice.TestLink`** — проверка связи только по открытой сессии (без нового TCP).
2. **MIC185** — при `rdsStarted` link OK; иначе IOCTL `GetSoftVersion` на `fClient`.
3. **MIC140 v1/v2** — при опросе `ProbeScan`; иначе `ReadFirmware` на существующем сокете.
4. **`uRecorderHardwareLiveDevices`** — реестр live `IRecorderDevice` от data source.
5. Дерево устройств / health probe — `RecorderHardwareIsSourceLinkOk`, **без TcpProbe**.
6. **Настройки** — preview не останавливается при открытии диалога (останавливается только запись).

## Исправление (v4) — состояние из класса устройства, без probe TCP

1. **`RecorderMic185RegisterLiveDevice`** — при `PrepareHardware` в реестр попадает `TRecorderMic185Device`.
2. **`RecorderMic185TryGetLiveDeviceInfo`** / **`IsLiveDeviceConnected`** — sn, версия, опрос из `Device.State`, `DeviceSerial`, `SoftVersion`.
3. **`RecorderMic185ReadDeviceInfo`** — **не открывает TCP**; только live device или «Нет связи».
4. Диалог MIC185 / дерево / health probe — без дополнительных подключений.

## Проверка (выполнена 2026-07-07)

```text
RecorderLnx.exe --selftest-mic185-settings
LogWindows.log:
  LiveDeviceRegister 192.168.9.142:4000 state=2 sn=157
  LiveDeviceInfo 192.168.9.142:4000 sn=157 ver=20.6.6 acquiring=True state=3
  (нет строк opening probe TCP)
```

## Исправление (v3)

1. **`RuntimeHoldBusy`** при `RequestStop` MIC185 — порт остаётся «занят» до завершения worker-thread.
2. **`Disconnect`**: сначала закрытие сокета, потом снятие из TCP-реестра (устранена гонка).
3. **`btnSettings`**: явный `StopDataSources` перед открытием диалога настроек.
4. **Дерево устройств**: `Mic185SourceConnected` не открывает TCP, если endpoint live.
5. **Self-test**: `--selftest-mic185-settings` — preview → `ConfigureMic185Source` без probe TCP.
6. **`DebugEditMic185Source`** / `RecorderSettingsDialogDebugEditMic185` — программный вызов пути dblClick.

## Проверка

1. Запустить просмотр MIC185.
2. dblClick по узлу в дереве — диалог открывается, sn/версия из live session, без исключения.
3. Лог: строки `[MIC185] ReadDeviceInfo ... reuse runtime` (не `opening probe TCP`).
4. Автотест: `RecorderLnx.exe --selftest-mic185-settings` → `MIC185 self-test: PASS`.

## Риск

Если сессия есть, но `SerialNumber` ещё 0 (между connect и QueryDeviceInfo) — диалог может показать пустой s/n; повторный Refresh после старта опроса заполнит поля.
