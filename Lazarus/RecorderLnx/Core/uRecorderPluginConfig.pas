unit uRecorderPluginConfig;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  uRecorderPluginInfo;

function RecorderPluginConfigFileName: string;
procedure MigrateRecorderPluginConfig(const ALegacyProjectConfigDir: string);
procedure LoadRecorderPluginConfig(const AFileName: string;
  ACatalog: TRecorderPluginCatalog);
procedure SaveRecorderPluginConfig(const AFileName: string;
  ACatalog: TRecorderPluginCatalog);
function RecorderInstallPluginFile(const ASourceFileName: string): string;

implementation

uses
  Classes, SysUtils, IniFiles, uRecorderMeraPaths;

function RecorderPluginConfigFileName: string;
begin
  Result := RecorderAppConfigFileName;
end;

procedure MigrateRecorderPluginConfig(const ALegacyProjectConfigDir: string);
var
  lAppConfigFileName, lLegacyFileName: string;
  lIni: TIniFile;
  lCatalog: TRecorderPluginCatalog;
begin
  lLegacyFileName := IncludeTrailingPathDelimiter(
    ALegacyProjectConfigDir) + 'plugins.ini';
  if not FileExists(lLegacyFileName) then
    Exit;
  lAppConfigFileName := RecorderPluginConfigFileName;
  if FileExists(lAppConfigFileName) then
  begin
    lIni := TIniFile.Create(lAppConfigFileName);
    try
      if lIni.ValueExists('Plugins', 'Count') then
        Exit;
    finally
      lIni.Free;
    end;
  end;
  lCatalog := TRecorderPluginCatalog.Create;
  try
    LoadRecorderPluginConfig(lLegacyFileName, lCatalog);
    SaveRecorderPluginConfig(lAppConfigFileName, lCatalog);
  finally
    lCatalog.Free;
  end;
end;

procedure LoadRecorderPluginConfig(const AFileName: string;
  ACatalog: TRecorderPluginCatalog);
var
  lIni: TIniFile;
  lEntry: TRecorderPluginEntry;
  lSection: string;
  lCount, I: Integer;
begin
  ACatalog.Clear;
  if not FileExists(AFileName) then
    Exit;
  lIni := TIniFile.Create(AFileName);
  try
    lCount := lIni.ReadInteger('Plugins', 'Count', 0);
    if lCount > 1000 then
      lCount := 1000;
    for I := 0 to lCount - 1 do
    begin
      lSection := 'Plugin' + IntToStr(I);
      lEntry := TRecorderPluginEntry.Create;
      lEntry.FileName := ExtractFileName(lIni.ReadString(lSection, 'FileName', ''));
      if lEntry.FileName = '' then
      begin
        lEntry.Free;
        Continue;
      end;
      lEntry.Name := lIni.ReadString(lSection, 'Name', '');
      lEntry.Description := lIni.ReadString(lSection, 'Description', '');
      lEntry.Vendor := lIni.ReadString(lSection, 'Vendor', '');
      lEntry.Version := lIni.ReadInteger(lSection, 'Version', 0);
      lEntry.SubVersion := lIni.ReadInteger(lSection, 'SubVersion', 0);
      lEntry.BugFix := lIni.ReadInteger(lSection, 'BugFix', 0);
      lEntry.BuildNumber := lIni.ReadInteger(lSection, 'BuildNumber', 0);
      lEntry.PluginType := lIni.ReadInteger(lSection, 'PluginType', -1);
      ACatalog.Add(lEntry);
    end;
  finally
    lIni.Free;
  end;
end;

procedure SaveRecorderPluginConfig(const AFileName: string;
  ACatalog: TRecorderPluginCatalog);
var
  lIni: TMemIniFile;
  lEntry: TRecorderPluginEntry;
  lSections: TStringList;
  lSection: string;
  lNumber, I: Integer;
begin
  ForceDirectories(ExtractFileDir(AFileName));
  lIni := TMemIniFile.Create(AFileName);
  lSections := TStringList.Create;
  try
    lIni.ReadSections(lSections);
    for I := 0 to lSections.Count - 1 do
      if (Copy(lSections[I], 1, 6) = 'Plugin') and
        TryStrToInt(Copy(lSections[I], 7, MaxInt), lNumber) then
        lIni.EraseSection(lSections[I]);
    lIni.WriteInteger('Plugins', 'Count', ACatalog.Count);
    for I := 0 to ACatalog.Count - 1 do
    begin
      lEntry := ACatalog.Entries[I];
      lSection := 'Plugin' + IntToStr(I);
      lIni.WriteString(lSection, 'FileName', ExtractFileName(lEntry.FileName));
      lIni.WriteString(lSection, 'Name', lEntry.Name);
      lIni.WriteString(lSection, 'Description', lEntry.Description);
      lIni.WriteString(lSection, 'Vendor', lEntry.Vendor);
      lIni.WriteInteger(lSection, 'Version', lEntry.Version);
      lIni.WriteInteger(lSection, 'SubVersion', lEntry.SubVersion);
      lIni.WriteInteger(lSection, 'BugFix', lEntry.BugFix);
      lIni.WriteInteger(lSection, 'BuildNumber', lEntry.BuildNumber);
      lIni.WriteInteger(lSection, 'PluginType', lEntry.PluginType);
    end;
    lIni.UpdateFile;
  finally
    lSections.Free;
    lIni.Free;
  end;
end;

function RecorderInstallPluginFile(const ASourceFileName: string): string;
var
  lSource, lTarget: string;
  lInput, lOutput: TFileStream;
begin
  lSource := ExpandFileName(ASourceFileName);
  if not FileExists(lSource) then
    raise Exception.Create('Файл плагина не найден: ' + lSource);
  if not ForceDirectories(RecorderPluginDirectory) then
    raise Exception.Create('Не удалось создать каталог плагинов: ' +
      RecorderPluginDirectory);
  lTarget := ExpandFileName(IncludeTrailingPathDelimiter(
    RecorderPluginDirectory) + ExtractFileName(lSource));
  {$IFDEF WINDOWS}
  if SameText(lSource, lTarget) then
  {$ELSE}
  if lSource = lTarget then
  {$ENDIF}
    Exit(ExtractFileName(lTarget));
  if FileExists(lTarget) then
    raise Exception.Create('В каталоге plugins уже есть файл с таким именем: ' +
      lTarget);
  lInput := TFileStream.Create(lSource, fmOpenRead or fmShareDenyNone);
  try
    lOutput := TFileStream.Create(lTarget, fmCreate);
    try
      lOutput.CopyFrom(lInput, 0);
    finally
      lOutput.Free;
    end;
  finally
    lInput.Free;
  end;
  Result := ExtractFileName(lTarget);
end;

end.
