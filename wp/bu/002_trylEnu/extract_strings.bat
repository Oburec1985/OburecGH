@echo off
set DXGETTEXT="c:\Program Files (x86)\dxgettext\dxgettext.exe"

echo Cleaning up old files...
if exist default.po del default.po
if exist WPExtPack.po del WPExtPack.po

echo Extracting strings (recursive scan)...
%DXGETTEXT% --delphi -r .

echo Finalizing...
if exist default.po (
    move /y default.po WPExtPack.po
    echo Done! File WPExtPack.po is ready.
) else (
    echo [ERROR] default.po was not created.
)
pause
