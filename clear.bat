@echo **************************************************************************
@echo * �������� �६����� 䠩��� �஥�� C++ Builder, � ४��ᨥ� ��⠫����.  *
@echo **************************************************************************

@rem �஢�ઠ �� ���� �� ⥪�騩 ��⠫�� ��⥬�� ��⠫����
@if exist system\nul if exist system32\nul goto windows

@rem �����⮢��� १������騩 䠩� ��� ⮣�, �⮡� � ���� ����� �뫮 �����뢠��
@if  exist clear_report.txt @attrib -h clear_report.txt

@rem ����塞 �६���� 䠩�� � ��࠭塞 �� ����� � १������饬
@del /s *.tds *.$$$ *.~bpr *.exe *.~bpk *.~dfm *.~h *.~cpp *.obj *.map *.~bpf *.~bpg *.~ddp *.~pas *.~dpk *.dcu >clear_report.txt

@rem �⮡� १������騩 �� �뤥���� ��뢠�� ���
@attrib +h clear_report.txt

@goto end

:windows
@echo Current directory is probably the Windows System directory!
@pause
:end
