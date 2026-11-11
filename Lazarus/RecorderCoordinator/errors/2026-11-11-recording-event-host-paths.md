# 2026-11-11 — recording event host paths and repeated takes

## Observed and confirmed

- RCPanel 0.1.33 on KIP3 showed every source package under KIP-4-USML, and a second group of five `building` packages as missing files.
- Read-only GET `http://192.168.9.66:8765/api/v1/events` identified event `D8BFD07C-21DB-498D-87DF-6529ADE7728B` with ten distinct recording IDs. All ten were completed after the second Stop.
- `/opt/mera/RecorderCoordinator/RecorderCoordinator.log` proves two actual takes. The first five completed at 09:27:30–31 with `completed=5 total=5`; the next five started at 09:27:45 inside the same original 30-second window. The second take completed at 09:31:20–23. These are valid packages, not deletable orphan rows.
- Coordinator lifecycle logs already carry distinct correct `smb://KIP-1..4/USML/...` and `smb://ARM/USML/...` paths. Physical host paths reported by current host snapshots also differ correctly. No measurement files or real SQL rows were changed during investigation.
- `FindOpenEvent` checked only the time window and could reopen a fully completed event. The old filename-only registry fallback could select a different machine with the same frame number. The working source already had a strict SMB fix newer than the installed RCPanel 0.1.33; the additional legacy-path fix must also bind the source host.
- Source-local `building` locations were discarded by the package loader because it accepted only `ready`, leaving an empty path and a misleading missing-file icon.

## Fix

- RCPanel 0.1.35: one recording per source instance belongs to an event. A second recording ID from an already represented host starts another take, including while the first take is active or inside its original 30-second window. A previously unseen participant with an earlier source timestamp can still join that original window even if known participants have completed. Anonymous legacy messages retain the conservative completed-group boundary. Start retries resolve by recording ID first and cannot downgrade an already completed package.
- Path resolution never searches arbitrary mounted hosts by frame number. Known remote host ownership takes precedence over an existing unrelated local file. Explicit operator-selected local copies remain usable through row-specific ownership reset.
- Explicit edit/repair persists `location_kind=operator-selected`; this location is preferred over a subsequently replayed source completion. Thus the operator-selected copy survives closing and reopening the dialog, rather than losing its ownership override.
- Pending packages retain their reported path, show `Записывается`, are not painted as failed/missing, and cannot be opened/transferred until completion.
- Historical event repair is prepared separately in `2026-11-11-recording-event-repair-plan.md`; it must preserve every recording/file ID and physical measurement.

## Verification

- Isolated forced Windows RecorderCoordinator build passed.
- Windows/Linux grouping and path-isolation console tests passed; regression cases cover five completed hosts followed by five new recordings inside the old window, a repeated host while other hosts remain active, previously unseen late participants after completion/by their old timestamps, delayed/repeated messages after the window, same frame names on different hosts, no-owner lookup, and known-host/local-file collision.
- Real pending UI fixture passed on Windows and Linux: building path/status and deferred opening, an existing foreign local-file collision, operator path save, reopening, and source-location retry preference. Windows uses the system `winsqlite3.dll`; the Python 3.14 SQLite DLL failed during the existing repository Open path and was not used for the passing run. Linux uses the installed versioned `libsqlite3.so.0` because the unversioned development symlink is absent. These are test-loader selections only, not production library changes.
- A test-only empty event display name initially caused an expected validation dialog during manual Save. VM screenshot confirmed that cause; it was not a proven SQL transaction lock. The fixture now supplies a valid name. Independently, the worker releases its materialized query connection before notifying UI, so edit callbacks never inherit its read transaction.

## Test-harness incident

The first pending UI fixture called `TRecorderSqlDbConfig.SaveToFile` without an explicit application INI. That method also persists SQL connection settings globally, changing three local workstation SQL connection fields. The damaged file was preserved at `D:\works\OburecGH\backup\RecorderLnx\2026-11-11-pending-ui-harness\app.ini.after-test`; the parent was notified immediately. No fleet configuration was touched. The exact preimage of those three values was unavailable (the old backup was already a stale SQLite fixture); the parent restored a verified functional Firebird profile from the saved project `003/sql-db.ini`, the existing local database, and unchanged remote endpoint. Every other normalized INI line was verified unchanged. The fixture now requires an exact CLI/getter path match, a new app.ini inside an owned unique `GetTempDir/MeraPendingApp-*` directory, and rejects a default application INI or a directory in place of a file. Subsequent guarded runs verified the real workstation app.ini SHA-256 unchanged (`B588355CF0F0B730971298A9D9AEB9109ED4D448849B0B9560096A105BE1086F`). Real measurements and SQL metadata were not touched by this incident. The actionable prevention rule was added to `RecorderLnx/Docs/development-rules.md`.
