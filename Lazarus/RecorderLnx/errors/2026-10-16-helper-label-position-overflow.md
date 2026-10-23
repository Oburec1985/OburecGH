# Helper caption overflows native move/size coordinates during orbit

User observed ELayoutException in SendMoveSizeMessages during camera rotation:
Left=-137624, Top=105765. DrawHelperLabels projected helper origins and passed
unbounded screen coordinates to a native TStaticText.SetBounds.

Added visibility checks before rounding/SetBounds: reject non-finite projected
coordinates, depth outside [0,1], and positions outside the viewport. Hide the
caption until its anchor re-enters the viewport. This avoids Win32 signed
16-bit move/size overflow near the perspective eye plane.

Verification: forced RecorderLnx.lpi build exit 0, main executable linked.
Interactive reproduction not performed.
