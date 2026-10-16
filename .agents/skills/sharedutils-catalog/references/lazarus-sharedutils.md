# Lazarus SharedUtils catalog

Root: `D:\works\OburecGH\Lazarus\SharedUtils`.

## Contents

- [Core utilities](#core-utilities)
- [Object, event, and LCL helpers](#object-event-and-lcl-helpers)
- [Math and DSP](#math-and-dsp)
- [OpenGL chart package](#opengl-chart-package)
- [Legacy and duplicate units](#legacy-and-duplicate-units)

## Core utilities

| Unit | Purpose and principal API | Use when |
|---|---|---|
| `uCommonTypes` | Primitive arrays; `point2/2d/2i/3/3d/4d`; rectangles and intervals; constructors/converters; shared `pi`, reciprocal and angle constants; Hz/angular-frequency helpers | A project needs canonical common data types, small geometry records, or invariant math coefficients |
| `uSharedAlgorithms` | Generic `TBinarySearch<T>` with first-greater and first-greater-or-equal searches | Searching sorted arrays without another local lower/upper-bound implementation |
| `math/uSharedStatistics` | Stable Welford summary, population/sample variance and standard deviation, covariance and correlation with strict finite-input checks | Reusable scalar statistics without mutating or allocating input data |
| `uSharedBinaryIO` | Exact `TStream` reader/writer for fixed-width little-endian values, strict Boolean8 and bounded raw strings/C strings | Cross-platform binary codecs that need explicit layout and reliable EOF/length validation |
| `uSharedAsync` | `TSharedAsyncTask`, `SharedStartAsync`, `SharedRunParallel`, aggregated `ESharedAsyncError` | A small number of independent coarse tasks; it is not a worker pool for tiny runtime jobs |
| `uSharedFileLogger` | Thread-safe singleton, levels, rotation, configuration, thread names | All new general application/file logging |
| `uSharedNumberFormat` | Locale-aware `FormatSignificant` | Compact values and chart/axis labels with controlled significant digits |
| `uSharedStringEncoding` | Byte loading, UTF-8 validation, CP1251 conversion, legacy detection, XML declaration normalization | Reading old Recorder files or any uncertain CP1251/UTF-8 boundary; see `Docs/string-encoding.md` |
| `uRecorderLanDiscovery` | Recorder/Coordinator UDP discovery on ports 38765/38766 | Discovering RecorderLnx services; specialized, not a generic network toolkit |

## Object, event, and LCL helpers

| Unit | Purpose | Guidance |
|---|---|---|
| `uEventList` + `uEventTypes` | Masked named event list and legacy event constants | Use for clients already following this event-mask model |
| `uBaseObjLaz` | Owned object tree, parent/children lookup and XML/text serialization | Preferred general Lazarus object/settings tree |
| `uComponentServices` | Stored values behind localized captions, `LclText`, ListView/StringGrid sizing, `TBaseObj`/TreeView synchronization | Preferred LCL helper unit |
| `uSharedColorCheckTable` | Reusable LCL table with named columns and independently optional checkbox and color-box columns | Use for channel/curve lists; row `Data` references are not owned, and domain-specific visibility rules stay in the client |
| `uBaseClass` | Separate JSON/class-registry/critical-section `TBaseObj` family | Existing clients only; do not mix with `uBaseObjLaz` or chart `cBaseObj` |
| `uBaseObjVclUtils` | Older TreeView helpers despite the VCL name | Compatibility only; prefer `uComponentServices` |
| `ubldlfmfile` | BLD/LFM binary structures and load/save | Discrete-phase BLD/LFM formats only |
| `ubldmath` | Tachometer periods, phase, speed, revolutions over BLD data | Discrete-phase domain calculations only |

## Math and DSP

| Unit | Purpose | Guidance |
|---|---|---|
| `math/complex` | Double complex type and basic operations, magnitude and phase | FFT internals; beware names colliding with standard `Abs`/`Exp` |
| `math/uCommonMath` | Legacy collection of flags, colors, min/max, parsing, INI, names, time and array extrema | Search before adding helpers, but add new code to a focused `uShared*` unit when responsibility is unrelated |
| `math/u2DMath` | Geometry, intersections, splines, cubic roots, reentrant convex hull and exact hull diameter; optional fast PCA principal-axis diameter | Geometry and spline calculations |
| `math/uHardwareMath` | CPU detection, aligned buffers, Pascal/SSE/AVX dispatch, FFT plans/windows and array operations | Production high-rate DSP through its guarded public dispatch API and tests |
| `math/Iterative_fft_nu`, `math/recursive_fft_nu` | Portable FFT implementations | Intentional portable/reference use only |
| `math/Iterative_FFT_sse`, `math/recursive_sse2_sse3_d_al_fft` | Architecture-specific FFT variants | Do not select directly without CPU guard and benchmark |

When introducing a new numerical family, define its behavior before choosing
an implementation: empty input, even-size result, window-edge handling,
NaN/Inf policy, mutation/ownership and numerical tolerance. Keep a simple
reference implementation as a test oracle for any optimized version. Put a
coherent reusable family in a focused unit such as `uSharedStatistics`; reserve
`uCommonMath` for compatibility with its existing callers.

## OpenGL chart package

Root: `components/chart_lzr`.

| Area | Units and role |
|---|---|
| Package/entry | `lzrObrPack`, `uoglchart` (`TOglChart`) |
| Contracts/model | `uOglChartTypes`, `uOglChartModel`, `uOglChartBaseObj`, `uOglChartChart`, `uOglChartPage`, `uOglChartAxis`; `TChartAxis.DisplayScale` and `DisplayUnit` affect only rendered tick labels and never world coordinates, series values, cursors, hit-test, pan or zoom |
| Series/data | `uOglChartTrend` for line/spline/realtime series; `uSharedQueue` for preallocated/ring chart data |
| Drawing | `uOglChartDrawObj`, `uOglChartRenderer`, `uOglChartLineHelper`, `uOglChartFontMng`, `uOglChartColors`; `cLineSeries.StipplePattern` enables fixed-pixel OpenGL line stipple (`0` means solid); `TOglChart` requests 4x MSAA and the renderer enables line smoothing as a fallback; `PageContentRect` measures actual tick-label widths/heights and reserves DPI-aware margins for every Y axis and the end X labels; the minimum linear tick label is display-rounded to 1% of the visible range without changing world coordinates |
| Interaction | `uOglChartFrameListener`, cursor, pan/zoom, page geometry, label edit, select and vertex-edit listeners; frame zoom requires Ctrl in the plot area, while dragging directly in an X/Y axis band performs one-axis zoom (including reverse-drag zoom-out) without Ctrl; when `HasPresetXRange` is set, pan, wheel, frame zoom and reverse zoom all keep the page X range inside Preset |
| Cursors/labels | `uOglChartCursor`, `uOglChartTextLabel`; `TChartHorizontalCursor` is a transient horizontal overlay whose Y belongs to an axis and whose X spans the page content rectangle in screen space, so use it for thresholds that must always cover the visible plot width. Opt-in `TChartFlagLabel.AutoLayout` places visible trend flags near their peaks using screen-space bounds, moves colliding captions upward, and skips hidden overflow flags in the label-render pass. Transient `Highlighted` prioritizes a selected flag in dense layouts and accents its fill, outline, marker and leader without changing the trend color. |
| Persistence/management | `uOglChartMng`, `uOglChartSerializer` |

Reuse model objects and listeners instead of implementing chart behavior in a
form. `uOglChartControl` is an older/simpler path; do not mix it with the full
stack without checking the owning project.

## Legacy and duplicate units

## Delphi 3D migration boundary

The canonical FPC/Lazarus implementation is
`D:\works\OburecGH\Lazarus\SharedUtils\3d`. Its current public units include
`u3dCoreTypes`, `u3dContracts`, `u3dSelection`, `u3dOpenGLRenderer`, and
`u3dLclWidget`. `u3dSelection.NodeIdAfterPick` defines whether an empty pick
clears the object or keeps it as the context for vertex editing.
`u3dContracts.RenderPassUsesDepthTest` keeps topology point/highlight overlays
visible while solid geometry continues using the depth buffer.
Core/contracts have no LCL, tag, or Recorder dependency; the renderer uses
cross-platform `gl/glu`; only the LCL adapter depends on `OpenGLContext`.
RecorderLnx consumes it through `uRecorder3dModel` and `uRecorder3dView`.

`D:\works\OburecGH\sharedUtils\3d` remains the Delphi migration source for
helper motion, FRF displacement, scene loading and scalar-field contracts.
Its VCL/WGL host is not reusable by Lazarus. Port algorithms into the FPC tree
behind the existing contracts; do not add the Delphi path to Lazarus projects.

- Canonical logger: `uSharedFileLogger`. `ThreadedLogger`, `ulogthread`, and
  chart-specific logging are compatibility/domain code.
- Canonical LCL helpers: `uComponentServices`.
  `uComponentServises` is the misspelled legacy duplicate.
- `uEventList2.pas` declares the same unit name as `uEventList`; do not add it
  to a search path.
- There are three incompatible object families: `uBaseClass.TBaseObj`,
  `uBaseObjLaz.TBaseObj`, and chart `cBaseObj`.
- Do not index `lib`, `backup`, `cach`, generated `.ppu/.o/.compiled`, `.bak`,
  `.pas.test`, or `.pas.utf8` copies as public API.

## 3D transform API

`3d/core/u3dTransforms` is the canonical node/frame transform API. It converts
world transforms to/from arbitrary frames, converts between frames, translates
or rotates a transform in another frame, changes parents while preserving world
TM, and updates cached scene world matrices. `u3dGeometryMath.ComposeMatrices`
uses AVX on x86-64 when CPUID and OSXSAVE/XCR0 permit it, otherwise SSE2 on
x86-64 and a scalar reference backend elsewhere. Camera, helper, and editor
code should reuse these APIs instead of maintaining private matrix arithmetic.
