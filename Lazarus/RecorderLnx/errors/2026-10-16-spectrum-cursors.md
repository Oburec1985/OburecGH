# Spectrum cursor interaction

## 0.1.184 — follower and draggable horizontal level

FollowPeakItem is available on a vertical cursor line; it binds that X1/X2 to
the selected spectrum series. Fresh data for that series triggers the shared
bounded maximum search; unrelated selection changes do not rebind it. The
search uses cached display geometry refreshed by rendering, supports log X,
does not allocate or look up names, and leaves X intact for empty/invalid data.
Reconfiguration clears non-owning cursor/series references before freeing them.

Cursor label placement now has separate persisted left/right flags. Drawing
and hit testing share ChartCursorLabelRect; dragging either label across its
line changes side without changing X. Old JSON defaults to the former right
placement. Horizontal cursor dragging uses its own axis value conversion and
validates live page/overlay/axis membership before dereferencing drag state.

Verified: native SpectrumUiSmoke with EventBus fresh spectra (local moving peak,
larger far peak ignored, no fresh data, off, two cursors, binding, empty frame,
reconfigure, log X). Shared CursorSnapSmoke covers both label drags/JSON plus
horizontal drag on a secondary log-Y axis and prior Shift/Home behavior. Forced
EXE/plugin 0.1.184 and full native plugin/user-project smoke passed.

Request: horizontal level cursor via right-click with its value; reliable Shift
maximum snap. The related plugin Oscillograph request removes unused axes.

Confirmed Shift cause: shared cursor listener selected whichever window min/max
was closest to mouse world-Y, so Shift could choose a trough. Radius converted
only X+10 into a symmetric world interval, distorting the window on log X.
Selected hidden/off-page series and the first empty axis could also interfere.

Fix: Shift=max, Ctrl+Shift=min, exact X-10/X+10 screen bounds, finite inputs,
visible/current-page selection and stable nearest-X tie-break. MouseDown applies
the snap too. No mode-string comparison or allocation is added to the mouse loop.

Spectrum uses a designer-backed TSpectrumCommands data module for its popup;
the canonical page-owned TChartHorizontalCursor supplies the overlay. Optional
ShowLabel is rendered in OpenGL using axis DisplayScale/DisplayUnit once.
Pointers are cleared before page children are freed during reconfiguration.

An implementation attempt cast the Renderer interface directly to its concrete
class, causing an AV in font metrics. Rejected/fixed: GetRenderer returns the
actual object and must be used for that cast. SpectrumUiSmoke reproduces the
real context event and command path; it now passes.

Verification: CursorSnapSmoke real chart listener mouse/key events PASS (log X,
negative DX, NaN/Inf, hidden/off-page series, secondary axis, Home/CtrlHome).
SpectrumUiSmoke popup/secondary-axis/label/hide/reconfigure PASS. Plugin model
and modal editor empty-axis tests PASS. Production native plugin smoke with all
7 local user-project pages and waveform/clear/refill/recreate PASS.
Forced main and plugin builds: 0.1.183, exit 0. Deployment evidence is recorded
in the iteration log after the MIC-315 binary/hash/configuration checks.
