# Installer package name used a stale hard-coded version

## Symptom

Running `installer/RecorderLnx/linux/build-installer.bat` produced a fresh DEB
named `recorderlnx_0.1.56_amd64.deb` while the application version was newer.

## Root cause

`linux/build-installer.ps1` used `0.1.56` as its default parameter. The Windows
installer had the same class of defect with `0.1.10`. The deployment script
then selected the newest DEB by timestamp, so a freshly rebuilt stale-version
package could be deployed.

## Fix and prevention rule

- Both installer scripts read `CRecorderLnxVersion` from
  `Core/uRecorderAppVersion.pas` when `-Version` is omitted.
- Explicit versions remain supported but are validated.
- `deploy-linux-all.bat` selects the exact DEB matching the source application
  version instead of the newest timestamp.
- A release build must print the resolved version and its output filename.

## Verification

`linux/build-installer.bat` without arguments resolved `0.1.70` and created
`recorderlnx_0.1.70_amd64.deb`. Deployment prepare-only selected that exact
file even while older packages were present.
