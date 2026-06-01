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
  TRecorderTagId = Int64;
  TRecorderDoubleArray = array of Double;
  TRecorderTagEstimateKind = (
    tekMean,
    tekRmsValue,
    tekRmsDeviation,
    tekPeak,
    tekPeakToPeak,
    tekMinimum,
    tekMaximum,
    tekPeakToPeakByRmsDeviation,
    tekLastValue
  );

  TRecorderTagEstimate = record
    Kind: TRecorderTagEstimateKind;
    Valid: Boolean;
    Count: Integer;
    StartTimeSec: Double;
    EndTimeSec: Double;
    Value: Double;
  end;

  { Persistent calculation settings for a tag.

    EnabledKinds     - estimates selected on the "Additional" tab.
    DefaultKind      - estimate used as the main displayed/calculated value.
    PortionLength    - sample count used by batch estimate calculations.
    SmoothingEnabled - enables y'=kx+(1-k)y smoothing.
    SmoothingK       - smoothing coefficient k.
    ScadaEnabled     - marks the tag as exported/visible for SCADA workflows. }
  TRecorderTagEstimateSettings = record
    EnabledKinds: array[TRecorderTagEstimateKind] of Boolean;
    DefaultKind: TRecorderTagEstimateKind;
    PortionLength: Integer;
    SmoothingEnabled: Boolean;
    SmoothingK: Double;
    ScadaEnabled: Boolean;
  end;

  TRecorderTagSetpointKind = (
    tskHighAlarm,
    tskHighWarning,
    tskLowWarning,
    tskLowAlarm
  );

  { Persistent limit/alarm settings for one setpoint row.

    The original Recorder dialog stores more routing details for "Record",
    "Sound", and "Take from". RecorderLnx keeps the visible core state now and
    leaves integration-specific routing for the later recorder backend. }
  TRecorderTagSetpoint = record
    Enabled: Boolean;
    Threshold: Double;
    Color: LongInt;
    OutputEnabled: Boolean;
    HysteresisPercent: Double;
  end;

  { Снимок сигнального буфера.

    Count  - число валидных точек.
    Times  - времена точек в секундах.
    Values - значения точек. Индексы совпадают с Times. }
  TRecorderSignalSnapshot = record
    Count: Integer;
    Times: TRecorderDoubleArray;
    Values: TRecorderDoubleArray;
  end;

  ERecorderTagError = class(Exception);

  { TRecorderSignalBuffer

    Потокобезопасный кольцевой буфер значений одного тега. Буфер выделяет память
    при создании и дальше переиспользует ее при добавлении sample-ов. Снимок
    копирует данные в динамические массивы вызывающего кода. }
  TRecorderSignalBuffer = class
  private
    fCapacity: Integer;
    fCount: Integer;
    fLock: TRTLCriticalSection;
    fStart: Integer;
    fLastBlockCount: Integer;
    fLastBlockTimes: TRecorderDoubleArray;
    fLastBlockValues: TRecorderDoubleArray;
    fTimes: array of Double;
    fValues: array of Double;
    function GetLatestTime: Double;
    function GetLatestValue: Double;
  public
    { ACapacity - максимальное число точек в кольцевом буфере. }
    constructor Create(ACapacity: Integer);
    destructor Destroy; override;

    { Очищает буфер без освобождения выделенных массивов. }
    procedure Clear;

    { Добавляет одну точку в буфер.

      ATimeSec - время точки в секундах.
      AValue   - значение точки. }
    procedure AddSample(ATimeSec, AValue: Double);
    procedure AddSamples(const ATimes, AValues: array of Double; ACount: Integer);

    { Возвращает снимок от старой точки к новой. }
    function Snapshot: TRecorderSignalSnapshot;
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
    fAddress: string;
    fDescription: string;
    fAutoRange: Boolean;
    fAutoUnit: Boolean;
    fId: TRecorderTagId;
    fEstimateSettings: TRecorderTagEstimateSettings;
    fModuleType: string;
    fName: string;
    fPollFrequencyHz: Double;
    fRangeMax: Double;
    fRangeMin: Double;
    fSignalBuffer: TRecorderSignalBuffer;
    fSourceId: string;
    fSetpointHysteresisEnabled: Boolean;
    fSetpointSoundUntilEnd: Boolean;
    fSetpointStatusChannelEnabled: Boolean;
    fSetpointStatusChannelName: string;
    fSetpoints: array[TRecorderTagSetpointKind] of TRecorderTagSetpoint;
    fTextValue: string;
    fUnitName: string;
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
    destructor Destroy; override;

    { Добавляет числовое значение в буфер тега. }
    procedure AddSample(ATimeSec, AValue: Double);
    procedure AddSamples(const ATimes, AValues: array of Double; ACount: Integer);

    { Возвращает снимок сигнала тега. }
    function Snapshot: TRecorderSignalSnapshot;
    function LastBlockSnapshot: TRecorderSignalSnapshot;
    function Estimate(AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;

    property Id: TRecorderTagId read fId;
    property Name: string read fName write fName;
    property Address: string read fAddress write fAddress;
    property UnitName: string read fUnitName write fUnitName;
    property Description: string read fDescription write fDescription;
    property PollFrequencyHz: Double read fPollFrequencyHz write fPollFrequencyHz;
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

  { Данные события обновления тега.

    Объект передается через TRecorderEvent.Data. Владение объектом остается у
    TRecorderTagRegistry, поэтому обработчики события не должны его освобождать. }
  TRecorderTagUpdateEventData = class
  private
    fTag: TRecorderTag;
    fTimeSec: Double;
    fValue: Double;
  public
    constructor Create(ATag: TRecorderTag; ATimeSec, AValue: Double);
    property Tag: TRecorderTag read fTag;
    property TimeSec: Double read fTimeSec;
    property Value: Double read fValue;
  end;

  { TRecorderTagRegistry

    Реестр тегов RecorderLnx. Владеет тегами, обеспечивает уникальность id/name и
    публикует rceDataUpdated при записи значения. }
  TRecorderTagRegistry = class
  private
    fEventBus: TRecorderEventBus;
    fLastUpdateData: TRecorderTagUpdateEventData;
    fNextId: TRecorderTagId;
    fTags: TList;
    function GetTag(AIndex: Integer): TRecorderTag;
    function GetTagCount: Integer;
  public
    { AEventBus - шина событий. Владение не передается, может быть nil. }
    constructor Create(AEventBus: TRecorderEventBus = nil);
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

    { Публикует новое значение тега и отправляет событие rceDataUpdated. }
    procedure PublishValue(const ATagName: string; ATimeSec, AValue: Double);
    procedure PublishBlock(const ATagName: string; const ATimes,
      AValues: array of Double; ACount: Integer);

    { Удаляет все теги и очищает счетчик id. }
    procedure Clear;

    property EventBus: TRecorderEventBus read fEventBus write fEventBus;
    property TagCount: Integer read GetTagCount;
    property Tags[AIndex: Integer]: TRecorderTag read GetTag;
  end;

function RecorderTagEstimateKindToShortName(AKind: TRecorderTagEstimateKind): string;
function RecorderTagEstimateKindToName(AKind: TRecorderTagEstimateKind): string;
function CalculateRecorderTagEstimate(const ASnapshot: TRecorderSignalSnapshot;
  AKind: TRecorderTagEstimateKind): TRecorderTagEstimate;

implementation

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
var
  I: Integer;
  lMean: Extended;
  lMin: Double;
  lMax: Double;
  lSum: Extended;
  lVarianceSum: Extended;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Kind := AKind;
  Result.Count := ASnapshot.Count;
  if ASnapshot.Count <= 0 then
    Exit;

  Result.Valid := True;
  Result.StartTimeSec := ASnapshot.Times[0];
  Result.EndTimeSec := ASnapshot.Times[ASnapshot.Count - 1];

  lMin := ASnapshot.Values[0];
  lMax := ASnapshot.Values[0];
  lSum := 0.0;
  for I := 0 to ASnapshot.Count - 1 do
  begin
    lSum := lSum + ASnapshot.Values[I];
    if ASnapshot.Values[I] < lMin then
      lMin := ASnapshot.Values[I];
    if ASnapshot.Values[I] > lMax then
      lMax := ASnapshot.Values[I];
  end;
  lMean := lSum / ASnapshot.Count;

  case AKind of
    tekMean:
      Result.Value := lMean;
    tekRmsValue:
      begin
        lSum := 0.0;
        for I := 0 to ASnapshot.Count - 1 do
          lSum := lSum + ASnapshot.Values[I] * ASnapshot.Values[I];
        Result.Value := Sqrt(lSum / ASnapshot.Count);
      end;
    tekRmsDeviation:
      begin
        if ASnapshot.Count = 1 then
          Result.Value := 0.0
        else
        begin
          lVarianceSum := 0.0;
          for I := 0 to ASnapshot.Count - 1 do
            lVarianceSum := lVarianceSum + Sqr(ASnapshot.Values[I] - lMean);
          Result.Value := Sqrt(lVarianceSum / (ASnapshot.Count - 1));
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
        if ASnapshot.Count = 1 then
          Result.Value := 0.0
        else
        begin
          lVarianceSum := 0.0;
          for I := 0 to ASnapshot.Count - 1 do
            lVarianceSum := lVarianceSum + Sqr(ASnapshot.Values[I] - lMean);
          Result.Value := 2.0 * Sqrt(2.0) *
            Sqrt(lVarianceSum / (ASnapshot.Count - 1));
        end;
      end;
    tekLastValue:
      Result.Value := ASnapshot.Values[ASnapshot.Count - 1];
  end;
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
      { При заполненном буфере затираем самую старую точку и сдвигаем начало.
        Это сохраняет последние Capacity точек без выделения памяти. }
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
      fLastBlockTimes[I] := ATimes[I];
      fLastBlockValues[I] := AValues[I];
    end;
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

    for I := 0 to fLastBlockCount - 1 do
    begin
      Result.Times[I] := fLastBlockTimes[I];
      Result.Values[I] := fLastBlockValues[I];
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
end;

{ TRecorderTagRegistry }

constructor TRecorderTagRegistry.Create(AEventBus: TRecorderEventBus);
begin
  inherited Create;
  fEventBus := AEventBus;
  fTags := TList.Create;
  fNextId := 1;
end;

destructor TRecorderTagRegistry.Destroy;
begin
  Clear;
  fLastUpdateData.Free;
  fTags.Free;
  inherited Destroy;
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

procedure TRecorderTagRegistry.PublishValue(const ATagName: string; ATimeSec,
  AValue: Double);
var
  lEvent: TRecorderEvent;
  lTag: TRecorderTag;
begin
  lTag := FindByName(ATagName);
  if lTag = nil then
    raise ERecorderTagError.CreateFmt('Tag not found: %s', [ATagName]);

  lTag.AddSample(ATimeSec, AValue);

  if fEventBus <> nil then
  begin
    { Переиспользуем один объект данных события, чтобы не выделять память на
      каждое обновление тега. Обработчики не должны сохранять ссылку надолго. }
    fLastUpdateData.Free;
    fLastUpdateData := TRecorderTagUpdateEventData.Create(lTag, ATimeSec, AValue);
    lEvent := TRecorderEventBus.MakeEvent(rceDataUpdated, Self, lTag.Name,
      lTag.TextValue, 1, fLastUpdateData);
    fEventBus.Publish(lEvent);
  end;
end;

procedure TRecorderTagRegistry.PublishBlock(const ATagName: string; const ATimes,
  AValues: array of Double; ACount: Integer);
var
  lEvent: TRecorderEvent;
  lTag: TRecorderTag;
  lTimeSec: Double;
  lValue: Double;
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
  lValue := AValues[ACount - 1];

  if fEventBus <> nil then
  begin
    fLastUpdateData.Free;
    fLastUpdateData := TRecorderTagUpdateEventData.Create(lTag, lTimeSec, lValue);
    lEvent := TRecorderEventBus.MakeEvent(rceDataUpdated, Self, lTag.Name,
      lTag.TextValue, ACount, fLastUpdateData);
    fEventBus.Publish(lEvent);
  end;
end;

procedure TRecorderTagRegistry.Clear;
var
  I: Integer;
begin
  for I := 0 to fTags.Count - 1 do
    TObject(fTags[I]).Free;
  fTags.Clear;
  fNextId := 1;
end;

end.
