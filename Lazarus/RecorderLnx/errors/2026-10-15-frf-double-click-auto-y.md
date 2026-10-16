# FRF disappears after double-click reset

UPDATE: user confirmed restored manual limits are intentional. The automatic
Y-fit change and its new test were reverted. Double-click restores configured
Y limits in both modes. Rebuilt RecorderLnx-frf-reset.exe successfully.
The original diagnosis below was rejected by clarified product requirements.

RestoreFrequencyPage restored stored manual Y bounds even with AutoScale=True.
FRF values below that manual minimum were clipped; reverse zoom fitted them
and made them visible again. Reset now fits current data for automatic Y and
retains explicit manual bounds only when AutoScale=False. User zoom flags are
cleared. Saved X limits are retained.

Verification: forced app and UI test builds OK. UI smoke stage log reached
zoom regression passed, including manual 2000 upper-bound reset and automatic
reset with dormant manual Y limits 1E20..1E21. The remaining full UI test
exited 1 after that stage without console details; this is not a full-suite pass.
Rule: auto-reset must not reinstate dormant manual bounds; test both modes
with data outside the manual range.
