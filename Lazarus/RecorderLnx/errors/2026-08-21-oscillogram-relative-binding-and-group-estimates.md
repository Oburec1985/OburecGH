# 2026-08-21 - Oscillogram relative binding and grouped estimates

## Symptom

- Oscillogram settings allowed selecting/adding a channel while binding mode was
  `Relative selected tag`; in preview the oscillogram still displayed `MemTag`.
- Group editing MIC185 tags to enable amplitude estimates did not make the
  amplitude appear in the oscillogram or on the digital page.

## Confirmed Facts

- `uRecorderOscillogramSettingsDialog.pas` is a specialized dialog and does not
  use the generic `TComponentSettingsDialog.UpdateTagVisibility` logic.
- Oscillogram and digital page rendering read `TRecorderTag.EstimateSettings`;
  they are not the primary place where grouped estimate settings should be fixed.
- `uTagSettingsDialog.pas` used grayed checkboxes for mixed multi-selection, and
  `StoreToTags` intentionally skipped checkboxes that remained `cbGrayed`.

## Checked Hypotheses

- The display components ignore amplitude estimates: rejected. They iterate
  `EstimateSettings.EnabledKinds` and can display enabled estimates.
- The relative-binding problem is in generic component settings: rejected for
  this case. Oscillogram has its own settings dialog.

## Changes

- In relative binding mode, oscillogram settings now disables tag search,
  channel combo, and the add-channel button.
- Estimate checkboxes now become explicit on user click, so grouped edits are
  written to all selected tags instead of staying in mixed/grayed state.
- Selecting a default estimate now explicitly enables the matching estimate.

## Verification

- `git diff --check` on touched files: no whitespace errors, only existing
  LF/CRLF warnings.
- `C:\lazarus\lazbuild.exe -B
  D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`: exit code 0.

## Remaining Manual Checks

- In oscillogram settings, choose `Relative selected tag`: channel search/combo
  and add button must be disabled.
- Select several MIC185 tags, enable amplitude estimate or choose amplitude as
  default estimate, press OK, then check that oscillogram/digital page show the
  enabled estimate rows/captions after fresh data arrives.
