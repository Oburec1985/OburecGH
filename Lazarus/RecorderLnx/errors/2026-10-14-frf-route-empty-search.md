# FRF route: empty channel selector prevents adding points

Symptom: route editor opens with an empty channel selector; Add silently does nothing.
Cause: SearchChange required Pos(search, name) > 0 even for an empty search.
FPC returns zero for the empty substring, removing every configured channel.
Fix: empty/whitespace search lists all responses; nonempty search matches a
case-insensitive substring. ReadEntry reports missing channel/object instead
of silently returning.
Regression prevention: cover initial empty search, substring filtering and
clearing search in ImpactHammerUiSmoke --route-search-only.
Verification: focused UI test passed; RecorderLnx-route-add.exe compiled.
Full application runtime and remaining route navigation integration are not
covered by this focused test.
