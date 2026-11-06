program RecorderMachineStorageTest;
{$mode objfpc}{$H+}
uses Classes, SysUtils, IniFiles, uRecorderMeraPaths, uRecorderRunControlSettings,
  uRecorderMachineStorage;
procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;
{$IFDEF RECORDER_STORAGE_TEST}
var gFaultAfterRename: Boolean;
procedure InjectFault(const AStage: string);
begin
  if AStage = 'after-rename' then
  begin
    gFaultAfterRename := True;
    raise ERecorderMachineStorageCommitUncertain.Create('simulated directory fsync failure');
  end;
  if (AStage = 'read') and gFaultAfterRename then
    raise Exception.Create('simulated readback failure');
end;
{$ENDIF}
var
  lRoot, lProject1, lProject2, lOriginal, lStorage, lBefore: string;
  lIni: TIniFile;
  lSettings: TRecorderRunControlSettings;
  lRejected: Boolean;
begin
  if ((ParamCount <> 1) and (ParamCount <> 2)) or
    (Copy(ParamStr(1), 1, 5) <> '/cfg:') then
    raise Exception.Create('Pass /cfg: with an isolated app.ini');
  lRoot := ExtractFileDir(RecorderAppConfigFileName);
  Check(ForceDirectories(lRoot), 'fixture directory');
  lProject1 := IncludeTrailingPathDelimiter(lRoot) + 'project1.ini';
  lProject2 := IncludeTrailingPathDelimiter(lRoot) + 'project2.ini';
  lOriginal := IncludeTrailingPathDelimiter(lRoot) + 'original data';
  lStorage := RecorderMachineStorageFileName;
  if (ParamCount = 2) and (ParamStr(2) = 'reload') then
  begin
    Check(TryLoadExistingRecorderMachineStorage, 'existing storage not loaded');
    Check(RecorderMachineMeraPath = lOriginal, 'restart lost machine path');
    lSettings := TRecorderRunControlSettings.Create;
    try
      lSettings.LoadFromFile(lProject1);
      Check(lSettings.MeraFilesPath = lOriginal, 'legacy project changed path after restart');
      Check(lSettings.RecordShareName = 'ARMshare', 'legacy project changed share after restart');
    finally lSettings.Free; end;
    WriteLn('RESULT RecorderMachineStorageTest reload passed');
    Halt(0);
  end;
  if (ParamCount = 2) and (ParamStr(2) = 'invalid') then
  begin
    lIni := TIniFile.Create(lStorage);
    try lIni.DeleteKey('Storage', 'MeraFilesPath'); lIni.UpdateFile;
    finally lIni.Free; end;
    lRejected := False;
    try InitializeRecorderMachineStorage('wrong');
    except on E: Exception do lRejected := True; end;
    Check(lRejected and not RecorderMachineStorageInitialized,
      'incomplete storage was silently replaced');
    lSettings := TRecorderRunControlSettings.Create;
    try
      lSettings.LoadFromFile(lProject1);
      Check((lSettings.MeraFilesPath = lOriginal) and
        (lSettings.RecordShareName = 'ARMshare'), 'legacy fallback failed');
    finally lSettings.Free; end;
    lIni := TIniFile.Create(lStorage);
    try Check(not lIni.ValueExists('Storage', 'MeraFilesPath'),
      'invalid file was modified by failed initialization');
    finally lIni.Free; end;
    WriteLn('RESULT RecorderMachineStorageTest invalid passed');
    Halt(0);
  end;
  if (ParamCount = 2) and (ParamStr(2) = 'writefailure') then
  begin
    Check(TryLoadExistingRecorderMachineStorage, 'storage missing for write failure test');
    lRejected := False;
    try SaveRecorderMachineStorage('new invalid change');
    except on E: Exception do lRejected := True; end;
    Check(lRejected, 'unwritable storage unexpectedly changed');
    Check(RecorderMachineMeraPath = lOriginal, 'failed write changed runtime');
    lIni := TIniFile.Create(lStorage);
    try Check(lIni.ReadString('Storage', 'MeraFilesPath', '') = lOriginal,
      'failed write changed file');
    finally lIni.Free; end;
    WriteLn('RESULT RecorderMachineStorageTest writefailure passed');
    Halt(0);
  end;
  {$IFDEF RECORDER_STORAGE_TEST}
  if (ParamCount = 2) and (ParamStr(2) = 'commitfailure') then
  begin
    Check(TryLoadExistingRecorderMachineStorage, 'storage missing for commit failure test');
    RecorderMachineStorageTestHook := @InjectFault;
    lRejected := False;
    try SaveRecorderMachineStorage('new committed path');
    except on E: ERecorderMachineStorageCommitUncertain do lRejected := True; end;
    Check(lRejected and RecorderMachineStorageCommitUncertain,
      'uncertain commit was not preserved');
    lRejected := False;
    try lBefore := RecorderMachineMeraPath;
    except on E: ERecorderMachineStorageCommitUncertain do lRejected := True; end;
    Check(lRejected, 'uncertain cache was silently exposed');
    lIni := TIniFile.Create(lStorage);
    try Check(lIni.ReadString('Storage', 'MeraFilesPath', '') = 'new committed path',
      'fault injection did not cross rename');
    finally lIni.Free; end;
    WriteLn('RESULT RecorderMachineStorageTest commitfailure passed');
    Halt(0);
  end;
  {$ENDIF}
  Check(not TryLoadExistingRecorderMachineStorage,
    'missing storage reported as present');
  Check(not FileExists(lStorage), 'read-only load created storage');
  Check(not FileExists(lStorage), 'storage fixture already exists');
  lIni := TIniFile.Create(lProject1);
  try
    lIni.WriteString('Mera', 'FilesPath', lOriginal);
    lIni.WriteString('Record', 'ShareName', 'ARMshare');
    lIni.UpdateFile;
  finally lIni.Free; end;
  lIni := TIniFile.Create(lProject2);
  try
    lIni.WriteString('Mera', 'FilesPath', IncludeTrailingPathDelimiter(lRoot) + 'other');
    lIni.WriteString('Record', 'ShareName', 'OtherShare');
    lIni.UpdateFile;
  finally lIni.Free; end;
  lSettings := TRecorderRunControlSettings.Create;
  try
    lSettings.LoadFromFile(lProject1);
    InitializeRecorderMachineStorage(lSettings.MeraFilesPath);
    Check(RecorderMachineMeraPath = lOriginal, 'legacy active path not migrated');
    lSettings.LoadFromFile(lProject2);
    Check(lSettings.MeraFilesPath = lOriginal, 'project changed machine path');
    Check(lSettings.RecordShareName = 'OtherShare', 'project share was not retained');
    Check(RecorderMachineStorageFileName = lStorage, 'bootstrap config path moved');
    SaveRecorderMachineStorage(lSettings.MeraFilesPath);
    lSettings.SaveToFile(lProject2);
    lIni := TIniFile.Create(lProject2);
    try
      Check(not lIni.ValueExists('Mera', 'FilesPath'), 'legacy project path still written');
      Check(lIni.ReadString('Record', 'ShareName', '') = 'OtherShare', 'project share lost');
    finally lIni.Free; end;
    lIni := TIniFile.Create(lStorage);
    try
      lIni.WriteString('Storage', 'MeraFilesPath', 'ExternalChange');
      lIni.UpdateFile;
    finally lIni.Free; end;
    lRejected := False;
    try SaveRecorderMachineStorage('Overwrite');
    except on E: Exception do lRejected := True; end;
    Check(lRejected, 'concurrent storage change was overwritten');
    lIni := TIniFile.Create(lStorage);
    try Check(lIni.ReadString('Storage', 'MeraFilesPath', '') = 'ExternalChange',
      'failed save changed disk');
    finally lIni.Free; end;
    lIni := TIniFile.Create(lStorage);
    try lIni.WriteString('Storage', 'MeraFilesPath', lOriginal); lIni.UpdateFile;
    finally lIni.Free; end;
    WriteLn('RESULT RecorderMachineStorageTest passed');
  finally lSettings.Free; end;
end.
