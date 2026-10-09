@echo off
setlocal EnableExtensions
chcp 65001 >nul

rem Reusable RecorderLnx deployment to the MIC-315 Windows host.
rem WARNING: the SSH password is intentionally stored in this file.

if "%RECORDER_DEPLOY_ASKPASS%"=="1" (
  echo 123
  exit /b 0
)

if /I "%~1"=="--remote-install" goto :remote_install

set "TARGET_HOST=192.168.15.84"
set "TARGET_USER=user"
set "SETUP_DIR=%~dp0installer\RecorderLnx\Win\Output"
set "REMOTE_SHARE=\\%TARGET_HOST%\Mera Files\screens"
set "REMOTE_LOCAL_DIR=C:\Mera Files\screens"
set "STAGED_NAME=RecorderLnx-latest.exe"
set "DEPLOY_LOG=RecorderLnx-deploy-latest.log"

where ssh.exe >nul 2>&1
if errorlevel 1 (
  echo ERROR: Windows OpenSSH client ssh.exe was not found.
  exit /b 2
)

set "INSTALLER="
for /f "delims=" %%F in ('dir /b /a-d /o-d "%SETUP_DIR%\RecorderLnx-Setup-*.exe" 2^>nul') do if not defined INSTALLER set "INSTALLER=%SETUP_DIR%\%%F"
if not defined INSTALLER (
  echo ERROR: No RecorderLnx installer found in %SETUP_DIR%.
  exit /b 2
)

echo Latest installer: %INSTALLER%
echo [1/4] Copying installer to %TARGET_HOST%...
copy /Y "%INSTALLER%" "%REMOTE_SHARE%\%STAGED_NAME%" >nul
if errorlevel 1 (
  echo ERROR: Could not copy installer to %REMOTE_SHARE%.
  exit /b 3
)

echo [2/4] Verifying staged SHA-256...
for /f "delims=" %%H in ('powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$s=[IO.File]::OpenRead('%INSTALLER%'); try { ([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($s))).Replace('-','') } finally { $s.Dispose() }"') do set "LOCAL_HASH=%%H"
for /f "delims=" %%H in ('powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$s=[IO.File]::OpenRead('%REMOTE_SHARE%\%STAGED_NAME%'); try { ([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($s))).Replace('-','') } finally { $s.Dispose() }"') do set "REMOTE_HASH=%%H"
if not defined LOCAL_HASH (
  echo ERROR: Could not calculate local installer SHA-256.
  exit /b 3
)
if /I not "%LOCAL_HASH%"=="%REMOTE_HASH%" (
  echo ERROR: Staged installer hash mismatch.
  echo Local:  %LOCAL_HASH%
  echo Remote: %REMOTE_HASH%
  exit /b 3
)
echo SHA-256: %LOCAL_HASH%

set "RECORDER_DEPLOY_ASKPASS=1"
set "SSH_ASKPASS=%~f0"
set "SSH_ASKPASS_REQUIRE=force"
set "DISPLAY=RecorderLnxDeploy"

echo [3/4] Staging this deployment BAT...
copy /Y "%~f0" "%REMOTE_SHARE%\deploy-recorderlnx-to-mic315.bat" >nul
if errorlevel 1 (
  echo ERROR: Could not copy the deployment BAT to the shared folder.
  exit /b 4
)
ssh.exe -o ConnectTimeout=10 %TARGET_USER%@%TARGET_HOST% powershell.exe -NoLogo -NoProfile -NonInteractive -EncodedCommand QwBvAHAAeQAtAEkAdABlAG0AIAAtAEwAaQB0AGUAcgBhAGwAUABhAHQAaAAgACcAQwA6AFwATQBlAHIAYQAgAEYAaQBsAGUAcwBcAHMAYwByAGUAZQBuAHMAXABkAGUAcABsAG8AeQAtAHIAZQBjAG8AcgBkAGUAcgBsAG4AeAAtAHQAbwAtAG0AaQBjADMAMQA1AC4AYgBhAHQAJwAgAC0ARABlAHMAdABpAG4AYQB0AGkAbwBuACAAKABKAG8AaQBuAC0AUABhAHQAaAAgACQAZQBuAHYAOgBVAFMARQBSAFAAUgBPAEYASQBMAEUAIAAnAGQAZQBwAGwAbwB5AC0AcgBlAGMAbwByAGQAZQByAGwAbgB4AC0AdABvAC0AbQBpAGMAMwAxADUALgBiAGEAdAAnACkAIAAtAEYAbwByAGMAZQA=
if errorlevel 1 (
  echo ERROR: Could not stage the deployment BAT in the remote user profile.
  exit /b 4
)

echo [4/4] Installing through SSH...
ssh.exe -o ConnectTimeout=10 %TARGET_USER%@%TARGET_HOST% deploy-recorderlnx-to-mic315.bat --remote-install
set "DEPLOY_EXIT=%ERRORLEVEL%"
if not "%DEPLOY_EXIT%"=="0" (
  echo ERROR: Remote deployment failed with code %DEPLOY_EXIT%.
  exit /b %DEPLOY_EXIT%
)

echo SUCCESS: RecorderLnx deployment completed on %TARGET_HOST%.
exit /b 0

:remote_install
set "REMOTE_INSTALLER=C:\Mera Files\screens\RecorderLnx-latest.exe"
set "REMOTE_LOG=C:\Mera Files\screens\RecorderLnx-deploy-latest.log"
set "APP_DIR=C:\Program Files (x86)\Mera\RecorderLnx"

fltmc >nul 2>&1
if errorlevel 1 (
  echo ERROR: SSH session does not have an elevated administrator token.
  exit /b 5
)
if not exist "%REMOTE_INSTALLER%" (
  echo ERROR: Staged installer not found: %REMOTE_INSTALLER%
  exit /b 2
)

"%REMOTE_INSTALLER%" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /MERAFILES="C:\Mera Files" /LOG="%REMOTE_LOG%"
set "INSTALL_EXIT=%ERRORLEVEL%"
if not "%INSTALL_EXIT%"=="0" (
  echo ERROR: Inno Setup failed with code %INSTALL_EXIT%.
  exit /b %INSTALL_EXIT%
)

for %%F in ("%APP_DIR%\RecorderLnx.exe" "%APP_DIR%\mx248\vendor\PxiMx248Bridge.exe" "%APP_DIR%\mx248\vendor\DevAPI.dll") do if not exist "%%~fF" (
  echo ERROR: Required installed file is missing: %%~fF
  exit /b 6
)

for /f "tokens=2,*" %%A in ('reg.exe query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{4A88E3C4-8B9E-4B0C-81F7-72D86F1C6143}_is1" /v DisplayVersion 2^>nul ^| findstr /I /C:"DisplayVersion"') do echo Installed RecorderLnx version: %%B
tasklist /FI "IMAGENAME eq RecorderHostAgent.exe" | findstr /I /C:"RecorderHostAgent.exe" >nul
if errorlevel 1 (
  echo ERROR: RecorderHostAgent.exe is not running after installation.
  exit /b 6
)
echo Remote installation and MX-248 payload verification passed.
exit /b 0
