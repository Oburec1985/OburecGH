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
  Classes, uhardwaremath, SyncObjs;

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
    // Событие для синхронизации потоков. Поток ждет этого события перед генерацией следующего блока.
    FBufferReadyEvent: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(ADacDevice: TDacDevice);
    destructor Destroy; override;
    property BufferReadyEvent: TEvent read FBufferReadyEvent;
  end;

  TDacDevice = class(TObject)
  private
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
    // Обработчик события OnBufferEnd. Вызывается из TSoundCardDac, когда буфер проигран.
    procedure DoBufferEnd(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;

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
    function IsActive: Boolean; virtual; abstract;
    // Возвращает список доступных устройств вывода
    function GetDeviceList: TStringList; virtual; abstract;

    property SampleRate: Cardinal read FSampleRate write FSampleRate; // Частота дискретизации (Гц)
    property BitsPerSample: Cardinal read FBitsPerSample write FBitsPerSample; // Битность (8, 16, ...)
    property Channels: Cardinal read FChannels write FChannels; // Количество каналов (1 - моно, 2 - стерео)
    property BufferSizeMS: Cardinal read FBufferSizeMS write FBufferSizeMS; // Длительность буфера в мс
    property OnBufferEnd: TNotifyEvent read FOnBufferEnd write FOnBufferEnd; // Событие, возникающее после окончания воспроизведения буфера
    property OnGenerateData: TNotifyEvent read FOnGenerateData write FOnGenerateData;
    // Идентификатор устройства для воспроизведения
    property DeviceID: Integer read FDeviceID write FDeviceID;
  end;

  // тестовые функции для отработки ЦАП
  function LowPassFilter(const Input: tdoublearray; var Settings: TFilterSettings): tdoublearray;


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
  inherited Create(False);
  FDacDevice := ADacDevice;
  // Создаем событие, которое будет использоваться для пробуждения потока
  FBufferReadyEvent := TEvent.Create(nil, True, False, '');
  FreeOnTerminate := True;
end;

destructor TDataGeneratorThread.Destroy;
begin
  FBufferReadyEvent.Free;
  inherited;
end;

procedure TDataGeneratorThread.Execute;
begin
  // Основной цикл потока
  while not Terminated do
  begin
    // Вызываем событие для генерации данных
    if Assigned(FDacDevice.OnGenerateData) then
      FDacDevice.OnGenerateData(FDacDevice);
    // Ждем, пока основной поток не сообщит, что буфер готов
    FBufferReadyEvent.WaitFor(INFINITE);
  end;
end;

{ TDacDevice }

constructor TDacDevice.Create;
begin
  inherited;
  FSampleRate := 44100;
  FBitsPerSample := 16;
  FChannels := 1;
  FBufferSizeMS := 100; // Default buffer size
  FDeviceID := -1; // WAVE_MAPPER
end;

destructor TDacDevice.Destroy;
begin
  Stop;
  inherited;
end;

procedure TDacDevice.Start(ALoopCount: Cardinal = 1);
begin
  if IsActive then Exit;
  // Создаем и запускаем поток для генерации данных
  FGeneratorThread := TDataGeneratorThread.Create(Self);
  // Назначаем обработчик события окончания буфера
  OnBufferEnd := DoBufferEnd;
  FGeneratorThread.Start;
end;

procedure TDacDevice.DoBufferEnd(Sender: TObject);
begin
  // Сообщаем потоку, что буфер готов для заполнения
  FGeneratorThread.BufferReadyEvent.SetEvent;
end;

procedure TDacDevice.Stop(AGraceful: Boolean = True);
begin
  if not IsActive then Exit;
  // Останавливаем поток генерации данных
  if Assigned(FGeneratorThread) then
  begin;
    FGeneratorThread.Terminate;
    FGeneratorThread.BufferReadyEvent.SetEvent; // Пробуждаем поток, чтобы он мог завершиться
    FGeneratorThread.WaitFor;
    FGeneratorThread := nil;
  end;
end;

end.
