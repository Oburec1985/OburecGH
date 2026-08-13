@echo off
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if not "%errorlevel%"=="0" (
  echo Requesting administrator rights...
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

echo MIC-185 capture self-test
set /p DEVICE_IP=Device IP [192.168.9.155]: 
if "%DEVICE_IP%"=="" set "DEVICE_IP=192.168.9.155"
echo.
echo A five-second capture will be made. Recorder is not required.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Capture-Mic185.ps1" -DeviceIp "%DEVICE_IP%" -Client custom -RunName selftest -DurationSec 5 -Probe -NoElevate
set "RESULT=%ERRORLEVEL%"
echo.
if "%RESULT%"=="0" echo SELF-TEST OK. A separate result folder was created in captures.
if not "%RESULT%"=="0" echo SELF-TEST FAILED. Send the newest folder from captures.
pause
exit /b %RESULT%
