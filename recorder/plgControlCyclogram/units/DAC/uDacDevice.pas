unit uDacDevice;

{******************************************************************************
 * Модуль абстрактного класса ЦАП (uDacDevice.pas)
 *------------------------------------------------------------------------------
 * НАЗНАЧЕНИЕ:
 *   Этот модуль определяет "контракт" или интерфейс для всех классов,
 *   реализующих управление Цифро-Аналоговым Преобразователем (ЦАП).
 *   Он использует абстрактные виртуальные методы, чтобы заставить классы-
 *   наследники (например, TSoundCardDac) реализовать всю необходимую
 *   функциональность.
 *
 * КЛЮЧЕВОЙ ЭЛЕМЕНТ:
 *   Событие OnBufferEnd является основой для создания потоковых ("streaming")
 *   систем, позволяя приложению подавать данные в ЦАП непрерывно по мере
 *   их воспроизведения.
 *****************************************************************************}

interface

uses
  Classes, uCommonTypes, SyncObjs, Windows,  sysutils, uDacVectorTagMirror;

type
  TDacData = record
    fTransportDeviceIndex: Integer;
    fTransportSampleRate: Cardinal;
    fTransportBitsPerSample: Cardinal;
    fTransportChannels: Cardinal;
    fTransportBufferSizeMS: Cardinal;
  end;

  // P - массив данных для ЦАП
  TOnBufferEnd = procedure (P: Pointer; Size: Integer) of object;

  // структура для настройки фильтра
  TFilterSettings = record
    // Коэффициент сглаживания (0 < Alpha <= 1)
    // вес следующего значения
    Alpha: Double;
    PrevOutput: Double;   // Предыдущее выходное значение
    IsFirstCall: Boolean; // Ф4лаг первого вызова
  end;

  TDacDevice = class;

  { TBlockQueue }
  (*
    Класс TBlockQueue реализует потокобезопасную циклическую очередь
    для управления указателями на блоки данных.
    Основные характеристики:
    - Универсальность: Хранит универсальные указатели (Pointer), позволяя
      использовать любые структуры данных для блоков.
    - Управление памятью: Класс не владеет памятью блоков данных,
      он только управляет указателями. Создание и освобождение памяти
      является ответственностью пользователя класса.
    - Перезапись при переполнении: При добавлении элемента в полную очередь
      самый старый элемент перезаписывается.
    - Отложенное удаление: Блоки не удаляются из очереди немедленно,
      а помечаются как "удаленные".
  *)
  TBlockData = record
    // Универсальный указатель на структуру данных блока
    Data: Pointer;
    // номер блока (аналог времени)
    index:integer;
    // время блока
    timestamp:double;
  end;
  PBlockData = ^TBlockData;

  TBlockQueue = class
  private
    FBlocks: array of TBlockData; // Массив для хранения указателей и их состояния
    FMaxBlocks: Cardinal;         // Максимальное количество блоков
    FBlockCount: Cardinal;        // Сколько лежит блоков
    FWriteIndex: Integer;          // Индекс последнего записанного
    FReadIndex: Integer;          // самый старый/ он же начало очереди
    FReadyBlocks:integer; // сколько всего положили
    FCs: TRTLCriticalSection;
  public
    // Метод для получения индекса блока по указателю (-1 если не найден)
    function GetBlockIndex(ADataPtr: Pointer): Integer;
  public
    // Конструктор: инициализирует очередь с заданным количеством блоков
    constructor Create(AMaxBlocks: Cardinal);
    // Деструктор
    destructor Destroy; override;
    // Очищает очередь без пересоздания. Память блоков не освобождается.
    procedure Clear;
    // Публичные свойства для доступа к внутренним данным
    property MaxBlocks: Cardinal read FMaxBlocks;
    // Метод для получения доступа к блоку по индексу
    function GetBlockData(AIndex: Integer): PBlockData;
    // извлечь блок из очереди
    function PopBlock: PBlockData;
    // вернуть ссылку на блок который хотим запушить. Меняет индексы в очереди
    // как будто положили новый блок
    function GetPushBlock:PBlockData;
  end;

  // Поток для генерации данных в фоновом режиме
  TDataGeneratorThread = class(TThread)
  private
    FDacDevice: TDacDevice;
    // Событие для синхронизации потоков. Поток ждет этого
    // события перед генерацией следующего блока.
    FBufferReadyEvent: TEvent;
    fstate:boolean;
    cs:TRTLCriticalSection;
  protected
    procedure Execute; override;
    function getstate:boolean;
    procedure setstate(s:boolean);
  public
    constructor Create(ADacDevice: TDacDevice);
    destructor Destroy; override;
    // проигрывается
    property state:boolean read getstate write setstate;
    property BufferReadyEvent: TEvent read FBufferReadyEvent;
  end;

  TDACState = (stClosed, // устройство не инициализировано
               stOpened, // устройство инициализировано
               stPlay); // устройство проигнрывает данные

  TDacDevice = class(TObject)
  private
    FBufferSize: Cardinal;        // Размер одного буфера в байтах
  protected
    FState: TDACState;
    FOnGenerateData: tNotifyEvent; // Событие генерации данных (передает буфер)
    FBlockQueue: TBlockQueue;     // Очередь блоков данных
    FOnBufferEnd: TOnBufferEnd;
  private
    FLock: TRTLCriticalSection; // Объект для синхронизации потоков
    FSampleRate: Cardinal;
    FBitsPerSample: Cardinal;
    // Количество каналов (1 - моно, 2 - стерео)
    FChannels: Cardinal;
    FBufferSizeMS: Cardinal;
    // номер устройства вывода в системе
    FDeviceID: Integer;
    FGeneratorThread: TDataGeneratorThread;
    FVectorMirror: TDacVectorTagMirror;
    FVectorTagEnabled: Boolean;
    FVectorTagName: string;
  PUBLIC
    name:string;
    // Очередь блоков данных (публичный доступ для программ)
    property BlockQueue: TBlockQueue read FBlockQueue;
  protected
    // Обработчик события OnBufferEnd. Вызывается из TSoundCardDac,
    // когда буфер проигран.
    procedure DoBufferEnd(Sender: TObject);virtual;
    procedure setstate(s:TDACState);
    function getstate:TDACState;
    // Рассчитывает размер буфера в байтах
    procedure CalculateBufferSize; virtual;
    // Выделяет память для одного блока данных, специфичного для реализации ЦАП
    function AllocateBlock: Pointer; virtual; abstract;
    // Освобождает память, выделенную для блока данных
    procedure FreeBlock(ABlock: Pointer); virtual; abstract;
    // Получает индекс блока по указателю (-1 если не найден)
    function GetBlockIndex(ADataPtr: Pointer): Integer;
    procedure setBufferSize(c:cardinal);
    function PrepareVectorTag: Boolean; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure EnterCs;
    procedure ExitCs;
    // Очищает очередь блоков без пересоздания. Память блоков не освобождается.
    procedure ClearBlocks;
    // Освобождает память всех блоков в очереди
    procedure FreeAllBlocks;
    // Открывает и инициализирует устройство
    function Open:cardinal; virtual; abstract;
    // Закрывает устройство и освобождает ресурсы
    procedure Close; virtual; abstract;
    // Начинает воспроизведение. ALoopCount=1 - однократно, >1 - N раз, 0 - бесконечно
    procedure Start(ALoopCount: Cardinal = 1); virtual;
    // Останавливает воспроизведение (плавно или мгновенно)
    procedure Stop(AGraceful: Boolean = True); virtual;
    // поставить буфер в очередь
    procedure AddBuffer(ABuffer:pointer; ASize: Integer); virtual; abstract;
    // Ставит буфер с данными в очередь на воспроизведение
    function QueueBuffer:PBlockData; virtual; abstract;
    // Проверяет, активно ли устройство в данный момент
    function IsPlay: Boolean; virtual; abstract;
    // Возвращает список доступных устройств вывода
    function GetDeviceList: TStringList; virtual; abstract;
    // Перевыделяет буферы с новым размером (виртуальный метод)
    procedure ReallocateBuffers(NewSize: Integer); virtual;
    procedure ApplyData(d:tdacdata);
    function UpdateVectorTag: Boolean;
    procedure ResetVectorTagTime;
    function WriteVectorSamples(ASamples: Pointer; ACount: Integer): Boolean;
  public

    property SampleRate: Cardinal read FSampleRate write FSampleRate; // Частота дискретизации (Гц)
    property BitsPerSample: Cardinal read FBitsPerSample write FBitsPerSample; // Битность (8, 16, ...)
    // Количество каналов (1 - моно, 2 - стерео)
    property Channels: Cardinal read FChannels write FChannels;
    // Длительность буфера в мс
    property BufferSizeMS: Cardinal read FBufferSizeMS write FBufferSizeMS;
    // Размер одного буфера в байтах
    property BufferSize: Cardinal read FBufferSize write setBufferSize;
    property OnBufferEnd: TOnBufferEnd read FOnBufferEnd write FOnBufferEnd;
    // Событие генерации данных (передает буфер: P-указатель, Size-размер в байтах)
    property OnGenerateData: TnotifyEvent read FOnGenerateData write FOnGenerateData;
    // Идентификатор устройства для воспроизведения
    property DeviceID: Integer read FDeviceID write FDeviceID;
    property State: TDACState read getstate write setstate;
    property VectorTagEnabled: Boolean read FVectorTagEnabled write FVectorTagEnabled;
    property VectorTagName: string read FVectorTagName write FVectorTagName;
  end;

  // тестовые функции для отработки ЦАП
  function LowPassFilter(const Input: tdoublearray; var Settings: TFilterSettings): tdoublearray;

  const
    NUM_BUFFERS = 4; // Количество используемых буферов

implementation

function LowPassFilter(const Input: tdoublearray; var Settings: TFilterSettings): tdoublearray;
var
  i, l: Integer;
begin
  SetLength(Result, Length(Input));

  l:=Length(Input);
  if l = 0 then
    Exit;

  // Инициализация при первом вызове
  if Settings.IsFirstCall then
  begin
    Settings.PrevOutput := Input[0];
    Settings.IsFirstCall := False;
  end;

  for i := 0 to l-1 do
  begin
    // Рекуррентная формула ФНЧ
    Result[i] := Settings.Alpha * Input[i] + (1 - Settings.Alpha) * Settings.PrevOutput;
    Settings.PrevOutput := Result[i];
  end;
end;

{ TBlockQueue }

constructor TBlockQueue.Create(AMaxBlocks: Cardinal);
var
  i: Integer;
begin
  inherited Create;
  InitializeCriticalSection(FCs);

  FMaxBlocks := AMaxBlocks;
  FWriteIndex := 0;
  FReadIndex := 0;

  // Выделяем память под массив структур TBlockData
  SetLength(FBlocks, FMaxBlocks);

  // Инициализируем состояние блоков
  for i := 0 to FMaxBlocks - 1 do
  begin
    FBlocks[i].Data := nil;
  end;
end;

destructor TBlockQueue.Destroy;
begin
  // Память, на которую указывают FBlocks[i].Data, здесь не освобождается,
  // так как класс TBlockQueue не является ее владельцем.
  DeleteCriticalSection(FCs);
  inherited;
end;

function TBlockQueue.GetBlockData(AIndex: Integer): PBlockData;
begin
  EnterCriticalSection(FCs);
  try
    if (AIndex >= 0) and (AIndex < FMaxBlocks) then
      Result := @FBlocks[AIndex]
    else
      Result := nil;
  finally
    LeaveCriticalSection(FCs);
  end;
end;

function TBlockQueue.GetBlockIndex(ADataPtr: Pointer): Integer;
var
  i: Integer;
begin
  Result := -1;
  if ADataPtr = nil then
    Exit;
    
  EnterCriticalSection(FCs);
  try
    for i := 0 to FMaxBlocks - 1 do
    begin
      if FBlocks[i].Data = ADataPtr then
      begin
        Result := i;
        Exit;
      end;
    end;
  finally
    LeaveCriticalSection(FCs);
  end;
end;

function TBlockQueue.PopBlock: PBlockData;
var
  bl:PBlockData;
  oldest:integer;
begin
  EnterCriticalSection(FCs);
  // очередь пуста
  if FBlockCount=0 then
  begin
    result:=nil;
    exit;
  end;
  bl:=GetBlockData(FReadIndex);
  result:=bl;
  // 2. Сдвигаем индекс чтения вперед (по кругу)
  FReadIndex := (FReadIndex + 1) mod FMaxBlocks;
  // 3. Уменьшаем счетчик
  Dec(FBlockCount);
  LeaveCriticalSection(FCs);
end;

function TBlockQueue.GetPushBlock: PBlockData;
var
  bl:pBlockData;
begin
  result:=nil;
  EnterCriticalSection(FCs);
  try
    // Если очередь полна, мы "жертвуем" самым старым блоком
    if FBlockCount >= FMaxBlocks then
    begin
      // Сдвигаем индекс чтения вперед, как будто мы прочитали старый блок
      FReadIndex := (FReadIndex + 1) mod FMaxBlocks;
      // Счетчик не увеличиваем, так как один блок ушел, один пришел
    end
    else
    begin
      // Если место есть, просто увеличиваем счетчик
      Inc(FBlockCount);
    end;
    bl:=GetBlockData(FWriteIndex);
    result:=bl;
    // Записываем новый блок в текущую позицию записи
    // (Предполагается, что массив/список блоков уже инициализирован до FMaxBlocks)
    // Сдвигаем индекс записи вперед
    FWriteIndex := (FWriteIndex + 1) mod FMaxBlocks;
    Inc(FReadyBlocks);
  finally
    LeaveCriticalSection(FCs);
  end;
end;

{ TDataGeneratorThread }

constructor TDataGeneratorThread.Create(ADacDevice: TDacDevice);
begin
  inherited Create(false);
  InitializeCriticalSection(cs);

  FDacDevice := ADacDevice;
  // Создаем событие, которое будет использоваться для пробуждения потока
  //                                      bManualReset = true
  FBufferReadyEvent := TEvent.Create(nil, True, False, '');
end;

destructor TDataGeneratorThread.Destroy;
begin
  Terminate;
  setstate(true); // Гарантированно пробуждаем поток, чтобы он мог выйти из цикла Execute
  inherited;
  DeleteCriticalSection(cs);
  FBufferReadyEvent.Free;
end;

procedure TDataGeneratorThread.Execute;
begin
  // Основной цикл потока
  while not Terminated do
  begin
    if not state then
    begin
      suspend;
    end
    else
    begin
      // Проверяем состояние устройства - генерируем только если play
      if Assigned(FDacDevice) and (FDacDevice.State = stPlay) then
      begin
        // Вызываем событие для генерации данных (nil, 0 - данные не передаются)
        if Assigned(FDacDevice.OnGenerateData) then
          FDacDevice.OnGenerateData(nil);
      end;
      sleep(100);
    end;
  end;
end;

function TDataGeneratorThread.getstate: boolean;
begin
  EnterCriticalSection(cs);
  result:=fstate;
  LeaveCriticalSection(cs);
end;

procedure TDataGeneratorThread.setstate(s: boolean);
begin
  EnterCriticalSection(cs);
  fstate:=s;
  if s then
    Resume();
  LeaveCriticalSection(cs);
end;

{ TDacDevice }

procedure TDacDevice.CalculateBufferSize;
begin
  // Расчет размера буфера в байтах
  FBufferSize := round(FSampleRate * FBufferSizeMS / 1000) * (FChannels * FBitsPerSample div 8);
  // Проверка на случай, если результат нулевой
  if FBufferSize = 0 then FBufferSize := 4096;
end;

constructor TDacDevice.Create;
begin
  inherited;
  FState:=stClosed;
  InitializeCriticalSection(FLock);
  FSampleRate := 44100;
  FBitsPerSample := 16;
  FChannels := 1;
  FBufferSizeMS := 100; // Default buffer size
  FDeviceID := -1; // WAVE_MAPPER

  FBlockQueue := TBlockQueue.Create(NUM_BUFFERS);
  FVectorMirror := TDacVectorTagMirror.Create;
  FVectorTagEnabled := False;
  FVectorTagName := ''; 
  FGeneratorThread := TDataGeneratorThread.Create(Self);
end;

destructor TDacDevice.Destroy;
begin
  Stop;

  // ПОРЯДОК ВАЖЕН: сначала завершаем поток, пока жива критическая секция устройства
  if Assigned(FGeneratorThread) then
  begin
    FGeneratorThread.Terminate;
    FGeneratorThread.state := true; // Пробуждаем поток, чтобы он мог выйти из цикла Execute
    FreeAndNil(FGeneratorThread);   // Вызывает деструктор потока и ждет завершения
  end;

  // Теперь безопасно удаляем критическую секцию самого устройства
  DeleteCriticalSection(FLock);
  FreeAndNil(FVectorMirror);
  FBlockQueue.Free;

  inherited;
end;

procedure TDacDevice.Start(ALoopCount: Cardinal = 1);
begin
  if IsPlay then Exit;
  State:=stPlay;
  // сброс очереди
  FBlockQueue.Clear;
  // тут падает
  FGeneratorThread.state:=true;
  // обнуляем счетчик блоков
end;

procedure TDacDevice.DoBufferEnd(Sender: TObject);
begin
  // Сообщаем потоку, что буфер доигран, готов для заполнения
  FGeneratorThread.BufferReadyEvent.SetEvent;
end;

procedure TDacDevice.EnterCs;
begin
  EnterCriticalSection(FLock);
end;

procedure TDacDevice.ExitCs;
begin
  LeaveCriticalSection(FLock);
end;

procedure TBlockQueue.Clear;
var
  i: Integer;
begin
  EnterCriticalSection(FCs);
  try
    // Сбрасываем все указатели и помечаем блоки как удаленные
    for i := 0 to FMaxBlocks - 1 do
    begin
      FBlocks[i].index := 0; // индекс блока аналог времени
      FBlocks[i].timestamp := 0;
    end;
    // Сбрасываем индексы
    FWriteIndex := 0;
    FReadIndex := 0;
    FReadyBlocks:=0;
  finally
    LeaveCriticalSection(FCs);
  end;
end;


procedure TDacDevice.ClearBlocks;
var
  block: Pointer;
begin
  // Очищаем очередь блоков. Память блоков не освобождается.
  FBlockQueue.Clear;
end;

procedure TDacDevice.FreeAllBlocks;
var
  block: Pointer;
  b:pBlockData;
  I: Integer;
begin
  for I := 0 to FBlockQueue.MaxBlocks - 1 do
  begin
    b:=FBlockQueue.GetBlockData(i);
    if b.Data<>nil then
    begin
      FreeBlock(block);
      b.Data:=nil;
    end;
  end;
end;

function TDacDevice.GetBlockIndex(ADataPtr: Pointer): Integer;
begin
  if Assigned(FBlockQueue) then
    Result := FBlockQueue.GetBlockIndex(ADataPtr)
  else
    Result := -1;
end;

function TDacDevice.getstate: TDACState;
begin
  entercs;
  result:=FState;
  exitcs;
end;


procedure TDacDevice.setBufferSize(c: cardinal);
begin
  FBufferSize:=c;
end;

procedure TDacDevice.setstate(s: TDACState);
begin
  entercs;
  FState:=s;
  exitcs;
end;

procedure TDacDevice.Stop(AGraceful: Boolean = True);
begin
  // Если ЦАП не в режиме воспроизведения, то выходим.
  if not IsPlay then Exit;
  // Останавливаем поток генерации данных
  FGeneratorThread.state:=false;
  case Fstate of
    stClosed: FState:=stClosed;
    stOpened:
    begin
      FState:=stOpened;
    end;
    stPlay: FState:=stOpened;
  end;
end;

procedure TDacDevice.ReallocateBuffers(NewSize: Integer);
begin
  // Базовая реализация - выбрасывает исключение
  // Наследники должны переопределить этот метод
  raise Exception.Create('ReallocateBuffers not implemented in base class');
end;

function TDacDevice.PrepareVectorTag: Boolean;
var
  lTagName: string;
begin
  Result := False;
  if not FVectorTagEnabled then
    Exit;

  lTagName := Trim(FVectorTagName);
  if lTagName = '' then
    lTagName := Format('DAC_%d', [DeviceID]);

  if lTagName = '' then
    Exit;

  Result := FVectorMirror.Configure(lTagName, SampleRate);
end;

function TDacDevice.UpdateVectorTag: Boolean;
begin
  Result := PrepareVectorTag;
end;

procedure TDacDevice.ResetVectorTagTime;
begin
  FVectorMirror.ResetWriteTime;
end;

function TDacDevice.WriteVectorSamples(ASamples: Pointer; ACount: Integer): Boolean;
begin
  Result := PrepareVectorTag and FVectorMirror.WriteSamples(ASamples, ACount);
end;
procedure TDacDevice.ApplyData(d: tdacdata);
begin
  SampleRate := d.fTransportSampleRate;
  BitsPerSample := d.fTransportBitsPerSample;
  Channels := d.fTransportChannels;
  BufferSizeMS := d.fTransportBufferSizeMS;
  DeviceID := d.fTransportDeviceIndex;
end;

end.
