@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%build-installer.ps1"

if not exist "%PS_SCRIPT%" (
  echo Build script not found: "%PS_SCRIPT%"
  exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
set "BUILD_RESULT=%ERRORLEVEL%"
if not "%BUILD_RESULT%"=="0" (
  echo.
  echo Linux installer build failed. See the error above.
  pause
)
exit /b %BUILD_RESULT%
