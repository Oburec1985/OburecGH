# Production Oscillogram DLL native smoke

## Scope and criterion

Load the real SampleInfoPlugin through the standard V2 loader, configure a
numeric tag binding, embed its native view and verify waveform/recreate/state.
No remote installation. Passing a fixture DLL does not prove this criterion.

## Confirmed findings

- Initial harness supplied an absolute plugin path, but the production catalog
  deliberately stores a basename and loads executable/plugins. Stage the DLL in
  that isolated directory, matching PluginVisualModelTest.
- First real attachment returned ERROR. Narrow temporary dispatch logging
  reported `EOscDataRead: History capacity 102 required; prepared 0`.
- PrepareHistoryBuffers iterated an empty snapshot-record array. Refresh later
  created records whose history arrays had never been prepared. Allocate the
  records in the cold preparation phase before preparing each history array.
- After the fix, the real loader/configure/state/attach path reaches a native
  root and chart. Win32 reports form/host/plugin windows visible.
- A test starting at 170x50 also exposed a preferred-size layout loop. The
  harness now realizes its host form before attaching; small-size resilience
  remains an explicit production UI gate, not a verified fix.
- BaseSurface had the same preparation omission. Its cold Rebuild now prepares
  snapshots; populated two-tag OscViewSmoke passed (5000 samples/tag, changed
  time window, stable runtime buffer addresses and revision skip).
- Editor candidate selection overwrote an existing line before Add. Explicit
  Apply separates selection from commit; realistic OnChange/add/apply/OK/cancel
  OscSettingsSmoke passed.
- Tag catalog Configure now stages all new objects before publication; failure
  regression passed with zero heaptrc leaks.

## Earlier capture attempts

Production waveform pixel smoke initially FAILED: the GDI chart scan sees eight blue
pixels, while BitBlt of the OpenGL surface is black. Screen-DC sampling was slow
and provided no stronger evidence, so that attempt was stopped. This does not
prove waveform rendering or a particular renderer defect. Do not relax the
assertion or mark the whole production migration accepted. Obtain a reliable
OpenGL/native-window capture and distinguish data geometry from presentation.

Temporary dispatch logging removed. SDK runner now builds/stages the real DLL
and runs GUI fixtures with bounded timeouts and stdout/stderr logs. Full host
forced build succeeded at _buildverify_plugin_0174/RecorderLnx.exe (0.1.174).

## Prevention

When caller-owned history buffers are required, create the entire snapshot
collection and prepare every primary/additional/base-page array in cold
Configure/Rebuild. Runtime reads must not create unprepared entries. Verify
with populated data, not construction with an empty registry.

## Follow-up: actual framebuffer and migration confirmed

The current native WGL context was verified against the chart HWND. GL_FRONT
readback proves the signal: interior blue pixels 70, clear history 0, refill70,
resize/recreate74; amplitude span also checked. Native framebuffer BMP was
viewed and shows the supplied +/-8 mV sine. The black GDI screenshot was a
capture limitation, not evidence of absent rendering. The assertion was not
relaxed.

SDK2.4 adds generic ImportState and CATALOG_CHANGED. Real project smoke now
passes full old INI -> missing-plugin preservation -> plugin-owned import ->
native save/reload, including Unicode, IDs, axes, lines, trigger and cursors.
Actual Russian-locale WriteFloat produced commas; plugin legacy parsing now
accepts comma/dot decimal separators without host-side normalization.

Independent audit identified silent-default risks in malformed/future envelope
fallback and unguarded optional callback tails. Fixed both. Negative tests pass:
malformed/missing hex errors, unknown format remains an unbound byte-identical
placeholder with installed plugin, invalid import preserves prior native state.
Minimal descriptor carries poisoned optional slots outside Size; host does not
invoke them. Unit/catalog rename/fs10000 tests and native modal owner/focus tests
pass. Base-form LFM/count/resize/FPS tests pass separately.

Full architectural goal remains open: host-specific model/view/factory/routes
and old serialization still exist; generic alias discovery/base-slot wiring,
host deletion, GTK2 and final independent full-goal audits remain required.
