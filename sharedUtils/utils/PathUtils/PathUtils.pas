unit PathUtils;

interface

uses
  uCommonMath, ShellApi, Windows, dialogs, SysUtils;

// ����������� ������������� ���� APath � ����������, ������������ ���� ABasePath.
function RelativePathToAbsolute(const ABasePath, APath: String): String;
  overload;
function RelativePathToAbsolute(APath: String): String; overload;
// ���������� ������� ���� + ����� ���� ��������� � ������ level
function GetPathLevel(Base, Path: String; level: integer): String;
// ����������� ���������� ���� APath � �������������, ��������� ��� ���� ABasePath.
function AbsolutePathToRelative(const ABasePath, APath: String): String;
function WideRelativePathToAbsolute(const ABasePath, APath: WideString)
  : WideString;
function WideAbsolutePathToRelative(const ABasePath, APath: WideString)
  : WideString;
function GetRoot(const APath: String): String;
function WideGetRoot(const APath: WideString): WideString;
function isRelativePath(const APath: string): boolean;
function isAbsolutePath(const APath: string): boolean;
// �������� ������ �� �������������� �������
function trimNullString(str: string): string;
function ExecFile(name: string): boolean;
// ���� �� ����� ��� '\' �� ���������
function AddSlashToPath(Path: string): string;
// ������� ������ '\'
function DelSlashFromPath(Path: string): string;
function extractDirName(Path: string): string;
function RemoveDirAll(sDir: string): boolean;
procedure RenameDir(DirFrom, DirTo: string);
function GetDirTime(const Dir: string): TDateTime;

var
  PathDelim: Char;
  CaseSensitive: boolean;

implementation

type
  TStringArray = array of String;

function GetDirTime(const Dir: string): TDateTime;
var
  H: integer;
  F: TFileTime;
  S: TSystemTime;
begin
  H := CreateFile(PChar(Dir), $0080, 0, nil, OPEN_EXISTING,
    FILE_FLAG_BACKUP_SEMANTICS, 0);
  if H <> -1 then
  begin
    GetFileTime(H, @F, nil, nil);
    FileTimeToLocalFileTime(F, F);
    FileTimeToSystemTime(F, S);
    Result := SystemTimeToDateTime(S);
    CloseHandle(H);
  end
  else
    Result := -1;
end;

procedure RenameDir(DirFrom, DirTo: string);
var
  shellinfo: TSHFileOpStruct;
begin
  with shellinfo do
  begin
    Wnd := 0;
    wFunc := FO_RENAME;
    pFrom := PChar(DirFrom + #0);
    pTo := PChar(DirTo + #0);
    fFlags :=
      FOF_FILESONLY or FOF_ALLOWUNDO or FOF_SILENT or FOF_NOCONFIRMATION;
  end;
  SHFileOperation(shellinfo);
end;

function RemoveDirAll(sDir: string): boolean;
var
  iIndex: integer;
  SearchRec: TSearchRec;
  sFileName: string;
begin
  Result := False;
  sDir := sDir + '\*.*';
  iIndex := FindFirst(sDir, faAnyFile, SearchRec);

  while iIndex = 0 do
  begin
    sFileName := ExtractFileDir(sDir) + '\' + SearchRec.name;
    if SearchRec.Attr = faDirectory then
    begin
      if (SearchRec.name <> '') and (SearchRec.name <> '.') and
        (SearchRec.name <> '..') then
        RemoveDir(sFileName);
    end
    else
    begin
      if SearchRec.Attr <> faArchive then
        FileSetAttr(sFileName, faArchive);
      if not DeleteFile(sFileName) then
      begin
        ShowMessage('Could NOT delete ' + sFileName);
      end;
    end;
    iIndex := FindNext(SearchRec);
  end;

  FindClose(SearchRec);
  RemoveDir(ExtractFileDir(sDir));
  Result := True;
end;

function ExecFile(name: string): boolean;
begin
  Result := ShellExecute(0, 'open', PChar(Name), '',
    PChar(ExtractFileDir(name)), SW_MAXIMIZE) > 0;
end;

function trimNullString(str: string): string;
var
  i: integer;
begin
  for i := 1 to length(str) - 1 do
  begin
    if byte(str[i]) = 0 then
    begin
      setlength(str, i - 1);
      Result := str;
      exit;
    end
  end;
  Result := str;
end;

procedure ResemblePath(const APath: String; var Parts: TStringArray); overload;
var
  i, j, k: integer;
  S: String;
begin
  j := 1;
  k := 0;
  Parts := nil;
  for i := 1 to length(APath) do
    if APath[i] = PathDelim then
    begin
      S := Copy(APath, j, i - j);
      if S <> '' then
      begin
        setlength(Parts, k + 1);
        Parts[k] := S;
        Inc(k);
      end;
      j := i + 1;
    end;
  if j <= length(APath) then
  begin
    setlength(Parts, k + 1);
    Parts[k] := Copy(APath, j, MaxInt);
  end;
end;

function RelativePathToAbsolute(const ABasePath, APath: String): String;
var
  i, j, k: integer;
  TmpPath, S: String;
  RootLevel: integer;
  Strs1: TStringArray;
begin
  if APath = '' then
  begin
    Result := '';
    exit;
  end;
  if (length(APath) > 1) and ((APath[2] = DriveDelim) or // ��������� ����
      ((APath[1] = PathDelim) and (APath[2] = PathDelim))) then
  // ��� ������� ����
  begin
    Result := APath; // � ����� ������ ���� �� �������� �������������
    exit;
  end;

  RootLevel := Ord((length(ABasePath) > 1) and ((ABasePath[2] = DriveDelim)
      // ��������� ����
        or ((ABasePath[1] = PathDelim) and (ABasePath[2] = PathDelim)))) - 1;
  // ��� ������� ����
  // ���� ����� ������ � ������� ������ ��������� ������: ([A..Z]:) ��� (\\server_name).
  // ���� RootLevel = 0, �� ��� ����� ���� ������� � ����� ���������� ������ (\home),
  // ��� ���-�� �������������� (���� ��� ������� �����) - ���� ������ �������� �����
  // ��������� (������� �� �������� � �����)

  Result := '';
  ResemblePath(ABasePath, Strs1);

  j := 1;
  k := length(Strs1) - 1;
  if APath[length(APath)] = PathDelim then
    TmpPath := APath
  else
    TmpPath := APath + PathDelim;
  for i := 1 to length(TmpPath) do
    if TmpPath[i] = PathDelim then
    begin
      S := Copy(TmpPath, j, i - j);
      if (S <> '') and (S <> '.') then
      begin
        if S = '..' then
        begin
          Dec(k);
          if k < RootLevel then
            k := RootLevel; // ���� ����� �� �������� :)
          // ���������� ������ ������ �� �������� ��� ��� ����� ����������?
        end
        else
        begin
          Inc(k);
          if k = length(Strs1) then
            setlength(Strs1, k + 1);
          Strs1[k] := S;
        end;
      end;
      j := i + 1;
    end;
  for i := 0 to k do
    Result := Result + Strs1[i] + PathDelim;

  // ������� �������� ���������
  if (length(APath) > 0) and (APath[length(APath)] <> PathDelim) then
    setlength(Result, length(Result) - 1); // � ����� ��� ����� - �.�. ��� �����
  if (length(ABasePath) > 0) and (ABasePath[1] = PathDelim) then
    Result := PathDelim + Result; // ���� � ������ - ��������� ����
  if (length(ABasePath) > 1) and (ABasePath[2] = PathDelim) then
    Result := PathDelim + Result; // ��� ����� � ������ - ������� ����
end;

function RelativePathToAbsolute(APath: String): String;
begin
  Result := RelativePathToAbsolute(getcurrentdir, APath);
end;

function GetRoot(const APath: String): String;
var
  i: integer;
begin
  Result := '';
  if length(APath) > 0 then
    if APath[1] = PathDelim then
      if (length(APath) > 1) and (APath[2] = PathDelim) then
      begin
        for i := 3 to length(APath) do // ������� ����
          if APath[i] = PathDelim then
          begin
            Result := Copy(APath, 3, i - 3);
            Break;
          end;
        if Result = '' then
          Result := Copy(APath, 3, MaxInt);
      end
      else
        Result := PathDelim // ������ �������� �������
      else if (length(APath) > 1) and (APath[2] = DriveDelim) then
        Result := APath[1] // ��������� ����
      else
        Result := PathDelim;
end;

function SameString(const S1, S2: String): boolean; overload;
begin
  if CaseSensitive then
    Result := AnsiCompareText(S1, S2) = 0
  else
    Result := AnsiCompareStr(S1, S2) = 0;
end;

function AbsolutePathToRelative(const ABasePath, APath: String): String;
var
  Strs1, Strs2: TStringArray;
  i, j, k, l: integer;
begin
  if (length(ABasePath) = 0) or (length(APath) = 0) then
  begin
    Result := APath; // (*)
    exit;
  end;

  // ���� �� ������ ������� ����� ��� ������
  if not SameString(GetRoot(ABasePath), GetRoot(APath)) then
  begin
    Result := APath;
    exit;
  end;

  ResemblePath(ABasePath, Strs1);
  ResemblePath(APath, Strs2);

  Result := '';
  k := length(Strs1);
  l := 0;
  for i := 0 to length(Strs2) - 1 do
    if i < k then
    begin
      if not SameString(Strs2[i], Strs1[i]) then
      begin
        for j := i to k - 1 do
          Result := Result + '..' + PathDelim;
        Break;
      end
      else
        Inc(l);
    end
    else
    begin
      Result := '.' + PathDelim;
      Break;
    end;
  // ���� ������ ��� ����� ��������
  if l >= length(Strs2) then
    if l = k then
      Result := Result + '.' + PathDelim
    else
      for i := l to k - 1 do
        Result := Result + '..' + PathDelim
      else
        for i := l to length(Strs2) - 1 do
          Result := Result + Strs2[i] + PathDelim;
  if (length(APath) > 0) and (APath[length(APath)] <> PathDelim) then
    setlength(Result, length(Result) - 1); // � ����� ��� ����� - �.�. ��� �����
end;

// ------------------------------------------------------------------------------
// Wide-������

type
  TWideStringArray = array of WideString;

procedure ResemblePath(const APath: WideString; var Parts: TWideStringArray);
  overload;
var
  i, j, k: integer;
  S: WideString;
  PathDelimW: WideChar;
begin
  j := 1;
  k := 0;
  Parts := nil;
  PathDelimW := WideChar(PathDelim);
  for i := 1 to length(APath) do
    if APath[i] = PathDelimW then
    begin
      S := Copy(APath, j, i - j);
      if S <> '' then
      begin
        setlength(Parts, k + 1);
        Parts[k] := S;
        Inc(k);
      end;
      j := i + 1;
    end;
  if j <= length(APath) then
  begin
    setlength(Parts, k + 1);
    Parts[k] := Copy(APath, j, MaxInt);
  end;
end;

function WideRelativePathToAbsolute(const ABasePath, APath: WideString)
  : WideString;
var
  i, j, k: integer;
  TmpPath, S: WideString;
  RootLevel: integer;
  Strs1: TWideStringArray;
  DriveDelimW, PathDelimW: WideChar;
begin
  DriveDelimW := WideChar(DriveDelim);
  PathDelimW := WideChar(PathDelim);

  if (length(APath) > 1) and ((APath[2] = DriveDelimW) or // ��������� ����
      ((APath[1] = PathDelimW) and (APath[2] = PathDelimW))) then
  // ��� ������� ����
  begin
    Result := APath; // � ����� ������ ���� �� �������� �������������
    exit;
  end;

  RootLevel := Ord((length(ABasePath) > 1) and ((ABasePath[2] = DriveDelimW)
      // ��������� ����
        or ((ABasePath[1] = PathDelimW) and (ABasePath[2] = PathDelimW)))) - 1;
  // ��� ������� ����
  // ���� ����� ������ � ������� ������ ��������� ������: ([A..Z]:) ��� (\\server_name).
  // ���� RootLevel = 0, �� ��� ����� ���� ������� � ����� ���������� ������ (\home),
  // ��� ���-�� �������������� (���� ��� ������� �����) - ���� ������ �������� �����
  // ��������� (������� �� �������� � �����)

  Result := '';
  ResemblePath(ABasePath, Strs1);

  j := 1;
  k := length(Strs1) - 1;
  if APath[length(APath)] = PathDelimW then
    TmpPath := APath
  else
    TmpPath := APath + PathDelimW;
  for i := 1 to length(TmpPath) do
    if TmpPath[i] = PathDelimW then
    begin
      S := Copy(TmpPath, j, i - j);
      if (S <> '') and (S <> WideString('.')) then
      begin
        if S = WideString('..') then
        begin
          Dec(k);
          if k < RootLevel then
            k := RootLevel; // ���� ����� �� �������� :)
          // ���������� ������ ������ �� �������� ��� ��� ����� ����������?
        end
        else
        begin
          Inc(k);
          if k = length(Strs1) then
            setlength(Strs1, k + 1);
          Strs1[k] := S;
        end;
      end;
      j := i + 1;
    end;
  for i := 0 to k do
    Result := Result + Strs1[i] + PathDelimW;

  // ������� �������� ���������
  if (length(APath) > 0) and (APath[length(APath)] <> PathDelimW) then
    setlength(Result, length(Result) - 1); // � ����� ��� ����� - �.�. ��� �����
  if (length(ABasePath) > 0) and (ABasePath[1] = PathDelimW) then
    Result := PathDelimW + Result; // ���� � ������ - ��������� ����
  if (length(ABasePath) > 1) and (ABasePath[2] = PathDelimW) then
    Result := PathDelimW + Result; // ��� ����� � ������ - ������� ����
end;

function WideGetRoot(const APath: WideString): WideString;
var
  i: integer;
  PathDelimW: WideChar;
begin
  PathDelimW := WideChar(PathDelim);
  Result := '';
  if length(APath) > 0 then
    if APath[1] = PathDelimW then
      if (length(APath) > 1) and (APath[2] = PathDelimW) then
      begin
        for i := 3 to length(APath) do // ������� ����
          if APath[i] = PathDelimW then
          begin
            Result := Copy(APath, 3, i - 3);
            Break;
          end;
        if Result = '' then
          Result := Copy(APath, 3, MaxInt);
      end
      else
        Result := PathDelim // ������ �������� �������
      else if (length(APath) > 1) and (APath[2] = WideChar(DriveDelim)) then
        Result := APath[1] // ��������� ����
      else
        Result := PathDelimW;
end;

function SameString(const S1, S2: WideString): boolean; overload;
begin
  if CaseSensitive then
    Result := WideCompareText(S1, S2) = 0
  else
    Result := WideCompareStr(S1, S2) = 0;
end;

function WideAbsolutePathToRelative(const ABasePath, APath: WideString)
  : WideString;
var
  Strs1, Strs2: TStringArray;
  i, j, k, l: integer;
  PathDelimW: WideChar;
begin
  PathDelimW := WideChar(PathDelim);

  if (length(ABasePath) = 0) or (length(APath) = 0) then
  begin
    Result := APath;
    exit;
  end;

  // ���� �� ������ ������� ����� ��� ������
  if not SameString(WideGetRoot(ABasePath), WideGetRoot(APath)) then
  begin
    Result := APath;
    exit;
  end;

  ResemblePath(ABasePath, Strs1);
  ResemblePath(APath, Strs2);

  Result := '';
  k := length(Strs1);
  l := 0;
  for i := 0 to length(Strs2) - 1 do
    if i < k then
    begin
      if not SameString(Strs2[i], Strs1[i]) then
      begin
        for j := i to k - 1 do
          Result := Result + '..' + PathDelimW;
        Break;
      end
      else
        Inc(l);
    end
    else
    begin
      Result := WideString('.') + PathDelimW;
      Break;
    end;
  // ���� ������ ��� ����� ��������
  if l >= length(Strs2) then
    if l = k then
      Result := Result + '.' + PathDelimW
    else
      for i := l to k - 1 do
        Result := Result + '..' + PathDelimW
      else
        for i := l to length(Strs2) - 1 do
          Result := Result + Strs2[i] + PathDelimW;
  if (length(APath) > 0) and (APath[length(APath)] <> PathDelimW) then
    setlength(Result, length(Result) - 1); // � ����� ��� ����� - �.�. ��� �����
end;

function isAbsolutePath(const APath: string): boolean;
begin
  Result := False;
  if pos(':\', APath) > 0 then
    Result := True;
end;

function isRelativePath(const APath: string): boolean;
begin
  if APath[1] = '.' then
    Result := True;
end;

function GetPathLevel(Base, Path: String; level: integer): String;
var
  i, j, len: integer;
  �: integer;
begin
  Result := '';
  if pos(Base, Path) > 0 then
  begin
    len := length(Base);
    i := len;
    if Base[i] <> '\' then
      Inc(i);
    for j := 0 to level - 1 do
    begin
      if i + 1 < length(Path) then
        Result := Result + '\' + GetSubString(Path, '\', i + 1, i);
    end;
    if Base[len] = '\' then
      setlength(Base, len - 1);
    Result := Base + Result;
  end;
end;

function AddSlashToPath(Path: string): string;
begin
  if Path[length(Path)] <> '\' then
    Result := Path + '\'
  else
    Result := Path;
end;

function DelSlashFromPath(Path: string): string;
begin
  if Path = '' then
  begin
    Result := '';
    exit;
  end;
  if Path[length(Path)] = '\' then
  begin
    setlength(Path, length(Path) - 1);
    Result := Path;
  end
  else
    Result := Path;
end;

function extractDirName(Path: string): string;
var
  i, from, l: integer;
begin
  l := length(Path);
  if Path[l] = '\' then
  begin
    from := l - 1;
  end
  else
  begin
    from := l;
  end;
  for i := from downto 1 do
  begin
    if Path[i] = '\' then
    begin
      Result := Copy(Path, i + 1, from - i);
      Break;
    end;
  end;
end;

initialization

PathDelim := SysUtils.PathDelim;
{$IF defined(MSWINDOWS) or defined(WINDOWS)}
CaseSensitive := False;
{$ELSE}
CaseSensitive := True;
{$IFEND}

end.
