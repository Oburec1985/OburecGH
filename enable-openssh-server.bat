@echo off
setlocal EnableExtensions
chcp 65001 >nul

if /I "%~1"=="--run" goto :run
call "%~f0" --run >"%~dp0enable-openssh-server.log" 2>&1
set "SETUP_EXIT=%ERRORLEVEL%"
if exist "C:\Mera Files\screens\" copy /Y "%~dp0enable-openssh-server.log" "C:\Mera Files\screens\enable-openssh-server.log" >nul
type "%~dp0enable-openssh-server.log"
echo.
echo Diagnostic log: %~dp0enable-openssh-server.log
pause
exit /b %SETUP_EXIT%

:run

rem Run locally on the target Windows PC as Administrator.
rem Installs Microsoft OpenSSH Server, starts sshd and opens TCP/22.

fltmc >nul 2>&1
if errorlevel 1 (
  echo ERROR: Run this file as Administrator.
  echo Right-click the BAT file and select "Run as administrator".
  exit /b 5
)

echo [1/6] Checking Windows OpenSSH Server capability...
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
  "$caps = @(Get-WindowsCapability -Online -Name 'OpenSSH.Server*' -ErrorAction Stop); $cap = $caps[0]; if ($null -eq $cap) { throw 'OpenSSH.Server capability is unavailable on this Windows installation.' }; Write-Host ('Capability: ' + $cap.Name + ', state=' + $cap.State); if ($cap.State -ne 'Installed') { $r = Add-WindowsCapability -Online -Name $cap.Name -ErrorAction Stop; Write-Host ('Install state=' + $r.State + ', restartNeeded=' + $r.RestartNeeded) }"
if errorlevel 1 goto :failed

echo [2/6] Validating sshd configuration...
if not exist "%WINDIR%\System32\OpenSSH\sshd.exe" (
  echo ERROR: sshd.exe was not installed in %WINDIR%\System32\OpenSSH.
  goto :failed
)
"%WINDIR%\System32\OpenSSH\ssh-keygen.exe" -A
if errorlevel 1 (
  echo ERROR: SSH host key generation failed.
  goto :failed
)
"%WINDIR%\System32\OpenSSH\sshd.exe" -t
if errorlevel 1 (
  echo ERROR: sshd configuration validation failed.
  echo Check %ProgramData%\ssh\sshd_config and the messages above.
  goto :failed
)

echo [3/6] Enabling and starting sshd...
sc.exe config sshd start= auto >nul
if errorlevel 1 goto :failed
sc.exe start sshd >nul 2>&1
for /f "tokens=3" %%S in ('sc.exe query sshd ^| findstr /R /C:"STATE"') do set "SSHD_STATE=%%S"
if not "%SSHD_STATE%"=="4" (
  echo ERROR: sshd service is not running.
  sc.exe query sshd
  goto :failed
)

echo [4/6] Configuring Windows Firewall...
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
  "$name = 'RecorderLnx-OpenSSH-Server-In-TCP'; $rule = Get-NetFirewallRule -Name $name -ErrorAction SilentlyContinue; if ($null -eq $rule) { $null = New-NetFirewallRule -Name $name -DisplayName 'RecorderLnx OpenSSH Server (TCP 22, Local Subnet)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -Profile Any -RemoteAddress LocalSubnet } else { $null = Set-NetFirewallRule -Name $name -Enabled True -Direction Inbound -Action Allow -Profile Any; $null = Set-NetFirewallAddressFilter -AssociatedNetFirewallRule (Get-NetFirewallRule -Name $name) -RemoteAddress LocalSubnet }; Write-Host 'Firewall rule enabled for the local subnet.'"
if errorlevel 1 goto :failed

echo [5/6] Testing local TCP/22...
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
  "$ok = Test-NetConnection -ComputerName 127.0.0.1 -Port 22 -InformationLevel Quiet -WarningAction SilentlyContinue; if (-not $ok) { throw 'Local TCP/22 test failed.' }; Write-Host 'Local TCP/22 test passed.'"
if errorlevel 1 goto :failed

echo [6/6] Showing connection information...
echo.
echo SUCCESS: Microsoft OpenSSH Server is installed and running.
echo Service: sshd ^(Automatic^)
echo Port: 22/TCP ^(local subnet only^)
echo Connect from another PC: ssh WINDOWS_USER@%COMPUTERNAME%
echo Use the existing Windows account password when prompted.
echo Passwords are not stored or changed by this script.
exit /b 0

:failed
echo.
echo FAILED: OpenSSH Server setup was not completed.
echo Inspect the error above and Windows Event Viewer:
echo Applications and Services Logs ^> OpenSSH ^> Operational
exit /b 1
