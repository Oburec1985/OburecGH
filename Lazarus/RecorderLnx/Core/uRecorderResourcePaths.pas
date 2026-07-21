unit uRecorderResourcePaths;

{
  Кроссплатформенный поиск неизменяемых ресурсов RecorderLnx.

  Рабочий код не должен знать абсолютные пути машины разработчика. Ресурс
  ищется по логическому относительному имени рядом с приложением, в каталоге
  Mera Files из настроек и, для запуска из IDE, относительно корня проекта.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

function RecorderResolveResourceFile(const ALogicalRelativePath,
  AConfiguredPath, ADevelopmentRelativePath: string; out AResolvedPath,
  ASearchedPaths: string): Boolean;

implementation

uses
  uRecorderMeraPaths;

function NormalizeRelativePath(const APath: string): string;
begin
  Result := StringReplace(Trim(APath), '\', PathDelim, [rfReplaceAll]);
  Result := StringReplace(Result, '/', PathDelim, [rfReplaceAll]);
  while (Result <> '') and (Result[1] = PathDelim) do
    Delete(Result, 1, 1);
end;

function IsAbsolutePath(const APath: string): Boolean;
begin
  Result := (APath <> '') and
    ((APath[1] = PathDelim) or
     ((Length(APath) >= 2) and (APath[2] = ':')) or
     ((Length(APath) >= 2) and (APath[1] = '\') and (APath[2] = '\')));
end;

procedure AddCandidate(AList: TStrings; const APath: string);
var
  lPath: string;
begin
  if Trim(APath) = '' then
    Exit;
  lPath := ExpandFileName(APath);
  if AList.IndexOf(lPath) < 0 then
    AList.Add(lPath);
end;

function RecorderResolveResourceFile(const ALogicalRelativePath,
  AConfiguredPath, ADevelopmentRelativePath: string; out AResolvedPath,
  ASearchedPaths: string): Boolean;
const
  CMaxParentLevels = 8;
var
  I: Integer;
  lAppDir: string;
  lBaseDir: string;
  lConfigured: string;
  lDevRelative: string;
  lEnvironmentDir: string;
  lLogical: string;
  lCandidates: TStringList;
begin
  Result := False;
  AResolvedPath := '';
  ASearchedPaths := '';
  lCandidates := TStringList.Create;
  try
    lCandidates.CaseSensitive := {$IFDEF MSWINDOWS}False{$ELSE}True{$ENDIF};
    lLogical := NormalizeRelativePath(ALogicalRelativePath);
    lDevRelative := NormalizeRelativePath(ADevelopmentRelativePath);
    lConfigured := Trim(AConfiguredPath);
    lAppDir := ExpandFileName(ExtractFilePath(ParamStr(0)));

    { Явная настройка имеет наивысший приоритет. Старые абсолютные Windows-пути
      под Linux не ExpandFileName-им: они всё равно не являются ресурсом гостя. }
    if lConfigured <> '' then
    begin
      if IsAbsolutePath(lConfigured) then
        AddCandidate(lCandidates, lConfigured)
      else
      begin
        AddCandidate(lCandidates, IncludeTrailingPathDelimiter(lAppDir) +
          NormalizeRelativePath(lConfigured));
        AddCandidate(lCandidates, IncludeTrailingPathDelimiter(
          RecorderMeraFilesPath) + NormalizeRelativePath(lConfigured));
      end;
    end;

    lEnvironmentDir := Trim(GetEnvironmentVariable('RECORDERLNX_RESOURCES'));
    if lEnvironmentDir <> '' then
      AddCandidate(lCandidates, IncludeTrailingPathDelimiter(lEnvironmentDir) +
        lLogical);

    AddCandidate(lCandidates, IncludeTrailingPathDelimiter(lAppDir) +
      'resources' + PathDelim + lLogical);
    AddCandidate(lCandidates, IncludeTrailingPathDelimiter(lAppDir) + lLogical);
    AddCandidate(lCandidates, IncludeTrailingPathDelimiter(
      RecorderMeraFilesPath) + 'Resources' + PathDelim + lLogical);

    { IDE и build-tree: поднимаемся от каталога ELF/exe, не от CurrentDir. }
    lBaseDir := ExcludeTrailingPathDelimiter(lAppDir);
    for I := 0 to CMaxParentLevels do
    begin
      AddCandidate(lCandidates, IncludeTrailingPathDelimiter(lBaseDir) +
        'resources' + PathDelim + lLogical);
      if lDevRelative <> '' then
        AddCandidate(lCandidates, IncludeTrailingPathDelimiter(lBaseDir) +
          lDevRelative);
      if ExtractFileDir(lBaseDir) = lBaseDir then
        Break;
      lBaseDir := ExtractFileDir(lBaseDir);
    end;

    ASearchedPaths := lCandidates.Text;
    for I := 0 to lCandidates.Count - 1 do
      if FileExists(lCandidates[I]) then
      begin
        AResolvedPath := lCandidates[I];
        Exit(True);
      end;
  finally
    lCandidates.Free;
  end;
end;

end.
