# Object selection shifts while changing 3D properties

Rebuilding the editor tree emitted selection callbacks while nodes were only
partially populated. Those callbacks selected an intermediate/previous node in
the viewport. Full configuration also reused SelectedNodeId after resetting
the scene instead of preserving the original selection.

Tree rebuilding now suppresses selection callbacks with fRebuildingTree and
BeginUpdate/EndUpdate, then loads only the final selected item. The viewport
captures the selected node ID before configuration and restores it after the
scene/evaluators are ready, before reattaching the editor.

Forced main build compiled all units; linking blocked by running RecorderLnx.exe
(Windows error 5). Runtime verification and final executable remain pending.
