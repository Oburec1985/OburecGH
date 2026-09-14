#define AppName "RecorderLnx"
#ifndef AppVersion
  #define AppVersion "0.1.10"
#endif
#define AppPublisher "Mera"
#define SourceRoot "..\..\..\Lazarus\RecorderLnx"
#define AppExe SourceRoot + "\lib\x86_64-win64\RecorderLnx.exe"
#define HostAgentExe SourceRoot + "\lib\x86_64-win64\RecorderHostAgent.exe"

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
OutputBaseFilename=RecorderLnx-Setup-{#AppVersion}
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
Source: "{#HostAgentExe}"; DestDir: "{app}"; Flags: ignoreversion; \
  AfterInstall: EnsureHostAgentConfig
Source: "{#SourceRoot}\lib\x86_64-win64\res\*"; DestDir: "{app}\res"; \
  Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#SourceRoot}\Device\MCbus\resources\devices\mc201\mc_201a.bio"; \
  DestDir: "{app}\bios\devices\mc201"; Flags: ignoreversion
Source: "{#SourceRoot}\config\app.ini"; \
  DestDir: "{code:GetMeraFilesDir}\RecorderLnx\config"; \
  Flags: onlyifdoesntexist uninsneveruninstall
Source: "{#SourceRoot}\config\projects\default\*"; \
  DestDir: "{code:GetMeraFilesDir}\RecorderLnx\config\projects\default"; \
  Flags: onlyifdoesntexist uninsneveruninstall recursesubdirs createallsubdirs

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

[Registry]
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; \
  ValueType: string; ValueName: "MeraRecorderHostAgent"; \
  ValueData: """{app}\RecorderHostAgent.exe"""; Flags: uninsdeletevalue

[Tasks]
Name: "desktopicon"; Description: "Создать ярлык на рабочем столе"; \
  GroupDescription: "Дополнительные значки:"

[Run]
Filename: "{sys}\netsh.exe"; \
  Parameters: "advfirewall firewall delete rule name=""Mera RecorderHostAgent API"""; \
  Flags: runhidden; StatusMsg: "Обновление правила управления компьютером..."
Filename: "{sys}\netsh.exe"; \
  Parameters: "advfirewall firewall add rule name=""Mera RecorderHostAgent API"" dir=in action=allow program=""{app}\RecorderHostAgent.exe"" protocol=TCP localport=8766 profile=domain,private enable=yes"; \
  Flags: runhidden; StatusMsg: "Разрешение управления компьютером RecorderLnx..."
Filename: "{app}\RecorderHostAgent.exe"; WorkingDir: "{app}"; \
  Flags: runhidden nowait; StatusMsg: "Запуск фонового агента RecorderLnx..."
Filename: "{sys}\netsh.exe"; \
  Parameters: "advfirewall firewall delete rule name=""Mera RecorderLnx discovery"""; \
  Flags: runhidden; StatusMsg: "Обновление правила сетевого обнаружения..."
Filename: "{sys}\netsh.exe"; \
  Parameters: "advfirewall firewall add rule name=""Mera RecorderLnx discovery"" dir=in action=allow program=""{app}\RecorderLnx.exe"" protocol=UDP localport=38766 profile=domain,private enable=yes"; \
  Flags: runhidden; StatusMsg: "Разрешение сетевого обнаружения RecorderLnx..."
Filename: "{app}\RecorderLnx.exe"; Description: "Запустить RecorderLnx"; \
  WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{sys}\taskkill.exe"; Parameters: "/IM RecorderHostAgent.exe /T /F"; \
  Flags: runhidden; RunOnceId: "StopRecorderHostAgent"
Filename: "{sys}\netsh.exe"; \
  Parameters: "advfirewall firewall delete rule name=""Mera RecorderHostAgent API"""; \
  Flags: runhidden; RunOnceId: "DeleteRecorderHostAgentFirewallRule"
Filename: "{sys}\netsh.exe"; \
  Parameters: "advfirewall firewall delete rule name=""Mera RecorderLnx discovery"""; \
  Flags: runhidden; RunOnceId: "DeleteRecorderLnxDiscoveryFirewallRule"

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

procedure StopHostAgent;
var
  ResultCode: Integer;
begin
  { The exact image name prevents an upgrade from terminating RecorderLnx. }
  Exec(ExpandConstant('{sys}\taskkill.exe'),
    '/IM RecorderHostAgent.exe /T /F', '', SW_HIDE,
    ewWaitUntilTerminated, ResultCode);
end;

procedure EnsureHostAgentConfig;
var
  ConfigFile: string;
  ConfigText: string;
begin
  ConfigFile := ExpandConstant('{app}\RecorderHostAgent.ini');
  if FileExists(ConfigFile) then
    Exit;
  ConfigText :=
    '[agent]' + #13#10 +
    'listen=0.0.0.0' + #13#10 +
    'port=8766' + #13#10 +
    'recorder_path=' + ExpandConstant('{app}\RecorderLnx.exe') + #13#10 +
    'allow_shutdown=0' + #13#10 +
    'api_token=' + #13#10;
  if not SaveStringToFile(ConfigFile, ConfigText, False) then
    RaiseException('Не удалось создать ' + ConfigFile);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
    StopHostAgent;
end;
