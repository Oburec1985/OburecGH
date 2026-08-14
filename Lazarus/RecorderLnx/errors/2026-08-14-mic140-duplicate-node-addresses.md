# 2026-08-14 - MIC-140 duplicate node addresses

## Symptom

After deleting one MIC-140 device from the project, the selected-channel grid
showed channels from different MIC-140 devices interleaved by the same address:
for example `140_{30_38}` and `140_{41_38}` both had address `2-38`.

The user clarified the rule: the address must include the device node number;
the hardware tree must not contain two nodes with the same index.

## Confirmed Facts

- MIC-140 channel names had already been changed to include the last IP octet,
  e.g. `140-{30-38}` and `140-{41-38}`.
- `UI/uRecorderSettingsSourceProbe.pas` still built MIC-140 signal addresses
  with `MIC140DefaultNodeNumber`, producing `2-01..2-48` for every device.
- `Device/MIC140/uRecorderMic140Device.pas` also initialized runtime `fNode`
  from the legacy default node, so runtime channel addresses could stay `2-*`
  even if the UI catalog was fixed separately.
- `SameMic140Address(...)` intentionally compares MIC-140 addresses by channel
  number inside the same `SourceId`; this is useful for migrating old `2-*`
  addresses without losing existing tags.
- Previous MIC-185 work recorded the same class of failure: constant node
  numbers caused duplicate device/channel addresses.

## Checked Hypotheses

- Protocol/commutator programming is not the cause of this specific screenshot.
  The shown failure is in the configuration/address layer before any ADC data is
  read.
- Tag names alone are not enough. Names already differed by IP octet, but the
  tag `Address` field remained identical, so selected channels collided.
- Changing only the settings UI would be incomplete because runtime data source
  channels are created from `TRecorderMic140Device`.

## Fix

- Added shared helpers:
  - `RecorderMic140NodeNumberForHost`
  - `RecorderMic140NodeNumberForSourceId`
- MIC-140 node number now comes from the last IPv4 octet:
  - `192.168.14.30`, channel 38 -> `30-38`
  - `192.168.14.41`, channel 38 -> `41-38`
  - temperature channels use the same node, e.g. `30-t6`.
- `TRecorderMic140Device` uses the same node number when building runtime
  channels.
- `TRecorderSettingsSourceProbe.BuildMic140` uses the same node number when
  building available-channel signals.
- Existing old tags are migrated when the source probe sees the matching
  channel in the same source: `2-38` for source `.30` becomes `30-38`.
- MIC-140 source dialog displays channel addresses from the entered host IP,
  not from the default node.
- When MIC-140 source properties are confirmed with OK, existing measurement
  tags for that source are also rewritten to the node derived from the selected
  host IP.

## Verification

- Searched the MIC-140 UI/runtime channel builders for remaining direct
  `MIC140DefaultNodeNumber` address generation. Only fallback/default constants
  remain.
- First `RecorderLnx.lpi` rebuild compiled but could not link because a running
  `RecorderLnx.exe` locked the output file.
- Stopped only that `RecorderLnx.exe` process and rebuilt again.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code `0`.
- After adding the MIC-140 source-dialog migration, rebuilt
  `RecorderLnx.lpi` again; exit code `0`.

## Remaining Check

Open the settings dialog on the current project. Expected selected addresses:
channels from `.30` must be `30-*`, channels from `.41` must be `41-*`; there
must be no cross-device duplicate `2-*` channel addresses after the probe
refreshes/migrates the registry.
