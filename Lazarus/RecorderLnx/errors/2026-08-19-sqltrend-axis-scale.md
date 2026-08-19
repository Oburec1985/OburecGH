# 2026-08-19 - SQL trend axis min/max scale

## Symptom

When the user changes SQL trend axis minimum/maximum, the graph scale does not
visibly follow the configured range.

## Confirmed Facts

- `TRecorderSqlTrendView.Paint` draws points and Y labels from local
  `fAxisMin`/`fAxisMax` arrays.
- `TRecorderSqlTrendSettingsDialog` stores edited axis ranges into
  `TRecorderSqlTrendComponent.ActiveDisplay.Axes`.
- Existing `TRecorderSqlTrendView.RefreshControl` was empty, so an already
  visible view did not synchronize local axis arrays after component settings
  changed.
- Mouse zoom/pan also uses `fAxisMin`/`fAxisMax`, so blindly copying model axis
  ranges every repaint would destroy interactive zoom.

## Fix

- Added an axis configuration signature to `TRecorderSqlTrendView`.
- `Configure` now loads axis ranges through one shared sync routine.
- `RefreshControl` compares the component axis signature and refreshes local
  scale arrays only when axis configuration changed.
- Manual axis Apply updates the signature after saving the same range into the
  component model.
- Removed the explicit Apply button from the SQL trend axis panel. Min/max
  edits now apply immediately from `OnChange` when both values parse and
  `max > min`.
- Programmatic loading of axis edit controls is guarded by
  `fAxisControlsLoading`, so filling fields does not recursively apply the same
  values.

## Verification

- `git diff --check -- Lazarus\RecorderLnx\SQLdb\SqlTrend\uRecorderSqlTrendView.pas Lazarus\RecorderLnx\errors\2026-08-19-sqltrend-axis-scale.md Lazarus\RecorderLnx\cach\notes_last_state.md`
  completed successfully; only standard LF/CRLF warnings were reported.
- Build was not started because `RecorderLnx.exe` PID 22640 is running from the
  build output path.
- After immediate-apply edits, `git diff --check -- Lazarus\RecorderLnx\SQLdb\SqlTrend\uRecorderSqlTrendView.pas`
  completed successfully; only standard LF/CRLF warnings were reported.
- Build is still deferred because `RecorderLnx.exe` PID 22888 is running from
  the build output path.
