# 2026-08-17 - tag table import crash

## Symptom

RecorderLnx crashed when the user tried to import a tag table from the channel
settings dialog.

## Confirmed Facts

- The crash appeared after adding `uRecorderTagTableExchange.pas`.
- Import parses spreadsheet rows into `TTagImportRow`.
- `TTagImportRow` contains managed `string` fields.
- The initial implementation reused the local row variable with
  `FillChar(lRow, SizeOf(lRow), 0)`.
- The debugger screenshot provided by the user shows the actual stack at
  `fpsopendocument.pas:1933`, inside `TsSpreadOpenDocReader.ReadFromFile`.
- The vendored fpspreadsheet ODS reader freed `Doc` after reading `content.xml`
  and then freed the same object again in `finally`.

## Checked Hypotheses

- Dialog lifetime leak: checked `TOpenDialog` handler; after the previous
  cleanup it uses `try/finally` and is not the likely crash source.
- fpspreadsheet format loading: the screenshot disproved the earlier low-risk
  assumption. ODS loading can crash because the vendored reader double-frees the
  XML document object.
- Managed-record memory corruption: confirmed in source. `FillChar` bypasses
  reference counting/finalization for `string` fields and can corrupt memory
  when the variable is reused in a loop.

## Action

- Replaced raw byte clearing of `TTagImportRow` with
  `lRow := Default(TTagImportRow)`.
- Patched vendored `fpsopendocument.pas`: after explicit document release, use
  `FreeAndNil(Doc)` so the finalizer does not release the same DOM twice.
- The first patch changed an earlier `Doc.Free`, but the user's second
  screenshot showed the crashing `Doc.Free` remained at the later
  `content.xml` release. Patched that second site too and deleted the stale
  `RecorderLnx/lib/x86_64-win64/fpsopendocument.ppu` before rebuilding.

## Effect / Verification

- `RecorderLnx.lpi` rebuilt with exit code 0 and linked `RecorderLnx.exe`.
- `RecorderLnx.lpi` rebuilt again after patching the later `Doc.Free`; lazbuild
  reported that `third_party/fpspreadsheet/fpsopendocument.pas` changed, rebuilt
  it, and linked `RecorderLnx.exe` with exit code 0.
- The reported debugger stack at `fpsopendocument.pas:1933` should no longer
  double-free `Doc`; both explicit document release sites now use
  `FreeAndNil(Doc)`.
- UI import still needs one manual retry with the user's `.ods` file to confirm
  end-to-end table parsing and tag update.

## Prevention

- Never use `FillChar` to clear a record that contains managed fields
  (`string`, dynamic arrays, interfaces, variants or records containing them).
  Use `Default(TRecordType)` or explicit field assignments instead.
- Treat vendored parser stack frames as project code during crash debugging.
  Compilation success does not prove third-party import/export code is safe on
  the current Lazarus/FPC runtime.
- Promoted project rule:
  `RLNX_MANAGED_RECORD_NO_FILLCHAR_2026_08_17` in
  `Docs/development-rules.md`.
