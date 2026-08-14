# 2026-08-13 - MIC-140 source-only add creates user tags and crashes tag calibration

## Symptom

After auto-search the user added three MIC-140 devices and pressed OK.
The user did not create channel tags. On re-entering settings the MIC-140
sources were shown with error icons, and opening/editing settings crashed in:

`TRecorderTagRegistry.TransformTagValue`

at the loop over `ATag.CalibrationNames.Count`.

## Confirmed Facts

- The user explicitly confirmed that channel tags were not created manually.
- Logs before the crash showed auto-search could discover MIC-140 devices and
  then settings apply attempted MIC-140 link tests.
- MIC-140 `DoCreateTags` interpreted an empty `fTagNames` list as "create all
  enabled user channels". That is wrong for source-only auto-add.
- Diagnostic tags are internal numeric tags and must not behave like ordinary
  measurement tags with text values or channel calibration pipelines.
- MIC-140 runtime keeps cached tag pointers for diagnostics/block counter.
  After settings reload/reconfiguration such pointers may be stale and must be
  validated before publishing.

## Checked Hypotheses

- "The crash means the user created broken tags" - rejected. The user did not
  create tags; the source itself created measurement tags because empty
  `fTagNames` had the wrong meaning.
- "This is only a communication error because devices are offline" - rejected
  as root cause of the crash. Offline devices may mark sources with errors, but
  must not crash tag transform/calibration code.
- "A nil `CalibrationNames` is impossible" - rejected as a defensive rule.
  `TRecorderTag.Create` normally allocates it, but legacy/bad config or stale
  pointers can still reach common registry code; shared code should guard it.

## Changes Made

- `TRecorderMic140DataSource.DoCreateTags` now treats empty `fTagNames` as
  "create no user measurement tags". Only explicitly selected channel/tag names
  create user tags.
- MIC-140 diagnostic status and block counter tags are numeric runtime tags:
  channel and hardware calibration are disabled and calibration names are
  cleared.
- Temperature tags are also created only when explicitly requested, and their
  calibration flags are disabled.
- `TRecorderTagRegistry.ContainsTag` was added so cached runtime tag pointers
  can be checked against the current registry.
- `PublishValue(ATag, ...)`, `AddBlockSamples(ATag, ...)`, MIC-140
  `PublishDiagnostics`, and `PublishBlockCounter` now ignore stale tag pointers
  instead of dereferencing freed/out-of-registry tags.
- `TransformTagValue`, save and load of tag calibration pipelines are guarded
  against nil tag/calibration list.

## Verification

- `RecorderLnx.lpi` rebuilt successfully with `lazbuild -B`.
- Hardware communication was not re-tested in this iteration because the user
  turned the devices off.

## Remaining Risk

- With devices off, MIC-140 rows can legitimately show offline/error icons.
- The live acceptance check still needs the devices powered on: auto-search,
  add MIC-140 sources without adding tags, press OK, re-open settings, and open
  MIC-140 source properties. Expected result: no crash and no automatic
  creation of 48+3 user measurement tags.
