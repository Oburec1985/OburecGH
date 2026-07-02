#!/bin/sh
:; # Unix/Linux section:
:; OUT="$1"
:; if [ -z "$OUT" ]; then exit 1; fi
:; mkdir -p "${OUT}res/sdb"
:; cp -f "$(dirname "$0")/../SDB/res/"*.ico "${OUT}res/sdb/" 2>/dev/null || true
:; exit 0

@echo off
rem Windows section:
set "OUT=%~1"
if "%OUT%"=="" exit /b 1
if not exist "%OUT%res\sdb" mkdir "%OUT%res\sdb"
copy /Y "%~dp0..\SDB\res\*.ico" "%OUT%res\sdb\" >nul
