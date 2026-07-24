# Заметки по доработке жизненного цикла MIC-140

## Промпт:
Реализовать жизненный цикл MIC-140 через IDevice (Connect -> InitializeDevice -> ConfigureDevice -> Start -> Stop -> Disconnect) по аналогии с MIC-185, удалив старые некорректно работающие наработки.

## Анализ:
В `TRecorderMic185DataSource` опрос идет синхронно в `DoTick` через `fDevice.ReadBlock`, а жизненный цикл управляется в `PrepareHardware` и `Stop`.
В `TRecorderMic140DataSource` сейчас накручены фоновые потоки `TMic140BlockPublishThread` и `TMic140LegacyReadThread`, а также FSM, которые приводят к нестабильной работе.
В тесте `Mic140ProtocolDebug_Codex` используется метод `ReadBlock` напрямую на `TRecorderMic140v2Device`, и он работает корректно.
Поэтому мы перепишем `uRecorderMic140DataSource.pas`, удалив фоновые потоки и переведя логику на синхронный опрос в `DoTick` (как в `mic185`).
