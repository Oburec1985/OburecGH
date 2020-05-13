[Setup]
AppName=SubdiveFilePlg

AppVersion=1.000
AppVerName=1.000
; защита от переустановки запущенной версии
AppMutex=SubdiveFilePlg

DefaultDirName={pf}\MERA\WinPOS\Plugins\SubdiveFilePlg\

OutputDir=output
;OutputDir=\\Fserv\e\MERA\PRODUCTS\WinPos\Utils\CorrectUTS_WpExtPack\versions\

[Types]
Name: "full"; Description: "Полная установка"

[Components]
Name: "program"; Description: "Расширенные функции WinПОС"; Types: full; Flags: fixed

[Files]
Source: "source\SubdivFilePlg.dll"; DestDir: "{app}\WPExtPack\"; Components: program; Flags:ignoreversion regserver;
Source: "source\WpServicePlg.dll"; DestDir: "{app}\WPExtPack\"; Components: program; Flags:ignoreversion regserver;
Source: "source\SniffDll.dll"; DestDir: "{app}\WPExtPack\"; Components: program;
Source: "source\FastMM_FullDebugMode.dll"; DestDir: "{app}\WPExtPack\"; Components: program;

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

[Run]
Filename: "regsvr32.exe";   Parameters: " /s /u ""{app}\WPExtPack\SubdivFilePlg.dll"" "
Filename: "regsvr32.exe";   Parameters: " /s ""{app}\WPExtPack\SubdivFilePlg.dll"" "
Filename: "regsvr32.exe";   Parameters: " /s /u ""{app}\WPExtPack\WpServicePlg.dll"" "
Filename: "regsvr32.exe";   Parameters: " /s ""{app}\WPExtPack\WpServicePlg.dll"" "
