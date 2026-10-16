---
name: sharedutils-catalog
description: Find, reuse, extend, and review shared Pascal utilities in OburecGH for Lazarus/FPC and Delphi. Use before creating reusable helpers, math/DSP routines, logging, async, encoding, formatting, object trees, queues, chart interactions, binary/file codecs, or porting code between D:\works\OburecGH\sharedUtils and Lazarus\SharedUtils.
---

# SharedUtils Catalog

Use this skill to avoid creating a second implementation of an existing shared
facility and to keep the catalog accurate as the libraries evolve.

## Required workflow

1. Before writing a universal helper, search both trees by responsibility and
   symbol, not only by the proposed name:
   - current cross-platform library: `D:\works\OburecGH\Lazarus\SharedUtils`;
   - legacy Delphi source/reference: `D:\works\OburecGH\sharedUtils`.
2. Read [Lazarus catalog](references/lazarus-sharedutils.md) to select the
   current canonical unit. Read [Delphi candidates](references/delphi-sharedutils.md)
   only when current Lazarus code lacks the required behavior or compatibility
   with legacy formats/algorithms matters.
3. Prefer extending the narrowest existing canonical unit. Create a new unit
   only when the responsibility is distinct, the dependency direction remains
   clean, and adding it to an existing unit would create an unrelated grab-bag.
   Treat `math/uCommonMath` as legacy compatibility: add a new coherent family
   such as statistics, binary I/O, timing, or filesystem operations to a focused
   `uShared*` unit instead of making that grab-bag larger.
4. Do not copy a Delphi unit wholesale. Separate pure logic from Windows/VCL,
   COM, UI, shell, database, or third-party dependencies; compare with the
   Lazarus counterpart and port only missing behavior with tests.
5. Treat `lib`, `backup`, `cach`, `.ppu`, `.o`, `.compiled`, `.bak`, `.test`,
   vendored JCL/TMS/FastMM/NativeXML/ZipMaster/alglib trees, and demos as
   artifacts or third-party sources, not as the project's canonical API.

## Canonical routing

- Common types, small geometry records, invariant math constants: `uCommonTypes`.
- Binary search and generic algorithms: `uSharedAlgorithms`.
- Short independent asynchronous work: `uSharedAsync`.
- Thread-safe application logging: `uSharedFileLogger`.
- Significant-digit formatting: `uSharedNumberFormat`.
- CP1251/UTF-8 and legacy text/XML boundaries: `uSharedStringEncoding`.
- Existing object trees and LCL helpers: `uBaseObjLaz` plus
  `uComponentServices`; do not introduce another `TBaseObj` family casually.
- Numerical/DSP work: inspect `math/uCommonMath`, `math/u2DMath`, and
  `math/uHardwareMath` before adding code.
- Charts: reuse `components/chart_lzr` models, series, listeners, cursors,
  serializers, and renderers instead of rebuilding interactions in forms.

## Mandatory maintenance rule

When adding, moving, renaming, deprecating, or materially expanding a universal
function or unit:

1. Put it in `Lazarus/SharedUtils` when it is useful to more than one Lazarus
   project and is not domain-owned by a single application.
2. Update the relevant reference in this skill in the same iteration: purpose,
   principal API, when to use it, dependencies, and any legacy/replacement note.
3. If the change came from Delphi SharedUtils, update its migration status in
   the Delphi reference (`candidate`, `partially ported`, `ported`, or
   `rejected`) and record the target Lazarus unit.
4. Search for duplicate implementations and migrate callers when safe; preserve
   compatibility adapters only when a real caller needs them.
5. Build the affected Lazarus projects on applicable platforms and run focused
   tests for math, binary formats, threading, encodings, or serialization.

For repository searches, exclude generated and vendored trees explicitly, for
example with `rg` globs for `!**/lib/**`, `!**/backup/**`, `!**/cach/**`,
`!**/jcl*/**`, `!**/TMSPack/**`, `!**/FastMM*/**`, `!**/NativeXml*/**`, and
`!**/alglib/**`. Inspect a third-party tree only when the task explicitly needs
that dependency.

The catalog is part of the library contract. A new universal helper without a
catalog update is incomplete.
