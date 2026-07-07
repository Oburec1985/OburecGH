# Эталон: windev `examples/mebius.daq/tests/mic185_test`

GTest-стенд программирования MIC-185 через Mebius DAQ API (`medaq_ms`). Добавлен в windev-v3.9 как референс для порта Lazarus `Tests/mic185`.

**Путь:** `d:\works\windev-v3.9\examples\mebius.daq\tests\mic185_test\`

## Структура

| Файл / каталог | Назначение |
|----------------|------------|
| `CMakeLists.txt` | Сборка `medaq_mic_185_test` (GTest + `medaq_ms`) |
| `fixtures/mic185_test_fixture.h` | Инициализация DART, `DeviceSession`, каталог вывода `%TEMP%/mic185/...` |
| `core/device_session.h` | `CreateDevice(\192.168.9.142:4000)`, `Connect` + `WaitConnecting(5s)` |
| `core/daq.h` | Connect → Program → Start → sleep → Stop |
| `core/channel_builder.h` | Fluent API свойств канала (`mode`, `commut`, `tenzo_sens`, …) |
| `core/stream.h` | Запись float-сэмплов в `channel_NN.bin` |
| `tests/test_runner.cpp` | Каналы 0–15 с разными свойствами, 10 с сбор |
| `tests/test_single_channel_basic.cpp` | Один канал (5), 3 с |

Драйвер (вне каталога теста): `examples/mebius.daq/mebius_daq_devices/ms/mic185/mic185.cpp` → `CMIC185::OnProgramDevice()`.

## Последовательность программирования (как в Recorder)

```
Connect → GET_SOFT_VERSION (в OnConnecting)
UpdateMaxFreq
LoadCalibrCoefficients   ← IOCTL метрологии (KX, IN_RESIST, temp)
CopySettingsToPhysical
CalcStartOffset
для i=0..63:  ch[i] = channel[i].GetSettings()   // только подключённые каналы Connected=true
для temp:     tCh[k] = tempChannel.GetSettings()
UTS Program
SET_CONTROLLER_PARAMS    (TASKSEV_EN_FLAG если UTS подключён)
PROGRAMM_DEVICE_BIN      (sizeof CMIC185V2_BASESETTINGS)
SET_SESSION_ID + PROGRAM
Start → IOCTL START
```

Соответствие Lazarus (`uMic185Device.ProgramDevice`): шаги 8–11 реализованы; **нет** `LoadCalibrCoefficients` и `CalcStartOffset` (для режима «коды» не критично).

## Дефолты vs Recorder UI

См. [defaults.md](defaults.md). `Mic185BuildSettings` в Lazarus повторяет `MIC185V2_DEFAULT` + `CMIC185V2ChannelBase::Init`:

- все **64** тензоканала: Connected, 100 Гц, ±5 мВ, коммутация «Вход», tenzo 2.0, R=200 Ом
- **5** темп.: 1 Гц, Connected
- модуль: Gnd 100 мкс, Chn 150 мкс, усреднение 128, `GroupAddition` = `MOD_ADD_OFF` (4)
- UTS: флаг `TASKSEV_EN_FLAG` при `fUtsEnabled` (как 70 каналов в Recorder)

`test_runner.cpp` **намеренно** меняет свойства каналов 0–15 — это не дефолт Recorder, а регрессия API.

## Коды АЦП

- В пакете `DEV_ID_MEAS_CHANNELS` — **float** (сырой код АЦП в режиме `TYPE_SIGNAL_CODE = 0`).
- `CMIC185Scan::Decommutate` → `PutSample(float)` → при `m_nSignalType=0` значение без пересчёта в мВ.
- Диапазон int16: **−32768 … +32767**.

### Парсинг в Lazarus (важно)

- Смещение данных **12** байт (`CMic185PacketDataOffset`) — MSVC padding в `INTERNAL_PACKET_HEADER`.
- Blob **3976** байт — явные `_Pad*` в `uMic185MebiusTypes.pas`.
- `ReadMeasDataBlock`: batch-drain для temp/UTS. См. [protocol.md](protocol.md).

## Сверка с Recorder

| Инструмент | Команда |
|------------|---------|
| CLI | `mic185_acquire_test.exe -verify-codes 192.168.9.142 4000 100 5` |
| GUI | `mic185_acquire_gui.exe --verify` |
| GUI stress | `mic185_acquire_gui.exe --stress` |

Эталонные коды каналов 3-1…3-50 — в [defaults.md](defaults.md), модуль `uMic185CodeVerify.pas` (допуск ±3).

Подробнее о стенде: [test_stand.md](test_stand.md).

Перед прогоном закройте Recorder / другие клиенты на порту 4000.

## Сборка windev-теста

```bat
cd d:\works\windev-v3.9\examples\mebius.daq
cmake --build build --target medaq_mic_185_test
ctest -R mic185
```

(точные цели зависят от корневого CMake windev.)
