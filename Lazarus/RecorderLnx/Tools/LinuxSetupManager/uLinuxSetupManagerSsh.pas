unit uLinuxSetupManagerSsh;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes;

// Returns a process-like exit code. Mutating actions require the caller to
// start the current LinuxSetupManager executable with administrative rights.
function ExecuteSshSetup(AArgs: TStrings; out AOutput: string): Integer;

implementation

uses SysUtils, Process
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

function RunProgram(const AProgram: string; const AValues: array of string;
  out AOutput: string): Integer;
var
  lProcess: TProcess;
  lBuffer: array[0..4095] of Byte;
  lCount, lIndex: Integer;
  lChunk: string;
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

function ServiceName: string;
var lOutput: string;
begin
  if RunProgram('systemctl', ['list-unit-files', 'ssh.service', '--no-legend'],
    lOutput) = 0 then
  begin
    if Pos('ssh.service', lOutput) > 0 then Exit('ssh');
  end;
  Result := 'sshd';
end;

function ArgumentValue(AArgs: TStrings; const AName: string): string;
var lIndex: Integer;
begin
  Result := '';
  for lIndex := 1 to AArgs.Count - 2 do
    if AArgs[lIndex] = AName then Exit(AArgs[lIndex + 1]);
end;

function ValidUser(const AUser: string): Boolean;
var lIndex: Integer;
begin
  Result := False;
  if AUser = '' then Exit;
  if not (AUser[1] in ['a'..'z', '_']) then Exit;
  for lIndex := 2 to Length(AUser) do
    if not (AUser[lIndex] in ['a'..'z', '0'..'9', '_', '-']) then Exit;
  Result := True;
end;

function UserHome(const AUser: string; out AHome: string): Boolean;
var
  lLine: string;
  lFields: TStringList;
begin
  Result := False;
  AHome := '';
  if not ValidUser(AUser) then Exit;
  if RunProgram('getent', ['passwd', AUser], lLine) <> 0 then Exit;
  lFields := TStringList.Create;
  try
    lFields.StrictDelimiter := True;
    lFields.Delimiter := ':';
    lFields.DelimitedText := Trim(lLine);
    if lFields.Count < 7 then Exit;
    AHome := lFields[5];
    Result := (Copy(AHome, 1, 1) = '/') and DirectoryExists(AHome) and
      (Pos('..', AHome) = 0);
  finally
    lFields.Free;
  end;
end;

function ValidPublicKey(const AKey: string): Boolean;
var
  lKind, lBlob: string;
  lSpace, lIndex: Integer;
begin
  Result := False;
  lSpace := Pos(' ', AKey);
  if lSpace < 2 then Exit;
  lKind := Copy(AKey, 1, lSpace - 1);
  if not ((lKind = 'ssh-ed25519') or (lKind = 'ssh-rsa') or
    (Copy(lKind, 1, 17) = 'ecdsa-sha2-nistp')) then Exit;
  lBlob := Copy(AKey, lSpace + 1, Length(AKey));
  lSpace := Pos(' ', lBlob);
  if lSpace > 0 then lBlob := Copy(lBlob, 1, lSpace - 1);
  if Length(lBlob) < 32 then Exit;
  for lIndex := 1 to Length(lBlob) do
    if not (lBlob[lIndex] in ['A'..'Z','a'..'z','0'..'9','+','/','=']) then Exit;
  Result := True;
end;

function InstallPublicKey(AArgs: TStrings; out AOutput: string): Integer;
var
  lUser, lKeyFile, lHome, lKey, lAuth, lDir, lIgnore: string;
  lLines: TStringList;
begin
  Result := 1;
  lUser := ArgumentValue(AArgs, '--user');
  lKeyFile := ArgumentValue(AArgs, '--key-file');
  if not UserHome(lUser, lHome) then
  begin AOutput := 'Пользователь не найден.'; Exit; end;
  if (lKeyFile = '') or not FileExists(lKeyFile) then
  begin AOutput := 'Файл публичного ключа не найден.'; Exit; end;
  lLines := TStringList.Create;
  try
   try
    lLines.LoadFromFile(lKeyFile);
    if lLines.Count <> 1 then
    begin AOutput := 'Ожидалась одна строка публичного ключа.'; Exit; end;
    lKey := Trim(lLines[0]);
    if not ValidPublicKey(lKey) then
    begin AOutput := 'Файл не похож на открытый ключ OpenSSH.'; Exit; end;
    lDir := IncludeTrailingPathDelimiter(lHome) + '.ssh';
    lAuth := IncludeTrailingPathDelimiter(lDir) + 'authorized_keys';
    if (RunProgram('test', ['-L', lDir], lIgnore) = 0) or
      (RunProgram('test', ['-L', lAuth], lIgnore) = 0) then
    begin AOutput := 'Символические ссылки .ssh/authorized_keys запрещены.'; Exit; end;
    if not DirectoryExists(lDir) and not CreateDir(lDir) then
    begin AOutput := 'Не удалось создать .ssh.'; Exit; end;
    if FileExists(lAuth) then lLines.LoadFromFile(lAuth) else lLines.Clear;
    if lLines.IndexOf(lKey) < 0 then
    begin
      lLines.Add(lKey);
      lLines.SaveToFile(lAuth);
    end;
    if (RunProgram('chown', [lUser, lDir, lAuth], lIgnore) <> 0) or
      (RunProgram('chmod', ['700', lDir], lIgnore) <> 0) or
      (RunProgram('chmod', ['600', lAuth], lIgnore) <> 0) then
    begin AOutput := 'Ключ добавлен, но права .ssh не настроены: ' + lIgnore; Exit; end;
    AOutput := 'Публичный ключ установлен для ' + lUser;
    Result := 0;
   except
     on E: Exception do AOutput := E.Message;
   end;
  finally
    lLines.Free;
  end;
end;

function ExecuteSshSetup(AArgs: TStrings; out AOutput: string): Integer;
var
  lAction, lUser, lHost, lPort: string;
begin
  Result := 1;
  AOutput := '';
  {$IFDEF WINDOWS}
  AOutput := 'Настройка SSH доступна только в Linux.';
  Exit;
  {$ENDIF}
  if AArgs.Count = 0 then
  begin AOutput := 'Не указано действие SSH.'; Exit; end;
  lAction := AArgs[0];
  {$IFDEF UNIX}
  if (lAction = 'start') or (lAction = 'stop') or
    (lAction = 'enable') or (lAction = 'disable') or
    (lAction = 'install-key') or
    ((lAction = 'firewall') and (AArgs.Count > 1) and
     (AArgs[1] <> 'status')) then
    if fpGetEUID <> 0 then
    begin AOutput := 'Для изменения SSH нужны права администратора.'; Exit; end;
  {$ENDIF}
  if (lAction = 'status') or (lAction = 'start') or (lAction = 'stop') or
    (lAction = 'enable') or (lAction = 'disable') then
    Exit(RunProgram('systemctl', [lAction, ServiceName], AOutput));
  if lAction = 'firewall' then
  begin
    if AArgs.Count < 2 then
    begin AOutput := 'Укажите действие firewall.'; Exit; end;
    if AArgs[1] = 'status' then
      Exit(RunProgram('ufw', ['status', 'verbose'], AOutput));
    if AArgs[1] = 'allow' then
      Exit(RunProgram('ufw', ['allow', 'OpenSSH'], AOutput));
    if AArgs[1] = 'delete' then
      Exit(RunProgram('ufw', ['--force', 'delete', 'allow', 'OpenSSH'], AOutput));
    AOutput := 'Неизвестное действие firewall.';
    Exit;
  end;
  if lAction = 'install-key' then Exit(InstallPublicKey(AArgs, AOutput));
  if lAction = 'command' then
  begin
    lUser := ArgumentValue(AArgs, '--user');
    lHost := ArgumentValue(AArgs, '--host');
    lPort := ArgumentValue(AArgs, '--port');
    if not ValidUser(lUser) then
    begin AOutput := 'Недопустимый пользователь.'; Exit; end;
    if lHost = '' then
      if RunProgram('hostname', ['-f'], lHost) <> 0 then lHost := 'localhost';
    lHost := Trim(lHost);
    if lPort = '' then lPort := '22';
    if (StrToIntDef(lPort, 0) < 1) or (StrToIntDef(lPort, 0) > 65535) then
    begin AOutput := 'Недопустимый порт.'; Exit; end;
    AOutput := 'ssh -p ' + lPort + ' ' + lUser + '@' + lHost;
    Result := 0;
    Exit;
  end;
  AOutput := 'Неизвестное действие SSH: ' + lAction;
end;

end.
