unit uRecorderDataStorage;

{
  Модуль uRecorderDataStorage

  Назначение:
    Минимальное ядро записи данных RecorderLnx. Модуль отвечает за создание
    каталогов кадров записи с автоинкрементом `0001`, `0002`, ... и за простой
    временный CSV-writer sample-ов тегов.

  Место в архитектуре:
    Core/domain. Модуль не зависит от LCL, источников данных и UI. Он получает
    уже подготовленные sample-ы вида tag/time/value и записывает их в текущий
    кадр записи. Подключение к событиям/очередям выполняет внешний слой.

  Ограничения первой версии:
    CSV используется как проверочный открытый формат. Окончательный формат
    хранения Recorder/MERA будет выбран отдельно после анализа совместимости.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  ERecorderDataStorageError = class(Exception);

  { TRecorderRecordFrameManager

    Управляет каталогами кадров записи внутри корневого каталога измерений.
    Кадр записи - это отдельный каталог `0001`, `0002`, ... Внутри кадра
    размещаются файлы данных и метаданные текущей записи. }
  TRecorderRecordFrameManager = class
  private
    fCurrentFrameDir: string;
    fCurrentFrameNo: Integer;
    fRecording: Boolean;
    fRootDir: string;
    function GetCurrentFrameName: string;
    function NormalizeRootDir(const ARootDir: string): string;
  public
    { ARootDir - каталог, внутри которого будут создаваться кадры записи.
      Владение каталогом не передается; каталог создается при OpenNextFrame. }
    constructor Create(const ARootDir: string);

    { Возвращает имя кадра в формате `0001`.

      AFrameNo - номер кадра, начиная с 1. }
    class function FormatFrameName(AFrameNo: Integer): string; static;

    { Проверяет, является ли имя каталога номером кадра `0001`..`9999`. }
    class function IsFrameName(const AName: string): Boolean; static;

    { Находит максимальный существующий номер кадра в RootDir.
      Если кадров нет, возвращает 0. }
    function FindLastFrameNo: Integer;

    { Создает следующий каталог кадра и делает его текущим.
      Возвращает полный путь к созданному каталогу. }
    function OpenNextFrame: string;

    { Записывает минимальные метаданные текущего кадра в frame.ini.

      AProjectName - имя/идентификатор проекта.
      AComment     - произвольный комментарий к кадру записи. }
    procedure WriteFrameInfo(const AProjectName, AComment: string);

    { Закрывает текущий кадр записи на уровне manager-а.
      Файлы данных должны быть закрыты соответствующими writer-ами до вызова. }
    procedure CloseFrame;

    property RootDir: string read fRootDir;
    property Recording: Boolean read fRecording;
    property CurrentFrameNo: Integer read fCurrentFrameNo;
    property CurrentFrameName: string read GetCurrentFrameName;
    property CurrentFrameDir: string read fCurrentFrameDir;
  end;

  { TRecorderCsvTagWriter

    Временный writer sample-ов тегов в CSV. Запись потокобезопасна, но writer
    рассчитан на простой последовательный сценарий: Open -> WriteSample* ->
    Flush/Close. В горячем контуре будущей записи CSV будет заменен или
    дополнен более эффективным writer-ом. }
  TRecorderCsvTagWriter = class
  private
    fFileName: string;
    fFileOpen: Boolean;
    fLock: TRTLCriticalSection;
    fTextFile: TextFile;
    function FloatToCsv(AValue: Double): string;
    procedure RequireOpen;
  public
    constructor Create;
    destructor Destroy; override;

    { Открывает CSV-файл внутри каталога кадра.

      AFrameDir - полный путь к текущему каталогу кадра.
      AFileName - имя CSV-файла внутри кадра, по умолчанию `tags.csv`. }
    procedure Open(const AFrameDir: string; const AFileName: string = 'tags.csv');

    { Записывает одну точку измерения.

      ATagName - имя тега.
      ATimeSec - время sample-а в секундах.
      AValue   - числовое значение sample-а. }
    procedure WriteSample(const ATagName: string; ATimeSec, AValue: Double);

    { Принудительно сбрасывает буфер файла на диск. }
    procedure Flush;

    { Закрывает CSV-файл, если он открыт. }
    procedure Close;

    property FileName: string read fFileName;
    property FileOpen: Boolean read fFileOpen;
  end;

implementation

{ TRecorderRecordFrameManager }

constructor TRecorderRecordFrameManager.Create(const ARootDir: string);
begin
  inherited Create;
  fRootDir := NormalizeRootDir(ARootDir);
end;

function TRecorderRecordFrameManager.NormalizeRootDir(
  const ARootDir: string): string;
begin
  if Trim(ARootDir) = '' then
    raise ERecorderDataStorageError.Create('Record root directory cannot be empty');

  Result := IncludeTrailingPathDelimiter(ExpandFileName(ARootDir));
end;

class function TRecorderRecordFrameManager.FormatFrameName(
  AFrameNo: Integer): string;
begin
  if (AFrameNo < 1) or (AFrameNo > 9999) then
    raise ERecorderDataStorageError.CreateFmt('Invalid record frame number: %d',
      [AFrameNo]);

  Result := Format('%.4d', [AFrameNo]);
end;

class function TRecorderRecordFrameManager.IsFrameName(
  const AName: string): Boolean;
var
  I: Integer;
begin
  Result := Length(AName) = 4;
  if not Result then
    Exit;

  for I := 1 to Length(AName) do
    if not (AName[I] in ['0'..'9']) then
      Exit(False);

  Result := StrToIntDef(AName, 0) > 0;
end;

function TRecorderRecordFrameManager.FindLastFrameNo: Integer;
var
  lFrameNo: Integer;
  lSearchRec: TSearchRec;
begin
  Result := 0;
  if not DirectoryExists(fRootDir) then
    Exit;

  if FindFirst(fRootDir + '*', faDirectory, lSearchRec) = 0 then
  begin
    try
      repeat
        if ((lSearchRec.Attr and faDirectory) <> 0) and
          IsFrameName(lSearchRec.Name) then
        begin
          lFrameNo := StrToInt(lSearchRec.Name);
          if lFrameNo > Result then
            Result := lFrameNo;
        end;
      until FindNext(lSearchRec) <> 0;
    finally
      FindClose(lSearchRec);
    end;
  end;
end;

function TRecorderRecordFrameManager.GetCurrentFrameName: string;
begin
  if fCurrentFrameNo > 0 then
    Result := FormatFrameName(fCurrentFrameNo)
  else
    Result := '';
end;

function TRecorderRecordFrameManager.OpenNextFrame: string;
begin
  if fRecording then
    raise ERecorderDataStorageError.Create('Record frame is already open');

  ForceDirectories(fRootDir);
  fCurrentFrameNo := FindLastFrameNo + 1;
  fCurrentFrameDir := IncludeTrailingPathDelimiter(fRootDir +
    FormatFrameName(fCurrentFrameNo));

  if DirectoryExists(fCurrentFrameDir) then
    raise ERecorderDataStorageError.CreateFmt('Record frame already exists: %s',
      [fCurrentFrameDir]);

  if not ForceDirectories(fCurrentFrameDir) then
    raise ERecorderDataStorageError.CreateFmt('Cannot create record frame: %s',
      [fCurrentFrameDir]);

  fRecording := True;
  Result := fCurrentFrameDir;
end;

procedure TRecorderRecordFrameManager.WriteFrameInfo(const AProjectName,
  AComment: string);
var
  lInfo: TStringList;
begin
  if not fRecording then
    raise ERecorderDataStorageError.Create('Cannot write frame info without open frame');

  lInfo := TStringList.Create;
  try
    lInfo.Add('[Frame]');
    lInfo.Add('Number=' + IntToStr(fCurrentFrameNo));
    lInfo.Add('Name=' + CurrentFrameName);
    lInfo.Add('Project=' + AProjectName);
    lInfo.Add('CreatedLocal=' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now));
    lInfo.Add('Comment=' + AComment);
    lInfo.SaveToFile(fCurrentFrameDir + 'frame.ini');
  finally
    lInfo.Free;
  end;
end;

procedure TRecorderRecordFrameManager.CloseFrame;
begin
  fRecording := False;
  fCurrentFrameDir := '';
  fCurrentFrameNo := 0;
end;

{ TRecorderCsvTagWriter }

constructor TRecorderCsvTagWriter.Create;
begin
  inherited Create;
  InitCriticalSection(fLock);
end;

destructor TRecorderCsvTagWriter.Destroy;
begin
  Close;
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderCsvTagWriter.FloatToCsv(AValue: Double): string;
var
  lFormatSettings: TFormatSettings;
begin
  lFormatSettings := DefaultFormatSettings;
  lFormatSettings.DecimalSeparator := '.';
  Result := FloatToStr(AValue, lFormatSettings);
end;

procedure TRecorderCsvTagWriter.RequireOpen;
begin
  if not fFileOpen then
    raise ERecorderDataStorageError.Create('CSV writer is not open');
end;

procedure TRecorderCsvTagWriter.Open(const AFrameDir: string;
  const AFileName: string);
begin
  if Trim(AFrameDir) = '' then
    raise ERecorderDataStorageError.Create('Frame directory cannot be empty');
  if Trim(AFileName) = '' then
    raise ERecorderDataStorageError.Create('CSV file name cannot be empty');

  Close;
  ForceDirectories(AFrameDir);
  fFileName := IncludeTrailingPathDelimiter(AFrameDir) + AFileName;
  AssignFile(fTextFile, fFileName);
  Rewrite(fTextFile);
  fFileOpen := True;
  Writeln(fTextFile, 'TagName;TimeSec;Value');
  System.Flush(fTextFile);
end;

procedure TRecorderCsvTagWriter.WriteSample(const ATagName: string; ATimeSec,
  AValue: Double);
begin
  if Trim(ATagName) = '' then
    raise ERecorderDataStorageError.Create('Tag name cannot be empty');

  EnterCriticalSection(fLock);
  try
    RequireOpen;
    Writeln(fTextFile, ATagName + ';' + FloatToCsv(ATimeSec) + ';' +
      FloatToCsv(AValue));
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderCsvTagWriter.Flush;
begin
  EnterCriticalSection(fLock);
  try
    if fFileOpen then
      System.Flush(fTextFile);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderCsvTagWriter.Close;
begin
  EnterCriticalSection(fLock);
  try
    if fFileOpen then
    begin
      System.Flush(fTextFile);
      CloseFile(fTextFile);
      fFileOpen := False;
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

end.
