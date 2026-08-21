# MIC-140 (документация по прибору)

Материалы по модулю MIC-140 в составе RecorderLnx: обмен с контроллером MC031,
настройка скана, приём блоков измерений.

## Документы

Главная точка входа для повторной реализации:

- [protocol/00_full_reproduction_spec.md](protocol/00_full_reproduction_spec.md) —
  транспорт, команды, ревизии, полный жизненный цикл, Config, форматы DM/FIFO,
  тайминги и формат потока на подтверждённом MIC-140-48v3.

| Файл | Содержание |
|------|------------|
| [protocol.md](protocol.md) | Краткое описание (устаревший монолит; см. [protocol/](protocol/)) |
| [protocol/](protocol/) | **Полное описание протокола** (MDP, коммутируемый АЦП, BIOS, приёмка) |
| [protocol/08_timing_and_count_aver.md](protocol/08_timing_and_count_aver.md) | Алгоритм таймингов: 640, 50 kHz, `PERIOD_TIMER_WORK`, расчёт `count_aver` |
| [acquisition_rules.md](acquisition_rules.md) | Правила приёма данных (resync, мусор, кольцо слотов, pacing) |
| [acceptance_tests.md](acceptance_tests.md) | Критерии успеха по логу: 3 проверки, прогоны 3/10/40 с |
| [migration_mic140v2.md](../migration_mic140v2.md) | Переход на реализацию `Device/MIC140v2` |

## Код

| Каталог | Назначение |
|---------|------------|
| `Device/MIC140/` | Рабочая реализация (поддержка, исправления обмена) |
| `Device/MIC140v2/` | Новая реализация по [device_abstraction.md](../device_abstraction.md) |
| `Tests/Mic140ProtocolDebug/` | Автономный стенд `Mic140Example` |

## Подробные материалы (архив)

Детальная отладка, история находок, длинные таблицы констант:

- [../../old/mic140_protocol.md](../../old/mic140_protocol.md)
- [../../old/mic140_legacy_scan_stream.md](../../old/mic140_legacy_scan_stream.md)
- [../../old/mic140_quickstart.md](../../old/mic140_quickstart.md)


**Задание**
Рабочий пример MIC-140:
d:\works\OburecGH\Lazarus\RecorderLnx\Tests\mic140\Mic140ProtocolDebug_Codex\.. 
Описание протокола
d:\works\OburecGH\Lazarus\RecorderLnx\Docs\devices\mic140\protocol\.. 

 Требуется вычистить все модули касающиеся MIC-140 из RecorderLnx (перенеси их из проекта, оставь чтоб можно  было подглядеть в папке backup). uRecorderMic140DeviceApi на уровне каталога Device - ошибка.
 Реализуй, используя рабочий пример как шпаргалку заново, коротки и чистовой протокол обмена с MIC-140:
- он должен реализовать жизненный цикл Connect>Init (разовые операции)>Config (переконфигурирование)>Play>Stop>Disconect;
- Пример должен быть простой и наглядный с комментами по коду, что для чего, отсылками на документацию;
- опереться надо на базовые интерфейсы;
- UI часть посмотреть в старом коде, который удаляем/ переносим из старой папки MIC-140 d:\works\OburecGH\Lazarus\RecorderLnx\Device\MIC140\.. 
- на уровне каталога Device предлагаю сделать универсальный DataThread который не будет привязан к конкретноу протоколу конкретного прибора. Этот универсальный поток должен уметь Create/ Destroy/ Config (перевыделение памяти и подготовка)/ Start/ Stop/ ReadBlock/ SendBlock/ OnStart и OnStop (разовые процедуры при старт стопе)/ Callback и т.д (возможно что-то еще надо смотреть реализацию MIC-140/MIC-185, возможно должны быть  другие универсальные). А на уровне каталога MIC сделать надо наследника этого потока.
- Сейчас в примере Codex не реализовано - UI аналогичный оригиналу, чтение ГХ перенос данных в теги и т.д. Это реализовано в текущем каталоге с MIC-140 (но там плохо работает сам протокол данные идут кривые).
 
