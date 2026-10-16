# Point-cloud markers disappear between redraws

## Symptom

Point markers intermittently disappear/reappear while the 3D view is repainted.

## Reproduction and evidence

- A point-cloud node is followed by another opaque mesh in the scene node order.
- The point pass disables depth testing, so it does not write depth; a later
  opaque mesh can overwrite the marker color while leaving the underlying depth
  buffer otherwise valid. Repaint order makes the visual result appear unstable.
- The renderer contract explicitly treats editor points as overlays
  (`RenderPassUsesDepthTest(rpPoints) = False`).

## Fix

- Suppress the inline marker pass for nodes with point-cloud bounds enabled.
- Add a final point-cloud marker pass after scene geometry and selection overlays.
- Restore the prior depth-test state after the overlay pass.

## Verification

- `ThreeDInteractionTest.exe`: `RESULT ThreeDInteraction passed`.
- `lazbuild --build-all RecorderLnx.lpi`: both changed Pascal units compiled;
  final link was blocked with Windows error 5 because the existing
  `RecorderLnx.exe` was in use.

## Remaining risk

Visual confirmation with a scene containing later-drawn opaque occluders is
still required. The build needs one successful link after the running app is
closed; no process was terminated as part of this change.
