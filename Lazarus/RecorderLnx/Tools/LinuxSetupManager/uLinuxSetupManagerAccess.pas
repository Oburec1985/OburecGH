unit uLinuxSetupManagerAccess;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

function RunAccessAction(const AArgs: array of string): Integer;

implementation

uses
  Classes, SysUtils, Process
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

type
  TAccessConfig = record
    UserName: string;
    Groups: TStringList;
    ReadPaths: TStringList;
    WritePaths: TStringList;
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

function RunTool(const AExecutable: string; const AArgs: array of string;
  out AOutput: string): Integer;
var
  lProcess: TProcess;
  lStream: TMemoryStream;
  lBuffer: array[0..4095] of Byte;
  lCount, lIndex: Integer;
begin
  AOutput := '';
  lProcess := TProcess.Create(nil);
  lStream := TMemoryStream.Create;
  try
    lProcess.Executable := AExecutable;
    lProcess.Options := [poUsePipes, poStderrToOutPut];
    for lIndex := Low(AArgs) to High(AArgs) do
      lProcess.Parameters.Add(AArgs[lIndex]);
    try
      lProcess.Execute;
      repeat
        lCount := lProcess.Output.Read(lBuffer, SizeOf(lBuffer));
        if lCount > 0 then lStream.WriteBuffer(lBuffer, lCount);
      until lCount = 0;
      lProcess.WaitOnExit;
      Result := lProcess.ExitStatus;
      SetLength(AOutput, lStream.Size);
      if lStream.Size > 0 then Move(lStream.Memory^, AOutput[1], lStream.Size);
    except
      on E: Exception do begin AOutput := E.Message; Result := 127; end;
    end;
  finally
    lStream.Free;
    lProcess.Free;
  end;
end;

function ToolSucceeded(const AExecutable: string;
  const AArgs: array of string): Boolean;
var
  lOutput: string;
begin
  Result := RunTool(AExecutable, AArgs, lOutput) = 0;
end;

procedure InitConfig(out AConfig: TAccessConfig);
begin
  AConfig.UserName := '';
  AConfig.Groups := TStringList.Create;
  AConfig.ReadPaths := TStringList.Create;
  AConfig.WritePaths := TStringList.Create;
end;

procedure FreeConfig(var AConfig: TAccessConfig);
begin
  AConfig.Groups.Free;
  AConfig.ReadPaths.Free;
  AConfig.WritePaths.Free;
end;

function ValidPath(const APath: string): Boolean;
var
  lExpanded: string;
begin
  Result := False;
  if (APath = '') or (APath[1] <> '/') or (Pos(#0, APath) <> 0) or
     not DirectoryExists(APath) then Exit;
  lExpanded := ExpandFileName(APath);
  Result := (lExpanded <> '/') and (lExpanded <> '');
end;

procedure AddGroups(const AText: string; AGroups: TStrings);
var
  lParts: TStringList;
  lIndex: Integer;
  lName: string;
begin
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ',';
    lParts.DelimitedText := AText;
    for lIndex := 0 to lParts.Count - 1 do
    begin
      lName := Trim(lParts[lIndex]);
      if lName = '' then Continue;
      if not ValidName(lName) then
        raise Exception.Create('Недопустимое имя группы: ' + lName);
      if AGroups.IndexOf(lName) < 0 then AGroups.Add(lName);
    end;
  finally
    lParts.Free;
  end;
end;

procedure LoadConfig(const AFileName: string; var AConfig: TAccessConfig);
var
  lLines: TStringList;
  lIndex, lPos: Integer;
  lLine, lKey, lValue: string;
begin
  if not FileExists(AFileName) then
    raise Exception.Create('Файл не найден: ' + AFileName);
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(AFileName);
    for lIndex := 0 to lLines.Count - 1 do
    begin
      lLine := Trim(lLines[lIndex]);
      if (lLine = '') or (lLine[1] = '#') then Continue;
      lPos := Pos('=', lLine);
      if lPos = 0 then
        raise Exception.CreateFmt('Строка %d: ожидается KEY=VALUE', [lIndex + 1]);
      lKey := Trim(Copy(lLine, 1, lPos - 1));
      lValue := Trim(Copy(lLine, lPos + 1, MaxInt));
      if lKey = 'USER' then AConfig.UserName := lValue
      else if lKey = 'GROUPS' then AddGroups(lValue, AConfig.Groups)
      else if lKey = 'ACL_READ' then AConfig.ReadPaths.Add(lValue)
      else if lKey = 'ACL_RW' then AConfig.WritePaths.Add(lValue)
      else
        raise Exception.CreateFmt('Строка %d: неизвестный ключ %s',
          [lIndex + 1, lKey]);
    end;
  finally
    lLines.Free;
  end;
end;

procedure ValidateConfig(const AConfig: TAccessConfig);
var
  lIndex: Integer;
begin
  if not ValidName(AConfig.UserName) then
    raise Exception.Create('USER отсутствует или имеет неверный формат');
  if not ToolSucceeded('getent', ['passwd', AConfig.UserName]) then
    raise Exception.Create('Пользователь не найден: ' + AConfig.UserName);
  for lIndex := 0 to AConfig.ReadPaths.Count - 1 do
    if not ValidPath(AConfig.ReadPaths[lIndex]) then
      raise Exception.Create('ACL-каталог не найден или не абсолютный: ' +
        AConfig.ReadPaths[lIndex]);
  for lIndex := 0 to AConfig.WritePaths.Count - 1 do
    if not ValidPath(AConfig.WritePaths[lIndex]) then
      raise Exception.Create('ACL-каталог не найден или не абсолютный: ' +
        AConfig.WritePaths[lIndex]);
end;

procedure PrintPlan(const AConfig: TAccessConfig);
var
  lIndex: Integer;
begin
  for lIndex := 0 to AConfig.Groups.Count - 1 do
    if ToolSucceeded('getent', ['group', AConfig.Groups[lIndex]]) then
      WriteLn(UTF8String('Добавить '), AConfig.UserName,
        UTF8String(' в группу '), AConfig.Groups[lIndex])
    else
      WriteLn(StdErr, UTF8String('Предупреждение: группы '),
        AConfig.Groups[lIndex],
        UTF8String(' нет, она будет пропущена.'));
  for lIndex := 0 to AConfig.ReadPaths.Count - 1 do
    WriteLn('ACL read: ', AConfig.UserName, ' -> ', AConfig.ReadPaths[lIndex],
      ' (recursive + default)');
  for lIndex := 0 to AConfig.WritePaths.Count - 1 do
    WriteLn('ACL rw: ', AConfig.UserName, ' -> ', AConfig.WritePaths[lIndex],
      ' (recursive + default)');
  WriteLn(UTF8String('Владелец и основная группа файлов не изменяются.'));
end;

procedure RequireTool(const AExecutable: string);
var
  lOutput: string;
begin
  if RunTool('which', [AExecutable], lOutput) <> 0 then
    raise Exception.Create('Не установлена системная утилита: ' + AExecutable);
end;

procedure RunRequired(const AExecutable: string; const AArgs: array of string);
var
  lOutput: string;
begin
  if RunTool(AExecutable, AArgs, lOutput) <> 0 then
    raise Exception.Create(AExecutable + ': ' + Trim(lOutput));
end;

procedure SetDefaultAcl(const APath, AEntry: string);
var
  lSearch: TSearchRec;
  lChild: string;
begin
  RunRequired('setfacl', ['-m', 'd:' + AEntry, APath]);
  if FindFirst(IncludeTrailingPathDelimiter(APath) + '*', faAnyFile, lSearch) <> 0 then
    Exit;
  try
    repeat
      if (lSearch.Name = '.') or (lSearch.Name = '..') or
         ((lSearch.Attr and faDirectory) = 0) or
         ((lSearch.Attr and faSymLink) <> 0) then Continue;
      lChild := IncludeTrailingPathDelimiter(APath) + lSearch.Name;
      SetDefaultAcl(lChild, AEntry);
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
end;

procedure ApplyAcl(const AUser, APath: string; AWrite: Boolean);
var
  lEntry: string;
begin
  if AWrite then lEntry := 'u:' + AUser + ':rwX'
  else lEntry := 'u:' + AUser + ':r-X';
  RunRequired('setfacl', ['-R', '-m', lEntry, APath]);
  SetDefaultAcl(APath, lEntry);
end;

procedure ApplyConfig(const AConfig: TAccessConfig);
var
  lIndex: Integer;
begin
  {$IFDEF UNIX}
  if fpGetEUID <> 0 then
    raise Exception.Create('apply нужно запускать с правами root');
  {$ELSE}
  raise Exception.Create('Изменение прав доступно только в Linux');
  {$ENDIF}
  RequireTool('usermod');
  if (AConfig.ReadPaths.Count + AConfig.WritePaths.Count) > 0 then
    RequireTool('setfacl');
  for lIndex := 0 to AConfig.Groups.Count - 1 do
    if ToolSucceeded('getent', ['group', AConfig.Groups[lIndex]]) then
      RunRequired('usermod', ['-aG', AConfig.Groups[lIndex], AConfig.UserName]);
  for lIndex := 0 to AConfig.ReadPaths.Count - 1 do
    ApplyAcl(AConfig.UserName, AConfig.ReadPaths[lIndex], False);
  for lIndex := 0 to AConfig.WritePaths.Count - 1 do
    ApplyAcl(AConfig.UserName, AConfig.WritePaths[lIndex], True);
  WriteLn(UTF8String('Готово. Членство в группах применится при следующем входе пользователя.'));
end;

function GetOption(const AArgs: array of string; const AName: string): string;
var
  lIndex: Integer;
begin
  Result := '';
  lIndex := 1;
  while lIndex <= High(AArgs) do
  begin
    if (AArgs[lIndex] = AName) and (lIndex < High(AArgs)) then
      Exit(AArgs[lIndex + 1]);
    Inc(lIndex);
  end;
end;

procedure ListUsers;
var
  lOutput, lLine, lUid: string;
  lLines, lFields: TStringList;
  lIndex: Integer;
begin
  if RunTool('getent', ['passwd'], lOutput) <> 0 then
    raise Exception.Create('Не удалось получить список пользователей: ' + lOutput);
  lLines := TStringList.Create;
  lFields := TStringList.Create;
  try
    lLines.Text := lOutput;
    lFields.StrictDelimiter := True;
    lFields.Delimiter := ':';
    for lIndex := 0 to lLines.Count - 1 do
    begin
      lLine := lLines[lIndex];
      lFields.DelimitedText := lLine;
      if lFields.Count < 7 then Continue;
      lUid := lFields[2];
      if (StrToIntDef(lUid, -1) < 1000) or (lFields[0] = 'nobody') then Continue;
      WriteLn(lFields[0], #9, lFields[5], #9, lFields[6]);
    end;
  finally
    lFields.Free;
    lLines.Free;
  end;
end;

procedure ShowUser(const AArgs: array of string);
var
  lUser, lPath, lOutput: string;
  lIndex: Integer;
begin
  lUser := GetOption(AArgs, '--user');
  if not ValidName(lUser) then
    raise Exception.Create('Укажите --user USER');
  if RunTool('id', [lUser], lOutput) <> 0 then
    raise Exception.Create('Пользователь не найден: ' + lUser);
  Write(lOutput);
  for lIndex := 1 to High(AArgs) do
    if (AArgs[lIndex] = '--path') and (lIndex < High(AArgs)) then
    begin
      lPath := AArgs[lIndex + 1];
      if not ValidPath(lPath) then
        raise Exception.Create('Каталог не найден: ' + lPath);
      WriteLn; WriteLn('[', lPath, ']');
      if RunTool('getfacl', ['-p', lPath], lOutput) <> 0 then
        RunTool('ls', ['-ld', lPath], lOutput);
      Write(lOutput);
    end;
end;

procedure ShowUserState(const AArgs: array of string);
var
  lUser, lOutput: string;
begin
  lUser := GetOption(AArgs, '--user');
  if not ValidName(lUser) then
    raise Exception.Create('Укажите --user USER');
  if RunTool('id', ['-nG', lUser], lOutput) <> 0 then
    raise Exception.Create('Пользователь не найден: ' + lUser);
  WriteLn('groups=', Trim(lOutput));
end;

function RunAccessAction(const AArgs: array of string): Integer;
var
  lConfig: TAccessConfig;
  lAction, lFileName: string;
begin
  Result := 1;
  if Length(AArgs) = 0 then Exit;
  lAction := AArgs[0];
  try
    if lAction = 'list-users' then ListUsers
    else if lAction = 'show' then ShowUser(AArgs)
    else if lAction = 'show-state' then ShowUserState(AArgs)
    else if (lAction = 'validate') or (lAction = 'plan') or
            (lAction = 'apply') then
    begin
      lFileName := GetOption(AArgs, '--config');
      if lFileName = '' then
        raise Exception.Create('Укажите --config FILE');
      InitConfig(lConfig);
      try
        LoadConfig(lFileName, lConfig);
        ValidateConfig(lConfig);
        if lAction = 'validate' then
          WriteLn(UTF8String('Конфигурация корректна.'))
        else begin
          PrintPlan(lConfig);
          if lAction = 'apply' then ApplyConfig(lConfig);
        end;
      finally
        FreeConfig(lConfig);
      end;
    end
    else raise Exception.Create('Неизвестная команда доступа: ' + lAction);
    Result := 0;
  except
    on E: Exception do WriteLn(StdErr, UTF8String('Ошибка: '), E.Message);
  end;
end;

end.
