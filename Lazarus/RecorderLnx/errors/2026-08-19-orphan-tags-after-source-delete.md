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

## 2026-08-19 follow-up

### New Facts Checked

- Active default project is `C:\Mera Files\RecorderLnx\config\projects\003`.
- `projects\003\default.config.json` does not contain `1_датчик_X`.
- `projects\003\default.gui.ini` still contains `TagName=1_датчик_X` and
  `Tag0=1_датчик_X`. This is expected: broken form bindings must remain visible
  as broken bindings and should start working again if the tag is recreated.
- The duplicate can therefore be held by the currently running in-memory tag
  registry, or by older project JSONs, not by the active `003` tag JSON.
- Mera-file tags are marked `IsVirtual=True`; this must not be confused with
  manual virtual tags. Manual tags use `SourceId=manual`, while Mera tags have
  `SourceId=Mera file: ...`.

### Hypotheses

- Confirmed: cleaning GUI references would be wrong. A form reference to a
  missing tag is a useful visible broken binding.
- Confirmed: a tag whose `SourceId` is no longer present in canonical
  `dataSources` is an orphan and can keep its name reserved.
- Rejected for now: broad reclamation inside `AddTag`; it could hide a real
  duplicate from a valid source.

### Change

- Added `TRecorderSettingsDialog.RemoveTagsFromDeletedSources`.
- The cleanup runs before manual virtual-tag creation and during settings OK,
  both before and after `fSourceProbe.SyncToRegistry`.
- It removes only tags whose normalized `SourceId` belongs to a Mera/hardware
  source absent from `ConfiguredDataSources`.
- It skips manual tags, diagnostics, spectrum-estimate tags, empty source ids,
  and old projects with an empty `ConfiguredDataSources` list.
- Removed tags are logged through `RecorderDebugLog` with the source id.

### Verification

- `rg` confirmed that active `003/default.config.json` has no
  `1_датчик_X`; only `default.gui.ini` references it.
- `git diff --check -- Lazarus\RecorderLnx\UI\uRecorderSettingsDialog.pas`
  passed. Build was intentionally not started because `RecorderLnx.exe`
  was running from `lib\x86_64-win64` as PID 19964.

## 2026-08-19 second follow-up

### New Fact

- The user reproduced the stop in `TRecorderTagRegistry.AddTag` for
  `1_датчик_X` after the tag was already absent from the saved project JSON.
- Cleanup only on settings OK is too late for paths that create/relink a tag
  immediately from the channel list.

### Change

- Added a single predicate `TagBelongsToDeletedSource`.
- Added `RemoveDeletedSourceTagByName`.
- `CreateSelectedMeraTags` now tries to release a same-name tag from a deleted
  source before falling back to a unique `..._2` name.
- Manual virtual-tag creation also runs deleted-source cleanup before duplicate
  validation.

### Verification

- `git diff --check -- Lazarus\RecorderLnx\UI\uRecorderSettingsDialog.pas`
  passed. Build was intentionally not started because `RecorderLnx.exe` was
  running from `lib\x86_64-win64` as PID 9540.

## 2026-08-19 third follow-up

### Clarification

- The cleanup must not depend on any fixed tag name. `1_датчик_X` is only the
  reproduced example.
- GUI/form references are allowed to point to missing tags and must not be
  deleted. They are not real tags and must not participate in uniqueness.

### Facts

- `TRecorderTagRegistry.AddTag` checks only `fTags` through `FindByName`.
  Form references from `default.gui.ini` do not enter this list.
- Therefore a duplicate in `AddTag` means a real `TRecorderTag` object with
  that name is still loaded in memory.

### Change

- Added project-level `ProjectTagBelongsToDeletedSource` in
  `uRecorderProjectFiles.pas`.
- `LoadRecorderProjectConfig` skips tags whose source is absent from
  `dataSources`.
- `SaveRecorderProjectConfig` also skips such tags, so a stale in-memory tag is
  not written back to `default.config.json`.
- `TRecorderTagRegistry.AddTag` now logs full duplicate details
  (existing/new id, source, address, module) before raising for a real live
  duplicate.

### Verification

- Initial build failed on a Pascal `if/else` syntax mistake in
  `uRecorderSettingsDialog.pas`; fixed the branch structure.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.

## 2026-08-19 fourth follow-up

### User Request

Add logging or an exception in `AddTag` to catch where the parasite tag appears
before the user creates it.

### Change

- Added temporary `AddTag` trace logging in `Core/uRecorderTags.pas`.
- Every `AddTag` request is logged with tag id, name, source id, address and
  module type.
- Successful additions are logged as `added`.
- Reclaimed detached duplicates are logged as `remove-detached-existing`.
- Real duplicates are logged as `duplicate-existing` and the raised
  `ERecorderTagError` now includes existing/new id, source id, address and
  module type.
- The first version also tried to include a caller stack using FPC frame
  helpers.

### Verification

- Rebuild reached the link step, which means the new Pascal code compiled.
- Linking failed because the running application owns
  `lib\x86_64-win64\RecorderLnx.exe` (`error code: 5`). This matches the normal
  user workflow where RecorderLnx may be open during debugging.

### Next Check

- Reproduce the issue and search `LogWindows.log` for `[Tags.AddTag]`.
- The first `added` entry for the duplicated name is the source of the
  parasite in-memory tag.

## 2026-08-19 fifth follow-up

### Symptom

The temporary caller-stack trace caused a new Access Violation while adding a
tag:

`Access violation reading from address $0000000002207C8` at
`lAddr := get_caller_addr(lFrame)`.

### Fact

- The failure is in the diagnostic code, not in the original tag-add logic.
- `get_caller_addr` over a manually walked frame pointer is unsafe in this
  Lazarus/FPC runtime context.

### Change

- Removed `RecorderTagStackTrace`.
- Kept the useful non-crashing `AddTag` diagnostics:
  `request`, `added`, `remove-detached-existing`, `duplicate-existing`.
- Duplicate exceptions still include existing/new id, source, address and
  module.

### Verification

- `git diff --check -- Lazarus/RecorderLnx/Core/uRecorderTags.pas` passed.
- `lazbuild -B RecorderLnx.lpi` compiled to the link step.
- Linking failed only because `lib\x86_64-win64\RecorderLnx.exe` is still held
  by a running process (`error code: 5`).

## 2026-08-19 sixth follow-up

### Symptom

After adding tags and pressing OK, `ERecorderTagError` is raised:

`Tag name already exists: 1_датчик_X. Existing id=2820 source="Mera file:
D:\works\mera\mera files signals\shocks\signal0005\signal0005.mera"
address="1- 2- 1" module="MC-201"; new id=2840 source="" address="" module=""`.

### Facts From Log

- At 17:39:42 the Mera tags `1_датчик_X`, `1_датчик_Y`, `1_датчик_Z`, ...
  were created once.
- At 17:39:45, while applying settings, the Mera-file source tried to create
  `1_датчик_X` again.
- The existing tag is a real Mera tag, not a form reference and not a deleted
  source.
- The duplicate happens because Mera runtime/configure code only matched
  existing tags by `SourceId + Address`. If address spelling/indexing changes,
  it misses the existing tag and calls `CreateTag` with the same name.

### Change

- In `Core/uRecorderDataSources.pas`, `TRecorderMeraFileDataSource.ConfigureTags`
  now:
  - still first matches tags by `SourceId + indexed address`;
  - then falls back to `FindByName` when the found tag belongs to the same
    Mera source;
  - updates/relinks that tag instead of creating a duplicate;
  - if the same name belongs to another source, creates a unique suffixed name
    instead of raising during configuration.

### Verification

- `git diff --check -- Lazarus/RecorderLnx/Core/uRecorderDataSources.pas
  Lazarus/RecorderLnx/Core/uRecorderTags.pas` passed.
- `lazbuild -B RecorderLnx.lpi` compiled to the link step.
- Linking failed only because `lib\x86_64-win64\RecorderLnx.exe` is held by
  the running RecorderLnx process (`error code: 5`).
