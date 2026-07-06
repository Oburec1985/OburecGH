# 7. Приёмка (кратко)



Полная версия: [../acceptance_tests.md](../acceptance_tests.md).



**Стенд:** `192.168.14.155:4000`, rev 14.1, 48 AIn, 10 Гц, `DataUpdateMs=200`, `range=0`, `commut=0`.



## Критерии PASS



1. **Коды AIn 1..48 + TIn 1..3** — ±**50** от эталона `Tests/Mic140ProtocolDebug/Data/mic140_adc_reference.txt` (дамп Recorder 2026-06-22).

2. **Поток:** `corruptRead=0`, `readGaps=0`, `publishGaps=0`, `corruptPublish=0`, `codeViolations=0`.

3. **Число блоков:** `published` в диапазоне ~90–125% от `duration × 5` (≈5 блоков/с при 10 Гц и 200 ms); `published/read ≥ 85%`.



## Запуск



```powershell

cd D:\works\OburecGH\Lazarus\RecorderLnx\Tests\Mic140ProtocolDebug

C:\lazarus\lazbuild.exe Mic140ProtocolDebugCli.lpi

.\Mic140ProtocolDebugCli.exe --auto 10

```



GUI: `Mic140ProtocolDebug.exe` — таблица ADC, строки с совпадением ±50 подсвечиваются зелёным.



Код возврата `0` = PASS, `1` = FAIL.



## Профиль по умолчанию (2026-07-01)

| Параметр | Значение |
|----------|----------|
| `tin-slots` | 3 |
| `fifo-stride` | auto → **48** (TIn из DM); эксперимент Recorder: `--fifo-stride 51` |
| `bank2-delay-mul` | 6 |
| ground ptrs | выкл. (`MIC140_DEBUG_GROUND_POINTERS=0`) |

Сниффинг Recorder: `Mic140ProtocolDebugCli.exe --proxy 4001` — см. `Tests/Mic140ProtocolDebug/Docs/MIC140_STAND_GUIDE.md`.



## Статус сверки (rev 14.1, 2026-07-01)



| Область | Результат |

|---------|-----------|

| CH01–24 | стабильно **PASS** ±50 |
| TIn 1..3 | **PASS** ±50 (READMEMDM 114) |
| CH25–48 | **FAIL** (2-й банк ME048/задержки) |
| Поток 10 с | `read≈51`, `gaps=0`, `corrupt=0` — OK |
| `published` | 0 (строгая приёмка: нужны все 51 канала) |



Следующий шаг: чтение TIn из DM + корректная реализация `flag_chan_ground` (чередование ptr) без порчи 2-го банка — см. `MIC140_48mod.cpp` и `SCAN_ORIGIN.md`.

## Текущий вывод 2026-07-06

Для живой приемки 10 Гц используется устойчивый профиль `fifo=48`:

- `Fs=10.000 Hz`, `DataUpdateMs=200`, ожидаемо около `5` блоков/с;
- `FifoReadyWords=96`, `msgWords=106`;
- descriptor list резервирует нулевой ground descriptor (`reserveGroundDesc=True`), но не включает ground-pointer пары;
- TIn читается через `CMD_READMEMDM=114`;
- `--recorder-wire` остается диагностическим профилем для сверки с MDP-дампом Recorder (`stride=51`, `msgWords=163`), но не считается PASS, если дает read timeout, soft restart или неполное число блоков.

Приемочный PASS по-прежнему требует одновременно: `readGaps=0`,
`corruptRead=0`, `publishGaps=0`, `corruptPublish=0`, `codeViolations=0`,
`softRestart=0`, `published/read >= 85%`, и число опубликованных блоков в
диапазоне для `duration * 5`.

