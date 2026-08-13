# 2026-08-13 - MIC-140 runtime diagnostic tags

## Symptom

After some runtime, RecorderLnx reports an error around `TRecorderMic140DataSource.PublishDiagnostics`.

## Confirmed Facts

- `PublishDiagnostics` is called from MIC-140 runtime lifecycle/tick paths.
- Before this fix it called `Registry.FindByName(fStatusTagName)` on every status update.
- It manually assigned `lTag.TextValue := AStatusText`.
- It manually changed `lTag.Description` in runtime with `Format(...)`.
- It then called `Registry.PublishValue(fStatusTagName, ...)`, which performs a second name lookup.
- MIC-140 block counter and temperature diagnostics also manually assigned `TextValue`; counter also did a repeated `FindByName`.

## Checked Hypotheses

- Hypothesis: status text must live in tag `TextValue`.
  - Check: `TRecorderTag.AddSample/AddSamples` already updates `TextValue` from numeric data.
  - Result: rejected. Source code should publish numeric status code; UI formatting should produce text when displaying it.
- Hypothesis: description should be updated with the current status.
  - Check: `DoCreateTags` already creates stable descriptions for diagnostic tags.
  - Result: rejected. Runtime mutation of description is unnecessary and allocates strings repeatedly.
- Hypothesis: repeated string lookup is needed because registry may change.
  - Check: MIC-140 already builds `fRuntimeChannelTags` and `fRuntimeTemperatureTags` in `BuildRuntimeCache`.
  - Result: rejected for normal runtime. Diagnostic tag refs should be cached by the same setup path.

## Actions

- Add fast `TRecorderTagRegistry.PublishValue(ATag, ...)` overload.
- Cache MIC-140 status and block counter tag references in `BuildRuntimeCache`.
- Remove runtime `Description` mutation and manual `TextValue` assignments from MIC-140 diagnostics.

## Verification

- `rg` in `Device/MIC140/uRecorderMic140DataSource.pas` shows remaining `FindByName` calls only in `BuildRuntimeCache` and `DoCreateTags`.
- `rg` in the same file shows no remaining `TextValue` assignments.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi` finished with exit code `0`.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe` finished with exit code `0`.

## Result

MIC-140 diagnostic status, block counter and temperature diagnostic tags now publish numeric values through cached tag references. String status text remains only for rare log messages, not as tag state.

## Expected Effect

- No repeated status/block-counter lookup by tag name in MIC-140 runtime.
- Diagnostic tags stay numeric (`Double` samples in the ring buffer); text rendering remains a UI responsibility.
- Less string allocation and less registry traversal in the acquisition path.
