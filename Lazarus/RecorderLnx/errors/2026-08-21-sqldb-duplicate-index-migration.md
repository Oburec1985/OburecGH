# 2026-08-21 - SQLdb duplicate index during schema migration

## Symptom

RecorderLnx raises `EIBDatabaseError` on startup:

- `TIBConnection : Execute`
- `unsuccessful metadata update`
- `CREATE INDEX IDX_SIGNALS_NAME failed`
- `Index IDX_SIGNALS_NAME already exists`

The user also reported that before the next startup, reading DB channels was
attempted and the application appeared to hang.

## Confirmed Facts

- The previous SQLdb maintenance change raised schema version to `3` and added
  indexes for signal listing, point counts and delete operations.
- `EnsureDatabase` created those indexes unconditionally through
  `TryCreateIndex`.
- `TryCreateIndex` caught duplicate-index exceptions, but Firebird DDL failures
  can leave the active transaction in an error state. Swallowing the exception is
  not a safe migration path.
- The startup error names an existing index, so the DB is not simply missing the
  new index; the migration path is repeating DDL against an already indexed DB.

## Hypotheses Checked

- **The database has no SQLdb schema:** rejected for this specific error because
  Firebird reports that `IDX_SIGNALS_NAME` already exists.
- **The duplicate index can be ignored by catching the exception:** rejected.
  Firebird metadata errors should be avoided before DDL, not used as normal
  control flow.

## Action

- Replaced catch-and-ignore `TryCreateIndex` with metadata-based
  `IndexExists` and `CreateIndexIfMissing`.
- Firebird checks `rdb$indices`; SQLite checks `sqlite_master`; PostgreSQL
  checks `pg_indexes`.
- `EnsureDatabase` and schema migration now skip index creation when the index
  already exists, avoiding the duplicate-index DDL command.

## Verification

- `git diff --check` for the changed repository/error files completed with
  only the standard LF/CRLF warning.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.

## Remaining Risk

- A database left inside an uncommitted failed transaction from the previously
  running process should be clean after closing that process and reopening the
  DB. If Firebird reports a different metadata error next, record the exact
  message here before changing another migration step.

## Follow-up: DB channel read hangs

### Symptom

After the duplicate-index startup fix, pressing `Прочитать каналы` in SQL DB
settings does not fill the list and the UI appears to hang. The same DB channel
read used to be fast.

### Confirmed Facts

- The recent SQLdb maintenance UI changed ordinary channel reading from a
  signal-list query to `ListSignalInfos(..., True)`.
- With point counts enabled, the query joins every `signals` row to
  `signal_values` and runs `count(v.id)` grouped by signal.
- On a real RecorderLnx Firebird DB, `signal_values` can contain millions of
  rows, so this count violates the original condition: show point counts only
  "если это не слишком долго высчитывать".

### Hypotheses Checked

- **The hang is caused by duplicate-index DDL:** unlikely after the previous
  fix and successful build; the new symptom is no modal exception, just a long
  read.
- **Point counting is too expensive for the normal channel-list button:**
  accepted. It explains why the regression appeared exactly after adding
  counts.

### Action

- SQL DB settings now calls `ListSignalInfos(..., False)` and fills the
  `Точек` column with `-`.
- SQL trend settings also loads DB channel names without point counts and no
  longer computes total DB range/count during that channel-list action.

### Verification

- `git diff --check` for the changed SQL settings/error files completed with
  only standard LF/CRLF warnings.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.

### Remaining Risk

- The `Точек` column now intentionally shows `-` in the fast channel list.
  If point counts are needed, add a separate explicit command that counts only
  selected channels or runs in the background with progress/cancel.
