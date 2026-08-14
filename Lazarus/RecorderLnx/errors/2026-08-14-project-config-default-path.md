# 2026-08-14 - Project config path returns to default after restart

## Symptom

User saved RecorderLnx project config under `C:\Mera Files\RecorderLnx\config\projects\002`, restarted RecorderLnx, but the main window caption still showed the build-tree default project path:
`D:\works\OburecGH\Lazarus\RecorderLnx\config\projects\default`.

## Acceptance Rule

After `Save As` / loading another project directory, a normal RecorderLnx restart must open that same project directory. The window caption must show the persisted project path, not `projects\default`.

## Checked Facts

- `C:\Mera Files\RecorderLnx\config\projects\002` exists and contains `default.config.json`, `default.gui.ini`, and `default.run-control.ini`.
- `C:\Mera Files\RecorderLnx\config\app.ini` initially contained `DefaultProjectConfigDir=projects/default`.
- `TMainForm.FormCreate` did not read `DefaultProjectConfigDir` from `app.ini`; it hardcoded `projects\default`.
- When `RecorderConfigPath` is empty, the old startup fallback used `GetDevProjectDir + config`, so the running app could load `D:\works\...\config\projects\default`.
- Project service files should live under `RecorderServicePath`, which resolves here to `C:\Mera Files\RecorderLnx`.

## Hypotheses And Results

- Hypothesis: only `app.ini` value is stale.
  - Check: updated real `app.ini` to `DefaultProjectConfigDir=projects/002`.
  - Result: necessary but not sufficient, because startup code ignored this setting.

- Hypothesis: startup hardcodes default project.
  - Check: inspected `UI\uMainForm.pas`.
  - Result: confirmed. `FormCreate` called `SetProjectConfigDir(...projects\default)` directly.

- Hypothesis: after adding `app.ini` reading, the app can still choose build-tree config.
  - Check: launched once after the first patch; log still showed `D:\works\...\config\projects\default`.
  - Result: confirmed. `RecorderConfigPath` was empty, and fallback still used the dev project directory.

## Fix

- `TMainForm.FormCreate` now calls `LoadDefaultProjectConfigDir`.
- `LoadDefaultProjectConfigDir` reads `[Application] DefaultProjectConfigDir` from the app config.
- `SaveConfigAsClick` and `LoadConfigFromClick` now persist the selected project path through `SaveDefaultProjectConfigDir`.
- `GetAppConfigDir` falls back to `RecorderServicePath\config` when `RecorderConfigPath` is empty.
- Real user config was updated to `C:\Mera Files\RecorderLnx\config\app.ini`: `DefaultProjectConfigDir=projects/002`.

## Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit code `0`.
- A running `RecorderLnx.exe` instance had to be stopped before linking because it locked the output executable.
- The existing Windows post-build `#!/bin/sh` message is non-blocking and did not prevent a successful build.

## Next Session Note

If the caption still shows a default project after restart, first check which physical `app.ini` the process reads:
`RecorderConfigPath` from `RecorderLnx.paths.ini` if present, otherwise `RecorderServicePath\config\app.ini`.
