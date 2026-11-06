program RecorderProjectNamesTest;
{$mode objfpc}{$H+}
uses Interfaces, Classes, SysUtils, uRecorderProjectFiles, uRecorderProjectConfiguration,
  uRecorderRunControlSettings, uRecorderTags, uRecorderFormModel,
  uRecorderNetworkBinding, uRecorderMeraPaths;

procedure Check(AValue: Boolean; const AMessage: string);
begin
  if not AValue then raise Exception.Create(AMessage);
end;

var
  lDir, lLoaded: string;
  lFiles: TRecorderProjectFileSet;
  lOld, lStale, lNew: TRecorderRunControlSettings;
  lRegistry: TRecorderTagRegistry;
  lForms: TRecorderFormManager;
  lFactory: TRecorderComponentFactory;
  lText: TStringList;
  lFailed: Boolean;
begin
  Check(ParamCount >= 1, 'Pass an isolated project directory');
  lDir := IncludeTrailingPathDelimiter(ExpandFileName(ParamStr(1)));
  ForceDirectories(lDir);
  Check(SameText(ExpandFileName(RecorderAppConfigFileName), lDir + 'test-app.ini'),
    'Pass /cfg:<project-dir>/test-app.ini to isolate the application config');
  Check(not FileExists(RecorderAppConfigFileName), 'Test app config already exists');
  lFiles := RecorderProjectFileSet(lDir, 'ignored');
  Check(ExtractFileName(lFiles.MainConfigFileName) = 'config.json', 'config name');
  Check(ExtractFileName(lFiles.GuiFileName) = 'gui.ini', 'gui name');
  Check(ExtractFileName(lFiles.RunControlFileName) = 'run-control.ini', 'run name');
  lOld := TRecorderRunControlSettings.Create;
  lStale := TRecorderRunControlSettings.Create;
  lNew := TRecorderRunControlSettings.Create;
  try
    lOld.StartChannelName := 'active-legacy';
    lOld.SaveToFile(lDir + 'default.run-control.ini');
    lStale.StartChannelName := 'stale-old';
    lStale.SaveToFile(lFiles.RunControlFileName);
    lText := TStringList.Create;
    try
      lText.Text := '{"tags":[]}';
      lText.SaveToFile(lFiles.MainConfigFileName);
    finally
      lText.Free;
    end;
    lLoaded := LoadRecorderProjectRunSettings(lDir, lNew);
    Check(ExtractFileName(lLoaded) = 'default.run-control.ini', 'legacy precedence');
    Check(lNew.StartChannelName = 'active-legacy', 'legacy value');
    SaveRecorderProjectRunSettings(lDir, lNew);
    Check(FileExists(lDir + 'run-control.ini.legacy-backup'), 'stale file backup');
    Check(FileExists(lDir + 'default.run-control.ini.legacy-backup'), 'active file backup');
    lNew.StartChannelName := '';
    lLoaded := LoadRecorderProjectRunSettings(lDir, lNew);
    Check(ExtractFileName(lLoaded) = 'run-control.ini', 'canonical precedence');
    Check(lNew.StartChannelName = 'active-legacy', 'value after migration');
    Check(DeleteFile(lFiles.MainConfigFileName), 'remove test config marker');
    ForceDirectories(lDir + 'failure');
    lOld.SaveToFile(lDir + 'failure/default.run-control.ini');
    ForceDirectories(lDir + 'failure/run-control.ini');
    lFailed := False;
    try
      SaveRecorderProjectRunSettings(lDir + 'failure', lOld);
    except
      on E: Exception do lFailed := True;
    end;
    Check(lFailed, 'failed save must be reported');
    Check(FileExists(lDir + 'failure/default.run-control.ini'),
      'failed save must preserve legacy settings');
    lText := TStringList.Create;
    lRegistry := TRecorderTagRegistry.Create(nil);
    lForms := TRecorderFormManager.Create;
    lFactory := TRecorderComponentFactory.Create;
    try
      lText.Text := '{"networkBindAddress":"203.0.113.8","tags":[]}';
      lText.SaveToFile(lDir + 'default.config.json');
      SaveRecorderGuiConfig(lDir + 'default.gui.ini', lForms);
      lFiles := LoadRecorderProjectPackage(lDir, lRegistry, lForms, lFactory);
      Check(not RecorderNetworkHasPersistedBindAddress, 'read-only load wrote app config');
      lFiles := LoadRecorderProjectPackage(lDir, lRegistry, lForms, lFactory, True);
      Check(ExtractFileName(lFiles.MainConfigFileName) = 'default.config.json', 'legacy config fallback');
      Check(ExtractFileName(lFiles.GuiFileName) = 'default.gui.ini', 'legacy gui fallback');
      Check(RecorderNetworkConfiguredBindAddress = '203.0.113.8', 'legacy network migration');
      lFiles := SaveRecorderProjectPackage(lDir, lRegistry, lForms, lNew);
      Check(FileExists(lDir + 'config.json'), 'canonical config saved');
      Check(FileExists(lDir + 'gui.ini'), 'canonical gui saved');
      Check(FileExists(lDir + 'default.config.json.legacy-backup'), 'legacy config retained');
      Check(FileExists(lDir + 'default.gui.ini.legacy-backup'), 'legacy gui retained');
      lText.LoadFromFile(lDir + 'config.json');
      Check(Pos('networkBindAddress', lText.Text) = 0, 'network setting duplicated in project');
    finally
      lFactory.Free; lForms.Free; lRegistry.Free; lText.Free;
    end;
    WriteLn('OK: project naming and run settings migration');
  finally
    lNew.Free; lStale.Free; lOld.Free;
  end;
end.
