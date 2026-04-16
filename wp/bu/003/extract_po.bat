@echo off
chcp 1251 >nul
echo ---------------------------------------------------
echo Извлечение текстов из исходников Delphi (.pas, .dfm)
echo ---------------------------------------------------

:: Путь до старой утилиты dxgettext - она нужна только для парсинга Delphi-кода
set DXGETTEXT="C:\Program Files (x86)\dxgettext\dxgettext.exe"

:: Папка, куда будет сохранен default.po
set OUT_DIR=locale\en\LC_MESSAGES

if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

echo Запускаем сканер...
%DXGETTEXT% --delphi -b . -o "%OUT_DIR%"\ --nonascii

echo.
echo Сбор завершен! Файл default.po был создан или обновлен в папке %OUT_DIR%
pause
