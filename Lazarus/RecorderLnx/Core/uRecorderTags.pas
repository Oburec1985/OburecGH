unit uRecorderTags;

{
  Модуль uRecorderTags

  Назначение:
    Минимальная модель тегов RecorderLnx: метаданные канала, кольцевой буфер
    сигнала и реестр тегов с публикацией событий обновления.

  Место в архитектуре:
    Core/domain. Модуль не зависит от LCL и не обращается к устройствам напрямую.
    Источники данных и плагины будут записывать значения в TRecorderTagRegistry,
    а UI, обработчики и запись будут читать снимки через теги и события core.

  Ограничения первой версии:
    Значения сигнала пока представлены как Double + время в секундах. Строковые
    состояния, блоковые пакеты, тарировки и аппаратные коды будут добавлены после
    проверки базового потока данных.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math,
  uRecorderCoreServices, uRecorderSpectrumEngine, uRecorderFrequencyBands;

type
  { Идентификатор тега }
  TRecorderTagId = Int64;
  { Динамический массив вещественных чисел }
  TRecorderDoubleArray = array of Double;

  { TRecorderTagEstimateKind
    Типы расчетных оценок тега. }
  TRecorderTagEstimateKind = (
    tekMean,                       { Среднее арифметическое (МO) }
    tekRmsValue,                   { Среднеквадратичное значение (RMS) }
    tekRmsDeviation,               { Среднеквадратичное отклонение (СКО / RMSD) }
    tekPeak,                       { Пиковое значение (Амплитуда) }
    tekPeakToPeak,                 { Размах (P2P / Пик-пик) }
    tekMinimum,                    { Минимальное значение }
    tekMaximum,                    { Максимальное значение }
    tekPeakToPeakByRmsDeviation,   { Размах по СКО (2.828 * RMSD) }
    tekLastValue                   { Последнее значение }
  );

  { TRecorderTagEstimate
    Результат расчета оценки сигнала тега. }
  TRecorderTagEstimate = record
    Kind: TRecorderTagEstimateKind; { Тип оценки }
    Valid: Boolean;                 { Флаг валидности расчета }
    Count: Integer;                 { Количество точек, участвовавших в расчете }
    StartTimeSec: Double;           { Время начала интервала расчета }
    EndTimeSec: Double;             { Время окончания интервала расчета }
    Value: Double;                  { Рассчитанное значение }
  end;

  { TRecorderTagEstimateSettings
    Настройки вычисления оценок для тега.
    
    EnabledKinds     - массив флагов включенных видов оценок.
    DefaultKind      - тип оценки по умолчанию для отображения.
    PortionLength    - размер порции (в отсчетах) для вычисления.
    SmoothingEnabled - флаг сглаживания y'=kx+(1-k)y.
    SmoothingK       - коэффициент сглаживания k.
    ScadaEnabled     - флаг передачи тега в SCADA. }
  TRecorderTagEstimateSettings = record
    EnabledKinds: array[TRecorderTagEstimateKind] of Boolean;
    DefaultKind: TRecorderTagEstimateKind;
    PortionLength: Integer;
    SmoothingEnabled: Boolean;
    SmoothingK: Double;
    ScadaEnabled: Boolean;
  end;

  { TRecorderTagSetpointKind
    Категории порогов (уставок) }
  TRecorderTagSetpointKind = (
    tskHighAlarm,     { Верхний аварийный }
    tskHighWarning,   { Верхний предупредительный }
    tskLowWarning,    { Нижний предупредительный }
    tskLowAlarm       { Нижний аварийный }
  );

  { TRecorderTagSetpoint
    Настройки порога (уставки) для тега. }
  TRecorderTagSetpoint = record
    Enabled: Boolean;             { Флаг включения порога }
    Threshold: Double;            { Значение порога }
    Color: LongInt;               { Цвет отображения порога в UI }
    OutputEnabled: Boolean;       { Флаг вывода (реле/цифровой выход) }
    HysteresisPercent: Double;    { Гистерезис в процентах }
  end;

  { TRecorderSignalSnapshot
    Снимок сигнального буфера.
    
    Count  - число валидных точек.
    Times  - времена точек в секундах.
    Values - значения точек. Индексы совпадают с Times. }
  TRecorderSignalSnapshot = record
    Count: Integer;
    Times: TRecorderDoubleArray;
    Values: TRecorderDoubleArray;
  end;

  { Исключение при ошибках работы с тегами }
  ERecorderTagError = class(Exception);

  { TRecorderSignalBuffer
    Потокобезопасный кольцевой буфер значений одного тега. Буфер выделяет память
    при создании и дальше переиспользует ее при добавлении sample-ов. Снимок
    копирует данные в динамические массивы вызывающего кода. }
  TRecorderSignalBuffer = class
  private
    fCapacity: Integer;                       { Максимальная емкость буфера }
    fCount: Integer;                          { Текущее количество точек в буфере }
    fLock: TRTLCriticalSection;               { Критическая секция защиты буфера }
    fStart: Integer;                          { Индекс начала кольцевого буфера }
    fLastBlockCount: Integer;                 { Размер последнего добавленного блока }
    fLastBlockTimes: TRecorderDoubleArray;    { Времена последнего блока }
    fLastBlockValues: TRecorderDoubleArray;   { Значения последнего блока }
    fTimes: array of Double;                  { Массив времен }
    fValues: array of Double;                 { Массив значений }
    function GetLatestTime: Double;
    function GetLatestValue: Double;
  public
    { ACapacity - максимальное число точек в кольцевом буфере. }
    constructor Create(ACapacity: Integer);
    { Деструктор корректно удаляет критическую секцию }
    destructor Destroy; override;

    { Очищает буфер без освобождения выделенных массивов. }
    procedure Clear;

    { Добавляет одну точку в буфер.
      ATimeSec - время точки в секундах.
      AValue   - значение точки. }
    procedure AddSample(ATimeSec, AValue: Double);
    { Добавляет массив точек в буфер. }
    procedure AddSamples(const ATimes, AValues: array of Double; ACount: Integer);
    { Меняет емкость буфера, сохраняя последние доступные точки. }
    procedure SetCapacity(ACapacity: Integer);
    { Возвращает снимок от старой точки к новой. }
    function Snapshot: TRecorderSignalSnapshot;
    { Возвращает снимок последнего добавленного блока точек. }
    function LastBlockSnapshot: TRecorderSignalSnapshot;
    property Capacity: Integer read fCapacity;
    property Count: Integer read fCount;
    property LatestTime: Double read GetLatestTime;
    property LatestValue: Double read GetLatestValue;
  end;

  { TRecorderTag
    Доменная модель одного измерительного/служебного тега. Тег хранит метаданные
    и собственный буфер сигнала; запись значений идет через AddSample. }
  TRecorderTag = class
  private
    fAddress: string;                                          { Адрес тега (например, в модуле) }
    fDescription: string;                                      { Описание тега }
    fAutoRange: Boolean;                                       { Автоматический диапазон шкалы }
    fAutoUnit: Boolean;                                        { Автоматические единицы измерения }
    fCalibrationNames: TStringList;                          { Цепочка имен канальных ГХ }
    fId: TRecorderTagId;                                       { Уникальный ID тега }
    fEstimateSettings: TRecorderTagEstimateSettings;           { Настройки расчета оценок }
    fModuleType: string;                                       { Тип модуля/устройства }
    fName: string;                                             { Уникальное имя тега }
    fPollFrequencyHz: Double;                                  { Частота опроса в Гц }
    fSensorCalibrationName: string;                            { Канальная датчиковая градуировка }
    fAmplifierCalibrationName: string;                         { Канальная усилительная градуировка }
    fRangeMax: Double;                                         { Максимум шкалы }
    fRangeMin: Double;                                         { Минимум шкалы }
    fSignalBuffer: TRecorderSignalBuffer;                      { Буфер сигнала }
    fSourceId: string;                                         { Идентификатор источника }
    fSetpointHysteresisEnabled: Boolean;                       { Разрешить гистерезис уставки }
    fSetpointSoundUntilEnd: Boolean;                           { Звук до сброса предупреждения }
    fSetpointStatusChannelEnabled: Boolean;                    { Формировать канал состояния }
    fSetpointStatusChannelName: string;                        { Имя формируемого канала состояния }
    fSetpoints: array[TRecorderTagSetpointKind] of TRecorderTagSetpoint; { Уставки тега }
    fSourceValueMode: string;                                  { Режим значения, заданный источником }
    fMeasRangeIndex: LongWord;                                 { Индекс диапазона MIC-140 }
    fHardwareCalibrationEnabled: Boolean;                      { Включена аппаратная ГХ с устройства }
    fHardwareCalibrationName: string;                          { Имя аппаратной ГХ в реестре калибровок }
    fChannelCalibrationEnabled: Boolean;                         { Включена канальная ГХ (термопарная/SDB) }
    fMic140DeviceSerial: Integer;                              { Серийный номер MIC-140 для аппаратной ГХ }
    fMic140ThermoCompensationEnabled: Boolean;                 { КТХС выполняется драйвером MIC-140 до ГХ }
    fMic140CjcDefault: Boolean;                                { Использовать штатный T-канал холодного спая }
    fMic140CjcChannel: Integer;                                { T1..T3, выбранный для КТХС }
    fMic140ThermocoupleScaleName: string;                      { Выбранная SDB ГХ термопары }
    fMic140ThermocoupleScalePath: string;                      { Ключ SDB выбранной ГХ }
    fMic140SoftBalance: Double;                                { Программное смещение нуля (коды АЦП) }
    fTextValue: string;                                        { Текстовое представление последнего значения }
    fUnitName: string;                                         { Единица измерения }
    function GetSetpoint(AKind: TRecorderTagSetpointKind): TRecorderTagSetpoint;
    procedure SetSetpoint(AKind: TRecorderTagSetpointKind;
      const AValue: TRecorderTagSetpoint);
  public
    { Создает тег.
      AId       - стабильный числовой id в пределах registry.
      AName     - уникальное имя тега.
      ACapacity - размер кольцевого буфера значений. }
    constructor Create(AId: TRecorderTagId; const AName: string;
      ACapacity: Integer = 4096);
    { Деструктор уничтожает внутренний буфер сигнала }
    destructor Destroy; override;

    { Добавляет числовое значение в буфер тега. }
    procedure AddSample(ATimeSec, AValue: Double);
    { Добавляет блок значений в буфер тега. }
    procedure AddSamples(const ATimes, AValues: array of Double; ACount: Integer);
    { Расширяет кольцевой буфер тега без потери последних точек. }
    procedure EnsureBufferCapacity(ACapacity: Integer);
    { Очищает историю сигнала после смены режима/ГХ канала. }
    procedure ClearSignalHistory;

    { Возвращает снимок сигнала тега. }
    function Snapshot: TRecorderSignalSnapshot;
    { Возвращает снимок последнего записанного блока тега. }
    function LastBlockSnapshot: TRecorderSignalSnapshot;
    { Расчитывает указанную оценку по текущим данным }
    function Estimate(AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;

    property Id: TRecorderTagId read fId;
    property Name: string read fName write fName;
    property Address: string read fAddress write fAddress;
    property UnitName: string read fUnitName write fUnitName;
    property Description: string read fDescription write fDescription;
    property PollFrequencyHz: Double read fPollFrequencyHz write fPollFrequencyHz;
    property SensorCalibrationName: string read fSensorCalibrationName write fSensorCalibrationName;
    property AmplifierCalibrationName: string read fAmplifierCalibrationName write fAmplifierCalibrationName;
    property ModuleType: string read fModuleType write fModuleType;
    property RangeMin: Double read fRangeMin write fRangeMin;
    property RangeMax: Double read fRangeMax write fRangeMax;
    property AutoRange: Boolean read fAutoRange write fAutoRange;
    property AutoUnit: Boolean read fAutoUnit write fAutoUnit;
    property CalibrationNames: TStringList read fCalibrationNames;
    property EstimateSettings: TRecorderTagEstimateSettings read fEstimateSettings
      write fEstimateSettings;
    property Setpoints[AKind: TRecorderTagSetpointKind]: TRecorderTagSetpoint
      read GetSetpoint write SetSetpoint;
    property SetpointHysteresisEnabled: Boolean read fSetpointHysteresisEnabled
      write fSetpointHysteresisEnabled;
    property SetpointSoundUntilEnd: Boolean read fSetpointSoundUntilEnd
      write fSetpointSoundUntilEnd;
    property SetpointStatusChannelEnabled: Boolean read fSetpointStatusChannelEnabled
      write fSetpointStatusChannelEnabled;
    property SetpointStatusChannelName: string read fSetpointStatusChannelName
      write fSetpointStatusChannelName;
    property SourceId: string read fSourceId write fSourceId;
    property SourceValueMode: string read fSourceValueMode write fSourceValueMode;
    property MeasRangeIndex: LongWord read fMeasRangeIndex write fMeasRangeIndex;
    property HardwareCalibrationEnabled: Boolean read fHardwareCalibrationEnabled
      write fHardwareCalibrationEnabled;
    property HardwareCalibrationName: string read fHardwareCalibrationName
      write fHardwareCalibrationName;
    property ChannelCalibrationEnabled: Boolean read fChannelCalibrationEnabled
      write fChannelCalibrationEnabled;
    property Mic140DeviceSerial: Integer read fMic140DeviceSerial
      write fMic140DeviceSerial;
    property Mic140ThermoCompensationEnabled: Boolean
      read fMic140ThermoCompensationEnabled write fMic140ThermoCompensationEnabled;
    property Mic140CjcDefault: Boolean read fMic140CjcDefault write fMic140CjcDefault;
    property Mic140CjcChannel: Integer read fMic140CjcChannel write fMic140CjcChannel;
    property Mic140ThermocoupleScaleName: string read fMic140ThermocoupleScaleName
      write fMic140ThermocoupleScaleName;
    property Mic140ThermocoupleScalePath: string read fMic140ThermocoupleScalePath
      write fMic140ThermocoupleScalePath;
    property Mic140SoftBalance: Double read fMic140SoftBalance write fMic140SoftBalance;
    property TextValue: string read fTextValue write fTextValue;
    property SignalBuffer: TRecorderSignalBuffer read fSignalBuffer;
  end;

  { TRecorderTagUpdateEventData
    Данные события обновления тега.
    Объект передается через TRecorderEvent.Data. Владение объектом остается у
    TRecorderTagRegistry, поэтому обработчики события не должны его освобождать. }
  TRecorderTagUpdateEventData = class
  private
    fTag: TRecorderTag;
    fTimeSec: Double;
    fValue: Double;
    fSampleCount: Integer;
    fTimes: TRecorderDoubleArray;
    fValues: TRecorderDoubleArray;
    fBlockTailNotify: Boolean;
  public
    constructor Create(ATag: TRecorderTag; ATimeSec, AValue: Double); overload;
    constructor CreateBlock(ATag: TRecorderTag; const ATimes, AValues: array of Double; ACount: Integer);
    constructor CreateBlockTailNotify(ATag: TRecorderTag; ATimeSec, AValue: Double);
    property Tag: TRecorderTag read fTag;
    property TimeSec: Double read fTimeSec;
    property Value: Double read fValue;
    property SampleCount: Integer read fSampleCount;
    property Times: TRecorderDoubleArray read fTimes;
    property Values: TRecorderDoubleArray read fValues;
    property BlockTailNotify: Boolean read fBlockTailNotify;
  end;

  { TRecorderTagRegistry
    Реестр тегов RecorderLnx. Владеет тегами, обеспечивает уникальность id/name и
    публикует rceDataUpdated при записи значения. }

  TRecorderCalibrationKind = (rckScale, rckPiecewiseLinear);

  TRecorderCalibrationPoint = class
  public
    X: Double;
    Y: Double;
    constructor Create(AX, AY: Double);
  end;

  TRecorderCalibration = class
  private
    fName: string;
    fDescription: string;
    fUnitIn: string;
    fUnitOut: string;
    fExtrapolation: Boolean;
    fKind: TRecorderCalibrationKind;
    fScale: Double;
    fPoints: TList; // List of TRecorderCalibrationPoint
    function GetPoint(AIndex: Integer): TRecorderCalibrationPoint;
    function GetPointCount: Integer;
  public
    constructor Create(AKind: TRecorderCalibrationKind);
    destructor Destroy; override;
    procedure AddPoint(AX, AY: Double);
    procedure Assign(ASource: TRecorderCalibration);
    function Clone: TRecorderCalibration;
    function Transform(AValue: Double): Double;
    procedure ClearPoints;
    function PointAt(AIndex: Integer): TRecorderCalibrationPoint;
    property Name: string read fName write fName;
    property Description: string read fDescription write fDescription;
    property UnitIn: string read fUnitIn write fUnitIn;
    property UnitOut: string read fUnitOut write fUnitOut;
    property Extrapolation: Boolean read fExtrapolation write fExtrapolation;
    property Kind: TRecorderCalibrationKind read fKind write fKind;
    property Scale: Double read fScale write fScale;
    property PointCount: Integer read GetPointCount;
  end;

  TRecorderCalibrationList = class
  private
    fList: TList; // List of TRecorderCalibration
    function GetCount: Integer;
    function GetItem(AIndex: Integer): TRecorderCalibration;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(ACalibration: TRecorderCalibration);
    procedure AddCopy(ACalibration: TRecorderCalibration);
    procedure Delete(AIndex: Integer);
    procedure Exchange(AIndex1, AIndex2: Integer);
    procedure Clear;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TRecorderCalibration read GetItem; default;
  end;

  TRecorderTagBlockPublishedEvent = procedure(Sender: TObject; const ATagName: string;
    const ATimes, AValues: array of Double; ACount: Integer) of object;

  TRecorderTagRegistry = class
  private
    fActiveSourceIds: TStringList;                     { Active data source ids for detached tag indication }
    fBlockPublishedTarget: TObject;
    fOnBlockPublished: TRecorderTagBlockPublishedEvent;
    fEventBus: TRecorderEventBus;                     { Ссылка на шину событий }
    fNextId: TRecorderTagId;                          { Счетчик следующего ID }
    fSelectedTagName: string;                         { Имя текущего выбранного тега }
    fTags: TList;                                     { Список тегов (TRecorderTag) }
    fCalibrations: TRecorderCalibrationList;
    fSpectrumConfigs: TRecorderSpectrumConfigTree;
    fFrequencyBands: TRecorderFrequencyBandList;
    fMic140DeviceConfigs: TStringList;
    function GetActiveSourceCount: Integer;
    function GetActiveSourceId(AIndex: Integer): string;
    function GetSelectedTag: TRecorderTag;
    function GetTag(AIndex: Integer): TRecorderTag;
    function GetTagCount: Integer;
  public
    { AEventBus - шина событий. Владение не передается, может быть nil. }
    constructor Create(AEventBus: TRecorderEventBus = nil);
    { Деструктор очищает и удаляет все зарегистрированные теги }
    destructor Destroy; override;

    { Создает тег с автоматическим id и добавляет его в registry.
      AName     - уникальное имя тега.
      ACapacity - размер кольцевого буфера тега. }
    function CreateTag(const AName: string; ACapacity: Integer = 4096): TRecorderTag;

    { Добавляет заранее созданный тег. Registry принимает владение. }
    function AddTag(ATag: TRecorderTag): TRecorderTag;

    { Ищет тег по id. Возвращает nil, если тег не найден. }
    function FindById(AId: TRecorderTagId): TRecorderTag;

    { Ищет тег по имени без учета регистра. Возвращает nil, если тег не найден. }
    function FindByName(const AName: string): TRecorderTag;
    function RenameTag(ATag: TRecorderTag; const ANewName: string): Boolean;
    function FindCalibrationByName(const AName: string): TRecorderCalibration;
    function FindTagHardwareCalibration(ATag: TRecorderTag): TRecorderCalibration;
    function FindTagThermocoupleCalibration(ATag: TRecorderTag): TRecorderCalibration;
    function TransformTagHardwareValue(ATag: TRecorderTag; AValue: Double): Double;
    function TransformTagThermocoupleValue(ATag: TRecorderTag; AValue: Double): Double;
    function InvertTagThermocoupleValue(ATag: TRecorderTag; ATemperatureC: Double;
      out AMillivolts: Double): Boolean;
    function TransformTagValue(ATag: TRecorderTag; AValue: Double): Double;

    procedure RegisterActiveSource(const ASourceId: string);
    procedure UnregisterActiveSource(const ASourceId: string);
    procedure ClearActiveSources;
    procedure RefreshActiveSourcesFromTags;
    function IsSourceActive(const ASourceId: string): Boolean;

    { Публикует новое значение тега и отправляет событие rceDataUpdated. }
    procedure PublishValue(const ATagName: string; ATimeSec, AValue: Double);
    { Добавляет блок в кольцевой буфер тега без публикации события. }
    procedure AddBlockSamples(const ATagName: string; const ATimes,
      AValues: array of Double; ACount: Integer;
      AValuesAlreadyTransformed: Boolean = False);
    { Публикует хвостовое UI-событие после AddBlockSamples. }
    procedure NotifyBlockTail(const ATagName: string; ATimeSec, AValue: Double);
    { Публикует блок значений тега и отправляет событие rceDataUpdated. }
    procedure PublishBlock(const ATagName: string; const ATimes,
      AValues: array of Double; ACount: Integer;
      AValuesAlreadyTransformed: Boolean = False);
    { Подписчик на полный блок до публикации легковесного UI-события.
      Используется рантаймом спектров, чтобы не копировать блоки в EventBus
      из потока опроса MIC-140. }
    procedure SetBlockPublishedHandler(ATarget: TObject;
      AHandler: TRecorderTagBlockPublishedEvent);
    { Публикует спектр/UI-уведомления после AddBlockSamples. }
    procedure PublishBlockNotifications(const ATagName: string);

    { Удаляет все теги и очищает счетчик id. }
    procedure Clear;
    procedure RemoveTag(ATag: TRecorderTag);

    property ActiveSourceCount: Integer read GetActiveSourceCount;
    property ActiveSourceIds[AIndex: Integer]: string read GetActiveSourceId;
    property EventBus: TRecorderEventBus read fEventBus write fEventBus;
    property SelectedTag: TRecorderTag read GetSelectedTag;
    property SelectedTagName: string read fSelectedTagName write fSelectedTagName;
    property TagCount: Integer read GetTagCount;
    property Calibrations: TRecorderCalibrationList read fCalibrations;
    property SpectrumConfigs: TRecorderSpectrumConfigTree read fSpectrumConfigs;
    property FrequencyBands: TRecorderFrequencyBandList read fFrequencyBands;
    property Mic140DeviceConfigs: TStringList read fMic140DeviceConfigs;
    property Tags[AIndex: Integer]: TRecorderTag read GetTag;
  end;

{ Возвращает короткое обозначение типа оценки (например 'MO') }
function RecorderTagEstimateKindToShortName(AKind: TRecorderTagEstimateKind): string;
{ Возвращает полное имя типа оценки }
function RecorderTagEstimateKindToName(AKind: TRecorderTagEstimateKind): string;
{ Вычисляет оценку сигнала по переданному снимку }
function CalculateRecorderTagEstimate(const ASnapshot: TRecorderSignalSnapshot;
  AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;
{ Вычисляет оценку по непрерывному диапазону точек снимка без копирования массива.
  AStartIndex - индекс первой точки диапазона.
  ACount      - количество точек диапазона. }
function CalculateRecorderTagEstimateRange(const ASnapshot: TRecorderSignalSnapshot;
  AStartIndex, ACount: Integer; AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;
{ Возвращает расчетный размер порции оценки по частоте тега и периоду данных. }
function RecorderTagDefaultEstimatePortionLength(APollFrequencyHz: Double;
  ADataUpdateMs: Cardinal): Integer;
{ Проверяет, похож ли размер порции на автоматический дефолт, а не ручную настройку. }
function RecorderTagEstimatePortionLengthIsAuto(AValue: Integer;
  APollFrequencyHz: Double; ADataUpdateMs: Cardinal): Boolean;

function RecorderTagsShareSourceId(ARegistry: TRecorderTagRegistry;
  const ATagNames: array of string): Boolean;
function RecorderTagsShareSourceIdList(ARegistry: TRecorderTagRegistry;
  ATagNames: TStrings): Boolean;

const
  CDetachedTagSourcePrefix = 'Detached:';
  CMeraTagSourcePrefix = 'Mera file: ';
  CMic140TagSourcePrefix = 'MIC-140:';

function RecorderNormalizeTagSourceId(const ASourceId: string): string;
function RecorderIsDetachedTagSource(const ASourceId: string): Boolean;
function RecorderIsVirtualTagSource(const ASourceId: string): Boolean;
function RecorderIsHardwareMic140TagSource(const ASourceId: string): Boolean;
function RecorderTagUsesMic140Settings(const ATag: TRecorderTag): Boolean;
procedure RecorderTagClearMic140Settings(ATag: TRecorderTag);

implementation

uses
  StrUtils, uRecorderDebugLog, uRecorderMic140DeviceConfig;

const
  CTagThermocoupleInverseMinMv = -20.0;
  CTagThermocoupleInverseMaxMv = 100.0;
  CTagThermocoupleInverseIterations = 48;

function RecorderTagEstimateKindToShortName(AKind: TRecorderTagEstimateKind): string;
begin
  case AKind of
    tekMean: Result := 'MO';
    tekRmsValue: Result := 'RMS';
    tekRmsDeviation: Result := 'RMSD';
    tekPeak: Result := 'Peak';
    tekPeakToPeak: Result := 'P2P';
    tekMinimum: Result := 'Min';
    tekMaximum: Result := 'Max';
    tekPeakToPeakByRmsDeviation: Result := 'P2P/RMSD';
    tekLastValue: Result := 'Last';
  else
    Result := '';
  end;
end;

function RecorderTagEstimateKindToName(AKind: TRecorderTagEstimateKind): string;
begin
  case AKind of
    tekMean: Result := 'Mean';
    tekRmsValue: Result := 'RMS value';
    tekRmsDeviation: Result := 'RMS deviation';
    tekPeak: Result := 'Peak';
    tekPeakToPeak: Result := 'Peak-to-peak';
    tekMinimum: Result := 'Minimum';
    tekMaximum: Result := 'Maximum';
    tekPeakToPeakByRmsDeviation: Result := 'Peak-to-peak by RMSD';
    tekLastValue: Result := 'Last value';
  else
    Result := '';
  end;
end;

function CalculateRecorderTagEstimate(const ASnapshot: TRecorderSignalSnapshot;
  AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;
begin
  Result := CalculateRecorderTagEstimateRange(ASnapshot, 0, ASnapshot.Count, AKind);
end;

function CalculateRecorderTagEstimateRange(const ASnapshot: TRecorderSignalSnapshot;
  AStartIndex, ACount: Integer; AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;
var
  I: Integer;
  lIndex: Integer;
  lMean: Extended;
  lMin: Double;
  lMax: Double;
  lSum: Extended;
  lVarianceSum: Extended;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Kind := AKind;
  Result.Count := ACount;
  if (ACount <= 0) or (AStartIndex < 0) or
    (AStartIndex + ACount > ASnapshot.Count) then
    Exit;

  Result.Valid := True;
  Result.StartTimeSec := ASnapshot.Times[AStartIndex];
  Result.EndTimeSec := ASnapshot.Times[AStartIndex + ACount - 1];

  lMin := ASnapshot.Values[AStartIndex];
  lMax := ASnapshot.Values[AStartIndex];
  lSum := 0.0;
  for I := 0 to ACount - 1 do
  begin
    lIndex := AStartIndex + I;
    lSum := lSum + ASnapshot.Values[lIndex];
    if ASnapshot.Values[lIndex] < lMin then
      lMin := ASnapshot.Values[lIndex];
    if ASnapshot.Values[lIndex] > lMax then
      lMax := ASnapshot.Values[lIndex];
  end;
  lMean := lSum / ACount;

  case AKind of
    tekMean:
      Result.Value := lMean;
    tekRmsValue:
      begin
        lSum := 0.0;
        for I := 0 to ACount - 1 do
        begin
          lIndex := AStartIndex + I;
          lSum := lSum + ASnapshot.Values[lIndex] * ASnapshot.Values[lIndex];
        end;
        Result.Value := Sqrt(lSum / ACount);
      end;
    tekRmsDeviation:
      begin
        if ACount = 1 then
          Result.Value := 0.0
        else
        begin
          lVarianceSum := 0.0;
          for I := 0 to ACount - 1 do
          begin
            lIndex := AStartIndex + I;
            lVarianceSum := lVarianceSum + Sqr(ASnapshot.Values[lIndex] - lMean);
          end;
          Result.Value := Sqrt(lVarianceSum / (ACount - 1));
        end;
      end;
    tekPeak:
      Result.Value := (lMax - lMin) / 2.0;
    tekPeakToPeak:
      Result.Value := lMax - lMin;
    tekMinimum:
      Result.Value := lMin;
    tekMaximum:
      Result.Value := lMax;
    tekPeakToPeakByRmsDeviation:
      begin
        if ACount = 1 then
          Result.Value := 0.0
        else
        begin
          lVarianceSum := 0.0;
          for I := 0 to ACount - 1 do
          begin
            lIndex := AStartIndex + I;
            lVarianceSum := lVarianceSum + Sqr(ASnapshot.Values[lIndex] - lMean);
          end;
          Result.Value := 2.0 * Sqrt(2.0) *
            Sqrt(lVarianceSum / (ACount - 1));
        end;
      end;
    tekLastValue:
      Result.Value := ASnapshot.Values[AStartIndex + ACount - 1];
  end;
end;

function RecorderTagDefaultEstimatePortionLength(APollFrequencyHz: Double;
  ADataUpdateMs: Cardinal): Integer;
begin
  if ADataUpdateMs = 0 then
    ADataUpdateMs := 300;
  if APollFrequencyHz <= 0 then
    Result := 1
  else
    Result := Round(APollFrequencyHz * ADataUpdateMs / 1000.0);
  if Result < 1 then
    Result := 1;
end;

function RecorderTagEstimatePortionLengthIsAuto(AValue: Integer;
  APollFrequencyHz: Double; ADataUpdateMs: Cardinal): Boolean;
const
  CRecorderLegacyDefaultPortionLength = 17280;
begin
  Result := (AValue = CRecorderLegacyDefaultPortionLength) or
    (AValue = RecorderTagDefaultEstimatePortionLength(APollFrequencyHz,
    ADataUpdateMs));
end;

function RecorderTagsShareSourceId(ARegistry: TRecorderTagRegistry;
  const ATagNames: array of string): Boolean;
var
  I: Integer;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  Result := False;
  if ARegistry = nil then
    Exit;
  lSourceId := '';
  for I := Low(ATagNames) to High(ATagNames) do
  begin
    if Trim(ATagNames[I]) = '' then
      Continue;
    lTag := ARegistry.FindByName(ATagNames[I]);
    if lTag = nil then
      Exit;
    if lSourceId = '' then
      lSourceId := lTag.SourceId
    else
    if not SameText(lTag.SourceId, lSourceId) then
      Exit;
  end;
  Result := lSourceId <> '';
end;

function RecorderTagsShareSourceIdList(ARegistry: TRecorderTagRegistry;
  ATagNames: TStrings): Boolean;
var
  I: Integer;
  lNames: array of string;
begin
  if (ATagNames = nil) or (ATagNames.Count = 0) then
    Exit(False);
  SetLength(lNames, ATagNames.Count);
  for I := 0 to ATagNames.Count - 1 do
    lNames[I] := ATagNames[I];
  Result := RecorderTagsShareSourceId(ARegistry, lNames);
end;

{ TRecorderSignalBuffer }
constructor TRecorderSignalBuffer.Create(ACapacity: Integer);
begin
  inherited Create;
  if ACapacity <= 0 then
    raise ERecorderTagError.Create('Signal buffer capacity must be positive');

  fCapacity := ACapacity;
  SetLength(fTimes, fCapacity);
  SetLength(fValues, fCapacity);
  InitCriticalSection(fLock);
end;

destructor TRecorderSignalBuffer.Destroy;
begin
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderSignalBuffer.GetLatestTime: Double;
var
  lIndex: Integer;
begin
  EnterCriticalSection(fLock);
  try
    if fCount = 0 then
      Exit(0);
    lIndex := (fStart + fCount - 1) mod fCapacity;
    Result := fTimes[lIndex];
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderSignalBuffer.GetLatestValue: Double;
var
  lIndex: Integer;
begin
  EnterCriticalSection(fLock);
  try
    if fCount = 0 then
      Exit(0);
    lIndex := (fStart + fCount - 1) mod fCapacity;
    Result := fValues[lIndex];
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalBuffer.Clear;
begin
  EnterCriticalSection(fLock);
  try
    fStart := 0;
    fCount := 0;
    fLastBlockCount := 0;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalBuffer.AddSample(ATimeSec, AValue: Double);
var
  lIndex: Integer;
begin
  EnterCriticalSection(fLock);
  try
    if fCount < fCapacity then
    begin
      lIndex := (fStart + fCount) mod fCapacity;
      Inc(fCount);
    end
    else
    begin
      lIndex := fStart;
      fStart := (fStart + 1) mod fCapacity;
    end;

    fTimes[lIndex] := ATimeSec;
    fValues[lIndex] := AValue;
    fLastBlockCount := 1;
    SetLength(fLastBlockTimes, 1);
    SetLength(fLastBlockValues, 1);
    fLastBlockTimes[0] := ATimeSec;
    fLastBlockValues[0] := AValue;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalBuffer.AddSamples(const ATimes, AValues: array of Double;
  ACount: Integer);
var
  I: Integer;
  lIndex: Integer;
begin
  if ACount < 0 then
    raise ERecorderTagError.Create('Sample block count cannot be negative');
  if (ACount > Length(ATimes)) or (ACount > Length(AValues)) then
    raise ERecorderTagError.Create('Sample block count exceeds data length');

  EnterCriticalSection(fLock);
  try
    fLastBlockCount := ACount;
    SetLength(fLastBlockTimes, ACount);
    SetLength(fLastBlockValues, ACount);
    if ACount > 0 then
    begin
      Move(ATimes[0], fLastBlockTimes[0], ACount * SizeOf(Double));
      Move(AValues[0], fLastBlockValues[0], ACount * SizeOf(Double));
    end;
    for I := 0 to ACount - 1 do
    begin
      if fCount < fCapacity then
      begin
        lIndex := (fStart + fCount) mod fCapacity;
        Inc(fCount);
      end
      else
      begin
        lIndex := fStart;
        fStart := (fStart + 1) mod fCapacity;
      end;

      fTimes[lIndex] := ATimes[I];
      fValues[lIndex] := AValues[I];
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalBuffer.SetCapacity(ACapacity: Integer);
var
  I: Integer;
  lKeepCount: Integer;
  lOldIndex: Integer;
  lTimes: array of Double;
  lValues: array of Double;
begin
  if ACapacity <= 0 then
    raise ERecorderTagError.Create('Signal buffer capacity must be positive');

  EnterCriticalSection(fLock);
  try
    if ACapacity = fCapacity then
      Exit;

    lKeepCount := fCount;
    if lKeepCount > ACapacity then
      lKeepCount := ACapacity;

    SetLength(lTimes, ACapacity);
    SetLength(lValues, ACapacity);
    for I := 0 to lKeepCount - 1 do
    begin
      lOldIndex := (fStart + fCount - lKeepCount + I) mod fCapacity;
      lTimes[I] := fTimes[lOldIndex];
      lValues[I] := fValues[lOldIndex];
    end;

    fTimes := lTimes;
    fValues := lValues;
    fCapacity := ACapacity;
    fCount := lKeepCount;
    fStart := 0;
  finally
    LeaveCriticalSection(fLock);
  end;
end;
function TRecorderSignalBuffer.Snapshot: TRecorderSignalSnapshot;
var
  I: Integer;
  lIndex: Integer;
begin
  EnterCriticalSection(fLock);
  try
    Result.Count := fCount;
    SetLength(Result.Times, fCount);
    SetLength(Result.Values, fCount);

    for I := 0 to fCount - 1 do
    begin
      lIndex := (fStart + I) mod fCapacity;
      Result.Times[I] := fTimes[lIndex];
      Result.Values[I] := fValues[lIndex];
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderSignalBuffer.LastBlockSnapshot: TRecorderSignalSnapshot;
var
  I: Integer;
begin
  EnterCriticalSection(fLock);
  try
    Result.Count := fLastBlockCount;
    SetLength(Result.Times, fLastBlockCount);
    SetLength(Result.Values, fLastBlockCount);
    if fLastBlockCount > 0 then
    begin
      Move(fLastBlockTimes[0], Result.Times[0], fLastBlockCount * SizeOf(Double));
      Move(fLastBlockValues[0], Result.Values[0], fLastBlockCount * SizeOf(Double));
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

{ TRecorderTag }

constructor TRecorderTag.Create(AId: TRecorderTagId; const AName: string;
  ACapacity: Integer);
var
  lKind: TRecorderTagEstimateKind;
begin
  inherited Create;
  if AName = '' then
    raise ERecorderTagError.Create('Tag name cannot be empty');

  fId := AId;
  fName := AName;
  fAutoRange := True;
  fAutoUnit := True;
  fPollFrequencyHz := 0;
  fRangeMin := -32000;
  fRangeMax := 32000;
  for lKind := Low(TRecorderTagEstimateKind) to High(TRecorderTagEstimateKind) do
    fEstimateSettings.EnabledKinds[lKind] := lKind = tekMean;
  fEstimateSettings.DefaultKind := tekMean;
  fEstimateSettings.PortionLength := 17280;
  fEstimateSettings.SmoothingEnabled := False;
  fEstimateSettings.SmoothingK := 1.0;
  fEstimateSettings.ScadaEnabled := False;
  fSetpoints[tskHighAlarm].Threshold := 10.0;
  fSetpoints[tskHighAlarm].Color := $0000FF;
  fSetpoints[tskHighWarning].Threshold := 5.0;
  fSetpoints[tskHighWarning].Color := $00FFFF;
  fSetpoints[tskLowWarning].Threshold := -5.0;
  fSetpoints[tskLowWarning].Color := $00FFFF;
  fSetpoints[tskLowAlarm].Threshold := -10.0;
  fSetpoints[tskLowAlarm].Color := $0000FF;
  fSetpointSoundUntilEnd := True;
  fMic140CjcDefault := True;
  fMic140CjcChannel := 0;
  fChannelCalibrationEnabled := True;
  fCalibrationNames := TStringList.Create;
  fCalibrationNames.CaseSensitive := False;
  fSignalBuffer := TRecorderSignalBuffer.Create(ACapacity);
end;

destructor TRecorderTag.Destroy;
begin
  fSignalBuffer.Free;
  fCalibrationNames.Free;
  inherited Destroy;
end;

procedure TRecorderTag.AddSample(ATimeSec, AValue: Double);
begin
  fSignalBuffer.AddSample(ATimeSec, AValue);
  fTextValue := FloatToStr(AValue);
end;

procedure TRecorderTag.AddSamples(const ATimes, AValues: array of Double;
  ACount: Integer);
begin
  fSignalBuffer.AddSamples(ATimes, AValues, ACount);
  if ACount > 0 then
    fTextValue := FloatToStr(AValues[ACount - 1]);
end;

procedure TRecorderTag.EnsureBufferCapacity(ACapacity: Integer);
begin
  if ACapacity > fSignalBuffer.Capacity then
    fSignalBuffer.SetCapacity(ACapacity);
end;

procedure TRecorderTag.ClearSignalHistory;
begin
  fSignalBuffer.Clear;
  fTextValue := '';
end;

function TRecorderTag.Snapshot: TRecorderSignalSnapshot;
begin
  Result := fSignalBuffer.Snapshot;
end;

function TRecorderTag.LastBlockSnapshot: TRecorderSignalSnapshot;
begin
  Result := fSignalBuffer.LastBlockSnapshot;
end;

function TRecorderTag.Estimate(
  AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;
var
  lSnapshot: TRecorderSignalSnapshot;
begin
  lSnapshot := LastBlockSnapshot;
  if lSnapshot.Count = 0 then
    lSnapshot := Snapshot;
  Result := CalculateRecorderTagEstimate(lSnapshot, AKind);
end;

function TRecorderTag.GetSetpoint(
  AKind: TRecorderTagSetpointKind): TRecorderTagSetpoint;
begin
  Result := fSetpoints[AKind];
end;

procedure TRecorderTag.SetSetpoint(AKind: TRecorderTagSetpointKind;
  const AValue: TRecorderTagSetpoint);
begin
  fSetpoints[AKind] := AValue;
end;

{ TRecorderTagUpdateEventData }

constructor TRecorderTagUpdateEventData.Create(ATag: TRecorderTag; ATimeSec,
  AValue: Double);
begin
  inherited Create;
  fTag := ATag;
  fTimeSec := ATimeSec;
  fValue := AValue;
  fSampleCount := 1;
  fBlockTailNotify := False;
  SetLength(fTimes, 1);
  SetLength(fValues, 1);
  fTimes[0] := ATimeSec;
  fValues[0] := AValue;
end;

constructor TRecorderTagUpdateEventData.CreateBlockTailNotify(ATag: TRecorderTag;
  ATimeSec, AValue: Double);
begin
  inherited Create;
  fTag := ATag;
  fTimeSec := ATimeSec;
  fValue := AValue;
  fSampleCount := 1;
  fBlockTailNotify := True;
  SetLength(fTimes, 1);
  SetLength(fValues, 1);
  fTimes[0] := ATimeSec;
  fValues[0] := AValue;
end;

constructor TRecorderTagUpdateEventData.CreateBlock(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer);
begin
  inherited Create;
  if ACount <= 0 then
    raise ERecorderTagError.Create('Tag update block cannot be empty');
  if (ACount > Length(ATimes)) or (ACount > Length(AValues)) then
    raise ERecorderTagError.Create('Tag update block count exceeds data length');

  fTag := ATag;
  fSampleCount := ACount;
  fBlockTailNotify := False;
  SetLength(fTimes, ACount);
  SetLength(fValues, ACount);
  if ACount > 0 then
  begin
    Move(ATimes[0], fTimes[0], ACount * SizeOf(Double));
    Move(AValues[0], fValues[0], ACount * SizeOf(Double));
  end;
  fTimeSec := fTimes[ACount - 1];
  fValue := fValues[ACount - 1];
end;

{ TRecorderTagRegistry }

constructor TRecorderTagRegistry.Create(AEventBus: TRecorderEventBus);
begin
  inherited Create;
  fEventBus := AEventBus;
  fActiveSourceIds := TStringList.Create;
  fActiveSourceIds.CaseSensitive := False;
  fActiveSourceIds.Sorted := False;
  fTags := TList.Create;
  fNextId := 1;
  fCalibrations := TRecorderCalibrationList.Create;
  fSpectrumConfigs := TRecorderSpectrumConfigTree.Create;
  fFrequencyBands := TRecorderFrequencyBandList.Create;
  fMic140DeviceConfigs := TStringList.Create;
  fMic140DeviceConfigs.OwnsObjects := True;
  fMic140DeviceConfigs.CaseSensitive := False;
end;

destructor TRecorderTagRegistry.Destroy;
begin
  Clear;
  fMic140DeviceConfigs.Free;
  fFrequencyBands.Free;
  fSpectrumConfigs.Free;
  fCalibrations.Free;
  fActiveSourceIds.Free;
  fTags.Free;
  inherited Destroy;
end;

function TRecorderTagRegistry.GetActiveSourceCount: Integer;
begin
  Result := fActiveSourceIds.Count;
end;

function TRecorderTagRegistry.GetActiveSourceId(AIndex: Integer): string;
begin
  Result := fActiveSourceIds[AIndex];
end;

function TRecorderTagRegistry.GetSelectedTag: TRecorderTag;
begin
  Result := FindByName(fSelectedTagName);
end;

function TRecorderTagRegistry.GetTag(AIndex: Integer): TRecorderTag;
begin
  Result := TRecorderTag(fTags[AIndex]);
end;

function TRecorderTagRegistry.GetTagCount: Integer;
begin
  Result := fTags.Count;
end;

function TRecorderTagRegistry.CreateTag(const AName: string;
  ACapacity: Integer): TRecorderTag;
begin
  Result := TRecorderTag.Create(fNextId, AName, ACapacity);
  try
    AddTag(Result);
    Inc(fNextId);
  except
    Result.Free;
    raise;
  end;
end;

function TRecorderTagRegistry.AddTag(ATag: TRecorderTag): TRecorderTag;
begin
  if ATag = nil then
    raise ERecorderTagError.Create('Tag cannot be nil');
  if FindById(ATag.Id) <> nil then
    raise ERecorderTagError.CreateFmt('Tag id already exists: %d', [ATag.Id]);
  if FindByName(ATag.Name) <> nil then
    raise ERecorderTagError.CreateFmt('Tag name already exists: %s', [ATag.Name]);

  fTags.Add(ATag);
  if ATag.Id >= fNextId then
    fNextId := ATag.Id + 1;
  Result := ATag;
end;

function TRecorderTagRegistry.FindById(AId: TRecorderTagId): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fTags.Count - 1 do
    if GetTag(I).Id = AId then
      Exit(GetTag(I));
end;

function TRecorderTagRegistry.FindByName(const AName: string): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fTags.Count - 1 do
    if SameText(GetTag(I).Name, AName) then
      Exit(GetTag(I));
end;


function TRecorderTagRegistry.RenameTag(ATag: TRecorderTag; const ANewName: string): Boolean;
var
  lExisting: TRecorderTag;
  lNewName: string;
begin
  Result := False;
  if ATag = nil then
    Exit;
  lNewName := Trim(ANewName);
  if lNewName = '' then
    Exit;
  if SameText(lNewName, ATag.Name) then
    Exit(True);
  lExisting := FindByName(lNewName);
  if (lExisting <> nil) and (lExisting <> ATag) then
    raise ERecorderTagError.Create('Tag name already exists: ' + lNewName);
  if SameText(fSelectedTagName, ATag.Name) then
    fSelectedTagName := lNewName;
  ATag.Name := lNewName;
  Result := True;
end;


function TRecorderTagRegistry.FindCalibrationByName(const AName: string): TRecorderCalibration;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fCalibrations.Count - 1 do
    if (fCalibrations[I] <> nil) and SameText(fCalibrations[I].Name, AName) then
      Exit(fCalibrations[I]);
end;

function TRecorderTagRegistry.FindTagHardwareCalibration(
  ATag: TRecorderTag): TRecorderCalibration;
var
  lName: string;
begin
  Result := nil;
  if ATag = nil then
    Exit;
  if RecorderMic140TagHardwareCalibrationEnabled(Self, ATag) then
  begin
    lName := RecorderMic140TagHardwareCalibrationName(Self, ATag);
    if Trim(lName) <> '' then
      Exit(FindCalibrationByName(lName));
  end;
  if ATag.HardwareCalibrationEnabled and (Trim(ATag.HardwareCalibrationName) <> '') then
    Result := FindCalibrationByName(ATag.HardwareCalibrationName);
end;

function TRecorderTagRegistry.FindTagThermocoupleCalibration(
  ATag: TRecorderTag): TRecorderCalibration;
var
  I: Integer;
  lName: string;
begin
  Result := nil;
  if (ATag = nil) or (not ATag.ChannelCalibrationEnabled) or
    (ATag.CalibrationNames = nil) then
    Exit;
  for I := 0 to ATag.CalibrationNames.Count - 1 do
  begin
    lName := Trim(ATag.CalibrationNames[I]);
    if StartsText('TC ', lName) then
      Exit(FindCalibrationByName(lName));
  end;
end;

function TRecorderTagRegistry.TransformTagHardwareValue(ATag: TRecorderTag;
  AValue: Double): Double;
var
  lCalibration: TRecorderCalibration;
begin
  Result := AValue;
  if ATag = nil then
    Exit;
  lCalibration := FindTagHardwareCalibration(ATag);
  if lCalibration <> nil then
    Result := lCalibration.Transform(Result);
end;

function TRecorderTagRegistry.TransformTagThermocoupleValue(ATag: TRecorderTag;
  AValue: Double): Double;
var
  lCalibration: TRecorderCalibration;
begin
  Result := AValue;
  if ATag = nil then
    Exit;
  lCalibration := FindTagThermocoupleCalibration(ATag);
  if lCalibration <> nil then
    Result := lCalibration.Transform(Result);
end;

function TRecorderTagRegistry.InvertTagThermocoupleValue(ATag: TRecorderTag;
  ATemperatureC: Double; out AMillivolts: Double): Boolean;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lHi: Double;
  lLo: Double;
  lMid: Double;
  lMidValue: Double;
  lReverse: Boolean;
begin
  Result := False;
  AMillivolts := 0.0;
  lCalibration := FindTagThermocoupleCalibration(ATag);
  if lCalibration = nil then
    Exit;

  lLo := CTagThermocoupleInverseMinMv;
  lHi := CTagThermocoupleInverseMaxMv;
  lReverse := lCalibration.Transform(lLo) > lCalibration.Transform(lHi);
  for I := 0 to CTagThermocoupleInverseIterations - 1 do
  begin
    lMid := (lLo + lHi) * 0.5;
    lMidValue := lCalibration.Transform(lMid);
    if (lMidValue < ATemperatureC) xor lReverse then
      lLo := lMid
    else
      lHi := lMid;
  end;
  AMillivolts := (lLo + lHi) * 0.5;
  Result := True;
end;

function TRecorderTagRegistry.TransformTagValue(ATag: TRecorderTag; AValue: Double): Double;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
begin
  Result := TransformTagHardwareValue(ATag, AValue);
  if (ATag = nil) or (not ATag.ChannelCalibrationEnabled) then
    Exit;
  for I := 0 to ATag.CalibrationNames.Count - 1 do
  begin
    lCalibration := FindCalibrationByName(ATag.CalibrationNames[I]);
    if lCalibration <> nil then
      Result := lCalibration.Transform(Result);
  end;
end;
procedure TRecorderTagRegistry.RegisterActiveSource(const ASourceId: string);
var
  lSourceId: string;
begin
  lSourceId := Trim(ASourceId);
  if lSourceId = '' then
    Exit;
  if fActiveSourceIds.IndexOf(lSourceId) < 0 then
    fActiveSourceIds.Add(lSourceId);
end;

procedure TRecorderTagRegistry.UnregisterActiveSource(const ASourceId: string);
var
  lIndex: Integer;
begin
  lIndex := fActiveSourceIds.IndexOf(Trim(ASourceId));
  if lIndex >= 0 then
    fActiveSourceIds.Delete(lIndex);
end;

procedure TRecorderTagRegistry.ClearActiveSources;
begin
  fActiveSourceIds.Clear;
end;

function RecorderNormalizeTagSourceId(const ASourceId: string): string;
begin
  Result := Trim(ASourceId);
  if Pos(CDetachedTagSourcePrefix, Result) = 1 then
    Result := Trim(Copy(Result, Length(CDetachedTagSourcePrefix) + 1, MaxInt));
end;

function RecorderIsDetachedTagSource(const ASourceId: string): Boolean;
begin
  Result := Pos(CDetachedTagSourcePrefix, Trim(ASourceId)) = 1;
end;

function RecorderIsVirtualTagSource(const ASourceId: string): Boolean;
begin
  Result := Pos(CMeraTagSourcePrefix, RecorderNormalizeTagSourceId(ASourceId)) = 1;
end;

function RecorderIsHardwareMic140TagSource(const ASourceId: string): Boolean;
begin
  Result := Pos(CMic140TagSourcePrefix, RecorderNormalizeTagSourceId(ASourceId)) = 1;
end;

function RecorderTagUsesMic140Settings(const ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and RecorderIsHardwareMic140TagSource(ATag.SourceId);
end;

procedure RecorderTagClearMic140Settings(ATag: TRecorderTag);
begin
  if ATag = nil then
    Exit;
  ATag.MeasRangeIndex := 0;
  ATag.HardwareCalibrationEnabled := False;
  ATag.HardwareCalibrationName := '';
  ATag.Mic140DeviceSerial := 0;
  ATag.Mic140ThermoCompensationEnabled := False;
  ATag.Mic140CjcDefault := True;
  ATag.Mic140CjcChannel := 0;
  ATag.Mic140ThermocoupleScaleName := '';
  ATag.Mic140ThermocoupleScalePath := '';
  ATag.Mic140SoftBalance := 0;
end;

procedure TRecorderTagRegistry.RefreshActiveSourcesFromTags;
var
  I: Integer;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  ClearActiveSources;
  RegisterActiveSource('manual');
  RegisterActiveSource('debug.diagnostics');
  for I := 0 to TagCount - 1 do
  begin
    lTag := Tags[I];
    if RecorderIsDetachedTagSource(lTag.SourceId) then
      Continue;
    lSourceId := Trim(lTag.SourceId);
    if lSourceId = '' then
      Continue;
    if Pos(CMeraTagSourcePrefix, lSourceId) = 1 then
      RegisterActiveSource(lSourceId)
    else if Pos(CMic140TagSourcePrefix, lSourceId) = 1 then
      RegisterActiveSource(lSourceId);
  end;
end;

function TRecorderTagRegistry.IsSourceActive(const ASourceId: string): Boolean;
var
  lSourceId: string;
begin
  lSourceId := Trim(ASourceId);
  Result := (lSourceId = '') or (fActiveSourceIds.IndexOf(lSourceId) >= 0);
end;

procedure TRecorderTagRegistry.PublishValue(const ATagName: string; ATimeSec,
  AValue: Double);
var
  lEvent: TRecorderEvent;
  lTag: TRecorderTag;
  lEventData: TRecorderTagUpdateEventData;
  lValue: Double;
begin
  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);

  lValue := TransformTagValue(lTag, AValue);
  lTag.AddSample(ATimeSec, lValue);

  if fEventBus <> nil then
  begin
    lEventData := TRecorderTagUpdateEventData.Create(lTag, ATimeSec, lValue);
    try
      lEvent := TRecorderEventBus.MakeEvent(rceDataUpdated, Self, lTag.Name,
        lTag.TextValue, 1, lEventData);
      fEventBus.Publish(lEvent);
    finally
      lEventData.Free;
    end;
  end;
end;

procedure TRecorderTagRegistry.SetBlockPublishedHandler(ATarget: TObject;
  AHandler: TRecorderTagBlockPublishedEvent);
begin
  fBlockPublishedTarget := ATarget;
  fOnBlockPublished := AHandler;
end;

procedure TRecorderTagRegistry.AddBlockSamples(const ATagName: string;
  const ATimes, AValues: array of Double; ACount: Integer;
  AValuesAlreadyTransformed: Boolean);
var
  lTag: TRecorderTag;
  lValues: TRecorderDoubleArray;
  I: Integer;
begin
  if ACount <= 0 then
    Exit;
  if (ACount > Length(ATimes)) or (ACount > Length(AValues)) then
    raise ERecorderTagError.Create('Publish block count exceeds data length');

  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);

  SetLength(lValues, ACount);
  if AValuesAlreadyTransformed then
  begin
    if ACount > 0 then
      Move(AValues[0], lValues[0], ACount * SizeOf(Double));
  end
  else
    for I := 0 to ACount - 1 do
      lValues[I] := TransformTagValue(lTag, AValues[I]);
  lTag.AddSamples(ATimes, lValues, ACount);
end;

procedure TRecorderTagRegistry.NotifyBlockTail(const ATagName: string;
  ATimeSec, AValue: Double);
var
  lEvent: TRecorderEvent;
  lTag: TRecorderTag;
  lEventData: TRecorderTagUpdateEventData;
begin
  if fEventBus = nil then
    Exit;
  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);
  lEventData := TRecorderTagUpdateEventData.CreateBlockTailNotify(lTag, ATimeSec,
    AValue);
  try
    lEvent := TRecorderEventBus.MakeEvent(rceDataUpdated, Self, lTag.Name,
      lTag.TextValue, 1, lEventData);
    fEventBus.Publish(lEvent);
  finally
    lEventData.Free;
  end;
end;

procedure TRecorderTagRegistry.PublishBlockNotifications(const ATagName: string);
var
  lSnapshot: TRecorderSignalSnapshot;
  lTag: TRecorderTag;
begin
  lTag := FindByName(ATagName);
  if lTag = nil then
    Exit;
  lSnapshot := lTag.LastBlockSnapshot;
  if lSnapshot.Count <= 0 then
    Exit;
  if Assigned(fOnBlockPublished) then
    fOnBlockPublished(fBlockPublishedTarget, ATagName, lSnapshot.Times,
      lSnapshot.Values, lSnapshot.Count);
  if fEventBus <> nil then
    NotifyBlockTail(ATagName, lSnapshot.Times[lSnapshot.Count - 1],
      lSnapshot.Values[lSnapshot.Count - 1]);
end;

procedure TRecorderTagRegistry.PublishBlock(const ATagName: string; const ATimes,
  AValues: array of Double; ACount: Integer; AValuesAlreadyTransformed: Boolean);
var
  lEvent: TRecorderEvent;
  lTag: TRecorderTag;
  lEventData: TRecorderTagUpdateEventData;
  lSnapshot: TRecorderSignalSnapshot;
begin
  if ACount <= 0 then
    Exit;

  AddBlockSamples(ATagName, ATimes, AValues, ACount, AValuesAlreadyTransformed);
  // This method is in the acquisition hot path. Per-tag disk logging turns a
  // 48-channel hardware block into dozens of synchronous writes and can delay
  // the next MIC-140 TCP read. Device-level diagnostics log block summaries.

  lTag := FindByName(ATagName);
  if lTag = nil then
    Exit;

  if Assigned(fOnBlockPublished) then
    PublishBlockNotifications(ATagName)
  else if fEventBus <> nil then
  begin
    lSnapshot := lTag.LastBlockSnapshot;
    lEventData := TRecorderTagUpdateEventData.CreateBlock(lTag, lSnapshot.Times,
      lSnapshot.Values, lSnapshot.Count);
    try
      lEvent := TRecorderEventBus.MakeEvent(rceDataUpdated, Self, lTag.Name,
        lTag.TextValue, lEventData.SampleCount, lEventData);
      fEventBus.Publish(lEvent);
    finally
      lEventData.Free;
    end;
  end;
end;

procedure TRecorderTagRegistry.RemoveTag(ATag: TRecorderTag);
begin
  if ATag <> nil then
  begin
    fTags.Remove(ATag);
    ATag.Free;
  end;
end;

procedure TRecorderTagRegistry.Clear;
var
  I: Integer;
begin
  for I := 0 to fTags.Count - 1 do
    TObject(fTags[I]).Free;
  fTags.Clear;
  fMic140DeviceConfigs.Clear;
  fSelectedTagName := '';
  fNextId := 1;
end;


{ TRecorderCalibrationPoint }

constructor TRecorderCalibrationPoint.Create(AX, AY: Double);
begin
  X := AX;
  Y := AY;
end;

{ TRecorderCalibration }

constructor TRecorderCalibration.Create(AKind: TRecorderCalibrationKind);
begin
  inherited Create;
  fKind := AKind;
  fPoints := TList.Create;
  fScale := 1.0;
  fExtrapolation := True;
end;

destructor TRecorderCalibration.Destroy;
begin
  ClearPoints;
  fPoints.Free;
  inherited Destroy;
end;

procedure TRecorderCalibration.AddPoint(AX, AY: Double);
begin
  fPoints.Add(TRecorderCalibrationPoint.Create(AX, AY));
end;


procedure TRecorderCalibration.Assign(ASource: TRecorderCalibration);
var
  I: Integer;
  lPoint: TRecorderCalibrationPoint;
begin
  if ASource = nil then
    Exit;
  fName := ASource.Name;
  fDescription := ASource.Description;
  fUnitIn := ASource.UnitIn;
  fUnitOut := ASource.UnitOut;
  fExtrapolation := ASource.Extrapolation;
  fKind := ASource.Kind;
  fScale := ASource.Scale;
  ClearPoints;
  for I := 0 to ASource.PointCount - 1 do
  begin
    lPoint := ASource.PointAt(I);
    if lPoint <> nil then
      AddPoint(lPoint.X, lPoint.Y);
  end;
end;

function TRecorderCalibration.Clone: TRecorderCalibration;
begin
  Result := TRecorderCalibration.Create(fKind);
  Result.Assign(Self);
end;

function TRecorderCalibration.Transform(AValue: Double): Double;
var
  I: Integer;
  lA: TRecorderCalibrationPoint;
  lB: TRecorderCalibrationPoint;
  lX1: Double;
  lX2: Double;
begin
  Result := AValue;
  case fKind of
    rckScale:
      Result := AValue * fScale;
    rckPiecewiseLinear:
      begin
        if fPoints.Count = 0 then
          Exit;
        if fPoints.Count = 1 then
        begin
          lA := PointAt(0);
          if lA <> nil then
            Result := lA.Y;
          Exit;
        end;

        for I := 0 to fPoints.Count - 2 do
        begin
          lA := PointAt(I);
          lB := PointAt(I + 1);
          if (lA = nil) or (lB = nil) then
            Continue;
          lX1 := Min(lA.X, lB.X);
          lX2 := Max(lA.X, lB.X);
          if (AValue >= lX1) and (AValue <= lX2) then
          begin
            if SameValue(lA.X, lB.X) then
              Result := lB.Y
            else
              Result := lA.Y + (AValue - lA.X) * (lB.Y - lA.Y) / (lB.X - lA.X);
            Exit;
          end;
        end;

        if (not fExtrapolation) and (AValue < PointAt(0).X) then
        begin
          Result := PointAt(0).Y;
          Exit;
        end;
        if (not fExtrapolation) and (AValue > PointAt(fPoints.Count - 1).X) then
        begin
          Result := PointAt(fPoints.Count - 1).Y;
          Exit;
        end;

        if AValue < PointAt(0).X then
        begin
          lA := PointAt(0);
          lB := PointAt(1);
        end
        else
        begin
          lA := PointAt(fPoints.Count - 2);
          lB := PointAt(fPoints.Count - 1);
        end;
        if SameValue(lA.X, lB.X) then
          Result := lB.Y
        else
          Result := lA.Y + (AValue - lA.X) * (lB.Y - lA.Y) / (lB.X - lA.X);
      end;
  end;
end;
procedure TRecorderCalibration.ClearPoints;
var
  I: Integer;
begin
  for I := 0 to fPoints.Count - 1 do
    TObject(fPoints[I]).Free;
  fPoints.Clear;
end;

function TRecorderCalibration.PointAt(AIndex: Integer): TRecorderCalibrationPoint;
begin
  Result := GetPoint(AIndex);
end;

function TRecorderCalibration.GetPoint(AIndex: Integer): TRecorderCalibrationPoint;
begin
  if (AIndex >= 0) and (AIndex < fPoints.Count) then
    Result := TRecorderCalibrationPoint(fPoints[AIndex])
  else
    Result := nil;
end;

function TRecorderCalibration.GetPointCount: Integer;
begin
  Result := fPoints.Count;
end;

{ TRecorderCalibrationList }

constructor TRecorderCalibrationList.Create;
begin
  inherited Create;
  fList := TList.Create;
end;

destructor TRecorderCalibrationList.Destroy;
begin
  Clear;
  fList.Free;
  inherited Destroy;
end;

procedure TRecorderCalibrationList.Add(ACalibration: TRecorderCalibration);
begin
  fList.Add(ACalibration);
end;

procedure TRecorderCalibrationList.AddCopy(ACalibration: TRecorderCalibration);
begin
  if ACalibration <> nil then
    Add(ACalibration.Clone);
end;

procedure TRecorderCalibrationList.Delete(AIndex: Integer);
begin
  if (AIndex >= 0) and (AIndex < fList.Count) then
  begin
    TObject(fList[AIndex]).Free;
    fList.Delete(AIndex);
  end;
end;

procedure TRecorderCalibrationList.Exchange(AIndex1, AIndex2: Integer);
begin
  fList.Exchange(AIndex1, AIndex2);
end;

procedure TRecorderCalibrationList.Clear;
var
  I: Integer;
begin
  for I := 0 to fList.Count - 1 do
    TObject(fList[I]).Free;
  fList.Clear;
end;

function TRecorderCalibrationList.GetCount: Integer;
begin
  Result := fList.Count;
end;

function TRecorderCalibrationList.GetItem(AIndex: Integer): TRecorderCalibration;
begin
  if (AIndex >= 0) and (AIndex < fList.Count) then
    Result := TRecorderCalibration(fList[AIndex])
  else
    Result := nil;
end;

end.
