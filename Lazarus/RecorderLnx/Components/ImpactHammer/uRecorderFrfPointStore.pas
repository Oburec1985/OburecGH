unit uRecorderFrfPointStore;

{ Explicit point save/load boundary used by the FRF route controller. A point
  directory contains a complete portable session, including time samples and
  spectra. The caller owns selection and overwrite confirmation; this unit
  never modifies the live acquisition repository. }

{$mode objfpc}{$H+}

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
  uRecorderImpactSessionJson;

class function TRecorderFrfPointStore.SessionFileName(
  const ADirectory: string): string;
begin
  Result := IncludeTrailingPathDelimiter(ADirectory) + 'session.json';
end;

class function TRecorderFrfPointStore.Exists(const ADirectory: string): Boolean;
begin
  Result := (Trim(ADirectory) <> '') and FileExists(SessionFileName(ADirectory));
end;

class function TRecorderFrfPointStore.Save(const ADirectory: string;
  const ASnapshot: TRecorderImpactSessionSnapshot; out AError: string): Boolean;
var
  lStore: IRecorderImpactSessionStore;
  lOptions: TRecorderImpactSessionSaveOptions;
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
    if not ForceDirectories(ADirectory) then
      raise EInOutError.Create('Cannot create FRF point directory: ' + ADirectory);
    lFileName := SessionFileName(ADirectory);
    CreateGUID(lIdentity);
    lTemporary := lFileName + '.' + GUIDToString(lIdentity) + '.tmp';
    lBackup := lTemporary + '.previous';
    lOptions.SaveT0 := True;
    lOptions.IncludeRawBlocks := True;
    lOptions.IncludeSpectra := True;
    lStore := TRecorderImpactSessionJsonStore.Create;
    if not lStore.Save(lTemporary, ASnapshot, lOptions, AError) then
      raise EInOutError.Create(AError);
    // Keep the existing realization recoverable until the new file is installed.
    lHadPrevious := FileExists(lFileName);
    if lHadPrevious and not RenameFile(lFileName, lBackup) then
      raise EInOutError.Create('Cannot back up previous FRF realization.');
    if not RenameFile(lTemporary, lFileName) then
    begin
      if lHadPrevious and not RenameFile(lBackup, lFileName) then
        raise EInOutError.Create('Cannot install FRF realization; previous data: ' + lBackup);
      raise EInOutError.Create('Cannot install FRF realization.');
    end;
    if lHadPrevious then
      DeleteFile(lBackup);
    Result := True;
  except
    on E: Exception do
      AError := E.Message;
  end;
  if (lTemporary <> '') and FileExists(lTemporary) then
    DeleteFile(lTemporary);
end;

class function TRecorderFrfPointStore.Load(const ADirectory: string;
  out ASnapshot: TRecorderImpactSessionSnapshot; out AError: string): Boolean;
var
  lStore: IRecorderImpactSessionStore;
begin
  ASnapshot := Default(TRecorderImpactSessionSnapshot);
  if Trim(ADirectory) = '' then
  begin
    AError := 'FRF point directory is empty.';
    Exit(False);
  end;
  lStore := TRecorderImpactSessionJsonStore.Create;
  Result := lStore.Load(SessionFileName(ADirectory), ASnapshot, AError);
  if not Result then
    ASnapshot := Default(TRecorderImpactSessionSnapshot);
end;

end.
