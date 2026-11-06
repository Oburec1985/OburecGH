program RecorderMachineStartupTest;
{$mode objfpc}{$H+}
uses Interfaces, SysUtils, IniFiles, uRecorderMeraPaths,
  uRecorderProjectConfiguration, uRecorderRunControlSettings,
  uRecorderMachineStorage;

procedure Check(ACondition: Boolean; const AMessage: string);
begin if not ACondition then raise Exception.Create(AMessage); end;

var
  lRoot, lP1, lP2, lData1, lData2, lMode, lBefore: string;
  lSettings: TRecorderRunControlSettings;
  lIni: TIniFile;
  lFailed: Boolean;
begin
  if (ParamCount < 1) or (Copy(ParamStr(1), 1, 5) <> '/cfg:') then
    raise Exception.Create('Pass isolated /cfg:app.ini');
  lRoot := ExtractFileDir(RecorderAppConfigFileName);
  lP1 := IncludeTrailingPathDelimiter(lRoot) + 'p1';
  lP2 := IncludeTrailingPathDelimiter(lRoot) + 'p2';
  lData1 := IncludeTrailingPathDelimiter(lRoot) + 'data1';
  lData2 := IncludeTrailingPathDelimiter(lRoot) + 'data2';
  if ParamCount > 1 then lMode := ParamStr(2) else lMode := 'first';
  lSettings := TRecorderRunControlSettings.Create;
  try
    if lMode = 'first' then
    begin
      Check(ForceDirectories(lP1) and ForceDirectories(lP2), 'fixture directories');
      lIni := TIniFile.Create(lP1 + DirectorySeparator + 'default.run-control.ini');
      try
        lIni.WriteString('Mera', 'FilesPath', lData1);
        lIni.WriteString('Record', 'ShareName', 'share1');
        lIni.UpdateFile;
      finally lIni.Free; end;
      lIni := TIniFile.Create(lP2 + DirectorySeparator + 'default.run-control.ini');
      try
        lIni.WriteString('Mera', 'FilesPath', lData2);
        lIni.WriteString('Record', 'ShareName', 'share2');
        lIni.UpdateFile;
      finally lIni.Free; end;
      LoadRecorderProjectRunSettings(lP2, lSettings);
      Check(not RecorderMachineStorageExists, 'ordinary read created machine storage');
      InitializeRecorderMachineStorageForActiveProject(lP1, lSettings);
      LoadRecorderProjectRunSettings(lP1, lSettings);
      Check(lSettings.MeraFilesPath = lData1, 'active project was not migrated');
      LoadRecorderProjectRunSettings(lP2, lSettings);
      Check(lSettings.MeraFilesPath = lData1, 'another project changed machine path');
      Check(lSettings.RecordShareName = 'share2', 'project-specific share changed');
      SaveRecorderProjectRunSettings(lP2, lSettings);
      lIni := TIniFile.Create(lP2 + DirectorySeparator + 'run-control.ini');
      try
        Check(not lIni.ValueExists('Mera', 'FilesPath'), 'machine path saved in project');
        Check(lIni.ReadString('Record', 'ShareName', '') = 'share2', 'project share lost');
      finally lIni.Free; end;
    end
    else if lMode = 'reload' then
    begin
      InitializeRecorderMachineStorageForActiveProject(lP2, lSettings);
      LoadRecorderProjectRunSettings(lP2, lSettings);
      Check(lSettings.MeraFilesPath = lData1, 'restart or project selection changed machine path');
      Check(lSettings.RecordShareName = 'share2', 'restart lost project share');
    end
    else if lMode = 'invalid' then
    begin
      lIni := TIniFile.Create(RecorderMachineStorageFileName);
      try lIni.DeleteKey('Storage', 'MeraFilesPath'); lIni.UpdateFile;
      finally lIni.Free; end;
      lBefore := RecorderMeraFilesPath;
      lFailed := False;
      try InitializeRecorderMachineStorageForActiveProject(lP1, lSettings);
      except on E: Exception do lFailed := True; end;
      Check(lFailed, 'invalid machine storage did not fail');
      Check(RecorderMeraFilesPath = lBefore, 'failed startup changed Mera Files');
      Check(FileExists(lP1 + DirectorySeparator + 'default.run-control.ini'),
        'failed startup changed legacy project');
    end
    else raise Exception.Create('Unknown mode');
    WriteLn('RESULT RecorderMachineStartupTest ', lMode, ' passed');
  finally lSettings.Free; end;
end.
