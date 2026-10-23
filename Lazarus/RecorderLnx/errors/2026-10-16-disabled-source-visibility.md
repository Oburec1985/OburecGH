# Disabled source presentation

Request: gray disabled sources in the device tree, hide their tags, and do not
count them as hardware errors. Preserve source/tag configuration for reenable.

Facts: main hardware badge already excludes ConfiguredDataSource.Enabled=False.
Tree showed [ВЫКЛ] and a disabled icon but lacked gray text. Main active-source
refresh could register a disabled source if its cached link was still healthy.
Canonical tag visibility returned True early for virtual tags, and existing
MERA files bypassed inactive-source membership.

Fix: tree custom drawing inherits disabled source appearance for descendants;
main active-source refresh requires enabled + link; canonical visibility checks
configured enabled before virtual/file/activity fallbacks. Hardware error cache
is preserved, while disabled sources remain excluded from the existing badge.

Verification: forced main build exit 0, version 0.1.181. Focused
RecorderTagsTest --disabled-source-only exit 0: cached active hardware,
virtual flag, existing file, reenable, manual and preserved tag configuration.
Full RecorderTagsTest has an unrelated failure in TestTagBlockEstimates:
measurement blocks are not copied through EventBus, expected 0, got 1.
Live tree color was not visually checked; no remote machine was changed.
