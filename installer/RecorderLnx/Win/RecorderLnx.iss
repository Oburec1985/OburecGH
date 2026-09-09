#define AppName "RecorderLnx"
#define AppVersion "0.1.0"
#define AppPublisher "Mera"
#define SourceRoot "..\..\..\Lazarus\RecorderLnx"
#define AppExe SourceRoot + "\lib\x86_64-win64\RecorderLnx.exe"

[Setup]
AppId={{4A88E3C4-8B9E-4B0C-81F7-72D86F1C6143}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={commonpf32}\Mera\RecorderLnx
; Тестовый /DIR не должен становиться штатным путём следующей установки.
UsePreviousAppDir=no
DefaultGroupName=Mera\RecorderLnx
DisableProgramGroupPage=yes
OutputDir=Output
OutputBaseFilename=RecorderLnx-Setup-{#AppVersion}-20260729
Compression=lzma2/max
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
WizardStyle=modern
UninstallDisplayIcon={app}\RecorderLnx.exe
SetupIconFile={#SourceRoot}\resources\app\RecorderLnx.ico
SetupLogging=yes

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Dirs]
Name: "{app}\plugins"
Name: "{app}\bios"
Name: "{app}\bios\devices"
Name: "{app}\bios\devices\mc201"
Name: "{app}\syscom"
Name: "{code:GetMeraFilesDir}"
Name: "{code:GetMeraFilesDir}\RecorderLnx"
Name: "{code:GetMeraFilesDir}\RecorderLnx\config"
Name: "{code:GetMeraFilesDir}\RecorderLnx\config\projects"
Name: "{code:GetMeraFilesDir}\RecorderLnx\config\projects\default"
Name: "{code:GetMeraFilesDir}\Calibr"
Name: "{code:GetMeraFilesDir}\Resources"
Name: "{code:GetMeraFilesDir}\SDB"

[Files]
Source: "{#AppExe}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceRoot}\lib\x86_64-win64\res\*"; DestDir: "{app}\res"; \
  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#SourceRoot}\Device\MCbus\resources\devices\mc201\mc_201a.bio"; \
  DestDir: "{app}\bios\devices\mc201"; Flags: ignoreversion
Source: "{#SourceRoot}\config\app.ini"; \
  DestDir: "{code:GetMeraFilesDir}\RecorderLnx\config"; \
  Flags: onlyifdoesntexist uninsneveruninstall

[INI]
Filename: "{app}\RecorderLnx.paths.ini"; Section: "Paths"; \
  Key: "MeraFiles"; String: "{code:GetMeraFilesDir}"
Filename: "{app}\RecorderLnx.paths.ini"; Section: "Paths"; \
  Key: "Config"; String: "{code:GetMeraFilesDir}\RecorderLnx\config"
Filename: "{app}\RecorderLnx.paths.ini"; Section: "Paths"; \
  Key: "Plugins"; String: "plugins"
Filename: "{app}\RecorderLnx.paths.ini"; Section: "Paths"; \
  Key: "Bios"; String: "bios"
Filename: "{app}\RecorderLnx.paths.ini"; Section: "Paths"; \
  Key: "SysCom"; String: "syscom"

[Icons]
Name: "{group}\RecorderLnx"; Filename: "{app}\RecorderLnx.exe"; \
  WorkingDir: "{app}"
Name: "{autodesktop}\RecorderLnx"; Filename: "{app}\RecorderLnx.exe"; \
  WorkingDir: "{app}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Создать ярлык на рабочем столе"; \
  GroupDescription: "Дополнительные значки:"

[Run]
Filename: "{sys}\netsh.exe"; \
  Parameters: "advfirewall firewall delete rule name=""Mera RecorderLnx discovery"""; \
  Flags: runhidden; StatusMsg: "Обновление правила сетевого обнаружения..."
Filename: "{sys}\netsh.exe"; \
  Parameters: "advfirewall firewall add rule name=""Mera RecorderLnx discovery"" dir=in action=allow program=""{app}\RecorderLnx.exe"" protocol=UDP localport=38766 profile=domain,private enable=yes"; \
  Flags: runhidden; StatusMsg: "Разрешение сетевого обнаружения RecorderLnx..."
Filename: "{app}\RecorderLnx.exe"; Description: "Запустить RecorderLnx"; \
  WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{sys}\netsh.exe"; \
  Parameters: "advfirewall firewall delete rule name=""Mera RecorderLnx discovery"""; \
  Flags: runhidden

[Code]
var
  MeraFilesPage: TInputDirWizardPage;

procedure InitializeWizard;
begin
  MeraFilesPage := CreateInputDirPage(wpSelectDir,
    'Каталог Mera Files',
    'Выберите общий каталог данных Mera.',
    'В нём будут храниться конфигурации RecorderLnx, SDB и калибровки.',
    False, '');
  MeraFilesPage.Add('');
  MeraFilesPage.Values[0] :=
    ExpandConstant('{param:MERAFILES|{sd}\Mera Files}');
end;

function GetMeraFilesDir(Param: string): string;
begin
  Result := RemoveBackslashUnlessRoot(Trim(MeraFilesPage.Values[0]));
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = MeraFilesPage.ID then
  begin
    if Trim(MeraFilesPage.Values[0]) = '' then
    begin
      MsgBox('Укажите каталог Mera Files.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;
