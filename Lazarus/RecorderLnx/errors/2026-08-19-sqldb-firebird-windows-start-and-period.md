# 2026-08-19 - SQL DB Firebird Windows start/check and period UI

## Symptom

- In SQL DB settings on Windows, `Проверить Firebird` reports
  `Firebird не отвечает: 127.0.0.1:3050`.
- User reports `Проверить и создать БД` and `Запустить Firebird` did not work.
- The record period field is shown in milliseconds, while user wants seconds.
- `Емкость очереди` is unclear in the UI.

## Confirmed Facts

- SQL DB config stores `RecordPeriodMs` internally in milliseconds.
- SQL DB runtime uses `QueueCapacity` as a bounded in-memory job buffer before
  the SQL writer thread; when the queue is full, new SQL jobs are dropped.
- SQL trend can read the `signals` table and display historical data in the
  user's current project. Therefore the application-level SQL repository path
  is working in at least one configuration.
- Empty Firebird `host` in RecorderLnx means local file/local connection, not
  necessarily TCP server access through `127.0.0.1:3050`.
- Previous Windows start implementation tried only
  `FirebirdServerDefaultInstance`, `FirebirdGuardianDefaultInstance`, and one
  `net start` command.
- Local development PC has `FirebirdServerDefaultInstance` running and
  `C:\Program Files\Firebird\Firebird_5_0\firebird.exe`; `netstat` shows
  TCP `0.0.0.0:3050` listening, and `Test-NetConnection 127.0.0.1 -Port 3050`
  succeeds.

## Hypotheses Checked

- **Port probe broken on Windows**: not confirmed. Local OS-level probe to
  `127.0.0.1:3050` succeeds when Firebird is listening. The likely issue is
  service/install state or insufficient diagnostics on the user's PC.
- **Local Firebird availability was wrongly equated with TCP 3050**: confirmed.
  The SQL trend screenshot proves DB access can work through the same repository
  path even when the new Firebird check reports the TCP probe as unavailable.
- **Service name mismatch**: plausible. Fixed start path now discovers Firebird
  service names from `sc query state= all`, not only hardcoded names.
- **Firebird installed but not as a service**: plausible. Fixed start path now
  searches standard Firebird install directories and starts `firebird.exe -a`.
- **DB check bypasses the new start logic**: confirmed. `Проверить и создать БД`
  previously created the repository directly; it now tries to start local
  Firebird first when the port is closed.

## Actions

- Added local Firebird diagnostics: service status plus TCP port listening check.
- Added Windows fallback to start discovered Firebird services.
- Added Windows fallback to run local `firebird.exe -a` from standard paths.
- `Проверить и создать БД` now attempts local Firebird startup before database
  connection/schema verification.
- Corrected `Проверить Firebird`: when Firebird `host` is empty, it now opens
  the DB through `TRecorderSqlDbRepository`, the same layer used by SQL trend,
  instead of probing `127.0.0.1:3050`.
- Corrected `Запустить Firebird`: when `host` is empty, success is validated by
  opening the local DB, not by TCP port probing.
- Corrected `Проверить и создать БД`: it first tries the real repository/schema
  check. Only if that fails does it try to start local Firebird and retry.
- SQL DB settings period UI now displays seconds and converts to/from internal
  `RecordPeriodMs`.
- Added a hint explaining `QueueCapacity`.

## Verification

- `git diff --check` for changed SQL DB settings/helper/error files exited `0`
  with only LF/CRLF warnings.
- Full `RecorderLnx.lpi` rebuild was skipped because `RecorderLnx.exe`
  PID 4736 is currently running from the build output path; per user rule, do
  not rebuild while the process is occupied.
- Manual Windows UI check is still required after rebuild.
