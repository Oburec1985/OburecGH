# Generic visual component ABI v2

## User-defined component boundary (2026-10-14)

`Oscillogram` is the simple built-in RecorderLnx chart and remains available in
the component palette and BasePage. `sample.oscillogram` is the independent
plugin Oscillograph, displayed as «Осциллограф». The plugin must not register the
`Oscillogram` alias or borrow its host model/renderer/editor/serializer. Only the
simple built-in configuration is parsed by the host; advanced plugin state and
its legacy import belong to the plugin. Verify distinct factories and both
project round-trips in OscillogramRuntimeSmoke.

This ABI is an additive SDK contract. It leaves the legacy
`uRecorderPluginApi` binary contract unchanged; the host runtime now probes for
the V2 descriptor export before falling back to the legacy plugin entry points.
It is intentionally generic: no oscillogram, spectrum, chart, or other
feature-specific type is present in the ABI. The V2 loader/factory handles
opaque instance state. The production plugin now contains its own model,
history adapters, editor and views, but host-specific legacy routes and
project/base-page migration remain and prevent a full architecture acceptance.

## Current additive services (2.3)

The stable 2.1 prefix remains intact. Appended flat callbacks provide bounded
range history, atomic signal info, selected numeric tag ID, cached estimates,
estimate settings, unit enumeration and conversion factors. Metadata includes
source visibility as a generic flag. No host classes or managed values cross
the DLL boundary. See the SDK unit for exact C-layout record sizes and offsets.

Production history preparation must allocate snapshot records first and then
prepare every caller-owned array in cold Configure/Rebuild. Runtime reads may
not create unprepared entries. Acceptance includes populated primary/additional
and base-page signals; an empty-registry construction smoke is insufficient.

The unified run-smoke script includes the real production DLL and plugin-local
editor/Base-surface resource tests. The production waveform gate reads GL_FRONT
after verifying that the current native WGL context belongs to the chart HWND.
Interior signal pixels disappear after clearing history, return after refill,
and remain after parent recreation. GDI BitBlt was rejected because accelerated
OpenGL capture returned black despite a populated framebuffer.

## Import and cold metadata notification (2.4)

The optional append-only ImportState callback receives a versioned request with
format ID, original TypeId and borrowed bytes. `recorder.ini.section-v1` is the
full UTF8 JSON object of original INI keys/string values, including common
binding fields. The host does not parse component-specific keys or normalize
locale decimals. The plugin validates a draft, then applies it atomically.
The host snapshots prior native state, invokes import, saves native opaque
bytes on success, and restores the instance/input envelope on failure.

Legacy import is allowed only when no encoded-state envelope exists. Malformed
hex-v1 or a missing data key is an explicit error, never a defaults-producing
fallback. Unknown encodings remain transport-only placeholders even when a
matching plugin is installed, with `recorder.unknown-envelope-v1` marking the
preserved raw envelope. Native save/reload must retain it without interpretation.

CATALOG_CHANGED is a cold UI-thread notification for tag metadata, units and
estimate settings. Runtime maps configuration completion/load/initialization
events to it; plugins rebuild catalogs and prepare buffers there, not in
DATA_UPDATED. Older plugins may return NOT_HANDLED. Optional descriptor fields
Edit, ViewDispatch and ImportState must each be cleared when outside Header.Size.

Regression evidence covers complete legacy/missing-plugin/native roundtrip,
Unicode and stable IDs, comma/dot decimals, invalid-import rollback, malformed
and unknown envelopes, numeric-ID rename/unit/fs change, and a LoadState-only
descriptor containing poisoned optional callback slots outside its prefix.

## Discovery and lifecycle contract

The library exports `RecorderVisualGetDescriptorV2(index, descriptor,
capacity)`. The host calls it with indices starting at zero until it returns
`REC_VISUAL_END_OF_ENUMERATION`. `REC_VISUAL_OK` means one complete descriptor
was written. Any other result is a load failure. The callback validates the
capacity before writing and leaves caller memory untouched when it is too
small. On success it writes the full descriptor it supports and sets
`Header.Size` to that descriptor's size. The host caps enumeration at 1024
descriptors, validates the
header, major version, minimum stable prefix, callback tail, and NUL-terminated
UTF-8 IDs/labels, then copies all descriptor bytes and strings into host-owned
storage while the library is still loaded. Duplicate IDs reject the plugin's
entire registration batch; registration is transactional.

For a new palette component the host calls `CreateInstance` with a nil/empty
initial-data buffer. This creates the plugin's default state. For a component
restored from a project the host first creates the instance the same way, then
calls `LoadState` exactly once with the saved opaque bytes. `CreateInstance`
data is reserved for ephemeral generic construction context and is never a
second persistence path. `LoadState` must validate into temporary state and
either apply all bytes or leave the prior instance unchanged.

`SaveState` uses two calls: `(nil, 0)` must return
`REC_VISUAL_BUFFER_TOO_SMALL` and the exact required size for non-empty state;
an empty state returns `REC_VISUAL_OK` with size zero. The host enforces its
16 MiB persistence limit, allocates a caller-owned buffer, calls again, checks
the returned size/status, and only then atomically replaces the stored blob.
The plugin must not retain caller buffers. A failed or short save never
overwrites the last known-good blob.

All descriptor callbacks are called serially on the LCL/UI thread unless a
future descriptor capability explicitly opts into another documented
execution model. Plugin code must catch its exceptions and return an ABI
status; exceptions must never cross the C boundary. Host context and service
tables are borrowed for the documented plugin-runtime lifetime and must not be
retained past it. Component instances are destroyed before their descriptor
factory is removed; factories and every callback/context reference are
released before `PluginClose`, `DestroyPluginClass`, and `FreeLibrary`, in that
order. The host must stop creating instances before teardown begins.

ABI 2.1 supplies a borrowed host-services table for tag enumeration and history.
ABI 2.2 adds a generic creation context, transactional editor request and native
child-view surface lifecycle. Component-specific model/view code remains to be
migrated. Do not grow `RegisterOscillogramFactory` or encode component names
into dispatch kinds as a shortcut.

## Host services, creation and editing

`CreateInstance` receives `PRecorderVisualHostServicesV2`, not a runtime object.
Its Context is an opaque callback token. `EnumerateTags` copies UTF-8 metadata,
numeric IDs, units, ranges, sampling frequency and flags into caller-owned
records. The first version of this metadata record requires its complete known
size; future appended fields require size-aware prefix handling.
`CopyLatestHistory` validates the requested window and copies into caller-owned
arrays. A size query returns BUFFER_TOO_SMALL and count; no short-buffer writes
are permitted. Count, timestamps and revision describe the same locked history
snapshot. Empty histories succeed with count zero. Calls are UI-thread serialized;
runtime scratch arrays are reused, but grow when a larger window is requested.
Tag IDs are currently resolved per call; a stable resolved-handle service remains
an optimization to implement before high-frequency production polling.

`CONFIGURE` receives a versioned create-context containing component number and
selected/default numeric TagIds. The host does not interpret plugin defaults.
`Edit` receives a versioned native owner/backend/DPI request and runs synchronously.
The plugin owns its editor and draft. OK commits through SaveState; CANCELLED,
error, NOT_HANDLED or failed post-edit save restores both opaque bytes and live
plugin state from the pre-edit snapshot. OwnerWindow is never a Pascal object.
Where a true native owner adapter is unavailable, it is zero.

## Native child views

A host-owned generic container is registered once for PluginVisual. Each view
session has a unique ViewId and sends ATTACH_VIEW, RESIZE_VIEW, VIEW_MODE and
DETACH_VIEW with `TRecorderVisualSurfaceV2`. The plugin owns all child controls,
rendering and native input handlers; no LCL or chart object crosses the ABI.
Dimensions are native parent-client pixels and DPI comes from the owning form.
Native parent transport is currently implemented for Win32 and GTK2; GTK3/Qt/Cocoa
must supply a real native adapter rather than forwarding Pascal widget wrappers.
Unsupported native backends return NOT_HANDLED.

The INTERACTIVE flag controls whether plugin input is active. In form-editor mode
the plugin must disable or otherwise release native hit testing so the host can
select/move the component. A normal runtime view receives native mouse/key events
directly inside the plugin. The parent may be recreated; detach must finish before
its old handle is destroyed, followed by attach to the replacement handle.
Repeated attach first detaches the prior view; a failed detach blocks replacement.
Resize/mode errors remain visible as ABI statuses.

Before unloading, the factory detaches every view, destroys the plugin instance,
invalidates surviving host session tokens, then unregisters callbacks and releases
the library. DestroyInstance must synchronously destroy every remaining owned view,
including cleanup after a failed detach. If final detach fails or instance destruction throws, the host
keeps the library mapped rather than unloading possibly live native callbacks.
The host never calls a destroyed session's plugin callbacks.

## Architectural reference: original `plgEvalFRF`

The original Delphi plugin is a reference for ownership/registration, not a
binary-compatibility target. `plgEvalFRF.dpr` exposes the generic
`IRecorderPlugin` lifecycle; `units/uCreateComponents.pas` creates its own
`cFRFFactory` and registers it through the host's `ICustomFormsRegistrator`
held by `cCompMng`. The factory and its forms are implemented inside the plugin
(`SharedRUnits/uRecBasicFactory.pas`, `forms/uEvalFRFFrm.pas`), while the host
discovers generic factories and does not contain FRF-specific form behavior.

The RecorderLnx migration must preserve that ownership boundary while using a
flat C ABI instead of Delphi interfaces: plugin owns type/model/config/editor/
view/behavior; host owns generic component placement, lifecycle dispatch,
tag/data services and notifications. The V2 descriptor is wired to a generic
runtime factory and opaque state callbacks, with a stateful test DLL exercising
load, save, clone, unregister and unload. A native view/editor surface and
generic tag/data service-table contract now have a tested Win64 implementation.
Production Oscillogram still needs its model/view/editor/state moved into the
plugin and host-specific branches removed; GTK2 native embedding is not yet
runtime-verified.

## Binary rules

- `{$PACKRECORDS C}` C-layout records, `cdecl` function pointers, fixed-width
  integer fields, fixed-size ANSI byte arrays, opaque `Pointer`, and explicit
  pointer-plus-`SizeUInt` byte buffers only.
- Text byte arrays are UTF-8, NUL-terminated, and must retain a terminator
  within their declared capacity; IDs should use ASCII where possible.
- No LCL controls, chart/canvas objects, Pascal classes/interfaces, managed
  strings, dynamic arrays, or compiler-managed records cross the boundary.
- Every public record starts with `Size: LongWord; AbiMajor: Word;
  AbiMinor: Word` (8 bytes). Major version must match. A reader must validate
  `Size` before accessing a field not guaranteed by the prefix it understands.
- Fields are append-only within major version 2. Do not reorder, resize, or
  repurpose fields. Unknown minor-version tail fields are ignored.
- `RecorderVisualFieldPresentV2` performs overflow-safe `(offset,size)` guards.
- Callback payloads are byte buffers owned by the caller for the duration of
  the call. No callback retains a supplied buffer after returning. Plugin state
  remains opaque to the host and is serialized by `SaveState`/`LoadState`.

Callback results: `REC_VISUAL_OK` means success; `REC_VISUAL_BUFFER_TOO_SMALL`
means `ARequiredSize`/`AOutputSize` contains the required capacity; error and
not-handled are distinct. To size a saved state, call `SaveState` with a nil
buffer and zero capacity, then allocate and call again. State bytes are plugin
private; the host stores and returns them unchanged.

`Edit` receives an opaque versioned edit request. `ViewDispatch` dispatches
plugin-owned view behavior by numeric `ADispatchKind`; input and output are
opaque versioned payloads, including the native surface/editor records above.
The host is responsible only for generic lifecycle,
buffer storage, and dispatch transport; it must not interpret component state
or implement component-specific presentation/behavior.

## Descriptor layout

Offsets below are byte offsets from record start. Fixed fields are identical
on 32- and 64-bit targets. C alignment makes the callback tail pointer-width
dependent:

| Field | Offset | Size |
|---|---:|---:|
| Header (`Size`, `AbiMajor`, `AbiMinor`) | 0 | 8 |
| `TypeId[128]` | 8 | 128 |
| `DisplayName[128]` | 136 | 128 |
| `Category[64]` | 264 | 64 |
| `Flags` | 328 | 8 |
| `CreateInstance` | 336 | pointer |
| `DestroyInstance` | 336 + pointer | pointer |
| `SaveState` | 336 + 2×pointer | pointer |
| `LoadState` | 336 + 3×pointer | pointer |
| `Edit` | 336 + 4×pointer | pointer |
| `ViewDispatch` | 336 + 5×pointer | pointer |
| Total descriptor size | 384 (64-bit), 360 (32-bit) | — |

The stable descriptor prefix ends after `Flags`, at byte 336. Probe:
`Tests/VisualComponentAbiV2/VisualComponentAbiV2Probe` verifies field offsets,
32/64-bit size formula, prefix copying, callback-tail detection, and overflow
behavior of the size guard. The stateful sample-plugin harness additionally
verifies descriptor export discovery, default creation, two-pass state save,
atomic rejection of malformed state, restore into a fresh instance, and
destruction before library unload. `run-smoke.ps1` also runs
`PluginVisualModelTest` against the host runtime: it loads the test DLL through
`LoadConfigured`, registers both descriptors, exercises generic state
restore/save and copy, and confirms factory teardown destroys the instances
before the runtime releases the library.

The same production-loader test now exercises two load/unload cycles, UTF-8
metadata, history snapshots and producer revisions, error/canary buffer cases,
palette creation and lifecycle, editor commit/cancel rollback, rejected detach/
resize/mode callbacks, and invalidation of sessions surviving unload. On Win64,
the DLL creates an actual LFM-backed native child; the test checks native parent,
rendered pixels, mouse/key handlers, resize, editor hit-testing and destruction/
recreation of the parent. This native fixture is a generic SDK acceptance test,
not proof of production Oscillogram migration or Linux support.

## Verification

From this directory, run the forced Win64 build and both probes with Lazarus/FPC:

```text
powershell -ExecutionPolicy Bypass -File Plugins/SDK/Tests/VisualComponentAbiV2/run-smoke.ps1
```
# Missing-plugin UI invariant

An unbound plugin placeholder may have `Factory=nil` even when a generic visual
host class is registered. All host presentation paths must tolerate this state
and preserve its opaque configuration and original type identity. Verify page
construction and runtime/editor mode transitions with an unavailable plugin,
not only with a loaded fixture DLL. Regression: PluginEditorStateSmoke; evidence:
`errors/2026-10-14-plugin-placeholder-startup.md`.

