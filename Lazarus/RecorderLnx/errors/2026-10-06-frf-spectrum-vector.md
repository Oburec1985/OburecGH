# FRF spectrum and vector-tag iteration (2026-10-06)

Request: match ordinary spectrum scaling in impact-hammer FRF, include generated vector signals in the tag picker, remove the redundant top status panel, and derive `IsVector` solely from nonzero sampling frequency.

Changes: subtract the capture-tail baseline before FFT; apply RMS spectrum scaling `sqrt(2)/FFTSize` in both chart data and exported spectra; apply optional temporal gate across the full capture rather than restarting it per FFT segment; filter available FRF tags by positive `PollFrequencyHz`; make `IsVector` read-only and derived from `PollFrequencyHz > 0`; remove the top status panel and retain the settings button in navigation.

Verification: ImpactHammerTest, ImpactHammerServiceTest, and ImpactHammerUiSmoke build and pass. The main RecorderLnx binary was not replaced because a running process locked the executable during the earlier full build attempt. Full legacy RecorderTagsTest has an unrelated existing epoch-start failure, while the targeted vector rule test passed.

Remaining: verify the spectrum shape and generated-signal picker in a restarted live application; review scalar algorithm tags with positive frequency, which now intentionally count as vectors under the requested rule.

## 2026-10-06: suspected over-smooth hammer spectrum

The ordinary Spectrum evaluator and FRF presentation both use `sqrt(2)/FFTSize` for RMS amplitude. Presenter/view copy all frequency bins without decimation. However, with Welch disabled and capture longer than FFT, FRF still split the capture into `ceil(CaptureSamples/FFTSize)` segments and averaged their powers; original `plgEvalFRF` `TDataBlock.BuildSpm` executes one FFT in this mode. FRF now uses exactly one segment when Welch is off; Welch-on segmentation remains unchanged. A new bin-by-bin test compares the hammer spectrum with the ordinary Spectrum evaluator on the same 20-point capture and 16-point FFT, including a nonzero trailing block that must not enter the first FFT. `ImpactHammerTest` and `ImpactHammerServiceTest` build and pass.

This corrects the processing discrepancy but does not by itself prove that two screenshots captured the same time interval. A short, smooth force impulse can naturally have a smooth spectral envelope. Live verification needs the same raw impact buffer passed to both evaluators and its per-bin difference recorded; do not infer a remaining numerical error solely from the appearance of spectra at different times.

The combined `RecorderLnx.lpi` forced build completed successfully later in this iteration (203152 lines compiled, exit 0); the earlier executable-lock limitation no longer applies to the current build.

## 2026-10-06: persistent hammer-spectrum concern

The active local project `C:\Mera Files\RecorderLnx\config\projects\test185_149\default.gui.ini` stores `Impact.WelchEnabled=False` for `ImpactHammer67`. `LoadFromStrings` reads False and both service DSP setup paths pass `WelchSegmentSamples=0` when the flag is False. A service-level test publishes a 20160-sample hammer capture, serializes/reloads the model, and verifies the hammer spectrum against direct DSP for every FFT bin: Welch off uses one segment; Welch on uses multiple segments and differs. The chart's hammer curve uses `ExcitationPower`, not a response spectrum. The ordinary-spectrum screenshot's `1694` is explicitly `Max i` (FFT-bin index), **not** a force peak; the earlier claim comparing it with the FRF time-domain peak near 12140 was erroneous and is withdrawn. Thus the permanent-Welch hypothesis is rejected, but the live visual discrepancy remains unproven without raw samples from the same hit. Do not invent a scaling/window change based only on these images.
