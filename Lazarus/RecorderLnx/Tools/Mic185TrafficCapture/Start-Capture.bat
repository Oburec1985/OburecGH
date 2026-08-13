@echo off
setlocal
cd /d "%~dp0"

set "DEVICE_IP=%~1"
if "%DEVICE_IP%"=="" set "DEVICE_IP=192.168.9.155"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Capture-Mic185.ps1" -DeviceIp "%DEVICE_IP%" -Client auto -RunName full_cycle
exit /b %ERRORLEVEL%
