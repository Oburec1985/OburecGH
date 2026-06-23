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
{$codepage UTF8}

interface

uses
  Classes, SysUtils,
  uRecorderTags, uMeraFile, uRecorderDebugLog;

type
  { Базовый класс исключения для источников данных }
  ERecorderDataSourceError = class(Exception);

  { Состояние источника данных. }
  TRecorderDataSourceState = (
    dssStopped,  { Источник остановлен }
    dssRunning   { Источник запущен и опрашивается }
  );

  { IRecorderDataSource
    Минимальный интерфейс источника данных.
    SourceId     - стабильный идентификатор источника в конфигурации проекта.
    Name         - человекочитаемое имя для логов и UI.
    UpdateTimeMs - период опроса/генерации данных в миллисекундах.
    State        - текущее состояние источника. }
  IRecorderDataSource = interface
    ['{B955E78D-DA62-48CC-8B3D-93372C82A06F}']
    { Возвращает стабильный идентификатор источника }
    function GetSourceId: string;
    { Возвращает отображаемое имя источника }
    function GetName: string;
    { Возвращает период опроса/обновления данных в мс }
    function GetUpdateTimeMs: Cardinal;
    { Возвращает текущее состояние источника }
    function GetState: TRecorderDataSourceState;
    { Создает/подключает теги источника в общем registry.
      ARegistry - общий реестр тегов проекта. Владение не передается. }
    procedure ConfigureTags(ARegistry: TRecorderTagRegistry);
    { Переводит источник в рабочее состояние. Теги должны быть настроены заранее. }
    procedure Start;
    { Останавливает источник. Вызывается только из worker-thread в конце суперцикла. }
    procedure Stop;
    { Запрос остановки из внешнего потока: только флаг TryStop, без смены State
      и без освобождения ресурсов (AGrav: состояние потока меняет сам поток). }
    procedure RequestStop;
    { Публикует один шаг данных. В потоковой версии будет вызываться worker-thread. }
    procedure Tick;
    { Флаг запрошенной остановки, выставленный RequestStop. }
    function GetTryStop: Boolean;

    property SourceId: string read GetSourceId;
    property Name: string read GetName;
    property UpdateTimeMs: Cardinal read GetUpdateTimeMs;
    property State: TRecorderDataSourceState read GetState;
    property TryStop: Boolean read GetTryStop;
  end;

  { TRecorderDataSourceBase
    Базовый класс источника данных. Потомки реализуют создание тегов и один
    шаг генерации/опроса данных в DoCreateTags/DoTick. }
  TRecorderDataSourceBase = class(TInterfacedObject, IRecorderDataSource)
  private
    fName: string;                          { Имя источника }
    fRegistry: TRecorderTagRegistry;        { Ссылка на реестр тегов }
    fSourceId: string;                      { Идентификатор источника }
    fState: TRecorderDataSourceState;       { Состояние источника }
    fTryStop: Boolean;                      { Запрос остановки из внешнего потока }
    fUpdateTimeMs: Cardinal;                { Период опроса в мс }
  protected
    function GetSourceId: string;
    function GetName: string;
    function GetUpdateTimeMs: Cardinal;
    function GetState: TRecorderDataSourceState;
    function GetTryStop: Boolean;
    { Точка проверки в DoTick: True, если суперцикл должен завершиться. }
    function ShouldStop: Boolean;

    { Проверяет, что registry уже подключен, и возвращает его. }
    function RequireRegistry: TRecorderTagRegistry;

    { Потомок создает или находит нужные ему теги. }
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); virtual; abstract;

    { Потомок публикует один шаг данных. }
    procedure DoTick; virtual; abstract;

    property Registry: TRecorderTagRegistry read fRegistry;
  public
    { Конструктор базового класса
      ASourceId     - стабильный идентификатор источника.
      AName         - имя источника для UI/логов.
      AUpdateTimeMs - период обновления, должен быть больше нуля. }
    constructor Create(const ASourceId, AName: string; AUpdateTimeMs: Cardinal);

    { Настройка реестра тегов }
    procedure ConfigureTags(ARegistry: TRecorderTagRegistry); virtual;
    { Запуск источника }
    procedure Start; virtual;
    { Остановка источника (только из worker-thread) }
    procedure Stop; virtual;
    { Запрос остановки из внешнего потока }
    procedure RequestStop; virtual;
    { Выполнение одного шага опроса/генерации }
    procedure Tick; virtual;

    property SourceId: string read GetSourceId;
    property Name: string read GetName;
    property UpdateTimeMs: Cardinal read GetUpdateTimeMs;
    property State: TRecorderDataSourceState read GetState;
    property TryStop: Boolean read GetTryStop;
  end;

  { TMockSineDataSource
    Отладочный источник синусоидального сигнала. Он нужен как первый
    контролируемый поставщик данных для UI, плагинов, записи и тестов. }
  TMockSineDataSource = class(TRecorderDataSourceBase)
  private
    fAmplitude: Double;          { Амплитуда генерируемого сигнала }
    fFrequencyHz: Double;        { Частота сигнала в герцах }
    fPhaseRad: Double;           { Начальная фаза в радианах }
    fSampleIndex: Int64;         { Индекс текущего семпла }
    fTagName: string;            { Имя целевого тега }
    fTimeSec: Double;            { Модельное время генератора в секундах }
    fTag: TRecorderTag;
    function GetTagName: string;
  protected
    { Создание тега синусоиды }
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    { Вычисление и публикация очередного значения синусоиды }
    procedure DoTick; override;
  public
    { Конструктор генератора синуса
      ASourceId     - стабильный идентификатор источника.
      ATagName      - имя тега, куда источник будет писать сигнал.
      AUpdateTimeMs - период генерации точки.
      AAmplitude    - амплитуда синусоиды.
      AFrequencyHz  - частота синусоиды в герцах.
      APhaseRad     - начальная фаза в радианах. }
    constructor Create(const ASourceId, ATagName: string; AUpdateTimeMs: Cardinal;
      AAmplitude, AFrequencyHz: Double; APhaseRad: Double = 0);

    property TagName: string read GetTagName;
    property Amplitude: Double read fAmplitude write fAmplitude;
    property FrequencyHz: Double read fFrequencyHz write fFrequencyHz;
    property PhaseRad: Double read fPhaseRad write fPhaseRad;
    property TimeSec: Double read fTimeSec;
  end;

  { TRecorderDiagnosticsDataSource }
  TRecorderDiagnosticsDataSource = class(TRecorderDataSourceBase)
  private
    fCpuTagName: string;
    fLastCpuTime100Ns: QWord;
    fLastWallTickMs: QWord;
    fMemoryTagName: string;
    fTimeSec: Double;
    fMemoryTag: TRecorderTag;
    fCpuTag: TRecorderTag;
    function GetMemoryTagName: string;
    function GetCpuTagName: string;
    function GetProcessCpuUsagePercent: Double;
    function GetProcessMemoryMb: Double;
  protected
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    procedure DoTick; override;
  public
    constructor Create(const ASourceId: string; AUpdateTimeMs: Cardinal;
      const AMemoryTagName: string = 'MemTag'; const ACpuTagName: string = 'CpuUsage');

    property MemoryTagName: string read GetMemoryTagName;
    property CpuTagName: string read GetCpuTagName;
  end;

  { TRecorderMeraFileDataSource
    Встроенный источник воспроизведения файлов MERA. Заменяет старый плагин:
    выбранные каналы MERA мапятся на теги регистратора, и Tick публикует семплы
    из файла в TRecorderTagRegistry. }
  TRecorderMeraFileDataSource = class(TRecorderDataSourceBase)
  private
    fBlockLength: Cardinal;               { Размер блока для векторных данных }
    fFileName: string;                    { Путь к файлу MERA }
    fLoop: Boolean;                       { Флаг циклического воспроизведения }
    fPlayRangeMinSec: Double;             { Минимальное время старта среди сигналов }
    fPlaybackSpeed: Cardinal;             { Коэффициент скорости воспроизведения }
    fPlaybackSignals: TList;              { Список проигрываемых сигналов TMeraPlaybackSignal }
    fStartTickMs: QWord;                  { Системное время старта воспроизведения }
    fSelectedTagNames: TStringList;       { Список выбранных адресов каналов }
    function IsSignalSelected(ASignal: TMeraSignalInfo): Boolean;
    function IsSignalTagSelected(const ATagName: string): Boolean;
  protected
    { Создание тегов для всех выбранных сигналов MERA }
    procedure DoCreateTags(ARegistry: TRecorderTagRegistry); override;
    { Считывание очередных порций данных и публикация в реестр тегов }
    procedure DoTick; override;
  public
    { Конструктор источника воспроизведения файлов MERA }
    constructor Create(const ASourceId, AFileName: string; AUpdateTimeMs: Cardinal;
      ASelectedTagNames: TStrings = nil; ABlockLength: Cardinal = 128;
      APlaybackSpeed: Cardinal = 1);
    { Деструктор закрывает файлы и очищает структуры }
    destructor Destroy; override;
    { Открытие файлов и подготовка воспроизведения }
    procedure Start; override;
    { Закрытие файлов и очистка проигрывателей }
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
    fLastErrorMessage: string;         { Текст последней ошибки потока }
    fSource: IRecorderDataSource;      { Ссылка на источник данных }
    fTickCount: Int64;                 { Счетчик выполненных тиков }
    procedure SleepInterruptible(AMilliseconds: Cardinal);
  protected
    { Главный цикл потока }
    procedure Execute; override;
  public
    { Конструктор потока
      ASource - источник данных. Поток хранит interface-ссылку, поэтому объект
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
    { Внутренний контекст источника данных }
    TSourceContext = class
    public
      Source: IRecorderDataSource;       { Ссылка на источник }
      Thread: TRecorderDataSourceThread; { Поток-опрашиватель источника }
    end;
  private
    fLastErrors: TStringList;           { Ошибки потоков после останова }
    fRegistry: TRecorderTagRegistry;    { Ссылка на реестр тегов }
    fRunning: Boolean;                  { Флаг активности опроса }
    fSources: TList;                    { Список контекстов источников (TSourceContext) }
    function GetLastError(AIndex: Integer): string;
    function GetLastErrorCount: Integer;
    function GetSource(AIndex: Integer): IRecorderDataSource;
    function GetSourceContext(AIndex: Integer): TSourceContext;
    function GetSourceCount: Integer;
  public
    { Создание менеджера }
    constructor Create;
    { Уничтожение менеджера с остановкой всех потоков }
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

{ Преобразует состояние источника в строковое представление }
function RecorderDataSourceStateToString(AState: TRecorderDataSourceState): string;

implementation

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  Math, LazFileUtils;

{$IFDEF MSWINDOWS}
type
  { WinAPI-счетчики процесса нужны только для Windows-диагностики памяти. }
  TProcessMemoryCounters = record
    cb: DWORD;
    PageFaultCount: DWORD;
    PeakWorkingSetSize: PtrUInt;
    WorkingSetSize: PtrUInt;
    QuotaPeakPagedPoolUsage: PtrUInt;
    QuotaPagedPoolUsage: PtrUInt;
    QuotaPeakNonPagedPoolUsage: PtrUInt;
    QuotaNonPagedPoolUsage: PtrUInt;
    PagefileUsage: PtrUInt;
    PeakPagefileUsage: PtrUInt;
  end;

function GetProcessMemoryInfo(Process: THandle; var Counters: TProcessMemoryCounters;
  Size: DWORD): BOOL; stdcall; external 'psapi.dll';
{$ENDIF}

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

function TRecorderDataSourceBase.GetTryStop: Boolean;
begin
  Result := fTryStop;
end;

function TRecorderDataSourceBase.ShouldStop: Boolean;
begin
  Result := fTryStop;
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
  fTryStop := False;
  fState := dssRunning;
end;

procedure TRecorderDataSourceBase.RequestStop;
begin
  fTryStop := True;
end;

procedure TRecorderDataSourceBase.Stop;
begin
  fState := dssStopped;
  fTryStop := False;
end;

procedure TRecorderDataSourceBase.Tick;
begin
  if fState <> dssRunning then
    raise ERecorderDataSourceError.CreateFmt(
      'Data source %s tick called while stopped', [fSourceId]);
  if fTryStop then
    Exit;

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

function TMockSineDataSource.GetTagName: string;
begin
  if fTag <> nil then
    Result := fTag.Name
  else
    Result := fTagName;
end;

procedure TMockSineDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  lTag: TRecorderTag;
  I: Integer;
begin
  fTag := nil;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].SourceId, SourceId) then
    begin
      fTag := ARegistry.Tags[I];
      Break;
    end;

  if fTag <> nil then
    fTagName := fTag.Name
  else
  begin
    fTag := ARegistry.FindByName(fTagName);
    if fTag = nil then
      fTag := ARegistry.CreateTag(fTagName, 4096);
  end;

  fTag.Address := 'virtual';
  fTag.UnitName := 'a.u.';
  fTag.Description := 'Mock sine signal';
  fTag.SourceId := SourceId;
  fTag.ModuleType := 'virtual';
  fTag.PollFrequencyHz := 1000.0 / UpdateTimeMs;
end;

procedure TMockSineDataSource.DoTick;
var
  lValue: Double;
begin
  lValue := fAmplitude * Sin((2 * Pi * fFrequencyHz * fTimeSec) + fPhaseRad);
  Registry.PublishValue(TagName, fTimeSec, lValue);

  Inc(fSampleIndex);
  fTimeSec := fTimeSec + (UpdateTimeMs / 1000.0);
end;

{ TRecorderDiagnosticsDataSource }

constructor TRecorderDiagnosticsDataSource.Create(const ASourceId: string;
  AUpdateTimeMs: Cardinal; const AMemoryTagName: string; const ACpuTagName: string);
begin
  inherited Create(ASourceId, 'Recorder diagnostics data source', AUpdateTimeMs);
  if AMemoryTagName = '' then
    raise ERecorderDataSourceError.Create('Diagnostics memory tag name cannot be empty');
  if ACpuTagName = '' then
    raise ERecorderDataSourceError.Create('Diagnostics CPU tag name cannot be empty');

  fMemoryTagName := AMemoryTagName;
  fCpuTagName := ACpuTagName;
  fLastCpuTime100Ns := 0;
  fLastWallTickMs := 0;
  fTimeSec := 0;
end;

function TRecorderDiagnosticsDataSource.GetMemoryTagName: string;
begin
  if fMemoryTag <> nil then
    Result := fMemoryTag.Name
  else
    Result := fMemoryTagName;
end;

function TRecorderDiagnosticsDataSource.GetCpuTagName: string;
begin
  if fCpuTag <> nil then
    Result := fCpuTag.Name
  else
    Result := fCpuTagName;
end;

procedure TRecorderDiagnosticsDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  lTag: TRecorderTag;
  I: Integer;
begin
  fMemoryTag := nil;
  fCpuTag := nil;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if SameText(lTag.SourceId, SourceId) then
    begin
      if SameText(lTag.Address, 'diagnostics.memory') then
        fMemoryTag := lTag
      else if SameText(lTag.Address, 'diagnostics.cpu') then
        fCpuTag := lTag;
    end;
  end;

  if fMemoryTag <> nil then
    fMemoryTagName := fMemoryTag.Name
  else
  begin
    fMemoryTag := ARegistry.FindByName(fMemoryTagName);
    if fMemoryTag = nil then
      fMemoryTag := ARegistry.CreateTag(fMemoryTagName, 4096);
  end;
  fMemoryTag.Address := 'diagnostics.memory';
  fMemoryTag.UnitName := 'MB';
  fMemoryTag.Description := 'Recorder process memory usage';
  fMemoryTag.SourceId := SourceId;
  fMemoryTag.ModuleType := 'diagnostics';
  fMemoryTag.PollFrequencyHz := 1000.0 / UpdateTimeMs;

  if fCpuTag <> nil then
    fCpuTagName := fCpuTag.Name
  else
  begin
    fCpuTag := ARegistry.FindByName(fCpuTagName);
    if fCpuTag = nil then
      fCpuTag := ARegistry.CreateTag(fCpuTagName, 4096);
  end;
  fCpuTag.Address := 'diagnostics.cpu';
  fCpuTag.UnitName := '%';
  fCpuTag.Description := 'Recorder process CPU usage';
  fCpuTag.SourceId := SourceId;
  fCpuTag.ModuleType := 'diagnostics';
  fCpuTag.PollFrequencyHz := 1000.0 / UpdateTimeMs;
end;

function TRecorderDiagnosticsDataSource.GetProcessMemoryMb: Double;
{$IFDEF MSWINDOWS}
var
  lCounters: TProcessMemoryCounters;
begin
  FillChar(lCounters, SizeOf(lCounters), 0);
  lCounters.cb := SizeOf(lCounters);
  if GetProcessMemoryInfo(GetCurrentProcess, lCounters, SizeOf(lCounters)) then
    Result := lCounters.WorkingSetSize / (1024.0 * 1024.0)
  else
    Result := 0;
end;
{$ELSE}
var
  lHeap: THeapStatus;
begin
  lHeap := GetHeapStatus;
  Result := lHeap.TotalAllocated / (1024.0 * 1024.0);
end;
{$ENDIF}

function TRecorderDiagnosticsDataSource.GetProcessCpuUsagePercent: Double;
{$IFDEF MSWINDOWS}
var
  lCreationTime: TFileTime;
  lExitTime: TFileTime;
  lKernelTime: TFileTime;
  lNowMs: QWord;
  lProcessDelta100Ns: QWord;
  lProcessTime100Ns: QWord;
  lProcessorCount: Cardinal;
  lSystemInfo: TSystemInfo;
  lUserTime: TFileTime;
  lWallDelta100Ns: QWord;

  function FileTimeToQWord(const AValue: TFileTime): QWord;
  begin
    Result := (QWord(AValue.dwHighDateTime) shl 32) or QWord(AValue.dwLowDateTime);
  end;
begin
  Result := 0;
  lNowMs := GetTickCount64;
  if not GetProcessTimes(GetCurrentProcess, lCreationTime, lExitTime, lKernelTime,
    lUserTime) then
    Exit;

  lProcessTime100Ns := FileTimeToQWord(lKernelTime) + FileTimeToQWord(lUserTime);
  if (fLastWallTickMs = 0) or (fLastCpuTime100Ns = 0) then
  begin
    fLastWallTickMs := lNowMs;
    fLastCpuTime100Ns := lProcessTime100Ns;
    Exit;
  end;

  lWallDelta100Ns := (lNowMs - fLastWallTickMs) * 10000;
  lProcessDelta100Ns := lProcessTime100Ns - fLastCpuTime100Ns;
  fLastWallTickMs := lNowMs;
  fLastCpuTime100Ns := lProcessTime100Ns;
  if lWallDelta100Ns = 0 then
    Exit;

  GetSystemInfo(lSystemInfo);
  lProcessorCount := lSystemInfo.dwNumberOfProcessors;
  if lProcessorCount = 0 then
    lProcessorCount := 1;
  Result := (lProcessDelta100Ns / lWallDelta100Ns) * 100.0 / lProcessorCount;
  Result := Max(0.0, Min(100.0, Result));
end;
{$ELSE}
begin
  Result := 0;
end;
{$ENDIF}

procedure TRecorderDiagnosticsDataSource.DoTick;
begin
  Registry.PublishValue(MemoryTagName, fTimeSec, GetProcessMemoryMb);
  Registry.PublishValue(CpuTagName, fTimeSec, GetProcessCpuUsagePercent);
  fTimeSec := fTimeSec + (UpdateTimeMs / 1000.0);
end;

type
  { TMeraPlaybackSignal
    Вспомогательный класс для воспроизведения отдельного сигнала из файла MERA. }
  TMeraPlaybackSignal = class
  private
    fCachedTimeSec: Double;             { Время кэшированного отсчета }
    fCachedValue: Double;                { Значение кэшированного отсчета }
    fDataStream: TFileStream;           { Файловый поток значений (Y) }
    fHasCachedSample: Boolean;          { Наличие кэшированного отсчета }
    fInfo: TMeraSignalInfo;             { Информация о сигнале MERA }
    fSampleIndex: Int64;                { Счетчик прочитанных отсчетов }
    fTagName: string;                   { Имя целевого тега }
    fTimeStream: TFileStream;           { Файловый поток времени (X) для неравномерных сигналов }
    
    function GetDataSize: Integer;
    function IsScalar: Boolean;
    function ReadRawValue(out AValue: Double): Boolean;
    function ReadSample(out ATimeSec, AValue: Double): Boolean;
    function EnsureCachedSample: Boolean;
  public
    { Конструктор проигрывателя сигнала }
    constructor Create(ASignal: TMeraSignalInfo);
    { Деструктор закрывает потоки }
    destructor Destroy; override;
    { Открытие файлов данных }
    procedure Open;
    { Закрытие файлов }
    procedure Close;
    { Перемотка в начало }
    procedure Rewind;
    { Публикует следующий отсчет }
    function PublishNext(ARegistry: TRecorderTagRegistry): Boolean;
    { Публикует скалярные отсчеты, время которых подошло к текущему }
    function PublishScalarDue(ARegistry: TRecorderTagRegistry; APlayTimeSec: Double;
      AMaxSamples: Integer): Boolean;
    { Публикует векторные блоки данных }
    function PublishVectorDue(ARegistry: TRecorderTagRegistry; APlayTimeSec: Double;
      AUpdateTimeMs: Cardinal; ABlockLength: Cardinal; AMaxBlocks: Integer): Boolean;
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
  FreeAndNil(fInfo);
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
  APlayTimeSec: Double; AUpdateTimeMs: Cardinal; ABlockLength: Cardinal;
  AMaxBlocks: Integer): Boolean;
var
  I: Integer;
  lAutoBlockLength: Boolean;
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
  lAutoBlockLength := ABlockLength = 0;
  if ABlockLength = 0 then
  begin
    if AUpdateTimeMs = 0 then
      AUpdateTimeMs := 1;
    ABlockLength := Round(fInfo.FrequencyHz * AUpdateTimeMs / 1000.0);
    if ABlockLength = 0 then
      ABlockLength := 1;
    AMaxBlocks := 1;
  end;

  lBlocks := 0;
  SetLength(lTimes, ABlockLength);
  SetLength(lValues, ABlockLength);
  while (lBlocks < AMaxBlocks) and
    (((not lAutoBlockLength) and
      (fInfo.StartSec + (fSampleIndex / fInfo.FrequencyHz) <= APlayTimeSec)) or
     (lAutoBlockLength and
      (fInfo.StartSec + ((fSampleIndex + ABlockLength - 1) / fInfo.FrequencyHz) <=
      APlayTimeSec))) do
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
    RecorderDebugLog(Format('MERA block: tag=%s count=%d first=%.6f last=%.6f blockLength=%d update=%dms',
      [fTagName, lCount, lTimes[0], lTimes[lCount - 1], ABlockLength,
      AUpdateTimeMs]));
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
    IsSignalTagSelected(ASignal.Address) or
    IsSignalTagSelected(ASignal.Name) or
    IsSignalTagSelected(MeraSignalToRecorderTagName(ASignal));
end;
function TRecorderMeraFileDataSource.IsSignalTagSelected(
  const ATagName: string): Boolean;
begin
  Result := fSelectedTagNames.IndexOf(ATagName) >= 0;
end;

procedure TRecorderMeraFileDataSource.DoCreateTags(ARegistry: TRecorderTagRegistry);
var
  I: Integer;
  J: Integer;
  lSignal: TMeraSignalInfo;
  lSignals: TList;
  lTag: TRecorderTag;
  lUpdated: Boolean;

  procedure UpdateTag(ATag: TRecorderTag);
  begin
    ATag.Address := lSignal.Address;
    ATag.UnitName := lSignal.UnitsName;
    ATag.ModuleType := lSignal.ModuleName;
    ATag.PollFrequencyHz := lSignal.FrequencyHz;
    ATag.SensorCalibrationName := lSignal.SensorCalibrationName;
    ATag.AmplifierCalibrationName := lSignal.AmplifierCalibrationName;
    ATag.SourceId := 'Mera file: ' + fFileName;
    ATag.Description := Format('%s; type=%s; freq=%s; file=%s',
      [lSignal.Name, lSignal.DataTypeName,
      FormatFloat('0.######', lSignal.FrequencyHz),
      ExtractFileName(lSignal.FileName)]);
  end;

begin
  if not FileExistsUTF8(fFileName) then
    Exit;

  lSignals := TList.Create;
  try
    LoadMeraSignalsFromFile(fFileName, lSignals);
    for I := 0 to lSignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(lSignals[I]);
      if not IsSignalSelected(lSignal) then
        Continue;

      lUpdated := False;
      for J := 0 to ARegistry.TagCount - 1 do
      begin
        lTag := ARegistry.Tags[J];
        if SameText(lTag.SourceId, 'Mera file: ' + fFileName) and
          SameText(lTag.Address, lSignal.Address) then
        begin
          UpdateTag(lTag);
          lUpdated := True;
        end;
      end;

      if not lUpdated then
      begin
        lTag := ARegistry.CreateTag(MeraSignalToRecorderTagName(lSignal), 4096);
        UpdateTag(lTag);
      end;
    end;
  finally
    ClearMeraSignals(lSignals);
    lSignals.Free;
  end;
end;
procedure TRecorderMeraFileDataSource.Start;
var
  I: Integer;
  J: Integer;
  lHasRange: Boolean;
  lLinked: Boolean;
  lSourceId: string;
  lSignal: TMeraSignalInfo;
  lSignals: TList;
  lTag: TRecorderTag;

  procedure AddPlaybackSignal(ASourceSignal: TMeraSignalInfo; const ATagName: string);
  var
    lPlaybackSignal: TMeraPlaybackSignal;
    lSignalCopy: TMeraSignalInfo;
  begin
    lSignalCopy := TMeraSignalInfo.Create;
    try
      lSignalCopy.Name := ATagName;
      lSignalCopy.Address := ASourceSignal.Address;
      lSignalCopy.ModuleName := ASourceSignal.ModuleName;
      lSignalCopy.DataTypeName := ASourceSignal.DataTypeName;
      lSignalCopy.DataType := ASourceSignal.DataType;
      lSignalCopy.FrequencyHz := ASourceSignal.FrequencyHz;
      lSignalCopy.StartSec := ASourceSignal.StartSec;
      lSignalCopy.UnitsName := ASourceSignal.UnitsName;
      lSignalCopy.Description := ASourceSignal.Description;
      lSignalCopy.SensorCalibrationName := ASourceSignal.SensorCalibrationName;
      lSignalCopy.AmplifierCalibrationName := ASourceSignal.AmplifierCalibrationName;
      lSignalCopy.FileName := ASourceSignal.FileName;
      lSignalCopy.XFileName := ASourceSignal.XFileName;
      lSignalCopy.HasXData := ASourceSignal.HasXData;
      lSignalCopy.Enabled := ASourceSignal.Enabled;
      lSignalCopy.Selected := ASourceSignal.Selected;

      lPlaybackSignal := TMeraPlaybackSignal.Create(lSignalCopy);
      lSignalCopy := nil;
      try
        lPlaybackSignal.Open;
        fPlaybackSignals.Add(lPlaybackSignal);
        lPlaybackSignal := nil;
      finally
        lPlaybackSignal.Free;
      end;
    finally
      lSignalCopy.Free;
    end;
  end;

begin
  inherited Start;
  lHasRange := False;
  lSourceId := 'Mera file: ' + fFileName;
  fPlayRangeMinSec := 0;
  fStartTickMs := GetTickCount64;

  if not FileExistsUTF8(fFileName) then
    Exit;

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

      lLinked := False;
      if Registry <> nil then
        for J := 0 to Registry.TagCount - 1 do
        begin
          lTag := Registry.Tags[J];
          if SameText(lTag.SourceId, lSourceId) and
            SameText(lTag.Address, lSignal.Address) then
          begin
            AddPlaybackSignal(lSignal, lTag.Name);
            lLinked := True;
          end;
        end;

      if not lLinked then
        AddPlaybackSignal(lSignal, MeraSignalToRecorderTagName(lSignal));
    end;
  finally
    ClearMeraSignals(lSignals);
    lSignals.Free;
  end;
end;

procedure TRecorderMeraFileDataSource.Stop;
begin
  inherited Stop;
  while fPlaybackSignals.Count > 0 do
  begin
    TObject(fPlaybackSignals[0]).Free;
    fPlaybackSignals.Delete(0);
  end;
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
    if ShouldStop then
      Exit;
    lSignal := TMeraPlaybackSignal(fPlaybackSignals[I]);
    if lSignal.IsScalar then
      lSignalPublished := lSignal.PublishScalarDue(Registry, lPlayTimeSec,
        CScalarSamplesPerTickLimit)
    else
      lSignalPublished := lSignal.PublishVectorDue(Registry, lPlayTimeSec,
        UpdateTimeMs, fBlockLength, CVectorBlocksPerTickLimit);

    if (not lSignalPublished) and fLoop then
    begin
      lSignal.Rewind;
      if lSignal.IsScalar then
        lSignalPublished := lSignal.PublishScalarDue(Registry, lPlayTimeSec,
          CScalarSamplesPerTickLimit)
      else
        lSignalPublished := lSignal.PublishVectorDue(Registry, lPlayTimeSec,
          UpdateTimeMs, fBlockLength, CVectorBlocksPerTickLimit);
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
var
  lElapsed: QWord;
  lNextTickMs: QWord;
  lNow: QWord;
  lSleepMs: QWord;
  lStart: QWord;
begin
  try
    fSource.Start;
    lNextTickMs := GetTickCount64;
    while not Terminated do
    begin
      if fSource.TryStop then
        Break;

      lStart := GetTickCount64;
      fSource.Tick;
      Inc(fTickCount);
      if fSource.TryStop then
        Break;
      lElapsed := GetTickCount64 - lStart;
      if lElapsed > 10 then
        RecorderDebugLog(Format('[DataSource:%s] Tick took %d ms on Thread %d',
          [fSource.SourceId, lElapsed, PtrUInt(GetThreadID)]));

      Inc(lNextTickMs, fSource.UpdateTimeMs);
      lNow := GetTickCount64;
      if lNextTickMs <= lNow then
      begin
        if lNow - lNextTickMs >= fSource.UpdateTimeMs then
          lNextTickMs := lNow + fSource.UpdateTimeMs
        else
          lNextTickMs := lNow + 1;
      end;

      lSleepMs := lNextTickMs - lNow;
      if lSleepMs > High(Cardinal) then
        lSleepMs := High(Cardinal);
      SleepInterruptible(Cardinal(lSleepMs));
    end;
  except
    on E: Exception do
    begin
      fLastErrorMessage := E.ClassName + ': ' + E.Message;
      RecorderDebugLog(Format('[DataSource:%s] Thread stopped by exception: %s',
        [fSource.SourceId, fLastErrorMessage]));
    end;
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
      RegisterThreadName(lContext.Thread.ThreadID, 'Src_' + lContext.Source.SourceId);
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

  { Внешний поток только выставляет TryStop; State и очистка — в worker-thread. }
  for I := 0 to fSources.Count - 1 do
  begin
    lContext := GetSourceContext(I);
    try
      lContext.Source.RequestStop;
    except
      on E: Exception do
        fLastErrors.Add(lContext.Source.SourceId + ': request stop failed: ' +
          E.Message);
    end;
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
