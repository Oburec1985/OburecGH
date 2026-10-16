# Modbus bit channel incorrectly required Bool

## Symptom

Saving a Coil or Discrete Input tag failed with “supports only Bool” when the
tag had previously used a register data type. This exposed the internal wire
codec as if it were the Recorder channel type.

## Confirmed cause

The editor and core validator required `mdBool` for bit regions. The original
plugin instead exposes a numeric channel: reads publish `0` or `1`; writes use
`value > 0` as an ON bit and pack bits only at the Modbus command layer.

## Fix

- Coil/Discrete Input always occupies one wire bit, independent of stale
  register data-type metadata.
- The editor automatically selects and locks the internal Bool codec for bit
  regions instead of showing a validation error.
- Runtime FC05 conversion now matches the original `value > 0` rule.
- Recorder tags remain numeric and receive `0.0` or `1.0`.

## Verification

- Modbus core: `RESULT 75 passed, 0 failed`.
- Runtime fake TCP/RTU: passed, including numeric `1` → FC05 `$FF00`.
- Editor resource smoke: passed.
- Forced RecorderLnx Win64 compile/link: exit code 0.

