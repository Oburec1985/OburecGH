---
name: recorder-unit-pipeline
description: Maintain and verify physical units through RecorderLnx datasource, hardware calibration, sensor-calibration pipelines, AutoUnit, tag dialogs, and runtime values. Use when changing units, GX/calibration behavior, MIC-185 channels, tag settings, import/load, or scale rebuilding.
---

# Recorder Unit Pipeline

Treat the signal path as explicit ordered stages:

`raw device value -> hardware GX -> datasource conversion -> sensor GX pipeline -> display unit`.

Preserve these invariants in implementation and review:

- `AutoUnit` selects the unit of the last effective stage; it never enables or disables a GX.
- For MIC-185, the datasource-declared channel unit is the effective output of the hardware stage. If the channel is configured as Ohm or microstrain, AutoUnit must return that unit rather than the intermediate V/mV output of the hardware GX.
- If no sensor GX is enabled, the tag's automatic unit equals the datasource output unit.
- If a sensor GX is enabled, automatically convert the datasource/hardware-stage output into the input unit of the first enabled sensor-GX step when their physical quantities are compatible. Continue the same check between every enabled pipeline step.
- Never silently bridge incompatible physical quantities. Keep the pipeline invalid and report the mismatched output/input units clearly.
- Only the user or project/config import may change GX enabled flags. Unit synchronization, source restart, scale rebuild, and AutoUnit must not toggle them.
- Persist the datasource unit separately from intermediate and display units. Start/stop, device reset, source reconfiguration, project reload, tag-dialog OK/Apply, and import must preserve it.

When validating a change, cover at least these states for the affected source:

1. Hardware GX on, sensor GX off, AutoUnit on: displayed unit equals datasource unit.
2. Hardware GX on, sensor GX on: compatible units are converted at the stage boundary and the displayed unit equals the last enabled sensor-GX output.
3. AutoUnit off: the user's compatible display unit is preserved.
4. Start/stop, edit/apply, reset/reconfigure, and project reload do not change datasource units or GX enabled flags.

For MIC-185 specifically, include an Ohm channel in the check and verify that an mV hardware GX remains an internal stage rather than becoming the displayed unit.
