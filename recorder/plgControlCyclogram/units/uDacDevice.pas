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
  Classes;

type
  TDacDevice = class(TObject)
  private
    FOnBufferEnd: TNotifyEvent;
    FSampleRate: Cardinal;
    FBitsPerSample: Cardinal;
    FChannels: Cardinal;
  public
    constructor Create;
    destructor Destroy; override;

    // Открывает и инициализирует устройство
    procedure Open; virtual; abstract;
    // Закрывает устройство и освобождает ресурсы
    procedure Close; virtual; abstract;
    // Начинает воспроизведение. ALoopCount=1 - однократно, >1 - N раз, 0 - бесконечно
    procedure Start(ALoopCount: Cardinal = 1); virtual; abstract;
    // Останавливает воспроизведение (плавно или мгновенно)
    procedure Stop(AGraceful: Boolean = True); virtual; abstract;
    // Ставит буфер с данными в очередь на воспроизведение
    procedure QueueBuffer(const ABuffer; ASize: Integer); virtual; abstract;
    // Проверяет, активно ли устройство в данный момент
    function IsActive: Boolean; virtual; abstract;

    property SampleRate: Cardinal read FSampleRate write FSampleRate; // Частота дискретизации (Гц)
    property BitsPerSample: Cardinal read FBitsPerSample write FBitsPerSample; // Битность (8, 16, ...)
    property Channels: Cardinal read FChannels write FChannels; // Количество каналов (1 - моно, 2 - стерео)
    property OnBufferEnd: TNotifyEvent read FOnBufferEnd write FOnBufferEnd; // Событие, возникающее после окончания воспроизведения буфера
  end;

implementation

constructor TDacDevice.Create;
begin
  inherited;
  FSampleRate := 44100;
  FBitsPerSample := 16;
  FChannels := 1;
end;

destructor TDacDevice.Destroy;
begin

  inherited;
end;

end.
