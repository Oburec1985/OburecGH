unit uPathMng;

interface

uses inifiles, forms, sysutils, classes, PathUtils, windows, shellapi;

type
  // класс для загрузки путей к ресурсам. При создании он запоминает директорию из
  // которой стартует приложение startdir. В кострукторе в него передается имя файла
  // filename (потом из этого файла считываются пути к ресурсам по алгоритму -
  // имя секции в ini файле - имя списка, ключи - строки в этом списке),
  // при удалении сохраняет списко путей
  // В папке dir содержит путь к самому файлу, который хранит настройки PathMng-а
  // при попытке найти файл проверяет следующие директории: startdir, dir, список
  // директорий определяемый в конфигурационном файле

  cPathMng = class
  protected
    ifile: tIniFile;
    // глубина поиска файлов
    fdeep: integer;
    // путь к файлу с ресурсами
    dir,
    // имя файла с ресурсами
    filename: string;
  public
    // Именованный список, который хранит списки путей.
    // например имя - help. список help будет хранить список путей к хелповым файлам
    PathList: TStringList;
    // путь из которого стартует приложение
    startdir: string;
  protected
    procedure addDefaultPathLists; virtual;
    function GetList(i: integer): TStringList; overload;
    function GetList(name: string): TStringList; overload;
    function AddPathList(section: string): TStringList;
    procedure ReadSectionValuesToList(list: TStringList; section: string);
    procedure WriteSectionValuesToList(list: TStringList; section: string);
  private
    function findListFile(PathList: TStringList; name: string): string;
  public
    // заполняет список flist найдеными файлами в папке dir
    procedure FillFileList(dir: string; flist: tstrings);
    // сделать текущей папку из которой стартовало приложение
    Procedure MakeCurrentStartAppDir;
    // искать во всех путях
    function GetFile(name: string): string; overload;
    // Искать в путях определенных списком list
    function GetFile(name: string; list: TStringList): string; overload;
    // искать в списке определленном как listname
    function GetFile(name: string; listname: string): string; overload;
    // возвращает все найденные файлы в которых содержиться подстрока name
    function GetFileExt(name: string; list: TStringList): string;
    // name - имя файла в котором храниться список путей
    constructor create(name: string); virtual;
    destructor destroy; virtual;
    procedure Save; virtual;
    procedure Load; virtual;
    property deep: integer read fdeep write fdeep;
  end;
// имя может быть кодировано маской '*.xml'
function FindFile(name: string; dir: string; deep: integer): string;

// Dir - стартовая директория; name - имя файла; deep - глубина поиска
// Возвращает путь к найденому файлу
// p_list - список найденых
function FindFileExt(name: string; dir: string; deep: integer;
  p_list: TStringList): string;

// Процедура выводит список директории в список List, начиная с директории,
// указанной в StartDir. Mask - маска для получения файлов
// Источник delphi.mastak.ru
// © А. Подгорецкий
Procedure ScanDir(startdir: String; Mask: string; list: tstrings); overload;
Procedure ScanDir(startdir: String; Mask: string; list: tstrings;
  deep: integer); overload;
Procedure FindFolders(startdir: String; Mask: string; list: tstrings;  deep: integer);
function isDirectory(str: string): boolean;
function isFile(str: string): boolean;
// если toDir существует то запись не происходит!!!
function CopyDir(const fromDir, toDir: string; handle:cardinal): boolean;overload;
// writeExist - если true то пишет даже если существует папка с перезаписью
function CopyDir(const fromDir, toDir: string; writeExist:boolean; handle:cardinal): boolean;overload;
//Проверить на занятость файла
function FileUse(fName: string): boolean;
function CreateTemporaryFile(FileName: string): string;
//CreateTempFile -параметр задает , стоит ли копировать сравниваемые файлы или нет.
//Сделано для избежания ошибок, если файл, к примеру, является запущенным exe
function CompareFiles(File1, File2: string; CreateTempFile: Boolean): Boolean;
function TempDir: string;
function GetFileSize(s:string):integer;

const
  MainSection = 'Main';
  deepkey = 'deep';

implementation


{Собственно функция сравнения: }

function TempDir: string;
{функция возвращает путь к папке временных файлов}
var
  Dir: array[0..MAX_PATH - 1] of char;
begin
  GetTempPath(SizeOf(Dir), Dir);
  Result := Dir;
end;

function GetFileSize(s:string):integer;
var
  F: TFileStream;
begin
  F:=TFileStream.Create(s, fmOpenRead);
  result:=(F.Size);
  F.Free;
end;

function CreateTemporaryFile(FileName: string): string;
//создание временной копии сравниваемых файлов (в папке Temp),
//можно использовать и отдельно для собств. нужд.
//Возвращает имя свежеиспеченного файла.
const
  S: string = '_QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm1234567890';
var
  i, N: integer;
  X: string;
label
  A;
begin
  Randomize;
  A:
  X := '';
  for i := 0 to 7 do {генерируем имя файла длиной 8 знаков}
  begin
    N := Random(Length(S) + 1);
    if N = 0 then
      goto A; {дико извиняюсь за goto. говорят что это ламерство :-)))}
    X := X + S[N];
  end;
  X := TempDir + X + '.tmp';
  if FileExists(pchar(X)) = true then
    goto a
  else
  begin
    if CopyFile(pchar(FileName), pchar(X), true) = true then
      Result := X
    else
      Result := '';
  end;
end;
//CreateTempFile -параметр задает , стоит ли копировать сравниваемые файлы или нет.
//Сделано для избежания ошибок, если файл, к примеру, является запущенным exe
function CompareFiles(File1, File2: string; CreateTempFile: Boolean): Boolean;
var
  F1, F2: file;
  B1, B2: array[0..1023] of Char;
  i1, i2: Integer;
begin
  Result := false;
  if (FileExists(pchar(File1)) = false) or (FileExists(pchar(File2)) = false)
    then
    Exit; {если один из файлов отсутствует , то выходим}
  if CreateTempfile = true then
    {если надо - создаем временные копии в папке Temp}
  begin
    File1 := CreateTemporaryFile(File1);
    File2 := CreateTemporaryFile(File2);
  end;
  Assign(F1, File1);
  Assign(F2, File2);
  Reset(f1, 1);
  Reset(f2, 1);
  if FileSize(f1) <> FileSize(f2) then
    {если размеры файлов не совпадают , то они(файлы) в любом случае не идентичны}
  begin
    CloseFile(F1);
    CloseFile(F2);
    if CreateTempFile = true then
    begin
      DeleteFile(pchar(File1)); {убираем мусор за собой}
      DeleteFile(pchar(File2));
    end;
    Exit;
  end;
  repeat
    {повторяем операции пока файл не закончится :}
    BlockRead(F1, B1, SizeOf(B1), i1);
    BlockRead(F2, B2, SizeOf(B2), i2);
    {: блочно читаем и сравниваем блоки. }

    {как только попадутся два различающихся блока , тут же выходим ,result:=false}
    if B1 <> B2 then
    begin
      Result := false;
      CloseFile(F1);
      CloseFile(F2);
      if CreateTempFile = true then
      begin
        DeleteFile(pchar(File1));
        DeleteFile(pchar(File2));
      end;
      Exit;
    end
    else
      Result := true;
  until EoF(F2); {конец файла}
  CloseFile(F1);
  CloseFile(F2);
  if CreateTempFile = true then
    {если мы создавали временные копии, то их нужно удалить :}
  begin
    DeleteFile(pchar(File1));
    DeleteFile(pchar(File2));
  end;
end;

//Проверить на занятость файла
function FileUse(fName: string): boolean;
var
  HFileRes: HFILE;
begin
  if not fileexists(fname) then
  begin
    result:=false;
    exit;
  end;
  HFileRes := CreateFile(pchar(fName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then CloseHandle(HFileRes);
end;


// Функция копирования каталога
// При копировании в уже существующую папку, будет выводиться запрос на обновление файлов,
// если такие уже имеются. Чтобы этого избежать в функцию добавляется флаг:
// fFlags := FOF_ALLOWUNDO + FOF_NOCONFIRMATION;
// F_ALLOWUNDO – если есть возможность, удаление производится в корзину.
// FOF_SILENT – запрещает показывать стандартное окно операционной системы с прогрессом копирования.
// FOF_RENAMEONCOLLISION – если файл уже существует, копируется с добавлением «Копия» в имя файла или папки.
function CopyDir(const fromDir, toDir: string; handle:cardinal) : Boolean;
var
  fos: TSHFileOpStruct;
  dir:string;
begin
  result := false;
  dir:=extractfiledir(todir);
  ForceDirectories(dir);
  //if DirectoryExists(toDir) then
  //  exit;

  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wnd:=handle;
    lpszProgressTitle := nil;
    wFunc := FO_COPY;
    fFlags:= FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR;
    fAnyOperationsAborted:=false;
    hNameMappings:= Nil;
    lpszProgressTitle:= Nil;

    pFrom := PChar(fromDir + #0);
    pTo := PChar(toDir)
  end;
  result := (0 = ShFileOperation(fos));
end;

// writeExist - если true то пишет даже если существует папка с перезаписью
function CopyDir(const fromDir, toDir: string; writeExist:boolean; handle:cardinal): boolean;overload;
var
  fos: TSHFileOpStruct;
  dir:string;
begin
  result := false;
  dir:=extractfiledir(todir);
  ForceDirectories(dir);
  if DirectoryExists(toDir) then
    exit;

  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wnd:=handle;

    lpszProgressTitle := nil;
    wFunc := FO_COPY;
    fFlags := FOF_ALLOWUNDO +
              FOF_NOCONFIRMATION+
              FOF_SIMPLEPROGRESS;
              // не спрашивать про создание каталога если его нет
              //не подтверждает создание нового каталога, если операция требует, чтобы он был создан.
              //FOF_NOCONFIRMMKDIR;
    pFrom := PChar(fromDir + #0);
    pTo := PChar(toDir)
  end;
  result := (0 = ShFileOperation(fos));
end;

function isDirectory(str: string): boolean;
var
  flags: cardinal;
begin
  flags := GetFileAttributes(@str[1]);
  if (flags and FILE_ATTRIBUTE_DIRECTORY <> 0) then
    result := true
  else
    result := false;
end;

function isFile(str: string): boolean;
var
  flags: cardinal;
begin
  flags := GetFileAttributes(@str[1]);
  if (flags and FILE_ATTRIBUTE_DIRECTORY = 0) then
    result := true
  else
    result := false;
end;

// Dir - стартовая директория; name - имя файла; deep - глубина поиска
// Возвращает путь к найденому файлу
function FindFileExt(name: string; dir: string; deep: integer;
  p_list: TStringList): string;
var
  sr: tSearchRec;
  fullpath, res: string;
  findres: integer;
  ldeep: integer;
  direxist: boolean;
begin
  direxist := DirectoryExists(dir);
  if dir[length(dir)] <> '\' then
    dir := dir + '\';
  if not direxist then
    exit;
  fullpath := dir + name;
  // Поиск файла в текущем каталоге
  findres := FindFirst(dir + name, faAnyFile, sr);
  while findres = 0 do
  begin
    IF (sr.Attr and faDirectory) <> faDirectory then
    begin
      p_list.Add(dir + sr.Name);
      result:=dir + sr.Name;
    end;
    findres := FindNext(sr);
  end;

  if deep <> 0 then
  begin
    findres := FindFirst(dir + '*', faDirectory, sr);
    if findres = 0 then
    begin
      // Ограничиваем поиск по глубине
      if deep <> 0 then
      begin
        while findres = 0 do
        begin
          if (pos(name, sr.Name) > 0) and (length(name) < length(sr.name)) then
          begin
            p_list.Add(dir + sr.Name);
          end;
          // ищем директорию глубже
          if (sr.name = '.') or (sr.name = '..') or (not(sr.Attr = faDirectory)) then
          begin
            findres := FindNext(sr); // продолжить поиск
            continue;
          end;
          res := FindFileExt(name, dir + sr.Name + '\', deep - 1, p_list);
          if res <> '' then
          begin
            findres := FindNext(sr);
            //if deep=0 then
            //  exit;
          end
          else
            findres := FindNext(sr);
        end
      end;
    end;
  end;
  sysutils.FindClose(sr);
end;

// Dir - стартовая директория; name - имя файла; deep - глубина поиска
// Возвращает путь к найденому файлу
function FindFile(name: string; dir: string; deep: integer): string;
var
  sr: tSearchRec;
  fullpath, res: string;
  findres: integer;
  ldeep: integer;
  direxist: boolean;
begin
  dir:=AddSlashToPath(dir);
  direxist := DirectoryExists(dir);
  if not direxist then
    exit;
  // Поиск файла в текущем каталоге
  fullpath := dir + name;
  if FindFirst(fullpath, faAnyFile, sr) = 0 then
  begin
    result :=dir+sr.name;
    exit;
  end
  else // Если не найден, то ищем в других каталогах
  begin
    if deep <> 0 then
    begin
      findres := FindFirst(dir + '*', faDirectory, sr);
      if findres = 0 then
      begin
        // Ограничиваем поиск по глубине
        if deep <> 0 then
        begin
          while findres = 0 do
          begin
            if (sr.name = '.') or (sr.name = '..') or
              (not(sr.Attr = faDirectory)) then
            begin
              findres := FindNext(sr); // продолжить поиск
              continue;
            end;
            res := FindFile(name, dir + sr.Name + '\', deep - 1);
            if res <> '' then
            begin
              inc(deep);
              result := res;
              exit;
            end
            else
              findres := FindNext(sr);
          end
        end;
      end;
    end;
  end;
  sysutils.FindClose(sr);
end;

function cPathMng.findListFile(PathList: TStringList; name: string): string;
var
  str: string;
  i: integer;
begin
  if PathList.Count = 0 then
  begin
    str := FindFile(name, startdir, deep);
    if str <> '' then
    begin
      result := RelativePathToAbsolute(getcurrentdir, str);
      exit;
    end;
  end
  else
  begin
    for i := 0 to PathList.Count - 1 do
    begin
      str := FindFile(name, PathList.strings[i], deep);
      if str <> '' then
      begin
        result := RelativePathToAbsolute(getcurrentdir, str);
        exit;
      end;
    end;
  end;
  str := '';
end;

function cPathMng.GetFileExt(name: string; list: TStringList): string;
var
  l: TStringList;
  i: integer;
begin
  if PathList.Count = 0 then
  begin
    if (name[1] <> '\') and (startdir[length(startdir)] <> '\') then
    begin
      startdir := startdir + '\';
    end;
    result := FindFileExt(name, startdir, deep, list);
  end
  else
  begin
    for i := 0 to PathList.Count - 1 do
    begin
      l := GetList(i);
      result := FindFileExt(name, PathList.strings[i], deep, list);
    end;
  end;
end;

Procedure ScanDir(startdir: String; Mask: string; list: tstrings);
{ Процедура выводит список директории в список List, начиная с директории, указанной в StartDir. Mask - маска для получения файлов
  Источник delphi.mastak.ru
  © А. Подгорецкий }
Var
  SearchRec: tSearchRec;
Begin
  if not DirectoryExists(startdir) then exit;
  IF Mask = '' then
    Mask := '*.*';
  IF startdir[length(startdir)] <> '\' then
    startdir := startdir + '\';
  IF FindFirst(startdir + Mask, faAnyFile, SearchRec) = 0 then
  Begin
    Repeat
      { Чтобы выполнение "не подвисало" }
      //Application.ProcessMessages;
      IF (SearchRec.Attr and faDirectory) <> faDirectory then
        list.Add(startdir + SearchRec.Name)
      else
      begin
        // если вошли в каталог но не текущий и не уровнем выше
        if (SearchRec.Name <> '..') and (SearchRec.Name <> '.') then
        begin
          list.Add(startdir + SearchRec.Name + '\');
          { Рекурсивный вызов }
          ScanDir(startdir + SearchRec.Name + '\', Mask, list);
        end;
      end;
    Until FindNext(SearchRec) <> 0;
    sysutils.FindClose(SearchRec);
  End; { IF }
end;

Procedure ScanDir(startdir: String; Mask: string; list: tstrings;
  deep: integer);
Var
  SearchRec: tSearchRec;
Begin
  if not DirectoryExists(startdir) then exit;
  IF Mask = '' then
    Mask := '*.*';
  IF startdir[length(startdir)] <> '\' then
    startdir := startdir + '\';
  IF FindFirst(startdir + Mask, faAnyFile, SearchRec) = 0 then
  Begin
    Repeat
      { Чтобы выполнение "не подвисало" }
      //Application.ProcessMessages;
      IF (SearchRec.Attr and faDirectory) <> faDirectory then
      begin
        list.Add(startdir + SearchRec.Name)
      end
      else
      begin
        if deep > 1 then
        begin
          // если вошли в каталог но не текущий и не уровнем выше
          if (SearchRec.Name <> '..') and (SearchRec.Name <> '.') then
          begin
            // List.Add(StartDir + SearchRec.Name + '\');
            { Рекурсивный вызов }
            ScanDir(startdir + SearchRec.Name + '\', Mask, list, deep - 1);
          end;
        end;
      end;
    Until FindNext(SearchRec) <> 0;
    sysutils.FindClose(SearchRec);
  End;
end;

Procedure FindFolders(startdir: String; Mask: string; list: tstrings;
  deep: integer);
Var
  SearchRec: tSearchRec;
Begin
  if not DirectoryExists(startdir) then exit;
  IF Mask = '' then
    Mask := '*.*';
  IF startdir[length(startdir)] <> '\' then
    startdir := startdir + '\';
  IF FindFirst(startdir + Mask, faAnyFile, SearchRec) = 0 then
  Begin
    Repeat
      { Чтобы выполнение "не подвисало" }
      //Application.ProcessMessages;
      IF (SearchRec.Attr and faDirectory) = faDirectory then
      begin
        list.Add(startdir + SearchRec.Name)
      end
      else
      begin
        if deep > 1 then
        begin
          // если вошли в каталог но не текущий и не уровнем выше
          if (SearchRec.Name <> '..') and (SearchRec.Name <> '.') then
          begin
            // List.Add(StartDir + SearchRec.Name + '\');
            { Рекурсивный вызов }
            ScanDir(startdir + SearchRec.Name + '\', Mask, list, deep - 1);
          end;
        end;
      end;
    Until FindNext(SearchRec) <> 0;
    sysutils.FindClose(SearchRec);
  End
  else
  begin
  end;
end;

procedure cPathMng.FillFileList(dir: string; flist: tstrings);
begin
  if DirectoryExists(dir) then
  begin
    ScanDir(dir, '*.*', flist);
  end;
end;

function cPathMng.GetFile(name: string): string;
var
  list: TStringList;
  i: integer;
begin
  for i := 0 to PathList.Count - 1 do
  begin
    list := GetList(i);
    result := GetFile(name, list);
  end;
end;

function cPathMng.GetFile(name: string; list: TStringList): string;
begin
  setcurrentdir(dir);
  result := findListFile(list, name);
  if result <> '' then
  begin
    result := RelativePathToAbsolute(dir, result);
    exit;
  end;
  setcurrentdir(startdir);
  if result = '' then
    result := findListFile(list, name);
end;

function cPathMng.GetFile(name: string; listname: string): string;
var
  list: TStringList;
  i: integer;
begin
  if PathList.Find(listname, i) then
  begin
    list := GetList(i);
    result := GetFile(name, list);
  end
  else
  begin
    result := findListFile(list, name);
  end;
end;

constructor cPathMng.create(name: string);
begin
  startdir := extractfiledir(Application.ExeName);

  PathList := TStringList.create;
  PathList.sorted := true;
  filename := name;
  if not fileexists(filename) then
  begin
    if filename <> '' then
    begin
      ifile := tIniFile.create(filename);
      filename := startdir + extractfilename(Application.ExeName);
      tIniFile.create(filename);
      deep := 2;
    end;
  end
  else
  begin
    dir := extractfiledir(filename);
    filename := RelativePathToAbsolute(startdir, filename);
    ifile := tIniFile.create(filename);
    addDefaultPathLists;
    Load;
  end;
end;

procedure cPathMng.WriteSectionValuesToList(list: TStringList; section: string);
var
  i: integer;
  str: string;
begin
  str := '';
  for i := 0 to list.Count - 1 do
  begin
    if i <> 0 then
      str := inttostr(i);
    ifile.WriteString(section, section + str, list.strings[i]);
  end;
end;

procedure cPathMng.ReadSectionValuesToList(list: TStringList; section: string);
var
  strlist: TStringList;
  str: string;
  i: integer;
begin
  strlist := TStringList.create;
  // Считываем все директории для объектов
  ifile.ReadSection(section, strlist);
  for i := 0 to strlist.Count - 1 do
  begin
    str := ifile.ReadString(section, strlist.strings[i],
      extractfiledir(Application.ExeName) + '\meshes\');
    if str[length(str)] <> '\' then
      str := str + '\';
    list.Add(str);
  end;
  strlist.destroy;
end;

procedure cPathMng.Load;
var
  str: string;
  list: TStringList;
  i: integer;
begin
  deep := ifile.ReadInteger(MainSection, deepkey, 2);
  for i := 0 to PathList.Count - 1 do
  begin
    list := GetList(i);
    ReadSectionValuesToList(list, PathList.strings[i]);
  end;
end;

procedure cPathMng.Save;
var
  i: integer;
  list: TStringList;
begin
  for i := 0 to PathList.Count - 1 do
  begin
    list := GetList(i);
    WriteSectionValuesToList(list, PathList.strings[i]);
  end;
  if ifile <> nil then
    ifile.WriteInteger(MainSection, deepkey, deep);
end;

destructor cPathMng.destroy;
var
  list: TStringList;
begin
  Save;
  while PathList.Count <> 0 do
  begin
    list := GetList(0);
    list.destroy;
    PathList.Delete(0);
  end;
  PathList.destroy;
  if ifile <> nil then
    ifile.destroy;
  inherited;
end;

function cPathMng.AddPathList(section: string): TStringList;
var
  i: integer;
begin
  if not PathList.Find(section, i) then
  begin
    result := TStringList.create;
    result.sorted := true;
    PathList.Addobject(section, result);
  end
  else
    result := nil;
end;

function cPathMng.GetList(name: string): TStringList;
var
  i: integer;
begin
  if PathList.Find(name, i) then
  begin
    result := GetList(i);
  end
  else
    result := nil;
end;

Procedure cPathMng.MakeCurrentStartAppDir;
begin
  setcurrentdir(startdir);
end;

function cPathMng.GetList(i: integer): TStringList;
begin
  result := TStringList(PathList.Objects[i]);
end;

procedure cPathMng.addDefaultPathLists;
begin

end;

end.
