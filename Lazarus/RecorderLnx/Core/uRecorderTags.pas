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
  Classes, SysUtils, Math, Contnrs,
  uRecorderCoreServices, uRecorderSpectrumEngine, uRecorderFrequencyBands,
  uRecorderTimeSystem, uRecorderUnitManager;

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
    AlarmInfoText: string;        { Пользовательский текст события срабатывания }
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
    fBlockSampleCapacity: Integer;
    fBlockBaseSample: QWord;                 { Первый отсчёт текущей серии логических блоков }
    fBlockBaseSequence: QWord;               { Номер первого блока текущей серии }
    fTotalSamples: QWord;                     { Монотонный номер следующего отсчёта для независимых потребителей }
    fTotalBlocks: QWord;                      { Монотонный номер следующего принятого блока }
    fPendingBlockStart: QWord;                { Начало собираемой логической порции }
    fPendingBlockCount: Integer;              { Уже набрано отсчётов в логическую порцию }
    fRevision: QWord;                         { Версия содержимого для UI }
    fTimes: array of Double;                  { Массив времен }
    fValues: array of Double;                 { Массив значений }
    function GetCount: Integer;
    function GetRevision: QWord;
    function GetLatestTime: Double;
    function GetLatestValue: Double;
    procedure CopyRangeLocked(AFromTimeSec: Double; AIncludePrevious: Boolean;
      var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer);
    procedure AccumulateLogicalBlocks(AStartSample: QWord; ACount: Integer);
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
    { Выделяет кольцо порций до запуска сбора. В RunTime память не меняется. }
    procedure ConfigureBlockRing(ABlockSamples, ABlockCount: Integer);
    { Меняет емкость буфера, сохраняя последние доступные точки. }
    procedure SetCapacity(ACapacity: Integer);
    { Возвращает снимок от старой точки к новой. }
    function Snapshot: TRecorderSignalSnapshot;
    procedure SnapshotRangeInto(AFromTimeSec: Double; AIncludePrevious: Boolean;
      var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer);
    procedure CopyLatestInto(AWindowSeconds: Double;
      var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer;
      out ADisplayStart: Double);
    { Возвращает только ещё не прочитанные потребителем отсчёты и передвигает его курсор.
      Если потребитель отстал больше ёмкости кольца, возвращается вся доступная история. }
    function SnapshotSince(var ACursor: QWord): TRecorderSignalSnapshot;
    { Копирует непрочитанные отсчёты в переиспользуемые массивы потребителя. }
    procedure SnapshotSinceInto(var ACursor: QWord;
      var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer);
    { Текущая позиция записи. Используется для инициализации нового потребителя без старой истории. }
    function CurrentCursor: QWord;
    { Возвращает следующий целый непрочитанный блок. В уведомления массивы не копируются. }
    function SnapshotNextBlock(var ABlockCursor: QWord;
      out ASnapshot: TRecorderSignalSnapshot): Boolean;
    { Копирует следующий логический блок в принадлежащие вызывающему массивы.
      Массивы растут только при нехватке емкости и затем переиспользуются. }
    function SnapshotNextBlockInto(var ABlockCursor: QWord;
      var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer): Boolean;
    function CurrentBlockSampleCapacity: Integer;
    function CurrentBlockCursor: QWord;
    { Возвращает снимок последнего добавленного блока точек. }
    function LastBlockSnapshot: TRecorderSignalSnapshot;
    property Capacity: Integer read fCapacity;
    property Count: Integer read GetCount;
    property Revision: QWord read GetRevision;
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
    fGroupPath: string;                                        { Пользовательский путь группы в дереве тегов }
    fAutoRange: Boolean;                                       { Автоматический диапазон шкалы }
    fAutoUnit: Boolean;                                        { Автоматические единицы измерения }
    fCalibrationNames: TStringList;                          { Цепочка имен канальных ГХ }
    fId: TRecorderTagId;                                       { Уникальный ID тега }
    fIsVirtual: Boolean;                                      { Тег создан программным, а не аппаратным источником }
    fExternalWriteAllowed: Boolean;                           { Значение разрешено задавать из UI/внешнего клиента }
    fExternalWriteLock: TRTLCriticalSection;
    fExternalWriteRevision: QWord;
    fExternalWriteValues: array[0..15] of Double;
    fEstimateSettings: TRecorderTagEstimateSettings;           { Настройки расчета оценок }
    fEstimateCache: array[TRecorderTagEstimateKind] of TRecorderTagEstimate;
    fEstimateLock: TRTLCriticalSection;                        { Кэш оценок читается UI-потоком }
    fEstimatePortionCount: Integer;
    fEstimatePortionStartTime: Double;
    fEstimatePortionEndTime: Double;
    fEstimatePortionLastValue: Double;
    fEstimatePortionMin: Double;
    fEstimatePortionMax: Double;
    fEstimatePortionSum: Extended;
    fEstimatePortionSquareSum: Extended;
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
    fSetpointRangeControlEnabled: Boolean;                     { Контроль допустимого диапазона }
    fSetpointRangeAlarmInfoText: string;                       { Текст события выхода за диапазон }
    fSetpoints: array[TRecorderTagSetpointKind] of TRecorderTagSetpoint; { Уставки тега }
    fSourceValueMode: string;                                  { Режим значения, заданный источником }
    fHardwareCalibrationEnabled: Boolean;                      { Включена аппаратная ГХ с устройства }
    fHardwareCalibrationName: string;                          { Имя аппаратной ГХ в реестре калибровок }
    fChannelCalibrationEnabled: Boolean;                         { Включена канальная ГХ (термопарная/SDB) }
    fCalibrationScaleBuilt: Boolean;
    fCalibrationScaleLinear: Boolean;
    fHardwareScale: Double;
    fResultScale: Double;

    fTextValue: string;                                        { Текстовое представление последнего значения }
    fUnitName: string;                                         { Единица измерения }
    fSourceUnitName: string;                                   { Единица исходного значения до ГХ }
    function GetBlockCounter: QWord;
    function GetIsVector: Boolean;
    function GetSetpoint(AKind: TRecorderTagSetpointKind): TRecorderTagSetpoint;
    procedure UpdateEstimateCache(const ATimes, AValues: array of Double;
      ACount: Integer);
    procedure ClearEstimateCache;
    procedure SetSetpoint(AKind: TRecorderTagSetpointKind;
      const AValue: TRecorderTagSetpoint);
    procedure SetUnitName(const AValue: string);
    procedure SetSourceUnitName(const AValue: string);
    procedure SetAutoUnit(AValue: Boolean);
    procedure SetHardwareCalibrationEnabled(AValue: Boolean);
    procedure SetHardwareCalibrationName(const AValue: string);
    procedure SetChannelCalibrationEnabled(AValue: Boolean);
    procedure SetEstimateSettings(const AValue: TRecorderTagEstimateSettings);
  public
    { Создает тег.
      AId       - стабильный числовой id в пределах registry.
      AName     - уникальное имя тега.
      ACapacity - размер кольцевого буфера значений. }
    constructor Create(AId: TRecorderTagId; const AName: string;
      ACapacity: Integer = 4096; AIsVirtual: Boolean = False);
    { Деструктор уничтожает внутренний буфер сигнала }
    destructor Destroy; override;

    { Добавляет числовое значение в буфер тега. }
    procedure AddSample(ATimeSec, AValue: Double);
    { Добавляет блок значений в буфер тега. }
    procedure AddSamples(const ATimes, AValues: array of Double; ACount: Integer);
    { Расширяет кольцевой буфер тега без потери последних точек. }
    procedure EnsureBufferCapacity(ACapacity: Integer);
    procedure ConfigureBlockBuffer(ABlockSamples, ABlockCount: Integer);
    { Очищает историю сигнала после смены режима/ГХ канала. }
    procedure ClearSignalHistory;
    procedure InvalidateCalibrationScale;
    { Сохраняет последнюю внешнюю команду отдельно от входящих данных
      источника. Один consumer считывает её по монотонной ревизии. }
    procedure QueueExternalWrite(AValue: Double);
    function ReadExternalWrite(var ARevision: QWord;
      out AValue: Double): Boolean;
    function ExternalWriteCursor: QWord;

    { Возвращает снимок сигнала тега. }
    function Snapshot: TRecorderSignalSnapshot;
    procedure SnapshotRangeInto(AFromTimeSec: Double; AIncludePrevious: Boolean;
      var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer);
    procedure CopyLatestInto(AWindowSeconds: Double;
      var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer;
      out ADisplayStart: Double);
    { Возвращает снимок последнего записанного блока тега. }
    function LastBlockSnapshot: TRecorderSignalSnapshot;
    property BlockCounter: QWord read GetBlockCounter;
    { Расчитывает указанную оценку по текущим данным }
    function Estimate(AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;

    property Id: TRecorderTagId read fId;
    property IsVirtual: Boolean read fIsVirtual write fIsVirtual;
    property ExternalWriteAllowed: Boolean read fExternalWriteAllowed
      write fExternalWriteAllowed;
    property IsVector: Boolean read GetIsVector;
    property Name: string read fName write fName;
    property Address: string read fAddress write fAddress;
    property UnitName: string read fUnitName write SetUnitName;
    property SourceUnitName: string read fSourceUnitName write SetSourceUnitName;
    property Description: string read fDescription write fDescription;
    property GroupPath: string read fGroupPath write fGroupPath;
    property PollFrequencyHz: Double read fPollFrequencyHz write fPollFrequencyHz;
    property SensorCalibrationName: string read fSensorCalibrationName write fSensorCalibrationName;
    property AmplifierCalibrationName: string read fAmplifierCalibrationName write fAmplifierCalibrationName;
    property ModuleType: string read fModuleType write fModuleType;
    property RangeMin: Double read fRangeMin write fRangeMin;
    property RangeMax: Double read fRangeMax write fRangeMax;
    property AutoRange: Boolean read fAutoRange write fAutoRange;
    property AutoUnit: Boolean read fAutoUnit write SetAutoUnit;
    property CalibrationNames: TStringList read fCalibrationNames;
    property EstimateSettings: TRecorderTagEstimateSettings read fEstimateSettings
      write SetEstimateSettings;
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
    property SetpointRangeControlEnabled: Boolean
      read fSetpointRangeControlEnabled write fSetpointRangeControlEnabled;
    property SetpointRangeAlarmInfoText: string
      read fSetpointRangeAlarmInfoText write fSetpointRangeAlarmInfoText;
    property SourceId: string read fSourceId write fSourceId;
    property SourceValueMode: string read fSourceValueMode write fSourceValueMode;
    property HardwareCalibrationEnabled: Boolean read fHardwareCalibrationEnabled
      write SetHardwareCalibrationEnabled;
    property HardwareCalibrationName: string read fHardwareCalibrationName
      write SetHardwareCalibrationName;
    property ChannelCalibrationEnabled: Boolean read fChannelCalibrationEnabled
      write SetChannelCalibrationEnabled;
    property TextValue: string read fTextValue write fTextValue;
    property SignalBuffer: TRecorderSignalBuffer read fSignalBuffer;
    property CalibrationScaleBuilt: Boolean read fCalibrationScaleBuilt;
    property CalibrationScaleLinear: Boolean read fCalibrationScaleLinear;
    property ResultScale: Double read fResultScale;
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

  TRecorderCalibrationKind = (rckScale, rckLinear, rckPiecewiseLinear,
    rckPolynomial, rckStrain);

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
    fOffset: Double;
    fK1: Double;
    fK2: Double;
    fModuleData: string;
    fSdbKey: string;
    fSourceFileName: string;
    fPoints: TList; // List of TRecorderCalibrationPoint
    function GetPoint(AIndex: Integer): TRecorderCalibrationPoint;
    function GetPointCount: Integer;
  public
    constructor Create(AKind: TRecorderCalibrationKind);
    destructor Destroy; override;
    procedure AddPoint(AX, AY: Double);
    procedure Assign(ASource: TRecorderCalibration);
    function Clone: TRecorderCalibration;
    function ConvertInputUnit(const AUnitName: string): Boolean;
    function ConvertOutputUnit(const AUnitName: string): Boolean;
    function Transform(AValue: Double): Double;
    function InverseTransform(AValue: Double; out AInputValue: Double): Boolean;
    procedure ClearPoints;
    function PointAt(AIndex: Integer): TRecorderCalibrationPoint;
    property Name: string read fName write fName;
    property Description: string read fDescription write fDescription;
    property UnitIn: string read fUnitIn write fUnitIn;
    property UnitOut: string read fUnitOut write fUnitOut;
    property Extrapolation: Boolean read fExtrapolation write fExtrapolation;
    property Kind: TRecorderCalibrationKind read fKind write fKind;
    property Scale: Double read fScale write fScale;
    property Offset: Double read fOffset write fOffset;
    property K1: Double read fK1 write fK1;
    property K2: Double read fK2 write fK2;
    property ModuleData: string read fModuleData write fModuleData;
    property SdbKey: string read fSdbKey write fSdbKey;
    property SourceFileName: string read fSourceFileName write fSourceFileName;
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
  TRecorderTagSqlBlockPublishedEvent = procedure(Sender: TObject;
    ATag: TRecorderTag; ATimeSec, AValue: Double) of object;
  TRecorderTagValuePublishedEvent = procedure(Sender: TObject; ATag: TRecorderTag;
    ATimeSec, AValue: Double) of object;
  TRecorderEnsureCalibrationDataEvent = function(ATag: TRecorderTag;
    out AStartedByCalibration: Boolean; out AError: string): Boolean of object;
  TRecorderReleaseCalibrationDataEvent = procedure(ATag: TRecorderTag) of object;

  TRecorderTagRegistry = class
  private
    fStructureRevision: QWord;
    fActiveSourceIds: TStringList;                     { Active data source ids for detached tag indication }
    fBlockPublishedTarget: TObject;
    fOnBlockPublished: TRecorderTagBlockPublishedEvent;
    fSqlBlockPublishedTarget: TObject;
    fOnSqlBlockPublished: TRecorderTagSqlBlockPublishedEvent;
    fValuePublishedTarget: TObject;
    fOnValuePublished: TRecorderTagValuePublishedEvent;
    fAlarmValuePublishedTarget: TObject;
    fOnAlarmValuePublished: TRecorderTagValuePublishedEvent;
    fFullBlockEventsEnabled: Boolean;                   { Полные UI-снимки нужны только при записи }
    fRuntimeDataLock: TRTLCriticalSection;
    fRuntimeDataRevision: QWord;
    fInputDataRevision: QWord;
    fRuntimeLatestTime: Double;
    fExternalWriteBatchLock: TRTLCriticalSection;
    fCalibrationCaptureLock: TRTLCriticalSection;
    fCalibrationCaptureTag: TRecorderTag;
    fCalibrationCaptureValues: TRecorderDoubleArray;
    fCalibrationCaptureCount: Integer;
    fOnEnsureCalibrationData: TRecorderEnsureCalibrationDataEvent;
    fOnReleaseCalibrationData: TRecorderReleaseCalibrationDataEvent;
    fFallbackStartTickMs: QWord;
    fTimeSystem: TRecorderTimeSystem;
    fEventBus: TRecorderEventBus;                     { Ссылка на шину событий }
    fSelectedTagName: string;                         { Имя текущего выбранного тега }
    fTagGroupPaths: TStringList;                      { Пользовательские группы дерева тегов }
    fTags: TList;                                     { Список тегов (TRecorderTag) }
    fLoadedTagIdAliases: TStringList;
    fLoadedTagNameAliases: TStringList;
    fCalibrations: TRecorderCalibrationList;
    fSpectrumConfigs: TRecorderSpectrumConfigTree;
    fAlgorithmConfigs: TStringList;
    fFrequencyBands: TRecorderFrequencyBandList;
    { Opaque per-source extension objects. Core owns them but does not know
      which device or plugin supplied their concrete types. }
    fSourceSpecificConfigs: TStringList;
    fConfiguredDataSources: TObjectList;
    function GetActiveSourceCount: Integer;
    function GetActiveSourceId(AIndex: Integer): string;
    function GetSelectedTag: TRecorderTag;
    function GetTag(AIndex: Integer): TRecorderTag;
    function GetTagCount: Integer;
    procedure MarkRuntimeDataUpdated(ATimeSec: Double);
    procedure MarkInputDataUpdated;
    procedure PublishValueInternal(ATag: TRecorderTag; ATimeSec,
      AValue: Double; AIsInput: Boolean);
    procedure RemoveTagReferences(ATag: TRecorderTag);
    procedure RemoveLoadedTagAliases(ATag: TRecorderTag);
    function ResolvePublishTime(ATimeSec: Double): Double;
    function CalibrationCaptureActive(ATag: TRecorderTag): Boolean;
    procedure CaptureCalibrationValue(ATag: TRecorderTag; AValue: Double);
  public
    { AEventBus - шина событий. Владение не передается, может быть nil. }
    constructor Create(AEventBus: TRecorderEventBus = nil);
    { Деструктор очищает и удаляет все зарегистрированные теги }
    destructor Destroy; override;

    { Создает тег с автоматическим id и добавляет его в registry.
      AName     - уникальное имя тега.
      ACapacity - размер кольцевого буфера тега. }
    function CreateTag(const AName: string; ACapacity: Integer = 4096;
      AIsVirtual: Boolean = False): TRecorderTag;

    { Добавляет заранее созданный тег. Registry принимает владение. }
    function AddTag(ATag: TRecorderTag): TRecorderTag;

    { Ищет тег по id. Возвращает nil, если тег не найден. }
    function FindById(AId: TRecorderTagId): TRecorderTag;

    { Ищет тег по имени без учета регистра. Возвращает nil, если тег не найден. }
    function FindByName(const AName: string): TRecorderTag;
    { Resolves saved references to a duplicate omitted during project loading.
      Aliases are runtime-only and do not own the target tag. }
    procedure RegisterLoadedTagAlias(AOldId: TRecorderTagId;
      const AOldName: string; ATarget: TRecorderTag);
    function ContainsTag(ATag: TRecorderTag): Boolean;
    function RenameTag(ATag: TRecorderTag; const ANewName: string): Boolean;
    function FindCalibrationByName(const AName: string): TRecorderCalibration;
    function FindCalibrationBySdbKey(const AKey: string): TRecorderCalibration;
    function RemoveUnusedCalibrations: Integer;
    function CommitCalibrationEdit(ATarget, ADraft: TRecorderCalibration): Boolean;
    function AddCalibrationCopyForTag(ATag: TRecorderTag;
      APipelineIndex: Integer; ADraft: TRecorderCalibration): TRecorderCalibration;
    function FindTagHardwareCalibration(ATag: TRecorderTag): TRecorderCalibration;
    function TryGetTagAutoUnit(ATag: TRecorderTag;
      out AUnitName: string): Boolean;
    procedure SyncTagAutoUnit(ATag: TRecorderTag; AForce: Boolean = False);
    procedure RebuildScales(ATag: TRecorderTag);
    function FindTagThermocoupleCalibration(ATag: TRecorderTag): TRecorderCalibration;
    function TransformTagHardwareValue(ATag: TRecorderTag; AValue: Double): Double;
    function TransformTagThermocoupleValue(ATag: TRecorderTag; AValue: Double): Double;
    function InvertTagThermocoupleValue(ATag: TRecorderTag; ATemperatureC: Double;
      out AMillivolts: Double): Boolean;
    function TransformTagValue(ATag: TRecorderTag; AValue: Double): Double;
    { Начинает кратковременный захват после аппаратной ГХ и до канальной.
      Буфер выделяется здесь, до входа acquisition в горячий цикл. }
    procedure BeginCalibrationCapture(ATag: TRecorderTag;
      ADurationSec: Double = 1.0);
    { Запускает штатный источник данных через callback composition root. }
    function EnsureCalibrationData(ATag: TRecorderTag;
      out AStartedByCalibration: Boolean; out AError: string): Boolean;
    { Останавливает Preview, только если мастер сам запустил его для градуировки. }
    procedure ReleaseCalibrationData(ATag: TRecorderTag);
    { Возвращает число уже записанных отсчётов без копирования capture-буфера. }
    function CalibrationCaptureSampleCount(ATag: TRecorderTag): Integer;
    { Завершает захват и возвращает накопленные значения одним снимком. }
    function FinishCalibrationCapture(ATag: TRecorderTag;
      out ASnapshot: TRecorderSignalSnapshot): Boolean;
    procedure CancelCalibrationCapture(ATag: TRecorderTag);
    property OnEnsureCalibrationData: TRecorderEnsureCalibrationDataEvent
      read fOnEnsureCalibrationData write fOnEnsureCalibrationData;
    property OnReleaseCalibrationData: TRecorderReleaseCalibrationDataEvent
      read fOnReleaseCalibrationData write fOnReleaseCalibrationData;

    procedure RegisterActiveSource(const ASourceId: string);
    procedure UnregisterActiveSource(const ASourceId: string);
    procedure ClearActiveSources;
    procedure RefreshActiveSourcesFromTags;
    function IsSourceActive(const ASourceId: string): Boolean;

    { Публикует новое значение тега и отправляет событие rceDataUpdated. }
    procedure PublishValue(const ATagName: string; ATimeSec, AValue: Double); overload;
    procedure PublishValue(ATag: TRecorderTag; ATimeSec, AValue: Double); overload;
    procedure PublishValue(const ATagName: string; AValue: Double); overload;
    procedure PublishValue(ATag: TRecorderTag; AValue: Double); overload;
    { Публикует введённое пользователем значение и ставит его в очередь
      аппаратному источнику, если запись для тега разрешена. }
    procedure PublishExternalValue(const ATagName: string;
      AValue: Double); overload;
    procedure PublishExternalValue(ATag: TRecorderTag;
      AValue: Double); overload;
    procedure BeginExternalWriteBatch;
    procedure EndExternalWriteBatch;
    { Добавляет блок в кольцевой буфер тега без публикации события. }
    procedure AddBlockSamples(const ATagName: string; const ATimes,
      AValues: array of Double; ACount: Integer;
      AValuesAlreadyTransformed: Boolean = False);
    procedure AddBlockSamples(ATag: TRecorderTag; const ATimes,
      AValues: array of Double; ACount: Integer;
      AValuesAlreadyTransformed: Boolean = False); overload;
    { Публикует хвостовое UI-событие после AddBlockSamples. }
    procedure NotifyBlockTail(const ATagName: string; ATimeSec, AValue: Double);
    { Публикует блок значений тега и отправляет событие rceDataUpdated. }
    procedure PublishBlock(const ATagName: string; const ATimes,
      AValues: array of Double; ACount: Integer;
      AValuesAlreadyTransformed: Boolean = False);
    procedure PublishBlock(ATag: TRecorderTag; const ATimes,
      AValues: array of Double; ACount: Integer;
      AValuesAlreadyTransformed: Boolean = False); overload;
    { Возвращает сводное состояние данных без обхода и блокировки всех тегов. }
    procedure GetRuntimeDataState(out ARevision: QWord; out ALatestTime: Double);
    procedure GetInputDataRevision(out ARevision: QWord);
    { Явный получатель полного блока до публикации легковесного динамического
      UI/extension-события. Назначается менеджером алгоритмов. }
    procedure SetBlockPublishedHandler(ATarget: TObject;
      AHandler: TRecorderTagBlockPublishedEvent);
    { Независимый маршрут блоков в SQL. Ошибка или замена обработчика
      алгоритмов не должна отключать запись измерений в базу. }
    procedure SetSqlBlockPublishedHandler(ATarget: TObject;
      AHandler: TRecorderTagSqlBlockPublishedEvent);
    { Прямой обработчик скалярного обновления для менеджера алгоритмов. }
    procedure SetValuePublishedHandler(ATarget: TObject;
      AHandler: TRecorderTagValuePublishedEvent);
    { Явный штатный маршрут значения в модель тревог. }
    procedure SetAlarmValuePublishedHandler(ATarget: TObject;
      AHandler: TRecorderTagValuePublishedEvent);
    { Публикует спектр/UI-уведомления после AddBlockSamples. }
    procedure PublishBlockNotifications(const ATagName: string);
    procedure PublishBlockNotifications(ATag: TRecorderTag); overload;
    procedure PublishBlockNotifications(ATag: TRecorderTag; const ATimes,
      AValues: array of Double; ACount: Integer); overload;

    { Удаляет все теги и очищает счетчик id. }
    procedure Clear;
    procedure RemoveTag(ATag: TRecorderTag);
    procedure RemoveTagsBySourceId(const ASourceId: string);
    procedure DetachTagsBySourceId(const ASourceId: string);

    property ActiveSourceCount: Integer read GetActiveSourceCount;
    property ActiveSourceIds[AIndex: Integer]: string read GetActiveSourceId;
    property EventBus: TRecorderEventBus read fEventBus write fEventBus;
    property FullBlockEventsEnabled: Boolean read fFullBlockEventsEnabled
      write fFullBlockEventsEnabled;
    { Не владеющая ссылка на общую систему времени Recorder. }
    property TimeSystem: TRecorderTimeSystem read fTimeSystem write fTimeSystem;
    property SelectedTag: TRecorderTag read GetSelectedTag;
    property SelectedTagName: string read fSelectedTagName write fSelectedTagName;
    property TagGroupPaths: TStringList read fTagGroupPaths;
    property TagCount: Integer read GetTagCount;
    property StructureRevision: QWord read fStructureRevision;
    property Calibrations: TRecorderCalibrationList read fCalibrations;
    property SpectrumConfigs: TRecorderSpectrumConfigTree read fSpectrumConfigs;
    { Serialized configurations of non-spectrum runtime algorithms. Spectrum
      keeps its structured tree for backward compatibility. }
    property AlgorithmConfigs: TStringList read fAlgorithmConfigs;
    property FrequencyBands: TRecorderFrequencyBandList read fFrequencyBands;
    property SourceSpecificConfigs: TStringList read fSourceSpecificConfigs;
    property ConfiguredDataSources: TObjectList read fConfiguredDataSources;
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
procedure RecorderTagUpdateAutoEstimatePortion(ATag: TRecorderTag;
  AOldPollFrequencyHz: Double; AOldDataUpdateMs, ANewDataUpdateMs: Cardinal);

function RecorderTagsShareSourceId(ARegistry: TRecorderTagRegistry;
  const ATagNames: array of string): Boolean;
function RecorderTagsShareSourceIdList(ARegistry: TRecorderTagRegistry;
  ATagNames: TStrings): Boolean;
{ Строковое имя является постоянной ссылкой. Id используется только для
  совместимости со старыми конфигурациями без имени. }
function RecorderResolveTagReference(ARegistry:TRecorderTagRegistry;
  ATagId:TRecorderTagId; const ATagName:string):TRecorderTag;
{ Reads a tag through the scalar-visualization contract. Scalar tags keep
  their latest-value behaviour; vector tags are reduced with an estimate. }
function RecorderTryReadScalarValue(ATag:TRecorderTag;
  AUseDefaultEstimate:Boolean; AEstimateKind:TRecorderTagEstimateKind;
  out AValue:Double):Boolean;

{ Состояние отдельной ступени pipeline хранится вместе с её именем.
  Старые списки без маркера считаются полностью включёнными. }
function RecorderCalibrationStepEnabled(ANames: TStrings;
  AIndex: Integer): Boolean;
procedure RecorderSetCalibrationStepEnabled(ANames: TStrings;
  AIndex: Integer; AEnabled: Boolean);

const
  CDetachedTagSourcePrefix = 'Detached:';
  CMeraTagSourcePrefix = 'Mera file: ';

function RecorderNormalizeTagSourceId(const ASourceId: string): string;
function RecorderIsDetachedTagSource(const ASourceId: string): Boolean;
function RecorderIsVirtualTagSource(const ASourceId: string): Boolean;
function RecorderIsHardwareTagSource(const ASourceId: string): Boolean;
function RecorderHardwareTreeShowsSourceId(const ASourceId: string): Boolean;
// требуется ли отображать тег в таблицах
function RecorderTagSourceIsVisible(ARegistry: TRecorderTagRegistry; ATag: TRecorderTag): Boolean;

implementation

uses
  StrUtils, uRecorderDebugLog;

const
  CTagThermocoupleInverseMinMv = -20.0;
  CTagThermocoupleInverseMaxMv = 100.0;
  CTagThermocoupleInverseIterations = 48;
  CTagAddTraceEnabled = True;
  CCalibrationStepDisabled = PtrInt(1);

function RecorderCalibrationStepEnabled(ANames: TStrings;
  AIndex: Integer): Boolean;
begin
  Result := (ANames <> nil) and (AIndex >= 0) and (AIndex < ANames.Count) and
    (PtrInt(ANames.Objects[AIndex]) <> CCalibrationStepDisabled);
end;

procedure RecorderSetCalibrationStepEnabled(ANames: TStrings;
  AIndex: Integer; AEnabled: Boolean);
begin
  if (ANames = nil) or (AIndex < 0) or (AIndex >= ANames.Count) then
    Exit;
  if AEnabled then
    ANames.Objects[AIndex] := nil
  else
    ANames.Objects[AIndex] := TObject(CCalibrationStepDisabled);
end;

procedure RecorderLogTagAddTrace(const AAction: string; ATag: TRecorderTag);
begin
  if (not CTagAddTraceEnabled) or (ATag = nil) then
    Exit;
  RecorderDebugLog(Format(
    '[Tags.AddTag] %s: id=%d name="%s" source="%s" address="%s" module="%s"',
    [AAction, ATag.Id, ATag.Name, ATag.SourceId, ATag.Address,
    ATag.ModuleType]));
end;

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
    Result := Ceil(APollFrequencyHz * ADataUpdateMs / 1000.0);
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

procedure RecorderTagUpdateAutoEstimatePortion(ATag: TRecorderTag;
  AOldPollFrequencyHz: Double; AOldDataUpdateMs, ANewDataUpdateMs: Cardinal);
var
  lSettings: TRecorderTagEstimateSettings;
begin
  if (ATag = nil) or not RecorderTagEstimatePortionLengthIsAuto(
    ATag.EstimateSettings.PortionLength, AOldPollFrequencyHz,
    AOldDataUpdateMs) then
    Exit;
  lSettings := ATag.EstimateSettings;
  lSettings.PortionLength := RecorderTagDefaultEstimatePortionLength(
    ATag.PollFrequencyHz, ANewDataUpdateMs);
  ATag.EstimateSettings := lSettings;
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
  fBlockSampleCapacity := 1;
  InitCriticalSection(fLock);
end;

destructor TRecorderSignalBuffer.Destroy;
begin
  DoneCriticalSection(fLock);
  inherited Destroy;
end;

function TRecorderSignalBuffer.GetCount: Integer;
begin
  EnterCriticalSection(fLock);
  try
    Result := fCount;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderSignalBuffer.GetRevision: QWord;
begin
  EnterCriticalSection(fLock);
  try
    Result := fRevision;
  finally
    LeaveCriticalSection(fLock);
  end;
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
    fPendingBlockCount := 0;
    fBlockBaseSample := fTotalSamples;
    fBlockBaseSequence := fTotalBlocks;
    Inc(fRevision);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalBuffer.AddSample(ATimeSec, AValue: Double);
var
  lIndex: Integer;
  lLastIndex: Integer;
begin
  EnterCriticalSection(fLock);
  try
    { Источник может начать новую временную эпоху после Stop/Start. Нельзя
      смешивать новые отсчёты от нуля со старой историей: Snapshot обязан
      оставаться отсортированным по времени для бинарного поиска в графиках. }
    if fCount > 0 then
    begin
      lLastIndex := (fStart + fCount - 1) mod fCapacity;
      if ATimeSec < fTimes[lLastIndex] then
      begin
        fStart := 0;
        fCount := 0;
        fLastBlockCount := 0;
        fPendingBlockCount := 0;
        fBlockBaseSample := fTotalSamples;
        fBlockBaseSequence := fTotalBlocks;
      end;
    end;
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
    if Length(fLastBlockTimes) < 1 then
      SetLength(fLastBlockTimes, 1);
    if Length(fLastBlockValues) < 1 then
      SetLength(fLastBlockValues, 1);
    fLastBlockTimes[0] := ATimeSec;
    fLastBlockValues[0] := AValue;
    AccumulateLogicalBlocks(fTotalSamples, 1);
    Inc(fTotalSamples);
    Inc(fRevision);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalBuffer.AddSamples(const ATimes, AValues: array of Double;
  ACount: Integer);
var
  lAppendIndex: Integer;
  lCopyCount: Integer;
  lFirstCount: Integer;
  lLastIndex: Integer;
  lOverflow: Integer;
  lSourceIndex: Integer;
begin
  if ACount < 0 then
    raise ERecorderTagError.Create('Sample block count cannot be negative');
  if (ACount > Length(ATimes)) or (ACount > Length(AValues)) then
    raise ERecorderTagError.Create('Sample block count exceeds data length');

  EnterCriticalSection(fLock);
  try
    { Очистка и добавление первого блока новой временной эпохи выполняются под
      одной блокировкой. UI поэтому не увидит промежуточный пустой буфер. }
    if (ACount > 0) and (fCount > 0) then
    begin
      lLastIndex := (fStart + fCount - 1) mod fCapacity;
      if ATimes[0] < fTimes[lLastIndex] then
      begin
        fStart := 0;
        fCount := 0;
        fLastBlockCount := 0;
        fPendingBlockCount := 0;
        fBlockBaseSample := fTotalSamples;
        fBlockBaseSequence := fTotalBlocks;
      end;
    end;
    fLastBlockCount := ACount;
    if Length(fLastBlockTimes) < ACount then
      SetLength(fLastBlockTimes, ACount);
    if Length(fLastBlockValues) < ACount then
      SetLength(fLastBlockValues, ACount);
    if ACount > 0 then
    begin
      Move(ATimes[0], fLastBlockTimes[0], ACount * SizeOf(Double));
      Move(AValues[0], fLastBlockValues[0], ACount * SizeOf(Double));
    end;

    { Кольцо измеряется отсчётами, а не транспортными пакетами. Поэтому несколько
      мелких пакетов MIC-140 за один период сохраняют то же окно, что один крупный блок. }
    lCopyCount := Min(ACount, fCapacity);
    if lCopyCount > 0 then
    begin
      lSourceIndex := ACount - lCopyCount;
      if ACount >= fCapacity then
      begin
        Move(ATimes[lSourceIndex], fTimes[0], lCopyCount * SizeOf(Double));
        Move(AValues[lSourceIndex], fValues[0], lCopyCount * SizeOf(Double));
        fStart := 0;
        fCount := lCopyCount;
      end
      else
      begin
        lAppendIndex := (fStart + fCount) mod fCapacity;
        lFirstCount := Min(lCopyCount, fCapacity - lAppendIndex);
        Move(ATimes[0], fTimes[lAppendIndex], lFirstCount * SizeOf(Double));
        Move(AValues[0], fValues[lAppendIndex], lFirstCount * SizeOf(Double));
        if lFirstCount < lCopyCount then
        begin
          Move(ATimes[lFirstCount], fTimes[0],
            (lCopyCount - lFirstCount) * SizeOf(Double));
          Move(AValues[lFirstCount], fValues[0],
            (lCopyCount - lFirstCount) * SizeOf(Double));
        end;
        lOverflow := Max(0, fCount + lCopyCount - fCapacity);
        if lOverflow > 0 then
          fStart := (fStart + lOverflow) mod fCapacity;
        fCount := Min(fCapacity, fCount + lCopyCount);
      end;
    end;
    if ACount > 0 then
    begin
      AccumulateLogicalBlocks(fTotalSamples, ACount);
      Inc(fTotalSamples, ACount);
    end;
    Inc(fRevision);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalBuffer.AccumulateLogicalBlocks(AStartSample: QWord;
  ACount: Integer);
var
  lOffset: Integer;
  lTake: Integer;
begin
  if (ACount <= 0) or (fBlockSampleCapacity <= 0) then
    Exit;
  lOffset := 0;
  while lOffset < ACount do
  begin
    if fPendingBlockCount = 0 then
      fPendingBlockStart := AStartSample + QWord(lOffset);
    lTake := Min(fBlockSampleCapacity - fPendingBlockCount, ACount - lOffset);
    Inc(fPendingBlockCount, lTake);
    Inc(lOffset, lTake);
    if fPendingBlockCount = fBlockSampleCapacity then
    begin
      Inc(fTotalBlocks);
      fPendingBlockCount := 0;
    end;
  end;
end;

procedure TRecorderSignalBuffer.ConfigureBlockRing(ABlockSamples,
  ABlockCount: Integer);
begin
  if (ABlockSamples < 1) or (ABlockCount < 1) then
    Exit;
  { Совместимый вызов конфигурации. История хранится единым кольцом отсчётов:
    границы сетевых пакетов не должны сокращать отображаемое временное окно. }
  EnterCriticalSection(fLock);
  try
    if Length(fLastBlockTimes) < ABlockSamples then
      SetLength(fLastBlockTimes, ABlockSamples);
    if Length(fLastBlockValues) < ABlockSamples then
      SetLength(fLastBlockValues, ABlockSamples);
    fBlockSampleCapacity := ABlockSamples;
    fPendingBlockCount := 0;
    fPendingBlockStart := fTotalSamples;
    fBlockBaseSample := fTotalSamples;
    fBlockBaseSequence := fTotalBlocks;
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
    fPendingBlockCount := 0;
    fBlockBaseSample := fTotalSamples;
    fBlockBaseSequence := fTotalBlocks;
    Inc(fRevision);
  finally
    LeaveCriticalSection(fLock);
  end;
end;
function TRecorderSignalBuffer.Snapshot: TRecorderSignalSnapshot;
var
  lFirstCount: Integer;
begin
  EnterCriticalSection(fLock);
  try
    Result.Count := fCount;
    SetLength(Result.Times, fCount);
    SetLength(Result.Values, fCount);
    if fCount > 0 then
    begin
      lFirstCount := Min(fCount, fCapacity - fStart);
      Move(fTimes[fStart], Result.Times[0], lFirstCount * SizeOf(Double));
      Move(fValues[fStart], Result.Values[0], lFirstCount * SizeOf(Double));
      if lFirstCount < fCount then
      begin
        Move(fTimes[0], Result.Times[lFirstCount],
          (fCount - lFirstCount) * SizeOf(Double));
        Move(fValues[0], Result.Values[lFirstCount],
          (fCount - lFirstCount) * SizeOf(Double));
      end;
    end;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalBuffer.CopyRangeLocked(AFromTimeSec: Double;
  AIncludePrevious: Boolean; var ATimes, AValues: TRecorderDoubleArray;
  out ACount: Integer);
var
  lFirstCount: Integer;
  lHigh: Integer;
  lLow: Integer;
  lMiddle: Integer;
  lReadIndex: Integer;
  lRequired: Integer;
begin
  ACount := 0;
  if fCount = 0 then
    Exit;
  lLow := 0;
  lHigh := fCount;
  while lLow < lHigh do
  begin
    lMiddle := lLow + (lHigh - lLow) div 2;
    if fTimes[(fStart + lMiddle) mod fCapacity] < AFromTimeSec then
      lLow := lMiddle + 1
    else
      lHigh := lMiddle;
  end;
  if AIncludePrevious and (lLow > 0) then
    Dec(lLow);
  lRequired := fCount - lLow;
  if lRequired <= 0 then
    Exit;
  if Length(ATimes) < lRequired then
    SetLength(ATimes, lRequired);
  if Length(AValues) < lRequired then
    SetLength(AValues, lRequired);
  lReadIndex := (fStart + lLow) mod fCapacity;
  lFirstCount := Min(lRequired, fCapacity - lReadIndex);
  Move(fTimes[lReadIndex], ATimes[0], lFirstCount * SizeOf(Double));
  Move(fValues[lReadIndex], AValues[0], lFirstCount * SizeOf(Double));
  if lFirstCount < lRequired then
  begin
    Move(fTimes[0], ATimes[lFirstCount],
      (lRequired - lFirstCount) * SizeOf(Double));
    Move(fValues[0], AValues[lFirstCount],
      (lRequired - lFirstCount) * SizeOf(Double));
  end;
  ACount := lRequired;
end;

procedure TRecorderSignalBuffer.SnapshotRangeInto(AFromTimeSec: Double;
  AIncludePrevious: Boolean; var ATimes, AValues: TRecorderDoubleArray;
  out ACount: Integer);
begin
  EnterCriticalSection(fLock);
  try
    CopyRangeLocked(AFromTimeSec, AIncludePrevious, ATimes, AValues, ACount);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

procedure TRecorderSignalBuffer.CopyLatestInto(AWindowSeconds: Double;
  var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer;
  out ADisplayStart: Double);
var
  lLatestTime: Double;
begin
  ACount := 0;
  ADisplayStart := 0;
  EnterCriticalSection(fLock);
  try
    if fCount = 0 then
      Exit;
    lLatestTime := fTimes[(fStart + fCount - 1) mod fCapacity];
    ADisplayStart := lLatestTime - Max(0, AWindowSeconds);
    CopyRangeLocked(ADisplayStart, False, ATimes, AValues, ACount);
    if ACount > 0 then
      ADisplayStart := Max(ADisplayStart, ATimes[0]);
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderSignalBuffer.SnapshotSince(
  var ACursor: QWord): TRecorderSignalSnapshot;
begin
  SnapshotSinceInto(ACursor, Result.Times, Result.Values, Result.Count);
end;

procedure TRecorderSignalBuffer.SnapshotSinceInto(var ACursor: QWord;
  var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer);
var
  lAvailableStart: QWord;
  lFirstCount: Integer;
  lOffset: Integer;
  lReadIndex: Integer;
begin
  EnterCriticalSection(fLock);
  try
    lAvailableStart := fTotalSamples - QWord(fCount);
    if (ACursor < lAvailableStart) or (ACursor > fTotalSamples) then
      ACursor := lAvailableStart;
    ACount := Integer(fTotalSamples - ACursor);
    if Length(ATimes) < ACount then
      SetLength(ATimes, ACount);
    if Length(AValues) < ACount then
      SetLength(AValues, ACount);
    if ACount > 0 then
    begin
      lOffset := Integer(ACursor - lAvailableStart);
      lReadIndex := (fStart + lOffset) mod fCapacity;
      lFirstCount := Min(ACount, fCapacity - lReadIndex);
      Move(fTimes[lReadIndex], ATimes[0], lFirstCount * SizeOf(Double));
      Move(fValues[lReadIndex], AValues[0], lFirstCount * SizeOf(Double));
      if lFirstCount < ACount then
      begin
        Move(fTimes[0], ATimes[lFirstCount],
          (ACount - lFirstCount) * SizeOf(Double));
        Move(fValues[0], AValues[lFirstCount],
          (ACount - lFirstCount) * SizeOf(Double));
      end;
    end;
    ACursor := fTotalSamples;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderSignalBuffer.CurrentCursor: QWord;
begin
  EnterCriticalSection(fLock);
  try
    Result := fTotalSamples;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderSignalBuffer.SnapshotNextBlock(var ABlockCursor: QWord;
  out ASnapshot: TRecorderSignalSnapshot): Boolean;
begin
  ASnapshot.Count := 0;
  SetLength(ASnapshot.Times, 0);
  SetLength(ASnapshot.Values, 0);
  Result := SnapshotNextBlockInto(ABlockCursor, ASnapshot.Times,
    ASnapshot.Values, ASnapshot.Count);
end;

function TRecorderSignalBuffer.SnapshotNextBlockInto(var ABlockCursor: QWord;
  var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer): Boolean;
var
  lAvailableStart: QWord;
  lBlockStart: QWord;
  lFirstCount: Integer;
  lOldestSequence: QWord;
  lReadIndex: Integer;
begin
  Result := False;
  ACount := 0;
  EnterCriticalSection(fLock);
  try
    if (fBlockSampleCapacity <= 0) or
      (fTotalBlocks <= fBlockBaseSequence) then
    begin
      ABlockCursor := fTotalBlocks;
      Exit;
    end;
    lAvailableStart := fTotalSamples - QWord(fCount);
    lOldestSequence := fBlockBaseSequence;
    if lAvailableStart > fBlockBaseSample then
      Inc(lOldestSequence, (lAvailableStart - fBlockBaseSample +
        QWord(fBlockSampleCapacity) - 1) div QWord(fBlockSampleCapacity));
    if (ABlockCursor < lOldestSequence) or (ABlockCursor > fTotalBlocks) then
      ABlockCursor := lOldestSequence;
    if ABlockCursor >= fTotalBlocks then
      Exit;

    lBlockStart := fBlockBaseSample +
      (ABlockCursor - fBlockBaseSequence) * QWord(fBlockSampleCapacity);
    ACount := fBlockSampleCapacity;
    if Length(ATimes) < ACount then
      SetLength(ATimes, ACount);
    if Length(AValues) < ACount then
      SetLength(AValues, ACount);
    lReadIndex := (fStart + Integer(lBlockStart - lAvailableStart)) mod fCapacity;
    lFirstCount := Min(ACount, fCapacity - lReadIndex);
    Move(fTimes[lReadIndex], ATimes[0], lFirstCount * SizeOf(Double));
    Move(fValues[lReadIndex], AValues[0], lFirstCount * SizeOf(Double));
    if lFirstCount < ACount then
    begin
      Move(fTimes[0], ATimes[lFirstCount],
        (ACount - lFirstCount) * SizeOf(Double));
      Move(fValues[0], AValues[lFirstCount],
        (ACount - lFirstCount) * SizeOf(Double));
    end;
    Inc(ABlockCursor);
    Result := True;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderSignalBuffer.CurrentBlockSampleCapacity: Integer;
begin
  EnterCriticalSection(fLock);
  try
    Result := fBlockSampleCapacity;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderSignalBuffer.CurrentBlockCursor: QWord;
begin
  EnterCriticalSection(fLock);
  try
    Result := fTotalBlocks;
  finally
    LeaveCriticalSection(fLock);
  end;
end;

function TRecorderSignalBuffer.LastBlockSnapshot: TRecorderSignalSnapshot;
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
  ACapacity: Integer; AIsVirtual: Boolean);
var
  lKind: TRecorderTagEstimateKind;
begin
  inherited Create;
  if AName = '' then
    raise ERecorderTagError.Create('Tag name cannot be empty');

  fId := AId;
  fName := AName;
  fIsVirtual := AIsVirtual;
  fExternalWriteAllowed := AIsVirtual;
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
  fSetpointRangeControlEnabled := True;
  { Применение ГХ по умолчанию выключено. Включать его вправе только
    пользователь либо загрузчик сохранённой конфигурации. }
  fChannelCalibrationEnabled := False;
  fCalibrationScaleBuilt := False;
  fCalibrationScaleLinear := False;
  fHardwareScale := 1.0;
  fResultScale := 1.0;
  fCalibrationNames := TStringList.Create;
  fCalibrationNames.CaseSensitive := False;
  fSignalBuffer := TRecorderSignalBuffer.Create(ACapacity);
  InitCriticalSection(fEstimateLock);
  InitCriticalSection(fExternalWriteLock);
  ClearEstimateCache;
end;

destructor TRecorderTag.Destroy;
begin
  DoneCriticalSection(fExternalWriteLock);
  DoneCriticalSection(fEstimateLock);
  fSignalBuffer.Free;
  fCalibrationNames.Free;
  inherited Destroy;
end;

procedure TRecorderTag.AddSample(ATimeSec, AValue: Double);
var
  lTimes: array[0..0] of Double;
  lValues: array[0..0] of Double;
begin
  fSignalBuffer.AddSample(ATimeSec, AValue);
  lTimes[0] := ATimeSec;
  lValues[0] := AValue;
  UpdateEstimateCache(lTimes, lValues, 1);
  fTextValue := FloatToStr(AValue);
end;

procedure TRecorderTag.AddSamples(const ATimes, AValues: array of Double;
  ACount: Integer);
begin
  fSignalBuffer.AddSamples(ATimes, AValues, ACount);
  if ACount > 0 then
  begin
    UpdateEstimateCache(ATimes, AValues, ACount);
    fTextValue := FloatToStr(AValues[ACount - 1]);
  end;
end;

procedure TRecorderTag.EnsureBufferCapacity(ACapacity: Integer);
begin
  if ACapacity > fSignalBuffer.Capacity then
    fSignalBuffer.SetCapacity(ACapacity);
end;

procedure TRecorderTag.ConfigureBlockBuffer(ABlockSamples, ABlockCount: Integer);
begin
  fSignalBuffer.ConfigureBlockRing(ABlockSamples, ABlockCount);
end;

procedure TRecorderTag.ClearSignalHistory;
begin
  fSignalBuffer.Clear;
  ClearEstimateCache;
  fTextValue := '';
end;

function TRecorderTag.Snapshot: TRecorderSignalSnapshot;
begin
  Result := fSignalBuffer.Snapshot;
end;

procedure TRecorderTag.SnapshotRangeInto(AFromTimeSec: Double;
  AIncludePrevious: Boolean; var ATimes, AValues: TRecorderDoubleArray;
  out ACount: Integer);
begin
  fSignalBuffer.SnapshotRangeInto(AFromTimeSec, AIncludePrevious, ATimes,
    AValues, ACount);
end;

procedure TRecorderTag.CopyLatestInto(AWindowSeconds: Double;
  var ATimes, AValues: TRecorderDoubleArray; out ACount: Integer;
  out ADisplayStart: Double);
begin
  fSignalBuffer.CopyLatestInto(AWindowSeconds, ATimes, AValues, ACount,
    ADisplayStart);
end;

function TRecorderTag.LastBlockSnapshot: TRecorderSignalSnapshot;
begin
  Result := fSignalBuffer.LastBlockSnapshot;
end;

function TRecorderTag.GetIsVector: Boolean;
begin
  Result := fPollFrequencyHz > 0;
end;

function TRecorderTag.GetBlockCounter: QWord;
begin
  Result := fSignalBuffer.CurrentBlockCursor;
end;

function TRecorderTag.Estimate(
  AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;
begin
  EnterCriticalSection(fEstimateLock);
  try
    Result := fEstimateCache[AKind];
  finally
    LeaveCriticalSection(fEstimateLock);
  end;
end;

procedure TRecorderTag.ClearEstimateCache;
var
  lKind: TRecorderTagEstimateKind;
begin
  EnterCriticalSection(fEstimateLock);
  try
    for lKind := Low(TRecorderTagEstimateKind) to
      High(TRecorderTagEstimateKind) do
    begin
      FillChar(fEstimateCache[lKind], SizeOf(TRecorderTagEstimate), 0);
      fEstimateCache[lKind].Kind := lKind;
    end;
    fEstimatePortionCount := 0;
    fEstimatePortionStartTime := 0.0;
    fEstimatePortionEndTime := 0.0;
    fEstimatePortionLastValue := 0.0;
    fEstimatePortionMin := 0.0;
    fEstimatePortionMax := 0.0;
    fEstimatePortionSum := 0.0;
    fEstimatePortionSquareSum := 0.0;
  finally
    LeaveCriticalSection(fEstimateLock);
  end;
end;

procedure TRecorderTag.UpdateEstimateCache(const ATimes,
  AValues: array of Double; ACount: Integer);
var
  I: Integer;
  lKind: TRecorderTagEstimateKind;
  lMean: Extended;
  lPortionLength: Integer;
  lVariance: Extended;
begin
  if (ACount <= 0) or (ACount > Length(ATimes)) or
    (ACount > Length(AValues)) then
    Exit;

  EnterCriticalSection(fEstimateLock);
  try
    lPortionLength := fEstimateSettings.PortionLength;
    if lPortionLength < 1 then
      lPortionLength := 1;
    for I := 0 to ACount - 1 do
    begin
      if fEstimatePortionCount = 0 then
      begin
        fEstimatePortionStartTime := ATimes[I];
        fEstimatePortionMin := AValues[I];
        fEstimatePortionMax := AValues[I];
        fEstimatePortionSum := 0.0;
        fEstimatePortionSquareSum := 0.0;
      end;
      Inc(fEstimatePortionCount);
      fEstimatePortionEndTime := ATimes[I];
      fEstimatePortionLastValue := AValues[I];
      fEstimatePortionSum := fEstimatePortionSum + AValues[I];
      fEstimatePortionSquareSum := fEstimatePortionSquareSum +
        AValues[I] * AValues[I];
      if AValues[I] < fEstimatePortionMin then
        fEstimatePortionMin := AValues[I];
      if AValues[I] > fEstimatePortionMax then
        fEstimatePortionMax := AValues[I];
      if fEstimatePortionCount < lPortionLength then
        Continue;

      lMean := fEstimatePortionSum / fEstimatePortionCount;
      if fEstimatePortionCount > 1 then
      begin
        lVariance := (fEstimatePortionSquareSum - fEstimatePortionSum *
          fEstimatePortionSum / fEstimatePortionCount) /
          (fEstimatePortionCount - 1);
        if lVariance < 0 then
          lVariance := 0;
      end
      else
        lVariance := 0;
      for lKind := Low(TRecorderTagEstimateKind) to
        High(TRecorderTagEstimateKind) do
      begin
        fEstimateCache[lKind].Kind := lKind;
        fEstimateCache[lKind].Count := fEstimatePortionCount;
        fEstimateCache[lKind].Valid := True;
        fEstimateCache[lKind].StartTimeSec := fEstimatePortionStartTime;
        fEstimateCache[lKind].EndTimeSec := fEstimatePortionEndTime;
        case lKind of
          tekMean: fEstimateCache[lKind].Value := lMean;
          tekRmsValue: fEstimateCache[lKind].Value :=
            Sqrt(fEstimatePortionSquareSum / fEstimatePortionCount);
          tekRmsDeviation: fEstimateCache[lKind].Value := Sqrt(lVariance);
          tekPeak: fEstimateCache[lKind].Value :=
            (fEstimatePortionMax - fEstimatePortionMin) / 2.0;
          tekPeakToPeak: fEstimateCache[lKind].Value :=
            fEstimatePortionMax - fEstimatePortionMin;
          tekMinimum: fEstimateCache[lKind].Value := fEstimatePortionMin;
          tekMaximum: fEstimateCache[lKind].Value := fEstimatePortionMax;
          tekPeakToPeakByRmsDeviation: fEstimateCache[lKind].Value :=
            2.0 * Sqrt(2.0) * Sqrt(lVariance);
          tekLastValue: fEstimateCache[lKind].Value :=
            fEstimatePortionLastValue;
        end;
      end;
      fEstimatePortionCount := 0;
    end;
  finally
    LeaveCriticalSection(fEstimateLock);
  end;
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
  InitCriticalSection(fRuntimeDataLock);
  InitCriticalSection(fExternalWriteBatchLock);
  InitCriticalSection(fCalibrationCaptureLock);
  fEventBus := AEventBus;
  fActiveSourceIds := TStringList.Create;
  fActiveSourceIds.CaseSensitive := False;
  fActiveSourceIds.Sorted := False;
  fTagGroupPaths := TStringList.Create;
  fTagGroupPaths.CaseSensitive := False;
  fTagGroupPaths.Sorted := True;
  fTagGroupPaths.Duplicates := dupIgnore;
  fTags := TList.Create;
  fLoadedTagIdAliases := TStringList.Create;
  fLoadedTagNameAliases := TStringList.Create;
  fLoadedTagNameAliases.CaseSensitive := False;
  fCalibrations := TRecorderCalibrationList.Create;
  fSpectrumConfigs := TRecorderSpectrumConfigTree.Create;
  fAlgorithmConfigs := TStringList.Create;
  fFrequencyBands := TRecorderFrequencyBandList.Create;
  fSourceSpecificConfigs := TStringList.Create;
  fSourceSpecificConfigs.OwnsObjects := True;
  fSourceSpecificConfigs.CaseSensitive := False;
  fConfiguredDataSources := TObjectList.Create(True);
  fFallbackStartTickMs := GetTickCount64;
end;

destructor TRecorderTagRegistry.Destroy;
begin
  Clear;
  fConfiguredDataSources.Free;
  fSourceSpecificConfigs.Free;
  fFrequencyBands.Free;
  fAlgorithmConfigs.Free;
  fSpectrumConfigs.Free;
  fCalibrations.Free;
  fTagGroupPaths.Free;
  fActiveSourceIds.Free;
  fTags.Free;
  fLoadedTagNameAliases.Free;
  fLoadedTagIdAliases.Free;
  SetLength(fCalibrationCaptureValues, 0);
  DoneCriticalSection(fCalibrationCaptureLock);
  DoneCriticalSection(fExternalWriteBatchLock);
  DoneCriticalSection(fRuntimeDataLock);
  inherited Destroy;
end;

procedure TRecorderTagRegistry.MarkRuntimeDataUpdated(ATimeSec: Double);
begin
  EnterCriticalSection(fRuntimeDataLock);
  try
    Inc(fRuntimeDataRevision);
    if ATimeSec > fRuntimeLatestTime then
      fRuntimeLatestTime := ATimeSec;
  finally
    LeaveCriticalSection(fRuntimeDataLock);
  end;
end;

procedure TRecorderTagRegistry.GetRuntimeDataState(out ARevision: QWord;
  out ALatestTime: Double);
begin
  EnterCriticalSection(fRuntimeDataLock);
  try
    ARevision := fRuntimeDataRevision;
    ALatestTime := fRuntimeLatestTime;
  finally
    LeaveCriticalSection(fRuntimeDataLock);
  end;
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
  ACapacity: Integer; AIsVirtual: Boolean): TRecorderTag;
var
  lGuid: TGUID;
  lId: QWord;
  I: Integer;
begin
  repeat
    if CreateGUID(lGuid) <> 0 then
      raise ERecorderTagError.Create('Cannot generate tag id');
    lId := 0;
    for I := 0 to High(lGuid.Data4) do
      lId := (lId shl 8) or lGuid.Data4[I];
    lId := lId and QWord(High(TRecorderTagId));
  until (lId <> 0) and (FindById(TRecorderTagId(lId)) = nil);
  Result := TRecorderTag.Create(TRecorderTagId(lId), AName,
    ACapacity, AIsVirtual);
  try
    AddTag(Result);
  except
    Result.Free;
    raise;
  end;
end;

function TRecorderTagRegistry.AddTag(ATag: TRecorderTag): TRecorderTag;
var
  lExisting: TRecorderTag;
begin
  if ATag = nil then
    raise ERecorderTagError.Create('Tag cannot be nil');
  RecorderLogTagAddTrace('request', ATag);
  if FindById(ATag.Id) <> nil then
    raise ERecorderTagError.CreateFmt('Tag id already exists: %d', [ATag.Id]);
  lExisting := FindByName(ATag.Name);
  if lExisting <> nil then
  begin
    if RecorderIsDetachedTagSource(lExisting.SourceId) then
    begin
      RecorderLogTagAddTrace('remove-detached-existing', lExisting);
      RemoveTag(lExisting)
    end
    else
    begin
      RecorderLogTagAddTrace('duplicate-existing', lExisting);
      RecorderDebugLog(Format(
        '[Tags] Duplicate tag name "%s": existing id=%d source="%s" address="%s" module="%s"; new id=%d source="%s" address="%s" module="%s"',
        [ATag.Name, lExisting.Id, lExisting.SourceId, lExisting.Address,
        lExisting.ModuleType, ATag.Id, ATag.SourceId, ATag.Address,
        ATag.ModuleType]));
      raise ERecorderTagError.CreateFmt(
        'Tag name already exists: %s. Existing id=%d source="%s" address="%s" module="%s"; new id=%d source="%s" address="%s" module="%s"',
        [ATag.Name, lExisting.Id, lExisting.SourceId, lExisting.Address,
        lExisting.ModuleType, ATag.Id, ATag.SourceId, ATag.Address,
        ATag.ModuleType]);
    end;
  end;

  fTags.Add(ATag);
  Inc(fStructureRevision);
  RecorderLogTagAddTrace('added', ATag);
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
  I := fLoadedTagIdAliases.IndexOf(IntToStr(AId));
  if I >= 0 then
    Result := TRecorderTag(fLoadedTagIdAliases.Objects[I]);
end;

procedure TRecorderTag.QueueExternalWrite(AValue: Double);
begin
  EnterCriticalSection(fExternalWriteLock);
  try
    fExternalWriteValues[fExternalWriteRevision mod
      QWord(Length(fExternalWriteValues))] := AValue;
    Inc(fExternalWriteRevision);
  finally
    LeaveCriticalSection(fExternalWriteLock);
  end;
end;

procedure TRecorderTagRegistry.GetInputDataRevision(out ARevision: QWord);
begin
  EnterCriticalSection(fRuntimeDataLock);
  try
    ARevision := fInputDataRevision;
  finally
    LeaveCriticalSection(fRuntimeDataLock);
  end;
end;

procedure TRecorderTagRegistry.MarkInputDataUpdated;
begin
  EnterCriticalSection(fRuntimeDataLock);
  try
    Inc(fInputDataRevision);
  finally
    LeaveCriticalSection(fRuntimeDataLock);
  end;
end;

function TRecorderTag.ReadExternalWrite(var ARevision: QWord;
  out AValue: Double): Boolean;
begin
  EnterCriticalSection(fExternalWriteLock);
  try
    if ARevision > fExternalWriteRevision then
      ARevision := fExternalWriteRevision
    else if fExternalWriteRevision - ARevision >
      QWord(Length(fExternalWriteValues)) then
      ARevision := fExternalWriteRevision - QWord(Length(fExternalWriteValues));
    Result := ARevision < fExternalWriteRevision;
    if Result then
    begin
      AValue := fExternalWriteValues[ARevision mod
        QWord(Length(fExternalWriteValues))];
      Inc(ARevision);
    end;
  finally
    LeaveCriticalSection(fExternalWriteLock);
  end;
end;

function TRecorderTag.ExternalWriteCursor: QWord;
begin
  EnterCriticalSection(fExternalWriteLock);
  try
    Result := fExternalWriteRevision;
  finally
    LeaveCriticalSection(fExternalWriteLock);
  end;
end;

procedure TRecorderTag.InvalidateCalibrationScale;
begin
  fCalibrationScaleBuilt := False;
end;

procedure TRecorderTag.SetUnitName(const AValue: string);
begin
  fUnitName := Trim(AValue);
  { При активной ГХ UnitName является единицей результата, а исходная единица
    остаётся самостоятельной. Иначе ручной выбор V/mV затирал бы "код" и
    аппаратный масштаб начинал собираться от неверного входа. }
  if not ((fHardwareCalibrationEnabled and
    (Trim(fHardwareCalibrationName) <> '')) or
    (fChannelCalibrationEnabled and (fCalibrationNames <> nil) and
    (fCalibrationNames.Count > 0))) then
    fSourceUnitName := fUnitName;
  InvalidateCalibrationScale;
end;

procedure TRecorderTag.SetSourceUnitName(const AValue: string);
begin
  fSourceUnitName := Trim(AValue);
  InvalidateCalibrationScale;
end;

procedure TRecorderTag.SetAutoUnit(AValue: Boolean);
begin
  if fAutoUnit = AValue then
    Exit;
  fAutoUnit := AValue;
  InvalidateCalibrationScale;
end;

procedure TRecorderTag.SetEstimateSettings(
  const AValue: TRecorderTagEstimateSettings);
var
  lPortionChanged: Boolean;
begin
  EnterCriticalSection(fEstimateLock);
  try
    lPortionChanged := fEstimateSettings.PortionLength <>
      AValue.PortionLength;
    fEstimateSettings := AValue;
    if lPortionChanged then
    begin
      { Не смешиваем остаток старой порции с новым размером. Следующая оценка
        будет опубликована только после накопления полной новой порции. }
      fEstimatePortionCount := 0;
      fEstimatePortionSum := 0.0;
      fEstimatePortionSquareSum := 0.0;
    end;
  finally
    LeaveCriticalSection(fEstimateLock);
  end;
end;

procedure TRecorderTag.SetHardwareCalibrationEnabled(AValue: Boolean);
begin
  if fHardwareCalibrationEnabled = AValue then
    Exit;
  fHardwareCalibrationEnabled := AValue;
  InvalidateCalibrationScale;
end;

procedure TRecorderTag.SetHardwareCalibrationName(const AValue: string);
var
  lValue: string;
begin
  lValue := Trim(AValue);
  if fHardwareCalibrationName = lValue then
    Exit;
  fHardwareCalibrationName := lValue;
  InvalidateCalibrationScale;
end;

procedure TRecorderTag.SetChannelCalibrationEnabled(AValue: Boolean);
begin
  if fChannelCalibrationEnabled = AValue then
    Exit;
  fChannelCalibrationEnabled := AValue;
  InvalidateCalibrationScale;
end;

function TRecorderTagRegistry.FindByName(const AName: string): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fTags.Count - 1 do
    if SameText(GetTag(I).Name, AName) then
      Exit(GetTag(I));
  I := fLoadedTagNameAliases.IndexOf(AName);
  if I >= 0 then
    Result := TRecorderTag(fLoadedTagNameAliases.Objects[I]);
end;

procedure TRecorderTagRegistry.RegisterLoadedTagAlias(
  AOldId: TRecorderTagId; const AOldName: string; ATarget: TRecorderTag);
var
  lIndex: Integer;
  lIdText: string;
  lName: string;
begin
  if not ContainsTag(ATarget) then
    raise ERecorderTagError.Create('Loaded tag alias target is not registered');

  if AOldId <> ATarget.Id then
  begin
    lIdText := IntToStr(AOldId);
    lIndex := fLoadedTagIdAliases.IndexOf(lIdText);
    if lIndex < 0 then
      fLoadedTagIdAliases.AddObject(lIdText, ATarget)
    else
      fLoadedTagIdAliases.Objects[lIndex] := ATarget;
  end;

  lName := Trim(AOldName);
  if (lName <> '') and not SameText(lName, ATarget.Name) then
  begin
    lIndex := fLoadedTagNameAliases.IndexOf(lName);
    if lIndex < 0 then
      fLoadedTagNameAliases.AddObject(lName, ATarget)
    else
      fLoadedTagNameAliases.Objects[lIndex] := ATarget;
  end;
end;

function TRecorderTagRegistry.ContainsTag(ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and (fTags.IndexOf(ATag) >= 0);
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

function TRecorderTagRegistry.FindCalibrationBySdbKey(
  const AKey: string): TRecorderCalibration;
var
  I: Integer;
  lKey: string;
begin
  Result := nil;
  lKey := Trim(AKey);
  if lKey = '' then
    Exit;
  for I := 0 to fCalibrations.Count - 1 do
    if (fCalibrations[I] <> nil) and
      SameText(Trim(fCalibrations[I].SdbKey), lKey) then
      Exit(fCalibrations[I]);
end;

function TRecorderTagRegistry.RemoveUnusedCalibrations: Integer;
var
  I: Integer;
  J: Integer;
  lName: string;
  lReferencedNames: TStringList;
  lTag: TRecorderTag;
begin
  Result := 0;
  lReferencedNames := TStringList.Create;
  try
    lReferencedNames.CaseSensitive := False;
    lReferencedNames.Sorted := True;
    lReferencedNames.Duplicates := dupIgnore;
    for I := 0 to TagCount - 1 do
    begin
      lTag := Tags[I];
      if lTag = nil then
        Continue;
      lName := Trim(lTag.HardwareCalibrationName);
      if lName <> '' then
        lReferencedNames.Add(lName);
      if lTag.CalibrationNames = nil then
        Continue;
      for J := 0 to lTag.CalibrationNames.Count - 1 do
      begin
        lName := Trim(lTag.CalibrationNames[J]);
        if lName <> '' then
          lReferencedNames.Add(lName);
      end;
    end;

    for I := fCalibrations.Count - 1 downto 0 do
      if (fCalibrations[I] = nil) or
        (lReferencedNames.IndexOf(Trim(fCalibrations[I].Name)) < 0) then
      begin
        fCalibrations.Delete(I);
        Inc(Result);
      end;
  finally
    lReferencedNames.Free;
  end;
end;

function TRecorderTagRegistry.CommitCalibrationEdit(ATarget,
  ADraft: TRecorderCalibration): Boolean;
var
  I: Integer;
  J: Integer;
  lExisting: TRecorderCalibration;
  lNewName: string;
  lOldName: string;
  lSdbKey: string;
  lSourceFileName: string;
  lTag: TRecorderTag;
begin
  Result := False;
  if (ATarget = nil) or (ADraft = nil) then
    Exit;
  lOldName := Trim(ATarget.Name);
  lSdbKey := ATarget.SdbKey;
  lSourceFileName := ATarget.SourceFileName;
  lNewName := Trim(ADraft.Name);
  if lNewName = '' then
    raise ERecorderTagError.Create('Calibration name cannot be empty');
  lExisting := FindCalibrationByName(lNewName);
  if (lExisting <> nil) and (lExisting <> ATarget) then
    raise ERecorderTagError.Create('Calibration name already exists: ' + lNewName);

  ATarget.Assign(ADraft);
  { A linked calibration remains the same source object after an in-place
    edit.  Explicit copy creation is the operation that clears this link. }
  if (ATarget.SdbKey = '') and (lSdbKey <> '') then
    ATarget.SdbKey := lSdbKey;
  if (ATarget.SourceFileName = '') and (lSourceFileName <> '') then
    ATarget.SourceFileName := lSourceFileName;
  ATarget.Name := lNewName;

  for I := 0 to TagCount - 1 do
  begin
    lTag := Tags[I];
    if lTag = nil then
      Continue;
    lTag.InvalidateCalibrationScale;
    for J := 0 to lTag.CalibrationNames.Count - 1 do
      if SameText(lTag.CalibrationNames[J], lOldName) then
        lTag.CalibrationNames[J] := lNewName;
    if SameText(lTag.HardwareCalibrationName, lOldName) then
      lTag.HardwareCalibrationName := lNewName;
    RebuildScales(lTag);
  end;
  Result := True;
end;

function TRecorderTagRegistry.AddCalibrationCopyForTag(ATag: TRecorderTag;
  APipelineIndex: Integer; ADraft: TRecorderCalibration): TRecorderCalibration;
var
  lBaseName: string;
  lName: string;
  lNumber: Integer;
begin
  Result := nil;
  if (ATag = nil) or (ADraft = nil) or
    (APipelineIndex < 0) or (APipelineIndex >= ATag.CalibrationNames.Count) then
    Exit;
  lBaseName := Trim(ADraft.Name);
  if lBaseName = '' then
    lBaseName := Trim(ATag.CalibrationNames[APipelineIndex]);
  if lBaseName = '' then
    lBaseName := 'ГХ';
  lName := lBaseName;
  lNumber := 2;
  while FindCalibrationByName(lName) <> nil do
  begin
    lName := lBaseName + ' (копия ' + IntToStr(lNumber) + ')';
    Inc(lNumber);
  end;

  Result := ADraft.Clone;
  Result.SdbKey := '';
  Result.Name := lName;
  fCalibrations.Add(Result);
  ATag.CalibrationNames[APipelineIndex] := lName;
end;

function TRecorderTagRegistry.FindTagHardwareCalibration(
  ATag: TRecorderTag): TRecorderCalibration;
begin
  Result := nil;
  if ATag = nil then
    Exit;
  if ATag.HardwareCalibrationEnabled and (Trim(ATag.HardwareCalibrationName) <> '') then
    Result := FindCalibrationByName(ATag.HardwareCalibrationName);
end;

function TRecorderTagRegistry.TryGetTagAutoUnit(ATag: TRecorderTag;
  out AUnitName: string): Boolean;
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lHardwareCalibration: TRecorderCalibration;
begin
  AUnitName := '';
  Result := False;
  if ATag = nil then
    Exit;

  lHardwareCalibration := FindTagHardwareCalibration(ATag);

  if ATag.ChannelCalibrationEnabled and (ATag.CalibrationNames <> nil) then
    for I := ATag.CalibrationNames.Count - 1 downto 0 do
    begin
      if not RecorderCalibrationStepEnabled(ATag.CalibrationNames, I) then
        Continue;
      lCalibration := FindCalibrationByName(ATag.CalibrationNames[I]);
      if (lCalibration <> nil) and (Trim(lCalibration.UnitOut) <> '') then
      begin
        AUnitName := Trim(lCalibration.UnitOut);
        Exit(True);
      end;
    end;

  { MIC-185 выполняет аппаратную ГХ и последующий пересчёт мВ -> Ом/мкстрн
    внутри datasource. Поэтому при отсутствии канальной ГХ результатом
    аппаратной части для пользователя является единица источника, а не
    промежуточный UnitOut аппаратной ГХ. }
  if (Pos('MIC-185:', ATag.SourceId) = 1) and
    (Trim(ATag.SourceUnitName) <> '') then
  begin
    AUnitName := Trim(ATag.SourceUnitName);
    Exit(True);
  end;

  if (lHardwareCalibration <> nil) and
    (Trim(lHardwareCalibration.UnitOut) <> '') then
  begin
    AUnitName := Trim(lHardwareCalibration.UnitOut);
    Result := True;
  end;
end;

procedure TRecorderTagRegistry.SyncTagAutoUnit(ATag: TRecorderTag;
  AForce: Boolean);
var
  lUnitName: string;
begin
  if (ATag = nil) or not (ATag.AutoUnit or AForce) then
    Exit;
  if TryGetTagAutoUnit(ATag, lUnitName) then
    ATag.fUnitName := lUnitName
  else
    ATag.fUnitName := Trim(ATag.fSourceUnitName);
  ATag.InvalidateCalibrationScale;
end;

procedure TRecorderTagRegistry.RebuildScales(ATag: TRecorderTag);
var
  I: Integer;
  lCalibration: TRecorderCalibration;
  lConversion: Double;
  lCurrentUnit: string;
  lResultUnit: string;
  lAutoUnit: string;

  function TryInputConversion(ACalibration: TRecorderCalibration;
    out AFactor: Double): Boolean;
  begin
    AFactor := 1.0;
    Result := True;
    if (ACalibration = nil) or (lCurrentUnit = '') or
      (Trim(ACalibration.UnitIn) = '') or
      SameText(lCurrentUnit, Trim(ACalibration.UnitIn)) then
      Exit;
    Result := RecorderUnitManager.TryGetConversionFactor(lCurrentUnit,
      ACalibration.UnitIn, AFactor);
  end;
begin
  if (ATag = nil) or ATag.fCalibrationScaleBuilt then
    Exit;
  ATag.fHardwareScale := 1.0;
  ATag.fResultScale := 1.0;
  ATag.fCalibrationScaleLinear := True;
  lCurrentUnit := Trim(ATag.fSourceUnitName);
  if lCurrentUnit = '' then
    lCurrentUnit := Trim(ATag.fUnitName);

  lCalibration := FindTagHardwareCalibration(ATag);
  if lCalibration <> nil then
  begin
    if (lCalibration.Kind <> rckScale) or
      not TryInputConversion(lCalibration, lConversion) then
      ATag.fCalibrationScaleLinear := False
    else
    begin
      ATag.fHardwareScale := lConversion * lCalibration.Scale;
      ATag.fResultScale := ATag.fResultScale * ATag.fHardwareScale;
      lCurrentUnit := Trim(lCalibration.UnitOut);
    end;
  end;

  if ATag.ChannelCalibrationEnabled and (ATag.CalibrationNames <> nil) then
    for I := 0 to ATag.CalibrationNames.Count - 1 do
    begin
      if not RecorderCalibrationStepEnabled(ATag.CalibrationNames, I) then
        Continue;
      lCalibration := FindCalibrationByName(ATag.CalibrationNames[I]);
      if lCalibration = nil then
        Continue;
      if (lCalibration.Kind <> rckScale) or
        not TryInputConversion(lCalibration, lConversion) then
      begin
        ATag.fCalibrationScaleLinear := False;
        Break;
      end;
      ATag.fResultScale := ATag.fResultScale * lConversion *
        lCalibration.Scale;
      lCurrentUnit := Trim(lCalibration.UnitOut);
    end;

  { AutoUnit управляет только выбранной единицей результата. Сама цепочка ГХ
    определяется исключительно флагами Hardware/ChannelCalibrationEnabled.
    Для ручной совместимой единицы добавляем конечный переход в уже свёрнутый
    коэффициент (например, V -> mV), не пересчитывая pipeline в runtime. }
  lResultUnit := lCurrentUnit;
  { TryGetTagAutoUnit также возвращает UnitOut нелинейной последней ступени,
    которую линейный свёртыватель намеренно не обходит. }
  if TryGetTagAutoUnit(ATag, lAutoUnit) then
    lResultUnit := lAutoUnit;
  if ATag.AutoUnit then
    ATag.fUnitName := lResultUnit
  else if ATag.fCalibrationScaleLinear and (lResultUnit <> '') and
    (Trim(ATag.fUnitName) <> '') and
    not SameText(lResultUnit, Trim(ATag.fUnitName)) then
  begin
    if RecorderUnitManager.TryGetConversionFactor(lResultUnit,
      ATag.fUnitName, lConversion) then
      ATag.fResultScale := ATag.fResultScale * lConversion
    else
      ATag.fCalibrationScaleLinear := False;
  end;
  ATag.fCalibrationScaleBuilt := True;
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
    if not RecorderCalibrationStepEnabled(ATag.CalibrationNames, I) then
      Continue;
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
  RebuildScales(ATag);
  if ATag.fCalibrationScaleLinear then
    Exit(AValue * ATag.fHardwareScale);
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
  lHardwareCalibration: TRecorderCalibration;
  lConversion: Double;
  lCurrentUnit: string;
  lOutputUnit: string;
begin
  if ATag <> nil then
  begin
    RebuildScales(ATag);
    if ATag.fCalibrationScaleLinear and not CalibrationCaptureActive(ATag) then
      Exit(AValue * ATag.fResultScale);
  end;
  if ATag = nil then
    Exit(AValue);
  Result := AValue;
  lCurrentUnit := Trim(ATag.SourceUnitName);
  if lCurrentUnit = '' then
    lCurrentUnit := Trim(ATag.UnitName);

  lHardwareCalibration := FindTagHardwareCalibration(ATag);
  if lHardwareCalibration <> nil then
  begin
    if (lCurrentUnit <> '') and
      (Trim(lHardwareCalibration.UnitIn) <> '') and
      not SameText(lCurrentUnit, Trim(lHardwareCalibration.UnitIn)) and
      RecorderUnitManager.TryGetConversionFactor(lCurrentUnit,
        lHardwareCalibration.UnitIn, lConversion) then
      Result := Result * lConversion;
    Result := lHardwareCalibration.Transform(Result);
    lCurrentUnit := Trim(lHardwareCalibration.UnitOut);
  end;
  { Интерактивная градуировка видит только вход канальной цепочки. Обычный
    runtime не платит за снимки и вычисления; активен лишь короткий append в
    заранее выделенный буфер одной выбранной сессии. }
  CaptureCalibrationValue(ATag, Result);
  if ATag.ChannelCalibrationEnabled and (ATag.CalibrationNames <> nil) then
    for I := 0 to ATag.CalibrationNames.Count - 1 do
    begin
      if not RecorderCalibrationStepEnabled(ATag.CalibrationNames, I) then
        Continue;
      lCalibration := FindCalibrationByName(ATag.CalibrationNames[I]);
      if lCalibration <> nil then
      begin
        if (lCurrentUnit <> '') and (Trim(lCalibration.UnitIn) <> '') and
          not SameText(lCurrentUnit, Trim(lCalibration.UnitIn)) and
          RecorderUnitManager.TryGetConversionFactor(lCurrentUnit,
            lCalibration.UnitIn, lConversion) then
          Result := Result * lConversion;
        Result := lCalibration.Transform(Result);
        lCurrentUnit := Trim(lCalibration.UnitOut);
      end;
    end;
  { Нелинейная цепочка не имеет ResultScale, поэтому совместимый переход от
    UnitOut последней включённой ГХ к ручной единице выполняется один раз после
    всех Transform. AutoUnit уже показывает сам UnitOut и перехода не требует. }
  lOutputUnit := lCurrentUnit;
  if (not ATag.AutoUnit) and (lOutputUnit <> '') and
    (Trim(ATag.UnitName) <> '') and
    not SameText(lOutputUnit, Trim(ATag.UnitName)) and
    RecorderUnitManager.TryGetConversionFactor(lOutputUnit, ATag.UnitName,
      lConversion) then
    Result := Result * lConversion;
end;

function TRecorderTagRegistry.CalibrationCaptureActive(
  ATag: TRecorderTag): Boolean;
begin
  Result := (ATag <> nil) and (fCalibrationCaptureTag = ATag);
end;

procedure TRecorderTagRegistry.CaptureCalibrationValue(ATag: TRecorderTag;
  AValue: Double);
begin
  if not CalibrationCaptureActive(ATag) then
    Exit;
  EnterCriticalSection(fCalibrationCaptureLock);
  try
    if (fCalibrationCaptureTag = ATag) and
      (fCalibrationCaptureCount < Length(fCalibrationCaptureValues)) then
    begin
      fCalibrationCaptureValues[fCalibrationCaptureCount] := AValue;
      Inc(fCalibrationCaptureCount);
    end;
  finally
    LeaveCriticalSection(fCalibrationCaptureLock);
  end;
end;

procedure TRecorderTagRegistry.BeginCalibrationCapture(ATag: TRecorderTag;
  ADurationSec: Double);
var
  lCapacity: Integer;
begin
  if (ATag = nil) or not ContainsTag(ATag) then
    raise ERecorderTagError.Create('Calibration capture tag is not registered');
  if ADurationSec <= 0 then
    ADurationSec := 1.0;
  lCapacity := Max(32, Ceil(Max(1.0, ATag.PollFrequencyHz) *
    ADurationSec * 1.25));
  EnterCriticalSection(fCalibrationCaptureLock);
  try
    fCalibrationCaptureTag := nil;
    SetLength(fCalibrationCaptureValues, lCapacity);
    fCalibrationCaptureCount := 0;
    fCalibrationCaptureTag := ATag;
  finally
    LeaveCriticalSection(fCalibrationCaptureLock);
  end;
end;

function TRecorderTagRegistry.EnsureCalibrationData(ATag: TRecorderTag;
  out AStartedByCalibration: Boolean; out AError: string): Boolean;
begin
  AStartedByCalibration := False;
  AError := '';
  if not ContainsTag(ATag) then
  begin
    AError := 'Выбранный тег больше не зарегистрирован.';
    Exit(False);
  end;
  if not Assigned(fOnEnsureCalibrationData) then
  begin
    AError := 'Запуск просмотра для градуировки недоступен.';
    Exit(False);
  end;
  Result := fOnEnsureCalibrationData(ATag, AStartedByCalibration, AError);
  if (not Result) and (Trim(AError) = '') then
    AError := 'Не удалось запустить просмотр данных.';
end;

procedure TRecorderTagRegistry.ReleaseCalibrationData(ATag: TRecorderTag);
begin
  if ContainsTag(ATag) and Assigned(fOnReleaseCalibrationData) then
    fOnReleaseCalibrationData(ATag);
end;

function TRecorderTagRegistry.CalibrationCaptureSampleCount(
  ATag: TRecorderTag): Integer;
begin
  Result := 0;
  EnterCriticalSection(fCalibrationCaptureLock);
  try
    if (ATag <> nil) and (fCalibrationCaptureTag = ATag) then
      Result := fCalibrationCaptureCount;
  finally
    LeaveCriticalSection(fCalibrationCaptureLock);
  end;
end;

function TRecorderTagRegistry.FinishCalibrationCapture(ATag: TRecorderTag;
  out ASnapshot: TRecorderSignalSnapshot): Boolean;
var
  I: Integer;
begin
  ASnapshot.Count := 0;
  SetLength(ASnapshot.Times, 0);
  SetLength(ASnapshot.Values, 0);
  EnterCriticalSection(fCalibrationCaptureLock);
  try
    Result := (ATag <> nil) and (fCalibrationCaptureTag = ATag) and
      (fCalibrationCaptureCount > 0);
    fCalibrationCaptureTag := nil;
    if Result then
    begin
      ASnapshot.Count := fCalibrationCaptureCount;
      SetLength(ASnapshot.Times, ASnapshot.Count);
      SetLength(ASnapshot.Values, ASnapshot.Count);
      for I := 0 to ASnapshot.Count - 1 do
      begin
        ASnapshot.Times[I] := I;
        ASnapshot.Values[I] := fCalibrationCaptureValues[I];
      end;
    end;
    fCalibrationCaptureCount := 0;
  finally
    LeaveCriticalSection(fCalibrationCaptureLock);
  end;
end;

procedure TRecorderTagRegistry.CancelCalibrationCapture(ATag: TRecorderTag);
begin
  EnterCriticalSection(fCalibrationCaptureLock);
  try
    if (ATag = nil) or (fCalibrationCaptureTag = ATag) then
    begin
      fCalibrationCaptureTag := nil;
      fCalibrationCaptureCount := 0;
    end;
  finally
    LeaveCriticalSection(fCalibrationCaptureLock);
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

function RecorderIsHardwareTagSource(const ASourceId: string): Boolean;
var
  lSourceId: string;
begin
  lSourceId := RecorderNormalizeTagSourceId(ASourceId);
  Result := (lSourceId <> '') and
    (not RecorderIsDetachedTagSource(ASourceId)) and
    (not RecorderIsVirtualTagSource(lSourceId)) and
    (not SameText(lSourceId, 'manual')) and
    (not SameText(lSourceId, 'debug.diagnostics'));
end;

function RecorderHardwareTreeShowsSourceId(const ASourceId: string): Boolean;
var
  lNorm: string;
begin
  lNorm := RecorderNormalizeTagSourceId(ASourceId);
  if lNorm = '' then
    Exit(False);
  Result := RecorderIsVirtualTagSource(lNorm) or RecorderIsHardwareTagSource(lNorm);
end;

function RecorderTagSourceIsVisible(ARegistry: TRecorderTagRegistry;
  ATag: TRecorderTag): Boolean;
var
  lPath: string;
  lSourceId: string;
begin
  Result := ATag <> nil;
  if not Result then
    Exit;
  if RecorderIsDetachedTagSource(ATag.SourceId) then
    Exit(False);
  { Виртуальность задаётся явно при создании тега. Такой тег не должен
    исчезать из представлений только потому, что его SourceId не является
    зарегистрированным аппаратным источником. }
  if ATag.IsVirtual then
    Exit(True);
  if ARegistry = nil then
    Exit;

  lSourceId := RecorderNormalizeTagSourceId(ATag.SourceId);
  if lSourceId = '' then
    Exit;
  if RecorderIsVirtualTagSource(lSourceId) then
  begin
    if ARegistry.IsSourceActive(lSourceId) then
      Exit(True);
    lPath := Trim(Copy(lSourceId, Length(CMeraTagSourcePrefix) + 1, MaxInt));
    Result := (lPath <> '') and
      (FileExists(lPath) or FileExists(ExpandFileName(lPath)));
    Exit;
  end;
  if RecorderIsHardwareTagSource(lSourceId) then
    Result := ARegistry.IsSourceActive(lSourceId);
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
      RegisterActiveSource(lSourceId);
  end;
end;

function TRecorderTagRegistry.IsSourceActive(const ASourceId: string): Boolean;
var
  lSourceId,s: string;
  ind:integer;
begin
  lSourceId := Trim(ASourceId);
  ind:=fActiveSourceIds.IndexOf(lSourceId);
  if ind>=0 then
    s:=fActiveSourceIds.Strings[ind];
  Result := (lSourceId = '') or (ind >= 0);
end;

procedure TRecorderTagRegistry.PublishValue(const ATagName: string; ATimeSec,
  AValue: Double);
var
  lTag: TRecorderTag;
begin
  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);
  PublishValue(lTag, ATimeSec, AValue);
end;

procedure TRecorderTagRegistry.PublishValue(ATag: TRecorderTag; ATimeSec,
  AValue: Double);
begin
  PublishValueInternal(ATag, ATimeSec, AValue, True);
end;

procedure TRecorderTagRegistry.PublishValueInternal(ATag: TRecorderTag;
  ATimeSec, AValue: Double; AIsInput: Boolean);
var
  lEvent: TRecorderEvent;
  lEventData: TRecorderTagUpdateEventData;
  lValue: Double;
begin
  if ATag = nil then
    raise ERecorderTagError.Create('Tag is nil');
  if not ContainsTag(ATag) then
    Exit;

  ATimeSec := ResolvePublishTime(ATimeSec);
  lValue := TransformTagValue(ATag, AValue);
  ATag.AddSample(ATimeSec, lValue);
  MarkRuntimeDataUpdated(ATimeSec);
  if AIsInput then MarkInputDataUpdated;

  if Assigned(fOnValuePublished) then
    fOnValuePublished(fValuePublishedTarget, ATag, ATimeSec, lValue);
  if Assigned(fOnAlarmValuePublished) then
    fOnAlarmValuePublished(fAlarmValuePublishedTarget, ATag, ATimeSec, lValue);

  if fEventBus <> nil then
  begin
    lEventData := TRecorderTagUpdateEventData.Create(ATag, ATimeSec, lValue);
    try
      lEvent := TRecorderEventBus.MakeEvent(rceDataUpdated, Self, ATag.Name,
        ATag.TextValue, 1, lEventData);
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

procedure TRecorderTagRegistry.SetValuePublishedHandler(ATarget: TObject;
  AHandler: TRecorderTagValuePublishedEvent);
begin
  fValuePublishedTarget := ATarget;
  fOnValuePublished := AHandler;
end;

procedure TRecorderTagRegistry.SetAlarmValuePublishedHandler(ATarget: TObject;
  AHandler: TRecorderTagValuePublishedEvent);
begin
  fAlarmValuePublishedTarget := ATarget;
  fOnAlarmValuePublished := AHandler;
end;

procedure TRecorderTagRegistry.AddBlockSamples(const ATagName: string;
  const ATimes, AValues: array of Double; ACount: Integer;
  AValuesAlreadyTransformed: Boolean);
var
  lTag: TRecorderTag;
begin
  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);
  AddBlockSamples(lTag, ATimes, AValues, ACount, AValuesAlreadyTransformed);
end;

procedure TRecorderTagRegistry.AddBlockSamples(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer;
  AValuesAlreadyTransformed: Boolean);
var
  lValues: TRecorderDoubleArray;
  I: Integer;
begin
  if ACount <= 0 then
    Exit;
  if (ACount > Length(ATimes)) or (ACount > Length(AValues)) then
    raise ERecorderTagError.Create('Publish block count exceeds data length');

  if ATag = nil then
    raise ERecorderTagError.Create('Tag is nil');
  if not ContainsTag(ATag) then
    Exit;

  if AValuesAlreadyTransformed then
    ATag.AddSamples(ATimes, AValues, ACount)
  else
  begin
    SetLength(lValues, ACount);
    for I := 0 to ACount - 1 do
      lValues[I] := TransformTagValue(ATag, AValues[I]);
    ATag.AddSamples(ATimes, lValues, ACount);
  end;
  MarkRuntimeDataUpdated(ATimes[ACount - 1]);
  MarkInputDataUpdated;
end;

procedure TRecorderTagRegistry.PublishValue(const ATagName: string;
  AValue: Double);
begin
  PublishValue(ATagName, 0.0, AValue);
end;

procedure TRecorderTagRegistry.PublishValue(ATag: TRecorderTag; AValue: Double);
begin
  PublishValue(ATag, 0.0, AValue);
end;

procedure TRecorderTagRegistry.SetSqlBlockPublishedHandler(ATarget: TObject;
  AHandler: TRecorderTagSqlBlockPublishedEvent);
begin
  fSqlBlockPublishedTarget := ATarget;
  fOnSqlBlockPublished := AHandler;
end;

procedure TRecorderTagRegistry.PublishExternalValue(const ATagName: string;
  AValue: Double);
var
  lTag: TRecorderTag;
begin
  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);
  PublishExternalValue(lTag, AValue);
end;

procedure TRecorderTagRegistry.PublishExternalValue(ATag: TRecorderTag;
  AValue: Double);
begin
  if (ATag = nil) or not ATag.ExternalWriteAllowed then Exit;
  BeginExternalWriteBatch;
  try
    PublishValueInternal(ATag, 0.0, AValue, False);
    ATag.QueueExternalWrite(AValue);
  finally
    EndExternalWriteBatch;
  end;
end;

procedure TRecorderTagRegistry.BeginExternalWriteBatch;
begin
  EnterCriticalSection(fExternalWriteBatchLock);
end;

procedure TRecorderTagRegistry.EndExternalWriteBatch;
begin
  LeaveCriticalSection(fExternalWriteBatchLock);
end;

function TRecorderTagRegistry.ResolvePublishTime(ATimeSec: Double): Double;
begin
  if ATimeSec > 0 then Exit(ATimeSec);
  if fTimeSystem <> nil then
    Result := fTimeSystem.Snapshot.ElapsedSec
  else
    Result := (GetTickCount64 - fFallbackStartTickMs) / 1000.0;
end;

procedure TRecorderTagRegistry.NotifyBlockTail(const ATagName: string;
  ATimeSec, AValue: Double);
var
  lTag: TRecorderTag;
begin
  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);
  if Assigned(fOnAlarmValuePublished) then
    fOnAlarmValuePublished(fAlarmValuePublishedTarget, lTag, ATimeSec, AValue);
end;

procedure TRecorderTagRegistry.PublishBlockNotifications(const ATagName: string);
var
  lTag: TRecorderTag;
begin
  lTag := FindByName(ATagName);
  PublishBlockNotifications(lTag);
end;

procedure TRecorderTagRegistry.PublishBlockNotifications(ATag: TRecorderTag);
var
  lSnapshot: TRecorderSignalSnapshot;
begin
  if ATag = nil then
    Exit;
  lSnapshot := ATag.LastBlockSnapshot;
  PublishBlockNotifications(ATag, lSnapshot.Times, lSnapshot.Values,
    lSnapshot.Count);
end;

procedure TRecorderTagRegistry.PublishBlockNotifications(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer);
var
  lEvent: TRecorderEvent;
  lEventData: TRecorderTagUpdateEventData;
begin
  if (ATag = nil) or (ACount <= 0) or (ACount > Length(ATimes)) or
    (ACount > Length(AValues)) then
    Exit;
  { SQL persistence is the first block consumer. Algorithm and alarm handlers
    are allowed to do substantially more work and must not delay or suppress
    the measurement that has already been accepted into the tag buffer. }
  if Assigned(fOnSqlBlockPublished) then
    try
      fOnSqlBlockPublished(fSqlBlockPublishedTarget, ATag,
        ATimes[ACount - 1], AValues[ACount - 1]);
    except
      on E: Exception do
        RecorderDebugLog(Format(
          '[Tags] SQL block consumer failed for %s: %s: %s',
          [ATag.Name, E.ClassName, E.Message]));
    end;
  if Assigned(fOnBlockPublished) then
    try
      fOnBlockPublished(fBlockPublishedTarget, ATag.Name, ATimes, AValues,
        ACount);
    except
      on E: Exception do
        RecorderDebugLog(Format(
          '[Tags] block consumer failed for %s: %s: %s',
          [ATag.Name, E.ClassName, E.Message]));
    end;
  if Assigned(fOnAlarmValuePublished) then
    try
      fOnAlarmValuePublished(fAlarmValuePublishedTarget, ATag,
        ATimes[ACount - 1], AValues[ACount - 1]);
    except
      on E: Exception do
        RecorderDebugLog(Format(
          '[Tags] alarm consumer failed for %s: %s: %s',
          [ATag.Name, E.ClassName, E.Message]));
    end;
  { Для медленных потребителей публикуется только хвост блока. Сами массивы
    остаются в буфере тега, поэтому acquisition-путь не получает лишнего копирования. }
  if fEventBus <> nil then
  begin
    lEventData := TRecorderTagUpdateEventData.CreateBlockTailNotify(ATag,
      ATimes[ACount - 1], AValues[ACount - 1]);
    try
      lEvent := TRecorderEventBus.MakeEvent(rceDataUpdated, Self, ATag.Name,
        ATag.TextValue, 1, lEventData);
      try
        fEventBus.Publish(lEvent);
      except
        on E: Exception do
          RecorderDebugLog(Format(
            '[Tags] event consumer failed for %s: %s: %s',
            [ATag.Name, E.ClassName, E.Message]));
      end;
    finally
      lEventData.Free;
    end;
  end;
  { Массивы измерений через EventBus не передаются. Потребители по своему
    настраиваемому периоду читают непрочитанный хвост кольца по курсору. }
end;

procedure TRecorderTagRegistry.PublishBlock(const ATagName: string; const ATimes,
  AValues: array of Double; ACount: Integer; AValuesAlreadyTransformed: Boolean);
var
  lTag: TRecorderTag;
begin
  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);
  PublishBlock(lTag, ATimes, AValues, ACount, AValuesAlreadyTransformed);
end;

procedure TRecorderTagRegistry.PublishBlock(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer;
  AValuesAlreadyTransformed: Boolean);
var
  I: Integer;
  lValues: TRecorderDoubleArray;
begin
  if ACount <= 0 then Exit;
  if ATag = nil then
    raise ERecorderTagError.Create('Tag is required for block publication');
  if AValuesAlreadyTransformed then
    ATag.AddSamples(ATimes, AValues, ACount)
  else
  begin
    SetLength(lValues, ACount);
    for I := 0 to ACount - 1 do
      lValues[I] := TransformTagValue(ATag, AValues[I]);
    ATag.AddSamples(ATimes, lValues, ACount);
  end;
  MarkRuntimeDataUpdated(ATimes[ACount - 1]);
  MarkInputDataUpdated;
  // This method is in the acquisition hot path. Per-tag disk logging turns a
  // 48-channel hardware block into dozens of synchronous writes and can delay
  // the next device read. Device-level diagnostics log block summaries.
  { Для уже преобразованных данных можно передать исходный массив напрямую.
    Иначе уведомление должно получить значения после ГХ из последнего блока. }
  if AValuesAlreadyTransformed then
    PublishBlockNotifications(ATag, ATimes, AValues, ACount)
  else
    PublishBlockNotifications(ATag, ATimes, lValues, ACount);
end;

procedure TRecorderTagRegistry.RemoveTagReferences(ATag: TRecorderTag);
var
  I, J: Integer;
  lBand: TRecorderFrequencyBand;
  lName: string;
  lNode: TRecorderSpectrumConfigNode;
begin
  if ATag = nil then
    Exit;

  lName := ATag.Name;
  if SameText(fSelectedTagName, lName) then
    fSelectedTagName := '';

  if fSpectrumConfigs <> nil then
    for I := 0 to fSpectrumConfigs.NodeCount - 1 do
    begin
      lNode := fSpectrumConfigs.Nodes[I];
      for J := lNode.BindingCount - 1 downto 0 do
        if SameText(lNode.Bindings[J].SourceTagName, lName) then
          lNode.DeleteBinding(J);
    end;

  if fFrequencyBands <> nil then
    for I := fFrequencyBands.BandCount - 1 downto 0 do
    begin
      lBand := fFrequencyBands.Bands[I];
      for J := lBand.TermCount - 1 downto 0 do
        if SameText(lBand.Terms[J].TagName, lName) then
          lBand.DeleteTerm(J);
      if (lBand.Kind = fbkFormula) and (lBand.TermCount = 0) then
        fFrequencyBands.DeleteBand(I);
    end;
end;

procedure TRecorderTagRegistry.RemoveTag(ATag: TRecorderTag);
begin
  if ATag <> nil then
  begin
    RemoveTagReferences(ATag);
    RemoveLoadedTagAliases(ATag);
    fTags.Remove(ATag);
    ATag.Free;
    Inc(fStructureRevision);
  end;
end;

procedure TRecorderTagRegistry.RemoveLoadedTagAliases(ATag: TRecorderTag);
var
  I: Integer;
begin
  for I := fLoadedTagIdAliases.Count - 1 downto 0 do
    if fLoadedTagIdAliases.Objects[I] = ATag then
      fLoadedTagIdAliases.Delete(I);
  for I := fLoadedTagNameAliases.Count - 1 downto 0 do
    if fLoadedTagNameAliases.Objects[I] = ATag then
      fLoadedTagNameAliases.Delete(I);
end;

procedure TRecorderTagRegistry.RemoveTagsBySourceId(const ASourceId: string);
var
  I: Integer;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  lSourceId := RecorderNormalizeTagSourceId(ASourceId);
  if lSourceId = '' then
    Exit;
  for I := fTags.Count - 1 downto 0 do
  begin
    lTag := TRecorderTag(fTags[I]);
    if SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lSourceId) then
      RemoveTag(lTag);
  end;
end;

procedure TRecorderTagRegistry.DetachTagsBySourceId(const ASourceId: string);
var
  I: Integer;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  lSourceId := RecorderNormalizeTagSourceId(ASourceId);
  if lSourceId = '' then
    Exit;
  for I := 0 to fTags.Count - 1 do
  begin
    lTag := TRecorderTag(fTags[I]);
    if SameText(RecorderNormalizeTagSourceId(lTag.SourceId), lSourceId) then
      lTag.SourceId := CDetachedTagSourcePrefix + ' ' + lSourceId;
  end;
end;

procedure TRecorderTagRegistry.Clear;
var
  I: Integer;
begin
  fLoadedTagIdAliases.Clear;
  fLoadedTagNameAliases.Clear;
  for I := 0 to fTags.Count - 1 do
    TObject(fTags[I]).Free;
  fTags.Clear;
  Inc(fStructureRevision);
  fSourceSpecificConfigs.Clear;
  fConfiguredDataSources.Clear;
  fTagGroupPaths.Clear;
  fSelectedTagName := '';
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
  fOffset := 0.0;
  fK1 := 1.0;
  fK2 := 0.0;
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
  fOffset := ASource.Offset;
  fK1 := ASource.K1;
  fK2 := ASource.K2;
  fModuleData := ASource.ModuleData;
  fSdbKey := ASource.SdbKey;
  fSourceFileName := ASource.SourceFileName;
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

function RecorderResolveTagReference(ARegistry:TRecorderTagRegistry;
  ATagId:TRecorderTagId; const ATagName:string):TRecorderTag;
begin
  Result:=nil;
  if ARegistry=nil then
    Exit;
  if Trim(ATagName)<>'' then
    Result:=ARegistry.FindByName(Trim(ATagName))
  else if ATagId<>0 then
    Result:=ARegistry.FindById(ATagId);
end;

function RecorderTryReadScalarValue(ATag:TRecorderTag;
  AUseDefaultEstimate:Boolean; AEstimateKind:TRecorderTagEstimateKind;
  out AValue:Double):Boolean;
var
  lEstimate:TRecorderTagEstimate;
begin
  Result:=False;
  AValue:=NaN;
  if ATag=nil then
    Exit;
  if ATag.IsVector then
  begin
    if AUseDefaultEstimate then
      AEstimateKind:=ATag.EstimateSettings.DefaultKind;
    lEstimate:=ATag.Estimate(AEstimateKind);
    if not lEstimate.Valid then
      Exit;
    AValue:=lEstimate.Value;
  end
  else
  begin
    if ATag.SignalBuffer.Count=0 then
      Exit;
    AValue:=ATag.SignalBuffer.LatestValue;
  end;
  Result:=not IsNan(AValue) and not IsInfinite(AValue);
end;

function TRecorderCalibration.ConvertInputUnit(
  const AUnitName: string): Boolean;
var
  I: Integer;
  lDegree: Integer;
  lFactor: Double;
  lPoint: TRecorderCalibrationPoint;
begin
  Result := False;
  if (Trim(fUnitIn) = '') or (Trim(AUnitName) = '') then
    Exit;
  if SameText(Trim(fUnitIn), Trim(AUnitName)) then
    Exit(True);
  if not RecorderUnitManager.TryGetConversionFactor(fUnitIn, AUnitName,
    lFactor) then
    Exit;

  case fKind of
    rckScale:
      fScale := fScale / lFactor;
    rckLinear:
      fScale := fScale / lFactor;
    rckStrain:
      begin
        fK1 := fK1 / lFactor;
        fK2 := fK2 / Sqr(lFactor);
      end;
    rckPiecewiseLinear:
      for I := 0 to fPoints.Count - 1 do
      begin
        lPoint := PointAt(I);
        if lPoint <> nil then
          lPoint.X := lPoint.X * lFactor;
      end;
    rckPolynomial:
      for I := 0 to fPoints.Count - 1 do
      begin
        lPoint := PointAt(I);
        if lPoint <> nil then
        begin
          lDegree := Max(0, Round(lPoint.X));
          lPoint.Y := lPoint.Y / IntPower(lFactor, lDegree);
        end;
      end;
  end;
  fUnitIn := Trim(AUnitName);
  Result := True;
end;

function TRecorderCalibration.ConvertOutputUnit(
  const AUnitName: string): Boolean;
var
  I: Integer;
  lFactor: Double;
  lPoint: TRecorderCalibrationPoint;
begin
  Result := False;
  if (Trim(fUnitOut) = '') or (Trim(AUnitName) = '') then
    Exit;
  if SameText(Trim(fUnitOut), Trim(AUnitName)) then
    Exit(True);
  if not RecorderUnitManager.TryGetConversionFactor(fUnitOut, AUnitName,
    lFactor) then
    Exit;

  case fKind of
    rckScale:
      fScale := fScale * lFactor;
    rckLinear:
      begin
        fScale := fScale * lFactor;
        fOffset := fOffset * lFactor;
      end;
    rckStrain:
      begin
        fOffset := fOffset * lFactor;
        fK1 := fK1 * lFactor;
        fK2 := fK2 * lFactor;
      end;
    rckPiecewiseLinear, rckPolynomial:
      for I := 0 to fPoints.Count - 1 do
      begin
        lPoint := PointAt(I);
        if lPoint <> nil then
          lPoint.Y := lPoint.Y * lFactor;
      end;
  end;
  fUnitOut := Trim(AUnitName);
  Result := True;
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
    rckLinear:
      Result := AValue * fScale + fOffset;
    rckStrain:
      Result := fOffset + fK1 * AValue + fK2 * AValue * AValue;
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
    rckPolynomial:
      begin
        Result := 0.0;
        for I := 0 to fPoints.Count - 1 do
        begin
          lA := PointAt(I);
          if lA <> nil then
            Result := Result + lA.Y * IntPower(AValue,
              Max(0, Round(lA.X)));
        end;
      end;
  end;
end;

function TRecorderCalibration.InverseTransform(AValue: Double;
  out AInputValue: Double): Boolean;
var
  lAscending: Boolean;
  lA: TRecorderCalibrationPoint;
  lB: TRecorderCalibrationPoint;
  lFirst: TRecorderCalibrationPoint;
  lLast: TRecorderCalibrationPoint;
  lLeft: Integer;
  lMid: Integer;
  lRight: Integer;
  lDiscriminant: Double;
  lLinearEstimate: Double;
  lRoot1: Double;
  lRoot2: Double;
begin
  Result := False;
  AInputValue := 0.0;
  case fKind of
    rckScale:
      begin
        if SameValue(fScale, 0.0) then
          Exit;
        AInputValue := AValue / fScale;
        Exit(True);
      end;
    rckLinear:
      begin
        if SameValue(fScale, 0.0) then
          Exit;
        AInputValue := (AValue - fOffset) / fScale;
        Exit(True);
      end;
    rckStrain:
      begin
        if SameValue(fK2, 0.0) then
        begin
          if SameValue(fK1, 0.0) then Exit;
          AInputValue := (AValue - fOffset) / fK1;
          Exit(True);
        end;
        { Выбираем корень, ближайший к линейной оценке. }
        lDiscriminant := Sqr(fK1) - 4 * fK2 * (fOffset - AValue);
        if lDiscriminant < 0 then Exit;
        lRoot1 := (-fK1 + Sqrt(lDiscriminant)) / (2 * fK2);
        lRoot2 := (-fK1 - Sqrt(lDiscriminant)) / (2 * fK2);
        if not SameValue(fK1, 0.0) then
          lLinearEstimate := (AValue - fOffset) / fK1
        else
          lLinearEstimate := 0.0;
        if Abs(lRoot1 - lLinearEstimate) <= Abs(lRoot2 - lLinearEstimate) then
          AInputValue := lRoot1
        else
          AInputValue := lRoot2;
        Result := True;
      end;
    rckPiecewiseLinear:
      begin
        if fPoints.Count < 2 then
          Exit;
        lFirst := PointAt(0);
        lLast := PointAt(fPoints.Count - 1);
        if (lFirst = nil) or (lLast = nil) then
          Exit;
        lAscending := lFirst.Y <= lLast.Y;
        lLeft := 0;
        lRight := fPoints.Count - 1;
        while lRight - lLeft > 1 do
        begin
          lMid := (lLeft + lRight) div 2;
          lA := PointAt(lMid);
          if lA = nil then
            Exit;
          if (lA.Y < AValue) = lAscending then
            lLeft := lMid
          else
            lRight := lMid;
        end;

        if (AValue < Min(lFirst.Y, lLast.Y)) or
          (AValue > Max(lFirst.Y, lLast.Y)) then
        begin
          if not fExtrapolation then
          begin
            if Abs(AValue - lFirst.Y) <= Abs(AValue - lLast.Y) then
              AInputValue := lFirst.X
            else
              AInputValue := lLast.X;
            Exit(True);
          end;
          if ((AValue < lFirst.Y) = lAscending) then
          begin
            lLeft := 0;
            lRight := 1;
          end
          else
          begin
            lLeft := fPoints.Count - 2;
            lRight := fPoints.Count - 1;
          end;
        end;

        lA := PointAt(lLeft);
        lB := PointAt(lRight);
        if (lA = nil) or (lB = nil) then
          Exit;
        if SameValue(lA.Y, lB.Y) then
          AInputValue := lA.X
        else
          AInputValue := lA.X + (AValue - lA.Y) *
            (lB.X - lA.X) / (lB.Y - lA.Y);
        Result := True;
      end;
    rckPolynomial:
      Exit;
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
