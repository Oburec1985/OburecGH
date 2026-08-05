# Чистовой пайплайн расчета спектров

Документ фиксирует текущую лучшую практику для runtime-расчета спектров в RecorderLnx. Код-образец находится в:

`C:\Oburec\OburecGH\Lazarus\RecorderLnx\Tests\TestSpectrumMath\uBestSpectrumPipeline.pas`

## Цель

Реальный режим: до 128 независимых спектров на одном ПК, типовые размеры FFT `8192` и `16384`. Runtime-часть не должна строить планы, считать тригонометрию, создавать потоки или выделять память.

## BestInitProc

`BestInitProc` выполняется один раз при создании спектрального движка:

- проверяет, что размер FFT является степенью двойки;
- строит `BitReverse[]`;
- строит таблицу экспоненциальных множителей `Twiddle[] = exp(-i * 2*pi*k/N)`;
- строит окно Hann;
- выделяет выровненные рабочие буферы;
- создает постоянный пул потоков.

Это принципиально важно: `SinCos`, `SetLength`, `Create`, `GetMem` и создание потоков не должны попадать в runtime tick.

## BestEvalProc

`BestEvalProc` выполняет один спектр без аллокаций:

1. `MulFloat64To`: поэлементно умножает входной массив на заранее рассчитанное окно.
2. `PrepareBitReversedReal`: раскладывает real input в complex-буфер в bit-reversed порядке.
3. `FFTForwardPrecomputedInline`: выполняет прямой FFT с готовыми twiddle factors.
4. `EvalRmsAndNormalize`: считает RMS-амплитуды и опционально нормирует спектр.

Формула RMS для positive-frequency bins:

```text
RMS[k] = sqrt(Re[k]^2 + Im[k]^2) * sqrt(2) / N
```

Поддержанные режимы нормировки:

- `bnmNone` - физическая RMS-шкала;
- `bnmMax` - деление на максимум спектра;
- `bnmEnergy` - деление на `sqrt(sum(RMS^2))`.

## BestEvalBatchProc

`BestEvalBatchProc` принимает массивы указателей входов и выходов. Если потоков больше одного, независимые спектры распределяются по постоянному worker pool:

- потоки уже созданы в `BestInitProc`;
- на tick назначаются только диапазоны индексов;
- workers получают `start`;
- основной поток ждет `done`.

По последнему benchmark постоянный pool для 128 спектров:

- FFT 8192: около `3.738 ms` на 128 спектров;
- FFT 16384: около `9.216 ms` на 128 спектров.

## Почему выбран Pascal inline

Для FFT-only runtime сравнивались:

- Pascal precomputed;
- Pascal inline;
- SSE2 scalar asm;
- AVX scalar asm;
- AVX vector2 asm.

Текущий лучший общий вариант для чистового кода - `Pascal_Inline_Precomputed`: он стабилен, прост, хорошо компилируется FPC и быстрее scalar asm. AVX vector2 иногда выигрывает на отдельных размерах, но пока не дает устойчивого преимущества на всем диапазоне.

## Что улучшать дальше

- Перенести `uBestSpectrumPipeline.pas` из тестового проекта в общий math/core-модуль.
- Сделать отдельные рабочие буферы на worker, чтобы batch-обработка не делила один `FWork`.
- Добавить batch API с заранее закрепленными каналами и NUMA/cache-friendly раскладкой.
- Для настоящего AVX/AVX2 выигрыша перейти от AoS complex (`Re,Im`) к SoA или специализированной packed layout.
- AVX-512 через текущий FPC inline assembler недоступен; для него нужен внешний object/C ABI backend.

