@echo off
:: Устанавливаем кодировку UTF-8
chcp 65001 >nul

:: Цвет: 1 - темно-синий фон, F - ярко-белый текст
color 1F

:: Установка размера окна
mode con: cols=100 lines=30

:: Данные прокси (взяты из вашего конфига)
set "PROXY_URL=http://SkripnikAA:Aa%%2111111@prox.mera.local:3128"

:: API Ключ Gemini (замените на ваш актуальный ключ)
set "GEMINI_API_KEY=ВАШ_API_KEY_ЗДЕСЬ"

:: Запуск PowerShell
powershell -NoExit -ExecutionPolicy Bypass -Command ^
    "$host.UI.RawUI.WindowTitle = 'Gemini AI - Work Session';" ^
    "$env:HTTP_PROXY='%PROXY_URL%';" ^
    "$env:HTTPS_PROXY='%PROXY_URL%';" ^
    "$env:GOOGLE_API_KEY='%GEMINI_API_KEY%';" ^
    "$env:NODE_TLS_REJECT_UNAUTHORIZED='0';" ^
    "Write-Host '------------------------------------------' -ForegroundColor Gray;" ^
    "Write-Host '  GEMINI CLI: ПОДКЛЮЧЕНО (ПРОКСИ 3128)' -ForegroundColor Cyan;" ^
    "Write-Host '  API KEY: УСТАНОВЛЕН' -ForegroundColor Green;" ^
    "Write-Host '------------------------------------------' -ForegroundColor Gray;" ^
    "gemini"