unit uRecorderPluginInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uRecorderPluginApi;

type
  TRecorderPluginEntry = class
  public
    FileName: string;
    Name: string;
    Description: string;
    Vendor: string;
    ErrorText: string;
    Version: Word;
    SubVersion: Word;
    BugFix: Word;
    BuildNumber: Word;
    PluginType: Integer;
    function IsValid: Boolean;
  end;

  TRecorderPluginCatalog = class
  private
    fEntries: TList;
    function GetCount: Integer;
    function GetEntry(AIndex: Integer): TRecorderPluginEntry;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(AEntry: TRecorderPluginEntry);
    procedure Delete(AIndex: Integer);
    procedure Scan(const ADirectory: string);
    property Count: Integer read GetCount;
    property Entries[AIndex: Integer]: TRecorderPluginEntry read GetEntry;
  end;

function RecorderPluginDirectory: string;
function RecorderReadPluginInfoFile(const AFileName: string): TRecorderPluginEntry;

implementation

uses
  DynLibs;

function RecorderPluginDirectory: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'plugins';
end;

function TRecorderPluginEntry.IsValid: Boolean;
begin
  Result := ErrorText = '';
end;

constructor TRecorderPluginCatalog.Create;
begin
  inherited Create;
  fEntries := TList.Create;
end;

destructor TRecorderPluginCatalog.Destroy;
begin
  Clear;
  fEntries.Free;
  inherited Destroy;
end;

procedure TRecorderPluginCatalog.Clear;
var
  I: Integer;
begin
  for I := 0 to fEntries.Count - 1 do
    TObject(fEntries[I]).Free;
  fEntries.Clear;
end;

procedure TRecorderPluginCatalog.Add(AEntry: TRecorderPluginEntry);
begin
  fEntries.Add(AEntry);
end;

procedure TRecorderPluginCatalog.Delete(AIndex: Integer);
begin
  TObject(fEntries[AIndex]).Free;
  fEntries.Delete(AIndex);
end;

function TRecorderPluginCatalog.GetCount: Integer;
begin
  Result := fEntries.Count;
end;

function TRecorderPluginCatalog.GetEntry(AIndex: Integer): TRecorderPluginEntry;
begin
  Result := TRecorderPluginEntry(fEntries[AIndex]);
end;

function BoundedText(const ABuffer: array of AnsiChar): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(ABuffer) do
  begin
    if ABuffer[I] = #0 then
      Exit;
    Result := Result + ABuffer[I];
  end;
end;

procedure ReadPluginInfo(AEntry: TRecorderPluginEntry);
var
  lHandle: TLibHandle;
  lInfo: TRecorderPluginInfo;
  lGetInfo: TRecorderPluginGetInfo;
  lGetType: TRecorderPluginGetType;
begin
  lHandle := SafeLoadLibrary(AEntry.FileName);
  if lHandle = NilHandle then
  begin
    AEntry.ErrorText := 'Не удалось загрузить библиотеку: ' + GetLoadErrorStr;
    Exit;
  end;
  try
    Pointer(lGetInfo) := GetProcedureAddress(lHandle, 'GetPluginInfo');
    if not Assigned(lGetInfo) then
      Pointer(lGetInfo) := GetProcedureAddress(lHandle, '_GetPluginInfo');
    if not Assigned(lGetInfo) then
    begin
      AEntry.ErrorText := 'Нет функции GetPluginInfo';
      Exit;
    end;
    lInfo := Default(TRecorderPluginInfo);
    lInfo.Version := SizeOf(lInfo); // Original Recorder passes the buffer size here.
    lGetInfo(lInfo);
    AEntry.Name := BoundedText(lInfo.Name);
    AEntry.Description := BoundedText(lInfo.Describe);
    AEntry.Vendor := BoundedText(lInfo.Vendor);
    AEntry.Version := lInfo.Version;
    AEntry.SubVersion := lInfo.SubVersion;
    AEntry.BugFix := lInfo.BugFix;
    AEntry.BuildNumber := lInfo.BuildNumber;
    Pointer(lGetType) := GetProcedureAddress(lHandle, 'GetPluginType');
    if Assigned(lGetType) then
      AEntry.PluginType := lGetType()
    else
      AEntry.PluginType := -1;
    if AEntry.Name = '' then
      AEntry.ErrorText := 'Плагин не сообщил имя';
  except
    on E: Exception do
      AEntry.ErrorText := E.ClassName + ': ' + E.Message;
  end;
  FreeLibrary(lHandle);
end;

function RecorderReadPluginInfoFile(const AFileName: string): TRecorderPluginEntry;
begin
  Result := TRecorderPluginEntry.Create;
  Result.FileName := ExpandFileName(AFileName);
  if not FileExists(Result.FileName) then
  begin
    Result.ErrorText := 'Файл не найден';
    Exit;
  end;
  ReadPluginInfo(Result);
end;

procedure TRecorderPluginCatalog.Scan(const ADirectory: string);
var
  lSearch: TSearchRec;
  lEntry: TRecorderPluginEntry;
  lMask: string;
begin
  Clear;
  if not DirectoryExists(ADirectory) then
    Exit;
  {$IFDEF WINDOWS}
  lMask := '*.dll';
  {$ELSE}
  lMask := '*.so';
  {$ENDIF}
  if FindFirst(IncludeTrailingPathDelimiter(ADirectory) + lMask,
    faAnyFile, lSearch) <> 0 then
    Exit;
  try
    repeat
      if (lSearch.Attr and faDirectory) <> 0 then
        Continue;
      lEntry := RecorderReadPluginInfoFile(
        IncludeTrailingPathDelimiter(ADirectory) + lSearch.Name);
      fEntries.Add(lEntry);
    until FindNext(lSearch) <> 0;
  finally
    FindClose(lSearch);
  end;
end;

end.
