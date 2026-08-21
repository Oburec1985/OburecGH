# 2026-08-21 - Toggle button visually releases while tag stays pressed

## Symptom

- A mnemonic button configured as `С фиксацией (переключатель)` writes the
  pressed value to the tag.
- Immediately after click the button visually releases, while the tag value
  remains equal to the pressed value.

## Facts Checked

- `TRecorderButtonView.ButtonClick` already toggled `fTogglePressed` and
  published `PressedValue` / `ReleasedValue`.
- `TRecorderButtonView.RefreshControl` then unconditionally reread the tag with
  `TagIsPressed` and called `SetVisualPressed(TagIsPressed)`.
- `TagIsPressed` used a strict `SameValue(LatestValue, PressedValue)` check and
  returned `False` when the tag had no readable sample yet or when the published
  value was not exactly represented as the configured double.

## Hypothesis

- The visible release is caused by refresh overriding the freshly toggled local
  state before the tag readback is a reliable exact match.

## Action

- Added `TryReadTagPressed(out APressed)` in
  `UI/uRecorderVisualControl.pas`.
- For toggle buttons, `RefreshControl` now updates `fTogglePressed` only when a
  real tag sample is available; otherwise it preserves the last local toggle
  state.
- The readback classifies the current value by distance to `PressedValue` vs
  `ReleasedValue`, which is more stable for fractional values.

## Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
