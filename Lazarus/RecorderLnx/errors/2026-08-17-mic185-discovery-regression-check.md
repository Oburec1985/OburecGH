# MIC-185 discovery regression check

## Report

The user suspected that MIC-185 devices stopped appearing after MIC-140 discovery work.

## Confirmed facts

- `Core/uRecorderNetworkBinding.pas` still classifies modern MIC-183/MIC-185 types `$020A0000` and `$02190000`, and legacy types `$440E` and `$442A`, as `MIC183/185`.
- `C:\Mera Files\RecorderLnx\LogWindows.log` at `2026-08-17 13:22:22.925` reports 12 broadcast devices: eight MIC183/185 and four MIC-140.
- The eight MIC183/185 endpoints are `.9.147`, `.148`, `.151`, `.152`, `.155`, `.156`, `.158`, and `.159`; their later initialize stages read serial numbers successfully.
- No uncommitted change was present in the common broadcast or settings-dialog discovery files during this check.

## Conclusion

No MIC-185 discovery regression is confirmed. If the search dialog omits the rows in a later run, capture that run's `[HardwareSearch]` lines and inspect dialog filtering/configured-state separately from network discovery.


## Confirmed root cause and fix

The network parser was not broken. The dialog ran after configured MIC-185
devices had opened their single-client working sessions; those devices could
stop answering broadcast, while the dialog accepted only fresh replies.

The dialog now merges fresh broadcast replies with configured MIC-185 devices
confirmed by the active runtime registry. It does not open another TCP client;
the existing `lSeenIds` set removes duplicates. Full `RecorderLnx.lpi` rebuild
completed with exit code 0. A fresh UI hardware-search check remains.

