unit uMyFileUtils;

interface

uses
  Windows, SysUtils, StrUtils, Classes, Math, SyncObjs, Variants, shellapi, Registry, Dialogs,

  uMyErrorMessages, uMyDataAndConvert;

const
  c_max_buff_size = 255;

  // константы для списков ComboBox для настройки
  c_ComboBox_COMSettingsBaudRate =
    '75'    + #13#10 + '110'   + #13#10 + '134'   + #13#10 + '150'   + #13#10 + '300'    + #13#10 + '600'    + #13#10 +
    '1200'  + #13#10 + '1800'  + #13#10 + '2400'  + #13#10 + '4800'  + #13#10 + '7200'   + #13#10 + '9600'   + #13#10 +
    '14400' + #13#10 + '19200' + #13#10 + '38400' + #13#10 + '57600' + #13#10 + '115200' + #13#10 + '128000' + #13#10 +
    '234000' + #13#10 + '460800' + #13#10 + '921600';
  c_ComboBox_COMSettingsDataBits =
    '4' + #13#10 + '5' + #13#10 + '6' + #13#10 + '7' + #13#10 + '8';
  c_ComboBox_COMSettingsParityEng =
    'NO' + #13#10 + 'ODD' + #13#10 + 'EVEN' + #13#10 + 'MARK' + #13#10 + 'SPACE';
  c_ComboBox_COMSettingsParityRus =
    'Нет' + #13#10 + 'Чет' + #13#10 + 'Не чет' + #13#10 + 'Маркер' + #13#10 + 'Пробел';
  c_ComboBox_COMSettingsStopsDot =
    '1' + #13#10 + '1.5' + #13#10 + '2';
  c_ComboBox_COMSettingsStopsComma =
    '1' + #13#10 + '1,5' + #13#10 + '2';

Type
  tMyFileMap_BaseAddress_Default = record
    // StrPCopy(MyFileMap_BaseAddress_Default.Buffer1,  AnsiString('111'));
    // string := String(PAnsiChar(@MyFileMap_BaseAddress_Default.Buffer1));

    Buffer1 : array [0..c_max_buff_size] of AnsiChar;
    Buffer2 : array [0..c_max_buff_size] of AnsiChar;
    Buffer3 : array [0..c_max_buff_size] of AnsiChar;
    Buffer4 : array [0..c_max_buff_size] of AnsiChar;
    Path1   : array [0..MAX_PATH] of AnsiChar;
    Path2   : array [0..MAX_PATH] of AnsiChar;

    Byte1, Byte2, Byte3, Byte4 : Byte;
    Integer1, Integer2, Integer3, Integer4 : Integer;
    Integer64_1, Integer64_2, Integer64_3, Integer64_4 : Int64;
    Double1, Double2, Double3, Double4 : Double;
    Extended1, Extended2, Extended3, Extended4 : Extended;
    Boolean1, Boolean2, Boolean3, Boolean4 : Boolean;
End;

type
  //PortBuffer_type = array [0..MaxBufSize-1] of Byte;
  //PortBuffer_type = array of Byte;
  ReadPortBuffer_type = array [0..c_max_buff_size] of Byte;//AnsiChar;

  // работа с файлами
  function CheckFileHandle(const WorkHandle : THandle) : Boolean; // проверка handle на корректность
  function MyFileSizeInt64(const aFilename: String): Int64;             // размер файла
  function GetFileVersionInfo_FieldString(FieldName : String) : String; // получение строк из VersionInfo
  function ClearDirectory(RootFolder: String; EnableRecursion: Boolean = True; DeleteSubFolders : Boolean = true; DeleteRootFolder : Boolean = false): boolean; // очистка папки
  function CheckCreateFolder(FolderPath : String; ShowError : Boolean = true) : Boolean;      // проверка пути для сохранения и создание папки
  function CheckCreateSavePath(SavePath : String; ShowError : Boolean = true) : Boolean;      // проверка пути для сохранения и создание файла
  procedure SaveStringToFile(SavePath : String; str2save : String; EndLine : Boolean = true; ShowError : Boolean = true); // сохранить строку в файл
  function CheckReadPath(ReadPath : String; ShowError : Boolean = true) : Boolean;            // проверка файла для чтения
  function CheckCopyFile(SourceFile, DestFile : String;  Rewrite : Boolean = false; ShowError : Boolean = true) : Boolean;// копирование файла с проверкой
  procedure ReadFileToStrings(const ReadPath : String; var sl : TStringList);                 // считать файл в массив строк

  // запуск файла в другом ПО
  function RunFileByExternalSoft(Handle : Cardinal; FilePathName : String; ShowError : Boolean = true) : boolean;

  // Проецируемые в память файлы
  function MyFileMap_Create(var FileMap_Handle: THandle; var FileMap_BaseAddress: Pointer;
                            const dwMaximumSizeLow: DWORD; Name: String;
                            flProtect: DWORD = PAGE_READWRITE;
                            dwDesiredAccess: DWORD = FILE_MAP_ALL_ACCESS) : Boolean;
  function MyFileMap_Create_Default : Boolean;
  function MyFileMap_Check(var FileMap_Handle: THandle; var FileMap_BaseAddress: Pointer) : Boolean;
  function MyFileMap_Check_Default : Boolean;
  function MyFileMap_Open(const Name: String; var FileMap_Handle: THandle;
                          dwDesiredAccess : DWORD = FILE_MAP_ALL_ACCESS; ShowError : Boolean = False;
                          CloseFileMapHandle : Boolean = False) : Boolean;
  function MyFileMap_Open_Default(dwDesiredAccess : DWORD = FILE_MAP_ALL_ACCESS; ShowError : Boolean = False;
                          CloseFileMapHandle : Boolean = False) : Boolean;
  function MyFileMap_MapView(var FileMap_Handle: THandle; var FileMap_BaseAddress: Pointer; const dwMaximumSizeLow: DWORD;
                             dwDesiredAccess : DWORD = FILE_MAP_ALL_ACCESS) : Boolean;
  function MyFileMap_MapView_Default : Boolean;
  procedure MyFileMap_Close(var FileMap_Handle: THandle; const FileMap_BaseAddress: Pointer);
  procedure MyFileMap_Close_Default;

  // работаем с COM-портом
  function MyComPortListComPorts(COMNameOnly : Boolean = False):TStringList;
  function MyComPortOpen(var WorkComPortHandle : THandle; const ComPortName : string) : Integer;
  function MyComPortClose(var WorkComPortHandle : THandle; const ShowError : Boolean = True) : Integer;
  function MyComPortConfig(WorkComPortHandle : THandle;
                           inBaudRate : Integer = 9600;
                           inByteSize : Byte = 8;
                           inParity   : Byte = NoParity;
                           inStopBits : Byte = OneStopBit) : Integer;
  function MyComPortRead(const WorkComPortHandle : THandle; var Buffer_Byte : array of byte; var Buffer_Count : Cardinal; const dwMilliseconds : DWORD = 1000) : Integer; overload;
  function MyComPortRead(const WorkComPortHandle : THandle; var Buffer_AnsiString : AnsiString; const dwMilliseconds : DWORD = 1000) : Integer; overload;
  function MyComPortWrite(const WorkComPortHandle : THandle; const data : array of byte; const length_data : Cardinal = 0; const dwMilliseconds : DWORD = 1000) : Integer; overload;
  function MyComPortWrite(const WorkComPortHandle : THandle; const data_str : string; const dwMilliseconds : DWORD = 1000) : Integer; overload;
  function MyComPortSendReceive(const WorkComPortHandle : THandle;
                                const SendStr : String;
                                out ReceiveStr : AnsiString;
                                const NeedSend : Boolean = True;
                                const NeedReceive : Boolean = True;
                                const SendTimeout : Integer = 100;
                                const ReceiveTimeout : Integer = 100;
                                const ReceiveRepeatCount : Integer = 1;
                                const ShowError : Boolean = True) : Integer;

var
  CS_FileWrite_String,                  // критическая секция для записи строки в файл
  CS_FileRead_Array : TCriticalSection; // критическая секция для чтения файла в массив

  CS_MyComPortWrite_Buffer : TCriticalSection; // критическая секция для записи буфера
  CS_MyComPortWrite_String : TCriticalSection; // критическая секция для записи строки
  CS_MyComPortRead_Buffer : TCriticalSection;  // критическая секция для чтения буфера
  CS_MyComPortRead_String : TCriticalSection;  // критическая секция для чтения буфера в строку
  CS_MyComPortSendReceive_String : TCriticalSection; // критическая секция для записи-чтения строки

  // Проецируемые в память файлы по дефолту
  MyFileMap_Handle_Default      : THandle; // Описатель объекта проецируемого файла
  MyFileMap_BaseAddress_Default : ^tMyFileMap_BaseAddress_Default; // Указатель на начальный адрес данных
  MyFileMap_Name_Default : string = 'MyFileMap_Name_Default'; // дефолтное имя

  // работаем с COM-портом
  MyComPortLanguage : string = 'RUS';  // язык сообщений
  MyComListNameOnly : Boolean = False; // отображать только с названием COM
  MyComPortHandle   : THandle = 0;  // Хендл COM-порта
  //MyComPortBuffer : PortBuffer_type; //Массив данных
  MyComPortBuffer_Byte : ReadPortBuffer_type;
  MyComPortBuffer_Readed : DWORD;
  MyComPortBuffer_AnsiString : AnsiString;

implementation

// -----------------------------------------------------------------------------
// проверка handle на корректность
function CheckFileHandle(const WorkHandle : THandle) : Boolean;
begin
  Result := (WorkHandle <> 0) and (WorkHandle <> INVALID_HANDLE_VALUE);
end;

// размер файла
function MyFileSizeInt64(const aFilename: String): Int64;
var
  info: TWin32FileAttributeData;
begin
  result := -1;

  if FileExists(aFilename) then
    begin
      if NOT GetFileAttributesEx(PChar(aFileName), GetFileExInfoStandard, @info) then EXIT;

      result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
    end;
end;

// получение строк из VersionInfo
function GetFileVersionInfo_FieldString(FieldName : String) : String;
type
  TTranslation=packed record
    langID : word;
    charset: word;
  end;
var
  n, Len: DWORD;
  Buf, Value: PChar;
  Name : array[0..255] of Char;
  pp: pointer;
  dwBytes: DWORD;
  TheTrans: TTranslation;
  theFixedInfo: TVSFixedFileInfo;
begin
  (* 1 VERSIONINFO
  FILEVERSION 3,60,0,0
  PRODUCTVERSION 1,00,0,0
  FILEFLAGSMASK 0x3FL
  FILEFLAGS 0x00L
  FILEOS 0x40004L
  FILETYPE 0x1L
  FILESUBTYPE 0x0L
  { BLOCK "StringFileInfo"
   { BLOCK "000104E4"
    {  VALUE "CompanyName", "UCL\0"
       VALUE "FileDescription", "\0"
       VALUE "FileVersion", "3.60.0.0\0"
       VALUE "InternalName", "\0"
       VALUE "LegalCopyright", "\0"
       VALUE "OriginalFilename", "\0"
       VALUE "ProductName", "xPOS Администратор\0"
       VALUE "ProductVersion", "1.0.0.0\0" } }
   BLOCK "VarFileInfo"
   { VALUE "Translation", 0x001, 1252 }
  } *)
  Result := '';

  GetModuleFileName(HInstance, Name, High(Name));

  n := GetFileVersionInfoSize(Name, n);

  if n > 0 then
    begin
      Buf := AllocMem(n);
      GetFileVersionInfo(Name, 0, n, Buf);

      if VerQueryValue(Buf, '\', pp, dwBytes) then
        Move(pp^, theFixedInfo, dwBytes);

      if VerQueryValue(Buf, '\VarFileInfo\Translation', pp, dwBytes) then
        Move(pp^, theTrans, dwBytes);

      if VerQueryValue(Buf, PChar('\StringFileInfo\' + inttohex(theTrans.langID, 4) + inttohex(theTrans.charset, 4) + '\' + FieldName), Pointer(Value), Len) then
        Result := Value;

      FreeMem(Buf, n);
    end;
end;

// очистка папки
function ClearDirectory(RootFolder: String; EnableRecursion: Boolean = True; DeleteSubFolders : Boolean = true; DeleteRootFolder : Boolean = false): boolean;
var
  Sr: SysUtils.TSearchRec;
begin
{$I-} // Выключение проверки ошибок ввода/вывода
  if (RootFolder <> '') and (RootFolder[length(RootFolder)] = '\') then
    Delete(RootFolder, Length(RootFolder), 1);
  if FindFirst(RootFolder + '\*.*',  faAnyFile, Sr) = 0 then
    repeat
      if (Sr.Name = '.') or (Sr.Name = '..') then
        continue;
      if (Sr.Attr and faDirectory <> faDirectory) then
        begin
          FileSetReadOnly(RootFolder + '\' + sr.Name, False);
          DeleteFile(RootFolder + '\' + sr.Name);
        end
      else
        if EnableRecursion then ClearDirectory(RootFolder + '\' + sr.Name, EnableRecursion, DeleteSubFolders, DeleteSubFolders);
    until FindNext(sr) <> 0;
  FindClose(sr);

  if DeleteRootFolder then RemoveDir(RootFolder); // Удалит корневой каталог

{$WARN SYMBOL_PLATFORM OFF}
  ClearDirectory := (FileGetAttr(RootFolder) = -1);
{$WARN SYMBOL_PLATFORM ON}
{$I+} // Включение проверки ошибок ввода/вывода
end;

// проверка пути для сохранения и создание папки
function CheckCreateFolder(FolderPath : String; ShowError : Boolean = true) : Boolean;
begin
  Result := False;

  if FolderPath = '' then // пустое значение
    begin
      if ShowError then // Сообщаем об ошибке ввода
        ExitOnError('Пустой путь папки!', 0, 'FolderCreate Error');

      Exit;
    end;

  // проверяем и создаем директорию
  if DirectoryExists(FolderPath) then
    begin
      Result := True;
      Exit;
    end;

  try
    ForceDirectories(FolderPath);
  except on E: Exception do
    if ShowError then // Сообщаем об ошибке
      ExitOnError('Ошибка создания папки:'#13#10 + FolderPath + #13#10 + E.Message, 0, 'FolderCreate Error');
  end;

  if not DirectoryExists(FolderPath) then
    begin
      if ShowError then // Сообщаем об ошибке
        ExitOnError('Ошибка создания папки:'#13#10 + FolderPath, 0, 'FolderCreate Error');

      Exit;
    end;

  Result := True;
end;

// проверка пути для сохранения и создание файла
function CheckCreateSavePath(SavePath : String; ShowError : Boolean = true) : Boolean;
var
  FilePath, FileName : String;
  FileHandle : THandle;
begin
  CheckCreateSavePath := false;

  if FileExists(SavePath) then
    begin
      CheckCreateSavePath := True;
      Exit;
    end;

  if SavePath = '' then
    if ShowError then ExitOnError('Пустой путь для сохранения!', 0, 'FileWrite Error')
    else Exit;

  FilePath := ExtractFilePath(SavePath);
  if not CheckCreateFolder(FilePath, ShowError) then Exit;

  FileName := ExtractFileName(SavePath);
  if FileName = '' then
    if ShowError then ExitOnError('Нет имени файла для сохранения!', 0, 'FileWrite Error')
    else Exit;

  FileHandle := FileCreate(SavePath);
  if not CheckFileHandle(FileHandle) then
    if ShowError then ExitOnError('Не удалось создать файл для сохранения!', 0, 'FileWrite Error')
    else Exit;

  FileClose(FileHandle);
  CheckCreateSavePath := True;
end;

// сохранить строку в файл
procedure SaveStringToFile(SavePath : String; str2save : String; EndLine : Boolean = true; ShowError : Boolean = true);
var
  f : System.Text; //класс текстового файла
begin
  CS_FileWrite_String.Enter;

  CheckCreateSavePath(SavePath, ShowError);

  try
    AssignFile(f, SavePath); //регистрация файла
    //Rewrite(f); //создание файла, если он там есть, то перезаписываеться (старый удаляеться, новый пустой появляеться)

    Append(f);
    if EndLine then
      Writeln(f, str2save)
    else
      Write(f, str2save);

    Flush(f);
  except
    on e: exception do
      begin
        CS_FileWrite_String.Leave;
        CloseFile(f); //закрываем файл
        if ShowError then
          ExitOnError('Ошибка создания файла ' + SavePath + ':' + sLineBreak + e.Message + '!', 0, 'Ошибка создания файла');
        Exit;
      end;
  end;

  CloseFile(f); //закрываем файл

  CS_FileWrite_String.Leave;
end;

// проверка файла для чтения
function CheckReadPath(ReadPath : String; ShowError : Boolean = true) : Boolean;
var FilePath, FileName : String;
begin
  CheckReadPath := false;

  if FileExists(ReadPath) then
    begin
      CheckReadPath := True;
      Exit;
    end;

  if ReadPath = '' then
    if ShowError then ExitOnError('Пустой путь для чтения!', 0, 'FileRead Error')
    else Exit;

  FilePath := ExtractFilePath(ReadPath);
  if FilePath = '' then
    if ShowError then ExitOnError('Не найдена директория для чтения!', 0, 'FileRead Error')
    else Exit;

  if Not DirectoryExists(FilePath) then
    ForceDirectories(FilePath);
  if Not DirectoryExists(FilePath) then
    if ShowError then ExitOnError('Ошибка директории файла для чтения!', 0, 'FileRead Error')
    else Exit;

  FileName := ExtractFileName(FilePath);
  if FileName = '' then
    if ShowError then ExitOnError('Нет имени файла для чтения!', 0, 'FileRead Error')
    else Exit;

  CheckReadPath := True;
end;

// копирование файла с проверкой
function CheckCopyFile(SourceFile, DestFile : String; Rewrite : Boolean = false; ShowError : Boolean = true) : Boolean;
var FilePath, FileName : String;
begin
  CheckCopyFile := False;

  if FileExists(DestFile) then
    begin
      if not Rewrite then
        begin // не надо удалять, если есть
          CheckCopyFile := True;
          Exit;
        end;

      // удаляем, если есть
      if not DeleteFile(DestFile) then
        begin
          if ShowError then
            MessageBox(0, PChar('Не могу удалить файл:' + #13#10 + DestFile), PChar('FileRead Error'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

          Exit;
        end;
    end;

  // проверки исходного файла
  if SourceFile = '' then
    begin
      if ShowError then
        MessageBox(0, PChar('Пустой путь для чтения!'), PChar('FileRead Error'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

      Exit;
    end;

  FilePath := ExtractFilePath(SourceFile);
  if FilePath = '' then
    begin
      if ShowError then
        MessageBox(0, PChar('Не найдена директория для чтения:' + #13#10 + FilePath), PChar('FileRead Error'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

      Exit;
    end;

  if not FileExists(SourceFile) then
    begin
      if ShowError then
        MessageBox(0, PChar('Не найден файл для чтения:' + #13#10 + SourceFile), PChar('FileRead Error'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

      Exit;
    end;

  // проверки финального файла
  if DestFile = '' then
    begin
      if ShowError then
        MessageBox(0, PChar('Пустой путь для записи!'), PChar('FileWrite Error'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

      Exit;
    end;

  FilePath := ExtractFilePath(DestFile);
  if Not DirectoryExists(FilePath) then
    ForceDirectories(FilePath);
  if Not DirectoryExists(FilePath) then
    begin
      if ShowError then
        MessageBox(0, PChar('Ошибка создания директории файла для записи:' + #13#10 + FilePath), PChar('FileWrite Error'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

      Exit;
    end;

  FileName := ExtractFileName(DestFile);
  if FileName = '' then
    begin
      if ShowError then
        MessageBox(0, PChar('Пустое имя файла для записи!'), PChar('FileWrite Error'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

      Exit;
    end;

  if not CopyFile(PChar(SourceFile), PChar(DestFile), True) then
    begin
      if ShowError then
        MessageBox(0, PChar('Не удалось скопировать файл:' + #13#10 + SysErrorMessage(GetLastError)), PChar('FileWrite Error'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

      Exit;
    end;

  CheckCopyFile := True;
end;

// считать файл в массив строк
procedure ReadFileToStrings(const ReadPath : String; var sl : TStringList);
var
  f : System.Text; //класс текстового файла
  StrRead : String;
  i : Integer;
begin
  CS_FileRead_Array.Enter;

  if not CheckReadPath(ReadPath) then Exit;
  i := 1;

  try
    AssignFile(f, ReadPath); //регистрация файла
    //Rewrite(f); //создание файла, если он там есть, то перезаписываеться (старый удаляеться, новый пустой появляеться)

    Reset(f);

    sl.BeginUpdate;
    sl.Clear;
    try
      while (not EOF(f)) do begin
        Readln(f, StrRead);
        sl.Add(StrRead);
        i := i + 1;
      end;
    finally
      sl.EndUpdate;
    end;
  except
    on e: exception do
      begin
        CS_FileRead_Array.Leave;
        CloseFile(f); //закрываем файл
        ExitOnError('Ошибка чтения файла ' + ReadPath + ', строка ' + IntToStr(i) + ' :' + sLineBreak + e.Message + '!', 0, 'Ошибка чтения файла');
        Exit;
      end;
  end;

  CloseFile(f); //закрываем файл

  CS_FileRead_Array.Leave;
end;

// запуск файла в другом ПО
function RunFileByExternalSoft(Handle : Cardinal; FilePathName : String; ShowError : Boolean = true) : boolean;
var
  res : Cardinal;
begin
  res := ShellExecute(Handle,//SettingsFrm.Handle, или = 0
         'open',
         PWideChar(FilePathName),
         '',
         '',
         SW_SHOW);

  Result := res > 31;

  if Result then Exit;// все успешно

  if not ShowError then Exit;

  case res of
    SE_ERR_FNF:             ShowMessage('Open file - Файл не найден' + sLineBreak + FilePathName);
    SE_ERR_PNF:             ShowMessage('Open file - Путь не найден' + sLineBreak + FilePathName);
    SE_ERR_ACCESSDENIED:    ShowMessage('Open file - Доступ к файлу запрещен' + sLineBreak + FilePathName);
    SE_ERR_OOM:             ShowMessage('Open file - He хватает памяти' + sLineBreak + FilePathName);
    SE_ERR_DLLNOTFOUND:     ShowMessage('Open file - Не найдена необходимая DLL' + sLineBreak + FilePathName);
    SE_ERR_SHARE:           ShowMessage('Open file - Файл захвачен другим пользователем' + sLineBreak + FilePathName);
    SE_ERR_ASSOCINCOMPLETE: ShowMessage('Open file - Не полная информация о связанном с файлом приложении' + sLineBreak + FilePathName);
    SE_ERR_DDETIMEOUT:      ShowMessage('Open file - Истекло время на выполнение операции DDE' + sLineBreak + FilePathName);
    SE_ERR_DDEFAIL:         ShowMessage('Open file - Ошибочная операция DDE' + sLineBreak + FilePathName);
    SE_ERR_DDEBUSY:         ShowMessage('Open file - Операция DDE занята' + sLineBreak + FilePathName);
    SE_ERR_NOASSOC:         ShowMessage('Open file - Нет приложения, связанного с файлом' + sLineBreak + FilePathName);
    else                    ShowMessage('Open file - Неизвестная ошибка - ' + IntToStr(res) + sLineBreak + FilePathName);
  end;
end;

// Проецируемые в память файлы
function MyFileMap_Create(var FileMap_Handle: THandle; var FileMap_BaseAddress: Pointer;
                          const dwMaximumSizeLow: DWORD; Name: String;
                          flProtect: DWORD = PAGE_READWRITE;
                          dwDesiredAccess: DWORD = FILE_MAP_ALL_ACCESS) : Boolean;
begin
  //Создаем проецируемый файл с именем CANFileMemory
  FileMap_Handle := CreateFileMapping(
                    MAXDWORD,         // дескриптор файла (INVALID_HANDLE_VALUE - использование файла подкачки)
                    nil,              // PSecurityAttributes; // атрибуты защиты
                    flProtect,        // флаги доступа к файлу, по умолчанию чтение-запись PAGE_READWRITE
                    0,                // старшее двойное слово размера объекта, если более 4Гб, =0
                    dwMaximumSizeLow, // младшее двойное слово размера объекта, SizeOf(tFileMap_BaseAddress)
                    PWideChar(Name)); // имя объекта отображения

  if CheckFileHandle(FileMap_Handle) then
     begin
        //Подключаем файл к адресному пространству и получаем начальный адрес данных
        FileMap_BaseAddress := MapViewOfFile(
                               FileMap_Handle,      // дескриптор объекта, отображающего файл
                               FILE_MAP_ALL_ACCESS, // режим доступа
                               0,                   // старшее двойное слово смещения
                               0,                   // младшее двойное слово смещения
                               dwMaximumSizeLow);   // количество отображаемых байт, SizeOf(tFileMap_BaseAddress)
     end;

  MyFileMap_Create := MyFileMap_Check(FileMap_Handle, FileMap_BaseAddress);
end;

function MyFileMap_Create_Default : Boolean;
begin
  //Создаем проецируемый файл с именем CANFileMemory
  MyFileMap_Handle_Default := CreateFileMapping(
                    MAXDWORD,         // дескриптор файла (INVALID_HANDLE_VALUE - использование файла подкачки)
                    nil,              // PSecurityAttributes; // атрибуты защиты
                    PAGE_READWRITE,   // флаги доступа к файлу, по умолчанию чтение-запись PAGE_READWRITE
                    0,                // старшее двойное слово размера объекта, если более 4Гб, =0
                    SizeOf(tMyFileMap_BaseAddress_Default), // младшее двойное слово размера объекта, SizeOf(tFileMap_BaseAddress)
                    PWideChar(MyFileMap_Name_Default)); // имя объекта отображения

  if CheckFileHandle(MyFileMap_Handle_Default) then
     begin
        //Подключаем файл к адресному пространству и получаем начальный адрес данных
        MyFileMap_BaseAddress_Default := MapViewOfFile(
                               MyFileMap_Handle_Default, // дескриптор объекта, отображающего файл
                               FILE_MAP_ALL_ACCESS, // режим доступа
                               0,                   // старшее двойное слово смещения
                               0,                   // младшее двойное слово смещения
                               SizeOf(tMyFileMap_BaseAddress_Default)); // количество отображаемых байт, SizeOf(tFileMap_BaseAddress)
     end;

  MyFileMap_Create_Default := MyFileMap_Check_Default;
end;

function MyFileMap_Check(var FileMap_Handle: THandle; var FileMap_BaseAddress: Pointer) : Boolean;
begin
  MyFileMap_Check := CheckFileHandle(FileMap_Handle);

  if FileMap_BaseAddress = nil then
    MyFileMap_Check := false;
end;

function MyFileMap_Check_Default : Boolean;
begin
  Result := MyFileMap_Check(MyFileMap_Handle_Default, Pointer(MyFileMap_BaseAddress_Default));
end;

function MyFileMap_Open(const Name: String; var FileMap_Handle: THandle;
                        dwDesiredAccess : DWORD = FILE_MAP_ALL_ACCESS; ShowError : Boolean = False;
                        CloseFileMapHandle : Boolean = False) : Boolean;
begin
  Result := false;

  FileMap_Handle := OpenFileMapping(dwDesiredAccess, // режим доступа, по-умолчанию FILE_MAP_ALL_ACCESS
                                    False,           // флажок наследования
                                    PChar(Name));    // имя объекта

  // проблема при открытии
  if not CheckFileHandle(FileMap_Handle) then
     begin
        if ShowError then
          MessageBox(0, PChar('Не удалось открыть отображаемый файл:' + #13#10 +
                              'Имя: ' + Name + #13#10 +
                              'Handle: ' + IntToStr(FileMap_Handle) + #13#10 +
                              'GetLastError: ' + SysErrorMessage(GetLastError)), PChar('FileMap_Open Error'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

        Exit;
     end;

  // нормально открылся
  if CloseFileMapHandle then
  if CheckFileHandle(FileMap_Handle) then
      CloseHandle(FileMap_Handle);

  Result := true;
end;

function MyFileMap_Open_Default(dwDesiredAccess : DWORD = FILE_MAP_ALL_ACCESS; ShowError : Boolean = False;
                          CloseFileMapHandle : Boolean = False) : Boolean;
begin
  Result := MyFileMap_Open(MyFileMap_Name_Default,
                           MyFileMap_Handle_Default,
                           dwDesiredAccess,
                           ShowError,
                           CloseFileMapHandle);
end;

function MyFileMap_MapView(var FileMap_Handle: THandle; var FileMap_BaseAddress: Pointer; const dwMaximumSizeLow: DWORD;
                           dwDesiredAccess : DWORD = FILE_MAP_ALL_ACCESS) : Boolean;
begin
  if CheckFileHandle(FileMap_Handle) then
     begin
        //Подключаем файл к адресному пространству и получаем начальный адрес данных
        FileMap_BaseAddress := MapViewOfFile(
                               FileMap_Handle,    // дескриптор объекта, отображающего файл
                               dwDesiredAccess,   // режим доступа
                               0,                 // старшее двойное слово смещения
                               0,                 // младшее двойное слово смещения
                               dwMaximumSizeLow); // количество отображаемых байт, SizeOf(tFileMap_BaseAddress)
     end;

  MyFileMap_MapView := MyFileMap_Check(FileMap_Handle, FileMap_BaseAddress);
end;

function MyFileMap_MapView_Default : Boolean;
begin
  Result := MyFileMap_MapView(MyFileMap_Handle_Default,
                              Pointer(MyFileMap_BaseAddress_Default),
                              SizeOf(tMyFileMap_BaseAddress_Default),
                              FILE_MAP_ALL_ACCESS);
end;

procedure MyFileMap_Close(var FileMap_Handle: THandle; const FileMap_BaseAddress: Pointer);
begin
  // Отключим файл от адресного пространства
  if FileMap_BaseAddress <> nil then
    UnmapViewOfFile(FileMap_BaseAddress);

  // Освобождаем объект файла
  if CheckFileHandle(FileMap_Handle) then
      CloseHandle(FileMap_Handle);

  FileMap_Handle := 0;
end;

procedure MyFileMap_Close_Default;
begin
  MyFileMap_Close(MyFileMap_Handle_Default, Pointer(MyFileMap_BaseAddress_Default));
end;

function MyComPortListComPorts(COMNameOnly : Boolean = False):TStringList;
var
  i: Integer;
  PortName : string;
  Ports: TStringList;
  reg: TRegistry;
begin
  Ports  := TStringList.Create;
  Result := TStringList.Create;
  reg    := TRegistry.Create(KEY_READ);

  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.OpenKey('hardware\devicemap\serialcomm', false) then
      try
        Ports.BeginUpdate();
        try
          reg.GetValueNames(Ports);
          for i := Ports.Count-1 downto 0 do // обязательно в обратном порядке
            begin
              PortName := reg.ReadString(Ports.Strings[i]);

              if COMNameOnly then
                if UpperCase(Copy(PortName, 1, 3)) <> 'COM' then
                  Continue; // если проверка на COMxx не прошла - пропускаем

              Result.Add(PortName);
            end;

          Result.CustomSort(@CompareStringWithNumberForCustomSort); // сортируем
        finally
          Ports.EndUpdate();
        end
      finally
        reg.CloseKey();
      end
    else
      Ports.clear();
  finally
    Ports.free();
    reg.free();
  end;
end;

function MyComPortOpen(var WorkComPortHandle : THandle; const ComPortName : string) : Integer;
begin
  //MyComPortClose;
  if CheckFileHandle(WorkComPortHandle) then
    begin
      //COMPortOpen_Error := 'Com порт уже открыт!';
      MyComPortOpen := S_OK;
      Exit;
    end;

  // сокращённое имя может использоваться только для COM1-9, для 10 и выше надо использовать полное имя устройства '\\.\COMn'
  // http://support.microsoft.com/kb/115831
  WorkComPortHandle := CreateFile(PWideChar('\\.\' + ComPortName),
                                  Generic_Read or Generic_Write,
                                  0,
                                  nil,
                                  OPEN_EXISTING,
                                  FILE_FLAG_OVERLAPPED, // асинхронный режим
                                  0);

  MyComPortOpen := GetLastError;
end;

function MyComPortClose(var WorkComPortHandle : THandle; const ShowError : Boolean = True) : Integer;
var res : Integer;
begin
  if CheckFileHandle(WorkComPortHandle) then
  if not CloseHandle(WorkComPortHandle) then
    begin
      res := GetLastError;
      MyComPortClose := res;

      if not ShowError then Exit;

      if UpperCase(MyComPortLanguage) = 'RUS' then
        MessageBox(0, PChar('Ошибка закрытия Com-порта!' + #13#10 + HResultToString(res)), PChar('Close COM-port'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);
      if UpperCase(MyComPortLanguage) = 'ENG' then
        MessageBox(0, PChar('Error closing the Com-port!' + #13#10 + HResultToString(res)), PChar('Close COM-port'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

      Exit;
    end;

  WorkComPortHandle := 0;
  MyComPortClose    := S_OK;
end;

function MyComPortConfig(WorkComPortHandle : THandle;
                       inBaudRate : Integer = 9600;
                       inByteSize : Byte = 8;
                       inParity   : Byte = NoParity;
                       inStopBits : Byte = OneStopBit) : Integer;
var
  Dcb : TDCB; // Структура настроек порта;
  Timeouts : TCommTimeouts; //Переменная таймаутов;
  Cnt, Errors : DWORD;
  Stat : COMSTAT;
  BufDataTmp : array[0..65535] of byte;
begin
  if not CheckFileHandle(WorkComPortHandle) then
      begin
        MyComPortConfig := E_HANDLE;

        if UpperCase(MyComPortLanguage) = 'RUS' then ExitOnError('Неверный описатель Com-порта!', E_HANDLE);
        if UpperCase(MyComPortLanguage) = 'ENG' then ExitOnError('Invalid handle of the Com-port!', E_HANDLE);

        Exit;
      end;

  // Очищаем буферы приема и передачи и очередей чтения/записи;
  if not PurgeComm(WorkComPortHandle, Purge_TXabort or Purge_RXabort or Purge_TXclear or Purge_RXclear) then
    begin
      MyComPortClose(WorkComPortHandle);
      MyComPortConfig := GetLastError;

      if UpperCase(MyComPortLanguage) = 'RUS' then ExitOnError('Не удалось очистить буферы приема и передачи Com-порта!', GetLastError);
      if UpperCase(MyComPortLanguage) = 'ENG' then ExitOnError('The Com-port reception and transmission buffers could not be cleared!', GetLastError);

      Exit;
    end;

  // Настраиваем DCB настройки порта
  if not GetCommState(WorkComPortHandle, DCB) then
    begin
      MyComPortClose(WorkComPortHandle);
      MyComPortConfig := GetLastError;

      if UpperCase(MyComPortLanguage) = 'RUS' then ExitOnError('Не удалось получить настройки DCB Com-порта!', GetLastError);
      if UpperCase(MyComPortLanguage) = 'ENG' then ExitOnError('DCB Com-port settings could not be obtained!', GetLastError);

      Exit;
    end;
  with DCB do
    begin
      BaudRate := inBaudRate;
      ByteSize := inByteSize;
      Parity   := inParity;
      StopBits := inStopBits;
      Flags    := 1; // fBinary := True(1); fDtrControl := DTR_CONTROL_DISABLE(0); fRtsControl := RTS_CONTROL_DISABLE(0);
    end;

  if not SetCommState(WorkComPortHandle, DCB) then
    begin
      MyComPortClose(WorkComPortHandle);
      MyComPortConfig := GetLastError;

      if UpperCase(MyComPortLanguage) = 'RUS' then ExitOnError('Не удалось применить настройки DCB Com-порта!', GetLastError);
      if UpperCase(MyComPortLanguage) = 'ENG' then ExitOnError('DCB Com-port settings could not be applied!', GetLastError);

      Exit;
    end;

  // Установка таймаутов
  if CheckFileHandle(WorkComPortHandle) then
    begin
      GetCommTimeouts(WorkComPortHandle, Timeouts); { Чтение текущих таймаутов и настройка параметров структуры CommTimeouts }
      Timeouts.ReadIntervalTimeout         := MAXDWORD; //Таймаут между двумя символами;
      Timeouts.ReadTotalTimeoutMultiplier  := 0;        //Общий таймаут операции чтения;
      Timeouts.ReadTotalTimeoutConstant    := 1000;     //Константа для общего таймаута операции чтения;
      Timeouts.WriteTotalTimeoutMultiplier := 0;        //Общий таймаут операции записи;
      Timeouts.WriteTotalTimeoutConstant   := 1000;     //Константа для общего таймаута операции записи;
      if not SetCommTimeouts(WorkComPortHandle, Timeouts) then //Установка таймаутов
        begin
          MyComPortClose(WorkComPortHandle);
          MyComPortConfig := GetLastError;

          if UpperCase(MyComPortLanguage) = 'RUS' then ExitOnError('Ошибка установки таймаутов Com-порта!', GetLastError);
          if UpperCase(MyComPortLanguage) = 'ENG' then ExitOnError('Error setting Com-port timeouts!', GetLastError);

          Exit;
        end;
    end;

  // Настройка буферов;
  if not SetupComm(WorkComPortHandle, 4096, 4096) then //Ошибка настройки буферов;
    begin
      MyComPortClose(WorkComPortHandle);
      MyComPortConfig := GetLastError;

      if UpperCase(MyComPortLanguage) = 'RUS' then ExitOnError('Ошибка настройки буферов Com-порта!', GetLastError);
      if UpperCase(MyComPortLanguage) = 'ENG' then ExitOnError('Error configuring Com-port buffers!', GetLastError);

      Exit;
    end;

  // Устанавливаем маску для срабатывания по событию - "Прием байта в порт"
  if not SetCommMask(WorkComPortHandle, EV_RXchar) then //Ошибка настройки маски;
    begin
      MyComPortClose(WorkComPortHandle);
      MyComPortConfig := GetLastError;

      if UpperCase(MyComPortLanguage) = 'RUS' then ExitOnError('Ошибка настройки маски для срабатывания по событию Com-порта!', GetLastError);
      if UpperCase(MyComPortLanguage) = 'ENG' then ExitOnError('Error configuring the mask for triggering a Com-port event!', GetLastError);

      Exit;
    end;

  // сброс ошибки COM порта
  repeat
    ClearCommError(WorkComPortHandle, Errors, @Stat);
    Cnt := Stat.cbInQue;
    ReadFile(WorkComPortHandle, BufDataTmp, Cnt, Cnt, nil);
  until Cnt = 0;

  MyComPortConfig := S_OK;
end;

function MyComPortRead(const WorkComPortHandle : THandle; var Buffer_Byte : array of byte; var Buffer_Count : Cardinal; const dwMilliseconds : DWORD = 1000) : Integer; overload;
var
  OverRead : TOverlapped;
  ComStat : TComStat; //Переменная состояния порта;
  Btr, Temp, Mask, Signal : DWORD;
begin
  CS_MyComPortRead_Buffer.Enter;

  try
    Result := E_FAIL;

    FillChar(Buffer_Byte, SizeOf(Buffer_Byte), #0);
    Buffer_Count := 0;

    // Инициализируем OVERLAPPED
    FillChar(OverRead, SizeOf(OverRead), 0);
    OverRead.Hevent := CreateEvent(Nil, TRUE, FALSE, 'MyReadCOM'{Nil}); //Сигнальный объект событие для ассинхронных операций;

    WaitCommEvent(WorkComPortHandle, Mask, @OverRead); //Ожидаем события (поступление байта);
    Signal := WaitForSingleObject(OverRead.hEvent, dwMilliseconds); //Infinite {Приостанавливаем поток до тех пор пока байт не поступит;}
    if (Signal = Wait_Object_0) then //Если байт поступил;
      begin
        if GetOverlappedResult(WorkComPortHandle, OverRead, Temp, true) then {Проверяем успешность завершения операции;}
          begin
            //if ((Mask and EV_RXchar)<>0) then //Если маска соответствует,
              begin
                ClearCommError(WorkComPortHandle, Temp, @ComStat); //Заполняем структуру ComStat;
                Btr := ComStat.CbInQue; //Получаем из структуры количество байт;
                if Btr > 0 then //Если байты присутствуют,
                  begin
                    ReadFile(WorkComPortHandle, Buffer_Byte, SizeOf(Buffer_Byte), Buffer_Count, @OverRead); //Читаем порт;
                  end;

                  Result := S_OK;
              end;
          end;
      end
    else
      Result := Signal; // WAIT_TIMEOUT = 258

   CloseHandle(OverRead.Hevent);
  finally
  end;

 CS_MyComPortRead_Buffer.Leave;
end;

function MyComPortRead(const WorkComPortHandle : THandle; var Buffer_AnsiString : AnsiString; const dwMilliseconds : DWORD = 1000) : Integer; overload;
var
  i : DWORD;
  WorkComPortBuffer : array [0..c_max_buff_size] of byte;
  WorkComPortBuffer_Readed : DWORD;
begin
  CS_MyComPortRead_String.Enter;

  try
    Result := MyComPortRead(WorkComPortHandle, WorkComPortBuffer, WorkComPortBuffer_Readed, dwMilliseconds);

    Buffer_AnsiString := '';

    if WorkComPortBuffer_Readed > 0 then
    for i := 0 to WorkComPortBuffer_Readed - 1 do
      if i <= SizeOf(WorkComPortBuffer) then
        Buffer_AnsiString := Buffer_AnsiString + AnsiChar(WorkComPortBuffer[i]);
  finally
  end;

  CS_MyComPortRead_String.Leave;
end;

function MyComPortWrite(const WorkComPortHandle : THandle; const data : array of byte; const length_data : Cardinal = 0; const dwMilliseconds : DWORD = 1000) : Integer; overload;
var
  OverWrite : TOverlapped;
  ResultWriteCount, сId : DWORD;
  length_data_int : Cardinal;
begin
  CS_MyComPortWrite_Buffer.Enter;

  try
    Result := E_FAIL;

    if length_data = 0 then
      length_data_int := Length(data)
    else
      length_data_int := length_data;

    if length_data_int > Cardinal(Length(data)) then length_data_int := Length(data);

    // Инициализируем OVERLAPPED
    FillChar(OverWrite, SizeOf(OverWrite), 0);
    OverWrite.hEvent := CreateEvent(nil, TRUE, FALSE, nil);
    if not WriteFile(WorkComPortHandle, data[0], length_data_int, ResultWriteCount, @OverWrite) then
      begin
        if GetLastError = ERROR_IO_PENDING then // Write is pending.
          begin
           сId := WaitForSingleObject(OverWrite.hEvent, dwMilliseconds); //INFINITE

            if сId = WAIT_OBJECT_0 then // OVERLAPPED structure's event has been signaled.
              begin
                if not GetOverlappedResult(WorkComPortHandle, OverWrite, ResultWriteCount, FALSE) then
                  Result := E_PENDING // Error GetOverlappedResult
                else
                  Result := S_OK; // Write operation completed successfully + IntToStr(ResultWriteCount)
              end
            else
              CancelIo(WorkComPortHandle);
          end;
      end;

    CloseHandle(OverWrite.hEvent);
  finally
  end;

  CS_MyComPortWrite_Buffer.Leave;
end;

function MyComPortWrite(const WorkComPortHandle : THandle; const data_str : string; const dwMilliseconds : DWORD = 1000) : Integer; overload;
var
  i : integer;
  data : array of byte;
  length_data : Cardinal;
begin
  CS_MyComPortWrite_String.Enter;

  try
    // загоняем строку в массив
    length_data := Length(data_str);
    SetLength(data, length_data);
    for i := 0 to length_data - 1 do
      data[i] := ord(data_str[i + 1]);

    Result := MyComPortWrite(WorkComPortHandle, data, length_data, dwMilliseconds);
  finally
  end;

  CS_MyComPortWrite_String.Leave;
end;

function MyComPortSendReceive(const WorkComPortHandle : THandle;
                              const SendStr : String;
                              out ReceiveStr : AnsiString;
                              const NeedSend : Boolean = True;
                              const NeedReceive : Boolean = True;
                              const SendTimeout : Integer = 100;
                              const ReceiveTimeout : Integer = 100;
                              const ReceiveRepeatCount : Integer = 1;
                              const ShowError : Boolean = True) : Integer;
var res_int, i : Integer;
begin
  CS_MyComPortSendReceive_String.Enter;
  Result := S_OK;
  ReceiveStr := '';

  try
  if NeedSend then
    begin
      res_int := MyComPortWrite(WorkComPortHandle, SendStr, SendTimeout);

      if res_int <> S_OK then
        begin
          Result := res_int;

          if ShowError then
            begin
              MessageBox(0,
                PChar('Error ComPortWrite: error send string (' + IntToStr(WorkComPortHandle) + ', ' + string(SendStr) + ')' + #13#10 + HResultToString(res_int)),
                PChar('ComPortWrite'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);
            end;
        end;
    end;
  finally
  end;

  try
  if NeedReceive then
    begin
      ReceiveStr := '';

      for i := 1 to ReceiveRepeatCount do
        begin // повторяем чтение пока не получим строку
          res_int := MyComPortRead(WorkComPortHandle, ReceiveStr, ReceiveTimeout);

          if res_int <> S_OK then
            begin
              Result := res_int;

              if ShowError then
                begin
                  MessageBox(0,
                   PChar('Error ComPortRead: error read string. Write string (' + IntToStr(WorkComPortHandle) + ', ' + string(SendStr) + ')' + #13#10 + HResultToString(res_int)),
                   PChar('ComPortRead'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);
                end;

              Break;
            end;

          if ReceiveStr <> '' then Break;
        end;
    end;
  finally
  end;

  CS_MyComPortSendReceive_String.Leave;
end;

// -------------------------------------------------------------------------
// создаем и удаляем критическую секцию
initialization

  CS_FileWrite_String := TCriticalSection.Create;
  CS_FileRead_Array   := TCriticalSection.Create;

  CS_MyComPortWrite_Buffer := TCriticalSection.Create;
  CS_MyComPortWrite_String := TCriticalSection.Create;
  CS_MyComPortRead_Buffer := TCriticalSection.Create;
  CS_MyComPortRead_String := TCriticalSection.Create;
  CS_MyComPortSendReceive_String := TCriticalSection.Create;

finalization

  CS_FileWrite_String.Free;
  CS_FileRead_Array.Free;

  CS_MyComPortWrite_Buffer.Free;
  CS_MyComPortWrite_String.Free;
  CS_MyComPortRead_Buffer.Free;
  CS_MyComPortRead_String.Free;
  CS_MyComPortSendReceive_String.Free;

end.
