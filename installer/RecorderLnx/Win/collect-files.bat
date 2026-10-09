@echo off
setlocal EnableExtensions

rem Builds the complete, structured Inno Setup payload under .\files.
rem Usage: collect-files.bat "<MX-248 vendor directory>" "<VC_redist.x86.exe>"

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..\..\..") do set "REPO_ROOT=%%~fI"
set "FILES_DIR=%SCRIPT_DIR%files"
set "RECORDER_DIR=%REPO_ROOT%\Lazarus\RecorderLnx"
set "VENDOR_DIR=%~1"
set "VC_REDIST=%~2"

if not defined VENDOR_DIR (
  echo ERROR: MX-248 vendor directory was not specified.
  exit /b 2
)
if not defined VC_REDIST (
  echo ERROR: VC_redist.x86.exe was not specified.
  exit /b 2
)
if not exist "%VENDOR_DIR%\DevAPI.dll" (
  echo ERROR: MX-248 vendor files not found in "%VENDOR_DIR%".
  exit /b 3
)
if not exist "%VC_REDIST%" (
  echo ERROR: VC++ x86 redistributable not found: "%VC_REDIST%".
  exit /b 3
)

if exist "%FILES_DIR%" rmdir /s /q "%FILES_DIR%"
if exist "%FILES_DIR%" (
  echo ERROR: Could not clean "%FILES_DIR%".
  exit /b 4
)

call :CopyFile "%RECORDER_DIR%\lib\x86_64-win64\RecorderLnx.exe" "%FILES_DIR%\app\RecorderLnx.exe" || exit /b 10
call :CopyFile "%RECORDER_DIR%\lib\x86_64-win64\RecorderHostAgent.exe" "%FILES_DIR%\app\RecorderHostAgent.exe" || exit /b 10
call :CopyFile "%RECORDER_DIR%\lib\x86_64-win64\lua54.dll" "%FILES_DIR%\app\lua54.dll" || exit /b 10
call :CopyFile "%RECORDER_DIR%\lib\x86_64-win64\help\RecorderLnxLua.chm" "%FILES_DIR%\app\help\RecorderLnxLua.chm" || exit /b 10
call :CopyFile "%RECORDER_DIR%\lib\x86_64-win64\plugins\LuaCalcPlugin.dll" "%FILES_DIR%\app\plugins\LuaCalcPlugin.dll" || exit /b 10
call :CopyFile "%RECORDER_DIR%\lib\x86_64-win64\plugins\SampleInfoPlugin.dll" "%FILES_DIR%\app\plugins\SampleInfoPlugin.dll" || exit /b 10
call :CopyTree "%RECORDER_DIR%\lib\x86_64-win64\res" "%FILES_DIR%\app\res" || exit /b 11
call :CopyFile "%RECORDER_DIR%\Device\MCbus\resources\devices\mc201\mc_201a.bio" "%FILES_DIR%\app\bios\devices\mc201\mc_201a.bio" || exit /b 10

call :CopyFile "%RECORDER_DIR%\Device\PXI\MX248\Bridge\PxiMx248Bridge.exe" "%FILES_DIR%\app\mx248\vendor\PxiMx248Bridge.exe" || exit /b 10
for %%F in (DevAPI.dll mdpC6424.dll MDProtocol.dll mx224v14.dll FTD2XX.dll mfc90.dll msvcp90.dll msvcr90.dll wd_utils.dll) do (
  call :CopyFile "%VENDOR_DIR%\%%F" "%FILES_DIR%\app\mx248\vendor\%%F" || exit /b 10
)

call :CopyFile "%RECORDER_DIR%\config\app.ini" "%FILES_DIR%\mera-files\RecorderLnx\app.ini" || exit /b 10
call :CopyTree "%RECORDER_DIR%\config\projects\default" "%FILES_DIR%\mera-files\RecorderLnx\config\projects\default" || exit /b 11
call :CopyFile "%VC_REDIST%" "%FILES_DIR%\redist\VC_redist.x86.exe" || exit /b 10
call :CopyFile "%RECORDER_DIR%\resources\app\RecorderLnx.ico" "%FILES_DIR%\setup\RecorderLnx.ico" || exit /b 10

echo RecorderLnx installer payload collected in "%FILES_DIR%".
exit /b 0

:CopyFile
if not exist "%~1" (
  echo ERROR: Required file not found: "%~1".
  exit /b 1
)
for %%I in ("%~2") do if not exist "%%~dpI" mkdir "%%~dpI"
copy /y "%~1" "%~2" >nul
if errorlevel 1 (
  echo ERROR: Could not copy "%~1" to "%~2".
  exit /b 1
)
exit /b 0

:CopyTree
if not exist "%~1\" (
  echo ERROR: Required directory not found: "%~1".
  exit /b 1
)
if not exist "%~2\" mkdir "%~2"
xcopy "%~1\*" "%~2\" /E /I /Y /Q >nul
if errorlevel 1 (
  echo ERROR: Could not copy tree "%~1" to "%~2".
  exit /b 1
)
exit /b 0
