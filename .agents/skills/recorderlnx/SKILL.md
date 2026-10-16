---
name: recorderlnx
description: Build, debug, and extend the cross-platform Lazarus RecorderLnx app in OburecGH. Use when working on RecorderLnx, MIC-140, tags/notify, spectrum, settings dialogs, RecorderTests, or when comparing behavior with the original Windows Recorder in windev-v3.9.
---

# RecorderLnx

## Paths

| What | Path |
| --- | --- |
| Project root | `D:\works\OburecGH\Lazarus\RecorderLnx` |
| Core | `RecorderLnx\Core\` |
| UI | `RecorderLnx\UI\` |
| Project docs | `RecorderLnx\Docs\` |
| Session memory | `RecorderLnx\cach\` (`plan.md`, `notes_last_state.md`) |
| Console tests | `D:\works\OburecGH\Lazarus\Tests\RecorderTests\` |
| Shared utils | `D:\works\OburecGH\Lazarus\SharedUtils\` |
| Original Recorder | `D:\works\windev-v3.9` — priority dirs: `rc_*`, `mr` |
| Windows Recorder (installed) | `C:\Program Files (x86)\Mera\Recorder\Recorder.exe` — launch for captures/comparison; do not ask the user for the path |
| AGrav project mirror | `D:\works\AGrav\20_Проекты\Разработка_Delphi\Lazarus\RecorderLnx\` |
| AGrav system rules | `D:\works\AGrav\00_Система\` |

Main project file: `RecorderLnx.lpi`. Entry: `RecorderLnx.lpr`.

## Session startup

Before any task:

1. Read `cach/plan.md` and `cach/notes_last_state.md`.
2. Read `Docs/development-rules.md` when touching architecture, encoding, threads, or UI contracts.
3. For behavior that must match original Recorder, read `Docs/current-plan.md` and check `windev-v3.9` (or AGrav `Docs/08_Карта_Исходников_Оригинального_Recorder.md`) before coding.
4. For device/protocol work, check `Docs/mic140_protocol.md`, `Docs/data_sources_architecture.md`, and related notes in `Docs/`.

After meaningful work:

- Update `cach/notes_last_state.md` (prompt summary + solution).
- Mark done items in `cach/plan.md`.
- Put durable architecture/protocol knowledge in `Docs/`, not only in chat.

Answer in Russian unless the user asks otherwise.

## Build and verify (обязательно)

**Не отдавать задачу как выполненную, пока проект не собирается.** Любые правки `.pas` / `.lfm` / `.lpi` завершаются проверкой сборки затронутых целей; при ошибках — исправить и пересобрать до успеха.

Compiler: `C:\lazarus\lazbuild.exe` (FPC 3.2.2). Always rebuild after Pascal edits when stale `.ppu` is possible.

```powershell
# Main app (Windows) — обязательно после изменений в RecorderLnx
C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi

# Example test — если менялись затронутые модули
C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\RecorderDataSourcesTest.lpi
```

Перед ответом пользователю:

1. Запустить `lazbuild -B` для каждого изменённого `.lpi` (минимум `RecorderLnx.lpi`).
2. Убедиться, что **exit code = 0** (hints/warnings допустимы, errors — нет).
3. Если exe заблокирован запущенным процессом — сообщить пользователю закрыть приложение и повторить сборку; не считать задачу готовой.
4. В отчёте явно указать: «сборка OK» или перечислить оставшиеся ошибки компиляции.

Cross-platform rule: no Windows-only APIs in `Core/` without abstraction. UI is LCL only. Linux build target must stay compilable from the same sources (`lib/x86_64-linux` artifacts already exist). On Linux use system `lazbuild` the same way.

Debug logs: `LogWindows.log` / `LogLinux.log` via `uRecorderDebugLog.pas`.

## Original Recorder comparison

Do not ask where the original sources are.

### Semantic-first source lookup

For original Recorder behavior, start with the Qdrant MCP tool
`search_original_recorder_sources` using a natural-language description plus
known class, method, tag-property, protocol, or UI terms. Request 5-12 results.
Then open the returned absolute paths at `line_start`/`line_end` and verify the
full call chain with `rg` and targeted reads. Embeddings are a navigation aid,
not evidence by themselves: never state original behavior without checking the
primary source text. If the MCP tool is unavailable, report that once and use
the same narrow `rg` workflow. After an intentional update of the immutable
`windev-v3.9` reference tree, run `sync_original_recorder_sources`; ordinary
RecorderLnx edits do not require reindexing the original tree.

When changing recording, tags, notify, plugins, devices, state machine, forms, or toolbar behavior:

1. Find the equivalent in `windev-v3.9` (`mr`, `rc_core`, `rc_guisrv`, `recorder`).
2. Extract intent (lifecycle, names, data flow), not COM/MFC/DLL details.
3. Implement in Lazarus/FPC with LCL and project interfaces.

Useful AGrav maps:

- `08_Карта_Исходников_Оригинального_Recorder.md` — where to look in windev
- `06_Идеи_из_руководства_Recorder.md`, `07_UI_Ориентир_Recorder.md`
- Project docs: `original-recorder-trend-component.md`, `original-recorder-block-recording.md`

## Architecture rules (short)

Full rules: `Docs/development-rules.md`. Key markers:

| Marker | Meaning |
| --- | --- |
| `RLNX_COLLAB_BEFORE_CODE` | Agree behavior/tests before coding |
| `RLNX_CORE_FIRST_FLOW_2026_05_25` | Core → minimal observe UI → tests → config → settings UI |
| `RLNX_TAG_DATA_FLOW_2026_05_25` | Data via tags + notify; forms are not domain sources |
| `RLNX_FILE_UPDATE_SAFETY_2026_05_25` | Edit working files only; verify mtime; `lazbuild -B` |
| `RLNX_CROSSPLATFORM_PLUGINS` | Plugins via DynLibs + flat C API |

Data path: devices/plugins → tags → notify → form/chart components. UI refresh ~5 Hz (200 ms), not on every sample.

Threads: no heavy I/O on GUI thread; no runtime allocation in hot paths; preallocate buffers; change thread state from inside the thread.

## Encoding (critical)

Before editing `*.pas` / `*.lfm` with Russian text:

- Check file bytes and `{$codepage ...}` directive — they must match.
- Many UI units use **cp1251** + `CP1251ToUTF8()` for LCL string properties in code.
- Never rewrite whole units via default text writers after patch failures.
- **Never use Python or shell scripts to edit `.pas`/`.lfm`** — breaks encoding.

After UI/encoding edits: rebuild and verify Cyrillic is not `????`.

## Naming (AGrav / project standard)

- locals: `lName`
- globals: `g_Name` (rare)
- private/protected fields: `fName`
- classes: `T...`, interfaces: `I...`
- mode: `{$mode objfpc}{$H+}`

## Tests

Location: `Tests/RecorderTests/<area>/`. Before adding a test, agree type with user (`RLNX_TEST_TYPE_AGREEMENT_2026_05_25`). Console tests should log `RESULT ... passed` and write a `.log` beside the exe.

Relevant test projects: Tags, DataSources, StateMachine, CoreServices, Storage, FormModel, EventQueue, TimeSystem, Math.

### Standalone protocol references

When a device debug/test project is declared independent, golden, reference, or
intended to preserve a known protocol state:

- Never reference mutable source units, PPUs, DLLs, resources, or output
  directories of RecorderLnx, SharedUtils, or another working project.
- Vendor the minimal required source/resource closure inside the reference
  project's directory and record its provenance/snapshot.
- Use a dedicated clean unit-output directory so stale PPUs cannot hide missing
  dependencies.
- Audit `.lpi`, `.lpr`, `uses`, include directives, and resource paths for
  paths outside the reference directory.
- Required acceptance test: copy the whole reference project to an unrelated
  temporary directory and run `lazbuild -B` there. A build in its original
  tree alone does not prove independence.
- Do not silently update the vendored protocol implementation when the main
  driver changes. Treat changes to the reference snapshot as explicit,
  reviewed protocol-baseline changes.

Project marker: `RLNX_STANDALONE_PROTOCOL_REFERENCE_2026_07_28`.

### Unified GUI/CLI test entry

For hardware and protocol diagnostic applications, keep GUI and CLI in the
same Lazarus project and executable:

- both entry modes must call one shared lifecycle/test scenario and the same
  vendored driver objects;
- CLI may only provide parameters, automatic start/stop, reporting, and exit;
  it must not contain a separate protocol implementation or alternate setup;
- verify both modes after protocol changes: run the CLI scenario unattended,
  then run the ordinary GUI path and start it through the same public action;
- compare their lifecycle/config signatures in the common log. A CLI-only
  success does not prove that the GUI application works.

Project marker: `RLNX_UNIFIED_GUI_CLI_TEST_2026_07_28`.

## Related skills

- `lazarus-native-apps` — general Lazarus/FPC patterns
- `lazarus-lcl-ui` — forms, `.lfm`, dialogs, layout
- `lazarus-integrations` — TCP, devices, external libs
- `agrav-knowledge-base` — update AGrav when durable cross-project knowledge changes

## AGrav sync

Project-specific knowledge lives primarily in `RecorderLnx/Docs/` and `cach/`. Update AGrav (`20_Проекты/.../RecorderLnx`, `90_Архив/История_изменений.md`) for significant cross-session decisions the user expects in the vault.

## Error investigation journal

When solving a bug, crash, build failure, regression, encoding issue, device/protocol issue, or recurring suspicious behavior:

1. **Do not wait for the user** — сам запускай логирование, воспроизведение и итерации по исправлению до стабильного результата или явного блокера.
2. Before forming new hypotheses, inspect `D:\works\OburecGH\Lazarus\RecorderLnx\errors\` for related symptoms, modules, log text, and error messages.
3. Continue the existing Markdown file when the symptom is the same or clearly related; create `YYYY-MM-DD-short-error-slug.md` only for a distinct error.
4. Record confirmed facts, checked hypotheses, commands/tests/logs/code locations used for verification, actions taken, and the observed effect after each meaningful change.
5. Keep rejected hypotheses in the file so future sessions do not repeat the same checks.
6. On completion, record root cause, final fix, verification result, and remaining risk.
7. For device/TCP issues: check `LogWindows.log` / `LogLinux.log` and device-specific logs (e.g. MIC185 lines in `RecorderMic185Log`); compare with a working client if needed.

Use `errors/README.md` as the template. Keep `cach/notes_last_state.md` for the short session summary; keep detailed debugging history in `errors/`.

## Network equipment: control packet captures

When debugging MIC-140 or any TCP/UDP device protocol:

1. Capture reference traffic from the **working client** (Windows Recorder) before changing the driver.
2. Windows Recorder path: `C:\Program Files (x86)\Mera\Recorder\Recorder.exe` (launch directly; do not ask the user).
3. Filter by **device IP** and port (`192.168.14.155:4000` on the stand).
3. Tools: `Mic140ProtocolDebugCli.exe --proxy 4001`, `Tests/Mic140ProtocolDebug/Tools/mic140_capture_start.ps1`, or Wireshark/tshark.
4. Store dumps under `Tests/Mic140ProtocolDebug/Data/captures/`; compare `stride`, `msgWords`, AIn/TIn codes with the stand log.
5. Cursor rule: `.cursor/rules/network-sniff-control.mdc`.
