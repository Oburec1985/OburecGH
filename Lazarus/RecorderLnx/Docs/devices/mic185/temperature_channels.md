# Температурные каналы MIC183/185

## Назначение

5 температурных каналов — датчики **LM74** на модулях **MI183**. В Recorder они отображаются как `MIC183_185-{3-t1}` … `{3-t5}` (виртуальный адрес `3-t1` … `3-t5`), единицы **°C**.

Используются для:
- отображения температуры модулей в UI;
- **термокомпенсации (ТКС)** тензоканалов (`MEPROP_TERMO_COMP`, `SetModuleTemp` в драйвере).

Температура **не проходит через таблицу ГХ** (калибровочную характеристику напряжения). Градусы получаются из **цифрового кода LM74** в драйвере (`ConvLM74CodeToC`).

## Частота опроса

| Группа | Fs по умолчанию | Где задаётся |
|--------|-----------------|--------------|
| 64 тензо | **100 Гц** | `ch[].m_fltFreq` в blob, `CMIC185V2ChannelBase::Init` |
| 5 temp | **1 Гц** | `tCh[].m_fltFreq`, `TEMP_MODULE_FREQ[] = {1.0f}` |
| 1 UTS | **1 Гц** | отдельный поток `DEV_ID_UTS` |

В blob стенда: `TMic185TempChanSettings.FrequencyHz := 1.0`, `Connected := True` для всех пяти слотов (`uMic185MebiusTypes.pas`).

## Протокол: отдельные TCP-пакеты

Потоки данных различаются первым ULONG **`device_id`** в payload (`mic185v2base.h`):

| device_id | Константа | Содержимое |
|-----------|-----------|------------|
| 0 | `DEV_ID_UTS` | СЕВ (время), 1 float |
| 1 | `DEV_ID_MEAS_CHANNELS` | 64× коды АЦП (float), ~100 пакетов/с |
| 2 | `DEV_ID_TEMP_CHANNELS` | 5× коды LM74 (float), **~1 пакет/с** |

Разбор в Recorder: `CMIC185V2Scan::Decommutate`, ветка `DEV_ID_TEMP_CHANNELS` → `CheckTemperature` → `PutSample` на `m_vTempChans`.

Layout payload (как у meas):

```
offset 0:   ULONG device_id (=2)
offset 4:   USHORT type_
offset 6:   USHORT pad (MSVC)
offset 8:   ULONG sampl_count_
offset 12:  float[5]  — сырые коды LM74 (в пакете как float, по смыслу USHORT)
```

Смещение данных: **`CMic185PacketDataOffset = 12`** байт.

## LM74 → °C (не ГХ)

`CMIC185V2Base::ConvLM74CodeToC` (`mic185v2base.cpp`):

```cpp
const float TEMP_CODES_TO_VALUE_COEEF = 0.0625;  // 1/16 °C на LSB
const USHORT TEMP_NEG_VALUE_MASK = 0x1000;
```

Алгоритм:
1. Взять 12-битный код LM74 (из float пакета: `(USHORT)packet.data()[i]`).
2. Если бит `0x1000` — отрицательная температура (обратный код).
3. `°C = code × sign × 0.0625`.
4. Вне диапазона **−50…+100 °C** → `BROKEN_SENSOR_DATA` (200.0).

Порт в стенде: `Mic185ConvLM74CodeToC` / `Mic185ParseTempValues` в `uMic185MebiusTcpProtocol.pas`.

### Что такое «ГХ» для temp в настройках

В UI Recorder для temp-каналов **нет** отдельной калибровочной кривой напряжения. Видимые градусы — результат **встроенной физики LM74**, а не `CComputePhysical::EvalU`.

Отдельно существуют IOCTL метрологии (`LoadCalibrCoefficients` в `mic185v2.cpp`):
- `GET_CALIBR_KOEF`, `GET_CALIBR_TC` — для **тензоканалов** (мВ, ТКС);
- `READ_CLB_MOD_TEMP` — температура модуля для **расчёта ТКС**, не для отображения `3-tN`.

Опционально при включённой ТКС: `CheckTempDeviation` усредняет «битые» датчики (отклонение ≥10 °C от максимума), если таких меньше половины.

## Именование и адреса

| Слой | Пример |
|------|--------|
| Mebius (драйвер) | `{ip}\t1` … `{ip}\t5` (`CMIC185V2TempChannelBase::GetAddress`) |
| Recorder virtual | `3-t1` … `3-t5` (`TranslateMebiusAddressToDevapi`) |
| MemTag / стенд | `MIC183_185-{3-t1}` … `{3-t5}` |

В Recorder в таблице каналов режим может отображаться как **`m`**, единицы — **`°C`** (код LM74 уже переведён в физику до UI).

## Почему temp могли не работать в стенде

### 1. Не было конвертации LM74 → °C

До исправления стенд показывал **сырой float-код** (сотни–тысячи), а не градусы. Recorder всегда вызывает `ConvLM74CodeToC`.

### 2. Потеря пакетов `dev_id=2` в очереди TCP

`ReadMeasDataBlock` раньше **выходил на первом** meas-пакете (`dev_id=1`). При соотношении 100:1 meas:temp пакет температуры часто оставался в буфере за десятками meas-пакетов и не попадал в UI.

Исправление: за один вызов сливать до 64 пакетов, кешировать последний meas и любые temp/UTS в этой пачке.

### 3. Отображение в GUI

Строки 65–69 сетки обновляются из кеша `fLastTempValues` (`UpdateAuxChannelGrid`), только если `HasTempData = True`. До прихода первого temp-пакета — `(n/a)`.

### 4. Не связано с отсутствием LoadCalibrCoefficients

Стенд не вызывает `LoadCalibrCoefficients` / `CalcStartOffset` (см. `windev_mic185_test.md`). Это влияет на **тензо/мВ и ТКС**, но **не** на базовое чтение LM74.

## Диагностика

1. **Sniff** (`mic185_acquire_test.exe`, режим sniff): в логе должны быть строки `devId=2` (~1 раз в секунду) наряду с `devId=1`.
2. **CLI**: при `HasTempData` печатается `temp[1]=37.xxx`.
3. **GUI**: строки `MIC183_185-{3-t1}` … после Start, обновление ~1 раз/с.
4. Только один TCP-клиент на порт 4000 (Recorder и стенд одновременно — IOCTL timeout).

## Ссылки на исходники windev

| Файл | Роль |
|------|------|
| `Mebius/.../mic185v2_pc/mic185v2scan.cpp` | `Decommutate`, `CheckTemperature` |
| `Mebius/.../mic185v2base/mic185v2base.cpp` | `ConvLM74CodeToC` |
| `Mebius/.../mic185v2base/mic185v2chanbase.cpp` | temp-канал 1 Гц, адрес `\tN` |
| `Mebius/.../mic185v2base/mic185v2base.h` | `tCh[5]`, `DEV_ID_TEMP_CHANNELS` |
| `MebDaqWrap/MebDaqWrapAPI.cpp` | `3-tN` в devapi |

## Ссылки на стенд

| Файл | Роль |
|------|------|
| `device/uMic185MebiusTcpProtocol.pas` | `Mic185ParseTempValues`, `ReadMeasDataBlock` |
| `device/MIC185/uMic185Device.pas` | кеш temp, `ReadBlock` |
| `uMic185DebugForm.pas` | строки 65–69 таблицы |
