# MIC-185 RunTime audit — 2026-07-24

См. также: skill [runtime-programming](file:///C:/Users/User/.cursor/skills/runtime-programming/SKILL.md),
AGrav [Код_Стандарты](file:///D:/works/AGrav/00_Система/Код_Стандарты.md),
[Потоки_и_Память](file:///D:/works/AGrav/10_Работа/Программирование/Методологии/Потоки_и_Память.md).

## Цепочка сбора (как есть)

```
Start / Preview
  → PrepareHardware / ApplyChannelProgramSettings  (OK: config phase)
  → worker DoTick loop
       → fDevice.ReadBlock
            → TCP ReadMeasDataBlock
            → SetLength(ABlock.Values) + поэлементное копирование  ← RunTime alloc
       → PublishMeasurementBlock
            → SetLength(lTimes/lValues)                             ← RunTime alloc
            → поэлементный lTimes[J]                                ← лишняя ось X
            → BuildSourceProgramSettings (64 ch + JSON)             ← config в тике
            → FindByName × N + ConvertValue × N×Samples
            → AddBlockSamples → ещё SetLength внутри registry
            → FindByName × N + PublishBlockNotifications × N
            → PublishAuxChannels (temp/UTS, одно время на блок)
```

## Комментарии в коде → вердикт

| Комментарий (смысл) | Место | Вердикт | Severity |
|---|---|---|---|
| «зачем в RunTime SetLength» | `PublishMeasurementBlock` | Подтверждено: аллокация каждый блок | Critical |
| «нельзя формировать времена X для каждой точки» | тот же | Подтверждено: для равномерного блока достаточно `FirstTimeSec` + `SampleRateHz` | High |
| «BuildSourceProgramSettings не место в RunTime» | тот же | Подтверждено: это сборка config snapshot; место — Prepare/Program | Critical |
| «хранить массив ссылок на теги» | цикл каналов | Подтверждено: `FindByName` в hot path | High |
| «линейную ГХ один раз / блоком» | ConvertValue loop | Подтверждено как цель оптимизации | Medium (perf) |
| «ток только если не коды/мВ» | PowerMa | Логика уже частично есть; держать вне внутреннего sample-loop | Medium |
| «одна общая нотификация» | второй цикл | Подтверждено: N notify + повторный FindByName | High |
| «время у блока, не у каждого отсчёта» | Aux + times | Подтверждено для 1D | High |

Дополнительно вне комментариев, но в том же hot path:

| Находка | Место | Severity |
|---|---|---|
| `SetLength(ABlock.Values[I])` + nested copy | `TRecorderMic185Device.ReadBlock` | Critical |
| `SetLength(fLastTempValues)` при каждом temp-блоке | `ReadBlock` | Medium |
| `AddBlockSamples` / `AddSamples` делают `SetLength` last-block + copy | `uRecorderTags` | High (общий слой) |

## Соответствие AGrav

AGrav требует:

- В RunTime память не выделять; выделять заранее по априорным данным.
- Clear > Recreate.
- Состояние потока менять только из потока.
- UI не перерисовывать на каждый блок — по таймеру.
- Избегать поэлементных циклов там, где возможен `Move`/блочная математика.

Текущий MIC-185 **нарушает** первые два правила в `ReadBlock` + `PublishMeasurementBlock`.
Протокол TCP / single-client / runtime busy registry — отдельный слой и здесь не ломается;
проблема именно **стоимость пути данных после приёма кадра**.

## Рекомендуемый целевой дизайн (без правки сейчас)

1. **Prepare/Start**
   - кэш `fChannelSettings: TMic185ChannelProgramSettingsArray`;
   - кэш `fChannelTags: array of TRecorderTag` (+ convert coeffs `a,b` если линейная ГХ);
   - prealloc `fBlockValues[ch][sample]`, `fPublishValues[sample]` с Capacity ≥ max block;
   - при необходимости один раз `EnsureTagSignalBufferCapacities`.
2. **ReadBlock**
   - писать в preallocated `fReadBlock`; `Move` из raw float; без `SetLength` если вмещается.
3. **Publish**
   - не строить `lTimes[]`; передавать в registry/`AddSamples` метаданные блока
     (`x0`, `dx`, `count`) **или** пока API требует массив времён — заполнять
     prealloc `fTimes` только при resize вверх (временный компромисс до смены API).
   - convert: если коды/мВ — `Move`; если линейная ГХ — scale массива; иначе fallback поэлементно.
   - одна нотификация «source block ready» / один проход по кэшу тегов без FindByName.
4. **Config change** (диалог OK) → invalidate cache → rebuild вне опроса или после Stop.

## Что не трогать без отдельной задачи

- `uRecorderMic185Runtime` (busy/TCP registry) — уже защищает от второго сокета.
- Probe серийника/версии вне live session.
- Протокол Mebius IOCTL/measurement framing.

## Статус

Аудит зафиксирован. Рефакторинг hot path — отдельная задача; skill
`runtime-programming` должен блокировать повторение этих ошибок в новых правках.
