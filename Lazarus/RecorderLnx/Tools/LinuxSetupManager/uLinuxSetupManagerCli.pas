unit uLinuxSetupManagerCli;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

function RunLinuxSetupCli: Integer;

implementation

uses
  Classes, SysUtils, Process, IniFiles;

const
  CHostnameHelper = '/usr/local/sbin/recorderlnx-set-hostname';
  CWolHelper = '/usr/local/sbin/recorderlnx-configure-wol';
  CShareHelper = '/usr/local/sbin/recorderlnx-share-folder';
  CConnectHelper = '/usr/local/sbin/recorderlnx-connect-share';
  CMeraAssociationHelper = '/usr/local/sbin/recorderlnx-associate-mera-winpos';
  CFileAssociationHelper = '/usr/local/sbin/recorderlnx-associate-file';
  CDesktopShortcutHelper = '/usr/local/sbin/recorderlnx-create-desktop-shortcut';
  CNetworkConfigHelper = '/usr/local/sbin/recorderlnx-configure-network';
  CProxyConfigHelper = '/usr/local/sbin/recorderlnx-configure-proxy';
  CTimeConfigHelper = '/usr/local/sbin/recorderlnx-configure-time';
  CAccessHelper = '/usr/local/sbin/recorderlnx-manage-access';
  CSshHelper = '/usr/local/sbin/recorderlnx-manage-ssh';
  CProfileHelper = '/usr/local/sbin/recorderlnx-profile';
  CDiskHelper = '/usr/local/sbin/recorderlnx-manage-disks';
  CRegistryDir = '/etc/recorderlnx/network-shares.d';

procedure PrintHelp;
begin
  WriteLn('Настройка Linux — командный интерфейс');
  WriteLn;
  WriteLn('Использование: LinuxSetupManager КОМАНДА [АРГУМЕНТЫ]');
  WriteLn;
  WriteLn('  help                         Показать эту справку');
  WriteLn('  status                       Показать имя ПК и состояние helper-ов');
  WriteLn('  hostname НОВОЕ_ИМЯ           Переименовать этот компьютер');
  WriteLn('  wol                          Включить Wake-on-LAN');
  WriteLn('  publish КАТАЛОГ [ИМЯ]        Опубликовать каталог (по умолчанию MeraFiles)');
  WriteLn('  connect ХОСТ РЕСУРС ИМЯ      Подключить SMB-ресурс');
  WriteLn('  disconnect ИМЯ               Отключить сетевой ресурс');
  WriteLn('  reconnect ИМЯ                Переподключить сетевой ресурс');
  WriteLn('  list                         Показать зарегистрированные ресурсы');
  WriteLn('  associate-mera               Открывать файлы .mera в WinПОС через Wine');
  WriteLn('  associate-file ФАЙЛ ПРОГРАММА Назначить программу расширению файла');
  WriteLn('  shortcut EXEC ПАРАМЕТРЫ ИМЯ [--desktop] [--autostart] [--sudo]');
  WriteLn('  autostart-remove ФАЙЛ.desktop Удалить программу из автозапуска');
  WriteLn('  network ...                  Настройка сети и маршрутов');
  WriteLn('  proxy ...                    Настройка системного прокси');
  WriteLn('  time ...                     Часовой пояс и NTP');
  WriteLn('  access ...                   Пользователи, группы и ACL');
  WriteLn('  ssh ...                      OpenSSH, firewall и публичные ключи');
  WriteLn('  profile ...                  Импорт и экспорт профиля ПК');
  WriteLn('  disks ...                    Просмотр, форматирование и монтаж дисков');
end;

function RunHelper(const AHelper: string;
  const AArguments: array of string): Integer; forward;

function ForwardArguments(const AHelper: string; AFirst: Integer): Integer;
var
  lArguments: array of string;
  lIndex: Integer;
begin
  SetLength(lArguments, ParamCount - AFirst + 3);
  lArguments[0] := '--internal';
  if AHelper = CNetworkConfigHelper then lArguments[1] := 'network'
  else if AHelper = CProxyConfigHelper then lArguments[1] := 'proxy'
  else if AHelper = CTimeConfigHelper then lArguments[1] := 'time'
  else if AHelper = CAccessHelper then lArguments[1] := 'access'
  else if AHelper = CSshHelper then lArguments[1] := 'ssh'
  else if AHelper = CProfileHelper then lArguments[1] := 'profile'
  else if AHelper = CDiskHelper then lArguments[1] := 'disks'
  else lArguments[1] := 'programs';
  for lIndex := AFirst to ParamCount do
    lArguments[lIndex - AFirst + 2] := ParamStr(lIndex);
  Result := RunHelper('/opt/mera/RecorderLnx/LinuxSetupManager', lArguments);
end;

function RequireArgumentCount(AExpected: Integer;
  const AUsage: string): Boolean;
begin
  Result := ParamCount = AExpected;
  if not Result then
    WriteLn(StdErr, 'Ошибка: использование: LinuxSetupManager ', AUsage);
end;

function RunHelper(const AHelper: string;
  const AArguments: array of string): Integer;
var
  lIndex: Integer;
  lProcess: TProcess;
  lSection: string;
begin
  if AHelper = CHostnameHelper then lSection := 'hostname'
  else if AHelper = CWolHelper then lSection := 'wol'
  else if AHelper = CShareHelper then lSection := 'publish'
  else if AHelper = CConnectHelper then lSection := 'shares'
  else if AHelper = CMeraAssociationHelper then lSection := 'associate-mera'
  else if AHelper = CFileAssociationHelper then lSection := 'associate-file'
  else if AHelper = '/opt/mera/RecorderLnx/LinuxSetupManager' then lSection := ''
  else lSection := '?';
  if lSection = '?' then
  begin
    WriteLn(StdErr, 'Ошибка: неизвестная встроенная операция ', AHelper);
    Exit(2);
  end;
  lProcess := TProcess.Create(nil);
  try
    try
      lProcess.Executable := 'pkexec';
      lProcess.Parameters.Add('/opt/mera/RecorderLnx/LinuxSetupManager');
      if lSection <> '' then
      begin
        lProcess.Parameters.Add('--internal');
        lProcess.Parameters.Add(lSection);
      end;
      for lIndex := Low(AArguments) to High(AArguments) do
        lProcess.Parameters.Add(AArguments[lIndex]);
      lProcess.Options := [poWaitOnExit];
      lProcess.Execute;
      Result := lProcess.ExitStatus;
      if Result <> 0 then
        WriteLn(StdErr, 'Операция завершилась с кодом ', Result, '.');
    except
      on E: Exception do
      begin
        WriteLn(StdErr, 'Не удалось запустить системную операцию: ', E.Message);
        Result := 3;
      end;
    end;
  finally
    lProcess.Free;
  end;
end;

function ReadComputerName: string;
var
  lOutput: TStringList;
  lProcess: TProcess;
begin
  Result := GetEnvironmentVariable('HOSTNAME');
  lOutput := TStringList.Create;
  lProcess := TProcess.Create(nil);
  try
    try
      lProcess.Executable := 'hostname';
      lProcess.Options := [poUsePipes, poWaitOnExit];
      lProcess.Execute;
      if lProcess.ExitStatus = 0 then
      begin
        lOutput.LoadFromStream(lProcess.Output);
        if lOutput.Count > 0 then
          Result := Trim(lOutput[0]);
      end;
    except
      { Переменная окружения остаётся резервным источником имени. }
    end;
  finally
    lProcess.Free;
    lOutput.Free;
  end;
end;

procedure PrintHelperState(const ACaption, APath: string);
const
  CState: array[Boolean] of string = ('не установлен', 'установлен');
begin
  WriteLn(ACaption, ': ', CState[FileExists(APath)]);
end;

function ListResources: Integer;
var
  lConfig: TIniFile;
  lFound: Boolean;
  lInfo: TSearchRec;
begin
  Result := 0;
  lFound := False;
  if FindFirst(IncludeTrailingPathDelimiter(CRegistryDir) + '*.ini', faAnyFile,
    lInfo) = 0 then
  try
    repeat
      if (lInfo.Attr and faDirectory) <> 0 then
        Continue;
      lConfig := TIniFile.Create(IncludeTrailingPathDelimiter(CRegistryDir) +
        lInfo.Name);
      try
        WriteLn(lConfig.ReadString('Share', 'LocalName', lInfo.Name), ': //',
          lConfig.ReadString('Share', 'Host', '?'), '/',
          lConfig.ReadString('Share', 'Name', '?'), ' -> ',
          lConfig.ReadString('Share', 'MountPoint', '?'));
        lFound := True;
      finally
        lConfig.Free;
      end;
    until FindNext(lInfo) <> 0;
  finally
    FindClose(lInfo);
  end;
  if not lFound then
    WriteLn('Подключённые сетевые ресурсы не зарегистрированы.');
end;

function ShowStatus: Integer;
begin
  WriteLn('Имя компьютера: ', ReadComputerName);
  PrintHelperState('Переименование', CHostnameHelper);
  PrintHelperState('Wake-on-LAN', CWolHelper);
  PrintHelperState('Публикация каталогов', CShareHelper);
  PrintHelperState('Подключение ресурсов', CConnectHelper);
  PrintHelperState('Ассоциация .mera с WinПОС', CMeraAssociationHelper);
  PrintHelperState('Произвольные ассоциации', CFileAssociationHelper);
  PrintHelperState('Программы и автозапуск', CDesktopShortcutHelper);
  PrintHelperState('Сеть и маршруты', CNetworkConfigHelper);
  PrintHelperState('Прокси', CProxyConfigHelper);
  PrintHelperState('Дата и время', CTimeConfigHelper);
  PrintHelperState('Пользователи и ACL', CAccessHelper);
  PrintHelperState('Удалённый доступ SSH', CSshHelper);
  PrintHelperState('Профили настроек', CProfileHelper);
  PrintHelperState('Диски и монтирование', CDiskHelper);
  WriteLn;
  Result := ListResources;
end;

function RunLinuxSetupCli: Integer;
var
  lAutostart, lCommand, lDesktop, lElevated: string;
  lIndex: Integer;
begin
  if ParamCount = 0 then
  begin
    PrintHelp;
    Exit(0);
  end;
  lCommand := LowerCase(Trim(ParamStr(1)));
  if (lCommand = 'help') or (lCommand = '--help') or (lCommand = '-h') then
  begin
    PrintHelp;
    Exit(0);
  end;
  if lCommand = 'status' then
    Exit(ShowStatus);
  if lCommand = 'list' then
    Exit(ListResources);
  if lCommand = 'hostname' then
  begin
    if not RequireArgumentCount(2, 'hostname НОВОЕ_ИМЯ') then Exit(1);
    Exit(RunHelper(CHostnameHelper, [ParamStr(2)]));
  end;
  if lCommand = 'wol' then
  begin
    if not RequireArgumentCount(1, 'wol') then Exit(1);
    Exit(RunHelper(CWolHelper, []));
  end;
  if lCommand = 'associate-mera' then
  begin
    if not RequireArgumentCount(1, 'associate-mera') then Exit(1);
    Exit(RunHelper(CMeraAssociationHelper, []));
  end;
  if lCommand = 'associate-file' then
  begin
    if not RequireArgumentCount(3, 'associate-file ФАЙЛ ПРОГРАММА') then Exit(1);
    Exit(RunHelper(CFileAssociationHelper, [ParamStr(2), ParamStr(3)]));
  end;
  if lCommand = 'shortcut' then
  begin
    if ParamCount < 4 then
    begin
      WriteLn(StdErr, 'Ошибка: использование: LinuxSetupManager shortcut EXEC ПАРАМЕТРЫ ИМЯ [--desktop] [--autostart] [--sudo]');
      Exit(1);
    end;
    lDesktop := 'false';
    lAutostart := 'false';
    lElevated := 'false';
    for lIndex := 5 to ParamCount do
    begin
      if ParamStr(lIndex) = '--desktop' then lDesktop := 'true'
      else if ParamStr(lIndex) = '--autostart' then lAutostart := 'true'
      else if ParamStr(lIndex) = '--sudo' then lElevated := 'true'
      else
      begin
        WriteLn(StdErr, 'Ошибка: неизвестный параметр ', ParamStr(lIndex));
        Exit(1);
      end;
    end;
    if (lDesktop = 'false') and (lAutostart = 'false') then
    begin
      WriteLn(StdErr, 'Ошибка: укажите --desktop и/или --autostart.');
      Exit(1);
    end;
    Exit(RunHelper('/opt/mera/RecorderLnx/LinuxSetupManager',
      ['--internal', 'programs', 'apply', ParamStr(2), ParamStr(3),
       lDesktop, lAutostart, lElevated, ParamStr(4)]));
  end;
  if lCommand = 'autostart-remove' then
  begin
    if not RequireArgumentCount(2, 'autostart-remove ФАЙЛ.desktop') then Exit(1);
    Exit(RunHelper('/opt/mera/RecorderLnx/LinuxSetupManager',
      ['--internal', 'programs', 'remove-autostart', ParamStr(2)]));
  end;
  if lCommand = 'publish' then
  begin
    if (ParamCount < 2) or (ParamCount > 3) then
    begin
      WriteLn(StdErr, 'Ошибка: использование: LinuxSetupManager publish КАТАЛОГ [ИМЯ]');
      Exit(1);
    end;
    if not DirectoryExists(ParamStr(2)) then
    begin
      WriteLn(StdErr, 'Ошибка: каталог не существует: ', ParamStr(2));
      Exit(1);
    end;
    if ParamCount = 3 then
      Exit(RunHelper(CShareHelper, [ParamStr(2), ParamStr(3)]));
    Exit(RunHelper(CShareHelper, [ParamStr(2), 'MeraFiles']));
  end;
  if lCommand = 'connect' then
  begin
    if not RequireArgumentCount(4, 'connect ХОСТ РЕСУРС ИМЯ') then Exit(1);
    Exit(RunHelper(CConnectHelper,
      ['connect', ParamStr(2), ParamStr(3), ParamStr(4)]));
  end;
  if lCommand = 'disconnect' then
  begin
    if not RequireArgumentCount(2, 'disconnect ИМЯ') then Exit(1);
    Exit(RunHelper(CConnectHelper,
      ['disconnect', '-', '-', ParamStr(2)]));
  end;
  if lCommand = 'reconnect' then
  begin
    if not RequireArgumentCount(2, 'reconnect ИМЯ') then Exit(1);
    Exit(RunHelper(CConnectHelper, ['reconnect', ParamStr(2)]));
  end;
  if lCommand = 'network' then Exit(ForwardArguments(CNetworkConfigHelper, 2));
  if lCommand = 'proxy' then Exit(ForwardArguments(CProxyConfigHelper, 2));
  if lCommand = 'time' then Exit(ForwardArguments(CTimeConfigHelper, 2));
  if lCommand = 'access' then Exit(ForwardArguments(CAccessHelper, 2));
  if lCommand = 'ssh' then Exit(ForwardArguments(CSshHelper, 2));
  if lCommand = 'profile' then Exit(ForwardArguments(CProfileHelper, 2));
  if lCommand = 'disks' then Exit(ForwardArguments(CDiskHelper, 2));
  WriteLn(StdErr, 'Неизвестная команда: ', ParamStr(1));
  WriteLn(StdErr, 'Выполните LinuxSetupManager help для просмотра команд.');
  Result := 1;
end;

end.
