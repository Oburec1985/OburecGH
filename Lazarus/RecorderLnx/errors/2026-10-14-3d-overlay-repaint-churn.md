# 3D overlay labels cause redraw churn and flicker

## Symptom

On a mnemonic containing a 3D scene with point/bone labels, loading the form
became slow, labels flickered, and parts of the interface appeared to repaint
only after unrelated mouse movement over the menu.

## Confirmed source facts

- `TRecorder3dView.Paint` called `DrawHelperLabels` after the OpenGL frame.
- `DrawHelperLabels` hid every helper-label child window, then showed visible
  labels again on every paint, even when the label text and screen position had
  not changed.
- The routine also called `SetBounds` and `BringToFront` unconditionally for
  each visible label. These are child-window operations during parent painting
  and can trigger additional invalidation/repaint work.
- Point-number text is drawn to the control canvas and does not itself toggle
  child controls; the repeated helper-label visibility changes were the clear
  repaint-churn defect in the same render path.

## Fix

- Preserve current helper-label visibility across frames.
- Change caption, bounds, and visibility only when each value actually changes.
- Hide labels only when a bone disappears, becomes unnamed, or is no longer
  projectable.

## Verification

- `C:\lazarus\lazbuild.exe -B RecorderLnx.lpi` exited 0 and linked the app.
- Launched the resulting `lib\x86_64-win64\RecorderLnx.exe` against the same
  local `test185_149` profile shown in the report. The active page contained a
  3D point cloud and a Skin bone. A screen capture showed the complete page,
  point numbers, and bone label rendered; the process reported a live main
  window and `Responding=True`.
- Startup diagnostics report `LoadProjectPackage elapsed=8765ms`, while the
  active page's measured render was 16 ms (later updates 0–32 ms). Thus the
  observed slow phase is package/tag loading; the initial visual smoke did not
  reproduce an app-wide paint freeze after startup.
- Closed only the process started for this smoke test using `CloseMainWindow`;
  it exited normally.

## Remaining risk

The scene was opened and visually captured once, but continuous flicker across
repeated repaint/page switching was not recorded. Point-number labels are still
projected/drawn per paint, capped at 1000 attempts. If startup remains slow,
profile package/tag loading separately; the present log attributes 8.765 s to
`LoadProjectPackage`, not page rendering.
