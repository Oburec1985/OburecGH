# Перенос полезных модулей Delphi SharedUtils в Lazarus

Источник: `D:\works\OburecGH\sharedUtils`.
Цель: `D:\works\OburecGH\Lazarus\SharedUtils`.

Перенос выполняется по ответственности, а не копированием каталогов. Windows,
VCL, COM, shell и сторонние библиотеки отделяются от чистой логики. Каждый этап
получает отдельную сборку и тесты.

## Этап 1 — чистые базовые библиотеки

- [x] `uSharedStatistics`: устойчивые среднее, дисперсия, СКО, ковариация,
  корреляция и summary вместо ошибочных частей Delphi `uMyMath`.
- [x] `uSharedBinaryIO`: строгий `TStream` API с явными размерами и endian,
  безопасными строками и контролем EOF вместо legacy `uBinFile`.
- [x] Исправить уже перенесённую convex-hull/diameter реализацию в `u2DMath`;
  Delphi `uGrahamScan*` отдельно не переносить.

## Этап 2 — алгоритмы по подтверждённой потребности

- [ ] Медиана и скользящий медианный фильтр с явно заданной политикой краёв и
  NaN; Delphi `MeedleFilter` не копировать, он незавершён.
- [ ] МНК/решение систем из `uMNK` — только после выбора численного контракта и
  сравнения с библиотеками FPC.
- [ ] Кроссплатформенный monotonic timer вместо двух Windows QPC units.
- [ ] Чистые filesystem helpers из `uPathMng`/`PathUtils`; destructive операции
  не переносить без отдельного безопасного контракта.

## Этап 3 — форматы и модели данных

- [ ] Выделить модель сигнала и codec MERA из `uMeraSignal/uBuffSignal/uMeraFile`,
  полностью отделив VCL/UI. Приёмка только по golden-файлам.
- [ ] Сопоставить `uSharedBinaryIO` с BLD/LFM codec и переносить legacy typed
  `TValueType` лишь после фиксации реальных файлов, включая историческую ошибку
  размера `vaInt16`.

## Не переносить как внутренний API

- JCL, TMSPack, FastMM, FastMath, ALGLIB, NativeXML, ZipMaster, FastReport,
  AlphaControls и их demos/design-time packages.
- Старые дубли логгеров, binary search и FFT, если современный Lazarus-аналог
  уже покрывает задачу.
- VCL-формы и shell-компоненты без выделенного кроссплатформенного контракта.
