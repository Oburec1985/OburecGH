[Setup]
AppName=Project1

AppVersion=1.000
AppVerName=1.000
; ������ �� ������������� ���������� ������
AppMutex=Project1

DefaultDirName={pf}\MERA\WinPOS\Plugins\

[Types]
Name: "full"; Description: "������ ���������"

[Components]
Name: "program"; Description: "����������� ������� Win���"; Types: full; Flags: fixed

[Files]
Source: "source\Project1.dll"; DestDir: "{app}\SH80\"; Components: program; Flags:ignoreversion regserver;
Source: "source\Project1.rsm"; DestDir: "{app}\SH80\"; Components: program; Flags:ignoreversion regserver;

[Run]
Filename: "regsvr32.exe";   Parameters: " /s /u ""{app}\SH80\Project1.dll"" "
Filename: "regsvr32.exe";   Parameters: " /s ""{app}\SH80\Project1.dll"" "
