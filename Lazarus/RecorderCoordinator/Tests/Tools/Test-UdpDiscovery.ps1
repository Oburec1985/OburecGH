param(
    [ValidateSet('Responder', 'Discover')]
    [string]$Mode,
    [string]$BindAddress = '0.0.0.0',
    [string[]]$Targets = @('255.255.255.255'),
    [int]$Port = 37651,
    [int]$TimeoutMs = 3000,
    [string]$Service = 'RecorderLnx',
    [string]$InstanceId = $env:COMPUTERNAME
)

$ErrorActionPreference = 'Stop'
$requestMagic = 'MERA_RECORDER_DISCOVERY_V1'
$utf8 = [System.Text.UTF8Encoding]::new($false)

function New-UdpClient([string]$Address, [int]$LocalPort) {
    $client = [System.Net.Sockets.UdpClient]::new()
    $client.ExclusiveAddressUse = $false
    $client.Client.SetSocketOption(
        [System.Net.Sockets.SocketOptionLevel]::Socket,
        [System.Net.Sockets.SocketOptionName]::ReuseAddress,
        $true)
    $client.EnableBroadcast = $true
    $client.Client.Bind([System.Net.IPEndPoint]::new(
        [System.Net.IPAddress]::Parse($Address), $LocalPort))
    return $client
}

if ($Mode -eq 'Responder') {
    $client = New-UdpClient $BindAddress $Port
    Write-Host "READY responder bind=$BindAddress port=$Port service=$Service"
    try {
        while ($true) {
            $remote = [System.Net.IPEndPoint]::new([System.Net.IPAddress]::Any, 0)
            $packet = $client.Receive([ref]$remote)
            $text = $utf8.GetString($packet)
            Write-Host "RX from=$remote bytes=$($packet.Length) text=$text"
            if ($text -ne $requestMagic) { continue }

            $replyObject = [ordered]@{
                protocol = 1
                service = $Service
                instance_id = $InstanceId
                host = $env:COMPUTERNAME
                address = $remote.Address.ToString()
            }
            $reply = $utf8.GetBytes(($replyObject | ConvertTo-Json -Compress))
            [void]$client.Send($reply, $reply.Length, $remote)
            Write-Host "TX to=$remote bytes=$($reply.Length)"
        }
    }
    finally {
        $client.Dispose()
    }
}

$client = New-UdpClient $BindAddress 0
$client.Client.ReceiveTimeout = 200
$request = $utf8.GetBytes($requestMagic)
$seen = @{}
try {
    foreach ($target in $Targets) {
        $endpoint = [System.Net.IPEndPoint]::new(
            [System.Net.IPAddress]::Parse($target), $Port)
        [void]$client.Send($request, $request.Length, $endpoint)
        Write-Host "TX target=$endpoint local=$($client.Client.LocalEndPoint)"
    }

    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
    while ([DateTime]::UtcNow -lt $deadline) {
        try {
            $remote = [System.Net.IPEndPoint]::new([System.Net.IPAddress]::Any, 0)
            $packet = $client.Receive([ref]$remote)
            $text = $utf8.GetString($packet)
            $key = "$remote|$text"
            if (-not $seen.ContainsKey($key)) {
                $seen[$key] = $true
                Write-Host "FOUND from=$remote payload=$text"
            }
        }
        catch [System.Net.Sockets.SocketException] {
            if ($_.Exception.SocketErrorCode -ne 'TimedOut') { throw }
        }
    }
}
finally {
    $client.Dispose()
}

if ($seen.Count -eq 0) {
    Write-Error 'RESULT failed: no discovery replies'
}
Write-Host "RESULT passed replies=$($seen.Count)"
