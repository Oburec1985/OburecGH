unit uLinuxSetupManagerPrograms;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes;

function ExecuteProgramsSetup(AArgs: TStrings; out AOutput: string): Integer;

implementation

uses
  SysUtils, Process
  {$IFDEF UNIX}, BaseUnix, UnixType{$ENDIF};

type
  TTargetUser = record
    Name: string;
    Home: string;
    Uid: LongInt;
    Gid: LongInt;
  end;

function RunTool(const AExecutable: string; const AArgs: array of string;
  out AOutput: string): Integer;
var
  lProcess: TProcess;
  lBuffer: array[0..4095] of Byte;
  lCount, lIndex: Integer;
begin
  AOutput := '';
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := AExecutable;
    lProcess.Options := [poUsePipes, poStderrToOutPut];
    for lIndex := Low(AArgs) to High(AArgs) do
      lProcess.Parameters.Add(AArgs[lIndex]);
    lProcess.Execute;
    repeat
      lCount := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
      if lCount > 0 then
        AOutput := AOutput + Copy(PAnsiChar(@lBuffer[0]), 1, lCount);
    until lCount = 0;
    lProcess.WaitOnExit;
    Result := lProcess.ExitStatus;
  finally
    lProcess.Free;
  end;
end;

function ValidName(const AValue: string): Boolean;
var
  lIndex: Integer;
begin
  Result := (AValue <> '') and (AValue[1] in ['a'..'z', '_']);
  if not Result then Exit;
  for lIndex := 2 to Length(AValue) do
    if not (AValue[lIndex] in ['a'..'z', '0'..'9', '_', '-']) and
       not ((lIndex = Length(AValue)) and (AValue[lIndex] = '$')) then
      Exit(False);
end;

procedure RejectLineBreaks(const ACaption, AValue: string);
begin
  if (Pos(#10, AValue) > 0) or (Pos(#13, AValue) > 0) or
     (Pos(#0, AValue) > 0) then
    raise Exception.Create(ACaption + ' не должен содержать управляющие символы.');
end;

function BooleanOption(const AValue: string): Boolean;
begin
  if AValue = 'true' then Exit(True);
  if AValue = 'false' then Exit(False);
  raise Exception.Create('Ожидалось true или false.');
end;

function ResolveUser: TTargetUser;
var
  lCandidate, lLine, lOutput: string;
  lFields: TStringList;
begin
  lCandidate := GetEnvironmentVariable('PKEXEC_UID');
  if lCandidate <> '' then
  begin
    if StrToIntDef(lCandidate, -1) < 0 then
      raise Exception.Create('Некорректный PKEXEC_UID.');
  end
  else
  begin
    lCandidate := GetEnvironmentVariable('SUDO_USER');
    if not ValidName(lCandidate) or (lCandidate = 'root') then
      raise Exception.Create('Не удалось определить пользователя рабочего стола.');
  end;
  if RunTool('getent', ['passwd', lCandidate], lOutput) <> 0 then
    raise Exception.Create('Пользователь не найден: ' + lCandidate);
  lLine := Trim(lOutput);
  lFields := TStringList.Create;
  try
    lFields.StrictDelimiter := True;
    lFields.Delimiter := ':';
    lFields.DelimitedText := lLine;
    if lFields.Count < 7 then
      raise Exception.Create('Некорректная запись passwd.');
    Result.Name := lFields[0];
    Result.Uid := StrToIntDef(lFields[2], -1);
    Result.Gid := StrToIntDef(lFields[3], -1);
    Result.Home := lFields[5];
    if (Result.Uid < 0) or (Result.Gid < 0) or
       (Result.Uid = 0) or (Result.Home = '') or
       (Result.Home[1] <> '/') or not DirectoryExists(Result.Home) then
      raise Exception.Create('Недопустимый домашний каталог пользователя.');
  finally
    lFields.Free;
  end;
end;

{$IFDEF UNIX}
function IsSymlink(const APath: string): Boolean;
var
  lStat: Stat;
begin
  Result := (fpLStat(PChar(APath), lStat) = 0) and
    ((lStat.st_mode and S_IFMT) = S_IFLNK);
end;

procedure EnsureDirectory(const APath: string; const AUser: TTargetUser);
var
  lParent: string;
begin
  if (APath = '') or (APath[1] <> '/') then
    raise Exception.Create('Ожидался абсолютный путь каталога.');
  lParent := ExtractFileDir(ExcludeTrailingPathDelimiter(APath));
  if (lParent <> '') and (lParent <> APath) then
    EnsureDirectory(lParent, AUser);
  if IsSymlink(APath) then
    raise Exception.Create('Символьная ссылка недопустима: ' + APath);
  if DirectoryExists(APath) then Exit;
  if fpMkDir(PChar(APath), &0755) <> 0 then
    raise Exception.Create('Не удалось создать каталог: ' + APath);
  if fpChown(PChar(APath), AUser.Uid, AUser.Gid) <> 0 then
    raise Exception.Create('Не удалось назначить владельца каталога: ' + APath);
end;

procedure WriteEntry(const APath, AContent: string; const AUser: TTargetUser);
var
  lTemp: string;
  lStream: TFileStream;
begin
  if IsSymlink(APath) then
    raise Exception.Create('Запись через символьную ссылку запрещена: ' + APath);
  lTemp := GetTempFileName(ExtractFileDir(APath), '.rls');
  try
    lStream := TFileStream.Create(lTemp, fmOpenWrite or fmShareExclusive);
    try
      if AContent <> '' then lStream.WriteBuffer(AContent[1], Length(AContent));
    finally
      lStream.Free;
    end;
    if (fpChown(PChar(lTemp), AUser.Uid, AUser.Gid) <> 0) or
       (fpChmod(PChar(lTemp), &0755) <> 0) then
      raise Exception.Create('Не удалось назначить владельца или права ярлыка.');
    if fpRename(PChar(lTemp), PChar(APath)) <> 0 then
      raise Exception.Create('Не удалось записать ярлык: ' + APath);
  finally
    if FileExists(lTemp) then DeleteFile(lTemp);
  end;
end;
{$ELSE}
procedure EnsureDirectory(const APath: string; const AUser: TTargetUser);
begin
  raise Exception.Create('Настройка программ доступна только в Linux.');
end;

procedure WriteEntry(const APath, AContent: string; const AUser: TTargetUser);
begin
  raise Exception.Create('Настройка программ доступна только в Linux.');
end;
{$ENDIF}

function DesktopDirectory(const AUser: TTargetUser): string;
var
  lConfig, lValue: string;
  lLines: TStringList;
  lIndex: Integer;
begin
  Result := AUser.Home + '/Desktop';
  if DirectoryExists(AUser.Home + '/Рабочий стол') then
    Result := AUser.Home + '/Рабочий стол';
  lConfig := AUser.Home + '/.config/user-dirs.dirs';
  if not FileExists(lConfig) then Exit;
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(lConfig);
    for lIndex := 0 to lLines.Count - 1 do
    begin
      if Pos('XDG_DESKTOP_DIR=', Trim(lLines[lIndex])) <> 1 then Continue;
      lValue := Trim(Copy(Trim(lLines[lIndex]), 17, MaxInt));
      if (Length(lValue) < 2) or (lValue[1] <> '"') or
         (lValue[Length(lValue)] <> '"') then Continue;
      lValue := Copy(lValue, 2, Length(lValue) - 2);
      if Pos('$HOME/', lValue) = 1 then
        lValue := AUser.Home + Copy(lValue, 6, MaxInt);
      if (lValue <> '') and (lValue[1] = '/') and
         (Pos('..', lValue) = 0) then Result := lValue;
      Break;
    end;
  finally
    lLines.Free;
  end;
end;

function SafeFileName(const AName: string): string;
var
  lIndex: Integer;
begin
  Result := Trim(AName);
  if ExtractFileExt(Result) = '.desktop' then
    Result := ChangeFileExt(Result, '');
  if ExtractFileExt(Result) = '.exe' then
    Result := ChangeFileExt(Result, '');
  for lIndex := 1 to Length(Result) do
    if not (Result[lIndex] in ['a'..'z', 'A'..'Z', '0'..'9', '_', '-',
       '.', ' ', #128..#255]) then Result[lIndex] := '_';
  if (Result = '') or (Result = '.') or (Result = '..') then
    raise Exception.Create('Имя ярлыка не задано.');
end;

function QuoteExec(const AValue: string): string;
var
  lIndex: Integer;
begin
  Result := '"';
  for lIndex := 1 to Length(AValue) do
  begin
    if AValue[lIndex] in ['\', '"', '$', '`'] then Result := Result + '\';
    Result := Result + AValue[lIndex];
  end;
  Result := Result + '"';
end;

procedure ValidateFieldCodes(const AValue: string);
var
  lIndex: Integer;
begin
  lIndex := 1;
  while lIndex <= Length(AValue) do
  begin
    if AValue[lIndex] = '%' then
    begin
      if (lIndex = Length(AValue)) or
         not (AValue[lIndex + 1] in ['%', 'f', 'F', 'u', 'U',
           'i', 'c', 'k']) then
        raise Exception.Create('Недопустимая подстановка % в Exec.');
      Inc(lIndex);
    end;
    Inc(lIndex);
  end;
end;

function BuildExec(const ACommand, AArguments: string;
  AElevated: Boolean): string;
begin
  RejectLineBreaks('Команда Exec', ACommand);
  RejectLineBreaks('Параметры запуска', AArguments);
  if Trim(ACommand) = '' then raise Exception.Create('Команда Exec не задана.');
  ValidateFieldCodes(ACommand);
  ValidateFieldCodes(AArguments);
  if FileExists(ACommand) then
  begin
    if ACommand[1] <> '/' then
      raise Exception.Create('Исполняемый файл должен иметь абсолютный путь.');
    {$IFDEF UNIX}
    if IsSymlink(ACommand) or (fpAccess(PChar(ACommand), X_OK) <> 0) then
      raise Exception.Create('Файл не является исполняемым: ' + ACommand);
    {$ENDIF}
    Result := QuoteExec(ACommand);
  end
  else
  begin
    if (ACommand[1] = '/') and (Pos(' ', ACommand) = 0) then
      raise Exception.Create('Исполняемый файл не найден: ' + ACommand);
    Result := ACommand;
  end;
  if AElevated then Result := '/usr/bin/pkexec ' + Result;
  if AArguments <> '' then Result := Result + ' ' + AArguments;
end;

function EntryContent(const AName, AExec: string): string;
begin
  Result := '[Desktop Entry]' + LineEnding +
    'Type=Application' + LineEnding +
    'Version=1.0' + LineEnding +
    'Name=' + AName + LineEnding +
    'Exec=' + AExec + LineEnding +
    'Terminal=false' + LineEnding +
    'StartupNotify=true' + LineEnding +
    'Categories=Utility;' + LineEnding;
end;

function ApplySettings(AArgs: TStrings; out AOutput: string): Integer;
var
  lUser: TTargetUser;
  lName, lExec, lDirectory, lPath, lContent: string;
  lDesktop, lAutostart, lElevated: Boolean;
begin
  if AArgs.Count <> 7 then
    raise Exception.Create('Использование: apply EXEC ARGS DESKTOP AUTOSTART ELEVATED NAME');
  lDesktop := BooleanOption(AArgs[3]);
  lAutostart := BooleanOption(AArgs[4]);
  lElevated := BooleanOption(AArgs[5]);
  if not (lDesktop or lAutostart) then
    raise Exception.Create('Выберите ярлык или автозапуск.');
  RejectLineBreaks('Имя ярлыка', AArgs[6]);
  lName := SafeFileName(AArgs[6]);
  lExec := BuildExec(AArgs[1], AArgs[2], lElevated);
  lUser := ResolveUser;
  lContent := EntryContent(lName, lExec);
  AOutput := '';
  if lDesktop then
  begin
    lDirectory := DesktopDirectory(lUser);
    EnsureDirectory(lDirectory, lUser);
    lPath := IncludeTrailingPathDelimiter(lDirectory) + lName + '.desktop';
    WriteEntry(lPath, lContent, lUser);
    AOutput := 'Создан ярлык: ' + lPath + LineEnding;
  end;
  if lAutostart then
  begin
    lDirectory := lUser.Home + '/.config/autostart';
    EnsureDirectory(lDirectory, lUser);
    lPath := lDirectory + '/' + lName + '.desktop';
    WriteEntry(lPath, lContent, lUser);
    AOutput := AOutput + 'Добавлен автозапуск: ' + lPath + LineEnding;
  end;
  Result := 0;
end;

function RemoveAutostart(AArgs: TStrings; out AOutput: string): Integer;
var
  lUser: TTargetUser;
  lPath, lName: string;
begin
  if AArgs.Count <> 2 then
    raise Exception.Create('Использование: remove-autostart FILE.desktop');
  lName := AArgs[1];
  if (lName <> ExtractFileName(lName)) or
     (ExtractFileExt(lName) <> '.desktop') or
     (lName = '.desktop') or (Pos('..', lName) > 0) then
    raise Exception.Create('Недопустимое имя записи автозапуска.');
  lUser := ResolveUser;
  lPath := lUser.Home + '/.config/autostart/' + lName;
  {$IFDEF UNIX}
  if IsSymlink(lPath) then
    raise Exception.Create('Запись автозапуска является символьной ссылкой.');
  {$ENDIF}
  if not FileExists(lPath) then
    raise Exception.Create('Запись автозапуска не найдена: ' + lName);
  if not DeleteFile(lPath) then
    raise Exception.Create('Не удалось удалить автозапуск: ' + lName);
  AOutput := 'Удалён автозапуск: ' + lName + LineEnding;
  Result := 0;
end;

function ExecuteProgramsSetup(AArgs: TStrings; out AOutput: string): Integer;
begin
  AOutput := '';
  Result := 1;
  try
    {$IFDEF UNIX}
    if fpGetEUID <> 0 then
      raise Exception.Create('Запустите настройку через pkexec или sudo.');
    {$ELSE}
    raise Exception.Create('Настройка программ доступна только в Linux.');
    {$ENDIF}
    if AArgs.Count = 0 then
      raise Exception.Create('Не указано действие apply или remove-autostart.');
    if AArgs[0] = 'apply' then Result := ApplySettings(AArgs, AOutput)
    else if AArgs[0] = 'remove-autostart' then
      Result := RemoveAutostart(AArgs, AOutput)
    else raise Exception.Create('Неизвестное действие: ' + AArgs[0]);
  except
    on E: Exception do AOutput := 'Ошибка: ' + E.Message;
  end;
end;

end.
