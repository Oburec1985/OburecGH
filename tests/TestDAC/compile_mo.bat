@echo off
chcp 1251 >nul
echo ---------------------------------------------------
echo Компиляция перевода (.po) в используемый бинарник (.mo)
echo ---------------------------------------------------

:: Укажите здесь путь к НОВОЙ версии msgfmt.exe если старая виснет.
:: Старая: "C:\Program Files (x86)\dxgettext\msgfmt.exe"
:: Идеально использовать скачанную из репозитория mlocati:
set MSGFMT="c:\Oburec\OburecGH\sharedUtils\utils\locTools\msgfmt.exe"

set PO_FILE=locale\en\LC_MESSAGES\default.po
set MO_FILE=locale\en\LC_MESSAGES\default.mo

if not exist "%PO_FILE%" (
    echo ОШИБКА: Файл %PO_FILE% не найден!
    pause
    exit /b
)

echo Компилируем %PO_FILE% в %MO_FILE% ...
%MSGFMT% -o "%MO_FILE%" "%PO_FILE%"

echo.
echo Компиляция завершена!
pause
