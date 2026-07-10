# MIC-185: units, hardware-GX button, dynamic UI encoding

## Symptom

- При нажатии кнопки выгрузки аппаратной ГХ для выбранного MIC-185 тега
  показывалось сообщение: "Среди выбранных тегов нет каналов MIC-140."
- После выбора единиц "Ом" MIC-185 канал продолжал визуально вести себя как
  канал в кодах.
- В динамических меню/диалогах встречались кракозябры.

## Context

- Пользователь просил не менять протокол MIC-185.
- Реальное чтение аппаратной ГХ MIC-185 из памяти прибора в RecorderLnx пока не
  реализовано.
- Для отсутствующих реальных коэффициентов принят fallback:
  `32768` кодов = `100%` выбранного номинального диапазона.

## Facts

- `UI/uTagSettingsDialog.pas` показывал кнопку выгрузки ГХ для MIC-185, но
  `DownloadHardwareCalibrationFromDeviceClick` обрабатывал только SourceId
  `MIC-140:` и имел текст `...нет каналов MIC-140`.
- `Device/mic185/uRecorderMic185DataSource.pas` публикует значения в теги через
  `PublishMeasurementBlock` с `AValuesAlreadyTransformed=True`, поэтому
  пересчет единиц должен быть выполнен до записи samples в теги.
- `Device/mic185/UI/uRecorderMic185SettingsDialog.pas` при создании/линковке
  измерительного тега сбрасывал `UnitName` на единицу диапазона, из-за чего
  пользовательский выбор "Ом" мог быть потерян.
- `rg -n "CP1251ToUTF8\('"` показал UTF-8 литералы, повторно обернутые в
  `CP1251ToUTF8`, в динамических диалогах и меню.

## Hypotheses

- Ошибка "нет каналов MIC-140" не связана с выбором тега, а является
  MIC-140-only обработчиком кнопки. Подтверждено кодом.
- Значения "в кодах" связаны с тем, что поток надо сначала номинально
  пересчитать в мВ. Принято как рабочий fallback до чтения реальной ГХ.
- Кракозябры в меню создаются не ресурсами `.lfm`, а строками, назначенными из
  кода с лишним `CP1251ToUTF8`. Подтверждено поиском.

## Actions

- `uTagSettingsDialog.pas`: обработчик выгрузки ГХ теперь различает MIC-185 и
  показывает честное сообщение, что чтение аппаратной ГХ MIC-185 из памяти пока
  не реализовано; протокол MIC-185 не тронут.
- `uRecorderMic185DataSource.pas`: добавлен номинальный пересчет
  `code * nominal_mV / 32768` перед переводом в мВ/Ом/мкм/м.
- `uRecorderMic185SettingsDialog.pas`: существующая единица измерительного тега
  больше не сбрасывается при линковке канала; диапазон пересчитывается в
  выбранной единице.
- Убраны лишние `CP1251ToUTF8('...')` вокруг UTF-8 литералов в динамических UI:
  `uRecorderSpectrumSettingsDialog.pas`, `uRecorderFrequencyBandsDialog.pas`,
  `uComponentSettingsDialog.pas`, `uMainForm.pas`, `uRecorderDataStorage.pas`.
- Добавлены поясняющие комментарии и `{$codepage UTF8}` в MIC-185 units с
  русскими строками/комментариями.

## Current Conclusion

MIC-185 protocol path remains unchanged. Values published into tags now use
the selected unit with nominal code fallback when real hardware-GX coefficients
are absent. The hardware-GX read button no longer misidentifies MIC-185 as
missing MIC-140 channels, but actual MIC-185 memory read is still a separate
protocol task.

## Verification

- `rg -n "CP1251ToUTF8\('" Lazarus\RecorderLnx\UI Lazarus\RecorderLnx\Core Lazarus\RecorderLnx\Device\mic185`
  returned no active matches.
- `rg -n "Рђ|Рџ|РЎ|СЃ|В±|РјР|РћРј" ... -g "*.pas" -g "*.lfm"`
  returned no active matches after fixing the dynamic UI strings and one
  damaged comment.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  passed. One earlier run failed on the known short-window thread timing check
  with only 2 ticks; immediate reruns passed.
## Follow-up 2026-07-10: explicit MIC-185 hardware-GX read

### New facts

- Original `examples\mebius.daq\mebius_daq_devices\ms\mic185\mic185.cpp`
  loads channel hardware evaluators in `CMIC185::LoadCalibrCoefficients` by
  calling `IOCTL_CMD_GET_CALIBR_KOEF` for each channel and applying the returned
  `MIC185_CHANNEL_KX_FULL`.
- `MebiusDAQDevices\mic183\mic183base\ComputePhysical.h` defines
  `MIC183_CHANNEL_KX` as `k,b` with evaluator math `k * (x - b)`.
- `IOCTL_CMD_RELOAD_CALIBR` exists, but it reloads a flash calibration file into
  OMAP memory and needs a separate device `fileType`; calling it from tag
  settings would change device state. The explicit RecorderLnx button therefore
  reads the currently loaded evaluator with `GET_CALIBR_KOEF`.

### Actions

- Added `Device/mic185/uRecorderMic185Calibration.pas`:
  connects through existing `TRecorderMebiusTcpClient`, calls
  `CMic185IoCtlCmdGetCalibrKoef`, reads the selected range `k,b`, creates a
  two-point hardware `TRecorderCalibration`, and assigns it to the tag.
- Added MIC185 command constants in `uMic185Constants.pas`.
- Updated `uRecorderMic185DataSource.pas` so assigned tag hardware GX is
  applied before MIC185 unit conversion; nominal fallback remains unchanged
  when no hardware GX is assigned.
- Updated `UI/uTagSettingsDialog.pas`:
  hardware-GX select/view now opens calibration list/properties,
  edit is no longer MIC140-only, and read-GX dispatches to MIC140 or MIC185.

### Verification

- First `lazbuild -B RecorderLnx.lpi` compiled but failed to link because a
  running `RecorderLnx.exe` held the output file (`error code: 5`, PID 15324).
  After `Stop-Process -Id 15324`, rebuild completed with exit code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  completed with exit code 0.

## Follow-up 2026-07-10: hardware-GX UI displayed id/list instead of k,b

### New facts

- The tag dialog hardware-GX display field was also used as the storage source
  for `TRecorderTag.HardwareCalibrationName` on OK/Apply.
- For MIC185 this is unsafe once the field shows a human-readable summary:
  writing `k=...; b=...` back into `HardwareCalibrationName` would break the
  link to the stored `TRecorderCalibration`.
- The assigned MIC185 hardware calibration is a two-point curve created from
  original math `y = k * (code - b)`, so `k,b` can be reconstructed from points:
  `k = (y1-y0)/(x1-x0)`, `b = x0 - y0/k`.

### Actions

- `uRecorderMic185Calibration.pas`: added detailed read function returning
  `k`, `b`, calibration name, and helpers to format/extract MIC185 hardware
  `k,b` from the stored calibration.
- `uTagSettingsDialog.pas`: MIC185 hardware-GX field now displays only
  `k=...; b=...`, while `HardwareCalibrationName` remains unchanged internally.
- `uTagSettingsDialog.pas`: OK/Apply no longer copies hardware-GX display text
  back into `HardwareCalibrationName`.
- `uTagSettingsDialog.pas`: hardware-GX view opens the assigned calibration
  properties directly; the explicit read-GX success message lists per-tag
  `k,b`.

### Verification

- First rebuild reached link but failed with `error code: 5` because
  `RecorderLnx.exe` PID 14752 held the output file; after stopping it, rebuild
  succeeded.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  completed with exit code 0 after the final display change.

## Follow-up 2026-07-10: unchecked hardware-GX must publish codes

### New facts

- `TRecorderTagRegistry.FindTagHardwareCalibration` already respects
  `TRecorderTag.HardwareCalibrationEnabled`, so it returns `nil` when the
  hardware-GX checkbox is unchecked.
- `RecorderMic185ConvertValue` treated `nil` hardware calibration as a signal
  to use the nominal fallback `code * nominal_mV / 32768`. That is correct for
  enabled calculation without real coefficients, but wrong for the unchecked
  UI mode where the user expects raw codes.

### Action

- `TRecorderMic185DataSource.PublishMeasurementBlock` now checks
  `lTag.HardwareCalibrationEnabled` before calling `RecorderMic185ConvertValue`.
  When the checkbox is off, it publishes raw `ABlock.Values[I][J]`. When the
  checkbox is on, it uses the existing conversion path: assigned GX if present,
  otherwise nominal fallback and selected unit conversion.

### Verification

- First rebuild failed only at link because a running `RecorderLnx.exe`
  PID 19184 held the output file (`error code: 5`).
- After `Stop-Process -Id 19184`,
  `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  completed with exit code 0.

## Follow-up 2026-07-10: hardware-GX assignment was lost/hidden after OK

### New facts

- `RecorderMic185DownloadHardwareCalibrationFromDeviceEx` already assigned the
  read calibration to the tag by writing `HardwareCalibrationName` and
  `HardwareCalibrationEnabled=True`.
- Those two tag fields were not serialized by `uRecorderProjectFiles.pas`, so
  saving/reloading the project could lose the hardware-GX link even though the
  calibration entry itself existed in the registry.
- `UpdateHardwareCurveText` used only the first selected tag and a normal
  checked/unchecked state. After reading GX for a group of MIC185 channels,
  different per-channel calibration names could be hidden or overwritten by an
  OK/Apply pass through the common tag dialog.
- For MIC185 the hardware-GX edit is a display surface: it may show `k,b`, so
  it must not be copied back into `HardwareCalibrationName`.

### Actions

- `Core/uRecorderProjectFiles.pas`: save/load
  `hardwareCalibrationEnabled` and `hardwareCalibrationName` for every tag.
- `UI/uTagSettingsDialog.pas`: hardware-GX display now:
  - shows MIC185 reconstructed `k,b` when the stored calibration exists;
  - falls back to the stored calibration name/alias when the registry object is
    missing;
  - shows `<разные аппаратные ГХ>` and grays the checkbox for multi-select with
    different hardware-GX assignments.
- `UI/uTagSettingsDialog.pas`: OK/Apply still does not copy the hardware-GX
  display text back into the tag name field, preserving the stable registry key.

### Verification

- First rebuild had previously failed only at link because a running
  `RecorderLnx.exe` held the output executable. Stopped PID 21752.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  completed with exit code 0.

## Follow-up 2026-07-10: hardware-GX was cleared by tag OK

### New facts

- Reproduced from code path: read-GX writes `HardwareCalibrationName` and
  `HardwareCalibrationEnabled=True`, then `TTagSettingsDialog.OkButtonClick`
  calls `StoreToTags`.
- At the end of `StoreToTags`, every tag that did not use MIC140 settings
  called `RecorderTagClearMic140Settings`.
- `RecorderTagClearMic140Settings` clears the generic tag hardware-GX fields:
  `HardwareCalibrationEnabled := False` and `HardwareCalibrationName := ''`.
- MIC185 tags are not MIC140 tags, so the OK path erased the just-read MIC185
  hardware-GX assignment before the dialog was reopened.

### Actions

- `UI/uTagSettingsDialog.pas`: the cleanup now skips MIC185 hardware sources:
  `not RecorderIsHardwareMic185TagSource(lTag.SourceId)`.
- `Device/mic185/uRecorderMic185DataSource.pas`: MIC185 `tagLinks[]` now also
  save/load `hardwareCalibrationEnabled` and `hardwareCalibrationName`, so the
  source-specific link section preserves the same assignment as the common
  `tags[]` section.

### Verification

- Stopped running `RecorderLnx.exe` PID 11208 which held the output file.
- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  completed with exit code 0.

## Follow-up 2026-07-10: MIC185 hardware-GX disk cache

### New facts

- RecorderLnx MIC140 already persists hardware GX in
  `C:\Mera Files\Calibr\hardware\MIC140\snXXXX\<range>\NN.csv`.
- The checked live file
  `C:\Mera Files\Calibr\hardware\MIC140\sn0164\06_100mV\01.csv` is plain text
  CSV with `x,y` points and no header.
- Original Mebius `CBaseVirtualChannel::UpdateDevTareDB` and
  `QueryDevTareFromDB` build the standard path as
  `GetCalibrDir + GetCalibrSubDir + "%02d.csv"` and call evaluator
  text export/import.
- Original MIC185 reads `k,b` through `IOCTL_CMD_GET_CALIBR_KOEF` into a
  channel evaluator and does not reliably write those coefficients through the
  standard `Calibr` database branch.

### Actions

- `uRecorderMic185Calibration.pas` now creates stable hardware-GX names:
  `MIC185 snXXXX rangeN chCC`.
- The MIC185 cache path is
  `C:\Mera Files\Calibr\hardware\MIC-185\snXXXX\rangeN\CC.csv`.
- A read request first tries the CSV cache; if it exists, the device is not
  queried again.
- A successful device read saves the two-point CSV equivalent of
  `y = k * (code - b)`.
- `uTagSettingsDialog.pas` attempts to restore a MIC185 GX object from disk when
  a tag has a saved GX name but the registry object is not loaded.
- `uRecorderMic185DataSource.pas` performs the same lazy restore in the publish
  path, so a project reload can use the cached GX before the user opens the tag
  dialog again.
- Added `Docs/devices/mic185/hardware_calibration_cache.md` with source list,
  path, format and original Recorder compatibility notes.

### Verification

- `C:\lazarus\lazbuild.exe -B D:\works\OburecGH\Lazarus\RecorderLnx\RecorderLnx.lpi`
  completed with exit code 0.
- `D:\works\OburecGH\Lazarus\Tests\RecorderTests\DataSources\lib\RecorderDataSourcesTest.exe`
  completed with exit code 0.

### Current conclusion

The MIC185 protocol remains unchanged. Disk persistence is implemented at the
RecorderLnx calibration layer and reuses the same CSV-style Mera/Calibr storage
contract that MIC140 and the standard Mebius virtual-channel path already use.
