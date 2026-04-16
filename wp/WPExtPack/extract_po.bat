@echo off
setlocal enabledelayedexpansion
chcp 1251 >nul

:: --- Настройки путей (относительно корня репозитория) ---
set REPO_ROOT=..\..
set LOC_TOOLS=%REPO_ROOT%\sharedUtils\utils\locTools
set MSGFMT=%LOC_TOOLS%\msgfmt.exe
set MSGCAT=%LOC_TOOLS%\msgcat.exe
set DXGETTEXT="C:\Program Files (x86)\dxgettext\dxgettext.exe"
set EXTRACTOR_PS1=%LOC_TOOLS%\dfm_extract.ps1

:: --- Настройки проекта ---
set OUT_DIR=locale\en\LC_MESSAGES
set PO_FILE=%OUT_DIR%\default.po
set TEMP_DFM_PO=%OUT_DIR%\dfm_strings.po

echo ===================================================
echo [Локализация] Сбор ресурсов проекта
echo ===================================================

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

:: 1. Стандартный сбор (PAS файлы и системные ключи)
echo [1/3] Запуск dxgettext...
if exist %DXGETTEXT% (
    %DXGETTEXT% --delphi -r -o "%OUT_DIR%" -b . --nonascii
) else (
    echo [!] dxgettext не найден в %DXGETTEXT%. Пропускаем базовый сбор.
)

:: 2. Умный сбор из DFM (декодирование #xxxx)
echo [2/3] Запуск dfm_extract.ps1...
if exist "%EXTRACTOR_PS1%" (
    powershell -ExecutionPolicy Bypass -File "%EXTRACTOR_PS1%" -SourcePath "." -OutputFile "%TEMP_DFM_PO%"
) else (
    echo [!] Скрипт %EXTRACTOR_PS1% не найден.
)

:: 3. Консолидация и перевод (объединение PAS и DFM строк + словарь)
echo [3/3] Консолидация и перевод (apply_dictionary.ps1)...
if exist "apply_dictionary.ps1" (
    powershell -ExecutionPolicy Bypass -File "apply_dictionary.ps1"
) else (
    echo [!] Скрипт apply_dictionary.ps1 не найден.
)

echo.
echo Сбор и перевод завершены.
echo Итоговый файл ресурсов: %PO_FILE%
echo Дополнительные строки (сырые): %TEMP_DFM_PO%
pause
