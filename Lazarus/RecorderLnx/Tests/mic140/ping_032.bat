@echo off
:: начало, шаг, конец для цикла
::for /L %%i in (1,1,255) do ping 192.168.13.%%i -n 1 -w 30
for /L %%i in (44,1,60) do ping 192.168.14.%%i -n 1 -w 30
pause