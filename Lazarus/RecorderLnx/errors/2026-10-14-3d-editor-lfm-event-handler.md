# 3D editor: LFM event handler cannot be resolved

## Symptom

Opening the 3D scene object editor aborts while reading the form resource:

`Error reading objectNameEdit.OnEditingDone: Invalid value for property.`

## Reproduction

1. Open a mnemonic containing the 3D component.
2. Open the scene tree.
3. Double-click a scene object to enter the object editor.

## Confirmed facts

- `objectNameEdit.OnEditingDone` in `uRecorder3dSettingsDialog.lfm` points to
  `ObjectPropertiesChanged`.
- The method existed in the form class but was declared in `private`.
- LCL streaming resolves named event handlers through published method metadata.

## Root cause

The `.lfm` referenced an event handler which was not published by the form
class. The resource compiled, but loading the form failed at runtime.

## Fix

Moved `ObjectPropertiesChanged(Sender: TObject)` into the form's `published`
section. The visual hierarchy remains designer-owned in `.lfm`; no runtime UI
creation was added.

## Verification

- Forced build: `lazbuild -B RecorderLnx.lpi`.
- Result: exit code 0; `RecorderLnx.exe` linked successfully.

## Remaining risk

## Geometry editing selection regression

Changing point-cloud subdivisions called `OnSettingsApplied`, which invoked
`ApplyComponentConfiguration` and `AttachLiveScene`; the latter cleared and
rebuilt the tree. Geometry itself was already replaced on the existing node.
Added `OnGeometryChanged` and a view handler which reconfigures mesh-dependent
Skin/color evaluators and marks the viewport dirty without reattaching the
scene. Node identity, transforms, and tree selection remain intact.
Forced main build compiled all units but linking was blocked by the running
`RecorderLnx.exe` (Windows error 5). Runtime verification remains pending.

Interactive opening of the dialog still needs the user's normal application
scenario; compilation validates the resource and handler declaration but is
not a substitute for a GUI smoke test.
