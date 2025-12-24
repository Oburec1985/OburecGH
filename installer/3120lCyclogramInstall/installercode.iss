[Setup]
AppName=plg3120Cyclogram
AppVerName=plg3120Cyclogram
; защита от переустановки запущенной версии
AppMutex=plg3120CyclogramMutex
DefaultDirName={pf}\Mera\Recorder\plugins
DefaultGroupName=Mera
UninstallDisplayIcon={app}\plg3120Cyclogram.dll

;OutputDir=output
OutputDir=\\Fserv\e\CLIENTS\Info\p3120_АО СКБМ_Муравейник_Коршунов\7. ЦР\Циклограмма\src\imstaller\
OutputBaseFilename=plg3120Cyclogram_inst_v1.1

[Types]
Name: "full"; Description: "Полная установка"
Name: "Plugin"; Description: "Только плагин"

[Components]
Name: "plgDll"; Description: "Плагин управления испытанием"; Types: Plugin; Flags: fixed
Name: "Full"; Description: "Полная установка (файлы и длл)"; Types: full; Flags: fixed

[Files]
;Source: "source\plg3120Cyclogram.dll"; DestDir: "{app}"; Components: plgDll Full
Source: "c:\Program Files (x86)\Mera\Recorder\plugins\plg3120Cyclogram.dll"; DestDir: "{app}"; Components: plgDll Full
;Source: "c:\Program Files (x86)\Mera\Recorder\plugins\readme.txt"; DestDir: "{app}"; Components: plgDll Full
Source: "\\Fserv\e\CLIENTS\Info\p3120_АО СКБМ_Муравейник_Коршунов\7. ЦР\Циклограмма\src\readme.txt"; DestDir: "{app}"; Components: plgDll Full
Source: "source\files\tmplt_report.xlsx"; DestDir: "c:\Mera Files\3120Base\template" ; Components: Full
