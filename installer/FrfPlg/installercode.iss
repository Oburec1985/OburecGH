[Setup]
AppName=plgEvalFRF
AppVerName=plgEvalFRF
; ������ �� ������������� ���������� ������
AppMutex=plgEvalFRFMutex
DefaultDirName={pf}\Mera\Recorder\plugins
DefaultGroupName=Mera
UninstallDisplayIcon={app}\plgEvalFRF.dll

OutputDir=output
;OutputDir=\\Fserv\e\MERA\WORKS\���\��\Skripnik\soft\recorder\plgEvalFRF\
OutputBaseFilename=plgEvalFRF_installer_v1.0

[Types]
Name: "full"; Description: "������ ���������"
Name: "Plugin"; Description: "������ ������"

[Components]
Name: "plgDll"; Description: "������ ���������� ����������"; Types: Plugin; Flags: fixed
Name: "Full"; Description: "������ ��������� (����� � ���)"; Types: full; Flags: fixed

[Files]
;Source: "source\plgControlCyclogram.dll"; DestDir: "{app}"; Components: plgDll Full
Source: "c:\Program Files (x86)\Mera\Recorder\plugins\plgEvalFRF.dll"; DestDir: "{app}"; Components: plgDll Full
Source: "source\DelZip179.dll"; DestDir: "{app}"; Components: Full
Source: "source\FastMM_FullDebugMode.dll"; DestDir: "{app}"; Components: Full
Source: "source\FastMM_FullDebugMode64.dll"; DestDir: "{app}"; Components: Full
Source: "source\plgRemoteControl.dll"; DestDir: "{app}"; Components: Full
Source: "source\rcServer.dll"; DestDir: "{app}"; Components: Full
Source: "source\files\shaders\LineLg.vert"; DestDir: "{app}\files\shaders"; Components: Full
Source: "source\files\shaders\LineLg1d.vert"; DestDir: "{app}\files\shaders"; Components: Full
Source: "source\files\Report_tmpl.xlsx"; DestDir: "c:\Mera Files\mdb\Template\Report_tmpl.xlsx"; Components: Full
