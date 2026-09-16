unit uLinuxSetupManagerDisks;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses Classes, SysUtils;

// The destructive operation is deliberately unavailable until the application
// can prove the entire block-device ancestry is not used by the running OS.
function ExecuteDiskSetup(AArgs: TStrings; out AOutput: string): Integer;

implementation

uses Process, fpjson, jsonparser
  {$IFDEF UNIX}, BaseUnix{$ENDIF};

const
  CFstab = '/etc/fstab';
  CMarker = 'linuxsetupmanager-managed';
  CProcessTimeoutMs = 90000;
  COptionalDiskFields: array[0..8] of string =
    ('model', 'serial', 'fstype', 'uuid', 'label', 'partlabel',
     'fsused', 'fsavail', 'fsuse%');

function RunProgram(const AProgram: string; AArgs: TStrings;
  out AOutput: string): Boolean;
var
  lProcess: TProcess;
  lBuffer: array[0..4095] of Byte;
  lCount, lIndex, lAvailable: Integer;
  lChunk: string;
  lStarted: QWord;
begin
  Result := False;
  AOutput := '';
  lProcess := TProcess.Create(nil);
  try
    lProcess.Executable := AProgram;
    for lIndex := 0 to AArgs.Count - 1 do
      lProcess.Parameters.Add(AArgs[lIndex]);
    lProcess.Options := [poUsePipes, poStderrToOutput];
    try
      lProcess.Execute;
      lProcess.CloseInput;
      lStarted := GetTickCount64;
      repeat
        lAvailable := lProcess.Output.NumBytesAvailable;
        while lAvailable > 0 do
        begin
          if lAvailable > SizeOf(lBuffer) then lAvailable := SizeOf(lBuffer);
          lCount := lProcess.Output.Read(lBuffer, lAvailable);
          if lCount <= 0 then Break;
          SetString(lChunk, PChar(@lBuffer[0]), lCount);
          AOutput := AOutput + lChunk;
          lAvailable := lProcess.Output.NumBytesAvailable;
        end;
        // A filesystem helper can daemonize and inherit stdout. EOF then never
        // arrives, although the command whose status matters has already exited.
        if not lProcess.Running then Break;
        if GetTickCount64 - lStarted >= CProcessTimeoutMs then
        begin
          lProcess.Terminate(0);
          AOutput := 'Превышено время выполнения команды ' + AProgram + '.' +
            LineEnding + AOutput;
          Exit;
        end;
        Sleep(20);
      until False;
      Result := lProcess.ExitStatus = 0;
      if not Result then
        AOutput := 'Код ' + IntToStr(lProcess.ExitStatus) + LineEnding + AOutput;
    except
      on E: Exception do AOutput := E.Message;
    end;
  finally
    lProcess.Free;
  end;
end;

function RunWith(const AProgram: string; const AValues: array of string;
  out AOutput: string): Boolean;
var
  lArgs: TStringList;
  lIndex: Integer;
begin
  lArgs := TStringList.Create;
  try
    for lIndex := Low(AValues) to High(AValues) do lArgs.Add(AValues[lIndex]);
    Result := RunProgram(AProgram, lArgs, AOutput);
  finally
    lArgs.Free;
  end;
end;

function RunProbeCommand(const AProgram: string; const AValues: array of string;
  out AOutput: string): Boolean;
var
  lArgs: TStringList;
  lIndex: Integer;
begin
  // A damaged or very large filesystem must not hold the inventory forever.
  lArgs := TStringList.Create;
  try
    lArgs.Add('--signal=TERM');
    lArgs.Add('--kill-after=2s');
    lArgs.Add('8s');
    lArgs.Add(AProgram);
    for lIndex := Low(AValues) to High(AValues) do
      lArgs.Add(AValues[lIndex]);
    Result := RunProgram('timeout', lArgs, AOutput);
    if (not Result) and (Pos('Код 124', AOutput) = 1) then
      AOutput := 'Превышено время безопасной проверки (' + AProgram + ').';
  finally
    lArgs.Free;
  end;
end;

function ValidDevice(const APath: string): Boolean; forward;

function JsonText(AObject: TJSONObject; const AName: string): string;
var lValue: TJSONData;
begin
  Result := '';
  lValue := AObject.Find(AName);
  if (lValue <> nil) and (lValue.JSONType <> jtNull) then
    Result := lValue.AsString;
end;

function FirstMountpoint(AObject: TJSONObject): string;
var
  lValues: TJSONData;
  lIndex: Integer;
begin
  Result := '';
  lValues := AObject.Find('mountpoints');
  if (lValues = nil) or (lValues.JSONType <> jtArray) then Exit;
  for lIndex := 0 to TJSONArray(lValues).Count - 1 do
    if (TJSONArray(lValues).Items[lIndex].JSONType <> jtNull) and
      (TJSONArray(lValues).Items[lIndex].AsString <> '') then
      Exit(TJSONArray(lValues).Items[lIndex].AsString);
end;

procedure NormalizeDiskNode(AObject: TJSONObject);
var
  lName, lMount, lStatus: string;
  lValues, lChildren: TJSONData;
  lIndex: Integer;
begin
  for lIndex := Low(COptionalDiskFields) to High(COptionalDiskFields) do
  begin
    lName := COptionalDiskFields[lIndex];
    lValues := AObject.Find(lName);
    if (lValues = nil) or (lValues.JSONType = jtNull) then
  begin
      if lValues <> nil then AObject.Delete(lName);
      AObject.Add(lName, '');
    end;
  end;
  lMount := FirstMountpoint(AObject);
  lValues := AObject.Find('mountpoints');
  if lValues <> nil then AObject.Delete('mountpoints');
  AObject.Add('mountpoint', lMount);
  if (lMount <> '') and (JsonText(AObject, 'fsused') <> '') and
    (JsonText(AObject, 'fsavail') <> '') then
    lStatus := 'mounted'
  else if lMount <> '' then
    lStatus := 'mounted-unknown'
  else if JsonText(AObject, 'fstype') <> '' then
    lStatus := 'unmounted-unknown'
  else
    lStatus := 'no-filesystem';
  AObject.Add('usage_status', lStatus);
  lChildren := AObject.Find('children');
  if (lChildren <> nil) and (lChildren.JSONType = jtArray) then
    for lIndex := 0 to TJSONArray(lChildren).Count - 1 do
      if TJSONArray(lChildren).Items[lIndex].JSONType = jtObject then
        NormalizeDiskNode(TJSONObject(TJSONArray(lChildren).Items[lIndex]));
end;

function DiskInventory(out AOutput: string): Boolean;
var
  lRaw: string;
  lRoot, lNodes: TJSONData;
  lIndex: Integer;
begin
  Result := RunWith('lsblk', ['-J', '--tree', '-b', '-o',
    'PATH,TYPE,SIZE,MODEL,SERIAL,FSTYPE,UUID,LABEL,PARTLABEL,' +
    'MOUNTPOINTS,FSUSED,FSAVAIL,FSUSE%'], lRaw);
  if not Result then
  begin AOutput := lRaw; Exit; end;
  lRoot := nil;
  try
    lRoot := GetJSON(lRaw);
    if lRoot.JSONType <> jtObject then raise Exception.Create('Некорректный ответ lsblk.');
    lNodes := TJSONObject(lRoot).Find('blockdevices');
    if (lNodes = nil) or (lNodes.JSONType <> jtArray) then
      raise Exception.Create('В ответе lsblk нет списка дисков.');
    for lIndex := 0 to TJSONArray(lNodes).Count - 1 do
      if TJSONArray(lNodes).Items[lIndex].JSONType = jtObject then
        NormalizeDiskNode(TJSONObject(TJSONArray(lNodes).Items[lIndex]));
    AOutput := lRoot.AsJSON;
  except
    on E: Exception do
    begin
      AOutput := 'Не удалось разобрать список дисков: ' + E.Message;
      Result := False;
    end;
  end;
  lRoot.Free;
end;

function CheckExistingDevice(const ADevice: string;
  out AUUID, AFstype, AParent, AError: string;
  AAllowMounted: Boolean = False): Boolean; forward;

function UsageFields(const AText: string; out AUsed, AFree: string): Boolean;
var
  lTokens: TStringList;
  lText: string;
  lIndex: Integer;
begin
  Result := False;
  AUsed := '';
  AFree := '';
  lText := Trim(AText);
  lTokens := TStringList.Create;
  try
    ExtractStrings([' ', #9, #10, #13], [], PChar(lText), lTokens);
    if lTokens.Count < 4 then Exit;
    AUsed := lTokens[lTokens.Count - 2];
    AFree := lTokens[lTokens.Count - 1];
    for lIndex := 1 to Length(AUsed) do
      if not (AUsed[lIndex] in ['0'..'9']) then Exit;
    for lIndex := 1 to Length(AFree) do
      if not (AFree[lIndex] in ['0'..'9']) then Exit;
    Result := (AUsed <> '') and (AFree <> '');
  finally
    lTokens.Free;
  end;
end;

function ProbeUsage(AObject: TJSONObject; out AError: string): Boolean;
var
  lDevice, lUuid, lType, lParent, lDir, lInfo, lUsed, lFree,
  lCleanupError: string;
  lMounted: Boolean;
begin
  Result := False;
  AError := '';
  lDevice := JsonText(AObject, 'path');
  if not ValidDevice(lDevice) or
    not CheckExistingDevice(lDevice, lUuid, lType, lParent, AError) then Exit;
  // Journaled native filesystems may replay a log even when mounted ro.
  if (lType <> 'ntfs') and (lType <> 'vfat') and (lType <> 'exfat') then
  begin AError := 'Тип ФС не разрешён для автоматического просмотра.'; Exit; end;
  {$IFDEF UNIX}
  lDir := '/run/linuxsetupmanager-usage-' + IntToStr(fpGetPID) +
    '-' + IntToStr(Random(1000000000));
  {$ELSE}
  lDir := '';
  {$ENDIF}
  if not CreateDir(lDir) then
  begin AError := 'Не удалось создать временную точку монтирования.'; Exit; end;
  lMounted := False;
  try
    lMounted := RunProbeCommand('mount', ['-o', 'ro,nosuid,nodev,noexec',
      lDevice, lDir], AError);
    if not lMounted then Exit;
    if not RunProbeCommand('df', ['-B1', '--output=used,avail', lDir], lInfo) then
    begin AError := lInfo; Exit; end;
    if not UsageFields(lInfo, lUsed, lFree) then
    begin AError := 'Не удалось прочитать занятое и свободное место.'; Exit; end;
    AObject.Strings['fsused'] := lUsed;
    AObject.Strings['fsavail'] := lFree;
    AObject.Strings['usage_status'] := 'probed-readonly';
    Result := True;
  finally
    if not lMounted then
      lMounted := RunWith('mountpoint', ['-q', lDir], lCleanupError);
    if lMounted and not RunProbeCommand('umount', [lDir], lCleanupError) then
    begin
      AError := 'ВНИМАНИЕ: временный том остался смонтирован: ' + lDir +
        '. ' + lCleanupError;
      AObject.Strings['fsused'] := '';
      AObject.Strings['fsavail'] := '';
      Result := False;
    end
    else RemoveDir(lDir);
  end;
end;

procedure ProbeDiskNodes(AArray: TJSONArray);
var
  lNode, lChildren: TJSONData;
  lError: string;
  lIndex: Integer;
begin
  for lIndex := 0 to AArray.Count - 1 do
  begin
    lNode := AArray.Items[lIndex];
    if lNode.JSONType <> jtObject then Continue;
    if JsonText(TJSONObject(lNode), 'usage_status') = 'unmounted-unknown' then
    begin
      if not ProbeUsage(TJSONObject(lNode), lError) then
      begin
        if lError = '' then lError := 'Устройство не прошло проверку безопасности.';
        TJSONObject(lNode).Add('usage_error', lError);
        TJSONObject(lNode).Strings['usage_status'] := 'unmounted-unknown';
      end;
    end;
    lChildren := TJSONObject(lNode).Find('children');
    if (lChildren <> nil) and (lChildren.JSONType = jtArray) then
      ProbeDiskNodes(TJSONArray(lChildren));
  end;
end;

function InventoryWithUsage(out AOutput: string): Boolean;
var
  lRoot, lNodes: TJSONData;
begin
  Result := DiskInventory(AOutput);
  if not Result then Exit;
  lRoot := nil;
  try
    lRoot := GetJSON(AOutput);
    lNodes := TJSONObject(lRoot).Find('blockdevices');
    ProbeDiskNodes(TJSONArray(lNodes));
    AOutput := lRoot.AsJSON;
  except
    on E: Exception do
    begin AOutput := 'Не удалось проверить занятое место: ' + E.Message; Result := False; end;
  end;
  lRoot.Free;
end;

function ValidDevice(const APath: string): Boolean;
begin
  Result := (Copy(APath, 1, 5) = '/dev/') and
    (Pos('..', APath) = 0) and (Pos(#10, APath) = 0) and
    (Pos(#13, APath) = 0);
end;

function OptionValue(AArgs: TStrings; const AName: string): string;
var lIndex: Integer;
begin
  Result := '';
  for lIndex := 2 to AArgs.Count - 2 do
    if AArgs[lIndex] = AName then Exit(AArgs[lIndex + 1]);
end;

function ValidMountPath(const APath: string): Boolean;
var
  lIndex, lNextSlash: Integer;
  lTop: string;
begin
  Result := False;
  if (Length(APath) < 2) or (APath[1] <> '/') or
    (Pos('..', APath) > 0) or (Pos('/./', APath) > 0) or
    (Copy(APath, Length(APath) - 1, 2) = '/.') or
    (Pos('//', APath) > 0) or
    (APath[Length(APath)] = '/') then Exit;
  for lIndex := 2 to Length(APath) do
    if not (APath[lIndex] in ['A'..'Z','a'..'z','0'..'9','_','-','/','.']) then Exit;
  lNextSlash := Pos('/', Copy(APath, 2, MaxInt));
  if lNextSlash = 0 then lTop := Copy(APath, 2, MaxInt)
  else lTop := Copy(APath, 2, lNextSlash - 1);
  if (lTop = '') or (lTop = '.') or
    (Pos('|' + LowerCase(lTop) + '|',
      '|bin|boot|dev|etc|lib|lib64|lost+found|opt|proc|root|run|sbin|srv|sys|tmp|usr|var|') > 0) then Exit;
  if ((lTop = 'home') or (lTop = 'mnt') or (lTop = 'media')) and
    (lNextSlash = 0) then Exit;
  if (lTop = 'home') and
    (Pos('/', Copy(APath, lNextSlash + 2, MaxInt)) = 0) then Exit;
  if ((lTop = 'home') or (lTop = 'mnt') or (lTop = 'media')) and
    (lNextSlash > 0) and (lNextSlash + 1 >= Length(APath)) then Exit;
  if (lTop <> 'home') and (lTop <> 'mnt') and (lTop <> 'media') and
    (lNextSlash > 0) then Exit;
  Result := True;
end;

function SafeMountDestination(const APath: string; out AError: string): Boolean;
var
  lIndex: Integer;
  lPart, lOutput: string;
begin
  Result := False;
  if not ValidMountPath(APath) then
  begin AError := 'Недопустимая точка подключения.'; Exit; end;
  for lIndex := 2 to Length(APath) + 1 do
    if (lIndex > Length(APath)) or (APath[lIndex] = '/') then
    begin
      lPart := Copy(APath, 1, lIndex - 1);
      if RunWith('test', ['-L', lPart], lOutput) then
      begin AError := 'Символические ссылки в пути подключения запрещены: ' + lPart; Exit; end;
      if FileExists(lPart) and not DirectoryExists(lPart) then
      begin AError := 'Компонент пути не является каталогом: ' + lPart; Exit; end;
    end;
  AError := '';
  Result := True;
end;

function FirstLine(const AText: string): string;
var lPos: Integer;
begin
  Result := Trim(AText);
  lPos := Pos(LineEnding, Result);
  if lPos > 0 then Result := Copy(Result, 1, lPos - 1);
end;

function CheckExistingDevice(const ADevice: string;
  out AUUID, AFstype, AParent, AError: string;
  AAllowMounted: Boolean): Boolean;
var
  lValue, lRoot, lTypes, lMounts, lSwap: string;
begin
  Result := False;
  AError := '';
  if not RunWith('lsblk', ['-dnro', 'TYPE', ADevice], lValue) or
    (Trim(lValue) <> 'part') then
  begin AError := 'Разрешён только существующий раздел (TYPE=part).'; Exit; end;
  if not RunWith('lsblk', ['-nrpo', 'TYPE', ADevice], lTypes) or
    (Trim(lTypes) <> 'part') then
  begin AError := 'У раздела обнаружены дочерние тома (LVM/RAID/crypt).'; Exit; end;
  if not RunWith('lsblk', ['-dnro', 'PKNAME', ADevice], lValue) then Exit;
  AParent := '/dev/' + Trim(lValue);
  if not ValidDevice(AParent) or (AParent = '/dev/') then
  begin AError := 'Не удалось определить физический диск.'; Exit; end;
  if not RunWith('lsblk', ['-nrpo', 'MOUNTPOINTS', AParent], lMounts) then Exit;
  if (not AAllowMounted) and (Trim(lMounts) <> '') then
  begin AError := 'На физическом диске есть смонтированные разделы.'; Exit; end;
  if not RunWith('findmnt', ['-n', '-o', 'SOURCE', '--target', '/'], lRoot) or
    not ValidDevice(FirstLine(lRoot)) then
  begin AError := 'Не удалось доказать, где находится корневая ФС.'; Exit; end;
  if not RunWith('lsblk', ['-s', '-nrpo', 'PATH', FirstLine(lRoot)], lValue) then Exit;
  if Pos(AParent + LineEnding, lValue + LineEnding) > 0 then
  begin AError := 'Физический диск содержит корневую ФС.'; Exit; end;
  if RunWith('swapon', ['--noheadings', '--raw', '--output', 'NAME'], lSwap) and
    (Pos(ADevice + LineEnding, lSwap + LineEnding) > 0) then
  begin AError := 'Раздел используется как swap.'; Exit; end;
  if not RunWith('blkid', ['-s', 'UUID', '-o', 'value', ADevice], lValue) then Exit;
  AUUID := FirstLine(lValue);
  if not RunWith('blkid', ['-s', 'TYPE', '-o', 'value', ADevice], lValue) then Exit;
  AFstype := FirstLine(lValue);
  if (AUUID = '') or (AFstype = '') then
  begin AError := 'У раздела нет обнаруженной файловой системы/UUID.'; Exit; end;
  Result := True;
end;

function ReadFstab: string;
var lLines: TStringList;
begin
  Result := '';
  lLines := TStringList.Create;
  try
    lLines.LoadFromFile(CFstab);
    Result := lLines.Text;
  finally
    lLines.Free;
  end;
end;

function SaveFstab(const AText: string; out AError: string): Boolean;
var
  lLines: TStringList;
  lBackup, lOutput: string;
begin
  Result := False;
  lBackup := CFstab + '.linuxsetupmanager-' + FormatDateTime('yyyymmddhhnnss', Now) + '.bak';
  if not RunWith('cp', ['-a', CFstab, lBackup], lOutput) then
  begin AError := 'Не удалось создать копию /etc/fstab.'; Exit; end;
  lLines := TStringList.Create;
  try
    lLines.Text := AText;
    lLines.SaveToFile(CFstab);
    Result := True;
    AError := 'Копия /etc/fstab: ' + lBackup;
  finally
    lLines.Free;
  end;
end;

function ManagedLine(const ADevice, AUUID: string; out ALine, AMount: string): Boolean;
var
  lRows, lFields: TStringList;
  lIndex: Integer;
begin
  Result := False;
  ALine := '';
  AMount := '';
  lRows := TStringList.Create;
  lFields := TStringList.Create;
  try
    lRows.Text := ReadFstab;
    lFields.Delimiter := ' ';
    lFields.StrictDelimiter := True;
    for lIndex := 0 to lRows.Count - 1 do
      if (Pos('UUID=' + AUUID + ' ', lRows[lIndex]) = 1) and
        (Pos('# ' + CMarker + ' device=' + ADevice, lRows[lIndex]) > 0) then
      begin
        ALine := lRows[lIndex];
        lFields.DelimitedText := ALine;
        if lFields.Count < 4 then Exit;
        AMount := lFields[1];
        Result := ValidMountPath(AMount);
        Exit;
      end;
  finally
    lFields.Free;
    lRows.Free;
  end;
end;

function DirectoryEmpty(const APath: string): Boolean;
var lSearch: TSearchRec;
begin
  Result := True;
  if not DirectoryExists(APath) then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(APath) + '*', faAnyFile, lSearch) <> 0 then Exit;
  try
    repeat
      if (lSearch.Name <> '.') and (lSearch.Name <> '..') then
        Exit(False);
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
end;

function PreviewDevice(const ADevice: string; out AOutput: string): Integer;
var
  lUuid, lType, lParent, lError, lDir, lInfo, lResult: string;
  lMounted: Boolean;
begin
  Result := 1;
  if not CheckExistingDevice(ADevice, lUuid, lType, lParent, lError) then
  begin AOutput := lError; Exit; end;
  {$IFDEF UNIX}
  lDir := '/run/linuxsetupmanager-preview-' + IntToStr(fpGetPID) +
    '-' + FormatDateTime('hhnnss', Now);
  {$ELSE}
  lDir := '';
  {$ENDIF}
  if not CreateDir(lDir) then
  begin AOutput := 'Не удалось создать временную точку монтирования.'; Exit; end;
  lMounted := False;
  try
    lMounted := RunWith('mount', ['-o', 'ro,nosuid,nodev,noexec',
      ADevice, lDir], lError);
    if not lMounted then
    begin AOutput := 'Монтирование только для чтения не удалось: ' + lError; Exit; end;
    RunWith('df', ['-hT', lDir], lInfo);
    RunWith('ls', ['-lah', lDir], lResult);
    AOutput := 'Устройство: ' + ADevice + '  UUID=' + lUuid +
      '  ФС=' + lType + LineEnding + lInfo + LineEnding + lResult;
    Result := 0;
  finally
    if lMounted then
      if not RunWith('umount', [lDir], lError) then
      begin
        AOutput := AOutput + LineEnding + 'ОШИБКА: временный том остался смонтирован: ' + lDir;
        Result := 1;
      end;
    if (not lMounted) or (Result = 0) then RemoveDir(lDir);
  end;
end;

function NumericId(const AText: string; out AValue: Integer): Boolean;
var lIndex: Integer;
begin
  Result := False;
  if AText = '' then Exit;
  for lIndex := 1 to Length(AText) do
    if not (AText[lIndex] in ['0'..'9']) then Exit;
  Result := TryStrToInt(AText, AValue);
end;

function OwnerMountOptions(const AArgs: TStrings; out AOptions,
  AError: string): Boolean;
var
  lUser, lUidText, lGidText, lCallerText: string;
  lUid, lGid, lCaller, lIndex: Integer;
begin
  Result := False;
  lUser := OptionValue(AArgs, '--owner-user');
  if (lUser = '') or not (lUser[1] in ['a'..'z', 'A'..'Z', '_']) then
  begin AError := 'Для записи на NTFS укажите существующего пользователя --owner-user.'; Exit; end;
  for lIndex := 2 to Length(lUser) do
    if not (lUser[lIndex] in ['a'..'z', 'A'..'Z', '0'..'9', '_', '-', '.']) then
    begin AError := 'Недопустимое имя пользователя.'; Exit; end;
  if not RunWith('id', ['-u', lUser], lUidText) or
    not RunWith('id', ['-g', lUser], lGidText) or
    not NumericId(FirstLine(lUidText), lUid) or
    not NumericId(FirstLine(lGidText), lGid) or (lUid = 0) then
  begin AError := 'Не удалось подтвердить обычного пользователя и его UID/GID.'; Exit; end;
  lCallerText := GetEnvironmentVariable('PKEXEC_UID');
  if lCallerText = '' then lCallerText := GetEnvironmentVariable('SUDO_UID');
  if (lCallerText <> '') and
    (not NumericId(lCallerText, lCaller) or (lCaller <> lUid)) then
  begin AError := 'Выбранный пользователь не совпадает с вызвавшим администраторскую команду.'; Exit; end;
  AOptions := ',uid=' + IntToStr(lUid) + ',gid=' + IntToStr(lGid) + ',umask=0002';
  AError := '';
  Result := True;
end;

function DiskMountOptions(const AArgs: TStrings; const AFstype,
  AReadOnly: string; out AOptions, AError: string): Boolean;
var lOwnerOptions: string;
begin
  Result := False;
  AOptions := 'defaults,nosuid,nodev,nofail,x-systemd.automount';
  if AReadOnly = 'yes' then AOptions := AOptions + ',ro'
  else if SameText(AFstype, 'ntfs') or SameText(AFstype, 'ntfs3') then
  begin
    if not OwnerMountOptions(AArgs, lOwnerOptions, AError) then Exit;
    AOptions := AOptions + lOwnerOptions;
  end;
  Result := True;
end;

function MountOptionPresent(const AOptions, AOption: string): Boolean; forward;

function NtfsMountedReadOnly(const ADevice, AFstype, APoint: string): Boolean;
var lOptions, lTrigger: string;
begin
  Result := False;
  if not SameText(AFstype, 'ntfs') then Exit;
  // systemd.automount may exist before the actual NTFS mount is activated.
  RunWith('stat', ['-c', '%F', APoint + '/.'], lTrigger);
  Result :=
    RunWith('findmnt', ['-rn', '-o', 'OPTIONS', '--source', ADevice], lOptions) and
    MountOptionPresent(FirstLine(lOptions), 'ro');
end;

function MountLayersBelongToDevice(const APoint, ADevice: string;
  AManagedHere: Boolean; out AForeign: string): Boolean;
var
  lSources, lAutofs: string;
  lRows: TStringList;
  lIndex: Integer;
begin
  Result := False;
  AForeign := '';
  if not RunWith('findmnt', ['-rn', '-o', 'SOURCE', '--mountpoint', APoint], lSources) then
    Exit(True);
  RunWith('findmnt', ['-rn', '-t', 'autofs', '-o', 'SOURCE', '--mountpoint', APoint], lAutofs);
  lRows := TStringList.Create;
  try
    lRows.Text := lSources;
    for lIndex := 0 to lRows.Count - 1 do
    begin
      AForeign := Trim(lRows[lIndex]);
      if AForeign = ADevice then
      begin
        if AManagedHere then Continue;
      end
      else if AManagedHere and (AForeign = 'systemd-1') and
        (Pos('systemd-1', lAutofs) > 0) then Continue;
      Exit;
    end;
    AForeign := '';
    Result := True;
  finally
    lRows.Free;
  end;
end;

function MountExisting(AArgs: TStrings; const ADevice: string;
  out AOutput: string): Integer;
var
  lUuid, lType, lParent, lError, lPoint, lReadOnly, lOptions, lEntry,
  lFstab, lNewFstab, lCheck, lOldLine, lOldPoint, lCurrentMount,
  lExistingTarget, lRollback: string;
  lManaged, lWasMounted: Boolean;
begin
  Result := 1;
  if not CheckExistingDevice(ADevice, lUuid, lType, lParent, lError, True) then
  begin AOutput := lError; Exit; end;
  lPoint := OptionValue(AArgs, '--mount-point');
  lReadOnly := OptionValue(AArgs, '--read-only');
  if not SafeMountDestination(lPoint, lError) or
    not ((lReadOnly = 'yes') or (lReadOnly = 'no')) then
  begin AOutput := lError + ' Укажите --read-only yes|no.'; Exit; end;
  if (OptionValue(AArgs, '--confirm-device') <> ADevice) or
    (OptionValue(AArgs, '--confirm-uuid') <> lUuid) then
  begin AOutput := 'Нужно подтвердить точные DEVICE и UUID.'; Exit; end;
  if not DiskMountOptions(AArgs, lType, lReadOnly, lOptions, lError) then
  begin AOutput := lError; Exit; end;
  lManaged := ManagedLine(ADevice, lUuid, lOldLine, lOldPoint);
  if (not lManaged or (lOldPoint <> lPoint)) and
    not DirectoryEmpty(lPoint) then
  begin AOutput := 'Каталог назначения не пуст.'; Exit; end;
  lFstab := ReadFstab;
  lNewFstab := lFstab;
  if lManaged then
    lNewFstab := StringReplace(lNewFstab, lOldLine + LineEnding, '', [])
  else if Pos('UUID=' + lUuid + ' ', lFstab) > 0 then
  begin AOutput := 'Устройство уже есть в /etc/fstab, но запись не принадлежит утилите.'; Exit; end;
  if Pos(' ' + lPoint + ' ', lNewFstab) > 0 then
  begin
    AOutput := 'Имя занято: ' + lPoint +
      ' уже указано в /etc/fstab. Выберите другой каталог.';
    Exit;
  end;
  lCurrentMount := '';
  if RunWith('findmnt', ['-rn', '-o', 'TARGET', '--source', ADevice], lCheck) then
    lCurrentMount := Trim(lCheck);
  if (lCurrentMount <> '') and
    (not lManaged or (lCurrentMount <> lOldPoint)) then
  begin AOutput := 'Раздел уже подключён вне управляемой точки: ' + lCurrentMount; Exit; end;
  lWasMounted := lManaged and (lCurrentMount = lOldPoint);
  if not MountLayersBelongToDevice(lPoint, ADevice,
    lManaged and (lOldPoint = lPoint), lExistingTarget) then
  begin
    AOutput := 'Точка уже занята другим подключением: ' + lExistingTarget;
    Exit;
  end;
  if lWasMounted and (lOldPoint = lPoint) and (lReadOnly = 'no') and
    NtfsMountedReadOnly(ADevice, lType, lPoint) then
  begin
    AOutput := 'NTFS_REPAIR_AVAILABLE: раздел уже подключён только для чтения: ' +
      ADevice + ' -> ' + lPoint + '. Повторное монтирование не устранит ' +
      'ошибку NTFS; ремонт требует отдельного подтверждения риска потери данных.';
    Exit;
  end;
  if lWasMounted and not RunWith('umount', [lOldPoint], lCheck) then
  begin AOutput := 'Старый ресурс занят; переподключение отменено: ' + lCheck; Exit; end;
  if not DirectoryExists(lPoint) and not ForceDirectories(lPoint) then
  begin
    if lWasMounted then RunWith('mount', [lOldPoint], lRollback);
    AOutput := 'Не удалось создать каталог назначения.'; Exit;
  end;
  lEntry := 'UUID=' + lUuid + ' ' + lPoint + ' ' + lType + ' ' +
    lOptions + ' 0 2 # ' + CMarker + ' device=' + ADevice;
  if not SaveFstab(lNewFstab + lEntry + LineEnding, lError) then
  begin
    if lWasMounted then RunWith('mount', [lOldPoint], lRollback);
    AOutput := lError; Exit;
  end;
  if not RunWith('mount', [lPoint], lCheck) then
  begin
    if NtfsMountedReadOnly(ADevice, lType, lPoint) then
    begin
      AOutput := 'NTFS_REPAIR_AVAILABLE: раздел подключён только для чтения: ' +
        ADevice + ' -> ' + lPoint + '. Возможна ошибка NTFS или незавершённая ' +
        'работа Windows. Ремонт требует отдельного подтверждения риска потери данных. ' + lCheck;
      Exit;
    end;
    if not SaveFstab(lFstab, lRollback) then
      AOutput := 'Монтаж не удался и возврат fstab не удался: ' + lCheck +
        '; ' + lRollback
    else
      AOutput := 'Монтаж не удался; исходная запись fstab возвращена: ' + lCheck;
    if lWasMounted and not RunWith('mount', [lOldPoint], lRollback) then
      AOutput := AOutput + LineEnding +
        'ОШИБКА: старый путь не восстановлен: ' + lRollback;
    Exit;
  end;
  if NtfsMountedReadOnly(ADevice, lType, lPoint) then
  begin
    AOutput := 'NTFS_REPAIR_AVAILABLE: раздел подключён только для чтения: ' +
      ADevice + ' -> ' + lPoint + '. Возможна ошибка NTFS или незавершённая ' +
      'работа Windows. Ремонт требует отдельного подтверждения риска потери данных.';
    Exit;
  end;
  AOutput := 'Смонтировано: ' + ADevice + ' -> ' + lPoint +
    ' (UUID=' + lUuid + '). ' + lError;
  Result := 0;
end;

function ChangeManagedMount(const AAction, ADevice: string;
  out AOutput: string): Integer;
var
  lUuid, lLine, lPoint, lValue, lFstab, lError: string;
begin
  Result := 1;
  if not RunWith('blkid', ['-s', 'UUID', '-o', 'value', ADevice], lValue) then
  begin AOutput := 'Не найден UUID устройства.'; Exit; end;
  lUuid := FirstLine(lValue);
  if not ManagedLine(ADevice, lUuid, lLine, lPoint) then
  begin AOutput := 'Нет управляемой записи для этого UUID и устройства.'; Exit; end;
  if AAction = 'unmount' then
  begin
    if not RunWith('findmnt', ['-rn', '-o', 'UUID', '--mountpoint', lPoint], lValue) or
      (FirstLine(lValue) <> lUuid) then
    begin AOutput := 'Точка не смонтирована либо занята другим устройством.'; Exit; end;
    if RunWith('umount', [lPoint], AOutput) then Result := 0;
    Exit;
  end;
  if RunWith('findmnt', ['-rn', '--mountpoint', lPoint], lValue) then
  begin AOutput := 'Сначала размонтируйте ресурс.'; Exit; end;
  lFstab := ReadFstab;
  lFstab := StringReplace(lFstab, lLine + LineEnding, '', []);
  if SaveFstab(lFstab, lError) then
  begin AOutput := 'Управляемая запись удалена. ' + lError; Result := 0; end
  else AOutput := lError;
end;

function MountOptionPresent(const AOptions, AOption: string): Boolean;
begin
  Result := Pos(',' + AOption + ',', ',' + Trim(AOptions) + ',') > 0;
end;

function CheckRepairMount(const ADevice, AUUID: string;
  out APoint, AError: string): Boolean;
var
  lLine, lTargets, lOptions, lSubmounts, lAllSources: string;
  lRows: TStringList;
  lIndex: Integer;
begin
  Result := False;
  if not ManagedLine(ADevice, AUUID, lLine, APoint) then
  begin AError := 'Восстановление разрешено только для раздела с управляемой записью /etc/fstab.'; Exit; end;
  if not RunWith('findmnt', ['-rn', '-o', 'TARGET', '--source', ADevice], lTargets) or
    (Trim(lTargets) <> APoint) then
  begin AError := 'Раздел используется более чем одним подключением; восстановление отменено.'; Exit; end;
  if not RunWith('findmnt', ['-rn', '-o', 'SOURCE'], lAllSources) or
    (Pos(ADevice + '[', lAllSources) > 0) then
  begin AError := 'Есть bind-монтирования каталогов этого раздела; восстановление отменено.'; Exit; end;
  if not RunWith('findmnt', ['-rn', '-o', 'TARGET', '--submounts', '--target', APoint], lSubmounts) then
  begin AError := 'Не удалось проверить дочерние монтирования.'; Exit; end;
  lRows := TStringList.Create;
  try
    lRows.Text := lSubmounts;
    if lRows.Count = 0 then
    begin AError := 'Точка монтирования не найдена.'; Exit; end;
    for lIndex := 0 to lRows.Count - 1 do
      if Trim(lRows[lIndex]) <> APoint then
      begin AError := 'Внутри точки есть дочерние монтирования; восстановление отменено.'; Exit; end;
  finally
    lRows.Free;
  end;
  if not RunWith('findmnt', ['-rn', '-o', 'OPTIONS', '--source', ADevice], lOptions) then
  begin AError := 'Не удалось проверить режим монтирования.'; Exit; end;
  if not MountOptionPresent(FirstLine(lOptions), 'ro') then
  begin AError := 'Раздел не смонтирован только для чтения; ремонт не требуется.'; Exit; end;
  AError := '';
  Result := True;
end;

function AutomountUnit(const APoint: string; out AUnit: string): Boolean;
begin
  Result := RunWith('systemd-escape', ['--path', '--suffix=automount', APoint], AUnit);
  AUnit := FirstLine(AUnit);
  Result := Result and (AUnit <> '');
end;

function RestoreRepairMount(const APoint, AUnit: string;
  AAutomountWasActive: Boolean; out AError: string): Boolean;
var lTrigger: string;
begin
  if AAutomountWasActive then
  begin
    Result := RunWith('systemctl', ['start', AUnit], AError);
    if not Result then Exit;
    // Accessing the path triggers the filesystem behind the automount layer.
    Result := RunWith('stat', ['-c', '%F', APoint + '/.'], lTrigger);
    if not Result then AError := 'Автоподключение запущено, но том недоступен: ' + lTrigger;
  end
  else
    Result := RunWith('mount', [APoint], AError);
end;

function RepairNtfs(AArgs: TStrings; const ADevice: string;
  out AOutput: string): Integer;
var
  lUuid, lType, lParent, lError, lPoint, lFixOutput, lMountOutput,
  lOptions, lUnit, lTargets: string;
  lFixed, lMounted, lAutomountActive: Boolean;
begin
  Result := 1;
  if not CheckExistingDevice(ADevice, lUuid, lType, lParent, lError, True) then
  begin AOutput := lError; Exit; end;
  if not SameText(lType, 'ntfs') then
  begin AOutput := 'Восстановление разрешено только для NTFS-раздела.'; Exit; end;
  if (OptionValue(AArgs, '--confirm-device') <> ADevice) or
    (OptionValue(AArgs, '--confirm-uuid') <> lUuid) or
    (OptionValue(AArgs, '--accept-data-risk') <> 'yes') then
  begin
    AOutput := 'Подтвердите точные DEVICE и UUID, а также риск изменения данных: ' +
      '--confirm-device ' + ADevice + ' --confirm-uuid ' + lUuid +
      ' --accept-data-risk yes.';
    Exit;
  end;
  if not CheckRepairMount(ADevice, lUuid, lPoint, lError) then
  begin AOutput := lError; Exit; end;
  if not AutomountUnit(lPoint, lUnit) then
  begin AOutput := 'Не удалось определить имя службы автоподключения.'; Exit; end;
  lAutomountActive := RunWith('systemctl', ['is-active', '--quiet', lUnit], lError);
  if lAutomountActive and not RunWith('systemctl', ['stop', lUnit], lError) then
  begin AOutput := 'Автоподключение не остановлено; ntfsfix не запускался: ' + lError; Exit; end;
  if RunWith('findmnt', ['-rn', '-o', 'TARGET', '--source', ADevice], lTargets) then
  begin
    if Trim(lTargets) <> lPoint then
    begin
      RestoreRepairMount(lPoint, lUnit, lAutomountActive, lMountOutput);
      AOutput := 'После остановки автомонтирования источник изменился; ntfsfix не запускался.';
      Exit;
    end;
    if not RunWith('umount', [lPoint], lError) then
    begin
      RestoreRepairMount(lPoint, lUnit, lAutomountActive, lMountOutput);
      AOutput := 'Раздел занят; обычное размонтирование не удалось. ntfsfix не запускался: ' +
        lError + LineEnding + 'Восстановление подключения: ' + lMountOutput;
      Exit;
    end;
  end;
  if RunWith('findmnt', ['-rn', '-o', 'TARGET', '--source', ADevice], lTargets) then
  begin
    RestoreRepairMount(lPoint, lUnit, lAutomountActive, lMountOutput);
    AOutput := 'Раздел всё ещё смонтирован; ntfsfix не запускался. ' +
      'Восстановление подключения: ' + lMountOutput;
    Exit;
  end;
  lFixed := RunWith('ntfsfix', [ADevice], lFixOutput);
  // Always attempt to restore the original managed mount, even after ntfsfix fails.
  lMounted := RestoreRepairMount(lPoint, lUnit, lAutomountActive, lMountOutput);
  if not lMounted then
  begin
    AOutput := 'ВНИМАНИЕ: раздел остался размонтирован. ' +
      'ntfsfix: ' + lFixOutput + LineEnding + 'Повторное монтирование: ' + lMountOutput;
    Exit;
  end;
  if not lFixed then
  begin AOutput := 'ntfsfix завершился ошибкой; исходная точка восстановлена: ' + lFixOutput; Exit; end;
  if not RunWith('findmnt', ['-rn', '-o', 'OPTIONS', '--source', ADevice], lOptions) or
    not MountOptionPresent(FirstLine(lOptions), 'rw') then
  begin
    AOutput := 'ntfsfix выполнен, но раздел по-прежнему доступен только для чтения ' +
      'в ' + lPoint + '. Проверьте вывод: ' + lFixOutput;
    Exit;
  end;
  AOutput := 'NTFS восстановлена и вновь подключена для записи: ' +
    ADevice + ' -> ' + lPoint + '.' + LineEnding + lFixOutput;
  Result := 0;
end;

function ExecuteDiskSetup(AArgs: TStrings; out AOutput: string): Integer;
var
  lAction, lDevice, lDetails: string;
  lSuccess: Boolean;
begin
  Result := 1;
  AOutput := '';
  {$IFDEF WINDOWS}
  AOutput := 'Управление дисками доступно только в Linux.';
  Exit;
  {$ENDIF}
  if AArgs.Count = 0 then
  begin
    AOutput := 'Не указано действие с диском.';
    Exit;
  end;
  lAction := AArgs[0];
  if (lAction = 'list') then
  begin
    lSuccess := DiskInventory(AOutput);
    if lSuccess then Result := 0;
    Exit;
  end;
  if lAction = 'list-with-usage' then
  begin
    {$IFDEF UNIX}
    if fpGetEUID <> 0 then
    begin AOutput := 'Нужны права администратора для временного просмотра дисков.'; Exit; end;
    {$ENDIF}
    if InventoryWithUsage(AOutput) then Result := 0;
    Exit;
  end;
  if lAction = 'detect-tools' then
  begin
    lSuccess := RunWith('which', ['gnome-disks', 'partitionmanager', 'gparted'], AOutput);
    if lSuccess then Result := 0;
    Exit;
  end;
  if AArgs.Count < 2 then
  begin
    AOutput := 'Укажите полный путь устройства /dev/...';
    Exit;
  end;
  lDevice := AArgs[1];
  if not ValidDevice(lDevice) then
  begin
    AOutput := 'Недопустимый путь устройства.';
    Exit;
  end;
  if (lAction = 'preview') or (lAction = 'mount-existing') or
    (lAction = 'repair-ntfs') or
    (lAction = 'unmount') or (lAction = 'remove-fstab') then
  begin
    {$IFDEF UNIX}
    if fpGetEUID <> 0 then
    begin AOutput := 'Нужны права администратора.'; Exit; end;
    {$ENDIF}
    if lAction = 'preview' then Exit(PreviewDevice(lDevice, AOutput));
    if lAction = 'mount-existing' then
      Exit(MountExisting(AArgs, lDevice, AOutput));
    if lAction = 'repair-ntfs' then
      Exit(RepairNtfs(AArgs, lDevice, AOutput));
    Exit(ChangeManagedMount(lAction, lDevice, AOutput));
  end;
  if lAction = 'inspect' then
  begin
    lSuccess := RunWith('lsblk', ['-b', '-o',
      'PATH,TYPE,SIZE,MODEL,SERIAL,FSTYPE,UUID,MOUNTPOINTS,FSUSED,FSAVAIL,FSUSE%',
      lDevice], AOutput);
    if lSuccess then Result := 0;
    if lSuccess and RunWith('df', ['-hT', '-P'], lDetails) then
      AOutput := AOutput + LineEnding + lDetails;
    Exit;
  end;
  if lAction = 'plan' then
  begin
    lSuccess := RunWith('lsblk', ['-b', '-o',
      'PATH,TYPE,SIZE,MODEL,SERIAL,FSTYPE,UUID,MOUNTPOINTS,FSUSED,FSAVAIL,FSUSE%',
      lDevice], AOutput);
    if lSuccess then
    begin
      Result := 0;
      AOutput := AOutput + LineEnding +
        'Форматирование встроенным кодом пока заблокировано: нельзя надёжно ' +
        'доказать, что диск не участвует в корневой ФС, LVM, RAID, swap или ' +
        'другом системном томе. Для подготовки используйте «Диски GUI».';
    end;
    Exit;
  end;
  AOutput := 'Операция ' + lAction + ' заблокирована встроенным менеджером дисков. ' +
    'Для форматирования и изменения монтирования используйте «Диски GUI». ' +
    'Данные диска не изменены.';
end;

end.
