# FRF editor and project-load failures

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
