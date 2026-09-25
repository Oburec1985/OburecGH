unit uLinuxSetupManagerSmb;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes;

function ExecuteSmbSetup(const AArgs: TStrings; const APassword: UTF8String;
  out AOutput: string): Integer;

implementation

uses SysUtils, Process
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

const
  CSettingsFile = '/etc/recorderlnx/smb-server.conf';
  CSmbConfig = '/etc/samba/smb.conf';

function RunProcess(const AProgram: string; const AArgs: array of string;
  const AInput: UTF8String; out AOutput: string): Boolean;
var
  lBuffer: array[0..4095] of Byte;
  lCount, lIndex: Integer;
  lProcess: TProcess;
  lStream: TMemoryStream;
begin
  Result := False;
  AOutput := '';
  lProcess := TProcess.Create(nil);
  lStream := TMemoryStream.Create;
  try
    lProcess.Executable := AProgram;
    for lIndex := Low(AArgs) to High(AArgs) do
      lProcess.Parameters.Add(AArgs[lIndex]);
    lProcess.Options := [poUsePipes, poStderrToOutput];
    try
      lProcess.Execute;
      if AInput <> '' then
        lProcess.Input.WriteBuffer(AInput[1], Length(AInput));
      lProcess.CloseInput;
      while lProcess.Running or (lProcess.Output.NumBytesAvailable > 0) do
      begin
        lCount := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
        if lCount > 0 then lStream.WriteBuffer(lBuffer, lCount);
      end;
      lProcess.WaitOnExit;
      SetLength(AOutput, lStream.Size);
      if lStream.Size > 0 then
      begin
        lStream.Position := 0;
        lStream.ReadBuffer(AOutput[1], lStream.Size);
      end;
      Result := lProcess.ExitStatus = 0;
    except
      on E: Exception do AOutput := E.Message;
    end;
  finally
    lStream.Free;
    lProcess.Free;
  end;
end;

function CommandExists(const APath: string): Boolean;
begin
  Result := FileExists(APath);
end;

function ServiceEnabled(const AName: string): Boolean;
var lText: string;
begin
  Result := RunProcess('/bin/systemctl', ['is-enabled', AName], '', lText);
end;

function ServiceActive(const AName: string): Boolean;
var lText: string;
begin
  Result := RunProcess('/bin/systemctl', ['is-active', AName], '', lText);
end;

function Status(out AOutput: string): Integer;
var
  lConfigOk, lSmbd, lNmbd: Boolean;
  lText: string;
begin
  lSmbd := CommandExists('/usr/sbin/smbd');
  lNmbd := CommandExists('/usr/sbin/nmbd');
  lConfigOk := CommandExists('/usr/bin/testparm') and
    RunProcess('/usr/bin/testparm', ['-s'], '', lText);
  AOutput := 'Samba: ';
  if lSmbd then AOutput += 'установлена' else AOutput += 'не установлена';
  AOutput += LineEnding + 'Конфигурация: ';
  if lConfigOk then AOutput += 'исправна' else AOutput += 'не проверена или содержит ошибку';
  AOutput += LineEnding + 'smbd: ';
  if ServiceActive('smbd') then AOutput += 'работает' else AOutput += 'не работает';
  AOutput += ', автозапуск ';
  if ServiceEnabled('smbd') then AOutput += 'включён' else AOutput += 'выключен';
  AOutput += LineEnding + 'Обнаружение в WORKGROUP (nmbd): ';
  if not lNmbd then AOutput += 'не установлено'
  else if ServiceActive('nmbd') then AOutput += 'работает'
  else AOutput += 'не работает';
  if FileExists(CSettingsFile) then
  begin
    with TStringList.Create do
    try
      try
        LoadFromFile(CSettingsFile);
        AOutput += LineEnding + 'Пользователь ресурсов: ' + Values['User'];
      except
        AOutput += LineEnding + 'Пользователь ресурсов: доступен после авторизации администратора';
      end;
    finally Free; end;
  end;
  if lSmbd and lConfigOk and ServiceActive('smbd') then Result := 0
  else Result := 1;
end;

function RequireRoot(out AOutput: string): Boolean;
begin
  {$IFDEF UNIX}
  Result := fpGetEUID = 0;
  {$ELSE}
  Result := True;
  {$ENDIF}
  if not Result then AOutput := 'Требуются права root (pkexec/sudo).';
end;

function InstallServer(out AOutput: string): Integer;
var lText: string;
begin
  Result := 1;
  if not RequireRoot(AOutput) then Exit;
  if not CommandExists('/usr/sbin/smbd') or
     not CommandExists('/usr/bin/testparm') then
    if not RunProcess('/usr/bin/apt-get',
      ['install', '-y', 'samba', 'smbclient', 'acl'], '', lText) then
    begin
      AOutput := 'Не удалось установить Samba: ' + Trim(lText);
      Exit;
    end;
  if not RunProcess('/bin/systemctl', ['enable', '--now', 'smbd'], '', lText) then
  begin AOutput := 'Не удалось запустить smbd: ' + Trim(lText); Exit; end;
  if CommandExists('/usr/sbin/nmbd') then
    RunProcess('/bin/systemctl', ['enable', '--now', 'nmbd'], '', lText);
  if CommandExists('/usr/sbin/ufw') and
     RunProcess('/usr/sbin/ufw', ['status'], '', lText) and
     (Pos('Status: active', lText) > 0) then
    RunProcess('/usr/sbin/ufw', ['allow', 'Samba'], '', lText);
  if not RunProcess('/usr/bin/testparm', ['-s'], '', lText) then
  begin AOutput := 'Ошибка smb.conf: ' + Trim(lText); Exit; end;
  AOutput := 'Samba установлена, smbd запущен и добавлен в автозапуск.';
  Result := 0;
end;

function ValidUser(const AUser: string): Boolean;
var lText: string;
begin
  Result := (AUser <> '') and
    RunProcess('/usr/bin/getent', ['passwd', AUser], '', lText);
end;

function SaveUser(const AUser: string; out AOutput: string): Boolean;
var lLines: TStringList;
begin
  Result := False;
  if not ForceDirectories(ExtractFileDir(CSettingsFile)) then
  begin AOutput := 'Не удалось создать /etc/recorderlnx.'; Exit; end;
  lLines := TStringList.Create;
  try
    lLines.Add('[SMB]');
    lLines.Add('User=' + AUser);
    try
      lLines.SaveToFile(CSettingsFile);
      {$IFDEF UNIX}fpChmod(CSettingsFile, &600);{$ENDIF}
      Result := True;
    except on E: Exception do AOutput := E.Message; end;
  finally lLines.Free; end;
end;

function ConfigureUser(const AUser: string; const APassword: UTF8String;
  out AOutput: string): Integer;
var lInput: UTF8String; lText: string;
begin
  Result := 1;
  if not RequireRoot(AOutput) then Exit;
  if not ValidUser(AUser) then
  begin AOutput := 'Локальный пользователь не найден: ' + AUser; Exit; end;
  if (APassword = '') or (Length(APassword) > 1024) then
  begin AOutput := 'Пароль должен содержать от 1 до 1024 байт.'; Exit; end;
  if InstallServer(lText) <> 0 then begin AOutput := lText; Exit; end;
  RunProcess('/usr/sbin/groupadd', ['-f', 'sambashare'], '', lText);
  if not RunProcess('/usr/sbin/usermod', ['-a', '-G', 'sambashare', AUser], '', lText) then
  begin AOutput := 'Не удалось добавить пользователя в sambashare: ' + Trim(lText); Exit; end;
  lInput := APassword + LineEnding + APassword + LineEnding;
  if not RunProcess('/usr/bin/smbpasswd', ['-s', '-a', AUser], lInput, lText) then
  begin AOutput := 'Не удалось создать Samba-пользователя: ' + Trim(lText); lInput := ''; Exit; end;
  lInput := '';
  if not SaveUser(AUser, AOutput) then Exit;
  RunProcess('/bin/systemctl', ['reload-or-restart', 'smbd'], '', lText);
  AOutput := 'SMB настроен для пользователя ' + AUser + '.';
  Result := 0;
end;

function SambaUsers(out AOutput: string): Integer;
var lRaw: string; lLines: TStringList; lIndex, lSeparator: Integer;
begin
  Result := 1;
  if not RequireRoot(AOutput) then Exit;
  if not RunProcess('/usr/bin/pdbedit', ['-L'], '', lRaw) then
  begin AOutput := 'Не удалось прочитать пользователей Samba: ' + Trim(lRaw); Exit; end;
  lLines := TStringList.Create;
  try
    lLines.Text := lRaw;
    AOutput := '';
    for lIndex := 0 to lLines.Count - 1 do
    begin
      lSeparator := Pos(':', lLines[lIndex]);
      if lSeparator <= 1 then Continue;
      if AOutput <> '' then AOutput += LineEnding;
      AOutput += Copy(lLines[lIndex], 1, lSeparator - 1);
    end;
  finally lLines.Free; end;
  Result := 0;
end;

function ManagedName(const ALine: string; var AName: string): Boolean;
const CPrefix = '# RECORDERLNX-SHARE-'; CSuffix = '-BEGIN';
var lText: string;
begin
  lText := Trim(ALine);
  Result := (Pos(CPrefix, lText) = 1) and
    (Copy(lText, Length(lText) - Length(CSuffix) + 1, Length(CSuffix)) = CSuffix);
  if Result then
    AName := Copy(lText, Length(CPrefix) + 1,
      Length(lText) - Length(CPrefix) - Length(CSuffix));
end;

function UserAllowed(const ALine, AUser: string): Boolean;
var lItems: TStringList; lIndex: Integer; lValue: string;
begin
  Result := False;
  lValue := Trim(Copy(ALine, Pos('=', ALine) + 1, MaxInt));
  lItems := TStringList.Create;
  try
    ExtractStrings([' ', #9], [], PChar(lValue), lItems);
    for lIndex := 0 to lItems.Count - 1 do
      if SameText(lItems[lIndex], AUser) then Exit(True);
  finally lItems.Free; end;
end;

function AccessList(const AUser: string; out AOutput: string): Integer;
var lLines: TStringList; lIndex: Integer; lName, lPath: string; lAllowed: Boolean;
begin
  Result := 1;
  if not RequireRoot(AOutput) then Exit;
  if not ValidUser(AUser) then begin AOutput := 'Пользователь не найден.'; Exit; end;
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(CSmbConfig);
    AOutput := ''; lName := ''; lPath := ''; lAllowed := False;
    for lIndex := 0 to lLines.Count - 1 do
    begin
      if ManagedName(lLines[lIndex], lName) then
      begin lPath := ''; lAllowed := False; Continue; end;
      if lName = '' then Continue;
      if Pos('path =', LowerCase(Trim(lLines[lIndex]))) = 1 then
        lPath := Trim(Copy(lLines[lIndex], Pos('=', lLines[lIndex]) + 1, MaxInt));
      if Pos('valid users =', LowerCase(Trim(lLines[lIndex]))) = 1 then
        lAllowed := UserAllowed(lLines[lIndex], AUser);
      if Trim(lLines[lIndex]) = '# RECORDERLNX-SHARE-' + lName + '-END' then
      begin
        if AOutput <> '' then AOutput += LineEnding;
        AOutput += lName + #9 + lPath + #9 + BoolToStr(lAllowed, True);
        lName := '';
      end;
    end;
    Result := 0;
  except on E: Exception do AOutput := E.Message; end;
  lLines.Free;
end;

function DesiredShare(const AArgs: TStrings; const AName: string): Boolean;
var lIndex: Integer;
begin
  for lIndex := 2 to AArgs.Count - 1 do
    if SameText(AArgs[lIndex], AName) then Exit(True);
  Result := False;
end;

function UpdatedUsers(const ALine, AUser: string; AAllow: Boolean): string;
var lItems: TStringList; lIndex: Integer; lValue: string;
begin
  lValue := Trim(Copy(ALine, Pos('=', ALine) + 1, MaxInt));
  lItems := TStringList.Create;
  try
    ExtractStrings([' ', #9], [], PChar(lValue), lItems);
    for lIndex := lItems.Count - 1 downto 0 do
      if SameText(lItems[lIndex], AUser) or
         SameText(lItems[lIndex], '__recorderlnx_no_user__') then lItems.Delete(lIndex);
    if AAllow then lItems.Add(AUser);
    if lItems.Count = 0 then lItems.Add('__recorderlnx_no_user__');
    Result := '   valid users = ' + StringReplace(Trim(lItems.Text), LineEnding, ' ', [rfReplaceAll]);
  finally lItems.Free; end;
end;

function ApplyAccess(const AArgs: TStrings; out AOutput: string): Integer;
var lLines, lOld: TStringList; lIndex: Integer; lName, lTemp, lText: string;
begin
  Result := 1;
  if not RequireRoot(AOutput) then Exit;
  if (AArgs.Count < 2) or not ValidUser(AArgs[1]) then
  begin AOutput := 'Укажите существующего пользователя.'; Exit; end;
  lLines := TStringList.Create; lOld := TStringList.Create;
  try
    lLines.LoadFromFile(CSmbConfig); lOld.Assign(lLines); lName := '';
    for lIndex := 0 to lLines.Count - 1 do
    begin
      if ManagedName(lLines[lIndex], lName) then Continue;
      if (lName <> '') and (Pos('valid users =', LowerCase(Trim(lLines[lIndex]))) = 1) then
        lLines[lIndex] := UpdatedUsers(lLines[lIndex], AArgs[1], DesiredShare(AArgs, lName));
      if (lName <> '') and (Trim(lLines[lIndex]) = '# RECORDERLNX-SHARE-' + lName + '-END') then lName := '';
    end;
    lTemp := CSmbConfig + '.linuxsetupmanager.tmp';
    lLines.SaveToFile(lTemp);
    if not RunProcess('/usr/bin/testparm', ['-s', lTemp], '', lText) then
    begin DeleteFile(lTemp); AOutput := 'Ошибка проверки smb.conf: ' + Trim(lText); Exit; end;
    if not RenameFile(lTemp, CSmbConfig) then begin AOutput := 'Не удалось сохранить smb.conf.'; Exit; end;
    {$IFDEF UNIX}fpChmod(CSmbConfig, &644);{$ENDIF}
    if not RunProcess('/bin/systemctl', ['reload', 'smbd'], '', lText) then
    begin lOld.SaveToFile(CSmbConfig); RunProcess('/bin/systemctl', ['reload', 'smbd'], '', lText); AOutput := 'Не удалось перечитать Samba; конфигурация восстановлена.'; Exit; end;
    AOutput := 'Права SMB пользователя ' + AArgs[1] + ' применены.'; Result := 0;
  except on E: Exception do AOutput := E.Message; end;
  lOld.Free; lLines.Free;
end;

function ExecuteSmbSetup(const AArgs: TStrings; const APassword: UTF8String;
  out AOutput: string): Integer;
begin
  try
    if (AArgs.Count = 1) and (AArgs[0] = 'status') then Exit(Status(AOutput));
    if (AArgs.Count = 1) and (AArgs[0] = 'install') then Exit(InstallServer(AOutput));
    if (AArgs.Count = 2) and (AArgs[0] = 'configure') then
      Exit(ConfigureUser(AArgs[1], APassword, AOutput));
    if (AArgs.Count = 1) and (AArgs[0] = 'users') then Exit(SambaUsers(AOutput));
    if (AArgs.Count = 2) and (AArgs[0] = 'access') then Exit(AccessList(AArgs[1], AOutput));
    if (AArgs.Count >= 2) and (AArgs[0] = 'access-apply') then Exit(ApplyAccess(AArgs, AOutput));
    AOutput := 'smb status | install | configure ПОЛЬЗОВАТЕЛЬ --password-stdin';
    Result := 1;
  except
    on E: Exception do
    begin
      AOutput := 'Не удалось прочитать или изменить настройки SMB. ' +
        'Для системных файлов требуются права администратора.';
      Result := 1;
    end;
  end;
end;

end.
