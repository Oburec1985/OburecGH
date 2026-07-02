# 1. Транспорт MDP (mdpEthernet81)

Обмен — **TCP**, порт **4000**. Все поля — **little-endian**, размерность в **16-битных словах** (`Word`).

## 1.1. Заголовок кадра

| Поле | Тип | Описание |
|------|-----|----------|
| SYNC | `uint16` | Всегда `0x12B8` |
| PORT | `uint16` | `0` — поток измерений, `1` — команды/ответы |
| SIZE | `uint16` | Длина Payload в словах |
| HCS | `uint16` | `(SYNC + PORT + SIZE) mod 65536` |
| PAYLOAD | `uint16[SIZE]` | Тело |
| DCS | `uint16` | Сумма слов Payload mod 65536 |

Код: `uRecorderMic140v2Protocol.TMic140v2Tcp`.

## 1.2. Поток команд (PORT=1)

Первое слово Payload — код команды BIOS (`CMD_*`). Ответы приходят в том же потоке.

Типовые коды (см. [03_scan_programming.md](03_scan_programming.md)):

| CMD | Значение | Назначение |
|-----|----------|------------|
| STARTSCANMAIN | 80 | Старт скана |
| APPENDSCANMAIN | 82 | Создать контекст скана |
| RESETSCANMAIN | 83 | Сброс |
| CONFIGSCANMAIN | 84 | Таймер кадра |
| SETSTATESCAN | 87 | Состояние FSM |
| WRITEDM | 111 | Запись DM ADSP |
| SCAN_SET_CHANS | 132 | Привязать каналы |
| SCAN_SET_BUFF | 133 | FIFO буфер |
| ADDCHANNELMODULE | 152 | Модуль MIC-140 |

## 1.3. Поток данных (PORT=0)

Непрерывные кадры после `STARTSCANMAIN`. Структура — [05_data_stream.md](05_data_stream.md).

## 1.4. Восстановление синхронизации

При неверном SYNC или контрольной сумме — сдвиг **на 1 байт**, повторный поиск `0x12B8`.
Нельзя отбрасывать большие фрагменты буфера: теряется выравнивание, растёт `mdpResync`.

Правило зафиксировано в [../acquisition_rules.md](../acquisition_rules.md) §1.
