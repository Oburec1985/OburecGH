param(
    [Parameter(Mandatory = $true)][string]$Target,
    [Parameter(Mandatory = $true)][string]$Command,
    [switch]$Sudo,
    [int]$TimeoutSec = 0
)

$ErrorActionPreference = 'Stop'
$pwshExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$askpassScript = 'D:\works\OburecGH\.dsh-work\askpass.ps1'

$env:SSH_ASKPASS = "$pwshExe -NoProfile -ExecutionPolicy Bypass -File `"$askpassScript`""
$env:SSH_ASKPASS_REQUIRE = 'force'
$env:DISPLAY = 'dsh-ssh'

$sshArgs = @(
    '-o', 'StrictHostKeyChecking=accept-new',
    '-o', 'NumberOfPasswordPrompts=1',
    '-o', 'ConnectTimeout=15',
    '-o', 'ServerAliveInterval=10',
    '-o', 'LogLevel=ERROR',
    $Target
)

if ($Sudo) {
    # Feed the password to sudo over stdin
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Command))
    $remote = "read -r pw; echo `"`$pw`" | sudo -S -p '' bash -c `"echo $b64 | base64 -d | bash`""
    $inputText = '11111111' + "`n"
    $inputText | & "$env:SystemRoot\System32\OpenSSH\ssh.exe" @sshArgs $remote
} else {
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Command))
    & "$env:SystemRoot\System32\OpenSSH\ssh.exe" @sshArgs "echo $b64 | base64 -d | bash"
}

exit $LASTEXITCODE
