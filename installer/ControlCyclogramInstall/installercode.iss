
[Setup]
AppName=plgControlCyclogram
AppVerName=plgControlCyclogram
; ������ �� ������������� ���������� ������
AppMutex=plgControlCyclogramMutex
DefaultDirName={pf}\Mera\Recorder\plugins
DefaultGroupName=Mera
UninstallDisplayIcon={app}\plgControlCyclogram.dll


;OutputDir=output
OutputDir=\\Fserv\e\MERA\WORKS\���\��\Skripnik\soft\recorder\ControlCyclogram\
OutputBaseFilename=plgControlCyclogram-installer

[Types]
Name: "full"; Description: "������ ���������"
Name: "Plugin"; Description: "������ ������"

[Components]
Name: "plgDll"; Description: "������ ���������� ����������"; Types: Plugin; Flags: fixed
Name: "Full"; Description: "������ ��������� (����� � ���)"; Types: full; Flags: fixed

[Files]
Source: "source\plgControlCyclogram.dll"; DestDir: "{app}"; Components: plgDll Full
Source: "source\DelZip179.dll"; DestDir: "{app}"; Components: Full
Source: "source\FastMM_FullDebugMode.dll"; DestDir: "{app}"; Components: Full
Source: "source\FastMM_FullDebugMode64.dll"; DestDir: "{app}"; Components: Full
Source: "source\plgRemoteControl.dll"; DestDir: "{app}"; Components: Full
Source: "source\rcServer.dll"; DestDir: "{app}"; Components: Full
Source: "source\plgEmul.dll"; DestDir: "{app}"; Components: Full
Source: "source\files\plgControlCuclogram.docx"; DestDir: "{app}"; Components: Full

