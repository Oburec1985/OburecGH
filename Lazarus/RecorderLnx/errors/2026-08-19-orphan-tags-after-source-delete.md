# 2026-08-19 - orphan tags after source delete

## Symptom

Adding a virtual-source channel failed with:

`Tag name already exists: 1_датчик_X`

The channel had existed before, then the source was deleted and the tag was no
longer visible to the user.

## Facts Checked

- The exception is raised by `TRecorderTagRegistry.AddTag` when
  `FindByName(ATag.Name)` finds an existing tag.
- `TRecorderTagRegistry.RemoveTag` only removed and freed the tag object; it did
  not clean selected-tag state, spectrum bindings, or frequency-band terms.
- Source deletion in `uRecorderSettingsDialog.pas` did not remove source tags.
  It rewrote their `SourceId` to `Detached: <old source id>`, so names stayed
  reserved inside the tag registry and were saved back to the project.
- Removing a tag from the used-channel list already called `RemoveTag`, so the
  missing part there was cleanup of dependent registry references.

## Hypotheses

- Confirmed: deleted sources leave detached tags with the original tag names,
  causing duplicate-name errors when the same source/channel is added again.
- Confirmed: deleted tags may leave references in spectrum/frequency settings,
  which can persist in the project even though the tag itself is gone.

## Change

- Added `TRecorderTagRegistry.RemoveTagsBySourceId`.
- `AddTag` now reclaims a name from an old `Detached:` tag before adding a new
  tag. Non-detached duplicate names still raise the original error.
- `RemoveTag` now clears references to the removed tag from:
  - selected tag name;
  - spectrum source bindings;
  - formula frequency-band terms. Empty formula bands are removed.
- Mera, MIC-140, MIC183/185, and generic hardware source deletion now removes
  tags owned by that source instead of converting them to `Detached:`.

## Expected Result

Deleting a source or removing a used channel should fully release the tag name
from the configuration, so adding the same channel again should not hit
`Tag name already exists`.
