@echo off
echo Audio repair retired: the device recovered using the correct RDP profile.
echo No services or settings will be changed.
exit /b 0
setlocal
set "nativePS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe" set "nativePS=%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
"%nativePS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Repair-Mic315AudioEndpoints.ps1" %*
set "repairExit=%errorlevel%"
echo Audio repair exit code: %repairExit%
if not "%repairExit%"=="0" pause
exit /b %repairExit%
