# Linux installer refused stale RecorderLnx ELF

## Symptom

`build-installer.bat` exits with code 1 because
`lib/x86_64-linux/RecorderLnx` is older than modified production sources.

## Confirmed cause

The current `build-installer.ps1` only packages and validates existing Linux
artifacts. It does not invoke Lazarus. The Linux targets must first be built in
the Astra VM with `Lazarus/Tools/build_recorderlnx_linux.sh`.

## Attempt

The Astra VMware machine is running, but `vmrun runScriptInGuest` rejected the
available guest credentials (`Invalid user name or password`). SSH public-key
authentication to `user@192.168.112.128` is also unavailable.

## Next step

Obtain the current password for guest account `user`, run the build script,
check `linux_build_report.txt`, and rerun `build-installer.bat`.

