@echo off
:: Устанавливаем кодировку UTF-8
chcp 65001 >nul

:: Цвет: 1 - темно-синий фон, F - ярко-белый текст
color 1F

:: Установка размера окна (ширина 100 символов, высота 30 строк)
mode con: cols=100 lines=30

set "PROXY_URL=http://SkripnikAA:Aa%%2111111@prox.mera.local:3128"

:: Запуск PowerShell с принудительным увеличением масштаба через заголовок (визуальный хак)
powershell -NoExit -ExecutionPolicy Bypass -Command ^
    "$host.UI.RawUI.WindowTitle = 'Qwen Code - Work Session';" ^
    "$env:HTTP_PROXY='%PROXY_URL%';" ^
    "$env:HTTPS_PROXY='%PROXY_URL%';" ^
    "$env:NODE_TLS_REJECT_UNAUTHORIZED='0';" ^
    "$npmPath = npm config get prefix;" ^
    "$env:Path += \";$npmPath\";" ^
    "Write-Host '------------------------------------------' -ForegroundColor Gray;" ^
    "Write-Host '  ПРОКСИ: ПОДКЛЮЧЕНО (ПОРТ 3128)' -ForegroundColor Yellow;" ^
    "Write-Host '------------------------------------------' -ForegroundColor Gray;" ^
    "qwen"