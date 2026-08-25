# 2026-08-18 - MIC185 hardware calibration cache must survive unit changes

## Symptom

After changing a MIC183/185 channel display unit to `Ом` in hardware/tag
settings, the tag dialog reported that the selected tag had no assigned
hardware calibration. Reading the hardware calibration from the device again
made it appear.

## Confirmed Facts

- MIC185 hardware calibration data is already cached under Mera Files:
  `C:\Mera Files\Calibr\hardware\MIC-185\snXXXX\rangeN\CC.csv`.
- Per-channel excitation current calibration is also cached under:
  `C:\Mera Files\Calibr\hardware\MIC-185\snXXXX\current\CC.csv`.
- The cached calibration name is derived from device type, serial number,
  range, and channel number.
- Changing display units must not change the stored hardware calibration data.
  It should only change the derived linear coefficients used for presentation
  and runtime conversion.
- `UpdateHardwareCurveText` only tried to reload cached MIC185 calibration when
  `HardwareCalibrationName` was non-empty. It skipped the exact regression
  case: name empty, but cached CSV exists.

## Hypotheses Checked

- **Need to reread calibration from the module after unit change:** rejected.
  The data is unchanged and already persisted by SN/range/channel.
- **Hardware calibration should be unit-specific:** rejected. The stored
  hardware calibration is the same physical device data; unit choice changes
  only the effective `K` and `B`.
- **Runtime should search calibration by name while publishing values:**
  rejected by runtime rules. Runtime continues to use prepared cached
  transforms; the new lookup is UI/setup only.

## Done

- Added `RecorderMic185EffectiveTransformText(...)` to format the effective
  linear `K/B` for the current tag display unit, using the stored hardware
  calibration plus the current/power conversion.
- `TTagSettingsDialog.UpdateHardwareCurveText` now attempts to assign cached
  MIC185 hardware calibration from Mera Files even when the tag's
  `HardwareCalibrationName` is empty.
- The hardware calibration view/edit buttons also attempt this cached
  assignment before showing "no assigned hardware GX".
- Saving tag settings preserves the calibration name when the hardware GX
  checkbox is off, and when it is on for MIC185 it tries to reattach the cached
  calibration instead of requiring a reread from the device.

## Verification

- `git diff --check` on the touched files completed with exit code `0` and
  only the existing LF/CRLF warnings.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code `0`.
- The running `RecorderLnx.exe` PID `21372` was stopped before the final link
  because it held `lib/x86_64-win64/RecorderLnx.exe`.
- The known Windows post-build `#!/bin/sh` message remained non-blocking.

## Manual Check

Open a MIC185 tag whose hardware calibration has already been read, switch the
unit to `Ом`, apply, and reopen the hardware GX button. Expected result: no
"read GX first" message; the field shows effective `k=...; b=...` in the
currently selected unit, while the cached CSV under Mera Files is reused.

## Follow-up: cached GX still looked lost after reopening

### Symptom

The tag dialog for `185-{156-1}` showed `Ом` with `Авто` enabled and an
already-calculated `±124.942838` range, but the `Аппаратная ГХ` checkbox and
text were empty.

### Confirmed Facts

- The range value proves that MIC185 cached calibration/current data was
  available enough to calculate the effective Ohm range.
- `UpdateHardwareCurveText` read `HardwareCalibrationEnabled` before lazy
  MIC185 GX attachment, so the checkbox could stay unchecked after the cache
  was found.
- Some UI paths called cached MIC185 GX attachment with `AEnableOnTag=False`.
  That made the cache visible at best, but did not restore the tag state.
- Serial resolution for cached MIC185 GX did not use the saved configured
  source identity (`dataSources[].mic185.serialNumber`) before trying live
  device reads.

### Done

- `Mic185ResolveSerialFromTag` now first uses
  `RecorderMic185GetKnownIdentity(...)`, so cached GX can be matched by stored
  source serial number without requiring a live TCP read.
- `TTagSettingsDialog.UpdateHardwareCurveText` now restores cached MIC185 GX
  for all selected MIC185 tags with `AEnableOnTag=True` before comparing names
  and checkbox states.
- MIC185 hardware-GX view/edit buttons now also restore the cached GX with the
  tag flag enabled before showing the "read GX first" message.

### Verification

- `git diff --check` for `uTagSettingsDialog.pas` and
  `uRecorderMic185Calibration.pas` completed with exit code `0`; only the
  existing LF/CRLF warnings were reported.
- A rebuild was intentionally not repeated because the user may keep
  `RecorderLnx.exe` running for hardware/session capture. The previous build
  before this follow-up had reached the link stage without Pascal compile
  errors; the link was blocked only by a running `RecorderLnx.exe`.

### Manual Check

Open a MIC185 tag after changing units to `Ом`. Expected result: `Аппаратная
ГХ` is checked again and the effective `k=...; b=...` is shown without
re-reading calibration from the device.

## Follow-up: empty GX after application restart

### Symptom

After restarting RecorderLnx and opening `185-{156-1}`, the tag dialog still
showed an empty `Аппаратная ГХ` field, although the channel range was already
displayed in Ohms.

### Confirmed Facts

- `C:\Mera Files\RecorderLnx\config\projects\002\default.config.json` contains
  `sourceId = "MIC-185: 192.168.9.156:4000"` for `185-{156-1}`.
- The same project stores source serial `168` and `tagLinks` for channel
  `156-1` with `hardwareCalibrationEnabled=true` and
  `hardwareCalibrationName="MIC185 sn0168 range3 ch01"`.
- Cached CSV files exist under
  `C:\Mera Files\Calibr\hardware\MIC-185\sn0168\range3\01.csv` and
  `...\current\01.csv`.
- Therefore the data exists; the robust fix must restore it during MIC185
  source/tag loading, not only when the tag settings dialog is opened.

### Done

- `LoadMic185DataSourceConfigs` now calls
  `RecorderMic185LoadHardwareCalibrationForTag(...)` for every
  measurement-channel tag after restoring its source id/address and channel
  mode. On project startup, MIC185 tags reattach the cached hardware GX from
  Mera Files immediately.
- Coefficient loading and checkbox state are separated: the cache restores the
  calibration name/registry object, while `HardwareCalibrationEnabled` remains
  the explicit project/user flag. When the user checks hardware GX in the tag
  dialog, saving still enables the tag and reuses the same cached coefficients.

### Verification

- `git diff --check` for the touched files completed with exit code `0`; only
  the existing LF/CRLF warnings were reported.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code `0`.
- The existing Windows post-build `#!/bin/sh` message remained non-blocking.
- This change is setup/load only and does not add runtime file or string lookup.

## Follow-up: active project 003 still opens MIC185 GX empty

### Symptom

The active application project shows `185-{156-1}` with unit `Ом`, `Auto`
checked, but both hardware and channel calibration fields are empty.

### Confirmed Facts

- `C:\Mera Files\RecorderLnx\config\app.ini` points to
  `DefaultProjectConfigDir=projects\003`.
- `LogWindows.log` shows MIC185 `192.168.9.156:4000` was identified as
  `sn=168`, so source identity is available.
- `projects\003\default.config.json` has top-level tag `185-{156-1}` and
  `mic185.tagLinks` saved with `address="185-{156-1}"`,
  `hardwareCalibrationEnabled=false`, and an empty
  `hardwareCalibrationName`.
- Cached calibration files for the same device exist under
  `C:\Mera Files\Calibr\hardware\MIC-185\sn0168`, including
  `range1\01.csv`.
- Before this fix there were no MIC185 hardware-GX cache restore/miss log
  lines, so failures were silent.

### Hypothesis Checked

- The visible empty field is not because the CSV is missing: the file exists.
- The loaded config was not the earlier checked `projects\002`; the active
  project is `projects\003`.
- The loader/dialog still called MIC185 cache attachment with
  `AEnableOnTag=False`, so a restored cache could remain invisible/unchecked
  in the dialog.

### Done

- MIC185 tag settings dialog now calls cached hardware-GX attachment with
  `AEnableOnTag=True` while opening/updating the hardware-GX field.
- MIC185 hardware calibration cache loading now logs the exact reason for a
  miss: invalid address, unknown serial, or missing CSV path.
- MIC185 project loading now logs normalization of old/corrupted tag-link
  addresses such as `185-{156-1}` to canonical addresses such as `156-1`.

### Verification

- `git diff --check` for the touched MIC185/tag-settings files completed with
  exit code `0`; only existing LF/CRLF warnings were reported.
- Rebuild was intentionally not started because `RecorderLnx.exe` is currently
  running from `D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64`.

## Follow-up: diagnostic log shows range0 path

### Symptom

After rebuilding with diagnostics, the dialog still shows empty hardware GX for
`185-{156-1}`.

### Confirmed Facts

- New log lines appeared, so the diagnostic build is running.
- `LogWindows.log` says:
  `Hardware GX cache miss tag="185-{156-1}" addr="156-1" ... sn=168 range=0 ch=1 file="...\sn0168\range0\01.csv"`.
- The expected files on disk are `range1\01.csv` and `range3\01.csv`; there is
  no `range0` directory.
- The config/programming log uses `range=0` for the first hardware range, while
  the Mera Files cache directory naming is one-based: `range1`.

### Root Cause

An invalid local hardware range index (`-1`) could reach
`RecorderMic185HardwareCalibrCsvPath`, producing `range0` after the path
formatter added one. This made cached GX recovery fail even though the CSV
existed.

### Done

- Added `Mic185NormalizeHardwareRangeIndex` in
  `uRecorderMic185Calibration.pas`.
- `RecorderMic185MakeHardwareCalibrationName` and
  `RecorderMic185HardwareCalibrCsvPath` now clamp range indexes to valid
  MIC185 hardware ranges before building names/paths.
- `RecorderMic185LoadHardwareCalibrationForTag` now normalizes its local
  range before loading and before logging.

### Verification

- `git diff --check` passed with exit code `0`; only existing LF/CRLF warnings
  were reported.
- The current running exe is older than this fix:
  source `uRecorderMic185Calibration.pas` is from `17:14:59`, while
  `RecorderLnx.exe` is from `17:11:06`. Rebuild is pending until the running
  `RecorderLnx.exe` process is closed.

## Follow-up: address shown as tag name and startup serial lost

### Symptom

The tag settings dialog showed MIC185 tag `185-{156-1}` with address
`185-{156-1}` instead of the canonical hardware channel address `156-1`, and
the hardware GX field was still empty.

### Confirmed Facts

- The active config `projects\003\default.config.json` still stores the
  top-level tag and `mic185.tagLinks[]` address as `185-{156-1}`.
- The same `dataSources` entry has old `specificConfigText` with
  `"serialNumber":168`, but the newer `mic185` object did not contain
  `serialNumber` / `softVersion`.
- `LoadMic185DataSourceConfigs` replaces the configured source object from the
  `mic185` section, so it was dropping the serial loaded earlier from
  `specificConfigText`.
- Startup log then showed repeated `serial unknown` during cached hardware GX
  restore before the live MIC185 connection had initialized.

### Hypotheses Checked

- Missing calibration CSV is not the cause; `sn0168\range1\01.csv` and
  `sn0168\range3\01.csv` exist.
- The visible wrong address is not acceptable even though protocol parsing can
  canonicalize it internally; it must not be saved/displayed as the tag address.

### Done

- MIC185 project save now stores `serialNumber` and `softVersion` into the
  `mic185` section when known.
- MIC185 project load now preserves `serialNumber` / `softVersion` from the
  already loaded legacy `specificConfigText` when the new `mic185` section does
  not yet contain them.
- MIC185 `tagLinks` save writes canonical addresses like `156-1`, not tag-name
  style values like `185-{156-1}`.
- Added MIC185 `TagLoadedProc` to canonicalize top-level tag addresses during
  JSON load, so the settings dialog sees `156-1` immediately.

### Verification

- `git diff --check` for the touched MIC185/tag-settings files completed with
  exit code `0`; only existing LF/CRLF warnings were reported.
- Rebuild is still blocked because `RecorderLnx.exe` PID `11656` is running.
  Per user instruction, the process was not stopped automatically.

## Follow-up: MIC185 settings dialog initially shows mV and rewrites source signature

### Symptom

When opening the MIC185 source properties dialog, rows initially showed
`±5.000 мВ`. After pressing `Выбрать все`, the same rows switched to the
expected `Ом` / `±125...` view. After browsing dialogs without intentional
changes, the runtime values changed for some rows: first channels showed about
`250 Ом`, while other rows still showed about `8189`.

### Confirmed Facts

- The active runtime log contains:
  `Source programming required: строка 6: "156-1=100" -> "185-{156-1}=100"`.
- Therefore the settings dialog changed the source signature only by using the
  old tag-name-like address form.
- `FillGrid` searched existing tags by `SameText(Tag.Address, "185-{156-1}")`.
  After tag address migration the real address is `156-1`, so existing tags
  were not found during first grid fill.
- `btnSelectAll` called `EnsureTagForGridRow`, which later forced tags/rows
  through a different path. That made the grid look corrected, but also risked
  saving rewritten defaults.

### Done

- MIC185 settings dialog now computes a canonical row address (`156-1`,
  `156-t1`, `156-uts`) independently from the visible grid cell.
- Tag lookup in the dialog now uses `RecorderMic185SameChannelAddress`, so old
  and canonical address spellings resolve to the same tag.
- The visible grid column remains a tag/display name; configuration read/write,
  properties editing and selected-channel operations use the canonical row
  address instead.
- Creating/updating existing tags no longer resets `AutoUnit` / `AutoRange`
  unless the tag is newly created.

### Verification

- `git diff --check` for MIC185 settings/source files completed with exit code
  `0`; only existing LF/CRLF warnings were reported.
- Rebuild is pending because `RecorderLnx.exe` PID `16824` is currently
  running and was not stopped automatically.

## Follow-up: unchecked MIC185 hardware GX must mean raw ADC codes

### Symptom

The main tag table showed MIC185 channels with unit `Ом`, but values around
`8188`, i.e. raw ADC-code-sized data instead of the expected physical value
when hardware GX is enabled. The user also clarified that if the hardware GX
checkbox is manually unchecked, raw codes are the expected output.

### Confirmed Facts

- `LogWindows.log` shows cached MIC185 hardware GX is found on project load:
  `Hardware GX cache restore OK ... enabled=False`.
- The dialog was reattaching cached GX with `AEnableOnTag=True` during display
  refresh. That made opening the dialog capable of re-enabling a checkbox the
  user had unchecked.
- When `HardwareCalibrationEnabled=false`, the runtime transform intentionally
  remains identity, so raw ADC codes are published.
- Therefore the broken state is not raw codes by itself; it is the inconsistent
  metadata state `HardwareCalibrationEnabled=false` plus `UnitName=Ом`.

### Done

- `UpdateHardwareCurveText` now loads cached MIC185 GX for display with
  `AEnableOnTag=False`, so merely opening the dialog does not turn the checkbox
  back on.
- In the MIC185 tag dialog, unchecking hardware GX immediately switches unit to
  `код` and disables auto-unit for that tag.
- `StoreToTags`, MIC185 project-load, and MIC185 `DoCreateTags` enforce the
  invariant: `MIC185 measurement tag + HardwareCalibrationEnabled=false =>
  UnitName=код`.
- Code-mode range now displays `±32768` instead of a physical mV/Ohm range.
- The earlier attempted nominal `code -> mV` fallback was removed: unchecked GX
  remains raw codes.

### Verification

- `git diff --check -- uRecorderMic185DataSource.pas uTagSettingsDialog.pas`
  completed with exit code `0`; only existing LF/CRLF warnings were reported.
- Full rebuild was not started because `RecorderLnx.exe` PID `16824` is running
  from `D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64`.

## Follow-up: bulk-enable GX still showed codes in Preview

### Symptom

After application start, MIC185 hardware GX / auto-unit states looked lost.
The user enabled hardware GX for all channels, entered Preview, and the main
table still showed `код` values around `32767`.

### Confirmed Facts

- `LogWindows.log` records `Tag settings updated: 64 channel(s)` followed by
  `Data sources started`, but also `Source programming skipped: hardware
  settings unchanged`.
- MIC185 `CacheRuntimeChannels` was called from `ApplyChannelProgramSettings`.
  When only tag flags/units changed, the MIC185 source was reused and hardware
  programming was skipped, so the old prepared transforms could stay active.
- The previous code also cleared `AutoUnit` when forcing `код` for disabled
  hardware GX. That made the auto-unit checkbox look lost after reload/source
  recreation.

### Done

- MIC185 `Start` now calls `CacheRuntimeChannels` before acquisition starts,
  so tag-only changes such as hardware GX enabled/disabled and unit changes are
  reflected even when device programming is skipped.
- Bulk `StoreToTags` now handles MIC185 hardware GX enablement: it attaches the
  cached GX and, if the tag still says `код`, switches it to the MIC185 range
  unit before recalculating `RangeMin/RangeMax`.
- Removed forced `AutoUnit := False` from the hardware-GX-off presentation
  paths. Turning hardware GX off still shows `код`, but does not destroy the
  user's auto-unit flag.

### Verification

- `git diff --check -- uRecorderMic185DataSource.pas uTagSettingsDialog.pas`
  completed with exit code `0`; only existing LF/CRLF warnings were reported.
- Full rebuild was not started because `RecorderLnx.exe` PID `23524` is running
  from `D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64`.

## Follow-up: hardware GX checkbox immediately unchecks on click

### Symptom

In the MIC185 tag settings dialog, clicking the `Аппаратная ГХ` checkbox on
made it immediately return to unchecked.

### Confirmed Facts

- The click handler changed `fHardwareCurveCheck.Checked` through the LCL event,
  but before `OK/Apply` the backing `TRecorderTag.HardwareCalibrationEnabled`
  still contained the old saved value.
- The MIC185 checked branch then called `UpdateHardwareCurveText`.
- `UpdateHardwareCurveText` re-read `TagAt(0).HardwareCalibrationEnabled` and
  copied that old value back into `fHardwareCurveCheck.Checked`.
- Therefore the checkbox was not losing cached calibration data; the UI was
  refreshing from the old model too early.

### Done

- The MIC185 checked-click branch no longer calls `UpdateHardwareCurveText`.
- It now recalculates only the visible effective `k/b` text with
  `RecorderMic185EffectiveTransformText(...)`, preserving the newly clicked
  checkbox state until `OK/Apply` stores it into the tag.

### Verification

- `git diff --check -- uTagSettingsDialog.pas uRecorderMic185DataSource.pas`
  completed with exit code `0`; only existing LF/CRLF warnings were reported.
- Full rebuild was not started because `RecorderLnx.exe` PID `11648` is running
  from `D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64`.

## Follow-up: DigitalForm kept old units after tag settings

### Symptom

After changing MIC185 tag units in the tag settings dialog, the main digital
form still showed the previous unit in the `Unit` column until a full redraw.

### Confirmed Facts

- `UpdateRecorderDigitalPage(..., AStatic=False)` updates live values and
  alarms only.
- Static fields such as `Name`, `Address`, `Unit`, and `Description` are
  refreshed only by `RenderRecorderDigitalPage`.
- After `ShowTagSettingsDialog`, `OpenSelectedTagSettings` refreshed tag list,
  live mnemonic components, and base oscillograms, but did not rebuild the
  active `DigitalForm`.
- `TRecorderTagValueView` does not store or display a separate unit string, so
  there is no additional stale unit cache in simple indicator components.

### Done

- After successful tag settings apply, `OpenSelectedTagSettings` now rebuilds
  the active `DigitalForm` with `RenderDigitalPage(True)` so the `Unit` column
  is immediately reread from `Tag.UnitName`.

### Verification

- `git diff --check` for the touched UI/MIC185 files completed with exit code
  `0`; only existing LF/CRLF warnings were reported.
- Full rebuild was not started because `RecorderLnx.exe` PID `20412` is running
  from `D:\works\OburecGH\Lazarus\RecorderLnx\lib\x86_64-win64`.

## Follow-up: range change must reattach matching cached GX

### Symptom

When changing the MIC183/185 measurement range, RecorderLnx could keep showing
an empty or stale hardware GX instead of automatically attaching the cached
calibration for the new `(serial, range, channel)` tuple.

### Confirmed Facts

- `RecorderMic185LoadHardwareCalibrationForTag` correctly knows how to load
  cached CSV files from Mera Files by serial/range/channel.
- Before this fix it initialized `lRangeIndex` from current channel settings,
  but then `Mic185TryParseCalibrationName(...)` reused the same variable and
  could overwrite it with the old range parsed from `HardwareCalibrationName`.
- The channel settings dialog calculated the new displayed range before forcing
  cached GX reattachment for the newly selected range.
- The bulk source properties path copied settings to selected rows without
  updating `SourceValueMode` before cached GX reattachment.

### Done

- `RecorderMic185LoadHardwareCalibrationForTag` now treats the current
  `SourceValueMode` / configured channel settings as the source of truth for
  range selection. A parsed old calibration name may provide the serial number,
  but no longer overrides the current range.
- `TRecorderMic185ChannelForm.SaveTag` stores the new `SourceValueMode`,
  reattaches cached MIC185 GX for the new range when GX is enabled or a cached
  name exists, then recalculates `RangeMin/RangeMax`.
- `TRecorderMic185SettingsForm.ApplySettingsToRow` does the same for bulk
  range/unit application to selected rows.

### Verification

- `git diff --check` for the touched MIC185 files completed with exit code `0`
  and only existing LF/CRLF warnings.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code `0`.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  completed with exit code `0`.

## Follow-up 2026-08-25: GX re-enable restored mV instead of source Ohms

### Symptom

For a MIC-185 channel configured in the data source as `Ом`, disabling the
tag's hardware GX and pressing OK switched the tag to raw codes. Re-enabling
the GX later restored `мВ` instead of the source channel's `Ом` setting.

### Root Cause

The physical channel unit was stored only in `Tag.UnitName`. Raw mode replaced
that value with `код`; the enable path then reconstructed a unit from the ADC
range through `RecorderMic185RangeUnitText`, which can only return `мВ` or
`мВ(тензо)`. The source configuration had no durable per-channel unit field.

### Done

- MIC-185 source channel config now owns `channels[].unitName`; source and
  channel dialogs save/read that value independently from tag raw mode.
- Tag GX off preserves/migrates the previous physical unit into source config
  and sets only the tag presentation to `код`; GX on restores the source unit.
- Project save/load persists `channels[].unitName`.
- Disabled GX builds an identity runtime transform before hardware, unit,
  soft-fine and channel calibration stages.
- Source settings grid and bulk properties use the source unit, so a raw/code
  master row cannot spread `код` or disable GX on other selected channels.

### Verification

- Independent Skill Compliance Review: `PASS`.
- Independent static QA review: `PASS`; single, mixed bulk, source-grid and
  persistence paths inspected.
- `git diff --check` passed with only standard LF/CRLF warnings.
- `C:\lazarus\lazbuild.exe -B
  D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` completed and linked
  with exit code `0`.
- Hardware/UI acceptance remains: `Ом -> GX off -> OK -> reopen -> GX on ->
  OK` must show `код`, then restore `Ом` and physical values.

## Follow-up 2026-08-25: balance columns use selected source units

### Symptom

The MIC-185 source grid showed hardware and software balance as their mV
equivalents even when the channel source unit was `Ом` or `мкм/м`.

### Done

- Added a unit-only balance conversion helper. It uses the channel's calibrated
  excitation current and the existing Ohm/strain formulas, but deliberately
  does not reapply hardware GX or user channel calibration chains.
- Both balance columns now convert their stored code to mV first and then from
  mV to the physical `channels[].unitName` used by the same grid row.
- Protocol values and the editable mV balance fields are unchanged.

### Verification

- Independent Skill Compliance Review and static QA review: `PASS`.
- `git diff --check` passed with only standard LF/CRLF warnings.
- Forced `lazbuild -B RecorderLnx.lpi` compiled all Pascal units and stopped at
  final link because a running `RecorderLnx.exe` locked the output file
  (`error code: 5`). Repeat after closing the application.
