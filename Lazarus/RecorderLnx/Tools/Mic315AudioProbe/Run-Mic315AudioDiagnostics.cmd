@echo off
setlocal
cd /d "%~dp0"
set "MIC315_POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe" set "MIC315_POWERSHELL=%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe"
"%MIC315_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Read-Mic315AudioDiagnostics.ps1"
echo.
echo Diagnostics complete. Logs remain in this folder.
pause
