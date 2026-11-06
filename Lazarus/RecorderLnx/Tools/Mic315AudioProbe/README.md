# MIC315 read-only audio diagnostics

Run `Run-Mic315AudioDiagnostics.cmd` in the same MIC315 Windows session as
RecorderLnx. It does not stop Recorder or open audio playback. It reads services,
sound controllers, PnP audio endpoints, MMDevices render endpoint states and the
PortAudio DLL loaded by Recorder, then invokes the standalone native probe.

Reports `Mic315-audio-*.log` and `Mic315-portaudio-*.log` are written beside the
scripts. Access errors are recorded explicitly; an empty inventory after an
error is not evidence that hardware is absent. No drivers, registry settings,
services, scheduled tasks or process lifetimes are modified.

The native probe takes explicit arguments:

```text
Mic315AudioProbe.exe --library=C:\absolute\path\portaudio.dll --out=C:\existing\folder\probe.log
```

It reports PortAudio version, host APIs and devices, plus WinMM waveOut device
capabilities. Its independent process balances successful Pa_Initialize with
Pa_Terminate before unloading. It binds no audio stream operations. The project
uses only FPC/Windows units and can be built with `lazbuild -B Mic315AudioProbe.lpi`.

Interpret separately: PnP controller presence, global MMDevices registry state,
WinMM visibility in the current session, and PortAudio visibility in the loaded
DLL are different observations. A missing PortAudio entry alone does not prove
that the USB device is disconnected.
