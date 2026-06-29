# MIC-140: критерии успешной работы (проверка по логу)

Критерий готовности **MIC140v2** (и регрессии legacy): автоматический прогон
`Tools/mic140_preview_eval.ps1` и разбор `LogWindows.log`.

Условия стенда по умолчанию: прибор `192.168.14.155:4000`, 48 каналов, **10 Гц**,
`DataUpdateMs=200` в настройках опроса (≈ **5 блоков/с** на хосте).

---

## Три обязательные проверки

Каждый прогон считается **PASS** только если выполнены **все три** пункта.

### 1. Корректные показания (совпадение с оригиналом)

В логе есть строка `MIC-140 block1 channels:` с превью каналов первого блока.

| Что смотреть | Критерий |
|--------------|----------|
| Коды AIn `MIC140_01` … `MIC140_24` | Отрицательные raw/SmallInt, типично порядка **−6500…−8000** мВ (как в Recorder) |
| Канал `MIC140_12` | Не **32767**, не **−32768**, не явный положительный скачок; диапазон **−15000…+500** |
| Насыщение АЦП | Не более 0 «плохих» кодов среди проверяемых каналов; не менее 4 «хороших» |
**Корректные коды АЦП из Recorder:**
![[Pasted image 20260626193036.png]]

### Text rule: Recorder ADC code profile

The screenshot above is the Recorder reference for the current MIC-140 stand.
Acceptance must not rely on the image only. For every published sample, not only
for `block1`, AIn channels must keep the same sign and group profile:

| AIn channels | Acceptance range | Meaning |
| --- | --- | --- |
| `MIC140_01` .. `MIC140_24` | `-8200..-6300` raw ADC code | first group, Recorder-like negative strain codes |
| `MIC140_25` .. `MIC140_48` | `-24000..-13000` raw ADC code | second group, Recorder-like lower negative codes |

Hard fail for any published AIn 1..48 value:

- `0` from a recovered or padded row;
- `32767`, `-32768`, or any saturation near ADC limits;
- positive values;
- values outside the group range above;
- a stable series of garbage values after the first good blocks.

Reference Recorder values from the screenshot:

| Ch | Raw | Ch | Raw | Ch | Raw | Ch | Raw |
| --- | ---: | --- | ---: | --- | ---: | --- | ---: |
| 01 | -7173 | 13 | -7175 | 25 | -15964 | 37 | -21720 |
| 02 | -7124 | 14 | -7123 | 26 | -19948 | 38 | -21600 |
| 03 | -6601 | 15 | -6602 | 27 | -19913 | 39 | -19077 |
| 04 | -7233 | 16 | -7234 | 28 | -17813 | 40 | -16798 |
| 05 | -7175 | 17 | -7174 | 29 | -22240 | 41 | -18149 |
| 06 | -7124 | 18 | -7125 | 30 | -23161 | 42 | -18786 |
| 07 | -6601 | 19 | -6603 | 31 | -19082 | 43 | -15961 |
| 08 | -7234 | 20 | -7234 | 32 | -15377 | 44 | -16499 |
| 09 | -7174 | 21 | -7175 | 33 | -15884 | 45 | -20232 |
| 10 | -7122 | 22 | -7126 | 34 | -17339 | 46 | -16064 |
| 11 | -6603 | 23 | -6603 | 35 | -15462 | 47 | -13875 |
| 12 | -7235 | 24 | -7235 | 36 | -17765 | 48 | -17504 |

`Tools/mic140_preview_eval.ps1` must fail when the log contains
`MIC-140 code quality violation` or when the final stream stop line reports
`corruptPublish > 0`.

**Не считать нормой:** «TCP идёт, но с 3–4-го блока мусор» или стабильные ±32767 —
это чаще ошибка циклограммы/FIFO, а не «шум на линии».

### 2. Опрос не сбивается (целостность потока)

В финальной строке остановки потока:

```text
MIC-140 stream stop: published=… read=… readGaps=… corruptRead=… publishGaps=…
```

| Поле | Допустимо |
|------|-----------|
| `corruptRead` | **0** |
| `readGaps` | **0** |
| `publishGaps` | **0** |
| `softRestart` (по всему логу) | **0** |
| `published` / `read` | Отношение **≥ 85%** |
| `mdpResync` | Не растёт сериями на здоровых кадрах |

Дополнительно в логе **не должно** быть устойчивых серий: `stride misalignment`,
`BIOS header invalid`, повторяющихся `32767/-32768` в опубликованных блоках.

### 3. Число блоков соответствует времени опроса

Ожидаемое число опубликованных блоков:

```text
ожидаемо ≈ длительность_сек × блоков_в_сек
```

При **10 Гц** и **DataUpdateMs=200** хост получает около **5 блоков/с** (половина частоты
скана на период UI). Примеры:

| Длительность Preview | Ожидаемо `published` | Допуск скрипта (≈) |
|----------------------|----------------------|---------------------|
| **3 с** | ~**15** | 13…20 |
| **10 с** | ~**50** | по той же формуле (90%…125% + 1) |
| **40 с** | ~**200** | по той же формуле |

Скрипт берёт `freq=… Hz` из лога и пересчитывает `blocksPerSec = freq/2`, если частота
известна.

---

## Порядок прогонов (нарастание длительности)

Работу считаем подтверждённой **поэтапно**:

| Этап | Команда | Условие перехода |
|------|---------|------------------|
| **A** | `mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0` | **3 подряд PASS** (три прогона по 3 с) |
| **B** | `mic140_preview_eval.ps1 -Seconds 10` | **3 подряд PASS** (три прогона по 10 с) |
| **C** | `mic140_preview_eval.ps1 -Seconds 40` | **1 PASS** (стабильность на длинном интервале) |

Между прогонами — пауза 2–3 с, лог перед каждым прогоном очищается (`-SettleSec` при
первом запуске после старта IDE — по необходимости).

Пример этапа A:

```powershell
1..3 | ForEach-Object {
  & D:\works\OburecGH\Lazarus\RecorderLnx\Tools\mic140_preview_eval.ps1 -Seconds 3 -SettleSec 0
  if ($LASTEXITCODE -ne 0) { break }
  Start-Sleep -Seconds 2
}
```

---

## Пример успешного PASS (3 с, эталон 25.06.2026)

```text
PASS pub=15 read=15 ratio=100% corrupt=0 pubGaps=0 readGaps=0 softRestart=0 expected=15 range=13..20 bps=5 readings=ok good=10 ch12=-7550
MIC-140 stream stop: published=15 read=15 readGaps=0 dupRead=0 corruptRead=0 publishGaps=0 corruptPublish=0 ringDropped=0 mdpResync=0
```

---

## Связь с MIC140v2

| Этап миграции | Требование по логам |
|---------------|---------------------|
| Transport + workers | Этап **A** (3×3 с) |
| Подключение в источник данных | Этап **B** (3×10 с) |
| Готовность к замене legacy | Этап **C** (40 с), `corruptRead=0` |

Скрипт и критерии общие для legacy и v2: меняется только код драйвера, строки в логе
и формат `stream stop` должны сохраниться.

См. также [mic140_legacy_scan_stream.md](../../mic140_legacy_scan_stream.md) §9.1,
[migration_mic140v2.md](../migration_mic140v2.md).
