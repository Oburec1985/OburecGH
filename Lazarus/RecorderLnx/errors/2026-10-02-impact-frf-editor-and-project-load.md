# FRF editor and project-load failures

## 2026-10-16 — same resource defect in the AFChKh editor

User: entering the frequency-response component editor reports unknown
property TabOrder. `uRcFreqRespDlg.lfm` streamed `fColor.TabOrder` on TColorButton.
The new standalone FrequencyResponseUiSmoke reproduced exactly:
`Error reading fColor.TabOrder: Unknown property: "TabOrder"` (exit 1).
Removed only the unsupported property; declared the resource's panels, labels,
buttons and handlers explicitly in the form's published section, removing its
accidental dependency on control classes registered by unrelated application
forms. Initial isolated creation had exposed `Class "TButton" not found` too.

After fix, the public modal editor opens, resizes and cancels normally:
`RESULT FrequencyResponseUiSmoke modal resource/resize/cancel passed` (exit 0).
The regression test lives in Tests/RecorderTests/FrequencyResponseUiSmoke.
Version 0.1.182; no deployment or user configuration changes.

## Symptoms

- Opening the impact FRF component editor terminated the application.
- Loading a project containing a newly placed, unconfigured FRF component raised
  `ERecorderFormError: Invalid impact-hammer component ... Не выбран тег ударного молотка`.

## Confirmed causes

1. The settings LFM contained a streamed `TabOrder` property on `TColorButton`.
   LCL raises `EReadError` while `TForm.Create` reads that unsupported property.
2. Persistence called the same strict `Validate` contract used before starting
   measurement. A newly placed component therefore could not be restored for
   later editing until its hammer and response channels had already been set.

## Fix

- Rebuilt the settings LFM as a clean component tree and removed the unsupported
  streamed property.
- Added a creation smoke test that constructs and frees the real settings form.
- Loading now accepts an incomplete editable draft. Runtime service configuration
  and the dialog OK action still call strict validation.
- Moved axis ranges/scales and export folder into component settings; simplified
  the runtime panel and removed CSV/MDB/WinPos buttons from view.

## Verification

- `ImpactHammerModelTestRunner`: passed, including LFM creation, incomplete draft
  round-trip, strict runtime rejection, axes and export-path persistence.
- Forced RecorderLnx build and link to `RecorderLnx-frf-verify.exe`: passed.

## Follow-up UI structure

The settings form now mirrors the measurement model: one input root (hammer)
with response outputs as child nodes, trigger/time-capture settings, FFT/FRF
calculation settings, and frequency-domain display settings. Time-domain axes
are intentionally absent and forced to auto-scale after loading.
