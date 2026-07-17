# MC-201: аппаратная балансировка нуля и мультипрограммирование ЦАП

См. также: [CHANGELOG.md](../../../CHANGELOG.md),  
[errors/2026-07-17-mc201-soft-stop-kills-commands.md](../../../errors/2026-07-17-mc201-soft-stop-kills-commands.md),  
[recorderlnx-integration.md](recorderlnx-integration.md).

Дата фиксации рабочего сценария: **2026-07-17** (стенд MC-032 + 4×MC-201).

## Цель

Параллельно сбалансировать много каналов MC-201: один общий prepare/collect,
расчёт кодов балансировочного ЦАП, затем запись кодов в железо и возврат в
просмотр — без зависаний UI и без «убийства» контроллера.

## Оригинал (windev `mtc/Mc201.cpp`)

| Что | Как в оригинале |
| --- | --- |
| Команда | `SEND_BALANCE_CC = 53`, аргументы `[chan, lo, hi]` (biased 0…255) |
| Алгоритм | `ZBalance` / `ChanCalibrFullSingleScan` — **по одному каналу**, обычно через `CSingleScan`, не через длительный `STARTSCANMAIN` |
| Запись всех ЦАП | `ModuleMC201::Programming()`: сначала модульный `CMD_STOP_SCAN`, затем цикл `SendBalanceDAC` по каналам |
| PlayDAC | `PauseTimer` / `RestoreTimer` — только для ЦАП воспроизведения, **не** для ADC-потока `STARTSCANMAIN` |

В RecorderLnx нет полного порта `CSingleScan`; мультибаланс сделан поверх
служебного `StartRawScan` + `CollectChannelsMean`.

## Рабочий конвейер RecorderLnx

Код: `TRecorderMcbusDevice.BalanceChannelsHardware`  
(`Device/MCbus/uRecorderMcbusDevice.pas`), остановка после плотного потока —
`TMc032Device.StopAfterHeavyStream` (`uMc032Device.pas`).

```text
1) prepare
   Stop (обычный CallCommand STOPSCANMAIN)
   → SEND_BALANCE $8080 на все целевые каналы
   → StartRawScan

2) settle
   ~1 с ReadRawMessage discard (прогрев, RX не копится)

3) collect
   CollectChannelsMean: параллельный набор отсчётов по Fs канала
   (квота ~6% Fs, cap 2048; канал без данных — SKIP)

4) stop-before-compute   ← критично
   StopAfterHeavyStream сразу после collect, ДО расчёта/длинного лога

5) compute
   mean → код ЦАП (формула стенда deltaADC ≈ -2.8*(lo-128)*(hi-128))
   soft: fBalanceDac + BalanceDac[range] в fConfig

6) apply
   TryApplySavedBalanceDac  (= Programming: SEND по всем каналам устройства)
   → StartRawScan
   → ResumeStreamingReader просмотра
```

Программирование ЦАП после сбора — это **не** полный `ProgramDevice` /
`RESETSCANMAIN` (после heavy stream он стабильно ловит `MDP command timeout`).
Это цикл `SEND_BALANCE_CC` на **уже остановленной** шине, как идея
`Programming()` в оригинале.

## StopAfterHeavyStream — как останавливать после dense collect

Обычный Preview `Stop` рассчитан на короткий RX-хвост (ReadBlock постоянно
дренирует TCP). После `CollectChannelsMean` хвост плотный: `CallCommand(STOP)`
часто не находит reply за 3–15 с.

Рабочая стратегия:

1. Сначала `CallCommand(STOPSCANMAIN)` с timeout ≥ 3 с (как prepare).  
   Если reply пришёл — сессия здоровая, дальше SEND как после обычного Stop.
2. Иначе `SendCommandNoWait(STOP)` + drain до тишины ≥ ~400 мс.  
   **`quiet=True` достаточно для успеха**, даже если `ack=0`.  
   Fire-and-forget STOP часто **не** отдаёт пакет `CMc201MdpStreamCommand`.
3. **Не** слать второй `CallCommand(STOP)` после quiet — контроллер уже молчит,
   повторный STOP даёт `MDP command timeout` и оставляет шину «глухой» для SEND.
4. **Не** делать `ForceDisconnect` в apply — после обрыва TCP контроллер
   часто «умирает» до сброса оригинальным Recorder.

Порядок **stop сразу после collect** обязателен: пауза на compute/лог копит
очередь RX; тогда даже правильный Stop реже успевает получить reply.

## Что проверено стендом (не делать)

| Подход | Результат |
| --- | --- |
| `ProgramDevice` / `RESETSCANMAIN` в конце multi | timeout |
| `ForceDisconnect` + reconnect + Config | контроллер мёртв до сброса оригиналом |
| Soft-STOP + второй sync STOP | глухая шина |
| Требовать command-port ACK после no-wait | ложный fail при `quiet=True` |
| `SEND_BALANCE` **в** живом `STARTSCANMAIN` (без PauseTimer) | диалог висит (reply не находится в data-port) |
| Менять `CallCommand` на short-poll | ломает обычный Preview (`scan started`, нет `[MCBUS] block`) |

`TimeoutMs` контроллера обязан писать и в `fClient` (`SetTimeoutMs`), иначе
apply думает, что поднял timeout, а MDP-клиент остаётся со старым.

## Soft-config и просмотр

- Коды пишутся в `fBalanceDac` и `CFG … dNrR=…` (разделитель `;`, не `,`).
- Перед каждым `STARTSCANMAIN` путь `Start` вызывает `ApplySavedBalanceDac`
  (регистры ЦАП после STOP не гарантированы).
- Диалог слота / снимок multi-balance должен сохранять коды так же, как
  runtime их читает при следующем `ProgramDevice`.

## Лог успеха (ориентир)

```text
phase prepare: Stop + SEND $8080 all + Start
phase settle: 1000 ms warmup discard
phase collect
CollectChannelsMean done: ok=N/N …
phase stop-before-compute: StopAfterHeavyStream
  → CallCommand STOP ok
  или drained=… ack=0|N quiet=True
phase compute
  ch=… mean=… code=$….
phase apply: SEND + StartRawScan
apply: TryApplySavedBalanceDac
apply: StartRawScan
BalanceChannelsHardware OK programmed=…
```

## Файлы

| Файл | Роль |
| --- | --- |
| `Device/MCbus/uRecorderMcbusDevice.pas` | `BalanceChannelsHardware`, `TryApplySavedBalanceDac`, `CollectChannelsMean` |
| `Device/MCbus/uMc032Device.pas` | `Stop`, `StopAfterHeavyStream`, `SendBalanceDac`, `StartRawScan` |
| `Device/MCbus/uRecorderMcbusDataSource.pas` | `ZeroBalanceTags`, пауза/resume reader, StoreBalanceDac |
| `Device/MCbus/uMc201LegacyMdpClient.pas` | `CallCommand` — не ломать classic-ожидание reply |

## Краткие правила для агентов

1. После dense collect — `StopAfterHeavyStream`, не Preview-`Stop` «наугад» и не RESET.
2. Stop **до** compute; quiet без ACK — OK; второй STOP после quiet — запрещён.
3. Apply = `TryApplySavedBalanceDac` + `StartRawScan`, не полный Config.
4. Не SEND в ADC-потоке; не ForceDisconnect в apply; не short-poll `CallCommand`.
