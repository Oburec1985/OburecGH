# MIC140v2

Новая реализация MIC-140 по [device_abstraction.md](../../Docs/devices/device_abstraction.md),
[protocol.md](../../Docs/devices/mic140/protocol.md) и
[acquisition_rules.md](../../Docs/devices/mic140/acquisition_rules.md).

`Device/MIC140/` не удаляем — исправления обмена по мере необходимости.

## Модули

| Unit | Назначение |
|------|------------|
| `uRecorderMic140v2Types.pas` | Подсостояния драйвера, параметры создания |
| `uRecorderMic140v2Device.pas` | `IRecorderDevice` — этапы связи / настройки / опроса |
| *(план)* `uRecorderMic140v2Transport.pas` | TCP + MDP, побайтовый resync |
| *(план)* `uRecorderMic140v2Workers.pas` | Потоки чтения и разбора |

## Общие компоненты (Device/)

| Unit | Назначение |
|------|------------|
| `uRecorderAcquirePhase.pas` | Этапы захвата + базовые интервалы ожидания |
| `uRecorderMic140AcquireTiming.pas` | Тайминги MIC-140 (наследник базового) |
| `uRecorderMic140RawRing.pas` | Кольцо 8+ слотов сырых кадров (**обязательно в v2**) |

## Статус

- [x] Каркас `TRecorderMic140v2Device`
- [x] Документация правил приёма (`acquisition_rules.md`)
- [x] Базовая машина этапов `TRecorderAcquirePhaseFsm`
- [x] `TMic140RawBlockRing` (модуль готов, подключение в v2 — следующий шаг)
- [ ] Transport: legacy client + resync §1
- [ ] Workers: read → ring → publish, один `AcquirePacingMs` §4
- [ ] Подключение в источник данных
- [ ] `mic140_preview_eval.ps1`

## Следующий шаг

`uRecorderMic140v2Workers.pas`: поток чтения пишет в `TMic140RawBlockRing`, поток разбора
читает слоты; pacing только через `fStreamFsm.AcquirePacingMs`.

См. [migration_mic140v2.md](../../Docs/devices/migration_mic140v2.md).
