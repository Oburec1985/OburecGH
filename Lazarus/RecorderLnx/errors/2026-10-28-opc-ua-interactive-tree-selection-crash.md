# OPC UA interactive Browse crashes while rebuilding tree

## Symptom
- Clicking «Интерактивное чтение» stops the debugger in `RebuildBrowseTree` while it captures multiselection through `fBrowseTree.Selections[I]`.
- The first click also changes the simplified-tree checkbox, whose `OnChange` rebuilds the tree synchronously.

## Confirmed facts
- The failing line repeatedly resolves the same mutable LCL selection-list index (`SelectionCount` and `Selections[I]`) while rebuilding a multiselect tree.
- Browse tree nodes store `Data` pointers to objects owned by `fTreeItems`; freeing the model while old tree nodes remain would leave dangling node data.
- Exception text/type is not visible in the provided screenshot. Full UI reproduction was not possible because the launched test executable did not expose a targetable window.

## Fix
- Capture selection by walking existing tree nodes and checking `TTreeNode.Selected`, without indexing `TTreeView.Selections[]`.
- Use the same direct traversal when collecting selected browse items or checking whether a browse selection contains usable nodes.
- Before freeing/replacing `fTreeItems`, clear the old `fBrowseTree.Items`; preserve selected NodeIds in a temporary list and pass them into the next rebuild.

## Verification
- Forced Win64 Lazarus build: `lib/x86_64-win64/RecorderLnx-opc-interactive-tree-lifetime-fix.exe`; exit 0, 236204 lines compiled, 48 warnings, 544 hints.
- `git diff --check` passed.
- CUA launch attempt did not expose a targetable window; interactive button click is not yet confirmed in a running GUI.

## Remaining risk
- The debugger screenshot identifies the failing expression but omits the exception message. The multiselection access path is removed from Browse-tree rebuild and node lifetime ordering is made explicit; confirm the original click path in the user's normal runtime.
