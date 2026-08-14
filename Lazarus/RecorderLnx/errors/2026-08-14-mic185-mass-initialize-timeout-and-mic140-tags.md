# 2026-08-14 - MIC-185 mass initialize timeout and MIC-140 tag visibility

## Symptom

User reported that MIC-185 devices started dropping, and MIC-140 tags were not
visible in the tag list although the MIC-140 device looked green after reset.

## Checked Facts

- `C:\Mera Files\RecorderLnx\LogWindows.log` showed a startup at `14:35`.
- All MIC-185 sources opened TCP quickly, then entered
  `Initialize transport-ready wait`.
- The MIC-185 clients then logged `TcpClientUnregister` / `RuntimeDetach`
  during the retry path, and finally all failed `initialize` after about
  `6.3 s` with TCP connection timeout text.
- The same log showed the configured MIC-140 source as
  `MIC-140: 192.168.14.41:4000`.
- Broadcast discovery in that run received MIC-140 replies from
  `192.168.14.42`, `192.168.14.30`, and `192.168.14.40`; it did not show
  `192.168.14.41` in the visible tail.
- The MIC-140 prepare failure was `TCP TEST failed for 192.168.14.41:4000`.
- In the current project file
  `C:\Mera Files\RecorderLnx\config\projects\002\default.config.json`,
  `dataSources` contains `MIC-140: 192.168.14.41:4000`.
- That same project file already contains `57` MIC-140 tags for
  `MIC-140: 192.168.14.41:4000`, so the tags were not lost from the saved
  project.
- Hardware tree green status currently means "no cached offline error"; it is
  intentionally not a synchronous TCP/Mebius probe during tree painting.

## Hypotheses And Results

- Hypothesis: MIC-185 failures are caused by no network route/ping.
  - Check: logs show TCP connect succeeds for each MIC-185.
  - Result: rejected.

- Hypothesis: the previous change that removed the global MIC-185 prepare lock
  made all devices issue Mebius command traffic at once.
  - Check: log timestamps show multiple MIC-185 devices enter initialize within
    one narrow window and all fail the command reply stage.
  - Result: likely. TCP opens, command protocol does not answer reliably under
    concurrent prepare pressure.

- Hypothesis: MIC-140 tags disappeared from the project.
  - Check: parsed `002/default.config.json`; 57 MIC-140 tags are present.
  - Result: rejected.

- Hypothesis: MIC-140 tags are hidden because the configured `.14.41` source is
  offline or because all its signals are already linked and therefore absent
  from the "available channels" grid.
  - Check: config has linked tags; log has `.14.41` TCP TEST failure.
  - Result: active UI-side explanation; needs next visual check of the
    selected-channel grid/filter after the MIC-185 fix.

## Fix

- Kept source preparation parallel at the data-source manager level.
- Added a MIC-185 command-stage throttle in
  `Device/mic185/uRecorderMic185DataSource.pas`.
- Only two MIC-185 sources may execute the sensitive prepare command section
  (`TryInitializeSession`, identity update, `TryProgramDevice`) at once.
- TCP connect remains outside this throttle, so independent endpoints still
  overlap and startup should not fall back to fully serial behavior.
- Added lifecycle log phase `prepare-command-slot` with wait/active/limit data.

## Verification

- Rebuilt `RecorderLnx.lpi` with exit code `0`.
- Existing post-build `copy_sdb_res.bat` still prints the known `#!/bin/sh`
  message, but the build/link step succeeds.

## Next Check

- Start RecorderLnx and apply/start with the same project.
- In `LogWindows.log`, MIC-185 prepare should show
  `prepare-command-slot ... limit=2` and should no longer have all devices
  failing initialize in the same 6-second wave.
- For MIC-140, if `.14.41` still does not answer TCP while `.14.40/.42/.30`
  answer broadcast, the configured source endpoint is the problem, not missing
  saved tags. Re-add/select the responding endpoint or power-cycle only the
  `.14.41` unit if it must be used.
