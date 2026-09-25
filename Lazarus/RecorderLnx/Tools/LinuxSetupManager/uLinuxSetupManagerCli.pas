unit uLinuxSetupManagerCli;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

function RunLinuxSetupCli: Integer;

implementation

uses
  Classes, SysUtils, Process, IniFiles
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

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
  CCurrentScreenHelper = '/usr/local/sbin/recorderlnx-current-screen-rdp';
  CRegistryDir = '/etc/recorderlnx/network-shares.d';
  CFlyDmConfig = '/etc/X11/fly-dm/fly-dmrc';

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
  WriteLn('  publish КАТАЛОГ [ИМЯ] [ПОЛЬЗОВАТЕЛЬ] [ro|rw]');
  WriteLn('                               Опубликовать каталог; rw разрешает запись');
  WriteLn('  smb status|install            Проверить или установить SMB-сервер');
  WriteLn('  smb configure ПОЛЬЗОВАТЕЛЬ    Настроить Samba-пользователя; пароль и подтверждение через stdin');
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
  WriteLn('  time ntp-server ПОДСЕТЬ      Раздавать время через NTP (например, 192.168.1.0/24)');
  WriteLn('  time ntp-client ХОСТ         Синхронизировать время с указанным NTP-сервером');
  WriteLn('  access ...                   Пользователи, группы и ACL');
  WriteLn('  ssh ...                      OpenSSH, firewall и публичные ключи');
  WriteLn('  profile ...                  Импорт и экспорт профиля ПК');
  WriteLn('  disks ...                    Просмотр, форматирование и монтаж дисков');
  WriteLn('  current-screen status|diagnostics|enable|disable|password [USER]');
  WriteLn('  password ПОЛЬЗОВАТЕЛЬ [--sync-flydm]');
  WriteLn('                               Сменить пароль: две строки stdin (пароль и подтверждение)');
  WriteLn('                               Окончание строк LF и CRLF поддерживается');
end;

function ValidUserName(const AValue: string): Boolean; forward;
procedure RemoveTrailingCr(var AValue: UTF8String); forward;

function RunSmbChild(const AArgs: array of string; AElevated: Boolean;
  const AInput: UTF8String): Integer;
var
  lBuffer: array[0..4095] of Byte;
  lCount: Integer;
  lIndex: Integer;
  lProcess: TProcess;
begin
  lProcess := TProcess.Create(nil);
  try
    try
      if AElevated then
      begin
        lProcess.Executable := 'pkexec';
        lProcess.Parameters.Add(ExpandFileName(ParamStr(0)));
      end
      else
        lProcess.Executable := ExpandFileName(ParamStr(0));
      lProcess.Parameters.Add('--internal');
      lProcess.Parameters.Add('smb');
      for lIndex := Low(AArgs) to High(AArgs) do
        lProcess.Parameters.Add(AArgs[lIndex]);
      lProcess.Options := [poUsePipes];
      lProcess.Execute;
      if AInput <> '' then
        lProcess.Input.WriteBuffer(AInput[1], Length(AInput));
      lProcess.CloseInput;
      while lProcess.Running do
      begin
        if lProcess.Output.NumBytesAvailable > 0 then
        begin
          lCount := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
          if lCount > 0 then FileWrite(StdOutputHandle, lBuffer, lCount);
        end;
        if lProcess.Stderr.NumBytesAvailable > 0 then
        begin
          lCount := lProcess.Stderr.Read(lBuffer, SizeOf(lBuffer));
          if lCount > 0 then FileWrite(StdErrorHandle, lBuffer, lCount);
        end;
      end;
      repeat
        lCount := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
        if lCount > 0 then FileWrite(StdOutputHandle, lBuffer, lCount);
      until lCount <= 0;
      repeat
        lCount := lProcess.Stderr.Read(lBuffer, SizeOf(lBuffer));
        if lCount > 0 then FileWrite(StdErrorHandle, lBuffer, lCount);
      until lCount <= 0;
      lProcess.WaitOnExit;
      Result := lProcess.ExitStatus;
    except
      on E: Exception do
      begin
        WriteLn(StdErr, 'Не удалось выполнить настройку SMB: ', E.Message);
        Result := 3;
      end;
    end;
  finally
    lProcess.Free;
  end;
end;

function RunSmbAction: Integer;
var
  lArgs: array of string;
  lIndex: Integer;
  lConfirm, lInput, lPassword: UTF8String;
  lAction, lUser: string;
begin
  if ParamCount < 2 then
  begin
    WriteLn(StdErr, 'Использование: LinuxSetupManagerCli smb status|install|configure ПОЛЬЗОВАТЕЛЬ');
    Exit(1);
  end;
  lAction := LowerCase(ParamStr(2));
  if (lAction = 'status') and (ParamCount = 2) then
    Exit(RunSmbChild(['status'], False, ''));
  if (lAction = 'install') and (ParamCount = 2) then
    Exit(RunSmbChild(['install'], True, ''));
  if (lAction = 'users') and (ParamCount = 2) then
    Exit(RunSmbChild(['users'], True, ''));
  if (lAction = 'access') and (ParamCount = 3) then
    Exit(RunSmbChild(['access', ParamStr(3)], True, ''));
  if (lAction = 'access-apply') and (ParamCount >= 3) then
  begin
    SetLength(lArgs, ParamCount - 1);
    for lIndex := 2 to ParamCount do lArgs[lIndex - 2] := ParamStr(lIndex);
    Exit(RunSmbChild(lArgs, True, ''));
  end;
  if (lAction <> 'configure') or (ParamCount <> 3) then
  begin
    WriteLn(StdErr, 'Использование: LinuxSetupManagerCli smb configure ПОЛЬЗОВАТЕЛЬ');
    Exit(1);
  end;
  lUser := ParamStr(3);
  if not ValidUserName(lUser) then
  begin WriteLn(StdErr, 'Недопустимое имя пользователя.'); Exit(1); end;
  ReadLn(Input, lPassword);
  ReadLn(Input, lConfirm);
  RemoveTrailingCr(lPassword);
  RemoveTrailingCr(lConfirm);
  if (lPassword = '') or (lPassword <> lConfirm) then
  begin WriteLn(StdErr, 'Пароль пуст или подтверждение не совпадает.'); Exit(1); end;
  lInput := lPassword + LineEnding;
  Result := RunSmbChild(['configure', lUser, '--password-stdin'], True, lInput);
  lInput := '';
  lConfirm := '';
  lPassword := '';
end;

function ValidUserName(const AValue: string): Boolean;
var
  lChar: Char;
  lIndex: Integer;
begin
  Result := (AValue <> '') and (Length(AValue) <= 32) and
    (AValue[1] in ['a'..'z', 'A'..'Z', '_']);
  if not Result then Exit;
  for lIndex := 2 to Length(AValue) do
  begin
    lChar := AValue[lIndex];
    if not (lChar in ['a'..'z', 'A'..'Z', '0'..'9', '_', '-']) and
      not ((lChar = '$') and (lIndex = Length(AValue))) then
      Exit(False);
  end;
end;

procedure RemoveTrailingCr(var AValue: UTF8String);
begin
  if (Length(AValue) > 0) and (AValue[Length(AValue)] = #13) then
    SetLength(AValue, Length(AValue) - 1);
end;

function RequireArgumentCount(AExpected: Integer;
  const AUsage: string): Boolean; forward;

function SaveFlyDmConfig(const ALines: TStringList): Boolean;
var
  lTemp: string;
begin
  lTemp := CFlyDmConfig + '.linuxsetupmanager.tmp';
  try
    ALines.SaveToFile(lTemp);
    {$IFDEF UNIX}
    fpChmod(lTemp, &600);
    Result := fpRename(PChar(lTemp), PChar(CFlyDmConfig)) = 0;
    {$ELSE}
    DeleteFile(CFlyDmConfig);
    Result := RenameFile(lTemp, CFlyDmConfig);
    {$ENDIF}
  except
    Result := False;
  end;
  if not Result then DeleteFile(lTemp);
end;

function LocalUserExists(const AUser: string): Boolean;
var
  lProcess: TProcess;
begin
  Result := False;
  lProcess := TProcess.Create(nil);
  try
    try
      lProcess.Executable := '/usr/bin/getent';
      lProcess.Parameters.Add('passwd');
      lProcess.Parameters.Add(AUser);
      lProcess.Options := [poUsePipes, poWaitOnExit];
      lProcess.Execute;
      Result := lProcess.ExitStatus = 0;
    except
      Result := False;
    end;
  finally
    lProcess.Free;
  end;
end;

function UpdateFlyDmPassword(const APassword: UTF8String;
  out AOriginal: TStringList): Boolean;
var
  lFound: Boolean;
  lIndex: Integer;
  lUpdated: TStringList;
begin
  Result := False;
  AOriginal := nil;
  if not FileExists(CFlyDmConfig) then Exit;
  AOriginal := TStringList.Create;
  lUpdated := TStringList.Create;
  try
    try
      AOriginal.LoadFromFile(CFlyDmConfig);
    except
      Exit;
    end;
    lUpdated.Assign(AOriginal);
    lFound := False;
    for lIndex := 0 to lUpdated.Count - 1 do
      if Pos('autologinpass=', LowerCase(TrimLeft(lUpdated[lIndex]))) = 1 then
      begin
        lUpdated[lIndex] := 'AutoLoginPass=' + string(APassword);
        lFound := True;
        Break;
      end;
    if not lFound then
      lUpdated.Add('AutoLoginPass=' + string(APassword));
    Result := SaveFlyDmConfig(lUpdated);
  finally
    lUpdated.Free;
  end;
end;

function RunPasswordApply: Integer;
var
  lInput, lPassword: UTF8String;
  lOriginal: TStringList;
  lProcess: TProcess;
  lSyncFlyDm: Boolean;
  lUser: string;
begin
  {$IFDEF UNIX}
  if fpGetEUID <> 0 then
  begin
    WriteLn(StdErr, 'Ошибка: внутреннее действие требует права root.');
    Exit(3);
  end;
  {$ENDIF}
  if (ParamCount < 2) or (ParamCount > 3) then Exit(1);
  lUser := ParamStr(2);
  lSyncFlyDm := (ParamCount = 3) and (ParamStr(3) = '--sync-flydm');
  if not ValidUserName(lUser) or ((ParamCount = 3) and not lSyncFlyDm) then
    Exit(1);
  if not LocalUserExists(lUser) then
  begin
    WriteLn(StdErr, 'Локальный пользователь не найден: ', lUser);
    Exit(1);
  end;
  ReadLn(Input, lPassword);
  RemoveTrailingCr(lPassword);
  if (lPassword = '') or (Length(lPassword) > 1024) or
    (Pos(':', lPassword) > 0) then Exit(1);
  lOriginal := nil;
  if lSyncFlyDm and not UpdateFlyDmPassword(lPassword, lOriginal) then
  begin
    lOriginal.Free;
    WriteLn(StdErr, 'Не удалось безопасно обновить AutoLoginPass в ',
      CFlyDmConfig, '.');
    Exit(4);
  end;
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := '/usr/sbin/chpasswd';
    lProcess.Options := [poUsePipes];
    lProcess.Execute;
    lInput := UTF8String(lUser) + ':' + lPassword + LineEnding;
    lProcess.Input.WriteBuffer(lInput[1], Length(lInput));
    lProcess.CloseInput;
    lInput := '';
    lProcess.WaitOnExit;
    Result := lProcess.ExitStatus;
    if (Result <> 0) and lSyncFlyDm and (lOriginal <> nil) and
      not SaveFlyDmConfig(lOriginal) then
      WriteLn(StdErr, 'Не удалось восстановить конфигурацию Fly-DM.');
  finally
    {$IFDEF UNIX}if lSyncFlyDm then fpChmod(CFlyDmConfig, &600);{$ENDIF}
    lInput := '';
    lPassword := '';
    lOriginal.Free;
    lProcess.Free;
  end;
end;

function RunPasswordAction: Integer;
var
  lConfirm, lInput, lPassword: UTF8String;
  lProcess: TProcess;
  lUser: string;
begin
  if (ParamCount < 2) or (ParamCount > 3) then
  begin
    WriteLn(StdErr, 'Ошибка: использование: LinuxSetupManager password ПОЛЬЗОВАТЕЛЬ [--sync-flydm]');
    Exit(1);
  end;
  lUser := ParamStr(2);
  if not ValidUserName(lUser) or
    ((ParamCount = 3) and (ParamStr(3) <> '--sync-flydm')) then
  begin
    WriteLn(StdErr, 'Ошибка: недопустимое имя пользователя.');
    Exit(1);
  end;
  ReadLn(Input, lPassword);
  ReadLn(Input, lConfirm);
  RemoveTrailingCr(lPassword);
  RemoveTrailingCr(lConfirm);
  if (lPassword = '') or (Length(lPassword) > 1024) then
  begin
    WriteLn(StdErr, 'Ошибка: пароль должен содержать от 1 до 1024 байт.');
    Exit(1);
  end;
  if Pos(':', lPassword) > 0 then
  begin
    WriteLn(StdErr, 'Ошибка: пароль не должен содержать двоеточие.');
    Exit(1);
  end;
  if lPassword <> lConfirm then
  begin
    WriteLn(StdErr, 'Ошибка: пароли не совпадают.');
    Exit(1);
  end;
  lProcess := TProcess.Create(nil);
  try
    try
      lProcess.Executable := 'pkexec';
      lProcess.Parameters.Add(ExpandFileName(ParamStr(0)));
      lProcess.Parameters.Add('--password-apply');
      lProcess.Parameters.Add(lUser);
      if ParamCount = 3 then lProcess.Parameters.Add('--sync-flydm');
      lProcess.Options := [poUsePipes];
      lProcess.Execute;
      lInput := lPassword + LineEnding;
      lProcess.Input.WriteBuffer(lInput[1], Length(lInput));
      lProcess.CloseInput;
      lInput := '';
      lProcess.WaitOnExit;
      Result := lProcess.ExitStatus;
      if Result = 0 then WriteLn('Пароль пользователя изменён.')
      else WriteLn(StdErr, 'Не удалось изменить пароль. Код ', Result, '.');
    except
      on E: Exception do
      begin
        WriteLn(StdErr, 'Не удалось запустить смену пароля: ', E.Message);
        Result := 3;
      end;
    end;
  finally
    lInput := '';
    lConfirm := '';
    lPassword := '';
    lProcess.Free;
  end;
end;

function RunCurrentScreenAction: Integer;
var
  lProcess: TProcess;
  lAction: string;
  lPassword: UTF8String;
  lIndex: Integer;
begin
  if (ParamCount < 2) or (ParamCount > 3) then
  begin
    WriteLn(StdErr, 'Использование: LinuxSetupManagerCli current-screen status|diagnostics|enable|disable|password [USER]');
    Exit(1);
  end;
  lAction := LowerCase(ParamStr(2));
  if (lAction <> 'status') and (lAction <> 'diagnostics') and (lAction <> 'enable') and
    (lAction <> 'disable') and (lAction <> 'password') then
  begin
    WriteLn(StdErr, 'Неизвестное действие: ', ParamStr(2));
    Exit(1);
  end;
  if not FileExists(CCurrentScreenHelper) then
  begin
    WriteLn(StdErr, 'Компонент текущего экрана не установлен: ',
      CCurrentScreenHelper);
    Exit(3);
  end;
  if lAction = 'password' then
  begin
    ReadLn(Input, lPassword);
    if (Length(lPassword) > 0) and (lPassword[Length(lPassword)] = #13) then
      SetLength(lPassword, Length(lPassword) - 1);
    if (Length(lPassword) < 1) or (Length(lPassword) > 8) then
    begin
      WriteLn(StdErr, 'Пароль должен содержать от 1 до 8 печатных символов ASCII.');
      Exit(1);
    end;
    for lIndex := 1 to Length(lPassword) do
      if (Ord(lPassword[lIndex]) < 33) or (Ord(lPassword[lIndex]) > 126) then
      begin
        WriteLn(StdErr, 'Пароль должен содержать от 1 до 8 печатных символов ASCII.');
        Exit(1);
      end;
  end;
  lProcess := TProcess.Create(nil);
  try
    try
      if (lAction = 'status') or (lAction = 'diagnostics')
        {$IFDEF UNIX}or (fpGetEUID = 0){$ENDIF} then
        lProcess.Executable := CCurrentScreenHelper
      else
      begin
        lProcess.Executable := 'pkexec';
        lProcess.Parameters.Add(CCurrentScreenHelper);
      end;
      lProcess.Parameters.Add(lAction);
      if ParamCount = 3 then lProcess.Parameters.Add(ParamStr(3));
      if lAction = 'password' then
        lProcess.Options := [poUsePipes]
      else
        lProcess.Options := [poWaitOnExit];
      lProcess.Execute;
      if lAction = 'password' then
      begin
        lPassword := lPassword + LineEnding;
        lProcess.Input.WriteBuffer(lPassword[1], Length(lPassword));
        lProcess.CloseInput;
        lProcess.WaitOnExit;
      end;
      Result := lProcess.ExitStatus;
      if lAction = 'password' then
      begin
        if Result = 0 then WriteLn('Пароль удалённого рабочего стола изменён.')
        else WriteLn(StdErr, 'Не удалось изменить пароль. Код ', Result, '.');
      end;
    except
      on E: Exception do
      begin
        WriteLn(StdErr, 'Не удалось запустить настройку: ', E.Message);
        Result := 3;
      end;
    end;
  finally
    lPassword := '';
    lProcess.Free;
  end;
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
  PrintHelperState('Текущий экран через RDP', CCurrentScreenHelper);
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
  if lCommand = '--password-apply' then Exit(RunPasswordApply);
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
    if (ParamCount < 2) or (ParamCount > 5) then
    begin
      WriteLn(StdErr, 'Ошибка: использование: LinuxSetupManager publish КАТАЛОГ [ИМЯ] [ПОЛЬЗОВАТЕЛЬ] [ro|rw]');
      Exit(1);
    end;
    if not DirectoryExists(ParamStr(2)) then
    begin
      WriteLn(StdErr, 'Ошибка: каталог не существует: ', ParamStr(2));
      Exit(1);
    end;
    if ParamCount = 5 then
      Exit(RunHelper('/opt/mera/RecorderLnx/LinuxSetupManager',
        ['--internal', 'publish', ParamStr(2), ParamStr(3), ParamStr(4), ParamStr(5)]));
    if ParamCount = 4 then
      Exit(RunHelper('/opt/mera/RecorderLnx/LinuxSetupManager',
        ['--internal', 'publish', ParamStr(2), ParamStr(3), ParamStr(4)]));
    if ParamCount = 3 then
      Exit(RunHelper('/opt/mera/RecorderLnx/LinuxSetupManager',
        ['--internal', 'publish', ParamStr(2), ParamStr(3)]));
    Exit(RunHelper('/opt/mera/RecorderLnx/LinuxSetupManager',
      ['--internal', 'publish', ParamStr(2), 'MeraFiles']));
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
  if lCommand = 'smb' then Exit(RunSmbAction);
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
  if lCommand = 'current-screen' then Exit(RunCurrentScreenAction);
  if lCommand = 'password' then Exit(RunPasswordAction);
  WriteLn(StdErr, 'Неизвестная команда: ', ParamStr(1));
  WriteLn(StdErr, 'Выполните LinuxSetupManager help для просмотра команд.');
  Result := 1;
end;

end.
