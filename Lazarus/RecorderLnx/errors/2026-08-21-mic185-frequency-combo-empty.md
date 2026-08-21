# 2026-08-21 - MIC-185 empty frequency combo

## Symptom

In the tag settings dialog for a MIC-185 channel, the current poll frequency is
shown as text, but the dropdown list is empty.

Follow-up: after selecting another frequency and pressing OK, the setting did
not affect the MIC-185 acquisition. MIC-185 has one measurement frequency for
the whole device, not an independent frequency per channel.

## Checked Facts

- `TTagSettingsDialog.LoadFromTags` fills the frequency combobox only through
  `RecorderFrequencyGridForSource`.
- `uRecorderFrequencyGrids` is a generic SourceId-prefix registry.
- MIC-140 and MC-201 register their grids, but MIC-185 did not.
- Original MIC-185 driver `mic185v2chanbase.cpp` declares:
  `1, 10, 25, 50, 100, 150, 200, 250, 400, 10000, 20000, 35000`.
- The original Recorder UI currently exposes only the first five values for the
  active MIC-185 mode: `1, 10, 25, 50, 100`.
- `TTagSettingsDialog.StoreToTags` applied non-MIC140/non-MC032 frequencies by
  changing only the current tag `PollFrequencyHz`.

## Hypothesis

The combobox is empty because MIC-185 never publishes its frequency grid into
the generic registry introduced for hardware-specific lists.

## Change

Registered the MIC-185 UI frequency grid during MIC-185 data source unit
initialization using the `MIC-185:` SourceId prefix.

Added `RecorderMic185ApplySourceFrequency`: it normalizes the selected value to
the MIC-185 UI grid, updates the configured source default frequency, updates
all measurement tags of the source, and rewrites per-channel MIC-185 config with
the same channel mode but the new `pollFrequencyHz`. Temperature and UTS tags
are intentionally left at their 1 Hz path.

## Verification

`C:\lazarus\lazbuild.exe -B
D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed with exit
code 0.
