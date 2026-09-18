# Windows: delayed window movement during drag

## Observation

On Windows the main and settings windows could follow the pointer with visible
latency. The report of a second cursor-like image is consistent with stale
frames being presented while the Windows modal move loop is busy.

## Change

The main form now disables its expensive GUI timers when Windows sends
`WM_ENTERSIZEMOVE` and restores them on `WM_EXITSIZEMOVE`. Data acquisition
workers are not stopped. A drag trace records local PC time, cursor position,
window rectangle, deltas, and interval for both forms in
`WindowDragTrace.csv` under the Recorder service/configuration directory.

## Verification

The Windows target was rebuilt successfully as
`_buildverify/RecorderLnx_drag_pause.exe` with Lazarus/FPC.

