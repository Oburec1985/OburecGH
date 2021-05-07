@echo **************************************************************************
@echo * Удаление временных файлов проекта C++ Builder, с рекурсией каталогов.  *
@echo **************************************************************************

@rem Проверка не является ли текущий каталог системным каталогом
@if exist system\nul if exist system32\nul goto windows

@rem Подготовить результирующий файл для того, чтобы в него можно было записывать
@if  exist clear_report.txt @attrib -h clear_report.txt

@rem Удаляем временные файлы и сохраняем их имена в результирующем
@del /s *.tds *.$$$ *.~bpr *.exe *.~bpk *.~dfm *.~h *.~cpp *.obj *.map *.~bpf *.~bpg *.~ddp *.~pas *.~dpk *.dcu >clear_report.txt

@rem Чтобы результирующий не выделялся скрываем его
@attrib +h clear_report.txt

@goto end

:windows
@echo Current directory is probably the Windows System directory!
@pause
:end
