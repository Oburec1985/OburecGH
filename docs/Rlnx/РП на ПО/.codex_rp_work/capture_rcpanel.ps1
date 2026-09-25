$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class Win32Capture {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr FindWindow(string className, string windowName);
  [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);
  public struct RECT { public int Left, Top, Right, Bottom; }
}
'@

function Save-WindowImage([IntPtr]$handle, [string]$path) {
    $rect = New-Object Win32Capture+RECT
    [void][Win32Capture]::GetWindowRect($handle, [ref]$rect)
    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top
    $bitmap = New-Object Drawing.Bitmap($width, $height)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
        $bitmap.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$captureDir = 'D:\works\OburecGH\docs\Rlnx\РП на ПО\.codex_rp_work\rcpanel_capture'
$exePath = Join-Path $captureDir 'RecorderCoordinator.exe'
$process = Start-Process -FilePath $exePath -WorkingDirectory $captureDir -PassThru
try {
    for ($i = 0; $i -lt 40 -and $process.MainWindowHandle -eq 0; $i++) {
        Start-Sleep -Milliseconds 250
        $process.Refresh()
    }
    if ($process.MainWindowHandle -eq 0) { throw 'RCPanel main window was not created.' }
    $handle = $process.MainWindowHandle
    [void][Win32Capture]::SetForegroundWindow($handle)
    Start-Sleep -Seconds 1
    Start-Sleep -Seconds 1
    [void][Win32Capture]::SetForegroundWindow($handle)
    Save-WindowImage $handle (Join-Path $captureDir 'rcpanel-hosts.png')
    for ($tab = 1; $tab -le 3; $tab++) {
        [Windows.Forms.SendKeys]::SendWait('^{TAB}')
        Start-Sleep -Milliseconds 800
        $name = @('rcpanel-events.png', 'rcpanel-storages.png', 'rcpanel-log.png')[$tab - 1]
        Save-WindowImage $handle (Join-Path $captureDir $name)
    }
}
finally {
    if (-not $process.HasExited) { $process.CloseMainWindow() | Out-Null; Start-Sleep -Milliseconds 500 }
    if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force }
}
