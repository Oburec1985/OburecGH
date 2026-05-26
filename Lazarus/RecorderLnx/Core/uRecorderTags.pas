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

  { Снимок сигнального буфера.

    Count  - число валидных точек.
    Times  - времена точек в секундах.
    Values - значения точек. Индексы совпадают с Times. }
  TRecorderSignalSnapshot = record
    Count: Integer;
    Times: array of Double;
    Values: array of Double;
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

    { Возвращает снимок от старой точки к новой. }
    function Snapshot: TRecorderSignalSnapshot;

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
    fId: TRecorderTagId;
    fName: string;
    fSignalBuffer: TRecorderSignalBuffer;
    fSourceId: string;
    fTextValue: string;
    fUnitName: string;
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

    { Возвращает снимок сигнала тега. }
    function Snapshot: TRecorderSignalSnapshot;

    property Id: TRecorderTagId read fId;
    property Name: string read fName write fName;
    property Address: string read fAddress write fAddress;
    property UnitName: string read fUnitName write fUnitName;
    property Description: string read fDescription write fDescription;
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

    { Удаляет все теги и очищает счетчик id. }
    procedure Clear;

    property EventBus: TRecorderEventBus read fEventBus write fEventBus;
    property TagCount: Integer read GetTagCount;
    property Tags[AIndex: Integer]: TRecorderTag read GetTag;
  end;

implementation

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

{ TRecorderTag }

constructor TRecorderTag.Create(AId: TRecorderTagId; const AName: string;
  ACapacity: Integer);
begin
  inherited Create;
  if AName = '' then
    raise ERecorderTagError.Create('Tag name cannot be empty');

  fId := AId;
  fName := AName;
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

function TRecorderTag.Snapshot: TRecorderSignalSnapshot;
begin
  Result := fSignalBuffer.Snapshot;
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
