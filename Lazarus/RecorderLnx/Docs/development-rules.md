# RecorderLnx Development Rules

Date: 2026-06-04

## Lazarus Source Encoding

- Before editing any `*.pas` or `*.lfm` file with Russian text, check the real
  file encoding and the Pascal directive near the top of the unit.
- The file bytes and the directive must match:
  `{$codepage UTF8}` for UTF-8 files, `{$codepage cp1251}` for Windows-1251
  files.
- Do not rewrite a whole Pascal unit through a default text writer unless the
  writer encoding is explicit. A silent encoding conversion can compile
  successfully but turn LCL captions and resources into `????`.
- For UTF-8 Lazarus UI units, save as UTF-8 and keep `{$codepage UTF8}`. This is
  required for runtime captions created in code, for example `TLabel.Caption`,
  `TTabSheet.Caption`, `TButton.Caption`, and dialog text.
- For legacy cp1251 units, either preserve cp1251 exactly or intentionally
  convert the whole unit to UTF-8 and update the directive in the same change.
- After any encoding-sensitive UI edit, rebuild with `lazbuild -B` and open the
  touched dialog/form once to verify Cyrillic captions are readable.
- При создании или изменении диалоговых окон и форм старайтесь проектировать их визуально через формы .lfm, а не создавать элементы интерфейса динамически в коде. Это упрощает их последующее редактирование и локализацию, а также предотвращает проблемы с кодировкой строк при ручном задании Caption в Pascal-коде.

## Safe Editing Practice

- Prefer narrow patches over whole-file rewrites.
- If `apply_patch` cannot read a Pascal unit because of encoding, do not blindly
  rewrite it. First inspect the current bytes/encoding, then choose an explicit
  encoding-preserving edit or a deliberate full conversion.
- When a UI exception points to a control field, verify that the field is
  actually created before use. Dynamically built LCL forms do not get designer
  initialization for undeclared controls.

## Safe Scripted Writes And Restores

- Before editing or restoring a tracked source file, check its current size and
  focused `git diff`.
- Do not test restore commands by redirecting output directly into the target
  file. Write to a temporary file first, verify it is non-empty, contains the
  expected key text, and has a plausible encoding, then replace the target.
- For Pascal/Lazarus files, preserve the existing encoding explicitly or perform
  a deliberate full-file conversion together with the matching `{$codepage ...}`
  directive change.
- After any scripted write, immediately inspect `git diff --stat` and the
  focused diff. If the diff looks like whole-file deletion, mojibake, or
  unrelated churn, stop and restore the file before continuing.

## Original Recorder Reference

- The original Recorder source tree is available under
  `D:\works\windev-v3.9\..`.
- For behavior that must match the original Recorder, inspect the `rc_*` and
  `mr` directories first.
- Do not ask the user where the original Recorder is for RecorderLnx
  compatibility work; use the path above.

## Правила рефакторинга и оптимизации кода

### 1. Эффективная работа с памятью и ресурсами
- **Избегать нерационального выделения памяти**: В критических путях выполнения, циклах и отрисовке сводить к минимуму частые аллокации (например, создание временных динамических массивов или объектов).
- **Не выделять память в реальном времени (RunTime в потоке)**: Вся рабочая память должна выделяться заранее на основе априорных данных.
- **Очищать объекты вместо пересоздания**: При смене состояния, старт/стопах или перезагрузке использовать методы очистки (`Clear`), а не уничтожать и создавать объекты заново, чтобы не поломать внешние ссылки на них.
- **Мапирование файлов**: При работе с большими файлами данных (сигналы, осциллограммы) использовать постраничное чтение или Memory Mapping вместо полной загрузки файлов в ОЗУ.

### 2. Структурирование и чистота кода
- **Устранение дублирования кода**: Если куски кода повторяются многократно, их необходимо выносить в отдельные процедуры или функции.
- **Именованные константы**: Избегать использования «магических» цифровых констант в коде. Все фиксированные значения выносить в именованные константы для удобства централизованного редактирования.
- **Локализационно-безопасный парсинг**: Числовой ввод (например, вещественные числа) обрабатывать с помощью универсальных парсеров, не зависящих от системных настроек разделителя целой и дробной части (точки или запятой).

### 3. Системное программирование и производительность
- **Избегание поэлементных циклов**: Стараться избегать циклов там, где можно использовать высокопроизводительные функции, выполняющиеся разово (например, копирование массивов через `Move`, быстрое чтение файлов через `BlockRead` или использование блочных операций чтения, вычисление суммы элементов через специализированные функции `Sum` вместо поэлементного суммирования в цикле). По возможности использовать аппаратно-ускоренные библиотеки (например, `uHardwareMath`, аналогичную той, что использовалась в Delphi-версии проекта и которую предстоит реализовать под Lazarus).
- **Исключение дедлоков потоков**: Проектировать и писать многопоточный код таким образом, чтобы взаимная блокировка потоков (deadlock) была невозможна даже теоретически (например, соблюдать строгий порядок захвата блокировок, минимизировать время нахождения в критической секции, избегать вложенных блокировок).
- **Предотвращение избыточной перерисовки UI**: Избегать частой перерисовки интерфейса при поступлении новых данных. Перерисовка должна выполняться по таймеру с фиксированной частотой обновления (например, 5 раз в секунду при периоде обновления 200 мс), а не инициироваться непосредственно при приеме порций данных.
- **Оптимизация рендеринга и отложенная сборка данных (Lazy Recompile)**: Анализировать процесс отрисовки и избегать избыточных расчетов перед выводом кадра. В графических подсистемах (например, OpenGL с использованием списков компиляции и пакетной отрисовки батчами) выполнять подготовку и сборку массивов данных только тогда, когда это действительно необходимо:
  - Выставлять инвалидирующий флаг (например, `needrecompile`) при изменении условий отрисовки: поступление новых данных, изменение масштаба отображения или изменение настроек шкалы (например, переключение флага логарифма).
  - Сборку данных и компиляцию графических структур производить непосредственно перед выводом кадра только при установленном флаге `needrecompile`, сбрасывая его по окончании сборки. Если флаг сброшен, повторно использовать ранее подготовленные структуры без перерасчета.
