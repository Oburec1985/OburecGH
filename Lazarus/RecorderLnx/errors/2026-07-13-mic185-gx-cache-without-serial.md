# MIC-185 GX cache was not written without a resolved serial number

## Symptom

After reading MIC-185 hardware GX from the device, the tag contained the
calibration coefficients, but no files appeared under
`C:\Mera Files\Calibr\hardware\MIC-185`.

## Cause

The disk cache path is serial-number based:
`Calibr\hardware\MIC-185\snXXXX\rangeN\CC.csv`.
The manual GX read saved files only when the serial number had already been
resolved from the tag name, runtime device info, or a separate probe. If that
probe failed or had not run yet, the calibration was still registered in the
tag registry with a fallback name, but the CSV save block was skipped.

## Fix

After a successful `GET_CALIBR_KOEF` read, RecorderLnx now asks the same
connected MIC-185 client for `GET_SOFT_VERSION`, extracts the serial number,
updates the runtime device info cache, and then writes:

- `Calibr\hardware\MIC-185\snXXXX\rangeN\CC.csv`
- `Calibr\hardware\MIC-185\snXXXX\current\CC.csv` when the current evaluator
  is present in the reply.

If the serial number is still unavailable, RecorderLnx writes a diagnostic log
entry explaining that the hardware GX cache was skipped.

## Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
