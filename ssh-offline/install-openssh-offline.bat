@echo off
setlocal EnableExtensions
chcp 65001 >nul

rem Offline Microsoft Win32-OpenSSH Server installation for x64 Windows.
rem Keep this BAT beside OpenSSH-Win64-v10.0.0.0.msi.

fltmc >nul 2>&1
if errorlevel 1 (
  echo ERROR: Run this BAT as Administrator.
  pause
  exit /b 5
)

set "MSI=%~dp0OpenSSH-Win64-v10.0.0.0.msi"
set "MSILOG=%~dp0install-openssh-offline-msi.log"
set "RESULTLOG=%~dp0install-openssh-offline-result.log"

call :install >"%RESULTLOG%" 2>&1
set "SETUP_EXIT=%ERRORLEVEL%"
if exist "C:\Mera Files\screens\" copy /Y "%RESULTLOG%" "C:\Mera Files\screens\install-openssh-offline-result.log" >nul
type "%RESULTLOG%"
echo.
echo Result log: %RESULTLOG%
echo MSI log: %MSILOG%
pause
exit /b %SETUP_EXIT%

:install
if not exist "%MSI%" (
  echo ERROR: MSI not found beside BAT: %MSI%
  exit /b 2
)

echo [1/5] Verifying Microsoft OpenSSH MSI...
for /f "tokens=*" %%H in ('powershell.exe -NoLogo -NoProfile -NonInteractive -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath '%MSI%').Hash"') do set "MSIHASH=%%H"
if /I not "%MSIHASH%"=="DDEC9C53864280759CF9F74791CEFD387100E3946AA849A1C138A4ED1B96B7D9" (
  echo ERROR: MSI SHA-256 mismatch: %MSIHASH%
  exit /b 3
)

echo [2/5] Installing OpenSSH Server from local MSI...
msiexec.exe /i "%MSI%" ADDLOCAL=Server /qn /norestart /L*v "%MSILOG%"
set "MSI_EXIT=%ERRORLEVEL%"
if not "%MSI_EXIT%"=="0" if not "%MSI_EXIT%"=="3010" (
  echo ERROR: msiexec failed with code %MSI_EXIT%.
  exit /b %MSI_EXIT%
)

echo [3/5] Enabling and starting sshd...
sc.exe config sshd start= auto
if errorlevel 1 exit /b 4
sc.exe start sshd >nul 2>&1
sc.exe query sshd | findstr /C:"RUNNING" >nul
if errorlevel 1 (
  echo ERROR: sshd service is not running.
  sc.exe query sshd
  exit /b 4
)

echo [4/5] Opening TCP/22 from the local subnet...
netsh advfirewall firewall delete rule name="RecorderLnx OpenSSH Server (TCP 22)" >nul 2>&1
netsh advfirewall firewall add rule name="RecorderLnx OpenSSH Server (TCP 22)" dir=in action=allow protocol=TCP localport=22 remoteip=localsubnet profile=any
if errorlevel 1 exit /b 4

echo [5/5] Testing local TCP/22...
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$ok = Test-NetConnection 127.0.0.1 -Port 22 -InformationLevel Quiet -WarningAction SilentlyContinue; if (-not $ok) { exit 1 }"
if errorlevel 1 (
  echo ERROR: Local TCP/22 test failed.
  exit /b 4
)

echo SUCCESS: offline OpenSSH Server installation completed.
echo Connect with: ssh WINDOWS_USER@%COMPUTERNAME%
if "%MSI_EXIT%"=="3010" echo NOTE: MSI requested a Windows restart.
exit /b 0
