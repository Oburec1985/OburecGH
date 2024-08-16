[Setup]
AppName=WPOperPlg

AppVersion=1.0
AppVerName=1.0
; защита от переустановки запущенной версии
AppMutex=WPOperPlg

DefaultDirName={pf}\MERA\WinPOS\Plugins\

OutputDir=output
;OutputDir=\\Fserv\e\MERA\PRODUCTS\WinPos\Utils\CorrectUTS_WpExtPack\versions\
OutputBaseFilename=WPOperPlg-installer_1.000

[Types]
Name: "full"; Description: "Полная установка"

[Components]
Name: "program"; Description: "Расширенные функции WinПОС"; Types: full; Flags: fixed

[Files]
Source: "source\WPOperPlg.dll"; DestDir: "{app}\OperPack\"; Components: program; Flags:ignoreversion regserver;

[Run]
Filename: "regsvr32.exe";   Parameters: " /s /u ""{app}\OperPack\WpOperPlg.dll"" "
Filename: "regsvr32.exe";   Parameters: " /s ""{app}\OperPack\WpOperPlg.dll"" "

;C:\Program Files (x86)\MERA\WinPOS\Plugins\OperPack\WPOperPlg.dll WpOperPlg.OperPack run
;C:\Program Files (x86)\MERA\WinPOS\Plugins\OperPack\WPOperPlg.dll WpOperPlg.OperPack resvr32
