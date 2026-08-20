# 2026-08-20 - Linux tag table export temp file

## Symptom

On Linux, exporting the channel/tag table from settings fails with:

- `Unable to create file "__temp__00000.tmp"`

The error appears during ODS export.

## Confirmed Facts

- RecorderLnx channel export uses `TsWorkbook.WriteToFile` with OpenDocument
  format from the vendored `fpspreadsheet`.
- `fpsopendocument.pas` created a `TZipper` with relative
  `FZip.FileName := '__temp__.tmp'`.
- `TZipper.ZipOneFile` derives intermediate disk stream names from
  `FZip.FileName`, so on Linux it attempted to create `__temp__00000.tmp` in
  the current working directory of RecorderLnx.
- Installed Linux applications may start from a directory where the normal user
  cannot create files, even when the chosen export destination is writable.

## Hypotheses Checked

- **User selected a non-writable export file:** not enough to explain the
  exact file name. The failing file is not the selected `.ods`, it is the
  library temporary file.
- **ODS writer uses a relative temp file:** confirmed in
  `third_party/fpspreadsheet/fpsopendocument.pas`.
- **The same class can affect XLSX:** confirmed in `xlsxooxml.pas`, which used
  the same `__temp__.tmp` pattern.

## Actions

- Changed `TsSpreadOpenDocWriter.WriteToStream` to assign `TZipper.FileName`
  to an absolute temporary file from `GetTempFileName`, then delete it after
  export.
- Applied the same fix to the OOXML writer so XLSX export does not hit the
  same current-directory problem later.
- In the RecorderLnx channel import/export UI, the file dialog initial
  directory now starts at `RecorderMeraFilesPath`; if it does not exist, it
  falls back to the user's home directory.

## Verification

- `git diff --check` for changed files completed with only standard LF/CRLF
  warnings.
- After the fpspreadsheet temp-file fix alone,
  `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- After adding the dialog initial directory change, `lazbuild -B` compiled
  units and reached the link step, then failed only because
  `lib\x86_64-win64\RecorderLnx.exe` is locked by a running RecorderLnx process
  (`error code: 5`). The running process was not stopped.

## Remaining Risk

- Needs a Linux retest of ODS export. Expected result: no
  `__temp__00000.tmp` creation error; dialog opens initially in Mera Files.
