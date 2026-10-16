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
procedure SaveRecorderProjectRunSettings(const AProjectDir: string;
  ARunSettings: TRecorderRunControlSettings);
function LoadRecorderProjectPackage(const AProjectDir: string;
  ATags: TRecorderTagRegistry; AForms: TRecorderFormManager;
  AFactory: TRecorderComponentFactory): TRecorderProjectFileSet;
function SaveRecorderProjectPackage(const AProjectDir: string;
  ATags: TRecorderTagRegistry; AForms: TRecorderFormManager;
  ARunSettings: TRecorderRunControlSettings): TRecorderProjectFileSet;
procedure SaveRecorderProjectGui(const AProjectDir: string;
  AForms: TRecorderFormManager);
function LoadRecorderMainWindowWidth(ADefaultWidth: Integer): Integer;
procedure SaveRecorderMainWindowWidth(AWidth: Integer);

implementation

uses
  Classes, IniFiles, StrUtils, SysUtils, uRecorderMeraPaths,
  uRecorderAppVersion;

const
  CAppSection = 'Application';
  CDefaultProjectDirKey = 'DefaultProjectConfigDir';
  CRightPanelWidthKey = 'RightPanelWidth';

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
  if (ARunSettings <> nil) and not FileExists(lFiles.RunControlFileName) then
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
  if FileExists(lFiles.RunControlFileName) then
    Result := lFiles.RunControlFileName
  else
  begin
    lLegacyFileName := RecorderLegacyRunControlFileName(AProjectDir);
    if FileExists(lLegacyFileName) then
      Result := lLegacyFileName;
  end;
  if (Result <> '') and (ARunSettings <> nil) then
    ARunSettings.LoadFromFile(Result);
end;

procedure SaveRecorderProjectRunSettings(const AProjectDir: string;
  ARunSettings: TRecorderRunControlSettings);
var
  lFiles: TRecorderProjectFileSet;
begin
  RecorderEnsureMeraDirectories;
  ForceDirectories(AProjectDir);
  lFiles := RecorderProjectFileSet(AProjectDir,
    CRecorderDefaultProjectBaseName);
  ARunSettings.SaveToFile(lFiles.RunControlFileName);
end;

function LoadRecorderProjectPackage(const AProjectDir: string;
  ATags: TRecorderTagRegistry; AForms: TRecorderFormManager;
  AFactory: TRecorderComponentFactory): TRecorderProjectFileSet;
begin
  Result := RecorderProjectFileSet(AProjectDir,
    CRecorderDefaultProjectBaseName);
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
