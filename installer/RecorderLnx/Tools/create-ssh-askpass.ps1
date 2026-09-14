param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$source = @'
using System;

public static class RecorderSshAskPass
{
    public static void Main()
    {
        string password = Environment.GetEnvironmentVariable("RECORDER_DEPLOY_PASSWORD");
        if (String.IsNullOrEmpty(password))
            password = Environment.GetEnvironmentVariable("RECORDER_WOL_PASSWORD");
        Console.Write(password ?? String.Empty);
    }
}
'@

$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $compiler)) {
    throw "C# compiler was not found: $compiler"
}
$sourcePath = [System.IO.Path]::ChangeExtension($OutputPath, '.cs')
try {
    [System.IO.File]::WriteAllText($sourcePath, $source,
        [System.Text.Encoding]::UTF8)
    if (Test-Path -LiteralPath $OutputPath) {
        Remove-Item -LiteralPath $OutputPath -Force
    }
    & $compiler /nologo /target:exe /out:$OutputPath $sourcePath
    if (($LASTEXITCODE -ne 0) -or (-not (Test-Path -LiteralPath $OutputPath))) {
        throw "SSH askpass helper was not created: $OutputPath"
    }
} finally {
    if (Test-Path -LiteralPath $sourcePath) {
        Remove-Item -LiteralPath $sourcePath -Force
    }
}
