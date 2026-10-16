---
name: lazarus-native-apps
description: Build, maintain, debug, and structure native desktop applications with Lazarus IDE, Free Pascal, Object Pascal, LCL/FCL, .lpi/.lpr/.pas/.lfm projects, cross-platform Windows/Linux/macOS builds, packages, resources, compiler modes, and AGrav Delphi/Lazarus standards. Use for any native app work where Lazarus or FPC is the target stack.
---

# Lazarus Native Apps

## First Moves

Use this skill for Lazarus/FPC native desktop work. Start by reading the local project shape before editing:
- `*.lpi` project metadata
- `*.lpr` program entry point
- `*.pas` units
- `*.lfm` form resources
- package files such as `*.lpk`
- existing `cach/plan.md`, `docs/`, and AGrav notes when present

For current API details, query Context7 before relying on memory:
- Resolve/query `/fpc/fpcdocumentation` for FPC, units, classes, threading, streams, strings, exceptions, and compiler behavior.
- Resolve Lazarus-adjacent libraries only when needed: CEF4Delphi, ZeosLib, RESTRequest4Delphi.

## Project Structure

Keep native apps boring and inspectable:
- Put application startup in `.lpr`; avoid business logic there.
- Keep forms thin: UI event handlers call service/model units instead of doing heavy work directly.
- Separate reusable logic into units with explicit responsibilities: `uMain`, `uTypes`, `uConfig`, `uLogger`, `uServices`, `uData`, etc., following the project's existing naming style.
- Keep generated or designer-owned `.lfm` changes consistent with the corresponding `.pas` form class.
- Add a one-click start/build script when creating a project, following AGrav's One-Click Start rule.

## Lazarus Encoding Safety

Before editing Pascal/LCL files, inspect the file bytes and the `{$codepage ...}` directive. Preserve the existing encoding unless the task explicitly requires conversion. If a unit contains Russian UI captions or comments, the file encoding and directive must match: UTF-8 files use `{$codepage UTF8}`, Windows-1251 files use `{$codepage cp1251}`. Never rewrite a whole unit through a default text writer after `apply_patch` fails on encoding; use an explicit encoding-preserving edit or deliberately convert the whole unit and update the directive in the same change. After encoding-sensitive UI changes, rebuild and verify Cyrillic captions are not rendered as `????`.
## Object Pascal Defaults

Prefer `{$mode objfpc}{$H+}` for new Lazarus/FPC code unless the existing project uses Delphi mode. Do not mix modes casually.

Use core units intentionally:
- `SysUtils` for exceptions, formatting, paths, date/time, conversions.
- `Classes` for `TComponent`, `TStringList`, `TList`, streams, collections, and `TThread`.
- `Contnrs`/generics only when already used or clearly beneficial.
- `LCLIntf`, `LCLType`, `Forms`, `Controls`, `StdCtrls`, etc. for UI-specific code.

## Memory And Lifetime

Follow the owner model:
- Components placed on forms are usually owned by the form; avoid freeing them manually.
- Objects created with `Create(nil)` or no owner must be freed in `finally` or by a clearly documented owner.
- Use `try/finally` around every manual allocation that can raise after allocation.
- Prefer clearing and reusing long-lived objects in hot paths when the AGrav project standard asks for it.

Example pattern:

```pascal
var
  lList: TStringList;
begin
  lList := TStringList.Create;
  try
    lList.LoadFromFile(AFileName);
    ProcessList(lList);
  finally
    lList.Free;
  end;
end;
```

## Threading And Responsiveness

Never block the GUI thread with slow I/O, long calculations, database work, network calls, or sleeps.

Use `TThread` or task-like wrappers for background work:
- Check `Terminated` inside loops.
- Use `Synchronize` or `Queue` for UI updates.
- On Unix targets, ensure thread support is initialized when relevant, commonly with `cthreads` early in the program.
- Do not mutate UI controls directly from worker threads.


## RecorderLnx Original Recorder Reference

When working on RecorderLnx behavior that must match the original Recorder, do not ask the user where the original sources are. Inspect the original Recorder under `D:\works\windev-v3.9\..` first, prioritizing directories named `rc_*` and `mr`.
## Build And Verification

**Не отдавать задачу как выполненную, пока изменённый `.lpi` не собирается без ошибок.**

1. После правок Pascal/LCL — `lazbuild -B <project>.lpi` (на Windows часто `C:\lazarus\lazbuild.exe`).
2. Exit code **0** обязателен; errors исправить до ответа пользователю.
3. Если exe заблокирован запущенным процессом — закрыть приложение и пересобрать.
4. В отчёте явно указать «сборка OK» или перечислить ошибки.

Prefer the project's existing build path. For new features, add a small test, demo path, or deterministic manual verification note when tests are in scope.

When debugging hard failures, use temporary high-resolution logs around the suspect code and remove them after the fix is verified.