# MIC315 one-shot Recorder updater

The updater accepts a sibling `RecorderLnx-dac-feedback.exe` payload and replaces
only `C:\Program Files (x86)\Mera\RecorderLnx\RecorderLnx.exe`. It does not modify
configuration, drivers, DLLs, services, scheduled tasks, or remote access settings.

Place both executables in `C:\Mera Files\DacCalibrationUpdate` on MIC315 and launch
`Run-Mic315Updater.cmd`. If elevation is required, confirm the Windows UAC prompt.
The initial non-elevated process only requests elevation; the elevated console
and timestamped log provide the update result.

Before stopping any process it verifies the hostname (`MIC-315` or `MIC315`), PE
headers, a timestamped backup in the updater's `backups/` subdirectory, and a staged replacement beside
the installation EXE. Copies are compared byte-for-byte. Only processes whose
queried full image paths are RecorderLnx executables in that exact installation
directory can be terminated. The new EXE is launched with installation cwd and
must remain alive for one second. This is a process check, not proof of a working
measurement/calibration. A failed replacement or launch attempts restoration and
launch of the verified backup. Configuration files remain untouched, although
unsaved in-memory Recorder edits are not preserved by forced process termination.

Backups `RecorderLnx-before-*.exe` are retained in `backups/`. Timestamped
`updater-*.log` and the launcher's `updater-launch.log` are retained in `logs/`.
The real update creates these subdirectories; dry-run creates neither.
Failed staging may leave a `.pending` file in the installation directory;
the utility does not perform broad cleanup.

`--dry-run --no-pause` performs read-only checks, without log writes, process
termination, launch, or elevation. For local validation only, overrides are
accepted in dry-run mode:

```
Mic315Updater.exe --dry-run --no-pause --payload=path\test.exe --target=path\test.exe
```

Real mode refuses path overrides and a computer other than MIC315. Failures leave
the console open unless `--no-pause` is supplied. Success closes it automatically.

Build (no extra runtime DLLs/packages):

```
C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpcres.exe Mic315Updater.rc -of res -o Mic315Updater.res
C:\lazarus\lazbuild.exe -B Mic315Updater.lpi
```

Output: `lib\x86_64-win64\Mic315Updater.exe`. The embedded manifest is `asInvoker`:
dry-run never requests elevation; only a validated real MIC315 update may request
it. No credentials are stored or entered by the updater.
