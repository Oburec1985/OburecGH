[Setup]
AppName=WPExtPack

AppVersion=1.099
AppVerName=1.099
; защита от переустановки запущенной версии
AppMutex=WPExtPack

DefaultDirName={pf}\MERA\WinPOS\Plugins\

;OutputDir=output
OutputDir=\\Fserv\e\MERA\PRODUCTS\WinPos\Utils\CorrectUTS_WpExtPack\versions\

;OutputBaseFilename=WPExtPack-installer_1.01_tryrzd
OutputBaseFilename=WPExtPack-installer_1.102

[Types]
Name: "full"; Description: "Полная установка"

[Components]
Name: "program"; Description: "Расширенные функции WinПОС"; Types: full; Flags: fixed

[Files]
Source: "source\WPExtPack.dll"; DestDir: "{app}\WPExtPack\"; Components: program; Flags:ignoreversion regserver;
Source: "source\WpServicePlg.dll"; DestDir: "{app}\WPExtPack\"; Components: program; Flags:ignoreversion regserver;
Source: "source\SniffDll.dll"; DestDir: "{app}\WPExtPack\"; Components: program;
Source: "source\ScriptFile.xml"; DestDir: "{app}\WPExtPack\"; Components: program
Source: "source\FastMM_FullDebugMode.dll"; DestDir: "{app}\WPExtPack\"; Components: program;
Source: "source\WPProc.ini"; DestDir: "{app}\WPExtPack\"; Components: program
Source: "source\Services.Ini"; DestDir: "{app}\WPExtPack\"; Components: program
Source: "source\Отчет циклограмма.xls"; DestDir: "{app}\WPExtPack\"; Components: program
Source: "source\Отчет циклограмма.xlsx"; DestDir: "{app}\WPExtPack\"; Components: program
Source: "source\Отчет циклограмма (шаблон).xlsm"; DestDir: "{app}\WPExtPack\"; Components: program
Source: "source\CorrectUTS.ini"; DestDir: "{app}\WPExtPack\"; Components: program
Source: "source\Opers\FindMax.Ini"; DestDir: "{app}\WPExtPack\Opers\"; Components: program
Source: "source\Opers\WrdTmpl.docx"; DestDir: "{app}\WPExtPack\Opers\"; Components: program
Source: "source\Opers\RptOper.ini"; DestDir: "{app}\WPExtPack\Opers\"; Components: program
Source: "source\Opers\rptCfg\RptOper.ini"; DestDir: "{app}\WPExtPack\Opers\rptCfg\"; Components: program
Source: "source\Opers\rptCfg\Сводный отчет Метрология.xlsm"; DestDir: "{app}\WPExtPack\Opers\rptCfg\"; Components: program

; Библиотеки fastreport в system32
Source: "source\fastreport\dclfrx14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfrxADO14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfrxBDE14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfrxcs14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfrxDB14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfrxDBX14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfrxe14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfrxIBX14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfrxTee14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfs14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfsADO14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfsBDE14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfsDB14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfsIBX14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\dclfsTee14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\fqb140.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist

Source: "source\fastreport\frx14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\frxADO14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\frxBDE14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\frxcs14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\frxDB14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\frxDBX14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\frxe14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\frxIBX14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\frxTee14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\fs14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\fsADO14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\fsBDE14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\fsDB14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\fsIBX14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist
Source: "source\fastreport\fsTee14.bpl"; DestDir: "{sys}\"; Components: program; Flags:onlyifdoesntexist



;Source: "source\regplg.exe";  DestDir: "{app}\WPExtPack\"; Components: program
;Source: "source\INSTALL.BAT"; DestDir: "{app}\WPExtPack\"; Components: program
; нужно для работы regplg.exe
;Source: "source\vcl60.bpl";  DestDir: "{app}\WPExtPack\"; Components: program
;Source: "source\vclx60.bpl";  DestDir: "{app}\WPExtPack\"; Components: program
;Source: "source\vcl50.bpl";  DestDir: "{app}\WPExtPack\"; Components: program
;Source: "source\vclx50.bpl";  DestDir: "{app}\WPExtPack\"; Components: program
;Source: "source\cc3250.dll";  DestDir: "{app}\WPExtPack\"; Components: program
;Source: "source\cc3250mt.dll";  DestDir: "{app}\WPExtPack\"; Components: program


[Run]
Filename: "regsvr32.exe";   Parameters: " /s /u ""{app}\WPExtPack\WPExtPack.dll"" "
Filename: "regsvr32.exe";   Parameters: " /s ""{app}\WPExtPack\WPExtPack.dll"" "
Filename: "regsvr32.exe";   Parameters: " /s /u ""{app}\WPExtPack\WpServicePlg.dll"" "
Filename: "regsvr32.exe";   Parameters: " /s ""{app}\WPExtPack\WpServicePlg.dll"" "
