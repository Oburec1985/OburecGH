unit uRecorderProjectConfiguration;

{
  Владелец постоянной конфигурации проекта RecorderLnx. Модуль связывает
  канонические пути, run-control и существующие сериализаторы project/gui;
  UI-реакции после загрузки остаются у вызывающего контроллера.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderFormModel, uRecorderProjectFiles, uRecorderRunControlSettings,
  uRecorderTags;

const
  CRecorderDefaultProjectBaseName = 'default';

procedure EnsureRecorderProjectConfiguration(const AProjectDir: string;
  ARunSettings: TRecorderRunControlSettings);
function LoadRecorderDefaultProjectDir: string;
procedure SaveRecorderDefaultProjectDir(const AProjectDir: string);
function LoadRecorderProjectRunSettings(const AProjectDir: string;
  ARunSettings: TRecorderRunControlSettings): string;
procedure InitializeRecorderMachineStorageForActiveProject(
  const AProjectDir: string; ARunSettings: TRecorderRunControlSettings);
procedure SaveRecorderProjectRunSettings(const AProjectDir: string;
  ARunSettings: TRecorderRunControlSettings);
function LoadRecorderProjectPackage(const AProjectDir: string;
  ATags: TRecorderTagRegistry; AForms: TRecorderFormManager;
  AFactory: TRecorderComponentFactory;
  AMigrateNetworkSetting: Boolean = False): TRecorderProjectFileSet;
function SaveRecorderProjectPackage(const AProjectDir: string;
  ATags: TRecorderTagRegistry; AForms: TRecorderFormManager;
  ARunSettings: TRecorderRunControlSettings): TRecorderProjectFileSet;
procedure SaveRecorderProjectGui(const AProjectDir: string;
  AForms: TRecorderFormManager);
function LoadRecorderMainWindowWidth(ADefaultWidth: Integer): Integer;
procedure SaveRecorderMainWindowWidth(AWidth: Integer);

implementation

uses
  Classes, IniFiles, StrUtils, SysUtils, fpjson, jsonparser, uRecorderMeraPaths,
  uRecorderAppVersion, uRecorderNetworkBinding, uRecorderDebugLog,
  uRecorderMachineStorage;

const
  CAppSection = 'Application';
  CDefaultProjectDirKey = 'DefaultProjectConfigDir';
  CRightPanelWidthKey = 'RightPanelWidth';

function LegacyProjectFile(const AProjectDir, ASuffix: string): string;
begin
  Result := RecorderNormalizeProjectDir(AProjectDir) +
    CRecorderDefaultProjectBaseName + ASuffix;
end;

function NextLegacyBackupName(const AFileName: string): string;
var
  lIndex: Integer;
begin
  Result := AFileName + '.legacy-backup';
  lIndex := 1;
  while FileExists(Result) do
  begin
    Result := AFileName + '.legacy-backup.' + IntToStr(lIndex);
    Inc(lIndex);
  end;
end;

procedure BackupExistingFile(const AFileName: string);
var
  lSource, lTarget: TFileStream;
  lBackup: string;
begin
  if not FileExists(AFileName) then Exit;
  lBackup := NextLegacyBackupName(AFileName);
  lSource := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    lTarget := TFileStream.Create(lBackup, fmCreate);
    try
      lTarget.CopyFrom(lSource, 0);
    finally
      lTarget.Free;
    end;
  finally
    lSource.Free;
  end;
end;

procedure PreserveLegacyFile(const AFileName: string);
var
  lBackupName: string;
begin
  if not FileExists(AFileName) then Exit;
  lBackupName := NextLegacyBackupName(AFileName);
  if not RenameFile(AFileName, lBackupName) then
    raise Exception.CreateFmt('Cannot preserve previous project file: %s',
      [AFileName]);
end;

procedure MigrateProjectNetworkSetting(const AFileName: string);
var
  lText: TStringList;
  lData: TJSONData;
  lRoot: TJSONObject;
begin
  if RecorderNetworkHasPersistedBindAddress then Exit;
  if not FileExists(AFileName) then
  begin
    RecorderMigrateLegacyNetworkBindAddress('');
    Exit;
  end;
  lText := TStringList.Create;
  try
    lText.LoadFromFile(AFileName);
    lData := GetJSON(lText.Text);
  finally
    lText.Free;
  end;
  try
    if lData is TJSONObject then
    begin
      lRoot := TJSONObject(lData);
      if lRoot.Find('networkBindAddress') <> nil then
        RecorderMigrateLegacyNetworkBindAddress(
          lRoot.Get('networkBindAddress', ''))
      else
        RecorderMigrateLegacyNetworkBindAddress('');
    end;
  finally
    lData.Free;
  end;
end;

procedure EnsureRecorderProjectConfiguration(const AProjectDir: string;
  ARunSettings: TRecorderRunControlSettings);
var
  lAppConfig: TStringList;
  lAppConfigFileName: string;
  lFiles: TRecorderProjectFileSet;
  lIni: TIniFile;
begin
  RecorderEnsureMeraDirectories;
  ForceDirectories(RecorderNormalizeProjectDir(AProjectDir));
  lAppConfigFileName := RecorderAppConfigFileName;
  ForceDirectories(RecorderAppConfigDir);
  if not FileExists(lAppConfigFileName) then
  begin
    lAppConfig := TStringList.Create;
    try
      lAppConfig.Add('[Application]');
      lAppConfig.Add('DefaultProjectConfigDir=config/projects/default');
      lAppConfig.Add('TimeSource=PC');
      lAppConfig.Add('');
      lAppConfig.Add('[Plugins]');
      lAppConfig.Add('; Plugin list will be added later');
      lAppConfig.SaveToFile(lAppConfigFileName);
    finally
      lAppConfig.Free;
    end;
  end;
  lIni := TIniFile.Create(lAppConfigFileName);
  try
    if not lIni.ValueExists(CAppSection, 'SoftwareArticle') then
      lIni.WriteString(CAppSection, 'SoftwareArticle',
        CRecorderDefaultSoftwareArticle);
  finally
    lIni.Free;
  end;
  lFiles := RecorderProjectFileSet(AProjectDir,
    CRecorderDefaultProjectBaseName);
  { Existing projects can contain the previous default.run-control.ini. }
  if (ARunSettings <> nil) and not FileExists(lFiles.RunControlFileName) and
    not FileExists(LegacyProjectFile(AProjectDir, '.run-control.ini')) then
    ARunSettings.SaveToFile(lFiles.RunControlFileName);
end;

function LoadRecorderDefaultProjectDir: string;
var
  lConfiguredDir: string;
  lIni: TIniFile;
begin
  Result := RecorderDefaultProjectConfigDir;
  if not FileExists(RecorderAppConfigFileName) then
    Exit;
  lIni := TIniFile.Create(RecorderAppConfigFileName);
  try
    lConfiguredDir := Trim(lIni.ReadString(CAppSection,
      CDefaultProjectDirKey, ''));
  finally
    lIni.Free;
  end;
  if lConfiguredDir <> '' then
    Result := RecorderResolveAppPath(lConfiguredDir);
end;

procedure SaveRecorderDefaultProjectDir(const AProjectDir: string);
var
  lAppDir, lProjectDir, lValue: string;
  lIni: TIniFile;
begin
  lAppDir := RecorderAppConfigDir;
  lProjectDir := IncludeTrailingPathDelimiter(ExpandFileName(AProjectDir));
  lValue := lProjectDir;
  if AnsiStartsText(lAppDir, lProjectDir) then
    lValue := ExcludeTrailingPathDelimiter(Copy(lProjectDir,
      Length(lAppDir) + 1, MaxInt));
  lIni := TIniFile.Create(RecorderAppConfigFileName);
  try
    lIni.WriteString(CAppSection, CDefaultProjectDirKey, lValue);
  finally
    lIni.Free;
  end;
end;

function LoadRecorderProjectRunSettings(const AProjectDir: string;
  ARunSettings: TRecorderRunControlSettings): string;
var
  lFiles: TRecorderProjectFileSet;
  lLegacyFileName: string;
begin
  Result := '';
  lFiles := RecorderProjectFileSet(AProjectDir,
    CRecorderDefaultProjectBaseName);
  lLegacyFileName := LegacyProjectFile(AProjectDir, '.run-control.ini');
  { Before migration both names may exist and contain different data. The
    default-prefixed file was the active one; preserve its precedence. }
  if FileExists(lLegacyFileName) then
    Result := lLegacyFileName
  else if FileExists(lFiles.RunControlFileName) then
    Result := lFiles.RunControlFileName;
  if (Result <> '') and (ARunSettings <> nil) then
    ARunSettings.LoadFromFile(Result);
end;

procedure InitializeRecorderMachineStorageForActiveProject(
  const AProjectDir: string; ARunSettings: TRecorderRunControlSettings);
var
  lPreviousMeraPath: string;
begin
  if (ARunSettings = nil) or RecorderMachineStorageInitialized then Exit;
  { Resolve and cache the bootstrap app path before inspecting a legacy
    project: reading the latter may change the effective Mera Files path. }
  lPreviousMeraPath := RecorderMeraFilesPath;
  try
    if not RecorderMachineStorageExists then
      LoadRecorderProjectRunSettings(AProjectDir, ARunSettings);
    InitializeRecorderMachineStorage(ARunSettings.MeraFilesPath);
    ARunSettings.MeraFilesPath := RecorderMachineMeraPath;
    SetRecorderMeraFilesPath(ARunSettings.MeraFilesPath);
  except
    SetRecorderMeraFilesPath(lPreviousMeraPath);
    raise;
  end;
end;

procedure SaveRecorderProjectRunSettings(const AProjectDir: string;
  ARunSettings: TRecorderRunControlSettings);
var
  lFiles: TRecorderProjectFileSet;
  lLegacyFileName: string;
begin
  RecorderEnsureMeraDirectories;
  ForceDirectories(AProjectDir);
  lFiles := RecorderProjectFileSet(AProjectDir,
    CRecorderDefaultProjectBaseName);
  lLegacyFileName := LegacyProjectFile(AProjectDir, '.run-control.ini');
  if (ARunSettings <> nil) and RecorderMachineStorageInitialized then
    SaveRecorderMachineStorage(ARunSettings.MeraFilesPath);
  if FileExists(lLegacyFileName) then
    BackupExistingFile(lFiles.RunControlFileName);
  ARunSettings.SaveToFile(lFiles.RunControlFileName);
  PreserveLegacyFile(lLegacyFileName);
end;

function LoadRecorderProjectPackage(const AProjectDir: string;
  ATags: TRecorderTagRegistry; AForms: TRecorderFormManager;
  AFactory: TRecorderComponentFactory;
  AMigrateNetworkSetting: Boolean): TRecorderProjectFileSet;
begin
  Result := RecorderProjectFileSet(AProjectDir,
    CRecorderDefaultProjectBaseName);
  if not FileExists(Result.MainConfigFileName) and
    FileExists(LegacyProjectFile(AProjectDir, '.config.json')) then
    Result.MainConfigFileName := LegacyProjectFile(AProjectDir, '.config.json');
  if not FileExists(Result.GuiFileName) and
    FileExists(LegacyProjectFile(AProjectDir, '.gui.ini')) then
    Result.GuiFileName := LegacyProjectFile(AProjectDir, '.gui.ini');
  if AMigrateNetworkSetting then
    try
      MigrateProjectNetworkSetting(Result.MainConfigFileName);
    except
      on E: Exception do RecorderInfoLog('Network setting migration deferred: ' + E.Message);
    end;
  if not FileExists(Result.MainConfigFileName) then
    RecorderLoadNetworkBindAddress('', False);
  LoadRecorderProjectConfig(Result.MainConfigFileName, ATags);
  LoadRecorderGuiConfig(Result.GuiFileName, AForms, AFactory);
end;

function SaveRecorderProjectPackage(const AProjectDir: string;
  ATags: TRecorderTagRegistry; AForms: TRecorderFormManager;
  ARunSettings: TRecorderRunControlSettings): TRecorderProjectFileSet;
begin
  Result := RecorderProjectFileSet(AProjectDir,
    CRecorderDefaultProjectBaseName);
  ForceDirectories(Result.DirectoryName);
  SaveRecorderProjectRunSettings(AProjectDir, ARunSettings);
  SaveRecorderProjectConfig(Result.MainConfigFileName, ATags);
  SaveRecorderGuiConfig(Result.GuiFileName, AForms);
  PreserveLegacyFile(LegacyProjectFile(AProjectDir, '.config.json'));
  PreserveLegacyFile(LegacyProjectFile(AProjectDir, '.gui.ini'));
end;

procedure SaveRecorderProjectGui(const AProjectDir: string;
  AForms: TRecorderFormManager);
var
  lFiles: TRecorderProjectFileSet;
begin
  lFiles := RecorderProjectFileSet(RecorderNormalizeProjectDir(AProjectDir),
    CRecorderDefaultProjectBaseName);
  ForceDirectories(lFiles.DirectoryName);
  SaveRecorderGuiConfig(lFiles.GuiFileName, AForms);
  PreserveLegacyFile(LegacyProjectFile(AProjectDir, '.gui.ini'));
end;

function LoadRecorderMainWindowWidth(ADefaultWidth: Integer): Integer;
var
  lIni: TIniFile;
begin
  lIni := TIniFile.Create(RecorderAppConfigFileName);
  try
    Result := lIni.ReadInteger(CAppSection, CRightPanelWidthKey,
      ADefaultWidth);
  finally
    lIni.Free;
  end;
end;

procedure SaveRecorderMainWindowWidth(AWidth: Integer);
var
  lIni: TIniFile;
begin
  lIni := TIniFile.Create(RecorderAppConfigFileName);
  try
    lIni.WriteInteger(CAppSection, CRightPanelWidthKey, AWidth);
  finally
    lIni.Free;
  end;
end;

end.
