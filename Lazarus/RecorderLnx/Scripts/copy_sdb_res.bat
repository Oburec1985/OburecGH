#!/bin/sh
:; # Unix/Linux section:
:; OUT="$1"
:; if [ -z "$OUT" ]; then exit 1; fi
:; mkdir -p "${OUT}res/sdb"
:; cp -f "$(dirname "$0")/../SDB/res/"*.ico "${OUT}res/sdb/" 2>/dev/null || true
:; mkdir -p "${OUT}resources/devices/mc201"
:; cp -f "$(dirname "$0")/../Device/MCbus/resources/devices/mc201/mc_201a.bio" "${OUT}resources/devices/mc201/"
:; exit 0

@echo off
rem Windows section:
set "OUT=%~1"
if "%OUT%"=="" exit /b 1
if not exist "%OUT%res\sdb" mkdir "%OUT%res\sdb"
copy /Y "%~dp0..\SDB\res\*.ico" "%OUT%res\sdb\" >nul
if not exist "%OUT%resources\devices\mc201" mkdir "%OUT%resources\devices\mc201"
copy /Y "%~dp0..\Device\MCbus\resources\devices\mc201\mc_201a.bio" "%OUT%resources\devices\mc201\" >nul
