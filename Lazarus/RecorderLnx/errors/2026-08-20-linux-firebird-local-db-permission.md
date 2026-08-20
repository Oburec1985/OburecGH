# 2026-08-20 - Linux Firebird local DB permission

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
