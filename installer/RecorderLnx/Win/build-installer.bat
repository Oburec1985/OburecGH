@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%build-installer.ps1"

if not exist "%PS_SCRIPT%" (
  echo ERROR: build script not found: "%PS_SCRIPT%"
  if not defined RECORDER_BUILD_NO_PAUSE pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
set "BUILD_RESULT=%ERRORLEVEL%"
echo.
if "%BUILD_RESULT%"=="0" (
  echo Windows installer build completed successfully.
) else (
  echo Windows installer build failed. See the error above.
)
if not defined RECORDER_BUILD_NO_PAUSE pause
exit /b %BUILD_RESULT%
