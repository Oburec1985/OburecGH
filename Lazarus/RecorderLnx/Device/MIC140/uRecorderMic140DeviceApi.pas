unit uRecorderMic140DeviceApi;

{
  ╨Ъ╨╛╨╜╤В╤А╨░╨║╤В IMic140Device ╨┤╨╗╤П v1/v2. Wire-╤В╨╕╨┐╤Л тАФ uRecorderMic140WireTypes.
}

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants,
  uRecorderDeviceInterfaces,
  uRecorderMic140WireTypes,
  uRecorderTags;

type
  TRecorderMic140LegacyFirmware = uRecorderMic140WireTypes.TRecorderMic140LegacyFirmware;
  TMic140LegacyRawBlock = uRecorderMic140WireTypes.TMic140LegacyRawBlock;
  TMic140AuxTemperatureBlock = uRecorderMic140WireTypes.TMic140AuxTemperatureBlock;

  { Сервисный доступ к памяти MIC-140 через уже открытую сессию устройства.
    Нужен диалогам настройки, чтобы не открывать второе TCP-соединение и не
    вмешиваться в штатный жизненный цикл сбора данных. }
  IMic140ServiceMemory = interface
    ['{EDAF6ED5-B44E-49FC-BD09-AB8B88E78D8D}']
    function ReadServiceFirmware(
      out AFirmware: TRecorderMic140LegacyFirmware;
      out AErrorMessage: string): Boolean;
    function StopServiceScan(out AErrorMessage: string): Boolean;
    function ReadServiceFlash(AAddress: LongWord; var ABuffer;
      AByteCount: Integer; out AErrorMessage: string): Boolean;
  end;

  IMic140Device = interface(IRecorderDevice)
    ['{A8E4F1C2-3B5D-4E9A-9F0C-1D2E3F4A5B6C}']
    function GetDeviceSerial: Integer;
    function GetLegacyFirmware(out AFirmware: TRecorderMic140LegacyFirmware): Boolean;
    function GetNodeNumber: Integer;
    procedure RequestStopAcquisition;
    function ReadLegacyRawBlock(ATimeoutMs: Cardinal;
      out ARaw: TMic140LegacyRawBlock): Boolean;
    function LegacyDecommutateRawBlock(const ARaw: TMic140LegacyRawBlock;
      out ABlock: TRecorderDeviceSampleBlock): Boolean;
    function LastAuxTemperatureBlock: TMic140AuxTemperatureBlock;
    function LegacyStreamReadCount: Int64;
    function LegacyNumBuffGapCount: Integer;
    function LegacyDuplicateNumBuffCount: Integer;
    function LegacyCorruptReadCount: Integer;
    function LegacyMdpResyncByteCount: Int64;
    function LegacyTryRestartStreamAfterReadStall: Boolean;
    function LegacyConsumeStreamSequenceReset: Boolean;
    function ChannelCount: Integer;
    function RunServiceZeroBalance(const AChannelNumbers: array of Integer;
      APollFrequencyHz: Double; out AMeans: TRecorderDoubleArray;
      out AErrorMessage: string): Boolean;
    function UsesRawRing: Boolean;
  end;

implementation

end.
