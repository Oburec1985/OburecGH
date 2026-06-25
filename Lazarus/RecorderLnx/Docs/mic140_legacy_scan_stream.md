# MIC-140 legacy: поток scan (stream 0) — методика, диагностика, задача для Codex

Документ собирает знания, накопленные при отладке **RecorderLnx** на живом приборе
`192.168.14.155:4000`, 48 каналов, 10–100 Гц. Это дополнение к
[`mic140_protocol.md`](mic140_protocol.md) и [`mic140_quickstart.md`](mic140_quickstart.md).

**Эталон:** оригинальный Windows Recorder `D:\works\windev-v3.9` (mdpEthernet81 +
MC031 + MIC140_48).

**Рабочий код:** `Device/MIC140/uRecorderMic140LegacyProtocol.pas`,
`Device/MIC140/uRecorderMic140DataSource.pas`.

**Лог:** `LogWindows.log` в каталоге сборки RecorderLnx.

> **Временный режим лога (2026-06):** `CMic140StreamLogOnly = True` в
> `Core/uRecorderDebugLog.pas` — в файл попадают только сообщения legacy scan
> stream MIC-140. Остальные `RecorderDebugLog` и шумные `Mic140LogWarning`
> (подключение, калибровки, CJC) отфильтрованы.

---

## Справочник: формат пакета и потоки опроса

Чистовой блок для отладки legacy scan stream MIC-140 48ch @ 10 Hz, 2 отсчёта/блок,
stride 51 (48 AIn + 3 TIn). Источник: `devapi/Types.h` (`THeaderMessage`),
`uRecorderMic140LegacyProtocol.pas` (`ReadPacket`, `ReadScanBlock`).

### Таблица 1. Формат MDP-кадра scan (stream 0)

Первая строка — начало кадра в TCP-потоке, последняя — конец кадра.
Все многобайтовые поля — **little-endian**. Размеры указаны для типового блока
измерений (112 слов payload).

| ID                 | Формат   | Размер                | Назначение                                                                                                         |
| ------------------ | -------- | --------------------- | ------------------------------------------------------------------------------------------------------------------ |
| MDP-SYNC           | `uint16` | 2 байта               | **Начало MDP-кадра.** Sync-word `0x12B8`                                                                           |
| MDP-PORT           | `uint16` | 2 байта               | Номер потока: `0` = scan (измерения), `1` = command                                                                |
| MDP-SIZE           | `uint16` | 2 байта               | Длина payload в словах WORD; для scan = `112`                                                                      |
| MDP-HCS            | `uint16` | 2 байта               | Контрольная сумма MDP-заголовка: `(SYNC+PORT+SIZE) mod 65536`                                                      |
| BIOS-TYPE          | `uint16` | 2 байта               | `THeaderMessage.type` — тип BIOS-сообщения (`0` = блок данных)                                                     |
| BIOS-SIZE          | `uint16` | 2 байта               | `THeaderMessage.size` — размер всего BIOS-сообщения в словах (`112`)                                               |
| BIOS-SCAN_ID       | `uint16` | 2 байта               | `scan_id` — идентификатор скана                                                                                    |
| BIOS-SLOT          | `uint16` | 2 байта               | `slot`                                                                                                             |
| BIOS-CHAN          | `uint16` | 2 байта               | `chan`                                                                                                             |
| BIOS-TIME_HI       | `uint16` | 2 байта               | `time_hi` — старшая часть метки времени                                                                            |
| BIOS-TIME_LO       | `uint16` | 2 байта               | `time_lo` — младшая часть метки времени                                                                            |
| BIOS-TIME_CNT      | `uint16` | 2 байта               | `time_cnt` — счётчик времени BIOS                                                                                  |
| BIOS-NUM_BUFF      | `uint16` | 2 байта               | `num_buff` — номер BIOS-блока (монотонный, без пропусков)                                                          |
| BIOS-STATE         | `uint16` | 2 байта               | `state` — флаги состояния блока                                                                                    |
| DATA-00 … DATA-101 | `uint16` | 102 слова (204 байта) | Payload: `2 отсчёта × (48 AIn + 3 TIn)`, stride = 51. Индекс: `j*51 + ch`. Код АЦП интерпретируется как `SmallInt` |
| MDP-DCS            | `uint16` | 2 байта               | **Конец MDP-кадра.** Контрольная сумма payload: `(Σ всех payload-слов) mod 65536`                                  |

**Итого кадр:** 8 байт MDP-заголовок + 112×2 байт payload + 2 байт MDP-DCS = **234 байта**.

Один MDP-кадр stream 0 = один BIOS-блок. Парсер `ReadScanBlock` не ищет
заголовок внутри DATA; первые 10 слов payload — всегда `THeaderMessage`.

### Таблица 2. Потоки, участвующие в опросе MIC-140 (legacy)

| Поток                                                                          | Действия                                                                                                                                                                                                                                                                                                          |
| ------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Src_MIC-140** | `DoTick`: `ReadLegacyRawBlock` → кольцо `TMic140RawBlockRing`; drain; `StopScan` по `TryStop` |
| **MIC-140.BlockPublish** | `Dequeue` → `LegacyDecommutateRawBlock` → CJC/теги |
| **LegacyClient** (объект) | MDP/TCP: `ReadScanBlock` в reader-потоке; `CallCommand` в `PrepareHardware` |
| **UIThread** | `StartAll` → `PrepareHardware` (Connect/Program/StartScan) до worker-потоков |
| *(резерв)* **LegacyRead** | Не стартует |

**Поток данных:**

```text
Прибор :4000 TCP
  -> ReadLegacyRawBlock (Src_MIC-140, LegacyClient.fLock)
  -> TMic140RawBlockRing (фикс. 8 слотов, struct copy)
  -> BlockPublish: LegacyDecommutateRawBlock -> ProcessAndPublishBlock -> теги MIC140_*
```

---

## 1. Задача для Codex (кратко)

Сделать **устойчивый непрерывный приём BIOS-блоков scan** по legacy TCP (stream 0)
для MIC-140 48ch, как в оригинальном Recorder:

- блоки 1, 2, 3… идут без рассинхрона;
- коды AIn стабильны (термопары: отрицательные мВ, без массовых `±32767`);
- сбор **не останавливается** через 2–5 блоков и не уходит в бесконечный resync;
- UI продолжает получать данные при работающем TCP.

**Не считать успехом:** «поток TCP идёт, но с 3–4 блока мусор» или «2 блока норм,
потом тишина / Stop».

---

## 2. Эталонная архитектура (windev-v3.9)

### 2.1. Цепочка данных

```text
TCP socket
  -> mdpEthernet81::RxCallBack (постоянное чтение)
  -> ProcessProtocol (sync 0x12B8, checksum, resync +1 byte при ошибке)
  -> по port: stream 0 -> m_ScanFifo, stream 1 -> m_CommandFifo
  -> ScanFifoCallBack (отдельный поток/обработчик)
       ReadStream: ровно 10 WORD THeaderMessage
       ReadStream: ровно (header.size - 10) WORD данных
       -> ScanMIC140::Decommutation()
```

Ключевые файлы:

| Файл | Роль |
|---|---|
| `mdpEthernet81/mdpEthernet81.cpp` | MDP-пакеты, scan/command FIFO |
| `mtcEthernet81/Mc031ethernetifc.cpp` | `ScanFifoCallBack`, чтение заголовка и тела |
| `devapi/Types.h` | `THeaderMessage` |
| `MIC140_96_rce/mic140_96scn.cpp` | `Decommutation`, CJC, `buff[offset+i*size]` |

### 2.2. Что делает оригинал принципиально иначе

1. **Два FIFO** — scan и command не смешиваются; команды не «съедают» scan-пакеты.
2. **Нет поиска заголовка в данных АЦП** — после sync читается ровно `header.size` слов.
3. **Нет отбрасывания блоков** по эвристике «похоже на мусор» в парсере.
4. **RX читает сокет постоянно**, а не только когда UI/источник вызвал `ReadBlock`.

---

## 3. Текущая архитектура RecorderLnx

### 3.1. Потоки (текущая сборка)

```text
UI / main thread (StartAll)
  -> PrepareHardware: Connect, ProgramDevice, StartScan (LegacyClient.CallCommand)

Src_MIC-140 (DoTick)
  -> ReadLegacyRawBlock: TCP/MDP, memcpy в TMic140LegacyRawBlock
  -> TMic140RawBlockRing.Enqueue (8 слотов, при переполнении — drop oldest + warning)

MIC-140.BlockPublish
  -> Dequeue raw -> LegacyDecommutateRawBlock -> ProcessAndPublishBlock -> теги
```

- **`TRecorderMic140LegacyClient`** — не поток, а объект TCP/MDP (`fLock` на `ReadScanBlock` / `CallCommand`).
  Команды старт/стоп/программирование — в **`PrepareHardware`** до старта worker-thread.
- **`TMic140RawBlockRing`** — фиксированный кольцевой буфер `8 × (10+102 WORD)` без heap-копий на handoff.
- **`TMic140BlockPublishThread`** — только декоммутация и публикация в теги.

### 3.2. Буферы в `TRecorderMic140LegacyClient`

| Буфер | Назначение |
|---|---|
| `fRxBuffer` | сырые байты MDP (уровень TCP-пакета: sync, port, size, data, checksum) |
| `fScanPayloadWords` | накопитель **слов** BIOS scan FIFO (как `m_ScanFifo` в оригинале) |
| `fPendingScanBlocks` | очередь уже разобранных блоков `{HeaderWords[10], DataWords[102]}` |

**Важно:** слова из `fScanPayloadWords` **не возвращаются** в `fRxBuffer`. Уровни
MDP и BIOS разделены.

### 3.3. Алгоритм `ReadScanBlock`

1. Dequeue из `fPendingScanBlocks`, если есть.
2. `ParseScanPayloadWords` на `fScanPayloadWords`.
3. Снова dequeue.
4. `ReadPacket` до `port == 0` (stream scan).
5. `AppendScanPayloadWords` + `ParseScanPayloadWords`.
6. Dequeue или мягкий timeout (не фатальная ошибка parse).

### 3.4. Алгоритм `ParseScanPayloadWords` (текущий)

Пока в буфере ≥ 10 слов и не исчерпан лимит resync (`CMic140LegacyMaxResyncStepsPerParse = 8`):

1. Если неполное сообщение при **валидном** заголовке — ждать (break).
2. Если заголовок на offset 0 невалиден — `resync +1` слово.
3. Если заголовок валиден — извлечь ровно `size` слов (112), enqueue, сдвинуть буфер.
4. Обновить `fLastParsedNumBuff` / `fExpectedDataWords` (102).

**Валидация заголовка** (`Mic140LegacyScanHeaderLooksValid`):

- `type = 0`, `scan_id = 0`, `state = 0`
- `size = 112` (ровно)
- `dataWords = 102` после первого блока
- `num_buff > 0`; если уже был блок — `num_buff > last` (строго растущий)

**Убрано (не повторять):**

- `doubled payload` — синтетические блоки из остатка кратного 102 без заголовка;
- `PrependRxWords` — смешивание BIOS-слов обратно в MDP byte buffer;
- проверка «plausible ADC» в парсере — отбрасывала **валидный блок 1** и запускала
  сотни `resync +1` за один вызов (~600 ms без чтения сокета);
- `ClearBufferedPackets` **после** `StartScan` — терялись первые пакеты уже идущего скана;
- отбрасывание «corrupt» блоков + `ClearLegacyScanBuffer` в publish-пути.

---

## 4. Формат BIOS-сообщения scan

### 4.1. MDP (TCP)

```text
WORD sync      = 0x12B8
WORD port      = 0 (scan) или 1 (command)
WORD size      = число WORD в data[]
WORD header_cs = (sync + port + size) & $FFFF
WORD data[size]
WORD data_cs   = sum(data[]) & $FFFF
```

При ошибке checksum/sync: сдвиг **+1 байт** (как `mdpEthernet81::ProcessProtocol`).

### 4.2. THeaderMessage + данные (внутри data[] stream 0)

```text
[10 WORD заголовка][102 WORD данных]  = 112 WORD на одно BIOS-сообщение
```

Поля заголовка (`devapi/Types.h`, индексы в `uRecorderMic140LegacyProtocol.pas`):

| Индекс | Поле | Типичное значение |
|---:|---|---|
| 0 | type | 0 |
| 1 | size | **112** (всё сообщение, не только data) |
| 2 | scan_id | 0 |
| 3 | slot | 0 |
| 4 | chan | 0 |
| 5 | time_hi | растёт |
| 6 | time_lo | ~28650 (на эталонном приборе) |
| 7 | time_cnt | 0 или 1 |
| 8 | num_buff | 1, 2, 3… |
| 9 | state | 0 |

**Критично:** раньше отбрасывали 5 WORD вместо 10 — поля `time_*` и `num_buff`
попадали в данные → скачки на всю шкалу. Сейчас `CLegacyScanHeaderWords = 10`.

### 4.3. Раскладка 102 WORD данных (48 AIn + 3 TIn)

Для текущего RecorderLnx:

- **stride (internal)** = `48 + 3 = 51` (`LegacyInternalScanChannelCount`);
- **samples per block** = `102 / 51 = 2`;
- индекс: `DataWords[J * 51 + I]` — sample `J`, канал `I` (0..47 AIn, 48..50 TIn).

Код в `TRecorderMic140Device.ReadBlock`:

```pascal
lDataIndex := J * lInternalChannelCount + I;
ABlock.Values[I][J] := SmallInt(lLegacyBlock.DataWords[lDataIndex]);
```

Оригинал (`mic140_96scn.cpp`):

```cpp
val = (short)buff[offset + i * size];  // offset=номер канала, size=stride, i=sample
```

При stride=51 и offset=I это эквивалентно `J*51+I`.

### 4.4. Эталонные коды АЦП (живой прибор, комнатная температура)

Как **uint16** в логе (как SmallInt — отрицательные мВ):

| Зона | Пример uint16 | SmallInt (мВ) |
|---|---:|---:|
| ch 1–24 | 58375–58947 | ~−6593…−7222 |
| ch 25–48 | выше, но как SmallInt отрицательные | ~−15789…−22808 |
| Tin (ch 49–51 в stride) | ~7886, 8065 | положительные коды |

**Не путать с мусором:** `±32767`, массовые положительные на ch 1–24, повторяющееся
preview каждые 3 блока — признак **рассинхрона парсера**, не «особенности датчиков».

---

## 5. Программирование скана (контекст для разбора потока)

Полная последовательность — в [`mic140_protocol.md`](mic140_protocol.md). Для потока
важно:

- FIFO DM: `0x0522..0x07FF` (Ethernet MC031, не `0x0000`);
- `fifoReadyWords` при 10 Hz, 48+3 ch, update 200 ms: **102** (= 2 samples × 51 ch);
- земля перед каждым каналом в таблице дескрипторов (ground, ch, ground, ch, …);
- `ClearBufferedPackets` — **до** `StartScan`, не после;
- при `CallCommand` пакеты stream 0 **буферизуются** в scan-парсер (`AbsorbScanStreamPacket`), не отбрасываются.

---

## 6. Диагностика по логу

### 6.1. Здоровый старт

```text
Legacy first scan packet: ... h=[0,112,0,0,0,0,10091,28650,1,0] d0=[58379,58429,...]
MIC-140 block=1 samples=2 stride=51 rate=10.000 Hz
```

### 6.2. Типичные симптомы поломки

| Симптом в логе | Вероятная причина |
|---|---|
| `d0=[32768,32767,...]` с 3-го блока | ложный заголовок / сдвиг на 1+ слово |
| `stride misalignment suspect: positive=26 sat=48` | неверный stride или сдвиг |
| сотни строк `resync +1` за <1 с | парсер крутится в буфере, сокет не читается |
| `reject implausible ADC payload` на `d0=58378…` | **ложное срабатывание** эвристики (уже убрано) |
| `Legacy scan read failed after N good blocks (3 timeouts)` | медленный reader или зависший parse |
| `readBlocks=0` при Stop после рестарта | блоки не дошли до publish |
| одинаковый `preview=[31613,13458,...]` на block 3,6,9… | цикл рассинхрона на 3 фазы |

### 6.3. Полезные строки лога

- `Legacy first scan:` / `Legacy scan:` — `readSerial`, `num_buff`, `sincePrevMs`, `page`, `time_lo`, `d0`, `corrupt=` (первые 50 блоков и любой corrupt);
- `Legacy num_buff gap on read` — пропуск на стороне TCP/reader (`prev`, `expected`, `cur`, `missed`);
- `Legacy num_buff duplicate` — повтор `num_buff` (дубликат пакета, не пропуск);
- `MIC-140 num_buff gap on publish` — пропуск после ring (reader не успел или overflow);
- `MIC-140 stream:` — сводка каждые 20 опубликованных блоков (`readGaps`, `dupRead`, `corruptRead`, `publishGaps`, `ring`);
- `MIC-140 raw ring overflow` / `raw ring depth` — переполнение кольца;
- `stride misalignment suspect` — corrupt после декоммутации;
- `MIC-140 block=N` — успешная публикация;
- `Legacy StopScan completed` / `MIC-140 stream stop` — итог сессии с счётчиками `num_buff`.

**Интерпретация `num_buff`:** монотонный рост без `gap`/`duplicate` → TCP не теряет пакеты; `corruptRead>0` при `readGaps=0` → битый payload на устройстве, не reader.

**Интерпретация `sincePrevMs`:** при 10 Hz и 2 samples/block ожидается **~200 ms** между пакетами. Значения 200–450 ms — reader успевает, но с запасом; систематически <100 ms — риск переполнения FIFO на прошивке; >500 ms — риск пропуска на устройстве (сверять с `readGaps`).

**Программирование scan (windev):** `m_ChanDump[2] = channels.Size()` — число пользовательских каналов (48), не stride AIn+TIn (51). Ошибка в этом поле ломает раскладку FIFO BIOS при двойной буферизации.

**MDP vs BIOS:** на каждом TCP-пакете проверяются sync + CS заголовка + CS данных (`ReadPacket`). Отдельного CRC у `THeaderMessage` нет; при неверном `type/size` пишется `Legacy BIOS header invalid`.

---

## 7. История неудачных гипотез (не повторять)

| Подход | Почему плохо |
|---|---|
| Искать заголовок `type=0,size=112` в потоке без строгого sync | ложные совпадения в данных АЦП |
| Resync +1 в цикле без лимита | блокирует read thread на сотни ms |
| Отбрасывать блоки с «corrupt» ADC в publish | ломает `num_buff` и провоцирует stop |
| Проверять «все каналы отрицательные» в парсере | отвергает валидные блоки; high ch могут давать иные коды |
| Смешивать MDP RX и BIOS payload в одном буфере | двойное потребление / потеря границ |
| `ClearBufferedPackets` после StartScan | теряются первые scan-пакеты |
| Читать сокет из main и read thread без mutex | гонка, битый `fRxBuffer` / `fScanPayloadWords` |

---

## 8. Целевая методика (к чему идём)

### 8.1. Минимально достаточная (ближайший шаг)

1. **Один владелец сокета** — mutex на клиенте (сделано).
2. **ScanFifo-модель** — накопитель слов + чтение ровно 112 слов по валидному заголовку.
3. **Ограниченный resync** — не более 8 слов за вызов parse; остальное — ждать следующий MDP-пакет.
4. **Мягкий timeout** — непарсимый хвост не фатален.
5. **CallCommand** — scan-пакеты в тот же FIFO, не в /dev/null.

### 8.2. Полная (как оригинал)

1. Отдельный **RX thread** — только чтение TCP и `ProcessProtocol`.
2. Два **FIFO**: scan words / command words.
3. **ScanFifoCallBack** — только разбор `THeaderMessage` + data, без эвристик.
4. Верхний слой только dequeue готовых блоков.

Псевдокод целевого parse (без поиска в данных):

```pascal
while Length(payload) >= 10 do
  if partial_valid_header then break;
  if not header_valid_at_0 then
    delete 1 word; continue;  // с лимитом за вызов
  extract 112 words;
  enqueue block;
  delete 112 words;
```

---

## 9. Критерии приёмки (для Codex)

На `192.168.14.155:4000`, 48 ch, 10 Hz, не менее **60 с** непрерывного Preview:

1. `MIC-140 block` растёт монотонно (≈10 блоков/с при 2 samples/block и 10 Hz — ориентир ~5–10 block/s в логе с учётом drain).
2. Нет серий >20 строк `resync +1` подряд.
3. `d0` в `Legacy scan block N` для N≤10: uint16 в диапазоне **58000–59000** на ch1–8 (или эквивалентные отрицательные SmallInt).
4. Нет `stride misalignment` с `sat>=32` на блоках 3+.
5. `num_buff` в заголовках монотонно растёт (допустимы пропуски с warning, не допустим цикл 1,2,3,1,2…).
6. Stop только по действию пользователя, не по timeout storm.

Сборка:

```text
C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi
```

---

## 10. Карта файлов

| Файл | Содержание |
|---|---|
| `Device/MIC140/uRecorderMic140LegacyProtocol.pas` | MDP, `ReadPacket`, `ParseScanPayloadWords`, mutex |
| `Device/MIC140/uRecorderMic140DataSource.pas` | ProgramLegacyDevice, ReadBlock, threads, decommutation |
| `Device/MIC140/uRecorderMic140Utils.pas` | host/port, теги |
| `Docs/mic140_protocol.md` | полный протокол, DM, дескрипторы, CJC |
| `Docs/mic140_quickstart.md` | краткая последовательность старта |
| `D:\works\windev-v3.9\mdpEthernet81\` | эталон MDP |
| `D:\works\windev-v3.9\mtcEthernet81\Mc031ethernetifc.cpp` | эталон ScanFifoCallBack |

Транскрипт отладочной сессии (июнь 2026):
`C:\Users\User\.cursor\projects\d-works-windev-v3-9\agent-transcripts\909735e2-468f-42b4-932f-f425e1fd2be6\909735e2-468f-42b4-932f-f425e1fd2be6.jsonl`

---

## 11. Промпт-заготовка для Codex

```text
Контекст: RecorderLnx, MIC-140 legacy Ethernet (mdpEthernet81), прибор 192.168.14.155:4000.

Прочитай:
- Docs/mic140_legacy_scan_stream.md
- Docs/mic140_protocol.md (разделы scan, FIFO, THeaderMessage)
- Device/MIC140/uRecorderMic140LegacyProtocol.pas
- Device/MIC140/uRecorderMic140DataSource.pas (ReadBlock, threads)

Эталон: windev-v3.9 mdpEthernet81 + Mc031ethernetifc ScanFifoCallBack.

Проблема: после 1–2 хороших BIOS-блоков stream 0 рассинхронизируется (мусорные ADC,
±32767, повтор preview каждые 3 блока) или сбор останавливается из-за бесконечного
resync / timeout.

Задача: довести приём stream 0 до поведения оригинала (ScanFifo + фиксированное
чтение 10+102 слов). Не использовать эвристики отбрасывания блоков в парсере.
Сохранить stride=51 (48+3 TIn). Проверить на LogWindows.log критерии из раздела 9.

Ограничения:
- не ломать ProgramLegacyDevice / DM 0x0522;
- не вызывать StopScan на обычном read timeout;
- mutex на TRecorderMic140LegacyClient обязателен;
- минимальный diff, без рефакторинга UI.
```

---

## 12. Состояние на 2026-06-24

**Сделано:**

- ScanFifo-подобный буфер `fScanPayloadWords` + очередь `fPendingScanBlocks`;
- отдельные read/publish threads;
- mutex на legacy client;
- заголовок 10 WORD, size=112, data=102;
- decommutation `J*51+I`;
- 3 TIn в хвосте stride для CJC;
- ограничение resync, буферизация scan при CallCommand;
- ClearBuffered перед StartScan.

**Открыто / нестабильно:**

- устойчивый приём 10+ блоков подряд без рассинхрона (основная задача);
- полный RX thread + dual FIFO как в mdpEthernet81;
- сверка `num_buff` при пропусках пакетов на сети;
- частоты ниже/выше 100 Hz на железе.

**Следующий инженерный шаг (рекомендация):** вынести RX в отдельный поток по образцу
`mdpEthernet81::RxCallBack`, оставив parse максимально тупым: «10 WORD header, затем
ровно size-10 WORD data», без сканирования payload.
