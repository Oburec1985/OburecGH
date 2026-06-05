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

interface

uses
  Classes, SysUtils,
  uRecorderCoreServices;

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
  public
    constructor Create(ATag: TRecorderTag; ATimeSec, AValue: Double); overload;
    constructor CreateBlock(ATag: TRecorderTag; const ATimes, AValues: array of Double; ACount: Integer);
    property Tag: TRecorderTag read fTag;
    property TimeSec: Double read fTimeSec;
    property Value: Double read fValue;
    property SampleCount: Integer read fSampleCount;
    property Times: TRecorderDoubleArray read fTimes;
    property Values: TRecorderDoubleArray read fValues;
  end;

  { TRecorderTagRegistry
    Реестр тегов RecorderLnx. Владеет тегами, обеспечивает уникальность id/name и
    публикует rceDataUpdated при записи значения. }
  TRecorderTagRegistry = class
  private
    fActiveSourceIds: TStringList;                     { Active data source ids for detached tag indication }
    fEventBus: TRecorderEventBus;                     { Ссылка на шину событий }
    fNextId: TRecorderTagId;                          { Счетчик следующего ID }
    fSelectedTagName: string;                         { Имя текущего выбранного тега }
    fTags: TList;                                     { Список тегов (TRecorderTag) }
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

    procedure RegisterActiveSource(const ASourceId: string);
    procedure UnregisterActiveSource(const ASourceId: string);
    procedure ClearActiveSources;
    function IsSourceActive(const ASourceId: string): Boolean;

    { Публикует новое значение тега и отправляет событие rceDataUpdated. }
    procedure PublishValue(const ATagName: string; ATimeSec, AValue: Double);
    { Публикует блок значений тега и отправляет событие rceDataUpdated. }
    procedure PublishBlock(const ATagName: string; const ATimes,
      AValues: array of Double; ACount: Integer);

    { Удаляет все теги и очищает счетчик id. }
    procedure Clear;
    procedure RemoveTag(ATag: TRecorderTag);

    property ActiveSourceCount: Integer read GetActiveSourceCount;
    property ActiveSourceIds[AIndex: Integer]: string read GetActiveSourceId;
    property EventBus: TRecorderEventBus read fEventBus write fEventBus;
    property SelectedTag: TRecorderTag read GetSelectedTag;
    property SelectedTagName: string read fSelectedTagName write fSelectedTagName;
    property TagCount: Integer read GetTagCount;
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

implementation

uses
  uRecorderDebugLog;

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
  fSignalBuffer := TRecorderSignalBuffer.Create(ACapacity);
end;

destructor TRecorderTag.Destroy;
begin
  fSignalBuffer.Free;
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
  SetLength(fTimes, 1);
  SetLength(fValues, 1);
  fTimes[0] := ATimeSec;
  fValues[0] := AValue;
end;

constructor TRecorderTagUpdateEventData.CreateBlock(ATag: TRecorderTag;
  const ATimes, AValues: array of Double; ACount: Integer);
var
  I: Integer;
begin
  inherited Create;
  if ACount <= 0 then
    raise ERecorderTagError.Create('Tag update block cannot be empty');
  if (ACount > Length(ATimes)) or (ACount > Length(AValues)) then
    raise ERecorderTagError.Create('Tag update block count exceeds data length');

  fTag := ATag;
  fSampleCount := ACount;
  SetLength(fTimes, ACount);
  SetLength(fValues, ACount);
  for I := 0 to ACount - 1 do
  begin
    fTimes[I] := ATimes[I];
    fValues[I] := AValues[I];
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
end;

destructor TRecorderTagRegistry.Destroy;
begin
  Clear;
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
begin
  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);

  lTag.AddSample(ATimeSec, AValue);

  if fEventBus <> nil then
  begin
    lEventData := TRecorderTagUpdateEventData.Create(lTag, ATimeSec, AValue);
    try
      lEvent := TRecorderEventBus.MakeEvent(rceDataUpdated, Self, lTag.Name,
        lTag.TextValue, 1, lEventData);
      fEventBus.Publish(lEvent);
    finally
      lEventData.Free;
    end;
  end;
end;

procedure TRecorderTagRegistry.PublishBlock(const ATagName: string; const ATimes,
  AValues: array of Double; ACount: Integer);
var
  lEvent: TRecorderEvent;
  lTag: TRecorderTag;
  lTimeSec: Double;
  lEventData: TRecorderTagUpdateEventData;
begin
  if ACount <= 0 then
    Exit;
  if (ACount > Length(ATimes)) or (ACount > Length(AValues)) then
    raise ERecorderTagError.Create('Publish block count exceeds data length');

  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);

  lTag.AddSamples(ATimes, AValues, ACount);
  lTimeSec := ATimes[ACount - 1];
  RecorderDebugLog(Format('Tag block: tag=%s count=%d first=%.6f last=%.6f bufferCount=%d bufferCapacity=%d',
    [lTag.Name, ACount, ATimes[0], lTimeSec, lTag.SignalBuffer.Count,
    lTag.SignalBuffer.Capacity]));

  if fEventBus <> nil then
  begin
    lEventData := TRecorderTagUpdateEventData.CreateBlock(lTag, ATimes, AValues, ACount);
    try
      lEvent := TRecorderEventBus.MakeEvent(rceDataUpdated, Self, lTag.Name,
        lTag.TextValue, ACount, lEventData);
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
  fSelectedTagName := '';
  fNextId := 1;
end;

end.
