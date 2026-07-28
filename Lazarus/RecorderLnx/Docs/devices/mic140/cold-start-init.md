# Холодная инициализация MIC-140-48v3

Эталон подтверждён сетевым дампом оригинального Recorder
`Tests/mic140/Mic140ProtocolDebug_Codex/data/captures/192.168.14.48_original_recorder_20260723_122408_packets.csv`.

В `InitializeDevice` один раз на новую TCP-сессию выполняется точная
последовательность:

```text
TEST_LOAD(32 нулевых WORD, ответ 2 WORD и reply[0] = 1)
REPLY(11 WORD firmware)
CMD_RESET
ожидание ответа RESET около 55 мс
REPLY(11 WORD firmware)
RESETSCANMAIN
ожидание готовности BIOS около 5 секунд
RESETSCANMAIN
STOPSCANMAIN
```

После этого начинается многократно допустимый `ConfigureDevice`. В него не
переносятся `TEST_LOAD`, `CMD_RESET` и пятисекундное ожидание.

Инвариант: первая штатная команда новой сессии — `TEST_LOAD` максимального
размера. В оригинальном `mdpEthernet81::CheckInitialized` она очищает
командный автомат после холодного запуска. Конфигурацию scan нельзя начинать
до второго `RESETSCANMAIN`: иначе контроллер способен выдать один оставшийся
FIFO-блок и остановить поток.

Проверка: в журнале холодного запуска должны последовательно присутствовать
`init TEST_LOAD: ready`, успешная повторная firmware-identification,
`initialized`, `scan programmed`, а за 8 секунд просмотра — существенно
больше одного блока без разрывов `num_buff`.
