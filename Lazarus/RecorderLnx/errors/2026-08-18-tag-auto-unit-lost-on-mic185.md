# 2026-08-18 - Tag auto unit checkbox was lost for MIC185 tags

## Symptom

Enabling the `Авто` measurement unit checkbox for many tags did not apply
the expected unit conversion. Reopening the tag settings dialog showed that
the checkbox had been reset.

## Confirmed Facts

- `TRecorderTag.AutoUnit` exists in the tag model and is saved to project JSON
  as `autoUnit`.
- `TTagSettingsDialog.StoreToTags` writes `AutoUnit` from the checkbox when
  the checkbox state is not grayed.
- MIC185 source synchronization code unconditionally assigned
  `AutoUnit := False` and `AutoRange := False` while refreshing existing tags.
- MIC185 channel settings dialog also assigned `AutoUnit := False` when
  applying channel settings to an existing row.
- For multi-tag editing, the unit combo may still contain an old visible unit.
  Previously this text was written back before the auto-unit fallback and the
  auto-unit fallback only ran when the combo text was empty.

## Hypotheses Checked

- **Project JSON does not save AutoUnit:** rejected. `SaveRecorderProjectConfig`
  writes `autoUnit`, and `LoadRecorderProjectConfig` reads it.
- **The checkbox state is not written by the tag dialog:** rejected for
  non-grayed state; `StoreToTags` writes it.
- **MIC185 refresh is allowed to reset AutoUnit:** rejected. Hardware/source
  synchronization may update source address, range, and generated defaults,
  but must not erase a user tag setting on an existing tag.

## Done

- MIC185 settings dialog now clears `AutoUnit` / `AutoRange` only for newly
  created tags, not for already configured tags.
- MIC185 data source tag creation/synchronization now applies those defaults
  only when it actually creates a new tag.
- `ApplySettingsToRow` no longer resets `AutoUnit` on an existing tag.
- `TTagSettingsDialog.StoreToTags` now applies the channel-calibration output
  unit whenever `AutoUnit` is enabled, regardless of stale text left in the
  unit combo.

## Verification

- First `lazbuild -B RecorderLnx.lpi` reached link, proving Pascal
  compilation was OK, but failed with `error code: 5` because a running
  `RecorderLnx.exe` held the output executable.
- Stopped the blocking `RecorderLnx.exe` PID `18252`.
- Rebuilt `D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`;
  build completed with exit code `0`.
- `git diff --check` on the touched source files completed with exit code `0`
  and only existing LF/CRLF warnings.

## Manual Check

Select several MIC185 tags, enable `Авто` for measurement units, apply or OK,
then reopen the same tag group. Expected result: the checkbox remains enabled
for tags that were changed, and units are taken from the last channel
calibration output unit instead of being overwritten by the visible combo text.
