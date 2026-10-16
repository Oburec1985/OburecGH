# Oscillogram trigger frame overwritten before capture interval ends

## Symptom

The falling-edge trigger captures a frame, then the displayed frame is replaced
by a later buffer that no longer contains the original event.

## Investigation

- The view's trigger detector used `lWindowSeconds` as the re-arm interval.
- `lWindowSeconds` can be the manually zoomed viewport width, not the configured
  capture duration `ADisplaySeconds`.
- A short zoom therefore allowed a later crossing to replace the frame before
  its configured capture interval had elapsed.
- The ring-buffer refresh path itself was not changed; no hardware replay was
  available in this session to independently reproduce the report.

## Fix

Store a separate `fTriggerHoldUntil` timestamp on a successful capture and only
allow a later edge at or after `eventTime + ADisplaySeconds`. Clear the hold
state when trigger parameters change, trigger tag disappears, or session state
resets.

## Verification

- Forced Win64 RecorderLnx build: passed.
- RecorderFormModelTest: passed.
- Forced Win64 SampleInfoPlugin and SamplePluginProbe builds: passed.
- SamplePluginProbe: `RESULT sample-plugin passed`.
- Runtime hardware/visual reproduction: pending.

## Remaining uncertainty

If the frame is still overwritten while unzoomed and before the configured
duration, capture logs or a reproducible data trace are needed to distinguish a
second genuine edge from a stale/repeated ring-buffer event.
