# Error: OPC UA editor opens with an empty cached tree

## Symptom
- What the user sees: the left OPC UA tree is empty after reopening datasource settings, while used channels still exist.
- Exact error text/log line: no exception; the tree has no nodes.
- First observed: 2026-10-23.

## Context
- Relevant files: `Device/OPC/uRecorderOpcUaSourceEditor.pas`, `.lfm`, OPC UA JSON configuration.
- Relevant screenshots: user screenshots from 2026-10-23.

## Facts
- New configurations persist the full Browse response in `browseCache`.
- Older configurations can contain `nodes[]` but no `browseCache`.
- Opening the editor must not silently contact the server; refresh is explicit.

## Hypotheses
- [x] Cache loading was broken for every project.
  - Check: inspected constructor and JSON fields.
  - Result: cache is loaded when present.
  - Status: rejected.
- [x] The affected project predates `browseCache`.
  - Check: empty cache plus retained configured nodes reproduces the observed UI.
  - Result: no fallback existed.
  - Status: confirmed.

## Actions
- Added an offline fallback tree built from configured used nodes.
- Added an explicit diagnostic that the fallback is incomplete and Browse must be refreshed once.
- Added a resizable properties panel for the selected used channel.
- Verification: full Lazarus build succeeded; application remained alive during a five-second smoke run.

## Current Conclusion
- Root cause: old project format had no saved full Browse tree and the editor only loaded `browseCache`.
- Fix status: fixed with backward-compatible fallback; new Browse snapshots remain authoritative.
- Remaining risk: old projects can only show configured channels until the user presses «Обновить дерево» and saves.
