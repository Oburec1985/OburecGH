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
  Classes, uCommonTypes, SyncObjs, Windows,  sysutils;

type
  // структура для настройки фильтра
  TFilterSettings = record
    // Коэффициент сглаживания (0 < Alpha <= 1)
    // вес следующего значения
    Alpha: Double;
    PrevOutput: Double;   // Предыдущее выходное значение
    IsFirstCall: Boolean; // Флаг первого вызова
  end;

  TDacDevice = class;

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
  protected
    FState: TDACState;
  private
    FLock: TRTLCriticalSection; // Объект для синхронизации потоков
    FOnBufferEnd: TNotifyEvent;
    FOnGenerateData: TNotifyEvent;
    FSampleRate: Cardinal;
    FBitsPerSample: Cardinal;
    // Количество каналов (1 - моно, 2 - стерео)
    FChannels: Cardinal;
    FBufferSizeMS: Cardinal;
    // номер устройства вывода в системе
    FDeviceID: Integer;
    FGeneratorThread: TDataGeneratorThread;
  PUBLIC
    name:string;
  protected
    // Обработчик события OnBufferEnd. Вызывается из TSoundCardDac,
    // когда буфер проигран.
    procedure DoBufferEnd(Sender: TObject);virtual;
    procedure setstate(s:TDACState);
    function getstate:TDACState;
  public
    constructor Create;
    destructor Destroy; override;
    procedure EnterCs;
    procedure ExitCs;
    // Открывает и инициализирует устройство
    function Open:cardinal; virtual; abstract;
    // Закрывает устройство и освобождает ресурсы
    procedure Close; virtual; abstract;
    // Начинает воспроизведение. ALoopCount=1 - однократно, >1 - N раз, 0 - бесконечно
    procedure Start(ALoopCount: Cardinal = 1); virtual;
    // Останавливает воспроизведение (плавно или мгновенно)
    procedure Stop(AGraceful: Boolean = True); virtual;
    // Ставит буфер с данными в очередь на воспроизведение
    procedure QueueBuffer(const ABuffer; ASize: Integer); virtual; abstract;
    // Проверяет, активно ли устройство в данный момент
    function IsPlay: Boolean; virtual; abstract;
    // Возвращает список доступных устройств вывода
    function GetDeviceList: TStringList; virtual; abstract;

    property SampleRate: Cardinal read FSampleRate write FSampleRate; // Частота дискретизации (Гц)
    property BitsPerSample: Cardinal read FBitsPerSample write FBitsPerSample; // Битность (8, 16, ...)
    // Количество каналов (1 - моно, 2 - стерео)
    property Channels: Cardinal read FChannels write FChannels;
    // Длительность буфера в мс
    property BufferSizeMS: Cardinal read FBufferSizeMS write FBufferSizeMS;
    //property OnBufferEnd: TNotifyEvent read FOnBufferEnd write FOnBufferEnd; // Событие, возникающее после окончания воспроизведения буфера
    property OnGenerateData: TNotifyEvent read FOnGenerateData write FOnGenerateData;
    // Идентификатор устройства для воспроизведения
    property DeviceID: Integer read FDeviceID write FDeviceID;
    property State: TDACState read getstate write setstate;
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

{ TDataGeneratorThread }

constructor TDataGeneratorThread.Create(ADacDevice: TDacDevice);
begin
  inherited Create(false);
  InitializeCriticalSection(cs);

  FDacDevice := ADacDevice;
  // Создаем событие, которое будет использоваться для пробуждения потока
  FBufferReadyEvent := TEvent.Create(nil, True, False, '');
end;

destructor TDataGeneratorThread.Destroy;
begin
  DeleteCriticalSection(cs);

  FBufferReadyEvent.Free;
  inherited;
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
      // Вызываем событие для генерации данных
      if Assigned(FDacDevice.OnGenerateData) then
        FDacDevice.OnGenerateData(FDacDevice);
      // Ждем, пока основной поток не сообщит, что буфер готов
      // doBufferEnd
      FBufferReadyEvent.WaitFor(INFINITE);
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

  FGeneratorThread := TDataGeneratorThread.Create(Self);
end;

destructor TDacDevice.Destroy;
begin
  Stop;
  DeleteCriticalSection(FLock);

  // Устанавливаем флаг Terminated в True. Поток должен периодически
  // проверять этот флаг и корректно завершать свою работу.
  FGeneratorThread.Terminate;
  // Сигнализируем событие, чтобы вывести поток из состояния ожидания
  // (FBufferReadyEvent.WaitFor). Это необходимо, чтобы поток мог
  // проверить флаг Terminated и завершиться.
  FGeneratorThread.BufferReadyEvent.SetEvent; // Пробуждаем поток, чтобы он мог завершиться
  // Ожидаем полного завершения потока. Это блокирующая операция.
  FGeneratorThread.WaitFor;
  // Ожидаем полного завершения потока и освобождаем память.
  FreeAndNil(FGeneratorThread);
  inherited;
end;

procedure TDacDevice.Start(ALoopCount: Cardinal = 1);
begin
  if IsPlay then Exit;
  State:=stPlay;
  // Создаем и запускаем поток для генерации данных
  // Назначаем обработчик события окончания буфера
  //OnBufferEnd := DoBufferEnd;

  // тут падает
  FGeneratorThread.state:=true;
end;

procedure TDacDevice.DoBufferEnd(Sender: TObject);
begin
  // Сообщаем потоку, что буфер готов для заполнения
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

function TDacDevice.getstate: TDACState;
begin
  entercs;
  result:=FState;
  exitcs;
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

end;

end.
