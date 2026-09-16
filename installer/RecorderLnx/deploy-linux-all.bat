@echo off
setlocal EnableExtensions DisableDelayedExpansion

call :Main %*
set "DEPLOY_EXIT=%ERRORLEVEL%"
if not defined RECORDER_DEPLOY_NO_PAUSE pause
exit /b %DEPLOY_EXIT%

:Main

set "SCRIPT_DIR=%~dp0"
set "HOSTS_FILE=%~1"
set "DEFAULT_USER=%~2"
set "ASKPASS_SCRIPT=%TEMP%\recorderlnx-askpass-%RANDOM%-%RANDOM%.exe"
set "ASKPASS_BUILDER=%SCRIPT_DIR%Tools\create-ssh-askpass.ps1"
set "SUMMARY_FILE=%TEMP%\recorderlnx-deploy-%RANDOM%-%RANDOM%.txt"
set "TOTAL=0"
set "SUCCEEDED=0"
set "FAILED=0"
set "COORDINATOR_URL="

if not defined HOSTS_FILE set "HOSTS_FILE=%SCRIPT_DIR%deploy-linux-hosts.local.txt"
if not defined DEFAULT_USER set "DEFAULT_USER=%RECORDER_DEPLOY_USER%"

call :RequireFile "%HOSTS_FILE%" "Linux host list"
if errorlevel 1 exit /b 1
call :ReadHostCount
if errorlevel 1 exit /b 1
call :ReadCoordinatorUrl
if errorlevel 1 exit /b 1
if not "%HOST_COUNT%"=="4" echo WARNING: expected four hosts, deploying the %HOST_COUNT% configured entries.
echo Coordinator: %COORDINATOR_URL%

call :ResolveOpenSshTool "ssh.exe" SSH_EXE
if errorlevel 1 exit /b 1
call :ResolveOpenSshTool "scp.exe" SCP_EXE
if errorlevel 1 exit /b 1
echo SSH: "%SSH_EXE%"
echo SCP: "%SCP_EXE%"
set "SSH_ASKPASS_REQUIRE=force"
set "DISPLAY=recorderlnx-deploy"

call :FindNewestDeb
if errorlevel 1 exit /b 1
if defined RECORDER_DEPLOY_PREPARE_ONLY (
  echo PREPARE ONLY: package found; remote computers were not changed.
  exit /b 0
)

call :CreateAskPass
if errorlevel 1 exit /b 1
set "SSH_ASKPASS=%ASKPASS_SCRIPT%"
>"%SUMMARY_FILE%" echo RecorderLnx deployment summary
for /f "usebackq eol=# tokens=* delims=" %%H in ("%HOSTS_FILE%") do call :DeployHost "%%H"

echo.
echo Deployment finished: %SUCCEEDED% succeeded, %FAILED% failed, %TOTAL% total.
type "%SUMMARY_FILE%"
del /q "%SUMMARY_FILE%" >nul 2>&1
del /q "%ASKPASS_SCRIPT%" >nul 2>&1

if "%TOTAL%"=="0" (
  echo ERROR: the host list contains no active entries.
  exit /b 1
)
if not "%FAILED%"=="0" exit /b 1
exit /b 0

:CreateAskPass
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%ASKPASS_BUILDER%" -OutputPath "%ASKPASS_SCRIPT%"
if errorlevel 1 (
  echo ERROR: could not build the temporary SSH password helper.
  exit /b 1
)
if exist "%ASKPASS_SCRIPT%" exit /b 0
echo ERROR: could not create the temporary SSH password helper.
exit /b 1

:RequireFile
if exist "%~1" exit /b 0
echo ERROR: %~2 was not found: "%~1"
exit /b 1

:ReadHostCount
set "HOST_COUNT=0"
for /f "usebackq eol=# tokens=* delims=" %%H in ("%HOSTS_FILE%") do call :CountHost "%%H"
if not "%HOST_COUNT%"=="0" exit /b 0
echo ERROR: no active hosts were found in "%HOSTS_FILE%".
exit /b 1

:CountHost
if not "%~1"=="" set /a HOST_COUNT+=1
exit /b 0

:ReadCoordinatorUrl
for /f "usebackq tokens=1,* delims==" %%A in (`findstr /b /c:"# coordinator=" "%HOSTS_FILE%"`) do set "COORDINATOR_URL=%%B"
if defined COORDINATOR_URL exit /b 0
echo ERROR: add this setting to "%HOSTS_FILE%":
echo # coordinator=http://192.168.9.66:8765
exit /b 1

:FindNewestDeb
set "DEB_FILE="
for /f "usebackq delims=" %%F in (`powershell.exe -NoLogo -NoProfile -Command "$f = Get-ChildItem -LiteralPath '%SCRIPT_DIR%linux\Output' -Filter 'recorderlnx_*_amd64.deb' -File | Where-Object Name -NotLike '*.previous.deb' | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1; if ($f) { $f.FullName }"`) do set "DEB_FILE=%%F"
if not defined DEB_FILE (
  echo ERROR: build completed without a recorderlnx_*_amd64.deb file.
  exit /b 1
)
if not exist "%DEB_FILE%" (
  echo ERROR: selected DEB does not exist: "%DEB_FILE%"
  exit /b 1
)
echo Package: "%DEB_FILE%"
exit /b 0

:DeployHost
set "HOST_ENTRY=%~1"
if not defined HOST_ENTRY exit /b 0
set /a TOTAL+=1

call :ResolveInventoryEntry "%HOST_ENTRY%"
if errorlevel 1 (
  call :RecordFailure "inventory entry %TOTAL%" "invalid target or password"
  exit /b 0
)

set "REMOTE_DEB=/tmp/recorderlnx-deploy-%RANDOM%-%RANDOM%.deb"
echo.
echo [%TOTAL%] Updating %SSH_TARGET%...

"%SCP_EXE%" -q -o BatchMode=no -o NumberOfPasswordPrompts=1 -o ConnectTimeout=10 -o ServerAliveInterval=5 -o ServerAliveCountMax=3 "%DEB_FILE%" "%SSH_TARGET%:%REMOTE_DEB%"
if errorlevel 1 (
  call :RecordFailure "%SSH_TARGET%" "copy failed"
  set "RECORDER_DEPLOY_PASSWORD="
  exit /b 0
)

powershell.exe -NoLogo -NoProfile -Command "[Console]::Out.WriteLine($env:RECORDER_DEPLOY_PASSWORD)" | "%SSH_EXE%" -T -o BatchMode=no -o NumberOfPasswordPrompts=1 -o ConnectTimeout=10 -o ServerAliveInterval=5 -o ServerAliveCountMax=3 "%SSH_TARGET%" "sudo -S -p '' sh -c 'if ! dpkg -i %REMOTE_DEB%; then apt-get -f install -y && dpkg -i %REMOTE_DEB%; fi; dpkg -s recorderlnx | grep -q ^Status:.*installed$ || exit 1; config=/var/opt/mera/RecorderLnx/config/coordinator-client.ini; if grep -q ^BaseUrl= \"$config\"; then sed -i \"s#^BaseUrl=.*#BaseUrl=%COORDINATOR_URL%#\" \"$config\"; else printf \"\\n[Coordinator]\\nBaseUrl=%COORDINATOR_URL%\\n\" >>\"$config\"; fi' && dpkg-query -W -f='package=${Package} version=${Version} status=${db:Status-Status}\n' recorderlnx && test -x /opt/mera/RecorderLnx/RecorderLnx && test -x /opt/mera/RecorderLnx/RecorderHostAgent && test -x /opt/mera/RecorderLnx/LinuxSetupManager && test -x /opt/mera/RecorderLnx/LinuxSetupManagerCli && test -x /usr/bin/recorderlnx-linux-setup && test -x /usr/local/sbin/recorderlnx-connect-share && test -x /usr/local/sbin/recorderlnx-share-folder && test -x /usr/local/sbin/recorderlnx-set-hostname && test -x /usr/local/sbin/recorderlnx-configure-wol && test -f /etc/xdg/autostart/recorder-host-agent.desktop && grep -F 'BaseUrl=%COORDINATOR_URL%' /var/opt/mera/RecorderLnx/config/coordinator-client.ini"
set "INSTALL_RESULT=%ERRORLEVEL%"

"%SSH_EXE%" -o ConnectTimeout=10 "%SSH_TARGET%" "rm -f %REMOTE_DEB%" >nul 2>&1
set "RECORDER_DEPLOY_PASSWORD="

if not "%INSTALL_RESULT%"=="0" (
  call :RecordFailure "%SSH_TARGET%" "install or verification failed"
  exit /b 0
)

set /a SUCCEEDED+=1
>>"%SUMMARY_FILE%" echo OK     %SSH_TARGET%
echo OK: %SSH_TARGET%
exit /b 0

:ResolveInventoryEntry
set "SSH_TARGET="
set "RECORDER_DEPLOY_PASSWORD="
for /f "tokens=1,* delims=|" %%A in ("%~1") do (
  set "SSH_TARGET=%%A"
  set "RECORDER_DEPLOY_PASSWORD=%%B"
)
if not defined SSH_TARGET exit /b 1
if not defined RECORDER_DEPLOY_PASSWORD exit /b 1
echo(%SSH_TARGET%| findstr /c:"@" >nul
if errorlevel 1 (
  if not defined DEFAULT_USER exit /b 1
  set "SSH_TARGET=%DEFAULT_USER%@%SSH_TARGET%"
)
exit /b 0

:RecordFailure
set /a FAILED+=1
>>"%SUMMARY_FILE%" echo FAILED %~1 - %~2
echo FAILED: %~1 - %~2
exit /b 0

:ResolveOpenSshTool
set "%~2="
if defined PROCESSOR_ARCHITEW6432 if exist "%SystemRoot%\Sysnative\OpenSSH\%~1" set "%~2=%SystemRoot%\Sysnative\OpenSSH\%~1"
if not defined %~2 if exist "%SystemRoot%\System32\OpenSSH\%~1" set "%~2=%SystemRoot%\System32\OpenSSH\%~1"
if not defined %~2 for /f "delims=" %%T in ('where %~1 2^>nul') do if not defined %~2 set "%~2=%%T"
if defined %~2 exit /b 0
echo ERROR: %~1 was not found in Windows OpenSSH or PATH.
exit /b 1
