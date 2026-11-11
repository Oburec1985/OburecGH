@echo off
setlocal EnableExtensions DisableDelayedExpansion
title RecorderLnx - build Linux and update KIP/ARM
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-kip-arm.ps1"
set "RESULT=%ERRORLEVEL%"
echo.
if "%RESULT%"=="0" (
  echo RecorderLnx update completed successfully.
) else (
  echo RecorderLnx update failed. See linux\Output\update-kip-arm-latest.log
)
pause
exit /b %RESULT%
