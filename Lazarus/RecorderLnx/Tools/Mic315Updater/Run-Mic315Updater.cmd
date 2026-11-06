@echo off
setlocal
cd /d "%~dp0"
for %%A in (%*) do if /i "%%~A"=="--dry-run" goto dryrun
if not exist "%~dp0logs" mkdir "%~dp0logs"
if not exist "%~dp0logs" exit /b 1
echo Starting MIC315 updater. Please confirm UAC if requested.
echo === %date% %time% ===>>"logs\updater-launch.log"
"%~dp0Mic315Updater.exe" --no-pause %* >>"logs\updater-launch.log" 2>&1
set "MIC315_UPDATE_EXIT=%errorlevel%"
echo Exit code: %MIC315_UPDATE_EXIT%>>"logs\updater-launch.log"
type "logs\updater-launch.log"
echo.
echo Send this window or wait while its log is checked.
pause
exit /b %MIC315_UPDATE_EXIT%
:dryrun
"%~dp0Mic315Updater.exe" --no-pause %*
exit /b %errorlevel%
