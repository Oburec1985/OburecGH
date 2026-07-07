# 2026-07-07 MIC140 offline tree icon

## Symptom

In the RecorderLnx settings hardware tree, `MIC-140: 192.168.14.155:4000`
kept the normal controller icon even when the MIC140 stand was powered off.

## Confirmed Facts

- `UI/uRecorderSettingsDialog.pas` already had `CDeviceDisabledImageIndex = 41`.
- `PopulateHardwareTree` only used image 41 when a source had no linked tags.
- MIC140 already exposes `RecorderMic140TcpProbe(AHost, APort, ATimeoutMs)`.
- MIC185 already exposes `RecorderMic185ReadDeviceInfo(..., ATimeoutMs)`.

## Fix

- Added `CDeviceTreeProbeTimeoutMs = 1000`.
- Added local `Mic140SourceConnected` and `Mic185SourceConnected` helpers in
  `PopulateHardwareTree`.
- MIC140 source nodes now require both linked tags and a successful
  `RecorderMic140TcpProbe(..., 1000)` to show the normal controller icon.
- MIC185 source nodes now require both linked tags and a successful
  `RecorderMic185ReadDeviceInfo(..., 1000)` to show the normal controller icon.
- On missing tags or failed connection, the source node uses image index 41.

## Verification

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0.

The known post-build `copy_sdb_res.bat` message about `#!/bin/sh` still appears
but does not fail the build.

## Follow-up: hardware tree source-only view

### Symptom

The hardware tree showed every linked/available channel as a child node under
Mera, MIC140, and MIC183/185 sources, which made the device list noisy and
duplicated the Channels tab.

### Fix

`UI/uRecorderSettingsDialog.pas` no longer adds signal/tag child nodes under
hardware source nodes in `PopulateHardwareTree`. The tree now shows source
nodes only; channel membership remains visible in the channel grids.

### Verification

`rg` confirms there are no remaining `Items.AddChild(lSourceNode, ...)` calls in
`UI/uRecorderSettingsDialog.pas`. `C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit
code 0 after stopping a running `RecorderLnx.exe` process that held the output
file. The known post-build `copy_sdb_res.bat` message about `#!/bin/sh` still
appears but does not fail the build.

## Follow-up: linked tags of inactive device

### Symptom

After the MIC140 source was marked offline in the hardware tree, tags linked to
that inactive source still appeared in the main form channel list. The settings
dialog also did not visually distinguish those selected channels.

### Fix

- `TMainForm.UpdateActiveSourceIds` now refreshes normal active sources from
  tags and then probes unique MIC140/MIC185 hardware sources with a 1000 ms
  timeout. Sources that fail the probe are removed from `ActiveSourceIds`.
- The main form already filters the right-side tag/channel list through
  `RecorderTagSourceIsVisible`, so tags of offline MIC sources are now hidden
  there.
- `TRecorderSettingsDialog.PopulateHardwareTree` now keeps `ActiveSourceIds`
  synchronized with the same MIC source probe used for the tree icon.
- The selected-channel grid in the settings dialog keeps inactive-source tags
  visible, but draws image index 54 in a dedicated 20 px icon column before the
  name column. The icon is fitted to 16x16 px and centered in that column.

### Verification

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0. The known post-build `copy_sdb_res.bat` message
about `#!/bin/sh` still appears but does not fail the build.

## Follow-up: selected-channel icon layout

### Symptom

Image index 54 was drawn inside the selected-channel name cell, so the icon
overlapped the tag name and looked unlike the original Recorder list.

### Fix

`UI/uRecorderSettingsDialog.pas` now gives the selected-channel grid a separate
leading icon column (`ColCount = 9`, `ColWidths[0] = 20`). The draw handler only
draws inactive-source image 54 in column 0, scales it into a centered 16x16 px
rectangle, and leaves tag names in column 1. The empty icon column is ignored by
sorting.

### Verification

`C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
completed with exit code 0. The known post-build `copy_sdb_res.bat` message
about `#!/bin/sh` still appears but does not fail the build.
