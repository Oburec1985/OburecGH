# 2026-08-21 - Measurement section bad values UI

## Symptom

In the measurement-section floating table, clearly invalid values such as
`32767` were shown as normal data. The mnemonic component also showed the
loaded-point summary only in edit mode; in normal/view mode, while the table was
open, the panel caption degraded to just `Измерительное сечение`.

## Confirmed Facts

- `TRecorderMeasurementSectionTableForm.RefreshTable` already recalculates table
  rows periodically from current tag values.
- `TRecorderMeasurementSectionView.Paint` explicitly skipped
  `BuildSummaryText` when `fTableForm <> nil`; this hid the summary whenever
  the floating table was open.
- `TRecorderTag` has `RangeMin`, `RangeMax` and `SignalBuffer.LatestValue`,
  enough to detect an out-of-range input value without changing calculation
  code.

## Checked Hypotheses

- Hypothesis: sigma/angle calculation should clamp invalid inputs.
  Result: rejected for now. The request is visual diagnostics; changing
  calculation semantics could hide source data problems.
- Hypothesis: summary disappears because table mode owns the runtime values.
  Result: rejected. The component deliberately skipped summary text while the
  table form existed.

## Change

- Added a per-cell bad-value cache in
  `UI/uRecorderMeasurementSectionView.pas`.
- Added `OnPrepareCanvas` coloring for out-of-range source cells and their
  dependent `sigma1`, `sigma2`, `Угол` cells.
- Always invalidated the mnemonic component after refresh.
- Always built the measurement-section summary text, including when the table
  form is open.

## Verification

- `git diff --check` passed for the changed Pascal file.
- `lazbuild -B RecorderLnx.lpi` reached linking, so the changed unit compiled.
- Full executable creation was blocked by an open/locked
  `lib/x86_64-win64/RecorderLnx.exe`:
  `Can't create executable ... RecorderLnx.exe (error code: 5)`.

## Follow-up

Close RecorderLnx and rerun the build for a full link check.
