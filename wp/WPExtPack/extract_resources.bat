@echo off
set REPO_ROOT=..\..
set LOC_TOOLS=%REPO_ROOT%\sharedUtils\utils\locTools
set MSGFMT=%LOC_TOOLS%\msgfmt.exe
set MSGCAT=%LOC_TOOLS%\msgcat.exe
set DXGETTEXT="C:\Program Files (x86)\dxgettext\dxgettext.exe"
if not exist "%DXGETTEXT%" (
    echo Error: dxgettext.exe not found at %DXGETTEXT%
    pause
    exit /b
)
echo Extracting resources...
%DXGETTEXT% --delphi -b . -o locale\en\LC_MESSAGES\ --nonascii
echo Done.
pause