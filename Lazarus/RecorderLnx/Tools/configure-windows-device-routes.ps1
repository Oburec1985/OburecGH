[CmdletBinding()]
param(
    [string]$InterfaceAlias = 'Ethernet 2',
    [string[]]$LocalAddresses = @('192.168.3.65/20', '192.169.12.99/24'),
    [string[]]$DestinationPrefixes = @(
        '192.168.5.0/24',
        '192.168.9.0/24',
        '192.169.12.87/32'
    ),
    [switch]$InstallStartupTask
)

$ErrorActionPreference = 'Stop'
$taskName = 'RecorderLnx device routes'

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run this script from PowerShell started as Administrator.'
    }
}

function Get-CidrParts([string]$Cidr) {
    $parts = $Cidr.Split('/')
    if ($parts.Count -ne 2) {
        throw "Invalid CIDR value: $Cidr"
    }
    [pscustomobject]@{
        Address = $parts[0]
        PrefixLength = [int]$parts[1]
    }
}

function Ensure-LocalAddress([int]$InterfaceIndex, [string]$Cidr) {
    $cidrParts = Get-CidrParts $Cidr
    $existing = Get-NetIPAddress -InterfaceIndex $InterfaceIndex `
        -AddressFamily IPv4 -IPAddress $cidrParts.Address `
        -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host "Address exists: $Cidr"
        return
    }

    New-NetIPAddress -InterfaceIndex $InterfaceIndex `
        -IPAddress $cidrParts.Address `
        -PrefixLength $cidrParts.PrefixLength `
        -SkipAsSource $false | Out-Null
    Write-Host "Address added: $Cidr"
}

function Ensure-OnLinkRoute([int]$InterfaceIndex, [string]$DestinationPrefix) {
    $routes = @(Get-NetRoute -DestinationPrefix $DestinationPrefix `
        -AddressFamily IPv4 -ErrorAction SilentlyContinue)
    $wanted = @($routes | Where-Object {
        ($_.InterfaceIndex -eq $InterfaceIndex) -and ($_.NextHop -eq '0.0.0.0')
    })

    if ($wanted.Count -eq 0) {
        $routes | Remove-NetRoute -Confirm:$false
        New-NetRoute -DestinationPrefix $DestinationPrefix `
            -InterfaceIndex $InterfaceIndex `
            -NextHop '0.0.0.0' `
            -RouteMetric 1 | Out-Null
        Write-Host "Route created: $DestinationPrefix -> ifIndex $InterfaceIndex (on-link)"
        return
    }

    $routes | Where-Object {
        ($_.InterfaceIndex -ne $InterfaceIndex) -or ($_.NextHop -ne '0.0.0.0')
    } | Remove-NetRoute -Confirm:$false
    Write-Host "Route exists: $DestinationPrefix -> ifIndex $InterfaceIndex (on-link)"
}

function Install-RouteTask([string]$ScriptPath) {
    $arguments = '-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $ScriptPath
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arguments
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' `
        -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName $taskName -Action $action `
        -Trigger $trigger -Principal $principal -Force | Out-Null
    Write-Host "Startup task installed: $taskName"
}

Assert-Administrator

$adapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction Stop
if ($adapter.Status -ne 'Up') {
    throw "Network adapter '$InterfaceAlias' is not Up (status: $($adapter.Status))."
}

$interfaceIndex = $adapter.ifIndex
Write-Host "Adapter: $InterfaceAlias, ifIndex=$interfaceIndex"

foreach ($localAddress in $LocalAddresses) {
    Ensure-LocalAddress $interfaceIndex $localAddress
}

foreach ($destinationPrefix in $DestinationPrefixes) {
    Ensure-OnLinkRoute $interfaceIndex $destinationPrefix
}

if ($InstallStartupTask) {
    Install-RouteTask $PSCommandPath
}

Write-Host 'Result:'
Get-NetIPAddress -InterfaceIndex $interfaceIndex -AddressFamily IPv4 |
    Format-Table IPAddress, PrefixLength, AddressState, SkipAsSource -AutoSize
foreach ($destinationPrefix in $DestinationPrefixes) {
    Get-NetRoute -DestinationPrefix $destinationPrefix -AddressFamily IPv4 |
        Format-Table DestinationPrefix, InterfaceIndex, NextHop, RouteMetric -AutoSize
}
