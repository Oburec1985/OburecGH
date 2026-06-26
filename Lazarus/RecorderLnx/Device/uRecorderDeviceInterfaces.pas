unit uRecorderDeviceInterfaces;

{
  Абстракция устройства захвата данных.

  Соответствует оригинальному Recorder:
  - этапы Connect / Program / Start / Stop;
  - параметры через GetDeviceProperty / TrySetDeviceProperty;
  - список каналов GetChannels.

  Блок отсчётов — uRecorderAcquisitionTypes.
  Особенности MIC-140 (TIn, CJC) — Device/MIC140 и Device/MIC140v2.

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
    rdpUpdateTimeMs,
    rdpChannelCount, // количество каналов
    rdpDeviceSerial, // серийный номер?
    { Специфичное подсостояние драйвера (см. Mebius DEVICE_STATE). }
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

  {
    Устаревшее имя блока отсчётов. Используйте TRecorderAcquisitionBlock.
    Поля Temperature* удалены — TIn это каналы устройства, не часть Core.
  }
  TRecorderDeviceSampleBlock = TRecorderAcquisitionBlock;

  IRecorderDevice = interface
    ['{39D2026D-851C-4EE4-97C7-3C86A02962A6}']
    function GetDeviceId: string;
    function GetName: string;
    function GetState: TRecorderDeviceState;
    function GetChannels: TRecorderDeviceChannelArray;

    { Свойства задаются до ProgramDevice / Start (см. device_abstraction.md). }
    function GetDeviceProperty(AProperty: TRecorderDeviceProperty;
      AIndex: Integer = -1): Variant;
    function TrySetDeviceProperty(AProperty: TRecorderDeviceProperty;
      const AValue: Variant; AIndex: Integer = -1): Boolean;

    procedure Connect;
    procedure Disconnect;
  procedure ProgramDevice;
    procedure Start;
    procedure Stop;

    {
      Legacy pull-модель чтения блока. Целевой путь — push через sink в драйвере v2.
      Вызывать только из потока источника данных, не из GUI.
    }
    function ReadBlock(ATimeoutMs: Cardinal;
      out ABlock: TRecorderAcquisitionBlock): Boolean;

    property DeviceId: string read GetDeviceId;
    property Name: string read GetName;
    property State: TRecorderDeviceState read GetState;
  end;

procedure ClearRecorderDeviceSampleBlock(var ABlock: TRecorderDeviceSampleBlock);
procedure CopyRecorderDeviceSampleBlock(const ASource: TRecorderDeviceSampleBlock;
  var ADest: TRecorderDeviceSampleBlock);

implementation

procedure CopyRecorderDeviceSampleBlock(const ASource: TRecorderDeviceSampleBlock;
  var ADest: TRecorderDeviceSampleBlock);
begin
  CopyRecorderAcquisitionBlock(ASource, ADest);
end;

procedure ClearRecorderDeviceSampleBlock(var ABlock: TRecorderDeviceSampleBlock);
begin
  ClearRecorderAcquisitionBlock(ABlock);
end;

end.
