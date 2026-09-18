param(
  [string]$ProcessName = 'RecorderLnx',
  [int]$DurationSeconds = 15,
  [int]$IntervalMs = 50,
  [int]$TimeoutMs = 1000,
  [switch]$IncludeHidden
)

$typeSource = @'
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
public static class WindowLatencyNative {
  public delegate bool EnumWindowsProc(IntPtr hwnd, IntPtr param);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc callback, IntPtr param);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hwnd, out uint pid);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hwnd);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr hwnd, StringBuilder text, int maxCount);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr hwnd, StringBuilder text, int maxCount);
  [DllImport("user32.dll", SetLastError=true)] public static extern IntPtr SendMessageTimeout(IntPtr hwnd, uint msg, IntPtr wparam, IntPtr lparam, uint flags, uint timeout, out IntPtr result);
  public static List<IntPtr> WindowsForProcess(uint processId, bool includeHidden) {
    var windows = new List<IntPtr>();
    EnumWindows((hwnd, unused) => {
      uint pid; GetWindowThreadProcessId(hwnd, out pid);
      if (pid == processId && (includeHidden || IsWindowVisible(hwnd))) windows.Add(hwnd);
      return true;
    }, IntPtr.Zero);
    return windows;
  }
  public static string Title(IntPtr hwnd) { var text = new StringBuilder(512); GetWindowText(hwnd, text, text.Capacity); return text.ToString(); }
  public static string Class(IntPtr hwnd) { var text = new StringBuilder(256); GetClassName(hwnd, text, text.Capacity); return text.ToString(); }
}
'@
Add-Type -TypeDefinition $typeSource

$processes = @(Get-Process -Name $ProcessName -ErrorAction Stop)
$windows = @()
foreach ($process in $processes) {
  foreach ($hwnd in [WindowLatencyNative]::WindowsForProcess([uint32]$process.Id, [bool]$IncludeHidden)) {
    $windows += [pscustomobject]@{ Pid=$process.Id; Hwnd=$hwnd; Title=[WindowLatencyNative]::Title($hwnd); Class=[WindowLatencyNative]::Class($hwnd) }
  }
}
if ($windows.Count -eq 0) { Write-Output "No top-level windows for $ProcessName in this desktop session."; exit 2 }
$windows | Format-Table Pid,Hwnd,Class,Title -AutoSize

$samples = New-Object System.Collections.Generic.List[object]
$deadline = [DateTime]::UtcNow.AddSeconds($DurationSeconds)
while ([DateTime]::UtcNow -lt $deadline) {
  foreach ($window in $windows) {
    $result = [IntPtr]::Zero
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $reply = [WindowLatencyNative]::SendMessageTimeout($window.Hwnd, 0, [IntPtr]::Zero, [IntPtr]::Zero, 2, [uint32]$TimeoutMs, [ref]$result)
    $watch.Stop()
    $samples.Add([pscustomobject]@{ Time=[DateTime]::Now.ToString('HH:mm:ss.fff'); Pid=$window.Pid; Hwnd=$window.Hwnd; Title=$window.Title; LatencyMs=[math]::Round($watch.Elapsed.TotalMilliseconds,2); TimedOut=($reply -eq [IntPtr]::Zero) })
  }
  Start-Sleep -Milliseconds $IntervalMs
}
$samples | Group-Object Hwnd | ForEach-Object {
  $rows = @($_.Group)
  $latencies = @($rows | ForEach-Object LatencyMs | Sort-Object)
  $p95 = $latencies[[math]::Min($latencies.Count-1,[int][math]::Floor($latencies.Count*0.95))]
  [pscustomobject]@{ Hwnd=$rows[0].Hwnd; Title=$rows[0].Title; Samples=$rows.Count; TimeoutCount=@($rows | Where-Object TimedOut).Count; MedianMs=$latencies[[int][math]::Floor($latencies.Count/2)]; P95Ms=$p95; MaxMs=$latencies[-1] }
} | Format-Table -AutoSize
$samples | Where-Object { $_.TimedOut -or $_.LatencyMs -ge 100 } | Select-Object -First 30 | Format-Table -AutoSize
