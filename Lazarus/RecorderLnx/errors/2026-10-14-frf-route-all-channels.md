# FRF route acquisition and interpretation

Request: MDB object directory selection; route points must not choose a sensor.
Route editor adds MDB checkbox resolving the selected XML object on its owner
page, using object/frf or object/frf/track according to scenario mode. MDB mode
locks manual folder editing and refreshes the object path before load/save.
Channel picker/search are hidden; route rows describe all FRF/SPM sensors.
CaptureRouteStep saves session.json with all configured channels, raw samples,
spectra and single-impact FRF/phase/coherence. It keeps a legacy curve.frf for
the existing intensity interpretation, which still needs separate integration.
Verification: ImpactHammerServiceTest compiled with the full-session change.
Production build succeeded for MDB UI before the all-channel change; subsequent
UI/application builds are blocked by missing RecorderPluginCapabilities,
RecorderPluginDispatchEvent and RecorderPluginRepaint in unrelated oscillogram
plugin code. No unrelated plugin edits were made.
Remaining prior work: main-widget route spinner, runtime protection, automatic
Save wiring and overwrite confirmation are not yet implemented.
