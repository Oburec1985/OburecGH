# 2026-07-17 — MC-201 multi balance: soft STOP kills command replies

## Symptom
Collect + DAC compute OK. Apply fails:
- soft/quiet STOP then SEND → `MDP command timeout`
- quiet ≥1s then sync `CallCommand(STOP)` → `STOPSCANMAIN sync failed after quiet: MDP command timeout`

Prepare (`Stop` + SEND `$8080` + `Start`) on a short stream works in ~0.6s.

## Cause
`SendCommandNoWait(STOP)` + drain leaves the controller silent for later `CallCommand` (STOP/SEND). Confirmed STOP with reply (prepare) keeps the command path alive. Soft STOP after heavy collect breaks it.

## Rejected
- ForceDisconnect / reconnect (kills device until original Recorder reset)
- Full `ProgramDevice` / `RESETSCANMAIN` after collect (same timeout)
- Soft Stop + SEND on “quiet” bus (quiet ≠ command-ready)

См. каноническое описание: [Docs/devices/mc/mc201-zero-balance-multi.md](../Docs/devices/mc/mc201-zero-balance-multi.md).

## Fix (updated 19:48)
1. Log `ack not seen … quiet=True`: fire-and-forget STOP often has **no** command-port ACK; quiet is enough — do not fail.
2. Stop **immediately after collect** (before compute/logging) so CallCommand(STOP) sees a short RX tail like prepare.
3. Fallback: no-wait + quiet; never second CallCommand(STOP) on an already-quiet bus.
4. Then SEND + StartRawScan.

## Verify
`phase stop-before-compute` → CallCommand STOP ok **or** `quiet=True` → `TryApplySavedBalanceDac` → `BalanceChannelsHardware OK`.
