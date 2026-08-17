# 2026-08-17 - MIC-185 hardware GX read opens a second TCP client

## Symptom

When reading hardware GX for MIC-185 tags, every selected channel reported:
`MIC183/185 <host>:4000 already has an active TCP client in RecorderLnx`.

## Confirmed Facts

- The error repeated for many channels of the same endpoint, for example
  `192.168.9.159:4000`.
- The tag dialog calls `RecorderMic185DownloadHardwareCalibrationFromDeviceEx`
  once per selected tag.
- After cache miss, that function created a new `TRecorderMebiusTcpClient` for
  the tag endpoint.
- MIC-185 is a single-client device; active RecorderLnx runtime already owns
  the TCP session.

## Checked Hypotheses

- **Cached GX only:** not enough. If cache already exists the function exits
  before TCP, but the reported error proves this path had cache misses.
- **Wrong endpoint parse:** not supported by the screenshot; all errors point
  to the expected MIC185 endpoint and port.
- **Second TCP from GX dialog:** confirmed in
  `uRecorderMic185Calibration.pas`.

## Fix

- Exported `RecorderMic185FindLiveDevice` from the MIC185 data source module.
- Added `TRecorderMic185Device.TryReadChannelRangeKx`, which reads
  `GET_CALIBR_KOEF` through the already opened MIC185 client.
- `RecorderMic185DownloadHardwareCalibrationFromDeviceEx` now first reuses the
  live device. A separate TCP client is created only when RecorderLnx does not
  already own the endpoint.
- If acquisition is currently started, live GX read returns a clear error:
  stop preview before reading MIC185 GX. This avoids mixing service commands
  with the measurement data stream.

## Verification

Full `RecorderLnx.lpi` rebuild completed with exit code 0. The post-build
`copy_sdb_res.bat` still prints the pre-existing Windows `#!/bin/sh` message,
but lazbuild finished successfully.
