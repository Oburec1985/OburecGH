# MIC185 GUI: падение после Start (2026-07-06)

## Симптом

После Start через некоторое время GUI падал или зависал.

## Гипотезы и результат

| # | Гипотеза | Статус |
|---|----------|--------|
| 1 | `ReadMeasDataBlock` читает до 64 пакетов с полным timeout 500 ms → накопление задержек / reentrancy | **Подтверждено** — pkts=64 на block 1 в логе до фикса |
| 2 | `Mic185Log` перезаписывал весь log-файл на каждую строку O(n²) | **Подтверждено** — при длинной сессии тормоза |
| 3 | `memLog` рос без лимита | **Вероятно** — исправлено cap 400 строк |
| 4 | `ShowMessage` + `btnStopClick` из `tmrAcquire` | **Вероятно** — убрано |
| 5 | Reentrancy таймера acquire | **Исправлено** — флаг `fAcquireBusy` |

## Исправления

- `ReadMeasDataBlock`: первый пакет — полный timeout, drain — 2 ms, max 32 пакета.
- `Mic185Log`: append в файл, буфер max 3000 строк.
- `Mic185LogPumpTo`: memo max 400 строк.
- `tmrAcquireTimer`: без ShowMessage, без btnStopClick, `fAcquireBusy`.
- `UpdateChannelGridFromBlock`: RecountMismatches раз в 10 блоков.

## Проверка

```bat
mic185_acquire_gui.exe --stress
```

120 с, ~1000 блоков, exit 0, лог `STRESS OK`.
