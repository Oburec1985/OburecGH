# 2026-07-17 — MC-bus balance ForceDisconnect kills device

## Symptom
After balance apply that used ForceDisconnect + reconnect, the controller stayed dead until reset with original Windows Recorder. Our reset path hung the UI.

## Cause
Apply tore down TCP (ForceDisconnect) then reconnected; device state did not recover cleanly on the new session.

## Fix
- Apply: StopAfterHeavyStream + ConfigKeepSession (RESETSCANMAIN/SEND on same TCP).
- ConfigKeepSession: on Program failure, CMD_RESET + Sleep + Program retry without Disconnect.
- Removed ForceDisconnect from balance apply.

## Verify
- No ForceDisconnect in BalanceChannelsHardware apply body.
- ConfigKeepSession present; CallCommand has no lPollMs.
- lazbuild RecorderLnx.lpi exit 0.
