# Delphi SharedUtils reference and migration candidates

Root: `D:\works\OburecGH\sharedUtils`.

This is a source/reference tree, not a library that Lazarus projects should add
directly to their search path. It mixes project-owned units with Windows/VCL
code and large third-party snapshots.

## Contents

- [Existing counterparts](#existing-counterparts)
- [Migration candidates](#migration-candidates)
- [Domain and platform-specific areas](#domain-and-platform-specific-areas)
- [Third-party and archived trees](#third-party-and-archived-trees)

## Existing counterparts

These already have Lazarus versions. Diff them before porting missing behavior;
never create another unit solely because the Delphi copy has a different API.

| Delphi area | Lazarus target | Status |
|---|---|---|
| `uCommonTypes` | `Lazarus/SharedUtils/uCommonTypes` | Ported; Lazarus version intentionally removes Windows keyboard dependencies |
| `math/uCommonMath` | `Lazarus/SharedUtils/math/uCommonMath` and focused `uShared*` units | Partially ported; extract only pure missing helpers |
| `math/u2DMath`, Graham-scan code | `Lazarus/SharedUtils/math/u2DMath` | Ported; hull is reentrant monotonic chain, legacy global-pivot units are rejected |
| `math/uHardwareMath`, FFT units | Lazarus math/DSP units | Ported/parallel implementations; choose via dispatcher and benchmark |
| event types/lists | `uEventTypes`, `uEventList` | Ported for legacy event architecture |
| queue implementations | chart `uSharedQueue` or a focused future shared queue | Candidate for consolidation, not another blind copy |
| logging | `uSharedFileLogger` | Replaced |

## Migration candidates

| Priority | Delphi source | Useful behavior | Target and constraints | Status |
|---|---|---|---|---|
| High | `uBinFile` | Legacy primitive/string binary I/O | Fixed-width safe core is ported to `uSharedBinaryIO`; legacy `TValueType` adapter remains blocked on golden files | Partially ported |
| High | `math/uMyMath`, `uListMath` | Bounds search, rounding, median filter, mean/variance/RMS/covariance/correlation | Statistics are ported to `math/uSharedStatistics`; bounds use `uSharedAlgorithms`; broken median/rounding code was rejected | Partially ported |
| High | `math/uGrahamScan*` | Convex hull and diameter | Useful behavior is ported into `math/u2DMath`; duplicate global-state units are rejected | Ported |
| Medium | `math/uMNK` | Gaussian elimination, inverse matrix, polynomial least squares | Create `math/uLeastSquares` only for a real caller after checking FPC libraries; remove `OleVariant` API and add numerical tests | Candidate |
| Medium | `mera/uMeraSignal`, `uBuffSignal`, `uMeraFile` | MERA signal model and measurement-file compatibility | Separate data codec/model from VCL/UI into `uMeraSignal` and `uMeraFileCodec`; require golden legacy files | Candidate |
| Medium | `utils/uPerformanceTime`, `PerformanceTime` | High-resolution timing | Consolidate duplicate Windows QPC units into a cross-platform monotonic `uSharedTiming` only when a caller needs it | Candidate |
| Medium | pure parts of `uPathMng`, `PathUtils` | Search, copy, relative/temp paths | Port selected operations through FPC/Lazarus file APIs into a focused `uSharedFileSystem`; keep shell/UI and destructive deletion out | Candidate |
| Low | `mera/uts/universal_time` | Device timestamp wrap/decode | Keep device-specific until the protocol and constants are verified; do not call it universal prematurely | Candidate |

## Domain and platform-specific areas

### 3D widget and legacy model formats

| Delphi source | Useful behavior | Target and constraints | Status |
|---|---|---|---|
| `3d/objects/uObrFile.pas`, `uObaFile.pas`, `uSkin.pas`, `uBaseDeformer.pas` | `.obr/.oba`, scene hierarchy, skin weights and deformation | New Delphi API in `sharedUtils/3d`; keep codec/model/animation/render separate. Current `u3dLegacySceneLoader` is a compatibility callback to the proven loader; independent codec still requires golden files | Partially ported |
| `recorder/plgControlCyclogram/units/u3dMoveEngine.pas` | Axis/tag-driven helper motion | `sharedUtils/3d/animation/u3dHelperMotionEngine.pas`; Recorder tags must be resolved by an external adapter | Ported as backend-neutral contract |
| `recorder/plgControlCyclogram/units/uModelPointMng.pas` | FRF amplitude/phase interpolation driving skin points | `sharedUtils/3d/animation/u3dFrfDisplacementSource.pas` and `u3dFrfAnimationComponent.pas`; fixes byte-count and range defects and removes SRS/UI globals | Partially ported |
| `3d/core/uRender.pas`, `uUI.pas`, forms and design editors | WGL renderer and editors | Do not copy wholesale. New host/backend are `sharedUtils/3d/vcl/u3dWidget.pas` and `render/opengl/u3dOpenGLRenderer.pas`; scene renderer remains a separate stage | Rejected wholesale / replacing |

- `objects/*` contains a broad Delphi object/tag/alarm/database hierarchy.
  Compare with current RecorderLnx models; do not import another base-object
  family merely for one helper.
- `mera/database/*`, `utils/uDBase`, VCL forms/components and report UI are
  Windows/Delphi domain code. Port behavior behind a cross-platform interface,
  not the UI implementation.
- `socket/uScktComp`, OpenGL/VCL editors, localization and shell/path helpers
  carry Windows/VCL dependencies.
- `uMeraFile` is valuable but tightly mixed with Windows, dialogs, controls,
  ComCtrls and custom lists; a codec extraction is a deliberate project, not a
  copy operation.

## Third-party and archived trees

Treat the following as vendored or archived dependencies, not project-owned
SharedUtils API: JCL, TMSPack, FastMM, FastMath, alglib, NativeXML variants,
ZipMaster, FastReport, AlphaControls and their demos/design-time packages.

Before reusing any code from them, prefer the FPC/Lazarus standard library or a
maintained dependency and verify license, provenance, version and platform
support. Do not copy demo code into production merely because it is under the
`sharedUtils` directory.
