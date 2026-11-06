# Linux installer refused stale RecorderLnx ELF

## 2026-10-30 — false freshness inputs from SDK tests

Screenshot identified Plugins/SDK/Tests/VisualComponentAbiV2/StatefulVisualProbePlugin.lpr
as the newest production input. The recursive scan excluded only exact
_buildverify, not _buildverify_v2, and did not exclude nested Tests.
The filter now uses paths relative to each scanned root, excludes Test/Tests
and _buildverify* directories, and includes project/resource files.
Three focused tests pass: ignored verification trees, retained production
SDK/SharedUtils/resource changes, and LinuxSetupManager's own sources.
The actual BAT then correctly identified a separate newer production
SampleInfoPlugin.lpr; Linux rebuilding was therefore required as well.
Prevention rule is documented in installer/RecorderLnx/linux/README.md.
Full Linux build and the exact build-installer.bat subsequently completed with
exit0; output recorderlnx_0.1.190_amd64.deb SHA256
2AD61259DE02BD325CD26CAC909BE897D08DEDF19451431699B19458B2B51255.

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

