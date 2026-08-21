# 2026-08-19 - mnemonic editor lag

## Symptom

Editing a mnemonic page reacts slowly to keys and mouse clicks. The user is not
sure whether these are UI stalls or deadlocks.

## Related History Checked

- `2026-07-13-preview-offline-and-form-editor-lag.md`: drag used to call
  `NotifyChanged`/`RenderLive` on every `MouseMove`; that part was already
  throttled.
- `2026-07-21-linux-mnemonic-first-open-slow.md`: first OpenGL frame/font atlas
  was already optimized.
- `2026-07-29-ui-event-queue-block-copies.md`: shared UI queue no longer copies
  tag blocks for the main form.

## Confirmed Facts

- `TFormEditorController.NotifyChanged` calls `TMainForm.FormEditorChanged`.
- `FormEditorChanged` called `PrepareRuntimeForConfiguration` while Recorder
  was stopped.
- `PrepareRuntimeForConfiguration` calls `WarmupHardwareNetwork`, whose UDP
  discovery timeout is up to 3000 ms, and then `PrepareHardwareAll`.
- `NotifyChanged` is reached from editor operations such as key movement,
  delete, placement, paste/undo, and component settings changes.

## Conclusion

The observed UI stalls can be caused by ordinary mnemonic editing synchronously
entering hardware/runtime preparation. This is not a true deadlock, but it
blocks the GUI thread long enough to look like one.

## Prevention Rule

When editing a mnemonic/form layout, UI-only operations must not enter hardware
preparation, network discovery, source reset, or full runtime preparation.
Verify by checking that drag, resize, keyboard nudges, selection, and delete do
not call `PrepareRuntimeForConfiguration`, `WarmupHardwareNetwork`,
`PrepareHardwareAll`, or full component `Render` unless the operation actually
changes component type/settings that require a rebuild.

## Change

- Split algorithm preparation from hardware preparation in `uMainForm.pas`.
- `FormEditorChanged` now runs only `PrepareAlgorithmsForFormConfiguration`
  while stopped.
- Full `PrepareRuntimeForConfiguration` still performs algorithm preparation
  plus hardware warmup/prepare, and remains available to settings/runtime paths
  that intentionally apply hardware configuration.
- Replaced full editor `Render` after drag/resize mouse-up with
  `RefreshSelectionVisuals`, because `EndOperation` already commits changed
  geometry and triggers the live/update path.
- Replaced arrow-key move full `Render` with `RefreshComponentLayout`: it only
  reapplies panel bounds from the model, adjusts image child size, and refreshes
  selection handles.
- Resize handles are now reused by operation kind and hidden/shown, not freed
  and recreated on every selection refresh.
- Delete toolbar handler no longer calls `RenderActivePage` after
  `fFormEditor.DeleteSelected`, because the editor already performs its own
  change notification/render.

## Remaining Optimization Candidates

- `TFormEditorController.Render` in the non-rebuild path still calls
  `Configure` and `RefreshControl` for every component. Selection-only changes
  should update handles/bevels without refreshing charts/images.
- Arrow-key moves call `PushUndoState` on every key repeat. Undo snapshots should
  be coalesced for repeated keyboard nudges.
- Add a lightweight UI-stall marker around editor operations to log calls that
  exceed 50-100 ms.

## 2026-08-20 Measurement Section Placement Stall

### Symptom

Placing a new `MeasurementSection` visual component on a mnemonic page caused a
long UI stall even before component settings were opened.

### Confirmed Facts

- `TMainForm.PlaceSelectedTool` already creates the component, positions it, and
  calls `RenderActivePage`.
- After that, `TFormEditorController.CanvasMouseDown` and
  `ComponentMouseDown` also called `NotifyChanged` and `Render` for the same
  placement operation.
- `NotifyChanged` reached `TMainForm.FormEditorChanged`, which still called
  `PrepareAlgorithmsForFormConfiguration` while stopped.
- This made a simple visual placement do duplicated rendering plus a broad
  algorithm prepare/event publish path.

### Change

- Removed the extra `NotifyChanged` and `Render` calls after successful pending
  component placement.
- Made `FormEditorChanged` a UI-only callback; runtime and algorithm preparation
  stays in explicit settings/apply/start paths.
- Added `[MNEMO-PERF] place ... elapsed=...ms` logging when a placement still
  takes 50 ms or more.

### Effect

The suspected heavy path is no longer entered by a plain component drop. If
placing `MeasurementSection` still stalls, the next log should point to the
remaining slow segment instead of rechecking the same notify/prepare hypothesis.

### Verification

- `git diff --check -- Lazarus\RecorderLnx\UI\uFormEditorController.pas Lazarus\RecorderLnx\UI\uMainForm.pas Lazarus\RecorderLnx\errors\2026-08-19-mnemonic-editor-lag.md Lazarus\RecorderLnx\cach\notes_last_state.md`
  completed successfully; only standard LF/CRLF warnings were reported.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed successfully.

## Verification

- `git diff --check -- Lazarus\RecorderLnx\UI\uFormEditorController.pas Lazarus\RecorderLnx\UI\uMainForm.pas Lazarus\RecorderLnx\errors\2026-08-19-mnemonic-editor-lag.md Lazarus\RecorderLnx\cach\notes_last_state.md`
  completed successfully; only standard LF/CRLF warnings were reported.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed successfully.
