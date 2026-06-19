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
{$codepage UTF8}

interface

uses
  Classes, SysUtils, LazUTF8, LConvEncoding;

type
  { Базовое исключение для ошибок хранилища данных }
  ERecorderDataStorageError = class(Exception);

  { TRecorderRecordFrameManager
    Управляет каталогами кадров записи внутри корневого каталога измерений.
    Кадр записи - это отдельный каталог `0001`, `0002`, ... Внутри кадра
    размещаются файлы данных и метаданные текущей записи. }
  TRecorderRecordFrameManager = class
  private
    fCurrentFrameDir: string;          { Путь к текущему кадру записи }
    fCurrentFrameNo: Integer;          { Номер текущего кадра }
    fRecording: Boolean;               { Флаг активности записи }
    fRootDir: string;                  { Корневой каталог для хранения кадров }
    function GetCurrentFrameName: string;
    function NormalizeRootDir(const ARootDir: string): string;
  public
    { Конструктор менеджера кадров записи
      ARootDir - каталог, внутри которого будут создаваться кадры записи.
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
    fFileName: string;                 { Путь к текущему файлу CSV }
    fFileOpen: Boolean;                { Флаг открытого файла }
    fLock: TRTLCriticalSection;        { Секция для защиты записи из разных потоков }
    fTextFile: TextFile;               { Объект текстового файла }
    function FloatToCsv(AValue: Double): string;
    procedure RequireOpen;
  public
    { Конструктор инициализирует критическую секцию }
    constructor Create;
    { Деструктор закрывает файл и освобождает критическую секцию }
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

  { TRecorderMeraTagWriter
    Writes one MERA descriptor record.mera plus binary R8 data/time files
    for every recorded tag. The layout is readable by uMeraFile loader. }
  TRecorderMeraTagWriter = class
  private
    fFrameDir: string;
    fFileOpen: Boolean;
    fLock: TRTLCriticalSection;
    fSignals: TList;
    function FloatToMera(AValue: Double): string;
    function FindSignal(const ATagName: string): TObject;
    function MakeSectionName(const ATagName: string): string;
    procedure RequireOpen;
    procedure WriteDescriptor;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Open(const AFrameDir: string);
    procedure WriteSample(const ATagName, AUnitName, ADescription: string;
      ATimeSec, AValue: Double; APollFrequencyHz: Double);
    procedure WriteBlock(const ATagName, AUnitName, ADescription,
      ASensorCalibration, AAmplifierCalibration: string; const ATimes,
      AValues: array of Double; ACount: Integer; APollFrequencyHz: Double);
    procedure Flush;
    procedure Close;
    property FileOpen: Boolean read fFileOpen;
  end;
implementation

type
  { TRecorderMeraSignalWriter
    Internal writer for one MERA channel. }
  TRecorderMeraSignalWriter = class
  public
    TagName: string;
    SectionName: string;
    SignalUnitName: string;
    Description: string;
    FrequencyHz: Double;
    ValueFormatName: string;
    StartTimeSec: Double;
    ExplicitXRequired: Boolean;
    SensorCalibrationName: string;
    AmplifierCalibrationName: string;
    SampleCount: Int64;
    LastTimeSec: Double;
    HasLastTime: Boolean;
    HasPortions: Boolean;
    DataStream: TFileStream;
    TimeStream: TFileStream;
    PtrStream: TFileStream;
    PrtStream: TFileStream;
    destructor Destroy; override;
  end;

{ TRecorderMeraSignalWriter }

destructor TRecorderMeraSignalWriter.Destroy;
begin
  FreeAndNil(DataStream);
  FreeAndNil(TimeStream);
  FreeAndNil(PtrStream);
  FreeAndNil(PrtStream);
  inherited Destroy;
end;
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

{ TRecorderMeraTagWriter }

constructor TRecorderMeraTagWriter.Create;
begin
  inherited Create;
  fSignals := TList.Create;
  InitCriticalSection(fLock);
end;

destructor TRecorderMeraTagWriter.Destroy;
begin
  Close;
  DoneCriticalSection(fLock);
  FreeAndNil(fSignals);
  inherited Destroy;
end;

function TRecorderMeraTagWriter.FloatToMera(AValue: Double): string;
var
  lFormatSettings: TFormatSettings;
begin
  lFormatSettings := DefaultFormatSettings;
  lFormatSettings.DecimalSeparator := '.';
  Result := FloatToStr(AValue, lFormatSettings);
end;

function TRecorderMeraTagWriter.FindSignal(const ATagName: string): TObject;
var
  I: Integer;
  lSignal: TRecorderMeraSignalWriter;
begin
  Result := nil;
  for I := 0 to fSignals.Count - 1 do
  begin
    lSignal := TRecorderMeraSignalWriter(fSignals[I]);
    if SameText(lSignal.TagName, ATagName) then
      Exit(lSignal);
  end;
end;

function MeraFileSystemName(const AFileName: string): string; forward;

function TRecorderMeraTagWriter.MakeSectionName(const ATagName: string): string;
var
  I: Integer;
  lBase: string;
  lCandidate: string;
  lIndex: Integer;
begin
  lBase := Trim(ATagName);
  for I := 1 to Length(lBase) do
    if lBase[I] in ['\', '/', ':', '*', '?', '"', '<', '>', '|', #0..#31] then
      lBase[I] := '_';
  while Pos('__', lBase) > 0 do
    lBase := StringReplace(lBase, '__', '_', [rfReplaceAll]);
  while (Length(lBase) > 0) and (lBase[1] = '_') do
    Delete(lBase, 1, 1);
  while (Length(lBase) > 0) and (lBase[Length(lBase)] = '_') do
    Delete(lBase, Length(lBase), 1);
  if lBase = '' then
    lBase := 'Signal';

  lCandidate := lBase;
  lIndex := 1;
  while FileExists(MeraFileSystemName(IncludeTrailingPathDelimiter(fFrameDir) + lCandidate + '.dat')) or
    FileExists(MeraFileSystemName(IncludeTrailingPathDelimiter(fFrameDir) + lCandidate + '.x')) do
  begin
    Inc(lIndex);
    lCandidate := Format('%s_%d', [lBase, lIndex]);
  end;
  Result := lCandidate;
end;

function MeraDescriptorFileName(const AFrameDir: string): string;
var
  lDir: string;
begin
  lDir := ExcludeTrailingPathDelimiter(AFrameDir);
  Result := IncludeTrailingPathDelimiter(AFrameDir) + ExtractFileName(lDir) + '.mera';
end;

function MeraFileSystemName(const AFileName: string): string;
begin
  Result := UTF8ToSys(AFileName);
end;

procedure SaveMeraTextFile(const AFileName, AText: string);
var
  lBytes: AnsiString;
  lStream: TFileStream;
begin
  lBytes := AnsiString(UTF8ToCP1251(AText));
  lStream := TFileStream.Create(MeraFileSystemName(AFileName), fmCreate);
  try
    if Length(lBytes) > 0 then
      lStream.WriteBuffer(lBytes[1], Length(lBytes));
  finally
    lStream.Free;
  end;
end;

function ExtractMeraValueFormat(const ADescription: string): string;
var
  lText: string;
  lPos: Integer;
begin
  Result := 'R8';
  lText := ADescription;
  lPos := Pos('type=', LowerCase(lText));
  if lPos <= 0 then
    Exit;

  Delete(lText, 1, lPos + Length('type=') - 1);
  lPos := Pos(';', lText);
  if lPos > 0 then
    lText := Copy(lText, 1, lPos - 1);
  lText := UpperCase(Trim(lText));
  if (lText = 'R4') or (lText = 'R8') then
    Result := lText;
end;

procedure WriteMeraValues(AStream: TStream; const AValues: array of Double;
  ACount: Integer; const AFormatName: string);
var
  I: Integer;
  lSingle: Single;
begin
  if SameText(AFormatName, 'R4') then
    for I := 0 to ACount - 1 do
    begin
      lSingle := AValues[I];
      AStream.WriteBuffer(lSingle, SizeOf(lSingle));
    end
  else
    AStream.WriteBuffer(AValues[0], ACount * SizeOf(Double));
end;

function MeraBlockHasExplicitX(const ATimes: array of Double; ACount: Integer;
  AFrequencyHz: Double): Boolean;
var
  I: Integer;
  lExpectedStep: Double;
  lGapLimit: Double;
begin
  Result := AFrequencyHz <= 0;
  if Result or (ACount <= 1) then
    Exit;

  lExpectedStep := 1.0 / AFrequencyHz;
  lGapLimit := 0.5 / AFrequencyHz;
  for I := 1 to ACount - 1 do
    if Abs((ATimes[I] - ATimes[I - 1]) - lExpectedStep) > lGapLimit then
      Exit(True);
end;

procedure EnsureMeraTimeStream(ASignal: TRecorderMeraSignalWriter;
  const AFrameDir: string);
var
  I: Int64;
  lTime: Double;
begin
  if ASignal.TimeStream <> nil then
    Exit;

  ASignal.TimeStream := TFileStream.Create(MeraFileSystemName(AFrameDir +
    ASignal.SectionName + '.x'), fmCreate);
  if (ASignal.SampleCount > 0) and (ASignal.FrequencyHz > 0) then
    for I := 0 to ASignal.SampleCount - 1 do
    begin
      lTime := ASignal.StartTimeSec + I / ASignal.FrequencyHz;
      ASignal.TimeStream.WriteBuffer(lTime, SizeOf(lTime));
    end;
end;
procedure TRecorderMeraTagWriter.RequireOpen;
begin
  if not fFileOpen then
    raise ERecorderDataStorageError.Create('MERA writer is not open');
end;

procedure TRecorderMeraTagWriter.WriteDescriptor;
var
  I: Integer;
  lText: TStringList;
  lSignal: TRecorderMeraSignalWriter;
begin
  if Trim(fFrameDir) = '' then
    Exit;

  lText := TStringList.Create;
  try
    lText.Add('[MERA]');
    lText.Add('Format=RecorderLnx.MERA');
    lText.Add('Version=1');
    lText.Add('');
    for I := 0 to fSignals.Count - 1 do
    begin
      lSignal := TRecorderMeraSignalWriter(fSignals[I]);
      lText.Add('[' + lSignal.SectionName + ']');
      lText.Add('Name=' + lSignal.TagName);
      lText.Add('Address=' + lSignal.TagName);
      lText.Add('ModName=RecorderLnx');
      lText.Add('XUnitsId=4294967553');
      lText.Add('XUnits=' + CP1251ToUTF8('сек'));
      lText.Add('YFormat=' + lSignal.ValueFormatName);
      lText.Add('YFile=' + lSignal.SectionName + '.dat');
      if lSignal.ExplicitXRequired then
      begin
        lText.Add('XFormat=R8');
        lText.Add('XFile=' + lSignal.SectionName + '.x');
      end;
      if lSignal.HasPortions then
      begin
        lText.Add('PtrFile=' + lSignal.SectionName + '.ptr');
        lText.Add('PrtFile=' + lSignal.SectionName + '.prt');
      end;
      lText.Add('YUnits=' + lSignal.SignalUnitName);
      if not lSignal.ExplicitXRequired then
      begin
        lText.Add('Freq=' + FloatToMera(lSignal.FrequencyHz));
        lText.Add('Start=' + FloatToMera(lSignal.StartTimeSec));
      end;
      if Trim(lSignal.SensorCalibrationName) <> '' then
        lText.Add('tare0="' + lSignal.SensorCalibrationName + '"');
      if Trim(lSignal.AmplifierCalibrationName) <> '' then
        lText.Add('tare1="' + lSignal.AmplifierCalibrationName + '"');
      lText.Add('Comment=' + lSignal.Description);
      lText.Add('');
    end;
    SaveMeraTextFile(MeraDescriptorFileName(fFrameDir), lText.Text);
  finally
    lText.Free;
  end;
end;

procedure TRecorderMeraTagWriter.Open(const AFrameDir: string);
begin
  if Trim(AFrameDir) = '' then
    raise ERecorderDataStorageError.Create('Frame directory cannot be empty');

  Close;
  fFrameDir := IncludeTrailingPathDelimiter(AFrameDir);
  ForceDirectories(fFrameDir);
  fFileOpen := True;
end;

procedure TRecorderMeraTagWriter.WriteSample(const ATagName, AUnitName,
  ADescription: string; ATimeSec, AValue: Double; APollFrequencyHz: Double);
var
  lTimes: array[0..0] of Double;
  lValues: array[0..0] of Double;
begin
  lTimes[0] := ATimeSec;
  lValues[0] := AValue;
  WriteBlock(ATagName, AUnitName, ADescription, '', '', lTimes, lValues, 1,
    APollFrequencyHz);
end;

procedure TRecorderMeraTagWriter.WriteBlock(const ATagName, AUnitName,
  ADescription, ASensorCalibration, AAmplifierCalibration: string; const ATimes,
  AValues: array of Double; ACount: Integer; APollFrequencyHz: Double);
var
  lExpectedTime: Double;
  lGapLimit: Double;
  lLine: AnsiString;
  lOffset: Int64;
  lSignalObject: TObject;
  lSignal: TRecorderMeraSignalWriter;
begin
  if Trim(ATagName) = '' then
    raise ERecorderDataStorageError.Create('Tag name cannot be empty');
  if ACount <= 0 then
    Exit;
  if (ACount > Length(ATimes)) or (ACount > Length(AValues)) then
    raise ERecorderDataStorageError.Create('MERA block count exceeds data length');

  EnterCriticalSection(fLock);
  try
    RequireOpen;
    lSignalObject := FindSignal(ATagName);
    if lSignalObject = nil then
    begin
      lSignal := TRecorderMeraSignalWriter.Create;
      try
        lSignal.TagName := ATagName;
        lSignal.SectionName := MakeSectionName(ATagName);
        lSignal.SignalUnitName := AUnitName;
        lSignal.Description := ADescription;
        lSignal.FrequencyHz := APollFrequencyHz;
        lSignal.ValueFormatName := ExtractMeraValueFormat(ADescription);
        lSignal.StartTimeSec := ATimes[0];
        lSignal.ExplicitXRequired := MeraBlockHasExplicitX(ATimes, ACount,
          APollFrequencyHz);
        lSignal.SensorCalibrationName := ASensorCalibration;
        lSignal.AmplifierCalibrationName := AAmplifierCalibration;
        lSignal.DataStream := TFileStream.Create(MeraFileSystemName(fFrameDir + lSignal.SectionName + '.dat'), fmCreate);
        if lSignal.ExplicitXRequired then
          EnsureMeraTimeStream(lSignal, fFrameDir);
        fSignals.Add(lSignal);
        lSignal := nil;
      finally
        lSignal.Free;
      end;
      lSignal := TRecorderMeraSignalWriter(fSignals[fSignals.Count - 1]);
    end
    else
      lSignal := TRecorderMeraSignalWriter(lSignalObject);

    if (Trim(lSignal.SignalUnitName) = '') and (Trim(AUnitName) <> '') then
      lSignal.SignalUnitName := AUnitName;
    if (Trim(lSignal.Description) = '') and (Trim(ADescription) <> '') then
      lSignal.Description := ADescription;
    if (lSignal.FrequencyHz <= 0) and (APollFrequencyHz > 0) then
      lSignal.FrequencyHz := APollFrequencyHz;
    if (Trim(lSignal.ValueFormatName) = '') or SameText(lSignal.ValueFormatName, 'R8') then
      lSignal.ValueFormatName := ExtractMeraValueFormat(ADescription);
    if MeraBlockHasExplicitX(ATimes, ACount, lSignal.FrequencyHz) then
      lSignal.ExplicitXRequired := True;
    if (Trim(lSignal.SensorCalibrationName) = '') and
      (Trim(ASensorCalibration) <> '') then
      lSignal.SensorCalibrationName := ASensorCalibration;
    if (Trim(lSignal.AmplifierCalibrationName) = '') and
      (Trim(AAmplifierCalibration) <> '') then
      lSignal.AmplifierCalibrationName := AAmplifierCalibration;

    if lSignal.HasLastTime and (lSignal.FrequencyHz > 0) then
    begin
      lExpectedTime := lSignal.LastTimeSec + (1.0 / lSignal.FrequencyHz);
      lGapLimit := 0.5 / lSignal.FrequencyHz;
      if Abs(ATimes[0] - lExpectedTime) > lGapLimit then
      begin
        lSignal.HasPortions := True;
        lOffset := lSignal.SampleCount;
        lLine := AnsiString(FloatToMera(ATimes[0]) + ' ' + IntToStr(lOffset) + LineEnding);
        if lSignal.PtrStream = nil then
          lSignal.PtrStream := TFileStream.Create(MeraFileSystemName(fFrameDir + lSignal.SectionName + '.ptr'), fmCreate);
        if lSignal.PrtStream = nil then
          lSignal.PrtStream := TFileStream.Create(MeraFileSystemName(fFrameDir + lSignal.SectionName + '.prt'), fmCreate);
        lSignal.PtrStream.WriteBuffer(lLine[1], Length(lLine));
        lSignal.PrtStream.WriteBuffer(lLine[1], Length(lLine));
      end;
    end;

    WriteMeraValues(lSignal.DataStream, AValues, ACount, lSignal.ValueFormatName);
    if lSignal.ExplicitXRequired then
    begin
      EnsureMeraTimeStream(lSignal, fFrameDir);
      lSignal.TimeStream.WriteBuffer(ATimes[0], ACount * SizeOf(Double));
    end;
    Inc(lSignal.SampleCount, ACount);
    lSignal.LastTimeSec := ATimes[ACount - 1];
    lSignal.HasLastTime := True;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderMeraTagWriter.Flush;
begin
  { TFileStream buffers are owned by OS/file handle; durable flush is performed
    by closing streams in Close. The method is kept for writer API symmetry. }
end;

procedure TRecorderMeraTagWriter.Close;
var
  I: Integer;
begin
  EnterCriticalSection(fLock);
  try
    if fFileOpen then
    begin
      Flush;
      WriteDescriptor;
      fFileOpen := False;
    end;
    for I := fSignals.Count - 1 downto 0 do
      TObject(fSignals[I]).Free;
    fSignals.Clear;
    fFrameDir := '';
  finally
    LeaveCriticalSection(fLock);
  end;
end;
end.
