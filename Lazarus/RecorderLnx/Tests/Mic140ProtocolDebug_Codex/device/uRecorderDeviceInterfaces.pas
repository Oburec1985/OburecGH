unit uRecorderDeviceInterfaces;

{
  Абстракция устройства захвата данных.

  Соответствует оригинальному Recorder:
  - этапы Connect / Program / Start / Stop;
  - параметры через GetDeviceProperty / TrySetDeviceProperty;
  - список каналов GetChannels.

  Блок отсчётов — uRecorderAcquisitionTypes.
  См. Docs/devices/device_abstraction.md
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants,
  uRecorderAcquisitionTypes;

type
  ERecorderDeviceError = class(Exception);

  { Упрощённая FSM, видимая источнику данных. Детали — rdpStateWord. }
  TRecorderDeviceState = (
    rdsDisconnected,
    rdsConnected,
    rdsProgrammed,
    rdsStarted
  );

  { Идентификаторы свойств (аналог DEVPROP_* / GetDeviceProperty). }
  TRecorderDeviceProperty = (
    rdpName,
    rdpHost,
    rdpPort,
    rdpPollFrequencyHz,  // частота опроса
    rdpUpdateTimeMs, // период вычитки данных из драйвера?
    rdpChannelCount, // количество каналов
    rdpDeviceSerial, // серийный номер
    // Специфичное подсостояние драйвера (см. Mebius DEVICE_STATE).
    rdpStateWord,
    rdpErrorCode,
    rdpErrorText
  );

  TRecorderDeviceChannel = record
    Name: string;
    Address: string;
    UnitName: string;
    ModuleType: string;
    PollFrequencyHz: Double;
    Enabled: Boolean;
  end;

  TRecorderDeviceChannelArray = array of TRecorderDeviceChannel;

  { Интерфейсные методы устройства.
    Любой класс устройства, например TRecorderMic140Device, обязан иметь
    методы с такими сигнатурами. В классе-реализации Lazarus не показывает
    это автоматически, поэтому там такие методы выделены отдельным блоком. }
  IRecorderDevice = interface
    ['{39D2026D-851C-4EE4-97C7-3C86A02962A6}']
    // строковый ID поторый однозначно идентифицирует устройство
    function GetDeviceId: string;
    // отображаемое имя устройства
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;
    // Возвращает объект-владельца интерфейса для отладочных форм, которым нужен конкретный класс.
    function GetNativeObject: TObject;

    { Свойства задаются до ProgramDevice / Start (см. device_abstraction.md). }
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant;
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer = -1): Boolean;

    procedure Connect;
    procedure Disconnect;
    // вызов переконфига девайса
    procedure ProgramDevice;
    procedure Start;
    procedure Stop;

    //  Вызов чтения блока. Вызывать только из потока источника данных, не из GUI.
    function ReadBlock(ATimeoutMs: Cardinal; out ABlock: TRecorderAcquisitionBlock): Boolean;
    // свойства
    property DeviceId: string read GetDeviceId;
    property Name: string read GetName;
    property State: TRecorderDeviceState read GetState;
  end;

  // Общая объектная реализация устройства Recorder.
  //  Класс держит свойства, которые есть у любого устройства: имя, адрес,
  //  состояние, число каналов, частоты опроса и период обновления данных.
  //  Наследники, например MIC-140, переопределяют только свою специфику.

  { TRecorderDevice }

  TRecorderDevice = class(TInterfacedObject, IRecorderDevice)
  protected
    // Общие поля объекта устройства.
    fDeviceId: string;
    fState: TRecorderDeviceState;
    fHost: string;
    fPort: Integer;
    fName: string;
    fChannelCount: Integer;
    fPollFrequencyHz: Double;
    fUpdateTimeMs: Integer;

    // Объектные методы базового класса. Наследник может переопределить
    //  чтение параметров и формирование каналов под конкретный прибор.
    procedure ReadDeviceParameters; virtual;
    function BuildChannelName(AIndex: Integer): string; virtual;
    function BuildChannelAddress(AIndex: Integer): string; virtual;
    function GetChannelUnitName(AIndex: Integer): string; virtual;
    function GetChannelModuleType(AIndex: Integer): string; virtual;
    procedure SetFs(fs:Double); virtual;

    // Реализация getter-методов интерфейса IRecorderDevice.
    function GetDeviceId: string; virtual;
    function GetName: string; virtual;
    function GetState: TRecorderDeviceState; virtual;
    function GetChannels: TRecorderDeviceChannelArray; virtual;
    function GetNativeObject: TObject; virtual;
  public
    // Объектные методы TRecorderDevice
    constructor Create(const ADeviceId, AName: string); virtual;
    // Объектные помощники ручного управления счетчиком ссылок.
    function AddRef: LongInt;
    function Release: LongInt;

    // Реализация интерфейса IRecorderDevice: параметры устройства.
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant; virtual;
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer = -1): Boolean; virtual;

    { Реализация интерфейса IRecorderDevice: общий жизненный цикл. }
    procedure Connect; virtual;
    procedure Disconnect; virtual;
    procedure ProgramDevice; virtual;
    procedure Start; virtual;
    procedure Stop; virtual;

    { Реализация интерфейса IRecorderDevice: базовая заглушка чтения. }
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderAcquisitionBlock): Boolean; virtual;

    property DeviceId: string read GetDeviceId;
    property Name: string read GetName;
    property State: TRecorderDeviceState read GetState;
  end;


implementation

constructor TRecorderDevice.Create(const ADeviceId, AName: string);
begin
  inherited Create;
  fDeviceId := ADeviceId;
  fName := AName;
  fState := rdsDisconnected;
  fHost := '';
  fPort := 0;
  fChannelCount := 0;
  fPollFrequencyHz := 0.0;
  fUpdateTimeMs := 0;
end;

function TRecorderDevice.AddRef: LongInt;
begin
  Result := _AddRef;
end;

function TRecorderDevice.Release: LongInt;
begin
  Result := _Release;
end;

procedure TRecorderDevice.ReadDeviceParameters;
begin
end;

function TRecorderDevice.BuildChannelName(AIndex: Integer): string;
begin
  Result := Format('AIn%d', [AIndex + 1]);
end;

function TRecorderDevice.BuildChannelAddress(AIndex: Integer): string;
begin
  Result := IntToStr(AIndex + 1);
end;

function TRecorderDevice.GetChannelUnitName(AIndex: Integer): string;
begin
  Result := 'code';
end;

function TRecorderDevice.GetChannelModuleType(AIndex: Integer): string;
begin
  Result := fName;
end;

procedure TRecorderDevice.SetFs(fs:double);
begin
  fPollFrequencyHz:=fs;
end;

function TRecorderDevice.GetDeviceId: string;
begin
  Result := fDeviceId;
end;

function TRecorderDevice.GetName: string;
begin
  Result := fName;
end;

function TRecorderDevice.GetState: TRecorderDeviceState;
begin
  Result := fState;
end;

function TRecorderDevice.GetChannels: TRecorderDeviceChannelArray;
var
  lIndex: Integer;
begin
  Result := nil;
  SetLength(Result, fChannelCount);
  for lIndex := 0 to fChannelCount - 1 do
  begin
    Result[lIndex].Name := BuildChannelName(lIndex);
    Result[lIndex].Address := BuildChannelAddress(lIndex);
    Result[lIndex].UnitName := GetChannelUnitName(lIndex);
    Result[lIndex].ModuleType := GetChannelModuleType(lIndex);
    Result[lIndex].PollFrequencyHz := fPollFrequencyHz;
    Result[lIndex].Enabled := True;
  end;
end;

function TRecorderDevice.GetNativeObject: TObject;
begin
  Result := Self;
end;

function TRecorderDevice.GetDeviceProperty(AProperty: TRecorderDeviceProperty;
  AIndex: Integer): Variant;
begin
  case AProperty of
    rdpName:
      Result := fName;
    rdpHost:
      Result := fHost;
    rdpPort:
      Result := fPort;
    rdpPollFrequencyHz:
      result:=fPollFrequencyHz;
    rdpUpdateTimeMs:
      Result := fUpdateTimeMs;
    rdpChannelCount:
      Result := fChannelCount;
    rdpStateWord:
      Result := Ord(fState);
    rdpErrorCode:
      Result := 0;
    rdpErrorText:
      Result := '';
  else
    Result := Null;
  end;
end;

function TRecorderDevice.TrySetDeviceProperty(
  AProperty: TRecorderDeviceProperty; const AValue: Variant;
  AIndex: Integer): Boolean;
begin
  Result := True;
  case AProperty of
    rdpName:
      fName := VarToStr(AValue);
    rdpHost:
      fHost := VarToStr(AValue);
    rdpPort:
      fPort := AValue;
    rdpPollFrequencyHz:
      setfs(aValue);
    rdpUpdateTimeMs:
      fUpdateTimeMs := AValue;
    rdpChannelCount:
      fChannelCount := AValue;
  else
    Result := False;
  end;
end;

procedure TRecorderDevice.Connect;
begin
  ReadDeviceParameters;
  fState := rdsConnected;
end;

procedure TRecorderDevice.Disconnect;
begin
  fState := rdsDisconnected;
end;

procedure TRecorderDevice.ProgramDevice;
begin
  fState := rdsProgrammed;
end;

procedure TRecorderDevice.Start;
begin
  fState := rdsStarted;
end;

procedure TRecorderDevice.Stop;
begin
  if fState = rdsStarted then
    fState := rdsProgrammed;
end;

function TRecorderDevice.ReadBlock(ATimeoutMs: Cardinal;
  out ABlock: TRecorderAcquisitionBlock): Boolean;
begin
  ClearRecorderAcquisitionBlock(ABlock);
  Result := False;
end;

end.
