@echo off
setlocal EnableExtensions

pushd "%~dp0"
if errorlevel 1 goto :failed_directory

echo Updating rcPanel payload...
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0prepare-installer.ps1"
if errorlevel 1 goto :failed_prepare

for %%F in (
  "install-firebird-recorderlnx.sh"
  "check-firebird-recorderlnx.sh"
  "Install Firebird for RecorderLnx.desktop"
  "readme.txt"
  "payload\RecorderCoordinator"
  "payload\rcpanel.png"
  "payload\RecorderCoordinator.sha256"
) do (
  if not exist "%%~F" (
    echo ERROR: required file is missing: %%~F
    goto :failed
  )
)

dir /b "Firebird-*-linux-x64.tar.gz" >nul 2>&1
if errorlevel 1 (
  echo ERROR: Firebird Linux archive is missing.
  goto :failed
)

if not exist "deps" mkdir "deps"
dir /b "deps\*.deb" >nul 2>&1
if errorlevel 1 (
  echo INFO: deps contains no optional offline DEB packages.
) else (
  echo INFO: optional offline DEB packages found in deps.
)

echo.
echo READY: copy this entire folder to the USB drive.
popd
if /i not "%~1"=="--no-pause" pause
exit /b 0

:failed_prepare
echo ERROR: failed to refresh rcPanel payload.
goto :failed

:failed_directory
echo ERROR: cannot open the installer directory.
if /i not "%~1"=="--no-pause" pause
exit /b 1

:failed
popd
if /i not "%~1"=="--no-pause" pause
exit /b 1
