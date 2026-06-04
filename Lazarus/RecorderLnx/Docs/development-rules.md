# RecorderLnx Development Rules

Date: 2026-06-04

## Lazarus Source Encoding

- Before editing any `*.pas` or `*.lfm` file with Russian text, check the real
  file encoding and the Pascal directive near the top of the unit.
- The file bytes and the directive must match:
  `{$codepage UTF8}` for UTF-8 files, `{$codepage cp1251}` for Windows-1251
  files.
- Do not rewrite a whole Pascal unit through a default text writer unless the
  writer encoding is explicit. A silent encoding conversion can compile
  successfully but turn LCL captions and resources into `????`.
- For UTF-8 Lazarus UI units, save as UTF-8 and keep `{$codepage UTF8}`. This is
  required for runtime captions created in code, for example `TLabel.Caption`,
  `TTabSheet.Caption`, `TButton.Caption`, and dialog text.
- For legacy cp1251 units, either preserve cp1251 exactly or intentionally
  convert the whole unit to UTF-8 and update the directive in the same change.
- After any encoding-sensitive UI edit, rebuild with `lazbuild -B` and open the
  touched dialog/form once to verify Cyrillic captions are readable.

## Safe Editing Practice

- Prefer narrow patches over whole-file rewrites.
- If `apply_patch` cannot read a Pascal unit because of encoding, do not blindly
  rewrite it. First inspect the current bytes/encoding, then choose an explicit
  encoding-preserving edit or a deliberate full conversion.
- When a UI exception points to a control field, verify that the field is
  actually created before use. Dynamically built LCL forms do not get designer
  initialization for undeclared controls.

## Original Recorder Reference

- The original Recorder source tree is available under
  `D:\works\windev-v3.9\..`.
- For behavior that must match the original Recorder, inspect the `rc_*` and
  `mr` directories first.
- Do not ask the user where the original Recorder is for RecorderLnx
  compatibility work; use the path above.
