# Remote Firebird recording was disabled by a local file-store check

## Symptom

KIP4 showed changing hardware tag values and connected successfully to
Firebird on `192.168.9.66:3050`, but its hardware tags did not appear in the
database.

## Root cause

`TRecorderSqlDbRuntime.RunWriter` unconditionally constructed
`TRecorderSqlDbFileStore` at writer startup. On a remote Firebird client this
attempted to create `/var/opt/mera/SQLdb/data` locally. The directory is not
needed for scalar values and was not writable, so the whole SQL writer entered
the error state before processing hardware values.

An installer regression made diagnosis harder: `/var/opt/mera/RecorderLnx/app.ini`
was created by root but was not assigned to the desktop user. RecorderLnx then
stopped in a modal permission error during startup.

## Fix

- Create the SQL file store lazily only when a real file job is processed.
- Keep scalar/event recording independent from a local file-store directory.
- Assign `app.ini` to the runtime desktop user in DEB `postinst`.
- Add `RecorderLnx…` diagnostics/repair to LinuxSetupManager →
  `Пользователи и права`.
- Show an actionable RecorderLnx error containing the exact path, OS reason,
  and repair location when application configuration cannot be created.
- Deployment now writes the active top-level `coordinator-client.ini`, not the
  obsolete `config/coordinator-client.ini`.

## Verification

RecorderLnx 0.1.143 on KIP4 connected to Firebird and all three MIC-185
sources. A direct Firebird query showed `4Е1…4Е176` with roughly 98–101 values
per channel. Clean build 0.1.144 was then deployed to KIP1–KIP4, MIC-200 and
`192.168.9.200`; RecorderLnx started successfully on all six computers.
