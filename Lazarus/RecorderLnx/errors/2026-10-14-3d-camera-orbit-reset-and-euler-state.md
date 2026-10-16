# 3D camera orbit reset and Euler-based state

## Symptom

Starting camera rotation could jump to a scene/object-centered pivot instead of
using the camera target established by pan. Rotation state also depended on
yaw/pitch values, so loading or invalidating the pose could reconstruct the
orientation from Euler angles rather than continuing from the current pose.

## Evidence and root cause

- `PrepareCameraRotationPivot` was called on overlay mouse-down and replaced
  the current target with the selected node pivot or scene-bounds center. The
  behavior entered in commit `bcef0e1c` (2026-10-07).
- `T3dCamera` and `T3dOrbitCamera` retained yaw/pitch/roll fields, and
  `BuildCameraBasis` regenerated the orientation from them whenever the pose
  was marked invalid. The component model persisted those angles rather than
  the camera basis.
- The reference implementation in `plgControlCyclogram` transforms the camera
  node around a target matrix using axis-angle node transforms, then derives
  the view with `gluLookAt`.

## Fix

- Camera orbit now keeps the existing target; pan target is not replaced when
  rotation starts.
- Runtime camera orientation and project persistence now use the orthonormal
  Forward/Right/Up basis only. Euler camera fields and fallback math were
  removed. Axis-angle rotations continue to update that basis around the
  existing target.
- Version incremented to 0.1.168.

## Verification

- `ThreeDInteractionTest` passes, including a regression test that pans to a
  non-origin target and verifies orbit preserves that exact target.
- `ThreeDMathTest` passes.
- Full RecorderLnx build and link succeeded after the running application was
  closed.
- Static search in the camera runtime/model/persistence paths found no
  yaw/pitch/roll fields or calculations.

## Compatibility note

Project files that only contain the removed `CameraYaw`/`CameraPitch` keys do
not carry a saved camera basis, so they open at the default camera orientation
until saved with this version. Target position, distance, projection and other
settings remain persisted. No Euler compatibility conversion is performed,
per the explicit camera invariant.

## Follow-up: camera overlay drag micro-jump

The follow-up symptom was small jumps while dragging the red/green axis or blue
ring handles. `T3dCameraRotateOverlay.UpdateDrag` returned before updating
`fLast` while the 3-pixel drag threshold had not been crossed. Thus a gradual
1-pixel-at-a-time gesture applied all accumulated movement in one first drag
event. The axis mapping itself matches the original ControlCyclogram overlay:
green horizontal = Y, red vertical = X, blue ring = Z.

Updated `fLast` on each below-threshold event so pre-drag movement is discarded
instead of replayed as a jump. Extended `ThreeDInteractionTest` to cross the
threshold one pixel at a time and require the first applied delta to be one
pixel. The focused test passes. Remaining risk: verify pointer feel in the
user's target UI when RecorderLnx is next opened; current request says the app
was closed, so no GUI run was attempted.

## Follow-up: axis-handle rotation drift

The next UI report narrowed the remaining issue to dragging the red and green
axis handles (and the blue ring). Inspection showed the overlay path called
`RotateCameraConstrained` for every mouse event; that routine selected the
current camera Right/Up/Forward basis anew on each event. The overlay itself is
screen-stationary, so the effective rotation axis moved during one continuous
gesture. A fixed-axis rotation primitive was added, and the widget snapshots
the selected camera basis vector when the handle drag begins. All deltas in
that drag now rotate around the captured axis; the next drag captures a fresh
axis. The blue ring still converts cursor movement to angular delta.

Added a regression that applies 100 incremental rotations around one captured
axis and checks the final pose equals a single 20-degree rotation about that
axis. `ThreeDInteractionTest` forced build and run pass. RecorderLnx forced
the standard `lib/x86_64-win64/RecorderLnx.exe` was locked by PID 33736, so it
was not terminated or overwritten. The forced build was repeated with output
`lib/x86_64-win64/RecorderLnx-0.1.169.exe` and completed/link succeeded. Visual
pointer verification remains pending because the open instance is still the
older standard binary.

## Follow-up: axis-handle sensitivity

The user reported the camera rotation now works but feels jumpy on the red and
green screen-space axes (and blue ring). The red/green handles used a fixed
0.5 degrees per pixel, while the blue ring used cursor angle around its centre.
Red/green sensitivity therefore did not scale with the visible overlay radius.
Added a shared axis-drag conversion that maps tangent pixels to radians using
the current overlay radius, then to degrees. Camera and Ctrl-object rotation
use the same conversion. Added focused checks for radius scaling, axis sign,
and zero-delta behavior. Version incremented to 0.1.170. Build/UI verification
is pending.

## Follow-up: camera drag loses most of short dx/dy

The user reported that camera rotation around the colored local axes again had
only a very small usable angle. The widget captured the camera pose and pointer
at MouseDown, but on the first event past the drag threshold it overwrote both
with the current pose and point, then did not calculate an angle until a later
MouseMove. This rebased the gesture and discarded its initial movement.

The drag now keeps the MouseDown pose, pointer, and overlay center as its
absolute origin. Every drag event applies its total dx/dy (or signed cursor
angle for the ring) to a fresh copy of that captured pose around the captured
camera-local axis. No yaw/pitch or per-event accumulated rotation is used.
Version incremented to 0.1.172.

Verification: forced `ThreeDInteractionTest` build and run passed, including a
regression for the first threshold-crossing movement and a 50-event absolute
drag. Full `RecorderLnx.lpi` forced build/link passed to
`_buildverify_camera_0172/RecorderLnx.exe`. Manual pointer feel remains to be
confirmed in the running UI; the angle path is now verified by deterministic
tests, but no GUI automation was available in this pass.

## Follow-up: repeated constrained-axis complaint, native widget verification

On 2026-10-14 the user again reported only small angles around the red/green
handles and specified total mouse dx/dy from MouseDown, fixed angular step,
camera-local captured axes and an unchanged panned target. Inspection found
that this exact contract is already present in `T3dLclWidget.MouseDown` and
`MouseMove`: a captured pose is restored and total delta is multiplied by
0.5 degrees/pixel. `TRecorder3dView.ViewChanged` persists the pose without
replacing it. No yaw/pitch path or constrained angle clamp was found.

Added `ThreeDWidgetRotationTest.lpi/lpr`: it creates a native LCL widget and
executes the actual MouseDown/Move/Up path, not just math helpers. Red/green
gestures reach -400/+400 degrees in 100 events from an oblique camera basis,
preserve translated target (8,-3,2), radius and captured axis, and return to
the exact start pose on reversal. An independent cosine oracle checks angular
response, so matching a shared helper cannot hide a clamp. Forced build and
bounded run passed. `ThreeDInteractionTest` also passed. Forced complete app
build passed to `_buildverify_camera_contract/RecorderLnx.exe` (0.1.174).

No production behavior was changed and no version was incremented for tests
alone. The reported live symptom remains unconfirmed: the existing Recorder
process was attached to Lazarus debugging and no targetable visible application
window was available. A stale-binary explanation is not established. Next step:
capture actual pointer events and active executable/version in the user's
failing scenario; do not claim this repeat complaint fixed by these tests.
