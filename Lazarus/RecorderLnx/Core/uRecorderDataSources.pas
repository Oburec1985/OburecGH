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
  uRecorderTags;

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
