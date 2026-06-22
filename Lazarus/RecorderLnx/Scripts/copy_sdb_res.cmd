@echo off
setlocal
set "OUT=%~1"
if "%OUT%"=="" exit /b 1
if not exist "%OUT%res\sdb" mkdir "%OUT%res\sdb"
copy /Y "%~dp0..\SDB\res\*.ico" "%OUT%res\sdb\" >nul
