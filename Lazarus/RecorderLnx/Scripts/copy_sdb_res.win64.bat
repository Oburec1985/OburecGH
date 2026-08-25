@echo off
setlocal
set "OUT=%~1"
if "%OUT%"=="" exit /b 1
if not exist "%OUT%res\sdb" mkdir "%OUT%res\sdb"
copy /Y "%~dp0..\SDB\res\*.ico" "%OUT%res\sdb\" >nul
if errorlevel 1 exit /b 1
if not exist "%OUT%resources\devices\mc201" mkdir "%OUT%resources\devices\mc201"
copy /Y "%~dp0..\Device\MCbus\resources\devices\mc201\mc_201a.bio" "%OUT%resources\devices\mc201\" >nul
if errorlevel 1 exit /b 1
