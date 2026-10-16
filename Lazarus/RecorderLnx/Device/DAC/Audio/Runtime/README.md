# PortAudio runtime

RecorderLnx uses one PortAudio V19 backend on Windows and Linux.

The Win64 runtime is stored as `Win64/portaudio.dll` and copied beside
`RecorderLnx.exe` by the Lazarus post-build step. The Windows installer also
includes the same file.

Binary provenance:

- repository: https://github.com/spatialaudio/portaudio-binaries
- snapshot commit: `c2422132502d8b1ab38237f0d1ffccdf90141749`
- source filename: `libportaudio64bit.dll`
- packaged filename: `portaudio.dll`
- SHA-256: `EC080194F01E4095C7FB43DBD7ED05AF922C5B34295056A9FF56782741D65481`
- host APIs: MME, DirectSound, WDM/KS and WASAPI

PortAudio is distributed under the MIT license. The upstream binary-package
notice is preserved in `PORTAUDIO-BINARIES-README.md`.
