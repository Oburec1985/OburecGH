# RecorderLnx: current safe plan

Date: 2026-05-26

This note fixes the current working boundary. The original Recorder sources are
available locally and must be checked before changing Recorder-compatible
behavior.

Original Recorder location:

- root/search area: `D:\works\windev-v3.9\..`
- priority source directories: `rc_*` and `mr`

## Current local structure

- `RecorderLnx/Core` contains the current domain/core model:
  state machine, run-control settings, form model, event bus, tag registry,
  data sources, storage, event queue, and time system.
- `RecorderLnx/UI` contains the Lazarus UI shell, pages dialog, and form editor
  controller.
- `RecorderLnx/config` contains the local default app and run-control INI files.
- `Tests/RecorderTests` contains console tests/examples for the current
  RecorderLnx core modules.
- `SharedUtils` contains shared helper units and chart code.

## Safe work now

- UI-only improvements in `RecorderLnx/UI` that do not change core contracts:
  layout, captions, command button state, editor ergonomics, tag list display,
  page/dialog behavior, and visual polish.
- Developer configuration and documentation:
  project notes, test/build instructions, local config defaults, and cleanup of
  stale hard-coded paths in docs.
- Test harness improvements around existing behavior:
  scripts or notes for running the current `Tests/RecorderTests` examples,
  without redefining expected Recorder behavior from memory.
- Build hygiene:
  Lazarus project metadata, output folders, ignored generated files, and warning
  cleanup when the behavior is mechanically obvious.
- Source/resource encoding hygiene:
  follow `RecorderLnx/Docs/development-rules.md` before editing Lazarus UI
  units with Russian captions or `{$codepage ...}` directives.
- Mock/demo data used only for UI scaffolding, clearly separated from real
  Recorder devices, notify events, plugins, and acquisition logic.

## Work That Requires Original Recorder Check

- Recording/playback semantics, start/stop/trigger behavior, and state-machine
  changes that must match the original Recorder.
- Device, notify, plugin, channel, and external data acquisition integration.
- Storage format decisions that must remain compatible with real Recorder data.
- Time-source policy beyond the already isolated display model.
- Any migration logic or compatibility layer that depends on original Recorder
  naming, file layout, event order, or side effects.

For these tasks, inspect `D:\works\windev-v3.9\..\rc_*` and
`D:\works\windev-v3.9\..\mr` first instead of asking where the original Recorder
is located.

## Suggested next tasks

1. Review `RecorderLnx/UI/uMainForm.pas` for UI-only rough edges:
   disabled/enabled command states, empty tag-list states, captions, and dialog
   flow.
2. Keep a separate compatibility backlog for items verified against the original
   Recorder source.

## Done in this pass

- Added this safe-plan note.
- Updated `Tests/RecorderTests/README.md`.
- Added `Tests/RecorderTests/run-recorder-tests.ps1`.
- Verified `RecorderLnx` build with `C:\lazarus\lazbuild.exe`.
- Built and ran all current console `RecorderTests` with direct FPC.
