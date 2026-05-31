@echo off
echo Configuring Lazarus layout to CodeGear style...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_layout.ps1"
if %errorlevel% neq 0 (
    echo [ERROR] Layout configuration failed.
) else (
    echo [SUCCESS] Layout configuration completed successfully!
)
pause
