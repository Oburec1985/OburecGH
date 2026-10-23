unit uRecorderFrfPointStore;

{ Сохраняет и загружает полный снимок точки маршрута: временные ряды, спектры
  и метаданные. Выбор точки и подтверждение перезаписи остаются у вызывающего
  кода; файловые операции не меняют активный репозиторий измерений. }

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  SysUtils, uRecorderImpactSessionContracts;

type
  TRecorderFrfPointStore = class
  public
    class function SessionFileName(const ADirectory: string): string; static;
    class function Exists(const ADirectory: string): Boolean; static;
    class function Save(const ADirectory: string;
      const ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean; static;
    class function Load(const ADirectory: string;
      out ASnapshot: TRecorderImpactSessionSnapshot;
      out AError: string): Boolean; static;
  end;

implementation

uses
  uRecorderImpactMeraPointStore;

{ Выбирает frf или совместимый старый каталог aka по наличию session.mera. }
function ExistingMeraDirectory(const ADirectory: string): string;
begin
  Result := IncludeTrailingPathDelimiter(ADirectory) + 'frf';
  if not FileExists(TRecorderImpactMeraPointStore.SessionFileName(Result)) and
    FileExists(TRecorderImpactMeraPointStore.SessionFileName(
      IncludeTrailingPathDelimiter(ADirectory) + 'aka')) then
    Result := IncludeTrailingPathDelimiter(ADirectory) + 'aka';
end;

{ Ищет резервное поколение frf.*.tmp.previous при отсутствии целевой сессии. }
function MissingMeraGeneration(const ADirectory: string): Boolean;
var lEntry: TSearchRec;
begin
  Result := False;
  if FileExists(TRecorderFrfPointStore.SessionFileName(ADirectory)) then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(ADirectory) +
    'frf.*.tmp.previous', faDirectory, lEntry) = 0 then
  try
    repeat
      if (lEntry.Attr and faDirectory) <> 0 then Exit(True);
    until FindNext(lEntry) <> 0;
  finally FindClose(lEntry) end;
end;

{ Строит путь к session.mera внутри ADirectory. }
class function TRecorderFrfPointStore.SessionFileName(
  const ADirectory: string): string;
begin
  Result := IncludeTrailingPathDelimiter(ADirectory) + 'frf' + PathDelim +
    'session.mera';
end;

{ Проверяет наличие сохранённой сессии либо незавершённой резервной генерации. }
class function TRecorderFrfPointStore.Exists(const ADirectory: string): Boolean;
begin
  Result := (Trim(ADirectory) <> '') and
    (MissingMeraGeneration(ADirectory) or
     FileExists(TRecorderImpactMeraPointStore.SessionFileName(
       ExistingMeraDirectory(ADirectory))));
end;

{ Записывает шаги и привязки в конфигурацию проекта; ADirectory задаёт корень результатов. }
class function TRecorderFrfPointStore.Save(const ADirectory: string;
  const ASnapshot: TRecorderImpactSessionSnapshot; out AError: string): Boolean;
var
  lFileName, lTemporary, lBackup: string;
  lIdentity: TGuid;
  lHadPrevious: Boolean;
begin
  Result := False;
  AError := '';
  if Trim(ADirectory) = '' then
  begin
    AError := 'FRF point directory is empty.';
    Exit;
  end;
  lTemporary := '';
  try
    if MissingMeraGeneration(ADirectory) then
      raise EInOutError.Create('MERA generation is missing; recover the frf.*.tmp.previous backup before saving.');
    if not ForceDirectories(ADirectory) then
      raise EInOutError.Create('Cannot create FRF point directory: ' + ADirectory);
    lFileName := IncludeTrailingPathDelimiter(ADirectory) + 'frf';
    CreateGUID(lIdentity);
    lTemporary := lFileName + '.' + GUIDToString(lIdentity) + '.tmp';
    lBackup := lTemporary + '.previous';
    if not TRecorderImpactMeraPointStore.Save(lTemporary, ASnapshot, AError) then
      raise EInOutError.Create(AError);
    // Старая запись остаётся доступной, пока новая не установлена полностью.
    lHadPrevious := DirectoryExists(lFileName);
    if lHadPrevious and not RenameFile(lFileName, lBackup) then
      raise EInOutError.Create('Cannot back up previous FRF realization.');
    if not RenameFile(lTemporary, lFileName) then
    begin
      if lHadPrevious and not RenameFile(lBackup, lFileName) then
        raise EInOutError.Create('Cannot install FRF realization; previous data: ' + lBackup);
      raise EInOutError.Create('Cannot install FRF realization.');
    end;
    { Предыдущая бинарная версия остаётся в резерве; каталог frf заменяется
      целиком, не затрагивая остальные файлы точки. }
    { Старую вычисленную кривую удаляем только после фиксации полной MERA-сессии;
      предыдущие сырые данные и посторонние файлы сохраняются. }
    lFileName := IncludeTrailingPathDelimiter(ADirectory) + 'curve.frf';
    if FileExists(lFileName) and not DeleteFile(lFileName) then
      raise EInOutError.Create('MERA saved, but cannot remove obsolete curve.frf.');
    Result := True;
  except
    on E: Exception do
      AError := E.Message;
  end;
  { Неудачный staging-каталог оставляем для диагностики и не устанавливаем. }
end;

{ Загружает снимок точки из текущего или совместимого каталога MERA; при ошибке очищает ASnapshot. }
class function TRecorderFrfPointStore.Load(const ADirectory: string;
  out ASnapshot: TRecorderImpactSessionSnapshot; out AError: string): Boolean;
begin
  ASnapshot := Default(TRecorderImpactSessionSnapshot);
  if Trim(ADirectory) = '' then
  begin
    AError := 'FRF point directory is empty.';
    Exit(False);
  end;
  if MissingMeraGeneration(ADirectory) then
  begin
    AError := 'MERA generation is missing; recover the frf.*.tmp.previous backup.';
    Exit(False);
  end;
  Result := TRecorderImpactMeraPointStore.Load(
    ExistingMeraDirectory(ADirectory), ASnapshot, AError);
  if not Result then
    ASnapshot := Default(TRecorderImpactSessionSnapshot);
end;

end.
