unit uLinuxSetupManagerProfile;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes;

function ExecuteProfileSetup(AArgs: TStrings; out AOutput: string): Integer;

implementation

uses SysUtils, Process, uLinuxSetupManagerSsh
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

const
  CSections = 'hostname,network,routes,proxy,time,users,acl,shares,autostart,ssh';

function RunProgram(const AProgram: string; const AValues: array of string;
  out AOutput: string): Integer;
var
  lProcess: TProcess;
  lBuffer: array[0..4095] of Byte;
  lChunk: string;
  lCount, lIndex: Integer;
begin
  Result := 1;
  AOutput := '';
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := AProgram;
    for lIndex := Low(AValues) to High(AValues) do
      lProcess.Parameters.Add(AValues[lIndex]);
    lProcess.Options := [poUsePipes, poStderrToOutput];
    try
      lProcess.Execute;
      repeat
        lCount := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
        if lCount > 0 then
        begin
          SetString(lChunk, PChar(@lBuffer[0]), lCount);
          AOutput := AOutput + lChunk;
        end;
      until lCount = 0;
      lProcess.WaitOnExit;
      Result := lProcess.ExitStatus;
    except
      on E: Exception do AOutput := E.Message;
    end;
  finally
    lProcess.Free;
  end;
end;

function ValueAfter(AArgs: TStrings; const AOption: string): string;
var lIndex: Integer;
begin
  Result := '';
  for lIndex := 1 to AArgs.Count - 2 do
    if AArgs[lIndex] = AOption then Exit(AArgs[lIndex + 1]);
end;

function SafeAbsoluteDirectory(const APath: string): Boolean;
begin
  Result := (Copy(APath, 1, 1) = '/') and
    (APath <> '/') and (Pos('..', APath) = 0) and
    (Pos(#10, APath) = 0) and (Pos(#13, APath) = 0);
end;

function SaveText(const APath, AText: string): Boolean;
var lLines: TStringList;
begin
  Result := False;
  lLines := TStringList.Create;
  try
    lLines.Text := AText;
    lLines.SaveToFile(APath);
    Result := True;
  finally
    lLines.Free;
  end;
end;

function ReadText(const APath: string): string;
var lLines: TStringList;
begin
  Result := '';
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(APath);
    Result := lLines.Text;
  finally
    lLines.Free;
  end;
end;

function PublicGroups(const AInput: string): string;
var
  lLines, lFields: TStringList;
  lIndex: Integer;
begin
  Result := '';
  lLines := TStringList.Create;
  lFields := TStringList.Create;
  try
    lLines.Text := AInput;
    lFields.StrictDelimiter := True;
    lFields.Delimiter := ':';
    for lIndex := 0 to lLines.Count - 1 do
    begin
      lFields.DelimitedText := lLines[lIndex];
      if lFields.Count >= 4 then
        Result := Result + lFields[0] + #9 + lFields[2] + #9 +
          lFields[3] + LineEnding;
    end;
  finally
    lFields.Free;
    lLines.Free;
  end;
end;

function ExportProfile(const APath: string; out AOutput: string): Integer;
var
  lHost, lText, lDir: string;
begin
  Result := 1;
  if not SafeAbsoluteDirectory(APath) or FileExists(APath) or DirectoryExists(APath) then
  begin AOutput := 'Нужен новый абсолютный каталог профиля.'; Exit; end;
  if not CreateDir(APath) then
  begin AOutput := 'Не удалось создать каталог профиля.'; Exit; end;
  RunProgram('hostname', [], lHost);
  if not SaveText(APath + '/profile.ini',
    'FORMAT=recorderlnx-linux-profile' + LineEnding +
    'VERSION=2' + LineEnding + 'SECRETS_INCLUDED=no' + LineEnding +
    'SOURCE_HOST=' + Trim(lHost) + LineEnding) then Exit;
  SaveText(APath + '/hostname.txt', Trim(lHost));
  lDir := APath + '/network';
  if CreateDir(lDir) then
  begin
    if RunProgram('nmcli', ['-t', '-f', 'NAME,DEVICE,TYPE', 'connection',
      'show', '--active'], lText) = 0 then
      SaveText(lDir + '/connections.txt', lText);
    if RunProgram('ip', ['-4', 'route', 'show'], lText) = 0 then
      SaveText(lDir + '/routes.txt', lText);
  end;
  lDir := APath + '/time';
  if CreateDir(lDir) and
    (RunProgram('timedatectl', ['show', '-p', 'Timezone', '-p', 'NTP'], lText) = 0) then
    SaveText(lDir + '/state.ini', lText);
  lDir := APath + '/users';
  if CreateDir(lDir) and (RunProgram('getent', ['group'], lText) = 0) then
    SaveText(lDir + '/groups.tsv', PublicGroups(lText));
  lDir := APath + '/ssh';
  if CreateDir(lDir) then
  begin
    RunProgram('systemctl', ['is-enabled', 'ssh'], lText);
    SaveText(lDir + '/enabled.txt', Trim(lText));
  end;
  // Secrets and arbitrary executable configuration are intentionally omitted.
  CreateDir(APath + '/proxy');
  SaveText(APath + '/proxy/README.txt',
    'Прокси не экспортирован: URL и конфиги могут содержать пароль. Настройте вручную.');
  CreateDir(APath + '/acl');
  CreateDir(APath + '/shares');
  CreateDir(APath + '/autostart');
  AOutput := 'Профиль создан: ' + APath + LineEnding +
    'Экспортированы hostname, активные сетевые подключения/маршруты, время, ' +
    'группы и состояние SSH. Секреты, ACL, Samba и автозапуск не копировались.';
  Result := 0;
end;

function ValidateProfile(const APath: string; out AOutput: string): Integer;
var lLines: TStringList;
begin
  Result := 1;
  if not SafeAbsoluteDirectory(APath) or
    not FileExists(APath + '/profile.ini') or
    not FileExists(APath + '/hostname.txt') then
  begin AOutput := 'Профиль не найден или неполон.'; Exit; end;
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(APath + '/profile.ini');
    if (lLines.IndexOf('FORMAT=recorderlnx-linux-profile') < 0) or
      (lLines.IndexOf('VERSION=2') < 0) or
      (lLines.IndexOf('SECRETS_INCLUDED=no') < 0) then
    begin AOutput := 'Неверный формат или версия профиля.'; Exit; end;
    AOutput := 'Профиль корректен. Секретов нет.';
    Result := 0;
  finally
    lLines.Free;
  end;
end;

function ValidSections(const ASections: string; out AOutput: string): Boolean;
var
  lItems: TStringList;
  lIndex: Integer;
begin
  Result := False;
  if ASections = '' then
  begin AOutput := 'Для apply обязательно --sections.'; Exit; end;
  lItems := TStringList.Create;
  try
    lItems.StrictDelimiter := True;
    lItems.Delimiter := ',';
    lItems.DelimitedText := ASections;
    for lIndex := 0 to lItems.Count - 1 do
      if (lItems[lIndex] <> 'all') and
        (Pos(',' + lItems[lIndex] + ',', ',' + CSections + ',') = 0) then
      begin AOutput := 'Неизвестный раздел: ' + lItems[lIndex]; Exit; end;
    Result := True;
  finally
    lItems.Free;
  end;
end;

function Selected(const ASections, AName: string): Boolean;
begin
  Result := (Pos(',all,', ',' + ASections + ',') > 0) or
    (Pos(',' + AName + ',', ',' + ASections + ',') > 0);
end;

function ValidateApplySections(const ASections: string; out AOutput: string): Boolean;
const CUnsupported = 'network,routes,proxy,acl,shares,autostart';
var
  lSections: TStringList;
  lIndex: Integer;
begin
  Result := False;
  if Selected(ASections, 'all') then
  begin
    AOutput := 'all включает неподдерживаемые разделы. Укажите только hostname,time,users,ssh.';
    Exit;
  end;
  lSections := TStringList.Create;
  try
    lSections.StrictDelimiter := True;
    lSections.Delimiter := ',';
    lSections.DelimitedText := ASections;
    for lIndex := 0 to lSections.Count - 1 do
      if Pos(',' + lSections[lIndex] + ',', ',' + CUnsupported + ',') > 0 then
      begin
        AOutput := 'Раздел ' + lSections[lIndex] +
          ' не применяется автоматически: нужен отдельный безопасный сценарий.';
        Exit;
      end;
    Result := True;
  finally
    lSections.Free;
  end;
end;

function ValidHostname(const AValue: string): Boolean;
var lIndex: Integer;
begin
  Result := False;
  if (AValue = '') or (Length(AValue) > 63) then Exit;
  if not (AValue[1] in ['A'..'Z','a'..'z','0'..'9']) then Exit;
  for lIndex := 2 to Length(AValue) do
    if not (AValue[lIndex] in ['A'..'Z','a'..'z','0'..'9','-','.']) then Exit;
  Result := True;
end;

function IniValue(const AText, AName: string): string;
var
  lLines: TStringList;
  lIndex: Integer;
begin
  Result := '';
  lLines := TStringList.Create;
  try
    lLines.Text := AText;
    for lIndex := 0 to lLines.Count - 1 do
      if Copy(lLines[lIndex], 1, Length(AName) + 1) = AName + '=' then
        Exit(Copy(lLines[lIndex], Length(AName) + 2, MaxInt));
  finally
    lLines.Free;
  end;
end;

function ValidateSelected(const APath, ASections: string; out AOutput: string): Boolean;
var
  lName, lTime, lTimezone, lNtp, lSsh: string;
begin
  Result := False;
  if Selected(ASections, 'hostname') then
  begin
    lName := Trim(ReadText(APath + '/hostname.txt'));
    if not ValidHostname(lName) then
    begin AOutput := 'Некорректное имя компьютера в профиле.'; Exit; end;
  end;
  if Selected(ASections, 'time') then
  begin
    if not FileExists(APath + '/time/state.ini') then
    begin AOutput := 'Нет состояния времени в профиле.'; Exit; end;
    lTime := ReadText(APath + '/time/state.ini');
    lTimezone := IniValue(lTime, 'Timezone');
    lNtp := IniValue(lTime, 'NTP');
    if (lTimezone = '') or (Pos('..', lTimezone) > 0) or
      (Pos(' ', lTimezone) > 0) or not ((lNtp = 'yes') or (lNtp = 'no')) then
    begin AOutput := 'Некорректная зона времени или NTP.'; Exit; end;
  end;
  if Selected(ASections, 'users') and
    not FileExists(APath + '/users/groups.tsv') then
  begin AOutput := 'Нет списка групп в профиле.'; Exit; end;
  if Selected(ASections, 'ssh') then
  begin
    if not FileExists(APath + '/ssh/enabled.txt') then
    begin AOutput := 'Нет состояния SSH в профиле.'; Exit; end;
    lSsh := Trim(ReadText(APath + '/ssh/enabled.txt'));
    if (lSsh <> 'enabled') and (lSsh <> 'disabled') then
    begin AOutput := 'Неподдерживаемое состояние SSH: ' + lSsh; Exit; end;
  end;
  Result := True;
end;

function ApplyGroups(const APath: string; out AOutput: string): Integer;
var
  lLines, lFields, lMembers: TStringList;
  lIndex, lMember: Integer;
  lGroup, lUser, lCurrent: string;
begin
  Result := 0;
  AOutput := '';
  lLines := TStringList.Create;
  lFields := TStringList.Create;
  lMembers := TStringList.Create;
  try
    lLines.LoadFromFile(APath + '/users/groups.tsv');
    lFields.StrictDelimiter := True;
    lFields.Delimiter := #9;
    lMembers.StrictDelimiter := True;
    lMembers.Delimiter := ',';
    for lIndex := 0 to lLines.Count - 1 do
    begin
      lFields.DelimitedText := lLines[lIndex];
      if lFields.Count < 3 then Continue;
      lGroup := lFields[0];
      if (lGroup = '') or (RunProgram('getent', ['group', lGroup], lCurrent) <> 0) then Continue;
      lMembers.DelimitedText := lFields[2];
      for lMember := 0 to lMembers.Count - 1 do
      begin
        lUser := lMembers[lMember];
        if (lUser = '') or (RunProgram('getent', ['passwd', lUser], lCurrent) <> 0) then Continue;
        Result := RunProgram('usermod', ['-aG', lGroup, lUser], lCurrent);
        if Result <> 0 then
        begin AOutput := 'Не удалось добавить ' + lUser + ' в ' + lGroup + ': ' + lCurrent; Exit; end;
      end;
    end;
  finally
    lMembers.Free;
    lFields.Free;
    lLines.Free;
  end;
  AOutput := 'Членство существующих пользователей дополнено.';
end;

function ApplyProfile(const APath, ASections: string; out AOutput: string): Integer;
var
  lBackup, lCurrent, lState, lValue, lResult: string;
  lArgs: TStringList;
begin
  Result := 1;
  {$IFDEF UNIX}
  if fpGetEUID <> 0 then
  begin AOutput := 'Для применения профиля нужны права администратора.'; Exit; end;
  {$ENDIF}
  if not ValidateApplySections(ASections, AOutput) or
    not ValidateSelected(APath, ASections, AOutput) then Exit;
  lBackup := '/var/backups/linuxsetupmanager-' + FormatDateTime('yyyymmddhhnnss', Now);
  if not DirectoryExists('/var/backups') or not CreateDir(lBackup) then
  begin AOutput := 'Не удалось создать каталог резервной копии.'; Exit; end;
  if RunProgram('chmod', ['700', lBackup], lCurrent) <> 0 then
  begin AOutput := 'Не удалось защитить каталог резервной копии.'; Exit; end;
  RunProgram('hostname', [], lCurrent);
  SaveText(lBackup + '/hostname.txt', lCurrent);
  RunProgram('timedatectl', ['show', '-p', 'Timezone', '-p', 'NTP'], lCurrent);
  SaveText(lBackup + '/time.ini', lCurrent);
  if RunProgram('getent', ['group'], lCurrent) = 0 then
    SaveText(lBackup + '/groups.tsv', PublicGroups(lCurrent));
  RunProgram('systemctl', ['is-enabled', 'ssh'], lCurrent);
  SaveText(lBackup + '/ssh-enabled.txt', lCurrent);
  AOutput := 'Резервная копия текущего состояния: ' + lBackup + LineEnding;
  if Selected(ASections, 'hostname') then
  begin
    Result := RunProgram('hostnamectl', ['set-hostname',
      Trim(ReadText(APath + '/hostname.txt'))], lResult);
    if Result <> 0 then begin AOutput := AOutput + lResult; Exit; end;
  end;
  if Selected(ASections, 'time') then
  begin
    lState := ReadText(APath + '/time/state.ini');
    lValue := IniValue(lState, 'Timezone');
    Result := RunProgram('timedatectl', ['set-timezone', lValue], lResult);
    if Result <> 0 then begin AOutput := AOutput + lResult; Exit; end;
    lValue := IniValue(lState, 'NTP');
    if lValue = 'yes' then lValue := 'true' else lValue := 'false';
    Result := RunProgram('timedatectl', ['set-ntp', lValue], lResult);
    if Result <> 0 then begin AOutput := AOutput + lResult; Exit; end;
  end;
  if Selected(ASections, 'users') then
  begin
    Result := ApplyGroups(APath, lResult);
    if Result <> 0 then begin AOutput := AOutput + lResult; Exit; end;
  end;
  if Selected(ASections, 'ssh') then
  begin
    lArgs := TStringList.Create;
    try
      lValue := Trim(ReadText(APath + '/ssh/enabled.txt'));
      if lValue = 'enabled' then lArgs.Add('enable') else lArgs.Add('disable');
      Result := ExecuteSshSetup(lArgs, lResult);
      if Result <> 0 then begin AOutput := AOutput + lResult; Exit; end;
    finally
      lArgs.Free;
    end;
  end;
  Result := 0;
  AOutput := AOutput + 'Выбранные разделы применены: ' + ASections;
end;

function ExecuteProfileSetup(AArgs: TStrings; out AOutput: string): Integer;
var
  lAction, lPath, lSections: string;
begin
  Result := 1;
  AOutput := '';
  {$IFDEF WINDOWS}
  AOutput := 'Профили Linux доступны только в Linux.';
  Exit;
  {$ENDIF}
  if AArgs.Count = 0 then
  begin AOutput := 'Не указана команда профиля.'; Exit; end;
  lAction := AArgs[0];
  if lAction = 'export' then
    Exit(ExportProfile(ValueAfter(AArgs, '--output'), AOutput));
  lPath := ValueAfter(AArgs, '--profile');
  Result := ValidateProfile(lPath, AOutput);
  if Result <> 0 then Exit;
  if lAction = 'validate' then Exit;
  lSections := ValueAfter(AArgs, '--sections');
  if (lSections = '') and (lAction = 'plan') then lSections := 'all';
  if not ValidSections(lSections, AOutput) then Exit(1);
  if lAction = 'plan' then
  begin
    AOutput := 'Выбраны разделы: ' + lSections + LineEnding +
      'Применение поддержано: hostname, time, users (только добавление ' +
      'существующих пользователей в существующие группы), ssh (автозапуск). ' +
      'Сеть, маршруты, прокси, ACL, Samba и автозапуск требуют отдельной ' +
      'проверки и здесь заблокированы. Перед применением создаётся резервная ' +
      'копия текущего состояния в /var/backups; смена сети может оборвать SSH.';
    Exit(0);
  end;
  if lAction = 'apply' then
    Exit(ApplyProfile(lPath, lSections, AOutput));
  AOutput := 'Неизвестное действие профиля: ' + lAction;
end;

end.
