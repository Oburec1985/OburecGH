# Trend component in original Recorder

This note records the original Recorder behavior that RecorderLnx follows for
the user mnemonic Trend component.

Original source locations:

- `D:\works\windev-v3.9\rc_guisrv\mnemo\trendform.h`
- `D:\works\windev-v3.9\rc_guisrv\mnemo\trendform.cpp`
- `D:\works\windev-v3.9\rc_guisrv\setup\tcf_set.*`
- `D:\works\windev-v3.9\rc_guisrv\setup\tcf_lset.*`
- `D:\works\windev-v3.9\rc_guisrv\setup\tcf_aset.*`
- `D:\works\windev-v3.9\rc_guisrv\ind_wrap\mrtrend.*`

## Original Model

The visual form is `CTrendVForm`. It owns a `CmrTrend` control and a collection
of per-line `CTrendData` objects. Settings are split into:

- trend-wide display parameters: duration, refresh/update period, trend type,
  time format, Y-axis mode, legend and font settings;
- line settings: tag, display name, estimate id, axis assignment, color, width,
  visibility;
- axis settings: axis name, color and numeric range.

The factory id in the original code is
`{0EFE371B-61E8-4d3e-89AA-C9969788C467}`. The default size is `400x300`, and the
component is not a single-tag-only component.

## Update Path

On `VSN_LEAVERCCONFIG`, the form resolves configured line tags and creates one
`CTrendData` object per line. Each line gets block access to the corresponding
tag and uses Recorder refresh period as the input block delta. The trend control
gets the configured update period.

On `VSN_RCSTART`, line buffers are reset and the current OLE date/time is
propagated as the trend start time.

On `VSN_UPDATE_DATA`, every `CTrendData` reads only ready blocks, calculates the
configured estimate over the period window, and appends points to the trend.
Regular channels append Y points on an evenly spaced X axis; scalar/irregular
channels append explicit X/Y points.

The important threading rule is that acquisition-side data access is short and
bounded. Heavy UI drawing is not done while source data locks are held.

## RecorderLnx Implementation Notes

RecorderLnx mirrors the model with `TRecorderTrendComponent`,
`TRecorderTrendAxis`, and `TRecorderTrendLine` in
`RecorderLnx/Core/uRecorderFormModel.pas`.

The LCL view `TRecorderTrendView` keeps per-line history in memory and updates
from tag snapshots on UI refresh. If the trend update period is shorter than the
Recorder UI refresh period, `RefreshTrend` advances in multiple configured
period-sized steps and appends multiple trend points in one UI cycle.

Trend configuration is persisted in the GUI INI beside other mnemonic component
settings: trend duration, update period, Y-axis mode, legend flags, axes, and
lines. The settings dialog is resource-free (`uRecorderTrendSettingsDialog.pas`)
to avoid accidental legacy `.lfm` encoding damage.

At component creation, RecorderLnx initializes the first line from the selected
tag when available, and initializes the first Y axis range from the tag's
configured value range.
