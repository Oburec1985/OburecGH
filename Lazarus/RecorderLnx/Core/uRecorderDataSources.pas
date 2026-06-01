unit uRecorderDataSources;

{
  Модуль uRecorderDataSources

  Назначение:
    Базовый слой источников данных RecorderLnx. Источник данных создает свои теги,
    запускается/останавливается и по вызову Tick публикует новые значения в
    TRecorderTagRegistry.

  Место в архитектуре:
    Core/domain. Модуль не зависит от LCL, устройств, файлов записи и потоков UI.
    Поточный сбор данных надстроен отдельным runner-классом: рабочий поток
    вызывает Tick источника с его UpdateTimeMs и не знает деталей устройства.

  Ограничения первой версии:
    Потоковый runner пока обслуживает один источник. Групповой менеджер потоков,
    диагностика связи и приоритеты будут отдельным слоем.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uMeraFile;

type
  ERecorderDataSourceError = class(Exception);

  { Состояние источника данных. }
  TRecorderDataSourceState = (
    dssStopped,
    dssRunning
  );

  { IRecorderDataSource

    Минимальный интерфейс источника данных.

    SourceId     - стабильный идентификатор источника в конфигурации проекта.
    Name         - человекочитаемое имя для логов и UI.
    UpdateTimeMs - период опроса/генерации данных в миллисекундах.
    State        - текущее состояние источника. }
  IRecorderDataSource = interface
    ['{B955E78D-DA62-48CC-8B3D-93372C82A06F}']
    function GetSourceId: string;
    function GetName: string;
    function GetUpdateTimeMs: Cardinal;
    function GetState: TRecorderDataSourceState;

    { Создает/подключает теги источника в общем registry.

      ARegistry - общий реестр тегов проекта. Владение не передается. }
    procedure ConfigureTags(ARegistry: TRecorderTagRegistry);

    { Переводит источник в рабочее состояние. Теги должны быть настроены заранее. }
    procedure Start;

    { Останавливает источник. После Stop вызов Tick считается ошибкой контракта. }
    procedure Stop;

    { Публикует один шаг данных. В потоковой версии будет вызываться worker-thread. }
    procedure Tick;

    property SourceId: string read GetSourceId;
    property Name: string read GetName;
    property UpdateTimeMs: Cardinal read GetUpdateTimeMs;
    property State: TRecorderDataSourceState read GetState;
  end;

  { TRecorderDataSourceBase

    Базовый класс источника данных. Потомки реализуют создание тегов и один
    шаг генерации/опроса данных в DoCreateTags/DoTick. }
  TRecorderDataSourceBase = class(TInterfacedObject, IRecorderDataSource)
  private
    fName: string;
    fRegistry: TRecorderTagRegistry;
    fSourceId: string;
    fState: TRecorderDataSourceState;
    fUpdateTimeMs: Cardinal;
  protected
    function GetSourceId: string;
    function GetName: string;
    function GetUpdateTimeMs: Cardinal;
    function GetState: TRecorderDataSourceState;

    { Проверяет, что registry уже подключен, и возвращает его. }
    function RequireRegistry: TRecorderTagRegistry;

    { Потомок создает или находит нужные ему теги. }
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); virtual; abstract;

    { Потомок публикует один шаг данных. }
    procedure DoTick; virtual; abstract;

    property Registry: TRecorderTagRegistry read fRegistry;
  public
    { ASourceId     - стабильный идентификатор источника.
      AName         - имя источника для UI/логов.
      AUpdateTimeMs - период обновления, должен быть больше нуля. }
    constructor Create(const ASourceId, AName: string; AUpdateTimeMs: Cardinal);

    procedure ConfigureTags(ARegistry: TRecorderTagRegistry); virtual;
    procedure Start; virtual;
    procedure Stop; virtual;
    procedure Tick; virtual;

    property SourceId: string read GetSourceId;
    property Name: string read GetName;
    property UpdateTimeMs: Cardinal read GetUpdateTimeMs;
    property State: TRecorderDataSourceState read GetState;
  end;

  { TMockSineDataSource

    Отладочный источник синусоидального сигнала. Он нужен как первый
    контролируемый поставщик данных для UI, плагинов, записи и тестов. }
  TMockSineDataSource = class(TRecorderDataSourceBase)
  private
    fAmplitude: Double;
    fFrequencyHz: Double;
    fPhaseRad: Double;
    fSampleIndex: Int64;
    fTagName: string;
    fTimeSec: Double;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    { ASourceId     - стабильный идентификатор источника.
      ATagName      - имя тега, куда источник будет писать сигнал.
      AUpdateTimeMs - период генерации точки.
      AAmplitude    - амплитуда синусоиды.
      AFrequencyHz  - частота синусоиды в герцах.
      APhaseRad     - начальная фаза в радианах. }
    constructor Create(const ASourceId, ATagName: string; AUpdateTimeMs: Cardinal;
      AAmplitude, AFrequencyHz: Double; APhaseRad: Double = 0);

    property TagName: string read fTagName;
    property Amplitude: Double read fAmplitude write fAmplitude;
    property FrequencyHz: Double read fFrequencyHz write fFrequencyHz;
    property PhaseRad: Double read fPhaseRad write fPhaseRad;
    property TimeSec: Double read fTimeSec;
    property SampleIndex: Int64 read fSampleIndex;
  end;

  { TRecorderMeraFileDataSource

    Built-in playback source for MERA files. It replaces the old plugin layer:
    selected MERA channels are mapped to recorder tags and Tick publishes file
    samples into TRecorderTagRegistry. }
  TRecorderMeraFileDataSource = class(TRecorderDataSourceBase)
  private
    fBlockLength: Cardinal;
    fFileName: string;
    fLoop: Boolean;
    fPlayRangeMinSec: Double;
    fPlaybackSpeed: Cardinal;
    fPlaybackSignals: TList;
    fStartTickMs: QWord;
    fSelectedTagNames: TStringList;
    function IsSignalSelected(ASignal: TMeraSignalInfo): Boolean;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId, AFileName: string; AUpdateTimeMs: Cardinal;
      ASelectedTagNames: TStrings = nil; ABlockLength: Cardinal = 128;
      APlaybackSpeed: Cardinal = 1);
    destructor Destroy; override;
    procedure Start; override;
    procedure Stop; override;

    property FileName: string read fFileName;
    property BlockLength: Cardinal read fBlockLength;
    property LoopPlayback: Boolean read fLoop write fLoop;
    property PlaybackSpeed: Cardinal read fPlaybackSpeed;
  end;

  { TRecorderDataSourceThread

    Рабочий поток одного источника данных. Поток хранит interface-ссылку на
    источник, вызывает Start, затем Tick с паузой UpdateTimeMs до Terminate.
    Все события данных публикуются в потоке источника; UI обязан принимать их
    через будущий dispatcher, а не менять LCL-компоненты напрямую. }
  TRecorderDataSourceThread = class(TThread)
  private
    fLastErrorMessage: string;
    fSource: IRecorderDataSource;
    fTickCount: Int64;
    procedure SleepInterruptible(AMilliseconds: Cardinal);
  protected
    procedure Execute; override;
  public
    { ASource - источник данных. Поток хранит interface-ссылку, поэтому объект
      источника нельзя освобождать вручную, пока thread существует. }
    constructor Create(const ASource: IRecorderDataSource);

    property Source: IRecorderDataSource read fSource;
    property TickCount: Int64 read fTickCount;
    property LastErrorMessage: string read fLastErrorMessage;
  end;

  { TRecorderDataSourceManager

    Реестр и групповой runner источников данных. Manager хранит interface-ссылки
    на источники, настраивает их теги, запускает отдельный TRecorderDataSourceThread
    на каждый источник и останавливает все потоки как одну группу.

    Важно: manager не является владельцем TRecorderTagRegistry и не занимается UI.
    Его задача - lifecycle источников сбора данных. }
  TRecorderDataSourceManager = class
  private type
    TSourceContext = class
    public
      Source: IRecorderDataSource;
      Thread: TRecorderDataSourceThread;
    end;
  private
    fLastErrors: TStringList;
    fRegistry: TRecorderTagRegistry;
    fRunning: Boolean;
    fSources: TList;
    function GetLastError(AIndex: Integer): string;
    function GetLastErrorCount: Integer;
    function GetSource(AIndex: Integer): IRecorderDataSource;
    function GetSourceContext(AIndex: Integer): TSourceContext;
    function GetSourceCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    { Добавляет источник в manager.

      ASource - источник данных. Manager хранит interface-ссылку. }
    procedure AddSource(const ASource: IRecorderDataSource);

    { Ищет источник по SourceId без учета регистра. }
    function FindSource(const ASourceId: string): IRecorderDataSource;

    { Настраивает теги всех источников в общем registry.

      ARegistry - общий реестр тегов проекта. Владение не передается. }
    procedure ConfigureTagsAll(ARegistry: TRecorderTagRegistry);

    { Запускает все источники, создавая отдельный thread-runner на каждый. }
    procedure StartAll;

    { Останавливает все thread-runner-ы через Terminate/WaitFor и собирает ошибки. }
    procedure StopAll;

    { Останавливает источники и очищает список. }
    procedure Clear;

    property Running: Boolean read fRunning;
    property SourceCount: Integer read GetSourceCount;
    property Sources[AIndex: Integer]: IRecorderDataSource read GetSource;
    property LastErrorCount: Integer read GetLastErrorCount;
    property LastErrors[AIndex: Integer]: string read GetLastError;
  end;

function RecorderDataSourceStateToString(AState: TRecorderDataSourceState): string;

implementation

function RecorderDataSourceStateToString(AState: TRecorderDataSourceState): string;
begin
  case AState of
    dssStopped:
      Result := 'Stopped';
    dssRunning:
      Result := 'Running';
  else
    Result := 'Unknown';
  end;
end;

{ TRecorderDataSourceBase }

constructor TRecorderDataSourceBase.Create(const ASourceId, AName: string;
  AUpdateTimeMs: Cardinal);
begin
  inherited Create;
  if ASourceId = '' then
    raise ERecorderDataSourceError.Create('Data source id cannot be empty');
  if AName = '' then
    raise ERecorderDataSourceError.Create('Data source name cannot be empty');
  if AUpdateTimeMs = 0 then
    raise ERecorderDataSourceError.Create('Data source update time must be positive');

  fSourceId := ASourceId;
  fName := AName;
  fUpdateTimeMs := AUpdateTimeMs;
  fState := dssStopped;
end;

function TRecorderDataSourceBase.GetSourceId: string;
begin
  Result := fSourceId;
end;

function TRecorderDataSourceBase.GetName: string;
begin
  Result := fName;
end;

function TRecorderDataSourceBase.GetUpdateTimeMs: Cardinal;
begin
  Result := fUpdateTimeMs;
end;

function TRecorderDataSourceBase.GetState: TRecorderDataSourceState;
begin
  Result := fState;
end;

function TRecorderDataSourceBase.RequireRegistry: TRecorderTagRegistry;
begin
  if fRegistry = nil then
    raise ERecorderDataSourceError.CreateFmt(
      'Data source %s tags are not configured', [fSourceId]);
  Result := fRegistry;
end;

procedure TRecorderDataSourceBase.ConfigureTags(ARegistry: TRecorderTagRegistry);
begin
  if ARegistry = nil then
    raise ERecorderDataSourceError.Create('Tag registry cannot be nil');
  if fState <> dssStopped then
    raise ERecorderDataSourceError.CreateFmt(
      'Data source %s cannot configure tags while running', [fSourceId]);

  fRegistry := ARegistry;
  DoCreateTags(ARegistry);
end;

procedure TRecorderDataSourceBase.Start;
begin
  RequireRegistry;
  fState := dssRunning;
end;

procedure TRecorderDataSourceBase.Stop;
begin
  fState := dssStopped;
end;

procedure TRecorderDataSourceBase.Tick;
begin
  if fState <> dssRunning then
    raise ERecorderDataSourceError.CreateFmt(
      'Data source %s tick called while stopped', [fSourceId]);

  DoTick;
end;

{ TMockSineDataSource }

constructor TMockSineDataSource.Create(const ASourceId, ATagName: string;
  AUpdateTimeMs: Cardinal; AAmplitude, AFrequencyHz: Double; APhaseRad: Double);
begin
  if ATagName = '' then
    raise ERecorderDataSourceError.Create('Mock sine tag name cannot be empty');

  inherited Create(ASourceId, 'Mock sine data source', AUpdateTimeMs);
  fTagName := ATagName;
  fAmplitude := AAmplitude;
  fFrequencyHz := AFrequencyHz;
  fPhaseRad := APhaseRad;
end;

procedure TMockSineDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  lTag: TRecorderTag;
begin
  lTag := ARegistry.FindByName(fTagName);
  if lTag = nil then
    lTag := ARegistry.CreateTag(fTagName, 4096);

  lTag.Address := 'virtual';
  lTag.UnitName := 'a.u.';
  lTag.Description := 'Mock sine signal';
  lTag.SourceId := SourceId;
  lTag.ModuleType := 'virtual';
  lTag.PollFrequencyHz := 1000.0 / UpdateTimeMs;
end;

procedure TMockSineDataSource.DoTick;
var
  lValue: Double;
begin
  { Tick делает только расчет одной точки и публикацию в тег. В будущем тяжелые
    источники смогут использовать заранее выделенные буферы или аппаратное ускорение. }
  lValue := fAmplitude * Sin((2 * Pi * fFrequencyHz * fTimeSec) + fPhaseRad);
  Registry.PublishValue(fTagName, fTimeSec, lValue);

  Inc(fSampleIndex);
  fTimeSec := fTimeSec + (UpdateTimeMs / 1000.0);
end;

type
  TMeraPlaybackSignal = class
  private
    fCachedTimeSec: Double;
    fCachedValue: Double;
    fDataStream: TFileStream;
    fHasCachedSample: Boolean;
    fInfo: TMeraSignalInfo;
    fSampleIndex: Int64;
    fTagName: string;
    fTimeStream: TFileStream;
    function GetDataSize: Integer;
    function IsScalar: Boolean;
    function ReadRawValue(out AValue: Double): Boolean;
    function ReadSample(out ATimeSec, AValue: Double): Boolean;
    function EnsureCachedSample: Boolean;
  public
    constructor Create(ASignal: TMeraSignalInfo);
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure Rewind;
    function PublishNext(ARegistry: TRecorderTagRegistry): Boolean;
    function PublishScalarDue(ARegistry: TRecorderTagRegistry; APlayTimeSec: Double;
      AMaxSamples: Integer): Boolean;
    function PublishVectorDue(ARegistry: TRecorderTagRegistry; APlayTimeSec: Double;
      ABlockLength: Cardinal; AMaxBlocks: Integer): Boolean;
    property TagName: string read fTagName;
  end;

constructor TMeraPlaybackSignal.Create(ASignal: TMeraSignalInfo);
begin
  inherited Create;
  if ASignal = nil then
    raise ERecorderDataSourceError.Create('MERA signal cannot be nil');

  fInfo := ASignal;
  fTagName := MeraSignalToRecorderTagName(ASignal);
end;

destructor TMeraPlaybackSignal.Destroy;
begin
  Close;
  inherited Destroy;
end;

function TMeraPlaybackSignal.GetDataSize: Integer;
begin
  Result := MeraValueTypeSize(fInfo.DataType);
end;

function TMeraPlaybackSignal.IsScalar: Boolean;
begin
  Result := fInfo.HasXData or (fInfo.FrequencyHz <= 0);
end;

procedure TMeraPlaybackSignal.Open;
begin
  Close;
  if not FileExists(fInfo.FileName) then
    raise ERecorderDataSourceError.CreateFmt('MERA data file not found: %s',
      [fInfo.FileName]);

  fDataStream := TFileStream.Create(fInfo.FileName, fmOpenRead or fmShareDenyNone);
  if fInfo.HasXData then
  begin
    if not FileExists(fInfo.XFileName) then
      raise ERecorderDataSourceError.CreateFmt('MERA time file not found: %s',
        [fInfo.XFileName]);
    fTimeStream := TFileStream.Create(fInfo.XFileName, fmOpenRead or fmShareDenyNone);
  end;
  Rewind;
end;

procedure TMeraPlaybackSignal.Close;
begin
  FreeAndNil(fTimeStream);
  FreeAndNil(fDataStream);
end;

procedure TMeraPlaybackSignal.Rewind;
begin
  if fDataStream <> nil then
    fDataStream.Position := 0;
  if fTimeStream <> nil then
    fTimeStream.Position := 0;
  fSampleIndex := 0;
  fCachedTimeSec := 0;
  fCachedValue := 0;
  fHasCachedSample := False;
end;

function TMeraPlaybackSignal.ReadRawValue(out AValue: Double): Boolean;
var
  lDouble: Double;
  lSingle: Single;
  lInt32: LongInt;
  lUInt32: LongWord;
  lInt16: SmallInt;
  lUInt16: Word;
begin
  Result := False;
  AValue := 0;
  if (fDataStream = nil) or (fDataStream.Position + GetDataSize > fDataStream.Size) then
    Exit;

  case fInfo.DataType of
    mvtFloat64:
      begin
        fDataStream.ReadBuffer(lDouble, SizeOf(lDouble));
        AValue := lDouble;
      end;
    mvtFloat32:
      begin
        fDataStream.ReadBuffer(lSingle, SizeOf(lSingle));
        AValue := lSingle;
      end;
    mvtInt32:
      begin
        fDataStream.ReadBuffer(lInt32, SizeOf(lInt32));
        AValue := lInt32;
      end;
    mvtUInt32:
      begin
        fDataStream.ReadBuffer(lUInt32, SizeOf(lUInt32));
        AValue := lUInt32;
      end;
    mvtInt16:
      begin
        fDataStream.ReadBuffer(lInt16, SizeOf(lInt16));
        AValue := lInt16;
      end;
    mvtUInt16:
      begin
        fDataStream.ReadBuffer(lUInt16, SizeOf(lUInt16));
        AValue := lUInt16;
      end;
  end;
  Result := True;
end;

function TMeraPlaybackSignal.ReadSample(out ATimeSec, AValue: Double): Boolean;
begin
  Result := False;
  ATimeSec := 0;
  AValue := 0;

  if fTimeStream <> nil then
  begin
    if fTimeStream.Position + SizeOf(Double) > fTimeStream.Size then
      Exit;
    fTimeStream.ReadBuffer(ATimeSec, SizeOf(Double));
    ATimeSec := ATimeSec + fInfo.StartSec;
  end
  else
  begin
    if fInfo.FrequencyHz <= 0 then
      Exit;
    ATimeSec := fInfo.StartSec + (fSampleIndex / fInfo.FrequencyHz);
  end;

  if not ReadRawValue(AValue) then
    Exit;

  Inc(fSampleIndex);
  Result := True;
end;

function TMeraPlaybackSignal.EnsureCachedSample: Boolean;
begin
  Result := fHasCachedSample;
  if Result then
    Exit;

  Result := ReadSample(fCachedTimeSec, fCachedValue);
  fHasCachedSample := Result;
end;

function TMeraPlaybackSignal.PublishNext(ARegistry: TRecorderTagRegistry): Boolean;
var
  lTimeSec: Double;
  lValue: Double;
begin
  Result := False;
  if ARegistry = nil then
    Exit;

  if not ReadSample(lTimeSec, lValue) then
    Exit;

  ARegistry.PublishValue(fTagName, lTimeSec, lValue);
  Result := True;
end;

function TMeraPlaybackSignal.PublishScalarDue(ARegistry: TRecorderTagRegistry;
  APlayTimeSec: Double; AMaxSamples: Integer): Boolean;
var
  lPublished: Integer;
begin
  Result := False;
  lPublished := 0;
  while (lPublished < AMaxSamples) and EnsureCachedSample and
    (fCachedTimeSec <= APlayTimeSec) do
  begin
    ARegistry.PublishValue(fTagName, fCachedTimeSec, fCachedValue);
    fHasCachedSample := False;
    Inc(lPublished);
    Result := True;
  end;
end;

function TMeraPlaybackSignal.PublishVectorDue(ARegistry: TRecorderTagRegistry;
  APlayTimeSec: Double; ABlockLength: Cardinal; AMaxBlocks: Integer): Boolean;
var
  I: Integer;
  lBlocks: Integer;
  lCount: Integer;
  lTimeSec: Double;
  lTimes: TRecorderDoubleArray;
  lValue: Double;
  lValues: TRecorderDoubleArray;
begin
  Result := False;
  if (ARegistry = nil) or IsScalar or (fInfo.FrequencyHz <= 0) then
    Exit;
  if ABlockLength = 0 then
    ABlockLength := 1;

  lBlocks := 0;
  SetLength(lTimes, ABlockLength);
  SetLength(lValues, ABlockLength);
  while (lBlocks < AMaxBlocks) and
    (fInfo.StartSec + (fSampleIndex / fInfo.FrequencyHz) <= APlayTimeSec) do
  begin
    lCount := 0;
    for I := 0 to ABlockLength - 1 do
    begin
      if not ReadRawValue(lValue) then
        Break;

      lTimeSec := fInfo.StartSec + (fSampleIndex / fInfo.FrequencyHz);
      lTimes[lCount] := lTimeSec;
      lValues[lCount] := lValue;
      Inc(lCount);
      Inc(fSampleIndex);
    end;

    if lCount = 0 then
      Break;

    ARegistry.PublishBlock(fTagName, lTimes, lValues, lCount);
    Result := True;
    Inc(lBlocks);
  end;
end;

{ TRecorderMeraFileDataSource }

constructor TRecorderMeraFileDataSource.Create(const ASourceId, AFileName: string;
  AUpdateTimeMs: Cardinal; ASelectedTagNames: TStrings; ABlockLength: Cardinal;
  APlaybackSpeed: Cardinal);
begin
  if AFileName = '' then
    raise ERecorderDataSourceError.Create('MERA file name cannot be empty');
  if APlaybackSpeed = 0 then
    raise ERecorderDataSourceError.Create('MERA playback speed must be positive');

  inherited Create(ASourceId, 'MERA file playback', AUpdateTimeMs);
  if ABlockLength = 0 then
    ABlockLength := 1;

  fFileName := AFileName;
  fBlockLength := ABlockLength;
  fPlaybackSpeed := APlaybackSpeed;
  fPlaybackSignals := TList.Create;
  fSelectedTagNames := TStringList.Create;
  fSelectedTagNames.CaseSensitive := False;
  fSelectedTagNames.Sorted := False;
  if ASelectedTagNames <> nil then
    fSelectedTagNames.Assign(ASelectedTagNames);
end;

destructor TRecorderMeraFileDataSource.Destroy;
begin
  Stop;
  while fPlaybackSignals.Count > 0 do
  begin
    TObject(fPlaybackSignals[0]).Free;
    fPlaybackSignals.Delete(0);
  end;
  fPlaybackSignals.Free;
  fSelectedTagNames.Free;
  inherited Destroy;
end;

function TRecorderMeraFileDataSource.IsSignalSelected(ASignal: TMeraSignalInfo): Boolean;
begin
  Result := (fSelectedTagNames.Count = 0) or
    (fSelectedTagNames.IndexOf(MeraSignalToRecorderTagName(ASignal)) >= 0);
end;

procedure TRecorderMeraFileDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  lSignal: TMeraSignalInfo;
  lSignals: TList;
  lTag: TRecorderTag;
  lTagName: string;
begin
  lSignals := TList.Create;
  try
    LoadMeraSignalsFromFile(fFileName, lSignals);
    for I := 0 to lSignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(lSignals[I]);
      if not IsSignalSelected(lSignal) then
        Continue;

      lTagName := MeraSignalToRecorderTagName(lSignal);
      lTag := ARegistry.FindByName(lTagName);
      if lTag = nil then
        lTag := ARegistry.CreateTag(lTagName, 4096);

      lTag.Address := lSignal.Address;
      lTag.UnitName := lSignal.UnitsName;
      lTag.ModuleType := lSignal.ModuleName;
      lTag.PollFrequencyHz := lSignal.FrequencyHz;
      if lTag.SourceId = '' then
        lTag.SourceId := 'Mera file: ' + fFileName;
      lTag.Description := Format('%s; type=%s; freq=%s; file=%s',
        [lSignal.Name, lSignal.DataTypeName,
        FormatFloat('0.######', lSignal.FrequencyHz),
        ExtractFileName(lSignal.FileName)]);
    end;
  finally
    ClearMeraSignals(lSignals);
    lSignals.Free;
  end;
end;

procedure TRecorderMeraFileDataSource.Start;
var
  I: Integer;
  lHasRange: Boolean;
  lSignal: TMeraSignalInfo;
  lSignals: TList;
  lPlaybackSignal: TMeraPlaybackSignal;
begin
  inherited Start;
  lHasRange := False;
  fPlayRangeMinSec := 0;
  fStartTickMs := GetTickCount64;

  lSignals := TList.Create;
  try
    LoadMeraSignalsFromFile(fFileName, lSignals);
    for I := 0 to lSignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(lSignals[I]);
      if not IsSignalSelected(lSignal) then
        Continue;
      if (not lHasRange) or (lSignal.StartSec < fPlayRangeMinSec) then
      begin
        fPlayRangeMinSec := lSignal.StartSec;
        lHasRange := True;
      end;

      lPlaybackSignal := TMeraPlaybackSignal.Create(lSignal);
      try
        lPlaybackSignal.Open;
        fPlaybackSignals.Add(lPlaybackSignal);
        lSignals[I] := nil;
        lPlaybackSignal := nil;
      finally
        lPlaybackSignal.Free;
      end;
    end;
  finally
    ClearMeraSignals(lSignals);
    lSignals.Free;
  end;
end;

procedure TRecorderMeraFileDataSource.Stop;
begin
  while fPlaybackSignals.Count > 0 do
  begin
    TObject(fPlaybackSignals[0]).Free;
    fPlaybackSignals.Delete(0);
  end;
  inherited Stop;
end;

procedure TRecorderMeraFileDataSource.DoTick;
var
  I: Integer;
  lAnyPublished: Boolean;
  lPlayTimeSec: Double;
  lSignal: TMeraPlaybackSignal;
  lSignalPublished: Boolean;
const
  CScalarSamplesPerTickLimit = 4096;
  CVectorBlocksPerTickLimit = 16;
begin
  lPlayTimeSec := fPlayRangeMinSec +
    (((GetTickCount64 - fStartTickMs) / 1000.0) * fPlaybackSpeed);
  lAnyPublished := False;
  for I := 0 to fPlaybackSignals.Count - 1 do
  begin
    lSignal := TMeraPlaybackSignal(fPlaybackSignals[I]);
    if lSignal.IsScalar then
      lSignalPublished := lSignal.PublishScalarDue(Registry, lPlayTimeSec,
        CScalarSamplesPerTickLimit)
    else
      lSignalPublished := lSignal.PublishVectorDue(Registry, lPlayTimeSec,
        fBlockLength, CVectorBlocksPerTickLimit);

    if (not lSignalPublished) and fLoop then
    begin
      lSignal.Rewind;
      if lSignal.IsScalar then
        lSignalPublished := lSignal.PublishScalarDue(Registry, lPlayTimeSec,
          CScalarSamplesPerTickLimit)
      else
        lSignalPublished := lSignal.PublishVectorDue(Registry, lPlayTimeSec,
          fBlockLength, CVectorBlocksPerTickLimit);
    end;
    lAnyPublished := lSignalPublished or lAnyPublished;
  end;

  if not lAnyPublished then
    Exit;
end;

{ TRecorderDataSourceThread }

constructor TRecorderDataSourceThread.Create(const ASource: IRecorderDataSource);
begin
  inherited Create(True);
  if ASource = nil then
    raise ERecorderDataSourceError.Create('Data source thread source cannot be nil');

  FreeOnTerminate := False;
  fSource := ASource;
end;

procedure TRecorderDataSourceThread.SleepInterruptible(AMilliseconds: Cardinal);
var
  lChunkMs: Cardinal;
  lSleptMs: Cardinal;
begin
  lSleptMs := 0;
  while (not Terminated) and (lSleptMs < AMilliseconds) do
  begin
    lChunkMs := AMilliseconds - lSleptMs;
    if lChunkMs > 10 then
      lChunkMs := 10;

    Sleep(lChunkMs);
    Inc(lSleptMs, lChunkMs);
  end;
end;

procedure TRecorderDataSourceThread.Execute;
begin
  try
    fSource.Start;
    while not Terminated do
    begin
      fSource.Tick;
      Inc(fTickCount);
      SleepInterruptible(fSource.UpdateTimeMs);
    end;
  except
    on E: Exception do
      fLastErrorMessage := E.ClassName + ': ' + E.Message;
  end;

  try
    fSource.Stop;
  except
    on E: Exception do
    begin
      if fLastErrorMessage = '' then
        fLastErrorMessage := E.ClassName + ': ' + E.Message
      else
        fLastErrorMessage := fLastErrorMessage + '; stop failed: ' + E.Message;
    end;
  end;
end;

{ TRecorderDataSourceManager }

constructor TRecorderDataSourceManager.Create;
begin
  inherited Create;
  fSources := TList.Create;
  fLastErrors := TStringList.Create;
end;

destructor TRecorderDataSourceManager.Destroy;
begin
  Clear;
  fLastErrors.Free;
  fSources.Free;
  inherited Destroy;
end;

function TRecorderDataSourceManager.GetSourceContext(AIndex: Integer): TSourceContext;
begin
  Result := TSourceContext(fSources[AIndex]);
end;

function TRecorderDataSourceManager.GetSource(AIndex: Integer): IRecorderDataSource;
begin
  Result := GetSourceContext(AIndex).Source;
end;

function TRecorderDataSourceManager.GetSourceCount: Integer;
begin
  Result := fSources.Count;
end;

function TRecorderDataSourceManager.GetLastError(AIndex: Integer): string;
begin
  Result := fLastErrors[AIndex];
end;

function TRecorderDataSourceManager.GetLastErrorCount: Integer;
begin
  Result := fLastErrors.Count;
end;

procedure TRecorderDataSourceManager.AddSource(const ASource: IRecorderDataSource);
var
  lContext: TSourceContext;
begin
  if ASource = nil then
    raise ERecorderDataSourceError.Create('Data source manager source cannot be nil');
  if fRunning then
    raise ERecorderDataSourceError.Create('Cannot add data source while manager is running');
  if FindSource(ASource.SourceId) <> nil then
    raise ERecorderDataSourceError.CreateFmt('Data source already exists: %s',
      [ASource.SourceId]);

  lContext := TSourceContext.Create;
  lContext.Source := ASource;
  fSources.Add(lContext);
end;

function TRecorderDataSourceManager.FindSource(const ASourceId: string): IRecorderDataSource;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fSources.Count - 1 do
    if SameText(GetSourceContext(I).Source.SourceId, ASourceId) then
      Exit(GetSourceContext(I).Source);
end;

procedure TRecorderDataSourceManager.ConfigureTagsAll(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
begin
  if ARegistry = nil then
    raise ERecorderDataSourceError.Create('Data source manager registry cannot be nil');
  if fRunning then
    raise ERecorderDataSourceError.Create('Cannot configure data sources while running');

  fRegistry := ARegistry;
  for I := 0 to fSources.Count - 1 do
    GetSourceContext(I).Source.ConfigureTags(fRegistry);
end;

procedure TRecorderDataSourceManager.StartAll;
var
  I: Integer;
  lContext: TSourceContext;
begin
  if fRunning then
    raise ERecorderDataSourceError.Create('Data source manager is already running');
  if fRegistry = nil then
    raise ERecorderDataSourceError.Create('Data source manager tags are not configured');

  fLastErrors.Clear;
  try
    for I := 0 to fSources.Count - 1 do
    begin
      lContext := GetSourceContext(I);
      lContext.Thread := TRecorderDataSourceThread.Create(lContext.Source);
      lContext.Thread.Start;
    end;
    fRunning := True;
  except
    StopAll;
    raise;
  end;
end;

procedure TRecorderDataSourceManager.StopAll;
var
  I: Integer;
  lContext: TSourceContext;
begin
  for I := 0 to fSources.Count - 1 do
  begin
    lContext := GetSourceContext(I);
    if lContext.Thread <> nil then
      lContext.Thread.Terminate;
  end;

  for I := 0 to fSources.Count - 1 do
  begin
    lContext := GetSourceContext(I);
    if lContext.Thread <> nil then
    begin
      lContext.Thread.WaitFor;
      if lContext.Thread.LastErrorMessage <> '' then
        fLastErrors.Add(lContext.Source.SourceId + ': ' +
          lContext.Thread.LastErrorMessage);
      FreeAndNil(lContext.Thread);
    end;
  end;

  fRunning := False;
end;

procedure TRecorderDataSourceManager.Clear;
var
  I: Integer;
begin
  StopAll;
  for I := fSources.Count - 1 downto 0 do
  begin
    GetSourceContext(I).Free;
    fSources.Delete(I);
  end;
  fRegistry := nil;
  fLastErrors.Clear;
end;

end.
