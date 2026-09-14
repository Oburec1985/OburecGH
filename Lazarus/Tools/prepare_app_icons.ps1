param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Save-PngSize {
    param(
        [System.Drawing.Image]$Image,
        [int]$Size,
        [string]$Destination
    )

    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear([System.Drawing.Color]::Transparent)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.DrawImage($Image, 0, 0, $Size, $Size)
        } finally {
            $graphics.Dispose()
        }
        $bitmap.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $bitmap.Dispose()
    }
}

function New-MultiSizeIcon {
    param(
        [System.Drawing.Image]$Image,
        [int[]]$Sizes,
        [string]$Destination
    )

    $frames = @()
    foreach ($size in $Sizes) {
        $bitmap = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        try {
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.Clear([System.Drawing.Color]::Transparent)
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
                $graphics.DrawImage($Image, 0, 0, $size, $size)
            } finally {
                $graphics.Dispose()
            }
            $colorBytes = $size * $size * 4
            $maskStride = [int]([Math]::Ceiling($size / 32.0) * 4)
            $maskBytes = $maskStride * $size
            $stream = [System.IO.MemoryStream]::new()
            $frameWriter = [System.IO.BinaryWriter]::new($stream)
            $bits = $null
            try {
                # Old Lazarus/FPC icon readers expect a BITMAPINFOHEADER here.
                # PNG-compressed ICO frames can be mistaken for a DIB and raise
                # FPImageException before the main form is created.
                $frameWriter.Write([uint32]40)
                $frameWriter.Write([int32]$size)
                $frameWriter.Write([int32]($size * 2))
                $frameWriter.Write([uint16]1)
                $frameWriter.Write([uint16]32)
                $frameWriter.Write([uint32]0)
                $frameWriter.Write([uint32]($colorBytes + $maskBytes))
                $frameWriter.Write([int32]0)
                $frameWriter.Write([int32]0)
                $frameWriter.Write([uint32]0)
                $frameWriter.Write([uint32]0)

                $rect = [System.Drawing.Rectangle]::new(0, 0, $size, $size)
                $bits = $bitmap.LockBits($rect,
                    [System.Drawing.Imaging.ImageLockMode]::ReadOnly,
                    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
                $row = [byte[]]::new($size * 4)
                for ($y = $size - 1; $y -ge 0; $y--) {
                    $source = [System.IntPtr]::Add($bits.Scan0, $y * $bits.Stride)
                    [System.Runtime.InteropServices.Marshal]::Copy($source, $row, 0, $row.Length)
                    $frameWriter.Write($row)
                }
                $frameWriter.Write([byte[]]::new($maskBytes))
                $frameWriter.Flush()
                $frames += ,$stream.ToArray()
            } finally {
                if ($null -ne $bits) {
                    $bitmap.UnlockBits($bits)
                }
                $frameWriter.Dispose()
                $stream.Dispose()
            }
        } finally {
            $bitmap.Dispose()
        }
    }

    $file = [System.IO.File]::Create($Destination)
    $writer = [System.IO.BinaryWriter]::new($file)
    try {
        $writer.Write([uint16]0)
        $writer.Write([uint16]1)
        $writer.Write([uint16]$Sizes.Count)
        $offset = 6 + 16 * $Sizes.Count
        for ($index = 0; $index -lt $Sizes.Count; $index++) {
            $dimension = if ($Sizes[$index] -eq 256) { 0 } else { $Sizes[$index] }
            $writer.Write([byte]$dimension)
            $writer.Write([byte]$dimension)
            $writer.Write([byte]0)
            $writer.Write([byte]0)
            $writer.Write([uint16]1)
            $writer.Write([uint16]32)
            $writer.Write([uint32]$frames[$index].Length)
            $writer.Write([uint32]$offset)
            $offset += $frames[$index].Length
        }
        foreach ($frame in $frames) {
            $writer.Write($frame)
        }
    } finally {
        $writer.Dispose()
        $file.Dispose()
    }
}

$recorderDir = Join-Path $RepoRoot 'Lazarus\RecorderLnx\resources\app'
$panelDir = Join-Path $RepoRoot 'Lazarus\RecorderCoordinator\resources\app'

$recorderIcon = [System.Drawing.Icon]::new((Join-Path $recorderDir 'RecorderLnx.ico'))
try {
    $recorderBitmap = $recorderIcon.ToBitmap()
    try {
        Save-PngSize $recorderBitmap 256 (Join-Path $recorderDir 'RecorderLnx.png')
    } finally {
        $recorderBitmap.Dispose()
    }
} finally {
    $recorderIcon.Dispose()
}

$panelImage = [System.Drawing.Image]::FromFile((Join-Path $panelDir 'rcPanel-source.png'))
try {
    Save-PngSize $panelImage 256 (Join-Path $panelDir 'rcPanel.png')
    New-MultiSizeIcon $panelImage @(16, 24, 32, 48, 64, 128, 256) (Join-Path $panelDir 'rcPanel.ico')
} finally {
    $panelImage.Dispose()
}

Write-Host 'Application icons prepared.'
