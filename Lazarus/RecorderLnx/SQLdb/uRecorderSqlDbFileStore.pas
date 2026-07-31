unit uRecorderSqlDbFileStore;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, uRecorderSqlDbTypes;

type
  TRecorderStoredFile = record
    Id: string;
    StorageKey: string;
    Size: Int64;
    Checksum: string;
  end;

  TRecorderSqlDbFileStore = class
  private
    fRoot: string;
    function SafeExtension(const AFileName: string): string;
    function AbsoluteName(const AStorageKey: string): string;
  public
    constructor Create(const ARootDirectory: string);
    function StoreFile(const ASourceFile, ADataType: string;
      AAnchorUtc: Double): TRecorderStoredFile;
    function OpenRead(const AStorageKey: string): TFileStream;
    procedure ArchiveTo(const AStorageKey, ADestinationFile: string);
  end;

implementation

function Fnv1a64Update(AHash: QWord; const ABuffer; ACount: Integer): QWord;
var
  I: Integer;
  P: PByte;
begin
  Result := AHash;
  P := @ABuffer;
  for I := 0 to ACount - 1 do
  begin
    Result := Result xor P[I];
    Result := Result * QWord(1099511628211);
  end;
end;

constructor TRecorderSqlDbFileStore.Create(const ARootDirectory: string);
begin
  inherited Create;
  fRoot := IncludeTrailingPathDelimiter(ExpandFileName(ARootDirectory));
  if not ForceDirectories(fRoot) then
    raise ERecorderSqlDbError.CreateFmt('Cannot create SQLdb data directory: %s', [fRoot]);
end;

function TRecorderSqlDbFileStore.SafeExtension(const AFileName: string): string;
var
  S: string;
begin
  S := LowerCase(ExtractFileExt(AFileName));
  if (Length(S) > 12) or (Pos('..', S) > 0) or
     (Pos('/', S) > 0) or (Pos('\', S) > 0) then S := '';
  Result := S;
end;

function TRecorderSqlDbFileStore.AbsoluteName(const AStorageKey: string): string;
begin
  if (AStorageKey = '') or (Pos('..', AStorageKey) > 0) or
     (ExtractFileDrive(AStorageKey) <> '') then
    raise ERecorderSqlDbError.Create('Unsafe SQLdb storage key');
  Result := ExpandFileName(fRoot + StringReplace(AStorageKey, '/',
    DirectorySeparator, [rfReplaceAll]));
  if Pos(LowerCase(fRoot), LowerCase(Result)) <> 1 then
    raise ERecorderSqlDbError.Create('SQLdb storage key escapes data directory');
end;

function TRecorderSqlDbFileStore.StoreFile(const ASourceFile, ADataType: string;
  AAnchorUtc: Double): TRecorderStoredFile;
const
  CBufferSize = 256 * 1024;
var
  lSource, lTarget: TFileStream;
  lBuffer: array[0..CBufferSize - 1] of Byte;
  lCount: Integer;
  lHash: QWord;
  lDir, lFinal, lTemp, lKind: string;
begin
  if not FileExists(ASourceFile) then
    raise ERecorderSqlDbError.CreateFmt('Data file not found: %s', [ASourceFile]);
  Result.Id := RecorderSqlDbNewId;
  lKind := LowerCase(Trim(ADataType));
  if lKind = '' then lKind := 'binary';
  lKind := StringReplace(lKind, '/', '_', [rfReplaceAll]);
  lKind := StringReplace(lKind, '\', '_', [rfReplaceAll]);
  Result.StorageKey := FormatDateTime('yyyy/mm/dd', AAnchorUtc) + '/' +
    lKind + '/' + Result.Id + SafeExtension(ASourceFile);
  lFinal := AbsoluteName(Result.StorageKey);
  lDir := ExtractFileDir(lFinal);
  if not ForceDirectories(lDir) then
    raise ERecorderSqlDbError.CreateFmt('Cannot create data directory: %s', [lDir]);
  lTemp := lFinal + '.tmp';
  lHash := QWord(14695981039346656037);
  Result.Size := 0;
  lSource := TFileStream.Create(ASourceFile, fmOpenRead or fmShareDenyWrite);
  try
    lTarget := TFileStream.Create(lTemp, fmCreate);
    try
      repeat
        lCount := lSource.Read(lBuffer, SizeOf(lBuffer));
        if lCount > 0 then
        begin
          lTarget.WriteBuffer(lBuffer, lCount);
          lHash := Fnv1a64Update(lHash, lBuffer, lCount);
          Inc(Result.Size, lCount);
        end;
      until lCount = 0;
    finally
      lTarget.Free;
    end;
    if not RenameFile(lTemp, lFinal) then
      raise ERecorderSqlDbError.CreateFmt('Cannot publish data file: %s', [lFinal]);
  finally
    lSource.Free;
    if FileExists(lTemp) then DeleteFile(lTemp);
  end;
  Result.Checksum := 'fnv1a64:' + IntToHex(lHash, 16);
end;

function TRecorderSqlDbFileStore.OpenRead(const AStorageKey: string): TFileStream;
begin
  Result := TFileStream.Create(AbsoluteName(AStorageKey),
    fmOpenRead or fmShareDenyNone);
end;

procedure TRecorderSqlDbFileStore.ArchiveTo(const AStorageKey,
  ADestinationFile: string);
var
  lSource, lTarget: TFileStream;
begin
  if not ForceDirectories(ExtractFileDir(ExpandFileName(ADestinationFile))) then
    raise ERecorderSqlDbError.Create('Cannot create archive destination directory');
  lSource := OpenRead(AStorageKey);
  try
    lTarget := TFileStream.Create(ADestinationFile, fmCreate);
    try
      lTarget.CopyFrom(lSource, 0);
    finally lTarget.Free; end;
  finally lSource.Free; end;
end;

end.
