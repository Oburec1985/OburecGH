# Error: OPC UA tree cache can belong to a different endpoint

## Symptom
- The editor shows a non-empty Browse tree while the configured endpoint is `opc.tcp://192.168.15.140:4840`; the tree had previously been read from `.130`.
- The user says the `.140` device has never been browsed successfully.

## Investigation facts
- The UI's “Проверить связь” operation only connects; it does not Browse. The screenshot's “Соединение установлено” therefore did not establish that the tree came from `.140`.
- Before this change, `browseCache` had no identity linking it to the endpoint that produced the snapshot.
- Earlier attempts ended at HEL/ACK, but the current reproduction establishes a UA session successfully. That first failure was transient, not the repeatable Browse failure.
- A successful Browse response from `.130` contained 108 nodes. This is a separate endpoint and does not validate `.140`.
- On `.140`, Browse repeatedly failed around 46 seconds into traversal with `service: connection closed`. The stream's socket `IOTimeout` was only 4000 ms, matching the normal Connect/Read/Write request timeout.
- The server accepts a Browse session and returns data, but the long traversal of 769 nodes cannot complete within that short per-response socket wait. The misleading “connection closed” text was a client-side read timeout, not proof that the server closed the session.

## Fix
- Persist `browseCacheEndpoint` alongside `browseCache`.
- On Refresh, if the endpoint differs from the cache source, clear the in-memory cache and rebuild the tree immediately before starting the request. A failed Browse therefore cannot leave `.130` presented as `.140`.
- On editor open, discard cache with a mismatched or missing source endpoint. Missing source means an older snapshot whose origin cannot be proved.
- Browse success/failure diagnostics include endpoint and found/cached node counts.
- Changing the endpoint also changes the datasource `SourceId`. Existing Recorder tags are retained by stable `recorderTagId`; for older configs without that field, the editor resolves them by the old `SourceId + NodeId`, then updates their `SourceId` while retaining Recorder name and tag ID.
- The settings dialog now unregisters the old active OPC UA `SourceId` and registers the new one after applying an endpoint change.
- Browse has a separate persisted `BrowseTimeoutMs` setting, visible in the datasource dialog as “Таймаут одного Browse/BrowseNext, с”. Default is 180 s, minimum 30 s; the socket wait and each Browse/BrowseNext/attribute-read RequestHeader TimeoutHint use `max(BrowseTimeoutMs, RequestTimeoutMs)`. The prior socket and request timeout are restored in `finally` after success or exception. The general 10 s TimeoutHint remains for regular read/write requests.
- Attribute transport failures that indicate a closed/truncated response now abort Browse with the failed node and path recorded, instead of silently continuing with an incomplete tree.

## Verification
- Forced Lazarus Win64 build to `lib/x86_64-win64/RecorderLnx-opc-cache.exe`: exit 0, 235374 lines compiled.
- After active-source rekey fix, forced build to `lib/x86_64-win64/RecorderLnx-opc-rebind.exe`: exit 0, 235380 lines compiled.
- Standard `RecorderLnx.exe` could not be relinked because it is running as PID 33120; it was not terminated.
- Standalone live-client reproduction against `opc.tcp://192.168.15.140:4840` after the timeout fix: Connect OK; Browse OK with 769 nodes; scalar STRING read of `ns=4;s=|vprop|SPK107 (M01).Application.SerialNumber` OK, quality `0x00000000`. Full Browse/read run took about 171 seconds and completed within the 300-second observation window.
- Final forced Win64 build after timeout-clamp and exception-safety adjustments: `lib/x86_64-win64/RecorderLnx-opc-browse-timeout-final.exe`, exit 0, 235445 lines compiled.

## Follow-up: interactive Browse and source status — 2026-10-28
- Batched BrowseRequests do not solve the 139–140 second full traversal on `.140`; requesting 16 parents in one service call was rejected by this server with `BadSessionIdInvalid (0x80250000)`. Batch size 2 remained valid but had no measurable speedup, so a large batch was not adopted.
- Added interactive mode to the OPC UA editor: read `Objects` first, then browse only the selected node's direct children. Production-client live probe against `.140:4840` returned 4 root children in 0.34 s and 2 children under DeviceSet in 0.40 s.
- Interactive branch results are merged into the endpoint-specific Browse cache and therefore persist with the datasource config. Existing same-endpoint cache stays visible while more branches are read.
- Successful probe now clears the offline marker for both the endpoint-derived OPC UA source id and the editor's configured source id. This addresses the red/failed-looking 5th datasource marker when its configured id differs from the synthesized endpoint id.
- Forced Win64 build passed to `lib/x86_64-win64/RecorderLnx-opc-interactive-browse.exe`: 236150 lines compiled, 0 errors. `git diff --check` passed.

## Follow-up: editor entry exception — 2026-10-28
- Symptom from debugger: opening OPC UA settings stops in `UpdateControlState` on `fInteractiveBrowseButton.Enabled := ...`.
- Root cause: the form is streamed from `uRecorderOpcUaSourceEditor.lfm`. The new button field was only instantiated in the constructor's legacy dynamic layout after an earlier unconditional `Exit`; meanwhile the active LFM construction path called `UpdateControlState` before that point. Thus the field was nil at the first update.
- Fix: declare `fInteractiveBrowseButton` in the LFM under the config panel with its caption and `InteractiveBrowseClick` handler. It now exists before the constructor's first `UpdateControlState`.
- Verification: forced Lazarus Win64 build to `lib/x86_64-win64/RecorderLnx-opc-editor-entry-fix.exe`: exit 0, 236150 lines, 48 compiler warnings (existing project warnings). `git diff --check` passed. GUI launch through CUA did not yield a targetable application window; user-side open confirmation remains outstanding.

## Remaining risk
- Browse is verified against `.140` through the standalone protocol client. Full in-application visual interaction was not repeated; the usual executable is locked by running PID 33120, so a separate build is used.
