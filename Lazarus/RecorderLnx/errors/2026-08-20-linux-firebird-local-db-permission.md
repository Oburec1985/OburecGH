# 2026-08-20 - Linux Firebird local DB permission

## Follow-up: TCP check succeeds, DB open still uses `/tmp/firebird`

### Symptom

On another Linux PC the SQL DB setup still failed after pressing settings
buttons:

- `Firebird доступен: 127.0.0.1:3050`
- but local DB open/create failed with
  `TIBConnection : DoInternalConnect : operating system directive access failed`
  and `/tmp/firebird/`
- SQL trend/read path also reported
  `Table unknown SIGNAL_VALUES`

### Confirmed Facts

- Firebird TCP server is reachable on `127.0.0.1:3050`; this rejects the
  hypothesis that the service is simply down.
- FPC `TIBConnection` treats an empty `HostName` as local/embedded Firebird.
  In this mode Firebird can touch `/tmp/firebird`, which explains the Linux
  permission error from the screenshots.
- RecorderLnx Firebird probe already maps an empty host to `127.0.0.1`, but
  the real SQL repository connection did not. Therefore the probe and the real
  DB open tested different connection mechanisms.
- SQL trend reads used `Open` directly and could query `SIGNAL_VALUES` before
  RecorderLnx had created/verified the schema.

### Hypotheses Checked

- **Firewall/network blocks Firebird:** rejected for this case because the TCP
  probe succeeded on `127.0.0.1:3050`.
- **Need to run RecorderLnx with higher rights:** not the primary fix. The
  `/tmp/firebird` access is a consequence of selecting embedded/local attach
  instead of the running server connection.
- **Missing SQL schema after DB creation/open:** confirmed by the
  `SIGNAL_VALUES` table-missing error.

### Actions

- `TRecorderSqlDbRepository.CreateConnection` now maps empty Firebird host to
  `127.0.0.1` before assigning `TIBConnection.HostName`, preserving the port as
  `127.0.0.1/3050`.
- `Проверить Firebird` and `Запустить Firebird` now only check/start the
  Firebird TCP service. They no longer try to open the project DB as a proxy for
  "is Firebird running", so the buttons do not accidentally enter embedded mode.
- SQL trend/read helpers (`ListSignalNames`, `GetTrendTimeRange`,
  `ReadTrendPoints`, `HealthCheck`) now call `EnsureDatabase` instead of `Open`
  so the expected tables exist before reads.

### Verification

- `git diff --check` for changed SQL DB units completed with only standard
  LF/CRLF warnings.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.

### Remaining Risk

- Needs a Linux retest. Expected result: with empty host or `127.0.0.1`, DB
  operations should go through the Firebird server TCP path and no longer fail
  on `/tmp/firebird`.
- If the next error names `/var/opt/mera/SQLdb/...` or
  `/home/user/Mera Files/SQLdb/...`, the remaining problem is directory/file
  ownership for the Firebird service account, not host selection.

## Symptom

On a Linux PC with local Firebird, RecorderLnx fails to create/open the local
SQL DB:

- `TIBConnection : CreateDB`
- `operating system directive access failed`
- `Permission denied`
- paths observed in screenshots:
  `/tmp/firebird/` and `/home/user/Mera Files/SQLdb/recorderlnx.fdb`

## Confirmed Facts

- RecorderLnx was configured with a local Firebird database file under
  `/home/user/Mera Files/SQLdb`.
- Local Firebird runs as a service process, normally under its own account
  (`firebird` or `firebirdsql`), not as the RecorderLnx GUI user.
- Creating the directory from RecorderLnx is not enough when the Firebird server
  process has to create/open the `.fdb` file.
- `Mera Files` is the intended special data root. On installed Linux builds the
  system data root is `/var/opt/mera`, not the user's home directory.

## Hypotheses Checked

- **Need higher privileges for RecorderLnx itself:** rejected. The failing
  file operation is performed by Firebird server, so elevating only the GUI app
  does not guarantee access.
- **Firebird service is missing:** not confirmed by this symptom. The error is
  a Firebird `CreateDB` permission failure, which means the connection reached a
  Firebird code path.
- **Installer should prepare DB directory permissions:** confirmed. This is the
  right layer because the Firebird installer runs as root and can assign owner
  and mode for the DB directory.

## Actions

- Updated `installer/RecorderLnx/firebird/linux/install-firebird-recorderlnx.sh`
  to create `/var/opt/mera/SQLdb` and legacy
  `/var/opt/mera/RecorderLnx/sqldb`.
- The installer now detects `firebird`/`firebirdsql` account and assigns it as
  owner of those directories, with mode `2775`.
- The installer writes `RECORDERLNX_SQLDB_ROOT=/var/opt/mera/SQLdb` to
  `/etc/profile.d/recorderlnx-sqldb.sh`.
- `check-firebird-recorderlnx.sh` now checks both SQL DB directories and prints
  `ls -ld /var/opt/mera/SQLdb`.
- `readme.txt` documents that local Firebird DB files should be stored in the
  system Mera Files root `/var/opt/mera/SQLdb`, not under `/home/user`.
- RecorderLnx now prefers `/var/opt/mera` as default Linux Mera Files when that
  directory exists.
- SQL DB config now honors `RECORDERLNX_SQLDB_ROOT`, and falls back from
  `/home/...` to `/var/opt/mera/SQLdb` for local Firebird when that directory
  exists.

## Verification

- `git diff --check` for changed installer and SQL path files completed with
  only standard LF/CRLF warnings.
- Windows `lazbuild -B RecorderLnx.lpi` compiled all Pascal units, then failed
  only at linking because `lib/x86_64-win64/RecorderLnx.exe` is locked by a
  running RecorderLnx process (`error code: 5`).
- Local `bash -n` could not be run because `bash` is not installed in the
  Windows shell environment.

## Remaining Risk

- Need to run `bash check-firebird-recorderlnx.sh` on the target Linux PC after
  reinstalling/rerunning the Firebird installer.
- If an old project explicitly stores `/home/user/Mera Files/SQLdb`, the new
  runtime fallback should redirect local Firebird to `/var/opt/mera/SQLdb` only
  when that system directory exists.
