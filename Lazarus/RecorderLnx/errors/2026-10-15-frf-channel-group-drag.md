# FRF settings: group drag reduced to one channel

The destination already iterates all selected tags. The native extended-select
list collapses the group on the plain mouse-down used to begin dragging.
Fix: intercept LM_LBUTTONDOWN on an already-selected member of a group before
native selection handling; begin drag without changing selection. Ctrl/Shift
and clicks on unselected items continue through the original control procedure.
The hook is owned by the dialog and installed after LFM construction.

Regression: ImpactHammerUiSmoke --multi-tag-drag-only selects three channels,
sends a mouse-down at a selected item, verifies three remain selected, drops
onto the tree and verifies all three response nodes plus hammer.
Result: PASS; forced app and smoke builds succeeded.
Prevention: multi-selection alone is insufficient for drag sources; test the
mouse-down-to-drop sequence, not just invoking a drop handler with preset flags.
