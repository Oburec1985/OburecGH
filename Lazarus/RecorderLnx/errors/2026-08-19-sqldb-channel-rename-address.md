# 2026-08-19 - SQLdb channel rename must preserve history by address

## Symptom

The SQL database used `signals.name` as the practical identity of a recorded
channel. If a RecorderLnx tag/channel is renamed, the next recording session can
create a new `signals` row, making it hard to understand that old and new names
refer to the same physical channel.

## Confirmed Facts

- `signal_values` already references `signals.id`, so historical samples do not
  need rewriting when metadata changes.
- Before this fix `TRecorderSqlDbRepository.EnsureSignal` searched by
  `object_id + name`.
- `TRecorderSqlDbManager.HandleEvent` receives the full `TRecorderTag`, so
  `SourceId`, `Address`, `Name`, and `UnitName` are available before enqueueing
  SQL jobs.
- `TRecorderTag.Address` is the stable channel address used by device sources
  (`156-1`, `42-1`, `diagnostics...`, etc.); `SourceId` distinguishes devices
  when addresses can overlap.

## Checked Hypotheses

- Keeping only `name` in `signals` is not sufficient: it changes when the user
  edits the channel name.
- Storing only `address` is close, but can collide between device sources; the
  stable lookup key should include `recorder_source_id + recorder_address`.
- Rewriting `signal_values` is unnecessary because values point to `signal_id`.

## Actions

- SQL schema version raised to 2.
- `signals` now has nullable `recorder_source_id` and `recorder_address`.
- `EnsureDatabase` migrates existing databases by adding those columns.
- Runtime SQL jobs carry tag `SourceId`, `Address`, and `UnitName`.
- `EnsureSignal` first searches by `object_id + recorder_source_id +
  recorder_address`; when found, it updates signal name/unit/binding instead of
  creating a new signal.
- Added a SQL settings button `Переименовать каналы`, which synchronizes current
  tag names into existing DB signals by stable address and fills address fields
  for old rows that still match by name.
- Fixed a compile error in `uRecorderSqlDbRuntime.pas`: internal SQL job field
  `UnitName` conflicted with an FPC system identifier, so it was renamed to
  `UnitText`.
- Fixed Windows post-build noise in `Scripts/copy_sdb_res.bat`: the file started
  with a Unix shebang and `cmd.exe` printed `#! is not recognized` after a
  successful link.

## Verification

- First `lazbuild -B RecorderLnx.lpi` failed at
  `SQLdb/uRecorderSqlDbRuntime.pas(32,15)` with `Duplicate identifier
  "UnitName"`.
- After renaming the field to `UnitText`, `lazbuild -B RecorderLnx.lpi` compiled
  and linked `RecorderLnx.exe` successfully, but the Windows post-build script
  printed a shebang error.
- After fixing `Scripts/copy_sdb_res.bat`, repeated
  `lazbuild -B RecorderLnx.lpi` completed with exit code 0. Warnings/hints
  remain existing project warnings.
- `git diff --check` for changed SQLdb/script/error files passed with exit code
  0. Git only reported LF/CRLF warnings.

## Remaining Risk

- Old DB rows created before schema v2 cannot be matched after a rename if they
  never received `recorder_source_id/recorder_address` and the old name no longer
  exists in the current registry. Run `Переименовать каналы` once while current
  tag names still match old DB names, or let recording touch those channels once,
  to populate the stable address columns.
