param([string]$LibraryPath = 'C:\Program Files (x86)\Mera\RecorderLnx\portaudio.dll')
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$escapedPath = $LibraryPath.Replace('"', '""')
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class DacAudioProbe {
  [StructLayout(LayoutKind.Sequential)] public struct Device {
    public int Version; public IntPtr Name; public int HostApi;
    public int Inputs; public int Outputs;
    public double LowInput; public double LowOutput;
    public double HighInput; public double HighOutput; public double Rate;
  }
  [DllImport(@"$escapedPath", CallingConvention=CallingConvention.Cdecl)] public static extern int Pa_Initialize();
  [DllImport(@"$escapedPath", CallingConvention=CallingConvention.Cdecl)] public static extern int Pa_Terminate();
  [DllImport(@"$escapedPath", CallingConvention=CallingConvention.Cdecl)] public static extern int Pa_GetDeviceCount();
  [DllImport(@"$escapedPath", CallingConvention=CallingConvention.Cdecl)] public static extern int Pa_GetDefaultOutputDevice();
  [DllImport(@"$escapedPath", CallingConvention=CallingConvention.Cdecl)] public static extern IntPtr Pa_GetDeviceInfo(int index);
}
"@
$init = [DacAudioProbe]::Pa_Initialize()
if ($init -ne 0) { throw "Pa_Initialize: $init" }
try {
  $default = [DacAudioProbe]::Pa_GetDefaultOutputDevice()
  $count = [DacAudioProbe]::Pa_GetDeviceCount()
  Write-Output "DEFAULT=$default COUNT=$count SESSION=$([Diagnostics.Process]::GetCurrentProcess().SessionId)"
  for ($index = 0; $index -lt $count; $index++) {
    $ptr = [DacAudioProbe]::Pa_GetDeviceInfo($index)
    if ($ptr -eq [IntPtr]::Zero) { continue }
    $info = [Runtime.InteropServices.Marshal]::PtrToStructure($ptr, [type][DacAudioProbe+Device])
    if ($info.Outputs -le 0) { continue }
    $length = 0
    while ([Runtime.InteropServices.Marshal]::ReadByte($info.Name, $length) -ne 0) { $length++ }
    $bytes = New-Object byte[] $length
    [Runtime.InteropServices.Marshal]::Copy($info.Name, $bytes, 0, $length)
    $name = [Text.Encoding]::UTF8.GetString($bytes)
    Write-Output "OUTPUT=$index HOST=$($info.HostApi) CHANNELS=$($info.Outputs) RATE=$($info.Rate) NAME=$name"
  }
} finally { [void][DacAudioProbe]::Pa_Terminate() }
